extern mvwaddch

section .data
	open_err_msg:		db "File Open Error", 0xa, 0x0
	open_err_msg_len:	equ $ - open_err_msg

	read_err_msg:		db "File Read Error", 0xa, 0x0
	read_err_msg_len:	equ $ - read_err_msg

	close_err_msg:		db "File Close Error", 0xa, 0x0
	close_err_msg_len:	equ $ - close_err_msg

	file_buffer_len:	equ 1282 ; (# rows + 1) * (# cols): Map = 60 col x 21 row

section .bss
	file_buffer:		resb 1283


section .text
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Parameters:	rdi - Window*
;				rsi - Map File
;				rdx - X location
;				rcx - Y location
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_render_map:
	; Saving the registers that are non-volatile
	PUSH	r12
	PUSH	r13
	PUSH	r14
	PUSH	r15
	PUSH	rbx

	PUSH	rdi
	PUSH	rdx
	PUSH	rcx

	; Opening the file
	MOV		rdi, rsi
	MOV		rax, 0x2
	MOV		rsi, 0x0
	MOV		rdx, 0x0
	SYSCALL

	push	rax				; Save file descriptor
	TEST	rax, rax
	JL		_open_file_err	; Will restore the stack

	; Reading the file into a buffer
	MOV		rdi, rax
	MOV		rax, 0x0
	MOV		rsi, file_buffer
	MOV		rdx, file_buffer_len
	SYSCALL

	TEST	rax, rax
	JL		_read_file_err	; Will restore the stack

	; Closing the file
	MOV		rax, 0x3
	POP		rdi				; File descriptor saved on line 16
	SYSCALL

	TEST	rax, rax
	JL		_close_file_err	; Will restore the stack

	; Creating Ncurses screen based off file buffer
	POP		r12			; currY
	POP		r13			; currX
	POP		rbx			; Window
	MOV		r14, r13	; origX
	MOV		r15, file_buffer
	MOV		rcx, 0x0	; Start position

_load_buffer:
	XOR		rax, rax
	MOV		al, [r15]; Set lower 8 bits to the char at head of buffer

	CMP		rax, 0xa	; If new line increase Y coord and reset X coord
	JE		_new_line

	CMP		rax, 0x0	; If end of buffer, exit render and return to callee
	JE		_finish_load

	CMP		rax, 'S'
	JNE		_place_char

_set_start:
	; Sets the starting point, which will be returned
	MOV		rcx, r13	
	SHR		rcx, 32		; Shift right by 32 bits, upper 32 bits are x loc
	OR		rcx, r12	; Lower 32 bits are the y loc

_place_char:
	PUSH	rcx
	; mvwaddch(Window, y, x, char)
	MOV		rdi, rbx	; Window
	MOV		rsi, r12	; currY
	MOV		rdx, r13	; currX
	MOV		rcx, rax	; char
	CALL	mvwaddch
	
	POP		rcx
	ADD		r13, 1		; currX + 1
	ADD		r15, 1		; next char in buffer
	JMP		_load_buffer

	
_new_line:
	MOV		r13, r14	; currX = origX
	ADD		r12, 1		; currY = origY
	ADD		r15, 1		; Next character in map buffer
	JMP		_load_buffer

_finish_load:
	POP		rbx
	POP		r15
	POP		r14
	POP		r13
	POP		r12
	MOV		rax, rcx
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;
; Error Handlers Below
;;;;;;;;;;;;;;;;;;;;;;;;;;

_open_file_err:
	MOV		rsi, 32
	SUB		rsp, 0x4
	MOV		rax, 0x1
	MOV		rdi, 0x1
	MOV		rsi, open_err_msg
	MOV		rdx, open_err_msg_len
	SYSCALL

	MOV		rax, 0x1
	RET

_read_file_err:
	MOV		rsi, 32
	SUB		rsp, 0x4
	MOV		rax, 0x1
	MOV		rdi, 0x1
	MOV		rsi, read_err_msg
	MOV		rdx, read_err_msg_len
	SYSCALL

	MOV		rax, 0x1
	RET

_close_file_err:
	MOV		rsi, 24
	MOV		rax, 0x1
	MOV		rdi, 0x1
	MOV		rsi, close_err_msg
	MOV		rdx, close_err_msg_len
	SYSCALL

	MOV		rax, 0x1
	RET


	
