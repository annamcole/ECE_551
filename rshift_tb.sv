module shifter_tb();

	logic [15:0] src, res;
	logic [3:0] amt;
	logic ars, clk;
	
	shifter iDUT(.src(src), .ars(ars), .amt(amt), .res(res));

	initial begin
		clk = 0;
		
		// test1: logical shift right by 1
		src = 16'h8000;
		ars = 1'b0;
		amt = 4'h1;
		@(posedge clk)
		if (res != 16'h4000) begin
			$display("ERR at %t: test1 result should be 0x400",$time);
			$stop;
		end
			
		// test2: logical shift right by 15
		src = 16'hFFFF;
		ars = 1'b0;
		amt = 4'hF;
		@(posedge clk)
		if (res != 16'h0001) begin
			$display("ERR at %t: test2 result should be 0x001",$time);
			$stop;
		end
		
		// test3a: arithmetic shift right by 1 (positive)
		src = 16'h0002;
		ars = 1'b1;
		amt = 4'h1;
		@(posedge clk)
		if (res != 16'h0001) begin
			$display("ERR at %t: test3a result should be 0x001",$time);
			$stop;
		end
			
		// test3b: arithemtic shift right by 1 (negative)
		src = 16'h8000;
		ars = 1'b1;
		amt = 4'h1;
		@(posedge clk)
		if (res != 16'hC000) begin
			$display("ERR at %t: testb result should be 0xC00",$time);
			$stop;
		end
			
		// test4a: arithmetic shift right by 15 (positive)
		src = 16'h7FFF;
		ars = 1'b1;
		amt = 4'hF;
		@(posedge clk)
		if (res != 16'h0000) begin
			$display("ERR at %t: test4a result should be 0x000",$time);
			$stop;
		end
			
		// test 4b: arithmetic shift right by 15 (negative)
		src = 16'h8000;
		ars = 1'b1;
		amt = 4'hF;
		@(posedge clk)
		if (res != 16'hFFFF) begin
			$display("ERR at %t: test4b result should be 0xFFF",$time);
			$stop;
		end
		
		$display("YAHOO! Tests passed");
		$stop;
		
	end
	
	always 
		#5 clk = ~clk;

endmodule