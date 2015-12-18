/*
Copyright (c) 2005-2006, MentorGen, LLC
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

import java.io.BufferedInputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Method;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketException;
import java.util.ArrayList;
import java.util.Properties;
import java.util.StringTokenizer;

import net.sourceforge.jiprof.instrument.clfilter.GenericClassLoaderFilter;

import com.mentorgen.tools.profile.instrument.clfilter.ClassLoaderFilter;
import com.mentorgen.tools.profile.instrument.clfilter.StandardClassLoaderFilter;
import com.mentorgen.tools.profile.output.ProfileDump;
import com.mentorgen.tools.profile.runtime.Profile;

/**
 * <code>Controller</code> reads the properties file that controls
 * how the profiler operates, both when the byte code is instrumented
 * as well as at runtime. It also opens a server socket to receive 
 * remote commands to modify the profiler's behavior, like turning 
 * the profiler on and off, but only if <code>remote=on</code> 
 * has been specified in the profile properties. Here's a short
 * description of all of the properties that are supported:
		<ul>
			<li><a href="#profiler">profiler</a></li>
			<li><a href="#remote">remote</a></li>
			<li><a href="#port">port</a></li>
			<li><a href="#classloader">ClassLoaderFilter.x</a></li>
			<li><a href="#thread-depth">thread-depth</a></li>
			<li><a href="#thread-threshold">thread.compact.threshold.ms</a></li>
			<li><a href="#max-method-count">max-method-count</a></li>
			<li><a href="#method-threshold">method.compact.threshold.ms</a></li>
			<li><a href="#file">file</a></li>
			<li><a href="#exlcude">exclude</a></li>
			<li><a href="#include">include</a></li>
			<li><a href="#alloc">track.object.alloc</a></li>
			<li><a href="#output">output</a></li>
			<li><a href="#debug">debug</a></li>
			<li><a href="#profiler-class">profiler-class</a></li>
			<li><a href="#output-method-signatures">output-method-signatures</a></li>
			<li><a href="#clock-resolution">clock-resolution</a></li>
			<li><a href="#output-summary-only">output-summary-only</li>
			<li><a href="#accept-class-loaders">accept-class-loaders</li>
            <li><a href="#accept-class-loaders-byname">accept-class-loaders-byname</li>
		</ul>
		
		<A NAME="profiler"/>
		<h3>profiler</h3>
		<blockquote>
			<b>Values</b>: on, off<br/>
			<b>Default</b>: on<br/>
			<b>Description</b>: controls whether or not profiling information
			is gathered when the VM starts. Usually you'll want this to 
			be on for command-line apps but off if you're profiling a web
			app.
		</blockquote>
		
		<a name="remote"/>
		<h3>remote</h3>
		<blockquote>
			<b>Values</b>: on, off<br/>
			<b>Default</b>: off<br/>
			<b>Description</b>: controls whether of not the remote interface
			is enabled or not. The remote interface allows you to turn the
			profiler on and off at runtime. This lets you take multiple 
			measurements without having to stop and start the application. 
			Usually you'll want this to be <code>on</code> for webapps
			but <code>off</code> for command-line apps.
		</blockquote>
		
		<a name="port"/>
		<h3>port</h3>
		<blockquote>
			<b>Values</b>: any valid TCP port number<br/>
			<b>Default</b>: 15599<br/>
			<b>Description</b>: this controls which port the remote interface 
			listens on.
		</blockquote>
		
		<a name="classloader"/>
		<h3>ClassLoaderFilter.x</h3>
		<blockquote>
			<b>Values</b>: any valid implemtation of 
			<code>com.mentorgen.tools.profile.ClassLoaderFilter</code><br/>
			<b>Default</b>: If no class loader filters a specificed then
		<code>net.sourceforge.jiprof.instrument.clfilter.GenericClassLoaderFilter</code>
			is used (see also: <a href="#accept-class-loaders">accept-class-loaders</a>).<br/>
			<b>Description</b>: JIP has to know which classloader will be 
			loading the classes to be profiled. With command-line
			apps we know what this is. However webapps and other
			kinds of apps that run in a container use different classloaders.
			The solution to this was to defined an interface: 
		<code>ClassLoaderFilter</code> to use in a chain of responsilbility
			pattern to determine which classloader should be "hooked"
			for profiling. The way this works is that you can define a number
			of realizations of this interface, one of each different env.
			You specify the search order by appending a number to the end
			of the property. For exmaple, the standard setup is:<pre><code>
ClassLoaderFilter.1=com.mentorgen.tools.profile.instrument.clfilter.WebAppClassLoaderFilter
ClassLoaderFilter.2=com.mentorgen.tools.profile.instrument.clfilter.StandardClassLoaderFilter		
	</code></pre>
			This indicates that the <code>WebAppClassLoaderFilter</code>
			should be called to determine if we're running in Tomcat. If that
			fails, call the <code>StandardClassLoaderFilter</code>. Note
			that currently only the Java 5(tm) and Tomcat 5.5 environments
			are supported. People who would like to add support for other
			environments are encouraged to do so.
		</blockquote>
		
		<a name="thread-depth"/>
		<h3>thread-depth</h3>
		<blockquote>
			<b>Values</b>: any positive integer, -1 or <i>compact</i><br/>
			<b>Default</b>: -1<br/>
			<b>Description</b>: Call stacks can get really deep and sometimes
			you only want to see a certain number of levels. This parameter
			controls the number of levels you will see. The default is -1 
			which means that there is no limit. Another option that can
			be used is <i>compact</i>. This will limit the call stacks
			to items that have a gross time that is at least 10 ms (this 
			can be <a href="#hread-threshold">changed</a>). Using
			<i>compact</i> is nice way to limit what you see while not
			imposing an arbitrary limit on the thread-depth.
		</blockquote>
		
		<a name="thread-threshold"/>
		<h3>thread.compact.threshold.ms</h3>
		<blockquote>
			<b>Values</b>: any positive integer<br/>
			<b>Default</b>: 10<br/>
			<b>Description</b>: Modifies the call stack output to 
			only show nodes with the given gross time. Only works when
			<code>thread-depth</code> is set to <i>compact</i>
		</blockquote>
		
		<a name="max-method-count"/>
		<h3>max-method-count</h3>
		<blockquote>
			<b>Values</b>: any positive integer, -1 or <i>compact</i><br/>
			<b>Default</b>: -1<br/>
			<b>Description</b>: This property modifieds the section 
			of the profiler output that shows the most expensive method. 
			Giving a number greater than -1 will limit the number of methods
			that are shown. -1 means no limit. <i>compact</i> can be usd to 
			show only methods with a creatin minimum gross time (the
			default is 10ms but can be changed by using 
			<a href="#method-threshold">method.compact.threshold.ms</a>
		</blockquote>
		
		<a name="method-threshold"/>
		<h3>method.compact.threshold.ms</h3>
		<blockquote>
			<b>Values</b>: any positive integer<br/>
			<b>Default</b>: 10<br/>
			<b>Description</b>: Modifies the method output to 
			only show methods with the given gross time. Only works when
			<code>max-method-count</code> is set to <i>compact</i>.
		</blockquote>
		
		<a name="file"/>
		<h3>file</h3>
		<blockquote>
			<b>Values</b>: the name of any valid file or directory.<br/>
			<b>Default</b>: ./profile.txt<br/>
			<b>Description</b>: Names the file that the profile is
			sent to. If this is a directory, JIP will auto-generate 
			file names and
			put the files in that directory. The format for the
			generated file name is <code>yyyyMMdd-HHmmss</code>.
		</blockquote>

		<a name="exlcude"/>
		<h3>exclude</h3>
		<blockquote>
			<b>Values</b>: a comman spearated list of package or class
			names (class names must be fully qualified).<br/>
			<b>Default</b>: <i>no default</i><br/>
			<b>Description</b>: the values for this property name
			packages or classes to be excluded from the profile. This
			is handy when you have a chatty package or class that you
			just don't want to see all over the place. Note that only
			classes that are loaded by the &quot;app&quot; class loader
			are profiled to start with.
		</blockquote>

		<a name="include"/>
		<h3>include</h3>
		<blockquote>
			<b>Values</b>: a comman spearated list of package or class
			names (class names must be fully qualified).<br/>
			<b>Default</b>: <i>no default</i><br/>
			<b>Description</b>: the values for this property name
			packages or classes to be explicitly included in the profile.
			Normally, you wouldn't use this, you'd let the <code><a href="#classloader">ClassLoaderFilter</a></code>
			determine which classes to include. If you don't want to see something,
			use <code><a href="#exlcude">exclude</a></code>. However, there
			are situations where you want to exclude so much stuff, that it's easier
			just to say what you want to be included. When using both exclude and include,
			the include list is applied, then the exclude list is applied.
		</blockquote>
		
		<a name="alloc"/>
		<h3>track.object.alloc</h3>
		<blockquote>
			<b>Values</b>: <code>on</code> or <code>off</code><br/>
			<b>Default</b>: <code>off</code><br/>
			<b>Description</b>: control whether or not JIP tracks 
			object allocation. 
		</blockquote>
		
		<a name="output"/>
		<h3>output</h3>
		<blockquote>
			<b>Values</b>: <code>text</code>, <code>xml</code> or <code>both</code><br/>
			<b>Default</b>: <code>text</code><br/>
			<b>Description</b>: in addition to the standard human readable
			profiles, this option allows you to output the profile information
			in a raw XML format.
		</blockquote>
		
		<a name="debug"/>
		<h3>debug</h3>
		<blockquote>
			<b>Values</b>: <code>on</code> or <code>off</code><br/>
			<b>Default</b>: <code>off</code><br/>
			<b>Description</b>: when debug is turned on, text will be sent to 
			standard out each time a class is classloaded and inspected by
			the profiler for possbile instrumentation (see <code>
			com.mentorgen.tools.profile.instrument.Transformer</code>). If the 
			class is instrumented, <code>INST</code>, plus the class name
			plus the classloader name will be sent to stddout. If the class
			is not instrumented, <code>skip</code>, plus the class name
			plus the classloader name will be sent to stddout. This is a 
			helpful tool when the profile you're getting (or not getting)
			doesn't match what you're expecting.<p/>
			In addition, text will be sent to standard error when an exception is
			detected and when the profile for a method has not been completed 
			when the profiler terminates. <br/>
			Exceptions are usually handled gracefully.
			However, there are some cases where they skew the timings and therefore
			the output is incorrect. Knowing that an exception is being thrown is a great
			help in diagnosing problems like this.<br/>
			Needing to &quot;fixup&quot; the profile
			for one or two methods is also not that unusual. However, if the timing
			for a method seems to be incorrect, knowing if the profiler needed to
			fixup that method can be useful from a diagnosics perspective.			
		</blockquote>
		
		<a name="profiler-class"/>
		<h3>profiler-class</h3>
		<blockquote>
			<b>Values</b>: any class name<br/>
			<b>Default</b>: <code>com.mentorgen.tools.profile.runtime.Profile</code><br/>
			<b>Description</b>: allows the another profiling backend to be used. 
		</blockquote>		
		
		<a name="output-method-signatures"/>
		<h3>output-method-signatures</h3>
		<blockquote>
			<b>Values:</b> <code>yes</code> or <code>no</code></br>
			<b>Default:</b> <code>no</code></br>
			<b>Description:</b> When set to <code>yes</code>, outputs the signature
			of methods. By default, the method signature is omitted from the output
			to save space. However, if you're dealing with methods that have been overloaded
			you need to be able to see the method signature.</br>
		</blockquote>
		
		<a name="clock-resolution"/>
		<h3>clock-resolution</h3>
		<blockquote>
			<b>Values:</b> <code>ms</code> or <code>ns</code></br>
			<b>Default:</b> <code>ns</code></br>
			<b>Description:</b> Sets the resolution of the TimeLineProfiler's clock to either milliseconds
			(<code>ms</code>) or nanoseconds (<code>ns</code>). Only valid when using the <code>
			TimeLineProfiler</code>.</br>
		</blockquote>
		
		<a name="output-summary-only"/>
		<h3>output-summary-only</h3>
		<blockquote>
			<b>Values:</b> <code>yes</code> or <code>no</code></br>
			<b>Default:</b> <code>no</code></br>
			<b>Description:</b> When set to <code>yes</code> the top most section of the profiler output
			(the section that contains thread + call stack information) is omitted. The section can be 
			quite large so it is sometime desirable to not have to page through it to get to the 
			summary information. </br>
		</blockquote>
		
		<a name="accept-class-loaders"/>
		<h3>accept-class-loaders</h3>
		<blockquote>
			<b>Values:</b> A comma separated list of classloader names (you can also specify
			interface names)</br>
			<b>Default:</b> If no values are given, <code>java.lang.ClassLoader.getSystemClassLoader()</code> 
			is used.</br>
			<b>Description:</b> A list of <code>Class Loaders</code> whose classes will be instrumented 
			when using <code>net.sourceforge.jiprof.instrument.clfilter.GenericClassLoaderFilter</code>
			as the classloader filter. Note that when looking to determine if profiling should be applied 
			to a classloader, <code>instanceof</code> is used as the mode of comparison. This means, for 
			example, that when profiling Tomcat, you can specify <code>org.apache.catalina.loader.Reloader</code>
			which is an interface rather than a subclass of <code>java.lang.ClassLoader</code>.
			</br>
		</blockquote>

 		<a name="accept-class-loaders-byname"/>
		<h3>accept-class-loaders-byname</h3>
		<blockquote>
			<b>Values:</b> A comma separated list of classloader names</br>
			<b>Default:</b>None</br>
			<b>Description:</b>A list of <code>Class Loaders</code> whose classes will be instrumented
			when using <code>net.sourceforge.jiprof.instrument.clfilter.CustomMultiClassLoaderFilter</code>
			as the classloader filter. The comparison used to determing if profiling should be applied is an exact
            string match to the classloader, an actual <code>instanceof</code> is not used.
			</br>
		</blockquote>
 * 
 * 
 * 
 * @author Andrew Wilcox
 *
 */
