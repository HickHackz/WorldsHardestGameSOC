//-------------------------------------------------------------------------
//    Player.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 298 Lab 7                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  player ( input Reset, frame_clk, dead, collected_all, initialize_level, new_level2,
					input [15:0] keycode,
					input [3:0] tl_bound, tr_bound, bl_bound, br_bound,
					input [9:0] Player_X_Center, Player_Y_Center,
               output [9:0] PlayerX, PlayerY, PlayerS,
				   output [11:0] tl_index, tr_index, bl_index, br_index,
				   output logic [7:0] HEX_out	);
    
    logic [9:0] Player_X_Pos, Player_X_Motion, Player_Y_Pos, Player_Y_Motion, Player_Size;
	 logic [9:0] tl_xpos, tl_ypos, tr_xpos, tr_ypos, bl_xpos, bl_ypos, br_xpos, br_ypos;
	 logic [9:0] tl_xcord, tl_ycord, tr_xcord, tr_ycord, bl_xcord, bl_ycord, br_xcord, br_ycord = 0;
	 logic flag_x, flag_y;
	 logic [15:0] decoded_input;
	 
	
	 
	 logic [7:0]  deathcount = 0;
	 wire [3:0] c1o, c2o, c3o, c4o, c5o, c6o, c7o;
	 //prints deathcount to hex display using a combinational version of add3 and shift binary to BCD
	 
	 add3 c1(.in({1'b0, deathcount[7:5]}), .out(c1o));
	 add3 c2(.in({c1o[2:0], deathcount[4]}), .out(c2o));
	 add3 c3(.in({c2o[2:0], deathcount[3]}), .out(c3o));
	 add3 c4(.in({c3o[2:0], deathcount[2]}), .out(c4o));
	 add3 c5(.in({c4o[2:0], deathcount[1]}), .out(c5o));
	 add3 c6(.in({1'b0, c1o[3], c2o[3], c3o[3]}), .out(c6o));
	 add3 c7(.in({c6o[2:0], c4o[3]}), .out(c7o));
	 
	 assign HEX_out[3:0] = {c5o[2:0], deathcount[0]};
	 
	 assign HEX_out[7:4] = {c7o[2:0], c5o[3]};
	 
	 
	 
    parameter [9:0] Player_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Player_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Player_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Player_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] Player_Speed=2;      // Speed setting of the player
    
	 
		
    assign Player_Size = 20;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
	 
	 always_comb
	 begin
		tl_xpos = PlayerX - (PlayerS >> 1);	// x-coordinate of the player's left edge
		tl_ypos = PlayerY - (PlayerS >> 1);
		tl_xcord = tl_xpos >> 5;				// conversion of pixel location on the screen into the 20x15 tile index
		tl_ycord = tl_ypos >> 5;
		tl_index = 20 * tl_ycord + tl_xcord;
		
		tr_xpos = PlayerX + (PlayerS >> 1);
		tr_ypos = PlayerY - (PlayerS >> 1);
		tr_xcord = tr_xpos >> 5;
		tr_ycord = tr_ypos >> 5;
		tr_index = 20 * tr_ycord + tr_xcord;
		
		bl_xpos = PlayerX - (PlayerS >> 1);
		bl_ypos = PlayerY + (PlayerS >> 1);
		bl_xcord = bl_xpos >> 5;
		bl_ycord = bl_ypos >> 5;
		bl_index = 20 * bl_ycord + bl_xcord;
		
		br_xpos = PlayerX + (PlayerS >> 1);
		br_ypos = PlayerY + (PlayerS >> 1);
		br_xcord = br_xpos >> 5;
		br_ycord = br_ypos >> 5;
		br_index = 20 * br_ycord + br_xcord;
	 end
   
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Player
        if (Reset)  // Asynchronous Reset
        begin 
            Player_Y_Motion <= 10'd0; //Player_Y_Step;
				Player_X_Motion <= 10'd0; //Player_X_Step;
				Player_X_Pos <= Player_X_Center; // change this to be level-start coordinates
				Player_Y_Pos <= Player_Y_Center; // each level will have it's own coordinates in the C code
				deathcount <= 8'b00000000;
        end
		  
		  else if (dead)
		  begin 
            Player_Y_Motion <= 10'd0; //Player_Y_Step;
				Player_X_Motion <= 10'd0; //Player_X_Step;
				Player_X_Pos <= Player_X_Center; // change this to be level-start coordinates
				Player_Y_Pos <= Player_Y_Center; // each level will have it's own coordinates in the C code
				deathcount <= deathcount + 1;
        end
        
		  else if (initialize_level)
		  begin 
            Player_Y_Motion <= 10'd0; //Player_Y_Step;
				Player_X_Motion <= 10'd0; //Player_X_Step;
				Player_X_Pos <= Player_X_Center; // change this to be level-start coordinates
				Player_Y_Pos <= Player_Y_Center; // each level will have it's own coordinates in the C code
				deathcount <= 8'b00000000;;
        end
		  else if (new_level2)
		  begin 
            Player_Y_Motion <= 10'd0; //Player_Y_Step;
				Player_X_Motion <= 10'd0; //Player_X_Step;
				Player_X_Pos <= Player_X_Center; // change this to be level-start coordinates
				Player_Y_Pos <= Player_Y_Center; // each level will have it's own coordinates in the C code
				deathcount <= 8'b00000000;
        end
        else 
        begin	  	 
				 case (decoded_input)
					16'h0004 : begin	// moving left
								  Player_X_Motion <= ~Player_Speed + 1'b1;//A
								  Player_Y_Motion <= 0;
										// collision detection
								  if((bl_xpos[4:0] <= 5'b00001) && (bl_bound[0] == 1))
										flag_x = 1;
								  else if((tl_xpos[4:0] <= 5'b00001) && (tl_bound[0] == 1))
										flag_x = 1;
								  else
										flag_x = 0;
							  end
					        
					16'h0007 : begin	// moving right
								  Player_X_Motion <= Player_Speed;//D
								  Player_Y_Motion <= 0;
								  // collision detection
								  if((tr_xpos[4:0] >= 5'b11110) && (tr_bound[1] == 1))
										flag_x = 1;
								  else if((br_xpos[4:0] >= 5'b11110) && (br_bound[1] == 1))
										flag_x = 1;
								  else
										flag_x = 0;
							  end
							  
					16'h0016 : begin
								  Player_Y_Motion <= Player_Speed;//S
								  Player_X_Motion <= 0;
								  // moving down
								  if((bl_ypos[4:0] >= 5'b11110) && (bl_bound[3] == 1))
										flag_y = 1;
								  else if((br_ypos[4:0] >= 5'b11110) && (br_bound[3] == 1))
										flag_y = 1;
								  else
										flag_y = 0;
							  end
							  
					16'h001A : begin
								  Player_Y_Motion <= ~(Player_Speed) + 1'b1;//W
								  Player_X_Motion <= 0;
								  // moving up
								  if((tl_ypos[4:0] <= 5'b00001) && (tl_bound[2] == 1))
										flag_y = 1;
								  else if((tr_ypos[4:0] <= 5'b00001) && (tr_bound[2] == 1))
										flag_y = 1;
								  else
										flag_y = 0;
								  end
							 
					16'h1A04 : begin		// WA
								  Player_Y_Motion <= ~(Player_Speed) + 1'b1;
								  Player_X_Motion <= ~(Player_Speed) + 1'b1;
								  // moving up and to the left
								  // if up left movement causes top left to violate boundary in x or y direction
								  if((tl_xpos[4:0] <= 5'b00001) && (tl_bound[0] == 1))
										flag_x = 1;
								  // if left movement causes bottom left to violate x boundary
								  else if((bl_xpos[4:0] <= 5'b00001) && (bl_bound[0] == 1)) // bottom left moving left
										flag_x = 1;
								  else
										flag_x = 0;
									
								  if((tl_ypos[4:0] <= 5'b00001) && (tl_bound[2] == 1))
										flag_y = 1;
								  // if up movement causes top right to violate y boundary
								  else if((tr_ypos[4:0] <= 5'b00001) && (tr_bound[2] == 1)) // top right moving up
										flag_y = 1;
								  else
										flag_y = 0;
								  end
										
					16'h0416 : begin		// AS
								  Player_Y_Motion <= Player_Speed;
								  Player_X_Motion <= ~(Player_Speed) + 1'b1;
								  // moving down and to the left
								  // if down left movement causes bottom left to violate boundary in x or y direction
								  // bottom left moving down and left
								  if((bl_xpos[4:0] <= 5'b00001) && (bl_bound[0] == 1))
										flag_x = 1;
								  // if left movement causes top left to violate x boundary
								  else if((tl_xpos[4:0] <= 5'b00001) && (tl_bound[0] == 1))	// top left moving left
										flag_x = 1;
								  else
										flag_x = 0;
										
								  if((bl_ypos[4:0] >= 5'b11110) && (bl_bound[3] == 1))	
										flag_y = 1;
								  // if down movement causes bottom right to violate y boundary
								  else if((br_ypos[4:0] >= 5'b11110) && (br_bound[3] == 1)) // bottom right moving down
										flag_y = 1;
								  else
										flag_y = 0;
								  end
										
					16'h1607 : begin		// SD
								  Player_Y_Motion <= Player_Speed;
								  Player_X_Motion <= Player_Speed;
								  // moving down and to the right
								  // if right movement on bottom right violates boundary OR down movement violates boundary 
								  if((br_xpos[4:0] >= 5'b11110) && br_bound[1] == 1)
										flag_x = 1;
								  // if right movement causes top right to violate x boundary
								  else if ((tr_xpos[4:0] >= 5'b11110) && (tr_bound[1] == 1)) // top right moving right
										flag_x = 1;
								  else
										flag_x = 0;
								  // if down movement causes bottom left to violate y boundary
								  if ((bl_ypos[4:0] >= 5'b11110) && (bl_bound[3] == 1)) // bottom left moving down
										flag_y = 1;
								  else if((br_ypos[4:0] >= 5'b11110) && (br_bound [3] == 1))
								      flag_y = 1;
								  else
										flag_y = 0;
							     end
										
					16'h071A : begin		// DW
								  Player_Y_Motion <= ~(Player_Speed) + 1'b1;
								  Player_X_Motion <= Player_Speed;
								  // moving up and to the right
								  // if up right movement causes top right to violate boundary in x or y direction
								  if ((tr_xpos[4:0] >= 5'b11110) && (tr_bound[1] == 1))
										flag_x = 1;
								  // if right movement causes bottom right to violate x boundary
								  else if ((br_xpos[4:0] >= 5'b11110) && (br_bound[1] == 1)) // bottom right moving right
										flag_x = 1;
								  else
										flag_x = 0;
								  // if up movement causes top left to violate y boundary
								  if ((tl_ypos[4:0] <= 5'b00001) && (tl_bound[2] == 1)) // top left moving up
										flag_y = 1;
								  else if((tr_ypos[4:0] <= 5'b00001) && (tr_bound[2] == 1))
										flag_y = 1;
								  else
										flag_y = 0;
								  end
								  
							 
					default: begin		// no input
							  Player_Y_Motion <= 0;
							  Player_X_Motion <= 0;
							  end
			   endcase
				
				if(flag_y && flag_x)
				begin
					Player_Y_Pos = Player_Y_Pos;
					Player_X_Pos = Player_X_Pos;
				end
				
				else if(flag_x)
				begin
					Player_X_Pos = Player_X_Pos;
					Player_Y_Pos = (Player_Y_Pos + Player_Y_Motion);
				end
				
				else if(flag_y)
				begin
					Player_Y_Pos = Player_Y_Pos;
					Player_X_Pos = (Player_X_Pos + Player_X_Motion);
				end
				
				else
				begin
					Player_Y_Pos = (Player_Y_Pos + Player_Y_Motion);  // Update Player position
					Player_X_Pos = (Player_X_Pos + Player_X_Motion);
				end
			
			
	 
      
			
		end  
    end
       
    assign PlayerX = Player_X_Pos;
   
    assign PlayerY = Player_Y_Pos;
   
    assign PlayerS = Player_Size;
    
	 
	 keydecoder decoder(
							.keycode_in(keycode),
							.keycode_out(decoded_input)
						);

endmodule
