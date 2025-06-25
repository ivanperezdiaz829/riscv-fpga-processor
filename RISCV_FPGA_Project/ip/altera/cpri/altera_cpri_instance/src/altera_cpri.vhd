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
use ieee.std_logic_unsigned.all;

entity altera_cpri is
generic (
   DEVICE                          : in integer := 0;
   SYNC_MODE                       : in integer := 0;
   LINERATE                        : in integer := 0;
   AUTORATE                        : in integer := 0;
   S_CH_NUMBER_M                   : in integer := 0;
   S_CH_NUMBER_S_TX                : in integer := 0;
   S_CH_NUMBER_S_RX                : in integer := 0;
   WIDTH_RX_BUF                    : in integer := 6;
   HDLC_OFF                        : in integer := 0;
   MAC_OFF                         : in integer := 0;
   N_MAP                           : in integer := 24;
   SYNC_MAP                        : in integer := 0;
   MAP_MODE                        : in integer := 4;
   VSS_OFF                         : in integer := 0;
   CAL_OFF                         : in integer := 0;
   CODE_BASE                       : in integer := 0
);
port (
   -- ALTGX Signals
   gxb_refclk                      : in  std_logic;
   gxb_pll_inclk                   : in  std_logic;  
   gxb_cal_blk_clk                 : in  std_logic;
   gxb_powerdown                   : in  std_logic;
   gxb_pll_locked                  : out std_logic;
   gxb_rx_pll_locked               : out std_logic;
   gxb_rx_freqlocked               : out std_logic;
   gxb_rx_errdetect                : out std_logic_vector(3 downto 0);
   gxb_rx_disperr                  : out std_logic_vector(3 downto 0);
   gxb_los                         : in  std_logic;
   gxb_txdataout                   : out std_logic;
   gxb_rxdatain                    : in  std_logic;
   usr_clk                         : in  std_logic;
   usr_pma_clk                     : in  std_logic;
   -- ALTGX_RECONFIG Signals
   reconfig_clk                    : in  std_logic;
   reconfig_busy                   : in  std_logic;
   reconfig_write                  : in  std_logic;
   reconfig_done                   : in  std_logic;
   reconfig_togxb_m                : in  std_logic_vector(3 downto 0);
   reconfig_togxb_s_tx             : in  std_logic_vector(3 downto 0);
   reconfig_togxb_s_rx             : in  std_logic_vector(3 downto 0);
   reconfig_fromgxb_m              : out std_logic_vector((16-((DEVICE/3)*12)) downto 0);
   reconfig_fromgxb_s_tx           : out std_logic_vector((16-((DEVICE/3)*12)) downto 0);
   reconfig_fromgxb_s_rx           : out std_logic_vector((16-((DEVICE/3)*12)) downto 0);
   --  ALTPLL_RECONFIG Signals
   pll_areset                      : in  std_logic_vector(1 downto 0);      
   pll_configupdate                : in  std_logic_vector(1 downto 0);
   pll_scanclk                     : in  std_logic_vector(1 downto 0);     
   pll_scanclkena                  : in  std_logic_vector(1 downto 0);     
   pll_scandata                    : in  std_logic_vector(1 downto 0);                                      
   pll_reconfig_done               : out std_logic_vector(1 downto 0);     
   pll_scandataout                 : out std_logic_vector(1 downto 0);  
   -- Clock and Reset
   cpri_clkout                     : out std_logic;
   pll_clkout                      : out std_logic;
   reset                           : in  std_logic;
   reset_done                      : out std_logic;
   config_reset                    : in  std_logic;
   hw_reset_assert                 : in  std_logic;
   hw_reset_req                    : out std_logic;
   clk_ex_delay                    : in  std_logic;
   reset_ex_delay                  : in  std_logic;
   -- CPRI Status
   extended_rx_status_data         : out std_logic_vector(11 downto 0);
   datarate_en                     : out std_logic;
   datarate_set                    : out std_logic_vector(4 downto 0);  
   -- CPU Interface
   cpu_clk                         : in  std_logic;
   cpu_reset                       : in  std_logic;
   cpu_address                     : in  std_logic_vector(15 downto 2);
   cpu_byteenable                  : in  std_logic_vector(3 downto 0);
   cpu_writedata                   : in  std_logic_vector(31 downto 0);
   cpu_readdata                    : out std_logic_vector(31 downto 0);
   cpu_read                        : in  std_logic;
   cpu_write                       : in  std_logic;
   cpu_waitrequest                 : out std_logic;
   cpu_irq                         : out std_logic;
   cpu_irq_vector                  : out std_logic_vector(4 downto 0);
   -- Auxiliary Interface
   aux_rx_status_data              : out std_logic_vector(75 downto 0);
   aux_tx_status_data              : out std_logic_vector(43 downto 0);
   aux_tx_mask_data                : in  std_logic_vector(64 downto 0);
   -- Hard PCS Interface
   phy_mgmt_clk                    : out std_logic;  
   phy_mgmt_clk_reset              : out std_logic;  
   phy_mgmt_address                : out std_logic_vector(11 downto 0);
   phy_mgmt_read                   : out std_logic;
   phy_mgmt_readdata               : in  std_logic_vector(31 downto 0);
   phy_mgmt_waitrequest            : in  std_logic;      
   phy_mgmt_write                  : out std_logic;
   phy_mgmt_writedata              : out std_logic_vector(31 downto 0);
   phy_tx_ready                    : in  std_logic;                      
   phy_rx_ready                    : in  std_logic;                      
   phy_pll_ref_clk                 : out std_logic; 
   phy_tx_serial_data              : in  std_logic;   
   phy_pll_locked                  : in  std_logic;   
   phy_rx_serial_data              : out std_logic; 
   phy_rx_is_lockedtoref           : in  std_logic;       
   phy_rx_is_lockedtodata          : in  std_logic;       
   phy_rx_bitslipboundaryselectout : in  std_logic_vector(4 downto 0);       
   phy_tx_clkout                   : in  std_logic;       
   phy_rx_clkout                   : in  std_logic;       
   phy_tx_parallel_data            : out std_logic_vector(43 downto 0);  
   phy_rx_parallel_data            : in  std_logic_vector(63 downto 0);      
   phy_tx_bitslipboundaryselect    : out std_logic_vector(4 downto 0);
   phy_pll_inclk                   : out std_logic;
   -- Soft-PCS Interface
   xcvr_mgmt_clk                   : out std_logic;
   xcvr_mgmt_clk_reset             : out std_logic;
   xcvr_mgmt_read                  : out std_logic;
   xcvr_mgmt_write                 : out std_logic;
   xcvr_mgmt_address               : out std_logic_vector(11 downto 0);
   xcvr_mgmt_writedata             : out std_logic_vector(31 downto 0);
   xcvr_mgmt_readdata              : in  std_logic_vector(31 downto 0);
   xcvr_mgmt_waitrequest           : in  std_logic;
   xcvr_pll_ref_clk                : out std_logic;
   xcvr_cdr_ref_clk                : out std_logic;
   xcvr_usr_pma_clk                : out std_logic;
   xcvr_usr_clk                    : out std_logic;
   xcvr_fifo_calc_clk              : out std_logic;
   xcvr_tx_fifocalreset            : out std_logic;
   xcvr_rx_fifocalreset            : out std_logic;
   xcvr_rx_clkout                  : in  std_logic;
   xcvr_rx_serial_data             : out std_logic;
   xcvr_rx_parallel_data           : in  std_logic_vector(31 downto 0);
   xcvr_tx_parallel_data           : out std_logic_vector(31 downto 0);
   xcvr_tx_serial_data             : in  std_logic;
   xcvr_tx_datak                   : out std_logic_vector(3 downto 0);
   xcvr_rx_datak                   : in  std_logic_vector(3 downto 0);
   xcvr_tx_bitslipboundaryselect   : out std_logic_vector(6 downto 0);
   xcvr_rx_bitslipboundaryselectout: in  std_logic_vector(6 downto 0);
   xcvr_rx_disperr                 : in  std_logic_vector(3 downto 0);
   xcvr_rx_errdetect               : in  std_logic_vector(3 downto 0);
   xcvr_rx_syncstatus              : in  std_logic_vector(3 downto 0);
   xcvr_pll_locked                 : in  std_logic;
   xcvr_tx_ready                   : in  std_logic;
   xcvr_rx_ready                   : in  std_logic;
   xcvr_tx_fifo_sample_size        : out std_logic_vector(7 downto 0);
   xcvr_rx_fifo_sample_size        : out std_logic_vector(7 downto 0);
   xcvr_tx_phase_measure_acc       : in  std_logic_vector(31 downto 0);
   xcvr_rx_phase_measure_acc       : in  std_logic_vector(31 downto 0);
   xcvr_tx_fifo_latency            : in  std_logic_vector(4 downto 0);
   xcvr_rx_fifo_latency            : in  std_logic_vector(WIDTH_RX_BUF downto 0);
   xcvr_tx_ph_acc_valid            : in  std_logic;
   xcvr_rx_ph_acc_valid            : in  std_logic;
   xcvr_tx_wr_full                 : in  std_logic;
   xcvr_rx_wr_full                 : in  std_logic;
   xcvr_tx_rd_empty                : in  std_logic;
   xcvr_rx_rd_empty                : in  std_logic;
   xcvr_tx_fiforeset               : out std_logic;
   xcvr_rx_fiforeset               : out std_logic;
   xcvr_tx_data_width_pma          : out std_logic_vector(6 downto 0);
   xcvr_rx_data_width_pma          : out std_logic_vector(6 downto 0);
   xcvr_rx_is_lockedtoref          : in  std_logic;       
   xcvr_rx_is_lockedtodata         : in  std_logic;       
   -- MII Interface
   cpri_mii_txclk                  : out std_logic;
   cpri_mii_txrd                   : out std_logic;
   cpri_mii_txen                   : in  std_logic;
   cpri_mii_txer                   : in  std_logic;
   cpri_mii_txd                    : in  std_logic_vector(3 downto 0);
   cpri_mii_rxclk                  : out std_logic;
   cpri_mii_rxwr                   : out std_logic;
   cpri_mii_rxdv                   : out std_logic;
   cpri_mii_rxer                   : out std_logic;
   cpri_mii_rxd                    : out std_logic_vector(3 downto 0);
   -- Channel 0 TX & RX
   map0_rx_clk                     : in  std_logic;
   map0_rx_reset                   : in  std_logic;
   map0_rx_ready                   : in  std_logic;
   map0_rx_data                    : out std_logic_vector(31 downto 0);
   map0_rx_valid                   : out std_logic;
   map0_rx_resync                  : in  std_logic;
   map0_rx_status_data             : out std_logic_vector(2 downto 0);
   map0_rx_start                   : out std_logic;
   map0_tx_clk                     : in  std_logic;
   map0_tx_reset                   : in  std_logic;
   map0_tx_ready                   : out std_logic;
   map0_tx_data                    : in  std_logic_vector(31 downto 0);
   map0_tx_valid                   : in  std_logic;
   map0_tx_resync                  : in  std_logic;
   map0_tx_status_data             : out std_logic_vector(2 downto 0);
   -- Channel 1 TX & RX
   map1_rx_clk                     : in  std_logic;
   map1_rx_reset                   : in  std_logic;
   map1_rx_ready                   : in  std_logic;
   map1_rx_data                    : out std_logic_vector(31 downto 0);
   map1_rx_valid                   : out std_logic;
   map1_rx_resync                  : in  std_logic;
   map1_rx_status_data             : out std_logic_vector(2 downto 0);
   map1_rx_start                   : out std_logic;
   map1_tx_clk                     : in  std_logic;
   map1_tx_reset                   : in  std_logic;
   map1_tx_ready                   : out std_logic;
   map1_tx_data                    : in  std_logic_vector(31 downto 0);
   map1_tx_valid                   : in  std_logic;
   map1_tx_resync                  : in  std_logic;
   map1_tx_status_data             : out std_logic_vector(2 downto 0);
   -- Channel 2 TX & RX
   map2_rx_clk                     : in  std_logic;
   map2_rx_reset                   : in  std_logic;
   map2_rx_ready                   : in  std_logic;
   map2_rx_data                    : out std_logic_vector(31 downto 0);
   map2_rx_valid                   : out std_logic;
   map2_rx_resync                  : in  std_logic;
   map2_rx_status_data             : out std_logic_vector(2 downto 0);
   map2_rx_start                   : out std_logic;
   map2_tx_clk                     : in  std_logic;
   map2_tx_reset                   : in  std_logic;
   map2_tx_ready                   : out std_logic;
   map2_tx_data                    : in  std_logic_vector(31 downto 0);
   map2_tx_valid                   : in  std_logic;
   map2_tx_resync                  : in  std_logic;
   map2_tx_status_data             : out std_logic_vector(2 downto 0);
   -- Channel 3 TX & RX
   map3_rx_clk                     : in  std_logic;
   map3_rx_reset                   : in  std_logic;
   map3_rx_ready                   : in  std_logic;
   map3_rx_data                    : out std_logic_vector(31 downto 0);
   map3_rx_valid                   : out std_logic;
   map3_rx_resync                  : in  std_logic;
   map3_rx_status_data             : out std_logic_vector(2 downto 0);
   map3_rx_start                   : out std_logic;
   map3_tx_clk                     : in  std_logic;
   map3_tx_reset                   : in  std_logic;
   map3_tx_ready                   : out std_logic;
   map3_tx_data                    : in  std_logic_vector(31 downto 0);
   map3_tx_valid                   : in  std_logic;
   map3_tx_resync                  : in  std_logic;
   map3_tx_status_data             : out std_logic_vector(2 downto 0);
   -- Channel 4 TX & RX
   map4_rx_clk                     : in  std_logic;
   map4_rx_reset                   : in  std_logic;
   map4_rx_ready                   : in  std_logic;
   map4_rx_data                    : out std_logic_vector(31 downto 0);
   map4_rx_valid                   : out std_logic;
   map4_rx_resync                  : in  std_logic;
   map4_rx_status_data             : out std_logic_vector(2 downto 0);
   map4_rx_start                   : out std_logic;
   map4_tx_clk                     : in  std_logic;
   map4_tx_reset                   : in  std_logic;
   map4_tx_ready                   : out std_logic;
   map4_tx_data                    : in  std_logic_vector(31 downto 0);
   map4_tx_valid                   : in  std_logic;
   map4_tx_resync                  : in  std_logic;
   map4_tx_status_data             : out std_logic_vector(2 downto 0);
   -- Channel 5 TX & RX
   map5_rx_clk                     : in  std_logic;
   map5_rx_reset                   : in  std_logic;
   map5_rx_ready                   : in  std_logic;
   map5_rx_data                    : out std_logic_vector(31 downto 0);
   map5_rx_valid                   : out std_logic;
   map5_rx_resync                  : in  std_logic;
   map5_rx_status_data             : out std_logic_vector(2 downto 0);
   map5_rx_start                   : out std_logic;
   map5_tx_clk                     : in  std_logic;
   map5_tx_reset                   : in  std_logic;
   map5_tx_ready                   : out std_logic;
   map5_tx_data                    : in  std_logic_vector(31 downto 0);
   map5_tx_valid                   : in  std_logic;
   map5_tx_resync                  : in  std_logic;
   map5_tx_status_data             : out std_logic_vector(2 downto 0);
   -- Channel 6 TX & RX
   map6_rx_clk                     : in  std_logic;
   map6_rx_reset                   : in  std_logic;
   map6_rx_ready                   : in  std_logic;
   map6_rx_data                    : out std_logic_vector(31 downto 0);
   map6_rx_valid                   : out std_logic;
   map6_rx_resync                  : in  std_logic;
   map6_rx_status_data             : out std_logic_vector(2 downto 0);
   map6_rx_start                   : out std_logic;
   map6_tx_clk                     : in  std_logic;
   map6_tx_reset                   : in  std_logic;
   map6_tx_ready                   : out std_logic;
   map6_tx_data                    : in  std_logic_vector(31 downto 0);
   map6_tx_valid                   : in  std_logic;
   map6_tx_resync                  : in  std_logic;
   map6_tx_status_data             : out std_logic_vector(2 downto 0);
   -- Channel 7 TX & RX
   map7_rx_clk                     : in  std_logic;
   map7_rx_reset                   : in  std_logic;
   map7_rx_ready                   : in  std_logic;
   map7_rx_data                    : out std_logic_vector(31 downto 0);
   map7_rx_valid                   : out std_logic;
   map7_rx_resync                  : in  std_logic;
   map7_rx_status_data             : out std_logic_vector(2 downto 0);
   map7_rx_start                   : out std_logic;
   map7_tx_clk                     : in  std_logic;
   map7_tx_reset                   : in  std_logic;
   map7_tx_ready                   : out std_logic;
   map7_tx_data                    : in  std_logic_vector(31 downto 0);
   map7_tx_valid                   : in  std_logic;
   map7_tx_resync                  : in  std_logic;
   map7_tx_status_data             : out std_logic_vector(2 downto 0);
   -- Channel 8 TX & RX
   map8_rx_clk                     : in  std_logic;
   map8_rx_reset                   : in  std_logic;
   map8_rx_ready                   : in  std_logic;
   map8_rx_data                    : out std_logic_vector(31 downto 0);
   map8_rx_valid                   : out std_logic;
   map8_rx_resync                  : in  std_logic;
   map8_rx_status_data             : out std_logic_vector(2 downto 0);
   map8_rx_start                    : out std_logic;
   map8_tx_clk                     : in  std_logic;
   map8_tx_reset                   : in  std_logic;
   map8_tx_ready                   : out std_logic;
   map8_tx_data                    : in  std_logic_vector(31 downto 0);
   map8_tx_valid                   : in  std_logic;
   map8_tx_resync                  : in  std_logic;
   map8_tx_status_data             : out std_logic_vector(2 downto 0);
   -- Channel 9 TX & RX
   map9_rx_clk                     : in  std_logic;
   map9_rx_reset                   : in  std_logic;
   map9_rx_ready                   : in  std_logic;
   map9_rx_data                    : out std_logic_vector(31 downto 0);
   map9_rx_valid                   : out std_logic;
   map9_rx_resync                  : in  std_logic;
   map9_rx_status_data             : out std_logic_vector(2 downto 0);
   map9_rx_start                   : out std_logic;
   map9_tx_clk                     : in  std_logic;
   map9_tx_reset                   : in  std_logic;
   map9_tx_ready                   : out std_logic;
   map9_tx_data                    : in  std_logic_vector(31 downto 0);
   map9_tx_valid                   : in  std_logic;
   map9_tx_resync                  : in  std_logic;
   map9_tx_status_data             : out std_logic_vector(2 downto 0);   
   -- Channel 10 TX & RX
   map10_rx_clk                    : in  std_logic;
   map10_rx_reset                  : in  std_logic;
   map10_rx_ready                  : in  std_logic;
   map10_rx_data                   : out std_logic_vector(31 downto 0);
   map10_rx_valid                  : out std_logic;
   map10_rx_resync                 : in  std_logic;
   map10_rx_status_data            : out std_logic_vector(2 downto 0);
   map10_rx_start                  : out std_logic;
   map10_tx_clk                    : in  std_logic;
   map10_tx_reset                  : in  std_logic;
   map10_tx_ready                  : out std_logic;
   map10_tx_data                   : in  std_logic_vector(31 downto 0);
   map10_tx_valid                  : in  std_logic;
   map10_tx_resync                 : in  std_logic;
   map10_tx_status_data            : out std_logic_vector(2 downto 0);   
   -- Channel 11 TX & RX
   map11_rx_clk                    : in  std_logic;
   map11_rx_reset                  : in  std_logic;
   map11_rx_ready                  : in  std_logic;
   map11_rx_data                   : out std_logic_vector(31 downto 0);
   map11_rx_valid                  : out std_logic;
   map11_rx_resync                 : in  std_logic;
   map11_rx_status_data            : out std_logic_vector(2 downto 0);
   map11_rx_start                  : out std_logic;
   map11_tx_clk                    : in  std_logic;
   map11_tx_reset                  : in  std_logic;
   map11_tx_ready                  : out std_logic;
   map11_tx_data                   : in  std_logic_vector(31 downto 0);
   map11_tx_valid                  : in  std_logic;
   map11_tx_resync                 : in  std_logic;
   map11_tx_status_data            : out std_logic_vector(2 downto 0);   
   -- Channel 12 TX & RX
   map12_rx_clk                    : in  std_logic;
   map12_rx_reset                  : in  std_logic;
   map12_rx_ready                  : in  std_logic;
   map12_rx_data                   : out std_logic_vector(31 downto 0);
   map12_rx_valid                  : out std_logic;
   map12_rx_resync                 : in  std_logic;
   map12_rx_status_data            : out std_logic_vector(2 downto 0);
   map12_rx_start                  : out std_logic;
   map12_tx_clk                    : in  std_logic;
   map12_tx_reset                  : in  std_logic;
   map12_tx_ready                  : out std_logic;
   map12_tx_data                   : in  std_logic_vector(31 downto 0);
   map12_tx_valid                  : in  std_logic;
   map12_tx_resync                 : in  std_logic;
   map12_tx_status_data            : out std_logic_vector(2 downto 0);      
   -- Channel 13 TX & RX
   map13_rx_clk                    : in  std_logic;
   map13_rx_reset                  : in  std_logic;
   map13_rx_ready                  : in  std_logic;
   map13_rx_data                   : out std_logic_vector(31 downto 0);
   map13_rx_valid                  : out std_logic;
   map13_rx_resync                 : in  std_logic;
   map13_rx_status_data            : out std_logic_vector(2 downto 0);
   map13_rx_start                  : out std_logic;
   map13_tx_clk                    : in  std_logic;
   map13_tx_reset                  : in  std_logic;
   map13_tx_ready                  : out std_logic;
   map13_tx_data                   : in  std_logic_vector(31 downto 0);
   map13_tx_valid                  : in  std_logic;
   map13_tx_resync                 : in  std_logic;
   map13_tx_status_data            : out std_logic_vector(2 downto 0);   
   -- Channel 14 TX & RX
   map14_rx_clk                    : in  std_logic;
   map14_rx_reset                  : in  std_logic;
   map14_rx_ready                  : in  std_logic;
   map14_rx_data                   : out std_logic_vector(31 downto 0);
   map14_rx_valid                  : out std_logic;
   map14_rx_resync                 : in  std_logic;
   map14_rx_status_data            : out std_logic_vector(2 downto 0);
   map14_rx_start                  : out std_logic;
   map14_tx_clk                    : in  std_logic;
   map14_tx_reset                  : in  std_logic;
   map14_tx_ready                  : out std_logic;
   map14_tx_data                   : in  std_logic_vector(31 downto 0);
   map14_tx_valid                  : in  std_logic;
   map14_tx_resync                 : in  std_logic;
   map14_tx_status_data            : out std_logic_vector(2 downto 0);   
   -- Channel 15 TX & RX
   map15_rx_clk                    : in  std_logic;
   map15_rx_reset                  : in  std_logic;
   map15_rx_ready                  : in  std_logic;
   map15_rx_data                   : out std_logic_vector(31 downto 0);
   map15_rx_valid                  : out std_logic;
   map15_rx_resync                 : in  std_logic;
   map15_rx_status_data            : out std_logic_vector(2 downto 0);
   map15_rx_start                  : out std_logic;
   map15_tx_clk                    : in  std_logic;
   map15_tx_reset                  : in  std_logic;
   map15_tx_ready                  : out std_logic;
   map15_tx_data                   : in  std_logic_vector(31 downto 0);
   map15_tx_valid                  : in  std_logic;
   map15_tx_resync                 : in  std_logic;
   map15_tx_status_data            : out std_logic_vector(2 downto 0);   
   -- Channel 16 TX & RX
   map16_rx_clk                    : in  std_logic;
   map16_rx_reset                  : in  std_logic;
   map16_rx_ready                  : in  std_logic;
   map16_rx_data                   : out std_logic_vector(31 downto 0);
   map16_rx_valid                  : out std_logic;
   map16_rx_resync                 : in  std_logic;
   map16_rx_status_data            : out std_logic_vector(2 downto 0);
   map16_rx_start                  : out std_logic;
   map16_tx_clk                    : in  std_logic;
   map16_tx_reset                  : in  std_logic;
   map16_tx_ready                  : out std_logic;
   map16_tx_data                   : in  std_logic_vector(31 downto 0);
   map16_tx_valid                  : in  std_logic;
   map16_tx_resync                 : in  std_logic;
   map16_tx_status_data            : out std_logic_vector(2 downto 0);
   -- Channel 17 TX & RX
   map17_rx_clk                    : in  std_logic;
   map17_rx_reset                  : in  std_logic;
   map17_rx_ready                  : in  std_logic;
   map17_rx_data                   : out std_logic_vector(31 downto 0);
   map17_rx_valid                  : out std_logic;
   map17_rx_resync                 : in  std_logic;
   map17_rx_status_data            : out std_logic_vector(2 downto 0);
   map17_rx_start                  : out std_logic;
   map17_tx_clk                    : in  std_logic;
   map17_tx_reset                  : in  std_logic;
   map17_tx_ready                  : out std_logic;
   map17_tx_data                   : in  std_logic_vector(31 downto 0);
   map17_tx_valid                  : in  std_logic;
   map17_tx_resync                 : in  std_logic;
   map17_tx_status_data            : out std_logic_vector(2 downto 0);
   -- Channel 18 TX & RX
   map18_rx_clk                    : in  std_logic;
   map18_rx_reset                  : in  std_logic;
   map18_rx_ready                  : in  std_logic;
   map18_rx_data                   : out std_logic_vector(31 downto 0);
   map18_rx_valid                  : out std_logic;
   map18_rx_resync                 : in  std_logic;
   map18_rx_status_data            : out std_logic_vector(2 downto 0);
   map18_rx_start                  : out std_logic;
   map18_tx_clk                    : in  std_logic;
   map18_tx_reset                  : in  std_logic;
   map18_tx_ready                  : out std_logic;
   map18_tx_data                   : in  std_logic_vector(31 downto 0);
   map18_tx_valid                  : in  std_logic;
   map18_tx_resync                 : in  std_logic;
   map18_tx_status_data            : out std_logic_vector(2 downto 0);
   -- Channel 19 TX & RX
   map19_rx_clk                    : in  std_logic;
   map19_rx_reset                  : in  std_logic;
   map19_rx_ready                  : in  std_logic;
   map19_rx_data                   : out std_logic_vector(31 downto 0);
   map19_rx_valid                  : out std_logic;
   map19_rx_resync                 : in  std_logic;
   map19_rx_status_data            : out std_logic_vector(2 downto 0);
   map19_rx_start                  : out std_logic;
   map19_tx_clk                    : in  std_logic;
   map19_tx_reset                  : in  std_logic;
   map19_tx_ready                  : out std_logic;
   map19_tx_data                   : in  std_logic_vector(31 downto 0);
   map19_tx_valid                  : in  std_logic;
   map19_tx_resync                 : in  std_logic;
   map19_tx_status_data            : out std_logic_vector(2 downto 0);
   -- Channel 20 TX & RX
   map20_rx_clk                    : in  std_logic;
   map20_rx_reset                  : in  std_logic;
   map20_rx_ready                  : in  std_logic;
   map20_rx_data                   : out std_logic_vector(31 downto 0);
   map20_rx_valid                  : out std_logic;
   map20_rx_resync                 : in  std_logic;
   map20_rx_status_data            : out std_logic_vector(2 downto 0);
   map20_rx_start                  : out std_logic;
   map20_tx_clk                    : in  std_logic;
   map20_tx_reset                  : in  std_logic;
   map20_tx_ready                  : out std_logic;
   map20_tx_data                   : in  std_logic_vector(31 downto 0);
   map20_tx_valid                  : in  std_logic;
   map20_tx_resync                 : in  std_logic;
   map20_tx_status_data            : out std_logic_vector(2 downto 0);
   -- Channel 21 TX & RX
   map21_rx_clk                    : in  std_logic;
   map21_rx_reset                  : in  std_logic;
   map21_rx_ready                  : in  std_logic;
   map21_rx_data                   : out std_logic_vector(31 downto 0);
   map21_rx_valid                  : out std_logic;
   map21_rx_resync                 : in  std_logic;
   map21_rx_status_data            : out std_logic_vector(2 downto 0);
   map21_rx_start                  : out std_logic;
   map21_tx_clk                    : in  std_logic;
   map21_tx_reset                  : in  std_logic;
   map21_tx_ready                  : out std_logic;
   map21_tx_data                   : in  std_logic_vector(31 downto 0);
   map21_tx_valid                  : in  std_logic;
   map21_tx_resync                 : in  std_logic;
   map21_tx_status_data            : out std_logic_vector(2 downto 0);
   -- Channel 22 TX & RX
   map22_rx_clk                    : in  std_logic;
   map22_rx_reset                  : in  std_logic;
   map22_rx_ready                  : in  std_logic;
   map22_rx_data                   : out std_logic_vector(31 downto 0);
   map22_rx_valid                  : out std_logic;
   map22_rx_resync                 : in  std_logic;
   map22_rx_status_data            : out std_logic_vector(2 downto 0);
   map22_rx_start                  : out std_logic;
   map22_tx_clk                    : in  std_logic;
   map22_tx_reset                  : in  std_logic;
   map22_tx_ready                  : out std_logic;
   map22_tx_data                   : in  std_logic_vector(31 downto 0);
   map22_tx_valid                  : in  std_logic;
   map22_tx_resync                 : in  std_logic;
   map22_tx_status_data            : out std_logic_vector(2 downto 0);   
   -- Channel 23 TX & RX
   map23_rx_clk                    : in  std_logic;
   map23_rx_reset                  : in  std_logic;
   map23_rx_ready                  : in  std_logic;
   map23_rx_data                   : out std_logic_vector(31 downto 0);
   map23_rx_valid                  : out std_logic;
   map23_rx_resync                 : in  std_logic;
   map23_rx_status_data            : out std_logic_vector(2 downto 0);
   map23_rx_start                  : out std_logic;
   map23_tx_clk                    : in  std_logic;
   map23_tx_reset                  : in  std_logic;
   map23_tx_ready                  : out std_logic;
   map23_tx_data                   : in  std_logic_vector(31 downto 0);
   map23_tx_valid                  : in  std_logic;
   map23_tx_resync                 : in  std_logic;
   map23_tx_status_data            : out std_logic_vector(2 downto 0)
);
end entity;

architecture rtl of altera_cpri is
ATTRIBUTE ALTERA_ATTRIBUTE        : string;
ATTRIBUTE ALTERA_ATTRIBUTE OF rtl : architecture is
"-name SUPPRESS_DA_RULE_INTERNAL C104";

   constant INCLUDE_RX_EX_DELAY : boolean := true;
   constant INCLUDE_TX_EX_DELAY : boolean := true;
   constant INCLUDE_8b10b       : boolean := false;
   constant INCLUDE_CPU_SYNC    : boolean := true;
   constant INCLUDE_PHY_LOOP    : boolean := true;
   constant INCLUDE_PRBS        : boolean := true;
   constant WIDTH_MAP_RX_ADDR   : integer := 4;
   constant WIDTH_MAP_TX_ADDR   : integer := 4;
   constant WIDTH_N_MAP         : integer := 5;
   constant WIDTH_ETH_BUF       : integer := 9;
   constant WIDTH_ETH_BLOCK     : integer := 4;
   constant WIDTH_HDLC_BUF      : integer := 9;
   constant WIDTH_HDLC_BLOCK    : integer := 4;
   constant WIDTH_RX            : integer := 8;
   constant WIDTH_K             : integer := 6;

