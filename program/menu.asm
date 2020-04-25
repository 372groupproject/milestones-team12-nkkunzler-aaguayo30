extern box
extern mvwprintw
extern wgetch
extern delwin
extern werase
extern wrefresh

section .data
	print_fmt	db "%s", 0x0

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
_B1:
	; Printing the title of the menu
	MOV		rdi, rbx
	MOV		rsi, 0x1	; y coord
	MOV		rdx, 0x2
	MOV		rcx, print_fmt
	MOV		r8, r12
	CALL	mvwprintw

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Starting the render of the menu options
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;MOV		rdi, rbx
	;MOV		rsi, 0x5
	;CALL 	wattrset
.menu_item:
	CMP		r13, 0x0		; Make sure that number of items is not zero
	JLE		.menu_end

	MOV		r12, r13		; Y location offset from first item (AKA number of menu items)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Rendering the menu option text items
; Starts two lines done from the title
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.menu_item_loop:
	MOV		rdi, rbx		; Window to print to
	MOV		rsi, r12		; Y offset from first item in list (1*item_num)
	ADD		rsi, 2			; Number of terminal lines between the title and start of items
	MOV		rdx, 0x2
	MOV		rcx, print_fmt
	MOV		r8, [rbp+(r12+1)*8] ; Getting the item from the stack, which was pushed by the caller
	CALL	mvwprintw

	SUB		r12, 1			; Y offset moving up one terminal row
	CMP		r12, 0x0		; Making sure not at the last menu item
	JG		.menu_item_loop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Moving the cursor up and down to indicate
; the menu item selection
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	MOV		r12, 1		; Curr pos in menu item list, starts at 1
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

	CMP		rax, 0xa		; Enter will select the item and return
	JE		.menu_end
	
	JMP		.menu_movement

;;;;;;;;;;;;;;;;;;;;;;;;;;
; Moves the current cursors Y position
; up one terminal line
;;;;;;;;;;;;;;;;;;;;;;;;;;
.menu_move_up:
	CMP		r12, 0x1		; Don't move up if current position in list is first item
	JLE		.menu_movement

	MOV		rdi, rbx		; Window 
	MOV		rsi, -1			; Movement direction
	CALL	_mov_cursor_y

	SUB		r12, 1			; Curr pos in list - 1
	JMP		.menu_movement
	
;;;;;;;;;;;;;;;;;;;;;;;;;;
; Moves the current cursors Y position
; down one terminal line
;;;;;;;;;;;;;;;;;;;;;;;;;;
.menu_move_down:
	CMP		r12, r13		; Don't move down if current position in list is the last item
	JE		.menu_movement

	MOV		rdi, rbx		; Window
	MOV		rsi, 1			; Movement direction
	CALL	_mov_cursor_y

	ADD		r12, 1			; Curr pos in list + 1
	JMP		.menu_movement

.menu_end:
	MOV		rdi, rbx
	CALL	werase

	MOV		rdi, rbx
	CALL	wrefresh

	MOV		rdi, rbx
	CALL	delwin
	
	; Restore saved non-volatile registers
	MOV		rdi, r12		; Return value is list item selected
	SUB		rdi, 1			; Sub 1 since index was 1 indexed not 0, we do 0 here

	MOV		rdx, r13		; Number menu items, needed for clearing the stack
	MOV		rax, 0x8		; Bytes per stack space
	MUL		rdx				; result stored in rax register

	POP		r15
	POP		r13
	POP		r12
	POP		rbx

	ADD		rsp, rax		; Restoring stack to remove menu item params
	MOV		rax, rdi
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
		
