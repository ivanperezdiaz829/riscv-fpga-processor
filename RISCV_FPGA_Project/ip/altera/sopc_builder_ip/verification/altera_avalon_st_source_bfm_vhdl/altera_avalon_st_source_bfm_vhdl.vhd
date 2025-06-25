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
use work.altera_avalon_st_source_bfm_vhdl_pkg.all;

entity altera_avalon_st_source_bfm_vhdl is
   generic (
      ST_SYMBOL_W          : integer := 8;
      ST_NUMSYMBOLS        : integer := 4;
      ST_CHANNEL_W         : integer := 1;
      ST_ERROR_W           : integer := 1;
      ST_EMPTY_W           : integer := 1;
      ST_READY_LATENCY     : integer := 0;
      ST_MAX_CHANNELS      : integer := 1;
      USE_PACKET           : integer := 0;
      USE_CHANNEL          : integer := 0;
      USE_ERROR            : integer := 0;
      USE_READY            : integer := 1;
      USE_VALID            : integer := 1;
      USE_EMPTY            : integer := 0;
      ST_BEATSPERCYCLE     : integer := 1;
      VHDL_ID              : integer := 0
   );
   port (
      clk                  : in std_logic;
      reset                : in std_logic;
      src_data             : out std_logic_vector ((ST_SYMBOL_W*ST_NUMSYMBOLS*ST_BEATSPERCYCLE) - 1 downto 0);
      src_channel          : out std_logic_vector ((ST_CHANNEL_W*ST_BEATSPERCYCLE) - 1 downto 0);
      src_valid            : out std_logic_vector (ST_BEATSPERCYCLE - 1 downto 0);
      src_startofpacket    : out std_logic_vector (ST_BEATSPERCYCLE - 1 downto 0);
      src_endofpacket      : out std_logic_vector (ST_BEATSPERCYCLE - 1 downto 0);
      src_error            : out std_logic_vector ((ST_ERROR_W*ST_BEATSPERCYCLE) - 1 downto 0);
      src_empty            : out std_logic_vector ((ST_EMPTY_W*ST_BEATSPERCYCLE) - 1 downto 0);
      src_ready            : in std_logic
   );
end altera_avalon_st_source_bfm_vhdl;

architecture st_source_bfm_vhdl_a of altera_avalon_st_source_bfm_vhdl is
   
   component altera_avalon_st_source_bfm_vhdl_wrapper
      generic (
         ST_SYMBOL_W          : integer := 8;
         ST_NUMSYMBOLS        : integer := 4;
         ST_CHANNEL_W         : integer := 1;
         ST_ERROR_W           : integer := 1;
         ST_EMPTY_W           : integer := 1;
         ST_READY_LATENCY     : integer := 0;
         ST_MAX_CHANNELS      : integer := 1;
         USE_PACKET           : integer := 0;
         USE_CHANNEL          : integer := 0;
         USE_ERROR            : integer := 0;
         USE_READY            : integer := 1;
         USE_VALID            : integer := 1;
         USE_EMPTY            : integer := 0;
         ST_BEATSPERCYCLE     : integer := 1;
         ST_MAX_BIT_W         : integer := 4096
      );
      port (
         clk                  : in std_logic;
         reset                : in std_logic;
         src_data             : out std_logic_vector ((ST_SYMBOL_W*ST_NUMSYMBOLS*ST_BEATSPERCYCLE) - 1 downto 0);
         src_channel          : out std_logic_vector ((ST_CHANNEL_W*ST_BEATSPERCYCLE) - 1 downto 0);
         src_valid            : out std_logic_vector (ST_BEATSPERCYCLE - 1 downto 0);
         src_startofpacket    : out std_logic_vector (ST_BEATSPERCYCLE - 1 downto 0);
         src_endofpacket      : out std_logic_vector (ST_BEATSPERCYCLE - 1 downto 0);
         src_error            : out std_logic_vector ((ST_ERROR_W*ST_BEATSPERCYCLE) - 1 downto 0);
         src_empty            : out std_logic_vector ((ST_EMPTY_W*ST_BEATSPERCYCLE) - 1 downto 0);
         src_ready            : in std_logic;
         -- VHDL request interface
         req                  : in std_logic_vector (ST_SRC_INIT downto 0);
         ack                  : out std_logic_vector (ST_SRC_INIT downto 0);
         data_in0             : in integer;
         data_in1             : in std_logic_vector (ST_MAX_BIT_W - 1 downto 0);
         data_out0            : out integer;
         data_out1            : out std_logic_vector (ST_MAX_BIT_W - 1 downto 0);
         events               : out std_logic_vector (ST_SRC_EVENT_SRC_NOT_READY downto 0)
      );
   end component;
   
   -- VHDL request interface
   signal req        : std_logic_vector (ST_SRC_INIT downto 0);
   signal ack        : std_logic_vector (ST_SRC_INIT downto 0);
   signal data_in0   : integer;
   signal data_in1   : std_logic_vector (ST_MAX_BIT_W - 1 downto 0);
   signal data_out0  : integer;
   signal data_out1  : std_logic_vector (ST_MAX_BIT_W - 1 downto 0);
   signal events     : std_logic_vector (ST_SRC_EVENT_SRC_NOT_READY downto 0);
   
   begin
   
   req                        <= req_if(VHDL_ID).req;
   data_in0                   <= req_if(VHDL_ID).data_in0;
   data_in1                   <= req_if(VHDL_ID).data_in1;
   ack_if(VHDL_ID).ack        <= ack;
   ack_if(VHDL_ID).data_out0  <= data_out0;
   ack_if(VHDL_ID).data_out1  <= data_out1;
   ack_if(VHDL_ID).events     <= events;
   
   st_source_vhdl_wrapper : altera_avalon_st_source_bfm_vhdl_wrapper
      generic map (
         ST_SYMBOL_W          => ST_SYMBOL_W,
         ST_NUMSYMBOLS        => ST_NUMSYMBOLS,
         ST_CHANNEL_W         => ST_CHANNEL_W,
         ST_ERROR_W           => ST_ERROR_W,
         ST_EMPTY_W           => ST_EMPTY_W,
         ST_READY_LATENCY     => ST_READY_LATENCY,
         ST_MAX_CHANNELS      => ST_MAX_CHANNELS,
         USE_PACKET           => USE_PACKET,
         USE_CHANNEL          => USE_CHANNEL,
         USE_ERROR            => USE_ERROR,
         USE_READY            => USE_READY,
         USE_VALID            => USE_VALID,
         USE_EMPTY            => USE_EMPTY,
         ST_BEATSPERCYCLE     => ST_BEATSPERCYCLE,
         ST_MAX_BIT_W         => ST_MAX_BIT_W
      )
      port map (
         clk               => clk,
         reset             => reset,
         src_data          => src_data,
         src_channel       => src_channel,
         src_valid         => src_valid,
         src_startofpacket => src_startofpacket,
         src_endofpacket   => src_endofpacket,
         src_error         => src_error,
         src_empty         => src_empty,
         src_ready         => src_ready,
         req               => req,
         ack               => ack,
         data_in0          => data_in0,
         data_in1          => data_in1,
         data_out0         => data_out0,
         data_out1         => data_out1,
         events            => events
      );
end st_source_bfm_vhdl_a;
