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
    This is a simple example of an AXI4 Slave to demonstrate the mgc_axi4_slave BFM usage. 

    This is a fairly generic slave which handles almost all write and read transaction
    scenarios from master. It handles write data with address as well as data after address
    both.

    This slave code is divided in two parts, one which user might need to edit to change slave
    mode (Transaction/burst or Phase level) and memory handling.
*/


import mgc_axi4_pkg::*;

module slave_test_program #(int AXI4_ADDRESS_WIDTH = 32, int AXI4_RDATA_WIDTH = 1024, int AXI4_WDATA_WIDTH = 1024, int AXI4_ID_WIDTH = 18, int AXI4_USER_WIDTH = 8, int AXI4_REGION_MAP_SIZE = 16)
(
    mgc_axi4_slave bfm
);

  typedef bit [((AXI4_ADDRESS_WIDTH) - 1) : 0] addr_t;

  // Enum type for slave mode
  // AXI4_TRANSACTION_SLAVE - Works at burst level (write data is received at
  //                          burst and read data/response is sent in burst)
  // AXI4_PHASE_SLAVE       - Write data and read data/response is worked upon
  //                          at phase level
  typedef enum bit
  {
    AXI4_TRANSACTION_SLAVE = 1'b0,
    AXI4_PHASE_SLAVE       = 1'b1
  } axi4_slave_mode_e;

  // Enum type for slave ready delay mode
  // AXI4_VALID2READY - Ready delay for a phase will be applied from
  //                    start of phase (Means from when VALID is asserted).
  // AXI4_TRANS2READY - Ready delay will be applied from the end of
  //                    previous phase. This might result in ready before valid.
  typedef enum bit
  {
    AXI4_VALID2READY = 1'b0,
    AXI4_TRANS2READY = 1'b1
  } axi4_slave_ready_delay_mode_e;

  /////////////////////////////////////////////////
  // Code user could edit according to requirements
  /////////////////////////////////////////////////

  // Slave max outstanding reads
  int m_max_outstanding_read_trans = 2;

  // Slave max outstanding writes
  int m_max_outstanding_write_trans = 2;

  // Variable : m_wr_addr_phase_ready_delay
  int m_wr_addr_phase_ready_delay = 2;

  // Variable : m_rd_addr_phase_ready_delay
  int m_rd_addr_phase_ready_delay = 2;

  // Variable : m_wr_data_phase_ready_delay
  int m_wr_data_phase_ready_delay = 2;

  // Slave ready delay mode seclection : default it is VALID2READY
  axi4_slave_ready_delay_mode_e slave_ready_delay_mode = AXI4_VALID2READY;

  // Slave mode seclection : default it is transaction level slave
  axi4_slave_mode_e slave_mode = AXI4_TRANSACTION_SLAVE;

  // Storage for a memory
  bit [7:0] mem [*];

  // Function : do_byte_read
  // Function to provide read data byte from memory at particular input
  // address
  function bit[7:0] do_byte_read(addr_t addr);
    return mem[addr];
  endfunction

  // Function : do_byte_write
  // Function to write data byte to memory at particular input address
  function void do_byte_write(addr_t addr, bit [7:0] data);
    mem[addr] = data;
  endfunction

  // Function : set_wr_resp_valid_delay
  // This is used to set write response phase valid delay to start driving
  // write response phase after specified delay.
  function void set_wr_resp_valid_delay(axi4_transaction trans);
    trans.set_write_response_valid_delay(2);
  endfunction

  // Function : set_read_data_valid_delay
  // This is used to set read response phase valid delays to start driving
  // read data/response phases after specified delay.
  function void set_read_data_valid_delay(axi4_transaction trans);
    for (int i = 0; i < trans.data_valid_delay.size(); i++)
      trans.set_data_valid_delay(i, i);
  endfunction


  ///////////////////////////////////////////////////////////////////////
  // Code user do not need to edit
  // Please note that in this part of code base below valid delays are assigned
  // which user might need to change according to requirement
  // data_valid_delay    : This is for sending read data/response valid
  ///////////////////////////////////////////////////////////////////////
  initial
  begin
    // Initialisation
    bfm.set_config(AXI4_CONFIG_MAX_OUTSTANDING_RD,m_max_outstanding_read_trans);
    bfm.set_config(AXI4_CONFIG_MAX_OUTSTANDING_WR,m_max_outstanding_write_trans);
    bfm.wait_on(AXI4_RESET_0_TO_1);
    bfm.wait_on(AXI4_CLOCK_POSEDGE);

    // Traffic generation
    fork
      process_read;
      process_write;
      handle_write_addr_ready;
      handle_read_addr_ready;
      handle_write_data_ready;
    join
  end

  // Task : process_read
  // This method keep receiving read address phase and calls another method to
  // process received transaction.
  task process_read;
    forever
    begin
      axi4_transaction read_trans;
    
      read_trans = bfm.create_slave_transaction();
      bfm.get_read_addr_phase(read_trans);

      fork
        begin
          automatic axi4_transaction t = read_trans;
          handle_read(t);
        end
      join_none
      #0;
    end
  endtask

  // Task : handle_read
  // This method reads data from memory and send read data/response either at
  // burst or phase level depending upon slave working mode.
  task automatic handle_read(input axi4_transaction read_trans);
    addr_t addr[];
    bit [7:0] mem_data[];
 
    set_read_data_valid_delay(read_trans); 

    for(int i = 0; bfm.get_read_addr(read_trans, i, addr); i++)
    begin
      mem_data = new[addr.size()];
      for (int j = 0; j < addr.size(); j++)
        mem_data[j] = do_byte_read(addr[j]);

      bfm.set_read_data(read_trans, i, addr, mem_data);

      if (slave_mode == AXI4_PHASE_SLAVE)
        bfm.execute_read_data_phase(read_trans, i);
    end

    if (slave_mode == AXI4_TRANSACTION_SLAVE)
      bfm.execute_read_data_burst(read_trans);
  endtask

  // Task : process_write
  // This method keep receiving write address phase and calls another method to
  // process received transaction.
  task process_write;
    forever
    begin
      axi4_transaction write_trans;
    
      write_trans = bfm.create_slave_transaction();
      bfm.get_write_addr_phase(write_trans);

      fork
        begin
          automatic axi4_transaction t = write_trans;
          handle_write(t);
        end
      join_none
      #0;
    end
  endtask

  // Task : handle_write
  // This method receive write data burst or phases for write transaction
  // depending upon slave working mode, write data to memory and then send
  // response
  task automatic handle_write(input axi4_transaction write_trans);
    addr_t addr[];
    bit [7:0] data[];
    bit last;

    if (slave_mode == AXI4_TRANSACTION_SLAVE)
    begin
      bfm.get_write_data_burst(write_trans);

      for( int i = 0; bfm.get_write_addr_data(write_trans, i, addr, data); i++ )
      begin
        for (int j = 0; j < addr.size(); j++)
          do_byte_write(addr[j], data[j]);
      end
    end
    else
    begin
      for(int i = 0; (last == 1'b0); i++)
      begin
        bfm.get_write_data_phase(write_trans, i, last);

        void'(bfm.get_write_addr_data(write_trans, i, addr, data));
        for (int j = 0; j < addr.size(); j++)
          do_byte_write(addr[j], data[j]);
      end
    end

    set_wr_resp_valid_delay(write_trans);
    bfm.execute_write_response_phase(write_trans);
  endtask

  // Task : handle_write_addr_ready
  // This method assert/de-assert the write address channel ready signal.
  // Assertion and de-assertion is done based on m_wr_addr_phase_ready_delay
  task automatic handle_write_addr_ready;
    bit seen_valid_ready;

    int tmp_ready_delay;
    int tmp_config_num_outstanding_wr_phase;
    axi4_slave_ready_delay_mode_e tmp_mode;

    forever
    begin
      tmp_config_num_outstanding_wr_phase = bfm.get_config(AXI4_CONFIG_NUM_OUTSTANDING_WR_PHASE);

      while ((tmp_config_num_outstanding_wr_phase >= m_max_outstanding_write_trans) && (m_max_outstanding_write_trans > 0))
      begin
        bfm.wait_on(AXI4_CLOCK_POSEDGE);
        tmp_config_num_outstanding_wr_phase = bfm.get_config(AXI4_CONFIG_NUM_OUTSTANDING_WR_PHASE);
      end

      wait(m_wr_addr_phase_ready_delay > 0);
      tmp_ready_delay = m_wr_addr_phase_ready_delay;
      tmp_mode        = slave_ready_delay_mode;

      if (tmp_mode == AXI4_VALID2READY)
      begin
        fork
          bfm.execute_write_addr_ready(1'b0);
        join_none

        bfm.get_write_addr_cycle;
        repeat(tmp_ready_delay - 1) bfm.wait_on(AXI4_CLOCK_POSEDGE);
  
        bfm.execute_write_addr_ready(1'b1);
        seen_valid_ready = 1'b1;
      end
      else  // AXI4_TRANS2READY
      begin
        if (seen_valid_ready == 1'b0)
        begin
          do
            bfm.wait_on(AXI4_CLOCK_POSEDGE);
          while (!((bfm.AWVALID === 1'b1) && (bfm.AWREADY === 1'b1)));
        end

        fork
          bfm.execute_write_addr_ready(1'b0);
        join_none

        repeat(tmp_ready_delay) bfm.wait_on(AXI4_CLOCK_POSEDGE);

        fork
          bfm.execute_write_addr_ready(1'b1);
        join_none
        seen_valid_ready = 1'b0;
      end
    end
  endtask

  // Task : handle_read_addr_ready
  // This method assert/de-assert the read address channel ready signal.
  // Assertion and de-assertion is done based on following variable's value:
  // m_rd_addr_phase_ready_delay
  // slave_ready_delay_mode
  task automatic handle_read_addr_ready;
    bit seen_valid_ready;

    int tmp_ready_delay;
    int tmp_config_num_outstanding_rd_phase;
    axi4_slave_ready_delay_mode_e tmp_mode;

    forever
    begin
      tmp_config_num_outstanding_rd_phase = bfm.get_config(AXI4_CONFIG_NUM_OUTSTANDING_RD_PHASE);

      while ((tmp_config_num_outstanding_rd_phase >= m_max_outstanding_read_trans) && (m_max_outstanding_read_trans > 0))
      begin
        bfm.wait_on(AXI4_CLOCK_POSEDGE);
        tmp_config_num_outstanding_rd_phase = bfm.get_config(AXI4_CONFIG_NUM_OUTSTANDING_RD_PHASE);
      end
      wait(m_rd_addr_phase_ready_delay > 0);
      tmp_ready_delay = m_rd_addr_phase_ready_delay;
      tmp_mode        = slave_ready_delay_mode;

      if (tmp_mode == AXI4_VALID2READY)
      begin
        fork
          bfm.execute_read_addr_ready(1'b0);
        join_none

        bfm.get_read_addr_cycle;
        repeat(tmp_ready_delay - 1) bfm.wait_on(AXI4_CLOCK_POSEDGE);
  
        bfm.execute_read_addr_ready(1'b1);
        seen_valid_ready = 1'b1;
      end
      else  // AXI4_TRANS2READY
      begin
        if (seen_valid_ready == 1'b0)
        begin
          do
            bfm.wait_on(AXI4_CLOCK_POSEDGE);
          while (!((bfm.ARVALID === 1'b1) && (bfm.ARREADY === 1'b1)));
        end

        fork
          bfm.execute_read_addr_ready(1'b0);
        join_none

        repeat(tmp_ready_delay) bfm.wait_on(AXI4_CLOCK_POSEDGE);

        fork
          bfm.execute_read_addr_ready(1'b1);
        join_none
        seen_valid_ready = 1'b0;
      end
    end
  endtask

  // Task : handle_write_data_ready
  // This method assert/de-assert the write data channel ready signal.
  // Assertion and de-assertion is done based on following variable's value:
  // m_wr_data_phase_ready_delay
  // slave_ready_delay_mode
  task automatic handle_write_data_ready;
    bit seen_valid_ready;

    int tmp_ready_delay;
    axi4_slave_ready_delay_mode_e tmp_mode;

    forever
    begin
      wait(m_wr_data_phase_ready_delay > 0);
      tmp_ready_delay = m_wr_data_phase_ready_delay;
      tmp_mode        = slave_ready_delay_mode;

      if (tmp_mode == AXI4_VALID2READY)
      begin
        fork
          bfm.execute_write_data_ready(1'b0);
        join_none

        bfm.get_write_data_cycle;
        repeat(tmp_ready_delay - 1) bfm.wait_on(AXI4_CLOCK_POSEDGE);
  
        bfm.execute_write_data_ready(1'b1);
        seen_valid_ready = 1'b1;
      end
      else  // AXI4_TRANS2READY
      begin
        if (seen_valid_ready == 1'b0)
        begin
          do
            bfm.wait_on(AXI4_CLOCK_POSEDGE);
          while (!((bfm.WVALID === 1'b1) && (bfm.WREADY === 1'b1)));
        end

        fork
          bfm.execute_write_data_ready(1'b0);
        join_none

        repeat(tmp_ready_delay) bfm.wait_on(AXI4_CLOCK_POSEDGE);

        fork
          bfm.execute_write_data_ready(1'b1);
        join_none
        seen_valid_ready = 1'b0;
      end
    end
  endtask

endmodule

