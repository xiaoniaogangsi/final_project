typedef struct{
					logic [9:0] Dragon_X_Pos, Dragon_Y_Pos, Dragon_Y_Motion,
					logic [9:0] Dragon_X_Size, // used for collision judgement.
					logic [9:0] Dragon_Y_Size,
					logic [1:0] Life,
					logic [2:0] State, //jump, run, get brithday cake, dead, rest
					} Dragon;
typedef struct{
					logic [9:0] Cactus_X_Pos, Cactus_Y_Pos, Cactus_X_Motion, //Horizontal Motion speed
					logic [9:0] Cactus_X_Size, Cactus_Y_Size,
					} Cactus;
typedef struct{
					logic [9:0] Ptero_X_Pos, Ptero_Y_Pos, Ptero_X_Motion, //Horizontal Motion speed
					logic [9:0] Ptero_X_Size, Ptero_Y_Size,
					} Ptero;
typedef struct{
					logic [9:0] Cloud_X_Pos, Cloud_Y_Pos, Cloud_X_Motion, //Horizontal Motion speed
					} Cloud;
typedef struct{
					logic [9:0] Star_X_Pos, Star_Y_Pos, Star_X_Motion, //Horizontal Motion speed
					} Star;
typedef struct{
					logic [9:0] Moon_X_Pos, Moon_Y_Pos, Moon_X_Motion, //Horizontal Motion speed
					} Moon; 