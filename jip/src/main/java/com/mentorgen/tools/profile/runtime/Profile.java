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
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.atomic.AtomicLong;

import com.mentorgen.tools.profile.Controller;
import com.mentorgen.tools.profile.output.ProfileDump;
import su.kidoz.jip.jfr.JfrProfileSupport;
import su.kidoz.jip.timeline.TimelineRecorder;

/**
 * The <code>Profiler</code> is the class that actually profiles the code. Code
 * to be profiled is instrumented, when the byte code is loaded, to make calls
 * to this class:
 * <ul>
 * <li>At the beginning of each method (calls
 * <code>Profiler.start()</cdoe>)</li>
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
 * -javaagent)</code> </blockquote>
 *
 *
 * @author Andrew Wilcox
 *
 */
public final class Profile implements Runnable {
	private static boolean _debugStart = false;
	private static boolean _debugException = false;

	private static ThreadDictionary _threadDictionary;
	private static ConcurrentLinkedQueue<Frame> _frameList;
	private static Map<Long, Frame> _threadActiveFrame;
	private static Map<String, Method> _methodDictionary;

	private static Map<String, ClassAllocation> _allocList;
	private static volatile List<Frame> _sortedFrameList;
	private static AtomicLong _generation = new AtomicLong();
	private static final ThreadLocal<ThreadState> _threadState = new ThreadLocal<ThreadState>();

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
		_generation.incrementAndGet();
		_threadActiveFrame = new ConcurrentHashMap<Long, Frame>(1001);
		_threadDictionary = new ThreadDictionary();
		_methodDictionary = new ConcurrentHashMap<String, Method>(2003);
		_frameList = new ConcurrentLinkedQueue<Frame>();
		_sortedFrameList = null;

