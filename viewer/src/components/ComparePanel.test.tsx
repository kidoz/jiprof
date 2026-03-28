import { describe, it, expect, afterEach } from "vitest";
import { render, screen } from "@testing-library/preact";
import { SnapshotContext, comparisonSnapshot } from "../context";
import { ComparePanel } from "./ComparePanel";
import { createTestSnapshot } from "../test-fixtures";
import type { SnapshotDocument } from "../types";

afterEach(() => {
  comparisonSnapshot.value = null;
});

function renderWithComparison(
  currentOverrides: Partial<SnapshotDocument> = {},
  baselineOverrides: Partial<SnapshotDocument> = {},
) {
  const current = createTestSnapshot(currentOverrides);
  const baseline = createTestSnapshot({
    snapshotLabel: "baseline-snapshot",
    ...baselineOverrides,
  });
  comparisonSnapshot.value = baseline;

  return render(
    <SnapshotContext.Provider value={current}>
      <ComparePanel />
    </SnapshotContext.Provider>,
  );
}

describe("ComparePanel", () => {
  it("renders nothing when no baseline is loaded", () => {
    const current = createTestSnapshot();
    const { container } = render(
      <SnapshotContext.Provider value={current}>
        <ComparePanel />
      </SnapshotContext.Provider>,
    );
    expect(container.innerHTML).toBe("");
  });

  it("renders comparison section headers", () => {
    renderWithComparison();
    expect(screen.getByText("Snapshot Compare")).toBeTruthy();
    expect(screen.getByText("Regression Candidates")).toBeTruthy();
    expect(screen.getByText("Improvements")).toBeTruthy();
    expect(screen.getAllByText("Allocation Delta").length).toBeGreaterThanOrEqual(1);
  });

  it("shows current and baseline labels", () => {
    renderWithComparison();
    expect(screen.getByText("test-snapshot")).toBeTruthy();
    expect(screen.getByText("baseline-snapshot")).toBeTruthy();
  });

  it("detects regressions when current is slower", () => {
    renderWithComparison(
      {
        methodSummary: [
          {
            name: "slow.Method:work",
            className: "slow.Method",
            methodName: "work",
            count: 1,
            totalTimeNanos: 10_000_000,
            netTimeNanos: 10_000_000,
          },
        ],
      },
      {
        methodSummary: [
          {
            name: "slow.Method:work",
            className: "slow.Method",
            methodName: "work",
            count: 1,
            totalTimeNanos: 2_000_000,
            netTimeNanos: 2_000_000,
          },
        ],
      },
    );

    expect(screen.getAllByText("slow.Method:work").length).toBeGreaterThanOrEqual(1);
  });

  it("detects improvements when current is faster", () => {
    renderWithComparison(
      {
        methodSummary: [
          {
            name: "fast.Method:run",
            className: "fast.Method",
            methodName: "run",
            count: 1,
            totalTimeNanos: 1_000_000,
            netTimeNanos: 1_000_000,
          },
        ],
      },
      {
        methodSummary: [
          {
            name: "fast.Method:run",
            className: "fast.Method",
            methodName: "run",
            count: 1,
            totalTimeNanos: 5_000_000,
            netTimeNanos: 5_000_000,
          },
        ],
      },
    );
    expect(screen.getAllByText("fast.Method:run").length).toBeGreaterThanOrEqual(1);
  });

  it("shows allocation count deltas", () => {
    renderWithComparison(
      {
        allocations: [
          {
            className: "alloc.Heavy",
            internalClassName: "alloc/Heavy",
            count: 100,
            jfrSampleCount: 0,
            jfrSampleBytes: 0,
          },
        ],
      },
      {
        allocations: [
          {
            className: "alloc.Heavy",
            internalClassName: "alloc/Heavy",
            count: 20,
            jfrSampleCount: 0,
            jfrSampleBytes: 0,
          },
        ],
      },
    );
    expect(screen.getAllByText("alloc.Heavy").length).toBeGreaterThanOrEqual(1);
    // +80 delta
    expect(screen.getAllByText("+80").length).toBeGreaterThanOrEqual(1);
  });

  it("shows allocation byte deltas", () => {
    renderWithComparison(
      {
        allocations: [
          {
            className: "alloc.Bytes",
            internalClassName: "alloc/Bytes",
            count: 10,
            jfrSampleCount: 5,
            jfrSampleBytes: 50000,
          },
        ],
      },
      {
        allocations: [
          {
            className: "alloc.Bytes",
            internalClassName: "alloc/Bytes",
            count: 10,
            jfrSampleCount: 2,
            jfrSampleBytes: 10000,
          },
        ],
      },
    );
    expect(screen.getAllByText("alloc.Bytes").length).toBeGreaterThanOrEqual(1);
    // byte delta = +40,000
    expect(screen.getAllByText("+40,000").length).toBeGreaterThanOrEqual(1);
  });

  it("shows JFR sample deltas when both snapshots have JFR", () => {
    const jfrBase = createTestSnapshot().jfr;
    renderWithComparison(
      {
        jfr: {
          ...jfrBase,
          enabled: true,
          topSampledMethods: [{ name: "jfr.Hot:method", samples: 50 }],
        },
      },
      {
        jfr: {
          ...jfrBase,
          enabled: true,
          topSampledMethods: [{ name: "jfr.Hot:method", samples: 20 }],
        },
      },
    );
    expect(screen.getByText("JFR Sample Delta")).toBeTruthy();
    expect(screen.getAllByText("jfr.Hot:method").length).toBeGreaterThanOrEqual(1);
    // +30 sample delta
    expect(screen.getAllByText("+30").length).toBeGreaterThanOrEqual(1);
  });

  it("hides JFR section when neither snapshot has JFR enabled", () => {
    renderWithComparison();
    expect(screen.queryByText("JFR Sample Delta")).toBeNull();
  });

  it("shows observed time delta in summary cards", () => {
    renderWithComparison(
      {
        summary: {
          threadCount: 1,
          interactionCount: 1,
          frameCount: 1,
          allocationClassCount: 0,
          totalObservedTimeNanos: 15_000_000,
        },
      },
      {
        summary: {
          threadCount: 1,
          interactionCount: 1,
          frameCount: 1,
          allocationClassCount: 0,
          totalObservedTimeNanos: 10_000_000,
        },
      },
    );
    expect(screen.getByText("+5.000 ms")).toBeTruthy();
  });

  it("renders Download Compare button", () => {
    renderWithComparison();
    expect(screen.getByText("Download Compare")).toBeTruthy();
  });
});
