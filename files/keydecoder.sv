
module keydecoder(
							input [15:0] keycode_in,
							output [15:0] keycode_out
					  );
// This decoder will ensure any pair of keycode inputs will result in a more intuitive output
// For example, you can press 'G', an unused key, and 'A', left directional, and the player will still move left
// In addition, this decoder will configure reverse inputs (AW vs. WA) to send the same output as the other
	logic [15:0] keycode;
	
	always_comb
	begin: Decode_Key
		// Start with diagonal movement keys
		// WA: up-left diagonal movement
		if (keycode_in == 16'h1A04 || keycode_in == 16'h041A) // WA or AW
			keycode = 16'h1A04;
		// AS: down-left diagonal movement
		else if (keycode_in == 16'h1604 || keycode_in == 16'h0416) // SA or AS
			keycode = 16'h0416;
		// SD: down-right diagonal movement
		else if (keycode_in == 16'h1607 || keycode_in == 16'h0716) // SD or DS
			keycode = 16'h1607;
		// DW: up-right diagonal movement
		else if (keycode_in == 16'h071A || keycode_in == 16'h1A07) // DW or WD
			keycode = 16'h071A;
			
		// We know two directional keys are not being input
		// Check if one of the keys is ESC (game menu key will take priority over all others)
		else if (keycode_in[15:8] == 8'h29 || keycode_in[7:0] == 8'h29)
			keycode = 16'h0029;
		
		// Check if a directional key is being pressed in combination with a non-directional key
		// A
		else if (keycode_in[15:8] == 8'h04 || keycode_in[7:0] == 8'h04)
			keycode = 16'h0004;
		// D
		else if (keycode_in[15:8] == 8'h07 || keycode_in[7:0] == 8'h07)
		   keycode = 16'h0007;
		// S
		else if (keycode_in[15:8] == 8'h16 || keycode_in[7:0] == 8'h16)
		   keycode = 16'h0016;
		// W
		else if (keycode_in[15:8] == 8'h1A || keycode_in[7:0] == 8'h1A)
		   keycode = 16'h001A;
		// Any other inputs should be erronenous and set to empty keycode
		else
			keycode = 16'h0000;
	end
	// Set the output keycode
	assign keycode_out = keycode;

endmodule
