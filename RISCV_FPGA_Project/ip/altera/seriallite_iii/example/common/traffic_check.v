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


`ifdef SIMULATION
`include "testbench_defs.v"
`endif


module traffic_check #
(
   parameter                     lanes                   = 4              // Number of lanes on the link
)
(
   // Clocks and reset
   input                         user_clock,
   input                         user_clock_reset,

`ifdef SIMULATION
   // Traffic checker ports
   input       [63:0]            burst_descr,
   input                         burst_descr_ready,
   output reg                    burst_descr_read,
`endif

   // Streaming data interface
   input       [(lanes*64)-1:0]  data,
   input       [3:0]             sync,
   input                         valid,
   input                         start_of_burst,
   input                         end_of_burst,

   // Test control ports
   input                         tc_enable,
   input                         tc_test_mode,
   input                         tc_enable_stalls,

   // Status interface
   output reg  [26:0]            tc_burst_count,
   output reg  [63:0]            tc_words_received,
   output reg  [lanes-1:0]       tc_lane_swap_error,
   output reg  [lanes-1:0]       tc_lane_sequence_error,
   output reg  [lanes-1:0]       tc_lane_alignment_error
);


   reg         [(lanes*64)-1:0]  last_valid_lane_data;
   reg                           last_valid_lane_data_valid;


   //
   // tc_test_mode synchronizer.
   //
   wire  sync_tc_test_mode;

   dp_sync #
   (
      .dp_width(1),
      .dp_reset(1'b1)
   )
   tc_test_mode_sync
   (
      .async_reset_n(~user_clock_reset),
      .sync_reset_n(1'b1),
      .clk(user_clock),
      .sync_ctrl(2'd2),
      .d(tc_test_mode),
      .o(sync_tc_test_mode)
   );


   //
   // tc_enable_stalls synchronizer.
   //
   wire  sync_tc_enable_stalls;

   dp_sync #
   (
      .dp_width(1),
      .dp_reset(1'b1)
   )
   tc_enable_stalls_sync
   (
      .async_reset_n(~user_clock_reset),
      .sync_reset_n(1'b1),
      .clk(user_clock),
      .sync_ctrl(2'd2),
      .d(tc_enable_stalls),
      .o(sync_tc_enable_stalls)
   );


   //
   // Traffic Checker Storage
   //
   always @(posedge user_clock or posedge user_clock_reset) begin

      if (user_clock_reset == 1'b1) begin

         last_valid_lane_data       <= {(64*lanes){1'b0}};
         last_valid_lane_data_valid <= 1'b0;

         tc_burst_count             <= 16'd0;
         tc_words_received          <= 64'd0;

      end else begin

         last_valid_lane_data       <= (valid == 1'b1) ? data : last_valid_lane_data;
         last_valid_lane_data_valid <= (valid == 1'b1) ? 1'b1 : last_valid_lane_data_valid;

         tc_burst_count             <= ((valid == 1'b1) && (tc_words_received == 64'd0)) ? 16'd1 :
                                       ((valid == 1'b1) && (start_of_burst == 1'b1))  ? tc_burst_count + 16'd1 : tc_burst_count;
         tc_words_received          <= (valid == 1'b1) ? tc_words_received + 64'd1 : tc_words_received;

      end

   end


   genvar lane;

   generate

      for (lane = 0; lane < lanes; lane = lane + 1) begin : lane_traffic_check_inst

         wire        [4:0]             data_lane_number;
         wire        [26:0]            data_burst_number;
         wire        [31:0]            data_sample_number;
         wire        [31:0]            last_valid_lane_data_sample_number;

         wire        [63:0]            lane_a_data;
         wire        [63:0]            lane_b_data;


         assign data_lane_number                   = data[((lanes*64)- 1)-(lane*64)-: 5];
         assign data_burst_number                  = data[((lanes*64)- 6)-(lane*64)-:27];
         assign data_sample_number                 = data[((lanes*64)-33)-(lane*64)-:32];
         assign last_valid_lane_data_sample_number = last_valid_lane_data[((lanes*64)-33)-(lane*64)-:32];

         //assign lane_a_data = (lane < lanes-1) ? data[(((lanes*64)-1)-(lane*64))-:64]     & 64'h07FFFFFFFFFFFFFF : 64'd0;
         //assign lane_b_data = (lane < lanes-1) ? data[(((lanes*64)-1)-((lane+1)*64))-:64] & 64'h07FFFFFFFFFFFFFF : 64'd0;

        // Fixed at lane 0
        assign lane_a_data = (lane < lanes-1) ? data[63:0] & 64'h07FFFFFFFFFFFFFF : 64'd0;
        assign lane_b_data = (lane < lanes-1) ? data[(((lane+1)*64)-1):((lane)*64)] & 64'h07FFFFFFFFFFFFFF : 64'd0;
         always @(posedge user_clock or posedge user_clock_reset) begin

            if (user_clock_reset == 1'b1) begin

               tc_lane_swap_error[lane]         <= 1'b0;
               tc_lane_sequence_error[lane]     <= 1'b0;
               tc_lane_alignment_error[lane]    <= 1'b0;

            end else begin

               // Check for lane swap error
               if ((valid == 1'b1) && (data_lane_number != lane) && (tc_enable == 1'b1)) begin

                  tc_lane_swap_error[lane] <= 1'b1;

                  `ifdef SIMULATION

                     $write("   *** ERROR *** Lane Swap Error on lane %0d at %0t\n", lane, $time);
                     $write("                 Expected lane number %0d got lane number %0d\n", lane, data_lane_number);

                  `endif

               end else begin
                   tc_lane_swap_error[lane] <= 1'b0;
               end

               // Check for non-monotonicly increasing sample number
               if ((last_valid_lane_data_valid == 1'b1) && (valid == 1'b1) && (data_sample_number != last_valid_lane_data_sample_number + 32'd1) && (tc_enable == 1'b1)) begin

                  tc_lane_sequence_error[lane] <= 1'b1;

                  `ifdef SIMULATION

                     $write("   *** ERROR *** Lane Sequence Error on lane %0d at %0t\n", lane, $time);
                     $write("                 Expected sample number %0d got sample number %0d\n", last_valid_lane_data_sample_number + 32'd1, data_sample_number);

                  `endif

                end          // Check for burst number inconsistancy at start of burst
                else if ((valid == 1'b1) && (start_of_burst == 1'b1) && (data_burst_number != tc_burst_count + 16'd1) && (tc_enable == 1'b1)) begin

                  tc_lane_sequence_error[lane] <= 1'b1;

                  `ifdef SIMULATION

                     $write("   *** ERROR *** Lane Sequence Error on lane %0d during burst start at %0t\n", lane, $time);
                     $write("                 Expected burst number %0d got burst number %0d\n", tc_burst_count + 16'd1, data_burst_number);

                  `endif

               end


               // Check for burst number inconsistancy in burst
               else if ((valid == 1'b1) && (start_of_burst == 1'b0) && (data_burst_number != tc_burst_count) && (tc_enable == 1'b1)) begin

                  tc_lane_sequence_error[lane] <= 1'b1;

                  `ifdef SIMULATION

                     $write("   *** ERROR *** Lane Sequence Error on lane %0d at %0t\n", lane, $time);
                     $write("                 Expected burst number %0d got burst number %0d\n", tc_burst_count, data_burst_number);

                  `endif

                end else begin
                  tc_lane_sequence_error[lane] <= 1'b0;
                end


               // Check for an alignment error between lane (lanes-1) and lane 0.
               if ((valid == 1'b1) && (lane_a_data != lane_b_data) && (tc_enable == 1'b1)) begin

                  tc_lane_alignment_error[lane] <= 1'b1;

                  `ifdef SIMULATION

                     $write("   *** ERROR *** Lane Alignment Error on lane %0d at %0t\n", lane, $time);
                     $write("                 Expected data %16.16h got data %16.16h\n", lane_a_data, lane_b_data);

                  `endif

                end else begin
                   tc_lane_alignment_error[lane] <= 1'b0;
                end


            end

         end

      end

   endgenerate


`ifdef SIMULATION

   wire     [7:0]             burst_descr_type;
   wire     [7:0]             burst_descr_inter_burst_interval;
   wire     [3:0]             burst_descr_sync_value;
   wire     [31:0]            burst_descr_sample_number;

   reg      [0:255]           burst_descr_type_encode;

   assign burst_descr_type                   = burst_descr[63:56];
   assign burst_descr_stall_duration         = burst_descr[55:48];
   assign burst_descr_inter_burst_interval   = burst_descr[55:48];
   assign burst_descr_sync_value             = burst_descr[47:44];
   assign burst_descr_sample_number          = burst_descr[31:00];


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
   // Burst Descriptor Checking clocked process
   //
   always @(posedge user_clock or posedge user_clock_reset) begin

      if (user_clock_reset == 1'b1) begin

      end else begin

         // Burst end descriptor
         if ((burst_descr_ready == 1'b1) && (tc_enable == 1'b1)) begin

            case (burst_descr_type)

               // Burst start/end descriptor
               `BURST_DESCR_START_END: begin

                  // Wait for the next end of burst and check consistency
                  if (start_of_burst == 1'b1) begin

                     $write("\n");
                     $write("   Traffic Checker: Burst start/end descriptor read at time %0t\n", $time);
                     $write("                    Inter-burst interval %0d\n", burst_descr_inter_burst_interval);
                     $write("                    Sync value %0d\n",           burst_descr_sync_value);
                     $write("                    Sample number %0d\n",        burst_descr_sample_number);

                     if (burst_descr_sync_value != sync) begin

                        $write("\n");
                        $write("   Traffic Checker: *** ERROR *** Sync value verification error at time %0t\n", $time);
                        $write("                    Expected sync value %0d got sync value %0d on incoming burst\n", burst_descr_sync_value, sync);

                        test_env.testbench.test_abort = 1;

                     end

                     if (burst_descr_sample_number != data[31:0]) begin

                        $write("\n");
                        $write("   Traffic Checker: *** ERROR *** Sample number verification error at time %0t\n", $time);
                        $write("                    Expected sample number %0d got sample number %0d on incoming burst\n", burst_descr_sample_number, data[31:0]);

                        test_env.testbench.test_abort = 1;

                     end

                  end

               end


               // Burst start descriptor
               `BURST_DESCR_START: begin

                  // Wait for the next end of burst and check consistency
                  if (start_of_burst == 1'b1) begin

                     $write("\n");
                     $write("   Traffic Checker: Burst start descriptor read at time %0t\n", $time);
                     $write("                    Sync value %0d\n",           burst_descr_sync_value);
                     $write("                    Sample number %0d\n",        burst_descr_sample_number);

                     if (burst_descr_sync_value != sync) begin

                        $write("\n");
                        $write("   Traffic Checker: *** ERROR *** Sync value verification error at time %0t\n", $time);
                        $write("                    Expected sync value %0d got sync value %0d on incoming burst\n", burst_descr_sync_value, sync);

                        test_env.testbench.test_abort = 1;

                     end

                     if (burst_descr_sample_number != data[31:0]) begin

                        $write("\n");
                        $write("   Traffic Checker: *** ERROR *** Sample number verification error at time %0t\n", $time);
                        $write("                    Expected sample number %0d got sample number %0d on incoming burst\n", burst_descr_sample_number, data[31:0]);

                        test_env.testbench.test_abort = 1;

                     end

                  end

               end


               // Burst end descriptor
               `BURST_DESCR_END: begin

                  // Wait for the next end of burst and check consistency
                  if (end_of_burst == 1'b1) begin

                     $write("\n");
                     $write("   Traffic Checker: Burst end descriptor read at time %0t\n", $time);
                     $write("                    Inter-burst interval %0d\n", burst_descr_inter_burst_interval);
                     $write("                    Sync value %0d\n",           burst_descr_sync_value);
                     $write("                    Sample number %0d\n",        burst_descr_sample_number);

                     if (burst_descr_sync_value != sync) begin

                        $write("\n");
                        $write("   Traffic Checker: *** ERROR *** Sync value verification error at time %0t\n", $time);
                        $write("                    Expected sync value %0d got sync value %0d on incoming burst\n", burst_descr_sync_value, sync);

                        test_env.testbench.test_abort = 1;

                     end

                  end

               end


               // Stall descriptor
               `BURST_DESCR_STALL: begin

                  // Wait for the next stall and check consistency
                  if (valid == 1'b0) begin

                     $write("\n");
                     $write("   Traffic Checker: Burst stall descriptor read at time %0t\n", $time);
                     $write("                    Stall duration %0d\n", burst_descr_stall_duration);
                     $write("                    Sample Number %0d\n",  burst_descr_sample_number);

                  end

               end


               default: begin

               end

            endcase

         end else begin

         end

      end

   end


   //
   // Burst Descriptor Checking combinatorial process
   //
   always @(*) begin

      if (user_clock_reset == 1'b1) begin

         burst_descr_read  = 1'b0;

      end else begin

         // Burst end descriptor
         if (burst_descr_ready == 1'b1) begin

            case (burst_descr_type)

               // Burst start/end descriptor
               `BURST_DESCR_START_END: begin

                  // Wait for the next end of burst and check consistency
                  burst_descr_read  = (start_of_burst == 1'b1) ? 1'b1 : 1'b0;

               end


               // Burst start descriptor
               `BURST_DESCR_START: begin

                  // Wait for the next end of burst and check consistency
                  burst_descr_read  = (start_of_burst == 1'b1) ? 1'b1 : 1'b0;

               end


               // Burst end descriptor
               `BURST_DESCR_END: begin

                  // Wait for the next end of burst and check consistency
                  burst_descr_read  = (end_of_burst == 1'b1) ? 1'b1 : 1'b0;

               end


               // Stall descriptor
               `BURST_DESCR_STALL: begin

                  // Wait for the next stall and check consistency
                  burst_descr_read  = (valid == 1'b0) ? 1'b1 : 1'b0;

               end


               default: begin

                  burst_descr_read  = 1'b0;

               end

            endcase

         end else if (tc_enable == 1'b0) begin

            burst_descr_read  = 1'b1;

         end else begin

            burst_descr_read  = 1'b0;

         end

      end

   end

`endif


endmodule