		_allocList = new ConcurrentHashMap<String, ClassAllocation>();
		TimelineRecorder.init();
	}

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
		Controller._profile = false;

		for (Frame frame : new ArrayList<Frame>(_threadActiveFrame.values())) {
			if (frame != null) {
				frame.close();
			}
		}

		for (Frame frame : snapshotFrameList()) {
			frame.computeNetTime();
		}

		JfrProfileSupport.stopProfileSession();
	}

	public static Iterable<Long> threads() {
		return _threadDictionary.threads();
	}

	public static Iterable<Frame> interactions(long threadId) {
		return _threadDictionary.interactions((threadId));
	}

	public static Iterable<Frame> frameList() {
		List<Frame> sorted = _sortedFrameList;
		return sorted == null ? snapshotFrameList() : sorted;
	}

	public static Iterable<ClassAllocation> allocations() {
		return new ArrayList<ClassAllocation>(_allocList.values());
	}

	public static long getThreadTotalTime(long threadId) {
		return _threadDictionary.getThreadTotalTime(threadId);
	}

	public static void sortFrameList(Comparator<Frame> comp) {
		List<Frame> sorted = snapshotFrameList();
		Collections.sort(sorted, comp);
		_sortedFrameList = sorted;
	}

	public static void start(String className, String methodName) {
		long start = System.nanoTime();

		if (!Controller._profile) {
			return;
		}

		ThreadState state = threadState();
		Method method = method(className, methodName);
		Frame parent = state.currentFrame;
		Frame target;

		if (parent != null) {
			target = parent.getChild(method);

			if (target == null) {
				target = createFrame(parent, method, state.threadId);
			}
		} else {
			target = createFrame(null, method, state.threadId);
			_threadDictionary.add(state.threadId, target);
		}

		if (_debugStart) {
			System.out.print("  (");
			System.out.print(className);
			System.out.print(" : ");
			System.out.print(methodName);
			System.out.println(')');

			Frame root = _threadDictionary.getMostRecentFrame(state.threadId);
			System.out.println(root);
		}

		updateActiveFrame(state, target);
		target.overhead(System.nanoTime() - start);
		target.setBeginTime(start);
	}

	public static void end(String className, String method) {
		long start = System.nanoTime();

		ThreadState state = threadState();
		Frame target = findFrame(state, className, method);

		if (target == null) {
			return;
		}

		long endTime = System.nanoTime();
		updateActiveFrame(state, target.getParent());
		target.overhead(System.nanoTime() - start);
		long duration = target.setEndTime(endTime);
		TimelineRecorder.record(state.threadId, endTime, duration);
	}

	public static void beginWait(String className, String methodName) {
		long start = System.nanoTime();

		Frame target = findFrame(threadState(), className, methodName);

		if (target == null) {
			return;
		}

		target.overhead(System.nanoTime() - start);
		target.beginWait(System.nanoTime());
	}

	public static void endWait(String className, String methodName) {
		long start = System.nanoTime();

		Frame target = findFrame(threadState(), className, methodName);

		if (target == null) {
			return;
		}

		target.overhead(System.nanoTime() - start);
		target.endWait(System.nanoTime());
	}

	public static void unwind(String className, String methodName, String exception) {
		if (_debugException || Controller._debug) {
			System.out.println("Catch: " + exception);
		}

		ThreadState state = threadState();
		Frame target = findFrame(state, className, methodName);

		if (target == null) {
			return;
		}

		updateActiveFrame(state, target);
	}

	private static Frame findFrame(ThreadState state, String className, String methodName) {
		if (!Controller._profile) {
			return null;
		}

		Frame target = state.currentFrame;

		if (target == null) {
			return null;
		}

		boolean detectedException = false;

		while (true) {
			if (target.getClassName().equals(className) && target.getMethodName().equals(methodName)) {
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

			long endTime = System.nanoTime();
			long duration = target.setEndTime(endTime);
			TimelineRecorder.record(state.threadId, endTime, duration);
			target = target.getParent();

			if (target == null) {
				updateActiveFrame(state, null);

				if (_debugException) {
					System.err.println("Stack completely unwound.");
				}

				return null;
			}
		}

		return target;
	}

	public static void alloc(String className) {
		if (!Controller._profile) {
			return;
		}

		ThreadState state = threadState();
		Frame target = state.currentFrame;

		if (target != null && target.getClassName().equals(className) && target.getMethodName().equals("<init>")) {
			return;
		}

		_allocList.computeIfAbsent(className, ClassAllocation::new).incAllocCount();
	}

	public void run() {
		try {
			if (_threadDictionary.size() > 0) {
				shutdown();
				ProfileDump.dump();
			}

			_controller.close();

			if (_controllerThread != null) {
				_controllerThread.interrupt();
			}

		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	private static Method method(String className, String methodName) {
		String key = className + '#' + methodName;
		return _methodDictionary.computeIfAbsent(key, ignored -> new Method(className, methodName));
	}

	private static Frame createFrame(Frame parent, Method method, long threadId) {
		Frame frame = new Frame(parent, method, threadId);
		_frameList.add(frame);
		_sortedFrameList = null;
		return frame;
	}

	private static void updateActiveFrame(ThreadState state, Frame frame) {
		state.currentFrame = frame;

		if (frame == null) {
			_threadActiveFrame.remove(state.threadId);
		} else {
			_threadActiveFrame.put(state.threadId, frame);
		}
	}

	private static List<Frame> snapshotFrameList() {
		return new ArrayList<Frame>(_frameList);
	}

	private static ThreadState threadState() {
		long generation = _generation.get();
		ThreadState state = _threadState.get();
		long threadId = Thread.currentThread().getId();

		if (state == null || state.generation != generation || state.threadId != threadId) {
			state = new ThreadState(generation, threadId);
			_threadState.set(state);
		}

		return state;
	}

	private static final class ThreadState {
		private final long generation;
		private final long threadId;
		private Frame currentFrame;

		private ThreadState(long generation, long threadId) {
			this.generation = generation;
			this.threadId = threadId;
		}
	}
}
