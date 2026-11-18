#!/usr/bin/env python3
"""The noise buffers of superdough (Strudel), made the same way: 2 seconds, Math.random white noise, Paul Kellet's
pink filter, brown = leaky integration. Written as 48 kHz WAVs for the SuperCollider voice sounds/sdNoise.scd.
usage: python3 noise-buffers.py <out-dir> [sampleRate]"""
import sys, numpy as np, soundfile as sf
out, sr = sys.argv[1], int(sys.argv[2]) if len(sys.argv) > 2 else 48000
rng = np.random.default_rng(909)
n = 2 * sr
white = rng.random(n) * 2 - 1
pink = np.zeros(n); b = [0.0] * 7
for i, w in enumerate(white):
    b[0] = 0.99886 * b[0] + w * 0.0555179; b[1] = 0.99332 * b[1] + w * 0.0750759; b[2] = 0.969 * b[2] + w * 0.153852
    b[3] = 0.8665 * b[3] + w * 0.3104856; b[4] = 0.55 * b[4] + w * 0.5329522; b[5] = -0.7616 * b[5] - w * 0.016898
    pink[i] = (b[0] + b[1] + b[2] + b[3] + b[4] + b[5] + b[6] + w * 0.5362) * 0.11
    b[6] = w * 0.115926
brown = np.zeros(n); last = 0.0
w2 = rng.random(n) * 2 - 1
for i, w in enumerate(w2):
    last = (last + 0.02 * w) / 1.02; brown[i] = last
for name, x in [('pink', pink), ('white', rng.random(n) * 2 - 1), ('brown', brown)]:
    sf.write(f'{out}/{name}.wav', x.astype(np.float32), sr, subtype='FLOAT')
print('ok')
