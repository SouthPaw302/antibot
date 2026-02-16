#!/usr/bin/env bash
set -euo pipefail
export NVM_DIR="${HOME}/.nvm"
# shellcheck source=/dev/null
[[ -f "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"
nvm use 22 2>/dev/null || true
mkdir -p "${HOME}/.antibot"
[[ -f "${HOME}/.antibot/antibot.json" ]] || echo '{}' > "${HOME}/.antibot/antibot.json"
cd ~/projects/antibot-wsl
export ANTIBOT_STATE_DIR="${HOME}/.antibot"
exec node antibot.mjs gateway --port 18889
