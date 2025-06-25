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


`timescale 100 fs / 100 fs

module tb_dual_link_sync (
    // port list
    clk,
    enable,
    reset,
    data_a,
    data_b,
    rx_ln,
    rx_ln_b,
    rx_eav,
    notsync,
    error
);

    //--------------------------------------------------------------------------
    // port declaration
    //--------------------------------------------------------------------------
    input clk;
    input enable;
    input reset;
    input [19:0] data_a;
    input [19:0] data_b;
    input [10:0] rx_ln;
    input [10:0] rx_ln_b;
    input        rx_eav;
    output error;
    output notsync;


    //---------------------------------------------------------------------------
    // Error counter
    //---------------------------------------------------------------------------
    integer     error_count_a;
    integer     error_count_b;
    reg         inc_err_a;
    reg         inc_err_b;
    reg         rst_err_cnt;

    always @ (posedge clk or posedge reset)
    begin
       if (reset) begin
          error_count_a <= 0;
          error_count_b <= 0;
       end else begin
          if (rst_err_cnt) begin
             error_count_a <= 0;
             error_count_b <= 0;
          end else if (inc_err_a) begin
             error_count_a <= error_count_a + 1;
          end else if (inc_err_b) begin
             error_count_b <= error_count_b + 1;
          end
       end
    end

    //---------------------------------------------------------------------------
    // Set which link to be compared
    //---------------------------------------------------------------------------
    reg         cmp_linka;
    reg         cmp_linkb;
    reg         clr_cmp;
    reg         set_cmp_a;
    reg         set_cmp_b;

    always @ (posedge clk or posedge reset)
    begin
       if (reset) begin
          cmp_linka <= 1'b0;
          cmp_linkb <= 1'b0;
       end else begin
          if (clr_cmp) begin
             cmp_linka <= 1'b0;
             cmp_linkb <= 1'b0;
          end else if (set_cmp_a) begin
             cmp_linka <= 1'b1;
          end else if (set_cmp_b) begin
             cmp_linkb <= 1'b1;
          end
       end
    end

    //---------------------------------------------------------------------------
    // Signal to indicate both streams are not in sync
    //---------------------------------------------------------------------------
    reg         trs_notmatch_a;
    reg         trs_notmatch_b;
    reg         set_notmatch_a_b;
    reg         set_notmatch_a;
    reg         set_notmatch_b;
    reg         clr_notmatch_a_b;
    reg         clr_notmatch_a;
    reg         clr_notmatch_b;

    always @ (posedge clk or posedge reset)
    begin
       if (reset) begin
          trs_notmatch_a <= 1'b1;
          trs_notmatch_b <= 1'b1;
       end else begin
          if (set_notmatch_a_b) begin
             trs_notmatch_a <= 1'b1;
             trs_notmatch_b <= 1'b1;
          end else if (set_notmatch_a) begin
             trs_notmatch_a <= 1'b1;
          end else if (set_notmatch_b) begin
             trs_notmatch_b <= 1'b1;
          end else if (clr_notmatch_a_b) begin
             trs_notmatch_a <= 1'b0;
             trs_notmatch_b <= 1'b0;
          end else if (clr_notmatch_a) begin
             trs_notmatch_a <= 1'b0;
          end else if (clr_notmatch_b) begin
             trs_notmatch_b <= 1'b0;
          end
       end
    end

    //---------------------------------------------------------------------------
    // Registers to store previous data
    //---------------------------------------------------------------------------
    reg stored_data_a;
    reg stored_data_b;
    reg [19:0]  prev_rxdata;
    reg [19:0]  prev_rxdatab;

    always @ (posedge clk or posedge reset)
    begin
       if (reset) begin
          prev_rxdata <= 20'd0;
          prev_rxdatab <= 20'd0;
       end else begin
          if (stored_data_a) begin
             prev_rxdata <= data_a;
          end else if (stored_data_b) begin
             prev_rxdatab <= data_b;
          end
       end
    end

    //--------------------------------------------------------------------------
    // local paramater and state names
    //--------------------------------------------------------------------------

    localparam BLANK_DATA = 20'h10200;

    localparam IDLE = 3'b000;
    localparam WAIT_FOR_TRS = 3'b001;
    localparam TRS_WORD1 = 3'b010;
    localparam TRS_WORD2 = 3'b011;
    localparam TRS_SEEN = 3'b100;
    localparam RESULT = 3'b101;
    localparam WAIT_FOR_EAV = 3'b110;
    localparam CHECK_LN_NUMBER = 3'b111;

    //---------------------------------------------------------------------------
    // Dual link sync check state machine
    //---------------------------------------------------------------------------

    reg [2:0]   current_state;
    reg [2:0]   next_state;
    reg         error;
    reg         notsync;
    wire        dl_in_sync = ~notsync;


    always @ (posedge clk or posedge reset)
    begin
       if (reset) begin
          current_state <= IDLE;
       end else begin
          current_state <= next_state;
       end
    end


    always @ (enable or data_a or data_b or rx_eav or error_count_a or error_count_b or 
              cmp_linka or cmp_linkb or trs_notmatch_a or trs_notmatch_b or prev_rxdata or prev_rxdatab or rx_ln or rx_ln_b)
    begin
       next_state  <= current_state;
       error <= 1'b0;
       rst_err_cnt <= 1'b0;
       inc_err_a <= 1'b0;
       inc_err_b <= 1'b0;
       clr_cmp <= 1'b0;
       set_cmp_a <= 1'b0;
       set_cmp_b <= 1'b0;
       set_notmatch_a_b <= 1'b0;
       set_notmatch_a <= 1'b0;
       set_notmatch_b <= 1'b0;
       clr_notmatch_a_b <= 1'b0;
       clr_notmatch_a <= 1'b0;
       clr_notmatch_b <= 1'b0;
       stored_data_a <= 1'b0;
       stored_data_b <= 1'b0;
       // notsync <= 1'b1;


        case (current_state)
          IDLE :            begin
                               set_notmatch_a_b <= 1'b1;
                               clr_cmp <= 1'b1;
                               if (enable) begin
                                  next_state <= WAIT_FOR_TRS;
                               end
                            end

          WAIT_FOR_TRS :    begin
                              if (data_a == 20'hfffff) begin
                                set_cmp_b <= 1'b1;
                                stored_data_b <= 1'b1;
                                next_state <= TRS_WORD1;
                              end else if (data_b == 20'hfffff) begin
                                set_cmp_a <= 1'b1;
                                stored_data_a <= 1'b1;
                                next_state <= TRS_WORD1;
                              end
                            end

          TRS_WORD1 :       begin
                              if (cmp_linkb) begin
                                if (prev_rxdatab == 20'hfffff) begin
                                   clr_notmatch_b <= 1'b1;
                                end else begin
                                   set_notmatch_b <= 1'b1;
                                end

                                if (data_a == 20'd0) begin
                                  stored_data_b <= 1'b1;
                                  next_state <= TRS_WORD2;
                                end else begin
                                  next_state <= WAIT_FOR_TRS;
                                  clr_cmp <= 1'b1;
                                end

                              end else if (cmp_linka) begin
                                if (prev_rxdata == 20'hfffff) begin
                                   clr_notmatch_a <= 1'b1;
                                end else begin
                                   set_notmatch_a <= 1'b1;
                                end

                                if (data_b == 20'd0) begin
                                  stored_data_a <= 1'b1;
                                  next_state <= TRS_WORD2;
                                end else begin
                                  next_state <= WAIT_FOR_TRS;
                                  clr_cmp <= 1'b1;
                                end
                              end
                            end

          TRS_WORD2 :       begin
                              if (cmp_linkb) begin
                                if (prev_rxdatab == 20'd0 && ~trs_notmatch_b) begin
                                   clr_notmatch_b <= 1'b1;
                                end else begin
                                   set_notmatch_b <= 1'b1;
                                end

                                if (data_a == 20'd0) begin
                                  stored_data_b <= 1'b1;
                                  next_state <= TRS_SEEN;
                                end else begin
                                  next_state <= WAIT_FOR_TRS;
                                  clr_cmp <= 1'b1;
                                end

                              end else if (cmp_linka) begin
                                if (prev_rxdata == 20'd0 && ~trs_notmatch_a) begin
                                   clr_notmatch_a <= 1'b1; 
                                end else begin
                                   set_notmatch_a <= 1'b1;
                                end

                                if (data_b == 20'd0) begin
                                   stored_data_a <= 1'b1;
                                   next_state <= TRS_SEEN;
                                end else begin
                                   next_state <= WAIT_FOR_TRS;
                                   clr_cmp <= 1'b1;
                                end
                              end
                            end

          TRS_SEEN :        begin
                              if (cmp_linkb) begin
                                if (prev_rxdatab == 20'd0 && ~trs_notmatch_b) begin
                                   clr_notmatch_a_b <= 1'b1;
                                end else begin
                                   set_notmatch_b <= 1'b1;
                                end

                              end else if (cmp_linka) begin
                                if (prev_rxdata == 20'd0 && ~trs_notmatch_a) begin
                                   clr_notmatch_a_b <= 1'b1;
                                end else begin
                                   set_notmatch_a <= 1'b1;
                                end
                              end
                              next_state <= RESULT;
                            end

          RESULT :          begin
                              if (trs_notmatch_a || trs_notmatch_b) begin
                                notsync <= 1'b1;
                                if (cmp_linka && trs_notmatch_a) begin
                                  inc_err_a <= 1'b1;
                                end else if (cmp_linkb && trs_notmatch_b) begin
                                  inc_err_b <= 1'b1;
                                end

                                if (error_count_a == 3 || error_count_b == 3) begin
                                  error <= 1'b1;
                                  $display ("\n-- Transceiver was unable to recover by the end of switching line.\n");
                                  next_state <= IDLE;
                                end else if (error_count_a < 3 || error_count_b < 3) begin
                                  $display ("Link A and Link B are not in sync.");
                                  next_state <= WAIT_FOR_TRS;
                                end
                              end

                              if (~(trs_notmatch_a || trs_notmatch_b) && ~dl_in_sync) begin
                                 if (error_count_a < 3 || error_count_b < 3) begin
                                    rst_err_cnt <= 1'b1;
                                    // error <= 1'b0;
                                    $display ("\n-- Link A and Link B are back in sync.\n");
                                    next_state <= WAIT_FOR_EAV;
                                    $display ("Waiting for eav to check line number...");
                                    // if (error_count_a < 3 || error_count_b < 3) notsync <= 1'b0;
                                 end else begin
                                    error <= 1'b1;
                                    $display ("\n-- Transceiver was unable to recover by the end of switching line.\n");
                                    next_state <= IDLE;
                                 end
                              end else if (~(trs_notmatch_a || trs_notmatch_b || ~dl_in_sync )) begin
                                  $display ("\n-- Link A and Link B are in sync. Waiting for the next TRS.");
                                  next_state <= IDLE;
                              end
                              clr_cmp <= 1'b1;
                            end

          WAIT_FOR_EAV :    begin
                               if (rx_eav) begin
                                  next_state <= CHECK_LN_NUMBER;
                                  $display ("Checking LN number...");
                               end
                            end

          CHECK_LN_NUMBER : begin
                               if (data_a == BLANK_DATA) begin
                                  if (rx_ln_b == rx_ln) begin
                                     notsync <= 1'b0;
                                     $display ("LN for link A & B are the same. Test passed!\n");
                                     // error <= 1'b0;
                                  end else begin
                                     error <= 1'b1;
                                     $display ("LN for link A & B are different.\n");
                                  end
                                  next_state <= IDLE;
                               end
                            end

          default :        next_state <= IDLE;
        endcase
    end
endmodule
