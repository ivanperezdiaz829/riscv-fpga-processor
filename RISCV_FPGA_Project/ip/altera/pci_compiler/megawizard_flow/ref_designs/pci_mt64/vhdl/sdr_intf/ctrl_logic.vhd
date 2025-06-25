
--------------------------------------------------------------------
--  pci_mt64 Reference Design
--  MODULE NAME: ctrl_logic
--  COMPANY:  Altera Coporation.
--            www.altera.com    

--  FUNCTIONAL DESCRIPTION:
--  This file consists of state machine which is required
-- ** to generate the control logic to control the read and write state
-- ** machines and also which controls the back end interface

--  Copyright (C) 1991-2004 Altera Corporation, All rights reserved.  
--  Altera products are protected under numerous U.S. and foreign patents, 
--  maskwork rights, copyrights and other intellectual property laws. 
--  This reference design file, and your use thereof, is subject to and 
--  governed by the terms and conditions of the applicable Altera Reference 
--  Design License Agreement (either as signed by you or found at www.altera.com).  
--  By using this reference design file, you indicate your acceptance of such terms 
--  and conditions between you and Altera Corporation.  In the event that you do
--  not agree with such terms and conditions, you may not use the reference design 
--  file and please promptly destroy any copies you have made. 
--  This reference design file is being provided on an "as-is" basis and as an 
--  accommodation and therefore all warranties, representations or guarantees 
--  of any kind (whether express, implied or statutory) including, without limitation, 
--  warranties of merchantability, non-infringement, or fitness for a particular purpose, 
--  are specifically disclaimed.  By making this reference design file available, 
--  Altera expressly does not recommend, suggest or require that this reference design 
--  file be used in combination with any other product not provided by Altera.
-----------------------------------------------------------------------------------



library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.STD_LOGIC_ARITH.all;
use ieee.STD_LOGIC_MISC.all;
use ieee.STD_LOGIC_UNSIGNED.all;
 
 
entity ctrl_logic is
  port (
        clk : in STD_LOGIC;
        reset_n : in STD_LOGIC;
        tr_mw_sm : in STD_LOGIC_VECTOR (4 downto 0);
        tw_mr_sm : in STD_LOGIC_VECTOR (4 downto 0);
        cmdack : in STD_LOGIC;
        load_fifodata : in STD_LOGIC;
        rdusedw_dec0 : in STD_LOGIC;
        ben : in STD_LOGIC_VECTOR (7 downto 0);
        rdusedw : in STD_LOGIC_VECTOR (6 downto 0);
        rdusedw_zero : in STD_LOGIC;
        end_sdram_txfr : in STD_LOGIC;
        dma_on_bit : in STD_LOGIC;
        data_cntr_zero : in STD_LOGIC;
        tr_mw_cmd_req : in STD_LOGIC;
        addr_monitor_7 : in STD_LOGIC;
        addr_monitor_6 : in STD_LOGIC;
        low_addr_7 : in STD_LOGIC;
        low_addr_not_zero : in STD_LOGIC;
        ld_addr_monitor : in STD_LOGIC;
        addr : in STD_LOGIC_VECTOR (25 downto 0);
        rd_wr_ctrl_cntr : out STD_LOGIC_VECTOR (2 downto 0);
        rd_wr_ctrl_cntr_7 : out STD_LOGIC;
        rd_req : out STD_LOGIC;
        wr_req : out STD_LOGIC;
        dmn : out STD_LOGIC_VECTOR(7 downto 0 )
        );
end ctrl_logic;
 

 
architecture ctrl_logic of ctrl_logic is
  signal visual_0_rd_wr_ctrl_cntr : STD_LOGIC_VECTOR(2 downto 0 );--    ----- created for output, which is read or nets with declaration delay .
  signal visual_0_rd_req : STD_LOGIC;--    ----- created for output, which is read or nets with declaration delay .
  signal visual_0_wr_req : STD_LOGIC;--    ----- created for output, which is read or nets with declaration delay .
 
 
  component cntr3
      port (
            clr : in STD_LOGIC;
            synclr : in STD_LOGIC;
            clken : in STD_LOGIC;
            clk : in STD_LOGIC; 
            q : out STD_LOGIC_VECTOR (2 downto 0); 
            tc : out STD_LOGIC
            );
  end component;
  signal rd_req_cntr : STD_LOGIC_VECTOR(2 downto 0 );
  signal dmcntr : STD_LOGIC_VECTOR(2 downto 0 );
  --  Internal signals
  signal rd_req_cntr_not1 : STD_LOGIC;  --  this signal indicates that rd_req_cntr is not 1
  signal last_mstr_wr_txfr : STD_LOGIC;  --  this signal is asserted during the last master write operation
  signal addr_monitor_for_dm_7 : STD_LOGIC;  --  control signal which indicates that addr_monitor_for_dm count is seven
  signal cntr3_clken : STD_LOGIC;
  --  Internal registers
  signal rd_req_en : STD_LOGIC;  --  control signal which controls the generation of rd_req
  signal dmcntr_en : STD_LOGIC;  --  enable signal which controls the dm control counter
  signal pulse_cntdat : STD_LOGIC_VECTOR(2 downto 0 );  --  This is the data that is loaded on to dm counter and rd_req counter
  signal rd_wr_ctrl_cntr_clr : STD_LOGIC;  --  counter which controls the read and write state machines
  signal del1_load_fifodata : STD_LOGIC;  --  load_fifodata signal delayed by one clock cycle
  signal dm_en : STD_LOGIC;--  This is the enable signal which controls the generation of dm signal
  signal dis_mstr_wr_en : STD_LOGIC;  --  control signal which disable the wr_req signal during master write opern
  --  at the end of last txfr
  signal addr_monitor_for_dm : STD_LOGIC_VECTOR(2 downto 0 );  --  address monitor signal in order to generate dm when the lower
