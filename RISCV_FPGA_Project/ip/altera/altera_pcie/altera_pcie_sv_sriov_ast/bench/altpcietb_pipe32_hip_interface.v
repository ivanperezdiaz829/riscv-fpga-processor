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


// Stratix V Hard IP PIPE 32-bit interface
// Reference : PHY Interface for the PCI Express Architecture specification v2.00 and higher
//
module altpcietb_pipe32_hip_interface (
      output nop_out
);

// PIPE interface signals
wire [17:0]     currentcoeff0      ;//  HIP output  : Used for G3 only - set coefficient  .
wire [17:0]     currentcoeff1      ;//  HIP output  : Used for G3 only - set coefficient  .
wire [17:0]     currentcoeff2      ;//  HIP output  : Used for G3 only - set coefficient  .
wire [17:0]     currentcoeff3      ;//  HIP output  : Used for G3 only - set coefficient  .
wire [17:0]     currentcoeff4      ;//  HIP output  : Used for G3 only - set coefficient  .
wire [17:0]     currentcoeff5      ;//  HIP output  : Used for G3 only - set coefficient  .
wire [17:0]     currentcoeff6      ;//  HIP output  : Used for G3 only - set coefficient  .
wire [17:0]     currentcoeff7      ;//  HIP output  : Used for G3 only - set coefficient  .
wire [2:0]      currentrxpreset0   ;//  HIP output  : Used for G3 only - set preset  .
wire [2:0]      currentrxpreset1   ;//  HIP output  : Used for G3 only - set preset  .
wire [2:0]      currentrxpreset2   ;//  HIP output  : Used for G3 only - set preset  .
wire [2:0]      currentrxpreset3   ;//  HIP output  : Used for G3 only - set preset  .
wire [2:0]      currentrxpreset4   ;//  HIP output  : Used for G3 only - set preset  .
wire [2:0]      currentrxpreset5   ;//  HIP output  : Used for G3 only - set preset  .
wire [2:0]      currentrxpreset6   ;//  HIP output  : Used for G3 only - set preset  .
wire [2:0]      currentrxpreset7   ;//  HIP output  : Used for G3 only - set preset  .
wire [1:0]      ratectrl           ;//  HIP output  : .
wire [1:0]      rate0              ;//  HIP output  : Indicates G1/G2/G3 rate.
wire [1:0]      rate1              ;//  HIP output  : Indicates G1/G2/G3 rate.
wire [1:0]      rate2              ;//  HIP output  : Indicates G1/G2/G3 rate.
wire [1:0]      rate3              ;//  HIP output  : Indicates G1/G2/G3 rate.
wire [1:0]      rate4              ;//  HIP output  : Indicates G1/G2/G3 rate.
wire [1:0]      rate5              ;//  HIP output  : Indicates G1/G2/G3 rate.
wire [1:0]      rate6              ;//  HIP output  : Indicates G1/G2/G3 rate.
wire [1:0]      rate7              ;//  HIP output  : Indicates G1/G2/G3 rate.
wire [2:0]      eidleinfersel0     ;//  HIP output  : Electrical IDLE infer.
wire [2:0]      eidleinfersel1     ;//  HIP output  : Electrical IDLE infer.
wire [2:0]      eidleinfersel2     ;//  HIP output  : Electrical IDLE infer.
wire [2:0]      eidleinfersel3     ;//  HIP output  : Electrical IDLE infer.
wire [2:0]      eidleinfersel4     ;//  HIP output  : Electrical IDLE infer.
wire [2:0]      eidleinfersel5     ;//  HIP output  : Electrical IDLE infer.
wire [2:0]      eidleinfersel6     ;//  HIP output  : Electrical IDLE infer.
wire [2:0]      eidleinfersel7     ;//  HIP output  : Electrical IDLE infer.

