import { useContext, useMemo } from "preact/hooks";
import { SnapshotContext, comparisonSnapshot } from "../context";
import { formatMs, formatInt, formatSignedMs, formatSignedInt } from "../format";
import { computeDeltaRows, sumBy } from "../compare";
import { Panel } from "./App";
import type { SnapshotDocument } from "../types";

function deltaColor(value: number): string {
  if (value > 0) return "text-warn font-semibold";
  if (value < 0) return "text-accent font-semibold";
  return "text-muted";
}

function buildComparisonExport(
  snapshot: SnapshotDocument,
  baseline: SnapshotDocument,
  regressions: ReturnType<typeof computeDeltaRows>,
  improvements: ReturnType<typeof computeDeltaRows>,
  allocationChanges: Array<{
    key: string;
    delta: number;
    byteDelta: number;
    currentValue: number;
    baselineValue: number;
    currentBytes: number;
    baselineBytes: number;
  }>,
  jfrChanges: ReturnType<typeof computeDeltaRows>,
  observedDelta: number,
  allocationTotalDelta: number,
  methodDelta: ReturnType<typeof computeDeltaRows>,
) {
  return {
    generatedAt: new Date().toISOString(),
    currentLabel: snapshot.snapshotLabel || "current-snapshot",
    baselineLabel: baseline.snapshotLabel || baseline.generatedAt || "baseline-snapshot",
    observedDeltaNanos: observedDelta,
    allocationDelta: allocationTotalDelta,
    allocationByteChanges: allocationChanges.map((e) => ({
      className: e.key,
      deltaCount: e.delta,
      deltaJfrSampleBytes: e.byteDelta || 0,
      currentCount: e.currentValue,
      baselineCount: e.baselineValue,
      currentJfrSampleBytes: e.currentBytes || 0,
      baselineJfrSampleBytes: e.baselineBytes || 0,
    })),
    changedMethodCount: methodDelta.filter((e) => e.delta !== 0).length,
    regressions: regressions.map((e) => ({
      name: e.key,
      deltaNetTimeNanos: e.delta,
      currentNetTimeNanos: e.currentValue,
      baselineNetTimeNanos: e.baselineValue,
    })),
    improvements: improvements.map((e) => ({
      name: e.key,
      deltaNetTimeNanos: e.delta,
      currentNetTimeNanos: e.currentValue,
      baselineNetTimeNanos: e.baselineValue,
    })),
    allocationChanges: allocationChanges.map((e) => ({
      className: e.key,
      deltaCount: e.delta,
      deltaJfrSampleBytes: e.byteDelta || 0,
      currentCount: e.currentValue,
      baselineCount: e.baselineValue,
      currentJfrSampleBytes: e.currentBytes || 0,
      baselineJfrSampleBytes: e.baselineBytes || 0,
    })),
    jfrChanges: jfrChanges.map((e) => ({
      name: e.key,
      deltaSamples: e.delta,
      currentSamples: e.currentValue,
      baselineSamples: e.baselineValue,
    })),
  };
}

