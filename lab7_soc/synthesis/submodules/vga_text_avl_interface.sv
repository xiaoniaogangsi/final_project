/************************************************************************
Avalon-MM Interface VGA Text mode display

Register Map:
0x000-0x0257 : VRAM, 80x30 (2400 byte, 600 word) raster order (first column then row)
0x258        : control register

VRAM Format:
X->
[ 31  30-24][ 23  22-16][ 15  14-8 ][ 7    6-0 ]
[IV3][CODE3][IV2][CODE2][IV1][CODE1][IV0][CODE0]

IVn = Draw inverse glyph
CODEn = Glyph code from IBM codepage 437

Control Register Format:
[[31-25][24-21][20-17][16-13][ 12-9][ 8-5 ][ 4-1 ][   0    ] 
[[RSVD ][FGD_R][FGD_G][FGD_B][BKG_R][BKG_G][BKG_B][RESERVED]

VSYNC signal = bit which flips on every Vsync (time for new frame), used to synchronize software
BKG_R/G/B = Background color, flipped with foreground when IVn bit is set
FGD_R/G/B = Foreground color, flipped with background when Inv bit is set

************************************************************************/
`define NUM_REGS 601 //80*30 characters / 4 characters per register
`define CTRL_REG 600 //index of control register

module vga_text_avl_interface (
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,					// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
	input  logic [11:0] AVL_ADDR,			// Avalon-MM Address			//Modified from 10-bit to 12-bit
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs						// VGA HS/VS
);

logic [31:0] LOCAL_REG       [`NUM_REGS]; // Registers
//put other local variables here
logic blank;
logic pixel_clk;
logic sync;
logic [9:0] Draw_X,Draw_Y;
logic [31:0] index;
//important!
logic [10:0] index_now;
logic [7:0] glypth;
logic [31:0] controller_register;

logic [10:0] AVL_address;
logic select_reg;
logic write_chip;
logic [31:0] AVL_READDATA_reg, AVL_READDATA_ram;

logic fore_or_back;
logic [3:0] fore_idx, back_idx;

int i;

//Declare submodules..e.g. VGA controller, ROMS, etc
vga_controller VGA_controller0(.*,
										 .Clk(CLK),
										 .Reset(RESET),
										 .DrawX(Draw_X),
										 .DrawY(Draw_Y));

//take caution for 16!
font_rom font_rom0(.addr(index_now),.data(glypth));   

ram on_chip_mem(
	.aclr(RESET),
	.address_a(AVL_ADDR),
	.address_b(AVL_address),	//Word address calculated
	.byteena_a(AVL_BYTE_EN),
	.clock(CLK),
	.data_a(AVL_WRITEDATA),
	.data_b(32'h00000000),
	.rden_a(AVL_READ),
	.rden_b(1'b1),
	.wren_a(write_chip),
	.wren_b(1'b0),
	.q_a(AVL_READDATA_ram),
	.q_b(index));					//Content in the calculated Word address
	
// Read and write from AVL interface to register block, note that READ waitstate = 1, so this should be in always_ff

assign write_chip = (~select_reg) && AVL_WRITE;		//Use select_reg to determine write to on-chip memory or the FPGA register
assign select_reg = AVL_ADDR[11];

always_comb
begin:READDATA_Router			//Choose the READDATA contents from on-chip memory or the FPGA register
	if (select_reg)
		AVL_READDATA = AVL_READDATA_reg;
	else
		AVL_READDATA = AVL_READDATA_ram;
end

always_ff @(posedge CLK or posedge RESET) begin
	if (RESET)
	begin
		for (i=0; i<`NUM_REGS; i++)
			LOCAL_REG[i] <= 32'h00000000;
	end
	else if (AVL_CS&&select_reg)
	begin
		if (AVL_READ)		//Do read operation
			AVL_READDATA_reg <= LOCAL_REG[AVL_ADDR[2:0]];	//LOCAL_REG is for the 8 registers, use AVL_ADDR[2:0] to locate them.
		if (AVL_WRITE)		//Do write operation
		begin
			case (AVL_BYTE_EN)
				4'b1111:	LOCAL_REG[AVL_ADDR[2:0]] <= AVL_WRITEDATA;								//Write full 32-bit
				4'b1100: LOCAL_REG[AVL_ADDR[2:0]][31:16] <= AVL_WRITEDATA[31:16];				//Write the 2 upper bytes
				4'b0011: LOCAL_REG[AVL_ADDR[2:0]][15:0] <= AVL_WRITEDATA[15:0];				//Write the 2 lower bytes
				4'b1000: LOCAL_REG[AVL_ADDR[2:0]][31:24] <= AVL_WRITEDATA[31:24];				//Write byte 3 only
				4'b0100: LOCAL_REG[AVL_ADDR[2:0]][23:16] <= AVL_WRITEDATA[23:16];				//Write byte 2 only
				4'b0010: LOCAL_REG[AVL_ADDR[2:0]][15:8] <= AVL_WRITEDATA[15:8];				//Write byte 1 only
				4'b0001: LOCAL_REG[AVL_ADDR[2:0]][7:0] <= AVL_WRITEDATA[7:0];					//Write byte 0 only
				default: ;
			endcase
		end
	end
