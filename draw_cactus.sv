module draw_cloud (	input Clk50, pixel_Clk, frame_Clk,
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
	
	parameter [9:0] cactus_largeY = 10'd100;
	parameter [9:0] cactus_smallY = 10'd70;
	parameter [9:0] cactus_large1X = 10'd50;
	parameter [9:0] cactus_large2X = 10'd100;
	parameter [9:0] cactus_large3X = 10'd150;
	parameter [9:0] cactus_small1X = 10'd36;
	parameter [9:0] cactus_small2X = 10'd68;
	parameter [9:0] cactus_large3X = 10'd102;	
	
	int frame_count;	
	logic [17:0] start, offset;
	logic [9:0] PosX, PosY;
	int SizeX, SizeY, DistX, DistY;
	logic [17:0] cactus_addr;
	logic [9:0] cactus_X, cactus_Y;
	
	logic [9:0] DrawX_new, WriteX_new;
	
	enum logic [2:0] {Large1, Large2, Large3, Small1, Small2, Samll3} cactus_type; 
	always_comb
	begin
		unique case (cactus_type)
			Large1: 
				begin
					cactus_addr = cactus_large1;
					cactus_X = cactus_large1X;
					cactus_Y = cactus_largeY;
					PosY = 10'd320;
				end
			Large2: 
				begin
					cactus_addr = cactus_large2;
					cactus_X = cactus_large2X;
					cactus_Y = cactus_largeY;
					PosY = 10'd320;
				end
			Large3: 
				begin
					cactus_addr = cactus_large3;
					cactus_X = cactus_large3X;
					cactus_Y = cactus_largeY;
					PosY = 10'd320;
				end
			Small1: 
				begin
					cactus_addr = cactus_small1;
					cactus_X = cactus_small1X;
					cactus_Y = cactus_smallY;
					PosY = 10'd350;
				end
			Small2: 
				begin
					cactus_addr = cactus_small2;
					cactus_X = cactus_small2X;
					cactus_Y = cactus_smallY;
					PosY = 10'd350;
				end
			Small3: 
				begin
					cactus_addr = cactus_small3;
					cactus_X = cactus_small3X;
					cactus_Y = cactus_smallY;
					PosY = 10'd350;
				end
		endcase
	end
	
	
	initial
	begin
		PosX = 10'd640;
		frame_count = 1;
	end
	
	logic Load_Seed, Done;
	logic [5:0] Seed;
	logic [5:0] rand_num;
	assign Seed = 6'b010101;
	LFSR gen_rand #(6)(.*, .Clk(frame_Clk), .Enable(1'b1), .Out(rand_num));
	
	always_comb
	begin
		DrawX_new = DrawX + cactus_X;
		WriteX_new = WriteX + cactus_X;
	end

	always_comb
	begin
		SizeX = cactus_X;
		SizeY = cactus_Y;
		DistX = WriteX_new - PosX;
		DistY = WriteY - PosY;
	end
	
	always_ff @ (posedge frame_Clk)
	begin
		if (frame_count == 5)
		begin
			if ((~PosX)+1  == cactus_X)
				PosX <= 10'd640;
			else
				PosX <= PosX - 1;
			frame_count <= 1;
		end
		else
			frame_count <= frame_count + 1;
	end
	
	always_ff @ (posedge Clk50)
//	always_comb
	begin
		start <= cactus_addr;
		offset <= DistY*SizeX + DistX;
	end
	assign address = start + offset;

	 always_comb
    begin:Cloud_on_proc
		 if ((DrawX_new >= PosX) &&
			 (DrawX_new < PosX + cactus_X) &&
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
		 if ((WriteX_new >= PosX) &&
			 (WriteX_new < PosX + cactus_X) &&
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
