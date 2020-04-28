extern mvwaddch
extern malloc
extern getch
extern newwin
extern box
extern wrefresh
extern mvwprintw
extern mvprintw

section .data
    int_fmt     db "Score: %d", 0x0

section .text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Parameters: 	rdi - X Loc
; 				rsi - Y Loc
;				rdx - Length
;
; struct Scoreboard {
;		WINDOW* window;
;}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_new_scoreboard:
	PUSH	rbp
	MOV		rbp, rsp
	SUB		rsp, 16


	MOV		rcx, rdi
	MOV		rdi, 3
	MOV		rax, rsi
	MOV		rsi, rdx
	MOV		rdx, rax
	CALL	newwin
    MOV     [rbp-8], rax

    MOV     rdi, rax
    CALL    wrefresh

    MOV     rdi, [rbp-8]
	MOV		rsi, 0
	MOV		rdx, 0
	CALL	box

	MOV		rdi, 16
	CALL	malloc
    MOV     [rbp-16], rax
    MOV     rdx, [rbp-8]
    MOV     [rax], rdx
    MOV     QWORD [rax+8], 1

    MOV     rax, [rbp-16]
	LEAVE
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Parameters - rdi - Scoreboard*
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_increament_score:
    ADD     QWORD [rdi+8], 1
    PUSH    QWORD [rdi+8]
    POP     r8
    MOV     rdi, [rdi]
    MOV     rsi, 0x1
    MOV     rdx, 0x1
    MOV     rcx, int_fmt
    CALL    mvwprintw

	RET
	
