
// ============================================================================
//
//	FileName:      PSM_controller.v
//
//	Date: 			24/02/2021 
//
// ============================================================================

//`define FOR_SIMULATION

module PSM_controller (	
`ifdef FOR_SIMULATION
	output 	[7:0]		oPSM,
	output 	[1:0]		oPSMp1,
	output 	[1:0]		oPSMp2,
	output 	[1:0]		oPSMs1,
    output 	[1:0]		oPSMs2
`else
	input				clk,
	input				rst,
	input	[16-1:0]	iSPS,
	input	[16-1:0]	iDPS,
	input	[16-1:0]	iFREQUENCY,
	input	[7-1:0]		iDEADTIME,
	input               iSych,
	
	output 	[7:0]		oPSM,
	output 	[1:0]		oPSMp1,
	output 	[1:0]		oPSMp2,
	output 	[1:0]		oPSMs1,
    output 	[1:0]		oPSMs2
`endif
);

	localparam BITS_DATA 	=	16;
	
	wire 					n_rst;
	reg 					run = 0;
	reg						sign = 0;
	reg 					blocked1 = 0;
	reg 					blocked2 = 0;
	reg	[31:0]				delay = 0;
	reg 		[1:0]		PSM1;
	wire 		[1:0]		PSM2;
	wire 		[3:0]		PSM3;
	wire 		[7:0]		PSM4;
	
	wire 		[1:0]		PSM1a;
	reg 				   cnt_sign = 0;
	reg 				   cnt_sign2 = 0;
	reg 				   cnt_sign3 = 0;
	reg 				   cnt_sign1 = 0;
	reg	[BITS_DATA-1:0]	   cnt_value = 0;
	reg                    st = 0;


	reg	[BITS_DATA-1:0]		dps = 0;
	wire [BITS_DATA-1:0]	dps_shift1;
	wire [BITS_DATA-1:0]	dps_shift2;
	
	reg	[BITS_DATA-1:0]		frequency_half = 0;
	reg	[BITS_DATA-1:0]		frequency_half2 = 0;
	reg	[BITS_DATA:0]		cnt_value1 = 0;
	reg [4-1:0]				rune = 0;
	
	wire [14:0]			shift1_15b;
	wire [14:0]			shift2_15b;
	wire [14:0]			shift3_15b;
	wire [14:0]			shift4_15b;
	
	reg	[BITS_DATA-1:0]	shift1_value_16b = 0;
	reg	[BITS_DATA-1:0]	shift2_value_16b = 0;
	reg	[BITS_DATA-1:0]	shift3_value_16b = 0;
	reg	[BITS_DATA-1:0]	shift4_value_16b = 0;
	
	reg	[BITS_DATA-1:0]	shift1_value1_16b = 0;
	reg	[BITS_DATA-1:0]	shift2_value1_16b = 0;
	reg	[BITS_DATA-1:0]	shift3_value1_16b = 0;
	reg	[BITS_DATA-1:0]	shift4_value1_16b = 0;
	
	reg	[BITS_DATA-1:0]	shift1_value2_16b = 0;
	reg	[BITS_DATA-1:0]	shift2_value2_16b = 0;
	reg	[BITS_DATA-1:0]	shift3_value2_16b = 0;
	reg	[BITS_DATA-1:0]	shift4_value2_16b = 0;


//**********************************************************
//---------------------FOR SIMULATION-----------------------
//**********************************************************
`ifdef FOR_SIMULATION
	initial $display ("Enable Simulation");
		reg 	clk = 0;
		reg 	rst = 1;
		reg 	start = 0;
		reg 	[BITS_DATA-1:0]	iDPS = 0;
		reg 	[BITS_DATA-1:0]	iSPS = 2 + 32768*0;
		reg 	[BITS_DATA-1:0]	iFREQUENCY = 20;
		reg 	[7-1:0]	iDEADTIME = 0;

		always #50	 clk = ~clk;
		always #1000 rst = 0;
		always #1500 start = 1;
`else	
`endif
//**********************************************************
//---------------------------END----------------------------
//**********************************************************

	assign n_rst = !rst;
	
	PSM_generator	psm_0	(clk, (n_rst || !st), iSPS[16-2:0], iSPS[16-1], iFREQUENCY, cnt_sign3, PSM1a);
	PSM_generator	psm_1	(clk, (n_rst || !st), iSPS[16-2:0], iSPS[16-1], iFREQUENCY, cnt_sign1, PSM2);
	
	assign PSM3[0] 	= PSM1a[0];
	assign PSM3[1] 	= PSM2[0]; 
	assign PSM3[2] 	= PSM1a[1]; 
	assign PSM3[3] 	= PSM2[1]; 

	PSM_deadtime	psm_6	(clk, (n_rst || !st), iDEADTIME, iFREQUENCY, PSM3[0], PSM4[1:0]);
	PSM_deadtime	psm_7	(clk, (n_rst || !st), iDEADTIME, iFREQUENCY, PSM3[1], PSM4[3:2]);
	PSM_deadtime	psm_8	(clk, (n_rst || !st), iDEADTIME, iFREQUENCY, PSM3[2], PSM4[5:4]);
	PSM_deadtime	psm_9	(clk, (n_rst || !st), iDEADTIME, iFREQUENCY, PSM3[3], PSM4[7:6]);
	
	
	always @(posedge clk) frequency_half = iFREQUENCY/2;
	always @(posedge clk) frequency_half2 = iFREQUENCY/4;
	
	// Update input data
	always @(posedge clk)
	begin	
		if (cnt_value == frequency_half || !n_rst) begin
			if (iDPS >= frequency_half) 	dps <= frequency_half;
			else 							dps <= iDPS;
		end
	end
	
	
	// Main triangular counter
	always @(posedge clk)
	begin
		if (!n_rst) 						cnt_sign = 0;
		else if (cnt_value == iFREQUENCY-1)	cnt_sign = 1;
		else  								cnt_sign = 0;
		
		
		if (!n_rst) 						st <= 0;
		else if (cnt_sign == 1)				st <= 1;
		
		
		cnt_sign2 <= cnt_sign;
		cnt_sign3 <= cnt_sign2;
		
		if (!n_rst) 					cnt_value <= 0;
		else if (cnt_sign == 1)			cnt_value <= 0;
		else  							cnt_value <= cnt_value + 1;
		
		if (!n_rst || !st) 		cnt_sign1 = 0;
		else if (cnt_value == dps)		cnt_sign1 = 1;
		else  							cnt_sign1 = 0;
	end

	
	assign shift1_15b = (iSPS[16-1]) ? iSPS[16-2:0] : 15'd0;
	assign shift2_15b = (iSPS[16-1]) ? iSPS[16-2:0] : 15'd0;
	assign shift3_15b = (iSPS[16-1]) ? 15'd0 		: iSPS[16-2:0];
	assign shift4_15b = (iSPS[16-1]) ? 15'd0 		: iSPS[16-2:0];
	
	assign dps_shift1 = (iSPS[16-1]) ? dps 		    : 16'd0;
	assign dps_shift2 = (iSPS[16-1]) ? 16'd0 		: dps;
	

    
/*	
	always @(posedge clk) shift1_value_16b = frequency_half + {0'b0, shift1_15b} + iDEADTIME +1;
	always @(posedge clk) shift2_value_16b = frequency_half + {0'b0, shift2_15b} + iDEADTIME + iDPS + 1;
	always @(posedge clk) shift3_value_16b = frequency_half + {0'b0, shift3_15b} + iDEADTIME + 1;
    always @(posedge clk) shift4_value_16b = frequency_half + {0'b0, shift4_15b} + iDEADTIME + iDPS + 1;
*/	
	always @(posedge clk) shift1_value_16b <= frequency_half2 +  shift1_15b/2;
	always @(posedge clk) shift1_value1_16b <= shift1_value_16b + iDEADTIME;
	always @(posedge clk) shift1_value2_16b <= shift1_value1_16b;
	
	always @(posedge clk) shift2_value_16b <= frequency_half2 +  shift2_15b/2;
	always @(posedge clk) shift2_value1_16b <= shift2_value_16b +  iDEADTIME;
	always @(posedge clk) shift2_value2_16b <= shift2_value1_16b + dps_shift1;
	
	always @(posedge clk) shift3_value_16b <= frequency_half2 +  shift3_15b/2;
	always @(posedge clk) shift3_value1_16b <= shift3_value_16b + iDEADTIME;
	always @(posedge clk) shift3_value2_16b <= shift3_value1_16b ;
	
	always @(posedge clk) shift4_value_16b <= frequency_half2 + shift4_15b/2;
	always @(posedge clk) shift4_value1_16b <= shift4_value_16b + iDEADTIME;
	always @(posedge clk) shift4_value2_16b <= shift4_value1_16b + dps_shift2;
		
	
// delay 1st sygnal
always @(posedge clk) 
begin

	if	(!n_rst | !st) 	cnt_value1 <= 0;					
	else 				cnt_value1 <= cnt_value1 + 1;

	if	(!n_rst | !st) begin				
		rune <= 0;
	end	
	else begin
        if(cnt_value1[15:0] == shift1_value2_16b) rune[0] <= 1;
        if(cnt_value1[15:0] == shift2_value2_16b) rune[1] <= 1;
        if(cnt_value1[15:0] == shift3_value2_16b) rune[2] <= 1;
        if(cnt_value1[15:0] == shift4_value2_16b) rune[3] <= 1;	
	end	
	
end

	
	assign	oPSM[1:0] = (rune[0]) ? PSM4[1:0] : 0;
	assign	oPSM[3:2] = (rune[1]) ? PSM4[3:2] : 0;
	assign	oPSM[5:4] = (rune[2]) ? PSM4[5:4] : 0;
	assign	oPSM[7:6] = (rune[3]) ? PSM4[7:6] : 0;
	
	assign	oPSMp1 = (rune[0]) ? PSM4[1:0] : 0;
	assign	oPSMp2 = (rune[1]) ? PSM4[3:2] : 0;
	assign	oPSMs1 = (rune[2]) ? PSM4[5:4] : 0;
	assign	oPSMs2 = (rune[3]) ? PSM4[7:6] : 0;
	

	
endmodule
