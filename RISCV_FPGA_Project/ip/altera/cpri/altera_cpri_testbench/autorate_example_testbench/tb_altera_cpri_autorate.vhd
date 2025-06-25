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
--File name: tb_altera_cpri_autorate.vhd
--Description: This is the customer demo testbench to test autorate negotiation feature for the CPRI MegaCore
--             based on the REC loopback configuration with starting linerate of 614.4Mbps to 1Gbps and back to 614.4Mbps.
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
    -- the value for the register is shift right 2 bits before send in to the core.
    constant REG_CPRI_CONFIG    	    : std_logic_vector(13 downto 0) := conv_std_logic_vector(16#02#,14);--actual value 0x08 
    constant REG_CPRI_MAP_CNT_CONFIG    : std_logic_vector(13 downto 0) := conv_std_logic_vector(16#41#,14);--actual value 0x104
    constant REG_CPRI_MAP_CONFIG        : std_logic_vector(13 downto 0) := conv_std_logic_vector(16#40#,14);--actual value 0x100
    constant REG_CPRI_RATE_CONFIG       : std_logic_vector(13 downto 0) := conv_std_logic_vector(16#12#,14); --actual value 0x48  
    -- Signal declaration
    signal aux_rx_status_data_wire     : std_logic_vector (75 downto 0);
    signal aux_tx_mask_data_wire       : std_logic_vector (64 downto 0):=(others=>'0');
    signal aux_tx_status_data_wire     : std_logic_vector (43 downto 0);
    signal config_reset_wire           : std_logic:='0';
    signal cpri_clkout_wire            : std_logic;
    signal cpu_address_wire            : std_logic_vector (13 downto 0):=(others=>'0');
    signal cpu_irq_wire	               : std_logic;
    signal cpu_irq_vector_wire         : std_logic_vector (4 downto 0);
    signal cpu_read_wire               : std_logic;
    signal cpu_readdata_wire           : std_logic_vector (31 downto 0);
    signal cpu_reset_wire	             : std_logic:= '0';
    signal cpu_waitrequest_wire        : std_logic;
    signal cpu_write_wire	             : std_logic;
    signal cpu_writedata_wire	         : std_logic_vector (31 downto 0):=(others=>'0');
    signal extended_rx_status_data_wire: std_logic_vector (11 downto 0);
    signal gxb_pll_locked_wire         : std_logic;
    signal gxb_refclk_wire             : std_logic:= '0';
    signal gxb_rx_disperr_wire	       : std_logic_vector (3 downto 0);
    signal gxb_rx_errdetect_wire       : std_logic_vector (3 downto 0);
    signal gxb_rx_freqlocked_wire  	   : std_logic;
    signal gxb_rx_pll_locked_wire      : std_logic;
    signal cpri_rec_loopback_wire      : std_logic;
    signal hw_reset_req_wire           : std_logic;
    signal pll_clkout_wire             : std_logic;
    signal reconfig_fromgxb_wire       : std_logic_vector (16 downto 0);
    signal reconfig_togxb_wire         : std_logic_vector (3 downto 0):=(others=>'0');    
    signal reset_wire                  : std_logic:= '0';                                 
    signal reset_ex_delay_wire         : std_logic:= '0'; 
    signal reset_done_wire             : std_logic:= '0';                        
    signal op_cnt                      : std_logic_vector (3 downto 0);
    signal cpu_running                 : std_logic:= '0';
    signal clk_ex_delay_wire           : std_logic:= '0';
    signal cpri_rx_aux_data            : std_logic_vector (31 downto 0):=(others=>'0');
    signal cpri_tx_seq                 : std_logic_vector (43 downto 37):=(others=>'0');
    signal cpri_rx_seq                 : std_logic_vector (38 downto 33):=(others=>'0');
    signal cpri_rx_sync_state          : std_logic:= '0';
    signal cpri_rx_sync                : std_logic:= '0'; 
    signal cpu_done_compare            : std_logic:= '0';
    signal reset                       : std_logic ;
    signal gxb_cal_blk_clk_wire        : std_logic := '0';
    signal reconfig_clk_wire           : std_logic := '0';
    signal reconfig_data_wire    	   : std_logic_vector(15 downto 0):=(others=>'0'); 
    signal rom_stratix4gx_1g_data	   : std_logic_vector(15 downto 0):=(others=>'0'); 
    signal rom_stratix4gx_614m_data	   : std_logic_vector(15 downto 0):=(others=>'0'); 
    signal reconfig_write_all_wire	   : std_logic:='0'; 
    signal reconfig_done_wire          : std_logic; 
    signal reconfig_busy_wire 	 	   : std_logic;
    signal reconfig_addr_en_wire       : std_logic;
    signal reconfig_addr_out_wire	   : std_logic_vector(5 downto 0);
    signal rom_addr				   	   : std_logic_vector(5 downto 0);
    signal start_configure  		   : std_logic:= '0';
    signal busy_cnt				       : std_logic_vector(1 downto 0):= "00";
    signal done_configure  	           : std_logic:= '1';
    signal cpri_rx_sync_state2	       : std_logic:= '0';
    signal clk_15_36				   : std_logic:= '0';
    signal clk_30_72				   : std_logic:= '0';
    signal reset_freq_check_wire	   : std_logic:= '0';
    signal freq_alarm_wire	   		   : std_logic:= '0';
    signal start_configure_hold	       : std_logic:= '0';
    signal freq_alarm_hold	           : std_logic:= '0';
    signal alarm_detected	           : std_logic:= '0';
    signal start_freq_checking	       : std_logic:= '0'; 
    signal completed_configure	       : std_logic:= '0';
    signal num_configure		       : std_logic_vector(3 downto 0):=(others=>'0');
    signal clk_check_configure		   : std_logic_vector(3 downto 0):=(others=>'0');
    signal clk_compare				   : std_logic:= '0';
    signal alarm_detected_edge		   : std_logic:= '0'; 
    
    subtype gray_cnt_type is std_logic_vector(3 downto 0);
    signal check_seq : std_logic_vector(1 downto 0);
    signal cnt : gray_cnt_type;
    signal cnt_check : gray_cnt_type;
    signal cnt_check_s0 : gray_cnt_type;
    signal cnt_check_s1 : gray_cnt_type; 
    signal diff : gray_cnt_type;
    signal resync : std_logic;
    
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
         
    component rom_stratix4gx is
    generic (
              init_file : in string := "stratix4gx_1228_m.mif"
           );
	 port (
		address		: in std_logic_vector(5 downto 0);
		clken		: in std_logic;
		clock		: in std_logic;
		q 		: out std_logic_vector(15 downto 0)
	     );
    end component; 
        
    component altgx_reconfig_cpri is
		port (
		reconfig_clk		: in std_logic;
		reconfig_data		: in std_logic_vector (15 downto 0);
		reconfig_fromgxb	: in std_logic_vector (16 downto 0);
		reconfig_mode_sel	: in std_logic_vector (2 downto 0);
		write_all		: in std_logic;
		busy			: out std_logic;
		channel_reconfig_done	: out std_logic;
		reconfig_address_en	: out std_logic;
		reconfig_address_out	: out std_logic_vector (5 downto 0);
		reconfig_togxb		: out std_logic_vector (3 downto 0)
	  	);
	end component; 	
  
    component cpri_top_level 
        port (
		gxb_refclk              : in  std_logic                     := '0';             --              gxb_refclk.export
		gxb_pll_inclk           : in  std_logic                     := '0';             --           gxb_pll_inclk.export
		gxb_cal_blk_clk         : in  std_logic                     := '0';             --         gxb_cal_blk_clk.export
		gxb_powerdown           : in  std_logic                     := '0';             --           gxb_powerdown.export
		gxb_pll_locked          : out std_logic;                                        --          gxb_pll_locked.export
		gxb_rx_pll_locked       : out std_logic;                                        --       gxb_rx_pll_locked.export
		gxb_rx_freqlocked       : out std_logic;                                        --       gxb_rx_freqlocked.export
		gxb_rx_errdetect        : out std_logic_vector(3 downto 0);                     --        gxb_rx_errdetect.export
		gxb_rx_disperr          : out std_logic_vector(3 downto 0);                     --          gxb_rx_disperr.export
		gxb_los                 : in  std_logic                     := '0';             --                 gxb_los.export
		gxb_txdataout           : out std_logic;                                        --           gxb_txdataout.export
		gxb_rxdatain            : in  std_logic                     := '0';             --            gxb_rxdatain.export
		reconfig_clk            : in  std_logic                     := '0';             --            reconfig_clk.export
		reconfig_busy           : in  std_logic                     := '0';             --           reconfig_busy.export
		reconfig_write          : in  std_logic                     := '0';             --          reconfig_write.export
		reconfig_done           : in  std_logic                     := '0';             --           reconfig_done.export
		reconfig_togxb_m        : in  std_logic_vector(3 downto 0)  := (others => '0'); --        reconfig_togxb_m.export
		reconfig_fromgxb_m      : out std_logic_vector(16 downto 0);                    --      reconfig_fromgxb_m.export
		cpri_clkout             : out std_logic;                                        --             cpri_clkout.export
		pll_clkout              : out std_logic;                                        --              pll_clkout.export
		reset                   : in  std_logic                     := '0';             --                   reset.export
		reset_done              : out std_logic;                                        --              reset_done.export
		config_reset            : in  std_logic                     := '0';             --            config_reset.export
		clk_ex_delay            : in  std_logic                     := '0';             --      clk_reset_ex_delay.clk
		reset_ex_delay          : in  std_logic                     := '0';             --                        .reset
		hw_reset_assert         : in  std_logic;                                        --            hw_reset_req.export
		hw_reset_req            : out std_logic;                                        --            hw_reset_req.export
		extended_rx_status_data : out std_logic_vector(11 downto 0);                    -- rx_extended_status_data.data
		cpu_reset               : in  std_logic                     := '0';             --         cpu_clock_reset.reset
		cpu_clk                 : in  std_logic                     := '0';             --                        .clk
		cpu_writedata           : in  std_logic_vector(31 downto 0) := (others => '0'); --           cpu_interface.writedata
		cpu_read                : in  std_logic                     := '0';             --                        .read
		cpu_write               : in  std_logic                     := '0';             --                        .write
		cpu_byteenable          : in  std_logic_vector(3 downto 0);                     --                        .byteenable
		cpu_readdata            : out std_logic_vector(31 downto 0);                    --                        .readdata
		cpu_address             : in  std_logic_vector(13 downto 0) := (others => '0'); --                        .address
		cpu_waitrequest         : out std_logic;                                        --                        .waitrequest
		cpu_irq                 : out std_logic;                                        --           cpu_interrupt.irq
		cpu_irq_vector          : out std_logic_vector(4 downto 0);                     --          cpu_irq_vector.data
		aux_rx_status_data      : out std_logic_vector(75 downto 0);                    --           rx_aux_status.data
		aux_tx_status_data      : out std_logic_vector(43 downto 0);                    --               tx_status.data
		aux_tx_mask_data        : in  std_logic_vector(64 downto 0) := (others => '0') --                  tx_aux.data
	    );
    end component cpri_top_level;

begin
    -- Supplied resets.
    reset_wire <= '1', '0' after 500 ns;        -- main reset does not reset configuration registers
    cpu_reset_wire <= '1', '0' after 500 ns;    -- reset cpu 
    config_reset_wire <= '1', '0' after 500 ns; -- reset configuration registers
    reset <= '1', '0' after 500 ns;             -- reset mapping interface
   
    -- Supplied clocks.
    gxb_refclk_wire <= not gxb_refclk_wire after 8.138 ns; -- 61.44MHz gxb_refclk
    clk_ex_delay_wire <= not clk_ex_delay_wire after 16.1485 ns; -- 30.96MHz
    reconfig_clk_wire <= not reconfig_clk_wire after 10 ns; --50MHz 
    gxb_cal_blk_clk_wire <= not gxb_cal_blk_clk_wire after 10 ns; --50MHz

    -- The following signals are pulled out for easy reading.
    cpri_rx_aux_data <= aux_rx_status_data_wire(31 downto 0);
    cpri_tx_seq <= aux_tx_status_data_wire(43 downto 37);
    cpri_rx_seq <= aux_rx_status_data_wire(38 downto 33);
    
    clk_15_36  <= not clk_15_36  after 32552 ps;      -- 15.36Mhz   
    clk_30_72  <= not clk_30_72  after 16276 ps;      -- 30.72Mhz   
    

    with clk_check_configure select
    clk_compare <= clk_30_72   when "0001", 
 				   clk_15_36   when "0010",   		   
               	   clk_15_36   when others;     
           
    -------------------------------------------------------------------------------------------------------------------
    -- Getting Started
    -- Configure the registers to allow transaction process to take place via the CPU interface.
    -------------------------------------------------------------------------------------------------------------------
    process (cpri_clkout_wire, cpu_reset_wire)
        variable cpu_op: std_logic;
    begin  		
        if (cpu_reset_wire = '1') then
            cpu_write_wire     <= '0';
            cpu_read_wire      <= '0';
           	op_cnt             <= "0000";
           	cpu_op             := '0';
           	cpu_address_wire   <= conv_std_logic_vector(16#00#,14);
           	cpu_writedata_wire <= conv_std_logic_vector(16#00#,32);
           	start_configure    <= '0';
        elsif (cpri_clkout_wire'event and cpri_clkout_wire = '1') then
       		if ((cpri_rx_sync_state = '0') and (extended_rx_status_data_wire(6) = '1')) then
		 		 start_configure  <= '1'; --start configure cpu register after reach BFN sync
	        end if;	
 			        
            if (reset_done_wire = '1') then 	  	
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
                    -- Write register auto_rate_config  i_datarate_en[4],i_datarate_set[4:0],  00010:1228.8Mbps(2),00100:2457.6Mbps(4), 			
  					if (op_cnt = "0010") and start_configure = '1' then					   -- 00101:3072.0Mbps(5),01000:4915.0Mbps(8),		
                        cpu_address_wire   <= REG_CPRI_RATE_CONFIG;							-- 01010:6144.0Mbps(A),00001:614Mbps(1)
                        cpu_writedata_wire <= conv_std_logic_vector(16#2#,32);
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
                    -- Write register auto_rate_config  i_datarate_en[4],i_datarate_set[4:0],  00010:1228.8Mbps(2),00100:2457.6Mbps(4), 			
  					if (op_cnt = "0100") and start_configure = '1' then					   -- 00101:3072.0Mbps(5),01000:4915.0Mbps(8),		
                        cpu_address_wire   <= REG_CPRI_RATE_CONFIG;							-- 01010:6144.0Mbps(A),00001:614Mbps(1)
                        cpu_writedata_wire <= conv_std_logic_vector(16#1#,32);
                        cpu_write_wire     <= '1';
                        cpu_read_wire      <= '0';
                        op_cnt             <= op_cnt + '1';
                        cpu_op             := '1';
                        start_configure <= '0';
                    end if;
                    -- Read back cpri_config register to ensure the data has been correctly written.
                    if (op_cnt = "0101") then
                        cpu_address_wire <= REG_CPRI_RATE_CONFIG;
                        cpu_write_wire   <= '0';
                        cpu_read_wire    <= '1';
                        cpu_op           := '1';
                    end if;
               end if;

               if (cpu_op = '1') then	-- Read waitrequest signal, perform avalon-mm transactions.
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
  		 	 	  		       report "CPU:write 614.4M at cpri_rate_config done" severity NOTE;	
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
	process(reconfig_clk_wire, cpu_reset_wire)
	begin
		if cpu_reset_wire = '1' then
			rom_addr <= (others => '0');
			reconfig_data_wire <= (others => '0');
			reconfig_write_all_wire <= '0';
			busy_cnt <= (others => '0');
			done_configure <= '1';
			cpri_rx_sync_state2 <= '0';  
			num_configure <= (others => '0');
		elsif reconfig_clk_wire'event and reconfig_clk_wire = '1' then
			cpri_rx_sync_state2 <= extended_rx_status_data_wire(6);
			
			if num_configure = "0000" then
			   reconfig_data_wire <= rom_stratix4gx_1g_data;
		    elsif num_configure = "0001" then
			   reconfig_data_wire <= rom_stratix4gx_614m_data; 
			else
			   reconfig_data_wire <= (others => '0');
		    end if;
		   	
		   	if ((cpri_rx_sync_state2 = '0') and (extended_rx_status_data_wire(6) = '1') and (completed_configure = '0')) then
		   		done_configure <='0';                                             --start configure gxb_reconfig
		   		report "Start to reconfigure gxb_reconfig_block " severity NOTE;	
		   	end if;	
		   	
		   	if reconfig_busy_wire = '0' and done_configure = '0' then
		   		busy_cnt <= busy_cnt + "1";
		   	end if;
		   	
		   	if busy_cnt = "11"  and done_configure = '0' then
		   		rom_addr <= rom_addr + "1";
		   		reconfig_write_all_wire <= '1';
		   	else
		   		reconfig_write_all_wire <= '0';
		   	end if;
		   	
		   	if rom_addr = conv_std_logic_vector(55,16) then 
		   		rom_addr <= (others => '0');
		   		busy_cnt <= (others => '0');
		   		done_configure <= '1';
		   		num_configure <= num_configure + '1';  
		   	end if;
	 		
		   	if num_configure = "0010" and alarm_detected = '0' then 
		   	   completed_configure <= '1';	
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
  	    
-----------------------------------------------------------------------------------------------------------------------
------------------------------------ Report error message at the end of simulation ------------------------------------
-----------------------------------------------------------------------------------------------------------------------
testbench : process is
    variable txt_output : LINE;
begin
    wait for 3.5 ms;

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

-----------------------------------------------------------------------------------------------------------------------
------------- Instantiation of cpri_top_level, altgx_reconfig_cpri and rom_stratix4gx_1228_m --------------------------
-----------------------------------------------------------------------------------------------------------------------
   gen_altgx_reconfig_cpri : altgx_reconfig_cpri
   port map (
      reconfig_clk            => reconfig_clk_wire,
      reconfig_data           => reconfig_data_wire,
      reconfig_fromgxb        => reconfig_fromgxb_wire,
      reconfig_mode_sel       => "101",
      write_all               => reconfig_write_all_wire,
      busy                    => reconfig_busy_wire,
      channel_reconfig_done   => reconfig_done_wire,
      reconfig_address_en     => reconfig_addr_en_wire,
      reconfig_address_out    => reconfig_addr_out_wire,
      reconfig_togxb          => reconfig_togxb_wire
   );

   gen_rom_stratix4gx_1228_m : rom_stratix4gx
   generic map (
               init_file => "../../../../reconfig_mif/stratix4gx_1228_m.mif"
               )
   port map (
      address => rom_addr,
      clken   => reconfig_addr_en_wire,
      clock   => reconfig_clk_wire,
      q       => rom_stratix4gx_1g_data 
   );
   
   gen_rom_stratix4gx_614_m : rom_stratix4gx
   generic map (
               init_file => "../../../../reconfig_mif/stratix4gx_614_m.mif"
               )
   port map (
      address => rom_addr,
      clken   => reconfig_addr_en_wire,
      clock   => reconfig_clk_wire,
      q       => rom_stratix4gx_614m_data 
   );
   
   altera_cpri_inst: cpri_top_level 
   port map(                          
        aux_rx_status_data	      => aux_rx_status_data_wire,
        aux_tx_mask_data	      => aux_tx_mask_data_wire,
        aux_tx_status_data	      => aux_tx_status_data_wire,
        clk_ex_delay	          => clk_ex_delay_wire,   
        config_reset	          => config_reset_wire, 
        cpri_clkout	              => cpri_clkout_wire, 
        cpu_address	              => cpu_address_wire,
        cpu_clk		              => cpri_clkout_wire,
        cpu_irq		              => cpu_irq_wire,
        cpu_irq_vector	          => cpu_irq_vector_wire,
        cpu_read		          => cpu_read_wire,
        cpu_readdata	          => cpu_readdata_wire,
        cpu_reset		          => cpu_reset_wire,
        cpu_waitrequest           => cpu_waitrequest_wire,
        cpu_write		          => cpu_write_wire,
        cpu_byteenable            => "1111",
        cpu_writedata	          => cpu_writedata_wire,
        extended_rx_status_data   => extended_rx_status_data_wire,
        gxb_cal_blk_clk	          => gxb_cal_blk_clk_wire,   
        gxb_los	                  => '0',  
        gxb_pll_inclk	          => gxb_refclk_wire,
        gxb_pll_locked	          => gxb_pll_locked_wire,
        gxb_powerdown	          => '0',
        gxb_refclk		          => gxb_refclk_wire,  
        gxb_rx_disperr	          => gxb_rx_disperr_wire,
        gxb_rx_errdetect	      => gxb_rx_errdetect_wire, 
        gxb_rx_freqlocked	      => gxb_rx_freqlocked_wire,
        gxb_rx_pll_locked	      => gxb_rx_pll_locked_wire,
        gxb_rxdatain	          => cpri_rec_loopback_wire, 
        gxb_txdataout	          => cpri_rec_loopback_wire,
        hw_reset_assert           => '0',
        hw_reset_req	          => hw_reset_req_wire, 
        pll_clkout		          => pll_clkout_wire, 
        reconfig_busy	          => reconfig_busy_wire,
        reconfig_clk		      => reconfig_clk_wire,
        reconfig_done			  => reconfig_done_wire,	
        reconfig_write			  => reconfig_write_all_wire,
        reconfig_fromgxb_m	      => reconfig_fromgxb_wire,
        reconfig_togxb_m		  => reconfig_togxb_wire,
        reset	                  => reset_wire,
        reset_done                => reset_done_wire,
        reset_ex_delay	          => reset_ex_delay_wire
    ); 
end architecture behavioral;
