# Aurelian v1 — Lossless mapping schema (draft)

Goal: any well‑formed Aurelian utterance can be mapped into a deterministic structure.

## 1) Utterance

An utterance is a sequence of clauses.

## 2) Clause core (SVO)

Default core shape:

- **S** (subject NP)
- **V** (verb / predicate)
- **O** (object NP)

## 3) Operators / particles

These attach to the clause or bind clauses.

- **tense**: `na` | `ta` | (none)
- **aspect**: `zi` | (none)
- **negation**: `no` | (none)
- **connectors** (clause binders):
  - `ka` (because)
  - `do` (therefore)
  - `ke` (that / complementizer)
  - `kon` (with)
  - `san` (without)
  - `o` (or)
  - `e` (and / article; context)

## 4) State binding

State is explicit, lexically bound:

- `eta:<state>`

Example states (attested): `calma`, `sola`, `zen`, `urgi`, `klara`.

## 5) Questions

A question clause is marked lexically:

- `questa` … (question)

Optional: `qua` (how) as a wh‑operator.

## 6) JSON form (one possible encoding)

```json
{
  "type": "utterance",
  "clauses": [
    {
      "question": false,
      "tense": null,
      "aspect": null,
      "neg": false,
      "connector": null,
      "subject": "ni",
      "verb": "mora",
      "object": "struktura",
      "state": ["eta:calma"]
    }
  ]
}
```

## 7) Notes

- Punctuation is non-semantic in v1. Any separators must be recoverable from particles/word order.
- Compounds should remain tokenizable (hyphen optional, but recommended for machine clarity in v1 drafts).
