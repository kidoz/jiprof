package sample.profiler;

import org.objectweb.asm.ClassReader;
import org.objectweb.asm.ClassVisitor;
import org.objectweb.asm.ClassWriter;

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

    public byte[] transform(
            ClassLoader loader,
            String className,
            Class<?> classBeingRedefined,
            ProtectionDomain protectionDomain,
            byte[] classfileBuffer
    ) throws IllegalClassFormatException {

        // can only profile classes that will be able to see
		// the Profile class which is loaded by the application
		// classloader
		//
		if (loader != ClassLoader.getSystemClassLoader()) {
			return classfileBuffer;
		}
		
		// can't profile yourself
		//
		if (className.startsWith("sample/profiler")) {
			return classfileBuffer;
		}

        final ClassReader reader = new ClassReader(classfileBuffer);
        final ClassWriter writer = new ClassWriter(ClassWriter.COMPUTE_FRAMES);
        final ClassVisitor adapter = new PerfClassAdapter(writer, className);
        reader.accept(adapter, ClassReader.EXPAND_FRAMES);

		return writer.toByteArray();
	}
}