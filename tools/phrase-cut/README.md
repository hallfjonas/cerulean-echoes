# phrase-cut — cut calm phrases from long solo recordings (lab/melodie/melodie-3, samples/horn-phrases)

Python 3 with numpy + scipy, ffmpeg. Run with `python3 -I` (downloads are untrusted data).
1. Download the Freesound HQ previews, decode to mono 44.1 kHz float WAV, one file per sound id:
   `ffmpeg -i <id>.mp3 -ac 1 -ar 44100 -c:a pcm_f32le wav/<id>.wav`
2. `python3 -I analyse.py wav all.json` — YIN pitch per 10 ms, notes, rests (≥ 0.25 s), tuning, best shift onto
   A dorian / A aeolian.
3. `python3 -I cut.py all.json wav out [--render]` — splits long phrases at the end of long notes (≤ 4 bars at 124 BPM),
   keeps calm ones, drops the hand-picked `DROP` set; `--render` writes FLACs (varispeed into A, −20 dBFS RMS) and
   `phrases.json`. Column / source table: `SRC` in cut.py.
4. Checks: `decode-page.py <url list> <page.html>` + `chrome-decode.mjs <page url>` (headless Chrome for Testing from
   ~/Library/Caches/ms-playwright, started with `--remote-debugging-port=9333`; serve the page with
   `python3 -m http.server --bind 127.0.0.1`). `level-render.mjs` = offline loudness of one board column (copy into
   tools/strudel-sim/ to run; args: board file, column, phrase, progression; env BOARD, BARS, K3).
