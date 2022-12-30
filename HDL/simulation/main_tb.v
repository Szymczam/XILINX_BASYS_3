`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.08.2022 13:22:28
// Design Name: 
// Module Name: main_tb
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
`define FOR_SIMULATION

module main_tb(
);


    initial $display ("Enable Simulation");
    localparam BITS_DATA 	=	16;
    
    localparam PERIOD = 300;
    
    reg 	[31:0]	clk_cnt = 0;
    reg 	CLK = 0;
    reg 	RST = 1;
    reg 	iSPS_sign = 0;
    reg 	iDPS_sign = 0;
    reg 	iN = 0;
    reg 	[BITS_DATA-1:0]	iDPS_value = 0;
    reg 	[BITS_DATA-1:0]	iSPS_value = 0;
    reg 	[BITS_DATA-1:0]	iFREQUENCY = 4000;
    reg 	[15:0]	iDEADTIME = 25;
    
    always #1   CLK = ~CLK;
    always #1   clk_cnt = clk_cnt + 1;



    wire [4:0]	btn;
    debounce #(.WIDTH(5), .TIMEOUT(1000), .TIMEOUT_WIDTH(16)) debounce_inst(
        .clk        (CLK),
        .data_in    ({0}),
        .data_out   (btn)
    );
   
    initial begin
    
        iSPS_value  = 0;
        iSPS_sign   = 0;
     //   iDPS_value  = iFREQUENCY/4;
     //   iDPS_sign   = 1;
        
        #1000   RST = 0;

        //SPS = 90, DPS = 0
    //    #(PERIOD-20) RST = 1; 
        iSPS_value  = 0;
        iSPS_sign   = 0;
     //   iDPS_value  = iFREQUENCY/4;
     //   iDPS_sign   = 1;
      //  #1100 RST = 0;
        
//        //SPS = 90, DPS = 0
//        #(PERIOD-20) RST = 1; 
//        iSPS_value  = iFREQUENCY/4;
//        iSPS_sign   = 0;
//        iDPS_value  = 0;
//        iDPS_sign   = 0;
//        #110 RST = 0;
        
//        //SPS = -90, DPS = 0
//        #(PERIOD-20) RST = 1; 
//        iSPS_value  = iFREQUENCY/4;
//        iSPS_sign   = 1;
//        iDPS_value  = 0;
//        iDPS_sign   = 0;
//        #110 RST = 0;
        
//        //SPS = 0, DPS = 90
//        #(PERIOD-20) RST = 1; 
//        iSPS_value  = 0;
//        iSPS_sign   = 0;
//        iDPS_value  = iFREQUENCY/4;
//        iDPS_sign   = 0;
//        #110 RST = 0;    
        
//        //SPS = 0, DPS = -90
//        #(PERIOD-20) RST = 1; 
//        iSPS_value  = 0;
//        iSPS_sign   = 0;
//        iDPS_value  = iFREQUENCY/4;
//        iDPS_sign   = 1;
//        #110 RST = 0;    
        
//        //SPS = 90, DPS = 90
//        #(PERIOD-20) RST = 1; 
//        iSPS_value  = iFREQUENCY/4;
//        iSPS_sign   = 0;
//        iDPS_value  = iFREQUENCY/4;
//        iDPS_sign   = 0;
//        #110 RST = 0;        
        
//        //SPS = -90, DPS = 90
//        #(PERIOD-20) RST = 1; 
//        iSPS_value  = iFREQUENCY/4;
//        iSPS_sign   = 1;
//        iDPS_value  = iFREQUENCY/4;
//        iDPS_sign   =0;
//        #110 RST = 0;   
         
//        //SPS = 90, DPS = -90
//        #(PERIOD-20) RST = 1; 
//        iSPS_value  = iFREQUENCY/4;
//        iSPS_sign   = 0;
//        iDPS_value  = iFREQUENCY/4;
//        iDPS_sign   = 1;
//        #110 RST = 0;     
        
//        //SPS = -90, DPS = -90
//        #(PERIOD-20) RST = 1; 
//        iSPS_value  = iFREQUENCY/4;
//        iSPS_sign   = 1;
//        iDPS_value  = iFREQUENCY/4;
//        iDPS_sign   = 1;
//        #110 RST = 0;   
               
        
//        #(PERIOD-20) RST = 1; 
//        #100 iN = 1;   
        
        
//          //SPS = 90, DPS = 0
//        #(PERIOD-20) RST = 1; 
//        iSPS_value  = iFREQUENCY/4;
//        iSPS_sign   = 0;
//        iDPS_value  = 0;
//        iDPS_sign   = 0;
//        #110 RST = 0;
        
