import { useContext } from "preact/hooks";
import { SnapshotContext } from "../context";
import { formatInt } from "../format";
import { Panel } from "./App";

export function AllocationsPanel() {
  const snapshot = useContext(SnapshotContext);
  const jfr = snapshot.jfr;
  const hasAllocationPaths = jfr && jfr.topAllocationPaths && jfr.topAllocationPaths.length > 0;

  const thCls = "text-left text-[0.65rem] font-semibold uppercase tracking-wide text-muted";
  const tdCls = "px-2 py-1.5 border-b border-line align-top";
  const numCls = `${tdCls} font-mono text-[0.7rem] whitespace-nowrap`;
  const codeCls = `${tdCls} font-mono text-[0.7rem] break-all`;

  return (
    <>
      <Panel title="Allocations">
        <table class="w-full border-collapse text-sm">
          <thead>
            <tr>
              <th class={thCls}>Class</th>
              <th class={thCls}>Count</th>
              <th class={thCls}>JFR Samples</th>
              <th class={thCls}>JFR Bytes</th>
            </tr>
          </thead>
          <tbody>
            {snapshot.allocations.map((alloc, i) => (
              <tr key={i}>
                <td class={codeCls}>{alloc.className}</td>
                <td class={numCls}>{formatInt(alloc.count)}</td>
                <td class={numCls}>{formatInt(alloc.jfrSampleCount || 0)}</td>
                <td class={numCls}>{formatInt(alloc.jfrSampleBytes || 0)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </Panel>

      {hasAllocationPaths && (
        <Panel title="Allocation Hot Paths">
          <table class="w-full border-collapse text-sm">
            <thead>
              <tr>
                <th class={thCls}>Path</th>
                <th class={thCls}>Class</th>
                <th class={thCls}>Samples</th>
                <th class={thCls}>Bytes</th>
              </tr>
            </thead>
            <tbody>
              {jfr.topAllocationPaths.map((alloc, i) => (
                <tr key={i}>
                  <td class={codeCls}>{alloc.pathName}</td>
                  <td class={codeCls}>{alloc.className}</td>
                  <td class={numCls}>{formatInt(alloc.samples)}</td>
                  <td class={numCls}>{formatInt(alloc.bytes)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </Panel>
      )}
    </>
  );
}
