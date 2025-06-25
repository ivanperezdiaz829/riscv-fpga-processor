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


`timescale 1 ps / 1 ps

module altera_xcvr_detlatency_wordalign #(
    parameter wa_mode             = "deterministic_latency", //"manual", "deterministic_latency"
    parameter full_data_width     = 80,
    parameter dwidth_size         = 7,
    parameter boundary_width      = 7,
    parameter pattern_detect      = 10'h17C,
    parameter pattern_detect_size = 10
) (
    input                    clk,
    input                    rst,
    input       [dwidth_size-1:0]           data_width,
    input       [full_data_width-1:0]       datain,
    input                                   encdt,
    output reg  [boundary_width-1:0]        rx_boundary_sel,
    output wire                             boundary_slip,
    output reg  [full_data_width-1:0]       dataout,
    output wire                             sync_status,
    output reg  [full_data_width/10-1:0]    pat_detect
);

	localparam PAT_SEARCH  = 1'b0;
	localparam RETAIN      = 1'b1;
	localparam STATE_WIDTH = 1;

  wire [pattern_detect_size-1:0] npattern_detect;

  reg    [full_data_width-1:0] din_r0;
  reg    [full_data_width-1:0] din_r1;
  reg    [full_data_width-1:0] din_r2;
  wire [full_data_width+pattern_detect_size-2:0] dw_data_20;
  wire [full_data_width+pattern_detect_size-2:0] dw_data_80;
  reg [full_data_width+pattern_detect_size-2:0] dw_data;
  wire [2*full_data_width-1:0] dw_data_out_20;
  wire [2*full_data_width-1:0] dw_data_out_80;
  reg [2*full_data_width-1:0] dw_data_out;
  wire   [full_data_width-1:0] dataout_w;
  reg                    [2:0] encdt_r;               
  wire                         encdt_rise;
  reg                          found;  
  wire                         goto_retain;
  reg     [boundary_width-1:0] sel;
  reg     [boundary_width-1:0] boundary_loc_r;
  reg                          sync_status_manual_r;
  wire                         sync_status_dlsm;
	reg                    [7:0] pat_detect_w;
  wire       [dwidth_size-1:0] sync_data_width;
	reg                          sync_status_manual_int;

  reg    [STATE_WIDTH-1:0] cs;
  reg    [STATE_WIDTH-1:0] ns;

	assign dw_data_20      = {60'b0,din_r0[pattern_detect_size-2:0],din_r1[19:0]};//form the double width data for the 20b width from PMA
	assign dw_data_out_20  = {120'b0,din_r1[19:0],din_r2[19:0]};//form the double width data for the 20b width from PMA
	assign dw_data_80      = {din_r0[pattern_detect_size-2:0],din_r1[79:0]};//form the double width data for the 80b width from PMA
	assign dw_data_out_80  = {din_r1[79:0],din_r2[79:0]};//form the double width data for the 80b width from PMA
	
	assign dataout_w       = (rx_boundary_sel<sync_data_width)? dw_data_out[rx_boundary_sel +: full_data_width] : dw_data_out[0 +: full_data_width];
	assign encdt_rise      = encdt_r[0] & ~encdt_r[2];
	assign npattern_detect = ~pattern_detect;
  assign goto_retain     = (wa_mode=="manual")? found: sync_status_dlsm;
  assign sync_status     = (wa_mode=="manual")? sync_status_manual_r: sync_status_dlsm;
	
  always @ (posedge clk or posedge rst)
  begin
    if (rst)
    begin
      din_r0           <= {full_data_width{1'b0}};
      din_r1           <= {full_data_width{1'b0}};
      din_r2           <= {full_data_width{1'b0}};
      encdt_r          <= 3'b0;
      dataout          <= {full_data_width{1'b0}};
      cs         			 <= PAT_SEARCH;
	    boundary_loc_r   <= 7'h7F;
	    rx_boundary_sel  <= 7'h0;
      pat_detect 			 <= {full_data_width/10{1'b0}};
      sync_status_manual_r <= 1'b0;
      dw_data <= {(full_data_width){1'b0}};
      dw_data_out <= {(2*full_data_width){1'b0}};
    end
    else
    begin
      din_r0           <= datain;
      din_r1           <= din_r0;
      din_r2           <= din_r1;
      encdt_r          <= {encdt_r[1],encdt_r[0],encdt};
      dataout          <= dataout_w;
    	cs 							 <= ns;
      boundary_loc_r   <= sel;
	    rx_boundary_sel  <= (cs==PAT_SEARCH && ~&sel)? sel : rx_boundary_sel;
      pat_detect 			 <= pat_detect_w;
      sync_status_manual_r <= sync_status_manual_int;
      dw_data         <= (sync_data_width==7'd80)?dw_data_80:dw_data_20;//to select the data from 20b width or 80b width
      dw_data_out    <= (sync_data_width==7'd80)?dw_data_out_80:dw_data_out_20;//to select the data from 20b width or 80b width
    end
  end

  always @ (*)
  begin
    case (cs)
      PAT_SEARCH: begin 	
                          ns = (goto_retain && !encdt_rise)? RETAIN : PAT_SEARCH;
                 					sync_status_manual_int = 1'b0;
                 	end
                 
      RETAIN: 		begin 	
                 					ns = (encdt_rise)? PAT_SEARCH : RETAIN;
                 					sync_status_manual_int = 1'b1;
                 	end
      default: ns = PAT_SEARCH;
    endcase
  end


  integer i;
	always @(*)
	begin
	  sel=7'h7F;
	  found=1'b0;
	  for (i=(full_data_width-1);i>=0;i=i-1)
	  begin : match_int
	    if ( (dw_data[i +: pattern_detect_size]==pattern_detect) || (dw_data[i +: pattern_detect_size]==npattern_detect) ) 
	    begin
	    	sel=i[6:0];
	    	found=1'b1;
	    end
	  end
  end

  integer j;
	always @(*)
	begin
	  pat_detect_w={full_data_width/10{1'b0}};
	  for (j=0;j<full_data_width;j=j+10)
	  begin : patdet_int
	    if ( (dataout_w[j +: pattern_detect_size]==pattern_detect) || (dataout_w[j +: pattern_detect_size]==npattern_detect) ) 
	    begin
	    	pat_detect_w[j/10]=1'b1;
	    end
	  end
  end
  
    altera_xcvr_detlatency_synchronizer
    #(
        .width (dwidth_size),
        .stages(2)
    )sync_data_width_wa_inst(
        .clk(clk),
        .rst(rst),
        .dat_in(data_width),
        .dat_out(sync_data_width)
    );

	generate
		if (wa_mode == "deterministic_latency" )
		begin : dl_sm

          altera_xcvr_detlatency_wa_dlsm #(
            .dwidth_size ( dwidth_size )
          ) det_latecny_sm_int(
            .data_width              (sync_data_width        ),
            .rcvd_clk                (clk                    ),
            .soft_reset              (rst                    ),
            .encdt_rse               (encdt_rise           ),
            .boundary_loc            (boundary_loc_r         ),
            .rslip_separation        (10'd3                  ), //based on RBC setting
            .rassert_sync_status_imm (1'b0                   ), //based on RBC setting
            .sync_status             (sync_status_dlsm ),
            .boundary_slip           (boundary_slip          ),
            .toggle_number           (                       ),
            .current_state           (                       )
          );  
		end
		else
		begin : no_dl_sm
		  assign sync_status_dlsm = 1'b0;
		  assign boundary_slip = 1'b0;
		end
	endgenerate

endmodule