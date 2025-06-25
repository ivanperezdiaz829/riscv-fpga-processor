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


`timescale 1ps/1ps

`ifdef SIMULATION
`include "testbench_defs.v"
`endif
//`include "tg_defs.v"
`define  CONTINUOUS                       0
`define  BURST                            1


module traffic_gen #
(
   parameter                     lanes                         = 4,              // Number of lanes on the link
   parameter   [63:0]            total_samples_to_transfer     = 10000           // Total words transferred during the test
)
(
   // Clocks and reset
   input                         user_clock,
   input                         user_clock_reset,

`ifdef SIMULATION

   // Traffic checker ports
   output      [63:0]            burst_descr,
   output                        burst_descr_ready,
   input                         burst_descr_read,
   input                         burst_descr_read_clk,

`endif

   // Streaming data interface
   output      [(lanes*64)-1:0]  data,
   output reg  [3:0]             sync,
   output reg                    valid,
   output reg                    start_of_burst,
   output reg                    end_of_burst,
   input                         link_up,

   // Test control ports
   input                         tg_enable,
   input                         tg_test_mode,
   input                         tg_enable_stalls,

   // Status interface
   output reg  [15:0]            tg_burst_count,
   output reg  [63:0]            tg_words_transferred
);

   localparam                    words = lanes;    // The number of 64-bit words on the user interface is 
                                                   // equal to the number of lanes on the link.

