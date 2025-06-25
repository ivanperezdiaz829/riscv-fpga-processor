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
package altera_avalon_mm_monitor_vhdl_pkg is

   -- maximum number of Avalon-MM monitor vhdl
   constant MAX_VHDL_BFM : integer := 1024;
   
   -- maximum number of bits in Avalon-MM interface
   constant MM_MAX_BIT_W : integer := 1024;
   
   -- request type
   constant REQ_READ     : integer := 0;
   constant REQ_WRITE    : integer := 1;
   constant REQ_IDLE     : integer := 2;
   
   -- response status type
   constant AV_OKAY         : integer := 0;
   constant AV_RESERVED     : integer := 1;
   constant AV_SLAVE_ERROR  : integer := 2;
   constant AV_DECODE_ERROR : integer := 3;
   
   -- mm_monitor_vhdl_api_e
   constant MM_MONITOR_SET_TRANSACTION_FIFO_MAX                                   : integer := 0;
   constant MM_MONITOR_GET_TRANSACTION_FIFO_MAX                                   : integer := 1;
   constant MM_MONITOR_SET_TRANSACTION_FIFO_THRESHOLD                             : integer := 2;
   constant MM_MONITOR_GET_TRANSACTION_FIFO_THRESHOLD                             : integer := 3;
   constant MM_MONITOR_SET_COMMAND_TRANSACTION_MODE                               : integer := 4;
   constant MM_MONITOR_POP_COMMAND                                                : integer := 5;
   constant MM_MONITOR_GET_COMMAND_QUEUE_SIZE                                     : integer := 6;
   constant MM_MONITOR_GET_COMMAND_REQUEST                                        : integer := 7;
   constant MM_MONITOR_GET_COMMAND_ADDRESS                                        : integer := 8;
   constant MM_MONITOR_GET_COMMAND_BURST_COUNT                                    : integer := 9;
   constant MM_MONITOR_GET_COMMAND_DATA                                           : integer := 10;
   constant MM_MONITOR_GET_COMMAND_BYTE_ENABLE                                    : integer := 11;
   constant MM_MONITOR_GET_COMMAND_BURST_CYCLE                                    : integer := 12;
   constant MM_MONITOR_GET_COMMAND_ARBITERLOCK                                    : integer := 13;
   constant MM_MONITOR_GET_COMMAND_LOCK                                           : integer := 14;
   constant MM_MONITOR_GET_COMMAND_DEBUGACCESS                                    : integer := 15;
   constant MM_MONITOR_GET_COMMAND_TRANSACTION_ID                                 : integer := 16;
   constant MM_MONITOR_GET_COMMAND_WRITE_RESPONSE_REQUEST                         : integer := 17;
   constant MM_MONITOR_GET_COMMAND_ISSUED_QUEUE_SIZE                              : integer := 18;
   constant MM_MONITOR_GET_RESPONSE_ADDRESS                                       : integer := 19;
   constant MM_MONITOR_GET_RESPONSE_BYTE_ENABLE                                   : integer := 20;
   constant MM_MONITOR_GET_RESPONSE_BURST_SIZE                                    : integer := 21;
   constant MM_MONITOR_GET_RESPONSE_DATA                                          : integer := 22;
   constant MM_MONITOR_GET_RESPONSE_LATENCY                                       : integer := 23;
   constant MM_MONITOR_GET_RESPONSE_REQUEST                                       : integer := 24;
   constant MM_MONITOR_GET_RESPONSE_QUEUE_SIZE                                    : integer := 25;
   constant MM_MONITOR_GET_RESPONSE_WAIT_TIME                                     : integer := 26;
   constant MM_MONITOR_POP_RESPONSE                                               : integer := 27;
   constant MM_MONITOR_GET_READ_RESPONSE_STATUS                                   : integer := 28;
   constant MM_MONITOR_GET_RESPONSE_READ_ID                                       : integer := 29;
   constant MM_MONITOR_GET_WRITE_RESPONSE_STATUS                                  : integer := 30;
   constant MM_MONITOR_GET_RESPONSE_WRITE_ID                                      : integer := 31;
   constant MM_MONITOR_GET_CLKEN                                                  : integer := 32;
   constant MM_MONITOR_GET_WRITE_RESPONSE_QUEUE_SIZE                              : integer := 33;
   constant MM_MONITOR_GET_READ_RESPONSE_QUEUE_SIZE                               : integer := 34;
   constant MM_MONITOR_INIT                                                       : integer := 35;
   
   -- mm_monitor_vhdl_event_e
   constant MM_MONITOR_EVENT_TRANSACTION_FIFO_THRESHOLD                           : integer := 0;
   constant MM_MONITOR_EVENT_TRANSACTION_FIFO_OVERFLOW                            : integer := 1;
   constant MM_MONITOR_EVENT_COMMAND_RECEIVED                                     : integer := 2;
   constant MM_MONITOR_EVENT_READ_RESPONSE_COMPLETE                               : integer := 3;
   constant MM_MONITOR_EVENT_WRITE_RESPONSE_COMPLETE                              : integer := 4;
   constant MM_MONITOR_EVENT_RESPONSE_COMPLETE                                    : integer := 5;
   
   -- VHDL API request interface type
   type mm_monitor_vhdl_if_base_t is record
      req         : std_logic_vector (MM_MONITOR_INIT downto 0);
      ack         : std_logic_vector (MM_MONITOR_INIT downto 0);
      data_in0    : integer;
      data_in1    : integer;
      data_in2    : std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
      data_out0   : integer;
      data_out1   : integer;
      data_out2   : std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
      events      : std_logic_vector (MM_MONITOR_EVENT_RESPONSE_COMPLETE downto 0);
   end record;

   type mm_monitor_vhdl_if_t is array(MAX_VHDL_BFM - 1 downto 0) of mm_monitor_vhdl_if_base_t;
   
   signal req_if           : mm_monitor_vhdl_if_t;
   signal ack_if           : mm_monitor_vhdl_if_t;

   -- convert signal to integer
   function to_integer (OP: STD_LOGIC_VECTOR) return INTEGER;
   
   -- helper function to get slave address width
   function log2 (NUMBER   : INTEGER) return INTEGER;      
   
   function get_slave_addrs_w (MASTER_ADDRESS_TYPE, SLAVE_ADDRESS_TYPE : STRING;
                               AV_ADDRESS_W, AV_NUMSYMBOLS             : INTEGER)
                               return INTEGER;
   
   -- procedures for monitor transaction
   procedure set_transaction_fifo_max                                  (size          : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_transaction_fifo_max                                  (size          : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure set_transaction_fifo_threshold                            (size          : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_transaction_fifo_threshold                            (size          : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure set_command_transaction_mode                              (mode          : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure pop_command                                               (bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_command_queue_size                                    (size          : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_command_request                                       (request       : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_command_address                                       (address       : out std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);
   
   procedure get_command_address                                       (address       : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_command_burst_count                                   (burst_count    : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_command_data                                          (data          : out std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
                                                                        index         : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);
                                                                        
   procedure get_command_data                                          (data          : out integer;
                                                                        index         : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_command_byte_enable                                   (byte_enable   : out std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
                                                                        index         : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);
   
   procedure get_command_byte_enable                                   (byte_enable   : out integer;
                                                                        index         : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_command_burst_cycle                                   (burst_cycle   : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_command_arbiterlock                                   (status        : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_command_lock                                          (status        : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_command_debugaccess                                   (status        : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_command_transaction_id                                (id            : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_command_write_response_request                        (request       : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_command_issued_queue_size                             (size          : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_response_address                                      (address       : out std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);
   
   procedure get_response_address                                      (address       : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_response_byte_enable                                  (byte_enable   : out std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
                                                                        index         : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);
   
   procedure get_response_byte_enable                                  (byte_enable   : out integer;
                                                                        index         : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_response_burst_size                                   (burst_size    : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_response_data                                         (data          : out std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
                                                                        index         : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);
   
   procedure get_response_data                                         (data          : out integer;
                                                                        index         : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_response_latency                                      (cycles        : out integer;
                                                                        index         : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);
   
   procedure get_response_latency                                      (cycles        : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_response_request                                      (request       : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_response_queue_size                                   (size          : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_response_wait_time                                    (cycles        : out integer;
                                                                        index         : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure pop_response                                              (bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_read_response_status                                  (response      : out integer;
                                                                        index         : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_response_read_id                                      (id            : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_write_response_status                                 (response      : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_response_write_id                                     (id            : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_clken                                                 (status        : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_write_response_queue_size                             (size          : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure get_read_response_queue_size                              (size          : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   procedure init                                                      (bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   -- deprecated API
   procedure get_response_read_response                                (response      : out integer;
                                                                        index         : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);
   
   procedure get_response_write_response                               (response      : out integer;
                                                                        index         : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t);

   -- VHDL events
   procedure event_transaction_fifo_threshold   (bfm_id  : in integer);
   procedure event_transaction_fifo_overflow    (bfm_id  : in integer);
   procedure event_command_received             (bfm_id  : in integer);
   procedure event_read_response_complete       (bfm_id  : in integer);
   procedure event_write_response_complete      (bfm_id  : in integer);
   procedure event_response_complete            (bfm_id  : in integer);
   
end altera_avalon_mm_monitor_vhdl_pkg;

-- VHDL procedures implementation
package body altera_avalon_mm_monitor_vhdl_pkg is

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
   
   -- helper function to get slave address width
   function log2 (NUMBER   : INTEGER) return INTEGER is      
      variable number_temp : INTEGER := NUMBER - 1;
      variable count       : INTEGER := 0;
   begin
      log_count: while number_temp > 0 loop
         number_temp := number_temp / 2;
         count := count + 1;
      end loop log_count;
      return count;
   end log2;
   
   function get_slave_addrs_w (MASTER_ADDRESS_TYPE, SLAVE_ADDRESS_TYPE : STRING;
                               AV_ADDRESS_W, AV_NUMSYMBOLS             : INTEGER)
                               return INTEGER is
      variable AV_SLAVE_ADDRESS_W : INTEGER := AV_ADDRESS_W;
   begin
      if  (MASTER_ADDRESS_TYPE = SLAVE_ADDRESS_TYPE) then         
         return AV_SLAVE_ADDRESS_W;
      else
         AV_SLAVE_ADDRESS_W := AV_ADDRESS_W - log2(AV_NUMSYMBOLS);
         return AV_SLAVE_ADDRESS_W;
      end if;
   end get_slave_addrs_w;
   
   -- procedures for monitor transaction
   procedure set_transaction_fifo_max                                  (size          : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= size;
      api_if(bfm_id).req(MM_MONITOR_SET_TRANSACTION_FIFO_MAX) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_SET_TRANSACTION_FIFO_MAX) = '1');
      api_if(bfm_id).req(MM_MONITOR_SET_TRANSACTION_FIFO_MAX) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_SET_TRANSACTION_FIFO_MAX) = '0');      
   end set_transaction_fifo_max;

   procedure get_transaction_fifo_max                                  (size          : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MONITOR_GET_TRANSACTION_FIFO_MAX) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_TRANSACTION_FIFO_MAX) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_TRANSACTION_FIFO_MAX) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_TRANSACTION_FIFO_MAX) = '0');
      size := ack_if(bfm_id).data_out0;
   end get_transaction_fifo_max;

   procedure set_transaction_fifo_threshold                            (size          : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= size;
      api_if(bfm_id).req(MM_MONITOR_SET_TRANSACTION_FIFO_THRESHOLD) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_SET_TRANSACTION_FIFO_THRESHOLD) = '1');
      api_if(bfm_id).req(MM_MONITOR_SET_TRANSACTION_FIFO_THRESHOLD) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_SET_TRANSACTION_FIFO_THRESHOLD) = '0');
   end set_transaction_fifo_threshold;

   procedure get_transaction_fifo_threshold                            (size          : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MONITOR_GET_TRANSACTION_FIFO_THRESHOLD) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_TRANSACTION_FIFO_THRESHOLD) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_TRANSACTION_FIFO_THRESHOLD) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_TRANSACTION_FIFO_THRESHOLD) = '0');
      size := ack_if(bfm_id).data_out0;
   end get_transaction_fifo_threshold;

   procedure set_command_transaction_mode                              (mode          : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= mode;
      api_if(bfm_id).req(MM_MONITOR_SET_COMMAND_TRANSACTION_MODE) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_SET_COMMAND_TRANSACTION_MODE) = '1');
      api_if(bfm_id).req(MM_MONITOR_SET_COMMAND_TRANSACTION_MODE) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_SET_COMMAND_TRANSACTION_MODE) = '0');
   end set_command_transaction_mode;

   procedure pop_command                                               (bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MONITOR_POP_COMMAND) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_POP_COMMAND) = '1');
      api_if(bfm_id).req(MM_MONITOR_POP_COMMAND) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_POP_COMMAND) = '0');
   end pop_command;

   procedure get_command_queue_size                                    (size          : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MONITOR_GET_COMMAND_QUEUE_SIZE) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_COMMAND_QUEUE_SIZE) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_COMMAND_QUEUE_SIZE) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_COMMAND_QUEUE_SIZE) = '0');
      size := ack_if(bfm_id).data_out0;
   end get_command_queue_size;

   procedure get_command_request                                       (request       : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MONITOR_GET_COMMAND_REQUEST) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_COMMAND_REQUEST) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_COMMAND_REQUEST) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_COMMAND_REQUEST) = '0');
      request := ack_if(bfm_id).data_out0;
   end get_command_request;

   procedure get_command_address                                       (address       : out std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MONITOR_GET_COMMAND_ADDRESS) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_COMMAND_ADDRESS) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_COMMAND_ADDRESS) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_COMMAND_ADDRESS) = '0');
      address := ack_if(bfm_id).data_out2;
   end get_command_address;
   
   procedure get_command_address                                       (address       : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   
      variable address_temp   : std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
   begin
      get_command_address(address_temp, bfm_id, api_if);
      address := to_integer(address_temp);
   end get_command_address;

   procedure get_command_burst_count                                   (burst_count   : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MONITOR_GET_COMMAND_BURST_COUNT) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_COMMAND_BURST_COUNT) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_COMMAND_BURST_COUNT) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_COMMAND_BURST_COUNT) = '0');
      burst_count := ack_if(bfm_id).data_out0;
   end get_command_burst_count;

   procedure get_command_data                                          (data          : out std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
                                                                        index         : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in1 <= index;
      api_if(bfm_id).req(MM_MONITOR_GET_COMMAND_DATA) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_COMMAND_DATA) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_COMMAND_DATA) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_COMMAND_DATA) = '0');
      data := ack_if(bfm_id).data_out2;
   end get_command_data;
   
   procedure get_command_data                                          (data          : out integer;
                                                                        index         : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
      
      variable data_temp   : std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
   begin
      get_command_data(data_temp, index, bfm_id, api_if);
      data := to_integer(data_temp);
   end get_command_data;

   procedure get_command_byte_enable                                   (byte_enable   : out std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
                                                                        index         : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in1 <= index;
      api_if(bfm_id).req(MM_MONITOR_GET_COMMAND_BYTE_ENABLE) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_COMMAND_BYTE_ENABLE) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_COMMAND_BYTE_ENABLE) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_COMMAND_BYTE_ENABLE) = '0');
      byte_enable := ack_if(bfm_id).data_out2;
   end get_command_byte_enable;
   
   procedure get_command_byte_enable                                   (byte_enable   : out integer;
                                                                        index         : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   
      variable byte_enable_temp   : std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
   begin
      get_command_byte_enable(byte_enable_temp, index, bfm_id, api_if);
      byte_enable := to_integer(byte_enable_temp);
   end get_command_byte_enable;

   procedure get_command_burst_cycle                                   (burst_cycle   : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MONITOR_GET_COMMAND_BURST_CYCLE) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_COMMAND_BURST_CYCLE) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_COMMAND_BURST_CYCLE) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_COMMAND_BURST_CYCLE) = '0');
      burst_cycle := ack_if(bfm_id).data_out0;
   end get_command_burst_cycle;

   procedure get_command_arbiterlock                                   (status        : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MONITOR_GET_COMMAND_ARBITERLOCK) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_COMMAND_ARBITERLOCK) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_COMMAND_ARBITERLOCK) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_COMMAND_ARBITERLOCK) = '0');
      status := ack_if(bfm_id).data_out0;
   end get_command_arbiterlock;

   procedure get_command_lock                                          (status        : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MONITOR_GET_COMMAND_LOCK) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_COMMAND_LOCK) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_COMMAND_LOCK) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_COMMAND_LOCK) = '0');
      status := ack_if(bfm_id).data_out0;
   end get_command_lock;

   procedure get_command_debugaccess                                   (status        : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MONITOR_GET_COMMAND_DEBUGACCESS) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_COMMAND_DEBUGACCESS) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_COMMAND_DEBUGACCESS) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_COMMAND_DEBUGACCESS) = '0');
      status := ack_if(bfm_id).data_out0;
   end get_command_debugaccess;

   procedure get_command_transaction_id                                (id            : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MONITOR_GET_COMMAND_TRANSACTION_ID) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_COMMAND_TRANSACTION_ID) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_COMMAND_TRANSACTION_ID) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_COMMAND_TRANSACTION_ID) = '0');
      id := ack_if(bfm_id).data_out0;
   end get_command_transaction_id;

   procedure get_command_write_response_request                        (request       : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MONITOR_GET_COMMAND_WRITE_RESPONSE_REQUEST) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_COMMAND_WRITE_RESPONSE_REQUEST) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_COMMAND_WRITE_RESPONSE_REQUEST) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_COMMAND_WRITE_RESPONSE_REQUEST) = '0');
      request := ack_if(bfm_id).data_out0;
   end get_command_write_response_request;

   procedure get_command_issued_queue_size                             (size          : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MONITOR_GET_COMMAND_ISSUED_QUEUE_SIZE) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_COMMAND_ISSUED_QUEUE_SIZE) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_COMMAND_ISSUED_QUEUE_SIZE) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_COMMAND_ISSUED_QUEUE_SIZE) = '0');
      size := ack_if(bfm_id).data_out0;
   end get_command_issued_queue_size;

   procedure get_response_address                                      (address       : out std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MONITOR_GET_RESPONSE_ADDRESS) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_RESPONSE_ADDRESS) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_RESPONSE_ADDRESS) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_RESPONSE_ADDRESS) = '0');
      address := ack_if(bfm_id).data_out2;
   end get_response_address;
   
   procedure get_response_address                                      (address         : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
      
      variable address_temp   : std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
   begin
      get_response_address(address_temp, bfm_id, api_if);
      address := to_integer(address_temp);
   end get_response_address;

   procedure get_response_byte_enable                                  (byte_enable   : out std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
                                                                        index         : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in1 <= index;
      api_if(bfm_id).req(MM_MONITOR_GET_RESPONSE_BYTE_ENABLE) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_RESPONSE_BYTE_ENABLE) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_RESPONSE_BYTE_ENABLE) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_RESPONSE_BYTE_ENABLE) = '0');
      byte_enable := ack_if(bfm_id).data_out2;
   end get_response_byte_enable;
   
   procedure get_response_byte_enable                                   (byte_enable   : out integer;
                                                                         index         : in integer;
                                                                         bfm_id        : in integer;
                                                                         signal api_if : inout mm_monitor_vhdl_if_t) is
      
      variable byte_enable_temp   : std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
   begin
      get_response_byte_enable(byte_enable_temp, index, bfm_id, api_if);
      byte_enable := to_integer(byte_enable_temp);
   end get_response_byte_enable;
   
   procedure get_response_burst_size                                   (burst_size       : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MONITOR_GET_RESPONSE_BURST_SIZE) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_RESPONSE_BURST_SIZE) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_RESPONSE_BURST_SIZE) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_RESPONSE_BURST_SIZE) = '0');
      burst_size := ack_if(bfm_id).data_out0;
   end get_response_burst_size;

   procedure get_response_data                                         (data          : out std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
                                                                        index         : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in1 <= index;
      api_if(bfm_id).req(MM_MONITOR_GET_RESPONSE_DATA) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_RESPONSE_DATA) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_RESPONSE_DATA) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_RESPONSE_DATA) = '0');
      data := ack_if(bfm_id).data_out2;
   end get_response_data;
   
   procedure get_response_data                                          (data          : out integer;
                                                                         index         : in integer;
                                                                         bfm_id        : in integer;
                                                                         signal api_if : inout mm_monitor_vhdl_if_t) is
      
      variable data_temp   : std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
   begin
      get_response_data(data_temp, index, bfm_id, api_if);
      data := to_integer(data_temp);
   end get_response_data;

   procedure get_response_latency                                      (cycles        : out integer;
                                                                        index         : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in1 <= index;
      api_if(bfm_id).req(MM_MONITOR_GET_RESPONSE_LATENCY) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_RESPONSE_LATENCY) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_RESPONSE_LATENCY) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_RESPONSE_LATENCY) = '0');
      cycles := ack_if(bfm_id).data_out0;
   end get_response_latency;
   
   procedure get_response_latency                                      (cycles        : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in1 <= 0;
      api_if(bfm_id).req(MM_MONITOR_GET_RESPONSE_LATENCY) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_RESPONSE_LATENCY) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_RESPONSE_LATENCY) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_RESPONSE_LATENCY) = '0');
      cycles := ack_if(bfm_id).data_out0;
   end get_response_latency;

   procedure get_response_request                                      (request       : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MONITOR_GET_RESPONSE_REQUEST) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_RESPONSE_REQUEST) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_RESPONSE_REQUEST) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_RESPONSE_REQUEST) = '0');
      request := ack_if(bfm_id).data_out0;
   end get_response_request;

   procedure get_response_queue_size                                   (size          : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MONITOR_GET_RESPONSE_QUEUE_SIZE) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_RESPONSE_QUEUE_SIZE) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_RESPONSE_QUEUE_SIZE) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_RESPONSE_QUEUE_SIZE) = '0');
      size := ack_if(bfm_id).data_out0;
   end get_response_queue_size;

   procedure get_response_wait_time                                    (cycles        : out integer;
                                                                        index         : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in1 <= index;
      api_if(bfm_id).req(MM_MONITOR_GET_RESPONSE_WAIT_TIME) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_RESPONSE_WAIT_TIME) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_RESPONSE_WAIT_TIME) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_RESPONSE_WAIT_TIME) = '0');
      cycles := ack_if(bfm_id).data_out0;
   end get_response_wait_time;

   procedure pop_response                                              (bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MONITOR_POP_RESPONSE) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_POP_RESPONSE) = '1');
      api_if(bfm_id).req(MM_MONITOR_POP_RESPONSE) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_POP_RESPONSE) = '0');
   end pop_response;

   procedure get_read_response_status                                  (response      : out integer;
                                                                        index         : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in1 <= index;
      api_if(bfm_id).req(MM_MONITOR_GET_READ_RESPONSE_STATUS) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_READ_RESPONSE_STATUS) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_READ_RESPONSE_STATUS) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_READ_RESPONSE_STATUS) = '0');
      response := ack_if(bfm_id).data_out0;
   end get_read_response_status;

   procedure get_response_read_id                                      (id            : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MONITOR_GET_RESPONSE_READ_ID) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_RESPONSE_READ_ID) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_RESPONSE_READ_ID) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_RESPONSE_READ_ID) = '0');
      id := ack_if(bfm_id).data_out0;
   end get_response_read_id;

   procedure get_write_response_status                                 (response      : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MONITOR_GET_WRITE_RESPONSE_STATUS) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_WRITE_RESPONSE_STATUS) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_WRITE_RESPONSE_STATUS) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_WRITE_RESPONSE_STATUS) = '0');
      response := ack_if(bfm_id).data_out0;
   end get_write_response_status;

   procedure get_response_write_id                                     (id            : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MONITOR_GET_RESPONSE_WRITE_ID) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_RESPONSE_WRITE_ID) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_RESPONSE_WRITE_ID) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_RESPONSE_WRITE_ID) = '0');
      id := ack_if(bfm_id).data_out0;
   end get_response_write_id;

   procedure get_clken                                                 (status        : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MONITOR_GET_CLKEN) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_CLKEN) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_CLKEN) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_CLKEN) = '0');
      status := ack_if(bfm_id).data_out0;
   end get_clken;

   procedure get_write_response_queue_size                             (size          : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MONITOR_GET_WRITE_RESPONSE_QUEUE_SIZE) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_WRITE_RESPONSE_QUEUE_SIZE) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_WRITE_RESPONSE_QUEUE_SIZE) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_WRITE_RESPONSE_QUEUE_SIZE) = '0');
      size := ack_if(bfm_id).data_out0;
   end get_write_response_queue_size;

   procedure get_read_response_queue_size                              (size          : out integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MONITOR_GET_READ_RESPONSE_QUEUE_SIZE) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_READ_RESPONSE_QUEUE_SIZE) = '1');
      api_if(bfm_id).req(MM_MONITOR_GET_READ_RESPONSE_QUEUE_SIZE) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_GET_READ_RESPONSE_QUEUE_SIZE) = '0');
      size := ack_if(bfm_id).data_out0;
   end get_read_response_queue_size;

   procedure init                                                      (bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MONITOR_INIT) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_INIT) = '1');
      api_if(bfm_id).req(MM_MONITOR_INIT) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MONITOR_INIT) = '0');
   end init;
   
   -- deprecated API
   procedure get_response_read_response                                (response      : out integer;
                                                                        index         : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      report "get_response_read_response API is no longer supported";
   end get_response_read_response;
   
   procedure get_response_write_response                               (response      : out integer;
                                                                        index         : in integer;
                                                                        bfm_id        : in integer;
                                                                        signal api_if : inout mm_monitor_vhdl_if_t) is
   begin
      report "get_response_write_response API is no longer supported";
   end get_response_write_response;
   
   -- VHDL events implementation
   procedure event_transaction_fifo_threshold        (bfm_id  : in integer) is
   begin
      wait until (ack_if(bfm_id).events(MM_MONITOR_EVENT_TRANSACTION_FIFO_THRESHOLD) = '1');
   end event_transaction_fifo_threshold;

   procedure event_transaction_fifo_overflow         (bfm_id  : in integer) is
   begin
      wait until (ack_if(bfm_id).events(MM_MONITOR_EVENT_TRANSACTION_FIFO_OVERFLOW) = '1');
   end event_transaction_fifo_overflow;

   procedure event_command_received                  (bfm_id  : in integer) is
   begin
      wait until (ack_if(bfm_id).events(MM_MONITOR_EVENT_COMMAND_RECEIVED) = '1');
   end event_command_received;

   procedure event_read_response_complete            (bfm_id  : in integer) is
   begin
      wait until (ack_if(bfm_id).events(MM_MONITOR_EVENT_READ_RESPONSE_COMPLETE) = '1');
   end event_read_response_complete;

   procedure event_write_response_complete           (bfm_id  : in integer) is
   begin
      wait until (ack_if(bfm_id).events(MM_MONITOR_EVENT_WRITE_RESPONSE_COMPLETE) = '1');
   end event_write_response_complete;

   procedure event_response_complete                 (bfm_id  : in integer) is
   begin
      wait until (ack_if(bfm_id).events(MM_MONITOR_EVENT_RESPONSE_COMPLETE) = '1');
   end event_response_complete;
   
end altera_avalon_mm_monitor_vhdl_pkg;
