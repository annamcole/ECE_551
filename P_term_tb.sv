module P_term_tb();

	logic signed [15:0] error;
	logic signed [14:0] P_term, actual;

	P_term iDUT(.error(error), .P_term(P_term));

	initial begin
	
		// test1: positive w/ no saturation
		error = 16'h0032;
		actual = 15'h012C;
		#15;
		if( P_term != actual ) begin
			$display("ERR at time %t: test1",$time,error);
			$stop;
		end
		
		// test2: positive w/ saturation
		error = 16'h5456;
		actual = 15'h17FA;
		#15;
		if( P_term != actual ) begin
			$display("ERR at time %t: test2",$time);
			$stop;
		end
		
		// test3: negative w/ no saturation
		error = 16'hFF03;
		actual = 15'h2A12;
		#15;
		if( P_term != actual ) begin
			$display("ERR at time %t: test3",$time);
			$stop;
		end
		
		// test4: negative w/ saturation
		error = 16'hD600;
		actual = 15'h1800;
		#15;
		if( P_term != actual ) begin
			$display("ERR at time %t: test4",$time);
			$stop;
		end
		
		// test5: zero
		error = 16'h0000;
		actual = 15'h0000;
		#15;
		if( P_term != actual ) begin
			$display("ERR at time %t: test5",$time);
			$stop;
		end
		
		$display("YAHOO!! Tests passed");
		$stop;
		
	end

endmodule