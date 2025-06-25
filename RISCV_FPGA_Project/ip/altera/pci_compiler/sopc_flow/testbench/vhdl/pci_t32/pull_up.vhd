--------------------------------------------------------------------
--  Altera PCI testbench
--  MODULE NAME: pull_up
--  COMPANY:  Altera Coporation.
--            www.altera.com    

--  FUNCTIONAL DESCRIPTION:
--  This file provides a weak pullup on the PCI signals.

--  REVISION HISTORY:  
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

entity pull_up is

    port(ad      : out std_logic_vector(31 downto 0);
         cben    : out std_logic_vector(3 downto 0);
         par     : out std_logic;
         framen  : out std_logic;
         irdyn   : out std_logic;
         devseln : out std_logic;
         trdyn   : out std_logic; 
         stopn   : out std_logic; 
         perrn   : out std_logic;
         serrn   : out std_logic;
         intan   : out std_logic);

end pull_up;
         
architecture behavior of pull_up is
             
begin
        
         ad <= (others => 'H');
         cben <= (others => 'H');
         par <= 'H';
         framen  <= 'H';
         irdyn   <= 'H';
         devseln <= 'H';
         trdyn   <= 'H'; 
         stopn   <= 'H'; 
         perrn   <= 'H';
         serrn   <= 'H';
         intan   <= 'H';
         
    
end behavior;
