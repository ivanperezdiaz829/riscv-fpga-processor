/* VIP flow control output of HDL template */
module alt_vipswi131_common_flow_control_output

	#(parameter BITS_PER_SYMBOL = 8,
		parameter SYMBOLS_PER_BEAT = 3,
		parameter WIDTH_DEFAULT = 16'd640,
		parameter HEIGHT_DEFAULT = 16'd480,
		parameter INTERLACED_DEFAULT = 4'd0)
		
	(	input		clk,
		input		rst,
	
		// interface to algorithm core
		input		[BITS_PER_SYMBOL * SYMBOLS_PER_BEAT - 1:0] data_out,
		input		[15:0] width_out,
		input		[15:0] height_out,
		input		[3:0] interlaced_out,
		input		vip_ctrl_valid_out,
		input		end_of_video_out,
		
		// interface to encoder
		input		dout_ready,
		output	dout_valid,
		output	[BITS_PER_SYMBOL * SYMBOLS_PER_BEAT - 1:0] dout_data,
		output	[15:0] encoder_width,
		output	[15:0] encoder_height,
		output	[3:0] encoder_interlaced,
		output	encoder_vip_ctrl_send,
		input		encoder_vip_ctrl_busy,
		output	encoder_end_of_video,
				
		// flow control signals
		input		write,
		output	stall_out
		);	
		
// conversion stall/write to ready/valid interface
assign dout_data = data_out;
assign encoder_end_of_video = end_of_video_out;
assign dout_valid = write;
assign stall_out = ~dout_ready;

reg [15:0] width_reg, height_reg;
reg [3:0] interlaced_reg;
reg vip_ctrl_valid_reg;

// encoder control signals
assign encoder_vip_ctrl_send = (vip_ctrl_valid_reg | vip_ctrl_valid_out) & ~encoder_vip_ctrl_busy;
assign encoder_width = vip_ctrl_valid_out ? width_out : width_reg;
assign encoder_height = vip_ctrl_valid_out ? height_out : height_reg;
assign encoder_interlaced = vip_ctrl_valid_out ? interlaced_out : interlaced_reg;

// connect control signals	
always @(posedge clk or posedge rst)
	if (rst) begin
		width_reg <= WIDTH_DEFAULT;
		height_reg <= HEIGHT_DEFAULT;
		interlaced_reg <= INTERLACED_DEFAULT;
		vip_ctrl_valid_reg <= 1'b0;
	end
	else begin
		width_reg <= encoder_width;
		height_reg <= encoder_height;
		interlaced_reg <= encoder_interlaced;
		if (vip_ctrl_valid_out | ~encoder_vip_ctrl_busy) begin
		   vip_ctrl_valid_reg <= vip_ctrl_valid_out & encoder_vip_ctrl_busy;
		end
	end	
	
endmodule
		
					
			
