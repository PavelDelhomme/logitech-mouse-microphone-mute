#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <stdio.h>
#include <linux/input.h>
#include <signal.h>
#include <string.h>

// *** CORRIGÉ : Utilise event5 pour ta MX Master 3 ***
#define MOUSE_EVENT_PATH "/dev/input/event5"  // MX Master 3 identifiée

// Codes de boutons courants pour MX Master 3 - à tester
#define MOUSE_BTN_CODE 275  // BTN_SIDE - bouton latéral

#define COMMAND "sudo -u pactivisme XDG_RUNTIME_DIR=/run/user/$(id -u pactivisme) pactl set-source-mute @DEFAULT_SOURCE@ toggle"

#define PID_FILE "/tmp/custom_keybind.pid"
#define STATUS_FILE "/tmp/custom_keybind.status"

// Déclarations des fonctions
void write_pid_file();
void write_status(const char* status);
void cleanup_handler(int sig);
void setup_service_management();

// Implémentations
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

void setup_service_management() {
    signal(SIGINT, cleanup_handler);
    signal(SIGTERM, cleanup_handler);
    write_pid_file();
    write_status("RUNNING");
}

int main(int argc, char **argv){
    setup_service_management();

    int mouse_fd;
    struct input_event ie;

    // Ouvre le périphérique MX Master 3 (/dev/input/event5)
    mouse_fd = open(MOUSE_EVENT_PATH, O_RDONLY);
    if (mouse_fd < 0) {
        write_status("ERROR: Cannot open mouse device");
        printf("❌ Erreur : Impossible d'ouvrir le périphérique souris : %s\n", MOUSE_EVENT_PATH);
        printf("💡 Vérifiez que vous êtes dans le groupe input : groups\n");
        printf("💡 Si ce n'est pas le cas : sudo usermod -a -G input $USER puis redémarrez la session\n");
        printf("💡 Permissions actuelles : ");
        system("ls -la /dev/input/event5");
        return (1);
    }

    write_status("LISTENING");
    printf("✅ Service démarré, écoute de la MX Master 3...\n");
    printf("🖱️  Périphérique : %s (Logitech MX Master 3)\n", MOUSE_EVENT_PATH);  
    printf("🎯 Code de bouton configuré : %d\n", MOUSE_BTN_CODE);
    printf("\n📝 APPUYEZ SUR TOUS LES BOUTONS DE VOTRE MX MASTER 3 :\n");
    printf("   - Clic gauche/droit/milieu\n");
    printf("   - Bouton pouce principal\n");
    printf("   - Bouton pouce secondaire\n");
    printf("   - Boutons avant/arrière\n");
    printf("   - Molette horizontale\n");
    printf("🛑 Ctrl+C pour arrêter\n\n");

    while (1) {
        read(mouse_fd, &ie, sizeof(ie));

        // Afficher tous les événements de boutons
        if (ie.type == EV_KEY) {
            if (ie.value == 1) {  // Appui
                printf("🔴 BOUTON APPUYÉ   - Code: %3d\n", ie.code);
            } else if (ie.value == 0) {  // Relâchement  
                printf("🔵 BOUTON RELÂCHÉ - Code: %3d\n", ie.code);
            }

            // Déclencher l'action sur notre bouton configuré
            if ((int)ie.code == MOUSE_BTN_CODE && ie.value == 1) {
                write_status("MUTE_TOGGLED");
                printf("\n🎤 *** MICROPHONE MUTE TOGGLED! *** (Code %d)\n\n", ie.code);
                system(COMMAND);
                write_status("LISTENING");
            }
        }

        // Afficher les événements de molette (optionnel)
        if (ie.type == EV_REL && (ie.code == 8 || ie.code == 6)) {
            if (ie.code == 8) {
                printf("🎡 Molette verticale   : %d\n", ie.value);
            } else if (ie.code == 6) {
                printf("🎡 Molette horizontale : %d\n", ie.value);  
            }
        }
    }

    close(mouse_fd);
    cleanup_handler(0);
    return (0);
}
