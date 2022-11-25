//***************************************************************
// ============================================================================
//
//	FileName:      PSM_deadtime.v
//
//	Date: 			24/02/2021
//
// ============================================================================

//`define FOR_SIMULATION

module PSM_deadtime1 (	
`ifdef FOR_SIMULATIONa
	output 	[1:0]		oPSM
`else
	input				clk,
	input				n_rst,
	input	[7-1:0]		iSHIFT,	//min. 2
    input	[16-1:0]	iFREQUENCY,//mod2
	input				iPSM,
	output 	[1:0]		oPSM
`endif
);

	localparam BITS_DATA 	=	7;
	localparam MAX_FREQUENCY=	32768;
    
    
	reg 				tmp 	= 0;
	reg [BITS_DATA-1:0]	cnt1 	= 0;
	reg [BITS_DATA-1:0]	cnt2 	= 0;
	reg [1:0]			psm 	= 0;
	reg [1:0]			psm1 	= 0;
    reg	[16-1:0]		upper2  = 5;
	reg [16-1:0]	    cnt3 	= 0;
	reg [16-1:0]	    cnt4 	= 0;
	
//**********************************************************
//---------------------FOR SIMULATION-----------------------
//**********************************************************
`ifdef FOR_SIMULATIONa
	initial $display ("Enable Simulation");
		reg clk,n_rst = 0;
		reg [BITS_DATA-1:0]	iSHIFT = 20;
		reg iPSM = 0;
		reg [16-1:0] iFREQUENCY = 20;

		initial begin
			clk = 0;
			n_rst	    = 0;
		end

		always #50	clk = ~clk;
		always #1000	n_rst = 1;
		always #1000	iPSM = ~iPSM;
`endif

//**********************************************************
//---------------------------END----------------------------
//**********************************************************
	always @(posedge clk)
	begin
	
		if (!n_rst) begin	
			tmp 	<= 1'b1;		
			cnt2 	<= 1;
			cnt1 	<= 1; 
		end
		else begin
	
			case(iPSM)
				0:	begin 	if (cnt1 >= iSHIFT)	tmp  <= 1'b0;	
							else  				cnt1 <= cnt1 + 1; 
												cnt2 <= 1; 
												
					end
				1:	begin 	if (cnt2 >= iSHIFT)	tmp  <= 1'b1;		
							else				cnt2 <= cnt2 + 1;
												cnt1 <= 1; 
					end
				default : begin
												tmp  <= 1'b0;	
												cnt2 <= 1;
												cnt1 <= 1; 
					end
			endcase
		end
	end

    
	always @(posedge clk)
	begin
		if (!n_rst) 	    psm = 2'b0;
		else 			    psm = {(!iPSM) && (!tmp), iPSM && tmp};
		
		if (psm[0] == 1)    cnt3 = cnt3 + 1;	
		else  			    cnt3 = 0;
		
		
		if (psm[1] == 1)    cnt4 = cnt4 + 1;
		else  			    cnt4 = 0;
		
		if(cnt3 >= upper2) 	psm1[0] = 0;
		else			    psm1[0] = psm[0];
		
		if(cnt4 >= upper2) 	psm1[1] = 0;
		else			    psm1[1] = psm[1];
		
        if (iFREQUENCY > MAX_FREQUENCY) upper2 <= MAX_FREQUENCY/2;
		else 							upper2 <= iFREQUENCY/2;
		
	end
	
	
	assign oPSM = psm1;
		
endmodule

