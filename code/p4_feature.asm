section .data
	nums	dw	69, 420, 42069 
	len		equ 3

	new_line	db 	0xa

section .bss
	buffer	resb 33

section .text
global _start

_start:

_insertionSort:
	xor		r12, r12	; i
	mov		r13, 0x0	; j

_for_loop:
	add		r12, 0x1
	cmp		r12, len	; i > n
	jge		_p_end

	mov		r14, [nums+r12]; val = nums[i]

	mov		r13, r12	; j = i
	sub		r13, 1		; j = i - 1

_while_loop:
	cmp		r13, 0			; j < 0
	jmp		_for_loop

	mov		r15, [nums+r12]
	cmp		r14, r15
	jge		_for_loop

	add		r13, 1
	mov		[nums+r13], r9
	sub		r13, 1

	JMP		_while_loop

	add		r13, 1
	mov		[nums+r13], r15
	sub		r13, 1
	JMP		_for_loop

_p_end:
	mov		rdi, [nums]
	and		rdi, 0xffff
	CALL	_itoa

	mov		rsi, buffer
	mov		rax, 0x1
	mov		rdi, 0x1
	mov		rdx, 0x33
	syscall

	; Printing a new line
	mov		rax, 0x1
	mov		rdi, 0x1
	mov		rsi, new_line
	mov		rdx, 0x1
	syscall

	; Exit
	mov		rax, 0x3c
	xor		rdi, rdi
	syscall

_itoa:
	MOV		rax, rdi
	XOR		rcx, rcx
	
_itoa_h:
	XOR		rdx, rdx
	MOV		rbx, 10			
	DIV		rbx					; Div input value by 10
	ADD		rdx, '0'			; int val to corresponding str val

	LEA		rsi, [buffer + rcx]
	MOV		[rsi], dl			; Remainder of the division
	ADD		rcx, 1

	CMP		rax, 0x0			; Checking if quotient is zero
	JNE		_itoa_h
	
	ADD		rcx, -1	; Go to last char

_swap:
	CMP		rax, rcx
	JG		_end

	MOV		rdx, [buffer+rax]	; tmp

	LEA		rdi, [buffer+rax]	; &lhs
	MOV		rsi, [buffer+rcx]	; *rhs
	MOV		[rdi], sil			; *lhs = *rhs

	LEA		rsi, [buffer+rcx]	; &rhs
	MOV		[rsi], dl			; *rhs = tmp

	ADD		rax, 1				; lhs + 1
	ADD		rcx, -1				; rhs - 1
	JMP		_swap

_end:
	RET
