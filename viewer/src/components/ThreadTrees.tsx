import { useContext } from "preact/hooks";
import { SnapshotContext } from "../context";
import { formatMs, formatInt } from "../format";
import type { FrameNode } from "../types";

interface Props {
  query: string;
}

function FrameNodeView({ frame }: { frame: FrameNode }) {
  return (
    <div class="tree-node">
      <div class="method-name">{frame.name}</div>
      <div class="meta">
        Net {formatMs(frame.netTimeNanos)} &middot; Total {formatMs(frame.totalTimeNanos)} &middot;
        Calls {formatInt(frame.count)}
      </div>
      {frame.children.map((child, i) => (
        <FrameNodeView frame={child} key={i} />
      ))}
    </div>
  );
}

export function ThreadTrees({ query }: Props) {
  const snapshot = useContext(SnapshotContext);

  const filtered = snapshot.threads.filter((thread) => {
    if (!query) return true;
    return (
      String(thread.threadId).includes(query) ||
      JSON.stringify(thread).toLowerCase().includes(query)
    );
  });

  return (
    <section class="panel">
      <h2>Thread Call Trees</h2>
      <div class="tree-stack">
        {filtered.map((thread) => (
          <details open key={thread.threadId}>
            <summary>
              Thread {thread.threadId} &middot; {formatMs(thread.totalTimeNanos)}
            </summary>
            {thread.interactions.map((interaction, index) => (
              <details open={index === 0} key={index}>
                <summary>Interaction {index + 1}</summary>
                <FrameNodeView frame={interaction} />
              </details>
            ))}
          </details>
        ))}
      </div>
    </section>
  );
}
