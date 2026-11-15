---
name: workflow-review
status: backlog
created: 2026-11-15T16:46:39Z
updated: 2026-11-15T16:46:39Z
progress: 0%
prd: .claude/prds/workflow-review.md
github: (will be set on sync)
---

# Epic: workflow-review

## Overview
Script-extract signals from the 27 cerulean-echoes sessions since 2026-11-10, have subagents read the condensed
digests in batches, cluster recurring friction into themes, propose skill/agent/hook/rule changes in a ranked report,
let the user pick, then build and try the picked ones.

## Architecture Decisions
- **Script first, LLM second.** A Node script (`tools/session-digest/digest.mjs`) turns each JSONL into a compact
  digest (user messages, corrections, tool-call sequences, skill/subagent calls, hook errors, turn lengths). Subagents
  read digests, never raw JSONL. Keeps context small and the run repeatable.
- **Batch reading in parallel.** Digests split into ~4 batches by date; one subagent per batch writes findings in a
  fixed schema (theme, evidence with session id, friction, suggested fix).
- **Human gate.** No skill, agent, hook or rule is written before the user selects proposals from the report.
- **Reuse existing artefacts.** Prefer updating the five project skills and the `lcxl-layout` hook over new ones; new
  skills only for uncovered recurring work.
- **Repeatable.** Digest script and report template stay in the repo so the review can be rerun later.

## Technical Approach
### Frontend Components
- `docs/workflow-review.md`: themes, frequency, evidence, ranked proposals (benefit × frequency / effort), selection
  checklist, later the outcome of each tried item.

### Backend Services
- `tools/session-digest/digest.mjs`: reads main and subagent JSONL for this project, writes
  `tools/session-digest/out/<session>.md` (git-ignored, contains private chat content).
- Signal heuristics: user turns starting with negation or repeating an earlier instruction; same tool sequence ≥3
  times; edits followed by reverts; hook outputs with errors; skills/subagents invoked and outcome.

### Infrastructure
- Built items land in `.claude/skills/<name>/SKILL.md`, `.claude/agents/<name>.md`, `.claude/settings.json` hooks,
  `CLAUDE.md` or project memory.
- `.gitignore` entry for digest output.

## Implementation Strategy
1. Build digest script, test on 1 small session, then run on all (one heavy job).
2. Parallel batch analysis by subagents → findings files.
3. Synthesis into the ranked report → user selection.
4. Build approved items (parallel where files are disjoint) → try each on a real past task → record outcome.
Order with `english-repo`: build step after that epic's task 2, or write in English and rebase.

## Task Breakdown Preview
1. **Session digest script** — `digest.mjs`, git-ignored output, run over all 27 sessions + subagents. Serial.
2. **Inventory current tooling** — summarise the 5 skills, hook, `CLAUDE.md` rules, memory: what each covers, when
   last used in sessions. Parallel with 1.
3. **Batch analysis A/B (Nov 10–12)** and **4. Batch analysis C/D (Nov 13–15)** — subagents read digests, write
   findings in fixed schema. Parallel, depend on 1.
5. **Synthesis report + user selection** — cluster, rank, compare to inventory, write `docs/workflow-review.md`,
   present for selection. Depends on 2–4. Blocks build.
6. **Build approved improvements** — implement selected skills/agents/hooks/rules; may split into sub-tasks per item
   after selection. Depends on 5.
7. **Try and record** — run each built item once on a real past task, note outcome in the report, adjust. Depends
   on 6.

## Dependencies
- Local transcripts in `~/.claude/projects/-Users-jonas-hall-Documents-GitHub-cerulean-echoes/`.
- User selection after task 5.
- Epic `english-repo` (task 2) for ordering of skill/`CLAUDE.md` edits.

## Success Criteria (Technical)
- Digest script processes 27/27 sessions and all subagent files without error; output git-ignored.
- Report: ≥5 themes, each with frequency and ≥2 cited sessions; every proposal has type, benefit, effort.
- Each approved item shipped, tried once, outcome recorded; rejected items listed with reason.
- No new skill overlaps an existing one without stating why.

## Estimated Effort
- Task 1 ~1–2 h, task 2 ~30 min, tasks 3–4 ~1 h each in parallel, task 5 ~1 h + user time, tasks 6–7 depend on
  selection (~0.5–1 day). Analysis to report: ~half a day of agent time.
