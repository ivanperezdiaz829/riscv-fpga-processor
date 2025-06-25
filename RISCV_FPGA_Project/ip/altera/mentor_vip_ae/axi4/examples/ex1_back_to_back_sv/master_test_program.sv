// *****************************************************************************
//
// Copyright 2007-2013 Mentor Graphics Corporation
// All Rights Reserved.
//
// THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF
// MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
//
// *****************************************************************************

/* 
    This is a simple example of an AXI4 master to demonstrate the mgc_axi4_master BFM usage. 

    This master performs a directed test, initiating 4 sequential writes, followed by 4 sequential reads. It then verifies that the data read out matches the data written.
    For the sake of simplicity, only one data cycle is used (default AXI4 burst length encoding 0).

    It then initiates two write data bursts followed by two read data bursts.

    It then initiates 4 outstanding writes, followed by 4 reads. It then verifies that the data read out matches the data written.
*/

import mgc_axi4_pkg::*;
module master_test_program #(int AXI4_ADDRESS_WIDTH = 32, int AXI4_RDATA_WIDTH = 1024, int AXI4_WDATA_WIDTH = 1024, int AXI4_ID_WIDTH = 18, int AXI4_USER_WIDTH = 8, int AXI4_REGION_MAP_SIZE = 16)
(
    mgc_axi4_master bfm
);

  // Enum type for master ready delay mode
  // AXI4_VALID2READY - Ready delay for a phase will be applied from
  //                    start of phase (Means from when VALID is asserted).
  // AXI4_TRANS2READY - Ready delay will be applied from the end of
  //                    previous phase. This might result in ready before valid.
  typedef enum bit
  {
    AXI4_VALID2READY = 1'b0,
    AXI4_TRANS2READY = 1'b1
  } axi4_master_ready_delay_mode_e;

  /////////////////////////////////////////////////
  // Code user could edit according to requirements
  /////////////////////////////////////////////////

  // Variable : m_wr_resp_phase_ready_delay
  int m_wr_resp_phase_ready_delay = 2;

  // Variable : m_rd_data_phase_ready_delay
  int m_rd_data_phase_ready_delay = 2;

  // Master ready delay mode seclection : default it is VALID2READY
  axi4_master_ready_delay_mode_e master_ready_delay_mode = AXI4_VALID2READY;

