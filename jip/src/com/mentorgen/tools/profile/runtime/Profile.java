/*
Copyright (c) 2005-2006, MentorGen, LLC
All rights reserved.

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are met:

+ Redistributions of source code must retain the above copyright notice, 
  this list of conditions and the following disclaimer.
+ Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
+ Neither the name of MentorGen LLC nor the names of its contributors may be 
  used to endorse or promote products derived from this software without 
  specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
  POSSIBILITY OF SUCH DAMAGE.
 */
package com.mentorgen.tools.profile.runtime;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.mentorgen.tools.profile.Controller;
import com.mentorgen.tools.profile.output.ProfileDump;

/**
 * The <code>Profiler</code> is the class that actually profiles the code.
 * Code to be profiled is instrumented, when the byte code is loaded,
 * to make calls to this class:
 * <ul>
 * 	<li>At the beginning of each method (calls <code>Profiler.start()</cdoe>)</li>
 * 	<li>At the end of each method (that is, when return is called, which
 * 		might not actaully be at the end of the method) 
 * 		(calls <code>Profiler.end()</cdoe>)</li>
 * 	<li>When an exception is thrown (also calls <code>Profiler.end()</cdoe>)</li>
 * 	<li>Each time a constructor is called (optional)</li>
 * </ul>
 * 
 * <blockquote>
 * Note: Instrumenting code can interfer with line numbers that are added to
 * the code for debugging. If you are debugging code and your stack traces
 * don't have line numbers, don't use the profiler (ie, don't use <code>
 * -javaagent)</code>
 * </blockquote>
 * 
 * 
 * @author Andrew Wilcox
 *
 */
public final class Profile implements Runnable {
	private static boolean _debugStart = false;
	private static boolean _debugException = false;
	
	private static ThreadDictionary _threadDictionary;
	private static List<Frame> _frameList;
	private static Map<Long, Frame> _threadActiveFrame;
	private static Map<String, Method> _methodDictionary;
	private static Object _lock;
	
	private static Map<String, ClassAllocation> _allocList;
	
	private static Controller _controller;
	private static Thread _controllerThread;
	
	public static void initProfiler() {
		System.err.println("Java Interactive Profiler: starting");
		
		init();
		Runtime.getRuntime().addShutdownHook(new Thread(new Profile()));
		_controller = new Controller();
		
		if (Controller._remote) {
			_controllerThread = new Thread(_controller);
			_controllerThread.start();
		}
	}
	
	
	public static void init() {
		_threadActiveFrame = new HashMap<Long, Frame>(1001);
		_threadDictionary = new ThreadDictionary();
		_methodDictionary = new HashMap<String, Method>(2003);
		_frameList = new ArrayList<Frame>(1001);
		_lock = new Object();
		
		_allocList = new HashMap<String, ClassAllocation>();
	}	
	
//
// Methods to programatically manipulate the Profiler
//
	
	public static void clear() {
		init();
	}
	
	public static void start() {
		_controller.start();
	}
	
	public static void stop() {
		_controller.stop();
	}
	
	public static void setFileName(String fileName) {
		_controller.setFileName(fileName);
	}
	
	public static void shutdown() {
		synchronized (_lock) {
			Controller._profile = false;
			
			for (Long threadId: _threadDictionary.keySet()) {
				Frame f = _threadDictionary.getMostRecentFrame(threadId);
				f.close();
			}
		
			for (Frame frame: frameList()) {
				frame.computeNetTime();
			}
		} // synchronized
	}	
	
//
// Methods called when generating output
// 
	
	public static Iterable<Long> threads() {
		return _threadDictionary.threads();
	}
	
	public static Iterable<Frame> interactions(long threadId) {
		return _threadDictionary.interactions((threadId));
	}
	
	public static Iterable<Frame> frameList() {
		return _frameList;
	}
	
	public static Iterable<ClassAllocation> allocations() {
		return _allocList.values();
	}
	
	public static long getThreadTotalTime(long threadId) {
		return _threadDictionary.getThreadTotalTime(threadId);
	}
	
	public static void sortFrameList(Comparator<Frame> comp) {
		synchronized (_lock) {
			Collections.sort(_frameList, comp);
		}
	}
		
//
// Methods that are called by instrumented code
//

	public static void start(String className, String methodName) {
		long start = System.nanoTime();
		
		long threadId = Thread.currentThread().getId();
		
		synchronized (_lock) {
			
			if (!Controller._profile) {
				return;
			}
	
			// try to get the method from the method pool
			//
			Method method = new Method(className, methodName);
				
			if (_methodDictionary.get(method.toString()) == null) {
				_methodDictionary.put(method.toString(), method);
			}
			
			Frame parent = (Frame) _threadActiveFrame.get(threadId);
			Frame target = null;
			
			if (parent != null) {
				target = (Frame) parent.getChild(method);
				
				if (target == null) {
					target = new Frame(parent, method, threadId);
					_frameList.add(target);
				}
			} else {
				target = new Frame(null, method, threadId);
				_frameList.add(target);
				_threadDictionary.add(threadId, target);
			}
	
			if (_debugStart) {
				System.out.print("  (");
				System.out.print(className);
				System.out.print(" : ");
				System.out.print(methodName);
				System.out.println(')');
				
				Frame root = _threadDictionary.getMostRecentFrame(threadId);
				System.out.println(root);
			}
			
			// "push"
			_threadActiveFrame.put(threadId, target);
			
			target.overhead(System.nanoTime() - start);
			target.setBeginTime(start);
		} // synchronized 
	}
	
