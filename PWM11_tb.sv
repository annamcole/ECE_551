module PWM11_tb();

	logic clk,rst_n,PWM_sig; 			// clk is 50MHz system clk, PWM_sig is PWM signal
	logic [10:0] duty_in, duty_out;		// duty_in is 11 bit duty signal that is recreated in 11 bit duty_out
	
	localparam PERIOD = 2048;
	
	PWM11 iDUT1(.clk(clk),.rst_n(rst_n),.duty(duty_in),.PWM_sig(PWM_sig));
	inverse_PWM iDUT2(.clk(clk),.rst_n(rst_n),.PWM_sig(PWM_sig),.duty(duty_out));
	
	initial begin
		clk = 0;
		rst_n = 0;
		
		@(posedge clk);
		@(negedge clk) rst_n = 1;
		duty_in = 11'h3FF;
		
		// test 1a: duty = 11'h3FF
		repeat (PERIOD-1) @(posedge clk);
		if(duty_out !== duty_in) begin
			$display("ERR: test 1a output doesn't match input: (test 1a) input:%h output:%h",duty_out, duty_in);
			$stop;
		end
		@(posedge clk);
		// test 1b: repeat duty?
		// check if duty repeated
		repeat (PERIOD-1) @(posedge clk);
		if(duty_out !== duty_in) begin
			$display("ERR: test 1b output doesn't match input: (test 1b) input:%h output:%h",duty_out, duty_in);
			$stop;
		end
		
		@(posedge clk);
		
		// test 2: 11'h025
		duty_in = 11'h025;
		repeat (PERIOD-1) @(posedge clk);
		if(duty_out !== duty_in) begin
			$display("ERR: test 2 output doesn't match input: (test 2) input:%h output:%h",duty_out, duty_in);
			$stop;
		end
		
		@(posedge clk);
		
		// test 3: 11'h000;
		duty_in = 11'h000;
		repeat (PERIOD-1) @(posedge clk);
		if(duty_out !== duty_in) begin
			$display("ERR: test 3 output doesn't match input: (test 2) input:%h output:%h",duty_out, duty_in);
			$stop;
		end
		
		$display("YAHOO! All tests passed");
		$stop;
		
	end

	always
		#5 clk = ~clk;

endmodule