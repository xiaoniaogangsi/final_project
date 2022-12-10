module frame_buffer (input Clk50, Reset, write_en,
							input [3:0] write_data,
							input [9:0] write_X, read_X,
							input [9:0] write_Y, read_Y,
							input select,
							output logic [3:0] read_data);

	logic we1, we2;
	logic [9:0] address1, address2;
	logic [3:0] out1, out2;
	//Each line buffer has 2^10 = 1024 addresses, enough to hold one row (640 pixels).
	
	buffer row_buffer1(.aclr(Reset),
							.address(address1),
							.clock(Clk50),
							.data(write_data),
							.wren(we1),
							.q(out1));
	buffer row_buffer2(.aclr(Reset),
							.address(address2),
							.clock(Clk50),
							.data(write_data),
							.wren(we2),
							.q(out2));
	
	always_comb
	begin
		if (select)		//If select=1, write to row_buffer1, and read from row_buffer2.
		begin
			address2 = read_X;
			we2 = 1'b0;
			read_data = out2;
			
			address1 = write_X;
			we1 = write_en;
		end
		else				//If select=1, read from row_buffer1, and write to row_buffer2.
		begin
			address1 = read_X;
			we1 = 1'b0;
			read_data = out1;
			
			address2 = write_X;
			we2 = write_en;
		end
	end

endmodule
