#!/usr/bin/env bash
# One-time bring-up verification: Node 22, artifacts, gateway with --allow-unconfigured on 18889.
# Run from repo root inside WSL:  bash scripts/antibot-bringup-verify.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANTIBOT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
export ANTIBOT_STATE_DIR="${ANTIBOT_STATE_DIR:-$HOME/.antibot}"

# 1) Node >=22.12
if [[ -f "$SCRIPT_DIR/antibot-env.sh" ]]; then
  # shellcheck source=antibot-env.sh
  . "$SCRIPT_DIR/antibot-env.sh"
else
  echo "antibot-env.sh not found"
  exit 1
fi

# 2) Artifacts
cd "$ANTIBOT_ROOT"
for f in dist/entry.js dist/control-ui/index.html src/canvas-host/a2ui/a2ui.bundle.js; do
  if [[ ! -f "$f" ]]; then
    echo "Missing artifact: $f (run pnpm build and pnpm ui:build)"
    exit 1
  fi
done
echo "Node $(node -v), artifacts OK"

# 3) Start gateway with --allow-unconfigured (prove path without config)
LOG="/tmp/antibot-bringup-verify.log"
pkill -f "antibot.mjs gateway.*18889" 2>/dev/null || true
sleep 1
# Ensure we use the same node that passed the version check (NVM may not be inherited by nohup on some systems)
NODE_EXEC=$(command -v node)
echo "Using $NODE_EXEC ($($NODE_EXEC -v))" >"$LOG"
nohup "$NODE_EXEC" antibot.mjs gateway --allow-unconfigured --port 18889 >>"$LOG" 2>&1 &
GW_PID=$!
# Gateway can take 15-20s to bind (canvas, heartbeat, model resolution, then listen)
for i in $(seq 1 25); do
  sleep 1
  if ! kill -0 "$GW_PID" 2>/dev/null; then
    echo "Gateway exited; log:"
    cat "$LOG"
    exit 1
  fi
  HTTP=$(curl -fsS -o /dev/null -w "%{http_code}" --max-time 2 http://127.0.0.1:18889/ 2>/dev/null || echo "000")
  if [[ "$HTTP" == "200" ]] || [[ "$HTTP" == "301" ]]; then
    break
  fi
  [[ $i -eq 25 ]] && HTTP="000"
done
kill "$GW_PID" 2>/dev/null || true
sleep 1
if [[ "$HTTP" != "200" ]] && [[ "$HTTP" != "301" ]]; then
  echo "Dashboard returned HTTP $HTTP (expected 200/301). Log:"
  tail -80 "$LOG"
  exit 1
fi
echo "Gateway on 18889 OK (HTTP $HTTP)"
