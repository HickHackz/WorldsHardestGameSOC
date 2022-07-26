module add3(in,out);
input [3:0] in;
output [3:0] out;
reg [3:0] out;

always @ (in)
    case (in)
    4'b0000: out <= 4'b0000;  // 0 -> 0
    4'b0001: out <= 4'b0001;
    4'b0010: out <= 4'b0010;
    4'b0011: out <= 4'b0011; 
    4'b0100: out <= 4'b0100;  // 4 -> 4
    4'b0101: out <= 4'b1000;  // 5 -> 8
    4'b0110: out <= 4'b1001;  
    4'b0111: out <= 4'b1010;
    4'b1000: out <= 4'b1011;
    4'b1001: out <= 4'b1100;  // 9 -> 12
    default: out <= 4'b0000;
    endcase
endmodule