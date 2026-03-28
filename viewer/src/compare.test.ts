import { describe, it, expect } from "vitest";
import { computeDeltaRows, sumBy } from "./compare";

describe("computeDeltaRows", () => {
  it("computes deltas for matching items", () => {
    const current = [
      { name: "foo", value: 10 },
      { name: "bar", value: 5 },
    ];
    const baseline = [
      { name: "foo", value: 7 },
      { name: "bar", value: 8 },
    ];

    const rows = computeDeltaRows(
      current,
      baseline,
      (i) => i.name,
      (i) => i.value,
      (i) => i.value,
    );

    expect(rows).toHaveLength(2);
    const foo = rows.find((r) => r.key === "foo")!;
    expect(foo.delta).toBe(3);
    expect(foo.currentValue).toBe(10);
    expect(foo.baselineValue).toBe(7);

    const bar = rows.find((r) => r.key === "bar")!;
    expect(bar.delta).toBe(-3);
  });

  it("handles items only in current", () => {
    const current = [{ name: "new", value: 5 }];
    const baseline: { name: string; value: number }[] = [];

    const rows = computeDeltaRows(
      current,
      baseline,
      (i) => i.name,
      (i) => i.value,
      (i) => i.value,
    );

    expect(rows).toHaveLength(1);
    expect(rows[0]!.delta).toBe(5);
    expect(rows[0]!.baselineValue).toBe(0);
    expect(rows[0]!.baseline).toBeUndefined();
  });

  it("handles items only in baseline", () => {
    const current: { name: string; value: number }[] = [];
    const baseline = [{ name: "old", value: 3 }];

    const rows = computeDeltaRows(
      current,
      baseline,
      (i) => i.name,
      (i) => i.value,
      (i) => i.value,
    );

    expect(rows).toHaveLength(1);
    expect(rows[0]!.delta).toBe(-3);
    expect(rows[0]!.currentValue).toBe(0);
    expect(rows[0]!.current).toBeUndefined();
  });

  it("returns empty array for empty inputs", () => {
    const rows = computeDeltaRows(
      [],
      [],
      (i: { name: string }) => i.name,
      () => 0,
      () => 0,
    );
    expect(rows).toHaveLength(0);
  });
});

describe("sumBy", () => {
  it("sums values from items", () => {
    const items = [{ v: 1 }, { v: 2 }, { v: 3 }];
    expect(sumBy(items, (i) => i.v)).toBe(6);
  });

  it("returns 0 for empty array", () => {
    expect(sumBy([], () => 1)).toBe(0);
  });
});
