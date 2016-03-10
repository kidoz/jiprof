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

    @Override
    public MethodVisitor visitMethod(
            int arg,
            String name,
            String descriptor,
            String signature,
            String[] exceptions
    ) {
        final MethodVisitor methodVisitor = super.visitMethod(
                arg,
                name,
                descriptor,
                signature,
                exceptions
        );
        final boolean isStatic = ((arg & Opcodes.ACC_STATIC) != 0) || (name.equals("<init>"));

        return new PerfMethodAdapter(methodVisitor, className, name, isStatic);
    }
}
