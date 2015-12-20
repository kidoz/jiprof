package sample.verboseclass;

import java.lang.instrument.ClassFileTransformer;
import java.lang.instrument.IllegalClassFormatException;
import java.lang.instrument.Instrumentation;
import java.security.ProtectionDomain;

public class Main {

	public static void premain(String args, Instrumentation inst) {
		inst.addTransformer(new Transformer());
	}
}

class Transformer implements ClassFileTransformer {
	
	public byte[] transform(ClassLoader loader, String className, 
			Class<?> classBeingRedefined, ProtectionDomain protectionDomain, 
			byte[] classfileBuffer) throws IllegalClassFormatException {
		System.out.print("Loading class: ");
		System.out.println(className);
		return classfileBuffer;
	}
}