begin
 
  rd_wr_ctrl_cntr <= visual_0_rd_wr_ctrl_cntr;
  wr_req <= visual_0_wr_req;
  rd_req <= visual_0_rd_req;
 
  --  3 bit address is not zero
  --  Read Write control counter
  --  This counter controls the read and the write state machines.
  --  During write operation this count indicates that number of data being written to the sdram controller
  --  Druing read operation this count is used for two purpose
  --  1. It is used to wait for the time till the data is available at the dataout i,e rcd + cl + 2 clk cycle
  --  2. number of data being read from the sdram controller
  cntr3_clken <= tr_mw_sm(2) or tw_mr_sm(3) or tr_mw_sm(3);
 
  rdwrctrlcntr: cntr3
    port map (
              clk => clk,
              clken => cntr3_clken,
              synclr => rd_wr_ctrl_cntr_clr,
              clr => reset_n,
              q => visual_0_rd_wr_ctrl_cntr(2 downto 0));
  --  This counter is used to control the generation of rd_req signal
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      rd_req_cntr <= "000";
    elsif (clk'event and clk = '1' ) then
      if (del1_load_fifodata) = '1'  then
        rd_req_cntr <= pulse_cntdat;
      else
        if (rd_req_en) = '1'  then
          rd_req_cntr <= ext(ext(rd_req_cntr,32) - 1,abs(2-0)+1);
        end if ;
      end if ;
    end if ;
  end process ;
 
  --  This counter is used to control the generation of dm signal
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      dmcntr <= "000";
    elsif (clk'event and clk = '1' ) then
      if (del1_load_fifodata) = '1'  then
        dmcntr <= pulse_cntdat;
      else
        if (dmcntr_en) = '1'  then
          dmcntr <= ext(ext(dmcntr,32) - 1,abs(2-0)+1);
        else
          if (end_sdram_txfr) = '1'  then
            dmcntr <= "000";
          end if ;
        end if ;
      end if ;
    end if ;
  end process ;
 
  --  This is the synchronous clear signal to the rd_wr_ctrl_cntr
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      rd_wr_ctrl_cntr_clr <= '0';
    elsif (clk'event and clk = '1' ) then
      if (tr_mw_sm(2)) = '1'  and visual_0_rd_wr_ctrl_cntr = "101" then
        rd_wr_ctrl_cntr_clr <= '1';
      else
        rd_wr_ctrl_cntr_clr <= '0';
      end if ;
    end if ;
  end process ;
 
  --  This signal indicates that the count of rd_wr_ctrl_cntr is seven
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      rd_wr_ctrl_cntr_7 <= '0';
    elsif (clk'event and clk = '1' ) then
      if visual_0_rd_wr_ctrl_cntr = "110" then
        rd_wr_ctrl_cntr_7 <= '1';
      else
        rd_wr_ctrl_cntr_7 <= '0';
      end if ;
    end if ;
  end process ;
 
  --  Generation of read request signal to the back end interface
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      visual_0_rd_req <= '0';
    elsif (clk'event and clk = '1' ) then
      if (((((cmdack) = '1'  and (rdusedw_zero = '0' ) and (low_addr_7 = '0' )))
         or (rd_req_en) = '1'  or (load_fifodata) = '1' )) and (tw_mr_sm(0)
          = '0' ) then
        visual_0_rd_req <= '1';
      else
        visual_0_rd_req <= '0';
      end if ;
    end if ;
  end process ;
 
  --  Generation of write request signal to the back end interface
  visual_0_wr_req <= tr_mw_sm(3) and dis_mstr_wr_en;
  --  Generation of control signal which indicates last txfr during master write operation
  last_mstr_wr_txfr <= ((data_cntr_zero and visual_0_wr_req and dma_on_bit)) or
    ((addr_monitor_7 and visual_0_wr_req));
  --  Generation of control signal which disables the write request signal during master write
  --  transaction at the end of transaction
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      dis_mstr_wr_en <= '0';
    elsif (clk'event and clk = '1' ) then
      if last_mstr_wr_txfr = '1' or (tr_mw_sm(0)) = '1'  then
        --  deasserted during a master write operation depending on data counter
        dis_mstr_wr_en <= '0';
      else
        if (tr_mw_cmd_req) = '1'  then
          dis_mstr_wr_en <= '1';  --  asserted when there is target read/ master write operation
        end if ;
      end if ;
    end if ;
  end process ;
 
  --  Generation of data mask signals
  process (dm_en, tr_mw_sm, ben)
 
  begin
    if (dm_en) = '1'  then
      dmn <= ben(7 downto 0);
    else
      if (tr_mw_sm(0) = '0' ) then
        dmn <= "00000000";
      else
        dmn <= "11111111";
      end if ;
    end if ;
  end process ;
 
  --  Control signal used in the generation of rd_req_en signal
  rd_req_cntr_not1 <= not(not(rd_req_cntr(2)) and not(rd_req_cntr(1)));
  --  Control signal for rd_req signal generation
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      rd_req_en <= '0';
    elsif (clk'event and clk = '1' ) then
      if ((rd_req_cntr = "010" and (cmdack = '0' ))) or (((addr_monitor_6) = '1'
          and (visual_0_rd_req) = '1' )) then
        rd_req_en <= '0';
      else
        if ((rd_req_cntr_not1) = '1'  and (cmdack) = '1'  and (addr_monitor_7
            = '0' )) and (tw_mr_sm(0) = '0' ) then
          rd_req_en <= '1';
        end if ;
      end if ;
    end if ;
  end process ;
 
  --  load_fifodata delayed by one clock cycle
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      del1_load_fifodata <= '0';
    elsif (clk'event and clk = '1' ) then
      del1_load_fifodata <= load_fifodata;
    end if ;
  end process ;
 
  --  clock enable for the dmcntr
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      dmcntr_en <= '0';
    elsif (clk'event and clk = '1' ) then
      if dmcntr = "000" or ((addr_monitor_for_dm = "111" and (low_addr_not_zero)
          = '1' )) then
        dmcntr_en <= '0';
      else
        if (tw_mr_sm(3)) = '1'  or (cmdack) = '1'  then
          dmcntr_en <= '1';
        end if ;
      end if ;
    end if ;
  end process ;
 
  --  Control signal which is used in the generationof data mask signal
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      dm_en <= '0';
    elsif (clk'event and clk = '1' ) then
      if (load_fifodata) = '1'  then
        dm_en <= '1';
      else
        if (((tw_mr_sm(3)) = '1'  and dmcntr = "000")) or ((addr_monitor_for_dm
           = "111" and (low_addr_not_zero) = '1'  and (tw_mr_sm(3)) = '1' ))
            then
          dm_en <= '0';
        end if ;
      end if ;
    end if ;
  end process ;
 
  --  This is the data loaded on to the rd_req_cntr and dmcntr which is used
  --  in the generation of rd_req and dm signals
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      pulse_cntdat <= "000";
    elsif (clk'event and clk = '1' ) then
      if (load_fifodata) = '1'  then
        if (rdusedw_dec0) = '1'  then
          --  when the rdusedw is less than or equal to 8
          pulse_cntdat <= ext(ext(rdusedw(2 downto 0),32) - 1,abs(2-0)+1);  --  the rdusedw value is loaded
        else
          pulse_cntdat <= "111";  --  else a count of 8 is loaded
        end if ;
      end if ;
    end if ;
  end process ;
 
  addr_monitor_for_dm_7 <= and_reduce(addr_monitor_for_dm(2 downto 0));
  -- /**** THE LOGIC BELOW IS ADDED IN ORDER TO COMPENSATE FOR THE ADDRESS WRAPPING IN THE SDRAM ****/
  --  Address monitor counter for masking the dm when the lower 3 address bits are not zero
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      addr_monitor_for_dm <= "000";
    elsif (clk'event and clk = '1' ) then
      if (ld_addr_monitor) = '1'  then
        --  the address is loaded at the start of transaction
        addr_monitor_for_dm <= addr(2 downto 0);
      else
        if (tw_mr_sm(3)) = '1'  and (low_addr_not_zero) = '1'  and (
           addr_monitor_for_dm_7 = '0' ) then
          --  the address is incremented after every 8 DWORD(64 Bit) transfer
          addr_monitor_for_dm(2 downto 0) <= ext(ext(addr_monitor_for_dm(2
                                              downto 0),32) + 1,abs(2-0)+1);
        end if ;
      end if ;
    end if ;
  end process ;
 
 
end ;

