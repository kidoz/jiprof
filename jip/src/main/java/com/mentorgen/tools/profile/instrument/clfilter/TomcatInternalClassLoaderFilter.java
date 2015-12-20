package com.mentorgen.tools.profile.instrument.clfilter;

public class TomcatInternalClassLoaderFilter implements ClassLoaderFilter {
	private static final String CLASSLOADER 
	= "org.apache.catalina.loader.StandardClassLoader";
	
	public boolean accept(ClassLoader loader) {
		return loader.getClass().getName().equals(CLASSLOADER);
	}

	public boolean canFilter() {
		return true;
	}

}
