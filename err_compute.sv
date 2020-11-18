module err_compute(clk,rst_n,IR_vld,IR_R0,IR_R1,IR_R2,IR_R3,
                    IR_L0,IR_L1,IR_L2,IR_L3,err_vld,error);

	input clk;		// 50MHz clk
	input rst_n;		// async active low reset
	input IR_vld;		// asserted when input ready
	input [11:0] IR_R0,IR_R1,IR_R2,IR_R3;	// right sensor readings
	input [11:0] IR_L0,IR_L1,IR_L2,IR_L3;	// left sensor readings
	  
	output logic [15:0] error;	// result of average of 8-samples
	output logic err_vld; 	// asserted when error output ready
	
	logic sub;
	logic [2:0] sel;
	logic en_accum, clr_accum;
	logic [15:0] error_old;
	logic err_vld_old;
	  
	//////////////////////////////////////////
	// Instantiate datapath of err_compute //
	////////////////////////////////////////
	err_compute_DP iDP(.clk(clk),.en_accum(en_accum),.clr_accum(clr_accum),
				.sub(sub),.sel(sel),.IR_R0(IR_R0),.IR_R1(IR_R1),
				.IR_R2(IR_R2),.IR_R3(IR_R3),.IR_L0(IR_L0),.IR_L1(IR_L1),
				.IR_L2(IR_L2),.IR_L3(IR_L3),.error(error_old));

	///////////////////////////////////////////////
	// Instantiate state machine of err_compute //
	/////////////////////////////////////////////
	err_compute_SM iSM(.clk(clk),.rst_n(rst_n),.IR_vld(IR_vld),.en_accum(en_accum),.clr_accum(clr_accum),
				.sub(sub),.sel(sel),.err_vld(err_vld_old));
						
	/////////////////////////
	// Delay error Signal //
	///////////////////////
	always_ff @(posedge clk) begin
		err_vld <= err_vld_old;
	end
	
	///////////////////////////
	// Delay err_vld Signal //
	/////////////////////////
	always_ff @(posedge clk) begin
		if(err_vld_old)
			error <= error_old;
	end
			
endmodule