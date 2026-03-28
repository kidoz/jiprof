import { useContext } from "preact/hooks";
import { SnapshotContext } from "../context";

export function ArtifactsPanel() {
  const snapshot = useContext(SnapshotContext);
  const entries = Object.entries(snapshot.artifacts).filter(([, path]) => path);

  return (
    <section class="panel">
      <h2>Artifacts</h2>
      <div class="artifact-list">
        {entries.map(([name, path]) => (
          <div key={name}>
            <strong>{name}</strong>
            <br />
            {path}
          </div>
        ))}
      </div>
    </section>
  );
}
