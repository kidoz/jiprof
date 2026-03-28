import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/preact";
import { SnapshotContext } from "../context";
import { HistoryPanel } from "./HistoryPanel";
import { createTestSnapshot } from "../test-fixtures";

function renderWithSnapshot(overrides = {}) {
  const snapshot = createTestSnapshot(overrides);
  return render(
    <SnapshotContext.Provider value={snapshot}>
      <HistoryPanel />
    </SnapshotContext.Provider>,
  );
}

describe("HistoryPanel", () => {
  it("renders nothing when history is disabled", () => {
    const { container } = renderWithSnapshot();
    expect(container.innerHTML).toBe("");
  });

  it("renders nothing when history has no entries", () => {
    const { container } = renderWithSnapshot({
      history: { enabled: true, indexArtifact: "", current: null, entries: [] },
    });
    expect(container.innerHTML).toBe("");
  });

  it("renders heading when history entries exist", () => {
    renderWithSnapshot({
      history: {
        enabled: true,
        indexArtifact: "/tmp/recordings-index.json",
        current: null,
        entries: [
          {
            snapshotLabel: "snap-1",
            generatedAt: "20260328-120000",
            totalObservedTimeNanos: 5_000_000,
            threadCount: 2,
            topMethod: "foo.Bar:baz",
            json: "/tmp/snap-1.json",
            html: "/tmp/snap-1.html",
            jfr: "",
            current: false,
          },
        ],
      },
    });
    expect(screen.getByText("Recent Recordings")).toBeTruthy();
  });

  it("renders entry snapshot label", () => {
    renderWithSnapshot({
      history: {
        enabled: true,
        indexArtifact: "",
        current: null,
        entries: [
          {
            snapshotLabel: "my-recording",
            generatedAt: "20260328-120000",
            totalObservedTimeNanos: 5_000_000,
            threadCount: 1,
            topMethod: "a.B:c",
            json: "/tmp/r.json",
            html: "",
            jfr: "",
            current: false,
          },
        ],
      },
    });
    expect(screen.getByText("my-recording")).toBeTruthy();
  });

  it("marks current entry with suffix", () => {
    renderWithSnapshot({
      history: {
        enabled: true,
        indexArtifact: "",
        current: null,
        entries: [
          {
            snapshotLabel: "latest",
            generatedAt: "20260328-120000",
            totalObservedTimeNanos: 5_000_000,
            threadCount: 1,
            topMethod: "a.B:c",
            json: "",
            html: "",
            jfr: "",
            current: true,
          },
        ],
      },
    });
    expect(screen.getByText("latest (current)")).toBeTruthy();
  });

  it("renders artifact links", () => {
    renderWithSnapshot({
      history: {
        enabled: true,
        indexArtifact: "",
        current: null,
        entries: [
          {
            snapshotLabel: "s",
            generatedAt: "",
            totalObservedTimeNanos: 0,
            threadCount: 0,
            topMethod: "",
            json: "/tmp/s.json",
            html: "/tmp/s.html",
            jfr: "/tmp/s.jfr",
            current: false,
          },
        ],
      },
    });
    expect(screen.getByText("json")).toBeTruthy();
    expect(screen.getByText("html")).toBeTruthy();
    expect(screen.getByText("jfr")).toBeTruthy();
  });

  it("shows index artifact path in caption", () => {
    renderWithSnapshot({
      history: {
        enabled: true,
        indexArtifact: "/data/recordings-index.json",
        current: null,
        entries: [
          {
            snapshotLabel: "s",
            generatedAt: "",
            totalObservedTimeNanos: 0,
            threadCount: 0,
            topMethod: "",
            json: "",
            html: "",
            jfr: "",
            current: false,
          },
        ],
      },
    });
    expect(screen.getByText(/\/data\/recordings-index\.json/)).toBeTruthy();
  });
});