//        //SPS = -90, DPS = 0
//        #(PERIOD-20) RST = 1; 
//        iSPS_value  = iFREQUENCY/4;
//        iSPS_sign   = 1;
//        iDPS_value  = 0;
//        iDPS_sign   = 0;
//        #110 RST = 0;
        
//        //SPS = 0, DPS = 90
//        #(PERIOD-20) RST = 1; 
//        iSPS_value  = 0;
//        iSPS_sign   = 0;
//        iDPS_value  = iFREQUENCY/4;
//        iDPS_sign   = 0;
//        #110 RST = 0;    
        
//        //SPS = 0, DPS = -90
//        #(PERIOD-20) RST = 1; 
//        iSPS_value  = 0;
//        iSPS_sign   = 0;
//        iDPS_value  = iFREQUENCY/4;
//        iDPS_sign   = 1;
//        #110 RST = 0;    
        
//        //SPS = 90, DPS = 90
//        #(PERIOD-20) RST = 1; 
//        iSPS_value  = iFREQUENCY/4;
//        iSPS_sign   = 0;
//        iDPS_value  = iFREQUENCY/4;
//        iDPS_sign   = 0;
//        #110 RST = 0;        
        
//        //SPS = -90, DPS = 90
//        #(PERIOD-20) RST = 1; 
//        iSPS_value  = iFREQUENCY/4;
//        iSPS_sign   = 1;
//        iDPS_value  = iFREQUENCY/4;
//        iDPS_sign   =0;
//        #110 RST = 0;   
         
//        //SPS = 90, DPS = -90
//        #(PERIOD-20) RST = 1; 
//        iSPS_value  = iFREQUENCY/4;
//        iSPS_sign   = 0;
//        iDPS_value  = iFREQUENCY/4;
//        iDPS_sign   = 1;
//        #110 RST = 0;     
        
//        //SPS = -90, DPS = -90
//        #(PERIOD-20) RST = 1; 
//        iSPS_value  = iFREQUENCY/4;
//        iSPS_sign   = 1;
//        iDPS_value  = iFREQUENCY/4;
//        iDPS_sign   = 1;
//        #110 RST = 0;   
 
    end  
    

	reg 				cnt_sign1 = 0;
	reg 				cnt_sign2 = 0;
	reg	[BITS_DATA-1:0]	cnt_value1 = 0;
	reg	[BITS_DATA-1:0]	cnt_value2 = 0;
	
    wire 	[7:0]		oPSM;

    PSM_controller1 PSM_controller12 
    (
        .CLK           (CLK),
        .RST           (RST),
        .iSPS_value    (iSPS_value),
        .iDPS_value    (iDPS_value),
        .iSPS_sign     (iSPS_sign),
        .iDPS_sign     (iDPS_sign),
        .iN            (iN),
        .iFREQUENCY    (iFREQUENCY),
        .iDEADTIME     (iDEADTIME),
        .iSych1         (cnt_sign1),
        .iSych2         (cnt_sign2),
        .oPSM          (oPSM)
    );



	
	
	always @(posedge CLK)
	begin
		if (RST) 						cnt_sign1 = 1'b0;
		else if (cnt_value1 == iFREQUENCY)	    cnt_sign1 = 1'b1;
		else  							cnt_sign1 = 1'b0;
	
		if (RST) 						cnt_value1 <= 0;
		else if (cnt_sign1 == 1'b1)		cnt_value1 <= 0;
		else  							cnt_value1 <= cnt_value1 + 1;
	

		if (RST) 						cnt_sign2 = 1'b0;
		else if (cnt_value2 ==  iFREQUENCY)	cnt_sign2 = 1'b1;
		else  							cnt_sign2 = 1'b0;
		
		if (RST) 						cnt_value2 <= iFREQUENCY/2;
		else if (cnt_sign2 == 1'b1)		cnt_value2 <= 0;
		else  							cnt_value2 <= cnt_value2 + 1;
	end


endmodule
