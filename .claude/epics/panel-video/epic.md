---
name: panel-video
status: in-progress
created: 2026-11-20T18:48:28Z
updated: 2026-11-20T19:30:00Z
progress: 0%
prd: (none, scoped from the request "record the MIDI panel in parallel with the audio recording, toggle, export as video")
github: (not synced; issue sync is off, see CONTRIBUTING.md)
---

# Epic: panel-video

## Overview

Record (key R, or auto-perform with Record audio) writes the master output as a WAV to `recordings/<track>/`. This
epic adds a toggle, **Record video**. With it on, the player also films the MIDI panel (the track's LC view, or the SC
panel with the spectrum and the set view) while the audio records, and exports one **MP4** (panel picture plus the
recorded sound) next to the WAV. The result shows what the hands did and what it sounded like, for sharing and for
reviewing a set.

Based on `ui/sc-themes` (the SC MIDI panel, PR 63): the panel to film is the one that branch builds.

### Where it stands today (what the code does)

- `recorder.mjs` taps `engine.output()` with an `AudioWorklet`, streams 1 s chunks to `recording.mjs`, which writes
  `<name>.wav` and `<name>.json` (sidecar). Human recording: Record to Stop. Auto-perform: Start to script end plus 4 s.
- The player shows the panel in an iframe: `#lcPanel` (Strudel, the track draws its own view) or `#scPanel`
  (`sc/ui/index.html`, DOM plus two canvases). Visualization is a canvas of its own; the views share the page.
- Recording SC tracks is refused today (`player.html`: "recording SuperCollider tracks is not built yet"); the
  `sc-migration` task 005 makes SC write the WAV itself (`DiskOut`, `/ce/record`).
- `ffmpeg` is installed on the machine. Nothing records video; the README lists "video export" as postponed.

## Architecture Decisions

- **Live capture of the panel, not a re-render.** The page films its own panel: `getDisplayMedia({ preferCurrentTab })`
  cropped to the visible panel iframe with Region Capture (`CropTarget.fromElement`), recorded with `MediaRecorder`.
  What the player sees is what the file shows, for both engines, without teaching the panels a playback mode.
  The alternative (log the panel state, re-render offline in a headless browser) is the fallback if the spike shows
  the live capture costs dropouts or cannot be aligned with the sound. It is task 007, only then.
- **Video rides on the audio recording.** No video-only recording. The audio file is the clock and the source of the
  sound in the MP4; the WAV stays as it is (lossless, analysis tools read it).
- **The toggle is armed before Record.** Ticking it is the user gesture that opens Chrome's share prompt (pick "this
  tab"); the stream is held until the toggle is cleared, so Record and auto-perform start without a dialog.
- **Panel only, view locked.** The video shows the MIDI panel. While video recording runs, the page stays on the MIDI
  panel view (a hidden iframe would film nothing). Visualization is not part of this epic.
- **Server muxes.** The page uploads video chunks next to the audio chunks; on finish the server runs `ffmpeg`
  (video copy or x264, audio AAC from the WAV, offset from the sidecar) and writes `<name>.mp4`. Raw capture is deleted
  after a successful mux. `ffmpeg` missing or failing keeps the raw capture and reports it; the WAV is never touched.
- **Names and guards unchanged.** Same folder, same name, same 2 GB free-space guard, `fromOwnPage` only; the page
  never names a file. `recordings/` stays outside git.
- **One heavy job at a time.** The mux runs niced after Stop, not while the capture runs.

## Technical Approach

### Page (`panel-video.mjs`, new)
- `createPanelVideo({ panel })`: `arm()` (share prompt, crop target, keeps the stream), `disarm()`, `start(name)`,
  `stop()`. `MediaRecorder` with a timeslice of 1 s, chunks posted to the server in order, like `recorder.mjs`.
- Codec: `video/mp4;codecs=avc1` if the browser offers it (no re-encode on the server), else WebM VP9; chosen in the
  spike. 30 fps, bitrate constant in the module, size follows the iframe, even width and height, capped at 1920 wide.
- Sync marks: the page notes, in one clock, when the audio started (the recorder's first chunk, mapped through
  `getOutputTimestamp()`) and when the first video chunk began. The difference goes in the sidecar as `offsetSeconds`.
- Ends on: Stop, track change, the user's "Stop sharing" (the recording continues as audio only and says so),
  `pagehide` (like the audio recorder).

### Server (`recording.mjs`)
- `PUT /recording/<track>/<name>/video` appends a chunk; `POST …/finish` accepts `video: { offsetSeconds, mime }`, runs
  the mux, returns the sidecar with `video: { file, width, height, fps, seconds, offsetSeconds }`.
- Sidecar fields are additive; old sidecars read as before.

### UI (`player.html`)
- A "Record video" checkbox next to Record (also covers auto-perform "Record audio": one toggle for both), saved with
  the other settings (`settings.mjs`), shown red with the recording state, "encoding video …" until the MP4 exists.
- While it records: the view cannot leave the MIDI panel (the Visualization link says why).

### SC path
- The SC recording (`sc-migration` 005) starts and ends the WAV over OSC. Its start is acknowledged with a time stamp;
  the video offset is measured against that acknowledgement instead of the browser's worklet.

## Implementation Strategy

1. Spike first (001): three things decide the design: does tab capture cropped to an iframe work in the user's Chrome,
   what does it cost on a dense track (008) beside the audio recorder, and how far off are picture and sound.
2. Server (002) and page (003) are independent after 001.
3. UI (004) needs both. SC (005) needs `sc-migration` 005 and 004.
4. Tests and docs (006) last. Task 007 (offline render) exists only if 001 fails its gate.

