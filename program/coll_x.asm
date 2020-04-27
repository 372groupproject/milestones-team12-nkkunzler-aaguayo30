.mv_check_x:
	MOV		rax, [rbp-16]	; GameBoard *
	MOV		rdi, [rax]		; Window *
	;MOV		rsi, [rax+8]	; Player * <- Think you can remove everythin above as that is just code to get the player *
	MOV		rdx, [rsi+12]	; y pos
	MOV		rsi, [rdi+16]	; x pos
	ADD		rsi, 1			; x pos + 1
	CALL	mvwinch
	AND		rax, 255

	CMP		rax, ' '
	JMP		.move_player
