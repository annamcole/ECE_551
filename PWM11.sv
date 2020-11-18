module PWM11(clk, rst_n, duty, PWM_sig);
/*
	INPUTS
	clk = clock
	rst_n = asynch active low reset
	duty[10:0] = specifies duty cycle (unsigned 11-bit)
	
	OUTPUT
	PWM_sig = PWM signal out (glitch free)

*/
	input clk, rst_n;
	input [10:0] duty;
	output logic PWM_sig;
	
	logic cnt_lt_duty;
	logic [10:0] cnt;
	
	// compare values
	always_comb
		cnt_lt_duty = cnt < duty;
	
	// counter & output PWM_sig
	always_ff @ (posedge clk,negedge rst_n) 
	begin
		if(!rst_n) begin
			cnt <= 0;
			PWM_sig <= 0;
		end else begin
			cnt <= cnt + 1;
			PWM_sig <= cnt_lt_duty;
		end
	end

endmodule
