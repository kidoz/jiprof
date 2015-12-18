package com.mentorgen.tools.profile.runtime;

import junit.framework.TestCase;

public class MetricsTest extends TestCase {
	
	public void testInitial() {
		Metrics m = new Metrics();
		assertTrue(m.getCount() == 0);
		assertTrue(m.getTotalTime() == 0);
	}

	public void testBasic() {
		final int TIME = 100;
		Metrics m = new Metrics();
		m.inc(TIME);
		assertTrue(m.getCount() == 1);
		assertTrue(m.getTotalTime() == TIME);
	}
	
	public void testTwo() {
		final int TIME1 = 100;
		final int TIME2 = 250;
		Metrics m = new Metrics();
		m.inc(TIME1);
		m.inc(TIME2);
		assertTrue(m.getCount() == 2);
		assertTrue(m.getTotalTime() == TIME1 + TIME2);
	}
	
	public void testAdjust() {
		final int TIME = 100;
		final int ADJUST = 2;
		Metrics m = new Metrics();
		m.inc(TIME);
		m.adjust(ADJUST);
		assertTrue(m.getCount() == 1);
		assertTrue(m.getTotalTime() == TIME-ADJUST);
	}
	
	public void testBoundaryTime() {
		final int TIME = -1;
		Metrics m = new Metrics();
		m.inc(TIME);
		assertTrue(m.getCount() == 1);
		assertTrue(m.getTotalTime() == 0);
	}
	
	public void testBoundarAdjust() {
		final int TIME = 100;
		final int ADJUST = -1;
		Metrics m = new Metrics();
		m.inc(TIME);
		m.adjust(ADJUST);
		assertTrue(m.getCount() == 1);
		assertTrue(m.getTotalTime() == TIME);
	}
}
