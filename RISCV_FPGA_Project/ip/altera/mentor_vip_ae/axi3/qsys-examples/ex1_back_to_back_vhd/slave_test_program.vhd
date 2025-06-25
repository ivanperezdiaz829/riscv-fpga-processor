-- *****************************************************************************
--
-- Copyright 2007-2013 Mentor Graphics Corporation
-- All Rights Reserved.
--
-- THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF
-- MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
--
-- *****************************************************************************
-- 
-- This is a simple example of an AXI Slave to demonstrate the mgc_axi_slave BFM usage. 
--
-- This is a fairly generic slave which handles almost all write and read transaction
-- scenarios from master. It handles write data with address as well as data after address
-- both. It handles outstanding read and write transactions.
--
-- This slave code is divided in two parts, one which user might need to edit to change slave
-- mode (Transaction/burst or Phase level) and memory handling.
-- Out of the code which is grouped as user do not need to edit, could be edited for achieving
-- required phase valid/ready delays.
--
library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.all;
use work.mgc_axi_bfm_pkg.all;

entity slave_test_program is
   generic (AXI_ADDRESS_WIDTH : integer := 32;
            AXI_RDATA_WIDTH : integer := 1024;
            AXI_WDATA_WIDTH : integer := 1024;
            AXI_ID_WIDTH : integer := 18;
            index : integer range 0 to 511 := 0
            );
 end slave_test_program;

architecture slave_test_program_a of slave_test_program is
  type axi_slave_mode_e is (AXI_TRANSACTION_SLAVE, AXI_PHASE_SLAVE);
  type memory_t is array (0 to 2**16-1) of std_logic_vector(7 downto 0);
  shared variable mem : memory_t;

  signal slave_mode : axi_slave_mode_e := AXI_TRANSACTION_SLAVE;
  signal m_max_outstanding_read_trans : integer := 2;
  signal m_max_outstanding_write_trans : integer := 2;

  procedure do_byte_read(addr : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0); data : out std_logic_vector(7 downto 0));
  procedure do_byte_write(addr : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);  data : in std_logic_vector(7 downto 0));
  procedure set_write_address_ready_delay(id : integer; signal tr_if : inout axi_vhd_if_struct_t);
  procedure set_write_address_ready_delay(id : integer; path_id : in axi_path_t; signal tr_if : inout axi_vhd_if_struct_t);
  procedure set_read_address_ready_delay(id : integer; signal tr_if : inout axi_vhd_if_struct_t);
  procedure set_read_address_ready_delay(id : integer; path_id : in axi_path_t; signal tr_if : inout axi_vhd_if_struct_t);
  procedure set_write_data_ready_delay(id : integer; signal tr_if : inout axi_vhd_if_struct_t);
  procedure set_write_data_ready_delay(id : integer; path_id : in axi_path_t; signal tr_if : inout axi_vhd_if_struct_t);
  procedure set_wr_resp_valid_delay(id : integer; signal tr_if : inout axi_vhd_if_struct_t);
  procedure set_wr_resp_valid_delay(id : integer; path_id : in axi_path_t; signal tr_if : inout axi_vhd_if_struct_t);
  procedure set_read_data_valid_delay(id : integer; signal tr_if : inout axi_vhd_if_struct_t);
  procedure set_read_data_valid_delay(id : integer; path_id : in axi_path_t; signal tr_if : inout axi_vhd_if_struct_t);

  -- Procedure : do_byte_read
  -- Procedure to provide read data byte from memory at particular input
  -- address
  procedure do_byte_read(addr : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0); data : out std_logic_vector(7 downto 0)) is
  begin
    data := mem(to_integer(addr));
  end do_byte_read;

  -- Procedure : do_byte_write
  -- Procedure to write data byte to memory at particular input address
  procedure do_byte_write(addr : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);  data : in std_logic_vector(7 downto 0)) is
  begin
    mem(to_integer(addr)) := data;
  end do_byte_write;

  -- Procedure : set_write_address_ready_delay
  -- This is used to set write address phase ready delay to extend phase
  procedure set_write_address_ready_delay(id : integer; signal tr_if : inout axi_vhd_if_struct_t) is
  begin
    set_address_ready_delay(1, id, index, tr_if);
  end set_write_address_ready_delay;
  procedure set_write_address_ready_delay(id : integer; path_id : in axi_path_t; signal tr_if : inout axi_vhd_if_struct_t) is
  begin
    set_address_ready_delay(1, id, index, path_id, tr_if);
  end set_write_address_ready_delay;

  -- Procedure : set_read_address_ready_delay
  -- This is used to set read address phase ready delay to extend phase
  procedure set_read_address_ready_delay(id : integer; signal tr_if : inout axi_vhd_if_struct_t) is
  begin
    set_address_ready_delay(1, id, index, tr_if);
  end set_read_address_ready_delay;
  procedure set_read_address_ready_delay(id : integer; path_id : in axi_path_t; signal tr_if : inout axi_vhd_if_struct_t) is
  begin
    set_address_ready_delay(1, id, index, path_id, tr_if);
  end set_read_address_ready_delay;

  -- Procedure : set_write_data_ready_delay
  -- This will set the ready delays for each write data phase in a write data
  -- burst
  procedure set_write_data_ready_delay(id : integer; signal tr_if : inout axi_vhd_if_struct_t) is
    variable burst_length : integer;
  begin
    get_burst_length(burst_length, id, index, tr_if);
    for i in  0 to burst_length loop
      set_data_ready_delay(i, i, id, index, tr_if);
    end loop;
  end set_write_data_ready_delay;
  procedure set_write_data_ready_delay(id : integer; path_id : in axi_path_t; signal tr_if : inout axi_vhd_if_struct_t) is
    variable burst_length : integer;
  begin
    get_burst_length(burst_length, id, index, path_id, tr_if);
    for i in  0 to burst_length loop
      set_data_ready_delay(i, i, id, index, path_id, tr_if);
    end loop;
  end set_write_data_ready_delay;

  -- Procedure : set_wr_resp_valid_delay
  -- This is used to set write response phase valid delay to start driving
  -- write response phase after specified delay.
  procedure set_wr_resp_valid_delay(id : integer; signal tr_if : inout axi_vhd_if_struct_t) is
  begin
    set_write_response_valid_delay(0, id, index, tr_if);
  end set_wr_resp_valid_delay;
  procedure set_wr_resp_valid_delay(id : integer; path_id : in axi_path_t; signal tr_if : inout axi_vhd_if_struct_t) is
  begin
    set_write_response_valid_delay(0, id, index, path_id, tr_if);
  end set_wr_resp_valid_delay;

  -- Procedure : set_read_data_valid_delay
  -- This will set the ready delays for each write data phase in a write data
  -- burst
  procedure set_read_data_valid_delay(id : integer; signal tr_if : inout axi_vhd_if_struct_t) is
    variable burst_length : integer;
  begin
    get_burst_length(burst_length, id, index, tr_if);
    for i in  0 to burst_length loop
      set_data_valid_delay(i, i, id, index, tr_if);
    end loop;
  end set_read_data_valid_delay;
  procedure set_read_data_valid_delay(id : integer; path_id : in axi_path_t; signal tr_if : inout axi_vhd_if_struct_t) is
    variable burst_length : integer;
  begin
    get_burst_length(burst_length, id, index, path_id, tr_if);
    for i in  0 to burst_length loop
      set_data_valid_delay(i, i, id, index, path_id, tr_if);
    end loop;
  end set_read_data_valid_delay;

