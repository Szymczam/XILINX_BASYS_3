//------------------------------------------------------
// GPIO on TE0725
//------------------------------------------------------
`define IO_INPUT            1'b1
`define IO_OUTPUT           1'b0

`define IO_LED_GREEN   LED_D2
`define IO_POF_RD_P    0
`define IO_POF_RD_N    1
`define IO_POF_TD_P    0
`define IO_POF_TD_N    1

//------------------------------------------------------
// GD_DAB_v3
//------------------------------------------------------
//------------------------------------------------------
// GPIO J1 on board (as J9B)
//------------------------------------------------------
`define IO_PG_PWR_SEC       IO_J1[3]
`define IO_SEC_T2           IO_J1[7]
`define IO_SEC_PWM2_L       IO_J1[9]
`define IO_SEC_PWM2_H       IO_J1[11]
`define IO_SEC_RDY          IO_J1[13]
`define IO_SEC_FLT          IO_J1[15]
`define IO_SEC_PWM1_L       IO_J1[17]
`define IO_SEC_PWM1_H       IO_J1[19]
`define IO_SEC_T1           IO_J1[21]
`define IO_PRIM_PWM2_L      IO_J1[23]
`define IO_PRIM_PWM2_H      IO_J1[25]
`define IO_PRIM_T2          IO_J1[27]
`define IO_EN_GD            IO_J1[29]
`define IO_RST_FLT          IO_J1[31] 
`define IO_EN_GD_SIG        IO_J1[33]
`define IO_PRIM_PWM1_L      IO_J1[35]
`define IO_PRIM_PWM1_H      IO_J1[37]
`define IO_PRIM_T1          IO_J1[39]
`define IO_PRIM_RDY         IO_J1[41]
`define IO_PRIM_FLT         IO_J1[43]
`define IO_DOUT_AC          IO_J1[47]

`define IO_EN_PWR_SEC       IO_J1[4]
`define IO_FLT_INTERFACE_PWR IO_J1[8]
`define IO_PG_INTERFACE_PWR IO_J1[10]
`define IO_EN_INTERFACE_PWR IO_J1[12]
`define IO_UART1_RX         IO_J1[14]
`define IO_UART2_RX         IO_J1[16]
`define IO_UART1_TX         IO_J1[18]
`define IO_UART2_TX         IO_J1[20]
`define IO_EN_PWR_PRIM      IO_J1[24]
`define IO_PG_PWR_PRIM      IO_J1[26]
`define IO_SWITCH_S0        IO_J1[28]
`define IO_SWITCH_S1        IO_J1[30]
`define IO_SWITCH_S2        IO_J1[32]
`define IO_SWITCH_S3        IO_J1[34]
`define IO_ADC_PRIM_SDOB    IO_J1[36]
`define IO_ADC_PRIM_SDOA    IO_J1[38]
`define IO_ADC_PRIM_SCLK    IO_J1[40]
`define IO_ADC_PRIM_CS      IO_J1[42]
`define IO_ADC_PRIM_SDI     IO_J1[44]
`define IO_CLKIN_AC         IO_J1[48]

`define IO_SYNC             IO_J1[22]

//------------------------------------------------------
// GPIO J2 on board (as J9A)
//------------------------------------------------------
`define IO_BUZZER           IO_J2[3]
`define IO_OUT5             IO_J2[7]//PULLDOWN true
`define IO_OUT6             IO_J2[9]//PULLDOWN true
`define IO_OUT7             IO_J2[11]//PULLDOWN true
`define IO_OUT8             IO_J2[13]//PULLDOWN true
`define IO_ADC_NTC_CS       IO_J2[15]//PULLDOWN true
`define IO_ADC_NTC_SCLK     IO_J2[17]//PULLDOWN true
`define IO_ADC_NTC_SDI      IO_J2[19]//PULLDOWN true
`define IO_ADC_NTC_SDO      IO_J2[21]//PULLDOWN true
`define IO_LED1             IO_J2[27]
`define IO_LED2             IO_J2[29]
`define IO_TX_2             IO_J2[31]//PULLUP true
`define IO_TX_EN_2          IO_J2[33]
`define IO_RX_EN_2          IO_J2[35]
`define IO_RX_2             IO_J2[37]//PULLUP true
`define IO_OUT4             IO_J2[39]
`define IO_OUT3             IO_J2[41]
`define IO_DISCH_SEC        IO_J2[43]
`define IO_OPTICAL_TX1      IO_J2[47]//PULLUP true

`define IO_DISCH_PRIM       IO_J2[8]
`define IO_OUT2             IO_J2[10]//PULLDOWN true
`define IO_OUT1             IO_J2[12]//PULLDOWN true
`define IO_PG_12V           IO_J2[14]
`define IO_EN_12V           IO_J2[16]
`define IO_PG_AVDD          IO_J2[18]
`define IO_EN_AVDD          IO_J2[20]
`define IO_ADC_SEC_SDOB     IO_J2[30]
`define IO_ADC_SEC_SDOA     IO_J2[32]
`define IO_ADC_SEC_SCLK     IO_J2[34]
`define IO_ADC_SEC_CS       IO_J2[36]
`define IO_ADC_SEC_SDI      IO_J2[38]
`define IO_OPTICAL_RX2      IO_J2[40]//PULLUP true
`define IO_OPTICAL_TX2      IO_J2[42]//PULLUP true
`define IO_OPTICAL_RX1      IO_J2[44]//PULLUP true
`define IO_NRST             IO_J2[48]




`define PSM_FREQUENCY       14'd2500    // Period clk
`define PSM_FREQUENCY_WIDTH 14//$clog2(`PSM_FREQUENCY)
`define PSM_DEADTIME        20-1









