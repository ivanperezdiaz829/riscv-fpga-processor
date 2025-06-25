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


// (C) 2001-2011 Altera Corporation. All rights reserved.
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
// the cv_tx_pma block will instantiate a simple pipeline of cgb -> 
// ser -> tx_buf. It requires that a high frequency clock be connected to
// 'clk' input port. 'datain' and 'dataout' have to be connected as 
// expected.
//
// (2) MASTER_SINGLE_CHANNEL --
//
// the cv_tx_pma block will instantiate a simple pipeline of cgb -> 
// ser -> tx_buf. It requires that a high frequency clock be connected to
// 'clk' input port. In addition, the module outputs the bonding clocks via ports
// (hfclkpout, lfclkpout,cpulseout,pclk0out,pclk1out). These clocks must be
// connected to another instance of cv_tx_pma_ch that serves as SLAVE_CHANNEL. 
// 'datain' and 'dataout' have to be connected as expected.
//
// (3) SLAVE_CHANNEL --
//
// the cv_tx_pma block will instantiate a simple pipeline of cgb -> 
// ser -> tx_buf. The cgb in this case is not used to divide the high frequency clock 
// from the tx pll, but to forward the bonding clocks to the serializer. It is required that
// the bonding clock bondle is connected to the inputs (hfclkpin, lfclkpin,cpulsein, 
// pclk0in,pclk1in). These clocks must come from a cv_tx_pma_ch block that serves 
// as MASTER_SINGLE_CHANNEL or as MASTER_ONLY. 
// 'datain' and 'dataout' have to be connected as expected.
//
// (4) MASTER_ONLY
//
// the cv_tx_pma_ch block will only instantiate a cgb -> ser. The cgb is used to divide the
// high frequency clock from the tx pll (input clk) and produce bonding clocks via ports
// (hfclkpout, lfclkpout,cpulseout,pclk0out,pclk1out). The serializer block in this case is
// configured in a special clk_forward_only_mode = true. This indicates that the serializer
// does not serve its usual role of converting data on a parallel bus input into a serial output,
// but serves to only forward the parallel clock from the cgb to the output clkdivtx.
// 

