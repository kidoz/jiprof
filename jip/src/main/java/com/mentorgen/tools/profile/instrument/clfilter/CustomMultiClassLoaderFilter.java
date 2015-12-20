package com.mentorgen.tools.profile.instrument.clfilter;

import com.mentorgen.tools.profile.Controller;
import com.mentorgen.tools.profile.instrument.clfilter.ClassLoaderFilter;


public class CustomMultiClassLoaderFilter implements ClassLoaderFilter
{
    public boolean canFilter() 
    {
      return true;
    }
	
    public boolean accept(ClassLoader loader) 
    {

      for (String TheClassLoaderName : Controller._acceptClassLoadersByName)
      {
        if (loader.getClass().getName().equals(TheClassLoaderName))
        {
          return true;
        }
      }

      return false;
    }
}
