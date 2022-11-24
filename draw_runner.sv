module draw_runner(  input pixel_Clk, frame_Clk,
							input [9:0] WriteX, WriteY,
							input [9:0] DrawX, DrawY,
							input [9:0] PosX, PosY,
							output logic runner_on_dr,
							output logic runner_on_wr,
							output logic [17:0] address);

	//$readmemh("sprite/run3_88x94.txt", mem, 207867, 216138);
	//$readmemh("sprite/run4_88x94.txt", mem, 216139, 224410);
	parameter [17:0] runner3 = 18'd207867;
	parameter [17:0] runner4 = 18'd216139;
	parameter [17:0] runner_X = 18'd88;
	parameter [17:0] runner_Y = 18'd94;
	
	int frame_count;
	logic draw_run3;
	logic [17:0] start, offset;
	int SizeX, SizeY, DistX, DistY;
	
	initial
	begin
		frame_count = 1;
		draw_run3 = 1'b1;
	end
	
	always_comb
	begin
		SizeX = runner_X;
		SizeY = runner_Y;
		DistX = WriteX - PosX;
		DistY = DrawY - PosY;
	end
	
	always_ff @ (posedge frame_Clk)
	begin
		if (frame_count == 10)
		begin
			draw_run3 <= ~(draw_run3);
			frame_count <= 1;
		end
		else
			frame_count <= frame_count + 1;
	end
	
//	always_ff @ (posedge pixel_Clk)
	always_comb
	begin
		if (draw_run3)
			start = runner3;
		else
			start = runner4;
		offset = DistY*SizeX + DistX;
		address = start + offset;
	end
	
	always_comb
   begin:Runner_on_wr_proc
	 if ((WriteX >= PosX) &&
       (WriteX < PosX + runner_X) &&
       (DrawY >= PosY) &&
       (DrawY < PosY + runner_Y)
//		 && (istransparent == 1'b0)
		 )
      runner_on_wr = 1'b1;
    else 
		runner_on_wr = 1'b0;
   end
	
		always_comb
   begin:Runner_on_proc
	 if ((DrawX >= PosX) &&
       (DrawX < PosX + runner_X) &&
       (DrawY >= PosY) &&
       (DrawY < PosY + runner_Y)
//		 && (istransparent == 1'b0)
		 )
      runner_on_dr = 1'b1;
    else 
		runner_on_dr = 1'b0;
   end
endmodule
