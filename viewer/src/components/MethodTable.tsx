import { formatMs, formatInt } from "../format";
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

  return (
    <section class="panel">
      <h2>{title}</h2>
      <table>
        <thead>
          <tr>
            <th>Method</th>
            <th>Net</th>
            <th>Total</th>
            <th>Calls</th>
          </tr>
        </thead>
        <tbody>
          {filtered.map((method, i) => {
            const width = Math.max(2, (method.netTimeNanos / totalObserved) * 100);
            return (
              <tr key={i}>
                <td>
                  <div class="method-name">{method.name}</div>
                  <div class="bar">
                    <span style={{ width: `${width}%` }} />
                  </div>
                </td>
                <td class="numeric">{formatMs(method.netTimeNanos)}</td>
                <td class="numeric">{formatMs(method.totalTimeNanos)}</td>
                <td class="numeric">{formatInt(method.count)}</td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </section>
  );
}
