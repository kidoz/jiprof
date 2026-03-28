import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/preact";
import { SnapshotContext } from "../context";
import { AsyncProfilerPanel } from "./AsyncProfilerPanel";
import { createTestSnapshot } from "../test-fixtures";
import type { SnapshotDocument } from "../types";

function renderWithSnapshot(overrides: Partial<SnapshotDocument> = {}) {
  const snapshot = createTestSnapshot(overrides);
  return render(
    <SnapshotContext.Provider value={snapshot}>
      <AsyncProfilerPanel />
    </SnapshotContext.Provider>,
  );
}

const enabledAP: SnapshotDocument["asyncProfiler"] = {
  enabled: true,
  warning: "",
  artifacts: [
    { label: "cpu-flamegraph", type: "flamegraph-html", path: "/tmp/cpu-flamegraph.html" },
  ],
  collapsed: {
    file: "/tmp/cpu.collapsed",
    totalSamples: 10,
    topLeafFrames: [
      { name: "sample/Service.run", samples: 7 },
      { name: "sample/Worker.step", samples: 3 },
    ],
    topStacks: [
      {
        leafFrame: "sample/Service.run",
        samples: 7,
        stack: "java/lang/Thread.run;sample/Service.run",
      },
    ],
  },
};

describe("AsyncProfilerPanel", () => {
  it("renders nothing when async-profiler is disabled", () => {
    const { container } = renderWithSnapshot();
    expect(container.innerHTML).toBe("");
  });

  it("renders heading when enabled", () => {
    renderWithSnapshot({ asyncProfiler: enabledAP });
    expect(screen.getByText("Async-Profiler Imports")).toBeTruthy();
  });

  it("renders artifact links", () => {
    renderWithSnapshot({ asyncProfiler: enabledAP });
    expect(screen.getByText("cpu-flamegraph")).toBeTruthy();
    expect(screen.getByText(/flamegraph-html/)).toBeTruthy();
    expect(screen.getByText("/tmp/cpu-flamegraph.html")).toBeTruthy();
  });

  it("renders leaf frames table", () => {
    renderWithSnapshot({ asyncProfiler: enabledAP });
    // sample/Service.run appears in both leaf frames and stacks tables
    expect(screen.getAllByText("sample/Service.run").length).toBeGreaterThanOrEqual(1);
    expect(screen.getAllByText("7").length).toBeGreaterThanOrEqual(1);
    expect(screen.getByText("sample/Worker.step")).toBeTruthy();
    expect(screen.getByText("3")).toBeTruthy();
  });

  it("renders collapsed stacks table", () => {
    renderWithSnapshot({ asyncProfiler: enabledAP });
    expect(screen.getByText("Collapsed Stack")).toBeTruthy();
    expect(screen.getByText("java/lang/Thread.run;sample/Service.run")).toBeTruthy();
  });

  it("renders warning when present", () => {
    renderWithSnapshot({
      asyncProfiler: { ...enabledAP, warning: "Collapsed file partially parsed" },
    });
    expect(screen.getByText("Collapsed file partially parsed")).toBeTruthy();
  });

  it("shows no artifacts message when artifacts list empty", () => {
    renderWithSnapshot({
      asyncProfiler: { ...enabledAP, artifacts: [] },
    });
    expect(screen.getByText(/No external async-profiler artifacts/)).toBeTruthy();
  });

  it("hides leaf frames table when no leaf frames", () => {
    renderWithSnapshot({
      asyncProfiler: {
        ...enabledAP,
        collapsed: { ...enabledAP.collapsed, topLeafFrames: [], topStacks: [] },
      },
    });
    expect(screen.queryByText("Leaf Frame")).toBeNull();
  });
});