---------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------- component instantiation -------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------      
   component clock_switch
   port (
         sel    : in  std_logic;
         reset  : in  std_logic;
         clk0   : in  std_logic;
         clk1   : in  std_logic;
         clkout : out std_logic
   );
   end component;

   component reset_controller
   generic(
      DEVICE               : in integer 
   );
   port (
         clk               : in  std_logic;
         reset             : in  std_logic;
         pll_locked  	   : in  std_logic;
         pll_configupdate  : in  std_logic_vector(1 downto 0);
         pll_reconfig_done : in  std_logic_vector(1 downto 0);
         pll_areset        : in  std_logic_vector(1 downto 0);
         rx_freqlocked 	   : in  std_logic;
         reconfig_busy     : in  std_logic;
         reconfig_write    : in  std_logic;
         reconfig_done     : in  std_logic;
         tx_digitalreset   : out std_logic;
         rx_digitalreset   : out std_logic;
         rx_analogreset    : out std_logic;
         done              : out std_logic
   );
   end component;

   component cpri
   generic (
      INCLUDE_RX_EX_DELAY   : in boolean;
      INCLUDE_TX_EX_DELAY   : in boolean;
      INCLUDE_8b10b         : in boolean;
      INCLUDE_CPU_SYNC      : in boolean;
      INCLUDE_PHY_LOOP      : in boolean;
      SYNC_MODE             : in integer;
      INCLUDE_PRBS          : in boolean;
      INCLUDE_MAP           : in boolean;
      SYNC_MAP              : in boolean;
      INCLUDE_MAC           : in boolean;
      INCLUDE_HDLC          : in boolean;
      INCLUDE_CAL           : in boolean;
      WIDTH_MAP_RX_ADDR     : in integer;
      WIDTH_MAP_TX_ADDR     : in integer;
      WIDTH_RX_BUF          : in integer;
      WIDTH_N_MAP           : in integer;
      WIDTH_K               : in integer;
      WIDTH_ETH_BUF         : in integer;
      WIDTH_ETH_BLOCK       : in integer;
      WIDTH_HDLC_BUF        : in integer;
      WIDTH_HDLC_BLOCK      : in integer;
      WIDTH_RX              : in integer;
      N_MAP                 : in integer;
      LINERATE              : in integer;
      DEVICE                : in integer;
      MAP_MODE              : in integer;
      INCLUDE_VSS           : in boolean);
   port (
      clk                   : in  std_logic;
      reset_rx              : in  std_logic;
      reset_tx              : in  std_logic;
      config_reset          : in  std_logic;
      clk_ex_delay          : in  std_logic;
      reset_ex_delay        : in  std_logic;
      hw_reset_assert       : in  std_logic;
      hw_reset_req          : out std_logic;

      rate                  : in  std_logic_vector(4 downto 0);
      int_datarate_en       : in  std_logic;
      int_datarate_set      : out std_logic_vector(4 downto 0);

      cpu_clk               : in  std_logic;
      cpu_reset             : in  std_logic;
      cpu_address           : in  std_logic_vector(15 downto 0);
      cpu_byte_en           : in  std_logic_vector(3 downto 0);
      cpu_wr_data           : in  std_logic_vector(31 downto 0);
      cpu_rd_data           : out std_logic_vector(31 downto 0);
      cpu_read              : in  std_logic;
      cpu_write             : in  std_logic;
      cpu_select            : in  std_logic;
      cpu_ack               : out std_logic;
      cpu_intr              : out std_logic;
      cpu_intr_vector       : out std_logic_vector(4 downto 0);

      cpri_map_rx_clk       : in  std_logic_vector(23 downto 0);
      cpri_map_rx_reset     : in  std_logic_vector(23 downto 0);
      cpri_map_rx_read      : in  std_logic_vector(23 downto 0);
      cpri_map_rx_resync    : in  std_logic_vector(23 downto 0);
      cpri_map_rx_data      : out std_logic_vector(767 downto 0);
      cpri_map_rx_en        : out std_logic_vector(23 downto 0);
      cpri_map_rx_start     : out std_logic_vector(23 downto 0);
      cpri_map_rx_ready     : out std_logic_vector(23 downto 0);
      cpri_map_rx_overflow  : out std_logic_vector(23 downto 0);
      cpri_map_rx_underflow : out std_logic_vector(23 downto 0);
      
      cpri_map_tx_clk       : in  std_logic_vector(23 downto 0);
      cpri_map_tx_reset     : in  std_logic_vector(23 downto 0);
      cpri_map_tx_write     : in  std_logic_vector(23 downto 0);
      cpri_map_tx_resync    : in  std_logic_vector(23 downto 0);
      cpri_map_tx_data      : in  std_logic_vector(767 downto 0);
      cpri_map_tx_en        : out std_logic_vector(23 downto 0);
      cpri_map_tx_ready     : out std_logic_vector(23 downto 0);
      cpri_map_tx_overflow  : out std_logic_vector(23 downto 0);
      cpri_map_tx_underflow : out std_logic_vector(23 downto 0);
      
      cpri_rx_aux_data      : out std_logic_vector(31 downto 0);

      cpri_tx_aux_data      : in  std_logic_vector(31 downto 0);
      cpri_tx_aux_mask      : in  std_logic_vector(31 downto 0);

      cpri_rx_sync_state    : out std_logic;
      cpri_rx_start         : out std_logic;
      cpri_rx_rfp           : out std_logic;
      cpri_rx_hfp           : out std_logic;
      cpri_rx_bfn           : out std_logic_vector(11 downto 0);
      cpri_rx_hfn           : out std_logic_vector(7 downto 0);
      cpri_rx_seq           : out std_logic_vector(5 downto 0);
      cpri_rx_x             : out std_logic_vector(7 downto 0);
      cpri_rx_k             : out std_logic_vector(WIDTH_K-1 downto 0);

      cpri_tx_sync_rfp      : in  std_logic;
      cpri_tx_start         : out std_logic;
      cpri_tx_rfp           : out std_logic;
      cpri_tx_hfp           : out std_logic;
      cpri_tx_bfn           : out std_logic_vector(11 downto 0);
      cpri_tx_hfn           : out std_logic_vector(7 downto 0);
      cpri_tx_seq           : out std_logic_vector(5 downto 0);
      cpri_tx_x             : out std_logic_vector(7 downto 0);
      cpri_tx_k             : out std_logic_vector(WIDTH_K-1 downto 0);
      cpri_tx_error         : out std_logic;

      cpri_rx_state         : out std_logic_vector(1 downto 0);
      cpri_rx_cnt_sync      : out std_logic_vector(2 downto 0);
      cpri_rx_freq_alarm    : out std_logic;
      cpri_rx_bfn_state     : out std_logic;
      cpri_rx_hfn_state     : out std_logic;
      cpri_rx_lcv           : out std_logic_vector(2 downto 0);
      cpri_rx_los           : out std_logic;

      serdes_rx_clk         : in  std_logic;
      serdes_rx_reset       : in  std_logic;
      serdes_rx_los         : in  std_logic;
      serdes_rx_data        : in  std_logic_vector(10*WIDTH_RX-1 downto 0);
      serdes_rx_align_en    : out std_logic;
      serdes_rx_align_delay : in  std_logic_vector(5 downto 0);
      
      serdes_width          : in  std_logic_vector(1 downto 0);
      serdes_tx_clk         : in  std_logic;
      serdes_tx_reset       : in  std_logic;
      serdes_tx_data        : out std_logic_vector(79 downto 0);
      serdes_tx_delay       : out std_logic_vector(5 downto 0);   
      cpri_mii_txclk        : out std_logic;
      cpri_mii_txrd         : out std_logic;
      cpri_mii_txen         : in  std_logic;
      cpri_mii_txer         : in  std_logic;
      cpri_mii_txd          : in  std_logic_vector(3 downto 0);
      cpri_mii_rxclk        : out std_logic;
      cpri_mii_rxwr         : out std_logic;      
      cpri_mii_rxdv         : out std_logic;
      cpri_mii_rxer         : out std_logic;
      cpri_mii_rxd          : out std_logic_vector(3 downto 0);
      tx_bitslip            : out std_logic_vector(6 downto 0);
      bitslipdetect         : in  std_logic_vector(6 downto 0);
      syncstatus            : in  std_logic_vector(3 downto 0);
      phy_ex_delay_period   : out std_logic_vector(8 downto 0);
      phy_rx_ex_buf_delay   : in  std_logic_vector(31 downto 0);
      phy_tx_ex_buf_delay   : in  std_logic_vector(31 downto 0);
      phy_rx_ex_buf_valid   : in  std_logic;
      phy_tx_ex_buf_valid   : in  std_logic;
      phy_tx_buf_delay      : in  std_logic_vector(4 downto 0);
      phy_rx_buf_delay      : in  std_logic_vector(WIDTH_RX_BUF downto 0);
      phy_rx_buf_resync     : in  std_logic;
      phy_tx_pcs_clk        : in  std_logic;
      phy_rx_pma_clk        : in  std_logic;
      rx_buf_resync_cpu     : out std_logic
   );
   end component;

   component cpri2
   generic (
      INCLUDE_RX_EX_DELAY   : in boolean;
      INCLUDE_TX_EX_DELAY   : in boolean;
      INCLUDE_8b10b         : in boolean;
      INCLUDE_CPU_SYNC      : in boolean;
      INCLUDE_PHY_LOOP      : in boolean;
      SYNC_MODE             : in integer;
      INCLUDE_PRBS          : in boolean;
      INCLUDE_MAP           : in boolean;
      SYNC_MAP              : in boolean;
      INCLUDE_MAC           : in boolean;
      INCLUDE_HDLC          : in boolean;
      INCLUDE_CAL           : in boolean;
      WIDTH_MAP_RX_ADDR     : in integer;
      WIDTH_MAP_TX_ADDR     : in integer;
      WIDTH_RX_BUF          : in integer;
      WIDTH_N_MAP           : in integer;
      WIDTH_K               : in integer;
      WIDTH_ETH_BUF         : in integer;
      WIDTH_ETH_BLOCK       : in integer;
      WIDTH_HDLC_BUF        : in integer;
      WIDTH_HDLC_BLOCK      : in integer;
      WIDTH_RX              : in integer;
      N_MAP                 : in integer;
      LINERATE              : in integer;
      DEVICE                : in integer;
      MAP_MODE              : in integer;
      INCLUDE_VSS           : in boolean);
   port (
      clk                   : in  std_logic;
      reset_rx              : in  std_logic;
      reset_tx              : in  std_logic;
      config_reset          : in  std_logic;
      clk_ex_delay          : in  std_logic;
      reset_ex_delay        : in  std_logic;
      hw_reset_assert       : in  std_logic;
      hw_reset_req          : out std_logic;

      rate                  : in  std_logic_vector(4 downto 0);
      int_datarate_en       : in  std_logic;
      int_datarate_set      : out std_logic_vector(4 downto 0);

      cpu_clk               : in  std_logic;
      cpu_reset             : in  std_logic;
      cpu_address           : in  std_logic_vector(15 downto 0);
      cpu_byte_en           : in  std_logic_vector(3 downto 0);
      cpu_wr_data           : in  std_logic_vector(31 downto 0);
      cpu_rd_data           : out std_logic_vector(31 downto 0);
      cpu_read              : in  std_logic;
      cpu_write             : in  std_logic;
      cpu_select            : in  std_logic;
      cpu_ack               : out std_logic;
      cpu_intr              : out std_logic;
      cpu_intr_vector       : out std_logic_vector(4 downto 0);

      cpri_map_rx_clk       : in  std_logic_vector(23 downto 0);
      cpri_map_rx_reset     : in  std_logic_vector(23 downto 0);
      cpri_map_rx_read      : in  std_logic_vector(23 downto 0);
      cpri_map_rx_resync    : in  std_logic_vector(23 downto 0);
      cpri_map_rx_data      : out std_logic_vector(767 downto 0);
      cpri_map_rx_en        : out std_logic_vector(23 downto 0);
      cpri_map_rx_start     : out std_logic_vector(23 downto 0);
      cpri_map_rx_ready     : out std_logic_vector(23 downto 0);
      cpri_map_rx_overflow  : out std_logic_vector(23 downto 0);
      cpri_map_rx_underflow : out std_logic_vector(23 downto 0);
      
      cpri_map_tx_clk       : in  std_logic_vector(23 downto 0);
      cpri_map_tx_reset     : in  std_logic_vector(23 downto 0);
      cpri_map_tx_write     : in  std_logic_vector(23 downto 0);
      cpri_map_tx_resync    : in  std_logic_vector(23 downto 0);
      cpri_map_tx_data      : in  std_logic_vector(767 downto 0);
      cpri_map_tx_en        : out std_logic_vector(23 downto 0);
      cpri_map_tx_ready     : out std_logic_vector(23 downto 0);
      cpri_map_tx_overflow  : out std_logic_vector(23 downto 0);
      cpri_map_tx_underflow : out std_logic_vector(23 downto 0);
      
      cpri_rx_aux_data      : out std_logic_vector(31 downto 0);

      cpri_tx_aux_data      : in  std_logic_vector(31 downto 0);
      cpri_tx_aux_mask      : in  std_logic_vector(31 downto 0);

      cpri_rx_sync_state    : out std_logic;
      cpri_rx_start         : out std_logic;
      cpri_rx_rfp           : out std_logic;
      cpri_rx_hfp           : out std_logic;
      cpri_rx_bfn           : out std_logic_vector(11 downto 0);
      cpri_rx_hfn           : out std_logic_vector(7 downto 0);
      cpri_rx_seq           : out std_logic_vector(5 downto 0);
      cpri_rx_x             : out std_logic_vector(7 downto 0);
      cpri_rx_k             : out std_logic_vector(WIDTH_K-1 downto 0);

      cpri_tx_sync_rfp      : in  std_logic;
      cpri_tx_start         : out std_logic;
      cpri_tx_rfp           : out std_logic;
      cpri_tx_hfp           : out std_logic;
      cpri_tx_bfn           : out std_logic_vector(11 downto 0);
      cpri_tx_hfn           : out std_logic_vector(7 downto 0);
      cpri_tx_seq           : out std_logic_vector(5 downto 0);
      cpri_tx_x             : out std_logic_vector(7 downto 0);
      cpri_tx_k             : out std_logic_vector(WIDTH_K-1 downto 0);
      cpri_tx_error         : out std_logic;

      cpri_rx_state         : out std_logic_vector(1 downto 0);
      cpri_rx_cnt_sync      : out std_logic_vector(2 downto 0);
      cpri_rx_freq_alarm    : out std_logic;
      cpri_rx_bfn_state     : out std_logic;
      cpri_rx_hfn_state     : out std_logic;
      cpri_rx_lcv           : out std_logic_vector(2 downto 0);
      cpri_rx_los           : out std_logic;

      serdes_rx_clk         : in  std_logic;
      serdes_rx_reset       : in  std_logic;
      serdes_rx_los         : in  std_logic;
      serdes_rx_data        : in  std_logic_vector(10*WIDTH_RX-1 downto 0);
      serdes_rx_align_en    : out std_logic;
      serdes_rx_align_delay : in  std_logic_vector(5 downto 0);
      
      serdes_width          : in  std_logic_vector(1 downto 0);
      serdes_tx_clk         : in  std_logic;
      serdes_tx_reset       : in  std_logic;
      serdes_tx_data        : out std_logic_vector(79 downto 0);
      serdes_tx_delay       : out std_logic_vector(5 downto 0);   
      cpri_mii_txclk        : out std_logic;
      cpri_mii_txrd         : out std_logic;
      cpri_mii_txen         : in  std_logic;
      cpri_mii_txer         : in  std_logic;
      cpri_mii_txd          : in  std_logic_vector(3 downto 0);
      cpri_mii_rxclk        : out std_logic;
      cpri_mii_rxwr         : out std_logic;      
      cpri_mii_rxdv         : out std_logic;
      cpri_mii_rxer         : out std_logic;
      cpri_mii_rxd          : out std_logic_vector(3 downto 0);
      tx_bitslip            : out std_logic_vector(6 downto 0);
      bitslipdetect         : in  std_logic_vector(6 downto 0);
      syncstatus            : in  std_logic_vector(3 downto 0);
      phy_ex_delay_period   : out std_logic_vector(8 downto 0);
      phy_rx_ex_buf_delay   : in  std_logic_vector(31 downto 0);
      phy_tx_ex_buf_delay   : in  std_logic_vector(31 downto 0);
      phy_rx_ex_buf_valid   : in  std_logic;
      phy_tx_ex_buf_valid   : in  std_logic;
      phy_tx_buf_delay      : in  std_logic_vector(4 downto 0);
      phy_rx_buf_delay      : in  std_logic_vector(WIDTH_RX_BUF downto 0);
      phy_rx_buf_resync     : in  std_logic;
      phy_tx_pcs_clk        : in  std_logic;
      phy_rx_pma_clk        : in  std_logic;
      rx_buf_resync_cpu     : out std_logic
   );
   end component;

   component cpri3
   generic (
      INCLUDE_RX_EX_DELAY   : in boolean;
      INCLUDE_TX_EX_DELAY   : in boolean;
      INCLUDE_8b10b         : in boolean;
      INCLUDE_CPU_SYNC      : in boolean;
      INCLUDE_PHY_LOOP      : in boolean;
      SYNC_MODE             : in integer;
      INCLUDE_PRBS          : in boolean;
      INCLUDE_MAP           : in boolean;
      SYNC_MAP              : in boolean;
      INCLUDE_MAC           : in boolean;
      INCLUDE_HDLC          : in boolean;
      INCLUDE_CAL           : in boolean;
      WIDTH_MAP_RX_ADDR     : in integer;
      WIDTH_MAP_TX_ADDR     : in integer;
      WIDTH_RX_BUF          : in integer;
      WIDTH_N_MAP           : in integer;
      WIDTH_K               : in integer;
      WIDTH_ETH_BUF         : in integer;
      WIDTH_ETH_BLOCK       : in integer;
      WIDTH_HDLC_BUF        : in integer;
      WIDTH_HDLC_BLOCK      : in integer;
      WIDTH_RX              : in integer;
      N_MAP                 : in integer;
      LINERATE              : in integer;
      DEVICE                : in integer;
      MAP_MODE              : in integer;
      INCLUDE_VSS           : in boolean);
   port (
      clk                   : in  std_logic;
      reset_rx              : in  std_logic;
      reset_tx              : in  std_logic;
      config_reset          : in  std_logic;
      clk_ex_delay          : in  std_logic;
      reset_ex_delay        : in  std_logic;
      hw_reset_assert       : in  std_logic;
      hw_reset_req          : out std_logic;

      rate                  : in  std_logic_vector(4 downto 0);
      int_datarate_en       : in  std_logic;
      int_datarate_set      : out std_logic_vector(4 downto 0);

      cpu_clk               : in  std_logic;
      cpu_reset             : in  std_logic;
      cpu_address           : in  std_logic_vector(15 downto 0);
      cpu_byte_en           : in  std_logic_vector(3 downto 0);
      cpu_wr_data           : in  std_logic_vector(31 downto 0);
      cpu_rd_data           : out std_logic_vector(31 downto 0);
      cpu_read              : in  std_logic;
      cpu_write             : in  std_logic;
      cpu_select            : in  std_logic;
      cpu_ack               : out std_logic;
      cpu_intr              : out std_logic;
      cpu_intr_vector       : out std_logic_vector(4 downto 0);

      cpri_map_rx_clk       : in  std_logic_vector(23 downto 0);
      cpri_map_rx_reset     : in  std_logic_vector(23 downto 0);
      cpri_map_rx_read      : in  std_logic_vector(23 downto 0);
      cpri_map_rx_resync    : in  std_logic_vector(23 downto 0);
      cpri_map_rx_data      : out std_logic_vector(767 downto 0);
      cpri_map_rx_en        : out std_logic_vector(23 downto 0);
      cpri_map_rx_start     : out std_logic_vector(23 downto 0);
      cpri_map_rx_ready     : out std_logic_vector(23 downto 0);
      cpri_map_rx_overflow  : out std_logic_vector(23 downto 0);
      cpri_map_rx_underflow : out std_logic_vector(23 downto 0);
      
      cpri_map_tx_clk       : in  std_logic_vector(23 downto 0);
      cpri_map_tx_reset     : in  std_logic_vector(23 downto 0);
      cpri_map_tx_write     : in  std_logic_vector(23 downto 0);
      cpri_map_tx_resync    : in  std_logic_vector(23 downto 0);
      cpri_map_tx_data      : in  std_logic_vector(767 downto 0);
      cpri_map_tx_en        : out std_logic_vector(23 downto 0);
      cpri_map_tx_ready     : out std_logic_vector(23 downto 0);
      cpri_map_tx_overflow  : out std_logic_vector(23 downto 0);
      cpri_map_tx_underflow : out std_logic_vector(23 downto 0);
      
      cpri_rx_aux_data      : out std_logic_vector(31 downto 0);

      cpri_tx_aux_data      : in  std_logic_vector(31 downto 0);
      cpri_tx_aux_mask      : in  std_logic_vector(31 downto 0);

      cpri_rx_sync_state    : out std_logic;
      cpri_rx_start         : out std_logic;
      cpri_rx_rfp           : out std_logic;
      cpri_rx_hfp           : out std_logic;
      cpri_rx_bfn           : out std_logic_vector(11 downto 0);
      cpri_rx_hfn           : out std_logic_vector(7 downto 0);
      cpri_rx_seq           : out std_logic_vector(5 downto 0);
      cpri_rx_x             : out std_logic_vector(7 downto 0);
      cpri_rx_k             : out std_logic_vector(WIDTH_K-1 downto 0);

      cpri_tx_sync_rfp      : in  std_logic;
      cpri_tx_start         : out std_logic;
      cpri_tx_rfp           : out std_logic;
      cpri_tx_hfp           : out std_logic;
      cpri_tx_bfn           : out std_logic_vector(11 downto 0);
      cpri_tx_hfn           : out std_logic_vector(7 downto 0);
      cpri_tx_seq           : out std_logic_vector(5 downto 0);
      cpri_tx_x             : out std_logic_vector(7 downto 0);
      cpri_tx_k             : out std_logic_vector(WIDTH_K-1 downto 0);
      cpri_tx_error         : out std_logic;

      cpri_rx_state         : out std_logic_vector(1 downto 0);
      cpri_rx_cnt_sync      : out std_logic_vector(2 downto 0);
      cpri_rx_freq_alarm    : out std_logic;
      cpri_rx_bfn_state     : out std_logic;
      cpri_rx_hfn_state     : out std_logic;
      cpri_rx_lcv           : out std_logic_vector(2 downto 0);
      cpri_rx_los           : out std_logic;

      serdes_rx_clk         : in  std_logic;
      serdes_rx_reset       : in  std_logic;
      serdes_rx_los         : in  std_logic;
      serdes_rx_data        : in  std_logic_vector(10*WIDTH_RX-1 downto 0);
      serdes_rx_align_en    : out std_logic;
      serdes_rx_align_delay : in  std_logic_vector(5 downto 0);
      
      serdes_width          : in  std_logic_vector(1 downto 0);
      serdes_tx_clk         : in  std_logic;
      serdes_tx_reset       : in  std_logic;
      serdes_tx_data        : out std_logic_vector(79 downto 0);
      serdes_tx_delay       : out std_logic_vector(5 downto 0);   
      cpri_mii_txclk        : out std_logic;
      cpri_mii_txrd         : out std_logic;
      cpri_mii_txen         : in  std_logic;
      cpri_mii_txer         : in  std_logic;
      cpri_mii_txd          : in  std_logic_vector(3 downto 0);
      cpri_mii_rxclk        : out std_logic;
      cpri_mii_rxwr         : out std_logic;      
      cpri_mii_rxdv         : out std_logic;
      cpri_mii_rxer         : out std_logic;
      cpri_mii_rxd          : out std_logic_vector(3 downto 0);
      tx_bitslip            : out std_logic_vector(6 downto 0);
      bitslipdetect         : in  std_logic_vector(6 downto 0);
      syncstatus            : in  std_logic_vector(3 downto 0);
      phy_ex_delay_period   : out std_logic_vector(8 downto 0);
      phy_rx_ex_buf_delay   : in  std_logic_vector(31 downto 0);
      phy_tx_ex_buf_delay   : in  std_logic_vector(31 downto 0);
      phy_rx_ex_buf_valid   : in  std_logic;
      phy_tx_ex_buf_valid   : in  std_logic;
      phy_tx_buf_delay      : in  std_logic_vector(4 downto 0);
      phy_rx_buf_delay      : in  std_logic_vector(WIDTH_RX_BUF downto 0);
      phy_rx_buf_resync     : in  std_logic;
      phy_tx_pcs_clk        : in  std_logic;
      phy_rx_pma_clk        : in  std_logic;
      rx_buf_resync_cpu     : out std_logic
   );
   end component;

   component arria2gx_614_m
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      tx_bitslipboundaryselect    : in  std_logic_vector(4 downto 0);
      tx_datainfull               : in  std_logic_vector(32 downto 0);
      tx_digitalreset             : in  std_logic_vector(0 downto 0);
      pll_locked                  : out std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(47 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0);
      tx_clkout                   : out std_logic_vector(0 downto 0);
      tx_dataout                  : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gx_1228_m
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      tx_bitslipboundaryselect    : in  std_logic_vector(4 downto 0);
      tx_datainfull               : in  std_logic_vector(32 downto 0);
      tx_digitalreset             : in  std_logic_vector(0 downto 0);
      pll_locked                  : out std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(47 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0);
      tx_clkout                   : out std_logic_vector(0 downto 0);
      tx_dataout                  : out std_logic_vector(0 downto 0)
   );
   end component;
    
   component arria2gx_2457_m
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      tx_bitslipboundaryselect    : in  std_logic_vector(4 downto 0);
      tx_datainfull               : in  std_logic_vector(32 downto 0);
      tx_digitalreset             : in  std_logic_vector(0 downto 0);
      pll_locked                  : out std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(47 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0);
      tx_clkout                   : out std_logic_vector(0 downto 0);
      tx_dataout                  : out std_logic_vector(0 downto 0)
   );
   end component;
  
   component arria2gx_3072_m
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      tx_bitslipboundaryselect    : in  std_logic_vector(4 downto 0);
      tx_datainfull               : in  std_logic_vector(32 downto 0);
      tx_digitalreset             : in  std_logic_vector(0 downto 0);
      pll_locked                  : out std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(47 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0);
      tx_clkout                   : out std_logic_vector(0 downto 0);
      tx_dataout                  : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gx_4915_m is
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      tx_bitslipboundaryselect    : in  std_logic_vector(4 downto 0);
      tx_datainfull               : in  std_logic_vector(32 downto 0);
      tx_digitalreset             : in  std_logic_vector(0 downto 0);
      pll_locked                  : out std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(47 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0);
      tx_clkout	                  : out std_logic_vector(0 downto 0);
      tx_dataout                  : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gx_6144_m is
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      tx_bitslipboundaryselect    : in  std_logic_vector(4 downto 0);
      tx_datainfull               : in  std_logic_vector(32 downto 0);
      tx_digitalreset             : in  std_logic_vector(0 downto 0);
      pll_locked                  : out std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(47 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0);
      tx_clkout	                  : out std_logic_vector(0 downto 0);
      tx_dataout                  : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gx_614_s_tx is
   generic (
      starting_channel_number  : natural := 0
   );
   port (
      cal_blk_clk              : in  std_logic;
      gxb_powerdown            : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk      : in  std_logic_vector(0 downto 0);
      reconfig_clk             : in  std_logic;
      reconfig_togxb           : in  std_logic_vector(3 downto 0);
      tx_bitslipboundaryselect : in  std_logic_vector(4 downto 0);
      tx_datainfull            : in  std_logic_vector(32 downto 0);
      tx_digitalreset          : in  std_logic_vector(0 downto 0);
      pll_locked               : out std_logic_vector(0 downto 0);
      reconfig_fromgxb         : out std_logic_vector(16 downto 0);
      tx_clkout                : out std_logic_vector(0 downto 0);
      tx_dataout               : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gx_614_s_rx is
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(47 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gx_1228_s_tx is
   generic (
      starting_channel_number  : natural := 0
   );
   port (
      cal_blk_clk              : in  std_logic;
      gxb_powerdown            : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk      : in  std_logic_vector(0 downto 0);
      reconfig_clk             : in  std_logic;
      reconfig_togxb           : in  std_logic_vector(3 downto 0);
      tx_bitslipboundaryselect : in  std_logic_vector(4 downto 0);
      tx_datainfull            : in  std_logic_vector(32 downto 0);
      tx_digitalreset          : in  std_logic_vector(0 downto 0);
      pll_locked               : out std_logic_vector(0 downto 0);
      reconfig_fromgxb         : out std_logic_vector(16 downto 0);
      tx_clkout                : out std_logic_vector(0 downto 0);
      tx_dataout               : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gx_1228_s_rx is
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(47 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gx_2457_s_tx is
   generic (
      starting_channel_number  : natural := 0
   );
   port (
      cal_blk_clk              : in  std_logic;
      gxb_powerdown            : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk      : in  std_logic_vector(0 downto 0);
      reconfig_clk             : in  std_logic;
      reconfig_togxb           : in  std_logic_vector(3 downto 0);
      tx_bitslipboundaryselect : in  std_logic_vector(4 downto 0);
      tx_datainfull            : in  std_logic_vector(32 downto 0);
      tx_digitalreset          : in  std_logic_vector(0 downto 0);
      pll_locked               : out std_logic_vector(0 downto 0);
      reconfig_fromgxb         : out std_logic_vector(16 downto 0);
      tx_clkout                : out std_logic_vector(0 downto 0);
      tx_dataout               : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gx_2457_s_rx is
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(47 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gx_3072_s_tx is
   generic (
      starting_channel_number  : natural := 0
   );
   port (
      cal_blk_clk              : in  std_logic;
      gxb_powerdown            : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk      : in  std_logic_vector(0 downto 0);
      reconfig_clk             : in  std_logic;
      reconfig_togxb           : in  std_logic_vector(3 downto 0);
      tx_bitslipboundaryselect : in  std_logic_vector(4 downto 0);
      tx_datainfull            : in  std_logic_vector(32 downto 0);
      tx_digitalreset          : in  std_logic_vector(0 downto 0);
      pll_locked               : out std_logic_vector(0 downto 0);
      reconfig_fromgxb         : out std_logic_vector(16 downto 0);
      tx_clkout                : out std_logic_vector(0 downto 0);
      tx_dataout               : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gx_3072_s_rx is
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(47 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gx_4915_s_tx is
   generic (
      starting_channel_number  : natural := 0
   );
   port (
      cal_blk_clk              : in  std_logic;
      gxb_powerdown            : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk      : in  std_logic_vector(0 downto 0);
      reconfig_clk             : in  std_logic;
      reconfig_togxb           : in  std_logic_vector(3 downto 0);
      tx_bitslipboundaryselect : in  std_logic_vector(4 downto 0);
      tx_datainfull            : in  std_logic_vector(32 downto 0);
      tx_digitalreset          : in  std_logic_vector(0 downto 0);
      pll_locked               : out std_logic_vector(0 downto 0);
      reconfig_fromgxb         : out std_logic_vector(16 downto 0);
      tx_clkout	               : out std_logic_vector(0 downto 0);
      tx_dataout               : out std_logic_vector(0 downto 0)
   );
   end component;
   
   component arria2gx_4915_s_rx is
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(47 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gx_6144_s_tx is
   generic (
      starting_channel_number  : natural := 0
   );
   port (
      cal_blk_clk              : in  std_logic;
      gxb_powerdown            : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk      : in  std_logic_vector(0 downto 0);
      reconfig_clk             : in  std_logic;
      reconfig_togxb           : in  std_logic_vector(3 downto 0);
      tx_bitslipboundaryselect : in  std_logic_vector(4 downto 0);
      tx_datainfull            : in  std_logic_vector(32 downto 0);
      tx_digitalreset          : in  std_logic_vector(0 downto 0);
      pll_locked               : out std_logic_vector(0 downto 0);
      reconfig_fromgxb         : out std_logic_vector(16 downto 0);
      tx_clkout	               : out std_logic_vector(0 downto 0);
      tx_dataout               : out std_logic_vector(0 downto 0)
   );
   end component;
   
   component arria2gx_6144_s_rx is
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(47 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0)
   );
   end component;
   
   component stratix4gx_614_m
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      tx_bitslipboundaryselect    : in  std_logic_vector(4 downto 0);
      tx_datainfull               : in  std_logic_vector(43 downto 0);
      tx_digitalreset             : in  std_logic_vector(0 downto 0);
      pll_locked                  : out std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(63 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0);
      tx_clkout                   : out std_logic_vector(0 downto 0);
      tx_dataout                  : out std_logic_vector(0 downto 0)
   );
   end component;

   component stratix4gx_1228_m
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      tx_bitslipboundaryselect    : in  std_logic_vector(4 downto 0);
      tx_datainfull               : in  std_logic_vector(43 downto 0);
      tx_digitalreset             : in  std_logic_vector(0 downto 0);
      pll_locked                  : out std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(63 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0);
      tx_clkout                   : out std_logic_vector(0 downto 0);
      tx_dataout                  : out std_logic_vector(0 downto 0)
   );
   end component;

   component stratix4gx_2457_m
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      tx_bitslipboundaryselect    : in  std_logic_vector(4 downto 0);
      tx_datainfull               : in  std_logic_vector(43 downto 0);
      tx_digitalreset             : in  std_logic_vector(0 downto 0);
      pll_locked                  : out std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(63 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0);
      tx_clkout                   : out std_logic_vector(0 downto 0);
      tx_dataout                  : out std_logic_vector(0 downto 0)
   );
   end component;

   component stratix4gx_3072_m
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      tx_bitslipboundaryselect    : in  std_logic_vector(4 downto 0);
      tx_datainfull               : in  std_logic_vector(43 downto 0);
      tx_digitalreset             : in  std_logic_vector(0 downto 0);
      pll_locked                  : out std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(63 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0);
      tx_clkout                   : out std_logic_vector(0 downto 0);
      tx_dataout                  : out std_logic_vector(0 downto 0)
   );
   end component;

   component stratix4gx_4915_m
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      tx_bitslipboundaryselect    : in  std_logic_vector(4 downto 0);
      tx_datainfull               : in  std_logic_vector(43 downto 0);
      tx_digitalreset             : in  std_logic_vector(0 downto 0);
      pll_locked                  : out std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(63 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0);
      tx_clkout                   : out std_logic_vector(0 downto 0);
      tx_dataout                  : out std_logic_vector(0 downto 0)
   );
   end component;

   component stratix4gx_6144_m
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      tx_bitslipboundaryselect    : in  std_logic_vector(4 downto 0);
      tx_datainfull               : in  std_logic_vector(43 downto 0);
      tx_digitalreset             : in  std_logic_vector(0 downto 0);
      pll_locked                  : out std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(63 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0);
      tx_clkout                   : out std_logic_vector(0 downto 0);
      tx_dataout                  : out std_logic_vector(0 downto 0)
   );
   end component;

   component stratix4gx_614_s_tx is
   generic (
      starting_channel_number  : natural := 0
   );
   port (
      cal_blk_clk              : in  std_logic;
      gxb_powerdown            : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk      : in  std_logic_vector(0 downto 0);
      reconfig_clk             : in  std_logic;
      reconfig_togxb           : in  std_logic_vector(3 downto 0);
      tx_bitslipboundaryselect : in  std_logic_vector(4 downto 0);
      tx_datainfull            : in  std_logic_vector(43 downto 0);
      tx_digitalreset          : in  std_logic_vector(0 downto 0);
      pll_locked               : out std_logic_vector(0 downto 0);
      reconfig_fromgxb         : out std_logic_vector(16 downto 0);
      tx_clkout                : out std_logic_vector(0 downto 0);
      tx_dataout               : out std_logic_vector(0 downto 0)
   );
   end component;

   component stratix4gx_614_s_rx is
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(63 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0)
   );
   end component;

   component stratix4gx_1228_s_tx is
   generic (
      starting_channel_number  : natural := 0
   );
   port (
      cal_blk_clk              : in  std_logic;
      gxb_powerdown            : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk      : in  std_logic_vector(0 downto 0);
      reconfig_clk             : in  std_logic;
      reconfig_togxb           : in  std_logic_vector(3 downto 0);
      tx_bitslipboundaryselect : in  std_logic_vector(4 downto 0);
      tx_datainfull            : in  std_logic_vector(43 downto 0);
      tx_digitalreset          : in  std_logic_vector(0 downto 0);
      pll_locked               : out std_logic_vector(0 downto 0);
      reconfig_fromgxb         : out std_logic_vector(16 downto 0);
      tx_clkout                : out std_logic_vector(0 downto 0);
      tx_dataout               : out std_logic_vector(0 downto 0)
   );
   end component;

   component stratix4gx_1228_s_rx is
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(63 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0)
   );
   end component;

   component stratix4gx_2457_s_tx is
   generic (
      starting_channel_number  : natural := 0
   );
   port (
      cal_blk_clk              : in  std_logic;
      gxb_powerdown            : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk      : in  std_logic_vector(0 downto 0);
      reconfig_clk             : in  std_logic;
      reconfig_togxb           : in  std_logic_vector(3 downto 0);
      tx_bitslipboundaryselect : in  std_logic_vector(4 downto 0);
      tx_datainfull            : in  std_logic_vector(43 downto 0);
      tx_digitalreset          : in  std_logic_vector(0 downto 0);
      pll_locked               : out std_logic_vector(0 downto 0);
      reconfig_fromgxb         : out std_logic_vector(16 downto 0);
      tx_clkout                : out std_logic_vector(0 downto 0);
      tx_dataout               : out std_logic_vector(0 downto 0)
   );
   end component;

   component stratix4gx_2457_s_rx is
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(63 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0)
   );
   end component;

   component stratix4gx_3072_s_tx is
   generic (
      starting_channel_number  : natural := 0
   );
   port (
      cal_blk_clk              : in  std_logic;
      gxb_powerdown            : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk      : in  std_logic_vector(0 downto 0);
      reconfig_clk             : in  std_logic;
      reconfig_togxb           : in  std_logic_vector(3 downto 0);
      tx_bitslipboundaryselect : in  std_logic_vector(4 downto 0);
      tx_datainfull            : in  std_logic_vector(43 downto 0);
      tx_digitalreset          : in  std_logic_vector(0 downto 0);
      pll_locked               : out std_logic_vector(0 downto 0);
      reconfig_fromgxb         : out std_logic_vector(16 downto 0);
      tx_clkout                : out std_logic_vector(0 downto 0);
      tx_dataout               : out std_logic_vector(0 downto 0)
   );
   end component;

   component stratix4gx_3072_s_rx is
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(63 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0)
   );
   end component;

   component stratix4gx_4915_s_tx is
   generic (
      starting_channel_number  : natural := 0
   );
   port (
      cal_blk_clk              : in  std_logic;
      gxb_powerdown            : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk      : in  std_logic_vector(0 downto 0);
      reconfig_clk             : in  std_logic;
      reconfig_togxb           : in  std_logic_vector(3 downto 0);
      tx_bitslipboundaryselect : in  std_logic_vector(4 downto 0);
      tx_datainfull            : in  std_logic_vector(43 downto 0);
      tx_digitalreset          : in  std_logic_vector(0 downto 0);
      pll_locked               : out std_logic_vector(0 downto 0);
      reconfig_fromgxb         : out std_logic_vector(16 downto 0);
      tx_clkout                : out std_logic_vector(0 downto 0);
      tx_dataout               : out std_logic_vector(0 downto 0)
   );
   end component;

   component stratix4gx_4915_s_rx is
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(63 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0)
   );
   end component;

   component stratix4gx_6144_s_tx is
   generic (
      starting_channel_number  : natural := 0
   );
   port (
      cal_blk_clk              : in  std_logic;
      gxb_powerdown            : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk      : in  std_logic_vector(0 downto 0);
      reconfig_clk             : in  std_logic;
      reconfig_togxb           : in  std_logic_vector(3 downto 0);
      tx_bitslipboundaryselect : in  std_logic_vector(4 downto 0);
      tx_datainfull            : in  std_logic_vector(43 downto 0);
      tx_digitalreset          : in  std_logic_vector(0 downto 0);
      pll_locked               : out std_logic_vector(0 downto 0);
      reconfig_fromgxb         : out std_logic_vector(16 downto 0);
      tx_clkout                : out std_logic_vector(0 downto 0);
      tx_dataout               : out std_logic_vector(0 downto 0)
   );
   end component;

   component stratix4gx_6144_s_rx is
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(63 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0)
   );
   end component;
   
   component cyclone4gx_614_m is
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_areset                  : in  std_logic_vector(1 downto 0);
      pll_configupdate            : in  std_logic_vector(1 downto 0);
      pll_inclk                   : in  std_logic_vector(1 downto 0);
      pll_scanclk                 : in  std_logic_vector(1 downto 0);
      pll_scanclkena              : in  std_logic_vector(1 downto 0);
      pll_scandata                : in  std_logic_vector(1 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      tx_bitslipboundaryselect    : in  std_logic_vector(4 downto 0);
      tx_datainfull               : in  std_logic_vector(21 downto 0);
      tx_digitalreset             : in  std_logic_vector(0 downto 0);
      pll_locked                  : out std_logic_vector(1 downto 0);
      pll_reconfig_done           : out std_logic_vector(1 downto 0);
      pll_scandataout             : out std_logic_vector(1 downto 0);
      reconfig_fromgxb            : out std_logic_vector(4 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(31 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      tx_clkout                   : out std_logic_vector(0 downto 0);
      tx_dataout                  : out std_logic_vector(0 downto 0)
   );
   end component;
   
   component cyclone4gx_1228_m is
   generic (
      starting_channel_number       : natural := 0
   );
   port (
      cal_blk_clk                   : in  std_logic;
      gxb_powerdown                 : in  std_logic_vector(0 downto 0);
      pll_areset                    : in  std_logic_vector(1 downto 0);
      pll_configupdate              : in  std_logic_vector(1 downto 0);
      pll_inclk                     : in  std_logic_vector(1 downto 0);
      pll_scanclk                   : in  std_logic_vector(1 downto 0);
      pll_scanclkena                : in  std_logic_vector(1 downto 0);
      pll_scandata                  : in  std_logic_vector(1 downto 0);
      reconfig_clk                  : in  std_logic;
      reconfig_togxb                : in  std_logic_vector(3 downto 0);
      rx_analogreset                : in  std_logic_vector(0 downto 0);
      rx_datain                     : in  std_logic_vector(0 downto 0);
      rx_digitalreset               : in  std_logic_vector(0 downto 0);
      rx_enapatternalign            : in  std_logic_vector(0 downto 0);
      tx_bitslipboundaryselect      : in  std_logic_vector(4 downto 0);
      tx_datainfull                 : in  std_logic_vector(21 downto 0);
      tx_digitalreset               : in  std_logic_vector(0 downto 0);
      pll_locked                    : out std_logic_vector(1 downto 0);
      pll_reconfig_done             : out std_logic_vector(1 downto 0);
      pll_scandataout               : out std_logic_vector(1 downto 0);
      reconfig_fromgxb              : out std_logic_vector(4 downto 0);
      rx_bitslipboundaryselectout   : out std_logic_vector(4 downto 0);
      rx_clkout                     : out std_logic_vector(0 downto 0);
      rx_dataoutfull                : out std_logic_vector(31 downto 0);
      rx_freqlocked                 : out std_logic_vector(0 downto 0);
      tx_clkout                     : out std_logic_vector(0 downto 0);
      tx_dataout                    : out std_logic_vector(0 downto 0)
   );
   end component;
   
   component cyclone4gx_2457_m is
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_areset                  : in  std_logic_vector(1 downto 0);
      pll_configupdate            : in  std_logic_vector(1 downto 0);
      pll_inclk                   : in  std_logic_vector(1 downto 0);
      pll_scanclk                 : in  std_logic_vector(1 downto 0);
      pll_scanclkena              : in  std_logic_vector(1 downto 0);
      pll_scandata                : in  std_logic_vector(1 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      tx_bitslipboundaryselect    : in  std_logic_vector(4 downto 0);
      tx_datainfull               : in  std_logic_vector(21 downto 0);
      tx_digitalreset             : in  std_logic_vector(0 downto 0);
      pll_locked                  : out std_logic_vector(1 downto 0);
      pll_reconfig_done           : out std_logic_vector(1 downto 0);
      pll_scandataout             : out std_logic_vector(1 downto 0);
      reconfig_fromgxb            : out std_logic_vector(4 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(31 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      tx_clkout                   : out std_logic_vector(0 downto 0);
      tx_dataout                  : out std_logic_vector(0 downto 0)
   );
   end component;
   
   component cyclone4gx_3072_m is
   generic (
       starting_channel_number      : natural := 0
   );
   port (
      cal_blk_clk                   : in  std_logic;
      gxb_powerdown                 : in  std_logic_vector(0 downto 0);
      pll_areset                    : in  std_logic_vector(1 downto 0);
      pll_configupdate              : in  std_logic_vector(1 downto 0);
      pll_inclk                     : in  std_logic_vector(1 downto 0);
      pll_scanclk                   : in  std_logic_vector(1 downto 0);
      pll_scanclkena                : in  std_logic_vector(1 downto 0);
      pll_scandata                  : in  std_logic_vector(1 downto 0);
      reconfig_clk                  : in  std_logic;
      reconfig_togxb                : in  std_logic_vector(3 downto 0);
      rx_analogreset                : in  std_logic_vector(0 downto 0);
      rx_datain                     : in  std_logic_vector(0 downto 0);
      rx_digitalreset               : in  std_logic_vector(0 downto 0);
      rx_enapatternalign            : in  std_logic_vector(0 downto 0);
      tx_bitslipboundaryselect      : in  std_logic_vector(4 downto 0);
      tx_datainfull                 : in  std_logic_vector(21 downto 0);
      tx_digitalreset               : in  std_logic_vector(0 downto 0);
      pll_locked                    : out std_logic_vector(1 downto 0);
      pll_reconfig_done             : out std_logic_vector(1 downto 0);
      pll_scandataout               : out std_logic_vector(1 downto 0);
      reconfig_fromgxb              : out std_logic_vector(4 downto 0);
      rx_bitslipboundaryselectout   : out std_logic_vector(4 downto 0);
      rx_clkout                     : out std_logic_vector(0 downto 0);
      rx_dataoutfull                : out std_logic_vector(31 downto 0);
      rx_freqlocked                 : out std_logic_vector(0 downto 0);
      tx_clkout                     : out std_logic_vector(0 downto 0);
      tx_dataout                    : out std_logic_vector(0 downto 0)
   );
   end component;
   
   component cyclone4gx_614_s_tx is
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_areset                  : in  std_logic_vector(0 downto 0);
      pll_configupdate            : in  std_logic_vector(0 downto 0);
      pll_inclk                   : in  std_logic_vector(0 downto 0);
      pll_scanclk                 : in  std_logic_vector(0 downto 0);
      pll_scanclkena              : in  std_logic_vector(0 downto 0);
      pll_scandata                : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      tx_bitslipboundaryselect    : in  std_logic_vector(4 downto 0);
      tx_datainfull               : in  std_logic_vector(21 downto 0);
      tx_digitalreset             : in  std_logic_vector(0 downto 0);
      pll_locked                  : out std_logic_vector(0 downto 0);
      pll_reconfig_done           : out std_logic_vector(0 downto 0);
      pll_scandataout             : out std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(4 downto 0);
      tx_clkout                   : out std_logic_vector(0 downto 0);
      tx_dataout                  : out std_logic_vector(0 downto 0)
   );
   end component;

   component cyclone4gx_614_s_rx is
   generic (
      starting_channel_number       : natural := 0
   );
   port (
      cal_blk_clk                   : in  std_logic;
      gxb_powerdown                 : in  std_logic_vector(0 downto 0);
      pll_areset                    : in  std_logic_vector(0 downto 0);
      pll_configupdate              : in  std_logic_vector(0 downto 0);
      pll_inclk                     : in  std_logic_vector(0 downto 0);
      pll_scanclk                   : in  std_logic_vector(0 downto 0);
      pll_scanclkena                : in  std_logic_vector(0 downto 0);
      pll_scandata                  : in  std_logic_vector(0 downto 0);
      reconfig_clk                  : in  std_logic;
      reconfig_togxb                : in  std_logic_vector(3 downto 0);
      rx_analogreset                : in  std_logic_vector(0 downto 0);
      rx_datain                     : in  std_logic_vector(0 downto 0);
      rx_digitalreset               : in  std_logic_vector(0 downto 0);
      rx_enapatternalign            : in  std_logic_vector(0 downto 0);
      pll_locked                    : out std_logic_vector(0 downto 0);
      pll_reconfig_done             : out std_logic_vector(0 downto 0);
      pll_scandataout               : out std_logic_vector(0 downto 0);
      reconfig_fromgxb              : out std_logic_vector(4 downto 0);
      rx_bitslipboundaryselectout   : out std_logic_vector(4 downto 0);
      rx_clkout                     : out std_logic_vector(0 downto 0);
      rx_dataoutfull                : out std_logic_vector(31 downto 0);
      rx_freqlocked                 : out std_logic_vector(0 downto 0)
   );
   end component;
   
   component cyclone4gx_1228_s_tx is
   generic (
      starting_channel_number        : natural := 0
   );
   port (
      cal_blk_clk                    : in  std_logic;
      gxb_powerdown                  : in  std_logic_vector(0 downto 0);
      pll_areset                     : in  std_logic_vector(0 downto 0);
      pll_configupdate               : in  std_logic_vector(0 downto 0);
      pll_inclk                      : in  std_logic_vector(0 downto 0);
      pll_scanclk                    : in  std_logic_vector(0 downto 0);
      pll_scanclkena                 : in  std_logic_vector(0 downto 0);
      pll_scandata                   : in  std_logic_vector(0 downto 0);
      reconfig_clk                   : in  std_logic;
      reconfig_togxb                 : in  std_logic_vector(3 downto 0);
      tx_bitslipboundaryselect       : in  std_logic_vector(4 downto 0);
      tx_datainfull                  : in  std_logic_vector(21 downto 0);
      tx_digitalreset                : in  std_logic_vector(0 downto 0);
      pll_locked                     : out std_logic_vector(0 downto 0);
      pll_reconfig_done              : out std_logic_vector(0 downto 0);
      pll_scandataout                : out std_logic_vector(0 downto 0);
      reconfig_fromgxb               : out std_logic_vector(4 downto 0);
      tx_clkout                      : out std_logic_vector(0 downto 0);
      tx_dataout                     : out std_logic_vector(0 downto 0)
   );
   end component;
   
   component cyclone4gx_1228_s_rx is
   generic (
      starting_channel_number        : natural := 0
   );
   port (
      cal_blk_clk                    : in  std_logic; 
      gxb_powerdown                  : in  std_logic_vector(0 downto 0);
      pll_areset                     : in  std_logic_vector(0 downto 0);
      pll_configupdate               : in  std_logic_vector(0 downto 0);
      pll_inclk                      : in  std_logic_vector(0 downto 0);
      pll_scanclk                    : in  std_logic_vector(0 downto 0);
      pll_scanclkena                 : in  std_logic_vector(0 downto 0);
      pll_scandata                   : in  std_logic_vector(0 downto 0);
      reconfig_clk                   : in  std_logic;
      reconfig_togxb                 : in  std_logic_vector(3 downto 0);
      rx_analogreset                 : in  std_logic_vector(0 downto 0);
      rx_datain                      : in  std_logic_vector(0 downto 0);
      rx_digitalreset                : in  std_logic_vector(0 downto 0);
      rx_enapatternalign             : in  std_logic_vector(0 downto 0);
      pll_locked                     : out std_logic_vector(0 downto 0);
      pll_reconfig_done              : out std_logic_vector(0 downto 0);
      pll_scandataout                : out std_logic_vector(0 downto 0);
      reconfig_fromgxb               : out std_logic_vector(4 downto 0);
      rx_bitslipboundaryselectout    : out std_logic_vector(4 downto 0);
      rx_clkout                      : out std_logic_vector(0 downto 0);
      rx_dataoutfull                 : out std_logic_vector(31 downto 0);
      rx_freqlocked                  : out std_logic_vector(0 downto 0)
   );
   end component;
   
   component cyclone4gx_2457_s_tx is
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_areset                  : in  std_logic_vector(0 downto 0);
      pll_configupdate            : in  std_logic_vector(0 downto 0);
      pll_inclk                   : in  std_logic_vector(0 downto 0);
      pll_scanclk                 : in  std_logic_vector(0 downto 0);
      pll_scanclkena              : in  std_logic_vector(0 downto 0);
      pll_scandata                : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      tx_bitslipboundaryselect    : in  std_logic_vector(4 downto 0);
      tx_datainfull               : in  std_logic_vector(21 downto 0);
      tx_digitalreset             : in  std_logic_vector(0 downto 0);
      pll_locked                  : out std_logic_vector(0 downto 0);
      pll_reconfig_done           : out std_logic_vector(0 downto 0);
      pll_scandataout             : out std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(4 downto 0);
      tx_clkout                   : out std_logic_vector(0 downto 0);
      tx_dataout                  : out std_logic_vector(0 downto 0)
   );
   end component;

   component cyclone4gx_2457_s_rx is
   generic (
      starting_channel_number       : natural := 0
   );
   port (
      cal_blk_clk                   : in  std_logic;
      gxb_powerdown                 : in  std_logic_vector(0 downto 0);
      pll_areset                    : in  std_logic_vector(0 downto 0);
      pll_configupdate              : in  std_logic_vector(0 downto 0);
      pll_inclk                     : in  std_logic_vector(0 downto 0);
      pll_scanclk                   : in  std_logic_vector(0 downto 0);
      pll_scanclkena                : in  std_logic_vector(0 downto 0);
      pll_scandata                  : in  std_logic_vector(0 downto 0);
      reconfig_clk                  : in  std_logic;
      reconfig_togxb                : in  std_logic_vector(3 downto 0);
      rx_analogreset                : in  std_logic_vector(0 downto 0);
      rx_datain                     : in  std_logic_vector(0 downto 0);
      rx_digitalreset               : in  std_logic_vector(0 downto 0);
      rx_enapatternalign            : in  std_logic_vector(0 downto 0);
      pll_locked                    : out std_logic_vector(0 downto 0);
      pll_reconfig_done             : out std_logic_vector(0 downto 0);
      pll_scandataout               : out std_logic_vector(0 downto 0);
      reconfig_fromgxb              : out std_logic_vector(4 downto 0);
      rx_bitslipboundaryselectout   : out std_logic_vector(4 downto 0);
      rx_clkout                     : out std_logic_vector(0 downto 0);
      rx_dataoutfull                : out std_logic_vector(31 downto 0);
      rx_freqlocked                 : out std_logic_vector(0 downto 0)
   );
   end component;
   
   component cyclone4gx_3072_s_tx is
   generic (
      starting_channel_number        : natural := 0
   );
   port (
      cal_blk_clk                    : in  std_logic;
      gxb_powerdown                  : in  std_logic_vector(0 downto 0);
      pll_areset                     : in  std_logic_vector(0 downto 0);
      pll_configupdate               : in  std_logic_vector(0 downto 0);
      pll_inclk                      : in  std_logic_vector(0 downto 0);
      pll_scanclk                    : in  std_logic_vector(0 downto 0);
      pll_scanclkena                 : in  std_logic_vector(0 downto 0);
      pll_scandata                   : in  std_logic_vector(0 downto 0);
      reconfig_clk                   : in  std_logic;
      reconfig_togxb                 : in  std_logic_vector(3 downto 0);
      tx_bitslipboundaryselect       : in  std_logic_vector(4 downto 0);
      tx_datainfull                  : in  std_logic_vector(21 downto 0);
      tx_digitalreset                : in  std_logic_vector(0 downto 0);
      pll_locked                     : out std_logic_vector(0 downto 0);
      pll_reconfig_done              : out std_logic_vector(0 downto 0);
      pll_scandataout                : out std_logic_vector(0 downto 0);
      reconfig_fromgxb               : out std_logic_vector(4 downto 0);
      tx_clkout                      : out std_logic_vector(0 downto 0);
      tx_dataout                     : out std_logic_vector(0 downto 0)
   );
   end component;
   
   component cyclone4gx_3072_s_rx is
   generic (
      starting_channel_number        : natural := 0
   );
   port (
      cal_blk_clk                    : in  std_logic; 
      gxb_powerdown                  : in  std_logic_vector(0 downto 0);
      pll_areset                     : in  std_logic_vector(0 downto 0);
      pll_configupdate               : in  std_logic_vector(0 downto 0);
      pll_inclk                      : in  std_logic_vector(0 downto 0);
      pll_scanclk                    : in  std_logic_vector(0 downto 0);
      pll_scanclkena                 : in  std_logic_vector(0 downto 0);
      pll_scandata                   : in  std_logic_vector(0 downto 0);
      reconfig_clk                   : in  std_logic;
      reconfig_togxb                 : in  std_logic_vector(3 downto 0);
      rx_analogreset                 : in  std_logic_vector(0 downto 0);
      rx_datain                      : in  std_logic_vector(0 downto 0);
      rx_digitalreset                : in  std_logic_vector(0 downto 0);
      rx_enapatternalign             : in  std_logic_vector(0 downto 0);
      pll_locked                     : out std_logic_vector(0 downto 0);
      pll_reconfig_done              : out std_logic_vector(0 downto 0);
      pll_scandataout                : out std_logic_vector(0 downto 0);
      reconfig_fromgxb               : out std_logic_vector(4 downto 0);
      rx_bitslipboundaryselectout    : out std_logic_vector(4 downto 0);
      rx_clkout                      : out std_logic_vector(0 downto 0);
      rx_dataoutfull                 : out std_logic_vector(31 downto 0);
      rx_freqlocked                  : out std_logic_vector(0 downto 0)
   );
   end component;
   
   component arria2gz_614_m
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      tx_bitslipboundaryselect    : in  std_logic_vector(4 downto 0);
      tx_datainfull               : in  std_logic_vector(43 downto 0);
      tx_digitalreset             : in  std_logic_vector(0 downto 0);
      pll_locked                  : out std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(63 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0);
      tx_clkout                   : out std_logic_vector(0 downto 0);
      tx_dataout                  : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gz_1228_m
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      tx_bitslipboundaryselect    : in  std_logic_vector(4 downto 0);
      tx_datainfull               : in  std_logic_vector(43 downto 0);
      tx_digitalreset             : in  std_logic_vector(0 downto 0);
      pll_locked                  : out std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(63 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0);
      tx_clkout                   : out std_logic_vector(0 downto 0);
      tx_dataout                  : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gz_2457_m
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      tx_bitslipboundaryselect    : in  std_logic_vector(4 downto 0);
      tx_datainfull               : in  std_logic_vector(43 downto 0);
      tx_digitalreset             : in  std_logic_vector(0 downto 0);
      pll_locked                  : out std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(63 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0);
      tx_clkout                   : out std_logic_vector(0 downto 0);
      tx_dataout                  : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gz_3072_m
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      tx_bitslipboundaryselect    : in  std_logic_vector(4 downto 0);
      tx_datainfull               : in  std_logic_vector(43 downto 0);
      tx_digitalreset             : in  std_logic_vector(0 downto 0);
      pll_locked                  : out std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(63 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0);
      tx_clkout                   : out std_logic_vector(0 downto 0);
      tx_dataout                  : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gz_4915_m
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      tx_bitslipboundaryselect    : in  std_logic_vector(4 downto 0);
      tx_datainfull               : in  std_logic_vector(43 downto 0);
      tx_digitalreset             : in  std_logic_vector(0 downto 0);
      pll_locked                  : out std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(63 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0);
      tx_clkout                   : out std_logic_vector(0 downto 0);
      tx_dataout                  : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gz_6144_m
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      tx_bitslipboundaryselect    : in  std_logic_vector(4 downto 0);
      tx_datainfull               : in  std_logic_vector(43 downto 0);
      tx_digitalreset             : in  std_logic_vector(0 downto 0);
      pll_locked                  : out std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(63 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0);
      tx_clkout                   : out std_logic_vector(0 downto 0);
      tx_dataout                  : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gz_614_s_tx is
   generic (
      starting_channel_number  : natural := 0
   );
   port (
      cal_blk_clk              : in  std_logic;
      gxb_powerdown            : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk      : in  std_logic_vector(0 downto 0);
      reconfig_clk             : in  std_logic;
      reconfig_togxb           : in  std_logic_vector(3 downto 0);
      tx_bitslipboundaryselect : in  std_logic_vector(4 downto 0);
      tx_datainfull            : in  std_logic_vector(43 downto 0);
      tx_digitalreset          : in  std_logic_vector(0 downto 0);
      pll_locked               : out std_logic_vector(0 downto 0);
      reconfig_fromgxb         : out std_logic_vector(16 downto 0);
      tx_clkout                : out std_logic_vector(0 downto 0);
      tx_dataout               : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gz_614_s_rx is
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(63 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gz_1228_s_tx is
   generic (
      starting_channel_number  : natural := 0
   );
   port (
      cal_blk_clk              : in  std_logic;
      gxb_powerdown            : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk      : in  std_logic_vector(0 downto 0);
      reconfig_clk             : in  std_logic;
      reconfig_togxb           : in  std_logic_vector(3 downto 0);
      tx_bitslipboundaryselect : in  std_logic_vector(4 downto 0);
      tx_datainfull            : in  std_logic_vector(43 downto 0);
      tx_digitalreset          : in  std_logic_vector(0 downto 0);
      pll_locked               : out std_logic_vector(0 downto 0);
      reconfig_fromgxb         : out std_logic_vector(16 downto 0);
      tx_clkout                : out std_logic_vector(0 downto 0);
      tx_dataout               : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gz_1228_s_rx is
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(63 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gz_2457_s_tx is
   generic (
      starting_channel_number  : natural := 0
   );
   port (
      cal_blk_clk              : in  std_logic;
      gxb_powerdown            : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk      : in  std_logic_vector(0 downto 0);
      reconfig_clk             : in  std_logic;
      reconfig_togxb           : in  std_logic_vector(3 downto 0);
      tx_bitslipboundaryselect : in  std_logic_vector(4 downto 0);
      tx_datainfull            : in  std_logic_vector(43 downto 0);
      tx_digitalreset          : in  std_logic_vector(0 downto 0);
      pll_locked               : out std_logic_vector(0 downto 0);
      reconfig_fromgxb         : out std_logic_vector(16 downto 0);
      tx_clkout                : out std_logic_vector(0 downto 0);
      tx_dataout               : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gz_2457_s_rx is
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(63 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gz_3072_s_tx is
   generic (
      starting_channel_number  : natural := 0
   );
   port (
      cal_blk_clk              : in  std_logic;
      gxb_powerdown            : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk      : in  std_logic_vector(0 downto 0);
      reconfig_clk             : in  std_logic;
      reconfig_togxb           : in  std_logic_vector(3 downto 0);
      tx_bitslipboundaryselect : in  std_logic_vector(4 downto 0);
      tx_datainfull            : in  std_logic_vector(43 downto 0);
      tx_digitalreset          : in  std_logic_vector(0 downto 0);
      pll_locked               : out std_logic_vector(0 downto 0);
      reconfig_fromgxb         : out std_logic_vector(16 downto 0);
      tx_clkout                : out std_logic_vector(0 downto 0);
      tx_dataout               : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gz_3072_s_rx is
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(63 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gz_4915_s_tx is
   generic (
      starting_channel_number  : natural := 0
   );
   port (
      cal_blk_clk              : in  std_logic;
      gxb_powerdown            : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk      : in  std_logic_vector(0 downto 0);
      reconfig_clk             : in  std_logic;
      reconfig_togxb           : in  std_logic_vector(3 downto 0);
      tx_bitslipboundaryselect : in  std_logic_vector(4 downto 0);
      tx_datainfull            : in  std_logic_vector(43 downto 0);
      tx_digitalreset          : in  std_logic_vector(0 downto 0);
      pll_locked               : out std_logic_vector(0 downto 0);
      reconfig_fromgxb         : out std_logic_vector(16 downto 0);
      tx_clkout                : out std_logic_vector(0 downto 0);
      tx_dataout               : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gz_4915_s_rx is
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(63 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gz_6144_s_tx is
   generic (
      starting_channel_number  : natural := 0
   );
   port (
      cal_blk_clk              : in  std_logic;
      gxb_powerdown            : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk      : in  std_logic_vector(0 downto 0);
      reconfig_clk             : in  std_logic;
      reconfig_togxb           : in  std_logic_vector(3 downto 0);
      tx_bitslipboundaryselect : in  std_logic_vector(4 downto 0);
      tx_datainfull            : in  std_logic_vector(43 downto 0);
      tx_digitalreset          : in  std_logic_vector(0 downto 0);
      pll_locked               : out std_logic_vector(0 downto 0);
      reconfig_fromgxb         : out std_logic_vector(16 downto 0);
      tx_clkout                : out std_logic_vector(0 downto 0);
      tx_dataout               : out std_logic_vector(0 downto 0)
   );
   end component;

   component arria2gz_6144_s_rx is
   generic (
      starting_channel_number     : natural := 0
   );
   port (
      cal_blk_clk                 : in  std_logic;
      gxb_powerdown               : in  std_logic_vector(0 downto 0);
      pll_inclk_rx_cruclk         : in  std_logic_vector(0 downto 0);
      reconfig_clk                : in  std_logic;
      reconfig_togxb              : in  std_logic_vector(3 downto 0);
      rx_analogreset              : in  std_logic_vector(0 downto 0);
      rx_datain                   : in  std_logic_vector(0 downto 0);
      rx_digitalreset             : in  std_logic_vector(0 downto 0);
      rx_enapatternalign          : in  std_logic_vector(0 downto 0);
      reconfig_fromgxb            : out std_logic_vector(16 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      rx_dataoutfull              : out std_logic_vector(63 downto 0);
      rx_freqlocked               : out std_logic_vector(0 downto 0);
      rx_pll_locked               : out std_logic_vector(0 downto 0)
   );
   end component;
  
--------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------- signal declaration --------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------   
   signal cpu_wr_data                        : std_logic_vector(31 downto 0);
   signal cpu_select                         : std_logic;
   signal cpu_ack                            : std_logic;
   signal cpu_intr                           : std_logic;

   signal cpri_map_rx_clk                    : std_logic_vector(23 downto 0);
   signal cpri_map_rx_reset                  : std_logic_vector(23 downto 0);
   signal cpri_map_rx_read                   : std_logic_vector(23 downto 0);
   signal cpri_map_rx_data                   : std_logic_vector(767 downto 0);
   signal cpri_map_rx_start                  : std_logic_vector(23 downto 0);
   signal cpri_map_rx_resync                 : std_logic_vector(23 downto 0);
   signal cpri_map_rx_ready                  : std_logic_vector(23 downto 0);
   signal cpri_map_rx_en                     : std_logic_vector(23 downto 0);
   signal cpri_map_rx_underflow              : std_logic_vector(23 downto 0);
   signal cpri_map_rx_overflow               : std_logic_vector(23 downto 0);

   signal cpri_map_tx_clk                    : std_logic_vector(23 downto 0);
   signal cpri_map_tx_reset                  : std_logic_vector(23 downto 0);
   signal cpri_map_tx_write                  : std_logic_vector(23 downto 0);
   signal cpri_map_tx_data                   : std_logic_vector(767 downto 0);
   signal cpri_map_tx_ready                  : std_logic_vector(23 downto 0);
   signal cpri_map_tx_en                     : std_logic_vector(23 downto 0);
   signal cpri_map_tx_underflow              : std_logic_vector(23 downto 0);
   signal cpri_map_tx_overflow               : std_logic_vector(23 downto 0);
   signal cpri_map_tx_resync                 : std_logic_vector(23 downto 0);

   signal cpri_rx_start                      : std_logic;
   signal cpri_rx_sync_state                 : std_logic;
   signal cpri_rx_rfp                        : std_logic;
   signal cpri_rx_hfp                        : std_logic;
   signal cpri_rx_bfn                        : std_logic_vector(11 downto 0);
   signal cpri_rx_hfn                        : std_logic_vector(7 downto 0); 
   signal cpri_rx_seq                        : std_logic_vector(5 downto 0);
   signal cpri_rx_x                          : std_logic_vector(7 downto 0);    
   signal cpri_rx_k                          : std_logic_vector(WIDTH_K-1 downto 0);
  
   signal cpri_tx_start                      : std_logic;
   signal cpri_tx_rfp                        : std_logic;
   signal cpri_tx_hfp                        : std_logic;
   signal cpri_tx_bfn                        : std_logic_vector(11 downto 0);
   signal cpri_tx_hfn                        : std_logic_vector(7 downto 0); 
   signal cpri_tx_seq                        : std_logic_vector(5 downto 0);
   signal cpri_tx_x                          : std_logic_vector(7 downto 0);
   signal cpri_tx_k                          : std_logic_vector(WIDTH_K-1 downto 0);
   signal cpri_tx_error                      : std_logic;
    
   signal cpri_tx_sync_rfp                   : std_logic;
   signal cpri_tx_aux_data                   : std_logic_vector(63 downto 32);
   signal cpri_tx_aux_mask                   : std_logic_vector(31 downto 0); 
  
   signal cpri_rx_aux_data_tmp               : std_logic_vector(31 downto 0); 
  
   signal cpri_rx_state                      : std_logic_vector(1 downto 0);
   signal cpri_rx_cnt_sync                   : std_logic_vector(2 downto 0);
   signal cpri_rx_freq_alarm                 : std_logic;                   
   signal cpri_rx_bfn_state                  : std_logic;                   
   signal cpri_rx_hfn_state                  : std_logic;                   
   signal cpri_rx_lcv                        : std_logic_vector(2 downto 0);
   signal cpri_rx_los                        : std_logic;                    

   signal rate	                             : std_logic_vector(4 downto 0);

   signal tx_digitalreset                    : std_logic := '1';
   signal rx_digitalreset                    : std_logic := '1';
   signal rx_analogreset                     : std_logic := '1';
   signal rx_pll_locked                      : std_logic;
   signal pll_locked                         : std_logic;
   signal rx_freqlocked                      : std_logic;
   signal s_pll_reconfig_done                : std_logic_vector(1 downto 0) := (others => '0');
   
   signal tx_clkout                          : std_logic;
   signal rx_clkout                          : std_logic;
	
   signal rx_errdetect                       : std_logic_vector(3 downto 0);
   signal rx_disperr                         : std_logic_vector(3 downto 0);
   signal rx_syncstatus                      : std_logic_vector(3 downto 0);   

   signal rx_enapatternalign                 : std_logic:= '0';

   signal tx_datainfull                      : std_logic_vector(43 downto 0) := (others => '0');
   signal tx_datainfull_pl                   : std_logic_vector(43 downto 0) := (others => '0');
   signal tx_datainfull_pl2                  : std_logic_vector(43 downto 0) := (others => '0');
   signal tx_datainfull_pl3                  : std_logic_vector(43 downto 0) := (others => '0');
   signal rx_dataoutfull                     : std_logic_vector(63 downto 0) := (others => '0');

   signal serdes_width                       : std_logic_vector(1 downto 0);
   signal serdes_tx_clk                      : std_logic;
   signal serdes_tx_data                     : std_logic_vector(79 downto 0);
   signal serdes_tx_data_pl                  : std_logic_vector(79 downto 0);
   signal serdes_rx_clk                      : std_logic;
   signal serdes_rx_data                     : std_logic_vector(39 downto 0);

   signal cpri_clk                           : std_logic;

   signal tx_bitslipboundaryselect           : std_logic_vector (6 downto 0);
   signal rx_bitslipboundaryselectout        : std_logic_vector (6 downto 0);

   signal int_datarate_en                    : std_logic;
   signal int_datarate_set                   : std_logic_vector(4 downto 0);
   
   signal serdes_rx_align_en                 : std_logic;
   signal serdes_rx_align_en_sync1           : std_logic:= '0';
   ATTRIBUTE ALTERA_ATTRIBUTE OF serdes_rx_align_en_sync1 : SIGNAL IS
     "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS";
   signal serdes_rx_align_en_sync2           : std_logic:= '0';

   signal rx_digitalreset_sync               : std_logic := '1';
   signal tx_digitalreset_sync               : std_logic := '1';

   signal rx_digitalreset_cpri_clk_sync1     : std_logic := '1';
   ATTRIBUTE ALTERA_ATTRIBUTE OF rx_digitalreset_cpri_clk_sync1 : SIGNAL IS
     "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS";
   signal rx_digitalreset_cpri_clk_sync2     : std_logic := '1';

   signal tx_digitalreset_cpri_clk_sync1 : std_logic := '1';
   ATTRIBUTE ALTERA_ATTRIBUTE OF tx_digitalreset_cpri_clk_sync1 : SIGNAL IS
     "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS";
   signal tx_digitalreset_cpri_clk_sync2 : std_logic := '1'; 

   signal rx_digitalreset_serdes_txclk_sync1 : std_logic := '1';
   ATTRIBUTE ALTERA_ATTRIBUTE OF rx_digitalreset_serdes_txclk_sync1 : SIGNAL IS
     "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS";
   signal rx_digitalreset_serdes_txclk_sync2 : std_logic := '1';

   signal tx_digitalreset_serdes_txclk_sync1 : std_logic := '1';
   ATTRIBUTE ALTERA_ATTRIBUTE OF tx_digitalreset_serdes_txclk_sync1 : SIGNAL IS
     "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS";
   signal tx_digitalreset_serdes_txclk_sync2 : std_logic := '1';

   signal rx_digitalreset_serdes_rxclk_sync1 : std_logic := '1';
   ATTRIBUTE ALTERA_ATTRIBUTE OF rx_digitalreset_serdes_rxclk_sync1 : SIGNAL IS
     "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS";
   signal rx_digitalreset_serdes_rxclk_sync2 : std_logic := '1'; 

   signal int_datarate_set_tx_clkout_sync1 : std_logic_vector(4 downto 0);
   ATTRIBUTE ALTERA_ATTRIBUTE OF int_datarate_set_tx_clkout_sync1 : SIGNAL IS
     "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS";
   signal int_datarate_set_tx_clkout_sync2 : std_logic_vector(4 downto 0);

   signal int_datarate_set_rx_clkout_sync1 : std_logic_vector(4 downto 0);
   ATTRIBUTE ALTERA_ATTRIBUTE OF int_datarate_set_rx_clkout_sync1 : SIGNAL IS
     "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS";
   signal int_datarate_set_rx_clkout_sync2 : std_logic_vector(4 downto 0);

   signal tx_parallel_data                 : std_logic_vector(43 downto 0);
   signal tx_parallel_data_pl              : std_logic_vector(43 downto 0);
   signal tx_datak                         : std_logic_vector((3-((LINERATE/614)*3)) downto 0);
   signal tx_datak_pl                      : std_logic_vector((3-((LINERATE/614)*3)) downto 0);
   signal rx_parallel_data                 : std_logic_vector(63 downto 0);
   signal rx_datak                         : std_logic_vector((3-((LINERATE/614)*3)) downto 0);
   signal tx_ready                         : std_logic;
   signal rx_ready                         : std_logic;
   signal s_reset_done                     : std_logic :='0';

   signal ex_delay_period                  : std_logic_vector(8 downto 0);
   signal tx_ex_buf_delay                  : std_logic_vector(31 downto 0);
   signal tx_ex_buf_valid                  : std_logic;
   signal tx_buf_delay                     : std_logic_vector(4 downto 0);
   signal tx_buf_error                     : std_logic;
   signal tx_buf_underflow                 : std_logic;
   signal tx_buf_underflow_sync1           : std_logic;
   signal tx_buf_underflow_sync2           : std_logic;
   signal tx_buf_overflow                  : std_logic;
   signal tx_buf_overflow_sync1            : std_logic;
   signal tx_buf_overflow_sync2            : std_logic;
   signal tx_buf_resync                    : std_logic;
   signal rx_ex_buf_delay                  : std_logic_vector(31 downto 0);
   signal rx_ex_buf_valid                  : std_logic;
   signal rx_buf_delay                     : std_logic_vector(WIDTH_RX_BUF downto 0);
   signal rx_buf_error                     : std_logic;
   signal rx_buf_underflow                 : std_logic;
   signal rx_buf_underflow_sync1           : std_logic;
   signal rx_buf_underflow_sync2           : std_logic;
   signal rx_buf_overflow                  : std_logic;
   signal rx_buf_overflow_sync1            : std_logic;
   signal rx_buf_overflow_sync2            : std_logic;
   signal rx_buf_resync                    : std_logic;

   signal rx_buf_resync_cpu                : std_logic;

   signal reset_usr_pma_clk_sync1          : std_logic;
   signal reset_usr_pma_clk_sync2          : std_logic;
   signal phy_mgmt_write_temp              : std_logic;
   signal phy_mgmt_read_temp               : std_logic;
   signal phy_mgmt_waitrequest_temp        : std_logic;
   signal phy_mgmt_writedata_temp          : std_logic_vector(31 downto 0);
   signal phy_mgmt_address_temp            : std_logic_vector(11 downto 0);   
   signal data_width_pma                   : std_logic_vector(6 downto 0);

begin
---------------------------------------------------------------------------------------------------------------------
------------------------------------------ Port assignment ----------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------

   -- ALTGX Signals
   gxb_rx_errdetect        <= rx_errdetect;
   gxb_rx_disperr          <= rx_disperr;
   gxb_rx_pll_locked       <= rx_pll_locked;
   gxb_pll_locked          <= pll_locked;
   gxb_rx_freqlocked       <= rx_freqlocked;
   
   -- ALTPLL signals
   pll_reconfig_done       <= s_pll_reconfig_done;
   
   -- CPU Signals
   cpu_wr_data     <= cpu_writedata;
   cpu_select      <= cpu_read xor cpu_write;
   cpu_waitrequest <= cpu_select and not cpu_ack;       
   cpu_irq         <= cpu_intr;
   
   -- Auxiliary Rx Signals
   aux_rx_status_data <= cpri_rx_rfp & 
                         cpri_rx_start & 
                         cpri_rx_hfp & 
                         cpri_rx_bfn & 
                         cpri_rx_hfn & 
                         cpri_rx_x & 
                         cpri_rx_k & 
                         cpri_rx_seq & 
                         cpri_rx_sync_state & 
                         cpri_rx_aux_data_tmp;
   
   -- Auxiliary Tx Signals   
   aux_tx_status_data <= cpri_tx_error & 
                         cpri_tx_seq & 
                         cpri_tx_k & 
                         cpri_tx_x & 
                         cpri_tx_hfn & 
                         cpri_tx_bfn & 
                         cpri_tx_hfp & 
                         cpri_tx_start & 
                         cpri_tx_rfp;
   cpri_tx_sync_rfp <= aux_tx_mask_data(64);
   cpri_tx_aux_data <= aux_tx_mask_data(63 downto 32);
   cpri_tx_aux_mask <= aux_tx_mask_data(31 downto 0);
   
   -- CPRI Extended Rx Status Signals
   extended_rx_status_data <= cpri_rx_los & 
                              cpri_rx_lcv & 
                              cpri_rx_hfn_state & 
                              cpri_rx_bfn_state & 
                              cpri_rx_freq_alarm & 
                              cpri_rx_cnt_sync & 
                              cpri_rx_state;

   -- Rx Map Signals
   cpri_map_rx_clk    <= map23_rx_clk & map22_rx_clk & map21_rx_clk & map20_rx_clk & map19_rx_clk & 
                         map18_rx_clk & map17_rx_clk & map16_rx_clk & map15_rx_clk & map14_rx_clk & 
                         map13_rx_clk & map12_rx_clk & map11_rx_clk & map10_rx_clk & map9_rx_clk & 
                         map8_rx_clk & map7_rx_clk & map6_rx_clk & map5_rx_clk & map4_rx_clk & 
                         map3_rx_clk & map2_rx_clk & map1_rx_clk & map0_rx_clk;
   cpri_map_rx_reset  <= map23_rx_reset & map22_rx_reset & map21_rx_reset & map20_rx_reset & map19_rx_reset & 
                         map18_rx_reset & map17_rx_reset & map16_rx_reset & map15_rx_reset & map14_rx_reset & 
                         map13_rx_reset & map12_rx_reset & map11_rx_reset & map10_rx_reset & map9_rx_reset & 
                         map8_rx_reset & map7_rx_reset & map6_rx_reset & map5_rx_reset & map4_rx_reset & 
                         map3_rx_reset & map2_rx_reset & map1_rx_reset & map0_rx_reset;
   cpri_map_rx_read   <= map23_rx_ready & map22_rx_ready & map21_rx_ready & map20_rx_ready & map19_rx_ready & 
                         map18_rx_ready & map17_rx_ready & map16_rx_ready & map15_rx_ready & map14_rx_ready & 
                         map13_rx_ready & map12_rx_ready & map11_rx_ready & map10_rx_ready & map9_rx_ready & 
                         map8_rx_ready & map7_rx_ready & map6_rx_ready & map5_rx_ready & map4_rx_ready & 
                         map3_rx_ready & map2_rx_ready & map1_rx_ready & map0_rx_ready ;                       
   cpri_map_rx_resync <= map23_rx_resync & map22_rx_resync & map21_rx_resync & map20_rx_resync & map19_rx_resync &
                         map18_rx_resync & map17_rx_resync & map16_rx_resync & map15_rx_resync & map14_rx_resync &
                         map13_rx_resync & map12_rx_resync & map11_rx_resync & map10_rx_resync & map9_rx_resync &
                         map8_rx_resync & map7_rx_resync & map6_rx_resync & map5_rx_resync & map4_rx_resync & 
                         map3_rx_resync & map2_rx_resync & map1_rx_resync & map0_rx_resync; 

   map23_rx_data <= cpri_map_rx_data(767 downto 736);					   
   map22_rx_data <= cpri_map_rx_data(735 downto 704);
   map21_rx_data <= cpri_map_rx_data(703 downto 672);
   map20_rx_data <= cpri_map_rx_data(671 downto 640);
   map19_rx_data <= cpri_map_rx_data(639 downto 608);
   map18_rx_data <= cpri_map_rx_data(607 downto 576);
   map17_rx_data <= cpri_map_rx_data(575 downto 544);
   map16_rx_data <= cpri_map_rx_data(543 downto 512);	
   map15_rx_data <= cpri_map_rx_data(511 downto 480);
   map14_rx_data <= cpri_map_rx_data(479 downto 448);
   map13_rx_data <= cpri_map_rx_data(447 downto 416);
   map12_rx_data <= cpri_map_rx_data(415 downto 384);
   map11_rx_data <= cpri_map_rx_data(383 downto 352);
   map10_rx_data <= cpri_map_rx_data(351 downto 320);
   map9_rx_data  <= cpri_map_rx_data(319 downto 288);
   map8_rx_data  <= cpri_map_rx_data(287 downto 256);
   map7_rx_data  <= cpri_map_rx_data(255 downto 224);
   map6_rx_data  <= cpri_map_rx_data(223 downto 192);
   map5_rx_data  <= cpri_map_rx_data(191 downto 160);
   map4_rx_data  <= cpri_map_rx_data(159 downto 128);
   map3_rx_data  <= cpri_map_rx_data(127 downto 96);
   map2_rx_data  <= cpri_map_rx_data(95 downto 64);
   map1_rx_data  <= cpri_map_rx_data(63 downto 32);
   map0_rx_data  <= cpri_map_rx_data(31 downto 0);  

   map23_rx_start <= cpri_map_rx_start(23);					   
   map22_rx_start <= cpri_map_rx_start(22);
   map21_rx_start <= cpri_map_rx_start(21);
   map20_rx_start <= cpri_map_rx_start(20);
   map19_rx_start <= cpri_map_rx_start(19);
   map18_rx_start <= cpri_map_rx_start(18);
   map17_rx_start <= cpri_map_rx_start(17);
   map16_rx_start <= cpri_map_rx_start(16);	
   map15_rx_start <= cpri_map_rx_start(15);
   map14_rx_start <= cpri_map_rx_start(14);
   map13_rx_start <= cpri_map_rx_start(13);
   map12_rx_start <= cpri_map_rx_start(12);
   map11_rx_start <= cpri_map_rx_start(11);
   map10_rx_start <= cpri_map_rx_start(10);
   map9_rx_start  <= cpri_map_rx_start(9);
   map8_rx_start  <= cpri_map_rx_start(8);
   map7_rx_start  <= cpri_map_rx_start(7);
   map6_rx_start  <= cpri_map_rx_start(6);
   map5_rx_start  <= cpri_map_rx_start(5);
   map4_rx_start  <= cpri_map_rx_start(4);
   map3_rx_start  <= cpri_map_rx_start(3);
   map2_rx_start  <= cpri_map_rx_start(2);
   map1_rx_start  <= cpri_map_rx_start(1);
   map0_rx_start  <= cpri_map_rx_start(0);

   map23_rx_valid <= cpri_map_rx_ready(23);
   map22_rx_valid <= cpri_map_rx_ready(22);
   map21_rx_valid <= cpri_map_rx_ready(21);
   map20_rx_valid <= cpri_map_rx_ready(20);
   map19_rx_valid <= cpri_map_rx_ready(19);
   map18_rx_valid <= cpri_map_rx_ready(18);
   map17_rx_valid <= cpri_map_rx_ready(17);
   map16_rx_valid <= cpri_map_rx_ready(16);
   map15_rx_valid <= cpri_map_rx_ready(15);
   map14_rx_valid <= cpri_map_rx_ready(14);
   map13_rx_valid <= cpri_map_rx_ready(13);
   map12_rx_valid <= cpri_map_rx_ready(12);
   map11_rx_valid <= cpri_map_rx_ready(11);
   map10_rx_valid <= cpri_map_rx_ready(10);
   map9_rx_valid  <= cpri_map_rx_ready(9);
   map8_rx_valid  <= cpri_map_rx_ready(8);
   map7_rx_valid  <= cpri_map_rx_ready(7);
   map6_rx_valid  <= cpri_map_rx_ready(6);
   map5_rx_valid  <= cpri_map_rx_ready(5);
   map4_rx_valid  <= cpri_map_rx_ready(4);
   map3_rx_valid  <= cpri_map_rx_ready(3);
   map2_rx_valid  <= cpri_map_rx_ready(2);
   map1_rx_valid  <= cpri_map_rx_ready(1);
   map0_rx_valid  <= cpri_map_rx_ready(0);  
  
   map23_rx_status_data(0) <= cpri_map_rx_en(23);
   map23_rx_status_data(1) <= cpri_map_rx_underflow(23);
   map23_rx_status_data(2) <= cpri_map_rx_overflow(23);   
   map22_rx_status_data(0) <= cpri_map_rx_en(22);
   map22_rx_status_data(1) <= cpri_map_rx_underflow(22);
   map22_rx_status_data(2) <= cpri_map_rx_overflow(22);
   map21_rx_status_data(0) <= cpri_map_rx_en(21);
   map21_rx_status_data(1) <= cpri_map_rx_underflow(21);
   map21_rx_status_data(2) <= cpri_map_rx_overflow(21);						
   map20_rx_status_data(0) <= cpri_map_rx_en(20);
   map20_rx_status_data(1) <= cpri_map_rx_underflow(20);
   map20_rx_status_data(2) <= cpri_map_rx_overflow(20);
   map19_rx_status_data(0) <= cpri_map_rx_en(19);
   map19_rx_status_data(1) <= cpri_map_rx_underflow(19);
   map19_rx_status_data(2) <= cpri_map_rx_overflow(19);
   map18_rx_status_data(0) <= cpri_map_rx_en(18);
   map18_rx_status_data(1) <= cpri_map_rx_underflow(18);
   map18_rx_status_data(2) <= cpri_map_rx_overflow(18);
   map17_rx_status_data(0) <= cpri_map_rx_en(17);
   map17_rx_status_data(1) <= cpri_map_rx_underflow(17);
   map17_rx_status_data(2) <= cpri_map_rx_overflow(17);
   map16_rx_status_data(0) <= cpri_map_rx_en(16);
   map16_rx_status_data(1) <= cpri_map_rx_underflow(16);
   map16_rx_status_data(2) <= cpri_map_rx_overflow(16);
   map15_rx_status_data(0) <= cpri_map_rx_en(15);
   map15_rx_status_data(1) <= cpri_map_rx_underflow(15);
   map15_rx_status_data(2) <= cpri_map_rx_overflow(15);
   map14_rx_status_data(0) <= cpri_map_rx_en(14);
   map14_rx_status_data(1) <= cpri_map_rx_underflow(14);
   map14_rx_status_data(2) <= cpri_map_rx_overflow(14);
   map13_rx_status_data(0) <= cpri_map_rx_en(13);
   map13_rx_status_data(1) <= cpri_map_rx_underflow(13);
   map13_rx_status_data(2) <= cpri_map_rx_overflow(13);
   map12_rx_status_data(0) <= cpri_map_rx_en(12);
   map12_rx_status_data(1) <= cpri_map_rx_underflow(12);
   map12_rx_status_data(2) <= cpri_map_rx_overflow(12);
   map11_rx_status_data(0) <= cpri_map_rx_en(11);
   map11_rx_status_data(1) <= cpri_map_rx_underflow(11);
   map11_rx_status_data(2) <= cpri_map_rx_overflow(11);
   map10_rx_status_data(0) <= cpri_map_rx_en(10);
   map10_rx_status_data(1) <= cpri_map_rx_underflow(10);
   map10_rx_status_data(2) <= cpri_map_rx_overflow(10);
   map9_rx_status_data(0) <= cpri_map_rx_en(9);
   map9_rx_status_data(1) <= cpri_map_rx_underflow(9);
   map9_rx_status_data(2) <= cpri_map_rx_overflow(9);
   map8_rx_status_data(0) <= cpri_map_rx_en(8);
   map8_rx_status_data(1) <= cpri_map_rx_underflow(8);
   map8_rx_status_data(2) <= cpri_map_rx_overflow(8);
   map7_rx_status_data(0) <= cpri_map_rx_en(7);
   map7_rx_status_data(1) <= cpri_map_rx_underflow(7);
   map7_rx_status_data(2) <= cpri_map_rx_overflow(7);
   map6_rx_status_data(0) <= cpri_map_rx_en(6);
   map6_rx_status_data(1) <= cpri_map_rx_underflow(6);
   map6_rx_status_data(2) <= cpri_map_rx_overflow(6);
   map5_rx_status_data(0) <= cpri_map_rx_en(5);
   map5_rx_status_data(1) <= cpri_map_rx_underflow(5);
   map5_rx_status_data(2) <= cpri_map_rx_overflow(5); 
   map4_rx_status_data(0) <= cpri_map_rx_en(4);
   map4_rx_status_data(1) <= cpri_map_rx_underflow(4);
   map4_rx_status_data(2) <= cpri_map_rx_overflow(4); 
   map3_rx_status_data(0) <= cpri_map_rx_en(3);
   map3_rx_status_data(1) <= cpri_map_rx_underflow(3);
   map3_rx_status_data(2) <= cpri_map_rx_overflow(3);
   map2_rx_status_data(0) <= cpri_map_rx_en(2);
   map2_rx_status_data(1) <= cpri_map_rx_underflow(2);
   map2_rx_status_data(2) <= cpri_map_rx_overflow(2);
   map1_rx_status_data(0) <= cpri_map_rx_en(1);
   map1_rx_status_data(1) <= cpri_map_rx_underflow(1);
   map1_rx_status_data(2) <= cpri_map_rx_overflow(1);
   map0_rx_status_data(0) <= cpri_map_rx_en(0);
   map0_rx_status_data(1) <= cpri_map_rx_underflow(0);
   map0_rx_status_data(2) <= cpri_map_rx_overflow(0);      
   
   -- Tx Map Signals
   cpri_map_tx_clk    <= map23_tx_clk & map22_tx_clk & map21_tx_clk & map20_tx_clk & map19_tx_clk & 
                         map18_tx_clk & map17_tx_clk & map16_tx_clk & map15_tx_clk & map14_tx_clk & 
                         map13_tx_clk & map12_tx_clk & map11_tx_clk & map10_tx_clk & map9_tx_clk & 
                         map8_tx_clk & map7_tx_clk & map6_tx_clk & map5_tx_clk & map4_tx_clk & 
                         map3_tx_clk & map2_tx_clk & map1_tx_clk & map0_tx_clk;
   cpri_map_tx_reset  <= map23_tx_reset & map22_tx_reset & map21_tx_reset & map20_tx_reset & map19_tx_reset &
                         map18_tx_reset & map17_tx_reset & map16_tx_reset & map15_tx_reset & map14_tx_reset & 
                         map13_tx_reset & map12_tx_reset & map11_tx_reset & map10_tx_reset & map9_tx_reset & 
                         map8_tx_reset & map7_tx_reset & map6_tx_reset & map5_tx_reset & map4_tx_reset & 
                         map3_tx_reset & map2_tx_reset & map1_tx_reset & map0_tx_reset;
   cpri_map_tx_write  <= map23_tx_valid & map22_tx_valid & map21_tx_valid & map20_tx_valid & map19_tx_valid &
                         map18_tx_valid & map17_tx_valid & map16_tx_valid & map15_tx_valid & map14_tx_valid &
                         map13_tx_valid & map12_tx_valid & map11_tx_valid & map10_tx_valid & map9_tx_valid & 
                         map8_tx_valid & map7_tx_valid & map6_tx_valid & map5_tx_valid & map4_tx_valid & 
                         map3_tx_valid & map2_tx_valid & map1_tx_valid & map0_tx_valid;
   cpri_map_tx_data   <= map23_tx_data & map22_tx_data & map21_tx_data & map20_tx_data &  map19_tx_data &
                         map18_tx_data & map17_tx_data & map16_tx_data & map15_tx_data & map14_tx_data &
                         map13_tx_data & map12_tx_data & map11_tx_data & map10_tx_data & map9_tx_data & 
                         map8_tx_data & map7_tx_data & map6_tx_data & map5_tx_data & map4_tx_data & 
                         map3_tx_data & map2_tx_data & map1_tx_data & map0_tx_data  ;  
   cpri_map_tx_resync <= map23_tx_resync & map22_tx_resync & map21_tx_resync & map20_tx_resync & map19_tx_resync &
                         map18_tx_resync & map17_tx_resync & map16_tx_resync & map15_tx_resync & map14_tx_resync &
                         map13_tx_resync & map12_tx_resync & map11_tx_resync & map10_tx_resync & map9_tx_resync &
                         map8_tx_resync & map7_tx_resync & map6_tx_resync & map5_tx_resync & map4_tx_resync & 
                         map3_tx_resync & map2_tx_resync & map1_tx_resync & map0_tx_resync ; 
   		
   map23_tx_ready <= cpri_map_tx_ready(23);
   map22_tx_ready <= cpri_map_tx_ready(22);   					   
   map21_tx_ready <= cpri_map_tx_ready(21);
   map20_tx_ready <= cpri_map_tx_ready(20);
   map19_tx_ready <= cpri_map_tx_ready(19);
   map18_tx_ready <= cpri_map_tx_ready(18);
   map17_tx_ready <= cpri_map_tx_ready(17);
   map16_tx_ready <= cpri_map_tx_ready(16);  					   
   map15_tx_ready <= cpri_map_tx_ready(15);
   map14_tx_ready <= cpri_map_tx_ready(14);
   map13_tx_ready <= cpri_map_tx_ready(13);
   map12_tx_ready <= cpri_map_tx_ready(12);
   map11_tx_ready <= cpri_map_tx_ready(11);
   map10_tx_ready <= cpri_map_tx_ready(10);
   map9_tx_ready  <= cpri_map_tx_ready(9);
   map8_tx_ready  <= cpri_map_tx_ready(8);
   map7_tx_ready  <= cpri_map_tx_ready(7);
   map6_tx_ready  <= cpri_map_tx_ready(6);
   map5_tx_ready  <= cpri_map_tx_ready(5);
   map4_tx_ready  <= cpri_map_tx_ready(4);
   map3_tx_ready  <= cpri_map_tx_ready(3);
   map2_tx_ready  <= cpri_map_tx_ready(2);
   map1_tx_ready  <= cpri_map_tx_ready(1);
   map0_tx_ready  <= cpri_map_tx_ready(0);  
    
   map23_tx_status_data(0) <= cpri_map_tx_en(23);
   map23_tx_status_data(1) <= cpri_map_tx_underflow(23);
   map23_tx_status_data(2) <= cpri_map_tx_overflow(23);
   map22_tx_status_data(0) <= cpri_map_tx_en(22);
   map22_tx_status_data(1) <= cpri_map_tx_underflow(22);
   map22_tx_status_data(2) <= cpri_map_tx_overflow(22);
   map21_tx_status_data(0) <= cpri_map_tx_en(21);
   map21_tx_status_data(1) <= cpri_map_tx_underflow(21);
   map21_tx_status_data(2) <= cpri_map_tx_overflow(21);
   map20_tx_status_data(0) <= cpri_map_tx_en(20);
   map20_tx_status_data(1) <= cpri_map_tx_underflow(20);
   map20_tx_status_data(2) <= cpri_map_tx_overflow(20);
   map19_tx_status_data(0) <= cpri_map_tx_en(19);
   map19_tx_status_data(1) <= cpri_map_tx_underflow(19);
   map19_tx_status_data(2) <= cpri_map_tx_overflow(19);
   map18_tx_status_data(0) <= cpri_map_tx_en(18);
   map18_tx_status_data(1) <= cpri_map_tx_underflow(18);
   map18_tx_status_data(2) <= cpri_map_tx_overflow(18);
   map17_tx_status_data(0) <= cpri_map_tx_en(17);
   map17_tx_status_data(1) <= cpri_map_tx_underflow(17);
   map17_tx_status_data(2) <= cpri_map_tx_overflow(17);
   map16_tx_status_data(0) <= cpri_map_tx_en(16);
   map16_tx_status_data(1) <= cpri_map_tx_underflow(16);
   map16_tx_status_data(2) <= cpri_map_tx_overflow(16);   						
   map15_tx_status_data(0) <= cpri_map_tx_en(15);
   map15_tx_status_data(1) <= cpri_map_tx_underflow(15);
   map15_tx_status_data(2) <= cpri_map_tx_overflow(15);
   map14_tx_status_data(0) <= cpri_map_tx_en(14);
   map14_tx_status_data(1) <= cpri_map_tx_underflow(14);
   map14_tx_status_data(2) <= cpri_map_tx_overflow(14);
   map13_tx_status_data(0) <= cpri_map_tx_en(13);
   map13_tx_status_data(1) <= cpri_map_tx_underflow(13);
   map13_tx_status_data(2) <= cpri_map_tx_overflow(13);
   map12_tx_status_data(0) <= cpri_map_tx_en(12);
   map12_tx_status_data(1) <= cpri_map_tx_underflow(12);
   map12_tx_status_data(2) <= cpri_map_tx_overflow(12);
   map11_tx_status_data(0) <= cpri_map_tx_en(11);
   map11_tx_status_data(1) <= cpri_map_tx_underflow(11);
   map11_tx_status_data(2) <= cpri_map_tx_overflow(11);
   map10_tx_status_data(0) <= cpri_map_tx_en(10);
   map10_tx_status_data(1) <= cpri_map_tx_underflow(10);
   map10_tx_status_data(2) <= cpri_map_tx_overflow(10);
   map9_tx_status_data(0) <= cpri_map_tx_en(9);
   map9_tx_status_data(1) <= cpri_map_tx_underflow(9);
   map9_tx_status_data(2) <= cpri_map_tx_overflow(9);
   map8_tx_status_data(0) <= cpri_map_tx_en(8);
   map8_tx_status_data(1) <= cpri_map_tx_underflow(8);
   map8_tx_status_data(2) <= cpri_map_tx_overflow(8);
   map7_tx_status_data(0) <= cpri_map_tx_en(7);
   map7_tx_status_data(1) <= cpri_map_tx_underflow(7);
   map7_tx_status_data(2) <= cpri_map_tx_overflow(7);
   map6_tx_status_data(0) <= cpri_map_tx_en(6);
   map6_tx_status_data(1) <= cpri_map_tx_underflow(6);
   map6_tx_status_data(2) <= cpri_map_tx_overflow(6);
   map5_tx_status_data(0) <= cpri_map_tx_en(5);
   map5_tx_status_data(1) <= cpri_map_tx_underflow(5);
   map5_tx_status_data(2) <= cpri_map_tx_overflow(5); 
   map4_tx_status_data(0) <= cpri_map_tx_en(4);
   map4_tx_status_data(1) <= cpri_map_tx_underflow(4);
   map4_tx_status_data(2) <= cpri_map_tx_overflow(4); 
   map3_tx_status_data(0) <= cpri_map_tx_en(3);
   map3_tx_status_data(1) <= cpri_map_tx_underflow(3);
   map3_tx_status_data(2) <= cpri_map_tx_overflow(3);
   map2_tx_status_data(0) <= cpri_map_tx_en(2);
   map2_tx_status_data(1) <= cpri_map_tx_underflow(2);
   map2_tx_status_data(2) <= cpri_map_tx_overflow(2);
   map1_tx_status_data(0) <= cpri_map_tx_en(1);
   map1_tx_status_data(1) <= cpri_map_tx_underflow(1);
   map1_tx_status_data(2) <= cpri_map_tx_overflow(1);
   map0_tx_status_data(0) <= cpri_map_tx_en(0);
   map0_tx_status_data(1) <= cpri_map_tx_underflow(0);
   map0_tx_status_data(2) <= cpri_map_tx_overflow(0); 
	
---------------------------------------------------------------------------------------------------------------------
------------------------------------------------------ Port Map -----------------------------------------------------
---------------------------------------------------------------------------------------------------------------------

   gen_stratixivgx_arriaiigxgz_cycloneivgx:
   if DEVICE < 4 generate -- Stratix IV GX, Arria II GX/GZ, Cyclone IV GX
   begin
   inst_cpri : cpri
   generic map (
      INCLUDE_RX_EX_DELAY          => INCLUDE_RX_EX_DELAY,
      INCLUDE_TX_EX_DELAY          => INCLUDE_TX_EX_DELAY,
      INCLUDE_8b10b                => INCLUDE_8b10b,
      INCLUDE_CPU_SYNC             => INCLUDE_CPU_SYNC,
      INCLUDE_PHY_LOOP             => INCLUDE_PHY_LOOP,
      SYNC_MODE                    => SYNC_MODE,
      INCLUDE_PRBS                 => INCLUDE_PRBS,
      INCLUDE_MAP                  => (N_MAP /= 0),
      SYNC_MAP                     => (SYNC_MAP = 1),
      INCLUDE_MAC                  => (MAC_OFF = 0),
      INCLUDE_HDLC                 => (HDLC_OFF = 0),
      INCLUDE_CAL                  => (CAL_OFF = 0),
      WIDTH_MAP_RX_ADDR            => WIDTH_MAP_RX_ADDR,
      WIDTH_MAP_TX_ADDR            => WIDTH_MAP_TX_ADDR,
      WIDTH_RX_BUF                 => WIDTH_RX_BUF,
      WIDTH_N_MAP                  => WIDTH_N_MAP,
      WIDTH_K                      => WIDTH_K,
      WIDTH_ETH_BUF                => WIDTH_ETH_BUF,
      WIDTH_ETH_BLOCK              => WIDTH_ETH_BLOCK,
      WIDTH_HDLC_BUF               => WIDTH_HDLC_BUF,
      WIDTH_HDLC_BLOCK             => WIDTH_HDLC_BLOCK,
      WIDTH_RX                     => WIDTH_RX,
      N_MAP                        => N_MAP,
      LINERATE                     => LINERATE,
      DEVICE                       => DEVICE,
      MAP_MODE                     => MAP_MODE,
      INCLUDE_VSS                  => (VSS_OFF = 0)
   )
   port map (
      clk                          => cpri_clk,
      reset_rx                     => rx_digitalreset_cpri_clk_sync2,
      reset_tx                     => tx_digitalreset_cpri_clk_sync2,
      config_reset                 => config_reset,
      clk_ex_delay                 => clk_ex_delay,
      reset_ex_delay               => reset_ex_delay,
      hw_reset_assert              => hw_reset_assert,
      hw_reset_req                 => hw_reset_req,
      rate                         => rate,
      int_datarate_en              => int_datarate_en,
      int_datarate_set             => int_datarate_set,
      cpu_clk                      => cpu_clk,
      cpu_reset                    => cpu_reset,
      cpu_address(15 downto 2)     => cpu_address,
      cpu_address(1 downto 0)      => "00",
      cpu_byte_en                  => cpu_byteenable,
      cpu_wr_data                  => cpu_wr_data,
      cpu_rd_data                  => cpu_readdata,
      cpu_read                     => cpu_read,
      cpu_write                    => cpu_write,
      cpu_select                   => cpu_select,
      cpu_ack                      => cpu_ack,
      cpu_intr                     => cpu_intr,
      cpu_intr_vector              => cpu_irq_vector,
      cpri_map_rx_clk              => cpri_map_rx_clk,
      cpri_map_rx_reset            => cpri_map_rx_reset,
      cpri_map_rx_en               => cpri_map_rx_en,
      cpri_map_rx_start            => cpri_map_rx_start,
      cpri_map_rx_read             => cpri_map_rx_read,
      cpri_map_rx_resync           => cpri_map_rx_resync,
      cpri_map_rx_data             => cpri_map_rx_data,
      cpri_map_rx_ready            => cpri_map_rx_ready,
      cpri_map_rx_underflow        => cpri_map_rx_underflow,
      cpri_map_rx_overflow         => cpri_map_rx_overflow,       
      cpri_map_tx_clk              => cpri_map_tx_clk,
      cpri_map_tx_reset            => cpri_map_tx_reset,
      cpri_map_tx_en               => cpri_map_tx_en,
      cpri_map_tx_write            => cpri_map_tx_write,
      cpri_map_tx_resync           => cpri_map_tx_resync,
      cpri_map_tx_data             => cpri_map_tx_data,
      cpri_map_tx_ready            => cpri_map_tx_ready,
      cpri_map_tx_underflow        => cpri_map_tx_underflow,
      cpri_map_tx_overflow         => cpri_map_tx_overflow,
      cpri_rx_aux_data             => cpri_rx_aux_data_tmp,
      cpri_tx_aux_data             => cpri_tx_aux_data,
      cpri_tx_aux_mask             => cpri_tx_aux_mask,
      cpri_rx_sync_state           => cpri_rx_sync_state,
      cpri_rx_start                => cpri_rx_start,
      cpri_rx_rfp                  => cpri_rx_rfp,
      cpri_rx_hfp                  => cpri_rx_hfp,
      cpri_rx_bfn                  => cpri_rx_bfn,
      cpri_rx_hfn                  => cpri_rx_hfn,
      cpri_rx_seq                  => cpri_rx_seq,
      cpri_rx_x                    => cpri_rx_x,
      cpri_rx_k                    => cpri_rx_k,
      cpri_tx_sync_rfp             => cpri_tx_sync_rfp,
      cpri_tx_start                => cpri_tx_start,
      cpri_tx_rfp                  => cpri_tx_rfp,
      cpri_tx_hfp                  => cpri_tx_hfp,
      cpri_tx_bfn                  => cpri_tx_bfn,
      cpri_tx_hfn                  => cpri_tx_hfn,
      cpri_tx_seq                  => cpri_tx_seq,
      cpri_tx_x                    => cpri_tx_x,
      cpri_tx_k                    => cpri_tx_k,
      cpri_tx_error                => cpri_tx_error,
      cpri_rx_state                => cpri_rx_state,
      cpri_rx_cnt_sync             => cpri_rx_cnt_sync,
      cpri_rx_freq_alarm           => cpri_rx_freq_alarm,
      cpri_rx_bfn_state            => cpri_rx_bfn_state,
      cpri_rx_hfn_state            => cpri_rx_hfn_state,
      cpri_rx_lcv                  => cpri_rx_lcv,
      cpri_rx_los                  => cpri_rx_los,
      serdes_rx_clk                => serdes_rx_clk,
      serdes_rx_reset              => rx_digitalreset_serdes_rxclk_sync2,
      serdes_rx_los                => gxb_los,
      serdes_rx_data(79 downto 40) => (others => '0'),
      serdes_rx_data(39 downto 0)  => serdes_rx_data,
      serdes_rx_align_delay        => "000000",
      serdes_rx_align_en           => serdes_rx_align_en,    
      serdes_width                 => serdes_width, 
      serdes_tx_clk                => serdes_tx_clk,
      serdes_tx_reset              => tx_digitalreset_serdes_txclk_sync2, 
      serdes_tx_data               => serdes_tx_data_pl, 
      cpri_mii_txclk               => cpri_mii_txclk, 
      cpri_mii_txrd                => cpri_mii_txrd,
      cpri_mii_txen                => cpri_mii_txen,
      cpri_mii_txer                => cpri_mii_txer,
      cpri_mii_txd                 => cpri_mii_txd,
      cpri_mii_rxclk               => cpri_mii_rxclk,
      cpri_mii_rxwr                => cpri_mii_rxwr,
      cpri_mii_rxdv                => cpri_mii_rxdv,
      cpri_mii_rxer                => cpri_mii_rxer,
      cpri_mii_rxd                 => cpri_mii_rxd,
      tx_bitslip                   => tx_bitslipboundaryselect,
      bitslipdetect                => rx_bitslipboundaryselectout,
      syncstatus                   => rx_syncstatus,
      phy_ex_delay_period          => open,
      phy_rx_ex_buf_delay          => (others => '0'),
      phy_tx_ex_buf_delay          => (others => '0'),
      phy_rx_ex_buf_valid          => '0',
      phy_tx_ex_buf_valid          => '0',
      phy_tx_buf_delay             => (others => '0'),
      phy_rx_buf_delay             => (others => '0'),
      phy_rx_buf_resync            => '0',
      phy_tx_pcs_clk               => '0',
      phy_rx_pma_clk               => '0',
      rx_buf_resync_cpu            => open
      );
   end generate; 

   gen_stratixvgxgt_arriavgxgz_cyclonev:
   if CODE_BASE = 1 
    or (CODE_BASE = 0 
   and  ((DEVICE = 4 and (LINERATE = 3 or LINERATE = 2 or LINERATE = 1 or LINERATE = 0 or LINERATE = 614))   -- Stratix V GX/GT < 6G
    or   (DEVICE = 5 and (LINERATE = 2 or LINERATE = 1 or LINERATE = 0 or LINERATE = 614))                   -- Arria V GX      < 5G
    or   (DEVICE = 6 and (LINERATE = 2 or LINERATE = 1 or LINERATE = 0 or LINERATE = 614))                   -- Cyclone V       < 5G
    or   (DEVICE = 7 and (LINERATE = 3 or LINERATE = 2 or LINERATE = 1 or LINERATE = 0 or LINERATE = 614)))) -- Arria V GZ      < 6G
   generate
   begin
      inst_cpri : cpri
      generic map (
         INCLUDE_RX_EX_DELAY          => INCLUDE_RX_EX_DELAY,
         INCLUDE_TX_EX_DELAY          => INCLUDE_TX_EX_DELAY,
         INCLUDE_8b10b                => INCLUDE_8b10b,
         INCLUDE_CPU_SYNC             => INCLUDE_CPU_SYNC,
         INCLUDE_PHY_LOOP             => INCLUDE_PHY_LOOP,
         SYNC_MODE                    => SYNC_MODE,
         INCLUDE_PRBS                 => INCLUDE_PRBS,
         INCLUDE_MAP                  => (N_MAP /= 0),
         SYNC_MAP                     => (SYNC_MAP = 1),
         INCLUDE_MAC                  => (MAC_OFF = 0),
         INCLUDE_HDLC                 => (HDLC_OFF = 0),
         INCLUDE_CAL                  => (CAL_OFF = 0),
         WIDTH_MAP_RX_ADDR            => WIDTH_MAP_RX_ADDR,
         WIDTH_MAP_TX_ADDR            => WIDTH_MAP_TX_ADDR,
         WIDTH_RX_BUF                 => WIDTH_RX_BUF,
         WIDTH_N_MAP                  => WIDTH_N_MAP,
         WIDTH_K                      => WIDTH_K,
         WIDTH_ETH_BUF                => WIDTH_ETH_BUF,
         WIDTH_ETH_BLOCK              => WIDTH_ETH_BLOCK,
         WIDTH_HDLC_BUF               => WIDTH_HDLC_BUF,
         WIDTH_HDLC_BLOCK             => WIDTH_HDLC_BLOCK,
         WIDTH_RX                     => WIDTH_RX,
         N_MAP                        => N_MAP,
         LINERATE                     => LINERATE,
         DEVICE                       => DEVICE,
         MAP_MODE                     => MAP_MODE,
         INCLUDE_VSS                  => (VSS_OFF = 0)
      )
      port map (
         clk                          => cpri_clk,
         reset_rx                     => rx_digitalreset_cpri_clk_sync2,
         reset_tx                     => tx_digitalreset_cpri_clk_sync2,
         config_reset                 => config_reset,
         clk_ex_delay                 => clk_ex_delay,
         reset_ex_delay               => reset_ex_delay,
         hw_reset_assert              => hw_reset_assert,
         hw_reset_req                 => hw_reset_req,
         rate                         => rate,
         int_datarate_en              => int_datarate_en,
         int_datarate_set             => int_datarate_set,
         cpu_clk                      => cpu_clk,
         cpu_reset                    => cpu_reset,
         cpu_address(15 downto 2)     => cpu_address,
         cpu_address(1 downto 0)      => "00",
         cpu_byte_en                  => cpu_byteenable,
         cpu_wr_data                  => cpu_wr_data,
         cpu_rd_data                  => cpu_readdata,
         cpu_read                     => cpu_read,
         cpu_write                    => cpu_write,
         cpu_select                   => cpu_select,
         cpu_ack                      => cpu_ack,
         cpu_intr                     => cpu_intr,
         cpu_intr_vector              => cpu_irq_vector,
         cpri_map_rx_clk              => cpri_map_rx_clk,
         cpri_map_rx_reset            => cpri_map_rx_reset,
         cpri_map_rx_en               => cpri_map_rx_en,
         cpri_map_rx_start            => cpri_map_rx_start,
         cpri_map_rx_read             => cpri_map_rx_read,
         cpri_map_rx_resync           => cpri_map_rx_resync,
         cpri_map_rx_data             => cpri_map_rx_data,
         cpri_map_rx_ready            => cpri_map_rx_ready,
         cpri_map_rx_underflow        => cpri_map_rx_underflow,
         cpri_map_rx_overflow         => cpri_map_rx_overflow,             
         cpri_map_tx_clk              => cpri_map_tx_clk,
         cpri_map_tx_reset            => cpri_map_tx_reset,
         cpri_map_tx_en               => cpri_map_tx_en,
         cpri_map_tx_write            => cpri_map_tx_write,
         cpri_map_tx_resync           => cpri_map_tx_resync,
         cpri_map_tx_data             => cpri_map_tx_data,
         cpri_map_tx_ready            => cpri_map_tx_ready,
         cpri_map_tx_underflow        => cpri_map_tx_underflow,
         cpri_map_tx_overflow         => cpri_map_tx_overflow,
         cpri_rx_aux_data             => cpri_rx_aux_data_tmp,
         cpri_tx_aux_data             => cpri_tx_aux_data,
         cpri_tx_aux_mask             => cpri_tx_aux_mask,
         cpri_rx_sync_state           => cpri_rx_sync_state,
         cpri_rx_start                => cpri_rx_start,
         cpri_rx_rfp                  => cpri_rx_rfp,
         cpri_rx_hfp                  => cpri_rx_hfp,
         cpri_rx_bfn                  => cpri_rx_bfn,
         cpri_rx_hfn                  => cpri_rx_hfn,
         cpri_rx_seq                  => cpri_rx_seq,
         cpri_rx_x                    => cpri_rx_x,
         cpri_rx_k                    => cpri_rx_k,
         cpri_tx_sync_rfp             => cpri_tx_sync_rfp,
         cpri_tx_start                => cpri_tx_start,
         cpri_tx_rfp                  => cpri_tx_rfp,
         cpri_tx_hfp                  => cpri_tx_hfp,
         cpri_tx_bfn                  => cpri_tx_bfn,
         cpri_tx_hfn                  => cpri_tx_hfn,
         cpri_tx_seq                  => cpri_tx_seq,
         cpri_tx_x                    => cpri_tx_x,
         cpri_tx_k                    => cpri_tx_k,
         cpri_tx_error                => cpri_tx_error,
         cpri_rx_state                => cpri_rx_state,
         cpri_rx_cnt_sync             => cpri_rx_cnt_sync,
         cpri_rx_freq_alarm           => cpri_rx_freq_alarm,
         cpri_rx_bfn_state            => cpri_rx_bfn_state,
         cpri_rx_hfn_state            => cpri_rx_hfn_state,
         cpri_rx_lcv                  => cpri_rx_lcv,
         cpri_rx_los                  => cpri_rx_los,
         serdes_rx_clk                => serdes_rx_clk,
         serdes_rx_reset              => rx_digitalreset_serdes_rxclk_sync2,
         serdes_rx_los                => gxb_los,
         serdes_rx_data(79 downto 40) => (others => '0'),
         serdes_rx_data(39 downto 0)  => serdes_rx_data,
         serdes_rx_align_delay        => "000000",
         serdes_rx_align_en           => serdes_rx_align_en,     
         serdes_width                 => serdes_width,
         serdes_tx_clk                => serdes_tx_clk,
         serdes_tx_reset              => tx_digitalreset_serdes_txclk_sync2,
         serdes_tx_data               => serdes_tx_data_pl, 
         cpri_mii_txclk               => cpri_mii_txclk, 
         cpri_mii_txrd                => cpri_mii_txrd,
         cpri_mii_txen                => cpri_mii_txen,
         cpri_mii_txer                => cpri_mii_txer,
         cpri_mii_txd                 => cpri_mii_txd,
         cpri_mii_rxclk               => cpri_mii_rxclk,
         cpri_mii_rxwr                => cpri_mii_rxwr,
         cpri_mii_rxdv                => cpri_mii_rxdv,
         cpri_mii_rxer                => cpri_mii_rxer,
         cpri_mii_rxd                 => cpri_mii_rxd,
         tx_bitslip                   => tx_bitslipboundaryselect,
         bitslipdetect                => rx_bitslipboundaryselectout,
         syncstatus                   => rx_syncstatus,
         phy_ex_delay_period          => open,
         phy_rx_ex_buf_delay          => (others => '0'),
         phy_tx_ex_buf_delay          => (others => '0'),
         phy_rx_ex_buf_valid          => '0',
         phy_tx_ex_buf_valid          => '0',
         phy_tx_buf_delay             => (others => '0'),
         phy_rx_buf_delay             => (others => '0'),
         phy_rx_buf_resync            => '0',
         phy_tx_pcs_clk               => '0',
         phy_rx_pma_clk               => '0',
         rx_buf_resync_cpu            => open
      );
   end generate;

   gen_stratixvgxgt_98G_6G_arriavgz:
   if CODE_BASE = 3 or (CODE_BASE = 0 and 
   ((DEVICE = 7 and (LINERATE = 5 or LINERATE = 4)) or         -- Arria V GZ 9.8G, 6G
   (DEVICE = 4 and (LINERATE = 5 or LINERATE = 4))))           -- Stratix V GX/GT 9.8G, 6G
   generate
   begin
      inst_cpri : cpri3
      generic map (
         INCLUDE_RX_EX_DELAY          => INCLUDE_RX_EX_DELAY,
         INCLUDE_TX_EX_DELAY          => INCLUDE_TX_EX_DELAY,
         INCLUDE_8b10b                => INCLUDE_8b10b,
         INCLUDE_CPU_SYNC             => INCLUDE_CPU_SYNC,
         INCLUDE_PHY_LOOP             => INCLUDE_PHY_LOOP,
         SYNC_MODE                    => SYNC_MODE,
         INCLUDE_PRBS                 => INCLUDE_PRBS,
         INCLUDE_MAP                  => (N_MAP /= 0),
         SYNC_MAP                     => (SYNC_MAP = 1),
         INCLUDE_MAC                  => (MAC_OFF = 0),
         INCLUDE_HDLC                 => (HDLC_OFF = 0),
         INCLUDE_CAL                  => (CAL_OFF = 0),
         WIDTH_MAP_RX_ADDR            => WIDTH_MAP_RX_ADDR,
         WIDTH_MAP_TX_ADDR            => WIDTH_MAP_TX_ADDR,
         WIDTH_RX_BUF                 => WIDTH_RX_BUF,
         WIDTH_N_MAP                  => WIDTH_N_MAP,
         WIDTH_K                      => WIDTH_K,
         WIDTH_ETH_BUF                => WIDTH_ETH_BUF,
         WIDTH_ETH_BLOCK              => WIDTH_ETH_BLOCK,
         WIDTH_HDLC_BUF               => WIDTH_HDLC_BUF,
         WIDTH_HDLC_BLOCK             => WIDTH_HDLC_BLOCK,
         WIDTH_RX                     => WIDTH_RX,
         N_MAP                        => N_MAP,
         LINERATE                     => LINERATE,
         DEVICE                       => DEVICE,
         MAP_MODE                     => MAP_MODE,
         INCLUDE_VSS                  => (VSS_OFF = 0)
      )
      port map (
         clk                          => cpri_clk,
         reset_rx                     => rx_digitalreset_cpri_clk_sync2,
         reset_tx                     => tx_digitalreset_cpri_clk_sync2,
         config_reset                 => config_reset,
         clk_ex_delay                 => clk_ex_delay,
         reset_ex_delay               => reset_ex_delay,
         hw_reset_assert              => hw_reset_assert,
         hw_reset_req                 => hw_reset_req,
         rate                         => rate,
         int_datarate_en              => int_datarate_en,
         int_datarate_set             => int_datarate_set,
         cpu_clk                      => cpu_clk,
         cpu_reset                    => cpu_reset,
         cpu_address(15 downto 2)     => cpu_address,
         cpu_address(1 downto 0)      => "00",
         cpu_byte_en                  => cpu_byteenable,
         cpu_wr_data                  => cpu_wr_data,
         cpu_rd_data                  => cpu_readdata,
         cpu_read                     => cpu_read,
         cpu_write                    => cpu_write,
         cpu_select                   => cpu_select,
         cpu_ack                      => cpu_ack,
         cpu_intr                     => cpu_intr,
         cpu_intr_vector              => cpu_irq_vector,
         cpri_map_rx_clk              => cpri_map_rx_clk,
         cpri_map_rx_reset            => cpri_map_rx_reset,
         cpri_map_rx_en               => cpri_map_rx_en,
         cpri_map_rx_start            => cpri_map_rx_start,
         cpri_map_rx_read             => cpri_map_rx_read,
         cpri_map_rx_resync           => cpri_map_rx_resync,
         cpri_map_rx_data             => cpri_map_rx_data,
         cpri_map_rx_ready            => cpri_map_rx_ready,
         cpri_map_rx_underflow        => cpri_map_rx_underflow,
         cpri_map_rx_overflow         => cpri_map_rx_overflow,             
         cpri_map_tx_clk              => cpri_map_tx_clk,
         cpri_map_tx_reset            => cpri_map_tx_reset,
         cpri_map_tx_en               => cpri_map_tx_en,
         cpri_map_tx_write            => cpri_map_tx_write,
         cpri_map_tx_resync           => cpri_map_tx_resync,
         cpri_map_tx_data             => cpri_map_tx_data,
         cpri_map_tx_ready            => cpri_map_tx_ready,
         cpri_map_tx_underflow        => cpri_map_tx_underflow,
         cpri_map_tx_overflow         => cpri_map_tx_overflow,
         cpri_rx_aux_data             => cpri_rx_aux_data_tmp,
         cpri_tx_aux_data             => cpri_tx_aux_data,
         cpri_tx_aux_mask             => cpri_tx_aux_mask,
         cpri_rx_sync_state           => cpri_rx_sync_state,
         cpri_rx_start                => cpri_rx_start,
         cpri_rx_rfp                  => cpri_rx_rfp,
         cpri_rx_hfp                  => cpri_rx_hfp,
         cpri_rx_bfn                  => cpri_rx_bfn,
         cpri_rx_hfn                  => cpri_rx_hfn,
         cpri_rx_seq                  => cpri_rx_seq,
         cpri_rx_x                    => cpri_rx_x,
         cpri_rx_k                    => cpri_rx_k,
         cpri_tx_sync_rfp             => cpri_tx_sync_rfp,
         cpri_tx_start                => cpri_tx_start,
         cpri_tx_rfp                  => cpri_tx_rfp,
         cpri_tx_hfp                  => cpri_tx_hfp,
         cpri_tx_bfn                  => cpri_tx_bfn,
         cpri_tx_hfn                  => cpri_tx_hfn,
         cpri_tx_seq                  => cpri_tx_seq,
         cpri_tx_x                    => cpri_tx_x,
         cpri_tx_k                    => cpri_tx_k,
         cpri_tx_error                => cpri_tx_error,
         cpri_rx_state                => cpri_rx_state,
         cpri_rx_cnt_sync             => cpri_rx_cnt_sync,
         cpri_rx_freq_alarm           => cpri_rx_freq_alarm,
         cpri_rx_bfn_state            => cpri_rx_bfn_state,
         cpri_rx_hfn_state            => cpri_rx_hfn_state,
         cpri_rx_lcv                  => cpri_rx_lcv,
         cpri_rx_los                  => cpri_rx_los,
         serdes_rx_clk                => serdes_rx_clk,
         serdes_rx_reset              => rx_digitalreset_serdes_rxclk_sync2,
         serdes_rx_los                => gxb_los,
         serdes_rx_data(79 downto 40) => (others => '0'),
         serdes_rx_data(39 downto 0)  => serdes_rx_data,
         serdes_rx_align_delay        => "000000",
         serdes_rx_align_en           => serdes_rx_align_en,     
         serdes_width                 => serdes_width,
         serdes_tx_clk                => serdes_tx_clk,
         serdes_tx_reset              => tx_digitalreset_serdes_txclk_sync2,
         serdes_tx_data               => serdes_tx_data_pl, 
         cpri_mii_txclk               => cpri_mii_txclk, 
         cpri_mii_txrd                => cpri_mii_txrd,
         cpri_mii_txen                => cpri_mii_txen,
         cpri_mii_txer                => cpri_mii_txer,
         cpri_mii_txd                 => cpri_mii_txd,
         cpri_mii_rxclk               => cpri_mii_rxclk,
         cpri_mii_rxwr                => cpri_mii_rxwr,
         cpri_mii_rxdv                => cpri_mii_rxdv,
         cpri_mii_rxer                => cpri_mii_rxer,
         cpri_mii_rxd                 => cpri_mii_rxd,
         tx_bitslip                   => tx_bitslipboundaryselect,
         bitslipdetect                => rx_bitslipboundaryselectout,
         syncstatus                   => rx_syncstatus,
         phy_ex_delay_period          => open,
         phy_rx_ex_buf_delay          => (others => '0'),
         phy_tx_ex_buf_delay          => (others => '0'),
         phy_rx_ex_buf_valid          => '0',
         phy_tx_ex_buf_valid          => '0',
         phy_tx_buf_delay             => (others => '0'),
         phy_rx_buf_delay             => (others => '0'),
         phy_rx_buf_resync            => '0',
         phy_tx_pcs_clk               => '0',
         phy_rx_pma_clk               => '0',
         rx_buf_resync_cpu            => open
      );
   end generate;

   gen_stratixvgxgt_98G_6G_arriavgxz_6G_5G:
   if CODE_BASE = 2
    or (CODE_BASE = 0
   and  (DEVICE = 5 and (LINERATE = 4 or LINERATE = 3)))          -- Arria V GX 6G, 5G
    generate
   begin
      inst_cpri : cpri2
      generic map (
         INCLUDE_RX_EX_DELAY          => INCLUDE_RX_EX_DELAY,
         INCLUDE_TX_EX_DELAY          => INCLUDE_TX_EX_DELAY,
         INCLUDE_8b10b                => INCLUDE_8b10b,
         INCLUDE_CPU_SYNC             => INCLUDE_CPU_SYNC,
         INCLUDE_PHY_LOOP             => INCLUDE_PHY_LOOP,
         SYNC_MODE                    => SYNC_MODE,
         INCLUDE_PRBS                 => INCLUDE_PRBS,
         INCLUDE_MAP                  => (N_MAP /= 0),
         SYNC_MAP                     => (SYNC_MAP = 1),
         INCLUDE_MAC                  => (MAC_OFF = 0),
         INCLUDE_HDLC                 => (HDLC_OFF = 0),
         INCLUDE_CAL                  => (CAL_OFF = 0),
         WIDTH_MAP_RX_ADDR            => WIDTH_MAP_RX_ADDR,
         WIDTH_MAP_TX_ADDR            => WIDTH_MAP_TX_ADDR,
         WIDTH_RX_BUF                 => WIDTH_RX_BUF,
         WIDTH_N_MAP                  => WIDTH_N_MAP,
         WIDTH_K                      => WIDTH_K,
         WIDTH_ETH_BUF                => 6,
         WIDTH_ETH_BLOCK              => WIDTH_ETH_BLOCK,
         WIDTH_HDLC_BUF               => 6,
         WIDTH_HDLC_BLOCK             => WIDTH_HDLC_BLOCK,
         WIDTH_RX                     => WIDTH_RX,
         N_MAP                        => N_MAP,
         LINERATE                     => LINERATE,
         DEVICE                       => DEVICE,
         MAP_MODE                     => MAP_MODE,
         INCLUDE_VSS                  => (VSS_OFF = 0)
      )
      port map (
         clk                          => cpri_clk,
         reset_rx                     => rx_digitalreset_cpri_clk_sync2,
         reset_tx                     => tx_digitalreset_cpri_clk_sync2,
         config_reset                 => config_reset,
         clk_ex_delay                 => clk_ex_delay,
         reset_ex_delay               => reset_ex_delay,
         hw_reset_assert              => hw_reset_assert,
         hw_reset_req                 => hw_reset_req,
         rate                         => rate,
         int_datarate_en              => int_datarate_en,
         int_datarate_set             => int_datarate_set,
         cpu_clk                      => cpu_clk,
         cpu_reset                    => cpu_reset,
         cpu_address(15 downto 2)     => cpu_address,
         cpu_address(1 downto 0)      => "00",
         cpu_byte_en                  => cpu_byteenable,
         cpu_wr_data                  => cpu_wr_data,
         cpu_rd_data                  => cpu_readdata,
         cpu_read                     => cpu_read,
         cpu_write                    => cpu_write,
         cpu_select                   => cpu_select,
         cpu_ack                      => cpu_ack,
         cpu_intr                     => cpu_intr,
         cpu_intr_vector              => cpu_irq_vector,
         cpri_map_rx_clk              => cpri_map_rx_clk,
         cpri_map_rx_reset            => cpri_map_rx_reset,
         cpri_map_rx_en               => cpri_map_rx_en,
         cpri_map_rx_start            => cpri_map_rx_start,
         cpri_map_rx_read             => cpri_map_rx_read,
         cpri_map_rx_resync           => cpri_map_rx_resync,
         cpri_map_rx_data             => cpri_map_rx_data,
         cpri_map_rx_ready            => cpri_map_rx_ready,
         cpri_map_rx_underflow        => cpri_map_rx_underflow,
         cpri_map_rx_overflow         => cpri_map_rx_overflow,             
         cpri_map_tx_clk              => cpri_map_tx_clk,
         cpri_map_tx_reset            => cpri_map_tx_reset,
         cpri_map_tx_en               => cpri_map_tx_en,
         cpri_map_tx_write            => cpri_map_tx_write,
         cpri_map_tx_resync           => cpri_map_tx_resync,
         cpri_map_tx_data             => cpri_map_tx_data,
         cpri_map_tx_ready            => cpri_map_tx_ready,
         cpri_map_tx_underflow        => cpri_map_tx_underflow,
         cpri_map_tx_overflow         => cpri_map_tx_overflow,
         cpri_rx_aux_data             => cpri_rx_aux_data_tmp,
         cpri_tx_aux_data             => cpri_tx_aux_data,
         cpri_tx_aux_mask             => cpri_tx_aux_mask,
         cpri_rx_sync_state           => cpri_rx_sync_state,
         cpri_rx_start                => cpri_rx_start,
         cpri_rx_rfp                  => cpri_rx_rfp,
         cpri_rx_hfp                  => cpri_rx_hfp,
         cpri_rx_bfn                  => cpri_rx_bfn,
         cpri_rx_hfn                  => cpri_rx_hfn,
         cpri_rx_seq                  => cpri_rx_seq,
         cpri_rx_x                    => cpri_rx_x,
         cpri_rx_k                    => cpri_rx_k,
         cpri_tx_sync_rfp             => cpri_tx_sync_rfp,
         cpri_tx_start                => cpri_tx_start,
         cpri_tx_rfp                  => cpri_tx_rfp,
         cpri_tx_hfp                  => cpri_tx_hfp,
         cpri_tx_bfn                  => cpri_tx_bfn,
         cpri_tx_hfn                  => cpri_tx_hfn,
         cpri_tx_seq                  => cpri_tx_seq,
         cpri_tx_x                    => cpri_tx_x,
         cpri_tx_k                    => cpri_tx_k,
         cpri_tx_error                => cpri_tx_error,
         cpri_rx_state                => cpri_rx_state,
         cpri_rx_cnt_sync             => cpri_rx_cnt_sync,
         cpri_rx_freq_alarm           => cpri_rx_freq_alarm,
         cpri_rx_bfn_state            => cpri_rx_bfn_state,
         cpri_rx_hfn_state            => cpri_rx_hfn_state,
         cpri_rx_lcv                  => cpri_rx_lcv,
         cpri_rx_los                  => cpri_rx_los,
         serdes_rx_clk                => serdes_rx_clk,
         serdes_rx_reset              => rx_digitalreset_serdes_rxclk_sync2,
         serdes_rx_los                => gxb_los,
         serdes_rx_data(79 downto 40) => (others => '0'),
         serdes_rx_data(39 downto 0)  => serdes_rx_data,
         serdes_rx_align_delay        => "000000",
         serdes_rx_align_en           => serdes_rx_align_en,     
         serdes_width                 => serdes_width,
         serdes_tx_clk                => serdes_tx_clk,
         serdes_tx_reset              => tx_digitalreset_serdes_txclk_sync2,
         serdes_tx_data               => serdes_tx_data_pl, 
         cpri_mii_txclk               => cpri_mii_txclk, 
         cpri_mii_txrd                => cpri_mii_txrd,
         cpri_mii_txen                => cpri_mii_txen,
         cpri_mii_txer                => cpri_mii_txer,
         cpri_mii_txd                 => cpri_mii_txd,
         cpri_mii_rxclk               => cpri_mii_rxclk,
         cpri_mii_rxwr                => cpri_mii_rxwr,
         cpri_mii_rxdv                => cpri_mii_rxdv,
         cpri_mii_rxer                => cpri_mii_rxer,
         cpri_mii_rxd                 => cpri_mii_rxd,
         tx_bitslip                   => tx_bitslipboundaryselect,
         bitslipdetect                => rx_bitslipboundaryselectout,
         syncstatus                   => rx_syncstatus,
         phy_ex_delay_period          => open,
         phy_rx_ex_buf_delay          => (others => '0'),
         phy_tx_ex_buf_delay          => (others => '0'),
         phy_rx_ex_buf_valid          => '0',
         phy_tx_ex_buf_valid          => '0',
         phy_tx_buf_delay             => (others => '0'),
         phy_rx_buf_delay             => (others => '0'),
         phy_rx_buf_resync            => '0',
         phy_tx_pcs_clk               => '0',
         phy_rx_pma_clk               => '0',
         rx_buf_resync_cpu            => open
      );
   end generate;

   gen_arriavgt_98:
   if DEVICE = 5 and LINERATE = 5 generate -- Arria V GT 9.8G
   begin
      inst_cpri : cpri2
      generic map (
         INCLUDE_RX_EX_DELAY          => INCLUDE_RX_EX_DELAY,
         INCLUDE_TX_EX_DELAY          => INCLUDE_TX_EX_DELAY,
         INCLUDE_8b10b                => INCLUDE_8b10b,
         INCLUDE_CPU_SYNC             => INCLUDE_CPU_SYNC,
         INCLUDE_PHY_LOOP             => INCLUDE_PHY_LOOP,
         SYNC_MODE                    => SYNC_MODE,
         INCLUDE_PRBS                 => INCLUDE_PRBS,
         INCLUDE_MAP                  => (N_MAP /= 0),
         SYNC_MAP                     => (SYNC_MAP = 1),
         INCLUDE_MAC                  => (MAC_OFF = 0),
         INCLUDE_HDLC                 => (HDLC_OFF = 0),
         INCLUDE_CAL                  => (CAL_OFF = 0),
         WIDTH_MAP_RX_ADDR            => WIDTH_MAP_RX_ADDR,
         WIDTH_MAP_TX_ADDR            => WIDTH_MAP_TX_ADDR,
         WIDTH_RX_BUF                 => WIDTH_RX_BUF,
         WIDTH_N_MAP                  => WIDTH_N_MAP,
         WIDTH_K                      => WIDTH_K,
         WIDTH_ETH_BUF                => 6,
         WIDTH_ETH_BLOCK              => WIDTH_ETH_BLOCK,
         WIDTH_HDLC_BUF               => 6,
         WIDTH_HDLC_BLOCK             => WIDTH_HDLC_BLOCK,
         WIDTH_RX                     => WIDTH_RX,
         N_MAP                        => N_MAP,
         LINERATE                     => LINERATE,
         DEVICE                       => DEVICE,
         MAP_MODE                     => MAP_MODE,
         INCLUDE_VSS                  => (VSS_OFF = 0)
      )
      port map (
         clk                          => cpri_clk,
         reset_rx                     => rx_digitalreset_cpri_clk_sync2,
         reset_tx                     => rx_digitalreset_cpri_clk_sync2,
         config_reset                 => config_reset,
         clk_ex_delay                 => clk_ex_delay,
         reset_ex_delay               => reset_ex_delay,
         hw_reset_assert              => hw_reset_assert,
         hw_reset_req                 => hw_reset_req,
         rate                         => rate,
         int_datarate_en              => int_datarate_en,
         int_datarate_set             => int_datarate_set,
         cpu_clk                      => cpu_clk,
         cpu_reset                    => cpu_reset,
         cpu_address(15 downto 2)     => cpu_address,
         cpu_address(1 downto 0)      => "00",
         cpu_byte_en                  => cpu_byteenable,
         cpu_wr_data                  => cpu_wr_data,
         cpu_rd_data                  => cpu_readdata,
         cpu_read                     => cpu_read,
         cpu_write                    => cpu_write,
         cpu_select                   => cpu_select,
         cpu_ack                      => cpu_ack,
         cpu_intr                     => cpu_intr,
         cpu_intr_vector              => cpu_irq_vector,
         cpri_map_rx_clk              => cpri_map_rx_clk,
         cpri_map_rx_reset            => cpri_map_rx_reset,
         cpri_map_rx_en               => cpri_map_rx_en,
         cpri_map_rx_start            => cpri_map_rx_start,
         cpri_map_rx_read             => cpri_map_rx_read,
         cpri_map_rx_resync           => cpri_map_rx_resync,
         cpri_map_rx_data             => cpri_map_rx_data,
         cpri_map_rx_ready            => cpri_map_rx_ready,
         cpri_map_rx_underflow        => cpri_map_rx_underflow,
         cpri_map_rx_overflow         => cpri_map_rx_overflow,             
         cpri_map_tx_clk              => cpri_map_tx_clk,
         cpri_map_tx_reset            => cpri_map_tx_reset,
         cpri_map_tx_en               => cpri_map_tx_en,
         cpri_map_tx_write            => cpri_map_tx_write,
         cpri_map_tx_resync           => cpri_map_tx_resync,
         cpri_map_tx_data             => cpri_map_tx_data,
         cpri_map_tx_ready            => cpri_map_tx_ready,
         cpri_map_tx_underflow        => cpri_map_tx_underflow,
         cpri_map_tx_overflow         => cpri_map_tx_overflow,
         cpri_rx_aux_data             => cpri_rx_aux_data_tmp,
         cpri_tx_aux_data             => cpri_tx_aux_data,
         cpri_tx_aux_mask             => cpri_tx_aux_mask,
         cpri_rx_sync_state           => cpri_rx_sync_state,
         cpri_rx_start                => cpri_rx_start,
         cpri_rx_rfp                  => cpri_rx_rfp,
         cpri_rx_hfp                  => cpri_rx_hfp,
         cpri_rx_bfn                  => cpri_rx_bfn,
         cpri_rx_hfn                  => cpri_rx_hfn,
         cpri_rx_seq                  => cpri_rx_seq,
         cpri_rx_x                    => cpri_rx_x,
         cpri_rx_k                    => cpri_rx_k,
         cpri_tx_sync_rfp             => cpri_tx_sync_rfp,
         cpri_tx_start                => cpri_tx_start,
         cpri_tx_rfp                  => cpri_tx_rfp,
         cpri_tx_hfp                  => cpri_tx_hfp,
         cpri_tx_bfn                  => cpri_tx_bfn,
         cpri_tx_hfn                  => cpri_tx_hfn,
         cpri_tx_seq                  => cpri_tx_seq,
         cpri_tx_x                    => cpri_tx_x,
         cpri_tx_k                    => cpri_tx_k,
         cpri_tx_error                => cpri_tx_error,
         cpri_rx_state                => cpri_rx_state,
         cpri_rx_cnt_sync             => cpri_rx_cnt_sync,
         cpri_rx_freq_alarm           => cpri_rx_freq_alarm,
         cpri_rx_bfn_state            => cpri_rx_bfn_state,
         cpri_rx_hfn_state            => cpri_rx_hfn_state,
         cpri_rx_lcv                  => cpri_rx_lcv,
         cpri_rx_los                  => cpri_rx_los,
         serdes_rx_clk                => serdes_rx_clk,
         serdes_rx_reset              => rx_digitalreset_serdes_rxclk_sync2,
         serdes_rx_los                => gxb_los,
         serdes_rx_data(79 downto 40) => (others => '0'),
         serdes_rx_data(39 downto 0)  => serdes_rx_data,
         serdes_rx_align_delay        => "000000",
         serdes_rx_align_en           => serdes_rx_align_en,     
         serdes_width                 => serdes_width,
         serdes_tx_clk                => serdes_tx_clk,
         serdes_tx_reset              => rx_digitalreset_serdes_txclk_sync2,
         serdes_tx_data               => serdes_tx_data_pl, 
         cpri_mii_txclk               => cpri_mii_txclk, 
         cpri_mii_txrd                => cpri_mii_txrd,
         cpri_mii_txen                => cpri_mii_txen,
         cpri_mii_txer                => cpri_mii_txer,
         cpri_mii_txd                 => cpri_mii_txd,
         cpri_mii_rxclk               => cpri_mii_rxclk,
         cpri_mii_rxwr                => cpri_mii_rxwr,
         cpri_mii_rxdv                => cpri_mii_rxdv,
         cpri_mii_rxer                => cpri_mii_rxer,
         cpri_mii_rxd                 => cpri_mii_rxd,
         tx_bitslip                   => tx_bitslipboundaryselect,
         bitslipdetect                => rx_bitslipboundaryselectout,
         syncstatus                   => rx_syncstatus,
         phy_ex_delay_period          => ex_delay_period,
         phy_rx_ex_buf_delay          => rx_ex_buf_delay,
         phy_rx_ex_buf_valid          => rx_ex_buf_valid,
         phy_rx_buf_delay             => rx_buf_delay,
         phy_tx_ex_buf_delay          => tx_ex_buf_delay,
         phy_tx_ex_buf_valid          => tx_ex_buf_valid,
         phy_tx_buf_delay             => tx_buf_delay,
         phy_rx_buf_resync            => rx_buf_resync,
         phy_tx_pcs_clk               => usr_clk,
         phy_rx_pma_clk               => rx_clkout,
         rx_buf_resync_cpu            => rx_buf_resync_cpu
      );
   end generate;
 
---------------------------------------------------------------------------------------------------------------------
------------------------------------------------ reset synchronization ----------------------------------------------
---------------------------------------------------------------------------------------------------------------------

   process(reconfig_clk)
   begin
      if reconfig_clk'event and reconfig_clk = '1' then 
         rx_digitalreset_sync <= rx_digitalreset;
         tx_digitalreset_sync <= tx_digitalreset;
      end if;
   end process;

   process(cpri_clk)
   begin
      if cpri_clk'event and cpri_clk = '1' then 
         rx_digitalreset_cpri_clk_sync1 <= rx_digitalreset_sync;
         rx_digitalreset_cpri_clk_sync2 <= rx_digitalreset_cpri_clk_sync1;
         tx_digitalreset_cpri_clk_sync1 <= tx_digitalreset_sync;
         tx_digitalreset_cpri_clk_sync2 <= tx_digitalreset_cpri_clk_sync1;
      end if;
   end process;

   process(serdes_tx_clk)
   begin
      if serdes_tx_clk'event and serdes_tx_clk = '1' then 
         rx_digitalreset_serdes_txclk_sync1 <= rx_digitalreset_sync;
         rx_digitalreset_serdes_txclk_sync2 <= rx_digitalreset_serdes_txclk_sync1;
      end if;
   end process;

   process(serdes_tx_clk)
   begin
      if serdes_tx_clk'event and serdes_tx_clk = '1' then 
         tx_digitalreset_serdes_txclk_sync1 <= tx_digitalreset_sync;
         tx_digitalreset_serdes_txclk_sync2 <= tx_digitalreset_serdes_txclk_sync1;
      end if;
   end process;

   process(serdes_rx_clk)
   begin
      if serdes_rx_clk'event and serdes_rx_clk = '1' then 
         rx_digitalreset_serdes_rxclk_sync1 <= rx_digitalreset_sync;
         rx_digitalreset_serdes_rxclk_sync2 <= rx_digitalreset_serdes_rxclk_sync1;
      end if;
   end process;

   gen_reset_controller: 
   if DEVICE < 4 generate
   begin   
      process(reconfig_clk, reset)
         variable loss_cnt  : integer := 0;
         variable align_cnt : integer := 0;
      begin
         if (reset = '1') then
            rx_enapatternalign       <= '0';
            loss_cnt                 := 0;
            align_cnt                := 0;
            serdes_rx_align_en_sync1 <= '0';
            serdes_rx_align_en_sync2 <= '0';
         elsif (reconfig_clk'event and reconfig_clk = '1') then
            serdes_rx_align_en_sync1 <= serdes_rx_align_en;
            serdes_rx_align_en_sync2 <= serdes_rx_align_en_sync1;
            if (serdes_rx_align_en_sync2 = '1') then
               if loss_cnt = 256 then
                  rx_enapatternalign <= '1';
                  if (align_cnt = 1024) then
                     loss_cnt  := 0;
                     align_cnt := 0;
                  else
                     align_cnt := align_cnt + 1;   
                  end if;
               else
                  rx_enapatternalign <= '0';
                  loss_cnt := loss_cnt + 1;
               end if;
            else
               rx_enapatternalign <= '0';
               loss_cnt  := 0;
               align_cnt := 0;
            end if;
         end if;
      end process;

      inst_reset_controller : reset_controller
      generic map(
         DEVICE             => DEVICE
      )
      port map (
         clk                => reconfig_clk,
         reset	            => reset,     
         pll_locked         => pll_locked,
         pll_configupdate   => pll_configupdate,
         pll_reconfig_done  => s_pll_reconfig_done,
         pll_areset         => pll_areset,
         rx_freqlocked      => rx_freqlocked, 
         reconfig_busy      => reconfig_busy,
         reconfig_write     => reconfig_write,
         reconfig_done      => reconfig_done,
         tx_digitalreset    => tx_digitalreset,
         rx_digitalreset    => rx_digitalreset,
         rx_analogreset     => rx_analogreset,
         done               => s_reset_done
      );
      end generate ; 

---------------------------------------------------------------------------------------------------------------------
------------------------------------------------ IF GENERATE BLOCK --------------------------------------------------
---------------------------------------------------------------------------------------------------------------------

   gen_reset_rx_phy_ip:
   if DEVICE > 3 generate
   begin
      process(reconfig_clk, reset)
         variable loss_cnt  : integer := 0;
         variable align_cnt : integer := 0;
      begin
         if (reset = '1') then
            loss_cnt                 := 0;
            align_cnt                := 0;
            serdes_rx_align_en_sync1 <= '0';
            serdes_rx_align_en_sync2 <= '0';
            phy_mgmt_write_temp      <= '0';             
            phy_mgmt_read_temp       <= '0';              
            phy_mgmt_writedata_temp  <= (others =>'0');
            phy_mgmt_address_temp    <= (others =>'0');
         elsif (reconfig_clk'event and reconfig_clk = '1') then
            serdes_rx_align_en_sync1 <= serdes_rx_align_en;
            serdes_rx_align_en_sync2 <= serdes_rx_align_en_sync1;
            if (serdes_rx_align_en_sync2 = '1') then
               if loss_cnt = 256 then
                  phy_mgmt_write_temp     <= '1';             
                  phy_mgmt_read_temp      <= '0';              
                  phy_mgmt_writedata_temp <= X"00000001";
                  phy_mgmt_address_temp   <= X"214"; -- Register 0x085 to set rx_enapatternalign 
                  if (align_cnt = 1024) then
                     loss_cnt  := 0;
                     align_cnt := 0;
                  else
                     align_cnt := align_cnt + 1;   
                  end if;
               else
                  phy_mgmt_write_temp     <= '1';             
                  phy_mgmt_read_temp      <= '0';              
                  phy_mgmt_writedata_temp <= X"00000000";
                  phy_mgmt_address_temp   <= X"214";
                  loss_cnt := loss_cnt + 1;
               end if;
            else
               phy_mgmt_write_temp     <= '0';             
               phy_mgmt_read_temp      <= '0';              
               phy_mgmt_writedata_temp <= X"00000000";
               phy_mgmt_address_temp   <= X"214";
               loss_cnt  := 0;
               align_cnt := 0;
            end if;
         end if;
      end process;
   end generate;
   
   gen_reset_done_non_phy_ip: 
   if DEVICE < 4 generate
   begin
      reset_done <= s_reset_done; 
   end generate ; 
	
   gen_reset_done_phy_ip: 
   if DEVICE > 3 generate
   begin
      reset_done      <= rx_ready; 	
      rx_digitalreset <= not rx_ready;
   end generate ; 

   gen_sv_av_cv_autorate:
   if DEVICE > 3 generate
   begin
       tx_digitalreset <= not tx_ready;     
   end generate;
	 
   gen_master:
   if SYNC_MODE = 0 generate
   begin
      reconfig_fromgxb_s_tx <= (others => '0');
      reconfig_fromgxb_s_rx <= (others => '0');
   end generate;

   gen_slave:
   if SYNC_MODE = 1 generate
   begin
      reconfig_fromgxb_m <= (others => '0');
   end generate;
  
   gen_remove_reconfig_fromgxb:
   if DEVICE > 3 generate
   begin
      reconfig_fromgxb_m    <= (others => '0');
      reconfig_fromgxb_s_tx <= (others => '0');
      reconfig_fromgxb_s_rx <= (others => '0');
   end generate;

   gen_c4gx_pll_reconfig_done:
   if DEVICE /= 3 generate
      s_pll_reconfig_done <= (others => '0');
      pll_scandataout     <= (others => '0');
   end generate;
 
   gen_a2gx_autorate_off:
   if DEVICE = 1 and AUTORATE = 0 generate
      process(tx_clkout,rx_digitalreset_serdes_txclk_sync2)
      begin
         if rx_digitalreset_serdes_txclk_sync2 = '1' then 
            serdes_tx_data    <= (others => '0');
            tx_datainfull     <= (others => '0');
            tx_datainfull_pl2 <= (others => '0');
         elsif tx_clkout'event and tx_clkout = '1' then
            serdes_tx_data    <= serdes_tx_data_pl;
            tx_datainfull_pl2 <= tx_datainfull_pl;
            tx_datainfull     <= tx_datainfull_pl2;
         end if;
      end process;
   end generate;

   gen_a2gx_autorate_on:
   if DEVICE = 1 and AUTORATE = 1 generate
      process(tx_clkout,rx_digitalreset_serdes_txclk_sync2)
      begin
         if rx_digitalreset_serdes_txclk_sync2 = '1' then 
            serdes_tx_data    <= (others => '0');
            tx_datainfull     <= (others => '0');
            tx_datainfull_pl2 <= (others => '0');
            tx_datainfull_pl3 <= (others => '0');
         elsif tx_clkout'event and tx_clkout = '1' then
            serdes_tx_data    <= serdes_tx_data_pl;
            tx_datainfull_pl2 <= tx_datainfull_pl;
            tx_datainfull_pl3 <= tx_datainfull_pl2;
            tx_datainfull     <= tx_datainfull_pl3;
         end if;
      end process;
   end generate;

   gen_s4gx_a2gz_c4gx:
   if DEVICE = 0 or DEVICE = 2 or DEVICE = 3 generate
      process(tx_clkout,rx_digitalreset_serdes_txclk_sync2)
      begin
         if rx_digitalreset_serdes_txclk_sync2 = '1' then 
            serdes_tx_data <= (others => '0');
            tx_datainfull  <= (others => '0');
         elsif tx_clkout'event and tx_clkout = '1' then
            serdes_tx_data <= serdes_tx_data_pl;
            tx_datainfull  <= tx_datainfull_pl;
         end if;
      end process;
   end generate;

   gen_s5gx_a5gx_c5gx:
   if DEVICE > 3 generate
      process(tx_clkout,tx_digitalreset_serdes_txclk_sync2)
      begin
         if tx_digitalreset_serdes_txclk_sync2 = '1' then
            serdes_tx_data      <= (others => '0');
            tx_parallel_data_pl <= (others => '0');
            tx_datak_pl         <= (others => '0');
         elsif tx_clkout'event and tx_clkout = '1' then
            serdes_tx_data      <= serdes_tx_data_pl;
            tx_parallel_data_pl <= tx_parallel_data;
            tx_datak_pl         <= tx_datak;
         end if;
      end process;
   end generate;
---------------------------------------------------------------------------------------------------------------------
------------------------------- Autorate off ------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
   
------------------------------ StratixIV or ArriaIIGZ ---------------------------------------------------------------
   gen_autorate_off:
   if AUTORATE = 0 generate
   begin
      int_datarate_en <= '0';
      gen_stratix_iv_gx_or_arria_ii_gz:
      if DEVICE = 0 or DEVICE = 2 generate
      begin
         gen_614mbps:
         if LINERATE = 614 generate
            signal txclk_div4  : std_logic := '0';
         begin
            process(tx_clkout)
               variable txclk_div2i : std_logic := '0';
            begin
               if tx_clkout'event and tx_clkout = '1' then
                  txclk_div2i := not txclk_div2i;
                  if txclk_div2i = '1' then
                     txclk_div4 <= not txclk_div4;
                  end if;
               end if;
            end process;
            tx_datainfull_pl(7 downto 0)              <= serdes_tx_data(7 downto 0);              --tx_datain
            tx_datainfull_pl(8)                       <= serdes_tx_data(8);                       --tx_ctrlenable
            tx_datainfull_pl(32 downto 9)             <= (others => '0');
            serdes_rx_data(7 downto 0)                <= rx_dataoutfull(7 downto 0);              --rx_dataout
            serdes_rx_data(8)                         <= rx_dataoutfull(8);                       --rx_ctrldetect
            serdes_rx_data(9)                         <= rx_dataoutfull(9) or rx_dataoutfull(11); --rx_errdetect
            serdes_rx_data(39 downto 10)              <= (others => '0');
            rx_errdetect(0)                           <= rx_dataoutfull(9);
            rx_disperr(0)                             <= rx_dataoutfull(11);
            rx_errdetect(3 downto 1)                  <= (others => '0');       
            rx_disperr(3 downto 1)                    <= (others => '0');
            cpri_clk                                  <= txclk_div4;
            cpri_clkout                               <= txclk_div4;
            pll_clkout                                <= rx_clkout;
            serdes_tx_clk                             <= tx_clkout;
            serdes_rx_clk                             <= rx_clkout;
            serdes_width                              <= "00";
            rate                                      <= "00001";
         end generate;   
         gen_not_614mbps:
         if LINERATE /= 614 generate
         begin
            process(serdes_tx_data)
            begin
               for n in 3 downto 0 loop
                  tx_datainfull_pl(n*11+7 downto n*11)<= serdes_tx_data((3-n)*10+7 downto 10*(3-n)); --tx_datain
                  tx_datainfull_pl(n*11+8)            <= serdes_tx_data((3-n)*10+8);                 --tx_ctrlenable
               end loop;
            end process;
            process(rx_dataoutfull)
            begin
               for n in 3 downto 0 loop
                  serdes_rx_data(n*10+7 downto n*10)  <= rx_dataoutfull((3-n)*16+7 downto (3-n)*16); --rx_dataout
                  serdes_rx_data(n*10+8)              <= rx_dataoutfull((3-n)*16+8);                 --rx_ctrldetect
                  --rx_err_disp
                  serdes_rx_data(n*10+9)              <= rx_dataoutfull((3-n)*16+9) or rx_dataoutfull(n*16+11);
                  rx_errdetect(3-n)                   <= rx_dataoutfull(n*16+9); 
                  rx_disperr(3-n)                     <= rx_dataoutfull(n*16+11);
               end loop;
            end process;
            tx_datainfull_pl(9)                       <= '0'; 
            tx_datainfull_pl(20)                      <= '0';
            tx_datainfull_pl(31)                      <= '0';
            tx_datainfull_pl(42)                      <= '0';
            tx_datainfull_pl(10)                      <= '0';
            tx_datainfull_pl(21)                      <= '0';
            tx_datainfull_pl(32)                      <= '0';
            tx_datainfull_pl(43)                      <= '0';         
            cpri_clk                                  <= tx_clkout;
            cpri_clkout                               <= tx_clkout;
            pll_clkout                                <= rx_clkout;
            serdes_tx_clk                             <= tx_clkout;
            serdes_rx_clk                             <= rx_clkout;
            serdes_width                              <= "10";
            rate                                      <= "00010" when LINERATE = 0 else
                                                         "00100" when LINERATE = 1 else
                                                         "00101" when LINERATE = 2 else
                                                         "01000" when LINERATE = 3 else
                                                         "01010" when LINERATE = 4 else
                                                         "10000" when LINERATE = 5;
         end generate;
      end generate;
      
-------------------------------------------------- ArriaIIGX --------------------------------------------------------
      gen_arria_ii_gx:
      if DEVICE = 1 generate
      begin
         gen_614mbps:
         if LINERATE = 614 generate
            signal txclk_div4  : std_logic := '0';
         begin
            process(tx_clkout)
               variable txclk_div2i : std_logic := '0';
            begin
               if tx_clkout'event and tx_clkout = '1' then
                  txclk_div2i := not txclk_div2i;
                  if txclk_div2i = '1' then
                     txclk_div4 <= not txclk_div4;
                  end if;
               end if;
            end process;            
            tx_datainfull_pl(7 downto 0)              <= serdes_tx_data(7 downto 0);              --tx_datain
            tx_datainfull_pl(8)                       <= serdes_tx_data(8);                       --tx_ctrlenable
            tx_datainfull_pl(32 downto 9)             <= (others => '0');
            serdes_rx_data(7 downto 0)                <= rx_dataoutfull(7 downto 0);              --rx_dataout
            serdes_rx_data(8)                         <= rx_dataoutfull(8);                       --rx_ctrldetect
            serdes_rx_data(9)                         <= rx_dataoutfull(9) or rx_dataoutfull(11); --rx_err
            serdes_rx_data(39 downto 10)              <= (others => '0');
            rx_errdetect(0)                           <= rx_dataoutfull(9);
            rx_disperr(0)                             <= rx_dataoutfull(11);
            rx_errdetect(3 downto 1)                  <= (others => '0');       
            rx_disperr(3 downto 1)                    <= (others => '0');
            cpri_clk                                  <= txclk_div4;
            cpri_clkout                               <= txclk_div4;
            pll_clkout                                <= rx_clkout;
            serdes_tx_clk                             <= tx_clkout;
            serdes_rx_clk                             <= rx_clkout;
            serdes_width                              <= "00";
            rate                                      <= "00001";
         end generate;
         gen_not_6144mbps:
         if LINERATE = 0 or
            LINERATE = 1 or
            LINERATE = 2 or
            LINERATE = 3 generate
            signal txclk_div2 : std_logic := '0';
         begin
            process(tx_clkout)
            begin
               if tx_clkout'event and tx_clkout = '1' then
                  txclk_div2 <= not txclk_div2;
               end if;
            end process;
            tx_datainfull_pl(7 downto 0)              <= serdes_tx_data(17 downto 10);             --tx_datain
            tx_datainfull_pl(8)                       <= serdes_tx_data(18);                       --tx_ctrlenable
            tx_datainfull_pl(18 downto 11)            <= serdes_tx_data(7 downto 0);               --tx_datain
            tx_datainfull_pl(19)                      <= serdes_tx_data(8);                        --tx_ctrlenable
            serdes_rx_data(7 downto 0)                <= rx_dataoutfull(23 downto 16);             --rx_dataout
            serdes_rx_data(8)                         <= rx_dataoutfull(24);                       --rx_ctrldetect
            serdes_rx_data(9)                         <= rx_dataoutfull(25) or rx_dataoutfull(43); --rx_err
            serdes_rx_data(17 downto 10)              <= rx_dataoutfull(7 downto 0);               --rx_dataout
            serdes_rx_data(18)                        <= rx_dataoutfull(8);                        --rx_ctrldetect
            serdes_rx_data(19)                        <= rx_dataoutfull(9) or rx_dataoutfull(11);  --rx_err
            serdes_rx_data(39 downto 20)              <= (others => '0');
            rx_errdetect(1 downto 0)                  <= rx_dataoutfull(25) & rx_dataoutfull(9);
            rx_disperr(1 downto 0)                    <= rx_dataoutfull(43) & rx_dataoutfull(11);
            rx_errdetect(3 downto 2)                  <= (others => '0');
            rx_disperr(3 downto 2)                    <= (others => '0');
            cpri_clk                                  <= txclk_div2;
            cpri_clkout                               <= txclk_div2;
            pll_clkout                                <= rx_clkout;
            serdes_tx_clk                             <= tx_clkout;
            serdes_rx_clk                             <= rx_clkout;
            serdes_width                              <= "01" when LINERATE = 0 else
                                                         "01" when LINERATE = 1 else
                                                         "01" when LINERATE = 2 else
                                                         "01" when LINERATE = 3;
            rate                                      <= "00010" when LINERATE = 0 else
                                                         "00100" when LINERATE = 1 else
                                                         "00101" when LINERATE = 2 else
                                                         "01000" when LINERATE = 3;
         end generate;
         gen_6144mbps:
         if LINERATE = 4 generate
            signal txclk_div2 : std_logic := '0';
            signal tx_clk_out : std_logic := '0';
         begin
            process(tx_clkout)
            begin
               if tx_clkout'event and tx_clkout = '1' then
                  txclk_div2 <= not txclk_div2;
               end if;
            end process;
            tx_datainfull_pl(7 downto 0)              <= serdes_tx_data(17 downto 10);             --tx_datain
            tx_datainfull_pl(8)                       <= serdes_tx_data(18);                       --tx_ctrlenable
            tx_datainfull_pl(18 downto 11)            <= serdes_tx_data(7 downto 0);               --tx_datain
            tx_datainfull_pl(19)                      <= serdes_tx_data(8);                        --tx_ctrlenable
            serdes_rx_data(7 downto 0)                <= rx_dataoutfull(23 downto 16);             --rx_dataout
            serdes_rx_data(8)                         <= rx_dataoutfull(24);                       --rx_ctrldetect
            serdes_rx_data(9)                         <= rx_dataoutfull(25) or rx_dataoutfull(43); --rx_err
            serdes_rx_data(17 downto 10)              <= rx_dataoutfull(7 downto 0);               --rx_dataout
            serdes_rx_data(18)                        <= rx_dataoutfull(8);                        --rx_ctrldetect
            serdes_rx_data(19)                        <= rx_dataoutfull(9) or rx_dataoutfull(11);  --rx_err
            serdes_rx_data(39 downto 20)              <= (others => '0');
            rx_errdetect(1 downto 0)                  <= rx_dataoutfull(25) & rx_dataoutfull(9);
            rx_disperr(1 downto 0)                    <= rx_dataoutfull(43) & rx_dataoutfull(11);
            rx_errdetect(3 downto 2)                  <= (others => '0');
            rx_disperr(3 downto 2)                    <= (others => '0');
            cpri_clk                                  <= tx_clk_out;
            cpri_clkout                               <= tx_clk_out;
            pll_clkout                                <= rx_clkout;
            serdes_tx_clk                             <= tx_clkout;
            serdes_rx_clk                             <= rx_clkout;
            serdes_width                              <= "01";
            rate                                      <= "01010";
            inst_tx_clock_switch : clock_switch
            port map (
               sel    => '0',
               reset  => tx_digitalreset_sync,
               clk0   => txclk_div2, 
               clk1   => '0',
               clkout => tx_clk_out
            );
         end generate;
      end generate;
     
--------------------------------------------------- CycloneIV -------------------------------------------------------
      gen_cyclone_iv_gx:
      if DEVICE = 3 generate
      begin
         gen_614mbps:
         if LINERATE = 614 generate
            signal txclk_div4  : std_logic := '0';
         begin
            process(tx_clkout)
               variable txclk_div2i : std_logic := '0';
            begin
               if tx_clkout'event and tx_clkout = '1' then
                  txclk_div2i := not txclk_div2i;
                  if txclk_div2i = '1' then
                     txclk_div4 <= not txclk_div4;
                  end if;
               end if;
            end process;
            tx_datainfull_pl(7 downto 0)              <= serdes_tx_data(7 downto 0);              --tx_datain
            tx_datainfull_pl(8)                       <= serdes_tx_data(8);                       --tx_ctrlenable
            tx_datainfull_pl(32 downto 9)             <= (others => '0');
            serdes_rx_data(7 downto 0)                <= rx_dataoutfull(7 downto 0);              --rx_dataout
            serdes_rx_data(8)                         <= rx_dataoutfull(8);                       --rx_ctrldetect
            serdes_rx_data(9)                         <= rx_dataoutfull(9) or rx_dataoutfull(11); --rx_errdetect
            serdes_rx_data(39 downto 10)              <= (others => '0');
            rx_errdetect(0)                           <= rx_dataoutfull(9);
            rx_disperr(0)                             <= rx_dataoutfull(11);
            rx_errdetect(3 downto 1)                  <= (others => '0');       
            rx_disperr(3 downto 1)                    <= (others => '0');
            cpri_clk                                  <= txclk_div4;
            cpri_clkout                               <= txclk_div4;
            pll_clkout                                <= rx_clkout;
            serdes_tx_clk                             <= tx_clkout;
            serdes_rx_clk                             <= rx_clkout;
            serdes_width                              <= "00";
            rate                                      <= "00001";
         end generate;   
         gen_not_614mbps:
         if LINERATE /= 614 generate
            signal txclk_div2 : std_logic := '0';
         begin
            process(tx_clkout)
            begin
               if tx_clkout'event and tx_clkout = '1' then
                  txclk_div2 <= not txclk_div2;                  
               end if;
            end process;
            tx_datainfull_pl(7 downto 0)              <= serdes_tx_data(17 downto 10);             --tx_datain
            tx_datainfull_pl(8)                       <= serdes_tx_data(18);                       --tx_ctrlenable
            tx_datainfull_pl(18 downto 11)            <= serdes_tx_data(7 downto 0);               --tx_datain
            tx_datainfull_pl(19)                      <= serdes_tx_data(8);                        --tx_ctrlenable
            tx_datainfull_pl(10 downto 9)             <= (others => '0'); 
            tx_datainfull_pl(43 downto 20)            <= (others => '0');
            serdes_rx_data(7 downto 0)                <= rx_dataoutfull(23 downto 16);             --rx_dataout
            serdes_rx_data(8)                         <= rx_dataoutfull(24);                       --rx_ctrldetect
            serdes_rx_data(9)                         <= rx_dataoutfull(25) or rx_dataoutfull(43); --rx_err
            serdes_rx_data(17 downto 10)              <= rx_dataoutfull(7 downto 0);               --rx_dataout
            serdes_rx_data(18)                        <= rx_dataoutfull(8);                        --rx_ctrldetect
            serdes_rx_data(19)                        <= rx_dataoutfull(9) or rx_dataoutfull(11);  --rx_err
            serdes_rx_data(39 downto 20)              <= (others => '0');
            rx_errdetect(1 downto 0)                  <= rx_dataoutfull(25) & rx_dataoutfull(9);
            rx_disperr(1 downto 0)                    <= rx_dataoutfull(43) & rx_dataoutfull(11);
            rx_errdetect(3 downto 2)                  <= (others => '0');
            rx_disperr(3 downto 2)                    <= (others => '0');
            cpri_clk                                  <= txclk_div2;
            cpri_clkout                               <= txclk_div2;
            pll_clkout                                <= rx_clkout;
            serdes_tx_clk                             <= tx_clkout;
            serdes_rx_clk                             <= rx_clkout;
            serdes_width                              <= "01" when LINERATE = 0 else
                                                         "01" when LINERATE = 1 else
                                                         "01" when LINERATE = 2; 
            rate                                      <= "00010" when LINERATE = 0 else
                                                         "00100" when LINERATE = 1 else
                                                         "00101" when LINERATE = 2;
         end generate;                            
      end generate;     
---------------------------------------------------Stratix V / Arria V GZ---------------------------------------------------------

      gen_stratix_v_arria_v_gz:
      if DEVICE = 4 or DEVICE = 7 generate
      begin
         gen_614mbps:
         if LINERATE = 614 generate
            signal txclk_div4  : std_logic := '0';
         begin
            process(tx_clkout)
               variable txclk_div2i : std_logic := '0';
            begin
               if tx_clkout'event and tx_clkout = '1' then
                  txclk_div2i := not txclk_div2i;
                  if txclk_div2i = '1' then
                     txclk_div4 <= not txclk_div4;
                  end if;
               end if;
            end process;
            tx_parallel_data(7 downto 0)                   <= serdes_tx_data(7 downto 0);               --tx_datain
            tx_parallel_data(8)                            <= serdes_tx_data(8);                        --tx_ctrlenable
            tx_parallel_data(43 downto 9)                  <= (others => '0');
            serdes_rx_data(7 downto 0)                     <= rx_parallel_data(7 downto 0);             --rx_dataout
            serdes_rx_data(8)                              <= rx_parallel_data(8);                      --rx_ctrldetect
            rx_errdetect(0)                                <= rx_parallel_data(9);
            rx_syncstatus(0)                               <= rx_parallel_data(10);
            rx_disperr(0)                                  <= rx_parallel_data(11);
            rx_errdetect(3 downto 1)                       <= (others => '0');
            rx_disperr(3 downto 1)                         <= (others => '0');
            serdes_rx_data(9)                              <= rx_errdetect(0) or rx_disperr(0);         
            serdes_rx_data(39 downto 10)                   <= (others => '0');
            cpri_clk                                       <= txclk_div4;
            cpri_clkout                                    <= txclk_div4;
            pll_clkout                                     <= rx_clkout;
            serdes_tx_clk                                  <= tx_clkout;
            serdes_rx_clk                                  <= rx_clkout;
            serdes_width                                   <= "00";
            rate                                           <= "00001";
         end generate;   
         gen_not_614mbps:
         if LINERATE /= 614 generate
         begin
            process(serdes_tx_data)
            begin
               for n in 3 downto 0 loop
                  tx_parallel_data(n*11+7 downto n*11)     <= serdes_tx_data((3-n)*10+7 downto 10*(3-n));
                  tx_parallel_data(n*11+8)                 <= serdes_tx_data((3-n)*10+8);
                  tx_parallel_data(n*11+10 downto n*11+9)  <= (others => '0');
               end loop;
                  tx_parallel_data(43 downto 41)           <= (others => '0');
            end process;
            process(rx_parallel_data,rx_errdetect,rx_disperr)
            begin
               for n in 3 downto 0 loop
                  serdes_rx_data(n*10+7 downto n*10)       <= rx_parallel_data((3-n)*16+7 downto (3-n)*16);      --rx_dataout
                  serdes_rx_data(n*10+8)                   <= rx_parallel_data((3-n)*16+8);                      --rx_ctrldetect
                  rx_errdetect(n)                          <= rx_parallel_data((3-n)*16+9);
                  rx_syncstatus(n)                         <= rx_parallel_data((3-n)*16+10);
                  rx_disperr(n)                            <= rx_parallel_data((3-n)*16+11);
                  serdes_rx_data(n*10+9)                   <= rx_errdetect(n) or rx_disperr(n);        
               end loop;
            end process;
            cpri_clk                                       <= tx_clkout;
            cpri_clkout                                    <= tx_clkout;
            serdes_rx_clk                                  <= rx_clkout;
            serdes_tx_clk                                  <= tx_clkout;
            pll_clkout                                     <= rx_clkout;
            serdes_width                                   <= "10";
            rate                                           <= "00010" when LINERATE = 0 else
                                                              "00100" when LINERATE = 1 else
                                                              "00101" when LINERATE = 2 else
                                                              "01000" when LINERATE = 3 else
                                                              "01010" when LINERATE = 4 else
                                                              "10000" when LINERATE = 5;
         end generate;
      end generate;

---------------------------------------------------Arria V / Cyclone V-----------------------------------------------------------
      gen_arria_v_cyclone_v:
      if DEVICE = 5 or DEVICE = 6 generate
      begin
         gen_614mbps:
         if LINERATE = 614 generate
            signal txclk_div4  : std_logic := '0';
         begin
            process(tx_clkout)
               variable txclk_div2i : std_logic := '0';
            begin
               if tx_clkout'event and tx_clkout = '1' then
                  txclk_div2i := not txclk_div2i;
                  if txclk_div2i = '1' then
                     txclk_div4 <= not txclk_div4;
                  end if;
               end if;
            end process;
            tx_parallel_data(7 downto 0)                   <= serdes_tx_data(7 downto 0);               --tx_datain
            tx_parallel_data(8)                            <= serdes_tx_data(8);                        --tx_ctrlenable
            tx_parallel_data(43 downto 9)                  <= (others => '0');
            serdes_rx_data(7 downto 0)                     <= rx_parallel_data(7 downto 0);             --rx_dataout
            serdes_rx_data(8)                              <= rx_parallel_data(8);                      --rx_ctrldetect
            rx_errdetect(0)                                <= rx_parallel_data(9);
            rx_syncstatus(0)                               <= rx_parallel_data(10);
            rx_disperr(0)                                  <= rx_parallel_data(11);
            rx_errdetect(3 downto 1)                       <= (others => '0');
            rx_disperr(3 downto 1)                         <= (others => '0');
            serdes_rx_data(9)                              <= rx_errdetect(0) or rx_disperr(0);         
            serdes_rx_data(39 downto 10)                   <= (others => '0');
            cpri_clk                                       <= txclk_div4;
            cpri_clkout                                    <= txclk_div4;
            pll_clkout                                     <= rx_clkout;
            serdes_tx_clk                                  <= tx_clkout;
            serdes_rx_clk                                  <= tx_clkout;
            serdes_width                                   <= "00";
            rate                                           <= "00001";
         end generate;   
         gen_not_614_9830mbps:
         if (LINERATE /= 614 and LINERATE /= 5) generate
         begin
            process(serdes_tx_data)
            begin
               for n in 3 downto 0 loop
                  tx_parallel_data(n*11+7 downto n*11)     <= serdes_tx_data((3-n)*10+7 downto 10*(3-n));
                  tx_parallel_data(n*11+8)                 <= serdes_tx_data((3-n)*10+8);
                  tx_parallel_data(n*11+10 downto n*11+9)  <= (others => '0');
               end loop;
                  tx_parallel_data(43 downto 41)           <= (others => '0');
            end process;
            process(rx_parallel_data,rx_errdetect,rx_disperr)
            begin
               for n in 3 downto 0 loop
                  serdes_rx_data(n*10+7 downto n*10)       <= rx_parallel_data((3-n)*16+7 downto (3-n)*16);      --rx_dataout
                  serdes_rx_data(n*10+8)                   <= rx_parallel_data((3-n)*16+8);                      --rx_ctrldetect
                  rx_errdetect(n)                          <= rx_parallel_data((3-n)*16+9);
                  rx_syncstatus(n)                         <= rx_parallel_data((3-n)*16+10);
                  rx_disperr(n)                            <= rx_parallel_data((3-n)*16+11);
                  serdes_rx_data(n*10+9)                   <= rx_errdetect(n) or rx_disperr(n);        
               end loop;
            end process;
            cpri_clk                                       <= tx_clkout;
            cpri_clkout                                    <= tx_clkout;
            serdes_rx_clk                                  <= rx_clkout;
            serdes_tx_clk                                  <= tx_clkout;
            pll_clkout                                     <= rx_clkout;
            serdes_width                                   <= "10";
            rate                                           <= "00010" when LINERATE = 0 else
                                                              "00100" when LINERATE = 1 else
                                                              "00101" when LINERATE = 2 else -- Cyclone V will support until 3.072Gbps
                                                              "01000" when LINERATE = 3 else
                                                              "01010" when LINERATE = 4;
         end generate;
         gen_9830mbps:
         if LINERATE = 5 generate
         begin
            process(serdes_tx_data)
            begin
               for n in 3 downto 0 loop
                  tx_parallel_data(n*8+7 downto n*8)       <= serdes_tx_data((3-n)*10+7 downto 10*(3-n));
                  tx_datak(n)                              <= serdes_tx_data((3-n)*10+8);
               end loop;
               tx_parallel_data(43 downto 32)              <= (others => '0');
            end process;
            process(rx_parallel_data,rx_datak,rx_errdetect,rx_disperr)
            begin
               for n in 3 downto 0 loop
                  serdes_rx_data(n*10+7 downto n*10)       <= rx_parallel_data(31-8*n downto 24-8*n); --rx_dataout
                  serdes_rx_data(n*10+8)                   <= rx_datak(3-n);                          --rx_ctrldetect
                  serdes_rx_data(n*10+9)                   <= rx_errdetect(3-n) or rx_disperr(3-n);   --rx_errdetect
               end loop;
            end process;      
            cpri_clk                                       <= tx_clkout;
            cpri_clkout                                    <= tx_clkout;
            serdes_rx_clk                                  <= tx_clkout;
            serdes_tx_clk                                  <= tx_clkout;
            pll_clkout                                     <= rx_clkout;
            serdes_width                                   <= "10";
            rate                                           <= "10000";
            data_width_pma                                 <= "1010000";
         end generate;
      end generate;
   end generate;

   datarate_en  <= int_datarate_en;
   datarate_set <= rate when AUTORATE = 0 else
                   int_datarate_set;  

---------------------------------------------------------------------------------------------------------------------
-----------------------------------------------Autorate on-----------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------

   gen_autorate_on:
   if AUTORATE = 1 generate
      signal tx_clk_sel       : std_logic;
      signal tx_clk_out       : std_logic;
   begin
      int_datarate_en <= '1';
      rate <= int_datarate_set;

      process(tx_clkout)
      begin
         if tx_clkout'event and tx_clkout = '1' then
            int_datarate_set_tx_clkout_sync1 <= int_datarate_set;
            int_datarate_set_tx_clkout_sync2 <= int_datarate_set_tx_clkout_sync1;
         end if;
      end process;

      process(rx_clkout)
      begin
         if rx_clkout'event and rx_clkout = '1' then
            int_datarate_set_rx_clkout_sync1 <= int_datarate_set;
            int_datarate_set_rx_clkout_sync2 <= int_datarate_set_rx_clkout_sync1;
         end if;
      end process;

--------------------------------- StratixIV or ArriaIIGZ -----------------------------------------------------------------------------
      gen_stratix_iv_gx_or_arria_ii_gz:
      if DEVICE = 0 or DEVICE = 2 generate
         signal txclk_div4 : std_logic := '0';
      begin
         process(tx_clkout)
            variable txclk_div2i : std_logic := '0';
         begin
            if tx_clkout'event and tx_clkout = '1' then
               txclk_div2i := not txclk_div2i;
               if txclk_div2i = '1' then
                  txclk_div4 <= not txclk_div4;
               end if;
            end if;
         end process;

         process(int_datarate_set_tx_clkout_sync2,
                 int_datarate_set_rx_clkout_sync2,
                 serdes_tx_data,
                 rx_dataoutfull)
         begin
            if int_datarate_set_tx_clkout_sync2 = "00001" then
               tx_datainfull_pl(7 downto 0)          <= serdes_tx_data(7 downto 0); --tx_datain
               tx_datainfull_pl(8)                   <= serdes_tx_data(8);          --tx_ctrlenable
               tx_datainfull_pl(43 downto 9)         <= (others => '0');
               tx_clk_sel                            <= '1';
            else
               for n in 3 downto 0 loop
                  tx_datainfull_pl(n*11+7 downto n*11)  <= serdes_tx_data((3-n)*10+7 downto 10*(3-n)); --tx_datain
                  tx_datainfull_pl(n*11+8)              <= serdes_tx_data((3-n)*10+8);                 --tx_ctrlenable
               end loop;
               tx_datainfull_pl(9)                   <= '0'; 
               tx_datainfull_pl(20)                  <= '0';
               tx_datainfull_pl(31)                  <= '0';
               tx_datainfull_pl(42)                  <= '0';
               tx_datainfull_pl(10)                  <= '0';
               tx_datainfull_pl(21)                  <= '0';
               tx_datainfull_pl(32)                  <= '0';
               tx_datainfull_pl(43)                  <= '0';
               tx_clk_sel                            <= '0';
            end if;
            if int_datarate_set_rx_clkout_sync2 = "00001" then
               serdes_rx_data(7 downto 0)            <= rx_dataoutfull(7 downto 0);                 --rx_dataout
               serdes_rx_data(8)                     <= rx_dataoutfull(8);                          --rx_ctrldetect
               serdes_rx_data(9)                     <= rx_dataoutfull(9) or rx_dataoutfull(11);    --rx_err
               serdes_rx_data(39 downto 10)          <= (others => '0');
               rx_errdetect(0)                       <= rx_dataoutfull(9);
               rx_disperr(0)                         <= rx_dataoutfull(11);
               rx_errdetect(3 downto 1)              <= (others => '0');
               rx_disperr(3 downto 1)               <= (others => '0');
               serdes_width                          <= "00";
            else
               for n in 3 downto 0 loop
                  serdes_rx_data(n*10+7 downto n*10) <= rx_dataoutfull((3-n)*16+7 downto (3-n)*16); --rx_dataout
                  serdes_rx_data(n*10+8)             <= rx_dataoutfull((3-n)*16+8);                 --rx_ctrldetect
                  -- rx_err_disp
                  serdes_rx_data(n*10+9)             <= rx_dataoutfull((3-n)*16+9) or rx_dataoutfull((3-n)*16+11);
                  rx_errdetect(3-n)                  <= rx_dataoutfull(n*16+9);
                  rx_disperr(3-n)                    <= rx_dataoutfull(n*16+11);
               end loop;
               serdes_width                          <= "10";
            end if;
         end process;

         cpri_clk      <= tx_clk_out;
         cpri_clkout   <= tx_clk_out;
         pll_clkout    <= rx_clkout;
         serdes_tx_clk <= tx_clkout;
         serdes_rx_clk <= rx_clkout;
        
         inst_tx_clock_switch : clock_switch
         port map (
            sel    => tx_clk_sel,
            reset  => tx_digitalreset_sync,
            clk0   => tx_clkout, 
            clk1   => txclk_div4,
            clkout => tx_clk_out
         );
      end generate;

---------------------------------------- ArriaIIGX ------------------------------------------------------------------
      gen_arria_ii_gx:
      if DEVICE = 1 generate
         signal txclk_div2 : std_logic := '0';
         signal txclk_div4 : std_logic := '0';
      begin

         process(tx_clkout)
            variable txclk_div2i : std_logic := '0';
         begin
            if tx_clkout'event and tx_clkout = '1' then
               txclk_div2i := not txclk_div2i;
               txclk_div2 <= not txclk_div2;
               if txclk_div2i = '1' then
                  txclk_div4 <= not txclk_div4;
               end if;
            end if;
         end process;

         process(int_datarate_set_tx_clkout_sync2,
                 int_datarate_set_rx_clkout_sync2,
                 serdes_tx_data,
                 rx_dataoutfull)
         begin
            if int_datarate_set_tx_clkout_sync2 = "00001" then
               tx_datainfull_pl(7 downto 0)          <= serdes_tx_data(7 downto 0);               --tx_datain
               tx_datainfull_pl(8)                   <= serdes_tx_data(8);                        --tx_ctrlenable
               tx_datainfull_pl(43 downto 9)         <= (others => '0');
               tx_clk_sel                            <= '1';
            else
               tx_datainfull_pl(7 downto 0)          <= serdes_tx_data(17 downto 10);             --tx_datain
               tx_datainfull_pl(8)                   <= serdes_tx_data(18);                       --tx_ctrlenable
               tx_datainfull_pl(9)                   <= '0';
               tx_datainfull_pl(10)                  <= '0';
               tx_datainfull_pl(18 downto 11)        <= serdes_tx_data(7 downto 0);               --tx_datain
               tx_datainfull_pl(19)                  <= serdes_tx_data(8);                        --tx_ctrlenable
               tx_datainfull_pl(43 downto 20)        <= (others => '0');
               tx_clk_sel                            <= '0';
            end if;
            if int_datarate_set_rx_clkout_sync2 = "00001" then
               serdes_rx_data(7 downto 0)            <= rx_dataoutfull(7 downto 0);               --rx_dataout
               serdes_rx_data(8)                     <= rx_dataoutfull(8);                        --rx_ctrldetect
               serdes_rx_data(9)                     <= rx_dataoutfull(9) or rx_dataoutfull(11);  --rx_err
               serdes_rx_data(39 downto 10)          <= (others => '0');
               rx_errdetect(0)                       <= rx_dataoutfull(9);
               rx_disperr(0)                         <= rx_dataoutfull(11);
               rx_errdetect(3 downto 1)              <= (others => '0');
               rx_disperr(3 downto 1)                <= (others => '0');
               serdes_width                          <= "00";
            else
               serdes_rx_data(7 downto 0)            <= rx_dataoutfull(23 downto 16);             --rx_dataout
               serdes_rx_data(8)                     <= rx_dataoutfull(24);                       --rx_ctrldetect
               serdes_rx_data(9)                     <= rx_dataoutfull(25) or rx_dataoutfull(43); --rx_err
               serdes_rx_data(17 downto 10)          <= rx_dataoutfull(7 downto 0);               --rx_dataout
               serdes_rx_data(18)                    <= rx_dataoutfull(8);                        --rx_ctrldetect
               serdes_rx_data(19)                    <= rx_dataoutfull(9) or rx_dataoutfull(11);  --rx_err
               serdes_rx_data(39 downto 20)          <= (others => '0');
               rx_errdetect(1 downto 0)              <= rx_dataoutfull(25) & rx_dataoutfull(9);
               rx_disperr(1 downto 0)                <= rx_dataoutfull(43) & rx_dataoutfull(11);
               rx_errdetect(3 downto 2)              <= (others => '0');
               rx_disperr(3 downto 2)                <= (others => '0');
               serdes_width                          <= "01";
            end if;
         end process;
 
         cpri_clk      <= tx_clk_out;
         cpri_clkout   <= tx_clk_out;     
         pll_clkout    <= rx_clkout;
         serdes_tx_clk <= tx_clkout;
         serdes_rx_clk <= rx_clkout;

         inst_tx_clock_switch : clock_switch
         port map (
            sel    => tx_clk_sel,
            reset  => tx_digitalreset_sync,
            clk0   => txclk_div2, 
            clk1   => txclk_div4,
            clkout => tx_clk_out
         );
      end generate;

----------------------------------------------- CycloneIV -----------------------------------------------------------
      gen_cyclone_iv_gx:
      if DEVICE = 3 generate
         signal txclk_div2 : std_logic := '0';
         signal txclk_div4 : std_logic := '0';
      begin      

         process(tx_clkout)
            variable txclk_div2i : std_logic := '0';
         begin
            if tx_clkout'event and tx_clkout = '1' then
               txclk_div2i := not txclk_div2i;
               txclk_div2 <= not txclk_div2;
               if txclk_div2i = '1' then
                  txclk_div4 <= not txclk_div4;
               end if;
            end if;
         end process;

         process(int_datarate_set_tx_clkout_sync2,
                 int_datarate_set_rx_clkout_sync2,
                 serdes_tx_data,
                 rx_dataoutfull)
         begin
            if int_datarate_set_tx_clkout_sync2 = "00001" then
               tx_datainfull_pl(7 downto 0)          <= serdes_tx_data(7 downto 0);              --tx_datain
               tx_datainfull_pl(8)                   <= serdes_tx_data(8);                       --tx_ctrlenable
               tx_datainfull_pl(43 downto 9)         <= (others => '0');
               tx_clk_sel                            <= '1';
            else
               tx_datainfull_pl(7 downto 0)          <= serdes_tx_data(17 downto 10);            --tx_datain
               tx_datainfull_pl(8)                   <= serdes_tx_data(18);                      --tx_ctrlenable
               tx_datainfull_pl(9)                   <= '0';
               tx_datainfull_pl(10)                  <= '0';
               tx_datainfull_pl(18 downto 11)        <= serdes_tx_data(7 downto 0);              --tx_datain
               tx_datainfull_pl(19)                  <= serdes_tx_data(8);                       --tx_ctrlenable
               tx_datainfull_pl(43 downto 20)        <= (others => '0');
               tx_clk_sel                            <= '0';
            end if;
            if int_datarate_set_tx_clkout_sync2 = "00001" then
               serdes_rx_data(7 downto 0)            <= rx_dataoutfull(7 downto 0);              --rx_dataout
               serdes_rx_data(8)                     <= rx_dataoutfull(8);                       --rx_ctrldetect
               serdes_rx_data(9)                     <= rx_dataoutfull(9) or rx_dataoutfull(11); --rx_err
               serdes_rx_data(39 downto 10)          <= (others => '0');            
               rx_errdetect(0)                       <= rx_dataoutfull(9);          
               rx_disperr(0)                         <= rx_dataoutfull(11);
               rx_errdetect(3 downto 1)              <= (others => '0');
               rx_disperr(3 downto 1)                <= (others => '0');
               serdes_width                          <= "00";
            else
               serdes_rx_data(7 downto 0)            <= rx_dataoutfull(23 downto 16);             --rx_dataout
               serdes_rx_data(8)                     <= rx_dataoutfull(24);                       --rx_ctrldetect
               serdes_rx_data(9)                     <= rx_dataoutfull(25) or rx_dataoutfull(43); --rx_err
               serdes_rx_data(17 downto 10)          <= rx_dataoutfull(7 downto 0);               --rx_dataout
               serdes_rx_data(18)                    <= rx_dataoutfull(8);                        --rx_ctrldetect
               serdes_rx_data(19)                    <= rx_dataoutfull(9) or rx_dataoutfull(11);  --rx_err
               serdes_rx_data(39 downto 20)          <= (others => '0');
               rx_errdetect(1 downto 0)              <= rx_dataoutfull(25) & rx_dataoutfull(9);
               rx_disperr(1 downto 0)                <= rx_dataoutfull(43) & rx_dataoutfull(11);
               rx_errdetect(3 downto 2)              <= (others => '0');
               rx_disperr(3 downto 2)                <= (others => '0');
               serdes_width                          <= "01";
            end if;
         end process;
  
         cpri_clk      <= tx_clk_out;
         cpri_clkout   <= tx_clk_out;
         pll_clkout    <= rx_clkout;
         serdes_tx_clk <= tx_clkout;
         serdes_rx_clk <= rx_clkout;      
         
         inst_tx_clock_switch : clock_switch
         port map (
            sel    => tx_clk_sel,
            reset  => tx_digitalreset_sync,
            clk0   => txclk_div2, 
            clk1   => txclk_div4,
            clkout => tx_clk_out
         );
      end generate;

---------------------------------------------------Stratix V / Arria V GZ---------------------------------------------------------

      gen_stratix_v_arria_v_gz:
      if DEVICE = 4 or DEVICE = 7 generate
         signal txclk_div4 : std_logic := '0';
      begin

         process(tx_clkout)
            variable txclk_div2i : std_logic := '0';
         begin
            if tx_clkout'event and tx_clkout = '1' then
               txclk_div2i := not txclk_div2i;
               if txclk_div2i = '1' then
                  txclk_div4 <= not txclk_div4;
               end if;
            end if;
         end process;

         process(int_datarate_set_tx_clkout_sync2,
                 int_datarate_set_rx_clkout_sync2,
                 serdes_tx_data,
                 rx_parallel_data,
                 rx_errdetect,
                 rx_disperr)
         begin
            if int_datarate_set_tx_clkout_sync2 = "00001" then
               tx_parallel_data(7 downto 0)                <= serdes_tx_data(7 downto 0); --tx_datain
               tx_parallel_data(8)                         <= serdes_tx_data(8);          --tx_ctrlenable
               tx_parallel_data(43 downto 9)               <= (others => '0');
               tx_clk_sel                                  <= '1';
            else
               for n in 3 downto 0 loop
                  tx_parallel_data(n*11+7 downto n*11)     <= serdes_tx_data((3-n)*10+7 downto 10*(3-n));
                  tx_parallel_data(n*11+8)                 <= serdes_tx_data((3-n)*10+8);
                  tx_parallel_data(n*11+10 downto n*11+9)  <= (others => '0');
               end loop;
               tx_parallel_data(43 downto 41)              <= (others => '0');
               tx_clk_sel                                  <= '0';
            end if;
            if int_datarate_set_tx_clkout_sync2 = "00001" then
               serdes_rx_data(7 downto 0)                  <= rx_parallel_data(7 downto 0); --rx_dataout
               serdes_rx_data(8)                           <= rx_parallel_data(8);          --rx_ctrldetect
               rx_errdetect(0)                             <= rx_parallel_data(9);
               rx_syncstatus(0)                            <= rx_parallel_data(10);
               rx_disperr(0)                               <= rx_parallel_data(11);
               rx_errdetect(3 downto 1)                    <= (others => '0');
               rx_disperr(3 downto 1)                      <= (others => '0');
               serdes_rx_data(9)                           <= rx_errdetect(0) or rx_disperr(0);         
               serdes_rx_data(39 downto 10)                <= (others => '0');
               serdes_width                                <= "00";
            else
               for n in 3 downto 0 loop
                  serdes_rx_data(n*10+7 downto n*10)       <= rx_parallel_data((3-n)*16+7 downto (3-n)*16); --rx_dataout
                  serdes_rx_data(n*10+8)                   <= rx_parallel_data((3-n)*16+8);                 --rx_ctrldetect
                  rx_errdetect(n)                          <= rx_parallel_data((3-n)*16+9);
                  rx_syncstatus(n)                         <= rx_parallel_data((3-n)*16+10);
                  rx_disperr(n)                            <= rx_parallel_data((3-n)*16+11);
                  serdes_rx_data(n*10+9)                   <= rx_errdetect(n) or rx_disperr(n);        
               end loop;
               serdes_width                                <= "10";
            end if;
         end process;
  
         cpri_clk      <= tx_clk_out;
         cpri_clkout   <= tx_clk_out;
         pll_clkout    <= rx_clkout;
         serdes_tx_clk <= tx_clkout;
         serdes_rx_clk <= rx_clkout;      
         
         inst_tx_clock_switch : clock_switch
         port map (
            sel    => tx_clk_sel,
            reset  => tx_digitalreset_sync,
            clk0   => tx_clkout, 
            clk1   => txclk_div4,
            clkout => tx_clk_out
         );
      end generate;

---------------------------------------------------Arria V / Cyclone V-----------------------------------------------------------

      gen_arria_v_cyclone_v:
      if (DEVICE = 5 or DEVICE = 6) and LINERATE /= 5 generate
         signal txclk_div4 : std_logic := '0';
      begin

         process(tx_clkout)
            variable txclk_div2i : std_logic := '0';
         begin
            if tx_clkout'event and tx_clkout = '1' then
               txclk_div2i := not txclk_div2i;
               if txclk_div2i = '1' then
                  txclk_div4 <= not txclk_div4;
               end if;
            end if;
         end process;

         process(int_datarate_set_tx_clkout_sync2,
                 int_datarate_set_rx_clkout_sync2,
                 serdes_tx_data,
                 rx_parallel_data,
                 rx_errdetect,
                 rx_disperr)
         begin
            if int_datarate_set_tx_clkout_sync2 = "00001" then
               tx_parallel_data(7 downto 0)                <= serdes_tx_data(7 downto 0); --tx_datain
               tx_parallel_data(8)                         <= serdes_tx_data(8);          --tx_ctrlenable
               tx_parallel_data(43 downto 9)               <= (others => '0');
               tx_clk_sel                                  <= '1';
            else
               for n in 3 downto 0 loop
                  tx_parallel_data(n*11+7 downto n*11)     <= serdes_tx_data((3-n)*10+7 downto 10*(3-n));
                  tx_parallel_data(n*11+8)                 <= serdes_tx_data((3-n)*10+8);
                  tx_parallel_data(n*11+10 downto n*11+9)  <= (others => '0');
               end loop;
               tx_parallel_data(43 downto 41)              <= (others => '0');
               tx_clk_sel                                  <= '0';
            end if;
            if int_datarate_set_tx_clkout_sync2 = "00001" then
               serdes_rx_data(7 downto 0)                  <= rx_parallel_data(7 downto 0); --rx_dataout
               serdes_rx_data(8)                           <= rx_parallel_data(8);          --rx_ctrldetect
               rx_errdetect(0)                             <= rx_parallel_data(9);
               rx_syncstatus(0)                            <= rx_parallel_data(10);
               rx_disperr(0)                               <= rx_parallel_data(11);
               rx_errdetect(3 downto 1)                    <= (others => '0');
               rx_disperr(3 downto 1)                      <= (others => '0');
               serdes_rx_data(9)                           <= rx_errdetect(0) or rx_disperr(0);         
               serdes_rx_data(39 downto 10)                <= (others => '0');
               serdes_width                                <= "00";
            else
               for n in 3 downto 0 loop
                  serdes_rx_data(n*10+7 downto n*10)       <= rx_parallel_data((3-n)*16+7 downto (3-n)*16); --rx_dataout
                  serdes_rx_data(n*10+8)                   <= rx_parallel_data((3-n)*16+8);                 --rx_ctrldetect
                  rx_errdetect(n)                          <= rx_parallel_data((3-n)*16+9);
                  rx_syncstatus(n)                         <= rx_parallel_data((3-n)*16+10);
                  rx_disperr(n)                            <= rx_parallel_data((3-n)*16+11);
                  serdes_rx_data(n*10+9)                   <= rx_errdetect(n) or rx_disperr(n);        
               end loop;
               serdes_width                                <= "10";
            end if;
         end process;
  
         cpri_clk      <= tx_clk_out;
         cpri_clkout   <= tx_clk_out;
         pll_clkout    <= rx_clkout;
         serdes_tx_clk <= tx_clkout;
         serdes_rx_clk <= rx_clkout;      
         
         inst_tx_clock_switch : clock_switch
         port map (
            sel    => tx_clk_sel,
            reset  => tx_digitalreset_sync,
            clk0   => tx_clkout, 
            clk1   => txclk_div4,
            clkout => tx_clk_out
         );
      end generate;

      gen_arria_v_gt_autorate:
      if (DEVICE = 5 and LINERATE = 5) generate
      begin
         process(serdes_tx_data)
         begin
            for n in 3 downto 0 loop
               tx_parallel_data(n*8+7 downto n*8)       <= serdes_tx_data((3-n)*10+7 downto 10*(3-n));
               tx_datak(n)                              <= serdes_tx_data((3-n)*10+8);
            end loop;
            tx_parallel_data(43 downto 32)              <= (others => '0');
         end process;
         process(rx_parallel_data,rx_datak,rx_errdetect,rx_disperr)
         begin
            for n in 3 downto 0 loop
               serdes_rx_data(n*10+7 downto n*10)       <= rx_parallel_data(31-8*n downto 24-8*n); --rx_dataout
               serdes_rx_data(n*10+8)                   <= rx_datak(3-n);                          --rx_ctrldetect
               serdes_rx_data(n*10+9)                   <= rx_errdetect(3-n) or rx_disperr(3-n);   --rx_errdetect
            end loop;
         end process;      
         data_width_pma(6)          <= '1' when (int_datarate_set(4 downto 3) /= "00") else '0';
         data_width_pma(5 downto 3) <= "010";
         data_width_pma(2)          <= '1' when (int_datarate_set(4 downto 3) = "00") else '0';
         data_width_pma(1 downto 0) <= "00";
         serdes_width               <= "10";
         cpri_clk                   <= tx_clkout;
         cpri_clkout                <= tx_clkout;
         pll_clkout                 <= rx_clkout;
         serdes_tx_clk              <= tx_clkout;
         serdes_rx_clk              <= tx_clkout;  
      end generate;
   end generate;

---------------------------------------------------------------------------------------------------------------------
-------------------------------------- Port Map between Altgx and cpri core -----------------------------------------
---------------------------------------------------------------------------------------------------------------------
-------------------------------------------- StratixIV --------------------------------------------------------------

   gen_stratix_iv_gx:
   if DEVICE = 0 generate
   begin
      gen_614mbps:
      if LINERATE = 614 generate
      begin
         gen_master:
         if SYNC_MODE = 0 or SYNC_MODE = 2 generate
         begin
            inst_stratix4gx_614_m : stratix4gx_614_m
            generic map (
               starting_channel_number     => S_CH_NUMBER_M
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_m,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               tx_bitslipboundaryselect    => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull               => tx_datainfull, 
               tx_digitalreset(0)          => tx_digitalreset,
               pll_locked(0)               => pll_locked,
               reconfig_fromgxb            => reconfig_fromgxb_m,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0), 
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull,
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked,
               tx_clkout(0)                => tx_clkout,
               tx_dataout(0)               => gxb_txdataout
            );
         end generate;
         gen_slave:
         if SYNC_MODE = 1 generate
         begin
            inst_stratix4gx_614_s_tx : stratix4gx_614_s_tx
            generic map (
               starting_channel_number  => S_CH_NUMBER_S_TX
            )
            port map (
               cal_blk_clk              => gxb_cal_blk_clk,
               gxb_powerdown(0)         => gxb_powerdown,
               pll_inclk_rx_cruclk(0)   => gxb_pll_inclk,
               reconfig_clk             => reconfig_clk,
               reconfig_togxb           => reconfig_togxb_s_tx,
               tx_bitslipboundaryselect => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull            => tx_datainfull,
               tx_digitalreset(0)       => tx_digitalreset,
               pll_locked(0)            => pll_locked,
               reconfig_fromgxb         => reconfig_fromgxb_s_tx,
               tx_clkout(0)             => tx_clkout,
               tx_dataout(0)            => gxb_txdataout
            );
            inst_stratix4gx_614_s_rx : stratix4gx_614_s_rx
            generic map (
               starting_channel_number     => S_CH_NUMBER_S_RX
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_s_rx,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,      
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               reconfig_fromgxb            => reconfig_fromgxb_s_rx,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0),
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull,
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked
            );
         end generate;
      end generate;
      gen_1228mbps:
      if LINERATE = 0 generate
      begin
         gen_master:
         if SYNC_MODE = 0 or SYNC_MODE = 2 generate
         begin
            inst_stratix4gx_1228_m : stratix4gx_1228_m
            generic map (
               starting_channel_number     => S_CH_NUMBER_M
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_m,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               tx_bitslipboundaryselect    => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull               => tx_datainfull, 
               tx_digitalreset(0)          => tx_digitalreset,
               pll_locked(0)               => pll_locked,
               reconfig_fromgxb            => reconfig_fromgxb_m,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0), 
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull,
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked,
               tx_clkout(0)                => tx_clkout,
               tx_dataout(0)               => gxb_txdataout
            );
         end generate;
         gen_slave:
         if SYNC_MODE = 1 generate
         begin
            inst_stratix4gx_1228_s_tx : stratix4gx_1228_s_tx
            generic map (
               starting_channel_number  => S_CH_NUMBER_S_TX
            )
            port map (
               cal_blk_clk              => gxb_cal_blk_clk,
               gxb_powerdown(0)         => gxb_powerdown,
               pll_inclk_rx_cruclk(0)   => gxb_pll_inclk,
               reconfig_clk             => reconfig_clk,
               reconfig_togxb           => reconfig_togxb_s_tx,
               tx_bitslipboundaryselect => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull            => tx_datainfull,
               tx_digitalreset(0)       => tx_digitalreset,
               pll_locked(0)            => pll_locked,
               reconfig_fromgxb         => reconfig_fromgxb_s_tx,
               tx_clkout(0)             => tx_clkout,
               tx_dataout(0)            => gxb_txdataout
            );
            inst_stratix4gx_1228_s_rx : stratix4gx_1228_s_rx
            generic map (
               starting_channel_number     => S_CH_NUMBER_S_RX
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_s_rx,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,      
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               reconfig_fromgxb            => reconfig_fromgxb_s_rx,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0),
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull,
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked
            );          
         end generate;
      end generate;
      gen_2457mbps:
      if LINERATE = 1 generate
      begin
         gen_master:
         if SYNC_MODE = 0 or SYNC_MODE = 2 generate
         begin
            inst_stratix4gx_2457_m : stratix4gx_2457_m
            generic map (
               starting_channel_number     => S_CH_NUMBER_M
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_m,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               tx_bitslipboundaryselect    => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull               => tx_datainfull, 
               tx_digitalreset(0)          => tx_digitalreset,
               pll_locked(0)               => pll_locked,
               reconfig_fromgxb            => reconfig_fromgxb_m,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0), 
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull,
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked,
               tx_clkout(0)                => tx_clkout,
               tx_dataout(0)               => gxb_txdataout
            );
         end generate;
         gen_slave:
         if SYNC_MODE = 1 generate
         begin
            inst_stratix4gx_2457_s_tx : stratix4gx_2457_s_tx
            generic map (
               starting_channel_number  => S_CH_NUMBER_S_TX
            )
            port map (
               cal_blk_clk              => gxb_cal_blk_clk,
               gxb_powerdown(0)         => gxb_powerdown,
               pll_inclk_rx_cruclk(0)   => gxb_pll_inclk,
               reconfig_clk             => reconfig_clk,
               reconfig_togxb           => reconfig_togxb_s_tx,
               tx_bitslipboundaryselect => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull            => tx_datainfull,
               tx_digitalreset(0)       => tx_digitalreset,          
               pll_locked(0)            => pll_locked,
               reconfig_fromgxb         => reconfig_fromgxb_s_tx,
               tx_clkout(0)             => tx_clkout,
               tx_dataout(0)            => gxb_txdataout
            );
            inst_stratix4gx_2457_s_rx : stratix4gx_2457_s_rx
            generic map (
               starting_channel_number     => S_CH_NUMBER_S_RX
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_s_rx,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,      
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               reconfig_fromgxb            => reconfig_fromgxb_s_rx,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0),
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull,
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked
            );          
         end generate;
      end generate;
      gen_3072mbps:
      if LINERATE = 2 generate
      begin
         gen_master:
         if SYNC_MODE = 0 or SYNC_MODE = 2 generate
         begin
            inst_stratix4gx_3072_m : stratix4gx_3072_m
            generic map (
               starting_channel_number     => S_CH_NUMBER_M
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_m,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               tx_bitslipboundaryselect    => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull               => tx_datainfull, 
               tx_digitalreset(0)          => tx_digitalreset,
               pll_locked(0)               => pll_locked,
               reconfig_fromgxb            => reconfig_fromgxb_m,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0), 
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull,
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked,
               tx_clkout(0)                => tx_clkout,
               tx_dataout(0)               => gxb_txdataout
            );
         end generate;
         gen_slave:
         if SYNC_MODE = 1 generate
         begin
            inst_stratix4gx_3072_s_tx : stratix4gx_3072_s_tx
            generic map (
               starting_channel_number  => S_CH_NUMBER_S_TX
            )
            port map (
               cal_blk_clk              => gxb_cal_blk_clk,
               gxb_powerdown(0)         => gxb_powerdown,
               pll_inclk_rx_cruclk(0)   => gxb_pll_inclk,
               reconfig_clk             => reconfig_clk,
               reconfig_togxb           => reconfig_togxb_s_tx,
               tx_bitslipboundaryselect => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull            => tx_datainfull,
               tx_digitalreset(0)       => tx_digitalreset,          
               pll_locked(0)            => pll_locked,
               reconfig_fromgxb         => reconfig_fromgxb_s_tx,
               tx_clkout(0)             => tx_clkout,
               tx_dataout(0)            => gxb_txdataout
            );
            inst_stratix4gx_3072_s_rx : stratix4gx_3072_s_rx
            generic map (
               starting_channel_number     => S_CH_NUMBER_S_RX
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_s_rx,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,      
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               reconfig_fromgxb            => reconfig_fromgxb_s_rx,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0),
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull,
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked
            );          
         end generate;
      end generate;
      gen_4915mbps:
      if LINERATE = 3 generate
      begin
         gen_master:
         if SYNC_MODE = 0 or SYNC_MODE = 2 generate
         begin
            inst_stratix4gx_4915_m : stratix4gx_4915_m
            generic map (
               starting_channel_number     => S_CH_NUMBER_M
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_m,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               tx_bitslipboundaryselect    => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull               => tx_datainfull, 
               tx_digitalreset(0)          => tx_digitalreset,
               pll_locked(0)               => pll_locked,
               reconfig_fromgxb            => reconfig_fromgxb_m,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0), 
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull,
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked,
               tx_clkout(0)                => tx_clkout,
               tx_dataout(0)               => gxb_txdataout
            );
         end generate;
         gen_slave:
         if SYNC_MODE = 1 generate
         begin
            inst_stratix4gx_4915_s_tx : stratix4gx_4915_s_tx
            generic map (
               starting_channel_number  => S_CH_NUMBER_S_TX
            )
            port map (
               cal_blk_clk              => gxb_cal_blk_clk,
               gxb_powerdown(0)         => gxb_powerdown,
               pll_inclk_rx_cruclk(0)   => gxb_pll_inclk,
               reconfig_clk             => reconfig_clk,
               reconfig_togxb           => reconfig_togxb_s_tx,
               tx_bitslipboundaryselect => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull            => tx_datainfull,
               tx_digitalreset(0)       => tx_digitalreset,          
               pll_locked(0)            => pll_locked,
               reconfig_fromgxb         => reconfig_fromgxb_s_tx,
               tx_clkout(0)             => tx_clkout,
               tx_dataout(0)            => gxb_txdataout
            );
            inst_stratix4gx_4915_s_rx : stratix4gx_4915_s_rx
            generic map (
               starting_channel_number     => S_CH_NUMBER_S_RX
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_s_rx,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,      
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               reconfig_fromgxb            => reconfig_fromgxb_s_rx,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0),
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull,
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked
            );          
         end generate;
      end generate;
      gen_6144mbps:
      if LINERATE = 4 generate
      begin
         gen_master:
         if SYNC_MODE = 0 or SYNC_MODE = 2 generate
         begin
            inst_stratix4gx_6144_m : stratix4gx_6144_m
            generic map (
               starting_channel_number     => S_CH_NUMBER_M
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_m,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               tx_bitslipboundaryselect    => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull               => tx_datainfull, 
               tx_digitalreset(0)          => tx_digitalreset,
               pll_locked(0)               => pll_locked,
               reconfig_fromgxb            => reconfig_fromgxb_m,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0), 
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull,
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked,
               tx_clkout(0)                => tx_clkout,
               tx_dataout(0)               => gxb_txdataout
            );
         end generate;
         gen_slave:
         if SYNC_MODE = 1 generate
         begin
            inst_stratix4gx_6144_s_tx : stratix4gx_6144_s_tx
            generic map (
               starting_channel_number  => S_CH_NUMBER_S_TX
            )
            port map (
               cal_blk_clk              => gxb_cal_blk_clk,
               gxb_powerdown(0)         => gxb_powerdown,
               pll_inclk_rx_cruclk(0)   => gxb_pll_inclk,
               reconfig_clk             => reconfig_clk,
               reconfig_togxb           => reconfig_togxb_s_tx,
               tx_bitslipboundaryselect => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull            => tx_datainfull,
               tx_digitalreset(0)       => tx_digitalreset,          
               pll_locked(0)            => pll_locked,
               reconfig_fromgxb         => reconfig_fromgxb_s_tx,
               tx_clkout(0)             => tx_clkout,
               tx_dataout(0)            => gxb_txdataout
            );
            inst_stratix4gx_6144_s_rx : stratix4gx_6144_s_rx
            generic map (
               starting_channel_number     => S_CH_NUMBER_S_RX
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_s_rx,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,      
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               reconfig_fromgxb            => reconfig_fromgxb_s_rx,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0),
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull,
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked
            );          
         end generate;
      end generate;
   end generate;

---------------------------------------------- ArriaIIGX ------------------------------------------------------------
   gen_arria_ii_gx:
   if DEVICE = 1 generate
   begin
      gen_614mbps:
      if LINERATE = 614 generate
      begin
         gen_master:
         if SYNC_MODE = 0 or SYNC_MODE = 2 generate
         begin
            inst_arria2gx_614_m : arria2gx_614_m
            generic map (
               starting_channel_number => S_CH_NUMBER_M
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_m,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               tx_bitslipboundaryselect    => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull               => tx_datainfull(32 downto 0), 
               tx_digitalreset(0)          => tx_digitalreset,
               pll_locked(0)               => pll_locked,
               reconfig_fromgxb            => reconfig_fromgxb_m,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0), 
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull(47 downto 0),
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked,
               tx_clkout(0)                => tx_clkout,
               tx_dataout(0)               => gxb_txdataout
            );          
         end generate;
         gen_slave:
         if SYNC_MODE = 1 generate
         begin
            inst_arria2gx_614_s_tx : arria2gx_614_s_tx
            generic map (
               starting_channel_number  => S_CH_NUMBER_S_TX
            )
            port map (
               cal_blk_clk              => gxb_cal_blk_clk,
               gxb_powerdown(0)         => gxb_powerdown,
               pll_inclk_rx_cruclk(0)   => gxb_pll_inclk,
               reconfig_clk             => reconfig_clk,
               reconfig_togxb           => reconfig_togxb_s_tx,
               tx_bitslipboundaryselect => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull            => tx_datainfull(32 downto 0),
               tx_digitalreset(0)       => tx_digitalreset,          
               pll_locked(0)            => pll_locked,
               reconfig_fromgxb         => reconfig_fromgxb_s_tx,
               tx_clkout(0)             => tx_clkout,
               tx_dataout(0)            => gxb_txdataout
            );
            inst_arria2gx_614_s_rx : arria2gx_614_s_rx
            generic map (
               starting_channel_number     => S_CH_NUMBER_S_RX
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_s_rx,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,      
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               reconfig_fromgxb            => reconfig_fromgxb_s_rx,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0),
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull(47 downto 0),
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked
            );          
         end generate;
      end generate;
      gen_1228mbps:
      if LINERATE = 0 generate
      begin
         gen_master:
         if SYNC_MODE = 0 or SYNC_MODE = 2 generate
         begin
            inst_arria2gx_1228_m : arria2gx_1228_m
            generic map (
               starting_channel_number     => S_CH_NUMBER_M
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_m,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               tx_bitslipboundaryselect    => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull               => tx_datainfull(32 downto 0), 
               tx_digitalreset(0)          => tx_digitalreset,
               pll_locked(0)               => pll_locked,
               reconfig_fromgxb            => reconfig_fromgxb_m,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0), 
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull(47 downto 0),
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked,
               tx_clkout(0)                => tx_clkout,
               tx_dataout(0)               => gxb_txdataout
            );
         end generate;
         gen_slave:
         if SYNC_MODE = 1 generate
         begin
            inst_arri2gx_1228_s_tx : arria2gx_1228_s_tx
            generic map (
               starting_channel_number  => S_CH_NUMBER_S_TX
            )
            port map (
               cal_blk_clk              => gxb_cal_blk_clk,
               gxb_powerdown(0)         => gxb_powerdown,
               pll_inclk_rx_cruclk(0)   => gxb_pll_inclk,
               reconfig_clk             => reconfig_clk,
               reconfig_togxb           => reconfig_togxb_s_tx,
               tx_bitslipboundaryselect => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull            => tx_datainfull(32 downto 0),
               tx_digitalreset(0)       => tx_digitalreset,          
               pll_locked(0)            => pll_locked,
               reconfig_fromgxb         => reconfig_fromgxb_s_tx,
               tx_clkout(0)             => tx_clkout,
               tx_dataout(0)            => gxb_txdataout
            );
            inst_arria2gx_1228_s_rx : arria2gx_1228_s_rx
            generic map (
               starting_channel_number     => S_CH_NUMBER_S_RX
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_s_rx,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,      
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               reconfig_fromgxb            => reconfig_fromgxb_s_rx,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0),
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull(47 downto 0),
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked
            );
         end generate;
      end generate;
      gen_2457mbps:
      if LINERATE = 1 generate
      begin
         gen_master:
         if SYNC_MODE = 0 or SYNC_MODE = 2 generate
         begin
            inst_arria2gx_2457_m : arria2gx_2457_m
            generic map (
               starting_channel_number     => S_CH_NUMBER_M
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_m,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               tx_bitslipboundaryselect    => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull               => tx_datainfull(32 downto 0), 
               tx_digitalreset(0)          => tx_digitalreset,
               pll_locked(0)               => pll_locked,
               reconfig_fromgxb            => reconfig_fromgxb_m,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0), 
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull(47 downto 0),
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked,
               tx_clkout(0)                => tx_clkout,
               tx_dataout(0)               => gxb_txdataout
            );
         end generate;
         gen_slave:
         if SYNC_MODE = 1 generate
         begin
            inst_arri2gx_2457_s_tx : arria2gx_2457_s_tx
            generic map (
               starting_channel_number  => S_CH_NUMBER_S_TX
            )
            port map (
               cal_blk_clk              => gxb_cal_blk_clk,
               gxb_powerdown(0)         => gxb_powerdown,
               pll_inclk_rx_cruclk(0)   => gxb_pll_inclk,
               reconfig_clk             => reconfig_clk,
               reconfig_togxb           => reconfig_togxb_s_tx,
               tx_bitslipboundaryselect => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull            => tx_datainfull(32 downto 0),
               tx_digitalreset(0)       => tx_digitalreset,          
               pll_locked(0)            => pll_locked,
               reconfig_fromgxb         => reconfig_fromgxb_s_tx,
               tx_clkout(0)             => tx_clkout,
               tx_dataout(0)            => gxb_txdataout
            );
            inst_arria2gx_2457_s_rx : arria2gx_2457_s_rx
            generic map (
               starting_channel_number     => S_CH_NUMBER_S_RX
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_s_rx,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,      
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               reconfig_fromgxb            => reconfig_fromgxb_s_rx,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0),
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull(47 downto 0),
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked
            );
         end generate;
      end generate;
      gen_3072mbps:
      if LINERATE = 2 generate
      begin
         gen_master:
         if SYNC_MODE = 0 or SYNC_MODE = 2 generate
         begin
            inst_arria2gx_3072_m : arria2gx_3072_m
            generic map (
               starting_channel_number     => S_CH_NUMBER_M
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_m,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               tx_bitslipboundaryselect    => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull               => tx_datainfull(32 downto 0), 
               tx_digitalreset(0)          => tx_digitalreset,
               pll_locked(0)               => pll_locked,
               reconfig_fromgxb            => reconfig_fromgxb_m,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0), 
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull(47 downto 0),
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked,
               tx_clkout(0)                => tx_clkout,
               tx_dataout(0)               => gxb_txdataout
            );
         end generate;
         gen_slave:
         if SYNC_MODE = 1 generate
         begin
            inst_arri2gx_3072_s_tx : arria2gx_3072_s_tx
            generic map (
               starting_channel_number  => S_CH_NUMBER_S_TX
            )
            port map (
               cal_blk_clk              => gxb_cal_blk_clk,
               gxb_powerdown(0)         => gxb_powerdown,
               pll_inclk_rx_cruclk(0)   => gxb_pll_inclk,
               reconfig_clk             => reconfig_clk,
               reconfig_togxb           => reconfig_togxb_s_tx,
               tx_bitslipboundaryselect => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull            => tx_datainfull(32 downto 0),
               tx_digitalreset(0)       => tx_digitalreset,          
               pll_locked(0)            => pll_locked,
               reconfig_fromgxb         => reconfig_fromgxb_s_tx,
               tx_clkout(0)             => tx_clkout,
               tx_dataout(0)            => gxb_txdataout
            );
            inst_arria2gx_3072_s_rx : arria2gx_3072_s_rx
            generic map (
               starting_channel_number     => S_CH_NUMBER_S_RX
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_s_rx,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,      
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               reconfig_fromgxb            => reconfig_fromgxb_s_rx,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0),
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull(47 downto 0),
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked
            );
         end generate;    
      end generate;        
      gen_4915mbps:
      if LINERATE = 3 generate
      begin
         gen_master:
         if SYNC_MODE = 0 or SYNC_MODE = 2 generate
         begin
            inst_arria2gx_4915_m : arria2gx_4915_m
            generic map (
               starting_channel_number     => S_CH_NUMBER_M
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_m,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               tx_bitslipboundaryselect    => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull               => tx_datainfull(32 downto 0), 
               tx_digitalreset(0)          => tx_digitalreset,
               pll_locked(0)               => pll_locked,
               reconfig_fromgxb            => reconfig_fromgxb_m,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0), 
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull(47 downto 0),
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked,
               tx_clkout(0)                => tx_clkout,
               tx_dataout(0)               => gxb_txdataout
            );
         end generate;
         gen_slave:
         if SYNC_MODE = 1 generate
         begin
            inst_arri2gx_4915_s_tx : arria2gx_4915_s_tx
            generic map (
               starting_channel_number  => S_CH_NUMBER_S_TX
            )
            port map (
               cal_blk_clk              => gxb_cal_blk_clk,
               gxb_powerdown(0)         => gxb_powerdown,
               pll_inclk_rx_cruclk(0)   => gxb_pll_inclk,
               reconfig_clk             => reconfig_clk,
               reconfig_togxb           => reconfig_togxb_s_tx,
               tx_bitslipboundaryselect => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull            => tx_datainfull(32 downto 0),
               tx_digitalreset(0)       => tx_digitalreset,          
               pll_locked(0)            => pll_locked,
               reconfig_fromgxb         => reconfig_fromgxb_s_tx,
               tx_clkout(0)             => tx_clkout,
               tx_dataout(0)            => gxb_txdataout
            );
            inst_arria2gx_4915_s_rx : arria2gx_4915_s_rx
            generic map (
               starting_channel_number     => S_CH_NUMBER_S_RX
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_s_rx,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,      
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               reconfig_fromgxb            => reconfig_fromgxb_s_rx,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0),
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull(47 downto 0),
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked
            );
         end generate;    
      end generate;          
      gen_6144mbps:
      if LINERATE = 4 generate
      begin
         gen_master:
         if SYNC_MODE = 0 or SYNC_MODE = 2 generate
         begin
            inst_arria2gx_6144_m : arria2gx_6144_m
            generic map (
               starting_channel_number     => S_CH_NUMBER_M
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_m,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               tx_bitslipboundaryselect    => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull               => tx_datainfull(32 downto 0), 
               tx_digitalreset(0)          => tx_digitalreset,
               pll_locked(0)               => pll_locked,
               reconfig_fromgxb            => reconfig_fromgxb_m,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0), 
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull(47 downto 0),
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked,
               tx_clkout(0)                => tx_clkout,
               tx_dataout(0)               => gxb_txdataout
            );
         end generate;
         gen_slave:
         if SYNC_MODE = 1 generate
         begin
            inst_arri2gx_6144_s_tx : arria2gx_6144_s_tx
            generic map (
               starting_channel_number  => S_CH_NUMBER_S_TX
            )
            port map (
               cal_blk_clk              => gxb_cal_blk_clk,
               gxb_powerdown(0)         => gxb_powerdown,
               pll_inclk_rx_cruclk(0)   => gxb_pll_inclk,
               reconfig_clk             => reconfig_clk,
               reconfig_togxb           => reconfig_togxb_s_tx,
               tx_bitslipboundaryselect => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull            => tx_datainfull(32 downto 0),
               tx_digitalreset(0)       => tx_digitalreset,          
               pll_locked(0)            => pll_locked,
               reconfig_fromgxb         => reconfig_fromgxb_s_tx,
               tx_clkout(0)             => tx_clkout,
               tx_dataout(0)            => gxb_txdataout
            );
            inst_arria2gx_6144_s_rx : arria2gx_6144_s_rx
            generic map (
               starting_channel_number     => S_CH_NUMBER_S_RX
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_s_rx,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,      
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               reconfig_fromgxb            => reconfig_fromgxb_s_rx,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0),
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull(47 downto 0),
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked
            );
         end generate;    
      end generate;          
   end generate;
   
