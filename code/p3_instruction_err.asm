;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This is another example of a run time error in which the
; stack is destroyed by a procedure. As a result of a destroyed
; stack, the return is referencing a bad instruction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section .text
global _start

_start:
	CALL	_destroy_stack

	; Exit
	MOV		rax, 0x3c
	XOR		rdi, rdi
	SYSCALL

_destroy_stack:
	pop		rdi
	pop		rdi
	pop		rdi
	pop		rsi
	pop		rsi
	pop		rsi
	RET				; Destroyed the stack and therefore the ret value is referencing wrong address

