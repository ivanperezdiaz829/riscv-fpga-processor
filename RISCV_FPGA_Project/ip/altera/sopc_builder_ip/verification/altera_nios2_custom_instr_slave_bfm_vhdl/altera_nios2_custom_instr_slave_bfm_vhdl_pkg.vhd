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
package altera_nios2_custom_instr_slave_bfm_vhdl_pkg is

   -- maximum number of Nios II custom instruction slave vhdl bfm
   constant MAX_VHDL_BFM : integer := 1024;
   
   -- maximum number of bits in custom instruction bfm
   constant CI_MAX_BIT_W : integer := 352;
   
   -- idle output configuration type
   constant LOW         : integer := 0;
   constant HIGH        : integer := 1;
   constant RANDOM      : integer := 2;
   constant UNKNOWN     : integer := 3;
   
   -- ci_slv_vhdl_api_e
   constant CI_SLV_GET_CI_CLK_EN                         : integer := 0;
   constant CI_SLV_RETRIEVE_INSTRUCTION                  : integer := 1;
   constant CI_SLV_INSERT_RESULT                         : integer := 2;
   constant CI_SLV_GET_INSTRUCTION_DATAA                 : integer := 3;
   constant CI_SLV_GET_INSTRUCTION_DATAB                 : integer := 4;
   constant CI_SLV_GET_INSTRUCTION_N                     : integer := 5;
   constant CI_SLV_GET_INSTRUCTION_A                     : integer := 6;
   constant CI_SLV_GET_INSTRUCTION_B                     : integer := 7;
   constant CI_SLV_GET_INSTRUCTION_C                     : integer := 8;
   constant CI_SLV_GET_INSTRUCTION_READRA                : integer := 9;
   constant CI_SLV_GET_INSTRUCTION_READRB                : integer := 10;
   constant CI_SLV_GET_INSTRUCTION_WRITERC               : integer := 11;
   constant CI_SLV_GET_INSTRUCTION_IDLE                  : integer := 12;
   constant CI_SLV_SET_RESULT_VALUE                      : integer := 13;
   constant CI_SLV_SET_RESULT_DELAY                      : integer := 14;
   constant CI_SLV_SET_RESULT_ERR_INJECT                 : integer := 15;
   constant CI_SLV_SET_INSTRUCTION_TIMEOUT               : integer := 16;
   constant CI_SLV_SET_IDLE_STATE_OUTPUT_CONFIGURATION   : integer := 17;
   constant CI_SLV_GET_IDLE_STATE_OUTPUT_CONFIGURATION   : integer := 18;
   constant CI_SLV_SET_CLOCK_ENABLE_TIMEOUT              : integer := 19;
   
   -- ci_slv_vhdl_event_e
   constant CI_SLV_EVENT_KNOWN_INSTRUCTION_RECEIVED      : integer := 0;
   constant CI_SLV_EVENT_UNKNOWN_INSTRUCTION_RECEIVED    : integer := 1;
   constant CI_SLV_EVENT_INSTRUCTION_INCONSISTENT        : integer := 2;
   constant CI_SLV_EVENT_RESULT_DRIVEN                   : integer := 3;
   constant CI_SLV_EVENT_RESULT_DONE                     : integer := 4;
   constant CI_SLV_EVENT_INSTRUCTION_UNCHANGED           : integer := 5;
   
   -- VHDL API request interface type
   type ci_slv_vhdl_if_base_t is record
      req         : std_logic_vector (CI_SLV_SET_CLOCK_ENABLE_TIMEOUT downto 0);
      ack         : std_logic_vector (CI_SLV_SET_CLOCK_ENABLE_TIMEOUT downto 0);
      data_in0    : integer;
      data_in1    : std_logic_vector (CI_MAX_BIT_W - 1 downto 0);
      data_out0   : integer;
      data_out1   : std_logic_vector (CI_MAX_BIT_W - 1 downto 0);
      events      : std_logic_vector (CI_SLV_EVENT_INSTRUCTION_UNCHANGED downto 0);
   end record;
   
   type ci_slv_vhdl_if_t is array(MAX_VHDL_BFM - 1 downto 0) of ci_slv_vhdl_if_base_t;
   
   signal req_if           : ci_slv_vhdl_if_t;
   signal ack_if           : ci_slv_vhdl_if_t;   
   
   -- VHDL procedures
   procedure get_ci_clk_en                     (enable       : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t);

   procedure retrieve_instruction              (dataa         : out integer;
                                                datab         : out integer;
                                                n             : out integer;
                                                a             : out integer;
                                                b             : out integer;
                                                c             : out integer;
                                                readra        : out integer;
                                                readrb        : out integer;
                                                writerc       : out integer;
                                                idle          : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t);

   procedure insert_result                     (result_value  : in integer;
                                                delay         : in integer;
                                                err_inj       : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t);

   procedure get_instruction_dataa             (dataa         : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t);

   procedure get_instruction_datab             (datab         : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t);

   procedure get_instruction_n                 (n             : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t);

   procedure get_instruction_a                 (a             : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t);

   procedure get_instruction_b                 (b             : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t);

   procedure get_instruction_c                 (c             : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t);

   procedure get_instruction_readra            (readra        : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t);

   procedure get_instruction_readrb            (readrb        : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t);

   procedure get_instruction_writerc           (writerc       : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t);

   procedure get_instruction_idle              (idle          : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t);

   procedure set_result_value                  (result_value  : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t);

   procedure set_result_delay                  (cycles        : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t);

   procedure set_result_err_inject             (err_inj       : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t);

   procedure set_instruction_timeout           (timeout       : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t);

   procedure set_idle_state_output_configuration   (config        : in integer;
                                                    bfm_id        : in integer;
                                                    signal api_if : inout ci_slv_vhdl_if_t);
   
   procedure get_idle_state_output_configuration   (config        : out integer;
                                                    bfm_id        : in integer;
                                                    signal api_if : inout ci_slv_vhdl_if_t);

   procedure set_clock_enable_timeout          (timeout       : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t);
   
   -- VHDL events
   procedure event_known_instruction_received  (bfm_id        : in integer);
   procedure event_unknown_instruction_received(bfm_id        : in integer);
   procedure event_instruction_inconsistent    (bfm_id        : in integer);
   procedure event_result_driven               (bfm_id        : in integer);
   procedure event_result_done                 (bfm_id        : in integer);
   procedure event_instruction_unchanged       (bfm_id        : in integer);

