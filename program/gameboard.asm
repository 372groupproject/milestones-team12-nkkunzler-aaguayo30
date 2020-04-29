extern malloc
extern mvwaddch
extern wmove
extern getch
extern wattron
extern wattroff
extern init_pair
extern COLOR_PAIR

%include "./player.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;
; Change player_chr to what ever ASCII character
; you desire. Currently 'P' for player.
;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text
	player_chr	equ	'P'
	enemy_chr	equ 'E'
	token_chr	equ 'o'

section .bss
	map_char:	resb 1

section .text
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Parameters:	rdi - Window*
;				rsi - Map File
;				rdx - Map Size
;
; Returns - Pointer to GameBoard struct (./game_ref/GameBoard for more info)
;
; struct GameBoard {
;		WINDOW* window;
;		Player* player;
;		Enemy* enemy;
;		int num_tokens;
;}
;
; Locals: [rbp-8] = GameBoard pointer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_gen_gameboard:
	PUSH	rbp
	MOV		rbp, rsp

	SUB		rsp, 32
	MOV		[rbp-8], rdi		; Window to render to
	MOV		[rbp-16], rsi		; Map file name
	MOV		QWORD [rbp-24], rdx	; Map size
	MOV		QWORD [rbp-32], 0x0	; GameBoard pointer

	; Malloc room for GameBoard 
	MOV		rdi, 32				; Save 24 bytes, 3 - 8 byte pointers, 1 - 8 byte counter
	CALL	malloc				; Need to add error checking
	MOV		[rbp-32], rax		; Local to store GameBoard pointer 

	MOV		rdi, [rbp-8]		; Window in which the gameboard is drawn
	MOV		[rax], rdi			; Setting GameBoard Window* field
	
	MOV		rdi, [rbp-32]
	MOV		QWORD [rdi+24], 0x0		; Number of tokens on the board

	; Storing parameters on the stack
	; Saving the registers that are non-volatile
	PUSH	rbx
	PUSH	r13
	PUSH	r15

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Opening the specified file
; Sets the rax register to the opened file descriptor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	MOV		rdi, [rbp-16]	; Map File Name
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
	XOR 	r13, r13		; Start at row 0 of the game window
    XOR     r15, r15

	;;;;;;;;;;;;;;;;
	; Setting up colors
	;;;;;;;;;;;;;;;;
	; Yellow text - For tokens
	MOV		rdi, 1
	MOV		rsi, 3
	MOV		rdx, 0
	CALL	init_pair

	MOV		rdi, 2
	MOV		rsi, 1
	MOV		rdx, 0
	CALL	init_pair
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Starting to read the map and render it
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_read:
	XOR		rax, rax		; Read syscall value
	MOV		rdi, rbx		; Map file
	MOV		rsi, map_char	; Location to store read char
	MOV		rdx, 0x1		; Number of char's to read, this case just 1
	SYSCALL

	TEST	rax, rax		; Check if a character was actually read
	JL		_read_file_err	

	MOV		rcx, [map_char]
	CMP		rcx, 0xa		; Is current char '\n'
	JE		_new_line

	CMP		rcx, 0x0		; Is current char '\0'
	JE		_render_end
	
	CMP		cx, player_chr	; Is current char a player?
	JE		_add_player

	CMP		cx, enemy_chr	; Is current char an enemy?
	JE		_add_enemy

	CMP		cx, token_chr	; Is current char a token
	JE		_add_token

	JMP		_place_char


_add_player:
	MOV		rdi, [rbp-8]	; Window to render player to
	MOV		rsi, player_chr	; Player character representation
	MOV		rdx, r15		; Player Y coord
	MOV		rcx, r13		; Player x coord
	CALL	_new_player		; Returns pointer to player struct
	MOV		rcx, [rbp-32]	; The gameboard struct
	MOV		[rcx+8], rax	; Setting player pointer

	JMP		_next_char_read

_add_enemy:
	MOV		rdi, [rbp-8]	; Window to render player to
	MOV		rsi, enemy_chr	; Player character representation
	MOV		rdx, r15		; Player Y coord
	MOV		rcx, r13		; Player x coord
	CALL	_new_player		; Returns pointer to player struct
	MOV		rcx, [rbp-32]	; The gameboard struct
	MOV		[rcx+16], rax	; Setting enemy player pointer
	JMP		_next_char_read

_add_token:
	MOV		rcx, [rbp-32]		; The gameboard struct
	ADD		QWORD [rcx+24], 1	; Adding 1 to current number of tokens

	MOV		rdi, 1
	CALL	COLOR_PAIR
	MOV		rdi, [rbp-8]		; Setting token to a yellow color
	MOV		rsi, rax
	CALL	wattron

_place_char:
	MOV		rdi, [rbp-8]		; Window
	MOV		rsi, r15 			; currY
	MOV		rdx, r13			; currX
	MOV		rcx, [map_char]		; char
	CALL	mvwaddch			; Adding the character to the terminal display

	MOV		rdi, [rbp-8]
	CALL	wattroff

_next_char_read:
	ADD		r13, 1				; currX += 1
	SUB		WORD [rbp-24], 1	; Bytes left to read
	CMP		QWORD [rbp-24], 0x0
	JG		_read
	JMP		_render_end

_new_line:
	; Resets X position to initial position and increases y position by 1
	MOV		r13, 0				; currX = origX
	ADD		r15, 1				; currY = origY
	CMP		QWORD [rbp-24], 0x0
	JG		_read

_render_end:
;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Closing the file after all characters have been read
;;;;;;;;;;;;;;;;;;;;;;;;;;;
_close:
    MOV     rdi, [rbp-8]
    CALL    wrefresh
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
	POP		rbx				; Map file descriptor
	MOV		rax, [rbp-32]	; Returning pointer to the game board
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
