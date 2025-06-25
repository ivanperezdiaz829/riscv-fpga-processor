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


package th_mgmt_program;

// Define address locations for each channels' block lock signal (0x82 = 130)
`define ADDR_PCS10G_BLK_LCK_CH0 130
`define ADDR_PCS10G_BLK_LCK_CH1 `ADDR_PCS10G_BLK_LCK_CH0+256 //386
//`define ADDR_PCS10G_BLK_LCK_CH2 `ADDR_PCS10G_BLK_LCK_CH1+256 //642
//`define ADDR_PCS10G_BLK_LCK_CH3 `ADDR_PCS10G_BLK_LCK_CH2+256 //898

// Define address locations for each channels' rx_syncstatus signal (0xA9 = 169)
`define ADDR_PCS8G_RX_SYNC_CH0  169
`define ADDR_PCS8G_RX_SYNC_CH1  `ADDR_PCS8G_RX_SYNC_CH0+256 //425
//`define ADDR_PCS8G_RX_SYNC_CH2  `ADDR_PCS8G_RX_SYNC_CH1+256 //681
//`define ADDR_PCS8G_RX_SYNC_CH3  `ADDR_PCS8G_RX_SYNC_CH2+256 //937

// Define address locations for each channels' sequencer registers (0xB0 = 176)
`define ADDR_SEQ_B0_CH0         176 
`define ADDR_SEQ_B0_CH1         `ADDR_SEQ_B0_CH0+256 //432
//`define ADDR_SEQ_B0_CH2         `ADDR_SEQ_B0_CH1+256 //688 
//`define ADDR_SEQ_B0_CH3         `ADDR_SEQ_B0_CH2+256 //944 

`define ADDR_SEQ_B1_CH0         'h0B1
`define ADDR_SEQ_B1_CH1         'h1B1 //432
//`define ADDR_SEQ_B1_CH2         'h2B1 //432
//`define ADDR_SEQ_B1_CH3         'h3B1 //432

`define ADDR_FEC_CSR_B2_CH0     'h0B2
`define ADDR_FEC_CSR_B2_CH1     'h1B2
//`define ADDR_FEC_CSR_B2_CH2     'h2B2
//`define ADDR_FEC_CSR_B2_CH3     'h3B2

`define ADDR_FEC_CORR_ERR_CH0   'h0B3
`define ADDR_FEC_CORR_ERR_CH1   'h1B3
//`define ADDR_FEC_CORR_ERR_CH2   'h2B3
//`define ADDR_FEC_CORR_ERR_CH3   'h3B3

`define ADDR_FEC_UNCORR_ERR_CH0   'h0B4
`define ADDR_FEC_UNCORR_ERR_CH1   'h1B4
//`define ADDR_FEC_UNCORR_ERR_CH2   'h2B4
//`define ADDR_FEC_UNCORR_ERR_CH3   'h3B4

// Define address locations for each channels' AN registers (0xC2)
`define ADDR_AN_C2_CH0        'h0C2
`define ADDR_AN_C2_CH1        'h1C2
//`define ADDR_AN_C2_CH2        'h2C2
//`define ADDR_AN_C2_CH3        'h3C2


// Define address locations for each channels' LT registers (0xC2)
`define ADDR_LT_D2_CH0        'h0D2
`define ADDR_LT_D2_CH1        'h1D2
//`define ADDR_LT_D2_CH2        'h2D2
//`define ADDR_LT_D2_CH3        'h3D2

