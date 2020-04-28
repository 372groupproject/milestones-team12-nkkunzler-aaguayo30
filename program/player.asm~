extern malloc		; Yes, I know
extern mvwaddch
extern mvwinch
extern wrefresh
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
;		Window* window
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
	MOV		[rbp-8], rdi	; Window in which the player belongs to

	PUSH	rdi				; Window the player belongs to
	PUSH	rsi				; The player ASCII character
	PUSH	rdx				; The player Y postiion
	PUSH	rcx				; The player X position

	MOV		rax, rdx		; Temp so I can switch rsi and rdx reg
	MOV		rdi, [rbp-8]	; Window to render to
	MOV		rdx, rcx		; X location
	MOV		rcx, rsi		; Player ASCII character
	MOV		rsi, rax		; Y location
	CALL	mvwaddch

	MOV		rdi, 32			; 8 byte pointer, 3 - 4 byte ints, 4 byte buffer
	CALL	malloc			

	CMP		rax, 0			; Checking that malloc was able to malloc
	JE		.malloc_err

	POP		rcx				; The player X position
	POP		rdx				; The player Y position
	POP		rsi				; The player ASCII character
	POP		rdi				; Window the player belongs to

	MOV		[rax], rdi		; Window player belongs to
	MOV		[rax+8], rsi	; Player ASCII character
	MOV		[rax+16], rdx	; Player Y location
	MOV		[rax+24], rcx	; Player X location
	LEAVE
	RET

.malloc_err:
	MOV		rax, -1
	LEAVE

;;;;;;;;;;;;;;;;;;;;;;;;;;
; Moves the player up/down/left/right
;
; Parameters:	rdi - Player *
;				rsi - Y movement direction (- is down, + is up)
;				rdx - X movement direction (- is left, + is right)
;;;;;;;;;;;;;;;;;;;;;;;;;;
_move_player_yx:
	PUSH	rbp
	MOV		rbp, rsp
	SUB		rsp, 24
	MOV		[rbp-8], rdi	; Player *
	MOV		[rbp-16], rsi	; y movement direction
	MOV		[rbp-24], rdx	; x movement direction



	CALL	_valid_move
	CMP		rax, 1
	JE		.move
	JMP		.move_player_exit	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Moving the player by replacing the cell the player
; is currently standing on with a space and than moving
; the player ASCII character to the left/right/up/down
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.move:
    MOV     rdi, [rbp-8]    ; Player *
	; Clearing the square the player is currently on
	MOV		rsi, [rdi+16]	; Player Y location
	MOV		rdx, [rdi+24]	; Player X location
	MOV		rdi, [rdi]		; Window the player is on
	MOV		rcx, ' '		; Place an empty char at current player pos
	CALL	mvwaddch

	; Moving the player x position left 1 or right 1, depending on rsi
	MOV		rdi, [rbp-8]	; Restore player pointer back into RDI
	MOV		rsi, [rbp-16]	; Restore y movement direction
	MOV		rdx, [rbp-24]	; Restore x movement direction
	ADD		[rdi+16], rsi	; Move the player up or down (y dir)
	ADD		[rdi+24], rdx	; Move the player left or right (x dir)

	; Placing the ASCII character at new player location
    MOV     rdi, [rbp-8]
	MOV		rsi, [rdi+16]	; Player Y location
	MOV		rdx, [rdi+24]	; Player X location
	MOV		rcx, [rdi+8]	; Place player ASCII character
	MOV		rdi, [rdi]		; Window the player is on
	CALL	mvwaddch

    MOV     rdi, [rbp-8]
    MOV     rdi, [rdi]
    CALL    wrefresh

.move_player_exit:
	LEAVE
	RET


;;;;;;;;;;;;;;;;;;;;;;;;
;
; Determines if a valid move
; rdi : player pointer
; rsi : Y movement direction (- is up, + is down)
; rdx : X movement direction (- is left, + is right)
;
;;;;;;;;;;;;;;;;;;;;;;;;
_valid_move:
;	PUSH	rbp
;	MOV		rbp, rsp
;	SUB		rsp, 24
;	MOV		[rbp-8], rdi	; Player *
;	MOV		[rbp-16], rsi	; y movement direction
;	MOV		[rbp-24], rdx	; x movement direction

	;;;;;;;;;;;;;;;;;;;;;;;;
	; Checking that the player is within the bounds
	; of the window that it is located in
	;;;;;;;;;;;;;;;;;;;;;;;;
	; if (player_x < 0) GOTO .move_player_exit
	MOV		rax, [rdi+24]		; Current player x location
	ADD		rax, rdx
	CMP		ax, 0x0
	JL		.valid_move_exit_fail

	; if (player_x > window_width) GOTO .move_player_exit
    MOV     rdx, [rdi]
	MOV		rdx, [rdx+6]
	AND		rdx, 0xffff			; Window width
	CMP		ax, dx
	JG		.valid_move_exit_fail

	; if (player_y < 0) GOTO .move_player_exit
	MOV		rax, [rdi+16]		; Current player y location
	ADD		rax, rsi
	CMP		ax, 0x0				; If y loc is negative do not move the player
	JL		.valid_move_exit_fail
	
	; if (player_y > window_height) GOTO .move_player_exit
	MOV		rdx, [rdi]	
	MOV		rdx, [rdx+4]
	AND		rdx, 0xffff			; Window height
	CMP		ax, dx
	JG		.valid_move_exit_fail


	;;;;;;;;;;;;;;;;;;;;;;;;
	; Checks for player collision with any wall or enemy
	; by looking in the new spot and determining if there
	; is a space or not
	;;;;;;;;;;;;;;;;;;;;;;;;
	MOV		r10, rdi				; move player so not overwritten
 
	MOV		rsi, [rbp - 16]			; get new y value
	ADD 	rsi, [rdi + 16]     	; add current x value to new
	MOV		rdx, [rbp - 24]  		; get new x value
	ADD		rdx, [rdi + 24]     	; add current y valie to new
	MOV		rdi, rbx    			; move window pointer  	
	CALL	mvwinch             	; get character at next location
	AND		rax, 0xffff         	; extract character value

	; if (player_x + shift, player_y + shift)== space then move there
	CMP		rax, ' '            	; check if space is free to move into
	JE		.valid_move_exit_pass	; move player if valid

	JMP		.valid_move_exit_fail


.valid_move_exit_pass:
	MOV		rax, 1
	RET

.valid_move_exit_fail:
	MOV		rax, 0
	RET
