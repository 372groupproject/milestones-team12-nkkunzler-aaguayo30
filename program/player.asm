extern malloc		; Yes, I know
extern wvwaddch


;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Parameters - 	rdi: Window to add character to
;				rsi: Player ASCII representation
;				rdx: Player Y location
;				rcx: Player X location
;
; Returns - 	Pointer to the player
;
; Player: Total of 12 bytes
; struct Player {
;		int chr;
;		int y;
;		int x;
; }
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text
_new_player:
	PUSH	rbp
	MOV		rbp, rsp
	SUB		rsp, 8			; Local variable to store player pointer

	PUSH	rdi
	PUSH	rsi
	PUSH	rdx
	PUSH	rcx

	MOV		rdi, 12
	CALL	malloc			

	CMP		rax, 0
	JE		.malloc_err

	POP		rdx			; X position
	POP		rsi			; Y position
	POP		rdi			; Root window
	POP		rcx			; Char
	MOV		[rax], rcx
	MOV		[rax+4], rsi
	MOV		[rax+8], rdx

	PUSH	rax
	CALL	mvwaddch
	POP		rax
	LEAVE
	RET


.malloc_err:
	MOV		rax, -1
	LEAVE
	RET
