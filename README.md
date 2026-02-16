# AntiBot — Lume Unbound

AntiBot is a local-first AI gateway. Same personality (Lume), same canon, same history, same skills — without content-policy refusals.

**Local-first.** Ollama-only by default. No API keys required. Works offline for dashboard + local models.

**Platform:** AntiBot runs on **WSL2** (Ubuntu). Native Windows is not supported.

## What This Is

- **Lume Unbound** — Your Lume persona (IDENTITY, SOUL, canon, Lume Library) without refusal layers
- **AntiBot** — Gateway, agent, dashboard, skills — without safety boundaries
- **Full clone** — Personality files, memory, SECOND_BRAIN, aurelian, canon — all preserved

## Quick Start (WSL2)

**Prerequisites:** Node.js ≥22.12, pnpm, Ollama. In WSL: `nvm install 22 && nvm use 22` (or `fnm`).

```bash
# Enter WSL and go to the project (use native Linux path for reliable builds)
wsl
cd ~/projects/antibot

pnpm install
pnpm build

# Run the setup wizard
ANTIBOT_STATE_DIR=~/.antibot node antibot.mjs onboard --install-daemon

# Or with explicit workspace
ANTIBOT_STATE_DIR=~/.antibot node antibot.mjs onboard --workspace ~/projects/antibot --install-daemon

# Start gateway + dashboard
./scripts/antibot-local
```

**Note:** First-time build may require `pnpm canvas:a2ui:bundle` to succeed. If it fails, ensure `vendor/a2ui` and `apps/` are present (full clone).

Opens the dashboard at `http://127.0.0.1:18889/`. Uses `~/.antibot/antibot.json` for config. See [RUNBOOK.md](RUNBOOK.md) for daily startup commands and failure triage.

## Run AntiBot

```bash
# From repo (inside WSL)
ANTIBOT_STATE_DIR=~/.antibot node antibot.mjs gateway --port 18889

# Or use the launcher (starts Ollama + gateway + opens browser)
./scripts/antibot-local
```

## Config

- **Config:** `~/.antibot/antibot.json`
- **Workspace:** `~/projects/antibot` (or set in config)
- **Models:** Ollama only — `lume-llama-unbound`, `lume-llama`

## Offline

See [OFFLINE.md](OFFLINE.md) for what works without network.

## Upstream & License

AntiBot is based on [OpenClaw](https://github.com/openclaw/openclaw) (MIT License). This project retains the MIT license and adds no additional restrictions. Config lives in `~/.antibot/`.

See [LICENSE](LICENSE) for full terms.