--------------------------------------- CycloneIV -------------------------------------------------------------------
   gen_cyclone_iv_gx:
   if DEVICE = 3 generate
   begin
      gen_614mbps:
      if LINERATE = 614 generate
      begin
         gen_master:
         if SYNC_MODE = 0 or SYNC_MODE = 2 generate
         begin         
            inst_cyclone4gx_614_m : cyclone4gx_614_m
            generic map (
               starting_channel_number     => S_CH_NUMBER_M
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_areset                  => pll_areset,     
               pll_configupdate            => pll_configupdate,         
               pll_inclk(0)                => gxb_refclk,      
               pll_inclk(1)                => gxb_refclk,
               pll_scanclk                 => pll_scanclk,        
               pll_scanclkena              => pll_scanclkena,     
               pll_scandata                => pll_scandata,     
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_m,     
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               tx_bitslipboundaryselect    => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull               => tx_datainfull(21 downto 0),  
               tx_digitalreset(0)          => tx_digitalreset,
               pll_locked(0)               => pll_locked,
               pll_locked(1)               => rx_pll_locked,
               pll_reconfig_done           => s_pll_reconfig_done,      
               pll_scandataout             => pll_scandataout,     
               reconfig_fromgxb            => reconfig_fromgxb_m(4 downto 0),    
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0), 
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull(31 downto 0),
               rx_freqlocked(0)            => rx_freqlocked,
               tx_clkout(0)                => tx_clkout,
               tx_dataout(0)               => gxb_txdataout
            );           
         end generate;
         
         gen_slave:
         if SYNC_MODE = 1 generate
         begin          
            inst_cyclone4gx_614_s_tx : cyclone4gx_614_s_tx
            generic map(
               starting_channel_number   => S_CH_NUMBER_S_TX
            )
            port map (
               cal_blk_clk               => gxb_cal_blk_clk,                    
               gxb_powerdown(0)          => gxb_powerdown,                      
               pll_areset(0)             => pll_areset(0),                      
               pll_configupdate(0)       => pll_configupdate(0),                
               pll_inclk(0)              => gxb_pll_inclk,                       
               pll_scanclk(0)            => pll_scanclk(0),                     
               pll_scanclkena(0)         => pll_scanclkena(0),                  
               pll_scandata(0)           => pll_scandata(0),                    
               reconfig_clk              => reconfig_clk,                       
               reconfig_togxb            => reconfig_togxb_s_tx,                
               tx_bitslipboundaryselect  => tx_bitslipboundaryselect(4 downto 0),           
               tx_datainfull             => tx_datainfull(21 downto 0),         
               tx_digitalreset(0)        => tx_digitalreset,                    
               pll_locked(0)             => pll_locked,                         
               pll_reconfig_done(0)      => s_pll_reconfig_done(0),               
               pll_scandataout(0)        => pll_scandataout(0),                  
               reconfig_fromgxb          => reconfig_fromgxb_s_tx(4 downto 0),  
               tx_clkout(0)              => tx_clkout,                          
               tx_dataout(0)             => gxb_txdataout                       
            );
            inst_cyclone4gx_614_s_rx : cyclone4gx_614_s_rx
            generic map(
               starting_channel_number      => S_CH_NUMBER_S_RX
            )
            port map (
               cal_blk_clk                  => gxb_cal_blk_clk,                  
               gxb_powerdown(0)             => gxb_powerdown,                    
               pll_areset(0)                => pll_areset(1),                    
               pll_configupdate(0)          => pll_configupdate(1),              
               pll_inclk(0)                 => gxb_refclk,                     
               pll_scanclk(0)               => pll_scanclk(1),                   
               pll_scanclkena(0)            => pll_scanclkena(1),                
               pll_scandata(0)              => pll_scandata(1),                  
               reconfig_clk                 => reconfig_clk,                     
               reconfig_togxb               => reconfig_togxb_s_rx,              
               rx_analogreset(0)            => rx_analogreset,                   
               rx_datain(0)                 => gxb_rxdatain,                     
               rx_digitalreset(0)           => rx_digitalreset,                  
               rx_enapatternalign(0)        => rx_enapatternalign,           
               pll_locked(0)                => rx_pll_locked,                    
               pll_reconfig_done(0)         => s_pll_reconfig_done(1),             
               pll_scandataout(0)           => pll_scandataout(1),               
               reconfig_fromgxb             => reconfig_fromgxb_s_rx(4 downto 0),
               rx_bitslipboundaryselectout  => rx_bitslipboundaryselectout(4 downto 0),      
               rx_clkout(0)                 => rx_clkout,                        
               rx_dataoutfull               => rx_dataoutfull(31 downto 0),      
               rx_freqlocked(0)             => rx_freqlocked                    
            );
         end generate; 
      end generate; 
         
      gen_1228mbps:
      if LINERATE = 0 generate
      begin
         gen_master:
         if SYNC_MODE = 0 or SYNC_MODE = 2 generate
         begin            
            inst_cyclone4gx_1228_m : cyclone4gx_1228_m
            generic map (
               starting_channel_number     => S_CH_NUMBER_M
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_areset                  => pll_areset,      
               pll_configupdate            => pll_configupdate,                    
               pll_inclk(0)                => gxb_refclk,        
               pll_inclk(1)                => gxb_refclk,
               pll_scanclk                 => pll_scanclk,          
               pll_scanclkena              => pll_scanclkena,      
               pll_scandata                => pll_scandata,       
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_m,       
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               tx_bitslipboundaryselect    => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull               => tx_datainfull(21 downto 0),   
               tx_digitalreset(0)          => tx_digitalreset,
               pll_locked(0)               => pll_locked,
               pll_locked(1)               => rx_pll_locked,
               pll_reconfig_done           => s_pll_reconfig_done,       
               pll_scandataout             => pll_scandataout,       
               reconfig_fromgxb            => reconfig_fromgxb_m(4 downto 0),     
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0), 
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull(31 downto 0),
               rx_freqlocked(0)            => rx_freqlocked,
               tx_clkout(0)                => tx_clkout,
               tx_dataout(0)               => gxb_txdataout
            );
         end generate;
         
         gen_slave:
         if SYNC_MODE = 1 generate
         begin           
            inst_cyclone4gx_1228_s_tx : cyclone4gx_1228_s_tx
            generic map(
               starting_channel_number   => S_CH_NUMBER_S_TX
            )
            port map (
               cal_blk_clk               => gxb_cal_blk_clk,                     
               gxb_powerdown(0)          => gxb_powerdown,                       
               pll_areset(0)             => pll_areset(0),                       
               pll_configupdate(0)       => pll_configupdate(0),                
               pll_inclk(0)              => gxb_pll_inclk,                         
               pll_scanclk(0)            => pll_scanclk(0),                     
               pll_scanclkena(0)         => pll_scanclkena(0),                  
               pll_scandata(0)           => pll_scandata(0),                    
               reconfig_clk              => reconfig_clk,                       
               reconfig_togxb            => reconfig_togxb_s_tx,                
               tx_bitslipboundaryselect  => tx_bitslipboundaryselect(4 downto 0),           
               tx_datainfull             => tx_datainfull(21 downto 0),         
               tx_digitalreset(0)        => tx_digitalreset,                    
               pll_locked(0)             => pll_locked,                         
               pll_reconfig_done(0)      => s_pll_reconfig_done(0),               
               pll_scandataout(0)        => pll_scandataout(0),                 
               reconfig_fromgxb          => reconfig_fromgxb_s_tx(4 downto 0),  
               tx_clkout(0)              => tx_clkout,                          
               tx_dataout(0)             => gxb_txdataout                       
            );
            inst_cyclone4gx_1228_s_rx : cyclone4gx_1228_s_rx
            generic map(
               starting_channel_number      => S_CH_NUMBER_S_RX
            )
            port map (
               cal_blk_clk                  => gxb_cal_blk_clk,                  
               gxb_powerdown(0)             => gxb_powerdown,                    
               pll_areset(0)                => pll_areset(1),                    
               pll_configupdate(0)          => pll_configupdate(1),              
               pll_inclk(0)                 => gxb_refclk,                       
               pll_scanclk(0)               => pll_scanclk(1),                   
               pll_scanclkena(0)            => pll_scanclkena(1),                
               pll_scandata(0)              => pll_scandata(1),                  
               reconfig_clk                 => reconfig_clk,                     
               reconfig_togxb               => reconfig_togxb_s_rx,              
               rx_analogreset(0)            => rx_analogreset,                   
               rx_datain(0)                 => gxb_rxdatain,                     
               rx_digitalreset(0)           => rx_digitalreset,                  
               rx_enapatternalign(0)        => rx_enapatternalign,           
               pll_locked(0)                => rx_pll_locked,                    
               pll_reconfig_done(0)         => s_pll_reconfig_done(1),             
               pll_scandataout(0)           => pll_scandataout(1),               
               reconfig_fromgxb             => reconfig_fromgxb_s_rx(4 downto 0),
               rx_bitslipboundaryselectout  => rx_bitslipboundaryselectout(4 downto 0),      
               rx_clkout(0)                 => rx_clkout,                        
               rx_dataoutfull               => rx_dataoutfull(31 downto 0),      
               rx_freqlocked(0)             => rx_freqlocked                    
            );
         end generate; 
      end generate; 
         
      gen_2457mbps:
      if LINERATE = 1 generate
      begin
         gen_master:
         if SYNC_MODE = 0 or SYNC_MODE = 2 generate
         begin
            inst_cyclone4gx_2457_m : cyclone4gx_2457_m
            generic map (
               starting_channel_number     => S_CH_NUMBER_M
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_areset                  => pll_areset,
               pll_configupdate            => pll_configupdate,
               pll_inclk(0)                => gxb_refclk,           
               pll_inclk(1)                => gxb_refclk,        
               pll_scanclk                 => pll_scanclk,          
               pll_scanclkena              => pll_scanclkena,       
               pll_scandata                => pll_scandata,         
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_m,     
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               tx_bitslipboundaryselect    => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull               => tx_datainfull(21 downto 0),  
               tx_digitalreset(0)          => tx_digitalreset,
               pll_locked(0)               => pll_locked,
               pll_locked(1)               => rx_pll_locked,
               pll_reconfig_done           => s_pll_reconfig_done,                
               pll_scandataout             => pll_scandataout,                  
               reconfig_fromgxb            => reconfig_fromgxb_m(4 downto 0),   
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0), 
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull(31 downto 0),
               rx_freqlocked(0)            => rx_freqlocked,
               tx_clkout(0)                => tx_clkout,
               tx_dataout(0)               => gxb_txdataout
            );
         end generate;
         
         gen_slave:
         if SYNC_MODE = 1 generate
         begin           
            inst_cyclone4gx_2457_s_tx : cyclone4gx_2457_s_tx
            generic map(
               starting_channel_number   => S_CH_NUMBER_S_TX
            )
            port map (
               cal_blk_clk               => gxb_cal_blk_clk,                   
               gxb_powerdown(0)          => gxb_powerdown,                     
               pll_areset(0)             => pll_areset(0),                     
               pll_configupdate(0)       => pll_configupdate(0),               
               pll_inclk(0)              => gxb_pll_inclk,                        
               pll_scanclk(0)            => pll_scanclk(0),                    
               pll_scanclkena(0)         => pll_scanclkena(0),                 
               pll_scandata(0)           => pll_scandata(0),                   
               reconfig_clk              => reconfig_clk,                      
               reconfig_togxb            => reconfig_togxb_s_tx,               
               tx_bitslipboundaryselect  => tx_bitslipboundaryselect(4 downto 0),          
               tx_datainfull             => tx_datainfull(21 downto 0),        
               tx_digitalreset(0)        => tx_digitalreset,                   
               pll_locked(0)             => pll_locked,                        
               pll_reconfig_done(0)      => s_pll_reconfig_done(0),              
               pll_scandataout(0)        => pll_scandataout(0),                
               reconfig_fromgxb          => reconfig_fromgxb_s_tx(4 downto 0), 
               tx_clkout(0)              => tx_clkout,                         
               tx_dataout(0)             => gxb_txdataout                      
            );         
           inst_cyclone4gx_2457_s_rx : cyclone4gx_2457_s_rx
           generic map(
              starting_channel_number      => S_CH_NUMBER_S_RX
           )
           port map (
              cal_blk_clk                  => gxb_cal_blk_clk,                
              gxb_powerdown(0)             => gxb_powerdown,                  
              pll_areset(0)                => pll_areset(1),                  
              pll_configupdate(0)          => pll_configupdate(1),            
              pll_inclk(0)                 => gxb_refclk,                     
              pll_scanclk(0)               => pll_scanclk(1),                 
              pll_scanclkena(0)            => pll_scanclkena(1),              
              pll_scandata(0)              => pll_scandata(1),                
              reconfig_clk                 => reconfig_clk,                   
              reconfig_togxb               => reconfig_togxb_s_rx,            
              rx_analogreset(0)            => rx_analogreset,                 
              rx_datain(0)                 => gxb_rxdatain,                     
              rx_digitalreset(0)           => rx_digitalreset,                  
              rx_enapatternalign(0)        => rx_enapatternalign,           
              pll_locked(0)                => rx_pll_locked,                    
              pll_reconfig_done(0)         => s_pll_reconfig_done(1),             
              pll_scandataout(0)           => pll_scandataout(1),               
              reconfig_fromgxb             => reconfig_fromgxb_s_rx(4 downto 0),
              rx_bitslipboundaryselectout  => rx_bitslipboundaryselectout(4 downto 0),      
              rx_clkout(0)                 => rx_clkout,                        
              rx_dataoutfull               => rx_dataoutfull(31 downto 0),      
              rx_freqlocked(0)             => rx_freqlocked                    
           );
         end generate; 
      end generate; 
         
      gen_3072mbps:
      if LINERATE = 2 generate
      begin
         gen_master:
         if SYNC_MODE = 0 or SYNC_MODE = 2 generate
         begin
            inst_cyclone4gx_3072_m : cyclone4gx_3072_m
            generic map (
               starting_channel_number     => S_CH_NUMBER_M
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_areset                  => pll_areset,       
               pll_configupdate            => pll_configupdate,         
               pll_inclk(0)                => gxb_refclk,       
               pll_inclk(1)                => gxb_refclk,
               pll_scanclk                 => pll_scanclk,      
               pll_scanclkena              => pll_scanclkena,   
               pll_scandata                => pll_scandata,     
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_m, 
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               tx_bitslipboundaryselect    => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull               => tx_datainfull(21 downto 0),        
               tx_digitalreset(0)          => tx_digitalreset,
               pll_locked(0)               => pll_locked,
               pll_locked(1)               => rx_pll_locked,
               pll_reconfig_done           => s_pll_reconfig_done,                 
               pll_scandataout             => pll_scandataout,                   
               reconfig_fromgxb            => reconfig_fromgxb_m(4 downto 0),    
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0), 
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull(31 downto 0),
               rx_freqlocked(0)            => rx_freqlocked,
               tx_clkout(0)                => tx_clkout,
               tx_dataout(0)               => gxb_txdataout
            );
         end generate;
         
         gen_slave:
         if SYNC_MODE = 1 generate
         begin           
            inst_cyclone4gx_3072_s_tx : cyclone4gx_3072_s_tx
            generic map(
               starting_channel_number   => S_CH_NUMBER_S_TX
            )
            port map (
               cal_blk_clk               => gxb_cal_blk_clk,                    
               gxb_powerdown(0)          => gxb_powerdown,                      
               pll_areset(0)             => pll_areset(0),                      
               pll_configupdate(0)       => pll_configupdate(0),                
               pll_inclk(0)              => gxb_pll_inclk,                         
               pll_scanclk(0)            => pll_scanclk(0),                     
               pll_scanclkena(0)         => pll_scanclkena(0),                  
               pll_scandata(0)           => pll_scandata(0),                    
               reconfig_clk              => reconfig_clk,                       
               reconfig_togxb            => reconfig_togxb_s_tx,                
               tx_bitslipboundaryselect  => tx_bitslipboundaryselect(4 downto 0),           
               tx_datainfull             => tx_datainfull(21 downto 0),         
               tx_digitalreset(0)        => tx_digitalreset,                    
               pll_locked(0)             => pll_locked,                         
               pll_reconfig_done(0)      => s_pll_reconfig_done(0),               
               pll_scandataout(0)        => pll_scandataout(0),                 
               reconfig_fromgxb          => reconfig_fromgxb_s_tx(4 downto 0),  
               tx_clkout(0)              => tx_clkout,                          
               tx_dataout(0)             => gxb_txdataout                       
            );
            inst_cyclone4gx_3072_s_rx : cyclone4gx_3072_s_rx
            generic map(
               starting_channel_number      => S_CH_NUMBER_S_RX
            )
            port map (
               cal_blk_clk                  => gxb_cal_blk_clk,                  
               gxb_powerdown(0)             => gxb_powerdown,                    
               pll_areset(0)                => pll_areset(1),                    
               pll_configupdate(0)          => pll_configupdate(1),              
               pll_inclk(0)                 => gxb_refclk,                       
               pll_scanclk(0)               => pll_scanclk(1),                   
               pll_scanclkena(0)            => pll_scanclkena(1),                
               pll_scandata(0)              => pll_scandata(1),                  
               reconfig_clk                 => reconfig_clk,                     
               reconfig_togxb               => reconfig_togxb_s_rx,              
               rx_analogreset(0)            => rx_analogreset,                   
               rx_datain(0)                 => gxb_rxdatain,                     
               rx_digitalreset(0)           => rx_digitalreset,                  
               rx_enapatternalign(0)        => rx_enapatternalign,           
               pll_locked(0)                => rx_pll_locked,                    
               pll_reconfig_done(0)         => s_pll_reconfig_done(1),             
               pll_scandataout(0)           => pll_scandataout(1),               
               reconfig_fromgxb             => reconfig_fromgxb_s_rx(4 downto 0),
               rx_bitslipboundaryselectout  => rx_bitslipboundaryselectout(4 downto 0),      
               rx_clkout(0)                 => rx_clkout,                        
               rx_dataoutfull               => rx_dataoutfull(31 downto 0),      
               rx_freqlocked(0)             => rx_freqlocked                     
            );
         end generate; 
      end generate; 
   end generate; 
   
