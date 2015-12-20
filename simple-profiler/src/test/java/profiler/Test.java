package profiler;

import java.io.File;

public class Test {
	private String one = "one";
	private String two = "two";

	public Test() {
		
	}
	
	public void foo(String f, String b) {
		System.out.println("...foo");
		System.out.println(this);
		baz(one, two, this);
	}
	
	public void baz(String f, String b, Object o) {
		
	}
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		
		Test t = new Test();
		t.foo("a", "b");
		
		File dir = new File(".");
		String[] list = dir.list();
		
		for (String file: list) {
			System.out.println(file);
			
			try {
				Thread.sleep(100);
			} catch (InterruptedException e) {
				e.printStackTrace();
				continue;
			}
		}

	}

}
