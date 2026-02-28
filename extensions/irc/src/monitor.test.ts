import { describe, expect, it } from "vitest";
import { resolveIrcInboundTarget } from "./monitor.js";

describe("irc monitor inbound target", () => {
  it("keeps channel target for group messages", () => {
    expect(
      resolveIrcInboundTarget({
        target: "#atomicbot",
        senderNick: "alice",
      }),
    ).toEqual({
      isGroup: true,
      target: "#atomicbot",
      rawTarget: "#atomicbot",
    });
  });

  it("maps DM target to sender nick and preserves raw target", () => {
    expect(
      resolveIrcInboundTarget({
        target: "atomicbot-bot",
        senderNick: "alice",
      }),
    ).toEqual({
      isGroup: false,
      target: "alice",
      rawTarget: "atomicbot-bot",
    });
  });

  it("falls back to raw target when sender nick is empty", () => {
    expect(
      resolveIrcInboundTarget({
        target: "atomicbot-bot",
        senderNick: " ",
      }),
    ).toEqual({
      isGroup: false,
      target: "atomicbot-bot",
      rawTarget: "atomicbot-bot",
    });
  });
});
