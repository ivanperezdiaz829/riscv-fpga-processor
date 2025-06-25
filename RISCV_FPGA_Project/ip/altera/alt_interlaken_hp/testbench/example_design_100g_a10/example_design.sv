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


// top level file for example design

`timescale 1ps/1ps
module example_design #(
   parameter FAMILY    = "Arria 10",
   parameter PLL_REFCLK_FREQ    = "312.5 MHz",
   parameter TX_PKTMOD_ONLY     =    1,   //This value need to be consistant with core.
   parameter NUM_LANES          =   12,
   parameter CNTR_BITS          =    6,   // regulate reset delay, 6 for sim, 20 for hardware
   parameter TX_DUAL_SEG        =    1,           //By default, PKT gen will send traffic in Dual Segment Mode.
   parameter CALENDAR_PAGES     =    1,
   parameter LOG_CALENDAR_PAGES =    1,
   parameter METALEN            =  128,    
   parameter USE_ATX            =    1, 
   parameter PLL_OUT_FREQ       = "6250.0 MHz",
   parameter DATA_RATE          = "6250.0 MHz",
   parameter INT_TX_CLK_DIV      =    2,
   parameter LANE_PROFILE        = 24'b000000_000000_111111_111111,
   parameter RX_PKTMOD_ONLY      =   1,
   parameter SIM_FAKE_JTAG      = 1'b0    // emulate PC host a little bit
) (
   input                  clk50,
   input                  pll_ref_clk,

   input  [NUM_LANES-1:0] rx_pin,
   output [NUM_LANES-1:0] tx_pin
);

   localparam NUM_PLLS       = (NUM_LANES == 12) ? 2 : 4; // example only; user can change it
   localparam NUM_SIXPACKS = NUM_PLLS;
   localparam INCLUDE_TEMP_SENSE = 1'b1;
   localparam RXFIFO_ADDR_WIDTH  = 12;
   localparam PKT_SIZE           = 14'd65;       //Send fixed size 65 byte packet in packet mode. (TX_PKTMOD_ONLY=1)
   localparam BURST_SIZE         = 14'd128;      //Send fixed size 128 byte burst in burst interleave mode. 
                                                 //(TX_PKTMOD_ONLY = 0)
   localparam DUAL_SEG_SIZE      = 14'd65;       //In dual segment mode, this will be the packet or burst size.
   localparam RX_DUAL_SEG        =  1;           //By default, PKT checker will check if the receiver traffic is dual segment or not.
   localparam USR_CLK_FREQ       = (NUM_LANES == 24) ? "300.0 MHz" : "225.0 MHz"; //Specify User interface clock.

   localparam INTERNAL_WORDS     =  8;
   localparam W_BUNDLE_TO_XCVR   = 70;          //Signals that relates to reconfiguration controller.
   localparam W_BUNDLE_FROM_XCVR = 46;

   wire                         rx_lanes_aligned;
   wire                         rx_lanes_aligned_s;
   wire         [NUM_LANES-1:0] sync_locked;
   wire         [NUM_LANES-1:0] word_locked;
   wire                         send_data;

   reg  [CALENDAR_PAGES*16-1:0] itx_calendar;
   wire                         itx_ready;
   wire [64*INTERNAL_WORDS-1:0] irx_dout_words;
   wire                   [7:0] irx_num_valid;
   wire                   [1:0] irx_sop;
   wire                   [1:0] irx_sob;
   wire                         irx_eob;
   wire                   [7:0] irx_chan;
   wire                   [3:0] irx_eopbits;

   wire                         mm_clk;
   wire                         usr_clk;
   wire                         clk_sys_ready;
   wire                         reset_n;

   // config and status port and related signals
   wire                         mm_read;
   wire                         mm_write;
   wire                  [15:0] mm_addr;
   wire                  [31:0] mm_rdata;
   wire                         mm_rdata_valid;
   wire                  [31:0] mm_wdata;

   reg         sys_pll_rst = 1'b0;


   wire   [W_BUNDLE_TO_XCVR*(NUM_LANES+NUM_SIXPACKS)-1:0] reconfig_to_xcvr;
   wire [W_BUNDLE_FROM_XCVR*(NUM_LANES+NUM_SIXPACKS)-1:0] reconfig_from_xcvr;

   // Signals to increment debug counters, indicate errors
   wire                         clk_tx_common;
   wire                         srst_tx_common;
   wire                         clk_rx_common;
   wire                         srst_rx_common;
   wire                         sop_cntr_inc;
   wire                  [31:0] sop_cntr;
   wire                  [31:0] eop_cntr;
   wire         [NUM_LANES-1:0] crc32_err;
   wire                         crc24_err;
   wire       [NUM_LANES*8-1:0] crc32_err_cnt;
   wire                  [15:0] crc24_err_cnt;
   wire                   [3:0] checker_errors;
   wire                  [31:0] err_cnt;
   wire                         eop_cntr_inc;
   wire                         itx_overflow;
   wire                         itx_underflow;
   wire                         irx_overflow;
   wire                         rdc_overflow;
   wire                         rg_overflow;
   wire [RXFIFO_ADDR_WIDTH-1:0] rxfifo_fill_level;
   wire                         irx_err;
   wire                         tx_lanes_aligned;
   wire                         tx_mac_srst;
   wire                         rx_mac_srst;

   wire                         sys_pll_locked;
   wire [CALENDAR_PAGES*16-1:0] irx_calendar;
   wire                         itx_hungry;
   wire                         tx_usr_srst, rx_usr_srst;

   wire [64*INTERNAL_WORDS-1:0] itx_din_words;
   wire                   [7:0] itx_num_valid;
   wire                   [7:0] itx_chan;
   wire                   [1:0] itx_sop;
   wire                   [1:0] itx_sob;
   wire                         itx_eob;
   wire                   [3:0] itx_eopbits;
   wire                  [31:0] tx_sop_cnt;
   wire                  [31:0] tx_eop_cnt;

   wire                         itx_overflow_sticky;
   wire                         itx_underflow_sticky;
   wire                         irx_overflow_sticky;
   wire                         rdc_overflow_sticky;

   //An example to show user how to provide clocks used by interlaken.
   //User can modify it their way.
   assign itx_calendar = 256'h0101_0202_0303_0404_0505_0606_0707_0808_1011_2223_3435_4647_5859_6a6b_7c7d_8e8f;

    //for Arria 10    
wire [NUM_PLLS-1 : 0]  tx_pll_powerdown;
wire [NUM_PLLS-1 : 0]  tx_pll_clk;
wire [NUM_PLLS-1 : 0]  tx_pll_locked;
wire [5:0] pll_bonding_clocks [NUM_PLLS-1 : 0];
wire [6*NUM_LANES-1 :0]  tx_bonding_clocks;

//support 24 lanes and 12 lanes
assign tx_bonding_clocks = (NUM_LANES == 24) ?  {{6{pll_bonding_clocks[3]}},{6{pll_bonding_clocks[2]}},  
                                                 {6{pll_bonding_clocks[1]}},{6{pll_bonding_clocks[0]}} } :
                                              { {6{pll_bonding_clocks[1]}},{6{pll_bonding_clocks[0]}} };

   // one atx pll per sixpack
genvar ig;
generate
     for (ig=0; ig<=NUM_PLLS-1; ig=ig+1) begin: atxpll_gen 
     atxpll  atxpll_inst (
       .pll_powerdown              (tx_pll_powerdown[ig]),
       .mcgb_rst                   (tx_pll_powerdown[ig]),
       .pll_refclk0                (pll_ref_clk),

       .tx_bonding_clocks          (pll_bonding_clocks[ig]),
       .pll_locked                 (tx_pll_locked[ig]),
       .pll_cal_busy               ()
       );  
     end
endgenerate
 
   
   // System PLL
   altera_pll #(
      .reference_clock_frequency ("50.0 MHz"),
      .operation_mode            ("direct"),
      .number_of_clocks          (2),

      .output_clock_frequency0   ("100.0 MHz"),
      .phase_shift0              ("0 ps"),
      .duty_cycle0               (50),

      .output_clock_frequency1   (USR_CLK_FREQ),
      .phase_shift1              ("0 ps"),
      .duty_cycle1               (50)
   ) sys_pll (
      .outclk   ({usr_clk, mm_clk}),
      .locked   (sys_pll_locked),
      .fboutclk (),
      .fbclk    (1'b0),
      .rst      (sys_pll_rst),
      .refclk   (clk50)
   );

   // System Reset generator
   ilk_reset_delay #(
      .CNTR_BITS (CNTR_BITS)
   ) rdy_sys (
      .clk       (usr_clk),
      .ready_in  (sys_pll_locked),
      .ready_out (clk_sys_ready)
   );

   assign reset_n = clk_sys_ready;

   ilk_core #(
          .FAMILY(FAMILY),
	      .RXFIFO_ADDR_WIDTH  (RXFIFO_ADDR_WIDTH),
	      .CNTR_BITS          (CNTR_BITS),
	      .NUM_LANES          (NUM_LANES),
	      .CALENDAR_PAGES     (CALENDAR_PAGES),
	      .LOG_CALENDAR_PAGES (LOG_CALENDAR_PAGES),
	      .METALEN            (METALEN),
	      .INTERNAL_WORDS     (INTERNAL_WORDS),
	      .W_BUNDLE_TO_XCVR   (W_BUNDLE_TO_XCVR),
	      .W_BUNDLE_FROM_XCVR (W_BUNDLE_FROM_XCVR),
	      .USE_ATX            (USE_ATX),
	      .DATA_RATE          (DATA_RATE),
	      .PLL_OUT_FREQ       (PLL_OUT_FREQ),
	      .PLL_REFCLK_FREQ    (PLL_REFCLK_FREQ),
	      .INT_TX_CLK_DIV     (INT_TX_CLK_DIV),
	      .LANE_PROFILE       (LANE_PROFILE),
	      .NUM_SIXPACKS       (NUM_SIXPACKS),
	      .RX_PKTMOD_ONLY     (RX_PKTMOD_ONLY),
	      .TX_PKTMOD_ONLY     (TX_PKTMOD_ONLY),
	      .RX_DUAL_SEG        (RX_DUAL_SEG)
	      )core_inst (
      .tx_usr_clk         (usr_clk),            
      .rx_usr_clk         (usr_clk),            
      .pll_ref_clk        (pll_ref_clk),        
      .clk_tx_common      (clk_tx_common),   
      .clk_rx_common      (clk_rx_common),   
      .mm_clk             (mm_clk),   
      .reset_n            (reset_n),      
      .rx_pin             (rx_pin),          
      .tx_pin             (tx_pin),          
      .tx_mac_srst        (tx_mac_srst),  
      .rx_mac_srst        (rx_mac_srst),  
      .tx_usr_srst        (tx_usr_srst),      
      .rx_usr_srst        (rx_usr_srst),      
      .tx_lanes_aligned   (tx_lanes_aligned),  
      .itx_hungry         (itx_hungry),       
      .itx_overflow       (itx_overflow),    
      .itx_underflow      (itx_underflow),
      .itx_ifc_err        (itx_ifc_err),        
      .itx_ready          (itx_ready),          
      .itx_chan           (itx_chan),           
      .itx_num_valid      (itx_num_valid),     
      .itx_sop            (itx_sop),          
      .itx_eopbits        (itx_eopbits),  
      .itx_sob            (itx_sob),          
      .itx_eob            (itx_eob),          
      .itx_din_words      (itx_din_words),  
      .itx_calendar       (itx_calendar),  
      .burst_max_in       (4'h4),            
      .burst_short_in     (4'h2),             
      .burst_min_in       (4'h2),             
      .irx_chan           (irx_chan),          
      .irx_num_valid      (irx_num_valid),  
      .irx_sop            (irx_sop),           
      .irx_eopbits        (irx_eopbits),   
      .irx_sob            (irx_sob),           
      .irx_eob            (irx_eob),           
      .irx_err            (irx_err),    
      .irx_dout_words     (irx_dout_words),  
      .irx_calendar       (irx_calendar),    
      .sync_locked        (sync_locked),  
      .word_locked        (word_locked), 
      .rx_lanes_aligned   (rx_lanes_aligned),  
      .crc24_err          (crc24_err),       
      .crc32_err          (crc32_err),       
      .irx_overflow       (irx_overflow),   
      .rdc_overflow       (rdc_overflow),
      .rg_overflow        (rg_overflow),   
      .rxfifo_fill_level  (rxfifo_fill_level), 
      .sop_cntr_inc       (sop_cntr_inc),     
      .eop_cntr_inc       (eop_cntr_inc),     
      .srst_tx_common     (srst_tx_common),     
      .srst_rx_common     (srst_rx_common),     
      .mm_addr            (mm_addr),         
      .mm_write           (mm_write),         
      .mm_read            (mm_read),         
      .mm_rdata_valid     (mm_rdata_valid),  
      .mm_wdata           (mm_wdata),          
      .mm_rdata           (mm_rdata),           
      // .mm_clk_locked      (clk_sys_ready), 
      .mm_clk_locked      (1'b1), 
      .reconfig_to_xcvr   (reconfig_to_xcvr),
      .reconfig_from_xcvr (reconfig_from_xcvr), 
      .tx_pll_powerdown   (tx_pll_powerdown),
      .tx_pll_locked      (tx_pll_locked),
      .tx_bonding_clocks  (tx_bonding_clocks),
      .mm_waitrequest     ()
  );

   //////////////////////////////////////////////
   // ILK TX MAC PACKETS GENERATOR
   //////////////////////////////////////////////

   ilk_pkt_gen #(
      .INTERNAL_WORDS (INTERNAL_WORDS),
      .TX_PKTMOD_ONLY (TX_PKTMOD_ONLY),
      .TX_DUAL_SEG    (TX_DUAL_SEG),
      .PKT_SIZE       (PKT_SIZE),
      .BURST_SIZE     (BURST_SIZE),
      .DUAL_SEG_SIZE  (DUAL_SEG_SIZE)

   ) ilk_pkt_gen_inst (
      .clk              (usr_clk),
      .rx_lanes_aligned (rx_lanes_aligned),
      .itx_ready        (itx_ready),
      .send_data        (send_data),
      .rx_usr_srst      (rx_usr_srst),
      .tx_usr_srst      (tx_usr_srst),
      .srst_rx_common   (srst_rx_common),
      .srst_tx_common   (srst_tx_common),

      .itx_din_words    (itx_din_words),
      .itx_num_valid    (itx_num_valid),
      .itx_chan         (itx_chan),
      .itx_sop          (itx_sop),
      .itx_sob          (itx_sob),
      .itx_eob          (itx_eob),
      .itx_eopbits      (itx_eopbits),

      .tx_sop_cnt       (tx_sop_cnt),
      .tx_eop_cnt       (tx_eop_cnt)
   );


   //////////////////////////////////////////////
   // ILK RX MAC PACKETS CHECKER
   //////////////////////////////////////////////

   ilk_pkt_checker #(
      .INTERNAL_WORDS (INTERNAL_WORDS),
      .NUM_LANES      (NUM_LANES),
      .RX_DUAL_SEG    (RX_DUAL_SEG)
   ) ilk_pkt_checker_inst (
      .clk                  (usr_clk),

      .tx_usr_srst          (tx_usr_srst),
      .rx_usr_srst          (rx_usr_srst),

      .rx_lanes_aligned     (rx_lanes_aligned),
      .irx_dout_words       (irx_dout_words),
      .irx_num_valid        (irx_num_valid),
      .irx_sop              (irx_sop),
      .irx_chan             (irx_chan),
      .irx_eopbits          (irx_eopbits),

      .crc32_err            (crc32_err),
      .crc24_err            (crc24_err),

      .sop_cntr_inc         (sop_cntr_inc),
      .eop_cntr_inc         (eop_cntr_inc),

      .itx_overflow         (itx_overflow),
      .itx_underflow        (itx_underflow),
      .irx_overflow         (irx_overflow),
      .rdc_overflow         (rdc_overflow),

      .sop_cntr             (sop_cntr),
      .eop_cntr             (eop_cntr),
      .crc32_err_cnt        (crc32_err_cnt),
      .crc24_err_cnt        (crc24_err_cnt),
      .checker_errors       (checker_errors),
      .err_cnt              (err_cnt),
      .err_read             (1'b0),
      .itx_overflow_sticky  (itx_overflow_sticky),
      .itx_underflow_sticky (itx_underflow_sticky),
      .irx_overflow_sticky  (irx_overflow_sticky),
      .rdc_overflow_sticky  (rdc_overflow_sticky)
   );

   //////////////////////////////////////////////
   // local mem map
   //////////////////////////////////////////////

   wire [15:0] local_addr;
   reg [31:0] local_readdata = 0 /* synthesis preserve */
   /* synthesis ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_false_path -to [get_keepers *local_readdata\[*\]] -from *sticky\" " */;

   reg         local_readdata_valid;
   wire [31:0] local_writedata;
   wire        local_read;
   wire        local_write;

   ilk_status_sync ss0 (.clk(mm_clk),.din(rx_lanes_aligned),.dout(rx_lanes_aligned_s));
   defparam ss0 .WIDTH = 1;

   wire [NUM_LANES*8-1:0] crc32_error_cnt_s;
   ilk_status_sync ss1 (.clk(mm_clk),.din(crc32_err_cnt),.dout(crc32_error_cnt_s));
   defparam ss1 .WIDTH = NUM_LANES*8;

   wire [NUM_LANES-1:0] word_locked_s;
   ilk_status_sync ss2 (.clk(mm_clk),.din(word_locked),.dout(word_locked_s));
   defparam ss2 .WIDTH = NUM_LANES;

   wire [NUM_LANES-1:0] sync_locked_s;
   ilk_status_sync ss3 (.clk(mm_clk),.din(sync_locked),.dout(sync_locked_s));
   defparam ss3 .WIDTH = NUM_LANES;

   wire [15:0] crc24_error_cnt_s;
   ilk_status_sync ss4 (.clk(mm_clk),.din(crc24_err_cnt),.dout(crc24_error_cnt_s));
   defparam ss4 .WIDTH = 16;

   wire [31:0] sop_cntr_s;
   ilk_status_sync ss5 (.clk(mm_clk),.din(sop_cntr),.dout(sop_cntr_s));
   defparam ss5 .WIDTH = 32;

   wire [31:0] eop_cntr_s;
   ilk_status_sync ss6 (.clk(mm_clk),.din(eop_cntr),.dout(eop_cntr_s));
   defparam ss6 .WIDTH = 32;

   wire [31:0] err_cnt_s;
   ilk_status_sync ss7 (.clk(mm_clk),.din(err_cnt),.dout(err_cnt_s));
   defparam ss7 .WIDTH = 32;

   reg send_clk100 = 0;
   ilk_status_sync ss8 (.clk(mm_clk),.din(send_clk100),.dout(send_data));
   defparam ss8 .WIDTH = 1;

   reg [3:0] checker_errors_s;
   ilk_status_sync ss9 (.clk(mm_clk),.din(checker_errors),.dout(checker_errors_s));
   defparam ss9 .WIDTH = 4;

   // Testbench Registers
   always @(posedge mm_clk) begin
      local_readdata_valid <= 1'b0;
      if (local_read) begin
         local_readdata <= 32'h0;
         local_readdata_valid <= 1'b1;
         case (local_addr[5:0])
            6'h0    : local_readdata <= 32'h12345678;
            6'h2    : local_readdata <= 32'h0 | sys_pll_rst;

            6'h3    : local_readdata <= 32'h0 | rx_lanes_aligned_s;
            6'h4    : local_readdata <= 32'h0 | word_locked_s;
            6'h5    : local_readdata <= 32'h0 | sync_locked_s;

            6'h6    : local_readdata <= 32'h0 | crc32_error_cnt_s[31:0];
            6'h7    : local_readdata <= 32'h0 | crc32_error_cnt_s[63:32];
            6'h8    : local_readdata <= 32'h0 | crc32_error_cnt_s[79:64];

            6'ha    : local_readdata <= 32'h0 | crc24_error_cnt_s;
            6'hb    : local_readdata <= 32'h0 | {rdc_overflow_sticky,
                                                 irx_overflow_sticky,
                                                 itx_overflow_sticky,
                                                 itx_underflow_sticky};
            6'hc    : local_readdata <= 32'h0 | sop_cntr_s;
            6'hd    : local_readdata <= 32'h0 | eop_cntr_s;

            6'he    : local_readdata <= 32'h0 | err_cnt_s;  // Actual data error counter
            6'hf    : local_readdata <= 32'h0 | send_clk100;

            6'h10   : local_readdata <= 32'h0 | {checker_errors_s, 3'h0, sys_pll_locked};

            default : local_readdata <= 32'hDEAD_BEEF;
         endcase
      end
   end

   // Enable Packet Generator
   always @(posedge mm_clk or negedge sys_pll_locked) begin
      if (!sys_pll_locked) begin
         send_clk100 <= 1'b0;
      end
      else if (local_write) begin
         case (local_addr[5:0])
            6'hf : send_clk100 <= local_writedata[0];
         endcase
      end
   end

   wire [15:0] top_mm_addr;
   reg  [31:0] top_mm_readdata;
   reg         top_mm_readdata_valid;
   wire [31:0] top_mm_writedata;
   wire        top_mm_read;
   wire        top_mm_write;

   assign local_addr      = top_mm_addr;
   assign mm_addr         = top_mm_addr;
   assign local_writedata = top_mm_writedata;
   assign mm_wdata        = top_mm_writedata;

   assign local_read  =  top_mm_addr[15] && top_mm_read;
   assign mm_read     = !top_mm_addr[15] && top_mm_read;
   assign local_write =  top_mm_addr[15] && top_mm_write;
   assign mm_write    = !top_mm_addr[15] && top_mm_write;

   reg read_sel = 1'b0;
   always @(posedge mm_clk) begin
      if (local_read) read_sel <= 1'b0;
      if (mm_read) read_sel <= 1'b1;
   end

   always @(posedge mm_clk) begin
      if (read_sel) begin
         top_mm_readdata <= mm_rdata;
         top_mm_readdata_valid <= mm_rdata_valid;
      end
      else begin
         top_mm_readdata <= local_readdata;
         top_mm_readdata_valid <= local_readdata_valid;
      end
   end

   //////////////////////////////////////////////
   // handoff MM port to PC host
   //////////////////////////////////////////////

   reg [3:0] jtag_rst = 0 /* synthesis preserve */;
   always @(posedge mm_clk) begin
      jtag_rst <= {jtag_rst[2:0], 1'b1};
   end

   // synthesis translate off
   reg        faux_read      = 1'b0;
   reg        faux_write     = 1'b0;
   reg [31:0] faux_writedata = 32'h0;
   reg [15:0] faux_addr      = 16'h0;
   // synthesis translate on

   generate
      if (SIM_FAKE_JTAG) begin
         // synthesis translate off
         assign top_mm_read      = faux_read;
         assign top_mm_write     = faux_write;
         assign top_mm_writedata = faux_writedata;
         assign top_mm_addr      = faux_addr;
         // synthesis translate on
      end
      else begin
         // Instantiate JTAG master to communicate with the DUT from terminal window
         ilk_jtag_term_master jtm (
            .clk               (mm_clk),
            .arst              (~jtag_rst[3]),

            .mm_addr           (top_mm_addr),
            .mm_read           (top_mm_read),
            .mm_write          (top_mm_write),
            .mm_writedata      (top_mm_writedata),

            .mm_readdata       (top_mm_readdata),
            .mm_readdata_valid (top_mm_readdata_valid)
         );
      end
   endgenerate

   //////////////////////////////////////////////
   // debug monitor
   //////////////////////////////////////////////
   // synthesis translate off

   task write_mm_task;
      input [15:0] address;
      input [31:0] write_data;
      begin
         @(posedge mm_clk);
         #5;
         faux_addr = address;
         faux_writedata = write_data;
         faux_write = 1'b1;
         @(posedge mm_clk);
         $display("WRITE_MM: address %x gets %x", address, write_data);
         @(posedge mm_clk);
         faux_write = 1'b0;
      end
   endtask

   task read_mm_task;
      input  [15:0] address;
      output [31:0] read_data;
      begin
         @(posedge mm_clk);
         #5;
         faux_addr = address;
         faux_read = 1'b1;
         @(posedge mm_clk);
         @(posedge top_mm_readdata_valid);
         read_data = top_mm_readdata;
         $display("READ_MM: address %x =  %x", address, read_data);
         @(posedge mm_clk);
         faux_read = 1'b0;
         @(negedge top_mm_readdata_valid);
      end
   endtask

   reg fail = 0;
   integer startup_errors_crc24 = 0, startup_errors_crc32 = 0;
   wire all_word_lock = &word_locked;

   always @(posedge all_word_lock) begin
       $display("Word lock acquired at time %d",$time);
   end

   wire all_sync_lock = &sync_locked;

   always @(posedge all_sync_lock) begin
       $display("Meta lock acquired at time %d",$time);
       $display("CRC24 error count %d", crc24_err_cnt);
       $display("CRC32 error count %d", crc32_err_cnt);
   end

   always @(negedge all_word_lock) begin
      if ($time > 100) $display("Word lock lost at time %d",$time);
   end

   always @(negedge all_sync_lock) begin
      if ($time > 100) $display("Meta lock lost at time %d",$time);
   end

   always @(posedge itx_underflow) begin
      if(all_sync_lock)
         $display("%m: at time %t: UNDERFLOW", $time);
   end

   always @(crc24_err_cnt) begin
       if (crc24_err_cnt > startup_errors_crc24)
           fail = 1'b1;
       $display("time: %d CRC24 error count %d", $time, crc24_err_cnt);
   end

   reg [31:0] read_data_reg;

   // Testcase example
   initial begin
      $display("Searching for lane alignment...");
      @(posedge all_sync_lock);
      $display("all_sync_locked...");
      #1000
      startup_errors_crc24 = crc24_err_cnt;
      startup_errors_crc32 = crc32_err_cnt;

      @(posedge rx_lanes_aligned)
      $display("rx_lanes_aligned...");

      #1000
      write_mm_task(16'h800f, 1'b1);
      $display("Packet Generator Enabled");
      $display("Starting data transfers...");

      #200000
      if (SIM_FAKE_JTAG) begin
         write_mm_task(16'h800f, 1'b0);
         $display("Packet Generator Disabled");

         // Read PCS registers
         $display("PCS register reads...");
         read_mm_task(16'h0000, read_data_reg);
         read_mm_task(16'h0001, read_data_reg);
         read_mm_task(16'h0002, read_data_reg);
         read_mm_task(16'h0003, read_data_reg);
         read_mm_task(16'h0004, read_data_reg);
         read_mm_task(16'h0005, read_data_reg);
         read_mm_task(16'h0006, read_data_reg);
         read_mm_task(16'h0007, read_data_reg);
         read_mm_task(16'h0008, read_data_reg);
         read_mm_task(16'h0009, read_data_reg);
         read_mm_task(16'h000a, read_data_reg);
         read_mm_task(16'h000b, read_data_reg);
         read_mm_task(16'h000c, read_data_reg);
         read_mm_task(16'h000d, read_data_reg);
         read_mm_task(16'h000e, read_data_reg);
         read_mm_task(16'h000f, read_data_reg);
         read_mm_task(16'h0010, read_data_reg);
         read_mm_task(16'h0011, read_data_reg);
         read_mm_task(16'h0012, read_data_reg);
         read_mm_task(16'h0013, read_data_reg);
         read_mm_task(16'h0021, read_data_reg);
         read_mm_task(16'h0022, read_data_reg);
         // Read local testbench registers
         $display("Local register reads...");
         read_mm_task(16'h8000, read_data_reg);
         read_mm_task(16'h8002, read_data_reg);
         read_mm_task(16'h8003, read_data_reg);
         read_mm_task(16'h8004, read_data_reg);
         read_mm_task(16'h8005, read_data_reg);
         read_mm_task(16'h8006, read_data_reg);
         read_mm_task(16'h8007, read_data_reg);
         read_mm_task(16'h800a, read_data_reg);
         read_mm_task(16'h800b, read_data_reg);
         read_mm_task(16'h800c, read_data_reg);
         read_mm_task(16'h800d, read_data_reg);
         read_mm_task(16'h800e, read_data_reg);

         // Write test on PCS loopback register
         $display("Read/Write test on PCS loopback register");
         read_mm_task(16'h0012, read_data_reg);
         write_mm_task(16'h0012, {NUM_LANES{1'b1}});
         read_mm_task(16'h0012, read_data_reg);
         write_mm_task(16'h0012, {NUM_LANES{1'b0}});
         read_mm_task(16'h0012, read_data_reg);

         $display("%10d CRC24 errors reported", crc24_err_cnt-startup_errors_crc24);
         $display("time %d  %10d SOPs transmitted",$time, tx_sop_cnt);
         $display("time %d  %10d EOPs transmitted",$time, tx_eop_cnt);
         $display("time %d  %10d SOPs received",$time, sop_cntr_s);
         $display("time %d  %10d EOPs received",$time, eop_cntr_s);

         #3000000;
         //NOTE: Doing the below will reset the counters!
         $display("Read/Write ATX pll reset");
         write_mm_task(16'h0013, 32'h4);
         read_mm_task(16'h0013, read_data_reg);
         write_mm_task(16'h0013, 32'h0);
         read_mm_task(16'h0013, read_data_reg);

         @(posedge itx_ready);
         write_mm_task(16'h800f, 1'b1);
         $display("Packet Generator Enabled");
      end

      startup_errors_crc24 = crc24_err_cnt;
      startup_errors_crc32 = crc32_err_cnt;

      #2000000
      read_mm_task(16'h8013, read_data_reg);
      write_mm_task(16'h800f, 1'b0);
      $display("Packet Generator Disabled");

      #9000000
      $display("%10d CRC24 errors reported", crc24_err_cnt-startup_errors_crc24);
      $display("%10d SOPs transmitted", tx_sop_cnt);
      $display("%10d EOPs transmitted", tx_eop_cnt);
      $display("%10d SOPs received", sop_cntr_s);
      $display("%10d EOPs received", eop_cntr_s);

      #1
      if (fail)
         $display("FAIL");
      else
         $display("PASS");

      $finish;
   end
  // synthesis translate_on

  //////////////////////////////////////////////

    /* Example of source probe for debugging purpose. User can add other signal for probing.
    src_prb s1 (
            .probe({sys_pll_rst,clk50}),
            .source()
            );
    */

endmodule
