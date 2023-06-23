`timescale 1ns / 10fs
`define SIMULATION

module main_tb(
);
    initial $display ("Enable Simulation");    
    reg 	CLK_IN_100MHz = 0;
    reg 	RST = 1;
    
    initial begin
        #400 RST = 0;
    end
    
    always begin
		CLK_IN_100MHz = 0;
		forever
			#5 CLK_IN_100MHz = !CLK_IN_100MHz;
	end



    main main_inst(
        .CLK_IN_100MHz(CLK_IN_100MHz),
        .btnC(RST),
        .btnD(1'b1),
        .SW(),
        .JA(),
        .JB(),
        .JC()
    );


endmodule
