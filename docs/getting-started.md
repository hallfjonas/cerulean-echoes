# Getting started

This page takes you from a fresh checkout to music in about five minutes. You do not need a controller for the first
play.

## What you need

- A Mac with Node.js and Chrome. The player uses Web MIDI, which Chrome has.
- Optional: one or two Novation Launch Control XL 3 (the faders and knobs) and a Novation Launchkey MK4 25 (keys and
  drum pads). See [controllers](features/controllers.md).
- Headphones or speakers.

## First play

1. Install the tools once:
   ```bash
   cd tools && npm install
   ```
2. Start the player:
   ```bash
   cd tools && node trajectory/server.mjs
   ```
3. Open http://localhost:8766 in Chrome.
4. Pick a track in the list at the top. **Live** holds the live tracks (007 to 010).
5. Press **Play**.
6. Raise the master fader. Nothing sounds until it is up: the live tracks start with everything quiet on purpose.
   - With a controller: move the fader in the last column (column 8, the global column).
   - Without a controller: pick a script in the Auto-perform section of the sidebar and press **Start**
     (key **P**). The script moves the controls for you. See [auto-perform](features/auto-perform.md).
7. Move a fader in another column to bring that part in, then turn its knobs.

If Chrome does not answer with MIDI within 2 seconds, the status line says "No MIDI" and the track plays with the
virtual controller only. That is fine for a first try.

## What next

- [Player](features/player.md): the sidebar, the picture, the settings.
- [Live tracks](features/live-tracks.md): what each row and column does.
- [Controllers](features/controllers.md): connecting and loading the layouts.
- All pages: [features/README.md](features/README.md). Words you do not know: [glossary](reference/glossary.md).
