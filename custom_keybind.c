#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <stdio.h>
#include <linux/uinput.h>

#define DEV_EVENT_PATH "/dev/input/by-id/usb-Logitech_USB_Receiver-if02-event-mouse"
//#define MOUSE_BTN_CODE 15 // KEY_TAB - cause problème avec changement de application
#define MOUSE_BTN_CODE 
#define COMMAND "sudo -u USER XDG_RUNTIME_DIR=/run/user/$(id -u USER) pactl set-source-mute @DEFAULT_SOURCE@ toggle"

int eventLog(struct input_event ie, int dc);

int main(int argc, char **argv){
  setup_service_management();

  int mouse_fd;
  struct input_event ie;

  //int debug = 0;
  mouse_fd = open(DEV_EVENT_PATH, O_RDONLY);
  if (mouse_fd < 0) {
	  write_status("ERROR: Cannot open device");
	  return (1);
  }
      //return (1);

  write_status("LISTENING");

  while (1)
    {
      read(mouse_fd, &ie, sizeof(ie));
      if ((int) ie.code == MOUSE_BTN_CODE && ie.value == 1) {
	  write_status("MUTE_TOGGLED");
	  system(COMMAND);
	  write_status("LISTENING");
	}
     }

  close(mouse_fd);
  cleanup_handler(0);
  return (0);
}

//for debug purpose
int eventLog(struct input_event ie, int dc){
  long sec = (long) ie.time.tv_sec;
  long usec = (long) ie.time.tv_usec;
  int type = (int) ie.type;
  int code = (int) ie.code;
  int val = (int) ie.value;  
  printf("event : %d\n|_sec : %d\n|_usec : %d\n|_type : %d\n|_code : %d\n|_val : %d\n\n",dc,sec,usec, type,code,val);
    return 0;
}
