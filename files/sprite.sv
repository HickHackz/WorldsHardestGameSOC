module sprite ( 
					input [9:0] DrawX, DrawY, input [6:0] keycode,
					output logic flag,
					output logic [9:0] Sprite_X_Pos, Sprite_Y_Pos);
					
			
   
	 
	 //assign offset_x = DrawX - 2'd48;
	 assign Sprite_X_Pos[9:3] = DrawX[9:3]; //because of the backporch
	 assign Sprite_X_Pos[2:0] = 3'b000;
	// assign offset_y =  - 2'd48;
	 assign Sprite_Y_Pos[9:4] = DrawY[9:4];
	 assign Sprite_Y_Pos[3:0] = 4'b0000;

	 
endmodule
	