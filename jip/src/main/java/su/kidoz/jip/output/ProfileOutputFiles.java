package su.kidoz.jip.output;

import com.mentorgen.tools.profile.Controller;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;

public final class ProfileOutputFiles {
	private final String basePath;
	private final String jsonFileName;
	private final String htmlFileName;
	private final String jfrFileName;
	private final String recordingDirectory;
	private final String recordingIndexFileName;
	private final boolean historyEnabled;
	private final String snapshotTimestamp;
	private final String snapshotLabel;

	private ProfileOutputFiles(String basePath, String jsonFileName, String htmlFileName, String jfrFileName,
			String recordingDirectory, String recordingIndexFileName, boolean historyEnabled, String snapshotTimestamp,
			String snapshotLabel) {
		this.basePath = basePath;
		this.jsonFileName = jsonFileName;
		this.htmlFileName = htmlFileName;
		this.jfrFileName = jfrFileName;
		this.recordingDirectory = recordingDirectory;
		this.recordingIndexFileName = recordingIndexFileName;
		this.historyEnabled = historyEnabled;
		this.snapshotTimestamp = snapshotTimestamp;
		this.snapshotLabel = snapshotLabel;
	}

	public static ProfileOutputFiles create() {
		Date now = new Date();
		String snapshotTimestamp = new SimpleDateFormat("yyyyMMdd-HHmmss").format(now);
		File configuredFile = new File(Controller._fileName);
		boolean historyEnabled = configuredFile.isDirectory();
		String recordingDirectory = historyEnabled ? configuredFile.getAbsolutePath() : "";
		String recordingIndexFileName = historyEnabled
				? new File(configuredFile, "recordings-index.json").getAbsolutePath()
				: "";
		String basePath = ensureUniqueBasePath(resolveBasePath(snapshotTimestamp));
		String snapshotLabel = resolveSnapshotLabel(basePath);

		return new ProfileOutputFiles(basePath, basePath + ".json", basePath + ".html", basePath + ".jfr",
				recordingDirectory, recordingIndexFileName, historyEnabled, snapshotTimestamp, snapshotLabel);
	}

	public String basePath() {
		return basePath;
	}

	public String jsonFileName() {
		return jsonFileName;
	}

	public String htmlFileName() {
		return htmlFileName;
	}

	public String jfrFileName() {
		return jfrFileName;
	}

	public String recordingDirectory() {
		return recordingDirectory;
	}

	public String recordingIndexFileName() {
		return recordingIndexFileName;
	}

	public boolean historyEnabled() {
		return historyEnabled;
	}

	public String snapshotTimestamp() {
		return snapshotTimestamp;
	}

	public String snapshotLabel() {
		return snapshotLabel;
	}

	private static String resolveBasePath(String snapshotTimestamp) {
		File file = new File(Controller._fileName);

		if (file.isDirectory()) {
			return new File(file, snapshotTimestamp).getAbsolutePath();
		}

		String configured = Controller._fileName.trim();
		if (configured.endsWith(".txt") || configured.endsWith(".xml") || configured.endsWith(".json")
				|| configured.endsWith(".html") || configured.endsWith(".jfr")) {
			int extensionIndex = configured.lastIndexOf('.');
			return configured.substring(0, extensionIndex);
		}

		return configured;
	}

	private static String ensureUniqueBasePath(String basePath) {
		File jsonFile = new File(basePath + ".json");
		File htmlFile = new File(basePath + ".html");
		File jfrFile = new File(basePath + ".jfr");
		if (!jsonFile.exists() && !htmlFile.exists() && !jfrFile.exists()) {
			return basePath;
		}

		for (int suffix = 1;; suffix++) {
			String candidate = basePath + "-" + suffix;
			if (!new File(candidate + ".json").exists() && !new File(candidate + ".html").exists()
					&& !new File(candidate + ".jfr").exists()) {
				return candidate;
			}
		}
	}

	private static String resolveSnapshotLabel(String basePath) {
		String label = new File(basePath).getName();
		if (label == null || label.trim().isEmpty()) {
			return "profile";
		}
		return label.trim();
	}
}
