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
--File name: cpri_reconfig_controller.vhd
--Description: This module contains a statemachine that will handle the xcvr_reconfig_controller in order to execute the dynamic reconfiguration on 
--             the deterministic latency phy.              
-------------------------------------------------------------------------------------------------------------------------------------------

library ieee;  
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use work.all;

entity cpri_reconfig_controller is
port (
    clk                       : in  std_logic;
    reset                     : in  std_logic;
    start_reconfig            : in  std_logic_vector(1 downto 0);
    reconfig_from_xcvr        : in  std_logic_vector(91 downto 0)  := (others => '0');
    reset_done                : in std_logic;
    done_reconfig             : out std_logic;
    config_mode               : out std_logic_vector(1 downto 0);
    reconfig_busy             : out std_logic;
    reconfig_to_xcvr          : out std_logic_vector(139 downto 0);                    
    reset_phy                 : out std_logic
);
end entity cpri_reconfig_controller;

architecture rtl of cpri_reconfig_controller is  
   -- Streamer Module Registers
   constant REG_LOG_CH : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#38#,7); -- Logical channel number
   constant REG_CS     : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#3A#,7); -- Control and status register
   constant REG_OFFSET : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#3B#,7); -- Offset register
   constant REG_DATA   : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#3C#,7); -- Data register

    -- Streamer Module Internal MIF Register Offsets
    -- REG_OFFSET 0x0: [R/W] MIF Base Address
    -- REG_OFFSET 0x1: [R/W] Set bit-0 to start MIF Stream
    -- REG_OFFSET 0x1: [R/W] Set bit-1 to clear error status in indirect register.
    -- REG_OFFSET 0x2: [Read-only] 
    -- bit-4 MIF or channel mismatch
    -- bit-2 PLL reconfiguration IP error
    -- bit-1 MIF opcode error
    -- bit-0 Invalid register access

   type StateType is   ( ST_IDLE,
                         ST_PHY_READY,
                         ST_SET_LOGICAL_CH,
                         ST_SET_MIF_MODE,
                         ST_OFFSET_0,
                         ST_DATA_0,
                         ST_WRITE_MIF,
                         ST_OFFSET_1,
                         ST_DATA_1,
                         ST_STREAM_MIF,
                         ST_RECONFIG,
                         ST_RECONFIG_BUSY,
                         ST_RECONFIG_STATUS,
                         ST_RECONFIG_STATUS_CHECK_1,
                         ST_RECONFIG_STATUS_CHECK_2,
                         ST_RECONFIG_STATUS_CHECK_3
                         );
   -- Component declaration
   component xcvr_reconfig_cpri is
      port (
              reconfig_busy             : out std_logic;                                         --      reconfig_busy.reconfig_busy
              mgmt_clk_clk              : in  std_logic                      := '0';             --       mgmt_clk_clk.clk
              mgmt_rst_reset            : in  std_logic                      := '0';             --     mgmt_rst_reset.reset
              reconfig_mgmt_address     : in  std_logic_vector(6 downto 0)   := (others => '0'); --      reconfig_mgmt.address
              reconfig_mgmt_read        : in  std_logic                      := '0';             --                   .read
              reconfig_mgmt_readdata    : out std_logic_vector(31 downto 0);                     --                   .readdata
              reconfig_mgmt_waitrequest : out std_logic;                                         --                   .waitrequest
              reconfig_mgmt_write       : in  std_logic                      := '0';             --                   .write
              reconfig_mgmt_writedata   : in  std_logic_vector(31 downto 0)  := (others => '0'); --                   .writedata
              reconfig_mif_address      : out std_logic_vector(31 downto 0);                     --       reconfig_mif.address
              reconfig_mif_read         : out std_logic;                                         --                   .read
              reconfig_mif_readdata     : in  std_logic_vector(15 downto 0)  := (others => '0'); --                   .readdata
              reconfig_mif_waitrequest  : in  std_logic                      := '0';             --                   .waitrequest
              reconfig_to_xcvr          : out std_logic_vector(139 downto 0);                    --   reconfig_to_xcvr.reconfig_to_xcvr
              reconfig_from_xcvr        : in  std_logic_vector(91 downto 0)  := (others => '0')  -- reconfig_from_xcvr.reconfig_from_xcvr
           );
   end component xcvr_reconfig_cpri;
   
   component rom_stratix5 is
      generic (
         init_file : in string := "inst_xcvr_channel_614.mif"
      );
      port (
              address	 : in std_logic_vector(7 downto 0);
              clock	    : in std_logic := '1';
              q		    : out std_logic_vector(15 downto 0)
           );
   end component rom_stratix5;
                     
   -- Signal declaration
   -- component: xcvr_reconfig_cpri
   -- inputs
   signal reconfig_mgmt_address                    : std_logic_vector(6 downto 0);
   signal reconfig_mgmt_write                      : std_logic;
   signal reconfig_mgmt_writedata                  : std_logic_vector(31 downto 0);
   signal reconfig_mgmt_read                       : std_logic;
   signal reconfig_mif_readdata                    : std_logic_vector(15 downto 0)  := (others => '0');
   signal reconfig_mif_waitrequest                 : std_logic                      := '0';     
   -- output
   signal reconfig_mgmt_readdata                   : std_logic_vector(31 downto 0);
   signal reconfig_mgmt_waitrequest                : std_logic;
   signal reconfig_mif_address                     : std_logic_vector(31 downto 0):= (others=>'0');                    
   signal reconfig_mif_read                        : std_logic:= '0';                                     
   signal reconfig_busy_wire                       : std_logic;
     
   -- signal switch 
   signal reconfig_channel_addr                    : std_logic_vector(7 downto 0);
   signal reconfig_pll_addr                        : std_logic_vector(7 downto 0);
   signal reconfig_channel_readdata                : std_logic_vector(15 downto 0);
   signal reconfig_pll_readdata                    : std_logic_vector(15 downto 0);
   signal config_mode_wire                              : std_logic_vector(1 downto 0);

   -- Flip-flops
   signal state : StateType;
   signal reconfig_in_progress  : std_logic;
   signal reset_phy_counter     : std_logic_vector(3 downto 0);
   signal read_done             : std_logic;
  
   -- misc
   signal done_reconfig_wire  : std_logic;
   signal reconfig_logical_channel                  : std_logic_vector(31 downto 0);
 
