
module coin (
							input frame_clk, Reset, refresh,
							input [9:0] x_pos, y_pos,
							input [9:0] PlayerX, PlayerY, PlayerS,
							input [9:0] DrawX, DrawY,
							output collected,
							output print_coin
);

		logic [9:0] coin_size;
		int DistX, DistY, DistX_draw, DistY_draw;

		assign coin_size = 6;
		
		always_ff @(posedge Reset or posedge refresh or posedge frame_clk)
		begin
			if(Reset)
				collected <= 1'b0;
			else if(refresh) // refresh goes high when we load a new level
				collected <= 1'b0;
			else
				begin: player_collect
					if (((DistX*DistX + DistY*DistY) < (PlayerS*PlayerS/2)) || (x_pos == 0 && y_pos == 0))
						collected <= 1;
				end
		end
		
	
	  always_comb
		 begin: player_collision
			DistX = PlayerX - x_pos;
			DistY = PlayerY - y_pos;
		 end
	 
	 always_comb
		 begin: Orb_on_proc
			DistX_draw = DrawX - x_pos;
			DistY_draw = DrawY - y_pos;
			if (((DistX_draw*DistX_draw + DistY_draw*DistY_draw) < (coin_size*coin_size)) && (!collected && x_pos != 0 && y_pos != 0))
				print_coin = 1;
			else
				print_coin = 0;
		end

endmodule
		