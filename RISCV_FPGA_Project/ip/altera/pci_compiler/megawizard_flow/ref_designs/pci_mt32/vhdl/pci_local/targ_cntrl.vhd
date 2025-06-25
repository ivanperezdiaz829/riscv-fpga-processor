--  pci_mt32 Reference Design
--  MODULE NAME: targ_cntrl
--  COMPANY:  Altera Coporation.
--            www.altera.com    

--  FUNCTIONAL DESCRIPTION:
--  This module generates control signals to the pci core when
--  the core is a target in the pci transaction. It also provides the interface
--  signals to the fifo and the sdram

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
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity targ_cntrl is
    Port (
        clk                                     : in std_logic;         -- clock
        rstn                                    : in std_logic;         -- reset
        lt_framen                               : in std_logic;
        lt_dxfrn                                : in std_logic;
        lt_tsr                                  : in std_logic_vector(11 downto 0);
        adr                                     : in std_logic_vector(25 downto 0);     -- target address
        cmd                                     : in std_logic_vector(3 downto 0);      -- target command
        s2p_fifo_usedw                          : in std_logic_vector(6 downto 0);      -- words in the sdram-to-pci fifo
        p2s_fifo_full                           : in std_logic;                         -- pci-to-sdram low fifo full
        sdram_end_txfr                          : in std_logic;                         -- sdram has finish current data access
        
        retry                                   : out std_logic;
        lt_rdy                                  : out std_logic;                        -- local target ready
        targ_rd                                 : out std_logic;                        -- indicate target read cycle to sdram
        targ_wr                                 : out std_logic;                        -- indicate target write cycle to sdram
        p2s_fifo_wrreq                          : out std_logic;                        -- pci-to-sdram low fifo write
        s2p_fifo_rdreq                          : out std_logic;                        -- sdram-to-pci fifo read
        
        dma_reg_cs                              : out std_logic;                        -- dma register chip select
        dma_reg_wen                             : out std_logic;                        -- dma register write enable
        dma_fifo_wen                            : out std_logic;                        -- dma fifo write enable
        isr_rd                                  : out std_logic;                        -- isr register read
        tr_fifo_flush                           : out std_logic                         -- target read fifo flush
       
                                                 
        );

end targ_cntrl;

architecture rtl of targ_cntrl is

constant TW_IDLE                                : std_logic_vector(4 downto 0) := "10000";      -- one hot encoding
constant TW_WAIT                                : std_logic_vector(4 downto 0) := "01000";
constant TW_RDY                                 : std_logic_vector(4 downto 0) := "00100";
constant TW_SDRAM_WAIT                          : std_logic_vector(4 downto 0) := "00010";
constant TW_RETRY                               : std_logic_vector(4 downto 0) := "00001";

constant TR_IDLE                                : std_logic_vector(5 downto 0) := "100000";     -- one hot encoding
constant TR_SDRAM_WAIT                          : std_logic_vector(5 downto 0) := "010000";
constant TR_RDY                                 : std_logic_vector(5 downto 0) := "001000";
constant TR_FLUSH                               : std_logic_vector(5 downto 0) := "000100";
constant TR_DAT_AVAIL                           : std_logic_vector(5 downto 0) := "000010";
constant TR_RETRY                               : std_logic_vector(5 downto 0) := "000001";


signal tw_state                                 : std_logic_vector(4 downto 0);
signal lt_wr_rdy                                : std_logic;
signal targ_mem_wr                              : std_logic;
signal tw_ret                                   : std_logic;
signal lt_framen_fall                           : std_logic;
signal lt_framen_reg                            : std_logic;
signal tw_cmd                                   : std_logic;
signal sdram_hit                                : std_logic;
signal fifo_hit                                 : std_logic;
signal targ_mem_rd                              : std_logic;
signal lt_framen_rise                           : std_logic;
signal tw_sdram_busy                            : std_logic;
signal fifo_hit_reg                             : std_logic;
signal tr_cmd                                   : std_logic;
signal bar0_hit_reg                             : std_logic;
signal tw_adr_reg                               : std_logic_vector(25 downto 0);
signal tr_adr_reg                               : std_logic_vector(25 downto 0);
signal tr_nxt_state                             : std_logic_vector(5 downto 0); 
signal tr_state                                 : std_logic_vector(5 downto 0);
signal lt_rd_rdy                                : std_logic;
signal tr_ret                                   : std_logic;
signal tr_flush_set                             : std_logic;
signal tr_sm_idle                               : std_logic;

