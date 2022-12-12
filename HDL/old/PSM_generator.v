// ============================================================================
//
//	FileName:      PSM_generator.v
//
//	Date: 			26/12/2019 
//
// ============================================================================

//`define FOR_SIMULATION

module PSM_generator(	
`ifdef FOR_SIMULATION
	output 	[1:0]		oPSM
`else
	input				clk,
	input				n_rst,	
	input		[14:0]	iANGLE,
	input				iDIRECT,
	input		[15:0]	iFREQUENCY,
	input				iSych,
	output 		[1:0]	oPSM
`endif
);

	localparam BITS_DATA 	=	16-1;
	localparam MAX_FREQUENCY=	65536;//20;
	
	wire 				psm1;
	wire 				psm2;
	
	reg	[BITS_DATA-1:0]	upper = 10;
	reg	[BITS_DATA-1:0]	upper2 = 5;
	reg	[BITS_DATA-1:0]	upper3 = 5;
	reg 				cnt_sign = 0;
	reg	[BITS_DATA-1:0]	cnt_value = 0;
	reg	[BITS_DATA-1:0]	psi = 0;

	reg 				sign = 0;
	reg [1:0]			psm = 0;

//**********************************************************
//---------------------FOR SIMULATION-----------------------
//**********************************************************
`ifdef FOR_SIMULATION
	initial $display ("Enable Simulation");
		reg clk,n_rst = 0;
		reg 	[BITS_DATA-1:0]	iANGLE = 0;
		reg 	 				iDIRECT = 0;
		reg 	[BITS_DATA-1:0]	iFREQUENCY = 0;

		initial begin
			clk = 0;
			n_rst	= 0;
			iFREQUENCY = 10;
			iANGLE = 0;
			iDIRECT = 0;
		end

		always #50	clk = ~clk;
		always #1000	n_rst = 1;
`endif
//**********************************************************
//---------------------------END----------------------------
//**********************************************************	

	// Update input data
	always @(posedge clk)
	begin
	
		if (cnt_value == upper || !n_rst) begin
			if (iFREQUENCY > MAX_FREQUENCY) upper <= MAX_FREQUENCY;
			else 							upper <= iFREQUENCY-1;
			
			
			if (iFREQUENCY > MAX_FREQUENCY) upper2 <= MAX_FREQUENCY/2;
			else 							upper2 <= iFREQUENCY/2;
			

			if (iANGLE >= upper2) 		psi <= upper2-1;
			else 						psi <= iANGLE;

			sign <= iDIRECT;
		end
		
		upper3 <= upper2+psi;
	end
	
	// Main triangular counter
	always @(posedge clk)
	begin
	//	if (!n_rst) 					cnt_sign = 0;
	//	else if (cnt_value == upper)	cnt_sign = 1;
	//	else  							cnt_sign = 0;
		cnt_sign = iSych;
		
		if (!n_rst) 					cnt_value <= 0;
		else if (cnt_sign == 1)			cnt_value <= 0;
		else  							cnt_value <= cnt_value + 1;
	
	end
	
	
	always @(posedge clk)
	begin
		if (!n_rst) 				psm[0] <= 1'b0;
		else if(cnt_value < upper2) psm[0] <= 1'b1;
		else 						psm[0] <= 1'b0;

	
		if (!n_rst) 				psm[1] <= 1'b0;
		else if(cnt_value == psi)	psm[1] <= 1'b1;
		else if(cnt_value == upper3)psm[1] <= 1'b0;
	end
	
	assign psm1 	= sign ? psm[1] : psm[0]; 
	assign psm2 	= sign ? psm[0] : psm[1]; 
	assign oPSM 	= {psm2, psm1};

endmodule
