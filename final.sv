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
		parameter [9:0] gravity = 2;
//typedef struct{
//					logic [9:0] Dragon_X_Pos, Dragon_Y_Pos, Dragon_Y_Motion,
//					logic [9:0] Dragon_X_Size, // used for collision judgement.
//					logic [9:0] Dragon_Y_Size,
//					logic [1:0] Life,
//					logic [2:0] State, //rest, run, jump, get brithday cake, dead, 
//					} Dragon;
//typedef struct{
//					logic [9:0] Cactus_X_Pos, Cactus_Y_Pos, Cactus_X_Motion, //Horizontal Motion speed
//					logic [9:0] Cactus_X_Size, Cactus_Y_Size,
//					} Cactus;
//typedef struct{
//					logic [9:0] Ptero_X_Pos, Ptero_Y_Pos, Ptero_X_Motion, //Horizontal Motion speed
//					logic [9:0] Ptero_X_Size, Ptero_Y_Size,
//					} Ptero;
//typedef struct{
//					logic [9:0] Cloud_X_Pos, Cloud_Y_Pos, Cloud_X_Motion, //Horizontal Motion speed
//					} Cloud;
//typedef struct{
//					logic [9:0] Star_X_Pos, Star_Y_Pos, Star_X_Motion, //Horizontal Motion speed
//					} Star;
//typedef struct{
//					logic [9:0] Moon_X_Pos, Moon_Y_Pos, Moon_X_Motion, //Horizontal Motion speed
//					} Moon; 
		Dragon mydragon;
		mydragon = '{Dragon_x, Ground_Level, 0, Dragon_X_Size, Dragon_Y_Size, 1, 0};
		case (keycode):
			8'h20 : begin
						mydragon.Dragon_Y_Motion = -10;
						if ((mydragon.Dragon_X_Pos-Dragon_X_Size/2)<=Ground_Level)
							begin
								mydragon.Dragon_Y_Motion
							end	