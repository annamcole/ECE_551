module A2D_intf_tb();

	logic clk, rst_n;
	logic strt_cnv;
	logic cnv_cmplt;
	logic [2:0] chnnl;
	logic [11:0]res;
	logic SS_n;
	logic SCLK;
	logic MOSI;
	logic MISO;
	
	logic [11:0] expected;

	///////////////////////////
	// Instantiate A2D_intf //
	/////////////////////////
	A2D_intf iINTF(.clk(clk),.rst_n(rst_n),.strt_cnv(strt_cnv),
			.cnv_cmplt(cnv_cmplt),.chnnl(chnnl),.res(res),
			.SS_n(SS_n),.SCLK(SCLK),.MOSI(MOSI),.MISO(MISO));
			
	//////////////////////////
	// Instantiate ADC128S //
	////////////////////////
	ADC128S iADC128S(.clk(clk),.rst_n(rst_n),.SS_n(SS_n),
			.SCLK(SCLK),.MISO(MISO),.MOSI(MOSI));
			
	initial begin
		clk = 0;
		rst_n = 0;
		
		@(posedge clk);
		@(negedge clk);
		rst_n = 1;
		
		chnnl = 3'b000;
		for(int i = 0; i < 100; i = i + 1) begin
			
			strt_cnv = 1;
			@(posedge clk);
			strt_cnv = 0;
			@(posedge clk);
					
			fork
				begin : timeout1
					repeat(3000) @(posedge clk);
					$display("ERR: timed out waiting for converstion 1 to compelete");
				    $stop;
				end
				begin
					@(posedge cnv_cmplt);
					disable timeout1;
				end
			join
			
			expected = ~(12'hC00 - (i*8'h10));
			if(res != expected) begin
				$display("ERR: test %d, expected: 0x%h  res: 0x%h",i,expected,res);
				$stop;
			end		
			
			//chnnl = chnnl + 1;
		end
		
		$display("YAHOO! All Tests Passed.");
		$stop;
	end	
	
	always
		#5 clk = ~clk;

endmodule