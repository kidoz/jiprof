import { useContext } from "preact/hooks";
import { SnapshotContext } from "../context";

export function InsightsPanel() {
  const snapshot = useContext(SnapshotContext);
  const insights = snapshot.insights || [];

  return (
    <section class="panel">
      <h2>Automated Insights</h2>
      <div class="insight-grid">
        {insights.length === 0 ? (
          <article class="insight-card">
            <div class="insight-head">
              <h3>No automatic bottlenecks flagged</h3>
              <span class="severity-pill medium">Clear</span>
            </div>
            <p class="muted">
              This snapshot did not cross the current insight thresholds. Use compare mode or JFR
              sampling to dig deeper.
            </p>
          </article>
        ) : (
          insights.map((insight, i) => (
            <article class="insight-card" key={i}>
              <div class="insight-head">
                <h3>{insight.title}</h3>
                <span class={`severity-pill ${insight.severity}`}>{insight.severity}</span>
              </div>
              <p>{insight.summary}</p>
              <div class="evidence-list">
                {(insight.evidence || []).map((item, j) => (
                  <div key={j}>{item}</div>
                ))}
              </div>
            </article>
          ))
        )}
      </div>
    </section>
  );
}