public class Controller implements Runnable {
	private static final String DEFAULT_PROFILE = "on";
	private static final String DEFAULT_REMOVE = "off";
	private static final String DEFAULT_PORT = "15599";
	private static final String DEFAULT_MAX_THREAD_DEPTH = "-1";
	private static final String DEFAULT_THREAD_COMPACT_THRESHOLD = "10";
	private static final String DEFAULT_MAX_METHOD_COUNT = "-1";
	private static final String DEFAULT_METHOD_COMPACT_THRESHOLD = "10";
	private static final String DEFAULT_FILE="profile.txt";
	private static final String DEFAULT_OBJECT_ALLOC = "off";
	private static final String DEFAULT_PROFILER_CLASS = "com.mentorgen.tools.profile.runtime.Profile";
	
	private static final String ON = "on";
	
	public static final int UNLIMITED = -1; 
	
	private static final String START = "start";
	private static final String STOP = "stop";
	private static final String DUMP = "dump";
	private static final String FILE = "file";
	private static final String CLEAR = "clear";
	private static final String FINISH = "finish";
    private static final String DEBUGON = "debugon";
    private static final String DEBUGOFF = "debugoff";
    private static final String REPLACEEXCLUDELIST = "replaceexcludelist";
    private static final String GETEXCLUDELIST = "getexcludelist";
    private static final String REPLACEINCLUDELIST = "replaceincludelist";
    private static final String GETINCLUDELIST = "getincludelist";
    private static final String GETCLASSLOADERSBYNAME = "getclassloadersbyname";
    private static final String REPLACECLASSLOADERSBYNAME = "replaceclassloadersbyname";
	
