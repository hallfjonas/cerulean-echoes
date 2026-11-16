# Workflow review: Claude Code sessions since 2026-11-10

Review of 33 main sessions (2026-11-10 → 2026-11-15) and 7 subagent transcripts of this project, to find recurring
friction and repeated manual work and to propose skill, agent, hook, rule and memory changes. Nothing below is built
yet: the user picks proposals in the selection checklist at the end.

## Method
1. `tools/session-digest/digest.mjs` turns every transcript into a compact digest (user messages with a correction
   flag, per-turn tool sequence, errors, hook output, skills and subagents, handover files, repeated tool sequences,
   edit reverts, subagent summaries). Output in `tools/session-digest/out/` is git-ignored because it holds private
   chat content. Rerun: `cd tools && node session-digest/digest.mjs [--since YYYY-MM-DD] [--only <id>]`.
2. Two subagents read the digests in two batches (Nov 10–12: 18 sessions, Nov 14–15: 15 sessions; none on Nov 13)
   and wrote findings in a fixed schema (theme, sessions, frequency, evidence, friction, suggested fix, coverage).
3. Findings were merged into themes, compared with the current tooling, and turned into ranked proposals.

Session ids are the first 8 characters of the transcript id; `T<n>` is the turn. Quotes are short English
paraphrases. Excluded as off-topic: 72c061d5 and 902a4537 (a task from another repository), b672f615 (only
`/clear`). 5b235b95 is an early copy of f184e8f7 and is counted once.

## Current tooling (inventory)
| Item | What it covers | Used in the 33 sessions |
|---|---|---|
| Skill `lab-board` | New board round: candidate columns, layout sheet, `feedback.md`, rotation | 0 invocations (2441fdae built a board by hand) |
| Skill `lab-to-track` | Move a lab column 1:1 into a track | 0 |
| Skill `lcxl-layout` | Layout sheet and `.syx` from `@ctl` tags; manual `npm run watch/layouts/syx` | 0 (regeneration done by hand in ≥9 sessions) |
| Skill `strudel-mix` | Per-stem loudness, fader ranges | 0 (≥9 sessions with level complaints) |
| Skill `strudel-optimize` | CPU gating, event-by-event proof | 0 (equivalence compares done by hand in 6 sessions) |
| PostToolUse hook `tools/lcxl-layout/hook.mjs` (Edit\|Write\|MultiEdit) | Layout PDF, `.syx`, single from dual, tapped copy, offline sound check | Fires only on Edit/Write; most track edits were Bash `python3 -`/`sed -i` (67 script edits in 6 sessions); silent on success; once found not registered at all (f184e8f7 T11) |
| `CLAUDE.md` | Labels, layout, rules, live tracks, set, CC map, CPU, sounds, layout sheets, machine | Read every session; no git/PR rules, no tool cheat sheet, no user vocabulary |
| Memory `one-file-any-controllers` | One file per live track, all controllers optional | Outdated: still says old files live in each track's `old/` (CLAUDE.md: no `old/` folders) |
| Memory `open-in-chrome` | Open pages in the user's Chrome | Followed after it was written (11e69acc) |
| User-level `ccpm` skill | PRD → epic → tasks | 6 invocations on Nov 15 (not project tooling) |

Subagents: 7 in total (5 translation agents in 871a0100, 2 web-fetch in f184e8f7). No project agents exist.

## Themes
Ranked by number of sessions affected.

### 1. Track edits bypass the hook, so generated files go stale (13 sessions)
- Sessions: 2b8c6298 (T5, T6, T10), e950b439 (T3), 2f14813b (T3), cd069e22 (T3), 2441fdae (T3, T4, T7, T11),
  11e69acc (T2, T3), 234acb00 (T1), 02c83e9d (T1, T2), 29da5b29 (T1–T3), f184e8f7 (T1–T16), 135b115f (T1–T3),
  29ba6711 (T2), 7e0555ac (T1)
