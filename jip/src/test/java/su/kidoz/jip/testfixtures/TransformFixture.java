package su.kidoz.jip.testfixtures;

public class TransformFixture {
    private final Object monitor = new Object();

    static {
        System.setProperty("jiprof.transform.fixture.initialized", "true");
    }

    public TransformFixture() {
    }

    public TransformFixture(boolean fail) {
        if (fail) {
            throw new IllegalArgumentException("ctor");
        }
    }

    public String echo(String value) {
        return value + "-ok";
    }

    public String synchronizedBlock() {
        synchronized (monitor) {
            return "sync";
        }
    }

    public void waitOnMonitor() throws InterruptedException {
        synchronized (monitor) {
            monitor.wait(1L);
        }
    }

    public void sleepBriefly() throws InterruptedException {
        Thread.sleep(1L);
    }

    public String catchesException() {
        try {
            throw new IllegalStateException("boom");
        } catch (IllegalStateException e) {
            return "caught";
        }
    }

    public void throwsException() {
        throw new IllegalArgumentException("boom");
    }
}
