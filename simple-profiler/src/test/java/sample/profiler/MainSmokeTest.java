package sample.profiler;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertSame;

public class MainSmokeTest {

	@Test
	public void transformerSkipsNonSystemClassLoader() throws Exception {
		Transformer transformer = new Transformer();
		byte[] bytes = new byte[]{1, 2, 3};

		assertSame(bytes, transformer.transform(null, "example/Foo", null, null, bytes));
	}
}
