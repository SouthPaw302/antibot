import type { OpenClawConfig } from "../config/config.js";
import type { ApplyAuthChoiceParams, ApplyAuthChoiceResult } from "./auth-choice.apply.js";
import { upsertSharedEnvVar } from "../infra/env-file.js";
import { shortenHomePath } from "../utils.js";

const OLLAMA_LOCAL_KEY = "ollama-local";
const DEFAULT_OLLAMA_MODEL = "lume-llama-unbound";

export async function applyAuthChoiceOllama(
  params: ApplyAuthChoiceParams,
): Promise<ApplyAuthChoiceResult | null> {
  if (params.authChoice !== "ollama") {
    return null;
  }

  const result = upsertSharedEnvVar({ key: "OLLAMA_API_KEY", value: OLLAMA_LOCAL_KEY });
  params.runtime.log(`Saved OLLAMA_API_KEY to ${shortenHomePath(result.path)}`);

  let nextConfig: OpenClawConfig = {
    ...params.config,
    env: {
      ...params.config.env,
      vars: {
        ...params.config.env?.vars,
        OLLAMA_API_KEY: OLLAMA_LOCAL_KEY,
      },
    },
  };

  if (params.setDefaultModel) {
    nextConfig = {
      ...nextConfig,
      agents: {
        ...nextConfig.agents,
        defaults: {
          ...nextConfig.agents?.defaults,
          model: {
            ...nextConfig.agents?.defaults?.model,
            primary: `ollama/${DEFAULT_OLLAMA_MODEL}`,
          },
        },
      },
    };
  }

  return { config: nextConfig };
}
