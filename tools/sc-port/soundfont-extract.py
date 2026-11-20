#!/usr/bin/env python3
"""Extract a General MIDI soundfont preset as Strudel plays it (gm_* sounds, @strudel/soundfonts: the WebAudioFont
presets of felixroos/webaudiofontdata) into WAV files + zones.json for SuperCollider (sc/sounds/sdFont.scd).

usage: python3 soundfont-extract.py <preset, e.g. 0110_JCLive_sf2_file> [<preset> …]
Writes sc/samples/gm/<preset>/z<i>.wav (decoded with ffmpeg at the file's own rate) and zones.json:
[{ keyRangeLow, keyRangeHigh, originalPitch, coarseTune, fineTune, loopStart, loopEnd, sampleRate, file }].
The preset file is parsed as data (key: value pairs), not run.
"""
import base64, json, os, re, subprocess, sys, tempfile

here = os.path.dirname(os.path.abspath(__file__))
out_root = os.path.join(here, '..', '..', 'sc', 'samples', 'gm')
URL = 'https://raw.githubusercontent.com/felixroos/webaudiofontdata/master/sound/'
NUM = ['midi', 'originalPitch', 'keyRangeLow', 'keyRangeHigh', 'loopStart', 'loopEnd', 'coarseTune', 'fineTune', 'sampleRate']

for preset in sys.argv[1:]:
    src = subprocess.run(['curl', '-sSf', URL + preset + '.js'], check=True, capture_output=True, text=True).stdout
    zones = []
    for block in re.findall(r'\{([^{}]*)\}', src.split('zones:', 1)[1]):
        z = {k: float(v) for k, v in re.findall(r'(\w+)\s*:\s*(-?[0-9.]+)\s*(?:,|$)', block) if k in NUM}
        m = re.search(r"file\s*:\s*'([^']*)'", block)
        if not m or 'keyRangeLow' not in z: continue
        z['data'] = m.group(1)
        zones.append(z)
    d = os.path.join(out_root, preset); os.makedirs(d, exist_ok=True)
    meta = []
    for i, z in enumerate(zones):
        raw = base64.b64decode(z.pop('data'))
        with tempfile.NamedTemporaryFile(suffix='.bin', delete=False) as f: f.write(raw); tmp = f.name
        wav = os.path.join(d, f'z{i}.wav')
        ok = subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-i', tmp, '-c:a', 'pcm_f32le', wav]).returncode == 0
        os.unlink(tmp)
        # a zone ffmpeg cannot decode (a few bytes of MP3) is kept without a file: the voice skips it
        if not ok: print(f'  {preset} zone {i} (keys {z["keyRangeLow"]:.0f}-{z["keyRangeHigh"]:.0f}): not decodable, left out')
        meta.append({**{k: z.get(k, 0) for k in NUM}, 'file': f'gm/{preset}/z{i}.wav' if ok else None})
    json.dump(meta, open(os.path.join(d, 'zones.json'), 'w'), indent=1)
    print(preset, len(meta), 'zones')
