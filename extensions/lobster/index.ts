import type {
  AnyAgentTool,
  AtomicBotPluginApi,
  AtomicBotPluginToolFactory,
} from "../../src/plugins/types.js";
import { createLobsterTool } from "./src/lobster-tool.js";

export default function register(api: AtomicBotPluginApi) {
  api.registerTool(
    ((ctx) => {
      if (ctx.sandboxed) {
        return null;
      }
      return createLobsterTool(api) as AnyAgentTool;
    }) as AtomicBotPluginToolFactory,
    { optional: true },
  );
}
