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


-- $File: //acds/rel/13.1/ip/sopc/components/verification/lib/altera_avalon_components_pkg.vhd $
-- $Revision: #1 $
-- $Date: 2013/08/11 $
-- $Author: swbranch $
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.all;

package altera_avalon_components_pkg is

  -----------------------------------------------------------------------------
  -- Avalon Interrupt Source 
  -----------------------------------------------------------------------------
  type irq_source_method_id is (IRQ_SRC_SET_IRQ,
                                IRQ_SRC_CLEAR_IRQ);

  function conv_std_logic (
      method : irq_source_method_id
  ) return std_logic;
  
  component altera_avalon_interrupt_source_api_wrapper
    generic (AV_DATA_W : integer := 32;
             AV_ADDR_W : integer := 8
            ); 
    port (
          api_clk           : in  std_logic;
    	  api_reset         : in  std_logic;      
  
    	  api_call_method   : in  std_logic;      
          api_call_data     : in  std_logic;      
          api_call_valid    : in  std_logic;      

          api_return_method : out std_logic;      
          api_return_data   : out std_logic; 
          api_return_valid  : out std_logic;      

          av_clk            : in  std_logic;
    	  av_reset          : in  std_logic;
          
          avs_waitrequest   : out std_logic;  
          avs_readdatavalid : out std_logic;      
          avs_readdata      : out std_logic_vector(AV_DATA_W-1 downto 0);
          avs_write         : in  std_logic;  
          avs_read          : in  std_logic;  
          avs_address       : in  std_logic_vector(AV_ADDR_W-1 downto 0);
          avs_writedata     : in  std_logic_vector(AV_DATA_W-1 downto 0);

          irq               : out std_logic
         );
  end component;

  -----------------------------------------------------------------------------
  -- Avalon Interrupt Sink 
  -----------------------------------------------------------------------------
  type irq_sink_method_id is (IRQ_SINK_GET_IRQ, 
                              IRQ_SINK_CLEAR_IRQ); 

  function conv_std_logic (
      method : irq_sink_method_id
  ) return std_logic;
  
  component altera_avalon_interrupt_sink_api_wrapper
    generic (AV_DATA_W : integer := 32;
             AV_ADDR_W : integer := 8;
             AV_IRQ_W  : integer := 1             
             ); 
    port (
          api_clk           : in  std_logic;
    	  api_reset         : in  std_logic;      
   
    	  api_call_method   : in  std_logic;      
	  api_call_data     : in  std_logic;      
	  api_call_valid    : in  std_logic;      

          api_return_method : out std_logic;      
          api_return_data   : out std_logic_vector(AV_IRQ_W-1 downto 0); 
          api_return_valid  : out std_logic;      

          av_clk            : in  std_logic;
    	  av_reset          : in  std_logic;
          
          avm_waitrequest   : in  std_logic;  
          avm_readdatavalid : in  std_logic;      
          avm_readdata      : in  std_logic_vector(AV_DATA_W-1 downto 0);
 	  avm_write         : out std_logic;  
	  avm_read          : out std_logic;  
          avm_address       : out std_logic_vector(AV_ADDR_W-1 downto 0);
          avm_writedata     : out std_logic_vector(AV_DATA_W-1 downto 0);

          irq               : in  std_logic_vector(AV_IRQ_W-1 downto 0)
          );
  end component;

  -----------------------------------------------------------------------------
  -- Avalon Streaming Source API Wrapper  
  -----------------------------------------------------------------------------
  type st_source_signal_index is (  
                    ST_SRC_SIGNAL_READY,
       	            ST_SRC_SIGNAL_NOT_READY,
       	            ST_SRC_SIGNAL_TRANS_COMPLETE,
       	            ST_SRC_SIGNAL_DRIVING_TRANS,
       	            ST_SRC_SIGNAL_RESERVED_4,
       	            ST_SRC_SIGNAL_RESERVED_5,
       	            ST_SRC_SIGNAL_RESERVED_6,
       	            ST_SRC_SIGNAL_RESERVED_7);

  type st_source_method_id is (
                    ST_SRC_INIT,
       	            ST_SRC_SET_RESP_TIMEOUT,
       	            ST_SRC_PUSH_TRANS,
       	            ST_SRC_GET_TRANS_QUEUE_SIZE,
       	            ST_SRC_GET_RESP_QUEUE_SIZE,
       	            ST_SRC_SET_TRANS_DATA,
       	            ST_SRC_SET_TRANS_CHANNEL,
       	            ST_SRC_SET_TRANS_IDLES,
       	            ST_SRC_SET_TRANS_SOP,
       	            ST_SRC_SET_TRANS_EOP,
       	            ST_SRC_SET_TRANS_ERROR,
       	            ST_SRC_SET_TRANS_EMPTY,
       	            ST_SRC_POP_RESP,
       	            ST_SRC_GET_RESP_LATENCY,
       	            ST_SRC_GET_SRC_READY,
       	            ST_SRC_GET_SRC_TRANS_COMPLETE);

  function conv_integer (
    sig : st_source_signal_index
  ) return integer;
  
  function conv_std_logic (
    method : st_source_method_id
  ) return std_logic_vector;
  
  component altera_avalon_st_source_api_wrapper
     generic (
              ST_SYMBOL_W     : integer := 8; 
              ST_NUMSYMBOLS   : integer := 4; 
              ST_CHANNEL_W    : integer := 0; 
              ST_ERROR_W      : integer := 0; 
              ST_EMPTY_W      : integer := 0;

              ST_READY_LATENCY: integer := 0;   
              ST_MAX_CHANNELS : integer := 1;
      
              USE_PACKET      : integer := 1;   
              USE_CHANNEL     : integer := 1;   
              USE_ERROR       : integer := 1;   
              USE_READY       : integer := 1;   
              USE_VALID       : integer := 1;       
              USE_EMPTY       : integer := 1;

              API_CALL_DATA_W : integer := 32;
              API_RETURN_DATA_W : integer := 32              
     );
     port (
           api_clk            : in  std_logic;             
           api_reset          : in  std_logic;             
                                                                           
           api_call_method    : in std_logic_vector(7 downto 0);   
           api_call_data      : in std_logic_vector(API_CALL_DATA_W-1 downto 0);  
           api_call_valid     : in std_logic;              
                                                                             
           api_return_method  : out std_logic_vector(7 downto 0); 
           api_return_data    : out std_logic_vector(31 downto 0); 
           api_return_valid   : out std_logic;  
                                                                             
           api_event_data     : out std_logic_vector(7 downto 0); 
           api_event_valid    : out std_logic;               
                                                                          
           av_clk             : in  std_logic;             
           av_reset           : in  std_logic;             
                                                                             
           src_data           : out std_logic_vector(
                                        ST_SYMBOL_W*ST_NUMSYMBOLS-1 downto 0); 
           src_channel        : out std_logic_vector(ST_CHANNEL_W-1 downto 0); 
           src_valid          : out std_logic;       
           src_startofpacket  : out std_logic;        
           src_endofpacket    : out std_logic;        
           src_error          : out std_logic_vector(ST_ERROR_W-1 downto 0); 
           src_empty          : out std_logic_vector(ST_EMPTY_W-1 downto 0); 
           src_ready          : in  std_logic              
          );
  end component;
  
  -----------------------------------------------------------------------------
  -- Avalon Streaming Sink 
  -----------------------------------------------------------------------------

  type st_sink_signal_index is (    
                      ST_SINK_SIGNAL_TRANS_RECEIVED,
		      ST_SINK_SIGNAL_READY_ASSERT,
		      ST_SINK_SIGNAL_READY_DEASSERT,
		      ST_SINK_SIGNAL_RESERVED_3,
		      ST_SINK_SIGNAL_RESERVED_4,
		      ST_SINK_SIGNAL_RESERVED_5,
		      ST_SINK_SIGNAL_RESERVED_6,
		      ST_SINK_SIGNAL_RESERVED_7 
		      );


  type st_sink_method_id is (   
                      ST_SINK_INIT,
		      ST_SINK_SET_READY,
		      ST_SINK_POP_TRANS,
		      ST_SINK_GET_TRANS_IDLES,
		      ST_SINK_GET_TRANS_DATA,
		      ST_SINK_GET_TRANS_CHANNEL,
		      ST_SINK_GET_TRANS_SOP,
		      ST_SINK_GET_TRANS_EOP,
		      ST_SINK_GET_TRANS_ERROR,
		      ST_SINK_GET_TRANS_EMPTY,
		      ST_SINK_GET_TRANS_QUEUE_SIZE
		     );

  function conv_integer (
    sig : st_sink_signal_index
  ) return integer;
  
  function conv_std_logic (
    method : st_sink_method_id
  ) return std_logic_vector;
  
  component altera_avalon_st_sink_api_wrapper
     generic (
              ST_SYMBOL_W     : integer := 8; 
              ST_NUMSYMBOLS   : integer := 4; 
              ST_CHANNEL_W    : integer := 0; 
              ST_ERROR_W      : integer := 0; 
              ST_EMPTY_W      : integer := 0;

              ST_READY_LATENCY: integer := 0;   
              ST_MAX_CHANNELS : integer := 1;
      
              USE_PACKET      : integer := 1;   
              USE_CHANNEL     : integer := 1;   
              USE_ERROR       : integer := 1;   
              USE_READY       : integer := 1;   
              USE_VALID       : integer := 1;       
              USE_EMPTY       : integer := 1;

              API_CALL_DATA_W : integer := 32;
              API_RETURN_DATA_W : integer := 32
     );
     port (
           api_clk            : in  std_logic;             
           api_reset          : in  std_logic;             
                                                                           
           api_call_method    : in std_logic_vector(7 downto 0);   
           api_call_data      : in std_logic_vector(31 downto 0);  
           api_call_valid     : in std_logic;              
                                                                             
           api_return_method  : out std_logic_vector(7 downto 0); 
           api_return_data    : out std_logic_vector(API_RETURN_DATA_W downto 0); 
           api_return_valid   : out std_logic;  
                                                                             
           api_event_data     : out std_logic_vector(7 downto 0); 
           api_event_valid    : out std_logic;               
                                                                          
           av_clk             : in  std_logic;             
           av_reset           : in  std_logic;             
                                                                             
           sink_data          : in std_logic_vector(
                                        ST_SYMBOL_W*ST_NUMSYMBOLS-1 downto 0); 
           sink_channel       : in std_logic_vector(ST_CHANNEL_W-1 downto 0); 
           sink_valid         : in std_logic;       
           sink_startofpacket : in std_logic;        
           sink_endofpacket   : in std_logic;        
           sink_error         : in std_logic_vector(ST_ERROR_W-1 downto 0); 
           sink_empty         : in std_logic_vector(ST_EMPTY_W-1 downto 0); 
           sink_ready         : out  std_logic              
          );
  end component;
  

  -----------------------------------------------------------------------------
  -- Avalon MM Master
  -----------------------------------------------------------------------------

  type mm_mstr_signal_index is (
                      MM_MSTR_SIGNAL_FATAL_ERROR       ,
		      MM_MSTR_SIGNAL_RESPONSE_COMPLETE , 
		      MM_MSTR_SIGNAL_COMMAND_ISSUED    ,
		      MM_MSTR_SIGNAL_ALL_TRANS_COMPLETE ,
		      MM_MSTR_SIGNAL_RESERVED_4        ,
		      MM_MSTR_SIGNAL_RESERVED_5        ,
		      MM_MSTR_SIGNAL_RESERVED_6        ,
		      MM_MSTR_SIGNAL_RESERVED_7
		      );                      


  type mm_mstr_method_id is (
                      MM_MSTR_INIT                     ,
		      MM_MSTR_SET_RESP_TIMEOUT         ,
		      MM_MSTR_SET_CMD_TIMEOUT          ,

		      MM_MSTR_ALL_TRANS_COMPLETE       ,
		      MM_MSTR_GET_CMD_ISSUE_QUEUE_SIZE ,
		      MM_MSTR_GET_CMD_PEND_QUEUE_SIZE  ,	   
		      MM_MSTR_GET_RESP_QUEUE_SIZE      ,  
		      MM_MSTR_PUSH_CMD                 ,
		      MM_MSTR_POP_RESP                 ,
		      
		      MM_MSTR_SET_CMD_DATA    	       ,
		      MM_MSTR_SET_CMD_ADDRESS 	       ,		      
		      MM_MSTR_SET_CMD_BYTE_ENABLE      ,
		      MM_MSTR_SET_CMD_BURST_COUNT      ,
		      MM_MSTR_SET_CMD_IDLE   	       ,
		      MM_MSTR_SET_CMD_REQUEST  	       ,
		      MM_MSTR_SET_CMD_RESERVED_1       ,

		      MM_MSTR_GET_RESP_REQUEST 	       ,		      
		      MM_MSTR_GET_RESP_DATA    	       ,
		      MM_MSTR_GET_RESP_ADDRESS	       , 
		      MM_MSTR_GET_RESP_BYTE_ENABLE     ,
		      MM_MSTR_GET_RESP_BURST_SIZE      ,  		      
		      MM_MSTR_GET_RESP_LATENCY         ,
		      MM_MSTR_GET_RESP_WAIT_TIME       ,

                      MM_MSTR_SET_CMD_INIT_LATENCY     ,
		      MM_MSTR_SET_CMD_BURST_SIZE
		     );

  function conv_integer (
    sig : mm_mstr_signal_index
  ) return integer;
  
  function conv_std_logic (
    method : mm_mstr_method_id
  ) return std_logic_vector;
  
  component altera_avalon_mm_master_bfm_api_wrapper
     generic (
              AV_ADDRESS_W              : integer := 32;
              AV_SYMBOL_W               : integer := 8; 
              AV_NUMSYMBOLS             : integer := 4; 
              AV_BURSTCOUNT_W           : integer := 3; 

              USE_READ                  : integer := 1; 
              USE_WRITE                 : integer := 1; 
              USE_ADDRESS               : integer := 1; 
              USE_BYTE_ENABLE           : integer := 1; 
              USE_BURSTCOUNT            : integer := 1; 
              USE_READ_DATA             : integer := 1; 
              USE_READ_DATA_VALID       : integer := 1; 
              USE_WRITE_DATA            : integer := 1; 
              USE_BEGIN_TRANSFER        : integer := 1; 
              USE_BEGIN_BURST_TRANSFER  : integer := 1; 
              USE_WAIT_REQUEST          : integer := 1; 

              AV_FIX_READ_LATENCY       : integer := 0; 
              AV_MAX_PENDING_READS      : integer := 1;

              AV_BURST_LINEWRAP         : integer := 0;  
              AV_BURST_BNDR_ONLY        : integer := 0;

              API_CALL_DATA_W           : integer := 64;
              API_RETURN_DATA_W         : integer := 64
     );
     port (
   api_clk                : in  std_logic;
   api_reset              : in  std_logic;
   

   api_call_method        : in  std_logic_vector(7 downto 0); 
   api_call_data          : in  std_logic_vector(API_CALL_DATA_W-1 downto 0); 
   api_call_valid         : in  std_logic;  

   api_return_method      : out std_logic_vector(7 downto 0);
   api_return_data        : out std_logic_vector(API_RETURN_DATA_W-1 downto 0);
   api_return_valid       : out std_logic;   

   api_event_data         : out std_logic_vector(7 downto 0);
   api_event_valid        : out std_logic;   

   avm_clk                : in  std_logic;  
   avm_reset              : in  std_logic;   

   avm_waitrequest        : in  std_logic;  
   avm_readdatavalid      : in  std_logic;  
   avm_readdata           : in  std_logic_vector((AV_SYMBOL_W*AV_NUMSYMBOLS)-1 downto 0); 
   avm_write              : out std_logic;    
   avm_read               : out std_logic;             
   avm_address            : out std_logic_vector(AV_ADDRESS_W-1 downto 0);
   avm_byteenable         : out std_logic_vector(AV_NUMSYMBOLS-1 downto 0); 
   avm_burstcount         : out std_logic_vector(AV_BURSTCOUNT_W-1 downto 0);
   avm_beginbursttransfer : out std_logic;   
   avm_begintransfer      : out std_logic;   
   avm_writedata          : out std_logic_vector((AV_SYMBOL_W*AV_NUMSYMBOLS)-1 downto 0)
          );
  end component;

  -----------------------------------------------------------------------------
  -- Avalon MM Slave 
  -----------------------------------------------------------------------------
  
  type mm_slv_signal_index is (
                      MM_SLV_SIGNAL_FATAL_ERROR                   ,
		      MM_SLV_SIGNAL_ERROR_EXCEED_MAX_PENDING_READS,
		      MM_SLV_SIGNAL_COMMAND_RECEIVED              ,
		      MM_SLV_SIGNAL_RESP_ISSUED                   ,
		      MM_SLV_SIGNAL_RESERVED_4                    ,          
		      MM_SLV_SIGNAL_RESERVED_5                    ,
		      MM_SLV_SIGNAL_RESERVED_6                    ,
		      MM_SLV_SIGNAL_RESERVED_7
		      );                      

  type mm_slv_method_id is (  
                      MM_SLV_INIT                 ,
		      MM_SLV_SET_RESP_TIMEOUT     ,

		      MM_SLV_GET_CMD_QUEUE_SIZE   ,
		      MM_SLV_GET_RESP_QUEUE_SIZE  ,  
		      MM_SLV_PUSH_RESP            ,
		      MM_SLV_POP_CMD              ,
		      
		      MM_SLV_SET_RESP_DATA    	  ,
		      MM_SLV_SET_RESP_BURST_SIZE  ,
		      MM_SLV_SET_RESP_LATENCY     ,

		      MM_SLV_SET_INTERFACE_WAIT_TIME    ,
		      
		      MM_SLV_GET_CMD_REQUEST 	  ,		      
		      MM_SLV_GET_CMD_DATA    	  ,
		      MM_SLV_GET_CMD_ADDRESS      , 
		      MM_SLV_GET_CMD_BYTE_ENABLE  ,
		      MM_SLV_GET_CMD_BURST_COUNT  ,
		      MM_SLV_GET_CMD_BURST_CYCLE
		     );                      


  function conv_integer (
    sig : mm_slv_signal_index
  ) return integer;
  
  function conv_std_logic (
    method : mm_slv_method_id
  ) return std_logic_vector;


  component altera_avalon_mm_slave_bfm_api_wrapper
     generic (
              AV_ADDRESS_W              : integer := 32;
              AV_SYMBOL_W               : integer := 8; 
              AV_NUMSYMBOLS             : integer := 4; 
              AV_BURSTCOUNT_W           : integer := 3; 

              USE_READ                  : integer := 1; 
              USE_WRITE                 : integer := 1; 
              USE_ADDRESS               : integer := 1; 
              USE_BYTE_ENABLE           : integer := 1; 
              USE_BURSTCOUNT            : integer := 1; 
              USE_READ_DATA             : integer := 1; 
              USE_READ_DATA_VALID       : integer := 1; 
              USE_WRITE_DATA            : integer := 1; 
              USE_BEGIN_TRANSFER        : integer := 1; 
              USE_BEGIN_BURST_TRANSFER  : integer := 1; 
              USE_WAIT_REQUEST          : integer := 1; 

              AV_FIX_READ_LATENCY       : integer := 0; 
              AV_MAX_PENDING_READS      : integer := 1;

              AV_BURST_LINEWRAP         : integer := 0;  
              AV_BURST_BNDR_ONLY        : integer := 0;

              AV_READ_WAIT_TIME         : integer := 0;
              AV_WRITE_WAIT_TIME        : integer := 0;
              
              API_CALL_DATA_W           : integer := 64;
              API_RETURN_DATA_W         : integer := 64
     );
     port (
   api_clk                : in  std_logic;
   api_reset              : in  std_logic;
   

   api_call_method        : in  std_logic_vector(7 downto 0); 
   api_call_data          : in  std_logic_vector(API_CALL_DATA_W-1 downto 0); 
   api_call_valid         : in  std_logic;  

   api_return_method      : out std_logic_vector(7 downto 0);
   api_return_data        : out std_logic_vector(API_RETURN_DATA_W-1 downto 0);
   api_return_valid       : out std_logic;   

   api_event_data         : out std_logic_vector(7 downto 0);
   api_event_valid        : out std_logic;   

   avs_clk                : in  std_logic;  
   avs_reset              : in  std_logic;   

   avs_waitrequest        : out std_logic;  
   avs_readdatavalid      : out std_logic;  
   avs_readdata           : out std_logic_vector((AV_SYMBOL_W*AV_NUMSYMBOLS)-1 downto 0); 
   avs_write              : in  std_logic;    
   avs_read               : in  std_logic;             
   avs_address            : in  std_logic_vector(AV_ADDRESS_W-1 downto 0);
   avs_byteenable         : in  std_logic_vector(AV_NUMSYMBOLS-1 downto 0); 
   avs_burstcount         : in  std_logic_vector(AV_BURSTCOUNT_W-1 downto 0);
   avs_beginbursttransfer : in  std_logic;   
   avs_begintransfer      : in  std_logic;   
   avs_writedata          : in  std_logic_vector((AV_SYMBOL_W*AV_NUMSYMBOLS)-1 downto 0)
          );
  end component;

