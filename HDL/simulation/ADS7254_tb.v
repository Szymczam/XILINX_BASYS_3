`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.08.2022 10:29:39
// Design Name: 
// Module Name: PSM_deadtime_tb
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


module ADS7254_tb(
    );
    
    initial $display ("Enable Simulation");
    
    reg 	CLK = 1;
    reg 	CLK32 = 1;
    
    reg 	RST = 1;
    reg     data = 0;
    reg     sync = 0;
    
    always #2.5   CLK = ~CLK;
    always #12   CLK32 = ~CLK32;
 
    
    always #25   RST = 0;
    always #3000   sync = ~sync;
   
    reg [4:0] cnt  = 0;
    wire oCLK,oCS_n;
    always@(negedge oCLK) 
	begin
        if (oCS_n)  cnt <= 0;
        else        cnt <= cnt +1;
        if (cnt > 20 && cnt < 31)  data <= 1;
        else            data <= 0;
    end
 
 
    ADS7254   ADS7254_prim(
            .iCLK_32        (CLK32),
            .iCLK_100       (CLK),
            .iRST           (RST), 
            .iSYNC          (sync),
            .iSDOA          (data),
            .iSDOB          (data),
            .oSDI           (),
            .oCS_n          (oCS_n),
            .oCLK           (oCLK),
            .odata_ch_A     (),
            .odata_ch_B     ()
    );

endmodule
