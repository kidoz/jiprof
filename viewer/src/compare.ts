export interface DeltaRow<T> {
  key: string;
  current: T | undefined;
  baseline: T | undefined;
  currentValue: number;
  baselineValue: number;
  delta: number;
}

export function computeDeltaRows<T>(
  currentItems: T[],
  baselineItems: T[],
  keyGetter: (item: T) => string,
  currentValueGetter: (item: T) => number,
  baselineValueGetter: (item: T) => number,
): DeltaRow<T>[] {
  const currentMap = keyedMap(currentItems, keyGetter);
  const baselineMap = keyedMap(baselineItems, keyGetter);
  const keys = new Set([...currentMap.keys(), ...baselineMap.keys()]);

  return [...keys].map((key) => {
    const current = currentMap.get(key);
    const baseline = baselineMap.get(key);
    const currentValue = current ? currentValueGetter(current) : 0;
    const baselineValue = baseline ? baselineValueGetter(baseline) : 0;
    return {
      key,
      current,
      baseline,
      currentValue,
      baselineValue,
      delta: currentValue - baselineValue,
    };
  });
}

export function sumBy<T>(items: T[], valueGetter: (item: T) => number): number {
  return items.reduce((total, item) => total + valueGetter(item), 0);
}

function keyedMap<T>(items: T[], keyGetter: (item: T) => string): Map<string, T> {
  const map = new Map<string, T>();
  items.forEach((item) => map.set(keyGetter(item), item));
  return map;
}
