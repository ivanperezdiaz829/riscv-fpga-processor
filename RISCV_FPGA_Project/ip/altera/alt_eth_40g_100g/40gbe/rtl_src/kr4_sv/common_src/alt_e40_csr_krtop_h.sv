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


//****************************************************************************
// Control & status register map for KR PHY IP
//****************************************************************************
package alt_e40_csr_krtop_h;

  import alt_xcvr_csr_common_h::*;

  // 8G PCS, a.k.a. "Legacy Gige", control and status for the KRPHY
  //
  localparam [alt_xcvr_csr_addr_width-1:0] 
          ADDR_KRGIGE_BASE   = ADDR_PCS_BASE    + 8'h28,   // 0xA8
          ADDR_KRGIGE_STATUS = ADDR_KRGIGE_BASE + 8'd1;

  // KR Sequencer, top-level, and FEC registers
  //
  localparam [alt_xcvr_csr_addr_width-1:0] 
          ADDR_KRTOP_BASE    = ADDR_PCS_BASE    + 8'h30,  // 0xB0
          ADDR_KRTOP_STATUS  = ADDR_KRTOP_BASE  + 8'd1,
          ADDR_KRFEC_STATUS  = ADDR_KRTOP_BASE  + 8'd2,
          ADDR_KRFEC_CRRBLKS = ADDR_KRTOP_BASE  + 8'd3,
          ADDR_KRFEC_UNCBLKS = ADDR_KRTOP_BASE  + 8'd4;

  // KR AN control and status Registers
  //
  localparam [alt_xcvr_csr_addr_width-1:0] 
          ADDR_KRAN_BASE   = ADDR_KRTOP_BASE + 8'h10,  // 0xC0
          ADDR_KRAN_RESET  = ADDR_KRAN_BASE  + 8'd1,
          ADDR_KRAN_STATUS = ADDR_KRAN_BASE  + 8'd2,
          ADDR_KRAN_UBPLO  = ADDR_KRAN_BASE  + 8'd3,
          ADDR_KRAN_UBPHI  = ADDR_KRAN_BASE  + 8'd4,
          ADDR_KRAN_UNXTLO = ADDR_KRAN_BASE  + 8'd5,
          ADDR_KRAN_UNXTHI = ADDR_KRAN_BASE  + 8'd6,
          ADDR_KRAN_LPBPLO = ADDR_KRAN_BASE  + 8'd7,
          ADDR_KRAN_LPBPHI = ADDR_KRAN_BASE  + 8'd8,
          ADDR_KRAN_LPNXLO = ADDR_KRAN_BASE  + 8'd9,
          ADDR_KRAN_LPNXHI = ADDR_KRAN_BASE  + 8'd10,
          ADDR_KRAN_LPADV  = ADDR_KRAN_BASE  + 8'd11,
		  ADDR_KRAN_OVRCH  = ADDR_KRAN_BASE  + 8'd12,
          ADDR_KRAN_TM     = ADDR_KRAN_BASE  + 8'd15;

  // KR LT control and status Registers
  //
  localparam [alt_xcvr_csr_addr_width-1:0] 
          ADDR_KRLT_BASE   = ADDR_KRAN_BASE + 8'h10,  // 0xD0
          ADDR_KRLT_RESET  = ADDR_KRLT_BASE  + 8'd1,
          ADDR_KRLT_STATUS = ADDR_KRLT_BASE  + 8'd2,
          ADDR_KRLT_BERTIM = ADDR_KRLT_BASE  + 8'd3,
          ADDR_KRLT_UCOEFF = ADDR_KRLT_BASE  + 8'd4,
          ADDR_KRLT_TAPVAL = ADDR_KRLT_BASE  + 8'd5,
          ADDR_KRLT_OVRDRULE = ADDR_KRLT_BASE  + 8'd6,
          ADDR_KRLT_TM     = ADDR_KRLT_BASE  + 8'd15,
          ADDR_KRLT_BERTIM1 = ADDR_KRLT_BASE  + 8'h10,
          ADDR_KRLT_UCOEFF1 = ADDR_KRLT_BASE  + 8'h11,
          ADDR_KRLT_TAPVAL1 = ADDR_KRLT_BASE  + 8'h12,
          ADDR_KRLT_OVRDRULE1 = ADDR_KRLT_BASE  + 8'h13,
          ADDR_KRLT_BERTIM2 = ADDR_KRLT_BASE  + 8'h14,
          ADDR_KRLT_UCOEFF2 = ADDR_KRLT_BASE  + 8'h15,
          ADDR_KRLT_TAPVAL2 = ADDR_KRLT_BASE  + 8'h16,
          ADDR_KRLT_OVRDRULE2 = ADDR_KRLT_BASE  + 8'h17,
          ADDR_KRLT_BERTIM3 = ADDR_KRLT_BASE  + 8'h18,
          ADDR_KRLT_UCOEFF3 = ADDR_KRLT_BASE  + 8'h19,
          ADDR_KRLT_TAPVAL3 = ADDR_KRLT_BASE  + 8'h1a,
          ADDR_KRLT_OVRDRULE3 = ADDR_KRLT_BASE  + 8'h1b;

endpackage
