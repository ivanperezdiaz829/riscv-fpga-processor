
--  pci_mt64 Reference Design
--  MODULE NAME: tw_mr_sm
--  COMPANY:  Altera Coporation.
--            www.altera.com    

--  FUNCTIONAL DESCRIPTION:
-- This file consists of state machine which is required
--  to generate the command signal to the SDR Sdram controller

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
 
 
entity tw_mr_sm is
  port (
        clk : in STD_LOGIC;
        reset_n : in STD_LOGIC;
        target_write : in STD_LOGIC;
        ext_bcr_zero : in STD_LOGIC;
        bar1_hit : in STD_LOGIC;
        rdusedw : in STD_LOGIC_VECTOR (6 downto 0);
        cmdack : in STD_LOGIC;
        rd_wr_ctrl_cntr_7 : in STD_LOGIC;
        pci_fifo_emptyn : in STD_LOGIC;
        dma_req_sdram : in STD_LOGIC;
        abort_wr : in STD_LOGIC;
        abort_wr_wod : in STD_LOGIC;
        dma_on_bit : in STD_LOGIC;
        dma_csr : in STD_LOGIC_VECTOR (8 downto 0);
        data_cntr_upper_zero : in STD_LOGIC;
        end_sdram_txfr : in STD_LOGIC;
        low_addr_not_zero : in STD_LOGIC;
        tw_mr_sm : out STD_LOGIC_VECTOR(4 downto 0 );
        tw_mr_cmd_req : out STD_LOGIC;
        rdusedw_dec0 : out STD_LOGIC;
        rdusedw_zero : out STD_LOGIC;
        end_of_wrxfr : out STD_LOGIC;
        probe : out STD_LOGIC_VECTOR (7 downto 0)
        );
end tw_mr_sm;
 

 
architecture tw_mr_sm of tw_mr_sm is
  signal visual_1_tw_mr_sm : STD_LOGIC_VECTOR(4 downto 0 );--    ----- created for output, which is read or nets with declaration delay .
  signal visual_0_rdusedw_dec0 : STD_LOGIC;--    ----- created for output, which is read or nets with declaration delay .
  signal visual_0_rdusedw_zero : STD_LOGIC;--    ----- created for output, which is read or nets with declaration delay .
 
  
  
  signal abort_wr_lat : STD_LOGIC;
  --  Internal register
  signal last_txfr : STD_LOGIC;
  signal assert_end_wr_txfr : STD_LOGIC;
  --  Internal signals
  signal abort_write : STD_LOGIC;
  signal wr_less_8 : STD_LOGIC;
  signal terminate_tw_xfr : STD_LOGIC;
