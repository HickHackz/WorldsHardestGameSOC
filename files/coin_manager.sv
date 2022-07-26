
module coin_manager (
							input logic Clk, vs,
							// Avalon Reset Input
							input logic RESET,
							input  logic new_level,
							input [9:0] DrawX, DrawY, PlayerX, PlayerY, PlayerS,
							output collected_all, print_coin,
							input initialize_level,
							
							input [4:0] Player_start_X,  
							Player_start_y, 
							Coin0_startx, 
							Coin0_starty, 
							Coin1_startx, 
							Coin1_starty, 
							Coin2_startx, 
							Coin2_starty,
							Coin3_startx, 
							Coin3_starty, 
							Coin4_startx, 
							Coin4_starty, 
							Coin5_startx, 
							Coin5_starty
							);
							
		logic [5:0] collect_flag, enable, print_mark;
		logic [9:0] x_pos [5:0], y_pos[5:0];
		logic [9:0] level_offset;
		
		logic [21:0] read_data; // each coin has 21 bits of data stored in it (enable, collected, and x/y coordinates)
		logic [10:0] mod_addr, read_addr; // address location we read the coin data from
		
		logic [9:0] coin0_startx, 
							coin0_starty, 
							coin1_startx, 
							coin1_starty, 
							coin2_startx, 
							coin2_starty,
							coin3_startx, 
							coin3_starty, 
							coin4_startx, 
							coin4_starty, 
							coin5_startx, 
							coin5_starty;
		always_comb
		begin
			coin0_startx[9:5] = Coin0_startx;
			coin0_starty[9:5] = Coin0_starty;
			coin1_startx[9:5] = Coin1_startx;
			coin1_starty[9:5] = Coin1_starty;
			coin2_startx[9:5] = Coin2_startx;
			coin2_starty[9:5] = Coin2_starty;
			coin3_startx[9:5] = Coin3_startx;
			coin3_starty[9:5] = Coin3_starty;
			coin4_startx[9:5] = Coin4_startx;
			coin4_starty[9:5] = Coin4_starty;
			coin5_startx[9:5] = Coin5_startx;
			coin5_starty[9:5] = Coin5_starty;
			
			coin0_startx[4:0] = 5'b0;
			coin0_starty[4:0] = 5'b0;
			coin1_startx[4:0] = 5'b0;
			coin1_starty[4:0] = 5'b0;
			coin2_startx[4:0] = 5'b0;
			coin2_starty[4:0] = 5'b0;
			coin3_startx[4:0] = 5'b0;
			coin3_starty[4:0] = 5'b0;
			coin4_startx[4:0] = 5'b0;
			coin4_starty[4:0] = 5'b0;
			coin5_startx[4:0] = 5'b0;
			coin5_starty[4:0] = 5'b0;
		end

		always_comb
		begin: Coin_on_proc
			if((print_mark & 6'b111111) != 0)
				print_coin = 1'b1;
			else
				print_coin = 1'b0;
		end
		
		always_comb
		begin: Collect_check // inactive coins are counted as already collected
			if(collect_flag == 6'b111111) // all active coins have been collected
				collected_all = 1'b1;
			else
				collected_all = 1'b0;
		end
		
				
		
		coin coin0(
						.Reset(RESET),
						.frame_clk(vs),
						.refresh(new_level | initialize_level), // temporarily adding refresh to only coins 0 and 1
				
						.x_pos(coin0_startx),
						.y_pos(coin0_starty),
						.PlayerX(PlayerX),
						.PlayerY(PlayerY),
						.PlayerS(PlayerS),
						.DrawX(DrawX),
						.DrawY(DrawY),
						.collected(collect_flag[0]),
						.print_coin(print_mark[0])
		);
		
		coin coin1(
						.Reset(RESET),
						.frame_clk(vs),
						.refresh(new_level | initialize_level),
				
						.x_pos(coin1_startx),
						.y_pos(coin1_starty),
						.PlayerX(PlayerX),
						.PlayerY(PlayerY),
						.PlayerS(PlayerS),
						.DrawX(DrawX),
						.DrawY(DrawY),
						.collected(collect_flag[1]),
						.print_coin(print_mark[1])
		);
		
		coin coin2(
						.Reset(RESET),
						.frame_clk(vs),
						.refresh(new_level | initialize_level),
			
						.x_pos(coin2_startx),
						.y_pos(coin2_starty),
						.PlayerX(PlayerX),
						.PlayerY(PlayerY),
						.PlayerS(PlayerS),
						.DrawX(DrawX),
						.DrawY(DrawY),
						.collected(collect_flag[2]),
						.print_coin(print_mark[2])
		);
		
		coin coin3(
						.Reset(RESET),
						.frame_clk(vs),
						.refresh(new_level | initialize_level),
			
						.x_pos(coin3_startx),
						.y_pos(coin3_starty),
						.PlayerX(PlayerX),
						.PlayerY(PlayerY),
						.PlayerS(PlayerS),
						.DrawX(DrawX),
						.DrawY(DrawY),
						.collected(collect_flag[3]),
						.print_coin(print_mark[3])
		);
		
		coin coin4(
						.Reset(RESET),
						.frame_clk(vs),
						.refresh(new_level | initialize_level),
				
						.x_pos(coin4_startx),
						.y_pos(coin4_starty),
						.PlayerX(PlayerX),
						.PlayerY(PlayerY),
						.PlayerS(PlayerS),
						.DrawX(DrawX),
						.DrawY(DrawY),
						.collected(collect_flag[4]),
						.print_coin(print_mark[4])
		);
		
		coin coin5(
						.Reset(RESET),
						.frame_clk(vs),
						.refresh(new_level | initialize_level),
		
						.x_pos(coin5_startx),
						.y_pos(coin5_starty),
						.PlayerX(PlayerX),
						.PlayerY(PlayerY),
						.PlayerS(PlayerS),
						.DrawX(DrawX),
						.DrawY(DrawY),
						.collected(collect_flag[5]),
						.print_coin(print_mark[5])
		);
		
endmodule
