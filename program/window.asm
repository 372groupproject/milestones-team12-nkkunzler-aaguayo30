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
	PUSH	rdi
	CALL	getcury
	ADD		rax, rsi

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
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Parameters:	rdi - The window of the cursor to move
;				rsi - Direction and spaces to left right (- left, + right)
;				rdx - Max x coord	
;				rcx - Min x coord
;;;;;;;;;;;;;;;;;;;;;;;;;;;
_mov_cursor_x:
	PUSH	rdi
	CALL	getcurx
	ADD		rax, rsi

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
