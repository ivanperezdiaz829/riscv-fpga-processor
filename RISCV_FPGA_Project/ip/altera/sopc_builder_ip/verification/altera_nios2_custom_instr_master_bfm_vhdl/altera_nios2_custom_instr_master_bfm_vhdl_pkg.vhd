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
use ieee.std_logic_signed.all;

library work;
use work.all;

-- VHDL procedure declarations
package altera_nios2_custom_instr_master_bfm_vhdl_pkg is

   -- maximum number of Nios II custom instruction master vhdl bfm
   constant MAX_VHDL_BFM : integer := 1024;
   
   -- maximu number of bits in custom instruction bfm
   constant CI_MAX_BIT_W : integer := 352;
   
   -- idle output configuration type
   constant LOW         : integer := 0;
   constant HIGH        : integer := 1;
   constant RANDOM      : integer := 2;
   constant UNKNOWN     : integer := 3;
   
   -- ci_mstr_vhdl_api_e
   constant CI_MSTR_SET_CI_CLK_EN                        : integer := 0;
   constant CI_MSTR_INSERT_INSTRUCTION                   : integer := 1;
   constant CI_MSTR_RETRIVE_RESULT                       : integer := 2;
   constant CI_MSTR_SET_INSTRUCTION_DATAA                : integer := 3;
   constant CI_MSTR_SET_INSTRUCTION_DATAB                : integer := 4;
   constant CI_MSTR_SET_INSTRUCTION_N                    : integer := 5;
   constant CI_MSTR_SET_INSTRUCTION_A                    : integer := 6;
   constant CI_MSTR_SET_INSTRUCTION_B                    : integer := 7;
   constant CI_MSTR_SET_INSTRUCTION_C                    : integer := 8;
   constant CI_MSTR_SET_INSTRUCTION_READRA               : integer := 9;
   constant CI_MSTR_SET_INSTRUCTION_READRB               : integer := 10;
   constant CI_MSTR_SET_INSTRUCTION_WRITERC              : integer := 11;
   constant CI_MSTR_SET_INSTRUCTION_IDLE                 : integer := 12;
   constant CI_MSTR_SET_INSTRUCTION_ERR_INJECT           : integer := 13;
   constant CI_MSTR_GET_RESULT_VALUE                     : integer := 14;
   constant CI_MSTR_GET_RESULT_DELAY                     : integer := 15;
   constant CI_MSTR_PUSH_INSTRUCTION                     : integer := 16;
   constant CI_MSTR_POP_RESULT                           : integer := 17;
   constant CI_MSTR_SET_MAX_INSTRUCTION_QUEUE_SIZE       : integer := 18;
   constant CI_MSTR_SET_MIN_INSTRUCTION_QUEUE_SIZE       : integer := 19;
   constant CI_MSTR_SET_MAX_RESULT_QUEUE_SIZE            : integer := 20;
   constant CI_MSTR_SET_MIN_RESULT_QUEUE_SIZE            : integer := 21;
   constant CI_MSTR_GET_INSTRUCTION_QUEUE_SIZE           : integer := 22;
   constant CI_MSTR_GET_RESULT_QUEUE_SIZE                : integer := 23;
   constant CI_MSTR_SET_INSTRUCTION_TIMEOUT              : integer := 24;
   constant CI_MSTR_SET_RESULT_TIMEOUT                   : integer := 25;
   constant CI_MSTR_SET_IDLE_STATE_OUTPUT_CONFIGURATION  : integer := 26;
   constant CI_MSTR_GET_IDLE_STATE_OUTPUT_CONFIGURATION  : integer := 27;
   constant CI_MSTR_SET_CLOCK_ENABLE_TIMEOUT             : integer := 28;
   
   -- ci_mstr_vhdl_event_e
   constant CI_MSTR_EVENT_INSTRUCTION_START              : integer := 0;
   constant CI_MSTR_EVENT_RESULT_RECEIVED                : integer := 1;
   constant CI_MSTR_EVENT_UNEXPECTED_RESULT_RECEIVED     : integer := 2;
   constant CI_MSTR_EVENT_INSTRUCTIONS_COMPLETED         : integer := 3;
   constant CI_MSTR_EVENT_MAX_INSTRUCTION_QUEUE_SIZE     : integer := 4;
   constant CI_MSTR_EVENT_MIN_INSTRUCTION_QUEUE_SIZE     : integer := 5;
   constant CI_MSTR_EVENT_MAX_RESULT_QUEUE_SIZE          : integer := 6;
   constant CI_MSTR_EVENT_MIN_RESULT_QUEUE_SIZE          : integer := 7;

    -- VHDL API request interface type
   type ci_mstr_vhdl_if_base_t is record
      req         : std_logic_vector (CI_MSTR_SET_CLOCK_ENABLE_TIMEOUT downto 0);
      ack         : std_logic_vector (CI_MSTR_SET_CLOCK_ENABLE_TIMEOUT downto 0);
      data_in0    : integer;
      data_in1    : std_logic_vector (CI_MAX_BIT_W - 1 downto 0);
      data_out0   : integer;
      data_out1   : std_logic_vector (CI_MAX_BIT_W - 1 downto 0);
      events      : std_logic_vector (CI_MSTR_EVENT_MIN_RESULT_QUEUE_SIZE downto 0);
   end record;
   
   type ci_mstr_vhdl_if_t is array(MAX_VHDL_BFM - 1 downto 0) of ci_mstr_vhdl_if_base_t;
   
   signal req_if           : ci_mstr_vhdl_if_t;
   signal ack_if           : ci_mstr_vhdl_if_t;

   -- VHDL procedures
   procedure set_ci_clk_en                     (enable        : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t);

   procedure insert_instruction                (dataa         : in integer;
                                                datab         : in integer;
                                                n             : in integer;
                                                a             : in integer;
                                                b             : in integer;
                                                c             : in integer;
                                                readra        : in integer;
                                                readrb        : in integer;
                                                writerc       : in integer;
                                                idle          : in integer;
                                                err_inj       : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t);

   procedure retrive_result                    (result_value  : out integer;
                                                delay         : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t);

   procedure set_instruction_dataa             (dataa         : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t);

   procedure set_instruction_datab             (datab         : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t);

   procedure set_instruction_n                 (n             : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t);

   procedure set_instruction_a                 (a             : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t);

   procedure set_instruction_b                 (b             : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t);

   procedure set_instruction_c                 (c             : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t);

   procedure set_instruction_readra            (readra        : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t);

   procedure set_instruction_readrb            (readrb        : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t);

   procedure set_instruction_writerc           (writerc       : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t);

   procedure set_instruction_idle              (idle          : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t);

   procedure set_instruction_err_inject        (err_inj       : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t);

   procedure get_result_value                  (result_value  : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t);

   procedure get_result_delay                  (delay         : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t);
   
   procedure push_instruction                  (bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t);

   procedure pop_result                        (bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t);

   procedure set_max_instruction_queue_size    (size          : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t);

   procedure set_min_instruction_queue_size    (size          : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t);

   procedure set_max_result_queue_size         (size          : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t);

   procedure set_min_result_queue_size         (size          : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t);

   procedure get_instruction_queue_size        (size          : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t);

   procedure get_result_queue_size             (size          : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t);

   procedure set_instruction_timeout           (timeout       : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t);

   procedure set_result_timeout                (timeout       : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t);
   
   procedure set_idle_state_output_configuration   (config        : in integer;
                                                    bfm_id        : in integer;
                                                    signal api_if : inout ci_mstr_vhdl_if_t);
   
   procedure get_idle_state_output_configuration   (config        : out integer;
                                                    bfm_id        : in integer;
                                                    signal api_if : inout ci_mstr_vhdl_if_t);

   procedure set_clock_enable_timeout          (timeout       : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t);
   
   -- VHDL events
   procedure event_instruction_start           (bfm_id        : in integer);
   procedure event_result_received             (bfm_id        : in integer);
   procedure event_unexpected_result_received  (bfm_id        : in integer);
   procedure event_instructions_completed      (bfm_id        : in integer);
   procedure event_max_instruction_queue_size  (bfm_id        : in integer);
   procedure event_min_instruction_queue_size  (bfm_id        : in integer);
   procedure event_max_result_queue_size       (bfm_id        : in integer);
   procedure event_min_result_queue_size       (bfm_id        : in integer);

