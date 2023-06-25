`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Marek Szymczak
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
`include "global.v" 
`include "board_GD_DAB_v3.v" 


module main(
    //////////// CLOCK //////////
    input           CLK_IN_100MHz,

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
    inout   [7:0]   JB,
    inout   [7:0]   JC
);


    //===================================================================                       
    //                         Clock manager
    //===================================================================
    wire clk_out_250MHz, clk_out_125MHz, clk_out_100MHz;
    wire clk_lock;

    clk_wiz_0 clk_wiz_0_inst(
      // Clock out ports  
      .clk_out_100MHz(clk_out_100MHz),
      .clk_out_125MHz(clk_out_125MHz),
      .clk_out_250MHz(clk_out_250MHz),
      // Status and control signals               
      .locked(clk_lock),
     // Clock in ports
      .clk_in1(CLK_IN_100MHz)
    );


    //===================================================================                       
    //                         Buttons
    //===================================================================
    `define Btn_Down    0
    `define Btn_Right   1
    `define Btn_Left    2
    `define Btn_Up      3
    `define Btn_Central 4 
    `define STATE_0   1'b0
    `define STATE_1   1'b1
    
    wire [15:0] GPIO_switch_16b;
    wire [4:0]  GPIO_button_5b;
    wire rst, n_rst;
    
    debounce2 #(.WIDTH(16), .STATE_ACTIVE(`STATE_1), .STATE_OUT(`STATE_1))	
        btn0 (clk_out_125MHz, SW, GPIO_switch_16b);
    debounce2 #(.WIDTH(5), .STATE_ACTIVE(`STATE_0), .STATE_OUT(`STATE_0))	
        btn1 (clk_out_125MHz, {btnC, btnU, btnL, btnR, btnD}, GPIO_button_5b);
    
    assign rst      = GPIO_button_5b[`Btn_Central];
    assign n_rst    = !rst;

    //===================================================================                       
    //                       Processor CPU1
    //===================================================================
    wire [31:0] CPU_IO_in0_32b, CPU_IO_out0_32b;
    wire CPU_UART_RX, CPU_UART_TX;
   
    wire [13:0] CPU_PSM_SPS_14b, CPU_PSM_DPS_14b;
    wire CPU_Led;
    
    
    // CPU gpio
    assign CPU_PSM_SPS_14b  = CPU_IO_out0_32b[13:0];
    assign CPU_PSM_DPS_14b  = CPU_IO_out0_32b[27:14];
    assign CPU_Led          = CPU_IO_out0_32b[28];
    assign CPU_IO_in0_32b   = {28'd0, GPIO_button_5b[3:0]};

    
`ifndef SIMULATION 
    CPU1_wrapper CPU1_12(
        //CLK
        .clk_in1        (clk_out_100MHz),
        //GPIO
        .IO_in0_tri_i   (CPU_IO_in0_32b),
        .IO_out0_tri_o  (CPU_IO_out0_32b),   
        //UART
        .UART0_rxd      (CPU_UART_RX),
        .UART0_txd      (CPU_UART_TX),
        //SD card
        .Pmod_sd0_pin1_io    (JA[0]),
        .Pmod_sd0_pin2_io    (JA[1]),
        .Pmod_sd0_pin3_io    (JA[2]),
        .Pmod_sd0_pin4_io    (JA[3]),
        .Pmod_sd0_pin7_io    (JA[4]),
        .Pmod_sd0_pin8_io    (JA[5]),
        .Pmod_sd0_pin9_io    (JA[6]),
        .Pmod_sd0_pin10_io   (JA[7]), 
        //SPI
        .SPI0_io0_io (JC[0]),
        .SPI0_io1_io (JC[1]),
        .SPI0_sck_io (JC[2]),
        .SPI0_ss_io  (JC[3]),  
        //I2C
        .IIC0_scl_io (JC[4]),
        .IIC0_sda_io (JC[5]), 
        //RESET
        .reset  (GPIO_switch_16b[15])
    );
`endif 
 

    //wire Pmod_RS485_TXD, Pmod_RS485_RXD, Pmod_RS485_DE, Pmod_RS485_nRE;
    
  //  assign JB[0] = Pmod_RS485_nRE;
  //  assign JB[1] = Pmod_RS485_TXD;
 //   assign Pmod_RS485_RXD = JB[2];
  //  assign JB[3] = Pmod_RS485_DE;
  
   // CPU UART
    //assign Pmod_RS485_TXD  = CPU_UART_TX;
    //assign CPU_UART_RX  = Pmod_RS485_RXD;
    
    //assign Pmod_RS485_DE  = SW[0];
    //assign Pmod_RS485_nRE  = SW[1];
    
  
//===================================================================                       
//                 Local Counter
//===================================================================
	wire[63:0] snapshot_value;
	wire[15:0] local_counter_16b; 
	wire[15:0] current_period;
	wire sync_phase;
	Local_counter Local_counter(.clk_i(clk_out_125MHz), .next_period_i(`CYCLE_PERIOD - 16'd1), 
        .current_period_o(current_period), 
        .local_counter_o(local_counter_16b), .sync_phase_o(sync_phase), 
        .snapshot_start_i({timestamp_code_rx2, timestamp_code_tx2, timestamp_code_rx1, timestamp_code_tx1}), 
        .snapshot_value_o(snapshot_value)); 
    
