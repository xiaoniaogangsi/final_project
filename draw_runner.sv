module draw_runner(  input Clk50, pixel_Clk, frame_Clk, Reset,
							input [9:0] WriteX, WriteY,
							input [9:0] PosX, PosY,
							input Dead,
							output logic runner_on_wr,
							output logic [17:0] address);

	//$readmemh("sprite/run3_88x94.txt", mem, 207867, 216138);
	//$readmemh("sprite/run4_88x94.txt", mem, 216139, 224410);
	//$readmemh("sprite/die1_88x94.txt", mem, 46904, 55175);
	parameter [17:0] runner3 = 18'd207867;
	parameter [17:0] runner4 = 18'd216139;
	parameter [17:0] die1 = 18'd46904;
	int runner_X = 88;
	int runner_Y = 94;
	
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
		DistY = WriteY - PosY;
	end
	
	always_ff @ (posedge frame_Clk or posedge Reset)
	begin
		if (Reset)
		begin
			frame_count <= 1;
			draw_run3 <= 1'b1;
		end
		else
		begin
			if (frame_count == 10)
			begin
				draw_run3 <= ~(draw_run3);
				frame_count <= 1;
			end
			else
				frame_count <= frame_count + 1;
		end
	end
	
//	always_ff @ (posedge Clk50)
	always_comb
	begin
		if (Dead)
			start = die1;
		else
		begin
			if (draw_run3)
				start = runner3;
			else
				start = runner4;
		end
		offset = DistY*SizeX + DistX;
	end
	assign address = start + offset;
	
	always_comb
   begin:Runner_on_wr_proc
	 if ((WriteX >= PosX) &&
       (WriteX < PosX + runner_X) &&
       (WriteY >= PosY) &&
       (WriteY < PosY + runner_Y))
      runner_on_wr = 1'b1;
    else 
		runner_on_wr = 1'b0;
   end

endmodule
