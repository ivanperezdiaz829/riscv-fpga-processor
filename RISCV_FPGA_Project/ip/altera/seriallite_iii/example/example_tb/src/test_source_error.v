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


      if (test_name == "source_error") begin

         automatic integer  quash_delay       = $urandom_range(total_samples_to_transfer-100, 10);
         automatic integer  quash_delay_count = 0;

         $write("   \n");
         $write("   ************************* Source Adaptation Overflow Test Started ************************\n");

         // Disable the traffic checker
         tc_enable = 1'b0;

         test_found        = 1;
         tg_test_mode      = $urandom_range(1, 0);
         tg_enable_stalls  = $urandom_range(1, 0);

         $write("   \n");
         $write("   Test Mode: ");
         if (tg_test_mode == `CONTINUOUS) $write("Continuous\n"); else  $write("Burst\n");

         $write("   \n");
         $write("   User Stall Insertion: ");
         if (tg_enable_stalls == 1'b1) $write("Enabled\n"); else  $write("Disabled\n");

         // Wait for the deassertion of snk_user_clock_reset
         while (test_env.snk_user_clock_reset == 1'b1) @(posedge test_env.snk_user_clock);

         // Wait for the assertion of snk_link_up
         while (test_env.snk_link_up == 1'b0) @(posedge test_env.snk_user_clock);

         // Start transmission
         tg_enable = 1'b1;

         // Wait for start of data
         while (test_env.snk_valid != 1'b0) @(posedge test_env.snk_user_clock);

         // Wait for random delay before forcing overflow
         while (quash_delay_count != quash_delay) begin

            @(posedge test_env.snk_user_clock);
            ++quash_delay_count;

         end

         $write("   \n");
         $write("   Forcing overflow at time %0t\n", $time);

         @(posedge test_env.src_user_clock);

         // Suppress reads of the source adaptation fifo until the FIFO
         // overflows.
         `ifdef DUPLEX_MODE
         force test_env.duplex_inst.source_adaptation.adaptation_FIFO_rdreq = {lanes{1'b0}};
         `else
         force test_env.source_inst.source_adaptation.adaptation_FIFO_rdreq = {lanes{1'b0}};
         `endif

         @(posedge test_env.src_user_clock);
         
         `ifdef DUPLEX_MODE
         while (test_env.duplex_inst.source_adaptation.adaptation_FIFO_full == {lanes{1'b0}}) @(posedge test_env.src_user_clock);
         release test_env.duplex_inst.source_adaptation.adaptation_FIFO_rdreq;
         `else
         while (test_env.source_inst.source_adaptation.adaptation_FIFO_full == {lanes{1'b0}}) @(posedge test_env.src_user_clock);
         release test_env.source_inst.source_adaptation.adaptation_FIFO_rdreq;
         `endif
         
         // Wait for the source error to register, a test error, or a test timeout.
         while ((test_env.src_error == 1'b0) && (test_abort == 0)) begin
        `ifdef DUPLEX_MODE 
            @(posedge test_env.duplex_inst.source_adaptation.user_clock);
        `else
            @(posedge test_env.source_inst.source_adaptation.user_clock);
        `endif
               ++timeout_count;

            if (timeout_count >= 2 * total_samples_to_transfer) begin

               test_abort = 1;
               $write("   \n");
               $write("   *** ERROR *** Test timeout at %0t\n", $time);

            end

         end

         if (test_env.src_error == 1'b1) begin

            $write("   \n");
            $write("   Source error due to overflow detected at %0t\n", $time);

         end


         //
         // Check for unexpected sink errors
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

         $write("   \n");
         $write("   ************************ Source Adaptation Overflow Test Completed ***********************\n");

      end
