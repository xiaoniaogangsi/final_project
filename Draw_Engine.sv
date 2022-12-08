module Draw_Engine (input Clk50, row_Clk, Reset,

					     input Dead, Enter,
						  
						  input Draw_Back, Draw_Ground,   //layer_1
						  input Draw_Cloud,  //layer_2
						  input Draw_Cactus, Draw_Buff, Draw_Rock, Draw_Pterosaur, //layer_3
						  input Draw_Score, Draw_Fire, Draw_Runner, Draw_Highscore, Draw_Over, //layer_4
						   
						  
						  input [17:0] address_Back, address_Ground, 
						  input [17:0] address_Cloud,  
						  input [17:0] address_Cactus, address_Buff, address_Rock, address_Pterosaur,
						  input [17:0] address_Score, address_Fire, address_Runner, address_Highscore, address_Over,
						  input [9:0] DrawX, DrawY,
						  output [17:0] draw_address,
						  output [9:0] write_X, write_Y,
						  output [2:0] write_which_layer
						  );
//	enum logic [1:0] {	WAIT, ADD} Counter_State, Counter_Next_State;
	
//	always_ff @ (posedge Clk50 or posedge Reset)
//	begin
//		if (Reset)
//		begin
//			Counter_State <= WAIT;
//			WriteX <= 10'b0000000000;
//			WriteY <= 10'b0000000000;
//		else
//			State <= Next_State;
//	end
//	
//	always_comb
//	begin
//		Counter_Next_State = Counter_State;
//		unique case (Counter_State)
//			WAIT: 
//				if (
//	end
	
	enum logic [3:0] {LAYER_1,
							LAYER_2,
							LAYER_3,
							LAYER_4,
							REST,
							PIXEL_FINISH
							}   State, Next_State;   // Internal state logic
	logic [9:0] WriteX, WriteY;
	logic Layer_1_on, Layer_2_on, Layer_3_on, Layer_4_on;
	logic [1:0] Layer_1_type;
	logic [3:0] Layer_3_type;
	logic [4:0] Layer_4_type;

	always_ff @ (posedge Clk50 or posedge Reset)
	begin
		if (Reset)
		begin
			State <= PIXEL_FINISH;
			//State <= LAYER_1;
			//WriteX <= 10'b0000000000;
			//WriteY <= 10'b0000000000;
		end
		else
			State <= Next_State;
	end
	
	always_comb
	begin
		if (DrawY == 524)
			WriteY = 0;
		else
			WriteY = DrawY + 1;
	end
	assign Layer_1_on = Draw_Back | Draw_Ground;
	assign Layer_2_on = Draw_Cloud;
	assign Layer_3_on = Draw_Cactus | Draw_Buff | Draw_Rock | Draw_Pterosaur;
	assign Layer_4_on = Draw_Score | Draw_Fire | Draw_Runner | Draw_Highscore | Draw_Over;
	
	assign Layer_1_type = {Draw_Back, Draw_Ground};
	assign Layer_3_type = {Draw_Cactus, Draw_Buff, Draw_Rock, Draw_Pterosaur};
	assign Layer_4_type = {Draw_Score, Draw_Fire,Draw_Runner, Draw_Highscore, Draw_Over};
	
	logic Smaller;		//Indicate whether WriteX is smaller than 640 (still inside the screen)
	always_comb //produce smaller
	begin
		if (WriteX<10'd640)
			Smaller = 1;
		else
			Smaller = 0;
	end
	
	always_comb
		begin
			//default state is staying at the current state;
			Next_State = State;
			unique case (State)
				LAYER_1 :
				begin
					if (Smaller == 0)
						Next_State = REST;
					else
					begin
						if (Layer_2_on == 0 && Layer_3_on == 0 && Layer_4_on == 0)
							Next_State = PIXEL_FINISH;
						else if (Layer_2_on)
							Next_State = LAYER_2;
						else if (Layer_2_on == 0 && Layer_3_on)
							Next_State = LAYER_3;
						else if (Layer_2_on == 0 && Layer_3_on == 0 && Layer_4_on) 
							Next_State = LAYER_4;
						else
							Next_State = PIXEL_FINISH;
					end
				end
				LAYER_2 :
				begin
					if (Smaller == 0)
						Next_State = REST;
					else
					begin
						if (Layer_2_on && Layer_3_on == 0 && Layer_4_on == 0)
							Next_State = PIXEL_FINISH;
						else if (Layer_2_on && Layer_3_on)
							Next_State = LAYER_3;
						else if (Layer_2_on && Layer_3_on == 0 && Layer_4_on)
							Next_State = LAYER_4;
						else
							Next_State = PIXEL_FINISH;
					end
				end
				LAYER_3 :
				begin
					if (Smaller == 0)
						Next_State = REST;
					else
					begin
						if (Layer_3_on && Layer_4_on == 0)
							Next_State = PIXEL_FINISH;
						else if (Layer_3_on && Layer_4_on)
							Next_State = LAYER_4;
						else 
							Next_State = PIXEL_FINISH;
					end
				end
				LAYER_4 : 
				begin
					if (Smaller == 0)
						Next_State = REST;
					else
						Next_State = PIXEL_FINISH;
				end
				PIXEL_FINISH :
				begin
					if (Smaller)	//If this pixel is still inside the screen
						Next_State = LAYER_1;
					else 				//Writing this line is finished, wait for DrawX finishes, and then DrawX and WriteX can start together.
						Next_State = REST;
				end
				REST :
				begin
					if (DrawX == 0)
						Next_State = LAYER_1;
					else 
						Next_State = REST;
				end
				//for debugging
				default : 
					Next_State = PIXEL_FINISH;
			endcase
		end
	
	always_comb
		begin
//			address_Back, address_Ground,  
//			address_Cloud,  
//			address_Cactus, address_Buff, address_Rock, address_Pterosaur,
//			address_Score，address_Fire,address_Runner, address_Highscore, address_Over,
			case (State)
				REST:	
				begin
					write_which_layer = 3'b000;
					draw_address = 18'd20;
				end
				LAYER_1 :
				begin
					write_which_layer = 3'b001;
					case (Layer_1_type)
						2'b10:
							draw_address = address_Back;
						2'b01:
							draw_address = address_Ground;
						default: 
							draw_address = 18'd20;
					endcase
				end
				LAYER_2 :
				begin
					write_which_layer = 3'b010;
					case (Draw_Cloud)
						1'b1: 
							draw_address = address_Cloud;
						default: 
							draw_address = 18'd20;
					endcase
				end
				LAYER_3 :
				begin
					write_which_layer = 3'b011;
					case (Layer_3_type)
						4'b1000 :
							draw_address = address_Cactus;
						4'b0100 :
							draw_address = address_Buff;
						4'b0010 :
							draw_address = address_Rock;
						4'b0001 :
							draw_address = address_Pterosaur;
						default : 
							draw_address = 18'd20;
					endcase
				end
				LAYER_4 :
				begin
					write_which_layer = 3'b100;
					case (Layer_4_type)
						5'b10000:
							draw_address = address_Score;
						5'b01000:
							draw_address = address_Fire;
						5'b00100:
							draw_address = address_Runner;
						5'b00010:	
							draw_address = address_Highscore;
						5'b00001:
							draw_address = address_Over;
						default: 
							draw_address = 18'd20;
					endcase
				end
				PIXEL_FINISH :
				begin
					write_which_layer = 3'b000;
					draw_address = 18'd0;
				end
			endcase
		end
		
		//produce WriteX
		//In this way, DrawX and WriteX will be synchronized after one REST state. Excellent!
		always_ff @ (posedge Clk50 or posedge Reset)
		begin
			if (Reset)
				WriteX <= 10'b0000000000;
			else
			begin
				if (State == REST)
					WriteX <= 10'b0000000000;
				else if (State == PIXEL_FINISH)
				begin
					WriteX <= WriteX + 1;
				end
				else 
					WriteX <= WriteX;
			end
		end
		
		assign write_X = WriteX;
		assign write_Y = WriteY;

	
		
		
endmodule