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


//============================================================================
// This confidential and proprietary software may be used only as authorized
// by a licensing agreement from ALTERA 
// copyright notice must be reproduced on all authorized copies.
//============================================================================
//

// Reconfig bundle wrapper

import mgmt_memory_map::*;
import alt_xcvr_reconfig_h::*;

`timescale 1ps/1ps
`define DESIGN_1G_10G 1

module sv_rcn_bundle
  #(
//  parameter ONEG_TENG_MODE = 0,       // use the 1g_10g roms/mifs 
    parameter PMA_RD_AFTER_WRITE = 1,
    parameter PLLS = 2,                 // can be #channel for 10G-only, 
                                        // can be 2x#channel for 1G_10G and KR
    parameter CHANNELS = 2,             // can be 1 for single channel, 2 for dual channel
    parameter MAP_PLLS = 1,             // remap logical channels to account for PLLs? (assuming one channel per xcvr instance)
    parameter SYNTH_1588_1G = 0,        // GigE data-path is not 1588-enabled 
    parameter SYNTH_1588_10G = 0,       // 10GBASE-R data-path is not 1588-enabled
    parameter KR_PHY_SYNTH_AN = 1,      // AN enabled
    parameter KR_PHY_SYNTH_LT = 1,      // LT enabled
    parameter KR_PHY_SYNTH_GIGE = 0,    // GigE not enabled              
    parameter PRI_RR = 0                // use round-robin priority in arbiter
    )
   (
    input wire 	     reconfig_clk,
    input wire 	     reconfig_reset,

    input wire [altera_xcvr_functions::get_custom_reconfig_from_width ("Stratix V","duplex",CHANNELS,PLLS,CHANNELS)-1:0] reconfig_from_xcvr,
    output wire [altera_xcvr_functions::get_custom_reconfig_to_width ("Stratix V","duplex",CHANNELS,PLLS,CHANNELS)-1:0] reconfig_to_xcvr,
    output wire      reconfig_mgmt_busy, // reconfig is busy

    input wire  [CHANNELS*6-1:0]  seq_pcs_mode,
    input wire  [CHANNELS*6-1:0]  seq_pma_vod,
    input wire  [CHANNELS*5-1:0]  seq_pma_postap1,
    input wire  [CHANNELS*4-1:0]  seq_pma_pretap,
    input wire  [CHANNELS-1:0]    seq_start_rc, 
    input wire  [CHANNELS-1:0]    lt_start_rc,
    input wire  [CHANNELS*3-1:0]  tap_to_upd,   
    output wire [CHANNELS-1:0]     hdsk_rc_busy, // reconfig is busy 
    output wire [CHANNELS-1:0]     baser_ll_mif_done

    );


   wire [6:0] 		     reconfig_mgmt_address;

   wire 		     reconfig_mgmt_read;
   wire 		     reconfig_mgmt_read_int;
   wire [31:0] 		     reconfig_mgmt_readdata;
   wire [31:0] 		     reconfig_mgmt_readdata_phy;
   wire 		     reconfig_mgmt_waitrequest;
   wire  		     reconfig_mgmt_write, kr_mmap_write;
   wire                      av_write_int;
   wire [31:0] 		     reconfig_mgmt_writedata;
   wire [31:0] 		     writedata;
   
   wire [31:0] 		     reconfig_mif_address;   
   wire 		     reconfig_mif_read;
   reg 			     reconfig_mif_waitrequest;
   reg  [15:0]               reconfig_mif_readdata;
   wire [15:0] 		     reconfig_ll_mif_readdata, reconfig_baser_mif_readdata;
   wire [15:0] 		     reconfig_gige_mif_readdata; 
   wire [15:0] 		     reconfig_1588_baser_mif_readdata, reconfig_1588_gige_mif_readdata; 
   wire [15:0]               reconfig_non1588_baser_mif_readdata, reconfig_non1588_gige_mif_readdata; 
   
   wire [5:0] 		     seq_pcs_mode_ch;
   wire [CHANNELS*6-1:0] pma_vod_out;
   wire [CHANNELS*5-1:0] pma_postap1_out;
   wire [CHANNELS*4-1:0] pma_pretap_out;

   wire                      rc_pma_vod_wr_done;
   wire                      rc_pma_postap1_wr_done;
   wire                      rc_pma_pretap1_wr_done;
   wire                      rc_pma_vod_rd_done;
   wire                      rc_pma_wr_mode;
   wire                      rc_pma_rd_mode;
   wire                      hdsk_rc_busy_wr;
   reg  		     verify_pma_write;
   wire                      pma_write_done;

   // Port changes for third channel
   wire     	             mgmt_kr_mmap_wr_sel;       
   wire     	             mgmt_kr_mmap_rd_sel;       
   wire     	             mgmt_hdsk_rc_busy_rd;            
   wire     	             mgmt_pma_write_done;       
   wire     	             mgmt_rc_pma_vod_rd_done;   
   wire     	             mgmt_rc_pma_rd_mode;       
   wire     	             mgmt_rc_pma_wr_mode;       
   wire     	             mgmt_hdsk_rc_busy_wr;      
   wire     	             rc_mgmt_busy;      
   wire     	             mgmt_baser_ll_mif_done;   
   wire		             mgmt_verify_pma_write;
   wire		             mgmt_lt_start_rc;
   wire		             mgmt_seq_start_rc;
   wire [2:0]                mgmt_tap_to_upd; 
 

   wire [31:0] 		     kr_mmap_readdata;
   wire [31:0]  reconfig_mgmt_writedata_to_rom ;
  
   localparam                WIDTH_2PLL = altera_xcvr_functions::clogb2(CHANNELS*3) ; 
   localparam                WIDTH_1PLL = altera_xcvr_functions::clogb2(CHANNELS*2) ; 
   localparam                WIDTH_CH   = altera_xcvr_functions::clogb2(CHANNELS-1) ; 
   wire [CHANNELS*WIDTH_2PLL-1:0]               LCH_mapped_2PLL;  
   wire [CHANNELS*WIDTH_1PLL-1:0]               LCH_mapped_1PLL;  
   wire [WIDTH_CH-1:0]                          rcfg_chan_select; 
   wire [CHANNELS-1:0]                          chan_select_1hot;   
