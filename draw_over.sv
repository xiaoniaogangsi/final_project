module draw_over(	input frame_Clk, Reset,
						input [9:0] WriteX, WriteY,
						input Dead,
						input [1:0] Game_State,
						input int score,
						output logic [3:0] over_on_wr,
						output logic [17:0] address);
	//over_on_wr=4'd0 means off, 4'd1~4'd8 means the text "GAME OVER",
	//4'd9 means the return picture.
	//4'd10~4'd14 means scores.
	
//	 $readmemh("memfiles/gameover1_G_21x21.txt", mem, 76216, 76656);
//	 $readmemh("memfiles/gameover2_A_21x21.txt", mem, 76657, 77097);
//	 $readmemh("memfiles/gameover3_M_21x21.txt", mem, 77098, 77538);
//	 $readmemh("memfiles/gameover4_E_21x21.txt", mem, 77539, 77979);
//	 $readmemh("memfiles/gameover5_O_21x21.txt", mem, 77980, 78420);
//	 $readmemh("memfiles/gameover6_V_21x21.txt", mem, 78421, 78861);
//	 $readmemh("memfiles/gameover7_R_21x21.txt", mem, 78862, 79302);

//	 $readmemh("sprite/restart_72x64.txt", mem, 186715, 191322);
	
	parameter [17:0] restart = 18'd186715;
	int gameover_X = 21;
	int gameover_Y = 21;
	int restart_X = 72;
	int restart_Y = 64;
	
	int gameover1_G_locX = 130;
	int gameover2_A_locX = 178;
	int gameover3_M_locX = 226;
	int gameover4_E_locX = 274;
	int gameover5_O_locX = 322;
	int gameover6_V_locX = 370;
	int gameover7_E_locX = 418;
	int gameover8_R_locX = 466;	
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
	
	logic [17:0] gameover [0:6];
	always_comb
	begin
		gameover[0] = 18'd76216; //G
		gameover[1] = 18'd76657; //A
		gameover[2] = 18'd77098; //M
		gameover[3] = 18'd77539; //E
		gameover[4] = 18'd77980; //O
		gameover[5] = 18'd78421; //V
		gameover[6] = 18'd78862; //R
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
			4'd1:
				begin
					SizeX = gameover_X;
					SizeY = gameover_Y;
					DistX = WriteX - gameover1_G_locX;
					DistY = WriteY - gameover_locY;
				end
			4'd2:
				begin
					SizeX = gameover_X;
					SizeY = gameover_Y;
					DistX = WriteX - gameover2_A_locX;
					DistY = WriteY - gameover_locY;
				end
			4'd3:
				begin
					SizeX = gameover_X;
					SizeY = gameover_Y;
					DistX = WriteX - gameover3_M_locX;
					DistY = WriteY - gameover_locY;
				end
			4'd4:
				begin
					SizeX = gameover_X;
					SizeY = gameover_Y;
					DistX = WriteX - gameover4_E_locX;
					DistY = WriteY - gameover_locY;
				end
			4'd5:
				begin
					SizeX = gameover_X;
					SizeY = gameover_Y;
					DistX = WriteX - gameover5_O_locX;
					DistY = WriteY - gameover_locY;
				end
			4'd6:
				begin
					SizeX = gameover_X;
					SizeY = gameover_Y;
					DistX = WriteX - gameover6_V_locX;
					DistY = WriteY - gameover_locY;
				end
			4'd7:
				begin
					SizeX = gameover_X;
					SizeY = gameover_Y;
					DistX = WriteX - gameover7_E_locX;
					DistY = WriteY - gameover_locY;
				end
			4'd8:
				begin
					SizeX = gameover_X;
					SizeY = gameover_Y;
					DistX = WriteX - gameover8_R_locX;
					DistY = WriteY - gameover_locY;
				end
			4'd9:
				begin
					SizeX = restart_X;
					SizeY = restart_Y;
					DistX = WriteX - restart_locX;
					DistY = WriteY - restart_locY;
				end
			4'd10:
				begin
					SizeX = num_X;
					SizeY = num_Y;
					DistX = WriteX - score1_locX;
					DistY = WriteY - score_locY;
				end
			4'd11:
				begin
					SizeX = num_X;
					SizeY = num_Y;
					DistX = WriteX - score2_locX;
					DistY = WriteY - score_locY;
				end
			4'd12:
				begin
					SizeX = num_X;
					SizeY = num_Y;
					DistX = WriteX - score3_locX;
					DistY = WriteY - score_locY;
				end
			4'd13:
				begin
					SizeX = num_X;
					SizeY = num_Y;
					DistX = WriteX - score4_locX;
					DistY = WriteY - score_locY;
				end
			4'd14:
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
			4'd1: start = gameover[0];	//G
			4'd2: start = gameover[1];	//A
			4'd3: start = gameover[2];	//M
			4'd4: start = gameover[3];	//E
			4'd5: start = gameover[4];	//O
			4'd6: start = gameover[5];	//V
			4'd7: start = gameover[3];	//E
			4'd8: start = gameover[6];	//R
			4'd9: start = restart;
			4'd10: start = num[score1];
			4'd11: start = num[score2];
			4'd12: start = num[score3];
			4'd13: start = num[score4];
			4'd14: start = num[score5];
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
				if ((WriteX >= gameover1_G_locX) && (WriteX < gameover1_G_locX + gameover_X))
					over_on_wr = 4'd1;
				else if ((WriteX >= gameover2_A_locX) && (WriteX < gameover2_A_locX + gameover_X))
					over_on_wr = 4'd2;
				else if ((WriteX >= gameover3_M_locX) && (WriteX < gameover3_M_locX + gameover_X))
					over_on_wr = 4'd3;
				else if ((WriteX >= gameover4_E_locX) && (WriteX < gameover4_E_locX + gameover_X))
					over_on_wr = 4'd4;
				else if ((WriteX >= gameover5_O_locX) && (WriteX < gameover5_O_locX + gameover_X))
					over_on_wr = 4'd5;
				else if ((WriteX >= gameover6_V_locX) && (WriteX < gameover6_V_locX + gameover_X))
					over_on_wr = 4'd6;
				else if ((WriteX >= gameover7_E_locX) && (WriteX < gameover7_E_locX + gameover_X))
					over_on_wr = 4'd7;
				else if ((WriteX >= gameover8_R_locX) && (WriteX < gameover8_R_locX + gameover_X))
					over_on_wr = 4'd8;
				else
					over_on_wr = 4'd0;
			end
		else if ((WriteY >= restart_locY) && (WriteY < restart_locY + restart_Y))
			begin
				if ((WriteX >= restart_locX) && (WriteX < restart_locX + restart_X))
					over_on_wr = 4'd9;
				else
					over_on_wr = 4'd0;
			end
		else if ((WriteY >= score_locY) && (WriteY < score_locY + num_Y))
			begin
				if ((WriteX >= score1_locX) && (WriteX < score1_locX + num_X))
					over_on_wr = 4'd10;
				else if ((WriteX >= score2_locX) && (WriteX < score2_locX + num_X))
					over_on_wr = 4'd11;
				else if ((WriteX >= score3_locX) && (WriteX < score3_locX + num_X))
					over_on_wr = 4'd12;
				else if ((WriteX >= score4_locX) && (WriteX < score4_locX + num_X))
					over_on_wr = 4'd13;
				else if ((WriteX >= score5_locX) && (WriteX < score5_locX + num_X))
					over_on_wr = 4'd14;
				else 
					over_on_wr = 4'd0;
			end
		else
			over_on_wr = 4'd0;
	end
	else
		over_on_wr = 4'd0;
	end
	
	

endmodule
