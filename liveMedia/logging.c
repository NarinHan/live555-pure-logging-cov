#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/file.h>  // For flock
#include "logging.h"

void log_variable(const char* var_name, int value, const char* file, int line) {
    const char* log_path = "/home/ubuntu/experiments/transitions.log";

    // Open the log file for writing (append mode)
    int fd = open(log_path, O_WRONLY | O_CREAT | O_APPEND, 0644);
    if (fd == -1) {
        perror("Error opening log file");
        return;
    }

    // Lock the file (exclusive lock)
    if (flock(fd, LOCK_EX) == -1) {
        perror("Error locking log file");
        close(fd);
        return;
    }

    // Write the log line atomically using dprintf
    dprintf(fd, "%s:%d: %s = %d\n", file, line, var_name, value);

    // Unlock and close the file
    flock(fd, LOCK_UN);
    close(fd);
}

