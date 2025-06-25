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


-------------------------------------------------------------------------------------------------------------------------------------------
--File name: tb_altera_cpri_autorate_phy.vhd
--Description: This is the customer demo testbench to test autorate negotiation feature for the CPRI MegaCore
--             based on the REC loopback configuration with starting linerate of 1Gbps to 614.4Mbps for SV and AV devices. (not for AV GT)
-------------------------------------------------------------------------------------------------------------------------------------------

library ieee;  
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use work.all;

entity tb is
end entity tb;

architecture behavioral of tb is 
   -- the value for the register is shift right 2 bits before send in to the core.
   constant REG_CPRI_CONFIG    	       : std_logic_vector(13 downto 0) := conv_std_logic_vector(16#02#,14);--actual value 0x08 
   constant REG_CPRI_MAP_CNT_CONFIG    : std_logic_vector(13 downto 0) := conv_std_logic_vector(16#41#,14);--actual value 0x104
   constant REG_CPRI_MAP_CONFIG        : std_logic_vector(13 downto 0) := conv_std_logic_vector(16#40#,14);--actual value 0x100
   constant REG_CPRI_RATE_CONFIG       : std_logic_vector(13 downto 0) := conv_std_logic_vector(16#12#,14); --actual value 0x48  

   -- Signal declaration
   signal reset_wire                   : std_logic                      := '0';
   signal clk_ex_delay_wire            : std_logic                      := '0';            
   signal reset_ex_delay_wire          : std_logic                      := '0';            
   signal cpu_clk_wire                 : std_logic                      := '0';            
   signal cpu_reset_wire               : std_logic                      := '0';            
   signal cpu_writedata_wire           : std_logic_vector(31 downto 0)  := (others => '0');
   signal cpu_read_wire                : std_logic                      := '0';            
   signal cpu_write_wire               : std_logic                      := '0';            
   signal cpu_readdata_wire            : std_logic_vector(31 downto 0);                    
   signal cpu_address_wire             : std_logic_vector(13 downto 0)  := (others => '0');
   signal cpu_waitrequest_wire         : std_logic;                                        
   signal extended_rx_status_data_wire : std_logic_vector(11 downto 0);                    
   signal cpri_clkout_wire             : std_logic;                                        
   signal cpu_irq_wire                 : std_logic;                                        
   signal cpu_irq_vector_wire          : std_logic_vector(4 downto 0);                     
   signal aux_rx_status_data_wire      : std_logic_vector(75 downto 0);                    
   signal aux_tx_status_data_wire      : std_logic_vector(43 downto 0);                    
   signal aux_tx_mask_data_wire        : std_logic_vector(64 downto 0)  := (others => '0');
   signal gxb_refclk_wire              : std_logic                      := '0';            
   signal gxb_pll_inclk_wire           : std_logic                      := '0';            
   signal gxb_pll_locked_wire          : std_logic;                                        
   signal gxb_rx_pll_locked_wire       : std_logic;                                        
   signal gxb_rx_freqlocked_wire       : std_logic;                                        
   signal gxb_rx_errdetect_wire        : std_logic_vector(3 downto 0);                     
   signal gxb_rx_disperr_wire          : std_logic_vector(3 downto 0);                     
   signal gxb_los_wire                 : std_logic                      := '0';            
   signal gxb_wire                     : std_logic;
   signal reconfig_clk_wire            : std_logic                      := '0';            
   signal pll_clkout_wire              : std_logic;                                                    
   signal reset_done_wire              : std_logic;                                        
   signal config_reset_wire            : std_logic                      := '0';            
   signal hw_reset_assert_wire         : std_logic                      := '0';            
   signal hw_reset_req_wire            : std_logic;                                        
   signal datarate_en_wire             : std_logic;                                        
   signal datarate_set_wire            : std_logic_vector(4 downto 0);                     
   signal reconfig_busy_wire           : std_logic;                                               
   signal reconfig_to_xcvr_wire        : std_logic_vector(139 downto 0);                   
   signal reconfig_from_xcvr_wire      : std_logic_vector(91 downto 0)  := (others => '0'); 
   signal op_cnt                       : std_logic_vector(3 downto 0)   := (others => '0');
   signal cpu_running                  : std_logic := '0';
   signal start_configure              : std_logic := '0';
   signal cpri_rx_sync_state           : std_logic := '0';
   signal cpri_rx_sync                 : std_logic := '0'; 
   signal cpu_done_compare             : std_logic := '0';
   signal clk_15_36                    : std_logic := '0';
   signal clk_30_72                    : std_logic := '0';
   signal main_reset                   : std_logic;
   signal reset_phy_wire               : std_logic;
   signal start_reconfig_wire          : std_logic_vector(1 downto 0):= "00";
   signal done_reconfig                : std_logic;
   signal start_auto                   : std_logic;
   signal cnt_auto                     : std_logic_vector(1 downto 0);
   signal clk_compare				        : std_logic := '0';
   signal reset_freq_check_wire	     : std_logic := '0';
   signal start_freq_checking          : std_logic := '0';
   signal freq_alarm_hold	           : std_logic := '0';
   signal freq_alarm_wire	   		  : std_logic := '0';
   signal alarm_detected_edge		     : std_logic := '0'; 
   signal clk_check_configure		     : std_logic_vector(3 downto 0) := (others => '0');
   signal completed_configure	        : std_logic:= '0';
   signal completed_configure_hold	  : std_logic:= '0';
   signal alarm_detected	              : std_logic:= '0';
   signal start_configure_hold	        : std_logic:= '0';
   signal freq_check_cnt               : std_logic_vector (1 downto 0);
   signal config_mode                  : std_logic_vector(1 downto 0);   

   subtype gray_cnt_type is std_logic_vector(3 downto 0);
   signal check_seq    : std_logic_vector(1 downto 0);
   signal resync       : std_logic;
   signal cnt          : gray_cnt_type;
   signal cnt_check    : gray_cnt_type;
   signal cnt_check_s0 : gray_cnt_type;
   signal cnt_check_s1 : gray_cnt_type; 
   signal diff         : gray_cnt_type;
  
   -- Function declaration   
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

   -- Component declaration
   component cpri_reconfig_controller is
      port (
         clk                       : in  std_logic;
         reset                     : in  std_logic;
         start_reconfig            : in  std_logic_vector(1 downto 0);
         reconfig_from_xcvr        : in  std_logic_vector(91 downto 0)  := (others => '0');
         reset_done                : in  std_logic;
         done_reconfig             : out std_logic;
         config_mode               : out std_logic_vector(1 downto 0);
         reconfig_busy             : out std_logic;
         reconfig_to_xcvr          : out std_logic_vector(139 downto 0);
         reset_phy                 : out std_logic
      );
   end component cpri_reconfig_controller;

   component cpri_top_level is
      port (
     	   clk_ex_delay            : in  std_logic                      := '0';  
		   reset_ex_delay          : in  std_logic                      := '0';             
         cpu_clk                 : in  std_logic                      := '0';       
		   cpu_reset               : in  std_logic                      := '0';             
		   cpu_writedata           : in  std_logic_vector(31 downto 0)  := (others => '0');
		   cpu_byteenable          : in  std_logic_vector(3 downto 0)   := (others => '0');
		   cpu_read                : in  std_logic                      := '0';           
		   cpu_write               : in  std_logic                      := '0';             
		   cpu_readdata            : out std_logic_vector(31 downto 0);                     
		   cpu_address             : in  std_logic_vector(13 downto 0)  := (others => '0'); 
		   cpu_waitrequest         : out std_logic;                                         
		   extended_rx_status_data : out std_logic_vector(11 downto 0);                     
		   cpri_clkout             : out std_logic;                                         
		   cpu_irq                 : out std_logic;                                         
		   cpu_irq_vector          : out std_logic_vector(4 downto 0);                      
		   aux_rx_status_data      : out std_logic_vector(75 downto 0);                     
		   aux_tx_status_data      : out std_logic_vector(43 downto 0);                     
		   aux_tx_mask_data        : in  std_logic_vector(64 downto 0)  := (others => '0'); 
		   gxb_refclk              : in  std_logic                      := '0';           
		   gxb_pll_inclk           : in  std_logic                      := '0';             
		   gxb_pll_locked          : out std_logic;                                         
		   gxb_rx_pll_locked       : out std_logic;                                         
		   gxb_rx_freqlocked       : out std_logic;                                         
		   gxb_rx_errdetect        : out std_logic_vector(3 downto 0);                      
		   gxb_rx_disperr          : out std_logic_vector(3 downto 0);                      
		   gxb_los                 : in  std_logic                      := '0';       
		   gxb_txdataout           : out std_logic;                                         
		   gxb_rxdatain            : in  std_logic                      := '0';             
		   reconfig_clk            : in  std_logic                      := '0';             
		   pll_clkout              : out std_logic;                                         
		   reset                   : in  std_logic                      := '0';             
		   reset_done              : out std_logic;                                         
		   config_reset            : in  std_logic                      := '0';             
		   hw_reset_assert         : in  std_logic                      := '0';             
		   hw_reset_req            : out std_logic;                                         
		   datarate_en             : out std_logic;                                         
		   datarate_set            : out std_logic_vector(4 downto 0);                      
		   reconfig_from_xcvr      : out std_logic_vector(91 downto 0);                     
		   reconfig_to_xcvr        : in  std_logic_vector(139 downto 0) := (others => '0')
      );
   end component cpri_top_level;

begin
   -- Reset
   reset_wire           <= '1' , '0' after 500 ns;
   reset_ex_delay_wire  <= '1' , '0' after 500 ns;
   cpu_reset_wire       <= '1' , '0' after 500 ns;
   config_reset_wire    <= '1' , '0' after 500 ns;
   -- Clocking
   reconfig_clk_wire <= not reconfig_clk_wire after 5 ns ;     -- 100MHz
   clk_ex_delay_wire <= not clk_ex_delay_wire after 16.485 ns; -- 30.96 MHz
   gxb_refclk_wire   <= not gxb_refclk_wire   after 8.138 ns;  -- 61.44Mhz
   clk_15_36         <= not clk_15_36  after 32552 ps;      -- 15.36Mhz   
   clk_30_72         <= not clk_30_72  after 16276 ps;      -- 30.72Mhz   
    
   clk_compare <= clk_15_36 ; 
                
   main_reset <= (reset_wire or reset_phy_wire);
   -- Sequential logic
   cpu_read_write : process(cpri_clkout_wire, cpu_reset_wire) is
   variable cpu_op: std_logic;
   begin
      if (cpu_reset_wire = '1') then
         cpu_write_wire <= '0';
         cpu_read_wire <= '0';
         op_cnt <= "0000";
         cpu_op := '0';
         cpu_address_wire <= conv_std_logic_vector(16#00#,14);
         cpu_writedata_wire <= conv_std_logic_vector(16#00#,32);
         start_auto <= '0';
      elsif (cpri_clkout_wire'event and cpri_clkout_wire ='1') then
         --start configure cpu register after reach BFN sync
         if ((cpri_rx_sync_state = '0') and (extended_rx_status_data_wire(6) = '1')) then
		 	   start_configure  <= '1'; 
         end if;	

         if (reset_done_wire = '1') then
            if (cpu_waitrequest_wire = '0' and cpu_op = '0' ) then
               -- Write to cpri_config register by setting tx_ctrl_insert_en, master mode, no loop, tx_enable.
               if (op_cnt = "0000") then
                 cpu_address_wire   <= REG_CPRI_CONFIG;
                 cpu_writedata_wire <= conv_std_logic_vector(16#0021#,32);
                 cpu_write_wire     <= '1';
                 cpu_read_wire      <= '0';
                 op_cnt             <= op_cnt + "0001";
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
               if (op_cnt = "0010") and start_configure = '1' then
                  cpu_address_wire   <= REG_CPRI_RATE_CONFIG;							
                  cpu_writedata_wire <= conv_std_logic_vector(16#1#,32);
                  cpu_write_wire     <= '1';
                  cpu_read_wire      <= '0';
                  op_cnt             <= op_cnt + '1';
                  cpu_op             := '1';
                  start_configure <= '0';
               end if;
               
               -- Read back cpri_config register to ensure the data has been correctly written.
               if (op_cnt = "0011") then
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
  		 	 		      if cpu_readdata_wire = conv_std_logic_vector(16#21#,32) then
                        report "CPU:write 614.4M at cpri_rate_config done and auto-negotiation from 1228.8Mbps to 614.4Mbps is ready to begin." severity NOTE;	
                        op_cnt <= op_cnt + '1';
                        cpu_done_compare <= '1';
                        start_auto <= '1';
  		 	 	         end if;		 				 		
  		 	         end if;        
               end if;
            end if; 

         end if;  
      end if;
  end process cpu_read_write;

   -------------------------------------------------------------------------------------------------------------------
   -- Check on the CPRI link for synchronization (cpri_rx_bfn_state is bit 6 of extended_rx_status_data)
   -------------------------------------------------------------------------------------------------------------------
   cpri_link_check : process (reset_wire, cpri_clkout_wire)
   begin
      if (reset_wire = '1') then 		
         cpri_rx_sync_state <= '0';   
         freq_check_cnt <= (others=>'0');
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
   end process cpri_link_check;

   -- -------------------------------------------------
   -- config_mode = "00" - channel reconfiguration
   -- config_mode = "01" - pll reconfiguration
   -- * -------------------------------------------------
   start_reconfig_controller : process(reconfig_clk_wire, reset_wire) is
   begin
      if (reset_wire = '1') then
         start_reconfig_wire <= "00";
         cnt_auto <= "00";
      elsif (reconfig_clk_wire'event and reconfig_clk_wire ='1') then
         if (start_auto = '1') then
            if (config_mode = "00" and cnt_auto = "00") then
               start_reconfig_wire <= "01";
               cnt_auto <= cnt_auto + "01";
            elsif (done_reconfig = '1' and cnt_auto = "01") then
               start_reconfig_wire <= "00";
               cnt_auto <= cnt_auto + "01";
            elsif (config_mode= "01" and cnt_auto= "10") then
               start_reconfig_wire <= "01";
               cnt_auto <= cnt_auto + "01";
            else
               start_reconfig_wire <= "00";
               cnt_auto <= "00";
               completed_configure <= '1';
            end if;
         end if;
      end if;
   end process start_reconfig_controller ;

   ------------------------------------------------------------------------------------------
   -- checking on cpri_clkout for rate changes
   ------------------------------------------------------------------------------------------
   process(reconfig_clk_wire)
   variable duration_cnt : integer := 0;
	variable freq_alarm_cnt : integer := 0;
      begin	
	      start_configure_hold <= start_configure ; 
    
         if (start_configure_hold = '0') and (start_configure = '1')  and (completed_configure = '0') then
            reset_freq_check_wire <= '1';					                  --trigger reset_freq_check to start the checking
		      start_freq_checking <= '1';	
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
            
            if duration_cnt = 50 then                                     --perform checking on freq_alarm every 50 clock cycle
               if freq_alarm_cnt > 0  then                                --if alarm detected, the linerate not match yet
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

---------------------------------------------------------
-- Report error message at the end of simulation 
---------------------------------------------------------
   testbench_report : process is
      variable txt_output : LINE;
   begin
      wait for 3 ms;
      
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
   end process testbench_report;

   cpri_reconfig_controller_inst : cpri_reconfig_controller
   port map (
               clk                => reconfig_clk_wire,
               reset              => reset_wire,
               start_reconfig     => start_reconfig_wire,
               reconfig_from_xcvr => reconfig_from_xcvr_wire,
               reset_done         => reset_done_wire,
               done_reconfig      => done_reconfig,
               config_mode        => config_mode,
               reconfig_busy      => reconfig_busy_wire,
               reconfig_to_xcvr   => reconfig_to_xcvr_wire,
               reset_phy          => reset_phy_wire
            );

   cpri_top_level_inst : cpri_top_level
   port map (
               clk_ex_delay             => clk_ex_delay_wire,
               reset_ex_delay           => reset_ex_delay_wire,
               cpu_clk                  => cpri_clkout_wire,
               cpu_reset                => cpu_reset_wire,
               cpu_writedata            => cpu_writedata_wire,
               cpu_byteenable           => "1111",
               cpu_read                 => cpu_read_wire,
               cpu_write                => cpu_write_wire,
               cpu_readdata             => cpu_readdata_wire,
               cpu_address              => cpu_address_wire,
               cpu_waitrequest          => cpu_waitrequest_wire,
               extended_rx_status_data  => extended_rx_status_data_wire,
               cpri_clkout              => cpri_clkout_wire,
               cpu_irq                  => cpu_irq_wire,
               cpu_irq_vector           => cpu_irq_vector_wire,
               aux_rx_status_data       => aux_rx_status_data_wire,
               aux_tx_status_data       => aux_tx_status_data_wire,
               aux_tx_mask_data         => aux_tx_mask_data_wire,
               gxb_refclk               => gxb_refclk_wire,
               gxb_pll_inclk            => gxb_refclk_wire,
               gxb_pll_locked           => gxb_pll_locked_wire,
               gxb_rx_pll_locked        => gxb_rx_pll_locked_wire,
               gxb_rx_freqlocked        => gxb_rx_freqlocked_wire,
               gxb_rx_errdetect         => gxb_rx_errdetect_wire,
               gxb_rx_disperr           => gxb_rx_disperr_wire,
               gxb_los                  => '0',
               gxb_txdataout            => gxb_wire,
               gxb_rxdatain             => gxb_wire,
               reconfig_clk             => reconfig_clk_wire,
               pll_clkout               => pll_clkout_wire,
               reset                    => main_reset,
               reset_done               => reset_done_wire,
               config_reset             => config_reset_wire,
               hw_reset_assert          => '0',
               hw_reset_req             => hw_reset_req_wire,
               datarate_en              => datarate_en_wire,
               datarate_set             => datarate_set_wire,
               reconfig_from_xcvr       => reconfig_from_xcvr_wire,
               reconfig_to_xcvr         => reconfig_to_xcvr_wire
            );
end behavioral;
