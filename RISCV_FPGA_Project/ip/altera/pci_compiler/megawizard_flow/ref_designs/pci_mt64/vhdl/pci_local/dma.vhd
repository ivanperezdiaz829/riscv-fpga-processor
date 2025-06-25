
--  pci_mt64 Reference Design
--  MODULE NAME:  dma
--  COMPANY:  Altera Coporation.
--            www.altera.com    

--  FUNCTIONAL DESCRIPTION:
--  This module is the DMA engine that includes the dma registers ,  
--  descriptor fifo, and control logic       

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
use work.components.all;


entity dma is

 Port (
      clk                     : in std_logic;                     -- clock
      rstn                    : in std_logic;                     -- reset
      start                   : in std_logic;                     -- trigger state machine
      dati                    : in std_logic_vector(31 downto 0); -- data input
      adr                     : in std_logic_vector(7 downto 0);  -- address of the dma register
      reg_wen                 : in std_logic;                     -- dma register write enable
      fifo_wen                : in std_logic;                     -- dma fifo write enable
      wr_rdn                  : in std_logic;                     -- write/read signal to dma registers
      cs                      : in std_logic;                     -- chip select (dma_register)
      bcr_cnten               : in std_logic;                     -- byte counter count enable
      acr_cnten               : in std_logic;                     -- address counter count enable
      lar_cnten               : in std_logic;                     -- local address counter count enable
      p2s_fifo_empty          : in std_logic;                     -- high and low p2s both empty
      s2p_fifo_usedw          : in std_logic_vector(6 downto 0);                
      mstr_busy               : in std_logic;
      stop                    : in std_logic;                     -- PCI core signals stop current dma
      abort                   : in std_logic;                     -- PCI core signals abort current dma
      last_xfr                : in std_logic;                     -- PCI core signals last transfer
      local_busy              : in std_logic;                     -- sdram is busy
      err_pend                : in std_logic;                     -- target abort, parity error, master abort
      lm_tsr                  : in std_logic_vector(9 downto 0);  -- master status std_logics
      isr_rd                  : in std_logic;                     -- isr read signal 
   
      isr                     : out std_logic_vector(5 downto 0);
      csr                     : out std_logic_vector(8 downto 0);
      bcr                     : out std_logic_vector(16 downto 0);
      acr                     : out std_logic_vector(31 downto 0);
      lar                     : out std_logic_vector(25 downto 0);
      req                     : out std_logic;                     -- dma requesting a PCI core for data transfer
      local_start             : out std_logic;                     -- dma requesting sdram controller to start data transfer
      dato                    : out std_logic_vector(63 downto 0);  -- dma register read data output   
      probe                   : out std_logic_vector(7 downto 0)    
        );
        
end dma;

architecture rtl of dma is

signal normal_termination     : std_logic;
signal start_chain            : std_logic;
signal chain_end              : std_logic;
signal dma_bcr                : std_logic_vector(16 downto 0);
signal dma_csr                : std_logic_vector(8 downto 0);
signal dma_done               : std_logic;
signal dma_error              : std_logic;
signal chain_acr_ld           : std_logic;
signal chain_bcr_ld           : std_logic;
signal dma_fifo_rd            : std_logic;
signal trans64                : std_logic;      
signal isr_in                 : std_logic_vector(5 downto 0);
signal dma_on                 : std_logic;
signal dma_acr                : std_logic_vector(31 downto 0);
signal dma_isr                : std_logic_vector(5 downto 0);
signal dma_lar                : std_logic_vector(25 downto 0);
signal dma_fifo_dato          : std_logic_vector(31 downto 0);
signal soft_flush             : std_logic;
signal dma_reg_dati           : std_logic_vector(31 downto 0);
signal reg_dat_sel            : std_logic;
signal direction              : std_logic;
signal acr_wr                 : std_logic;
signal csr_wr                 : std_logic;
signal csr_wr_reg             : std_logic;
signal int_irq                : std_logic;
signal local_irq              : std_logic;
signal rst                    : std_logic;
signal req_int                : std_logic; 
signal high                   : std_logic;
signal dma_reg_hit            : std_logic_vector(4 downto 0);

        
begin
   high <= '1';
   rst          <= not rstn;
   soft_flush   <= dma_csr(1);          -- flush std_logic of the control status register       
   start_chain  <= dma_isr(5);          -- DMA chaining mode enable
   direction    <= dma_csr(3);          -- 1 for write, 0 for read
        
-- interrupt pending std_logic
   isr_in(0)    <= err_pend or int_irq or (dma_isr(3) and not dma_csr(5));      
   int_irq      <= local_irq;
   
-- assert local irq when there is error pending or DMA has completed
   local_irq    <= dma_isr(1) or (dma_isr(3) and not dma_csr(5));
   isr_in(1)    <= err_pend;
        
   isr_in(2)    <= int_irq;
        

-- generate transfer complete status std_logic 3

   process(dma_done, isr_rd, csr_wr, acr_wr, dma_isr)   -- dma_tc
      begin
         if(dma_done = '1') then
            isr_in(3) <= '1';
         elsif(isr_rd = '1' or csr_wr = '1' or acr_wr = '1') then
            isr_in(3) <= '0';
         else
            isr_in(3) <= dma_isr(3);
         end if;
      end process;
         
