import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/preact";
import { SnapshotContext } from "../context";
import { JfrPanel } from "./JfrPanel";
import { createTestSnapshot } from "../test-fixtures";
import type { SnapshotDocument } from "../types";

function renderWithSnapshot(overrides: Partial<SnapshotDocument> = {}) {
  const snapshot = createTestSnapshot(overrides);
  return render(
    <SnapshotContext.Provider value={snapshot}>
      <JfrPanel />
    </SnapshotContext.Provider>,
  );
}

const enabledJfr: SnapshotDocument["jfr"] = {
  enabled: true,
  artifact: "/tmp/test.jfr",
  warning: "",
  metadata: {
    samplePeriodMs: 20,
    executionSamplingEnabled: true,
    nativeSamplingEnabled: false,
    cpuTimeSamplingEnabled: true,
    allocationEventsEnabled: true,
    monitorEnterEventsEnabled: true,
    monitorWaitEventsEnabled: false,
    threadParkEventsEnabled: true,
  },
  executionSampleCount: 100,
  nativeSampleCount: 0,
  cpuTimeSampleCount: 50,
  allocationSampleCount: 10,
  monitorEnterCount: 5,
  monitorWaitCount: 0,
  threadParkCount: 3,
  contentionEventCount: 8,
  contentionDurationNanos: 2_000_000,
  topSampledMethods: [
    { name: "hot.Method:compute", samples: 42 },
    { name: "warm.Method:process", samples: 18 },
  ],
  topAllocationSamples: [{ className: "byte[]", samples: 7, bytes: 16384 }],
  topAllocationPaths: [],
  topContentionSamples: [
    {
      name: "lock.Monitor:enter",
      monitorEnterCount: 5,
      monitorWaitCount: 0,
      threadParkCount: 3,
      eventCount: 8,
      durationNanos: 2_000_000,
    },
  ],
};

describe("JfrPanel", () => {
  it("renders nothing when JFR is disabled", () => {
    const { container } = renderWithSnapshot();
    expect(container.innerHTML).toBe("");
  });

  it("renders heading when JFR is enabled", () => {
    renderWithSnapshot({ jfr: enabledJfr });
    expect(screen.getByText("JFR Sampled Hotspots")).toBeTruthy();
  });

  it("renders metadata fields", () => {
    renderWithSnapshot({ jfr: enabledJfr });
    expect(screen.getByText(/Sample period: 20 ms/)).toBeTruthy();
    expect(screen.getByText(/Execution samples: on/)).toBeTruthy();
    expect(screen.getByText(/Native samples: off/)).toBeTruthy();
    expect(screen.getByText(/CPU-time samples: on/)).toBeTruthy();
    expect(screen.getByText(/Allocation events: on/)).toBeTruthy();
    expect(screen.getByText(/Lock events: on/)).toBeTruthy();
  });

  it("renders sampled method hotspots", () => {
    renderWithSnapshot({ jfr: enabledJfr });
    expect(screen.getByText("hot.Method:compute")).toBeTruthy();
    expect(screen.getByText("42")).toBeTruthy();
    expect(screen.getByText("warm.Method:process")).toBeTruthy();
  });

  it("renders allocation samples table", () => {
    renderWithSnapshot({ jfr: enabledJfr });
    expect(screen.getByText("byte[]")).toBeTruthy();
    expect(screen.getByText("Allocation Class")).toBeTruthy();
  });

  it("renders contention table", () => {
    renderWithSnapshot({ jfr: enabledJfr });
    expect(screen.getByText("Contention Site")).toBeTruthy();
    expect(screen.getByText("lock.Monitor:enter")).toBeTruthy();
    expect(screen.getByText("8")).toBeTruthy();
  });

  it("renders warning when present", () => {
    renderWithSnapshot({
      jfr: { ...enabledJfr, warning: "JFR recording truncated" },
    });
    expect(screen.getByText("JFR recording truncated")).toBeTruthy();
  });

  it("shows empty hotspot message when no sampled methods", () => {
    renderWithSnapshot({
      jfr: { ...enabledJfr, topSampledMethods: [] },
    });
    expect(screen.getByText(/No sampled Java hotspots/)).toBeTruthy();
  });

  it("hides contention table when no contention samples", () => {
    renderWithSnapshot({
      jfr: { ...enabledJfr, topContentionSamples: [] },
    });
    expect(screen.queryByText("Contention Site")).toBeNull();
  });

  it("hides allocation table when no allocation samples", () => {
    renderWithSnapshot({
      jfr: { ...enabledJfr, topAllocationSamples: [] },
    });
    expect(screen.queryByText("Allocation Class")).toBeNull();
  });
});
