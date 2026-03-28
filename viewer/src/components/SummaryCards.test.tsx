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
  it("renders schema version", () => {
    renderWithSnapshot();
    expect(screen.getByText("jip-modern-v1")).toBeTruthy();
  });

  it("renders snapshot label", () => {
    renderWithSnapshot();
    expect(screen.getByText("test-snapshot")).toBeTruthy();
  });

  it("renders thread count", () => {
    renderWithSnapshot();
    expect(screen.getByText("2")).toBeTruthy();
  });

  it("renders hottest method name", () => {
    renderWithSnapshot();
    expect(screen.getByText("sample.Service:run")).toBeTruthy();
  });

  it("renders n/a when no methods", () => {
    renderWithSnapshot({ methodSummary: [] });
    expect(screen.getByText("n/a")).toBeTruthy();
  });
});
