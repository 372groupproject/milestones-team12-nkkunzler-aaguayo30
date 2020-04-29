;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The following will read in a map file, render it
; to the screen and exit when the user adds an input.
;
; Remaining Tasks (Current Thoughts):
;	- Center the map on the window
; 	- Add player movement
;	- Add enemy movement
;	- Add win/lose screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%include "./scoreboard.asm"
%include "./gameboard.asm"
%include "./window.asm"
%include "./menu.asm"

extern initscr
extern refresh
extern cbreak
extern noecho
extern getch
extern free
extern endwin
extern newwin
extern mvaddch
extern curs_set
extern wtimeout
extern wrefresh
extern printw

section .data
	title			db "GAME TITLE", 0x0
	play_str		db "PLAY", 0x0

	win_str			db "YOU WON!", 0x0
	lose_str		db "YOU LOST", 0x0
	play_again_str	db "PLAY AGAIN", 0x0

	pause_str		db "PAUSE", 0x0
	resume_str		db "RESUME", 0x0

	info_str		db "INFO", 0x0
	goal_info_str	db "Avoid the 'E' enemy.", 0x0
	mv_key_info_str	db "Move using standard AWSD keys or HJKL.", 0x0
	ex_key_info_str db "Pause by pressing the 'P' key.", 0x0
	hint_str		db "Hint: Hold direction keys to move faster.", 0x0
	credit_str		db "Created by: Angel Aguayo and Nicholas Kunzler", 0x0

	exit_str		db "EXIT", 0x0

	map_file:		db "map0.txt", 0x0
	map_width		equ 75
	map_height		equ 25

	dir				dq	16		; bitmap showing valid directions, 0=up, 2=right, 4=down, 8=left, 16=not set

section .text
global _start

_start:
	PUSH	rbp
	MOV		rbp, rsp

	SUB		rsp, 24; Allow space for 3 local variable
	; rsp-8 = Root Window and Game window
	; rsp-16 = GameBoard*
	; rsp-24 = Scoreboard*

	; Standard Ncurses terminal preping
	CALL	initscr
	MOV		[rbp-8], rax
	CALL	cbreak
	CALL	noecho

	; Hiding the cursor
	XOR		rdi, rdi
	CALL	curs_set

_load_main_menu:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Load the main menu system
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	; WARNING
	; This procedure does not follow standard calling convention
	; All the menu items are stored on the stack and not within the
	; standared registers
	; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	MOV		rdi, [rbp-8]    ; Window to which to render menu
	MOV		rsi, title		; Title for the menu, currently not working
	MOV		rcx, 3			; Number of menu items
	PUSH	exit_str		; Middle menu item
	PUSH	info_str		; Last menu item
	PUSH	play_str		; First menu item
	CALL	_show_menu

	CMP		rax, 0x0		; First list item selected, PLAY
	JE		_load_map		

	CMP		rax, 0x1		; Second list item selected, INFO
	JE		_load_info_menu

	CMP		rax, 0x2		; Second list item selected, EXIT
	JE		_exit_success

	JMP		_exit_error		; Strange selection is an error

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Creates a new Info window that tells a little about how
; to move around in the game, gives a movement hint, and
; how to pause the game, and of course given credit to the
; creators, use.
;;;;;;;;;;;;;;;;;;;;;;;;;;;
_load_info_menu:
	MOV		rdi, [rbp-8]	; Window to which to render menu
	MOV		rsi, info_str	; Title for the menu, currently not working
	MOV		rcx, 5			; Number of menu items
	PUSH	credit_str
	PUSH	hint_str
	PUSH	ex_key_info_str
	PUSH	mv_key_info_str
	PUSH	goal_info_str
	CALL	_show_menu
	JMP		_load_main_menu


