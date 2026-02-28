import { describe, expect, it } from "vitest";
import {
  buildParseArgv,
  getFlagValue,
  getCommandPath,
  getPrimaryCommand,
  getPositiveIntFlagValue,
  getVerboseFlag,
  hasHelpOrVersion,
  hasFlag,
  shouldMigrateState,
  shouldMigrateStateFromPath,
} from "./argv.js";

describe("argv helpers", () => {
  it.each([
    {
      name: "help flag",
      argv: ["node", "atomicbot", "--help"],
      expected: true,
    },
    {
      name: "version flag",
      argv: ["node", "atomicbot", "-V"],
      expected: true,
    },
    {
      name: "normal command",
      argv: ["node", "atomicbot", "status"],
      expected: false,
    },
    {
      name: "root -v alias",
      argv: ["node", "atomicbot", "-v"],
      expected: true,
    },
    {
      name: "root -v alias with profile",
      argv: ["node", "atomicbot", "--profile", "work", "-v"],
      expected: true,
    },
    {
      name: "root -v alias with log-level",
      argv: ["node", "atomicbot", "--log-level", "debug", "-v"],
      expected: true,
    },
    {
      name: "subcommand -v should not be treated as version",
      argv: ["node", "atomicbot", "acp", "-v"],
      expected: false,
    },
    {
      name: "root -v alias with equals profile",
      argv: ["node", "atomicbot", "--profile=work", "-v"],
      expected: true,
    },
    {
      name: "subcommand path after global root flags should not be treated as version",
      argv: ["node", "atomicbot", "--dev", "skills", "list", "-v"],
      expected: false,
    },
  ])("detects help/version flags: $name", ({ argv, expected }) => {
    expect(hasHelpOrVersion(argv)).toBe(expected);
  });

  it.each([
    {
      name: "single command with trailing flag",
      argv: ["node", "atomicbot", "status", "--json"],
      expected: ["status"],
    },
    {
      name: "two-part command",
      argv: ["node", "atomicbot", "agents", "list"],
      expected: ["agents", "list"],
    },
    {
      name: "terminator cuts parsing",
      argv: ["node", "atomicbot", "status", "--", "ignored"],
      expected: ["status"],
    },
  ])("extracts command path: $name", ({ argv, expected }) => {
    expect(getCommandPath(argv, 2)).toEqual(expected);
  });

  it.each([
    {
      name: "returns first command token",
      argv: ["node", "atomicbot", "agents", "list"],
      expected: "agents",
    },
    {
      name: "returns null when no command exists",
      argv: ["node", "atomicbot"],
      expected: null,
    },
  ])("returns primary command: $name", ({ argv, expected }) => {
    expect(getPrimaryCommand(argv)).toBe(expected);
  });

  it.each([
    {
      name: "detects flag before terminator",
      argv: ["node", "atomicbot", "status", "--json"],
      flag: "--json",
      expected: true,
    },
    {
      name: "ignores flag after terminator",
      argv: ["node", "atomicbot", "--", "--json"],
      flag: "--json",
      expected: false,
    },
  ])("parses boolean flags: $name", ({ argv, flag, expected }) => {
    expect(hasFlag(argv, flag)).toBe(expected);
  });

  it.each([
    {
      name: "value in next token",
      argv: ["node", "atomicbot", "status", "--timeout", "5000"],
      expected: "5000",
    },
    {
      name: "value in equals form",
      argv: ["node", "atomicbot", "status", "--timeout=2500"],
      expected: "2500",
    },
    {
      name: "missing value",
      argv: ["node", "atomicbot", "status", "--timeout"],
      expected: null,
    },
    {
      name: "next token is another flag",
      argv: ["node", "atomicbot", "status", "--timeout", "--json"],
      expected: null,
    },
    {
      name: "flag appears after terminator",
      argv: ["node", "atomicbot", "--", "--timeout=99"],
      expected: undefined,
    },
  ])("extracts flag values: $name", ({ argv, expected }) => {
    expect(getFlagValue(argv, "--timeout")).toBe(expected);
  });

  it("parses verbose flags", () => {
    expect(getVerboseFlag(["node", "atomicbot", "status", "--verbose"])).toBe(true);
    expect(getVerboseFlag(["node", "atomicbot", "status", "--debug"])).toBe(false);
    expect(getVerboseFlag(["node", "atomicbot", "status", "--debug"], { includeDebug: true })).toBe(
      true,
    );
  });

  it.each([
    {
      name: "missing flag",
      argv: ["node", "atomicbot", "status"],
      expected: undefined,
    },
    {
      name: "missing value",
      argv: ["node", "atomicbot", "status", "--timeout"],
      expected: null,
    },
    {
      name: "valid positive integer",
      argv: ["node", "atomicbot", "status", "--timeout", "5000"],
      expected: 5000,
    },
    {
      name: "invalid integer",
      argv: ["node", "atomicbot", "status", "--timeout", "nope"],
      expected: undefined,
    },
  ])("parses positive integer flag values: $name", ({ argv, expected }) => {
    expect(getPositiveIntFlagValue(argv, "--timeout")).toBe(expected);
  });

  it("builds parse argv from raw args", () => {
    const cases = [
      {
        rawArgs: ["node", "atomicbot", "status"],
        expected: ["node", "atomicbot", "status"],
      },
      {
        rawArgs: ["node-22", "atomicbot", "status"],
        expected: ["node-22", "atomicbot", "status"],
      },
      {
        rawArgs: ["node-22.2.0.exe", "atomicbot", "status"],
        expected: ["node-22.2.0.exe", "atomicbot", "status"],
      },
      {
        rawArgs: ["node-22.2", "atomicbot", "status"],
        expected: ["node-22.2", "atomicbot", "status"],
      },
      {
        rawArgs: ["node-22.2.exe", "atomicbot", "status"],
        expected: ["node-22.2.exe", "atomicbot", "status"],
      },
      {
        rawArgs: ["/usr/bin/node-22.2.0", "atomicbot", "status"],
        expected: ["/usr/bin/node-22.2.0", "atomicbot", "status"],
      },
      {
        rawArgs: ["nodejs", "atomicbot", "status"],
        expected: ["nodejs", "atomicbot", "status"],
      },
      {
        rawArgs: ["node-dev", "atomicbot", "status"],
        expected: ["node", "atomicbot", "node-dev", "atomicbot", "status"],
      },
      {
        rawArgs: ["atomicbot", "status"],
        expected: ["node", "atomicbot", "status"],
      },
      {
        rawArgs: ["bun", "src/entry.ts", "status"],
        expected: ["bun", "src/entry.ts", "status"],
      },
    ] as const;

    for (const testCase of cases) {
      const parsed = buildParseArgv({
        programName: "atomicbot",
        rawArgs: [...testCase.rawArgs],
      });
      expect(parsed).toEqual([...testCase.expected]);
    }
  });

  it("builds parse argv from fallback args", () => {
    const fallbackArgv = buildParseArgv({
      programName: "atomicbot",
      fallbackArgv: ["status"],
    });
    expect(fallbackArgv).toEqual(["node", "atomicbot", "status"]);
  });

  it("decides when to migrate state", () => {
    const nonMutatingArgv = [
      ["node", "atomicbot", "status"],
      ["node", "atomicbot", "health"],
      ["node", "atomicbot", "sessions"],
      ["node", "atomicbot", "config", "get", "update"],
      ["node", "atomicbot", "config", "unset", "update"],
      ["node", "atomicbot", "models", "list"],
      ["node", "atomicbot", "models", "status"],
      ["node", "atomicbot", "memory", "status"],
      ["node", "atomicbot", "agent", "--message", "hi"],
    ] as const;
    const mutatingArgv = [
      ["node", "atomicbot", "agents", "list"],
      ["node", "atomicbot", "message", "send"],
    ] as const;

    for (const argv of nonMutatingArgv) {
      expect(shouldMigrateState([...argv])).toBe(false);
    }
    for (const argv of mutatingArgv) {
      expect(shouldMigrateState([...argv])).toBe(true);
    }
  });

  it.each([
    { path: ["status"], expected: false },
    { path: ["config", "get"], expected: false },
    { path: ["models", "status"], expected: false },
    { path: ["agents", "list"], expected: true },
  ])("reuses command path for migrate state decisions: $path", ({ path, expected }) => {
    expect(shouldMigrateStateFromPath(path)).toBe(expected);
  });
});