## Task Breakdown Preview

1. **Spike** — crop to iframe, codec choice, CPU/dropout cost on 008 and 010, offset between flash and click; findings
   into this epic. Gate: pass, or switch to task 007. (first)
2. **Video upload and mux (server)** — endpoints, ffmpeg job, sidecar fields, raw capture cleanup, `check-recording`.
   (after 1; parallel with 3)
3. **Panel capture (page)** — `panel-video.mjs`: arm, crop, record, chunks, sync marks, end cases. (after 1;
   parallel with 2)
4. **Record video toggle** — checkbox, setting, human and auto-perform paths (tail included), view lock, status text.
   (after 2 and 3)
5. **SC tracks** — same toggle with the SC recording, offset against the OSC acknowledgement. (after 4 and
   `sc-migration` 005)
6. **Tests and docs** — feature tests, README "Recording video", CLAUDE.md player paragraph, Help panel text. (after 5)
7. **Offline render (fallback)** — log panel state during Record, render with a headless browser and ffmpeg after Stop.
   Only if the spike fails. (after 1)

## Dependencies

- Internal: `recorder.mjs`, `recording.mjs`, the player's Record code, `settings.mjs`, the panels (`sc/ui/index.html`,
  the Strudel LC view).
- `ui/sc-themes` (PR 63): the panel's final look and size behaviour; merge or rebase before 004.
- `sc-migration` 005 (Recording in SC): needed for SC tracks only (task 5).
- Tool: `ffmpeg` on the PATH (present). No new npm package.

## Risks

- **CPU on the M2 Air (16 GB, shared).** Tab capture and encoding beside SC, the audio worklet and a dense track can
  cause dropouts. Mitigation: spike measures it; hardware H.264 in the MediaRecorder; 30 fps cap; mux after Stop.
- **Sync drift.** Browser video clock and audio clock differ; SC adds its own start latency. Mitigation: one offset in
  the sidecar, measured in the spike with a flash-and-click test; the gate is within two frames (about 70 ms).
- **Chrome only.** Region Capture needs Chrome (the user's player browser). Other browsers get the toggle disabled.
- **Share prompt.** One prompt per page load; a closed share ends the video, not the audio.
- **Panel size changes mid-recording** (window resized). Mitigation: the mux scales to the first frame size and pads.
- **Tab in the background.** A hidden tab stops painting; the video freezes. Mitigation: a warning while recording.
- **Disk.** A 10 min MP4 at 1080p 30 fps is about 200 MB. Same guard as the audio; sizes shown after Stop.

## Open Questions

1. Live capture (this plan) or offline render (task 007) as the main path? Offline is exact in sync and costs nothing
   live, but needs a panel playback mode, a state log and a headless browser.
2. Should the video follow the view (also film Visualization), or is the MIDI panel enough? Plan: panel only.
3. Fixed output size (1920×1080) or follow the window? Plan: follow the window, even dims, 1920 wide at most.
4. Keep the raw capture after the mux? Plan: delete on success.
5. Skip the share prompt: document Chrome's `--auto-select-tab-capture-source-by-title`, or leave the prompt?

## Success Criteria (Technical)

- With Record video on, a human recording of 3 minutes on a Strudel track gives `<name>.wav`, `<name>.json` and
  `<name>.mp4`; the MP4 shows the panel (controls moving) with the sound, plays in a normal player.
- Same with an auto-perform run, ending 4 s after the script's last bar.
- Same on an SC track once `sc-migration` 005 is merged.
- Picture and sound differ by at most two frames in the flash-and-click test.
- No dropout caused by video capture on 008 and 010 on the M2 Air (the spike records the numbers).
- Toggle off: byte-identical behaviour to today; `npm test` and `npm run verify` stay green.
- Closing the share prompt or "Stop sharing" leaves a valid WAV and a sidecar that says the video ended early.

## Estimated Effort

6 tasks (a seventh only on spike failure), about 2-3 working sessions. Critical path: 1 → 2 and 3 → 4 → 5 → 6.
The spike decides the schedule risk (cost and sync of live capture).

## Spike findings (task 001, 2026-11-20, partial)

Throwaway Chrome 157 (own profile, flags `--auto-accept-this-tab-capture`), driven over CDP; harness was not kept.

- **Crop works.** `CropTarget.fromElement(iframe)` + `cropTo` films only the panel iframe, about 30 fps. Output size is not controllable (1280×720 or 2560×1440 for a 640×360 iframe at DPR 2), so the mux must scale to even dims.
- **Codec.** `video/mp4;codecs=avc1` and WebM VP9 are both supported. The MP4 stream decodes with one warning at the first frame (`left block unavailable`); re-encoding with x264 `veryfast` is fast (8 s clip in 0.25 s) and removes it. Plan: re-encode, not copy.
- **Sync.** Panel events show up in the video 57-103 ms after the page's own clock (MP4: mean 84, sd 15; VP9: mean 65, sd 19). The audio mark (worklet start mapped through `getOutputTimestamp`) was accurate to about 15 ms. Gate: pass with a constant video advance of about 75 ms in the mux, leaving about ±30 ms (one frame). Not yet tested under load.
- **Cost, 008 Strudel with auto-perform:** Chrome total CPU about 50% (audio recorder included) rises to about 67% with video capture, one run of 20 s per phase. `playoutStats` is not available, so dropouts were not measured, and the WAV check was not done.
- **Not done:** 010 and an SC track (016 or 008 SC panel), underrun or dropout check, flash-and-click under load. Task 001 stays open for these; the gate leans to PASS (live capture, tasks 002-006; task 007 not needed).
