`include "struct_declaration.sv"
//Description: the file controls the collision and movement and objects
//				   in the game. The module will output parallel draw signal to
//					render engine.
module control (input Reset, frame_clk,
					 input [7:0] keycode,
					 output Dead,);
		parameter [9:0] Drangon_X = 80;
		parameter [9:0] Ground_Level = 60;
		parameter [9:0] Dragon_X_Size = 10; //To be determinied
		parameter [9:0] Dragon_Y_Size = 20; //To be determinied
		parameter [9:0] Cactus_X_Size = 10; //To be determinied
		parameter [9:0] Gravity = 2;

		enum logic [3:0] {  		
							Start,
							Game,
							Over}   State, Next_state;   // Internal state logic
		
		enum logic [2:0] {
							Rest,
							Run,
							Jump,
							Lean,
							Cake,
							Dead}		Action;

		Dragon mydragon;
		mydragon = '{Dragon_x, Ground_Level, 0, Dragon_X_Size, Dragon_Y_Size, 1, 0};
		
		
		//state machine that controls the user interface.
		always_ff @ (posedge frame_clk)
		begin
			if (keycode = 8'h0c)
				State <= Start;
			else
				State <= Next_State;
		end
		always_comb @ (posedge frame_clk)
		begin
			//default state is staying at the current state;
			Next_State <= state;
			unique case (State)
				Start:
					if (keycode == 8'h20)
						Next_State = Game;
				Game :
					if (mydragon.Life == 0)
						Next_State = Over;
				Over: 
					if (keycode == 8'h0d)
						Next_State = Start;
		end
		
		
		//control code of the little dragon
		always_ff @ (posedge frame_clk)
		begin:
			//keycode processing
			case (keycode):
				8'h20 : begin
								if (mydragon.Dragon_Y_Pos <= Ground_level)
									mydragon.Dragon_Y_Motion <= -10;
						  end
				8'h26 : begin
								Action <= Lean;
								mydragon.State <= Action;
						  end
				default:
			endcase
			//simulation of gravity
			if (mydragon.Dragon_Y_Pos <= Ground_level)
				mydragon.Dragon_Y_Motion <= (mydragon.Dragon_Y_Motion + Gravity);
			mydragon.Dragon_Y_Pos <= (mydragon.Dragon_Y_Pos + mydragon.Dragon_Y_Motion);
		end	











		
							