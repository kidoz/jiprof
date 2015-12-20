/*
Copyright (c) 2007, Andrew Wilcox
All rights reserved.

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are met:

+ Redistributions of source code must retain the above copyright notice, 
  this list of conditions and the following disclaimer.
+ Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
+ Neither the name Andrew Wilcox nor the names of its contributors may be 
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
package net.sourceforge.jiprof.timeline;

import java.io.IOException;

import com.mentorgen.tools.profile.Controller;


public class TimeLineProfiler implements Runnable {
	public static TimeLine _timeLine;
	static long _startTime;
	
	public static void initProfiler() {
		System.err.println("TimeLineProfiler: starting");
		Runtime.getRuntime().addShutdownHook(new Thread(new TimeLineProfiler()));
		_timeLine = new TimeLine();
		
		if (Controller._timeResoltion == Controller.TimeResolution.ns) {
			_startTime = System.nanoTime();
		} else {
			_startTime = System.currentTimeMillis();
		}		
	}
	
	public static void start(String className, String methodName) {
		createActionRecord(className, methodName, Action.START);
	}
	
	public static void end(String className, String methodName) {
		createActionRecord(className, methodName, Action.STOP);
	}
	
	private static void createActionRecord(String className, String methodName, Action type) {
		long threadId = Thread.currentThread().getId();
		ActionRecord rec = new ActionRecord(className, methodName, type, threadId);
		long time;
		
		if (Controller._timeResoltion == Controller.TimeResolution.ns) {
			time = System.nanoTime();
		} else {
			time = System.currentTimeMillis();
		}
		
		synchronized (_timeLine) {
			TimeRecord tr = null;
			
			if (_timeLine.size() > 0) {
				tr = _timeLine.getLast();
			}
			
			if (tr == null || tr._pointInTime != time) {
				tr = new TimeRecord(time);
				_timeLine.add(tr);
			}
			
			tr._actionRecordList.add(rec);
		}		
	}
	
	public static void alloc(String className) {
		createActionRecord(className, "", Action.ALLOC);
	}
	
	public static void beginWait(String className, String methodName) {
		createActionRecord(className, methodName, Action.BEGIN_WAIT);
	}
	
	public static void endWait(String className, String methodName) {
		createActionRecord(className, methodName, Action.END_WAIT);
	}
	
	public static void unwind(String className, String methodName, String exception) {
		createActionRecord(className, methodName, Action.EXCEPTION);
	}
	
	/**
	 * ShutdownHook: This will dump the profiling info when the VM shutsdown.
	 */
	public void run() {
		
		try {
			TextOutput.dump();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}	
	
}
