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
package altera_avalon_st_source_bfm_vhdl_pkg is
   
   -- maximum number of Avalon-ST source vhdl bfm
   constant MAX_VHDL_BFM : integer := 1024;
   
   -- maximum number of bits in Avalon-ST interface
   constant ST_MAX_BIT_W : integer := 4096;
   
   -- idle output configuration type
   constant LOW         : integer := 0;
   constant HIGH        : integer := 1;
   constant RANDOM      : integer := 2;
   constant UNKNOWN     : integer := 3;
   
   -- st_src_vhdl_api_e
   constant ST_SRC_GET_SRC_TRANSACTION_COMPLETE          : integer := 0;
   constant ST_SRC_GET_SRC_READY                         : integer := 1;
   constant ST_SRC_SET_RESPONSE_TIMEOUT                  : integer := 2;
   constant ST_SRC_PUSH_TRANSACTION                      : integer := 3;
   constant ST_SRC_GET_TRANSACTION_QUEUE_SIZE            : integer := 4;
   constant ST_SRC_GET_RESPONSE_QUEUE_SIZE               : integer := 5;
   constant ST_SRC_SET_TRANSACTION_DATA                  : integer := 6;
   constant ST_SRC_SET_TRANSACTION_CHANNEL               : integer := 7;
   constant ST_SRC_SET_TRANSACTION_IDLES                 : integer := 8;
   constant ST_SRC_SET_TRANSACTION_SOP                   : integer := 9;
   constant ST_SRC_SET_TRANSACTION_EOP                   : integer := 10;
   constant ST_SRC_SET_TRANSACTION_ERROR                 : integer := 11;
   constant ST_SRC_SET_TRANSACTION_EMPTY                 : integer := 12;
   constant ST_SRC_POP_RESPONSE                          : integer := 13;
   constant ST_SRC_GET_RESPONSE_LATENCY                  : integer := 14;
   constant ST_SRC_SET_MAX_TRANSACTION_QUEUE_SIZE        : integer := 15;
   constant ST_SRC_SET_MIN_TRANSACTION_QUEUE_SIZE        : integer := 16;
   constant ST_SRC_SET_IDLE_STATE_OUTPUT_CONFIGURATION   : integer := 17;
   constant ST_SRC_GET_IDLE_STATE_OUTPUT_CONFIGURATION   : integer := 18;
   constant ST_SRC_INIT                                  : integer := 19;
   
   -- st_src_vhdl_event_e
   constant ST_SRC_EVENT_RESPONSE_DONE                : integer := 0;
   constant ST_SRC_EVENT_MAX_TRANSACTION_QUEUE_SIZE   : integer := 1;
   constant ST_SRC_EVENT_MIN_TRANSACTION_QUEUE_SIZE   : integer := 2;
   constant ST_SRC_EVENT_SRC_TRANSACTION_COMPLETE     : integer := 3;
   constant ST_SRC_EVENT_SRC_DRIVING_TRANSACTION      : integer := 4;
   constant ST_SRC_EVENT_SRC_READY                    : integer := 5;
   constant ST_SRC_EVENT_SRC_NOT_READY                : integer := 6;
   
   -- VHDL API request interface type
   type st_src_vhdl_if_base_t is record
      req         : std_logic_vector (ST_SRC_INIT downto 0);
      ack         : std_logic_vector (ST_SRC_INIT downto 0);
      data_in0    : integer;
      data_in1    : std_logic_vector (ST_MAX_BIT_W - 1 downto 0);
      data_out0   : integer;
      data_out1   : std_logic_vector (ST_MAX_BIT_W - 1 downto 0);
      events      : std_logic_vector (ST_SRC_EVENT_SRC_NOT_READY downto 0);
   end record;

   type st_src_vhdl_if_t is array(MAX_VHDL_BFM - 1 downto 0) of st_src_vhdl_if_base_t;
   
   signal req_if           : st_src_vhdl_if_t;
   signal ack_if           : st_src_vhdl_if_t;

   -- VHDL procedures
   procedure get_src_transaction_complete (status        : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t);

   procedure get_src_ready                (status        : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t);

   procedure set_response_timeout         (timeout       : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t);
                                           
   procedure push_transaction             (bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t);

   procedure get_transaction_queue_size   (size          : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t);
                                           
   procedure get_response_queue_size      (size          : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t);
                                           
   procedure set_transaction_data         (data          : in std_logic_vector (ST_MAX_BIT_W - 1 downto 0);
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t);
                                           
   procedure set_transaction_data         (data          : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t);
                                           
   procedure set_transaction_channel      (channel       : in std_logic_vector (ST_MAX_BIT_W - 1 downto 0);
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t);
                                           
   procedure set_transaction_channel      (channel       : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t);
   
   procedure set_transaction_idles        (idles         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t);
                                           
   procedure set_transaction_sop          (sop           : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t);
                                           
   procedure set_transaction_eop          (eop           : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t);
                                           
   procedure set_transaction_error        (error         : in std_logic_vector (ST_MAX_BIT_W - 1 downto 0);
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t);
                                           
   procedure set_transaction_error        (error         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t);
   
   procedure set_transaction_empty        (empty         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t);
                                           
   procedure pop_response                 (bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t);
                                           
   procedure get_response_latency         (latency       : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t);
                                           
   procedure set_max_transaction_queue_size(size         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t);
                                           
   procedure set_min_transaction_queue_size(size         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t);
   
   procedure set_idle_state_output_configuration   (config        : in integer;
                                                    bfm_id        : in integer;
                                                    signal api_if : inout st_src_vhdl_if_t);
   
   procedure get_idle_state_output_configuration   (config        : out integer;
                                                    bfm_id        : in integer;
                                                    signal api_if : inout st_src_vhdl_if_t);
                                           
   procedure init                         (bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t);
   
   -- VHDL events
   procedure event_response_done                (bfm_id        : in integer);
   procedure event_max_transaction_queue_size   (bfm_id        : in integer);
   procedure event_min_transaction_queue_size   (bfm_id        : in integer);
   procedure event_src_transaction_complete     (bfm_id        : in integer);
   procedure event_src_driving_transaction      (bfm_id        : in integer);
   procedure event_src_ready                    (bfm_id        : in integer);
   procedure event_src_not_ready                (bfm_id        : in integer);

