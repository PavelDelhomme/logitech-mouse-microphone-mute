#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <stdio.h>
#include <linux/uinput.h>

#define DEV_EVENT_PATH "/dev/input/by-id/usb-Logitech_USB_Receiver-if02-event-mouse"
#define MOUSE_BTN_CODE 15
#define COMMAND "sudo -u USER XDG_RUNTIME_DIR=/run/user/$(id -u USER) pactl set-source-mute @DEFAULT_SOURCE@ toggle"

int eventLog(struct input_event ie, int dc);

int main(int argc, char **argv){

  int mouse_fd;
  struct input_event ie;
  int debug = 0;
  mouse_fd = open(DEV_EVENT_PATH, O_RDONLY);
  if (mouse_fd < 0)
      return (1);
  
  while (1)
    {
      read(mouse_fd, &ie, sizeof(ie));
      if ((int) ie.code == 15 && ie.value == 1)
	{
	  system(COMMAND);
	}
     }

  close(mouse_fd);
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
