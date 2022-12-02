module draw_cactus (	input Clk50, pixel_Clk, frame_Clk, Reset,
							input [9:0] WriteX, WriteY,
							input [9:0] DrawX, DrawY,
							output logic cactus_on_wr,
							output logic cactus_on_dr,
							output logic [17:0] address);
//	 $readmemh("sprite/cactus_large1_50x100.txt", mem, 0, 4999);
//	 $readmemh("sprite/cactus_large2_100x100.txt", mem, 5000, 14999);
//	 $readmemh("sprite/cactus_large3_150x100.txt", mem, 15000, 29999);
//	 $readmemh("sprite/cactus_small1_36x70.txt", mem, 30000, 32519);
//	 $readmemh("sprite/cactus_small2_68x70.txt", mem, 32520, 37279);
//	 $readmemh("sprite/cactus_small3_102x70.txt", mem, 37280, 44419);
	parameter [17:0] cactus_large1 = 18'd0;
	parameter [17:0] cactus_large2 = 18'd5000;
	parameter [17:0] cactus_large3 = 18'd15000;
	parameter [17:0] cactus_small1 = 18'd30000;
	parameter [17:0] cactus_small2 = 18'd32520;
	parameter [17:0] cactus_small3 = 18'd37280;	
	
	int cactus_largeY = 100;
	int cactus_smallY = 70;
	int cactus_large1X = 50;
	int cactus_large2X = 100;
	int cactus_large3X = 150;
	int cactus_small1X = 36;
	int cactus_small2X = 68;
	int cactus_small3X = 102;	
	
	int frame_count;	
	logic [17:0] start, offset;
	int PosX, PosY;
	int SizeX, SizeY, DistX, DistY;
	logic [17:0] cactus_addr;
	int cactus_X, cactus_Y;
	logic change_type;
	
	enum logic [2:0] {Large1, Large2, Large3, Small1, Small2, Small3} cactus_type; 
	always_comb
	begin
		unique case (cactus_type)
			Large1: 
				begin
					cactus_addr = cactus_large1;
					cactus_X = cactus_large1X;
					cactus_Y = cactus_largeY;
					PosY = 320;
				end
			Large2: 
				begin
					cactus_addr = cactus_large2;
					cactus_X = cactus_large2X;
					cactus_Y = cactus_largeY;
					PosY = 320;
				end
			Large3: 
				begin
					cactus_addr = cactus_large3;
					cactus_X = cactus_large3X;
					cactus_Y = cactus_largeY;
					PosY = 320;
				end
			Small1: 
				begin
					cactus_addr = cactus_small1;
					cactus_X = cactus_small1X;
					cactus_Y = cactus_smallY;
					PosY = 350;
				end
			Small2: 
				begin
					cactus_addr = cactus_small2;
					cactus_X = cactus_small2X;
					cactus_Y = cactus_smallY;
					PosY = 350;
				end
			Small3: 
				begin
					cactus_addr = cactus_small3;
					cactus_X = cactus_small3X;
					cactus_Y = cactus_smallY;
					PosY = 350;
				end
		endcase
	end
	
	
	initial
	begin
		PosX = 640;
		frame_count = 1;
		change_type = 0;
	end
	
	logic Load_Seed, Done;
	logic [5:0] Seed;
	logic [5:0] rand_num;
	int pulse_counter;
	assign Seed = 6'b010101;
	
	initial
	begin
		Load_Seed = 1;
		pulse_counter = 0;
	end
	always_ff @ (posedge frame_Clk or posedge Reset)
	begin
		if (Reset)
		begin
			Load_Seed <= 1;
			pulse_counter <= 0;
		end
		else if (pulse_counter >= 2)
		begin
			Load_Seed <= 0;
			pulse_counter <= 2;
		end
		else
			pulse_counter <= pulse_counter + 1;
	end
	LFSR #(6) gen_rand (.*, .Clk(frame_Clk), .Enable(1'b1), .Out(rand_num));
	
	always_ff @ (posedge change_type)
	begin:Choose_draw_type
		if (rand_num >= 6'd0 && rand_num < 6'd16)			//Possibility = 1/4
			cactus_type = Large1;
		else if (rand_num >= 6'd16 && rand_num < 6'd24) //Possibility = 1/8
			cactus_type = Large2;
		else if (rand_num >= 6'd24 && rand_num < 6'd32)	//Possibility = 1/8
			cactus_type = Large3;
		else if (rand_num >= 6'd32 && rand_num < 6'd48) //Possibility = 1/4
			cactus_type = Small1;
		else if (rand_num >= 6'd48 && rand_num < 6'd56) //Possibility = 1/8
			cactus_type = Small2;
		else 															//Possibility = 1/8
			cactus_type = Small3;
	end

	always_comb
	begin
		SizeX = cactus_X;
		SizeY = cactus_Y;
		DistX = WriteX - PosX;
		DistY = WriteY - PosY;
	end
	
	always_ff @ (posedge frame_Clk)
	begin
		if (frame_count == 1)
		begin
			if (PosX == 640)
				change_type <= 0;
			if (PosX  == -cactus_X)
			begin
				PosX <= 640;
				change_type <= 1;
			end
			else
				PosX <= PosX - 2;
			frame_count <= 1;
		end
		else
			frame_count <= frame_count + 1;
	end
	
//	always_ff @ (posedge Clk50)
	always_comb
	begin
		start = cactus_addr;
		offset = DistY*SizeX + DistX;
	end
	assign address = start + offset;

	 always_comb
    begin:Cloud_on_proc
		 if ((DrawX >= PosX || PosX < 0) &&
			 (DrawX < PosX + cactus_X) &&
			 (DrawY >= PosY) &&
			 (DrawY < PosY + cactus_Y)
	//		 && (istransparent == 1'b0)
	//		 && (ball_on == 1'b0)
			 )
			cactus_on_dr = 1'b1;
		 else 
			cactus_on_dr = 1'b0;
    end 	 
	 
	 always_comb
    begin:Cloud_on_wr_proc
		 if ((WriteX >= PosX || PosX < 0) &&
			 (WriteX < PosX + cactus_X) &&
			 (WriteY >= PosY) &&
			 (WriteY < PosY + cactus_Y)
	//		 && (istransparent == 1'b0)
	//		 && (ball_on == 1'b0)
			 )
			cactus_on_wr = 1'b1;
		 else 
			cactus_on_wr = 1'b0;
    end 
	 			
endmodule