// interface with the PHY PCS Lane 0
wire [31:0]     txdata0            ;//  HIP output  : .
wire [3:0]      txdatak0           ;//  HIP output  : .
wire            txdetectrx0        ;//  HIP output  : .
wire            txelecidle0        ;//  HIP output  : .
wire            txcompl0           ;//  HIP output  : .
wire            rxpolarity0        ;//  HIP output  : .
wire [1:0]      powerdown0         ;//  HIP output  : .
wire            txdataskip0        ;//  HIP output  : .
wire            txblkst0           ;//  HIP output  : .
wire [1:0]      txsynchd0          ;//  HIP output  : .
wire            txdeemph0          ;//  HIP output  : .
wire [2:0]      txmargin0          ;//  HIP output  : .
wire            txswing0           ;//  HIP output  : .

reg  [31:0]    rxdata0            ;//  HIP input   : .
reg  [3:0]     rxdatak0           ;//  HIP input   : .
reg            rxvalid0           ;//  HIP input   : .
reg            phystatus0         ;//  HIP input   : .
reg            rxelecidle0        ;//  HIP input   : .
reg  [2:0]     rxstatus0          ;//  HIP input   : .
reg            rxdataskip0        ;//  HIP input   : .
reg            rxblkst0           ;//  HIP input   : .
reg  [1:0]     rxsynchd0          ;//  HIP input   : .
reg            rxfreqlocked0      ;//  HIP input   : .

// interface with the PHY PCS Lane 1
wire [31:0]     txdata1            ;//  HIP output  : .
wire [3:0]      txdatak1           ;//  HIP output  : .
wire            txdetectrx1        ;//  HIP output  : .
wire            txelecidle1        ;//  HIP output  : .
wire            txcompl1           ;//  HIP output  : .
wire            rxpolarity1        ;//  HIP output  : .
wire [1:0]      powerdown1         ;//  HIP output  : .
wire            txdataskip1        ;//  HIP output  : .
wire            txblkst1           ;//  HIP output  : .
wire [1:0]      txsynchd1          ;//  HIP output  : .
wire            txdeemph1          ;//  HIP output  : .
wire [2:0]      txmargin1          ;//  HIP output  : .
wire            txswing1           ;//  HIP output  : .

reg  [31:0]    rxdata1            ;//  HIP input   : .
reg  [3:0]     rxdatak1           ;//  HIP input   : .
reg            rxvalid1           ;//  HIP input   : .
reg            phystatus1         ;//  HIP input   : .
reg            rxelecidle1        ;//  HIP input   : .
reg  [2:0]     rxstatus1          ;//  HIP input   : .
reg            rxdataskip1        ;//  HIP input   : .
reg            rxblkst1           ;//  HIP input   : .
reg  [1:0]     rxsynchd1          ;//  HIP input   : .
reg            rxfreqlocked1      ;//  HIP input   : .

// interface with the PHY PCS Lane 2
wire [31:0]     txdata2            ;//  HIP output  : .
wire [3:0]      txdatak2           ;//  HIP output  : .
wire            txdetectrx2        ;//  HIP output  : .
wire            txelecidle2        ;//  HIP output  : .
wire            txcompl2           ;//  HIP output  : .
wire            rxpolarity2        ;//  HIP output  : .
wire [1:0]      powerdown2         ;//  HIP output  : .
wire            txdataskip2        ;//  HIP output  : .
wire            txblkst2           ;//  HIP output  : .
wire [1:0]      txsynchd2          ;//  HIP output  : .
wire            txdeemph2          ;//  HIP output  : .
wire [2:0]      txmargin2          ;//  HIP output  : .
wire            txswing2           ;//  HIP output  : .

reg  [31:0]    rxdata2            ;//  HIP input   : .
reg  [3:0]     rxdatak2           ;//  HIP input   : .
reg            rxvalid2           ;//  HIP input   : .
reg            phystatus2         ;//  HIP input   : .
reg            rxelecidle2        ;//  HIP input   : .
reg  [2:0]     rxstatus2          ;//  HIP input   : .
reg            rxdataskip2        ;//  HIP input   : .
reg            rxblkst2           ;//  HIP input   : .
reg  [1:0]     rxsynchd2          ;//  HIP input   : .
reg            rxfreqlocked2      ;//  HIP input   : .

