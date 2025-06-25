
--  pci_mt64 Reference Design
--  MODULE NAME: tr_mw_sm
--  COMPANY:  Altera Coporation.
--            www.altera.com    

--  FUNCTIONAL DESCRIPTION:
-- This file consists of state machine which is required
-- ** to generate the command signal to the SDR Sdram controller

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
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
 
entity tr_mw_sm is
  port (
        clk : in STD_LOGIC;
        reset_n : in STD_LOGIC;
        target_read : in STD_LOGIC;
        bar1_hit : in STD_LOGIC;
        cmdack : in STD_LOGIC;
        rd_wr_ctrl_cntr : in STD_LOGIC_VECTOR (2 downto 0);
        abort_rd : in STD_LOGIC;
        dma_req_sdram : in STD_LOGIC;
        dma_on_bit : in STD_LOGIC;
        data_cntr : in STD_LOGIC_VECTOR (13 downto 0);
        data_cntr_zero : out STD_LOGIC;
        data_cntr_upper_zero : out STD_LOGIC;
        end_sdram_txfr : in STD_LOGIC;
        dma_csr : in STD_LOGIC_VECTOR (8 downto 0);
        rd_req : in STD_LOGIC;
        wr_req : in STD_LOGIC;
        tw_mr_sm : in STD_LOGIC_VECTOR (4 downto 0);
        tr_mw_sm : out STD_LOGIC_VECTOR(4 downto 0 );
        tr_mw_cmd_req : out STD_LOGIC;
        dis_monitor_sig : out STD_LOGIC;
        abort_rd_lat : out STD_LOGIC;
        end_of_rdxfr : out STD_LOGIC
        );
end tr_mw_sm;
 

 
architecture tr_mw_sm of tr_mw_sm is
  signal visual_0_data_cntr_zero : STD_LOGIC;--    ----- created for output, which is read or nets with declaration delay .
  signal visual_1_tr_mw_sm : STD_LOGIC_VECTOR(4 downto 0 );--    ----- created for output, which is read or nets with declaration delay .
  signal visual_0_abort_rd_lat : STD_LOGIC;--    ----- created for output, which is read or nets with declaration delay .
 
  
  --  state machine definitions
  --  idle state
  --  start state
  --  send request state
  --  write state
  --  Internal signals
  signal end_trd_txfr : STD_LOGIC;
  signal end_mwr_txfr : STD_LOGIC;
  signal data_cntr_dec1 : STD_LOGIC;
  signal data_cntr_dec2 : STD_LOGIC;
  signal data_cntr_dec3 : STD_LOGIC;
  signal terminate_tr : STD_LOGIC;
  signal del_target_read : STD_LOGIC;
