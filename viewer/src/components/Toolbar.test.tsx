import { describe, it, expect, afterEach } from "vitest";
import { render, screen } from "@testing-library/preact";
import { SnapshotContext, comparisonSnapshot, methodSearch, threadSearch } from "../context";
import { Toolbar } from "./Toolbar";
import { createTestSnapshot } from "../test-fixtures";

afterEach(() => {
  comparisonSnapshot.value = null;
  methodSearch.value = "";
  threadSearch.value = "";
});

function renderToolbar(overrides = {}) {
  const snapshot = createTestSnapshot(overrides);
  return render(
    <SnapshotContext.Provider value={snapshot}>
      <Toolbar />
    </SnapshotContext.Provider>,
  );
}

describe("Toolbar", () => {
  it("renders search inputs", () => {
    renderToolbar();
    expect(screen.getByPlaceholderText("Filter methods, classes, or signatures")).toBeTruthy();
    expect(screen.getByPlaceholderText("Filter thread trees")).toBeTruthy();
  });

  it("renders Load Baseline Snapshot button", () => {
    renderToolbar();
    expect(screen.getByText("Load Baseline Snapshot")).toBeTruthy();
  });

  it("renders Download Snapshot button", () => {
    renderToolbar();
    expect(screen.getByText("Download Snapshot")).toBeTruthy();
  });

  it("shows no baseline status by default", () => {
    renderToolbar();
    expect(screen.getByText("No baseline snapshot loaded.")).toBeTruthy();
  });

  it("does not show Clear Compare when no baseline loaded", () => {
    renderToolbar();
    expect(screen.queryByText("Clear Compare")).toBeNull();
  });

  it("shows comparison status when baseline is loaded", () => {
    comparisonSnapshot.value = createTestSnapshot({ snapshotLabel: "baseline-run" });
    renderToolbar();
    expect(screen.getByText(/Comparing.*against.*baseline-run/)).toBeTruthy();
  });

  it("shows Clear Compare button when baseline is loaded", () => {
    comparisonSnapshot.value = createTestSnapshot({ snapshotLabel: "baseline-run" });
    renderToolbar();
    expect(screen.getByText("Clear Compare")).toBeTruthy();
  });
});
