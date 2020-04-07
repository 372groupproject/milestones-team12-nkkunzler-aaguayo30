section .data
	msg_jmp		db "At instruction: "
	msg_jmp_len equ $ - msg_jmp

	msg_j		db "Jump", 0xa, 0x0 ; string followed by new line and null char
	msg_j_len	equ $ - msg_j

	msg_jeq		db "Jump if Equal", 0xa, 0x0
	msg_jeq_len equ $ - msg_jeq

	msg_jne		db "Jump if Not Equal", 0xa, 0x0
	msg_jne_len equ $ - msg_jne

	msg_jg		db "Jump if Greater Than", 0xa, 0x0
	msg_jg_len equ $ - msg_jg

	msg_jge		db "Jump if Greater Than or Equal", 0xa, 0x0
	msg_jge_len equ $ - msg_jge

	msg_jl		db "Jump if Less Than", 0xa, 0x0
	msg_jl_len equ $ - msg_jl

	msg_jle		db "Jump if Less Than or Equal", 0xa, 0x0
	msg_jle_len equ $ - msg_jle

section .text
global _start
	
_start:
	mov		rsi, msg_j
	mov 	rdx, msg_j_len
	call 	print_jmp_status ; Print "At Instruction: Jump"
	jmp		_label_jeq

_label_jeq:
	mov		rsi, msg_jeq
	mov		rdx, msg_jeq_len
	call	print_jmp_status ; Print "At Instruction: Jump if Equal"

	mov		rax, 0x1
	cmp		rax, 0x1
	je		_label_jne

_label_jne:
	mov		rsi, msg_jne
	mov		rdx, msg_jne_len
	call	print_jmp_status ; Print "At Instruction: Jump if Not Equal"

	mov		rax, 0x1
	cmp		rax, 0x2
	jne		_label_jg

_label_jg:
	mov		rsi, msg_jg
	mov		rdx, msg_jg_len
	call	print_jmp_status ; Print "At Instruction: Jump if Not Equal"

	mov		rax, 0x1
	cmp		rax, 0x0
	jg		_label_jge
	
_label_jge:
	mov		rsi, msg_jge
	mov		rdx, msg_jge_len
	call	print_jmp_status ; Print "At Instruction: Jump if Not Equal"

	mov		rax, 0x1
	cmp		rax, 0x1
	jge		_label_jl

_label_jl:
	mov		rsi, msg_jl
	mov		rdx, msg_jl_len
	call	print_jmp_status ; Print "At Instruction: Jump if Not Equal"

	mov		rax, 0x0
	cmp		rax, 0x1
	jl		_label_jle
	
_label_jle:
	mov		rsi, msg_jle
	mov		rdx, msg_jle_len
	call	print_jmp_status ; Print "At Instruction: Jump if Not Equal"

	mov		rax, 0x1
	cmp		rax, 0x1
	jle		_exit

_exit:
	mov		rax, 0x3c		; syscall set to 60, exit
	xor		rdi, rdi		; Set exit code to 0
	syscall

print_jmp_status:
	; The rsi, msg, and rdx, msg_len should be set before calling
	push	rsi
	push	rdx

	mov		rdi, 0x1		; print a string
	mov		rsi, msg_jmp	; Message to indicate start of new jump instruction
	mov		rdx, msg_jmp_len; Length of the jump instruction message
	mov		rax, 0x1		; syscall for printing
	syscall

	pop		rdx
	pop		rsi

	mov		rdi, 0x1		; print a string
	mov		rax, 0x1		; syscall for printing
	syscall

	ret 	; return to callee
