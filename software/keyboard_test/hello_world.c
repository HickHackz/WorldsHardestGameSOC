#include <stdio.h>
#include "system.h"
#include "map_print.h"
#include "altera_avalon_spi.h"
#include "altera_avalon_spi_regs.h"
#include "altera_avalon_pio_regs.h"
#include "sys/alt_irq.h"
#include "usb_kb/GenericMacros.h"
#include "usb_kb/GenericTypeDefs.h"
#include "usb_kb/HID.h"
#include "usb_kb/MAX3421E.h"
#include "usb_kb/transfer.h"
#include "usb_kb/usb_ch9.h"
#include "usb_kb/USB.h"
#include "usb_input.h"


int main() {
	volatile unsigned int *INITIALIZE_LEVEL_PIO = (unsigned int*)0x11150;

	*INITIALIZE_LEVEL_PIO = 0;
	//mapWrite();
	for (int i = 0; i < 119110; i++)
		*INITIALIZE_LEVEL_PIO = 1; //this triggers the initial loading of registers
	*INITIALIZE_LEVEL_PIO = 0;
	usb_input();
	return 0;
}
