import { useContext } from "preact/hooks";
import { SnapshotContext } from "../context";
import { formatMs, formatInt, toLocalHref } from "../format";
import { Panel } from "./App";

export function HistoryPanel() {
  const snapshot = useContext(SnapshotContext);
  const history = snapshot.history;

  if (!history || !history.enabled || !(history.entries || []).length) return null;

  const caption = history.indexArtifact
    ? `This snapshot includes the most recent local recordings from ${history.indexArtifact}.`
    : "This snapshot includes the most recent local recordings captured into the same output directory.";

  const thCls = "text-left text-[0.65rem] font-semibold uppercase tracking-wide text-muted";
  const tdCls = "px-2 py-1.5 border-b border-line align-top";
  const numCls = `${tdCls} font-mono text-[0.7rem] whitespace-nowrap`;
  const codeCls = `${tdCls} font-mono text-[0.7rem] break-all`;

  return (
    <Panel title="Recent Recordings">
      <p class="mb-3 text-sm text-muted">{caption}</p>
      <table class="w-full border-collapse text-sm">
        <thead>
          <tr>
            <th class={thCls}>Snapshot</th>
            <th class={thCls}>Generated</th>
            <th class={thCls}>Observed</th>
            <th class={thCls}>Threads</th>
            <th class={thCls}>Top Method</th>
            <th class={thCls}>Artifacts</th>
          </tr>
        </thead>
        <tbody>
          {(history.entries || []).map((entry, i) => {
            const label = entry.current ? `${entry.snapshotLabel} (current)` : entry.snapshotLabel;
            const artifacts: { name: string; href: string }[] = [];
            if (entry.json)
              artifacts.push({ name: "json", href: encodeURI(toLocalHref(entry.json)) });
            if (entry.html)
              artifacts.push({ name: "html", href: encodeURI(toLocalHref(entry.html)) });
            if (entry.jfr)
              artifacts.push({ name: "jfr", href: encodeURI(toLocalHref(entry.jfr)) });

            return (
              <tr key={i}>
                <td class={codeCls}>{label}</td>
                <td class={numCls}>{entry.generatedAt || "n/a"}</td>
                <td class={numCls}>{formatMs(entry.totalObservedTimeNanos || 0)}</td>
                <td class={numCls}>{formatInt(entry.threadCount || 0)}</td>
                <td class={codeCls}>{entry.topMethod || "n/a"}</td>
                <td class={tdCls}>
                  {artifacts.length === 0 ? (
                    <span class="text-muted">n/a</span>
                  ) : (
                    artifacts.map((a, j) => (
                      <span key={j}>
                        {j > 0 && " \u00B7 "}
                        <a href={a.href} target="_blank" rel="noreferrer" class="text-accent underline">
                          {a.name}
                        </a>
                      </span>
                    ))
                  )}
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </Panel>
  );
}