- Evidence: 11e69acc T2 searches for the hook command, reads `hook.mjs`, then runs it by hand; 2b8c6298 T6 pipes fake
  hook JSON into it; f184e8f7 T10 user: "we play the tapped versions, I see no change yet"; 135b115f T2 user asks
  whether the tapped tracks are updated (they were not); f184e8f7 T11: the hook was not registered on this machine.
- Friction: 3–5 extra calls per session to rediscover the hook; stale layout sheets, `.syx` and tapped copies reach
  rehearsal; the offline sound check never runs on script edits.
- Coverage: outdated. The hook exists but matches only the edit tools Claude rarely uses for tracks.

### 2. Checks are reinvented by hand instead of using skills and tools (12 sessions)
- Sessions: 234acb00 (T1), e950b439 (T1, T3), 2f14813b (T3), cd069e22 (T3), 2441fdae (T3, T4, T11), 892246f0 (T3),
  3f2839f6 (T1), 576e367d (T1), 11e69acc (T2, T3), 02c83e9d (T1, T2), 29da5b29 (T1–T3), f184e8f7 (T1, T5, T12–T14)
- Evidence: calls like "Look up strudel-sim usage" (892246f0), "Inspect sim harness API" (2f14813b), "Read measure
  tool internals" (cd069e22); turns end with ad-hoc chains transpile-check → compare → check-sounds → measure →
  make-tapped; throwaway files (`.once-test.mjs`, `_dec.mjs`, `zz-lk-test.html`) left in `tools/`.
- Friction: 2–5 lookup calls per session plus 5–10 calls per feedback round; forgotten steps; results not comparable
  across sessions. Zero project-skill invocations in 33 sessions.
- Coverage: unused (skills exist but their descriptions never trigger) and gap (no single verify command).

### 3. Controller and view behaviour is not testable offline (11 sessions)
- Sessions: 2b8c6298 (T4, T5, T6, T10), e950b439 (T2, T3), 2f14813b (T3), cd069e22 (T3), 2441fdae (T3, T9),
  11e69acc (T3), 234acb00 (T1), 1f719521 (T2), 721b54c8 (T2), f184e8f7 (T4, T12–T14), 135b115f (T1)
- Evidence: one-off scenario scripts `_lk-test.mjs`, `_two-lc.mjs`, `_lk-master.mjs`, `tension-check.mjs`,
  `lk-smoke.mjs`; f184e8f7 T4 user: still cannot see the sample names; 135b115f: pad highlighting still broken;
  e950b439 T2: Fog sounded different because a neighbouring knob was repurposed; f184e8f7 T13: knob-target toggle
  reverted after it broke the pads.
- Friction: the same scaffolding (stub `midin`/`midikeys`, set CCs, press buttons, hit pads, two LCs) is rewritten
  and deleted each time; regressions and side effects are found by the user at rehearsal.
- Coverage: gap. `harness.mjs` has the primitives, but there is no CLI and nothing checks the LC view.

### 4. Git, PR and parallel-session logistics (14 sessions)
- Sessions: 5af8579c (T1), 3f2839f6 (T2, T3), 576e367d (T1, T2), 721b54c8 (T1–T7), 11e69acc (T1, T2, T4, T8, T10),
  1f719521 (T2, T3), af56f83f (T16), 2b8c6298 (T10), 892246f0 (T2), 2441fdae (T12, T13), 2f14813b/cd069e22 (same
  feature built twice), f184e8f7 (T5–T7, T15), d086ed6d (T1), 02c83e9d (T1)
- Evidence: 5af8579c force-resets remote main after a direct push; 11e69acc T10 is only "conflict in PR" (README
  between two PRs); conflicts on generated PDFs; 721b54c8 finds PR #15 superseded; 1f719521 rewrites commits to drop a
  108 MB wav; the density/tension build-up was built twice 50 minutes apart (2f14813b, cd069e22); f184e8f7 T5: a stash
  pop during Claude's edit left conflict markers in four tracks.
