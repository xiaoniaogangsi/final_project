//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//                                                                       --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 7                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module  gamelogic ( 	  input 					 Clk50, pixel_Clk, frame_Clk, Reset, blank,
							  input        [9:0]  DrawX, DrawY,
							  input 			[7:0]	 keycode,
							  input 			[7:0]  easter_egg,
                       output logic [7:0]  Red, Green, Blue );
	 
	logic [17:0] address_runner, address_cloud, address_score, address_horizon, address_moon;
	logic [17:0] address_cactus, address_pterosaur, address_over, address_hscore, address_heart;
	logic [17:0] draw_address;	//current Address for the picture we want to draw (start+offset)
	logic [3:0] color_index;		//color index we get from the ROM
	logic [3:0] color_index_buffer; //color index from frame_buffer
	logic [7:0] Red_p, Green_p, Blue_p;
	logic [9:0] PosX, PosY;		//The position of the dinosaur (up-left corner)
	
   logic runner_on_wr;	
	logic cloud_on_wr;
	logic [2:0] score_on_wr;	//000 means off, 001~101 means on1~on5.
	logic horizon_on_wr;
	logic cactus_on_wr;
	logic pterosaur_on_wr;
	logic [3:0] over_on_wr;
	logic [2:0] hscore_on_wr;
	logic heart_on_wr;
	logic [1:0] moon_on_wr;
	
	logic isnight;
  
	logic buffer_select;
	assign buffer_select = WriteY[0];
	
	int score;
	int Ptero_PosX, Ptero_PosY;
	int Fire_PosX, Fire_PosY;
	int Buff_PosX, Buff_PosY;
	int Cactus_PosX, Cactus_PosY;
	int Cactus_SizeX, Cactus_SizeY;
	int heart_PosX, heart_PosY;
	
	logic pt_off, ca_off, heart_off;
	logic contact, gift;
	
	logic[9:0] WriteX, WriteY;
  
	draw_runner runner0(.*, .Reset(Restart), .address(address_runner));
	draw_cloud cloud0(.*, .Reset(Restart), .address(address_cloud));
	draw_score score0(.*, .Reset(Restart), .address(address_score), .score_out(score));
	draw_horizon horizon0(.*, .Reset(Restart), .address(address_horizon));
	draw_cactus cactus0(.*, .Reset(Restart), .address(address_cactus));
	draw_pterosaur pterosaur0(.*, .Reset(Restart), .address(address_pterosaur));
	draw_over over0(.*, .Reset(Restart), .address(address_over));
	draw_hscore highscore0(.*, .address(address_hscore));	//Notice here we use Reset but not Restart to reset, because high score shouldn't be reset unless you press reset.
	draw_heart heart0(.*, .Reset(Restart),	.address(address_heart));
	draw_moon moon0(.*, .Reset(Restart), .address(address_moon));
	
	logic Dead;
	logic [1:0] Game_State;
	logic Restart;
	always_comb
	begin
		Restart = Reset | (Game_State == 2'b00);
	end
	
	control control0(.*,
					 .keycode(keycode),
					 .Dino_PosX(PosX), .Dino_PosY(PosY),
					 .Dead(Dead), .Game_State(Game_State));
	
	
	logic score_on_1bit, over_on_1bit, hscore_on_1bit, moon_on_1bit;
	assign score_on_1bit = (score_on_wr == 3'b000)? 1'b0 : 1'b1;
	assign over_on_1bit = (over_on_wr == 4'b0000)? 1'b0 : 1'b1;
	assign hscore_on_1bit = (hscore_on_wr == 3'b000)? 1'b0 : 1'b1;
	assign moon_on_1bit = (moon_on_wr == 2'b00)? 1'b0 : 1'b1;
	logic [2:0] write_which_layer;	//Indicate we are writing which layer, 000 means no writing.
	
	Draw_Engine draw(.*, 
						  .Draw_Back(~horizon_on_wr), .Draw_Ground(horizon_on_wr),   //layer_1
						  .Draw_Cloud(cloud_on_wr),  .Draw_Moon(moon_on_1bit),	//layer_2
						  .Draw_Cactus(cactus_on_wr), .Draw_Buff(heart_on_wr), .Draw_Rock(1'b0), .Draw_Pterosaur(pterosaur_on_wr), //layer_3
						  .Draw_Score(score_on_1bit), .Draw_Fire(1'b0), .Draw_Runner(runner_on_wr), .Draw_Highscore(hscore_on_1bit), .Draw_Over(over_on_1bit), //layer_4						   
						  
						  .address_Back(18'd20), .address_Ground(address_horizon), 
						  .address_Cloud(address_cloud),  .address_Moon(address_moon),
						  .address_Cactus(address_cactus), .address_Buff(address_heart), .address_Rock(18'd0), .address_Pterosaur(address_pterosaur),
						  .address_Score(address_score), .address_Fire(18'd0), .address_Runner(address_runner), .address_Highscore(address_hscore), .address_Over(address_over),
						  .DrawX(DrawX), .DrawY(DrawY),
						  .draw_address(draw_address),
						  .write_X(WriteX), .write_Y(WriteY),
						  .write_which_layer(write_which_layer));	

	logic [3:0] empty_data_in;
	assign empty_data_in = 4'b0000;
	logic [15:0] empty_addr;
	assign empty_addr = 0;
	logic [15:0] four_color_indices;	//color index we get from the ROM

	logic [15:0] rom_address;
	assign rom_address = draw_address[17:2];	//draw_address \ 4
	spriterom16 sprite0(.address_a(rom_address[15:0]),
							.address_b(empty_addr),
							.clock(~Clk50),
							.data_a(empty_data_in),
							.data_b(empty_data_in),
							.wren_a(1'b0),
							.wren_b(1'b0),
							.q_a(four_color_indices),
							.q_b(4'bZ));
	
	always_comb
	begin
		case (draw_address[1:0])
		2'b00:	color_index = four_color_indices[15:12];
		2'b01:	color_index = four_color_indices[11:8];
		2'b10:	color_index = four_color_indices[7:4];
		2'b11:	color_index = four_color_indices[3:0];
		endcase
	end

	logic transparent;
	
	always_comb
	begin:Judge_transparent
		if (color_index == 4'h0)	//Color index 0 means transparent color.
			transparent = 1;
		else
			transparent = 0;
	end
	
	logic [3:0] color_index_in;
	always_comb
	begin:Judge_background
		if (write_which_layer == 3'b001)		//When writing Layer 1 (Background)
		begin
			//In Layer 1, if this area is the horizon, but is transparent, still fill in the background color.
			if ((horizon_on_wr == 1'b1) && (transparent == 1'b1))
				color_index_in = 4'h4;	//Background color index
			else	//If this area is the horizon, and is not transparent, write the horizon in.
				color_index_in = color_index;	
		end
		else	//In other layers, take the color from the ROM directly
		begin
			color_index_in = color_index;	
		end
	end
	
	logic write_en;
	always_comb
	begin:Judge_write_en
		if (write_which_layer == 3'b001)		//When writing Layer 1 (Background)
			write_en = 1'b1;
		else	//In other layers, if it is transparent, we do not allow write, else you can write.
			write_en = ~transparent;
	end
	
	//Do synchronization before and after the frame buffer
	logic write_en_sync, buffer_select_sync;
	logic [9:0] WriteX_sync, WriteY_sync, DrawX_sync, DrawY_sync;
	logic [3:0] color_index_sync, color_index_buffer_sync;
	always_ff @ (posedge Clk50)
	begin:Sync_50
		write_en_sync <= write_en;
		color_index_sync <= color_index_in;
		buffer_select_sync <= buffer_select;
		WriteX_sync <= WriteX;
		WriteY_sync <= WriteY;
	end
	
	always_ff @ (posedge pixel_Clk)
	begin:Sync_25
		DrawX_sync <= DrawX;
		DrawY_sync <= DrawY;
		color_index_buffer_sync <= color_index_buffer;
	end
	
	frame_buffer frame_buffer0(.Clk50(~Clk50), .Reset(Reset), .write_en(write_en_sync),
										.write_data(color_index_sync),
										.write_X(WriteX_sync), .read_X(DrawX_sync),
										.write_Y(WriteY_sync), .read_Y(DrawY_sync),
										.select(buffer_select_sync),
										.read_data(color_index_buffer));
	
	always_comb
	begin
		if ((score > 200) && (score % 400 >= 0) && (score % 400 <= 200))
			isnight = 1'b1;
		else
			isnight = 1'b0;
	end
	
	palette palette0(.*, .color(color_index_buffer_sync),
				.Red(Red_p),
				.Green(Green_p),
				.Blue(Blue_p));

	always_ff @ (posedge pixel_Clk)
   begin:RGB_Display
		if (blank == 1'b0)
		begin
			Red <= 8'h00; 
			Green <= 8'h00;
			Blue <= 8'h00;
		end
		else
		begin
			Red <= Red_p;
			Green <= Green_p;
			Blue <= Blue_p;
		end
	end	
 
endmodule