initial
begin
    axi4_transaction trans, trans1, trans2, trans3, trans4, trans5, trans6, trans7, trans8;

    /*******************
    ** Initialisation **
    *******************/
    bfm.wait_on(AXI4_RESET_0_TO_1);
    bfm.wait_on(AXI4_CLOCK_POSEDGE);

    /*******************
    ** **
    *******************/
    fork
      handle_write_resp_ready;
      handle_read_data_ready;
    join_none

    /************************
    ** Traffic generation: **
    ************************/    
    // 4 x Writes
    // Write data value 1 on byte lanes 1 to address 1.
    trans = bfm.create_write_transaction(1);
    trans.set_data_words(32'h0000_0100, 0);
    trans.set_write_strobes(4'b0010, 0);
    $display ( "@ %t, master_test_program: Writing data (1) to address (1)", $time);    

    // By default it will run in Blocking mode 
    bfm.execute_transaction(trans); 
    
    // Write data value 2 on byte lane 2 to address 2.
    trans = bfm.create_write_transaction(2);
    trans.set_data_words(32'h0002_0000, 0);
    trans.set_write_strobes(4'b0100, 0);
    trans.set_write_data_mode(AXI4_DATA_WITH_ADDRESS);
    $display ( "@ %t, master_test_program: Writing data (2) to address (2)", $time);        

    bfm.execute_transaction(trans);

    // Write data value 3 on byte lane 3 to address 3.
    trans = bfm.create_write_transaction(3);
    trans.set_data_words(32'h0300_0000, 0);
    trans.set_write_strobes(4'b1000, 0);
    $display ( "@ %t, master_test_program: Writing data (3) to address (3)", $time);        

    bfm.execute_transaction(trans);
    
    // Write data value 4 to address 4 on byte lane 0.
    trans = bfm.create_write_transaction(4);
    trans.set_data_words(32'h0000_0004, 0);
    trans.set_write_strobes(4'b0001, 0);
    trans.set_write_data_mode(AXI4_DATA_WITH_ADDRESS);
    $display ( "@ %t, master_test_program: Writing data (4) to address (4)", $time);        

    bfm.execute_transaction(trans);

    // 4 x Reads
    // Read data from address 1.
    trans = bfm.create_read_transaction(1);
    trans.set_size(AXI4_BYTES_1);
    trans.set_id(1);

    bfm.execute_transaction(trans);
    if (trans.get_data_words(0) == 32'h0000_0100)
        $display ( "@ %t, master_test_program: Read correct data (1) at address (1)", $time);
    else
        $display ( "@ %t master_test_program: Error: Expected data (1) at address 1, but got %d", $time, trans.get_data_words(0));

    // Read data from address 2. 
    trans = bfm.create_read_transaction(2);
    trans.set_size(AXI4_BYTES_1);
    trans.set_id(2);

    bfm.execute_transaction(trans);
    if (trans.get_data_words(0) == 32'h0002_0000)
        $display ( "@ %t, master_test_program: Read correct data (2) at address (2)", $time);
    else
        $display ( "@ %t, master_test_program: Error: Expected data (2) at address 2, but got %d", $time, trans.get_data_words(0));
    
    // Read data from address 3.
    trans = bfm.create_read_transaction(3);
    trans.set_size(AXI4_BYTES_1);
    trans.set_id(3);

    bfm.execute_transaction(trans);
    if (trans.get_data_words(0) == 32'h0300_0000)
      $display ( "@ %t, master_test_program: Read correct data (3) at address (3)", $time);
    else
        $display ( "@ %t, master_test_program: Error: Expected data (3) at address 3, but got %d", $time, trans.get_data_words(0));

    // Read data from address 4.
    trans = bfm.create_read_transaction(4);
    trans.set_size(AXI4_BYTES_1);
    trans.set_id(4);

    bfm.execute_transaction(trans);
    if (trans.get_data_words(0) == 32'h0000_0004)
        $display ( "@ %t, master_test_program: Read correct data (4) at address (4)", $time);
    else
        $display ( "@ %t, master_test_program: Error: Expected data (4) at address 4, but got %d", $time, trans.get_data_words(0));

    // Write data burst length of 7 to start address 16.
    trans = bfm.create_write_transaction(16, 7);

    trans.set_size(AXI4_BYTES_4);
    trans.set_data_words('hACE0ACE1, 0);
    trans.set_data_words('hACE2ACE3, 1);
    trans.set_data_words('hACE4ACE5, 2);
    trans.set_data_words('hACE6ACE7, 3);
    trans.set_data_words('hACE8ACE9, 4);
    trans.set_data_words('hACEAACEB, 5);
    trans.set_data_words('hACECACED, 6);
    trans.set_data_words('hACEEACEF, 7);
    for(int i=0; i<8; i++)
        trans.set_write_strobes(4'b1111, i);

    trans.set_write_data_mode(AXI4_DATA_WITH_ADDRESS);
    $display ( "@ %t, master_test_program: Writing data burst of length 7 to start address 16", $time);    
    
    bfm.execute_transaction(trans); 

    // Write data burst of length 7 to start address 128 with LSB write strobe inactive.
    trans = bfm.create_write_transaction(128, 7);

    trans.set_data_words('hACE0ACE1, 0);
    trans.set_data_words('hACE2ACE3, 1);
    trans.set_data_words('hACE4ACE5, 2);
    trans.set_data_words('hACE6ACE7, 3);
    trans.set_data_words('hACE8ACE9, 4);
    trans.set_data_words('hACEAACEB, 5);
    trans.set_data_words('hACECACED, 6);
    trans.set_data_words('hACEEACEF, 7);

    trans.set_write_strobes(4'b1110, 0);
    for(int i=1; i<8; i++)
        trans.set_write_strobes(4'b1111, i);
    $display ( "@ %t, master_test_program: Writing data burst of length 7 to start address 128", $time);    
    
    bfm.execute_transaction(trans); 

    // Read data burst of length 1 from address 16.
    trans = bfm.create_read_transaction(16, 1);

    bfm.execute_transaction(trans);
    if (trans.get_data_words(0) == 'hACE0ACE1)
      $display ( "@ %t, master_test_program: Read correct data (hACE0ACE1) at address (16)", $time);
    else
      $display ( "@ %t, master_test_program: Error: Expected data (hACE0ACE1) at address (16), but got %h", $time, trans.get_data_words(0));

    if (trans.get_data_words(1) == 'hACE2ACE3)
      $display ( "@ %t, master_test_program: Read correct data (hACE2ACE3) at address (20)", $time);
    else
      $display ( "@ %t, master_test_program: Error: Expected data (hACE2ACE3) at address (20), but got %h", $time, trans.get_data_words(1));
    

    // Read data burst of length 1 from address 128.
    trans = bfm.create_read_transaction(128, 1);

    bfm.execute_transaction(trans);
    if (trans.get_data_words(0) == 'hACE0AC00)
      $display ( "@ %t, master_test_program: Read correct data (hACE0AC00) at address (128)", $time);
    else
      $display ( "@ %t, master_test_program: Error: Expected data (hACE0AC00) at address (128), but got %h", $time, trans.get_data_words(0));

    if (trans.get_data_words(1) == 'hACE2ACE3)
      $display ( "@ %t, master_test_program: Read correct data (hACE2ACE3) at address (132)", $time);
    else
      $display ( "@ %t, master_test_program: Error: Expected data (hACE2ACE3) at address (132), but got %h", $time, trans.get_data_words(1));


    /************************************
    ** Outstanding Traffic generation: **
    ************************************/

    repeat(10)
    bfm.wait_on(AXI4_CLOCK_POSEDGE);

    // 4 x Writes
    // Write data value to address 0.
    trans1 = bfm.create_write_transaction(0,3);
    trans1.set_data_words('hACE0ACE1, 0);
    trans1.set_data_words('hACE2ACE3, 1);
    trans1.set_data_words('hACE4ACE5, 2);
    trans1.set_data_words('hACE6ACE7, 3);
    for(int i=0; i<4; i++)
        trans1.set_write_strobes(4'b1111, i);
    $display ( "@ %t, master_test_program: Writing data (1) to address (0)", $time);    

    fork 
      bfm.execute_write_addr_phase(trans1);
      bfm.execute_write_data_burst(trans1);
    join_any
 
    // Write data value to address 16.
    trans2 = bfm.create_write_transaction(16,2);
    trans2.set_data_words('hACE0ACE1, 0);
    trans2.set_data_words('hACE2ACE3, 1);
    trans2.set_data_words('hACE4ACE5, 2);
    for(int i=0; i<3; i++)
        trans2.set_write_strobes(4'b1111, i);
    $display ( "@ %t, master_test_program: Writing data (2) to address (16)", $time);        

    fork
      bfm.execute_write_addr_phase(trans2);
      bfm.execute_write_data_burst(trans2);
    join_any

    // Write data value to address 32.
    trans3 = bfm.create_write_transaction(32,4);
    trans3.set_data_words('hACE0ACE1, 0);
    trans3.set_data_words('hACE2ACE3, 1);
    trans3.set_data_words('hACE4ACE5, 2);
    trans3.set_data_words('hACE6ACE7, 3);
    trans3.set_data_words('hACE8ACE9, 4);
    for(int i=0; i<5; i++)
        trans3.set_write_strobes(4'b1111, i);
    $display ( "@ %t, master_test_program: Writing data (3) to address (32)", $time);        

    fork
      bfm.execute_write_addr_phase(trans3);
      bfm.execute_write_data_burst(trans3);
    join_any

    // Write data value to address 64.
    trans4 = bfm.create_write_transaction(64,5);
    trans4.set_data_words('hACE0ACE1, 0);
    trans4.set_data_words('hACE2ACE3, 1);
    trans4.set_data_words('hACE4ACE5, 2);
    trans4.set_data_words('hACE6ACE7, 3);
    trans4.set_data_words('hACE8ACE9, 4);
    trans4.set_data_words('hACEAACEB, 5);
    for(int i=0; i<6; i++)
        trans4.set_write_strobes(4'b1111, i);
    $display ( "@ %t, master_test_program: Writing data (4) to address (64)", $time);        

    fork
      bfm.execute_write_addr_phase(trans4);
      bfm.execute_write_data_burst(trans4);
    join_any

    repeat(50)
    bfm.wait_on(AXI4_CLOCK_POSEDGE);

    // 4 x Reads
    // Read data from address 0.
    trans5 = bfm.create_read_transaction(0,3);
    trans5.set_id(1);

    bfm.execute_transaction(trans5);
    if (trans5.get_data_words(0) == 'hACE0ACE1)
      $display ( "@ %t, master_test_program: Read correct data (hACE0ACE1) at address (0)", $time);
    else
      $display ( "@ %t, master_test_program: Error: Expected data (hACE0ACE1) at address (0), but got %h", $time, trans5.get_data_words(0));

    if (trans5.get_data_words(1) == 'hACE2ACE3)
      $display ( "@ %t, master_test_program: Read correct data (hACE2ACE3) at address (4)", $time);
    else
      $display ( "@ %t, master_test_program: Error: Expected data (hACE2ACE3) at address (4), but got %h", $time, trans5.get_data_words(1));

    if (trans5.get_data_words(2) == 'hACE4ACE5)
      $display ( "@ %t, master_test_program: Read correct data (hACE4ACE5) at address (8)", $time);
    else
      $display ( "@ %t, master_test_program: Error: Expected data (hACE4ACE5) at address (8), but got %h", $time, trans5.get_data_words(2));

    // Read data from address 16. 
    trans6 = bfm.create_read_transaction(16,2);
    trans6.set_id(2);

    bfm.execute_transaction(trans6);
    if (trans6.get_data_words(0) == 'hACE0ACE1)
      $display ( "@ %t, master_test_program: Read correct data (hACE0ACE1) at address (16)", $time);
    else
      $display ( "@ %t, master_test_program: Error: Expected data (hACE0ACE1) at address (16), but got %h", $time, trans6.get_data_words(0));

    if (trans6.get_data_words(1) == 'hACE2ACE3)
      $display ( "@ %t, master_test_program: Read correct data (hACE2ACE3) at address (20)", $time);
    else
      $display ( "@ %t, master_test_program: Error: Expected data (hACE2ACE3) at address (20), but got %h", $time, trans6.get_data_words(1));

    if (trans6.get_data_words(2) == 'hACE4ACE5)
      $display ( "@ %t, master_test_program: Read correct data (hACE4ACE5) at address (24)", $time);
    else
      $display ( "@ %t, master_test_program: Error: Expected data (hACE4ACE5) at address (24), but got %h", $time, trans6.get_data_words(2));
    
    // Read data from address 32.
    trans7 = bfm.create_read_transaction(32,4);
    trans7.set_id(3);

    bfm.execute_transaction(trans7);
    if (trans7.get_data_words(0) == 'hACE0ACE1)
      $display ( "@ %t, master_test_program: Read correct data (hACE0ACE1) at address (32)", $time);
    else
      $display ( "@ %t, master_test_program: Error: Expected data (hACE0ACE1) at address (32), but got %h", $time, trans7.get_data_words(0));

    if (trans7.get_data_words(1) == 'hACE2ACE3)
      $display ( "@ %t, master_test_program: Read correct data (hACE2ACE3) at address (36)", $time);
    else
      $display ( "@ %t, master_test_program: Error: Expected data (hACE2ACE3) at address (36), but got %h", $time, trans7.get_data_words(1));

    if (trans7.get_data_words(2) == 'hACE4ACE5)
      $display ( "@ %t, master_test_program: Read correct data (hACE4ACE5) at address (40)", $time);
    else
      $display ( "@ %t, master_test_program: Error: Expected data (hACE4ACE5) at address (40), but got %h", $time, trans7.get_data_words(2));

    // Read data from address 64.
    trans8 = bfm.create_read_transaction(64,5);
    trans8.set_id(4);

    bfm.execute_transaction(trans8);
    if (trans8.get_data_words(0) == 'hACE0ACE1)
      $display ( "@ %t, master_test_program: Read correct data (hACE0ACE1) at address (64)", $time);
    else
      $display ( "@ %t, master_test_program: Error: Expected data (hACE0ACE1) at address (64), but got %h", $time, trans8.get_data_words(0));

    if (trans8.get_data_words(1) == 'hACE2ACE3)
      $display ( "@ %t, master_test_program: Read correct data (hACE2ACE3) at address (68)", $time);
    else
      $display ( "@ %t, master_test_program: Error: Expected data (hACE2ACE3) at address (68), but got %h", $time, trans8.get_data_words(1));

    if (trans8.get_data_words(2) == 'hACE4ACE5)
      $display ( "@ %t, master_test_program: Read correct data (hACE4ACE5) at address (72)", $time);
    else
      $display ( "@ %t, master_test_program: Error: Expected data (hACE4ACE5) at address (72), but got %h", $time, trans8.get_data_words(2));

    #10000
    $finish();
end

  // Task : handle_write_resp_ready
  // This method assert/de-assert the write response channel ready signal.
  // Assertion and de-assertion is done based on following variable's value:
  // m_wr_resp_phase_ready_delay
  // master_ready_delay_mode
  task automatic handle_write_resp_ready;
    bit seen_valid_ready;

    int tmp_ready_delay;
    axi4_master_ready_delay_mode_e tmp_mode;

    forever
    begin
      wait(m_wr_resp_phase_ready_delay > 0);
      tmp_ready_delay = m_wr_resp_phase_ready_delay;
      tmp_mode        = master_ready_delay_mode;

      if (tmp_mode == AXI4_VALID2READY)
      begin
        fork
          bfm.execute_write_resp_ready(1'b0);
        join_none

        bfm.get_write_response_cycle;
        repeat(tmp_ready_delay - 1) bfm.wait_on(AXI4_CLOCK_POSEDGE);
  
        bfm.execute_write_resp_ready(1'b1);
        seen_valid_ready = 1'b1;
      end
      else  // AXI4_TRANS2READY
      begin
        if (seen_valid_ready == 1'b0)
        begin
          do
            bfm.wait_on(AXI4_CLOCK_POSEDGE);
          while (!((bfm.BVALID === 1'b1) && (bfm.BREADY === 1'b1)));
        end

        fork
          bfm.execute_write_resp_ready(1'b0);
        join_none

        repeat(tmp_ready_delay) bfm.wait_on(AXI4_CLOCK_POSEDGE);

        fork
          bfm.execute_write_resp_ready(1'b1);
        join_none
        seen_valid_ready = 1'b0;
      end
    end
  endtask

  // Task : handle_read_data_ready
  // This method assert/de-assert the read data/response channel ready signal.
  // Assertion and de-assertion is done based on following variable's value:
  // m_rd_data_phase_ready_delay
  // master_ready_delay_mode
  task automatic handle_read_data_ready;
    bit seen_valid_ready;

    int tmp_ready_delay;
    axi4_master_ready_delay_mode_e tmp_mode;

    forever
    begin
      wait(m_rd_data_phase_ready_delay > 0);
      tmp_ready_delay = m_rd_data_phase_ready_delay;
      tmp_mode        = master_ready_delay_mode;

      if (tmp_mode == AXI4_VALID2READY)
      begin
        fork
          bfm.execute_read_data_ready(1'b0);
        join_none

        bfm.get_read_data_cycle;
        repeat(tmp_ready_delay - 1) bfm.wait_on(AXI4_CLOCK_POSEDGE);
  
        bfm.execute_read_data_ready(1'b1);
        seen_valid_ready = 1'b1;
      end
      else  // AXI4_TRANS2READY
      begin
        if (seen_valid_ready == 1'b0)
        begin
          do
            bfm.wait_on(AXI4_CLOCK_POSEDGE);
          while (!((bfm.RVALID === 1'b1) && (bfm.RREADY === 1'b1)));
        end

        fork
          bfm.execute_read_data_ready(1'b0);
        join_none

        repeat(tmp_ready_delay) bfm.wait_on(AXI4_CLOCK_POSEDGE);

        fork
          bfm.execute_read_data_ready(1'b1);
        join_none
        seen_valid_ready = 1'b0;
      end
    end
  endtask

endmodule
