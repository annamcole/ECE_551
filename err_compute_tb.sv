module err_compute_tb();
  
  /////// Declare stiumulus of type reg ///////
  reg clk,rst_n;
  reg [11:0] IR_R0,IR_R1,IR_R2,IR_R3;
  reg [11:0] IR_L0,IR_L1,IR_L2,IR_L3;
  reg [15:0] answer;
  
  //// Declare stimulus signals
  reg IR_vld;
  reg [2:0] sel;
  reg sub;
  reg clr_accum,en_accum;
  reg err_vld;
  
  //// Declare output to monitor of type wire /////
  wire [15:0] error;
  
  integer indx;
  //////////////////////////
  //// Instantiate DUT ////
  ////////////////////////
  err_compute iDUT(.clk(clk),.rst_n(rst_n),.IR_vld(IR_vld),.IR_R0(IR_R0),.IR_R1(IR_R1),.IR_R2(IR_R2),.IR_R3(IR_R3),
                    .IR_L0(IR_L0),.IR_L1(IR_L1),.IR_L2(IR_L2),.IR_L3(IR_L3),
					.err_vld(err_vld),.error(error));

	logic oops = 0;
  initial begin
	clk = 0;
	
	for (indx = 0; indx<8'h66; indx++) begin
		oops = 0;
		
		IR_L3 = $random%12'hFFF;
		IR_L2 = $random%12'hFFF;
		IR_L1 = $random%12'hFFF;
		IR_L0 = $random%12'hFFF;
		IR_R3 = $random%12'hFFF;
		IR_R2 = $random%12'hFFF;
		IR_R1 = $random%12'hFFF;
		IR_R0 = $random%12'hFFF;
		rst_n = 0;
		@(posedge clk);
		@(negedge clk);
		rst_n = 1;
		
		IR_vld = 1;
		@(posedge clk);
		@(negedge clk);
		IR_vld = 0;
		repeat (9)@(posedge clk);
		oops = 1;
		
        if (err_vld) begin
			answer = {4'h0,IR_R0} - {4'h0,IR_L0} + {3'h0,IR_R1,1'b0} - {3'h0,IR_L1,1'b0} + 
	             {2'b00,IR_R2,2'b00} - {2'b00,IR_L2,2'b00} + {1'b0,IR_R3,3'h0} - {1'b0,IR_L3,3'h0};
			if (error!==answer) begin
		
				$display("ERR: expected %h but received %h at test %d",answer,error,indx);
				$display("   IR_L3: %h",IR_L3);
				$display("   IR_L2: %h",IR_L2);
				$display("   IR_L1: %h",IR_L1);
				$display("   IR_L0: %h",IR_L0);
				$display("   IR_R3: %h",IR_R3);
				$display("   IR_R2: %h",IR_R2);
				$display("   IR_R1: %h",IR_R1);
				$display("   IR_R0: %h",IR_R0);
				$stop();
			end else
				$display("GOOD: Test %d passed",indx);
		end
	  @(negedge clk);
	end
	$display("YAHOO! all tests passed!");
	$stop();
  end
 
  always
    #5 clk = ~clk;  
				
endmodule
					