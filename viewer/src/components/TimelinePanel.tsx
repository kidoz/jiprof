import { useContext } from "preact/hooks";
import { SnapshotContext } from "../context";
import { formatMs, formatInt } from "../format";
import type { JfrTimelineBucket } from "../types";

export function TimelinePanel() {
  const snapshot = useContext(SnapshotContext);
  const timeline = snapshot.timeline;

  if (!timeline) return null;

  const jfrByBucket = new Map<number, JfrTimelineBucket>(
    (timeline.jfrBuckets || []).map((b) => [b.bucketIndex, b]),
  );

  return (
    <section class="panel">
      <h2>Timeline</h2>
      <p class="muted">
        Coarse runtime buckets show how observed time moves through the capture window. JFR counts
        are overlaid when the companion recording is enabled.
      </p>
      <section class="layout">
        <div>
          <table>
            <thead>
              <tr>
                <th>Window</th>
                <th>Observed</th>
                <th>Events</th>
                <th>Threads</th>
                <th>JFR Samples</th>
                <th>JFR Contention</th>
              </tr>
            </thead>
            <tbody>
              {(timeline.buckets || []).length === 0 ? (
                <tr>
                  <td class="muted" colSpan={6}>
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
                      <td class="numeric">
                        {formatInt(bucket.startOffsetMs)}-{formatInt(bucket.endOffsetMs)} ms
                      </td>
                      <td class="numeric">{formatMs(bucket.observedTimeNanos)}</td>
                      <td class="numeric">{formatInt(bucket.eventCount)}</td>
                      <td class="numeric">{formatInt(bucket.activeThreadCount)}</td>
                      <td class="numeric">{formatInt(sampleCount)}</td>
                      <td class="numeric">{formatInt(jfr.contentionEvents || 0)}</td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
        <div>
          <table>
            <thead>
              <tr>
                <th>Thread</th>
                <th>Observed</th>
                <th>Events</th>
                <th>Peak Window</th>
              </tr>
            </thead>
            <tbody>
              {(timeline.threads || []).length === 0 ? (
                <tr>
                  <td class="muted" colSpan={4}>
                    No thread activity summary is available for this snapshot.
                  </td>
                </tr>
              ) : (
                (timeline.threads || []).map((thread) => (
                  <tr key={thread.threadId}>
                    <td class="numeric">{formatInt(thread.threadId)}</td>
                    <td class="numeric">{formatMs(thread.observedTimeNanos)}</td>
                    <td class="numeric">{formatInt(thread.eventCount)}</td>
                    <td class="numeric">
                      {formatInt(thread.peakStartOffsetMs)}-{formatInt(thread.peakEndOffsetMs)} ms
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </section>
    </section>
  );
}