end altera_avalon_components_pkg;


package body altera_avalon_components_pkg is

  -----------------------------------------------------------------------------
  -- Avalon Interrupt Source 
  -----------------------------------------------------------------------------

  function conv_std_logic (
      method : irq_source_method_id
  ) return std_logic is
  begin
    case method is
      when IRQ_SRC_SET_IRQ    => return '0';
      when IRQ_SRC_CLEAR_IRQ  => return '1';
      when others             => return 'X';
    end case;
  end function conv_std_logic;

  -----------------------------------------------------------------------------
  -- Avalon Interrupt Sink 
  -----------------------------------------------------------------------------

  function conv_std_logic (
      method : irq_sink_method_id
  ) return std_logic is
  begin
    case method is
      when IRQ_SINK_GET_IRQ    => return '0';
      when IRQ_SINK_CLEAR_IRQ  => return '1';
      when others              => return 'X';
    end case;
  end function conv_std_logic;

  -----------------------------------------------------------------------------
  -- Avalon ST Source
  -----------------------------------------------------------------------------
  function conv_integer (
    sig : st_source_signal_index
  ) return integer is
  begin
    case sig is
      when ST_SRC_SIGNAL_READY          => return 0;
      when ST_SRC_SIGNAL_NOT_READY      => return 1;
      when ST_SRC_SIGNAL_TRANS_COMPLETE => return 2;
      when ST_SRC_SIGNAL_DRIVING_TRANS  => return 3;
      when ST_SRC_SIGNAL_RESERVED_4     => return 4;
      when ST_SRC_SIGNAL_RESERVED_5     => return 5;
      when ST_SRC_SIGNAL_RESERVED_6     => return 6; 
      when ST_SRC_SIGNAL_RESERVED_7     => return 7;
      when others                       => return -1;          
    end case;
  end function conv_integer;

  function conv_std_logic (    
      method : st_source_method_id
  ) return std_logic_vector is
  begin
    case method is
      when ST_SRC_INIT                   => return X"00";      
      when ST_SRC_SET_RESP_TIMEOUT       => return X"01";   
      when ST_SRC_PUSH_TRANS             => return X"02"; 
      when ST_SRC_GET_TRANS_QUEUE_SIZE   => return X"03";
      when ST_SRC_GET_RESP_QUEUE_SIZE    => return X"04";
      when ST_SRC_SET_TRANS_DATA         => return X"05";
      when ST_SRC_SET_TRANS_CHANNEL      => return X"06";
      when ST_SRC_SET_TRANS_IDLES        => return X"07";
      when ST_SRC_SET_TRANS_SOP          => return X"08";
      when ST_SRC_SET_TRANS_EOP          => return X"09";
      when ST_SRC_SET_TRANS_ERROR        => return X"0A";
      when ST_SRC_SET_TRANS_EMPTY        => return X"0B";
      when ST_SRC_POP_RESP               => return X"0C";
      when ST_SRC_GET_RESP_LATENCY       => return X"0D";
      when ST_SRC_GET_SRC_READY          => return X"0E";
      when ST_SRC_GET_SRC_TRANS_COMPLETE => return X"0F";
      when others                        => return X"FF";
    end case;
  end function conv_std_logic;

  -----------------------------------------------------------------------------
  -- Avalon ST Sink
  -----------------------------------------------------------------------------
  function conv_integer (
    sig : st_sink_signal_index
  ) return integer is
  begin
    case sig is
      when ST_SINK_SIGNAL_TRANS_RECEIVED => return 0;
      when ST_SINK_SIGNAL_READY_ASSERT   => return 1;
      when ST_SINK_SIGNAL_READY_DEASSERT => return 2;
      when ST_SINK_SIGNAL_RESERVED_3     => return 3;
      when ST_SINK_SIGNAL_RESERVED_4     => return 4;
      when ST_SINK_SIGNAL_RESERVED_5     => return 5;
      when ST_SINK_SIGNAL_RESERVED_6     => return 6;
      when ST_SINK_SIGNAL_RESERVED_7     => return 7;
      when others                        => return -1; 
    end case;                      
  end function conv_integer;
                      
  function conv_std_logic (
    method : st_sink_method_id
  ) return std_logic_vector is
  begin
    case method is    
      when ST_SINK_INIT                 => return X"00";
      when ST_SINK_SET_READY            => return X"01";
      when ST_SINK_POP_TRANS            => return X"02";
      when ST_SINK_GET_TRANS_IDLES      => return X"03";
      when ST_SINK_GET_TRANS_DATA       => return X"04";
      when ST_SINK_GET_TRANS_CHANNEL    => return X"05";
      when ST_SINK_GET_TRANS_SOP        => return X"06";
      when ST_SINK_GET_TRANS_EOP        => return X"07";
      when ST_SINK_GET_TRANS_ERROR      => return X"08";
      when ST_SINK_GET_TRANS_EMPTY      => return X"09"; 
      when ST_SINK_GET_TRANS_QUEUE_SIZE => return X"0A";
      when others                       => return X"FF";                      
    end case;                                            
  end function conv_std_logic;

  
  -----------------------------------------------------------------------------
  -- Avalon MM Master
  -----------------------------------------------------------------------------
  function conv_integer (
    sig : mm_mstr_signal_index
  ) return integer is
  begin
    case sig is
      when MM_MSTR_SIGNAL_FATAL_ERROR        => return 0; 
      when MM_MSTR_SIGNAL_RESPONSE_COMPLETE  => return 1; 
      when MM_MSTR_SIGNAL_COMMAND_ISSUED     => return 2; 
      when MM_MSTR_SIGNAL_ALL_TRANS_COMPLETE => return 3; 
      when MM_MSTR_SIGNAL_RESERVED_4         => return 4; 
      when MM_MSTR_SIGNAL_RESERVED_5         => return 5; 
      when MM_MSTR_SIGNAL_RESERVED_6         => return 6; 
      when MM_MSTR_SIGNAL_RESERVED_7         => return 7; 
      when others                            => return -1; 
    end case;
    
  end function conv_integer;
  
  function conv_std_logic (
    method : mm_mstr_method_id
  ) return std_logic_vector is
  begin

    case method is    
      when MM_MSTR_INIT                       => return X"00";
      when MM_MSTR_SET_RESP_TIMEOUT           => return X"01";
      when MM_MSTR_SET_CMD_TIMEOUT            => return X"02";

      when MM_MSTR_ALL_TRANS_COMPLETE         => return X"03"; 
      when MM_MSTR_GET_CMD_ISSUE_QUEUE_SIZE   => return X"04"; 
      when MM_MSTR_GET_CMD_PEND_QUEUE_SIZE    => return X"05"; 
      when MM_MSTR_GET_RESP_QUEUE_SIZE        => return X"06";
      when MM_MSTR_PUSH_CMD                   => return X"07";
      when MM_MSTR_POP_RESP                   => return X"08"; 

      when MM_MSTR_SET_CMD_DATA               => return X"09";  
      when MM_MSTR_SET_CMD_ADDRESS            => return X"0A"; 
      when MM_MSTR_SET_CMD_BYTE_ENABLE        => return X"0B"; 
      when MM_MSTR_SET_CMD_BURST_COUNT        => return X"0C";
      when MM_MSTR_SET_CMD_IDLE               => return X"0D"; 
      when MM_MSTR_SET_CMD_REQUEST            => return X"0E"; 
      when MM_MSTR_SET_CMD_RESERVED_1         => return X"0F";   

      when MM_MSTR_GET_RESP_REQUEST           => return X"10";
      when MM_MSTR_GET_RESP_DATA              => return X"11";    
      when MM_MSTR_GET_RESP_ADDRESS           => return X"12"; 
      when MM_MSTR_GET_RESP_BYTE_ENABLE       => return X"13"; 
      when MM_MSTR_GET_RESP_BURST_SIZE        => return X"14"; 
      when MM_MSTR_GET_RESP_LATENCY           => return X"15"; 
      when MM_MSTR_GET_RESP_WAIT_TIME         => return X"16";

      when MM_MSTR_SET_CMD_INIT_LATENCY       => return X"17";
      when MM_MSTR_SET_CMD_BURST_SIZE         => return X"18";   

      when others                             => return X"FF";  
    end case;                                                
  end function conv_std_logic;


  -----------------------------------------------------------------------------
  -- Avalon MM Slave
  -----------------------------------------------------------------------------
  function conv_integer (
    sig : mm_slv_signal_index
  ) return integer is
  begin
    case sig is

      when MM_SLV_SIGNAL_FATAL_ERROR                    => return 0; 
      when MM_SLV_SIGNAL_ERROR_EXCEED_MAX_PENDING_READS => return 1;  
      when MM_SLV_SIGNAL_COMMAND_RECEIVED               => return 2; 
      when MM_SLV_SIGNAL_RESP_ISSUED                    => return 3; 
      when MM_SLV_SIGNAL_RESERVED_4        		=> return 4;  
      when MM_SLV_SIGNAL_RESERVED_5        		=> return 5; 
      when MM_SLV_SIGNAL_RESERVED_6        		=> return 6; 
      when MM_SLV_SIGNAL_RESERVED_7        		=> return 7; 	
      when others                                       => return -1; 
    end case;
  end function conv_integer;
  
  function conv_std_logic (
    method : mm_slv_method_id
  ) return std_logic_vector is
  begin

    case method is
      when MM_SLV_INIT                 => return X"00";
      when MM_SLV_SET_RESP_TIMEOUT     => return X"01";

      when MM_SLV_GET_CMD_QUEUE_SIZE   => return X"02";
      when MM_SLV_GET_RESP_QUEUE_SIZE  => return X"03";
      when MM_SLV_PUSH_RESP            => return X"04";
      when MM_SLV_POP_CMD              => return X"05";

      when MM_SLV_SET_RESP_DATA        => return X"06";
      when MM_SLV_SET_RESP_BURST_SIZE  => return X"07";
      when MM_SLV_SET_RESP_LATENCY     => return X"08";

      when MM_SLV_SET_INTERFACE_WAIT_TIME => return X"09";
      when MM_SLV_GET_CMD_REQUEST      => return X"0A";
      when MM_SLV_GET_CMD_DATA         => return X"0B";
      when MM_SLV_GET_CMD_ADDRESS      => return X"0C";
      when MM_SLV_GET_CMD_BYTE_ENABLE  => return X"0D";
      when MM_SLV_GET_CMD_BURST_COUNT  => return X"0E"; 
      when MM_SLV_GET_CMD_BURST_CYCLE  => return X"0F"; 

      when others                             => return X"FF";  
    end case;                                                
  end function conv_std_logic;
  
end package body altera_avalon_components_pkg;
  
