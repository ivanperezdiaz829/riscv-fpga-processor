-- *****************************************************************************
--
-- Copyright 2007-2013 Mentor Graphics Corporation
-- All Rights Reserved.
--
-- THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF
-- MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
--
-- *****************************************************************************

 
--    This is a simple example of an AXI4 master to demonstrate the mgc_axi4_master BFM usage. 
--
--    This master performs a directed test, initiating 4 sequential writes, followed by 4 sequential reads.
--    It then verifies that the data read out matches the data written.
--    For the sake of simplicity, only one data cycle is used (default AXI burst length encoding 0).
--
--    It then initiates two write data bursts followed by two read data bursts.
--
--    It then initiates 3 outstanding writes followed by 3 reads.
--    It then verifies that the data read out matches the data written.

library ieee ;
use ieee.std_logic_1164.all;

library work;
use work.all;
use work.mgc_axi4_bfm_pkg.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity master_test_program is
 generic (AXI4_ADDRESS_WIDTH : integer := 32;
          AXI4_RDATA_WIDTH : integer := 32;
          AXI4_WDATA_WIDTH : integer := 32;
          AXI4_ID_WIDTH    : integer := 4;
          AXI4_USER_WIDTH : integer := 4;
          AXI4_REGION_MAP_SIZE : integer := 16;
           index : integer range 0 to 511 :=0
          );
end master_test_program;

architecture master_test_program_a of master_test_program is
  --///////////////////////////////////////////////
  -- Code user could edit according to requirements
  --///////////////////////////////////////////////

  -- Variable : m_wr_resp_phase_ready_delay
  signal m_wr_resp_phase_ready_delay :integer := 2;

  -- Variable : m_rd_data_phase_ready_delay
  signal m_rd_data_phase_ready_delay : integer := 2;
