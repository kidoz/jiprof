package net.sourceforge.jiprof.instrument.clfilter;

import com.mentorgen.tools.profile.instrument.clfilter.ClassLoaderFilter;

public class EclipseOSGIClassLoaderFilter implements ClassLoaderFilter {
	private static final String CLASSLOADER = "org.eclipse.osgi.internal.baseadaptor.DefaultClassLoader"; 
	
	public boolean accept(ClassLoader loader) { 	
		return loader.getClass().getName().equals(CLASSLOADER); 
	} 
		 
	public boolean canFilter() { 
		return true; 
	}
}