// interface with the PHY PCS Lane 3
wire [31:0]     txdata3            ;//  HIP output  : .
wire [3:0]      txdatak3           ;//  HIP output  : .
wire            txdetectrx3        ;//  HIP output  : .
wire            txelecidle3        ;//  HIP output  : .
wire            txcompl3           ;//  HIP output  : .
wire            rxpolarity3        ;//  HIP output  : .
wire [1:0]      powerdown3         ;//  HIP output  : .
wire            txdataskip3        ;//  HIP output  : .
wire            txblkst3           ;//  HIP output  : .
wire [1:0]      txsynchd3          ;//  HIP output  : .
wire            txdeemph3          ;//  HIP output  : .
wire [2:0]      txmargin3          ;//  HIP output  : .
wire            txswing3           ;//  HIP output  : .

reg  [31:0]    rxdata3            ;//  HIP input   : .
reg  [3:0]     rxdatak3           ;//  HIP input   : .
reg            rxvalid3           ;//  HIP input   : .
reg            phystatus3         ;//  HIP input   : .
reg            rxelecidle3        ;//  HIP input   : .
reg  [2:0]     rxstatus3          ;//  HIP input   : .
reg            rxdataskip3        ;//  HIP input   : .
reg            rxblkst3           ;//  HIP input   : .
reg  [1:0]     rxsynchd3          ;//  HIP input   : .
reg            rxfreqlocked3      ;//  HIP input   : .

// interface with the PHY PCS Lane 4
wire [31:0]     txdata4            ;//  HIP output  : .
wire [3:0]      txdatak4           ;//  HIP output  : .
wire            txdetectrx4        ;//  HIP output  : .
wire            txelecidle4        ;//  HIP output  : .
wire            txcompl4           ;//  HIP output  : .
wire            rxpolarity4        ;//  HIP output  : .
wire [1:0]      powerdown4         ;//  HIP output  : .
wire            txdataskip4        ;//  HIP output  : .
wire            txblkst4           ;//  HIP output  : .
wire [1:0]      txsynchd4          ;//  HIP output  : .
wire            txdeemph4          ;//  HIP output  : .
wire [2:0]      txmargin4          ;//  HIP output  : .
wire            txswing4           ;//  HIP output  : .

reg  [31:0]    rxdata4            ;//  HIP input   : .
reg  [3:0]     rxdatak4           ;//  HIP input   : .
reg            rxvalid4           ;//  HIP input   : .
reg            phystatus4         ;//  HIP input   : .
reg            rxelecidle4        ;//  HIP input   : .
reg  [2:0]     rxstatus4          ;//  HIP input   : .
reg            rxdataskip4        ;//  HIP input   : .
reg            rxblkst4           ;//  HIP input   : .
reg  [1:0]     rxsynchd4          ;//  HIP input   : .
reg            rxfreqlocked4      ;//  HIP input   : .

// interface with the PHY PCS Lane 5
wire [31:0]     txdata5            ;//  HIP output  : .
wire [3:0]      txdatak5           ;//  HIP output  : .
wire            txdetectrx5        ;//  HIP output  : .
wire            txelecidle5        ;//  HIP output  : .
wire            txcompl5           ;//  HIP output  : .
wire            rxpolarity5        ;//  HIP output  : .
wire [1:0]      powerdown5         ;//  HIP output  : .
wire            txdataskip5        ;//  HIP output  : .
wire            txblkst5           ;//  HIP output  : .
wire [1:0]      txsynchd5          ;//  HIP output  : .
wire            txdeemph5          ;//  HIP output  : .
wire [2:0]      txmargin5          ;//  HIP output  : .
wire            txswing5           ;//  HIP output  : .

reg  [31:0]    rxdata5            ;//  HIP input   : .
reg  [3:0]     rxdatak5           ;//  HIP input   : .
reg            rxvalid5           ;//  HIP input   : .
reg            phystatus5         ;//  HIP input   : .
reg            rxelecidle5        ;//  HIP input   : .
reg  [2:0]     rxstatus5          ;//  HIP input   : .
reg            rxdataskip5        ;//  HIP input   : .
reg            rxblkst5           ;//  HIP input   : .
reg  [1:0]     rxsynchd5          ;//  HIP input   : .
reg            rxfreqlocked5      ;//  HIP input   : .