begin

  -- Master test 
  process
    variable tr_id: integer;
    variable data_words         :  std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
    variable lp: line;
  begin    
    wait_on(AXI4_RESET_0_TO_1, index, axi4_tr_if_0(index));
    wait_on(AXI4_CLOCK_POSEDGE, index, axi4_tr_if_0(index));

    -- 4 x Writes
    -- Write data value 1 on byte lanes 1 to address 1.
    create_write_transaction(1, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"00000100";
    set_data_words(data_words, tr_id, index, axi4_tr_if_0(index));
    set_write_strobes(2, tr_id, index, axi4_tr_if_0(index));
    report "master_test_program: Writing data (1) to address (1)";    

    -- By default it will run in Blocking mode 
    execute_transaction(tr_id, index, axi4_tr_if_0(index));

        
    -- Write data value 2 on byte lane 2 to address 2.
    create_write_transaction(2, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"00020000";
    set_data_words(data_words, tr_id, index, axi4_tr_if_0(index));
    set_write_strobes(4, tr_id, index, axi4_tr_if_0(index));
    report "master_test_program: Writing data (2) to address (2)";    

    -- By default it will run in Blocking mode 
    execute_transaction(tr_id, index, axi4_tr_if_0(index));

    -- Write data value 3 on byte lane 3 to address 3.
    create_write_transaction(3, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"03000000";
    set_data_words(data_words, tr_id, index, axi4_tr_if_0(index));
    set_write_strobes(8, tr_id, index, axi4_tr_if_0(index));
    report "master_test_program: Writing data (3) to address (3)";    

    -- By default it will run in Blocking mode 
    execute_transaction(tr_id, index, axi4_tr_if_0(index));

    -- Write data value 4 on byte lane 0 to address 4.
    create_write_transaction(4, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"00000004";
    set_data_words(data_words, tr_id, index, axi4_tr_if_0(index));
    set_write_strobes(1, tr_id, index, axi4_tr_if_0(index));
    report "master_test_program: Writing data (4) to address (4)";    

    -- By default it will run in Blocking mode 
    execute_transaction(tr_id, index, axi4_tr_if_0(index));

    --4 x Reads
    --Read data from address 1.
    create_read_transaction(1, tr_id, index, axi4_tr_if_0(index));
    set_id(1, tr_id, index, axi4_tr_if_0(index));
    set_size(AXI4_BYTES_1, tr_id, index, axi4_tr_if_0(index));
    execute_transaction(tr_id, index, axi4_tr_if_0(index));

    get_data_words(data_words, tr_id, index, axi4_tr_if_0(index));
    if(data_words(31 downto 0) = x"00000100") then 
      report "master_test_program: Read correct data (1) at address (1)";
    else
     hwrite(lp, data_words(31 downto 0)); 
     report "master_test_program: Error: Expected data (1) at address 1, but got " & lp.all;
    end if;
   
    --Read data from address 2.
    create_read_transaction(2, tr_id, index, axi4_tr_if_0(index));
    set_id(2, tr_id, index, axi4_tr_if_0(index));
    set_size(AXI4_BYTES_1, tr_id, index, axi4_tr_if_0(index));
    execute_transaction(tr_id, index, axi4_tr_if_0(index));

    get_data_words(data_words, tr_id, index, axi4_tr_if_0(index));
    if(data_words(31 downto 0) = x"00020000") then 
      report "master_test_program: Read correct data (2) at address (2)";
    else
     hwrite(lp, data_words(31 downto 0)); 
     report "master_test_program: Error: Expected data (2) at address 2, but got " & lp.all;
    end if;

    --Read data from address 3.
    create_read_transaction(3, tr_id, index, axi4_tr_if_0(index));
    set_id(3, tr_id, index, axi4_tr_if_0(index));
    set_size(AXI4_BYTES_1, tr_id, index, axi4_tr_if_0(index));
    execute_transaction(tr_id, index, axi4_tr_if_0(index));

    get_data_words(data_words, tr_id, index, axi4_tr_if_0(index));
    if(data_words(31 downto 0) = x"03000000") then 
      report "master_test_program: Read correct data (3) at address (3)";
    else
     hwrite(lp, data_words(31 downto 0)); 
     report "master_test_program: Error: Expected data (3) at address 3, but got " & lp.all;
    end if;

    --Read data from address 4.
    create_read_transaction(4, tr_id, index, axi4_tr_if_0(index));
    set_id(4, tr_id, index, axi4_tr_if_0(index));
    set_size(AXI4_BYTES_1, tr_id, index, axi4_tr_if_0(index));
    execute_transaction(tr_id, index, axi4_tr_if_0(index));

    get_data_words(data_words, tr_id, index, axi4_tr_if_0(index));
    if(data_words(31 downto 0) = x"00000004") then 
      report "master_test_program: Read correct data (4) at address (4)";
    else
     hwrite(lp, data_words(31 downto 0)); 
     report "master_test_program: Error: Expected data (4) at address 4, but got " & lp.all;
    end if;

 
    --  Write data burst length of 7 to start address 16.
    create_write_transaction(16, 7, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"ACE0ACE1";
    set_data_words(data_words, 0, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"ACE2ACE3";
    set_data_words(data_words, 1, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"ACE4ACE5";
    set_data_words(data_words, 2, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"ACE6ACE7";
    set_data_words(data_words, 3, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"ACE8ACE9";
    set_data_words(data_words, 4, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"ACEAACEB";
    set_data_words(data_words, 5, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"ACECACED";
    set_data_words(data_words, 6, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"ACEEACEF";
    set_data_words(data_words, 7, tr_id, index, axi4_tr_if_0(index));
    for i in  0 to 7 loop
      set_write_strobes(15, i, tr_id, index, axi4_tr_if_0(index));
    end loop;
    execute_transaction(tr_id, index, axi4_tr_if_0(index));

    --  Write data burst length of 7 to start address 128  with LSB write strobe inactive.
    create_write_transaction(128, 7, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"ACE0ACE1";
    set_data_words(data_words, 0, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"ACE2ACE3";
    set_data_words(data_words, 1, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"ACE4ACE5";
    set_data_words(data_words, 2, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"ACE6ACE7";
    set_data_words(data_words, 3, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"ACE8ACE9";
    set_data_words(data_words, 4, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"ACEAACEB";
    set_data_words(data_words, 5, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"ACECACED";
    set_data_words(data_words, 6, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"ACEEACEF";
    set_data_words(data_words, 7, tr_id, index, axi4_tr_if_0(index));
    set_write_strobes(14, 0, tr_id, index, axi4_tr_if_0(index));
    for i in  1 to 7 loop
      set_write_strobes(15, i, tr_id, index, axi4_tr_if_0(index));
    end loop;
    execute_transaction(tr_id, index, axi4_tr_if_0(index));

    -- Read data burst of length 1 from address 16.
    create_read_transaction(16, 1, tr_id, index, axi4_tr_if_0(index));
    execute_transaction(tr_id, index, axi4_tr_if_0(index));

    get_data_words(data_words, 0, tr_id, index, axi4_tr_if_0(index));
    if(data_words(31 downto 0) = x"ACE0ACE1") then 
      report "master_test_program: Read correct data (hACE0ACE1) at address (16)";
    else
     hwrite(lp, data_words(31 downto 0)); 
     report "master_test_program: Error: Expected data (hACE0ACE1) at address (16), but got " & lp.all;
    end if;
    get_data_words(data_words, 1, tr_id, index, axi4_tr_if_0(index));
    if(data_words(31 downto 0) = x"ACE2ACE3") then 
      report "master_test_program: Read correct data (hACE2ACE3) at address (20)";
    else
     hwrite(lp, data_words(31 downto 0)); 
     report "master_test_program: Error: Expected data (hACE2ACE3) at address (20), but got " & lp.all;
    end if;

    -- Read data burst of length 1 from address 128.
    create_read_transaction(128, 1, tr_id, index, axi4_tr_if_0(index));
    execute_transaction(tr_id, index, axi4_tr_if_0(index));

    get_data_words(data_words, 0, tr_id, index, axi4_tr_if_0(index));
    if(data_words(31 downto 0) = x"ACE0AC00") then 
      report "master_test_program: Read correct data (ACE0AC00) at address (128)";
    else
     hwrite(lp, data_words(31 downto 0)); 
     report "master_test_program: Error: Expected data (ACE0AC00) at address (128), but got " & lp.all;
    end if;
    get_data_words(data_words, 1, tr_id, index, axi4_tr_if_0(index));
    if(data_words(31 downto 0) = x"ACE2ACE3") then 
      report "master_test_program: Read correct data (hACE2ACE3) at address (132)";
    else
     hwrite(lp, data_words(31 downto 0)); 
     report "master_test_program: Error: Expected data (hACE2ACE3) at address (132), but got " & lp.all;
    end if;

    -------------------------------------------------------------------------
    --------------------  Outstanding write transactions --------------------
    -------------------------------------------------------------------------

    create_write_transaction(0, 3, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"ACE0ACE1";
    set_data_words(data_words, 0, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"ACE2ACE3";
    set_data_words(data_words, 1, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"ACE4ACE5";
    set_data_words(data_words, 2, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"ACE6ACE7";
    set_data_words(data_words, 3, tr_id, index, axi4_tr_if_0(index));
    for i in  0 to 3 loop
      set_write_strobes(15, i, tr_id, index, axi4_tr_if_0(index));
    end loop;
    set_write_data_mode(AXI4_DATA_AFTER_ADDRESS, tr_id, index, axi4_tr_if_0(index));  
    set_operation_mode(AXI4_TRANSACTION_NON_BLOCKING, tr_id, index, axi4_tr_if_0(index));  
    execute_transaction(tr_id, index, axi4_tr_if_0(index));

    create_write_transaction(32, 2, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"ACE0ACE1";
    set_data_words(data_words, 0, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"ACE2ACE3";
    set_data_words(data_words, 1, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"ACE4ACE5";
    set_data_words(data_words, 2, tr_id, index, axi4_tr_if_0(index));
    for i in  0 to 2 loop
      set_write_strobes(15, i, tr_id, index, axi4_tr_if_0(index));
    end loop;
    set_write_data_mode(AXI4_DATA_AFTER_ADDRESS, tr_id, index, axi4_tr_if_0(index));  
    set_operation_mode(AXI4_TRANSACTION_NON_BLOCKING, tr_id, index, axi4_tr_if_0(index));  
    execute_transaction(tr_id, index, axi4_tr_if_0(index));

    create_write_transaction(64, 4, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"ACE0ACE1";
    set_data_words(data_words, 0, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"ACE2ACE3";
    set_data_words(data_words, 1, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"ACE4ACE5";
    set_data_words(data_words, 2, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"ACE6ACE7";
    set_data_words(data_words, 3, tr_id, index, axi4_tr_if_0(index));
    data_words(31 downto 0) := x"ACE8ACE9";
    set_data_words(data_words, 4, tr_id, index, axi4_tr_if_0(index));
    for i in  0 to 4 loop
      set_write_strobes(15, i, tr_id, index, axi4_tr_if_0(index));
    end loop;
    set_write_data_mode(AXI4_DATA_AFTER_ADDRESS, tr_id, index, axi4_tr_if_0(index));  
    set_operation_mode(AXI4_TRANSACTION_NON_BLOCKING, tr_id, index, axi4_tr_if_0(index));  
    execute_transaction(tr_id, index, axi4_tr_if_0(index));

    for i in 0 to 50 loop
      wait_on(AXI4_CLOCK_POSEDGE, index, axi4_tr_if_0(index));
    end loop;

    -- Read data burst of length 1 from address 0.
    create_read_transaction(0, 1, tr_id, index, axi4_tr_if_0(index));
    execute_transaction(tr_id, index, axi4_tr_if_0(index));

    get_data_words(data_words, 0, tr_id, index, axi4_tr_if_0(index));
    if(data_words(31 downto 0) = x"ACE0ACE1") then 
      report "master_test_program: Read correct data (hACE0ACE1) at address (0)";
    else
     hwrite(lp, data_words(31 downto 0)); 
     report "master_test_program: Error: Expected data (hACE0ACE1) at address (0), but got " & lp.all;
    end if;
    get_data_words(data_words, 1, tr_id, index, axi4_tr_if_0(index));
    if(data_words(31 downto 0) = x"ACE2ACE3") then 
      report "master_test_program: Read correct data (hACE2ACE3) at address (4)";
    else
     hwrite(lp, data_words(31 downto 0)); 
     report "master_test_program: Error: Expected data (hACE2ACE3) at address (4), but got " & lp.all;
    end if;

    -- Read data burst of length 1 from address 32.
    create_read_transaction(32, 1, tr_id, index, axi4_tr_if_0(index));
    execute_transaction(tr_id, index, axi4_tr_if_0(index));

    get_data_words(data_words, 0, tr_id, index, axi4_tr_if_0(index));
    if(data_words(31 downto 0) = x"ACE0ACE1") then 
      report "master_test_program: Read correct data (ACE0ACE1) at address (32)";
    else
     hwrite(lp, data_words(31 downto 0)); 
     report "master_test_program: Error: Expected data (ACE0ACE1) at address (32), but got " & lp.all;
    end if;
    get_data_words(data_words, 1, tr_id, index, axi4_tr_if_0(index));
    if(data_words(31 downto 0) = x"ACE2ACE3") then 
      report "master_test_program: Read correct data (hACE2ACE3) at address (36)";
    else
     hwrite(lp, data_words(31 downto 0)); 
     report "master_test_program: Error: Expected data (hACE2ACE3) at address (36), but got " & lp.all;
    end if;

    -- Read data burst of length 1 from address 64.
    create_read_transaction(64, 1, tr_id, index, axi4_tr_if_0(index));
    execute_transaction(tr_id, index, axi4_tr_if_0(index));

    get_data_words(data_words, 0, tr_id, index, axi4_tr_if_0(index));
    if(data_words(31 downto 0) = x"ACE0ACE1") then 
      report "master_test_program: Read correct data (ACE0ACE1) at address (64)";
    else
     hwrite(lp, data_words(31 downto 0)); 
     report "master_test_program: Error: Expected data (ACE0ACE1) at address (64), but got " & lp.all;
    end if;
    get_data_words(data_words, 1, tr_id, index, axi4_tr_if_0(index));
    if(data_words(31 downto 0) = x"ACE2ACE3") then 
      report "master_test_program: Read correct data (hACE2ACE3) at address (68)";
    else
     hwrite(lp, data_words(31 downto 0)); 
     report "master_test_program: Error: Expected data (hACE2ACE3) at address (68), but got " & lp.all;
    end if;

    wait;
  end process;

  -- handle_write_resp_ready : write response ready through path 5. 
  -- This method assert/de-assert the write response channel ready signal.
  -- Assertion and de-assertion is done based on following variable's value:
  -- m_wr_resp_phase_ready_delay
  process
    variable tmp_ready_delay : integer;
  begin
    wait_on(AXI4_RESET_0_TO_1, index, AXI4_PATH_5, axi4_tr_if_5(index));
    wait_on(AXI4_CLOCK_POSEDGE, index, AXI4_PATH_5, axi4_tr_if_5(index));
    loop
      wait until m_wr_resp_phase_ready_delay > 0;
      tmp_ready_delay := m_wr_resp_phase_ready_delay;
      execute_write_resp_ready(0, 1, index, AXI4_PATH_5, axi4_tr_if_5(index)); 
      get_write_response_cycle(index, AXI4_PATH_5, axi4_tr_if_5(index)); 
      if(tmp_ready_delay > 1) then
        for i in  0 to tmp_ready_delay-2 loop
          wait_on(AXI4_CLOCK_POSEDGE, index, AXI4_PATH_5, axi4_tr_if_5(index));
        end loop;
      end if;  
      execute_write_resp_ready(1, 1, index, AXI4_PATH_5, axi4_tr_if_5(index)); 
    end loop;
    wait;
  end process;

  -- handle_read_data_ready : read data ready through path 6.
  -- This method assert/de-assert the read data channel ready signal.
  -- Assertion and de-assertion is done based on following variable's value:
  -- m_rd_data_phase_ready_delay
  process
    variable tmp_ready_delay : integer;
  begin
    wait_on(AXI4_RESET_0_TO_1, index, AXI4_PATH_6, axi4_tr_if_6(index));
    wait_on(AXI4_CLOCK_POSEDGE, index, AXI4_PATH_6, axi4_tr_if_6(index));
    loop
      wait until m_rd_data_phase_ready_delay > 0;
      tmp_ready_delay := m_rd_data_phase_ready_delay;
      execute_read_data_ready(0, 1, index, AXI4_PATH_6, axi4_tr_if_6(index)); 
      get_read_data_cycle(index, AXI4_PATH_6, axi4_tr_if_6(index)); 
      if(tmp_ready_delay > 1) then
        for i in  0 to tmp_ready_delay-2 loop
          wait_on(AXI4_CLOCK_POSEDGE, index, AXI4_PATH_6, axi4_tr_if_6(index));
        end loop;
      end if;  
      execute_read_data_ready(1, 1, index, AXI4_PATH_6, axi4_tr_if_6(index)); 
    end loop;
    wait;
  end process;

end master_test_program_a;

