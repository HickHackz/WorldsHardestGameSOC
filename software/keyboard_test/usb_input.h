
#ifndef USB_INPUT_H
#define USB_INPUT_H

BYTE GetDriverandReport();
//void setLED(int LED);
//void clearLED(int LED);
//void printSignedHex0(signed char value);
//void printSignedHex1(signed char value);
void setKeycode(WORD keycode0, WORD keycode1);

int usb_input();

#endif
