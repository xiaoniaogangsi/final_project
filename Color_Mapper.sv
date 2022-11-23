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


module  color_mapper ( input 					 Clk50, pixel_Clk, frame_Clk, Reset, blank,
							  input        [9:0]  BallX, BallY, DrawX, DrawY, Ball_size,
                       output logic [7:0]  Red, Green, Blue );
    
    logic ball_on;
	 
	 /* test begin */
	 logic flag;
	 
	 /* test finish */
	 
 /* Old Ball: Generated square box by checking if the current pixel is within a square of length
    2*Ball_Size, centered at (BallX, BallY).  Note that this requires unsigned comparisons.
	 
    if ((DrawX >= BallX - Ball_size) &&
       (DrawX <= BallX + Ball_size) &&
       (DrawY >= BallY - Ball_size) &&
       (DrawY <= BallY + Ball_size))

     New Ball: Generates (pixelated) circle by using the standard circle formula.  Note that while 
     this single line is quite powerful descriptively, it causes the synthesis tool to use up three
     of the 12 available multipliers on the chip!  Since the multiplicants are required to be signed,
	  we have to first cast them from logic to int (signed by default) before they are multiplied). */
	  
    int DistX, DistY, Size;
	 int SizeX, SizeY;
//	   assign DistX = DrawX - BallX;
//    assign DistY = DrawY - BallY;
    assign Size = Ball_size;
	 
	 logic [17:0] address_runner, address_cloud, address_score;
	 logic [17:0] draw_address;	//current Address for the picture we want to draw (start+offset)
	 logic [3:0] color_index;		//color index we get from the ROM
	 logic [3:0] color_index_buffer; //color index from frame_buffer
	 logic [7:0]  Red_p, Green_p, Blue_p;
	 logic istransparent;
	 
	 logic cloud_on;
	 logic [9:0] cloud_locX, cloud_locY;
	 
//	 parameter [17:0] Trex = 18'd225383;
//	 parameter [17:0] Trex_X = 18'd88;
//	 parameter [17:0] Trex_Y = 18'd90;	
	
	 logic [2:0] score_on;	//000 means off, 001~101 means on1~on5.
	 
	draw_runner runner0(.*, .PosX(BallX), .PosY(BallY),
							.runner_on(ball_on),
							.address(address_runner));
	draw_cloud cloud0(.*, .address(address_cloud));
	draw_score score0(.*, .address(address_score));
	
	always_comb
	begin
		if (cloud_on)
			draw_address = address_cloud;
		else 
		begin
			if (score_on != 3'b000)
			begin
				draw_address = address_score;
			end
			else
			begin
				draw_address = address_runner;
			end
		end
	end
	
	// 800 horizontal pixels indexed 0 to 799
   // 525 vertical pixels indexed 0 to 524
   parameter [9:0] hpixels = 10'b1100011111;
   parameter [9:0] vlines = 10'b1000001100;
	logic [9:0] hc, vc;
	int loop_counter;
	always_ff @ (posedge Clk50 or posedge Reset )
	begin: counter_proc
		  if ( Reset ) 
			begin 
				 hc <= 10'b0000000000;
				 vc <= 10'b0000000000;
				 loop_counter <= 0;
			end
				
		  else 
			 if ( hc == hpixels )  //If hc has reached the end of pixel count
			  begin 
					hc <= 10'b0000000000;
					loop_counter <= loop_counter + 1;
					if ( vc == vlines )   //if vc has reached end of line count
						 vc <= 10'b0000000000;
					else 
					begin
						if (loop_counter == 1)
						begin
							vc <= (vc + 1);
							loop_counter <= 0;
						end
					end
			  end
			 else 
				  hc <= (hc + 1);  //no statement about vc, implied vc <= vc;
	 end 
	 
	spriteROM sprite(.read_address(draw_address),
							.Clk(pixel_Clk),
							.data_Out(color_index));
							
	frame_buffer frame_buffer0(.Clk(Clk50), .Reset(Reset), .write_en(1'b1),
										.write_data(color_index),
										.write_row(vc), .read_row(DrawY),
										.read_col(DrawX), .write_col(hc),
										.select(pixel_Clk),
										.read_data(color_index_buffer));
	
	palette palette0(.*, .color(color_index_buffer),
				.Red(Red_p),
				.Green(Green_p),
				.Blue(Blue_p),
				.clk(pixel_Clk));
	  
	 
    always_ff @ (posedge pixel_Clk)
    begin:RGB_Display
		flag<=0;
		if (blank == 1'b0)
		begin
			Red <= 8'h00; 
			Green <= 8'h00;
			Blue <= 8'h00;
		end
		else
		begin
        if (((ball_on == 1'b1) || (cloud_on == 1'b1) || (score_on != 3'b000)) && (istransparent == 1'b0)) 
        begin 
//				Red <= Red_p;
//				Green <= Green_p;
//				Blue <= Blue_p;
				flag<=1;
        end       
//        else
		  if (~flag) 
        begin 
//            Red <= 8'h00; 
//            Green <= 8'h00;
//            Blue <= 8'h7f - DrawX[9:3];
            Red <= 8'h7f; 
            Green <= 8'h7f;
            Blue <= 8'h7f;
        end
		  else
		  begin
				Red <= Red_p;
				Green <= Green_p;
				Blue <= Blue_p;
		  end
		  
		end
    end 
    
endmodule
