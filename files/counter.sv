module counter (input Clk, vs, no_update, Reset,
					 input initialize_level, new_level,
					 output reg[5:0] out, output logic write_begin, output logic new_level2, output logic new_level3, output wire clkdiv);
					 


always_ff @ (posedge new_level or posedge vs )
begin
    if (new_level)
        new_level2 <= 1;
    else
        new_level2 <= 0;
end

logic update_previous;

always_ff @ (posedge Clk)
begin
	
	if (update_previous !== no_update)
		new_level3 = 1;
	else
		new_level3 = 0;
		
	update_previous <= no_update;
		
end


						

	
always_ff @ (posedge Clk or posedge Reset )
    begin 
        if (Reset) 
            clkdiv <= 1'b0;
        else 
            clkdiv <= ~ (clkdiv);
    end

	 
always @ (posedge Clk) 
begin
	if ((initialize_level || new_level2) && !write_begin)
	begin
		write_begin = 1;
		out <= 0;
	end
	
	else if (out == 6'b111111)
	begin
		
		write_begin = 0;
	end
	
	else
	begin
		out <= out + 1;
	end
	
	
end
endmodule