-------------------------------------- ArriaIIGZ --------------------------------------------------------------------
   gen_arria_ii_gz:
   if DEVICE = 2 generate
   begin
      gen_614mbps:
      if LINERATE = 614 generate
      begin
         gen_master:
         if SYNC_MODE = 0 or SYNC_MODE = 2 generate
         begin
            inst_arria2gz_614_m : arria2gz_614_m
            generic map (
               starting_channel_number     => S_CH_NUMBER_M
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_m,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               tx_bitslipboundaryselect    => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull               => tx_datainfull, 
               tx_digitalreset(0)          => tx_digitalreset,
               pll_locked(0)               => pll_locked,
               reconfig_fromgxb            => reconfig_fromgxb_m,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0), 
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull,
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked,
               tx_clkout(0)                => tx_clkout,
               tx_dataout(0)               => gxb_txdataout
            );
         end generate;
         gen_slave:
         if SYNC_MODE = 1 generate
         begin
            inst_arria2gz_614_s_tx : arria2gz_614_s_tx
            generic map (
               starting_channel_number  => S_CH_NUMBER_S_TX
            )
            port map (
               cal_blk_clk              => gxb_cal_blk_clk,
               gxb_powerdown(0)         => gxb_powerdown,
               pll_inclk_rx_cruclk(0)   => gxb_pll_inclk,
               reconfig_clk             => reconfig_clk,
               reconfig_togxb           => reconfig_togxb_s_tx,
               tx_bitslipboundaryselect => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull            => tx_datainfull,
               tx_digitalreset(0)       => tx_digitalreset,
               pll_locked(0)            => pll_locked,
               reconfig_fromgxb         => reconfig_fromgxb_s_tx,
               tx_clkout(0)             => tx_clkout,
               tx_dataout(0)            => gxb_txdataout
            );
            inst_arria2gz_614_s_rx : arria2gz_614_s_rx
            generic map (
               starting_channel_number     => S_CH_NUMBER_S_RX
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_s_rx,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,      
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               reconfig_fromgxb            => reconfig_fromgxb_s_rx,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0),
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull,
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked
            );
         end generate;
      end generate;
      gen_1228mbps:
      if LINERATE = 0 generate
      begin
         gen_master:
         if SYNC_MODE = 0 or SYNC_MODE = 2 generate
         begin
            inst_arria2gz_1228_m : arria2gz_1228_m
            generic map (
               starting_channel_number     => S_CH_NUMBER_M
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_m,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               tx_bitslipboundaryselect    => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull               => tx_datainfull, 
               tx_digitalreset(0)          => tx_digitalreset,
               pll_locked(0)               => pll_locked,
               reconfig_fromgxb            => reconfig_fromgxb_m,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0), 
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull,
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked,
               tx_clkout(0)                => tx_clkout,
               tx_dataout(0)               => gxb_txdataout
            );
         end generate;
         gen_slave:
         if SYNC_MODE = 1 generate
         begin
            inst_arria2gz_1228_s_tx : arria2gz_1228_s_tx
            generic map (
               starting_channel_number  => S_CH_NUMBER_S_TX
            )
            port map (
               cal_blk_clk              => gxb_cal_blk_clk,
               gxb_powerdown(0)         => gxb_powerdown,
               pll_inclk_rx_cruclk(0)   => gxb_pll_inclk,
               reconfig_clk             => reconfig_clk,
               reconfig_togxb           => reconfig_togxb_s_tx,
               tx_bitslipboundaryselect => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull            => tx_datainfull,
               tx_digitalreset(0)       => tx_digitalreset,
               pll_locked(0)            => pll_locked,
               reconfig_fromgxb         => reconfig_fromgxb_s_tx,
               tx_clkout(0)             => tx_clkout,
               tx_dataout(0)            => gxb_txdataout
            );
            inst_arria2gz_1228_s_rx : arria2gz_1228_s_rx
            generic map (
               starting_channel_number     => S_CH_NUMBER_S_RX
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_s_rx,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,      
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               reconfig_fromgxb            => reconfig_fromgxb_s_rx,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0),
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull,
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked
            );          
         end generate;
      end generate;
      gen_2457mbps:
      if LINERATE = 1 generate
      begin
         gen_master:
         if SYNC_MODE = 0 or SYNC_MODE = 2 generate
         begin
            inst_arria2gz_2457_m : arria2gz_2457_m
            generic map (
               starting_channel_number     => S_CH_NUMBER_M
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_m,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               tx_bitslipboundaryselect    => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull               => tx_datainfull, 
               tx_digitalreset(0)          => tx_digitalreset,
               pll_locked(0)               => pll_locked,
               reconfig_fromgxb            => reconfig_fromgxb_m,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0), 
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull,
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked,
               tx_clkout(0)                => tx_clkout,
               tx_dataout(0)               => gxb_txdataout
            );
         end generate;
         gen_slave:
         if SYNC_MODE = 1 generate
         begin
            inst_arria2gz_2457_s_tx : arria2gz_2457_s_tx
            generic map (
               starting_channel_number  => S_CH_NUMBER_S_TX
            )
            port map (
               cal_blk_clk              => gxb_cal_blk_clk,
               gxb_powerdown(0)         => gxb_powerdown,
               pll_inclk_rx_cruclk(0)   => gxb_pll_inclk,
               reconfig_clk             => reconfig_clk,
               reconfig_togxb           => reconfig_togxb_s_tx,
               tx_bitslipboundaryselect => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull            => tx_datainfull,
               tx_digitalreset(0)       => tx_digitalreset,          
               pll_locked(0)            => pll_locked,
               reconfig_fromgxb         => reconfig_fromgxb_s_tx,
               tx_clkout(0)             => tx_clkout,
               tx_dataout(0)            => gxb_txdataout
            );
            inst_arria2gz_2457_s_rx : arria2gz_2457_s_rx
            generic map (
               starting_channel_number     => S_CH_NUMBER_S_RX
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_s_rx,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,      
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               reconfig_fromgxb            => reconfig_fromgxb_s_rx,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0),
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull,
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked
            );          
         end generate;
      end generate;
      gen_3072mbps:
      if LINERATE = 2 generate
      begin
         gen_master:
         if SYNC_MODE = 0 or SYNC_MODE = 2 generate
         begin
            inst_arria2gz_3072_m : arria2gz_3072_m
            generic map (
               starting_channel_number     => S_CH_NUMBER_M
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_m,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               tx_bitslipboundaryselect    => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull               => tx_datainfull, 
               tx_digitalreset(0)          => tx_digitalreset,
               pll_locked(0)               => pll_locked,
               reconfig_fromgxb            => reconfig_fromgxb_m,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0), 
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull,
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked,
               tx_clkout(0)                => tx_clkout,
               tx_dataout(0)               => gxb_txdataout
            );
         end generate;
         gen_slave:
         if SYNC_MODE = 1 generate
         begin
            inst_arria2gz_3072_s_tx : arria2gz_3072_s_tx
            generic map (
               starting_channel_number  => S_CH_NUMBER_S_TX
            )
            port map (
               cal_blk_clk              => gxb_cal_blk_clk,
               gxb_powerdown(0)         => gxb_powerdown,
               pll_inclk_rx_cruclk(0)   => gxb_pll_inclk,
               reconfig_clk             => reconfig_clk,
               reconfig_togxb           => reconfig_togxb_s_tx,
               tx_bitslipboundaryselect => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull            => tx_datainfull,
               tx_digitalreset(0)       => tx_digitalreset,          
               pll_locked(0)            => pll_locked,
               reconfig_fromgxb         => reconfig_fromgxb_s_tx,
               tx_clkout(0)             => tx_clkout,
               tx_dataout(0)            => gxb_txdataout
            );
            inst_arria2gz_3072_s_rx : arria2gz_3072_s_rx
            generic map (
               starting_channel_number     => S_CH_NUMBER_S_RX
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_s_rx,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,      
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               reconfig_fromgxb            => reconfig_fromgxb_s_rx,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0),
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull,
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked
            );          
         end generate;
      end generate;
      gen_4915mbps:
      if LINERATE = 3 generate
      begin
         gen_master:
         if SYNC_MODE = 0 or SYNC_MODE = 2 generate
         begin
            inst_arria2gz_4915_m : arria2gz_4915_m
            generic map (
               starting_channel_number     => S_CH_NUMBER_M
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_m,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               tx_bitslipboundaryselect    => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull               => tx_datainfull, 
               tx_digitalreset(0)          => tx_digitalreset,
               pll_locked(0)               => pll_locked,
               reconfig_fromgxb            => reconfig_fromgxb_m,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0), 
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull,
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked,
               tx_clkout(0)                => tx_clkout,
               tx_dataout(0)               => gxb_txdataout
            );
         end generate;
         gen_slave:
         if SYNC_MODE = 1 generate
         begin
            inst_arria2gz_4915_s_tx : arria2gz_4915_s_tx
            generic map (
               starting_channel_number  => S_CH_NUMBER_S_TX
            )
            port map (
               cal_blk_clk              => gxb_cal_blk_clk,
               gxb_powerdown(0)         => gxb_powerdown,
               pll_inclk_rx_cruclk(0)   => gxb_pll_inclk,
               reconfig_clk             => reconfig_clk,
               reconfig_togxb           => reconfig_togxb_s_tx,
               tx_bitslipboundaryselect => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull            => tx_datainfull,
               tx_digitalreset(0)       => tx_digitalreset,          
               pll_locked(0)            => pll_locked,
               reconfig_fromgxb         => reconfig_fromgxb_s_tx,
               tx_clkout(0)             => tx_clkout,
               tx_dataout(0)            => gxb_txdataout
            );
            inst_arria2gz_4915_s_rx : arria2gz_4915_s_rx
            generic map (
               starting_channel_number     => S_CH_NUMBER_S_RX
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_s_rx,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,      
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               reconfig_fromgxb            => reconfig_fromgxb_s_rx,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0),
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull,
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked
            );          
         end generate;
      end generate;
      gen_6144mbps:
      if LINERATE = 4 generate
      begin
         gen_master:
         if SYNC_MODE = 0 or SYNC_MODE = 2 generate
         begin
            inst_arria2gz_6144_m : arria2gz_6144_m
            generic map (
               starting_channel_number     => S_CH_NUMBER_M
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_m,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               tx_bitslipboundaryselect    => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull               => tx_datainfull, 
               tx_digitalreset(0)          => tx_digitalreset,
               pll_locked(0)               => pll_locked,
               reconfig_fromgxb            => reconfig_fromgxb_m,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0), 
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull,
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked,
               tx_clkout(0)                => tx_clkout,
               tx_dataout(0)               => gxb_txdataout
            );
         end generate;
         gen_slave:
         if SYNC_MODE = 1 generate
         begin
            inst_arria2gz_6144_s_tx : arria2gz_6144_s_tx
            generic map (
               starting_channel_number  => S_CH_NUMBER_S_TX
            )
            port map (
               cal_blk_clk              => gxb_cal_blk_clk,
               gxb_powerdown(0)         => gxb_powerdown,
               pll_inclk_rx_cruclk(0)   => gxb_pll_inclk,
               reconfig_clk             => reconfig_clk,
               reconfig_togxb           => reconfig_togxb_s_tx,
               tx_bitslipboundaryselect => tx_bitslipboundaryselect(4 downto 0),
               tx_datainfull            => tx_datainfull,
               tx_digitalreset(0)       => tx_digitalreset,          
               pll_locked(0)            => pll_locked,
               reconfig_fromgxb         => reconfig_fromgxb_s_tx,
               tx_clkout(0)             => tx_clkout,
               tx_dataout(0)            => gxb_txdataout
            );
            inst_arria2gz_6144_s_rx : arria2gz_6144_s_rx
            generic map (
               starting_channel_number     => S_CH_NUMBER_S_RX
            )
            port map (
               cal_blk_clk                 => gxb_cal_blk_clk,
               gxb_powerdown(0)            => gxb_powerdown,
               pll_inclk_rx_cruclk(0)      => gxb_refclk,
               reconfig_clk                => reconfig_clk,
               reconfig_togxb              => reconfig_togxb_s_rx,
               rx_analogreset(0)           => rx_analogreset,
               rx_datain(0)                => gxb_rxdatain,      
               rx_digitalreset(0)          => rx_digitalreset,
               rx_enapatternalign(0)       => rx_enapatternalign,
               reconfig_fromgxb            => reconfig_fromgxb_s_rx,
               rx_bitslipboundaryselectout => rx_bitslipboundaryselectout(4 downto 0),
               rx_clkout(0)                => rx_clkout,
               rx_dataoutfull              => rx_dataoutfull,
               rx_freqlocked(0)            => rx_freqlocked,
               rx_pll_locked(0)            => rx_pll_locked
            );          
         end generate;
      end generate;
   end generate;

