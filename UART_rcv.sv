module UART_rx(clk,rst_n,RX,clr_rdy,rx_data,rdy);

input clk, rst_n;		// 50MHz system clock & active low reset
input RX, clr_rdy;		// RX is the serial line, clr_rdy asserted when double flop displays low start
output logic [7:0] rx_data;	// data received
output logic rdy;		// asserted when received data is complete

typedef enum reg[1:0]{IDLE,RECEIVE,SHIFT} state_t;
state_t state, nxt_state;

localparam CLKS_PER_BIT = 5208;	// baud count
localparam HALF_CLKS = 2604;	// half baud count

logic [3:0] bit_cnt;	 		// bit count
logic [12:0] baud_cnt, baud;	 	// baud count
logic [8:0] rx_shft_reg; 	
logic start, shift;	
logic set_rdy, RX_temp, RX_rdy;

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
	start = 0;
	shift = 0;
	set_rdy = 0;
	nxt_state = state;
	
	case(state)
	
		IDLE: 
		begin
		// wait forlow start signal
			if(RX_temp && !RX_rdy)
			begin
				start = 1;
				nxt_state = RECEIVE;
			end
		end
		
		RECEIVE:
		begin // check when to shift signal at baud rate
			if(baud_cnt == 0)
			begin
				shift = 1;
				nxt_state = SHIFT;
			// check if shifting should end aka signal is ready
			end else if(bit_cnt == 10)
			begin
				set_rdy = 1;
			end
		end
		SHIFT:
		begin // allow time to shift and clear shift signal
			nxt_state = RECEIVE;
		end
		
	endcase
end

assign rx_data = rx_shft_reg[7:0];
assign rdy = !start && set_rdy;

//double flop RX with preset
always_ff @(posedge clk, negedge rst_n) 
begin
	if(!rst_n)
	begin
	RX_temp <= 1;
	RX_rdy <= 1;
	end else
	begin
	RX_temp <= RX;
	RX_rdy <= RX_temp;
	end
end

// shift
always @(posedge clk) 
begin
	if(shift)
		rx_shft_reg <= {RX,rx_shft_reg[8:1]};
end

// bit count
always_ff @(posedge clk, negedge rst_n) 
begin
	if(!rst_n)
		bit_cnt <= 0;
	else if(start)
		bit_cnt <= 0;
	else
	begin
		if(baud_cnt == 0)
		begin
			if(bit_cnt < 10)
				bit_cnt <= bit_cnt + 1;				
			else
				bit_cnt <= 0;
		end
	end
end

// baud count
// assign baud count to sample at mid baud of transmitter
assign baud = (start) ? HALF_CLKS : CLKS_PER_BIT; 
always_ff @(posedge clk, negedge rst_n) 
begin
	if(!rst_n)
		baud_cnt <= 0;
	else
	begin
		if(baud_cnt > 0)
			baud_cnt <= baud_cnt - 1;
		else
			baud_cnt <= baud;
	end
end

endmodule