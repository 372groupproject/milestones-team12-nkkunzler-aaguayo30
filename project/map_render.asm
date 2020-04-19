extern mvwaddch
extern wmove

section .bss
	map_char:	resb 1

section .text
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Parameters:	rdi - Window*
;				rsi - Map File
;				rdx - Map Size
;				rcx - X location
;				r8 	- Y location
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_render_map:
	; Saving the registers that are non-volatile
	PUSH	r12
	PUSH	r13
	PUSH	r14
	PUSH	r15
	PUSH	rdx				; Number of bytes to read
	MOV		r12, rdi		; Window *
	MOV		r13, rcx		; X Location
	MOV		r14, rcx		; Original X Location
	MOV		r15, r8			; Y Location

	; Opening the file
	MOV		rdi, rsi		; File Name
	MOV		rax, 0x2		
	XOR		rsi, rsi
	XOR		rdx, rdx
	SYSCALL

	POP		rcx				; Save number of bytes to read
	
	; Check that the file was opened, else throw an error
	TEST	rax, rax
	JL		_open_file_err	

	MOV		rbx, rax		; Map File
	PUSH	0x0				; Start location
_read:
	PUSH	rcx				; Save current number of bytes remaining

	XOR		rax, rax		; Read syscall value
	MOV		rdi, rbx		; Map file
	MOV		rsi, map_char	; Location to store read char
	MOV		rdx, 0x1		; Number of char's to read, this case just 1
	SYSCALL

	; Checking that the file was read, else throws an error
	TEST	rax, rax
	JL		_read_file_err	

	MOV		rcx, [map_char]
	CMP		rcx, 0xa		; Is current char '\n'
	JE		_new_line

	CMP		rcx, 0x0		; Is current char '\0'
	JE		_close
	
	CMP		rcx, 'S'		; Is current char 'S'
	JNE		_place_char

_set_start:
	; If the current char is an 'S', set starting cursor position
	POP		rcx
	POP		rdi
	MOV		rdi, r15		; currY
	SHL		rdi, 32			; Set upper 32 bits to be the y coord
	OR		rdi, r13		; Set the lower 32 bits to be the x coord
	PUSH	rdi
	PUSH	rcx

_place_char:
	; mvwaddch(Window, y, x, char)
	MOV		rdi, r12		; Window
	MOV		rsi, r15		; currY
	MOV		rdx, r13		; currX
	MOV		rcx, [map_char]	; char
	CALL	mvwaddch		; Adding the character to the terminal display

	ADD		r13, 1			; currX += 1
	POP		rcx				; Restore number of bytes left to print
	LOOP	_read			; Draw next character in file
	JMP		_close

_new_line:
	; Resets X position to initial position and increases y position by 1
	MOV		r13, r14		; currX = origX
	ADD		r15, 1			; currY = origY
	POP		rcx				; Restore number of bytes left to print
	LOOP	_read			; Draw next character in file

_close:
	; Setting the cursor position
	POP		rax				; 64 bit number, Upper 32 bits - y pos and lower 32 bits - x pos
	MOV		rsi, rax		; 64 bit y pos
	MOV		rdx, rax		; 64 bit x pos

	MOV		rdi, r12		; Window
	SHR		rsi, 32			; 32 bit y pos
	AND		rdx, 0xffffff	; 32 bit x pos
	CALL	wmove			; move cursor to start position

	; Closing the file
	MOV		rax, 0x3		; Syscall close value
	MOV		rdi, rbx		; File descriptor saved on line 16
	SYSCALL

	; Checking to make sure the file was actually close, otherwise throw an error
	TEST	rax, rax
	JL		_close_file_err	

	; Restore the stack and restore non-volatile registers used by caller
	POP		r15
	POP		r14
	POP		r13
	POP		r12
	XOR		rax, rax	
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;
; Error Handlers Below
;;;;;;;;;;;;;;;;;;;;;;;;;;
section .data
	open_err_msg:		db "File Open Error", 0xa, 0x0
	open_err_msg_len:	equ $ - open_err_msg

	read_err_msg:		db "File Read Error", 0xa, 0x0
	read_err_msg_len:	equ $ - read_err_msg

	close_err_msg:		db "File Close Error", 0xa, 0x0
	close_err_msg_len:	equ $ - close_err_msg

_open_file_err:
	; Restore stack and non-volatile registers
	POP		r15
	POP		r14
	POP		r13
	POP		r12

	MOV		rax, 0x1
	MOV		rdi, 0x1
	MOV		rsi, open_err_msg
	MOV		rdx, open_err_msg_len
	SYSCALL

	MOV		rax, 0x1
	RET

_read_file_err:
	; Restore stack and non-volatile registers
	ADD		rsp, 0x16
	POP		r15
	POP		r14
	POP		r13
	POP		r12

	MOV		rax, 0x1
	MOV		rdi, 0x1
	MOV		rsi, read_err_msg
	MOV		rdx, read_err_msg_len
	SYSCALL

	MOV		rax, 0x1
	RET

_close_file_err:
	; Restore stack and non-volatile registers
	POP		r15
	POP		r14
	POP		r13
	POP		r12

	MOV		rax, 0x1
	MOV		rdi, 0x1
	MOV		rsi, close_err_msg
	MOV		rdx, close_err_msg_len
	SYSCALL

	MOV		rax, 0x1
	RET
