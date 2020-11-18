module err_compute_DP(clk,en_accum,clr_accum,sub,sel,IR_R0,IR_R1,IR_R2,IR_R3,
                    IR_L0,IR_L1,IR_L2,IR_L3,error);
					
  input clk;							// 50MHz clock
  input en_accum,clr_accum;				// accumulator control signals
  input sub;							// If asserted we subtract IR reading
  input [2:0] sel;						// mux select for operand
  input [11:0] IR_R0,IR_R1,IR_R2,IR_R3; // Right IR readings from inside out
  input [11:0] IR_L0,IR_L1,IR_L2,IR_L3; // Left IR reading from inside out
  
  
  output reg signed [15:0] error;	// Error in line following, goes to PID
  
	logic [15:0] next_error;	// error to input into flop
	logic [15:0] mux_out;		// output from mux
	logic [15:0] negation;		// negate mux selection
	
  //////////////////////////////
  // Implement mux selection //
  ////////////////////////////
	assign mux_out =	(sel == 3'h0) ? {4'h0,IR_R0} :
						(sel == 3'h1) ? {4'h0,IR_L0} :
						(sel == 3'h2) ? {3'h0,IR_R1,1'b0} :
						(sel == 3'h3) ? {3'h0,IR_L1,1'b0} :
						(sel == 3'h4) ? {2'h0,IR_R2,2'h0} :
						(sel == 3'h5) ? {2'h0,IR_L2,2'h0} :
						(sel == 3'h6) ? {1'b0,IR_R3,3'h0} :
						(sel == 3'h7) ? {1'b0,IR_L3,3'h0} : 16'h0000;
						
	assign negation = mux_out[15:0]^{15{sub}};
	
	assign next_error = error + negation + sub;
	
	
  
  //////////////////////////////////
  // Implement error accumulator //
  ////////////////////////////////
  always_ff @(posedge clk)
    if (clr_accum)
	  error <= 16'h0000;
	else if (en_accum)
	  error <= next_error; 

endmodule