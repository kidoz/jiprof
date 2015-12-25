package sample.profiler;

public class Profile {
	
	public static void start(String className, String methodName) {
		System.out.println(new StringBuilder(className)
				.append('\t')
				.append(methodName)
				.append("\tstart\t")
				.append(System.currentTimeMillis()));
	}

	public static void start(String className, String methodName, Object o) {
		System.out.println(new StringBuilder(className)
				.append('\t')
				.append(methodName)
				.append("\tstart\t")
				.append(System.currentTimeMillis()));
		System.out.println("object: " + o);
	}

	public static void end(String className, String methodName) {
		System.out.println(new StringBuilder(className)
				.append('\t')
				.append(methodName)
				.append("\tend\t")
				.append(System.currentTimeMillis()));		
	}

	public static void end(String className, String methodName, Object o) {
		System.out.println(new StringBuilder(className)
				.append('\t')
				.append(methodName)
				.append("\tend\t")
				.append(System.currentTimeMillis()));
		System.out.println("object: " + o);
	}
}
