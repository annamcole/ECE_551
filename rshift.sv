module shifter(src, ars, amt, res);
	
	input [15:0] src;
	input ars;
	input [3:0] amt;
	output logic [15:0] res;
	
	logic [15:0] shft_stg1, shft_stg2, shft_stg3;
	
	always @(*) begin
	
		if (ars) begin
			 
			assign shft_stg1 = (amt[0]) ? {src[15],src[15:1]} : src[15:0];
			assign shft_stg2 = (amt[1]) ? {{2{shft_stg1[15]}},shft_stg1[15:2]} : shft_stg1[15:0];
			assign shft_stg3 = (amt[2]) ? {{4{shft_stg2[15]}},shft_stg2[15:4]} : shft_stg2[15:0];
			assign res = (amt[3]) ? {{8{shft_stg3[15]}},shft_stg3[15:8]} : shft_stg3[15:0];
	
		end 
		else begin
		
			assign shft_stg1 = (amt[0]) ? {1'b0,src[15:1]} : src[15:0];
			assign shft_stg2 = (amt[1]) ? {{2{1'b0}},shft_stg1[15:2]} : shft_stg1[15:0];
			assign shft_stg3 = (amt[2]) ? {{4{1'b0}},shft_stg2[15:4]} : shft_stg2[15:0];
			assign res = (amt[3]) ? {{8{1'b0}},shft_stg3[15:8]} : shft_stg3[15:0];
		
		end
	
	end
	
	
	endmodule
	
	
	