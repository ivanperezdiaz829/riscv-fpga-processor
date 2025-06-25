// (C) 2001-2012 Altera Corporation. All rights reserved.
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



// NOTES: parameter tx_pma_channel_type can take the following four values:
// (1) SINGLE_CHANNEL --
//
// the av_tx_pma block will instantiate a simple pipeline of cgb -> 
// ser -> tx_buf. It requires that a high frequency clock be connected to
// 'clk' input port. 'datain' and 'dataout' have to be connected as 
// expected.
//
// (2) MASTER_SINGLE_CHANNEL --
//
// the av_tx_pma block will instantiate a simple pipeline of cgb -> 
// ser -> tx_buf. It requires that a high frequency clock be connected to
// 'clk' input port. In addition, the module outputs the bonding clocks via ports
// (hfclkpout, lfclkpout,cpulseout,pclk0out,pclk1out). These clocks must be
// connected to another instance of av_tx_pma_ch that serves as SLAVE_CHANNEL. 
// 'datain' and 'dataout' have to be connected as expected.
//
// (3) SLAVE_CHANNEL --
//
// the av_tx_pma block will instantiate a simple pipeline of cgb -> 
// ser -> tx_buf. The cgb in this case is not used to divide the high frequency clock 
// from the tx pll, but to forward the bonding clocks to the serializer. It is required that
// the bonding clock bondle is connected to the inputs (hfclkpin, lfclkpin,cpulsein, 
// pclk0in,pclk1in). These clocks must come from a av_tx_pma_ch block that serves 
// as MASTER_SINGLE_CHANNEL or as MASTER_ONLY. 
// 'datain' and 'dataout' have to be connected as expected.
//
// (4) MASTER_ONLY
//
// the av_tx_pma_ch block will only instantiate a cgb -> ser. The cgb is used to divide the
// high frequency clock from the tx pll (input clk) and produce bonding clocks via ports
// (hfclkpout, lfclkpout,cpulseout,pclk0out,pclk1out). The serializer block in this case is
// configured in a special clk_forward_only_mode = true. This indicates that the serializer
// does not serve its usual role of converting data on a parallel bus input into a serial output,
// but serves to only forward the parallel clock from the cgb to the output clkdivtx.
// 

