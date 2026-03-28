import { useContext } from "preact/hooks";
import { SnapshotContext } from "../context";
import { Panel } from "./App";

export function ArtifactsPanel() {
  const snapshot = useContext(SnapshotContext);
  const entries = Object.entries(snapshot.artifacts).filter(([, path]) => path);

  return (
    <Panel title="Artifacts">
      <div class="grid gap-1 font-mono text-[0.7rem] break-all">
        {entries.map(([name, path]) => (
          <div key={name}>
            <strong>{name}</strong>
            <br />
            {path}
          </div>
        ))}
      </div>
    </Panel>
  );
}