end altera_avalon_st_source_bfm_vhdl_pkg;

-- VHDL procedures implementation
package body altera_avalon_st_source_bfm_vhdl_pkg is

   procedure get_src_transaction_complete (status        : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t) is
   begin
      api_if(bfm_id).req(ST_SRC_GET_SRC_TRANSACTION_COMPLETE) <= '1';
      wait until (ack_if(bfm_id).ack(ST_SRC_GET_SRC_TRANSACTION_COMPLETE) = '1');
      api_if(bfm_id).req(ST_SRC_GET_SRC_TRANSACTION_COMPLETE) <= '0';
      wait until (ack_if(bfm_id).ack(ST_SRC_GET_SRC_TRANSACTION_COMPLETE) = '0');
      status := ack_if(bfm_id).data_out0;
   end get_src_transaction_complete;
   
   procedure get_src_ready                (status        : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t) is
   begin
      api_if(bfm_id).req(ST_SRC_GET_SRC_READY) <= '1';
      wait until (ack_if(bfm_id).ack(ST_SRC_GET_SRC_READY) = '1');
      api_if(bfm_id).req(ST_SRC_GET_SRC_READY) <= '0';
      wait until (ack_if(bfm_id).ack(ST_SRC_GET_SRC_READY) = '0');
      status := ack_if(bfm_id).data_out0;
   end get_src_ready;

   procedure set_response_timeout         (timeout       : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= timeout;
      api_if(bfm_id).req(ST_SRC_SET_RESPONSE_TIMEOUT) <= '1';
      wait until (ack_if(bfm_id).ack(ST_SRC_SET_RESPONSE_TIMEOUT) = '1');
      api_if(bfm_id).req(ST_SRC_SET_RESPONSE_TIMEOUT) <= '0';
      wait until (ack_if(bfm_id).ack(ST_SRC_SET_RESPONSE_TIMEOUT) = '0');
   end set_response_timeout;
   
   procedure push_transaction             (bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t) is
   begin
      api_if(bfm_id).req(ST_SRC_PUSH_TRANSACTION) <= '1';
      wait until (ack_if(bfm_id).ack(ST_SRC_PUSH_TRANSACTION) = '1');
      api_if(bfm_id).req(ST_SRC_PUSH_TRANSACTION) <= '0';
      wait until (ack_if(bfm_id).ack(ST_SRC_PUSH_TRANSACTION) = '0');
   end push_transaction;

   procedure get_transaction_queue_size   (size          : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t) is
   begin
      api_if(bfm_id).req(ST_SRC_GET_TRANSACTION_QUEUE_SIZE) <= '1';
      wait until (ack_if(bfm_id).ack(ST_SRC_GET_TRANSACTION_QUEUE_SIZE) = '1');
      api_if(bfm_id).req(ST_SRC_GET_TRANSACTION_QUEUE_SIZE) <= '0';
      wait until (ack_if(bfm_id).ack(ST_SRC_GET_TRANSACTION_QUEUE_SIZE) = '0');
      size := ack_if(bfm_id).data_out0;
   end get_transaction_queue_size;
   
   procedure get_response_queue_size      (size          : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t) is
   begin
      api_if(bfm_id).req(ST_SRC_GET_RESPONSE_QUEUE_SIZE) <= '1';
      wait until (ack_if(bfm_id).ack(ST_SRC_GET_RESPONSE_QUEUE_SIZE) = '1');
      api_if(bfm_id).req(ST_SRC_GET_RESPONSE_QUEUE_SIZE) <= '0';
      wait until (ack_if(bfm_id).ack(ST_SRC_GET_RESPONSE_QUEUE_SIZE) = '0');
      size := ack_if(bfm_id).data_out0;
   end get_response_queue_size;
   
   procedure set_transaction_data         (data          : in std_logic_vector (ST_MAX_BIT_W - 1 downto 0);
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in1 <= data;
      api_if(bfm_id).req(ST_SRC_SET_TRANSACTION_DATA) <= '1';
      wait until (ack_if(bfm_id).ack(ST_SRC_SET_TRANSACTION_DATA) = '1');
      api_if(bfm_id).req(ST_SRC_SET_TRANSACTION_DATA) <= '0';
      wait until (ack_if(bfm_id).ack(ST_SRC_SET_TRANSACTION_DATA) = '0');
   end set_transaction_data;
   
   procedure set_transaction_data         (data          : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t) is
   begin
      set_transaction_data(conv_std_logic_vector(data, ST_MAX_BIT_W), bfm_id, api_if);
   end set_transaction_data;
                                           
   procedure set_transaction_channel      (channel       : in std_logic_vector (ST_MAX_BIT_W - 1 downto 0);
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in1 <= channel;
      api_if(bfm_id).req(ST_SRC_SET_TRANSACTION_CHANNEL) <= '1';
      wait until (ack_if(bfm_id).ack(ST_SRC_SET_TRANSACTION_CHANNEL) = '1');
      api_if(bfm_id).req(ST_SRC_SET_TRANSACTION_CHANNEL) <= '0';
      wait until (ack_if(bfm_id).ack(ST_SRC_SET_TRANSACTION_CHANNEL) = '0');
   end set_transaction_channel;
   
   procedure set_transaction_channel      (channel       : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t) is
   begin
      set_transaction_channel(conv_std_logic_vector(channel, ST_MAX_BIT_W), bfm_id, api_if);
   end set_transaction_channel;
                                           
   procedure set_transaction_idles        (idles         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= idles;
      api_if(bfm_id).req(ST_SRC_SET_TRANSACTION_IDLES) <= '1';
      wait until (ack_if(bfm_id).ack(ST_SRC_SET_TRANSACTION_IDLES) = '1');
      api_if(bfm_id).req(ST_SRC_SET_TRANSACTION_IDLES) <= '0';
      wait until (ack_if(bfm_id).ack(ST_SRC_SET_TRANSACTION_IDLES) = '0');
   end set_transaction_idles;
                                           
   procedure set_transaction_sop          (sop           : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= sop;
      api_if(bfm_id).req(ST_SRC_SET_TRANSACTION_SOP) <= '1';
      wait until (ack_if(bfm_id).ack(ST_SRC_SET_TRANSACTION_SOP) = '1');
      api_if(bfm_id).req(ST_SRC_SET_TRANSACTION_SOP) <= '0';
      wait until (ack_if(bfm_id).ack(ST_SRC_SET_TRANSACTION_SOP) = '0');
   end set_transaction_sop;
                                           
   procedure set_transaction_eop          (eop           : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= eop;
      api_if(bfm_id).req(ST_SRC_SET_TRANSACTION_EOP) <= '1';
      wait until (ack_if(bfm_id).ack(ST_SRC_SET_TRANSACTION_EOP) = '1');
      api_if(bfm_id).req(ST_SRC_SET_TRANSACTION_EOP) <= '0';
      wait until (ack_if(bfm_id).ack(ST_SRC_SET_TRANSACTION_EOP) = '0');
   end set_transaction_eop;
                                           
   procedure set_transaction_error        (error         : in std_logic_vector (ST_MAX_BIT_W - 1 downto 0);
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in1 <= error;
      api_if(bfm_id).req(ST_SRC_SET_TRANSACTION_ERROR) <= '1';
      wait until (ack_if(bfm_id).ack(ST_SRC_SET_TRANSACTION_ERROR) = '1');
      api_if(bfm_id).req(ST_SRC_SET_TRANSACTION_ERROR) <= '0';
      wait until (ack_if(bfm_id).ack(ST_SRC_SET_TRANSACTION_ERROR) = '0');
   end set_transaction_error;
   
   procedure set_transaction_error        (error         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t) is
   begin
      set_transaction_error(conv_std_logic_vector(error, ST_MAX_BIT_W), bfm_id, api_if);
   end set_transaction_error;
                                           
   procedure set_transaction_empty        (empty         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= empty;
      api_if(bfm_id).req(ST_SRC_SET_TRANSACTION_EMPTY) <= '1';
      wait until (ack_if(bfm_id).ack(ST_SRC_SET_TRANSACTION_EMPTY) = '1');
      api_if(bfm_id).req(ST_SRC_SET_TRANSACTION_EMPTY) <= '0';
      wait until (ack_if(bfm_id).ack(ST_SRC_SET_TRANSACTION_EMPTY) = '0');
   end set_transaction_empty;
                                           
   procedure pop_response                 (bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t) is
   begin
      api_if(bfm_id).req(ST_SRC_POP_RESPONSE) <= '1';
      wait until (ack_if(bfm_id).ack(ST_SRC_POP_RESPONSE) = '1');
      api_if(bfm_id).req(ST_SRC_POP_RESPONSE) <= '0';
      wait until (ack_if(bfm_id).ack(ST_SRC_POP_RESPONSE) = '0');
   end pop_response;
                                           
   procedure get_response_latency         (latency       : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t) is
   begin
      api_if(bfm_id).req(ST_SRC_GET_RESPONSE_LATENCY) <= '1';
      wait until (ack_if(bfm_id).ack(ST_SRC_GET_RESPONSE_LATENCY) = '1');
      api_if(bfm_id).req(ST_SRC_GET_RESPONSE_LATENCY) <= '0';
      wait until (ack_if(bfm_id).ack(ST_SRC_GET_RESPONSE_LATENCY) = '0');
      latency := ack_if(bfm_id).data_out0;
   end get_response_latency;
                                           
   procedure set_max_transaction_queue_size(size         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= size;
      api_if(bfm_id).req(ST_SRC_SET_MAX_TRANSACTION_QUEUE_SIZE) <= '1';
      wait until (ack_if(bfm_id).ack(ST_SRC_SET_MAX_TRANSACTION_QUEUE_SIZE) = '1');
      api_if(bfm_id).req(ST_SRC_SET_MAX_TRANSACTION_QUEUE_SIZE) <= '0';
      wait until (ack_if(bfm_id).ack(ST_SRC_SET_MAX_TRANSACTION_QUEUE_SIZE) = '0');
   end set_max_transaction_queue_size;
                                           
   procedure set_min_transaction_queue_size(size         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= size;
      api_if(bfm_id).req(ST_SRC_SET_MIN_TRANSACTION_QUEUE_SIZE) <= '1';
      wait until (ack_if(bfm_id).ack(ST_SRC_SET_MIN_TRANSACTION_QUEUE_SIZE) = '1');
      api_if(bfm_id).req(ST_SRC_SET_MIN_TRANSACTION_QUEUE_SIZE) <= '0';
      wait until (ack_if(bfm_id).ack(ST_SRC_SET_MIN_TRANSACTION_QUEUE_SIZE) = '0');
   end set_min_transaction_queue_size;

   procedure set_idle_state_output_configuration   (config        : in integer;
                                                    bfm_id        : in integer;
                                                    signal api_if : inout st_src_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= config;
      api_if(bfm_id).req(ST_SRC_SET_IDLE_STATE_OUTPUT_CONFIGURATION) <= '1';
      wait until (ack_if(bfm_id).ack(ST_SRC_SET_IDLE_STATE_OUTPUT_CONFIGURATION) = '1');
      api_if(bfm_id).req(ST_SRC_SET_IDLE_STATE_OUTPUT_CONFIGURATION) <= '0';
      wait until (ack_if(bfm_id).ack(ST_SRC_SET_IDLE_STATE_OUTPUT_CONFIGURATION) = '0');
   end set_idle_state_output_configuration;
   
   procedure get_idle_state_output_configuration   (config        : out integer;
                                                    bfm_id        : in integer;
                                                    signal api_if : inout st_src_vhdl_if_t) is
   begin
      api_if(bfm_id).req(ST_SRC_GET_IDLE_STATE_OUTPUT_CONFIGURATION) <= '1';
      wait until (ack_if(bfm_id).ack(ST_SRC_GET_IDLE_STATE_OUTPUT_CONFIGURATION) = '1');
      api_if(bfm_id).req(ST_SRC_GET_IDLE_STATE_OUTPUT_CONFIGURATION) <= '0';
      wait until (ack_if(bfm_id).ack(ST_SRC_GET_IDLE_STATE_OUTPUT_CONFIGURATION) = '0');
      config := ack_if(bfm_id).data_out0;
   end get_idle_state_output_configuration;
   
   procedure init                         (bfm_id        : in integer;
                                           signal api_if : inout st_src_vhdl_if_t) is
   begin
      api_if(bfm_id).req(ST_SRC_INIT) <= '1';
      wait until (ack_if(bfm_id).ack(ST_SRC_INIT) = '1');
      api_if(bfm_id).req(ST_SRC_INIT) <= '0';
      wait until (ack_if(bfm_id).ack(ST_SRC_INIT) = '0');
   end init;
   
   
   -- VHDL events implementation
   procedure event_response_done                (bfm_id        : in integer) is
   begin
      wait until (ack_if(bfm_id).events(ST_SRC_EVENT_RESPONSE_DONE) = '1');
   end event_response_done;

   procedure event_max_transaction_queue_size   (bfm_id        : in integer) is
   begin
      wait until (ack_if(bfm_id).events(ST_SRC_EVENT_MAX_TRANSACTION_QUEUE_SIZE) = '1');
   end event_max_transaction_queue_size;
   
   procedure event_min_transaction_queue_size   (bfm_id        : in integer) is
   begin
      wait until (ack_if(bfm_id).events(ST_SRC_EVENT_MIN_TRANSACTION_QUEUE_SIZE) = '1');
   end event_min_transaction_queue_size;
   
   procedure event_src_transaction_complete     (bfm_id        : in integer) is
   begin
      wait until (ack_if(bfm_id).events(ST_SRC_EVENT_SRC_TRANSACTION_COMPLETE) = '1');
   end event_src_transaction_complete;
   
   procedure event_src_driving_transaction      (bfm_id        : in integer) is
   begin
      wait until (ack_if(bfm_id).events(ST_SRC_EVENT_SRC_DRIVING_TRANSACTION) = '1');
   end event_src_driving_transaction;
   
   procedure event_src_ready                    (bfm_id        : in integer) is
   begin
      wait until (ack_if(bfm_id).events(ST_SRC_EVENT_SRC_READY) = '1');
   end event_src_ready;
   
   procedure event_src_not_ready                (bfm_id        : in integer) is
   begin
      wait until (ack_if(bfm_id).events(ST_SRC_EVENT_SRC_NOT_READY) = '1');
   end event_src_not_ready;
   
end altera_avalon_st_source_bfm_vhdl_pkg;
