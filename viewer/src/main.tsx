import { render } from "preact";
import { App } from "./components/App";
import type { SnapshotDocument } from "./types";
import "./styles.css";

const dataElement = document.getElementById("profile-data");
if (!dataElement || !dataElement.textContent) {
  throw new Error("Missing embedded profile data.");
}

const snapshot: SnapshotDocument = JSON.parse(dataElement.textContent);
const app = document.getElementById("app");
if (!app) {
  throw new Error("Missing app mount point.");
}

render(<App snapshot={snapshot} />, app);