	public static enum OutputType {Text, XML, Both };
	public static enum TimeResolution { ms, ns };
	
	public static boolean _profile;
	public static boolean _remote;
	public static int _port;
	public static int _threadDepth;
	public static int _methodCount;
	public static String _fileName;
	public static String[] _excludeList;
	public static String[] _includeList;
    public static String[] _acceptClassLoadersByName;
	public static boolean _compactThreadDepth = false;
	public static boolean _compactMethodCount = false;
	public static int _compactThreadThreshold;
	public static int _compactMethodThreshold;
	public static boolean _trackObjectAlloc = false;
	public static ClassLoaderFilter _filter;
	public static OutputType _outputType  = OutputType.Text;
	public static boolean _debug = false;
	public static String _profiler;
	public static boolean _outputMethodSignatures = false;
	public static TimeResolution _timeResoltion;
	public static boolean _outputSummaryOnly = false;
	public static Class[] _acceptClassLoaders;
	
	public static int _instrumentCount = 0;
	
	private ServerSocket _socket; 
	
	static {
		Properties props = new Properties();
		String propsFile = System.getProperty("profile.properties");
		
		if (propsFile != null) {
			try {
				props.load(new FileInputStream(propsFile));
			} catch (IOException e) {
				System.err.print("Unable to open ");
				System.err.print(propsFile);
				System.err.println(". Using the defaults.");
			}			
		}
		
		String profile = getProperty(props,"profiler", DEFAULT_PROFILE);
		String remote = getProperty(props, "remote", DEFAULT_REMOVE);
		String port = getProperty(props, "port", DEFAULT_PORT);
		String threadDepth = getProperty(props, "thread-depth", DEFAULT_MAX_THREAD_DEPTH);
		String threadCompactThreshold = getProperty(props, "thread.compact.threshold.ms", DEFAULT_THREAD_COMPACT_THRESHOLD);
		String maxMethodCount = getProperty(props, "max-method-count", DEFAULT_MAX_METHOD_COUNT);
		String methodCompactThreshold = getProperty(props, "method.compact.threshold.ms", DEFAULT_METHOD_COMPACT_THRESHOLD);
		String file = getProperty(props,"file", DEFAULT_FILE);
		String objectAlloc = getProperty(props,"track.object.alloc", DEFAULT_OBJECT_ALLOC);
		String outputType = getProperty(props, "output", "text");
		String debug = getProperty(props, "debug", "off");
		String profiler = getProperty(props, "profiler-class", DEFAULT_PROFILER_CLASS);
		String methodSigs = getProperty(props, "output-method-signatures", "no");
		String clockResolution = getProperty(props, "clock-resolution", "ms");
		String outputSummaryOnly = getProperty(props, "output-summary-only", "no");
		
		Controller._profile = profile.equals(ON);
		Controller._remote = remote.equals(ON);
		Controller._port = Integer.parseInt(port);
		Controller._compactThreadThreshold = Integer.parseInt(threadCompactThreshold);
		Controller._compactMethodThreshold = Integer.parseInt(methodCompactThreshold);
		
		if ("compact".equals(threadDepth.trim())) {
			Controller._compactThreadDepth = true;
		} else {
			Controller._threadDepth = Integer.parseInt(threadDepth);
		}
		
		if ("compact".equals(maxMethodCount.trim())) {
			Controller._compactMethodCount = true;
		} else {
			Controller._methodCount = Integer.parseInt(maxMethodCount);
		}
		
		if ("on".equalsIgnoreCase(objectAlloc.trim())) {
			_trackObjectAlloc = true;
		}
		
		if ("on".equalsIgnoreCase(debug.trim())) {
			_debug = true;
		}
		
		if ("yes".equalsIgnoreCase(methodSigs)) {
			_outputMethodSignatures = true;
		}
		
		if ("text".equalsIgnoreCase(outputType.trim())) {
			_outputType = OutputType.Text;
		} else if ("xml".equalsIgnoreCase(outputType.trim())) {
			_outputType = OutputType.XML;
		} else if ("both".equalsIgnoreCase(outputType.trim())) {
			_outputType = OutputType.Both;
		}
		
		if ("ms".equalsIgnoreCase(clockResolution)) {
			_timeResoltion = TimeResolution.ms;
		} else {
			_timeResoltion = TimeResolution.ns;
		}
		
		if ("yes".equalsIgnoreCase(outputSummaryOnly)) {
			_outputSummaryOnly = true;
		}
		
		Controller._fileName = file;
		
		String excludeList = props.getProperty("exclude");
		String includeList = props.getProperty("include");

		System.out.print("exclude:");
		System.out.println(excludeList);

		if (includeList != null && includeList.length() > 0) {
			System.out.print("include:");
			System.out.println(includeList);
		}
		
		Controller._excludeList = parseList(excludeList, true);
		Controller._includeList = parseList(includeList, true);

        String ClassLoadersByName = props.getProperty("accept-class-loaders-byname");

        if (ClassLoadersByName != null && ClassLoadersByName.length() > 0) {
          System.out.println("Class loaders by name:");
          System.out.println(ClassLoadersByName);
        }

        Controller._acceptClassLoadersByName = parseList(props.getProperty("accept-class-loaders-byname"),false);

		String[] classLoaderNames = parseList(props.getProperty("accept-class-loaders", 
				ClassLoader.getSystemClassLoader().getClass().getName()), false);

		Controller._acceptClassLoaders = new Class[classLoaderNames.length];
		
		for (int i=0; i<classLoaderNames.length; i++) {
			try {
				Controller._acceptClassLoaders[i] = Class.forName(classLoaderNames[i]);
				System.out.println("Accept ClassLoader: " + Controller._acceptClassLoaders[i].getName());
			} catch (ClassNotFoundException e) {
				System.err.println("UNKNOWN CLASSLOADER: " + classLoaderNames[i]);
				System.err.println("Using the system classloader instead");
				Controller._acceptClassLoaders[i] = ClassLoader.getSystemClassLoader().getClass();
			}	
		}
		
		// get the class loader filter;
		
		for (int i=1; ; i++) {
			StringBuffer b = new StringBuffer("ClassLoaderFilter.");
			b.append(i);
			String filter = getProperty(props, b.toString(), null);
			
			if (filter == null) {
				break;
			}
			
			try {
				ClassLoaderFilter clf = (ClassLoaderFilter) 
					Class.forName(filter).newInstance();
				
				if (clf.canFilter()) {
					_filter = clf;
					break;
				}
			} catch (Exception e) {
				System.err.print("Could not instantiate ClassLoaderFilter ");
				System.err.println(filter);
			}
		}
		
		if (_filter == null) {
			System.err.println("Using the generic class loader filter.");
			_filter = new GenericClassLoaderFilter();
		}
		
		Controller._profiler = profiler.replace('.', '/');
		
		try {
			Class c = Class.forName(profiler);
			Method m = c.getMethod("initProfiler", new Class[0]);
			m.invoke(null, new Object[0]);
		} catch (Exception e) {
			System.err.println("Unable to invoke init on Profiler class.");
		}
		
		System.out.println("------------------");
	}
	
