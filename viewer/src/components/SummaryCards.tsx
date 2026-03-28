import { useContext } from "preact/hooks";
import { SnapshotContext } from "../context";
import { formatMs, formatInt } from "../format";

export function SummaryCards() {
  const snapshot = useContext(SnapshotContext);
  const hottest = snapshot.methodSummary[0];

  const cards: [string, string][] = [
    ["Schema", snapshot.schemaVersion],
    ["Label", snapshot.snapshotLabel || "profile"],
    ["Generated", snapshot.generatedAt],
    ["Threads", formatInt(snapshot.summary.threadCount)],
    ["Frames", formatInt(snapshot.summary.frameCount)],
    ["Observed", formatMs(snapshot.summary.totalObservedTimeNanos)],
    ["Hottest Method", hottest ? hottest.name : "n/a"],
  ];

  return (
    <section class="card-grid">
      {cards.map(([label, value]) => (
        <article class="card" key={label}>
          <div class="label">{label}</div>
          <div class="value">{value}</div>
        </article>
      ))}
    </section>
  );
}
