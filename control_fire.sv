module fire_control (input frame_Clk, Reset,
							input Speed_up, Dead,
							input int score,
							input int Dragon_Y_Pos, Dragon_X_Pos,
							input [7:0] keycode,
							output [9:0]  FireX, FireY);
	int Ground_Level = 412; //take the middle of the gound sprite: 400 + 12.
	int Dragon_X_Size = 88; //correct.
	int Dragon_Y_Size = 94; //correct.
	
	int Ptero_X_Size  = 92;
	int Ptero_Y_Size  = 80;
	int Gravity = 2;
	
	int fire_off;
	int X_Motion, Y_Motion;
	
	initial
	begin
		FireX = 640;
		FireY = 412;
		fire_off =1;
	end  
	
	always_comb 
	begin
		if (Dead)
		begin
			Y_Motion = 0;
			X_Motion = 0;
		end
		else if (Speed_up)
			X_Motion = X_Motion*2;
		else
			X_Motion = X_Motion;
	end
	
	always_ff @ (posedge frame_Clk)
	begin
		if (score % 500 == 499 && fire_off)
		begin 
			fire_off <= 0;
			X_Motion <= -2;
			FireX <= FireX + X_Motion;
		end
		else
		begin
			fire_off <= 0;
		end
	end

	//collision judgement between dragon and ptero.
	always_ff @ (posedge frame_Clk)
	begin
		if (fire_off == 0)
		begin
			if ((FireX >= Dragon_X_Pos) && (FireX < Dragon_X_Pos + Dragon_X_Size) && (FireY >= Dragon_Y_Pos) && (FireY< Dragon_Y_Pos + Dragon_Y_Size))
			begin
				
				//Action <= Buff1;
				mydragon.Dragon_Y_Motion <= 0;
			end
			
		else 
			Dead <=0;
		end
	end
endmodule	