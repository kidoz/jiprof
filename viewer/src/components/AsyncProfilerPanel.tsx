import { useContext } from "preact/hooks";
import { SnapshotContext } from "../context";
import { formatInt, toLocalHref } from "../format";
import { Panel } from "./App";

export function AsyncProfilerPanel() {
  const snapshot = useContext(SnapshotContext);
  const ap = snapshot.asyncProfiler;

  if (!ap || !ap.enabled) return null;

  const collapsed = ap.collapsed || ({} as typeof ap.collapsed);

  const thCls = "text-left text-[0.65rem] font-semibold uppercase tracking-wide text-muted";
  const tdCls = "px-2 py-1.5 border-b border-line align-top";
  const numCls = `${tdCls} font-mono text-[0.7rem] whitespace-nowrap`;
  const codeCls = `${tdCls} font-mono text-[0.7rem] break-all`;

  return (
    <Panel title="Async-Profiler Imports">
      {ap.warning && <p class="text-sm text-warn">{ap.warning}</p>}

      <div class="mb-3 grid gap-1 font-mono text-[0.7rem] break-all">
        {(ap.artifacts || []).length === 0 ? (
          <div class="text-muted">No external async-profiler artifacts were attached.</div>
        ) : (
          ap.artifacts.map((artifact, i) => (
            <div key={i}>
              <strong>{artifact.label || artifact.type || "artifact"}</strong>{" "}
              <span class="text-muted">({artifact.type || "file"})</span>
              <br />
              <a
                href={encodeURI(toLocalHref(artifact.path || ""))}
                target="_blank"
                rel="noreferrer"
                class="text-accent underline"
              >
                {artifact.path || ""}
              </a>
            </div>
          ))
        )}
      </div>

      {(collapsed.topLeafFrames || []).length > 0 && (
        <table class="w-full border-collapse text-sm">
          <thead>
            <tr>
              <th class={thCls}>Leaf Frame</th>
              <th class={thCls}>Samples</th>
            </tr>
          </thead>
          <tbody>
            {collapsed.topLeafFrames.map((frame, i) => (
              <tr key={i}>
                <td class={codeCls}>{frame.name}</td>
                <td class={numCls}>{formatInt(frame.samples)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      {(collapsed.topStacks || []).length > 0 && (
        <table class="mt-3 w-full border-collapse text-sm">
          <thead>
            <tr>
              <th class={thCls}>Leaf Frame</th>
              <th class={thCls}>Samples</th>
              <th class={thCls}>Collapsed Stack</th>
            </tr>
          </thead>
          <tbody>
            {collapsed.topStacks.map((stack, i) => (
              <tr key={i}>
                <td class={codeCls}>{stack.leafFrame}</td>
                <td class={numCls}>{formatInt(stack.samples)}</td>
                <td class={codeCls}>{stack.stack}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </Panel>
  );
}
