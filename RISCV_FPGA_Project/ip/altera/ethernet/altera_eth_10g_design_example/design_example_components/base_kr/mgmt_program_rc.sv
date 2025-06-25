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

`define START              1
`define END                2

`define START_MIF          3
`define END_MIF            4

`define START_PMA_WRITE    5
`define END_PMA_WRITE      6

`define START_PMA_READ     7
`define END_PMA_READ       8

`define CHECK_VOD_UPDATE               9  
`define CHECK_POST_TAP_UPDATE         10   
`define CHECK_PRE_TAP_UPDATE          11  
`define VOD_PRETAP_POSTTAP_WRITE_DONE 12   


// PIO input bits

`define PIO_IN_VERIFY_PMA_WRITE     3
`define PIO_IN_LT_START_RC          2
`define PIO_IN_SEQ_START_RC         1
`define PIO_IN_RECONFIG_MGMT_BUSY   0


`define PIO_IN_TAP_TO_UPD_MAIN_TAP      6 
`define PIO_IN_TAP_TO_UPD_POST_TAP      5
`define PIO_IN_TAP_TO_UPD_PRE_TAP       4 



// PIO output bits
`define PIO_OUT_BASER_LL_MIF_DONE      0
`define PIO_OUT_HDSK_RC_BUSY_WR        1
`define PIO_OUT_RC_PMA_WR_MODE         2
`define PIO_OUT_RC_PMA_RD_MODE         3
`define PIO_OUT_RC_PMA_RD_DONE         4 
`define PIO_OUT_PMA_WRITE_DONE         5 
`define PIO_OUT_HDSK_RC_BUSY_RD        6 
`define PIO_OUT_KR_MMAP_RD_SEL         7 
`define PIO_OUT_KR_MMAP_WR_SEL         8 

   import mgmt_memory_map::*;
   import mgmt_functions_h::*;
   import alt_xcvr_reconfig_h::*;

     
   task mgmt_program;
      begin

