# SECOND_BRAIN

This folder is a machine-readable mirror of Clawdbot conversation history + an inbox for notes.

## What’s in here

- `transcripts/` — JSONL transcripts mirrored from Clawdbot’s canonical session store:
  - Source: `~/.clawdbot/agents/main/sessions/*.jsonl`
  - Mirror: `SECOND_BRAIN/transcripts/`

- `notes/inbox.jsonl` — append-only notes you send (NOTE/TODO/IDEA/REMIND).

- `state/` — exporter state (last run timestamps, hashes).

## Export/update

Run:

```bash
python3 /home/koss/clawd/scripts/secondary_brain_export.py
```

This copies any new/changed `*.jsonl` session files into `SECOND_BRAIN/transcripts/` and writes/updates `SECOND_BRAIN/transcripts/index.json`.

## Notes format

Each line in `notes/inbox.jsonl` is a JSON object.

Example:

```json
{
  "ts": "2026-02-14T21:51:00-05:00",
  "kind": "NOTE",
  "text": "buy batteries",
  "source": { "channel": "telegram" }
}
```
