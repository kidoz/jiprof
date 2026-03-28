import { useContext } from "preact/hooks";
import { SnapshotContext } from "../context";
import { formatMs, formatInt } from "../format";

export function SummaryCards() {
  const snapshot = useContext(SnapshotContext);
  const hottest = snapshot.methodSummary[0];

  const cards: [string, string][] = [
    ["Threads", formatInt(snapshot.summary.threadCount)],
    ["Interactions", formatInt(snapshot.summary.interactionCount)],
    ["Frames", formatInt(snapshot.summary.frameCount)],
    ["Allocations", formatInt(snapshot.summary.allocationClassCount)],
    ["Observed", formatMs(snapshot.summary.totalObservedTimeNanos)],
  ];

  return (
    <section class="my-3 grid grid-cols-[repeat(auto-fit,minmax(8rem,1fr))] gap-2">
      {cards.map(([label, value]) => (
        <article
          class="rounded-lg border border-line bg-surface px-3 py-2 shadow-sm"
          key={label}
        >
          <div class="text-[0.65rem] font-semibold uppercase tracking-wide text-muted">
            {label}
          </div>
          <div class="text-lg font-bold leading-tight">{value}</div>
        </article>
      ))}
      {hottest && (
        <article class="col-span-2 rounded-lg border border-line bg-surface px-3 py-2 shadow-sm">
          <div class="text-[0.65rem] font-semibold uppercase tracking-wide text-muted">
            Hottest Method
          </div>
          <div class="font-mono text-sm font-semibold">{hottest.name}</div>
        </article>
      )}
    </section>
  );
}
