module IR_intf_tb();

	localparam LINE_THRES = 12'h040;
	
	logic clk, rst_n;
	logic strt_cnv;
	logic cnv_cmplt;
	logic [2:0] chnnl;
	logic [11:0]res;
	logic SS_n;
	logic SCLK;
	logic MOSI;
	logic MISO;
	
	logic [11:0] IR_R0,IR_R1,IR_R2,IR_R3;
	logic [11:0] IR_L0,IR_L1,IR_L2,IR_L3;
	logic IR_en;
	logic IR_vld;
	logic line_present;
	
	logic [11:0] exp_res;
	logic expected_line;

	///////////////////////////
	// Instantiate IR_intf //
	/////////////////////////
	IR_intf #(.FAST_SIM (1)) iINTF(.clk(clk),.rst_n(rst_n),.SS_n(SS_n),.SCLK(SCLK),
			.MOSI(MOSI),.MISO(MISO),.IR_L0(IR_L0),.IR_L1(IR_L1),
			.IR_L2(IR_L2),.IR_L3(IR_L3),.IR_R0(IR_R0),.IR_R1(IR_R1),
			.IR_R2(IR_R2),.IR_R3(IR_R3),.IR_en(IR_en),.IR_vld(IR_vld),
			.line_present(line_present));
			
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
		
		for(int i = 0; i < 50; i = i + 1) begin
					
			fork
				begin : timeout1
					repeat(18'h3ffff) @(posedge clk);
					$display("ERR: test %d, timed out waiting for conversions",i);
					$stop;
				end
				begin
					@(posedge IR_vld);
					disable timeout1;
				end
			join
			
			exp_res = ~(12'hC00 - (i*8'h10));
			expected_line = exp_res > LINE_THRES;
			if(res != expected_line) begin
				$display("ERR: test %d, line expected but not detected",i,expected_line);
				$stop;
			end		
			
		end
		
		$display("YAHOO! All Tests Passed.");
		$stop;
	end	
	
	always
		#5 clk = ~clk;

endmodule