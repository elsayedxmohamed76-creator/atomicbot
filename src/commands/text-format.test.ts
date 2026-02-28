import { describe, expect, it } from "vitest";
import { shortenText } from "./text-format.js";

describe("shortenText", () => {
  it("returns original text when it fits", () => {
    expect(shortenText("atomicbot", 16)).toBe("atomicbot");
  });

  it("truncates and appends ellipsis when over limit", () => {
    expect(shortenText("atomicbot-status-output", 10)).toBe("atomicbot-…");
  });

  it("counts multi-byte characters correctly", () => {
    expect(shortenText("hello🙂world", 7)).toBe("hello🙂…");
  });
});
