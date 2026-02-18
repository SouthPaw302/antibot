# AntiBot — Daily Runbook and Failure Triage

Use this from a **single WSL (Ubuntu) terminal**. All commands assume Node ≥22.12 (use `nvm use 22` or source `scripts/antibot-env.sh`).

**If you cloned or copied the repo from Windows:** run `pnpm install` **inside WSL** so native deps (e.g. esbuild) get Linux binaries. Using a Windows-installed `node_modules` in WSL causes "wrong platform" errors.

---

## Startup order (required)

Start services **in this order** or the gateway will time out talking to the model:

1. **WSL** — terminal/session running.
2. **Ollama** — `ollama serve` (or already running).
3. **Model** — load `lume-llama-unbound` once so it’s in memory:  
   `ollama run lume-llama-unbound "hi"` (then Ctrl+C or wait for reply).
4. **Gateway** — only after 1–3 are up: start the AntiBot gateway.

If you start the gateway before the model is loaded, the first chat request can time out.

---

## Canonical daily startup (full)

Run from the **repo root** (WSL path e.g. `~/projects/antibot` or `~/projects/antibot-wsl`):

```bash
# 1) Ensure Node 22 (required)
. scripts/antibot-env.sh

# 2) Start Ollama (if not already running)
ollama serve &

# 3) Load the model so it’s ready (required before gateway chat)
ollama run lume-llama-unbound "hi"
# Wait for a reply or Ctrl+C once it starts; model stays loaded.

# 4) Start gateway + dashboard (creates minimal config if missing)
./scripts/antibot-local
```

Then open the dashboard URL in your browser. The launcher prints a URL that may include the gateway token (e.g. `http://127.0.0.1:18889/#token=...`) so you don’t have to paste it. If no token is configured, use `http://127.0.0.1:18889/`. The launcher creates `~/.antibot/antibot.json` with `gateway.mode: "local"` if missing.

---

## Clean start (connection refused or stuck)

If you see **connection refused** or the dashboard never loads, stop everything and start clean from **repo root** in WSL:

```bash
# 1) Stop any gateway process
./scripts/antibot-gateway-stop.sh

# 2) Optional: clear the gateway log to see fresh output
rm -f /tmp/antibot-gateway.log

# 3) Start clean (Ollama + gateway + dashboard URL)
./scripts/antibot-local
```

Then wait **15–20 seconds** and open the printed URL. If it still fails, run the gateway in the foreground in a **second** WSL terminal to see errors:  
`cd /mnt/c/Projects/antibot && . scripts/antibot-env.sh && node antibot.mjs gateway --port 18889`

---

## Restart gateway only

When **WSL, Ollama, and the model are already running**, only restart the gateway:

From **repo root**:

```bash
. scripts/antibot-env.sh
export ANTIBOT_STATE_DIR="${ANTIBOT_STATE_DIR:-$HOME/.antibot}"

# Kill existing gateway on 18889
pkill -f "antibot.mjs gateway.*18889" || true
sleep 2

# Start gateway (foreground or background)
node antibot.mjs gateway --port 18889
# Or: nohup node antibot.mjs gateway --port 18889 >/tmp/antibot-gateway.log 2>&1 &
```

Or run the helper script from repo root: `./scripts/antibot-gateway-restart.sh` (it prints the dashboard URL; if a gateway token is in config or env, the URL includes `#token=...` so you can open it without pasting the token).

**Manual gateway start (foreground, same shell):**

```bash
. scripts/antibot-env.sh
export ANTIBOT_STATE_DIR="${ANTIBOT_STATE_DIR:-$HOME/.antibot}"
node antibot.mjs gateway --port 18889
```

Gateway may take **15–20 seconds** before the dashboard responds.

**Verify startup:** After running `./scripts/antibot-local` or `./scripts/antibot-gateway-restart.sh`, check `/tmp/antibot-gateway.log` for startup messages and run `curl -s http://127.0.0.1:18889/` — a response means the gateway is up.

### Local model (Ollama) first response

- **First inference** with `lume-llama-unbound` can take **30–90 seconds** on CPU while the model loads (~1.2GB into memory). Subsequent requests are much faster.
- `./scripts/antibot-local` pre-warms the model in the background and sets `OLLAMA_KEEP_ALIVE=-1` so the model stays loaded.
- To keep the model in memory when starting Ollama yourself: `export OLLAMA_KEEP_ALIVE=-1` before `ollama serve`, or use e.g. `OLLAMA_KEEP_ALIVE=30m` to keep it loaded for 30 minutes.

---

## Failure triage checklist

If the dashboard does not load or the gateway fails to start, check in order:

| Check | What to do |
|-------|------------|
| **Node version** | Run `node -v`. Must be **≥22.12**. If not: `nvm use 22` or `. scripts/antibot-env.sh`. |
| **Working directory** | Run from **repo root** (where `antibot.mjs` and `dist/entry.js` exist). `cd` there before starting the gateway. |
| **Config / mode** | Ensure `~/.antibot/antibot.json` has `"gateway": { "mode": "local" }`. Run `./scripts/antibot-local` once to create it, or add it manually. |
| **Port 18889** | Nothing else should listen on 18889. Check with `ss -tlnp` and look for 18889 (or `netstat -tlnp`). Kill the process or use `--port` for another port. |
| **Ollama (if using local models)** | Ollama must be reachable at **http://127.0.0.1:11434**. Run `ollama serve` in the background; then `ollama list` and `ollama run lume-llama-unbound "hi"` to confirm. If the first chat reply never appears, wait 60–90s (model load) or pre-warm with `ollama run lume-llama-unbound "hi"`. |

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
