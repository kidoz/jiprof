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

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedList;

import com.mentorgen.tools.profile.Controller;
import com.mentorgen.tools.profile.runtime.ClassAllocation;
import com.mentorgen.tools.profile.runtime.Frame;
import com.mentorgen.tools.profile.runtime.Profile;

/**
 * This class outputs the profile in a human-readable text format.
 * 
 * @author Andrew Wilcox
 * @see com.mentorgen.tools.profile.output.ProfileXMLDump 
 */
final class ProfileTextDump {
	static HashMap<String, Holder> _clumpedFrameMap;
	
	static void dump() throws IOException {
		
		// init
		//
		_clumpedFrameMap = new HashMap<String, Holder>();
		
		//
		// output
		//
		String fileName = null;
		File f = new File(Controller._fileName);
		Date now = new Date();
		
		if (f.isDirectory()) {
			StringBuffer b = new StringBuffer(f.getAbsolutePath());
			b.append(File.separator);
			b.append(new SimpleDateFormat("yyyyMMdd-HHmmss").format(now));
			b.append(".txt");
			fileName = b.toString();
		} else {
			if (Controller._fileName.endsWith(".txt")) {
				fileName = Controller._fileName;
			} else {
				StringBuffer b = new StringBuffer(Controller._fileName);
				b.append(".txt");
				fileName = b.toString();
			}
		}
		
		FileWriter out = new FileWriter(fileName);
		BufferedWriter bufferedWriter = new BufferedWriter(out);
		PrintWriter writer = new PrintWriter(bufferedWriter);
		
		writer.println("+----------------------------------------------------------------------");		
		writer.print("|  File: ");
		writer.println(fileName);
		writer.print("|  Date: ");
		writer.println(new SimpleDateFormat("yyyy.MM.dd HH:mm:ss a").format(now));
		writer.println("+----------------------------------------------------------------------");
		writer.println();

		if (!Controller._outputSummaryOnly) {
			dumpThreads(writer);
		}
		
		dumpFrames(writer);
		dumpClumpedFrames(writer);
		dumpAllocation(writer);
		
		writer.flush();
		out.close();		
	}
	
	private static void dumpThreads(PrintWriter writer) {
		
		// announce the control level for the threads
		//
		writer.println("+------------------------------");
		writer.print("| Thread depth limit: ");
		
		if (Controller._compactThreadDepth) {
			writer.println("Compact");
		}
		else if (Controller._threadDepth == Controller.UNLIMITED){
			writer.println("Unlimited");
		}
		else {
			writer.println(Controller._threadDepth);
		}
		
		writer.println("+------------------------------");
		
		// display the threads
		//
		for (Long threadId: Profile.threads()) {
			int i=1;
			
			for (Frame iteractionRoot: Profile.interactions(threadId)) {
				FrameDump.dump(writer, iteractionRoot, i);
				i++;
			}
		}
	}
	
	private static void dumpFrames(PrintWriter writer) {
		
		// announce the control level
		//
		writer.println();
		writer.println("+--------------------------------------");
		writer.println("| Most expensive methods (by net time)");
		writer.print("| Frame Count Limit: ");
		
		if (Controller._compactMethodCount) {
			writer.println("Compact");
		}
		else if (Controller._methodCount == Controller.UNLIMITED){
			writer.println("Unlimited");
		}
		else {
			writer.println(Controller._methodCount);
		}
		
		writer.println("+--------------------------------------");
		writer.println();
		
		// display the frame information
		//
		writer.println("               Net");
		writer.println("          ------------"); 
		writer.println(" Count     Time    Pct  Location");
		writer.println(" =====     ====    ===  ========");
		int count = 0;
		boolean display = true;
		Profile.sortFrameList(new FrameComparator());
		
		for (Frame frame: Profile.frameList()) {
			
			long threadId = frame.getThreadId();
			
			double threadTotalTime = Profile.getThreadTotalTime(threadId);
			double percent = Math.toPercent(frame.netTime(), threadTotalTime);
			double time = Math.nanoToMilli(frame.netTime());
			String name = frame.getName();
			
			if (display && belowThreshold(time, count)) {
				display = false;
			}
			
			count++;			
			
			if (display) {
				writer.printf("%6d ", frame._metrics.getCount());
				writer.printf("%8.1f  ", time);
				writer.printf("%5.1f  ", percent);
				writer.println(name);
			}
			
			clumpFrame(frame._metrics.getCount(), time, percent, name);
		}
	}
	