f_label(`START);
	$display ("main ...\n");

         // start with ch0 selected  
         f_wait_for_pio_bit(`PIO_IN_RECONFIG_MGMT_BUSY,0); //wait for reconfig busy
	 // Clear test done flag
         f_write_pio_bit(`PIO_OUT_BASER_LL_MIF_DONE,0);
	 f_write_pio_bit(`PIO_OUT_RC_PMA_RD_DONE,0);

	 // set mmap to reconfig
	 f_write_pio_bit(`PIO_OUT_KR_MMAP_RD_SEL,0);

         //PMA Write for CH0 
	 f_read_pio_bit(`PIO_IN_LT_START_RC);
	 f_compare_result(1'b1);
	 f_jump_not_equal_zero(`START_PMA_WRITE);

         //10GBASE-R and 10GBASE-R low latency MIF streams for CH0
	 f_read_pio_bit(`PIO_IN_SEQ_START_RC);
	 f_compare_result(1'b1);
	 f_jump_not_equal_zero(`START_MIF);


	 f_write_pio_bit(`PIO_OUT_HDSK_RC_BUSY_WR,0);
	 f_load_result(1);
	 f_jump_not_equal_zero(`START);
	 
f_label(`START_MIF);
        $display ("MIF waiting ...\n");
         
	 // verify write
        f_write_pio_bit(`PIO_OUT_PMA_WRITE_DONE,0);

        f_wait_for_pio_bit(`PIO_IN_RECONFIG_MGMT_BUSY,0); //wait for reconfig busy
        $display("Detected rx_ready assertion");
        
        f_sleep(100);

	// hdshk_busy  
        f_write_pio_bit(`PIO_OUT_HDSK_RC_BUSY_WR,1);
	f_write_pio_bit(`PIO_OUT_HDSK_RC_BUSY_RD,1);
	 
	 $display ("Set Up MIF1 Streamer with MIF address 8000h\n");
  
        f_write_reg(LOCAL_ADDR_XR_MIF_LCH, 32'd0); 
        //Ctrl write to mif_mode = 00b
        f_write_reg(LOCAL_ADDR_XR_MIF_STATUS,32'd0);
        //Set up Offset to internal reg 0
        f_write_reg(LOCAL_ADDR_XR_MIF_OFFSET,32'h0);
        //Set up Data internal reg 0
        f_write_reg(LOCAL_ADDR_XR_MIF_DATA,32'h8000);
        //Ctrl write to internal reg 0,  to mif_mode = 00b
        f_write_reg(LOCAL_ADDR_XR_MIF_STATUS,32'd1); 
 
        f_sleep(10);

        //wait for busy to clear
        f_wait_for_reg(LOCAL_ADDR_XR_MIF_STATUS,32'h0);    

        $display ("Start MIF Streamer ...\n");
        //Set up Offset to internal reg 0
        f_write_reg(LOCAL_ADDR_XR_MIF_OFFSET,32'h1);
        //Set up Data internal reg 0
        f_write_reg(LOCAL_ADDR_XR_MIF_DATA,32'h1);
        //Ctrl write to internal reg 0,  to mif_mode = 00b
        f_write_reg(LOCAL_ADDR_XR_MIF_STATUS,32'd1);

        f_sleep(10);

        //wait for busy to clear
        f_wait_for_reg(LOCAL_ADDR_XR_MIF_STATUS,32'h0); 
        $display ("MIF Stream Done ...\n");

 
        f_sleep(10);
	
	// set the mif_done done bit  
	f_write_pio_bit(`PIO_OUT_BASER_LL_MIF_DONE,1);
        f_sleep(5);
	f_write_pio_bit(`PIO_OUT_BASER_LL_MIF_DONE,0);

	// make sure request 
        f_wait_for_pio_bit(`PIO_IN_SEQ_START_RC,0);
	
	// hdshk_busy 
	f_write_pio_bit(`PIO_OUT_HDSK_RC_BUSY_WR,0);
	f_write_pio_bit(`PIO_OUT_HDSK_RC_BUSY_RD,0);
 

	// Goto START and wait
        f_load_result(1);
	f_jump_not_equal_zero(`START);

f_label(`END_MIF);

        
f_label(`START_PMA_WRITE);
	 // hdshk_busy
	 f_write_pio_bit(`PIO_OUT_HDSK_RC_BUSY_WR,1);

	 // verify write
	 f_write_pio_bit(`PIO_OUT_PMA_WRITE_DONE,0);
	 f_wait_for_pio_bit(`PIO_IN_RECONFIG_MGMT_BUSY,0);
	 f_write_pio_bit(`PIO_OUT_KR_MMAP_RD_SEL,1);

         f_label(`CHECK_VOD_UPDATE);                              
	 // jump past VOD write if it does not need to be updated
	 f_read_pio_bit(`PIO_IN_TAP_TO_UPD_MAIN_TAP);            
	 f_compare_result(1'b0);                                 
	 f_jump_not_equal_zero(`CHECK_POST_TAP_UPDATE);          

	 
	 // VOD
	 f_write_reg(ADDR_XR_ANALOG_LCH, 0); // address 0
	 f_write_reg(ADDR_XR_ANALOG_OFFSET, 0); // Write offset for VOD (which is 0 as offset for vod is 0) at logical_ch_register = address 3
	 //f_write_pio_bit(`PIO_OUT_KR_MMAP_RD_SEL,1);
	 f_read_reg(0);
	 f_write_result_to_reg(ADDR_XR_ANALOG_DATA);
	 //f_write_pio_bit(`PIO_OUT_KR_MMAP_RD_SEL,0);
	 f_write_reg(ADDR_XR_ANALOG_STATUS, 1); // enable wr bit in control register, start write operation by writing 1 in control register = address 2

	 f_sleep(1);

	 // wait for busy to go low
	 f_wait_for_pio_bit(`PIO_IN_RECONFIG_MGMT_BUSY,0);

	 
	 f_label(`CHECK_POST_TAP_UPDATE);                             
	 // jump past POSTTAP write if it does not need to be updated 
	 f_read_pio_bit(`PIO_IN_TAP_TO_UPD_POST_TAP);                 
	 f_compare_result(1'b0);                                      
	 f_jump_not_equal_zero(`CHECK_PRE_TAP_UPDATE);	              

	 
	 // POSTTAP1
	 f_write_reg(ADDR_XR_ANALOG_OFFSET, 2); // Write offset for VOD (which is 0 as offset for vod is 0) at logical_ch_register = address 3
	 //f_write_pio_bit(`PIO_OUT_KR_MMAP_RD_SEL,1);
	 f_read_reg(1);
	 f_write_result_to_reg(ADDR_XR_ANALOG_DATA);
	 //f_write_pio_bit(`PIO_OUT_KR_MMAP_RD_SEL,0);
	 f_write_reg(ADDR_XR_ANALOG_STATUS, 1); // enable wr bit in control register, start write operation by writing 1 in control register = address 2

	 f_sleep(1);

	 // wait for busy to go low
	 f_wait_for_pio_bit(`PIO_IN_RECONFIG_MGMT_BUSY,0);
	 

	 f_label(`CHECK_PRE_TAP_UPDATE);                              
	  // jump past PRETAP1 write if it does not need to be updated
	 f_read_pio_bit(`PIO_IN_TAP_TO_UPD_PRE_TAP);                  
	 f_compare_result(1'b0);                                      
	 f_jump_not_equal_zero(`VOD_PRETAP_POSTTAP_WRITE_DONE);       

	 
	 // PRETAP1
	 f_write_reg(ADDR_XR_ANALOG_OFFSET, 1); // Write offset for VOD (which is 0 as offset for vod is 0) at logical_ch_register = address 3
	 //f_write_pio_bit(`PIO_OUT_KR_MMAP_RD_SEL,1);
	 f_read_reg(2);
	 f_write_result_to_reg(ADDR_XR_ANALOG_DATA);
	 //f_write_pio_bit(`PIO_OUT_KR_MMAP_RD_SEL,0);
	 f_write_reg(ADDR_XR_ANALOG_STATUS, 1); // enable wr bit in control register, start write operation by writing 1 in control register = address 2

	 f_sleep(1);

	 // wait for busy to go low
	 f_wait_for_pio_bit(`PIO_IN_RECONFIG_MGMT_BUSY,0);


	 f_label(`VOD_PRETAP_POSTTAP_WRITE_DONE);     
	 //f_write_pio_bit(`PIO_OUT_KR_MMAP_RD_SEL,0);

	 // set flags
	 // hdshk_busy 
	 f_write_pio_bit(`PIO_OUT_PMA_WRITE_DONE,1);

         //Verify read after write for CH0	 
 	 f_read_pio_bit(`PIO_IN_VERIFY_PMA_WRITE);
  	 f_compare_result(1'b1);
  	 f_jump_not_equal_zero(`START_PMA_READ);

	 f_write_pio_bit(`PIO_OUT_HDSK_RC_BUSY_WR,0);
	 // Goto START and wait
         f_load_result(1);
	 f_jump_not_equal_zero(`START);

f_label(`END_PMA_WRITE);	  


f_label(`START_PMA_READ);
	 // hdshk_busy
	 f_write_pio_bit(`PIO_OUT_HDSK_RC_BUSY_RD,1);
	 // clear done flags
	 f_write_pio_bit(`PIO_OUT_RC_PMA_RD_DONE,0);
	 f_wait_for_pio_bit(`PIO_IN_RECONFIG_MGMT_BUSY,0);	 

	 // read vod
	 f_write_reg(ADDR_XR_ANALOG_LCH, 0); // address 0
	 f_write_reg(ADDR_XR_ANALOG_OFFSET, 0); // Write offset for VOD (which is 0 as offset for vod is 0) at logical_ch_register = address 3
	 f_write_reg(ADDR_XR_ANALOG_STATUS, 2); // enable wr bit in control register, start write operation by writing 1 in control register = address 2
	 // wait for busy to go low
	 f_wait_for_pio_bit(`PIO_IN_RECONFIG_MGMT_BUSY,0);
	 f_sleep(20);
	 // write to the internal memory map
	 f_write_pio_bit(`PIO_OUT_KR_MMAP_WR_SEL,1);
	 f_read_reg(ADDR_XR_ANALOG_DATA);
	 f_write_result_to_reg(3);
	 f_write_pio_bit(`PIO_OUT_KR_MMAP_WR_SEL,0);
	 


	 // read postap1
	 f_wait_for_pio_bit(`PIO_IN_RECONFIG_MGMT_BUSY,0);	 
	 f_write_reg(ADDR_XR_ANALOG_OFFSET, 1); // Write offset for VOD (which is 0 as offset for vod is 0) at logical_ch_register = address 3
	 f_write_reg(ADDR_XR_ANALOG_STATUS, 2); // enable wr bit in control register, start write operation by writing 1 in control register = address 2
	 // wait for busy to go low
	 f_wait_for_pio_bit(`PIO_IN_RECONFIG_MGMT_BUSY,0);
	 f_sleep(20);
	 // write to the internal memory map
	 f_write_pio_bit(`PIO_OUT_KR_MMAP_WR_SEL,1);
	 f_read_reg(ADDR_XR_ANALOG_DATA);
	 f_write_result_to_reg(4);
	 f_write_pio_bit(`PIO_OUT_KR_MMAP_WR_SEL,0);
	 

	 // read pretap1
	 f_wait_for_pio_bit(0,0);	 
	 f_write_reg(ADDR_XR_ANALOG_OFFSET, 2); // Write offset for VOD (which is 0 as offset for vod is 0) at logical_ch_register = address 3
	 f_write_reg(ADDR_XR_ANALOG_STATUS, 2); // enable wr bit in control register, start write operation by writing 1 in control register = address 2
	 // wait for busy to go low
	 f_wait_for_pio_bit(`PIO_IN_RECONFIG_MGMT_BUSY,0);
	 f_sleep(20);
	 // write to the internal memory map
	 f_write_pio_bit(`PIO_OUT_KR_MMAP_WR_SEL,1);
	 f_read_reg(ADDR_XR_ANALOG_DATA);
	 f_write_result_to_reg(5);
	 f_write_pio_bit(`PIO_OUT_KR_MMAP_WR_SEL,0);
	 
	 
	 // set flags
	 f_wait_for_pio_bit(`PIO_IN_RECONFIG_MGMT_BUSY,0);

	 f_write_pio_bit(`PIO_OUT_RC_PMA_RD_DONE,1);
	 f_write_pio_bit(`PIO_OUT_PMA_WRITE_DONE,0);
	 f_write_pio_bit(`PIO_OUT_HDSK_RC_BUSY_RD,0);
	 f_write_pio_bit(`PIO_OUT_RC_PMA_RD_DONE,1);
	
	 
	 // Goto START and wait
         f_load_result(1);
	 f_jump_not_equal_zero(`START);

f_label(`END_PMA_READ);	  

	 
f_label(`END);
	 
      end
   endtask

endpackage

