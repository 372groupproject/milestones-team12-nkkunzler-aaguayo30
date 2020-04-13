

section		.data
	nums			db		'1', 0x0, '2', '3', 0xa, 0x0
	ms_len			equ		$ - nums
	EXIT_SUCCESS 	equ		0
	SYS_exit		equ		60


section		.text

global		_start

_start:

	mov 	rdi, 0x1		; write to stdout
	mov 	rsi, [nums]		; store element of array
	mov		rdx, 1			; size of input
	mov		rax, 1			; syscall to write
	syscall
	
	mov 	rax, SYS_exit
	mov		rdi, EXIT_SUCCESS
	syscall