//===================================================================                       
//                         PSM Controller
//===================================================================
//    wire [7:0] PSM_8b;
//    wire [13:0]PSM_SPS_14b, PSM_DPS_14b;


//    xpm_cdc_array_single #(
//       .DEST_SYNC_FF(3),   // DECIMAL; range: 2-10
//       .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
//       .SIM_ASSERT_CHK(1), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
//       .SRC_INPUT_REG(1),  // DECIMAL; 0=do not register input, 1=register input
//       .WIDTH(14)          // DECIMAL; range: 1-1024
//    )
//    xpm_cdc_array_single_sync [1:0] (
//       .dest_out({PSM_DPS_14b, PSM_SPS_14b}), // WIDTH-bit output: src_in synchronized to the destination clock domain.
//       .dest_clk(clk_out_250MHz), // 1-bit input: Clock signal for the destination clock domain.
//       .src_clk(clk_out_100MHz),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
//       .src_in({CPU_PSM_DPS_14b, CPU_PSM_SPS_14b}) // WIDTH-bit input: Input single-bit array to be synchronized to destination clock domain.
//    );

//    PSM_modulator #(.N(`PSM_FREQUENCY_WIDTH)) psm1(
//        .CLK            (clk_out_125MHz),
//        .RST            (rst),
//        .SPS_value_i    (PSM_SPS_14b[`PSM_FREQUENCY_WIDTH-1:0]),
//        .DPS_value_i    (PSM_DPS_14b[`PSM_FREQUENCY_WIDTH-1:0]),
//        .CPU_PSM_soft_i (GPIO_button_5b[`Btn_Down]),
//        .local_counter_i(local_counter_16b),
//        .oPSM           (PSM_8b)
//    );
    
//    assign JB = PSM_8b;


//===================================================================                       
//                 UARTs
//===================================================================
    assign UART_TX     = CPU_UART_TX;
    assign CPU_UART_RX = UART_RX;
    
    PULLUP PULLUP_UART_TX (.O(UART_TX));
    PULLUP PULLUP_UART_RX (.O(UART_RX));

//===================================================================                       
//                 Leds
//===================================================================
    assign LED[0]   = CPU_Led;
    //assign LED[11]  = Pmod_RS485_nRE;
    //assign LED[12]  = Pmod_RS485_DE;
    //assign LED[13]  = !Pmod_RS485_RXD;
    //assign LED[14]  = !Pmod_RS485_TXD; 


//===================================================================                       
//                 Seven Segment module
//===================================================================
    wire [15:0] seg7_16b;       // input to seg7 to define segment pattern
    wire [19:0] seg7_bcdout_20b;// bcdout is sent to Scroll_Display Module
    
    assign seg7_16b = GPIO_switch_16b;
    
    // conver bin to decimal
    bin_to_decimal u1 (.B(seg7_16b), .bcdout(seg7_bcdout_20b));
    
    // 7segment display module
    seg7decimal u2 (.x(seg7_bcdout_20b[15:0]), .clk(clk_out_100MHz), .clr(btnC), .a_to_g(SEG), .an(AN),. dp(DP));
    
endmodule
