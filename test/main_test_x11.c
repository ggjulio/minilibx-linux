#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <X11/Xlib.h>

Display *display;
GC	gc;
int	screen;
Window	win, root;
unsigned long white_pixel, black_pixel;

void expose (){ XDrawString (display, win, gc, 10, 30, "working !", 14);}

int main ()
{
	char *display_name = NULL;

	printf("start poc\n");
    if ((display = XOpenDisplay (display_name)) == NULL) {
		fprintf (stderr, "Can't open Display\n");
		exit (2);
    }

    gc = DefaultGC (display, screen);
    screen = DefaultScreen (display);
    root = RootWindow (display, screen);
    white_pixel = WhitePixel (display, screen);
    black_pixel = BlackPixel (display, screen);

	win = XCreateSimpleWindow (display, root, 0, 0, 100, 90, 2, black_pixel, white_pixel);
    XSelectInput (display, win, ExposureMask);
    XStoreName (display, win, "xsimple");
    XMapWindow (display, win);

	printf("screen=%d", screen);
    while(1) {
		XEvent ev;
		char c;

		XNextEvent(display, &ev);
		switch (ev.type) {
			case Expose :
				expose();
				break;
			default :
				break;
		}
    }
	printf("end poc\n");
	return 0;
}