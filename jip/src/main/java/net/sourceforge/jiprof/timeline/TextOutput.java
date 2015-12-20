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

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;

import com.mentorgen.tools.profile.Controller;



public class TextOutput {

	public static void dump() throws IOException {
		System.err.println("TimeLine Profiler: generating output");
		
		// this section of code is almost identical to ProfileTextDump
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
		
		for (TimeRecord rec: TimeLineProfiler._timeLine) {
			writer.print("Time: ");
			writer.print(rec._pointInTime - TimeLineProfiler._startTime);
			
			if (Controller._timeResoltion == Controller.TimeResolution.ns) {
				writer.println(" ns.");
			} else {
				writer.println(" ms.");
			}
			
			for (ActionRecord act: rec._actionRecordList) {
				writer.print('\t');
				
				if (act.getAction() == Action.START) {
					writer.print("START");
				} else if (act.getAction() == Action.STOP){
					writer.print("END");
				} else if (act.getAction() == Action.ALLOC) {
					writer.print("ALLOC");
				} else if (act.getAction() == Action.BEGIN_WAIT) {
					writer.print("W:START");
				} else if (act.getAction() == Action.END_WAIT) {
					writer.print("W:END");
				} else if (act.getAction() == Action.EXCEPTION) {
					writer.print("THROWS");
				} else {
					writer.print("???");
				}
				
				writer.print('\t');
				
				writer.print('[');
				writer.print(act.getThreadId());
				writer.print("]\t");
				
				// copied verbatium from Method
				//
				String className = act.getClassName().replace('/', '.');
				
				int index = className.lastIndexOf('.');
				String shortName = null;
				String packageName = "";  
					
				if (index > -1) {
					shortName = className.substring(index+1);
					packageName = className.substring(0, index);
				} else {
					shortName = className; 
				}
				
				StringBuffer b = new StringBuffer();
				b.append(shortName);
				
				if (act.getMethodName().length()> 0) {
					b.append(':');
					b.append(act.getMethodName());					
				}
				
				b.append("\t(");
				b.append(packageName);
				b.append(")");
				writer.println(b.toString());
			}
			
		}
		
		writer.flush();
		writer.close();
	}
}
