`include "struct_declaration.sv"
//Description: the file controls the collision and movement and objects
//				   in the game. The module will output parallel draw signal to
//					render engine.
module control (input Reset, frame_clk,
					 input [7:0] keycode,
					 output Dead,Enter);
		parameter [9:0] Dragon_X = 80;
		parameter [9:0] Ground_Level = 60;
		parameter [9:0] Dragon_X_Size = 10; //To be determinied
		parameter [9:0] Dragon_Y_Size = 20; //To be determinied
		parameter [9:0] Cactus_X_Size = 10; //To be determinied
		parameter [9:0] Gravity = 2;

		enum logic [3:0] {  		
							Start,
							Game,
							Over}   State, Next_State;   // Internal state logic
		
		enum logic [2:0] {
							REST,
							RUN,
							JUMP,
							DUCK,
							CAKE,
							DEAD}		Action;
		Dragon mydragon;	
		

		initial begin
		
		//X_POS, Y_POS, Y_MOTION, X_SIZE, Y_SIZE, LIFE, STATE
			mydragon = '{80, 60, 0, 10, 20, 1, 0};
		end
		
		//state machine that controls the user interface.
		always_ff @ (posedge frame_clk)
		begin
			if (keycode == 8'h0d)
				State <= Start;
			else
				State <= Next_State;
		end
		always_comb
		begin
			//default state is staying at the current state;
			Next_State = State;
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
			endcase
		end
		
		int Jump_counter;
		int Bottem = mydragon.Dragon_Y_Pos + mydragon.Dragon_Y_Size/2; //take caution!
		int Right_Edge = mydragon.Dragon_X_Pos + mydragon.Dragon_X_Size/2;
		int Left_Edge =  mydragon.Dragon_X_Pos - mydragon.Dragon_X_Size/2;
		
		//control code of the little dragon
		always_ff @ (posedge frame_clk)
		begin 
			//keycode processing
			case (keycode)
				8'h20 : //SPACE
				if (keycode == 8'h20 && Jump_counter < 60)
						Jump_counter <= Jump_counter+1;
				else if (Jump_counter<30)
							begin
								if (Bottem == Ground_Level)
								begin
									mydragon.Dragon_Y_Motion <= -10;
								end
								//press space on space, neglect.
								else
								begin
									mydragon.Dragon_Y_Motion <= mydragon.Dragon_Y_Motion;
								end
								//no matter how, clear the counter.
								Jump_counter <= 0;
							end
						//longer storage force
						else
							begin
								if (Bottem == Ground_Level)
								begin
									mydragon.Dragon_Y_Motion <= -20;
								end
								//press jump on space, neglect.
								else
								begin
									mydragon.Dragon_Y_Motion <= mydragon.Dragon_Y_Motion;
								end
								//no matter how, clear the counter.
								Jump_counter <= 0;
							end
							
				8'h26 : //DOWN
				begin
					Action <= DUCK;
					mydragon.State <= Action;
				end
				default: ;
			endcase
			
			//simulation of gravity
			if (Bottem + mydragon.Dragon_Y_Motion >= Ground_Level)
			begin
				//when the dragon reach the ground in the next state, the motion will change to zero instantaneously.
				mydragon.Dragon_Y_Motion <= 0; 
				mydragon.Dragon_Y_Pos <= Ground_Level;
			end
			else 
			begin
				mydragon.Dragon_Y_Motion <= (mydragon.Dragon_Y_Motion + Gravity);
				mydragon.Dragon_Y_Pos <= (mydragon.Dragon_Y_Pos + mydragon.Dragon_Y_Motion);
			end
		end
		
		//control code of the cactus.
//		always_ff @ (posedge frame_clk)
//		begin 
//			
//		end 
		
		//
		
		always_comb  //Produce Enter
		begin
		if (keycode == 8'h0c)
			Enter = 1;
		else
			Enter = 0;
		end
endmodule









		
							