package su.kidoz.jip.output;

import com.mentorgen.tools.profile.Controller;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;

public final class ProfileOutputFiles {
	private final String jsonFileName;
	private final String htmlFileName;
	private final String jfrFileName;
	private final String snapshotTimestamp;

	private ProfileOutputFiles(String jsonFileName, String htmlFileName, String jfrFileName, String snapshotTimestamp) {
		this.jsonFileName = jsonFileName;
		this.htmlFileName = htmlFileName;
		this.jfrFileName = jfrFileName;
		this.snapshotTimestamp = snapshotTimestamp;
	}

	public static ProfileOutputFiles create() {
		Date now = new Date();
		String snapshotTimestamp = new SimpleDateFormat("yyyyMMdd-HHmmss").format(now);
		String basePath = resolveBasePath(snapshotTimestamp);

		return new ProfileOutputFiles(basePath + ".json", basePath + ".html", basePath + ".jfr", snapshotTimestamp);
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

	public String snapshotTimestamp() {
		return snapshotTimestamp;
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
}