// interface with the PHY PCS Lane 6
wire [31:0]     txdata6            ;//  HIP output  : .
wire [3:0]      txdatak6           ;//  HIP output  : .
wire            txdetectrx6        ;//  HIP output  : .
wire            txelecidle6        ;//  HIP output  : .
wire            txcompl6           ;//  HIP output  : .
wire            rxpolarity6        ;//  HIP output  : .
wire [1:0]      powerdown6         ;//  HIP output  : .
wire            txdataskip6        ;//  HIP output  : .
wire            txblkst6           ;//  HIP output  : .
wire [1:0]      txsynchd6          ;//  HIP output  : .
wire            txdeemph6          ;//  HIP output  : .
wire [2:0]      txmargin6          ;//  HIP output  : .
wire            txswing6           ;//  HIP output  : .

reg  [31:0]    rxdata6            ;//  HIP input   : .
reg  [3:0]     rxdatak6           ;//  HIP input   : .
reg            rxvalid6           ;//  HIP input   : .
reg            phystatus6         ;//  HIP input   : .
reg            rxelecidle6        ;//  HIP input   : .
reg  [2:0]     rxstatus6          ;//  HIP input   : .
reg            rxdataskip6        ;//  HIP input   : .
reg            rxblkst6           ;//  HIP input   : .
reg  [1:0]     rxsynchd6          ;//  HIP input   : .
reg            rxfreqlocked6      ;//  HIP input   : .

// interface with the PHY PCS Lane 7
wire [31:0]     txdata7            ;//  HIP output  : .
wire [3:0]      txdatak7           ;//  HIP output  : .
wire            txdetectrx7        ;//  HIP output  : .
wire            txelecidle7        ;//  HIP output  : .
wire            txcompl7           ;//  HIP output  : .
wire            rxpolarity7        ;//  HIP output  : .
wire [1:0]      powerdown7         ;//  HIP output  : .
wire            txdataskip7        ;//  HIP output  : .
wire            txblkst7           ;//  HIP output  : .
wire [1:0]      txsynchd7          ;//  HIP output  : .
wire            txdeemph7          ;//  HIP output  : .
wire [2:0]      txmargin7          ;//  HIP output  : .
wire            txswing7           ;//  HIP output  : .

reg  [31:0]    rxdata7            ;//  HIP input   : .
reg  [3:0]     rxdatak7           ;//  HIP input   : .
reg            rxvalid7           ;//  HIP input   : .
reg            phystatus7         ;//  HIP input   : .
reg            rxelecidle7        ;//  HIP input   : .
reg  [2:0]     rxstatus7          ;//  HIP input   : .
reg            rxdataskip7        ;//  HIP input   : .
reg            rxblkst7           ;//  HIP input   : .
reg  [1:0]     rxsynchd7          ;//  HIP input   : .
reg            rxfreqlocked7      ;//  HIP input   : .

reg            pipe_pclk          ;
reg            pipe_pclkch1       ;
reg            pipe_pclkcentral   ;
reg            pllfixedclkch0     ;
reg            pllfixedclkch1     ;
reg            pllfixedclkcentral ;

