# Getting started

This page takes you from a fresh checkout to music in about five minutes. You do not need a controller for the first
play.

## What you need

- A Mac with Node.js and Chrome. The player uses Web MIDI, which Chrome has.
- Optional: one or two Novation Launch Control XL 3 (the faders and knobs) and a Novation Launchkey MK4 25 (keys and
  drum pads). See [controllers](features/controllers.md).
- Headphones or speakers.

## Start with one double-click (no Terminal)

1. Install once: [SuperCollider](https://supercollider.github.io/downloads) (drag it into Applications) and
   [Node.js](https://nodejs.org) (the LTS version). Chrome (or another Chrome-based browser such as Brave) as your
   default browser is best: Safari has no Web MIDI.
2. Get the repo: `git clone` it (a ZIP download from GitHub is blocked by macOS as an app "from the internet"; then
   right-click the app and pick **Open** once).
3. Double-click **Cerulean Echoes.app** in the repo folder. The player opens in the browser; SuperCollider starts
   when you press **Play** on a track. The first start installs the player's helpers once (1-2 minutes, a message
   says so).

To stop everything (the player and SuperCollider): quit **Cerulean Echoes** (its Dock icon: Quit, or Cmd-Q).
Double-click it again while it runs to open the player once more or to stop it.
Keep only **one** browser tab of the player open: each tab holds two open connections and Chrome allows six per
address, so several tabs make the page hang. If something does not start, a message says what is missing; details
are in `~/Library/Logs/cerulean-echoes.log`.

## First play (Terminal)

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
