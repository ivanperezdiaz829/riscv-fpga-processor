// top-level module of user algorithm and wrappers which is instantiated in SOPC Builder
module alt_vipcts131_cts

	#(parameter BITS_PER_SYMBOL = 8,
	  parameter NUMBER_OF_COLOR_PLANES = 3,
	  parameter COLOUR_PLANES_ARE_IN_PARALLEL = 1,
	  parameter MAX_INSTRUCTION_COUNT = 3,
	  parameter TRIGGER_ON_WIDTH_CHANGE = 1,
	  parameter TRIGGER_ON_HEIGHT_CHANGE = 1,
	  parameter TRIGGER_ON_IMAGE_SOP =1,
	  parameter DISARM_ON_TRIGGER = 0) 
		
		
		
	(	
	  input		clock,
		input		reset,
	
		// Avalon-ST sink interface
		output	din_ready,
		input		din_valid,
		input		din_startofpacket,
		input		din_endofpacket,
		input		[BITS_PER_SYMBOL * (COLOUR_PLANES_ARE_IN_PARALLEL == 0 ? 1 : NUMBER_OF_COLOR_PLANES) - 1:0] din_data, 
		
		// Avalon-ST source interface
		input		dout_ready,
		output	dout_valid,
		output	dout_startofpacket,
		output	dout_endofpacket,
		output	[BITS_PER_SYMBOL * (COLOUR_PLANES_ARE_IN_PARALLEL == 0 ? 1 : NUMBER_OF_COLOR_PLANES) - 1:0] dout_data,
		
		// Avalon-MM slave interface
		input [4:0] slave_address,
		input slave_read,
		output [31:0] slave_readdata,
		input slave_write,
		input [31:0] slave_writedata,
		output status_update_int,
		
		// Avalon-MM master interface
		output [31:0] master_address,
		output [31:0] master_writedata,
		output master_write,
		input master_waitrequest);
		
		localparam SYMBOLS_PER_BEAT = COLOUR_PLANES_ARE_IN_PARALLEL == 0 ? 1 : NUMBER_OF_COLOR_PLANES;
		
		// Avalon-MM slave internal signals
		wire 	[4:0] av_slave_address_w;
		wire 	av_slave_read_w;
		wire 	[31:0] av_slave_readdata_w;
		wire 	av_slave_write_w;
		wire 	[31:0] av_slave_writedata_w;
		wire 	status_update_int_w;
		
		// Avalon-MM master internal signals
		wire 	[31:0] master_address_w;
		wire 	[31:0] master_writedata_w;
		wire 	master_write_w;
		wire 	master_waitrequest_w;
		
// Avalon Stream Input internal signals
		wire		input_ready;
		wire		input_valid;
		wire		input_sop;
		wire		input_eop;
		wire		[BITS_PER_SYMBOL * SYMBOLS_PER_BEAT - 1:0] input_data;
		
// VIP Avalon Stream Input
alt_vipcts131_common_stream_input
	#(.DATA_WIDTH (BITS_PER_SYMBOL * SYMBOLS_PER_BEAT))
	avalon_st_input
	(	.clk (clock),
		.rst (reset),
		.din_ready (din_ready),
		.din_valid (din_valid),
		.din_data (din_data),
		.din_sop (din_startofpacket),
		.din_eop (din_endofpacket),
		.int_ready (input_ready),
		.int_valid (input_valid),
		.int_data (input_data),
		.int_sop (input_sop),
		.int_eop (input_eop));				
						
// VIP_Control_Packet_decoder signals
wire		decoder_ready;
wire 		decoder_valid;
wire		decoder_sop;
wire 		decoder_eop;
wire 		[BITS_PER_SYMBOL * SYMBOLS_PER_BEAT - 1:0] decoder_data;

wire		[15:0] decoder_width;
wire		[15:0] decoder_height;
wire		[3:0] decoder_interlaced;

wire		decoder_vip_ctrl_valid;
wire		decoder_end_of_video;
wire		decoder_is_video;
						
