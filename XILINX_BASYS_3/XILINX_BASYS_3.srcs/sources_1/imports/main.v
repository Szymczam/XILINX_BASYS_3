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



    // Buttons
    wire 		rst;
    wire 		n_rst;

    // CPU


    //===================================================================                       
    //                         Clocks
    //===================================================================
    assign rst      = btnC;
    assign n_rst    = !rst;

    //===================================================================                       
    //                       Processor CPU1
    //===================================================================
    wire CPU_UART_RX, CPU_UART_TX;
    
    CPU1 CPU1_1
    (
        //GPIO
        .IO_in0_tri_i   ({20'd0, psm, btnU, btnL, btnR, btnD}),
        .IO_out0_tri_o  ({31'd0, LED[2]}),

        //SD card
        .Pmod_SD_pin10_i(Pmod_SD_pin10_i),
        .Pmod_SD_pin10_o(Pmod_SD_pin10_o),
        .Pmod_SD_pin10_t(Pmod_SD_pin10_t),
        .Pmod_SD_pin1_i(Pmod_SD_pin1_i),
        .Pmod_SD_pin1_o(Pmod_SD_pin1_o),
        .Pmod_SD_pin1_t(Pmod_SD_pin1_t),
        .Pmod_SD_pin2_i(Pmod_SD_pin2_i),
        .Pmod_SD_pin2_o(Pmod_SD_pin2_o),
        .Pmod_SD_pin2_t(Pmod_SD_pin2_t),
        .Pmod_SD_pin3_i(Pmod_SD_pin3_i),
        .Pmod_SD_pin3_o(Pmod_SD_pin3_o),
        .Pmod_SD_pin3_t(Pmod_SD_pin3_t),
        .Pmod_SD_pin4_i(Pmod_SD_pin4_i),
        .Pmod_SD_pin4_o(Pmod_SD_pin4_o),
        .Pmod_SD_pin4_t(Pmod_SD_pin4_t),
        .Pmod_SD_pin7_i(Pmod_SD_pin7_i),
        .Pmod_SD_pin7_o(Pmod_SD_pin7_o),
        .Pmod_SD_pin7_t(Pmod_SD_pin7_t),
        .Pmod_SD_pin8_i(Pmod_SD_pin8_i),
        .Pmod_SD_pin8_o(Pmod_SD_pin8_o),
        .Pmod_SD_pin8_t(Pmod_SD_pin8_t),
        .Pmod_SD_pin9_i(Pmod_SD_pin9_i),
        .Pmod_SD_pin9_o(Pmod_SD_pin9_o),
        .Pmod_SD_pin9_t(Pmod_SD_pin9_t),

        //UART
        .UART0_rxd(CPU_UART_RX),
        .UART0_txd(CPU_UART_TX),



        //CLK
        .clk_in1(CLK_IN_100MHz),
        //RESET
        .reset(rst)
    );

    //Pmod Header JC
    IOBUF Pmod_SD_pin10_iobuf
    (.I(Pmod_SD_pin10_o),
        .IO(JC[0]),
        .O(Pmod_SD_pin10_i),
        .T(Pmod_SD_pin10_t));
    IOBUF Pmod_SD_pin1_iobuf
    (.I(Pmod_SD_pin1_o),
        .IO(JC[1]),
        .O(Pmod_SD_pin1_i),
        .T(Pmod_SD_pin1_t));
    IOBUF Pmod_SD_pin2_iobuf
    (.I(Pmod_SD_pin2_o),
        .IO(JC[2]),
        .O(Pmod_SD_pin2_i),
        .T(Pmod_SD_pin2_t));
    IOBUF Pmod_SD_pin3_iobuf
    (.I(Pmod_SD_pin3_o),
        .IO(JC[3]),
        .O(Pmod_SD_pin3_i),
        .T(Pmod_SD_pin3_t));
    IOBUF Pmod_SD_pin4_iobuf
    (.I(Pmod_SD_pin4_o),
        .IO(JC[4]),
        .O(Pmod_SD_pin4_i),
        .T(Pmod_SD_pin4_t));
    IOBUF Pmod_SD_pin7_iobuf
    (.I(Pmod_SD_pin7_o),
        .IO(JC[5]),
        .O(Pmod_SD_pin7_i),
        .T(Pmod_SD_pin7_t));
    IOBUF Pmod_SD_pin8_iobuf
    (.I(Pmod_SD_pin8_o),
        .IO(JC[6]),
        .O(Pmod_SD_pin8_i),
        .T(Pmod_SD_pin8_t));
    IOBUF Pmod_SD_pin9_iobuf
    (.I(Pmod_SD_pin9_o),
        .IO(JC[7]),
        .O(Pmod_SD_pin9_i),
        .T(Pmod_SD_pin9_t));




    wire Pmod_RS485_TXD, Pmod_RS485_RXD, Pmod_RS485_DE, Pmod_RS485_nRE;
    
    
    assign JB[0] = Pmod_RS485_nRE;
    assign JB[1] = Pmod_RS485_TXD;
    assign Pmod_RS485_RXD = JB[2];
    assign JB[3] = Pmod_RS485_DE;

    assign UART_TX = Pmod_RS485_TXD;
    
    assign Pmod_RS485_DE  = SW[0];
    assign Pmod_RS485_nRE  = SW[1];
    
    assign Pmod_RS485_TXD  = CPU_UART_TX;
    assign CPU_UART_RX  = Pmod_RS485_RXD;
    
    assign LED[11]  = Pmod_RS485_nRE;
    assign LED[12]  = Pmod_RS485_DE;
    assign LED[13]  = !Pmod_RS485_RXD;
    assign LED[14]  = !Pmod_RS485_TXD;
    
    
    
    assign LED[15]  = btnC;



endmodule
