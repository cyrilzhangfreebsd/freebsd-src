#include <stdlib.h>
#include <unistd.h>

static void
fork_and_handle(int fail)
{
	pid_t pid = fork();
	if (pid == 0) {
		usleep(2000000);
		exit(0);
	}
	else if (fail) {
		exit(!(pid == -1));
	}
	else if (pid == -1) {
		exit(1);
	}
}

int
main()
{
	/*
	 * Fork 5 times successfully,
	 * 1 time unsuccessfully.
	 */
	for (int i = 0; i < 5; ++i) {
		fork_and_handle(0);
	}
	fork_and_handle(1);
}
