package sample.profiler;

import org.objectweb.asm.MethodAdapter;
import org.objectweb.asm.MethodVisitor;
import org.objectweb.asm.Opcodes;

import static org.objectweb.asm.Opcodes.INVOKESTATIC;


public class PerfMethodAdapter extends MethodAdapter {
	private String _className, _methodName;
	private boolean _isStatic;
	
	public PerfMethodAdapter(MethodVisitor visitor, 
			String className,
			String methodName,
			boolean isStatic) { 
		super(visitor);
		_className = className;
		_methodName = methodName;
		_isStatic = isStatic;
	}

	public void visitCode() {
		this.visitLdcInsn(_className);
		this.visitLdcInsn(_methodName);
	
		if (!_isStatic) {
			this.visitVarInsn(Opcodes.ALOAD, 0);
			this.visitMethodInsn(INVOKESTATIC, 
					"sample/profiler/Profile", 
					"start", 
					"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V");

		} else { 
		this.visitMethodInsn(INVOKESTATIC, 
				"sample/profiler/Profile", 
				"start", 
				"(Ljava/lang/String;Ljava/lang/String;)V");
		}
		
		super.visitCode();
	}

	public void visitInsn(int inst) {
		switch (inst) {
		case Opcodes.ARETURN:
		case Opcodes.DRETURN:
		case Opcodes.FRETURN:
		case Opcodes.IRETURN:
		case Opcodes.LRETURN:
		case Opcodes.RETURN:
		case Opcodes.ATHROW:
			this.visitLdcInsn(_className);
			this.visitLdcInsn(_methodName);

			if (!_isStatic) {
				this.visitVarInsn(Opcodes.ALOAD, 0);
				this.visitMethodInsn(INVOKESTATIC, 
						"sample/profiler/Profile", 
						"end", 
						"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V");
			} else {
				this.visitMethodInsn(INVOKESTATIC, 
						"sample/profiler/Profile", 
						"end", 
						"(Ljava/lang/String;Ljava/lang/String;)V");
			}
			break;
		default:
			break;
		}
		
		super.visitInsn(inst);
	}
	
}

