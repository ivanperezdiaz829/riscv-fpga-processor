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
package altera_avalon_st_monitor_vhdl_pkg is

   -- maximum number of Avalon-ST monitor vhdl
   constant MAX_VHDL_BFM : integer := 1024;
   
   -- maximum number of bits in st bfm
   constant ST_MAX_BIT_W : integer := 4096;
   
   -- st_monitor_vhdl_api_e
   constant ST_MONITOR_SET_TRANSACTION_FIFO_MAX          : integer := 0;
   constant ST_MONITOR_GET_TRANSACTION_FIFO_MAX          : integer := 1;
   constant ST_MONITOR_SET_TRANSACTION_FIFO_THRESHOLD    : integer := 2;
   constant ST_MONITOR_GET_TRANSACTION_FIFO_THRESHOLD    : integer := 3;
   constant ST_MONITOR_POP_TRANSACTION                   : integer := 4;
   constant ST_MONITOR_GET_TRANSACTION_IDLES             : integer := 5;
   constant ST_MONITOR_GET_TRANSACTION_DATA              : integer := 6;
   constant ST_MONITOR_GET_TRANSACTION_CHANNEL           : integer := 7;
   constant ST_MONITOR_GET_TRANSACTION_SOP               : integer := 8;
   constant ST_MONITOR_GET_TRANSACTION_EOP               : integer := 9;
   constant ST_MONITOR_GET_TRANSACTION_ERROR             : integer := 10;
   constant ST_MONITOR_GET_TRANSACTION_EMPTY             : integer := 11;
   constant ST_MONITOR_GET_TRANSACTION_QUEUE_SIZE        : integer := 12;
   
   -- st_monitor_vhdl_event_e
   constant ST_MONITOR_EVENT_TRANSACTION_RECEIVED        : integer := 0;
   constant ST_MONITOR_EVENT_TRANSACTION_FIFO_THRESHOLD  : integer := 1;
   constant ST_MONITOR_EVENT_TRANSACTION_FIFO_OVERFLOW   : integer := 2;

   -- VHDL API request interface type
   type st_monitor_vhdl_if_base_t is record
      req         : std_logic_vector (ST_MONITOR_GET_TRANSACTION_QUEUE_SIZE downto 0);
      ack         : std_logic_vector (ST_MONITOR_GET_TRANSACTION_QUEUE_SIZE downto 0);
      data_in0    : integer;
      data_in1    : std_logic_vector (ST_MAX_BIT_W - 1 downto 0);
      data_out0   : integer;
      data_out1   : std_logic_vector (ST_MAX_BIT_W - 1 downto 0);
      events      : std_logic_vector (ST_MONITOR_EVENT_TRANSACTION_FIFO_OVERFLOW downto 0);
   end record;

   type st_monitor_vhdl_if_t is array(MAX_VHDL_BFM - 1 downto 0) of st_monitor_vhdl_if_base_t;
   
   signal req_if           : st_monitor_vhdl_if_t;
   signal ack_if           : st_monitor_vhdl_if_t;
   
   -- convert signal to integer
   function to_integer (OP: STD_LOGIC_VECTOR) return INTEGER;
   
   -- VHDL procedures
   procedure set_transaction_fifo_max          (size          : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t);

   procedure get_transaction_fifo_max          (size          : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t);

   procedure set_transaction_fifo_threshold    (size          : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t);

   procedure get_transaction_fifo_threshold    (size          : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t);

   procedure pop_transaction                   (bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t);

   procedure get_transaction_idles             (cycles        : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t);

   procedure get_transaction_data              (data          : out std_logic_vector (ST_MAX_BIT_W - 1 downto 0);
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t);
   
   procedure get_transaction_data              (data          : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t);

   procedure get_transaction_channel           (channel       : out std_logic_vector (ST_MAX_BIT_W - 1 downto 0);
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t);
                                                
   procedure get_transaction_channel           (channel       : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t);

   procedure get_transaction_sop               (sop           : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t);

   procedure get_transaction_eop               (eop           : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t);

   procedure get_transaction_error             (error         : out std_logic_vector (ST_MAX_BIT_W - 1 downto 0);
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t);
   
   procedure get_transaction_error             (error         : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t);

   procedure get_transaction_empty             (empty         : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t);

   procedure get_transaction_queue_size        (size          : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t);

   -- VHDL events
   procedure event_transaction_received        (bfm_id        : in integer);
   procedure event_transaction_fifo_threshold  (bfm_id        : in integer);
   procedure event_transaction_fifo_overflow   (bfm_id        : in integer);

end altera_avalon_st_monitor_vhdl_pkg;

