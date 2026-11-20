# Samples

- `tr909/bd-01.wav` — Roland TR-909 bass drum, from [ritchse/tidal-drum-machines](https://github.com/ritchse/tidal-drum-machines)
  (`machines/RolandTR909/rolandtr909-bd/Bassdrum-01.wav`), the same file Strudel plays for `s("bd").bank("RolandTR909")`.
- `ir/orbit-0.6.wav`, `ir/orbit-1.2.wav` — impulse responses of Strudel's orbit reverb (superdough, room size 0.6 and 1.2),
  measured with `tools/sc-port/reverb-ir.mjs`. superdough generates noise for its reverb, so every browser session has a
  slightly different one; these are one such reverb, measured including the browser's normalisation.
- `tr909/*`, `tr727/*`, `tr808/*`, `tr707/*` — further drum-machine one-shots from the same collection
  (tidal-drum-machines, via strudel.cc's `felixroos/dough-samples` map), each the file Strudel plays for that sound
  and number (`cp-00` = `RolandTR909_cp` n 0, …). Used by the drum stems and the Launchkey pads.
- `ir/orbit-2.0.wav` (+ `-44100`) — the same measurement for room size 2 (Jonas' lab columns, orbit 3; keys orbit 4).
- `noise/` — superdough's noise buffers (pink, white, brown), as `tools/sc-port/noise-buffers.py` writes them.
- `jrhodes/` — jRhodes3d (Rhodes Mark I), the keys' Rhodes as the Strudel track loads it.
- `vibraphone/` (FLAC, lossless) — VCSL vibraphone, hard mallets ([sgossner/VCSL](https://github.com/sgossner/VCSL), CC0): strudel.cc's
  built-in `vibraphone`, the files of its sample map.
- `sso/` (FLAC, lossless from the WAV files) — Sonatina Symphonic Orchestra ([peastman/sso](https://github.com/peastman/sso), CC Sampling Plus 1.0):
  trumpets, horns, trombones (brass), violins, violas, celli (strings) — the files the Strudel track loads.
- `vsco/` (FLAC, lossless) — VSCO 2 Community Edition string sections, spiccato ([sgossner/VSCO-2-CE](https://github.com/sgossner/VSCO-2-CE), CC0).
- `strat/` — Stratocaster single notes ([nyanshell/nyanshell.strat](https://github.com/nyanshell/nyanshell.strat), MIT),
  cut to the first 1.5 s and stored as FLAC (the guitar plays short notes; the track compensates the start offset).
- `gm/<preset>/` — General MIDI soundfont zones as strudel.cc plays its `gm_*` sounds (WebAudioFont presets,
  [felixroos/webaudiofontdata](https://github.com/felixroos/webaudiofontdata)), decoded with
  `tools/sc-port/soundfont-extract.py` (zones.json = the zone data: key range, pitch, loop points).
- `voice/brace.wav`, `voice/lw.wav` — the repository's own spoken samples (`samples/voice/*.m4a`), decoded to WAV
  (SuperCollider cannot read m4a). Browsers drop the AAC encoder delay when decoding; so does this decode.
- Files with `repo:` in the track (keys piano, flute phrases) are read from the repository's own `samples/` folder.
- `ir/orbit-1.6.wav`, `ir/orbit-2.6.wav`, `ir/orbit-4.wav` (+ `-44100`) — the same measurement for room sizes 1.6, 2.6
  and 4 (track 008: orbit 1 drums and bass, orbit 3 rumble, orbit 2 Jonas' colour).
- `tr808/sh-00.wav`, `tr909/ht-00.wav`, `sergemodular/perc-00.wav`, `emumodular/perc-00.wav`,
  `viscospacedrum/misc-00.wav` — more tidal-drum-machines one-shots (n 0 of `RolandTR808_sh`, `RolandTR909_ht`,
  `SergeModular_perc`, `EmuModular_perc`, `ViscoSpaceDrum_misc`): track 008's Launchkey pads.
- `dirt/metal-00.wav`, `dirt/space-00.wav`, `dirt/wind-00.wav` — from [tidalcycles/Dirt-Samples](https://github.com/tidalcycles/Dirt-Samples)
  (`metal/000_0.wav`, `space/000_0.wav`, `wind/000_wind1.wav`), strudel.cc's default sample pack (n 0 of `metal`,
  `space`, `wind`): track 008's Launchkey pads.
- `ir/orbit-6.wav`, `ir/orbit-6.5.wav` (+ `-44100`) — the same measurement for room sizes 6 and 6.5 (track 007: orbit 2
  and orbit 1).
- `vcsl/` (FLAC, lossless from the WAV files) — VCSL ([sgossner/VCSL](https://github.com/sgossner/VCSL), CC0), the files
  of strudel.cc's sample maps that track 007 plays: `vibraphone_bowed`, `xylophone_soft_ff`, `glockenspiel` (one file
  per key), `shaker_small` (12), `cabasa` (2), `tom2_mallet` (n 0), `agogo` (n 1).
- `voice/david.flac`, `voice/in_the_vast.flac`, `voice/piece_of_paper.flac`, `voice/plaenterwald_wine_and_cheese.flac`,
  `voice/the_creatures_have_begun_illumination.flac`, `voice/the_evening_does_not_end.flac`,
  `voice/the_evening_progresses.flac` — the repository's own spoken recordings (`samples/voice/*.mp3`), decoded to FLAC
  (44.1 kHz mono) with ffmpeg: track 007 (Jonas 7 = David, the Launchkey pads = the others).
- `gm/0090_JCLive_sf2_file/` (gm_glockenspiel), `gm/0520_Aspirin_sf2_file/` (gm_choir_aahs) — track 007's Launchkey pads.
- `voice/plaenterwald.flac` — the repository's own `samples/voice/plaenterwald.mp3`, decoded (track 008's pads).
- `tr727/perc-00.wav`, `tr727/perc-01.wav` — TR-727 agogo high / low (tidal-drum-machines, `RolandTR727_perc` n 0 / 1):
  track 010's congas.
- `ir/orbit-5.wav` (+ `-44100`) — the orbit reverb measurement for room size 5 (track 010, orbit 2).