---------------------------------------ArriaV GX/GZ or StratixV or CycloneV------------------------------------------------------------

   gen_arria_V_or_stratix_V_gx_or_cyclone_V:
   if DEVICE = 4 or (DEVICE = 5 and LINERATE /= 5) or DEVICE = 6 or DEVICE = 7 generate
   begin
      phy_mgmt_clk                                    <= reconfig_clk ;
      phy_mgmt_clk_reset                              <= reset;
      phy_mgmt_address                                <= phy_mgmt_address_temp;
      phy_mgmt_read                                   <= phy_mgmt_read_temp;
      phy_mgmt_write                                  <= phy_mgmt_write_temp;
      phy_mgmt_writedata                              <= phy_mgmt_writedata_temp;
      phy_mgmt_waitrequest_temp                       <= phy_mgmt_waitrequest;
      rx_ready                                        <= phy_rx_ready;
      tx_ready                                        <= phy_tx_ready; 
      phy_pll_ref_clk                                 <= gxb_refclk;
      gxb_txdataout                                   <= phy_tx_serial_data;
      pll_locked                                      <= phy_pll_locked;
      phy_rx_serial_data                              <= gxb_rxdatain;
      rx_pll_locked                                   <= phy_rx_is_lockedtoref;
      rx_freqlocked                                   <= phy_rx_is_lockedtodata;
      tx_clkout                                       <= phy_tx_clkout;
      rx_clkout                                       <= phy_rx_clkout;
      phy_tx_parallel_data                            <= tx_parallel_data_pl;
      rx_parallel_data                                <= phy_rx_parallel_data;
      phy_tx_bitslipboundaryselect                    <= tx_bitslipboundaryselect(4 downto 0);
      rx_bitslipboundaryselectout(4 downto 0)         <= phy_rx_bitslipboundaryselectout;
      rx_bitslipboundaryselectout(6 downto 5)         <= (others => '0');
      phy_pll_inclk                                   <= gxb_pll_inclk;
   end generate;
   
   gen_not_sv_or_av_or_cv:
   if DEVICE < 4 generate
      phy_mgmt_clk                                       <= '0';
      phy_mgmt_clk_reset                                 <= '0';
      phy_mgmt_address                                   <= (others => '0');
      phy_mgmt_read                                      <= '0';   
      phy_mgmt_write                                     <= '0';
      phy_mgmt_writedata                                 <= (others => '0');                     
      phy_pll_ref_clk                                    <= '0';   
      phy_rx_serial_data                                 <= '0';      
      phy_tx_parallel_data                               <= (others => '0');  
      phy_tx_bitslipboundaryselect                       <= (others => '0');
      phy_pll_inclk                                      <= '0';
      rx_bitslipboundaryselectout(6 downto 5)            <= (others => '0');
   end generate;

