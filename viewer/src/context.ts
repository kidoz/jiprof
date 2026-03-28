import { createContext } from "preact";
import { signal } from "@preact/signals";
import type { SnapshotDocument } from "./types";

export const SnapshotContext = createContext<SnapshotDocument>(null!);

export const methodSearch = signal("");
export const threadSearch = signal("");
export const comparisonSnapshot = signal<SnapshotDocument | null>(null);
