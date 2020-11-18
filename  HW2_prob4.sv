/*
	Anna Stephan
	wisc: amstephan
	
	///// HW 2 Question 4 Answers /////
	
	a. 	This code is correct only if this D latch is supposed to be
		enabled by clk. When enable is active (clk = 1) the output
		becomes the input.
*/

// 	b.	D-FF with active high synchronous reset
module dff_high_sync(d,rst,clk,q);
	input d, rst, clk;
	output logic q;
	
	always @ (posedge clk or posedge rst)
		if(rst)
			q <= 0;
		else
			q <= d;
endmodule

// 	c.	D-FF with asynchronous active low reset and an active high enable
module dff_high_sync(d,rstn_n,en,q);
	input d, rst_n, en;
	output logic q;
	
	always @ (posedge en or negedge rst_n)
		if(!rst_n)
			q <= 0;
		else
			q <= d;
endmodule

//	d.	SR FF with active low asynch reset
module SR_FF(clk,S,R,rst_n,q);
	input clk,S,R,rst_n;
	output q;
	
	always @ (posedge clk or negedge rst_n)
		if(!rst_n)
			q <= 0;
		else if(S)
			q <= 1;
		else if(R)
			q <= 0;
endmodule

/*
	e.	The use of the always_ff construct does not ensure that the
		logic will infer a flop because it doesn't specify the
		sensitivities required for the specific flop.
*/