	private static String[] parseList(String list, boolean doReplacement) {	
		if (list == null || list.length() == 0 || list.equals("null")) {
			return new String[0];
		}
		
		ArrayList<String> al = new ArrayList<String>();
		StringTokenizer t = new StringTokenizer(list, ", ");
		
		while (t.hasMoreTokens()) {
			String token = t.nextToken();
			
			if (doReplacement) { 
				al.add(token.replace('.' , '/'));
			} else {
				al.add(token);
			}
		}
		
		String[] sl = new String[al.size()];
		al.toArray(sl);
		return sl;
	}
	
	private static String getProperty(Properties props, 
			String key, 
			String defaultValue) {
		
		String value = props.getProperty(key, defaultValue);
		System.out.print(key);
		System.out.print(": ");
		System.out.println(value);
		return value;
	}	
	
	public void setFileName(String fileName) {
		_fileName = fileName;
	}
    
    private void printStringArray(String[] TheArray)
    {

      if (TheArray == null || TheArray.length == 0)
        return;
      
      StringBuilder MyBuffer = new StringBuilder(256);
                    
      for (String MyWorkString : TheArray)
      {
        MyBuffer.append(MyWorkString.replace("/","."));
        MyBuffer.append(',');
      }
                    
      System.out.println(MyBuffer.toString().substring(0,MyBuffer.length()-1)); 
    }

