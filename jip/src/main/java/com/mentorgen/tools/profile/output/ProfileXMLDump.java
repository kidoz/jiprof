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
import java.util.Date;
import java.util.HashMap;

import com.mentorgen.tools.profile.Controller;
import com.mentorgen.tools.profile.runtime.ClassAllocation;
import com.mentorgen.tools.profile.runtime.Frame;
import com.mentorgen.tools.profile.runtime.Profile;

/**
 * This class outputs the profile as an XML document. We're creating the
 * XML document by hand rather than by using one of the standard XML 
 * libraries. We're doing it this way to avoid using non-core libraries
 * (I'm not sure if this is warrented).
 * <br/>
 * Since XML can be verbose, a number of things were done to help limit
 * the file size:
 * <ul>
 * 	<li>When outputting a stack frame, the following abbreviations are used:
 * 		<ul>
 * 			<li><em>cn</em> &mdash; class name</li>
 * 			<li><em>mn</em> &mdash; method name</li>
 * 			<li><em>c</em> &mdash; call count</li>
 *  		<li><em>t</em> &mdash; total time</li>
 * 		</ul>
 * 	</li>
 * 	<li>The full class names have been abbreviated. Usually, the 
 * 	abbreviation is just the class name. There is a section at the
 * 	end of the XML document that maps the short class names to
 * 	the fully qualifed class names.</li>
 * </ul>
 * 
 * @author Andrew Wilcox
 * @see com.mentorgen.tools.profile.output.ProfileTextDump
 */
final class ProfileXMLDump {
	
	private static HashMap<String, String> _classNameMap 
		= new HashMap<String, String>();
	
	private static String _fileName;
	private static String _date;

	static void dump() throws IOException {
		createFileName();
		
		FileWriter out = new FileWriter(_fileName);
		BufferedWriter bufferedWriter = new BufferedWriter(out);
		PrintWriter writer = new PrintWriter(bufferedWriter);
		
		outputHeader(writer);
		outputCallGraph(writer);
		outputObjectAlloc(writer);
		outputClassMap(writer);
		outputEnd(writer);
		
		writer.flush();
		out.close();
	}
	
	
	private static void createFileName() {
		File f = new File(Controller._fileName);
		SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd-HHmmss");
		_date = df.format(new Date());
		
		if (f.isDirectory()) {
			StringBuffer b = new StringBuffer(f.getAbsolutePath());
			b.append(File.separator);
			b.append(_date);
			b.append(".xml");
			_fileName = b.toString();
		} else {
			String fileName = Controller._fileName.trim();
			
			if (fileName.endsWith(".txt")) {
				String t = fileName;
				t = t.substring(0, t.length() - 4);
				StringBuffer b = new StringBuffer(t);
				b.append(".xml");
				_fileName = b.toString();
			} else if (fileName.endsWith(".xml")) {
				_fileName = fileName;
			} else {
				StringBuffer b = new StringBuffer(fileName);
				b.append(".xml");
				_fileName = b.toString();
			}
		}
	}

	
	private static void outputHeader(PrintWriter writer) 
	throws IOException {
		writer.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
		startElement(writer, "profile", 0);
		attribute(writer, "file", _fileName);
		attribute(writer, "date", _date);
		cap(writer);
	}
	
	
	private static void outputCallGraph(PrintWriter writer) 
	throws IOException {

		for(Long threadId: Profile.threads()) {
			startElement(writer, "thread", 1);
			attribute(writer, "id", threadId);
			cap(writer);

			int i = 1;
			for (Frame f: Profile.interactions(threadId)) {
				startElement(writer, "interaction", 2);
				attribute(writer, "id", i++);
				cap(writer);
				outputFrame(writer, f, 3);
				endElement(writer, "interaction", 2);
			}
			
			endElement(writer, "thread", 1);
		}		
	}
	
	
	private static void outputFrame(PrintWriter writer, Frame f, int depth) 
	throws IOException {
		
		startElement(writer, "frame", depth);
		attribute(writer, "cn", shortenClassName(f.getClassName()));
		attribute(writer, "mn", f.getName());
		attribute(writer, "c", f._metrics.getCount());
		attribute(writer, "t", f._metrics.getTotalTime());
		
		if (!f.hasChildren()) {
			endElement(writer);
			return;
		}
		
		cap(writer);
		
		for (Frame child: f.childIterator()) {
			outputFrame(writer, child, depth+1);
		}
		
		endElement(writer, "frame", depth);
	}
	
	private static void outputObjectAlloc(PrintWriter writer) 
	throws IOException {
		startElement(writer, "allocation", 1);
		cap(writer);

		for (ClassAllocation alloc: Profile.allocations()) {
			startElement(writer, "class", 2);
			attribute(writer, "cn", shortenClassName(alloc.getInternalClassName()));
			attribute(writer, "c", alloc.getAllocCount());
			endElement(writer);
		}
		
		endElement(writer, "allocation", 1);
	}
	
	
	private static void outputClassMap(PrintWriter writer) 
	throws IOException {
		startElement(writer, "class-map", 1);
		cap(writer);
		
		for (String key: _classNameMap.keySet()) {
			String value = _classNameMap.get(key);
			startElement(writer, "entry", 2);
			attribute(writer, "s", key); //shortened name
			attribute(writer, "f", value); // full name
			endElement(writer);
		}
		
		endElement(writer, "class-map", 1);
	}
	
	//
	// Helper methods ...
	//
	
	private static void outputEnd(PrintWriter writer) 
	throws IOException {
		endElement(writer, "profile", 0);
	}
	
	
	private static void startElement(PrintWriter writer, String element, 
			int depth) throws IOException {
		
		for (int i=0; i<depth; i++) {
			writer.print('\t');
		}

		writer.print("<");
		writer.print(element);
	}
	
	
	private static void cap(PrintWriter writer) {
		writer.println(">");	
	}
	
	
	private static void endElement(PrintWriter writer) {
		writer.println("/>");
	}
	
	
	private static void endElement(PrintWriter writer, String element, 

			int depth) throws IOException {
		for (int i=0; i<depth; i++) {
			writer.print('\t');
		}
		
		writer.print("</");
		writer.print(element);
		writer.println(">");
	}
	
	
	private static void attribute(PrintWriter writer, String name, 
			Object value) throws IOException {
		writer.print(" ");
		writer.print(name);
		writer.print("=\"");
		
		char[] string = value.toString().toCharArray();
		
		for (char c : string) {
			if (c == '<') {
				writer.print("&lt;");
			} else if (c == '>') {
				writer.print("&gt;");
			} else {
				writer.print(c);
			}
		}
		
		writer.print("\"");
	}
	
	private static String shortenClassName(String className) {
		StringBuffer shortName = new StringBuffer();
		char[] string = className.toCharArray();
		
		for (int i=string.length-1; i>=0; i--) {
			
			if (string[i] == '/') {
				String fullName = _classNameMap.get(shortName.toString());
				
				if (fullName == null) {
					_classNameMap.put(shortName.toString(), className);
					return shortName.toString();
				} 
				
				if (fullName.equals(className)) {
					return shortName.toString();
				}
			}
			
			shortName.insert(0, string[i]);
		}
		
		return className;
	}

}
