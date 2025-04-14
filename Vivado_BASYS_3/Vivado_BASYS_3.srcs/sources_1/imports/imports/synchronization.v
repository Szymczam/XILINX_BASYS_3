`include "global.v" 

module Node_number_eval(clk_1x_i, fifo_clk_i, fifo_we_i, fifo_i, node_number_o, node_number_rdy_o);
	input clk_1x_i;
	input fifo_clk_i;
	input[1:0] fifo_we_i;
	input[8:0] fifo_i;

	output reg[`HIPRI_MAILBOXES_WIDTH-1:0] node_number_o;
	output reg node_number_rdy_o;

	reg[15:0] timeout_counter;
	reg[`HIPRI_MAILBOXES_WIDTH-1:0] node_counter;
	reg[`HIPRI_MAILBOXES_WIDTH-1:0] node_counter_save;
	reg[`HIPRI_MAILBOXES_WIDTH-1:0] node_number_last;
	reg[1:0] stable_counter;
	
	assign K_Enum_nodes = fifo_i == `K_Enum_nodes && fifo_we_i[0];
	assign K_Timestamp_master = fifo_i == `K_Timestamp_master && fifo_we_i[0];
	
	reg K_Enum_nodes_r;
	reg K_Timestamp_master_r;
	always @(posedge fifo_clk_i) begin
		K_Enum_nodes_r <= K_Enum_nodes;
		K_Timestamp_master_r <= K_Timestamp_master;
		if(K_Enum_nodes & !K_Enum_nodes_r)
			node_counter <= node_counter + 1'b1;	
		if(K_Timestamp_master & !K_Timestamp_master_r) begin
			node_counter_save <= node_counter;
			node_counter <= {`HIPRI_MAILBOXES_WIDTH{1'b0}};
		end
	end
	
  	wire K_Timestamp_master_sync;
	Sync_latch_input #(.OUT_POLARITY(1), .STEPS(2)) Sync_latch_error_propagation(.clk_i(clk_1x_i), .in(K_Timestamp_master_r), .out(K_Timestamp_master_sync), .reset_i(K_Timestamp_master_sync), .set_i(1'b0));
  
	always @(posedge clk_1x_i) begin
		timeout_counter <= timeout_counter + 1'b1;
		node_number_rdy_o <= stable_counter == 2'b11;
		
		if(K_Timestamp_master_sync) begin
			timeout_counter <= 16'b0;
			node_number_last <= node_number_o;
			node_number_o <= node_counter_save;
			if(node_counter_save == node_number_last && node_number_o == node_number_last) begin
				if(!node_number_rdy_o)
					stable_counter <= stable_counter + 1'b1;
			end else
				stable_counter <= 2'b0;
		end
		
		if(timeout_counter == `CYCLE_PERIOD >> 2)
			stable_counter <= 2'b0;
	end

	initial begin
		K_Enum_nodes_r = 0;
		K_Timestamp_master_r = 0;
		timeout_counter = 0;
		node_counter = 0;
		node_counter_save = 0;
		node_number_o = 0;
		node_number_last = 0;
		node_number_rdy_o = 0;
		stable_counter = 0;
	end
endmodule

module Local_counter(clk_i, next_period_i, current_period_o, local_counter_o, sync_phase_o, snapshot_start_i, snapshot_value_o); 
	parameter INITIAL_PHASE = 0;
	input clk_i; 
	input[15:0] next_period_i; 
	output reg[15:0] current_period_o; 
	output reg[15:0] local_counter_o; 
	output reg sync_phase_o;
	input[3:0] snapshot_start_i; 
	output[63:0] snapshot_value_o; 
	
/////////////////////////////////////////////////
	
	wire[3:0] snapshot_start_r;
	Sync_latch_input #(.OUT_POLARITY(1), .STEPS(4)) sync_snap_start[3:0](.clk_i(clk_i), .in(snapshot_start_i), .out(snapshot_start_r), .reset_i(snapshot_start_r), .set_i(1'b0));
	 
	reg[15:0] snapshot_value_r[3:0]; 

	assign snapshot_value_o = {snapshot_value_r[3], snapshot_value_r[2],	snapshot_value_r[1], snapshot_value_r[0]};

	always @(posedge clk_i) begin
		if(snapshot_start_r[3]) snapshot_value_r[3] <= local_counter_o; 
		if(snapshot_start_r[2]) snapshot_value_r[2] <= local_counter_o; 
		if(snapshot_start_r[1]) snapshot_value_r[1] <= local_counter_o; 
		if(snapshot_start_r[0]) snapshot_value_r[0] <= local_counter_o; 
 
		if(local_counter_o == current_period_o) begin
			current_period_o <= next_period_i;			
			sync_phase_o <= ~sync_phase_o;
			local_counter_o <= 0; 
		end
		else 
			local_counter_o <= local_counter_o + 1'b1; 
	end 
 
	initial begin 
		sync_phase_o = INITIAL_PHASE;
		current_period_o = `CYCLE_PERIOD - 16'd1; 
		local_counter_o = 0; 
		snapshot_value_r[3] = 0; 
		snapshot_value_r[2] = 0; 
		snapshot_value_r[1] = 0; 
		snapshot_value_r[0] = 0; 
	end 
endmodule 

module Master_sync(clk_i, pulse_cycle_i, rx_addrw_i, rx_dataw_i, rx_we_i, snapshot_value_i, clock_offsets_o, comm_delays_o, rx_ok_o, sync_ok_o, slave_rdy_o, scope_trigger_request_o);
	localparam STATES_WIDTH = 3;
	localparam [STATES_WIDTH-1:0]
    S_MS_idle = 0,
    S_MS_1 = 1,
    S_MS_2 = 2,
	S_MS_3 = 3,
    S_MS_4 = 4,
    S_MS_5 = 5,
    S_MS_6 = 6,
	S_MS_7 = 7;
	reg[STATES_WIDTH-1:0] state_reg;
 
	integer i; 
	genvar j;
/////////////////////////////////////////////////////////////////////

	input clk_i;
	input pulse_cycle_i; 
	
	input[`POINTER_WIDTH-1:0] rx_addrw_i; 
	input[7:0] rx_dataw_i;
	input rx_we_i; 
	input[63:0] snapshot_value_i; 
	 
	output[`HIPRI_MAILBOXES_NUMBER*16-1:0] clock_offsets_o; 
	output[`HIPRI_MAILBOXES_NUMBER*16-1:0] comm_delays_o; 
	output reg[`HIPRI_MAILBOXES_NUMBER-1:0] rx_ok_o; 
	output reg[`HIPRI_MAILBOXES_NUMBER-1:0] sync_ok_o; 
	output reg[`HIPRI_MAILBOXES_NUMBER-1:0] slave_rdy_o; 
	output reg[`HIPRI_MAILBOXES_NUMBER-1:0] scope_trigger_request_o; 
	
/////////////////////////////////////////////////////////////////////

	wire pulse_cycle_r; 
	Sync_latch_input #(.OUT_POLARITY(1), .STEPS(2)) Sync_latch_value_compare(.clk_i(clk_i), .in(pulse_cycle_i), .out(pulse_cycle_r), .reset_i(pulse_cycle_r), .set_i(1'b0));
 
	reg[`HIPRI_MAILBOXES_NUMBER-1:0] rx_rdy1_r;
	reg[`HIPRI_MAILBOXES_NUMBER-1:0] rx_rdy2_r; 
	reg[`HIPRI_MAILBOXES_NUMBER-1:0] rx_rdy1_w; 
	reg[`HIPRI_MAILBOXES_NUMBER-1:0] rx_rdy2_w;
	reg[`HIPRI_MAILBOXES_WIDTH+1:0] timestamp_adrw;		
	reg timestamp_we1;
	reg timestamp_we2;
	always @(*) begin 
		rx_rdy1_w = rx_rdy1_r; 
		rx_rdy2_w = rx_rdy2_r;
		timestamp_we1 = 1'b0;
		timestamp_we2 = 1'b0;
		timestamp_adrw = {`HIPRI_MAILBOXES_WIDTH+1{1'b0}}; 
		for(i = 0; i < `HIPRI_MAILBOXES_NUMBER*4; i = i + 1) begin 
			if(rx_addrw_i == ((i%4 << 1) + 4 + (i>>2)*`HIPRI_MSG_LENGTH + `LOPRI_MSG_LENGTH*`LOPRI_MAILBOXES_NUMBER)) begin 
				if(rx_we_i) begin 
					if(i == 0) 
						rx_rdy1_w = rx_rdy1_r | (1'b1 << (i>>2)); 
					else if(rx_rdy1_r[(i>>2)-1] && rx_rdy2_r[(i>>2)-1]) 
						rx_rdy1_w = rx_rdy1_r | (1'b1 << (i>>2)); 
				end	 
				 
				timestamp_we1 = rx_we_i; 
				timestamp_adrw = i[`HIPRI_MAILBOXES_WIDTH+1:0]; 
			end 
			if(rx_addrw_i == ((i%4 << 1) + 5 + (i>>2)*`HIPRI_MSG_LENGTH + `LOPRI_MSG_LENGTH*`LOPRI_MAILBOXES_NUMBER)) begin 
				if(rx_we_i) begin 
					if(rx_rdy1_r[(i>>2)]) begin 
						if(i == 0)
							rx_rdy2_w = rx_rdy2_r | (1'b1 << (i>>2));
						else if(rx_rdy1_r[(i>>2)-1] && rx_rdy2_r[(i>>2)-1])
							rx_rdy2_w = rx_rdy2_r | (1'b1 << (i>>2)); 
					end
				end	
				timestamp_we2 = rx_we_i;
				timestamp_adrw = i[`HIPRI_MAILBOXES_WIDTH+1:0];
			end 
		end 
	end 
	
	reg[15:0] flags_memory[`HIPRI_MAILBOXES_NUMBER-1:0];
	reg[7:0] timestamp_memory0[`HIPRI_MAILBOXES_NUMBER*4-1:0];
	reg[7:0] timestamp_memory1[`HIPRI_MAILBOXES_NUMBER*4-1:0];
	reg[15:0] snapshot_value_tx1_codes;
	reg[15:0] snapshot_value_rx1_codes;
	reg[15:0] snapshot_value_tx2_codes;
	reg[15:0] snapshot_value_rx2_codes;
	always @(posedge clk_i) begin
		if(timestamp_we1)
			timestamp_memory0[timestamp_adrw] <= rx_dataw_i;
		if(timestamp_we2)
			timestamp_memory1[timestamp_adrw] <= rx_dataw_i; 
		if(pulse_cycle_r) 
			{snapshot_value_rx2_codes, snapshot_value_tx2_codes, snapshot_value_rx1_codes, snapshot_value_tx1_codes} <= snapshot_value_i; 
 
		for(i = 0; i < `HIPRI_MAILBOXES_NUMBER; i = i + 1) begin
			if(rx_addrw_i == (2 + i*`HIPRI_MSG_LENGTH + `LOPRI_MSG_LENGTH*`LOPRI_MAILBOXES_NUMBER) && rx_we_i)
				flags_memory[i][7:0] <= rx_dataw_i;
			if(rx_addrw_i == (3 + i*`HIPRI_MSG_LENGTH + `LOPRI_MSG_LENGTH*`LOPRI_MAILBOXES_NUMBER) && rx_we_i)
				flags_memory[i][15:8] <= rx_dataw_i; 
			if(pulse_cycle_r)
				flags_memory[i] <= 16'b0; 
		end 
	end 
	 
	reg[`HIPRI_MAILBOXES_WIDTH-1:0] converter_number; 
	reg[`HIPRI_MAILBOXES_WIDTH+1:0] read_address;
	always @(*) begin
		case(state_reg)
			S_MS_idle : read_address = {converter_number, 2'b0};
			S_MS_1 : read_address = {converter_number, 2'b0} + 4'h0; 
			S_MS_2 : read_address = {converter_number, 2'b0} + 4'h1; 
			S_MS_3 : read_address = {converter_number, 2'b0} - 4'h2; 
			S_MS_4 : read_address = {converter_number, 2'b0} - 4'h1; 
			S_MS_5 : read_address = {converter_number, 2'b0}; 
			S_MS_6 : read_address = {converter_number, 2'b0}; 
			S_MS_7 : read_address = {converter_number, 2'b0};
		endcase
	end 
	wire[15:0] timestamp_memory_read;
	assign timestamp_memory_read = {timestamp_memory1[read_address], timestamp_memory0[read_address]};
 
	reg[15:0] ALU_offset; 
	reg[15:0] ALU_delay; 
	reg[15:0] clock_offsets_r[`HIPRI_MAILBOXES_NUMBER-1:0]; 
	reg[15:0] comm_delays_r[`HIPRI_MAILBOXES_NUMBER-1:0]; 
	always @(posedge clk_i) begin
		rx_rdy1_r <= rx_rdy1_w;
		rx_rdy2_r <= rx_rdy2_w; 
		case (state_reg)
			S_MS_idle : begin 
				ALU_delay <= 16'b0;
				ALU_offset <= 16'b0; 
				converter_number <= {`HIPRI_MAILBOXES_WIDTH{1'b0}}; 
				if(pulse_cycle_r) begin
					state_reg <= S_MS_1; 
					rx_rdy1_r <= {`HIPRI_MAILBOXES_NUMBER{1'b0}};
					rx_rdy2_r <= {`HIPRI_MAILBOXES_NUMBER{1'b0}};
					rx_ok_o <= rx_rdy1_r & rx_rdy2_r;	 
					for(i = 0; i < `HIPRI_MAILBOXES_NUMBER; i = i + 1) 
						sync_ok_o[i] <= rx_rdy1_r[i] && rx_rdy2_r[i] && flags_memory[i][0]; 
					for(i = 0; i < `HIPRI_MAILBOXES_NUMBER; i = i + 1)
						slave_rdy_o[i] <= rx_rdy1_r[i] && rx_rdy2_r[i] && flags_memory[i][0] && flags_memory[i][1];
					for(i = 0; i < `HIPRI_MAILBOXES_NUMBER; i = i + 1)
						scope_trigger_request_o[i] <= rx_rdy1_r[i] && rx_rdy2_r[i] && flags_memory[i][2];	
				end
			end 
			S_MS_1 : begin 
				ALU_delay <= ALU_delay + timestamp_memory_read;
				ALU_offset <= ALU_offset + timestamp_memory_read;
				state_reg <= S_MS_2;
			end
			S_MS_2 : begin 
				ALU_delay <= ALU_delay - timestamp_memory_read; 
				ALU_offset <= ALU_offset + timestamp_memory_read; 
				state_reg <= S_MS_3;
			end
			S_MS_3 : begin 
				if(converter_number == {`HIPRI_MAILBOXES_WIDTH{1'b0}}) begin 
					ALU_delay <= ALU_delay - snapshot_value_tx1_codes; 
					ALU_offset <= ALU_offset - snapshot_value_tx1_codes; 
				end  
				else begin 
					ALU_delay <= ALU_delay - timestamp_memory_read;
					ALU_offset <= ALU_offset - timestamp_memory_read;					 
				end
				state_reg <= S_MS_4;
			end
			S_MS_4 : begin 
				if(converter_number == {`HIPRI_MAILBOXES_WIDTH{1'b0}}) begin
					ALU_delay <= ALU_delay + snapshot_value_rx1_codes;
					ALU_offset <= ALU_offset - snapshot_value_rx1_codes;
				end  
				else begin
					ALU_delay <= ALU_delay + timestamp_memory_read;
					ALU_offset <= ALU_offset - timestamp_memory_read;					
				end
				state_reg <= S_MS_5;
			end
			S_MS_5 : begin 
				comm_delays_r[converter_number] <= ALU_delay; 
				clock_offsets_r[converter_number] <= ALU_offset; 
 
				converter_number <= converter_number + 1'b1;
				ALU_delay <= 16'b0; 
				if(converter_number == {`HIPRI_MAILBOXES_WIDTH{1'b1}})
					state_reg <= S_MS_idle; 
				else 
					state_reg <= S_MS_1;
			end
			S_MS_6 : begin
				state_reg <= S_MS_idle;
			end
			S_MS_7 : begin
				state_reg <= S_MS_idle;
			end
		endcase
	end 
	 
	initial begin 
		slave_rdy_o = 0; 
		rx_rdy1_r = 0; 
		rx_rdy2_r = 0; 
		rx_ok_o = 0; 
		sync_ok_o = 0; 
		scope_trigger_request_o = 0; 
		state_reg = 0; 
		for(i = 0;i < `HIPRI_MAILBOXES_NUMBER*4; i = i + 1) begin
			timestamp_memory0[i] = 0;
			timestamp_memory1[i] = 0;
		end
		for(i = 0;i < `HIPRI_MAILBOXES_NUMBER; i = i + 1) begin
			comm_delays_r[i] = 0;
			clock_offsets_r[i] = 0; 
			flags_memory[i] = 0;
		end
	end 
	 
	for(j = 0; j < `HIPRI_MAILBOXES_NUMBER; j = j + 1) begin
		assign clock_offsets_o[j*16 +: 16] = clock_offsets_r[j];
		assign comm_delays_o[j*16 +: 16] = comm_delays_r[j]; 
	end 

endmodule
 
module Slave_sync(clk_i, rx_addrw_i, rx_dataw_i, rx_we_i, node_number_i, node_number_rdy_i, msg_rdy_i, next_period_o, sync_phase_i, Kalman_offset_o, Kalman_rate_o, offset_memory_o, sync_rdy_o);
	localparam STATES_WIDTH = 3;
	localparam [STATES_WIDTH-1:0]
    S_SS_idle = 0,
    S_SS_1 = 1,
    S_SS_2 = 2,
	S_SS_3 = 3,
    S_SS_4 = 4,
    S_SS_5 = 5,
    S_SS_6 = 6,
	S_SS_7 = 7;
	reg[STATES_WIDTH-1:0] state_reg;

	integer i;
	genvar j;
/////////////////////////////////////////////////////////////////////

	input clk_i;
	
	input[`POINTER_WIDTH-1:0] rx_addrw_i;
	input[7:0] rx_dataw_i;
	input rx_we_i;
	input[`HIPRI_MAILBOXES_WIDTH-1:0] node_number_i; 
	input node_number_rdy_i; 
	input msg_rdy_i; 
	output reg[15:0] next_period_o;
	input sync_phase_i; 
	 
	output reg[31:0] Kalman_offset_o; 
	output reg[31:0] Kalman_rate_o; 
	output reg[15:0] offset_memory_o; 
	output reg sync_rdy_o; 
	
/////////////////////////////////////////////////////////////////////

	reg[15:0] flags_memory;
	always @(posedge clk_i) begin 
		if(rx_addrw_i == 2 + `HIPRI_MSG_LENGTH*1 + `LOPRI_MSG_LENGTH*`LOPRI_MAILBOXES_NUMBER)
			flags_memory[7:0] <= rx_dataw_i;
		if(rx_addrw_i == 3 + `HIPRI_MSG_LENGTH*1 + `LOPRI_MSG_LENGTH*`LOPRI_MAILBOXES_NUMBER)
			flags_memory[15:8] <= rx_dataw_i; 
			
		if(rx_addrw_i == 4 + `HIPRI_MSG_LENGTH*1 + `LOPRI_MSG_LENGTH*`LOPRI_MAILBOXES_NUMBER + (node_number_i<<1))
			offset_memory_o[7:0] <= rx_dataw_i;
		if(rx_addrw_i == 5 + `HIPRI_MSG_LENGTH*1 + `LOPRI_MSG_LENGTH*`LOPRI_MAILBOXES_NUMBER + (node_number_i<<1))
			offset_memory_o[15:8] <= rx_dataw_i; 
	end
	 
	initial begin
		offset_memory_o = 0; 
		flags_memory = 0;
	end 
	
	reg[31:0] A_r;
	reg[31:0] B_r; 
	wire[63:0] Y_mult; 
	reg start_r; 
	wire rdy_mult; 
	Multiplier_signed #(.WIDTH_A(32), .WIDTH_B(32))Multiplier_signed(.clk_i(clk_i), .start_i(start_r), .A_i(A_r), .B_i(B_r), .Y_o(Y_mult), .rdy_o(rdy_mult)); 
 
	reg[31:0] Kalman_offset_predict; 
	wire[31:0] Kalman_error;
	assign Kalman_error = {offset_memory_o, 16'b0} - Kalman_offset_o; 
	 
	reg[15:0] sync_counter; 
	reg[1:0] period_request; 
	reg[1:0] period_request_r; 
	reg[2:0] period_request_timer; 
	reg comm_last;
	reg msg_rdy_r;
	reg msg_rdy_flag;
	reg[1:0] sync_phase_r;
	reg new_cycle_flag;
	assign new_cycle_r = sync_phase_r[1] ^ sync_phase_r[0];
	
	localparam [1:0]
    PERIOD_DONOTHING = 0,
    PERIOD_CHANGE_PHASE = 1,
    PERIOD_DECREASE = 2,
	PERIOD_INCREASE = 3;

	always @(posedge clk_i) begin 
		sync_phase_r <= {sync_phase_i, sync_phase_r[1]}; 
		msg_rdy_r <= msg_rdy_i;
		if(msg_rdy_i && !msg_rdy_r) begin
			msg_rdy_flag <= 1'b1;
			comm_last <= 1'b1;
		end

		if(new_cycle_r) begin
			new_cycle_flag <= 1'b1;
			comm_last <= 1'b0;
			
			if($signed(Kalman_offset_o) < $signed(786432/*65536.0*1.2*/) && $signed(Kalman_offset_o) > $signed(-786432/*-65536.0*1.2*/) && 
			   node_number_rdy_i && comm_last) begin
				if(sync_counter >= `FREQUENCY)
					sync_rdy_o <= 1'b1;
				else
					sync_counter <= sync_counter + 1'b1;
			end
			else begin
				sync_counter <= 16'b0;
				sync_rdy_o <= 1'b0; 
			end 
			
			period_request <= 2'b0;
			if(period_request_timer == 3'b0) begin
				period_request_r <= period_request;
				if(period_request != 2'b0) period_request_timer <= 3'b1;
				case (period_request) 
					PERIOD_DONOTHING : next_period_o <= `CYCLE_PERIOD - 16'd1;
					PERIOD_CHANGE_PHASE : next_period_o <= `CYCLE_PERIOD*2 - 16'd1;
					PERIOD_DECREASE : next_period_o <= `CYCLE_PERIOD - 16'd2; 
					PERIOD_INCREASE : next_period_o <= `CYCLE_PERIOD - 16'd0;
				endcase
			end
			else begin
				next_period_o <= `CYCLE_PERIOD - 16'd1;
				period_request_timer <= period_request_timer + 1'b1;
			end
		end 
		
		start_r <= 1'b0; 
		case (state_reg)
			S_SS_idle : begin
				if(msg_rdy_flag) begin
					if(node_number_rdy_i && flags_memory[node_number_i])				
						state_reg <= S_SS_1; 
					msg_rdy_flag <= 1'b0; 
				end
				else if(new_cycle_flag) begin
					new_cycle_flag <= 1'b0;
					state_reg <= S_SS_3;
					if(period_request_timer == 3'd5) begin
						case (period_request_r) 
							PERIOD_DONOTHING : ;
							PERIOD_CHANGE_PHASE : ;
							PERIOD_DECREASE : Kalman_offset_o <= Kalman_offset_o + {16'd2, 16'd0}; 
							PERIOD_INCREASE : Kalman_offset_o <= Kalman_offset_o - {16'd2, 16'd0};
						endcase
					end
				end
			end
			S_SS_1 : begin 
				A_r <= Kalman_error;
				B_r <= (2.0**32.0)*`KALMAN_GAIN; 
				start_r <= 1'b1;
				state_reg <= S_SS_2;
			end 
			S_SS_2 : begin 
				if(rdy_mult && !start_r) begin
					state_reg <= S_SS_idle; 
					Kalman_offset_o <= Kalman_offset_o + Y_mult[32 +: 32]; 
					Kalman_rate_o <= Kalman_rate_o + Y_mult[32 +: 32]; 
				end
			end
			S_SS_3 : begin 
				A_r <= Kalman_rate_o;
				B_r <= (2.0**32.0)*`SAMPLING_TIME*6.0;
				start_r <= 1'b1;
				state_reg <= S_SS_4;
			end
			S_SS_4 : begin
				if(rdy_mult && !start_r) begin
					state_reg <= S_SS_5;
					Kalman_offset_predict <= Kalman_offset_o + Y_mult[32 +: 32];
				end
			end
			S_SS_5 : begin 
				A_r <= Kalman_rate_o;
				B_r <= (2.0**32.0)*`SAMPLING_TIME;
				start_r <= 1'b1;
				state_reg <= S_SS_6;
			end
			S_SS_6 : begin
				if(rdy_mult && !start_r) begin
					state_reg <= S_SS_7;
					Kalman_offset_o <= Kalman_offset_o + Y_mult[32 +: 32];
				end
			end
			S_SS_7 : begin
				if($signed(Kalman_offset_predict) >= $signed(32'd65536))
					period_request <= PERIOD_INCREASE;
				else if($signed(Kalman_offset_predict) <= $signed(-32'd65536)) 
					period_request <= PERIOD_DECREASE;
				else if(sync_phase_r[0] == flags_memory[8])
					period_request <= PERIOD_CHANGE_PHASE;
				else
					period_request <= PERIOD_DONOTHING;	
				state_reg <= S_SS_idle;
			end
		endcase 
	end
 
	initial begin 
		sync_rdy_o = 0; 
		new_cycle_flag = 0; 
		sync_phase_r = 0; 
		comm_last = 0; 
		sync_counter = 0;
		period_request = 0; 
		period_request_r = 0; 
		period_request_timer = 0; 
		next_period_o = `CYCLE_PERIOD - 16'd1; 
		state_reg = 0; 
		Kalman_offset_o = 0; 
		Kalman_offset_predict = 0; 
		Kalman_rate_o = 0;
	end

endmodule
