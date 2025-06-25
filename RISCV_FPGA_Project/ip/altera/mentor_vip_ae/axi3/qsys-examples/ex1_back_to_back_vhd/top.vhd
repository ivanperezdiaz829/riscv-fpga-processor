-- *****************************************************************************
--
-- Copyright 2007-2013 Mentor Graphics Corporation
-- All Rights Reserved.
--
-- THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF
-- MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
--
-- *****************************************************************************

library ieee ;
use ieee.std_logic_1164.all;

library work;
use work.all;

entity top is
end top;

architecture top_a of top is

  signal ARESETn : std_logic := '1';
  signal ACLK    : std_logic := '0';

  component master_test_program
   generic (AXI_ADDRESS_WIDTH : integer := 32;
           AXI_RDATA_WIDTH : integer := 1024;
           AXI_WDATA_WIDTH : integer := 1024;
           AXI_ID_WIDTH : integer := 18;
           index : integer range 0 to 511 :=0
          );
  end component;

  component slave_test_program
   generic (AXI_ADDRESS_WIDTH : integer := 32;
           AXI_RDATA_WIDTH : integer := 1024;
           AXI_WDATA_WIDTH : integer := 1024;
           AXI_ID_WIDTH : integer := 18;
           index : integer range 0 to 511 :=0
          );
  end component;

  component monitor_test_program
   generic (AXI_ADDRESS_WIDTH : integer := 32;
           AXI_RDATA_WIDTH : integer := 1024;
           AXI_WDATA_WIDTH : integer := 1024;
           AXI_ID_WIDTH : integer := 18;
           index : integer range 0 to 511 :=0
          );
  end component;

  component ex1_back_to_back_vhd
   port (
            reset_reset_n : in std_logic := '0'; -- reset.reset_n
            clk_clk       : in std_logic := '0'  --   clk.clk
        );
  end component;

begin

mas_test: master_test_program
 generic map(AXI_ADDRESS_WIDTH => 32,
             AXI_RDATA_WIDTH   => 32,
             AXI_WDATA_WIDTH   => 32,
             AXI_ID_WIDTH      => 18,
             index             => 0);

slv_test: slave_test_program
 generic map(AXI_ADDRESS_WIDTH => 32,
             AXI_RDATA_WIDTH   => 32,
             AXI_WDATA_WIDTH   => 32,
             AXI_ID_WIDTH      => 18,
             index             => 1);

mon_test: monitor_test_program
 generic map(AXI_ADDRESS_WIDTH => 32,
             AXI_RDATA_WIDTH   => 32,
             AXI_WDATA_WIDTH   => 32,
             AXI_ID_WIDTH      => 18,
             index             => 2);

dut: ex1_back_to_back_vhd
 port map( reset_reset_n => ARESETn,
           clk_clk => ACLK);

  -- Clock and reset generation 
  process
  begin
    ARESETn <= '1';
    wait for 10 ns;
    ARESETn <= '0';
    wait for 100 ns;
    ARESETn <= '1';
    wait;
  end process;
  
  process
  begin
      ACLK <=  not ACLK;
      wait for 5 ns;
  end process;

end top_a;
