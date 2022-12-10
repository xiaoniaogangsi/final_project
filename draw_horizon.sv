module draw_horizon (input frame_Clk, Reset,
								input [9:0] WriteX, WriteY,
								input Dead,
								input [1:0] Game_State,
								output logic horizon_on_wr,
								output logic [17:0] address);

	//$readmemh("sprite/horizon_2400x24.txt", mem, 85015, 142614);
	parameter [17:0] horizon = 18'd85015;
	int horizon_X = 2400;
	int horizon_Y = 24;
	int window_X = 640;
	
	int frame_count;
	logic [17:0] start, offset;
	int PosX, PosY;
	int SizeX, SizeY, DistX, DistY;
	
	int X_Motion;
	int frame_PosX;	//The X Position of the first pixel in the screen, ranges from 0 to 2399.
	
	initial
	begin
		PosX = 0;
		PosY = 400;
		frame_PosX = 0;
		frame_count = 1;
		start = horizon;
		X_Motion = 4;
	end
	
	always_comb
	begin
		SizeX = horizon_X;
		SizeY = horizon_Y;
		DistX = WriteX - PosX;
		DistY = WriteY - PosY;
	end
	
	always_comb
	begin
		if ((Game_State == 2'b00) || (Game_State == 2'b10) || Dead)
			X_Motion = 0;
		else
			X_Motion = 4;
	end
	
	always_ff @ (posedge frame_Clk or posedge Reset)
	begin
		if (Reset)
		begin
			PosX <= 0;
			PosY <= 400;
			frame_count <= 1;
			start <= horizon;
			frame_PosX <= 0;
		end
		else
		begin
			if (frame_count == 1)
			begin
				if (start + X_Motion >= horizon + 2400)
				begin
					start <= horizon;
					frame_PosX <= 0;
				end
				else
				begin
					start <= start + X_Motion;
					frame_PosX <= frame_PosX + X_Motion;
				end
				frame_count <= 1;
			end
			else
				frame_count <= frame_count + 1;
		end
	end
	
	always_comb
	begin
		offset = DistY*SizeX + DistX;
		if (frame_PosX + DistX >= 2400)		//Circularly pick pixels
			address = start + offset - 2400;
		else 
			address = start + offset;
	end
	
	always_comb
   begin:Horizon_on_wr_proc
	 if ((WriteX >= PosX) &&
       (WriteX < PosX + window_X) &&
       (WriteY >= PosY) &&
       (WriteY < PosY + horizon_Y))
      horizon_on_wr = 1'b1;
    else 
		horizon_on_wr = 1'b0;
   end

endmodule
