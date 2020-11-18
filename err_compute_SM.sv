module err_compute_SM(clk,rst_n,IR_vld,en_accum,clr_accum,sub,sel,err_vld);

	input clk;		// 50MHz clk
	input rst_n;	// asynch active low reset
	input IR_vld;	// start signal when IR readings are valid
	output logic en_accum;	// start accumulator
	output logic clr_accum;	// clear accumulator
	output logic sub;		// subtract IR reading
	output logic [2:0] sel;	// sensor select
	output logic err_vld; 	// asserted when error is valid
	
	typedef enum reg [1:0]{IDLE,COMPUTE,FINISH} state_t;
	state_t state, nxt_state;
	
	always_ff @(posedge clk, negedge rst_n) 
	begin
		if(!rst_n)
			state <= IDLE;
		else
			state <= nxt_state;
	end

	////////////////////
	// STATE MACHINE //
	//////////////////
	always_comb
	begin
		//////////////////////
		// Default outputs //
		////////////////////
		en_accum = 0;
		clr_accum = 0;
		sub = 0;
		err_vld = 0;
		nxt_state = state;
		
		case(state)
		
			IDLE: // wait for start signal
			begin
				if(IR_vld)
				begin
					clr_accum = 1;
					nxt_state = COMPUTE;
				end
			end
			
			COMPUTE:
			begin
				// check if all signals have been accumulated 
				// otherwise send signal for accumulation to happen
				if(sel == 7)
				begin
					sub = 1;
					en_accum = 1;
					err_vld = 1;
					nxt_state = FINISH;
				end
				else
				begin
					if(!sel[0])
						sub = 0;
					else 
						sub = 1;
						
					en_accum = 1;
				end
				
			end
			
			FINISH:
			begin
				err_vld = 1;
				nxt_state = IDLE;
			end
			
		endcase
	end
	
	/////////////////////////////////////////////////////
	// Instantiate incrementor for select bits of mux //
	///////////////////////////////////////////////////
	always_ff @(posedge clk, negedge rst_n)
	begin
		if(!rst_n)
			sel <= 0;
		else if(clr_accum)
			sel <= 0;
		else if(en_accum)
			sel <= sel + 1;
	end
  
endmodule
  
					   