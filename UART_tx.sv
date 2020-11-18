module UART_tx(clk, rst_n, TX, trmt, tx_data, tx_done);

input clk, rst_n;		// 50MHz system clock & active low reset
input trmt;			// asserted for 1 clock to initiate transmission
input [7:0] tx_data;		// data to transmit
output logic TX, tx_done;	// TX is the serial line, tx_done asserted back to Master SM
	
typedef enum reg[1:0]{IDLE, LOAD, TRANSMIT} state_t;
state_t state, nxt_state;

localparam CLKS_PER_BIT = 5208;

logic [3:0] bit_cnt;	 	// bit count
logic [12:0] baud_cnt;	 	// baud count
logic [8:0] tx_shft_reg; 	
logic load, shift, transmit;	
logic set_done;	

// set up state transitions
always_ff @(posedge clk, negedge rst_n) 
begin
	if(!rst_n)
		state <= IDLE;
	else
		state <= nxt_state;
end

// state machine
always_comb
begin
	// default outputs
	load = 0;
	shift = 0;
	set_done = 0;
	nxt_state = state;
	
	case(state)
	
		IDLE: 
		begin // load value when start signal is asserted
			if(trmt) 
			begin
				transmit = 1;
				load = 1;
				tx_done = 0;
				nxt_state = LOAD;
			end
		end
		
		LOAD:
		begin // start shifting
			if(baud_cnt == CLKS_PER_BIT-1)
				shift = 1;
				nxt_state = TRANSMIT;
		end
				
		TRANSMIT: 
		begin // shift bits at the baud rate and check if all bits have been shifted
			if(baud_cnt == CLKS_PER_BIT-1)
			begin
				if(bit_cnt < 9)
				begin
					shift = 1;
				end	else
				begin
					transmit = 0;
					tx_done = 1;
					nxt_state = IDLE;
				end
			end
		end
		
	endcase
end

// shift
always @(posedge clk, negedge rst_n) 
begin
	if(!rst_n)
		tx_shft_reg <= 0;
	else if(load)
		tx_shft_reg <= {tx_data, 1'b0};
	else if(shift)
		tx_shft_reg <= {1'b1,tx_shft_reg[8:1]};
end

// bit count
always_ff @(posedge clk, negedge rst_n) 
begin
	if(!rst_n)
		bit_cnt <= 4'h0;
	else if(transmit)
	begin
		if(baud_cnt == CLKS_PER_BIT-1)
		begin
			if(bit_cnt < 9)
				bit_cnt <= bit_cnt + 1;				
			else
				bit_cnt <= 0;
		end
	end
end

// baud count
always_ff @(posedge clk, negedge rst_n) 
begin
	if(!rst_n)
		baud_cnt <= 0;
	else if(transmit)
	begin
		if(baud_cnt < CLKS_PER_BIT-1)
			baud_cnt <= baud_cnt + 1;
		else
			baud_cnt <= 0;
	end else
		baud_cnt <= 0;
end

assign TX = tx_shft_reg[0];

endmodule