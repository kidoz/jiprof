package demo;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ThreadLocalRandom;

public class DemoApp {

    public static void main(String[] args) throws Exception {
        System.out.println("=== JIP Profiler Demo ===");

        DemoApp app = new DemoApp();
        app.runWorkload();

        System.out.println("=== Done ===");
    }

    void runWorkload() throws Exception {
        List<String> results = new ArrayList<>();
        for (int i = 0; i < 20; i++) {
            results.add(processRequest(i));
        }

        Thread worker = new Thread(() -> {
            for (int i = 0; i < 10; i++) {
                backgroundTask(i);
            }
        }, "background-worker");
        worker.start();
        worker.join();

        summarize(results);
    }

    String processRequest(int id) {
        String data = fetchData(id);
        return transformData(data);
    }

    String fetchData(int id) {
        // simulate I/O
        busyWait(10);
        return "record-" + id;
    }

    String transformData(String data) {
        // simulate CPU work
        busyWait(5);
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 1000; i++) {
            sb.append(data.hashCode() ^ i);
        }
        return sb.toString().substring(0, 20);
    }

    void backgroundTask(int iteration) {
        byte[][] churn = new byte[128][];
        for (int i = 0; i < churn.length; i++) {
            churn[i] = new byte[ThreadLocalRandom.current().nextInt(64, 512)];
        }
        busyWait(8);
    }

    void summarize(List<String> results) {
        busyWait(3);
        System.out.println("Processed " + results.size() + " requests");
    }

    private void busyWait(int millis) {
        long end = System.nanoTime() + millis * 1_000_000L;
        long v = 0;
        while (System.nanoTime() < end) {
            v += System.nanoTime() & 0xFF;
        }
        if (v == Long.MIN_VALUE) throw new AssertionError();
    }
}
