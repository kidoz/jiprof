export interface SnapshotDocument {
  schemaVersion: string;
  snapshotLabel: string;
  generatedAt: string;
  clockResolution: string;
  summary: Summary;
  timeline: Timeline | null;
  threads: ThreadSnapshot[];
  topMethods: MethodSummary[];
  methodSummary: MethodSummary[];
  allocations: Allocation[];
  jfr: JfrSection;
  asyncProfiler: AsyncProfilerSection;
  insights: Insight[];
  history: HistorySection;
  artifacts: Artifacts;
}

export interface Summary {
  threadCount: number;
  interactionCount: number;
  frameCount: number;
  allocationClassCount: number;
  totalObservedTimeNanos: number;
}

export interface Timeline {
  bucketSizeMs: number;
  durationNanos: number;
  jfrBucketSizeMs: number;
  buckets: TimelineBucket[];
  threads: ThreadActivity[];
  jfrBuckets: JfrTimelineBucket[];
}

export interface TimelineBucket {
  bucketIndex: number;
  startOffsetMs: number;
  endOffsetMs: number;
  observedTimeNanos: number;
  eventCount: number;
  activeThreadCount: number;
  topThreads: BucketThread[];
}

export interface BucketThread {
  threadId: number;
  observedTimeNanos: number;
}

export interface ThreadActivity {
  threadId: number;
  observedTimeNanos: number;
  eventCount: number;
  peakBucketIndex: number;
  peakStartOffsetMs: number;
  peakEndOffsetMs: number;
  peakObservedTimeNanos: number;
}

export interface JfrTimelineBucket {
  bucketIndex: number;
  startOffsetMs: number;
  endOffsetMs: number;
  executionSamples: number;
  nativeSamples: number;
  cpuTimeSamples: number;
  allocationEvents: number;
  contentionEvents: number;
}

export interface ThreadSnapshot {
  threadId: number;
  totalTimeNanos: number;
  interactions: FrameNode[];
}

export interface FrameNode {
  name: string;
  className: string;
  methodName: string;
  count: number;
  totalTimeNanos: number;
  netTimeNanos: number;
  children: FrameNode[];
}

export interface MethodSummary {
  name: string;
  className: string;
  methodName: string;
  count: number;
  totalTimeNanos: number;
  netTimeNanos: number;
}

export interface Allocation {
  className: string;
  internalClassName: string;
  count: number;
  jfrSampleCount: number;
  jfrSampleBytes: number;
}

export interface JfrSection {
  enabled: boolean;
  artifact: string;
  warning: string;
  metadata: JfrMetadata;
  executionSampleCount: number;
  nativeSampleCount: number;
  cpuTimeSampleCount: number;
  allocationSampleCount: number;
  monitorEnterCount: number;
  monitorWaitCount: number;
  threadParkCount: number;
  contentionEventCount: number;
  contentionDurationNanos: number;
  topSampledMethods: JfrMethodSample[];
  topAllocationSamples: JfrAllocationSample[];
  topAllocationPaths: JfrAllocationPath[];
  topContentionSamples: JfrContentionSample[];
}

export interface JfrMetadata {
  samplePeriodMs: number;
  executionSamplingEnabled: boolean;
  nativeSamplingEnabled: boolean;
  cpuTimeSamplingEnabled: boolean;
  allocationEventsEnabled: boolean;
  monitorEnterEventsEnabled: boolean;
  monitorWaitEventsEnabled: boolean;
  threadParkEventsEnabled: boolean;
}

export interface JfrMethodSample {
  name: string;
  samples: number;
}

export interface JfrAllocationSample {
  className: string;
  samples: number;
  bytes: number;
}

export interface JfrAllocationPath {
  className: string;
  pathName: string;
  samples: number;
  bytes: number;
}

export interface JfrContentionSample {
  name: string;
  monitorEnterCount: number;
  monitorWaitCount: number;
  threadParkCount: number;
  eventCount: number;
  durationNanos: number;
}

export interface AsyncProfilerSection {
  enabled: boolean;
  warning: string;
  artifacts: AsyncProfilerArtifact[];
  collapsed: CollapsedSection;
}

export interface AsyncProfilerArtifact {
  label: string;
  type: string;
  path: string;
}

export interface CollapsedSection {
  file: string;
  totalSamples: number;
  topLeafFrames: CollapsedFrame[];
  topStacks: CollapsedStack[];
}

export interface CollapsedFrame {
  name: string;
  samples: number;
}

export interface CollapsedStack {
  leafFrame: string;
  samples: number;
  stack: string;
}

export interface Insight {
  type: string;
  severity: string;
  title: string;
  summary: string;
  evidence: string[];
}

export interface HistorySection {
  enabled: boolean;
  indexArtifact: string;
  current: HistoryEntry | null;
  entries: HistoryEntry[];
}

export interface HistoryEntry {
  snapshotLabel: string;
  generatedAt: string;
  totalObservedTimeNanos: number;
  threadCount: number;
  topMethod: string;
  json: string;
  html: string;
  jfr: string;
  current: boolean;
}

export interface Artifacts {
  basePath: string;
  json: string;
  html: string;
  jfr: string;
  recordingIndex: string;
}
