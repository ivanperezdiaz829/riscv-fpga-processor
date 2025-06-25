--  pci_mt64 Reference Design
--  MODULE NAME:  cnten
--  COMPANY:  Altera Coporation.
--            www.altera.com    

--  FUNCTIONAL DESCRIPTION:
--  This module generates the count enable of the DMA counters

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

entity cnten is
    Port (
        clk                                     : in std_logic;         -- clock
        rstn                                    : in std_logic;         -- reset
        pci_dxfr                                : in std_logic;         -- data transfer on the pci bus
        lm_dxfrn                                : in std_logic;
        l_hdat_ackn                             : in std_logic;
        wr_rdn                                  : in std_logic;
        abrt_rd                                 : in std_logic;
        lm_req32                                : in std_logic;
        lm_req64                                : in std_logic;
        grant                                   : in std_logic;
        single_cycle_reg                        : in std_logic;
        bcr_zero                                : in std_logic;
  
        trans64                                 : in std_logic;
        data_phase                              : in std_logic;
                
        bcr_cnten                               : out std_logic;
        acr_cnten                               : buffer std_logic;
        lar_cnten                               : out std_logic  
        );
end cnten;

architecture rtl of cnten is

signal  lpci_dxfr_clr           : std_logic;
signal  abrt_rd_reg             : std_logic;            

signal  lpci_dxfr               : std_logic;
signal  mw32_bcr_cnten          : std_logic;
signal  mr_bcr_cnten            : std_logic;
signal  lpci_acr_dxfr           : std_logic;
signal  mw32_acr_cnten          : std_logic;

begin
 
 --======================BCR count enable==============================================
process(clk,rstn)                       -- register abrt_rd signal
  begin
    if(rstn='0') then
      abrt_rd_reg <= '0';
    elsif(clk'event and clk='1') then
      if(abrt_rd='1') then
        abrt_rd_reg <= '1';     -- set abort read
      elsif(lm_req64='1' or lm_req32='1') then
        abrt_rd_reg <= '0';     -- reset at request
      end if;
    end if;
  end process;
  
   
process(clk,rstn)       -- low dword pci transfer TFF clear signal (this signal is generated with SRFF)
  begin                 
    if(rstn='0') then
      lpci_dxfr_clr <= '0';
    elsif(clk'event and clk='1') then
      if((abrt_rd_reg = '1' and data_phase='0') or lm_req64='1' or lm_req32='1') then
        lpci_dxfr_clr <= '1';
      elsif(grant='1') then
        lpci_dxfr_clr <= '0';
      end if;
    end if;
  end process;
  
process(clk,lpci_dxfr_clr)      -- toggle flip flop to indicate the low dword has been transferred on the pci bus
  begin
    if(lpci_dxfr_clr='1') then
      lpci_dxfr <= '0';
    elsif(clk'event and clk='1') then
      if(pci_dxfr='1') then
        lpci_dxfr <= not lpci_dxfr;
      end if;
    end if;
  end process;
  
    
mw32_bcr_cnten <= lpci_dxfr and pci_dxfr; -- 32-std_logic master write bcr count enable; count every two tranfers on pci bus

mr_bcr_cnten <= (not lm_dxfrn and not l_hdat_ackn) or (single_cycle_reg and not lm_dxfrn and not bcr_zero) ; -- master read bcr count enable

-- mux the bcr count enable
bcr_cnten <= (wr_rdn and trans64 and pci_dxfr)          -- 64-std_logic master write
        or (wr_rdn and not trans64 and mw32_bcr_cnten)  -- 32-std_logic master write
         or (not wr_rdn and not trans64 and  mr_bcr_cnten)      -- 32-std_logic master read
         or (not wr_rdn and trans64 and not lm_dxfrn);          -- 64 std_logic master read

 
 --===========================ACR count enable===========================================
 
 process(clk,grant)     -- toggle flip flop to indicate the low dword has been transferred on the pci bus
  begin
    if(grant='1') then  -- same as lpci_dxfr except that it's cleared when grant asserted
      lpci_acr_dxfr <= '0';
    elsif(clk'event and clk='1') then
      if(pci_dxfr='1') then
        lpci_acr_dxfr <= not lpci_acr_dxfr;
      end if;
    end if;
  end process;
  
  mw32_acr_cnten <= lpci_acr_dxfr and pci_dxfr; -- counts acr every 2 transfer on the pci bus for 32-std_logic master write
  
  -- mux the acr count enable output
  acr_cnten <=             (wr_rdn and trans64 and pci_dxfr)                    -- 64-std_logic master write
                        or (wr_rdn and not trans64 and mw32_acr_cnten)          -- 32-std_logic master write
                        or (not wr_rdn and pci_dxfr and not l_hdat_ackn);               -- 32/64-std_logic master read
                        
  --=========================LAR count enable=================================================
  
  lar_cnten <= acr_cnten;               -- count the LAR same way as the ACR
  
  
  
end rtl;













