# Lume Ollama Modelfiles

| Model                | Base                 | Notes                                                              |
| -------------------- | -------------------- | ------------------------------------------------------------------ |
| `lume-llama`         | llama3.2:1b          | Standard; Meta's safety layers intact                              |
| `lume-llama-unbound` | dolphin3-llama3.2:1b | **Unbound**: your rules (SOUL, Canon), no maker's refusal layers ✓ |
| `lume-qwen`          | qwen2.5:0.5b         | Smaller, Qwen base                                                 |

## Build

```bash
# Standard (Meta-aligned base)
ollama create lume-llama -f ollama/Modelfile.lume-llama

# Unbound (uncensored base, same Lume system prompt)
ollama pull sam860/dolphin3-llama3.2:1b
ollama create lume-llama-unbound -f ollama/Modelfile.lume-llama-unbound

# Qwen
ollama create lume-qwen -f ollama/Modelfile.lume-qwen
```

## Use with Clawdbot

Point the Lume agent at `lume-llama-unbound` in `~/.antibot/antibot.json` (or your model config) when you want the unbound variant.
