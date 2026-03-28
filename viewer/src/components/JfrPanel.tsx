import { useContext } from "preact/hooks";
import { SnapshotContext } from "../context";
import { formatMs, formatInt } from "../format";

export function JfrPanel() {
  const snapshot = useContext(SnapshotContext);
  const jfr = snapshot.jfr;

  if (!jfr || !jfr.enabled) return null;

  const meta = jfr.metadata;
  const lockEnabled =
    (meta && meta.monitorEnterEventsEnabled) ||
    (meta && meta.monitorWaitEventsEnabled) ||
    (meta && meta.threadParkEventsEnabled);

  const metadataLines = [
    `Sample period: ${formatInt((meta && meta.samplePeriodMs) || 0)} ms`,
    `Execution samples: ${meta && meta.executionSamplingEnabled ? "on" : "off"}`,
    `Native samples: ${meta && meta.nativeSamplingEnabled ? "on" : "off"}`,
    `CPU-time samples: ${meta && meta.cpuTimeSamplingEnabled ? "on" : "off"}`,
    `Allocation events: ${meta && meta.allocationEventsEnabled ? "on" : "off"}`,
    `Lock events: ${lockEnabled ? "on" : "off"}`,
  ];

  return (
    <section class="panel">
      <h2>JFR Sampled Hotspots</h2>

      {jfr.warning && <p class="warning">{jfr.warning}</p>}

      <div class="artifact-list" style={{ marginBottom: "1rem" }}>
        {metadataLines.map((line, i) => (
          <div key={i}>{line}</div>
        ))}
      </div>

      <table>
        <thead>
          <tr>
            <th>Method</th>
            <th>Samples</th>
          </tr>
        </thead>
        <tbody>
          {(jfr.topSampledMethods || []).length === 0 ? (
            <tr>
              <td class="muted" colSpan={2}>
                No sampled Java hotspots were captured for this snapshot.
              </td>
            </tr>
          ) : (
            jfr.topSampledMethods.map((method, i) => (
              <tr key={i}>
                <td class="method-name">{method.name}</td>
                <td class="numeric">{formatInt(method.samples)}</td>
              </tr>
            ))
          )}
        </tbody>
      </table>

      {(jfr.topAllocationSamples || []).length > 0 && (
        <table style={{ marginTop: "1rem" }}>
          <thead>
            <tr>
              <th>Allocation Class</th>
              <th>Samples</th>
              <th>Bytes</th>
            </tr>
          </thead>
          <tbody>
            {jfr.topAllocationSamples.map((alloc, i) => (
              <tr key={i}>
                <td class="method-name">{alloc.className}</td>
                <td class="numeric">{formatInt(alloc.samples)}</td>
                <td class="numeric">{formatInt(alloc.bytes)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      {(jfr.topContentionSamples || []).length > 0 && (
        <table style={{ marginTop: "1rem" }}>
          <thead>
            <tr>
              <th>Contention Site</th>
              <th>Events</th>
              <th>Duration</th>
            </tr>
          </thead>
          <tbody>
            {jfr.topContentionSamples.map((c, i) => (
              <tr key={i}>
                <td class="method-name">{c.name}</td>
                <td class="numeric">{formatInt(c.eventCount)}</td>
                <td class="numeric">{formatMs(c.durationNanos)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </section>
  );
}
