/*
Copyright (c) 2005 - 2006, MentorGen, LLC
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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import com.mentorgen.tools.profile.Controller;

/**
 * Models a (call) stack frame.
 * 
 * @author Andrew Wilcox
 *
 */
public final class Frame {
	
	// identification
	//
	private Method _method;
	private Frame _parent;
	private long _netTime = 0;
	private long _threadId;
	
	private Map<Method, Frame> _children = new HashMap<Method, Frame>(); 
	private ArrayList<Frame> _childList = new ArrayList<Frame>();
	
	// metrics
	//
	public Metrics _metrics = new Metrics();	
	private long _lastStartTime = 0;
	private long _lastWaitStartTime = 0;
	private long _waitTime = 0;
	
	private Frame() {		
	}
	
	Frame(Frame parent, Method method, long threadId) {
		assert method != null;
		_parent = parent;
		_method = method;
		_threadId = threadId;
		
		if (parent != null) {
			parent.addChild(method, this);
		}
	}
	
	//
	// from object
	//
	
	// for debugging
	public String toString() {
		StringBuffer b = new StringBuffer();
		toStringBuffer(b, 0);
		return b.toString();
	}
	
	//
	// public query methods
	//

	public long getThreadId() {
		return _threadId;
	}
	
	public String getName() {
		return _method.toString();
	}
	
	public String getInvertedName() {
		return _method.toInvertedString();
	}
	
	public String getClassName() {
		return _method.getClassName();
	}
	
	public String getMethodName() {
		return _method.getMethodName();
	}
	
	public Iterable<Frame> childIterator() {
		return _childList;
	}
	
	public boolean hasChildren() {
		return _childList.size() > 0;
	}
	
	public Frame getParent() {
		return _parent;
	}

	public long netTime() {
		return _netTime;
	}
	
	//
	// public "action" methods
	//
	
	void computeNetTime() {
		long childTime = 0;
		
		for (Frame child: _childList) {
			childTime += child._metrics.getTotalTime();
		}
		
		_netTime = _metrics.getTotalTime() - childTime - _waitTime;
		
		if (_netTime < 0) {
			_netTime = 0;
		}
	}
	
	//
	// package methods used by the runtime profiler
	//
	
	void setBeginTime(long time) {
		_lastStartTime = time;
	}
	
	void setEndTime(long endTime) {
		if (_lastStartTime == 0) {
			_metrics.inc(0);
		} else if (0 < (endTime - _lastStartTime)) {
			_metrics.inc(endTime - _lastStartTime);
		} else {
			_metrics.inc(0);
		}
		_lastStartTime = 0;
	}
	
	void beginWait(long time) {
		_lastWaitStartTime = time;
	}
	
	void endWait(long time) {
		if (0 < (time - _lastWaitStartTime)) {
			_waitTime += (time - _lastWaitStartTime);
		}
		_lastWaitStartTime = 0;
	}
	
	Frame getChild(Method m) {
		return _children.get(m);
	}
	
	void overhead(long overhead) {
		_metrics.adjust(overhead);
	}
	
	
	void close() {
		if (_lastStartTime > 0) {
			this.setEndTime(System.nanoTime());
			
			if (Controller._debug) {
				System.err.print("Fixup: ");
				System.err.println(_method);
			}
		}
		
		// make sure that all of the child frames are closed
		//
		for (Frame child: _childList) {
			child.close();
		}
	}

	//
	// private
	//
	
	private void addChild(Method m, Frame f) {
		_children.put(m ,f);
		_childList.add(f);
	}
	
	// very similar to a section of FrameDump
	private void toStringBuffer(StringBuffer b, int depth) {
		if (depth > 5) {
			return;
		}
		
		b.append(" ");
		
		for (int i=0; i<depth; i++) {
			b.append("| ");
		}
		
		b.append("+--");
		b.append(this.getInvertedName());
		b.append(System.getProperty("line.separator"));
		
		if (Controller._threadDepth != Controller.UNLIMITED
				&& depth == Controller._threadDepth-1) {
			return;
		}
		
		for (Frame child: _childList) {
			
			if (Controller._compactThreadDepth
					&& child._metrics.getTotalTime() 
					< Controller._compactThreadThreshold * 1000000) {
				continue;
			}
			
			child.toStringBuffer(b, depth + 1);
		}
	}

}
