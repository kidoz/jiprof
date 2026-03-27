package su.kidoz.jip.output;

import com.mentorgen.tools.profile.Controller;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;

public final class ProfileOutputFiles {
    private final String textFileName;
    private final String xmlFileName;
    private final String jsonFileName;
    private final String htmlFileName;
    private final String snapshotTimestamp;
    private final String legacyDisplayTimestamp;

    private ProfileOutputFiles(
            String textFileName,
            String xmlFileName,
            String jsonFileName,
            String htmlFileName,
            String snapshotTimestamp,
            String legacyDisplayTimestamp
    ) {
        this.textFileName = textFileName;
        this.xmlFileName = xmlFileName;
        this.jsonFileName = jsonFileName;
        this.htmlFileName = htmlFileName;
        this.snapshotTimestamp = snapshotTimestamp;
        this.legacyDisplayTimestamp = legacyDisplayTimestamp;
    }

    public static ProfileOutputFiles create() {
        Date now = new Date();
        String snapshotTimestamp = new SimpleDateFormat("yyyyMMdd-HHmmss").format(now);
        String legacyDisplayTimestamp = new SimpleDateFormat("yyyy.MM.dd HH:mm:ss a").format(now);
        String basePath = resolveBasePath(snapshotTimestamp);

        return new ProfileOutputFiles(
                basePath + ".txt",
                basePath + ".xml",
                basePath + ".json",
                basePath + ".html",
                snapshotTimestamp,
                legacyDisplayTimestamp
        );
    }

    public String textFileName() {
        return textFileName;
    }

    public String xmlFileName() {
        return xmlFileName;
    }

    public String jsonFileName() {
        return jsonFileName;
    }

    public String htmlFileName() {
        return htmlFileName;
    }

    public String snapshotTimestamp() {
        return snapshotTimestamp;
    }

    public String legacyDisplayTimestamp() {
        return legacyDisplayTimestamp;
    }

    private static String resolveBasePath(String snapshotTimestamp) {
        File file = new File(Controller._fileName);

        if (file.isDirectory()) {
            return new File(file, snapshotTimestamp).getAbsolutePath();
        }

        String configured = Controller._fileName.trim();
        if (configured.endsWith(".txt")
                || configured.endsWith(".xml")
                || configured.endsWith(".json")
                || configured.endsWith(".html")) {
            int extensionIndex = configured.lastIndexOf('.');
            return configured.substring(0, extensionIndex);
        }

        return configured;
    }
}
