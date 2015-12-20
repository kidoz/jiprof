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
package com.mentorgen.tools.profile.output;

import java.io.PrintWriter;

import com.mentorgen.tools.profile.Controller;
import com.mentorgen.tools.profile.runtime.Frame;


/**
 * 
 * @author Andrew Wilcox
 * @see com.mentorgen.tools.profile.output.ProfileTextDump
 */
final class FrameDump {
	private static final String NEW_LINE=System.getProperty("line.separator");
	
	static void dump(PrintWriter writer, Frame frame, int interaction) {
		
		if (Controller._compactThreadDepth) {
			// If the root frame doesn't have any children,
			// we're guessing that the user probably doesn't want to see it.
			// Specifically, for web-apps, there are "worker" threads that 
			// aren't of any interest so this is a good way to filter out
			// that kind of chaff.
			//
			if (!frame.hasChildren()) {
				return;
			}
			
			boolean childAboveThreshold = false;
			
			for (Frame child: frame.childIterator()) {
				
				if (!belowThreshold(child) || child.hasChildren()) {
					childAboveThreshold = true;
					break;
				}
			}
			
			if (!childAboveThreshold) {
				return;
			}
		}
		
		writer.print("+------------------------------");
		writer.print(NEW_LINE);
		writer.print("| Thread: ");
		writer.print(frame.getThreadId());
		
		if (interaction > 1) {
			writer.print(" (interaction #");
			writer.print(interaction);
			writer.print(")");
		}
		
		writer.print(NEW_LINE);
		writer.print("+------------------------------");
		writer.print(NEW_LINE);		
		writer.print("              Time            Percent    ");
		writer.print(NEW_LINE);
		writer.print("       ----------------- ---------------");
		writer.print(NEW_LINE);
		writer.print(" Count    Total      Net   Total     Net  Location");
		writer.print(NEW_LINE);
		writer.print(" =====    =====      ===   =====     ===  =========");
		writer.print(NEW_LINE);
		
		long threadTotalTime = frame._metrics.getTotalTime();
		dump(writer, 0, frame, (double) threadTotalTime);
	}
	
	private static void dump(PrintWriter writer, 
			int depth, 
			Frame parent, 
			double threadTotalTime) {
		
		long total = parent._metrics.getTotalTime();
		long net = parent.netTime();
		writer.printf("%6d ", parent._metrics.getCount());
		writer.printf("%8.1f ", Math.nanoToMilli(total));
		writer.printf("%8.1f ", Math.nanoToMilli(net));
		
		if (total > 0 ) {
			double percent = Math.toPercent(total, threadTotalTime);
			writer.printf("%7.1f ", percent);
		} else {
			writer.print("        ");
		}
		
		if (net > 0 && threadTotalTime > 0.000) {
			double percent = Math.toPercent(net, threadTotalTime);
			
			if (percent > 0.1) {
				writer.printf("%7.1f ", percent);
			} else {
				writer.print("        ");
			}
		} else {
			writer.print("        ");
		}
				
		writer.print(" ");
		for (int i=0; i<depth; i++) {
			writer.print("| ");
		}
		
		writer.print("+--");
		writer.print(parent.getInvertedName());
		writer.print(NEW_LINE);
		
		if (Controller._threadDepth != Controller.UNLIMITED
				&& depth == Controller._threadDepth-1) {
			return;
		}
		
		for (Frame child: parent.childIterator()) {
			
			if (belowThreshold(child)) {
				continue;
			}
			
			dump(writer, depth+1, child, threadTotalTime);
		}
	}
	
	
	private static boolean belowThreshold(Frame f) {
		return (Controller._compactThreadDepth
				&& f._metrics.getTotalTime() 
				< Controller._compactThreadThreshold * 1000000);
	}
	
}
