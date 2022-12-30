
module clock_manager(	
	input          iclk_100MHz,
	input          irst,
    output         oclk_locked_o,
    output         oclk_200MHz,
 	output         oclk_100MHz
);

//===================================================================                       
//   IBUF: Single-ended Input Buffer
//===================================================================
//    wire CLK_100MH_bufio;
    
//    IBUF #(
//       .IBUF_LOW_PWR("FALSE"),  // Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
//       .IOSTANDARD("LVCMOS33")  // Specify the input I/O standard
//    ) IBUF_inst (
//       .O(CLK_100MH_bufio),     // Buffer output
//       .I(CLK_100MHz)      // Buffer input (connect directly to top-level port)
//    );
    
//=======================================================
//  Clock Wizard
//=======================================================  
    wire clk_locked;
    
    clk_wiz_0 clk_wiz_0_inst(
      // Clock out ports  
      .clk_out_200MHz(oclk_200MHz),
      .clk_out_100MHz(oclk_100MHz),
      // Status and control signals               
      .locked(oclk_locked_o),
     // Clock in ports
      .clk_in1(iclk_100MHz)
    );
    
endmodule

