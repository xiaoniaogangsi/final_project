module draw_heart ( input frame_Clk, Reset,
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

//	 $readmemh("memfiles/your_heart1_20x20.txt", mem, 258119, 258518);
//	 $readmemh("memfiles/your_heart2_20x20.txt", mem, 258519, 258918);
	parameter [17:0] heart1 = 18'd258119;
	parameter [17:0] heart2 = 18'd258519;

	int PosX, PosY;
	int X_Motion = -4;
	int heart_X = 20;
	int heart_Y = 20;
	
	int frame_count;
	logic draw_heart1;
	logic flag;
	logic [17:0] start, offset;
	int SizeX, SizeY, DistX, DistY;
	logic contact_flag;
	
	initial
	begin
		PosX = 1000;
		PosY = 256;
		frame_count = 1;
		draw_heart1 = 1'b1;
		contact_flag = 1'b0;
	end

	//control part
	always_ff @ (posedge frame_Clk or posedge Reset)
	begin
		if (Reset)
		begin
			contact_flag <= 0;
			heart_off <= 0;
		end
		else
		begin
			if (contact)
			begin
				contact_flag <= 1;
			end
			if (contact_flag)
				heart_off <= 1;
			if (PosX + heart_X < 0 || PosX >= 640)
			begin
				heart_off <= 0;
				contact_flag <= 0;
			end
		end
	end
	
	always_ff @ (posedge frame_Clk or posedge Reset)
	begin
		if (Reset)
		begin
			PosX <= 640;
			flag <= 0;
		end
		else
		begin
			if ((Game_State == 2'b00) || (Game_State == 2'b10) || Dead)
				X_Motion <= 0;
			else
			begin
				if (PosX + X_Motion <= -heart_X)
				begin
					flag<=0;
					PosX<=640;
					X_Motion <= 0;
				end
				else 
				begin
					if (score%500 > 100 && score%500 < 150 && Cactus_PosX < 320 && (Ptero_PosX<320||Ptero_PosX>670))
					begin
						flag<=1;
						X_Motion <= -4;
					end
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
		end
	end
	
	always_ff @ (negedge frame_Clk or posedge Reset)
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