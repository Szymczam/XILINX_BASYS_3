
// ============================================================================
//
//	FileName:      PSM_controller.v
//
//	Date: 			24/02/2021 
//
// ============================================================================


module SR_latch(
    input S, R,
    output Q, Q_not
	);
    assign Q     = ~(R | Q_not);
    assign Q_not = ~(S | Q);
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
	input	[7:0]		iDEADTIME,
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
	always @(posedge CLK) upper = iFREQUENCY;
	always @(posedge CLK) upper2 = iFREQUENCY/2 + 1;
	always @(posedge CLK) upper4 = iFREQUENCY/4 + 1;
	
	wire [3:0]	PSM1;
	wire [3:0]	PSM2;
	wire [7:0]	PSM3;



	// Main triangular counter
	reg 				cnt_sign1 = 0;
	reg 				cnt_sign2 = 0;
	reg	[BITS_DATA-1:0]	cnt_value1 = 0;
	reg	[BITS_DATA-1:0]	cnt_value2 = 0;

	always @(posedge CLK)
	begin
		if (RST) 						cnt_sign1 = 1'b0;
		else if (cnt_value1 == upper)	cnt_sign1 = 1'b1;
		else  							cnt_sign1 = 1'b0;
	
		if (RST) 						cnt_value1 <= 0;
		else if (cnt_sign1 == 1'b1)		cnt_value1 <= 0;
		else  							cnt_value1 <= cnt_value1 + 1;

		if (RST) 						cnt_sign2 = 1'b0;
		else if (cnt_sign2 ==  upper)	cnt_sign2 = 1'b1;
		else  							cnt_sign2 = 1'b0;
		
		if (RST) 						cnt_value2 <= upper2;
		else if (iSych2 == 1'b1)		cnt_value2 <= 0;
		else  							cnt_value2 <= cnt_value2 + 1;
	end



	// Select sfift sps and dps values
	reg 	[BITS_DATA-1:0]	SPS_value = 0;
	reg 	[BITS_DATA-1:0]	SPS_value_p = 0;
	reg 	[BITS_DATA-1:0]	SPS_value_n = 0;
	reg 	[BITS_DATA-1:0]	DPS_value = 0;
	reg 	[BITS_DATA-1:0]	DPS_value_p = 0;
	reg 	[BITS_DATA-1:0]	DPS_value_n = 0;
	reg 	SPS_sign = 0;
	reg 	DPS_sign = 0;
	reg 	N = 0;


	always @(posedge CLK)
	begin
		if ((cnt_value1 >= upper-1) || RST)	
		begin
			if (iSPS_value > upper) 	SPS_value 	<= upper;
			else 						SPS_value 	<= iSPS_value;

			if (iSPS_sign)				SPS_value_p	<= SPS_value;
			else						SPS_value_p	<= 0;

			if (iSPS_sign)				SPS_value_n <= 0;
			else						SPS_value_n <= SPS_value;
		end	

		if ((cnt_value1 == upper-1) || RST)	
		begin
			if (iDPS_value > upper) 	DPS_value 	<= upper;
			else 						DPS_value 	<= iDPS_value;

			if (iN)						DPS_value_p <= 0;
			else						DPS_value_p <= DPS_value;

			if (iN)						DPS_value_n <= DPS_value;
			else						DPS_value_n <= 0;
		end	

		if ((cnt_value1 >= upper-1) || RST)	
		begin
			if (iSPS_sign)				SPS_sign	<= 1'b1;
			else						SPS_sign	<= 1'b0;

			if (iDPS_sign)				DPS_sign 	<= 1'b1;
			else						DPS_sign 	<= 1'b0;

			if (iN)						N 	<= 1'b1;
			else						N 	<= 1'b0;
		end	



	end


	// PSM1: Displacement Capture
	reg 	[2:0]		PSM1r = 0;
	wire 	[1:0]		PSM1w;

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

	SR_latch	SR_latch1a(.S(PSM1r[0]), .R(PSM1r[1] && n_rst), .Q(PSM1w[0])); 
	SR_latch	SR_latch1b(.S(PSM1r[2]), .R(RST), 				.Q(PSM1w[1])); 
	and 		AND1(PSM1[0], PSM1w[0], PSM1w[1]);
	

	// PSM2: Displacement Capture  
	reg 	[4:0]		PSM2r = 0;
	reg [BITS_DATA-1:0]	tmp22 = 0;
	reg [BITS_DATA-1:0]	tmp32 = 0;
	reg [BITS_DATA-1:0]	tmp42 = 0;
	reg [BITS_DATA-1:0]	tmp52 = 0;
	reg [BITS_DATA-1:0]	tmp62 = 0;
	reg [BITS_DATA-1:0]	tmp72 = 0;
	reg [BITS_DATA-1:0]	tmp82 = 0;
	wire 	[4:0]		PSM2w;

	always @(posedge CLK)
	begin
		tmp22 = upper - DPS_value_p;
		tmp32 = SPS_value_n + DPS_value_p;
		tmp42 = tmp22 + SPS_value_p;
		tmp52 = tmp42 - upper;
		tmp82 = DPS_value_p/2 + upper4;
		

		if (RST) 							PSM2r[3] = 1'b0;
		else if(tmp42 >= upper) 			PSM2r[3] = 1'b1;
		else 								PSM2r[3] = 1'b0;

		if(PSM2r[3] == 1'b1) 				tmp62 = tmp52;
		else 								tmp62 = tmp42;

		if(DPS_sign == 1'b1) 				tmp72 = tmp62;
		else 								tmp72 = tmp32;

		if (RST) 							PSM2r[0] = 1'b0;
		else if(cnt_value1 == tmp72) 		PSM2r[0] = 1'b1;
		else 								PSM2r[0] = 1'b0;

		if (RST) 							PSM2r[1] = 1'b0;
		else if(cnt_value2 == tmp72) 		PSM2r[1] = 1'b1;
		else 								PSM2r[1] = 1'b0;

		if (RST) 							PSM2r[2] = 1'b0;
		else if(cnt_value1 == tmp82) 		PSM2r[2] = 1'b1;
		else 								PSM2r[2] = 1'b0;

		if (RST) 							PSM2r[4] = 1'b0;
		else if(cnt_value2 == 0) 			PSM2r[4] = 1'b1;
		else 								PSM2r[4] = 1'b0;

	end

	SR_latch	SR_latch2a(.S(PSM2r[0]),	.R(PSM2r[1] || RST),  	.Q(PSM2w[0])); 
	SR_latch	SR_latch2b(.S(PSM2r[2]), 	.R(RST), 				.Q(PSM2w[1])); 
	and 		AND2(PSM2w[2], PSM2w[0], PSM2w[1]);
	SR_latch	SR_latch2c(.S(PSM2r[4]),	.R(RST), 				.Q(PSM2w[3])); 
	SR_latch	SR_latch2d(.S(PSM2r[2]), 	.R(PSM2w[3] || RST), 	.Q(PSM2w[4])); 
	or 			OR2(PSM1[1], PSM2w[2], PSM2w[4]);




	// PSM3: Displacement Capture
	reg 	[2:0]		PSM3r = 0;
	wire 	[1:0]		PSM3w;

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

	SR_latch	SR_latch3a(.S(PSM3r[0]),	.R(PSM3r[1] && n_rst), 	.Q(PSM3w[0])); 
	SR_latch	SR_latch3b(.S(PSM3r[2]), 	.R(RST), 		.Q(PSM3w[1])); 
	and 		AND3(PSM1[2], PSM3w[0], PSM3w[1]);


	// PSM4: Displacement Capture  
	reg 	[3:0]		PSM4r = 0;
	reg [BITS_DATA-1:0]	tmp14 = 0;	
	reg [BITS_DATA-1:0]	tmp24 = 0;
	reg [BITS_DATA-1:0]	tmp34 = 0;
	reg [BITS_DATA-1:0]	tmp44 = 0;
	reg [BITS_DATA-1:0]	tmp54 = 0;
	reg [BITS_DATA-1:0]	tmp64 = 0;
	wire 	[1:0]		PSM4w;

	always @(posedge CLK)
	begin
		tmp14 = upper - DPS_value_n;
		tmp24 = SPS_value_n + DPS_value_n;
		tmp34 = SPS_value_n + tmp14;
		tmp44 = tmp34 - upper;

		if (RST) 							PSM4r[3] = 1'b0;
		else if(tmp34 >= upper) 			PSM4r[3] = 1'b1;
		else 								PSM4r[3] = 1'b0;

		if(PSM4r[3]) 						tmp54 = tmp44;
		else 								tmp54 = tmp34;

		if(DPS_sign) 						tmp64 = tmp54;
		else 								tmp64 = tmp24;

		if (RST) 							PSM4r[0] = 1'b0;
		else if(cnt_value1 == tmp64) 		PSM4r[0] = 1'b1;
		else 								PSM4r[0] = 1'b0;

		if (RST) 							PSM4r[1] = 1'b0;
		else if(cnt_value2 == tmp64) 		PSM4r[1] = 1'b1;
		else 								PSM4r[1] = 1'b0;

		if (RST) 							PSM4r[2] = 1'b0;
		else if(cnt_value1 == upper4) 		PSM4r[2] = 1'b1;
		else 								PSM4r[2] = 1'b0;
	end

	SR_latch	SR_latch4a(.S(PSM4r[0]),	.R(PSM4r[1] && n_rst), 	.Q(PSM4w[0])); 
	SR_latch	SR_latch4b(.S(PSM4r[2]), 	.R(RST), 				.Q(PSM4w[1])); 
	and 		AND4(PSM1[3], PSM4w[0], PSM4w[1]);



    // Deadtime
	assign PSM2 = (n_rst) ? PSM1 : 0;

	PSM_deadtime1	psm_6	(CLK, (n_rst && PSM1w[1]), iDEADTIME, iFREQUENCY, PSM2[0], PSM3[1:0]);
	PSM_deadtime1	psm_7	(CLK, (n_rst && PSM1w[1]), iDEADTIME, iFREQUENCY, PSM2[1], PSM3[3:2]);
	PSM_deadtime1	psm_8	(CLK, (n_rst && PSM1w[1]), iDEADTIME, iFREQUENCY, PSM2[2], PSM3[5:4]);
	PSM_deadtime1	psm_9	(CLK, (n_rst && PSM1w[1]), iDEADTIME, iFREQUENCY, PSM2[3], PSM3[7:6]);
	
	assign	oPSM[1:0] = (n_rst) ? PSM3[1:0] : 0;
	assign	oPSM[3:2] = (n_rst) ? PSM3[3:2] : 0;
	assign	oPSM[5:4] = (n_rst) ? PSM3[5:4] : 0;
	assign	oPSM[7:6] = (n_rst) ? PSM3[7:6] : 0;
	

	
endmodule

