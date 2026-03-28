import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/preact";
import { SnapshotContext } from "../context";
import { ThreadTrees } from "./ThreadTrees";
import { createTestSnapshot } from "../test-fixtures";

function renderWithSnapshot(query: string, overrides = {}) {
  const snapshot = createTestSnapshot(overrides);
  return render(
    <SnapshotContext.Provider value={snapshot}>
      <ThreadTrees query={query} />
    </SnapshotContext.Provider>,
  );
}

describe("ThreadTrees", () => {
  it("renders heading", () => {
    renderWithSnapshot("");
    expect(screen.getByText("Thread Call Trees")).toBeTruthy();
  });

  it("renders thread summary with ID and time", () => {
    renderWithSnapshot("");
    expect(screen.getByText(/Thread 1/)).toBeTruthy();
  });

  it("renders interaction labels", () => {
    renderWithSnapshot("");
    expect(screen.getByText("Interaction 1")).toBeTruthy();
  });

  it("renders frame method names", () => {
    renderWithSnapshot("");
    expect(screen.getByText("sample.Service:run")).toBeTruthy();
    expect(screen.getByText("sample.Worker:step")).toBeTruthy();
  });

  it("renders frame metadata (net, total, calls)", () => {
    renderWithSnapshot("");
    expect(screen.getAllByText(/Net/).length).toBeGreaterThan(0);
    expect(screen.getAllByText(/Total/).length).toBeGreaterThan(0);
    expect(screen.getAllByText(/Calls/).length).toBeGreaterThan(0);
  });

  it("filters threads by thread ID query", () => {
    renderWithSnapshot("999", {
      threads: [
        {
          threadId: 1,
          totalTimeNanos: 1_000_000,
          interactions: [
            {
              name: "a.B:c",
              className: "a.B",
              methodName: "c",
              count: 1,
              totalTimeNanos: 1_000_000,
              netTimeNanos: 1_000_000,
              children: [],
            },
          ],
        },
        {
          threadId: 999,
          totalTimeNanos: 2_000_000,
          interactions: [
            {
              name: "x.Y:z",
              className: "x.Y",
              methodName: "z",
              count: 1,
              totalTimeNanos: 2_000_000,
              netTimeNanos: 2_000_000,
              children: [],
            },
          ],
        },
      ],
    });
    expect(screen.getByText("x.Y:z")).toBeTruthy();
    expect(screen.queryByText("a.B:c")).toBeNull();
  });

  it("filters threads by method name query", () => {
    renderWithSnapshot("worker");
    expect(screen.getByText("sample.Worker:step")).toBeTruthy();
  });

  it("shows all threads when query is empty", () => {
    renderWithSnapshot("", {
      threads: [
        {
          threadId: 1,
          totalTimeNanos: 1_000_000,
          interactions: [
            {
              name: "a.B:c",
              className: "a.B",
              methodName: "c",
              count: 1,
              totalTimeNanos: 1_000_000,
              netTimeNanos: 1_000_000,
              children: [],
            },
          ],
        },
        {
          threadId: 2,
          totalTimeNanos: 2_000_000,
          interactions: [
            {
              name: "x.Y:z",
              className: "x.Y",
              methodName: "z",
              count: 1,
              totalTimeNanos: 2_000_000,
              netTimeNanos: 2_000_000,
              children: [],
            },
          ],
        },
      ],
    });
    expect(screen.getByText("a.B:c")).toBeTruthy();
    expect(screen.getByText("x.Y:z")).toBeTruthy();
  });
});
