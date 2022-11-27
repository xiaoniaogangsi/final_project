module draw_cloud (	input Clk50, pixel_Clk, frame_Clk,
							input [9:0] WriteX, WriteY,
							input [9:0] DrawX, DrawY,
							output logic cloud_on_wr,
							output logic cloud_on_dr,
							output logic [17:0] address);

	//$readmemh("sprite/cloud_92x27.txt", mem, 44420, 46903);
	parameter [17:0] cloud = 18'd44420;
	parameter [9:0] cloud_X = 10'd92;
	parameter [9:0] cloud_Y = 10'd27;
	
	int frame_count;	
	logic [17:0] start, offset;
	logic [9:0] PosX, PosY;
	int SizeX, SizeY, DistX, DistY;
	
	logic [9:0] DrawX_new, WriteX_new;
	
	initial
	begin
		PosX = 10'd640;
		PosY = 10'd100;
		frame_count = 1;
	end
	
	always_comb
	begin
		DrawX_new = DrawX + cloud_X;
		WriteX_new = WriteX + cloud_X;
	end

	always_comb
	begin
		SizeX = cloud_X;
		SizeY = cloud_Y;
		DistX = WriteX_new - PosX;
		DistY = WriteY - PosY;
	end
	
	always_ff @ (posedge frame_Clk)
	begin
		if (frame_count == 1)
		begin
			if ((~PosX)+1  == cloud_X)
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
		start <= cloud;
		offset <= DistY*SizeX + DistX;
	end
	assign address = start + offset;

	 always_comb
    begin:Cloud_on_proc
		 if ((DrawX_new >= PosX) &&
			 (DrawX_new < PosX + cloud_X) &&
			 (DrawY >= PosY) &&
			 (DrawY < PosY + cloud_Y)
	//		 && (istransparent == 1'b0)
	//		 && (ball_on == 1'b0)
			 )
			cloud_on_dr = 1'b1;
		 else 
			cloud_on_dr = 1'b0;
    end 	 
	 
	 always_comb
    begin:Cloud_on_wr_proc
		 if ((WriteX_new >= PosX) &&
			 (WriteX_new < PosX + cloud_X) &&
			 (WriteY >= PosY) &&
			 (WriteY < PosY + cloud_Y)
	//		 && (istransparent == 1'b0)
	//		 && (ball_on == 1'b0)
			 )
			cloud_on_wr = 1'b1;
		 else 
			cloud_on_wr = 1'b0;
    end 
	 			
endmodule
