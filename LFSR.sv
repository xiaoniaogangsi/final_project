//From https://blog.csdn.net/hengzo/article/details/49689725, with some modification.
module LFSR #(parameter length = 24)
				(input Clk, Enable,
				 input Load_Seed,
				 input [length-1:0] Seed,
				 output logic [length-1:0] Out,
				 output logic Done);
//The Linear Feedback Shift Register, used to generate a random number.
//The parameter "length" should be 2~24.
logic [length-1:0] LFSR_regs = 0;
logic Shift_in;

always_ff @ (posedge Clk)
begin
	if (Enable)
	begin
		if (Load_Seed)
			LFSR_regs <= Seed;
		else	//Do the shift.
			LFSR_regs <= {LFSR_regs[length-2:0], Shift_in};
	end
end

always_comb
begin
	//The Table is from Wikipedia, 
	//https://en.wikipedia.org/wiki/Linear-feedback_shift_register
	unique case (length)
	2: Shift_in = LFSR_regs[2-1] ^ LFSR_regs[1-1];
	3: Shift_in = LFSR_regs[3-1] ^ LFSR_regs[2-1];
	4: Shift_in = LFSR_regs[4-1] ^ LFSR_regs[3-1];
	5: Shift_in = LFSR_regs[5-1] ^ LFSR_regs[3-1];
	6: Shift_in = LFSR_regs[6-1] ^ LFSR_regs[5-1];
	7: Shift_in = LFSR_regs[7-1] ^ LFSR_regs[6-1];
	8: Shift_in = LFSR_regs[8-1] ^ LFSR_regs[6-1] ^ LFSR_regs[5-1] ^ LFSR_regs[3-1];
	9: Shift_in = LFSR_regs[9-1] ^ LFSR_regs[5-1];
	10: Shift_in = LFSR_regs[10-1] ^ LFSR_regs[7-1];
	11: Shift_in = LFSR_regs[11-1] ^ LFSR_regs[9-1];
	12: Shift_in = LFSR_regs[12-1] ^ LFSR_regs[11-1] ^ LFSR_regs[10-1] ^ LFSR_regs[4-1];
	13: Shift_in = LFSR_regs[13-1] ^ LFSR_regs[12-1] ^ LFSR_regs[11-1] ^ LFSR_regs[8-1];
	14: Shift_in = LFSR_regs[14-1] ^ LFSR_regs[13-1] ^ LFSR_regs[12-1] ^ LFSR_regs[2-1];
	15: Shift_in = LFSR_regs[15-1] ^ LFSR_regs[14-1];
	16: Shift_in = LFSR_regs[16-1] ^ LFSR_regs[15-1] ^ LFSR_regs[13-1] ^ LFSR_regs[4-1];
	17: Shift_in = LFSR_regs[17-1] ^ LFSR_regs[14-1];
	18: Shift_in = LFSR_regs[18-1] ^ LFSR_regs[11-1];
	19: Shift_in = LFSR_regs[19-1] ^ LFSR_regs[18-1] ^ LFSR_regs[17-1] ^ LFSR_regs[14-1];
	20: Shift_in = LFSR_regs[20-1] ^ LFSR_regs[17-1];
	21: Shift_in = LFSR_regs[21-1] ^ LFSR_regs[19-1];
	22: Shift_in = LFSR_regs[22-1] ^ LFSR_regs[21-1];
	23: Shift_in = LFSR_regs[23-1] ^ LFSR_regs[18-1];
	24: Shift_in = LFSR_regs[24-1] ^ LFSR_regs[23-1] ^ LFSR_regs[22-1] ^ LFSR_regs[17-1];
	endcase
end

always_comb
begin
	Out = LFSR_regs[length-1:0];
	if (LFSR_regs[length-1:0] == Seed)	//The loop is finished
		Done = 1'b1;
	else
		Done = 1'b0;
end

endmodule
