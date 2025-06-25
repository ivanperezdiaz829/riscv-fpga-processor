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


---------------------------------------------------------------------------------------------------------------------------------
-- Entity name: tb_altera_cpri_c4gx_autorate                                                                                         
--
-- Description: This is the customer demo testbench to test autorate negotiation feature for the CPRI MegaCore
--              based on the REC loopback configuration with starting linerate of 0.6144Gbps to 1Gbps and then back to 0.6144Gbps.               
--                    
-- Limitation : Only cater for Cyclone IV GX device        
---------------------------------------------------------------------------------------------------------------------------------
library ieee, std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use work.all;

entity tb is                      
end tb;          

architecture behavioral of tb is
-- The value for the register is shift right 2 bits before send in to the core.
constant REG_CPRI_CONFIG    	    : std_logic_vector(13 downto 0) := conv_std_logic_vector(16#02#,14);--actual value 0x08 
constant REG_CPRI_RATE_CONFIG       : std_logic_vector(13 downto 0) := conv_std_logic_vector(16#12#,14);--actual value 0x48  

-- State machine for altpll_reconfig
type   STATE_TYPE            is ( IDLE,
                                  WAIT_READ_MIF_FROM_ROM_BUSY,
                                  READ_MIF_FROM_ROM,
                                  WAIT_RECONFIG_BUSY,
                                  RECONFIG,
                                  WAIT_FOR_PARAM_WRITE,
                                  RESET_ROM_ADDR_DONE
                                   );

-- State machine for altgx_reconfig                                   
type STATE_TYPE2 is ( IDLE,
                      BUSY,
                      START_WRITE_EN
                      );
                                   
signal STATE_PLL               : STATE_TYPE;
signal STATE_GX                : STATE_TYPE2;

-- altgx_c4gx_reconfig_cpri 
signal reconfig_clk_wire		    : std_logic:='0';
-- altpll_c4gx_reconfig_cpri
signal clock_wire		            : std_logic := '0';
signal pll_areset_in_wire		    : std_logic := '0';
signal reconfig_wire		        : std_logic := '0' ;
signal reconfig_tx_wire             : std_logic := '0';
signal reconfig_rx_wire             : std_logic := '0';
signal reset_wire		            : std_logic := '0';
signal altpll_busy_wire		        : std_logic_vector (1 downto 0) := "00" ;
signal rom_rx_address_out_wire		: std_logic_vector (7 downto 0);
signal rom_tx_address_out_wire		: std_logic_vector (7 downto 0);
signal write_rx_rom_ena_wire		: std_logic :='0';
signal write_tx_rom_ena_wire		: std_logic :='0';
signal start_configure_hold	        : std_logic :='0';
signal rxpll_reset_rom_addr_wire    : std_logic :='0';
signal rxpll_rom_data_in_wire	    : std_logic :='0';
signal rxpll_write_from_rom_wire    : std_logic :='0';
signal txpll_reset_rom_addr_wire    : std_logic :='0';
signal txpll_rom_data_in_wire	    : std_logic :='0';  
signal txpll_write_from_rom_wire    : std_logic :='0';

-- rom for 1228 and 614
signal reconfig_data                : std_logic_vector (15 downto 0) := (others=>'0');
signal channel_reconfig_done        : std_logic :='0';
signal reconfig_address_en          : std_logic :='0';
signal reconfig_address_out         : std_logic_vector (5 downto 0) := (others=> '0');
signal error_wire                        : std_logic :='0';
signal write_1228_reconfig_data     : std_logic :='0';
signal write_614_reconfig_data      : std_logic :='0';
signal rom_1228_reconfig_add        : std_logic_vector (7 downto 0) := (others=>'0');
signal rom_614_reconfig_add         : std_logic_vector (7 downto 0) := (others=> '0');
signal rom_c4gx_614_reconfig_data   : std_logic_vector (15 downto 0) := (others=>'0');
signal rom_c4gx_1228_reconfig_data  : std_logic_vector (15 downto 0) := (others=>'0');
signal rom_c4gx_1228_tx_data_wire	: std_logic_vector (0 downto 0);
signal rom_c4gx_1228_rx_data_wire	: std_logic_vector (0 downto 0);
signal rom_c4gx_614_tx_data_wire	: std_logic_vector (0 downto 0);
signal rom_c4gx_614_rx_data_wire	: std_logic_vector (0 downto 0);

-- MISC signals
signal cpri_rx_sync_state           : std_logic:= '0';
signal start_configure  		    : std_logic:= '0';
signal op_cnt                       : std_logic_vector (3 downto 0);
signal cpu_running                  : std_logic:= '0';
signal clk_15_36                    : std_logic:= '0';
signal clk_61_44				    : std_logic:= '0';
signal clk_30_72				    : std_logic:= '0';
signal gxb_clk_61_44                : std_logic:= '0';
signal gxb_clk_122_8                : std_logic:= '0';
signal clk_check_configure		    : std_logic_vector(3 downto 0):=(others=>'0');
signal gxb_refclk_select            : std_logic_vector(3 downto 0):=(others=>'0');
signal clk_compare				    : std_logic:= '0';
signal cpu_done_compare             : std_logic:= '0';
signal cpri_rec_loopback_wire       : std_logic;
signal cpri_rx_sync_state2	        : std_logic:= '0';
signal num_configure		        : std_logic_vector(3 downto 0):=(others=>'0');
signal completed_configure	        : std_logic:= '0';
signal alarm_detected	            : std_logic:= '0';
signal done_configure  	            : std_logic:= '1';
signal cpri_rx_sync                 : std_logic:= '0'; 
signal fsm_stop                     : std_logic:= '0';
signal fsm_altgx_start              : std_logic:= '0';
signal fsm_altgx_stop               : std_logic:= '0';
signal reset_freq_check_wire	    : std_logic:= '0';
signal start_freq_checking          : std_logic:= '0';
signal freq_alarm_hold	            : std_logic:= '0';
signal freq_alarm_wire	   		    : std_logic:= '0';
signal alarm_detected_edge		    : std_logic:= '0'; 

-- CPRI top level wire
signal gxb_refclk_wire               : std_logic                     := '0';             
signal gxb_cal_blk_clk_wire          : std_logic                     := '0';             
signal gxb_powerdown_wire            : std_logic                     := '0';             
signal gxb_pll_locked_wire           : std_logic;                                        
signal gxb_rx_pll_locked_wire        : std_logic;                                        
signal gxb_rx_freqlocked_wire        : std_logic;                                        
signal gxb_rx_errdetect_wire         : std_logic_vector(3 downto 0);                     
signal gxb_rx_disperr_wire           : std_logic_vector(3 downto 0);                     
signal gxb_los_wire                  : std_logic                     := '0';                        
signal reconfig_busy_wire            : std_logic                     := '0';             
signal reconfig_write_wire           : std_logic                     := '0';             
signal reconfig_done_wire            : std_logic                     := '0';             
signal reconfig_togxb_m_wire         : std_logic_vector(3 downto 0)  := (others => '0'); 
signal reconfig_fromgxb_m_wire       : std_logic_vector(4 downto 0);                     
signal pll_areset_wire               : std_logic_vector(1 downto 0)  := (others => '0'); 
signal pll_configupdate_wire         : std_logic_vector(1 downto 0)  := (others => '0'); 
signal pll_scanclk_wire              : std_logic_vector(1 downto 0)  := (others => '0'); 
signal pll_scanclkena_wire           : std_logic_vector(1 downto 0)  := (others => '0'); 
signal pll_scandata_wire             : std_logic_vector(1 downto 0)  := (others => '0'); 
signal pll_reconfig_done_wire        : std_logic_vector(1 downto 0);                     
signal pll_scandataout_wire          : std_logic_vector(1 downto 0);                     
signal cpri_clkout_wire              : std_logic;                                        
signal pll_clkout_wire               : std_logic;                                        
signal reset_done_wire               : std_logic;                                        
signal config_reset_wire             : std_logic                     := '0';             
signal clk_ex_delay_wire             : std_logic                     := '0';             
signal reset_ex_delay_wire           : std_logic                     := '0';             
signal hw_reset_req_wire             : std_logic;                                        
signal extended_rx_status_data_wire  : std_logic_vector(11 downto 0);                    
signal datarate_en_wire              : std_logic;                                        
signal datarate_set_wire             : std_logic_vector(4 downto 0);                     
signal cpu_reset_wire                : std_logic                     := '0';             
signal cpu_writedata_wire            : std_logic_vector(31 downto 0) := (others => '0'); 
signal cpu_read_wire                 : std_logic                     := '0';             
signal cpu_write_wire                : std_logic                     := '0';             
signal cpu_readdata_wire             : std_logic_vector(31 downto 0);                    
signal cpu_address_wire              : std_logic_vector(13 downto 0) := (others => '0'); 
signal cpu_waitrequest_wire          : std_logic;                                        
signal cpu_irq_wire                  : std_logic;                                        
signal cpu_irq_vector_wire           : std_logic_vector(4 downto 0);                     
signal aux_rx_status_data_wire       : std_logic_vector(75 downto 0);                    
signal aux_tx_status_data_wire       : std_logic_vector(43 downto 0);                    
signal aux_tx_mask_data_wire         : std_logic_vector(64 downto 0) := (others => '0');  
signal s_reset_done_wire             : std_logic := '0';
subtype gray_cnt_type is std_logic_vector(3 downto 0);
signal check_seq : std_logic_vector(1 downto 0);
signal cnt : gray_cnt_type;
signal cnt_check : gray_cnt_type;
signal cnt_check_s0 : gray_cnt_type;
signal cnt_check_s1 : gray_cnt_type; 
signal diff : gray_cnt_type;
signal resync : std_logic;
signal fsm_cnt : std_logic_vector( 1 downto 0):= (others => '0');
signal fsm_ctrl : std_logic_vector(1 downto 0):=(others=>'0');
signal cnt_en1 : std_logic:= '0';
signal cnt_en2 : std_logic:= '0';

-- function declaration   
function xor_all(V: in std_logic_vector) return std_logic is
   variable Q: std_logic;
begin
      Q := '0';
   for i in V'range loop
      Q := V(i) xor Q;
   end loop;
   return Q;
end;

function gray2binary( g : gray_cnt_type ) return gray_cnt_type is
   variable b : gray_cnt_type;
begin
   for n in gray_cnt_type'range loop
      b(n) := xor_all(g(gray_cnt_type'high downto n));
   end loop;
   return b;
end gray2binary;

function binary2gray( b : gray_cnt_type ) return gray_cnt_type is
   variable g : gray_cnt_type;
begin
   for n in gray_cnt_type'low to gray_cnt_type'high-1 loop
      g(n) := b(n) xor b(n+1);
   end loop;
      g(gray_cnt_type'high) := b(gray_cnt_type'high);
   return g;
end binary2gray;

function inc_gray( g : gray_cnt_type ) return gray_cnt_type is
begin
   return binary2gray(gray2binary(g) + "1");
end inc_gray;

-- component declaration
component altgx_c4gx_reconfig_cpri 
   port
   (
	  reconfig_clk		     : in std_logic ;
	  reconfig_data		     : in std_logic_vector (15 downto 0);
	  reconfig_fromgxb		 : in std_logic_vector (4 downto 0);
	  reconfig_mode_sel		 : in std_logic_vector (2 downto 0);
	  write_all		         : in std_logic ;
      error                  : out std_logic;
	  busy		             : out std_logic ;
	  channel_reconfig_done	 : out std_logic ;
	  reconfig_address_en	 : out std_logic ;
	  reconfig_address_out	 : out std_logic_vector (5 downto 0);
	  reconfig_togxb		 : out std_logic_vector (3 downto 0)
   );
end component altgx_c4gx_reconfig_cpri;
 
component altpll_c4gx_reconfig_cpri 
   port
   (
      clock		        : in std_logic ;
	  counter_param		: in std_logic_vector (2 downto 0);
	  counter_type		: in std_logic_vector (3 downto 0);
	  data_in		    : in std_logic_vector (8 downto 0);
	  pll_areset_in		: in std_logic  := '0';
	  pll_scandataout	: in std_logic ;
	  pll_scandone		: in std_logic ;
	  read_param		: in std_logic ;
	  reconfig		    : in std_logic ;
	  reset		        : in std_logic ;
	  reset_rom_address	: in std_logic  := '0';
	  rom_data_in		: in std_logic  := '0';
	  write_from_rom	: in std_logic  := '0';
	  write_param		: in std_logic ;
	  busy		        : out std_logic ;
	  data_out		    : out std_logic_vector (8 downto 0);
	  pll_areset		: out std_logic ;
	  pll_configupdate  : out std_logic ;
	  pll_scanclk       : out std_logic ;
	  pll_scanclkena	: out std_logic ;
	  pll_scandata		: out std_logic ;
	  rom_address_out	: out std_logic_vector (7 downto 0);
	  write_rom_ena		: out std_logic 
   );
end component altpll_c4gx_reconfig_cpri;

component rom_cyclone4gx_pll is
   generic (
              init_file : in string := "cyclone4gx_1228_m_rx_pll1.mif"
           );
   port
   (
	  address	: in std_logic_vector (7 downto 0);
	  clock		: in std_logic  := '1';
	  rden	    : in std_logic  := '1';
	  q		    : out std_logic_vector (0 downto 0)
   );
end component rom_cyclone4gx_pll;

component rom_cyclone4gx is
   generic (
              init_file : in string := "cyclone4gx_1228_m.mif"
           );
   port
   (
	  address	: in std_logic_vector (7 downto 0);
	  clock		: in std_logic  := '1';
	  rden	    : in std_logic  := '1';
	  q		    : out std_logic_vector (15 downto 0)
   );
end component rom_cyclone4gx;
                    
component cpri_top_level
   port 
   (
	  gxb_refclk              : in  std_logic                     := '0';            
	  gxb_pll_inclk           : in  std_logic                     := '0';            
	  gxb_cal_blk_clk         : in  std_logic                     := '0';            
	  gxb_powerdown           : in  std_logic                     := '0';            
	  gxb_pll_locked          : out std_logic;                                       
	  gxb_rx_pll_locked       : out std_logic;                                       
	  gxb_rx_freqlocked       : out std_logic;                                       
	  gxb_rx_errdetect        : out std_logic_vector(3 downto 0);                    
	  gxb_rx_disperr          : out std_logic_vector(3 downto 0);                    
	  gxb_los                 : in  std_logic                     := '0';            
	  gxb_txdataout           : out std_logic;                                       
	  gxb_rxdatain            : in  std_logic                     := '0';            
	  reconfig_clk            : in  std_logic                     := '0';            
	  reconfig_busy           : in  std_logic                     := '0';            
	  reconfig_write          : in  std_logic                     := '0';            
	  reconfig_done           : in  std_logic                     := '0';            
	  reconfig_togxb_m        : in  std_logic_vector(3 downto 0)  := (others => '0');
	  reconfig_fromgxb_m      : out std_logic_vector(4 downto 0);                    
	  pll_areset              : in  std_logic_vector(1 downto 0)  := (others => '0');
	  pll_configupdate        : in  std_logic_vector(1 downto 0)  := (others => '0');
	  pll_scanclk             : in  std_logic_vector(1 downto 0)  := (others => '0');
	  pll_scanclkena          : in  std_logic_vector(1 downto 0)  := (others => '0');
	  pll_scandata            : in  std_logic_vector(1 downto 0)  := (others => '0');
	  pll_reconfig_done       : out std_logic_vector(1 downto 0);                    
	  pll_scandataout         : out std_logic_vector(1 downto 0);                    
	  cpri_clkout             : out std_logic;                                       
	  pll_clkout              : out std_logic;                                       
	  reset                   : in  std_logic                     := '0';            
	  reset_done              : out std_logic;                                       
	  config_reset            : in  std_logic                     := '0';            
	  clk_ex_delay            : in  std_logic                     := '0';            
          hw_reset_req            : out  std_logic                     := '0';
	  reset_ex_delay          : in  std_logic                     := '0';            
          hw_reset_assert         : in  std_logic;                                     
	  extended_rx_status_data : out std_logic_vector(11 downto 0);                   
	  datarate_en             : out std_logic;                                       
	  datarate_set            : out std_logic_vector(4 downto 0);                    
	  cpu_clk                 : in  std_logic                     := '0';            
	  cpu_reset               : in  std_logic                     := '0';            
	  cpu_writedata           : in  std_logic_vector(31 downto 0) := (others => '0');
	  cpu_read                : in  std_logic                     := '0';            
	  cpu_write               : in  std_logic                     := '0';            
	  cpu_byteenable          : in  std_logic_vector(3 downto 0);                     
	  cpu_readdata            : out std_logic_vector(31 downto 0);                   
	  cpu_address             : in  std_logic_vector(13 downto 0) := (others => '0');
	  cpu_waitrequest         : out std_logic;                                       
	  cpu_irq                 : out std_logic;                                       
	  cpu_irq_vector          : out std_logic_vector(4 downto 0);                    
	  aux_rx_status_data      : out std_logic_vector(75 downto 0);                   
	  aux_tx_status_data      : out std_logic_vector(43 downto 0);                   
	  aux_tx_mask_data        : in  std_logic_vector(64 downto 0) := (others => '0') 
   );
end component cpri_top_level;

begin
   -- Supplied resets
   reset_wire <= '1', '0' after 500 ns;        -- main reset does not reset configuration registers
   cpu_reset_wire <= '1', '0' after 500 ns;    -- reset cpu 
   config_reset_wire <= '1', '0' after 500 ns; -- reset configuration registers
   pll_areset_in_wire <= '1' , '0' after 1000 ns; -- reset for altpll
      
   -- Supplied clocks  
   clk_ex_delay_wire <= not clk_ex_delay_wire after 16.1485 ns;  -- 30.96MHz
   reconfig_clk_wire <= not reconfig_clk_wire after 10 ns;       --50MHz 
   gxb_cal_blk_clk_wire <= not gxb_cal_blk_clk_wire after 10 ns; --50MHz
   clock_wire    <= not clock_wire after 10 ns;         -- 50 Mhz
   clk_15_36     <= not clk_15_36 after 32552 ps;       -- 15.36Mhz
   clk_30_72     <= not clk_30_72  after 16276 ps;      -- 30.72Mhz 
   clk_61_44     <= not clk_61_44  after 8138 ps;       -- 61.44Mhz
   gxb_clk_61_44 <= not gxb_clk_61_44 after 8138 ps;    -- 61.44MHz gxb_refclk
   gxb_clk_122_8 <= not gxb_clk_122_8 after  4069 ps;   -- 122.88Mhz
   
   with clk_check_configure select
   clk_compare <=  
                  clk_30_72   when "0001", 
                  clk_15_36   when "0010", 
                  clk_15_36   when others; 
   
   -- Provide the flexibility for the user to change
   with gxb_refclk_select select
   gxb_refclk_wire <=  
                   gxb_clk_61_44   when "0001", 
                   gxb_clk_61_44   when "0010", 
               	   gxb_clk_61_44   when others; 
               	   
   -------------------------------------------------------------------------------------------------------------------
   -- Getting Started
   -- Configure the registers to allow transaction process to take place via the CPU interface.
   -------------------------------------------------------------------------------------------------------------------
   process (cpri_clkout_wire, cpu_reset_wire)
       variable cpu_op: std_logic;
   begin  		
      if (cpu_reset_wire = '1') then
         cpu_write_wire      <= '0';
         cpu_read_wire       <= '0';
         op_cnt             <= "0000";
         cpu_op             := '0';
         cpu_address_wire   <= conv_std_logic_vector(16#00#,14);
         cpu_writedata_wire <= conv_std_logic_vector(16#00#,32);
         start_configure    <= '0';
         fsm_cnt <="00";
         fsm_altgx_start <='0';
      elsif (cpri_clkout_wire'event and cpri_clkout_wire = '1') then
         s_reset_done_wire <= reset_done_wire;
         if ((cpri_rx_sync_state = '0') and (extended_rx_status_data_wire(6) = '1')) then
            --start configure cpu register after reach BFN sync
            start_configure  <= '1'; 
            fsm_altgx_start <= '1';
            fsm_cnt <= fsm_cnt + "01";
            else
            fsm_altgx_start <= '0';
            fsm_cnt<=fsm_cnt;
	     end if;	
         if (s_reset_done_wire = '1') then 	  	
            if (cpu_waitrequest_wire = '0' and cpu_op = '0' ) then
               -- Write to cpri_config register by setting tx_ctrl_insert_en, master mode, no loop, tx_enable.
               if (op_cnt = "0000") then
                  cpu_address_wire   <= REG_CPRI_CONFIG;
                  cpu_writedata_wire <= conv_std_logic_vector(16#0021#,32);
                  cpu_write_wire     <= '1';
                  cpu_read_wire      <= '0';
                  op_cnt             <= op_cnt + '1';
                  cpu_op             := '1';
               end if;
               -- Read back cpri_config register to ensure the data has been correctly written.
               if (op_cnt = "0001") then
                  cpu_address_wire <= REG_CPRI_CONFIG;
                  cpu_write_wire   <= '0';
                  cpu_read_wire    <= '1';
                  cpu_op           := '1';
               end if;
              
               ------------------------------------------------------------
               -- REG_CPRI_RATE_CONFIG
               -- i_datarate_en[4],i_datarate_set[3:0],
               ------------------------------------------------------------
               -- 0001: 614 Mbps(1)
               -- 0010:1228.8Mbps(2)
               -- 0100:2457.6Mbps(4)			
               -- 0101:3072.0Mbps(5)
               -- 1000:4915.0Mbps(8)
               -- 1010:6144.0Mbps(A)
               -------------------------------------------------------------
               -- Write register auto_rate_config, switch from 614Mbps to 1228.8Mbps
  			   if (op_cnt = "0010") and start_configure = '1' then							
                  cpu_address_wire   <= REG_CPRI_RATE_CONFIG;							
                  cpu_writedata_wire <= conv_std_logic_vector(16#2#,32);
                  cpu_write_wire     <= '1';
                  cpu_read_wire      <= '0';
                  op_cnt             <= op_cnt + '1';
                  cpu_op             := '1';
                  start_configure    <= '0';
                  fsm_altgx_start    <= '0';
                  gxb_refclk_select  <= gxb_refclk_select+ '1'  ;
               end if;
               -- Read back cpri_config register to ensure the data has been correctly written.
               if (op_cnt = "0011") then
                  cpu_address_wire <= REG_CPRI_RATE_CONFIG;
                  cpu_write_wire   <= '0';
                  cpu_read_wire    <= '1';
                  cpu_op           := '1';
               end if;
               
               -- Write register auto_rate_config, switch from 1228.8Mbps to 614Mbps			
               if (op_cnt = "0100") and start_configure = '1' then						
                  cpu_address_wire   <= REG_CPRI_RATE_CONFIG;					
                  cpu_writedata_wire <= conv_std_logic_vector(16#1#,32);
                  cpu_write_wire     <= '1';
                  cpu_read_wire      <= '0';
                  op_cnt             <= op_cnt + '1';
                  cpu_op             := '1';
                  start_configure    <= '0';
                  gxb_refclk_select  <= gxb_refclk_select+ '1';
                  fsm_altgx_start    <= '0';
               end if;
               -- Read back cpri_config register to ensure the data has been correctly written.
               if (op_cnt = "0101") then
                  cpu_address_wire <= REG_CPRI_RATE_CONFIG;
                  cpu_write_wire   <= '0';
                  cpu_read_wire    <= '1';
                  cpu_op           := '1';
               end if;
            end if;
            -- Read waitrequest signal, perform avalon-mm transactions.
            if (cpu_op = '1') then	
               if (cpu_waitrequest_wire = '1') then
                  cpu_running <= '1';
               end if;
               if (cpu_running = '1' and cpu_waitrequest_wire = '0') then
                  cpu_write_wire <= '0';
                  cpu_read_wire  <= '0';
                  cpu_op         := '0';
                  cpu_running    <= '0';
               if (op_cnt = "0001") then
  	              if cpu_readdata_wire = conv_std_logic_vector(16#0021#,32) then
  	  	  	         report "CPU:write cpri_config done " severity NOTE;	
                     op_cnt <= op_cnt + '1';
  	  	          end if;		 				 		
  	           end if;
  	           if (op_cnt = "0011") then
  	  		      if cpu_readdata_wire = conv_std_logic_vector(16#22#,32) then
  	  	  		     report "CPU:write 1G at cpri_rate_config done" severity NOTE;
                     op_cnt <= op_cnt + '1';
  	  	          end if;		 				 		
  	           end if;
  	           if (op_cnt = "0101") then
  	  		      if cpu_readdata_wire = conv_std_logic_vector(16#21#,32) then
  	  	  	         report "CPU:write 614.4M at cpri_rate_config done " severity NOTE;	
                     op_cnt <= op_cnt + '1';
                     cpu_done_compare <= '1';
  	  	          end if;		 				 		
  	           end if;
            end if;
         end if;
      end if;
   end if;		 
end process;            	   

-----------------------------------------------------------------------------------------------------------------
------------Perform reconfiguration for altgx_reconfig_block----------------------------------------------------
-----------------------------------------------------------------------------------------------------------------		
-- Signal Swicth
-- To cater for different connection between ROM and altpll/altgx_reconfig block when differnt linerate is configured.
process(clock_wire,reset_wire)
   begin
      if num_configure = "0000" then    --switch to 1G
         -- altgx reconfig
         reconfig_data                     <= rom_c4gx_1228_reconfig_data;
         rom_1228_reconfig_add(5 downto 0) <= reconfig_address_out ;
         write_1228_reconfig_data          <= reconfig_address_en;
         -- altpll reconfig
         txpll_rom_data_in_wire            <= rom_c4gx_1228_tx_data_wire(0); 
	     rxpll_rom_data_in_wire            <= rom_c4gx_1228_rx_data_wire(0); 
      elsif num_configure = "0001" then --switch back to 0.6144 G
         -- altgx_reconfig
         reconfig_data                     <= rom_c4gx_614_reconfig_data;
         rom_614_reconfig_add(5 downto 0)  <= reconfig_address_out ;
         write_614_reconfig_data           <= reconfig_address_en;
         -- altpll_reconfig
	     txpll_rom_data_in_wire            <= rom_c4gx_614_tx_data_wire(0);
	     rxpll_rom_data_in_wire            <= rom_c4gx_614_rx_data_wire(0);     
      elsif num_configure = "0010" and alarm_detected = '0' then
	     completed_configure <= '1';
         -- terminate all the FSM operation after the altgx_reconfig and altpll_reconfig are completed
         fsm_stop <= '1';
         fsm_altgx_stop <='1';
      else
         txpll_rom_data_in_wire <= '0';
         rxpll_rom_data_in_wire <= '0';
      end if;
end process;	

-- FSM control
-- This can avoid the altpll_reconfig from executing twice 
process (reconfig_clk_wire ,reset_wire)
   begin
   if reset_wire ='1' then    
      fsm_ctrl <= "00" ;
   elsif reconfig_clk_wire'event and reconfig_clk_wire = '1' then
      if ((cnt_en1 = '1' ) or (cnt_en2 ='1')) then
         fsm_ctrl <= fsm_ctrl + "1";
      else
         fsm_ctrl<=fsm_ctrl;
      end if;
   end if;
end process;

-- BFN Check
-- To indicate the reconfig process has begun once the BFN statd of the cPRI core is reached.	     	
process(reconfig_clk_wire, cpu_reset_wire)
   begin
      if cpu_reset_wire = '1' then
	     done_configure <= '1';
	     cpri_rx_sync_state2 <= '0';  
      elsif reconfig_clk_wire'event and reconfig_clk_wire = '1' then
	     cpri_rx_sync_state2 <= extended_rx_status_data_wire(6);  	
	     if ((cpri_rx_sync_state2 = '0') and (extended_rx_status_data_wire(6) = '1') and (completed_configure = '0')) then
	        done_configure <='0'; -- Start the altpll_reconfig when CPRI core achieves Basic Frame Synchorization (BFN)
	        report "Start to reconfigure gxb_reconfig_block " severity NOTE;	
	     end if;	 
      end if;  	
end process;

------------------------------
-- FSM_ALTGX_RECONFIG
------------------------------
FSM_ALTGX_RECONFIG: 
   process(reconfig_clk_wire,reset_wire)
   variable busy_cnt : integer := 0;
   begin 
      if (reset_wire = '1') then
         reconfig_write_wire		         <='0';    
         busy_cnt := 0;    
      elsif (reconfig_clk_wire'event and reconfig_clk_wire = '1') then
         case STATE_GX is
         -- waiting for the fsm_altgx_start to be asserted when bfn state is reached.
         when IDLE=>
            cnt_en1 <= '0';
         if (fsm_altgx_start = '1') and (fsm_altgx_stop = '0') then 
            if fsm_cnt= "10" then
               busy_cnt :=4;
            end if;
         reconfig_write_wire<='0'; 
         STATE_GX <= START_WRITE_EN;   
         else
            STATE_GX<=IDLE; 
         end if;
      
         -- extract the MIF from the ROM and write into the altgx_reconfig.
         -- ONLY assert the reconfig_write when the busy signal is deasserted.
         when START_WRITE_EN=>
         if reconfig_busy_wire = '0' then 
         --wait for 4 cycle again before the next write is asserted.
         --This is to make sure busy is deasserted while write operation is executed.
         if busy_cnt = 4 and ((reconfig_done_wire = '0') or (reconfig_done_wire='1' and fsm_cnt="10")) then
            reconfig_write_wire <='1'; 
            STATE_GX <= BUSY;
         elsif reconfig_done_wire = '1' then
            cnt_en1 <='1';   
            STATE_GX <= IDLE;
         else
            busy_cnt := busy_cnt + 1; 
            STATE_GX<= START_WRITE_EN;
         end if;    
         end if; 
         
         -- deasserted the write and 
         when BUSY=>
            reconfig_write_wire <='0';
            busy_cnt := 0;
            --fsm_stop <='0';
            STATE_GX <=START_WRITE_EN;
         end case;
      end if;
   end process;

------------------------------
-- FSM_ALTPLL_RECONFIG
------------------------------
FSM_ALTPLL_RECONFIG: 
   process(reconfig_clk_wire, reset_wire)
   begin
      if (reset_wire = '1') then
         STATE_PLL                 <= IDLE;
         txpll_write_from_rom_wire <= '0';
         rxpll_write_from_rom_wire <= '0';
         txpll_reset_rom_addr_wire <= '1';
         rxpll_reset_rom_addr_wire <= '1';
         reconfig_tx_wire <= '0';
         reconfig_rx_wire <= '0';
         num_configure <= "0000";
      elsif (reconfig_clk_wire'event and reconfig_clk_wire = '1') then
      case STATE_PLL is
         when IDLE => 
         -- fsm_ctrl stop the FSM_ALTPLL_RECONFIG from doing it twice
         -- altpll only will start once altgx_reconfig is done (as indicated by the reconfig_done_wire)
         -- fsm_stop is to stop this FSM permanently.
            if (reset_done_wire ='1') and (fsm_stop ='0') and (reconfig_done_wire ='1') and (fsm_ctrl ="01" or fsm_ctrl="11")then 
               txpll_write_from_rom_wire <= '0';
			   rxpll_write_from_rom_wire <= '0';   
			   txpll_reset_rom_addr_wire <= '0';
			   rxpll_reset_rom_addr_wire <= '0'; 
               STATE_PLL <= WAIT_READ_MIF_FROM_ROM_BUSY; 
            else     
               STATE_PLL <= IDLE;
            end if;
         
         -- extract the MIF content from the ROM    
         when WAIT_READ_MIF_FROM_ROM_BUSY =>
               txpll_write_from_rom_wire <= '1';
			   rxpll_write_from_rom_wire <= '1'; 
			if altpll_busy_wire = "11" then
			   STATE_PLL <= READ_MIF_FROM_ROM;
			else                
               STATE_PLL <= WAIT_READ_MIF_FROM_ROM_BUSY;
            end if;
         
         -- enable the reconfig signal    			   		 
         when READ_MIF_FROM_ROM =>
               txpll_write_from_rom_wire <= '0';
			   rxpll_write_from_rom_wire <= '0';			
			if altpll_busy_wire = "00" then 
               reconfig_tx_wire <= '1';
               reconfig_rx_wire <= '1'; 
               STATE_PLL <= WAIT_RECONFIG_BUSY;
            else
			   STATE_PLL <= READ_MIF_FROM_ROM;
            end if;
         
         -- wait for reconfig busy   
         when WAIT_RECONFIG_BUSY =>
			   reconfig_tx_wire <= '1';
               reconfig_rx_wire <= '1'; 
			if altpll_busy_wire = "11" then
			   STATE_PLL <= RECONFIG;
			else                
               STATE_PLL <= WAIT_RECONFIG_BUSY;
            end if;
         
         -- deassert the reconfig signal once busy is asserted  
         when RECONFIG =>	
				reconfig_tx_wire <= '0';
				reconfig_rx_wire <= '0'; 		   
			if altpll_busy_wire = "11" then
			   STATE_PLL <= RECONFIG;
			else                
               STATE_PLL <= WAIT_FOR_PARAM_WRITE;
            end if;   
         
         -- reset rom addr      
         when WAIT_FOR_PARAM_WRITE =>  
               txpll_reset_rom_addr_wire <= '1';
		   	   rxpll_reset_rom_addr_wire <= '1';  
		   	   reconfig_tx_wire <= '0';
		   	   reconfig_rx_wire <= '0';       
               num_configure <= num_configure + '1';
               cnt_en2 <= '1';
               STATE_PLL <= RESET_ROM_ADDR_DONE;
         
         -- pll_reconfig completed   
         when RESET_ROM_ADDR_DONE =>
            txpll_reset_rom_addr_wire <= '0';
		   	rxpll_reset_rom_addr_wire <= '0';
            cnt_en2 <= '0';
            STATE_PLL <= IDLE;
            
         when others =>
               STATE_PLL          <= IDLE;
         end case;
      end if;
   end process FSM_ALTPLL_RECONFIG;  	
   	
-------------------------------------------------------------------------------------------------------------------
-- Check on the CPRI link for synchronization (cpri_rx_bfn_state is bit 6 of extended_rx_status_data)
-------------------------------------------------------------------------------------------------------------------
process (reset_wire, cpri_clkout_wire)
begin
   if (reset_wire = '1') then 		
      cpri_rx_sync_state <= '0';    
   elsif (cpri_clkout_wire'event and  cpri_clkout_wire = '1') then   
      cpri_rx_sync_state <= extended_rx_status_data_wire(6);
      if ((cpri_rx_sync_state = '0') AND (extended_rx_status_data_wire(6) = '1')) then
         report "RX has achieved BFN synchronization" severity NOTE;
         cpri_rx_sync <= '1';
      end if;	
      if ((cpri_rx_sync_state = '1') AND (extended_rx_status_data_wire(6) = '0')) then
          report "RX has lost BFN synchronization" severity NOTE;
          cpri_rx_sync <= '0';
      end if;	  	   
   end if;
end process;

------------------------------------------------------------------------------------------
--------checking on cpri_clkout for rate changes------------------------------------------	
------------------------------------------------------------------------------------------	
process(reconfig_clk_wire)
   variable duration_cnt : integer := 0;
   variable freq_alarm_cnt : integer := 0;
   begin	
   start_configure_hold <= start_configure ; 
   if (start_configure_hold = '0') and (start_configure = '1')  and (completed_configure = '0') then
      reset_freq_check_wire <= '1';					--trigger reset_freq_check to start the checking
      start_freq_checking <= '1';	
      clk_check_configure <= clk_check_configure + '1';
   end if;		
   if reset_freq_check_wire = '1' then
      reset_freq_check_wire <= '0';
   end if;		
   if start_freq_checking = '1' then				
      freq_alarm_hold <= freq_alarm_wire;
      if (freq_alarm_hold = '0') and (freq_alarm_wire = '1') then  --detected freq_alarm and increase the counter
 	     freq_alarm_cnt := freq_alarm_cnt + 1;
 	  end if;
 	  if duration_cnt = 50 then 
 	     duration_cnt := 0;
 	  else
 	     duration_cnt := duration_cnt + 1;   
 	  end if;		
 	  if duration_cnt = 50 then         --perform checking on freq_alarm every 50 clock cycle
 	     if freq_alarm_cnt > 0  then    --if alarm detected, the linerate not match yet
 	        alarm_detected <= '1';
 	        freq_alarm_cnt := 0 ;
 	     else
 	        alarm_detected <= '0';
 	     end if;  		
 	  end if;
   end if; 	
   alarm_detected_edge <= alarm_detected;
   if (alarm_detected = '0') and (alarm_detected_edge = '1') then		    
      report "Correct cpri_clkout frequency is detected" severity NOTE;
   end if;			
end process;
			
process(cpri_clkout_wire,reset_freq_check_wire) 
   begin
      if reset_freq_check_wire = '1' then
        check_seq <= (others => '0');
        cnt_check <= (others => '0');
      elsif cpri_clkout_wire'event and cpri_clkout_wire = '1' then
         check_seq <= check_seq + 1;
         if false then
            if check_seq = "11" then
               cnt_check <= inc_gray(cnt_check);
            end if;
         else 
            if not false or check_seq(0) = '1' then
               cnt_check <= inc_gray(cnt_check);
            end if;
         end if;
      end if;
end process;

diff <= gray2binary(cnt_check_s1) - gray2binary(cnt);
 	
process(clk_compare,reset_freq_check_wire) 
   begin
      if reset_freq_check_wire = '1' then
 	     cnt_check_s0 <= (others => '0');
 	     cnt_check_s1 <= (others => '0');
 	     cnt <= (others => '0');
 	     resync <= '0';
 	     freq_alarm_wire <= '0';
 	  elsif clk_compare'event and clk_compare = '1' then
 	     cnt_check_s0 <= cnt_check;
 	     cnt_check_s1 <= cnt_check_s0;
 	     if (diff > (2**(4-2))) and (diff < 3*(2**(4-2))) then
 	        resync <= '0';
 	     else
 	        resync <= '1';
 	     end if;
 	  if resync = '1' then
 	     cnt <= binary2gray(gray2binary(cnt_check_s1)+conv_std_logic_vector(2**(4-1),4));
 	  else
 	     cnt <= inc_gray(cnt);
 	  end if;
 	     freq_alarm_wire <= resync;
 	  end if;
end process;

-----------------------------------------------------------------------------------------------------------------------
------------------------------------ Report error message at the end of simulation ------------------------------------
-----------------------------------------------------------------------------------------------------------------------
testbench : process is
   variable txt_output : LINE;
begin
   wait for 3.2 ms;

   if cpu_done_compare = '0' then
      report "CPU : CPU read write failed" severity error;  
   end if;
    
   if alarm_detected = '0' then
      report "Linerate Match" severity NOTE; 
   else
      report "Linerate Not Match" severity error; 
   end if;

   if  cpri_rx_sync = '1' and cpu_done_compare = '1' and alarm_detected = '0' and completed_configure = '1' then
      report "Testbench is completed, No Errors detected" severity NOTE;
      write(txt_output, string'("*************************************************************************"));
      writeline(output, txt_output);
      write(txt_output, string'("\$\$\$ End of testbench customer_demo_tb"));
      writeline(output, txt_output);
      write(txt_output, string'("RUNNING ACTUAL_TC =           1  RUNNING EXPECTED_TC =           1"));
      writeline(output, txt_output);
      write(txt_output, string'("RUNNING ACTUAL_ERR =          0, "));
      writeline(output, txt_output);
      write(txt_output, string'("\$\$\$ Exit status for testbench customer_demo_tb :  TESTBENCH_PASSED "));
      writeline(output, txt_output);
      write(txt_output, string'("*************************************************************************"));
      writeline(output, txt_output);
      report "None. No Failures." severity FAILURE;
   else
      report "Testbench is completed, Errors detected!" severity WARNING;
      write(txt_output, string'("*************************************************************************"));
      writeline(output, txt_output);
      write(txt_output, string'("\$\$\$ End of testbench customer_demo_tb"));
      writeline(output, txt_output);
      write(txt_output, string'("RUNNING ACTUAL_TC =           1  RUNNING EXPECTED_TC =           1"));
      writeline(output, txt_output);
      write(txt_output, string'("RUNNING ACTUAL_ERR =          1, ")); 
      writeline(output, txt_output);               
      write(txt_output, string'("\$\$\$ Exit status for testbench customer_demo_tb :  TESTBENCH_FAILED "));
      writeline(output, txt_output);
      write(txt_output, string'("*************************************************************************"));
      writeline(output, txt_output);
      report "Failures Found. Exiting." severity FAILURE;
   end if;
end process testbench;

--------------------------------------------------------------------------------------------------------------------------
------------- Instantiation of cpri_top_level, altgx_reconfig, altpll_reconfig ,altgx_c4gx_reconfig_cpri & rom_cyclone4gx
--------------------------------------------------------------------------------------------------------------------------
inst_altgx_c4gx_reconfig_cpri:altgx_c4gx_reconfig_cpri 
port map
   (
   reconfig_clk		    => reconfig_clk_wire,		
   reconfig_data		=> reconfig_data,
   reconfig_fromgxb		=> reconfig_fromgxb_m_wire,		
   reconfig_mode_sel	=> "001", -- channnel reconfiguration mode
   error                => error_wire,
   write_all		    => reconfig_write_wire,
   busy		            => reconfig_busy_wire,		
   channel_reconfig_done=> reconfig_done_wire,
   reconfig_address_en	=> reconfig_address_en,
   reconfig_address_out	=> reconfig_address_out,
   reconfig_togxb		=> reconfig_togxb_m_wire		
   );
 
inst_altpll_tx_c4gx_reconfig_cpri : altpll_c4gx_reconfig_cpri 
port map 
   (
   clock		        => clock_wire,		         
   counter_param		=> (others => '0'),		 
   counter_type		    => (others => '0'),		 
   data_in		        => (others => '0'),		     
   pll_areset_in		=> pll_areset_in_wire,		 
   pll_scandataout		=> pll_scandataout_wire(0),	
   pll_scandone		    => pll_reconfig_done_wire(0),		 
   read_param		    => '0', 
   reconfig		        => reconfig_tx_wire,		     
   reset		        => reset_wire,		         
   reset_rom_address	=> txpll_reset_rom_addr_wire,	
   rom_data_in		    => txpll_rom_data_in_wire,		 
   write_from_rom		=> txpll_write_from_rom_wire,	
   write_param		    => '0', 		 
   busy		            => altpll_busy_wire(0),		         
   data_out		        => open,
   pll_areset		    => pll_areset_wire(0),		 
   pll_configupdate	    => pll_configupdate_wire(0),	 
   pll_scanclk		    => pll_scanclk_wire(0),		 
   pll_scanclkena		=> pll_scanclkena_wire(0),	
   pll_scandata		    => pll_scandata_wire(0),		 
   rom_address_out		=> rom_tx_address_out_wire,	
   write_rom_ena		=> write_tx_rom_ena_wire		 
   );

inst_altpll_rx_c4gx_reconfig_cpri : altpll_c4gx_reconfig_cpri 
port map 
   (
   clock		        => clock_wire,		             
   counter_param		=> (others => '0'),		        
   counter_type		    => (others => '0'),		        
   data_in		        => (others => '0'),		        
   pll_areset_in		=> pll_areset_in_wire,		     
   pll_scandataout		=> pll_scandataout_wire(1),  
   pll_scandone		    => pll_reconfig_done_wire(1), 
   read_param		    => '0',
   reconfig		        => reconfig_rx_wire,	    
   reset		        => reset_wire,		             
   reset_rom_address	=> rxpll_reset_rom_addr_wire,
   rom_data_in		    => rxpll_rom_data_in_wire,	  
   write_from_rom		=> rxpll_write_from_rom_wire,
   write_param		    => '0',
   busy		            => altpll_busy_wire(1),		               
   data_out		        => open,
   pll_areset		    => pll_areset_wire(1),		     
   pll_configupdate	    => pll_configupdate_wire(1), 
   pll_scanclk		    => pll_scanclk_wire(1),	     
   pll_scanclkena		=> pll_scanclkena_wire(1),	  
   pll_scandata		    => pll_scandata_wire(1),	    
   rom_address_out		=> rom_rx_address_out_wire,	    
   write_rom_ena		=> write_rx_rom_ena_wire		      
   );

inst_rom_cyclone4gx_614_reconfig : rom_cyclone4gx 
generic map (
               init_file => "../../../../reconfig_mif/cyclone4gx_614_m.mif"
               )
port map
   (
   address	=> rom_614_reconfig_add, 
   clock	=> clock_wire ,     
   rden	    => write_614_reconfig_data,  
   q		=> rom_c4gx_614_reconfig_data 		  
   );

inst_rom_cyclone4gx_1228_reconfig : rom_cyclone4gx
generic map (
               init_file => "../../../../reconfig_mif/cyclone4gx_1228_m.mif"
               )
port map
   (
   address	=> rom_1228_reconfig_add, 
   clock	=> clock_wire ,     
   rden	    => write_1228_reconfig_data,  
   q		=> rom_c4gx_1228_reconfig_data 		  
   );

inst_rom_cyclone4gx_1228_m_tx : rom_cyclone4gx_pll
generic map (
               init_file => "../../../../reconfig_mif/cyclone4gx_1228_m_tx_pll0.mif"
               )
port map
   (
   address	=> rom_tx_address_out_wire, 
   clock	=> clock_wire,     
   rden	    => write_tx_rom_ena_wire,  
   q		=> rom_c4gx_1228_tx_data_wire		  
   );

inst_rom_cyclone4gx_1228_m_rx : rom_cyclone4gx_pll
generic map (
               init_file => "../../../../reconfig_mif/cyclone4gx_1228_m_rx_pll1.mif"
               )
port map
   (
   address	=> rom_rx_address_out_wire,
   clock	=> clock_wire,    
   rden	    => write_rx_rom_ena_wire, 
   q		=> rom_c4gx_1228_rx_data_wire		    
   );
  

inst_rom_cyclone4gx_614_m_tx : rom_cyclone4gx_pll
generic map (
               init_file => "../../../../reconfig_mif/cyclone4gx_614_m_tx_pll0.mif"
               )
port map
   (
   address   => rom_tx_address_out_wire, 
   clock     => clock_wire,     
   rden      => write_tx_rom_ena_wire,  
   q		 => rom_c4gx_614_tx_data_wire		   
   );

inst_rom_cyclone4gx_614_m_rx:rom_cyclone4gx_pll
generic map (
               init_file => "../../../../reconfig_mif/cyclone4gx_614_m_rx_pll1.mif"
               )
port map
   (
   address	=> rom_rx_address_out_wire, 
   clock	=> clock_wire,     
   rden	    => write_rx_rom_ena_wire,  
   q		=> rom_c4gx_614_rx_data_wire		   
   );

inst_cpri_top_level : cpri_top_level
port map (
   gxb_refclk              =>gxb_refclk_wire,               
   gxb_pll_inclk           =>gxb_refclk_wire,
   gxb_cal_blk_clk         =>gxb_cal_blk_clk_wire,          
   gxb_powerdown           =>gxb_powerdown_wire,            
   gxb_pll_locked          =>gxb_pll_locked_wire,           
   gxb_rx_pll_locked       =>gxb_rx_pll_locked_wire,        
   gxb_rx_freqlocked       =>gxb_rx_freqlocked_wire,        
   gxb_rx_errdetect        =>gxb_rx_errdetect_wire,         
   gxb_rx_disperr          =>gxb_rx_disperr_wire,           
   gxb_los                 =>gxb_los_wire,                  
   gxb_txdataout           =>cpri_rec_loopback_wire,            
   gxb_rxdatain            =>cpri_rec_loopback_wire,             
   reconfig_clk            =>reconfig_clk_wire,             
   reconfig_busy           =>reconfig_busy_wire,            
   reconfig_write          =>reconfig_write_wire,           
   reconfig_done           =>reconfig_done_wire,            
   reconfig_togxb_m        =>reconfig_togxb_m_wire,         
   reconfig_fromgxb_m      =>reconfig_fromgxb_m_wire,       
   pll_areset              =>pll_areset_wire,               
   pll_configupdate        =>pll_configupdate_wire,         
   pll_scanclk             =>pll_scanclk_wire,              
   pll_scanclkena          =>pll_scanclkena_wire,           
   pll_scandata            =>pll_scandata_wire,             
   pll_reconfig_done       =>pll_reconfig_done_wire,        
   pll_scandataout         =>pll_scandataout_wire,          
   cpri_clkout             =>cpri_clkout_wire,              
   pll_clkout              =>pll_clkout_wire,               
   reset                   =>reset_wire,                    
   reset_done              =>reset_done_wire,               
   config_reset            =>config_reset_wire,             
   clk_ex_delay            =>clk_ex_delay_wire,             
   reset_ex_delay          =>reset_ex_delay_wire,          
   hw_reset_assert         =>'0', 
   hw_reset_req            =>hw_reset_req_wire,             
   extended_rx_status_data =>extended_rx_status_data_wire,  
   datarate_en             =>datarate_en_wire,              
   datarate_set            =>datarate_set_wire,             
   cpu_clk                 =>cpri_clkout_wire,                  
   cpu_reset               =>cpu_reset_wire,                
   cpu_writedata           =>cpu_writedata_wire,
   cpu_byteenable          =>"1111",            
   cpu_read                =>cpu_read_wire,                 
   cpu_write               =>cpu_write_wire,                
   cpu_readdata            =>cpu_readdata_wire,             
   cpu_address             =>cpu_address_wire,              
   cpu_waitrequest         =>cpu_waitrequest_wire,          
   cpu_irq                 =>cpu_irq_wire,                  
   cpu_irq_vector          =>cpu_irq_vector_wire,           
   aux_rx_status_data      =>aux_rx_status_data_wire,       
   aux_tx_status_data      =>aux_tx_status_data_wire,       
   aux_tx_mask_data        =>aux_tx_mask_data_wire         
   );
end architecture behavioral;
