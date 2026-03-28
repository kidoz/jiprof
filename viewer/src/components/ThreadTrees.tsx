import { useContext } from "preact/hooks";
import { SnapshotContext } from "../context";
import { formatMs, formatInt } from "../format";
import { Panel } from "./App";
import type { FrameNode } from "../types";

interface Props {
  query: string;
}

function FrameNodeView({ frame }: { frame: FrameNode }) {
  return (
    <div class="ml-3 mt-1 border-l-2 border-accent/15 pl-3">
      <div class="font-mono text-[0.7rem]">{frame.name}</div>
      <div class="text-[0.65rem] text-muted">
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
    <Panel title="Thread Call Trees">
      <div class="grid gap-2">
        {filtered.map((thread) => (
          <details
            open
            key={thread.threadId}
            class="rounded-md border border-line bg-surface-strong p-2"
          >
            <summary class="cursor-pointer text-sm font-semibold [list-style:none]">
              Thread {thread.threadId} &middot; {formatMs(thread.totalTimeNanos)}
            </summary>
            {thread.interactions.map((interaction, index) => (
              <details
                open={index === 0}
                key={index}
                class="mt-1 rounded-md border border-line bg-surface-strong p-2"
              >
                <summary class="cursor-pointer text-sm font-semibold [list-style:none]">
                  Interaction {index + 1}
                </summary>
                <FrameNodeView frame={interaction} />
              </details>
            ))}
          </details>
        ))}
      </div>
    </Panel>
  );
}
