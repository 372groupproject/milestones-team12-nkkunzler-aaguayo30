extern malloc
extern getch
extern newwin
extern box
extern wrefresh
extern mvwprintw

section .data
	int_fmt		db "Score: %d", 0x0

section .text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Parameters: 	rdi - X Loc
; 				rsi - Y Loc
;				rdx - Length
;
; struct Scoreboard {
;		WINDOW* window;
; 		int score;
;}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_new_scoreboard:
	PUSH	rbp
	MOV		rbp, rsp

	SUB		rsp, 8

	MOV		rcx, rdi
	MOV		rdi, 3
	MOV		rax, rsi
	MOV		rsi, rdx
	MOV		rdx, rax
	CALL	newwin
	MOV		[rbp-8], rax

	MOV		rdi, [rbp-8]
	MOV		rsi, 0
	MOV		rdx, 0
	CALL	box

	MOV		rdi, 16
	CALL	malloc
	MOV		rcx, [rbp-8]
	MOV		[rax], rcx
	MOV		QWORD[rax+8], -1

	MOV		rdi, rax
	CALL	_increase_score

	MOV		rax, [rbp-8]
	LEAVE
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Parameters - rdi - Scoreboard*
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_increase_score:
	PUSH	rdi
	MOV		rax, [rdi+8]
	ADD		rax, 1
	MOV		[rdi+8], rax

	MOV		rdi, [rdi]		; Scoreboard
	MOV		rsi, 0x1		; Y 
	MOV		rdx, 0x2		; X
	MOV		rcx, int_fmt
	MOV		r8, rax
	CALL	mvwprintw

	POP		rdi
	MOV		rdi, [rdi]
	CALL	wrefresh
	RET
	
