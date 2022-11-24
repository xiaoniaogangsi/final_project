module draw_cloud (	input pixel_Clk, frame_Clk,
							input [9:0] WriteX, WriteY,
							input [9:0] DrawX, DrawY,
							output logic cloud_on,
							output logic [17:0] address);

	//$readmemh("sprite/cloud_92x27.txt", mem, 44420, 46903);
	parameter [17:0] cloud = 18'd44420;
	parameter [17:0] cloud_X = 18'd92;
	parameter [17:0] cloud_Y = 18'd27;
	
	int frame_count;	
	logic [17:0] start, offset;
	logic [9:0] PosX, PosY;
	int SizeX, SizeY, DistX, DistY;
	
	initial
	begin
		PosX = 10'd640;
		PosY = 10'd100;
		frame_count = 1;
	end

	always_comb
	begin
		SizeX = cloud_X;
		SizeY = cloud_Y;
		DistX = WriteX - PosX;
		DistY = WriteY - PosY;
	end
	
	always_ff @ (posedge frame_Clk)
	begin
		if (frame_count == 10)
		begin
			if (PosX == 10'b0)
				PosX <= 10'd640;
			else
				PosX <= PosX - 1;
			frame_count <= 1;
		end
		else
			frame_count <= frame_count + 1;
	end
	
//	always_ff @ (posedge pixel_Clk)
	always_comb
	begin
		start = cloud;
		offset = DistY*SizeX + DistX;
		address = start + offset;
	end
	
	 always_comb
    begin:Cloud_on_proc
		 if ((DrawX >= PosX) &&
			 (DrawX < PosX + cloud_X) &&
			 (DrawY >= PosY) &&
			 (DrawY < PosY + cloud_Y)
	//		 && (istransparent == 1'b0)
	//		 && (ball_on == 1'b0)
			 )
			cloud_on = 1'b1;
		 else 
			cloud_on = 1'b0;
    end 
	
							
endmodule