begin
 
  abort_rd_lat <= visual_0_abort_rd_lat;
  tr_mw_sm <= visual_1_tr_mw_sm;
  data_cntr_zero <= visual_0_data_cntr_zero;
 
  --  The upper 12 bits are decoded inorder to generate the data_cntr_zero signal
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      data_cntr_dec1 <= '0';
      data_cntr_dec2 <= '0';
      data_cntr_dec3 <= '0';
    elsif (clk'event and clk = '1' ) then
      data_cntr_dec1 <= not(data_cntr(13) or data_cntr(12) or data_cntr(11) or
                        data_cntr(10));
      data_cntr_dec2 <= not(data_cntr(9) or data_cntr(8) or data_cntr(7) or
                        data_cntr(6));
      data_cntr_dec3 <= not(data_cntr(5) or data_cntr(4) or data_cntr(3) or
                        data_cntr(2));
    end if ;
  end process ;
 
  --  Generation of data_cntr_zero signal
  --  This signal is asserted during master read or master write access
  --  This signal is asserted when the data cntr is 2 and there is a write request signal
  --  or when the data cntr is 1
  --  This is used as a control signal by the tr_mw_sm and tw_mr_sm during a master access
  --  which indicates the last transfer
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      visual_0_data_cntr_zero <= '0';
    elsif (clk'event and clk = '1' ) then
      if (dma_on_bit) = '1'  and (visual_0_data_cntr_zero = '0' ) and (((rd_req)
          = '1'  or (visual_1_tr_mw_sm(2)) = '1'  or (wr_req) = '1' )) then
        visual_0_data_cntr_zero <= data_cntr_dec1 and data_cntr_dec2 and
                                   data_cntr_dec3 and ((((data_cntr(1) and not(
                                   data_cntr(0)) and wr_req)) or ((not(data_cntr
                                   (1)) and data_cntr(0)))));
      else
        if (visual_1_tr_mw_sm(0)) = '1'  and (tw_mr_sm(0)) = '1'  then
          visual_0_data_cntr_zero <= '0';
        end if ;
      end if ;
    end if ;
  end process ;
 
  --  Generation of control signal which indicates whether the remanining data during the master acces is
  --  less or more than eight
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      data_cntr_upper_zero <= '0';
    elsif (clk'event and clk = '1' ) then
      data_cntr_upper_zero <= data_cntr_dec1 and data_cntr_dec2 and not(
                              data_cntr(5)) and not(data_cntr(4)) and not(
                              data_cntr(3));
    end if ;
  end process ;
 
  end_trd_txfr <= terminate_tr;
  --  end of target read transaction
  end_mwr_txfr <= (visual_0_data_cntr_zero) or (visual_0_abort_rd_lat or abort_rd);
  --  end of master write transaction
  --  latching the abort read signal
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      visual_0_abort_rd_lat <= '0';
    elsif (clk'event and clk = '1' ) then
      if end_sdram_txfr = '1' then
        visual_0_abort_rd_lat <= '0';
      else
        if abort_rd = '1' and (dma_on_bit) = '1'  then
          visual_0_abort_rd_lat <= '1';
        end if ;
      end if ;
    end if ;
  end process ;
 
  --  latching the target read signal
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      del_target_read <= '0';
    elsif (clk'event and clk = '1' ) then
      del_target_read <= target_read;
    end if ;
  end process ;
 
  --  control signal which terminates target read operation
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      terminate_tr <= '0';
    elsif (clk'event and clk = '1' ) then
      if (del_target_read) = '1'  and (target_read = '0' ) then
        terminate_tr <= '1';
      else
        if ext(visual_1_tr_mw_sm(3 downto 0),5) = "00001" then
          terminate_tr <= '0';
        end if ;
      end if ;
    end if ;
  end process ;
 
  -- TARGET READ STATE MACHINE
  process (clk, reset_n)
    variable case_var : STD_LOGIC_VECTOR(4 downto 0);
       -- Generated for case statement
 
  begin
    if reset_n = '0' then
      visual_1_tr_mw_sm <= "00001";
      end_of_rdxfr <= '0';
      tr_mw_cmd_req <= '0';
      dis_monitor_sig <= '0';
    elsif (clk'event and clk = '1' ) then
      case_var := ext(visual_1_tr_mw_sm(3 downto 0),5) ;
      case case_var is
        when "00001" =>
          --  Idle State
          --  When there is a target read/ master write the state machine goes to the send request state
          --  by asserting the request to the command state machine to output the appropriate command
          end_of_rdxfr <= '0';
          dis_monitor_sig <= '0';
          if ((target_read = '1' and bar1_hit = '1')) or ((dma_req_sdram = '1'
             and dma_csr(3) = '1')) then
            visual_1_tr_mw_sm <= "00010";
            tr_mw_cmd_req <= '1';
          else
            visual_1_tr_mw_sm <= "00001";
          end if ;
        when "00010" =>
          --  Send Request State
          --  In this state when the command ack is asserted it goes to the wait state
          --  else waits for command ack in the same state
          tr_mw_cmd_req <= '0';
          dis_monitor_sig <= '0';
          if cmdack = '1' then
            visual_1_tr_mw_sm <= "00100";
          else
            visual_1_tr_mw_sm <= "00010";
          end if ;
        when "00100" =>
          if rd_wr_ctrl_cntr = "110" then
            --  Wait State
            --  In this state, it waits for the data to be available on the sdram controller data bus
            --  It waits for cas latency + ras to cas delay + 1 clock cycle(waiting time) and moves
            --  to the read state
            visual_1_tr_mw_sm <= "01000";
          else
            visual_1_tr_mw_sm <= "00100";
          end if ;
        when "01000" =>
          if rd_wr_ctrl_cntr = "111" then
            if end_trd_txfr = '1' or end_mwr_txfr = '1' then
              --  Read State
              --  In this state a burst of 8 data is read from the sdram controller
              --  If it the last transfer it goes to the idle state asserting the end_of_rdxfr signal
              --  and dis_monitor_sig
              --  else goes to the send request state to send another request to the
              --  sdram controller and also asserts the dis_monitor_sig which is used as control signal
              --  when the lower 3 address bits are not zero
              visual_1_tr_mw_sm <= "00001";
              end_of_rdxfr <= '1';
              dis_monitor_sig <= '1';
            else
              tr_mw_cmd_req <= '1';
              visual_1_tr_mw_sm <= "00010";
              dis_monitor_sig <= '1';
            end if ;
          else
            visual_1_tr_mw_sm <= "01000";
          end if ;
        when others =>
          null;
      end case  ;
    end if ;
  end process ;
 
 
end ;

