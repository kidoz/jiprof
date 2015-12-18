// DeveloperWorksJavaCheck class
//
// This sample class is designed to check the VM version of the 
// installed JAva and also report the runtime version and VM vendor.
// It takes no input and returns the VM and VM vendor 
// on a single line separated by a tab.
// See the "Author guidelines" tab at 
// http://www.ibm.com/developerworks/aboutdw/
// for more information on how to use this program.
// © Copyright IBM Corporation 2004. All rights reserved.

import java.lang.System;

public class DeveloperWorksJavaCheck {
    public static void main(String[] argv)
    {  
        System.out.println(System.getProperty("java.specification.version") + 
			   '\t' + 
			   System.getProperty("java.runtime.version") +
			   '\t' +
			   System.getProperty("java.vm.vendor") );
    }
}