	private static void clumpFrame(long count, 
			double time, 
			double percent, 
			String name) {
		Holder h = _clumpedFrameMap.get(name);
		
		if (h == null) {
			h = new Holder(count, time, percent, name);
			_clumpedFrameMap.put(name, h);
		} else {
			h._count   += count;
			h._time    += time;
			h._percent += percent;
		}
	}
	
	
	private static void dumpClumpedFrames(PrintWriter writer) {
		writer.println();
		writer.println("+--------------------------------------+");
		writer.println("| Most expensive methods summarized    |");
		writer.println("+--------------------------------------+");
		writer.println();
		
		LinkedList<Holder> list = new LinkedList<Holder>();

		for (Holder h: _clumpedFrameMap.values()) {
			list.add(h);
		}
		
		Collections.sort(list, new HolderComparator());
		
		writer.println("               Net");
		writer.println("          ------------"); 
		writer.println(" Count     Time    Pct  Location");
		writer.println(" =====     ====    ===  ========");
		
		long count = 0;
		
		for (Holder h: list) {
			
			if (belowThreshold(h._time, count)) {
				break;
			}
			count++;
			
			writer.printf("%6d ", h._count);
			writer.printf("%8.1f  ", h._time);
			writer.printf("%5.1f  ", h._percent);
			writer.println(h._name);
		}
	}
	
	private static boolean belowThreshold(double time, long count) {
		
		if (Controller._compactMethodCount) {  
			if (time < (Controller._compactMethodThreshold)) {
				return true;
			}
		}
		else if (Controller._methodCount != Controller.UNLIMITED) {
			if (count+1 == Controller._methodCount) 
				return true;
		}
		
		return false;
	}
	
	private static void dumpAllocation(PrintWriter writer) {
		
		if (!Controller._trackObjectAlloc) {
			return;
		}
		
		writer.println();
		writer.println("+---------------------------------+");
		writer.println("| Object Allocation               |");
		writer.println("+---------------------------------+");
		writer.println();
		writer.println("     Count Class Name");
		writer.println("     ===== ==========");
		
		LinkedList<ClassAllocation> caList = new LinkedList<ClassAllocation>();

		for (ClassAllocation ca: Profile.allocations()) {
			caList.add(ca);
		}
		
		Collections.sort(caList, new ClassAllocComparator());
		
		for (ClassAllocation ca: caList) {
			writer.printf("%10d  ", ca.getAllocCount());
			writer.println(ca.getClassName());			
		}
	}	
}



class Holder {
	long _count;
	double _time;
	double _percent;
	String _name;
	
	Holder(long count, double time, double percent, String name) {
		_count = count;
		_time = time;
		_percent = percent;
		_name = name;
	}
}


class FrameComparator implements Comparator<Frame> {
	
	public int compare(Frame fa, Frame fb) {
		//
		// IMPORTANT NOTE: 
		// 
		// Returning:
		// fb.netTime() - fa.netTime()
		//
		// won't work. This is because netTime is a long. So, for 
		// example, if fb.netTime() is close to zero and fa.netTime()
		// is large, you might end up with a number that can't be expressed
		// properly as an integer.
		//
		
		if (fa.netTime() < fb.netTime()) {
			return 1;
		} else if (fa.netTime() == fb.netTime()) { 
			return 0;
		} else {
			return -1;
		}
	}
	
}

class HolderComparator implements Comparator<Holder> {
	
	public int compare(Holder ha, Holder hb) {
		
		if (ha._time < hb._time) {
			return 1;
		} else if (ha._time == hb._time) {
			return 0;
		} else {
			return -1;
		}
	}
}

class ClassAllocComparator implements Comparator<ClassAllocation> {
	
	public int compare(ClassAllocation ca1, ClassAllocation ca2) {
		return ca2.getAllocCount() - ca1.getAllocCount();
	}
}
