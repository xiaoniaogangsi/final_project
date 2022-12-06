module palette(input logic [3:0] color,
					input logic isnight,
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
//	always_ff @ (posedge clk)
	always_comb
	begin
		if (~isnight)
		begin
		case (color)
			4'h0:		//Transparent
			begin
				Red = 8'h80;
				Green = 8'h00;
				Blue = 8'h80;
			end
			4'h1:
			begin
				Red = 8'hEF;
				Green = 8'hEF;
				Blue = 8'hEF;
			end
			4'h2:
			begin
				Red = 8'hF0;
				Green = 8'hF0;
				Blue = 8'hF0;
			end
			4'h3:
			begin
				Red = 8'hF6;
				Green = 8'hF6;
				Blue = 8'hF6;
			end
			4'h4:		//Background Color
			begin
				Red = 8'hA0;	//F7; originally
				Green = 8'hA0;	//F7; originally
				Blue = 8'hA0;	//F7; originally
			end
			4'h5:
			begin
				Red = 8'hF8;
				Green = 8'hF8;
				Blue = 8'hF8;
			end
			4'h6:
			begin
				Red = 8'hFE;
				Green = 8'hFE;
				Blue = 8'hFE;
			end
			4'h7:
			begin
				Red = 8'hFF;
				Green = 8'hFF;
				Blue = 8'hFF;
			end
			4'h8:
			begin
				Red = 8'h53;
				Green = 8'h53;
				Blue = 8'h53;
			end
			4'h9:
			begin
				Red = 8'hB9;
				Green = 8'hB9;
				Blue = 8'hB9;
			end
			4'hA:
			begin
				Red = 8'hDA;
				Green = 8'hDA;
				Blue = 8'hDA;
			end
			4'hB:
			begin
				Red = 8'hFF;
				Green = 8'h90;
				Blue = 8'h00;
			end
			4'hC:
			begin
				Red = 8'h60;
				Green = 8'h00;
				Blue = 8'h00;
			end
			4'hD:
			begin
				Red = 8'h00;
				Green = 8'h00;
				Blue = 8'h00;
			end
			default:		//Give black
			begin
				Red = 8'h00;
				Green = 8'h00;
				Blue = 8'h00;
			end
		endcase
		end
		else	//Night
		begin
		case (color)
			4'h0:		//Transparent
			begin
				Red = 8'h80;
				Green = 8'h00;
				Blue = 8'h80;
			end
			4'h1:
			begin
				Red = 8'h1F;
				Green = 8'h1F;
				Blue = 8'h1F;
			end
			4'h2:
			begin
				Red = 8'h00;
				Green = 8'h00;
				Blue = 8'h00;
			end
			4'h3:
			begin
				Red = 8'h06;
				Green = 8'h06;
				Blue = 8'h06;
			end
			4'h4:		//Background Color: At night is #202020
			begin
				Red = 8'h20;	
				Green = 8'h20;	
				Blue = 8'h20;	
			end
			4'h5:
			begin
				Red = 8'h08;
				Green = 8'h08;
				Blue = 8'h08;
			end
			4'h6:
			begin
				Red = 8'h0E;
				Green = 8'h0E;
				Blue = 8'h0E;
			end
			4'h7:
			begin		//White become black.
				Red = 8'h00;
				Green = 8'h00;
				Blue = 8'h00;
			end
			4'h8:	//At night is #ACACAC
			begin
				Red = 8'hAC;
				Green = 8'hAC;
				Blue = 8'hAC;
			end
			4'h9:
			begin
				Red = 8'hB9;
				Green = 8'hB9;
				Blue = 8'hB9;
			end
			4'hA:
			begin
				Red = 8'hDA;
				Green = 8'hDA;
				Blue = 8'hDA;
			end
			4'hB:
			begin
				Red = 8'hFF;
				Green = 8'h90;
				Blue = 8'h00;
			end
			4'hC:
			begin
				Red = 8'h60;
				Green = 8'h00;
				Blue = 8'h00;
			end
			4'hD:
			begin
				Red = 8'hFF;
				Green = 8'hFF;
				Blue = 8'hFF;
			end
			default:		//Give black
			begin
				Red = 8'h00;
				Green = 8'h00;
				Blue = 8'h00;
			end
		endcase
		end
	end

endmodule
