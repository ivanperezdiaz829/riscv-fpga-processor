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


      if (test_name == "sink_crc32_error") begin

         automatic integer  error_delay       = $urandom_range(total_samples_to_transfer-100, 10);
         automatic integer  error_delay_count = 0;

         $write("   \n");
         $write("   ****************************** Sink CRC32 Error Test Started *****************************\n");

         // Disable the traffic checker
         tc_enable         = 1'b0;

         test_found        = 1;
         tg_test_mode      = $urandom_range(1, 0);
         tg_enable_stalls  = 0;

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

         // Wait for random delay before forcing Interlaken PHY IP CRC32 error
         // indication.
         while (error_delay_count != error_delay) begin

            @(posedge test_env.snk_user_clock);
            ++error_delay_count;

         end

         `ifdef DUPLEX_MODE         
         @(posedge test_env.duplex_inst.rx_clkout[0]);
         force test_env.duplex_inst.rx_crc32err = {lanes{1'b1}};         
         `else
         @(posedge test_env.sink_inst.rx_clkout[0]);
         force test_env.sink_inst.rx_crc32err = {lanes{1'b1}};
         `endif

         $write("   \n");
         $write("   Forcing CRC32 errors at time %0t\n", $time);


         `ifdef DUPLEX_MODE         
         @(posedge test_env.duplex_inst.rx_clkout[0]);
         @(posedge test_env.duplex_inst.rx_clkout[0]);
         `else
         @(posedge test_env.sink_inst.rx_clkout[0]);
         @(posedge test_env.sink_inst.rx_clkout[0]);
         `endif


         `ifdef DUPLEX_MODE
         release test_env.duplex_inst.rx_crc32err;
         `else
         release test_env.sink_inst.rx_crc32err;
         `endif

         // Wait for the source error to register, a test error, or a test timeout.
         @(posedge test_env.snk_user_clock);

         while ((test_env.snk_error[lanes-1:0] != {lanes{1'b1}}) && (test_abort == 0)) begin
              
            @(posedge test_env.snk_user_clock);
            ++timeout_count;

            if (timeout_count >= 2 * total_samples_to_transfer) begin

               test_abort = 1;
               $write("   \n");
               $write("   *** ERROR *** Test timeout at %0t\n", $time);

            end

         end

         if (test_env.snk_error[lanes-1:0] == {lanes{1'b1}}) begin

            $write("   \n");
            $write("   Sink error due to RX_CRC32_ERR detected at %0t\n", $time);

         end



         //
         // Check for unexpected errors
         //
         if (source_overflow_error_count != 0) begin

            test_abort = 1;
            $write("   \n");
            $write("   *** ERROR *** %0d source overflow errors detected\n", source_overflow_error_count);

         end


         //
         // Check for sink errors
         //
         if (source_overflow_error_count != 0) begin

            test_abort = 1;
            $write("   \n");
            $write("   *** ERROR *** %0d source overflow errors detected\n", source_overflow_error_count);

         end

         if (sink_overflow_error_count != 0) begin

            test_abort = 1;
            $write("   \n");
            $write("   *** ERROR *** %0d sink overflow errors detected\n", sink_overflow_error_count);

         end

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


         $write("   \n");
         $write("   ***************************** Sink CRC32 Error Test Completed ****************************\n");

      end
