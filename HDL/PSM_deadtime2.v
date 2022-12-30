//***************************************************************
// ============================================================================
//
//	FileName:      PSM_deadtime.v
//
//	Date: 			22/08/2022
//
// ============================================================================

module PSM_deadtime2 (CLK, RST, iSHIFT, iPSM, oPSM);
	parameter BITS_DATA 	=	7;
	
	input                  CLK;
	input                  RST;
	input[BITS_DATA-1:0]   iSHIFT;
	input                  iPSM;
	output [1:0]           oPSM; //always has 1 clk deadtime
	
	reg  [BITS_DATA-1:0] cnt;
	reg  [1:0] psm_2b;	
    wire [1:0] out_2b;
    reg  enb;
        
	always @(posedge CLK) 
    begin    
        if (RST)  psm_2b <= 2'b11; 
		else      psm_2b <= {!iPSM, iPSM};
    
        if (RST || out_2b)  cnt <= 0; 
		else                cnt <= cnt + 1; 
		
		if (RST)                  enb <= 1'b1; 	
		else if (cnt >= iSHIFT)   enb <= 1'd1;
        else                      enb <= 1'd0;
	end		
	
	FDCE #(.INIT(1'b0)) FDCE_inst0 (.Q(out_2b[0]), .C(CLK), .CE(enb), .CLR(psm_2b[1]), .D(psm_2b[0]));
	FDCE #(.INIT(1'b0)) FDCE_inst1 (.Q(out_2b[1]), .C(CLK), .CE(enb), .CLR(psm_2b[0]), .D(psm_2b[1]));
	
    assign oPSM = out_2b;
    
endmodule
