typedef struct packed{
					int Dragon_X_Pos;
					int Dragon_Y_Pos;
					int Dragon_Y_Motion;
					int Dragon_X_Size; // used for collision judgement.
					int Dragon_Y_Size;
					int Life;
					logic [2:0] State; //jump, run, get brithday cake, dead, rest
					} Dragon;
typedef struct packed{
					int Cactus_X_Pos;
					int Cactus_Y_Pos;
					int Cactus_X_Motion; //Horizontal Motion speed
					int Cactus_X_Size; 
					int Cactus_Y_Size;
					} Cactus;
typedef struct packed{
					int Ptero_X_Pos; 
					int Ptero_Y_Pos; 
					int Ptero_X_Motion; //Horizontal Motion speed
					int Ptero_X_Size; 
					int Ptero_Y_Size;
					} Ptero;
typedef struct packed{
					int Cloud_X_Pos; 
					int Cloud_Y_Pos; 
					int Cloud_X_Motion; //Horizontal Motion speed
					} Cloud;
typedef struct packed{
					int Star_X_Pos; 
					int Star_Y_Pos; 
					int Star_X_Motion; //Horizontal Motion speed
					} Star;
typedef struct packed{
					int Moon_X_Pos;
					int Moon_Y_Pos; 
					int Moon_X_Motion; //Horizontal Motion speed
					} Moon; 