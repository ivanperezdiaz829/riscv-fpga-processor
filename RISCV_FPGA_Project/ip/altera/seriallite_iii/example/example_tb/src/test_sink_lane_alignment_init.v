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


      if (test_name == "sink_lane_alignment_init") begin

         integer lane_hold = 0;
         $write("   \n");
         $write("   ************* Sink Lane Alignment Error During Initialization Test Started ***************\n");

      
         test_found  = 1;
      //   integer  lane_hold = 0;

         test_lane   = $urandom_range(lanes-1, 0);

         // Wait for the deassertion of snk_user_clock_reset
         while (test_env.snk_user_clock_reset == 1'b1) @(posedge test_env.snk_user_clock);

         // Wait for the deassertion of src_user_clock_reset
         while (test_env.src_user_clock_reset == 1'b1) @(posedge test_env.src_user_clock);

         // Wait for the lane alignment state machine to enter the aligning state
         while (test_env.sink_inst.sink_alignment.la_sm != test_env.sink_inst.sink_alignment.LASM_TRIAL_CHECK) @(posedge test_env.snk_user_clock);

         // Force the error.
         @(posedge test_env.snk_user_clock);

         $write("   \n");
         $write("   Forcing error on lane %0d at %0t\n", test_lane, $time);

         force test_env.sink_inst.sink_alignment.lane_sync_det= {{lanes-1{1'b0}}, {1'b1}} << test_lane;
     
    //   while (lane_hold != 33) begin 
     //       @(posedge test_env.snk_user_clock);
     //       ++lane_hold;

    // end 
         @(posedge test_env.snk_user_clock);

         release test_env.sink_inst.sink_alignment.lane_sync_det;

         // Wait for the error to register, a test error, or a test timeout.
         while ((sink_loss_of_alignment_init_error_count == 0) && (test_abort == 0)) begin

            @(posedge test_env.snk_user_clock);
            ++timeout_count;

            if (timeout_count >= 2 * total_samples_to_transfer) begin

               test_abort = 1;
               $write("   \n");
               $write("   *** ERROR *** Test timeout at %0t\n", $time);

            end

         end

         if (sink_loss_of_alignment_init_error_count != 0) begin

            $write("   \n");
            $write("   Sink error due to alignment detected at %0t\n", $time);

         end


         // Wait for the link to come back up, a test error, or a test timeout.
         while ((test_env.snk_link_up == 0) && (test_abort == 0)) begin

            @(posedge test_env.snk_user_clock);
            ++timeout_count;

            if (timeout_count >= 1000) begin

               test_abort = 1;
               $write("   \n");
               $write("   *** ERROR *** Link initialization timeout at %0t\n", $time);

            end

         end


         //
         // Check for unexpected errors
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

         $write("   \n");
         $write("   ************ Sink Lane Alignment Error During Initialization Test Completed **************\n");

      end