- Friction: about a third of the turns in the first batch are git logistics; duplicated and lost work; repo growth.
- Coverage: gap. `CLAUDE.md` has no git, PR or binary-file rules.

### 5. Levels and audibility are left to the user's ears (9 sessions)
- Sessions: 2b8c6298 (T4), 11e69acc (T4, T6), 2441fdae (T11), 3f2839f6 (T1), 892246f0 (T3), 02c83e9d (T2),
  29da5b29 (T3), f184e8f7 (T1, T3, T9), 135b115f (T1)
- Evidence: 2b8c6298 T4: no keys audible with knobs at 0; 11e69acc T4: Launchkey level "guessed, not measured";
  f184e8f7 T1: voice, shaker and rim must be louder, T3: keys too quiet; 02c83e9d T2: marimbas too quiet.
- Friction: one round trip per complaint; ad-hoc meters (`pad-levels.mjs`, patched `render.mjs`); three gain
  iterations in f184e8f7 T9.
- Coverage: unused. `strudel-mix` covers stems but not pads, keys or voice samples, and was never invoked.

### 6. Adding and loading samples (6 sessions)
- Sessions: 892246f0 (T1–T3), 3f2839f6 (T1, T2), 721b54c8 (T1), f184e8f7 (T8, T14–T17), 02c83e9d (T1, T2),
  135b115f (T1), 7e0555ac (T1)
- Evidence: "put this sample on drum E1" (892246f0); f184e8f7 T14 user: shakers broken, "we've had this issue
  before"; T16: new samples stay silent until pushed to main; 02c83e9d probes CDN URLs by hand.
- Friction: each time Claude re-finds `LK_SHOTS`, the pad-note map and the samples call; two extra push turns;
  a 55-call turn to find a comma in a VCSL path.
- Coverage: partly covered since f184e8f7 T14 (`samples/sounds.json`, `check-sounds.mjs`, `mirror-sound.mjs`); gap
  for the add-a-sample steps and for "file not on origin/main yet".

### 7. Stale or missing reference facts (13 sessions)
- Sessions: paths: 135b115f, 29da5b29, 02c83e9d, 29ba6711 (T1, T2), 7e0555ac, 14cfb5a5 (T3), 871a0100; device facts:
  135b115f (T1), f184e8f7 (T12), 02c83e9d (T2), 111e7944 (T1), 2f14813b (T3), 695d5970 (T5, T9); user vocabulary:
  e950b439 (T1, T3), 2f14813b (T1), cd069e22 (T2)
- Evidence: `ls: tracks/008: No such file` after the genre restructure; skills and epics citing removed folders;
  Launchkey knobs documented as CC 21–28 but sending 31–38; button CCs unknown; "endless encoder" assumption wrong;
  the user says "Density" for Tension and "build-up button" for Chapter, and every session re-derives it.
- Friction: failed calls, a whole session (7e0555ac) of reference cleanup, features built on guessed CCs.
- Coverage: outdated (devices doc, memory) and gap (no path check, no alias list).

### 8. One block patched by hand in four tracks (4 sessions)
- Sessions: 135b115f (T1), 29da5b29 (T1, T2), f184e8f7 (T4, T5, T9, T12–T14), 02c83e9d (T1)
- Evidence: "patch pad lights and knob CC in four tracks"; the barLatch patch fails on 009, then on 010, because each
  copy has a different shape; Read of 008 fails (25k tokens), so sections are found with `sed -n` ranges.
- Friction: failed assert-replace scripts, drift between the copies of the Launchkey/LC-view code, many navigation
  calls in ~1200-line files.
- Coverage: gap.

