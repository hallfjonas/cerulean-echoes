# Tech stack

```
Novation (2× Launch Control XL 3, 1× Launchkey MK4 25)
  → USB-MIDI → macOS
  → Strudel (strudel.cc, browser, Web MIDI)
  → Focusrite Scarlett 2i2 (4th Gen)
  → 2× Kali Audio LP-6 V2
```

## Recording a session

Scarlett 2i2 4th Gen has built-in **Loopback**: the computer's playback comes back as inputs 3/4, so Strudel is recorded
digitally, without a cable or extra software.

| Input | Source |
|---|---|
| 1 | Microphone (XLR; enable 48V only for a condenser mic) — room, voices |
| 3/4 | Loopback = Strudel, stereo, clean |

1. Focusrite Control 2: enable Loopback.
2. GarageBand: Open or copy tempate /Users/jonas.hall/Documents/GitHub/cerulean-echoes/recordings/2026-11-14-beats-und-basteln/001.band
3. Track A: input 1 (mono, mic). Track B: input 3+4 (stereo, Strudel). Arm both, record.
4. Close other apps or mute system sounds: Loopback records everything the Mac plays.

Both tracks share one clock and stay in sync; mix the mic under the Strudel signal afterwards.