	//
	// Thread to open a server socket and listen for commands
	//
	
	public void run() {
		try {
			_socket = new ServerSocket(_port);
			
			top:
			while (true) {
				Socket child = _socket.accept();

				// so that someone cannot tie-up this socket for too long
				//
				child.setSoTimeout(5000); 
				InputStream in = child.getInputStream();
				BufferedInputStream bin = new BufferedInputStream(in);
				StringBuffer b = new StringBuffer();
				
				while (true) {
					char c = (char) bin.read();
					
					if (c == '\r') {
						break;
					} else {
						b.append(c);
					}
				}
				
				String command = b.toString();
				System.out.println(command);
				
				if (command.startsWith(START)) {
					start();
				} else if (command.startsWith(STOP)) {
					stop();
				} else if (command.startsWith(DUMP)) {
					ProfileDump.dump();
				} else if (command.startsWith(CLEAR)) {
					Profile.init();
				} else if (command.startsWith(FILE)) {
					String name = command.substring(command.indexOf(' ')+1);
					_fileName = name;
                } else if (command.startsWith(GETCLASSLOADERSBYNAME)) {
                    System.out.println("Current class loaders by name:");
                    printStringArray(Controller._acceptClassLoadersByName);
                } else if (command.startsWith(REPLACECLASSLOADERSBYNAME)) {
                    if (Controller._profile == true) {
                      stop();
                      ProfileDump.dump();
                    }
                    String NewClassesByName = command.substring(command.indexOf(' ') + 1);
                    Controller._acceptClassLoadersByName = parseList(NewClassesByName,false);
                    System.out.print("New class loaders by name:");
                    printStringArray(Controller._acceptClassLoadersByName);
                } else if (command.startsWith(GETEXCLUDELIST)) {
                    System.out.println("Current exclude list:");
                    printStringArray(Controller._excludeList);
                } else if (command.startsWith(REPLACEEXCLUDELIST)) {
                    if (Controller._profile == true) {
                      stop();
                      ProfileDump.dump();
                    }
                    String TheExcludes = command.substring(command.indexOf(' ') + 1);
                    Controller._excludeList = parseList(TheExcludes, true);
                    System.out.println("New exclude list:");
                    printStringArray(Controller._excludeList);
                    Profile.init();
                } else if (command.startsWith(GETINCLUDELIST)) {
                    System.out.println("Current include list:");
                    printStringArray(Controller._includeList);
                } else if (command.startsWith(REPLACEINCLUDELIST)) {
                    if (Controller._profile == true) {
                      stop();
                      ProfileDump.dump();
                    }
                    String TheIncludes = command.substring(command.indexOf(' ') + 1);
                    Controller._includeList = parseList(TheIncludes, true);
                    System.out.println("New include list:");
                    printStringArray(Controller._includeList);
                    Profile.init();
                } else if (command.startsWith(DEBUGON)) {
                    _debug = true;
                } else if (command.startsWith(DEBUGOFF)) {
                    _debug = false;
				} else if (command.startsWith(FINISH)) {
					stop();              // stop
					ProfileDump.dump();	// dump
					Profile.init();		// clear
				}
				
				child.close();
			}
		} catch (SocketException e) {
			// eat this type of exception ...
		} catch (IOException e) {
			e.printStackTrace();
			throw new RuntimeException(e);
		}

	}
	
