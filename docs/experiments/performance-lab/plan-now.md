# Plan: now

Build the Tracks lab for performances, without Launchkey support and without LLM help. One branch and one PR (this
one, #138, leaves draft when the work is done), built in the order below, one commit per step. Everything not listed
under "In" is in [plan-later.md](plan-later.md).

The prototype (`tools/trajectory/perform-lab-prototype.html`) is the UI reference. It is deleted in the last step; its
decisions are in the [design notes](README.md).

## Scope

**In** (prototype, core, shell, save, import, play):
- A Labs sub-tab **Tracks** with track and performance dropdowns, expected length (bars and minutes), tempo as a
  what-if, and the five levels Story, Sections, Moves, Lanes, Steps.
- Moves for the Launch Control XL 3 only: Enter, Layers, Leave, Build, Fog dip, Move control, Break, Press, Hand-made.
- Compile moves and hand edits to script v2, check, save as a new file, import the 15 existing scripts, play from a bar.

**Out** (see later): integrated LLM support (words to adjust operations, drafting from the story text), writing the
tempo to the track, stem editing, Launchkey support (keys, pads, knobs and mod wheel as moves, lanes and pickers),
arc presets and section recipes, feedback rounds, design `.md` export.

**Launchkey steps in existing scripts stay safe.** An imported script that has `keys`, `pad` or `lk` steps keeps them
as Hand-made moves: shown at the Steps and Lanes levels, movable and deletable as raw steps, never dropped or
rewritten. The lab does not offer to create them.

## Steps

Files follow the stem lab: a server module with a `handle` function, a UI module, a pure module, tests next to them.
`autoperform.mjs` already exports a `compile` for scripts, so the lab's function is named `compileMoves`.

1. **Core** (`tools/trajectory/perform-lab-core.mjs`, pure, no DOM, no fs). Move catalogue with parameters, `compileMoves`
   (moves plus `edits` overrides to steps), `spanOf`, section helpers, `checkLab` that calls the `check-perform`
   checks on the compiled script and adds the lab's own warnings (a section without moves, too many moves at once).
   Tests (`perform-lab-core.test.mjs`): every move compiles to steps `check-perform` accepts; an edit by step index
   survives a parameter change; deleted steps stay deleted; bars use the script's 0-based, half-open convention.
2. **Shell and routes** (`perform-lab.mjs`, `pages.mjs`, `server.mjs`, `player.html`). Add `{ id: 'tracks', label:
   'Tracks' }` to the Labs subs and its sidebar sections (`data-pages="labs/tracks"`). Read-only routes under
   `/lab/tracks/`: tracks with performances (from `perform/<track>/*.json`, with meta), the track's controls
   (`controlsOf` / `tagSource`) and its bpm (the `tempo` of the `.track` file, which the engine reads). Opens the
   existing steps at the Steps level. Test: the routes list every performance of every track and a control table for
   two stem tracks (every track is a `.track`; there is no `.scd` track left).
3. **Levels UI** (`perform-lab-ui.mjs`, styles in `ui.css`). Port the five levels from the prototype with the same
   interactions: selection that survives a level change, drag for moves, section edges and lane dots, undo, zoom, keys
   1-5. Tempo changes the displayed length only. Unit-test the pure parts (ruler marks, snap, lane paths); the rest is
   checked by looking at it in the player.
4. **Save** (`perform-lab.mjs`). `POST /lab/tracks/save` writes `perform/<track>/<name>.json` and
   `<name>.lab.json`, runs the check and returns its errors; the footer shows them and Save is blocked on errors.
   An existing script is never overwritten: "Save as" asks for a new name, and a file whose sidecar exists can be
   saved over by the lab itself. Tests: new file written, existing file refused, errors returned, the written `.json`
   passes `node trajectory/check-perform.mjs`.
5. **Import** (core, `importScript`). Group the Launch Control steps of a script into moves: a ramp on a Level
   control is Enter or Leave, a staggered run of them is Layers, a ramp up and a jump to 0 is Build, up and down on
   Fog is Fog dip, two presses on Break are a Break, one press is Press, other cc steps are Move control; everything
   else, Launchkey steps included, is Hand-made. Sections, title, mood and bars come from the script's meta; a script
   without sections (the `every-button` scripts, `spike-run`) gets one section over its whole length, and a missing
   `bars` is the end of its last step. A take saved as a copy drops its `take` meta and becomes a hand-written script.
   **Rule that decides done:** for every script in `perform/`, `compileMoves(importScript(script))` gives back the
   original steps, compared after a stable sort by bar (two scripts are not in bar order; steps on one control at one
   bar keep their order, the last one wins). Test (`perform-lab-core.test.mjs`) runs it over all committed scripts,
   so opening a script cannot change it; takes are gitignored, so they are included only where present locally and
   only those `check-perform` accepts.
6. **Play** (`perform-lab-ui.mjs`, `autoperform.mjs`, `sc-auto.mjs`, `sc-link.mjs`, `sc/engine.scd`). Play and Stop
   in the lab sidebar use the existing auto-perform path. The page fetches a script and plays it itself
   (`createPerformer`), so the player's start splits into fetch and play and the lab hands over its in-memory script:
   unsaved edits can be heard, no new server route. New: start at bar N or at a section, and click a section or the
   ruler to jump while playing.
   - Start at N: controls get their value at N (the last value per control, a ramp read at N). Buttons step through
     states one press at a time, so their state at N is the number of presses before N: `/ce/load` gains
     `press <cc> <count>`, applied before the first note, beside the `cc` and `lk` values it carries today. Keys and
     pads before N are skipped. Then the clock starts at N.
   - N snaps: a ruler click goes down to the 4-bar line (Chapter switches on 4-bar phrases counted from the load), a
     section click starts at the section's first bar.
   - A jump while playing is a reload at N, forward and back (a short gap; every load costs the sound server memory).
   - A recording or take of an unsaved lab script names it `lab:<name>` as its `script`.

   Test: `autoperform` and `sc-auto` tests for the start offset and the press counts; `sc-link` test for the load
   message. **A listen in the player on 009 and 010 decides this step**; the agent cannot hear.
7. **Docs and clean-up.** `docs/features/tracks-lab.md`, the help text, `docs/features/auto-perform.md` (play from a
   bar), `tools/trajectory/README.md`, CLAUDE.md layout line. Delete the prototype. Move anything still useful
   from this folder into `docs/features/tracks-lab.md`; keep `plan-later.md` as the roadmap.

## Done when

- `cd tools && npm test` and `npm run verify-sc` pass, `npm run path-lint` shows no new missing paths.
- Every script in `perform/` opens, shows sections and moves, and saves as a copy that `check-perform` accepts.
- A new performance can be drawn from scratch (sections, moves, tempo what-if), saved, and played in the player from
  a chosen bar, with the user's listen on 009 and 010.

## Risks

- **Importer ambiguity.** Several readings of a ramp are plausible; the round-trip rule makes a wrong guess harmless
  (it only changes how a step is grouped, not what plays). Keep the recogniser small and let Hand-made catch the rest.
- **Play from a bar** touches the performer that works today (the user approved it by listening). Add the offset as a
  new path and leave the start-at-0 path as it is (a load without presses sends what it sends today); compare 009
  start-at-0 before and after with `check-replay`.
- **Size of `player.html`.** The lab gets its own modules and only a section and a script tag in the page.
- **Sidecar drift.** If a script is edited outside the lab, its sidecar no longer matches: store a hash of the `.json`
  in the sidecar and re-import (with a note) when it differs.
