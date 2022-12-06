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
					 //input int heart_PosX, heart_PosY,
					 //input logic heart_off,
					 input [7:0] keycode,
					 output logic [9:0] Dino_PosX, Dino_PosY,
					 output logic Dead,
					 //output logic contact,
					 output logic [1:0] Game_State);
		int Ground_Level = 412; //take the middle of the gound sprite: 400 + 12.
		int Dragon_X_Pos = 94;
		int Dragon_Y_Pos = 365;
		int Dragon_X_Size = 88; //correct.
		int Dragon_Y_Size = 94; //correct.
		
		int Ptero_X_Size  = 92;
		int Ptero_Y_Size  = 80;
		int Gravity = 3;

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
			mydragon = '{94, 367, 0, 88, 94, 1, 0};
		end
		
		//state machine that controls the user interface.
		always_ff @ (posedge frame_Clk or posedge Reset)
		begin
			if (Reset)
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
				begin
					if (keycode == 8'h2C || keycode == 8'h52)	//Press Space or Up to start
						Next_State = Game;
				end
				Game :
				begin
					if (mydragon.Life == 0)	//If dead, go to Over
						Next_State = Over;
				end
				Over: 
				begin
					if (keycode == 8'h28)	//Press Enter to restart
						Next_State = Start;
				end
			endcase
		end
		
		always_comb
		begin
			case (State)
				Start:
				begin
					Game_State = 2'b00;
				end
				Game:
				begin
					Game_State = 2'b01;
				end
				Over:
				begin
					Game_State = 2'b10;
				end
			endcase
		end
		
		int Jump_counter;
		initial begin
			Jump_counter = 0;
		end
		
		int Top, Bottom;
		int Right_Edge, Left_Edge;
		assign Top = mydragon.Dragon_Y_Pos - mydragon.Dragon_Y_Size/2;
		assign Bottom = mydragon.Dragon_Y_Pos + mydragon.Dragon_Y_Size/2; //take caution!
		assign Right_Edge = mydragon.Dragon_X_Pos + mydragon.Dragon_X_Size/2;
		assign Left_Edge =  mydragon.Dragon_X_Pos - mydragon.Dragon_X_Size/2;
		
		int frame_count;
		always_ff @ (posedge frame_Clk or posedge Reset)
		begin
			if (Reset)
				frame_count <= 0;
			else
			begin
				if (frame_count > 10)
					frame_count <= 0;
				else
					frame_count <= frame_count + 1;
			end
		end
		
		//control code of the little dragon
		always_ff @ (posedge frame_Clk)
		begin 
			if (State == Start)
			begin
				mydragon.Dragon_X_Pos <= 94;
				mydragon.Dragon_Y_Pos <= 365;
				mydragon.Dragon_Y_Motion <= 0;
			end
			else
			begin
				if (Dead)
				begin
					Action <= DEAD;
					mydragon.Dragon_Y_Motion <= 0;
				end
				else
				begin
					//keycode processing
					case (keycode)
						8'h2C, 8'h52 : //SPACE or UP
						begin
						if (Jump_counter < 30)
							Jump_counter <= Jump_counter+1;
						else
							Jump_counter <= 30;
						end
									
						8'h51 : //DOWN
						begin
							Action <= DUCK;
							Jump_counter <= Jump_counter;
							Gravity <= 3;
							//mydragon.State <= Action;
						end
						default: 
						begin
							Jump_counter <= Jump_counter;
							Gravity <= 3;
						end
					endcase
					
					if (keycode == 8'h00)
					begin
						if (Jump_counter > 0 && Jump_counter <= 15)
						begin
							if (Bottom == Ground_Level)
								mydragon.Dragon_Y_Motion <= -10;
								//press space in mid-air, neglect.
							else
								mydragon.Dragon_Y_Motion <= mydragon.Dragon_Y_Motion;
						end
						else if (Jump_counter > 15)
						begin
							if (Bottom == Ground_Level)
								mydragon.Dragon_Y_Motion <= -11;
								//press space in mid-air, neglect.
							else
								mydragon.Dragon_Y_Motion <= mydragon.Dragon_Y_Motion;
						end
					end
					else if ((keycode == 8'h2C || keycode == 8'h52) && Jump_counter == 30)
					begin
						if (Bottom == Ground_Level)
							mydragon.Dragon_Y_Motion <= -11;
							//press space in mid-air, neglect.
						else
							mydragon.Dragon_Y_Motion <= mydragon.Dragon_Y_Motion;
					end
					
					if (Bottom < Ground_Level)
						Jump_counter <= 0;
						
					//simulation of gravity
					if (Bottom + mydragon.Dragon_Y_Motion > Ground_Level)
					begin
						//when the dragon reach the ground in the next state, the motion will change to zero instantaneously.
						Action <= RUN;
						mydragon.Dragon_Y_Motion <= 0; 
						mydragon.Dragon_Y_Pos <= 365;
					end
					else 
					begin
						Action <= JUMP;
						if (frame_count == 10)
							mydragon.Dragon_Y_Motion <= (mydragon.Dragon_Y_Motion + Gravity);
						mydragon.Dragon_Y_Pos <= (mydragon.Dragon_Y_Pos + mydragon.Dragon_Y_Motion);
					end
					
				end
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

		logic Dead_ptero, Dead_cactus;
		//collision judgement between dragon and ptero.
		always_ff @ (posedge frame_Clk)
		begin
			if (pt_off == 0)
			begin
				if ((test_point1_x >= Ptero_PosX) && (test_point1_x < Ptero_PosX + Ptero_X_Size) && (test_point1_y >= Ptero_PosY) && (test_point1_y< Ptero_PosY + Ptero_Y_Size))
					Dead_ptero <= 1;
				else if ((test_point2_x >= Ptero_PosX) && (test_point2_x < Ptero_PosX + Ptero_X_Size) && (test_point2_y >= Ptero_PosY) && (test_point2_y< Ptero_PosY + Ptero_Y_Size))
					Dead_ptero <= 1;
				else if ((test_point3_x >= Ptero_PosX) && (test_point3_x < Ptero_PosX + Ptero_X_Size) && (test_point3_y >= Ptero_PosY) && (test_point3_y< Ptero_PosY + Ptero_Y_Size))
					Dead_ptero <= 1;
				else if ((test_point4_x >= Ptero_PosX) && (test_point4_x < Ptero_PosX + Ptero_X_Size) && (test_point4_y >= Ptero_PosY) && (test_point4_y< Ptero_PosY + Ptero_Y_Size))
					Dead_ptero <= 1;
				else 
					Dead_ptero <=0;
			end
			else 
				Dead_ptero <=0;
		end
		
		//collision judgement between dragon and cactus.
		always_ff @ (posedge frame_Clk)
		begin
			if (ca_off == 0)
			begin
				if ((test_point1_x >= Cactus_PosX) && (test_point1_x < Cactus_PosX + Cactus_SizeX) && (test_point1_y >= Cactus_PosY) && (test_point1_y< Cactus_PosY + Cactus_SizeY))
					Dead_cactus <= 1;
				else if ((test_point2_x >= Cactus_PosX) && (test_point2_x < Cactus_PosX + Cactus_SizeX) && (test_point2_y >= Cactus_PosY) && (test_point2_y< Cactus_PosY + Cactus_SizeY))
					Dead_cactus <= 1;
				else if ((test_point3_x >= Cactus_PosX) && (test_point3_x < Cactus_PosX + Cactus_SizeX) && (test_point3_y >= Cactus_PosY) && (test_point3_y< Cactus_PosY + Cactus_SizeY))
					Dead_cactus <= 1;
				else if ((test_point4_x >= Cactus_PosX) && (test_point4_x < Cactus_PosX + Cactus_SizeX) && (test_point4_y >= Cactus_PosY) && (test_point4_y< Cactus_PosY + Cactus_SizeY))
					Dead_cactus <= 1;
				else 
					Dead_cactus <=0;
			end
			else 
				Dead_cactus <=0;
		end
		//collision judgement between heart and dragon.
		always_ff @ (posedge frame_Clk)
		begin
			if (heart_off == 0)
			begin
				if ((heart_PosX >= Left_Edge && heart_PosX <Right_Edge && heart_PosY >= Top && heart_PosY < Bottom)
					contact <= 1;
					mydragon.Life <= mydragon.Life + 1;
			end
		end

		always_comb
		begin
			Dead = Dead_ptero | Dead_cactus;
			if (Dead)
				mydragon.Life = 0;
			else
				mydragon.Life = 1;
		end
		assign Dino_PosX = Left_Edge;
		assign Dino_PosY = Top;
		
endmodule









		
							