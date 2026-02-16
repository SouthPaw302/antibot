# AntiBot — Daily Runbook and Failure Triage

Use this from a **single WSL (Ubuntu) terminal**. All commands assume Node ≥22.12 (use `nvm use 22` or source `scripts/antibot-env.sh`).

---

## Canonical daily startup

Run from the **repo root** (WSL-native path recommended, e.g. `~/projects/antibot` or `~/projects/antibot-wsl`):

```bash
# 1) Ensure Node 22 (required)
. scripts/antibot-env.sh

# 2) Start Ollama if you use local models
ollama serve &
# Optional: ensure model exists
# ollama run lume-llama-unbound "hello"

# 3) Start gateway + dashboard (creates minimal config if missing)
./scripts/antibot-local
```

Then open **http://127.0.0.1:18889/** in your browser. The launcher creates `~/.antibot/antibot.json` with `gateway.mode: "local"` if missing.

**Manual gateway start (same shell):**

```bash
. scripts/antibot-env.sh
export ANTIBOT_STATE_DIR="${ANTIBOT_STATE_DIR:-$HOME/.antibot}"
node antibot.mjs gateway --port 18889
```

Gateway may take **15–20 seconds** before the dashboard responds.

---

## Failure triage checklist

If the dashboard does not load or the gateway fails to start, check in order:

| Check | What to do |
|-------|------------|
| **Node version** | Run `node -v`. Must be **≥22.12**. If not: `nvm use 22` or `. scripts/antibot-env.sh`. |
| **Working directory** | Run from **repo root** (where `antibot.mjs` and `dist/entry.js` exist). `cd` there before starting the gateway. |
| **Config / mode** | Ensure `~/.antibot/antibot.json` has `"gateway": { "mode": "local" }`. Run `./scripts/antibot-local` once to create it, or add it manually. |
| **Port 18889** | Nothing else should listen on 18889. Check with `ss -tlnp` and look for 18889 (or `netstat -tlnp`). Kill the process or use `--port` for another port. |
| **Ollama (if using local models)** | Ollama must be reachable at **http://127.0.0.1:11434**. Run `ollama serve` in the background; then `ollama list` and `ollama run lume-llama-unbound "hi"` to confirm. |

**Useful logs**

- Gateway: `/tmp/antibot-gateway.log` (when started via `antibot-local`) or stdout if run in foreground.
- Ollama: `ollama serve` stdout or `/tmp/ollama-serve.log` if started with `nohup ollama serve >/tmp/ollama-serve.log 2>&1 &`.

**One-time bring-up verification**

From repo root, after `pnpm build` and `pnpm ui:build`:

```bash
. scripts/antibot-env.sh
bash scripts/antibot-bringup-verify.sh
```

This starts the gateway with `--allow-unconfigured` on 18889, checks the dashboard HTTP response, then exits. Use it to confirm Node, artifacts, and port without relying on existing config.
