module P_term(error, P_term);

	localparam signed P_COEFF = 4'h6;
	
	input signed [15:0] error;
	output logic signed [14:0] P_term;
	
	logic signed [10:0] err_sat;
	

	// 11-bit saturation

	assign err_sat = 	( !error[15] && |error[14:10] ) ? 11'h3ff :
						(  error[15] && !(&error[14:10]) ) ? 11'h400 : error[10:0];
														
	// signed multiply
	assign P_term[14:0] = err_sat * P_COEFF;
	
endmodule