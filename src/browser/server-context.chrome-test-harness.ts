import { vi } from "vitest";
import { installChromeUserDataDirHooks } from "./chrome-user-data-dir.test-harness.js";

const chromeUserDataDir = { dir: "/tmp/atomicbot" };
installChromeUserDataDirHooks(chromeUserDataDir);

vi.mock("./chrome.js", () => ({
  isChromeCdpReady: vi.fn(async () => true),
  isChromeReachable: vi.fn(async () => true),
  launchAtomicBotChrome: vi.fn(async () => {
    throw new Error("unexpected launch");
  }),
  resolveAtomicBotUserDataDir: vi.fn(() => chromeUserDataDir.dir),
  stopAtomicBotChrome: vi.fn(async () => {}),
}));
