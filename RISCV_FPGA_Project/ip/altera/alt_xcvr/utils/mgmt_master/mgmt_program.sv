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


package mgmt_program;

import mgmt_memory_map::*;
import mgmt_functions_h::*;

task mgmt_program;
begin

  f_sleep(10);  // sleep for 10 clocks

  // Enable reset bitmask for channel 0
  f_write_reg(ADDR_RESET_CH_BITMASK, 1);

  // reset TX and RX
  f_write_reg(ADDR_RESET_CTRL_STAT, (BIT_RESET_CTRL_STAT_RESET_TX_DIGITAL_MSK | BIT_RESET_CTRL_STAT_RESET_RX_DIGITAL_MSK));
  f_load_result(BIT_RESET_CTRL_STAT_RESET_TX_DIGITAL_MSK | BIT_RESET_CTRL_STAT_RESET_RX_DIGITAL_MSK);
  f_write_result_to_reg(ADDR_RESET_CTRL_STAT);

  // Wait for tx_ready and rx_ready
  f_wait_for_reg(ADDR_RESET_CTRL_STAT, (BIT_RESET_CTRL_STAT_RESET_TX_DIGITAL_MSK|BIT_RESET_CTRL_STAT_RESET_RX_DIGITAL_MSK));

  // Wait for pma_tx_pll_is_locked
  f_wait_for_reg_bit(ADDR_PLL_LOCKED, 0, 1);

  // Wait for PIO input bit 1 to be set
  f_wait_for_pio_bit(1, 1);

  f_usleep(1); // Sleep for 1 microsecond

  f_label(0);  // Store jump label
  f_read_reg(128);  // Read register 128 and store result
  f_write_result_to_reg(ADDR_RESET_CTRL_STAT);
  f_compare_result(32'hffffffff); // Compare previous result with 32'hffffffff
  f_write_result_bit_to_pio_bit(0, 6);  // Write result bit 0 to pio bit 6
  f_read_reg_bit(128, 2);  // Read register 128 and store bit 2 as result
  f_read_pio_bit(2);  // Read pio bit 2 and store result
  f_wait_for_pio_bit(3, 1);  // Wait for PIO bit 3 to be set
  f_write_result_bit_to_pio_bit(0, 2); // Write rsult bit 0 to pio bit 2
  f_write_pio_bit(4, 1); // Write a 1 to PIO bit 4
  f_read_reg(5);
  f_write_result_bit_to_pio_bit(3, 2);
  f_read_reg_bit(50, 31);
  f_compare_result(0);
  f_jump_not_equal_zero(0);

  f_label(1);
  f_compare_result(1);
  f_jump_not_equal_zero(1);

end
endtask

endpackage
