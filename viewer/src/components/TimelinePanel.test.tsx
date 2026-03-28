import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/preact";
import { SnapshotContext } from "../context";
import { TimelinePanel } from "./TimelinePanel";
import { createTestSnapshot } from "../test-fixtures";

function renderWithSnapshot(overrides = {}) {
  const snapshot = createTestSnapshot(overrides);
  return render(
    <SnapshotContext.Provider value={snapshot}>
      <TimelinePanel />
    </SnapshotContext.Provider>,
  );
}

describe("TimelinePanel", () => {
  it("renders timeline heading", () => {
    renderWithSnapshot();
    expect(screen.getByText("Timeline")).toBeTruthy();
  });

  it("renders bucket window range", () => {
    const { container } = renderWithSnapshot();
    const numericCells = container.querySelectorAll("td.numeric");
    const windowCell = numericCells[0];
    expect(windowCell?.textContent).toContain("0");
    expect(windowCell?.textContent).toContain("1,000");
  });

  it("renders thread activity row", () => {
    renderWithSnapshot();
    // thread ID 1
    expect(screen.getAllByText("1").length).toBeGreaterThan(0);
  });

  it("renders nothing when timeline is null", () => {
    const { container } = renderWithSnapshot({ timeline: null });
    expect(container.innerHTML).toBe("");
  });

  it("renders empty message when no buckets", () => {
    renderWithSnapshot({
      timeline: {
        bucketSizeMs: 1000,
        durationNanos: 0,
        jfrBucketSizeMs: 0,
        buckets: [],
        threads: [],
        jfrBuckets: [],
      },
    });
    expect(screen.getByText(/No runtime timeline buckets/)).toBeTruthy();
  });

  it("renders empty message when no thread activity", () => {
    renderWithSnapshot({
      timeline: {
        bucketSizeMs: 1000,
        durationNanos: 10_000_000,
        jfrBucketSizeMs: 0,
        buckets: [
          {
            bucketIndex: 0,
            startOffsetMs: 0,
            endOffsetMs: 1000,
            observedTimeNanos: 10_000_000,
            eventCount: 1,
            activeThreadCount: 1,
            topThreads: [],
          },
        ],
        threads: [],
        jfrBuckets: [],
      },
    });
    expect(screen.getByText(/No thread activity summary/)).toBeTruthy();
  });

  it("merges JFR sample counts into timeline buckets", () => {
    renderWithSnapshot({
      timeline: {
        bucketSizeMs: 1000,
        durationNanos: 10_000_000,
        jfrBucketSizeMs: 1000,
        buckets: [
          {
            bucketIndex: 0,
            startOffsetMs: 0,
            endOffsetMs: 1000,
            observedTimeNanos: 10_000_000,
            eventCount: 1,
            activeThreadCount: 1,
            topThreads: [],
          },
        ],
        threads: [
          {
            threadId: 1,
            observedTimeNanos: 8_000_000,
            eventCount: 1,
            peakBucketIndex: 0,
            peakStartOffsetMs: 0,
            peakEndOffsetMs: 1000,
            peakObservedTimeNanos: 8_000_000,
          },
        ],
        jfrBuckets: [
          {
            bucketIndex: 0,
            startOffsetMs: 0,
            endOffsetMs: 1000,
            executionSamples: 10,
            nativeSamples: 5,
            cpuTimeSamples: 3,
            allocationEvents: 0,
            contentionEvents: 2,
          },
        ],
      },
    });
    // 10+5+3 = 18 JFR samples
    expect(screen.getByText("18")).toBeTruthy();
    // 2 contention events
    expect(screen.getByText("2")).toBeTruthy();
  });
});
