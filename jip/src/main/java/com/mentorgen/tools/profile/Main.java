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
package com.mentorgen.tools.profile;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.lang.instrument.Instrumentation;
import java.util.Properties;

import com.mentorgen.tools.profile.instrument.Transformer;


public class Main {
	
	/**
	 * Useage: <br>
	 * <pre><code>java -javaagent:lib/profile.jar -Dprofile.properties=properties-file-name</code></pre>
	 * <p>
	 * 
	 * 
	 * @param args
	 * @param inst
	 */
	public static void premain(String args, Instrumentation inst) {
		Properties props = null;
		
		if (args != null && args.length() != 0 && !args.equals("null")) {
			System.err.println("The -javaagent:foo=bar syntax is no " +
					"longer supported.");
			System.err.println("Use the VM property profile.properties " +
					"instead.");
			System.err.println("Continuing using the defaults.");
		}
		
		if (args == null || args.length() == 0 || args.equals("null")) {
			props = new Properties();
		} else if (! new File(args).exists()) {
			props = new Properties();
		} else {
			props = new Properties();
			try {
				props.load(new FileInputStream(args));
			} catch (IOException e) {
				e.printStackTrace();
				// leave the props file empty
			}
		}
		
		inst.addTransformer(new Transformer());
	}

}
