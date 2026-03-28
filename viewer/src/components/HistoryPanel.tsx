import { useContext } from "preact/hooks";
import { SnapshotContext } from "../context";
import { formatMs, formatInt, toLocalHref } from "../format";

export function HistoryPanel() {
  const snapshot = useContext(SnapshotContext);
  const history = snapshot.history;

  if (!history || !history.enabled || !(history.entries || []).length) return null;

  const caption = history.indexArtifact
    ? `This snapshot includes the most recent local recordings from ${history.indexArtifact}.`
    : "This snapshot includes the most recent local recordings captured into the same output directory.";

  return (
    <section class="panel">
      <h2>Recent Recordings</h2>
      <p class="muted">{caption}</p>
      <table>
        <thead>
          <tr>
            <th>Snapshot</th>
            <th>Generated</th>
            <th>Observed</th>
            <th>Threads</th>
            <th>Top Method</th>
            <th>Artifacts</th>
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
            if (entry.jfr) artifacts.push({ name: "jfr", href: encodeURI(toLocalHref(entry.jfr)) });

            return (
              <tr key={i}>
                <td class="method-name">{label}</td>
                <td class="numeric">{entry.generatedAt || "n/a"}</td>
                <td class="numeric">{formatMs(entry.totalObservedTimeNanos || 0)}</td>
                <td class="numeric">{formatInt(entry.threadCount || 0)}</td>
                <td class="method-name">{entry.topMethod || "n/a"}</td>
                <td>
                  {artifacts.length === 0 ? (
                    <span class="muted">n/a</span>
                  ) : (
                    artifacts.map((a, j) => (
                      <span key={j}>
                        {j > 0 && " \u00B7 "}
                        <a href={a.href} target="_blank" rel="noreferrer">
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
    </section>
  );
}
