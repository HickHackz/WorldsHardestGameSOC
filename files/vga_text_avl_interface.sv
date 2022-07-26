/************************************************************************
Avalon-MM Interface VGA Text mode display

Register Map:
0x000-0x0257 : VRAM, 80x30 (2400 byte, 600 word) raster order (first column then row)
0x258        : control register

VRAM Format:
X->
[ 31  30-24][ 23  22-16][ 15  14-8 ][ 7    6-0 ]
[IV3][CODE3][IV2][CODE2][IV1][CODE1][IV0][CODE0]

IVn = Draw inverse glyph
CODEn = Glyph code from IBM codepage 437

Control Register Format:
[[31-25][24-21][20-17][16-13][ 12-9][ 8-5 ][ 4-1 ][   0    ] 
[[RSVD ][FGD_R][FGD_G][FGD_B][BKG_R][BKG_G][BKG_B][RESERVED]

VSYNC signal = bit which flips on every Vsync (time for new frame), used to synchronize software
BKG_R/G/B = Background color, flipped with foreground when IVn bit is set
FGD_R/G/B = Foreground color, flipped with background when Inv bit is set

************************************************************************/
`define NUM_REGS 601 //80*30 characters / 4 characters per register
`define CTRL_REG 600 //index of control register
/*
module read_state_machine (
	input logic CLK,
	input logic AVL_READ,
	input logic RESET,
	output logic ready
	);
	logic one = 1'b1;
	always_ff @(posedge CLK)
	begin
		if (AVL_READ)
		begin
			if (one == 0)
			begin
				ready = 1;
				one = 1;
			end
			else
				begin
				one = 0;
				ready = 0;
			end
		end
		else
			ready = 1'b0;
	end
endmodule
*/

