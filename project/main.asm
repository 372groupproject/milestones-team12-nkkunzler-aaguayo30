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

section .text
global _start

_start:
	CALL	initscr
	PUSH	rax			; RAX = Pointer to Window, created by initscr 
	CALL	cbreak
	CALL	noecho

	POP		rdi			; Window to load to
	MOV		rsi, map	; The map to render
	XOR		rdx, rdx	; X loc of map
	XOR		rcx, rcx	; Y loc of map
	CALL	_render_map
	PUSH	rax
	

	CALL	getch
	CALL	endwin

	; Exit
	MOV		rax, 0x3c
	POP		rdi
	SYSCALL
