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

library work;
use work.all;

-- VHDL procedure declarations
package altera_avalon_interrupt_sink_vhdl_pkg is

   -- maximum number of irq sink vhdl bfm
   constant MAX_VHDL_BFM : integer := 1024;
   
   -- irq_sink_vhdl_api_e
   constant IRQ_SINK_GET_IRQ                 : integer := 0;
   constant IRQ_SINK_CLEAR_IRQ               : integer := 1;
   
   -- VHDL API request interface type
   type irq_sink_vhdl_if_base_t is record
      req         : std_logic_vector (IRQ_SINK_CLEAR_IRQ downto 0);
      ack         : std_logic_vector (IRQ_SINK_CLEAR_IRQ downto 0);      
      data_out0   : integer;      
   end record;
   
   type irq_sink_vhdl_if_t is array(MAX_VHDL_BFM - 1 downto 0) of irq_sink_vhdl_if_base_t;
   
   signal req_if           : irq_sink_vhdl_if_t;
   signal ack_if           : irq_sink_vhdl_if_t;
   
   procedure get_irq                   (irq           : out integer;
                                        bfm_id        : in integer;
                                        signal api_if : inout irq_sink_vhdl_if_t);
   
   procedure clear_irq                 (bfm_id        : in integer;
                                        signal api_if : inout irq_sink_vhdl_if_t);

end altera_avalon_interrupt_sink_vhdl_pkg;

package body altera_avalon_interrupt_sink_vhdl_pkg is 

   procedure get_irq                   (irq           : out integer;
                                        bfm_id        : in integer;
                                        signal api_if : inout irq_sink_vhdl_if_t) is
   begin
      api_if(bfm_id).req(IRQ_SINK_GET_IRQ) <= '1';
      wait until (ack_if(bfm_id).ack(IRQ_SINK_GET_IRQ) = '1');
      api_if(bfm_id).req(IRQ_SINK_GET_IRQ) <= '0';
      wait until (ack_if(bfm_id).ack(IRQ_SINK_GET_IRQ) = '0');
      irq := ack_if(bfm_id).data_out0;
   end get_irq;
   
   procedure clear_irq                 (bfm_id        : in integer;
                                        signal api_if : inout irq_sink_vhdl_if_t) is
   begin
      api_if(bfm_id).req(IRQ_SINK_CLEAR_IRQ) <= '1';
      wait until (ack_if(bfm_id).ack(IRQ_SINK_CLEAR_IRQ) = '1');
      api_if(bfm_id).req(IRQ_SINK_CLEAR_IRQ) <= '0';
      wait until (ack_if(bfm_id).ack(IRQ_SINK_CLEAR_IRQ) = '0');
   end clear_irq;

end altera_avalon_interrupt_sink_vhdl_pkg;
