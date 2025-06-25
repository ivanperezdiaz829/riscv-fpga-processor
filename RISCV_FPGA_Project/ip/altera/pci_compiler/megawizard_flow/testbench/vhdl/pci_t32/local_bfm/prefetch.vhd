-- ------------------------------------------------------------------
--   Altera PCI testbench
--   MODULE NAME: prefetch
--   COMPANY:  Altera Coporation.
--             www.altera.com    

--**************************************************************************************
-- FUNCTIONAL DESCRIPTION:
-- This file implements prefetch logic
-- Prefetch Register:
-- Prefetch register is required in this kind of design because
-- inputs to the SRAM are registered, hence there will be a delay of one
-- clock to get the valid data for the give address for example
-- if address(1) is provided in clock x. the SRAM will give the data corresponding
-- to address(1) in clock x+1
-- Hence if there is a successful data transfer on the local side we need to provide the
-- next data immediately.
-- If we fetch data directly from SRAM we cannot provide data immediately because of the
-- registered inputs. hence this design performs the following
-- 1. We prefetch the data and increment the SRAM address
-- 2. Provide the Prefetch data as the first data.
-- 3. Switch to SRAM data as soon as prefetch data is transferred

-- Note that this design is assuming that there will be no wait states from target.
-- If the design has to take target waits into consideration
-- The below given logic will be different.
--**************************************************************************************

--   REVISION HISTORY:  
--   Revision 1.3 Description: Changed the code to make it synthesizable.
--   Revision 1.2 Description: No change.
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity prefetch is
  port (
    Clk                  : in std_logic;                           -- Clock                           
    Rstn                 : in std_logic;                           -- Reset                           
    Prftch_i             : in std_logic;                           -- Prefetch                        
    Sx_data_tx_i         : in std_logic;                           -- Successful Data transfer        
    Trgt_done_i          : in std_logic;                           -- Target Done                     
    Sram_data_i          : in std_logic_vector (31 downto 0);      -- Sram Data                           
    Prftch_o             : out std_logic_vector (31 downto 0)      -- Prefech data output             
   );                                                                                                 
end prefetch;


architecture prefetch_rtl of prefetch is



begin


-- ------------------------------------------
-- Prefetch Register
-- ------------------------------------------

  process (Clk,Rstn)
  begin
    if  ( Rstn = '0' ) then
      Prftch_o <= (others => '0');
    
    elsif(Clk'event and Clk='1') then    
    
      if  ( Trgt_done_i = '1' ) then        
        Prftch_o <= (others => '0');        
      elsif  ( Prftch_i = '1' or  Sx_data_tx_i = '1') then
        Prftch_o <= Sram_data_i ;
      end if;
    
    end if;
  end process;


end prefetch_rtl;
