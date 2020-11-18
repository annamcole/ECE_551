module err_compute_DP_tb();
  
  /////// Declare stiumulus of type reg ///////
  reg clk,rst_n;
  reg [11:0] IR_R0,IR_R1,IR_R2,IR_R3;
  reg [11:0] IR_L0,IR_L1,IR_L2,IR_L3;
  reg [15:0] answer;
  reg [0:255]vectors[103:0];
  reg [103:0] stim_vec;
  
  //// Declare stimulus signals
  reg [2:0] sel;
  reg sub;
  reg clr_accum,en_accum;
  reg err_vld;
  
  //// Declare output to monitor of type wire /////
  wire [15:0] error;
  
  integer indx;
  
  //// Instantiate DUT ////
  err_compute_DP iDP(.clk(clk),.en_accum(en_accum),.clr_accum(clr_accum),.sub(sel[0]),
                     .sel(sel),.IR_R0(IR_R0),.IR_R1(IR_R1),.IR_R2(IR_R2),.IR_R3(IR_R3),
                     .IR_L0(IR_L0),.IR_L1(IR_L1),.IR_L2(IR_L2),.IR_L3(IR_L3),.error(error));


  initial begin
    $readmemh("err_compute_stim.hex",vectors);	// read test vectors from memory
	clk = 0;
	for (indx = 0; indx<8'h66; indx++) begin
	  stim_vec = vectors[indx];
	  IR_L3 = stim_vec[11:0];
	  IR_L2 = stim_vec[23:12];
	  IR_L1 = stim_vec[35:24];
	  IR_L0 = stim_vec[47:36];
	  IR_R3 = stim_vec[59:48];
	  IR_R2 = stim_vec[71:60];
	  IR_R1 = stim_vec[83:72];
	  IR_R0 = stim_vec[95:84];
	  sel = stim_vec[98:96];
	  sub = stim_vec[99];
	  clr_accum = stim_vec[100];
	  en_accum = stim_vec[101];
	  err_vld = stim_vec[102];
	  rst_n = stim_vec[103];
      if (err_vld) begin
	  	answer = {4'h0,IR_R0} - {4'h0,IR_L0} + {3'h0,IR_R1,1'b0} - {3'h0,IR_L1,1'b0} + 
	             {2'b00,IR_R2,2'b00} - {2'b00,IR_L2,2'b00} + {1'b0,IR_R3,3'h0} - {1'b0,IR_L3,3'h0};
		if (error!==answer) begin
	      $display("ERR: expected %h but received %h at vector %d",answer,error,indx);
		  $stop();
        end else
	      $display("GOOD: Test vector %d passed",indx);
      end
	  @(negedge clk);
	end
	$display("YAHOO!  all vectors passed!");
	$stop();
  end
 
  always
    #5 clk = ~clk;  
				
endmodule
					