#include <ncurses.h>
#include <stdio.h>

int main() {
	int x, y;
	WINDOW* s = initscr();
	((void) 0);
	getmaxyx(s, x, y);
	endwin();
	printf("x: %d\n", x);
	printf("y: %d\n", y);
	return 0;
}
