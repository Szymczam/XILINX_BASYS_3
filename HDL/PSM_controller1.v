
// ============================================================================
//
//	FileName:      PSM_controller.v
//
//	Date: 			24/02/2021 
//
// ============================================================================


module SR_latch (input CLK, input S, input R, output reg Q);
    always @(posedge CLK) 
    begin
        if(R)       Q <= 1'b0;
        else if(S)  Q <= 1'b1;
	end	
endmodule

module SR_latch_asy (input CLK, input S, input R, output reg Q);
    always @(posedge CLK, posedge R) 
    begin
        if(R)       Q <= 1'b0;
        else if(S)  Q <= 1'b1;
	end	
endmodule


module PSM_controller1 (	
	input				CLK,
	input				RST,
	input	[15:0]		iSPS_value,
	input	[15:0]		iDPS_value,
	input				iSPS_sign,
	input				iDPS_sign,
	input				iN,
	input	[15:0]		iFREQUENCY,
	input	[15:0]		iDEADTIME,
	input               iSych1,
	input               iSych2,
	output 	[7:0]		oPSM
);

	localparam BITS_DATA 	=	16;
	
	wire 	n_rst;
	assign n_rst = !RST;
	
	reg	[BITS_DATA-1:0]	upper = 0;
	reg	[BITS_DATA-1:0]	upper2 = 0;
	reg	[BITS_DATA-1:0]	upper4 = 0;
	always @(posedge CLK) upper = iFREQUENCY-2;
	always @(posedge CLK) upper2 = iFREQUENCY/2 -0;
	always @(posedge CLK) upper4 = iFREQUENCY/4 -0;
	
	wire [3:0]	PSM1;
	wire [3:0]	PSM2;
	wire [7:0]	PSM3;


    //----------------------------------------------------------
	// Main triangular counter
	//----------------------------------------------------------
	reg 				cnt_sign1 = 0;
	reg 				cnt_sign2 = 0;
	reg	[BITS_DATA-1:0]	cnt_value1 = 0;
	reg	[BITS_DATA-1:0]	cnt_value2 = 2000+1;

	always @(posedge CLK)
	begin
		if (RST) 						cnt_sign1 <= 1'b0;
		else if (cnt_value1 == upper)	cnt_sign1 <= 1'b1;
		else  							cnt_sign1 <= 1'b0;
	
		if (RST) 						cnt_value1 <= 0;
		else if (cnt_sign1 == 1'b1)		cnt_value1 <= 0;
		else  							cnt_value1 <= cnt_value1 + 1;

		if (RST) 						cnt_sign2 <= 1'b0;
		else if (cnt_value2 ==  upper)	cnt_sign2 <= 1'b1;
		else  							cnt_sign2 <= 1'b0;
		
		if (RST) 						cnt_value2 <= upper2;
		else if (cnt_sign2 == 1'b1)		cnt_value2 <= 0;
		else  							cnt_value2 <= cnt_value2 + 1;
	end



	// Select sfift sps and dps values
	reg 	[BITS_DATA-1:0]	SPS_value1 = 0;
	reg 	[BITS_DATA-1:0]	DPS_value1 = 0;
	reg 	[BITS_DATA-1:0]	SPS_value = 0;
	reg 	[BITS_DATA-1:0]	SPS_value_p = 0;
	reg 	[BITS_DATA-1:0]	SPS_value_n = 0;
	reg 	[BITS_DATA-1:0]	DPS_value = 0;
	reg 	[BITS_DATA-1:0]	DPS_value_p = 0;
	reg 	[BITS_DATA-1:0]	DPS_value_n = 0;
	
	reg 	SPS_sign = 0;
	reg 	DPS_sign = 0;
	reg 	N = 0;

	reg update = 0;
	always @(posedge CLK) update <= (cnt_value1 >= upper-1) ? 1'b1: 1'b0;

    ///////////////////////////////////////////////////////////
	always @(posedge CLK)
    begin
	   if(RST)                       SPS_value1 <= 0;
	   else if(iSPS_value > upper)   SPS_value1 <= iFREQUENCY;
	   else 						 SPS_value1 <= iSPS_value;
	end
	
	always @(posedge CLK)
	begin
	   if(RST)             SPS_value <= 0;
	   else if(update)     SPS_value <= SPS_value1;
	end
	
	always @(posedge CLK)
    begin
	   if(RST || iSPS_sign) SPS_value_p <= 0;
	   else 			    SPS_value_p <= SPS_value;
	end
	always @(posedge CLK)
    begin
	   if(RST || iSPS_sign) SPS_value_n <= SPS_value;
	   else 				SPS_value_n <= 0;
	end
	
	
	///////////////////////////////////////////////////////////
	always @(posedge CLK)
    begin
	   if(RST)                       DPS_value1 <= 0;
	   else if(iSPS_value > upper)   DPS_value1 <= iFREQUENCY;
	   else 						 DPS_value1 <= iDPS_value;
	end
	
	always @(posedge CLK)
	begin
	   if(RST)                     DPS_value <= 0;
	   else if(update)             DPS_value <= DPS_value1;
	end
	
	always @(posedge CLK)
    begin
	   if(RST || iDPS_sign)          DPS_value_p <= 0;
	   else 						 DPS_value_p <= DPS_value;
	end
	
	always @(posedge CLK)
    begin
	   if(RST || iDPS_sign)          DPS_value_n <= DPS_value;
	   else 						 DPS_value_n <= 0;
	end
	
	
	///////////////////////////////////////////////////////////
	always @(posedge CLK)
	begin
	   if(RST)         SPS_sign <= iSPS_sign;
	   else if(update) SPS_sign <= iSPS_sign;
	end
	
	always @(posedge CLK)
	begin
	   if(RST)         DPS_sign <= iDPS_sign;
	   else if(update) DPS_sign <= iDPS_sign;
	end
	
	always @(posedge CLK)
	begin
	   if(RST)         N <= iN;
	   else if(update) N <= iN;
	end
	
    //----------------------------------------------------------
	// PSM1: Displacement Capture
	//----------------------------------------------------------
	reg  [2:0] PSM1r;
	wire [1:0] PSM1w;

	always @(posedge CLK)
	begin
		if (RST) 							PSM1r[0] <= 1'b0;
		else if(cnt_value1 == SPS_value_p) 	PSM1r[0] <= 1'b1;
		else 								PSM1r[0] <= 1'b0;

		if (RST) 							PSM1r[1] <= 1'b0;
		else if(cnt_value2 == SPS_value_p) 	PSM1r[1] <= 1'b1;
		else 								PSM1r[1] <= 1'b0;

		if (RST) 							PSM1r[2] <= 1'b0;
		else if(cnt_value1 == upper4) 		PSM1r[2] <= 1'b1;
		else 								PSM1r[2] <= 1'b0;
	end

	SR_latch	SR_latch1a(.CLK(CLK), .S(PSM1r[0]), .R(PSM1r[1] && !RST), .Q(PSM1w[0])); 
	SR_latch	SR_latch1b(.CLK(CLK), .S(PSM1r[2]), .R(RST), 			  .Q(PSM1w[1])); 
	assign PSM1[0] = PSM1w[0] && PSM1w[1];

	
	
    //----------------------------------------------------------
	// PSM2: Displacement Capture
	//----------------------------------------------------------
	reg  [4:0] PSM2r;
    wire [4:0] PSM2w;
	reg [BITS_DATA-1:0]	tmp22 = 0;
	reg [BITS_DATA-1:0]	tmp32 = 0;
	reg [BITS_DATA-1:0]	tmp42 = 0;
	reg [BITS_DATA-1:0]	tmp52 = 0;
	reg [BITS_DATA-1:0]	tmp62 = 0;
	reg [BITS_DATA-1:0]	tmp72 = 0;
	reg [BITS_DATA-1:0]	tmp82 = 0;

	always @(posedge CLK)
	begin
		tmp22 <= upper - DPS_value_p;
		tmp32 <= SPS_value_p + DPS_value_p;
		tmp42 <= SPS_value_p + tmp22;
		tmp52 <= SPS_value_p - DPS_value_p;
		tmp82 <= DPS_value_p/2 + upper4;
		

		if (RST) 							PSM2r[3] = 1'b0;
		else if(tmp42 >= upper) 			PSM2r[3] = 1'b1;
		else 								PSM2r[3] = 1'b0;

		if(PSM2r[3] == 1'b1) 				tmp62 <= tmp52;
		else 								tmp62 <= tmp42;

		if(DPS_sign == 1'b1) 				tmp72 <= tmp62;
		else 								tmp72 <= tmp32;

		if (RST) 							PSM2r[0] <= 1'b0;
		else if(cnt_value1 == tmp72) 		PSM2r[0] <= 1'b1;
		else 								PSM2r[0] <= 1'b0;

		if (RST) 							PSM2r[1] <= 1'b0;
		else if(cnt_value2 == tmp72) 		PSM2r[1] <= 1'b1;
		else 								PSM2r[1] <= 1'b0;

		if (RST) 							PSM2r[2] <= 1'b0;
		else if(cnt_value1 == tmp82) 		PSM2r[2] <= 1'b1;
		else 								PSM2r[2] <= 1'b0;

		if (RST) 							PSM2r[4] <= 1'b0;
		else if(cnt_value2 == 0) 			PSM2r[4] <= 1'b1;
		else 								PSM2r[4] <= 1'b0;

	end

	SR_latch	SR_latch2a(.CLK(CLK), .S(PSM2r[0]),	.R(PSM2r[1] || RST),  	.Q(PSM2w[0])); 
	SR_latch	SR_latch2b(.CLK(CLK), .S(PSM2r[2]), .R(RST), 				.Q(PSM2w[1])); 
	assign  PSM2w[2] = PSM2w[0] && PSM2w[1];

	
	SR_latch	SR_latch2c(.CLK(CLK), .S(PSM2r[4]),	.R(RST), 				.Q(PSM2w[3])); 
	SR_latch_asy SR_latch2d(.CLK(CLK), .S(PSM2r[2]), .R(PSM2w[3] || RST), 	.Q(PSM2w[4])); 
    assign  PSM1[1] = PSM2w[2] || PSM2w[4];



    //----------------------------------------------------------
	// PSM3: Displacement Capture
	//----------------------------------------------------------
	reg  [2:0] PSM3r;
    wire [1:0] PSM3w;

	always @(posedge CLK)
	begin
		if (RST) 							PSM3r[0] <= 1'b0;
		else if(cnt_value1 == SPS_value_n) 	PSM3r[0] <= 1'b1;
		else 								PSM3r[0] <= 1'b0;

		if (RST) 							PSM3r[1] <= 1'b0;
		else if(cnt_value2 == SPS_value_n) 	PSM3r[1] <= 1'b1;
		else 								PSM3r[1] <= 1'b0;

		if (RST) 							PSM3r[2] <= 1'b0;
		else if(cnt_value1 == upper4) 		PSM3r[2] <= 1'b1;
		else 								PSM3r[2] <= 1'b0;
	end

	SR_latch	SR_latch3a(.CLK(CLK), .S(PSM3r[0]),	.R(PSM3r[1] && n_rst), .Q(PSM3w[0])); 
	SR_latch	SR_latch3b(.CLK(CLK), .S(PSM3r[2]), .R(RST), 		       .Q(PSM3w[1])); 
    assign  PSM1[2] = PSM3w[0] && PSM3w[1];
    
    
    //----------------------------------------------------------
	// PSM4: Displacement Capture
	//----------------------------------------------------------
	reg 			    PSM4r0 = 0;
	reg 			    PSM4r1 = 0;
	reg 			    PSM4r2 = 0;
	reg 			    PSM4r3 = 0;
	reg [BITS_DATA-1:0]	tmp14 = 0;	
	reg [BITS_DATA-1:0]	tmp24 = 0;
	reg [BITS_DATA-1:0]	tmp34 = 0;
	reg [BITS_DATA-1:0]	tmp44 = 0;
	reg [BITS_DATA-1:0]	tmp54 = 0;
	reg [BITS_DATA-1:0]	tmp64 = 0;
	wire 			PSM4w0;
	wire 			PSM4w1;

	always @(posedge CLK)
	begin
		tmp14 <= upper - DPS_value_n;
		tmp24 <= SPS_value_n + DPS_value_n;
		tmp34 <= SPS_value_n + tmp14;
		tmp44 <= tmp34 - upper;

		if (RST) 							PSM4r3 <= 1'b0;
		else if(tmp34 >= upper) 			PSM4r3 <= 1'b1;
		else 								PSM4r3 <= 1'b0;

		if(PSM4r3) 						    tmp54 <= tmp44;
		else 								tmp54 <= tmp34;

		if(DPS_sign) 						tmp64 <= tmp54;
		else 								tmp64 <= tmp24;

		if (RST) 							PSM4r0 <= 1'b0;
		else if(cnt_value1 == tmp64) 		PSM4r0 <= 1'b1;
		else 								PSM4r0 <= 1'b0;

		if (RST) 							PSM4r1 <= 1'b0;
		else if(cnt_value2 == tmp64) 		PSM4r1 <= 1'b1;
		else 								PSM4r1 <= 1'b0;

		if (RST) 							PSM4r2 <= 1'b0;
		else if(cnt_value1 == upper4) 		PSM4r2 <= 1'b1;
		else 								PSM4r2 <= 1'b0;
	end

	SR_latch	SR_latch4a(.CLK(CLK), .S(PSM4r0),	.R(PSM4r1 && n_rst), 	.Q(PSM4w0)); 
	SR_latch	SR_latch4b(.CLK(CLK), .S(PSM4r2), 	.R(RST), 				.Q(PSM4w1)); 
	and 		AND4(PSM1[3], PSM4w0, PSM4w1);


    //----------------------------------------------------------
	// Deadtime
	//----------------------------------------------------------
	localparam DEADTIME_BITS_DATA = 8;
	
	wire deadtime_rst;
	wire [DEADTIME_BITS_DATA-1:0] deadtime_val;
    
    assign deadtime_rst = RST || !PSM1w[1];
    assign deadtime_val = iDEADTIME[DEADTIME_BITS_DATA-1:0];

	PSM_deadtime2 #(.BITS_DATA(DEADTIME_BITS_DATA))	psm_0	(CLK, (deadtime_rst), deadtime_val, PSM1[0], oPSM[1:0]);
	PSM_deadtime2 #(.BITS_DATA(DEADTIME_BITS_DATA))	psm_1	(CLK, (deadtime_rst), deadtime_val, PSM1[1], oPSM[3:2]);
	PSM_deadtime2 #(.BITS_DATA(DEADTIME_BITS_DATA))	psm_2	(CLK, (deadtime_rst), deadtime_val, PSM1[2], oPSM[5:4]);
	PSM_deadtime2 #(.BITS_DATA(DEADTIME_BITS_DATA))	psm_3	(CLK, (deadtime_rst), deadtime_val, PSM1[3], oPSM[7:6]);
	

endmodule


