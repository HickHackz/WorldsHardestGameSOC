module  color_mapper (input blank, print_enemy, print_coin,
                      input logic [2:0] blockcode, 
							 input logic [3:0] boundaries,
                      input [9:0] PlayerX, PlayerY, DrawX, DrawY, Player_size,
                      output logic [3:0]  Red, Green, Blue );
    // Boundary and player variables
    logic bound;
    logic Player_Red, Player_Black;
	 // Variables related to the player's geometry
    int DistX, DistY, Size;
    assign DistX = DrawX - PlayerX;
    assign DistY = DrawY - PlayerY;
    assign Size = Player_size;
    
	 
	 // Enable pixel to display the player
    always_comb
    begin:Player_on_proc
        if ((DistX*DistX <= Size*Size/4) && (DistY*DistY <= Size*Size/4)) // The inner red area of the player
        begin
            if ((DistX*DistX >= Size*Size/4-50) || (DistY*DistY >= Size*Size/4-50)) // The outer black edges of the player
            begin
                Player_Black = 1; // Enable signal to print pixel as player's black edge
                Player_Red = 0;
            end
                
            else
            begin
                Player_Black = 0;
                Player_Red = 1;	// Enable signal to print pixel as player's inner red area
            end
        end
        else		// Not within the bounds of the player, do not enable player print signal
          begin 
            Player_Black = 0;
                Player_Red = 0;
          end
     end
	 // Enables the pixel we're on to be printed as a boundary
    always_comb
    begin:Boundary_enable
    
        if (boundaries[0] && ((DrawX[4:1] == 0)))
            bound = 1;
            
        else if (boundaries[1] && ((DrawX[4:1] == 4'b1111)))
            bound = 1;
        else if (boundaries[2] && ((DrawY[4:1] == 0)))
            bound = 1;
        else if (boundaries[3] && ((DrawY[4:1] == 4'b1111)))
            bound = 1;
        else
            bound = 0;
    end
	 
	 /* Need code to set enable for pixels enemies are located at
	 
	 */
	 
	// Decide which type of pixel to print here
   always_comb
   begin:RGB_Display
     
        if (!blank)	// If blank signal is off (blank is active low) print black
        begin
            Red = 4'b0000;
            Green = 4'b0000;
            Blue = 4'b0000;
        end
		  else if (print_coin) 
        begin
                Red = 4'hf;   // red and green gives us a banana sort of color for our coins
                Green = 4'hf;
                Blue = 4'h0;
        end
		  else if (print_enemy)
		  begin
				Red = 4'h0;
				Green = 4'h0;
				Blue = 4'hf;
		  end
		  
        else if (bound) // If the pixel is a boundary, print black
        begin
            Red = 4'b0000;
            Green = 4'b0000;
            Blue = 4'b0000;
        end
        
        else if(Player_Black == 1'b1) // If the pixel is marked as the player's edge, print black
        begin
            Red = 4'h0;
            Green = 4'h0;
            Blue = 4'h0;
        end
        
        else if (Player_Red == 1'b1) // If pixel is player's inner body, print red
        begin
            Red = 4'hf;
            Green = 4'h0;
            Blue = 4'h0;
        end
		  
		  /*
		  else if (enemy_on)
			 RGB is dark blue
		  */
        
        // If none of the above, then the pixel is just a game tile
        else
        begin
            if ((blockcode == 3'b000)) //ghost white, actual RGB = #F8F7FF
				begin
					Red = 4'b1110;
					Green = 4'b1110;
					Blue = 4'b1111;
				end
            
            else if ((blockcode == 3'b011) || (blockcode == 3'b100)) //pale green, actual RGB = #9FF2A1
				begin
					Red = 4'b1001;
					Green = 4'b1110;
				   Blue = 4'b1001;
				end
            
            else if (blockcode == 3'b001) //plale lavender, actual RGB = #E0DAFC
				begin
					Red = 4'b1101;
					Green = 4'b1101;
					Blue = 4'b1111;
				end
            
            else if (blockcode == 3'b010) //bright lavender, actual RGB = #AAA5FB
				begin
					Red = 4'b1010;
					Green = 4'b1010;
					Blue = 4'b1111;
				end
        
            else
				begin
					Red = 4'b0000;
					Green = 4'b0000;
					Blue = 4'b0000;

				end
        end
    end
    
endmodule