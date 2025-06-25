
--  pci_mt64 Reference Design
--  MODULE NAME:  mstr_fifo_cntrl
--  COMPANY:  Altera Coporation.
--            www.altera.com    

--  FUNCTIONAL DESCRIPTION:
-- This module contains the master transaction fifo interface to the back-end logic
-- in case of the master read, it controls the write signals to the pci2dram fifo, and
-- for master write, it controls the read signal of the sdram2pci fifo. 

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

entity mstr_fifo_cntrl is
    Port (
        clk                     : in std_logic;         -- clock
        rstn                    : in std_logic;         -- reset
        bcr_zero                : in std_logic;         -- the byte counter has counted down to zero
        lm_dxfrn                : in std_logic;         -- data transfer on the local side
        wr_rdn                  : in std_logic;         
        l_ldat_ackn             : in std_logic;         -- low dword is transferred on the local side
        l_hdat_ackn             : in std_logic;         -- high dword is transferred on the local side
        lm_tsr                  : in std_logic_vector(9 downto 0);
        single_cycle_reg        : in std_logic;
        
        
        p2s_lfifo_wr            : buffer std_logic;     -- pci2sdram low fifo write signal (master read)
        p2s_hfifo_wr            : buffer std_logic;     -- pci2sdram high fifo write signal (master read)
        s2p_fifo_rdreq          : out std_logic;        -- sdram2pci fifo read request (master write)  
        ldat_msk                : out std_logic; --   master read low dword byte enable used to mask the 
                                                                    --   invalid dword before writting qword data to the sdram
        hdat_msk                : out std_logic  --   master read high byte enable used to mask the 
                                                                    --   invalid dword before writting qword data to the sdram                                     
        );
        
end mstr_fifo_cntrl;

architecture rtl of mstr_fifo_cntrl is

  constant      IDLE                    : std_logic_vector(3 downto 0) := "1000";       -- one hot encoding
  constant      FIFO_WR                 : std_logic_vector(3 downto 0) := "0100";
  constant      END_MR                  : std_logic_vector(3 downto 0) := "0010";
  constant      HDAT_DUMMY_WRITE        : std_logic_vector(3 downto 0) := "0001";

  signal        p2s_lfifo_wrreq_int     : std_logic;
  signal        p2s_hfifo_wrreq_int     : std_logic;
  signal        hdat_ben                : std_logic;
  signal        odd_data_num            : std_logic;
  signal        p2s_32_lfifo_wrreq      : std_logic;    
  signal        p2s_32_hfifo_wrreq      : std_logic;
  signal        hdat_dummy_wr           : std_logic;
  signal        lm_tsr3_reg             : std_logic;
  signal        lm_tsr3_rise            : std_logic;
  signal        mem_mwr64               : std_logic;
  signal        bcr_zero_reg            : std_logic;
  signal        mem_mwr32               : std_logic;
  signal        odd_even_cntr           : std_logic_vector(1 downto 0);
  signal        mr_fifo_state           : std_logic_vector(3 downto 0);
  signal        mr_fifo_nxt_state       : std_logic_vector(3 downto 0);
  signal        lm_tsr3_fall            : std_logic;
 
  
  
begin
        
-- pci2sdram fifo write enable generation active high
-- during the master read operation, the pci2sdram fifo is written with the data 
-- transferred from the CPI bus to the local side interface.

p2s_lfifo_wrreq_int <= not wr_rdn and not lm_dxfrn and not l_ldat_ackn;
        
p2s_hfifo_wrreq_int <= not wr_rdn and not lm_dxfrn and not l_hdat_ackn;
        

-- 2-std_logic counter to keep track of odd or even number of DWORD's written to the FIFO's
-- this is used when the target is 32-std_logic. The control logic write the mask to the lower or upper 32-std_logic data
-- written into sdram accordingly. 

