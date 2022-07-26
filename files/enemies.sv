module enemy (
					input Reset, frame_clk, input logic start_enemies,
					input [9:0] start_x, start_y, center_x, center_y,
					input [9:0] PlayerX, PlayerY, PlayerS,
					input [9:0] DrawX, DrawY,
					input direction,	// movement pattern forward (1) or reverse (0)
					input enable,
					input [3:0] speed,
					input [2:0] movement, // linear, square, or circular movement
					input [9:0] x_range,
					input [3:0] y_range,
					output collision,
					output print_enemy
);


	
	 logic [9:0] Enemy_X_Pos, Enemy_Y_Pos, Enemy_X_Motion, Enemy_Y_Motion, size;
	 logic switch;
	 
	 int DistX, DistY, DistX_draw, DistY_draw;
	 
	 parameter [9:0] Enemy_X_Start=420;  // temp values for object testing
    parameter [9:0] Enemy_Y_Start=180;

	 assign size = 8;
	 
	 logic flag, top, bottom, left, right;
	 
	 always_ff @ (posedge frame_clk or posedge start_enemies)
    begin: Move_Enemy
       if (start_enemies)  // Asynchronous Reset
       begin
			Enemy_X_Motion <= 10'd0;
			Enemy_Y_Motion <= 10'd0;
			Enemy_Y_Pos <= start_y; // 
			Enemy_X_Pos <= start_x; // start_x
       end
		  
		 else
		 begin
				case (movement)
					3'b000 : begin // linear movement in x-direction
										if (direction) // +x direction
										begin
											if (Enemy_X_Pos - start_x == 0) // Enemy has returned to starting point, sent it forward
												Enemy_X_Motion <= speed;
											else if (Enemy_X_Pos - start_x == x_range) // Enemy has reached the end of it's path, send it back
												Enemy_X_Motion <= (~(speed) + 1'b1);
										end
									
										else // -x direction
										begin
											if (start_x - Enemy_X_Pos == x_range) // Enemy has returned to starting point, sent it forward
												Enemy_X_Motion <= speed;
											else if (Enemy_X_Pos ==  start_x) // Enemy has reached the end of it's path, send it back
												Enemy_X_Motion <= (~(speed) + 1'b1);
										end
								end
								
					3'b100 : begin // linear movement in +y-direction
										if (direction) // +y direction, going up on monitor  
										begin
											if (Enemy_Y_Pos == start_y) // Enemy has returned to starting point, sent it forward
												Enemy_Y_Motion <= ~(speed) + 1'b1; //Computer thinks negative is up
											else if (start_y - Enemy_Y_Pos == x_range) // Enemy has reached the end of it's path, send it back
												Enemy_Y_Motion <= speed;
										end
									
										else // -y direction, going down down monitor
										begin
											if (Enemy_Y_Pos == start_y) // Enemy has returned to starting point, sent it forward
												Enemy_Y_Motion <= speed;
											else if (Enemy_Y_Pos - start_y == x_range) // Enemy has reached the end of it's path, send it back
												Enemy_Y_Motion <= (~(speed) + 1'b1);
										end
								  end
									
						default: begin		// no movement
									Enemy_Y_Motion <= 0;
									Enemy_X_Motion <= 0;
									end
					3'b001 : begin // rectangle movement, tracking center point and storing x_range as tile index
                                        if (direction) // clockwise movement
                                        begin // starting at top left corner of pattern
                                            if (Enemy_X_Pos <= center_x - x_range<<5 + 8'h10) //This is equivalent logic
														  // On the left side of the square pattern - 1'hF
                                            begin
																left = 1'b1;
                                                if (Enemy_Y_Pos <= (center_y - y_range<<5)) //This is equivalent logic
                                                begin
                                                    Enemy_X_Motion <= speed; // send enemy in +x direction + 1'hF
                                                    Enemy_Y_Motion <= 0;
                                                end
                                                
                                                else if (Enemy_Y_Pos >= center_y + y_range<<5) //This is equivalent logic
																// at bottom left corner of pattern - 1'hF
                                                begin
                                                    Enemy_Y_Motion <= (~(speed) + 1'b1); // send in -y direction (up)
                                                    Enemy_X_Motion <= 0;
                                                end
                                            end
														  
                                          else if (Enemy_Y_Pos <= center_y - y_range<<5) //This is equivalent logic
														  // On the top of the square pattern
                                            begin
																top = 1'b1;

                                                if (Enemy_X_Pos < (center_x + x_range<<5 + 8'h10)) //This is equivalent logic
                                                begin
                                                    Enemy_X_Motion <= speed; // send enemy in +x direction + 1'hF
                                                    Enemy_Y_Motion <= 0;
                                                end
                                                
                                                
                                            end 
														  
														else if (Enemy_Y_Pos <= center_y - y_range<<5) //This is equivalent logic
														begin  // On the bottom of the square pattern
																bottom = 1'b1;
																
                                                if (Enemy_X_Pos > (center_x - x_range<<5 - 8'h10)) //This is equivalent logic
                                                begin
                                                    Enemy_X_Motion <= (~(speed) + 1'b1); // send enemy in +x direction + 1'hF
                                                    Enemy_Y_Motion <= 0;
                                                end
                                                
                                                else if (Enemy_X_Pos <= (center_x - x_range<<5 - 8'h10)) //This is equivalent logic
																// at bottom left corner of pattern - 1'hF
                                                begin
                                                    Enemy_Y_Motion <= (~(speed) + 1'b1); // send in -y direction (up)
                                                    Enemy_X_Motion <= 0;
                                                end
                                            end			  
														else if (Enemy_X_Pos - center_x >= x_range<<5+ 8'h10) //this seems like proper logic but shits fucked
														// Enemy is on right side of square pattern - 1'hF
                                            begin
																right = 1'b1;
                                                if (Enemy_Y_Pos <= center_y - y_range<<5)  //FUCKKK
																// Enemy is at top right corner of pattern - 1'hF
                                                begin
                                                    Enemy_Y_Motion <= speed; // Send enemy in +y direction (down)
                                                    Enemy_X_Motion <= 0; // Cancel x velocity
                                                end
                                                
                                                else if (Enemy_Y_Pos - center_y >= y_range<<5) // Enemy is at bottom right corner of pattern
                                                begin
                                                    Enemy_X_Motion <= (~(speed) + 1'b1); // send in -x direction- 1'hF
                                                    Enemy_Y_Motion <= 0;
                                                end
                                            end
                                        end
                                        
                                        
                                        
                                        else // counter-clockwise movement
                                        begin // starting at top left corner of pattern
                                            if (Enemy_X_Pos <= start_x) // On the left side of the square pattern
                                            begin
                                                if (Enemy_Y_Pos <= start_y)
                                                begin
                                                    Enemy_X_Motion <= 0; // send enemy in +y direction (down)
                                                    Enemy_Y_Motion <= speed;
                                                end
                                                
                                                else if (Enemy_Y_Pos - start_y >= x_range)// Enemy is on bottom left corner
                                                begin
                                                    Enemy_Y_Motion <= 0;
                                                    Enemy_X_Motion <= speed; // send in +x direction
                                                end
                                            end
                                                
                                            else if (Enemy_X_Pos - start_x >= x_range) // Enemy is on right side of square pattern
                                            begin
                                                if (Enemy_Y_Pos <= start_y) // Enemy is at top right corner of pattern
                                                begin
                                                    Enemy_Y_Motion <= 0;
                                                    Enemy_X_Motion <= (~(speed) + 1'b1); // Send enemy in -x direction
                                                end
                                                
                                                else if (Enemy_Y_Pos - start_y >= x_range)// Enemy is at bottom right corner of pattern
                                                begin
                                                    Enemy_X_Motion <= 0;
                                                    Enemy_Y_Motion <= (~(speed) + 1'b1); // send in -y direction (up)
                                                end
                                            end
                                        end
                                end				
				endcase
				
				Enemy_Y_Pos = Enemy_Y_Pos + Enemy_Y_Motion;
				Enemy_X_Pos = Enemy_X_Pos + Enemy_X_Motion;
		 end
	 end
	 
	 always_comb
	 begin: player_collision
		DistX = PlayerX - Enemy_X_Pos;
		DistY = PlayerY - Enemy_Y_Pos;
		if ((DistX*DistX + DistY*DistY < (PlayerS*PlayerS / 2)) && enable)
			collision = 1;
		else
			collision = 0;
	 end
	 
	 always_comb
	 begin: Enemy_on_proc
		DistX_draw = DrawX - Enemy_X_Pos;
		DistY_draw = DrawY - Enemy_Y_Pos;
		if (((DistX_draw*DistX_draw + DistY_draw*DistY_draw) < (size*size)) && enable)
			print_enemy = 1;
		else
			print_enemy = 0;
	end

endmodule