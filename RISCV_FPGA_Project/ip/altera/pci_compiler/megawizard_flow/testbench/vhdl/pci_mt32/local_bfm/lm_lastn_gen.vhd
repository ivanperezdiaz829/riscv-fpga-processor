-- ------------------------------------------------------------------
--   Altera PCI testbench
--   MODULE NAME: last_gen
--   COMPANY:  Altera Coporation.
--             www.altera.com    

--****************************************************************************
--  FUNCTIONAL DESCRIPTION:
--  This file generates lm_lastn signal
--  Local master last. This signal is driven by the local side to request
--  that the pci_mt64 or pci_mt32 master interface ends the current
--  transaction. When the local side asserts this signal, the PCI
--  MegaCore function master interface deasserts framen as soon as
--  possible and asserts irdyn to indicate that the last data phase has
--  begun. The local side should assert this signal for one clock to initiate
--  completion of Master transaction.
--****************************************************************************

--   REVISION HISTORY:  
--   Revision 1.4 Description: Changed the code to make it modular and simple
--   Revision 1.3 Description: No change
--   Revision 1.1 Description: No change.
--   Revision 1.0 Description: Initial Release.
-- 
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
-----------------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity lm_lastn_gen is

  generic (
    width : natural := 7);             -- width of xfr_length

  port (
    lm_lastn      : out std_logic;
    clk           : in  std_logic;          -- clock
    rstn          : in  std_logic;          -- active low reset
    wr_rdn        : in  std_logic;          -- write = 1 and read = 0
    lm_req32n     : in  std_logic;          -- 32-bit request
    lm_dxfrn      : in  std_logic;          -- local master data transfer
    lm_tsr        : in  std_logic_vector(9 downto 0);
                                            -- local master transaction status register
    xfr_length    : in  std_logic_vector(width downto 0);
                                            -- # of transfers required
    abnormal_term : in  std_logic);         -- Active high signal indicating an
                                            -- abnormal  termination occured. This signal
                                            -- should  indicate that one of the
                                            -- following conditions occured
                                            -- Latency timeout
                                            -- Target Disconnect
                                            -- Target retry
                                            -- Target abort
                                            -- Master abort
end lm_lastn_gen;

architecture RTL of lm_lastn_gen is
-- reqn indicates that a local side request is active and is used for 
-- loading the xfr_length into the local_xfr_cnt and also for setting 
-- the following "xfr_......" registers    
  signal reqn                  : std_logic;
-- Decodes of xfr_length for 1 word, 2 words and 3 words  
  signal xfr_one_word_reg      : std_logic;  -- transfer 1 word
  signal xfr_two_words_reg     : std_logic;  -- transfer 2 words
  signal xfr_three_words_reg   : std_logic;  -- transfer 3 words
-- local transfer counter
  signal cnten                 : std_logic;
  signal local_xfr_cnt         : std_logic_vector(width downto 0);
-- register indicates that local_xfr_cnt = '1' for writes and is held
-- active until local_xfr_cnt = 1 & lm_dxfrn = '0'   
  signal wr_done_reg           : std_logic;
-- pipeline version lm_tsr(3).  
  signal pci_data_phase_q      : std_logic;
  signal pci_data_phase_rising : std_logic;
-- Single transfer and  2 WORD read transfers is generated using the register rd_done1_reg  
  signal rd_done1_reg          : std_logic;
-- Greater than 2 transfer reads is generated using rd_done_2_reg  
  signal rd_done2_reg          : std_logic;
  signal term1                 : std_logic;
  signal term3                 : std_logic;

begin  -- RTL

  reqn <= lm_req32n;
