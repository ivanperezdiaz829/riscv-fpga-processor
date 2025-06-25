
--  pci_mt64 Reference Design
--  MODULE NAME: targ_fifo_cntrl
--  COMPANY:  Altera Coporation.
--            www.altera.com    

--  FUNCTIONAL DESCRIPTION:
--  Target FIFO control module. This module controls the reading of
--  of the sdram-to-pci fifo during the target read and writting of the pci-to-sdram
--  fifo during target write. it also generates the mask std_logics for invalid data dword
--  during target write when there is qword un-aligned data transfer      

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

entity targ_fifo_cntrl is
    Port (
        clk                     : in std_logic;         
        rstn                    : in std_logic;
        lt_framen_fall          : in std_logic;                        -- lt_framen assertion
        lt_framen               : in std_logic;                         
        tw_cmd                  : in std_logic;                        -- target write command decoded
        tr_cmd                  : in std_logic;                        -- target read command decoded
        sdram_hit               : in std_logic;                        -- sdram hit when bar1 is hit
        adr                     : in std_logic_vector(7 downto 0);     -- address for dma register access
        tw_sdram_busy           : in std_logic;                        -- sdram busy reading the fifo
        lt_dxfrn                : in std_logic;                        
        l_ldat_ackn             : in std_logic;                        -- low dword transferred to the local side
        l_hdat_ackn             : in std_logic;                        -- high dword transferred to the local side
        lt_tsr7                 : in std_logic;                        -- 64-std_logic target transaction indicator
        tw_idle                 : in std_logic;
        ldat_msk                : out std_logic;                       -- low dword data mask
        hdat_msk                : out std_logic;                       -- high dword data mask
        p2s_lfifo_wr            : out std_logic;                       -- pci-to-sdram low dword fifo write
        p2s_hfifo_wr            : out std_logic;                       -- pci-to-sdram high dword fifo write
        s2p_fifo_rdreq          : out std_logic                        -- sdram-to-pci fifo read
       
        
                    
           );
end targ_fifo_cntrl;

architecture rtl of targ_fifo_cntrl is

-- One hot encoding
  constant IDLE                 : std_logic_vector(5 downto 0) := "100000";     -- IDLE 
  constant LDAT_DUMP_WR         : std_logic_vector(5 downto 0) := "010000";     -- Low dword dumpmy write ( mark invalid low dword)
  constant FIFO_WR              : std_logic_vector(5 downto 0) := "001000";     -- normal fifo write (target write)
  constant END_TW               : std_logic_vector(5 downto 0) := "000100";     -- target write has ended
  constant HDAT_DUMP_WR         : std_logic_vector(5 downto 0) := "000010";     -- high dword dumpmy write ( mark invalid high dword)
  constant DONE_TW              : std_logic_vector(5 downto 0) := "000001";     -- target write done
  
  signal   tw_fifo_state        : std_logic_vector(5 downto 0);
  signal   qword_adr            : std_logic;
  signal   odd_data_num         : std_logic;
  signal   adr_reg              : std_logic_vector(7 downto 0);
  signal   lmsk                 : std_logic;
  signal   hmsk                 : std_logic;
  signal   lmsk_wr              : std_logic;
  signal   hmsk_wr              : std_logic;
  signal   trans64              : std_logic;
  signal   trans32              : std_logic;
  signal   odd_even_cntr        : std_logic_vector(1 downto 0);
  signal   done_tw_sig          : std_logic;
  signal   p2s_32_lfifo_wr      : std_logic;
  signal   p2s_32_hfifo_wr      : std_logic;
  signal   p2s_lfifo_wrreq_int  : std_logic;
  signal   p2s_hfifo_wrreq_int  : std_logic;
  
  
  begin


-- State machine that generate the masking std_logics for 32-std_logic target write transaction
-- with the data mis-aligned with 64-std_logic boundary. For example, if the target write
-- started at odd dword address(4,C) then the first low dword data has to be masked
-- since the local side is 64-std_logic interface. Also in this cas if the total number of
-- dword is even, the last valid dword will reside in the low dword fifo, therfore
-- the last high dword has be be mask to avoid being written into the SDRAM