process(clk,rstn)
begin
  if(rstn='0') then
    odd_even_cntr <= "00";
  elsif(clk'event and clk='1') then
    if(lm_tsr3_rise='1') then
      odd_even_cntr <= "00";
    elsif (p2s_hfifo_wr='1' or p2s_lfifo_wr='1') then -- count when fifo write
      odd_even_cntr <= odd_even_cntr + 1;
    end if;
  end if;
end process;

odd_data_num <= odd_even_cntr(0);       -- odd number of dwords is written into the pci2sdram fifo

-- Detect rising edge of lm_tsr3 (data phase on PCI bus)

process(clk,rstn)
begin
  if(rstn='0') then
    lm_tsr3_reg <= '0';
  elsif(clk'event and clk='1') then
    lm_tsr3_reg <= lm_tsr(3);
  end if;
end process;

lm_tsr3_rise <= lm_tsr(3) and not lm_tsr3_reg;
lm_tsr3_fall <= not lm_tsr(3) and lm_tsr3_reg;

-- register bcr_zero

process(clk,rstn)
begin
  if(rstn='0') then
    bcr_zero_reg <= '0';
  elsif(clk'event and clk='1') then
    bcr_zero_reg <=  bcr_zero;
  end if;
end process;


-- master read fifo interface state machine
make_mr_fifo_state : process (clk, rstn)
  begin
    if rstn ='0' then
      mr_fifo_state <= IDLE;                
    elsif (clk'event and clk='1') then
      mr_fifo_state <= mr_fifo_nxt_state;
    end if;
end process;

process(mr_fifo_state, lm_tsr3_rise, lm_tsr3_fall, odd_data_num)
  begin
        case mr_fifo_state is
        
        when IDLE       =>
          if(lm_tsr3_rise='1') then     -- data phase has started on the PCI bus
            mr_fifo_nxt_state <= FIFO_WR;
          else
            mr_fifo_nxt_state <= IDLE;
          end if;

        when FIFO_WR    =>              -- normal fifo write
          if(lm_tsr3_fall='1') then     -- end of read cycle
            mr_fifo_nxt_state <= END_MR;
          else
            mr_fifo_nxt_state <= FIFO_WR;
          end if;
          
        when END_MR     =>              -- end normal fifo write
          if(odd_data_num='1') THEN
            mr_fifo_nxt_state <= HDAT_DUMMY_WRITE;
          else
            mr_fifo_nxt_state <= IDLE;
          end if;
          
        when HDAT_DUMMY_WRITE   =>      -- mask upper 32-std_logic data before written into sdram
          mr_fifo_nxt_state <= IDLE;
         
        when OTHERS             =>
          mr_fifo_nxt_state <= IDLE;
          
        end case;
end process;

hdat_dummy_wr <= mr_fifo_state(0);
hdat_ben <=  mr_fifo_state(0);

-- master read fifo write request for 32-std_logic target transfer
p2s_32_lfifo_wrreq <= p2s_lfifo_wrreq_int; 
p2s_32_hfifo_wrreq <= p2s_hfifo_wrreq_int or hdat_dummy_wr; -- write hi fifo with valid data or dummymy data 

-- mux out master read request for both 32 and 64-std_logic transfer
-- memory 64-std_logic transaction
process(clk,rstn) 
begin
  if(rstn='0') then
    mem_mwr64 <= '0';
  elsif(clk'event and clk='1') then
    if(lm_tsr(9)='1') then  -- 64-std_logic transaction, set when 64 std_logic transfer
      mem_mwr64 <= '1';
    elsif(lm_tsr3_rise='1') then  -- reset at the begining of transfer
      mem_mwr64 <= '0';
    end if;
  end if;
end process;

mem_mwr32 <= not mem_mwr64;  -- memory 32-std_logic transaction

-- muxing logic
process(mem_mwr32, p2s_32_lfifo_wrreq, p2s_32_hfifo_wrreq, p2s_lfifo_wrreq_int, p2s_hfifo_wrreq_int, hdat_ben)
begin
  case mem_mwr32 is
    when '1'    => -- 32 std_logic transfer, mask the last upper 32-std_logic if meccessary
      p2s_lfifo_wr <= p2s_32_lfifo_wrreq;
      p2s_hfifo_wr <= p2s_32_hfifo_wrreq;
      ldat_msk <= '0';
      hdat_msk <= hdat_ben;
    
    when others => -- 64 std_logic transfer, dont use mask
      p2s_lfifo_wr <= p2s_lfifo_wrreq_int;
      p2s_hfifo_wr <= p2s_hfifo_wrreq_int;
      ldat_msk <= '0';
      hdat_msk <= '0';
    end case;
end process;

-- sdram2pci fifo read request for master write
-- do not read when doing single 64-std_logic data
-- the data is showing ahead at the output of the fifo
-- otherwise read when local tranfer occurs
s2p_fifo_rdreq <= wr_rdn and not lm_dxfrn and not single_cycle_reg; 




  

end rtl;






