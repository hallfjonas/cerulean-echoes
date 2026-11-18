#!/usr/bin/env python3
"""Run a list of scenarios on both sides (Strudel and SuperCollider) and compare each.

usage: python3 batch.py <scenarios.json> <workdir> [name-filter]
scenarios.json: [ { "name": "kick-punch1", "strudel": "stemJ1_kick", "sc": "kick", "events": "kick",
                    "scen": { "bpm": 124, "cycles": 8, "cc": {...}, "events": [...] } }, ... ]
Needs: node (npm install in tools/), python3 with numpy scipy soundfile pyloudnorm, SuperCollider (sc-render.sh;
SC_RENDER overrides it).
Prints one line per scenario and writes <workdir>/summary.json.
"""
import json, os, subprocess, sys
import compare
from compare import load, audio, events

here = os.path.dirname(os.path.abspath(__file__))
# the track: CE_TRACK=<folder>/<name> under tracks/ and sc/tracks/ (default 009-house/009-house), e.g.
# CE_TRACK=008-groove-techno/008-groove-techno python3 batch.py scenarios/008-kick.json /tmp/cmp-008-kick
track = os.environ.get('CE_TRACK', '009-house/009-house')
os.environ['CE_TRACK'] = track   # for sc-render.sh
track_strudel = os.path.join(here, '..', '..', 'tracks', track + '.strudel')
sc_render = os.environ.get('SC_RENDER', os.path.join(here, 'sc-render.sh'))

scens = json.load(open(sys.argv[1])); work = sys.argv[2]; filt = sys.argv[3] if len(sys.argv) > 3 else ''
os.makedirs(work, exist_ok=True)
out = []
for s in scens:
    if filt not in s['name']: continue
    sf = os.path.join(work, s['name'] + '.json'); json.dump(s['scen'], open(sf, 'w'))
    pa, pb = os.path.join(work, s['name'] + '-strudel'), os.path.join(work, s['name'] + '-sc')
    subprocess.run(['node', os.path.join(here, 'strudel-run.mjs'), track_strudel, s['strudel'], sf, pa], check=True,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    subprocess.run([sc_render, sf, pb, s['sc']], check=True)
    a, sr = load(pa); b, _ = load(pb)
    # "from": compare from this cycle on (e.g. after a held chord that Strudel's first query cannot play)
    compare.FROM = s['scen'].get('from', 0)
    cut = int(compare.FROM * 4 * 60 / s['scen'].get('bpm', 124) * sr)
    a, b = a[cut:], b[cut:]
    au = audio(a, b, sr)
    # the offline Strudel render sometimes comes out broken (superdough/node-web-audio-api): render it once more
    if au['null_db'] > -20:
        subprocess.run(['node', os.path.join(here, 'strudel-run.mjs'), track_strudel, s['strudel'], sf, pa + '-retry'],
                       check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        a2, _ = load(pa + '-retry'); a2 = a2[cut:]; au2 = audio(a2, b, sr)
        if au2['null_db'] < au['null_db']: au, a = au2, a2; au['retried'] = True
    r = dict(name=s['name'], audio=au, events=events(pa, pb, s.get('events', 'none')))
    out.append(r)
    au, ev = r['audio'], r['events']
    evs = 'events ok' if ev.get('onsets_equal', ev.get('equal')) else ('events DIFF ' + json.dumps(ev)[:300] if ev else '')
    print(f"{s['name']:28s} LUFS {au['lufs_strudel']:7.2f} / {au['lufs_sc']:7.2f} (Δ {au['lufs_diff']:+.2f})  "
          f"null {au['null_db']:6.1f} dB  bands ≤{au['band_diff_max']:4.1f} dB  env r {au['env_corr']:.3f}  {evs}", flush=True)
json.dump(out, open(os.path.join(work, 'summary.json'), 'w'), indent=1)
