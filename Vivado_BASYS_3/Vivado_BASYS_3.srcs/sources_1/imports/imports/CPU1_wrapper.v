//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
//Date        : Sun Mar 26 23:06:50 2023
//Host        : PCMAREK running 64-bit major release  (build 9200)
//Command     : generate_target CPU1_wrapper.bd
//Design      : CPU1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module CPU1_wrapper
   (IIC0_scl_io,
    IIC0_sda_io,
    IO_in0_tri_i,
    IO_out0_tri_o,
    Pmod_SD_pin10_io,
    Pmod_SD_pin1_io,
    Pmod_SD_pin2_io,
    Pmod_SD_pin3_io,
    Pmod_SD_pin4_io,
    Pmod_SD_pin7_io,
    Pmod_SD_pin8_io,
    Pmod_SD_pin9_io,
    SPI0_io0_io,
    SPI0_io1_io,
    SPI0_sck_io,
    SPI0_ss_io,
    UART0_rxd,
    UART0_txd,
    clk_in1,
    reset);
  inout IIC0_scl_io;
  inout IIC0_sda_io;
  input [31:0]IO_in0_tri_i;
  output [31:0]IO_out0_tri_o;
  inout Pmod_SD_pin10_io;
  inout Pmod_SD_pin1_io;
  inout Pmod_SD_pin2_io;
  inout Pmod_SD_pin3_io;
  inout Pmod_SD_pin4_io;
  inout Pmod_SD_pin7_io;
  inout Pmod_SD_pin8_io;
  inout Pmod_SD_pin9_io;
  inout SPI0_io0_io;
  inout SPI0_io1_io;
  inout SPI0_sck_io;
  inout [0:0]SPI0_ss_io;
  input UART0_rxd;
  output UART0_txd;
  input clk_in1;
  input reset;

  wire IIC0_scl_i;
  wire IIC0_scl_io;
  wire IIC0_scl_o;
  wire IIC0_scl_t;
  wire IIC0_sda_i;
  wire IIC0_sda_io;
  wire IIC0_sda_o;
  wire IIC0_sda_t;
  wire [31:0]IO_in0_tri_i;
  wire [31:0]IO_out0_tri_o;
  wire Pmod_SD_pin10_i;
  wire Pmod_SD_pin10_io;
  wire Pmod_SD_pin10_o;
  wire Pmod_SD_pin10_t;
  wire Pmod_SD_pin1_i;
  wire Pmod_SD_pin1_io;
  wire Pmod_SD_pin1_o;
  wire Pmod_SD_pin1_t;
  wire Pmod_SD_pin2_i;
  wire Pmod_SD_pin2_io;
  wire Pmod_SD_pin2_o;
  wire Pmod_SD_pin2_t;
  wire Pmod_SD_pin3_i;
  wire Pmod_SD_pin3_io;
  wire Pmod_SD_pin3_o;
  wire Pmod_SD_pin3_t;
  wire Pmod_SD_pin4_i;
  wire Pmod_SD_pin4_io;
  wire Pmod_SD_pin4_o;
  wire Pmod_SD_pin4_t;
  wire Pmod_SD_pin7_i;
  wire Pmod_SD_pin7_io;
  wire Pmod_SD_pin7_o;
  wire Pmod_SD_pin7_t;
  wire Pmod_SD_pin8_i;
  wire Pmod_SD_pin8_io;
  wire Pmod_SD_pin8_o;
  wire Pmod_SD_pin8_t;
  wire Pmod_SD_pin9_i;
  wire Pmod_SD_pin9_io;
  wire Pmod_SD_pin9_o;
  wire Pmod_SD_pin9_t;
  wire SPI0_io0_i;
  wire SPI0_io0_io;
  wire SPI0_io0_o;
  wire SPI0_io0_t;
  wire SPI0_io1_i;
  wire SPI0_io1_io;
  wire SPI0_io1_o;
  wire SPI0_io1_t;
  wire SPI0_sck_i;
  wire SPI0_sck_io;
  wire SPI0_sck_o;
  wire SPI0_sck_t;
  wire [0:0]SPI0_ss_i_0;
  wire [0:0]SPI0_ss_io_0;
  wire [0:0]SPI0_ss_o_0;
  wire SPI0_ss_t;
  wire UART0_rxd;
  wire UART0_txd;
  wire clk_in1;
  wire reset;

  CPU1 CPU1_i
       (.IIC0_scl_i(IIC0_scl_i),
        .IIC0_scl_o(IIC0_scl_o),
        .IIC0_scl_t(IIC0_scl_t),
        .IIC0_sda_i(IIC0_sda_i),
        .IIC0_sda_o(IIC0_sda_o),
        .IIC0_sda_t(IIC0_sda_t),
        .IO_in0_tri_i(IO_in0_tri_i),
        .IO_out0_tri_o(IO_out0_tri_o),
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
        .UART0_rxd(UART0_rxd),
        .UART0_txd(UART0_txd),
        .clk_in1(clk_in1),
        .reset(reset));
  IOBUF IIC0_scl_iobuf
       (.I(IIC0_scl_o),
        .IO(IIC0_scl_io),
        .O(IIC0_scl_i),
        .T(IIC0_scl_t));
  IOBUF IIC0_sda_iobuf
       (.I(IIC0_sda_o),
        .IO(IIC0_sda_io),
        .O(IIC0_sda_i),
        .T(IIC0_sda_t));
  IOBUF Pmod_SD_pin10_iobuf
       (.I(Pmod_SD_pin10_o),
        .IO(Pmod_SD_pin10_io),
        .O(Pmod_SD_pin10_i),
        .T(Pmod_SD_pin10_t));
  IOBUF Pmod_SD_pin1_iobuf
       (.I(Pmod_SD_pin1_o),
        .IO(Pmod_SD_pin1_io),
        .O(Pmod_SD_pin1_i),
        .T(Pmod_SD_pin1_t));
  IOBUF Pmod_SD_pin2_iobuf
       (.I(Pmod_SD_pin2_o),
        .IO(Pmod_SD_pin2_io),
        .O(Pmod_SD_pin2_i),
        .T(Pmod_SD_pin2_t));
  IOBUF Pmod_SD_pin3_iobuf
       (.I(Pmod_SD_pin3_o),
        .IO(Pmod_SD_pin3_io),
        .O(Pmod_SD_pin3_i),
        .T(Pmod_SD_pin3_t));
  IOBUF Pmod_SD_pin4_iobuf
       (.I(Pmod_SD_pin4_o),
        .IO(Pmod_SD_pin4_io),
        .O(Pmod_SD_pin4_i),
        .T(Pmod_SD_pin4_t));
  IOBUF Pmod_SD_pin7_iobuf
       (.I(Pmod_SD_pin7_o),
        .IO(Pmod_SD_pin7_io),
        .O(Pmod_SD_pin7_i),
        .T(Pmod_SD_pin7_t));
  IOBUF Pmod_SD_pin8_iobuf
       (.I(Pmod_SD_pin8_o),
        .IO(Pmod_SD_pin8_io),
        .O(Pmod_SD_pin8_i),
        .T(Pmod_SD_pin8_t));
  IOBUF Pmod_SD_pin9_iobuf
       (.I(Pmod_SD_pin9_o),
        .IO(Pmod_SD_pin9_io),
        .O(Pmod_SD_pin9_i),
        .T(Pmod_SD_pin9_t));
  IOBUF SPI0_io0_iobuf
       (.I(SPI0_io0_o),
        .IO(SPI0_io0_io),
        .O(SPI0_io0_i),
        .T(SPI0_io0_t));
  IOBUF SPI0_io1_iobuf
       (.I(SPI0_io1_o),
        .IO(SPI0_io1_io),
        .O(SPI0_io1_i),
        .T(SPI0_io1_t));
  IOBUF SPI0_sck_iobuf
       (.I(SPI0_sck_o),
        .IO(SPI0_sck_io),
        .O(SPI0_sck_i),
        .T(SPI0_sck_t));
  IOBUF SPI0_ss_iobuf_0
       (.I(SPI0_ss_o_0),
        .IO(SPI0_ss_io[0]),
        .O(SPI0_ss_i_0),
        .T(SPI0_ss_t));
endmodule