end
 
//handle drawing (may either be combinational or sequential - or both).
logic [6:0] col;
logic [4:0] row;
logic [6:0] col_now;
logic [4:0] row_now;
logic char_on;		//Now 2 chars in one register

always_comb
begin: character_on
	AVL_address = (Draw_X + (Draw_Y/16)*640)/16;		//Change /32 to /16 (which means now a register contains 2 characters/16 pixels)
	col = (AVL_address * 2) % 80;		//Change to *2 since now one word has only 2 char.
//	row = AVL_address * 4 / 80;
	col_now = Draw_X / 8;
//	row_now = Draw_Y / 16;
	if (col_now == col)
		char_on = 1'b0;
	else 		//col_now == col+1
		char_on = 1'b1;
end

logic inverse_now;


always_comb
begin: refer_to_font_table
	case (char_on)
		1'b0:
		begin
			index_now = index[14:8]*16 + Draw_Y[3:0];
			inverse_now = index[15];
			fore_idx = index[7:4];
			back_idx = index[3:0];
		end
		1'b1:
		begin
			index_now = index[30:24]*16 + Draw_Y[3:0];
			inverse_now = index[31];
			fore_idx = index[23:20];
			back_idx = index[19:16];
		end
		default: ;
	endcase
	//read information about the pixel drawing is foreground or background
	fore_or_back = glypth[7-Draw_X[2:0]];
end

always_ff @ (posedge pixel_clk)	
begin: color_mapper
	if (blank==0)
	begin
		red <= 4'h0;
		green <= 4'h0;
		blue <= 4'h0;
	end
	else 
	begin
	if (inverse_now == 1'b0)	//No need for inverse
		begin
			if (fore_or_back)		//Fill Foreground Color
			begin
				if (fore_idx[0] == 1'b0)
				begin
					red <= LOCAL_REG[fore_idx[3:1]][12:9];
					green <= LOCAL_REG[fore_idx[3:1]][8:5];
					blue <= LOCAL_REG[fore_idx[3:1]][4:1];
				end
				else
				begin
					red <= LOCAL_REG[fore_idx[3:1]][24:21];
					green <= LOCAL_REG[fore_idx[3:1]][20:17];
					blue <= LOCAL_REG[fore_idx[3:1]][16:13];
				end
			end
			else						//Fill Background Color
			begin
				if (back_idx[0] == 1'b0)
				begin
					red <= LOCAL_REG[back_idx[3:1]][12:9];
					green <= LOCAL_REG[back_idx[3:1]][8:5];
					blue <= LOCAL_REG[back_idx[3:1]][4:1];
				end
				else
				begin
					red <= LOCAL_REG[back_idx[3:1]][24:21];
					green <= LOCAL_REG[back_idx[3:1]][20:17];
					blue <= LOCAL_REG[back_idx[3:1]][16:13];
				end
			end
		end
		else							//Need inverse
		begin
			if (fore_or_back)		//Fill Background Color
			begin
				if (back_idx[0] == 1'b0)
				begin
					red <= LOCAL_REG[back_idx[3:1]][12:9];
					green <= LOCAL_REG[back_idx[3:1]][8:5];
					blue <= LOCAL_REG[back_idx[3:1]][4:1];
				end
				else
				begin
					red <= LOCAL_REG[back_idx[3:1]][24:21];
					green <= LOCAL_REG[back_idx[3:1]][20:17];
					blue <= LOCAL_REG[back_idx[3:1]][16:13];
				end
			end
			else						//Fill Foreground Color
			begin
				if (fore_idx[0] == 1'b0)
				begin
					red <= LOCAL_REG[fore_idx[3:1]][12:9];
					green <= LOCAL_REG[fore_idx[3:1]][8:5];
					blue <= LOCAL_REG[fore_idx[3:1]][4:1];
				end
				else
				begin
					red <= LOCAL_REG[fore_idx[3:1]][24:21];
					green <= LOCAL_REG[fore_idx[3:1]][20:17];
					blue <= LOCAL_REG[fore_idx[3:1]][16:13];
				end
			end
		end
	end
end
		

endmodule
