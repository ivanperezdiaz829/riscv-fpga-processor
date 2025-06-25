--------------------------------------------------------------------
--  Altera PCI testbench
--  MODULE NAME: arbiter
--  COMPANY:  Altera Coporation.
--            www.altera.com    

-- FUNCTIONAL DESCRIPTION:
-- This Arbiter gives high priority to device connected to port 0
-- You can park the bus on device 0 by modifying the park to be true
-- in the top level file.

--  REVISION HISTORY:  
--	Revision 4.1.0: Corrected several issues to prevent bus contention.
--					Cleaned up the unused ports.
--  Revision 1.1 Description: No change.
--  Revision 1.0 Description: Initial Release.
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
use ieee.std_logic_arith.all;   

entity arbiter is
   generic(park : boolean := false);
   port (
      clk           : in std_logic;   
      rstn          : in std_logic;
      
     
      busfree       : in std_logic;     
         
      pci_reqn      : in std_logic_vector(1 downto 0);   
      pci_gntn      : out std_logic_vector(1 downto 0));   
end  arbiter;

architecture behavior of arbiter is


--*********************************************
type state_type is (park_disable,park_enable);
signal state, nxstate : state_type;
-----------------------------------------------


   signal pci_gntn_tie    :  std_logic_vector(1 downto 0);   

begin
   pci_gntn <= pci_gntn_tie;
   
   --*************************************************
   process (clk, rstn, pci_reqn,state)
   --*************************************************
   begin
    
      if (rstn = '0') then
         pci_gntn_tie(0) <= '1';
             
      elsif (clk'event and clk = '1') then
        
         if(state = park_enable or ( pci_reqn(0) = '0' and pci_gntn_tie(1) = '1')) then
           
            pci_gntn_tie(0) <= '0';
         else
           pci_gntn_tie(0) <= '1';   
         end if;
         
     end if;
   end process;

   --*****************************************
   process (clk, rstn,pci_reqn(1),pci_reqn(0),state)
   --*****************************************
   begin
      if (rstn = '0') then
         pci_gntn_tie(1) <= '1';    
      elsif (clk'event and clk = '1') then
         
        if (pci_reqn(1) = '1' or pci_reqn(0) = '0') then
            pci_gntn_tie(1) <= '1';    
         elsif(pci_reqn(0) = '1' and state = park_disable and pci_gntn_tie(0) = '1') then
            pci_gntn_tie(1) <= '0';
         end if;
      end if;
   end process;



 -------------------------------------------------------------------------------------------
--********************************************
--nxstate_generator for park
--********************************************
process (clk,rstn,nxstate)
        begin
        if rstn = '0'  then
          state <= park_disable;
        elsif clk'event and clk = '1' then
          state <= nxstate;
        end if;
end process;

process (state, busfree, pci_reqn)
   begin
     case state is
      when park_disable =>
        if (busfree = '1' and park = true and pci_reqn(1) = '1') then
           nxstate <= park_enable;
        else
           nxstate <= park_disable;
        end if;
        
        
      when park_enable =>
         if pci_reqn(1) = '0' then
          nxstate <= park_disable;
         else
          nxstate <= park_enable;
         end if; 
         
        
       when others =>
           nxstate <= park_disable;   
           
     end case;
        
end process;   
   
     
end behavior;