begin
   
   done_reconfig <= done_reconfig_wire;
   reconfig_busy <= reconfig_busy_wire;
   config_mode   <= config_mode_wire;
   -- Sequential logic
   reset_phy_sequential: process(clk, reset) is
   begin
      if (reset = '1') then
         reset_phy<= '1';
         reset_phy_counter <= (others => '0');
      else
         if (reconfig_in_progress = '1') then
            reset_phy <= '1'; -- Hold PHY in reset mode during reconfiguration , until reconfig_done
         elsif (done_reconfig_wire = '1' and reset_phy_counter < "1010") then
            reset_phy_counter <= reset_phy_counter + '1';
            reset_phy <= '1';
            -- hold reset for 10 cycles after reconfig_done. Then release the PHY reset
         else
            reset_phy_counter <= "0000";
            reset_phy <= '0';
         end if; 
      end if;
   end process reset_phy_sequential;

  
   -- Reconfig logic 
   reconfig_sequential : process(clk, reset) is
   begin
      if (reset = '1') then
         state<= ST_IDLE;
         reconfig_mgmt_address<= (others=>'0');
         reconfig_mgmt_read <= '0';
         reconfig_mgmt_write <= '0';
         reconfig_mgmt_writedata <= (others=>'0');
         done_reconfig_wire <= '0';
         reconfig_in_progress <= '0';
         config_mode_wire <= "00";
      elsif (clk'event and clk='1') then
         reconfig_mgmt_read <= '0';
         reconfig_mgmt_write <= '0';

         case state is 
            when ST_IDLE =>
               reconfig_mgmt_address <= (others=>'0');
               reconfig_mgmt_read <= '0';
               reconfig_mgmt_write <= '0';
               reconfig_mgmt_writedata <= (others=>'0');
               done_reconfig_wire <= '0';
               reconfig_in_progress <= '0';
               if (start_reconfig = "01") then
                  -- Wait for PHY rx_ready and tx_ready before start reconfiguring
                  state <= ST_PHY_READY;
               end if;

            when ST_PHY_READY =>
               --if (tx_ready='1' and rx_ready='1') then
               if (reset_done = '1') then
                  state <= ST_SET_LOGICAL_CH;
                  reconfig_in_progress <= '1';
               end if;

            when ST_SET_LOGICAL_CH =>
               -- Set logical channel to 0x0
               if (reconfig_mgmt_waitrequest ='0') then
                  reconfig_mgmt_address <= REG_LOG_CH;
                  reconfig_mgmt_write <= '1';
                  reconfig_mgmt_writedata <= reconfig_logical_channel;
                  state <= ST_SET_MIF_MODE;
               end if;

            when ST_SET_MIF_MODE =>
              -- Set mode bit[3:2] of REG_CS to 2#00# MIF mode.
               if (reconfig_mgmt_waitrequest ='0' ) then
                  reconfig_mgmt_address <= REG_CS;
                  reconfig_mgmt_write <= '1';
                  reconfig_mgmt_writedata <= (others=>'0');
                  state <= ST_OFFSET_0;
               end if;

            when ST_OFFSET_0 =>
               -- Set offset to 0x0 to set MIF base address in ST_DATA_0
               if ( reconfig_mgmt_waitrequest ='0' ) then
                  reconfig_mgmt_address <= REG_OFFSET;
                  reconfig_mgmt_write <= '1';
                  reconfig_mgmt_writedata <= (others=>'0');
                  state <= ST_DATA_0;
               end if;

            when ST_DATA_0 =>
                --Set MIF base address to 0x0
               if (reconfig_mgmt_waitrequest = '0' ) then
                  reconfig_mgmt_address <= REG_DATA;
                  reconfig_mgmt_write <= '1';
                  reconfig_mgmt_writedata <= (others =>'0');
                  state <= ST_WRITE_MIF;
               end if;
               
            when ST_WRITE_MIF =>
               --Initiate write operation to write all the data set in the previous state.
               if (reconfig_mgmt_waitrequest = '0' ) then
                  reconfig_mgmt_address <= REG_CS;
                  reconfig_mgmt_write <= '1';
                  reconfig_mgmt_writedata <= X"00000001";
                  state <= ST_OFFSET_1;
               end if;
  
            when ST_OFFSET_1 =>
               --Set offset to 0x1 to start MIF stream to be done in ST_DATA_1
               if (reconfig_mgmt_waitrequest = '0' ) then
                  reconfig_mgmt_address <= REG_OFFSET;
                  reconfig_mgmt_write <= '1';
                  reconfig_mgmt_writedata <= X"00000001";
                  state <= ST_DATA_1;
               end if;
                 
            when ST_DATA_1 =>
               -- Stream MIF by writing 1 to bit-0 of offset 0x1.
               if (reconfig_mgmt_waitrequest='0') then
                  reconfig_mgmt_address <= REG_DATA;
                  reconfig_mgmt_write <= '1';
                  reconfig_mgmt_writedata <= X"00000001";
                  state <= ST_STREAM_MIF;
               end if; 

            when ST_STREAM_MIF =>
            -- Initiate write operation to write all the data set in the previous state.
               if ( reconfig_mgmt_waitrequest='0' ) then
                  reconfig_mgmt_address <= REG_CS;
                  reconfig_mgmt_write <= '1';
                  reconfig_mgmt_writedata <= X"00000001";
                  state <= ST_RECONFIG;
               end if;
       
            when ST_RECONFIG =>
            --Wait for reconfig to start.
               if ( reconfig_mgmt_waitrequest = '0' ) then
                  if ( reconfig_busy_wire = '1' ) then
                     state <= ST_RECONFIG_BUSY;
                  end if;
               end if;
          
            when ST_RECONFIG_BUSY =>
            -- Reconfiguring by streaming MIF.
               if ( reconfig_busy_wire = '0' ) then
                  state <= ST_RECONFIG_STATUS;
                  done_reconfig_wire <= '1'; --asserted for one cycle only.
                  reconfig_in_progress <= '0';
               end if;
                    
            when ST_RECONFIG_STATUS =>
               -- Check reconfig MIF register status from offset 0x2 after done reconfig.
               if ( reconfig_mgmt_waitrequest = '0' ) then
                  reconfig_mgmt_address <= REG_OFFSET;
                  reconfig_mgmt_write <= '1';
                  reconfig_mgmt_writedata <= X"00000002";
                  state <= ST_RECONFIG_STATUS_CHECK_1;
               end if;
               
            when ST_RECONFIG_STATUS_CHECK_1 =>
               -- Initiate read operation to read from offset 0x2.
               if ( reconfig_mgmt_waitrequest ='0' ) then
                  reconfig_mgmt_address <= REG_CS;
                  reconfig_mgmt_write <= '1';
                  reconfig_mgmt_writedata <= X"00000002";
                  state <= ST_RECONFIG_STATUS_CHECK_2;
               end if;
                
            when ST_RECONFIG_STATUS_CHECK_2 =>
               -- Read MIF reg status from offset 0x2.
               if ( reconfig_mgmt_waitrequest = '0' ) then
                  reconfig_mgmt_address <= REG_DATA;
                  reconfig_mgmt_read <= '1';
                  state <= ST_RECONFIG_STATUS_CHECK_3;
               end if;
              
            when ST_RECONFIG_STATUS_CHECK_3 =>
            -- Read MIF reg status from offset 0x2.
               if ( reconfig_mgmt_waitrequest = '0') then
                  state <= ST_IDLE;
                  config_mode_wire <= config_mode_wire + '1';
               end if;
         end case;
     end if;
  end process reconfig_sequential;

   read_mif_sequential : process(clk, reset) is
   begin
      if (reset = '1') then
         reconfig_mif_waitrequest <= '0';
         read_done <= '0'; -- hold the waitrequest for two clock cycles because ROM data out is registered
      elsif (clk'event and clk = '1') then
         if (reconfig_mif_read ='1' and read_done = '0') then
            reconfig_mif_waitrequest <= '1';
            read_done <= '1';
         elsif (reconfig_mif_read='1') then
            reconfig_mif_waitrequest <= '0';
            read_done <='0';
         else
            reconfig_mif_waitrequest <= '1';
            read_done <= '0';
         end if;
      end if;
   end process read_mif_sequential;

   -- Signal switch
   -- This is to switch between the channel and pll reconfiguration with respective mif setting
   -- TX PLL     -> logical addr = X"00000001"
   -- Channel IF -> logical addr = X"00000000"
   signal_switch : process(clk, reset) is
   begin
      if config_mode_wire = "00" then
         reconfig_channel_addr     <= reconfig_mif_address(8 downto 1);
         reconfig_mif_readdata     <= reconfig_channel_readdata;
         reconfig_logical_channel  <= X"00000000";
      elsif config_mode_wire = "01" then
         reconfig_pll_addr         <= reconfig_mif_address(8 downto 1);
         reconfig_mif_readdata     <= reconfig_pll_readdata;
         reconfig_logical_channel  <= X"00000001";
      else
         reconfig_channel_addr <= (others=>'0');
         reconfig_pll_addr     <= (others=>'0');
         reconfig_mif_readdata <= (others=>'0');
         reconfig_logical_channel <= (others=>'0');
      end if;
   end process signal_switch;

   -- Component instantiation
   rom_channel_614_inst : rom_stratix5
   generic map (
               init_file => "../../../../reconfig_mif/inst_xcvr_channel.mif"
               )
   port map(
              address   => reconfig_channel_addr,
              clock	   => clk, 
              q		   => reconfig_channel_readdata
           );
    
   rom_pll_614_inst : rom_stratix5
   generic map (
               init_file => "../../../../reconfig_mif/inst_xcvr_txpll0.mif"
               )
   port map(
              address   => reconfig_pll_addr,
              clock	   => clk, 
              q		   => reconfig_pll_readdata
           );

   xcvr_reconfig_cpri_inst : xcvr_reconfig_cpri
      port map (
                  reconfig_busy             => reconfig_busy_wire,
                  mgmt_clk_clk              => clk,
                  mgmt_rst_reset            => reset,
                  reconfig_mgmt_address     => reconfig_mgmt_address,
                  reconfig_mgmt_read        => reconfig_mgmt_read,
                  reconfig_mgmt_readdata    => reconfig_mgmt_readdata,
                  reconfig_mgmt_waitrequest => reconfig_mgmt_waitrequest,
                  reconfig_mgmt_write       => reconfig_mgmt_write,
                  reconfig_mgmt_writedata   => reconfig_mgmt_writedata,
                  reconfig_mif_address      => reconfig_mif_address,
                  reconfig_mif_read         => reconfig_mif_read,
                  reconfig_mif_readdata     => reconfig_mif_readdata,
                  reconfig_mif_waitrequest  => reconfig_mif_waitrequest,
                  reconfig_to_xcvr          => reconfig_to_xcvr,
                  reconfig_from_xcvr        => reconfig_from_xcvr
               );
   end rtl;

