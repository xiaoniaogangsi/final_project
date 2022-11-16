module palette(input logic [3:0] color,
					output logic istransparent,
					output logic [7:0]  Red, Green, Blue);
//The palette module is used to map the color index into RGB values
//The colors used in the project includes:
//0:	'0x800080', (purple, which represents transparent pixel)
//1:	'0xEFEFEF', 
//2:	'0xF0F0F0', 
//3:	'0xF6F6F6', 
//4:	'0xF7F7F7', 
//5:	'0xF8F8F8', 
//6:	'0xFEFEFE', 
//7:	'0xFFFFFF', 
//8:	'0x535353', 
//9:	'0xB9B9B9', 
//a:	'0xDADADA'				
	always_comb
	begin
		case (color)
			4'h0:
			begin
				Red = 8'h80;
				Green = 8'h00;
				Blue = 8'h80;
				istransparent = 1'b1;
			end
			4'h1:
			begin
				Red = 8'hEF;
				Green = 8'hEF;
				Blue = 8'hEF;
				istransparent = 1'b0;
			end
			4'h2:
			begin
				Red = 8'hF0;
				Green = 8'hF0;
				Blue = 8'hF0;
				istransparent = 1'b0;
			end
			4'h3:
			begin
				Red = 8'hF6;
				Green = 8'hF6;
				Blue = 8'hF6;
				istransparent = 1'b0;
			end
			4'h4:
			begin
				Red = 8'hF7;
				Green = 8'hF7;
				Blue = 8'hF7;
				istransparent = 1'b0;
			end
			4'h5:
			begin
				Red = 8'hF8;
				Green = 8'hF8;
				Blue = 8'hF8;
				istransparent = 1'b0;
			end
			4'h6:
			begin
				Red = 8'hFE;
				Green = 8'hFE;
				Blue = 8'hFE;
				istransparent = 1'b0;
			end
			4'h7:
			begin
				Red = 8'hFF;
				Green = 8'hFF;
				Blue = 8'hFF;
				istransparent = 1'b0;
			end
			4'h8:
			begin
				Red = 8'h53;
				Green = 8'h53;
				Blue = 8'h53;
				istransparent = 1'b0;
			end
			4'h9:
			begin
				Red = 8'hB9;
				Green = 8'hB9;
				Blue = 8'hB9;
				istransparent = 1'b0;
			end
			4'hA:
			begin
				Red = 8'hDA;
				Green = 8'hDA;
				Blue = 8'hDA;
				istransparent = 1'b0;
			end
			default:		//Give black
			begin
				Red = 8'h00;
				Green = 8'h00;
				Blue = 8'h00;
				istransparent = 1'b0;
			end
		endcase
	end

endmodule
