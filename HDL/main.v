`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.02.2022 19:55:44
// Design Name: 
// Module Name: main
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module main(
    //////////// CLOCK //////////
    input           CLK_100MHz,
    
    //////////// SWITCHES //////////
    input   [15:0]  SW,
    
    //////////// BUTTONS //////////  
    input           btnC,
    input           btnU,
    input           btnL,
    input           btnR,
    input           btnD,
    
    //////////// LEDS //////////
    output  [15:0]  LED,
    
    //////////// UART //////////
    input           UART_RX,
    output          UART_TX,   
    
    //////////// 7-seg Display //////////
    output  [6:0]   SEG,
    output  [3:0]   AN,
    output          DP, 

    //////////// GPIO //////////
    inout   [7:0]   JA,
    inout   [7:0]   JB
);

	//	Clocks
	wire 	    clk_10MHz;	
	wire        clk_10Hz;
	wire        clk_1Hz;
	
	// Buttons
	wire 		rst;
	wire 		n_rst;

    // CPU
    wire        IIC0_scl_i;
    wire        IIC0_scl_io;
    wire        IIC0_scl_o;
    wire        IIC0_scl_t;
    wire        IIC0_sda_i;
    wire        IIC0_sda_io;
    wire        IIC0_sda_o;
    wire        IIC0_sda_t;
  
    wire        SPI0_io0_i;
    wire        SPI0_io0_io;
    wire        SPI0_io0_o;
    wire        SPI0_io0_t;
    wire        SPI0_io1_i;
    wire        SPI0_io1_io;
    wire        SPI0_io1_o;
    wire        SPI0_io1_t;
    wire        SPI0_sck_i;
    wire        SPI0_sck_io;
    wire        SPI0_sck_o;
    wire        SPI0_sck_t;
    wire [0:0]  SPI0_ss_i_0;
    wire [0:0]  SPI0_ss_io_0;
    wire [0:0]  SPI0_ss_o_0;
    wire        SPI0_ss_t;

//===================================================================                       
//                         Clocks
//===================================================================
	clk_div    clk_div_0	(CLK_100MHz, 0, clk_1Hz);
			   defparam 	clk_div_0.div_by	= 100_000_000;
 

//===================================================================                       
//                       Processor CPU1
//===================================================================
 CPU1 CPU1_1
       (//IIC
        .IIC0_scl_i(IIC0_scl_i),
        .IIC0_scl_o(IIC0_scl_o),
        .IIC0_scl_t(IIC0_scl_t),
        .IIC0_sda_i(IIC0_sda_i),
        .IIC0_sda_o(IIC0_sda_o),
        .IIC0_sda_t(IIC0_sda_t),
        
        //GPIO
        .IO_in0_tri_i   ({20'd0, psm, btnU, btnL, btnR, btnD}),
        .IO_out0_tri_o  ({31'd0, LED[2]}),

        //SPI
        .SPI0_io0_i(SPI0_io0_i),
        .SPI0_io0_o(SPI0_io0_o),
        .SPI0_io0_t(SPI0_io0_t),
        .SPI0_io1_i(SPI0_io1_i),
        .SPI0_io1_o(SPI0_io1_o),
        .SPI0_io1_t(SPI0_io1_t),
        .SPI0_sck_i(SPI0_sck_i),
        .SPI0_sck_o(SPI0_sck_o),
        .SPI0_sck_t(SPI0_sck_t),
        .SPI0_ss_i(SPI0_ss_i_0),
        .SPI0_ss_o(SPI0_ss_o_0),
        .SPI0_ss_t(SPI0_ss_t),
               
        //UART
        .UART0_rxd(UART_RX),
        .UART0_txd(UART_TX),
        //CLK
        .clk_in1(CLK_100MHz),
        //RESET
        .reset(rst)
  );
  
  //I2C
  IOBUF IIC0_scl_iobuf
       (.I(IIC0_scl_o),
        .IO(JA[0]),
        .O(IIC0_scl_i),
        .T(IIC0_scl_t));
  IOBUF IIC0_sda_iobuf
       (.I(IIC0_sda_o),
        .IO(JA[1]),
        .O(IIC0_sda_i),
        .T(IIC0_sda_t));
  //SPI      
  IOBUF SPI0_io0_iobuf
       (.I(SPI0_io0_o),
        .IO(JB[0]),
        .O(SPI0_io0_i),
        .T(SPI0_io0_t));
  IOBUF SPI0_io1_iobuf
       (.I(SPI0_io1_o),
        .IO(JB[1]),
        .O(SPI0_io1_i),
        .T(SPI0_io1_t));
  IOBUF SPI0_sck_iobuf
       (.I(SPI0_sck_o),
        .IO(JB[2]),
        .O(SPI0_sck_i),
        .T(SPI0_sck_t));
  IOBUF SPI0_ss_iobuf_0
       (.I(SPI0_ss_o_0),
        .IO(JB[3]),
        .O(SPI0_ss_i_0),
        .T(SPI0_ss_t));

assign rst      = btnC;
assign n_rst    = !rst;

assign LED[0]   = clk_1Hz;
assign LED[1]   = clk_10Hz;
assign LED[15]  = btnC;
assign JA[2]    = UART_TX;



	reg 			cnt_sign1 = 0;
	reg 			cnt_sign2 = 0;
	reg	[16-1:0]	cnt_value1 = 0;
	reg	[16-1:0]	cnt_value2 = 0;
	reg	[16-1:0]	SPS_value = 0;
	wire	[7:0]	psm;
	
/*
PSM_controller1 PSM_controller_0(
    .CLK            (CLK_100MHz),
    .RST            (0),
    .iSPS_value     ({1'b0, SPS_value[14:0]}),
    .iSPS_sign      (SPS_value[15]),
    .iDPS_value     (0),
    .iDPS_sign      (0),
    .iFREQUENCY     (400),
    .iDEADTIME      (2),
    .iN             (0),
    .iSych1         (cnt_sign1),
    .iSych2         (cnt_sign2),
    .oPSM           (psm)
    ); 
*/
    // Main counter
	always @(posedge CLK_100MHz)
	begin
	
		if (rst) 						cnt_sign1 = 1'b0;
		else if (cnt_value1 == 4000)	cnt_sign1 = 1'b1;
		else  							cnt_sign1 = 1'b0;
	
		if (rst) 						cnt_value1 <= 0;
		else if (cnt_sign1 == 1'b1)		cnt_value1 <= 0;
		else  							cnt_value1 <= cnt_value1 + 1;
	

		if (rst) 						cnt_sign2 = 1'b0;
		else if (cnt_value2 ==  4000)	cnt_sign2 = 1'b1;
		else  							cnt_sign2 = 1'b0;
		
		if (rst) 						cnt_value2 <= 2000;
		else if (cnt_sign2 == 1'b1)		cnt_value2 <= 0;
		else  							cnt_value2 <= cnt_value2 + 1;
		
	end	


endmodule
