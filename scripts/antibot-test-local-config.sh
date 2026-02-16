#!/usr/bin/env bash
# Test: minimal config (gateway.mode=local), start gateway without --allow-unconfigured, confirm dashboard.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/antibot-env.sh"
cd "$SCRIPT_DIR/.."
export ANTIBOT_STATE_DIR="${ANTIBOT_STATE_DIR:-$HOME/.antibot}"
mkdir -p "$ANTIBOT_STATE_DIR"
echo '{"gateway":{"mode":"local","bind":"loopback"}}' > "$ANTIBOT_STATE_DIR/antibot.json"
pkill -f "antibot.mjs gateway" 2>/dev/null || true
sleep 2
node antibot.mjs gateway --port 18889 >/tmp/gw-local.log 2>&1 &
GW_PID=$!
for i in $(seq 1 25); do
  sleep 1
  HTTP=$(curl -fsS -o /dev/null -w "%{http_code}" --max-time 2 http://127.0.0.1:18889/ 2>/dev/null || echo "000")
  if [[ "$HTTP" == "200" ]] || [[ "$HTTP" == "301" ]]; then
    echo "OK (HTTP $HTTP) with config only, no --allow-unconfigured"
    kill $GW_PID 2>/dev/null || true
    exit 0
  fi
done
echo "FAIL: dashboard not ready in 25s"
kill $GW_PID 2>/dev/null || true
exit 1
