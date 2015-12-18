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
package com.mentorgen.tools.profile.instrument.clfilter;

/**
 * The <code>Profile</code> class is loaded by the &quot;
 * application&quot; classloader. This can be a problem because 
 * it's possble that classed that are loaded by other classloaders
 * (like the extensions classloader) might be instrumented to make
 * calls to the profiler. This results in a <code>
 * ClassNotFoundException</code>, which is not good. To make matters worse,
 * which classloader is the &quot;application&quot; classloader varies
 * depending on your environment. For example, a web app running under
 * Tomcat will have a different &quot;Application&quot; classloader 
 * than a stand alone application.
 * To get around this, JIP uses <code>ClassLoaderFiler</code>. Implementations
 * of this class do two things:
 * <ol>
 * 	<li>Determine if they are the right <code>ClassLoaderFilter</code> 
 * 		for a given runtime environment.</li>
 * 	<li>Determine if a given <code>ClassLoader</code> is the
 * &quot;Application&quot; classloader.</li>
 * </ol> 
 * The way JIP chooses the right <code>ClassLoaderFiler</code> is by 
 * going though a number of implementations until it finds one that
 * <code>canFilter()</code> in the given environment. This is accomplished
 * by configuring the profile properties file. 
 * For example, the default properties file has a 
			section that looks like:<pre><code>
ClassLoaderFilter.1=com.mentorgen.tools.profile.WebAppClassLoaderFilter
ClassLoaderFilter.2=com.mentorgen.tools.profile.StandardClassLoaderFilter
			</code></pre>
 * 
 * 
 * @author Andrew Wilcox
 *
 */
public interface ClassLoaderFilter {
	/**
	 * This method examines the environment to determine if
	 * it can be used to filter by <code>ClassLoader</code>.
	 * For example, a realization of this class for Tomcat
	 * might look for Tomcat's VM parameters to determine
	 * if the Tomcat is running in the VM.
	 */
	boolean canFilter();
	
	/**
	 * Tries to determine if the given <code>ClassLoader</code>
	 * is the &quot;application classloader&quot;. What this means exactly
	 * is dependent on the type of application (that is, this is 
	 * different for Tomcat than for a standalone app) 
	 * 
	 * @param loader
	 */
	boolean accept(ClassLoader loader);
}
