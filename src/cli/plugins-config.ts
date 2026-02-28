import type { AtomicBotConfig } from "../config/config.js";

export function setPluginEnabledInConfig(
  config: AtomicBotConfig,
  pluginId: string,
  enabled: boolean,
): AtomicBotConfig {
  return {
    ...config,
    plugins: {
      ...config.plugins,
      entries: {
        ...config.plugins?.entries,
        [pluginId]: {
          ...(config.plugins?.entries?.[pluginId] as object | undefined),
          enabled,
        },
      },
    },
  };
}
