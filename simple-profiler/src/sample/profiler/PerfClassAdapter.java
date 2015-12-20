package sample.profiler;

import java.lang.reflect.Method;

import org.objectweb.asm.ClassAdapter;
import org.objectweb.asm.ClassVisitor;
import org.objectweb.asm.MethodAdapter;
import org.objectweb.asm.MethodVisitor;
import org.objectweb.asm.Opcodes;


public class PerfClassAdapter extends ClassAdapter {
	private String className;
	
	public PerfClassAdapter(ClassVisitor visitor, String theClass) {
		super(visitor);
		this.className = theClass;
	}

	
	public MethodVisitor visitMethod(int arg,
			String name,
			String descriptor,
			String signature,
			String[] exceptions) {
		MethodVisitor mv = super.visitMethod(arg, 
				name, 
				descriptor, 
				signature, 
				exceptions);
		boolean isStatic = ((arg & Opcodes.ACC_STATIC) != 0) || (name.equals("<init>"));
		MethodAdapter ma = new PerfMethodAdapter(mv, className, name, isStatic);
		return ma;
	}
	
}
