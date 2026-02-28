import path from "node:path";
import { describe, expect, it } from "vitest";
import { formatCliCommand } from "./command-format.js";
import { applyCliProfileEnv, parseCliProfileArgs } from "./profile.js";

describe("parseCliProfileArgs", () => {
  it("leaves gateway --dev for subcommands", () => {
    const res = parseCliProfileArgs([
      "node",
      "atomicbot",
      "gateway",
      "--dev",
      "--allow-unconfigured",
    ]);
    if (!res.ok) {
      throw new Error(res.error);
    }
    expect(res.profile).toBeNull();
    expect(res.argv).toEqual(["node", "atomicbot", "gateway", "--dev", "--allow-unconfigured"]);
  });

  it("still accepts global --dev before subcommand", () => {
    const res = parseCliProfileArgs(["node", "atomicbot", "--dev", "gateway"]);
    if (!res.ok) {
      throw new Error(res.error);
    }
    expect(res.profile).toBe("dev");
    expect(res.argv).toEqual(["node", "atomicbot", "gateway"]);
  });

  it("parses --profile value and strips it", () => {
    const res = parseCliProfileArgs(["node", "atomicbot", "--profile", "work", "status"]);
    if (!res.ok) {
      throw new Error(res.error);
    }
    expect(res.profile).toBe("work");
    expect(res.argv).toEqual(["node", "atomicbot", "status"]);
  });

  it("rejects missing profile value", () => {
    const res = parseCliProfileArgs(["node", "atomicbot", "--profile"]);
    expect(res.ok).toBe(false);
  });

  it.each([
    ["--dev first", ["node", "atomicbot", "--dev", "--profile", "work", "status"]],
    ["--profile first", ["node", "atomicbot", "--profile", "work", "--dev", "status"]],
  ])("rejects combining --dev with --profile (%s)", (_name, argv) => {
    const res = parseCliProfileArgs(argv);
    expect(res.ok).toBe(false);
  });
});

describe("applyCliProfileEnv", () => {
  it("fills env defaults for dev profile", () => {
    const env: Record<string, string | undefined> = {};
    applyCliProfileEnv({
      profile: "dev",
      env,
      homedir: () => "/home/peter",
    });
    const expectedStateDir = path.join(path.resolve("/home/peter"), ".atomicbot-dev");
    expect(env.ATOMICBOT_PROFILE).toBe("dev");
    expect(env.ATOMICBOT_STATE_DIR).toBe(expectedStateDir);
    expect(env.ATOMICBOT_CONFIG_PATH).toBe(path.join(expectedStateDir, "atomicbot.json"));
    expect(env.ATOMICBOT_GATEWAY_PORT).toBe("19001");
  });

  it("does not override explicit env values", () => {
    const env: Record<string, string | undefined> = {
      ATOMICBOT_STATE_DIR: "/custom",
      ATOMICBOT_GATEWAY_PORT: "19099",
    };
    applyCliProfileEnv({
      profile: "dev",
      env,
      homedir: () => "/home/peter",
    });
    expect(env.ATOMICBOT_STATE_DIR).toBe("/custom");
    expect(env.ATOMICBOT_GATEWAY_PORT).toBe("19099");
    expect(env.ATOMICBOT_CONFIG_PATH).toBe(path.join("/custom", "atomicbot.json"));
  });

  it("uses ATOMICBOT_HOME when deriving profile state dir", () => {
    const env: Record<string, string | undefined> = {
      ATOMICBOT_HOME: "/srv/atomicbot-home",
      HOME: "/home/other",
    };
    applyCliProfileEnv({
      profile: "work",
      env,
      homedir: () => "/home/fallback",
    });

    const resolvedHome = path.resolve("/srv/atomicbot-home");
    expect(env.ATOMICBOT_STATE_DIR).toBe(path.join(resolvedHome, ".atomicbot-work"));
    expect(env.ATOMICBOT_CONFIG_PATH).toBe(
      path.join(resolvedHome, ".atomicbot-work", "atomicbot.json"),
    );
  });
});

describe("formatCliCommand", () => {
  it.each([
    {
      name: "no profile is set",
      cmd: "atomicbot doctor --fix",
      env: {},
      expected: "atomicbot doctor --fix",
    },
    {
      name: "profile is default",
      cmd: "atomicbot doctor --fix",
      env: { ATOMICBOT_PROFILE: "default" },
      expected: "atomicbot doctor --fix",
    },
    {
      name: "profile is Default (case-insensitive)",
      cmd: "atomicbot doctor --fix",
      env: { ATOMICBOT_PROFILE: "Default" },
      expected: "atomicbot doctor --fix",
    },
    {
      name: "profile is invalid",
      cmd: "atomicbot doctor --fix",
      env: { ATOMICBOT_PROFILE: "bad profile" },
      expected: "atomicbot doctor --fix",
    },
    {
      name: "--profile is already present",
      cmd: "atomicbot --profile work doctor --fix",
      env: { ATOMICBOT_PROFILE: "work" },
      expected: "atomicbot --profile work doctor --fix",
    },
    {
      name: "--dev is already present",
      cmd: "atomicbot --dev doctor",
      env: { ATOMICBOT_PROFILE: "dev" },
      expected: "atomicbot --dev doctor",
    },
  ])("returns command unchanged when $name", ({ cmd, env, expected }) => {
    expect(formatCliCommand(cmd, env)).toBe(expected);
  });

  it("inserts --profile flag when profile is set", () => {
    expect(formatCliCommand("atomicbot doctor --fix", { ATOMICBOT_PROFILE: "work" })).toBe(
      "atomicbot --profile work doctor --fix",
    );
  });

  it("trims whitespace from profile", () => {
    expect(formatCliCommand("atomicbot doctor --fix", { ATOMICBOT_PROFILE: "  jbatomicbot  " })).toBe(
      "atomicbot --profile jbatomicbot doctor --fix",
    );
  });

  it("handles command with no args after atomicbot", () => {
    expect(formatCliCommand("atomicbot", { ATOMICBOT_PROFILE: "test" })).toBe(
      "atomicbot --profile test",
    );
  });

  it("handles pnpm wrapper", () => {
    expect(formatCliCommand("pnpm atomicbot doctor", { ATOMICBOT_PROFILE: "work" })).toBe(
      "pnpm atomicbot --profile work doctor",
    );
  });
});
