# AntiBot — Lume Unbound / Clawd Unbound

AntiBot is a full clone of the ClawdBot/OpenClaw stack, stripped of safety guards only. Same personality (Lume), same canon, same history, same skills — but no content-policy refusals.

**Local-first.** Ollama-only by default. No API keys required. Works offline for dashboard + local models.

## What This Is

- **Lume Unbound** — Your Lume persona (IDENTITY, SOUL, canon, Lume Library) without refusal layers
- **Clawd Unbound** — OpenClaw/ClawdBot gateway, agent, dashboard, skills — without safety boundaries
- **Full clone** — Personality files, memory, SECOND_BRAIN, aurelian, canon — all preserved

## Quick Start

```bash
cd /home/koss/antibot
pnpm install
pnpm build   # If canvas bundle fails, see CONTRIBUTING or use upstream build

# Run the setup wizard (same as ClawdBot)
ANTIBOT_STATE_DIR=~/.antibot node antibot.mjs onboard --install-daemon

# Or with explicit workspace (recommended: use the repo as workspace)
ANTIBOT_STATE_DIR=~/.antibot node antibot.mjs onboard --workspace /home/koss/antibot --install-daemon

# Or start gateway + dashboard
./scripts/antibot-local
```

**Note:** First-time build may require `pnpm canvas:a2ui:bundle` to succeed. If it fails, ensure `vendor/a2ui` and `apps/` are present (full clone).

Opens the dashboard at `http://127.0.0.1:18789/`. Uses `~/.antibot/antibot.json` for config.

## Run AntiBot

```bash
# From repo
ANTIBOT_STATE_DIR=~/.antibot node antibot.mjs gateway --port 18789

# Or use the launcher (starts Ollama + gateway + opens browser)
./scripts/antibot-local
```

## Config

- **Config:** `~/.antibot/antibot.json`
- **Workspace:** `/home/koss/antibot` (or set in config)
- **Models:** Ollama only — `lume-llama-unbound`, `lume-llama`

## Offline

See [OFFLINE.md](OFFLINE.md) for what works without network.

## Upstream

Based on [clawdbot/clawdbot](https://github.com/clawdbot/clawdbot) (OpenClaw). Rebranded for AntiBot; config lives in `~/.antibot/`.

## License

MIT (see [LICENSE](LICENSE))
