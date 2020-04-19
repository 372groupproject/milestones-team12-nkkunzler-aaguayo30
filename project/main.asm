%include "./map_render.asm"

extern initscr
extern refresh
extern cbreak
extern noecho
extern mvaddch
extern getch
extern endwin

section .data
	map:		db "map1.txt", 0x0
	map_size	equ 1282	; Size = (# ROWS + 1) * (# Cols)

section .text
global _start

_start:
	CALL	initscr
	PUSH	rax			; RAX = Pointer to Window, created by initscr 
	CALL	cbreak
	CALL	noecho

	POP		rdi			; Window to load to
	MOV		rsi, map	; The map to load
	MOV		rdx, map_size
	MOV		rcx, 15 	; X loc of map
	MOV		r8, 10		; Y loc of map
	CALL	_render_map	; Draws the map to the terminal and set cursor to start
	PUSH	rax

	CALL	getch
	CALL	endwin

	; Exit
	MOV		rax, 0x3c
	POP		rdi
	SYSCALL