;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Loading the map the player will run on
;;;;;;;;;;;;;;;;;;;;;;;;;;;
_load_map:
	; Get Y position for game map window
	MOV		rdx, map_height	; RDX = y coord
	SHR		rdx, 1			; Map height / 2

	MOV		rdi, [rbp-0x8]	; Root window
	CALL	_get_win_centerY; Center X position of root window
	SUB		rax, rdx		; Game window y = (root_window_height / 2) - (map_height / 2)
	MOV		rdx, rax		; RDX = y coord where the game window is centered in root window

	; Get X position for game map window 
	MOV		rcx, map_width	; RCX = x coord
	SHR		rcx, 1			; Map width / 2

	MOV		rdi, [rbp-0x8]	; Root window
	CALL	_get_win_centerX; Center X coord of root window
	SUB		rax, rcx		; Game window x = (root_window_width / 2) - (map_width / 2)
	MOV		rcx, rax		; RCX = x coord where the game window is centered in root window

	MOV		rdi, map_height	; Number of rows
	MOV		rsi, map_width	; Number of columns

	PUSH	rdx
	PUSH	rcx
	CALL	newwin
	MOV		rbx, rax		; Game Window


;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generating the scoreboard window
;;;;;;;;;;;;;;;;;;;;;;;;;;
	POP		rdi
	POP		rsi
	ADD		rsi, map_height
	MOV		rdx, map_width
	MOV		rcx, 100			; Starting score
	CALL	_new_scoreboard
    MOV     [rbp-24], rax

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;
; This where the game board is rendered to the terminal and the game loop
; starts. Most of the code will go below this point.
;
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Rending the map specified by map_file
;
; _render_map returns a pointer to a player.
; The player starts wherever an 'S' appears on the game map
; If multiple 'S' unknown behavior occurs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Calculate map size = (# Cols) * (# Rows)
	MOV		rax, map_width
	MOV		rdx, map_height
	MUL		rdx				; RAX = RDX * RAX
	MOV		rdi, rbx		; Game window
	MOV		rsi, map_file	; The map to load
	MOV		rdx, rax		; map_size
	CALL	_gen_gameboard	; Draws the map to the terminal and set cursor to start
	MOV		[rbp-16], rax	; GameBoard* gameboard

	TEST	rax, rax		; Making sure the game map was rendered, error if rax < 0
	JL		_exit_error

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Player movement / Game loop here
;
; Can use window.asm for maybe helpful procedures
;;;;;;;;;;;;;;;;;;;;;;;;;;;
	XOR		r12, r12		; Key pressed

	MOV		rdi, [rbp-16]
	MOV		rdi, [rdi]
	MOV		rsi, 100		; Wait <x> milliseconds before skipping user input
	CALL	wtimeout

_game_loop:
	PUSH	r12
	CALL	_move_enemy
	POP		r12

	;;;;;;;;;;;;;;;;;;;;;;;;
	; Getting the user input, if no input after 
	; x milliseconds auto move
	;;;;;;;;;;;;;;;;;;;;;;;;
	MOV		rdi, [rbp-16]
	MOV		rdi, [rdi]
	CALL	wgetch			; Waiting for user input

	CMP		eax, -1			; If the user does not input movement -1 is returned
	JE		.move_player	; If no input move player in direction of last move
	MOV		r12, rax

	;;;;;;;;;;;;;;;;;;;;;;;;
	; If the player has pressed a move button
	; add one to their score, if score is zero, they lose
	;;;;;;;;;;;;;;;;;;;;;;;;
	MOV		rdi, [rbp-24]
	MOV		rsi, -5				; Amount to decrease the score by
	CALL	_increment_score

	MOV		rdi, [rbp-24]
	MOV		rdi, [rdi+8]
	CMP		rdi, 0x0
	JLE		_menus.show_lose_menu
	;;;;;;;;;;;;;;;;;;;;;;;;;
	; Menu toggle options
	;;;;;;;;;;;;;;;;;;;;;;;;;
	CMP		r12, 0xa		; If user input is new line, exit game
	JE		_menus.show_lose_menu

	CMP		r12, 'p'
	JE		_menus.show_pause_menu


.move_player:
	; Start of player movement
	; Sorry just have to have vim movement for my sanity

	CMP		r12, 's'		; S key for gamers
	JE		.mv_player_down
	CMP		r12, 'j'		; J key for vimers
	JE		.mv_player_down

	CMP		r12, 'w'
	JE		.mv_player_up
	CMP		r12, 'k'		
	JE		.mv_player_up

	CMP		r12, 'a'
	JE		.mv_player_left
	CMP		r12, 'h'	
	JE		.mv_player_left

	CMP		r12, 'd'
	JE		.mv_player_right
	CMP		r12, 'l'
	JE		.mv_player_right

	JMP		_game_loop		; Infinite loop / game loop


.mv_player_right:
	MOV		rdi, [rbp-16]	; GameBoard
	MOV		rdi, [rdi+8]	; Player
	MOV		rsi, 0			; Move player down/up zero rows
	MOV		rdx, 1			; Move the player right 1 column
	CALL	_move_player_yx	; CALL window.asm corresponding function
	JMP     _game_loop		; Jump back to game loop to get next input

.mv_player_left:
	MOV		rdi, [rbp-16]	; GameBoard
	MOV		rdi, [rdi+8]	; Player
	MOV		rsi, 0			; Move player down/up zero rows
	MOV		rdx, -1			; Move the player left 1 column
	CALL	_move_player_yx	; CALL window.asm corresponding function
	JMP		_game_loop		; Jump back to game loop to get next input


.mv_player_up:
	MOV		rdi, [rbp-16]	; GameBoard
	MOV		rdi, [rdi+8]	; Player
	MOV		rsi, -1			; Move player up 1 column
	MOV		rdx, 0			; Move the player left/right zero rows
	CALL	_move_player_yx	; CALL window.asm corresponding function
	JMP		_game_loop


.mv_player_down:
	MOV		rdi, [rbp-16]	; GameBoard
	MOV		rdi, [rdi+8]	; Player
	MOV		rsi, 1			; Move player down 1 column
	MOV		rdx, 0			; Move the player left/right zero rows
	CALL	_move_player_yx	; CALL window.asm corresponding function
	JMP		_game_loop		; Jump back to game loop to get next input

_move_enemy:
	;
	; Start of enemy movement
	; Basic AI of moving directly towards the player
    ; if the direct pathway is blocked, will move the opposite direction
    ; in hopes of finding a new pathway
 	;
	MOV		r8, [dir]
	MOV		rdi, [rbp-16]	; Gameboard
	MOV		r9, [rdi+16]	; Enemy
	MOV		r10, [r9+16]	; Save current Y location
	MOV		r11, [r9+24]	; Save current X location

	;;;;;;;;;;;;;;;;;;;;;;;
	;
	; Go through every direction and determine which ones are valid
	;
	;;;;;;;;;;;;;;;;;;;;;;;

	;check if we can move up
	MOV		rdi, r9			; 
	MOV		rsi, -1			; Move up 1 row
	MOV		rdx, 0			; move left/right zero columns
	CALL	_valid_move	
	MOV		r12, rax

	;check if we can move down
	MOV		rdi, r9
	MOV		rsi, 1			; Move dowm 1 row
	MOV		rdx, 0			; move left/right zero columns
	CALL	_valid_move	
	MOV		r13, rax

	;check if we can move left
	MOV		rdi, r9
	MOV		rsi, 0			; Move up/down zero row
	MOV		rdx, -1			; move left 1 column
	CALL	_valid_move	
	MOV		r14, rax

	;check if we can move right
	MOV		rdi, r9
	MOV		rsi, 0			; Move up/down zero row
	MOV		rdx, 1			; move right 1 column
	CALL	_valid_move	
	MOV		r15, rax

;
; Disable the move that was previously taken
; This prevents the enemy from ever going backwards and thus
; getting stuck in a corner
;
.check_up:
	; check move up is disabled	
	CMP		r8, 0
	JNE		.check_right

;.set_up:
	XOR		r12, r12

.check_right:
	; move right is disabled
	CMP		r8, 2
	JNE		.check_down

.set_right:
	XOR		r13, r13	

.check_down:
	; move down is disbaled
	CMP		r8, 4
	JNE		.check_left	

.set_down:
	XOR		r14, r14

.check_left:
	; move left is disbaled
	CMP		r8, 8
	JNE		.calc_closest

.set_left:
	XOR		r15, r15

;;;;;;;;;;;;;;;;;;;;;;;
;
; Calculate the distance between enemy and 
; the player depending on various moves
;
;;;;;;;;;;;;;;;;;;;;;;;
.calc_closest:
	MOV		r8, [rbp-16]	; Gameboard
	MOV		r8, [r8+8]		; Player

	; check if up needs to be calculated
	CMP		r12, 1
	JE		.up_closest

.up_set_neg:
	MOV		r12, -1			; set distance to -1
	JMP		.right_check
	
.up_closest:
	MOV		rsi, [r8+16]	; Player y
	MOV		rdi, [r8+24]	; Player x
	
	MOV		rcx, r10		; Store enemy y		
	ADD		rcx, -1			; move up one row
	MOV		rdx, r11		; store enemy x
	CALL	_calc_distance	; calculate distance between player and enemy next move
	MOV		r12, rax

.right_check:
	CMP		r13, 1			; is right a valid move
	JMP		.right_closest

.right_set_neg:
	MOV		r13, -1			; set distance = -1
	JMP		.down_check


.right_closest:
	MOV		rsi, [r8+16]	; Player y
	MOV		rdi, [r8+24]	; Player x
	
	MOV		rcx, r10		; Store enemy y		
	MOV		rdx, r11		; store enemy x
	ADD		rdx, 1			; move right 1 column
	CALL	_calc_distance	; calculate distance between player and enemy next move
	MOV		r13, rax


.down_check:
	CMP		r14, 1			; is down a valid move
	JE		.down_closest

.down_set_neg:
	MOV		r14, -1			; set disrance = 1
	JMP		.left_check

.down_closest:
	MOV		rsi, [r8+16]	; Player y
	MOV		rdi, [r8+24]	; Player x
	
	MOV		rcx, r10		; Store enemy y		
	ADD		rcx, 1			; move down one row
	MOV		rdx, r11		; store enemy x
	CALL	_calc_distance	; calculate distance between player and enemy next move
	MOV		r14, rax


.left_check:
	CMP		r15, 1			; is left a valid move
	JE		.left_closest

.left_set_neg:
	MOV		r15, -1			; set distance = -1
	JMP		.perform_enemy_move

.left_closest:
	MOV		rsi, [r8+16]	; Player y
	MOV		rdi, [r8+24]	; Player x
	
	MOV		rcx, r10		; Store enemy y		
	MOV		rdx, r11		; store enemy x
	ADD		rdx, -1			; move left one column
	CALL	_calc_distance	; calculate distance between player and enemy next move
	MOV		r12, rax

;
; Need to find direction to move in
; Current min direction will be stored in (x,y)=(rdx, rsi)
; Current min distance is stored in r8
;
.perform_enemy_move:
	XOR		rdx, rdx		; x=0
	XOR		rsi, rsi		; y=0

.is_up_lose:
	CMP		r12, 0			; if distance is 0, we have hit the player
	JNE		.is_right_lose	; not a losing move
	
	; lose the game
	MOV		rdi, r9			; Enemy
	MOV		rsi, -1			; Move up one row
	XOR		rdx, rdx		; Move left/right zero columns
	CALL	_move_player_yx	; Move enemy before ending game so user knows they were touched	
	CALL	_menus.show_lose_menu	; End game

.is_right_lose:
	CMP		r13, 0			; if distance is 0, we have hit the player
	JNE		.compare_right	; not a losing move
	
	; lose the game
	MOV		rdi, r9			; Enemy
	XOR		rsi, rsi		; Move up/down zero row
	MOV		rdx, 1			; Move right 0 columns
	CALL	_move_player_yx	; Move enemy before ending game so user knows they were touched	
	CALL	_menus.show_lose_menu	; End game


.compare_right:
	; compare up distance with right distance
	CMP		r12, r13		; is moving up better than right
	JL		.up_min			; distance moving up is closer
	JMP		.right_min		; jump to right being minimum 

.up_min:
	MOV		QWORD [dir], 0	; set current direction to up
	MOV		r8, r12			; set up dist as new min
	XOR		rdx, rdx		; x=0
	MOV		rsi, -1			; y=-1
	JMP		.is_down_lose

.right_min:
	MOV		QWORD [dir], 2	; set current direction to right
	MOV		r8, r13			; set right dist as new min
	MOV		rdx, 1			; x=1
	XOR		rsi, rsi		; y=0
	JMP		.is_down_lose

.is_down_lose:
	CMP		r14, 0			; distance is 0 so enemy has hit the player
	JNE		.compare_down
	
	; lose the game
	MOV		rdi, r9			; Enemy
	MOV		rsi, 1			; Move down one row
	XOR		rdx, rdx		; Move left/right zero columns
	CALL	_move_player_yx	; Move enemy before ending game so user knows they were touched	
	CALL	_menus.show_lose_menu	; End game

.compare_down:
	CMP		r14, r8			; is down dist smaller than current
	JL		.down_min
	JMP		.is_left_lose	

.down_min:
	MOV		QWORD [dir], 4	; set current direction to down
	MOV		r8, r14			; set down as new min
	XOR		rdx, rdx		; x=0
	MOV		rsi, 1			; y=1

.is_left_lose:
	CMP		r15, 0			; if distance is 0, we have hit the player
	JNE		.compare_left	; not a losing move
		
	; lose the game
	MOV		rdi, r9			; Enemy
	XOR		rsi, rsi		; Move up/down zero row
	MOV		rdx, -1			; Move left 1 columns
	CALL	_move_player_yx	; Move enemy before ending game so user knows they were touched	
	CALL	_menus.show_lose_menu	; End game


.compare_left:
	CMP		r15, r8			; is left dist smaller than current min
	JE		.left_min
	JMP		.end_game	


.left_min:
	MOV		QWORD [dir], 8	; set current direction to left
	MOV		r8, r15			; set left as new min
	MOV		rdx, -1			; x=-1
	XOR		rsi, rsi		; y=0

.end_game:
	MOV		rdi, r9			; enemy
	CALL	_move_player_yx		
	CMOVE	r8,r9
	RET


;;;;;;;;;;;;;;;;;;;;;;;;
;
; Calculates the distance between 2 points
; rdi: 1st x coordiate
; rsi: 1st y coordinate
; rdx: 2nd x coordinate
; rcx: 2nd y coordinate
;
;;;;;;;;;;;;;;;;;;;;;;;;
_calc_distance:
	CMP		rdi, rdx	; Figure out with x is smaller
	JL		.x_lesser
	JMP		.x_greater

.x_lesser:
	SUB		rdx, rdi	; x_2 - x_1 (guranteed positive since x_2 > x_1
	MOV		rdi, rdx	; make sure x difference stored in rdi
	JMP		.check_y

.x_greater:
	SUB		rdi, rdx	; x-1 - x_2 (guranteed positive since x_1 >= x_2

.check_y:
	CMP		rsi, rcx
	JL		.y_lesser
	JMP		.y_greater

.y_lesser:
	SUB		rcx, rsi	; y_2 - y_1 (guranteed positive since y_2 > y_1)
	MOV		rsi, rcx	; make sure y difference is stored in rsi
	JMP		.get_dist

.y_greater:
	SUB		rsi, rcx	; y_1 - y_2 (guranteed positive since y_1 >= y_2)

.get_dist:
	IMUL	rdi, rdi	; x^2
	IMUL	rsi, rsi	; y^2
	ADD		rdi, rsi	; x^2+y^2, No need to do sqrt 

	MOV		rax, rdi
	RET	

_menus:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a new pause window that will prompt the user
; to either resume the game play or to exit the game.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.show_pause_menu:
	MOV		rdi, [rbp-16]
	MOV		rdi, [rdi]		; Window to which to render menu
	MOV		rsi, pause_str	; Title for the pause menu
	MOV		rcx, 2			; Number of menu items
	PUSH	exit_str		; Last menu item
	PUSH	resume_str		; First menu item
	CALL	_show_menu
	
	CMP		rax, 0x0		; First list item selected, RESUME
	JE		_game_loop

	CMP		rax, 0x1		; Second list item selected, EXIT
	JE		_end_game
	JMP		_exit_error		; Strange selection is an error

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a new win window that indicates to the user that
; they have won the game. They are given the option to play
; again or to exit the game.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.show_win_menu:
	MOV		rdi, [rbp-16]	; GameBoard
	MOV		rdi, [rbp-8]	; Window to which to render menu
	MOV		rsi, win_str	; Title for the win menu
	MOV		rcx, 2			; Number of menu items
	PUSH	exit_str		; Last menu item
	PUSH	play_again_str	; First menu item
	CALL	_show_menu

	CMP		rax, 0x0		; First list item selected, PLAY AGAIN
	JE		_restart

	CMP		rax, 0x1		; Second list item selected, EXIT
	JE		_end_game

	JMP		_exit_error		; Strange selection is an error

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a new win window that indicates to the user that
; they have lost the game. They are given the option to play
; again or to exit the game.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.show_lose_menu:
	MOV		rdi, [rbp-8]	; Window to which to render menu
	MOV		rsi, lose_str	; Title for the lose menu
	MOV		rcx, 2			; Number of menu items
	PUSH	exit_str		; Last menu item
	PUSH	play_again_str	; First menu item
	CALL	_show_menu

	CMP		rax, 0x0		; First list item selected, PLAY AGAIN
	JE		_restart

	CMP		rax, 0x1		; Second list item selected, EXIT
	JE		_end_game

	JMP		_exit_error		; Strange selection is an error

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Destroys the current game window and will rerender the game
; board representing a restart.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_restart:
    MOV     rax, [rbp-24]
    MOV     rdi, [rax]      ; Freeing the scoreboard window
    CALL    delwin

	MOV		rdi, [rbp-16]
	CALL	free			; Freeing the player created

	mov		rdi, rdx
	CALL	endwin
	JE		_load_map

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Destroys the current game window and then exits the program
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_end_game:
	MOV		rdi, [rbp-16]
	CALL	free			; Freeing the player created

	mov		rdi, rdx
	CALL	endwin
	; Falls through to exit_success

;;;;;;;;;;;;;;;;;;;;;;;;;
; Code to exit the program
; 
; Contains: 
; 		exit success, returns error code 0
; 		exit error, returns error code 1
;;;;;;;;;;;;;;;;;;;;;;;;;
section .data
	suc_msg		db ":( Why are you leaving me? Please come back!", 0xa, 0x0
	suc_msg_len	equ $ - suc_msg

	err_msg		db ":() An Error Has Occured!", 0xa, 0x0
	err_msg_len	equ $ - err_msg

section .text

_exit_success:
	MOV		rdi, 1
	CALL	curs_set

	CALL	endwin

	; Print success leave message
	MOV		rax, 0x1
	MOV		rdi, 0x1
	MOV		rsi, suc_msg
	MOV		rdx, suc_msg_len
	SYSCALL

	LEAVE		; restoring the stack

	; Exit with error code 0
	MOV		rax, 0x3c
	XOR		rdi, rdi
	SYSCALL

_exit_error:
	MOV		rdi, 1
	CALL	curs_set

	CALL	endwin

	; Print error message
	MOV		rax, 0x1
	MOV		rdi, 0x1
	MOV		rsi, err_msg
	MOV		rdx, err_msg_len
	SYSCALL

	LEAVE		; restoring the stack

	; Exit with error code 1
	MOV		rax, 0x3c
	MOV		rdi, 1
	SYSCALL
