`timescale 1ns / 1ps
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
    localparam DEADTIME_BITS_DATA   = 10;
    
    reg 	CLK = 0;
    reg 	RST = 1;
    reg 	[BITS_DATA-1:0]	iFREQUENCY = 20;
    reg 	[DEADTIME_BITS_DATA:0]	iDEADTIME = 1;
    
    always #1   CLK = ~CLK;
    
   
    reg 	   PSM2 = 1;
    wire [1:0] PSM3;
    
    always #10   RST = 0;
    always #20   PSM2 = ~PSM2;
   
    PSM_deadtime1 #(.BITS_DATA(DEADTIME_BITS_DATA))	psm    (CLK, RST, iDEADTIME, PSM2, PSM3[1:0]);

endmodule
