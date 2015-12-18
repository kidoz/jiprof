/*
Copyright (c) 2005, MentorGen, LLC
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
package com.mentorgen.tools.profile.instrument;

import java.lang.instrument.ClassFileTransformer;
import java.lang.instrument.IllegalClassFormatException;
import java.security.ProtectionDomain;

import org.objectweb.asm.jip.ClassAdapter;
import org.objectweb.asm.jip.ClassReader;
import org.objectweb.asm.jip.ClassWriter;

import com.mentorgen.tools.profile.Controller;

/**
 * This class determines if a given class should be instrumented
 * with profiling code or not. The property <code>debug</code>, when
 * set to <code>on</code>, will show you which classes are being instrumented
 * and what ones are not.
 * 
 * @author Andrew Wilcox
 * @see java.lang.instrument.ClassFileTransformer
 */
public class Transformer implements ClassFileTransformer {
		
	public byte[] transform(ClassLoader loader, 
			String className, 
			Class<?> classBeingRedefined, 
			ProtectionDomain protectionDomain, 
			byte[] classfileBuffer) throws IllegalClassFormatException {
		
		// can't profile yourself
		//
		if (className.startsWith("com/mentorgen/tools/profile") ||
				className.startsWith("net/sourceforge/jiprof")) {
			return classfileBuffer;
		}
		
		// include
		//
 		if (Controller._includeList.length > 0) {
 			boolean toInclude = false;
 			
			for (String include: Controller._includeList) {
				if (className.startsWith(include)) {
					toInclude = true;
					break;
				}
			}
			
			if (!toInclude) {
				if (Controller._debug) {
					debug(loader, className, false);
				}
				
				return classfileBuffer;
			}
		}
		
		if (!Controller._filter.accept(loader)){
			
			if (Controller._debug) {
				debug(loader, className, false);
			}
			
			return classfileBuffer;
		}

		// exclude
		//
		for (String exclude: Controller._excludeList) {
			if (className.startsWith(exclude)) {
				if (Controller._debug) {
					debug(loader, className, false);
				}
				return classfileBuffer;
			}
		}
		
		byte[] result = classfileBuffer;
		try {
			if (Controller._debug) {
				debug(loader, className, true);
			}
			
			Controller._instrumentCount++;
			
			ClassReader reader = new ClassReader(classfileBuffer);
			ClassWriter writer = new ClassWriter(ClassWriter.COMPUTE_MAXS);
			ClassAdapter adapter = new PerfClassAdapter(writer, className);
			reader.accept(adapter, ClassReader.SKIP_DEBUG);
			result = writer.toByteArray();
		} catch (Throwable t) {
			t.printStackTrace();
			throw new RuntimeException(t);
		}
		
		return result;
	}
	
	
	private void debug(ClassLoader loader, String className, 
			boolean transformed) {
		StringBuffer b = new StringBuffer();
		
		if (transformed) {
			b.append("INST");
		} else {
			b.append("skip");
		}
		
		b.append("\t");
		b.append(className);
		b.append("\t");
		b.append("[");
		b.append(loader.getClass().getName());
		b.append("]");
		System.out.println(b.toString());
	}
}

