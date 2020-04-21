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
extern getch
extern endwin

section .data
	map:		db "map1.txt", 0x0
	map_width	equ 60
	map_height	equ 21

section .text
global _start

_start:
	CALL	initscr
	MOV		rbx, rax
	CALL	cbreak
	CALL	noecho

	; Getting main window maximum size
	; Could just use getmaxyx() but that is not fun
	
	; Get Y position for the map
	MOV		r9, map_height
	SHR		r9, 1			; half map height

	MOV		r8, [rbx+4]
	AND		r8, 0xffff
	SHR		r8, 1		
	SUB		r8, r9

	; Get X position for the map
	MOV		r9, map_width
	SHR		r9, 1			; half map height

	MOV		rcx, [rbx+6]
	AND		rcx, 0xffff
	SHR		rcx, 1			; X
	SUB		rcx, r9

	; Get the number of bytes to read based off of width and height
	MOV		rax, map_width
	MOV		rdx, map_height
	MUL		rdx
	MOV		rdx, rax

	; Rendering the map to terminal screen
	MOV		rdi, rbx
	MOV		rsi, map	; The map to load
	CALL	_render_map	; Draws the map to the terminal and set cursor to start

	TEST	rax, rax
	JL		_exit_error

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
