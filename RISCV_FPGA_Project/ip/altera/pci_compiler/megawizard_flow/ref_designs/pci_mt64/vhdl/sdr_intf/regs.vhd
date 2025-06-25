
--  pci_mt64 Reference Design
--  MODULE NAME: regs
--  COMPANY:  Altera Coporation.
--            www.altera.com    

--  FUNCTIONAL DESCRIPTION:
--  This file outputs the data that has to be loaded into
-- ** the address counter which is output as the address to the sdram
-- ** controller during the configuration or load mode reg access

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
use ieee.STD_LOGIC_1164.all;
use ieee.STD_LOGIC_ARITH.all;
use ieee.STD_LOGIC_MISC.all;
use ieee.STD_LOGIC_UNSIGNED.all;
 
 
entity regs is
  port (
        bar0_hit : in STD_LOGIC;
        s_adri : in STD_LOGIC_VECTOR (7 downto 0);
        load_reg_data : out STD_LOGIC_VECTOR(15 downto 0 )
        );
end regs;
 

 
architecture regs of regs is
--  inputs
 
begin
 
  --  cas latency = 3
  --  ras to cas delay = 3
  --  burst length = 8
  --  page mode = normal
  --  refresh cmd duration
  --  Load mode register
  --  burst length = [2:0] = 011(burst length is eight), cas latency = [6:4] = 011(cl is three)
  --  `define load_refresh_count 16'h1562
  --  Load refresh register
  process (bar0_hit, s_adri)
    variable case_var : STD_LOGIC_VECTOR(7 downto 0);
       -- Generated for case statement
 
  begin
    if (bar0_hit) = '1'  then
      case_var := s_adri(7 downto 0) ;
      case case_var is
        when "00011000" =>
          load_reg_data <= "0000000000110011";  --  load mode register in sdram
        when "00011100" =>
          load_reg_data <= STD_LOGIC_VECTOR'("0001000000001111");  --  load register1 in the sdram controller
        when "00100000" =>
          load_reg_data <= "0000001000001000";  --  load register2 in the sdram controller
        when others  =>
          load_reg_data <= "0000000000110011";
      end case  ;
    else
      load_reg_data <= "0000000000110011";
    end if ;
  end process ;
 
 
end ;

