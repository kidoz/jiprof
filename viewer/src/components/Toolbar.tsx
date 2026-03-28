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
        throw new Error("The selected file is not a JIP modern JSON snapshot.");
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

  return (
    <div class="toolbar">
      <input
        type="search"
        placeholder="Filter methods, classes, or signatures"
        value={methodSearch.value}
        onInput={(e) => {
          methodSearch.value = (e.target as HTMLInputElement).value.trim().toLowerCase();
        }}
      />
      <input
        type="search"
        placeholder="Filter thread trees"
        value={threadSearch.value}
        onInput={(e) => {
          threadSearch.value = (e.target as HTMLInputElement).value.trim().toLowerCase();
        }}
      />
      <div class="toolbar-item">
        <div class="button-row">
          <label class="button" onClick={() => fileInputRef.current?.click()}>
            Load Baseline Snapshot
          </label>
          <button
            type="button"
            class="button secondary"
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
              class="button secondary"
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
          onChange={handleCompareFile}
        />
        <div class={`status-pill ${baseline ? "" : "muted"}`}>{statusText}</div>
      </div>
    </div>
  );
}
