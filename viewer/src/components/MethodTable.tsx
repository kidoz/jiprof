import { formatMs, formatInt } from "../format";
import { Panel } from "./App";
import type { MethodSummary } from "../types";

interface Props {
  title: string;
  methods: MethodSummary[];
  query: string;
  totalObservedTimeNanos: number;
}

export function MethodTable({ title, methods, query, totalObservedTimeNanos }: Props) {
  const totalObserved = Math.max(totalObservedTimeNanos, 1);

  const filtered = methods.filter((method) => {
    if (!query) return true;
    const haystack = `${method.name} ${method.className} ${method.methodName}`.toLowerCase();
    return haystack.includes(query);
  });

  const thCls = "text-left text-[0.65rem] font-semibold uppercase tracking-wide text-muted";
  const tdCls = "px-2 py-1.5 border-b border-line align-top";
  const numCls = `${tdCls} font-mono text-[0.7rem] whitespace-nowrap`;

  return (
    <Panel title={title}>
      <table class="w-full border-collapse text-sm">
        <thead>
          <tr>
            <th class={thCls}>Method</th>
            <th class={thCls}>Net</th>
            <th class={thCls}>Total</th>
            <th class={thCls}>Calls</th>
          </tr>
        </thead>
        <tbody>
          {filtered.map((method, i) => {
            const width = Math.max(2, (method.netTimeNanos / totalObserved) * 100);
            return (
              <tr key={i}>
                <td class={tdCls}>
                  <div class="font-mono text-[0.7rem] break-all">{method.name}</div>
                  <div class="mt-1 h-1 overflow-hidden rounded-sm bg-accent/10">
                    <span
                      class="block h-full bg-accent"
                      style={{ width: `${width}%` }}
                    />
                  </div>
                </td>
                <td class={numCls}>{formatMs(method.netTimeNanos)}</td>
                <td class={numCls}>{formatMs(method.totalTimeNanos)}</td>
                <td class={numCls}>{formatInt(method.count)}</td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </Panel>
  );
}