//============================================================================
// reconfig controller
//============================================================================
alt_xcvr_reconfig #(
  .device_family                 ("Stratix V"),
  .number_of_reconfig_interfaces (CHANNELS+PLLS),
  .enable_offset                 (1),
  .enable_dcd                    (0),
  .enable_lc                     (1),
  .enable_analog                 (1),
  .enable_eyemon                 (0),
  .enable_dfe                    (0),
  .enable_adce                   (0),
  .enable_mif                    (1),
  .enable_pll                    (1)
  ) reconfig_ctrl (
  .reconfig_busy             (reconfig_mgmt_busy),
  .mgmt_clk_clk              (reconfig_clk),
  .mgmt_rst_reset            (reconfig_reset),

  .reconfig_mgmt_address     (reconfig_mgmt_address),
  .reconfig_mgmt_read        (reconfig_mgmt_read),
  .reconfig_mgmt_readdata    (reconfig_mgmt_readdata_phy),
  .reconfig_mgmt_waitrequest (reconfig_mgmt_waitrequest),
  .reconfig_mgmt_write       (reconfig_mgmt_write),
  .reconfig_mgmt_writedata   (reconfig_mgmt_writedata_to_rom),

  .reconfig_mif_address      (reconfig_mif_address),
  .reconfig_mif_read         (reconfig_mif_read),
  .reconfig_mif_readdata     (reconfig_mif_readdata),
  .reconfig_mif_waitrequest  (reconfig_mif_waitrequest),

  .reconfig_to_xcvr          (reconfig_to_xcvr),
  .reconfig_from_xcvr        (reconfig_from_xcvr)
);

