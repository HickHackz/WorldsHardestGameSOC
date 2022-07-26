

module vga_game_map_interface (
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
	input  logic [10:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs,						// VGA HS/VS
	// Imported conduit from keycode
	input logic [15:0] wasd,	// WASD from the keyboard, controls the player sprite
	input logic initialize_level,
	input logic [9:0] SW_in,
	output logic [15:0] HEX_out,
	output logic [9:0] LEDS_wire,
	input logic [1:0] key
);

assign Reset = ~key[0];






wire SW[9:0];
wire blank;
logic new_level;
//logic [31:0] LOCAL_REG       [600:0]; // Registers
logic [31:0] onchipq;
//put other local variables here
logic pixel_clk, sync, flag, print_coin; //deleted ready
logic [9:0] DrawX, DrawY;
logic [6:0] addr;
logic [7:0] row, column, row_idx, col_idx;
logic [2:0] blockcode;
logic [3:0] boundaries;
logic [9:0] Sprite_X_Pos, Sprite_Y_Pos;
logic [11:0] sram_address, player_tr_index, player_tl_index, player_br_index, player_bl_index, tile_idx;
logic [9:0] x_pos, y_pos, player_size;
//logic [2:0] block_type;
//read_state_machine stm (.CLK(CLK), .AVL_READ(AVL_READ), .Reset(Reset), .ready(ready));
wire Reset;
logic [9:0] Player_X_Center, Player_Y_Center;

logic [9:0] leftpos, rightpos, toppos, bottompos;
logic [3:0] top_left_bound, top_right_bound, bottom_left_bound, bottom_right_bound;
//logic [11:0] background, foreground;
logic [3:0] Red, Green, Blue;
//Declare submodules..e.g. VGA controller, ROMS, etc



logic write_map, write_obstacle, print_enemy, collision;

always_comb
begin
	if (AVL_ADDR[10] && AVL_WRITE)
	begin
		write_obstacle = 1;
		write_map = 0;
	end
	
	else if (AVL_WRITE && !AVL_ADDR[10])
	begin
		write_obstacle = 0;
		write_map = 1;
	end
	
	else
	begin
		write_obstacle = 0;
		write_map = 0;
	end
			
end

VGA_controller con (
                            .Clk(CLK), 
                            .Reset(Reset), 
                            .hs(hs), 
                            .vs(vs), 
                            .pixel_clk(pixel_clk),
                            .blank(blank),
                            .sync(sync),
                            .DrawX(DrawX),
                            .DrawY(DrawY)  ); 
									 
color_mapper mapper(
                                     .blockcode(blockcode),
                                     .blank(blank),
                                     .PlayerX(x_pos),
                                     .PlayerY(y_pos),
                                     .boundaries(boundaries),
                                     .DrawX(DrawX),
                                     .DrawY(DrawY),
                                     .Player_size(player_size),
                            .Red(Red),
                            .Green(Green),
                            .Blue(Blue),
                                     .print_enemy(print_enemy),
												 .print_coin(print_coin)
                         );
  
player player_sprite(
					.initialize_level(initialize_level),
					.new_level2(new_level2),
					.Reset(Reset),
					.frame_clk(vs),
					.keycode(wasd),
					.tl_bound(top_left_bound), 
					.tr_bound(top_right_bound), 
					.bl_bound(bottom_left_bound), 
					.br_bound(bottom_right_bound),
					.tl_index(player_tl_index), 
					.tr_index(player_tr_index), 
					.bl_index(player_bl_index), 
					.br_index(player_br_index),
					.PlayerX(x_pos),
					.PlayerY(y_pos),
					.PlayerS(player_size),
					.dead(collision),
					.HEX_out(HEX_out[15:8]),
					.Player_X_Center(Player_X_Center), //starting locations, don't know why I kept then named center but whatever 
					.Player_Y_Center(Player_Y_Center)
					);
			
					
level_manager one (
.RESET(Reset),
.blockcode(blockcode),
.AVL_READ(AVL_READ),					// Avalon-MM Read
.AVL_WRITE(write_map),					// Avalon-MM Write
.AVL_CS(AVL_CS),	
.AVL_BYTE_EN(AVL_BYTE_EN),			// Avalon-MM Byte Enable
.AVL_ADDR(AVL_ADDR),
.VGA_ADDR(sram_address),	//Avalon-MM Address
.AVL_WRITEDATA(AVL_WRITEDATA),		// Avalon-MM Write Data
.AVL_READDATA (AVL_READDATA),
.onchipq(onchipq),
.Clk(CLK),
.new_level(new_level),
.SW_in(SW_in),
.HEX_out(HEX_out[7:0]),
.initialize_level(initialize_level),
.pixel_clk(pixel_clk)

);

obstacle_controller two(
.RESET(Reset),			// Avalon-MM Read
.AVL_WRITE(write_obstacle),					// Avalon-MM Write
.vs(vs),
.AVL_BYTE_EN(AVL_BYTE_EN),			// Avalon-MM Byte Enable
.AVL_ADDR(AVL_ADDR),

.AVL_WRITEDATA(AVL_WRITEDATA),		// Avalon-MM Write Data
.PlayerX(x_pos),
.PlayerY(y_pos),
.PlayerS(player_size),
.Clk(CLK),
.pixel_clk(pixel_clk),
.new_level(new_level),
.initialize_level(initialize_level),
.DrawX(DrawX),
.DrawY(DrawY),
.dead(collision),
.new_level2(new_level2),
.new_level3(new_level3),
.print_enemy(print_enemy),
.SW_in(SW_in)
);

player_coin_controller three (
.Clk(CLK), 
.pixel_clk(pixel_clk), 
.vs(vs), 
.initialize_level(initialize_level),
.RESET(Reset),
.AVL_WRITE (AVL_WRITE),                   
.AVL_BYTE_EN(AVL_BYTE_EN),			// Avalon-MM Byte Enable
.AVL_ADDR(AVL_ADDR),
.AVL_WRITEDATA(AVL_WRITEDATA),    
.new_level(new_level),
.SW_in(SW_in),
.DrawX(DrawX),
.DrawY(DrawY),
.PlayerX(x_pos),
.PlayerY(y_pos),
.PlayerS(player_size), 
.collected_all(collected_all), 
.print_coin(print_coin),
.Player_start_X(Player_X_Center[9:5]),  
.Player_start_y(Player_Y_Center[9:5]),
.new_level2(new_level2)
);

assign Player_X_Center[4:0] = 4'b0;
assign Player_Y_Center[4:0] = 4'b0;


wire new_level2, new_level3;
logic collected_all;
//.*, .VGA_ADDR(sram_address), .color_code(color_code), .background(background), .foreground(foreground));


assign column = Sprite_X_Pos >> 7; //3 for 8 wide character, 2 character / word, column of words
											  //5 for 32 wide block, 4 character / word, columns of words

assign row = Sprite_Y_Pos >> 5; // 16 bits per character, now 32 bits per block

assign row_idx = Sprite_Y_Pos >> 5;

assign col_idx = Sprite_X_Pos >> 5;

assign tile_idx = 20 * row_idx + col_idx;
//font_rom rom (.*);
assign sram_address = 5 * row + column;



logic [9:0] block_col; //used to determine which portion of the data the clock pertains to 

assign block_col = Sprite_X_Pos >> 5; //32 bits per block
always_comb 
begin
	
	if (block_col[1:0] == 2'b00)
		begin
			blockcode = onchipq[2:0];
			boundaries = onchipq[6:3];
			
			
		end

	else if (block_col[1:0] == 2'b01)
	begin
		blockcode = onchipq[10:8];
		boundaries = onchipq[14:11];
	end
	
	else if (block_col[1:0] == 2'b10)
	begin
		blockcode = onchipq[18:16];
		boundaries = onchipq[22:19];
	end
	
	else
	begin
		blockcode = onchipq[26:24];
		boundaries = onchipq[30:27];
	end
end
//logic failed_boundary;
always_ff @ (posedge CLK)
begin
	if (player_tl_index == tile_idx)
		top_left_bound = boundaries;
	else
		top_left_bound = top_left_bound;

	if (player_tr_index == tile_idx)
		top_right_bound = boundaries;
	else
		top_right_bound = top_right_bound;

	if (player_bl_index == tile_idx)
		bottom_left_bound = boundaries;
	else
      bottom_left_bound= bottom_left_bound;
		
	if (player_br_index == tile_idx)
		bottom_right_bound = boundaries;
	else
	   bottom_right_bound = bottom_right_bound;

end

always_ff @ (posedge pixel_clk)
begin
	if (((player_tl_index == tile_idx || player_tr_index == tile_idx || player_bl_index == tile_idx || player_br_index == tile_idx) && blockcode == 3'b100) && collected_all == 6'b111111)
		new_level = 1;
	else
		new_level = 0;
end
			
sprite sym (
                    .DrawX(DrawX),
                    .DrawY(DrawY),
                   // .keycode(keycode),
                   // .flag(flag),
                    .Sprite_X_Pos(Sprite_X_Pos),
                    .Sprite_Y_Pos(Sprite_Y_Pos)  );   

assign red = Red;
assign green = Green;
assign blue = Blue;

endmodule
