import { useContext } from "preact/hooks";
import { SnapshotContext } from "../context";
import { formatMs, formatInt } from "../format";

export function MethodHeatmap() {
  const snapshot = useContext(SnapshotContext);
  const methods = (snapshot.methodSummary || []).slice(0, 12);

  if (!methods.length) {
    return (
      <div class="viz-card">
        <h3>Method Heatmap</h3>
        <p class="viz-caption">
          The strongest tiles combine net-time dominance and call density to surface hotspots at a
          glance.
        </p>
        <div class="muted">No method summary is available for this snapshot.</div>
      </div>
    );
  }

  const maxNetTime = Math.max(...methods.map((m) => m.netTimeNanos || 0), 1);
  const maxCount = Math.max(...methods.map((m) => m.count || 0), 1);

  return (
    <div class="viz-card">
      <h3>Method Heatmap</h3>
      <p class="viz-caption">
        The strongest tiles combine net-time dominance and call density to surface hotspots at a
        glance.
      </p>
      <div class="heatmap-grid">
        {methods.map((method, index) => {
          const netRatio = (method.netTimeNanos || 0) / maxNetTime;
          const countRatio = (method.count || 0) / maxCount;
          const intensity = Math.min(1, netRatio * 0.75 + countRatio * 0.25);
          const hue = 20 + (1 - Math.min(netRatio, 1)) * 130;
          const bg = `hsla(${hue}, 65%, ${92 - intensity * 38}%, 0.95)`;
          return (
            <article class="heatmap-tile" style={{ background: bg }} key={index}>
              <div class="label">Rank {index + 1}</div>
              <div class="tile-name">{method.name}</div>
              <div class="tile-meta">Net {formatMs(method.netTimeNanos || 0)}</div>
              <div class="tile-meta">Total {formatMs(method.totalTimeNanos || 0)}</div>
              <div class="tile-meta">Calls {formatInt(method.count || 0)}</div>
            </article>
          );
        })}
      </div>
    </div>
  );
}
