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
// Reconfig PCS State Machine
// Generates data address and control signals to AVMM master SM
//============================================================================

`timescale 1 ps / 1 ps

module rcfg_pcs_ctrl
   (
  input  wire        clk,
  input  wire        reset,
     // PCS reconfig requests
  input  wire           seq_start_rc,   // start the PCS reconfig
  input  wire [4:3]     pcs_mode_rc,    // PCS mode for reconfig - 1 hot
                                        // bit 0 = AN mode = low_lat, PLL LTR
                                        // bit 1 = LT mode = low_lat, PLL LTD
                                        // bit 2 = 10G data mode = 10GBASE-R
                                        // bit 3 = GigE data mode = 8G PCS
                                        // bit 4 = XAUI data mode = future?
                                        // bit 5 = 10G-FEC
  output reg            rc_busy,        // reconfig is busy
  input  wire           skip_cal,       // skip the calibration
    //  AVMM master State Machine
  input  wire       ctrl_busy,
  output wire       refclk_req,
  output wire       cgb_req,
  output wire       cal_req,
  output wire       refclk_sel,          // 0 = clock 0 = 10G clock
  output wire       cgb_sel,             // 1 = clock 1 = 1G clock
  output wire       cal_sel,             // 0 = request, 1 give ctrl
    //  HSSI
  input  wire       rcfg_wtrqst,       // AVMM wait request
  input  wire       calibration_busy,
  output reg        analog_reset,
  output reg        digital_reset,
    // HSSI Reconfig data
  input  wire       last_data,
  output reg [5:0]  pcs_data_addr,
  output wire       en_next
  );

//============================================================================
//  input Handshaking
//============================================================================
  reg       start_dly;
  reg       start_edge;  // rising edge of start
  reg       busy_dly;
  reg       busy_edge;   // falling edge of busy
  reg       wtrqst_dly;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      start_dly  <= 1'b0;
      start_edge <= 1'b0;
      busy_dly   <= 1'b0;
      busy_edge  <= 1'b0;
      wtrqst_dly <= 1'b0;
      end
    else begin
      start_dly  <=  seq_start_rc;
      start_edge <= (seq_start_rc & ~start_dly & ~rcfg_wtrqst) |
                    (seq_start_rc &  start_dly & ~rcfg_wtrqst & wtrqst_dly);
      busy_dly   <=  ctrl_busy;
      busy_edge  <= ~ctrl_busy & busy_dly;
      wtrqst_dly <= rcfg_wtrqst;
      end
  end

  wire  cal_busy;
  reg   cal_busy_dly;
  reg   cal_busy_edge;   // falling edge of busy

  // synchronize the cal_busy input
  alt_xcvr_resync #(
      .WIDTH            (1)  // Number of bits to resync
  ) busy_sync (
    .clk    (clk),
    .reset  (reset),
    .d      (calibration_busy),
    .q      (cal_busy)
  );

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        cal_busy_dly  <=0;
        cal_busy_edge <=0;
    end else begin
        cal_busy_dly  <=  calibration_busy;
        cal_busy_edge <= ~calibration_busy & cal_busy_dly;
    end
  end

//============================================================================
//  Control State Machine
//============================================================================
  localparam [3:0] IDLE      = 4'd0;    // wait for rc_start
  localparam [3:0] RC_1G     = 4'd1;    // Reconfig into 1G mode
  localparam [3:0] REF_1G    = 4'd2;    // change refclk for 1G mode
  localparam [3:0] CGB_1G    = 4'd3;    // change clock block for 1G mdoe
  localparam [3:0] RC_10G    = 4'd4;    // Reconfig into one of the 10G modes
  localparam [3:0] REF_10G   = 4'd5;    // change refclk for 10G mode
  localparam [3:0] CGB_10G   = 4'd6;    // change clock block for 10G mode
  localparam [3:0] CAL_REQ   = 4'd7;    // Request Calibration
  localparam [3:0] CAL_GIVE  = 4'd8;    // Give control of HSSI bus to NIOS
  localparam [3:0] WAIT_RST  = 4'd9;    // cal busy done to clear analog rst
  localparam [3:0] RST_DIG   = 4'd10;   // Wait for clear digital reset
  localparam [3:0] DONE      = 4'd11;   // Handshake for rc_start

  reg [3:0]  pcs_state;
  reg [3:0]  pcs_next_state;
  reg [2:0]  reset_counter;             // hold digital reset after analog
  reg        set_reset_active;          // reset both analog and digital
  reg        clear_ana_reset;           // clear the analog reset

    // state register
  always_ff @(posedge clk or posedge reset) begin
   if (reset)
     pcs_state <= IDLE;
   else
     pcs_state <= pcs_next_state;
  end

    // next state logic
  always_comb begin
    set_reset_active = 1'b0;
    clear_ana_reset  = 1'b0;
    case(pcs_state)
      IDLE: begin
           if     (start_edge & pcs_mode_rc[3]) begin
            pcs_next_state   = RC_1G;
            set_reset_active = 1'b1;
            end
          else if (start_edge & ~pcs_mode_rc[4]) begin
            pcs_next_state = RC_10G;
            set_reset_active = 1'b1;
            end
          else
            pcs_next_state = IDLE;
          end
      RC_1G: begin
           if (busy_edge & last_data)
            pcs_next_state = REF_1G;
          else
            pcs_next_state = RC_1G;
          end
      REF_1G: begin
           if (busy_edge)
            pcs_next_state = CGB_1G;
          else
            pcs_next_state = REF_1G;
          end
      CGB_1G: begin
           if (busy_edge & skip_cal)
            pcs_next_state = WAIT_RST;
           else if (busy_edge)
             pcs_next_state = CAL_REQ;
          else
            pcs_next_state = CGB_1G;
          end
      RC_10G: begin
           if (busy_edge & last_data)
            pcs_next_state = REF_10G;
          else
            pcs_next_state = RC_10G;
          end
      REF_10G: begin
           if (busy_edge)
            pcs_next_state = CGB_10G;
          else
            pcs_next_state = REF_10G;
          end
      CGB_10G: begin
           if (busy_edge & skip_cal)
            pcs_next_state = WAIT_RST;
           else if (busy_edge)
             pcs_next_state = CAL_REQ;
          else
            pcs_next_state = CGB_10G;
          end
      CAL_REQ: begin
           if (busy_edge)
            pcs_next_state = CAL_GIVE;
          else
            pcs_next_state = CAL_REQ;
          end
      CAL_GIVE: begin
           if (busy_edge)
            pcs_next_state = WAIT_RST;
          else
            pcs_next_state = CAL_GIVE;
          end
      WAIT_RST: begin
           if (cal_busy_edge | skip_cal) begin
            pcs_next_state  = RST_DIG;
            clear_ana_reset = 1'b1;
            end
          else
            pcs_next_state = WAIT_RST;
          end
      RST_DIG: begin
           if (&reset_counter)
            pcs_next_state = DONE;
          else
            pcs_next_state = RST_DIG;
          end
      DONE: begin
           if (~start_dly)
            pcs_next_state = IDLE;
          else
            pcs_next_state = DONE;
          end
      default : begin
        pcs_next_state = IDLE;
        set_reset_active = 1'b0;
        clear_ana_reset  = 1'b0;
        end
    endcase
  end

//============================================================================
//  reconfig data address
//============================================================================
  always_ff @(posedge clk or posedge reset) begin
    if (reset)
      pcs_data_addr <= 6'b0;
    else if (pcs_state == IDLE)
      pcs_data_addr <= 6'b0;
//    else if (busy_edge & ~last_data)
// a delay of pcs_address update means also need to delay en_next busy_edge
    else if (~ctrl_busy & busy_dly & ~last_data)
      pcs_data_addr <= pcs_data_addr + 1'b1;
  end

//============================================================================
//  reset counter to hold digital reset for 8 clocks after analog reset
//============================================================================
  always_ff @(posedge clk or posedge reset) begin
    if (reset)                     reset_counter <= 'd0;
    else if (pcs_state != RST_DIG) reset_counter <= 'd0;
    else                           reset_counter <= reset_counter + 1'b1;
  end

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      analog_reset  <=0;
      digital_reset <=0;
    end else begin
      analog_reset  <= set_reset_active | (analog_reset  & ~clear_ana_reset);
      digital_reset <= set_reset_active | (digital_reset & ~&reset_counter);
    end
  end

//============================================================================
//  outputs
//============================================================================
  always_ff @(posedge clk or posedge reset) begin
    if (reset) rc_busy <= 1'b0;
    else       rc_busy <= (pcs_next_state != IDLE);
  end

  assign refclk_req = ~busy_dly & ~busy_edge && 
                           ((pcs_state == REF_1G)  || (pcs_state == REF_10G));
  assign cgb_req    = ~busy_dly & ~busy_edge && 
                           ((pcs_state == CGB_1G)  || (pcs_state == CGB_10G));
  assign cal_req    = ~busy_dly & ~busy_edge && 
                           ((pcs_state == CAL_REQ) || (pcs_state == CAL_GIVE));
  assign refclk_sel = (pcs_state == REF_1G);
  assign cgb_sel    = (pcs_state == CGB_1G);
  assign cal_sel    = (pcs_state == CAL_REQ);

  assign en_next    = ((pcs_state == IDLE) && (pcs_next_state != IDLE)) ||
                (busy_edge &&
                  ((pcs_next_state == RC_1G) || (pcs_next_state == RC_10G)));

endmodule // rcfg_pcs_ctrl