`timescale 1ps/1ps
module av_tx_pma_ch #(
    parameter mode = 8,
    parameter channel_number    = 0,
    parameter auto_negotiation  = "true",
    parameter plls              = 1,
    parameter pll_sel           = 0,
    parameter ser_loopback      = "false",
    parameter ht_delay_sel      = "false",
    parameter tx_pma_type       = "SINGLE_CHANNEL",
    parameter data_rate         = "0 ps",
    parameter rx_det_pdb        = "false",
    parameter tx_clk_div        = 1, //(1,2,4,8)
	  parameter pcie_rst          = "NORMAL_RESET",
	  parameter fref_vco_bypass   = "normal_operation",
	  parameter enable_dcd        = 0, // mask off PLL AUX until fitter support is ready
	  parameter pma_bonding_mode  = "x1", // valid value "x1", "xN"
	  parameter bonded_lanes      = 1,
	  parameter pma_direct        = "false",
	  parameter external_master_cgb = 0,
    parameter fir_coeff_ctrl_sel = "ram_ctl"	//Valid values: dynamic_ctl|ram_ctrl
) ( 
  //input port for aux
  input             calclk,
  //input port for buf
  input   [79:0]    datain,
  input             txelecidl,
  input             rxdetclk,
  input             txdetrx,
  
  //output port for buf
  output            dataout,
  output            rxdetectvalid,
  output            rxfound,
  
  //input ports for ser
  input               rstn,
  input               seriallpbken,
  
  //output ports for ser
  output              clkdivtx,
  output              seriallpbkout,
  
  //input ports for cgb
  input   [plls-1:0]  clk,
  input               pciesw,
  input               pcsrstn,
  input               fref,
  
  // bonding clock inputs from master CGB
  input               cpulsein,
  input               hfclkpin,
  input               lfclkpin,
  input   [2:0]       pclkin,
  
  //output ports for cgb
  output              pcieswdone,
  
  // bonding clock outputs (driven if this CGB is acting as a master)
  output              hfclkpout,
  output              lfclkpout,
  output              cpulseout,
  output  [2:0]       pclkout,
  
  // input/outputs related to reconfiguration
  input               avmmrstn,
  input               avmmclk,
  input               avmmwrite,
  input               avmmread,
  input   [1:0 ]      avmmbyteen,
  input   [10:0 ]     avmmaddress,
  input   [15:0 ]     avmmwritedata,
  output  [15:0 ]     avmmreaddata_cgb, // CGB readdata
  output  [15:0 ]     avmmreaddata_ser, // SER readdata
  output  [15:0 ]     avmmreaddata_buf, // BUF readdata
  output              blockselect_cgb,  // CGB blockselect
  output              blockselect_ser,  // SER blockselect
  output              blockselect_buf,  // BUF blockselect
  output              atb_comp_out,     // Voltage comparator output for DCD
  
  input               vrlpbkp,
  input               vrlpbkn  
);

  localparam  MAX_PLLS = 7;
  localparam  PLL_CNT = (plls < MAX_PLLS) ? plls : MAX_PLLS;
  
  localparam  integer is_single_chan       = (tx_pma_type == "SINGLE_CHANNEL"       ) ? 1 : 0;
  localparam  integer is_master_only       = (tx_pma_type == "MASTER_ONLY"          ) ? 1 : 0;
  localparam  integer is_master_chan       = (tx_pma_type == "MASTER_SINGLE_CHANNEL") ? 1 : 0;
  localparam  integer is_slave_chan        = (tx_pma_type == "SLAVE_CHANNEL"        ) ? 1 : 0;
  localparam  integer is_empty_chan        = (tx_pma_type == "EMPTY_CHANNEL"        ) ? 1 : 0;
  localparam  integer is_fb_comp           = (tx_pma_type == "FB_COMP_CHANNEL"      ) ? 1 : 0;  
  // to support bonding 
  
  // Select clock source for g2 and g1 based on auto_negotiation
  localparam X1_CLOCK_SOURCE_SEL_AUTONEG =
                  (auto_negotiation == "true") ? "same_ch_txpll"
              //: (pll_sel ==11) ? "hfclk_ch1_x6_up"// 9  - hfclkp_x6_up
              //: (pll_sel ==10) ? "hfclk_xn_dn"    // 8  - hfclkp_xn_dn
              //: (pll_sel == 9) ? "hfclk_ch1_x6_dn"// 7  - hfclkp_x6_dn
              //: (pll_sel == 8) ? "hfclk_xn_up"    // 6  - hfclkp_xn_up
                : (pll_sel == 5) ? "down_segmented" // 1  - clk_dn_seg
                : (pll_sel == 4) ? "up_segmented"   // 0  - clk_up_seg
              //: (pll_sel == 5) ? "lcpll_bottom"   // 11 - clk_lc_b
              //: (pll_sel == 4) ? "lcpll_top"      // 10 - clk_lc_t
                : (pll_sel == 3) ? "ffpll"          // 2  - clk_ffpll
                : (pll_sel == 2) ? "ch1_txpll_b"    // 4  - clk_cdr_1b
                : (pll_sel == 1) ? "ch1_txpll_t"    // 3  - clk_cdr_1t 
                : (pll_sel == 0) ? "same_ch_txpll"  // 5  - clk_cdr_loc
                : "x1_clk_unused";

  localparam X1_DIV_M_SEL = (tx_clk_div == 2) ? 2 :
                            (tx_clk_div == 4) ? 4 :
                            (tx_clk_div == 8) ? 8 :
                            1;   

  generate if(is_empty_chan == 0) begin:tx_pma_ch
    wire  [MAX_PLLS-1:0] wire_clk;

    wire  [79:0]  w_datain;
    wire          w_txelecidl;
    wire          w_rxdetclk;
    wire          w_txdetrx;

    wire        cpulse_from_cgb;
    wire        hclk_from_cgb;
    wire        lfclk_from_cgb;
    wire  [2:0] pclk_from_cgb;
    wire        dataout_from_ser;
    
    wire        wire_hfclkpin;
    wire        wire_lfclkpin;
    wire        wire_cpulsein;
    wire  [2:0] wire_pclkin;

    wire        wire_hfclkpout;
    wire        wire_lfclkpout;
    wire        wire_cpulseout;
    wire  [2:0] wire_pclkout;
    
    wire        wire_rstn;
    wire        wire_pcsrstn;
    wire        wire_fref;
    
    wire        w_pciesw;  
    
    // for bonding support 
    wire        cpulse_from_cgb_master; 
    wire        hclk_from_cgb_master  ;
    wire        lfclk_from_cgb_master ;
    wire [2:0]  pclk_from_cgb_master  ;
    
    assign  w_datain    = (is_master_only == 0) ? datain    : 80'd0;
    assign  w_txelecidl = (is_master_only == 0) ? txelecidl : 1'b0;
    assign  w_rxdetclk  = (is_master_only == 0) ? rxdetclk  : 1'b0;
    assign  w_txdetrx   = (is_master_only == 0) ? txdetrx   : 1'b0;
    
    // Determine what drives the bonding lines input to the CGB
    assign wire_hfclkpin = (is_single_chan       == 1) ? 1'b0           : 
                           (pma_bonding_mode == "xN" && bonded_lanes == 1)? 1'b0:
                           (is_fb_comp           == 1) ? wire_hfclkpout : 
                           (is_master_chan       == 1) ? wire_hfclkpout :
                           (is_master_only       == 1) ? wire_hfclkpout :
                                                         hfclkpin       ;
    
    assign wire_lfclkpin = (is_single_chan       == 1) ? 1'b0           :
                           (pma_bonding_mode == "xN" && bonded_lanes == 1)? 1'b0:   
                           (is_fb_comp           == 1) ? wire_lfclkpout :
                           (is_master_chan       == 1) ? wire_lfclkpout :
                           (is_master_only       == 1) ? wire_lfclkpout :
                                                         lfclkpin       ;
    
    assign wire_cpulsein = (is_single_chan       == 1) ? 1'b0           :
                           (pma_bonding_mode == "xN" && bonded_lanes == 1)? 1'b0:    
                           (is_fb_comp           == 1) ? wire_cpulseout :
                           (is_master_chan       == 1) ? wire_cpulseout :
                           (is_master_only       == 1) ? wire_cpulseout :
                                                         cpulsein       ;
    
    assign wire_pclkin   = (is_single_chan       == 1) ? 3'b000         :
                           (pma_bonding_mode == "xN" && bonded_lanes == 1)? 3'b000:  
                           (is_fb_comp           == 1) ? wire_pclkout   :
                           (is_master_chan       == 1) ? wire_pclkout   :
                           (is_master_only       == 1) ? wire_pclkout   :
                                                         pclkin         ;
		
    // determine what drives the bonding lines output from this module
    assign hfclkpout =  (is_single_chan == 1) ? 1'b0 :
                        (is_slave_chan  == 1) ? 1'b0 :
                                                wire_hfclkpout;
    
    assign lfclkpout =  (is_single_chan == 1) ? 1'b0 :
                        (is_slave_chan  == 1) ? 1'b0 :
                                                wire_lfclkpout;
    
    assign cpulseout =  (is_single_chan == 1) ? 1'b0 :
                        (is_slave_chan  == 1) ? 1'b0 :
                                                wire_cpulseout;
    
    assign pclkout =  (is_single_chan == 1) ? 1'b0 :
                      (is_slave_chan  == 1) ? 1'b0 :
                                              wire_pclkout;
					      
    // determine what drives the HF clock input into CGB
    assign wire_clk = (is_slave_chan == 1) ? {MAX_PLLS{1'b0}} // no clock can be connected in a slave mode
                      : {{(MAX_PLLS-PLL_CNT){1'b0}},clk};  // otherwise, connect the input clock
    
    assign w_pciesw = (auto_negotiation == "false") ? 1'b0 : pciesw;  
    // determine what drives the HF clock input into CGB
						  
    assign wire_rstn = (pcie_rst == "NORMAL_RESET") ? rstn
                    : 1'b1;
  
    assign wire_pcsrstn = (pcie_rst == "PCIE_RESET") ? pcsrstn
                    : 1'b1;
						  
    assign wire_fref = (fref_vco_bypass == "FREF_BYPASS") ? fref
                    : 1'b0;
		    
    wire        avmmrstn_master     ;    
    wire        avmmclk_master      ;    
    wire        avmmwrite_master    ;  
    wire        avmmread_master     ;  
    wire [1:0]  avmmbyteen_master   ;  
    wire [10:0] avmmaddress_master  ;  
    wire [15:0] avmmwritedata_master; 
    wire [15:0] avmmreaddata_master ;
    wire        blockselect_master  ;
    
    wire        avmmrstn_slave     ;    
    wire        avmmclk_slave      ;    
    wire        avmmwrite_slave    ;  
    wire        avmmread_slave     ;  
    wire [1:0]  avmmbyteen_slave   ;  
    wire [10:0] avmmaddress_slave  ;  
    wire [15:0] avmmwritedata_slave; 
    wire [15:0] avmmreaddata_slave ;
    wire        blockselect_slave  ;
      
    // If the feedback compensation is not used, the AVMM signals from/to the CGB connect to the AVMM
    //Inputs 
    assign avmmrstn_master      = (is_fb_comp == 0 && pma_bonding_mode != "xN") ? avmmrstn               : 1'd0  ;
    assign avmmclk_master       = (is_fb_comp == 0 && pma_bonding_mode != "xN") ? avmmclk                : 1'd0  ; 
    assign avmmwrite_master     = (is_fb_comp == 0 && pma_bonding_mode != "xN") ? avmmwrite              : 1'd0  ;  
    assign avmmread_master      = (is_fb_comp == 0 && pma_bonding_mode != "xN") ? avmmread               : 1'd0  ;   
    assign avmmbyteen_master    = (is_fb_comp == 0 && pma_bonding_mode != "xN") ? avmmbyteen             : 2'd0  ; 
    assign avmmaddress_master   = (is_fb_comp == 0 && pma_bonding_mode != "xN") ? avmmaddress            : 11'd0 ;
    assign avmmwritedata_master = (is_fb_comp == 0 && pma_bonding_mode != "xN") ? avmmwritedata          : 16'd0 ;
    
    assign avmmrstn_slave      = (is_fb_comp == 0) ? avmmrstn               : 1'd0  ;
    assign avmmclk_slave       = (is_fb_comp == 0) ? avmmclk                : 1'd0  ; 
    assign avmmwrite_slave     = (is_fb_comp == 0) ? avmmwrite              : 1'd0  ;  
    assign avmmread_slave      = (is_fb_comp == 0) ? avmmread               : 1'd0  ;   
    assign avmmbyteen_slave    = (is_fb_comp == 0) ? avmmbyteen             : 2'd0  ; 
    assign avmmaddress_slave   = (is_fb_comp == 0) ? avmmaddress            : 11'd0 ;
    assign avmmwritedata_slave = (is_fb_comp == 0) ? avmmwritedata          : 16'd0 ;
    
    if (external_master_cgb == 0) begin
      arriav_hssi_pma_tx_cgb tx_cgb (
        .rstn           (wire_rstn             ),
        .pcsrstn        (wire_pcsrstn          ),
        .clkcdrloc      (wire_clk[0]      ),  // Switch between this
        .clkcdr1t       (wire_clk[1]      ),
        .clkcdr1b       (wire_clk[2]      ),
        .clkffpll       (wire_clk[3]      ),
        .clkupseg       (wire_clk[4]      ),
        .clkdnseg       (wire_clk[5]      ),	
        .fref           (fref             ),
        .pciesw         (w_pciesw         ),
        .hfclkpxnup     (wire_hfclkpin    ),
        .lfclkpxnup     (wire_lfclkpin    ),
        .cpulsexnup     (wire_cpulsein    ),
        .pclkxnup       (wire_pclkin      ),
        .rxclk          (                 ), //to pma_rx_pma_clk
    
        // to serializer
        .cpulse         (cpulse_from_cgb_master  ),
        .hfclkp         (hclk_from_cgb_master    ),
        .lfclkp         (lfclk_from_cgb_master   ),
        .pclk           (pclk_from_cgb_master    ),
    
        // when used as a CGB master, these are bonding clocks
        .cpulseout      (wire_cpulseout   ),
        .hfclkpout      (wire_hfclkpout   ),
        .lfclkpout      (wire_lfclkpout   ),
        .pclkout        (wire_pclkout     ),
        .pcieswdone     (pcieswdone       ),
		
        .avmmrstn       (avmmrstn_master     ),
        .avmmclk        (avmmclk_master      ),
        .avmmwrite      (avmmwrite_master    ),
        .avmmread       (avmmread_master     ),
        .avmmbyteen     (avmmbyteen_master   ),
        .avmmaddress    (avmmaddress_master  ),
        .avmmwritedata  (avmmwritedata_master),
        .avmmreaddata   (avmmreaddata_master ),
        .blockselect    (blockselect_master  ),
    
      
      
        // synopsys translate_off
        //.clklct         (1'b0/*TODO*/     ),
        //.clklcb         (1'b0/*TODO*/     ),
        .hfclkn         (                 ),
        .hfclknout      (                 ),
        .lfclkn         (                 ),
        .lfclknout      (                 ),
        .rxiqclk        (                 ),
        .clkbcdr1t      (1'b0             ),
        .clkbcdr1b      (1'b0             ),
        .clkbcdrloc     (1'b0             ),
        .clkbdnseg      (1'b0             ),
        .clkbffpll      (1'b0             ),
        //.clkblcb        (1'b0             ),
        //.clkblct        (1'b0             ),
        .clkbupseg      (1'b0             ),
        .cpulsex6up     (1'b0             ),
        .cpulsex6dn     (1'b0             ),
        .cpulsexndn     (1'b0             ),
        .hfclknx6up     (1'b0             ),
        .hfclknx6dn     (1'b0             ),
        .hfclknxndn     (1'b0             ),
        .hfclknxnup     (1'b0             ),
        .hfclkpx6up     (1'b0             ),
        .hfclkpx6dn     (1'b0             ),
        .hfclkpxndn     (1'b0             ),
        .lfclknx6up     (1'b0             ),
        .lfclknx6dn     (1'b0             ),
        .lfclknxndn     (1'b0             ),
        .lfclknxnup     (1'b0             ),
        .lfclkpx6up     (1'b0             ),
        .lfclkpx6dn     (1'b0             ),
        .lfclkpxndn     (1'b0             ),
        .pciesyncp      (/*TODO*/         ),
        //.pciefbclk      (/*TODO*/         ),
        .pclkx6up       (3'b0             ),
        .pclkx6dn       (3'b0             ),
        .pclkxndn       (3'b0             )
        //.pllfbsw        (/*TODO*/         ),
        //.txpmasyncp     (1'b0             )
        // synopsys translate_on
      );
      defparam tx_cgb.mode = mode;
      //defparam tx_cgb.channel_number = channel_number;
      defparam tx_cgb.auto_negotiation = auto_negotiation;
      defparam tx_cgb.data_rate = data_rate;
      //defparam tx_cgb.fref_vco_bypass = fref_vco_bypass;
  
      defparam tx_cgb.x1_clock_source_sel = 
                     ((is_fb_comp == 1) || 
                      (is_single_chan == 1) ||
                      (is_master_chan == 1) ||
                      (is_master_only == 1)) ? X1_CLOCK_SOURCE_SEL_AUTONEG     // corresponds to .clkcdrloc input
                      : "x1_clk_unused";  // a special setting when the front-end mux of the CGB is not used (SLAVE CHANNEL ONLY)
  
      defparam tx_cgb.xn_clock_source_sel = 
                     (pma_bonding_mode == "xN" && bonded_lanes == 1)? "cgb_xn_unused"
		     :(((is_fb_comp == 1) || 
                      (is_master_chan == 1) ||
                      (is_slave_chan == 1) ||
                      (is_master_only == 1))           ? "xn_up" : // corresponds to *xnup ports
                     ((is_single_chan == 1) && (ht_delay_sel == "true")) ? "cgb_ht" 
                     : "cgb_x1_m_div");

      defparam tx_cgb.x1_div_m_sel = X1_DIV_M_SEL;
    end
  
    // Outputs to AVMM
    // If feedback compensation is not used, signals from CGB connect to/from the AVMM 
    assign avmmreaddata_cgb     = (is_fb_comp == 1) ? 16'd0 
                                  : ((pma_bonding_mode != "xN")? avmmreaddata_master : avmmreaddata_slave); 
    assign blockselect_cgb      = (is_fb_comp == 1) ? 1'd0
                                  : ((pma_bonding_mode != "xN")? blockselect_master : blockselect_slave);
    
    if(pma_bonding_mode == "x1") begin: tx_cgb_master
      // Based on the bonding type, either the master or the slave CGB output ports will be connected to the Serializer. 
      // If the bonding type is not feedback compensation, then the master CGB output ports will be connected to the Serializer  
      assign cpulse_from_cgb = cpulse_from_cgb_master; 
      assign hclk_from_cgb   = hclk_from_cgb_master  ; 
      assign lfclk_from_cgb  = lfclk_from_cgb_master ;
      assign pclk_from_cgb   = pclk_from_cgb_master  ;  
    end else begin
      wire        cpulse_from_cgb_slave  ;
      wire        hclk_from_cgb_slave    ;
      wire        lfclk_from_cgb_slave   ;
      wire  [2:0] pclk_from_cgb_slave    ;

      // slave CGB; This is cascaded to the Master CGB when feedback compensation bonding is used.
      // The cpulseout, hfclkpout, lfclkpout, pclkout, pcieswdone, pciefbclk, pllfbsw, txpmasyncp are left unconnected  
      assign cpulse_from_cgb = cpulse_from_cgb_slave; 
      assign hclk_from_cgb   = hclk_from_cgb_slave  ; 
      assign lfclk_from_cgb  = lfclk_from_cgb_slave ;
      assign pclk_from_cgb   = pclk_from_cgb_slave  ;  
      
      arriav_hssi_pma_tx_cgb tx_cgb_slave (
        .rstn           (wire_rstn             ),
        .clkcdrloc      (1'b0             ),
        .clkcdr1t       (1'b0             ),
        .clkcdr1b       (1'b0             ),
        //.clklct         (1'b0             ),
        //.clklcb         (1'b0             ),
        .clkffpll       (1'b0             ),
        .clkupseg       (1'b0             ),
        .clkdnseg       (1'b0             ),
        .pciesw         (w_pciesw         ),
        .hfclkpxnup     ((external_master_cgb  == 1) ? hfclkpin : wire_hfclkpout   ),
        .lfclkpxnup     ((external_master_cgb  == 1) ? lfclkpin : wire_lfclkpout   ),
        .cpulsexnup     ((external_master_cgb  == 1) ? cpulsein : wire_cpulseout   ),
        .pclkxnup       ((external_master_cgb  == 1) ? pclkin   : wire_pclkout     ),
        .rxclk          (                 ), //to pma_rx_pma_clk
        // to serializer
        .cpulse         (cpulse_from_cgb_slave  ),
        .hfclkp         (hclk_from_cgb_slave    ),
        .lfclkp         (lfclk_from_cgb_slave   ),
        .pclk           (pclk_from_cgb_slave    ),
        
        // when used as a CGB master, these are bonding clocks
        .cpulseout      (                 ),
        .hfclkpout      (                 ),
        .lfclkpout      (                 ),
        .pclkout        (                 ),
        .pcieswdone     (                 ),
        //.pciefbclk      (                 ),
        //.pllfbsw        (                 ),
        //.txpmasyncp     (                 ),
        
        .avmmrstn       (avmmrstn_slave     ),
        .avmmclk        (avmmclk_slave      ),
        .avmmwrite      (avmmwrite_slave    ),
        .avmmread       (avmmread_slave     ),
        .avmmbyteen     (avmmbyteen_slave   ),
        .avmmaddress    (avmmaddress_slave  ),
        .avmmwritedata  (avmmwritedata_slave),
        .avmmreaddata   (avmmreaddata_slave ),
        .blockselect    (blockselect_slave  ),

        // synopsys translate_off
        
        .hfclkn         (                 ),
        .hfclknout      (                 ),
        .lfclkn         (                 ),
        .lfclknout      (                 ),
        .rxiqclk        (                 ),
        .clkbcdr1t      (1'b0             ),
        .clkbcdr1b      (1'b0             ),
        .clkbcdrloc     (1'b0             ),
        .clkbdnseg      (1'b0             ),
        .clkbffpll      (1'b0             ),
        //.clkblcb        (1'b0             ),
        //.clkblct        (1'b0             ),
        .clkbupseg      (1'b0             ),
        .cpulsex6up     (1'b0             ),
        .cpulsex6dn     (1'b0             ),
        .cpulsexndn     (1'b0             ),
        .hfclknx6up     (1'b0             ),
        .hfclknx6dn     (1'b0             ),
        .hfclknxndn     (1'b0             ),
        .hfclknxnup     (1'b0             ),
        .hfclkpx6up     (1'b0             ),
        .hfclkpx6dn     (1'b0             ),
        .hfclkpxndn     (1'b0             ),
        .lfclknx6up     (1'b0             ),
        .lfclknx6dn     (1'b0             ),
        .lfclknxndn     (1'b0             ),
        .lfclknxnup     (1'b0             ),
        .lfclkpx6up     (1'b0             ),
        .lfclkpx6dn     (1'b0             ),
        .lfclkpxndn     (1'b0             ),
        .pciesyncp      (/*TODO*/         ),
        .pclkx6up       (3'b0             ),
        .pclkx6dn       (3'b0             ),
        .pclkxndn       (3'b0             )
        // synopsys translate_on
      );
      defparam tx_cgb_slave.mode = mode;
      defparam tx_cgb_slave.auto_negotiation = auto_negotiation;
      defparam tx_cgb_slave.data_rate = data_rate;
      
      defparam tx_cgb_slave.x1_clock_source_sel = "x1_clk_unused" ; 
      
      defparam tx_cgb_slave.xn_clock_source_sel = (pma_bonding_mode == "xN" && bonded_lanes == 1)? "cgb_x1_m_div" : "xn_up"; 

      defparam tx_cgb_slave.x1_div_m_sel = X1_DIV_M_SEL;
    end
    
    arriav_hssi_pma_tx_ser tx_pma_ser (
      .cpulse         (cpulse_from_cgb  ),
      .datain         (w_datain         ),
      .hfclk          (hclk_from_cgb    ),
      .lfclk          (lfclk_from_cgb   ),
      .pclk           (pclk_from_cgb    ),
      //.pciesw         (w_pciesw         ),
      .rstn           (rstn             ),
      .clkdivtx       (clkdivtx         ),
      .dataout        (dataout_from_ser ),
      .lbvop          (seriallpbkout    ),
      .slpbk          (seriallpbken     ),
      .hfclkn         (1'b0             ),
      .lfclkn         (1'b0             ),
      //.lbvon          (/*TODO*/         ),
      .preenout       (/*TODO*/         ),
      //.pciesyncp      (/*TODO*/         ),
      .avmmrstn       (avmmrstn         ),
      .avmmclk        (avmmclk          ),
      .avmmwrite      (avmmwrite        ),
      .avmmread       (avmmread         ),
      .avmmbyteen     (avmmbyteen       ),
      .avmmaddress    (avmmaddress      ),
      .avmmwritedata  (avmmwritedata    ),
      .avmmreaddata   (avmmreaddata_ser ),
      .blockselect    (blockselect_ser  )
    );
    defparam tx_pma_ser.mode = mode;
    defparam tx_pma_ser.auto_negotiation = auto_negotiation;
    defparam tx_pma_ser.ser_loopback = ser_loopback;
    defparam tx_pma_ser.clk_forward_only_mode = 
                     (is_master_only == 1) ? "true" : "false";
    defparam tx_pma_ser.pma_direct = pma_direct;
    

    if (is_master_only == 0) begin:tx_pma_buf
      wire nonuserfrompmaux;
      wire atb0outtopllaux;
      wire atb1outtopllaux;
      
      arriav_hssi_pma_aux tx_pma_aux (
        .calpdb       (1'b1             ),
        .calclk       (calclk           ),
        .testcntl     (/*unused*/       ),
        .refiqclk     (refiqclk         ),
        .nonusertoio  (nonuserfrompmaux ),
        .zrxtx50      (/*unused*/       ),
	.atb0out (atb0outtopllaux),
        .atb1out (atb1outtopllaux)
      ); 
                    
      arriav_hssi_pma_tx_buf #(
        .rx_det_pdb(rx_det_pdb),
        .fir_coeff_ctrl_sel(fir_coeff_ctrl_sel)
      ) tx_pma_buf (
        .nonuserfrompmaux (nonuserfrompmaux ),
        .datain           (dataout_from_ser ),
        .rxdetclk         (w_rxdetclk       ),
        .txdetrx          (w_txdetrx        ),
        .txelecidl        (w_txelecidl      ),
        .rxdetectvalid    (rxdetectvalid    ),
        .dataout          (dataout          ),
        .rxfound          (rxfound          ),
        //.txqpipulldn      (1'b0             ),
        //.txqpipullup      (1'b0             ),
        .fixedclkout      (/*TODO*/         ),
        .vrlpbkn          (vrlpbkn          ),
        .vrlpbkp          (vrlpbkp          ),
        .vrlpbkp1t        (/*TODO*/         ),
        .vrlpbkn1t        (/*TODO*/         ),
        .icoeff           (icoeff           ),
        .avmmrstn         (avmmrstn         ),
        .avmmclk          (avmmclk          ),
        .avmmwrite        (avmmwrite        ),
        .avmmread         (avmmread         ),
        .avmmbyteen       (avmmbyteen       ),
        .avmmaddress      (avmmaddress      ),
        .avmmwritedata    (avmmwritedata    ),
        .avmmreaddata     (avmmreaddata_buf ),
        .blockselect      (blockselect_buf  )
      );
      
      if ( enable_dcd == 1 ) begin
      //pll aux for DCD calibration
      arriav_pll_aux pll_aux (
        .atb0out(atb0outtopllaux),
        .atb1out(atb1outtopllaux),
        .atbcompout(atb_comp_out)
      );
      end else begin
        assign atb_comp_out = 1'b0;
      end
    end // end of if (is_master_only == 0)
  end else begin  // if dummy_chan
    // Warning avoidance
    assign  dataout = {1'b0,calclk,datain,txelecidl,rxdetclk,txdetrx,
              rstn,seriallpbken,clk,pciesw,1'b0,cpulsein,
              hfclkpin,lfclkpin,pclkin,avmmrstn,avmmclk,avmmwrite,
              avmmread,avmmbyteen,avmmaddress,avmmwritedata, 
              vrlpbkp,vrlpbkn};

    assign  rxdetectvalid = 1'b0;
    assign  rxfound       = 1'b0;
    assign  clkdivtx      = 1'b0;
    assign  seriallpbkout = 1'b0;
    assign  pcieswdone    = 2'b00;
    assign  hfclkpout     = 1'b0;
    assign  lfclkpout     = 1'b0;
    assign  cpulseout     = 1'b0;
    assign  pclkout       = 3'b000;
    
    assign  avmmreaddata_cgb  = 16'd0;
    assign  avmmreaddata_ser  = 16'd0;
    assign  avmmreaddata_buf  = 16'd0;
    assign  blockselect_cgb   = 1'b0;
    assign  blockselect_ser   = 1'b0;
    assign  blockselect_buf   = 1'b0;
  end	    

  endgenerate  

initial begin
  if( (tx_clk_div != 1) && (tx_clk_div != 2) && (tx_clk_div != 4) && (tx_clk_div != 8) ) begin
    $display("Critical Warning: parameter 'tx_clk_div' of instance '%m' has illegal value '%0d' assigned to it. Valid parameter values are: '1,2,4,8'. Using value '%0d'", tx_clk_div, X1_DIV_M_SEL);
  end
end

endmodule

                
