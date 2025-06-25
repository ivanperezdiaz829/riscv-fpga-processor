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



/////////////////////////////////////////////////////////////////////////////
// baeckler - 09-09-2011
// Interlaken multi-lane IO with built in resets/reconfig/alignment/management/debug

`timescale 1 ps / 1 ps

import altera_xcvr_functions::*;

module ilk_pcs_assembly #(
   parameter USE_ATX               = 1,
   parameter DATA_RATE             = "10312.5 Mbps",
   parameter PLL_OUT_FREQ          = "5156.25 MHz", // CAREFUL!! : this is MHz, not MBPS, typically 1/2 data rate
   parameter PLL_REFCLK_FREQ = "322.265625 MHz",
   parameter INT_TX_CLK_DIV        = 1,             // CGB TX clock divider, typically 1
   parameter SCRAM_CONST           = 58'hdeadbeef123,
   parameter METALEN               = 2048,          // suggested minimum 128, legal max 8191 (1 less than 8K)
   parameter CNTR_BITS             =   20,          // reset delay.  Set 6 for fast simulation reset, 20 for regular operation
   parameter INCLUDE_TEMP_SENSE    = 1'b1,

   // management clock range is restricted to 75 to 125 MHz by hard logic
   parameter MM_CLK_KHZ            = 20'd100000,
   parameter MM_CLK_MHZ            = 28'd100000000,

   // CAUTION - these must correspond to the pin placement used in place and route
   // for all of the DPRIO and reconfig to function properly'

   parameter LANE_PROFILE = 24'b000000_111111_111111_000000,
   parameter NUM_LANES             =  12,
   parameter NUM_SIXPACKS          =  1,

   // sim debug messages
   parameter DEBUG_CMDS            = 1'b1,  // commands and reply regs
   parameter DEBUG_DPRIO           = 1'b1,  // periphery regs

   // do not override
   parameter BITS_PER_LANE         = 64,

   parameter MAX_LANES_PER_SIXPACK =  6,    // duh
   parameter MAX_NUM_SIXPACKS      =  4,
   parameter MAX_NUM_LANES         = MAX_NUM_SIXPACKS * MAX_LANES_PER_SIXPACK,
   parameter W_BUNDLE_TO_XCVR      = 70,
   parameter W_BUNDLE_FROM_XCVR    = 46,
   parameter DIAG_ON               = 0
)(
   input                                         pll_ref_clk,
   // config and status port
   input                                         mm_clk,            // 100 MHz
   input mm_clk_locked, // loss of lock restarts GX / CPU reset sequence
   input                                         mm_read,
   input                                         mm_write,
   input                                  [15:0] mm_addr,
   output reg                             [31:0] mm_rdata,
   output reg                                    mm_rdata_valid,
   input                                  [31:0] mm_wdata,

   // chip HSIO pins
   input                         [NUM_LANES-1:0] rx_pin,
   output                        [NUM_LANES-1:0] tx_pin,

   // data streams, msb first on the wire
   output                                        clk_tx_common,
   output                                        srst_tx_common,
   input           [NUM_LANES*BITS_PER_LANE-1:0] tx_din,
   input                         [NUM_LANES-1:0] tx_control,
   input                                         tx_valid,
   output reg                                    tx_cadence,

   output                                        clk_rx_common,
   output                                        srst_rx_common,
   output                                        tx_lanes_aligned,
   output                                        tx_pcsfifo_pempty,
   output                                        rx_lanes_aligned,
   output reg      [NUM_LANES*BITS_PER_LANE-1:0] rx_dout,
   output                        [NUM_LANES-1:0] rx_control,
   output                        [NUM_LANES-1:0] rx_wordlock,
   output                        [NUM_LANES-1:0] rx_metalock,
   output                        [NUM_LANES-1:0] rx_crc32err,
   output                        [NUM_LANES-1:0] rx_sh_err,
   output reg                    [NUM_LANES-1:0] rx_valid,          // these should all be the same when operating normally
   input        [W_BUNDLE_TO_XCVR*(NUM_LANES+NUM_SIXPACKS)-1:0] reconfig_to_xcvr,
   output     [W_BUNDLE_FROM_XCVR*(NUM_LANES+NUM_SIXPACKS)-1:0] reconfig_from_xcvr
);

   localparam MAX_NUM_TRIPLETS = MAX_NUM_SIXPACKS * 2;
   function integer count_ones;
      input integer val;
      begin
         count_ones = 0;
         while (val > 0) begin
            count_ones = count_ones + val[0];
            val = val >> 1;
         end
      end
   endfunction

   function integer count_sixpacks;
      input integer val;
      begin
         count_sixpacks = 0;
         while (val > 0) begin
            count_sixpacks = count_sixpacks + |val[5:0];
            val = val >> 6;
         end
      end
   endfunction

   //////////////////////////////////////////////
   // common wires
   //////////////////////////////////////////////
   wire [NUM_LANES-1:0] tx_clkout;
   wire [NUM_LANES-1:0] rx_clkout;

   // we want these to go through an LCELL to become internal
   // global clock lines.
   wire tx_common_ena = 1'b1 /* synthesis keep */;
   wire rx_common_ena = 1'b1 /* synthesis keep */;
   wire tx_common     = tx_clkout [NUM_LANES >> 1'b1] & tx_common_ena /* synthesis keep */;
   wire rx_common     = rx_clkout [NUM_LANES >> 1'b1] & rx_common_ena /* synthesis keep */;

   assign clk_tx_common = tx_common;
   assign clk_rx_common = rx_common;

   wire [MAX_NUM_SIXPACKS-1:0] pll_locked, all_pll_locked;
   wire    [NUM_LANES-1:0] rx_is_lockedtodata;
   wire    [NUM_LANES-1:0] rx_crc32err_pcs;


   reg [NUM_LANES-1:0] loopback = {NUM_LANES{1'b0}} /* synthesis preserve */;
   reg [NUM_LANES-1:0] tx_crc32err_inject = {NUM_LANES{1'b0}};
   wire [NUM_LANES-1:0] tx_crc32err_inject_s_txc;

   //////////////////////////////////////////////
   // clock monitors
   //////////////////////////////////////////////
   wire [19:0] pll_ref_khz,rx_khz, tx_khz;
   generate
      if( DIAG_ON != 0 ) begin : diag_fm
         ilk_frequency_monitor fm (
            .signal       ({pll_ref_clk,rx_common,tx_common}),
            .ref_clk      (mm_clk),
            .khz_counters ({pll_ref_khz,rx_khz,tx_khz})
         );
         defparam fm .NUM_SIGNALS = 3;
         defparam fm .REF_KHZ     = MM_CLK_KHZ;
      end
      else begin
        assign pll_ref_khz = 20'b0;
        assign rx_khz = 20'b0;
        assign tx_khz = 20'b0;
      end
   endgenerate

   reg [27:0] cntr0;
   reg [23:0] sec_cntr;
   wire system_reset;
   always @(posedge mm_clk or posedge system_reset) begin
      if (system_reset) begin
         cntr0    <= 0;
         sec_cntr <= 0;
      end else begin
         if (cntr0 == MM_CLK_MHZ -1) begin
            sec_cntr <= sec_cntr + 1'b1;
            cntr0    <= 0;
         end
         else begin
            cntr0 <= cntr0 + 1'b1;
         end
      end
   end

   //////////////////////////////////////////////
   // temp sense diode
   //////////////////////////////////////////////
   wire [7:0] degrees_f;
   wire [7:0] degrees_c;
   generate
      if (INCLUDE_TEMP_SENSE) begin
         ilk_temp_sense ts (
            .clk       (mm_clk),
            .degrees_c (degrees_c),
            .degrees_f (degrees_f)
         );
      end
      else begin
         assign degrees_f = 8'h0;
         assign degrees_c = 8'h0;
      end
   endgenerate

   //////////////////////////////////////////////
   // reset sequence
   //////////////////////////////////////////////
   //wire gx_pdn;
   wire pll_pdn;
//wire tx_analog_rst;  pll_pdn is used for tx_analog_rst.

   wire tx_digital_rst /* synthesis keep */;
   wire rx_analog_rst  /* synthesis keep */;
   wire rx_digital_rst /* synthesis keep */;

   reg soft_rst_txrx     /* synthesis preserve */;
   reg soft_rst_rx       /* synthesis preserve */;
   reg ignore_rx_digital /* synthesis preserve */;
   reg ignore_rx_analog  /* synthesis preserve */;


   wire rds_ready;
   ilk_reset_delay rds (
      .clk       (mm_clk),
	.ready_in(mm_clk_locked),
      .ready_out (rds_ready)
   );
   defparam rds .CNTR_BITS = CNTR_BITS;
   assign system_reset = !rds_ready;

   wire rd0_ready;
   ilk_reset_delay rd0 (
      .clk       (mm_clk),
      .ready_in  (!system_reset && !soft_rst_txrx),
      .ready_out (rd0_ready)
   );
   defparam rd0 .CNTR_BITS = CNTR_BITS;
   //assign gx_pdn = !rd0_ready;

   wire rd1_ready /* synthesis keep */;
   ilk_reset_delay rd1 (
      .clk       (mm_clk),
      .ready_in  (rd0_ready),
      .ready_out (rd1_ready)
   );
   defparam rd1 .CNTR_BITS = CNTR_BITS;
   assign pll_pdn = !rd1_ready;

   wire rd1b_ready /* synthesis keep */;
   ilk_reset_delay rd1b (
      .clk       (mm_clk),
      .ready_in  (rd1_ready),
      .ready_out (rd1b_ready)
   );
   defparam rd1b .CNTR_BITS = CNTR_BITS;
   //assign tx_analog_rst = !rd1b_ready;

   wire rd2_ready /* synthesis keep */;
   ilk_reset_delay rd2 (
      .clk       (mm_clk),
      .ready_in(rd1_ready && (&all_pll_locked)),
      .ready_out (rd2_ready)
   );
   defparam rd2 .CNTR_BITS = CNTR_BITS;
   assign tx_digital_rst = !rd2_ready;

   wire rd3_ready /* synthesis keep */;
   ilk_reset_delay rd3 (
      .clk       (mm_clk),
      .ready_in  (rd2_ready && !soft_rst_rx),
      .ready_out (rd3_ready)
   );
   defparam rd3 .CNTR_BITS = CNTR_BITS;
assign rx_analog_rst = !rd3_ready && !ignore_rx_analog;

   wire rd4_ready /* synthesis keep */;
   ilk_reset_delay rd4 (
      .clk       (mm_clk),
      .ready_in  (rd3_ready & (&rx_is_lockedtodata)),
      .ready_out (rd4_ready)
   );
   defparam rd4 .CNTR_BITS = CNTR_BITS;
assign rx_digital_rst = !rd4_ready && !ignore_rx_digital;

   ////////////////
   // sync the digital resets out to the world

   reg [2:0] srst_tx_shift_n  /* synthesis preserve */
       /* synthesis ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_false_path -to [get_keepers *pcs_assembly*srst_tx_shift_n\[?\]]\" " */;

   always @(posedge tx_common or posedge tx_digital_rst) begin
      if (tx_digital_rst)
         srst_tx_shift_n <= 3'b000;
      else
         srst_tx_shift_n <= {srst_tx_shift_n[1:0],1'b1};
   end

   assign srst_tx_common = ~srst_tx_shift_n[2];

   reg [2:0] srst_rx_shift_n  /* synthesis preserve */
       /* synthesis ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_false_path -to [get_keepers *pcs_assembly*srst_rx_shift_n\[?\]]\" " */;

   always @(posedge rx_common or posedge rx_digital_rst) begin
      if (rx_digital_rst)
         srst_rx_shift_n <= 0;
      else
         srst_rx_shift_n <= {srst_rx_shift_n[1:0],1'b1};
   end
   assign srst_rx_common = ~srst_rx_shift_n[2];

   //////////////////////////////////////////////
   // IO pins
   //////////////////////////////////////////////
   reg  rx_cadence;

   wire                [NUM_LANES-1:0] tx_empty, tx_full, tx_pempty, tx_pfull;
   wire                [NUM_LANES-1:0] rx_empty, rx_full, rx_pempty, rx_pfull;
   wire                [NUM_LANES-1:0] rx_prbs_done;
   wire                [NUM_LANES-1:0] rx_prbs_err;
   reg                                 rx_prbs_err_clr = 1'b0;
   wire                [NUM_LANES-1:0] tx_pempty_s;
   reg                 [NUM_LANES-1:0] rx_pempty_r;
   reg                                 tx_from_fifo                          /* synthesis preserve */;
   reg                 [NUM_LANES-1:0] tx_full_r;
   wire                [NUM_LANES-1:0] tx_frame;
   wire                                tx_burst_en = tx_from_fifo;
   reg                                 tx_force_fill;
   wire                [NUM_LANES-1:0] rx_backup;
   reg                                 rx_set_locktodata;
   reg                                 rx_set_locktoref;
   wire  [NUM_LANES*BITS_PER_LANE-1:0] rx_dout_early;
   wire                [NUM_LANES-1:0] rx_valid_early, rx_control_early;

   reg   [NUM_LANES*BITS_PER_LANE-1:0] rx_dout_i;
   reg                 [NUM_LANES-1:0] rx_valid_i, rx_control_i;

   wire [20*MAX_LANES_PER_SIXPACK-1:0] exp_pcs_testbus_lnsel;
   reg          [MAX_NUM_SIXPACKS-1:0] pcs_testbus_6sel = {MAX_NUM_SIXPACKS{1'b0}};
   reg     [MAX_LANES_PER_SIXPACK-1:0] pcs_testbus_lnsel = {MAX_LANES_PER_SIXPACK{1'b0}};
   
   wire         [20*MAX_NUM_LANES-1:0] gated_pcs_testbus;

   reg  rx_purge;
   reg  any_loss_of_meta;

   wire [NUM_LANES-1:0] rx_metalock_s;
   ilk_status_sync #( .WIDTH( NUM_LANES ) ) rx_metalock_sync (.clk(rx_common),.din(rx_metalock),.dout(rx_metalock_s));
   always @(posedge rx_common) begin
      any_loss_of_meta <= (~&rx_metalock_s);
      rx_dout_i        <= rx_dout_early;
      rx_valid_i       <= rx_valid_early;
      rx_control_i     <= rx_control_early;
   end

   genvar i, j;
   genvar k;

   generate
      for (i=0; i<MAX_NUM_SIXPACKS; i=i+1) begin : gxlp

         //localparam GRP_IDX  = (count_sixpacks(LANE_PROFILE & {(6*(i+1)){1'b1}}) != 0) ? (count_sixpacks(LANE_PROFILE & {(6*(i+1)){1'b1}})-1) : 0;
         localparam GRP_IDX  = (i == 0) ? ((count_sixpacks(LANE_PROFILE & {(6*(0+1)){1'b1}}) != 0) ? (count_sixpacks(LANE_PROFILE & {(6*(0+1)){1'b1}})-1) : 0) :
                               (i == 1) ? ((count_sixpacks(LANE_PROFILE & {(6*(1+1)){1'b1}}) != 0) ? (count_sixpacks(LANE_PROFILE & {(6*(1+1)){1'b1}})-1) : 0) :
                               (i == 2) ? ((count_sixpacks(LANE_PROFILE & {(6*(2+1)){1'b1}}) != 0) ? (count_sixpacks(LANE_PROFILE & {(6*(2+1)){1'b1}})-1) : 0) : 
                                          ((count_sixpacks(LANE_PROFILE & {(6*(3+1)){1'b1}}) != 0) ? (count_sixpacks(LANE_PROFILE & {(6*(3+1)){1'b1}})-1) : 0) ;
         //localparam GRP_BOT  = (i == 0) ? 0 : count_ones(LANE_PROFILE & {(6*i){1'b1}});
         localparam GRP_BOT  = (i == 0) ? 0 : 
                               (i == 1) ? count_ones(LANE_PROFILE & {6*1{1'b1}}) : 
                               (i == 2) ? count_ones(LANE_PROFILE & {6*2{1'b1}}) : count_ones(LANE_PROFILE & {6*3{1'b1}});
         localparam GRP_SIZE = count_ones(LANE_PROFILE & (24'h3f << (i*6)));
         localparam [MAX_LANES_PER_SIXPACK-1:0] GRP_PROFILE = LANE_PROFILE[(i+1)*MAX_LANES_PER_SIXPACK-1 : i*MAX_LANES_PER_SIXPACK];

         if (((LANE_PROFILE >> (i*MAX_LANES_PER_SIXPACK)) & 6'h3f) != 6'h00) begin

            reg rx_fifo_clr;
			
            wire [MAX_LANES_PER_SIXPACK*20-1:0] tmp_pcs_testbus;

            sv_ilk_sixpack gx (
               .tx_empty           (tx_empty [GRP_BOT+GRP_SIZE-1 : GRP_BOT]),
               .tx_full            (tx_full  [GRP_BOT+GRP_SIZE-1 : GRP_BOT]),
               .tx_pempty          (tx_pempty[GRP_BOT+GRP_SIZE-1 : GRP_BOT]),
               .tx_pfull           (tx_pfull [GRP_BOT+GRP_SIZE-1 : GRP_BOT]),

               .rx_empty           (rx_empty [GRP_BOT+GRP_SIZE-1 : GRP_BOT]),
               .rx_full            (rx_full  [GRP_BOT+GRP_SIZE-1 : GRP_BOT]),
               .rx_pempty          (rx_pempty[GRP_BOT+GRP_SIZE-1 : GRP_BOT]),
               .rx_pfull           (rx_pfull [GRP_BOT+GRP_SIZE-1 : GRP_BOT]),
               .rx_prbs_done       (rx_prbs_done[GRP_BOT+GRP_SIZE-1 : GRP_BOT]),
               .rx_prbs_err        (rx_prbs_err[GRP_BOT+GRP_SIZE-1 : GRP_BOT]),
               .rx_prbs_err_clr    ({GRP_SIZE{rx_prbs_err_clr}}), // 1 bit for all lanes; will by sync'ed to each lane by PHY

               .rx_set_locktodata  (rx_set_locktodata),
               .rx_set_locktoref   (rx_set_locktoref),

               .pll_pdn            (pll_pdn),
               .rst_txa            (pll_pdn),
               .rst_rxa            (rx_analog_rst),
               .rst_txd            (tx_digital_rst),
               .rst_rxd            (rx_digital_rst),
               .rx_seriallpbken    ({GRP_SIZE{1'b0}} | loopback[GRP_BOT+GRP_SIZE-1 : GRP_BOT]),

               .ref_clk            (pll_ref_clk),
               .tx_coreclk         ({GRP_SIZE{tx_common}}),
               .rx_coreclk         ({GRP_SIZE{rx_common}}),

               .tx_parallel_data   (tx_din    [(GRP_BOT+GRP_SIZE)*BITS_PER_LANE-1 : GRP_BOT*BITS_PER_LANE]),
               .tx_control         (tx_control[GRP_BOT+GRP_SIZE-1 : GRP_BOT]),
               .tx_serial_data     (tx_pin    [GRP_BOT+GRP_SIZE-1 : GRP_BOT]),
               .tx_burst_en        (tx_burst_en),
               .tx_frame           (tx_frame [GRP_BOT+GRP_SIZE-1 : GRP_BOT]),
               .tx_crc32err_inject (tx_crc32err_inject_s_txc[GRP_BOT+GRP_SIZE-1 : GRP_BOT]),
               .tx_clkout          (tx_clkout[GRP_BOT+GRP_SIZE-1 : GRP_BOT]),

               .rx_serial_data     (rx_pin          [GRP_BOT+GRP_SIZE-1 : GRP_BOT]),
               .rx_parallel_data   (rx_dout_early   [(GRP_BOT+GRP_SIZE)*BITS_PER_LANE-1 : GRP_BOT*BITS_PER_LANE]),
               .rx_control         (rx_control_early[GRP_BOT+GRP_SIZE-1 : GRP_BOT]),
               .rx_clkout          (rx_clkout       [GRP_BOT+GRP_SIZE-1 : GRP_BOT]),

               .rx_fifo_clr        (rx_fifo_clr),
               .rx_wordlock        (rx_wordlock[GRP_BOT+GRP_SIZE-1 : GRP_BOT]),
               .rx_metalock        (rx_metalock[GRP_BOT+GRP_SIZE-1 : GRP_BOT]),
               .rx_crc32err        (rx_crc32err_pcs[GRP_BOT+GRP_SIZE-1 : GRP_BOT]),
               .rx_sh_err          (rx_sh_err  [GRP_BOT+GRP_SIZE-1 : GRP_BOT]),
               .rx_valid           (rx_valid_early[GRP_BOT+GRP_SIZE-1 : GRP_BOT]),
               .rx_ready           ({GRP_SIZE{rx_cadence}} & ~rx_backup[GRP_BOT+GRP_SIZE-1 : GRP_BOT]),
               .tx_valid           ({GRP_SIZE{tx_valid | tx_force_fill}}),

               .pll_locked         (pll_locked[i]),
               .rx_is_lockedtodata (rx_is_lockedtodata[GRP_BOT+GRP_SIZE-1 : GRP_BOT]),

               .pcs_testbus        (tmp_pcs_testbus),

               .reconfig_from_xcvr (reconfig_from_xcvr[(GRP_IDX+GRP_BOT)*W_BUNDLE_FROM_XCVR +: (GRP_SIZE+1)*W_BUNDLE_FROM_XCVR]),
               .reconfig_to_xcvr   (reconfig_to_xcvr  [(GRP_IDX+GRP_BOT)*W_BUNDLE_TO_XCVR   +: (GRP_SIZE+1)*W_BUNDLE_TO_XCVR])
            );

            defparam gx .USE_ATX            = USE_ATX;
            defparam gx .NUM_PLLS           = 1;
            defparam gx .NUM_LANES          = GRP_SIZE;
            defparam gx .LANE_PROFILE       = GRP_PROFILE;
            defparam gx .METALEN            = METALEN;
            defparam gx .SCRAM_CONST        = SCRAM_CONST + 214013 * i;
            defparam gx .DATA_RATE          = DATA_RATE;
            defparam gx .PLL_OUT_FREQ       = PLL_OUT_FREQ;
            defparam gx .PLL_REFCLK_FREQ    = PLL_REFCLK_FREQ;
            defparam gx .INT_TX_CLK_DIV     = INT_TX_CLK_DIV;
            defparam gx .W_BUNDLE_TO_XCVR   = W_BUNDLE_TO_XCVR;
            defparam gx .W_BUNDLE_FROM_XCVR = W_BUNDLE_FROM_XCVR;

            //// local copy of the PCS RX FIFO aclr
            always @(posedge rx_common) begin
               rx_fifo_clr <= rx_purge;
            end

            if( DIAG_ON != 0 ) begin
               assign gated_pcs_testbus [(i+1)*MAX_LANES_PER_SIXPACK*20-1 : i*MAX_LANES_PER_SIXPACK*20] =
                      {(MAX_LANES_PER_SIXPACK*20){pcs_testbus_6sel[i]}} & tmp_pcs_testbus & exp_pcs_testbus_lnsel;
            end
            assign all_pll_locked[i] = pll_locked[i];
         end
         else begin
            // This sixpack is not used in this config
            assign pll_locked[i]     = 1'b0;
            assign all_pll_locked[i] = 1'b1;
            if( DIAG_ON != 0 ) begin
               assign gated_pcs_testbus [(i+1)*MAX_LANES_PER_SIXPACK*20-1 : i*MAX_LANES_PER_SIXPACK*20] =
                      {(MAX_LANES_PER_SIXPACK*20){1'b0}};
            end
         end
      end
   endgenerate

   generate
   endgenerate

   // Mux the PCS testbus
   wire [19:0] pcs_testbus_out;
   generate
      if( DIAG_ON != 0 ) begin : diag_pcstb
         reg [19:0] pcs_testbus /* synthesis preserve */
             /* synthesis ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_false_path -to [get_keepers *pcs_assembly*pcs_testbus\[*\]]\" " */;

         for (i=0; i<MAX_LANES_PER_SIXPACK; i=i+1) begin : tbsel
            assign exp_pcs_testbus_lnsel [(i+1)*20-1 : i*20] = {20{pcs_testbus_lnsel[i]}};
         end

         for (i=0; i<20; i=i+1) begin : tbbit
            wire [MAX_NUM_LANES-1:0] tmp_tb;

            for (k=0; k<MAX_NUM_LANES; k=k+1) begin : tbwrd
               assign tmp_tb[k] = gated_pcs_testbus[k*20+i];
            end

            always @(posedge mm_clk)
               pcs_testbus[i] <= |tmp_tb;
         end

         assign pcs_testbus_out = pcs_testbus;
      end
      else begin
         assign pcs_testbus_out = 20'b0;
      end
   endgenerate

   /////////////////////////////////////////////////
   // cadence
   /////////////////////////////////////////////////
   // used a smoothed version of the TX fifo to accept new data
   reg last_tx_cadence;

   always @(posedge clk_tx_common) begin
      if (srst_tx_common) begin
         tx_cadence      <= 1'b0;
         last_tx_cadence <= 1'b0;
      end
      else begin
         last_tx_cadence <= tx_cadence;
         tx_cadence      <= (|tx_pempty_s) && (!last_tx_cadence || !tx_cadence);
      end
   end

   // used a smoothed version of the RX fifo to push new data out
   reg last_rx_cadence;

   always @(posedge clk_rx_common) begin
      if (srst_rx_common) begin
         rx_cadence      <= 1'b0;
         last_rx_cadence <= 1'b0;
      end
      else begin
         last_rx_cadence <= rx_cadence;
         rx_cadence      <= (~|rx_pempty_r) && (!last_rx_cadence || !rx_cadence);
      end
   end

   /////////////////////////////////////////////////
   // TX aligner
   /////////////////////////////////////////////////
   //Added extra pipe tx_empty_r, tx_empty_rr so that pcs domain will not be
   //Bottle neck. JZ 5-23-12

   reg all_tx_full;
   reg any_tx_empty;
   reg any_tx_frame;
   reg any_tx_full;

   wire [NUM_LANES-1:0] tx_frame_s;
   ilk_status_sync #( .WIDTH( NUM_LANES ) ) tx_frame_sync (.clk(clk_tx_common),.din(tx_frame),.dout(tx_frame_s));
   wire [NUM_LANES-1:0] tx_empty_rr;
   ilk_status_sync #( .WIDTH( NUM_LANES ) ) tx_empty_sync (.clk(clk_tx_common),.din(tx_empty),.dout(tx_empty_rr));
   ilk_status_sync #( .WIDTH( NUM_LANES ) ) tx_pempty_sync (.clk(clk_tx_common),.din(tx_pempty),.dout(tx_pempty_s));
   always @(posedge clk_tx_common) begin
      if (srst_tx_common) begin
         all_tx_full  <= 1'b0;
         any_tx_full  <= 1'b0;
         any_tx_empty <= 1'b1;
         any_tx_frame <= 1'b0;
         tx_full_r    <= { NUM_LANES{ 1'b0 }};
      end
      else begin
      all_tx_full  <= &tx_full_r;
      any_tx_full  <= |tx_full_r;
      any_tx_empty <= |tx_empty_rr;
         any_tx_frame <= |tx_frame_s;
      tx_full_r    <= tx_full;
      end
   end

   always @(posedge clk_rx_common) begin
      rx_pempty_r <= rx_pempty;
   end

   reg [2:0] txa_sm               /* synthesis preserve */;
   localparam TXA_INIT           = 3'h0;
   localparam TXA_FILL           = 3'h1;
   localparam TXA_PREFRAME_WAIT  = 3'h2;
   localparam TXA_POSTFRAME_WAIT = 3'h3;
   localparam TXA_ENABLE         = 3'h4;
   localparam TXA_ALIGNED        = 3'h5;
   localparam TXA_ERROR0         = 3'h6;
   localparam TXA_ERROR1         = 3'h7;


   reg       tx_aligned;
   reg [3:0] tx_frame_countdown;

   assign tx_lanes_aligned = tx_aligned;
   assign tx_pcsfifo_pempty = |tx_pempty_s;

always @(posedge clk_tx_common) begin
	if (srst_tx_common) begin
		txa_sm <= TXA_INIT;
		tx_from_fifo <= 1'b1;
		tx_aligned <= 1'b0;
		tx_force_fill <= 1'b0;
		tx_frame_countdown <= 4'hf;
	end
	else begin
		
		// defaults
		tx_aligned <= 1'b0;
		tx_force_fill <= 1'b0;
		
		case (txa_sm) 
			TXA_INIT : begin
				txa_sm <= TXA_FILL;
				tx_from_fifo <= 1'b1;
			end
			TXA_FILL :	begin
				tx_from_fifo <= 1'b0;
				tx_force_fill <= 1'b1;
				if (all_tx_full) txa_sm <= TXA_PREFRAME_WAIT;
			end
			TXA_PREFRAME_WAIT : begin
                                // wait until you see a frame being transmitted
				tx_frame_countdown <= 4'hf;
				if (any_tx_frame) txa_sm <= TXA_POSTFRAME_WAIT;				
			end
			TXA_POSTFRAME_WAIT : begin
                                // wait for ~16 ticks after any TX framing activity
		//		if (any_tx_frame) txa_sm <= TXA_PREFRAME_WAIT;				
		//		tx_frame_countdown <= tx_frame_countdown - 1'b1;
                                if (any_tx_frame) tx_frame_countdown <= 4'hf;
                                else tx_frame_countdown <= tx_frame_countdown - 1'b1;
				if (~|tx_frame_countdown) txa_sm <= TXA_ENABLE;
				if (!all_tx_full) txa_sm <= TXA_ERROR0; // this would be an error - start over
			end
			TXA_ENABLE :  begin
				tx_from_fifo <= 1'b1;
//			        if (!all_tx_full) txa_sm <= TXA_ALIGNED;
  			        if (!any_tx_full) txa_sm <= TXA_ALIGNED;  //This will make sure no one is full
								   //and wait longer to be more robust. 3-22-12
			end
			TXA_ALIGNED : begin
				tx_aligned <= 1'b1;
				if (any_tx_empty || any_tx_full) txa_sm <= TXA_ERROR0; // this would be an error - start over 
			end		
			TXA_ERROR0 : txa_sm <= TXA_ERROR1;
			TXA_ERROR1 : txa_sm <= TXA_INIT;
			
			default : txa_sm <= TXA_ERROR0;
		endcase		
	end
end
	
//////////////////////////////////////////////
// make abnormal TX status sticky
//////////////////////////////////////////////

reg sclr_txerr;
reg sclr_txerr_s /* synthesis preserve */
	/* synthesis ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_false_path -to [get_keepers *pcs_assembly*sclr_txerr_s]\" " */;
reg sclr_txerr_ss /* synthesis preserve */;

   always @(posedge clk_tx_common) begin
      sclr_txerr_ss <= sclr_txerr_s;
      sclr_txerr_s  <= sclr_txerr;
   end

   reg sticky_tx_loa;

   always @(posedge clk_tx_common) begin
      if (sclr_txerr_ss) begin
         sticky_tx_loa <= 1'b0;
      end
      else begin
         sticky_tx_loa <= sticky_tx_loa | !tx_aligned;
      end
   end

   /////////////////////////////////////////////////
   // RX aligner
   /////////////////////////////////////////////////

   // framing control words (as opposed to burst ctrl or idle) have bit 63 = 0
   wire [NUM_LANES-1:0] rx_bit63;
   generate
      for (i=0; i<NUM_LANES; i=i+1) begin : b63
         assign rx_bit63[i] = rx_dout_i[(i*64)+63];
      end
   endgenerate

   reg                  any_control;
   reg                  all_control;
   reg  [NUM_LANES-1:0] rx_control_r;
   wire [NUM_LANES-1:0] rx_framing_i = rx_control_i & ~rx_bit63;
   reg                  rx_any_pfull;
   reg                  rx_none_pempty;
   wire [NUM_LANES-1:0] rx_pfull_s;
   ilk_status_sync #( .WIDTH( NUM_LANES ) ) rx_pfull_sync (.clk(clk_rx_common),.din(rx_pfull),.dout(rx_pfull_s));

   always @(posedge clk_rx_common) begin
      if (srst_rx_common) begin
         any_control    <= 1'b0;
         all_control    <= 1'b0;
         rx_control_r   <= {NUM_LANES{1'b0}};
         rx_any_pfull   <= 1'b0;
         rx_none_pempty <= 1'b0;
      end
      else begin
         any_control    <= |(rx_valid_i & rx_framing_i);
         all_control    <= &(rx_valid_i & rx_framing_i);
         rx_control_r   <= rx_control_i;
         rx_any_pfull   <= |rx_pfull_s;
         rx_none_pempty <= ~|rx_pempty;
      end
   end
   assign rx_control = rx_control_r;

   localparam RXA_INIT          = 2'h0;
   localparam RXA_TRIAL_RELEASE = 2'h1;
   localparam RXA_TRIAL_ENGAGE  = 2'h2;
   localparam RXA_MONITOR_LOCK  = 2'h3;

   reg [1:0] rxa_sm          /* synthesis preserve */;
   reg [4:0] rxa_timer;
   reg [2:0] bad_align_cntr;
   reg       rx_align_locked;

   assign rx_backup = {NUM_LANES{1'b0}};

   always @(posedge clk_rx_common) begin

      if (srst_rx_common) begin
         rxa_sm          <= 2'b0;
         rx_align_locked <= 1'b0;
         rx_purge        <= 1'b0;
         bad_align_cntr  <= 3'b0;
         rxa_timer       <= 5'h0;
      end
      else begin

         if (!rxa_timer[4]) begin
            rxa_timer <= rxa_timer + 1'b1;
         end

         if (any_loss_of_meta) begin
            rxa_sm          <= RXA_INIT;
            rx_purge        <= 1'b1;
            rx_align_locked <= 1'b0;
         end
         else begin
            case (rxa_sm)
               RXA_INIT          : begin
                                      rx_purge        <= 1'b1;
                                      rxa_timer       <= 5'h0;
                                      rx_align_locked <= 1'b0;
                                      rxa_sm          <= RXA_TRIAL_RELEASE;
                                   end

               RXA_TRIAL_RELEASE : begin
                                      if (|rxa_timer[4:3]) begin
                                         rx_purge <= 1'b0;
                                         if (rx_any_pfull) begin
                                            // will be overflowing soon - try again
                                            rxa_sm <= RXA_INIT;
                                         end
                                         if (rx_none_pempty) begin
                                            // life in all lanes - start reading
                                            rxa_sm <= RXA_TRIAL_ENGAGE;
                                         end
                                      end
                                   end

               RXA_TRIAL_ENGAGE  : begin
                                      if (any_control) begin
                                         if (all_control) begin
                                            // confirmation of good alignment, declare lock
                                            rxa_sm         <= RXA_MONITOR_LOCK;
                                            bad_align_cntr <= 3'b0;
                                         end
                                         else begin
                                            // false start, try again
                                            rxa_sm <= RXA_INIT;
                                         end
                                      end
                                   end

               RXA_MONITOR_LOCK  : begin
                                      rx_align_locked <= 1'b1;
                                      if (rxa_timer[4] && any_control) begin
                                         if (all_control) begin
                                            // good alignment detected
                                            bad_align_cntr <= 3'b0;
                                         end
                                         else begin
                                            bad_align_cntr <= bad_align_cntr + 1'b1;
                                            rxa_timer      <= 5'h0;
                                            if (bad_align_cntr[2]) begin
                                               // after 4 bad alignments something is very wrong
                                               // release and try again
                                               rxa_sm <= RXA_INIT;
                                            end
                                         end
                                      end
                                   end
            endcase
         end
      end
   end

   assign rx_lanes_aligned = rx_align_locked;

   // call 2 out of 3 lanes showing framing a drop - to tolerate some bit error on the control bits
   wire rx_framing_decision = (rx_framing_i[0] & rx_framing_i[1]) |
                              (rx_framing_i[0] & rx_framing_i[2]) |
                              (rx_framing_i[1] & rx_framing_i[2]);

   // rx output registers - drop the framing layer words
   always @(posedge clk_rx_common) begin
      if (srst_rx_common) begin
         rx_valid <= {NUM_LANES{1'b0}};
         rx_dout  <= {(NUM_LANES*BITS_PER_LANE){1'b0}};
      end
      else begin
         rx_valid <= rx_valid_i & ~{NUM_LANES{rx_framing_decision}};
         rx_dout  <= rx_dout_i;
      end
   end

   //////////////////////////////////////////////
   // count crc32 errors for easier visibility
   //////////////////////////////////////////////
   reg sclr_rxerr;
   reg sclr_rxerr_s  /* synthesis preserve */
                     /* synthesis ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_false_path -to [get_keepers *pcs_assembly*sclr_rxerr_s]\" " */;
   reg sclr_rxerr_ss /* synthesis preserve */;

   always @(posedge clk_rx_common) begin
      sclr_rxerr_ss <= sclr_rxerr_s;
      sclr_rxerr_s  <= sclr_rxerr;
   end

   wire [NUM_LANES-1:0] rx_crc32err_s;
   ilk_status_sync #( .WIDTH( NUM_LANES ) ) rx_crc32err_sync (.clk(clk_rx_common),.din(rx_crc32err_pcs),.dout(rx_crc32err_s));
   assign rx_crc32err = rx_crc32err_s;
   
   wire [32*4-1:0] padded_crc32_cnt;
   generate
      if( DIAG_ON != 0 ) begin : diag_crc32
         wire [NUM_LANES * 4 - 1:0] crc32_error_cnt;
         wire [NUM_LANES*4-1:0] crc32_error_cnt_s;

         ilk_status_sync ss1 (.clk(mm_clk),.din(crc32_error_cnt),.dout(crc32_error_cnt_s));
         defparam ss1 .WIDTH = NUM_LANES*4;

         for (i=0; i<NUM_LANES; i=i+1) begin : ecnt
            reg [3:0] local_cnt;
            always @(posedge clk_rx_common or posedge srst_rx_common) begin
               if( srst_rx_common ) begin
                  local_cnt <= 4'h0;
               end
               else if (sclr_rxerr_ss) begin
                  local_cnt <= 4'h0;
               end
               else begin
                  if (rx_crc32err_s[i]) begin
                     // saturate rather than wrapping
                     if (~&local_cnt)
                        local_cnt <= local_cnt + 1'b1;
                  end
               end
            end

            assign crc32_error_cnt [(i+1)*4-1:i*4] = local_cnt;
         end

         assign padded_crc32_cnt = {(32*4){1'b0}} | crc32_error_cnt_s;

         ilk_status_sync ss30 (.clk(tx_common),.din(tx_crc32err_inject),.dout(tx_crc32err_inject_s_txc));
         defparam ss30.WIDTH = NUM_LANES;
      end
      else begin
         assign padded_crc32_cnt = {(32*4){1'b0}};
         assign tx_crc32err_inject_s_txc = {NUM_LANES{1'b0}};
      end
   endgenerate

   //////////////////////////////////////////////
   // count PRBS errors for easier visibility
   //////////////////////////////////////////////
   wire [7:0] rx_prbs_err_cnt_mm;
   wire [NUM_LANES-1:0] sticky_rx_prbs_err_mm;
   wire [NUM_LANES-1:0] rx_prbs_done_mm;
   generate
      if( DIAG_ON != 0 ) begin : diag_prbs
         reg  [7:0]           rx_prbs_err_cnt;
         wire                 rx_prbs_err_clr_s;
         wire [NUM_LANES-1:0] rx_prbs_err_s;

         ilk_status_sync #( .WIDTH( 1 ) ) rx_prbs_err_clr_sync (.clk(clk_rx_common),.din(rx_prbs_err_clr),.dout(rx_prbs_err_clr_s));
         ilk_status_sync #( .WIDTH( NUM_LANES ) ) rx_prbs_err_sync (.clk(clk_rx_common),.din(rx_prbs_err),.dout(rx_prbs_err_s));
         always @( posedge clk_rx_common or posedge srst_rx_common ) begin
            if( srst_rx_common ) begin
               rx_prbs_err_cnt <= 8'h0;
            end
            else if( rx_prbs_err_clr_s ) begin
               rx_prbs_err_cnt <= 0;
            end
            else if( ( |rx_prbs_err_s ) && ( rx_prbs_err_cnt != 8'hff ) ) begin
               rx_prbs_err_cnt <= rx_prbs_err_cnt + 1'b1;
            end
         end

         ilk_status_sync ss22 (.clk(mm_clk),.din(rx_prbs_err_cnt),.dout(rx_prbs_err_cnt_mm));
         defparam ss22.WIDTH = 8;

         reg [NUM_LANES-1:0] sticky_rx_prbs_err = {NUM_LANES{1'b0}};

         always @(posedge clk_rx_common or posedge srst_rx_common) begin
            if (srst_rx_common) begin
               sticky_rx_prbs_err  <= {NUM_LANES{1'b0}};
            end
            else if (rx_prbs_err_clr_s) begin
               sticky_rx_prbs_err  <= {NUM_LANES{1'b0}};
            end
            else begin
               sticky_rx_prbs_err  <= sticky_rx_prbs_err | rx_prbs_err_s;
            end
         end

         ilk_status_sync ss21 (.clk(mm_clk),.din(sticky_rx_prbs_err),.dout(sticky_rx_prbs_err_mm));
         defparam ss21.WIDTH = NUM_LANES;

         ilk_status_sync ss20 (.clk(mm_clk),.din(rx_prbs_done),.dout(rx_prbs_done_mm));
         defparam ss20.WIDTH = NUM_LANES;
      end
      else begin
         assign rx_prbs_err_cnt_mm = 8'h00;
         assign sticky_rx_prbs_err_mm = {NUM_LANES{1'b0}};
         assign rx_prbs_done_mm = {NUM_LANES{1'b0}};
      end
   endgenerate

   //////////////////////////////////////////////
   // make abnormal RX status sticky
   //////////////////////////////////////////////
   reg [NUM_LANES-1:0] sticky_sherr = {NUM_LANES{1'b0}};
   reg                 sticky_rx_loa = 1'b0;

   wire [NUM_LANES-1:0] rx_sh_err_s;
   ilk_status_sync #( .WIDTH( NUM_LANES ) ) rx_sh_err_sync (.clk(clk_rx_common),.din(rx_sh_err),.dout(rx_sh_err_s));
   always @(posedge clk_rx_common or posedge srst_rx_common) begin
      if (srst_rx_common) begin
         sticky_sherr  <= {NUM_LANES{1'b0}};
         sticky_rx_loa <= 1'b0;
      end
      else if (sclr_rxerr_ss) begin
         sticky_sherr  <= {NUM_LANES{1'b0}};
         sticky_rx_loa <= 1'b0;
      end
      else begin
         sticky_sherr  <= sticky_sherr | rx_sh_err_s;
         sticky_rx_loa <= sticky_rx_loa | !rx_align_locked;
      end
   end

   // Service reads issued by the top level
   //////////////////////////////////////////////
   wire rx_lanes_aligned_s;
   ilk_status_sync ss0 (.clk(mm_clk),.din(rx_lanes_aligned),.dout(rx_lanes_aligned_s));
   defparam ss0 .WIDTH = 1;

   wire [NUM_LANES-1:0] word_locked_s;
   ilk_status_sync ss2 (.clk(mm_clk),.din(rx_wordlock),.dout(word_locked_s));
   defparam ss2 .WIDTH = NUM_LANES;

   wire [NUM_LANES-1:0] sync_locked_s;
   ilk_status_sync ss3 (.clk(mm_clk),.din(rx_metalock),.dout(sync_locked_s));
   defparam ss3 .WIDTH = NUM_LANES;

   wire tx_lanes_aligned_s;
   ilk_status_sync ss4 (.clk(mm_clk),.din(tx_aligned),.dout(tx_lanes_aligned_s));
   defparam ss4 .WIDTH = 1;

   wire [NUM_LANES-1:0] sticky_sherr_s;
   ilk_status_sync ss5 (.clk(mm_clk),.din(sticky_sherr),.dout(sticky_sherr_s));
   defparam ss5 .WIDTH = NUM_LANES;

   wire sticky_tx_loa_s;
   ilk_status_sync ss6 (.clk(mm_clk),.din(sticky_tx_loa),.dout(sticky_tx_loa_s));
   defparam ss6 .WIDTH = 1;

   wire sticky_rx_loa_s;
   ilk_status_sync ss7 (.clk(mm_clk),.din(sticky_rx_loa),.dout(sticky_rx_loa_s));
   defparam ss7 .WIDTH = 1;

   wire [1:0] rxa_sm_s;
   wire [4:0] rxa_timer_s;
   wire all_control_s;
   wire any_control_s;
   wire any_loss_of_meta_s;
   wire [2:0] txa_sm_s;
   wire all_tx_full_s;
   wire any_tx_empty_s;
   wire any_tx_full_s;
   wire any_tx_frame_s;
   generate
      if( DIAG_ON != 0 ) begin : diag0
         ilk_status_sync ss8 (.clk(mm_clk),.din(rxa_sm),.dout(rxa_sm_s));
         defparam ss8 .WIDTH = 2;

         ilk_status_sync ss9 (.clk(mm_clk),.din(all_control),.dout(all_control_s));
         defparam ss9 .WIDTH = 1;

         ilk_status_sync ss10 (.clk(mm_clk),.din(any_control),.dout(any_control_s));
         defparam ss10 .WIDTH = 1;

         ilk_status_sync ss11 (.clk(mm_clk),.din(rxa_timer),.dout(rxa_timer_s));
         defparam ss11 .WIDTH = 5;

         ilk_status_sync ss12 (.clk(mm_clk),.din(any_loss_of_meta),.dout(any_loss_of_meta_s));
         defparam ss12.WIDTH = 1;

         ilk_status_sync ss13 (.clk(mm_clk),.din(any_tx_frame),.dout(any_tx_frame_s));
         defparam ss13.WIDTH = 1;

         ilk_status_sync ss14 (.clk(mm_clk),.din(all_tx_full),.dout(all_tx_full_s));
         defparam ss14.WIDTH = 1;

         ilk_status_sync ss15 (.clk(mm_clk),.din(any_tx_full),.dout(any_tx_full_s));
         defparam ss15.WIDTH = 1;

         ilk_status_sync ss16 (.clk(mm_clk),.din(any_tx_empty),.dout(any_tx_empty_s));
         defparam ss16.WIDTH = 1;

         ilk_status_sync ss18 (.clk(mm_clk),.din(txa_sm),.dout(txa_sm_s));
         defparam ss18.WIDTH = 3;
      end
      else begin
         assign rxa_sm_s = 2'b0,
                rxa_timer_s = 5'b0,
                all_control_s = 1'b0,
                any_control_s = 1'b0,
                any_loss_of_meta_s = 1'b0,
                txa_sm_s = 3'b0,
                all_tx_full_s = 1'b0,
                any_tx_empty_s = 1'b0,
                any_tx_full_s = 1'b0,
                any_tx_frame_s = 1'b0;
      end
   endgenerate

   wire [NUM_LANES-1:0] tx_empty_s_mm_clk;
   ilk_status_sync ss19 (.clk(mm_clk),.din(tx_empty_rr),.dout(tx_empty_s_mm_clk));
   defparam ss19.WIDTH = NUM_LANES;

   // add ilk_sync to rx_empty
   wire [NUM_LANES-1:0] rx_empty_s_mm_clk;
   ilk_status_sync ss23 (.clk(mm_clk),.din(rx_empty),.dout(rx_empty_s_mm_clk));
   defparam ss23.WIDTH = NUM_LANES;

   wire [NUM_LANES-1:0] tx_full_s_mm_clk;
   ilk_status_sync ss24 (.clk(mm_clk),.din(tx_full),.dout(tx_full_s_mm_clk));
   defparam ss24.WIDTH = NUM_LANES;   
 
   wire [NUM_LANES-1:0] tx_pempty_s_mm_clk;
   ilk_status_sync ss25 (.clk(mm_clk),.din(tx_pempty),.dout(tx_pempty_s_mm_clk));
   defparam ss25.WIDTH = NUM_LANES;  

   wire [NUM_LANES-1:0] tx_pfull_s_mm_clk;
   ilk_status_sync ss26 (.clk(mm_clk),.din(tx_pfull),.dout(tx_pfull_s_mm_clk));
   defparam ss26.WIDTH = NUM_LANES;    
 
   wire [NUM_LANES-1:0] rx_full_s_mm_clk;
   ilk_status_sync ss27 (.clk(mm_clk),.din(rx_full),.dout(rx_full_s_mm_clk));
   defparam ss27.WIDTH = NUM_LANES;  

   wire [NUM_LANES-1:0] rx_pempty_s_mm_clk;
   ilk_status_sync ss28 (.clk(mm_clk),.din(rx_pempty),.dout(rx_pempty_s_mm_clk));
   defparam ss28.WIDTH = NUM_LANES; 

   wire [NUM_LANES-1:0] rx_pfull_s_mm_clk;
   ilk_status_sync ss29 (.clk(mm_clk),.din(rx_pfull),.dout(rx_pfull_s_mm_clk));
   defparam ss29.WIDTH = NUM_LANES; 
   
   ////////////////////////////

   wire [31:0] counts = {24'h0,NUM_LANES[7:0]};
   wire [31:0] counts2 = {32'h0 | LANE_PROFILE};

   always @(posedge mm_clk) begin
      mm_rdata_valid <= 1'b0;

      if (mm_read) begin
         mm_rdata_valid <= 1'b1;
         case (mm_addr[5:0])
            6'h0    : mm_rdata <= {"HSi",8'h2};                   // cookie / version
            6'h1    : mm_rdata <= counts;
            6'h2    : mm_rdata <= 32'h0 | {degrees_c,degrees_f};  // degrees F @ TSD
            6'h3    : mm_rdata <= 32'h0 | sec_cntr;               // seconds since powerup

            6'h4    : mm_rdata <= 32'h0 | tx_empty_s_mm_clk;   // phase comp status
            6'h5    : mm_rdata <= 32'h0 | tx_full_s_mm_clk;
            6'h6    : mm_rdata <= 32'h0 | tx_pempty_s_mm_clk;
            6'h7    : mm_rdata <= 32'h0 | tx_pfull_s_mm_clk;
            6'h8    : mm_rdata <= 32'h0 | rx_empty_s_mm_clk;
            6'h9    : mm_rdata <= 32'h0 | rx_full_s_mm_clk;
            6'ha    : mm_rdata <= 32'h0 | rx_pempty_s_mm_clk;
            6'hb    : mm_rdata <= 32'h0 | rx_pfull_s_mm_clk;

            6'hc    : mm_rdata <= 32'h0 | pll_ref_khz;            // SERDES clock rates
            6'hd    : mm_rdata <= 32'h0 | rx_khz;
            6'he    : mm_rdata <= 32'h0 | tx_khz;
            6'hf    : mm_rdata <= counts2;

            6'h10   : mm_rdata <= 32'h0 | pll_locked;
            6'h11   : mm_rdata <= 32'h0 | rx_is_lockedtodata;
            6'h12   : mm_rdata <= 32'h0 | loopback;
            6'h13   : mm_rdata <= 32'h0 | {rx_set_locktodata,
                                           rx_set_locktoref,
                                           sclr_txerr, sclr_rxerr,
                                           1'b0,
                                           ignore_rx_analog,
                                           1'b0, soft_rst_txrx, soft_rst_rx, ignore_rx_digital};

            6'h20   : mm_rdata <= 32'h0 | {any_tx_frame_s,
                                           all_tx_full_s, any_tx_full_s, any_tx_empty_s, all_tx_full_s,
                                           txa_sm_s, tx_lanes_aligned_s,
                                           any_loss_of_meta_s, any_control_s, all_control_s, rxa_timer_s,
                                           rxa_sm_s, 1'b0, rx_lanes_aligned_s};
            6'h21   : mm_rdata <= 32'h0 | word_locked_s;
            6'h22   : mm_rdata <= 32'h0 | sync_locked_s;
            6'h23   : mm_rdata <= 32'h0 | padded_crc32_cnt[31:0];
            6'h24   : mm_rdata <= 32'h0 | padded_crc32_cnt[63:32];
            6'h25   : mm_rdata <= 32'h0 | padded_crc32_cnt[95:64];
            6'h26   : mm_rdata <= 32'h0 | padded_crc32_cnt[127:96];
            6'h27   : mm_rdata <= 32'h0 | sticky_sherr_s;
            6'h28   : mm_rdata <= 32'h0 | sticky_rx_loa_s;
            6'h29   : mm_rdata <= 32'h0 | sticky_tx_loa_s;

            6'h30   : mm_rdata <= 32'h0 | pcs_testbus_6sel;
            6'h31   : mm_rdata <= 32'h0 | pcs_testbus_lnsel;
            6'h32   : mm_rdata <= 32'h0 | pcs_testbus_out;
            6'h34   : mm_rdata <= 32'h0 | rx_prbs_done_mm;
            6'h35   : mm_rdata <= 32'h0 | sticky_rx_prbs_err_mm;
            6'h36   : mm_rdata <= 32'h0 | rx_prbs_err_cnt_mm;
            6'h37   : mm_rdata <= 32'h0 | rx_prbs_err_clr;
            6'h38   : mm_rdata <= 32'h0 | tx_crc32err_inject;

            default : mm_rdata <= 32'hDEAD_BEEF;
         endcase
      end
   end

   //////////////////////////////////////////////
   // Service writes issued by the top level
   //////////////////////////////////////////////
   always @(posedge mm_clk or posedge system_reset) begin

      if (system_reset) begin
         rx_set_locktodata <= 1'b0;
         rx_set_locktoref  <= 1'b0;
         loopback          <= {NUM_LANES{1'b0}};
         ignore_rx_analog  <= 1'b0;
         soft_rst_txrx     <= 1'b0;
         soft_rst_rx       <= 1'b0;
         ignore_rx_digital <= 1'b0;
         sclr_txerr        <= 1'b0;
         sclr_rxerr        <= 1'b0;
         pcs_testbus_6sel  <= {MAX_NUM_SIXPACKS{1'b0}};
         pcs_testbus_lnsel <= {MAX_LANES_PER_SIXPACK{1'b0}};
         tx_crc32err_inject<= {NUM_LANES{1'b0}};
         rx_prbs_err_clr   <= 1'b0;
      end
      else begin

         if (mm_write) begin
            case (mm_addr[5:0])
               6'h12 : loopback <= mm_wdata[NUM_LANES-1:0];
               6'h13 : {rx_set_locktodata,
                        rx_set_locktoref,
                        sclr_txerr,
                        sclr_rxerr,
                        //prg_read_mode,
                        ignore_rx_analog,
                        //soft_rst_cpu,
                        soft_rst_txrx,
                        soft_rst_rx,
                        ignore_rx_digital} <= {mm_wdata[9:6], mm_wdata[4], mm_wdata[2:0]};

               6'h30 : pcs_testbus_6sel   <= (DIAG_ON==0) ? {MAX_NUM_SIXPACKS{1'b0}} : mm_wdata[MAX_NUM_SIXPACKS-1:0];
               6'h31 : pcs_testbus_lnsel  <= (DIAG_ON==0) ? {MAX_LANES_PER_SIXPACK{1'b0}} : mm_wdata[MAX_LANES_PER_SIXPACK-1:0];
               6'h37 : rx_prbs_err_clr    <= (DIAG_ON==0) ? 1'b0 : mm_wdata[0];
               6'h38 : tx_crc32err_inject <= (DIAG_ON==0) ? {NUM_LANES{1'b0}} : mm_wdata[NUM_LANES-1:0];
            endcase
         end
      end
   end

endmodule