end altera_nios2_custom_instr_slave_bfm_vhdl_pkg;

-- VHDL procedures implementation
package body altera_nios2_custom_instr_slave_bfm_vhdl_pkg is
   
   procedure get_ci_clk_en                     (enable        : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t) is
   begin
      api_if(bfm_id).req(CI_SLV_GET_CI_CLK_EN) <= '1';
      wait until (ack_if(bfm_id).ack(CI_SLV_GET_CI_CLK_EN) = '1');
      api_if(bfm_id).req(CI_SLV_GET_CI_CLK_EN) <= '0';
      wait until (ack_if(bfm_id).ack(CI_SLV_GET_CI_CLK_EN) = '0');
      enable := ack_if(bfm_id).data_out0;
   end get_ci_clk_en;

   procedure retrieve_instruction              (dataa         : out integer;
                                                datab         : out integer;
                                                n             : out integer;
                                                a             : out integer;
                                                b             : out integer;
                                                c             : out integer;
                                                readra        : out integer;
                                                readrb        : out integer;
                                                writerc       : out integer;
                                                idle          : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t) is
   begin
      api_if(bfm_id).req(CI_SLV_RETRIEVE_INSTRUCTION) <= '1';
      wait until (ack_if(bfm_id).ack(CI_SLV_RETRIEVE_INSTRUCTION) = '1');
      api_if(bfm_id).req(CI_SLV_RETRIEVE_INSTRUCTION) <= '0';
      wait until (ack_if(bfm_id).ack(CI_SLV_RETRIEVE_INSTRUCTION) = '0');
      dataa := conv_integer(ack_if(bfm_id).data_out1(319 downto 288));
      datab := conv_integer(ack_if(bfm_id).data_out1(287 downto 256));
      n := conv_integer(ack_if(bfm_id).data_out1(255 downto 224));
      a := conv_integer(ack_if(bfm_id).data_out1(223 downto 192));
      b := conv_integer(ack_if(bfm_id).data_out1(191 downto 160));
      c := conv_integer(ack_if(bfm_id).data_out1(159 downto 128));
      readra := conv_integer(ack_if(bfm_id).data_out1(127 downto 96));
      readrb := conv_integer(ack_if(bfm_id).data_out1(95 downto 64));
      writerc := conv_integer(ack_if(bfm_id).data_out1(63 downto 32));
      idle := conv_integer(ack_if(bfm_id).data_out1(31 downto 0));
   end retrieve_instruction;

   procedure insert_result                     (result_value  : in integer;
                                                delay         : in integer;
                                                err_inj       : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in1(95 downto 0) <= conv_std_logic_vector(result_value,32) & conv_std_logic_vector(delay,32) & conv_std_logic_vector(err_inj,32);
      api_if(bfm_id).req(CI_SLV_INSERT_RESULT) <= '1';
      wait until (ack_if(bfm_id).ack(CI_SLV_INSERT_RESULT) = '1');
      api_if(bfm_id).req(CI_SLV_INSERT_RESULT) <= '0';
      wait until (ack_if(bfm_id).ack(CI_SLV_INSERT_RESULT) = '0');
   end insert_result;

   procedure get_instruction_dataa             (dataa         : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t) is
   begin
      api_if(bfm_id).req(CI_SLV_GET_INSTRUCTION_DATAA) <= '1';
      wait until (ack_if(bfm_id).ack(CI_SLV_GET_INSTRUCTION_DATAA) = '1');
      api_if(bfm_id).req(CI_SLV_GET_INSTRUCTION_DATAA) <= '0';
      wait until (ack_if(bfm_id).ack(CI_SLV_GET_INSTRUCTION_DATAA) = '0');
      dataa := ack_if(bfm_id).data_out0;
   end get_instruction_dataa;

   procedure get_instruction_datab             (datab       : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t) is
   begin
      api_if(bfm_id).req(CI_SLV_GET_INSTRUCTION_DATAB) <= '1';
      wait until (ack_if(bfm_id).ack(CI_SLV_GET_INSTRUCTION_DATAB) = '1');
      api_if(bfm_id).req(CI_SLV_GET_INSTRUCTION_DATAB) <= '0';
      wait until (ack_if(bfm_id).ack(CI_SLV_GET_INSTRUCTION_DATAB) = '0');
      datab := ack_if(bfm_id).data_out0;
   end get_instruction_datab;

   procedure get_instruction_n                 (n             : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t) is
   begin
      api_if(bfm_id).req(CI_SLV_GET_INSTRUCTION_N) <= '1';
      wait until (ack_if(bfm_id).ack(CI_SLV_GET_INSTRUCTION_N) = '1');
      api_if(bfm_id).req(CI_SLV_GET_INSTRUCTION_N) <= '0';
      wait until (ack_if(bfm_id).ack(CI_SLV_GET_INSTRUCTION_N) = '0');
      n := ack_if(bfm_id).data_out0;
   end get_instruction_n;

   procedure get_instruction_a                 (a             : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t) is
   begin
      api_if(bfm_id).req(CI_SLV_GET_INSTRUCTION_A) <= '1';
      wait until (ack_if(bfm_id).ack(CI_SLV_GET_INSTRUCTION_A) = '1');
      api_if(bfm_id).req(CI_SLV_GET_INSTRUCTION_A) <= '0';
      wait until (ack_if(bfm_id).ack(CI_SLV_GET_INSTRUCTION_A) = '0');
      a := ack_if(bfm_id).data_out0;
   end get_instruction_a;

   procedure get_instruction_b                 (b             : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t) is
   begin
      api_if(bfm_id).req(CI_SLV_GET_INSTRUCTION_B) <= '1';
      wait until (ack_if(bfm_id).ack(CI_SLV_GET_INSTRUCTION_B) = '1');
      api_if(bfm_id).req(CI_SLV_GET_INSTRUCTION_B) <= '0';
      wait until (ack_if(bfm_id).ack(CI_SLV_GET_INSTRUCTION_B) = '0');
      b := ack_if(bfm_id).data_out0;
   end get_instruction_b;

   procedure get_instruction_c                 (c             : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t) is
   begin
      api_if(bfm_id).req(CI_SLV_GET_INSTRUCTION_C) <= '1';
      wait until (ack_if(bfm_id).ack(CI_SLV_GET_INSTRUCTION_C) = '1');
      api_if(bfm_id).req(CI_SLV_GET_INSTRUCTION_C) <= '0';
      wait until (ack_if(bfm_id).ack(CI_SLV_GET_INSTRUCTION_C) = '0');
      c := ack_if(bfm_id).data_out0;
   end get_instruction_c;

   procedure get_instruction_readra            (readra        : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t) is
   begin
      api_if(bfm_id).req(CI_SLV_GET_INSTRUCTION_READRA) <= '1';
      wait until (ack_if(bfm_id).ack(CI_SLV_GET_INSTRUCTION_READRA) = '1');
      api_if(bfm_id).req(CI_SLV_GET_INSTRUCTION_READRA) <= '0';
      wait until (ack_if(bfm_id).ack(CI_SLV_GET_INSTRUCTION_READRA) = '0');
      readra := ack_if(bfm_id).data_out0;
   end get_instruction_readra;

   procedure get_instruction_readrb            (readrb       : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t) is
   begin
      api_if(bfm_id).req(CI_SLV_GET_INSTRUCTION_READRB) <= '1';
      wait until (ack_if(bfm_id).ack(CI_SLV_GET_INSTRUCTION_READRB) = '1');
      api_if(bfm_id).req(CI_SLV_GET_INSTRUCTION_READRB) <= '0';
      wait until (ack_if(bfm_id).ack(CI_SLV_GET_INSTRUCTION_READRB) = '0');
      readrb := ack_if(bfm_id).data_out0;
   end get_instruction_readrb;

   procedure get_instruction_writerc           (writerc       : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t) is
   begin
      api_if(bfm_id).req(CI_SLV_GET_INSTRUCTION_WRITERC) <= '1';
      wait until (ack_if(bfm_id).ack(CI_SLV_GET_INSTRUCTION_WRITERC) = '1');
      api_if(bfm_id).req(CI_SLV_GET_INSTRUCTION_WRITERC) <= '0';
      wait until (ack_if(bfm_id).ack(CI_SLV_GET_INSTRUCTION_WRITERC) = '0');
      writerc := ack_if(bfm_id).data_out0;
   end get_instruction_writerc;

   procedure get_instruction_idle              (idle          : out integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t) is
   begin
      api_if(bfm_id).req(CI_SLV_GET_INSTRUCTION_IDLE) <= '1';
      wait until (ack_if(bfm_id).ack(CI_SLV_GET_INSTRUCTION_IDLE) = '1');
      api_if(bfm_id).req(CI_SLV_GET_INSTRUCTION_IDLE) <= '0';
      wait until (ack_if(bfm_id).ack(CI_SLV_GET_INSTRUCTION_IDLE) = '0');
      idle := ack_if(bfm_id).data_out0;
   end get_instruction_idle;

   procedure set_result_value                  (result_value  : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= result_value;
      api_if(bfm_id).req(CI_SLV_SET_RESULT_VALUE) <= '1';
      wait until (ack_if(bfm_id).ack(CI_SLV_SET_RESULT_VALUE) = '1');
      api_if(bfm_id).req(CI_SLV_SET_RESULT_VALUE) <= '0';
      wait until (ack_if(bfm_id).ack(CI_SLV_SET_RESULT_VALUE) = '0');
   end set_result_value;

   procedure set_result_delay                  (cycles        : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= cycles;
      api_if(bfm_id).req(CI_SLV_SET_RESULT_DELAY) <= '1';
      wait until (ack_if(bfm_id).ack(CI_SLV_SET_RESULT_DELAY) = '1');
      api_if(bfm_id).req(CI_SLV_SET_RESULT_DELAY) <= '0';
      wait until (ack_if(bfm_id).ack(CI_SLV_SET_RESULT_DELAY) = '0');
   end set_result_delay;

   procedure set_result_err_inject             (err_inj       : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= err_inj;
      api_if(bfm_id).req(CI_SLV_SET_RESULT_ERR_INJECT) <= '1';
      wait until (ack_if(bfm_id).ack(CI_SLV_SET_RESULT_ERR_INJECT) = '1');
      api_if(bfm_id).req(CI_SLV_SET_RESULT_ERR_INJECT) <= '0';
      wait until (ack_if(bfm_id).ack(CI_SLV_SET_RESULT_ERR_INJECT) = '0');
   end set_result_err_inject;

   procedure set_instruction_timeout           (timeout       : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= timeout;
      api_if(bfm_id).req(CI_SLV_SET_INSTRUCTION_TIMEOUT) <= '1';
      wait until (ack_if(bfm_id).ack(CI_SLV_SET_INSTRUCTION_TIMEOUT) = '1');
      api_if(bfm_id).req(CI_SLV_SET_INSTRUCTION_TIMEOUT) <= '0';
      wait until (ack_if(bfm_id).ack(CI_SLV_SET_INSTRUCTION_TIMEOUT) = '0');
   end set_instruction_timeout;

   
   procedure set_idle_state_output_configuration   (config        : in integer;
                                                    bfm_id        : in integer;
                                                    signal api_if : inout ci_slv_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= config;
      api_if(bfm_id).req(CI_SLV_SET_IDLE_STATE_OUTPUT_CONFIGURATION) <= '1';
      wait until (ack_if(bfm_id).ack(CI_SLV_SET_IDLE_STATE_OUTPUT_CONFIGURATION) = '1');
      api_if(bfm_id).req(CI_SLV_SET_IDLE_STATE_OUTPUT_CONFIGURATION) <= '0';
      wait until (ack_if(bfm_id).ack(CI_SLV_SET_IDLE_STATE_OUTPUT_CONFIGURATION) = '0');
   end set_idle_state_output_configuration;
   
   procedure get_idle_state_output_configuration   (config        : out integer;
                                                    bfm_id        : in integer;
                                                    signal api_if : inout ci_slv_vhdl_if_t) is
   begin
      api_if(bfm_id).req(CI_SLV_GET_IDLE_STATE_OUTPUT_CONFIGURATION) <= '1';
      wait until (ack_if(bfm_id).ack(CI_SLV_GET_IDLE_STATE_OUTPUT_CONFIGURATION) = '1');
      api_if(bfm_id).req(CI_SLV_GET_IDLE_STATE_OUTPUT_CONFIGURATION) <= '0';
      wait until (ack_if(bfm_id).ack(CI_SLV_GET_IDLE_STATE_OUTPUT_CONFIGURATION) = '0');
      config := ack_if(bfm_id).data_out0;
   end get_idle_state_output_configuration;
   
   procedure set_clock_enable_timeout          (timeout       : in integer;
                                                bfm_id        : in integer;
                                                signal api_if : inout ci_slv_vhdl_if_t) is
   begin
      api_if(bfm_id).data_in0 <= timeout;
      api_if(bfm_id).req(CI_SLV_SET_CLOCK_ENABLE_TIMEOUT) <= '1';
      wait until (ack_if(bfm_id).ack(CI_SLV_SET_CLOCK_ENABLE_TIMEOUT) = '1');
      api_if(bfm_id).req(CI_SLV_SET_CLOCK_ENABLE_TIMEOUT) <= '0';
      wait until (ack_if(bfm_id).ack(CI_SLV_SET_CLOCK_ENABLE_TIMEOUT) = '0');
   end set_clock_enable_timeout;

   -- VHDL events implementation
   procedure event_known_instruction_received  (bfm_id        : in integer) is
   begin
      wait until (ack_if(bfm_id).events(CI_SLV_EVENT_KNOWN_INSTRUCTION_RECEIVED) = '1');
   end event_known_instruction_received;

   procedure event_unknown_instruction_received (bfm_id        : in integer) is
   begin
      wait until (ack_if(bfm_id).events(CI_SLV_EVENT_UNKNOWN_INSTRUCTION_RECEIVED) = '1');
   end event_unknown_instruction_received;

   procedure event_instruction_inconsistent    (bfm_id        : in integer) is
   begin
      wait until (ack_if(bfm_id).events(CI_SLV_EVENT_INSTRUCTION_INCONSISTENT) = '1');
   end event_instruction_inconsistent;

   procedure event_result_driven               (bfm_id        : in integer) is
   begin
      wait until (ack_if(bfm_id).events(CI_SLV_EVENT_RESULT_DRIVEN) = '1');
   end event_result_driven;

   procedure event_result_done                 (bfm_id        : in integer) is
   begin
      wait until (ack_if(bfm_id).events(CI_SLV_EVENT_RESULT_DONE) = '1');
   end event_result_done;

   procedure event_instruction_unchanged       (bfm_id        : in integer) is
   begin
      wait until (ack_if(bfm_id).events(CI_SLV_EVENT_INSTRUCTION_UNCHANGED) = '1');
   end event_instruction_unchanged;

end altera_nios2_custom_instr_slave_bfm_vhdl_pkg;
