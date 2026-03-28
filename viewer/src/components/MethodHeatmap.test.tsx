import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/preact";
import { SnapshotContext } from "../context";
import { MethodHeatmap } from "./MethodHeatmap";
import { createTestSnapshot } from "../test-fixtures";

function renderWithSnapshot(overrides = {}) {
  const snapshot = createTestSnapshot(overrides);
  return render(
    <SnapshotContext.Provider value={snapshot}>
      <MethodHeatmap />
    </SnapshotContext.Provider>,
  );
}

describe("MethodHeatmap", () => {
  it("renders heatmap heading", () => {
    renderWithSnapshot();
    expect(screen.getByText("Method Heatmap")).toBeTruthy();
  });

  it("renders method names as tiles", () => {
    renderWithSnapshot();
    expect(screen.getByText("sample.Service:run")).toBeTruthy();
    expect(screen.getByText("sample.Worker:step")).toBeTruthy();
  });

  it("renders rank labels", () => {
    renderWithSnapshot();
    expect(screen.getByText("Rank 1")).toBeTruthy();
    expect(screen.getByText("Rank 2")).toBeTruthy();
  });

  it("renders empty state when no methods", () => {
    renderWithSnapshot({ methodSummary: [] });
    expect(screen.getByText("No method summary is available for this snapshot.")).toBeTruthy();
  });

  it("limits to 12 tiles", () => {
    const methods = Array.from({ length: 20 }, (_, i) => ({
      name: `method.M${i}:run`,
      className: `method.M${i}`,
      methodName: "run",
      count: 20 - i,
      totalTimeNanos: (20 - i) * 1_000_000,
      netTimeNanos: (20 - i) * 500_000,
    }));
    renderWithSnapshot({ methodSummary: methods });
    expect(screen.getByText("Rank 12")).toBeTruthy();
    expect(screen.queryByText("Rank 13")).toBeNull();
  });

  it("renders timing metadata in tiles", () => {
    renderWithSnapshot();
    expect(screen.getAllByText(/Net/).length).toBeGreaterThan(0);
    expect(screen.getAllByText(/Total/).length).toBeGreaterThan(0);
    expect(screen.getAllByText(/Calls/).length).toBeGreaterThan(0);
  });
});
