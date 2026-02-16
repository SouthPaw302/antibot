#!/usr/bin/env bash
# Source this (or run) before any AntiBot commands in WSL/Linux so Node 22 is active.
# Usage: source scripts/antibot-env.sh   OR   . scripts/antibot-env.sh
set -euo pipefail

# Load NVM if present so we get Node 22
if [[ -n "${NVM_DIR:-}" ]] && [[ -f "${NVM_DIR}/nvm.sh" ]]; then
  # shellcheck source=/dev/null
  . "${NVM_DIR}/nvm.sh"
  nvm use 22 2>/dev/null || true
elif [[ -f "${HOME}/.nvm/nvm.sh" ]]; then
  export NVM_DIR="${HOME}/.nvm"
  # shellcheck source=/dev/null
  . "${NVM_DIR}/nvm.sh"
  nvm use 22 2>/dev/null || true
fi

# Require Node >= 22.12 (matches src/infra/runtime-guard.ts)
node_ver=$(node -v 2>/dev/null | sed 's/^v//') || { echo "Node not found. Install Node 22 (e.g. nvm install 22)."; exit 1; }
major=$(echo "$node_ver" | cut -d. -f1)
minor=$(echo "$node_ver" | cut -d. -f2)
if [[ ! "$major" =~ ^[0-9]+$ ]] || [[ ! "$minor" =~ ^[0-9]+$ ]]; then
  echo "Could not parse Node version: $node_ver"
  exit 1
fi
if [[ "$major" -lt 22 ]] || { [[ "$major" -eq 22 ]] && [[ "$minor" -lt 12 ]]; }; then
  echo "AntiBot requires Node >=22.12.0. Found: $node_ver"
  echo "In WSL: nvm install 22 && nvm use 22"
  exit 1
fi