begin

  -- To create pipelining in VHDL there are multiple channel path in each API.
  -- So each process will choose separate path to interact with BFM.

  -- process_write : write address phase through path 0
  -- This process keep receiving write address phase and push the transaction into queue through 
  -- push_transaction_id API.
  process
    variable write_trans : integer;
  begin
    set_config(AXI_CONFIG_MAX_OUTSTANDING_RD, m_max_outstanding_read_trans, index, axi_tr_if_0(index));
    set_config(AXI_CONFIG_MAX_OUTSTANDING_WR, m_max_outstanding_write_trans, index, axi_tr_if_0(index));
    wait_on(AXI_RESET_0_TO_1, index, axi_tr_if_0(index));
    wait_on(AXI_CLOCK_POSEDGE, index, axi_tr_if_0(index));
    loop
      create_slave_transaction(write_trans, index, axi_tr_if_0(index));
      set_write_address_ready_delay(write_trans, axi_tr_if_0(index));
      get_write_addr_phase(write_trans, index, axi_tr_if_0(index));
      push_transaction_id(write_trans, AXI_QUEUE_ID_0, index, axi_tr_if_0(index));
    end loop;
    wait; 
  end process;

  -- handle_write : write data phase through path 1 
  -- This method receive write data burst or phases for write transaction
  -- depending upon slave working mode and write data to memory.
  process
    variable write_trans: integer;
    variable byte_length : integer;
    variable burst_length : integer;
    variable addr : std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
    variable data : std_logic_vector(7 downto 0);
    variable last : integer := 0;
    variable loop_i : integer := 0;
  begin
    loop
      pop_transaction_id(write_trans, AXI_QUEUE_ID_0, index, AXI_PATH_1, axi_tr_if_1(index));
      set_write_data_ready_delay(write_trans, AXI_PATH_1, axi_tr_if_1(index));

      if (slave_mode = AXI_TRANSACTION_SLAVE) then 
        get_write_data_burst(write_trans, index, AXI_PATH_1, axi_tr_if_1(index));
        get_burst_length(burst_length, write_trans, index, AXI_PATH_1, axi_tr_if_1(index));
        for i in  0 to burst_length loop
          get_write_addr_data(write_trans,  i, 0, byte_length, addr, data, index, AXI_PATH_1, axi_tr_if_1(index));
          do_byte_write(addr, data); 
          if byte_length > 1 then 
            for j in 1 to byte_length-1 loop
               get_write_addr_data(write_trans,  i, j, byte_length, addr, data, index, AXI_PATH_1, axi_tr_if_1(index));
               do_byte_write(addr, data); 
            end loop;
          end if;  
        end loop;
      else
        last := 0;
        loop_i := 0;
        while(last = 0) loop
          get_write_data_phase(write_trans, loop_i, last, index, AXI_PATH_1, axi_tr_if_1(index));
          get_write_addr_data(write_trans,  loop_i, 0, byte_length, addr, data, index, AXI_PATH_1, axi_tr_if_1(index));
          do_byte_write(addr, data); 
          if byte_length > 1 then 
            for j in 1 to byte_length-1 loop
               get_write_addr_data(write_trans,  loop_i, j, byte_length, addr, data, index, AXI_PATH_1, axi_tr_if_1(index));
               do_byte_write(addr, data); 
            end loop;
          end if;
          loop_i := loop_i + 1; 
        end loop;
      end if;
      push_transaction_id(write_trans, AXI_QUEUE_ID_2, index, AXI_PATH_1, axi_tr_if_1(index));
    end loop;
    wait;
  end process;

  -- handle_response : write response phase through path 2
  -- This method sends the write response phase
  process
    variable write_trans: integer;
  begin
    loop  
      pop_transaction_id(write_trans, AXI_QUEUE_ID_2, index, AXI_PATH_2, axi_tr_if_2(index));
      set_wr_resp_valid_delay(write_trans, AXI_PATH_2, axi_tr_if_2(index));
      execute_write_response_phase(write_trans, index, AXI_PATH_2, axi_tr_if_2(index));
    end loop;
    wait;
  end process;

  -- process_read : read address phase through path 3
  -- This process keep receiving read address phase and push the transaction into queue through 
  -- push_transaction_id API.
  process
    variable read_trans: integer;
  begin
    set_config(AXI_CONFIG_MAX_OUTSTANDING_RD, m_max_outstanding_read_trans, index, AXI_PATH_3, axi_tr_if_3(index));
    set_config(AXI_CONFIG_MAX_OUTSTANDING_WR, m_max_outstanding_write_trans, index, AXI_PATH_3, axi_tr_if_3(index));
    wait_on(AXI_RESET_0_TO_1, index, AXI_PATH_3, axi_tr_if_3(index));
    wait_on(AXI_CLOCK_POSEDGE, index, AXI_PATH_3, axi_tr_if_3(index));
    loop
      create_slave_transaction(read_trans, index, AXI_PATH_3, axi_tr_if_3(index));
      set_read_address_ready_delay(read_trans, AXI_PATH_3, axi_tr_if_3(index));
      get_read_addr_phase(read_trans, index, AXI_PATH_3, axi_tr_if_3(index));
      push_transaction_id(read_trans, AXI_QUEUE_ID_1, index, AXI_PATH_3, axi_tr_if_3(index));
    end loop;
    wait;
  end process;

  -- handle_read : read data and response through path 4
  -- This process reads data from memory and send read data/response either at
  -- burst or phase level depending upon slave working mode. 
  process
    variable read_trans: integer;
    variable burst_length : integer;
    variable byte_length : integer;
    variable addr : std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
    variable data : std_logic_vector(7 downto 0);
  begin
    loop
      pop_transaction_id(read_trans, AXI_QUEUE_ID_1, index, AXI_PATH_4, axi_tr_if_4(index));
      set_read_data_valid_delay(read_trans, AXI_PATH_4, axi_tr_if_4(index));
   
      get_burst_length(burst_length, read_trans, index, AXI_PATH_4, axi_tr_if_4(index));
      for i in  0 to burst_length loop
        get_read_addr(read_trans,  i, 0, byte_length, addr, index, AXI_PATH_4, axi_tr_if_4(index));
        do_byte_read(addr, data);
        set_read_data(read_trans, i, 0, byte_length, addr, data, index, AXI_PATH_4, axi_tr_if_4(index));
        if byte_length > 1 then 
          for j in 1 to byte_length-1 loop
             get_read_addr(read_trans,  i, j, byte_length, addr, index, AXI_PATH_4, axi_tr_if_4(index));
             do_byte_read(addr, data);
             set_read_data(read_trans, i, j, byte_length, addr, data, index, AXI_PATH_4, axi_tr_if_4(index));
          end loop;
        end if;
        if slave_mode = AXI_PHASE_SLAVE then
          execute_read_data_phase(read_trans, i, index, AXI_PATH_4, axi_tr_if_4(index));
        end if;
      end loop;
      if slave_mode = AXI_TRANSACTION_SLAVE then
        execute_read_data_burst(read_trans, index, AXI_PATH_4, axi_tr_if_4(index));
      end if;  
    end loop;
    wait;
  end process;
end slave_test_program_a;

