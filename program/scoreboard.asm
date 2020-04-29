extern mvwaddch
extern malloc
extern getch
extern newwin
extern box
extern wrefresh
extern mvwprintw
extern mvprintw
extern wprintw
extern wclear

section .data
    int_fmt     db "Score: %d", 0x0

section .text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Parameters: 	rdi - X Loc
; 				rsi - Y Loc
;				rdx - Length
;				rcx - Starting score
;
; struct Scoreboard {
;		WINDOW* window;
;}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_new_scoreboard:
	PUSH	rbp
	MOV		rbp, rsp
	SUB		rsp, 24
	MOV		[rbp-24], rcx	; Initial player score

	MOV		rcx, rdi
	MOV		rdi, 3
	MOV		rax, rsi
	MOV		rsi, rdx
	MOV		rdx, rax
	CALL	newwin
    MOV     [rbp-8], rax

    MOV     rdi, [rbp-8]
	MOV		rsi, 0
	MOV		rdx, 0
	CALL	box

	MOV		rdi, 16
	CALL	malloc
    MOV     [rbp-16], rax
    MOV     rdx, [rbp-8]
    MOV     [rax], rdx
	MOV		r8, [rbp-24]
    MOV     QWORD [rax+8], r8

	MOV		rax, 0x0
	MOV		rdi, [rbp-16]
	MOV		rdi, [rdi]
	MOV		rsi, 1
	MOV		rdx, 1
	MOV		rcx, int_fmt
	CALL	mvwprintw

	MOV		rdi, [rbp-8]
	CALL	wrefresh

    MOV     rax, [rbp-16]
	LEAVE
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Parameters:	rdi - Scoreboard*
;				rsi - Increment value
;
; WARNING - THIS BREAKS SUPER EASY
; AND IS SUPER INEFFICIENT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_increment_score:
	PUSH	rbp
	MOV		rbp, rsp
	SUB		rsp, 16
	MOV		rax, [rdi]
	MOV		[rbp-8], rax
	ADD		[rdi+8], rsi
	MOV		rax, [rdi+8]
	MOV		[rbp-16], rax

	MOV		rdi, [rbp-8]
	CALL	wclear

    MOV     rdi, [rbp-8]
	MOV		rsi, 0
	MOV		rdx, 0
	CALL	box

	MOV		rax, 0x0
	MOV		rdi, [rbp-8]
	MOV		rsi, 1
	MOV		rdx, 1
	MOV		rcx, int_fmt
	MOV		r8, [rbp-16]
	CALL	mvwprintw

	MOV		rdi, [rbp-8]
	CALL	wrefresh

	LEAVE
	RET
	
