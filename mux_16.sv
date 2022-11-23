module mux2to1
					#(parameter width = 16)
					(input [width-1:0] Zero, One,
					input Select,
					output logic [width-1:0] Out);

always_comb
begin
	if (Select)
		Out = One;
	else
		Out = Zero;
end

endmodule

module mux3to1
					#(parameter width = 16)
					(input [width-1:0] Zero, One, Two,
					input [1:0] Select,
					output logic [width-1:0] Out);

always_comb
begin
	case (Select[1:0])
	2'b00:	Out = Zero;
	2'b01:	Out = One;
	2'b10:	Out = Two;
	default:	Out = 16'bX;
	endcase
end

endmodule

module mux4to1
					#(parameter width = 16)
					(input [width-1:0] Zero, One, Two, Three,
					input [1:0] Select,
					output logic [width-1:0] Out);

always_comb
begin
	case (Select[1:0])
	2'b00:	Out = Zero;
	2'b01:	Out = One;
	2'b10:	Out = Two;
	2'b11: 	Out = Three;
	default:	Out = 16'bX;
	endcase
end

endmodule
