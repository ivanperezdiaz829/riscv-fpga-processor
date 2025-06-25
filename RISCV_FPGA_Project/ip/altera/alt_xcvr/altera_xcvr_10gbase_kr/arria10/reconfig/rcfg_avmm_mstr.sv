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




//===========================================================================
// This confidential and proprietary software may be used only as authorized
// by a licensing agreement from ALTERA
// copyright notice must be reproduced on all authorized copies.
//============================================================================

//============================================================================
// Reconfig AVMM master State Machine
// Generates DPRIO address and control signals for a single xcvr interface
//   - Performs a write operation for full 8-bit write
//   - Performs a RMW for less than full 8-bit data with the given mask
//   - Performs RMW for logical refclk select and logical PLL (CGB) select
//============================================================================

`timescale 1 ps / 1 ps

module rcfg_avmm_mstr
   (
  input  wire        clk,
  input  wire        reset,
    //  Controller
  input  wire [9:0]  ctrl_addr,
  input  wire [7:0]  ctrl_writedata,
  input  wire [7:0]  ctrl_datamask,
  input  wire        ctrl_write,
  input  wire        ctrl_rmw,
  output wire        ctrl_busy,
  input  wire        refclk_req,
  input  wire        cgb_req,
  input  wire        cal_req,
  input  wire        refclk_sel,          // 0 = clock 0 = 10G clock
  input  wire        cgb_sel,             // 1 = clock 1 = 1G clock
  input  wire        cal_sel,             // 0 = request, 1 give ctrl
    // HSSI Reconfig master
  output reg             xcvr_rcfg_write,   // AVMM write
  output reg             xcvr_rcfg_read,    // AVMM read
  output reg  [9:0]      xcvr_rcfg_address, // AVMM address
  output reg  [7:0]      xcvr_rcfg_wrdata,  // AVMM write data
  input  wire [7:0]      xcvr_rcfg_rddata,  // AVMM read data
  input  wire            xcvr_rcfg_wtrqst   // AVMM wait request
  );

//============================================================================
//  Control State Machine
//============================================================================
  localparam [1:0] CTRL_IDLE      = 2'd0;
  localparam [1:0] CTRL_WR        = 2'd1;
  localparam [1:0] CTRL_RD        = 2'd2;

  reg [1:0]  ctrl_state;
  reg [1:0]  ctrl_next_state;

    // state register
  always_ff @(posedge clk or posedge reset) begin
   if (reset)
     ctrl_state <= CTRL_IDLE;
   else
     ctrl_state <= ctrl_next_state;
  end

    // next state logic
  always_comb begin
    case(ctrl_state)
      CTRL_IDLE : begin
          if (xcvr_rcfg_wtrqst)
            ctrl_next_state = CTRL_IDLE;
          else if (ctrl_write | cal_req)
            ctrl_next_state = CTRL_WR;
          else if (ctrl_rmw | refclk_req | cgb_req)
            ctrl_next_state = CTRL_RD;
          else
            ctrl_next_state = CTRL_IDLE;
          end
      CTRL_WR : begin
          if (xcvr_rcfg_wtrqst)
            ctrl_next_state = CTRL_WR;
          else if (ctrl_write | cal_req)
            ctrl_next_state = CTRL_WR;
          else if (ctrl_rmw | refclk_req | cgb_req)
            ctrl_next_state = CTRL_RD;
          else
            ctrl_next_state = CTRL_IDLE;
          end
      CTRL_RD : begin
          if (xcvr_rcfg_wtrqst)
            ctrl_next_state = CTRL_RD;
          else if (ctrl_rmw | refclk_req | cgb_req)
            ctrl_next_state = CTRL_RD;
          else
            ctrl_next_state = CTRL_WR;
          end
      default : ctrl_next_state = CTRL_IDLE;
    endcase
  end

  assign ctrl_busy = (ctrl_next_state != CTRL_IDLE);

//============================================================================
//  Refclk/CGB/RMW active
//============================================================================
  reg       refclk_active;  // Flag for refclk RMW operation
  reg       cgb_active;     // Flag for cgb RMW operation
  reg       rmw_active;     // Flag for data RMW operation

  always_ff @(posedge clk or posedge reset) begin
    if (reset)
      refclk_active <= 1'b0;
    else if (refclk_req)
      refclk_active <= 1'b1;
    else if ((ctrl_state == CTRL_WR) && (ctrl_next_state != CTRL_WR))
      refclk_active <= 1'b0;
  end

  always_ff @(posedge clk or posedge reset) begin
    if (reset)
      cgb_active <= 1'b0;
    else if (cgb_req)
      cgb_active <= 1'b1;
    else if ((ctrl_state == CTRL_WR) && (ctrl_next_state != CTRL_WR))
      cgb_active <= 1'b0;
  end

  always_ff @(posedge clk or posedge reset) begin
    if (reset)
      rmw_active <= 1'b0;
    else if (ctrl_rmw)
      rmw_active <= 1'b1;
    else if ((ctrl_state == CTRL_WR) && (ctrl_next_state != CTRL_WR))
      rmw_active <= 1'b0;
  end

//============================================================================
//  Generate DPRIO signals for single XCVR Interface
//============================================================================

  //DPRIO read
  always_ff @(posedge clk or posedge reset) begin
    if (reset)
      xcvr_rcfg_read  <= 1'b0;
    else if(ctrl_next_state == CTRL_RD)
      xcvr_rcfg_read  <= 1'b1;
    else
      xcvr_rcfg_read  <= 1'b0;
  end

  //DPRIO write
  always_ff @(posedge clk or posedge reset) begin
    if (reset)
      xcvr_rcfg_write  <= 1'b0;
    else if(ctrl_next_state == CTRL_WR)
      xcvr_rcfg_write  <= 1'b1;
    else
      xcvr_rcfg_write  <= 1'b0;
  end

  //DPRIO address
  always_ff @ (posedge clk or posedge reset) begin
    if (reset)
      xcvr_rcfg_address <= 10'b0;
    else if ((ctrl_next_state == CTRL_RD) & 
                                  (refclk_req | refclk_active) & ~refclk_sel)
      xcvr_rcfg_address <= 10'h16A;    // refclk 0 address
    else if ((ctrl_next_state == CTRL_RD) & 
                                  (refclk_req | refclk_active) &  refclk_sel)
      xcvr_rcfg_address <= 10'h16B;    // refclk 1 address
    else if ((ctrl_next_state == CTRL_RD) & (cgb_req | cgb_active))
      xcvr_rcfg_address <= 10'h117;    // CGB 0/1 address
    else if ((ctrl_next_state == CTRL_WR) & refclk_active)
      xcvr_rcfg_address <= 10'h141;    // refclk mux address
    else if ((ctrl_next_state == CTRL_WR) & cgb_active)
      xcvr_rcfg_address <= 10'h111;    // CGB mux address
    else if ((ctrl_next_state == CTRL_WR) & cal_req & cal_sel)
      xcvr_rcfg_address <= 10'h100;    // calibration request address
    else if ((ctrl_next_state == CTRL_WR) & cal_req & ~cal_sel)
      xcvr_rcfg_address <= 10'h000;    // NIOS arbitration address
    else
      xcvr_rcfg_address <= ctrl_addr; // address from controller
  end

//============================================================================
// Modify the Data for RMW operation
//   - refclk: just write the scratch0/1 data to the mux select reg
//   - cgb: select nibble0/1 and modify the data to the mux select reg
//============================================================================
  wire [7:0] modify_cgb_data;
  wire [7:0] modify_rmw_data;

  //scratch_reg[2:0]=x1,scratch_reg[3]=xn for logical PLL 0 and 2
  //scratch_reg[6:4]=x1,scratch_reg[7]=xn for logical PLL 1 and 3
  assign modify_cgb_data  =
    cgb_sel ? {~xcvr_rcfg_rddata[7],xcvr_rcfg_rddata[5:4],xcvr_rcfg_rddata[7],
                xcvr_rcfg_rddata[7:4]} :
              {~xcvr_rcfg_rddata[3],xcvr_rcfg_rddata[1:0],xcvr_rcfg_rddata[3],
                xcvr_rcfg_rddata[3:0]};

  assign modify_rmw_data  = (xcvr_rcfg_rddata & ~ctrl_datamask) |
                            (ctrl_writedata   &  ctrl_datamask);

  //DPRIO writedata
  always_ff @(posedge clk or posedge reset) begin
    if (reset)
      xcvr_rcfg_wrdata <= 8'b0;
    else if (ctrl_write)
      xcvr_rcfg_wrdata <= ctrl_writedata;
    else if (cal_req & cal_sel)
      xcvr_rcfg_wrdata <= 8'b1010_0110;     // dcd = b7,VOD = b5,dfe = b2,ro = b1
    else if (cal_req & ~cal_sel)
      xcvr_rcfg_wrdata <= 8'b0000_0001;     // bit 0 to release NIOS
    else if((ctrl_state == CTRL_RD) & refclk_active)
      xcvr_rcfg_wrdata  <= xcvr_rcfg_rddata;
    else if((ctrl_state == CTRL_RD) & cgb_active)
      xcvr_rcfg_wrdata  <= modify_cgb_data;
    else if((ctrl_state == CTRL_RD) & rmw_active)
      xcvr_rcfg_wrdata  <= modify_rmw_data;
  end

//============================================================================
endmodule // rcfg_avmm_mstr
