typedef struct packed{
					logic [9:0] Dragon_X_Pos;
					logic [9:0] Dragon_Y_Pos;
					logic [9:0] Dragon_Y_Motion;
					logic [9:0] Dragon_X_Size; // used for collision judgement.
					logic [9:0] Dragon_Y_Size;
					logic [1:0] Life;
					logic [2:0] State; //jump, run, get brithday cake, dead, rest
					} Dragon;
typedef struct packed{
					logic [9:0] Cactus_X_Pos;
					logic [9:0] Cactus_Y_Pos;
					logic [9:0] Cactus_X_Motion; //Horizontal Motion speed
					logic [9:0] Cactus_X_Size; 
					logic [9:0] Cactus_Y_Size;
					} Cactus;
typedef struct packed{
					logic [9:0] Ptero_X_Pos; 
					logic [9:0] Ptero_Y_Pos; 
					logic [9:0] Ptero_X_Motion; //Horizontal Motion speed
					logic [9:0] Ptero_X_Size; 
					logic [9:0] Ptero_Y_Size;
					} Ptero;
typedef struct packed{
					logic [9:0] Cloud_X_Pos; 
					logic [9:0] Cloud_Y_Pos; 
					logic [9:0] Cloud_X_Motion; //Horizontal Motion speed
					} Cloud;
typedef struct packed{
					logic [9:0] Star_X_Pos; 
					logic [9:0] Star_Y_Pos; 
					logic [9:0] Star_X_Motion; //Horizontal Motion speed
					} Star;
typedef struct packed{
					logic [9:0] Moon_X_Pos;
					logic [9:0] Moon_Y_Pos; 
					logic [9:0] Moon_X_Motion; //Horizontal Motion speed
					} Moon; 