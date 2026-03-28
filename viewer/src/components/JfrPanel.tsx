import { useContext } from "preact/hooks";
import { SnapshotContext } from "../context";
import { formatMs, formatInt } from "../format";
import { Panel } from "./App";

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

  const thCls = "text-left text-[0.65rem] font-semibold uppercase tracking-wide text-muted";
  const tdCls = "px-2 py-1.5 border-b border-line align-top";
  const numCls = `${tdCls} font-mono text-[0.7rem] whitespace-nowrap`;
  const codeCls = `${tdCls} font-mono text-[0.7rem] break-all`;

  return (
    <Panel title="JFR Sampled Hotspots">
      {jfr.warning && <p class="text-sm text-warn">{jfr.warning}</p>}

      <div class="mb-3 grid gap-1 font-mono text-[0.7rem] break-all">
        {metadataLines.map((line, i) => (
          <div key={i}>{line}</div>
        ))}
      </div>

      <table class="w-full border-collapse text-sm">
        <thead>
          <tr>
            <th class={thCls}>Method</th>
            <th class={thCls}>Samples</th>
          </tr>
        </thead>
        <tbody>
          {(jfr.topSampledMethods || []).length === 0 ? (
            <tr>
              <td class={`${tdCls} text-muted`} colSpan={2}>
                No sampled Java hotspots were captured for this snapshot.
              </td>
            </tr>
          ) : (
            jfr.topSampledMethods.map((method, i) => (
              <tr key={i}>
                <td class={codeCls}>{method.name}</td>
                <td class={numCls}>{formatInt(method.samples)}</td>
              </tr>
            ))
          )}
        </tbody>
      </table>

      {(jfr.topAllocationSamples || []).length > 0 && (
        <table class="mt-3 w-full border-collapse text-sm">
          <thead>
            <tr>
              <th class={thCls}>Allocation Class</th>
              <th class={thCls}>Samples</th>
              <th class={thCls}>Bytes</th>
            </tr>
          </thead>
          <tbody>
            {jfr.topAllocationSamples.map((alloc, i) => (
              <tr key={i}>
                <td class={codeCls}>{alloc.className}</td>
                <td class={numCls}>{formatInt(alloc.samples)}</td>
                <td class={numCls}>{formatInt(alloc.bytes)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      {(jfr.topContentionSamples || []).length > 0 && (
        <table class="mt-3 w-full border-collapse text-sm">
          <thead>
            <tr>
              <th class={thCls}>Contention Site</th>
              <th class={thCls}>Events</th>
              <th class={thCls}>Duration</th>
            </tr>
          </thead>
          <tbody>
            {jfr.topContentionSamples.map((c, i) => (
              <tr key={i}>
                <td class={codeCls}>{c.name}</td>
                <td class={numCls}>{formatInt(c.eventCount)}</td>
                <td class={numCls}>{formatMs(c.durationNanos)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </Panel>
  );
}
