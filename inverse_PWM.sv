module inverse_PWM(clk,rst_n,PWM_sig,duty);
/*
	INPUTS
	clk = clock
	rst_n = asynch active low reset
	PWM_sig = PWM signal in
	
	OUTPUT
	duty[10:0] = specifies duty cycle (unsigned 11-bit)
*/

	input clk, rst_n, PWM_sig;
	output reg [10:0] duty;
	
	localparam PERIOD = 2048;
	
	logic [10:0] clk_cnt;
	
	// clock and duty counter
	always_ff @ (posedge clk,negedge rst_n) begin
		if(!rst_n)
		begin
			clk_cnt <= 0;
			duty <= 0;
		end else if(clk_cnt == PERIOD-1) 
		begin
			clk_cnt <= 0;
			duty <= 0;
		end
		else
			clk_cnt <= clk_cnt +1;
		
		if(PWM_sig)
		begin
			duty <= duty + 1;
		end
	end

endmodule
