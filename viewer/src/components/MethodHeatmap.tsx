import { useContext } from "preact/hooks";
import { SnapshotContext } from "../context";
import { formatMs, formatInt } from "../format";

export function MethodHeatmap() {
  const snapshot = useContext(SnapshotContext);
  const methods = (snapshot.methodSummary || []).slice(0, 12);

  if (!methods.length) {
    return (
      <div class="rounded-md border border-line bg-surface-strong p-3">
        <h3 class="mb-1 text-xs font-bold uppercase tracking-wide text-muted">Method Heatmap</h3>
        <p class="text-sm text-muted">
          The strongest tiles combine net-time dominance and call density to surface hotspots at a
          glance.
        </p>
        <div class="text-muted">No method summary is available for this snapshot.</div>
      </div>
    );
  }

  const maxNetTime = Math.max(...methods.map((m) => m.netTimeNanos || 0), 1);
  const maxCount = Math.max(...methods.map((m) => m.count || 0), 1);

  return (
    <div class="rounded-md border border-line bg-surface-strong p-3">
      <h3 class="mb-1 text-xs font-bold uppercase tracking-wide text-muted">Method Heatmap</h3>
      <p class="mb-2 text-sm text-muted">
        The strongest tiles combine net-time dominance and call density to surface hotspots at a
        glance.
      </p>
      <div class="grid grid-cols-[repeat(auto-fit,minmax(8rem,1fr))] gap-1.5">
        {methods.map((method, index) => {
          const netRatio = (method.netTimeNanos || 0) / maxNetTime;
          const countRatio = (method.count || 0) / maxCount;
          const intensity = Math.min(1, netRatio * 0.75 + countRatio * 0.25);
          const hue = 20 + (1 - Math.min(netRatio, 1)) * 130;
          const bg = `hsla(${hue}, 65%, ${92 - intensity * 38}%, 0.95)`;
          return (
            <article
              class="grid min-h-20 content-start gap-0.5 rounded-md border border-black/5 p-2"
              style={{ background: bg }}
              key={index}
            >
              <div class="text-[0.6rem] font-semibold uppercase tracking-wide text-muted">
                Rank {index + 1}
              </div>
              <div class="break-all font-mono text-[0.7rem]">{method.name}</div>
              <div class="text-[0.7rem] text-black/55">Net {formatMs(method.netTimeNanos || 0)}</div>
              <div class="text-[0.7rem] text-black/55">
                Total {formatMs(method.totalTimeNanos || 0)}
              </div>
              <div class="text-[0.7rem] text-black/55">Calls {formatInt(method.count || 0)}</div>
            </article>
          );
        })}
      </div>
    </div>
  );
}
