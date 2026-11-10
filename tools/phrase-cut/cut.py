# Split phrases (long ones at the ends of long notes), keep calm ones, render them moved into A (varispeed),
# evened in level. usage: python3 -I cut.py <all.json> <wav dir> <out dir> [--render]
import sys, os, json, re, subprocess
import numpy as np
from scipy.io import wavfile
from scipy.signal import resample

SR = 44100
NAMES = 'C C# D D# E F F# G G# A A# B'.split()
MAXDUR = 4 * 4 * 60 / 124          # 4 bars at 124 BPM = 7.74 s
FRAME_S = 0.01

all_, wdir, odir = sys.argv[1], sys.argv[2], sys.argv[3]
RENDER = '--render' in sys.argv
R = json.load(open(all_))

# which column a recording goes to, the player, instrument, and Freesound metadata (checked on the pages)
SRC = {
    '424876': ('tpd', 'Trumpet improvisation, Bb dorian', 'Hikmet Altunbaşlıer', 'emirdemirel', 'CC BY 4.0'),
    '424907': ('tpd', 'Trumpet improvisation, Bb minor (1)', 'Hikmet Altunbaşlıer', 'emirdemirel', 'CC BY 4.0'),
    '424905': ('tpm', 'Trumpet improvisation, Bb minor (hikmet_minor2)', 'Hikmet Altunbaşlıer', 'emirdemirel', 'CC BY 4.0'),
    '430268': ('tpx', 'Trumpet improvisation, Bb minor', 'Hikmet Altunbaşlıer', 'emirdemirel', 'CC BY 4.0'),
    '424906': ('tpx', 'Trumpet improvisation, Bb mixolydian', 'Hikmet Altunbaşlıer', 'emirdemirel', 'CC BY 4.0'),
    '430269': ('tpx', 'Trumpet improvisation, Bb major', 'Hikmet Altunbaşlıer', 'emirdemirel', 'CC BY 4.0'),
    '424894': ('sax', 'Saxophone improvisation, Bb dorian', 'Toprak Barut', 'emirdemirel', 'CC BY 4.0'),
    '424899': ('sax', 'Saxophone improvisation, Bb mixolydian (toprak_mixolydian2)', 'Toprak Barut', 'emirdemirel', 'CC BY 4.0'),
    '430271': ('sax', 'Saxophone improvisation, Bb minor', 'Toprak Barut', 'emirdemirel', 'CC BY 4.0'),
    '424911': ('sax', 'Saxophone improvisation, Bb lydian (2)', 'Toprak Barut', 'emirdemirel', 'CC BY 4.0'),
    '430267': ('sax', 'Saxophone improvisation, Bb major (1)', 'Toprak Barut', 'emirdemirel', 'CC BY 4.0'),
    '424916': ('sax', 'Saxophone improvisation, Bb major (2)', 'Toprak Barut', 'emirdemirel', 'CC BY 4.0'),
    '65509': ('flute', 'Flute2 — a short melody on the flute', 'juskiddink', 'juskiddink', 'CC BY 4.0'),
}


