-------------------------------------------------------------------------------
-- lm_lastn_final_64.vhd
-- Generates lm_lastn - 64bit version
-- *******************************************
-- need to remove lm_rdyn logic - currently commented
-- 
--********************************************
--******
-- Rev 0.1 3/26/04
-- Fixed problems with conversion and verified the logic
-- a) drive reqn
-- b) reset of wr_done_reg when rstn = '0' instead of when rstn = '1'
-- c) Fix the logic for term2
-- *****

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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity last_gen is

  generic (
    width : natural := 10);             -- width of xfr_length

  port (
    lm_lastn      : out std_logic;
    clk           : in  std_logic;          -- clock
    rstn          : in  std_logic;          -- active low reset
    wr_rdn        : in  std_logic;          -- write = 1 and read = 0
    lm_req32n     : in  std_logic;          -- 32-bit request
    lm_req64n     : in  std_logic;          -- 64-bit request
--    lm_adr_ackn   : in std_logic;          
--    lm_rdyn       : out std_logic;
    lm_dxfrn      : in  std_logic;          -- local master data transfer
    l_hdat_ackn   : in  std_logic;          -- local high data acknowledge
    l_ldat_ackn   : in  std_logic;          -- local low data acknowledge
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
end last_gen;

architecture RTL of last_gen is
  signal reqn                  : std_logic;
  signal xfr_one_word_reg      : std_logic;  -- transfer 1 word
  signal xfr_two_words_reg     : std_logic;  -- transfer 2 words
  signal xfr_three_words_reg   : std_logic;  -- transfer 3 words
  signal xfr_64bit_reg         : std_logic;  -- keep track of whether a 64-bit
                                        -- access was requested
  signal cnten                 : std_logic;
  signal local_xfr_cnt         : std_logic_vector(width downto 0);
  signal wr_done_reg           : std_logic;
  signal pci_data_phase_q      : std_logic;
  signal pci_data_phase_rising : std_logic;
  signal rd_done1_reg          : std_logic;
  signal rd_done2_reg          : std_logic;
  signal term1                 : std_logic;
  signal term2                 : std_logic;
  signal term3                 : std_logic;
  signal term4                 : std_logic;
  --- lm_rdyn logic
--  signal lm_adr_ackn_del,
--         cycle,
--         lm_rdynt              : std_logic;
begin  -- RTL
-------------------------------------------------------------------------------  
-- decodes for xfr_length for 1 word, 2 words and 3 words
-------------------------------------------------------------------------------
  reqn <= lm_req64n and lm_req32n;
  
  process (clk, rstn)
  begin  -- process
    if (rstn = '0') then                -- asynchronous reset (active low)
      xfr_one_word_reg        <= '0';
      xfr_two_words_reg       <= '0';
      xfr_three_words_reg     <= '0';
      xfr_64bit_reg           <= '0';
    elsif (clk'event and clk = '1') then  -- rising clock edge
      if (abnormal_term = '1') then
        xfr_one_word_reg      <= '0';
        xfr_two_words_reg     <= '0';
        xfr_three_words_reg   <= '0';
        xfr_64bit_reg         <= '0';
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
        xfr_64bit_reg <= not lm_req64n;
      end if;  -- reqn = '0'
    end if;  -- rising edge of clock
  end process;
-------------------------------------------------------------------------------
-- local transfer counter
-------------------------------------------------------------------------------
  cnten                       <= (not lm_dxfrn) and
            (wr_rdn or                  -- writes
             (not wr_rdn and
              (not xfr_64bit_reg or     -- 32-bit request and transfer
               (xfr_64bit_reg and lm_tsr(9)) or  -- 64-bit request and transfer
               ((xfr_64bit_reg and not lm_tsr(9))  -- 64-bit request and
                and not l_hdat_ackn))));  -- 32-bit transfer

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
-- wire wr_lm_lastn = !((local_xfr_cnt == 1) & !lm_dxfrn);
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
-- lm last for reads needs to consider 4 different cases
-- 1) Signle transfer = !(xfr_one_word_reg & !lm_dxfrn)
-- 2) 2 WORD transfer = !(xfr_two_words_reg & rising edge of lm_tsr[3])
-- 3) Greater than 2 WORD Transfer = !((local_xfr_cnt == 'h3) &
-- !lm_dxfrn);
-- 4) For 64-bit->32bit transfers we need to consider the following
-- expression
-- !(!l_hdat_ackn & !lm_tsr[9] & !lm_dxfrn)&
-- (local_xfr_cnt == 'h2));
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
-- !(!l_hdat_ackn & !lm_tsr[9] & !lm_dxfrn)&
-- (local_xfr_cnt == 'h2));
-------------------------------------------------------------------------------
-- 32-bit request and transfer or 64-bit request and transfer
-- rd_done2_reg is set when local_xfr_cnt = 4 or when
-- xfr_three_words_reg is active
  term1            <= '1' when ((xfr_64bit_reg = '0' or (xfr_64bit_reg = '1' and lm_tsr(9) = '1')) and
                                ((local_xfr_cnt = 4 and lm_dxfrn = '0') or
                                 (local_xfr_cnt = 3 and xfr_three_words_reg = '1')))
                      else '0';
-- 64 bit request and 32-bit transfer
-- rd_done2_reg is set when local_xfr_cnt = 2 and
-- l_ldat_ackn is active
  term2            <= '1' when ((xfr_64bit_reg = '1' and lm_tsr(9) = '0') and
                                (local_xfr_cnt = 2 and l_ldat_ackn = '0' and lm_dxfrn = '0') )
                      else '0';
-- reset for term1
  term3            <= '1' when ((xfr_64bit_reg = '0' or (xfr_64bit_reg = '1' and lm_tsr(9) = '1')) and
                                (local_xfr_cnt = 3 and lm_dxfrn = '0'))
                      else '0';
-- reset for term2
  term4            <= '1' when ((xfr_64bit_reg = '1' and lm_tsr(9) = '0') and
                                (local_xfr_cnt = 2 and lm_dxfrn = '0' and l_hdat_ackn = '0'))
                      else '0';

  process (clk, rstn)
  begin
    if (rstn = '0') then
      rd_done2_reg     <= '0';
    elsif (clk'event and clk = '1') then
      if (not rd_done2_reg = '1') then
        rd_done2_reg   <= not wr_rdn and (term1 or term2);
      else
        if ((term3 or term4) = '1') then
          rd_done2_reg <= '0';
        end if;
      end if;
    end if;
  end process;

  lm_lastn <= not (rd_done1_reg or (not lm_dxfrn and (wr_done_reg or rd_done2_reg)));

-------------------------------------------------------------------------------
-- lm_rdyn logic 
-------------------------------------------------------------------------------
--   process (clk)
--   begin  -- process
--     if (clk'event and clk = '1') then    -- rising clock edge
--       lm_adr_ackn_del <= lm_adr_ackn;
--     end if;
--   end process;

--   process (clk, rstn)
--     begin
--       if (rstn = '0') then
--         cycle <= '0';
--       elsif (clk'event and clk = '1') then
--         if ((local_xfr_cnt = 1 and lm_dxfrn = '0' and wr_rdn = '1') or
--             (xfr_one_word_reg = '1' and lm_adr_ackn_del = '0') ) then
--           cycle <= '0';
--         elsif (reqn = '0') then
--           cycle <= '1';
--         end if;
--       end if;
--     end process;
--     process (clk,rstn)
--       begin
--         if (rstn = '0') then
--           lm_rdynt <= '1';
--         elsif (clk'event and clk = '1') then
--           lm_rdynt <= lm_tsr(2) or lm_tsr(3) or not lm_adr_ackn;
--         end if;
--       end process;
      
--     lm_rdyn <= not ((lm_rdynt and  not wr_rdn) or
--                 (lm_rdynt and cycle and wr_rdn));
end RTL;


