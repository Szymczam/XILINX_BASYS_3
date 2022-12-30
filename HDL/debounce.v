module debounce (	
		input				clk,
		input	[WIDTH-1:0]	data_in,
		output 	[WIDTH-1:0]	data_out
	);

	parameter WIDTH = 1; 
	parameter TIMEOUT = 1000; 		// number of input clock cycles the input signal needs to be in the active state
	parameter TIMEOUT_WIDTH = 16;		// set to be ceil(log2(TIMEOUT)) 
	
	
	wire	cnt_reset	[0:WIDTH-1];
	wire	cnt_enable	[0:WIDTH-1];
	reg	[TIMEOUT_WIDTH-1:0]	cnt	[0:WIDTH-1];
	
	genvar i;
	generate for (i = 0; i < WIDTH; i = i+1)
	begin:  counter_loop
		always @(posedge clk)
		begin
			if(cnt_reset[i])	cnt[i] <= 0;
			else if (cnt_enable[i] == 1)	cnt[i] <= cnt[i] + 1'd1;
		end
		
	assign cnt_reset[i] 	= (data_in[i] == 1);
    assign cnt_enable[i] = (data_in[i] == 0) & (cnt[i] < TIMEOUT);
    assign data_out[i] 	= (cnt[i] == TIMEOUT) ? 1'b0 : 1'b1;
		
	end
	endgenerate
	
endmodule
