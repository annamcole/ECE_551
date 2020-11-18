module mtr_drv_tb();

	logic clk,rst_n;		// cock and asynch active low reset
	logic [11:0] lft_duty,rght_duty;	// left motor speed and right motor speed both in duty form
	logic DIRL,DIRR,PWML,PWMR;	// DIRL and DIRR are high if speed is negative
								// PWML and PWMR are 11-bit PWM signals

	mtr_drv iDUT(.clk(clk),.rst_n(rst_n),.lft_duty(lft_duty),.rght_duty(rght_duty),.DIRL(DIRL),.DIRR(DIRR),.PWML(PWML),.PWMR(PWMR));

	initial begin
	
		clk = 0;
		rst_n = 0;
		
		@(negedge clk) rst_n = 1;

		// test1: both duty = 12'h000
		lft_duty = 12'h000;
		rght_duty = 12'h000;
		repeat (2048) @(posedge clk);
	
		// test2: both duty negative saturation
		lft_duty = 12'h7FF;
		rght_duty = 12'h7FF;
		repeat (2048) @(posedge clk);
		
		// test3: both duty positive saturation
		lft_duty = 12'h0FF;
		rght_duty = 12'h0FF;
		repeat (2048) @(posedge clk);
		
		// test4: both duty positive
		lft_duty = 12'h080;
		rght_duty = 12'h080;
		repeat (2048) @(posedge clk);
		
		// test5: different duty
		lft_duty = 12'hF33;
		rght_duty = 12'h07C;
		repeat (2048) @(posedge clk);
		
		$display("YAHOO! Tests passed");
		$stop;

	end
	
	always
		#5 clk = ~clk;
		
endmodule