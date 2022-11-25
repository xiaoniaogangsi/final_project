module Draw_Engine (input Clk50, row_Clk,

					     input Dead, Enter,
						  
						  input Draw_Back,   //layer_1
						  input Draw_Ground, //layer_2
						  input Draw_Cloud,  //layer_3
						  input Draw_Cactus, Draw_Buff, Draw_Rock, Draw_Pterosaur, //layer_4
						  input Draw_Scode，Draw_Fire,Draw_Runner,  //layer_5
						   
						  
						  input address_Back,   
						  input address_Ground, 
						  input address_Cloud,  
						  input address_Cactus, address_Buff, address_Rock, address_Pterosaur,
						  input address_Scode，address_Fire,address_Runner,
						  output [17:0] draw_address;
						  output [9:0] write_X, write_Y
						  );
//	enum logic [3:0] {  		
//								Start,
//								Game,
//								Over}   State, Next_State;   // Internal state logic
//								
//	always_ff @ (posedge frame_clk)
//	begin
//		if (keycode == 8'h0c)
//			State <= Start;
//		else
//			State <= Next_State;
//	end
//	
//	always_comb
//		begin
//			//default state is staying at the current state;
//			Next_State = State;
//			unique case (State)
//				Start:
//					if (keycode == 8'h20)
//						Next_State = Game;
//				Game :
//					if (mydragon.Life == 0)
//						Next_State = Over;
//				Over: 
//					if (keycode == 8'h0d)
//						Next_State = Start;
//			endcase
//		end

	
		
		
endmodule