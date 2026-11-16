---
name: workflow-review
description: Mine recent cerulean-echoes chats for friction and build the agent/skill/hook improvements the user approves
status: backlog
created: 2026-11-15T16:46:39Z
---

# PRD: workflow-review

## Executive Summary
Review all Claude Code sessions of this project since 2026-11-10 (27 main transcripts plus subagent transcripts,
~54 MB), find recurring friction and repeated manual work, propose new or improved skills, agents, hooks and
`CLAUDE.md` rules, and build the ones the user approves.

## Problem Statement
Work on tracks, boards and the set repeats the same steps across sessions (layout regeneration, equivalence checks,
sound checks, handovers between agents, controller layout reviews). Some steps are covered by the five project skills
(`lab-board`, `lab-to-track`, `lcxl-layout`, `strudel-mix`, `strudel-optimize`) and one PostToolUse hook; others are
redone by hand, explained again each session, or corrected by the user. Nobody has looked across sessions to see
where time and corrections go.

## User Stories
- **As the user**, I get a ranked list of improvement proposals grounded in real sessions.
  - Acceptance: each proposal cites at least two sessions (session id + short quote or summary), states the friction,
    the proposed change (new skill / skill update / agent / hook / `CLAUDE.md` rule / memory), expected benefit and
    effort.
- **As the user**, I decide which proposals get built.
  - Acceptance: proposals are presented for selection before any skill, agent, hook or rule is written or changed.
- **As the user**, approved improvements work in the next session.
  - Acceptance: each built item has been tried once on a real task from the sessions it came from, and the result
    is noted in the findings report.

## Functional Requirements
1. Extract from each transcript: user requests, user corrections and rejections ("no", "not like that", repeated
   instructions), repeated tool sequences, skill and subagent use, hook output and failures, long or abandoned turns,
   handover notes (`handover-*`, `next-agent-prompt.md`).
2. Cluster findings into themes and count frequency across sessions.
3. Compare themes against existing skills, hook, `CLAUDE.md` and memory: gap, outdated, or unused.
4. Write `docs/workflow-review.md`: themes, evidence, ranked proposals.
5. After user selection, implement each approved proposal in `.claude/skills/`, `.claude/agents/`,
   `.claude/settings.json`, `CLAUDE.md` or memory.

## Non-Functional Requirements
- Transcripts stay local; nothing from them is sent to external services. Quotes in the report are short.
- Extraction runs as a script over the JSONL files (cheap), not by loading 54 MB into context; reading is done by
  subagents per batch of sessions.
- Machine rule: one heavy job at a time on the shared M2 Air.
- New skills follow the existing project skill format and house style in `CLAUDE.md`.

## Success Criteria
- 100% of the 27 sessions (and their subagent transcripts) processed by the extraction script.
- Report lists ≥5 themes, each with frequency and ≥2 cited sessions.
- Every approved proposal shipped and tried once; rejected ones listed with reason.
- No duplicate skill: each new skill states which existing skill it does not overlap with.

## Constraints & Assumptions
- Transcripts live in `~/.claude/projects/-Users-jonas-hall-Documents-GitHub-cerulean-echoes/*.jsonl` (+ subagent
  folders); format is Claude Code JSONL and may change between versions.
- Only project-level changes (`.claude/` in the repo, `CLAUDE.md`, project memory); user-level `~/.claude` stays as is.
- Overlap with epic `english-repo`: skill and `CLAUDE.md` edits must be in English and should land after that epic's
  rule/skill translation, or be rebased onto it.

## Out of Scope
- Sessions from other repositories and user-level skills/agents.
- Changing tracks, sounds or controller layouts.
- Tuning model, effort or permission settings.

## Dependencies
- Node or Python for the extraction script (in `tools/`).
- User availability for the selection step.
- Epic `english-repo` task 2 (rules/skills translation) for ordering of skill edits.
