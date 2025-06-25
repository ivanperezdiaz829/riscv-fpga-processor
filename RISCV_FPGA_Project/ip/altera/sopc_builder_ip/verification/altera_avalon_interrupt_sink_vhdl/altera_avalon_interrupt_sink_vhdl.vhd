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

library work;
use work.all;
use work.altera_avalon_interrupt_sink_vhdl_pkg.all;

entity altera_avalon_interrupt_sink_vhdl is
   generic (
      ASSERT_HIGH_IRQ            : integer := 1;
      AV_IRQ_W                   : integer := 1;
      ASYNCHRONOUS_INTERRUPT     : integer := 0;
      VHDL_ID                    : integer := 0
   );
   port (
      clk                        : in std_logic;
      reset                      : in std_logic;
      irq                        : in std_logic_vector (AV_IRQ_W - 1 downto 0)
   );
end altera_avalon_interrupt_sink_vhdl;

architecture irq_sink_bfm_vhdl_a of altera_avalon_interrupt_sink_vhdl is 

   component altera_avalon_interrupt_sink_vhdl_wrapper
      generic (
         ASSERT_HIGH_IRQ         : integer := 1;
         AV_IRQ_W                : integer := 1;
         ASYNCHRONOUS_INTERRUPT  : integer := 0
      );
      port (
         clk                     : in std_logic;
         reset                   : in std_logic;
         irq                     : in std_logic_vector (AV_IRQ_W - 1 downto 0);
         -- VHDL request interface
         req                     : in std_logic_vector (IRQ_SINK_CLEAR_IRQ downto 0);
         ack                     : out std_logic_vector (IRQ_SINK_CLEAR_IRQ downto 0);         
         data_out0               : out integer
      );
   end component;
   
   -- VHDL request interface
   signal req                    : std_logic_vector (IRQ_SINK_CLEAR_IRQ downto 0);
   signal ack                    : std_logic_vector (IRQ_SINK_CLEAR_IRQ downto 0);         
   signal data_out0              : integer;
   
   begin
   
   req                           <= req_if(VHDL_ID).req;
   ack_if(VHDL_ID).ack           <= ack;
   ack_if(VHDL_ID).data_out0     <= data_out0;
   
   irq_sink_vhdl_wrapper : altera_avalon_interrupt_sink_vhdl_wrapper
      generic map (
         ASSERT_HIGH_IRQ         => ASSERT_HIGH_IRQ,
         AV_IRQ_W                => AV_IRQ_W,
         ASYNCHRONOUS_INTERRUPT  => ASYNCHRONOUS_INTERRUPT
      )
      port map (
         clk                     => clk,
         reset                   => reset,
         irq                     => irq,      
         req                     => req,
         ack                     => ack,
         data_out0               => data_out0
      );

end irq_sink_bfm_vhdl_a;