### 9. Epic and PRD workflow (8 sessions)
- Sessions: 95978549, 14cfb5a5 (T1, T2), 111e7944, fd82181a, d086ed6d, 29ba6711 (T1, T2), 871a0100, 37237eec
- Evidence: five epics in one afternoon, all backlog; a review found outdated facts in every epic; epics were
  untracked because `.gitignore` excludes `.claude/*`; the user had to ask for English in capitals; translation
  subagents in 871a0100 ended without a report and overlapped in scope.
- Friction: one session to commit epics, one to review and fix them; unknown completion state of parallel agents.
- Coverage: gap. `ccpm` is user-level; the project has no conventions for it.

### 10. Environment setup (8 sessions)
- Sessions: 234acb00 (T1), af56f83f (T7, T13, T20), 11e69acc (T7), 1f719521 (T2), e950b439 (T2), 02c83e9d (T2),
  d2e0b46d (T1), f184e8f7 (T12)
- Evidence: `ERR_MODULE_NOT_FOUND @strudel/transpiler` then three reinstall attempts; "navigation to localhost:8766
  was denied or failed"; port 8766 already in use; servers on 8765/8766/8767; `pdftotext not found`; numpy missing.
- Friction: 4–6 calls per occurrence before real work starts.
- Coverage: covered for Chrome (memory); gap for deps in fresh worktrees, server ports and missing CLI tools.

Smaller themes, not ranked: trajectory visuals drifting from the wanted look (af56f83f, 1f719521, 11e69acc); slow KPI
renders with notification loops (2441fdae, cd069e22); mixed reply language before the English switch (95978549,
14cfb5a5, 871a0100, 29ba6711; handled by epic `english-repo`); `wrap_up` refusing the commit button (harness only).

## Proposals
Score = benefit (1–3) × sessions affected / effort (S = 1, M = 2, L = 3). Type: hook, tool script, skill update, new
skill, `CLAUDE.md` rule, memory, config.

| # | Proposal | Type | Themes | Benefit | Effort | Score |
|---|---|---|---|---|---|---|
| P1 | Bash PostToolUse matcher: after any Bash call, run every `.strudel` file changed since the last run (`git status`) through `hook.mjs`; print one line per file regenerated (PDF, syx, single, tapped) | hook | 1 | 3 | S | 39 |
| P2 | `npm run verify -- <track…>` in `tools/`: transpile check, compare vs HEAD, check-sounds, layout/syx, tapped refresh; a "Tools" cheat sheet in `CLAUDE.md` with one command per tool (`compare`, `measure`, `check-sounds`, `make-set`, `verify`) | tool script + rule | 1, 2 | 3 | M | 19 |
| P3 | Rewrite the five skill descriptions with the user's trigger words ("compare old/new", "louder/quieter", "level", "board", "regenerate layout") and add "use skill X for Y" lines in `CLAUDE.md` | skill update | 2, 5 | 2 | S | 24 |
| P4 | Git rules in `CLAUDE.md`: never push to main, branch from fresh main, regenerate generated files on conflict, check `git status` and sibling variants/PRs before multi-file edits; `.gitattributes` marks PDFs and `.syx` as binary/generated | rule + config | 4 | 3 | S | 42 |
| P5 | `tools/strudel-sim/scenario.mjs <track> --cc --press --pad --keys --lc 2 --stems`: controller scenarios from the command line, plus a dump of the LC view text | tool script | 3 | 3 | M | 16 |
| P6 | Track `.claude/settings.json` in git (`.gitignore` exception) so the hooks exist in every checkout | config | 1, 9 | 2 | S | 8 |
| P7 | `strudel-mix` covers pads, Launchkey keys and voice samples; an audibility check flags any layer silent or far below the mix at knobs 0 | skill update + tool | 5 | 2 | M | 9 |
| P8 | New skill `add-sample`: file into `samples/<folder>/`, register, map the pad, run check-sounds, report the push needed; check-sounds flags samples not on origin/main | new skill + tool | 6 | 2 | M | 6 |
| P9 | Measured Launchkey MK4 25 table (keys, pads, knobs, wheel, every button CC) in the devices doc, LC XL 3 knobs noted as absolute; a user-vocabulary line under Labels (Density → Tension, build-up → Chapter) | rule + doc | 7 | 2 | S | 26 |
| P10 | `tools/path-lint.mjs`: check every repo path cited in `CLAUDE.md`, skills, epics and docs; run before commits | tool script | 7 | 2 | S | 14 |
| P11 | Shared regions (`// @shared <name> begin/end`) and `tools/shared/sync.mjs` that copies the canonical block into 007–010 and reports drift | tool script | 8 | 2 | L | 3 |
| P12 | `tools/track-map.mjs <track>`: section banners, `@ctl`/`@lk` tags, helpers and stems with line numbers | tool script | 8 | 1 | S | 4 |
| P13 | Epic conventions in `CLAUDE.md`: English, tracked in git, facts checked against the tree, overlaps with open epics noted; parallel agents get disjoint file lists and must report | rule | 9 | 2 | S | 16 |
| P14 | SessionStart hook: `npm ci` in `tools/` when `node_modules/@strudel/transpiler` is missing (fresh worktrees) | hook | 10 | 2 | S | 4 |
| P15 | `.claude/launch.json` with the trajectory server on a fixed port and a static server for mocks | config | 10 | 1 | S | 5 |
| P16 | Pre-commit guard (PreToolUse on `git commit`) that rejects staged files over 10 MB; `.gitignore` for recordings and DAW backups | hook + config | 4 | 2 | S | 6 |
| P17 | Memory refresh: fix `one-file-any-controllers` (`old/` is gone); add machine tool notes (ffmpeg yes, numpy/poppler no) and the trajectory visual reference | memory | 7, 10 | 1 | S | 4 |

