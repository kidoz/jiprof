import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/preact";
import { MethodTable } from "./MethodTable";

const methods = [
  {
    name: "com.example.Foo:bar",
    className: "com.example.Foo",
    methodName: "bar",
    count: 10,
    totalTimeNanos: 5_000_000,
    netTimeNanos: 3_000_000,
  },
  {
    name: "com.example.Baz:qux",
    className: "com.example.Baz",
    methodName: "qux",
    count: 2,
    totalTimeNanos: 1_000_000,
    netTimeNanos: 1_000_000,
  },
];

describe("MethodTable", () => {
  it("renders the title", () => {
    render(
      <MethodTable
        title="Top Methods"
        methods={methods}
        query=""
        totalObservedTimeNanos={10_000_000}
      />,
    );
    expect(screen.getByText("Top Methods")).toBeTruthy();
  });

  it("renders all method names", () => {
    render(
      <MethodTable
        title="Top Methods"
        methods={methods}
        query=""
        totalObservedTimeNanos={10_000_000}
      />,
    );
    expect(screen.getByText("com.example.Foo:bar")).toBeTruthy();
    expect(screen.getByText("com.example.Baz:qux")).toBeTruthy();
  });

  it("filters methods by query", () => {
    render(
      <MethodTable
        title="Top Methods"
        methods={methods}
        query="foo"
        totalObservedTimeNanos={10_000_000}
      />,
    );
    expect(screen.getByText("com.example.Foo:bar")).toBeTruthy();
    expect(screen.queryByText("com.example.Baz:qux")).toBeNull();
  });

  it("shows all methods when query is empty", () => {
    render(
      <MethodTable
        title="Top Methods"
        methods={methods}
        query=""
        totalObservedTimeNanos={10_000_000}
      />,
    );
    const rows = screen.getAllByText(/com\.example\./);
    expect(rows.length).toBe(2);
  });

  it("renders call counts", () => {
    render(
      <MethodTable
        title="Top Methods"
        methods={methods}
        query=""
        totalObservedTimeNanos={10_000_000}
      />,
    );
    expect(screen.getByText("10")).toBeTruthy();
    expect(screen.getByText("2")).toBeTruthy();
  });
});