assign nop_out = 1'b0; // no op
//=====================================
//
 `define HIP_256_PIPEN1B  top_tb.top_inst.dut.altpcie_sv_hip_ast_hwtcl.altpcie_hip_256_pipen1b


assign    currentcoeff0     = `HIP_256_PIPEN1B.currentcoeff0   ;//  HIP output  : Used for G3 only - set coefficient  .
assign    currentcoeff1     = `HIP_256_PIPEN1B.currentcoeff1   ;//  HIP output  : Used for G3 only - set coefficient  .
assign    currentcoeff2     = `HIP_256_PIPEN1B.currentcoeff2   ;//  HIP output  : Used for G3 only - set coefficient  .
assign    currentcoeff3     = `HIP_256_PIPEN1B.currentcoeff3   ;//  HIP output  : Used for G3 only - set coefficient  .
assign    currentcoeff4     = `HIP_256_PIPEN1B.currentcoeff4   ;//  HIP output  : Used for G3 only - set coefficient  .
assign    currentcoeff5     = `HIP_256_PIPEN1B.currentcoeff5   ;//  HIP output  : Used for G3 only - set coefficient  .
assign    currentcoeff6     = `HIP_256_PIPEN1B.currentcoeff6   ;//  HIP output  : Used for G3 only - set coefficient  .
assign    currentcoeff7     = `HIP_256_PIPEN1B.currentcoeff7   ;//  HIP output  : Used for G3 only - set coefficient  .
assign    currentrxpreset0  = `HIP_256_PIPEN1B.currentrxpreset0    ;//  HIP output  : Used for G3 only - set preset  .
assign    currentrxpreset1  = `HIP_256_PIPEN1B.currentrxpreset1    ;//  HIP output  : Used for G3 only - set preset  .
assign    currentrxpreset2  = `HIP_256_PIPEN1B.currentrxpreset2    ;//  HIP output  : Used for G3 only - set preset  .
assign    currentrxpreset3  = `HIP_256_PIPEN1B.currentrxpreset3    ;//  HIP output  : Used for G3 only - set preset  .
assign    currentrxpreset4  = `HIP_256_PIPEN1B.currentrxpreset4    ;//  HIP output  : Used for G3 only - set preset  .
assign    currentrxpreset5  = `HIP_256_PIPEN1B.currentrxpreset5    ;//  HIP output  : Used for G3 only - set preset  .
assign    currentrxpreset6  = `HIP_256_PIPEN1B.currentrxpreset6    ;//  HIP output  : Used for G3 only - set preset  .
assign    currentrxpreset7  = `HIP_256_PIPEN1B.currentrxpreset7    ;//  HIP output  : Used for G3 only - set preset  .
assign    ratectrl          = `HIP_256_PIPEN1B.ratectrl;//  HIP output  : .


assign    rate0            = `HIP_256_PIPEN1B.rate0            ;//  HIP output  : Indicates G1/G2/G3 rate.
assign    rate1            = `HIP_256_PIPEN1B.rate1            ;//  HIP output  : Indicates G1/G2/G3 rate.
assign    rate2            = `HIP_256_PIPEN1B.rate2            ;//  HIP output  : Indicates G1/G2/G3 rate.
assign    rate3            = `HIP_256_PIPEN1B.rate3            ;//  HIP output  : Indicates G1/G2/G3 rate.
assign    rate4            = `HIP_256_PIPEN1B.rate4            ;//  HIP output  : Indicates G1/G2/G3 rate.
assign    rate5            = `HIP_256_PIPEN1B.rate5            ;//  HIP output  : Indicates G1/G2/G3 rate.
assign    rate6            = `HIP_256_PIPEN1B.rate6            ;//  HIP output  : Indicates G1/G2/G3 rate.
assign    rate7            = `HIP_256_PIPEN1B.rate7            ;//  HIP output  : Indicates G1/G2/G3 rate.
assign    eidleinfersel0   = `HIP_256_PIPEN1B.eidleinfersel0     ;//  HIP output  : Electrical IDLE infer.
assign    eidleinfersel1   = `HIP_256_PIPEN1B.eidleinfersel1     ;//  HIP output  : Electrical IDLE infer.
assign    eidleinfersel2   = `HIP_256_PIPEN1B.eidleinfersel2     ;//  HIP output  : Electrical IDLE infer.
assign    eidleinfersel3   = `HIP_256_PIPEN1B.eidleinfersel3     ;//  HIP output  : Electrical IDLE infer.
assign    eidleinfersel4   = `HIP_256_PIPEN1B.eidleinfersel4     ;//  HIP output  : Electrical IDLE infer.
assign    eidleinfersel5   = `HIP_256_PIPEN1B.eidleinfersel5     ;//  HIP output  : Electrical IDLE infer.
assign    eidleinfersel6   = `HIP_256_PIPEN1B.eidleinfersel6     ;//  HIP output  : Electrical IDLE infer.
assign    eidleinfersel7   = `HIP_256_PIPEN1B.eidleinfersel7     ;//  HIP output  : Electrical IDLE infer.
                             
