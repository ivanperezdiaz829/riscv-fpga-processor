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
use work.altera_nios2_custom_instr_master_bfm_vhdl_pkg.all;

entity altera_nios2_custom_instr_master_bfm_vhdl is
   generic (
      NUM_OPERANDS      : integer := 2;
      USE_RESULT        : integer := 1;
      USE_MULTI_CYCLE   : integer := 0;
      FIXED_LENGTH      : integer := 2;
      USE_START         : integer := 1;
      USE_DONE          : integer := 0;
      USE_EXTENSION     : integer := 0;
      EXT_WIDTH         : integer := 8;
      USE_READRA        : integer := 0;
      USE_READRB        : integer := 0;
      USE_WRITERC       : integer := 0;
      VHDL_ID           : integer := 0
   );
   port (
      clk               : in std_logic;
      reset             : in std_logic;
      ci_clk            : out std_logic;
      ci_reset          : out std_logic;
      ci_clk_en         : out std_logic;
      ci_dataa          : out std_logic_vector (31 downto 0);
      ci_datab          : out std_logic_vector (31 downto 0);
      ci_result         : in std_logic_vector (31 downto 0);
      ci_start          : out std_logic;
      ci_done           : in std_logic;
      ci_n              : out std_logic_vector (EXT_WIDTH - 1 downto 0);
      ci_a              : out std_logic_vector (4 downto 0);                    
      ci_b              : out std_logic_vector (4 downto 0);                    
      ci_c              : out std_logic_vector (4 downto 0);                    
      ci_readra         : out std_logic;
      ci_readrb         : out std_logic;
      ci_writerc        : out std_logic
   );
end altera_nios2_custom_instr_master_bfm_vhdl;

architecture ci_master_bfm_vhdl_a of altera_nios2_custom_instr_master_bfm_vhdl is

   component altera_nios2_custom_instr_master_bfm_vhdl_wrapper
      generic (
         NUM_OPERANDS      : integer := 2;
         USE_RESULT        : integer := 1;
         USE_MULTI_CYCLE   : integer := 0;
         FIXED_LENGTH      : integer := 2;
         USE_START         : integer := 1;
         USE_DONE          : integer := 0;
         USE_EXTENSION     : integer := 0;
         EXT_WIDTH         : integer := 8;
         USE_READRA        : integer := 0;
         USE_READRB        : integer := 0;
         USE_WRITERC       : integer := 0;
         CI_MAX_BIT_W      : integer := 352
      );
      port (
         clk               : in std_logic;
         reset             : in std_logic;
         ci_clk            : out std_logic;
         ci_reset          : out std_logic;
         ci_clk_en         : out std_logic;
         ci_dataa          : out std_logic_vector (31 downto 0);
         ci_datab          : out std_logic_vector (31 downto 0);
         ci_result         : in std_logic_vector (31 downto 0);
         ci_start          : out std_logic;
         ci_done           : in std_logic;
         ci_n              : out std_logic_vector (EXT_WIDTH - 1 downto 0);
         ci_a              : out std_logic_vector (4 downto 0);                    
         ci_b              : out std_logic_vector (4 downto 0);                    
         ci_c              : out std_logic_vector (4 downto 0);                    
         ci_readra         : out std_logic;
         ci_readrb         : out std_logic;
         ci_writerc        : out std_logic;
         
         -- VHDL request interface
         req               : in std_logic_vector (CI_MSTR_SET_CLOCK_ENABLE_TIMEOUT downto 0);
         ack               : out std_logic_vector (CI_MSTR_SET_CLOCK_ENABLE_TIMEOUT downto 0);
         data_in0          : in integer;
         data_in1          : in std_logic_vector (CI_MAX_BIT_W - 1 downto 0);
         data_out0         : out integer;
         data_out1         : out std_logic_vector (CI_MAX_BIT_W - 1 downto 0);
         events            : out std_logic_vector (CI_MSTR_EVENT_MIN_RESULT_QUEUE_SIZE downto 0)
      );
   end component;
      
   -- VHDL request interface
   signal req              : std_logic_vector (CI_MSTR_SET_CLOCK_ENABLE_TIMEOUT downto 0);
   signal ack              : std_logic_vector (CI_MSTR_SET_CLOCK_ENABLE_TIMEOUT downto 0);
   signal data_in0         : integer;
   signal data_in1         : std_logic_vector (CI_MAX_BIT_W - 1 downto 0);
   signal data_out0        : integer;
   signal data_out1        : std_logic_vector (CI_MAX_BIT_W - 1 downto 0);
   signal events           : std_logic_vector (CI_MSTR_EVENT_MIN_RESULT_QUEUE_SIZE downto 0);
      
   begin
   
   req                                 <= req_if(VHDL_ID).req;
   data_in0                            <= req_if(VHDL_ID).data_in0;
   data_in1                            <= req_if(VHDL_ID).data_in1;
   ack_if(VHDL_ID).ack                 <= ack;
   ack_if(VHDL_ID).data_out0           <= data_out0;
   ack_if(VHDL_ID).data_out1           <= data_out1;
   ack_if(VHDL_ID).events              <= events;

   ci_master_vhdl_wrapper : altera_nios2_custom_instr_master_bfm_vhdl_wrapper
      generic map (
         NUM_OPERANDS       => NUM_OPERANDS,
         USE_RESULT         => USE_RESULT,
         USE_MULTI_CYCLE    => USE_MULTI_CYCLE,
         FIXED_LENGTH       => FIXED_LENGTH,
         USE_START          => USE_START,
         USE_DONE           => USE_DONE,
         USE_EXTENSION      => USE_EXTENSION,
         EXT_WIDTH          => EXT_WIDTH,
         USE_READRA         => USE_READRA,
         USE_READRB         => USE_READRB,
         USE_WRITERC        => USE_WRITERC,
         CI_MAX_BIT_W       => CI_MAX_BIT_W
      )
      port map (
         clk               => clk,
         reset             => reset,
         ci_clk            => ci_clk,
         ci_reset          => ci_reset,
         ci_clk_en         => ci_clk_en,
         ci_dataa          => ci_dataa,
         ci_datab          => ci_datab,
         ci_result         => ci_result,
         ci_start          => ci_start,
         ci_done           => ci_done,
         ci_n              => ci_n,
         ci_a              => ci_a,
         ci_b              => ci_b,
         ci_c              => ci_c,
         ci_readra         => ci_readra,
         ci_readrb         => ci_readrb,
         ci_writerc        => ci_writerc,
         req               => req,
         ack               => ack,
         data_in0          => data_in0,
         data_in1          => data_in1,
         data_out0         => data_out0,
         data_out1         => data_out1,
         events            => events
      );

end ci_master_bfm_vhdl_a;