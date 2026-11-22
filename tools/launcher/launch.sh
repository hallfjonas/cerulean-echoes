#!/bin/bash
# The launcher's work, called by "Cerulean Echoes.app" (tools/launcher/launcher.applescript) and by its test:
#   launch.sh check      exit 0 and print "ok", or "install" when tools/node_modules is missing;
#                        exit 1 with a plain message (stderr) when Node.js or SuperCollider is missing
#   launch.sh install    npm ci in tools/ (once, on the first start)
#   launch.sh start      start the player server (tools/trajectory/server.mjs) in the background and wait until it
#                        answers; print "started <pid>", or "running" when a player already answers on the port (then
#                        nothing is started and stop leaves it alone)
#   launch.sh open       open the player in the default browser (one tab)
#   launch.sh alive      exit 0 while the server this launcher started runs, 1 when it ended by itself, 3 when this
#                        launcher started none (or stopped it)
#   launch.sh url        print the player's address
#   launch.sh stop       stop the server this launcher started (SIGINT: it ends its SuperCollider), wait for it
# Options (or environment): --port N (CE_PORT, default 8766), --no-browser (CE_NO_BROWSER=1),
#   --watch PID: the started server is stopped when process PID ends (the app: also on a force quit).
# Environment for tests: CE_LOG (log file), CE_STATE_DIR (pid files), CE_NODE (node binary), SCLANG (as in sc-link.mjs),
#   CE_SC_PORT / CE_SC_SERVER_PORT (passed on to the server).
# Log: ~/Library/Logs/cerulean-echoes.log (launcher lines and the server's output; SC's own log path is written there).
set -u

here="$(cd "$(dirname "$0")" && pwd)"
repo="$(cd "$here/../.." && pwd)"
tools="$repo/tools"
command="${1:-}"; shift || true
port="${CE_PORT:-8766}"
browser=1; [ "${CE_NO_BROWSER:-}" = 1 ] && browser=0
watch=""
while [ $# -gt 0 ]; do
  case "$1" in
    --port) port="$2"; shift 2 ;;
    --no-browser) browser=0; shift ;;
    --watch) watch="$2"; shift 2 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done
log="${CE_LOG:-$HOME/Library/Logs/cerulean-echoes.log}"
state="${CE_STATE_DIR:-$HOME/Library/Application Support/Cerulean Echoes}"
pidfile="$state/server-$port.pid"
url="http://localhost:$port"
mkdir -p "$(dirname "$log")" "$state"
# keep the log small: start a new one past 2 MB (the last one stays as .1)
if [ -f "$log" ] && [ "$(wc -c < "$log")" -gt 2000000 ]; then mv -f "$log" "$log.1"; fi
say() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] launcher: $*" >> "$log"; }
fail() { say "error: $*"; echo "$*" >&2; exit 1; }

