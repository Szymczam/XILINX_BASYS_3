`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.02.2023 09:02:53
// Design Name: 
// Module Name: debounce
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module debounce (	
		input				clk,
		input	[WIDTH-1:0]	data_in,
		output 	[WIDTH-1:0]	data_out
	);
	
    parameter STATE_ACTIVE  = 1'b0; 
    parameter STATE_OUT     = 1'b1; 
	parameter WIDTH = 2; 
	parameter TIMEOUT = 10_000; 		// number of input clock cycles the input signal needs to be in the active state
	parameter TIMEOUT_WIDTH = $clog2(TIMEOUT);
	
	
	wire cnt_reset	[0:WIDTH-1];
	wire cnt_enable	[0:WIDTH-1];
	reg	[TIMEOUT_WIDTH-1:0]	cnt	[0:WIDTH-1];
	
	genvar i;
	generate for (i = 0; i < WIDTH; i = i+1)
        begin:  counter_loop
            always @(posedge clk)
            begin
                if(cnt_reset[i])	cnt[i] <= 0;
                else if (cnt_enable[i] == 1)	cnt[i] <= cnt[i] + 1'd1;
            end
            
        assign cnt_reset[i] = (data_in[i] == !STATE_ACTIVE);
        assign cnt_enable[i]= (data_in[i] == STATE_ACTIVE) & (cnt[i] < TIMEOUT);
        assign data_out[i] 	= (cnt[i] == TIMEOUT) ? STATE_OUT : !STATE_OUT;
                 
	   end
	   
	endgenerate
	
endmodule


module debounce2 (	
		input				    clk,
		input	    [WIDTH-1:0]	data_in,
		output reg	[WIDTH-1:0]	data_out
	);
	
    parameter STATE_ACTIVE  = 1'b0; 
    parameter STATE_OUT     = 1'b1; 
	parameter WIDTH = 2; 
`ifdef SIMULATION 
	parameter TIMEOUT = 100_000;
`else
    parameter TIMEOUT = 100; // number of input clock cycles the input signal needs to be in the active state
`endif 

	parameter TIMEOUT_WIDTH = $clog2(TIMEOUT);
	
	
	wire cnt_up	[0:WIDTH-1];
	wire cnt_down [0:WIDTH-1];
	reg	[TIMEOUT_WIDTH-1:0]	cnt	[0:WIDTH-1];
	
	integer j;
    initial begin
        for (j=0; j<=WIDTH-1; j=j+1)
            cnt[j]      = 0;
    end
	
	
	genvar i;
	generate for (i = 0; i < WIDTH; i = i+1)
        begin:  counter_loop
            always @(posedge clk)
            begin
                if (cnt_up[i] == 1)         cnt[i] <= cnt[i] + 1'd1;
                else if (cnt_down[i] == 1)  cnt[i] <= cnt[i] - 1'd1;
                
                if (cnt[i] == TIMEOUT)	  data_out[i] <= STATE_OUT;
                else if (cnt[i] == 0)	  data_out[i] <= !STATE_OUT;
                     
            end
            
        assign cnt_down[i]  = (data_in[i] == !STATE_ACTIVE)& (cnt[i] > 0);
        assign cnt_up[i]    = (data_in[i] == STATE_ACTIVE) & (cnt[i] < TIMEOUT);
                 
	   end
	   
	endgenerate
	
endmodule



