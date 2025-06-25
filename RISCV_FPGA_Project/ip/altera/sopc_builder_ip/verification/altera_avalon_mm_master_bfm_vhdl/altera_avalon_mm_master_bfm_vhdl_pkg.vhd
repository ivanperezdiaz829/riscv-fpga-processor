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
package altera_avalon_mm_master_bfm_vhdl_pkg is

   -- maximum number of Avalon-MM master vhdl bfm
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
   
   -- idle output configuration type
   constant LOW         : integer := 0;
   constant HIGH        : integer := 1;
   constant RANDOM      : integer := 2;
   constant UNKNOWN     : integer := 3;
   
   -- mm_mstr_vhdl_api_e
   constant MM_MSTR_SET_RESPONSE_TIMEOUT                 : integer := 0;
   constant MM_MSTR_SET_COMMAND_TIMEOUT                  : integer := 1;
   constant MM_MSTR_ALL_TRANSACTIONS_COMPLETE            : integer := 2;
   constant MM_MSTR_GET_COMMAND_ISSUED_QUEUE_SIZE        : integer := 3;
   constant MM_MSTR_GET_COMMAND_PENDING_QUEUE_SIZE       : integer := 4;
   constant MM_MSTR_GET_RESPONSE_ADDRESS                 : integer := 5;
   constant MM_MSTR_GET_RESPONSE_BYTE_ENABLE             : integer := 6;
   constant MM_MSTR_GET_RESPONSE_BURST_SIZE              : integer := 7;
   constant MM_MSTR_GET_RESPONSE_DATA                    : integer := 8;
   constant MM_MSTR_GET_RESPONSE_LATENCY                 : integer := 9;
   constant MM_MSTR_GET_RESPONSE_REQUEST                 : integer := 10;
   constant MM_MSTR_GET_RESPONSE_QUEUE_SIZE              : integer := 11;
   constant MM_MSTR_GET_RESPONSE_WAIT_TIME               : integer := 12;
   constant MM_MSTR_POP_RESPONSE                         : integer := 13;
   constant MM_MSTR_PUSH_COMMAND                         : integer := 14;
   constant MM_MSTR_SET_COMMAND_ADDRESS                  : integer := 15;
   constant MM_MSTR_SET_COMMAND_BYTE_ENABLE              : integer := 16;
   constant MM_MSTR_SET_COMMAND_BURST_COUNT              : integer := 17;
   constant MM_MSTR_SET_COMMAND_BURST_SIZE               : integer := 18;
   constant MM_MSTR_SET_COMMAND_DATA                     : integer := 19;
   constant MM_MSTR_SET_COMMAND_IDLE                     : integer := 20;
   constant MM_MSTR_SET_COMMAND_INIT_LATENCY             : integer := 21;
   constant MM_MSTR_SET_COMMAND_REQUEST                  : integer := 22;
   constant MM_MSTR_SET_COMMAND_ARBITERLOCK              : integer := 23;
   constant MM_MSTR_SET_COMMAND_LOCK                     : integer := 24;
   constant MM_MSTR_SET_COMMAND_DEBUGACCESS              : integer := 25;
   constant MM_MSTR_SET_MAX_COMMAND_QUEUE_SIZE           : integer := 26;
   constant MM_MSTR_SET_MIN_COMMAND_QUEUE_SIZE           : integer := 27;
   constant MM_MSTR_SET_COMMAND_TRANSACTION_ID           : integer := 28;
   constant MM_MSTR_SET_COMMAND_WRITE_RESPONSE_REQUEST   : integer := 29;
   constant MM_MSTR_GET_READ_RESPONSE_STATUS             : integer := 30;
   constant MM_MSTR_GET_RESPONSE_READ_ID                 : integer := 31;
   constant MM_MSTR_GET_WRITE_RESPONSE_STATUS            : integer := 32;
   constant MM_MSTR_GET_RESPONSE_WRITE_ID                : integer := 33;
   constant MM_MSTR_GET_WRITE_RESPONSE_QUEUE_SIZE        : integer := 34;
   constant MM_MSTR_GET_READ_RESPONSE_QUEUE_SIZE         : integer := 35;
   constant MM_MSTR_SET_CLKEN                            : integer := 36;
   constant MM_MSTR_SET_IDLE_STATE_OUTPUT_CONFIGURATION  : integer := 37;
   constant MM_MSTR_GET_IDLE_STATE_OUTPUT_CONFIGURATION  : integer := 38;
   constant MM_MSTR_INIT                                 : integer := 39;
   
   -- mm_mstr_vhdl_event_e
   constant MM_MSTR_EVENT_READ_RESPONSE_COMPLETE         : integer := 0;
   constant MM_MSTR_EVENT_WRITE_RESPONSE_COMPLETE        : integer := 1;
   constant MM_MSTR_EVENT_RESPONSE_COMPLETE              : integer := 2;
   constant MM_MSTR_EVENT_COMMAND_ISSUED                 : integer := 3;
   constant MM_MSTR_EVENT_ALL_TRANSACTIONS_COMPLETE      : integer := 4;
   constant MM_MSTR_EVENT_MAX_COMMAND_QUEUE_SIZE         : integer := 5;
   constant MM_MSTR_EVENT_MIN_COMMAND_QUEUE_SIZE         : integer := 6;
   
   -- VHDL API request interface type
   type mm_mstr_vhdl_if_base_t is record
      req         : std_logic_vector (MM_MSTR_INIT downto 0);
      ack         : std_logic_vector (MM_MSTR_INIT downto 0);
      data_in0    : integer;
      data_in1    : integer;
      data_in2    : std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
      data_out0   : integer;
      data_out1   : integer;
      data_out2   : std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
      events      : std_logic_vector (MM_MSTR_EVENT_MIN_COMMAND_QUEUE_SIZE downto 0);
   end record;

   type mm_mstr_vhdl_if_t is array(MAX_VHDL_BFM - 1 downto 0) of mm_mstr_vhdl_if_base_t;
   
   signal req_if           : mm_mstr_vhdl_if_t;
   signal ack_if           : mm_mstr_vhdl_if_t;

   -- convert signal to integer
   function to_integer (OP: STD_LOGIC_VECTOR) return INTEGER;
   
   -- VHDL procedures
   procedure set_response_timeout         (timeout       : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure set_command_timeout          (timeout       : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure all_transactions_complete    (status        : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure get_command_issued_queue_size(size          : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure get_command_pending_queue_size(size         : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure get_response_address         (address       : out std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure get_response_address         (address       : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure get_response_byte_enable     (byte_enable   : out std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
                                           index         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure get_response_byte_enable     (byte_enable   : out integer;
                                           index         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure get_response_burst_size      (burst_size    : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure get_response_data            (data          : out std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
                                           index         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure get_response_data            (data          : out integer;
                                           index         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure get_response_latency         (cycles        : out integer;
                                           index         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure get_response_latency         (cycles        : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure get_response_request         (request       : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure get_response_queue_size      (size          : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure get_response_wait_time       (cycles        : out integer;
                                           index         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure pop_response                 (bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure push_command                 (bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure set_command_address          (address       : in std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure set_command_address          (address       : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure set_command_byte_enable      (byte_enable   : in std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
                                           index         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure set_command_byte_enable      (byte_enable   : in integer;
                                           index         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure set_command_burst_count      (burst_count   : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure set_command_burst_size       (burst_size    : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure set_command_data             (data          : in std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
                                           index         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure set_command_data             (data          : in integer;
                                           index         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure set_command_idle             (idle          : in integer;
                                           index         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure set_command_init_latency     (cycles        : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure set_command_request          (request       : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure set_command_arbiterlock      (state         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure set_command_lock             (state         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure set_command_debugaccess      (state         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure set_max_command_queue_size   (size          : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure set_min_command_queue_size   (size          : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure set_command_transaction_id   (id            : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure set_command_write_response_request(request  : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure get_read_response_status     (response      : out integer;
                                           index         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure get_response_read_id         (id            : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure get_write_response_status    (response      : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure get_response_write_id        (id            : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure get_write_response_queue_size(size          : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure get_read_response_queue_size (size          : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure set_clken                    (state         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   procedure init                         (bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);
   
   procedure set_idle_state_output_configuration  (config        : in integer;
                                                   bfm_id        : in integer;
                                                   signal api_if : inout mm_mstr_vhdl_if_t);
   
   procedure get_idle_state_output_configuration  (config        : out integer;
                                                   bfm_id        : in integer;
                                                   signal api_if : inout mm_mstr_vhdl_if_t);

   -- deprecated API
   procedure get_response_read_response   (response      : out integer;
                                           index         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);
                                           
   procedure get_response_write_response  (response      : out integer;
                                           index         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t);

   -- VHDL events
   procedure event_read_response_complete      (bfm_id  : in integer);
   procedure event_write_response_complete     (bfm_id  : in integer);
   procedure event_response_complete           (bfm_id  : in integer);
   procedure event_command_issued              (bfm_id  : in integer);
   procedure event_all_transactions_complete   (bfm_id  : in integer);
   procedure event_max_command_queue_size      (bfm_id  : in integer);
   procedure event_min_command_queue_size      (bfm_id  : in integer);

end altera_avalon_mm_master_bfm_vhdl_pkg;

-- VHDL procedures implementation
package body altera_avalon_mm_master_bfm_vhdl_pkg is

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
   
   procedure set_response_timeout         (timeout       : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= timeout;
      api_if(bfm_id).req(MM_MSTR_SET_RESPONSE_TIMEOUT) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_RESPONSE_TIMEOUT) = '1');
      api_if(bfm_id).req(MM_MSTR_SET_RESPONSE_TIMEOUT) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_RESPONSE_TIMEOUT) = '0');
   end set_response_timeout;

   procedure set_command_timeout          (timeout       : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= timeout;
      api_if(bfm_id).req(MM_MSTR_SET_COMMAND_TIMEOUT) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_COMMAND_TIMEOUT) = '1');
      api_if(bfm_id).req(MM_MSTR_SET_COMMAND_TIMEOUT) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_COMMAND_TIMEOUT) = '0');
   end set_command_timeout;
   
   procedure all_transactions_complete    (status        : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MSTR_ALL_TRANSACTIONS_COMPLETE) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_ALL_TRANSACTIONS_COMPLETE) = '1');
      api_if(bfm_id).req(MM_MSTR_ALL_TRANSACTIONS_COMPLETE) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_ALL_TRANSACTIONS_COMPLETE) = '0');
      status := ack_if(bfm_id).data_out0;
   end all_transactions_complete;

   procedure get_command_issued_queue_size(size          : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MSTR_GET_COMMAND_ISSUED_QUEUE_SIZE) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_COMMAND_ISSUED_QUEUE_SIZE) = '1');
      api_if(bfm_id).req(MM_MSTR_GET_COMMAND_ISSUED_QUEUE_SIZE) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_COMMAND_ISSUED_QUEUE_SIZE) = '0');
      size := ack_if(bfm_id).data_out0;
   end get_command_issued_queue_size;

   procedure get_command_pending_queue_size(size         : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MSTR_GET_COMMAND_PENDING_QUEUE_SIZE) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_COMMAND_PENDING_QUEUE_SIZE) = '1');
      api_if(bfm_id).req(MM_MSTR_GET_COMMAND_PENDING_QUEUE_SIZE) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_COMMAND_PENDING_QUEUE_SIZE) = '0');
      size := ack_if(bfm_id).data_out0;
   end get_command_pending_queue_size;

   procedure get_response_address         (address       : out std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MSTR_GET_RESPONSE_ADDRESS) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_RESPONSE_ADDRESS) = '1');
      api_if(bfm_id).req(MM_MSTR_GET_RESPONSE_ADDRESS) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_RESPONSE_ADDRESS) = '0');
      address := ack_if(bfm_id).data_out2;
   end get_response_address;

   procedure get_response_address         (address         : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
      
      variable address_temp   : std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
   begin
      get_response_address(address_temp, bfm_id, api_if);
      address := to_integer(address_temp);
   end get_response_address;

   procedure get_response_byte_enable     (byte_enable   : out std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
                                           index         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in1 <= index;
      api_if(bfm_id).req(MM_MSTR_GET_RESPONSE_BYTE_ENABLE) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_RESPONSE_BYTE_ENABLE) = '1');
      api_if(bfm_id).req(MM_MSTR_GET_RESPONSE_BYTE_ENABLE) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_RESPONSE_BYTE_ENABLE) = '0');
      byte_enable := ack_if(bfm_id).data_out2;
   end get_response_byte_enable;

   procedure get_response_byte_enable     (byte_enable   : out integer;
                                           index         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
      
      variable byte_enable_temp   : std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
   begin
      get_response_byte_enable(byte_enable_temp, index, bfm_id, api_if);
      byte_enable := to_integer(byte_enable_temp);
   end get_response_byte_enable;

   procedure get_response_burst_size      (burst_size    : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MSTR_GET_RESPONSE_BURST_SIZE) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_RESPONSE_BURST_SIZE) = '1');
      api_if(bfm_id).req(MM_MSTR_GET_RESPONSE_BURST_SIZE) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_RESPONSE_BURST_SIZE) = '0');
      burst_size := ack_if(bfm_id).data_out0;
   end get_response_burst_size;

   procedure get_response_data            (data          : out std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
                                           index         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in1 <= index;
      api_if(bfm_id).req(MM_MSTR_GET_RESPONSE_DATA) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_RESPONSE_DATA) = '1');
      api_if(bfm_id).req(MM_MSTR_GET_RESPONSE_DATA) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_RESPONSE_DATA) = '0');
      data := ack_if(bfm_id).data_out2;
   end get_response_data;

   procedure get_response_data            (data          : out integer;
                                           index         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
      
      variable data_temp   : std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
   begin
      get_response_data(data_temp, index, bfm_id, api_if);
      data := to_integer(data_temp);
   end get_response_data;

   procedure get_response_latency         (cycles        : out integer;
                                           index         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in1 <= index;
      api_if(bfm_id).req(MM_MSTR_GET_RESPONSE_LATENCY) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_RESPONSE_LATENCY) = '1');
      api_if(bfm_id).req(MM_MSTR_GET_RESPONSE_LATENCY) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_RESPONSE_LATENCY) = '0');
      cycles := ack_if(bfm_id).data_out0;
   end get_response_latency;
   
   procedure get_response_latency         (cycles        : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in1 <= 0;
      api_if(bfm_id).req(MM_MSTR_GET_RESPONSE_LATENCY) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_RESPONSE_LATENCY) = '1');
      api_if(bfm_id).req(MM_MSTR_GET_RESPONSE_LATENCY) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_RESPONSE_LATENCY) = '0');
      cycles := ack_if(bfm_id).data_out0;
   end get_response_latency;

   procedure get_response_request         (request       : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MSTR_GET_RESPONSE_REQUEST) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_RESPONSE_REQUEST) = '1');
      api_if(bfm_id).req(MM_MSTR_GET_RESPONSE_REQUEST) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_RESPONSE_REQUEST) = '0');
      request := ack_if(bfm_id).data_out0;
   end get_response_request;

   procedure get_response_queue_size      (size          : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MSTR_GET_RESPONSE_QUEUE_SIZE) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_RESPONSE_QUEUE_SIZE) = '1');
      api_if(bfm_id).req(MM_MSTR_GET_RESPONSE_QUEUE_SIZE) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_RESPONSE_QUEUE_SIZE) = '0');
      size := ack_if(bfm_id).data_out0;
   end get_response_queue_size;

   procedure get_response_wait_time       (cycles        : out integer;
                                           index         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in1 <= index;
      api_if(bfm_id).req(MM_MSTR_GET_RESPONSE_WAIT_TIME) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_RESPONSE_WAIT_TIME) = '1');
      api_if(bfm_id).req(MM_MSTR_GET_RESPONSE_WAIT_TIME) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_RESPONSE_WAIT_TIME) = '0');
      cycles := ack_if(bfm_id).data_out0;
   end get_response_wait_time;
   
   procedure pop_response                 (bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MSTR_POP_RESPONSE) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_POP_RESPONSE) = '1');
      api_if(bfm_id).req(MM_MSTR_POP_RESPONSE) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_POP_RESPONSE) = '0');
   end pop_response;

   procedure push_command                 (bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MSTR_PUSH_COMMAND) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_PUSH_COMMAND) = '1');
      api_if(bfm_id).req(MM_MSTR_PUSH_COMMAND) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_PUSH_COMMAND) = '0');
   end push_command;
   
   procedure set_command_address          (address       : in std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in2 <= address;
      api_if(bfm_id).req(MM_MSTR_SET_COMMAND_ADDRESS) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_COMMAND_ADDRESS) = '1');
      api_if(bfm_id).req(MM_MSTR_SET_COMMAND_ADDRESS) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_COMMAND_ADDRESS) = '0');
   end set_command_address;

   procedure set_command_address          (address       : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      set_command_address(conv_std_logic_vector(address, MM_MAX_BIT_W), bfm_id, api_if);
   end set_command_address;

   procedure set_command_byte_enable      (byte_enable   : in std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
                                           index         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in1 <= index;
      api_if(bfm_id).data_in2 <= byte_enable;
      api_if(bfm_id).req(MM_MSTR_SET_COMMAND_BYTE_ENABLE) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_COMMAND_BYTE_ENABLE) = '1');
      api_if(bfm_id).req(MM_MSTR_SET_COMMAND_BYTE_ENABLE) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_COMMAND_BYTE_ENABLE) = '0');
   end set_command_byte_enable;

   procedure set_command_byte_enable      (byte_enable   : in integer;
                                           index         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      set_command_byte_enable(conv_std_logic_vector(byte_enable, MM_MAX_BIT_W), index, bfm_id, api_if);
   end set_command_byte_enable;

   procedure set_command_burst_count      (burst_count   : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= burst_count;
      api_if(bfm_id).req(MM_MSTR_SET_COMMAND_BURST_COUNT) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_COMMAND_BURST_COUNT) = '1');
      api_if(bfm_id).req(MM_MSTR_SET_COMMAND_BURST_COUNT) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_COMMAND_BURST_COUNT) = '0');
   end set_command_burst_count;

   procedure set_command_burst_size       (burst_size    : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= burst_size;
      api_if(bfm_id).req(MM_MSTR_SET_COMMAND_BURST_SIZE) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_COMMAND_BURST_SIZE) = '1');
      api_if(bfm_id).req(MM_MSTR_SET_COMMAND_BURST_SIZE) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_COMMAND_BURST_SIZE) = '0');
   end set_command_burst_size;

   procedure set_command_data             (data          : in std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
                                           index         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in1 <= index;
      api_if(bfm_id).data_in2 <= data;
      api_if(bfm_id).req(MM_MSTR_SET_COMMAND_DATA) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_COMMAND_DATA) = '1');
      api_if(bfm_id).req(MM_MSTR_SET_COMMAND_DATA) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_COMMAND_DATA) = '0');
   end set_command_data;

   procedure set_command_data             (data          : in integer;
                                           index         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      set_command_data(conv_std_logic_vector(data, MM_MAX_BIT_W), index, bfm_id, api_if);
   end set_command_data;

   procedure set_command_idle             (idle          : in integer;
                                           index         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= idle;
      api_if(bfm_id).data_in1 <= index;
      api_if(bfm_id).req(MM_MSTR_SET_COMMAND_IDLE) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_COMMAND_IDLE) = '1');
      api_if(bfm_id).req(MM_MSTR_SET_COMMAND_IDLE) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_COMMAND_IDLE) = '0');
   end set_command_idle;

   procedure set_command_init_latency     (cycles        : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= cycles;
      api_if(bfm_id).req(MM_MSTR_SET_COMMAND_INIT_LATENCY) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_COMMAND_INIT_LATENCY) = '1');
      api_if(bfm_id).req(MM_MSTR_SET_COMMAND_INIT_LATENCY) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_COMMAND_INIT_LATENCY) = '0');
   end set_command_init_latency;

   procedure set_command_request          (request       : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= request;
      api_if(bfm_id).req(MM_MSTR_SET_COMMAND_REQUEST) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_COMMAND_REQUEST) = '1');
      api_if(bfm_id).req(MM_MSTR_SET_COMMAND_REQUEST) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_COMMAND_REQUEST) = '0');
   end set_command_request;

   procedure set_command_arbiterlock      (state         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= state;
      api_if(bfm_id).req(MM_MSTR_SET_COMMAND_ARBITERLOCK) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_COMMAND_ARBITERLOCK) = '1');
      api_if(bfm_id).req(MM_MSTR_SET_COMMAND_ARBITERLOCK) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_COMMAND_ARBITERLOCK) = '0');
   end set_command_arbiterlock;

   procedure set_command_lock             (state         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= state;
      api_if(bfm_id).req(MM_MSTR_SET_COMMAND_LOCK) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_COMMAND_LOCK) = '1');
      api_if(bfm_id).req(MM_MSTR_SET_COMMAND_LOCK) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_COMMAND_LOCK) = '0');
   end set_command_lock;

   procedure set_command_debugaccess      (state         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= state;
      api_if(bfm_id).req(MM_MSTR_SET_COMMAND_DEBUGACCESS) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_COMMAND_DEBUGACCESS) = '1');
      api_if(bfm_id).req(MM_MSTR_SET_COMMAND_DEBUGACCESS) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_COMMAND_DEBUGACCESS) = '0');
   end set_command_debugaccess;

   procedure set_max_command_queue_size   (size          : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= size;
      api_if(bfm_id).req(MM_MSTR_SET_MAX_COMMAND_QUEUE_SIZE) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_MAX_COMMAND_QUEUE_SIZE) = '1');
      api_if(bfm_id).req(MM_MSTR_SET_MAX_COMMAND_QUEUE_SIZE) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_MAX_COMMAND_QUEUE_SIZE) = '0');
   end set_max_command_queue_size;

   procedure set_min_command_queue_size   (size          : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= size;
      api_if(bfm_id).req(MM_MSTR_SET_MIN_COMMAND_QUEUE_SIZE) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_MIN_COMMAND_QUEUE_SIZE) = '1');
      api_if(bfm_id).req(MM_MSTR_SET_MIN_COMMAND_QUEUE_SIZE) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_MIN_COMMAND_QUEUE_SIZE) = '0');
   end set_min_command_queue_size;

   procedure set_command_transaction_id   (id            : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= id;
      api_if(bfm_id).req(MM_MSTR_SET_COMMAND_TRANSACTION_ID) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_COMMAND_TRANSACTION_ID) = '1');
      api_if(bfm_id).req(MM_MSTR_SET_COMMAND_TRANSACTION_ID) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_COMMAND_TRANSACTION_ID) = '0');
   end set_command_transaction_id;

   procedure set_command_write_response_request(request  : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= request;
      api_if(bfm_id).req(MM_MSTR_SET_COMMAND_WRITE_RESPONSE_REQUEST) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_COMMAND_WRITE_RESPONSE_REQUEST) = '1');
      api_if(bfm_id).req(MM_MSTR_SET_COMMAND_WRITE_RESPONSE_REQUEST) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_COMMAND_WRITE_RESPONSE_REQUEST) = '0');
   end set_command_write_response_request;
   
   procedure get_read_response_status     (response      : out integer;
                                           index         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in1 <= index;
      api_if(bfm_id).req(MM_MSTR_GET_READ_RESPONSE_STATUS) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_READ_RESPONSE_STATUS) = '1');
      api_if(bfm_id).req(MM_MSTR_GET_READ_RESPONSE_STATUS) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_READ_RESPONSE_STATUS) = '0');
      response := ack_if(bfm_id).data_out0;
   end get_read_response_status;

   procedure get_response_read_id         (id            : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MSTR_GET_RESPONSE_READ_ID) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_RESPONSE_READ_ID) = '1');
      api_if(bfm_id).req(MM_MSTR_GET_RESPONSE_READ_ID) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_RESPONSE_READ_ID) = '0');
      id := ack_if(bfm_id).data_out0;
   end get_response_read_id;

   procedure get_write_response_status    (response      : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MSTR_GET_WRITE_RESPONSE_STATUS) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_WRITE_RESPONSE_STATUS) = '1');
      api_if(bfm_id).req(MM_MSTR_GET_WRITE_RESPONSE_STATUS) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_WRITE_RESPONSE_STATUS) = '0');
      response := ack_if(bfm_id).data_out0;
   end get_write_response_status;

   procedure get_response_write_id        (id            : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MSTR_GET_RESPONSE_WRITE_ID) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_RESPONSE_WRITE_ID) = '1');
      api_if(bfm_id).req(MM_MSTR_GET_RESPONSE_WRITE_ID) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_RESPONSE_WRITE_ID) = '0');
      id := ack_if(bfm_id).data_out0;
   end get_response_write_id;

   procedure get_write_response_queue_size(size          : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MSTR_GET_WRITE_RESPONSE_QUEUE_SIZE) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_WRITE_RESPONSE_QUEUE_SIZE) = '1');
      api_if(bfm_id).req(MM_MSTR_GET_WRITE_RESPONSE_QUEUE_SIZE) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_WRITE_RESPONSE_QUEUE_SIZE) = '0');
      size := ack_if(bfm_id).data_out0;
   end get_write_response_queue_size;

   procedure get_read_response_queue_size (size          : out integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MSTR_GET_READ_RESPONSE_QUEUE_SIZE) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_READ_RESPONSE_QUEUE_SIZE) = '1');
      api_if(bfm_id).req(MM_MSTR_GET_READ_RESPONSE_QUEUE_SIZE) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_READ_RESPONSE_QUEUE_SIZE) = '0');
      size := ack_if(bfm_id).data_out0;
   end get_read_response_queue_size;
   
   procedure set_clken                    (state         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= state;
      api_if(bfm_id).req(MM_MSTR_SET_CLKEN) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_CLKEN) = '1');
      api_if(bfm_id).req(MM_MSTR_SET_CLKEN) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_CLKEN) = '0');
   end set_clken;
   
   procedure init                         (bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MSTR_INIT) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_INIT) = '1');
      api_if(bfm_id).req(MM_MSTR_INIT) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_INIT) = '0');
   end init;
   
   procedure set_idle_state_output_configuration  (config        : in integer;
                                                   bfm_id        : in integer;
                                                   signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= config;
      api_if(bfm_id).req(MM_MSTR_SET_IDLE_STATE_OUTPUT_CONFIGURATION) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_IDLE_STATE_OUTPUT_CONFIGURATION) = '1');
      api_if(bfm_id).req(MM_MSTR_SET_IDLE_STATE_OUTPUT_CONFIGURATION) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_SET_IDLE_STATE_OUTPUT_CONFIGURATION) = '0');
   end set_idle_state_output_configuration;
   
   procedure get_idle_state_output_configuration   (config        : out integer;
                                                    bfm_id        : in integer;
                                                    signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).req(MM_MSTR_GET_IDLE_STATE_OUTPUT_CONFIGURATION) <= '1';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_IDLE_STATE_OUTPUT_CONFIGURATION) = '1');
      api_if(bfm_id).req(MM_MSTR_GET_IDLE_STATE_OUTPUT_CONFIGURATION) <= '0';
      wait until (ack_if(bfm_id).ack(MM_MSTR_GET_IDLE_STATE_OUTPUT_CONFIGURATION) = '0');
      config := ack_if(bfm_id).data_out0;
   end get_idle_state_output_configuration;
   
   -- deprecated API
   procedure get_response_read_response   (response      : out integer;
                                           index         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      report "get_response_read_response API is no longer supported";
   end get_response_read_response;
                                           
   procedure get_response_write_response  (response      : out integer;
                                           index         : in integer;
                                           bfm_id        : in integer;
                                           signal api_if : inout mm_mstr_vhdl_if_t) is
   begin
      report "get_response_write_response API is no longer supported";
   end get_response_write_response;
   
   -- VHDL events implementation
      procedure event_read_response_complete      (bfm_id  : in integer) is
   begin
      wait until (ack_if(bfm_id).events(MM_MSTR_EVENT_READ_RESPONSE_COMPLETE) = '1');
   end event_read_response_complete;
   
   procedure event_write_response_complete     (bfm_id  : in integer) is
   begin
      wait until (ack_if(bfm_id).events(MM_MSTR_EVENT_WRITE_RESPONSE_COMPLETE) = '1');
   end event_write_response_complete;
   
   procedure event_response_complete           (bfm_id  : in integer) is
   begin
      wait until (ack_if(bfm_id).events(MM_MSTR_EVENT_RESPONSE_COMPLETE) = '1');
   end event_response_complete;
   
   procedure event_command_issued              (bfm_id  : in integer) is
   begin
      wait until (ack_if(bfm_id).events(MM_MSTR_EVENT_COMMAND_ISSUED) = '1');
   end event_command_issued;
   
   procedure event_all_transactions_complete   (bfm_id  : in integer) is
   begin
      wait until (ack_if(bfm_id).events(MM_MSTR_EVENT_ALL_TRANSACTIONS_COMPLETE) = '1');
   end event_all_transactions_complete;
   
   procedure event_max_command_queue_size      (bfm_id  : in integer) is
   begin
      wait until (ack_if(bfm_id).events(MM_MSTR_EVENT_MAX_COMMAND_QUEUE_SIZE) = '1');
   end event_max_command_queue_size;
   
   procedure event_min_command_queue_size      (bfm_id  : in integer) is
   begin
      wait until (ack_if(bfm_id).events(MM_MSTR_EVENT_MIN_COMMAND_QUEUE_SIZE) = '1');
   end event_min_command_queue_size;
   
end altera_avalon_mm_master_bfm_vhdl_pkg;
