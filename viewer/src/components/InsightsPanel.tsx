import { useContext } from "preact/hooks";
import { SnapshotContext } from "../context";
import { Panel } from "./App";

const severityCls: Record<string, string> = {
  high: "bg-warn/10 text-warn",
  medium: "bg-accent/10 text-accent",
  low: "bg-accent-soft text-accent",
};

export function InsightsPanel() {
  const snapshot = useContext(SnapshotContext);
  const insights = snapshot.insights || [];

  return (
    <Panel title="Automated Insights">
      <div class="grid grid-cols-[repeat(auto-fit,minmax(15rem,1fr))] gap-2">
        {insights.length === 0 ? (
          <article class="grid gap-1.5 rounded-md border border-line bg-surface-strong p-3">
            <div class="flex items-center justify-between gap-2">
              <h3 class="text-sm font-semibold">No automatic bottlenecks flagged</h3>
              <span class="rounded-sm px-1.5 py-0.5 text-[0.65rem] font-bold uppercase bg-accent/10 text-accent">
                Clear
              </span>
            </div>
            <p class="text-sm text-muted">
              This snapshot did not cross the current insight thresholds. Use compare mode or JFR
              sampling to dig deeper.
            </p>
          </article>
        ) : (
          insights.map((insight, i) => (
            <article
              class="grid gap-1.5 rounded-md border border-line bg-surface-strong p-3"
              key={i}
            >
              <div class="flex items-center justify-between gap-2">
                <h3 class="text-sm font-semibold">{insight.title}</h3>
                <span
                  class={`rounded-sm px-1.5 py-0.5 text-[0.65rem] font-bold uppercase ${severityCls[insight.severity] || severityCls.low}`}
                >
                  {insight.severity}
                </span>
              </div>
              <p class="text-sm">{insight.summary}</p>
              <div class="grid gap-0.5 text-sm text-muted">
                {(insight.evidence || []).map((item, j) => (
                  <div key={j}>{item}</div>
                ))}
              </div>
            </article>
          ))
        )}
      </div>
    </Panel>
  );
}