`timescale 1ps/1ps
module cv_tx_pma_ch #(
    parameter mode = 8,
    parameter channel_number    = 0,
    parameter auto_negotiation  = "true",
    parameter plls              = 1,
    parameter pll_sel           = 0,
    parameter ser_loopback      = "false",
    parameter ht_delay_sel      = "false",
    parameter tx_pma_type       = "SINGLE_CHANNEL",
    parameter data_rate         = "0 ps",
    parameter rx_det_pdb        = "true",
    parameter tx_clk_div        = 1, //(1,2,4,8)
	 parameter pcie_rst          = "NORMAL_RESET",
	 parameter fref_vco_bypass   = "NORMAL_OPERATION"
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
     
  input               vrlpbkp,
  input               vrlpbkn  
);

  localparam  MAX_PLLS = 7;
  localparam  PLL_CNT = (plls < MAX_PLLS) ? plls : MAX_PLLS;

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

  wire  [MAX_PLLS-1:0] wire_clk;

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

  generate 
  
  // determine what drives the bonding lines input to the CGB
  
  assign wire_hfclkpin = (tx_pma_type == "SINGLE_CHANNEL") ? 1'b0 // don't need a bonding clock
                         : (((tx_pma_type == "MASTER_SINGLE_CHANNEL") || 
                             (tx_pma_type == "MASTER_ONLY")) ? wire_hfclkpout // create a self-loop
                         : hfclkpin); // driven by the input
  
  assign wire_lfclkpin = (tx_pma_type == "SINGLE_CHANNEL") ? 1'b0 // don't need a bonding clock
                         : (((tx_pma_type == "MASTER_SINGLE_CHANNEL") ||
                             (tx_pma_type == "MASTER_ONLY")) ? wire_lfclkpout // create a self-loop
                         : lfclkpin); // driven by the input
  
  assign wire_cpulsein = (tx_pma_type == "SINGLE_CHANNEL") ? 1'b0 // don't need a bonding clock
                         : (((tx_pma_type == "MASTER_SINGLE_CHANNEL") ||
                             (tx_pma_type == "MASTER_ONLY")) ? wire_cpulseout // create a self-loop
                         : cpulsein); // driven by the input
  
  assign wire_pclkin = (tx_pma_type == "SINGLE_CHANNEL") ? 1'b0 // don't need a bonding clock
                         : (((tx_pma_type == "MASTER_SINGLE_CHANNEL") ||
                             (tx_pma_type == "MASTER_ONLY")) ? wire_pclkout // create a self-loop
                         : pclkin); // driven by the input
  
  
  // determine what drives the bonding lines output from this module
  assign hfclkpout = ((tx_pma_type == "SINGLE_CHANNEL") || 
                      (tx_pma_type == "SLAVE_CHANNEL")) ? 1'b0  // don't to generate a bonding clock
                      : wire_hfclkpout; // driven by the input
  
  assign lfclkpout = ((tx_pma_type == "SINGLE_CHANNEL") || 
                      (tx_pma_type == "SLAVE_CHANNEL")) ? 1'b0  // don't to generate a bonding clock
                      : wire_lfclkpout; // driven by the input
  
  assign cpulseout = ((tx_pma_type == "SINGLE_CHANNEL") || 
                      (tx_pma_type == "SLAVE_CHANNEL")) ? 1'b0  // don't to generate a bonding clock
                      : wire_cpulseout; // driven by the input
  
  assign pclkout = ((tx_pma_type == "SINGLE_CHANNEL") || 
                    (tx_pma_type == "SLAVE_CHANNEL")) ? 1'b0  // don't to generate a bonding clock
                    : wire_pclkout; // driven by the input
  
  
  // determine what drives the HF clock input into CGB
  assign wire_clk = (tx_pma_type == "SLAVE_CHANNEL") ? {MAX_PLLS{1'b0}} // no clock can be connected in a slave mode
                    : {{(7-PLL_CNT){1'b0}},clk};  // otherwise, connect the input clock
						  
  assign wire_rstn = (pcie_rst == "NORMAL_RESET") ? rstn
                    : 1'b1;
  
  assign wire_pcsrstn = (pcie_rst == "PCIE_RESET") ? pcsrstn
                    : 1'b1;

  assign wire_fref = (fref_vco_bypass == "FREF_BYPASS") ? fref
                    : 1'b0;
  
  cyclonev_hssi_pma_tx_cgb tx_cgb (
    .rstn           (wire_rstn             ),
	.pcsrstn        (wire_pcsrstn          ),
    .clkcdrloc      (wire_clk[0]      ),  // Switch between this
//  .clkcdr1t       (wire_clk[1]      ),
//  .clkcdr1b       (wire_clk[2]      ),
//  .clkffpll       (wire_clk[3]      ),
//  .clklct         (wire_clk[4]      ),
//  .clklcb         (wire_clk[5]      ),
//  .clkupseg       (wire_clk[6]      ),
    .fref           (fref             ),
    .pciesw         (pciesw           ),
    .hfclkpxnup     (wire_hfclkpin    ),
    .lfclkpxnup     (wire_lfclkpin    ),
    .cpulsexnup     (wire_cpulsein    ),
    .pclkxnup       (wire_pclkin      ),
    .rxclk          (                 ), //to pma_rx_pma_clk
    
    // to serializer
    .cpulse         (cpulse_from_cgb  ),
    .hfclkp         (hclk_from_cgb    ),
    .lfclkp         (lfclk_from_cgb   ),
    .pclk           (pclk_from_cgb    ),
    
    // when used as a CGB master, these are bonding clocks
    .cpulseout      (wire_cpulseout   ),
    .hfclkpout      (wire_hfclkpout   ),
    .lfclkpout      (wire_lfclkpout   ),
    .pclkout        (wire_pclkout     ),
    .hfclkn         (                 ),
    .hfclknout      (                 ),
    .lfclkn         (                 ),
    .lfclknout      (                 ),
    .rxiqclk        (                 ),
    .pcieswdone     (pcieswdone       )
    

// synopsys translate_off
    ,
    .clkcdr1t       (1'b0/*TODO*/     ),  // TODO - reconnect to clock inputs after fitter fixes
    .clkcdr1b       (1'b0/*TODO*/     ),
    .clkffpll       (1'b0/*TODO*/     ),
    //.clklct         (1'b0/*TODO*/     ),
    //.clklcb         (1'b0/*TODO*/     ),
    .clkupseg       (1'b0/*TODO*/     ),
    .clkbcdr1t      (1'b0             ),
    .clkbcdr1b      (1'b0             ),
    .clkbcdrloc     (1'b0             ),
    .clkbdnseg      (1'b0             ),
    .clkbffpll      (1'b0             ),
    //.clkblcb        (1'b0             ),
    //.clkblct        (1'b0             ),
    .clkbupseg      (1'b0             ),
    .clkdnseg       (1'b0             ),
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
  defparam tx_cgb.channel_number = channel_number;
  defparam tx_cgb.auto_negotiation = auto_negotiation;
  defparam tx_cgb.data_rate = data_rate;
  
  defparam tx_cgb.x1_clock_source_sel = 
                   ((tx_pma_type == "SINGLE_CHANNEL") ||
                    (tx_pma_type == "MASTER_SINGLE_CHANNEL") ||
                    (tx_pma_type == "MASTER_ONLY")) ? X1_CLOCK_SOURCE_SEL_AUTONEG     // corresponds to .clkcdrloc input
					: "x1_clk_unused";  // a special setting when the front-end mux of the CGB is not used (SLAVE CHANNEL ONLY)
  
  defparam tx_cgb.xn_clock_source_sel = 
                   ((tx_pma_type == "MASTER_SINGLE_CHANNEL") ||
                    (tx_pma_type == "SLAVE_CHANNEL") ||
                    (tx_pma_type == "MASTER_ONLY"))           ? "xn_up" : // corresponds to *xnup ports
                   ((tx_pma_type == "SINGLE_CHANNEL") && (ht_delay_sel == "true")) ? "cgb_ht" 
                   : "cgb_x1_m_div";
                   
  defparam tx_cgb.x1_div_m_sel = X1_DIV_M_SEL;
  
  cyclonev_hssi_pma_tx_ser tx_pma_ser (
    .cpulse         (cpulse_from_cgb  ),
    .datain         (datain           ),
    .hfclk          (hclk_from_cgb    ),
    .lfclk          (lfclk_from_cgb   ),
    .pclk           (pclk_from_cgb    ),
    //.pciesw         (pciesw           ),
    .rstn           (rstn             ),
    .clkdivtx       (clkdivtx         ),
    .dataout        (dataout_from_ser ),
    .lbvop          (seriallpbkout    ),
    .slpbk          (seriallpbken     ),
    .hfclkn         (1'b0             ),
    .lfclkn         (1'b0             ),
    .preenout       (/*TODO*/         )
    //.pciesyncp      (/*TODO*/         )
  );
  defparam tx_pma_ser.mode = mode;
  defparam tx_pma_ser.channel_number = channel_number; 
  defparam tx_pma_ser.auto_negotiation = auto_negotiation;
  defparam tx_pma_ser.ser_loopback = ser_loopback;
  defparam tx_pma_ser.clk_forward_only_mode = 
                   (tx_pma_type == "MASTER_ONLY") ? "true" : "false";
  
  if (tx_pma_type != "MASTER_ONLY") begin: c

    wire nonuserfrompmaux;
    
    cyclonev_hssi_pma_aux #(
        .continuous_calibration ("true")
      ) tx_pma_aux (
      .calpdb       (1'b1             ),
      .calclk       (calclk           ),
      .testcntl     (/*unused*/       ),
      .refiqclk     (/*unused*/       ),
      .nonusertoio  (nonuserfrompmaux ),
      .zrxtx50      (/*unused*/       )
    ); 
                  
    cyclonev_hssi_pma_tx_buf #(
      .channel_number(channel_number),
      .rx_det_pdb(rx_det_pdb)
    ) tx_pma_buf (
      .nonuserfrompmaux (nonuserfrompmaux ),
      .datain           (dataout_from_ser ),
      .rxdetclk         (rxdetclk         ),
      .txdetrx          (txdetrx          ),
      .txelecidl        (txelecidl        ),
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
      .icoeff           (/*TODO*/         )
    );
  end // end of if (tx_pma_type == "SINGLE_CHANNEL")
  endgenerate

initial begin
  if( (tx_clk_div != 1) && (tx_clk_div != 2) && (tx_clk_div != 4) && (tx_clk_div != 8) ) begin
    $display("Critical Warning: parameter 'tx_clk_div' of instance '%m' has illegal value '%0d' assigned to it. Valid parameter values are: '1,2,4,8'. Using value '%0d'", tx_clk_div, X1_DIV_M_SEL);
  end
end
        
endmodule

                
