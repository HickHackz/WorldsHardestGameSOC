




module obstacle_controller (
	input Clk, pixel_clk, vs,
    // Avalon Reset Input
    input logic RESET,
    input  logic AVL_WRITE,                    // Avalon-MM Write
    input  logic [3:0] AVL_BYTE_EN,            // Avalon-MM Byte Enable
    input  [10:0] AVL_ADDR,    // Avalon-MM Address
    input  logic [31:0] AVL_WRITEDATA,        // Avalon-MM Write Data
    input  new_level, initialize_level,
	 input [9:0] SW_in, //switches to lead specified level
    input [9:0] DrawX, DrawY, PlayerX, PlayerY, PlayerS,
    output dead, print_enemy, new_level2, new_level3
	);
	logic [5:0] count;
	wire write_begin, clkdiv;
	logic [31:0] enemy_mark; //32-bit number each enemy sends it's print enable bit to, AND with 32 1's to see if any enemy is here
   logic [31:0] collision_mark;
	
	counter c1 (.clkdiv(clkdiv), .Reset(RESET), .new_level2(new_level2), .Clk(pixel_clk), .vs(vs), .initialize_level(initialize_level), .new_level(new_level), .out(count), .write_begin(write_begin), .no_update(no_update), .new_level3(new_level3));
	
	//sync enm_ctrl (.Clk(vs), .d(initialize_level), .q(test));
	
	logic [31:0] read_data;
	logic [10:0] mod_addr, read_addr;
	assign mod_addr = AVL_ADDR & 11'b01111111111; //This clears the last address bit for new obstacle addressing
	
	obstacle2_memory ram1 (.clock(Clk), .address(read_addr), .q(read_data));
						
						
	logic [9:0] start_x [31:0], start_y [31:0], center_x [31:0], x_range [31:0], center_y [31:0];
	logic enable [31:0], direction [31:0];
	logic [2:0] movement [31:0];
	logic [3:0] speed [31:0], y_range [31:0];
	
	
	logic [9:0] level_offset;
	
	always_comb
	begin: Collision_check
		if((collision_mark & 32'hffffffff) != 0)	// Did any enemy report contact with the player?
			dead = 1'b1;	// Player got hit and is dead
		else
			dead = 1'b0;	// No enemy has reported hitting player
	end
	
	always_comb
	begin: Enemy_on_proc
		if((enemy_mark & 32'hffffffff) != 0)
			print_enemy = 1'b1;
		else
			print_enemy = 1'b0;
	end
	
	
	always_ff @ (posedge RESET or posedge initialize_level or posedge no_update or posedge new_level)
	begin
		if (RESET)
		begin
			level_offset = 10'h000;
		end
		else if (initialize_level)
		begin
         level_offset = 10'h000;
		end
		else if (no_update)
		begin
		   level_offset = level_offset;
		end
		else if (new_level)
		begin
			level_offset = 10'h040 + level_offset;
		end
		else
		begin
			level_offset = level_offset;
		end
		
	end	
	
	 
	logic no_update;
	always_comb
	begin
		unique case (SW_in)
		
		
			10'b0000000001 : begin 
									read_addr = count;
									no_update = 1'b1;
									//current_level = 1;
								  end
								
			10'b0000000010 : begin 
									read_addr = count + 8'h40;
									no_update = 1'b1;
									//current_level = 2;
								  end
								  
			10'b0000000100 : begin 
									read_addr = count + 8'h80;
									no_update = 1'b1;
									//current_level = 3;
								  end
								  
			10'b0000001000 : begin 
									read_addr = count + 8'hc0;
									no_update = 1'b1;
									//current_level = 4;
								  end
								  
			10'b0000010000 : begin 
									read_addr = count + 12'h100;
									no_update = 1'b1;
									//current_level = 5;
								  end
								  
			10'b0000100000 : begin 
									read_addr = count + 12'h140;
									no_update = 1'b1;
									//current_level = 6;
								  end
								  
			10'b0001000000 : begin 
									read_addr = count + 12'h180;
									no_update = 1'b1;
									//current_level = 7;
								  end
								  
			10'b0010000000 : begin 
									read_addr = count + 12'h1c0;
									no_update = 1'b1;
									//current_level = 8;
								  end				  
						
			10'b0100000000 : begin 
									read_addr = count + 12'h200;
									no_update = 1'b1;
									//current_level = 9;
								  end
								  
			10'b1000000000 : begin 
									read_addr = count + 12'h240;
									no_update = 1'b1;
									//current_level = 10;
								  end			
			default: 		  begin		
									read_addr = count + level_offset;
									no_update = 1'b0;
									
								  end
		endcase
	
	end
	 
	 
	 
	
	always_ff @(posedge pixel_clk) //or level_offset
    begin
        if (new_level2 || initialize_level) // May only write to enemy 0-15
        begin
            if (count[0] == 0)
            begin
                start_x[count>>1] = read_data[9:0];
                start_y[count>>1] = read_data[19:10];
                center_x[count>>1] = read_data[29:20];
                enable[count>>1] = read_data[30];
            end
            else
            begin
                center_y[count>>1] = read_data[9:0];
                x_range[count>>1] = read_data[19:10];
                movement[count>>1] = read_data[22:20];
                direction[count>>1] = read_data[23];
                speed[count>>1] = read_data[27:24];
					 y_range[count>>1] = read_data[31:28];
            end

        end
    end
				
	enemy enemy0(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[0]), 
                    .start_y(start_y[0]), 
                    .center_x(center_x[0]), 
                    .center_y(center_y[0]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[0]),
                    .enable(enable[0]),
                    .speed(speed[0]),
                    .movement(movement[0]),
                    .x_range(x_range[0]),
						  .y_range(y_range[0]),
                    .collision(collision_mark[0]),
                    .print_enemy(enemy_mark[0]),
                    .start_enemies(write_begin)
                );
				
	enemy enemy1(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[1]), 
                    .start_y(start_y[1]), 
                    .center_x(center_x[1]), 
                    .center_y(center_y[1]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[1]),
                    .enable(enable[1]),
                    .speed(speed[1]),
                    .movement(movement[1]),
                    .x_range(x_range[1]),
						  .y_range(y_range[1]),
                    .collision(collision_mark[1]),
                    .print_enemy(enemy_mark[1]),
                    .start_enemies(write_begin)
                );
				
	enemy enemy2(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[2]), 
                    .start_y(start_y[2]), 
                    .center_x(center_x[2]), 
                    .center_y(center_y[2]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[2]),
                    .enable(enable[2]),
                    .speed(speed[2]),
                    .movement(movement[2]),
                    .x_range(x_range[2]),
						  .y_range(y_range[2]),
                    .collision(collision_mark[2]),
                    .print_enemy(enemy_mark[2]),
                    .start_enemies(write_begin)
                );
					 
	enemy enemy3(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[3]), 
                    .start_y(start_y[3]), 
                    .center_x(center_x[3]), 
                    .center_y(center_y[3]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[3]),
                    .enable(enable[3]),
                    .speed(speed[3]),
                    .movement(movement[3]),
                    .x_range(x_range[3]),
						  .y_range(y_range[3]),
                    .collision(collision_mark[3]),
                    .print_enemy(enemy_mark[3]),
                    .start_enemies(write_begin)
                );
	
	enemy enemy4(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[4]), 
                    .start_y(start_y[4]), 
                    .center_x(center_x[4]), 
                    .center_y(center_y[4]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[4]),
                    .enable(enable[4]),
                    .speed(speed[4]),
                    .movement(movement[4]),
                    .x_range(x_range[4]),
						  .y_range(y_range[4]),
                    .collision(collision_mark[4]),
                    .print_enemy(enemy_mark[4]),
                    .start_enemies(write_begin)
                );
							
				
	enemy enemy5(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[5]), 
                    .start_y(start_y[5]), 
                    .center_x(center_x[5]), 
                    .center_y(center_y[5]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[5]),
                    .enable(enable[5]),
                    .speed(speed[5]),
                    .movement(movement[5]),
                    .x_range(x_range[5]),
						  .y_range(y_range[5]),
                    .collision(collision_mark[5]),
                    .print_enemy(enemy_mark[5]),
                    .start_enemies(write_begin)
                );
	enemy enemy6(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[6]), 
                    .start_y(start_y[6]), 
                    .center_x(center_x[6]), 
                    .center_y(center_y[6]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[6]),
                    .enable(enable[6]),
                    .speed(speed[6]),
                    .movement(movement[6]),
                    .x_range(x_range[6]),
						  .y_range(y_range[6]),
                    .collision(collision_mark[6]),
                    .print_enemy(enemy_mark[6]),
                    .start_enemies(write_begin)
                );
					 
	enemy enemy7(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[7]), 
                    .start_y(start_y[7]), 
                    .center_x(center_x[7]), 
                    .center_y(center_y[7]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[7]),
                    .enable(enable[7]),
                    .speed(speed[7]),
                    .movement(movement[7]),
                    .x_range(x_range[7]),
						  .y_range(y_range[7]),
                    .collision(collision_mark[7]),
                    .print_enemy(enemy_mark[7]),
                    .start_enemies(write_begin)
                );
	
	enemy enemy8(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[8]), 
                    .start_y(start_y[8]), 
                    .center_x(center_x[8]), 
                    .center_y(center_y[8]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[8]),
                    .enable(enable[8]),
                    .speed(speed[8]),
                    .movement(movement[8]),
                    .x_range(x_range[8]),
						  .y_range(y_range[8]),
                    .collision(collision_mark[8]),
                    .print_enemy(enemy_mark[8]),
                    .start_enemies(write_begin)
                );
	
	enemy enemy9(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[9]), 
                    .start_y(start_y[9]), 
                    .center_x(center_x[9]), 
                    .center_y(center_y[9]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[9]),
                    .enable(enable[9]),
                    .speed(speed[9]),
                    .movement(movement[9]),
                    .x_range(x_range[9]),
						  .y_range(y_range[9]),
                    .collision(collision_mark[9]),
                    .print_enemy(enemy_mark[9]),
                    .start_enemies(write_begin)
                );
	
	enemy enemy10(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[10]), 
                    .start_y(start_y[10]), 
                    .center_x(center_x[10]), 
                    .center_y(center_y[10]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[10]),
                    .enable(enable[10]),
                    .speed(speed[10]),
                    .movement(movement[10]),
                    .x_range(x_range[10]),
						  .y_range(y_range[10]),
                    .collision(collision_mark[10]),
                    .print_enemy(enemy_mark[10]),
                    .start_enemies(write_begin)
                );
	
	enemy enemy11(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[11]), 
                    .start_y(start_y[11]), 
                    .center_x(center_x[11]), 
                    .center_y(center_y[11]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[11]),
                    .enable(enable[11]),
                    .speed(speed[11]),
                    .movement(movement[11]),
                    .x_range(x_range[11]),
						  .y_range(y_range[11]),
                    .collision(collision_mark[11]),
                    .print_enemy(enemy_mark[11]),
                    .start_enemies(write_begin)
                );
	
	enemy enemy12(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[12]), 
                    .start_y(start_y[12]), 
                    .center_x(center_x[12]), 
                    .center_y(center_y[12]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[12]),
                    .enable(enable[12]),
                    .speed(speed[12]),
                    .movement(movement[12]),
                    .x_range(x_range[12]),
						  .y_range(y_range[12]),
                    .collision(collision_mark[12]),
                    .print_enemy(enemy_mark[12]),
                    .start_enemies(write_begin)
                );
	
	enemy enemy13(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[13]), 
                    .start_y(start_y[13]), 
                    .center_x(center_x[13]), 
                    .center_y(center_y[13]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[13]),
                    .enable(enable[13]),
                    .speed(speed[13]),
                    .movement(movement[13]),
                    .x_range(x_range[13]),
						  .y_range(y_range[13]),
                    .collision(collision_mark[13]),
                    .print_enemy(enemy_mark[13]),
                    .start_enemies(write_begin)
                );
	
	enemy enemy14(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[14]), 
                    .start_y(start_y[14]), 
                    .center_x(center_x[14]), 
                    .center_y(center_y[14]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[14]),
                    .enable(enable[14]),
                    .speed(speed[14]),
                    .movement(movement[14]),
                    .x_range(x_range[14]),
						  .y_range(y_range[14]),
                    .collision(collision_mark[14]),
                    .print_enemy(enemy_mark[14]),
                    .start_enemies(write_begin)
                );
	
	enemy enemy15(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[15]), 
                    .start_y(start_y[15]), 
                    .center_x(center_x[15]), 
                    .center_y(center_y[15]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[15]),
                    .enable(enable[15]),
                    .speed(speed[15]),
                    .movement(movement[15]),
                    .x_range(x_range[15]),
						  .y_range(y_range[15]),
                    .collision(collision_mark[15]),
                    .print_enemy(enemy_mark[15]),
                    .start_enemies(write_begin)
                );
	
	enemy enemy16(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[16]), 
                    .start_y(start_y[16]), 
                    .center_x(center_x[16]), 
                    .center_y(center_y[16]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[16]),
                    .enable(enable[16]),
                    .speed(speed[16]),
                    .movement(movement[16]),
                    .x_range(x_range[16]),
						  .y_range(y_range[16]),
                    .collision(collision_mark[16]),
                    .print_enemy(enemy_mark[16]),
                    .start_enemies(write_begin)
                );
	
	enemy enemy17(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[17]), 
                    .start_y(start_y[17]), 
                    .center_x(center_x[17]), 
                    .center_y(center_y[17]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[17]),
                    .enable(enable[17]),
                    .speed(speed[17]),
                    .movement(movement[17]),
                    .x_range(x_range[17]),
						  .y_range(y_range[17]),
                    .collision(collision_mark[17]),
                    .print_enemy(enemy_mark[17]),
                    .start_enemies(write_begin)
                );
	
	
	enemy enemy18(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[18]), 
                    .start_y(start_y[18]), 
                    .center_x(center_x[18]), 
                    .center_y(center_y[18]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[18]),
                    .enable(enable[18]),
                    .speed(speed[18]),
                    .movement(movement[18]),
                    .x_range(x_range[18]),
						  .y_range(y_range[19]),
                    .collision(collision_mark[18]),
                    .print_enemy(enemy_mark[18]),
                    .start_enemies(write_begin)
                );
					 
	enemy enemy19(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[19]), 
                    .start_y(start_y[19]), 
                    .center_x(center_x[19]), 
                    .center_y(center_y[19]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[19]),
                    .enable(enable[19]),
                    .speed(speed[19]),
                    .movement(movement[19]),
                    .x_range(x_range[19]),
						  .y_range(y_range[19]),
                    .collision(collision_mark[19]),
                    .print_enemy(enemy_mark[19]),
                    .start_enemies(write_begin)
                );
	
	enemy enemy20(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[20]), 
                    .start_y(start_y[20]), 
                    .center_x(center_x[20]), 
                    .center_y(center_y[20]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[20]),
                    .enable(enable[20]),
                    .speed(speed[20]),
                    .movement(movement[20]),
                    .x_range(x_range[20]),
						  .y_range(y_range[20]),
                    .collision(collision_mark[20]),
                    .print_enemy(enemy_mark[20]),
                    .start_enemies(write_begin)
                );
	
	enemy enemy21(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[21]), 
                    .start_y(start_y[21]), 
                    .center_x(center_x[21]), 
                    .center_y(center_y[21]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[21]),
                    .enable(enable[21]),
                    .speed(speed[21]),
                    .movement(movement[21]),
                    .x_range(x_range[21]),
						  .y_range(y_range[21]),
                    .collision(collision_mark[21]),
                    .print_enemy(enemy_mark[21]),
                    .start_enemies(write_begin)
                );
	
	enemy enemy22(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[22]), 
                    .start_y(start_y[22]), 
                    .center_x(center_x[22]), 
                    .center_y(center_y[22]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[22]),
                    .enable(enable[22]),
                    .speed(speed[22]),
                    .movement(movement[22]),
                    .x_range(x_range[22]),
						  .y_range(y_range[22]),
                    .collision(collision_mark[22]),
                    .print_enemy(enemy_mark[22]),
                    .start_enemies(write_begin)
                );
	
	enemy enemy23(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[23]), 
                    .start_y(start_y[23]), 
                    .center_x(center_x[23]), 
                    .center_y(center_y[23]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[23]),
                    .enable(enable[23]),
                    .speed(speed[23]),
                    .movement(movement[23]),
                    .x_range(x_range[23]),
						  .y_range(y_range[23]),
                    .collision(collision_mark[23]),
                    .print_enemy(enemy_mark[23]),
                    .start_enemies(write_begin)
                );
	
	enemy enemy24(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[24]), 
                    .start_y(start_y[24]), 
                    .center_x(center_x[24]), 
                    .center_y(center_y[24]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[24]),
                    .enable(enable[24]),
                    .speed(speed[24]),
                    .movement(movement[24]),
                    .x_range(x_range[24]),
						  .y_range(y_range[24]),
                    .collision(collision_mark[24]),
                    .print_enemy(enemy_mark[24]),
                    .start_enemies(write_begin)
                );
	
	enemy enemy25(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[25]), 
                    .start_y(start_y[25]), 
                    .center_x(center_x[25]), 
                    .center_y(center_y[25]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[25]),
                    .enable(enable[25]),
                    .speed(speed[25]),
                    .movement(movement[25]),
                    .x_range(x_range[25]),
						  .y_range(y_range[25]),
                    .collision(collision_mark[25]),
                    .print_enemy(enemy_mark[25]),
                    .start_enemies(write_begin)
                );
	
	enemy enemy26(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[26]), 
                    .start_y(start_y[26]), 
                    .center_x(center_x[26]), 
                    .center_y(center_y[26]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[26]),
                    .enable(enable[26]),
                    .speed(speed[26]),
                    .movement(movement[26]),
                    .x_range(x_range[26]),
						  .y_range(y_range[26]),
                    .collision(collision_mark[26]),
                    .print_enemy(enemy_mark[26]),
                    .start_enemies(write_begin)
                );
	
	enemy enemy27(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[27]), 
                    .start_y(start_y[27]), 
                    .center_x(center_x[27]), 
                    .center_y(center_y[27]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[27]),
                    .enable(enable[27]),
                    .speed(speed[27]),
                    .movement(movement[27]),
                    .x_range(x_range[27]),
						  .y_range(y_range[27]),
                    .collision(collision_mark[27]),
                    .print_enemy(enemy_mark[27]),
                    .start_enemies(write_begin)
                );
	
	enemy enemy28(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[28]), 
                    .start_y(start_y[28]), 
                    .center_x(center_x[28]), 
                    .center_y(center_y[28]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[28]),
                    .enable(enable[28]),
                    .speed(speed[28]),
                    .movement(movement[28]),
                    .x_range(x_range[28]),
						  .y_range(y_range[28]),
                    .collision(collision_mark[28]),
                    .print_enemy(enemy_mark[28]),
                    .start_enemies(write_begin)
                );
	
	enemy enemy29(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[29]), 
                    .start_y(start_y[29]), 
                    .center_x(center_x[29]), 
                    .center_y(center_y[29]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[29]),
                    .enable(enable[29]),
                    .speed(speed[29]),
                    .movement(movement[29]),
                    .x_range(x_range[29]),
						  .y_range(y_range[29]),
                    .collision(collision_mark[29]),
                    .print_enemy(enemy_mark[29]),
                    .start_enemies(write_begin)
                );
	
	enemy enemy30(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[30]), 
                    .start_y(start_y[30]), 
                    .center_x(center_x[30]), 
                    .center_y(center_y[30]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[30]),
                    .enable(enable[30]),
                    .speed(speed[30]),
                    .movement(movement[30]),
                    .x_range(x_range[30]),
						  .y_range(y_range[30]),
                    .collision(collision_mark[30]),
                    .print_enemy(enemy_mark[30]),
                    .start_enemies(write_begin)
                );
	
	enemy enemy31(
                    .Reset(RESET),
                    .frame_clk(vs),
                    .start_x(start_x[31]), 
                    .start_y(start_y[31]), 
                    .center_x(center_x[31]), 
                    .center_y(center_y[31]),
                    .PlayerX(PlayerX), 
                    .PlayerY(PlayerY), 
                    .PlayerS(PlayerS),
                    .DrawX(DrawX), 
                    .DrawY(DrawY),
                    .direction(direction[31]),
                    .enable(enable[31]),
                    .speed(speed[31]),
                    .movement(movement[31]),
                    .x_range(x_range[31]),
						  .y_range(y_range[31]),
                    .collision(collision_mark[31]),
                    .print_enemy(enemy_mark[31]),
                    .start_enemies(write_begin)
                );
					 
	
	endmodule
	
