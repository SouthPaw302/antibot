// Defaults for agent metadata when upstream does not supply them.
// AntiBot: local Ollama model (Lume Unbound). Override via agents.defaults.model.primary in config.
export const DEFAULT_PROVIDER = "ollama";
export const DEFAULT_MODEL = "lume-llama-unbound";
// Conservative fallback used when model metadata is unavailable.
export const DEFAULT_CONTEXT_TOKENS = 200_000;
