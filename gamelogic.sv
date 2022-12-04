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


module  gamelogic ( 	  input 					 Clk50, pixel_Clk, frame_Clk, Reset, blank, row_Clk,
							  input        [9:0]  DrawX, DrawY,
							  input 			[7:0]	 keycode,
                       output logic [7:0]  Red, Green, Blue );
	 
	logic [17:0] address_runner, address_cloud, address_score, address_horizon, address_cactus, address_pterosaur;
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
	
	logic isnight;
  
	logic buffer_select;
	assign buffer_select = WriteY[0];
	
	int score;
	int Ptero_PosX, Ptero_PosY;
	int Fire_PosX, Fire_PosY;
	int Buff_PosX, Buff_PosY;
	int Cactus_PosX, Cactus_PosY;
	int Cactus_SizeX, Cactus_SizeY;
	
	logic pt_off, ca_off;
	
	logic[9:0] WriteX, WriteY;
  
	draw_runner runner0(.*, .address(address_runner));
	draw_cloud cloud0(.*, .address(address_cloud));
	draw_score score0(.*, .address(address_score), .score_out(score));
	draw_horizon horizon0(.*, .address(address_horizon));
	draw_cactus cactus0(.*, .address(address_cactus));
	draw_pterosaur pterosaur0(.*, .address(address_pterosaur));
	
	logic Dead, Enter;
	
	control control0(.*,
					 .keycode(keycode),
					 .Dino_PosX(PosX), .Dino_PosY(PosY),
					 .Dead(Dead));
	
	
	logic score_on_1bit;
	assign score_on_1bit = (score_on_wr == 3'b000)? 1'b0 : 1'b1;
	logic [2:0] write_which_layer;	//Indicate we are writing which layer, 000 means no writing.
	
	Draw_Engine draw(.*, 
						  .Draw_Back(~horizon_on_wr), .Draw_Ground(horizon_on_wr),   //layer_1
						  .Draw_Cloud(cloud_on_wr),  //layer_2
						  .Draw_Cactus(cactus_on_wr), .Draw_Buff(1'b0), .Draw_Rock(1'b0), .Draw_Pterosaur(pterosaur_on_wr), //layer_3
						  .Draw_Score(score_on_1bit), .Draw_Fire(1'b0), .Draw_Runner(runner_on_wr), .Draw_Start(1'b0), .Draw_Over(1'b0), //layer_4						   
						  
						  .address_Back(18'd20), .address_Ground(address_horizon), 
						  .address_Cloud(address_cloud),  
						  .address_Cactus(address_cactus), .address_Buff(18'd0), .address_Rock(18'd0), .address_Pterosaur(address_pterosaur),
						  .address_Score(address_score), .address_Fire(18'd0), .address_Runner(address_runner), .address_Start(18'd0), .address_Over(18'd0),
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
	begin
		if (color_index == 4'h0)	//Color index 0 means transparent color.
			transparent = 1;
		else
			transparent = 0;
	end
	
	logic [3:0] color_index_in;
	always_comb
	begin
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
	begin
		if (write_which_layer == 3'b001)		//When writing Layer 1 (Background)
			write_en = 1'b1;
		else	//In other layers, if it is transparent, we do not allow write, else you can write.
			//write_en = ~transparent_in;
			write_en = ~transparent;
	end
	
	frame_buffer frame_buffer0(.Clk50(~Clk50), .pixel_Clk(~pixel_Clk), .Reset(Reset), .write_en(write_en),
										.write_data(color_index_in),
										.write_X(WriteX), .read_X(DrawX),
										.write_Y(WriteY), .read_Y(DrawY),
										.select(buffer_select),
										.read_data(color_index_buffer));
	
	always_comb
	begin
		if ((score > 200) && (score % 700 >= 0) && (score % 700 <= 200))
			isnight = 1'b1;
		else
			isnight = 1'b0;
	end
	
	palette palette0(.*, .color(color_index_buffer),
				.Red(Red_p),
				.Green(Green_p),
				.Blue(Blue_p));
	  
	 
//	logic horizon_on_wr_delay;
//	always_ff @ (posedge Clk50)
//	begin
//		horizon_on_wr_delay <= horizon_on_wr;
//	end

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
