import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/preact";
import { SnapshotContext } from "../context";
import { IcicleChart } from "./IcicleChart";
import { createTestSnapshot } from "../test-fixtures";

function renderWithSnapshot(overrides = {}) {
  const snapshot = createTestSnapshot(overrides);
  return render(
    <SnapshotContext.Provider value={snapshot}>
      <IcicleChart />
    </SnapshotContext.Provider>,
  );
}

describe("IcicleChart", () => {
  it("renders icicle view heading", () => {
    renderWithSnapshot();
    expect(screen.getByText("Icicle View")).toBeTruthy();
  });

  it("renders hottest interaction from the thread with highest total time", () => {
    renderWithSnapshot();
    expect(screen.getByText(/thread 1/i)).toBeTruthy();
  });

  it("renders root frame segment label", () => {
    renderWithSnapshot();
    expect(screen.getByText("sample.Service:run")).toBeTruthy();
  });

  it("renders child frame segment", () => {
    renderWithSnapshot();
    expect(screen.getByText("sample.Worker:step")).toBeTruthy();
  });

  it("shows empty state when no threads", () => {
    renderWithSnapshot({ threads: [] });
    expect(screen.getByText("No icicle data available.")).toBeTruthy();
  });

  it("shows empty state when threads have no interactions", () => {
    renderWithSnapshot({ threads: [{ threadId: 1, totalTimeNanos: 0, interactions: [] }] });
    expect(screen.getByText("No icicle data available.")).toBeTruthy();
  });

  it("picks the hottest interaction across multiple threads", () => {
    renderWithSnapshot({
      threads: [
        {
          threadId: 1,
          totalTimeNanos: 2_000_000,
          interactions: [
            {
              name: "cold.Method:run",
              className: "cold.Method",
              methodName: "run",
              count: 1,
              totalTimeNanos: 2_000_000,
              netTimeNanos: 2_000_000,
              children: [],
            },
          ],
        },
        {
          threadId: 2,
          totalTimeNanos: 9_000_000,
          interactions: [
            {
              name: "hot.Method:execute",
              className: "hot.Method",
              methodName: "execute",
              count: 5,
              totalTimeNanos: 9_000_000,
              netTimeNanos: 9_000_000,
              children: [],
            },
          ],
        },
      ],
    });
    expect(screen.getByText(/thread 2/i)).toBeTruthy();
    expect(screen.getByText("hot.Method:execute")).toBeTruthy();
  });
});
