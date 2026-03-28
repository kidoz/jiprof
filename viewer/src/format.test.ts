import { describe, it, expect } from "vitest";
import {
  formatMs,
  formatInt,
  formatSignedMs,
  formatSignedInt,
  escapeHtml,
  toLocalHref,
  deltaClass,
  colorForName,
} from "./format";

describe("formatMs", () => {
  it("converts nanoseconds to milliseconds", () => {
    expect(formatMs(1_000_000)).toBe("1.000 ms");
    expect(formatMs(1_500_000)).toBe("1.500 ms");
    expect(formatMs(0)).toBe("0.000 ms");
  });

  it("handles large values", () => {
    expect(formatMs(123_456_789_000)).toBe("123456.789 ms");
  });
});

describe("formatInt", () => {
  it("formats integers with locale grouping", () => {
    expect(formatInt(0)).toBe("0");
    expect(formatInt(42)).toBe("42");
  });

  it("handles negative values", () => {
    const result = formatInt(-5);
    expect(result).toContain("5");
  });
});

describe("formatSignedMs", () => {
  it("adds plus sign for positive values", () => {
    expect(formatSignedMs(1_000_000)).toBe("+1.000 ms");
  });

  it("adds minus sign for negative values", () => {
    expect(formatSignedMs(-1_000_000)).toBe("-1.000 ms");
  });

  it("shows no sign for zero", () => {
    expect(formatSignedMs(0)).toBe("0.000 ms");
  });
});

describe("formatSignedInt", () => {
  it("adds plus sign for positive values", () => {
    expect(formatSignedInt(5)).toBe("+5");
  });

  it("adds minus sign for negative values", () => {
    expect(formatSignedInt(-5)).toBe("-5");
  });

  it("shows no sign for zero", () => {
    expect(formatSignedInt(0)).toBe("0");
  });
});

describe("escapeHtml", () => {
  it("escapes ampersand", () => {
    expect(escapeHtml("a&b")).toBe("a&amp;b");
  });

  it("escapes angle brackets", () => {
    expect(escapeHtml("<div>")).toBe("&lt;div&gt;");
  });

  it("escapes double quotes", () => {
    expect(escapeHtml('"hello"')).toBe("&quot;hello&quot;");
  });

  it("handles clean strings", () => {
    expect(escapeHtml("hello world")).toBe("hello world");
  });

  it("escapes all special characters together", () => {
    expect(escapeHtml('<a href="x&y">')).toBe("&lt;a href=&quot;x&amp;y&quot;&gt;");
  });
});

describe("toLocalHref", () => {
  it("returns empty string for empty input", () => {
    expect(toLocalHref("")).toBe("");
  });

  it("preserves URLs with scheme", () => {
    expect(toLocalHref("https://example.com/file")).toBe("https://example.com/file");
  });

  it("converts Unix absolute paths to file:// URLs", () => {
    expect(toLocalHref("/tmp/profile.json")).toBe("file:///tmp/profile.json");
  });

  it("converts Windows absolute paths to file:/// URLs", () => {
    expect(toLocalHref("C:\\Users\\test\\file.json")).toBe("file:///C:\\Users\\test\\file.json");
  });

  it("returns relative paths unchanged", () => {
    expect(toLocalHref("output/file.json")).toBe("output/file.json");
  });
});

describe("deltaClass", () => {
  it("returns delta-positive for positive values", () => {
    expect(deltaClass(1)).toBe("delta-positive");
  });

  it("returns delta-negative for negative values", () => {
    expect(deltaClass(-1)).toBe("delta-negative");
  });

  it("returns muted for zero", () => {
    expect(deltaClass(0)).toBe("muted");
  });
});

describe("colorForName", () => {
  it("returns an hsl color string", () => {
    const color = colorForName("test.Method", 0);
    expect(color).toMatch(/^hsl\(\d+ 58% \d+%\)$/);
  });

  it("returns consistent colors for the same input", () => {
    expect(colorForName("foo", 0)).toBe(colorForName("foo", 0));
  });

  it("varies by depth", () => {
    expect(colorForName("foo", 0)).not.toBe(colorForName("foo", 3));
  });

  it("decreases lightness with depth", () => {
    const shallow = colorForName("method", 0);
    const deep = colorForName("method", 5);
    const lightShallow = parseInt(shallow.match(/(\d+)%\)$/)![1]!);
    const lightDeep = parseInt(deep.match(/(\d+)%\)$/)![1]!);
    expect(lightShallow).toBeGreaterThanOrEqual(lightDeep);
  });
});
