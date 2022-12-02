module draw_pterosaur(  input Clk50, pixel_Clk, frame_Clk, Reset,
							input [9:0] WriteX, WriteY,
							input [9:0] DrawX, DrawY,	
							input int Cactus_PosX, Cactus_PosY,
							input int Cactus_SizeX, Cactus_SizeY,
							output logic pterosaur_on_dr,
							output logic pterosaur_on_wr,
							output logic [17:0] address);

	//$readmemh("sprite/pterosaur_wingdown_92x80.txt", mem, 171995, 179354);
	//$readmemh("sprite/pterosaur_wingup_92x80.txt", mem, 179355, 186714);
	parameter [17:0] pterosaur1 = 18'd171995;
	parameter [17:0] pterosaur2 = 18'd179355;
	int pterosaur_X = 92;
	int pterosaur_Y = 80;
	int PosX, PosY;
	int frame_count1, frame_count2;
	logic draw_pt1;
	logic change_height;
	logic [17:0] start, offset;
	int SizeX, SizeY, DistX, DistY;
	
	initial
	begin
		PosX = 640;
		PosY = 120;
		frame_count1 = 1;
		frame_count2 = 1;
		draw_pt1 = 1'b1;
		change_height = 1'b0;
	end
	
	enum logic [3:0] {Height1, Height2, Height3, None} draw_type;
	logic pt_off;
	always_comb
	begin
		unique case (draw_type)
			Height1 : 
				begin
					PosY = 120;
					pt_off = 1'b0;
				end
			Height2 :
				begin
					PosY = 210;
					pt_off = 1'b0;
				end
			Height3:
				begin
					PosY = 300;
					pt_off = 1'b0;
				end
			None :
				begin
					PosY = 480;
					pt_off = 1'b1;
				end
		endcase
	end
	
	always_comb
	begin
		SizeX = pterosaur_X;
		SizeY = pterosaur_Y;
		DistX = WriteX - PosX;
		DistY = WriteY - PosY;
	end
	
	always_ff @ (posedge frame_Clk)
	begin
		if (frame_count1 == 10)
		begin
			draw_pt1 <= ~(draw_pt1);
			frame_count1 <= 1;
		end
		else
			frame_count1 <= frame_count1 + 1;
		if (frame_count2 == 1)
		begin
			if (PosX == 640)
				change_height <= 0;
			if (PosX == -pterosaur_X)
			begin
				change_height <= 1;
				PosX <= 640;
			end
			else
				PosX <= PosX - 2;
			frame_count2 <= 1;
		end
		else
			frame_count2 <= frame_count2 + 1;
	end
	//Random number
	logic Load_Seed, Done;
	logic [5:0] Seed;
	logic [5:0] rand_num;
	int pulse_counter;
	assign Seed = 6'b101010;
	
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
	
	//Change height according to the random number
	always_ff @ (posedge change_height)
	begin:Choose_height
		if (Cactus_PosX + Cactus_SizeX > 320)
			draw_type = None;
		else
		begin
			if (rand_num >= 6'd0 && rand_num < 6'd16)			//Possibility = 1/4
				draw_type = Height1;
			else if (rand_num >= 6'd16 && rand_num < 6'd48) //Possibility = 1/2
				draw_type = Height2;
			else															//Possibility = 1/4
				draw_type = Height3;
		end
	end
	
//	always_ff @ (posedge Clk50)
	always_comb
	begin
		if (draw_pt1)
			start = pterosaur1;
		else
			start = pterosaur2;
		offset = DistY*SizeX + DistX;
	end
	assign address = start + offset;
	
	always_comb
   begin:Pterosaur_on_wr_proc
	 if ((WriteX >= PosX || PosX < 0) &&
       (WriteX < PosX + pterosaur_X) &&
       (WriteY >= PosY) &&
       (WriteY < PosY + pterosaur_Y) &&
		 (~pt_off)
//		 && (istransparent == 1'b0)
		 )
      pterosaur_on_wr = 1'b1;
    else 
		pterosaur_on_wr = 1'b0;
   end
	
		always_comb
   begin:Pterosaur_on_proc
	 if ((DrawX >= PosX || PosX < 0) &&
       (DrawX < PosX + pterosaur_X) &&
       (DrawY >= PosY) &&
       (DrawY < PosY + pterosaur_Y) &&
		 (~pt_off)
//		 && (istransparent == 1'b0)
		 )
      pterosaur_on_dr = 1'b1;
    else 
		pterosaur_on_dr = 1'b0;
   end
endmodule
