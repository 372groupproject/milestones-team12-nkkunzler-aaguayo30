extern initscr
extern cbreak
extern noecho
extern getch
extern endwin
extern mvaddch

section .data
	map:		db "map1.txt", 0x0
	map_len:	equ $ - map

	buffer_len:	equ 1282	; (# rows + 1) * (# columns): Map = 60 col x 21 rows

section .bss
	buffer: resb 1283		; (# rows + 1) * (# columns) + 1: Map = 60 col x 21 row

section .text
global _start

_start:
	; Open the map file
	MOV		rdi, map		; File to open
	CALL	_open_file
	push	rax				; Save map descriptor 

	; Read the file that was opened
	MOV		rdi, rax		; File descriptor to read
	MOV		rsi, buffer		; Buffer to store file text
	MOV		rdx, buffer_len	; Length of buffer
	CALL	_read_file

	; Close the map file
	pop		rdi				; Load map descriptor
	CALL	_close_file

	;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Ncurses stuff
	;;;;;;;;;;;;;;;;;;;;;;;;;;
	CALL	initscr
	CALL	cbreak
	CALL	noecho

	XOR		rdi, rdi		; col = 0
	XOR		rsi, rsi		; row = 0
	MOV		rdx, buffer		; map
	CALL	_render_map


	; Can be relaced by native x86 code
	CALL	getch
	CALL	endwin

	;;;;;;;;;;;;;;;;;;;;;;;;;;
	; DONE WITH Ncurses stuff reg output
	;;;;;;;;;;;;;;;;;;;;;;;;;;

	; Exit error code 0
	MOV		rax, 0x3c
	XOR		rdi, rdi		; XOR improves speed :)
	SYSCALL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Following procedures are used to open, read, and close a file.
; All error checking is done within the corresponding procedures
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_render_map:
	push	rbx				; Need to save rbx reg, convention
	MOV		rbx, rdx		; map 

_render_map_loop:
	XOR		rax, rax		; Zeroing so that a char value can be stored
	MOV		al, [rbx]		; Store result in lower 8 bits or rax register

	CMP		rax, 0xa		; New line, need to change row and col accordingly
	JE		_render_new_line

	CMP		rax, 0x0		; Reached end of file / map buffer
	JNE		_render_map_char
	pop		rbx
	RET

_render_map_char:

	PUSH	rsi				; Save Col as mvaddch may trash the value
	PUSH	rdi				; Save Row as mvaddch may trash the value
	MOV		rdx, rax		; mvaddch char = curr_char
	CALL	mvaddch			

	POP		rdi				; Restore Row value
	POP		rsi				; Restore Col value

	ADD		rbx, 1			; Get next char
	ADD		rsi, 1			; Row += 1
	JMP		_render_map_loop

_render_new_line:
	MOV		rsi, 0			; Row = 0
	ADD		rdi, 1			; Col += 1
	ADD		rbx, 1			; Next char in buffer
	JMP		_render_map_loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Following procedures are used to open, read, and close a file.
; All error checking is done within the corresponding procedures
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .data
	open_err_msg: 		db "FILE ERROR: Could Not Open File", 0xa, 0x0
	open_err_msg_len:	equ $ - open_err_msg

	read_err_msg: 		db "FILE ERROR: Could Not Read File", 0xa, 0x0
	read_err_msg_len:	equ $ - read_err_msg

	close_err_msg: 		db "FILE ERROR: Could Not Close File", 0xa, 0x0
	close_err_msg_len:	equ $ - close_err_msg

section .text
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Parameter: rdi - The name of the file to open
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_open_file:
	; Opening a file 
	MOV		rax, 0x2	; Open file
	MOV		rsi, 0x0	; Read only
	MOV		rdx, 0x0	; Mode
	SYSCALL

	; Either return to callee or exit if error
	TEST	rax, rax
	JL		_open_file_err
	RET

_open_file_err:
	; Print err main message
	MOV		rax, 0x1
	MOV		rdi, 0x1
	MOV		rsi, open_err_msg
	MOV		rdx, open_err_msg_len
	SYSCALL

	; Exit error code 2, No such file
	MOV		rax, 0x3c
	MOV		rdi, 0x2
	SYSCALL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Parameter:	rdi - The file descriptor
;				rsi - Buffer to store text
;				rdx - Buffer length
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_read_file:
	; Read the file
	MOV		rax, 0x0
	SYSCALL

	TEST	rax, rax
	JL		_read_file_err	; Jump if file could not open, rax = -1
	RET

_read_file_err:
	; Print err main message
	MOV		rax, 0x1
	MOV		rdi, 0x1
	MOV		rsi, read_err_msg
	MOV		rdx, read_err_msg_len
	SYSCALL

	; Exit error code 5, IO error
	MOV		rax, 0x3c
	MOV		rdi, 0x5
	SYSCALL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Parameter: rdi - The file descriptor
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_close_file:
	; Closing a file
	MOV		rax, 0x3	; Close file
	SYSCALL

	TEST	rax, rax
	JL		_close_file_err	; Jump if file could not close, rax = -1
	RET

_close_file_err:
	; Print err main message
	MOV		rax, 0x1
	MOV		rdi, 0x1
	MOV		rsi, close_err_msg
	MOV		rdx, close_err_msg_len
	SYSCALL

	; Exit error code -1, close error 
	MOV		rax, 0x3c
	MOV		rdi, -1
	SYSCALL