begin
 
  rdusedw_zero <= visual_0_rdusedw_zero;
  tw_mr_sm <= visual_1_tw_mr_sm;
  rdusedw_dec0 <= visual_0_rdusedw_dec0;
 
  --  state machine definitions
  --  idle state
  --  start state
  --  send request state
  --  write state
  --  check status state
  --  when the fifo is filled with 8 data this signal is asserted
  --  indicates write operation
  --  indicates master access
  -- indicates target access
  wr_less_8 <= ((not(target_write) and not(dma_on_bit))) or ((ext_bcr_zero and
    dma_on_bit));
  --  when the data to be transferred is less than 8 this signal is asserted
  --  latching the abort write signal
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      abort_wr_lat <= '0';
    elsif (clk'event and clk = '1' ) then
      if abort_wr = '1' and (dma_on_bit) = '1'  then
        abort_wr_lat <= '1';
      else
        if end_sdram_txfr = '1' or (visual_1_tw_mr_sm(0)) = '1'  then
          abort_wr_lat <= '0';
        end if ;
      end if ;
    end if ;
  end process ;
 
  --  Assert the end of write transfer
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      end_of_wrxfr <= '0';
    elsif (clk'event and clk = '1' ) then
      end_of_wrxfr <= assert_end_wr_txfr;
    end if ;
  end process ;
 
  --  The upper 4 bits of rdusedw are decoded
  --  This indicates whether the data is less or more than 8
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      visual_0_rdusedw_dec0 <= '0';
    elsif (clk'event and clk = '1' ) then
      visual_0_rdusedw_dec0 <= (not(rdusedw(6)) and not(rdusedw(5)) and not(
                               rdusedw(4)) and not(rdusedw(3)));
    end if ;
  end process ;
 
  --  This signal indicates that the fifo is empty
  --  It is asserted when rdusedw is zero
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      visual_0_rdusedw_zero <= '0';
    elsif (clk'event and clk = '1' ) then
      visual_0_rdusedw_zero <= (visual_0_rdusedw_dec0 and not(rdusedw(2)) and
                               not(rdusedw(1)) and not(rdusedw(0)));
    end if ;
  end process ;
 
  -- TARGET WRITE/MASTER READ STATE MACHINE
  process (clk, reset_n)
    variable case_var : STD_LOGIC_VECTOR(4 downto 0);
       -- Generated for case statement
 
  begin
    if reset_n = '0' then
      visual_1_tw_mr_sm <= "00001";
      tw_mr_cmd_req <= '0';
      assert_end_wr_txfr <= '0';
      last_txfr <= '0';
    elsif (clk'event and clk = '1' ) then
      case_var := visual_1_tw_mr_sm(4 downto 0) ;
      case case_var is
        when "00001" =>
          --  Idle State
          --  When there is a request for target write or master read operation the
          --  state machine goes to start opertion state
          assert_end_wr_txfr <= '0';
          if ((target_write = '1' and bar1_hit = '1')) or ((dma_req_sdram = '1'
             and dma_csr(3) = '0')) then
            visual_1_tw_mr_sm <= "00010";
          else
            visual_1_tw_mr_sm <= "00001";
          end if ;
        when "00010" =>
          if rdusedw(3) = '1' or (wr_less_8) = '1'  or (abort_wr_wod) = '1'  or
             (abort_wr_lat) = '1'  then
            if (abort_wr_wod) = '1'  then
              --  Start State
              --  In this state the fifo status is checked and once the fifo is filled it goes to
              --  the send request state by asserting the request to the command state machine to
              --  output a write command
              --  else if the fifo is empty then it goes to idle state
              --  by asserting the end of transfer pulse which indicates that there is no
              --  data to be transferred even though there is a request
              -- /*   if (rdusedw[3] == `wr_more_8 || wr_less_8 || abort_wr_wod || abort_wr)
              --                                if (!pci_fifo_emptyn)   // this checks whether the data has been written
              --                                  begin                 // into the fifo
              --                                    tw_mr_sm <= `tw_mr_sendrq_st;
              --                                    tw_mr_cmd_req <= 1'b1;
              --                                  end
              --                                else if (abort_wr_wod)  //target retry (abort without data)
              --                                  begin
              --                                    tw_mr_sm <= `tw_mr_idle_st;
              --                                    assert_end_wr_txfr <= 1'b1;
              --                                  end
              --                                else
              --                                  begin
              --                                    tw_mr_sm <= `tw_mr_start_st;
              --                                  end
              --                              else
              --                                tw_mr_sm <= `tw_mr_start_st;
              --                            end */
              --  this checks whether the data has been written
              --  into the fifo
              visual_1_tw_mr_sm <= "00001";
              assert_end_wr_txfr <= '1';
            else
              if (pci_fifo_emptyn = '0' ) then
                visual_1_tw_mr_sm <= "00100";
                tw_mr_cmd_req <= '1';
              else
                visual_1_tw_mr_sm <= "00010";
              end if ;
            end if ;
          end if ;
        when "00100" =>
          --  Send Request State
          --  In this state cmd ack signal is checked.
          --  Once cmdack is asserted it also checks whether the current transfer is the last transfer
          --  by checking the target signals(target operation), master signals (master operation)
          --  and abort signals(master read abort)
          --  If last transfer then the last_txfr bit is set, else reset and goes to the Write state
          tw_mr_cmd_req <= '0';
          if cmdack = '1' then
            if (((visual_0_rdusedw_dec0) = '1'  and (target_write = '0' ))) or (
               ((data_cntr_upper_zero) = '1'  and (dma_on_bit) = '1' )) or (((
               abort_wr_lat) = '1'  and (visual_0_rdusedw_dec0) = '1' )) then
              --  end of target write
              --  end of master read
              --  end bcoz of abort_wr
              last_txfr <= '1';
              visual_1_tw_mr_sm <= "01000";
            else
              last_txfr <= '0';
              visual_1_tw_mr_sm <= "01000";
            end if ;
          else
            last_txfr <= '0';
            visual_1_tw_mr_sm <= "00100";
          end if ;
        when "01000" =>
          if (rd_wr_ctrl_cntr_7) = '1'  then
            if last_txfr = '1' and (((((visual_0_rdusedw_zero) = '1'  and (
               low_addr_not_zero) = '1' )) or (low_addr_not_zero = '0' ))) then
              --  Write state
              --  In this state, 8 data transfer is performed and checks for last transfer
              --  If the current transfer is last transfer(which is indicated by last_txfr signal)  and
              --  1. if the lower 3 bit address is not zero and the data to be transferred is less than 8
              --  2. if the lower 3 bit address is zero
              --  then for the above 2 cases it goes to the idle state
              --  else goes to the check next transfer state
              assert_end_wr_txfr <= '1';
              visual_1_tw_mr_sm <= "00001";
              last_txfr <= '0';
            else
              visual_1_tw_mr_sm <= "10000";
            end if ;
          else
            visual_1_tw_mr_sm <= "01000";
          end if ;
        when "10000" =>
          --  Check State
          --  In this state depending on whether the access is target or master access the request signal
          --  to the command state machine is asserted. In this state it will wait for either atleast 8 data
          --  to be written into the fifo(backend) if the data to be transferred is more than 8 quadword or
          --  wait for all the data to be written  into the fifo(backend) if the data to be transferred
          --  is less than 8 quadword when there is no abort_wr signal.But once the abort write is asserted
          --  during a master read then it immediately moves to the send request state inorder to terminate the
          --  transaction
          --  If master read access then the data counter value and rdusedw value is checked and
          --  if target write access then the target write signal and rdusedw value is checked
          --  once the data is available in the fifo(back end interface) this state asserts the request signal
          --  to the command state machine and goes to the send request state
          case dma_on_bit is  --  MASTER
            when '1' =>
              if (data_cntr_upper_zero = '0' ) and (abort_wr_lat = '0' ) then
                if (visual_0_rdusedw_dec0) = '1'  then
                  --  if the data count is more than eight
                  --  quad word & data in fifo(rdusedw) is less than 8
                  visual_1_tw_mr_sm <= "10000";  --  wait in the check state
                else
                  tw_mr_cmd_req <= '1';  --  if data in fifo(indicated by rdusedw) is more than
                  visual_1_tw_mr_sm <= "00100";  --  8 then go to send request state
                end if ;
              else
                if (ext_bcr_zero) = '1'  or (abort_wr_lat) = '1'  then
                  --  else if the data count is less than eight
                  --  quad word and fifo is already written with all or
                  tw_mr_cmd_req <= '1';  --  there is a abort write then go to send request state
                  visual_1_tw_mr_sm <= "00100";
                end if ;
              end if ;
            when '0' =>
              if (target_write) = '1'  then
                if (visual_0_rdusedw_dec0) = '1'  then
                  --  TARGET
                  --  if target_write is asserted and the data in the
                  --  fifo is less than 8 then wait in the check state
                  visual_1_tw_mr_sm <= "10000";
                else
                  tw_mr_cmd_req <= '1';  --  once eight data is written to the fifo then go
                  visual_1_tw_mr_sm <= "00100";  --  to send request state by asserting tw_mr_cmd_req
                end if ;
              else
                --  if target_write is deasserted, then it means that
                --  data has been written into the fifo and hence it
                tw_mr_cmd_req <= '1';  --  goes to the send request state
                visual_1_tw_mr_sm <= "00100";
              end if ;
            when others =>
              null;
          end case  ;
        when others =>
          null;
      end case  ;
    end if ;
  end process ;
 
  probe(4 downto 0) <= visual_1_tw_mr_sm;
  probe(5) <= abort_wr;
  probe(6) <= abort_wr_wod;
  probe(7) <= pci_fifo_emptyn;
 
end ;