-- VHDL procedures implementation
package body altera_avalon_st_monitor_vhdl_pkg is

   -- convert to integer
   function to_integer (OP: STD_LOGIC_VECTOR) return INTEGER is
      variable result : INTEGER := 0;
      variable tmp_op : STD_LOGIC_VECTOR (OP'range) := OP;
   begin
      if not (Is_X(OP)) then
         for i in OP'range loop
            if OP(i) = '1' then
               result := result + 2**i;
            end if;
         end loop; 
         return result;
      else
         return 0;
      end if;
   end to_integer;
   
   procedure set_transaction_fifo_max          (size          : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= size;
      api_if(bfm_id).req(ST_MONITOR_SET_TRANSACTION_FIFO_MAX) <= '1';
      wait until (ack_if(bfm_id).ack(ST_MONITOR_SET_TRANSACTION_FIFO_MAX) = '1');
      api_if(bfm_id).req(ST_MONITOR_SET_TRANSACTION_FIFO_MAX) <= '0';
      wait until (ack_if(bfm_id).ack(ST_MONITOR_SET_TRANSACTION_FIFO_MAX) = '0');
   end set_transaction_fifo_max;

   procedure get_transaction_fifo_max          (size          : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(ST_MONITOR_GET_TRANSACTION_FIFO_MAX) <= '1';
      wait until (ack_if(bfm_id).ack(ST_MONITOR_GET_TRANSACTION_FIFO_MAX) = '1');
      api_if(bfm_id).req(ST_MONITOR_GET_TRANSACTION_FIFO_MAX) <= '0';
      wait until (ack_if(bfm_id).ack(ST_MONITOR_GET_TRANSACTION_FIFO_MAX) = '0');
      size := ack_if(bfm_id).data_out0;
   end get_transaction_fifo_max;

   procedure set_transaction_fifo_threshold    (size          : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= size;
      api_if(bfm_id).req(ST_MONITOR_SET_TRANSACTION_FIFO_THRESHOLD) <= '1';
      wait until (ack_if(bfm_id).ack(ST_MONITOR_SET_TRANSACTION_FIFO_THRESHOLD) = '1');
      api_if(bfm_id).req(ST_MONITOR_SET_TRANSACTION_FIFO_THRESHOLD) <= '0';
      wait until (ack_if(bfm_id).ack(ST_MONITOR_SET_TRANSACTION_FIFO_THRESHOLD) = '0');
   end set_transaction_fifo_threshold;

   procedure get_transaction_fifo_threshold    (size          : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(ST_MONITOR_GET_TRANSACTION_FIFO_THRESHOLD) <= '1';
      wait until (ack_if(bfm_id).ack(ST_MONITOR_GET_TRANSACTION_FIFO_THRESHOLD) = '1');
      api_if(bfm_id).req(ST_MONITOR_GET_TRANSACTION_FIFO_THRESHOLD) <= '0';
      wait until (ack_if(bfm_id).ack(ST_MONITOR_GET_TRANSACTION_FIFO_THRESHOLD) = '0');
      size := ack_if(bfm_id).data_out0;
   end get_transaction_fifo_threshold;

   procedure pop_transaction                   (bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(ST_MONITOR_POP_TRANSACTION) <= '1';
      wait until (ack_if(bfm_id).ack(ST_MONITOR_POP_TRANSACTION) = '1');
      api_if(bfm_id).req(ST_MONITOR_POP_TRANSACTION) <= '0';
      wait until (ack_if(bfm_id).ack(ST_MONITOR_POP_TRANSACTION) = '0');
   end pop_transaction;

   procedure get_transaction_idles             (cycles        : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(ST_MONITOR_GET_TRANSACTION_IDLES) <= '1';
      wait until (ack_if(bfm_id).ack(ST_MONITOR_GET_TRANSACTION_IDLES) = '1');
      api_if(bfm_id).req(ST_MONITOR_GET_TRANSACTION_IDLES) <= '0';
      wait until (ack_if(bfm_id).ack(ST_MONITOR_GET_TRANSACTION_IDLES) = '0');
      cycles := ack_if(bfm_id).data_out0;
   end get_transaction_idles;

   procedure get_transaction_data              (data          : out std_logic_vector (ST_MAX_BIT_W - 1 downto 0);
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(ST_MONITOR_GET_TRANSACTION_DATA) <= '1';
      wait until (ack_if(bfm_id).ack(ST_MONITOR_GET_TRANSACTION_DATA) = '1');
      api_if(bfm_id).req(ST_MONITOR_GET_TRANSACTION_DATA) <= '0';
      wait until (ack_if(bfm_id).ack(ST_MONITOR_GET_TRANSACTION_DATA) = '0');
      data := ack_if(bfm_id).data_out1;
   end get_transaction_data;
   
   procedure get_transaction_data              (data          : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t) is
      
      variable data_temp   : std_logic_vector (ST_MAX_BIT_W - 1 downto 0);
   begin
      get_transaction_data(data_temp, bfm_id, api_if);
      data := to_integer(data_temp);
   end get_transaction_data;

   procedure get_transaction_channel           (channel       : out std_logic_vector (ST_MAX_BIT_W - 1 downto 0);
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(ST_MONITOR_GET_TRANSACTION_CHANNEL) <= '1';
      wait until (ack_if(bfm_id).ack(ST_MONITOR_GET_TRANSACTION_CHANNEL) = '1');
      api_if(bfm_id).req(ST_MONITOR_GET_TRANSACTION_CHANNEL) <= '0';
      wait until (ack_if(bfm_id).ack(ST_MONITOR_GET_TRANSACTION_CHANNEL) = '0');
      channel := ack_if(bfm_id).data_out1;
   end get_transaction_channel;
   
   procedure get_transaction_channel           (channel       : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t) is
   
      variable channel_temp   : std_logic_vector (ST_MAX_BIT_W - 1 downto 0);
   begin
      get_transaction_channel(channel_temp, bfm_id, api_if);
      channel := to_integer(channel_temp);
   end get_transaction_channel;

   procedure get_transaction_sop               (sop           : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(ST_MONITOR_GET_TRANSACTION_SOP) <= '1';
      wait until (ack_if(bfm_id).ack(ST_MONITOR_GET_TRANSACTION_SOP) = '1');
      api_if(bfm_id).req(ST_MONITOR_GET_TRANSACTION_SOP) <= '0';
      wait until (ack_if(bfm_id).ack(ST_MONITOR_GET_TRANSACTION_SOP) = '0');
      sop := ack_if(bfm_id).data_out0;
   end get_transaction_sop;

   procedure get_transaction_eop               (eop           : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(ST_MONITOR_GET_TRANSACTION_EOP) <= '1';
      wait until (ack_if(bfm_id).ack(ST_MONITOR_GET_TRANSACTION_EOP) = '1');
      api_if(bfm_id).req(ST_MONITOR_GET_TRANSACTION_EOP) <= '0';
      wait until (ack_if(bfm_id).ack(ST_MONITOR_GET_TRANSACTION_EOP) = '0');
      eop := ack_if(bfm_id).data_out0;
   end get_transaction_eop;

   procedure get_transaction_error             (error         : out std_logic_vector (ST_MAX_BIT_W - 1 downto 0);
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(ST_MONITOR_GET_TRANSACTION_ERROR) <= '1';
      wait until (ack_if(bfm_id).ack(ST_MONITOR_GET_TRANSACTION_ERROR) = '1');
      api_if(bfm_id).req(ST_MONITOR_GET_TRANSACTION_ERROR) <= '0';
      wait until (ack_if(bfm_id).ack(ST_MONITOR_GET_TRANSACTION_ERROR) = '0');
      error := ack_if(bfm_id).data_out1;
   end get_transaction_error;

   procedure get_transaction_error             (error         : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t) is
      
      variable error_temp   : std_logic_vector (ST_MAX_BIT_W - 1 downto 0);
   begin
      get_transaction_error(error_temp, bfm_id, api_if);
      error := to_integer(error_temp);
   end get_transaction_error;

   procedure get_transaction_empty             (empty         : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(ST_MONITOR_GET_TRANSACTION_EMPTY) <= '1';
      wait until (ack_if(bfm_id).ack(ST_MONITOR_GET_TRANSACTION_EMPTY) = '1');
      api_if(bfm_id).req(ST_MONITOR_GET_TRANSACTION_EMPTY) <= '0';
      wait until (ack_if(bfm_id).ack(ST_MONITOR_GET_TRANSACTION_EMPTY) = '0');
      empty := ack_if(bfm_id).data_out0;
   end get_transaction_empty;

   procedure get_transaction_queue_size        (size          : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout st_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(ST_MONITOR_GET_TRANSACTION_QUEUE_SIZE) <= '1';
      wait until (ack_if(bfm_id).ack(ST_MONITOR_GET_TRANSACTION_QUEUE_SIZE) = '1');
      api_if(bfm_id).req(ST_MONITOR_GET_TRANSACTION_QUEUE_SIZE) <= '0';
      wait until (ack_if(bfm_id).ack(ST_MONITOR_GET_TRANSACTION_QUEUE_SIZE) = '0');
      size := ack_if(bfm_id).data_out0;
   end get_transaction_queue_size;

   -- VHDL events implementation
   procedure event_transaction_received        (bfm_id        : in integer) is
   begin
      wait until (ack_if(bfm_id).events(ST_MONITOR_EVENT_TRANSACTION_RECEIVED) = '1');
   end event_transaction_received;

   procedure event_transaction_fifo_threshold  (bfm_id        : in integer) is
   begin
      wait until (ack_if(bfm_id).events(ST_MONITOR_EVENT_TRANSACTION_FIFO_THRESHOLD) = '1');
   end event_transaction_fifo_threshold;

   procedure event_transaction_fifo_overflow   (bfm_id        : in integer) is
   begin
      wait until (ack_if(bfm_id).events(ST_MONITOR_EVENT_TRANSACTION_FIFO_OVERFLOW) = '1');
   end event_transaction_fifo_overflow;

end altera_avalon_st_monitor_vhdl_pkg;