`define CHK_UNCORR               1
`define FEC_ERR_INJECT           4
`define GIGE_MODE                5
`define TEST_FAIL                6
`define BASER_DATA               7


import mgmt_memory_map::*;
import mgmt_functions_h::*;

task th_mgmt_program;
begin
 //f_sleep(10);  // sleep for 10 clocks
 f_usleep(75);	// sleep for 75 us to make sure calibration and reconfig is done
 // Un-comment these if using non-sequencer mode
 f_write_pio_bit(1, 0);   // de-assert reconfig_rom1_rom0bar=0->10G mode
 f_write_pio_bit(2, 0);   // de-assert reconfig_req=0
 f_write_pio_bit(10, 0);   //de-assert ch1_reconfig_rom1_rom0bar=0->10G mode
 f_write_pio_bit(11, 0);   //de-assert ch1_reconfig_req=0
// Uncomment following to check AN/LT status before starting 10G test
///// **** Check if AN has completed w/o error
/// f_wait_for_reg_bit(`ADDR_AN_C2_CH0, 2, 1); // wait for CH0 AN complete
/// f_wait_for_reg_bit(`ADDR_AN_C2_CH1, 2, 1); // wait for CH1 AN complete
///
/// f_wait_for_reg_bit(`ADDR_AN_C2_CH0, 9, 0); // wait for CH0 AN-NO failure
/// f_wait_for_reg_bit(`ADDR_AN_C2_CH1, 9, 0); // wait for CH1 AN-No failure
///
///// **** Check for PCS_MODE_RC = LT 
/// f_wait_for_reg_bit(`ADDR_SEQ_B1_CH0, 9, 1); // wait for CH0 to go in LT mode
/// f_wait_for_reg_bit(`ADDR_SEQ_B1_CH1, 9, 1); // wait for CH1 to go in LT mode
///
///// **** Check for PCS_MODE_RC = 10G
/// f_wait_for_reg_bit(`ADDR_SEQ_B1_CH0, 10, 1); // wait for CH0 to go in 10G mode
/// f_wait_for_reg_bit(`ADDR_SEQ_B1_CH1, 10, 1); // wait for CH1 to go in 10G mode
///
///// **** Check for LT was exit w/o errors
/// f_wait_for_reg_bit(`ADDR_LT_D2_CH0, 3, 0); // check CH0 LT failure=0
/// f_wait_for_reg_bit(`ADDR_LT_D2_CH1, 3, 0); // check CH1 LT failure=0
///
/// f_wait_for_reg_bit(`ADDR_LT_D2_CH0, 4, 0); // check CH0 LT error=0
/// f_wait_for_reg_bit(`ADDR_LT_D2_CH1, 4, 0); // check CH1 LT error=0

// ******************************************************************************************************
// ************ INTIAL 10G TEST HERE ********************************************************************
// ******************************************************************************************************
// The PHY powers up in 10G mode, so no need to specify the rate
 f_wait_for_reg_bit(`ADDR_PCS10G_BLK_LCK_CH0, 2, 1); // wait for CH0 blk lock to go high
 f_wait_for_reg_bit(`ADDR_PCS10G_BLK_LCK_CH1, 2, 1); // wait for CH1 blk lock to go high
 // Add more channels here as required
 //**** check if FEC is present and check error correction counters ***
 f_read_reg_bit (`ADDR_AN_C2_CH0,8);// check if AN has resulted to FEC	 
 f_jump_not_equal_zero (`FEC_ERR_INJECT) ;
 
 f_sleep(650);  // sleep 
 f_wait_for_reg_bit(`ADDR_PCS10G_BLK_LCK_CH0, 2, 1); // wait for CH0 blk lock to go high
 f_wait_for_reg_bit(`ADDR_PCS10G_BLK_LCK_CH1, 2, 1); // wait for CH1 blk lock to go high
 

