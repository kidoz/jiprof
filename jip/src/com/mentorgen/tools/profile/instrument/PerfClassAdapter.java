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

import org.objectweb.asm.jip.ClassAdapter;
import org.objectweb.asm.jip.ClassVisitor;
import org.objectweb.asm.jip.MethodVisitor;

import com.mentorgen.tools.profile.Controller;

/**
 * 
 * @author Andrew Wilcox
 * @see org.objectweb.asm.jip.ClassAdapter
 */
public class PerfClassAdapter extends ClassAdapter {
	private String className;
	
	public PerfClassAdapter(ClassVisitor visitor, String theClass) {
		super(visitor);
		this.className = theClass;
	}
	
	public MethodVisitor visitMethod(int arg,
			String name,
			String descriptor,
			String signature,
			String[] exceptions) {
		MethodVisitor mv = super.visitMethod(arg, 
				name, 
				descriptor, 
				signature, 
				exceptions);
		if (Controller._outputMethodSignatures && descriptor != null) {
			return new PerfMethodAdapter(mv, className, name + descriptor);
		} else {
			return new PerfMethodAdapter(mv, className, name);
		}
	}
	
}