Rank by score: P4, P1, P9, P3, P2, P5, P13, P10, P7, P6, P8, P16, P15, P12, P14, P17, P11.

Suggested first package (highest score, small, disjoint files): P4, P1, P9, P3, P2. P1 and P6 together remove the
biggest single source of stale output. P5 and P7 are the larger builds with the most rehearsal-time payoff.

Overlap notes: P2 does not replace `strudel-optimize` (CPU restructuring and its proof) or `strudel-mix` (leveling);
it runs their checks as one command. P8 is the only new skill; no existing skill covers adding a sample.

## Selection
All 17 proposals were selected and built (2026-11-16):

- [x] P1 Bash hook for track edits
- [x] P2 `npm run verify` + tools cheat sheet
- [x] P3 Skill descriptions with trigger words
- [x] P4 Git rules + `.gitattributes`
- [x] P5 Controller scenario CLI
- [x] P6 Track `.claude/settings.json` and PRDs
- [x] P7 `strudel-mix` for pads/keys/voices + audibility check
- [x] P8 `add-sample` skill
- [x] P9 Launchkey table + user vocabulary
- [x] P10 Path lint
- [x] P11 Shared-block sync
- [x] P12 Track map
- [x] P13 Epic conventions
- [x] P14 Deps on session start
- [x] P15 `launch.json`
- [x] P16 Big-file guard
- [x] P17 Memory refresh

## Outcome
Built 2026-11-16, each item tried once on a real past case. Nothing rejected; partial items say what is missing.

