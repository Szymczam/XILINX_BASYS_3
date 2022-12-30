
`define DUAL_SDO_MODE_32CLK
//`define SINGLE_SDO_MODE_32CLK
//`define DUAL_SDO_MODE_16CLK
//`define SINGLE_SDO_MODE_16CLK


`timescale 10ps/1fs

module ADS7254(	

	input			iRST,
	input			iCLK_32,
	input			iCLK_100,
	input           iSYNC,

	input			iSDOA,

	input			iSDOB,
	output			oSDI,
	output			oCS_n,
	output			oCLK,

	output  [11:0]	odata_ch_A,
	output  [11:0]	odata_ch_B

);

//===================================================================                          
//                         Structural coding
//===================================================================
    localparam IDLE 		= 3'd0;
    localparam START 		= 3'd1;
    localparam TRANSMIT 	= 3'd2;
    localparam STOP 		= 3'd3;
 
    reg [1:0] spi_state = IDLE;
    reg CS_n = 0;
    
    reg [11:0] data_receiveA32  = 0;
    reg [11:0] data_receiveB32  = 0;
    reg [11:0] data_receiveA100 = 0;
    reg [11:0] data_receiveB100 = 0;
    reg [4:0] cnt  = 0;
    
    wire sync;
    
    xpm_cdc_array_single #(
       .DEST_SYNC_FF(3),   // DECIMAL; range: 2-10
       .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
       .SIM_ASSERT_CHK(1), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
       .SRC_INPUT_REG(1),  // DECIMAL; 0=do not register input, 1=register input
       .WIDTH(1)          // DECIMAL; range: 1-1024
    )
    xpm_cdc_array_single_sync (
       .dest_out(sync), // WIDTH-bit output: src_in synchronized to the destination clock domain.
       .dest_clk(iCLK_32), // 1-bit input: Clock signal for the destination clock domain.
       .src_clk(iCLK_100),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
       .src_in(iSYNC) // WIDTH-bit input: Input single-bit array to be synchronized to destination clock domain.
    );
    
    always@(posedge iCLK_32 or posedge iRST) 
	begin
	    if (iRST) 
        begin 
            CS_n = 1;
            cnt = 0;
            spi_state = IDLE; 
        end else 
        begin
            case (spi_state)	
                START  :  begin
                            CS_n = 0;
                            cnt = 0;
                            spi_state = TRANSMIT;
                        end
                TRANSMIT  :  begin
                            CS_n = 0;
                            cnt = cnt + 1;						
                            if (cnt == 0) spi_state = STOP;
                        end
                STOP  :  begin
                            CS_n = 1;
                            cnt = 0;
                            spi_state = IDLE;
                        end
                default :	begin    // IDLE
                            CS_n = 1;
                            cnt = 0;
                            if(sync) spi_state = START;
                        end
			 endcase
	    end				
	end
	
	
	reg	[11:0]	data_A32 = 0;
	reg	[11:0]	data_B32 = 0;
	reg [11:0]	adc_data_A = 0;
	reg [11:0]	adc_data_B = 0;
	
	
	// Reading data
	always@(negedge iCLK_32)
	begin
		if(CS_n)
			begin
				data_A32 <=	0;
				data_B32 <=	0;
			end
		else
		begin		
			case (cnt)	
				18  :  begin
							data_A32[11]<= iSDOA;	
							data_B32[11]<= iSDOB;
						end
				19  :  begin
							data_A32[10]<= iSDOA;	
							data_B32[10]<= iSDOB;
						end
				20  :  begin
							data_A32[9]<= iSDOA;	
							data_B32[9]<= iSDOB;
						end
				21  :  begin
							data_A32[8]<= iSDOA;	
							data_B32[8]<= iSDOB;
						end
				22  :  begin
							data_A32[7]<= iSDOA;	
							data_B32[7]<= iSDOB;
						end
				23  :  begin
							data_A32[6]<= iSDOA;	
							data_B32[6]<= iSDOB;
						end
				24 :  begin
							data_A32[5]<= iSDOA;	
							data_B32[5]<= iSDOB;
						end
				25 :  begin
							data_A32[4]<= iSDOA;	
							data_B32[4]<= iSDOB;
						end
				26 :  begin
							data_A32[3]<= iSDOA;	
							data_B32[3]<= iSDOB;
						end
				27 :  begin
							data_A32[2]<= iSDOA;	
							data_B32[2]<= iSDOB;
						end
				28 :  begin
							data_A32[1]<= iSDOA;	
							data_B32[1]<= iSDOB;
						end
				29 :	begin
							data_A32[0]<= iSDOA;	
							data_B32[0]<= iSDOB;
						end
			endcase				
		end
	end
	
	wire enb_read;
	assign enb_read = (cnt == 30)? 1'b1 : 1'b0; 


	always@(negedge iCLK_32) 
	begin
        if (iRST)           data_receiveA32 <= 0;
        else if (enb_read)  data_receiveA32 <= data_A32; 
    end

	always@(negedge iCLK_32) 
	begin
        if (iRST)           data_receiveB32 <= 0;
        else if (enb_read)  data_receiveB32 <= data_B32;
    end
	
	
	always@(posedge iCLK_100) 
	begin
        if (iRST)       data_receiveA100 <= 0;  
        else if (CS_n)  data_receiveA100 <= data_receiveA32;
    end
    
    always@(posedge iCLK_100)
    begin
        if (iRST)       data_receiveB100 <= 0;  
        else if (CS_n)  data_receiveB100 <= data_receiveB32;
    end	 

    
    reg read_enb;
    always@(negedge iCLK_32) 
	begin
        if (iRST)                           read_enb <= 1'b0;
        else if (spi_state == TRANSMIT)     read_enb <= 1'b1;
        else                                read_enb <= 1'b0;
    end
    
	// CS_n	
	assign	oCS_n   =	CS_n;
	// SCLK
	assign	oCLK    =	(read_enb) ? iCLK_32 : 0;
	// DIN
	assign	oSDI    =	0;
	// Results
    assign 	odata_ch_A = data_receiveA100;
	assign 	odata_ch_B = data_receiveB100;

endmodule