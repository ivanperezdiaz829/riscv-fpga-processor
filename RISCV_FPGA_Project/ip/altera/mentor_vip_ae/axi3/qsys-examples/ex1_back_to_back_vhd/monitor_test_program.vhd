-- *****************************************************************************
--
-- Copyright 2007-2013 Mentor Graphics Corporation
-- All Rights Reserved.
--
-- THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF
-- MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
--
-- *****************************************************************************

-- This is a simple example of an AXI monitor to demonstrate the usage of the mgc_axi_monitor BFM. 


library ieee ;
use ieee.std_logic_1164.all;

library work;
use work.all;
use work.mgc_axi_bfm_pkg.all;

entity monitor_test_program is
   generic (AXI_ADDRESS_WIDTH : integer := 32;
            AXI_RDATA_WIDTH : integer := 1024;
            AXI_WDATA_WIDTH : integer := 1024;
            AXI_ID_WIDTH : integer := 18;
            index : integer range 0 to 511 :=0
            );
 end monitor_test_program;

architecture monitor_test_program_a of monitor_test_program is
begin

  -- process_write : write address phase through path 0
  -- This process keep receiving write address phase and push the transaction into queue through 
  -- push_transaction_id API.
  process
    variable write_trans : integer;
  begin
    wait_on(AXI_RESET_0_TO_1, index, axi_tr_if_0(index));
    loop
      create_monitor_transaction(write_trans, index, axi_tr_if_0(index));
      set_read_or_write(AXI_TRANS_WRITE, write_trans, index, axi_tr_if_0(index));
      get_write_addr_phase(write_trans, index, axi_tr_if_0(index));
      push_transaction_id(write_trans, AXI_QUEUE_ID_0, index, axi_tr_if_0(index));
    end loop;
    wait; 
  end process;

  -- handle_write : write data phase through path 1 
  -- This method receives write data phases for write transaction.
  process
    variable write_trans: integer;
    variable last : integer := 0;
    variable loop_i : integer := 0;
  begin
    loop
      pop_transaction_id(write_trans, AXI_QUEUE_ID_0, index, AXI_PATH_1, axi_tr_if_1(index));

      last := 0;
      loop_i := 0;
      while(last = 0) loop
        get_write_data_phase(write_trans, loop_i, last, index, AXI_PATH_1, axi_tr_if_1(index));
        loop_i := loop_i + 1; 
      end loop;
      push_transaction_id(write_trans, AXI_QUEUE_ID_2, index, AXI_PATH_1, axi_tr_if_1(index));
    end loop;
    wait;
  end process;

  -- handle_response : write response phase through path 2
  -- This method receives the write response phase and print the write transaction
  process
    variable write_trans: integer;
  begin
    loop  
      pop_transaction_id(write_trans, AXI_QUEUE_ID_2, index, AXI_PATH_2, axi_tr_if_2(index));
      get_write_response_phase(write_trans, index, AXI_PATH_2, axi_tr_if_2(index));
      report "=======================";
      report "MONITOR: WRITE";
      print(write_trans, index, AXI_PATH_2, axi_tr_if_2(index));
      report "=======================";
    end loop;
    wait;
  end process;

  -- process_read : read address phase through path 3
  -- This process keep receiving read address phase and push the transaction into queue through 
  -- push_transaction_id API.
  process
    variable read_trans: integer;
  begin
    wait_on(AXI_RESET_0_TO_1, index, AXI_PATH_3, axi_tr_if_3(index));
    loop
      create_monitor_transaction(read_trans, index, AXI_PATH_3, axi_tr_if_3(index));
      set_read_or_write(AXI_TRANS_READ, read_trans, index, AXI_PATH_3, axi_tr_if_3(index));
      get_read_addr_phase(read_trans, index, AXI_PATH_3, axi_tr_if_3(index));
      push_transaction_id(read_trans, AXI_QUEUE_ID_1, index, AXI_PATH_3, axi_tr_if_3(index));
    end loop;
    wait;
  end process;

  -- handle_read : read data and response through path 4
  -- This process receives read response and print the read transaction.
  process
    variable read_trans: integer;
    variable done: integer := 0;
    variable loop_i : integer := 0;
    variable last: integer;
  begin
    loop
      pop_transaction_id(read_trans, AXI_QUEUE_ID_1, index, AXI_PATH_4, axi_tr_if_4(index));
      done := 0;
      loop_i := 0;
      while(done = 0) loop
        get_read_data_phase(read_trans, loop_i, last, index, AXI_PATH_4, axi_tr_if_4(index));
        get_transaction_done(done, read_trans, index, AXI_PATH_4, axi_tr_if_4(index));
        loop_i := loop_i + 1; 
      end loop;
      report "=======================";
      report "MONITOR: READ";
      print(read_trans, index, AXI_PATH_4, axi_tr_if_4(index));
      report "=======================";
    end loop;  
    wait;
  end process;

 end monitor_test_program_a;
