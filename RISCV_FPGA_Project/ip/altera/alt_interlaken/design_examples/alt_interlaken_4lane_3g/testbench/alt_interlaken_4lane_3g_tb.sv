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




`timescale 1 ps / 1 ps

module alt_interlaken_4lane_3g_tb ();
   reg ref_clk 	    = 1'b0;
   reg mac_clk 	    = 1'b0;
   reg cal_blk_clk  = 1'b0;

   wire [3:0] tx_pins;
   wire [3:0] rx_pins = tx_pins;

   wire[31:0] crc32_errors;
   wire[31:0] tx_packet_cnt0,tx_packet_cnt1, rx_packet_cnt0, rx_packet_cnt1;
   wire [15:0] crc24_errors;
   wire fully_locked;

   reg arst;
   reg[31:0] previous_tx_packet_cnt0;
   reg[31:0] previous_tx_packet_cnt1;
   reg[31:0] previous_rx_packet_cnt0;
   reg[31:0] previous_rx_packet_cnt1;
   reg[31:0] save_crc32_error_count;
   reg  crc24_errors_found;
   reg  crc32_errors_found;
   reg crc32_state_saved;
   
   alt_interlaken_4lane_3g dut (
				  .interlaken_0_tx_mac_clk_clk(mac_clk),
				  .interlaken_0_cal_blk_clk(cal_blk_clk),
				  .interlaken_0_rx_mac_clk_clk(mac_clk),
				  .interlaken_0_ref_clk(ref_clk),
	       //		  .interlaken_0_tx_lane_r_reset(arst),
				  .alt_ntrlkn_sample_channel_client_0_rx_arst_reset(~fully_locked),
				  .alt_ntrlkn_sample_channel_client_0_tx_arst_reset(~fully_locked),
		//                .interlaken_0_tx_mac_r_reset(arst),
				  .alt_ntrlkn_sample_channel_client_1_rx_arst_reset(~fully_locked),
				  .alt_ntrlkn_sample_channel_client_1_tx_arst_reset(~fully_locked),
	       //		  .interlaken_0_rx_mac_r_reset(arst),
                                  .interlaken_0_reset_export(arst),
				  .interlaken_0_rx_status_per_lane_crc32_errs(crc32_errors),
				  .alt_ntrlkn_sample_channel_client_0_tx_counter_export(tx_packet_cnt0),
				  .alt_ntrlkn_sample_channel_client_1_tx_counter_export(tx_packet_cnt1),
				  .alt_ntrlkn_sample_channel_client_0_rx_counter_export(rx_packet_cnt0),
				  .alt_ntrlkn_sample_channel_client_1_rx_counter_export(rx_packet_cnt1),
				  .interlaken_0_rx_status_error_count(crc24_errors),
				  .interlaken_0_tx_serial_data0_export(tx_pins[3:0]),
				  .interlaken_0_rx_serial_data0_export(rx_pins[3:0]),
				  .interlaken_0_tx_control_force_transmit(1'b0),
				  .interlaken_0_tx_control_channel_enable(2'b11),
				  .alt_ntrlkn_sample_channel_client_0_tx_clk_clk(mac_clk),
				  .alt_ntrlkn_sample_channel_client_0_rx_clk_clk(mac_clk),
				  .alt_ntrlkn_sample_channel_client_1_tx_clk_clk(mac_clk),
				  .alt_ntrlkn_sample_channel_client_1_rx_clk_clk(mac_clk),				
				  .interlaken_0_rx_status_fully_locked(fully_locked)
				  );
	defparam dut.interlaken_0.alt_ilk_hsio_bank_0.SIM_FAST_RESET = 1'b1;
        defparam dut.interlaken_0.alt_rst.SIM_FAST_RESET  = 1'b1;
   
   initial begin
      previous_tx_packet_cnt0  = 32'b0;
      previous_tx_packet_cnt1  = 32'b0;
      previous_rx_packet_cnt0  = 32'b0;
      previous_rx_packet_cnt1  = 32'b0;
      save_crc32_error_count   = 1'b0;
      crc24_errors_found       = 1'b0;
      crc32_errors_found       = 1'b0;
      crc32_state_saved        = 1'b0;
      save_crc32_error_count   = 32'b0;
      
      #1 arst = 1'b1;
      repeat (20) @(negedge mac_clk);
      
      arst = 1'b0;
   end

   //156.25 MHz reference clock
   always begin
      #3200 ref_clk = ~ref_clk;
      
   end

   //Running MAC at 156.25 MHz
   always begin
      #3200 mac_clk = ~mac_clk;
      
   end
 
   //50 MHz cal_blk_clk
   always begin
      #10000 cal_blk_clk = ~cal_blk_clk;
      
   end

   //Keeping track of the incrementing TX packet counts from the sample_channel_client
   always @(tx_packet_cnt0) begin
      if(tx_packet_cnt0 !== 32'b0) begin
	 if(tx_packet_cnt0 !== previous_tx_packet_cnt0+1) begin
	    $display("Error, tx_packet_cnt0 should be incrementing on each transmission");
	    
	 end
	 previous_tx_packet_cnt0 <= tx_packet_cnt0;
      end
   end
  
   always @(tx_packet_cnt1) begin
      if(tx_packet_cnt1 !== 32'b0) begin
	 if(tx_packet_cnt1 !== previous_tx_packet_cnt1+1) begin
	    $display("Error, tx_packet_cnt1 should be incrementing on each transmission");
	    
	 end
	 previous_tx_packet_cnt1 <= tx_packet_cnt1;
      end
   end

   //Keeping track of the received packets  
   always @(rx_packet_cnt0) begin
      if(rx_packet_cnt0 !== 32'b0) begin
	 if(rx_packet_cnt0 !== previous_rx_packet_cnt0+1) begin
	    $display("Error, rx_packet_cnt0 should be incrementing on each transmission");
	    
	 end
	 previous_rx_packet_cnt0 <= rx_packet_cnt0;
      end
   end

   always @(rx_packet_cnt1) begin
      if(rx_packet_cnt1 !== 32'b0) begin
	 if(rx_packet_cnt1 !== previous_rx_packet_cnt1+1) begin
	    $display("Error, rx_packet_cnt1 should be incrementing on each transmission");
	    
	    end
	 previous_rx_packet_cnt1 <= rx_packet_cnt1;
      end      
   end

   //Stop simulation once at least 100 packets are sent through succesfully  
   always @(posedge mac_clk) begin
      if(rx_packet_cnt0 >= 'd100 && rx_packet_cnt1 >= 'd100) begin
	 $display("Test complete");
	 $display("Received %d packets on channel 0",rx_packet_cnt0);
	 $display("Received %d packets on channel 1",rx_packet_cnt1);
	 if(crc24_errors_found == 1'b0 && crc32_errors_found == 1'b0) begin
	    $display("Simulation success...");
	    
	 end
	 else begin
	    $display("Simulation failed...");
	    
	 end	 
	 $finish();
	 
	 end
   end
   
   always @(posedge fully_locked) begin
      if(crc32_state_saved == 1'b0) begin
	 save_crc32_error_count  = crc32_errors;
	 crc32_state_saved 	 = 1'b1;
	 
      end
   end

   //Need to monitor for CRC24 and CRC 32 errors
   //CRC32 errors will occur before lock, but should stabilize after RX is locked
   //It's possible to have a low number of CRC 24 errors shortly after lock.  Should stabilize shortly after RX locked.
   always @(posedge mac_clk) begin
      if(fully_locked) begin
	 //Explicitly allowing for a single CRC24 error, as explained above
	 if(crc24_errors !== 1'b0 && crc24_errors_found == 1'b0) begin
	    $display("SIMULATION FAILURE: CRC 24 errors reported");
	    crc24_errors_found  = 1;
	    
	 end
	 else if(crc32_errors !== save_crc32_error_count && crc32_errors_found === 1'b0 && crc32_state_saved === 1'b1) begin
 	    $display("SIMULATION FAILURE: CRC 32 errors reported");
	    crc32_errors_found  = 1;
	    
	 end
      end
   end
   
endmodule
