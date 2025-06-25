module alt_vipcts131_cts_core

	#(parameter BITS_PER_SYMBOL = 8,
		parameter SYMBOLS_PER_BEAT = 3,
	  parameter TRIGGER_ON_WIDTH_CHANGE = 1,
	  parameter TRIGGER_ON_HEIGHT_CHANGE = 1,
	  parameter TRIGGER_ON_IMAGE_SOP =1)
		
	(	input		clk,
		input		rst,
		
		// interface to VIP control packet decoder
		input		[BITS_PER_SYMBOL * SYMBOLS_PER_BEAT - 1:0] din_data,
		input		din_valid,
		input 	din_sop,
		input		din_eop,
		output	din_ready,
		input		[15:0] width_in,
		input		[15:0] height_in,
		input		[3:0] interlaced_in,
		
		// interface to VIP control packet encoder via VIP flow control wrapper	
		input		dout_ready,		
		output	dout_valid,
		output [BITS_PER_SYMBOL * SYMBOLS_PER_BEAT - 1:0] dout_data,
		output	dout_eop,		
		output	dout_sop,
		
		// interface to cts_instruction_writer
		output reg 	do_data_write,
		input 	data_write_done,
		input 	go_n,
	  	output reg status_running_n,
		input 	disarm
			
		);

reg [BITS_PER_SYMBOL * SYMBOLS_PER_BEAT - 1:0] data_delay1;
reg valid_delay1;
reg sop_delay1;
reg eop_delay1;
reg hold_data_flow;		
		
reg [15:0] prev_width;
reg [15:0] prev_height;

//trigger condition
wire trigger;
generate
	if (TRIGGER_ON_WIDTH_CHANGE && !TRIGGER_ON_HEIGHT_CHANGE) begin
		assign trigger = (prev_width != width_in);
	end else if (!TRIGGER_ON_WIDTH_CHANGE && TRIGGER_ON_HEIGHT_CHANGE) begin
		assign trigger = (prev_height != height_in);
	end else if (TRIGGER_ON_WIDTH_CHANGE && TRIGGER_ON_HEIGHT_CHANGE) begin
		assign trigger = (prev_width != width_in) | (prev_height != height_in);
	end else begin//TRIGGER ON SOP IS EXCLUSIVE
		assign trigger = 1;
	end
endgenerate

//proporgating the data
assign din_ready = dout_ready & !hold_data_flow;
assign dout_valid = valid_delay1 & !hold_data_flow;
assign dout_data = data_delay1;
assign dout_sop = sop_delay1;
assign dout_eop = eop_delay1;

// simple FSM
localparam WAITING_FOR_VID_SOP = 0;
localparam WRITING_DATA_TO_TARGET = 1;
localparam STOPPED = 2;
reg [1:0] state;

always @(posedge clk or posedge rst)
	if (rst) begin
		data_delay1 <= 0;
		valid_delay1 <= 0;
		sop_delay1 <= 0;
		eop_delay1 <= 0;
		prev_width <= 0;
		prev_height <= 0;
		state <= WAITING_FOR_VID_SOP;
		hold_data_flow <= 0;
		status_running_n <= 1;
		do_data_write <= 0;
	end else begin
		
		if(din_ready) begin
			data_delay1 <= din_data;
			valid_delay1 <= din_valid;
			sop_delay1 <= din_sop;
			eop_delay1 <= din_eop;
		end

		//states		
		case(state)
			WAITING_FOR_VID_SOP : begin
				if (din_valid && din_ready && din_sop && (din_data [3:0] == 4'h0)) begin								
					state <= STOPPED;
					status_running_n <= 1;
					hold_data_flow <= 1;
				end
			end

			STOPPED : begin
				if(!go_n) begin
					if(trigger && !disarm) begin
						state <= WRITING_DATA_TO_TARGET;
						do_data_write <= 1;			
					end else begin
						state <= WAITING_FOR_VID_SOP;
						hold_data_flow <= 0;
						status_running_n <= 0;
						prev_width <= width_in;
						prev_height <= height_in;
					end
				end
			end
		
			WRITING_DATA_TO_TARGET : begin
				do_data_write <= 0;	//lower this flag, it should only be high for one cycle
				if(data_write_done) begin
					state <= WAITING_FOR_VID_SOP;
					hold_data_flow <= 0;
					status_running_n <= 0;
					prev_width <= width_in;
					prev_height <= height_in;
				end
			end
					
		endcase
		
	end	

endmodule
