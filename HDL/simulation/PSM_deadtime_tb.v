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


module PSM_deadtime_tb(
    );
    
    initial $display ("Enable Simulation");
    localparam BITS_DATA 	        = 16;
    localparam DEADTIME_BITS_DATA   = 8;
    
    reg 	CLK = 1;
    reg 	RST = 1;
    reg 	[BITS_DATA-1:0]	           iFREQUENCY = 20;
    reg 	[DEADTIME_BITS_DATA-1:0]   iDEADTIME = 1;
    
    always #2.5   CLK = ~CLK;
    
   
    reg 	   PSM2 = 0;
    wire [1:0] PSM3, PSM4;
    
    always #25   RST = 0;
    always #(2.5*5000)   PSM2 = ~PSM2;
   
    PSM_deadtime1 #(.BITS_DATA(DEADTIME_BITS_DATA))	
        psm1(CLK, RST, iDEADTIME[DEADTIME_BITS_DATA-1:0], PSM2, PSM3);
        
    PSM_deadtime2 #(.BITS_DATA(DEADTIME_BITS_DATA))	
        psm2(CLK, RST, iDEADTIME[DEADTIME_BITS_DATA-1:0], PSM2, PSM4);

endmodule
