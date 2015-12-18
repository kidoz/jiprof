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
package com.mentorgen.tools.profile.runtime;

/**
 * A simple class to capture metrics for a method in a particular thread
 * 
 * @author Andrew Wilcox
 *
 */
final class Method {
	private String _className;
	private String _methodName;
	
	Method(String className, String method) {
		_className = className;
		_methodName = method;
	}

	String getClassName() {
		return _className;
	}
	
	String getMethodName() {
		return _methodName;
	}
	
	String toInvertedString() {
		String className = _className.replace('/', '.');
		
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
		b.append(':');
		b.append(_methodName);
		b.append("\t(");
		b.append(packageName);
		b.append(")");
		return b.toString();
	}
	
	//
	// from object
	//
	
	public String toString() {
		StringBuffer b = new StringBuffer(_className.replace('/', '.'));
		b.append(':');
		b.append(_methodName);
		return b.toString();
	}

	@Override
	public boolean equals(Object other) {
		assert other instanceof Method;
		Method m = (Method) other;
		return this._className.equals(m._className) 
			&& this._methodName.equals(m._methodName);
	}

	@Override
	public int hashCode() {
		return _className.hashCode() + _methodName.hashCode();
	}
	
}
