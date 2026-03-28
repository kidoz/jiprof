package su.kidoz.jip.output;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;

public final class ProfileHtmlDump {
	private static final String JSON_PLACEHOLDER = "__PROFILE_JSON__";

	public static void dump(ProfileOutputFiles files) throws IOException {
		dump(files, ProfileJsonDump.buildSnapshot(files));
	}

	public static void dump(ProfileOutputFiles files, String json) throws IOException {
		String template = loadTemplate();
		String html = template.replace(JSON_PLACEHOLDER, escapeForInlineScript(json));

		FileWriter out = new FileWriter(files.htmlFileName());
		BufferedWriter bufferedWriter = new BufferedWriter(out);
		PrintWriter writer = new PrintWriter(bufferedWriter);
		writer.print(html);
		writer.flush();
		out.close();
	}

	private static String loadTemplate() throws IOException {
		InputStream inputStream = ProfileHtmlDump.class
				.getResourceAsStream("/su/kidoz/jip/output/profile-modern-viewer.html");
		if (inputStream == null) {
			throw new IOException("Missing embedded modern viewer template.");
		}
		return new String(inputStream.readAllBytes(), StandardCharsets.UTF_8);
	}

	private static String escapeForInlineScript(String json) {
		return json.replace("</script>", "<\\/script>");
	}
}
