import { SnapshotContext, methodSearch, threadSearch } from "../context";
import { SummaryCards } from "./SummaryCards";
import { InsightsPanel } from "./InsightsPanel";
import { TimelinePanel } from "./TimelinePanel";
import { HistoryPanel } from "./HistoryPanel";
import { IcicleChart } from "./IcicleChart";
import { MethodHeatmap } from "./MethodHeatmap";
import { ComparePanel } from "./ComparePanel";
import { MethodTable } from "./MethodTable";
import { AllocationsPanel } from "./AllocationsPanel";
import { ArtifactsPanel } from "./ArtifactsPanel";
import { JfrPanel } from "./JfrPanel";
import { AsyncProfilerPanel } from "./AsyncProfilerPanel";
import { ThreadTrees } from "./ThreadTrees";
import { Toolbar } from "./Toolbar";
import type { SnapshotDocument } from "../types";

interface Props {
  snapshot: SnapshotDocument;
}

export function App({ snapshot }: Props) {
  return (
    <SnapshotContext.Provider value={snapshot}>
      <div class="mx-auto max-w-screen-xl px-4 py-4 pb-12">
        <header class="rounded-lg border border-line bg-surface p-4 shadow-sm">
          <div class="flex flex-wrap items-baseline gap-3">
            <h1 class="text-xl font-bold tracking-tight">
              {snapshot.snapshotLabel || "Profile Snapshot"}
            </h1>
            {snapshot.generatedAt !== snapshot.snapshotLabel && (
              <span class="text-sm text-muted">{snapshot.generatedAt}</span>
            )}
          </div>
          <Toolbar />
        </header>

        <SummaryCards />
        <InsightsPanel />
        <TimelinePanel />
        <HistoryPanel />

        <Panel title="Advanced Visualizations">
          <div class="grid grid-cols-1 items-start gap-3 lg:grid-cols-[1.3fr_0.7fr]">
            <IcicleChart />
            <MethodHeatmap />
          </div>
        </Panel>

        <ComparePanel />

        <div class="mt-3 grid grid-cols-1 items-start gap-3 lg:grid-cols-[1.2fr_0.8fr]">
          <div>
            <MethodTable
              title="Top Methods"
              methods={snapshot.topMethods}
              query={methodSearch.value}
              totalObservedTimeNanos={snapshot.summary.totalObservedTimeNanos}
            />
            <MethodTable
              title="Method Summary"
              methods={snapshot.methodSummary}
              query={methodSearch.value}
              totalObservedTimeNanos={snapshot.summary.totalObservedTimeNanos}
            />
          </div>
          <div>
            <AllocationsPanel />
            <ArtifactsPanel />
            <JfrPanel />
            <AsyncProfilerPanel />
          </div>
        </div>

        <ThreadTrees query={threadSearch.value} />
      </div>
    </SnapshotContext.Provider>
  );
}

export function Panel({
  title,
  children,
}: {
  title: string;
  children: preact.ComponentChildren;
}) {
  return (
    <section class="mt-3 rounded-lg border border-line bg-surface p-4 shadow-sm">
      <h2 class="mb-2 text-xs font-bold uppercase tracking-wide text-muted">{title}</h2>
      {children}
    </section>
  );
}
