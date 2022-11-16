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


module  color_mapper ( input 					 pixel_Clk,
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
	 initial
	 begin
		draw_type = 18'd225383;
		offset = 1'b0;
	 end
	 
	 spriteROM sprite(.read_address(draw_type + offset),
							.Clk(pixel_Clk),
							.data_Out(color_index));
	 palette(.*, .color(color_index),
				.Red(Red_p),
				.Green(Green_p),
				.Blue(Blue_p));
	  
    always_comb
    begin:Ball_on_proc
//        if ( ( DistX*DistX + DistY*DistY) <= (Size * Size) ) 
	 if ((DrawX >= BallX - 44) &&
       (DrawX <= BallX + 44) &&
       (DrawY >= BallY - 45) &&
       (DrawY <= BallY + 45))
            ball_on = 1'b1;
        else 
            ball_on = 1'b0;
     end 
       
    always_ff @ (posedge pixel_Clk)
    begin:RGB_Display
        if ((ball_on == 1'b1)) 
        begin 
            offset <= offset + 1;
				Red <= Red_p;
				Green <= Green_p;
				Blue <= Blue_p;
        end       
        else 
        begin 
            Red <= 8'h00; 
            Green <= 8'h00;
            Blue <= 8'h7f - DrawX[9:3];
        end      
    end 
    
endmodule