// VIP_Control_Packet_decoder instantiation		
alt_vipcts131_common_control_packet_decoder
	#(.BITS_PER_SYMBOL (BITS_PER_SYMBOL),
		.SYMBOLS_PER_BEAT (SYMBOLS_PER_BEAT))
	decoder	
	(	.clk (clock),
		.rst (reset),
		// Avalon-ST sink interface
		.din_ready (input_ready),
		.din_valid (input_valid),
		.din_sop (input_sop),
		.din_eop (input_eop),
		.din_data (input_data),
		// interface to user algorithm
		.dout_ready (decoder_ready),
		.dout_valid (decoder_valid),
		.dout_data (decoder_data),
		.dout_sop (decoder_sop),
		.dout_eop (decoder_eop),
		.width (decoder_width),
		.height (decoder_height),
		.interlaced (decoder_interlaced),
		.is_video (decoder_is_video),
		.end_of_video (decoder_end_of_video),
		.vip_ctrl_valid (decoder_vip_ctrl_valid)
	);
	

wire 	resolution_changed_w;
wire	hold_before_image_data_w;
wire	stalled_w;
wire	transfer_done_w;
wire 	disarm_w;
wire	output_ready;
wire	output_valid;
wire	output_eop;
wire	output_sop;
wire [BITS_PER_SYMBOL * SYMBOLS_PER_BEAT - 1:0] output_data;
	
// algorithm core instantiation 
alt_vipcts131_cts_core
	#(.BITS_PER_SYMBOL (BITS_PER_SYMBOL),
		.SYMBOLS_PER_BEAT (SYMBOLS_PER_BEAT),
		.TRIGGER_ON_WIDTH_CHANGE (TRIGGER_ON_WIDTH_CHANGE),
		.TRIGGER_ON_HEIGHT_CHANGE (TRIGGER_ON_HEIGHT_CHANGE),
		.TRIGGER_ON_IMAGE_SOP (TRIGGER_ON_IMAGE_SOP))
	algorithm	
	(	.clk (clock),
		.rst (reset),	
		//input
		.din_data (decoder_data),
		.din_valid (decoder_valid),
		.din_sop (decoder_sop),
		.din_eop (decoder_eop),
		.din_ready (decoder_ready),
		.width_in (decoder_width),
		.height_in (decoder_height),
		.interlaced_in (decoder_interlaced),	
		// output
		.dout_ready (output_ready),
		.dout_valid (output_valid),
		.dout_data (output_data),
		.dout_eop (output_eop),		
		.dout_sop (output_sop),
		
		//instruction writer
		.do_data_write(resolution_changed_w),
		.data_write_done(transfer_done_w),
		.status_running_n(stalled_w),
		.go_n(hold_before_image_data_w),
		.disarm(disarm_w)
		);
	
	
// VIP Avalon Stream Output
alt_vipcts131_common_stream_output
	#(.DATA_WIDTH (BITS_PER_SYMBOL * SYMBOLS_PER_BEAT))
	avalon_st_output
	(	.clk (clock),
		.rst (reset),
		.dout_ready (dout_ready),
		.dout_valid (dout_valid),
		.dout_data (dout_data),
		.dout_sop (dout_startofpacket),
		.dout_eop (dout_endofpacket),
		.int_ready (output_ready),
		.int_valid (output_valid),
		.int_data (output_data),
		.int_sop (output_sop),
		.int_eop (output_eop),
		.enable (1'b1),
		.synced ());				
							

alt_vipcts131_cts_instruction_writer 
	#(.MAX_INSTRUCTION_COUNT (MAX_INSTRUCTION_COUNT),
	.DISARM_ON_TRIGGER(DISARM_ON_TRIGGER))
	piw(
	.rst(reset),
	.clk(clock),
	
	// Slave Control port
	.av_slave_address(slave_address),
	.av_slave_read(slave_read),
	.av_slave_readdata(slave_readdata),
	.av_slave_write(slave_write),
	.av_slave_writedata(slave_writedata),
	//	.av_waitrequest,
	
	// Interrupt
	.status_update_int(status_update_int),
	
	// Master port
	.av_master_address(master_address),
	.av_master_writedata(master_writedata),
	.av_master_write(master_write),
	.av_master_waitrequest(master_waitrequest),
	
	//instruction lines	
	.do_transfer(resolution_changed_w),
	.done_transfer(transfer_done_w),
	// Core stop/go control
	.hold_before_image_data(hold_before_image_data_w),
	.stalled(stalled_w),
	.disarm(disarm_w)
	

);

endmodule
					
			
