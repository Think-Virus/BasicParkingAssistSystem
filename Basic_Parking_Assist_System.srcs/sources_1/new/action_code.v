module  action_code(ASCII_code, action );
input [7:0] ASCII_code;
output [3:0]action;
reg [3:0] action;

always @ (ASCII_code)
	begin
		case(ASCII_code)
			8'b00110001: action = 4'b0001; //Forward if ASCII_code =8'b00110001,action =4'b0001 -> 31 
			8'b00110010: action = 4'b0010; //Back 	if ASCII_code =8'b00110010,action =4'b0010 -> 32
			default: action = 4'b0000;
		endcase
	end 
endmodule
