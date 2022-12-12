//***************************************************************
// ============================================================================
//
//	FileName:      PSM_deadtime.v
//
//	Date: 			22/08/2022
//
// ============================================================================

module PSM_deadtime1 (CLK, RST, iSHIFT, iPSM, oPSM);
	parameter BITS_DATA 	=	7;
	
	input                  CLK;
	input                  RST;
	input[BITS_DATA:0]     iSHIFT;
	input                  iPSM;
	output [1:0]           oPSM;
	

	reg [BITS_DATA:0]	cnt1 	= 0;
	reg [BITS_DATA:0]	cnt2 	= 0;	
    reg 	[1:0]		psm1 	= 0;
	reg 	[1:0]		psm2 	= 0;
	
    always @(posedge CLK) 
    begin
        psm1[1] <= !iPSM;
        psm1[0] <= iPSM;
    end
     
    always @(posedge CLK) 
    begin
        if (RST) 				    cnt1 <= 1'b0; 
		else if(psm1[0] == 1'b1) 	cnt1 <= cnt1 + 1; 
		else 						cnt1 <= 1'b0;
	end	
	
	
    always @(posedge CLK) 
    begin
		if (RST)                    cnt2 <= 1'b0; 
		else if(psm1[0] == 1'b0) 	cnt2 <= cnt2 + 1; 
		else 						cnt2 <= 1'b0;
    end	
    
    
    always @(posedge CLK) 
    begin
        if ((psm1[0] == 1) && (cnt1 >= iSHIFT))     psm2[0]  <= 1'b1;	
        else                                        psm2[0]  <= 1'b0;	
    end
    
    always @(posedge CLK) 
    begin
        if ((psm1[1] == 1) && (cnt2 >= iSHIFT))     psm2[1]  <= 1'b1;    
        else                                        psm2[1]  <= 1'b0;	 
    end
    
    assign oPSM = (RST) ? 2'd0 : psm2;
    
endmodule

