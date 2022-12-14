module draw_cloud (	input frame_Clk, Reset,
							input [9:0] WriteX, WriteY,
							output logic cloud_on_wr,
							output logic [17:0] address);

	//$readmemh("sprite/cloud_92x27.txt", mem, 44420, 46903);
	parameter [17:0] cloud = 18'd44420;
	int cloud_X = 92;
	int cloud_Y = 27;
	int frame_count;	
	logic [17:0] start, offset;

	int PosX, PosY;
	int SizeX, SizeY, DistX, DistY;
	
	initial
	begin
		PosX = 640;
		PosY = 100;
		frame_count = 1;
	end

	always_comb
	begin
		SizeX = cloud_X;
		SizeY = cloud_Y;
   	DistX = WriteX - PosX;
		DistY = WriteY - PosY;
	end
	
	always_ff @ (posedge frame_Clk or posedge Reset)
	begin
		if (Reset)
		begin
			frame_count <= 1;
			PosX <= 640;
		end
		else
		begin
			if (frame_count == 1)
			begin
				if (PosX <= -cloud_X)
					PosX <= 640;
				else
					PosX <= PosX - 1;
				frame_count <= 1;
			end
			else
				frame_count <= frame_count + 1;
		end
	end
	
	always_comb
	begin
		start = cloud;
		offset = DistY*SizeX + DistX;
	end
	assign address = start + offset;
	 
	 always_comb
    begin:Cloud_on_wr_proc
		 if ((WriteX >= PosX || PosX<0) &&
			 (WriteX < PosX + cloud_X ) &&
			 (WriteY >= PosY) &&
			 (WriteY < PosY + cloud_Y))
			cloud_on_wr = 1'b1;
		 else 
			cloud_on_wr = 1'b0;
    end 
	 			
endmodule
