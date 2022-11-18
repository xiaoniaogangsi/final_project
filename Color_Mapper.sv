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


module  color_mapper ( input 					 pixel_Clk, frame_Clk,
							  input        [9:0]  BallX, BallY, DrawX, DrawY, Ball_size,
                       output logic [7:0]  Red, Green, Blue );
    
    logic ball_on;
	 
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
	 assign DistX = DrawX - BallX;
    assign DistY = DrawY - BallY;
    assign Size = Ball_size;
	 
	 logic [17:0] draw_type;	//starting Address for the picture we want to draw
	 logic [3:0] color_index;	//color index we get from the ROM
	 logic [17:0] offset;
	 logic [7:0]  Red_p, Green_p, Blue_p;
	 logic istransparent;
	 logic draw_run3;
	 int frame_count;
	 
	 logic cloud_on;
	 logic [9:0] cloud_locX, cloud_locY;
	 
	 initial
	 begin
		draw_run3 = 1'b1;
		frame_count = 1;
		cloud_locX = 10'd640;
		cloud_locY = 10'd100;
	 end
	 
	 parameter [17:0] Trex = 18'd225383;
	 parameter [17:0] Trex_X = 18'd88;
	 parameter [17:0] Trex_Y = 18'd90;	
	
	 //$readmemh("sprite/run3_88x94.txt", mem, 207867, 216138);
	 //$readmemh("sprite/run4_88x94.txt", mem, 216139, 224410);	
	 parameter [17:0] runner3 = 18'd207867;
	 parameter [17:0] runner4 = 18'd216139;
	 parameter [17:0] runner_X = 18'd88;
	 parameter [17:0] runner_Y = 18'd94;
	 
	 //$readmemh("sprite/cloud_92x27.txt", mem, 44420, 46903);
	 parameter [17:0] cloud = 18'd44420;
	 parameter [17:0] cloud_X = 18'd92;
	 parameter [17:0] cloud_Y = 18'd27;
	 
	 int SizeX, SizeY;
	 assign SizeX = runner_X;
	 assign SizeY = runner_Y;
	 
	 always_ff @ (posedge frame_Clk)
	 begin
		if (frame_count == 5)
		begin
			if (cloud_locX == 0)
				cloud_locX = 10'd640;
			else
				cloud_locX <= cloud_locX - 1;
			draw_run3 <= ~(draw_run3);
			frame_count <= 1;
		end
		else
			frame_count <= frame_count + 1;
	 end
	 
	 always_ff @ (posedge pixel_Clk)
	 begin
		if (ball_on)
		begin
			offset <= DistY*SizeX + DistX;
			if (draw_run3)
				draw_type <= runner3;
			else
				draw_type <= runner4;
		end
		else if (cloud_on)
		begin
			offset <= (DrawY - cloud_locY) * cloud_X + (DrawX - cloud_locX);
			draw_type <= cloud;
		end
		else
		begin
			offset <= 18'b0;
			draw_type <= 18'b0;
		end
	 end
	 
	 spriteROM sprite(.read_address(draw_type + offset),
							.Clk(pixel_Clk),
							.data_Out(color_index));
	 palette palette0(.*, .color(color_index),
				.Red(Red_p),
				.Green(Green_p),
				.Blue(Blue_p));
	  

	 
    always_comb
    begin:Cloud_on_proc
	 if ((DrawX >= cloud_locX) &&
       (DrawX <= cloud_locX + cloud_X) &&
       (DrawY >= cloud_locY) &&
       (DrawY <= cloud_locY + cloud_Y)
		 && (istransparent == 1'b0)
		 && (ball_on == 1'b0))
            cloud_on = 1'b1;
        else 
            cloud_on = 1'b0;
     end 

	  
	 always_comb
    begin:Ball_on_proc
//        if ( ( DistX*DistX + DistY*DistY) <= (Size * Size) ) 
	 if ((DrawX >= BallX) &&
       (DrawX <= BallX + SizeX) &&
       (DrawY >= BallY) &&
       (DrawY <= BallY + SizeY)
		 && (istransparent == 1'b0))
            ball_on = 1'b1;
        else 
            ball_on = 1'b0;
     end 
	 
    always_ff @ (posedge pixel_Clk)
    begin:RGB_Display
        if ((ball_on == 1'b1) || (cloud_on == 1'b1)) 
        begin 
				Red <= Red_p;
				Green <= Green_p;
				Blue <= Blue_p;
        end       
        else 
        begin 
            Red <= 8'h00; 
            Green <= 8'h00;
            Blue <= 8'h7f - DrawX[9:3];
//            Red <= 8'hff - DrawY[9:3]; 
//            Green <= 8'hff - DrawY[9:3];
//            Blue <= 8'hff - DrawY[9:3];
        end      
    end 
    
endmodule