// interface with the PHY PCS Lane 0
assign    txdata0          = `HIP_256_PIPEN1B.txdata0     ;//  HIP output  : .
assign    txdatak0         = `HIP_256_PIPEN1B.txdatak0    ;//  HIP output  : .
assign    txdetectrx0      = `HIP_256_PIPEN1B.txdetectrx0 ;//  HIP output  : .
assign    txelecidle0      = `HIP_256_PIPEN1B.txelecidle0 ;//  HIP output  : .
assign    txcompl0         = `HIP_256_PIPEN1B.txcompl0    ;//  HIP output  : .
assign    rxpolarity0      = `HIP_256_PIPEN1B.rxpolarity0 ;//  HIP output  : .
assign    powerdown0       = `HIP_256_PIPEN1B.powerdown0  ;//  HIP output  : .
assign    txdataskip0      = `HIP_256_PIPEN1B.txdataskip0 ;//  HIP output  : .
assign    txblkst0         = `HIP_256_PIPEN1B.txblkst0    ;//  HIP output  : .
assign    txsynchd0        = `HIP_256_PIPEN1B.txsynchd0   ;//  HIP output  : .
assign    txdeemph0        = `HIP_256_PIPEN1B.txdeemph0   ;//  HIP output  : .
assign    txmargin0        = `HIP_256_PIPEN1B.txmargin0   ;//  HIP output  : .
assign    txswing0         = `HIP_256_PIPEN1B.txswing0    ;//  HIP output  : .
//
//// interface with the PHY PCS Lane 1
 assign   txdata1          = `HIP_256_PIPEN1B.txdata1        ;//  HIP output  : .
 assign   txdatak1         = `HIP_256_PIPEN1B.txdatak1       ;//  HIP output  : .
 assign   txdetectrx1      = `HIP_256_PIPEN1B.txdetectrx1    ;//  HIP output  : .
 assign   txelecidle1      = `HIP_256_PIPEN1B.txelecidle1    ;//  HIP output  : .
 assign   txcompl1         = `HIP_256_PIPEN1B.txcompl1       ;//  HIP output  : .
 assign   rxpolarity1      = `HIP_256_PIPEN1B.rxpolarity1    ;//  HIP output  : .
 assign   powerdown1       = `HIP_256_PIPEN1B.powerdown1     ;//  HIP output  : .
 assign   txdataskip1      = `HIP_256_PIPEN1B.txdataskip1    ;//  HIP output  : .
 assign   txblkst1         = `HIP_256_PIPEN1B.txblkst1       ;//  HIP output  : .
 assign   txsynchd1        = `HIP_256_PIPEN1B.txsynchd1      ;//  HIP output  : .
 assign   txdeemph1        = `HIP_256_PIPEN1B.txdeemph1      ;//  HIP output  : .
 assign   txmargin1        = `HIP_256_PIPEN1B.txmargin1      ;//  HIP output  : .
 assign   txswing1         = `HIP_256_PIPEN1B.txswing1       ;//  HIP output  : .
                                                           
 assign   txdata2          = `HIP_256_PIPEN1B.txdata2       ;//  HIP output  : .
 assign   txdatak2         = `HIP_256_PIPEN1B.txdatak2      ;//  HIP output  : .
 assign   txdetectrx2      = `HIP_256_PIPEN1B.txdetectrx2   ;//  HIP output  : .
 assign   txelecidle2      = `HIP_256_PIPEN1B.txelecidle2   ;//  HIP output  : .
 assign   txcompl2         = `HIP_256_PIPEN1B.txcompl2      ;//  HIP output  : .
 assign   rxpolarity2      = `HIP_256_PIPEN1B.rxpolarity2   ;//  HIP output  : .
 assign   powerdown2       = `HIP_256_PIPEN1B.powerdown2    ;//  HIP output  : .
 assign   txdataskip2      = `HIP_256_PIPEN1B.txdataskip2   ;//  HIP output  : .
 assign   txblkst2         = `HIP_256_PIPEN1B.txblkst2      ;//  HIP output  : .
 assign   txsynchd2        = `HIP_256_PIPEN1B.txsynchd2     ;//  HIP output  : .
 assign   txdeemph2        = `HIP_256_PIPEN1B.txdeemph2     ;//  HIP output  : .
 assign   txmargin2        = `HIP_256_PIPEN1B.txmargin2     ;//  HIP output  : .
 assign   txswing2         = `HIP_256_PIPEN1B.txswing2      ;//  HIP output  : .
//
//// interface with the PHY PCS Lane 3
 assign   txdata3          = `HIP_256_PIPEN1B.txdata3        ;//  HIP output  : .
 assign   txdatak3         = `HIP_256_PIPEN1B.txdatak3       ;//  HIP output  : .
 assign   txdetectrx3      = `HIP_256_PIPEN1B.txdetectrx3    ;//  HIP output  : .
 assign   txelecidle3      = `HIP_256_PIPEN1B.txelecidle3    ;//  HIP output  : .
 assign   txcompl3         = `HIP_256_PIPEN1B.txcompl3       ;//  HIP output  : .
 assign   rxpolarity3      = `HIP_256_PIPEN1B.rxpolarity3    ;//  HIP output  : .
 assign   powerdown3       = `HIP_256_PIPEN1B.powerdown3     ;//  HIP output  : .
 assign   txdataskip3      = `HIP_256_PIPEN1B.txdataskip3    ;//  HIP output  : .
 assign   txblkst3         = `HIP_256_PIPEN1B.txblkst3       ;//  HIP output  : .
 assign   txsynchd3        = `HIP_256_PIPEN1B.txsynchd3      ;//  HIP output  : .
 assign   txdeemph3        = `HIP_256_PIPEN1B.txdeemph3      ;//  HIP output  : .
 assign   txmargin3        = `HIP_256_PIPEN1B.txmargin3      ;//  HIP output  : .
 assign   txswing3         = `HIP_256_PIPEN1B.txswing3       ;//  HIP output  : .
