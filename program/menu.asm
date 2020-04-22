extern wmove
extern wattron
extern wattroff
extern box
extern wgetch
extern newwin
extern delwin
extern mvwprintw
extern wprintw

section .text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Parameters:	rdi - Root Window
;				rsi - Menu Title
;				rcx - Num of menu options
;				All menu option text is stored on stack
;	
; Returns: Num of Items in Menu
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_show_menu:
	PUSH	rbp
	MOV		rbp, rsp

	; Save non-volatile registers
	PUSH	rbx
	PUSH	r12
	PUSH	r13
	PUSH	r15

	MOV		rbx, rdi	; Root window
	MOV		r12, rsi	; Menu Title
	MOV		r13, rcx	; Num of menu options
	XOR		r15, r15	; Random use 

	; Creating new screen in center of caller window
	CALL	_get_win_centerY
	MOV		r15, rax	; root window height

	MOV		rdi, rbx
	CALL	_get_win_centerX
	MOV		rcx, rax	; root window width

	; Getting y location
	MOV		rdi, r13	; window height = Num of menu options
	ADD		rdi, 5		; Extra height - 2 for title, 3 space around menu items

	MOV		rax, rdi	
	SHR		rax, 1		; half windows height
	MOV		rdx, r15
	SUB		rdx, rax	; y = y - (height of window / 2)

	; Getting x location
	MOV		rsi, 60		; root window width
	MOV		r15, rsi
	SHR		r15, 1
	SUB		rcx, r15	; x = x - (root window with / 2)

	CALL	newwin		; drawing the menu
	MOV		rbx, rax	; Root window is now that of the newly created window

	; Putting a border around the menu
	MOV		rdi, rbx
	MOV		rsi, '|'
	MOV		rdx, '*'
	CALL	box

	; Getting title length
	MOV		rdx, r15
	MOV		rdi, r12
	CALL	.str_len
	SHR		rax, 1		; Half the string length
	SUB		rdx, rax
	
	; Printing the title of the menu
	MOV		rdi, rbx
	MOV		rsi, 0x1	; y coord
	MOV		rcx, r12
	CALL	mvwprintw

.menu_item:
	CMP		r13, 0x0
	JLE		.menu_end

	MOV		r12, r13

	PUSH	r14
	XOR		r14, r14		; selection


.menu_item_loop:
	MOV		rdi, rbx
	MOV		rdx, r15
	MOV		rsi, r12
	ADD		rsi, 2
	MOV		rcx, [rbp+(r12+1)*8]
	CALL	mvwprintw

	SUB		r12, 1
	CMP		r12, 0x0
	JG		.menu_item_loop

	MOV		r8, 0

.menu_movement:

	MOV		rdi, rbx	
	CALL	wgetch

	; Move down one item
	CMP		rax, 'w'
	JE		.menu_move_up
	CMP		rax, 'k'
	JE		.menu_move_up

	; Move up one item
	CMP		rax, 's'
	JE		.menu_move_down
	CMP		rax, 'j'
	JE		.menu_move_down

	CMP		rax, 0xa
	JE		.menu_end
	JMP		.menu_movement

.menu_move_up:
	MOV		rdi, rbx
	MOV		rsi, -1
	MOV		rdx, 3			; Min y
	MOV		rcx, rdx
	ADD		rcx, r13		; Max y = min y + num of menu items
	SUB		rcx, 1
	CALL	_mov_cursor_y
	MOV		r14, rax		; Sub num of moves occured from to selected
	JMP		.menu_movement
	
.menu_move_down:
	MOV		rdi, rbx
	MOV		rsi, 1			
	MOV		rdx, 3			; min y
	MOV		rcx, rdx
	ADD		rcx, r13		; Max y = min y + num of menu items
	CALL	_mov_cursor_y
	MOV		r14, rax		; Sub num of moves occured from to selected
	JMP		.menu_movement

.menu_end:
	MOV		rdi, rbx
	CALL	delwin
	
	; Restore saved non-volatile registers
	MOV		rax, r14
	POP		r14
	POP		r15
	POP		r13
	POP		r12
	POP		rbx
	LEAVE
	RET		

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Parameters:	rdi - The address of the string
;
; Returns the length of the given string
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.str_len:
	XOR		rax, rax
	
.str_len_l:
	MOV		rcx, [rdi+rax]

	CMP		cl, 0x0
	JE		.str_len_end

	ADD		rax, 1
	JMP		.str_len_l

.str_len_end:
	RET
		
