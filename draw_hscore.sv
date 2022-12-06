module draw_hscore (	input Clk50, pixel_Clk, frame_Clk, Reset,
							input [9:0] WriteX, WriteY,
							input Dead,
							input [1:0] Game_State,
							input score,
							output logic [2:0] hscore_on_wr,
							output logic [17:0] address);
	//For score_on, 000 means off, 001~101 means hscore_on1~hscore_on5, 011 means HI_on.
	
	//	 $readmemh("sprite/num_0_18x21.txt", mem, 168215, 168592);
	//	 $readmemh("sprite/num_1_18x21.txt", mem, 168593, 168970);
	//	 $readmemh("sprite/num_2_18x21.txt", mem, 168971, 169348);
	//	 $readmemh("sprite/num_3_18x21.txt", mem, 169349, 169726);
	//	 $readmemh("sprite/num_4_18x21.txt", mem, 169727, 170104);
	//	 $readmemh("sprite/num_5_18x21.txt", mem, 170105, 170482);
	//	 $readmemh("sprite/num_6_18x21.txt", mem, 170483, 170860);
	//	 $readmemh("sprite/num_7_18x21.txt", mem, 170861, 171238);
	//	 $readmemh("sprite/num_8_18x21.txt", mem, 171239, 171616);
	//	 $readmemh("sprite/num_9_18x21.txt", mem, 171617, 171994);
	
	//	 $readmemh("sprite/HI_38x21.txt", mem, 84217, 85014);
	
	logic [17:0] num [0:9];
	always_comb
	begin
		num[0] = 18'd168215; 
		num[1] = 18'd168593; 
		num[2] = 18'd168971; 
		num[3] = 18'd169349; 
		num[4] = 18'd169727; 
		num[5] = 18'd170105; 
		num[6] = 18'd170483; 
		num[7] = 18'd170861; 
		num[8] = 18'd171239; 
		num[9] = 18'd171617; 
	end
	parameter [17:0] HI = 18'd84217;
	int num_X = 18;
	int num_Y = 21;
	int HI_X = 38;

	int score_locY = 20;
	
	int hscoreHI_locX = 340;
	int hscore1_locX = 380;
	int hscore2_locX = 400;
	int hscore3_locX = 420; 
	int hscore4_locX = 440;
	int hscore5_locX = 460; 
	
	logic [17:0] hscore1;
	logic [17:0] hscore2;
	logic [17:0] hscore3;
	logic [17:0] hscore4;
	logic [17:0] hscore5;

	logic [17:0] start, offset;
	int DistX, DistY, SizeX, SizeY;
	int frame_count;
	int hscore_add;
	int hscore;
	
	initial
	begin
		frame_count = 1;
		hscore_add = 1;
		hscore = 0;
	end
	
	always_comb
	begin
		case (hscore_on_wr)
		3'b001, 3'b010, 3'b011, 3'b100, 3'b101:
		begin
			SizeX = num_X;
			SizeY = num_Y;
		end
		3'b110:
		begin
			SizeX = HI_X;
			SizeY = num_Y;
		end
		default:
		begin
			SizeX = 0;
			SizeY = 0;
		end
		endcase
		
		case (hscore_on_wr)
			3'b001: DistX = WriteX - hscore1_locX;
			3'b010: DistX = WriteX - hscore2_locX;
			3'b011: DistX = WriteX - hscore3_locX;
			3'b100: DistX = WriteX - hscore4_locX;
			3'b101: DistX = WriteX - hscore5_locX;
			3'b110: DistX = WriteX - hscoreHI_locX;
			default: DistX = 0;
		endcase
		DistY = WriteY - score_locY;
	end
	
	always_comb
	begin
		if ((Game_State == 2'b00) || Dead ||
			(Game_State == 2'b01 && hscore >= score))
			hscore_add = 0;
		else
			hscore_add = 1;
	end
	
	always_ff @ (posedge frame_Clk or posedge Reset)
	begin
		if (Reset)
		begin
			frame_count <= 1;
		end
		else
		begin
			if (hscore < score)
				hscore <= score;
			if (frame_count == 10)
			begin
				hscore <= hscore + hscore_add;
				if (hscore == 100000)
					hscore <= 0;
				frame_count <= 1;
			end
			else
				frame_count <= frame_count + 1;
		end
	end
	
	always_comb
	begin
		hscore1 = hscore / 10000;
		hscore2 = (hscore / 1000) % 10;
		hscore3 = (hscore / 100) % 10;
		hscore4 = (hscore / 10) % 10;
		hscore5 = hscore % 10;
	end
	
//	always_ff @ (posedge Clk50)
	always_comb
	begin
		case (hscore_on_wr)
			4'b0110: start = num[hscore1];
			4'b0111: start = num[hscore2];
			4'b1000: start = num[hscore3];
			4'b1001: start = num[hscore4];
			4'b1010: start = num[hscore5];
			4'b1011: start = HI;
			default: start = 0;
		endcase
		offset = DistY*SizeX + DistX;
	end
	assign address = start + offset;
	
	always_comb
	begin:Score_on_wr_proc
		if ((WriteY >= score_locY) && (WriteY < score_locY + num_Y))
		begin
			if ((WriteX >= hscore1_locX) && (WriteX < hscore1_locX + num_X))
				hscore_on_wr = 3'b001;
			else if ((WriteX >= hscore2_locX) && (WriteX < hscore2_locX + num_X))
				hscore_on_wr = 3'b010;
			else if ((WriteX >= hscore3_locX) && (WriteX < hscore3_locX + num_X))
				hscore_on_wr = 3'b011;
			else if ((WriteX >= hscore4_locX) && (WriteX < hscore4_locX + num_X))
				hscore_on_wr = 3'b100;
			else if ((WriteX >= hscore5_locX) && (WriteX < hscore5_locX + num_X))
				hscore_on_wr = 3'b101;
			else if ((WriteX >= hscoreHI_locX) && (WriteX < hscoreHI_locX + HI_X))
				hscore_on_wr = 3'b110;
			else
				hscore_on_wr = 3'b000;
		end
		else
			hscore_on_wr = 3'b000;
	end
	
endmodule
