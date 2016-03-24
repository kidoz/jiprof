package com.mentorgen.tools.util.profile;
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


public class Client {
	
	static void help() {
		System.out.println("use: java -jar client.jar <cmd> <server> " +
			"<port> [file-name] [data-list]");
		System.out.println("where <cmd> is:");
		System.out.println("file\tstart\tfinish\tdebugon\tdebugoff\tgetexcludelist\treplaceexcludelist\tgetincludelist\treplaceincludelist");
        System.out.println("getclassloadersbyname\treplaceclassloadersbyname");
        System.out.println(" ");
		System.out.println("( [file-name] is only used by the file command");
        System.out.println("( [data-list] is only used by the replace include/exclude/classloadersbyname list commands");
	}

	public static void main(String[] args) {
		
		if (args.length == 0) {
			help();
			return;
		} else if ("file".equals(args[0]) && args.length == 4) {
			ClientHelper.send("file " + args[3], args[1], args[2]);
		} else if ("start".equals(args[0]) && args.length == 3) {
			ClientHelper.send("start", args[1], args[2]);
		} else if ("finish".equals(args[0]) && args.length == 3) {
            ClientHelper.send("finish", args[1], args[2]);
        } else if ("debugon".equals(args[0]) && args.length == 3) {
	        ClientHelper.send("debugon", args[1], args[2]);
        } else if ("debugoff".equals(args[0]) && args.length == 3) {
	        ClientHelper.send("debugoff", args[1], args[2]);
        } else if ("getexcludelist".equals(args[0]) && args.length == 3) {
	        ClientHelper.send("getexcludelist", args[1], args[2]);
		} else if ("replaceexcludelist".equals(args[0]) && args.length == 4) {
			ClientHelper.send("replaceexcludelist " + args[3], args[1], args[2]);
        } else if ("getincludelist".equals(args[0]) && args.length == 3) {
	        ClientHelper.send("getincludelist", args[1], args[2]);
        } else if ("getclassloadersbyname".equals(args[0]) && args.length == 3) {
	        ClientHelper.send("getclassloadersbyname", args[1], args[2]);
		} else if ("replaceincludelist".equals(args[0]) && args.length == 4) {
			ClientHelper.send("replaceincludelist " + args[3], args[1], args[2]);
		} else if ("replaceclassloadersbyname".equals(args[0]) && args.length == 4) {
			ClientHelper.send("replaceclassloadersbyname " + args[3], args[1], args[2]);
		} else {
			help();
		}
		
		return;
	}

}