`ifndef SIMULATION

   //*************************************************************************
   //
   // Instantiate the PRBS generator  
   //
   //*************************************************************************

   wire        [31:0]            prbs;

   prbs_generator #
   (
      .PRBS_INITIAL_VALUE(97),
      .DATA_WIDTH(32),
      .PRBS(23)
   ) 
   prbs_data_generator_inst
   (
      .clk(user_clock),
      .nreset(~user_clock_reset),
      .xaui_word_align(1'b0),
      .dout(prbs),
      .pause(1'b0),
      .insert_error(1'b0)
   );

`endif


   //
   // tg_enable synchronizer.
   //
   wire  sync_tg_enable;

   dp_sync #
   (
      .dp_width(1),
      .dp_reset(1'b0)
   )
   tg_enable_sync
   (
      .async_reset_n(~user_clock_reset),
      .sync_reset_n(1'b1),
      .clk(user_clock),
      .sync_ctrl(2'd2),
      .d(tg_enable),
      .o(sync_tg_enable)
   );


   //
   // tg_test_mode synchronizer.
   //
   wire  sync_tg_test_mode;

   dp_sync #
   (
      .dp_width(1),
      .dp_reset(1'b1)
   )
   tg_test_mode_sync
   (
      .async_reset_n(~user_clock_reset),
      .sync_reset_n(1'b1),
      .clk(user_clock),
      .sync_ctrl(2'd2),
      .d(tg_test_mode),
      .o(sync_tg_test_mode)
   );


   //
   // tg_enable_stalls synchronizer.
   //
   wire  sync_tg_enable_stalls;

   dp_sync #
   (
      .dp_width(1),
      .dp_reset(1'b0)
   )
   tg_enable_stalls_sync
   (
      .async_reset_n(~user_clock_reset),
      .sync_reset_n(1'b1),
      .clk(user_clock),
      .sync_ctrl(2'd2),
      .d(tg_enable_stalls),
      .o(sync_tg_enable_stalls)
   );


   //*********************************************************************
   //
   // Traffic Generator Stall Generation
   //
   //*********************************************************************

   localparam                 stall_probability    = 1;     // Probability of starting a stall in a given clock cycle (%). Set to 0 to disable.
   localparam                 stall_max_duration   = 3;     // Maximum number of clock cycles in a stall

   localparam                 IDLE                 = 2'd0;
   localparam                 ACTIVE               = 2'd1;
   localparam                 STALLING             = 2'd2;

   reg            [1:0]       stall_state, next_stall_state;

   reg                        stall_tg, next_stall_tg;

   reg            [2:0]       stall_beats, next_stall_beats;
   reg            [2:0]       beat_count, next_beat_count;

   reg            [7:0]       random_value;


   /* synthesis translate_off */

   reg [0:255] stall_state_encode;     // This string is for simulation debug

   always @ (stall_state) begin

      case (stall_state)

         IDLE:       stall_state_encode   <= "IDLE"; 
         ACTIVE:     stall_state_encode   <= "ACTIVE";
         STALLING:   stall_state_encode   <= "STALLING";

     endcase

   end

   /* synthesis translate_on */


   //
   // Traffic Generator Stall State Machine Storage
   //
   always @(posedge user_clock or posedge user_clock_reset) begin

      if (user_clock_reset == 1'b1) begin

         stall_state    <= IDLE;
         stall_beats    <= 3'd0;
         beat_count     <= 3'd0;
         stall_tg       <= 1'b0;
         random_value   <= 8'd255;

      end else begin

         stall_state    <= next_stall_state;
         stall_beats    <= next_stall_beats;
         beat_count     <= next_beat_count;
         stall_tg       <= next_stall_tg;

`ifdef SIMULATION
         random_value   <= $urandom_range(100, 1);

`else
         random_value   <=prbs[6:0];
`endif

      end

   end


   //
   // Traffic Generator Stall State Machine Decoder
   //
   always @(*) begin

      case (stall_state)

         IDLE: begin

`ifdef SIMULATION
            if ((start_of_burst == 1'b1) && ($urandom_range(100, 1) <= stall_probability) && (sync_tg_enable_stalls == 1'b1)) begin
`else
            if ((start_of_burst == 1'b1) && (prbs[6:0] <= stall_probability) && (sync_tg_enable_stalls == 1'b1)) begin
`endif
               next_stall_state     = STALLING;
               next_stall_tg        = 1'b0;
               next_beat_count      = 3'd1;

`ifdef SIMULATION
               next_stall_beats     = $urandom_range(stall_max_duration, 1);
`else
               next_stall_beats     = prbs[9:7];
`endif

            end else if (start_of_burst == 1'b1) begin

               next_stall_state     = ACTIVE;
               next_stall_tg        = 1'b0;
               next_stall_beats     = 3'd0;
               next_beat_count      = 3'd0;

            end else begin

               next_stall_state     = IDLE;
               next_stall_tg        = 1'b0;
               next_stall_beats     = 3'd0;
               next_beat_count      = 3'd0;

            end

         end


         ACTIVE: begin

            if ((random_value <= stall_probability) && (sync_tg_enable_stalls == 1'b1)) begin

               next_stall_state     = STALLING;
               next_stall_tg        = 1'b1;
               next_beat_count      = 3'd1;

`ifdef SIMULATION
               next_stall_beats     = $urandom_range(stall_max_duration, 1);
`else
               next_stall_beats     = prbs[9:7];
`endif

            end else begin

               next_stall_state     = (end_of_burst == 1'b1) ? IDLE : ACTIVE;
               next_stall_tg        = 1'b0;
               next_stall_beats     = 3'd0;
               next_beat_count      = 3'd0;

            end

         end


         STALLING: begin

            if (beat_count == stall_beats) begin

               next_stall_state     = (end_of_burst == 1'b1) ? IDLE : ACTIVE;
               next_stall_tg        = 1'b1;
               next_stall_beats     = 3'd0;
               next_beat_count      = 3'd0;

            end else begin

               next_stall_state     = (end_of_burst == 1'b1) ? IDLE : STALLING;
               next_stall_tg        = 1'b1;
               next_stall_beats     = stall_beats;
               next_beat_count      = beat_count + 3'd1;

            end

         end


         default: begin

            next_stall_state     = IDLE;
            next_stall_tg        = 1'b0;
            next_stall_beats     = 3'd0;
            next_beat_count      = 3'd0;

         end

      endcase

   end


   //*********************************************************************
   //
   // Traffic Generator Control State Machine
   //
   //*********************************************************************

   localparam                 TG_INIT              = 3'd0;
   localparam                 TG_IDLE              = 3'd1;
   localparam                 TG_ACTIVE_BURST      = 3'd2;
   localparam                 TG_ACTIVE_CONT       = 3'd3;
   localparam                 TG_ACTIVE_COMPLETE   = 3'd4;

   localparam                 max_burst_size       = 100;
   localparam                 max_inter_burst_gap  = 16;

   reg      [2:0]             tg_state, next_tg_state;
   reg                        next_start_of_burst;
   reg                        next_end_of_burst;
   reg      [3:0]             next_sync;

   reg      [7:0]             inter_burst_count, next_inter_burst_count;
   reg      [15:0]            next_tg_burst_count;
   reg      [63:0]            burst_length, next_burst_length;
   reg      [63:0]            next_tg_words_transferred;


   /* synthesis translate_off */

   reg [0:255] tg_state_encode;     // This string is for simulation debug

   always @ (tg_state) begin

      case (tg_state)

         TG_INIT:             tg_state_encode   <= "INIT"; 
         TG_IDLE:             tg_state_encode   <= "IDLE"; 
         TG_ACTIVE_BURST:     tg_state_encode   <= "ACTIVE_BURST";
         TG_ACTIVE_CONT:      tg_state_encode   <= "ACTIVE_CONT";
         TG_ACTIVE_COMPLETE:  tg_state_encode   <= "CONT_COMPLETE";

     endcase

   end


   wire [0:255] tg_test_mode_encode;     // This string is for simulation debug

   assign tg_test_mode_encode = (sync_tg_test_mode == `CONTINUOUS) ? "CONTINUOUS" : "BURST";

   /* synthesis translate_on */


   //
   // Traffic Generator Control State Machine Storage
   //
   always @(posedge user_clock or posedge user_clock_reset) begin

      if (user_clock_reset == 1'b1) begin

         tg_state             <= TG_INIT;
         start_of_burst       <= 1'b0;
         end_of_burst         <= 1'b0;
         sync                 <= 4'd0;
         tg_burst_count       <= 16'd0;
         burst_length         <= 64'd0;
         inter_burst_count    <= 8'd0;
         tg_words_transferred <= 64'd0;

      end else begin

         if (stall_tg == 1'b0) begin

            tg_state             <= next_tg_state;
            start_of_burst       <= next_start_of_burst;
            end_of_burst         <= next_end_of_burst;
            sync                 <= next_sync;
            tg_burst_count       <= next_tg_burst_count;
            burst_length         <= next_burst_length;
            inter_burst_count    <= next_inter_burst_count;
            tg_words_transferred <= next_tg_words_transferred;

         end else begin

            tg_state             <= tg_state;
            start_of_burst       <= start_of_burst;
            end_of_burst         <= end_of_burst;
            sync                 <= sync;
            tg_burst_count       <= tg_burst_count;
            burst_length         <= burst_length;
            inter_burst_count    <= inter_burst_count;
            tg_words_transferred <= tg_words_transferred;

         end

      end

   end


   //
   // Traffic Generator Control State Machine Decoder
   //
   always @* begin

      case (tg_state)

         TG_INIT: begin

            valid                      = 1'b0;
            next_tg_state              = TG_IDLE;
            next_start_of_burst        = 1'b0;
            next_end_of_burst          = 1'b0;
            next_sync                  = 4'd0;
            next_tg_burst_count        = 16'd0;
            next_burst_length          = 64'd0;
            next_tg_words_transferred  = 64'd0;

`ifdef SIMULATION
            next_inter_burst_count     = (lanes == 1) ? $urandom_range(max_inter_burst_gap, 2) : $urandom_range(max_inter_burst_gap, 1);
`else
            next_inter_burst_count     = ((lanes == 1) && (prbs[15:8]  < 2)) ? 8'd2 :
                                         ((lanes != 1) && (prbs[15:8] == 0)) ? 8'd1 :
                                         prbs[15:8];
`endif

         end


         TG_IDLE: begin

            if ((sync_tg_test_mode == `CONTINUOUS) && (tg_words_transferred < total_samples_to_transfer) && (link_up == 1'b1) && (sync_tg_enable == 1'b1)) begin

               valid                      = 1'b0;
               next_tg_state              = TG_ACTIVE_CONT;
               next_start_of_burst        = 1'b1;
               next_end_of_burst          = 1'b0;
               next_inter_burst_count     = 8'd0;
               next_tg_burst_count        = 16'd1;
               next_burst_length          = total_samples_to_transfer;
               next_tg_words_transferred  = tg_words_transferred + 64'd1;

`ifdef SIMULATION
               next_sync                  = $urandom_range(15, 0);

               $write("\n");
               $write("   Traffic Generator: %0d sample continuous transfer started at time %0t\n", total_samples_to_transfer, $time);
`else
               next_sync                  = prbs[3:0];
`endif

            end else if ((sync_tg_test_mode == `BURST) && (tg_words_transferred < total_samples_to_transfer) && (link_up == 1'b1) && (sync_tg_enable == 1'b1) && (inter_burst_count == 0)) begin

               valid                      = 1'b0;
               next_tg_state              = TG_ACTIVE_BURST;
               next_start_of_burst        = 1'b1;
               next_tg_burst_count        = tg_burst_count + 16'd1;
               next_tg_words_transferred  = tg_words_transferred + 64'd1;

               next_inter_burst_count     = 8'd0;
`ifdef SIMULATION
               next_burst_length          = $urandom_range(max_burst_size, 2);
               next_sync                  = $urandom_range(15, 0);
               //next_inter_burst_count     = ((next_burst_length == 1) && (lanes == 1)) ? $urandom_range(max_inter_burst_gap, 2) :
               //                             ((next_burst_length == 1) && (lanes != 1)) ? $urandom_range(max_inter_burst_gap, 1) :
               //                             8'd0;

               $write("\n");
               $write("   Traffic Generator: %0d sample burst started at time %0t\n", next_burst_length, $time);
`else
               next_burst_length          = prbs[15:0];
               next_sync                  = prbs[7:4];
               //next_inter_burst_count     = ((next_burst_length == 1) && (lanes == 1) && (prbs[15:8]  < 2)) ? 8'd2 :
               //                             ((next_burst_length == 1) && (lanes != 1) && (prbs[15:8] == 0)) ? 8'd1 :
               //                             prbs[15:8];
`endif

               next_end_of_burst          = (next_burst_length == 1) ? 1'b1 : 1'b0;

            end else begin

               valid                      = 1'b0;
               next_tg_state              = TG_IDLE;
               next_start_of_burst        = 1'b0;
               next_end_of_burst          = 1'b0;
               next_sync                  = 3'd0;
               next_inter_burst_count     = (inter_burst_count != 8'd0) ? inter_burst_count - 8'd1 : inter_burst_count;
               next_tg_burst_count        = tg_burst_count;
               next_burst_length          = 64'd0;
               next_tg_words_transferred  = tg_words_transferred;

            end

         end


         TG_ACTIVE_BURST: begin

            valid = (stall_tg == 1'b0) ? 1'b1 : 1'b0;


            `ifdef SIMULATION
               next_sync                  = $urandom_range(15, 0);
            `else
               next_sync                  = prbs[3:0];
            `endif
            
	    next_tg_burst_count        = tg_burst_count + 16'd1;
            next_burst_length          = burst_length;
            next_inter_burst_count     = 8'd0;
            next_tg_words_transferred  = tg_words_transferred + 64'd1;

            if ((tg_burst_count       == burst_length - 1)              ||
                (tg_words_transferred == total_samples_to_transfer - 1) ||
                (sync_tg_enable       == 1'b0))
               begin

               next_tg_state              = TG_ACTIVE_COMPLETE ; //TG_IDLE;
               next_start_of_burst        = 1'b0;
               next_end_of_burst          = 1'b1;
               //next_sync                  = sync;
               //next_tg_burst_count        = 0;
               //next_burst_length          = burst_length;
               //next_tg_words_transferred  = tg_words_transferred;


            end else begin

               next_tg_state              = TG_ACTIVE_BURST;
               next_start_of_burst        = 1'b0;
	       next_end_of_burst          = 1'b0;
               //next_end_of_burst          = ((tg_burst_count == burst_length - 1) || (tg_words_transferred == total_samples_to_transfer - 1)) ? 1'b1 : 1'b0;
            end

         end


         TG_ACTIVE_CONT: begin

            valid                      = (stall_tg == 1'b0) ? 1'b1 : 1'b0;
`ifdef SIMULATION
            next_sync                  = $urandom_range(15, 0);
`else
            next_sync                  = prbs[3:0];
`endif
            next_tg_burst_count        = tg_burst_count;
            next_burst_length          = burst_length;
            next_inter_burst_count     = 8'd0;
            next_tg_words_transferred  = tg_words_transferred + 64'd1;

            if ((tg_words_transferred == burst_length - 64'd1) || (sync_tg_enable == 1'b0)) begin

               next_tg_state              = TG_ACTIVE_COMPLETE;
               next_start_of_burst        = 1'b0;
               next_end_of_burst          = 1'b1;

            end else begin

               next_tg_state              = TG_ACTIVE_CONT;
               next_start_of_burst        = 1'b0;
               next_end_of_burst          = 1'b0;

            end 
	 end


         TG_ACTIVE_COMPLETE: begin

            //next_tg_state              = (sync_tg_enable == 1'b0) ? TG_IDLE : TG_ACTIVE_COMPLETE;
	    next_tg_state              = TG_IDLE;
            valid                      = (stall_tg == 1'b0) ? 1'b1 : 1'b0;
            next_start_of_burst        = 1'b0;
            next_end_of_burst          = 1'b0;
            //next_sync                  = sync;

`ifdef SIMULATION
               next_sync                  = $urandom_range(15, 0);
`else
               next_sync                  = prbs[3:0];
`endif


            next_tg_burst_count        = 0;
            next_burst_length          = 0; //burst_length;
            next_tg_words_transferred  = tg_words_transferred;
            
	    if(sync_tg_test_mode == `CONTINUOUS)
	    begin
               next_inter_burst_count     = 8'd0;
	    end 
	    else begin

            `ifdef SIMULATION
               next_inter_burst_count     = (lanes == 1) ? $urandom_range(max_inter_burst_gap, 2) : $urandom_range(max_inter_burst_gap, 1);
            `else
               next_inter_burst_count     = ((lanes == 1) && (prbs[15:8]  < 2)) ? 8'd2 :
                                            ((lanes != 1) && (prbs[15:8] == 0)) ? 8'd1 :
                                            prbs[15:8];
            `endif
             end

         end


         default: begin

            valid                      = 1'b0;
            next_tg_state              = TG_IDLE;
            next_start_of_burst        = 1'b0;
            next_end_of_burst          = 1'b0;
            next_sync                  = 3'd0;
            next_tg_burst_count        = 16'd0;
            next_burst_length          = 64'd0;
            next_inter_burst_count     = 8'd0;
            next_tg_words_transferred  = 64'd0;

         end

      endcase

   end


`ifdef SIMULATION

   //*********************************************************************
   //
   // Transaction enqueue logic
   //
   //*********************************************************************

   reg      [63:0]   unbuf_burst_descr, next_unbuf_burst_descr;
   reg               unbuf_burst_descr_wr, next_unbuf_burst_descr_wr;
   reg      [1:0]    last_stall_state;


   wire     [7:0]             unbuf_burst_descr_type;
   wire     [7:0]             burst_descr_type;

   reg      [0:255]           unbuf_burst_descr_type_encode;
   reg      [0:255]           burst_descr_type_encode;


   assign unbuf_burst_descr_type = unbuf_burst_descr[63:56];
   assign burst_descr_type       = burst_descr[63:56];


   always @* begin

      case (unbuf_burst_descr_type)

         `BURST_DESCR_START_END: unbuf_burst_descr_type_encode   <= "START_END"; 
         `BURST_DESCR_START:     unbuf_burst_descr_type_encode   <= "START"; 
         `BURST_DESCR_END:       unbuf_burst_descr_type_encode   <= "END"; 
         `BURST_DESCR_STALL:     unbuf_burst_descr_type_encode   <= "STALL"; 
         default:                unbuf_burst_descr_type_encode   <= "reserved"; 

     endcase

   end


   always @* begin

      case (burst_descr_type)

         `BURST_DESCR_START_END: burst_descr_type_encode   <= "START_END"; 
         `BURST_DESCR_START:     burst_descr_type_encode   <= "START"; 
         `BURST_DESCR_END:       burst_descr_type_encode   <= "END"; 
         `BURST_DESCR_STALL:     burst_descr_type_encode   <= "STALL"; 
         default:                burst_descr_type_encode   <= "reserved"; 

     endcase

   end


   //
   // Transaction enqueue logic storage
   //
   always @(posedge user_clock or posedge user_clock_reset) begin

      if (user_clock_reset == 1'b1) begin

         unbuf_burst_descr       <= 64'd0;
         unbuf_burst_descr_wr    <= 1'b0;

      end else begin

         unbuf_burst_descr       <= next_unbuf_burst_descr;
         unbuf_burst_descr_wr    <= next_unbuf_burst_descr_wr;

      end


   end


   //
   // Transaction enqueue logic decode
   //
   always @* begin
 
      if ((start_of_burst == 1'b1) && (end_of_burst == 1'b1) && (valid == 1'b1)) begin

         next_unbuf_burst_descr     = {`BURST_DESCR_START_END, next_inter_burst_count, sync, 12'd0, tg_words_transferred[31:0]};
         next_unbuf_burst_descr_wr  = 1'b1;

      end else if ((start_of_burst == 1'b1) && (valid == 1'b1)) begin

         next_unbuf_burst_descr     = {`BURST_DESCR_START, 8'd0, sync, 12'd0, tg_words_transferred[31:0]};
         next_unbuf_burst_descr_wr  = 1'b1;

      end else if ((end_of_burst == 1'b1) && (valid == 1'b1)) begin

         next_unbuf_burst_descr     = {`BURST_DESCR_END, next_inter_burst_count, sync, 12'd0, tg_words_transferred[31:0]};
         next_unbuf_burst_descr_wr  = 1'b1;

//      end else if ((stall_state == STALLING) && (last_stall_state != STALLING)) begin

//         next_unbuf_burst_descr     = {`BURST_DESCR_STALL, {5'd0, stall_beats}, 16'd0, tg_words_transferred[31:0]};
//         next_unbuf_burst_descr_wr  = 1'b1;

      end else begin

         next_unbuf_burst_descr     = 64'd0;
         next_unbuf_burst_descr_wr  = 1'b0;

      end

   end

`endif


   //*********************************************************************
   //
   // Per-word datapath logic
   //
   //*********************************************************************

   genvar            word;

   generate

      for (word = 0; word < words; word = word + 1) begin : word_generator_inst

         /* synthesis translate_off */

         // These wires are used for simulation debug
         wire [63:0] word_data         = data[((words*64)-1)-(64*word):(words*64)-((word+1)*64)];
         wire [4:0]  word_num          = word_data[63:59];
         wire [26:0] word_burst_num    = word_data[58:32];
         wire [31:0] word_sample_num   = word_data[31:0];

         /* synthesis translate_on */


         word_traffic_gen #
         (
            .word_id(word)
         )
         word_generator
         (
            .clk(user_clock),
            .reset(user_clock_reset),
            .start_of_burst(next_start_of_burst),
            .burst_enable(valid),
            .word_data(data[((words*64)-1)-(64*word):(words*64)-((word+1)*64)])
         );

      end

   endgenerate


`ifdef SIMULATION

   //*********************************************************************
   //
   // Transaction FIFO
   //
   //*********************************************************************

   localparam  trans_fifo_depth = 16;
   localparam  trans_fifo_width = 64;

   wire        trans_fifo_empty;

   assign burst_descr_ready = ~trans_fifo_empty;


   dcfifo #
   (
      .intended_device_family("Stratix V"),
      .lpm_numwords(trans_fifo_depth),
      .lpm_showahead("ON"),
      .lpm_type("dcfifo"),
      .lpm_width(trans_fifo_width),
      .lpm_widthu($clog2(trans_fifo_depth)),
      .overflow_checking("ON"),
      .rdsync_delaypipe(5),
      .read_aclr_synch("ON"),
      .underflow_checking("ON"),
      .use_eab("ON"),
      .write_aclr_synch("ON"),
      .wrsync_delaypipe(5)
   )
   dcfifo_component
   (
      .aclr(user_clock_reset),

      .wrclk(user_clock),
      .data(unbuf_burst_descr),
      .wrreq(unbuf_burst_descr_wr),
      .wrfull(),
      .wrempty(),
      .wrusedw(),

      .rdclk(burst_descr_read_clk),
      .q(burst_descr),
      .rdreq(burst_descr_read),
      .rdempty(trans_fifo_empty),
      .rdfull(),
      .rdusedw()
   );

`endif

endmodule


module word_traffic_gen #
(
   parameter            word_id = 0
)
(
   input                clk,
   input                reset,

   input                start_of_burst,
   input                burst_enable,

   output reg  [63:0]   word_data
);

   wire         [31:0]   word_id_reg32  = word_id;
   wire         [4:0]    word_id_reg    = word_id_reg32[4:0];
   
   wire         [26:0]   burst_count_inc;
   wire         [31:0]   byte_count_inc; 
   
   assign burst_count_inc = word_data[58:32] + 27'd1;
   assign byte_count_inc  = word_data[31:0] + 32'd1;

   //
   // Traffic generator word storage
   //
   always @(posedge clk or posedge reset) begin

      if (reset == 1'b1) begin

         word_data   <= {word_id_reg, 27'd0, 32'd1};

      end else begin

         word_data   <= (start_of_burst == 1'b1) ? {word_id_reg, burst_count_inc,  word_data[31:0]        } :
                        (burst_enable   == 1'b1) ? {word_id_reg, word_data[58:32], byte_count_inc} : word_data;

      end

   end


endmodule
