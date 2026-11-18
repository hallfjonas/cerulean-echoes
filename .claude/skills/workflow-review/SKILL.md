---
name: workflow-review
description: Review past Claude Code sessions of this project for a date or date range, collect recurring pain points and repeated manual work, and propose ranked repo changes (skills, hooks, tool scripts, CLAUDE.md rules, memory, file layout) that cut friction and keep the repo maintainable. Nothing is built before the user picks. Use for "review sessions", "review conversations", "workflow review", "pain points", "what went wrong this week", "friction", "retro", "how can we work better".
---

# Workflow review

Script first, reading second: transcripts are never read raw. The digest script condenses them, subagents read the
digests, you synthesise. The first full review is `docs/dev/workflow-review.md`; follow its structure.

## 1. Range
Take `--since` / `--until` (YYYY-MM-DD, inclusive; a session counts on the day it started) from the request. One
date: same value for both. No date: since the end of the last report in `docs/workflow-reviews/` (or
`docs/dev/workflow-review.md`) until today. Say the range in one line before starting.

## 2. Digest
```sh
cd tools
node session-digest/digest.mjs --since <from> --until <to>
```
Writes `tools/session-digest/out/<session>.md` plus `out/index.md` (sessions, human turns, corrections, tool calls,
errors, subagents). The folder is emptied each run and git-ignored: it holds private chat content, so never commit it
or quote it at length. Skip sessions that are only `/clear`, belong to another repository, or are copies of another.
Zero sessions: say so and stop.

## 3. Inventory
List what exists now, with how often each was used in the range (count `Skill(...)`, hook output and agent calls in
the digests): `.claude/skills/*`, `.claude/agents/*`, hooks in `.claude/settings.json`, `CLAUDE.md` sections, project
memory (`~/.claude/projects/-Users-jonas-hall-Documents-GitHub-cerulean-echoes/memory/`), tools in `tools/`.
Read the previous reports' Proposals and Outcome sections: note which built items were used and whether their theme
came back.

## 4. Read in batches
Up to 8 sessions: read the digests yourself. More: split by date into batches of about 8–10 sessions and start one
`general-purpose` subagent per batch in parallel, each with the digest paths of its batch and this output schema:

```
### <theme, one line>
- Sessions: <8-char id> (T<n>, ...), ...
- Frequency: <sessions affected>
- Evidence: short English paraphrases per session, no long quotes
- Friction: what it cost (turns, user corrections, rework, stale files)
- Suggested fix: hook / tool script / skill update / new skill / agent / CLAUDE.md rule / memory / file layout
- Coverage: which existing item should have handled it, and why it did not
```

Look for: user corrections and repeated instructions, the same tool sequence three or more times, edits followed by
reverts, hook errors or silent hooks, steps done by hand that a skill or tool covers, stale facts in `CLAUDE.md` or
memory, files the agent had to search for, sessions that ended without the result verified.
Maintainability counts too: duplicated blocks patched in several tracks, generated files edited by hand, docs that
drifted from code, dead tools or skills.

## 5. Report
Write `docs/workflow-reviews/<from>_<to>.md` (one date: `<date>.md`), in English:
1. Method: range, session count, excluded sessions and why.
2. Inventory table: item, what it covers, used in this range.
3. Themes ranked by sessions affected, merged across batches, each with sessions, evidence, friction.
4. Follow-up on earlier proposals: built item → used? theme gone, smaller, or back?
5. Proposals table: `#`, proposal, type, themes, benefit (1–3), effort (S = 1, M = 2, L = 3),
   score = benefit × sessions / effort. Prefer updating an existing skill, hook or rule over a new one; a new skill
   only for recurring work nothing covers, and say why it does not overlap.
6. Selection checklist (`- [ ] P1 …`), empty Outcome section.

## 6. Gate
Show the top proposals with score in chat and ask which to build. Build nothing before the answer. Changes to sound,
effects, orbits, naming or controller layout found on the way are follow-ups that need the user's OK (`CLAUDE.md`
rules), never part of the build.

## 7. Build and try
Build the picked items (parallel subagents only for disjoint files). Try each once on a real case from the digests,
fill the Outcome section (built, tried on, result, adjusted), add the new item to `CLAUDE.md` "Skills and tools" when
it is a skill or tool. Commit on a branch; push and PR only when asked.
