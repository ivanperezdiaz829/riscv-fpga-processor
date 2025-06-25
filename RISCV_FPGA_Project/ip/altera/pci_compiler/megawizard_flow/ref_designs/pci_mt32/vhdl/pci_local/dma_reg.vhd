
--  pci_mt32 Reference Design
--  MODULE NAME:  dma_reg
--  COMPANY:  Altera Coporation.
--            www.altera.com    

--  FUNCTIONAL DESCRIPTION:
--  This module consists of all the DMA registers and it read and
--  write control logic. These registers are byte count register, address count 
--  register, control and status register, interrupt ans status register, and 
--  local address register.

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

entity dma_reg is
    Port (
        clk                        : in std_logic;                               -- clock
        rstn                       : in std_logic;                               -- reset
        adr                        : in std_logic_vector(7 downto 0);            -- address of the register to be accessed
        dati                       : in std_logic_vector(31 downto 0);           -- data input to the register
        wen                        : in std_logic;                               -- write enable to the register
        acr_ld                     : in std_logic;                               -- load acr in chaining mode
        bcr_ld                     : in std_logic;                               -- load bcr in chaining mode
        acr_cnten                  : in std_logic;                               -- address counter count enable
        lar_cnten                  : in std_logic;                               -- local address counter count enable
        bcr_cnten                  : in std_logic;                               -- byte counter count enable
        isr_in                     : in std_logic_vector(5 downto 0);            -- set signal for the interrupt status register      
        dma_on                     : in std_logic;                               -- indicate dma is in progress, input to csr(6)
        cs                         : in std_logic;                               -- chip select
        acr                        : out std_logic_vector(31 downto 0);          -- address counter
        bcr                        : out std_logic_vector(16 downto 0);          -- byte counter
        csr                        : out std_logic_vector(8 downto 0);           -- control and status register
        isr                        : out std_logic_vector(5 downto 0);           -- interrupt status register
        lar                        : out std_logic_vector(25 downto 0);          -- local address register
        dato                       : out std_logic_vector(31 downto 0);          -- data outputs from the DMA registers
        dma_reg_hit                : out std_logic_vector(4 downto 0)
        
                                                    
        );
        
end dma_reg;

architecture rtl of dma_reg is


signal acr_cnt                    : std_logic_vector(29 downto 0);
signal acr_wen                    : std_logic;
signal lar_cnt                    : std_logic_vector(22 downto 0);
signal lar_wen                    : std_logic;
signal bcr_cnt                    : std_logic_vector(14 downto 0);
signal bcr_wen                    : std_logic;
signal isr_wen                    : std_logic;
signal csr_wen                    : std_logic;
signal flush                      : std_logic;
signal csr_reg                    : std_logic_vector(8 downto 0);
signal isr_reg                    : std_logic_vector(5 downto 0);
signal reg_hit                    : std_logic_vector(4 downto 0);
signal csr_hit                    : std_logic;
signal acr_hit                    : std_logic;
signal bcr_hit                    : std_logic;
signal isr_hit                    : std_logic;
signal lar_hit                    : std_logic;
signal rd_mux_sel                 : std_logic_vector(1 downto 0);                                       
signal mux_sel_reg                : std_logic_vector(1 downto 0);
signal mux_out                    : std_logic_vector(31 downto 0);
signal mux_out_reg                : std_logic_vector(31 downto 0);



begin
        
        
        
