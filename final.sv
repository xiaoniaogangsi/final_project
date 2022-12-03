`include "struct_declaration.sv"
//Purpose: the file controls the collision and movement and objects
//				   in the game. The module will output parallel draw signal to
//					render engine.
//Description: To integrate the module into the design:
//					1. ObstacleX and Y are the size of cactus or pterosaur;
//					2. use Dead signal to freeze the motion of cactus and pterosaur;
//					3. PosX and PoxY the same as defined in draw_cactus and draw_prerosaur
//					
//
module control (input Reset, frame_Clk,
					 input pt_off, ca_off,
					 input int Ptero_PosX, Ptero_PosY,
					 input int Fire_PosX, Fire_PosY,
					 input int Buff_PosX, Buff_PosY,
					 input int Cactus_PosX, Cactus_PosY,
					 input int Cactus_SizeX, Cactus_SizeY,
					 input [7:0] keycode,
					 output logic [9:0] Dino_PosX, Dino_PosY,
					 output logic Dead);
		int Ground_Level = 412; //take the middle of the gound sprite: 400 + 12.
		int Dragon_X_Pos = 120;
		int Dragon_Y_Pos = 412;
		int Dragon_X_Size = 88; //correct.
		int Dragon_Y_Size = 94; //correct.
		
		int Ptero_X_Size  = 92;
		int Ptero_Y_Size  = 80;
		int Gravity = 2;

		enum logic [3:0] {  		
							Start,
							Game,
							Over}   State, Next_State;   // Internal state logic
		
		enum logic [2:0] {
							REST,
							RUN,
							JUMP,
							DUCK,
							BUFF1, //renergy
							BUFF2, //fire mode
							DEAD}		Action;
		Dragon mydragon;	
		

		initial begin
		
		//initial_X_POS, initial_Y_POS, Y_MOTION, X_SIZE, Y_SIZE, LIFE, STATE
			mydragon = '{120, 412, 0, 88, 94, 1, 0};
		end
		
		//state machine that controls the user interface.
		always_ff @ (posedge frame_Clk)
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
		int Top, Bottom;
		int Right_Edge, Left_Edge;
		assign Top = mydragon.Dragon_Y_Pos - mydragon.Dragon_Y_Size/2;
		assign Bottom = mydragon.Dragon_Y_Pos + mydragon.Dragon_Y_Size/2; //take caution!
		assign Right_Edge = mydragon.Dragon_X_Pos + mydragon.Dragon_X_Size/2;
		assign Left_Edge =  mydragon.Dragon_X_Pos - mydragon.Dragon_X_Size/2;
		
		//control code of the little dragon
		always_ff @ (posedge frame_Clk)
		begin 
			//keycode processing
			case (keycode)
				8'h20 : //SPACE
				if (keycode == 8'h20 && Jump_counter < 60)
						Jump_counter <= Jump_counter+1;
				else if (Jump_counter<30)
							begin
								if (Bottom == Ground_Level)
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
								if (Bottom == Ground_Level)
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
					//mydragon.State <= Action;
				end
				default: ;
			endcase
			
			//simulation of gravity
			if (Bottom + mydragon.Dragon_Y_Motion >= Ground_Level)
			begin
				//when the dragon reach the ground in the next state, the motion will change to zero instantaneously.
				Action <= RUN;
				mydragon.Dragon_Y_Motion <= 0; 
				mydragon.Dragon_Y_Pos <= Ground_Level;
			end
			else 
			begin
				Action <= JUMP;
				mydragon.Dragon_Y_Motion <= (mydragon.Dragon_Y_Motion + Gravity);
				mydragon.Dragon_Y_Pos <= (mydragon.Dragon_Y_Pos + mydragon.Dragon_Y_Motion);
			end
		end
		
		int test_point1_x, test_point1_y;
		int test_point2_x, test_point2_y;
		int test_point3_x, test_point3_y;
		int test_point4_x, test_point4_y;
			
		assign test_point1_x = Right_Edge;
		assign test_point1_y = mydragon.Dragon_Y_Pos - mydragon.Dragon_Y_Size/2;
		
		assign test_point2_x = Right_Edge;
		assign test_point2_y = mydragon.Dragon_Y_Pos - mydragon.Dragon_Y_Size/4;
		
		assign test_point3_x = mydragon.Dragon_X_Pos;
		assign test_point3_y = mydragon.Dragon_Y_Pos - mydragon.Dragon_Y_Size/2;
		
		assign test_point4_x = mydragon.Dragon_X_Pos;
		assign test_point4_y = mydragon.Dragon_Y_Pos + mydragon.Dragon_Y_Size/4;
		
//		input int PosX, PosY,
//		input int ObstacleX, ObstacleY,
		//collision judgement between dragon and ptero.
		always_ff @ (posedge frame_Clk)
		begin
			if (pt_off == 0)
			begin
				if ((test_point1_x >= Ptero_PosX) && (test_point1_x < Ptero_PosX + Ptero_X_Size) && (test_point1_y >= Ptero_PosY) && (test_point1_y< Ptero_PosY + Ptero_Y_Size))
				begin
					Dead <= 1;
					Action <= DEAD;
					mydragon.Dragon_Y_Motion <= 0;
				end
				else if ((test_point2_x >= Ptero_PosX) && (test_point2_x < Ptero_PosX + Ptero_X_Size) && (test_point2_y >= Ptero_PosY) && (test_point2_y< Ptero_PosY + Ptero_Y_Size))
				begin
					Dead <= 1;
					Action <= DEAD;
					mydragon.Dragon_Y_Motion <= 0;
				end
				else if ((test_point3_x >= Ptero_PosX) && (test_point3_x < Ptero_PosX + Ptero_X_Size) && (test_point3_y >= Ptero_PosY) && (test_point3_y< Ptero_PosY + Ptero_Y_Size))
				begin
					Dead <= 1;
					Action <= DEAD;
					mydragon.Dragon_Y_Motion <= 0;
				end
				else if ((test_point4_x >= Ptero_PosX) && (test_point4_x < Ptero_PosX + Ptero_X_Size) && (test_point4_y >= Ptero_PosY) && (test_point4_y< Ptero_PosY + Ptero_Y_Size))
				begin
					Dead <= 1;
					Action <= DEAD;
					mydragon.Dragon_Y_Motion <= 0;
				end
				else 
					Dead <=0;
			end
			else 
				Dead <=0;
		end
		
		//collision judgement between dragon and cactus.
		always_ff @ (posedge frame_Clk)
		begin
			if (ca_off == 0)
			begin
				if ((test_point1_x >= Cactus_PosX) && (test_point1_x < Cactus_PosX + Cactus_SizeX) && (test_point1_y >= Cactus_PosY) && (test_point1_y< Cactus_PosY + Cactus_SizeY))
				begin
					Dead <= 1;
					Action <= DEAD;
					mydragon.Dragon_Y_Motion <= 0;
				end
				else if ((test_point2_x >= Cactus_PosX) && (test_point2_x < Cactus_PosX + Cactus_SizeX) && (test_point2_y >= Cactus_PosY) && (test_point2_y< Cactus_PosY + Cactus_SizeY))
				begin
					Dead <= 1;
					Action <= DEAD;
					mydragon.Dragon_Y_Motion <= 0;
				end
				else if ((test_point3_x >= Cactus_PosX) && (test_point3_x < Cactus_PosX + Cactus_SizeX) && (test_point3_y >= Cactus_PosY) && (test_point3_y< Cactus_PosY + Cactus_SizeY))
				begin
					Dead <= 1;
					Action <= DEAD;
					mydragon.Dragon_Y_Motion <= 0;
				end
				else if ((test_point4_x >= Cactus_PosX) && (test_point4_x < Cactus_PosX + Cactus_SizeX) && (test_point4_y >= Cactus_PosY) && (test_point4_y< Cactus_PosY + Cactus_SizeY))
				begin
					Dead <= 1;
					Action <= DEAD;
					mydragon.Dragon_Y_Motion <= 0;
				end
				else 
					Dead <=0;
			end
			else 
				Dead <=0;
		end
//		always_comb  //Produce Enter
//		begin
//		if (keycode == 8'h0c)
//			Enter = 1;
//		else
//			Enter = 0;
//		end

		assign Dino_PosX = Left_Edge;
		assign Dino_PosY = Top;
		
endmodule









		
							