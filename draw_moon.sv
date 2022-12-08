module draw_moon(input Clk50, pixel_Clk, frame_Clk, Reset,
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
	
	int moon_locX1 = 0;
	int moon_locX2 = 40;
	int moon_locY = 80;
	int star_locX1 = 100;
	int star_locY1 = 20;
	int star_locX2 = 200;
	int star_locY2 = 60;`
	
	logic [17:0] start, offset;
	int DistX, DistY, SizeX, SizeY;
	logic [17:0] moon_addr, star_addr;
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
					SizeX = star_X;
					SizeY = star_Y;
					DistX = WriteX - star_locX1;
					DistY = WriteY - star_locY1;
				end
			2'b11:
				begin
					SizeX = star_X;
					SizeY = star_Y;
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
				draw_which_star <= 3'b11;
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
	
	enum logic [2:0] {}

endmodule
