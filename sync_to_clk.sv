module synch_detect(asynch_sig_in, clk, fall_edge);

input asynch_sig_in, clk;
output reg fall_edge;

logic not_sig, prev_sig, prev_sig2, prev_sig3;

dff idff(.D(asynch_sig_in), .clk(clk), .Q(prev_sig));
dff idff2(.D(prev_sig), .clk(clk), .Q(prev_sig2));
dff idff1(.D(prev_sig2), .clk(clk), .Q(prev_sig3));

not inot_sig(not_sig, prev_sig2);

and synch_and(fall_edge, not_sig, prev_sig3);

endmodule