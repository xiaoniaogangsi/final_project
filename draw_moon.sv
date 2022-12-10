module draw_moon(input frame_Clk, Reset,
					input [9:0] WriteX, WriteY,
					input isnight,
					output logic [1:0] moon_on_wr,
					output logic [17:0] address);

//	 $readmemh("sprite/moon_full_80x80.txt", mem, 142615, 149014);
//	 $readmemh("sprite/moon_left1_40x80.txt", mem, 149015, 152214);
//	 $readmemh("sprite/moon_left2_40x80.txt", mem, 152215, 155414);
//	 $readmemh("sprite/moon_left3_40x80.txt", mem, 155415, 158614);
//	 $readmemh("sprite/moon_right1_40x80.txt", mem, 158615, 161814);
//	 $readmemh("sprite/moon_right2_40x80.txt", mem, 161815, 165014);
//	 $readmemh("sprite/moon_right3_40x80.txt", mem, 165015, 168214);

//	 $readmemh("sprite/star1_18x17.txt", mem, 224411, 224716);
//	 $readmemh("sprite/star2_18x19.txt", mem, 224717, 225058);
//	 $readmemh("sprite/star3_18x18.txt", mem, 225059, 225382);
	
	logic [17:0] moon [0:6];
	logic [17:0] star [0:2];
	always_comb
	begin
		moon[0] = 18'd142615; 
	   moon[1] = 18'd149015;
	   moon[2] = 18'd152215;
	   moon[3] = 18'd155415;
	   moon[4] = 18'd158615;
	   moon[5] = 18'd161815;
	   moon[6] = 18'd165015;
		star[0] = 18'd224411;
		star[1] = 18'd224717;
		star[2] = 18'd225059;
	end
	
	int moon_locX1 = 10;
	int moon_locX2 = 40;
	int moon_locY = 10;
	int star_locX1 = 100;
	int star_locY1 = 20;
	int star_locX2 = 200;
	int star_locY2 = 60;
	
	logic [17:0] start, offset;
	int DistX, DistY, SizeX, SizeY;
	int moon_X = 40;
	int moon_full_X = 80;
	int moon_Y = 80;
	int star_X = 18;
	int star1_Y = 17;
	int star2_Y = 19;
	int star3_Y = 18;
	int moon_SizeX, moon_SizeY, moon_locX;
	int star_SizeX, star_SizeY;
	
	int frame_count;
	logic [1:0] draw_which_star;
	logic [2:0] draw_which_moon;
	
	always_comb
	begin
		case (moon_on_wr)
			2'b01:
				begin
					SizeX = moon_SizeX;
					SizeY = moon_SizeY;
					DistX = WriteX - moon_locX;
					DistY = WriteY - moon_locY;
				end
			2'b10:
				begin
					SizeX = star_SizeX;
					SizeY = star_SizeY;
					DistX = WriteX - star_locX1;
					DistY = WriteY - star_locY1;
				end
			2'b11:
				begin
					SizeX = star_SizeX;
					SizeY = star_SizeY;
					DistX = WriteX - star_locX2;
					DistY = WriteY - star_locY2;
				end	
			default:
				begin
					SizeX = 0;
					SizeY = 0;
					DistX = 0;;
					DistY = 0;
				end
		endcase
	end
	
	always_ff @ (posedge frame_Clk or posedge Reset)
	begin
		if (Reset)
		begin
			frame_count <= 1;
			draw_which_star <= 2'b00;
		end
		else
		begin
			if (frame_count == 1)
			begin
				draw_which_star <= 2'b00;
				frame_count <= frame_count + 1;
			end
			else if (frame_count == 10)
			begin
				draw_which_star <= 2'b01;
				frame_count <= frame_count + 1;
			end
			else if (frame_count == 20)
			begin
				draw_which_star <= 2'b10;
				frame_count <= frame_count + 1;
			end
			else if (frame_count == 30)
			begin
				draw_which_star <= 2'b00;
				frame_count <= 1;
			end
			else
				frame_count <= frame_count + 1;
		end
	end
	
	always_comb
	begin
		case (moon_on_wr)
			2'b01: start = moon[draw_which_moon];
			2'b10: start = star[draw_which_star];
			2'b11: start = star[draw_which_star];
			default: start = 0;
		endcase
		offset = DistY*SizeX + DistX;
	end
	assign address = start + offset;
	
	always_comb
	begin
		case (draw_which_star)
			2'b00:
			begin
				star_SizeX = star_X;
				star_SizeY = star1_Y;
			end
			2'b01:
			begin
				star_SizeX = star_X;
				star_SizeY = star2_Y;
			end
			2'b10:
			begin
				star_SizeX = star_X;
				star_SizeY = star3_Y;
			end
			default:
			begin
				star_SizeX = star_X;
				star_SizeY = star1_Y;
			end
		endcase
	end
	
	enum logic [2:0] {Moon_Full, Moon_Left1, Moon_Left2, Moon_Left3, Moon_Right1, Moon_Right2, Moon_Right3} moon_type, Next_moon_type;
	always_ff @ (posedge isnight or posedge Reset)
	begin
		if (Reset)
			moon_type <= Moon_Full;
		else 
			moon_type <= Next_moon_type;
	end
	
	always_comb
	begin
	unique case (moon_type)
			Moon_Full: 
				begin
					draw_which_moon = 3'b000;
					moon_SizeX = moon_full_X;
					moon_SizeY = moon_Y;
					moon_locX = moon_locX1;
				end
			Moon_Left1: 
				begin
					draw_which_moon = 3'b001;
					moon_SizeX = moon_X;
					moon_SizeY = moon_Y;
					moon_locX = moon_locX1;
				end
			Moon_Left2: 
				begin
					draw_which_moon = 3'b010;
					moon_SizeX = moon_X;
					moon_SizeY = moon_Y;
					moon_locX = moon_locX1;
				end
			Moon_Left3: 
				begin
					draw_which_moon = 3'b011;
					moon_SizeX = moon_X;
					moon_SizeY = moon_Y;
					moon_locX = moon_locX1;
				end
			Moon_Right1: 
				begin
					draw_which_moon = 3'b100;
					moon_SizeX = moon_X;
					moon_SizeY = moon_Y;
					moon_locX = moon_locX2;
				end
			Moon_Right2: 
				begin
					draw_which_moon = 3'b101;
					moon_SizeX = moon_X;
					moon_SizeY = moon_Y;
					moon_locX = moon_locX2;
				end
			Moon_Right3: 
				begin
					draw_which_moon = 3'b110;
					moon_SizeX = moon_X;
					moon_SizeY = moon_Y;
					moon_locX = moon_locX2;
				end
		endcase
	end
	
	logic Load_Seed, Done;
	logic [5:0] Seed;
	logic [5:0] rand_num;
	int pulse_counter;
	assign Seed = 6'b010101;
	
	initial
	begin
		Load_Seed = 1;
		pulse_counter = 0;
	end
	always_ff @ (posedge frame_Clk)
	begin
		if (pulse_counter >= 2)
		begin
			Load_Seed <= 0;
			pulse_counter <= 2;
		end
		else
			pulse_counter <= pulse_counter + 1;
	end
	LFSR #(6) gen_rand (.*, .Clk(~frame_Clk), .Enable(1'b1), .Out(rand_num));
	
	always_comb
	begin:Choose_moon_type
		Next_moon_type = moon_type;
			if (rand_num >= 6'd0 && rand_num < 6'd16)			//Possibility = 1/4
				Next_moon_type = Moon_Full;
			else if (rand_num >= 6'd16 && rand_num < 6'd24) //Possibility = 1/8
				Next_moon_type = Moon_Left1;
			else if (rand_num >= 6'd24 && rand_num < 6'd32)	//Possibility = 1/8
				Next_moon_type = Moon_Left2;
			else if (rand_num >= 6'd32 && rand_num < 6'd40) //Possibility = 1/8
				Next_moon_type = Moon_Left3;
			else if (rand_num >= 6'd40 && rand_num < 6'd48) //Possibility = 1/8
				Next_moon_type = Moon_Right1;
			else if (rand_num >= 6'd48 && rand_num < 6'd56) //Possibility = 1/8
				Next_moon_type = Moon_Right2;
			else 															//Possibility = 1/8
				Next_moon_type = Moon_Right3;
	end
	 
	always_comb
   begin:Moon_on_wr_proc
		if (isnight)
		begin
			if ((WriteX >= moon_locX) && (WriteX < moon_locX + moon_SizeX) && (WriteY >= moon_locY) && (WriteY < moon_locY + moon_SizeY))
				moon_on_wr = 2'b01;
			else if ((WriteX >= star_locX1) && (WriteX < star_locX1 + star_SizeX) && (WriteY >= star_locY1) && (WriteY < star_locY1 + star_SizeY))
				moon_on_wr = 2'b10;
			else if ((WriteX >= star_locX2) && (WriteX < star_locX2 + star_SizeX) && (WriteY >= star_locY2) && (WriteY < star_locY2 + star_SizeY))
				moon_on_wr = 2'b11;
			else
				moon_on_wr = 2'b00;
		end
		else
			moon_on_wr = 2'b00;
   end 

endmodule
