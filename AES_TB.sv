module aes_modified_tb();
	reg clk, rst;
	reg start;
	reg [127:0] in, encrypkey;
	reg [127:0] out;
	aes_modified dut (clk, rst, start, in, encrypkey, out);
	
	initial begin
		clk=0;
		forever 
			#10 clk=~clk;	
	end

	initial begin
		rst=1;
				// For 'n', values are arranged by rows
		in = {8'h32, 8'h88, 8'h31, 8'he0,  // Row 0
		     8'h43, 8'h5a, 8'h31, 8'h37,  // Row 1
		     8'hf6, 8'h30, 8'h98, 8'h07,  // Row 2
		     8'ha8, 8'h8d, 8'ha2, 8'h34}; // Row 3

		// For 'encrypkey', values are arranged by rows
		encrypkey = {8'h2b, 8'h28, 8'hab, 8'h09,  // Row 0
		             8'h7e, 8'hae, 8'hf7, 8'hcf,  // Row 1
		             8'h15, 8'hd2, 8'h15, 8'h4f,  // Row 2
		             8'h16, 8'ha6, 8'h88, 8'h3c}; // Row 3

		@(negedge clk);
		rst=0;
		start=1;

        @(negedge clk);
        start=0;
		repeat(55) @(negedge clk);
		$stop;
	end
endmodule	