def tok(p): p = int(round(p)); return NAMES[p % 12] + str(p // 12 - 1)


def scale_run(ps):
    best = cur = 1; d0 = 0
    for a, b in zip(ps, ps[1:]):
        d = b - a
        if 1 <= abs(d) <= 2 and (d0 == 0 or (d > 0) == (d0 > 0)): cur += 1; d0 = d
        else: cur = 1; d0 = d if 1 <= abs(d) <= 2 else 0
        best = max(best, cur)
    return best


def stats(ns, s, e):
    """ns: notes [start, end, pitch] in frames, already shifted; s, e: the piece in frames"""
    dur = (e - s) * FRAME_S
    lens = [(b - a) * FRAME_S for a, b, _ in ns]
    pcs = {int(round(p)) % 12 for _, _, p in ns}
    chrom = pcs & {1, 3, 8, 10}
    fits = 'drop' if chrom or {5, 6} <= pcs else 'dorian' if 6 in pcs else 'aeolian' if 5 in pcs else 'both'
    ps = [int(round(p)) for _, _, p in ns]
    return dict(dur=round(dur, 2), n=len(ns), nps=round(len(ns) / dur, 2), longest=round(max(lens), 2),
                long_share=round(sum(l for l in lens if l >= 0.3) / dur, 2), last=round(lens[-1], 2),
                run=scale_run(ps), fits=fits, lo=tok(min(ps)), hi=tok(max(ps)),
                melody=' '.join(tok(p) + ('_' if l >= 0.3 else '') for (_, _, p), l in zip(ns, lens)))


cands = []
for rid, v in R.items():
    if rid not in SRC: continue
    sh = v['shift']
    notes = [[a, b, p + sh] for a, b, p in v['notes']]
    raws = v['raw']
    for k, (s, e) in enumerate(raws):
        nxt = raws[k + 1][0] if k + 1 < len(raws) else None
        ns = [n for n in notes if n[0] >= s - 2 and n[1] <= e + 3]
        if not ns: continue
        pieces = []
        if (e - s) * FRAME_S <= MAXDUR:
            pieces.append((s, e, ns, 'rest'))
        else:
            # cut points: the end of a note of at least 0.5 s; greedy pieces of 2 … 7.7 s
            i0 = 0
            while i0 < len(ns):
                start = ns[i0][0]
                best = None
                for j in range(i0, len(ns)):
                    if (ns[j][1] - start) * FRAME_S > MAXDUR: break
                    if (ns[j][1] - ns[j][0]) * FRAME_S >= 0.5 and (ns[j][1] - start) * FRAME_S >= 2: best = j
                if best is None:
                    # no long note in reach: skip to the next long note's successor
                    j = next((j for j in range(i0, len(ns)) if (ns[j][1] - ns[j][0]) * FRAME_S >= 0.5), None)
                    if j is None: break
                    i0 = j + 1; continue
                pieces.append((start, ns[best][1], ns[i0:best + 1], 'long note'))
                i0 = best + 1
        for (ps, pe, pns, how) in pieces:
            st = stats(pns, ps, pe)
            calm = (1.5 <= st['dur'] <= MAXDUR and st['nps'] <= 3.2 and st['longest'] >= 0.5 and st['long_share'] >= 0.5
                    and st['n'] >= 3 and st['run'] < 5 and st['fits'] != 'drop')
            # where the file may end: a tail after a rest, a short release after a cut at a long note
            if how == 'rest':
                tail_end = min(pe + 35, (nxt - 5) if nxt else pe + 35)
            else:
                nn = next((n for n in notes if n[0] >= pe), None)
                tail_end = min(pe + 8, nn[0] - 1) if nn else pe + 8
            cands.append(dict(id=rid, col=SRC[rid][0], shift=sh, cents=v['cents'], s=ps, e=pe, end=tail_end, how=how,
                              calm=calm, **st))

# by hand after the first listing (not by ear): too many notes (≥ 19 / nps ≥ 3), near-duplicates, short endings
DROP = {('424894', 28.93), ('430271', 12.90), ('424905', 50.60), ('424905', 87.27), ('424906', 66.49),
        ('430268', 29.99), ('424876', 25.98), ('430269', 76.19), ('65509', 20.61)}
keep = [c for c in cands if c['calm'] and (c['id'], round(c['s'] / 100, 2)) not in DROP]
for c in sorted(keep, key=lambda c: (c['col'], c['id'], c['s'])):
    print(f"{c['col']:5} {c['id']:>6} {c['shift']:+d} {c['s']/100:6.2f}-{c['end']/100:6.2f} {c['dur']:4.1f}s n{c['n']:2} nps{c['nps']:4.1f} "
          f"share{c['long_share']:4.2f} last{c['last']:4.1f} {c['fits']:7} {c['how']:9} {c['melody']}")
print(len(keep), {k: sum(c['col'] == k for c in keep) for k in ('tpd', 'tpm', 'tpx', 'sax', 'flute')})
json.dump(keep, open(os.path.join(os.path.dirname(all_), 'keep.json'), 'w'), indent=1)

if RENDER:
    os.makedirs(odir, exist_ok=True)
    TARGET = -20.0   # dBFS RMS of the sounding part
    out = []
    for c in sorted(keep, key=lambda c: (c['col'], c['id'], c['s'])):
        sr, x = wavfile.read(os.path.join(wdir, c['id'] + '.wav'))
        a = max(0, int((c['s'] * FRAME_S - 0.03) * SR)); b = int(c['end'] * FRAME_S * SR)
        y = x[a:b].astype(np.float64)
        ratio = 2 ** ((c['shift'] - c['cents']) / 12)     # > 1 = up: played faster
        y = resample(y, int(round(len(y) / ratio)))
        fi, fo = int(0.015 * SR), int((0.15 if c['how'] == 'rest' else 0.1) * SR)
        y[:fi] *= np.linspace(0, 1, fi); y[-fo:] *= np.linspace(1, 0, fo)
        fr = y[: len(y) // 1024 * 1024].reshape(-1, 1024)
        rms = np.sqrt(np.mean(fr ** 2, axis=1)); db = 20 * np.log10(rms + 1e-12)
        act = rms[db > db.max() - 30]
        level = 20 * np.log10(np.sqrt(np.mean(act ** 2)))
        g = 10 ** ((TARGET - level) / 20)
        peak = np.max(np.abs(y)) * g
        if peak > 10 ** (-1 / 20): g *= 10 ** (-1 / 20) / peak
        y *= g
        name = f"{c['col']}-{c['id']}-{int(round(c['s'] * FRAME_S * 10)):04d}"
        tmp = os.path.join(odir, name + '.wav')
        wavfile.write(tmp, SR, (np.clip(y, -1, 1) * 32767).astype(np.int16))
        subprocess.run(['ffmpeg', '-nostdin', '-loglevel', 'error', '-y', '-i', tmp, '-c:a', 'flac', os.path.join(odir, name + '.flac')], check=True)
        os.remove(tmp)
        out.append(dict(file=name + '.flac', **{k: c[k] for k in ('col', 'id', 'shift', 'cents', 'fits', 'dur', 'n', 'nps', 'melody', 'how')},
                        src_from=round(a / SR, 2), src_to=round(b / SR, 2), len=round(len(y) / SR, 2),
                        gain_db=round(20 * np.log10(g), 1), limited=bool(peak > 10 ** (-1 / 20))))
    json.dump(out, open(os.path.join(odir, 'phrases.json'), 'w'), indent=1, ensure_ascii=False)
    print('rendered', len(out))
