# Model comparison: one prompt, three models

Same task, three models: build a groove techno track from `docs/reference/genres.md`.
Evidence page: see the published artifact. Meme: `meme.svg`.

## Reproduce

1. Fresh checkout of `origin/main`, new session per model.
2. Pick the model (`/model claude-haiku-5-5`, `claude-sonnet-5-5` or `claude-opus-5-5`), same effort.
3. Send the prompt from `sessions.json` (`prompt`), with `<model>` replaced. Let it finish, note start and end time, turns.
4. Commit the track on its own branch, open a PR.
5. Play the track in the player (`cd tools && node trajectory/server.mjs`, localhost:8766), press R to record, press R to stop.
   Copy `recordings/<track>/*.json` to `recordings-sidecars/<model>.json`.
6. Put branch, track path, PR and timings into `sessions.json`, then run:

```bash
node docs/experiments/model-comparison/reproduce.mjs
```

`--no-audibility` skips the loudness render (the slow part). The script reads each track from its branch with
`git show`, so it never touches your working tree.
