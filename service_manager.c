#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>

#define PID_FILE "/tmp/custom_keybind.pid"
#define STATUS_FILE "/tmp/custom_keybind.status"

void write_pid_file() {
    FILE *pid_file = fopen(PID_FILE, "w");
    if (pid_file) {
        fprintf(pid_file, "%d\n", getpid());
        fclose(pid_file);
    }
}

void write_status(const char* status) {
    FILE *status_file = fopen(STATUS_FILE, "w");
    if (status_file) {
        fprintf(status_file, "%s\n", status);
        fclose(status_file);
    }
}

void cleanup_handler(int sig) {
    write_status("STOPPED");
    unlink(PID_FILE);
    unlink(STATUS_FILE);
    exit(0);
}

// Ajoute cette fonction au début de ton main() dans custom_keybind.c
void setup_service_management() {
    signal(SIGINT, cleanup_handler);
    signal(SIGTERM, cleanup_handler);
    write_pid_file();
    write_status("RUNNING");
}

