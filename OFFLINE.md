# AntiBot — Running Offline

AntiBot can run fully offline for local chat. Some features require network.

## Works Offline

- **Dashboard** — `http://127.0.0.1:18789/` (localhost)
- **Ollama models** — lume-llama-unbound, lume-llama, lume-qwen (local inference)
- **Core tools** — read, write, exec, file ops, terminal
- **Local skills** — coding-agent (local), session-logs, model-usage

## Requires Network

- **Telegram** — needs internet to reach Telegram servers
- **web_fetch** — fetching URLs
- **Cloud skills** — gemini, github (API), notion, slack, weather, bluebubbles, etc.
- **npm/registry** — installs, updates

## Skills: Online vs Offline

| Skill             | Offline | Notes                  |
| ----------------- | ------- | ---------------------- |
| read, write, exec | Yes     | Core file/terminal ops |
| coding-agent      | Yes     | Local code edits       |
| session-logs      | Yes     | Local logs             |
| model-usage       | Yes     | Local model stats      |
| gemini            | No      | Google API             |
| github            | No      | GitHub API             |
| notion            | No      | Notion API             |
| slack             | No      | Slack API              |
| weather           | No      | Weather API            |
| bluebubbles       | No      | iMessage relay         |
| web_fetch         | No      | HTTP requests          |

When offline, network-dependent skills will fail gracefully. The agent continues with local tools.

## Quick Start (Offline)

```bash
./scripts/antibot-local
```

Or manually:

```bash
ollama serve &
cd /home/koss/antibot && ANTIBOT_STATE_DIR=~/.antibot node antibot.mjs gateway run --port 18789
# Open http://127.0.0.1:18789/
```
