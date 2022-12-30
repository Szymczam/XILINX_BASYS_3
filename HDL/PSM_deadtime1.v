//***************************************************************
// ============================================================================
//
//	FileName:      PSM_deadtime.v
//
//	Date: 			22/08/2022
//
// ============================================================================

module PSM_deadtime1 (CLK, RST, iSHIFT, iPSM, oPSM);
	parameter BITS_DATA 	=	8;
	
	input                  CLK;
	input                  RST;
	input[BITS_DATA-1:0]   iSHIFT;
	input                  iPSM;
	output [1:0]           oPSM;
	

	reg [BITS_DATA-1:0]	cnt0, cnt1;
    reg [1:0]		    psm1, psm2, enb;
    
    always @(posedge CLK) psm1 <= {!iPSM, iPSM};
        
    always @(posedge CLK) 
    begin
        if (RST) 				cnt0 <= 1'b0; 
		else if(iPSM == 1'b1) 	cnt0 <= cnt0 + 1; 
		else 			        cnt0 <= 1'b0;

		if (RST)                cnt1 <= 1'b0; 
		else if(iPSM == 1'b0) 	cnt1 <= cnt1 + 1; 
		else 			        cnt1 <= 1'b0;
    end	
    
    
    always @(posedge CLK) begin
        if (RST) 			     enb[0] <= 1'b0; 
        else if (cnt0 >= iSHIFT) enb[0] <= 1'd1;
        else                     enb[0] <= 1'd0; 
        
        if (RST) 			     enb[1] <= 1'b0; 
        else if (cnt1 >= iSHIFT) enb[1] <= 1'd1;
        else                     enb[1] <= 1'd0; 
    end
    
    always @(posedge CLK) 
    begin
        if (RST)                                psm2[0] <= 1'b0; 
        else if ((psm1[0] == 1'b1) && enb[0])   psm2[0] <= 1'b1;	
        else                                    psm2[0] <= 1'b0;	
    end
    
    always @(posedge CLK) 
    begin
        if (RST)                                psm2[1] <= 1'b0; 
        else if ((psm1[1] == 1'b1) && enb[1])   psm2[1] <= 1'b1;    
        else                                    psm2[1] <= 1'b0;	 
    end
    
    FDCE #(.INIT(1'b0)) FDCE_inst0 (.Q(oPSM[0]), .C(CLK), .CE(enb[0]), .CLR(psm1[1] || RST), .D(psm1[0]));
    FDCE #(.INIT(1'b0)) FDCE_inst1 (.Q(oPSM[1]), .C(CLK), .CE(enb[1]), .CLR(psm1[0] || RST), .D(psm1[1]));
    
endmodule

