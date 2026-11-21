---
name: player
description: Start the player (tools/trajectory/server.mjs) and open it in the default browser, optionally on a given port and a given branch. Use for "start the player", "open the player", "launch the player on port 8800", "player for branch epic/sound-lab". Arguments, both optional - port (digits, default 8766) and branch (anything else, default the current checkout).
---

# Launch the player

Arguments: `$ARGUMENTS`, in any order. A token of only digits is the port (default `8766`); any other token is the branch
(default: the current checkout).

## 1. Pick the directory
- No branch, or the branch is the one checked out here: the repo root.
- Otherwise find a worktree on that branch: `git worktree list --porcelain`, match `branch refs/heads/<branch>`; use its
  path. Skip entries marked `prunable`.
- No worktree has it: `git fetch origin <branch>` if it is not local, then
  `git worktree add .claude/worktrees/<branch with / replaced by ->  <branch>`. Never switch the branch of the main
  checkout and never touch uncommitted work. If the branch does not exist locally or on origin, stop and say so.
- A fresh worktree has no `tools/node_modules`: run `npm ci` in its `tools/` first.

## 2. Check the port
`lsof -nP -iTCP:<port> -sTCP:LISTEN`. If something listens, show its command and the port and ask whether to use
another port or just open the browser on the running one (it may already be the player). Do not kill it.

## 3. Start and open
1. In `<dir>/tools`, run `node trajectory/server.mjs <port>` with Bash `run_in_background: true`.
2. Wait until `curl -sf http://localhost:<port>/ -o /dev/null` succeeds (poll up to about 15 s). On failure read the
   background output and report the error.
3. `open http://localhost:<port>` (macOS default browser).

Report in one line: URL, directory, branch. Stopping: the background task ends with the session, or kill that task.
