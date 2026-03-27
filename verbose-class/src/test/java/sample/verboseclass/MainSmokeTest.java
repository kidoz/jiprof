package sample.verboseclass;

import org.junit.Test;

import static org.junit.Assert.assertSame;

public class MainSmokeTest {

    @Test
    public void transformerReturnsOriginalBytes() throws Exception {
        Transformer transformer = new Transformer();
        byte[] bytes = new byte[] {1, 2, 3};

        assertSame(bytes, transformer.transform(null, "example/Foo", null, null, bytes));
    }
}
