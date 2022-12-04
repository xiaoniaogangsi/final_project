module draw_score (	input Clk50, pixel_Clk, frame_Clk, Reset,
							input [9:0] WriteX, WriteY,
							input [9:0] DrawX, DrawY,
							input Dead,
							output logic [2:0] score_on_dr,
							output logic [2:0] score_on_wr,
							output logic [17:0] address,
							output int score_out);
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
	int num_X = 18;
	int num_Y = 21;

	int score1_locX = 520;
	int score2_locX = 540;
	int score3_locX = 560; 
	int score4_locX = 580;
	int score5_locX = 600; 

	int score_locY = 20;

	logic [17:0] score1;
	logic [17:0] score2;
	logic [17:0] score3;
	logic [17:0] score4;
	logic [17:0] score5;

	logic [17:0] start, offset;
	int DistX, DistY, SizeX, SizeY;
	int frame_count;
	int score;
	int score_add;
	
	initial
	begin
		frame_count = 1;
		score = 0;
		score_add = 1;
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
		DistY = WriteY - score_locY;
	end
	
	logic blink;
	int blink_count;
	always_ff @ (posedge frame_Clk or posedge Reset)
	begin
		if (Reset)
		begin
			blink <= 1'b0;
			blink_count <= 0;
		end
		else
		begin
			if ((score != 0) && (score % 100 == 0))		//At every hundreds, enable blink.
				blink <= 1'b1;
			if (blink == 1'b1)
				blink_count <= blink_count + 1;
			if (blink_count == 200)
			begin
				blink <= 1'b0;
				blink_count <= 0;
			end
		end
	end
	
	always_comb
	begin
		if (Dead)
			score_add = 0;
		else
			score_add = 1;
	end
	
	always_ff @ (posedge frame_Clk or posedge Reset)
	begin
		if (Reset)
		begin
			score <= 0;
			frame_count <= 1;
		end
		else
		begin
			if (frame_count == 10)
			begin
				score <= score + score_add;
				if (score == 100000)
					score <= 0;
				frame_count <= 1;
			end
			else
				frame_count <= frame_count + 1;
		end
	end
	
	always_comb
	begin
		score1 = score / 10000;
		score2 = (score / 1000) % 10;
		score3 = (score / 100) % 10;
		if (blink)
		begin
			score4 = 0;
			score5 = 0;
		end
		else
		begin
			score4 = (score / 10) % 10;
			score5 = score % 10;
		end
	end
	
//	always_ff @ (posedge Clk50)
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
	end
	assign address = start + offset;
	
	always_comb
	begin:Score_on_wr_proc
	if ((blink_count % 50 >= 25) && (blink_count % 50 <= 50))
		 score_on_wr = 3'b000;
	else
	begin
		if ((WriteY >= score_locY) && (WriteY < score_locY + num_Y))
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
	end 
	
	always_comb
	begin:Score_on_proc
	if ((blink_count % 50 >= 25) && (blink_count % 50 <= 50))
		 score_on_dr = 3'b000;
	else
	begin
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
	end
	
	assign score_out = score;
	
endmodule
