#!/usr/bin/env bash
# Restart only the AntiBot gateway on 18889.
# Use when WSL, Ollama, and lume-llama-unbound are already running.
# Run from repo root (e.g. ~/projects/antibot).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANTIBOT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
if [[ -f "$SCRIPT_DIR/antibot-env.sh" ]]; then
  . "$SCRIPT_DIR/antibot-env.sh"
fi
export ANTIBOT_STATE_DIR="${ANTIBOT_STATE_DIR:-$HOME/.antibot}"

echo "Stopping gateway on 18889..."
pkill -f "antibot.mjs gateway.*18889" 2>/dev/null || true
pkill -f "run-node.mjs gateway.*18889" 2>/dev/null || true
pkill -f "entry.js gateway.*18889" 2>/dev/null || true
pkill -f "node.*antibot.mjs gateway" 2>/dev/null || true
pkill -f "node.*run-node.mjs gateway" 2>/dev/null || true
sleep 2

echo "Starting AntiBot gateway..."
cd "$ANTIBOT_ROOT"
NODE_BIN="$(which node)"
# ClawdBot verbatim: run-node.mjs builds if needed then spawns node dist/entry.js.
nohup "$NODE_BIN" scripts/run-node.mjs gateway --port 18889 >/tmp/antibot-gateway.log 2>&1 &
sleep 2

get_dashboard_url() {
  local token=""
  if [[ -n "${OPENCLAW_GATEWAY_TOKEN:-}" ]]; then
    token="$OPENCLAW_GATEWAY_TOKEN"
  elif [[ -n "${ANTIBOT_GATEWAY_TOKEN:-}" ]]; then
    token="$ANTIBOT_GATEWAY_TOKEN"
  elif [[ -f "${ANTIBOT_STATE_DIR:-$HOME/.antibot}/antibot.json" ]]; then
    token=$(jq -r '.gateway.auth.token // empty' "${ANTIBOT_STATE_DIR:-$HOME/.antibot}/antibot.json" 2>/dev/null) || \
    token=$(grep -oE '"token"\s*:\s*"[^"]+' "${ANTIBOT_STATE_DIR:-$HOME/.antibot}/antibot.json" 2>/dev/null | head -1 | sed 's/.*"\([^"]*\)$/\1/') || true
  fi
  if [[ -n "$token" ]]; then
    echo "http://127.0.0.1:18889/#token=${token}"
  else
    echo "http://127.0.0.1:18889/"
  fi
}
echo "Gateway restarted. Dashboard: $(get_dashboard_url)"