# GUI apps do not get the shell's PATH: look where Node.js is usually installed
find_node() {
  local candidate
  {
    [ -n "${CE_NODE:-}" ] && echo "$CE_NODE"
    command -v node 2>/dev/null
    echo /opt/homebrew/bin/node
    echo /usr/local/bin/node
    ls -d "$HOME"/.nvm/versions/node/*/bin/node 2>/dev/null | sort -rV
    echo "$HOME/.volta/bin/node"
    echo "$HOME/.asdf/shims/node"
    echo "$HOME/.local/share/fnm/aliases/default/bin/node"
    /bin/zsh -lic 'command -v node' 2>/dev/null </dev/null | tail -n 1
  } | while IFS= read -r candidate; do
    if [ -n "$candidate" ] && [ -x "$candidate" ]; then echo "$candidate"; break; fi
  done
}
node="$(find_node)"
if [ -n "$node" ]; then export PATH="$(dirname "$node"):/opt/homebrew/bin:/usr/local/bin:$PATH"; fi

has_sclang() {
  if [ -n "${SCLANG:-}" ]; then [ -e "$SCLANG" ]; return; fi
  [ -x /Applications/SuperCollider.app/Contents/MacOS/sclang ] || command -v sclang >/dev/null 2>&1
}

# a player server answers /catalogue with a JSON list
player_answers() {
  curl -s -m 2 "http://127.0.0.1:$port/catalogue" 2>/dev/null | head -c 1 | grep -q '\['
}

# the pid this launcher started, if that process is still our server
our_pid() {
  local pid
  [ -f "$pidfile" ] || return 1
  pid="$(cat "$pidfile")"
  ps -p "$pid" -o command= 2>/dev/null | grep -q 'trajectory/server.mjs' || return 1
  echo "$pid"
}

case "$command" in
  check)
    [ -n "$node" ] || fail "Node.js is missing. Install it once from https://nodejs.org (the LTS version), then start Cerulean Echoes again."
    major="$("$node" -p 'process.versions.node.split(".")[0]' 2>/dev/null)"
    [ "${major:-0}" -ge 20 ] 2>/dev/null || fail "Node.js $("$node" --version 2>/dev/null) is too old. Install the current LTS version from https://nodejs.org, then start Cerulean Echoes again."
    has_sclang || fail "SuperCollider is missing. Install it once from https://supercollider.github.io/downloads (drag it into Applications), then start Cerulean Echoes again."
    [ -f "$tools/trajectory/server.mjs" ] || fail "The player is not next to the app ($tools/trajectory/server.mjs is missing). Keep Cerulean Echoes.app in the repo folder."
    say "check: node $node ($("$node" --version)), repo $repo"
    if [ -d "$tools/node_modules" ]; then echo ok; else echo install; fi
    ;;
  install)
    [ -n "$node" ] || fail "Node.js is missing. Install it once from https://nodejs.org, then start Cerulean Echoes again."
    npm="$(dirname "$node")/npm"; [ -x "$npm" ] || npm="$(command -v npm)"
    say "install: npm ci in $tools"
    (cd "$tools" && "$npm" ci >> "$log" 2>&1) || fail "Installing the player's helpers failed (no internet connection?). Details: $log"
    say "install: done"
    echo installed
    ;;
  start)
    if our_pid >/dev/null; then echo "started $(our_pid)"; exit 0; fi
    if player_answers; then say "start: a player already answers on $url, nothing started"; rm -f "$pidfile"; echo running; exit 0; fi
    if lsof -nP -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; then
      fail "Port $port is used by another program. Quit it (or restart the Mac), then start Cerulean Echoes again."
    fi
    [ -n "$node" ] || fail "Node.js is missing. Install it once from https://nodejs.org, then start Cerulean Echoes again."
    say "start: node trajectory/server.mjs $port (repo $repo)"
    cd "$tools" || fail "Cannot open $tools"
    nohup "$node" trajectory/server.mjs "$port" >> "$log" 2>&1 < /dev/null &
    pid=$!
    echo "$pid" > "$pidfile"
    if [ -n "$watch" ]; then
      # stop the server when the app ends without its quit handler (force quit, crash)
      nohup /bin/bash -c 'while kill -0 "$1" 2>/dev/null && kill -0 "$2" 2>/dev/null; do sleep 1; done
        if kill -0 "$2" 2>/dev/null; then kill -INT "$2"; fi' "cerulean-echoes-watch-$port" "$watch" "$pid" > /dev/null 2>&1 < /dev/null &
    fi
    for _ in $(seq 1 100); do
      if ! kill -0 "$pid" 2>/dev/null; then
        rm -f "$pidfile"
        fail "The player stopped right after starting. Details: $log"
      fi
      if player_answers; then say "start: player $pid answers on $url"; echo "started $pid"; exit 0; fi
      sleep 0.2
    done
    kill -INT "$pid" 2>/dev/null
    fail "The player did not answer within 20 seconds. Details: $log"
    ;;
  open)
    if [ "$browser" = 0 ]; then say "open: browser skipped ($url)"; echo skipped; exit 0; fi
    say "open: $url"
    open "$url" || fail "Could not open the browser. Open $url yourself."
    echo opened
    ;;
  alive)
    our_pid >/dev/null && exit 0
    [ -f "$pidfile" ] && exit 1   # started, and ended by itself
    exit 3                        # nothing started by this launcher
    ;;
  url)
    echo "$url"
    ;;
  stop)
    pid="$(our_pid)" || { rm -f "$pidfile"; echo "not running"; exit 0; }
    # its children (sclang, which runs scsynth): ended by the server itself; collected in case it has to be killed
    children="$(pgrep -P "$pid" 2>/dev/null) $(for c in $(pgrep -P "$pid" 2>/dev/null); do pgrep -P "$c"; done)"
    say "stop: player $pid"
    kill -INT "$pid" 2>/dev/null
    for _ in $(seq 1 50); do kill -0 "$pid" 2>/dev/null || break; sleep 0.2; done
    if kill -0 "$pid" 2>/dev/null; then say "stop: no exit after 10 s, terminating"; kill -TERM "$pid" 2>/dev/null; sleep 3; fi
    if kill -0 "$pid" 2>/dev/null; then kill -KILL "$pid" 2>/dev/null; fi
    for c in $children; do kill -0 "$c" 2>/dev/null && { say "stop: ending leftover $c"; kill -TERM "$c" 2>/dev/null; }; done
    rm -f "$pidfile"
    say "stop: done"
    echo stopped
    ;;
  *)
    echo "usage: launch.sh check|install|start|open|alive|url|stop [--port N] [--no-browser] [--watch PID]" >&2
    exit 2
    ;;
esac
