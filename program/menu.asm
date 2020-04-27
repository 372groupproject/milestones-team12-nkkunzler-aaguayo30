extern stdscr
extern box
extern mvwprintw
extern wgetch
extern delwin
extern werase
extern wrefresh
extern wattron
extern wattroff
extern touchwin

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

	SUB		rsp, 24			; Saving enough room for 2 local variable
	MOV		[rbp-8], rdi	; The root window in which to add the menu to
	MOV		[rbp-16], rcx	; The number of selectable items in the menu
	MOV		[rbp-24], rdi	; The actual menu window

	; Save non-volatile registers
	PUSH	r12
	PUSH	r15
	MOV		r12, rsi		; Menu Title
	XOR		r15, r15		; Random use 

	; Creating new screen in center of caller window

	; THIS IS BROKEN

	MOV		rdi, [rbp-8]
	CALL	_get_win_centerY
	MOV		r15, rax		; root window height

	MOV		rdi, [rbp-8]
	CALL	_get_win_centerX
	MOV		rcx, rax		; root window width

	; Getting menu window y location
	MOV		rdi, [rbp-16]	; window height = Num of menu options
	ADD		rdi, 5			; Extra height - 2 for title, 3 space around menu items

	MOV		rax, rdi		; Need the rdi for window height
	SHR		rax, 1			; half menu window height
	MOV		rdx, r15
	SUB		rdx, rax		; y = y - (height of window / 2)

	; Getting menu window x location
	MOV		rsi, 60			; root window width
	CALL	newwin			; drawing the menu
	MOV		[rbp-24], rax 

	; Putting a pretty border around the menu
	MOV		rdi, [rbp-24]
	MOV		rsi, '|'
	MOV		rdx, '*'
	CALL	box

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Rendering the title to the menu window
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	MOV		rdi, [rbp-24]
	MOV		rsi, 0x1		; y coord
	MOV		rdx, 0x2		; x coord
	MOV		rcx, print_fmt
	MOV		r8, r12			; The title
	CALL	mvwprintw

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Starting the render of the menu options
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	CMP		QWORD [rbp-16], 0x0	; If no menu items just start menu end procedure
	JLE		.menu_end

	MOV		r12, 1				; Current menu item selected, 1 indexed

.render_menu_items:
	MOV		r15, [rbp-16]		; RCX = number of menu items

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Rendering the menu option text items
; Starts two lines done from the title
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.menu_item_loop:
	CMP		r15, r12		; Current menu item = current selection
	JNE		.highlight_off

	; Turn on the menu highlight if the player is not hovering over it
	MOV		rdi, [rbp-24]
	MOV		rsi, 262144			; 262144 is the invert color code for wattron
	CALL	wattron
	JMP		.render_item

.highlight_off:
	; Turn off the menu highlight if the player is not hovering over it
	MOV		rdi, [rbp-24] 
	MOV		rsi, 262144			; 262144 is the invert color code for wattron
	CALL	wattroff

.render_item:
	MOV		rdi, [rbp-24]		; Window to print to
	MOV		rsi, r15			; y offset for first item in parameter list 
	ADD		rsi, 2				; Number of terminal lines between the title and start of items
	MOV		rdx, 2				; x position (second column in the window) (TODO: TRY TO FIGURE OUT CENTERING)
	MOV		r8, [rbp+(r15+1)*8] ; Getting menu item from the stack
	MOV		rcx, print_fmt		; "%s"
	CALL	mvwprintw

	SUB		r15, 1				; Decrement number of menu items
	CMP		r15, 0x0			; Making sure not at the first menu item (working bottom up)
	JG		.menu_item_loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Moving the cursor up and down to indicate the menu
; item selection. The selected item will highlighted
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.select_movement:
	MOV		rdi, [rbp-24]
	CALL	wgetch

	; Move down one item
	CMP		rax, 'w'
	JE		.select_move_up
	CMP		rax, 'k'
	JE		.select_move_up

	; Move up one item
	CMP		rax, 's'
	JE		.select_move_down
	CMP		rax, 'j'
	JE		.select_move_down

	CMP		rax, 0xa			; Enter will select the item and return
	JE		.menu_end
	
	JMP		.select_movement

;;;;;;;;;;;;;;;;;;;;;;;;;;
; Moves the current cursors Y position
; up one terminal line
;;;;;;;;;;;;;;;;;;;;;;;;;;
.select_move_up:
	CMP		r12, 0x1			; Don't move up if current position in list is first item
	JLE		.render_menu_items

	MOV		rdi, [rbp-24]		; Window from which cursor to move
	MOV		rsi, -1				; Movement direction
	CALL	_mov_cursor_y

	SUB		r12, 1				; Curr menu item selection index
	JMP		.render_menu_items
	
;;;;;;;;;;;;;;;;;;;;;;;;;;
; Moves the current cursors Y position
; down one terminal line
;;;;;;;;;;;;;;;;;;;;;;;;;;
.select_move_down:
	CMP		r12, [rbp-16]		; Don't move down if current position in list is the last item
	JE		.render_menu_items

	MOV		rdi, [rbp-24]		; Window from which cursor to move
	MOV		rsi, 1				; Movement direction
	CALL	_mov_cursor_y

	ADD		r12, 1				; Curr menu item selection index
	JMP		.render_menu_items

.menu_end:
	MOV		rdi, [rbp-24]		; Delete the window memory
	CALL	delwin

	MOV		rdi, [rbp-8]		; Update the window to display the erase
	CALL	touchwin

	MOV		rdi, [rbp-8]		; Update the window to display the erase
	CALL	wrefresh
	
	; Restore saved non-volatile registers
	MOV		rdi, r12			; Return value is list item selected
	SUB		rdi, 1				; Sub 1 since index was 1 indexed not 0, we do 0 here

	MOV		rdx, [rbp-16]		; Number menu items, needed for clearing the stack
	MOV		rax, 0x8			; Bytes per stack space
	MUL		rdx					; result stored in rax register

	; Restoring non-volatile registers
	POP		r15
	POP		r12

	; Restoring stack to remove menu items that are on the stack
	ADD		rsp, rax				
	MOV		rax, rdi
	LEAVE
	RET		

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Parameters:	rdi - The address of the string
;
; Returns the length of the given string
;
; TODO: BREAKS WHEN USING WITH mvwprintw, don't know why
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
		
