#include <sys/time.h>
#include <stdlib.h>

int
main()
{
	struct timeval zero = { 0, 0 };
	struct timeval three = { 3, 0 };
	struct itimerval timer = { zero, three };
	setitimer(ITIMER_REAL, &timer, NULL);
	for (;;)
		system("true");
}
