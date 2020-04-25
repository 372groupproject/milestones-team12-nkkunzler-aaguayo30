extern mvwaddch
extern wmove

section .text
	err db "easports", 0x0

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
	PUSH	rbp
	MOV		rbp, rsp

	; Storing parameters on the stack
	SUB		rsp, 24
	MOV		[rbp-8], rdi	; Window to render to
	MOV		[rbp-16], rcx	; Game map X position in window
	MOV		QWORD [rbp-24], 0x0	; Starting position



	; Saving the registers that are non-volatile
	PUSH	rbx
	PUSH	r13
	PUSH	r15
	PUSH	rdx				; Number of bits of the map to read

	MOV		r13, rcx		; X Location
	MOV		r15, r8			; Y Location

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Opening the specified file
; Sets the rax register to file descriptor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	MOV		rdi, rsi		; File Name
	MOV		rax, 0x2		
	XOR		rsi, rsi
	XOR		rdx, rdx
	SYSCALL
	MOV		rbx, rax		; Open file descriptor
	
	TEST	rax, rax		; Making sure file was able to be opened
	JL		_open_file_err	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Reading the file and transcribing the ASCII characters
; to the terminal through the use of ncurses
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	POP		rcx				; Number of bits in the file to read
_b3:
_read:
	PUSH	rcx				; Save current bits read from the file

	XOR		rax, rax		; Read syscall value
	MOV		rdi, rbx		; Map file
	MOV		rsi, map_char	; Location to store read char
	MOV		rdx, 0x1		; Number of char's to read, this case just 1
	SYSCALL

	TEST	rax, rax		; Check if a character was actually read
	JL		_read_file_err	

	MOV		rcx, [map_char]
_b2:
	CMP		rcx, 0xa		; Is current char '\n'
	JE		_new_line

	CMP		rcx, 0x0		; Is current char '\0'
	JE		_render_end
	
	CMP		rcx, 'S'		; Is current char 'S'
	JNE		_place_char

;;;;;;;;;;;;;;;;;;;;;;;;
; Stores cursor position of where the S, indicating start
; position is within the file. This will be returned after
; rendering is complete. 
;;;;;;;;;;;;;;;;;;;;;;;;
_set_start:
	; If the current char is an 'S', set starting cursor position
	MOV		rcx, r15		; currY
	SHL		rcx, 32			; Set upper 32 bits to be the y coord
	OR		rcx, r13		; Set the lower 32 bits to be the x coord
	MOV		[rbp-24], rcx	; Save result of position

;;;;;;;;;;;;;;;;;;;;;;;;
; Placing the character read from the _read body on the terminal
;;;;;;;;;;;;;;;;;;;;;;;;
_place_char:
	; mvwaddch(Window, y, x, char)
	MOV		rdi, [rbp-8]	; Window
	MOV		rsi, r15		; currY
	MOV		rdx, r13		; currX
	MOV		rcx, [map_char]	; char
	CALL	mvwaddch		; Adding the character to the terminal display

	ADD		r13, 1			; currX += 1
	POP		rcx				; Restore number of bytes left to print
	LOOP	_read			; Draw next character in file
	JMP		_render_end

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Moves the cursor y position down one terminal row
; and resets the x position to the specified x parameter
;;;;;;;;;;;;;;;;;;;;;;;;;;;
_new_line:
	; Resets X position to initial position and increases y position by 1
	MOV		r13, [rbp-16]	; currX = origX
	ADD		r15, 1			; currY = origY
	POP		rcx				; Restore number of bytes left to print
	ADD		rcx, 1
	LOOP	_read			; Draw next character in file

_render_end:
	; Setting the cursor position
	MOV		rax, [rbp-24]	; (y, x) position of start. Upper 32 - y, lower 32 - x
	MOV		rsi, rax		; 64 bit y pos
	MOV		rdx, rax		; 64 bit x pos

	MOV		rdi, [rbp-0x8]	; Window
	SHR		rsi, 32			; 32 bit y pos
	AND		rdx, 0xffffff	; 32 bit x pos
	CALL	wmove			; move cursor to start position

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Closing the file after all characters have been read
;;;;;;;;;;;;;;;;;;;;;;;;;;;
_close:
	; Closing the file
	MOV		rax, 0x3		; Syscall close value
	MOV		rdi, rbx		; File descriptor saved on line 16
	SYSCALL

	; Checking to make sure the file was actually close, otherwise throw an error
	TEST	rax, rax
	JL		_close_file_err	

	; Restore the stack and restore non-volatile registers used by caller
	POP		r15
	POP		r13
	POP		rbx
	XOR		rax, rax	
	LEAVE
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
	POP		r13
	POP		rbx

	MOV		rax, 0x1
	MOV		rdi, 0x1
	MOV		rsi, open_err_msg
	MOV		rdx, open_err_msg_len
	SYSCALL

	MOV		rax, 0x1
	LEAVE
	RET

_read_file_err:
	; Restore stack and non-volatile registers
	ADD		rsp, 0x16
	POP		r15
	POP		r13
	POP		rbx

	MOV		rax, 0x1
	MOV		rdi, 0x1
	MOV		rsi, read_err_msg
	MOV		rdx, read_err_msg_len
	SYSCALL

	MOV		rax, 0x1
	LEAVE
	RET

_close_file_err:
	; Restore stack and non-volatile registers
	POP		r15
	POP		r13
	POP		rbx

	MOV		rax, 0x1
	MOV		rdi, 0x1
	MOV		rsi, close_err_msg
	MOV		rdx, close_err_msg_len
	SYSCALL

	MOV		rax, 0x1
	LEAVE
	RET
