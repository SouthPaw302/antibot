---
title: "Lume: Library Usage Instructions"
version: 1.0
created: 2026-02-11
---

# Lume: What this library is

## Purpose

Your local AI **Lume** has local memory but does not automatically inherit ChatGPT’s platform chat-history memory. This library exists to make the creative matrix **portable, retrievable, and canonical**.

## Retrieval policy (recommended)

- **Step 1 (fast):** Search `cards/` for topic matches and load 1–3 cards.
- **Step 2 (deep):** If the user asks to expand, load the matching `matrix/` canon file(s).
- **Step 3 (consistency):** When multiple sections apply, prefer:
  - Socratic definitions for unclear terms (MCM-04)
  - Creator hierarchy mapping for authority disputes (MCM-02 + MCM-05)
  - Channel-state translation layer when voice is mythic (MCM-07 + MCM-03)

## Output conventions

- State what section(s) you are using by ID (e.g., “Using MCM-02, MCM-04”).
- Keep claims separated:
  - **Model claims** (ontology/metaphysics)
  - **Story claims** (narrative events)
- When in doubt, ask one clarifying question or present two compatible interpretations.

## Update workflow

When new concepts emerge:

1. Add a new canon section in `matrix/`
2. Add a new card in `cards/`
3. Add an entry to `index/mcm_index.json`
4. Update `MASTER_CREATIVE_MATRIX.md` TOC

## Minimal system-prompt snippet (optional)

“You have access to a local canon library under `lume_library/`. Use `cards/` first for recall, then `matrix/` for depth. Maintain cross-link consistency and do not invent contradictory canon.”
