;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The following will read in a map file, render it
; to the screen and exit when the user adds an input.
;
; Remaining Tasks (Current Thoughts):
;	- Center the map on the window
; 	- Add player movement
;	- Add enemy movement
;	- Add win/lose screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%include "./map_render.asm"

extern initscr
extern refresh
extern cbreak
extern noecho
extern mvaddch
extern getch
extern endwin
extern box

section .data
	map:		db "map1.txt", 0x0
	map_size	equ 1282	; Size = (# ROWS + 1) * (# Cols)

section .text
global _start

_start:
	CALL	initscr
	MOV		rbx, rax
	CALL	cbreak
	CALL	noecho

	MOV		rdi, rbx
	MOV		rsi, map	; The map to load
	MOV		rdx, map_size
	MOV		rcx, 15 	; X loc of map
	MOV		r8, 10		; Y loc of map
	CALL	_render_map	; Draws the map to the terminal and set cursor to start

	TEST	rax, rax
	JL		_exit_error

	; Draws a border around the window
	;MOV		rdi, rbx
	;MOV		rsi, '|'
	;MOV		rdx, '`'
	;CALL	box

	CALL	getch
	CALL	endwin

	; Exit
	MOV		rax, 0x3c
	XOR		rdi, rdi
	SYSCALL

_exit_error:
	MOV		rax, 0x3c
	MOV		rdi, 1
	SYSCALL