| # | Built | Tried on | Result |
|---|---|---|---|
| P1 | `tools/lcxl-layout/bash-hook.mjs` (PostToolUse Bash); `hook.mjs` refactored into `refresh()` and now reports one line per file as `additionalContext` | temp lab board edited by shell; dirty 009 | Regenerates PDF/single, no-op on the next call (~0.1 s), broken `@ctl` → exit 2. First run without cache only takes files changed in the last 10 minutes |
| P2 | `tools/verify/verify.mjs`, `npm run verify`; Tools cheat sheet in `CLAUDE.md`; stale `layouts`/`syx` globs fixed | 007–010 after the P11 edit | 5–15 s per track; compare reports identical / changed per scenario. Layout PDFs are now byte-stable (`typst --creation-timestamp 0`) |
| P3 | Trigger-word descriptions for all six project skills; "Skills and tools" section in `CLAUDE.md` | — | Effect shows only in later sessions; rerun the digest to count invocations |
| P4 | `## Git` rules in `CLAUDE.md`; `.gitattributes` (PDF, syx, audio binary; generated files marked) | — | Rules only |
| P5 | `tools/strudel-sim/scenario.mjs` (`npm run scenario`); `harness.mjs` gains fake WebMidi ports, midikeys queue, stem tap (backward compatible) | 009 Chapter press; 010 two LCs on the kick fader; 009 pads | All three behave as in the browser; `--view` dumps the LC view as text (no bar counter, no styling) |
| P6 | `.gitignore` tracks `.claude/settings.json`, `launch.json`, `.gitattributes` | — | Hooks now reach every checkout |
| P7 | `tools/strudel-sim/audibility.mjs` (`npm run audibility`); `render.mjs` loads banks, soundfonts and the track's own samples, keys render; `strudel-mix` skill rewritten | 010 ambient-house | Found: `stemJ8_shake` is always silent (`colJojo(8)` maps to `off()`); Marimba D and Glockenspiel pads LOW; Rim echo and Shaker pads clip; noise, hats, bells, birds LOW. Not fixed (sound changes need the user) |
| P8 | Skill `add-sample`; `check-sounds.mjs` warns "plays only after push to main" | copy of 010 with an unpushed dummy sample | Warning in both modes, exit code unchanged. `pad-levels.mjs` keeps its own voice map (skill says so) |
| P9 | `midi-layouts/devices.md`: full Launchkey table (pad grid C1 = 36 … E1 = 40, knobs absolute, untested buttons marked); vocabulary line in `CLAUDE.md` | transcripts and tracks | Pad channel 10 confirmed in use, button CCs still unmeasured |
| P10 | `tools/path-lint.mjs` (`npm run path-lint`) | whole repo | 62 hits, all planned files in epics/PRDs, example names, or deleted files the review quotes; `CLAUDE.md`, skills and devices doc clean. Not run as a commit hook (too noisy while epics name planned files) |
| P11 | `// @shared` regions (10 regions) in 007–010, canonical copies in `tools/shared/`, `npm run shared [-- --check / --from]` | 007–010 | `--check` 38× same. `controls` and `lc-view-draw` unified; compare identical on 008–010; 007 `ride B` differs, but HEAD vs HEAD differs the same way (compare is nondeterministic there). Left unmarked: 009's view draw, 008's `columns` (knob defaults), the status boxes |
| P12 | `tools/track-map.mjs` (`npm run track-map`) | 008 (1462 lines) | ~80-line outline with sections, tags, stems, master |
| P13 | `## Epics (ccpm)` in `CLAUDE.md` | — | Rules only |
| P14 | `tools/hooks/session-start.mjs` (SessionStart) | scratch copy of `tools/` without `node_modules` | Runs `npm ci` once, silent afterwards |
| P15 | `.claude/launch.json`: `trajectory` (8766) and `static` (repo root on 8770) | — | Config only |
| P16 | `tools/hooks/commit-guard.mjs` (PreToolUse Bash on `git commit`) | 11 MB staged file | Refused with file and size; recordings are tracked on purpose, so no new `.gitignore` entries |
| P17 | Memory: `one-file-any-controllers` fixed (`old/` → git history, set sources); new `machine-tools` | — | Trajectory visual reference not added (no source for it) |

Follow-ups found during the build: 010 shaker stem silent and pad levels (P7); `measure.mjs` default `--base` (CC 21–28)
is from the 006 layout; 008/009/010/011 load piano samples from the `johannes` branch; `lab/harmony/old/` may still exist.
