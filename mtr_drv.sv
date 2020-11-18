module mtr_drv(clk,rst_n,lft_duty,rght_duty,DIRL,DIRR,PWML,PWMR);

	input signed [11:0] lft_duty, rght_duty;
	input clk, rst_n;			// clk is clock, rst_n is a-synch active low reset
	output logic PWML,PWMR;		// 11-bit PWM signals
	output logic DIRL,DIRR;		// High if speed is negative

	logic [10:0] absL,absR;		// magnitude of motor speeds

	// assign direction
	assign DIRL = lft_duty[11];
	assign DIRR = rght_duty[11];

	// calculate abs value
	assign absL = (DIRL) ? ~lft_duty[10:0] : lft_duty[10:0];
	assign absR = (DIRR) ? ~rght_duty[10:0] : rght_duty[10:0];

	// PWM11
	PWM11 iPWM_L(.clk(clk),.rst_n(rst_n),.duty(absL),.PWM_sig(PWML));
	PWM11 iPWM_R(.clk(clk),.rst_n(rst_n),.duty(absR),.PWM_sig(PWMR));

endmodule