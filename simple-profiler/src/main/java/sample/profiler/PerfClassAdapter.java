package sample.profiler;

import org.objectweb.asm.ClassVisitor;
import org.objectweb.asm.MethodVisitor;
import org.objectweb.asm.Opcodes;


public class PerfClassAdapter extends ClassVisitor {
    private String className;

    public PerfClassAdapter(ClassVisitor visitor, String theClass) {
        super(Opcodes.ASM5, visitor);
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

        return new PerfMethodAdapter(mv, className, name, isStatic);
    }
}
