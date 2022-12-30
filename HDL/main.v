
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
    inout   [7:0]   JB
);

    //===================================================================                       
    //                         Clocks
    //===================================================================
    wire clk_100MHz, clk_200MHz;
    wire clk_locked;

    clock_manager clock_manager_inst(
        .iclk_100MHz     (CLK_IN_100MHz),
        .irst            (0),
        .oclk_locked_o   (clk_locked),
        .oclk_200MHz     (clk_200MHz),
        .oclk_100MHz     (clk_100MHz)
    );

    //===================================================================                       
    //                         GPIO & Reset 
    //===================================================================
    // Buttons
    wire [4:0]	btn;
    debounce #(.WIDTH(5)) debounce_inst(
        .clk        (clk_100MHz),
        .data_in    ({btnD, btnR, btnL, btnU, btnC}),
        .data_out   (btn)
    );

    //LEDs
    assign LED[0]   = 0;
    assign LED[1]   = 0;
    assign LED[15]  = btn[0];

    // Reset
    wire rst, n_rst;
    assign rst      = btn[0];
    assign n_rst    = !rst;

    //===================================================================                       
    //                         PSM
    //===================================================================
//    reg 			cnt_sign1 = 0;
//    reg 			cnt_sign2 = 0;
//    reg	[16-1:0]	cnt_value1 = 0;
//    reg	[16-1:0]	cnt_value2 = 0;
//    reg	[16-1:0]	SPS_value = 0;
//    wire	[7:0]	psm_8b;


//    PSM_controller1 PSM_controller_0(
//        .CLK            (clk_200MHz),
//        .RST            (rst),
//        .iSPS_value     ({1'b0, SPS_value[14:0]}),
//        .iSPS_sign      (SPS_value[15]),
//        .iDPS_value     (0),
//        .iDPS_sign      (0),
//        .iFREQUENCY     (4000),
//        .iDEADTIME      (20),
//        .iN             (0),
//        .iSych1         (cnt_sign1),
//        .iSych2         (cnt_sign2),
//        .oPSM           (psm_8b)
//    );


    //===================================================================                       
    //                         UCC21750
    //===================================================================
    //    wire [14:0] oDuty1;
    //    wire [14:0] oDuty2;
    //    wire [1:0] psm;

    //    UCC21750 UCC21750_3(
    //        .CLK_temp   (clk_100MHz),
    //        .CLK_psm    (clk_200MHz),
    //        .iRST       (rst),
    //        .iRST_psm   (btnD),
    //        .iAPWM      (btnC),
    //        .iIN        (btnU),
    //        .oDuty1     (oDuty1),
    //        .oDuty2     (oDuty2),
    //        .oOUT       (psm)

    //    ); 


    //===================================================================                       
    //                         ADC
    //===================================================================

//    wire [11:0] odata_ch_A;
//    wire [11:0] odata_ch_B;
    
//    ADS7254   ADS7254_prim(
//        .iCLK_32        (clk_100MHz),
//        .iCLK_100       (clk_200MHz),
//        .iRST           (rst), 
//        .iSYNC          (1),
//        .iSDOA          (btnD),
//        .iSDOB          (btnR),
//        .oSDI           (AN[0]),
//        .oCS_n          (AN[1]),
//        .oCLK           (AN[2]),
//        .odata_ch_A     (odata_ch_A),
//        .odata_ch_B     (odata_ch_B)
//    );



    //===================================================================                       
    //                         Symulator
    //===================================================================
//    ila_0 ila_0_inst(
//        .clk        (clk_100MHz),

//        .probe0     ({8'd0, psm_8b}), //16bit
//        .probe1     ({8'd0, 0}), //16bit
//        .probe2     ({4'd0, odata_ch_B}), //16bit
//        .probe3     ({16'd0}) //16bit
//    );

    //===================================================================                       
    //                       Processor CPU1
    //===================================================================
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

     CPU1 CPU1_1
           (//IIC
            .IIC0_scl_i(IIC0_scl_i),
            .IIC0_scl_o(IIC0_scl_o),
            .IIC0_scl_t(IIC0_scl_t),
            .IIC0_sda_i(IIC0_sda_i),
            .IIC0_sda_o(IIC0_sda_o),
            .IIC0_sda_t(IIC0_sda_t),

            //GPIO
            .IO_in0_tri_i   ({27'd0, btn}),
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
            .clk_in(clk_100MHz),
            .dcm_locked(clk_locked),
            //RESET
            .reset(rst)
      );

    //I2C
    IOBUF IIC0_scl_iobuf (.I(IIC0_scl_o), .IO(JA[0]), .O(IIC0_scl_i), .T(IIC0_scl_t));
    IOBUF IIC0_sda_iobuf (.I(IIC0_sda_o), .IO(JA[1]), .O(IIC0_sda_i), .T(IIC0_sda_t));
    //SPI      
    IOBUF SPI0_io0_iobuf (.I(SPI0_io0_o), .IO(JB[0]), .O(SPI0_io0_i), .T(SPI0_io0_t));
    IOBUF SPI0_io1_iobuf (.I(SPI0_io1_o), .IO(JB[1]), .O(SPI0_io1_i), .T(SPI0_io1_t));
    IOBUF SPI0_sck_iobuf (.I(SPI0_sck_o), .IO(JB[2]), .O(SPI0_sck_i), .T(SPI0_sck_t));
    IOBUF SPI0_ss_iobuf  (.I(SPI0_ss_o_0), .IO(JB[3]), .O(SPI0_ss_i_0), .T(SPI0_ss_t));




endmodule
