module draw_over(	input Clk50, pixel_Clk, frame_Clk, Reset,
						input [9:0] WriteX, WriteY,
						input Dead,
						input [1:0] Game_State,
						input int score,
						output logic [2:0] over_on_wr,
						output logic [17:0] address);
	//over_on_wr=3'b000 means off, 3'b001 means the text "GAME OVER!", 3'b010 means the return picture.
	//3'b011~3'b111 means scores.
	//$readmemh("sprite/gameover_381x21.txt", mem, 76216, 84216);
	//$readmemh("sprite/restart_72x64.txt", mem, 186715, 191322);
	parameter [17:0] gameover = 18'd76216;
	parameter [17:0] restart = 18'd186715;
	int gameover_X = 381;
	int gameover_Y = 21;
	int restart_X = 72;
	int restart_Y = 64;
	
	int gameover_locX = 130;
	int gameover_locY = 130;
	int restart_locX = 284;
	int restart_locY = 160;
	
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

	int score1_locX = 271;
	int score2_locX = 291;
	int score3_locX = 311; 
	int score4_locX = 331;
	int score5_locX = 351; 

	int score_locY = 230;

	logic [17:0] score1;
	logic [17:0] score2;
	logic [17:0] score3;
	logic [17:0] score4;
	logic [17:0] score5;
	
	logic [17:0] start, offset;
	int DistX, DistY, SizeX, SizeY;
	
	always_comb
	begin
		score1 = score / 10000;
		score2 = (score / 1000) % 10;
		score3 = (score / 100) % 10;
		score4 = (score / 10) % 10;
		score5 = score % 10;
	end
	
	always_comb
	begin
		case (over_on_wr)
			3'b001:
				begin
					SizeX = gameover_X;
					SizeY = gameover_Y;
					DistX = WriteX - gameover_locX;
					DistY = WriteY - gameover_locY;
				end
			3'b010:
				begin
					SizeX = restart_X;
					SizeY = restart_Y;
					DistX = WriteX - restart_locX;
					DistY = WriteY - restart_locY;
				end
			3'b011:
				begin
					SizeX = num_X;
					SizeY = num_Y;
					DistX = WriteX - score1_locX;
					DistY = WriteY - score_locY;
				end
			3'b100:
				begin
					SizeX = num_X;
					SizeY = num_Y;
					DistX = WriteX - score2_locX;
					DistY = WriteY - score_locY;
				end
			3'b101:
				begin
					SizeX = num_X;
					SizeY = num_Y;
					DistX = WriteX - score3_locX;
					DistY = WriteY - score_locY;
				end
			3'b110:
				begin
					SizeX = num_X;
					SizeY = num_Y;
					DistX = WriteX - score4_locX;
					DistY = WriteY - score_locY;
				end
			3'b111:
				begin
					SizeX = num_X;
					SizeY = num_Y;
					DistX = WriteX - score5_locX;
					DistY = WriteY - score_locY;
				end
			default:
				begin
					SizeX = 0;
					SizeY = 0;
					DistX = 0;
					DistY = 0;
				end
		endcase
	end
	
	always_comb
	begin
		case (over_on_wr)
			3'b001: start = gameover;
			3'b010: start = restart;
			3'b011: start = num[score1];
			3'b100: start = num[score2];
			3'b101: start = num[score3];
			3'b110: start = num[score4];
			3'b111: start = num[score5];
			default: start = 0;
		endcase
		offset = DistY*SizeX + DistX;
	end
	assign address = start + offset;
	
	always_comb
	begin
	if (Game_State == 2'b10)
	begin
		if ((WriteY >= gameover_locY) && (WriteY < gameover_locY + gameover_Y))
			begin
				if ((WriteX >= gameover_locX) && (WriteX < gameover_locX + gameover_X))
					over_on_wr = 3'b001;
				else
					over_on_wr = 3'b000;
			end
		else if ((WriteY >= restart_locY) && (WriteY < restart_locY + restart_Y))
			begin
				if ((WriteX >= restart_locX) && (WriteX < restart_locX + restart_X))
					over_on_wr = 3'b010;
				else
					over_on_wr = 3'b000;
			end
		else if ((WriteY >= score_locY) && (WriteY < score_locY + num_Y))
			begin
				if ((WriteX >= score1_locX) && (WriteX < score1_locX + num_X))
					over_on_wr = 3'b011;
				else if ((WriteX >= score2_locX) && (WriteX < score2_locX + num_X))
					over_on_wr = 3'b100;
				else if ((WriteX >= score3_locX) && (WriteX < score3_locX + num_X))
					over_on_wr = 3'b101;
				else if ((WriteX >= score4_locX) && (WriteX < score4_locX + num_X))
					over_on_wr = 3'b110;
				else if ((WriteX >= score5_locX) && (WriteX < score5_locX + num_X))
					over_on_wr = 3'b111;
				else 
					over_on_wr = 3'b000;
			end
		else
			over_on_wr = 3'b000;
	end
	else
		over_on_wr = 3'b000;
	end
	
	

endmodule