	public void close() throws IOException {
		System.err.println("Controller -- shuttingdown");
		
		if (_remote && _socket!= null && !_socket.isClosed()) {
			_socket.close();
		}
	}
	
	
	public void start() {

		// Nice little hack to explain to the user why they aren't getting
		// a profile.
		//
		if (_instrumentCount == 0) {
			System.err.println("Warning: a request has been made to start the " +
					"profiler but no classes have been instrumented. " +
					"Possible reasons: ");
			System.err.println("1. All the classes that have been classloaded " +
					"have been \"excluded\". Check the exclude property in " +
					"the current profile properties file.");
			System.err.println("2. No appropriate class loader filter has been " +
					"provided (see \"ClassLoaderFilter.x\" in the current " +
					"profile properties file.) If no appropriate " +
					"filter can be found, the standard filter is used. This" +
					"filter is really only useful for stand-alone " +
					"applications. Make sure your environment has a " +
					"ClassLoaderFilter and that your profile properties " +
					"file is configured correctly.");
			System.err.println("3. Sometimes when Tomcat is launched from " +
					"within " +
					"Eclipse, Tomcat, for some reason, will start using the " +
					"appication classloader (the one that stand-alone " +
					"apps use) to classload the webapp rather than the " +
					"web app classloader that it should use. One thing that " +
					"you can try to get around this odd behavior is to not " +
					"run Tomcat in debug mode (Window > Perferences > Tomcat > " +
					"JVM settings : Don't run Tomcat in debug mode.) If this " +
					"doesn't work, you could try removing the webapp " +
					"classlaoder filter from your profile properties file.");
		}
		
		Profile.clear();
		_profile = true;
	}
	
	public void stop() {
		
		// Explain to the user why they aren't going to be seeing a profile.
		//
		if (_instrumentCount == 0) {
			System.err.println("No classes have been instrumented for " +
					"profiling. There should be a previous message to this " +
					"effect which outlines why this is happening.");
		}
		
		Profile.shutdown();
	}
}
