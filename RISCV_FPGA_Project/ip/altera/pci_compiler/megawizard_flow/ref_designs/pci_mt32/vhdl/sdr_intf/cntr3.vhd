--------------------------------------------------------------------
--  pci_mt32 Reference Design
--  MODULE NAME: cntr3
--  COMPANY:  Altera Coporation.
--            www.altera.com    


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
 
 
entity cntr3 is
  port (
        clr : in STD_LOGIC;
        synclr : in STD_LOGIC;
        clken : in STD_LOGIC;
        clk : in STD_LOGIC;
        q : out STD_LOGIC_VECTOR (2 downto 0);
        tc : out STD_LOGIC
        );
end cntr3;
 
architecture cntr3 of cntr3 is
  signal visual_0_q : STD_LOGIC_VECTOR(2 downto 0 );--    ----- created for output, which is read or nets with declaration delay .
 
 
  --   reg [3:0]        q;
  signal c_q : STD_LOGIC_VECTOR(2 downto 0 );
  signal n_q : STD_LOGIC_VECTOR(2 downto 0 );
begin
 
  q <= visual_0_q;
 
  --  functional part
  process (clk, clr)
 
  begin
    if (clr = '0' ) then
      c_q <= "000";
                           --  if (!clr)
    elsif (clk'event and clk = '1' ) then
      c_q <= n_q;
                           --  else: !if(clken)
    end if ;
                           --  always @ (posedge aclk or negdge clr)
  end process ;
 
  process (c_q, synclr, clken)
 
  begin
    n_q <= c_q;
    if (synclr) = '1'  then
      n_q <= "000";
                           --  else: !if(!clr)
    else
      if (clken) = '1'  then
        n_q <= ext(ext(c_q,32) + 1,abs(2-0)+1);
                           --  else: !if(!clken)
      else
        n_q <= c_q;
                           --  else: !if(!clr
      end if ;
    end if ;
                           --  always @ (c_q or synclr or load or clken )
  end process ;
 
  visual_0_q <= c_q;
  tc <= '1' when (ext(visual_0_q,32) = "00000000000000000000000000001111") else '0'
    ;
  --  q
 
end ;