process (clk, rstn)
  begin
    if rstn ='0' then
      tw_fifo_state <= IDLE;
                
    elsif (clk'event and clk='1') then
       case tw_fifo_state is
        
       when IDLE        =>      
          if(lt_framen_fall='1' and tw_cmd='1' and sdram_hit='1' and qword_adr='1' and tw_sdram_busy='0' and tw_idle='1') then
             tw_fifo_state <= FIFO_WR;  -- target write at qword aligned address, go to normal fifo write
          elsif(lt_framen_fall='1' and tw_cmd='1' and sdram_hit='1' and qword_adr='0' and tw_sdram_busy='0' and tw_idle='1') then
             tw_fifo_state <= LDAT_DUMP_WR; -- write ate odd dword address, need to mask to low dword
          else
             tw_fifo_state <= IDLE;
          end if;

       when LDAT_DUMP_WR        =>              
          tw_fifo_state <= FIFO_WR;     -- goto normal write after writting the low dword mask
        
       when FIFO_WR     =>
          if(lt_framen='1') then                -- framen deasserted, end of target write
       tw_fifo_state <= END_TW;
          else
       tw_fifo_state <= FIFO_WR;
          end if;
        
        when END_TW     => 
                -- if the total dword is odd and starting address is qword aligned or 
                -- the total dword is even and startin address is qword mis-aligned
                -- we need to write a mask std_logic to the high fifo
           if((odd_data_num='1' and adr_reg(2)='0') or (odd_data_num='0' and  adr_reg(2)='1')) then
              tw_fifo_state <= HDAT_DUMP_WR;
           else
              tw_fifo_state <= DONE_TW;
           end if;
         
        when HDAT_DUMP_WR       =>
            tw_fifo_state <= DONE_TW;
        
        when DONE_TW            =>
           tw_fifo_state <= IDLE;
        
        when OTHERS     =>
           tw_fifo_state <= IDLE;
        end case;
        
end if;

end process;


-- state machine output assignment
lmsk_wr <= tw_fifo_state(4);
lmsk <= tw_fifO_state(4);
hmsk_wr <= tw_fifo_state(1);
hmsk <= tw_fifo_state(1);
done_tw_sig <= tw_fifo_state(0);

-- 2-std_logic counter to keeps track of odd or even number of dword written to the pci-to-sdram fifo

process(clk,rstn)
begin
  if(rstn='0') then
    odd_even_cntr <= "00";
  elsif(clk'event and clk='1') then
    if(lt_framen_fall='1') then
      odd_even_cntr <= "00";
    elsif(p2s_lfifo_wrreq_int='1' or p2s_hfifo_wrreq_int='1') then -- count when data transfer written into fifo
      odd_even_cntr <= odd_even_cntr + 1;
    end if;
  end if;
end process;

odd_data_num <= odd_even_cntr(0);       -- even=0, odd=1

-- decode adr for qwords address boundary

process(clk,rstn) 
begin
  if(rstn='0') then
    adr_reg <= "00000000";
  elsif(clk'event and clk='1') then
    if(lt_framen_fall='1') then                 -- latch address at lt_framen falling edge
      adr_reg <= adr;
    end if;
  end if;
end process;

qword_adr <= not adr(2) ; -- this indicates that the address is qword

--- generating pci2sdram fifo write request

p2s_lfifo_wrreq_int <= tw_cmd and sdram_hit and not lt_dxfrn and not l_ldat_ackn;
        
p2s_hfifo_wrreq_int <= tw_cmd and sdram_hit and not lt_dxfrn and not l_hdat_ackn;

 -- target write fifo write request for 32-std_logic target transaction
 
p2s_32_lfifo_wr <= p2s_lfifo_wrreq_int or lmsk_wr; -- write low fifo with valid data or masked data 
p2s_32_hfifo_wr <= p2s_hfifo_wrreq_int or hmsk_wr; -- write hi fifo with valid data or masked data 
        
-- trans64 signal generation with SRFF

process(clk,rstn) 
begin
  if(rstn='0') then
    trans64 <= '0';
  elsif(clk'event and clk='1') then
    if(lt_tsr7='1') then        -- set when trans64 std_logic is set
      trans64 <= '1';   
    elsif(done_tw_sig='1') then -- reset when target write is done
      trans64 <= '0';
    end if;
  end if;

end process;

trans32 <= not trans64; -- 32-std_logic transaction used as the mux select for the fifo write request

-- mux the fifo write request

process(trans32, p2s_32_lfifo_wr, p2s_32_hfifo_wr, p2s_lfifo_wrreq_int, p2s_hfifo_wrreq_int)
begin
  case trans32 is
    when '1' =>         -- 32-std_logic target transaction
      p2s_lfifo_wr <= p2s_32_lfifo_wr;  
      p2s_hfifo_wr <= p2s_32_hfifo_wr;
    when others =>      -- 64 std_logic target transaction
      p2s_lfifo_wr <= p2s_lfifo_wrreq_int;
      p2s_hfifo_wr <= p2s_hfifo_wrreq_int;
    end case;
end process;

-- data mask std_logics for 32-std_logic transacton 

hdat_msk <= trans32 and hmsk;
ldat_msk <= trans32 and lmsk;

-- sdram-to-pci fifo read
s2p_fifo_rdreq <= tr_cmd and sdram_hit and not lt_dxfrn;

end rtl;






