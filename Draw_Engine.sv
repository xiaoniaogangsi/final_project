module Draw_Engine (input Clk50, row_Clk, Reset,

					     input Dead, Enter,
						  
						  input Draw_Back_or_Ground,   //layer_1
						  input Draw_Cloud,  //layer_2
						  input Draw_Cactus, Draw_Buff, Draw_Rock, Draw_Pterosaur, //layer_3
						  input Draw_Scoce, Draw_Fire,Draw_Runner, Draw_Start, Draw_Over, //layer_4
						   
						  
						  input address_Back,   
						  input address_Ground, 
						  input address_Cloud,  
						  input address_Cactus, address_Buff, address_Rock, address_Pterosaur,
						  input address_Scode，address_Fire,address_Runner, address_Start, address_Over,
						  input [9:0] DrawX, DrawY,
						  output [17:0] draw_address,
						  output [9:0] write_X, write_Y
						  );
	enum logic [3:0] {  		
								LAYER_1,
								LAYER_2,
								LAYER_3
								LAYER_4
								REST}   State, Next_State;   // Internal state logic
	logic [9:0] WriteX, WriteY;							
	always_ff @ (posedge Clk50 or posedge Reset)
	begin
		if (Reset)
		begin
			State <= LAYER_1;
			WriteX <= 10'b0000000000;
			WriteY <= 10'b0000000000;
		else
			State <= Next_State;
	end
	
	assign WriteY = DrawY + 1;
	assign Layer_1_on = Draw_Back_or_Ground;
	assign Layer_2_on = Draw_Cloud;
	assign Layer_3_on = Draw_Cactus | Draw_Buff | Draw_Rock | Draw_Pterosaur;
	assign Layer_4_on = Draw_Scoce | Draw_Fire | Draw_Runner | Draw_Start | Draw_Over;
	
	assign Layer_3_type = {Draw_Cactus, Draw_Buff, Draw_Rock, Draw_Pterosaur};
	assign Layer_4_type = {Draw_Scoce, Draw_Fire,Draw_Runner, Draw_Start, Draw_Over};
	
	always_comb //produce smaller
	begin
		if (WriteX<640 && WriteX>=0)
			Smaller = 1;
		else
			Smaller = 0;
	end
	
	always_comb
		begin
			//default state is staying at the current state;
			Next_State = State;
			unique case (State)
				REST :
					if (row_Clk == 0)
						Next_State = LAYER_1;
					else 
						Next_State = REST;
				LAYER_1:
					if (Layer_2_on == 0 && Layer_3_on == 0 && Layer_4_on == 0)
						Next_State = LAYER_1;
					else if (Layer_2_on)
						Next_State = LAYER_2;
					else if (Layer_2_on == 0 && Layer_3_on)
						Next_State = LAYER_3;
					else if (Layer_2_on == 0 && Layer_3_on == 0 && Layer_4_on) 
						Next_State = LAYER_4;
				LAYER_2 :
					if (Layer_2_on && Layer_3_on == 0 && Layer_4_on == 0)
						Next_State = LAYER_1;
					else if (Layer_2_on && Layer_3_on)
						Next_State = LAYER_3;
					else if (Layer_2_on && Layer_2_on == 0 && Layer_2_on)
						Next_State = LAYER_4;
					else
						Next_State = LAYER_1;
				LAYER_3 :
					if (Layer_3_on && Layer_4_on == 0)
						Next_State = LAYER_1;
					else if (Layer_3_on && Layer_4_on)
						Next_State = LAYER_4;
					else 
						Next_State = LAYER_1;
				LAYER_4 : 
					if (Smaller)
						Next_State = LAYER_1;
					else 
						Next_State = REST;
			endcase
		end

	
		
		
endmodule