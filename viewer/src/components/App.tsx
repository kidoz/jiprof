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
      <div class="page">
        <section class="hero">
          <p class="eyebrow">JIP Modern Viewer</p>
          <h1>Profiling snapshot with a modern local report</h1>
          <p class="subtitle">
            This report is self-contained. It embeds the versioned JSON snapshot and renders the
            hottest methods, aggregated method totals, allocation counts, and per-thread interaction
            trees without requiring a server.
          </p>
          <Toolbar />
        </section>

        <SummaryCards />
        <InsightsPanel />
        <TimelinePanel />
        <HistoryPanel />

        <section class="panel">
          <h2>Advanced Visualizations</h2>
          <section class="viz-grid">
            <IcicleChart />
            <MethodHeatmap />
          </section>
        </section>

        <ComparePanel />

        <section class="layout">
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
        </section>

        <ThreadTrees query={threadSearch.value} />
      </div>
    </SnapshotContext.Provider>
  );
}
