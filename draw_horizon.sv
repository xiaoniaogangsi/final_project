module draw_horizon (input pixel_Clk, frame_Clk,
								input [9:0] WriteX, WriteY,
								input [9:0] DrawX, DrawY,
								output logic horizon_on_wr,
								output logic horizon_on_dr,
								output logic [17:0] address);

	//$readmemh("sprite/horizon_2400x24.txt", mem, 85015, 142614);
	parameter [17:0] horizon = 18'd85015;
	parameter [17:0] horizon_X = 18'd2400;
	parameter [17:0] horizon_Y = 18'd24;
	parameter [17:0] window_X = 18'd640;
	
	int frame_count;
	logic [17:0] start, offset;
	logic [9:0] PosX, PosY;
	int SizeX, SizeY, DistX, DistY;
	
	initial
	begin
		PosX = 10'd0;
		PosY = 10'd400;
		frame_count = 1;
		start = horizon;
	end
	
	always_comb
	begin
		SizeX = horizon_X;
		SizeY = horizon_Y;
		DistX = WriteX - PosX;
		DistY = DrawY - PosY;
	end
	
	always_ff @ (posedge frame_Clk)
	begin
		if (frame_count == 5)
		begin
			start <= start + 1;
			if (start == horizon + 2400)
				start <= horizon;
			frame_count <= 1;
		end
		else
			frame_count <= frame_count + 1;
	end
	
//	always_ff @ (posedge pixel_Clk)
	always_comb
	begin
		offset = DistY*SizeX + DistX;
		address = start + offset;
	end
	
	always_comb
   begin:Horizon_on_wr_proc
	 if ((WriteX >= PosX) &&
       (WriteX < PosX + window_X) &&
       (DrawY >= PosY) &&
       (DrawY < PosY + horizon_Y)
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