f_label (`BASER_DATA) ;
 // Once block lock is achieved, enable XGMII data generator
 // The connections for the data generator(s) are done in the design_example_wrapper_nch.sv file
 // The generators and checkers are instantiated in the test_harness.sv file.
 f_write_pio_bit(4, 0);  // De-assert rx_sync_lock_ff2 
 f_write_pio_bit(5, 1);  // assert start_xgmii_test
 f_sleep(2);  // 
 f_write_pio_bit(5, 0);  // De-assert start_xgmii_test
 f_write_pio_bit(4, 1);  // Assert rx_sync_lock_ff2 
 
 f_wait_for_pio_bit(4,1); 	//wait for test pass
// ******************************************************************************************************
// ************ END 10G MODE TEST ***********************************************************************
// ******************************************************************************************************
 
// ******************************************************************************************************
// ************ BEGIN 1G TEST HERE **********************************************************************
// ******************************************************************************************************
f_label (`GIGE_MODE) ;

	// ******************************************************************************************************
	// ************ USE THIS SECTION IF SEQUENCER IS ENABLED (SYNTH_SEQ_DE = 1) *****************************
	// ******************************************************************************************************
	// **** FORCE ALL CH to 1G MODE **** (if not using 1G mode, comment this section out)
	// Writing 17 (0x11) to addr 0xB0 does the following:
	//			SEQ Force Mode[2:0] 	= 3'b001 --> This forces into GigE mode
	//			Reset SEQ 				= 1'b1   --> This resets the sequencer to initiate the change
	f_write_reg(`ADDR_SEQ_B0_CH0,17); 	// force CH0 to 1G mode
	f_write_reg(`ADDR_SEQ_B0_CH1,17); 	// force CH1 to 1G mode
	f_sleep(600);  		  				// sleep 
	// ******************************************************************************************************
	// ************ END SEQUENCER SECTION *******************************************************************
	// ******************************************************************************************************

	// ******************************************************************************************************
	// ************ USE THIS SECTION IF SEQUENCER IS NOT ENABLED (SYNTH_SEQ_DE = 0) *************************
	// ******************************************************************************************************
	//f_write_pio_bit(10, 1);   // Assert reconfig_rom1_rom0bar=1->1G mode (Ch 1)
	//f_wait_for_pio_bit(6,0); // wait for reconfig_busy to go low before Req
	//f_write_pio_bit(11, 1);   // de-assert reconfig_req=1
	//f_wait_for_pio_bit(6,1); // wait for reconfig_busy to go high
	//f_write_pio_bit(11, 0);   // de-assert reconfig_req=0
	//f_wait_for_pio_bit(6,0); // wait for reconfig_busy to go low
	//
	//f_write_pio_bit(1, 1);   // assert reconfig_rom1_rom0bar=1->1G mode (Ch 0)
	//f_wait_for_pio_bit(0,0); // wait for reconfig_busy to go low before Req
	//f_write_pio_bit(2, 1);   // assert reconfig_req=1
	//f_wait_for_pio_bit(0,1); // wait for reconfig_busy to go high
	//f_write_pio_bit(2, 0);   // de-assert reconfig_req=0
	//f_wait_for_pio_bit(0,0); // wait for reconfig_busy to go low
	// ******************************************************************************************************
	// ************ END NON-SEQUENCER SECTION *******************************************************************
	// ******************************************************************************************************

 f_wait_for_reg_bit(`ADDR_PCS8G_RX_SYNC_CH0, 0, 0); 	// wait for CH0 rx_syncstatus to go down in rcfg
 f_wait_for_reg_bit(`ADDR_PCS8G_RX_SYNC_CH1, 0, 0); 	// wait for CH1 rx_syncstatus to go odwn in rcfg
 f_wait_for_reg_bit(`ADDR_PCS8G_RX_SYNC_CH0, 0, 1); 	// wait for CH0 rx_syncstatus to go high
 f_wait_for_reg_bit(`ADDR_PCS8G_RX_SYNC_CH1, 0, 1); 	// wait for CH1 rx_syncstatus to go high
 //f_wait_for_reg_bit(`ADDR_PCS8G_RX_SYNC_CH2, 0, 1); // wait for CH2 rx_syncstatus to go high
 //f_wait_for_reg_bit(`ADDR_PCS8G_RX_SYNC_CH3, 0, 1); // wait for CH3 rx_syncstatus to go high
 
 f_write_pio_bit(3, 1);  	// assert start for Gige FSM
 f_sleep(5);  					// sleep for 5 clocks
 f_write_pio_bit(3, 0);  	// de-assert start for Gige FSM

 f_wait_for_pio_bit(5,1); //wait for ch_pass
// ******************************************************************************************************
// ************ END 1G MODE TEST ************************************************************************
// ******************************************************************************************************


// Declare tests pass and done 
 f_write_pio_bit(0, 1);

