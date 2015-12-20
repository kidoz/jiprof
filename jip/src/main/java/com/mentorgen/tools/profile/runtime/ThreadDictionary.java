/*
Copyright (c) 2006, MentorGen, LLC
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

import java.util.HashMap;
import java.util.LinkedList;

final class ThreadDictionary extends HashMap<Long, InteractionList> {
	
	void add(long threadId, Frame f) {
		InteractionList list = get(threadId);
		
		if (list == null) {
			list = new InteractionList();
			put(threadId, list);
		}
		
		list.add(f);
	}
	
	Frame getMostRecentFrame(long threadId) {
		return this.get(threadId).getLast();
	}
	
	Iterable<Long> threads() {
		return this.keySet();
	}
	
	Iterable<Frame> interactions(long threadId) {
		return this.get(threadId);
	}
	
	long getThreadTotalTime(long threadId) {
		InteractionList il = this.get(threadId);
		assert il != null;
		long totalTime = 0;
		
		for (Frame f : il) {
			totalTime += f._metrics.getTotalTime();
		}
		
		return totalTime;
	}
}



class InteractionList extends LinkedList<Frame> {
}