-- write signal to the address counter
   acr_wr <= dma_reg_hit(1) and cs and reg_wen;

-- generate ad_loaded singal for the isr std_logic 4
   process(acr_wr, dma_isr, soft_flush, dma_done, dma_error)
      begin
         if(acr_wr = '1') then
            isr_in(4) <= '1';
         elsif(dma_isr(3) = '1' or soft_flush = '1' or dma_done = '1' or dma_error = '1') then
            isr_in(4) <= '0';
         else
            isr_in(4) <= dma_isr(4);
         end if;
      end process;
          
-- control status register write signal  
   csr_wr <= dma_reg_hit(0) and cs and reg_wen;
   
   process(clk,rstn)                    -- register csr_wr
      begin
         if(rstn='0') then
            csr_wr_reg <= '0';
         elsif(clk'event and clk = '1') then
            csr_wr_reg <= csr_wr;
         end if;
      end process;
        
-- generate start_chain std_logic
   process(csr_wr_reg, dma_isr, dma_csr, soft_flush, dma_done, dma_error)
      begin
         if (csr_wr_reg = '1' and dma_csr(8) = '1') then                -- start chain
            isr_in(5) <= '1';
         elsif (dma_isr(3) = '1' or soft_flush = '1' or dma_done = '1' or dma_error ='1') then
            isr_in(5) <= '0';
         else
            isr_in(5) <= dma_isr(5);
         end if;
      end process;
  
  
  
  -- generate dma_on std_logic csr(6)
  
   dma_on <= (dma_isr(4) and dma_csr(4) and not err_pend) or (isr_in(5) and dma_csr(4) and  not err_pend);


-- dma state machine instantiation
dma_sm0 : dma_sm

port map (
      clk                       =>      clk,
      rstn                      =>      rstn,
      normal_termination        =>      normal_termination,             
      stop                      =>      stop,                           
      lm_tsr                    =>      lm_tsr,                 
      err_pend                  =>      err_pend,               
      start                     =>      start   ,                       
      start_chain               =>      start_chain,                    
      chain_end                 =>      chain_end,                      
      p2s_fifo_empty            =>      p2s_fifo_empty,                 
      s2p_fifo_usedw            =>      s2p_fifo_usedw,                 
      direction                 =>      direction,                                      
      dma_bcr                   =>      dma_bcr,                                
      local_busy                =>      local_busy,                     
      req                       =>      req_int,                                
      dma_done                  =>      dma_done,                       
      dma_error                 =>      dma_error,                      
      chain_acr_ld              =>      chain_acr_ld,                   
      chain_bcr_ld              =>      chain_bcr_ld,                   
      dma_fifo_rd               =>      dma_fifo_rd,                    
      local_start               =>      local_start,    
      chain_dma_loading         =>      reg_dat_sel
     
           );
                


-- DMA registers instantiation
   dma_reg0 : dma_reg
   
   port map (   
      clk                       =>      clk     ,                       
      rstn                      =>      rstn     ,                      
      adr                       =>      adr     ,                       
      dati                      =>      dma_reg_dati    ,       -- mux output select between dati and dma_fifo_dato                             
      dato_64                   =>      high,                           
      wen                       =>      reg_wen ,                               
      acr_ld                    =>      chain_acr_ld    ,                               
      bcr_ld                    =>      chain_bcr_ld    ,                               
      acr_cnten                 =>      acr_cnten,                              
      lar_cnten                 =>      lar_cnten,                              
      bcr_cnten                 =>      bcr_cnten,                              
      isr_in                    =>      isr_in  ,                                               
      dma_on                    =>      dma_on  ,                                       
      cs                        =>      cs,                                     
      acr                       =>      dma_acr ,                               
      bcr                       =>      dma_bcr ,                                       
      csr                       =>      dma_csr ,                                       
      isr                       =>      dma_isr ,                               
      lar                       =>      dma_lar ,                               
      dato                      =>      dato,
      dma_reg_hit               =>      dma_reg_hit                     
            );
                
                
-- chain descriptor fifo instantiation

dma_fifo : fifo_256x32
      
       PORT MAP (
           rdreq => dma_fifo_rd,
           aclr =>   rst,
           sclr => soft_flush,         
           clock => clk,
           wrreq => fifo_wen,data => dati,
           empty => chain_end,
           q => dma_fifo_dato
           
           );

-- muxing data input to dma register
-- data comes from the pci side or the descriptor
process(reg_dat_sel, dati, dma_fifo_dato)
  begin
    case (reg_dat_sel) is
      when '1' =>
        dma_reg_dati <= dma_fifo_dato;  -- descriptor fifo for chaining DMA 
      when OTHERS =>
        dma_reg_dati <= dati;
    end case;
end process;

-- set normal termination when lm_lastn has asserted

req <= req_int;
process(clk,rstn)
begin
  if(rstn='0') then
    normal_termination <= '0';
  elsif(clk'event and clk='1') then
    if(last_xfr='1') then
      normal_termination <= '1';        -- set when lm_last
    elsif(req_int='1') then
      normal_termination <= '0';        -- reset when request
    end if;
  end if;
end process;
        
                
-- assign outputs

bcr <= dma_bcr;
acr <= dma_acr;
lar <= dma_lar;
csr <= dma_csr;
isr <= dma_isr;


end rtl;
























