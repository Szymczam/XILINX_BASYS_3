`timescale 1ns / 10ps

//`include "defines.v" 
//`include "global.v" 
`define FOR_SIMULATION


module UCC21750_tb(
);
initial $display ("Enable Simulation");


//===================================================================                       
//                         UCC21750
//===================================================================    
    reg 	CLK = 1;
    reg 	CLK2 = 1;
    reg 	RST = 1;
    reg 	APWM = 0;
    reg 	PSM = 1;
    reg 	error = 1;
    always #2.5   CLK2 = ~CLK2;
    always #5     CLK = ~CLK;
   
    
    
    always #25   RST = 0;
    always #5000  APWM = ~APWM;
    always #500  PSM = ~PSM;
    always #10000 error = ~error;
    
    UCC21750 UCC21750_3(
        .CLK_temp   (CLK),
        .CLK_psm    (CLK2),
        .iRST       (RST),
        .iRST_psm   (error),
        .iAPWM      (APWM),
        .iIN        (PSM),
        .oDuty      (),
        .oOUT       ()
    );   



endmodule
