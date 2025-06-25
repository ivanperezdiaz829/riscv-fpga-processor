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


`timescale 1 ps/1 ps

module alt_xcvr_native_avmm_nf #(
    parameter CHANNELS        = 1,
    parameter RECONFIG_SHARED = 0,
    parameter JTAG_ENABLED    = 0,
    // The following are not intended to be directly set
    parameter IFACES          = RECONFIG_SHARED ? 1 : CHANNELS,
    parameter ADDR_BITS       = 9,
    parameter SEL_BITS        = (RECONFIG_SHARED ? clogb2(CHANNELS-1) : 0)
  ) (
  // Reconfig interface ports
  input   wire  [IFACES-1:0]    reconfig_clk,
  input   wire  [IFACES-1:0]    reconfig_reset,
  input   wire  [IFACES-1:0]    reconfig_write,
  input   wire  [IFACES-1:0]    reconfig_read,
  input   wire  [IFACES*(ADDR_BITS+SEL_BITS)-1:0] reconfig_address,
  input   wire  [IFACES*32-1:0] reconfig_writedata,
  output  wire  [IFACES*32-1:0] reconfig_readdata,
  output  wire  [IFACES-1:0]    reconfig_waitrequest,

  // AVMM ports to transceiver
  output  wire  [CHANNELS-1:0]            avmm_clk,
  output  wire  [CHANNELS-1:0]            avmm_reset,
  output  wire  [CHANNELS-1:0]            avmm_write,
  output  wire  [CHANNELS-1:0]            avmm_read,
  output  wire  [CHANNELS*ADDR_BITS-1:0]  avmm_address,
  output  wire  [CHANNELS*8-1:0]          avmm_writedata,
  input   wire  [CHANNELS*8-1:0]          avmm_readdata,
  input   wire  [CHANNELS-1:0]            avmm_waitrequest
);

// AVMM connections from the interface sharing logic to the JTAG arbitration
wire  [IFACES-1:0]    arb_write;
wire  [IFACES-1:0]    arb_read;
wire  [IFACES*(ADDR_BITS+SEL_BITS)-1:0] arb_address;
wire  [IFACES*32-1:0] arb_writedata;
wire  [IFACES*32-1:0] arb_readdata;
wire  [IFACES-1:0]    arb_waitrequest;

genvar ig;

//***************************************************************************
//********************** Embedded JTAG Debug Master *************************
generate
if(!JTAG_ENABLED) begin : g_no_jtag
  assign  arb_address   = reconfig_address;
  assign  arb_write     = reconfig_write;
  assign  arb_read      = reconfig_read;
  assign  arb_writedata = reconfig_writedata;
  
  assign  reconfig_readdata   = arb_readdata;
  assign  reconfig_waitrequest= arb_waitrequest;
end else begin : g_jtag
  reg sel;  // Arbitration bit

  wire [31:0] jtag_address;
  wire [31:0] jtag_readdata;
  wire        jtag_read;
  wire        jtag_write;
  wire [31:0] jtag_writedata;
  wire        jtag_waitrequest;
  wire        jtag_readdatavalid;

  jtag_master jtag_master_inst(
    /*input  wire       */.jtag_master_reset_reset          (reconfig_reset     ),
    /*input  wire       */.jtag_master_clk_clk              (reconfig_clk       ),
  
    /*output wire       */.jtag_master_reset_out_reset      (/*unused*/         ),
    /*output wire [31:0]*/.jtag_master_master_address       (jtag_address       ),
    /*input  wire [31:0]*/.jtag_master_master_readdata      (jtag_readdata      ),
    /*output wire       */.jtag_master_master_read          (jtag_read          ),
    /*output wire       */.jtag_master_master_write         (jtag_write         ),
    /*output wire [31:0]*/.jtag_master_master_writedata     (jtag_writedata     ),
    /*input  wire       */.jtag_master_master_waitrequest   (jtag_waitrequest   ),
    /*input  wire       */.jtag_master_master_readdatavalid (jtag_readdatavalid ),
    /*output wire [3:0] */.jtag_master_master_byteenable    (/*unused*/         )
  );


  //************************************************************************
  //*********************** JTAG<->Reconfig Arbitration ********************
  // Drop the lower two address bits from the jtag master (byte addressed)
  assign  arb_address   = sel ? jtag_address[2+:ADDR_BITS+SEL_BITS] : reconfig_address;
  assign  arb_write     = sel ? jtag_write      : reconfig_write;
  assign  arb_read      = sel ? jtag_read       : reconfig_read;
  assign  arb_writedata = sel ? jtag_writedata  : reconfig_writedata;
  
  assign  reconfig_readdata   = arb_readdata;
  assign  jtag_readdata       = arb_readdata;
  assign  reconfig_waitrequest= arb_waitrequest | sel;
  assign  jtag_waitrequest    = arb_waitrequest | ~sel;

  // Arbitration
  always @(posedge reconfig_clk or posedge reconfig_reset)
    if(reconfig_reset)  sel <= 1'b0;
    else begin
      if(sel)           sel <= ~arb_waitrequest;
      else              sel <= (jtag_write|jtag_read) & ~(reconfig_write|reconfig_read);
    end
  //********************* End JTAG<->Reconfig Arbitration ******************
  //************************************************************************
end 
endgenerate

//******************** End Embedded JTAG Debug Master ***********************
//***************************************************************************


//***************************************************************************
//********************** AVMM Reconfig Connections **************************
generate
  if(!RECONFIG_SHARED) begin : g_not_shared
    // We wire straight between the interfaces if there is no sharing logic
    assign  avmm_clk        = reconfig_clk;
    assign  avmm_reset      = reconfig_reset;
    assign  avmm_write      = arb_write;
    assign  avmm_read       = arb_read;
    assign  avmm_address    = arb_address;
    assign  arb_waitrequest = avmm_waitrequest;
    
    for(ig=0;ig<CHANNELS;ig=ig+1) begin : g_shared
      assign  avmm_writedata[ig*8 +:8]    = arb_writedata[7:0];
      assign  arb_readdata  [ig*32 +:32]  = {24'd0,avmm_readdata[ig*8 +: 8]};
    end

  end else begin : g_shared
    wire  [SEL_BITS-1:0]  arb_sel;

    assign  arb_sel = arb_address[ADDR_BITS+:SEL_BITS];

    for(ig=0;ig<CHANNELS;ig=ig+1) begin : g_shared
      assign  avmm_clk      [ig]  = reconfig_clk;
      assign  avmm_reset    [ig]  = reconfig_reset;
      // Use the upper address bits as the interface select if shared
      assign  avmm_write    [ig]                         = arb_write & (arb_sel == ig);
      assign  avmm_read     [ig]                         = arb_read  & (arb_sel == ig);
      assign  avmm_address  [ig*ADDR_BITS +: ADDR_BITS]  = arb_address[0+:ADDR_BITS];
      assign  avmm_writedata[ig*8 +: 8]                  = arb_writedata[7:0];
    end

      assign  arb_readdata    = {24'd0,avmm_readdata[arb_sel*8 +: 8]};
      assign  arb_waitrequest = avmm_waitrequest[arb_sel];
  end
endgenerate

//********************** AVMM Reconfig Connections **************************
//***************************************************************************

////////////////////////////////////////////////////////////////////
// Return the number of bits required to represent an integer
// E.g. 0->1; 1->1; 2->2; 3->2 ... 31->5; 32->6
//
function integer clogb2;
  input integer input_num;
  begin
    for (clogb2=0; input_num>0; clogb2=clogb2+1)
      input_num = input_num >> 1;
    if(clogb2 == 0)
      clogb2 = 1;
  end
endfunction


endmodule

