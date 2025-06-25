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
    This is a simple example of an AXI Slave to demonstrate the mgc_axi_slave BFM usage. 

    This is a fairly generic slave which handles almost all write and read transaction
    scenarios from master. It handles write data with address as well as data after address
    both. It handles outstanding read and write transactions.

    This slave code is divided in two parts, one which user might need to edit to change slave
    mode (Transaction/burst or Phase level) and memory handling.
    Out of the code which is grouped as user do not need to edit, could be edited for achieving
    required phase valid/ready delays.
*/

import mgc_axi_pkg::*;

module slave_test_program #(int AXI_ADDRESS_WIDTH = 32, int AXI_RDATA_WIDTH = 32, int AXI_WDATA_WIDTH = 32, int AXI_ID_WIDTH = 18)
(
    mgc_axi_slave bfm
);

  typedef bit [((AXI_ADDRESS_WIDTH) - 1) : 0] addr_t;

  // Enum type for slave mode
  // AXI_TRANSACTION_SLAVE - Works at burst level (write data is received at
  //                         burst and read data/response is sent in burst)
  // AXI_PHASE_SLAVE       - Write data and read data/response is worked upon
  //                         at phase level
  typedef enum bit
  {
    AXI_TRANSACTION_SLAVE = 1'b0,
    AXI_PHASE_SLAVE       = 1'b1
  } axi_slave_mode_e;

  /////////////////////////////////////////////////
  // Code user could edit according to requirements
  /////////////////////////////////////////////////

  // Slave mode seclection : default it is transaction level slave
  axi_slave_mode_e slave_mode = AXI_TRANSACTION_SLAVE;

  // Slave max outstanding reads
  int m_max_outstanding_read_trans = 2;

  // Slave max outstanding writes
  int m_max_outstanding_write_trans = 2; 

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

  // Function : set_write_address_ready_delay
  // This is used to set write address phase ready delay to extend phase
  function void set_write_address_ready_delay(axi_transaction trans);
    trans.set_address_ready_delay(1);
  endfunction

  // Function : set_read_address_ready_delay
  // This is used to set read address phase ready delay to entend phase
  function void set_read_address_ready_delay(axi_transaction trans);
    trans.set_address_ready_delay(1);
  endfunction

  // Function : set_write_data_ready_delay
  // This will set the ready delays for each write data phase in a write data
  // burst
  function void set_write_data_ready_delay(axi_transaction trans);
    for (int i = 0; i < trans.data_ready_delay.size(); i++)
      trans.set_data_ready_delay(i, i);
  endfunction

  // Function : set_wr_resp_valid_delay
  // This is used to set write response phase valid delay to start driving
  // write response phase after specified delay.
  function void set_wr_resp_valid_delay(axi_transaction trans);
    trans.set_write_response_valid_delay(2);
  endfunction

  // Function : set_read_data_valid_delay
  // This is used to set read response phase valid delays to start driving
  // read data/response phases after specified delay.
  function void set_read_data_valid_delay(axi_transaction trans);
    for (int i = 0; i < trans.data_valid_delay.size(); i++)
      trans.set_data_valid_delay(i, i);
  endfunction

  ///////////////////////////////////////////////////////////////////////
  // Code user do not need to edit
  // Please note that in this part of code base below delays are assigned
  // which user might need to change according to requirement
  // address_ready_delay : This is for write and read address phase both
  // data_valid_delay    : This is for sending read data/response valid
  // data_ready_delay    : This is for write data phase ready delay
  ///////////////////////////////////////////////////////////////////////
  initial
  begin
    // Initialisation
    bfm.set_config(AXI_CONFIG_MAX_OUTSTANDING_RD,m_max_outstanding_read_trans);
    bfm.set_config(AXI_CONFIG_MAX_OUTSTANDING_WR,m_max_outstanding_write_trans);
    bfm.wait_on(AXI_RESET_0_TO_1);
    bfm.wait_on(AXI_CLOCK_POSEDGE); 
    // Traffic generation
    fork
      process_read;
      process_write;
    join
  end

  // Task : process_read
  // This method keep receiving read address phase and calls another method to
  // process received transaction.
  task process_read;
    forever
    begin
      axi_transaction read_trans;
    
      read_trans = bfm.create_slave_transaction();
      set_read_address_ready_delay(read_trans);
      bfm.get_read_addr_phase(read_trans);

      fork
        begin
          automatic axi_transaction t = read_trans;
          handle_read(t);
        end
      join_none
      #0;
    end
  endtask

  // Task : handle_read
  // This method reads data from memory and send read data/response either at
  // burst or phase level depending upon slave working mode.
  task automatic handle_read(input axi_transaction read_trans);
    addr_t addr[];
    bit [7:0] mem_data[];
 
    set_read_data_valid_delay(read_trans); 

    for(int i = 0; bfm.get_read_addr(read_trans, i, addr); i++)
    begin
      mem_data = new[addr.size()];
      for (int j = 0; j < addr.size(); j++)
        mem_data[j] = do_byte_read(addr[j]);

      bfm.set_read_data(read_trans, i, addr, mem_data);

      if (slave_mode == AXI_PHASE_SLAVE)
        bfm.execute_read_data_phase(read_trans, i);
    end

    if (slave_mode == AXI_TRANSACTION_SLAVE)
      bfm.execute_read_data_burst(read_trans);
  endtask

  // Task : process_write
  // This method keep receiving write address phase and calls another method to
  // process received transaction.
  task process_write;
    forever
    begin
      axi_transaction write_trans;
    
      write_trans = bfm.create_slave_transaction();
      set_write_address_ready_delay(write_trans);
      bfm.get_write_addr_phase(write_trans);

      fork
        begin
          automatic axi_transaction t = write_trans;
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
  task automatic handle_write(input axi_transaction write_trans);
    addr_t addr[];
    bit [7:0] data[];
    bit last;

    set_write_data_ready_delay(write_trans); 

    if (slave_mode == AXI_TRANSACTION_SLAVE)
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

endmodule

