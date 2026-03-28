import { useContext } from "preact/hooks";
import { SnapshotContext } from "../context";
import { formatInt } from "../format";

export function AllocationsPanel() {
  const snapshot = useContext(SnapshotContext);
  const jfr = snapshot.jfr;
  const hasAllocationPaths = jfr && jfr.topAllocationPaths && jfr.topAllocationPaths.length > 0;

  return (
    <>
      <section class="panel">
        <h2>Allocations</h2>
        <table>
          <thead>
            <tr>
              <th>Class</th>
              <th>Count</th>
              <th>JFR Samples</th>
              <th>JFR Bytes</th>
            </tr>
          </thead>
          <tbody>
            {snapshot.allocations.map((alloc, i) => (
              <tr key={i}>
                <td class="method-name">{alloc.className}</td>
                <td class="numeric">{formatInt(alloc.count)}</td>
                <td class="numeric">{formatInt(alloc.jfrSampleCount || 0)}</td>
                <td class="numeric">{formatInt(alloc.jfrSampleBytes || 0)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </section>

      {hasAllocationPaths && (
        <section class="panel">
          <h2>Allocation Hot Paths</h2>
          <table>
            <thead>
              <tr>
                <th>Path</th>
                <th>Class</th>
                <th>Samples</th>
                <th>Bytes</th>
              </tr>
            </thead>
            <tbody>
              {jfr.topAllocationPaths.map((alloc, i) => (
                <tr key={i}>
                  <td class="method-name">{alloc.pathName}</td>
                  <td class="method-name">{alloc.className}</td>
                  <td class="numeric">{formatInt(alloc.samples)}</td>
                  <td class="numeric">{formatInt(alloc.bytes)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </section>
      )}
    </>
  );
}
