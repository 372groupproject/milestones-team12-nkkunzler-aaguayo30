#include <ncurses.h>

int main() {
	initscr();
	noecho();
	cbreak();

	int max_x = 0;
	int max_y = 0;
	getmaxyx(stdscr, max_y, max_x);

	getch();
	endwin();
	printf("X: %d\nY:%d\n", max_x, max_y);
	return 0;
}
