import { useContext } from "preact/hooks";
import { SnapshotContext } from "../context";
import { formatMs, formatInt } from "../format";
import { Panel } from "./App";
import type { JfrTimelineBucket } from "../types";

export function TimelinePanel() {
  const snapshot = useContext(SnapshotContext);
  const timeline = snapshot.timeline;

  if (!timeline) return null;

  const jfrByBucket = new Map<number, JfrTimelineBucket>(
    (timeline.jfrBuckets || []).map((b) => [b.bucketIndex, b]),
  );

  const thCls = "text-left text-[0.65rem] font-semibold uppercase tracking-wide text-muted";
  const tdCls = "px-2 py-1.5 border-b border-line align-top";
  const numCls = `${tdCls} font-mono text-[0.7rem] whitespace-nowrap`;

  return (
    <Panel title="Timeline">
      <p class="mb-3 text-sm text-muted">
        Coarse runtime buckets show how observed time moves through the capture window. JFR counts
        are overlaid when the companion recording is enabled.
      </p>
      <div class="grid grid-cols-1 gap-3 lg:grid-cols-[1.2fr_0.8fr]">
        <div>
          <table class="w-full border-collapse text-sm">
            <thead>
              <tr>
                <th class={thCls}>Window</th>
                <th class={thCls}>Observed</th>
                <th class={thCls}>Events</th>
                <th class={thCls}>Threads</th>
                <th class={thCls}>JFR Samples</th>
                <th class={thCls}>JFR Contention</th>
              </tr>
            </thead>
            <tbody>
              {(timeline.buckets || []).length === 0 ? (
                <tr>
                  <td class={`${tdCls} text-muted`} colSpan={6}>
                    No runtime timeline buckets were captured for this snapshot.
                  </td>
                </tr>
              ) : (
                (timeline.buckets || []).map((bucket) => {
                  const jfr =
                    jfrByBucket.get(bucket.bucketIndex) || ({} as Partial<JfrTimelineBucket>);
                  const sampleCount =
                    (jfr.executionSamples || 0) +
                    (jfr.nativeSamples || 0) +
                    (jfr.cpuTimeSamples || 0);
                  return (
                    <tr key={bucket.bucketIndex}>
                      <td class={numCls}>
                        {formatInt(bucket.startOffsetMs)}-{formatInt(bucket.endOffsetMs)} ms
                      </td>
                      <td class={numCls}>{formatMs(bucket.observedTimeNanos)}</td>
                      <td class={numCls}>{formatInt(bucket.eventCount)}</td>
                      <td class={numCls}>{formatInt(bucket.activeThreadCount)}</td>
                      <td class={numCls}>{formatInt(sampleCount)}</td>
                      <td class={numCls}>{formatInt(jfr.contentionEvents || 0)}</td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
        <div>
          <table class="w-full border-collapse text-sm">
            <thead>
              <tr>
                <th class={thCls}>Thread</th>
                <th class={thCls}>Observed</th>
                <th class={thCls}>Events</th>
                <th class={thCls}>Peak Window</th>
              </tr>
            </thead>
            <tbody>
              {(timeline.threads || []).length === 0 ? (
                <tr>
                  <td class={`${tdCls} text-muted`} colSpan={4}>
                    No thread activity summary is available for this snapshot.
                  </td>
                </tr>
              ) : (
                (timeline.threads || []).map((thread) => (
                  <tr key={thread.threadId}>
                    <td class={numCls}>{formatInt(thread.threadId)}</td>
                    <td class={numCls}>{formatMs(thread.observedTimeNanos)}</td>
                    <td class={numCls}>{formatInt(thread.eventCount)}</td>
                    <td class={numCls}>
                      {formatInt(thread.peakStartOffsetMs)}-{formatInt(thread.peakEndOffsetMs)} ms
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </Panel>
  );
}
