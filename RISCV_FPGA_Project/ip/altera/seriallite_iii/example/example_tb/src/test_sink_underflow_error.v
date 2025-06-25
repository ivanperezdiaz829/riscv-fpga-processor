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


if (test_name == "sink_underflow_error") begin

  automatic integer  quash_delay       = $urandom_range(total_samples_to_transfer-100, 10);
  automatic integer  quash_delay_count = 0;
  automatic integer  fifo_empty_delay  = 0;
  $write("   \n");
  $write("   ************************** Sink Adaptation Underflow Test Started *************************\n");

  // Disable the traffic checker
  tc_enable = 1'b0;

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

  // Wait for random delay before forcing underflow
  while (quash_delay_count != quash_delay) begin
  @(posedge test_env.snk_user_clock);
     ++quash_delay_count;
   end


  @(posedge test_env.snk_user_clock);

  // Suppress writes to the sink adaptation fifo until the FIFO underflows.
  `ifdef DUPLEX_MODE
    while (test_env.duplex_inst.sink_adaptation.lane_fifo_empty == {lanes{1'b1}}) @(posedge test_env.snk_user_clock);
    force test_env.duplex_inst.sink_adaptation.rx_datavalid = {lanes{1'b0}};
  `else
    while (test_env.sink_inst.sink_adaptation.lane_fifo_empty == {lanes{1'b1}}) @(posedge test_env.snk_user_clock);
    force test_env.sink_inst.sink_adaptation.rx_datavalid = {lanes{1'b0}};
  `endif
  $write("   \n");
  $write("   Forcing underflow at time %0t\n", $time);



  @(posedge test_env.snk_user_clock);
  `ifdef DUPLEX_MODE
  while (test_env.duplex_inst.sink_adaptation.lane_fifo_empty == {lanes{1'b0}}) @(posedge test_env.snk_user_clock);
  release test_env.duplex_inst.sink_adaptation.rx_datavalid;

  force test_env.duplex_inst.sink_adaptation.lane_read = 1'b1;
  
  `else
  while (test_env.sink_inst.sink_adaptation.lane_fifo_empty == {lanes{1'b0}}) @(posedge test_env.snk_user_clock);
  release test_env.sink_inst.sink_adaptation.rx_datavalid;

  force test_env.sink_inst.sink_adaptation.lane_read = 1'b1;
  `endif
  
  while (fifo_empty_delay != 2) begin
   @(posedge test_env.snk_user_clock);
      fifo_empty_delay++;
  end 
  
  `ifdef DUPLEX_MODE
  release test_env.duplex_inst.sink_adaptation.fi_valid;
  `else
  release test_env.sink_inst.sink_adaptation.fi_valid;
  `endif

  @(posedge test_env.snk_user_clock);

  // Wait for the sink underflow error to register, a test error, or a test timeout.
  while ((sink_underflow_error_count == 0) && (test_abort == 0)) begin

     @(posedge test_env.snk_user_clock);
        ++timeout_count;
        if (timeout_count >= 2 * total_samples_to_transfer) begin
           test_abort = 1;
           $write("   \n");
           $write("   *** ERROR *** Test timeout at %0t\n", $time);

        end

   end

   if (test_env.snk_error[(lanes+2)-1] == 1'b1) begin

         $write("   \n");
         $write("   Sink error due to underflow detected at %0t\n", $time);

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
       $write("   ************************* Sink Adaptation Underflow Test Completed ************************\n");

     end
