module draw_score (	input pixel_Clk, frame_Clk,
							input [9:0] WriteX, WriteY,
							input [9:0] DrawX, DrawY,
							output logic [2:0] score_on_dr,
							output logic [2:0] score_on_wr,
							output logic [17:0] address);
	//For score_on, 000 means off, 001~101 means on1~on5.
	
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
	parameter [17:0] num_X = 18'd18;
	parameter [17:0] num_Y = 18'd21;

	parameter [9:0] score1_locX = 10'd520;
	parameter [9:0] score2_locX = 10'd540;
	parameter [9:0] score3_locX = 10'd560; 
	parameter [9:0] score4_locX = 10'd580;
	parameter [9:0] score5_locX = 10'd600; 

	parameter [9:0] score_locY = 10'd20;

	logic [17:0] score1;
	logic [17:0] score2;
	logic [17:0] score3;
	logic [17:0] score4;
	logic [17:0] score5;

	logic [17:0] start, offset;
	int DistX, DistY, SizeX, SizeY;
	int frame_count;
	int score;
	
	initial
	begin
		frame_count = 1;
		score = 0;
	end
	
	always_comb
	begin
		SizeX = num_X;
		SizeY = num_Y;
		case (score_on_wr)
			3'b001: DistX = WriteX - score1_locX;
			3'b010: DistX = WriteX - score2_locX;
			3'b011: DistX = WriteX - score3_locX;
			3'b100: DistX = WriteX - score4_locX;
			3'b101: DistX = WriteX - score5_locX;
			default: DistX = 0;
		endcase
		DistY = DrawY - score_locY;
	end
	
	always_ff @ (posedge frame_Clk)
	begin
		if (frame_count == 10)
		begin
			score <= score + 1;
			if (score == 100000)
				score <= 0;
			frame_count <= 1;
		end
		else
			frame_count <= frame_count + 1;
	end
	
	always_comb
	begin
		score1 = score / 10000;
		score2 = (score / 1000) % 10;
		score3 = (score / 100) % 10;
		score4 = (score / 10) % 10;
		score5 = score % 10;
	end
	
//	always_ff @ (posedge pixel_Clk)
	always_comb
	begin
		case (score_on_wr)
			3'b001: start = num[score1];
			3'b010: start = num[score2];
			3'b011: start = num[score3];
			3'b100: start = num[score4];
			3'b101: start = num[score5];
			default: start = 0;
		endcase
		offset = DistY*SizeX + DistX;
		address = start + offset;
	end
	
	always_comb
	begin:Score_on_wr_proc
	if ((DrawY >= score_locY) && (DrawY < score_locY + num_Y))
	begin
		if ((WriteX >= score1_locX) && (WriteX < score1_locX + num_X))
			score_on_wr = 3'b001;
		else if ((WriteX >= score2_locX) && (WriteX < score2_locX + num_X))
			score_on_wr = 3'b010;
		else if ((WriteX >= score3_locX) && (WriteX < score3_locX + num_X))
			score_on_wr = 3'b011;
		else if ((WriteX >= score4_locX) && (WriteX < score4_locX + num_X))
			score_on_wr = 3'b100;
		else if ((WriteX >= score5_locX) && (WriteX < score5_locX + num_X))
			score_on_wr = 3'b101;
		else 
			score_on_wr = 3'b000;
	end
	else
		score_on_wr = 3'b000;
	end 
	
	always_comb
	begin:Score_on_proc
	if ((DrawY >= score_locY) && (DrawY < score_locY + num_Y))
	begin
		if ((DrawX >= score1_locX) && (DrawX < score1_locX + num_X))
			score_on_dr = 3'b001;
		else if ((DrawX >= score2_locX) && (DrawX < score2_locX + num_X))
			score_on_dr = 3'b010;
		else if ((DrawX >= score3_locX) && (DrawX < score3_locX + num_X))
			score_on_dr = 3'b011;
		else if ((DrawX >= score4_locX) && (DrawX < score4_locX + num_X))
			score_on_dr = 3'b100;
		else if ((DrawX >= score5_locX) && (DrawX < score5_locX + num_X))
			score_on_dr = 3'b101;
		else 
			score_on_dr = 3'b000;
	end
	else
		score_on_dr = 3'b000;
	end 

endmodule
