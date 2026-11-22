# Claude skills

## What it is
Skills are short instruction files in `.claude/skills/` that tell Claude Code how to do a recurring job in this repo.
You do not run them as commands. You say what you want in your own words, and Claude picks the matching skill.

## When to use it
When you work with Claude Code in this repo and the job is one of the ones below.

## How to use it
| Skill | What it does | Say something like |
|---|---|---|
| `strudel-optimize` | Makes a track cheaper to compute without changing the sound, and proves it event by event | "it drops out", "compare old and new" |
| `strudel-mix` | Measures levels and sets faders and gains in balance | "too quiet", "it clips", "balance the stems" |
| `lab-board` | Builds a lab board or the next round of one | "new board", "candidates for bass", "next round" |
| `lab-to-track` | Moves a finished lab column into a track unchanged | "put the winner into 009" |
| `add-sample` | Adds an audio file, puts it on a Launchkey pad, levels it and checks that it loads | "put this sample on pad E1" |
| `sample-designer` | Arranges a free sound as a Sample Designer project, or copies a project and changes it; checks it and loads it in SuperCollider | "a soft tom with a short noise tail" |
| `stem-designer` | Sets up a Stem Designer project of candidate stems against a track; promotes a winner and puts it into a new track file | "the flute in the house track is boring, explore a replacement" |
| `auto-perform` | Designs, scripts and reviews an auto-performance | "new performance for 008" |
| `workflow-review` | Reviews past sessions and proposes ranked repo changes | "workflow review for last week" |

## Good to know
- A skill only guides Claude. The real work is done by the tools in `tools/` (see [checks](checks.md)).
- Claude asks before it changes sound, effects or the controller layout, unless that is the task.
- Hooks run on their own after every edit: they check the `@ctl` tags of a changed track and regenerate single versions.
- Project rules Claude always reads: `CLAUDE.md`.

## Related
- [Checks](checks.md)
- [Lab boards](lab-boards.md)
- [Samples and sounds](samples-and-sounds.md)
- [Auto-perform](auto-perform.md)
