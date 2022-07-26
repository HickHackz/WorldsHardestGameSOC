module level_manager (
	input logic Clk, new_level, pixel_clk,
	// Avalon Reset Input
	input logic RESET,
	input logic [2:0] blockcode,
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,					// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
	input  [10:0] AVL_ADDR,
	input  logic [11:0] VGA_ADDR,	// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,
	output logic [31:0] onchipq,
	input [9:0] SW_in,
	output [7:0] HEX_out,
	input initialize_level
	);
	logic [10:0] level_address, new_address;
	
	
	
	
	
	always_ff @ (posedge RESET or posedge new_level)
	begin
		if (RESET)
		begin
			level_address = 12'b0;
			level_count = 2'h01;
		end
		
		else if (new_level)
		begin
			level_address += 10'h04b;
			level_count = level_count + 1;
		end
		else
		begin
			level_address = level_address;
			level_count = level_count;
		end
		
	end	
	
	

	
	logic [6:0]  level_count;
	logic [7:0] current_level;
	
	 wire [3:0] c1o, c2o, c3o, c4o, c5o, c6o, c7o;
	 
	 add3 c1(.in({1'b0, current_level[7:5]}), .out(c1o));
	 add3 c2(.in({c1o[2:0], current_level[4]}), .out(c2o));
	 add3 c3(.in({c2o[2:0], current_level[3]}), .out(c3o));
	 add3 c4(.in({c3o[2:0], current_level[2]}), .out(c4o));
	 add3 c5(.in({c4o[2:0], current_level[1]}), .out(c5o));
	 add3 c6(.in({1'b0, c1o[3], c2o[3], c3o[3]}), .out(c6o));
	 add3 c7(.in({c6o[2:0], c4o[3]}), .out(c7o));
	 
	 assign HEX_out[3:0] = {c5o[2:0], current_level[0]};
	 
	 assign HEX_out[7:4] = {c7o[2:0], c5o[3]};
	
	 
	 assign new_address = level_address + VGA_ADDR;
	
	 assign current_level = level_count;
	
		
	memory_access mem (
	.RESET(RESET),
	.blockcode(blockcode),
	.AVL_READ(AVL_READ),					// Avalon-MM Read
	.AVL_WRITE(AVL_WRITE),					// Avalon-MM Write
	.AVL_CS(AVL_CS),	
	.AVL_BYTE_EN(AVL_BYTE_EN),			// Avalon-MM Byte Enable
	.AVL_ADDR(AVL_ADDR),
	.VGA_ADDR(new_address),	//Avalon-MM Address
	.AVL_WRITEDATA(AVL_WRITEDATA),		// Avalon-MM Write Data
	.AVL_READDATA (AVL_READDATA),
	.onchipq(onchipq),
	.Clk(Clk)
	);

endmodule