//============================================================================
// Instantiate arbiter here. Arbiter will make request to mgmt master 
//============================================================================

arbiter #(
 .CHANNELS (CHANNELS),
 .PRI_RR   (PRI_RR)
) arbiter_inst  (
  .clk               (reconfig_clk       ),             
  .reset             (reconfig_reset     ),
  .lt_start_rc       (lt_start_rc        ),  // 1 per channel, synchronous with clk
  .seq_start_rc      (seq_start_rc       ),  // 1 per channel, synchronous with clk
  .seq_pcs_mode      (seq_pcs_mode       ),  // 1 per channel, synchronous with clk
  .hdsk_rc_busy      (hdsk_rc_busy       ),  // 1 per channel, synchronous with clk
 //rcfg_busy         (rc_mgmt_busy       ),  // reconfig_busy from controller
  .rcfg_busy         (rc_mgmt_busy       ),  // reconfig_busy from mgmt master
  .rcfg_lt_start_rc  (mgmt_lt_start_rc   ),   // pma reconfig request to mgmt_master
  .rcfg_seq_start_rc (mgmt_seq_start_rc  ),  // pcs reconfig request to mgmt_master
  .rcfg_chan_select  (rcfg_chan_select   )   // current selected channel
);
// cannot connect reconfig_busy from RC directly as during PMA RC, busy might toggle saying false complete to aribter
// convert rcfg_chan_select from arbiter to 1 hot
assign chan_select_1hot = {{(CHANNELS-1){1'b0}},1'b1} << rcfg_chan_select ;
// current seq_pcs_mode, hdsk_busy
assign seq_pcs_mode_ch = seq_pcs_mode[rcfg_chan_select*6+:6];
// busy from mgmt_prog
assign rc_mgmt_busy = mgmt_hdsk_rc_busy_rd | mgmt_hdsk_rc_busy_wr ; 
//============================================================================
// Instantiate the mgmt master program control
// Need to have the program in the file mgmt_program_mif.sv
//============================================================================
   // added to get rid of connections warning
   wire [30:7] 		     debug2;
   
   wire [12:0] 		     pio_in; 
   wire [11:0] 		     pio_out_int;
  

assign  mgmt_verify_pma_write = verify_pma_write ;
assign  mgmt_tap_to_upd       = tap_to_upd[rcfg_chan_select*3 +:3] ; 
   assign pio_in = {
		    mgmt_tap_to_upd,      //6,5,4
		    mgmt_verify_pma_write,//3
		    mgmt_lt_start_rc,     //2 
		    mgmt_seq_start_rc,    //1 
		    reconfig_mgmt_busy    //0
		    };
   
   assign {
	   mgmt_kr_mmap_wr_sel,        // 8 
	   mgmt_kr_mmap_rd_sel,        // 7 
	   mgmt_hdsk_rc_busy_rd,       // 6       
	   mgmt_pma_write_done,        // 5 
	   mgmt_rc_pma_vod_rd_done,    // 4 
	   mgmt_rc_pma_rd_mode,        // 3
	   mgmt_rc_pma_wr_mode,        // 2 
	   mgmt_hdsk_rc_busy_wr,       // 1 
	   mgmt_baser_ll_mif_done      // 0
	   }  =  pio_out_int;
assign pma_write_done         = mgmt_pma_write_done;
assign baser_ll_mif_done      = {CHANNELS{mgmt_baser_ll_mif_done}}  & chan_select_1hot ;        


   always_comb
     begin
	if( PMA_RD_AFTER_WRITE == 1 && pma_write_done)
	  verify_pma_write = 1'b1;
	else
	  verify_pma_write = 1'b0;
     end


mgmt_master
     #( 
	.CLOCKS_PER_SECOND(125000000),  // Used for time calculations
	.PIO_OUT_SIZE(9),               // Width of PIO output port
	.PIO_IN_SIZE(7),                // Width of PIO input port 
	.ROM_DEPTH(512)                // Depth of command ROM
	) master_program_mif 
       (
	.clk                     (reconfig_clk),
	.reset                   (reconfig_reset),
	.av_write                (av_write_int),
	.av_read                 (reconfig_mgmt_read),
	.av_address              ({debug2,reconfig_mgmt_address}),
	.av_writedata            (writedata),
	.av_readdata             (reconfig_mgmt_readdata),
	.av_waitrequest          (reconfig_mgmt_waitrequest),
	.pio_out                 (pio_out_int),
	.pio_in                  (pio_in)
	);
`undef MGMT_PROGRAM_TASK

/// override writedata from mgmt program when address is for logical ch no. 
// mapping between LCH and CH Select here - for 2 PLLs (when both 1G and 10G enabled)
genvar lch ;
generate
  for (lch=0; lch<CHANNELS;lch=lch+1) begin : LCH_MAPPING
  assign LCH_mapped_2PLL[lch*WIDTH_2PLL+:WIDTH_2PLL] = MAP_PLLS ? lch*3 : lch;
  assign LCH_mapped_1PLL[lch*WIDTH_1PLL+:WIDTH_1PLL] = MAP_PLLS ? lch*2 : lch;
  end
endgenerate  

generate
  if (KR_PHY_SYNTH_GIGE) begin: GIGE_RECONF_CH
  assign  reconfig_mgmt_writedata[WIDTH_2PLL-1:0] = (({debug2,reconfig_mgmt_address}==ADDR_XR_ANALOG_LCH ) || ({debug2,reconfig_mgmt_address}== LOCAL_ADDR_XR_MIF_LCH)) ? 
                                                    LCH_mapped_2PLL[(rcfg_chan_select*WIDTH_2PLL)+:WIDTH_2PLL] : writedata[WIDTH_2PLL-1:0]; 
  assign  reconfig_mgmt_writedata[31:WIDTH_2PLL]  = writedata[31:WIDTH_2PLL];
  end
  else begin : TENG_RECONF_CH
  assign reconfig_mgmt_writedata[WIDTH_1PLL-1:0] = (({debug2,reconfig_mgmt_address}==ADDR_XR_ANALOG_LCH ) || ({debug2,reconfig_mgmt_address}== LOCAL_ADDR_XR_MIF_LCH)) ?
                                                   LCH_mapped_1PLL[(rcfg_chan_select*WIDTH_1PLL)+:WIDTH_1PLL] :  writedata[WIDTH_1PLL-1:0]; 
  assign reconfig_mgmt_writedata[31:WIDTH_1PLL]  = writedata[31:WIDTH_1PLL];
  end
endgenerate 

/// override base address of MIF file reconfig controller - depending upon pcs_mode
///MIF is arranged in following way
///0   - 163 - 10G MIF 
///164 - 327 - 1G MIF       (A4)
///328 - 491 - LL MIF       (148)
///492 - 655 - 10G 1588 MIF (1EC)
///656 - 819 - 1G 1588 MIF  (290) 
///820 - 983 - FEC LL MIF --(334) this is not done yet
assign reconfig_mgmt_writedata_to_rom[10:1] = ((reconfig_mgmt_writedata[15]) && ({debug2,reconfig_mgmt_address}==LOCAL_ADDR_XR_MIF_DATA)&& (seq_pcs_mode_ch==8) && !SYNTH_1588_1G )  ? 10'hA4 : // 1G non 1588
                                              ((reconfig_mgmt_writedata[15]) && ({debug2,reconfig_mgmt_address}==LOCAL_ADDR_XR_MIF_DATA)&& (|seq_pcs_mode_ch[1:0]) && !SYNTH_1588_1G)? 10'h148: // LL
				              ((reconfig_mgmt_writedata[15]) && ({debug2,reconfig_mgmt_address}==LOCAL_ADDR_XR_MIF_DATA)&& (seq_pcs_mode_ch==4) && SYNTH_1588_10G )  ? 10'h1EC: // 10G 1588
				              ((reconfig_mgmt_writedata[15]) && ({debug2,reconfig_mgmt_address}==LOCAL_ADDR_XR_MIF_DATA)&& (seq_pcs_mode_ch==8) && SYNTH_1588_1G)    ? 10'h290: // 1G 1588
				              ((reconfig_mgmt_writedata[15]) && ({debug2,reconfig_mgmt_address}==LOCAL_ADDR_XR_MIF_DATA)&& (seq_pcs_mode_ch==32)                )    ? 10'h334: // FEC-LL mode
				              reconfig_mgmt_writedata[10:1] ;                                                                                       //default 10G-non 1588    
assign 	reconfig_mgmt_writedata_to_rom[31:11] =	reconfig_mgmt_writedata[31:11] ;
assign 	reconfig_mgmt_writedata_to_rom[0]     =	reconfig_mgmt_writedata[0] ;


   sv_10g_kr_avalon_analog_mmap # (
      .CHANNELS (CHANNELS)
     ) sv_10g_kr_avalon_analog_mmap_inst (
      .clk(reconfig_clk),
      .reset(reconfig_reset),
      .av_address(reconfig_mgmt_address),
      .av_readdata(kr_mmap_readdata),
      .av_write(kr_mmap_write),
      .av_writedata(reconfig_mgmt_writedata_to_rom),
      .av_read(reconfig_mgmt_read),
      
      .pma_vod(seq_pma_vod),
      .pma_postap1(seq_pma_postap1),
      .pma_pretap1(seq_pma_pretap),
         
      .pma_vod_out(pma_vod_out),
      .pma_postap1_out(pma_postap1_out),
      .pma_pretap1_out(pma_pretap_out),

      .rcfg_chan_select (rcfg_chan_select)
      );

   // Mux to selece the avalon interface
   assign reconfig_mgmt_readdata      = mgmt_kr_mmap_rd_sel ? kr_mmap_readdata : reconfig_mgmt_readdata_phy;
   assign kr_mmap_write               = mgmt_kr_mmap_wr_sel ? av_write_int     : 1'b0;
   assign reconfig_mgmt_write         = mgmt_kr_mmap_wr_sel ? 1'b0             : av_write_int;



       rom_all_modes all_modes_mif_rom (
       .address(reconfig_mif_address[10:1]),
       .clock(reconfig_clk),
       .q(reconfig_mif_readdata)
       );

    // reg mif_read_q;
   always_ff @(posedge reconfig_clk) 
     begin
	reconfig_mif_waitrequest <= ~(reconfig_mif_read);
     end

	   
endmodule // sv_rc_bundle

    
module sv_10g_kr_avalon_analog_mmap
  #(
    parameter ADDR_WIDTH = 5,
    parameter CHANNELS = 12,
    parameter WIDTH_CH = altera_xcvr_functions::clogb2(CHANNELS-1)
    )
   (
    input wire 			clk,
    input wire 			reset,
    
   // Avalon interface
    input wire [ADDR_WIDTH-1:0] av_address,
    input wire 			av_write,
    input wire 			av_read,
    input wire [31:0] 		av_writedata,
    output reg [31:0] 		av_readdata,

    input wire [CHANNELS*6-1:0]	pma_vod,
    input wire [CHANNELS*5-1:0]	pma_postap1,
    input wire [CHANNELS*4-1:0]	pma_pretap1,
    output reg [CHANNELS*6-1:0]	pma_vod_out,
    output reg [CHANNELS*5-1:0]	pma_postap1_out,
    output reg [CHANNELS*4-1:0]	pma_pretap1_out,
    input wire [WIDTH_CH-1:0]  rcfg_chan_select 
   );
 
  wire [5:0] av_readdata_vod,av_readdata_post,av_readdata_pre;

     // need to encode the pre-tap values as the reconfig_controller un-encodes them
   // see table 16-11 in the reconfig cruontroller user guide for details
   function [3:0] enc_pre;
     input [3:0] pre_tap;
     begin
       case (pre_tap)
       4'b0000:  enc_pre = 4'b0000;
       4'b0001:  enc_pre = 4'b1111;
       4'b0010:  enc_pre = 4'b1110;
       4'b0011:  enc_pre = 4'b1101;
       4'b0100:  enc_pre = 4'b1100;
       4'b0101:  enc_pre = 4'b1011;
       4'b0110:  enc_pre = 4'b1010;
       4'b0111:  enc_pre = 4'b1001;
       4'b1000:  enc_pre = 4'b1000;
       4'b1001:  enc_pre = 4'b0111;
       4'b1010:  enc_pre = 4'b0110;
       4'b1011:  enc_pre = 4'b0101;
       4'b1100:  enc_pre = 4'b0100;
       4'b1101:  enc_pre = 4'b0011;
       4'b1110:  enc_pre = 4'b0010;
       4'b1111:  enc_pre = 4'b0001;
       default:  enc_pre = 4'b0000;
       endcase
     end
   endfunction

  assign av_readdata_vod  =  pma_vod[rcfg_chan_select*6+:6]; 
  assign av_readdata_post =  {1'd0,pma_postap1[rcfg_chan_select*5+:5]};
  assign av_readdata_pre  =  {2'd0,enc_pre(pma_pretap1[rcfg_chan_select*4+:4])};
 
  always_comb 
    begin
      if (av_read)
         case (av_address)
	 5'b00000  : av_readdata[5:0] = av_readdata_vod ;	 
	 5'b00001  : av_readdata[5:0] = av_readdata_post;	 
	 5'b00010  : av_readdata[5:0] = av_readdata_pre;	 
	 default : av_readdata[5:0] = 6'd0;
	  endcase // case (av_address[2:0])
	else
	  av_readdata[5:0] = 6'd0;
     end // always_comb
   always_comb
   av_readdata [31:6] = 26'd0 ; 	   
    
   
   always @(posedge clk or posedge reset)
     // write
     begin
	if(reset) begin
	   pma_vod_out <= 0;
	   pma_postap1_out <= 0;
	   pma_pretap1_out <= 0;
	end
	else if(av_write) begin
	   case(av_address)
		   5'b00011  : pma_vod_out[rcfg_chan_select*6+:6]     <= av_writedata[5:0];
		   5'b00100  : pma_postap1_out[rcfg_chan_select*5+:5] <= av_writedata[4:0]; 
		   5'b00101  : pma_pretap1_out[rcfg_chan_select*4+:4] <= av_writedata[3:0]; 
		   default : ;
	   endcase
     end
/*  	 case({mgmt_select_ch2, mgmt_select_ch1, mgmt_select_ch0, av_address})
	    8'b001_00000:              pma_vod_out         <= av_writedata[5:0];
	    8'b001_00001:              pma_postap1_out     <= av_writedata[4:0];
	    8'b001_00010:              pma_pretap1_out     <= av_writedata[3:0];
	    8'b010_00000:              ch1_pma_vod_out     <= av_writedata[5:0];
	    8'b010_00001:              ch1_pma_postap1_out <= av_writedata[4:0];
	    8'b010_00010:              ch1_pma_pretap1_out <= av_writedata[3:0];
	    8'b100_00000:              ch2_pma_vod_out     <= av_writedata[5:0];
	    8'b100_00001:              ch2_pma_postap1_out <= av_writedata[4:0];
	    8'b100_00010:              ch2_pma_pretap1_out <= av_writedata[3:0];
	    default:;
	 endcase // case ({mgmt_select_ch2, mgmt_select_ch1, mgmt_select_ch0, av_address})	*/
     end // always @ (posedge clk)
endmodule // sv_10g_kr_avalon_analog_mmap
