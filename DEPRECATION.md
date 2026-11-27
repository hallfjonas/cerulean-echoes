# Deprecations

Every agent working in this repo reads this file before it builds a feature. When a new feature is developed, do not
support anything listed here: build the feature on the replacement, and do not add code, controls, tests or docs that
extend a deprecated feature. If a request can only be met on a deprecated feature, say so and ask before you go on.

Deprecated features keep working where they already work. Existing files are not removed by this list. Removal is a
separate decision, made with the user.

## Deprecated

| Feature | Replacement | Deprecated since |
|---|---|---|
| Strudel (strudel.cc tracks, boards, the Strudel-based player and tools) | SuperCollider, see [SC-MIGRATION.md](SC-MIGRATION.md) and [sc/README.md](sc/README.md) | 2026-11-21 |

## Strudel

- **Not supported for new features:** new Strudel tracks, boards or stems; new controls, layouts, auto-performances or
  visuals written in Strudel; new Strudel-only helpers or checks.
- **New features go to SuperCollider** (`sc/`). Plans and decisions for the move are in [SC-MIGRATION.md](SC-MIGRATION.md).
- **Still there:** `tools/sc-port/reverb-ir.mjs`, which measures Strudel's reverb with `superdough` (and
  `node-web-audio-api`, the two npm packages left) to make an impulse response for SC. Nothing else in the player or
  the tools runs Strudel.
- **Removed on 2026-11-22** (decided with the user, sc-migration 010): set 011, the historic tracks 000-006, the
  Strudel checks (`verify`, `compare`, `audibility`, `measure`, `scenario`, `check-sounds`, the sound list) and the
  skills `/strudel-mix` and `/strudel-optimize`.
- **Removed on 2026-11-26** (decided with the user): the lab tutorials (`lab/tutorials/`), `snippets/`,
  `superdirt-setup/`, the `dual-lc` template and the layout hooks that checked `.strudel` files, the Strudel-only
  comparison tools in `tools/sc-port/`, and the skills `/lab-board` and `/lab-to-track`.
- **Removed on 2026-11-27** (decided with the user): the producer (Guitar Pro MIDI → Strudel track: `tools/producer/`,
  `npm run producer`, the skill `/producer`, the producer mode docs, the 012 and 013 fixtures), the player's Strudel
  engine (`engine-strudel.mjs`, `strudel-source.mjs`, `strudel-globals.mjs`, `banks.mjs`, `make-tapped.mjs` and the
  routes and page code that served them), `tools/strudel-sim/`, `tools/shared/` (`npm run shared`) and the `@strudel/*`
  npm packages. Git history keeps them.

## How to add an entry

Add one row to the table, with the replacement and the date. Then add a section below it with what is no longer
supported for new features. Remove an entry only when the user decides the feature is gone.
