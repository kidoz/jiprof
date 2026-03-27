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

import org.objectweb.asm.ClassVisitor;
import org.objectweb.asm.ClassReader;
import org.objectweb.asm.ClassWriter;

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
	public boolean shouldTransformClass(ClassLoader loader, String className) {
		if (className == null) {
			return false;
		}

		// can't profile yourself
		//
		if (className.startsWith("com/mentorgen/tools/profile") ||
				className.startsWith("net/sourceforge/jiprof")) {
			return false;
		}

		String[] includeList = Controller._includeList == null ? new String[0] : Controller._includeList;
		String[] excludeList = Controller._excludeList == null ? new String[0] : Controller._excludeList;

		if (includeList.length > 0) {
			boolean toInclude = false;

			for (String include: includeList) {
				if (className.startsWith(include)) {
					toInclude = true;
					break;
				}
			}

			if (!toInclude) {
				return false;
			}
		}

		return Controller._filter != null && Controller._filter.accept(loader) && !isExcluded(className, excludeList);
	}

	@Override
	public byte[] transform(ClassLoader loader, 
			String className, 
			Class<?> classBeingRedefined, 
			ProtectionDomain protectionDomain, 
			byte[] classfileBuffer) throws IllegalClassFormatException {
		return transformClass(loader, className, classBeingRedefined, protectionDomain, classfileBuffer);
	}

	@Override
	public byte[] transform(Module module,
			ClassLoader loader,
			String className,
			Class<?> classBeingRedefined,
			ProtectionDomain protectionDomain,
			byte[] classfileBuffer) throws IllegalClassFormatException {
		return transformClass(loader, className, classBeingRedefined, protectionDomain, classfileBuffer);
	}

	private byte[] transformClass(ClassLoader loader,
			String className,
			Class<?> classBeingRedefined,
			ProtectionDomain protectionDomain,
			byte[] classfileBuffer) throws IllegalClassFormatException {
		if (className == null || classfileBuffer == null) {
			return classfileBuffer;
		}

		if (!shouldTransformClass(loader, className)) {
			if (Controller._debug) {
				debug(loader, className, false);
			}

			return classfileBuffer;
		}
		
		byte[] result = classfileBuffer;
		try {
			if (Controller._debug) {
				debug(loader, className, true);
			}
			
			Controller._instrumentCount++;
			
			ClassReader reader = new ClassReader(classfileBuffer);
			ClassWriter writer = new FrameComputingClassWriter(reader, loader);
			ClassVisitor visitor = new PerfClassAdapter(writer, className);
			reader.accept(visitor, ClassReader.EXPAND_FRAMES);
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
		if (loader == null) {
			b.append("bootstrap");
		} else {
			b.append(loader.getClass().getName());
		}
		b.append("]");
		System.out.println(b.toString());
	}

	private static final class FrameComputingClassWriter extends ClassWriter {
		private final ClassLoader loader;

		private FrameComputingClassWriter(ClassReader reader, ClassLoader loader) {
			super(reader, ClassWriter.COMPUTE_FRAMES);
			this.loader = loader;
		}

		@Override
		protected String getCommonSuperClass(String type1, String type2) {
			try {
				Class<?> class1 = loadClass(type1);
				Class<?> class2 = loadClass(type2);

				if (class1.isAssignableFrom(class2)) {
					return type1;
				}
				if (class2.isAssignableFrom(class1)) {
					return type2;
				}
				if (class1.isInterface() || class2.isInterface()) {
					return "java/lang/Object";
				}

				do {
					class1 = class1.getSuperclass();
				} while (class1 != null && !class1.isAssignableFrom(class2));

				if (class1 == null) {
					return "java/lang/Object";
				}

				return class1.getName().replace('.', '/');
			} catch (Throwable ignored) {
				return "java/lang/Object";
			}
		}

		private Class<?> loadClass(String internalName) throws ClassNotFoundException {
			return Class.forName(internalName.replace('/', '.'), false, loader);
		}
	}

	private static boolean isExcluded(String className, String[] excludeList) {
		for (String exclude: excludeList) {
			if (className.startsWith(exclude)) {
				return true;
			}
		}

		return false;
	}
}
