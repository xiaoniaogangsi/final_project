/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */
//This module is no longer included in the project,
//just put here as a reference of the pixel address.
module  spriteROM
(
		input [17:0] read_address,
		
		input Clk,

		output logic [3:0] data_Out
		
);

// mem has width of 4 bits and a total of 233303 addresses
//2^18=262144, so we need 18 bits for address
logic [3:0] mem [0:258118];

//Sprite location info: 

initial
begin
	//Cactus: Need 11105 16bit-addresses, 2^14=16384
	 $readmemh("sprite/cactus_large1_50x100.txt", mem, 0, 4999);
	 $readmemh("sprite/cactus_large2_100x100.txt", mem, 5000, 14999);
	 $readmemh("sprite/cactus_large3_150x100.txt", mem, 15000, 29999);
	 $readmemh("sprite/cactus_small1_36x70.txt", mem, 30000, 32519);
	 $readmemh("sprite/cactus_small2_68x70.txt", mem, 32520, 37279);
	 $readmemh("sprite/cactus_small3_102x70.txt", mem, 37280, 44419);
	//Cloud: Need 621 16bit-address, 2^10=1024
	 $readmemh("sprite/cloud_92x27.txt", mem, 44420, 46903);
	//Die: Need 2788 16bit-address, 2^11=2048
	 $readmemh("sprite/die1_88x94.txt", mem, 46904, 55175);
	 $readmemh("sprite/die2_80x86.txt", mem, 55176, 62055);
	//Duck: Need 3540 16-bit address, 2^12=4096
	 $readmemh("sprite/duck1_118x60.txt", mem, 62056, 69135);
	 $readmemh("sprite/duck2_118x60.txt", mem, 69136, 76215);
	 
	 $readmemh("sprite/gameover_381x21.txt", mem, 76216, 84216);
	 
	 $readmemh("sprite/HI_38x21.txt", mem, 84217, 85014);
	 
	 $readmemh("sprite/horizon_2400x24.txt", mem, 85015, 142614);
	 
	 $readmemh("sprite/moon_full_80x80.txt", mem, 142615, 149014);
	 $readmemh("sprite/moon_left1_40x80.txt", mem, 149015, 152214);
	 $readmemh("sprite/moon_left2_40x80.txt", mem, 152215, 155414);
	 $readmemh("sprite/moon_left3_40x80.txt", mem, 155415, 158614);
	 $readmemh("sprite/moon_right1_40x80.txt", mem, 158615, 161814);
	 $readmemh("sprite/moon_right2_40x80.txt", mem, 161815, 165014);
	 $readmemh("sprite/moon_right3_40x80.txt", mem, 165015, 168214);
	 
	 $readmemh("sprite/num_0_18x21.txt", mem, 168215, 168592);
	 $readmemh("sprite/num_1_18x21.txt", mem, 168593, 168970);
	 $readmemh("sprite/num_2_18x21.txt", mem, 168971, 169348);
	 $readmemh("sprite/num_3_18x21.txt", mem, 169349, 169726);
	 $readmemh("sprite/num_4_18x21.txt", mem, 169727, 170104);
	 $readmemh("sprite/num_5_18x21.txt", mem, 170105, 170482);
	 $readmemh("sprite/num_6_18x21.txt", mem, 170483, 170860);
	 $readmemh("sprite/num_7_18x21.txt", mem, 170861, 171238);
	 $readmemh("sprite/num_8_18x21.txt", mem, 171239, 171616);
	 $readmemh("sprite/num_9_18x21.txt", mem, 171617, 171994);
	 
	 $readmemh("sprite/pterosaur_wingdown_92x80.txt", mem, 171995, 179354);
	 $readmemh("sprite/pterosaur_wingup_92x80.txt", mem, 179355, 186714);
	 
	 $readmemh("sprite/restart_72x64.txt", mem, 186715, 191322);
	 
	 $readmemh("sprite/run1_88x94.txt", mem, 191323, 199594);
	 $readmemh("sprite/run2_88x94.txt", mem, 199595, 207866);
	 $readmemh("sprite/run3_88x94.txt", mem, 207867, 216138);
	 $readmemh("sprite/run4_88x94.txt", mem, 216139, 224410);
	 
	 $readmemh("sprite/star1_18x17.txt", mem, 224411, 224716);
	 $readmemh("sprite/star2_18x19.txt", mem, 224717, 225058);
	 $readmemh("sprite/star3_18x18.txt", mem, 225059, 225382);
	 
	 $readmemh("sprite/Trex_88x90.txt", mem, 225383, 233302);
	 
	 $readmemh("sprite/XK3_88x94.txt", mem, 233303, 241574);
	 $readmemh("sprite/XK4_88x94.txt", mem, 241575, 249846);
	 $readmemh("sprite/XKdie_88x94.txt", mem, 249847, 258118);
end

always_ff @ (posedge Clk) begin
	data_Out<= mem[read_address];
end

endmodule
