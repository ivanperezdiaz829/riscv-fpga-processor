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
use work.altera_avalon_mm_master_bfm_vhdl_pkg.all;

entity altera_avalon_mm_master_bfm_vhdl is
   generic (
      AV_ADDRESS_W                  : integer := 32;
      AV_SYMBOL_W                   : integer := 8;
      AV_NUMSYMBOLS                 : integer := 4;
      AV_BURSTCOUNT_W               : integer := 3;
      AV_READRESPONSE_W             : integer := 8;
      AV_WRITERESPONSE_W            : integer := 8;
      USE_READ                      : integer := 1;
      USE_WRITE                     : integer := 1;
      USE_ADDRESS                   : integer := 1;
      USE_BYTE_ENABLE               : integer := 1;
      USE_BURSTCOUNT                : integer := 1;
      USE_READ_DATA                 : integer := 1;
      USE_READ_DATA_VALID           : integer := 1;
      USE_WRITE_DATA                : integer := 1;
      USE_BEGIN_TRANSFER            : integer := 1;
      USE_BEGIN_BURST_TRANSFER      : integer := 1;
      USE_WAIT_REQUEST              : integer := 1;
      USE_ARBITERLOCK               : integer := 0;
      USE_LOCK                      : integer := 0;
      USE_DEBUGACCESS               : integer := 0;
      USE_TRANSACTIONID             : integer := 0;
      USE_WRITERESPONSE             : integer := 0;
      USE_READRESPONSE              : integer := 0;
      USE_CLKEN                     : integer := 0;
      AV_REGISTERINCOMINGSIGNALS    : integer := 0;
      AV_FIX_READ_LATENCY           : integer := 0;
      AV_MAX_PENDING_READS          : integer := 0;
      AV_MAX_PENDING_WRITES         : integer := 0;
      AV_BURST_LINEWRAP             : integer := 0;
      AV_BURST_BNDR_ONLY            : integer := 0;
      AV_CONSTANT_BURST_BEHAVIOR    : integer := 1;
      AV_READ_WAIT_TIME             : integer := 0;
      AV_WRITE_WAIT_TIME            : integer := 0;
      REGISTER_WAITREQUEST          : integer := 0;
      VHDL_ID                       : integer := 0
   );
   port (
      clk                           : in std_logic;
      reset                         : in std_logic;
      avm_clken                     : out std_logic;
      avm_address                   : out std_logic_vector (AV_ADDRESS_W - 1 downto 0);
      avm_waitrequest               : in std_logic;
      avm_burstcount                : out std_logic_vector (AV_BURSTCOUNT_W - 1 downto 0);
      avm_byteenable                : out std_logic_vector (AV_NUMSYMBOLS - 1 downto 0);
      avm_begintransfer             : out std_logic;
      avm_beginbursttransfer        : out std_logic;
      avm_read                      : out std_logic;
      avm_readdatavalid             : in std_logic;
      avm_readdata                  : in std_logic_vector ((AV_SYMBOL_W*AV_NUMSYMBOLS) - 1 downto 0);
      avm_write                     : out std_logic;
      avm_writedata                 : out std_logic_vector ((AV_SYMBOL_W*AV_NUMSYMBOLS) - 1 downto 0);
      avm_transactionid             : out std_logic_vector (7 downto 0);
      avm_readid                    : in std_logic_vector (7 downto 0);
      avm_writeid                   : in std_logic_vector (7 downto 0);
      avm_readresponse              : in std_logic_vector (AV_READRESPONSE_W - 1 downto 0);
      avm_writeresponse             : in std_logic_vector (AV_READRESPONSE_W - 1 downto 0);
      avm_writeresponserequest      : out std_logic;
      avm_writeresponsevalid        : in std_logic;
      avm_arbiterlock               : out std_logic;
      avm_lock                      : out std_logic;
      avm_debugaccess               : out std_logic;
      avm_response                  : in std_logic_vector (1 downto 0)
   );
end altera_avalon_mm_master_bfm_vhdl;