---------------------------------------Arria V GT 9.8G---------------------------------------------------------------

   gen_arria_v_98G:
   if (DEVICE = 5 and LINERATE = 5) generate
   begin
      -- Un-used hard PCS port
      phy_mgmt_address                 <= (others => '0');
      phy_mgmt_writedata               <= (others => '0');
      phy_tx_parallel_data             <= (others => '0');
      phy_tx_bitslipboundaryselect     <= (others => '0');
      phy_mgmt_clk                     <= '0';
      phy_mgmt_clk_reset               <= '0';
      phy_mgmt_read                    <= '0';
      phy_mgmt_write                   <= '0';
      phy_pll_ref_clk                  <= '0';
      phy_rx_serial_data               <= '0';
      phy_pll_inclk                    <= '0';
      -- Soft PCS ports
      -- Output
      xcvr_mgmt_clk                    <= reconfig_clk;
      xcvr_mgmt_clk_reset              <= reset;
      xcvr_mgmt_read                   <= phy_mgmt_read_temp;
      xcvr_mgmt_write                  <= phy_mgmt_write_temp;
      xcvr_mgmt_address                <= phy_mgmt_address_temp;
      xcvr_mgmt_writedata              <= phy_mgmt_writedata_temp;
      phy_mgmt_waitrequest_temp        <= xcvr_mgmt_waitrequest;
      xcvr_pll_ref_clk                 <= gxb_pll_inclk;
      xcvr_cdr_ref_clk                 <= gxb_refclk;
      xcvr_usr_pma_clk                 <= usr_pma_clk;
      xcvr_usr_clk                     <= usr_clk;
      xcvr_fifo_calc_clk               <= clk_ex_delay;
      xcvr_tx_fifocalreset             <= reset_ex_delay;
      xcvr_rx_fifocalreset             <= reset_ex_delay;
      xcvr_rx_serial_data              <= gxb_rxdatain;
      xcvr_tx_parallel_data            <= tx_parallel_data_pl(31 downto 0);
      xcvr_tx_datak                    <= tx_datak_pl;
      xcvr_tx_bitslipboundaryselect    <= tx_bitslipboundaryselect;
      xcvr_tx_fifo_sample_size         <= ex_delay_period(7 downto 0);
      xcvr_rx_fifo_sample_size         <= ex_delay_period(7 downto 0);
      xcvr_tx_fiforeset                <= tx_buf_resync;
      xcvr_rx_fiforeset                <= rx_buf_resync;
      xcvr_tx_data_width_pma           <= data_width_pma;
      xcvr_rx_data_width_pma           <= data_width_pma;
      -- Input
      rx_pll_locked                    <= xcvr_rx_is_lockedtoref;
      rx_freqlocked                    <= xcvr_rx_is_lockedtodata;
      rx_clkout                        <= xcvr_rx_clkout;
      rx_parallel_data(31 downto 0)    <= xcvr_rx_parallel_data;
      rx_datak                         <= xcvr_rx_datak;
      gxb_txdataout                    <= xcvr_tx_serial_data;
      rx_bitslipboundaryselectout      <= xcvr_rx_bitslipboundaryselectout;
      rx_disperr                       <= xcvr_rx_disperr;
      rx_errdetect                     <= xcvr_rx_errdetect;
      rx_syncstatus                    <= xcvr_rx_syncstatus;
      pll_locked                       <= xcvr_pll_locked;
      rx_ready                         <= xcvr_rx_ready;
      tx_ready                         <= xcvr_tx_ready;
      tx_ex_buf_delay                  <= xcvr_tx_phase_measure_acc;
      rx_ex_buf_delay                  <= xcvr_rx_phase_measure_acc;
      tx_buf_delay                     <= xcvr_tx_fifo_latency;
      rx_buf_delay                     <= xcvr_rx_fifo_latency;
      tx_ex_buf_valid                  <= xcvr_tx_ph_acc_valid;
      rx_ex_buf_valid                  <= xcvr_rx_ph_acc_valid;
      tx_buf_overflow                  <= xcvr_tx_wr_full;
      rx_buf_overflow                  <= xcvr_rx_wr_full;
      tx_buf_underflow                 <= xcvr_tx_rd_empty;
      rx_buf_underflow                 <= xcvr_rx_rd_empty;

      tx_clkout                        <= usr_clk;

      process(usr_pma_clk)
      begin
         if usr_pma_clk'event and usr_pma_clk = '1' then
            reset_usr_pma_clk_sync1 <= reset;
            reset_usr_pma_clk_sync2 <= reset_usr_pma_clk_sync1;
         end if; 
      end process;
      process(usr_pma_clk,reset_usr_pma_clk_sync2)
         variable tx_buf_err_cnt : std_logic_vector(4 downto 0);
         variable rx_buf_err_cnt : std_logic_vector(4 downto 0);
      begin
         if reset_usr_pma_clk_sync2 = '1' then
            tx_buf_error   <= '0';
            rx_buf_error   <= '0';
            tx_buf_resync  <= '1';
            rx_buf_resync  <= '1';
            tx_buf_err_cnt := (others => '0');
            rx_buf_err_cnt := (others => '0');
         elsif usr_pma_clk'event and usr_pma_clk = '1' then
            tx_buf_overflow_sync1  <= tx_buf_overflow;
            tx_buf_overflow_sync2  <= tx_buf_overflow_sync1;
            tx_buf_underflow_sync1 <= tx_buf_underflow;
            tx_buf_underflow_sync2 <= tx_buf_underflow_sync1;
            rx_buf_overflow_sync1  <= rx_buf_overflow;
            rx_buf_overflow_sync2  <= rx_buf_overflow_sync1;
            rx_buf_underflow_sync1 <= rx_buf_underflow;
            rx_buf_underflow_sync2 <= rx_buf_underflow_sync1;
            tx_buf_error           <= tx_buf_overflow_sync2 or tx_buf_underflow_sync2;
            rx_buf_error           <= rx_buf_overflow_sync2 or rx_buf_underflow_sync2;
            if tx_buf_error = '1' then
               tx_buf_err_cnt := tx_buf_err_cnt + "1";
            end if;
            if rx_buf_error = '1' then
               rx_buf_err_cnt := rx_buf_err_cnt + "1";
            end if;
            if tx_buf_err_cnt = "11111" then
               tx_buf_resync <= '1';               
            else
               tx_buf_resync <= '0'; 
            end if;
            if rx_buf_err_cnt = "11111" or rx_buf_resync_cpu = '1' or cpri_rx_freq_alarm = '1' then
               rx_buf_resync <= '1';
            else
               rx_buf_resync <= '0';
            end if;
         end if;
      end process;
   end generate;
end rtl;
------------------------------------------------------------#END#----------------------------------------------------