-------------------------------------------------------------------------------  
-- decodes for xfr_length for 1 word, 2 words and 3 words
-------------------------------------------------------------------------------  
  process (clk, rstn)
  begin  -- process
    if (rstn = '0') then                -- asynchronous reset (active low)
      xfr_one_word_reg        <= '0';
      xfr_two_words_reg       <= '0';
      xfr_three_words_reg     <= '0';
    elsif (clk'event and clk = '1') then  -- rising clock edge
      if (abnormal_term = '1') then
        xfr_one_word_reg      <= '0';
        xfr_two_words_reg     <= '0';
        xfr_three_words_reg   <= '0';
      elsif (reqn = '0') then
        if ( xfr_length = 1) then
          xfr_one_word_reg    <= '1';
        else
          xfr_one_word_reg    <= '0';
        end if;
        if ( xfr_length = 2) then
          xfr_two_words_reg   <= '1';
        else
          xfr_two_words_reg   <= '0';
        end if;
        if ( xfr_length = 3) then
          xfr_three_words_reg <= '1';
        else
          xfr_three_words_reg <= '0';
        end if;
      end if;  -- reqn = '0'
    end if;  -- rising edge of clock
  end process;
-------------------------------------------------------------------------------
-- local transfer counter
-------------------------------------------------------------------------------
  cnten                       <= (not lm_dxfrn);

  process (clk, rstn)
  begin
    if ( rstn = '0') then
      local_xfr_cnt       <= (others => '0');
    elsif (clk'event and clk = '1') then
      if (abnormal_term = '1') then     -- sync clear
        local_xfr_cnt     <= (others => '0');
      else
        if (reqn = '0') then            -- load
          local_xfr_cnt   <= xfr_length;
        else
          if (cnten = '1') then         -- count
            local_xfr_cnt <= local_xfr_cnt - 1;
          end if;
        end if;
      end if;
    end if;
  end process;
-------------------------------------------------------------------------------
-- lm last for writes is generated as shown below
-- which is a pipelined version of
--!((local_xfr_cnt == 1) & !lm_dxfrn);
-------------------------------------------------------------------------------
  process (clk, rstn)
  begin
    if (rstn = '0') then
      wr_done_reg         <= '0';
    elsif (clk'event and clk = '1') then
      if (wr_done_reg = '0') then
        if ((local_xfr_cnt = 2) and (lm_dxfrn = '0') and (wr_rdn = '1')) then
          wr_done_reg     <= '1';
        end if;
      elsif ( (local_xfr_cnt = 1) and (xfr_one_word_reg = '1' or lm_dxfrn = '0')) then
        wr_done_reg       <= '0';
      end if;
    end if;  -- rising edge clock
  end process;
-------------------------------------------------------------------------------
-- lm last for reads needs to consider 3 different cases
-- 1) Signle transfer = !(xfr_one_word_reg & !lm_dxfrn)
-- 2) 2 WORD transfer = !(xfr_two_words_reg & rising edge of lm_tsr[3])
-- 3) Greater than 2 WORD Transfer = !((local_xfr_cnt == 'h3) &
-- !lm_dxfrn);
-------------------------------------------------------------------------------
-- generate rising edge of lm_tsr(3)
  process (clk, rstn)
  begin
    if (rstn = '0') then
      pci_data_phase_q    <= '0';
    elsif (clk'event and clk = '1') then
      pci_data_phase_q    <= lm_tsr(3);
    end if;
  end process;
  pci_data_phase_rising   <= lm_tsr(3) and not pci_data_phase_q;

-- First 2 cases i.e. Single transfer and 2 WORD transfer
  process (clk, rstn)
  begin
    if (rstn = '0') then
      rd_done1_reg <= '0';
    elsif (clk'event and clk = '1') then
      rd_done1_reg <= (xfr_one_word_reg and lm_tsr(1)) or  -- single
                                                           -- transfer for reads/writes
                      ((not wr_rdn and xfr_two_words_reg)
                       and pci_data_phase_rising);         -- 2word read
    end if;
  end process;
-------------------------------------------------------------------------------
--Transfer for greater than 2 words is generated using a
--pipelined version of !((local_xfr_cnt == 'h3) & !lm_dxfrn) and
-------------------------------------------------------------------------------
-- 32-bit request and transfer
-- rd_done2_reg is set when local_xfr_cnt = 4 or when
-- xfr_three_words_reg is active
  term1            <= '1' when ((local_xfr_cnt = 4 and lm_dxfrn = '0') or
                                 (local_xfr_cnt = 3 and xfr_three_words_reg = '1'))
                      else '0';
-- reset for term1
  term3            <= '1' when  (local_xfr_cnt = 3 and lm_dxfrn = '0')
                      else '0';

  process (clk, rstn)
  begin
    if (rstn = '0') then
      rd_done2_reg     <= '0';
    elsif (clk'event and clk = '1') then
      if (not rd_done2_reg = '1') then
        rd_done2_reg   <= not wr_rdn and (term1 );
      else
        if (term3  = '1') then
          rd_done2_reg <= '0';
        end if;
      end if;
    end if;
  end process;

  lm_lastn <= not (rd_done1_reg or (not lm_dxfrn and (wr_done_reg or rd_done2_reg)));


end RTL;


