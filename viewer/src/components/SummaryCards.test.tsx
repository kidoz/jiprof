import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/preact";
import { SnapshotContext } from "../context";
import { SummaryCards } from "./SummaryCards";
import { createTestSnapshot } from "../test-fixtures";

function renderWithSnapshot(overrides = {}) {
  const snapshot = createTestSnapshot(overrides);
  return render(
    <SnapshotContext.Provider value={snapshot}>
      <SummaryCards />
    </SnapshotContext.Provider>,
  );
}

describe("SummaryCards", () => {
  it("renders thread count", () => {
    renderWithSnapshot();
    expect(screen.getByText("2")).toBeTruthy();
  });

  it("renders frame count", () => {
    renderWithSnapshot();
    expect(screen.getByText("5")).toBeTruthy();
  });

  it("renders observed time", () => {
    renderWithSnapshot();
    expect(screen.getByText("10.000 ms")).toBeTruthy();
  });

  it("renders hottest method name", () => {
    renderWithSnapshot();
    expect(screen.getByText("sample.Service:run")).toBeTruthy();
  });

  it("hides hottest method when no methods", () => {
    renderWithSnapshot({ methodSummary: [] });
    expect(screen.queryByText("Hottest Method")).toBeNull();
  });
});
