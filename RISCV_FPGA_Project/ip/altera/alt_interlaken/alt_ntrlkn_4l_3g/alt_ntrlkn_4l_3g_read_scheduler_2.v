// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// baeckler - 01-29-2010

// Valid is up the most significant bit.
// e.g.  for width 4 up to 4'b1000 (8) words valid or fewer.

// take a stream of valid word counts and EOP positions and convert
// it to maximum width reads subject to hitting all of the packet boundaries
//
// dshih may 26, 2011; add arst to DCFIFO
// dshih aug 1, 2011: merge in read_scheduler_pre from cust_rel PR 07/26/2011

`timescale 1 ps / 1 ps

module read_scheduler_pre #(
	parameter VALID_WIDTH = 4
)(
	input clk,
	input arst,
	input ena,
	
	input [VALID_WIDTH-1:0] in_num_valid,
	input [VALID_WIDTH-1:0] in_eop_position, // 1 for MS word, 2,3... 8.   0 for no EOP
	output [VALID_WIDTH-1:0] out_num_valid,
	output [VALID_WIDTH-1:0] out_eop_position // 1 for MS word, 2,3... 8.   0 for no EOP
);

reg [VALID_WIDTH-1:0] next_num_valid = {(VALID_WIDTH){1'b0}};
reg [VALID_WIDTH-1:0] next_eop_pos = {(VALID_WIDTH){1'b0}};
reg [VALID_WIDTH-1:0] num_valid = {(VALID_WIDTH){1'b0}};
reg [VALID_WIDTH-1:0] eop_pos = {(VALID_WIDTH){1'b0}};
reg [VALID_WIDTH-1:0] last_num_valid = {(VALID_WIDTH){1'b0}};
reg [VALID_WIDTH-1:0] last_eop_pos = {(VALID_WIDTH){1'b0}};

always @(posedge clk or posedge arst) begin
   if (arst) begin
		next_num_valid 	       <= {(VALID_WIDTH){1'b0}};
		next_eop_pos 	       <= {(VALID_WIDTH){1'b0}};
		num_valid 	       <= {(VALID_WIDTH){1'b0}};
		eop_pos 	       <= {(VALID_WIDTH){1'b0}};
		last_num_valid 	       <= {(VALID_WIDTH){1'b0}};
		last_eop_pos 	       <= {(VALID_WIDTH){1'b0}};
	end
	else if (ena) begin
		///////////////////////////////
		// pass through by default
		
		next_num_valid 	       <= in_num_valid;
		next_eop_pos 	       <= in_eop_position;
		num_valid 	       <= next_num_valid;
		eop_pos 	       <= next_eop_pos;
		last_num_valid 	       <= num_valid;
		last_eop_pos 	       <= eop_pos;
		
		/////////////////////////////////////////
		// special treatment for poorly grouped data, 
		// we want to pull some of the "next" into current

		if(num_valid == 2'h1 && (~|eop_pos) && next_num_valid >= 2'h1 ) begin
		   last_num_valid <= 2'h2;
		   last_eop_pos   <= (next_eop_pos == 2'h1) ? 2'h2 : 2'h0;
		   num_valid      <= next_num_valid - 2'h1;
		   eop_pos        <= (next_eop_pos <= 2'h1) ? 2'h0 : next_eop_pos - 2'h1;	
		  	   
		end
		else if(num_valid == 2'h0 && (~|eop_pos) && next_num_valid == 2'h2 ) begin
		   last_num_valid <= 2'h2;
		   last_eop_pos   <= next_eop_pos;
		   num_valid      <= 2'h0;
		   eop_pos        <= 2'h0;	   
		end	   
		else if(num_valid < 2'h2 && (~|eop_pos) && next_eop_pos != 2'h0 && next_eop_pos <= (2'h2-num_valid)) begin
		   //EOP is upcoming and can be brought into current cycle
		   last_num_valid <= num_valid + next_eop_pos;
		   last_eop_pos <= (next_eop_pos == 2'h1) ? num_valid + 2'h1 : (next_eop_pos == 2'h2) ? num_valid + 2'h2: 2'h0;
		   num_valid <= next_num_valid - next_eop_pos;
		   eop_pos   <= 2'h0;
		   
		end
	   
	end
end

assign out_num_valid 	      = last_num_valid;
assign out_eop_position = last_eop_pos; // 1 for MS word, 2,3... 8.   0 for no EOP
endmodule



module alt_ntrlkn_4l_3g_read_scheduler_2 #(
	parameter VALID_WIDTH = 4
)
(
	input clk,
	input arst,
	output reg wr_wait = 1'b0,
	input [VALID_WIDTH-1:0] wr_num_valid,
	input [VALID_WIDTH-1:0] wr_eop_position,
        // 1 for MS word, 2,3... 8.   0 for no EOP

	output reg [VALID_WIDTH-1:0] rd_num_valid = {VALID_WIDTH{1'b0}}
);

////////////////////////////////////////
// pre filter to improve grouping for very high load

wire [VALID_WIDTH-1:0] i_wr_num_valid;
wire [VALID_WIDTH-1:0] i_wr_eop_position;
	
read_scheduler_pre rsp (
	.clk(clk),
	.arst(arst),
	.ena(!wr_wait),
	.in_num_valid(wr_num_valid),
	.in_eop_position(wr_eop_position), // 1 for MS word, 2,3... 8.   0 for no EOP
	.out_num_valid(i_wr_num_valid),
	.out_eop_position(i_wr_eop_position) // 1 for MS word, 2,3... 8.   0 for no EOP
);
defparam rsp .VALID_WIDTH = VALID_WIDTH;

///////////////////////////////////////

wire wr_contains_eop = |i_wr_eop_position;

// input sanity check
// synthesis translate off
always @(posedge clk) begin
	if (i_wr_num_valid[VALID_WIDTH-1]) begin
		if (|i_wr_num_valid[VALID_WIDTH-2:0]) begin
			$display ("Warning : too many valid input words to read schedule");
		end	
	end	
	if (i_wr_num_valid < i_wr_eop_position) begin
		$display ("Warning : illegal EOP info to read schedule");
	end
end
// synthesis translate on

/////////////////////////////////////////////////////////////////
// convert inbound counters into contributions to add to
// packets 0 and 1, ping pong.

reg [VALID_WIDTH-1:0] add_to_packet_0 = 0,add_to_packet_1 = 0;
reg active_packet = 1'b0, packet_0_complete = 1'b0, packet_1_complete = 1'b0;

always @(posedge clk or posedge arst) begin
	if (arst) begin
		packet_1_complete <= 1'b0;
		packet_0_complete <= 1'b0;
		add_to_packet_0 <= {VALID_WIDTH{1'b0}};
		add_to_packet_1 <= {VALID_WIDTH{1'b0}};
		active_packet <= 1'b0;	
	end
	else begin
		if (!wr_wait) begin
			packet_1_complete <= 1'b0;
			packet_0_complete <= 1'b0;
			add_to_packet_0 <= {VALID_WIDTH{1'b0}};
			add_to_packet_1 <= {VALID_WIDTH{1'b0}};

			if (active_packet) begin
				if (wr_contains_eop) begin
					add_to_packet_1 <= i_wr_eop_position;
					add_to_packet_0 <= i_wr_num_valid - i_wr_eop_position;
					packet_1_complete <= 1'b1;
					active_packet <= ~active_packet;
				end
				else begin
					add_to_packet_1 <= i_wr_num_valid;
				end
			end
			else begin
				if (wr_contains_eop) begin
					add_to_packet_0 <= i_wr_eop_position;
					add_to_packet_1 <= i_wr_num_valid - i_wr_eop_position;
					packet_0_complete <= 1'b1;
					active_packet <= ~active_packet;
				end
				else begin
					add_to_packet_0 <= i_wr_num_valid;
				end
			end
		end
	end
end

/////////////////////////////////////////////////////////////////
// tally contributions

reg [VALID_WIDTH-1:0] holding_0 = 0, holding_1 = 0;
reg holding_0_complete = 0, holding_1_complete = 0;

always @(posedge clk or posedge arst) begin
	if (arst) begin
		holding_0 <= {VALID_WIDTH{1'b0}};
		holding_1 <= {VALID_WIDTH{1'b0}};
		holding_0_complete <= 1'b0;
		holding_1_complete <= 1'b0;			
	end
	else begin
		if (!wr_wait) begin
			holding_0[VALID_WIDTH-1] <= 1'b0;
			holding_1[VALID_WIDTH-1] <= 1'b0;
			holding_0 <= (packet_1_complete ? {VALID_WIDTH{1'b0}} : holding_0[VALID_WIDTH-2:0]) + add_to_packet_0;
			holding_1 <= (packet_0_complete ? {VALID_WIDTH{1'b0}} : holding_1[VALID_WIDTH-2:0]) + add_to_packet_1;
			holding_0_complete <= packet_0_complete;
			holding_1_complete <= packet_1_complete;
		end
	end
end

/////////////////////////////////////////////////////////////////
// schedule reads to clear tally
// full width when available
// reduced width for completed packets

reg read_serving = 1'b0;

//reg wr_wait = 1'b0;

reg [VALID_WIDTH-1:0] rd_count = {VALID_WIDTH{1'b0}};
reg [VALID_WIDTH-2:0] owed_read = {(VALID_WIDTH-1){1'b0}};
reg rd_wait = 1'b0;

always @(posedge clk or posedge arst) begin
	if (arst) begin
		wr_wait <= 1'b0;
		rd_wait <= 1'b0;
		rd_count <= {VALID_WIDTH{1'b0}};
		read_serving <= 1'b0;
		owed_read <= {(VALID_WIDTH-1){1'b0}};
	end
	else begin
		wr_wait <= 1'b0;
		rd_wait <= 1'b0;
		rd_count <= {VALID_WIDTH{1'b0}};
		owed_read <= {(VALID_WIDTH-1){1'b0}};

        if (rd_wait) begin
			rd_count <= owed_read;
			read_serving <= ~read_serving;
		end
		else begin
			if (read_serving == 1'b0) begin
				// service channel 0
				if (holding_0_complete) begin
					if (holding_0[VALID_WIDTH-1]) begin
						// final full read
						rd_count[VALID_WIDTH-1] <= 1'b1;
						if (|holding_0[VALID_WIDTH-2:0]) begin
							// residue also needed
							owed_read <= holding_0[VALID_WIDTH-2:0];
							// Allin (9/3/2010): Fix for SPR 352425
							if ((|holding_1) | add_to_packet_1[VALID_WIDTH-1]) wr_wait <= 1'b1;
							rd_wait <= 1'b1;
						end
						else begin
							// no residue
							read_serving <= 1'b1;
						end
					end
					else begin
						// final residue
						rd_count[VALID_WIDTH-2:0] <= holding_0[VALID_WIDTH-2:0];
						read_serving <= 1'b1;
					end
				end
				else begin
					// continuing - read full if available
					rd_count[VALID_WIDTH-1] <= holding_0[VALID_WIDTH-1];
				end
			end
			else begin
				// service channel 1
				if (holding_1_complete) begin
					if (holding_1[VALID_WIDTH-1]) begin
						// final full read
						rd_count[VALID_WIDTH-1] <= 1'b1;
						if (|holding_1[VALID_WIDTH-2:0]) begin
							// residue also needed
							owed_read <= holding_1[VALID_WIDTH-2:0];
							// Allin (9/3/2010): Fix for SPR 352425 
							if ((|holding_0) | add_to_packet_0[VALID_WIDTH-1]) wr_wait <= 1'b1;
							rd_wait <= 1'b1;
						end
						else begin
							// no residue
							read_serving <= 1'b0;
						end
					end
					else begin
						// final residue
						rd_count[VALID_WIDTH-2:0] <= holding_1[VALID_WIDTH-2:0];
						read_serving <= 1'b0;
					end
				end
				else begin
					// continuing - read full if available
					rd_count[VALID_WIDTH-1] <= holding_1[VALID_WIDTH-1];
				end
			end
		end
	end
end


//reg rd_num_valid = 1'b0;

always @(posedge clk or posedge arst) begin
	if (arst) rd_num_valid <= {VALID_WIDTH{1'b0}};
	else rd_num_valid <= rd_count;
end

// synthesis translate off
always @(posedge clk) begin
	if (holding_0[VALID_WIDTH-1] & holding_1[VALID_WIDTH-1]) begin
		$display ("Warning - Error in read control at time %d",$time);
	end
end
// synthesis translate on

endmodule
