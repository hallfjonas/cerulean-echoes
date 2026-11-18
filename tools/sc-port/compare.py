#!/usr/bin/env python3
"""Compare a Strudel render with a SuperCollider render of the same stem and scenario.

usage: python3 compare.py <strudel-prefix> <sc-prefix> [--events kick|bass|none] [--json out.json]

Audio (both WAVs, 48 kHz): integrated loudness (BS.1770), peak, the time offset that lines them up best,
the level difference per third-octave band (long-term spectrum), the correlation of the loudness envelopes
(10 ms), and a null test (residual of SC − Strudel after alignment, in dB below the Strudel signal: −40 dB or
lower means practically identical; noise-based sounds never null, judge them by the spectrum).
Events: onsets (in 16ths) and pitches per onset, from <prefix>.events.json of both sides.
"""
import json, sys, math
import numpy as np, soundfile as sf, pyloudnorm as pyln
from scipy.signal import correlate

def load(prefix):
    x, sr = sf.read(prefix + '.wav', always_2d=True)
    return x.astype(np.float64), sr

def bands(x, sr):
    spec = np.abs(np.fft.rfft(x.mean(axis=1) * np.hanning(len(x)))) ** 2
    f = np.fft.rfftfreq(len(x), 1 / sr)
    centers = [25 * 2 ** (i / 3) for i in range(0, 30) if 25 * 2 ** (i / 3) < 18000]
    out = []
    for c in centers:
        lo, hi = c / 2 ** (1 / 6), c * 2 ** (1 / 6)
        e = spec[(f >= lo) & (f < hi)].sum()
        out.append((c, 10 * math.log10(e + 1e-30)))
    return out

def envelope(x, sr):
    m = x.mean(axis=1) ** 2
    n = int(0.01 * sr)
    k = len(m) // n
    return 10 * np.log10(m[:k * n].reshape(k, n).mean(axis=1) + 1e-12)

def audio(a, b, sr):
    meter = pyln.Meter(sr)
    la, lb = meter.integrated_loudness(a), meter.integrated_loudness(b)
    n = min(len(a), len(b))
    a, b = a[:n], b[:n]
    # alignment: cross-correlation of the mono signals within ±20 ms
    w = int(0.02 * sr)
    ma, mb = a.mean(axis=1), b.mean(axis=1)
    seg = slice(0, min(n, sr * 4))
    c = correlate(mb[seg], ma[seg], mode='full', method='fft')
    mid = len(ma[seg]) - 1
    lag = int(np.argmax(c[mid - w: mid + w + 1]) - w)
    bs = np.roll(b, -lag, axis=0)
    res = bs - a
    ea, er = (a ** 2).sum(), (res ** 2).sum()
    null = 10 * math.log10(er / ea) if ea > 0 and er > 0 else -200.0
    ba, bb = bands(a, sr), bands(bs, sr)
    ref = max(v for _, v in ba)
    diffs = [(round(c), round(vb - va, 1)) for (c, va), (_, vb) in zip(ba, bb) if va > ref - 50]
    ea_, eb_ = envelope(a, sr), envelope(bs, sr)
    live = (ea_ > ea_.max() - 50) | (eb_ > eb_.max() - 50)
    corr = float(np.corrcoef(ea_[live], eb_[live])[0, 1]) if live.sum() > 2 else float('nan')
    return dict(lufs_strudel=round(la, 2), lufs_sc=round(lb, 2), lufs_diff=round(lb - la, 2),
                peak_strudel=round(20 * math.log10(np.abs(a).max() + 1e-12), 2),
                peak_sc=round(20 * math.log10(np.abs(b).max() + 1e-12), 2),
                offset_ms=round(1000 * lag / sr, 2), null_db=round(null, 1), env_corr=round(corr, 4),
                band_diff_db=diffs, band_diff_max=max((abs(d) for _, d in diffs), default=0))

def midi_of(v):
    if 'note' in v:
        n = v['note']
        if isinstance(n, (int, float)): return float(n)
        names = dict(c=0, d=2, e=4, f=5, g=7, a=9, b=11)
        s = n.lower(); k = names[s[0]]; i = 1
        while i < len(s) and s[i] in '#b': k += 1 if s[i] == '#' else -1; i += 1
        return 12 * (int(s[i:]) + 1) + k
    if 'freq' in v and isinstance(v['freq'], (int, float)): return 69 + 12 * math.log2(v['freq'] / 440)
    return None

FROM = 0   # compare only from this cycle on (set by batch.py from the scenario's "from")

def events(pa, pb, kind):
    ea = [e for e in json.load(open(pa + '.events.json')) if e['b'] >= FROM - 1e-9]
    eb = [e for e in json.load(open(pb + '.events.json')) if e['b'] >= FROM - 1e-9]
    q = lambda b: round(b * 16 * 1000) / 1000     # onset in 16ths
    if kind == 'kick':   # Strudel: sample + body events per hit; compare the sample hits
        A = sorted(q(e['b']) for e in ea if e['v'].get('s') == 'bd')
        B = sorted(q(e['b']) for e in eb)
        return dict(count_strudel=len(A), count_sc=len(B), onsets_equal=A == B,
                    first_diff=next(([a, b] for a, b in zip(A, B) if a != b), None))
    if kind == 'bass':   # Strudel: one event per sound side; compare onset + pitch + length per note
        main = lambda v: 'fmi' in v or v.get('s') in ('triangle', 'sawtooth')   # the main layer of each sound
        A = sorted({(q(e['b']), round(midi_of(e['v']), 3), round((e['e'] - e['b']) * 16 * e['v'].get('clip', 1), 3), round(e['v'].get('velocity', 1), 3)) for e in ea if main(e['v'])})
        B = sorted({(q(e['b']), round(midi_of(e['v']), 3), round(e['v'].get('len16', -1), 3), round(e['v'].get('vel', 1), 3)) for e in eb})
        sa, sb = set(A), set(B)
        return dict(count_strudel=len(A), count_sc=len(B), equal=A == B,
                    only_strudel=sorted(sa - sb)[:8], only_sc=sorted(sb - sa)[:8])
    if kind == 'generic':   # any stem: (onset, sound tag, gain, note) per event; tag = bank_s:n for samples, else s
        def tag(v):
            if 'bank' in v: return f"{v['bank']}_{v['s']}:{int(v.get('n', 0))}"
            return v.get('s')
        def note(v):
            m = midi_of(v) if ('note' in v or 'freq' in v) else None
            return None if m is None else round(m, 2)
        A = sorted((q(e['b']), tag(e['v']), round(e['v'].get('gain', 1) * e['v'].get('velocity', 1), 3), note(e['v'])) for e in ea)
        B = sorted((q(e['b']), e['v'].get('tag'), round(e['v'].get('g', 0), 3), round(e['v']['midi'], 2) if 'midi' in e['v'] else None) for e in eb)
        from collections import Counter
        ca, cb = Counter(A), Counter(B)
        return dict(count_strudel=len(A), count_sc=len(B), equal=ca == cb,
                    only_strudel=sorted((ca - cb).elements())[:8], only_sc=sorted((cb - ca).elements())[:8])
    return {}

if __name__ == '__main__':
    args = sys.argv[1:]
    pa, pb = args[0], args[1]
    kind = args[args.index('--events') + 1] if '--events' in args else 'none'
    a, sr = load(pa); b, sr2 = load(pb)
    assert sr == sr2
    r = dict(audio=audio(a, b, sr), events=events(pa, pb, kind))
    if '--json' in args: json.dump(r, open(args[args.index('--json') + 1], 'w'), indent=1)
    print(json.dumps(r, indent=1))