function downloadJson(filename: string, payload: unknown) {
  const blob = new Blob([JSON.stringify(payload, null, 2)], { type: "application/json" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  link.remove();
  URL.revokeObjectURL(url);
}

export function ComparePanel() {
  const snapshot = useContext(SnapshotContext);
  const baseline = comparisonSnapshot.value;

  const comparison = useMemo(() => {
    if (!baseline) return null;

    const methodDelta = computeDeltaRows(
      snapshot.methodSummary || [],
      baseline.methodSummary || [],
      (i) => i.name,
      (i) => i.netTimeNanos || 0,
      (i) => i.netTimeNanos || 0,
    );

    const allocationDelta = computeDeltaRows(
      snapshot.allocations || [],
      baseline.allocations || [],
      (i) => i.className,
      (i) => i.count || 0,
      (i) => i.count || 0,
    );

    const allocationBytesDelta = computeDeltaRows(
      snapshot.allocations || [],
      baseline.allocations || [],
      (i) => i.className,
      (i) => i.jfrSampleBytes || 0,
      (i) => i.jfrSampleBytes || 0,
    );

    const jfrDelta = computeDeltaRows(
      snapshot.jfr?.topSampledMethods || [],
      baseline.jfr?.topSampledMethods || [],
      (i) => i.name,
      (i) => i.samples || 0,
      (i) => i.samples || 0,
    );

    const regressions = methodDelta
      .filter((e) => e.delta > 0)
      .sort((a, b) => b.delta - a.delta)
      .slice(0, 12);
    const improvements = methodDelta
      .filter((e) => e.delta < 0)
      .sort((a, b) => a.delta - b.delta)
      .slice(0, 12);

    const allocationBytesByClass = new Map(allocationBytesDelta.map((e) => [e.key, e]));
    const allocationChanges = allocationDelta
      .map((e) => {
        const byteEntry = allocationBytesByClass.get(e.key);
        return {
          ...e,
          byteDelta: byteEntry ? byteEntry.delta : 0,
          currentBytes: byteEntry ? byteEntry.currentValue : 0,
          baselineBytes: byteEntry ? byteEntry.baselineValue : 0,
        };
      })
      .filter((e) => e.delta !== 0 || e.byteDelta !== 0)
      .sort(
        (a, b) =>
          Math.max(Math.abs(b.delta), Math.abs(b.byteDelta)) -
          Math.max(Math.abs(a.delta), Math.abs(a.byteDelta)),
      )
      .slice(0, 12);

    const jfrChanges = jfrDelta
      .filter((e) => e.delta !== 0)
      .sort((a, b) => Math.abs(b.delta) - Math.abs(a.delta))
      .slice(0, 12);

    const observedDelta =
      snapshot.summary.totalObservedTimeNanos -
      ((baseline.summary && baseline.summary.totalObservedTimeNanos) || 0);
    const currentAllocationTotal = sumBy(snapshot.allocations || [], (i) => i.count || 0);
    const baselineAllocationTotal = sumBy(baseline.allocations || [], (i) => i.count || 0);
    const allocationTotalDelta = currentAllocationTotal - baselineAllocationTotal;

    const exportData = buildComparisonExport(
      snapshot,
      baseline,
      regressions,
      improvements,
      allocationChanges,
      jfrChanges,
      observedDelta,
      allocationTotalDelta,
      methodDelta,
    );

    return {
      regressions,
      improvements,
      allocationChanges,
      jfrChanges,
      observedDelta,
      allocationTotalDelta,
      methodDelta,
      exportData,
    };
  }, [snapshot, baseline]);

  if (!baseline || !comparison) return null;

  const showJfr =
    comparison.jfrChanges.length > 0 ||
    (snapshot.jfr && snapshot.jfr.enabled) ||
    (baseline.jfr && baseline.jfr.enabled);

  const summaryCards: [string, string][] = [
    ["Current", snapshot.snapshotLabel || "n/a"],
    ["Baseline", baseline.snapshotLabel || baseline.generatedAt || "n/a"],
    ["Observed Delta", formatSignedMs(comparison.observedDelta)],
    ["Top Regression", comparison.regressions[0] ? comparison.regressions[0].key : "none"],
    ["Top Improvement", comparison.improvements[0] ? comparison.improvements[0].key : "none"],
    ["Allocation Delta", formatSignedInt(comparison.allocationTotalDelta)],
    ["Changed Methods", formatInt(comparison.methodDelta.filter((e) => e.delta !== 0).length)],
  ];

  const thCls = "text-left text-[0.65rem] font-semibold uppercase tracking-wide text-muted";
  const tdCls = "px-2 py-1.5 border-b border-line align-top";
  const numCls = `${tdCls} font-mono text-[0.7rem] whitespace-nowrap`;
  const codeCls = `${tdCls} font-mono text-[0.7rem] break-all`;

  return (
    <Panel title="Snapshot Compare">
      <p class="mb-3 text-sm text-muted">
        Diffs are computed client-side from the current report and the baseline JSON snapshot you
        loaded.
      </p>

      <section class="my-3 grid grid-cols-[repeat(auto-fit,minmax(8rem,1fr))] gap-2">
        {summaryCards.map(([label, value]) => {
          let cls = "";
          if (label.includes("Delta") && String(value).startsWith("-"))
            cls = "text-accent font-semibold";
          else if (label.includes("Delta") && String(value).startsWith("+"))
            cls = "text-warn font-semibold";
          return (
            <article
              class="rounded-lg border border-line bg-surface px-3 py-2 shadow-sm"
              key={label}
            >
              <div class="text-[0.65rem] font-semibold uppercase tracking-wide text-muted">
                {label}
              </div>
              <div class={`text-lg font-bold leading-tight ${cls}`}>{value}</div>
            </article>
          );
        })}
      </section>

      <div class="mt-3 grid grid-cols-[repeat(auto-fit,minmax(16rem,1fr))] gap-3">
        <DeltaTable
          title="Regression Candidates"
          rows={comparison.regressions}
          emptyMessage="No method regressions detected."
          thCls={thCls}
          tdCls={tdCls}
          numCls={numCls}
          codeCls={codeCls}
          formatDelta={formatSignedMs}
          formatValue={formatMs}
        />
        <DeltaTable
          title="Improvements"
          rows={comparison.improvements}
          emptyMessage="No method improvements detected."
          thCls={thCls}
          tdCls={tdCls}
          numCls={numCls}
          codeCls={codeCls}
          formatDelta={formatSignedMs}
          formatValue={formatMs}
        />

        <section class="rounded-md border border-line bg-surface-strong p-3">
          <h3 class="mb-2 text-[0.65rem] font-bold uppercase tracking-wide text-muted">
            Allocation Delta
          </h3>
          <table class="w-full border-collapse text-sm">
            <thead>
              <tr>
                <th class={thCls}>Class</th>
                <th class={thCls}>Count Delta</th>
                <th class={thCls}>Bytes Delta</th>
                <th class={thCls}>Current</th>
                <th class={thCls}>Baseline</th>
              </tr>
            </thead>
            <tbody>
              {comparison.allocationChanges.length === 0 ? (
                <tr>
                  <td class={`${tdCls} text-muted`} colSpan={5}>
                    No allocation deltas detected.
                  </td>
                </tr>
              ) : (
                comparison.allocationChanges.map((e) => (
                  <tr key={e.key}>
                    <td class={codeCls}>{e.key}</td>
                    <td class={`${numCls} ${deltaColor(e.delta)}`}>
                      {formatSignedInt(e.delta)}
                    </td>
                    <td class={`${numCls} ${deltaColor(e.byteDelta || 0)}`}>
                      {formatSignedInt(e.byteDelta || 0)}
                    </td>
                    <td class={numCls}>
                      {formatInt(e.currentValue)} / {formatInt(e.currentBytes || 0)}
                    </td>
                    <td class={numCls}>
                      {formatInt(e.baselineValue)} / {formatInt(e.baselineBytes || 0)}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </section>

        {showJfr && (
          <section class="rounded-md border border-line bg-surface-strong p-3">
            <h3 class="mb-2 text-[0.65rem] font-bold uppercase tracking-wide text-muted">
              JFR Sample Delta
            </h3>
            <table class="w-full border-collapse text-sm">
              <thead>
                <tr>
                  <th class={thCls}>Method</th>
                  <th class={thCls}>Delta Samples</th>
                  <th class={thCls}>Current</th>
                  <th class={thCls}>Baseline</th>
                </tr>
              </thead>
              <tbody>
                {comparison.jfrChanges.length === 0 ? (
                  <tr>
                    <td class={`${tdCls} text-muted`} colSpan={4}>
                      No sampled JFR hotspot deltas detected.
                    </td>
                  </tr>
                ) : (
                  comparison.jfrChanges.map((e) => (
                    <tr key={e.key}>
                      <td class={codeCls}>{e.key}</td>
                      <td class={`${numCls} ${deltaColor(e.delta)}`}>
                        {formatSignedInt(e.delta)}
                      </td>
                      <td class={numCls}>{formatInt(e.currentValue)}</td>
                      <td class={numCls}>{formatInt(e.baselineValue)}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </section>
        )}
      </div>

      <div class="mt-3 flex gap-2">
        <button
          type="button"
          class="inline-flex h-9 items-center rounded-md border border-line bg-surface-strong px-3 text-sm font-semibold"
          onClick={() => {
            const currentLabel = (comparison.exportData.currentLabel || "current").replaceAll(
              /[^a-zA-Z0-9._-]+/g,
              "-",
            );
            const baselineLabel = (comparison.exportData.baselineLabel || "baseline").replaceAll(
              /[^a-zA-Z0-9._-]+/g,
              "-",
            );
            downloadJson(`${currentLabel}-vs-${baselineLabel}.compare.json`, comparison.exportData);
          }}
        >
          Download Compare
        </button>
      </div>
    </Panel>
  );
}

function DeltaTable({
  title,
  rows,
  emptyMessage,
  thCls,
  tdCls,
  numCls,
  codeCls,
  formatDelta,
  formatValue,
}: {
  title: string;
  rows: { key: string; delta: number; currentValue: number; baselineValue: number }[];
  emptyMessage: string;
  thCls: string;
  tdCls: string;
  numCls: string;
  codeCls: string;
  formatDelta: (n: number) => string;
  formatValue: (n: number) => string;
}) {
  return (
    <section class="rounded-md border border-line bg-surface-strong p-3">
      <h3 class="mb-2 text-[0.65rem] font-bold uppercase tracking-wide text-muted">{title}</h3>
      <table class="w-full border-collapse text-sm">
        <thead>
          <tr>
            <th class={thCls}>Method</th>
            <th class={thCls}>Delta Net</th>
            <th class={thCls}>Current</th>
            <th class={thCls}>Baseline</th>
          </tr>
        </thead>
        <tbody>
          {rows.length === 0 ? (
            <tr>
              <td class={`${tdCls} text-muted`} colSpan={4}>
                {emptyMessage}
              </td>
            </tr>
          ) : (
            rows.map((e) => (
              <tr key={e.key}>
                <td class={codeCls}>{e.key}</td>
                <td class={`${numCls} ${deltaColor(e.delta)}`}>{formatDelta(e.delta)}</td>
                <td class={numCls}>{formatValue(e.currentValue)}</td>
                <td class={numCls}>{formatValue(e.baselineValue)}</td>
              </tr>
            ))
          )}
        </tbody>
      </table>
    </section>
  );
}
