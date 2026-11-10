# Cut long solo recordings into phrases at rests, track pitch (YIN), measure calmness, find the transposition
# onto A dorian / A aeolian. usage: python3 -I analyse.py <wav dir> <out json> [ids...]
import sys, os, json, glob
import numpy as np
from scipy.io import wavfile
from scipy.ndimage import median_filter

SR = 44100
HOP = 441            # 10 ms
FRAME = 2048
FMIN, FMAX = 90.0, 1300.0
DORIAN = {9, 11, 0, 2, 4, 6, 7}
AEOLIAN = {9, 11, 0, 2, 4, 5, 7}


def load(path):
    sr, x = wavfile.read(path)
    assert sr == SR, (path, sr)
    return x.astype(np.float32)


def yin(x):
    n = 1 + max(0, (len(x) - FRAME) // HOP)
    tmin, tmax = int(SR / FMAX), int(SR / FMIN)
    W = FRAME // 2
    f0 = np.zeros(n, np.float32)
    conf = np.ones(n, np.float32)
    rms = np.zeros(n, np.float32)
    for c0 in range(0, n, 400):                                  # chunks keep memory small
        idx = np.arange(c0, min(n, c0 + 400))
        fr = np.stack([x[i * HOP: i * HOP + FRAME] for i in idx]).astype(np.float32)
        rms[idx] = np.sqrt(np.mean(fr[:, :W] ** 2, axis=1) + 1e-12)
        # difference function d(tau) = sum (x_j - x_{j+tau})^2 over j < W, via FFT cross-correlation
        F = np.fft.rfft(fr, 2 * FRAME)
        a = fr[:, :W]
        Fa = np.fft.rfft(a, 2 * FRAME)
        acf = np.fft.irfft(np.conj(Fa) * F, 2 * FRAME)[:, :tmax + 1]
        e0 = np.sum(a * a, axis=1, keepdims=True)
        cs = np.cumsum(fr ** 2, axis=1)
        et = np.stack([cs[:, t + W - 1] - (cs[:, t - 1] if t > 0 else 0) for t in range(tmax + 1)], axis=1)
        d = e0 + et - 2 * acf
        d[:, 0] = 0
        cm = d[:, 1:] * np.arange(1, tmax + 1) / (np.cumsum(d[:, 1:], axis=1) + 1e-12)
        cm = np.concatenate([np.ones((len(idx), 1)), cm], axis=1)
        for k, row in enumerate(cm):
            r = row[tmin:tmax]
            below = np.where(r < 0.15)[0]
            if len(below):
                t = below[0]
                while t + 1 < len(r) and r[t + 1] < r[t]: t += 1
            else:
                t = int(np.argmin(r))
            tau = t + tmin
            if 1 <= tau < tmax:
                y0, y1, y2 = row[tau - 1], row[tau], row[tau + 1]
                den = y0 - 2 * y1 + y2
                tau = tau + (0.5 * (y0 - y2) / den if abs(den) > 1e-9 else 0)
            f0[idx[k]] = SR / tau
            conf[idx[k]] = r[t]
    return f0, conf, rms


def notes_of(midi, voiced, rms):
    """runs of one rounded semitone, min 50 ms; returns (start, end, pitch) in frames"""
    out, i, n = [], 0, len(midi)
    r = np.round(midi)
    while i < n:
        if not voiced[i]: i += 1; continue
        j = i
        while j + 1 < n and voiced[j + 1] and r[j + 1] == r[i]: j += 1
        # re-articulation of the same pitch: a clear dip in level splits the run
        if j - i + 1 >= 5:
            out.append([i, j + 1, float(np.median(midi[i:j + 1]))])
        i = j + 1
    # merge tiny gaps (< 40 ms) between the same pitch
    merged = []
    for s, e, p in out:
        if merged and round(merged[-1][2]) == round(p) and s - merged[-1][1] <= 4:
            merged[-1][1] = e
        else:
            merged.append([s, e, p])
    return merged


def analyse(path):
    x = load(path)
    f0, conf, rms = yin(x)
    db = 20 * np.log10(rms + 1e-9)
    ref = np.percentile(db, 95)
    voiced = (conf < 0.25) & (db > ref - 35)
    midi = 69 + 12 * np.log2(np.maximum(f0, 1) / 440)
    midi = median_filter(midi, 5)
    # global tuning: median deviation from the semitone grid
    dev = (midi[voiced] - np.round(midi[voiced]))
    cents = float(np.median(dev)) if voiced.any() else 0.0
    midi_c = midi - cents
    notes = notes_of(midi_c, voiced, rms)
    # pitch-class histogram weighted by duration → best shift onto dorian / aeolian
    hist = np.zeros(12)
    for s, e, p in notes: hist[int(round(p)) % 12] += (e - s)
    best = []
    for target, S in (('dorian', DORIAN), ('aeolian', AEOLIAN)):
        for sh in range(-6, 6):
            fit = sum(hist[pc] for pc in range(12) if (pc + sh) % 12 in S) / max(1, hist.sum())
            best.append((fit, -abs(sh), sh, target))
    best.sort(reverse=True)
    # rests: ≥ 0.25 s of unvoiced and quiet frames
    quiet = (~voiced) & (db < ref - 25)
    phrases, i, n = [], 0, len(db)
    act = np.where(voiced)[0]
    if len(act):
        start = act[0]
        k = start
        while k < n:
            if quiet[k]:
                j = k
                while j < n and quiet[j]: j += 1
                if j - k >= 25 or j >= n:
                    phrases.append((start, k))
                    nxt = np.where(voiced[j:])[0]
                    if not len(nxt): break
                    start = j + nxt[0]
                    k = start
                    continue
                k = j
            else:
                k += 1
    return x, dict(cents=cents, hist=hist.tolist(), fits=[b for b in best[:4]], notes=notes, phrases=phrases,
                   ref=float(ref))


def phrase_stats(notes, s, e, sh):
    ns = [(a, b, p + sh) for a, b, p in notes if a >= s and b <= e + 2]
    dur = (e - s) / 100
    if not ns: return None
    lens = [(b - a) / 100 for a, b, _ in ns]
    pcs = [int(round(p)) % 12 for _, _, p in ns]
    out_d = [round(p) for (a, b, p), l in zip(ns, lens) if int(round(p)) % 12 not in DORIAN and l > 0.08]
    out_a = [round(p) for (a, b, p), l in zip(ns, lens) if int(round(p)) % 12 not in AEOLIAN and l > 0.08]
    names = 'C C# D D# E F F# G G# A A# B'.split()
    return dict(dur=round(dur, 2), n=len(ns), nps=round(len(ns) / dur, 2), longest=round(max(lens), 2),
                long_share=round(sum(l for l in lens if l >= 0.3) / dur, 2), last=round(lens[-1], 2),
                lo=int(round(min(p for _, _, p in ns))), hi=int(round(max(p for _, _, p in ns))),
                fits=('both' if not out_d and not out_a else 'dorian' if not out_d else 'aeolian' if not out_a else 'none'),
                out_dorian=len(out_d), out_aeolian=len(out_a),
                melody=' '.join(names[int(round(p)) % 12] + str(int(round(p)) // 12 - 1) + ('' if l < 0.3 else '_')
                                for (_, _, p), l in zip(ns, lens)))


if __name__ == '__main__':
    wdir, outp = sys.argv[1], sys.argv[2]
    ids = sys.argv[3:] or [os.path.basename(f)[:-4] for f in sorted(glob.glob(os.path.join(wdir, '*.wav')))]
    res = {}
    for i in ids:
        x, a = analyse(os.path.join(wdir, i + '.wav'))
        fit, _, sh, target = a['fits'][0]
        ph = []
        for s, e in a['phrases']:
            st = phrase_stats(a['notes'], s, e, sh)
            if st: ph.append(dict(s=s / 100, e=e / 100, **st))
        res[i] = dict(cents=round(a['cents'], 3), shift=sh, target=target, fit=round(fit, 3),
                      fits=[(round(f, 3), s, t) for f, _, s, t in a['fits']], phrases=ph, len=len(x) / SR,
                      notes=a['notes'], raw=[[int(s), int(e)] for s, e in a['phrases']])
        print(i, f"{len(x)/SR:6.1f}s cents {a['cents']:+.2f} → shift {sh:+d} {target} fit {fit:.3f}", 'phrases', len(ph), flush=True)
    json.dump(res, open(outp, 'w'), indent=1)