signal p2s_fifo_wr                              : std_logic;

signal sdram_cfg_wr                             : std_logic;
signal sdram_cfg_rd                             : std_logic;
signal sdram_config                             : std_logic;
signal dma_reg_access                           : std_logic;
signal sdram_reg_hit                            : std_logic;
signal sdram_reg_access                         : std_logic;
signal tw_sm_idle                               : std_logic;
signal lt_mem_rdy                               : std_logic;
signal lt_dma_rdy                               : std_logic;
signal mem_access                               : std_logic;
signal bar1_hit_reg                             : std_logic;
signal isr_hit                                  : std_logic;



begin


-- lt_framen edge detection
process(clk,rstn) 
  begin
    if(rstn='0') then
      lt_framen_reg <= '0';
    elsif(clk'event and clk='1') then
      lt_framen_reg <= lt_framen;
    end if;
  end process;
  
lt_framen_rise <= not lt_framen_reg and lt_framen;
lt_framen_fall <= lt_framen_reg and not lt_framen;

-- target command decode

tw_cmd <= '1' when (cmd = "111")                 -- target write when command is 7 HEX
                else '0';
                
tr_cmd <= '1' when (cmd = "110")                 -- target read when command is 6 HEX
                else '0';

-- sdram memory hit decode
sdram_hit <= lt_tsr(1);                 -- bar1 is assigned to sdram memory

-- dma fifo hit detect
fifo_hit <= lt_tsr(0)  and adr(19);     -- upper half of the mem space reserved by bar0 is assigned to dma fifo

--target write sdram busy signal generation with SRFF
process(clk, rstn)                      -- this signal indicates that the sdram is busy writing
begin
  if(rstn='0') then
    tw_sdram_busy <= '0';
  elsif(clk'event and clk='1') then
    if(tw_sm_idle='1' and lt_framen_fall='1' and tw_cmd='1' and sdram_hit='1') then     -- set when at IDLE and detect
      tw_sdram_busy <= '1';                                                     -- a target write to sdram
    elsif(sdram_end_txfr='1') then              -- reset when sdram is done with current access
      tw_sdram_busy <= '0';
    end if;
  end if;
end process;

-- latch the address for target write 
process(clk,rstn)
begin
  if(rstn='0') then
    tw_adr_reg <= (others => '0');
  elsif(clk'event and clk='1') then
    if(tw_sm_idle='1') then                     -- latch the address at target write state machine idle
      tw_adr_reg <= adr;
    end if;
  end if;
end process;


-- register bar0_hit
process(clk,rstn) 
  begin
    if(rstn='0') then
      bar0_hit_reg <= '0';
    elsif(clk'event and clk='1') then
      bar0_hit_reg <= lt_tsr(0);
    end if;
  end process;
-- registered version of fifo_hit ( dma fifo hit)

fifo_hit_reg <= bar0_hit_reg and tw_adr_reg(19);        -- bar0 and std_logic 19 of the address to indicate that the upper half 
                                                        -- of the bar0 mem is accessed


-- target write state machine to generate the ready signal to the PCI core 
-- and the target write/read cycle to the sdram controller

process(clk, rstn)
  begin
    if (rstn='0') then
      tw_state <= TW_IDLE;
    elsif(clk'event and clk='1') then
    
        case tw_state is
        when TW_IDLE    =>
          if (lt_framen_fall='1' and tw_cmd='1' and (sdram_hit='1' or fifo_hit='1') and targ_mem_rd='0') then   -- trigger the write state machine 
            tw_state <= TW_WAIT;                   
          else
            tw_state <= TW_IDLE;
          end if;
          
        when TW_RDY     =>                                      -- ready to receive data to the FIFO
          if (p2s_fifo_full='1') then                           -- fifo full, enter wait state          
            tw_state <= TW_WAIT;
          elsif (lt_framen_rise='1') then                       -- end of target write, wait for all data to be written to sdram
            tw_state <= TW_SDRAM_WAIT;
          else
            tw_state <= TW_RDY;
          end if;
        
        when TW_WAIT    =>                                      -- wait state when FIFO is full or initial wait state
          if(p2s_fifo_full='1') then                            -- fifo full, enter wait state
            tw_state <= TW_WAIT;
          else
            tw_state <= TW_RDY;
          end if;
          
        when TW_SDRAM_WAIT      =>                             -- wait for completion of writing all data from the FIFO to SDRAM
          if(lt_framen_fall='1' and (sdram_hit='1' or fifo_hit='1') ) then      -- target access while sdram is busy, go to retry
            tw_state <= TW_RETRY;
          elsif (tw_sdram_busy='0' or fifo_hit_reg='1') then -- sdram not busy or dma fifo access
            tw_state <= TW_IDLE;
          else
            tw_state <= TW_SDRAM_WAIT;
          end if;
          
          when TW_RETRY =>                                     -- retry any target access while sdram is busy
            IF(lt_framen_fall='1' and (sdram_hit='1' or fifo_hit='1')) THEN     -- target access while sdram is busy, stay in retry
              tw_state <= TW_RETRY;
            else
              tw_state <= TW_SDRAM_WAIT;
            end if;
            
          when OTHERS   =>
            tw_state <= TW_IDLE;
         
        end case;
  end if;
  end process;
  
        lt_wr_rdy <= tw_state(2);                            -- assert lt_rdyn
        targ_mem_wr <= tw_state(2) or tw_state(3);           -- indicates target memory write in prgress 
        tw_ret <= tw_state(0);                               -- retry due to sdram busy
        tw_sm_idle <= tw_state(4);                           -- target write state machine idle
        
  
  
--=============================== Target Read State Machine =======================================================

process(clk,rstn)
begin
  if(rstn='0') then
    tr_state <= TR_IDLE;
  elsif(clk'event and clk='1') then
    tr_state <= tr_nxt_state;
  end if;
end process;

process(tr_state, lt_framen_fall, tr_cmd, sdram_hit, tw_sdram_busy, adr, tr_adr_reg, lt_framen_rise, s2p_fifo_usedw)
  begin 
        case tr_state is

        when TR_IDLE    =>
          if(lt_framen_fall='1' and tr_cmd='1' and sdram_hit='1' and tw_sdram_busy='0') then 
          -- memory target write detected and sdram is not busy from the last target write.
          -- if sdram is not busy then this state machine can proceed to the next state
            tr_nxt_state <= TR_RETRY;   -- retry since the sdram takes more than 16 clocks to get the first data from SDRAM
          else                          
            tr_nxt_state <= TR_IDLE;
          end if;

        when TR_RETRY   =>           -- target retry since data is not available in the FIFO
          if(lt_framen_fall='1' and tr_cmd='1' and sdram_hit='1') then
            tr_nxt_state <= TR_RETRY;           -- stay in retry if target read access since data is not available
          else
            tr_nxt_state <= TR_SDRAM_WAIT;              -- wait for sdram to get the first data
          end if;

        when TR_SDRAM_WAIT      =>                 
          if(lt_framen_fall='1' and sdram_hit='1') then
            tr_nxt_state <= TR_RETRY;           -- while waiting for data, any target access will be retried
          elsif(s2p_fifo_usedw >= 32) then      -- 16 DWORDs in the FIFO
            tr_nxt_state <= TR_DAT_AVAIL;               -- there is data in the fifo
          else
            tr_nxt_state <= TR_SDRAM_WAIT;      
          end if;
        
        when TR_DAT_AVAIL       =>              -- data available in the FIFO
          if(lt_framen_fall='1' and tr_cmd='1' and (adr=tr_adr_reg)) then
            tr_nxt_state <= TR_RDY;                     -- only accept the target read to the same address of the first retry
          elsif(lt_framen_fall='1' and sdram_hit='1') then
            tr_nxt_state <= TR_RETRY;           -- retry sdram access but allow target access other than sdram
          else
            tr_nxt_state <= TR_DAT_AVAIL;               -- stay in this state to wait for the right target access
          end if;
        
        when TR_RDY     =>
          if(lt_framen_rise='1') then
            tr_nxt_state <= TR_FLUSH;           -- end target read, flush the fifo
          else
            tr_nxt_state <= TR_RDY;                     -- this assumes that the sdram is fast enough to continue
          end if;                               -- to provide data to the fifo before the fifo is emptied 
                                                -- by the PCI read. for slower sdram, the TR_WAIT state is needed!
        when TR_FLUSH   =>
          tr_nxt_state <= TR_IDLE;
        
        when OTHERS     =>    
          tr_nxt_state <= TR_IDLE;
        
        end case;
end process;

lt_rd_rdy <= tr_state(3);                                 -- assert lt_rdyn
tr_ret <= tr_state(0);                                    -- assert lt_discn for retry
targ_mem_rd <= not tr_state(5) and not tr_state(2);       -- target memory read in progress
tr_flush_set <= tr_state(2);                              -- set the FIFO flush when transaction is completed
tr_sm_idle <= tr_state(5);                                -- state machine is idle

-- Latch the address in order to accept the target read to the same address that was retried earlier (delayed transaction)

process(clk,rstn)
begin
  if(rstn='0') then
    tr_adr_reg <= (others => '0');
  elsif(clk'event and clk='1') then
    if(tr_sm_idle='1') then                     -- latch the address at target read state machine idle
      tr_adr_reg <= adr;
    end if;
  end if;
end process;    

lt_mem_rdy <= lt_rd_rdy or lt_wr_rdy;

lt_dma_rdy <= not lt_framen_reg;

mem_access <= sdram_hit or fifo_hit;

process(clk,rstn)       -- registered mux of the lt_rdy signal for better fmax
begin
  if(rstn='0') then
    lt_rdy <= '0';
  elsif(clk'event and clk='1') then
    lt_rdy <= (lt_mem_rdy and mem_access ) or (lt_dma_rdy and dma_reg_access);
  end if;
end process;
-- muxing targ_rd and targ_wr signals to the sdram controller
-- These signals are used to indicate the duration of the sdram access 
-- for target transaction. It also indicates the sdram configuration register
-- write during sdram initialization

process(clk, rstn)
begin
  if(rstn='0') then
    bar1_hit_reg <= '0';
  elsif(clk'event and clk='1') then
    bar1_hit_reg <= lt_tsr(1);
  end if;
end process;

dma_reg_access <= lt_tsr(0) and not adr(19);    -- dma register access when lower half of the 1MB reserved by bar0 is decoded

-- decode the address when the sdram config reg is accessed (18, 1C, 20 HEX)
sdram_reg_hit <= '1' when (adr(7 downto 0)="00011000" or adr(7 downto 0)="00011100" or adr(7 downto 0)="00100000")
                        else '0';
                        
sdram_config <= (not lt_framen and dma_reg_access and sdram_reg_hit);
sdram_cfg_wr <= tw_cmd  and sdram_config;
sdram_cfg_rd <= tr_cmd and sdram_config;

process(clk,rstn)               -- register the targ_rd , targ_wr signal
begin
  if(rstn='0') then
    targ_wr <= '0';
    targ_rd <= '0';
  elsif(clk'event and clk='1') then
    targ_wr <= targ_mem_wr or sdram_cfg_wr;
    targ_rd <= targ_mem_rd or sdram_cfg_rd;
  end if;
end process;
    
-- retry signal
retry <= tw_ret or tr_ret;


s2p_fifo_rdreq <= tr_cmd and lt_tsr(1) and not lt_dxfrn;
p2s_fifo_wr <= tw_cmd and lt_tsr(1) and not lt_dxfrn;


-- register the pci-to-sdram write request

process(clk, rstn)
begin
  if(rstn='0') then
    p2s_fifo_wrreq <= '0';
  elsif(clk'event and clk='1') then
    p2s_fifo_wrreq <= p2s_fifo_wr;
  end if;
end process;


dma_reg_cs <= dma_reg_access;
dma_reg_wen <= dma_reg_access and not lt_dxfrn and tw_cmd;
dma_fifo_wen <= fifo_hit and not lt_dxfrn and tw_cmd;
isr_rd <= dma_reg_access and not lt_dxfrn and tr_cmd and isr_hit;
isr_hit <= '1' when (adr(4 downto 2)) = "011"
                else '0';       -- address = 0C


-- target read fifo flush

process(clk,rstn)
begin
  if(rstn='0') then
    tr_fifo_flush <= '0';
  elsif(clk'event and clk='1') then
    if(tr_flush_set='1') then
      tr_fifo_flush <= '1';                     -- flush when state machine at flush state (end of target read)
    elsif(sdram_end_txfr='1') then
      tr_fifo_flush <= '0';                     -- remove flush when sdram controller stops writting to fifo
    end if;
  end if;
end process;
    
           
end rtl;
