	public static void end(String className, String method) {
		long start = System.nanoTime();
		
		synchronized (_lock) {
			long threadId = Thread.currentThread().getId();
			Frame target = findFrame(threadId, className, method);
			
			if (target == null) {
				return;
			}
		
			if (target.getParent() != null) {
				// "pop"
				_threadActiveFrame.put(threadId, target.getParent());	
			} else {
				_threadActiveFrame.put(threadId, null);
			}
		
			target.overhead(System.nanoTime() - start);
			target.setEndTime(System.nanoTime());
		} // synchronized
	}
	
	public static void beginWait(String className, String methodName) {
		long start = System.nanoTime();
		
		synchronized (_lock) {
			Frame target = findFrame(Thread.currentThread().getId(), className, methodName);
			
			if (target == null) {
				return;
			}
		
			target.overhead(System.nanoTime() - start);
			target.beginWait(System.nanoTime());
		}
	}
	
	public static void endWait(String className, String methodName) {
		long start = System.nanoTime();
		
		synchronized (_lock) {
			Frame target = findFrame(Thread.currentThread().getId(), className, methodName);
			
			if (target == null) {
				return;
			}
		
			target.overhead(System.nanoTime() - start);
			target.endWait(System.nanoTime());
		}
	}
	
	public static void unwind(String className, String methodName, String exception) {
		if (_debugException || Controller._debug) {
			System.out.println("Catch: " + exception);
		}
		
		synchronized (_lock) {
			long threadId = Thread.currentThread().getId();
			Frame target = findFrame(threadId, className, methodName);
			
			if (target == null) {
				return;
			}
			
			_threadActiveFrame.put(threadId, target);
		} // synchronized
	}
	
	// MUST be called from a block that has synchronized on _lock!
	//
	private static final Frame findFrame(long threadId, String className, String methodName) {
		if (!Controller._profile) {
			return null;
		}
		
		Frame target = (Frame) _threadActiveFrame.get(threadId);
		
		if (target == null) {
			return null;
		}
		
		// The flow of control is interrupted when an exception is
		// thrown. This code will detect this an unwind the stack
		// until it figures out where we are.
		// Note that this method has its problems. Because it tries to figure
		// out were it is based on the class name method name, it's possible
		// that it could unwind the call stack to the wrong place. Worse yet,
		// if the flow of control is transfered to the same method, but at a
		// different point in the call stack,the exception will not be detected
		// at all.
		//
		boolean detectedException = false;
		
		while (true) {
			
			if (target.getClassName().equals(className) 
					&& target.getMethodName().equals(methodName)) {
				break;
			}
			
			if (!detectedException) {
				detectedException = true;
				
				if (_debugException || Controller._debug) {
					System.err.print("Detected an exception at ");
					System.err.print(className);
					System.err.print('.');
					System.err.println(methodName);
				}
			} else if (_debugException) {
				System.err.print("Unwinding ");
				System.err.print(target.getClassName());
				System.err.print('.');
				System.err.println(target.getMethodName());
			}
			
			target.setEndTime(System.nanoTime());
			target = target.getParent();
			
			// the stack has been unwound to pass the point where
			// we started to profile.
			//
			if (target == null) {
				
				if (_debugException) {
					System.err.println("Stack completely unwound.");
				}
				
				return null;
			}
		}
		
		return target;
	}

	// Uses synchronization for thread safety. I thought this 
	// would slow things down a whole bunch, but on Java 5
	// I haven't seen any major performance problems.
	//
	public static void alloc(String className) {
		
		synchronized (_lock) {
			
			if (!Controller._profile) {
				return;
			}
			
			// this code guards against a constructor calling another constructor 
			// in the same class
			long threadId = Thread.currentThread().getId();
			Frame target = (Frame) _threadActiveFrame.get(threadId);
			
			if (target != null && target.getClassName().equals(className)
					&& target.getMethodName().equals("<init>")) {
				return;
			}
			
			ClassAllocation ca = _allocList.get(className);
			
			if (ca == null) {
				ca = new ClassAllocation(className);
				_allocList.put(className, ca);
			}
			
			ca.incAllocCount();
		} // synchronized
	}
		
	/**
	 * ShutdownHook: This will dump the profiling info when the VM shutsdown.
	 */
	public void run() {
		try {
			if (_threadDictionary.size() > 0) {
				shutdown();
				ProfileDump.dump();
			}
			
			// fix up the Controller
			//
			_controller.close(); //closes the socket
			
			if (_controllerThread != null) {
				_controllerThread.interrupt();
			}
			
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

}

