export function formatMs(nanos: number): string {
  return `${(nanos / 1_000_000).toFixed(3)} ms`;
}

export function formatInt(value: number): string {
  return new Intl.NumberFormat().format(value);
}

export function formatSignedMs(nanos: number): string {
  const sign = nanos > 0 ? "+" : nanos < 0 ? "-" : "";
  return `${sign}${formatMs(Math.abs(nanos))}`;
}

export function formatSignedInt(value: number): string {
  const sign = value > 0 ? "+" : value < 0 ? "-" : "";
  return `${sign}${formatInt(Math.abs(value))}`;
}

export function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

export function toLocalHref(path: string): string {
  if (!path) return "";
  if (/^[a-zA-Z]+:\/\//.test(path)) return path;
  if (/^[a-zA-Z]:[\\/]/.test(path)) return `file:///${path.replaceAll("\\\\", "/")}`;
  if (path.startsWith("/")) return `file://${path}`;
  return path;
}

export function deltaClass(value: number): string {
  if (value > 0) return "delta-positive";
  if (value < 0) return "delta-negative";
  return "muted";
}

export function colorForName(name: string, depth: number = 0): string {
  let hash = 0;
  const source = `${name}:${depth}`;
  for (let i = 0; i < source.length; i++) {
    hash = (hash * 31 + source.charCodeAt(i)) >>> 0;
  }
  const hue = hash % 360;
  const lightness = Math.max(34, 58 - depth * 4);
  return `hsl(${hue} 58% ${lightness}%)`;
}
