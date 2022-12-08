module draw_heart ( input Clk50, pixel_Clk, frame_Clk, Reset,
							input Dead, contact,
							input int score,
							//input Speed_up,
							input [1:0] Game_State,
							input [9:0] WriteX, WriteY,	
							input int Cactus_PosX, Cactus_PosY,
							//input int Cactus_SizeX, Cactus_SizeY,
							input int Ptero_PosX, Ptero_PosY,
							output logic heart_on_wr,
							output int heart_PosX, heart_PosY,
							output logic [17:0] address,
							output logic heart_off);
//							
//	 $readmemh("sprite/star1_18x17.txt", mem, 224411, 224716);
//	 $readmemh("sprite/star2_18x19.txt", mem, 224717, 225058);
//	 $readmemh("sprite/star3_18x18.txt", mem, 225059, 225382);
	parameter [17:0] heart1 = 18'd224411;
	parameter [17:0] heart2 = 18'd224717;
//	parameter [17:0] heart3 = 18'd225059;

	int PosX, PosY;
	int X_Motion = -4;
	int heart1_X = 18;
	int heart1_Y = 17;
	int heart2_X = 18;
	int heart2_Y = 19;
	int heart_X;
	int heart_Y;
	
	int frame_count;
	logic draw_heart1;
	logic flag;
	logic [17:0] start, offset;
	int SizeX, SizeY, DistX, DistY;
	
	initial
	begin
		PosX = 1000;
		PosY = 256;
		frame_count = 1;
		draw_heart1 = 1'b1;
	end
	
	//control part
	always_ff @ (posedge contact)
	begin
		heart_off <= 1;
	end
	
	always_ff @ (posedge frame_Clk)
	begin
		if (PosX < 0 || PosX >= 640)
			heart_off <= 0;
	end
	
	always_comb
	begin
		if ((Game_State == 2'b00) || (Game_State == 2'b10) || Dead)
			X_Motion = 0;
		else
		begin
			if (PosX <= 4-heart_X)
				X_Motion = -1;
			else
				X_Motion = -4;
		end
	end
	
//	always_ff @ (posedge frame_clk)
//	begin
//	if (heart_off)
//		flag
//	end
	always_ff @ (posedge frame_Clk or posedge Reset)
	begin
		if (Reset)
		begin
			PosX <= 640;
			flag <= 0;
		end
		else
		begin
			if (PosX <= -heart_X)
			begin
				flag<=0;
				PosX<=640;
			end
			else if (score%1000>300 && score%1000 < 350 && Cactus_PosX <320 && (Ptero_PosX<320||Ptero_PosX>670))
				flag<=1;
			else
				flag<=0;
				
			if (flag)
			begin
				PosX<=PosX+X_Motion;
			end
			if (PosX<640)
				PosX<=PosX+X_Motion;
		end
	end
	
	always_ff @ (posedge frame_Clk or posedge Reset)
	begin
		if (Reset)
		begin
			frame_count <= 1;
			draw_heart1 <= 1'b1;
		end
		else
		begin
			if (frame_count == 10)
			begin
				draw_heart1 <= ~(draw_heart1);
				frame_count <= 1;
			end
			else
				frame_count <= frame_count + 1;
		end
	end
	
	
	
	always_comb //decode heart_X and heart_Y from draw_heart1.
	begin
		if (draw_heart1)
		begin
			heart_X = heart1_X;
			heart_Y = heart1_Y;
		end
		else
		begin
			heart_X = heart2_X;
			heart_Y = heart2_Y;
		end
	end
	
	always_comb
	begin
		SizeX = heart_X;
		SizeY = heart_Y;
		DistX = WriteX - PosX;
		DistY = WriteY - PosY;
	end
	
	always_comb
	begin
		if (draw_heart1)
			start = heart1;
		else
			start = heart2;
		offset = DistY*SizeX + DistX;
	end
	assign address = start + offset;
	
	always_comb
   begin:Heart_on_wr_proc
	 if ((WriteX >= PosX || PosX < 0) &&
       (WriteX < PosX + heart_X) &&
       (WriteY >= PosY) &&
       (WriteY < PosY + heart_Y) &&
		 (~heart_off))
      heart_on_wr = 1'b1;
    else 
		heart_on_wr = 1'b0;
   end
	
	assign heart_PosX = PosX;
	assign heart_PosY = PosY;
	
	
endmodule