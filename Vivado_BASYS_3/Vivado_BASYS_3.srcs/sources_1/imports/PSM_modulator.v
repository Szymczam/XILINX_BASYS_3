// ============================================================================
//
//	FileName:      PSM_controller.v
//
//	Date: 			24/02/2021 
//
// ============================================================================
`include "board_GD_DAB_v3.v" 

module SR_latch_asy (input S, input R, output reg Q, output reg Qc);
    always @(*) begin
        Q  =  ~(R | Qc); 
        Qc =  ~(S | Q); 
    end
endmodule


module SR_latch_sy (input CLK, input S, input R, output reg Q);
    always @(posedge CLK)
    begin
        if(R)       Q <= 1'b0;
        else if(S)  Q <= 1'b1;
    end
endmodule

module PWM_capture
#(
    parameter N = 16 //N bit binary counter
) (
    input          CLK, 
    input          RST, 
    input [N-1:0]  CMPA, 
    input [N-1:0]  CMPB,
    input [N-1:0]  TBPRD,
    output         PWM_o
);

    reg [1:0]   TBCTR = 0;
    wire[1:0]   CTR;

    always @(posedge CLK, posedge RST)
    begin
        if (RST == 1) TBCTR <= 0;
        else          TBCTR <= CTR;
    end
    
    assign CTR[0] = (CMPA == TBPRD) ? 1'b1 : 0'b0;
    assign CTR[1] = (CMPB == TBPRD) ? 1'b1 : 0'b0;  
    
   // SR_latch_asy	SR_latch(.S(CTR[0]), .R(CTR[1] || RST), .Q(PWM_o));
    SR_latch_sy	SR_latch(.CLK(CLK), .S(TBCTR[0]), .R(TBCTR[1] || RST), .Q(PWM_o));
    
endmodule


module Counter
#(
    parameter TBPRD = 5, // count from 0 to TBPRD-1
              N = 3 // N bits required to count upto M i.e. 2**N >= M
)
(
    input wire CLK, RST, 
    input wire[N-1:0] count_initial_i,
    output wire[N-1:0] count_o
);

    reg[N-1:0] count_reg;
    wire[N-1:0] count_next;
    
    always @(posedge CLK, posedge RST)
    begin
        if (RST == 1) count_reg <= count_initial_i;
        else          count_reg <= count_next;
    end
    
    // set count_next to 0 when maximum count is reached i.e. (TBPRD-1) otherwise increase the count
    assign count_next    = (count_reg == TBPRD-1) ? 0 : count_reg + 1'b1 ;
    assign count_o       = count_reg; // assign count to output port 
    
endmodule


module PSM_deadtime 
#(
    parameter DATA = 7
) (
    input          CLK, 
    input          RST, 
    input          PWM_i,
    output [1:0]   PWM_o
);
    localparam WIDTH = $clog2(DATA);
    
	reg  [1:0]     pwm_r = 0;	
	reg  [WIDTH:0] cnt = 0;
    reg            enb = 0;    
        
    always @(*) 
    begin    
        if (RST)  pwm_r = 2'b11; 
		else      pwm_r = {!PWM_i, PWM_i};   
    end
        
	always @(posedge CLK) 
    begin    
        if (RST || |PWM_o)  cnt <= 0; 
		else                cnt <= cnt + 1; 
	end	
	
	always @(*) 
    begin    
        if (RST)                        enb = 1'b1; 
        else if (cnt >= DATA[WIDTH:0])  enb = 1'd1;
		else                            enb = 1'd0;   
    end
		
	FDCE #(.INIT(1'b0)) FDCE_inst0 (.Q(PWM_o[0]), .C(CLK), .CE(enb), .CLR(pwm_r[1]), .D(pwm_r[0]));
	FDCE #(.INIT(1'b0)) FDCE_inst1 (.Q(PWM_o[1]), .C(CLK), .CE(enb), .CLR(pwm_r[0]), .D(pwm_r[1]));
	
endmodule


module PSM_modulator
#(
    parameter N = 16 //N bit binary counter
) (
    input				 CLK,
    input				 RST,
    input signed [N-1:0] SPS_value_i,
    input signed [N-1:0] DPS_value_i,
    input				 CPU_PSM_soft_i,
    input	[15:0]		 local_counter_i,
    output 	[7:0]		 oPSM
);

    localparam [`PSM_FREQUENCY_WIDTH-1:0] upper    = `PSM_FREQUENCY-2;
    localparam [`PSM_FREQUENCY_WIDTH-1:0] upper2   = `PSM_FREQUENCY/2;
    localparam [`PSM_FREQUENCY_WIDTH-1:0] upper23  = `PSM_FREQUENCY/4 + `PSM_FREQUENCY/2;
    localparam [N-1:0] minus_one  = -1;
    
    
    //----------------------------------------------------------
    // Main triangular counter
    //----------------------------------------------------------
    wire [`PSM_FREQUENCY_WIDTH-1:0]	cnt_value1,cnt_value2;
    
    Counter #(.TBPRD(`PSM_FREQUENCY), .N(`PSM_FREQUENCY_WIDTH)) 
            Counter_inst_a (.CLK(CLK), .RST(local_counter_i == 0), .count_initial_i(0), .count_o(cnt_value1));
    Counter #(.TBPRD(`PSM_FREQUENCY), .N(`PSM_FREQUENCY_WIDTH)) 
            Counter_inst_b (.CLK(CLK), .RST(local_counter_i == 0), .count_initial_i(`PSM_FREQUENCY/2), .count_o(cnt_value2));


    //----------------------------------------------------------
    // Select sfift sps and dps values
    //----------------------------------------------------------
    wire [`PSM_FREQUENCY_WIDTH-1:0]	SPS_value, DPS_value;

    assign SPS_value = (SPS_value_i[N-1]) ? (SPS_value_i[N-1:0] * minus_one) : {1'b0, SPS_value_i[N-2:0]};
    assign DPS_value = (DPS_value_i[N-1]) ? (DPS_value_i[N-1:0] * minus_one) : {1'b0, DPS_value_i[N-2:0]};
    
    reg update1;
    reg [`PSM_FREQUENCY_WIDTH-1:0]	SPS_value0, SPS_value1;
    reg [`PSM_FREQUENCY_WIDTH-1:0]	SPS_value_p, SPS_value_n;
    reg SPS_sign;

    always @(posedge CLK)
    begin
        if(RST)                         update1 <= 1'b0;
        else if(cnt_value1 == upper-3)  update1 <= 1'b1;
        else                            update1 <= 1'b0;
    
        if(RST)                     SPS_value0 <= 0;
        else if(SPS_value > upper2) SPS_value0 <= upper2;
        else 						SPS_value0 <= SPS_value;

        if(RST)                     SPS_value1 <= 0;
        else if(update1)            SPS_value1 <= SPS_value0;

        if(RST)                     SPS_sign <= 0;
        else if(update1)            SPS_sign <= SPS_value_i[N-1];
        
        if(RST || SPS_sign)         SPS_value_p <= 0;
        else 			            SPS_value_p <= SPS_value1;

        if(RST || SPS_sign)         SPS_value_n <= SPS_value1;
        else 				        SPS_value_n <= 0;
    end


    ///////////////////////////////////////////////////////////	
    reg [`PSM_FREQUENCY_WIDTH-1:0]	DPS_value0, DPS_value1, DPS_value_p, DPS_value_n;
    reg DPS_sign;

    always @(posedge CLK)
    begin
        if(RST)                     DPS_value0 <= 0;
        else if(DPS_value > upper2) DPS_value0 <= upper2;
        else                        DPS_value0 <= DPS_value;

        if(RST)                     DPS_value1 <= 0;
        else if(update1)            DPS_value1 <= DPS_value0;

        if(RST)                     DPS_sign <= DPS_value_i[N-1];
        else if(update1)            DPS_sign <= DPS_value_i[N-1];

        if(RST || DPS_sign)         DPS_value_p <= 0;
        else 			            DPS_value_p <= DPS_value1;

        if(RST || DPS_sign)         DPS_value_n <= DPS_value1;
        else 			            DPS_value_n <= 0;
    end

    ///////////////////////////////////////////////////////////	
    reg [`PSM_FREQUENCY_WIDTH-1:0] PSM_value1, PSM_value2, PSM_value3, PSM_value4;
    
    always @(posedge CLK)
    begin
        if(RST) PSM_value1 <= 0;
        else 	PSM_value1 <= SPS_value_p;

        if(RST) PSM_value2 <= 0;
        else 	PSM_value2 <= SPS_value_p + DPS_value_p;

        if(RST) PSM_value3 <= 0;
        else    PSM_value3 <= SPS_value_n;

        if(RST) PSM_value4 <= 0;
        else    PSM_value4 <= SPS_value_n + DPS_value_n;
    end


    //----------------------------------------------------------
    // PSM: Displacement Capture
    //----------------------------------------------------------
    wire [3:0] PSMa, PSMb;
    reg [3:0] PSMa_r;
    
    PWM_capture #(.N(`PSM_FREQUENCY_WIDTH)) PWM_capture1a (.CLK(CLK), .RST(RST), .CMPA(cnt_value1), .CMPB(cnt_value2), .TBPRD({1'b0, PSM_value1[`PSM_FREQUENCY_WIDTH-1:1]+1}), .PWM_o(PSMa[0]));
    PWM_capture #(.N(`PSM_FREQUENCY_WIDTH)) PWM_capture2a (.CLK(CLK), .RST(RST), .CMPA(cnt_value1), .CMPB(cnt_value2), .TBPRD({1'b0, PSM_value2[`PSM_FREQUENCY_WIDTH-1:1]+1}), .PWM_o(PSMa[1]));
    PWM_capture #(.N(`PSM_FREQUENCY_WIDTH)) PWM_capture3a (.CLK(CLK), .RST(RST), .CMPA(cnt_value1), .CMPB(cnt_value2), .TBPRD({1'b0, PSM_value3[`PSM_FREQUENCY_WIDTH-1:1]+1}), .PWM_o(PSMa[2]));
    PWM_capture #(.N(`PSM_FREQUENCY_WIDTH)) PWM_capture4a (.CLK(CLK), .RST(RST), .CMPA(cnt_value1), .CMPB(cnt_value2), .TBPRD({1'b0, PSM_value4[`PSM_FREQUENCY_WIDTH-1:1]+1}), .PWM_o(PSMa[3]));

    always @(posedge CLK) begin
        PSMa_r <= PSMa;
    end
    
    assign PSMb[0] = (PSM_value1[0]) ? PSMa_r[0] : PSMa[0];
    assign PSMb[1] = (PSM_value2[0]) ? PSMa_r[1] : PSMa[1];
    assign PSMb[2] = (PSM_value3[0]) ? PSMa_r[2] : PSMa[2];
    assign PSMb[3] = (PSM_value4[0]) ? PSMa_r[3] : PSMa[3];

    //----------------------------------------------------------
    // Deadtime
    //----------------------------------------------------------
    reg deadtime_rst = 1'b1;
    reg [`PSM_FREQUENCY_WIDTH-1:0] shift = 0;

    always @(posedge CLK)
    begin
        shift <= upper23 + SPS_value1 + DPS_value_p/2;

        if (RST) 					    deadtime_rst <= 1'b1;
        else if(cnt_value1 == shift)    deadtime_rst <= 1'b0;
    end
     
    wire [7:0] psm_a, psm_b;
    PSM_deadtime #(.DATA(`PSM_DEADTIME)) PSM_deadtime1 [3:0] (CLK, deadtime_rst, PSMa, psm_b);
    PSM_deadtime #(.DATA(`PSM_DEADTIME)) PSM_deadtime2 [3:0] (CLK, deadtime_rst, PSMb, psm_a);  

    //----------------------------------------------------------
    // Change position signals to soft start
    //----------------------------------------------------------
    wire [1:0] PSM_ap1, PSM_ap2, PSM_as1, PSM_as2;
    wire [1:0] PSM_bp1, PSM_bp2, PSM_bs1, PSM_bs2;
    assign {PSM_as2,PSM_as1,PSM_ap2,PSM_ap1} = psm_a;
    assign {PSM_bs2,PSM_bs1,PSM_bp2,PSM_bp1} = psm_b;

    reg [7:0] PSM_8a, PSM_8b;
    always @(posedge CLK)
    begin
        if (RST) 			        PSM_8a <= 8'd0;
        else if (CPU_PSM_soft_i)	PSM_8a <= {PSM_as1,PSM_ap1,PSM_ap1,PSM_ap1};
        else  				        PSM_8a <= {{PSM_as2[0], PSM_as2[1]}, PSM_as1,{PSM_ap2[0], PSM_ap2[1]}, PSM_ap1};
    
        if (RST) 			        PSM_8b <= 8'd0;
        else if (CPU_PSM_soft_i)    PSM_8b <= {PSM_bs1,PSM_bp1,PSM_bp1,PSM_bp1};
        else  				        PSM_8b <= {{PSM_bs2[0], PSM_bs2[1]}, PSM_bs1,{PSM_bp2[0], PSM_bp2[1]}, PSM_bp1};
    end

	ODDR #(
        .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE"
        .INIT(1'b0), // Initial value of Q: 1'b0 or 1'b1
        .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC"
    ) ODDR_inst [7:0](
        .Q(oPSM), // 1-bit DDR output
        .C(CLK), // 1-bit clock input
        .CE(1'b1), // 1-bit clock enable input
        .D1(PSM_8a), // 1-bit data input (positive edge)
        .D2(PSM_8b), // 1-bit data input (negative edge)
        .R(1'd0), // 1-bit reset 
        .S(1'd0) // 1-bit set
    ); 
    
endmodule