end altera_nios2_custom_instr_master_bfm_vhdl_pkg;

-- VHDL procedures implementation
package body altera_nios2_custom_instr_master_bfm_vhdl_pkg is

   procedure set_ci_clk_en                     (enable        : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= enable;
      api_if(bfm_id).req(CI_MSTR_SET_CI_CLK_EN) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_CI_CLK_EN) = '1');
      api_if(bfm_id).req(CI_MSTR_SET_CI_CLK_EN) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_CI_CLK_EN) = '0');
   end set_ci_clk_en;

   procedure insert_instruction                (dataa         : in integer;
                                                datab         : in integer;
                                                n             : in integer;
                                                a             : in integer;
                                                b             : in integer;
                                                c             : in integer;
                                                readra        : in integer;
                                                readrb        : in integer;
                                                writerc       : in integer;
                                                idle          : in integer;
                                                err_inj       : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in1 <= conv_std_logic_vector(dataa,32) & conv_std_logic_vector(datab,32) & conv_std_logic_vector(n,32)
                                 & conv_std_logic_vector(a,32) & conv_std_logic_vector(b,32) & conv_std_logic_vector(c,32)
                                 & conv_std_logic_vector(readra,32) & conv_std_logic_vector(readrb,32)
                                 & conv_std_logic_vector(writerc,32) & conv_std_logic_vector(idle,32) & conv_std_logic_vector(err_inj,32);
      api_if(bfm_id).req(CI_MSTR_INSERT_INSTRUCTION) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_INSERT_INSTRUCTION) = '1');
      api_if(bfm_id).req(CI_MSTR_INSERT_INSTRUCTION) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_INSERT_INSTRUCTION) = '0');
   end insert_instruction;

   procedure retrive_result                    (result_value  : out integer;
                                                delay         : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).req(CI_MSTR_RETRIVE_RESULT) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_RETRIVE_RESULT) = '1');
      api_if(bfm_id).req(CI_MSTR_RETRIVE_RESULT) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_RETRIVE_RESULT) = '0');
      result_value := conv_integer(ack_if(bfm_id).data_out1(63 downto 32));
      delay := conv_integer(ack_if(bfm_id).data_out1(31 downto 0));
   end retrive_result;

   procedure set_instruction_dataa             (dataa         : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= dataa;
      api_if(bfm_id).req(CI_MSTR_SET_INSTRUCTION_DATAA) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_INSTRUCTION_DATAA) = '1');
      api_if(bfm_id).req(CI_MSTR_SET_INSTRUCTION_DATAA) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_INSTRUCTION_DATAA) = '0');
   end set_instruction_dataa;

   procedure set_instruction_datab             (datab         : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= datab;
      api_if(bfm_id).req(CI_MSTR_SET_INSTRUCTION_DATAB) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_INSTRUCTION_DATAB) = '1');
      api_if(bfm_id).req(CI_MSTR_SET_INSTRUCTION_DATAB) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_INSTRUCTION_DATAB) = '0');
   end set_instruction_datab;

   procedure set_instruction_n                 (n             : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= n;
      api_if(bfm_id).req(CI_MSTR_SET_INSTRUCTION_N) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_INSTRUCTION_N) = '1');
      api_if(bfm_id).req(CI_MSTR_SET_INSTRUCTION_N) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_INSTRUCTION_N) = '0');
   end set_instruction_n;

   procedure set_instruction_a                 (a             : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= a;
      api_if(bfm_id).req(CI_MSTR_SET_INSTRUCTION_A) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_INSTRUCTION_A) = '1');
      api_if(bfm_id).req(CI_MSTR_SET_INSTRUCTION_A) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_INSTRUCTION_A) = '0');
   end set_instruction_a;

   procedure set_instruction_b                 (b             : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= b;
      api_if(bfm_id).req(CI_MSTR_SET_INSTRUCTION_B) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_INSTRUCTION_B) = '1');
      api_if(bfm_id).req(CI_MSTR_SET_INSTRUCTION_B) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_INSTRUCTION_B) = '0');
   end set_instruction_b;

   procedure set_instruction_c                 (c             : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= c;
      api_if(bfm_id).req(CI_MSTR_SET_INSTRUCTION_C) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_INSTRUCTION_C) = '1');
      api_if(bfm_id).req(CI_MSTR_SET_INSTRUCTION_C) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_INSTRUCTION_C) = '0');
   end set_instruction_c;

   procedure set_instruction_readra            (readra        : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= readra;
      api_if(bfm_id).req(CI_MSTR_SET_INSTRUCTION_READRA) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_INSTRUCTION_READRA) = '1');
      api_if(bfm_id).req(CI_MSTR_SET_INSTRUCTION_READRA) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_INSTRUCTION_READRA) = '0');
   end set_instruction_readra;

   procedure set_instruction_readrb            (readrb        : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= readrb;
      api_if(bfm_id).req(CI_MSTR_SET_INSTRUCTION_READRB) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_INSTRUCTION_READRB) = '1');
      api_if(bfm_id).req(CI_MSTR_SET_INSTRUCTION_READRB) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_INSTRUCTION_READRB) = '0');
   end set_instruction_readrb;

   procedure set_instruction_writerc           (writerc       : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= writerc;
      api_if(bfm_id).req(CI_MSTR_SET_INSTRUCTION_WRITERC) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_INSTRUCTION_WRITERC) = '1');
      api_if(bfm_id).req(CI_MSTR_SET_INSTRUCTION_WRITERC) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_INSTRUCTION_WRITERC) = '0');
   end set_instruction_writerc;

   procedure set_instruction_idle              (idle          : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= idle;
      api_if(bfm_id).req(CI_MSTR_SET_INSTRUCTION_IDLE) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_INSTRUCTION_IDLE) = '1');
      api_if(bfm_id).req(CI_MSTR_SET_INSTRUCTION_IDLE) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_INSTRUCTION_IDLE) = '0');
   end set_instruction_idle;

   procedure set_instruction_err_inject        (err_inj       : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= err_inj;
      api_if(bfm_id).req(CI_MSTR_SET_INSTRUCTION_ERR_INJECT) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_INSTRUCTION_ERR_INJECT) = '1');
      api_if(bfm_id).req(CI_MSTR_SET_INSTRUCTION_ERR_INJECT) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_INSTRUCTION_ERR_INJECT) = '0');
   end set_instruction_err_inject;

   procedure get_result_value                  (result_value  : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).req(CI_MSTR_GET_RESULT_VALUE) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_GET_RESULT_VALUE) = '1');
      api_if(bfm_id).req(CI_MSTR_GET_RESULT_VALUE) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_GET_RESULT_VALUE) = '0');
      result_value := ack_if(bfm_id).data_out0;
   end get_result_value;

   procedure get_result_delay                  (delay         : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).req(CI_MSTR_GET_RESULT_DELAY) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_GET_RESULT_DELAY) = '1');
      api_if(bfm_id).req(CI_MSTR_GET_RESULT_DELAY) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_GET_RESULT_DELAY) = '0');
      delay := ack_if(bfm_id).data_out0;
   end get_result_delay;

   procedure push_instruction                  (bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).req(CI_MSTR_PUSH_INSTRUCTION) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_PUSH_INSTRUCTION) = '1');
      api_if(bfm_id).req(CI_MSTR_PUSH_INSTRUCTION) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_PUSH_INSTRUCTION) = '0');
   end push_instruction;

   procedure pop_result                        (bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).req(CI_MSTR_POP_RESULT) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_POP_RESULT) = '1');
      api_if(bfm_id).req(CI_MSTR_POP_RESULT) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_POP_RESULT) = '0');
   end pop_result;

   procedure set_max_instruction_queue_size    (size          : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= size;
      api_if(bfm_id).req(CI_MSTR_SET_MAX_INSTRUCTION_QUEUE_SIZE) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_MAX_INSTRUCTION_QUEUE_SIZE) = '1');
      api_if(bfm_id).req(CI_MSTR_SET_MAX_INSTRUCTION_QUEUE_SIZE) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_MAX_INSTRUCTION_QUEUE_SIZE) = '0');
   end set_max_instruction_queue_size;

   procedure set_min_instruction_queue_size    (size          : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= size;
      api_if(bfm_id).req(CI_MSTR_SET_MIN_INSTRUCTION_QUEUE_SIZE) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_MIN_INSTRUCTION_QUEUE_SIZE) = '1');
      api_if(bfm_id).req(CI_MSTR_SET_MIN_INSTRUCTION_QUEUE_SIZE) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_MIN_INSTRUCTION_QUEUE_SIZE) = '0');
   end set_min_instruction_queue_size;

   procedure set_max_result_queue_size         (size          : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= size;
      api_if(bfm_id).req(CI_MSTR_SET_MAX_RESULT_QUEUE_SIZE) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_MAX_RESULT_QUEUE_SIZE) = '1');
      api_if(bfm_id).req(CI_MSTR_SET_MAX_RESULT_QUEUE_SIZE) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_MAX_RESULT_QUEUE_SIZE) = '0');
   end set_max_result_queue_size;

   procedure set_min_result_queue_size         (size          : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= size;
      api_if(bfm_id).req(CI_MSTR_SET_MIN_RESULT_QUEUE_SIZE) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_MIN_RESULT_QUEUE_SIZE) = '1');
      api_if(bfm_id).req(CI_MSTR_SET_MIN_RESULT_QUEUE_SIZE) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_MIN_RESULT_QUEUE_SIZE) = '0');
   end set_min_result_queue_size;

   procedure get_instruction_queue_size        (size          : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).req(CI_MSTR_GET_INSTRUCTION_QUEUE_SIZE) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_GET_INSTRUCTION_QUEUE_SIZE) = '1');
      api_if(bfm_id).req(CI_MSTR_GET_INSTRUCTION_QUEUE_SIZE) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_GET_INSTRUCTION_QUEUE_SIZE) = '0');
      size := ack_if(bfm_id).data_out0;
   end get_instruction_queue_size;

   procedure get_result_queue_size             (size          : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).req(CI_MSTR_GET_RESULT_QUEUE_SIZE) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_GET_RESULT_QUEUE_SIZE) = '1');
      api_if(bfm_id).req(CI_MSTR_GET_RESULT_QUEUE_SIZE) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_GET_RESULT_QUEUE_SIZE) = '0');
      size := ack_if(bfm_id).data_out0;
   end get_result_queue_size;

   procedure set_instruction_timeout           (timeout       : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= timeout;
      api_if(bfm_id).req(CI_MSTR_SET_INSTRUCTION_TIMEOUT) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_INSTRUCTION_TIMEOUT) = '1');
      api_if(bfm_id).req(CI_MSTR_SET_INSTRUCTION_TIMEOUT) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_INSTRUCTION_TIMEOUT) = '0');
   end set_instruction_timeout;

   procedure set_result_timeout                (timeout       : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= timeout;
      api_if(bfm_id).req(CI_MSTR_SET_RESULT_TIMEOUT) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_RESULT_TIMEOUT) = '1');
      api_if(bfm_id).req(CI_MSTR_SET_RESULT_TIMEOUT) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_RESULT_TIMEOUT) = '0');
   end set_result_timeout;
   
   procedure set_idle_state_output_configuration   (config        : in integer;
                                                    bfm_id        : in integer;
                                                    signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= config;
      api_if(bfm_id).req(CI_MSTR_SET_IDLE_STATE_OUTPUT_CONFIGURATION) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_IDLE_STATE_OUTPUT_CONFIGURATION) = '1');
      api_if(bfm_id).req(CI_MSTR_SET_IDLE_STATE_OUTPUT_CONFIGURATION) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_IDLE_STATE_OUTPUT_CONFIGURATION) = '0');
   end set_idle_state_output_configuration;
   
   procedure get_idle_state_output_configuration   (config        : out integer;
                                                    bfm_id        : in integer;
                                                    signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).req(CI_MSTR_GET_IDLE_STATE_OUTPUT_CONFIGURATION) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_GET_IDLE_STATE_OUTPUT_CONFIGURATION) = '1');
      api_if(bfm_id).req(CI_MSTR_GET_IDLE_STATE_OUTPUT_CONFIGURATION) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_GET_IDLE_STATE_OUTPUT_CONFIGURATION) = '0');
      config := ack_if(bfm_id).data_out0;
   end get_idle_state_output_configuration;

   procedure set_clock_enable_timeout          (timeout       : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_mstr_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= timeout;
      api_if(bfm_id).req(CI_MSTR_SET_CLOCK_ENABLE_TIMEOUT) <= '1';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_CLOCK_ENABLE_TIMEOUT) = '1');
      api_if(bfm_id).req(CI_MSTR_SET_CLOCK_ENABLE_TIMEOUT) <= '0';
      wait until (ack_if(bfm_id).ack(CI_MSTR_SET_CLOCK_ENABLE_TIMEOUT) = '0');
   end set_clock_enable_timeout;
   
   -- VHDL events implementation
   procedure event_instruction_start           (bfm_id        : in integer) is
   begin
      wait until (ack_if(bfm_id).events(CI_MSTR_EVENT_INSTRUCTION_START) = '1');
   end event_instruction_start;

   procedure event_result_received             (bfm_id        : in integer) is
   begin
      wait until (ack_if(bfm_id).events(CI_MSTR_EVENT_RESULT_RECEIVED) = '1');
   end event_result_received;

   procedure event_unexpected_result_received  (bfm_id        : in integer) is
   begin
      wait until (ack_if(bfm_id).events(CI_MSTR_EVENT_UNEXPECTED_RESULT_RECEIVED) = '1');
   end event_unexpected_result_received;

   procedure event_instructions_completed      (bfm_id        : in integer) is
   begin
      wait until (ack_if(bfm_id).events(CI_MSTR_EVENT_INSTRUCTIONS_COMPLETED) = '1');
   end event_instructions_completed;

   procedure event_max_instruction_queue_size  (bfm_id        : in integer) is
   begin
      wait until (ack_if(bfm_id).events(CI_MSTR_EVENT_MAX_INSTRUCTION_QUEUE_SIZE) = '1');
   end event_max_instruction_queue_size;

   procedure event_min_instruction_queue_size  (bfm_id        : in integer) is
   begin
      wait until (ack_if(bfm_id).events(CI_MSTR_EVENT_MIN_INSTRUCTION_QUEUE_SIZE) = '1');
   end event_min_instruction_queue_size;

   procedure event_max_result_queue_size       (bfm_id        : in integer) is
   begin
      wait until (ack_if(bfm_id).events(CI_MSTR_EVENT_MAX_RESULT_QUEUE_SIZE) = '1');
   end event_max_result_queue_size;

   procedure event_min_result_queue_size       (bfm_id        : in integer) is
   begin
      wait until (ack_if(bfm_id).events(CI_MSTR_EVENT_MIN_RESULT_QUEUE_SIZE) = '1');
   end event_min_result_queue_size;
   
end altera_nios2_custom_instr_master_bfm_vhdl_pkg;
