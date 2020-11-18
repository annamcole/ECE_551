module UART_tb();

logic clk, rst_n, X; // 50MHz system clock & active low reset, X is the serial line
logic trmt, tx_done; // trmt is start signal, tx_done is asserted when tramsitter has finished transmitting
logic [7:0] tx_data; // data to transmit
logic clr_rdy,rdy;	 // clr_rdy is asserted when receiver values should be cleared, rdy is asserted when reciever has finished receiving
logic [7:0] rx_data; // data received


UART_tx iDUT1(.clk(clk),.rst_n(rst_n),.TX(X),.trmt(trmt),.tx_data(tx_data),.tx_done(tx_done));
UART_rx iDUT2(.clk(clk),.rst_n(rst_n),.RX(X),.clr_rdy(tx_done),.rx_data(rx_data),.rdy(rdy));

initial 
begin
	clk = 0;
	rst_n = 0;
	tx_data = 8'h00;
	
	// test 1: 0x00
	@(posedge clk);
	@(negedge clk) rst_n = 1;
	trmt = 1;
	tx_data = 8'h00;
	@(posedge clk) trmt = 0;
	repeat (52080)@(posedge clk);
	if(tx_data != tx_data)
	begin
		$display("ERR: input: %h output: %h", tx_data, rx_data);
		$stop;
	end
	
	// test 2: 0x3A
	@(posedge clk);
	trmt = 1;
	tx_data = 8'h3A;
	@(posedge clk) trmt = 0;
	repeat (52080)@(posedge clk);
	if(tx_data != tx_data)
	begin
		$display("ERR: input: %h output: %h", tx_data, rx_data);
		$stop;
	end
	
	// test3: 0x
	@(posedge clk);
	trmt = 1;
	tx_data = 8'hFF;
	@(posedge clk) trmt = 0;
	repeat (52080)@(posedge clk);
	if(tx_data != tx_data)
	begin
		$display("ERR: input: %h output: %h", tx_data, rx_data);
		$stop;
	end
	
	$display("YAHOO! Tests passed");
	$stop;
end

always
	#5 clk = ~clk;

endmodule