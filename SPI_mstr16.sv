module SPI_mstr16(clk,rst_n,SS_n,SCLK,MOSI,MISO,wrt,cmd,done,rd_data);

	input clk, rst_n;	// 50MHz system clock and reset
	input MISO;	// Master In Slave Out
	input wrt;	// A high for 1 clock period would initiate a SPI transaction
	input [15:0] cmd;	// Data (command) begin sent to inertial sensor or A2D converter
	output logic SS_n;	// Active low Slave Select
	output logic SCLK;	// Serial Clock
	output logic MOSI;	// Master Out Slave In
	output logic done;	// Asserted when SPI transaction is complete. Should stay asserted until next wrt
	output logic [15:0] rd_data;	// Data from SPI slave

	localparam logic [5:0] cnt_default = 6'b101111;
			
	typedef enum reg[2:0]{IDLE,WAIT,LOAD,SHIFT,DONE} state_t;
	state_t state, nxt_state;
	
	logic MISO_smpl;
	logic [15:0]shft_reg;
	logic [5:0] sclk_div;
	logic [4:0] bit_cnt;

	logic rst_cnt = 0;
	logic smpl;
	logic shft;
	logic clr_done;
	logic set_done;
	
	////////////////////////
	// Set Up Next State //
	//////////////////////
	always_ff @(posedge clk, negedge rst_n)
	begin
		if(!rst_n)
			state <= IDLE;
		else
			state <= nxt_state;
	end

	////////////////////
	// State Machine //
	//////////////////
	always_comb
	begin
		// default SM outputs
		rst_cnt = 0;
		smpl = 0;
		shft = 0;
		nxt_state = state;
		
		case(state)
		
			IDLE:
			begin
				if(wrt)
				begin
					rst_cnt = 1;
					clr_done = 1;
					set_done = 0;
					nxt_state = WAIT;
				end
			end
			
			WAIT:
			begin
				if(sclk_div == 6'b000000)
					nxt_state = LOAD;
			end
			
			LOAD:
			begin
				if(sclk_div == 6'b011111)
					smpl = 1;
				else if(sclk_div == 6'b111111 && bit_cnt == 15)
				begin
					nxt_state = DONE;
				end
				else if(sclk_div == 6'b111111)
				begin
					shft = 1;
				end
			end
			
			DONE:
			begin
				if(set_done == 1)
					nxt_state = IDLE;
				else
				begin
					shft = 1;
					set_done = 1;
					clr_done = 0;
				end
			end
			
		endcase
	end
	
	//////////////////////
	// Initialize SCLK //
	////////////////////
	always_ff @(posedge clk)
	begin
		if(rst_cnt)
			sclk_div <= cnt_default;
		else if(bit_cnt == 15 && sclk_div == 6'b111111)
			sclk_div <= cnt_default;
		else
			sclk_div <= sclk_div + 1;
	end
	
	assign SCLK = (SS_n)? 1 : sclk_div[5];
	
	//////////////////////
	// Initialize MISO //
	////////////////////
	always_ff @(posedge clk)
	begin
		if(smpl)
			MISO_smpl <= MISO;
	end
	
	////////////////////////////////
	// Initialize shift register //
	//////////////////////////////
	always_ff @(posedge clk)
	begin
		if(wrt)
			shft_reg <= cmd[15:0];
		else if(shft)
			shft_reg <= {shft_reg[14:0],MISO_smpl};
	end
	
	//////////////////////
	// Initialize MOSI //
	////////////////////
	assign MOSI = shft_reg[15];
	
	//////////////////
	// Bit Counter //
	////////////////
	always_ff @(posedge clk)
	begin
		if(rst_cnt)
			bit_cnt <= 0;
		else if(shft)
			bit_cnt <= bit_cnt + 1;
	end
	
	////////////////////
	// SS_n register //
	//////////////////
	always_ff @(posedge clk)
	begin
		if(!rst_n)
			SS_n <= 1;
		else if(clr_done)
			SS_n <= 0;
		else if(set_done)
			SS_n <= 1;
	end
	
	////////////////////
	// Done register //
	//////////////////
	always_ff @(posedge clk)
	begin
		if(!rst_n)
			done <= 0;
		else if(clr_done)
			done <= 0;
		else if(set_done)
			done <= 1;
	end
	
	assign rd_data = shft_reg;
	

endmodule