-- address counter (dma_acr)
-- this counter holds the PCI address of the current
-- master trasaction and is incremented every time there is a successful
-- data transfer on the PCI bus
make_acr: process(clk, rstn)
             begin
               if(rstn='0') then
                 acr_cnt    <= (others => '0'); 
               elsif(clk'event and clk='1') then
                   if (acr_ld = '1' or acr_wen = '1') then      -- write from pci bus or from dma fifo
                     acr_cnt <= dati(31 downto 2);           
                   elsif(acr_cnten = '1') then
                     acr_cnt <= acr_cnt + 1;
                   end if;
               end if;
             end process;

-- local address counter
-- this counter holds the starting address of the 
-- sdram module where the SDRAM access occurs. It is incremented
-- when data transfer occurs on the PCI bus
make_lar: process(clk, rstn)
             begin
               if(rstn='0') then
                 lar_cnt    <= (others => '0'); 
               elsif(clk'event and clk='1') then
                   if lar_wen = '1' then
                     lar_cnt <= dati(24 downto 2);           
                   elsif(lar_cnten = '1') then
                     lar_cnt <= lar_cnt + 1;
                   end if;
               end if;
             end process;


-- byte counter
-- this counters holds the transfer count of the current master
-- transaction. It is incremented decremented when there is a
-- successful data transfer on the PCI bus

make_bcr: process(clk, rstn)
             begin
               if(rstn='0') then
                 bcr_cnt    <= (others => '0'); 
               elsif(clk'event and clk='1') then
                   if (bcr_ld = '1' or bcr_wen = '1') then      -- write from pci bus or from dma fifo
                     bcr_cnt <= dati(16 downto 2);           
                   elsif(bcr_cnten = '1') then
                     bcr_cnt <= bcr_cnt - 1;
                   end if;
               end if;
             end process;

-- control status registers (dma_csr)
-- This register contains the control and status information
-- of the current DMA transaction

make_csr_7_8:   process(clk,rstn)               -- req32, chain_ena
                  begin
                    if(rstn='0') then
                      csr_reg(8 downto 7) <= (others => '0');
                    elsif(clk'event and clk='1') then
                      if(csr_wen='1') then
                        csr_reg(8 downto 7) <= dati(8 downto 7);
                      end if;
                    end if;
                end process;





make_csr_6:     process(clk,rstn)               -- dma_on
                  begin
                    if(rstn='0') then
                      csr_reg(6) <= '0';
                    elsif(clk'event and clk='1') then
                      csr_reg(6) <= dma_on;
                    end if;
                end process;
                
make_csr_5_2:   process(clk,rstn)               -- transfer complete interrupt disable, dma enable, write, local reset
                  begin
                    if(rstn='0') then
                      csr_reg(5 downto 2) <= (others => '0');
                    elsif(clk'event and clk='1') then
                      if(csr_wen='1') then
                        csr_reg(5 downto 2) <= dati(5 downto 2);
                      end if;
                    end if;
                end process;

flush <= csr_wen and dati(1);   -- flush
make_csr_1:     process(clk,rstn)
                  begin
                    if(rstn='0') then
                      csr_reg(1) <= '0';
                    elsif(clk'event and clk='1') then
                      csr_reg(1) <= flush;
                    end if;
                end process;


make_csr_0:     process(clk,rstn)               -- interrupt enable
                  begin
                    if(rstn='0') then
                      csr_reg(0) <=  '0';
                    elsif(clk'event and clk='1') then
                      if(csr_wen='1') then
                        csr_reg(0) <= dati(0);
                      end if;
                    end if;
                end process;


-- interupt status registers
-- This register contains the interrupt status of the
-- current DMA transaction

make_isr:       process(clk,rstn)
                  begin
                    if(rstn='0') then
                      isr_reg <= (others => '0');
                    elsif(clk'event and clk='1') then
                      isr_reg <= isr_in;
                    end if;
                end process;


-- register write enable logic
-- this logic decode the address of the 
-- DMA register access to determine what DMA register is being accessed

process(adr) -- this is pci address std_logics 4:2, 2 LSB std_logics tied to GND
  begin
    case adr(7 downto 0) is
      when "00000000"   =>      reg_hit <= "00001";                -- 00 Hex (CSR)
      when "00000100"   =>      reg_hit <= "00010";                -- 04 Hex (ACR)      
      when "00001000"   =>      reg_hit <= "00100";                -- 08 Hex (BCR)
      when "00001100"   =>      reg_hit <= "01000";                -- 0C Hex (ISR)
      when "00010000"   =>      reg_hit <= "10000";                -- 10 Hex (LAR)
      
      when others       =>      reg_hit <= "00000";
    end case;
  end process; 
     

        csr_hit         <= cs and reg_hit(0);   -- cs indicate BAR0 and the lower half of 1MB memory is accessed (std_logic 19 ='0')
        acr_hit         <= cs and reg_hit(1);
        bcr_hit         <= cs and reg_hit(2);
        isr_hit         <= cs and reg_hit(3);
        lar_hit         <= cs and reg_hit(4);

        csr_wen         <= csr_hit and wen;    -- wen = !lt_dxfrn and write cycle (wr_rdn = '1')
        acr_wen         <= acr_hit and wen;    -- wen indicates that there is a data transfer from the PCI core to the
        bcr_wen         <= bcr_hit and wen;    -- local side and the command is write (7)
        isr_wen         <= isr_hit and wen;
        lar_wen         <= lar_hit and wen;
        
-- register read logic
-- This is the read mux selects decode logic that decodes the select 
-- signal of the read mux based on the address.


  
  rd_mux_sel <= adr(3 downto 2);
  
  
  
  process(clk, rstn)            -- register mux select signal
begin
  if(rstn='0') then
    mux_sel_reg <= (others => '0');
  elsif(clk'event and clk='1') then
    mux_sel_reg <= rd_mux_sel;
  end if;
end process;

process(mux_sel_reg, csr_reg, bcr_cnt, acr_cnt, isr_reg)
  begin
    case mux_sel_reg is
      when "00" =>
        mux_out <= ("00000000000000000000000" & csr_reg);
      when "01" =>
        mux_out <= (acr_cnt & "00");
      when "10" => 
        mux_out <= ("000000000000000" & bcr_cnt & "00");
      when "11" =>
        mux_out <= ("00000000000000000000000000" & isr_reg);
      when OTHERS =>
        mux_out <= (others => '0');
      end case;
   end process;
   
   
      
      


-- register mux output
process(clk, rstn)              
begin
  if(rstn='0') then
    mux_out_reg <= (others => '0');
  elsif(clk'event and clk='1') then
    mux_out_reg <= mux_out;
  end if;
end process;


-- assign outputs

dato <= mux_out_reg;
csr <= csr_reg;
isr <= isr_reg;
bcr <= ( bcr_cnt & "00");
acr <= ( acr_cnt & "00");
lar <= ( lar_cnt & "000");

dma_reg_hit <= reg_hit;

end rtl;
