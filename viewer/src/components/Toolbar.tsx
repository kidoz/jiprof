import { useRef, useContext } from "preact/hooks";
import { SnapshotContext, methodSearch, threadSearch, comparisonSnapshot } from "../context";
import type { SnapshotDocument } from "../types";

function downloadJson(filename: string, payload: unknown) {
  const blob = new Blob([JSON.stringify(payload, null, 2)], { type: "application/json" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  link.remove();
  URL.revokeObjectURL(url);
}

export function Toolbar() {
  const snapshot = useContext(SnapshotContext);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const baseline = comparisonSnapshot.value;

  const handleCompareFile = async (e: Event) => {
    const input = e.target as HTMLInputElement;
    const file = input.files?.[0];
    if (!file) return;

    try {
      const text = await file.text();
      const parsed = JSON.parse(text) as SnapshotDocument;
      if (!parsed || !Array.isArray(parsed.methodSummary) || !parsed.summary) {
        throw new Error("The selected file is not a JIP JSON snapshot.");
      }
      comparisonSnapshot.value = parsed;
    } catch (error) {
      comparisonSnapshot.value = null;
      alert(error instanceof Error ? error.message : "Unable to read the baseline snapshot.");
    } finally {
      input.value = "";
    }
  };

  const statusText = baseline
    ? `Comparing ${snapshot.snapshotLabel || "current snapshot"} against ${baseline.snapshotLabel || baseline.generatedAt || "baseline snapshot"}.`
    : "No baseline snapshot loaded.";

  const inputCls =
    "h-9 w-full rounded-md border border-line bg-surface-strong px-3 font-sans text-sm";
  const btnCls =
    "inline-flex h-9 items-center justify-center whitespace-nowrap rounded-md px-3 text-sm font-semibold";

  return (
    <div class="mt-3 grid grid-cols-1 items-start gap-2 lg:grid-cols-[1fr_1fr_auto]">
      <input
        type="search"
        placeholder="Filter methods, classes, or signatures"
        class={inputCls}
        value={methodSearch.value}
        onInput={(e) => {
          methodSearch.value = (e.target as HTMLInputElement).value.trim().toLowerCase();
        }}
      />
      <input
        type="search"
        placeholder="Filter thread trees"
        class={inputCls}
        value={threadSearch.value}
        onInput={(e) => {
          threadSearch.value = (e.target as HTMLInputElement).value.trim().toLowerCase();
        }}
      />
      <div class="grid gap-1.5">
        <div class="flex flex-wrap gap-1.5">
          <label
            class={`${btnCls} cursor-pointer bg-accent text-white`}
            onClick={() => fileInputRef.current?.click()}
          >
            Load Baseline Snapshot
          </label>
          <button
            type="button"
            class={`${btnCls} border border-line bg-surface-strong text-ink`}
            onClick={() => {
              const label = (snapshot.snapshotLabel || "snapshot").replaceAll(
                /[^a-zA-Z0-9._-]+/g,
                "-",
              );
              downloadJson(`${label}.json`, snapshot);
            }}
          >
            Download Snapshot
          </button>
          {baseline && (
            <button
              type="button"
              class={`${btnCls} border border-line bg-surface-strong text-ink`}
              onClick={() => {
                comparisonSnapshot.value = null;
              }}
            >
              Clear Compare
            </button>
          )}
        </div>
        <input
          ref={fileInputRef}
          type="file"
          accept=".json,application/json"
          class="hidden"
          onChange={handleCompareFile}
        />
        <div class="rounded-md border border-line bg-surface-strong px-3 py-1.5 text-sm text-muted">
          {statusText}
        </div>
      </div>
    </div>
  );
}
