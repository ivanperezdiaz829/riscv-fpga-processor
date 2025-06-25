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


      if (test_name == "data_forwarding") begin

         $write("   \n");
         $write("   ******************************* Data Forwarding Test Started *****************************\n");

         test_found        = 1;
         tg_test_mode      = $urandom_range(1, 0);
         tg_enable_stalls  = $urandom_range(1, 0);
         test_timeout      = 2 * total_samples_to_transfer;

         $write("   \n");
         $write("   Test Mode:            ");
         if (tg_test_mode == `CONTINUOUS) $write("Continuous\n"); else  $write("Burst\n");

         $write("   User Stall Insertion: ");
         if (tg_enable_stalls == 1'b1) $write("Enabled\n"); else  $write("Disabled\n");
         $write("   \n");

         // Wait for the deassertion of snk_user_clock_reset
         while (test_env.snk_user_clock_reset == 1'b1) @(posedge test_env.snk_user_clock);

         // Wait for the assertion of snk_link_up
         while (test_env.snk_link_up == 1'b0) @(posedge test_env.snk_user_clock);

         // Start transmission
         tg_enable = 1'b1;

         // Wait for the required number of data words to be transferred, 
         // a test error, or a test timeout.
         while ((samples_received < total_samples_to_transfer) && (test_abort == 0)) begin
              
            @(posedge test_env.snk_user_clock);
            ++timeout_count;

            if (timeout_count >= test_timeout * total_samples_to_transfer) begin

               test_abort = 1;
               $write("   \n");
               $write("   *** ERROR *** Test timeout at %0t\n", $time);

            end

         end


         // Wait for another 100 clock cycles to make sure there are no late breaking errors.

         timeout_count = 0;

         while (timeout_count < 100) begin
              
            @(posedge test_env.snk_user_clock);
            ++timeout_count;

         end


         //
         // Check for source errors
         //
         if (source_overflow_error_count != 0) begin

            test_abort = 1;
            $write("   \n");
            $write("   *** ERROR *** %0d source overflow errors detected\n", source_overflow_error_count);

         end


         //
         // Check for sink errors
         //
         if (sink_underflow_error_count != 0) begin

            test_abort = 1;
            $write("   \n");
            $write("   *** ERROR *** %0d sink underflow errors detected\n", sink_underflow_error_count);

         end

         if (sink_loss_of_alignment_normal_error_count != 0) begin

            test_abort = 1;
            $write("   \n");
            $write("   *** ERROR *** %0d sink loss of alignment during normal operation errors detected\n", sink_loss_of_alignment_normal_error_count);

         end

         if (sink_loss_of_alignment_init_error_count != 0) begin

            test_abort = 1;
            $write("   \n");
            $write("   *** ERROR *** %0d sink loss of alignment during initialization errors detected\n", sink_loss_of_alignment_init_error_count);

         end

         for (lane = 0; lane < lanes; ++lane) begin

            if (sink_meta_frame_crc_error_count[lane] != 0) begin

               test_abort = 1;
               $write("   \n");
               $write("   *** ERROR *** %0d sink meta frame CRC32 errors on lane %0d detected\n", sink_meta_frame_crc_error_count[lane], lane);

            end

         end


         //
         // Check for traffic checker errors
         //
         if (lane_swap_error_count != 0) begin

               test_abort = 1;
               $write("   \n");
               $write("   *** ERROR *** %0d lane swap errors detected\n", lane_swap_error_count);

         end

         if (lane_sequence_error_count != 0) begin

               test_abort = 1;
               $write("   \n");
               $write("   *** ERROR *** %0d lane sequence errors detected\n", lane_sequence_error_count);

         end

         if (lane_alignment_error_count != 0) begin

               test_abort = 1;
               $write("   \n");
               $write("   *** ERROR *** %0d lane alignment errors detected\n", lane_alignment_error_count);

         end

         $write("   \n");
         $write("   ****************************** Data Forwarding Test Completed ****************************\n");

      end
