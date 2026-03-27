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

import java.io.IOException;

import com.mentorgen.tools.profile.Controller;
import com.mentorgen.tools.profile.runtime.Profile;
import su.kidoz.jip.output.ProfileHtmlDump;
import su.kidoz.jip.output.ProfileJsonDump;
import su.kidoz.jip.output.ProfileOutputFiles;

/**
 * Will output the profile to a text file, an XML file or both
 * depending on the value of <code>output</code> property in the
 * profile properties file.
 * 
 * @author Andrew Wilcox
 * @see com.mentorgen.tools.profile.output.ProfileTextDump
 * @see com.mentorgen.tools.profile.output.ProfileXMLDump
 */
public final class ProfileDump {
	
	public static void dump() throws IOException {
		
		synchronized (Profile.class) {
			ProfileOutputFiles files = ProfileOutputFiles.create();
			
			switch (Controller._outputType) {
				case Text: 
					ProfileTextDump.dump(files);
					break;
				case XML : 
					ProfileXMLDump.dump(files);
					break;
				case JSON:
					ProfileJsonDump.dump(files);
					break;
				case Modern:
					ProfileJsonDump.dump(files);
					ProfileHtmlDump.dump(files);
					break;
				case All:
					ProfileTextDump.dump(files);
					ProfileXMLDump.dump(files);
					ProfileJsonDump.dump(files);
					ProfileHtmlDump.dump(files);
					break;
				default: 
					ProfileTextDump.dump(files);
					ProfileXMLDump.dump(files);
					break;
			}
		}
	}
	
}
