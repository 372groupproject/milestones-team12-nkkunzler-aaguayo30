extern getcury
extern getcurx
extern wmove

section .text

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the width of the specified window
;;;;;;;;;;;;;;;;;;;;;;;;;;;
_get_win_width:
	MOV		rax, [rdi + 6]
	AND		rax, 0xffff
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the height of the specified window
;;;;;;;;;;;;;;;;;;;;;;;;;;;
_get_win_height:
	MOV		rax, [rdi + 4]
	AND		rax, 0xffff
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the x coordinate of the specified window
;;;;;;;;;;;;;;;;;;;;;;;;;;;
_get_win_x:
	MOV		rax, [rdi + 8]
	AND		rax, 0xffff
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the y coordinate of the specified window
;;;;;;;;;;;;;;;;;;;;;;;;;;;
_get_win_y:
	MOV		rax, [rdi + 10]
	AND		rax, 0xffff
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the center x coordinate of the specified window
;;;;;;;;;;;;;;;;;;;;;;;;;;;
_get_win_centerX:
	MOV		rax, [rdi + 6]
	AND		rax, 0xffff
	SHR		rax, 1
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the center y coordinate of the specified window
;;;;;;;;;;;;;;;;;;;;;;;;;;;
_get_win_centerY:
	MOV		rax, [rdi + 4]
	AND		rax, 0xffff
	SHR		rax, 1
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Parameters:	rdi - The window of the cursor to move
;				rsi - Direction and space to move (- down, + up)
;				rdx - Min y coord
;				rcx - Max y coord	
;
; Returns: Absolute number of spaces moved
;;;;;;;;;;;;;;;;;;;;;;;;;;;
_mov_cursor_y:
	PUSH	r12			; Used to determine how many spots from min index

	PUSH	rdi
	PUSH	rdx
	PUSH	rcx
	PUSH	rsi
	CALL	getcury
	POP		rsi
	POP		rcx
	POP		rdx
	ADD		rax, rsi

	; All of this is super buggy and weird, but should still move cursor as expected
	CMP		rax, rdx		; y < min y 
	JL		.mov_loop_max

	CMP		rax, rcx		; y > max y
	JGE		.mov_loop_min
	
	JMP		.mov_loop_mov

.mov_loop_min:
	MOV		rax, rdx
	JMP		.mov_loop_mov

.mov_loop_max:
	MOV		rax, rcx

.mov_loop_mov:
	; Ignore this for now, trying something out
	MOV		r12, rax
	SUB		r12, rcx
	POP		rdi
	PUSH	rax
	
	; Get curr x position
	PUSH	rdi
	CALL	getcurx
	MOV		rdx, rax
	POP		rdi
	POP		rsi
	
	; Move position to new location
	CALL	wmove

	MOV		rax, r12
	POP		r12
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Parameters:	rdi - The window of the cursor to move
;				rsi - Direction and spaces to left right (- left, + right)
;				rdx - Max x coord	
;				rcx - Min x coord
;;;;;;;;;;;;;;;;;;;;;;;;;;;
_mov_cursor_x:
	PUSH	rdi
	PUSH	rdx
	PUSH	rcx
	PUSH	rsi
	CALL	getcurx
	POP		rsi
	POP		rcx
	POP		rdx
	ADD		rax, rsi

	; All of this is super buggy and weird, but should still move cursor as expected
	CMP		rax, rdx		; x < min x
	JLE		.mov_loop_max

	CMP		rax, rcx		; x > max x
	JGE		.mov_loop_max

	JMP		.mov_loop_mov

.mov_loop_min:
	ADD		rax, 1
	JMP		.mov_loop_mov

.mov_loop_max:
	SUB		rax, 1
	MOV		rax, rdx

.mov_loop_mov:
	POP		rdi
	PUSH	rax
	
	; Get current cursor y position
	PUSH	rdi
	CALL	getcury
	MOV		rsi, rax
	POP		rdi
	POP		rdx
	
	; Update cursor to new position
	CALL	wmove
	RET
