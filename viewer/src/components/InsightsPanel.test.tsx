import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/preact";
import { SnapshotContext } from "../context";
import { InsightsPanel } from "./InsightsPanel";
import { createTestSnapshot } from "../test-fixtures";
import type { Insight } from "../types";

function renderWithInsights(insights: Insight[]) {
  const snapshot = createTestSnapshot({ insights });
  return render(
    <SnapshotContext.Provider value={snapshot}>
      <InsightsPanel />
    </SnapshotContext.Provider>,
  );
}

describe("InsightsPanel", () => {
  it("renders clear message when no insights", () => {
    renderWithInsights([]);
    expect(screen.getByText("No automatic bottlenecks flagged")).toBeTruthy();
    expect(screen.getByText("Clear")).toBeTruthy();
  });

  // --- dominant-hotspot ---
  it("renders dominant hotspot insight", () => {
    renderWithInsights([
      {
        type: "dominant-hotspot",
        severity: "high",
        title: "Dominant hotspot",
        summary: "sample.Service:run dominates the profile",
        evidence: ["sample.Service:run accounts for 50% of net time"],
      },
    ]);
    expect(screen.getByText("Dominant hotspot")).toBeTruthy();
    expect(screen.getByText("high")).toBeTruthy();
    expect(screen.getByText("sample.Service:run dominates the profile")).toBeTruthy();
    expect(screen.getByText("sample.Service:run accounts for 50% of net time")).toBeTruthy();
  });

  // --- allocation-pressure ---
  it("renders allocation pressure insight", () => {
    renderWithInsights([
      {
        type: "allocation-pressure",
        severity: "medium",
        title: "Allocation pressure",
        summary: "sample.Widget drives 92% of tracked allocations",
        evidence: [
          "sample.Widget: 12 allocations out of 13 total",
          "JFR sampled 8 allocation events for this class",
        ],
      },
    ]);
    expect(screen.getByText("Allocation pressure")).toBeTruthy();
    expect(screen.getByText("medium")).toBeTruthy();
    expect(screen.getByText(/sample\.Widget drives 92%/)).toBeTruthy();
    expect(screen.getByText(/12 allocations out of 13 total/)).toBeTruthy();
    expect(screen.getByText(/JFR sampled 8 allocation events/)).toBeTruthy();
  });

  // --- single-thread-dominance ---
  it("renders single-thread dominance insight", () => {
    renderWithInsights([
      {
        type: "single-thread-dominance",
        severity: "high",
        title: "Single-thread dominance",
        summary: "Thread 1 accounts for 85% of observed time",
        evidence: ["Thread 1: 8.500 ms", "Thread 2: 1.500 ms"],
      },
    ]);
    expect(screen.getByText("Single-thread dominance")).toBeTruthy();
    expect(screen.getByText("high")).toBeTruthy();
    expect(screen.getByText(/Thread 1 accounts for 85%/)).toBeTruthy();
    expect(screen.getByText("Thread 1: 8.500 ms")).toBeTruthy();
    expect(screen.getByText("Thread 2: 1.500 ms")).toBeTruthy();
  });

  // --- jfr-instrumentation-mismatch ---
  it("renders JFR instrumentation mismatch insight", () => {
    renderWithInsights([
      {
        type: "jfr-instrumentation-mismatch",
        severity: "medium",
        title: "Sampled mismatch",
        summary: "The top JFR-sampled hotspot does not appear among the top instrumented methods",
        evidence: ["Top sampled: native.Method:compute", "Top instrumented: app.Service:handle"],
      },
    ]);
    expect(screen.getByText("Sampled mismatch")).toBeTruthy();
    expect(screen.getByText("medium")).toBeTruthy();
    expect(screen.getByText(/top JFR-sampled hotspot/)).toBeTruthy();
    expect(screen.getByText("Top sampled: native.Method:compute")).toBeTruthy();
    expect(screen.getByText("Top instrumented: app.Service:handle")).toBeTruthy();
  });

  // --- multiple insights at once ---
  it("renders all 4 insight types simultaneously", () => {
    renderWithInsights([
      {
        type: "dominant-hotspot",
        severity: "high",
        title: "Dominant hotspot",
        summary: "s1",
        evidence: [],
      },
      {
        type: "allocation-pressure",
        severity: "medium",
        title: "Allocation pressure",
        summary: "s2",
        evidence: [],
      },
      {
        type: "single-thread-dominance",
        severity: "high",
        title: "Single-thread dominance",
        summary: "s3",
        evidence: [],
      },
      {
        type: "jfr-instrumentation-mismatch",
        severity: "medium",
        title: "Sampled mismatch",
        summary: "s4",
        evidence: [],
      },
    ]);
    expect(screen.getByText("Dominant hotspot")).toBeTruthy();
    expect(screen.getByText("Allocation pressure")).toBeTruthy();
    expect(screen.getByText("Single-thread dominance")).toBeTruthy();
    expect(screen.getByText("Sampled mismatch")).toBeTruthy();
  });

  it("renders severity pill text", () => {
    renderWithInsights([
      {
        type: "dominant-hotspot",
        severity: "high",
        title: "Test",
        summary: "s",
        evidence: [],
      },
    ]);
    expect(screen.getByText("high")).toBeTruthy();
  });
});