module  color_mapper (input flag, input blank, input logic [11:0] fg, bg,
							 //adding this line
                      output logic [7:0]  Red, Green, Blue );
 //

    always_comb
    begin:RGB_Display
	 
	if (!blank)
	begin
		Red = 4'b0000; //changed to red foreground
		Green = 4'b0000;//changed to red foreground
		Blue = 4'b0000;
	end			
	else
		begin
		 if ((flag == 1'b1))
		 begin
			Red = fg[11:8]; //changed to red foreground
			Green = fg[7:4];;//changed to red foreground
			Blue = fg[3:0];//changed to red foreground
		end
		else
		begin
			Red = bg[11:8]; //changed to red foreground
			Green = bg[7:4];;//changed to red foreground
			Blue = bg[3:0];//changed to red foreground
		end
	end

    end
    //
endmodule

module fsm (
			
input logic Clk,
	
	// Avalon Reset Input
	input logic RESET,
	input logic [7:0] color_code,
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,					// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
	input  [11:0] AVL_ADDR,
	input  logic [11:0] VGA_ADDR,	// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,
	output logic [31:0] onchipq,
	output logic [11:0] background, foreground
	);
	
	logic ram_rwen;
	onchipram ram (.byteena_a(AVL_BYTE_EN), .clock(Clk), .data(AVL_WRITEDATA), .rdaddress(VGA_ADDR), .wraddress(AVL_ADDR), .wren(ram_rwen),
						.q(onchipq));
	logic [31:0] ColorPal   [7:0]; //This is my 8 register color pallete
	logic regaccess, odd_b, odd_f;
	logic [3:0] idx_background, idx_foreground;

	
	
	always_comb
	begin
		idx_background = color_code[3:0] >> 1;
		idx_foreground = color_code[7:4] >> 1;
		
		if (color_code[3:0] == 1'h0 && color_code[7:4] == 1'h0)
		begin
			background = ColorPal[idx_background][12:1];
			foreground = ColorPal[idx_foreground][12:1];
		end
		
		else
		begin
			if (odd_b)
				background = ColorPal[idx_background][24:13];
			else
				background = ColorPal[idx_background][12:1];
				
			if (odd_f)
				foreground = ColorPal[idx_foreground][24:13];
			else
				foreground = ColorPal[idx_foreground][12:1];
		end
	
	end
	
	always_comb 
	begin
		if (color_code[0] == 1'b0)
			odd_b = 0;
		else
			odd_b = 1;
			
		if (color_code[4] == 1'b0)
			odd_f = 0;
		else
			odd_f = 1;
		
		regaccess = AVL_ADDR[11];
		if (!regaccess)
			ram_rwen = AVL_WRITE;
		else
			ram_rwen = 1'b0;
	end
	
	always_ff @(posedge Clk) 
	begin
	
	if (RESET)
	begin
		ColorPal[0] = 32'h00000000;
		ColorPal[1] = 32'h00000000;
		ColorPal[2] = 32'h00000000;
		ColorPal[3] = 32'h00000000;
		ColorPal[4] = 32'h00000000;
		ColorPal[5] = 32'h00000000;
		ColorPal[6] = 32'h00000000;
		ColorPal[7] = 32'h00000000;

	end
	else if (AVL_CS) 
	begin
		if (AVL_READ) 
			if (regaccess)
				AVL_READDATA = ColorPal[AVL_ADDR[2:0]]; //grabs the word register for specified address above 	
		
		if (AVL_WRITE)
		begin
			if (regaccess)
			begin
				unique case (AVL_BYTE_EN)
				4'b1111 : ColorPal[AVL_ADDR[2:0]] <= AVL_WRITEDATA;
				4'b1100 : ColorPal[AVL_ADDR[2:0]][31:16] <= AVL_WRITEDATA[31:16];
				4'b0011 : ColorPal[AVL_ADDR[2:0]][15:0] <= AVL_WRITEDATA[15:0];
				4'b1000 : ColorPal[AVL_ADDR[2:0]][31:24] <= AVL_WRITEDATA[31:24];
				4'b0100 : ColorPal[AVL_ADDR[2:0]][23:16] <= AVL_WRITEDATA[23:16];
				4'b0010 : ColorPal[AVL_ADDR[2:0]][15:8] <= AVL_WRITEDATA[15:8];
				4'b0001 : ColorPal[AVL_ADDR[2:0]][7:0] <= AVL_WRITEDATA[7:0];
				endcase
			end	
		end
	

		
	end
	end
endmodule
	// Avalon-MM Read Data
module vga_text_avl_interface (
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,

	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,					// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
	input  logic [11:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs						// VGA HS/VS
);

wire blank;
//logic [31:0] LOCAL_REG       [600:0]; // Registers
logic [31:0] onchipq, color_reg;
//put other local variables here
logic pixel_clk, sync, flag, not_flag; //deleted ready
logic [9:0] DrawX, DrawY;
logic [11:0] addr;
logic [7:0] data, row, column, color_code;
logic [6:0] keycode;
logic [9:0] Sprite_X_Pos, Sprite_Y_Pos;
logic [11:0] sram_address;
//read_state_machine stm (.CLK(CLK), .AVL_READ(AVL_READ), .RESET(RESET), .ready(ready));


logic [11:0] background, foreground;
logic [7:0] Red, Green, Blue;
//Declare submodules..e.g. VGA controller, ROMS, etc
VGA_controller con (
                            .Clk(CLK), 
                            .Reset(RESET), 
                            .hs(hs), 
                            .vs(vs), 
                            .pixel_clk(pixel_clk),
                            .blank(blank),
                            .sync(sync),
                            .DrawX(DrawX),
                            .DrawY(DrawY)  ); 
									 
color_mapper mapper(			
									 .bg(background),
									 .fg(foreground),
									 .blank(blank),
                            .flag(not_flag),
                            .Red(Red),
                            .Green(Green),
                            .Blue(Blue)
                         );
fsm notanfsm (
.RESET(RESET),
.color_code(color_code),
.AVL_READ(AVL_READ),					// Avalon-MM Read
.AVL_WRITE(AVL_WRITE),					// Avalon-MM Write
.AVL_CS(AVL_CS),	
.AVL_BYTE_EN(AVL_BYTE_EN),			// Avalon-MM Byte Enable
.AVL_ADDR(AVL_ADDR),
.VGA_ADDR(sram_address),	//Avalon-MM Address
.AVL_WRITEDATA(AVL_WRITEDATA),		// Avalon-MM Write Data
.AVL_READDATA (AVL_READDATA),
.onchipq(onchipq),
.background(background),
.foreground(foreground),
.Clk(CLK)
);










//.*, .VGA_ADDR(sram_address), .color_code(color_code), .background(background), .foreground(foreground));

assign column = Sprite_X_Pos >> 4; //3 for 8 wide character, 2 character / word, column of words

assign row = Sprite_Y_Pos >> 4; //
//font_rom rom (.*);
assign sram_address = 20 * row + column;

logic [9:0] char_col;

assign char_col = Sprite_X_Pos >> 3; //8 bit wide character
always_comb 
begin
	
	if (char_col[0] == 1'b0)
		begin
			not_flag = flag ^ onchipq[15];
			keycode = onchipq[14:8];
			color_code = onchipq[7:0];
		end

	else 
	begin
		not_flag = flag ^ onchipq[31];
		keycode = onchipq[30:24];
		color_code = onchipq[23:16];
	end
end

sprite sym (
                    .DrawX(DrawX),
                    .DrawY(DrawY),
                    .keycode(keycode),
                    .flag(flag),
                    .Sprite_X_Pos(Sprite_X_Pos),
                    .Sprite_Y_Pos(Sprite_Y_Pos)  );   
// Read and write from AVL interface to register block, note that READ waitstate = 1, so this should be in always_ff



assign red = Red[3:0];
assign green = Green[3:0];
assign blue = Blue[3:0];


//handle drawing (may either be combinational or sequential - or both).
		

endmodule
