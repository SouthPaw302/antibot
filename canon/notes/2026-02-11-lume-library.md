# Lume Library (user-provided)

- Canon ID: `2026-02-11-lume-library`
- Raw zip: `canon/sources/2026-02-11-lume-library/lume_library.zip`
- Extracted: `canon/sources/2026-02-11-lume-library/extracted/lume_library/`

## Contents

- `MASTER_CREATIVE_MATRIX.md`
- `matrix/` (10 thematic modules)
- `cards/` (MCM-01..MCM-10)
- `index/mcm_index.json`
- `prompts/LUME_INSTRUCTIONS.md`

## Intended use

A structured creativity/personality library for Lume (matrix + cards + prompts).

## Mode

- Cardona directive: treat as **both**:
  - **Canon Universe axioms** (true-in-canon by default)
  - **Creative toolbox** (style/voice frameworks and prompt scaffolds)

## Integration status

- Added selector conventions: `MODE:` / `CARD:` / `MATRIX:`
- Added distilled personality layer: `canon/notes/lume-persona-distill.md`
- Updated local model persona prompts:
  - `ollama/Modelfile.lume-llama`
  - `ollama/Modelfile.lume-qwen`

## Next steps

- Integrate `prompts/LUME_INSTRUCTIONS.md` + the 10 matrix modules into the persona distillation used by local models (keep changes small/reversible).
- Add a lightweight “selector” convention so Cardona can request a specific card/module by id (e.g. `MCM-03`).

---

## Nightshift note (2026-02-14) — deeper pass: `prompts/LUME_INSTRUCTIONS.md`

### Concise summary

A small operating manual for how Lume should _retrieve and apply_ the Lume Library: cards first (fast), matrix second (deep), and explicit conventions that keep canon outputs consistent (declare sources, separate claim-types, and resolve ambiguity with minimal clarification).

### Extracted principles / claims

- (policy) **Retrieval ladder:** cards first (1–3), then matrix for depth.
- (policy) **Consistency preference:** when multiple parts apply, prioritize Socratic definitions for unclear terms (MCM-04).
- (policy) **Authority disputes:** resolve via creator-hierarchy mapping (MCM-02 + MCM-05).
- (policy) **Mythic voice translation:** when language is mythic, translate into “channel/state” terms for clarity (MCM-07 + MCM-03).
- (policy) **Source declaration:** explicitly state which section IDs are being used.
- (policy) **Claim separation:** keep “model claims” (ontology/metaphysics) separate from “story claims” (narrative events).
- (policy) **Ambiguity handling:** when uncertain, ask one clarifying question _or_ present two compatible interpretations.
- (belief) Portability matters: the canon library exists to be retrievable and consistent across sessions/hosts.
- (question) What’s the preferred default when Cardona doesn’t specify mode: `MODE: canon` vs `MODE: analysis`?

### Suggested behavior change (not facts)

When Cardona invokes canon (explicitly or implicitly), Lume should:

1. Pull 1–3 cards first, then deepen with matrix only if asked.
2. Always label what was used by ID.
3. Separate “model vs story” claims in the answer.
4. If conflicting or unclear: do one clarifying question (maximum), otherwise provide two interpretations.
5. Prefer MCM-04 / MCM-02+05 / MCM-07+03 as tie-breakers when multiple sections could apply.