//
//// interface with the PHY PCS Lane 4
 assign  txdata4           = `HIP_256_PIPEN1B.txdata4      ;//  HIP output  : .
 assign  txdatak4          = `HIP_256_PIPEN1B.txdatak4     ;//  HIP output  : .
 assign  txdetectrx4       = `HIP_256_PIPEN1B.txdetectrx4  ;//  HIP output  : .
 assign  txelecidle4       = `HIP_256_PIPEN1B.txelecidle4  ;//  HIP output  : .
 assign  txcompl4          = `HIP_256_PIPEN1B.txcompl4     ;//  HIP output  : .
 assign  rxpolarity4       = `HIP_256_PIPEN1B.rxpolarity4  ;//  HIP output  : .
 assign  powerdown4        = `HIP_256_PIPEN1B.powerdown4   ;//  HIP output  : .
 assign  txdataskip4       = `HIP_256_PIPEN1B.txdataskip4  ;//  HIP output  : .
 assign  txblkst4          = `HIP_256_PIPEN1B.txblkst4     ;//  HIP output  : .
 assign  txsynchd4         = `HIP_256_PIPEN1B.txsynchd4    ;//  HIP output  : .
 assign  txdeemph4         = `HIP_256_PIPEN1B.txdeemph4    ;//  HIP output  : .
 assign  txmargin4         = `HIP_256_PIPEN1B.txmargin4    ;//  HIP output  : .
 assign  txswing4          = `HIP_256_PIPEN1B.txswing4     ;//  HIP output  : .
//
//// interface with the PHY PCS Lane 5
 assign  txdata5           = `HIP_256_PIPEN1B.txdata5     ;//  HIP output  : .
 assign  txdatak5          = `HIP_256_PIPEN1B.txdatak5    ;//  HIP output  : .
 assign  txdetectrx5       = `HIP_256_PIPEN1B.txdetectrx5 ;//  HIP output  : .
 assign  txelecidle5       = `HIP_256_PIPEN1B.txelecidle5 ;//  HIP output  : .
 assign  txcompl5          = `HIP_256_PIPEN1B.txcompl5    ;//  HIP output  : .
 assign  rxpolarity5       = `HIP_256_PIPEN1B.rxpolarity5 ;//  HIP output  : .
 assign  powerdown5        = `HIP_256_PIPEN1B.powerdown5  ;//  HIP output  : .
 assign  txdataskip5       = `HIP_256_PIPEN1B.txdataskip5 ;//  HIP output  : .
 assign  txblkst5          = `HIP_256_PIPEN1B.txblkst5    ;//  HIP output  : .
 assign  txsynchd5         = `HIP_256_PIPEN1B.txsynchd5   ;//  HIP output  : .
 assign  txdeemph5         = `HIP_256_PIPEN1B.txdeemph5   ;//  HIP output  : .
 assign  txmargin5         = `HIP_256_PIPEN1B.txmargin5   ;//  HIP output  : .
 assign  txswing5          = `HIP_256_PIPEN1B.txswing5    ;//  HIP output  : .