// ******************************************************************************************************
// ************ BEGIN 10G FEC TEST HERE *****************************************************************
// ******************************************************************************************************
f_label(`FEC_ERR_INJECT); 
  f_sleep(10);  //
  //
  // Procedure:
  // We will inject errors on data going from Ch0 -> Ch1 then check the error counters to make
  // sure they have the correct number of correctable and uncorrectable errors.
  // Errors of burst length 0-10 are injected. Correctable error count should be 11 in this case.
  // Errors of burst length 11-15 are injected. These are uncorrectable and that count should be 5.
  //
  // Clear FEC error counters
  f_read_reg  (`ADDR_FEC_CORR_ERR_CH1); 		// Read corr error from CH1 to clear counter
  f_read_reg  (`ADDR_FEC_UNCORR_ERR_CH1); 		// Read un-corr error from CH1 to clear counter
  f_write_reg (`ADDR_FEC_CSR_B2_CH0 , 'hD82 ); 	// Burst_len=0, enable burst err
  f_sleep(50);  // 
  f_write_reg (`ADDR_FEC_CSR_B2_CH0 , 'hD86 ); // Burst_len=1, enable burst err
  f_sleep(50);  // 
  f_write_reg (`ADDR_FEC_CSR_B2_CH0 , 'hD8A ); // Burst_len=2, enable burst err
  f_sleep(50);  // 
  f_write_reg (`ADDR_FEC_CSR_B2_CH0 , 'hD8E ); // Burst_len=3, enable burst err
  f_sleep(50);  // 
  f_write_reg (`ADDR_FEC_CSR_B2_CH0 , 'hD92 ); // Burst_len=4, enable burst err
  f_sleep(50);  // 
  f_write_reg (`ADDR_FEC_CSR_B2_CH0 , 'hD96 ); // Burst_len=5, enable burst err
  f_sleep(50);  // 
  f_write_reg (`ADDR_FEC_CSR_B2_CH0 , 'hD9A ); // Burst_len=6, enable burst err
  f_sleep(50);  // 
  f_write_reg (`ADDR_FEC_CSR_B2_CH0 , 'hD9E ); // Burst_len=7, enable burst err
  f_sleep(50);  // 
  f_write_reg (`ADDR_FEC_CSR_B2_CH0 , 'hDA2 ); // Burst_len=8, enable burst err
  f_sleep(50);  // 
  f_write_reg (`ADDR_FEC_CSR_B2_CH0 , 'hDA6 ); // Burst_len=9, enable burst err
  f_sleep(50);  // 
  f_write_reg (`ADDR_FEC_CSR_B2_CH0 , 'hDAA ); // Burst_len=10, enable burst err
  f_sleep(50);  // 
  f_write_reg (`ADDR_FEC_CSR_B2_CH0 , 'hDAE ); // Burst_len=11, enable burst err
  f_sleep(50);  // 
  f_write_reg (`ADDR_FEC_CSR_B2_CH0 , 'hDB2 ); // Burst_len=12, enable burst err
  f_sleep(50);  // 
  f_write_reg (`ADDR_FEC_CSR_B2_CH0 , 'hDB6 ); // Burst_len=13, enable burst err
  f_sleep(50);  // 
  f_write_reg (`ADDR_FEC_CSR_B2_CH0 , 'hDBA ); // Burst_len=14, enable burst err
  f_sleep(50);  // 
  f_write_reg (`ADDR_FEC_CSR_B2_CH0 , 'hDBE ); // Burst_len=15, enable burst err
  f_sleep(50);  // 
  f_sleep(100);  // 
  f_read_reg  (`ADDR_FEC_CORR_ERR_CH1); // Read corr error from CH1-should be 11
  f_compare_result(11) ;
  f_jump_not_equal_zero (`CHK_UNCORR) ;
  f_load_result(1);
  f_jump_not_equal_zero(`TEST_FAIL);

f_label(`CHK_UNCORR);
  f_read_reg  (`ADDR_FEC_UNCORR_ERR_CH1); // Read un-corr error from CH1 - should be 5
  f_compare_result(5) ;
  f_jump_not_equal_zero(`BASER_DATA);

f_label(`TEST_FAIL);
 f_wait_for_pio_bit(3,1); 	//wait for test pass
// ******************************************************************************************************
// ************ END 10G FEC MODE TEST *******************************************************************
// ******************************************************************************************************
 
end
endtask

endpackage

