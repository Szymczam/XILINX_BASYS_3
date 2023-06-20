`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2022 10:13:40
// Design Name: 
// Module Name: mIOBUF
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
module mIOBUF(
    input           I,
    output          O,
    input           T,
    inout           IO
);
    

assign IO = T ? I : 1'bZ ;
assign O  = IO;

endmodule
