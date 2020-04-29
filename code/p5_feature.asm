;;;;;;;;;;;;;;;;;;;;;
; Showing some weird x86 instructions
; Its x86 so everything is weird
;;;;;;;;;;;;;;;;;;;;;
section .data
	no_output	db "Lets use funcky instructions do do nothing!", 0xa, 0x0
	no_output_len equ $ - no_output

section .text
global _start

_start:
	CMPXCHG	rax, rdx		; Like what??
	CPUID					; WHY

	; Who made x86?
	SFENCE					; I like fencing

	;INVLPGA					; Invalidate TLB netry in a specified ASID, ohh yes just what I needed

	F2XM1					; 2^x-1 because its just more precise, like why?
	FDISI					; Hate interrupts just diasable them
	FNDISI					; Even better, don't wait just do it

	; Here we go for all mathy people
	MOV		rax, 0x1
	FYL2X					; Cleary stands for y * lg x, duh
	MOV		rax, 0x20
	FYL2XP1					; of course its y * lg (x+1)

	; Print message
	MOV		rax, 0x1
	MOV		rdi, 0x1
	MOV		rsi, no_output
	MOV		rdx, no_output_len
	SYSCALL

	; system call exit, which is kinda cool
	SYSEXIT
	
	;Exit
	MOV		rax, 0x3c
	XOR		rdi, rdi
	SYSCALL
