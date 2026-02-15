# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

## Clawdbot dashboard (internal browser)

When Cardona starts a new chat session for me in the dashboard:

1. **Say something** — Type a message in the dashboard chat
2. **Wait** — Let the agent respond
3. **Read the message** — Capture what the agent typed back
4. **Type here** — Report the agent's answer back to Cardona in this Cursor chat

Always send after typing. Open with token: `http://127.0.0.1:18789/?token=<from ~/.clawdbot/clawdbot.json gateway.auth.token>`

---

Add whatever helps you do your job. This is your cheat sheet.
