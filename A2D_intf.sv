module A2D_intf(clk,rst_n,strt_cnv,cnv_cmplt,chnnl,res,SS_n,SCLK,MOSI,MISO);

	input clk,rst_n;	// clock and synch active low reset
	input strt_cnv;		// Asserted for at least one clock cycle to start a conversion
	input [2:0] chnnl;	// Specifies which A2D channel (0...7) to convert
	output logic cnv_cmplt;		// Asserted by A2D_intf to indicate the conversion has completed. Should stay asserted until the next strt_cnv
	output logic [11:0] res;		// The 12-bit result from A2D (lower 12-bits read from SPI)
	output logic SS_n;		// Active low slave select (to A2D)
	output logic SCLK;		// Serial clock to the A2D
	output logic MOSI;		// Master Out Slave In (serial data to the A2D)
	input MISO;		// Master In Slave Out (serial data from the A2D)

	logic wrt;
	logic set_rdy;
	logic clr_rdy;
	
	logic [15:0] rd_data;

	typedef enum reg[1:0]{IDLE,SEND,WAIT,READ} state_t;
	state_t state, nxt_state;

	///////////////////////////
	// Instantiate SPI_mstr //
	/////////////////////////
	SPI_mstr16 iSPI(.clk(clk),.rst_n(rst_n),.SS_n(SS_n),
			.SCLK(SCLK),.MOSI(MOSI),.MISO(MISO),.wrt(wrt),
			.cmd({2'b00,chnnl,11'h000}),.done(done),.rd_data(rd_data));
			
	////////////////////////
	// Set Up Next State //
	//////////////////////
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			state <= IDLE;
		else
			state <= nxt_state;
	end
	
	////////////////////
	// State Machine //
	//////////////////
	always_comb begin
		// default outputs
		wrt = 0;
		set_rdy = 0;
		clr_rdy = 0;
		nxt_state = state;
		
		case(state)
			
			IDLE: 
				if(strt_cnv) begin
					wrt = 1;
					clr_rdy = 1;
					nxt_state = SEND;
				end
			
			SEND: 
				if(done) begin
					nxt_state = WAIT;
				end
			
			WAIT: begin
				wrt = 1;
				nxt_state = READ;
			end
			
			READ: 
				if(done) begin
					set_rdy = 1;
					nxt_state = IDLE;
				end
			
		endcase
	end
	
	////////////////////////////
	// Set up cnv_cmplt flop //
	//////////////////////////
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			cnv_cmplt <= 0;
		else if(set_rdy)
			cnv_cmplt <= 1;
		else if(clr_rdy)
			cnv_cmplt <= 0;
	end
	
	/////////////////
	// Set up res //
	///////////////
	assign res = ~rd_data[11:0];
	
endmodule