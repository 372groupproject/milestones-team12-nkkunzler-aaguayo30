;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This is an example of a compile like error
; as the program is trying to store a value
; larger than one byte into a register that
; can only hold a maximum value of 1 byte.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text
global _start

_start:
	MOV		al, 0x100	; al register is only 1 byte in size and cannot store the value 256

	; Exit
	MOV		rax, 0x3c
	MOV		rdi, 1
	SYSCALL