architecture mm_master_bfm_vhdl_a of altera_avalon_mm_master_bfm_vhdl is

   component altera_avalon_mm_master_bfm_vhdl_wrapper
      generic (
         AV_ADDRESS_W                  : integer := 32;
         AV_SYMBOL_W                   : integer := 8;
         AV_NUMSYMBOLS                 : integer := 4;
         AV_BURSTCOUNT_W               : integer := 3;
         USE_READ                      : integer := 1;
         USE_WRITE                     : integer := 1;
         USE_ADDRESS                   : integer := 1;
         USE_BYTE_ENABLE               : integer := 1;
         USE_BURSTCOUNT                : integer := 1;
         USE_READ_DATA                 : integer := 1;
         USE_READ_DATA_VALID           : integer := 1;
         USE_WRITE_DATA                : integer := 1;
         USE_BEGIN_TRANSFER            : integer := 1;
         USE_BEGIN_BURST_TRANSFER      : integer := 1;
         USE_WAIT_REQUEST              : integer := 1;
         USE_ARBITERLOCK               : integer := 0;
         USE_LOCK                      : integer := 0;
         USE_DEBUGACCESS               : integer := 0;
         USE_TRANSACTIONID             : integer := 0;
         USE_WRITERESPONSE             : integer := 0;
         USE_READRESPONSE              : integer := 0;
         USE_CLKEN                     : integer := 0;
         AV_REGISTERINCOMINGSIGNALS    : integer := 0;
         AV_FIX_READ_LATENCY           : integer := 0;
         AV_MAX_PENDING_READS          : integer := 0;
         AV_MAX_PENDING_WRITES         : integer := 0;
         AV_BURST_LINEWRAP             : integer := 0;
         AV_BURST_BNDR_ONLY            : integer := 0;
         AV_CONSTANT_BURST_BEHAVIOR    : integer := 1;
         AV_READ_WAIT_TIME             : integer := 0;
         AV_WRITE_WAIT_TIME            : integer := 0;
         REGISTER_WAITREQUEST          : integer := 0;
         MM_MAX_BIT_W                  : integer := 1024
      );
      port (
         clk                           : in std_logic;
         reset                         : in std_logic;
         avm_clken                     : out std_logic;
         avm_address                   : out std_logic_vector (AV_ADDRESS_W - 1 downto 0);
         avm_waitrequest               : in std_logic;
         avm_burstcount                : out std_logic_vector (AV_BURSTCOUNT_W - 1 downto 0);
         avm_byteenable                : out std_logic_vector (AV_NUMSYMBOLS - 1 downto 0);
         avm_begintransfer             : out std_logic;
         avm_beginbursttransfer        : out std_logic;
         avm_read                      : out std_logic;
         avm_readdatavalid             : in std_logic;
         avm_readdata                  : in std_logic_vector ((AV_SYMBOL_W*AV_NUMSYMBOLS) - 1 downto 0);
         avm_write                     : out std_logic;
         avm_writedata                 : out std_logic_vector ((AV_SYMBOL_W*AV_NUMSYMBOLS) - 1 downto 0);
         avm_transactionid             : out std_logic_vector (7 downto 0);
         avm_readid                    : in std_logic_vector (7 downto 0);
         avm_writeid                   : in std_logic_vector (7 downto 0);
         avm_response                  : in std_logic_vector (1 downto 0);
         avm_writeresponserequest      : out std_logic;
         avm_writeresponsevalid        : in std_logic;
         avm_arbiterlock               : out std_logic;
         avm_lock                      : out std_logic;
         avm_debugaccess               : out std_logic;
         -- VHDL request interface
         req                           : in std_logic_vector (MM_MSTR_INIT downto 0);
         ack                           : out std_logic_vector (MM_MSTR_INIT downto 0);
         data_in0                      : in integer;
         data_in1                      : in integer;
         data_in2                      : in std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
         data_out0                     : out integer;
         data_out1                     : out integer;
         data_out2                     : out std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
         events                        : out std_logic_vector (MM_MSTR_EVENT_MIN_COMMAND_QUEUE_SIZE downto 0)
      );
   end component;
   
   -- VHDL request interface
   signal req        : std_logic_vector (MM_MSTR_INIT downto 0);
   signal ack        : std_logic_vector (MM_MSTR_INIT downto 0);
   signal data_in0   : integer;
   signal data_in1   : integer;
   signal data_in2   : std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
   signal data_out0  : integer;
   signal data_out1  : integer;
   signal data_out2  : std_logic_vector (MM_MAX_BIT_W - 1 downto 0);
   signal events     : std_logic_vector (MM_MSTR_EVENT_MIN_COMMAND_QUEUE_SIZE downto 0);
   
   begin
   
   req                                 <= req_if(VHDL_ID).req;
   data_in0                            <= req_if(VHDL_ID).data_in0;
   data_in1                            <= req_if(VHDL_ID).data_in1;
   data_in2                            <= req_if(VHDL_ID).data_in2;
   ack_if(VHDL_ID).ack                 <= ack;
   ack_if(VHDL_ID).data_out0           <= data_out0;
   ack_if(VHDL_ID).data_out1           <= data_out1;
   ack_if(VHDL_ID).data_out2           <= data_out2;
   ack_if(VHDL_ID).events              <= events;
   
   mm_master_vhdl_wrapper : altera_avalon_mm_master_bfm_vhdl_wrapper
      generic map (
         AV_ADDRESS_W                  => AV_ADDRESS_W,
         AV_SYMBOL_W                   => AV_SYMBOL_W,
         AV_NUMSYMBOLS                 => AV_NUMSYMBOLS,
         AV_BURSTCOUNT_W               => AV_BURSTCOUNT_W,         
         USE_READ                      => USE_READ,
         USE_WRITE                     => USE_WRITE,
         USE_ADDRESS                   => USE_ADDRESS,
         USE_BYTE_ENABLE               => USE_BYTE_ENABLE,
         USE_BURSTCOUNT                => USE_BURSTCOUNT,
         USE_READ_DATA                 => USE_READ_DATA,
         USE_READ_DATA_VALID           => USE_READ_DATA_VALID,
         USE_WRITE_DATA                => USE_WRITE_DATA,
         USE_BEGIN_TRANSFER            => USE_BEGIN_TRANSFER,
         USE_BEGIN_BURST_TRANSFER      => USE_BEGIN_BURST_TRANSFER,
         USE_WAIT_REQUEST              => USE_WAIT_REQUEST,
         USE_ARBITERLOCK               => USE_ARBITERLOCK,
         USE_LOCK                      => USE_LOCK,
         USE_DEBUGACCESS               => USE_DEBUGACCESS,
         USE_TRANSACTIONID             => USE_TRANSACTIONID,
         USE_WRITERESPONSE             => USE_WRITERESPONSE,
         USE_READRESPONSE              => USE_READRESPONSE,
         USE_CLKEN                     => USE_CLKEN,
         AV_REGISTERINCOMINGSIGNALS    => AV_REGISTERINCOMINGSIGNALS,
         AV_FIX_READ_LATENCY           => AV_FIX_READ_LATENCY,
         AV_MAX_PENDING_READS          => AV_MAX_PENDING_READS,
         AV_MAX_PENDING_WRITES         => AV_MAX_PENDING_WRITES,
         AV_BURST_LINEWRAP             => AV_BURST_LINEWRAP,
         AV_BURST_BNDR_ONLY            => AV_BURST_BNDR_ONLY,
         AV_CONSTANT_BURST_BEHAVIOR    => AV_CONSTANT_BURST_BEHAVIOR,
         AV_READ_WAIT_TIME             => AV_READ_WAIT_TIME,
         AV_WRITE_WAIT_TIME            => AV_WRITE_WAIT_TIME,
         REGISTER_WAITREQUEST          => REGISTER_WAITREQUEST,
         MM_MAX_BIT_W                  => MM_MAX_BIT_W
      )
      port map (
         clk                            => clk,
         reset                          => reset,
         avm_clken                      => avm_clken,
         avm_address                    => avm_address,
         avm_waitrequest                => avm_waitrequest,
         avm_burstcount                 => avm_burstcount,
         avm_byteenable                 => avm_byteenable,
         avm_begintransfer              => avm_begintransfer,
         avm_beginbursttransfer         => avm_beginbursttransfer,
         avm_read                       => avm_read,
         avm_readdatavalid              => avm_readdatavalid,
         avm_readdata                   => avm_readdata,
         avm_write                      => avm_write,
         avm_writedata                  => avm_writedata,
         avm_transactionid              => avm_transactionid,
         avm_readid                     => avm_readid,
         avm_writeid                    => avm_writeid,
         avm_response                   => avm_response,
         avm_writeresponserequest       => avm_writeresponserequest,
         avm_writeresponsevalid         => avm_writeresponsevalid,
         avm_arbiterlock                => avm_arbiterlock,
         avm_lock                       => avm_lock,
         avm_debugaccess                => avm_debugaccess,
         req                            => req,
         ack                            => ack,
         data_in0                       => data_in0,
         data_in1                       => data_in1,
         data_in2                       => data_in2,
         data_out0                      => data_out0,
         data_out1                      => data_out1,
         data_out2                      => data_out2,
         events                         => events
      );
   
end mm_master_bfm_vhdl_a;
