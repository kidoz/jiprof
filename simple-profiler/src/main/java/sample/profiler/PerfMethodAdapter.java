package sample.profiler;

import org.objectweb.asm.MethodVisitor;
import org.objectweb.asm.Opcodes;

import static org.objectweb.asm.Opcodes.INVOKESTATIC;


public class PerfMethodAdapter extends MethodVisitor {

    private String className;
    private String methodName;
    private boolean isStatic;

    public PerfMethodAdapter(
            MethodVisitor visitor,
            String className,
            String methodName,
            boolean isStatic
    ) {
        super(Opcodes.ASM5, visitor);
        this.className = className;
        this.methodName = methodName;
        this.isStatic = isStatic;
    }

    @Override
    public void visitCode() {
        this.visitLdcInsn(className);
        this.visitLdcInsn(methodName);

        if (!isStatic) {
            this.visitVarInsn(Opcodes.ALOAD, 0);
            this.visitMethodInsn(
                    INVOKESTATIC,
                    "sample/profiler/Profile",
                    "start",
                    "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V",
                    false
            );

        } else {
            this.visitMethodInsn(
                    INVOKESTATIC,
                    "sample/profiler/Profile",
                    "start",
                    "(Ljava/lang/String;Ljava/lang/String;)V",
                    false
            );
        }

        super.visitCode();
    }

    @Override
    public void visitInsn(int inst) {
        switch (inst) {
            case Opcodes.ARETURN:
            case Opcodes.DRETURN:
            case Opcodes.FRETURN:
            case Opcodes.IRETURN:
            case Opcodes.LRETURN:
            case Opcodes.RETURN:
            case Opcodes.ATHROW:
                this.visitLdcInsn(className);
                this.visitLdcInsn(methodName);

                if (!isStatic) {
                    this.visitVarInsn(Opcodes.ALOAD, 0);
                    this.visitMethodInsn(
                            INVOKESTATIC,
                            "sample/profiler/Profile",
                            "end",
                            "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V",
                            false
                    );
                } else {
                    this.visitMethodInsn(
                            INVOKESTATIC,
                            "sample/profiler/Profile",
                            "end",
                            "(Ljava/lang/String;Ljava/lang/String;)V",
                            false
                    );
                }
                break;
            default:
                break;
        }

        super.visitInsn(inst);
    }
}

