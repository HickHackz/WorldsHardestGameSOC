module memory_access (
			
input logic Clk,
	
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
	output logic [31:0] onchipq
	);
	
	map2_memory ram (.clock(Clk), .address(VGA_ADDR), .q(onchipq));

	always_comb
	begin
	if (AVL_READ)
		AVL_READDATA = 8'hF;
	else
		AVL_READDATA = 8'h0;
	end
endmodule
	// Avalon-MM Read Data