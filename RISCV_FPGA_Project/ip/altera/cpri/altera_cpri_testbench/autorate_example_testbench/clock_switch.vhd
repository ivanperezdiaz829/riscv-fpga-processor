-- (C) 2001-2013 Altera Corporation. All rights reserved.
-- Your use of Altera Corporation's design tools, logic functions and other 
-- software and tools, and its AMPP partner logic functions, and any output 
-- files any of the foregoing (including device programming or simulation 
-- files), and any associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License Subscription 
-- Agreement, Altera MegaCore Function License Agreement, or other applicable 
-- license agreement, including, without limitation, that your use is for the 
-- sole purpose of programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the applicable 
-- agreement for further details.


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity clock_switch is
port (
    -- I/O
    sel    : in  std_logic;
    reset  : in  std_logic;
    clk0   : in  std_logic;
    clk1   : in  std_logic;
    clkout : out std_logic
);
end entity clock_switch;

architecture rtl of clock_switch is

-- Signal declaration
   signal q1        : std_logic:='0';
   signal q2        : std_logic:='0';
   signal q3        : std_logic:='0';
   signal q4        : std_logic:='0';
   signal or_one    : std_logic:='0';
   signal or_two    : std_logic:='0';
   signal or_three  : std_logic:='0';
   signal or_four   : std_logic:='0';
   
begin
  -- Process
   clk_0 : process (clk0 )is
   begin
      if(clk0'event and clk0 ='1') then 
         q1 <= q4;
         q3 <= or_one; 
      end if;
   end process clk_0;

  clk_1 : process (clk1 )is
   begin
      if(clk1'event and clk1 ='1') then 
         q2 <= q3;
         q4 <= or_two; 
      end if;
   end process clk_1;

or_one   <= (not q1) or (not sel);
or_two   <= (not q2) or (sel);
or_three <= (q3) or (clk0);
or_four  <= (q4) or (clk1);
clkout  <= or_three and or_four;

end rtl;