//
//// interface with the PHY PCS Lane 6
 assign  txdata6           = `HIP_256_PIPEN1B.txdata6      ;//  HIP output  : .
 assign  txdatak6          = `HIP_256_PIPEN1B.txdatak6     ;//  HIP output  : .
 assign  txdetectrx6       = `HIP_256_PIPEN1B.txdetectrx6  ;//  HIP output  : .
 assign  txelecidle6       = `HIP_256_PIPEN1B.txelecidle6  ;//  HIP output  : .
 assign  txcompl6          = `HIP_256_PIPEN1B.txcompl6     ;//  HIP output  : .
 assign  rxpolarity6       = `HIP_256_PIPEN1B.rxpolarity6  ;//  HIP output  : .
 assign  powerdown6        = `HIP_256_PIPEN1B.powerdown6   ;//  HIP output  : .
 assign  txdataskip6       = `HIP_256_PIPEN1B.txdataskip6  ;//  HIP output  : .
 assign  txblkst6          = `HIP_256_PIPEN1B.txblkst6     ;//  HIP output  : .
 assign  txsynchd6         = `HIP_256_PIPEN1B.txsynchd6    ;//  HIP output  : .
 assign  txdeemph6         = `HIP_256_PIPEN1B.txdeemph6    ;//  HIP output  : .
 assign  txmargin6         = `HIP_256_PIPEN1B.txmargin6    ;//  HIP output  : .
 assign  txswing6          = `HIP_256_PIPEN1B.txswing6     ;//  HIP output  : .
//
//// interface with the PHY PCS Lane 7
 assign  txdata7           = `HIP_256_PIPEN1B.txdata7      ;//  HIP output  : .
 assign  txdatak7          = `HIP_256_PIPEN1B.txdatak7     ;//  HIP output  : .
 assign  txdetectrx7       = `HIP_256_PIPEN1B.txdetectrx7  ;//  HIP output  : .
 assign  txelecidle7       = `HIP_256_PIPEN1B.txelecidle7  ;//  HIP output  : .
 assign  txcompl7          = `HIP_256_PIPEN1B.txcompl7     ;//  HIP output  : .
 assign  rxpolarity7       = `HIP_256_PIPEN1B.rxpolarity7  ;//  HIP output  : .
 assign  powerdown7        = `HIP_256_PIPEN1B.powerdown7   ;//  HIP output  : .
 assign  txdataskip7       = `HIP_256_PIPEN1B.txdataskip7  ;//  HIP output  : .
 assign  txblkst7          = `HIP_256_PIPEN1B.txblkst7     ;//  HIP output  : .
 assign  txsynchd7         = `HIP_256_PIPEN1B.txsynchd7    ;//  HIP output  : .
 assign  txdeemph7         = `HIP_256_PIPEN1B.txdeemph7    ;//  HIP output  : .
 assign  txmargin7         = `HIP_256_PIPEN1B.txmargin7    ;//  HIP output  : .
 assign  txswing7          = `HIP_256_PIPEN1B.txswing7     ;//  HIP output  : .
//
endmodule
