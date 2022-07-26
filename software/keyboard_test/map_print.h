// map_print header file

#ifndef MAP_PRINT_H_
#define MAP_PRINT_H_

#include <system.h>
#include <alt_types.h>

#define COLUMNS 20
#define ROWS 15
#define LEVEL_NUM 10
#define DATA_PER_OBSTACLE 64

//define some colors
#define WHITE 		0xFFF
#define BRIGHT_RED 	0xF00
#define DIM_RED    	0x700
#define BRIGHT_GRN	0x0F0
#define DIM_GRN		0x070
#define BRIGHT_BLU  0x00F
#define DIM_BLU		0x007
#define GRAY		0x777
#define BLACK		0x000

struct LEVEL {
	alt_u8 MAPS[ROWS*COLUMNS*LEVEL_NUM];
	alt_u8 JUNK[1096];
	alt_u8 OBSTACLES[DATA_PER_OBSTACLE*LEVEL_NUM * 4];
	alt_u8 COIN_PLAYER[4 * LEVEL_NUM * 3];

};

static volatile struct LEVEL* vga_ctrl = VGA_GAME_MAP_CONTROLLER_0_BASE;

void mapClr();
void mapWrite();

#endif
