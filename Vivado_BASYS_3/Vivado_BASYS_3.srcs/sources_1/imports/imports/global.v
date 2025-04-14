
//Comm defines
`define K_28_0 9'h11C
`define K_28_1 9'h13C //comma
`define K_28_2 9'h15C
`define K_28_3 9'h17C
`define K_28_4 9'h19C
`define K_28_5 9'h1BC //comma
`define K_28_6 9'h1DC
`define K_28_7 9'h1FC //comma, not allowed
`define K_23_7 9'h1F7
`define K_27_7 9'h1FB //507
`define K_29_7 9'h1FD
`define K_30_7 9'h1FE

`define K_Enum_nodes `K_28_0
`define K_Timestamp_master `K_28_2
`define K_Timestamp_slave `K_28_3
`define K_Start_Hipri_Packet `K_27_7
`define K_End_Hipri_Packet `K_29_7
`define K_Start_Lopri_Packet `K_23_7
`define K_End_Lopri_Packet `K_30_7

`define K_Idle `K_28_5
`define K_Error 9'h1EE

`define SAMPLING_TIME 16e-6
`define FREQUENCY 16'd50000
`define KALMAN_GAIN 0.005

`define HIPRI_MAILBOXES_NUMBER 8
`define HIPRI_MAILBOXES_WIDTH $clog2(`HIPRI_MAILBOXES_NUMBER)
`define LOPRI_MAILBOXES_NUMBER 8
`define LOPRI_MAILBOXES_WIDTH $clog2(`LOPRI_MAILBOXES_NUMBER)

`define LOPRI_MSG_LENGTH 128
`define LOPRI_MSG_WIDTH $clog2(`LOPRI_MSG_LENGTH)
`define HIPRI_MSG_LENGTH 128
`define HIPRI_MSG_WIDTH $clog2(`HIPRI_MSG_LENGTH)

`define POINTER_WIDTH $clog2(`HIPRI_MAILBOXES_NUMBER*`HIPRI_MSG_LENGTH+`LOPRI_MAILBOXES_NUMBER*`LOPRI_MSG_LENGTH)

`define COMM_MEMORY_EMIF_WIDTH (`POINTER_WIDTH-2)

`define CYCLE_PERIOD 16'd2500