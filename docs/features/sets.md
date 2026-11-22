# Sets

## What it is
A set plays several tracks as one performance: one track runs, then the next takes over, without a stop. On
SuperCollider this is planned: the `set-designer` epic (`.claude/epics/set-designer/`) builds sets from stem tracks
([stems](stems.md), section "Set").

## The Strudel forerunner (removed)
Set 011 played 007, 010, 009 and 008 as one Strudel file, with the Fog knob as the position in the set. It was
removed on 2026-11-22 with the move to SuperCollider (sc-migration 010), together with its build and check tools.
Git history keeps it (`tracks/sets/011-combining-all/` with its `feedback.md`, `tools/set/`). The lesson for SC
sets: one instrument per column, the position moves parameters only, tracks are not morphed into each other.

## Related
- [Live tracks](live-tracks.md)
- [Stems](stems.md)
- [Sound lab](sound-lab.md)
