#!/usr/bin/env bash
# Stop all AntiBot gateway processes. Run from repo root or scripts/.
set -euo pipefail
echo "Stopping AntiBot gateway on 18889..."
pkill -f "antibot.mjs gateway.*18889" 2>/dev/null || true
pkill -f "run-node.mjs gateway.*18889" 2>/dev/null || true
pkill -f "entry.js gateway.*18889" 2>/dev/null || true
pkill -f "node.*antibot.mjs gateway" 2>/dev/null || true
pkill -f "node.*run-node.mjs gateway" 2>/dev/null || true
sleep 2
if pgrep -f "gateway.*18889" >/dev/null 2>&1; then
  echo "Some gateway processes may still be running. Try: pkill -9 -f gateway"
  exit 1
fi
echo "Gateway stopped. Port 18889 is free."
