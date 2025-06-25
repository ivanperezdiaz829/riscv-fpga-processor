/* VIP flow control input of HDL template */
module alt_vipitc131_common_flow_control_input

	#(parameter BITS_PER_SYMBOL = 8,
		parameter SYMBOLS_PER_BEAT = 3)
		
	(	input		clk,
		input		rst,
	
		// interface to decoder
		output	din_ready,
		input		din_valid,
		input		[BITS_PER_SYMBOL * SYMBOLS_PER_BEAT - 1:0] din_data,
		input		[15:0] decoder_width,
		input		[15:0] decoder_height,
		input		[3:0] decoder_interlaced,
		input		decoder_end_of_video,
		input		decoder_is_video,
		input		decoder_vip_ctrl_valid,
		
		// interface to algorithm core
		output	[BITS_PER_SYMBOL * SYMBOLS_PER_BEAT - 1:0] data_in,
		output	[15:0] width_in,
		output	[15:0] height_in,
		output	[3:0] interlaced_in,
		output	end_of_video_in,
		output	vip_ctrl_valid_in,
						
		// flow control signals
		input		read,
		output	stall_in
		);	

// conversion ready/valid to stall/read interface and filtering of active video		
assign data_in = din_data;
assign end_of_video_in = decoder_end_of_video;
assign din_ready = ~decoder_is_video | read;
assign stall_in = ~(din_valid & decoder_is_video);
		
// decoder control signals
assign width_in = decoder_width;
assign height_in = decoder_height;
assign interlaced_in = decoder_interlaced;
assign vip_ctrl_valid_in = decoder_vip_ctrl_valid;
	
endmodule
		
					
			
