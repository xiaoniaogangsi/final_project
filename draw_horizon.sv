module draw_horizon (input Clk50, pixel_Clk, frame_Clk,
								input [9:0] WriteX, WriteY,
								input [9:0] DrawX, DrawY,
								output logic horizon_on_wr,
								output logic horizon_on_dr,
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
	
	initial
	begin
		PosX = 0;
		PosY = 400;
		frame_count = 1;
		start = horizon;
	end
	
	always_comb
	begin
		SizeX = horizon_X;
		SizeY = horizon_Y;
		DistX = WriteX - PosX;
		DistY = WriteY - PosY;
	end
	
	always_ff @ (posedge frame_Clk)
	begin
		if (frame_count == 1)
		begin
			start <= start + 2;
			if (start == horizon + 2400)
				start <= horizon;
			frame_count <= 1;
		end
		else
			frame_count <= frame_count + 1;
	end
	
	always_ff @ (posedge Clk50)
//	always_comb
	begin
		offset <= DistY*SizeX + DistX;
	end
	assign address = start + offset;
	
	always_comb
   begin:Horizon_on_wr_proc
	 if ((WriteX >= PosX) &&
       (WriteX < PosX + window_X) &&
       (WriteY >= PosY) &&
       (WriteY < PosY + horizon_Y)
//		 && (istransparent == 1'b0)
		 )
      horizon_on_wr = 1'b1;
    else 
		horizon_on_wr = 1'b0;
   end
	
		always_comb
   begin:Horizon_on_proc
	 if ((DrawX >= PosX) &&
       (DrawX < PosX + window_X) &&
       (DrawY >= PosY) &&
       (DrawY < PosY + horizon_Y)
//		 && (istransparent == 1'b0)
		 )
      horizon_on_dr = 1'b1;
    else 
		horizon_on_dr = 1'b0;
   end
endmodule
