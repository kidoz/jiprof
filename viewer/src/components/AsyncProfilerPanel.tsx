import { useContext } from "preact/hooks";
import { SnapshotContext } from "../context";
import { formatInt, toLocalHref } from "../format";

export function AsyncProfilerPanel() {
  const snapshot = useContext(SnapshotContext);
  const ap = snapshot.asyncProfiler;

  if (!ap || !ap.enabled) return null;

  const collapsed = ap.collapsed || ({} as typeof ap.collapsed);

  return (
    <section class="panel">
      <h2>Async-Profiler Imports</h2>

      {ap.warning && <p class="warning">{ap.warning}</p>}

      <div class="artifact-list" style={{ marginBottom: "1rem" }}>
        {(ap.artifacts || []).length === 0 ? (
          <div class="muted">No external async-profiler artifacts were attached.</div>
        ) : (
          ap.artifacts.map((artifact, i) => (
            <div key={i}>
              <strong>{artifact.label || artifact.type || "artifact"}</strong>{" "}
              <span class="muted">({artifact.type || "file"})</span>
              <br />
              <a
                href={encodeURI(toLocalHref(artifact.path || ""))}
                target="_blank"
                rel="noreferrer"
              >
                {artifact.path || ""}
              </a>
            </div>
          ))
        )}
      </div>

      {(collapsed.topLeafFrames || []).length > 0 && (
        <table>
          <thead>
            <tr>
              <th>Leaf Frame</th>
              <th>Samples</th>
            </tr>
          </thead>
          <tbody>
            {collapsed.topLeafFrames.map((frame, i) => (
              <tr key={i}>
                <td class="method-name">{frame.name}</td>
                <td class="numeric">{formatInt(frame.samples)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      {(collapsed.topStacks || []).length > 0 && (
        <table style={{ marginTop: "1rem" }}>
          <thead>
            <tr>
              <th>Leaf Frame</th>
              <th>Samples</th>
              <th>Collapsed Stack</th>
            </tr>
          </thead>
          <tbody>
            {collapsed.topStacks.map((stack, i) => (
              <tr key={i}>
                <td class="method-name">{stack.leafFrame}</td>
                <td class="numeric">{formatInt(stack.samples)}</td>
                <td class="method-name">{stack.stack}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </section>
  );
}
