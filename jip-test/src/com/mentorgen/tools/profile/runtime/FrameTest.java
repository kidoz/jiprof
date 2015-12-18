package com.mentorgen.tools.profile.runtime;

import junit.framework.TestCase;

public class FrameTest extends TestCase {
	
	public void testBasic() {
		final String CLASSNAME = "testpackage/TestClass";
		final String METHODNAME = "testMethod";
		final int THREAD_ID = 1;
		Method m = new Method(CLASSNAME, METHODNAME);
		Frame f = new Frame(null, m, THREAD_ID);
		
		f.setBeginTime(100);
		f.setEndTime(200);
		f.computeNetTime();
		
		assertTrue(f.getClassName().equals(CLASSNAME));
		assertTrue(f.getMethodName().equals(METHODNAME));
		assertTrue(f.getThreadId() == THREAD_ID);
		
		assertTrue(f.getParent() == null);
		assertTrue(f.hasChildren() ==false);
		
		int count = 0;
		for (Frame child: f.childIterator()) count ++;
		assertTrue(count == 0);
		
		assertTrue(f.netTime() == 100);		
	}
	
	public void testTwo() {
		final String CLASSNAME = "testpackage/TestClass";
		final String METHODNAME = "testMethod";
		final int THREAD_ID = 1;
		Method m = new Method(CLASSNAME, METHODNAME);
		Frame f = new Frame(null, m, THREAD_ID);
		
		f.setBeginTime(100);
		f.setEndTime(200);
		f.setBeginTime(500);
		f.setEndTime(600);
		f.computeNetTime();
		
		assertTrue(f.netTime() == 200);
	}
	
	public void testNoEnd() {
		final String CLASSNAME = "testpackage/TestClass";
		final String METHODNAME = "testMethod";
		final int THREAD_ID = 1;
		Method m = new Method(CLASSNAME, METHODNAME);
		Frame f = new Frame(null, m, THREAD_ID);
		
		long bOutside = System.nanoTime();
		f.setBeginTime(System.nanoTime());
		long bInside = System.nanoTime();
		try {Thread.sleep(1);} catch (InterruptedException ie) {}
		long eInside = System.nanoTime();
		f.close();
		long eOutside = System.nanoTime();
		f.computeNetTime();

		// this is an approximation
		//
		assertTrue(f.netTime() >= (eInside - bInside));
		assertTrue(f.netTime() <= (eOutside - bOutside));
	}
	
	public void testOneChild() {
		final String CLASSNAME1 = "testpackage/TestClass";
		final String CLASSNAME2 = "testpackage/TwoClass";
		final String METHODNAME1 = "testMethod";
		final String METHODNAME2 = "twoMethod";
		final int THREAD_ID = 1;
		Method m = new Method(CLASSNAME1, METHODNAME1);
		Frame f = new Frame(null, m, THREAD_ID);
		
		Method m2 = new Method(CLASSNAME2, METHODNAME2);
		Frame child = new Frame(f, m2, THREAD_ID);
		
		f.setBeginTime(100);
		child.setBeginTime(200);
		child.setEndTime(500);
		f.setEndTime(1100);
		
		f.computeNetTime();
		child.computeNetTime();
		
		assertTrue(f.hasChildren());

		int count = 0;
		for (Frame foo: f.childIterator()) count ++;
		assertTrue(count == 1);
		
		assertTrue(f.netTime() == 700);
		assertTrue(child.netTime() == 300);
	}
	
	public void testTwoChildren() {
		final String CLASSNAME1 = "testpackage/TestClass";
		final String CLASSNAME2 = "testpackage/TwoClass";
		final String CLASSNAME3 = "testpackage/ChildClass";
		final String METHODNAME1 = "testMethod";
		final String METHODNAME2 = "twoMethod";
		final String METHODNAME3 = "childMethod";
		final int THREAD_ID = 1;
		Method m = new Method(CLASSNAME1, METHODNAME1);
		Frame f = new Frame(null, m, THREAD_ID);
		
		Method m2 = new Method(CLASSNAME2, METHODNAME2);
		Frame child = new Frame(f, m2, THREAD_ID);
		
		Method m3 = new Method(CLASSNAME3, METHODNAME3);
		Frame child2 = new Frame(f, m3, THREAD_ID);
		
		f.setBeginTime(100);
		child.setBeginTime(200);
		child.setEndTime(500);
		child2.setBeginTime(500);
		child2.setEndTime(750);
		f.setEndTime(1100);
		
		f.computeNetTime();
		child.computeNetTime();
		child2.computeNetTime();
		
		assertTrue(f.hasChildren());

		int count = 0;
		for (Frame foo: f.childIterator()) count ++;
		assertTrue(count == 2);
		
		assertTrue(f.netTime() == 450);
		assertTrue(child.netTime() == 300);
		assertTrue(child2.netTime() == 250);
	}
	
	public void test3Levels() {
		final String CLASSNAME1 = "testpackage/TestClass";
		final String CLASSNAME2 = "testpackage/TwoClass";
		final String CLASSNAME3 = "testpackage/ChildClass";
		final String METHODNAME1 = "testMethod";
		final String METHODNAME2 = "twoMethod";
		final String METHODNAME3 = "childMethod";
		final int THREAD_ID = 1;
		Method m = new Method(CLASSNAME1, METHODNAME1);
		Frame f = new Frame(null, m, THREAD_ID);
		
		Method m2 = new Method(CLASSNAME2, METHODNAME2);
		Frame child = new Frame(f, m2, THREAD_ID);
		
		Method m3 = new Method(CLASSNAME3, METHODNAME3);
		Frame child2 = new Frame(child, m3, THREAD_ID);
		
		f.setBeginTime(100);
		child.setBeginTime(200);
		child2.setBeginTime(500);
		child2.setEndTime(750);
		child.setEndTime(750);
		f.setEndTime(1100);
		
		f.computeNetTime();
		child.computeNetTime();
		child2.computeNetTime();
		
		assertTrue(f.hasChildren());

		int count = 0;
		for (Frame foo: f.childIterator()) count ++;
		assertTrue(count == 1);
		
		assertTrue(f.hasChildren());

		count = 0;
		for (Frame foo: child.childIterator()) count ++;
		assertTrue(count == 1);

		assertTrue(f.netTime() == 450);
		assertTrue(child.netTime() == 300);
		assertTrue(child2.netTime() == 250);
	}
	
}
