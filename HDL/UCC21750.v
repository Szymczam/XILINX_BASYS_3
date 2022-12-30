module UCC21750 (
	input			CLK_psm,
	input			CLK_temp,
	input			iRST,
	input			iRST_psm,
	input			iAPWM,
	input		    iIN,
	output	[14:0]	oPulse_up_cnt,
	output	[14:0]	oPulse_down_cnt,
	output	[1:0]   oOUT
);


    localparam DEADTIME_BITS_DATA = 8;
    // deadtime 
    reg [DEADTIME_BITS_DATA-1:0]DEADTIME_VALUE = 8'd20;
    wire [1:0] psm_out;	
	PSM_deadtime2 #(.BITS_DATA(DEADTIME_BITS_DATA))	psm    (CLK_psm, iRST_psm, DEADTIME_VALUE, iIN, psm_out);
	
	FDCE #(.INIT(1'b0)) FDCE_inst3 (.Q(oOUT[0]), .C(CLK_psm), .CE(1'b1), .CLR(iRST_psm), .D(psm_out[0]));
    FDCE #(.INIT(1'b0)) FDCE_inst4 (.Q(oOUT[1]), .C(CLK_psm), .CE(1'b1), .CLR(iRST_psm), .D(psm_out[1]));


    // termistor 
    reg [14:0] 	cnt10 = 1;
    reg [14:0] 	save1 = 0;
    reg [14:0] 	save2 = 0;
    reg [14:0] 	cnt20 = 1;
	reg [2:0]   s = 0;
	wire [1:0]  set; 
	
	always @(posedge CLK_temp) 
	begin
	   s[0] <= iAPWM;
	   s[1] <= s[0];
	   s[2] <= !s[0];
	end
	
	always @(posedge CLK_temp) 
    begin
		if (iRST)                cnt10 <= 1'b1; 
		else if(s[1] == 1'b1) 	 cnt10 <= cnt10 + 1; 
		else 				     cnt10 <= 1'b1;
		
	    if (iRST)                save1 <= 1'b0; 
		else if(set[0]) 	     save1 <= cnt10;	
    end	
    
    FDCE #(.INIT(1'b0)) FDCE_inst0 (.Q(set[0]), .C(CLK_temp), .CE(1'b1), .CLR(s[2]), .D(iAPWM == 1'b0));
    
    always @(posedge CLK_temp) 
    begin
		if (iRST)                cnt20 <= 1'b1; 
		else if(s[1] == 1'b0) 	 cnt20 <= cnt20 + 1; 
		else 				     cnt20 <= 1'b1;
		
	    if (iRST)                save2 <= 1'b0; 
		else if(set[1]) 	     save2 <= cnt20;
    end	
    
    FDCE #(.INIT(1'b0)) FDCE_inst1 (.Q(set[1]), .C(CLK_temp), .CE(1'b1), .CLR(s[1]), .D(iAPWM == 1'b1));
    
	assign oPulse_up_cnt 		= save1;
	assign oPulse_down_cnt 		= save2;

endmodule
