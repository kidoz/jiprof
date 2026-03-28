import { useContext, useMemo } from "preact/hooks";
import { SnapshotContext } from "../context";
import { formatMs, formatInt, colorForName } from "../format";
import type { FrameNode, ThreadSnapshot } from "../types";

interface IcicleSegment {
  left: number;
  width: number;
  name: string;
  totalTimeNanos: number;
  netTimeNanos: number;
  count: number;
  depth: number;
}

function flattenIcicleSegments(
  frame: FrameNode,
  rootTotal: number,
  depth: number,
  leftOffset: number,
  rows: IcicleSegment[][],
) {
  const total = Math.max(frame.totalTimeNanos || 0, frame.netTimeNanos || 0, 1);
  const width = (total / Math.max(rootTotal, 1)) * 100;
  if (!rows[depth]) rows[depth] = [];
  rows[depth].push({
    left: leftOffset,
    width,
    name: frame.name,
    totalTimeNanos: frame.totalTimeNanos || 0,
    netTimeNanos: frame.netTimeNanos || 0,
    count: frame.count || 0,
    depth,
  });

  let childOffset = leftOffset;
  (frame.children || []).forEach((child) => {
    const childTotal = Math.max(child.totalTimeNanos || 0, child.netTimeNanos || 0, 0);
    const childWidth = (childTotal / Math.max(rootTotal, 1)) * 100;
    flattenIcicleSegments(child, rootTotal, depth + 1, childOffset, rows);
    childOffset += childWidth;
  });
}

function findHottestInteraction(
  threads: ThreadSnapshot[],
): { threadId: number; interaction: FrameNode } | null {
  let hottest: { threadId: number; interaction: FrameNode } | null = null;
  for (const thread of threads || []) {
    for (const interaction of thread.interactions || []) {
      if (
        !hottest ||
        (interaction.totalTimeNanos || 0) > (hottest.interaction.totalTimeNanos || 0)
      ) {
        hottest = { threadId: thread.threadId, interaction };
      }
    }
  }
  return hottest;
}

export function IcicleChart() {
  const snapshot = useContext(SnapshotContext);
  const hottest = useMemo(() => findHottestInteraction(snapshot.threads), [snapshot.threads]);

  if (!hottest) {
    return (
      <div class="viz-card">
        <h3>Icicle View</h3>
        <p class="viz-caption">No thread interactions are available for this snapshot.</p>
        <div class="muted">No icicle data available.</div>
      </div>
    );
  }

  const root = hottest.interaction;
  const rows: IcicleSegment[][] = [];
  flattenIcicleSegments(root, Math.max(root.totalTimeNanos || 0, 1), 0, 0, rows);

  return (
    <div class="viz-card">
      <h3>Icicle View</h3>
      <p class="viz-caption">
        Showing the hottest recorded interaction from thread {hottest.threadId}. Block widths are
        proportional to total observed time.
      </p>
      <div class="icicle-chart">
        {rows.map((segments, rowIndex) => (
          <div class="icicle-row" key={rowIndex}>
            {segments
              .filter((s) => s.width >= 1.5)
              .map((s, si) => (
                <div
                  key={si}
                  class="icicle-segment"
                  style={{
                    left: `${s.left}%`,
                    width: `${Math.max(s.width, 1.5)}%`,
                    background: colorForName(s.name, s.depth),
                  }}
                  title={`${s.name} | total ${formatMs(s.totalTimeNanos)} | net ${formatMs(s.netTimeNanos)} | calls ${formatInt(s.count)}`}
                >
                  <span class="segment-label">{s.name}</span>
                  <span class="segment-meta">
                    {formatMs(s.totalTimeNanos)} &middot; {formatInt(s.count)}
                  </span>
                </div>
              ))}
          </div>
        ))}
      </div>
    </div>
  );
}
