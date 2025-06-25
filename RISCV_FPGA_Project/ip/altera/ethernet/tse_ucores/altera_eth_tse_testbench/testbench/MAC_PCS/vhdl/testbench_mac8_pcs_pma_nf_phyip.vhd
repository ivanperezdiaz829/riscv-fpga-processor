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


-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
--
-- Revision Control Information
--
-- $RCSfile: testbench_mac8_pcs_pma.vhd,v $
-- $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/testbench/MAC_PCS/vhdl/testbench_mac8_pcs_pma.vhd,v $
--
-- $Revision: #5 $
-- $Date: 2013/04/04 $
-- Check in by : $Author: ksting $
-- Author      : SKNg/TTChong
--
-- Project     : Triple Speed Ethernet - 10/100/1000 MAC +  1000 Base-X PCS / SGMII + PMA
--
-- Description : (Simulation only)
--
-- Testbench for 8-Bit Core 10/100/1000 MAC +  1000 Base-X PCS / SGMII + PMA
-- 
-- ALTERA Confidential and Proprietary
-- Copyright 2007 (c) Altera Corporation
-- All rights reserved
--
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------

library ieee ;
use     ieee.std_logic_1164.all ;
use     ieee.std_logic_arith.all ;
use     ieee.std_logic_unsigned.all ;
use     ieee.std_logic_misc.all;
use     std.textio.all ;
use     work.altera_ethmodels_pack.all;


entity tb is

generic(
    -- Simulation Settings (Testbench)
    -- -------------------------------

    LOG_FILE                    : string(1 to 7) := "sim.log";


    -- MAC related

    ETH_MODE                    : integer := 1000 ; -- Ethernet Operation Mode
    HD_ENA                      : boolean := FALSE ; -- Enable Half Duplex Operation
    TB_RXFRAMES                 : integer := 0 ; -- number of frames to send in RX path - If set to 0, generator is diabled and loopbackmode is active
    TB_RXIPG                    : integer := 12 ; -- Inter Packet Gap used by RX generator
    TB_TXFRAMES                 : integer := 5 ; -- number of frames to send in TX path (set to 0 to disable)
    TB_PAUSECONTROL             : boolean := TRUE ; -- react on PAUSE Frames coming from MAC
    TB_LENSTART                 : integer := 100 ; -- length to start (incremented each new frame by TB_LENSTEP)
    TB_LENSTEP                  : integer := 1 ; -- steps the length should increase with each frame
    TB_LENMAX                   : integer := 1500 ; -- max. payload length for generation
    TB_ENA_PADDING              : boolean := TRUE ; -- enable padding of frames coming from RX PHY generator
    TB_ENA_VLAN                 : integer := 0 ; -- enable generation of a VLAN frame every x frames
    TB_STOPREAD                 : integer := 0 ; -- stop reading the RX fifo after x frames
    TB_HOLDREAD                 : integer := 1000 ; -- clock cycles to wait after stopread before continuing to read
    TB_TRIGGERXOFF              : integer := 0 ; -- when to trigger a pause frame using the xoff_gen command
    TB_TRIGGERXON               : integer := 0 ; -- when to trigger a pause frame using the xon_gen command
    TB_MACLENMAX                : integer := 1518 ; -- max. frame length configuration of MAC
    TB_MACPAUSEQ                : integer := 15 ; -- pause quanta configuration of MAC
    TB_MACIGNORE_PAUSE          : boolean := FALSE ; -- Ignore Pause Frames
    TB_MACFWD_PAUSE             : boolean := FALSE ; -- Forward Pause Frames
    TB_MACFWDCRC                : boolean := FALSE ; -- Forward CRC
    TB_MACINSERT_ADDR           : boolean := FALSE ; -- Insert MAC source address
    TB_MACRX_ERR_DISC           : integer := 1 ;  --MAC function discards erroneous frames received, only when rx_section_full register = 0
    TB_ADDR_SEL                 : integer := 0 ; -- Select MAC source address
    TB_MACPADEN                 : boolean := TRUE ; -- Enable Padding
    TB_MODPAUSEQ                : integer := 16 ; -- Pause Quanta
    TB_ENA_VAR_IPG              : boolean := FALSE ; -- Enable Variable IPG  
    RX_FIFO_SECTION_EMPTY       : integer := 0 ; -- Section Empty Threshold
    RX_FIFO_SECTION_FULL        : integer := 16 ; -- Section Full Threshold
    TX_FIFO_SECTION_EMPTY       : integer := 16 ; -- Section Empty Threshold
    TX_FIFO_SECTION_FULL        : integer := 16 ; -- Section Full Threshold
    RX_FIFO_AE                  : integer := 8 ; -- Almost Empty Threshold
    RX_FIFO_AF                  : integer := 8 ; -- Almost Full Threshold
    TX_FIFO_AE                  : integer := 8 ; -- Almost Empty Threshold
    TX_FIFO_AF                  : integer := 10 ; -- Almost Full Threshold
    RX_COL_FRM                  : integer := 0 ; -- Colision on Frame Number
    RX_COL_GEN                  : integer := 0 ; -- Colision on Nibble Number
    TX_COL_FRM                  : integer := 0 ; -- Colision on Frame Number
    TX_COL_GEN                  : integer := 0 ; -- Colision on Nibble Number
    TX_COL_NUM                  : integer := 0 ; -- Number of Concecutive Collisions
    TX_COL_DELAY                : integer := 0 ; -- Delay Between Concecutive Collisions
    TB_MDIO_ADDR1               : integer := 1 ; -- MDIO PHY 1 Address
    TB_PROMIS_ENA               : boolean := true ; -- Enable Promiscuous Mode
    PERIOD_HASHCLK              : time := 15 ns;  -- 66MHz hash table programming
    TB_MDIO_SIMULATION          : boolean := FALSE ; -- Enable MDIO Simulation
    TB_ENA_AUTONEG              : boolean := FALSE ; -- Enable Autonegotiation
    TB_PCS_BYPASS               : boolean := FALSE ; -- Bypass PCS
    TB_IPG_LENGTH               : integer := 12 ; -- Enable Inverted Loopback
    LOC_HIGH                    : time := 4.0 ns ;
    LOC_LOW                     : time := 4.0 ns ; 
    TB_TX_FF_ERR                : boolean := FALSE ; -- Generate Frame with Errors on Tx FIFO
    ENA_MAGIC                   : boolean := FALSE ; -- Enable Sleep . Wake Up Simulation
    ENA_SLEEP_PIN               : boolean := FALSE ; -- Sleep Activated with magic_sleep_n Pin
    ENA_INVERT_LB               : boolean := FALSE ; -- Enable Inverted Loopback

    -- PCS related
    TB_PHYERR                   : boolean := FALSE; -- Generate PHY Error
    TB_PCS_LINK_TIMER           : integer := 512 ; -- Link Timer
    TB_PARTNER_LINK_TIMER       : integer := 128 ; -- Link Timer
    TB_TX_ERR                   : boolean := FALSE ; -- Enable GMII Error
    TB_PARTNER_PS1              : boolean := TRUE ; -- Pause Support Encoding
    TB_PARTNER_PS2              : boolean := FALSE ; -- Pause Support Encoding
    TB_PARTNER_RF1              : boolean := FALSE ; -- Remote Fault Encoding
    TB_PARTNER_RF2              : boolean := FALSE ; -- Remote Fault Encoding
    TB_PCS_PS1                  : boolean := TRUE ; -- Pause Support Encoding
    TB_PCS_PS2                  : boolean := FALSE ; -- Pause Support Encoding
    TB_PCS_RF1                  : boolean := FALSE ; -- Remote Fault Encoding
    TB_PCS_RF2                  : boolean := FALSE ; -- Remote Fault Encoding
    TB_ISOLATE                  : boolean := FALSE ; -- Remote Fault Encoding
    TB_SGMII_ENA                : boolean := FALSE ; -- Enable SGMII Interface
    TB_SGMII_AUTO_CONF          : boolean := FALSE ; -- Enable SGMII Auto-Configuration
    TB_SGMII_1000               : boolean := TRUE ; -- Enable SGMII Gigabit
    TB_SGMII_100                : boolean := FALSE ; -- Enable SGMII 100Mbps
    TB_SGMII_10                 : boolean := FALSE ; -- Enable SGMII 10Mbps
    TB_SGMII_HD                 : boolean := FALSE --Enable SGMII Half-Duplex Operation
   

        
); -- end generic


type TARGET_TYPE is (GEN) ;

-- Simulation Configuration
-- ------------------------
   -- Multicast addresses 

constant MCAST_TABLEN : integer := 9;    -- number of MAC addresses in the table
type mctable is array(0 to MCAST_TABLEN-1) of std_logic_vector(47 downto 0); -- rx_err/rx_en/rx_d(7:0)
constant MCAST_ADDRESSLIST : mctable := (
  X"887654332211",      -- LSB=1 is Multicast address!
  X"886644352611",      -- LSB=1 is Multicast address!
  X"ABCDEF012313",   
  X"92456545ab15",   
  X"432680010217",   
  X"adb589215439",   
  X"ffeacfe3434B",   
  X"ffccddaa3123",   
  X"adb358415439");


-- Core Settings
-- WARNING: DO NOT MODIFY THESE PARAMETERS
-- ------------------

-- $<RTL_PARAMETERS>

end tb ;

architecture a of tb is

    

-- ------------------
-- ------------------
-- COMPONENTS
-- ------------------
-- ------------------

-- $<RTL_CORE_INSTANCE_COMPONENT>
                

        component loopback_adapter is
                port (
              -- Interface: clk                     
              clk                  : in std_logic;
              reset                : in std_logic;
              -- Interface: in
              in_ready              : out std_logic;          
              in_valid              : in  std_logic;
              in_data               : in  std_logic_vector (7 downto 0);
              in_startofpacket      : in  std_logic;
              in_endofpacket        : in  std_logic;
              in_error              : in  std_logic_vector(4 downto 0);
              -- Interface: out
              out_ready             : in std_logic;
              out_valid             : out std_logic;
              out_data              : out std_logic_vector (7 downto 0);
              out_startofpacket     : out std_logic;
              out_endofpacket       : out std_logic;
              out_error             : out std_logic
            );
        end component loopback_adapter ;
    


        component ethgenerator2
                generic (  
                        THOLD           : time := 1 ns);
                port (
                        reset           : in std_logic ;                        -- active high
                        rx_clk          : in std_logic ;
                        rxd             : out std_logic_vector(7 downto 0);
                        rx_dv           : out std_logic;
                        rx_er           : out std_logic;
                        sop             : out std_logic;                        -- pulse with first character
                        eop             : out std_logic;                        -- pulse with last  character
                        ethernet_speed  : in std_logic;
                        mii_mode        : in std_logic;                         -- 4-bit Nibbles (Fast Ethernet)
                        rgmii_mode      : in std_logic;                         -- 4-bit DDR (Reduced Gigabit)     
                        mac_reverse     : in std_logic;                         -- 1: dst/src are sent MSB first
                        dst             : in std_logic_vector(47 downto 0);     -- destination address
                        src             : in std_logic_vector(47 downto 0);     -- source address
                        prmble_len      : in integer range 0 to 15;             -- length of preamble
                        pquant          : in std_logic_vector(15 downto 0);     -- Pause Quanta value
                        vlan_ctl        : in std_logic_vector(15 downto 0);     -- VLAN control info
                        len             : in std_logic_vector(15 downto 0);     -- Length of payload
                        frmtype         : in std_logic_vector(15 downto 0);     -- if non-null: type field instead length
                        cntstart        : in integer range 0 to 255;            -- payload data counter start (first byte of payload)
                        cntstep         : in integer range 0 to 255;            -- payload counter step (2nd byte in paylaod)
                        ipg_len         : in integer range 0 to 32768;          -- inter packet gap (delay after CRC)         
                        payload_err     : in std_logic;                         -- generate payload pattern error (last payload byte is wrong)
                        prmbl_err       : in std_logic;
                        crc_err         : in std_logic;
                        vlan_en         : in std_logic;
                        pause_gen       : in std_logic;
                        wrong_pause_op  : in std_logic ;                        -- Generate Pause Frame with Wrong Opcode       
                        wrong_pause_lgth: in std_logic ;                        -- Generate Pause Frame with Wrong Opcode       
                        pad_en          : in std_logic;
                        phy_err         : in std_logic;
                        end_err         : in std_logic;                         -- keep rx_dv high one cycle after end of frame                
                        magic           : in std_logic;     
                        stack_vlan      : in std_logic;   
                        data_only       : in std_logic;                         -- if set omits preamble, padding, CRC            
                        start           : in  std_logic;
                        done            : out std_logic );
      
        end component ; 
        
                
                
        component ethgenerator 
            generic (  
                        THOLD  : time;
                        LATENCY: integer := 0
                ) ;

                port (
                        reset           : in std_logic ;                        -- active high
                        rx_clk          : in std_logic ;
                        enable          : in std_logic ;
            rxd             : out std_logic_vector(7 downto 0);
                        rx_dv           : out std_logic;
                        rx_er           : out std_logic;                
                        sop             : out std_logic;                        -- pulse with first character
                        eop             : out std_logic;                        -- pulse with last  character
                        mac_reverse     : in std_logic;                         -- 1: dst/src are sent MSB first
                        dst             : in std_logic_vector(47 downto 0);     -- destination address
                        src             : in std_logic_vector(47 downto 0);     -- source address     
                        prmble_len      : in integer range 0 to 15;             -- length of preamble
                        pquant          : in std_logic_vector(15 downto 0);     -- Pause Quanta value
                        vlan_ctl        : in std_logic_vector(15 downto 0);     -- VLAN control info
                        len             : in std_logic_vector(15 downto 0);     -- Length of payload
                        frmtype         : in std_logic_vector(15 downto 0);     -- if non-null: type field instead length      
                        cntstart        : in integer range 0 to 255;            -- payload data counter start (first byte of payload)
                        cntstep         : in integer range 0 to 255;            -- payload counter step (2nd byte in paylaod)
                        ipg_len         : in integer range 0 to 32768;          -- inter packet gap (delay after CRC)         
                        payload_err     : in std_logic;                         -- generate payload pattern error (last payload byte is wrong)
                        prmbl_err       : in std_logic;
                        crc_err         : in std_logic;
                        vlan_en         : in std_logic;
                        pause_gen       : in std_logic;
                        wrong_pause_op  : in std_logic ;                        -- Generate Pause Frame with Wrong Opcode       
                        wrong_pause_lgth: in std_logic ;                        -- Generate Pause Frame with Wrong Opcode       
                        pad_en          : in std_logic;
                        phy_err         : in std_logic;
                        end_err         : in std_logic;                         -- keep rx_dv high one cycle after end of frame
                        magic           : in std_logic;     
                        stack_vlan      : in std_logic;   
                        data_only       : in std_logic;                         -- if set omits preamble, padding, CRC            
                        start           : in  std_logic;
                        done            : out std_logic );
        end component ;


        component top_ethgenerator_8
            generic (  THOLD           : time    := 1 ns; 
                       ENABLE_SHIFT16  : integer := 1;  --0 for false, 1 for true
                       ZERO_LATENCY    : integer := 1   --0 for NON-ZERO read latency, etc.
                    );
            port (
      
               reset        : in    std_logic;
               clk          : in    std_logic;
               enable       : in    std_logic;
               dout         : out   std_logic_vector(7 downto 0);
               dval         : out   std_logic;
               derror       : out   std_logic;
               sop          : out   std_logic;
               eop          : out   std_logic;
               mac_reverse  : in    std_logic;
               dst          : in    std_logic_vector (47 downto 0);
               src          : in    std_logic_vector (47 downto 0);
               prmble_len   : in    integer range 0 to 40;
               pquant       : in    std_logic_vector (15 downto 0);
               vlan_ctl     : in    std_logic_vector (15 downto 0);
               len          : in    std_logic_vector (15 downto 0);
               frmtype      : in    std_logic_vector (15 downto 0);
               cntstart     : in    integer range 0 to 255;
               cntstep      : in    integer range 0 to 255;
               ipg_len      : in    integer range 0 to 32768;
               payload_err  : in    std_logic;
               prmbl_err    : in    std_logic;
               crc_err      : in    std_logic;
               vlan_en      : in    std_logic;
               stack_vlan   : in    std_logic;
               pause_gen    : in    std_logic;
               pad_en       : in    std_logic;
               phy_err      : in    std_logic;
               end_err      : in    std_logic;
               data_only    : in    std_logic;
               start        : in    std_logic;
               done         : out   std_logic
             );
        end component ;
        
        
        component ethmonitor2 
            port (

                reset           : in std_logic ;
                tx_clk          : in std_logic ;
                txd             : in std_logic_vector(7 downto 0);
                tx_dv           : in std_logic;
                tx_er           : in std_logic;       
                tx_sop          : in std_logic;
                tx_eop          : in std_logic;                
                ethernet_speed  : in std_logic;
        mii_mode        : in std_logic;                         -- 4-bit Nibbles (Fast Ethernet)
                rgmii_mode      : in std_logic;                         -- 4-bit DDR (Reduced Gigabit)
                dst             : out std_logic_vector(47 downto 0);    -- destination address
                src             : out std_logic_vector(47 downto 0);    -- source address
                prmble_len      : out integer range 0 to 10000;         -- length of preamble
                pquant          : out std_logic_vector(15 downto 0);    -- Pause Quanta value
                vlan_ctl        : out std_logic_vector(15 downto 0);    -- VLAN control info
                len             : out std_logic_vector(15 downto 0);    -- Length of payload
                frmtype         : out std_logic_vector(15 downto 0);    -- if non-null: type field instead length
                payload         : out std_logic_vector(7 downto 0);
                payload_vld     : out std_logic;        
                is_vlan         : out std_logic;
                is_stack_vlan   : out std_logic;
                is_pause        : out std_logic;
                crc_err         : out std_logic;
                prmbl_err       : out std_logic;
                len_err         : out std_logic;
                payload_err     : out std_logic;
                frame_err       : out std_logic;
                pause_op_err    : out std_logic;
                pause_dst_err   : out std_logic;
                mac_err         : out std_logic;
                end_err         : out std_logic;
                jumbo_en        : in std_logic;
                data_only       : in std_logic;
                frm_rcvd        : out std_logic );
        end component ; 


        component ethmonitor is 
        generic (  ENABLE_SHIFT16 : integer := 0  --0 for false, 1 for true
            );
                port (
                        reset         : in std_logic ;     -- active high
                        tx_clk        : in std_logic ;
                        txd           : in std_logic_vector(7 downto 0);
                        tx_dv         : in std_logic;
                        tx_er         : in std_logic;
                        tx_sop        : in std_logic;
                        tx_eop        : in std_logic;                                                                     
                        dst           : out std_logic_vector(47 downto 0); -- destination address
                        src           : out std_logic_vector(47 downto 0); -- source address
                        prmble_len    : out integer range 0 to 10000;         -- length of preamble
                        pquant        : out std_logic_vector(15 downto 0); -- Pause Quanta value
                        vlan_ctl      : out std_logic_vector(15 downto 0); -- VLAN control info
                        len           : out std_logic_vector(15 downto 0); -- Length of payload
                        frmtype       : out std_logic_vector(15 downto 0); -- if non-null: type field instead length
                        payload       : out std_logic_vector(7 downto 0);
                        payload_vld   : out std_logic;
                        is_vlan       : out std_logic;
                        is_stack_vlan : out std_logic;
                        is_pause      : out std_logic;
                        crc_err       : out std_logic;
                        prmbl_err     : out std_logic;
                        len_err       : out std_logic;
                        payload_err   : out std_logic;
                        frame_err     : out std_logic;
                        pause_op_err  : out std_logic;
                        pause_dst_err : out std_logic;
                        mac_err       : out std_logic;
                        end_err       : out std_logic;  -- dv stayed asserted after CRC       
                        jumbo_en      : in std_logic;
                        data_only     : in std_logic;            
                        frm_rcvd      : out std_logic );
        end component ;
        

        
        component top_mdio_slave 
        port (
                reset           : in std_logic ;
                mdc             : in std_logic ;
                mdio            : inout std_logic ;
                dev_addr        : in std_logic_vector(4 downto 0) ;
                conf_done       : out std_logic) ;
        end component ;

        component NF_PHYIP_RESET_MODEL port (
               clk                  :in std_logic;
               reset                :in std_logic;

               tx_serial_clk        :out std_logic_vector (0 downto 0);
               tx_analogreset       :out std_logic_vector (0 downto 0);
               tx_digitalreset      :out std_logic_vector (0 downto 0);
               tx_ready             :out std_logic;

               rx_analogreset       :out std_logic_vector (0 downto 0);
               rx_digitalreset      :out std_logic_vector (0 downto 0);
               rx_ready             :out std_logic;

               tx_cal_busy          :in std_logic_vector (0 downto 0);
               rx_is_lockedtodata   :in std_logic_vector (0 downto 0);
               rx_cal_busy          :in std_logic_vector (0 downto 0) );
        end component;

-- ------------------
-- ------------------
-- INTERCONNECTS
-- ------------------
-- ------------------

  -- DUT interconnects
  -- ------------------
        signal   rx_afull_clk       : std_logic;
        signal   rx_afull_channel   : std_logic_vector (4 downto 0);
        signal   rx_afull_data      : std_logic_vector (1 downto 0);
        signal   rx_afull_valid     : std_logic;
        signal   tx_crc_fwd_0       : std_logic;
        signal   data_tx_data_0     : std_logic_vector (7 downto 0);
        signal   data_tx_eop_0      : std_logic;
        signal   data_tx_error_0    : std_logic;
        signal   data_tx_sop_0      : std_logic;
        signal   data_tx_valid_0    : std_logic;
        signal   data_rx_ready_0    : std_logic;
        signal   tx_clk_0           : std_logic;
        signal   rx_clk_0           : std_logic;
        signal   gm_rx_d_0          : std_logic_vector (7 downto 0);
        signal   gm_rx_dv_0         : std_logic;
        signal   gm_rx_err_0        : std_logic;
        signal   m_rx_d_0           : std_logic_vector (3 downto 0);
        signal   m_rx_en_0          : std_logic;
        signal   m_rx_err_0         : std_logic;
        signal   set_10_0           : std_logic;
        signal   set_1000_0         : std_logic;
        signal   xon_gen_0          : std_logic;
        signal   xoff_gen_0         : std_logic;
        signal   magic_sleep_n_0    : std_logic;
        signal   m_rx_col_0         : std_logic;
        signal   m_rx_crs_0         : std_logic;
        signal   tx_crc_fwd_1       : std_logic;
        signal   data_tx_data_1     : std_logic_vector (7 downto 0);
        signal   data_tx_eop_1      : std_logic;
        signal   data_tx_error_1    : std_logic;
        signal   data_tx_sop_1      : std_logic;
        signal   data_tx_valid_1    : std_logic;
        signal   data_rx_ready_1    : std_logic;
        signal   tx_clk_1           : std_logic;
        signal   rx_clk_1           : std_logic;
        signal   gm_rx_d_1          : std_logic_vector (7 downto 0);
        signal   gm_rx_dv_1         : std_logic;
        signal   gm_rx_err_1        : std_logic;
        signal   m_rx_d_1           : std_logic_vector (3 downto 0);
        signal   m_rx_en_1          : std_logic;
        signal   m_rx_err_1         : std_logic;
        signal   set_10_1           : std_logic;
        signal   set_1000_1         : std_logic;
        signal   xon_gen_1          : std_logic;
        signal   xoff_gen_1         : std_logic;
        signal   magic_sleep_n_1    : std_logic;
        signal   m_rx_col_1         : std_logic;
        signal   m_rx_crs_1         : std_logic;
        signal   tx_crc_fwd_2       : std_logic;
        signal   data_tx_data_2     : std_logic_vector (7 downto 0);
        signal   data_tx_eop_2      : std_logic;
        signal   data_tx_error_2    : std_logic;
        signal   data_tx_sop_2      : std_logic;
        signal   data_tx_valid_2    : std_logic;
        signal   data_rx_ready_2    : std_logic;
        signal   tx_clk_2           : std_logic;
        signal   rx_clk_2           : std_logic;
        signal   gm_rx_d_2          : std_logic_vector (7 downto 0);
        signal   gm_rx_dv_2         : std_logic;
        signal   gm_rx_err_2        : std_logic;
        signal   m_rx_d_2           : std_logic_vector (3 downto 0);
        signal   m_rx_en_2          : std_logic;
        signal   m_rx_err_2         : std_logic;
        signal   set_10_2           : std_logic;
        signal   set_1000_2         : std_logic;
        signal   xon_gen_2          : std_logic;
        signal   xoff_gen_2         : std_logic;
        signal   magic_sleep_n_2    : std_logic;
        signal   m_rx_col_2         : std_logic;
        signal   m_rx_crs_2         : std_logic;
        signal   tx_crc_fwd_3       : std_logic;
        signal   data_tx_data_3     : std_logic_vector (7 downto 0);
        signal   data_tx_eop_3      : std_logic;
        signal   data_tx_error_3    : std_logic;
        signal   data_tx_sop_3      : std_logic;
        signal   data_tx_valid_3    : std_logic;
        signal   data_rx_ready_3    : std_logic;
        signal   tx_clk_3           : std_logic;
        signal   rx_clk_3           : std_logic;
        signal   gm_rx_d_3          : std_logic_vector (7 downto 0);
        signal   gm_rx_dv_3         : std_logic;
        signal   gm_rx_err_3        : std_logic;
        signal   m_rx_d_3           : std_logic_vector (3 downto 0);
        signal   m_rx_en_3          : std_logic;
        signal   m_rx_err_3         : std_logic;
        signal   set_10_3           : std_logic;
        signal   set_1000_3         : std_logic;
        signal   xon_gen_3          : std_logic;
        signal   xoff_gen_3         : std_logic;
        signal   magic_sleep_n_3    : std_logic;
        signal   m_rx_col_3         : std_logic;
        signal   m_rx_crs_3         : std_logic;
        signal   tx_crc_fwd_4       : std_logic;
        signal   data_tx_data_4     : std_logic_vector (7 downto 0);
        signal   data_tx_eop_4      : std_logic;
        signal   data_tx_error_4    : std_logic;
        signal   data_tx_sop_4      : std_logic;
        signal   data_tx_valid_4    : std_logic;
        signal   data_rx_ready_4    : std_logic;
        signal   tx_clk_4           : std_logic;
        signal   rx_clk_4           : std_logic;
        signal   gm_rx_d_4          : std_logic_vector (7 downto 0);
        signal   gm_rx_dv_4         : std_logic;
        signal   gm_rx_err_4        : std_logic;
        signal   m_rx_d_4           : std_logic_vector (3 downto 0);
        signal   m_rx_en_4          : std_logic;
        signal   m_rx_err_4         : std_logic;
        signal   set_10_4           : std_logic;
        signal   set_1000_4         : std_logic;
        signal   xon_gen_4          : std_logic;
        signal   xoff_gen_4         : std_logic;
        signal   magic_sleep_n_4    : std_logic;
        signal   m_rx_col_4         : std_logic;
        signal   m_rx_crs_4         : std_logic;
        signal   tx_crc_fwd_5       : std_logic;
        signal   data_tx_data_5     : std_logic_vector (7 downto 0);
        signal   data_tx_eop_5      : std_logic;
        signal   data_tx_error_5    : std_logic;
        signal   data_tx_sop_5      : std_logic;
        signal   data_tx_valid_5    : std_logic;
        signal   data_rx_ready_5    : std_logic;
        signal   tx_clk_5           : std_logic;
        signal   rx_clk_5           : std_logic;
        signal   gm_rx_d_5          : std_logic_vector (7 downto 0);
        signal   gm_rx_dv_5         : std_logic;
        signal   gm_rx_err_5        : std_logic;
        signal   m_rx_d_5           : std_logic_vector (3 downto 0);
        signal   m_rx_en_5          : std_logic;
        signal   m_rx_err_5         : std_logic;
        signal   set_10_5           : std_logic;
        signal   set_1000_5         : std_logic;
        signal   xon_gen_5          : std_logic;
        signal   xoff_gen_5         : std_logic;
        signal   magic_sleep_n_5    : std_logic;
        signal   m_rx_col_5         : std_logic;
        signal   m_rx_crs_5         : std_logic;
        signal   tx_crc_fwd_6       : std_logic;
        signal   data_tx_data_6     : std_logic_vector (7 downto 0);
        signal   data_tx_eop_6      : std_logic;
        signal   data_tx_error_6    : std_logic;
        signal   data_tx_sop_6      : std_logic;
        signal   data_tx_valid_6    : std_logic;
        signal   data_rx_ready_6    : std_logic;
        signal   tx_clk_6           : std_logic;
        signal   rx_clk_6           : std_logic;
        signal   gm_rx_d_6          : std_logic_vector (7 downto 0);
        signal   gm_rx_dv_6         : std_logic;
        signal   gm_rx_err_6        : std_logic;
        signal   m_rx_d_6           : std_logic_vector (3 downto 0);
        signal   m_rx_en_6          : std_logic;
        signal   m_rx_err_6         : std_logic;
        signal   set_10_6           : std_logic;
        signal   set_1000_6         : std_logic;
        signal   xon_gen_6          : std_logic;
        signal   xoff_gen_6         : std_logic;
        signal   magic_sleep_n_6    : std_logic;
        signal   m_rx_col_6         : std_logic;
        signal   m_rx_crs_6         : std_logic;
        signal   tx_crc_fwd_7       : std_logic;
        signal   data_tx_data_7     : std_logic_vector (7 downto 0);
        signal   data_tx_eop_7      : std_logic;
        signal   data_tx_error_7    : std_logic;
        signal   data_tx_sop_7      : std_logic;
        signal   data_tx_valid_7    : std_logic;
        signal   data_rx_ready_7    : std_logic;
        signal   tx_clk_7           : std_logic;
        signal   rx_clk_7           : std_logic;
        signal   gm_rx_d_7          : std_logic_vector (7 downto 0);
        signal   gm_rx_dv_7         : std_logic;
        signal   gm_rx_err_7        : std_logic;
        signal   m_rx_d_7           : std_logic_vector (3 downto 0);
        signal   m_rx_en_7          : std_logic;
        signal   m_rx_err_7         : std_logic;
        signal   set_10_7           : std_logic;
        signal   set_1000_7         : std_logic;
        signal   xon_gen_7          : std_logic;
        signal   xoff_gen_7         : std_logic;
        signal   magic_sleep_n_7    : std_logic;
        signal   m_rx_col_7         : std_logic;
        signal   m_rx_crs_7         : std_logic;
        signal   tx_crc_fwd_8       : std_logic;
        signal   data_tx_data_8     : std_logic_vector (7 downto 0);
        signal   data_tx_eop_8      : std_logic;
        signal   data_tx_error_8    : std_logic;
        signal   data_tx_sop_8      : std_logic;
        signal   data_tx_valid_8    : std_logic;
        signal   data_rx_ready_8    : std_logic;
        signal   tx_clk_8           : std_logic;
        signal   rx_clk_8           : std_logic;
        signal   gm_rx_d_8          : std_logic_vector (7 downto 0);
        signal   gm_rx_dv_8         : std_logic;
        signal   gm_rx_err_8        : std_logic;
        signal   m_rx_d_8           : std_logic_vector (3 downto 0);
        signal   m_rx_en_8          : std_logic;
        signal   m_rx_err_8         : std_logic;
        signal   set_10_8           : std_logic;
        signal   set_1000_8         : std_logic;
        signal   xon_gen_8          : std_logic;
        signal   xoff_gen_8         : std_logic;
        signal   magic_sleep_n_8    : std_logic;
        signal   m_rx_col_8         : std_logic;
        signal   m_rx_crs_8         : std_logic;
        signal   tx_crc_fwd_9       : std_logic;
        signal   data_tx_data_9     : std_logic_vector (7 downto 0);
        signal   data_tx_eop_9      : std_logic;
        signal   data_tx_error_9    : std_logic;
        signal   data_tx_sop_9      : std_logic;
        signal   data_tx_valid_9    : std_logic;
        signal   data_rx_ready_9    : std_logic;
        signal   tx_clk_9           : std_logic;
        signal   rx_clk_9           : std_logic;
        signal   gm_rx_d_9          : std_logic_vector (7 downto 0);
        signal   gm_rx_dv_9         : std_logic;
        signal   gm_rx_err_9        : std_logic;
        signal   m_rx_d_9           : std_logic_vector (3 downto 0);
        signal   m_rx_en_9          : std_logic;
        signal   m_rx_err_9         : std_logic;
        signal   set_10_9           : std_logic;
        signal   set_1000_9         : std_logic;
        signal   xon_gen_9          : std_logic;
        signal   xoff_gen_9         : std_logic;
        signal   magic_sleep_n_9    : std_logic;
        signal   m_rx_col_9         : std_logic;
        signal   m_rx_crs_9         : std_logic;
        signal   tx_crc_fwd_10      : std_logic;
        signal   data_tx_data_10    : std_logic_vector (7 downto 0);
        signal   data_tx_eop_10     : std_logic;
        signal   data_tx_error_10   : std_logic;
        signal   data_tx_sop_10     : std_logic;
        signal   data_tx_valid_10   : std_logic;
        signal   data_rx_ready_10   : std_logic;
        signal   tx_clk_10          : std_logic;
        signal   rx_clk_10          : std_logic;
        signal   gm_rx_d_10         : std_logic_vector (7 downto 0);
        signal   gm_rx_dv_10        : std_logic;
        signal   gm_rx_err_10       : std_logic;
        signal   m_rx_d_10          : std_logic_vector (3 downto 0);
        signal   m_rx_en_10         : std_logic;
        signal   m_rx_err_10        : std_logic;
        signal   set_10_10          : std_logic;
        signal   set_1000_10        : std_logic;
        signal   xon_gen_10         : std_logic;
        signal   xoff_gen_10        : std_logic;
        signal   magic_sleep_n_10   : std_logic;
        signal   m_rx_col_10        : std_logic;
        signal   m_rx_crs_10        : std_logic;
        signal   tx_crc_fwd_11      : std_logic;
        signal   data_tx_data_11    : std_logic_vector (7 downto 0);
        signal   data_tx_eop_11     : std_logic;
        signal   data_tx_error_11   : std_logic;
        signal   data_tx_sop_11     : std_logic;
        signal   data_tx_valid_11   : std_logic;
        signal   data_rx_ready_11   : std_logic;
        signal   tx_clk_11          : std_logic;
        signal   rx_clk_11          : std_logic;
        signal   gm_rx_d_11         : std_logic_vector (7 downto 0);
        signal   gm_rx_dv_11        : std_logic;
        signal   gm_rx_err_11       : std_logic;
        signal   m_rx_d_11          : std_logic_vector (3 downto 0);
        signal   m_rx_en_11         : std_logic;
        signal   m_rx_err_11        : std_logic;
        signal   set_10_11          : std_logic;
        signal   set_1000_11        : std_logic;
        signal   xon_gen_11         : std_logic;
        signal   xoff_gen_11        : std_logic;
        signal   magic_sleep_n_11   : std_logic;
        signal   m_rx_col_11        : std_logic;
        signal   m_rx_crs_11        : std_logic;
        signal   tx_crc_fwd_12      : std_logic;
        signal   data_tx_data_12    : std_logic_vector (7 downto 0);
        signal   data_tx_eop_12     : std_logic;
        signal   data_tx_error_12   : std_logic;
        signal   data_tx_sop_12     : std_logic;
        signal   data_tx_valid_12   : std_logic;
        signal   data_rx_ready_12   : std_logic;
        signal   tx_clk_12          : std_logic;
        signal   rx_clk_12          : std_logic;
        signal   gm_rx_d_12         : std_logic_vector (7 downto 0);
        signal   gm_rx_dv_12        : std_logic;
        signal   gm_rx_err_12       : std_logic;
        signal   m_rx_d_12          : std_logic_vector (3 downto 0);
        signal   m_rx_en_12         : std_logic;
        signal   m_rx_err_12        : std_logic;
        signal   set_10_12          : std_logic;
        signal   set_1000_12        : std_logic;
        signal   xon_gen_12         : std_logic;
        signal   xoff_gen_12        : std_logic;
        signal   magic_sleep_n_12   : std_logic;
        signal   m_rx_col_12        : std_logic;
        signal   m_rx_crs_12        : std_logic;
        signal   tx_crc_fwd_13      : std_logic;
        signal   data_tx_data_13    : std_logic_vector (7 downto 0);
        signal   data_tx_eop_13     : std_logic;
        signal   data_tx_error_13   : std_logic;
        signal   data_tx_sop_13     : std_logic;
        signal   data_tx_valid_13   : std_logic;
        signal   data_rx_ready_13   : std_logic;
        signal   tx_clk_13          : std_logic;
        signal   rx_clk_13          : std_logic;
        signal   gm_rx_d_13         : std_logic_vector (7 downto 0);
        signal   gm_rx_dv_13        : std_logic;
        signal   gm_rx_err_13       : std_logic;
        signal   m_rx_d_13          : std_logic_vector (3 downto 0);
        signal   m_rx_en_13         : std_logic;
        signal   m_rx_err_13        : std_logic;
        signal   set_10_13          : std_logic;
        signal   set_1000_13        : std_logic;
        signal   xon_gen_13         : std_logic;
        signal   xoff_gen_13        : std_logic;
        signal   magic_sleep_n_13   : std_logic;
        signal   m_rx_col_13        : std_logic;
        signal   m_rx_crs_13        : std_logic;
        signal   tx_crc_fwd_14      : std_logic;
        signal   data_tx_data_14    : std_logic_vector (7 downto 0);
        signal   data_tx_eop_14     : std_logic;
        signal   data_tx_error_14   : std_logic;
        signal   data_tx_sop_14     : std_logic;
        signal   data_tx_valid_14   : std_logic;
        signal   data_rx_ready_14   : std_logic;
        signal   tx_clk_14          : std_logic;
        signal   rx_clk_14          : std_logic;
        signal   gm_rx_d_14         : std_logic_vector (7 downto 0);
        signal   gm_rx_dv_14        : std_logic;
        signal   gm_rx_err_14       : std_logic;
        signal   m_rx_d_14          : std_logic_vector (3 downto 0);
        signal   m_rx_en_14         : std_logic;
        signal   m_rx_err_14        : std_logic;
        signal   set_10_14          : std_logic;
        signal   set_1000_14        : std_logic;
        signal   xon_gen_14         : std_logic;
        signal   xoff_gen_14        : std_logic;
        signal   magic_sleep_n_14   : std_logic;
        signal   m_rx_col_14        : std_logic;
        signal   m_rx_crs_14        : std_logic;
        signal   tx_crc_fwd_15      : std_logic;
        signal   data_tx_data_15    : std_logic_vector (7 downto 0);
        signal   data_tx_eop_15     : std_logic;
        signal   data_tx_error_15   : std_logic;
        signal   data_tx_sop_15     : std_logic;
        signal   data_tx_valid_15   : std_logic;
        signal   data_rx_ready_15   : std_logic;
        signal   tx_clk_15          : std_logic;
        signal   rx_clk_15          : std_logic;
        signal   gm_rx_d_15         : std_logic_vector (7 downto 0);
        signal   gm_rx_dv_15        : std_logic;
        signal   gm_rx_err_15       : std_logic;
        signal   m_rx_d_15          : std_logic_vector (3 downto 0);
        signal   m_rx_en_15         : std_logic;
        signal   m_rx_err_15        : std_logic;
        signal   set_10_15          : std_logic;
        signal   set_1000_15        : std_logic;
        signal   xon_gen_15         : std_logic;
        signal   xoff_gen_15        : std_logic;
        signal   magic_sleep_n_15   : std_logic;
        signal   m_rx_col_15        : std_logic;
        signal   m_rx_crs_15        : std_logic;
        signal   tx_crc_fwd_16      : std_logic;
        signal   data_tx_data_16    : std_logic_vector (7 downto 0);
        signal   data_tx_eop_16     : std_logic;
        signal   data_tx_error_16   : std_logic;
        signal   data_tx_sop_16     : std_logic;
        signal   data_tx_valid_16   : std_logic;
        signal   data_rx_ready_16   : std_logic;
        signal   tx_clk_16          : std_logic;
        signal   rx_clk_16          : std_logic;
        signal   gm_rx_d_16         : std_logic_vector (7 downto 0);
        signal   gm_rx_dv_16        : std_logic;
        signal   gm_rx_err_16       : std_logic;
        signal   m_rx_d_16          : std_logic_vector (3 downto 0);
        signal   m_rx_en_16         : std_logic;
        signal   m_rx_err_16        : std_logic;
        signal   set_10_16          : std_logic;
        signal   set_1000_16        : std_logic;
        signal   xon_gen_16         : std_logic;
        signal   xoff_gen_16        : std_logic;
        signal   magic_sleep_n_16   : std_logic;
        signal   m_rx_col_16        : std_logic;
        signal   m_rx_crs_16        : std_logic;
        signal   tx_crc_fwd_17      : std_logic;
        signal   data_tx_data_17    : std_logic_vector (7 downto 0);
        signal   data_tx_eop_17     : std_logic;
        signal   data_tx_error_17   : std_logic;
        signal   data_tx_sop_17     : std_logic;
        signal   data_tx_valid_17   : std_logic;
        signal   data_rx_ready_17   : std_logic;
        signal   tx_clk_17          : std_logic;
        signal   rx_clk_17          : std_logic;
        signal   gm_rx_d_17         : std_logic_vector (7 downto 0);
        signal   gm_rx_dv_17        : std_logic;
        signal   gm_rx_err_17       : std_logic;
        signal   m_rx_d_17          : std_logic_vector (3 downto 0);
        signal   m_rx_en_17         : std_logic;
        signal   m_rx_err_17        : std_logic;
        signal   set_10_17          : std_logic;
        signal   set_1000_17        : std_logic;
        signal   xon_gen_17         : std_logic;
        signal   xoff_gen_17        : std_logic;
        signal   magic_sleep_n_17   : std_logic;
        signal   m_rx_col_17        : std_logic;
        signal   m_rx_crs_17        : std_logic;
        signal   tx_crc_fwd_18      : std_logic;
        signal   data_tx_data_18    : std_logic_vector (7 downto 0);
        signal   data_tx_eop_18     : std_logic;
        signal   data_tx_error_18   : std_logic;
        signal   data_tx_sop_18     : std_logic;
        signal   data_tx_valid_18   : std_logic;
        signal   data_rx_ready_18   : std_logic;
        signal   tx_clk_18          : std_logic;
        signal   rx_clk_18          : std_logic;
        signal   gm_rx_d_18         : std_logic_vector (7 downto 0);
        signal   gm_rx_dv_18        : std_logic;
        signal   gm_rx_err_18       : std_logic;
        signal   m_rx_d_18          : std_logic_vector (3 downto 0);
        signal   m_rx_en_18         : std_logic;
        signal   m_rx_err_18        : std_logic;
        signal   set_10_18          : std_logic;
        signal   set_1000_18        : std_logic;
        signal   xon_gen_18         : std_logic;
        signal   xoff_gen_18        : std_logic;
        signal   magic_sleep_n_18   : std_logic;
        signal   m_rx_col_18        : std_logic;
        signal   m_rx_crs_18        : std_logic;
        signal   tx_crc_fwd_19      : std_logic;
        signal   data_tx_data_19    : std_logic_vector (7 downto 0);
        signal   data_tx_eop_19     : std_logic;
        signal   data_tx_error_19   : std_logic;
        signal   data_tx_sop_19     : std_logic;
        signal   data_tx_valid_19   : std_logic;
        signal   data_rx_ready_19   : std_logic;
        signal   tx_clk_19          : std_logic;
        signal   rx_clk_19          : std_logic;
        signal   gm_rx_d_19         : std_logic_vector (7 downto 0);
        signal   gm_rx_dv_19        : std_logic;
        signal   gm_rx_err_19       : std_logic;
        signal   m_rx_d_19          : std_logic_vector (3 downto 0);
        signal   m_rx_en_19         : std_logic;
        signal   m_rx_err_19        : std_logic;
        signal   set_10_19          : std_logic;
        signal   set_1000_19        : std_logic;
        signal   xon_gen_19         : std_logic;
        signal   xoff_gen_19        : std_logic;
        signal   magic_sleep_n_19   : std_logic;
        signal   m_rx_col_19        : std_logic;
        signal   m_rx_crs_19        : std_logic;
        signal   tx_crc_fwd_20      : std_logic;
        signal   data_tx_data_20    : std_logic_vector (7 downto 0);
        signal   data_tx_eop_20     : std_logic;
        signal   data_tx_error_20   : std_logic;
        signal   data_tx_sop_20     : std_logic;
        signal   data_tx_valid_20   : std_logic;
        signal   data_rx_ready_20   : std_logic;
        signal   tx_clk_20          : std_logic;
        signal   rx_clk_20          : std_logic;
        signal   gm_rx_d_20         : std_logic_vector (7 downto 0);
        signal   gm_rx_dv_20        : std_logic;
        signal   gm_rx_err_20       : std_logic;
        signal   m_rx_d_20          : std_logic_vector (3 downto 0);
        signal   m_rx_en_20         : std_logic;
        signal   m_rx_err_20        : std_logic;
        signal   set_10_20          : std_logic;
        signal   set_1000_20        : std_logic;
        signal   xon_gen_20         : std_logic;
        signal   xoff_gen_20        : std_logic;
        signal   magic_sleep_n_20   : std_logic;
        signal   m_rx_col_20        : std_logic;
        signal   m_rx_crs_20        : std_logic;
        signal   tx_crc_fwd_21      : std_logic;
        signal   data_tx_data_21    : std_logic_vector (7 downto 0);
        signal   data_tx_eop_21     : std_logic;
        signal   data_tx_error_21   : std_logic;
        signal   data_tx_sop_21     : std_logic;
        signal   data_tx_valid_21   : std_logic;
        signal   data_rx_ready_21   : std_logic;
        signal   tx_clk_21          : std_logic;
        signal   rx_clk_21          : std_logic;
        signal   gm_rx_d_21         : std_logic_vector (7 downto 0);
        signal   gm_rx_dv_21        : std_logic;
        signal   gm_rx_err_21       : std_logic;
        signal   m_rx_d_21          : std_logic_vector (3 downto 0);
        signal   m_rx_en_21         : std_logic;
        signal   m_rx_err_21        : std_logic;
        signal   set_10_21          : std_logic;
        signal   set_1000_21        : std_logic;
        signal   xon_gen_21         : std_logic;
        signal   xoff_gen_21        : std_logic;
        signal   magic_sleep_n_21   : std_logic;
        signal   m_rx_col_21        : std_logic;
        signal   m_rx_crs_21        : std_logic;
        signal   tx_crc_fwd_22      : std_logic;
        signal   data_tx_data_22    : std_logic_vector (7 downto 0);
        signal   data_tx_eop_22     : std_logic;
        signal   data_tx_error_22   : std_logic;
        signal   data_tx_sop_22     : std_logic;
        signal   data_tx_valid_22   : std_logic;
        signal   data_rx_ready_22   : std_logic;
        signal   tx_clk_22          : std_logic;
        signal   rx_clk_22          : std_logic;
        signal   gm_rx_d_22         : std_logic_vector (7 downto 0);
        signal   gm_rx_dv_22        : std_logic;
        signal   gm_rx_err_22       : std_logic;
        signal   m_rx_d_22          : std_logic_vector (3 downto 0);
        signal   m_rx_en_22         : std_logic;
        signal   m_rx_err_22        : std_logic;
        signal   set_10_22          : std_logic;
        signal   set_1000_22        : std_logic;
        signal   xon_gen_22         : std_logic;
        signal   xoff_gen_22        : std_logic;
        signal   magic_sleep_n_22   : std_logic;
        signal   m_rx_col_22        : std_logic;
        signal   m_rx_crs_22        : std_logic;
        signal   tx_crc_fwd_23      : std_logic;
        signal   data_tx_data_23    : std_logic_vector (7 downto 0);
        signal   data_tx_eop_23     : std_logic;
        signal   data_tx_error_23   : std_logic;
        signal   data_tx_sop_23     : std_logic;
        signal   data_tx_valid_23   : std_logic;
        signal   data_rx_ready_23   : std_logic;
        signal   tx_clk_23          : std_logic;
        signal   rx_clk_23          : std_logic;
        signal   gm_rx_d_23         : std_logic_vector (7 downto 0);
        signal   gm_rx_dv_23        : std_logic;
        signal   gm_rx_err_23       : std_logic;
        signal   m_rx_d_23          : std_logic_vector (3 downto 0);
        signal   m_rx_en_23         : std_logic;
        signal   m_rx_err_23        : std_logic;
        signal   set_10_23          : std_logic;
        signal   set_1000_23        : std_logic;
        signal   xon_gen_23         : std_logic;
        signal   xoff_gen_23        : std_logic;
        signal   magic_sleep_n_23   : std_logic;
        signal   m_rx_col_23        : std_logic;
        signal   m_rx_crs_23        : std_logic;
        signal   readdata           : std_logic_vector (31 downto 0);
        signal   waitrequest        : std_logic;
        signal   mac_tx_clk_0       : std_logic;
        signal   mac_rx_clk_0       : std_logic;
        signal   data_tx_ready_0    : std_logic;
        signal   data_rx_data_0     : std_logic_vector (7 downto 0);
        signal   data_rx_valid_0    : std_logic;
        signal   data_rx_eop_0      : std_logic;
        signal   data_rx_sop_0      : std_logic;
        signal   data_rx_error_0    : std_logic_vector (4 downto 0);
        signal   pkt_class_data_0   : std_logic_vector (4 downto 0);
        signal   pkt_class_valid_0  : std_logic;
        signal   gm_tx_d_0          : std_logic_vector (7 downto 0);
        signal   gm_tx_en_0         : std_logic;
        signal   gm_tx_err_0        : std_logic;
        signal   m_tx_d_0           : std_logic_vector (3 downto 0);
        signal   m_tx_en_0          : std_logic;
        signal   m_tx_err_0         : std_logic;
        signal   ena_10_0           : std_logic;
        signal   eth_mode_0         : std_logic;
        signal   magic_wakeup_0     : std_logic;
        signal   mac_tx_clk_1       : std_logic;
        signal   mac_rx_clk_1       : std_logic;
        signal   data_tx_ready_1    : std_logic;
        signal   data_rx_data_1     : std_logic_vector (7 downto 0);
        signal   data_rx_valid_1    : std_logic;
        signal   data_rx_eop_1      : std_logic;
        signal   data_rx_sop_1      : std_logic;
        signal   data_rx_error_1    : std_logic_vector (4 downto 0);
        signal   pkt_class_data_1   : std_logic_vector (4 downto 0);
        signal   pkt_class_valid_1  : std_logic;
        signal   gm_tx_d_1          : std_logic_vector (7 downto 0);
        signal   gm_tx_en_1         : std_logic;
        signal   gm_tx_err_1        : std_logic;
        signal   m_tx_d_1           : std_logic_vector (3 downto 0);
        signal   m_tx_en_1          : std_logic;
        signal   m_tx_err_1         : std_logic;
        signal   ena_10_1           : std_logic;
        signal   eth_mode_1         : std_logic;
        signal   magic_wakeup_1     : std_logic;
        signal   mac_tx_clk_2       : std_logic;
        signal   mac_rx_clk_2       : std_logic;
        signal   data_tx_ready_2    : std_logic;
        signal   data_rx_data_2     : std_logic_vector (7 downto 0);
        signal   data_rx_valid_2    : std_logic;
        signal   data_rx_eop_2      : std_logic;
        signal   data_rx_sop_2      : std_logic;
        signal   data_rx_error_2    : std_logic_vector (4 downto 0);
        signal   pkt_class_data_2   : std_logic_vector (4 downto 0);
        signal   pkt_class_valid_2  : std_logic;
        signal   gm_tx_d_2          : std_logic_vector (7 downto 0);
        signal   gm_tx_en_2         : std_logic;
        signal   gm_tx_err_2        : std_logic;
        signal   m_tx_d_2           : std_logic_vector (3 downto 0);
        signal   m_tx_en_2          : std_logic;
        signal   m_tx_err_2         : std_logic;
        signal   ena_10_2           : std_logic;
        signal   eth_mode_2         : std_logic;
        signal   magic_wakeup_2     : std_logic;
        signal   mac_tx_clk_3       : std_logic;
        signal   mac_rx_clk_3       : std_logic;
        signal   data_tx_ready_3    : std_logic;
        signal   data_rx_data_3     : std_logic_vector (7 downto 0);
        signal   data_rx_valid_3    : std_logic;
        signal   data_rx_eop_3      : std_logic;
        signal   data_rx_sop_3      : std_logic;
        signal   data_rx_error_3    : std_logic_vector (4 downto 0);
        signal   pkt_class_data_3   : std_logic_vector (4 downto 0);
        signal   pkt_class_valid_3  : std_logic;
        signal   gm_tx_d_3          : std_logic_vector (7 downto 0);
        signal   gm_tx_en_3         : std_logic;
        signal   gm_tx_err_3        : std_logic;
        signal   m_tx_d_3           : std_logic_vector (3 downto 0);
        signal   m_tx_en_3          : std_logic;
        signal   m_tx_err_3         : std_logic;
        signal   ena_10_3           : std_logic;
        signal   eth_mode_3         : std_logic;
        signal   magic_wakeup_3     : std_logic;
        signal   mac_tx_clk_4       : std_logic;
        signal   mac_rx_clk_4       : std_logic;
        signal   data_tx_ready_4    : std_logic;
        signal   data_rx_data_4     : std_logic_vector (7 downto 0);
        signal   data_rx_valid_4    : std_logic;
        signal   data_rx_eop_4      : std_logic;
        signal   data_rx_sop_4      : std_logic;
        signal   data_rx_error_4    : std_logic_vector (4 downto 0);
        signal   pkt_class_data_4   : std_logic_vector (4 downto 0);
        signal   pkt_class_valid_4  : std_logic;
        signal   gm_tx_d_4          : std_logic_vector (7 downto 0);
        signal   gm_tx_en_4         : std_logic;
        signal   gm_tx_err_4        : std_logic;
        signal   m_tx_d_4           : std_logic_vector (3 downto 0);
        signal   m_tx_en_4          : std_logic;
        signal   m_tx_err_4         : std_logic;
        signal   ena_10_4           : std_logic;
        signal   eth_mode_4         : std_logic;
        signal   magic_wakeup_4     : std_logic;
        signal   mac_tx_clk_5       : std_logic;
        signal   mac_rx_clk_5       : std_logic;
        signal   data_tx_ready_5    : std_logic;
        signal   data_rx_data_5     : std_logic_vector (7 downto 0);
        signal   data_rx_valid_5    : std_logic;
        signal   data_rx_eop_5      : std_logic;
        signal   data_rx_sop_5      : std_logic;
        signal   data_rx_error_5    : std_logic_vector (4 downto 0);
        signal   pkt_class_data_5   : std_logic_vector (4 downto 0);
        signal   pkt_class_valid_5  : std_logic;
        signal   gm_tx_d_5          : std_logic_vector (7 downto 0);
        signal   gm_tx_en_5         : std_logic;
        signal   gm_tx_err_5        : std_logic;
        signal   m_tx_d_5           : std_logic_vector (3 downto 0);
        signal   m_tx_en_5          : std_logic;
        signal   m_tx_err_5         : std_logic;
        signal   ena_10_5           : std_logic;
        signal   eth_mode_5         : std_logic;
        signal   magic_wakeup_5     : std_logic;
        signal   mac_tx_clk_6       : std_logic;
        signal   mac_rx_clk_6       : std_logic;
        signal   data_tx_ready_6    : std_logic;
        signal   data_rx_data_6     : std_logic_vector (7 downto 0);
        signal   data_rx_valid_6    : std_logic;
        signal   data_rx_eop_6      : std_logic;
        signal   data_rx_sop_6      : std_logic;
        signal   data_rx_error_6    : std_logic_vector (4 downto 0);
        signal   pkt_class_data_6   : std_logic_vector (4 downto 0);
        signal   pkt_class_valid_6  : std_logic;
        signal   gm_tx_d_6          : std_logic_vector (7 downto 0);
        signal   gm_tx_en_6         : std_logic;
        signal   gm_tx_err_6        : std_logic;
        signal   m_tx_d_6           : std_logic_vector (3 downto 0);
        signal   m_tx_en_6          : std_logic;
        signal   m_tx_err_6         : std_logic;
        signal   ena_10_6           : std_logic;
        signal   eth_mode_6         : std_logic;
        signal   magic_wakeup_6     : std_logic;
        signal   mac_tx_clk_7       : std_logic;
        signal   mac_rx_clk_7       : std_logic;
        signal   data_tx_ready_7    : std_logic;
        signal   data_rx_data_7     : std_logic_vector (7 downto 0);
        signal   data_rx_valid_7    : std_logic;
        signal   data_rx_eop_7      : std_logic;
        signal   data_rx_sop_7      : std_logic;
        signal   data_rx_error_7    : std_logic_vector (4 downto 0);
        signal   pkt_class_data_7   : std_logic_vector (4 downto 0);
        signal   pkt_class_valid_7  : std_logic;
        signal   gm_tx_d_7          : std_logic_vector (7 downto 0);
        signal   gm_tx_en_7         : std_logic;
        signal   gm_tx_err_7        : std_logic;
        signal   m_tx_d_7           : std_logic_vector (3 downto 0);
        signal   m_tx_en_7          : std_logic;
        signal   m_tx_err_7         : std_logic;
        signal   ena_10_7           : std_logic;
        signal   eth_mode_7         : std_logic;
        signal   magic_wakeup_7     : std_logic;
        signal   mac_tx_clk_8       : std_logic;
        signal   mac_rx_clk_8       : std_logic;
        signal   data_tx_ready_8    : std_logic;
        signal   data_rx_data_8     : std_logic_vector (7 downto 0);
        signal   data_rx_valid_8    : std_logic;
        signal   data_rx_eop_8      : std_logic;
        signal   data_rx_sop_8      : std_logic;
        signal   data_rx_error_8    : std_logic_vector (4 downto 0);
        signal   pkt_class_data_8   : std_logic_vector (4 downto 0);
        signal   pkt_class_valid_8  : std_logic;
        signal   gm_tx_d_8          : std_logic_vector (7 downto 0);
        signal   gm_tx_en_8         : std_logic;
        signal   gm_tx_err_8        : std_logic;
        signal   m_tx_d_8           : std_logic_vector (3 downto 0);
        signal   m_tx_en_8          : std_logic;
        signal   m_tx_err_8         : std_logic;
        signal   ena_10_8           : std_logic;
        signal   eth_mode_8         : std_logic;
        signal   magic_wakeup_8     : std_logic;
        signal   mac_tx_clk_9       : std_logic;
        signal   mac_rx_clk_9       : std_logic;
        signal   data_tx_ready_9    : std_logic;
        signal   data_rx_data_9     : std_logic_vector (7 downto 0);
        signal   data_rx_valid_9    : std_logic;
        signal   data_rx_eop_9      : std_logic;
        signal   data_rx_sop_9      : std_logic;
        signal   data_rx_error_9    : std_logic_vector (4 downto 0);
        signal   pkt_class_data_9   : std_logic_vector (4 downto 0);
        signal   pkt_class_valid_9  : std_logic;
        signal   gm_tx_d_9          : std_logic_vector (7 downto 0);
        signal   gm_tx_en_9         : std_logic;
        signal   gm_tx_err_9        : std_logic;
        signal   m_tx_d_9           : std_logic_vector (3 downto 0);
        signal   m_tx_en_9          : std_logic;
        signal   m_tx_err_9         : std_logic;
        signal   ena_10_9           : std_logic;
        signal   eth_mode_9         : std_logic;
        signal   magic_wakeup_9     : std_logic;
        signal   mac_tx_clk_10      : std_logic;
        signal   mac_rx_clk_10      : std_logic;
        signal   data_tx_ready_10   : std_logic;
        signal   data_rx_data_10    : std_logic_vector (7 downto 0);
        signal   data_rx_valid_10   : std_logic;
        signal   data_rx_eop_10     : std_logic;
        signal   data_rx_sop_10     : std_logic;
        signal   data_rx_error_10   : std_logic_vector (4 downto 0);
        signal   pkt_class_data_10  : std_logic_vector (4 downto 0);
        signal   pkt_class_valid_10 : std_logic;
        signal   gm_tx_d_10         : std_logic_vector (7 downto 0);
        signal   gm_tx_en_10        : std_logic;
        signal   gm_tx_err_10       : std_logic;
        signal   m_tx_d_10          : std_logic_vector (3 downto 0);
        signal   m_tx_en_10         : std_logic;
        signal   m_tx_err_10        : std_logic;
        signal   ena_10_10          : std_logic;
        signal   eth_mode_10        : std_logic;
        signal   magic_wakeup_10    : std_logic;
        signal   mac_tx_clk_11      : std_logic;
        signal   mac_rx_clk_11      : std_logic;
        signal   data_tx_ready_11   : std_logic;
        signal   data_rx_data_11    : std_logic_vector (7 downto 0);
        signal   data_rx_valid_11   : std_logic;
        signal   data_rx_eop_11     : std_logic;
        signal   data_rx_sop_11     : std_logic;
        signal   data_rx_error_11   : std_logic_vector (4 downto 0);
        signal   pkt_class_data_11  : std_logic_vector (4 downto 0);
        signal   pkt_class_valid_11 : std_logic;
        signal   gm_tx_d_11         : std_logic_vector (7 downto 0);
        signal   gm_tx_en_11        : std_logic;
        signal   gm_tx_err_11       : std_logic;
        signal   m_tx_d_11          : std_logic_vector (3 downto 0);
        signal   m_tx_en_11         : std_logic;
        signal   m_tx_err_11        : std_logic;
        signal   ena_10_11          : std_logic;
        signal   eth_mode_11        : std_logic;
        signal   magic_wakeup_11    : std_logic;
        signal   mac_tx_clk_12      : std_logic;
        signal   mac_rx_clk_12      : std_logic;
        signal   data_tx_ready_12   : std_logic;
        signal   data_rx_data_12    : std_logic_vector (7 downto 0);
        signal   data_rx_valid_12   : std_logic;
        signal   data_rx_eop_12     : std_logic;
        signal   data_rx_sop_12     : std_logic;
        signal   data_rx_error_12   : std_logic_vector (4 downto 0);
        signal   pkt_class_data_12  : std_logic_vector (4 downto 0);
        signal   pkt_class_valid_12 : std_logic;
        signal   gm_tx_d_12         : std_logic_vector (7 downto 0);
        signal   gm_tx_en_12        : std_logic;
        signal   gm_tx_err_12       : std_logic;
        signal   m_tx_d_12          : std_logic_vector (3 downto 0);
        signal   m_tx_en_12         : std_logic;
        signal   m_tx_err_12        : std_logic;
        signal   ena_10_12          : std_logic;
        signal   eth_mode_12        : std_logic;
        signal   magic_wakeup_12    : std_logic;
        signal   mac_tx_clk_13      : std_logic;
        signal   mac_rx_clk_13      : std_logic;
        signal   data_tx_ready_13   : std_logic;
        signal   data_rx_data_13    : std_logic_vector (7 downto 0);
        signal   data_rx_valid_13   : std_logic;
        signal   data_rx_eop_13     : std_logic;
        signal   data_rx_sop_13     : std_logic;
        signal   data_rx_error_13   : std_logic_vector (4 downto 0);
        signal   pkt_class_data_13  : std_logic_vector (4 downto 0);
        signal   pkt_class_valid_13 : std_logic;
        signal   gm_tx_d_13         : std_logic_vector (7 downto 0);
        signal   gm_tx_en_13        : std_logic;
        signal   gm_tx_err_13       : std_logic;
        signal   m_tx_d_13          : std_logic_vector (3 downto 0);
        signal   m_tx_en_13         : std_logic;
        signal   m_tx_err_13        : std_logic;
        signal   ena_10_13          : std_logic;
        signal   eth_mode_13        : std_logic;
        signal   magic_wakeup_13    : std_logic;
        signal   mac_tx_clk_14      : std_logic;
        signal   mac_rx_clk_14      : std_logic;
        signal   data_tx_ready_14   : std_logic;
        signal   data_rx_data_14    : std_logic_vector (7 downto 0);
        signal   data_rx_valid_14   : std_logic;
        signal   data_rx_eop_14     : std_logic;
        signal   data_rx_sop_14     : std_logic;
        signal   data_rx_error_14   : std_logic_vector (4 downto 0);
        signal   pkt_class_data_14  : std_logic_vector (4 downto 0);
        signal   pkt_class_valid_14 : std_logic;
        signal   gm_tx_d_14         : std_logic_vector (7 downto 0);
        signal   gm_tx_en_14        : std_logic;
        signal   gm_tx_err_14       : std_logic;
        signal   m_tx_d_14          : std_logic_vector (3 downto 0);
        signal   m_tx_en_14         : std_logic;
        signal   m_tx_err_14        : std_logic;
        signal   ena_10_14          : std_logic;
        signal   eth_mode_14        : std_logic;
        signal   magic_wakeup_14    : std_logic;
        signal   mac_tx_clk_15      : std_logic;
        signal   mac_rx_clk_15      : std_logic;
        signal   data_tx_ready_15   : std_logic;
        signal   data_rx_data_15    : std_logic_vector (7 downto 0);
        signal   data_rx_valid_15   : std_logic;
        signal   data_rx_eop_15     : std_logic;
        signal   data_rx_sop_15     : std_logic;
        signal   data_rx_error_15   : std_logic_vector (4 downto 0);
        signal   pkt_class_data_15  : std_logic_vector (4 downto 0);
        signal   pkt_class_valid_15 : std_logic;
        signal   gm_tx_d_15         : std_logic_vector (7 downto 0);
        signal   gm_tx_en_15        : std_logic;
        signal   gm_tx_err_15       : std_logic;
        signal   m_tx_d_15          : std_logic_vector (3 downto 0);
        signal   m_tx_en_15         : std_logic;
        signal   m_tx_err_15        : std_logic;
        signal   ena_10_15          : std_logic;
        signal   eth_mode_15        : std_logic;
        signal   magic_wakeup_15    : std_logic;
        signal   mac_tx_clk_16      : std_logic;
        signal   mac_rx_clk_16      : std_logic;
        signal   data_tx_ready_16   : std_logic;
        signal   data_rx_data_16    : std_logic_vector (7 downto 0);
        signal   data_rx_valid_16   : std_logic;
        signal   data_rx_eop_16     : std_logic;
        signal   data_rx_sop_16     : std_logic;
        signal   data_rx_error_16   : std_logic_vector (4 downto 0);
        signal   pkt_class_data_16  : std_logic_vector (4 downto 0);
        signal   pkt_class_valid_16 : std_logic;
        signal   gm_tx_d_16         : std_logic_vector (7 downto 0);
        signal   gm_tx_en_16        : std_logic;
        signal   gm_tx_err_16       : std_logic;
        signal   m_tx_d_16          : std_logic_vector (3 downto 0);
        signal   m_tx_en_16         : std_logic;
        signal   m_tx_err_16        : std_logic;
        signal   ena_10_16          : std_logic;
        signal   eth_mode_16        : std_logic;
        signal   magic_wakeup_16    : std_logic;
        signal   mac_tx_clk_17      : std_logic;
        signal   mac_rx_clk_17      : std_logic;
        signal   data_tx_ready_17   : std_logic;
        signal   data_rx_data_17    : std_logic_vector (7 downto 0);
        signal   data_rx_valid_17   : std_logic;
        signal   data_rx_eop_17     : std_logic;
        signal   data_rx_sop_17     : std_logic;
        signal   data_rx_error_17   : std_logic_vector (4 downto 0);
        signal   pkt_class_data_17  : std_logic_vector (4 downto 0);
        signal   pkt_class_valid_17 : std_logic;
        signal   gm_tx_d_17         : std_logic_vector (7 downto 0);
        signal   gm_tx_en_17        : std_logic;
        signal   gm_tx_err_17       : std_logic;
        signal   m_tx_d_17          : std_logic_vector (3 downto 0);
        signal   m_tx_en_17         : std_logic;
        signal   m_tx_err_17        : std_logic;
        signal   ena_10_17          : std_logic;
        signal   eth_mode_17        : std_logic;
        signal   magic_wakeup_17    : std_logic;
        signal   mac_tx_clk_18      : std_logic;
        signal   mac_rx_clk_18      : std_logic;
        signal   data_tx_ready_18   : std_logic;
        signal   data_rx_data_18    : std_logic_vector (7 downto 0);
        signal   data_rx_valid_18   : std_logic;
        signal   data_rx_eop_18     : std_logic;
        signal   data_rx_sop_18     : std_logic;
        signal   data_rx_error_18   : std_logic_vector (4 downto 0);
        signal   pkt_class_data_18  : std_logic_vector (4 downto 0);
        signal   pkt_class_valid_18 : std_logic;
        signal   gm_tx_d_18         : std_logic_vector (7 downto 0);
        signal   gm_tx_en_18        : std_logic;
        signal   gm_tx_err_18       : std_logic;
        signal   m_tx_d_18          : std_logic_vector (3 downto 0);
        signal   m_tx_en_18         : std_logic;
        signal   m_tx_err_18        : std_logic;
        signal   ena_10_18          : std_logic;
        signal   eth_mode_18        : std_logic;
        signal   magic_wakeup_18    : std_logic;
        signal   mac_tx_clk_19      : std_logic;
        signal   mac_rx_clk_19      : std_logic;
        signal   data_tx_ready_19   : std_logic;
        signal   data_rx_data_19    : std_logic_vector (7 downto 0);
        signal   data_rx_valid_19   : std_logic;
        signal   data_rx_eop_19     : std_logic;
        signal   data_rx_sop_19     : std_logic;
        signal   data_rx_error_19   : std_logic_vector (4 downto 0);
        signal   pkt_class_data_19  : std_logic_vector (4 downto 0);
        signal   pkt_class_valid_19 : std_logic;
        signal   gm_tx_d_19         : std_logic_vector (7 downto 0);
        signal   gm_tx_en_19        : std_logic;
        signal   gm_tx_err_19       : std_logic;
        signal   m_tx_d_19          : std_logic_vector (3 downto 0);
        signal   m_tx_en_19         : std_logic;
        signal   m_tx_err_19        : std_logic;
        signal   ena_10_19          : std_logic;
        signal   eth_mode_19        : std_logic;
        signal   magic_wakeup_19    : std_logic;
        signal   mac_tx_clk_20      : std_logic;
        signal   mac_rx_clk_20      : std_logic;
        signal   data_tx_ready_20   : std_logic;
        signal   data_rx_data_20    : std_logic_vector (7 downto 0);
        signal   data_rx_valid_20   : std_logic;
        signal   data_rx_eop_20     : std_logic;
        signal   data_rx_sop_20     : std_logic;
        signal   data_rx_error_20   : std_logic_vector (4 downto 0);
        signal   pkt_class_data_20  : std_logic_vector (4 downto 0);
        signal   pkt_class_valid_20 : std_logic;
        signal   gm_tx_d_20         : std_logic_vector (7 downto 0);
        signal   gm_tx_en_20        : std_logic;
        signal   gm_tx_err_20       : std_logic;
        signal   m_tx_d_20          : std_logic_vector (3 downto 0);
        signal   m_tx_en_20         : std_logic;
        signal   m_tx_err_20        : std_logic;
        signal   ena_10_20          : std_logic;
        signal   eth_mode_20        : std_logic;
        signal   magic_wakeup_20    : std_logic;
        signal   mac_tx_clk_21      : std_logic;
        signal   mac_rx_clk_21      : std_logic;
        signal   data_tx_ready_21   : std_logic;
        signal   data_rx_data_21    : std_logic_vector (7 downto 0);
        signal   data_rx_valid_21   : std_logic;
        signal   data_rx_eop_21     : std_logic;
        signal   data_rx_sop_21     : std_logic;
        signal   data_rx_error_21   : std_logic_vector (4 downto 0);
        signal   pkt_class_data_21  : std_logic_vector (4 downto 0);
        signal   pkt_class_valid_21 : std_logic;
        signal   gm_tx_d_21         : std_logic_vector (7 downto 0);
        signal   gm_tx_en_21        : std_logic;
        signal   gm_tx_err_21       : std_logic;
        signal   m_tx_d_21          : std_logic_vector (3 downto 0);
        signal   m_tx_en_21         : std_logic;
        signal   m_tx_err_21        : std_logic;
        signal   ena_10_21          : std_logic;
        signal   eth_mode_21        : std_logic;
        signal   magic_wakeup_21    : std_logic;
        signal   mac_tx_clk_22      : std_logic;
        signal   mac_rx_clk_22      : std_logic;
        signal   data_tx_ready_22   : std_logic;
        signal   data_rx_data_22    : std_logic_vector (7 downto 0);
        signal   data_rx_valid_22   : std_logic;
        signal   data_rx_eop_22     : std_logic;
        signal   data_rx_sop_22     : std_logic;
        signal   data_rx_error_22   : std_logic_vector (4 downto 0);
        signal   pkt_class_data_22  : std_logic_vector (4 downto 0);
        signal   pkt_class_valid_22 : std_logic;
        signal   gm_tx_d_22         : std_logic_vector (7 downto 0);
        signal   gm_tx_en_22        : std_logic;
        signal   gm_tx_err_22       : std_logic;
        signal   m_tx_d_22          : std_logic_vector (3 downto 0);
        signal   m_tx_en_22         : std_logic;
        signal   m_tx_err_22        : std_logic;
        signal   ena_10_22          : std_logic;
        signal   eth_mode_22        : std_logic;
        signal   magic_wakeup_22    : std_logic;
        signal   mac_tx_clk_23      : std_logic;
        signal   mac_rx_clk_23      : std_logic;
        signal   data_tx_ready_23   : std_logic;
        signal   data_rx_data_23    : std_logic_vector (7 downto 0);
        signal   data_rx_valid_23   : std_logic;
        signal   data_rx_eop_23     : std_logic;
        signal   data_rx_sop_23     : std_logic;
        signal   data_rx_error_23   : std_logic_vector (4 downto 0);
        signal   pkt_class_data_23  : std_logic_vector (4 downto 0);
        signal   pkt_class_valid_23 : std_logic;
        signal   gm_tx_d_23         : std_logic_vector (7 downto 0);
        signal   gm_tx_en_23        : std_logic;
        signal   gm_tx_err_23       : std_logic;
        signal   m_tx_d_23          : std_logic_vector (3 downto 0);
        signal   m_tx_en_23         : std_logic;
        signal   m_tx_err_23        : std_logic;
        signal   ena_10_23          : std_logic;
        signal   eth_mode_23        : std_logic;
        signal   magic_wakeup_23    : std_logic;

        signal   rgmii_in_0         : std_logic_vector (3 downto 0);
        signal   rx_control_0       : std_logic;
        signal   rgmii_in_1         : std_logic_vector (3 downto 0);
        signal   rx_control_1       : std_logic;
        signal   rgmii_in_2         : std_logic_vector (3 downto 0);
        signal   rx_control_2       : std_logic;
        signal   rgmii_in_3         : std_logic_vector (3 downto 0);
        signal   rx_control_3       : std_logic;
        signal   rgmii_in_4         : std_logic_vector (3 downto 0);
        signal   rx_control_4       : std_logic;
        signal   rgmii_in_5         : std_logic_vector (3 downto 0);
        signal   rx_control_5       : std_logic;
        signal   rgmii_in_6         : std_logic_vector (3 downto 0);
        signal   rx_control_6       : std_logic;
        signal   rgmii_in_7         : std_logic_vector (3 downto 0);
        signal   rx_control_7       : std_logic;
        signal   rgmii_in_8         : std_logic_vector (3 downto 0);
        signal   rx_control_8       : std_logic;
        signal   rgmii_in_9         : std_logic_vector (3 downto 0);
        signal   rx_control_9       : std_logic;
        signal   rgmii_in_10        : std_logic_vector (3 downto 0);
        signal   rx_control_10      : std_logic;
        signal   rgmii_in_11        : std_logic_vector (3 downto 0);
        signal   rx_control_11      : std_logic;
        signal   rgmii_in_12        : std_logic_vector (3 downto 0);
        signal   rx_control_12      : std_logic;
        signal   rgmii_in_13        : std_logic_vector (3 downto 0);
        signal   rx_control_13      : std_logic;
        signal   rgmii_in_14        : std_logic_vector (3 downto 0);
        signal   rx_control_14      : std_logic;
        signal   rgmii_in_15        : std_logic_vector (3 downto 0);
        signal   rx_control_15      : std_logic;
        signal   rgmii_in_16        : std_logic_vector (3 downto 0);
        signal   rx_control_16      : std_logic;
        signal   rgmii_in_17        : std_logic_vector (3 downto 0);
        signal   rx_control_17      : std_logic;
        signal   rgmii_in_18        : std_logic_vector (3 downto 0);
        signal   rx_control_18      : std_logic;
        signal   rgmii_in_19        : std_logic_vector (3 downto 0);
        signal   rx_control_19      : std_logic;
        signal   rgmii_in_20        : std_logic_vector (3 downto 0);
        signal   rx_control_20      : std_logic;
        signal   rgmii_in_21        : std_logic_vector (3 downto 0);
        signal   rx_control_21      : std_logic;
        signal   rgmii_in_22        : std_logic_vector (3 downto 0);
        signal   rx_control_22      : std_logic;
        signal   rgmii_in_23        : std_logic_vector (3 downto 0);
        signal   rx_control_23      : std_logic;
        signal   rgmii_out_0        : std_logic_vector (3 downto 0);
        signal   tx_control_0       : std_logic;
        signal   rgmii_out_1        : std_logic_vector (3 downto 0);
        signal   tx_control_1       : std_logic;
        signal   rgmii_out_2        : std_logic_vector (3 downto 0);
        signal   tx_control_2       : std_logic;
        signal   rgmii_out_3        : std_logic_vector (3 downto 0);
        signal   tx_control_3       : std_logic;
        signal   rgmii_out_4        : std_logic_vector (3 downto 0);
        signal   tx_control_4       : std_logic;
        signal   rgmii_out_5        : std_logic_vector (3 downto 0);
        signal   tx_control_5       : std_logic;
        signal   rgmii_out_6        : std_logic_vector (3 downto 0);
        signal   tx_control_6       : std_logic;
        signal   rgmii_out_7        : std_logic_vector (3 downto 0);
        signal   tx_control_7       : std_logic;
        signal   rgmii_out_8        : std_logic_vector (3 downto 0);
        signal   tx_control_8       : std_logic;
        signal   rgmii_out_9        : std_logic_vector (3 downto 0);
        signal   tx_control_9       : std_logic;
        signal   rgmii_out_10       : std_logic_vector (3 downto 0);
        signal   tx_control_10      : std_logic;
        signal   rgmii_out_11       : std_logic_vector (3 downto 0);
        signal   tx_control_11      : std_logic;
        signal   rgmii_out_12       : std_logic_vector (3 downto 0);
        signal   tx_control_12      : std_logic;
        signal   rgmii_out_13       : std_logic_vector (3 downto 0);
        signal   tx_control_13      : std_logic;
        signal   rgmii_out_14       : std_logic_vector (3 downto 0);
        signal   tx_control_14      : std_logic;
        signal   rgmii_out_15       : std_logic_vector (3 downto 0);
        signal   tx_control_15      : std_logic;
        signal   rgmii_out_16       : std_logic_vector (3 downto 0);
        signal   tx_control_16      : std_logic;
        signal   rgmii_out_17       : std_logic_vector (3 downto 0);
        signal   tx_control_17      : std_logic;
        signal   rgmii_out_18       : std_logic_vector (3 downto 0);
        signal   tx_control_18      : std_logic;
        signal   rgmii_out_19       : std_logic_vector (3 downto 0);
        signal   tx_control_19      : std_logic;
        signal   rgmii_out_20       : std_logic_vector (3 downto 0);
        signal   tx_control_20      : std_logic;
        signal   rgmii_out_21       : std_logic_vector (3 downto 0);
        signal   tx_control_21      : std_logic;
        signal   rgmii_out_22       : std_logic_vector (3 downto 0);
        signal   tx_control_22      : std_logic;
        signal   rgmii_out_23       : std_logic_vector (3 downto 0);
        signal   tx_control_23      : std_logic;

        signal   tbi_rx_clk_0       : std_logic ;             --  125MHz Recoved Clock
        signal   tbi_tx_clk_0       : std_logic ;             --  125MHz Transmit Clock
        signal   tbi_rx_d_0         : std_logic_vector(9 downto 0) ;         --  Non Aligned 10-Bit Characters
        signal   tbi_tx_d_0         : std_logic_vector(9 downto 0) ;         --  Transmit TBI Interface
        signal   sd_loopback_0      : std_logic ;            --  SERDES Loopback Enable
        signal   powerdown_0        : std_logic ;              --  Powerdown Enable
        signal   led_crs_0          : std_logic ;                --  Carrier Sense
        signal   led_link_0         : std_logic ;               --  Valid Link 
        signal   led_col_0          : std_logic ;                --  Collision Indication
        signal   led_an_0           : std_logic ;                 --  Auto-Negotiation Status
        signal   led_char_err_0     : std_logic ;           --  Character Error
        signal   led_disp_err_0     : std_logic ;           --  Disparity Error
       --         
        signal   tbi_rx_clk_1       : std_logic ;             --  125MHz Recoved Clock
        signal   tbi_tx_clk_1       : std_logic ;             --  125MHz Transmit Clock
        signal   tbi_rx_d_1         : std_logic_vector(9 downto 0) ;         --  Non Aligned 10-Bit Characters
        signal   tbi_tx_d_1         : std_logic_vector(9 downto 0) ;         --  Transmit TBI Interface
        signal   sd_loopback_1      : std_logic ;            --  SERDES Loopback Enable
        signal   powerdown_1        : std_logic ;              --  Powerdown Enable
        signal   led_crs_1          : std_logic ;                --  Carrier Sense
        signal   led_link_1         : std_logic ;               --  Valid Link 
        signal   led_col_1          : std_logic ;                --  Collision Indication
        signal   led_an_1           : std_logic ;                 --  Auto-Negotiation Status
        signal   led_char_err_1     : std_logic ;           --  Character Error
        signal   led_disp_err_1     : std_logic ;           --  Disparity Error
       --
        signal   tbi_rx_clk_2       : std_logic ;             --  125MHz Recoved Clock
        signal   tbi_tx_clk_2       : std_logic ;             --  125MHz Transmit Clock
        signal   tbi_rx_d_2         : std_logic_vector(9 downto 0) ;         --  Non Aligned 10-Bit Characters
        signal   tbi_tx_d_2         : std_logic_vector(9 downto 0) ;         --  Transmit TBI Interface
        signal   sd_loopback_2      : std_logic ;            --  SERDES Loopback Enable
        signal   powerdown_2        : std_logic ;              --  Powerdown Enable
        signal   led_crs_2          : std_logic ;                --  Carrier Sense
        signal   led_link_2         : std_logic ;               --  Valid Link 
        signal   led_col_2          : std_logic ;                --  Collision Indication
        signal   led_an_2           : std_logic ;                 --  Auto-Negotiation Status
        signal   led_char_err_2     : std_logic ;           --  Character Error
        signal   led_disp_err_2     : std_logic ;           --  Disparity Error
       --
        signal   tbi_rx_clk_3       : std_logic ;             --  125MHz Recoved Clock
        signal   tbi_tx_clk_3       : std_logic ;             --  125MHz Transmit Clock
        signal   tbi_rx_d_3         : std_logic_vector(9 downto 0) ;         --  Non Aligned 10-Bit Characters
        signal   tbi_tx_d_3         : std_logic_vector(9 downto 0) ;         --  Transmit TBI Interface
        signal   sd_loopback_3      : std_logic ;            --  SERDES Loopback Enable
        signal   powerdown_3        : std_logic ;              --  Powerdown Enable
        signal   led_crs_3          : std_logic ;                --  Carrier Sense
        signal   led_link_3         : std_logic ;               --  Valid Link 
        signal   led_col_3          : std_logic ;                --  Collision Indication
        signal   led_an_3           : std_logic ;                 --  Auto-Negotiation Status
        signal   led_char_err_3     : std_logic ;           --  Character Error
        signal   led_disp_err_3     : std_logic ;           --  Disparity Error
       --
        signal   tbi_rx_clk_4       : std_logic ;             --  125MHz Recoved Clock
        signal   tbi_tx_clk_4       : std_logic ;             --  125MHz Transmit Clock
        signal   tbi_rx_d_4         : std_logic_vector(9 downto 0) ;         --  Non Aligned 10-Bit Characters
        signal   tbi_tx_d_4         : std_logic_vector(9 downto 0) ;         --  Transmit TBI Interface
        signal   sd_loopback_4      : std_logic ;            --  SERDES Loopback Enable
        signal   powerdown_4        : std_logic ;              --  Powerdown Enable
        signal   led_crs_4          : std_logic ;                --  Carrier Sense
        signal   led_link_4         : std_logic ;               --  Valid Link 
        signal   led_col_4          : std_logic ;                --  Collision Indication
        signal   led_an_4           : std_logic ;                 --  Auto-Negotiation Status
        signal   led_char_err_4     : std_logic ;           --  Character Error
        signal   led_disp_err_4     : std_logic ;           --  Disparity Error
       --
        signal   tbi_rx_clk_5       : std_logic ;             --  125MHz Recoved Clock
        signal   tbi_tx_clk_5       : std_logic ;             --  125MHz Transmit Clock
        signal   tbi_rx_d_5         : std_logic_vector(9 downto 0);         --  Non Aligned 10-Bit Characters
        signal   tbi_tx_d_5         : std_logic_vector(9 downto 0);         --  Transmit TBI Interface
        signal   sd_loopback_5      : std_logic ;            --  SERDES Loopback Enable
        signal   powerdown_5        : std_logic ;              --  Powerdown Enable
        signal   led_crs_5          : std_logic ;                --  Carrier Sense
        signal   led_link_5         : std_logic ;               --  Valid Link 
        signal   led_col_5          : std_logic ;                --  Collision Indication
        signal   led_an_5           : std_logic ;                 --  Auto-Negotiation Status
        signal   led_char_err_5     : std_logic ;           --  Character Error
        signal   led_disp_err_5     : std_logic ;           --  Disparity Error
       --
        signal   tbi_rx_clk_6       : std_logic ;             --  125MHz Recoved Clock
        signal   tbi_tx_clk_6       : std_logic ;             --  125MHz Transmit Clock
        signal   tbi_rx_d_6         : std_logic_vector(9 downto 0);         --  Non Aligned 10-Bit Characters
        signal   tbi_tx_d_6         : std_logic_vector(9 downto 0);         --  Transmit TBI Interface
        signal   sd_loopback_6      : std_logic ;            --  SERDES Loopback Enable
        signal   powerdown_6        : std_logic ;              --  Powerdown Enable
        signal   led_crs_6          : std_logic ;                --  Carrier Sense
        signal   led_link_6         : std_logic ;               --  Valid Link 
        signal   led_col_6          : std_logic ;                --  Collision Indication
        signal   led_an_6           : std_logic ;                 --  Auto-Negotiation Status
        signal   led_char_err_6     : std_logic ;           --  Character Error
        signal   led_disp_err_6     : std_logic ;           --  Disparity Error
       --
        signal   tbi_rx_clk_7       : std_logic ;             --  125MHz Recoved Clock
        signal   tbi_tx_clk_7       : std_logic ;             --  125MHz Transmit Clock
        signal   tbi_rx_d_7         : std_logic_vector(9 downto 0);         --  Non Aligned 10-Bit Characters
        signal   tbi_tx_d_7         : std_logic_vector(9 downto 0);         --  Transmit TBI Interface
        signal   sd_loopback_7      : std_logic ;            --  SERDES Loopback Enable
        signal   powerdown_7        : std_logic ;              --  Powerdown Enable
        signal   led_crs_7          : std_logic ;                --  Carrier Sense
        signal   led_link_7         : std_logic ;               --  Valid Link 
        signal   led_col_7          : std_logic ;                --  Collision Indication
        signal   led_an_7           : std_logic ;                 --  Auto-Negotiation Status
        signal   led_char_err_7     : std_logic ;           --  Character Error
        signal   led_disp_err_7     : std_logic ;           --  Disparity Error
       --
        signal   tbi_rx_clk_8       : std_logic ;             --  125MHz Recoved Clock
        signal   tbi_tx_clk_8       : std_logic ;             --  125MHz Transmit Clock
        signal   tbi_rx_d_8         : std_logic_vector(9 downto 0);         --  Non Aligned 10-Bit Characters
        signal   tbi_tx_d_8         : std_logic_vector(9 downto 0);         --  Transmit TBI Interface
        signal   sd_loopback_8      : std_logic ;            --  SERDES Loopback Enable
        signal   powerdown_8        : std_logic ;              --  Powerdown Enable
        signal   led_crs_8          : std_logic ;                --  Carrier Sense
        signal   led_link_8         : std_logic ;               --  Valid Link 
        signal   led_col_8          : std_logic ;                --  Collision Indication
        signal   led_an_8           : std_logic ;                 --  Auto-Negotiation Status
        signal   led_char_err_8     : std_logic ;           --  Character Error
        signal   led_disp_err_8     : std_logic ;           --  Disparity Error
       --
        signal   tbi_rx_clk_9       : std_logic ;             --  125MHz Recoved Clock
        signal   tbi_tx_clk_9       : std_logic ;             --  125MHz Transmit Clock
        signal   tbi_rx_d_9         : std_logic_vector(9 downto 0);         --  Non Aligned 10-Bit Characters
        signal   tbi_tx_d_9         : std_logic_vector(9 downto 0);         --  Transmit TBI Interface
        signal   sd_loopback_9      : std_logic ;            --  SERDES Loopback Enable
        signal   powerdown_9        : std_logic ;              --  Powerdown Enable
        signal   led_crs_9          : std_logic ;                --  Carrier Sense
        signal   led_link_9         : std_logic ;               --  Valid Link 
        signal   led_col_9          : std_logic ;                --  Collision Indication
        signal   led_an_9           : std_logic ;                 --  Auto-Negotiation Status
        signal   led_char_err_9     : std_logic ;           --  Character Error
        signal   led_disp_err_9     : std_logic ;           --  Disparity Error
       --
        signal   tbi_rx_clk_10      : std_logic ;             --  125MHz Recoved Clock
        signal   tbi_tx_clk_10      : std_logic ;             --  125MHz Transmit Clock
        signal   tbi_rx_d_10        : std_logic_vector(9 downto 0);         --  Non Aligned 10-Bit Characters
        signal   tbi_tx_d_10        : std_logic_vector(9 downto 0);         --  Transmit TBI Interface
        signal   sd_loopback_10     : std_logic ;            --  SERDES Loopback Enable
        signal   powerdown_10       : std_logic ;              --  Powerdown Enable
        signal   led_crs_10         : std_logic ;                --  Carrier Sense
        signal   led_link_10        : std_logic ;               --  Valid Link 
        signal   led_col_10         : std_logic ;                --  Collision Indication
        signal   led_an_10          : std_logic ;                 --  Auto-Negotiation Status
        signal   led_char_err_10    : std_logic ;           --  Character Error
        signal   led_disp_err_10    : std_logic ;           --  Disparity Error
   
       --
        signal   tbi_rx_clk_11      : std_logic ;             --  125MHz Recoved Clock
        signal   tbi_tx_clk_11      : std_logic ;             --  125MHz Transmit Clock
        signal   tbi_rx_d_11        : std_logic_vector(9 downto 0);         --  Non Aligned 10-Bit Characters
        signal   tbi_tx_d_11        : std_logic_vector(9 downto 0);         --  Transmit TBI Interface
        signal   sd_loopback_11     : std_logic ;            --  SERDES Loopback Enable
        signal   powerdown_11       : std_logic ;              --  Powerdown Enable
        signal   led_crs_11         : std_logic ;                --  Carrier Sense
        signal   led_link_11        : std_logic ;               --  Valid Link 
        signal   led_col_11         : std_logic ;                --  Collision Indication
        signal   led_an_11          : std_logic ;                 --  Auto-Negotiation Status
        signal   led_char_err_11    : std_logic ;           --  Character Error
        signal   led_disp_err_11    : std_logic ;           --  Disparity Error
       --
        signal   tbi_rx_clk_12      : std_logic ;             --  125MHz Recoved Clock
        signal   tbi_tx_clk_12      : std_logic ;             --  125MHz Transmit Clock
        signal   tbi_rx_d_12        : std_logic_vector(9 downto 0);         --  Non Aligned 10-Bit Characters
        signal   tbi_tx_d_12        : std_logic_vector(9 downto 0);         --  Transmit TBI Interface
        signal   sd_loopback_12     : std_logic ;            --  SERDES Loopback Enable
        signal   powerdown_12       : std_logic ;              --  Powerdown Enable
        signal   led_crs_12         : std_logic ;                --  Carrier Sense
        signal   led_link_12        : std_logic ;               --  Valid Link 
        signal   led_col_12         : std_logic ;                --  Collision Indication
        signal   led_an_12          : std_logic ;                 --  Auto-Negotiation Status
        signal   led_char_err_12    : std_logic ;           --  Character Error
        signal   led_disp_err_12    : std_logic ;           --  Disparity Error
       --
        signal   tbi_rx_clk_13      : std_logic ;             --  125MHz Recoved Clock
        signal   tbi_tx_clk_13      : std_logic ;             --  125MHz Transmit Clock
        signal   tbi_rx_d_13        : std_logic_vector(9 downto 0);         --  Non Aligned 10-Bit Characters
        signal   tbi_tx_d_13        : std_logic_vector(9 downto 0);         --  Transmit TBI Interface
        signal   sd_loopback_13     : std_logic ;            --  SERDES Loopback Enable
        signal   powerdown_13       : std_logic ;              --  Powerdown Enable
        signal   led_crs_13         : std_logic ;                --  Carrier Sense
        signal   led_link_13        : std_logic ;               --  Valid Link 
        signal   led_col_13         : std_logic ;                --  Collision Indication
        signal   led_an_13          : std_logic ;                 --  Auto-Negotiation Status
        signal   led_char_err_13    : std_logic ;           --  Character Error
        signal   led_disp_err_13    : std_logic ;           --  Disparity Error
       --
        signal   tbi_rx_clk_14      : std_logic ;             --  125MHz Recoved Clock
        signal   tbi_tx_clk_14      : std_logic ;             --  125MHz Transmit Clock
        signal   tbi_rx_d_14        : std_logic_vector(9 downto 0);         --  Non Aligned 10-Bit Characters
        signal   tbi_tx_d_14        : std_logic_vector(9 downto 0);         --  Transmit TBI Interface
        signal   sd_loopback_14     : std_logic ;            --  SERDES Loopback Enable
        signal   powerdown_14       : std_logic ;              --  Powerdown Enable
        signal   led_crs_14         : std_logic ;                --  Carrier Sense
        signal   led_link_14        : std_logic ;               --  Valid Link 
        signal   led_col_14         : std_logic ;                --  Collision Indication
        signal   led_an_14          : std_logic ;                 --  Auto-Negotiation Status
        signal   led_char_err_14    : std_logic ;           --  Character Error
        signal   led_disp_err_14    : std_logic ;           --  Disparity Error
       --
        signal   tbi_rx_clk_15      : std_logic ;             --  125MHz Recoved Clock
        signal   tbi_tx_clk_15      : std_logic ;             --  125MHz Transmit Clock
        signal   tbi_rx_d_15        : std_logic_vector(9 downto 0);         --  Non Aligned 10-Bit Characters
        signal   tbi_tx_d_15        : std_logic_vector(9 downto 0);         --  Transmit TBI Interface
        signal   sd_loopback_15     : std_logic ;            --  SERDES Loopback Enable
        signal   powerdown_15       : std_logic ;              --  Powerdown Enable
        signal   led_crs_15         : std_logic ;                --  Carrier Sense
        signal   led_link_15        : std_logic ;               --  Valid Link 
        signal   led_col_15         : std_logic ;                --  Collision Indication
        signal   led_an_15          : std_logic ;                 --  Auto-Negotiation Status
        signal   led_char_err_15    : std_logic ;           --  Character Error
        signal   led_disp_err_15    : std_logic ;           --  Disparity Error
       --
        signal   tbi_rx_clk_16      : std_logic ;             --  125MHz Recoved Clock
        signal   tbi_tx_clk_16      : std_logic ;             --  125MHz Transmit Clock
        signal   tbi_rx_d_16        : std_logic_vector(9 downto 0);         --  Non Aligned 10-Bit Characters
        signal   tbi_tx_d_16        : std_logic_vector(9 downto 0);         --  Transmit TBI Interface
        signal   sd_loopback_16     : std_logic ;            --  SERDES Loopback Enable
        signal   powerdown_16       : std_logic ;              --  Powerdown Enable
        signal   led_crs_16         : std_logic ;                --  Carrier Sense
        signal   led_link_16        : std_logic ;               --  Valid Link 
        signal   led_col_16         : std_logic ;                --  Collision Indication
        signal   led_an_16          : std_logic ;                 --  Auto-Negotiation Status
        signal   led_char_err_16    : std_logic ;           --  Character Error
        signal   led_disp_err_16    : std_logic ;           --  Disparity Error
       --
        signal   tbi_rx_clk_17      : std_logic ;             --  125MHz Recoved Clock
        signal   tbi_tx_clk_17      : std_logic ;             --  125MHz Transmit Clock
        signal   tbi_rx_d_17        : std_logic_vector(9 downto 0);         --  Non Aligned 10-Bit Characters
        signal   tbi_tx_d_17        : std_logic_vector(9 downto 0);         --  Transmit TBI Interface
        signal   sd_loopback_17     : std_logic ;            --  SERDES Loopback Enable
        signal   powerdown_17       : std_logic ;              --  Powerdown Enable
        signal   led_crs_17         : std_logic ;                --  Carrier Sense
        signal   led_link_17        : std_logic ;               --  Valid Link 
        signal   led_col_17         : std_logic ;                --  Collision Indication
        signal   led_an_17          : std_logic ;                 --  Auto-Negotiation Status
        signal   led_char_err_17    : std_logic ;           --  Character Error
        signal   led_disp_err_17    : std_logic ;           --  Disparity Error
   
       --
        signal   tbi_rx_clk_18      : std_logic ;             --  125MHz Recoved Clock
        signal   tbi_tx_clk_18      : std_logic ;             --  125MHz Transmit Clock
        signal   tbi_rx_d_18        : std_logic_vector(9 downto 0);         --  Non Aligned 10-Bit Characters
        signal   tbi_tx_d_18        : std_logic_vector(9 downto 0);         --  Transmit TBI Interface
        signal   sd_loopback_18     : std_logic ;            --  SERDES Loopback Enable
        signal   powerdown_18       : std_logic ;              --  Powerdown Enable
        signal   led_crs_18         : std_logic ;                --  Carrier Sense
        signal   led_link_18        : std_logic ;               --  Valid Link 
        signal   led_col_18         : std_logic ;                --  Collision Indication
        signal   led_an_18          : std_logic ;                 --  Auto-Negotiation Status
        signal   led_char_err_18    : std_logic ;           --  Character Error
        signal   led_disp_err_18    : std_logic ;           --  Disparity Error
   
       --
        signal   tbi_rx_clk_19      : std_logic ;             --  125MHz Recoved Clock
        signal   tbi_tx_clk_19      : std_logic ;             --  125MHz Transmit Clock
        signal   tbi_rx_d_19        : std_logic_vector(9 downto 0);         --  Non Aligned 10-Bit Characters
        signal   tbi_tx_d_19        : std_logic_vector(9 downto 0);         --  Transmit TBI Interface
        signal   sd_loopback_19     : std_logic ;            --  SERDES Loopback Enable
        signal   powerdown_19       : std_logic ;              --  Powerdown Enable
        signal   led_crs_19         : std_logic ;                --  Carrier Sense
        signal   led_link_19        : std_logic ;               --  Valid Link 
        signal   led_col_19         : std_logic ;                --  Collision Indication
        signal   led_an_19          : std_logic ;                 --  Auto-Negotiation Status
        signal   led_char_err_19    : std_logic ;           --  Character Error
        signal   led_disp_err_19    : std_logic ;           --  Disparity Error
   
       --
        signal   tbi_rx_clk_20      : std_logic ;             --  125MHz Recoved Clock
        signal   tbi_tx_clk_20      : std_logic ;             --  125MHz Transmit Clock
        signal   tbi_rx_d_20        : std_logic_vector(9 downto 0);         --  Non Aligned 10-Bit Characters
        signal   tbi_tx_d_20        : std_logic_vector(9 downto 0);         --  Transmit TBI Interface
        signal   sd_loopback_20     : std_logic ;            --  SERDES Loopback Enable
        signal   powerdown_20       : std_logic ;              --  Powerdown Enable
        signal   led_crs_20         : std_logic ;                --  Carrier Sense
        signal   led_link_20        : std_logic ;               --  Valid Link 
        signal   led_col_20         : std_logic ;                --  Collision Indication
        signal   led_an_20          : std_logic ;                 --  Auto-Negotiation Status
        signal   led_char_err_20    : std_logic ;           --  Character Error
        signal   led_disp_err_20    : std_logic ;           --  Disparity Error
   
       --
        signal   tbi_rx_clk_21      : std_logic ;             --  125MHz Recoved Clock
        signal   tbi_tx_clk_21      : std_logic ;             --  125MHz Transmit Clock
        signal   tbi_rx_d_21        : std_logic_vector(9 downto 0);         --  Non Aligned 10-Bit Characters
        signal   tbi_tx_d_21        : std_logic_vector(9 downto 0);         --  Transmit TBI Interface
        signal   sd_loopback_21     : std_logic ;            --  SERDES Loopback Enable
        signal   powerdown_21       : std_logic ;              --  Powerdown Enable
        signal   led_crs_21         : std_logic ;                --  Carrier Sense
        signal   led_link_21        : std_logic ;               --  Valid Link 
        signal   led_col_21         : std_logic ;                --  Collision Indication
        signal   led_an_21          : std_logic ;                 --  Auto-Negotiation Status
        signal   led_char_err_21    : std_logic ;           --  Character Error
        signal   led_disp_err_21    : std_logic ;           --  Disparity Error
   
       --
        signal   tbi_rx_clk_22      : std_logic ;             --  125MHz Recoved Clock
        signal   tbi_tx_clk_22      : std_logic ;             --  125MHz Transmit Clock
        signal   tbi_rx_d_22        : std_logic_vector(9 downto 0) ;         --  Non Aligned 10-Bit Characters
        signal   tbi_tx_d_22        : std_logic_vector(9 downto 0);         --  Transmit TBI Interface
        signal   sd_loopback_22     : std_logic ;            --  SERDES Loopback Enable
        signal   powerdown_22       : std_logic ;              --  Powerdown Enable
        signal   led_crs_22         : std_logic ;                --  Carrier Sense
        signal   led_link_22        : std_logic ;               --  Valid Link 
        signal   led_col_22         : std_logic ;                --  Collision Indication
        signal   led_an_22          : std_logic ;                 --  Auto-Negotiation Status
        signal   led_char_err_22    : std_logic ;           --  Character Error
        signal   led_disp_err_22    : std_logic ;           --  Disparity Error
   
       --
        signal   tbi_rx_clk_23      : std_logic ;             --  125MHz Recoved Clock
        signal   tbi_tx_clk_23      : std_logic ;             --  125MHz Transmit Clock
        signal   tbi_rx_d_23        : std_logic_vector(9 downto 0);         --  Non Aligned 10-Bit Characters
        signal   tbi_tx_d_23        : std_logic_vector(9 downto 0);         --  Transmit TBI Interface
        signal   sd_loopback_23     : std_logic ;            --  SERDES Loopback Enable
        signal   powerdown_23       : std_logic ;              --  Powerdown Enable
        signal   led_crs_23         : std_logic ;                --  Carrier Sense
        signal   led_link_23        : std_logic ;               --  Valid Link 
        signal   led_col_23         : std_logic ;                --  Collision Indication
        signal   led_an_23          : std_logic ;                 --  Auto-Negotiation Status
        signal   led_char_err_23    : std_logic ;           --  Character Error
        signal   led_disp_err_23    : std_logic ;           --  Disparity Error
   
       -- DEVICE SPECIFIC SIGNALS
        signal   gxb_cal_blk_clk    : std_logic ;            --  GXB Calibration Clock
        signal   ref_clk            : std_logic ;                    --  Reference Clock

	   -- RECONFIG BLOCK SIGNALS
      signal   reconfig_clk			: std_logic_vector (0 downto 0) ;			-- Reconfig clk
      signal   reconfig_reset       : std_logic_vector (0 downto 0);
      signal   reconfig_write       : std_logic_vector (0 downto 0);
      signal   reconfig_read        : std_logic_vector (0 downto 0);
      signal   reconfig_address     : std_logic_vector (9 downto 0);
      signal   reconfig_writedata   : std_logic_vector (31 downto 0);
      signal   reconfig_readdata    : std_logic_vector (31 downto 0);
      signal   reconfig_waitrequest : std_logic_vector (0 downto 0);

      signal   reconfig_clk_0			   : std_logic_vector (0 downto 0) ;			-- Reconfig clk
      signal   reconfig_reset_0        : std_logic_vector (0 downto 0);
      signal   reconfig_write_0        : std_logic_vector (0 downto 0);
      signal   reconfig_read_0         : std_logic_vector (0 downto 0);
      signal   reconfig_address_0      : std_logic_vector (9 downto 0);
      signal   reconfig_writedata_0    : std_logic_vector (31 downto 0);
      signal   reconfig_readdata_0     : std_logic_vector (31 downto 0);
      signal   reconfig_waitrequest_0  : std_logic_vector (0 downto 0);

      signal   reconfig_clk_1			   : std_logic_vector (0 downto 0) ;			-- Reconfig clk
      signal   reconfig_reset_1        : std_logic_vector (0 downto 0);
      signal   reconfig_write_1        : std_logic_vector (0 downto 0);
      signal   reconfig_read_1         : std_logic_vector (0 downto 0);
      signal   reconfig_address_1      : std_logic_vector (9 downto 0);
      signal   reconfig_writedata_1    : std_logic_vector (31 downto 0);
      signal   reconfig_readdata_1     : std_logic_vector (31 downto 0);
      signal   reconfig_waitrequest_1  : std_logic_vector (0 downto 0);

      signal   reconfig_clk_2			   : std_logic_vector (0 downto 0) ;			-- Reconfig clk
      signal   reconfig_reset_2        : std_logic_vector (0 downto 0);
      signal   reconfig_write_2        : std_logic_vector (0 downto 0);
      signal   reconfig_read_2         : std_logic_vector (0 downto 0);
      signal   reconfig_address_2      : std_logic_vector (9 downto 0);
      signal   reconfig_writedata_2    : std_logic_vector (31 downto 0);
      signal   reconfig_readdata_2     : std_logic_vector (31 downto 0);
      signal   reconfig_waitrequest_2  : std_logic_vector (0 downto 0);

      signal   reconfig_clk_3			   : std_logic_vector (0 downto 0) ;			-- Reconfig clk
      signal   reconfig_reset_3        : std_logic_vector (0 downto 0);
      signal   reconfig_write_3        : std_logic_vector (0 downto 0);
      signal   reconfig_read_3         : std_logic_vector (0 downto 0);
      signal   reconfig_address_3      : std_logic_vector (9 downto 0);
      signal   reconfig_writedata_3    : std_logic_vector (31 downto 0);
      signal   reconfig_readdata_3     : std_logic_vector (31 downto 0);
      signal   reconfig_waitrequest_3  : std_logic_vector (0 downto 0);

      signal   reconfig_clk_4			   : std_logic_vector (0 downto 0) ;			-- Reconfig clk
      signal   reconfig_reset_4        : std_logic_vector (0 downto 0);
      signal   reconfig_write_4        : std_logic_vector (0 downto 0);
      signal   reconfig_read_4         : std_logic_vector (0 downto 0);
      signal   reconfig_address_4      : std_logic_vector (9 downto 0);
      signal   reconfig_writedata_4    : std_logic_vector (31 downto 0);
      signal   reconfig_readdata_4     : std_logic_vector (31 downto 0);
      signal   reconfig_waitrequest_4  : std_logic_vector (0 downto 0);

      signal   reconfig_clk_5			   : std_logic_vector (0 downto 0) ;			-- Reconfig clk
      signal   reconfig_reset_5        : std_logic_vector (0 downto 0);
      signal   reconfig_write_5        : std_logic_vector (0 downto 0);
      signal   reconfig_read_5         : std_logic_vector (0 downto 0);
      signal   reconfig_address_5      : std_logic_vector (9 downto 0);
      signal   reconfig_writedata_5    : std_logic_vector (31 downto 0);
      signal   reconfig_readdata_5     : std_logic_vector (31 downto 0);
      signal   reconfig_waitrequest_5  : std_logic_vector (0 downto 0);

      signal   reconfig_clk_6			   : std_logic_vector (0 downto 0) ;			-- Reconfig clk
      signal   reconfig_reset_6        : std_logic_vector (0 downto 0);
      signal   reconfig_write_6        : std_logic_vector (0 downto 0);
      signal   reconfig_read_6         : std_logic_vector (0 downto 0);
      signal   reconfig_address_6      : std_logic_vector (9 downto 0);
      signal   reconfig_writedata_6    : std_logic_vector (31 downto 0);
      signal   reconfig_readdata_6     : std_logic_vector (31 downto 0);
      signal   reconfig_waitrequest_6  : std_logic_vector (0 downto 0);

      signal   reconfig_clk_7			   : std_logic_vector (0 downto 0) ;			-- Reconfig clk
      signal   reconfig_reset_7        : std_logic_vector (0 downto 0);
      signal   reconfig_write_7        : std_logic_vector (0 downto 0);
      signal   reconfig_read_7         : std_logic_vector (0 downto 0);
      signal   reconfig_address_7      : std_logic_vector (9 downto 0);
      signal   reconfig_writedata_7    : std_logic_vector (31 downto 0);
      signal   reconfig_readdata_7     : std_logic_vector (31 downto 0);
      signal   reconfig_waitrequest_7  : std_logic_vector (0 downto 0);

      signal   reconfig_clk_8			   : std_logic_vector (0 downto 0) ;			-- Reconfig clk
      signal   reconfig_reset_8        : std_logic_vector (0 downto 0);
      signal   reconfig_write_8        : std_logic_vector (0 downto 0);
      signal   reconfig_read_8         : std_logic_vector (0 downto 0);
      signal   reconfig_address_8      : std_logic_vector (9 downto 0);
      signal   reconfig_writedata_8    : std_logic_vector (31 downto 0);
      signal   reconfig_readdata_8     : std_logic_vector (31 downto 0);
      signal   reconfig_waitrequest_8  : std_logic_vector (0 downto 0);

      signal   reconfig_clk_9			   : std_logic_vector (0 downto 0) ;			-- Reconfig clk
      signal   reconfig_reset_9        : std_logic_vector (0 downto 0);
      signal   reconfig_write_9        : std_logic_vector (0 downto 0);
      signal   reconfig_read_9         : std_logic_vector (0 downto 0);
      signal   reconfig_address_9      : std_logic_vector (9 downto 0);
      signal   reconfig_writedata_9    : std_logic_vector (31 downto 0);
      signal   reconfig_readdata_9     : std_logic_vector (31 downto 0);
      signal   reconfig_waitrequest_9  : std_logic_vector (0 downto 0);

      signal   reconfig_clk_10			: std_logic_vector (0 downto 0) ;			-- Reconfig clk
      signal   reconfig_reset_10       : std_logic_vector (0 downto 0);
      signal   reconfig_write_10       : std_logic_vector (0 downto 0);
      signal   reconfig_read_10        : std_logic_vector (0 downto 0);
      signal   reconfig_address_10     : std_logic_vector (9 downto 0);
      signal   reconfig_writedata_10   : std_logic_vector (31 downto 0);
      signal   reconfig_readdata_10    : std_logic_vector (31 downto 0);
      signal   reconfig_waitrequest_10 : std_logic_vector (0 downto 0);

      signal   reconfig_clk_11			: std_logic_vector (0 downto 0) ;			-- Reconfig clk
      signal   reconfig_reset_11       : std_logic_vector (0 downto 0);
      signal   reconfig_write_11       : std_logic_vector (0 downto 0);
      signal   reconfig_read_11        : std_logic_vector (0 downto 0);
      signal   reconfig_address_11     : std_logic_vector (9 downto 0);
      signal   reconfig_writedata_11   : std_logic_vector (31 downto 0);
      signal   reconfig_readdata_11    : std_logic_vector (31 downto 0);
      signal   reconfig_waitrequest_11 : std_logic_vector (0 downto 0);

      signal   reconfig_clk_12			: std_logic_vector (0 downto 0) ;			-- Reconfig clk
      signal   reconfig_reset_12       : std_logic_vector (0 downto 0);
      signal   reconfig_write_12       : std_logic_vector (0 downto 0);
      signal   reconfig_read_12        : std_logic_vector (0 downto 0);
      signal   reconfig_address_12     : std_logic_vector (9 downto 0);
      signal   reconfig_writedata_12   : std_logic_vector (31 downto 0);
      signal   reconfig_readdata_12    : std_logic_vector (31 downto 0);
      signal   reconfig_waitrequest_12 : std_logic_vector (0 downto 0);

      signal   reconfig_clk_13			: std_logic_vector (0 downto 0) ;			-- Reconfig clk
      signal   reconfig_reset_13       : std_logic_vector (0 downto 0);
      signal   reconfig_write_13       : std_logic_vector (0 downto 0);
      signal   reconfig_read_13        : std_logic_vector (0 downto 0);
      signal   reconfig_address_13     : std_logic_vector (9 downto 0);
      signal   reconfig_writedata_13   : std_logic_vector (31 downto 0);
      signal   reconfig_readdata_13    : std_logic_vector (31 downto 0);
      signal   reconfig_waitrequest_13 : std_logic_vector (0 downto 0);

      signal   reconfig_clk_14			: std_logic_vector (0 downto 0) ;			-- Reconfig clk
      signal   reconfig_reset_14       : std_logic_vector (0 downto 0);
      signal   reconfig_write_14       : std_logic_vector (0 downto 0);
      signal   reconfig_read_14        : std_logic_vector (0 downto 0);
      signal   reconfig_address_14     : std_logic_vector (9 downto 0);
      signal   reconfig_writedata_14   : std_logic_vector (31 downto 0);
      signal   reconfig_readdata_14    : std_logic_vector (31 downto 0);
      signal   reconfig_waitrequest_14 : std_logic_vector (0 downto 0);

      signal   reconfig_clk_15			: std_logic_vector (0 downto 0) ;			-- Reconfig clk
      signal   reconfig_reset_15       : std_logic_vector (0 downto 0);
      signal   reconfig_write_15       : std_logic_vector (0 downto 0);
      signal   reconfig_read_15        : std_logic_vector (0 downto 0);
      signal   reconfig_address_15     : std_logic_vector (9 downto 0);
      signal   reconfig_writedata_15   : std_logic_vector (31 downto 0);
      signal   reconfig_readdata_15    : std_logic_vector (31 downto 0);
      signal   reconfig_waitrequest_15 : std_logic_vector (0 downto 0);

      signal   reconfig_clk_16			: std_logic_vector (0 downto 0) ;			-- Reconfig clk
      signal   reconfig_reset_16       : std_logic_vector (0 downto 0);
      signal   reconfig_write_16       : std_logic_vector (0 downto 0);
      signal   reconfig_read_16        : std_logic_vector (0 downto 0);
      signal   reconfig_address_16     : std_logic_vector (9 downto 0);
      signal   reconfig_writedata_16   : std_logic_vector (31 downto 0);
      signal   reconfig_readdata_16    : std_logic_vector (31 downto 0);
      signal   reconfig_waitrequest_16 : std_logic_vector (0 downto 0);

      signal   reconfig_clk_17			: std_logic_vector (0 downto 0) ;			-- Reconfig clk
      signal   reconfig_reset_17       : std_logic_vector (0 downto 0);
      signal   reconfig_write_17       : std_logic_vector (0 downto 0);
      signal   reconfig_read_17        : std_logic_vector (0 downto 0);
      signal   reconfig_address_17     : std_logic_vector (9 downto 0);
      signal   reconfig_writedata_17   : std_logic_vector (31 downto 0);
      signal   reconfig_readdata_17    : std_logic_vector (31 downto 0);
      signal   reconfig_waitrequest_17 : std_logic_vector (0 downto 0);

      signal   reconfig_clk_18			: std_logic_vector (0 downto 0) ;			-- Reconfig clk
      signal   reconfig_reset_18       : std_logic_vector (0 downto 0);
      signal   reconfig_write_18       : std_logic_vector (0 downto 0);
      signal   reconfig_read_18        : std_logic_vector (0 downto 0);
      signal   reconfig_address_18     : std_logic_vector (9 downto 0);
      signal   reconfig_writedata_18   : std_logic_vector (31 downto 0);
      signal   reconfig_readdata_18    : std_logic_vector (31 downto 0);
      signal   reconfig_waitrequest_18 : std_logic_vector (0 downto 0);

      signal   reconfig_clk_19			: std_logic_vector (0 downto 0) ;			-- Reconfig clk
      signal   reconfig_reset_19       : std_logic_vector (0 downto 0);
      signal   reconfig_write_19       : std_logic_vector (0 downto 0);
      signal   reconfig_read_19        : std_logic_vector (0 downto 0);
      signal   reconfig_address_19     : std_logic_vector (9 downto 0);
      signal   reconfig_writedata_19   : std_logic_vector (31 downto 0);
      signal   reconfig_readdata_19    : std_logic_vector (31 downto 0);
      signal   reconfig_waitrequest_19 : std_logic_vector (0 downto 0);

      signal   reconfig_clk_20			: std_logic_vector (0 downto 0) ;			-- Reconfig clk
      signal   reconfig_reset_20       : std_logic_vector (0 downto 0);
      signal   reconfig_write_20       : std_logic_vector (0 downto 0);
      signal   reconfig_read_20        : std_logic_vector (0 downto 0);
      signal   reconfig_address_20     : std_logic_vector (9 downto 0);
      signal   reconfig_writedata_20   : std_logic_vector (31 downto 0);
      signal   reconfig_readdata_20    : std_logic_vector (31 downto 0);
      signal   reconfig_waitrequest_20 : std_logic_vector (0 downto 0);

      signal   reconfig_clk_21			: std_logic_vector (0 downto 0) ;			-- Reconfig clk
      signal   reconfig_reset_21       : std_logic_vector (0 downto 0);
      signal   reconfig_write_21       : std_logic_vector (0 downto 0);
      signal   reconfig_read_21        : std_logic_vector (0 downto 0);
      signal   reconfig_address_21     : std_logic_vector (9 downto 0);
      signal   reconfig_writedata_21   : std_logic_vector (31 downto 0);
      signal   reconfig_readdata_21    : std_logic_vector (31 downto 0);
      signal   reconfig_waitrequest_21 : std_logic_vector (0 downto 0);

      signal   reconfig_clk_22			: std_logic_vector (0 downto 0) ;			-- Reconfig clk
      signal   reconfig_reset_22       : std_logic_vector (0 downto 0);
      signal   reconfig_write_22       : std_logic_vector (0 downto 0);
      signal   reconfig_read_22        : std_logic_vector (0 downto 0);
      signal   reconfig_address_22     : std_logic_vector (9 downto 0);
      signal   reconfig_writedata_22   : std_logic_vector (31 downto 0);
      signal   reconfig_readdata_22    : std_logic_vector (31 downto 0);
      signal   reconfig_waitrequest_22 : std_logic_vector (0 downto 0);

      signal   reconfig_clk_23			: std_logic_vector (0 downto 0) ;			-- Reconfig clk
      signal   reconfig_reset_23       : std_logic_vector (0 downto 0);
      signal   reconfig_write_23       : std_logic_vector (0 downto 0);
      signal   reconfig_read_23        : std_logic_vector (0 downto 0);
      signal   reconfig_address_23     : std_logic_vector (9 downto 0);
      signal   reconfig_writedata_23   : std_logic_vector (31 downto 0);
      signal   reconfig_readdata_23    : std_logic_vector (31 downto 0);
      signal   reconfig_waitrequest_23 : std_logic_vector (0 downto 0);


-- RECOVERED CLOCK
	  signal   rx_recovclkout     : std_logic ;
          signal   rx_recovclkout_0     : std_logic ;
          signal   rx_recovclkout_1     : std_logic ;
          signal   rx_recovclkout_2     : std_logic ;
          signal   rx_recovclkout_3     : std_logic ;
          signal   rx_recovclkout_4     : std_logic ;
          signal   rx_recovclkout_5     : std_logic ;
          signal   rx_recovclkout_6     : std_logic ;
          signal   rx_recovclkout_7     : std_logic ;
          signal   rx_recovclkout_8     : std_logic ;
          signal   rx_recovclkout_9     : std_logic ;
          signal   rx_recovclkout_10     : std_logic ;
          signal   rx_recovclkout_11     : std_logic ;
          signal   rx_recovclkout_12     : std_logic ;
          signal   rx_recovclkout_13     : std_logic ;
          signal   rx_recovclkout_14     : std_logic ;
          signal   rx_recovclkout_15     : std_logic ;
          signal   rx_recovclkout_16     : std_logic ;
          signal   rx_recovclkout_17     : std_logic ;
          signal   rx_recovclkout_18     : std_logic ;
          signal   rx_recovclkout_19     : std_logic ;
          signal   rx_recovclkout_20     : std_logic ;
          signal   rx_recovclkout_21     : std_logic ;
          signal   rx_recovclkout_22     : std_logic ;
          signal   rx_recovclkout_23     : std_logic ;
        signal   rxp_0              : std_logic ;                    --  Differential Receive Data 
        signal   txp_0              : std_logic ;                    --  Differential Receive Data 
        signal   gxb_pwrdn_in_0     : std_logic ;           --  Powerdown signal to GXB
        signal   pcs_pwrdn_out_0    : std_logic ;          --  Powerdown Enable from PCS
   
        signal   rxp_1              : std_logic ;                    --  Differential Receive Data 
        signal   txp_1              : std_logic ;                    --  Differential Receive Data 
        signal   gxb_pwrdn_in_1     : std_logic ;           --  Powerdown signal to GXB
        signal   pcs_pwrdn_out_1    : std_logic ;          --  Powerdown Enable from PCS
   
        signal   rxp_2              : std_logic ;                    --  Differential Receive Data 
        signal   txp_2              : std_logic ;                    --  Differential Receive Data 
        signal   gxb_pwrdn_in_2     : std_logic ;           --  Powerdown signal to GXB
        signal   pcs_pwrdn_out_2    : std_logic ;          --  Powerdown Enable from PCS
   
        signal   rxp_3              : std_logic ;                    --  Differential Receive Data 
        signal   txp_3              : std_logic ;                    --  Differential Receive Data 
        signal   gxb_pwrdn_in_3     : std_logic ;           --  Powerdown signal to GXB
        signal   pcs_pwrdn_out_3    : std_logic ;          --  Powerdown Enable from PCS
   
        signal   rxp_4              : std_logic ;                    --  Differential Receive Data 
        signal   txp_4              : std_logic ;                    --  Differential Receive Data 
        signal   gxb_pwrdn_in_4     : std_logic ;           --  Powerdown signal to GXB
        signal   pcs_pwrdn_out_4    : std_logic ;          --  Powerdown Enable from PCS
   
        signal   rxp_5              : std_logic ;                    --  Differential Receive Data 
        signal   txp_5              : std_logic ;                    --  Differential Receive Data 
        signal   gxb_pwrdn_in_5     : std_logic ;           --  Powerdown signal to GXB
        signal   pcs_pwrdn_out_5    : std_logic ;          --  Powerdown Enable from PCS
        signal   rxp_6              : std_logic ;                    --  Differential Receive Data 
        signal   txp_6              : std_logic ;                    --  Differential Receive Data 
        signal   gxb_pwrdn_in_6     : std_logic ;           --  Powerdown signal to GXB
        signal   pcs_pwrdn_out_6    : std_logic ;          --  Powerdown Enable from PCS
        signal   rxp_7              : std_logic ;                    --  Differential Receive Data 
        signal   txp_7              : std_logic ;                    --  Differential Receive Data 
        signal   gxb_pwrdn_in_7     : std_logic ;           --  Powerdown signal to GXB
        signal   pcs_pwrdn_out_7    : std_logic ;          --  Powerdown Enable from PCS
        signal   rxp_8              : std_logic ;                    --  Differential Receive Data 
        signal   txp_8              : std_logic ;                    --  Differential Receive Data 
        signal   gxb_pwrdn_in_8     : std_logic ;           --  Powerdown signal to GXB
        signal   pcs_pwrdn_out_8    : std_logic ;          --  Powerdown Enable from PCS
        signal   rxp_9              : std_logic ;                    --  Differential Receive Data 
        signal   txp_9              : std_logic ;                    --  Differential Receive Data 
        signal   gxb_pwrdn_in_9     : std_logic ;           --  Powerdown signal to GXB
        signal   pcs_pwrdn_out_9    : std_logic ;          --  Powerdown Enable from PCS
        signal   rxp_10             : std_logic ;                    --  Differential Receive Data 
        signal   txp_10             : std_logic ;                    --  Differential Receive Data 
        signal   gxb_pwrdn_in_10    : std_logic ;           --  Powerdown signal to GXB
        signal   pcs_pwrdn_out_10   : std_logic ;          --  Powerdown Enable from PCS
        signal   rxp_11             : std_logic ;                    --  Differential Receive Data 
        signal   txp_11             : std_logic ;                    --  Differential Receive Data 
        signal   gxb_pwrdn_in_11    : std_logic ;           --  Powerdown signal to GXB
        signal   pcs_pwrdn_out_11   : std_logic ;          --  Powerdown Enable from PCS
   
        signal   rxp_12             : std_logic ;                    --  Differential Receive Data 
        signal   txp_12             : std_logic ;                    --  Differential Receive Data 
        signal   gxb_pwrdn_in_12    : std_logic ;           --  Powerdown signal to GXB
        signal   pcs_pwrdn_out_12   : std_logic ;          --  Powerdown Enable from PCS
        signal   rxp_13             : std_logic ;                    --  Differential Receive Data 
        signal   txp_13             : std_logic ;                    --  Differential Receive Data 
        signal   gxb_pwrdn_in_13    : std_logic ;           --  Powerdown signal to GXB
        signal   pcs_pwrdn_out_13   : std_logic ;          --  Powerdown Enable from PCS
        signal   rxp_14             : std_logic ;                    --  Differential Receive Data 
        signal   txp_14             : std_logic ;                    --  Differential Receive Data 
        signal   gxb_pwrdn_in_14    : std_logic ;           --  Powerdown signal to GXB
        signal   pcs_pwrdn_out_14   : std_logic ;          --  Powerdown Enable from PCS
        signal   rxp_15             : std_logic ;                    --  Differential Receive Data 
        signal   txp_15             : std_logic ;                    --  Differential Receive Data 
        signal   gxb_pwrdn_in_15    : std_logic ;           --  Powerdown signal to GXB
        signal   pcs_pwrdn_out_15   : std_logic ;          --  Powerdown Enable from PCS
        signal   rxp_16             : std_logic ;                    --  Differential Receive Data 
        signal   txp_16             : std_logic ;                    --  Differential Receive Data 
        signal   gxb_pwrdn_in_16    : std_logic ;           --  Powerdown signal to GXB
        signal   pcs_pwrdn_out_16   : std_logic ;          --  Powerdown Enable from PCS
        signal   rxp_17             : std_logic ;                    --  Differential Receive Data 
        signal   txp_17             : std_logic ;                    --  Differential Receive Data 
        signal   gxb_pwrdn_in_17    : std_logic ;           --  Powerdown signal to GXB
        signal   pcs_pwrdn_out_17   : std_logic ;          --  Powerdown Enable from PCS
        signal   rxp_18             : std_logic ;                    --  Differential Receive Data 
        signal   txp_18             : std_logic ;                    --  Differential Receive Data 
        signal   gxb_pwrdn_in_18    : std_logic ;           --  Powerdown signal to GXB
        signal   pcs_pwrdn_out_18   : std_logic ;          --  Powerdown Enable from PCS
        signal   rxp_19             : std_logic ;                    --  Differential Receive Data 
        signal   txp_19             : std_logic ;                    --  Differential Receive Data 
        signal   gxb_pwrdn_in_19    : std_logic ;           --  Powerdown signal to GXB
        signal   pcs_pwrdn_out_19   : std_logic ;          --  Powerdown Enable from PCS
        signal   rxp_20             : std_logic ;                    --  Differential Receive Data 
        signal   txp_20             : std_logic ;                    --  Differential Receive Data 
        signal   gxb_pwrdn_in_20    : std_logic ;           --  Powerdown signal to GXB
        signal   pcs_pwrdn_out_20   : std_logic ;          --  Powerdown Enable from PCS
        signal   rxp_21             : std_logic ;                    --  Differential Receive Data 
        signal   txp_21             : std_logic ;                    --  Differential Receive Data 
        signal   gxb_pwrdn_in_21    : std_logic ;           --  Powerdown signal to GXB
        signal   pcs_pwrdn_out_21   : std_logic ;          --  Powerdown Enable from PCS
        signal   rxp_22             : std_logic ;                    --  Differential Receive Data 
        signal   txp_22             : std_logic ;                    --  Differential Receive Data 
        signal   gxb_pwrdn_in_22    : std_logic ;           --  Powerdown signal to GXB
        signal   pcs_pwrdn_out_22   : std_logic ;          --  Powerdown Enable from PCS
        signal   rxp_23             : std_logic ;                    --  Differential Receive Data 
        signal   txp_23             : std_logic ;                    --  Differential Receive Data 
        signal   gxb_pwrdn_in_23    : std_logic ;           --  Powerdown signal to GXB
        signal   pcs_pwrdn_out_23   : std_logic ;          --  Powerdown Enable from PCS
		
	
        -- Timestamping
        signal   pcs_phase_measure_clk                  : std_logic;                        -- Input
        
        signal   rx_time_of_day_96b_data_0                  		: std_logic_vector (95 downto 0);   -- Input
        signal   rx_time_of_day_64b_data_0                  		: std_logic_vector (63 downto 0);   -- Input
		signal   rx_ingress_timestamp_96b_valid_0           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_64b_valid_0           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_96b_data_0            		: std_logic_vector (95 downto 0);   -- Output
		signal   rx_ingress_timestamp_64b_data_0            		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_time_of_day_96b_data_0                  		: std_logic_vector (95 downto 0);   -- Input
		signal   tx_time_of_day_64b_data_0                  		: std_logic_vector (63 downto 0);   -- Input
		signal   tx_egress_timestamp_96b_valid_0            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_64b_valid_0            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_96b_data_0             		: std_logic_vector (95 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_data_0             		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_egress_timestamp_96b_fingerprint_0             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_fingerprint_0             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_request_valid_0    			: std_logic;                        -- Input
		signal   tx_egress_timestamp_request_fingerprint_0     		: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);    -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_96b_0        : std_logic_vector (95 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_64b_0        : std_logic_vector (63 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_timestamp_insert_0    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_update_0    	: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_zero_0    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_correct_0    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_calc_format_0   : std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_timestamp_format_0    			: std_logic;                        -- Input
		signal   tx_etstamp_ins_ctrl_offset_timestamp_0            	: std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_correction_field_0      : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_field_0        : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_correction_0   : std_logic_vector (15 downto 0);   -- Input

        signal   rx_time_of_day_96b_data_1                  		: std_logic_vector (95 downto 0);   -- Input
        signal   rx_time_of_day_64b_data_1                  		: std_logic_vector (63 downto 0);   -- Input
		signal   rx_ingress_timestamp_96b_valid_1           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_64b_valid_1           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_96b_data_1            		: std_logic_vector (95 downto 0);   -- Output
		signal   rx_ingress_timestamp_64b_data_1            		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_time_of_day_96b_data_1                  		: std_logic_vector (95 downto 0);   -- Input
		signal   tx_time_of_day_64b_data_1                  		: std_logic_vector (63 downto 0);   -- Input
		signal   tx_egress_timestamp_96b_valid_1            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_64b_valid_1            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_96b_data_1             		: std_logic_vector (95 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_data_1             		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_egress_timestamp_96b_fingerprint_1             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_fingerprint_1             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_request_valid_1    			: std_logic;                        -- Input
		signal   tx_egress_timestamp_request_fingerprint_1     		: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);    -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_96b_1        : std_logic_vector (95 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_64b_1        : std_logic_vector (63 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_timestamp_insert_1    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_update_1    	: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_zero_1    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_correct_1    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_calc_format_1   : std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_timestamp_format_1    			: std_logic;                        -- Input
		signal   tx_etstamp_ins_ctrl_offset_timestamp_1            	: std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_correction_field_1      : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_field_1        : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_correction_1   : std_logic_vector (15 downto 0);   -- Input

        signal   rx_time_of_day_96b_data_2                  		: std_logic_vector (95 downto 0);   -- Input
        signal   rx_time_of_day_64b_data_2                  		: std_logic_vector (63 downto 0);   -- Input
		signal   rx_ingress_timestamp_96b_valid_2           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_64b_valid_2           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_96b_data_2            		: std_logic_vector (95 downto 0);   -- Output
		signal   rx_ingress_timestamp_64b_data_2            		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_time_of_day_96b_data_2                  		: std_logic_vector (95 downto 0);   -- Input
		signal   tx_time_of_day_64b_data_2                  		: std_logic_vector (63 downto 0);   -- Input
		signal   tx_egress_timestamp_96b_valid_2            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_64b_valid_2            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_96b_data_2             		: std_logic_vector (95 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_data_2             		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_egress_timestamp_96b_fingerprint_2             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_fingerprint_2             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_request_valid_2    			: std_logic;                        -- Input
		signal   tx_egress_timestamp_request_fingerprint_2     		: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);    -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_96b_2        : std_logic_vector (95 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_64b_2        : std_logic_vector (63 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_timestamp_insert_2    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_update_2    	: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_zero_2    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_correct_2    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_calc_format_2   : std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_timestamp_format_2    			: std_logic;                        -- Input
		signal   tx_etstamp_ins_ctrl_offset_timestamp_2            	: std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_correction_field_2      : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_field_2        : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_correction_2   : std_logic_vector (15 downto 0);   -- Input

        signal   rx_time_of_day_96b_data_3                  		: std_logic_vector (95 downto 0);   -- Input
        signal   rx_time_of_day_64b_data_3                  		: std_logic_vector (63 downto 0);   -- Input
		signal   rx_ingress_timestamp_96b_valid_3           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_64b_valid_3           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_96b_data_3            		: std_logic_vector (95 downto 0);   -- Output
		signal   rx_ingress_timestamp_64b_data_3            		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_time_of_day_96b_data_3                  		: std_logic_vector (95 downto 0);   -- Input
		signal   tx_time_of_day_64b_data_3                  		: std_logic_vector (63 downto 0);   -- Input
		signal   tx_egress_timestamp_96b_valid_3            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_64b_valid_3            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_96b_data_3             		: std_logic_vector (95 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_data_3             		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_egress_timestamp_96b_fingerprint_3             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_fingerprint_3             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_request_valid_3    			: std_logic;                        -- Input
		signal   tx_egress_timestamp_request_fingerprint_3     		: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);    -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_96b_3        : std_logic_vector (95 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_64b_3        : std_logic_vector (63 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_timestamp_insert_3    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_update_3    	: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_zero_3    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_correct_3    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_calc_format_3   : std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_timestamp_format_3    			: std_logic;                        -- Input
		signal   tx_etstamp_ins_ctrl_offset_timestamp_3            	: std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_correction_field_3      : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_field_3        : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_correction_3   : std_logic_vector (15 downto 0);   -- Input

        signal   rx_time_of_day_96b_data_4                  		: std_logic_vector (95 downto 0);   -- Input
        signal   rx_time_of_day_64b_data_4                  		: std_logic_vector (63 downto 0);   -- Input
		signal   rx_ingress_timestamp_96b_valid_4           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_64b_valid_4           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_96b_data_4            		: std_logic_vector (95 downto 0);   -- Output
		signal   rx_ingress_timestamp_64b_data_4            		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_time_of_day_96b_data_4                  		: std_logic_vector (95 downto 0);   -- Input
		signal   tx_time_of_day_64b_data_4                  		: std_logic_vector (63 downto 0);   -- Input
		signal   tx_egress_timestamp_96b_valid_4            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_64b_valid_4            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_96b_data_4             		: std_logic_vector (95 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_data_4             		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_egress_timestamp_96b_fingerprint_4             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_fingerprint_4             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_request_valid_4    			: std_logic;                        -- Input
		signal   tx_egress_timestamp_request_fingerprint_4     		: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);    -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_96b_4        : std_logic_vector (95 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_64b_4        : std_logic_vector (63 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_timestamp_insert_4    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_update_4    	: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_zero_4    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_correct_4    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_calc_format_4   : std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_timestamp_format_4    			: std_logic;                        -- Input
		signal   tx_etstamp_ins_ctrl_offset_timestamp_4            	: std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_correction_field_4      : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_field_4        : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_correction_4   : std_logic_vector (15 downto 0);   -- Input

        signal   rx_time_of_day_96b_data_5                  		: std_logic_vector (95 downto 0);   -- Input
        signal   rx_time_of_day_64b_data_5                  		: std_logic_vector (63 downto 0);   -- Input
		signal   rx_ingress_timestamp_96b_valid_5           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_64b_valid_5           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_96b_data_5            		: std_logic_vector (95 downto 0);   -- Output
		signal   rx_ingress_timestamp_64b_data_5            		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_time_of_day_96b_data_5                  		: std_logic_vector (95 downto 0);   -- Input
		signal   tx_time_of_day_64b_data_5                  		: std_logic_vector (63 downto 0);   -- Input
		signal   tx_egress_timestamp_96b_valid_5            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_64b_valid_5            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_96b_data_5             		: std_logic_vector (95 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_data_5             		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_egress_timestamp_96b_fingerprint_5             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_fingerprint_5             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_request_valid_5    			: std_logic;                        -- Input
		signal   tx_egress_timestamp_request_fingerprint_5     		: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);    -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_96b_5        : std_logic_vector (95 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_64b_5        : std_logic_vector (63 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_timestamp_insert_5    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_update_5    	: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_zero_5    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_correct_5    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_calc_format_5   : std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_timestamp_format_5    			: std_logic;                        -- Input
		signal   tx_etstamp_ins_ctrl_offset_timestamp_5            	: std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_correction_field_5      : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_field_5        : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_correction_5   : std_logic_vector (15 downto 0);   -- Input

        signal   rx_time_of_day_96b_data_6                  		: std_logic_vector (95 downto 0);   -- Input
        signal   rx_time_of_day_64b_data_6                  		: std_logic_vector (63 downto 0);   -- Input
		signal   rx_ingress_timestamp_96b_valid_6           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_64b_valid_6           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_96b_data_6            		: std_logic_vector (95 downto 0);   -- Output
		signal   rx_ingress_timestamp_64b_data_6            		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_time_of_day_96b_data_6                  		: std_logic_vector (95 downto 0);   -- Input
		signal   tx_time_of_day_64b_data_6                  		: std_logic_vector (63 downto 0);   -- Input
		signal   tx_egress_timestamp_96b_valid_6            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_64b_valid_6            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_96b_data_6             		: std_logic_vector (95 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_data_6             		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_egress_timestamp_96b_fingerprint_6             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_fingerprint_6             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_request_valid_6    			: std_logic;                        -- Input
		signal   tx_egress_timestamp_request_fingerprint_6     		: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);    -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_96b_6        : std_logic_vector (95 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_64b_6        : std_logic_vector (63 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_timestamp_insert_6    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_update_6    	: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_zero_6    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_correct_6    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_calc_format_6   : std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_timestamp_format_6    			: std_logic;                        -- Input
		signal   tx_etstamp_ins_ctrl_offset_timestamp_6            	: std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_correction_field_6      : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_field_6        : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_correction_6   : std_logic_vector (15 downto 0);   -- Input

        signal   rx_time_of_day_96b_data_7                  		: std_logic_vector (95 downto 0);   -- Input
        signal   rx_time_of_day_64b_data_7                  		: std_logic_vector (63 downto 0);   -- Input
		signal   rx_ingress_timestamp_96b_valid_7           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_64b_valid_7           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_96b_data_7            		: std_logic_vector (95 downto 0);   -- Output
		signal   rx_ingress_timestamp_64b_data_7            		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_time_of_day_96b_data_7                  		: std_logic_vector (95 downto 0);   -- Input
		signal   tx_time_of_day_64b_data_7                  		: std_logic_vector (63 downto 0);   -- Input
		signal   tx_egress_timestamp_96b_valid_7            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_64b_valid_7            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_96b_data_7             		: std_logic_vector (95 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_data_7             		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_egress_timestamp_96b_fingerprint_7             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_fingerprint_7             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_request_valid_7    			: std_logic;                        -- Input
		signal   tx_egress_timestamp_request_fingerprint_7     		: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);    -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_96b_7        : std_logic_vector (95 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_64b_7        : std_logic_vector (63 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_timestamp_insert_7    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_update_7    	: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_zero_7    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_correct_7    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_calc_format_7   : std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_timestamp_format_7    			: std_logic;                        -- Input
		signal   tx_etstamp_ins_ctrl_offset_timestamp_7            	: std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_correction_field_7      : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_field_7        : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_correction_7   : std_logic_vector (15 downto 0);   -- Input

        signal   rx_time_of_day_96b_data_8                  		: std_logic_vector (95 downto 0);   -- Input
        signal   rx_time_of_day_64b_data_8                  		: std_logic_vector (63 downto 0);   -- Input
		signal   rx_ingress_timestamp_96b_valid_8           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_64b_valid_8           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_96b_data_8            		: std_logic_vector (95 downto 0);   -- Output
		signal   rx_ingress_timestamp_64b_data_8            		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_time_of_day_96b_data_8                  		: std_logic_vector (95 downto 0);   -- Input
		signal   tx_time_of_day_64b_data_8                  		: std_logic_vector (63 downto 0);   -- Input
		signal   tx_egress_timestamp_96b_valid_8            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_64b_valid_8            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_96b_data_8             		: std_logic_vector (95 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_data_8             		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_egress_timestamp_96b_fingerprint_8             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_fingerprint_8             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_request_valid_8    			: std_logic;                        -- Input
		signal   tx_egress_timestamp_request_fingerprint_8     		: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);    -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_96b_8        : std_logic_vector (95 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_64b_8        : std_logic_vector (63 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_timestamp_insert_8    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_update_8    	: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_zero_8    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_correct_8    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_calc_format_8   : std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_timestamp_format_8    			: std_logic;                        -- Input
		signal   tx_etstamp_ins_ctrl_offset_timestamp_8            	: std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_correction_field_8      : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_field_8        : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_correction_8   : std_logic_vector (15 downto 0);   -- Input

        signal   rx_time_of_day_96b_data_9                  		: std_logic_vector (95 downto 0);   -- Input
        signal   rx_time_of_day_64b_data_9                  		: std_logic_vector (63 downto 0);   -- Input
		signal   rx_ingress_timestamp_96b_valid_9           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_64b_valid_9           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_96b_data_9            		: std_logic_vector (95 downto 0);   -- Output
		signal   rx_ingress_timestamp_64b_data_9            		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_time_of_day_96b_data_9                  		: std_logic_vector (95 downto 0);   -- Input
		signal   tx_time_of_day_64b_data_9                  		: std_logic_vector (63 downto 0);   -- Input
		signal   tx_egress_timestamp_96b_valid_9            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_64b_valid_9            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_96b_data_9             		: std_logic_vector (95 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_data_9             		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_egress_timestamp_96b_fingerprint_9             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_fingerprint_9             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_request_valid_9    			: std_logic;                        -- Input
		signal   tx_egress_timestamp_request_fingerprint_9     		: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);    -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_96b_9        : std_logic_vector (95 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_64b_9        : std_logic_vector (63 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_timestamp_insert_9    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_update_9    	: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_zero_9    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_correct_9    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_calc_format_9   : std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_timestamp_format_9    			: std_logic;                        -- Input
		signal   tx_etstamp_ins_ctrl_offset_timestamp_9            	: std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_correction_field_9      : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_field_9        : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_correction_9   : std_logic_vector (15 downto 0);   -- Input

        signal   rx_time_of_day_96b_data_10                  		: std_logic_vector (95 downto 0);   -- Input
        signal   rx_time_of_day_64b_data_10                  		: std_logic_vector (63 downto 0);   -- Input
		signal   rx_ingress_timestamp_96b_valid_10           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_64b_valid_10           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_96b_data_10            		: std_logic_vector (95 downto 0);   -- Output
		signal   rx_ingress_timestamp_64b_data_10            		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_time_of_day_96b_data_10                  		: std_logic_vector (95 downto 0);   -- Input
		signal   tx_time_of_day_64b_data_10                  		: std_logic_vector (63 downto 0);   -- Input
		signal   tx_egress_timestamp_96b_valid_10            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_64b_valid_10            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_96b_data_10             		: std_logic_vector (95 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_data_10             		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_egress_timestamp_96b_fingerprint_10             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_fingerprint_10             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_request_valid_10    			: std_logic;                        -- Input
		signal   tx_egress_timestamp_request_fingerprint_10     		: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);    -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_96b_10        : std_logic_vector (95 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_64b_10        : std_logic_vector (63 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_timestamp_insert_10    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_update_10    	: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_zero_10    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_correct_10    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_calc_format_10   : std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_timestamp_format_10    			: std_logic;                        -- Input
		signal   tx_etstamp_ins_ctrl_offset_timestamp_10            	: std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_correction_field_10      : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_field_10        : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_correction_10   : std_logic_vector (15 downto 0);   -- Input

        signal   rx_time_of_day_96b_data_11                  		: std_logic_vector (95 downto 0);   -- Input
        signal   rx_time_of_day_64b_data_11                  		: std_logic_vector (63 downto 0);   -- Input
		signal   rx_ingress_timestamp_96b_valid_11           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_64b_valid_11           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_96b_data_11            		: std_logic_vector (95 downto 0);   -- Output
		signal   rx_ingress_timestamp_64b_data_11            		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_time_of_day_96b_data_11                  		: std_logic_vector (95 downto 0);   -- Input
		signal   tx_time_of_day_64b_data_11                  		: std_logic_vector (63 downto 0);   -- Input
		signal   tx_egress_timestamp_96b_valid_11            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_64b_valid_11            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_96b_data_11             		: std_logic_vector (95 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_data_11             		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_egress_timestamp_96b_fingerprint_11             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_fingerprint_11             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_request_valid_11    			: std_logic;                        -- Input
		signal   tx_egress_timestamp_request_fingerprint_11     		: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);    -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_96b_11        : std_logic_vector (95 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_64b_11        : std_logic_vector (63 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_timestamp_insert_11    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_update_11    	: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_zero_11    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_correct_11    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_calc_format_11   : std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_timestamp_format_11    			: std_logic;                        -- Input
		signal   tx_etstamp_ins_ctrl_offset_timestamp_11            	: std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_correction_field_11      : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_field_11        : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_correction_11   : std_logic_vector (15 downto 0);   -- Input

        signal   rx_time_of_day_96b_data_12                  		: std_logic_vector (95 downto 0);   -- Input
        signal   rx_time_of_day_64b_data_12                  		: std_logic_vector (63 downto 0);   -- Input
		signal   rx_ingress_timestamp_96b_valid_12           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_64b_valid_12           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_96b_data_12            		: std_logic_vector (95 downto 0);   -- Output
		signal   rx_ingress_timestamp_64b_data_12            		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_time_of_day_96b_data_12                  		: std_logic_vector (95 downto 0);   -- Input
		signal   tx_time_of_day_64b_data_12                  		: std_logic_vector (63 downto 0);   -- Input
		signal   tx_egress_timestamp_96b_valid_12            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_64b_valid_12            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_96b_data_12             		: std_logic_vector (95 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_data_12             		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_egress_timestamp_96b_fingerprint_12             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_fingerprint_12             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_request_valid_12    			: std_logic;                        -- Input
		signal   tx_egress_timestamp_request_fingerprint_12     		: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);    -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_96b_12        : std_logic_vector (95 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_64b_12        : std_logic_vector (63 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_timestamp_insert_12    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_update_12    	: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_zero_12    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_correct_12    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_calc_format_12   : std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_timestamp_format_12    			: std_logic;                        -- Input
		signal   tx_etstamp_ins_ctrl_offset_timestamp_12            	: std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_correction_field_12      : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_field_12        : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_correction_12   : std_logic_vector (15 downto 0);   -- Input

        signal   rx_time_of_day_96b_data_13                  		: std_logic_vector (95 downto 0);   -- Input
        signal   rx_time_of_day_64b_data_13                  		: std_logic_vector (63 downto 0);   -- Input
		signal   rx_ingress_timestamp_96b_valid_13           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_64b_valid_13           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_96b_data_13            		: std_logic_vector (95 downto 0);   -- Output
		signal   rx_ingress_timestamp_64b_data_13            		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_time_of_day_96b_data_13                  		: std_logic_vector (95 downto 0);   -- Input
		signal   tx_time_of_day_64b_data_13                  		: std_logic_vector (63 downto 0);   -- Input
		signal   tx_egress_timestamp_96b_valid_13            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_64b_valid_13            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_96b_data_13             		: std_logic_vector (95 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_data_13             		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_egress_timestamp_96b_fingerprint_13             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_fingerprint_13             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_request_valid_13    			: std_logic;                        -- Input
		signal   tx_egress_timestamp_request_fingerprint_13     		: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);    -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_96b_13        : std_logic_vector (95 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_64b_13        : std_logic_vector (63 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_timestamp_insert_13    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_update_13    	: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_zero_13    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_correct_13    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_calc_format_13   : std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_timestamp_format_13    			: std_logic;                        -- Input
		signal   tx_etstamp_ins_ctrl_offset_timestamp_13            	: std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_correction_field_13      : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_field_13        : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_correction_13   : std_logic_vector (15 downto 0);   -- Input

        signal   rx_time_of_day_96b_data_14                  		: std_logic_vector (95 downto 0);   -- Input
        signal   rx_time_of_day_64b_data_14                  		: std_logic_vector (63 downto 0);   -- Input
		signal   rx_ingress_timestamp_96b_valid_14           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_64b_valid_14           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_96b_data_14            		: std_logic_vector (95 downto 0);   -- Output
		signal   rx_ingress_timestamp_64b_data_14            		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_time_of_day_96b_data_14                  		: std_logic_vector (95 downto 0);   -- Input
		signal   tx_time_of_day_64b_data_14                  		: std_logic_vector (63 downto 0);   -- Input
		signal   tx_egress_timestamp_96b_valid_14            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_64b_valid_14            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_96b_data_14             		: std_logic_vector (95 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_data_14             		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_egress_timestamp_96b_fingerprint_14             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_fingerprint_14             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_request_valid_14    			: std_logic;                        -- Input
		signal   tx_egress_timestamp_request_fingerprint_14     		: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);    -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_96b_14        : std_logic_vector (95 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_64b_14        : std_logic_vector (63 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_timestamp_insert_14    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_update_14    	: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_zero_14    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_correct_14    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_calc_format_14   : std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_timestamp_format_14    			: std_logic;                        -- Input
		signal   tx_etstamp_ins_ctrl_offset_timestamp_14            	: std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_correction_field_14      : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_field_14        : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_correction_14   : std_logic_vector (15 downto 0);   -- Input

        signal   rx_time_of_day_96b_data_15                  		: std_logic_vector (95 downto 0);   -- Input
        signal   rx_time_of_day_64b_data_15                  		: std_logic_vector (63 downto 0);   -- Input
		signal   rx_ingress_timestamp_96b_valid_15           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_64b_valid_15           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_96b_data_15            		: std_logic_vector (95 downto 0);   -- Output
		signal   rx_ingress_timestamp_64b_data_15            		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_time_of_day_96b_data_15                  		: std_logic_vector (95 downto 0);   -- Input
		signal   tx_time_of_day_64b_data_15                  		: std_logic_vector (63 downto 0);   -- Input
		signal   tx_egress_timestamp_96b_valid_15            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_64b_valid_15            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_96b_data_15             		: std_logic_vector (95 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_data_15             		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_egress_timestamp_96b_fingerprint_15             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_fingerprint_15             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_request_valid_15    			: std_logic;                        -- Input
		signal   tx_egress_timestamp_request_fingerprint_15     		: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);    -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_96b_15        : std_logic_vector (95 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_64b_15        : std_logic_vector (63 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_timestamp_insert_15    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_update_15    	: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_zero_15    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_correct_15    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_calc_format_15   : std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_timestamp_format_15    			: std_logic;                        -- Input
		signal   tx_etstamp_ins_ctrl_offset_timestamp_15            	: std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_correction_field_15      : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_field_15        : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_correction_15   : std_logic_vector (15 downto 0);   -- Input

        signal   rx_time_of_day_96b_data_16                  		: std_logic_vector (95 downto 0);   -- Input
        signal   rx_time_of_day_64b_data_16                  		: std_logic_vector (63 downto 0);   -- Input
		signal   rx_ingress_timestamp_96b_valid_16           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_64b_valid_16           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_96b_data_16            		: std_logic_vector (95 downto 0);   -- Output
		signal   rx_ingress_timestamp_64b_data_16            		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_time_of_day_96b_data_16                  		: std_logic_vector (95 downto 0);   -- Input
		signal   tx_time_of_day_64b_data_16                  		: std_logic_vector (63 downto 0);   -- Input
		signal   tx_egress_timestamp_96b_valid_16            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_64b_valid_16            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_96b_data_16             		: std_logic_vector (95 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_data_16             		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_egress_timestamp_96b_fingerprint_16             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_fingerprint_16             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_request_valid_16    			: std_logic;                        -- Input
		signal   tx_egress_timestamp_request_fingerprint_16     		: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);    -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_96b_16        : std_logic_vector (95 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_64b_16        : std_logic_vector (63 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_timestamp_insert_16    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_update_16    	: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_zero_16    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_correct_16    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_calc_format_16   : std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_timestamp_format_16    			: std_logic;                        -- Input
		signal   tx_etstamp_ins_ctrl_offset_timestamp_16            	: std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_correction_field_16      : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_field_16        : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_correction_16   : std_logic_vector (15 downto 0);   -- Input

        signal   rx_time_of_day_96b_data_17                  		: std_logic_vector (95 downto 0);   -- Input
        signal   rx_time_of_day_64b_data_17                  		: std_logic_vector (63 downto 0);   -- Input
		signal   rx_ingress_timestamp_96b_valid_17           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_64b_valid_17           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_96b_data_17            		: std_logic_vector (95 downto 0);   -- Output
		signal   rx_ingress_timestamp_64b_data_17            		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_time_of_day_96b_data_17                  		: std_logic_vector (95 downto 0);   -- Input
		signal   tx_time_of_day_64b_data_17                  		: std_logic_vector (63 downto 0);   -- Input
		signal   tx_egress_timestamp_96b_valid_17            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_64b_valid_17            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_96b_data_17             		: std_logic_vector (95 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_data_17             		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_egress_timestamp_96b_fingerprint_17             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_fingerprint_17             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_request_valid_17    			: std_logic;                        -- Input
		signal   tx_egress_timestamp_request_fingerprint_17     		: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);    -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_96b_17        : std_logic_vector (95 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_64b_17        : std_logic_vector (63 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_timestamp_insert_17    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_update_17    	: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_zero_17    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_correct_17    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_calc_format_17   : std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_timestamp_format_17    			: std_logic;                        -- Input
		signal   tx_etstamp_ins_ctrl_offset_timestamp_17            	: std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_correction_field_17      : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_field_17        : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_correction_17   : std_logic_vector (15 downto 0);   -- Input

        signal   rx_time_of_day_96b_data_18                  		: std_logic_vector (95 downto 0);   -- Input
        signal   rx_time_of_day_64b_data_18                  		: std_logic_vector (63 downto 0);   -- Input
		signal   rx_ingress_timestamp_96b_valid_18           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_64b_valid_18           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_96b_data_18            		: std_logic_vector (95 downto 0);   -- Output
		signal   rx_ingress_timestamp_64b_data_18            		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_time_of_day_96b_data_18                  		: std_logic_vector (95 downto 0);   -- Input
		signal   tx_time_of_day_64b_data_18                  		: std_logic_vector (63 downto 0);   -- Input
		signal   tx_egress_timestamp_96b_valid_18            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_64b_valid_18            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_96b_data_18             		: std_logic_vector (95 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_data_18             		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_egress_timestamp_96b_fingerprint_18             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_fingerprint_18             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_request_valid_18    			: std_logic;                        -- Input
		signal   tx_egress_timestamp_request_fingerprint_18     		: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);    -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_96b_18        : std_logic_vector (95 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_64b_18        : std_logic_vector (63 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_timestamp_insert_18    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_update_18    	: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_zero_18    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_correct_18    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_calc_format_18   : std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_timestamp_format_18    			: std_logic;                        -- Input
		signal   tx_etstamp_ins_ctrl_offset_timestamp_18            	: std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_correction_field_18      : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_field_18        : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_correction_18   : std_logic_vector (15 downto 0);   -- Input

        signal   rx_time_of_day_96b_data_19                  		: std_logic_vector (95 downto 0);   -- Input
        signal   rx_time_of_day_64b_data_19                  		: std_logic_vector (63 downto 0);   -- Input
		signal   rx_ingress_timestamp_96b_valid_19           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_64b_valid_19           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_96b_data_19            		: std_logic_vector (95 downto 0);   -- Output
		signal   rx_ingress_timestamp_64b_data_19            		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_time_of_day_96b_data_19                  		: std_logic_vector (95 downto 0);   -- Input
		signal   tx_time_of_day_64b_data_19                  		: std_logic_vector (63 downto 0);   -- Input
		signal   tx_egress_timestamp_96b_valid_19            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_64b_valid_19            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_96b_data_19             		: std_logic_vector (95 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_data_19             		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_egress_timestamp_96b_fingerprint_19             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_fingerprint_19             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_request_valid_19    			: std_logic;                        -- Input
		signal   tx_egress_timestamp_request_fingerprint_19     		: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);    -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_96b_19        : std_logic_vector (95 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_64b_19        : std_logic_vector (63 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_timestamp_insert_19    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_update_19    	: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_zero_19    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_correct_19    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_calc_format_19   : std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_timestamp_format_19    			: std_logic;                        -- Input
		signal   tx_etstamp_ins_ctrl_offset_timestamp_19            	: std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_correction_field_19      : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_field_19        : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_correction_19   : std_logic_vector (15 downto 0);   -- Input

        signal   rx_time_of_day_96b_data_20                  		: std_logic_vector (95 downto 0);   -- Input
        signal   rx_time_of_day_64b_data_20                  		: std_logic_vector (63 downto 0);   -- Input
		signal   rx_ingress_timestamp_96b_valid_20           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_64b_valid_20           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_96b_data_20            		: std_logic_vector (95 downto 0);   -- Output
		signal   rx_ingress_timestamp_64b_data_20            		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_time_of_day_96b_data_20                  		: std_logic_vector (95 downto 0);   -- Input
		signal   tx_time_of_day_64b_data_20                  		: std_logic_vector (63 downto 0);   -- Input
		signal   tx_egress_timestamp_96b_valid_20            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_64b_valid_20            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_96b_data_20             		: std_logic_vector (95 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_data_20             		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_egress_timestamp_96b_fingerprint_20             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_fingerprint_20             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_request_valid_20    			: std_logic;                        -- Input
		signal   tx_egress_timestamp_request_fingerprint_20     		: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);    -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_96b_20        : std_logic_vector (95 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_64b_20        : std_logic_vector (63 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_timestamp_insert_20    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_update_20    	: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_zero_20    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_correct_20    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_calc_format_20   : std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_timestamp_format_20    			: std_logic;                        -- Input
		signal   tx_etstamp_ins_ctrl_offset_timestamp_20            	: std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_correction_field_20      : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_field_20        : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_correction_20   : std_logic_vector (15 downto 0);   -- Input

        signal   rx_time_of_day_96b_data_21                  		: std_logic_vector (95 downto 0);   -- Input
        signal   rx_time_of_day_64b_data_21                  		: std_logic_vector (63 downto 0);   -- Input
		signal   rx_ingress_timestamp_96b_valid_21           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_64b_valid_21           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_96b_data_21            		: std_logic_vector (95 downto 0);   -- Output
		signal   rx_ingress_timestamp_64b_data_21            		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_time_of_day_96b_data_21                  		: std_logic_vector (95 downto 0);   -- Input
		signal   tx_time_of_day_64b_data_21                  		: std_logic_vector (63 downto 0);   -- Input
		signal   tx_egress_timestamp_96b_valid_21            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_64b_valid_21            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_96b_data_21             		: std_logic_vector (95 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_data_21             		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_egress_timestamp_96b_fingerprint_21             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_fingerprint_21             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_request_valid_21    			: std_logic;                        -- Input
		signal   tx_egress_timestamp_request_fingerprint_21     		: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);    -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_96b_21        : std_logic_vector (95 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_64b_21        : std_logic_vector (63 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_timestamp_insert_21    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_update_21    	: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_zero_21    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_correct_21    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_calc_format_21   : std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_timestamp_format_21    			: std_logic;                        -- Input
		signal   tx_etstamp_ins_ctrl_offset_timestamp_21            	: std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_correction_field_21      : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_field_21        : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_correction_21   : std_logic_vector (15 downto 0);   -- Input

        signal   rx_time_of_day_96b_data_22                  		: std_logic_vector (95 downto 0);   -- Input
        signal   rx_time_of_day_64b_data_22                  		: std_logic_vector (63 downto 0);   -- Input
		signal   rx_ingress_timestamp_96b_valid_22           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_64b_valid_22           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_96b_data_22            		: std_logic_vector (95 downto 0);   -- Output
		signal   rx_ingress_timestamp_64b_data_22            		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_time_of_day_96b_data_22                  		: std_logic_vector (95 downto 0);   -- Input
		signal   tx_time_of_day_64b_data_22                  		: std_logic_vector (63 downto 0);   -- Input
		signal   tx_egress_timestamp_96b_valid_22            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_64b_valid_22            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_96b_data_22             		: std_logic_vector (95 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_data_22             		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_egress_timestamp_96b_fingerprint_22             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_fingerprint_22             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_request_valid_22    			: std_logic;                        -- Input
		signal   tx_egress_timestamp_request_fingerprint_22     		: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);    -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_96b_22        : std_logic_vector (95 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_64b_22        : std_logic_vector (63 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_timestamp_insert_22    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_update_22    	: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_zero_22    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_correct_22    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_calc_format_22   : std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_timestamp_format_22    			: std_logic;                        -- Input
		signal   tx_etstamp_ins_ctrl_offset_timestamp_22            	: std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_correction_field_22      : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_field_22        : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_correction_22   : std_logic_vector (15 downto 0);   -- Input

        signal   rx_time_of_day_96b_data_23                  		: std_logic_vector (95 downto 0);   -- Input
        signal   rx_time_of_day_64b_data_23                  		: std_logic_vector (63 downto 0);   -- Input
		signal   rx_ingress_timestamp_96b_valid_23           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_64b_valid_23           		: std_logic;                        -- Output
		signal   rx_ingress_timestamp_96b_data_23            		: std_logic_vector (95 downto 0);   -- Output
		signal   rx_ingress_timestamp_64b_data_23            		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_time_of_day_96b_data_23                  		: std_logic_vector (95 downto 0);   -- Input
		signal   tx_time_of_day_64b_data_23                  		: std_logic_vector (63 downto 0);   -- Input
		signal   tx_egress_timestamp_96b_valid_23            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_64b_valid_23            		: std_logic;                        -- Output
		signal   tx_egress_timestamp_96b_data_23             		: std_logic_vector (95 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_data_23             		: std_logic_vector (63 downto 0);   -- Output
		signal   tx_egress_timestamp_96b_fingerprint_23             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_64b_fingerprint_23             	: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);   -- Output
		signal   tx_egress_timestamp_request_valid_23    			: std_logic;                        -- Input
		signal   tx_egress_timestamp_request_fingerprint_23     		: std_logic_vector (TSTAMP_FP_WIDTH-1 downto 0);    -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_96b_23        : std_logic_vector (95 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_ingress_timestamp_64b_23        : std_logic_vector (63 downto 0);   -- Input
		signal   tx_etstamp_ins_ctrl_timestamp_insert_23    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_update_23    	: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_zero_23    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_checksum_correct_23    			: std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_residence_time_calc_format_23   : std_logic;                        -- Input		
		signal   tx_etstamp_ins_ctrl_timestamp_format_23    			: std_logic;                        -- Input
		signal   tx_etstamp_ins_ctrl_offset_timestamp_23            	: std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_correction_field_23      : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_field_23        : std_logic_vector (15 downto 0);   -- Input		
		signal   tx_etstamp_ins_ctrl_offset_checksum_correction_23   : std_logic_vector (15 downto 0);   -- Input		
        
  
        
----------- PCS related

 -- PCS Status
 -- ----------

      signal led_crs          : std_logic ;                           -- Carrier Sense
      signal led_an           : std_logic ;                           -- Auto-Negotiation Status
      signal led_link         : std_logic ;                           -- Valid Link 
      signal led_col          : std_logic ;                           -- Collision 
      signal led_char_err     : std_logic ;                           -- Character Error
      signal led_disp_err     : std_logic ;                           -- Disparity Error
      
 -- PCS Control
 -- -----------

      signal sd_loopback      : std_logic ;                           -- SERDES Loopback Enable
      signal powerdown        : std_logic ;                           -- Powerdown Control
      
 -- TBI Interface
 -- -------------

      signal tbi_rxd          : std_logic_vector(9 downto 0) ;        -- Non Aligned 10-Bit Characters                       
      signal tbi_rxd_tmp      : std_logic_vector(9 downto 0) ;        -- Non Aligned 10-Bit Characters                       
      signal tbi_txd          : std_logic_vector(9 downto 0) ;        -- Transmit TBI Interface
      signal tbi_ena          : std_logic ;                           -- Enable TBI Interface
      signal gmii_crs         : std_logic ;                           -- Carrier Sense           
      signal dec_err          : std_logic ;                           -- Decoded Symbol Error
      signal rx_sync          : std_logic ;                           -- Receiver Synchronized
      signal an_restart_rst   : std_logic ;                           -- Reset Autonegotiation Command        

      signal tbi_rxd_tmp_last : std_logic_vector(9 downto 0) ;        -- Non Aligned 10-Bit Characters                       


--  SERIAL Interface
--  -------------

      signal    rxp : std_logic ;                    --  Serial 1.25Gbps Receive Interface
      signal    txp : std_logic ;                    --  Serial 1.25Gbps Transmit Interface


      -- Clocks
      -- -------------
      signal tbi_tx_clk       : std_logic ;                           -- 125MHz Transmit Clock        
      signal tbi_rx_clk       : std_logic ;                           -- 125MHz Recoved Clock


 ----------- MAC related
        
   -- Reset Signals
   -- -------------
   
      signal reset                    : std_logic ;
        
   -- Interface Control
   -- -----------------
   
      signal ether_mod                : std_logic ;                           -- Ethernet Mode
        signal ena_10                   : std_logic ;                           -- Enable 10Mbps Mode
      signal set_1000                 : std_logic ;                           -- Ethernet Mode Set
      signal set_10                   : std_logic ;                           -- Ethernet Mode Set

   -- FIFO and Magic Detection Status Signals
   -- ---------------------------------------
   
      signal magic_wakeup                : std_logic ;                           -- magic detection wakeup status
      signal ff_rx_a_full                : std_logic ;                           -- receive fifo almost full
      signal ff_rx_a_empty               : std_logic ;                           -- receive fifo almost empty
      signal ff_tx_a_full                : std_logic ;                           -- transmit fifo almost full
      signal ff_tx_a_empty               : std_logic ;                           -- transmit fifo almost empty

  --  Atlantic II Interface
  --  --------------
      signal   rx_err             : std_logic_vector(5 downto 0);
      signal   rx_err_stat        : std_logic_vector(17 downto 0);
      signal   rx_frm_type        : std_logic_vector(3 downto 0);
 
   -- MDIO Interface
   -- --------------
   
      signal mdc                      : std_logic;                            -- 2.5MHz Inteface
      signal mdio_in                  : std_logic;                            -- MDIO Input
      signal mdio_out                 : std_logic;                            -- MDIO Output
      signal mdio_oen                 : std_logic;                            -- MDIO Output Enable
      signal mdio                     : std_logic;                            -- MDIO
      signal phy_addr1                : std_logic_vector(4 downto 0) ;        -- PHY 1 Address
      signal mdio1_done               : std_logic ;                           -- Slave MDIO 1 Access Done
                
   -- Receive GMII Interface
   -- ----------------------
   
      signal rx_clk                   : std_logic ;                           -- GMII Receive clock       
        signal rx_clk_10mbps            : std_logic ;
        signal rx_clk_100mbps           : std_logic ;
        signal rx_clk_1000mbps          : std_logic ;         
      signal ref_clk_1000mbps         : std_logic;
      signal gm_rx_data               : std_logic_vector(7 downto 0) ;        -- GMII Receive data        
      signal gm_rx_en                 : std_logic ;                           -- GMII Receive frame enable
      signal gm_rx_err                : std_logic ;                           -- GMII Receive frame error 
        
   -- Transmit GMII Interface
   -- -----------------------

      signal tx_clk                   : std_logic ;                           -- GMII Transmit clock       
        signal tx_clk_10mbps            : std_logic ;
        signal tx_clk_100mbps           : std_logic ;
        signal tx_clk_1000mbps          : std_logic ;     
      signal gm_tx_data               : std_logic_vector(7 downto 0) ;        -- GMII Transmit data        
      signal gm_tx_en                 : std_logic ;                           -- GMII Transmit frame enable
      signal gm_tx_err                : std_logic ;                           -- GMII Transmit frame error
        
   -- Receive MII Interface
   -- ---------------------
   
      signal m_rx_data                : std_logic_vector(3 downto 0) ;        -- MII Receive data        
      signal m_rx_en                  : std_logic ;                           -- MII Receive frame enable
      signal m_rx_err                 : std_logic ;                           -- MII Receive frame error 
      signal m_rx_crs                 : std_logic;                            -- MII Carrier Sense
      signal m_rx_crs_fd              : std_logic;                            -- MII Carrier Sense
      signal m_rx_col                 : std_logic;                            -- MII Collision 
      signal m_rx_col_fd              : std_logic;                            -- MII Collision 
            
   -- Transmit MII Interface
   -- ----------------------

      signal m_tx_data                : std_logic_vector(3 downto 0) ;        -- MII Transmit data        
      signal m_tx_data_tmp            : std_logic_vector(7 downto 0) ;        -- MII Transmit data        
      signal m_tx_en                  : std_logic ;                           -- MII Transmit frame enable
      signal m_tx_err                 : std_logic ;                           -- MII Transmit frame error
        
   -- Receive User Interface
   -- ---------------------     
        signal ff_rx_clk_internal       : std_logic ;                           -- Receive Local Clock 
        signal ff_rx_clk                : std_logic ;                           -- Receive Local Clock
      signal ff_rx_data               : std_logic_vector(7 downto 0) ;        -- Data Out
      signal ff_rx_sop                : std_logic ;                           -- Start of Packet
      signal ff_rx_eop                : std_logic ;                           -- End of Packet
      signal ff_rx_err                : std_logic ;                           -- Errored Packet Indication (Parity, POS-PHY Errored or Oversized Packet)
      signal ff_rx_err_stat           : std_logic_vector(22 downto 0) ;       -- Errored Packet Status Word
      signal ff_rx_rdy                : std_logic ;                           -- PHY Application Ready
      signal ff_rx_dval               : std_logic ;                           -- Data Valid Strobe
      signal ff_rx_dsav               : std_logic ;                           -- Data Available
      signal ff_rx_ucast              : std_logic;                            -- Unicast Frame Indication
      signal ff_rx_bcast              : std_logic;                            -- Broadcast Frame Indication
      signal ff_rx_mcast              : std_logic;                            -- Multicast Frame Indication
      signal ff_rx_vlan               : std_logic;                            -- VLAN Frame Indication
      signal ff_rx_ucast_reg          : std_logic;                            -- Unicast Frame Indication
      signal ff_rx_bcast_reg          : std_logic;                            -- Broadcast Frame Indication
      signal ff_rx_mcast_reg          : std_logic;                            -- Multicast Frame Indication
      signal ff_rx_vlan_reg           : std_logic;                            -- VLAN Frame Indication
            
   -- Transmit User Interface
   -- -----------------------   

      signal ff_tx_clk_internal       : std_logic ;                           -- Transmit Local Clock 
      signal ff_tx_clk                : std_logic ;                           -- Transmit Local Clock 
      signal ff_tx_data               : std_logic_vector(7 downto 0) ;        -- Data Out
      signal ff_tx_sop                : std_logic ;                           -- Start of Packet
      signal ff_tx_eop                : std_logic ;                           -- End of Packet
      signal ff_tx_err                : std_logic ;                           -- Errored Packet
      signal ff_tx_wren               : std_logic ;                           -- Write Enable
      signal ff_tx_crc_fwd            : std_logic ;                           -- Forward Frame with CRC from Application
      signal ff_tx_rdy                : std_logic ;                           -- FIFO Ready           
      signal ff_tx_septy              : std_logic ;                           -- FIFO section empty
      signal tx_ff_uflow              : std_logic ;                           -- TX FIFO underflow occured (Synchronous with tx_clk)             

   -- Multicast Address Resolution Hash Look up Table Interface
   -- ---------------------------------------------------------
   
      signal sim_stop                 : std_logic ;                           -- End of Simulation
    
   -- Ethernet MAC Configuration
   -- --------------------------
        
      signal xoff_gen                 : std_logic;                            -- Xoff Pause frame generate 
      signal xon_gen                  : std_logic;                            -- Xon Pause frame generate         
      signal mac_addr                 : std_logic_vector(47 downto 0);        -- Device Ethernet MAC address
      signal sup_mac_addr_0           : std_logic_vector(47 downto 0);        -- Supplemental Ethernet MAC address
      signal sup_mac_addr_1           : std_logic_vector(47 downto 0);        -- Supplemental Ethernet MAC address
      signal sup_mac_addr_2           : std_logic_vector(47 downto 0);        -- Supplemental Ethernet MAC address
      signal sup_mac_addr_3           : std_logic_vector(47 downto 0);        -- Supplemental Ethernet MAC address
      signal promis_en                : std_logic;                            -- Enable promiscuous mode: accept any frame
      signal frm_length_max           : std_logic_vector(15 downto 0);        -- Maximium Received Frame length          
      signal ethernet_mode            : std_logic;                            -- Ethernet Mode (1 for Gigabit)
                                                                
   -- Event Triggers
   -- --------------
   
      signal pause_rcv                : std_logic;                            -- Pause Frame Receive Indication
      signal frm_rcv                  : std_logic;                            -- Frame Receive Indication
      signal frm_tx                   : std_logic;                            -- Frame Transmit Indication
      signal frm_align_err            : std_logic;                            -- Received Frame Aligment Error Indication
      signal frm_type_err             : std_logic;                            -- Received Frame type Error Indication
      signal frm_length_err           : std_logic;                            -- Received Frame length Error Indication
      signal frm_crc_err              : std_logic;                            -- Received Frame CRC_32 Error Indication
    
   -- Ethernet Generator Config (GMII RX)
   -- -----------------------------------

      signal gm_rxgen_rx_d            : std_logic_vector(7 downto 0);         -- gmii receive data
      signal gm_rxgen_rx_en           : std_logic;                            -- gmii receive frame enable  
      signal gm_rxgen_rx_err          : std_logic;                            -- gmii receive frame error     
      signal m_rxgen_rx_d             : std_logic_vector(7 downto 0);         -- mii receive data
      signal m_rxgen_rx_en            : std_logic;                            -- mii receive frame enable  
      signal m_rxgen_rx_err           : std_logic;                            -- mii receive frame error                     
      signal gm_mac_reverse           : std_logic;                            -- 1: dst/src are sent MSB first
      signal gm_dst                   : std_logic_vector(47 downto 0);        -- destination address
      signal gm_src                   : std_logic_vector(47 downto 0);        -- source address     
      signal gm_prmble_len            : integer range 0 to 15;                -- length of preamble
      signal gm_pquant                : std_logic_vector(15 downto 0);        -- Pause Quanta value
      signal gm_vlan_ctl              : std_logic_vector(15 downto 0);        -- VLAN control info
      signal gm_len                   : std_logic_vector(15 downto 0);        -- Length of payload
      signal gm_frmtype               : std_logic_vector(15 downto 0);        -- if non-null: type field instead length      
      signal gm_cntstart              : integer range 0 to 255;               -- payload data counter start (first byte of payload)
      signal gm_cntstep               : integer range 0 to 255;               -- payload counter step (2nd byte in paylaod)
      signal gm_ipg_cnt               : integer range 0 to 32768;             -- inter-packet gap
      signal gm_payload_err           : std_logic;                            -- generate payload pattern error (last payload byte is wrong)
      signal gm_prmbl_err             : std_logic;
      signal gm_crc_err               : std_logic;
      signal gm_pause_gen             : std_logic;
      signal gm_vlan_en               : std_logic;
      signal gm_stack_vlan_en         : std_logic;
      signal gm_pad_en                : std_logic;
      signal gm_phy_err               : std_logic;
      signal gm_end_err               : std_logic;                            -- keep rx_dv high one cycle after end of frame
      signal gm_magic                 : std_logic;


   -- FIFO Generator Config (user app FIFO TX)
   -- ----------------------------------------
        
      signal ff_mac_reverse           : std_logic;                            -- 1: dst/src are sent MSB first
      signal ff_dst                   : std_logic_vector(47 downto 0);        -- destination address
      signal ff_src                   : std_logic_vector(47 downto 0);        -- source address     
      signal ff_prmble_len            : integer range 0 to 15;                -- length of preamble
      signal ff_pquant                : std_logic_vector(15 downto 0);        -- Pause Quanta value
      signal ff_vlan_ctl              : std_logic_vector(15 downto 0);        -- VLAN control info
      signal ff_len                   : std_logic_vector(15 downto 0);        -- Length of payload
      signal ff_frmtype               : std_logic_vector(15 downto 0);        -- if non-null: type field instead length      
      signal ff_cntstart              : integer range 0 to 255;               -- payload data counter start (first byte of payload)
      signal ff_cntstep               : integer range 0 to 255;               -- payload counter step (2nd byte in paylaod)
      signal ff_ipg_len               : integer range 0 to 32768;             -- inter packet gap (delay after CRC)         
      signal ff_payload_err           : std_logic;                            -- generate payload pattern error (last payload byte is wrong)
      signal ff_prmbl_err             : std_logic;
      signal ff_crc_err               : std_logic;
      signal ff_vlan_en               : std_logic;
      signal ff_stack_vlan_en         : std_logic;
      signal ff_pad_en                : std_logic;
      signal ff_phy_err               : std_logic;
      signal ff_end_err               : std_logic;                            -- keep rx_dv high one cycle after end of frame

   -- Register Interface
   -- ------------------
   
      signal reg_clk                  : std_logic ;                           -- 25MHz Host Interface Clock
      signal reg_rd                   : std_logic ;               -- Register Read Strobe
      signal reg_wr                   : std_logic ;               -- Register Write Strobe
        signal reg_addr                 : std_logic_vector(13 downto 0) ;        -- Register Address
      signal reg_data_in              : std_logic_vector(31 downto 0) ;   -- Write Data for Host Bus
      signal reg_data_out             : std_logic_vector(31 downto 0) ;   -- Read Data to Host Bus
      signal reg_busy                 : std_logic ;                           -- Interface Busy
      signal magic_sleep_n            : std_logic ;                           -- Enable Sleep Mode
      signal reg_wakeup               : std_logic ;                           -- Wake Up Request

    -- NightFury PHYIP Interface
    -- -------------------------
      signal tx_serial_clk_0      : std_logic_vector (0 downto 0);
      signal tx_analogreset_0     : std_logic_vector (0 downto 0);
      signal tx_digitalreset_0    : std_logic_vector (0 downto 0);
      signal rx_analogreset_0     : std_logic_vector (0 downto 0);
      signal rx_digitalreset_0    : std_logic_vector (0 downto 0);
      signal tx_cal_busy_0        : std_logic_vector (0 downto 0);
      signal rx_cal_busy_0        : std_logic_vector (0 downto 0);
      signal rx_is_lockedtodata_0 : std_logic_vector (0 downto 0);
      signal rx_is_lockedtoref_0  : std_logic_vector (0 downto 0);
      signal rx_set_locktodata_0  : std_logic_vector (0 downto 0);
      signal rx_set_locktoref_0   : std_logic_vector (0 downto 0);
      signal rx_cdr_refclk_0      : std_logic;

      signal tx_serial_clk_1      : std_logic_vector (0 downto 0);
      signal tx_analogreset_1     : std_logic_vector (0 downto 0);
      signal tx_digitalreset_1    : std_logic_vector (0 downto 0);
      signal rx_analogreset_1     : std_logic_vector (0 downto 0);
      signal rx_digitalreset_1    : std_logic_vector (0 downto 0);
      signal tx_cal_busy_1        : std_logic_vector (0 downto 0);
      signal rx_cal_busy_1        : std_logic_vector (0 downto 0);
      signal rx_is_lockedtodata_1 : std_logic_vector (0 downto 0);
      signal rx_is_lockedtoref_1  : std_logic_vector (0 downto 0);
      signal rx_set_locktodata_1  : std_logic_vector (0 downto 0);
      signal rx_set_locktoref_1   : std_logic_vector (0 downto 0);
      signal rx_cdr_refclk_1      : std_logic;

      signal tx_serial_clk_2      : std_logic_vector (0 downto 0);
      signal tx_analogreset_2     : std_logic_vector (0 downto 0);
      signal tx_digitalreset_2    : std_logic_vector (0 downto 0);
      signal rx_analogreset_2     : std_logic_vector (0 downto 0);
      signal rx_digitalreset_2    : std_logic_vector (0 downto 0);
      signal tx_cal_busy_2        : std_logic_vector (0 downto 0);
      signal rx_cal_busy_2        : std_logic_vector (0 downto 0);
      signal rx_is_lockedtodata_2 : std_logic_vector (0 downto 0);
      signal rx_is_lockedtoref_2  : std_logic_vector (0 downto 0);
      signal rx_set_locktodata_2  : std_logic_vector (0 downto 0);
      signal rx_set_locktoref_2   : std_logic_vector (0 downto 0);
      signal rx_cdr_refclk_2      : std_logic;

      signal tx_serial_clk_3      : std_logic_vector (0 downto 0);
      signal tx_analogreset_3     : std_logic_vector (0 downto 0);
      signal tx_digitalreset_3    : std_logic_vector (0 downto 0);
      signal rx_analogreset_3     : std_logic_vector (0 downto 0);
      signal rx_digitalreset_3    : std_logic_vector (0 downto 0);
      signal tx_cal_busy_3        : std_logic_vector (0 downto 0);
      signal rx_cal_busy_3        : std_logic_vector (0 downto 0);
      signal rx_is_lockedtodata_3 : std_logic_vector (0 downto 0);
      signal rx_is_lockedtoref_3  : std_logic_vector (0 downto 0);
      signal rx_set_locktodata_3  : std_logic_vector (0 downto 0);
      signal rx_set_locktoref_3   : std_logic_vector (0 downto 0);
      signal rx_cdr_refclk_3      : std_logic;

      signal tx_serial_clk_4      : std_logic_vector (0 downto 0);
      signal tx_analogreset_4     : std_logic_vector (0 downto 0);
      signal tx_digitalreset_4    : std_logic_vector (0 downto 0);
      signal rx_analogreset_4     : std_logic_vector (0 downto 0);
      signal rx_digitalreset_4    : std_logic_vector (0 downto 0);
      signal tx_cal_busy_4        : std_logic_vector (0 downto 0);
      signal rx_cal_busy_4        : std_logic_vector (0 downto 0);
      signal rx_is_lockedtodata_4 : std_logic_vector (0 downto 0);
      signal rx_is_lockedtoref_4  : std_logic_vector (0 downto 0);
      signal rx_set_locktodata_4  : std_logic_vector (0 downto 0);
      signal rx_set_locktoref_4   : std_logic_vector (0 downto 0);
      signal rx_cdr_refclk_4      : std_logic;

      signal tx_serial_clk_5      : std_logic_vector (0 downto 0);
      signal tx_analogreset_5     : std_logic_vector (0 downto 0);
      signal tx_digitalreset_5    : std_logic_vector (0 downto 0);
      signal rx_analogreset_5     : std_logic_vector (0 downto 0);
      signal rx_digitalreset_5    : std_logic_vector (0 downto 0);
      signal tx_cal_busy_5        : std_logic_vector (0 downto 0);
      signal rx_cal_busy_5        : std_logic_vector (0 downto 0);
      signal rx_is_lockedtodata_5 : std_logic_vector (0 downto 0);
      signal rx_is_lockedtoref_5  : std_logic_vector (0 downto 0);
      signal rx_set_locktodata_5  : std_logic_vector (0 downto 0);
      signal rx_set_locktoref_5   : std_logic_vector (0 downto 0);
      signal rx_cdr_refclk_5      : std_logic;

      signal tx_serial_clk_6      : std_logic_vector (0 downto 0);
      signal tx_analogreset_6     : std_logic_vector (0 downto 0);
      signal tx_digitalreset_6    : std_logic_vector (0 downto 0);
      signal rx_analogreset_6     : std_logic_vector (0 downto 0);
      signal rx_digitalreset_6    : std_logic_vector (0 downto 0);
      signal tx_cal_busy_6        : std_logic_vector (0 downto 0);
      signal rx_cal_busy_6        : std_logic_vector (0 downto 0);
      signal rx_is_lockedtodata_6 : std_logic_vector (0 downto 0);
      signal rx_is_lockedtoref_6  : std_logic_vector (0 downto 0);
      signal rx_set_locktodata_6  : std_logic_vector (0 downto 0);
      signal rx_set_locktoref_6   : std_logic_vector (0 downto 0);
      signal rx_cdr_refclk_6      : std_logic;

      signal tx_serial_clk_7      : std_logic_vector (0 downto 0);
      signal tx_analogreset_7     : std_logic_vector (0 downto 0);
      signal tx_digitalreset_7    : std_logic_vector (0 downto 0);
      signal rx_analogreset_7     : std_logic_vector (0 downto 0);
      signal rx_digitalreset_7    : std_logic_vector (0 downto 0);
      signal tx_cal_busy_7        : std_logic_vector (0 downto 0);
      signal rx_cal_busy_7        : std_logic_vector (0 downto 0);
      signal rx_is_lockedtodata_7 : std_logic_vector (0 downto 0);
      signal rx_is_lockedtoref_7  : std_logic_vector (0 downto 0);
      signal rx_set_locktodata_7  : std_logic_vector (0 downto 0);
      signal rx_set_locktoref_7   : std_logic_vector (0 downto 0);
      signal rx_cdr_refclk_7      : std_logic;

      signal tx_serial_clk_8      : std_logic_vector (0 downto 0);
      signal tx_analogreset_8     : std_logic_vector (0 downto 0);
      signal tx_digitalreset_8    : std_logic_vector (0 downto 0);
      signal rx_analogreset_8     : std_logic_vector (0 downto 0);
      signal rx_digitalreset_8    : std_logic_vector (0 downto 0);
      signal tx_cal_busy_8        : std_logic_vector (0 downto 0);
      signal rx_cal_busy_8        : std_logic_vector (0 downto 0);
      signal rx_is_lockedtodata_8 : std_logic_vector (0 downto 0);
      signal rx_is_lockedtoref_8  : std_logic_vector (0 downto 0);
      signal rx_set_locktodata_8  : std_logic_vector (0 downto 0);
      signal rx_set_locktoref_8   : std_logic_vector (0 downto 0);
      signal rx_cdr_refclk_8      : std_logic;

      signal tx_serial_clk_9      : std_logic_vector (0 downto 0);
      signal tx_analogreset_9     : std_logic_vector (0 downto 0);
      signal tx_digitalreset_9    : std_logic_vector (0 downto 0);
      signal rx_analogreset_9     : std_logic_vector (0 downto 0);
      signal rx_digitalreset_9    : std_logic_vector (0 downto 0);
      signal tx_cal_busy_9        : std_logic_vector (0 downto 0);
      signal rx_cal_busy_9        : std_logic_vector (0 downto 0);
      signal rx_is_lockedtodata_9 : std_logic_vector (0 downto 0);
      signal rx_is_lockedtoref_9  : std_logic_vector (0 downto 0);
      signal rx_set_locktodata_9  : std_logic_vector (0 downto 0);
      signal rx_set_locktoref_9   : std_logic_vector (0 downto 0);
      signal rx_cdr_refclk_9      : std_logic;

      signal tx_serial_clk_10      : std_logic_vector (0 downto 0);
      signal tx_analogreset_10     : std_logic_vector (0 downto 0);
      signal tx_digitalreset_10    : std_logic_vector (0 downto 0);
      signal rx_analogreset_10     : std_logic_vector (0 downto 0);
      signal rx_digitalreset_10    : std_logic_vector (0 downto 0);
      signal tx_cal_busy_10        : std_logic_vector (0 downto 0);
      signal rx_cal_busy_10        : std_logic_vector (0 downto 0);
      signal rx_is_lockedtodata_10 : std_logic_vector (0 downto 0);
      signal rx_is_lockedtoref_10  : std_logic_vector (0 downto 0);
      signal rx_set_locktodata_10  : std_logic_vector (0 downto 0);
      signal rx_set_locktoref_10   : std_logic_vector (0 downto 0);
      signal rx_cdr_refclk_10      : std_logic;

      signal tx_serial_clk_11      : std_logic_vector (0 downto 0);
      signal tx_analogreset_11     : std_logic_vector (0 downto 0);
      signal tx_digitalreset_11    : std_logic_vector (0 downto 0);
      signal rx_analogreset_11     : std_logic_vector (0 downto 0);
      signal rx_digitalreset_11    : std_logic_vector (0 downto 0);
      signal tx_cal_busy_11        : std_logic_vector (0 downto 0);
      signal rx_cal_busy_11        : std_logic_vector (0 downto 0);
      signal rx_is_lockedtodata_11 : std_logic_vector (0 downto 0);
      signal rx_is_lockedtoref_11  : std_logic_vector (0 downto 0);
      signal rx_set_locktodata_11  : std_logic_vector (0 downto 0);
      signal rx_set_locktoref_11   : std_logic_vector (0 downto 0);
      signal rx_cdr_refclk_11      : std_logic;

      signal tx_serial_clk_12      : std_logic_vector (0 downto 0);
      signal tx_analogreset_12     : std_logic_vector (0 downto 0);
      signal tx_digitalreset_12    : std_logic_vector (0 downto 0);
      signal rx_analogreset_12     : std_logic_vector (0 downto 0);
      signal rx_digitalreset_12    : std_logic_vector (0 downto 0);
      signal tx_cal_busy_12        : std_logic_vector (0 downto 0);
      signal rx_cal_busy_12        : std_logic_vector (0 downto 0);
      signal rx_is_lockedtodata_12 : std_logic_vector (0 downto 0);
      signal rx_is_lockedtoref_12  : std_logic_vector (0 downto 0);
      signal rx_set_locktodata_12  : std_logic_vector (0 downto 0);
      signal rx_set_locktoref_12   : std_logic_vector (0 downto 0);
      signal rx_cdr_refclk_12      : std_logic;

      signal tx_serial_clk_13      : std_logic_vector (0 downto 0);
      signal tx_analogreset_13     : std_logic_vector (0 downto 0);
      signal tx_digitalreset_13    : std_logic_vector (0 downto 0);
      signal rx_analogreset_13     : std_logic_vector (0 downto 0);
      signal rx_digitalreset_13    : std_logic_vector (0 downto 0);
      signal tx_cal_busy_13        : std_logic_vector (0 downto 0);
      signal rx_cal_busy_13        : std_logic_vector (0 downto 0);
      signal rx_is_lockedtodata_13 : std_logic_vector (0 downto 0);
      signal rx_is_lockedtoref_13  : std_logic_vector (0 downto 0);
      signal rx_set_locktodata_13  : std_logic_vector (0 downto 0);
      signal rx_set_locktoref_13   : std_logic_vector (0 downto 0);
      signal rx_cdr_refclk_13      : std_logic;

      signal tx_serial_clk_14      : std_logic_vector (0 downto 0);
      signal tx_analogreset_14     : std_logic_vector (0 downto 0);
      signal tx_digitalreset_14    : std_logic_vector (0 downto 0);
      signal rx_analogreset_14     : std_logic_vector (0 downto 0);
      signal rx_digitalreset_14    : std_logic_vector (0 downto 0);
      signal tx_cal_busy_14        : std_logic_vector (0 downto 0);
      signal rx_cal_busy_14        : std_logic_vector (0 downto 0);
      signal rx_is_lockedtodata_14 : std_logic_vector (0 downto 0);
      signal rx_is_lockedtoref_14  : std_logic_vector (0 downto 0);
      signal rx_set_locktodata_14  : std_logic_vector (0 downto 0);
      signal rx_set_locktoref_14   : std_logic_vector (0 downto 0);
      signal rx_cdr_refclk_14      : std_logic;

      signal tx_serial_clk_15      : std_logic_vector (0 downto 0);
      signal tx_analogreset_15     : std_logic_vector (0 downto 0);
      signal tx_digitalreset_15    : std_logic_vector (0 downto 0);
      signal rx_analogreset_15     : std_logic_vector (0 downto 0);
      signal rx_digitalreset_15    : std_logic_vector (0 downto 0);
      signal tx_cal_busy_15        : std_logic_vector (0 downto 0);
      signal rx_cal_busy_15        : std_logic_vector (0 downto 0);
      signal rx_is_lockedtodata_15 : std_logic_vector (0 downto 0);
      signal rx_is_lockedtoref_15  : std_logic_vector (0 downto 0);
      signal rx_set_locktodata_15  : std_logic_vector (0 downto 0);
      signal rx_set_locktoref_15   : std_logic_vector (0 downto 0);
      signal rx_cdr_refclk_15      : std_logic;

      signal tx_serial_clk_16      : std_logic_vector (0 downto 0);
      signal tx_analogreset_16     : std_logic_vector (0 downto 0);
      signal tx_digitalreset_16    : std_logic_vector (0 downto 0);
      signal rx_analogreset_16     : std_logic_vector (0 downto 0);
      signal rx_digitalreset_16    : std_logic_vector (0 downto 0);
      signal tx_cal_busy_16        : std_logic_vector (0 downto 0);
      signal rx_cal_busy_16        : std_logic_vector (0 downto 0);
      signal rx_is_lockedtodata_16 : std_logic_vector (0 downto 0);
      signal rx_is_lockedtoref_16  : std_logic_vector (0 downto 0);
      signal rx_set_locktodata_16  : std_logic_vector (0 downto 0);
      signal rx_set_locktoref_16   : std_logic_vector (0 downto 0);
      signal rx_cdr_refclk_16      : std_logic;

      signal tx_serial_clk_17      : std_logic_vector (0 downto 0);
      signal tx_analogreset_17     : std_logic_vector (0 downto 0);
      signal tx_digitalreset_17    : std_logic_vector (0 downto 0);
      signal rx_analogreset_17     : std_logic_vector (0 downto 0);
      signal rx_digitalreset_17    : std_logic_vector (0 downto 0);
      signal tx_cal_busy_17        : std_logic_vector (0 downto 0);
      signal rx_cal_busy_17        : std_logic_vector (0 downto 0);
      signal rx_is_lockedtodata_17 : std_logic_vector (0 downto 0);
      signal rx_is_lockedtoref_17  : std_logic_vector (0 downto 0);
      signal rx_set_locktodata_17  : std_logic_vector (0 downto 0);
      signal rx_set_locktoref_17   : std_logic_vector (0 downto 0);
      signal rx_cdr_refclk_17      : std_logic;

      signal tx_serial_clk_18      : std_logic_vector (0 downto 0);
      signal tx_analogreset_18     : std_logic_vector (0 downto 0);
      signal tx_digitalreset_18    : std_logic_vector (0 downto 0);
      signal rx_analogreset_18     : std_logic_vector (0 downto 0);
      signal rx_digitalreset_18    : std_logic_vector (0 downto 0);
      signal tx_cal_busy_18        : std_logic_vector (0 downto 0);
      signal rx_cal_busy_18        : std_logic_vector (0 downto 0);
      signal rx_is_lockedtodata_18 : std_logic_vector (0 downto 0);
      signal rx_is_lockedtoref_18  : std_logic_vector (0 downto 0);
      signal rx_set_locktodata_18  : std_logic_vector (0 downto 0);
      signal rx_set_locktoref_18   : std_logic_vector (0 downto 0);
      signal rx_cdr_refclk_18      : std_logic;

      signal tx_serial_clk_19      : std_logic_vector (0 downto 0);
      signal tx_analogreset_19     : std_logic_vector (0 downto 0);
      signal tx_digitalreset_19    : std_logic_vector (0 downto 0);
      signal rx_analogreset_19     : std_logic_vector (0 downto 0);
      signal rx_digitalreset_19    : std_logic_vector (0 downto 0);
      signal tx_cal_busy_19        : std_logic_vector (0 downto 0);
      signal rx_cal_busy_19        : std_logic_vector (0 downto 0);
      signal rx_is_lockedtodata_19 : std_logic_vector (0 downto 0);
      signal rx_is_lockedtoref_19  : std_logic_vector (0 downto 0);
      signal rx_set_locktodata_19  : std_logic_vector (0 downto 0);
      signal rx_set_locktoref_19   : std_logic_vector (0 downto 0);
      signal rx_cdr_refclk_19      : std_logic;

      signal tx_serial_clk_20      : std_logic_vector (0 downto 0);
      signal tx_analogreset_20     : std_logic_vector (0 downto 0);
      signal tx_digitalreset_20    : std_logic_vector (0 downto 0);
      signal rx_analogreset_20     : std_logic_vector (0 downto 0);
      signal rx_digitalreset_20    : std_logic_vector (0 downto 0);
      signal tx_cal_busy_20        : std_logic_vector (0 downto 0);
      signal rx_cal_busy_20        : std_logic_vector (0 downto 0);
      signal rx_is_lockedtodata_20 : std_logic_vector (0 downto 0);
      signal rx_is_lockedtoref_20  : std_logic_vector (0 downto 0);
      signal rx_set_locktodata_20  : std_logic_vector (0 downto 0);
      signal rx_set_locktoref_20   : std_logic_vector (0 downto 0);
      signal rx_cdr_refclk_20      : std_logic;

      signal tx_serial_clk_21      : std_logic_vector (0 downto 0);
      signal tx_analogreset_21     : std_logic_vector (0 downto 0);
      signal tx_digitalreset_21    : std_logic_vector (0 downto 0);
      signal rx_analogreset_21     : std_logic_vector (0 downto 0);
      signal rx_digitalreset_21    : std_logic_vector (0 downto 0);
      signal tx_cal_busy_21        : std_logic_vector (0 downto 0);
      signal rx_cal_busy_21        : std_logic_vector (0 downto 0);
      signal rx_is_lockedtodata_21 : std_logic_vector (0 downto 0);
      signal rx_is_lockedtoref_21  : std_logic_vector (0 downto 0);
      signal rx_set_locktodata_21  : std_logic_vector (0 downto 0);
      signal rx_set_locktoref_21   : std_logic_vector (0 downto 0);
      signal rx_cdr_refclk_21      : std_logic;

      signal tx_serial_clk_22      : std_logic_vector (0 downto 0);
      signal tx_analogreset_22     : std_logic_vector (0 downto 0);
      signal tx_digitalreset_22    : std_logic_vector (0 downto 0);
      signal rx_analogreset_22     : std_logic_vector (0 downto 0);
      signal rx_digitalreset_22    : std_logic_vector (0 downto 0);
      signal tx_cal_busy_22        : std_logic_vector (0 downto 0);
      signal rx_cal_busy_22        : std_logic_vector (0 downto 0);
      signal rx_is_lockedtodata_22 : std_logic_vector (0 downto 0);
      signal rx_is_lockedtoref_22  : std_logic_vector (0 downto 0);
      signal rx_set_locktodata_22  : std_logic_vector (0 downto 0);
      signal rx_set_locktoref_22   : std_logic_vector (0 downto 0);
      signal rx_cdr_refclk_22      : std_logic;

      signal tx_serial_clk_23      : std_logic_vector (0 downto 0);
      signal tx_analogreset_23     : std_logic_vector (0 downto 0);
      signal tx_digitalreset_23    : std_logic_vector (0 downto 0);
      signal rx_analogreset_23     : std_logic_vector (0 downto 0);
      signal rx_digitalreset_23    : std_logic_vector (0 downto 0);
      signal tx_cal_busy_23        : std_logic_vector (0 downto 0);
      signal rx_cal_busy_23        : std_logic_vector (0 downto 0);
      signal rx_is_lockedtodata_23 : std_logic_vector (0 downto 0);
      signal rx_is_lockedtoref_23  : std_logic_vector (0 downto 0);
      signal rx_set_locktodata_23  : std_logic_vector (0 downto 0);
      signal rx_set_locktoref_23   : std_logic_vector (0 downto 0);
      signal rx_cdr_refclk_23      : std_logic;

      signal tx_ready             : std_logic;
      signal rx_ready             : std_logic;
      signal tx_serial_clk        : std_logic_vector (0 downto 0);
      signal tx_analogreset       : std_logic_vector (0 downto 0);
      signal tx_digitalreset      : std_logic_vector (0 downto 0);
      signal rx_analogreset       : std_logic_vector (0 downto 0);
      signal rx_digitalreset      : std_logic_vector (0 downto 0);
      signal tx_cal_busy          : std_logic_vector (0 downto 0);
      signal rx_cal_busy          : std_logic_vector (0 downto 0);
      signal rx_is_lockedtodata   : std_logic_vector (0 downto 0);
      signal rx_is_lockedtoref    : std_logic_vector (0 downto 0);
      signal rx_set_locktodata    : std_logic_vector (0 downto 0);
      signal rx_set_locktoref     : std_logic_vector (0 downto 0);
      signal rx_cdr_refclk        : std_logic;

   -- Ethernet TX Monitor
   -- -------------------

      signal  mgm_dst                 :  std_logic_vector(47 downto 0);       -- destination address
      signal  mgm_src                 :  std_logic_vector(47 downto 0);       -- source address
      signal  mgm_prmble_len          :  integer range 0 to 10000;            -- length of preamble
      signal  mgm_pquant              :  std_logic_vector(15 downto 0);       -- Pause Quanta value
      signal  mgm_vlan_ctl            :  std_logic_vector(15 downto 0);       -- VLAN control info
      signal  mgm_len                 :  std_logic_vector(15 downto 0);       -- Length of payload
      signal  mgm_frmtype             :  std_logic_vector(15 downto 0);       -- if non-null: type field instead length
      signal  mgm_payload             :  std_logic_vector(7 downto 0); 
      signal  mgm_payload_vld         :  std_logic;
      signal  mgm_is_vlan             :  std_logic;
      signal  mgm_is_stack_vlan       :  std_logic;
      signal  mgm_is_pause            :  std_logic;
      signal  mgm_crc_err             :  std_logic;
      signal  mgm_prmbl_err           :  std_logic;
      signal  mgm_pad_err             :  std_logic;
      signal  mgm_len_err             :  std_logic;
      signal  mgm_payload_err         :  std_logic;
      signal  mgm_frame_err           :  std_logic;
      signal  mgm_pause_op_err        :  std_logic;
      signal  mgm_pause_dst_err       :  std_logic;
      signal  mgm_mac_err             :  std_logic;
      signal  mgm_end_err             :  std_logic;
      signal  mgm_frm_rcvd            :  std_logic; 

   -- GMII Modintor
   -- -------------
           
      signal  gm_mgm_dst              :  std_logic_vector(47 downto 0);       -- destination address
      signal  gm_mgm_src              :  std_logic_vector(47 downto 0);       -- source address
      signal  gm_mgm_prmble_len       :  integer range 0 to 10000;            -- length of preamble
      signal  gm_mgm_pquant           :  std_logic_vector(15 downto 0);       -- Pause Quanta value
      signal  gm_mgm_vlan_ctl         :  std_logic_vector(15 downto 0);       -- VLAN control info
      signal  gm_mgm_len              :  std_logic_vector(15 downto 0);       -- Length of payload
      signal  gm_mgm_frmtype          :  std_logic_vector(15 downto 0);       -- if non-null: type field instead length
      signal  gm_mgm_payload          :  std_logic_vector(7 downto 0); 
      signal  gm_mgm_payload_vld      :  std_logic;
      signal  gm_mgm_is_vlan          :  std_logic;
      signal  gm_mgm_is_stack_vlan    :  std_logic;
      signal  gm_mgm_is_pause         :  std_logic;
      signal  gm_mgm_crc_err          :  std_logic;
      signal  gm_mgm_prmbl_err        :  std_logic;
      signal  gm_mgm_pad_err          :  std_logic;
      signal  gm_mgm_len_err          :  std_logic;
      signal  gm_mgm_payload_err      :  std_logic;
      signal  gm_mgm_frame_err        :  std_logic;
      signal  gm_mgm_pause_op_err     :  std_logic;
      signal  gm_mgm_pause_dst_err    :  std_logic;
      signal  gm_mgm_mac_err          :  std_logic;
      signal  gm_mgm_end_err          :  std_logic;
      signal  gm_mgm_frm_rcvd         :  std_logic;                           -- if '1' all signals/indicators are valid        

   -- MII Monitor
   -- -----------
           
      signal  m_mgm_dst               :  std_logic_vector(47 downto 0);       -- destination address
      signal  m_mgm_src               :  std_logic_vector(47 downto 0);       -- source address
      signal  m_mgm_prmble_len        :  integer range 0 to 10000;            -- length of preamble
      signal  m_mgm_pquant            :  std_logic_vector(15 downto 0);       -- Pause Quanta value
      signal  m_mgm_vlan_ctl          :  std_logic_vector(15 downto 0);       -- VLAN control info
      signal  m_mgm_len               :  std_logic_vector(15 downto 0);       -- Length of payload
      signal  m_mgm_frmtype           :  std_logic_vector(15 downto 0);       -- if non-null: type field instead length
      signal  m_mgm_payload           :  std_logic_vector(7 downto 0); 
      signal  m_mgm_payload_vld       :  std_logic;
      signal  m_mgm_is_vlan           :  std_logic;
      signal  m_mgm_is_stack_vlan     :  std_logic;
      signal  m_mgm_is_pause          :  std_logic;
      signal  m_mgm_crc_err           :  std_logic;
      signal  m_mgm_prmbl_err         :  std_logic;
      signal  m_mgm_pad_err           :  std_logic;
      signal  m_mgm_len_err           :  std_logic;
      signal  m_mgm_payload_err       :  std_logic;
      signal  m_mgm_frame_err         :  std_logic;
      signal  m_mgm_pause_op_err      :  std_logic;
      signal  m_mgm_pause_dst_err     :  std_logic;
      signal  m_mgm_mac_err           :  std_logic;
      signal  m_mgm_end_err           :  std_logic;
      signal  m_mgm_frm_rcvd          :  std_logic;                           -- if '1' all signals/indicators are valid         

   -- FIFO Monitor (Checking)
   -- ----------------------

      signal  mff_dst                 :  std_logic_vector(47 downto 0);       -- destination address
      signal  mff_dst_reg             :  std_logic_vector(47 downto 0);       -- destination address
      signal  mff_src                 :  std_logic_vector(47 downto 0);       -- source address
      signal  mff_prmble_len          :  integer range 0 to 10000;            -- length of preamble
      signal  mff_pquant              :  std_logic_vector(15 downto 0);       -- Pause Quanta value
      signal  mff_vlan_ctl            :  std_logic_vector(15 downto 0);       -- VLAN control info
      signal  mff_len                 :  std_logic_vector(15 downto 0);       -- Length of payload
      signal  mff_frmtype             :  std_logic_vector(15 downto 0);       -- if non-null: type field instead length
      signal  mff_payload             :  std_logic_vector(7 downto 0); 
      signal  mff_payload_vld         :  std_logic;
      signal  mff_is_vlan             :  std_logic;
      signal  mff_is_stack_vlan       :  std_logic;
      signal  mff_is_pause            :  std_logic;
      signal  mff_crc_err             :  std_logic;
      signal  mff_prmbl_err           :  std_logic;
      signal  mff_pad_err             :  std_logic;
      signal  mff_len_err             :  std_logic;
      signal  mff_payload_err         :  std_logic;
      signal  mff_frame_err           :  std_logic;
      signal  mff_pause_op_err        :  std_logic;
      signal  mff_pause_dst_err       :  std_logic;
      signal  mff_mac_err             :  std_logic;
      signal  mff_end_err             :  std_logic;
      signal  mff_frm_rcvd            :  std_logic;                           -- if '1' all signals/indicators are valid
      signal  ff_frmlen               :  integer;                             -- length of frame as it is coming from the FIFO

   -- Simulation Command Signals
   -- --------------------------
   
      signal gm_start_ether_gen       : std_logic ;           -- Enable Frame Generation
      signal m_start_ether_gen        : std_logic ;           -- Enable Frame Generation
      signal gm_ether_gen_done        : std_logic ;           -- Ethernet Generation Completed
      signal gm_gm_ether_gen_done     : std_logic ;           -- Ethernet Generation Completed
      signal m_gm_ether_gen_done      : std_logic ;           -- Ethernet Generation Completed
      signal ff_start_ether_gen       : std_logic ;           -- Enable Frame Generation
      signal ff_ether_gen_done        : std_logic ;           -- Ethernet Generation Completed
      signal jumbo_enable             : std_logic ;           -- depending on TB_MACLENMAX            

    -- Simulation Control
    -- ------------------
    
      signal sim_done                 : std_logic;            -- 1 when everything has finished
      signal sim_start                : std_logic;            -- when to start simulation
      signal delay_cnt                : integer := 0;         -- wait before start and after done until stop    
      signal hash_cnt                 : integer;              -- Hash table programming counter 
      signal multicast_cnt            : integer;              -- counter during setting of a multicast address
      signal multicast_wrong          : boolean := false;              -- true if we currently use a multicast address not from the table    
      signal promis_en_dly            : std_logic;
      signal stop_rx_fifo_read        : std_logic;            -- FIFO read should be stopped now
      signal ff_rx_rdy_dly            : std_logic;            -- delayed rx_rdy for message generation
      signal rx_hold_cnt              : integer  ;            -- timer counting cycles during fifo read stop
      signal rx_fifo_cnt              : integer  ;            -- incremented with each frame read from the FIFO
      signal tx_pause_wait            : std_logic;            -- Pause frame received. TX should stop
      signal tx_pause_cnt             : integer  ;            -- timer counting pause delay
      
      signal force_xoff_pause_cnt     : integer  ;            -- when to trigger a Xoff frame generation
      signal force_xon_pause_cnt      : integer  ;            -- when to trigger a Xon frame generation

   -- TX PATH simulation
   -- ------------------
    
      signal txframe_cnt              : integer := 0;         -- number of frames transmitted/generated
      signal txsim_done               : std_logic;            -- 1 when everything has finished
      signal ff_tx_clk_gen_en         : std_logic;            -- clock enable for TX FIFO generator    
      signal ff_tx_clk_gen            : std_logic;            -- clock for TX FIFO generator    
      signal ff_tx_wren_gen           : std_logic;            -- write enable FIFO interface

   -- TX: Verification information
   -- ----------------------------
               
      signal tx_good_sent             : integer;              -- valid frames sent which should be counted as good on receive
      signal tx_good_rcvd             : integer;              -- should be same as good_sent at end of test        
      signal tx_pause_rcvd            : integer;
      signal tx_pause_err_rcvd        : integer;              -- erroneous PAUSE frames
      signal tx_align_err_rcvd        : integer;              -- should NEVER happen
      signal gm_txcnt                 : integer;        
      signal tx_vlan_sent             : integer;
      signal tx_stack_vlan_sent       : integer;
      signal tx_frm_all               : integer;
      signal tx_vlan_rcvd             : integer;              -- received by monitor
      signal tx_stack_vlan_rcvd       : integer;              -- received by monitor
      signal tx_vlan_wrong_type_sent  : integer;    
      signal tx_phy_err_rcvd          : integer;              -- GMII tx error signal detected
      signal tx_crc_err_rcvd          : integer;            
      signal tx_payload_err_sent      : integer;
      signal tx_payload_err_rcvd      : integer;
      
      signal tx_wrong_src_rcvd        : integer;              -- Wrong MAC SOURCE address received by monitor
        
   -- RX PATH simulation
   -- ------------------
      signal rxframe_cnt              : integer := 0;                         -- number of frames transmitted/generated
      signal last_err_stat            : std_logic_vector(3 downto 0);         -- latest FIFO error bits
      signal ff_last_length           : std_logic_vector(15 downto 0);        -- length part of ff_rx_err_stat
      signal gm_sop                   : std_logic;                            -- sop from GMII generator
      signal gm_gm_sop                : std_logic;                            -- sop from GMII generator
      signal m_gm_sop                 : std_logic;                            -- sop from MII generator
      signal gm_sop_dly               : std_logic;                            -- delayed by 1
      signal gm_sop_dly2              : std_logic;                            -- delayed by 1
      signal gm_eop                   : std_logic;                            -- eop from GMII generator
      signal gm_gm_eop                : std_logic;                            -- eop from GMII generator
      signal m_gm_eop                 : std_logic;                            -- eop from MII generator
      signal gm_eop_dly               : std_logic;                            -- dito delayed by 1 clk 
    
   -- RX: Determine when to expect the RX to act 
   -- ------------------------------------------
   
      signal expect1                  : std_logic;                            -- set after start of generator
      signal expect2                  : std_logic;                            -- set when we expect something, cleared if done
        
   -- RX: Verification information
   -- ------------------------
        
      signal rx_is_good_frame         : boolean;                              -- true if valid frame (payload error is still a valid frame)
      signal rx_is_good_addr          : boolean;                              -- true if valid mac address is given        
      signal rx_good_sent             : integer := -1;                        -- valid frames sent which should be counted as good on receive
      signal rx_good_rcvd             : integer := -1;                        -- should be same as good_sent at end of test        
      signal rx_pause_sent            : integer := -1;
      signal rx_pause_rcvd            : integer := -1;    
      signal rx_align_err_sent        : integer := -1;
      signal rx_align_err_rcvd        : integer := -1;
      signal rx_crc_err_sent          : integer := -1;
      signal rx_crc_err_rcvd          : integer := -1;        
      signal rx_gmii_err_sent         : integer := -1;
      signal rx_gmii_err_rcvd         : integer := -1;
      signal rx_length_err_rcvd       : integer := -1;
      signal rx_length_mismatch_rcvd  : integer := -1;        
      signal rx_vlan_sent             : integer := -1;
      signal rx_stack_vlan_sent       : integer := -1;
      signal rx_vlan_rcvd             : integer := -1;
      signal rx_stack_vlan_rcvd       : integer := -1;
      signal rx_vlan_wrong_type_sent  : integer := -1;    
      signal rx_discard_sent          : integer := -1;                        -- frame sent that should have been discarded
      signal rx_non_discard_rcvd      : integer := -1;                        -- frames discarded on receive
      signal rx_discard_rcvd          : integer := -1;                        -- frame_cnt - non_discard_rcvd    
      signal rx_wrong_status_sent     : integer := -1;                        -- sent frame that will be pushed into FIFO but with error status
      signal rx_wrong_status_rcvd     : integer := -1;        
      signal rx_payload_err_sent      : integer := -1;
      signal rx_payload_err_rcvd      : integer := -1;
      signal mff_rxcnt                : integer := -1;                
      signal rx_wrong_mac_sent        : integer := -1;
      signal rx_wrong_mac_rcvd        : integer := -1;        
      signal rx_broadcast_sent        : integer := -1;
      signal rx_broadcast_rcvd        : integer := -1;        
      signal rx_multicast_sent_total  : integer := -1;
      signal rx_multicast_sent        : integer := -1;
      signal rx_multicast_rcvd        : integer := -1;
      signal rx_multicast_denied      : integer := -1;
      signal rx_unexpected            : integer := -1;
      signal rx_fifo_overflow_rcvd    : integer := -1;        
      signal rx_col_sent              : integer := -1 ;
      signal tx_col_sent              : integer := -1 ;
      signal tx_pause_sent            : integer := -1;            
      signal rx_col_rcvd              : integer := -1 ;        
        
   -- Control State Machine
   -- ---------------------
   
      type stm_typ is (IDLE, READ_VER, WR_SCRATCH, RD_SCRATCH, WRITE_MDIO1, READ_MDIO1, 
                       MAC_CONFIG, WR_MAC1, WR_MAC2, WR_RX_AE, WR_RX_AF, WR_TX_AE, WR_TX_AF, 
                       WR_RX_SE, WR_RX_SF, WR_TX_SE, WR_TX_SF, WR_IPG_LEN,
                       LUT_PROG, LUT_PROG_INC,WR_FRM_LENGTH, WR_PAUSE_QUANTA, WR_MDIO_ADDR1,
                       SIM, END_SIM_WAIT, WR_SUP_MAC0_0, WR_SUP_MAC0_1, WR_SUP_MAC1_0, WR_SUP_MAC1_1,
                       WR_SUP_MAC2_0, WR_SUP_MAC2_1, WR_SUP_MAC3_0, WR_SUP_MAC3_1,
                       RD_FRM_TX, RD_FRM_RX, RD_CRC_ERR, RD_ALIGN_ERR, RD_TX_OCTETS, RD_RX_OCTETS, RD_PAUSE_RX, 
                       RD_PAUSE_TX, RX_UNICAST, RX_MLTCAST, RX_BRDCAST,
                       TX_FRM_DISCARD, TX_UNICAST, TX_MLTCAST, TX_BRDCAST, RX_FRM_ERR, TX_FRM_ERR,
                       RX_FRM_DROP, RX_UNDERSZ_FRM, RX_OVERSZ_FRM, RX_64_FRM, RX_65_127_FRM, RX_128_255_FRM,
                       RX_256_511_FRM, RX_512_1023_FRM, RX_1024_1518_FRM, RX_1519_X_FRM, RX_JABBER, RX_FRAGMENT,
                       SW_RESET, RD_SW_RESET, WR_ENA_MAGIC, NODE_SLEEP1, GEN_MAGIC, NODE_SLEEP2, NODE_ON,
                       END_SIM1, END_SIM,
                       pcs_read_ver, pcs_wr_scratch, pcs_rd_scratch, pcs_read_phy_control, pcs_read_sync_status,
                       pcs_prog_ability, pcs_prog_timer_1, pcs_prog_timer_2, pcs_autoneg_enable, pcs_start_autoneg,
                       pcs_wait_autoneg, pcs_read_autoneg_expansion, pcs_read_autoneg_status, read_part_ability,
                       pcs_wait_link, 
  --                         pcs_sim, 
                       pcs_stop_tbi, pcs_start_tbi, pcs_read_status, pcs_read_status_2, pcs_ena_sw_reset,
                       pcs_read_sw_reset, pcs_disable_isolate, 
  --                         pcs_end_sim, 
                       pcs_autoneg_disable, pcs_if_control) ;

       signal state            : stm_typ ;
       signal nextstate        : stm_typ ;
       signal sim_cnt_end      : integer ;
       signal re_read_ena      : boolean := FALSE ;
        
   -- Hash Table Program Control
   -- --------------------------
   
       signal lut_prog_cnt             : integer range 0 to 64 := 0 ; 
        
   -- Half Duplex Colision Control
   -- ----------------------------

       signal rx_nib_cnt           : integer ;                             -- Nibble Counter
       signal tx_nib_cnt           : integer ;                             -- Nibble Counter
       signal tx_col_reg           : std_logic;                            -- Packet Transmitted with Col                
       signal tx_col_reg_fd        : std_logic;                            -- Packet Transmitted with Col                
       signal tx_col_reg_hd        : std_logic;                            -- Packet Transmitted with Col   

               
   -- register write/read test
   -- ----------------------------
        signal readback_scratch     : std_logic_vector(31 downto 0) ;
        signal readback_MDIO0_addr0 : std_logic_vector(15 downto 0) ;
        signal readback_MDIO1_addr0 : std_logic_vector(15 downto 0) ;
        
        signal register_test        : integer;
        shared variable reg_iteration: natural;  
               
begin

   -- global settings
   -- ---------------
   
        jumbo_enable    <= '1' when (TB_MACLENMAX >1522) else '0';   -- enable monitors for long frames
	-- MAGIC PACKET WIRING
		reg_wakeup <= magic_wakeup;	        
   -- Reset Control and start simulation
   -- -------------

        reset       <= '0', '1' after 50 ns, '0' after 2000 ns ;           
        sim_start   <= '1' when ((tx_ready = '1') and (rx_ready = '1')) else '0';

   -- Clocks
   -- ------
   
        ethernet_mode <= '1' when ETH_MODE=1000 else '0';
        tx_clk <= tx_clk_10mbps when ETH_MODE=10 else tx_clk_100mbps when ETH_MODE=100 else tx_clk_1000mbps;
        rx_clk <= rx_clk_10mbps when ETH_MODE=10 else rx_clk_100mbps when ETH_MODE=100 else rx_clk_1000mbps;        
        ref_clk <= ref_clk_1000mbps;          

        
        --E1000_GEN: if (ETH_MODE=1000) generate
        --begin
                
                --ethernet_mode <= '1' ;
   
                CLK_NOLOOP: if( TB_RXFRAMES/=0) generate        -- RX extra test, generate own clock
                 
                        process
                        begin
        
                rx_clk_1000mbps <= '0' ;
                                wait for 4 ns ;
                rx_clk_1000mbps <= '1' ;
                                wait for 4 ns ; 
                
                        end process ;     
        
                end generate;
        
                CLK_LOOPBACK: if( TB_RXFRAMES=0) generate      -- RX Loopback, use TX Clock
            
                        rx_clk_1000mbps <= tx_clk_1000mbps;
            
                end generate;    
                
                process
                begin
        
                tx_clk_1000mbps  <= '1' ;
                ref_clk_1000mbps <= '1' ;
                        wait for 4 ns ;
                tx_clk_1000mbps  <= '0' ;
                ref_clk_1000mbps <= '0' ;
                        wait for 4 ns ; 
                
                end process ; 
                
        --end generate ;
        
        --E100_GEN: if (ETH_MODE=100) generate
        --begin
        
                --ethernet_mode <= '0' ;
   
                CLK_NOLOOP_100: if( TB_RXFRAMES/=0) generate        -- RX extra test, generate own clock
                 
                        process
                        begin
        
                rx_clk_100mbps <= '0' ;
                                wait for 20 ns ;
                rx_clk_100mbps <= '1' ;
                                wait for 20 ns ; 
                
                        end process ;     
        
                end generate;
        
                CLK_LOOPBACK_100: if( TB_RXFRAMES=0) generate      -- RX Loopback, use TX Clock
            
                        rx_clk_100mbps <= tx_clk_100mbps;
            
                end generate;    
                
                process
                begin
        
                tx_clk_100mbps <= '1' ;
                        wait for 20 ns ;
                tx_clk_100mbps <= '0' ;
                        wait for 20 ns ; 
                
                end process ; 
                
                
        --end generate ; 
        
        --E10_GEN: if (ETH_MODE=10) generate
        --begin
        
                --ethernet_mode <= '0' ;
   
                CLK_NOLOOP_10: if( TB_RXFRAMES/=0) generate        -- RX extra test, generate own clock
                 
                        process
                        begin
        
                                rx_clk_10mbps <= '0' ;
                                wait for 200 ns ;
                                rx_clk_10mbps <= '1' ;
                                wait for 200 ns ; 
                
                        end process ;     
        
                end generate;
        
                CLK_LOOPBACK_10: if( TB_RXFRAMES=0) generate      -- RX Loopback, use TX Clock
            
                        rx_clk_10mbps <= tx_clk_10mbps;
            
                end generate;    
                
                process
                begin
        
                        tx_clk_10mbps <= '1' ;
                        wait for 200 ns ;
                        tx_clk_10mbps <= '0' ;
                        wait for 200 ns ; 
                
                end process ;
                
        --end generate ;  
        
        process
        begin
        
                ff_rx_clk_internal <= '1' ;
                wait for 4 ns;
                ff_rx_clk_internal <= '0' ;
                wait for 4 ns ; 
                
        end process ;                

        process
        begin
        
                ff_tx_clk_internal <= '1' ;
                wait for 4 ns;
                ff_tx_clk_internal <= '0' ;
                wait for 4 ns; 
                
        end process ;   

   -- Collision Control
   -- -----------------
   
        GEN_NHD: if (HD_ENA=FALSE) generate
        begin
        
                m_rx_crs   <= '0' ;
                m_rx_col   <= '0' ;
                tx_col_reg <= '0' ;
               
        end generate ;          

   -- Half Duplex Control
   -- -------------------
   
        GEN_HD: if (HD_ENA=TRUE and ENABLE_HD_LOGIC=1) generate
        begin
        
           -- RX
           -- --
        
                process(reset, rx_clk)
                begin
                
                        if (reset='1') then
                        
                                rx_nib_cnt     <= 0 ;
                                rx_col_sent <= 0 ;
                                
                        elsif (rx_clk='1') and (rx_clk'event) then
                        
                                if (m_rx_en='1') then
                                
                                        rx_nib_cnt <= rx_nib_cnt+1 ;
                                        
                                else
                                
                                        rx_nib_cnt <= 0 ;
                                        
                                end if ;
                                
                                if (m_rx_col='1' and rx_nib_cnt=RX_COL_GEN) then
                                
                                        rx_col_sent <= rx_col_sent+1 ;
                                        
                                end if ;        
                                
                        end if ;
                        
                end process ;
                
           -- Collision Control
           -- -----------------
                
                process(rxframe_cnt, rx_nib_cnt, m_rx_en, tx_frm_all, tx_nib_cnt)
                begin
                
                        if (TB_RXFRAMES>0 and rxframe_cnt=RX_COL_FRM and (rx_nib_cnt>=RX_COL_GEN and rx_nib_cnt<=RX_COL_GEN+4) and m_rx_en='1') then
                                
                                if (RX_COL_FRM>0) then
                                
                                        m_rx_col    <= '1' ;
                                        
                                else
                                
                                        m_rx_col <= '0' ;
                                        
                                end if ;
                                
                        elsif (tx_frm_all=TX_COL_FRM-1 and tx_nib_cnt>=TX_COL_GEN and tx_nib_cnt<=TX_COL_GEN+4) then
                        
                                if (TX_COL_FRM>0) then
                                
                                        m_rx_col    <= '1' ;
                                        
                                else
                                
                                        m_rx_col <= '0' ;
                                        
                                end if ;
                                                              
                        elsif (tx_frm_all>TX_COL_FRM-1 and tx_frm_all<TX_COL_FRM+TX_COL_NUM-1 and 
                               tx_nib_cnt>=TX_COL_GEN+(tx_frm_all-gm_txcnt)*TX_COL_DELAY and tx_nib_cnt<=TX_COL_GEN+(tx_frm_all-gm_txcnt)*TX_COL_DELAY+4) then
                                        
                                if (TX_COL_FRM>0) then
                                
                                        m_rx_col    <= '1' ;
                                        
                                else
                                
                                        m_rx_col <= '0' ;
                                        
                                end if ;
                        
                        else
                                
                                m_rx_col <= '0' ;
                                                                        
                        end if ;
                        
                end process ;
                
           -- TX
           -- --
           
                m_rx_crs <= '1' when (m_rx_en='1' or m_tx_en='1') else '0' ; 
                
                process(reset, tx_clk)
                begin
                
                        if (reset='1') then
                        
                                tx_nib_cnt  <= 0 ;
                                tx_col_sent <= 0 ;
                                tx_col_reg  <= '0' ;
                                
                        elsif (tx_clk='1') and (tx_clk'event) then
                        
                                if (m_tx_en='1') then
                                
                                        tx_nib_cnt <= tx_nib_cnt+1 ;
                                        
                                else
                                
                                        tx_nib_cnt <= 0 ;
                                        
                                end if ;
                                
                                if (m_rx_col='1' and tx_nib_cnt=TX_COL_GEN) then
                                
                                        tx_col_sent <= rx_col_sent+1 ;
                                        
                                end if ;   
                                
                                if (m_rx_col='1' and m_tx_en='1') then
                                
                                        tx_col_reg <= '1' ;
                                        
                                elsif (m_mgm_frm_rcvd='1') then
                                
                                        tx_col_reg <= '0' ;
                                        
                                end if ;    
                                
                        end if ;
                        
                end process ;                    
                
        end generate ; 
        
   -- -------------------------------------------------------------------
   -- Ethernet MAC Core        
   -- -------------------------------------------------------------------
                   
        ff_tx_crc_fwd <= '0' ;
        set_1000      <= '0' ;
        set_10        <= '0' ;
        magic_sleep_n    <= '0' after 300 ns when ((nextstate=NODE_SLEEP1 or nextstate=NODE_SLEEP2 or nextstate=GEN_MAGIC) and ENA_SLEEP_PIN) else '1' ;
        

  DUT_with_internal_FIFO: if (ENABLE_ENA = 8) generate --DUT core with internal FIFO
   begin
    
    ff_tx_clk        <= ff_tx_clk_internal;
    ff_rx_clk        <= ff_rx_clk_internal;
    ff_rx_err_stat  <=  rx_err_stat(17) &  rx_err(5) & rx_err_stat(15 downto 0) & rx_err_stat(16) & rx_err(4 downto 1); 
    ff_rx_err       <=  rx_err(0);
    ff_rx_vlan      <=  rx_frm_type(3); 
    ff_rx_bcast     <=  rx_frm_type(2);
    ff_rx_mcast     <=  rx_frm_type(1);
    ff_rx_ucast     <=  rx_frm_type(0);
    rxp         <= txp ;
    tbi_tx_clk       <= tx_clk_1000mbps;
    tbi_rx_clk       <= rx_clk_1000mbps;

   end generate;

   
  
  Single_DUT_without_FIFO_Timestamping: if (MAX_CHANNELS >= 1) generate
   begin
     pcs_phase_measure_clk <= ref_clk;
     
     rx_time_of_day_96b_data_0 <= X"000000000000000000000000";
     rx_time_of_day_64b_data_0 <= X"0000000000000000";
     tx_time_of_day_96b_data_0 <= X"000000000000000000000000";
     tx_time_of_day_64b_data_0 <= X"0000000000000000";
     tx_egress_timestamp_request_valid_0 			<= '0';
     tx_egress_timestamp_request_fingerprint_0 		<= conv_std_logic_vector(0, TSTAMP_FP_WIDTH);
     tx_etstamp_ins_ctrl_ingress_timestamp_96b_0 	<= X"000000000000000000000000";
     tx_etstamp_ins_ctrl_ingress_timestamp_64b_0 	<= X"0000000000000000";
     tx_etstamp_ins_ctrl_timestamp_insert_0 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_update_0 	<= '0';
     tx_etstamp_ins_ctrl_checksum_zero_0 			<= '0';
     tx_etstamp_ins_ctrl_checksum_correct_0 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_calc_format_0 <= '0';
     tx_etstamp_ins_ctrl_timestamp_format_0 		<= '0';
	 tx_etstamp_ins_ctrl_offset_timestamp_0 		<= X"0000";
	 tx_etstamp_ins_ctrl_offset_correction_field_0 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_field_0 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_correction_0 <= X"0000";
   end generate;
   
   FourPort_DUT_without_FIFO_Timestamping: if (MAX_CHANNELS >= 4) generate
   begin
     rx_time_of_day_96b_data_1 <= X"000000000000000000000000";
     rx_time_of_day_64b_data_1 <= X"0000000000000000";
     tx_time_of_day_96b_data_1 <= X"000000000000000000000000";
     tx_time_of_day_64b_data_1 <= X"0000000000000000";
     tx_egress_timestamp_request_valid_1 			<= '0';
     tx_egress_timestamp_request_fingerprint_1 		<= conv_std_logic_vector(0, TSTAMP_FP_WIDTH);
     tx_etstamp_ins_ctrl_ingress_timestamp_96b_1 	<= X"000000000000000000000000";
     tx_etstamp_ins_ctrl_ingress_timestamp_64b_1 	<= X"0000000000000000";
     tx_etstamp_ins_ctrl_timestamp_insert_1 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_update_1 	<= '0';
     tx_etstamp_ins_ctrl_checksum_zero_1 			<= '0';
     tx_etstamp_ins_ctrl_checksum_correct_1 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_calc_format_1 <= '0';
     tx_etstamp_ins_ctrl_timestamp_format_1 		<= '0';
	 tx_etstamp_ins_ctrl_offset_timestamp_1 		<= X"0000";
	 tx_etstamp_ins_ctrl_offset_correction_field_1 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_field_1 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_correction_1 <= X"0000";
	 
     rx_time_of_day_96b_data_2 <= X"000000000000000000000000";
     rx_time_of_day_64b_data_2 <= X"0000000000000000";
     tx_time_of_day_96b_data_2 <= X"000000000000000000000000";
     tx_time_of_day_64b_data_2 <= X"0000000000000000";
     tx_egress_timestamp_request_valid_2 			<= '0';
     tx_egress_timestamp_request_fingerprint_2 		<= conv_std_logic_vector(0, TSTAMP_FP_WIDTH);
     tx_etstamp_ins_ctrl_ingress_timestamp_96b_2 	<= X"000000000000000000000000";
     tx_etstamp_ins_ctrl_ingress_timestamp_64b_2 	<= X"0000000000000000";
     tx_etstamp_ins_ctrl_timestamp_insert_2 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_update_2 	<= '0';
     tx_etstamp_ins_ctrl_checksum_zero_2 			<= '0';
     tx_etstamp_ins_ctrl_checksum_correct_2 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_calc_format_2 <= '0';
     tx_etstamp_ins_ctrl_timestamp_format_2 		<= '0';
	 tx_etstamp_ins_ctrl_offset_timestamp_2 		<= X"0000";
	 tx_etstamp_ins_ctrl_offset_correction_field_2 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_field_2 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_correction_2 <= X"0000";

     rx_time_of_day_96b_data_3 <= X"000000000000000000000000";
     rx_time_of_day_64b_data_3 <= X"0000000000000000";
     tx_time_of_day_96b_data_3 <= X"000000000000000000000000";
     tx_time_of_day_64b_data_3 <= X"0000000000000000";
     tx_egress_timestamp_request_valid_3 			<= '0';
     tx_egress_timestamp_request_fingerprint_3 		<= conv_std_logic_vector(0, TSTAMP_FP_WIDTH);
     tx_etstamp_ins_ctrl_ingress_timestamp_96b_3 	<= X"000000000000000000000000";
     tx_etstamp_ins_ctrl_ingress_timestamp_64b_3 	<= X"0000000000000000";
     tx_etstamp_ins_ctrl_timestamp_insert_3 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_update_3 	<= '0';
     tx_etstamp_ins_ctrl_checksum_zero_3 			<= '0';
     tx_etstamp_ins_ctrl_checksum_correct_3 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_calc_format_3 <= '0';
     tx_etstamp_ins_ctrl_timestamp_format_3 		<= '0';
	 tx_etstamp_ins_ctrl_offset_timestamp_3 		<= X"0000";
	 tx_etstamp_ins_ctrl_offset_correction_field_3 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_field_3 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_correction_3 <= X"0000";	 
   end generate;
   
   EightPort_DUT_without_FIFO_Timestamping: if (MAX_CHANNELS >= 8) generate
   begin
     rx_time_of_day_96b_data_4 <= X"000000000000000000000000";
     rx_time_of_day_64b_data_4 <= X"0000000000000000";
     tx_time_of_day_96b_data_4 <= X"000000000000000000000000";
     tx_time_of_day_64b_data_4 <= X"0000000000000000";
     tx_egress_timestamp_request_valid_4 			<= '0';
     tx_egress_timestamp_request_fingerprint_4 		<= conv_std_logic_vector(0, TSTAMP_FP_WIDTH);
     tx_etstamp_ins_ctrl_ingress_timestamp_96b_4 	<= X"000000000000000000000000";
     tx_etstamp_ins_ctrl_ingress_timestamp_64b_4 	<= X"0000000000000000";
     tx_etstamp_ins_ctrl_timestamp_insert_4 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_update_4 	<= '0';
     tx_etstamp_ins_ctrl_checksum_zero_4 			<= '0';
     tx_etstamp_ins_ctrl_checksum_correct_4 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_calc_format_4 <= '0';
     tx_etstamp_ins_ctrl_timestamp_format_4 		<= '0';
	 tx_etstamp_ins_ctrl_offset_timestamp_4 		<= X"0000";
	 tx_etstamp_ins_ctrl_offset_correction_field_4 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_field_4 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_correction_4 <= X"0000";
	 
     rx_time_of_day_96b_data_5 <= X"000000000000000000000000";
     rx_time_of_day_64b_data_5 <= X"0000000000000000";
     tx_time_of_day_96b_data_5 <= X"000000000000000000000000";
     tx_time_of_day_64b_data_5 <= X"0000000000000000";
     tx_egress_timestamp_request_valid_5 			<= '0';
     tx_egress_timestamp_request_fingerprint_5 		<= conv_std_logic_vector(0, TSTAMP_FP_WIDTH);
     tx_etstamp_ins_ctrl_ingress_timestamp_96b_5 	<= X"000000000000000000000000";
     tx_etstamp_ins_ctrl_ingress_timestamp_64b_5 	<= X"0000000000000000";
     tx_etstamp_ins_ctrl_timestamp_insert_5 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_update_5 	<= '0';
     tx_etstamp_ins_ctrl_checksum_zero_5 			<= '0';
     tx_etstamp_ins_ctrl_checksum_correct_5 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_calc_format_5 <= '0';
     tx_etstamp_ins_ctrl_timestamp_format_5 		<= '0';
	 tx_etstamp_ins_ctrl_offset_timestamp_5 		<= X"0000";
	 tx_etstamp_ins_ctrl_offset_correction_field_5 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_field_5 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_correction_5 <= X"0000";

     rx_time_of_day_96b_data_6 <= X"000000000000000000000000";
     rx_time_of_day_64b_data_6 <= X"0000000000000000";
     tx_time_of_day_96b_data_6 <= X"000000000000000000000000";
     tx_time_of_day_64b_data_6 <= X"0000000000000000";
     tx_egress_timestamp_request_valid_6 			<= '0';
     tx_egress_timestamp_request_fingerprint_6 		<= conv_std_logic_vector(0, TSTAMP_FP_WIDTH);
     tx_etstamp_ins_ctrl_ingress_timestamp_96b_6 	<= X"000000000000000000000000";
     tx_etstamp_ins_ctrl_ingress_timestamp_64b_6 	<= X"0000000000000000";
     tx_etstamp_ins_ctrl_timestamp_insert_6 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_update_6 	<= '0';
     tx_etstamp_ins_ctrl_checksum_zero_6 			<= '0';
     tx_etstamp_ins_ctrl_checksum_correct_6 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_calc_format_6 <= '0';
     tx_etstamp_ins_ctrl_timestamp_format_6 		<= '0';
	 tx_etstamp_ins_ctrl_offset_timestamp_6 		<= X"0000";
	 tx_etstamp_ins_ctrl_offset_correction_field_6 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_field_6 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_correction_6 <= X"0000";

     rx_time_of_day_96b_data_7 <= X"000000000000000000000000";
     rx_time_of_day_64b_data_7 <= X"0000000000000000";
     tx_time_of_day_96b_data_7 <= X"000000000000000000000000";
     tx_time_of_day_64b_data_7 <= X"0000000000000000";
     tx_egress_timestamp_request_valid_7 			<= '0';
     tx_egress_timestamp_request_fingerprint_7 		<= conv_std_logic_vector(0, TSTAMP_FP_WIDTH);
     tx_etstamp_ins_ctrl_ingress_timestamp_96b_7 	<= X"000000000000000000000000";
     tx_etstamp_ins_ctrl_ingress_timestamp_64b_7 	<= X"0000000000000000";
     tx_etstamp_ins_ctrl_timestamp_insert_7 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_update_7 	<= '0';
     tx_etstamp_ins_ctrl_checksum_zero_7 			<= '0';
     tx_etstamp_ins_ctrl_checksum_correct_7 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_calc_format_7 <= '0';
     tx_etstamp_ins_ctrl_timestamp_format_7 		<= '0';
	 tx_etstamp_ins_ctrl_offset_timestamp_7 		<= X"0000";
	 tx_etstamp_ins_ctrl_offset_correction_field_7 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_field_7 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_correction_7 <= X"0000";	 
   end generate;
   
   TwelvePort_DUT_without_FIFO_Timestamping: if (MAX_CHANNELS >= 12) generate
   begin
     rx_time_of_day_96b_data_8 <= X"000000000000000000000000";
     rx_time_of_day_64b_data_8 <= X"0000000000000000";
     tx_time_of_day_96b_data_8 <= X"000000000000000000000000";
     tx_time_of_day_64b_data_8 <= X"0000000000000000";
     tx_egress_timestamp_request_valid_8 			<= '0';
     tx_egress_timestamp_request_fingerprint_8 		<= conv_std_logic_vector(0, TSTAMP_FP_WIDTH);
     tx_etstamp_ins_ctrl_ingress_timestamp_96b_8 	<= X"000000000000000000000000";
     tx_etstamp_ins_ctrl_ingress_timestamp_64b_8 	<= X"0000000000000000";
     tx_etstamp_ins_ctrl_timestamp_insert_8 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_update_8 	<= '0';
     tx_etstamp_ins_ctrl_checksum_zero_8 			<= '0';
     tx_etstamp_ins_ctrl_checksum_correct_8 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_calc_format_8 <= '0';
     tx_etstamp_ins_ctrl_timestamp_format_8 		<= '0';
	 tx_etstamp_ins_ctrl_offset_timestamp_8 		<= X"0000";
	 tx_etstamp_ins_ctrl_offset_correction_field_8 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_field_8 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_correction_8 <= X"0000";
	 
     rx_time_of_day_96b_data_9 <= X"000000000000000000000000";
     rx_time_of_day_64b_data_9 <= X"0000000000000000";
     tx_time_of_day_96b_data_9 <= X"000000000000000000000000";
     tx_time_of_day_64b_data_9 <= X"0000000000000000";
     tx_egress_timestamp_request_valid_9 			<= '0';
     tx_egress_timestamp_request_fingerprint_9 		<= conv_std_logic_vector(0, TSTAMP_FP_WIDTH);
     tx_etstamp_ins_ctrl_ingress_timestamp_96b_9 	<= X"000000000000000000000000";
     tx_etstamp_ins_ctrl_ingress_timestamp_64b_9 	<= X"0000000000000000";
     tx_etstamp_ins_ctrl_timestamp_insert_9 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_update_9 	<= '0';
     tx_etstamp_ins_ctrl_checksum_zero_9 			<= '0';
     tx_etstamp_ins_ctrl_checksum_correct_9 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_calc_format_9 <= '0';
     tx_etstamp_ins_ctrl_timestamp_format_9 		<= '0';
	 tx_etstamp_ins_ctrl_offset_timestamp_9 		<= X"0000";
	 tx_etstamp_ins_ctrl_offset_correction_field_9 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_field_9 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_correction_9 <= X"0000";

     rx_time_of_day_96b_data_10 <= X"000000000000000000000000";
     rx_time_of_day_64b_data_10 <= X"0000000000000000";
     tx_time_of_day_96b_data_10 <= X"000000000000000000000000";
     tx_time_of_day_64b_data_10 <= X"0000000000000000";
     tx_egress_timestamp_request_valid_10 			<= '0';
     tx_egress_timestamp_request_fingerprint_10 		<= conv_std_logic_vector(0, TSTAMP_FP_WIDTH);
     tx_etstamp_ins_ctrl_ingress_timestamp_96b_10 	<= X"000000000000000000000000";
     tx_etstamp_ins_ctrl_ingress_timestamp_64b_10 	<= X"0000000000000000";
     tx_etstamp_ins_ctrl_timestamp_insert_10 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_update_10 	<= '0';
     tx_etstamp_ins_ctrl_checksum_zero_10 			<= '0';
     tx_etstamp_ins_ctrl_checksum_correct_10 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_calc_format_10 <= '0';
     tx_etstamp_ins_ctrl_timestamp_format_10 		<= '0';
	 tx_etstamp_ins_ctrl_offset_timestamp_10 		<= X"0000";
	 tx_etstamp_ins_ctrl_offset_correction_field_10 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_field_10 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_correction_10 <= X"0000";

     rx_time_of_day_96b_data_11 <= X"000000000000000000000000";
     rx_time_of_day_64b_data_11 <= X"0000000000000000";
     tx_time_of_day_96b_data_11 <= X"000000000000000000000000";
     tx_time_of_day_64b_data_11 <= X"0000000000000000";
     tx_egress_timestamp_request_valid_11 			<= '0';
     tx_egress_timestamp_request_fingerprint_11 		<= conv_std_logic_vector(0, TSTAMP_FP_WIDTH);
     tx_etstamp_ins_ctrl_ingress_timestamp_96b_11 	<= X"000000000000000000000000";
     tx_etstamp_ins_ctrl_ingress_timestamp_64b_11 	<= X"0000000000000000";
     tx_etstamp_ins_ctrl_timestamp_insert_11 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_update_11 	<= '0';
     tx_etstamp_ins_ctrl_checksum_zero_11 			<= '0';
     tx_etstamp_ins_ctrl_checksum_correct_11 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_calc_format_11 <= '0';
     tx_etstamp_ins_ctrl_timestamp_format_11 		<= '0';
	 tx_etstamp_ins_ctrl_offset_timestamp_11 		<= X"0000";
	 tx_etstamp_ins_ctrl_offset_correction_field_11 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_field_11 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_correction_11 <= X"0000";	 
   end generate;
   
   SixteenPort_DUT_without_FIFO_Timestamping: if (MAX_CHANNELS >= 16) generate
   begin
     rx_time_of_day_96b_data_12 <= X"000000000000000000000000";
     rx_time_of_day_64b_data_12 <= X"0000000000000000";
     tx_time_of_day_96b_data_12 <= X"000000000000000000000000";
     tx_time_of_day_64b_data_12 <= X"0000000000000000";
     tx_egress_timestamp_request_valid_12 			<= '0';
     tx_egress_timestamp_request_fingerprint_12 		<= conv_std_logic_vector(0, TSTAMP_FP_WIDTH);
     tx_etstamp_ins_ctrl_ingress_timestamp_96b_12 	<= X"000000000000000000000000";
     tx_etstamp_ins_ctrl_ingress_timestamp_64b_12 	<= X"0000000000000000";
     tx_etstamp_ins_ctrl_timestamp_insert_12 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_update_12 	<= '0';
     tx_etstamp_ins_ctrl_checksum_zero_12 			<= '0';
     tx_etstamp_ins_ctrl_checksum_correct_12 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_calc_format_12 <= '0';
     tx_etstamp_ins_ctrl_timestamp_format_12 		<= '0';
	 tx_etstamp_ins_ctrl_offset_timestamp_12 		<= X"0000";
	 tx_etstamp_ins_ctrl_offset_correction_field_12 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_field_12 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_correction_12 <= X"0000";
	 
     rx_time_of_day_96b_data_13 <= X"000000000000000000000000";
     rx_time_of_day_64b_data_13 <= X"0000000000000000";
     tx_time_of_day_96b_data_13 <= X"000000000000000000000000";
     tx_time_of_day_64b_data_13 <= X"0000000000000000";
     tx_egress_timestamp_request_valid_13 			<= '0';
     tx_egress_timestamp_request_fingerprint_13 		<= conv_std_logic_vector(0, TSTAMP_FP_WIDTH);
     tx_etstamp_ins_ctrl_ingress_timestamp_96b_13 	<= X"000000000000000000000000";
     tx_etstamp_ins_ctrl_ingress_timestamp_64b_13 	<= X"0000000000000000";
     tx_etstamp_ins_ctrl_timestamp_insert_13 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_update_13 	<= '0';
     tx_etstamp_ins_ctrl_checksum_zero_13 			<= '0';
     tx_etstamp_ins_ctrl_checksum_correct_13 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_calc_format_13 <= '0';
     tx_etstamp_ins_ctrl_timestamp_format_13 		<= '0';
	 tx_etstamp_ins_ctrl_offset_timestamp_13 		<= X"0000";
	 tx_etstamp_ins_ctrl_offset_correction_field_13 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_field_13 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_correction_13 <= X"0000";

     rx_time_of_day_96b_data_14 <= X"000000000000000000000000";
     rx_time_of_day_64b_data_14 <= X"0000000000000000";
     tx_time_of_day_96b_data_14 <= X"000000000000000000000000";
     tx_time_of_day_64b_data_14 <= X"0000000000000000";
     tx_egress_timestamp_request_valid_14 			<= '0';
     tx_egress_timestamp_request_fingerprint_14 		<= conv_std_logic_vector(0, TSTAMP_FP_WIDTH);
     tx_etstamp_ins_ctrl_ingress_timestamp_96b_14 	<= X"000000000000000000000000";
     tx_etstamp_ins_ctrl_ingress_timestamp_64b_14 	<= X"0000000000000000";
     tx_etstamp_ins_ctrl_timestamp_insert_14 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_update_14 	<= '0';
     tx_etstamp_ins_ctrl_checksum_zero_14 			<= '0';
     tx_etstamp_ins_ctrl_checksum_correct_14 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_calc_format_14 <= '0';
     tx_etstamp_ins_ctrl_timestamp_format_14 		<= '0';
	 tx_etstamp_ins_ctrl_offset_timestamp_14 		<= X"0000";
	 tx_etstamp_ins_ctrl_offset_correction_field_14 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_field_14 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_correction_14 <= X"0000";

     rx_time_of_day_96b_data_15 <= X"000000000000000000000000";
     rx_time_of_day_64b_data_15 <= X"0000000000000000";
     tx_time_of_day_96b_data_15 <= X"000000000000000000000000";
     tx_time_of_day_64b_data_15 <= X"0000000000000000";
     tx_egress_timestamp_request_valid_15 			<= '0';
     tx_egress_timestamp_request_fingerprint_15 		<= conv_std_logic_vector(0, TSTAMP_FP_WIDTH);
     tx_etstamp_ins_ctrl_ingress_timestamp_96b_15 	<= X"000000000000000000000000";
     tx_etstamp_ins_ctrl_ingress_timestamp_64b_15 	<= X"0000000000000000";
     tx_etstamp_ins_ctrl_timestamp_insert_15 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_update_15 	<= '0';
     tx_etstamp_ins_ctrl_checksum_zero_15 			<= '0';
     tx_etstamp_ins_ctrl_checksum_correct_15 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_calc_format_15 <= '0';
     tx_etstamp_ins_ctrl_timestamp_format_15 		<= '0';
	 tx_etstamp_ins_ctrl_offset_timestamp_15 		<= X"0000";
	 tx_etstamp_ins_ctrl_offset_correction_field_15 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_field_15 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_correction_15 <= X"0000";	 
   end generate;
   
   TwentyPort_DUT_without_FIFO_Timestamping: if (MAX_CHANNELS >= 20) generate
   begin
     rx_time_of_day_96b_data_16 <= X"000000000000000000000000";
     rx_time_of_day_64b_data_16 <= X"0000000000000000";
     tx_time_of_day_96b_data_16 <= X"000000000000000000000000";
     tx_time_of_day_64b_data_16 <= X"0000000000000000";
     tx_egress_timestamp_request_valid_16 			<= '0';
     tx_egress_timestamp_request_fingerprint_16 		<= conv_std_logic_vector(0, TSTAMP_FP_WIDTH);
     tx_etstamp_ins_ctrl_ingress_timestamp_96b_16 	<= X"000000000000000000000000";
     tx_etstamp_ins_ctrl_ingress_timestamp_64b_16 	<= X"0000000000000000";
     tx_etstamp_ins_ctrl_timestamp_insert_16 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_update_16 	<= '0';
     tx_etstamp_ins_ctrl_checksum_zero_16 			<= '0';
     tx_etstamp_ins_ctrl_checksum_correct_16 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_calc_format_16 <= '0';
     tx_etstamp_ins_ctrl_timestamp_format_16 		<= '0';
	 tx_etstamp_ins_ctrl_offset_timestamp_16 		<= X"0000";
	 tx_etstamp_ins_ctrl_offset_correction_field_16 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_field_16 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_correction_16 <= X"0000";
	 
     rx_time_of_day_96b_data_17 <= X"000000000000000000000000";
     rx_time_of_day_64b_data_17 <= X"0000000000000000";
     tx_time_of_day_96b_data_17 <= X"000000000000000000000000";
     tx_time_of_day_64b_data_17 <= X"0000000000000000";
     tx_egress_timestamp_request_valid_17 			<= '0';
     tx_egress_timestamp_request_fingerprint_17 		<= conv_std_logic_vector(0, TSTAMP_FP_WIDTH);
     tx_etstamp_ins_ctrl_ingress_timestamp_96b_17 	<= X"000000000000000000000000";
     tx_etstamp_ins_ctrl_ingress_timestamp_64b_17 	<= X"0000000000000000";
     tx_etstamp_ins_ctrl_timestamp_insert_17 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_update_17 	<= '0';
     tx_etstamp_ins_ctrl_checksum_zero_17 			<= '0';
     tx_etstamp_ins_ctrl_checksum_correct_17 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_calc_format_17 <= '0';
     tx_etstamp_ins_ctrl_timestamp_format_17 		<= '0';
	 tx_etstamp_ins_ctrl_offset_timestamp_17 		<= X"0000";
	 tx_etstamp_ins_ctrl_offset_correction_field_17 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_field_17 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_correction_17 <= X"0000";

     rx_time_of_day_96b_data_18 <= X"000000000000000000000000";
     rx_time_of_day_64b_data_18 <= X"0000000000000000";
     tx_time_of_day_96b_data_18 <= X"000000000000000000000000";
     tx_time_of_day_64b_data_18 <= X"0000000000000000";
     tx_egress_timestamp_request_valid_18 			<= '0';
     tx_egress_timestamp_request_fingerprint_18 		<= conv_std_logic_vector(0, TSTAMP_FP_WIDTH);
     tx_etstamp_ins_ctrl_ingress_timestamp_96b_18 	<= X"000000000000000000000000";
     tx_etstamp_ins_ctrl_ingress_timestamp_64b_18 	<= X"0000000000000000";
     tx_etstamp_ins_ctrl_timestamp_insert_18 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_update_18 	<= '0';
     tx_etstamp_ins_ctrl_checksum_zero_18 			<= '0';
     tx_etstamp_ins_ctrl_checksum_correct_18 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_calc_format_18 <= '0';
     tx_etstamp_ins_ctrl_timestamp_format_18 		<= '0';
	 tx_etstamp_ins_ctrl_offset_timestamp_18 		<= X"0000";
	 tx_etstamp_ins_ctrl_offset_correction_field_18 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_field_18 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_correction_18 <= X"0000";

     rx_time_of_day_96b_data_19 <= X"000000000000000000000000";
     rx_time_of_day_64b_data_19 <= X"0000000000000000";
     tx_time_of_day_96b_data_19 <= X"000000000000000000000000";
     tx_time_of_day_64b_data_19 <= X"0000000000000000";
     tx_egress_timestamp_request_valid_19 			<= '0';
     tx_egress_timestamp_request_fingerprint_19 		<= conv_std_logic_vector(0, TSTAMP_FP_WIDTH);
     tx_etstamp_ins_ctrl_ingress_timestamp_96b_19 	<= X"000000000000000000000000";
     tx_etstamp_ins_ctrl_ingress_timestamp_64b_19 	<= X"0000000000000000";
     tx_etstamp_ins_ctrl_timestamp_insert_19 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_update_19 	<= '0';
     tx_etstamp_ins_ctrl_checksum_zero_19 			<= '0';
     tx_etstamp_ins_ctrl_checksum_correct_19 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_calc_format_19 <= '0';
     tx_etstamp_ins_ctrl_timestamp_format_19 		<= '0';
	 tx_etstamp_ins_ctrl_offset_timestamp_19 		<= X"0000";
	 tx_etstamp_ins_ctrl_offset_correction_field_19 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_field_19 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_correction_19 <= X"0000";	 
   end generate;
   
   TwentyfourPort_DUT_without_FIFO_Timestamping: if (MAX_CHANNELS >= 24) generate
   begin
     rx_time_of_day_96b_data_20 <= X"000000000000000000000000";
     rx_time_of_day_64b_data_20 <= X"0000000000000000";
     tx_time_of_day_96b_data_20 <= X"000000000000000000000000";
     tx_time_of_day_64b_data_20 <= X"0000000000000000";
     tx_egress_timestamp_request_valid_20 			<= '0';
     tx_egress_timestamp_request_fingerprint_20 		<= conv_std_logic_vector(0, TSTAMP_FP_WIDTH);
     tx_etstamp_ins_ctrl_ingress_timestamp_96b_20 	<= X"000000000000000000000000";
     tx_etstamp_ins_ctrl_ingress_timestamp_64b_20 	<= X"0000000000000000";
     tx_etstamp_ins_ctrl_timestamp_insert_20 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_update_20 	<= '0';
     tx_etstamp_ins_ctrl_checksum_zero_20 			<= '0';
     tx_etstamp_ins_ctrl_checksum_correct_20 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_calc_format_20 <= '0';
     tx_etstamp_ins_ctrl_timestamp_format_20 		<= '0';
	 tx_etstamp_ins_ctrl_offset_timestamp_20 		<= X"0000";
	 tx_etstamp_ins_ctrl_offset_correction_field_20 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_field_20 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_correction_20 <= X"0000";
	 
     rx_time_of_day_96b_data_21 <= X"000000000000000000000000";
     rx_time_of_day_64b_data_21 <= X"0000000000000000";
     tx_time_of_day_96b_data_21 <= X"000000000000000000000000";
     tx_time_of_day_64b_data_21 <= X"0000000000000000";
     tx_egress_timestamp_request_valid_21 			<= '0';
     tx_egress_timestamp_request_fingerprint_21 		<= conv_std_logic_vector(0, TSTAMP_FP_WIDTH);
     tx_etstamp_ins_ctrl_ingress_timestamp_96b_21 	<= X"000000000000000000000000";
     tx_etstamp_ins_ctrl_ingress_timestamp_64b_21 	<= X"0000000000000000";
     tx_etstamp_ins_ctrl_timestamp_insert_21 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_update_21 	<= '0';
     tx_etstamp_ins_ctrl_checksum_zero_21 			<= '0';
     tx_etstamp_ins_ctrl_checksum_correct_21 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_calc_format_21 <= '0';
     tx_etstamp_ins_ctrl_timestamp_format_21 		<= '0';
	 tx_etstamp_ins_ctrl_offset_timestamp_21 		<= X"0000";
	 tx_etstamp_ins_ctrl_offset_correction_field_21 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_field_21 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_correction_21 <= X"0000";

     rx_time_of_day_96b_data_22 <= X"000000000000000000000000";
     rx_time_of_day_64b_data_22 <= X"0000000000000000";
     tx_time_of_day_96b_data_22 <= X"000000000000000000000000";
     tx_time_of_day_64b_data_22 <= X"0000000000000000";
     tx_egress_timestamp_request_valid_22 			<= '0';
     tx_egress_timestamp_request_fingerprint_22 		<= conv_std_logic_vector(0, TSTAMP_FP_WIDTH);
     tx_etstamp_ins_ctrl_ingress_timestamp_96b_22 	<= X"000000000000000000000000";
     tx_etstamp_ins_ctrl_ingress_timestamp_64b_22 	<= X"0000000000000000";
     tx_etstamp_ins_ctrl_timestamp_insert_22 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_update_22 	<= '0';
     tx_etstamp_ins_ctrl_checksum_zero_22 			<= '0';
     tx_etstamp_ins_ctrl_checksum_correct_22 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_calc_format_22 <= '0';
     tx_etstamp_ins_ctrl_timestamp_format_22 		<= '0';
	 tx_etstamp_ins_ctrl_offset_timestamp_22 		<= X"0000";
	 tx_etstamp_ins_ctrl_offset_correction_field_22 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_field_22 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_correction_22 <= X"0000";

     rx_time_of_day_96b_data_23 <= X"000000000000000000000000";
     rx_time_of_day_64b_data_23 <= X"0000000000000000";
     tx_time_of_day_96b_data_23 <= X"000000000000000000000000";
     tx_time_of_day_64b_data_23 <= X"0000000000000000";
     tx_egress_timestamp_request_valid_23 			<= '0';
     tx_egress_timestamp_request_fingerprint_23 		<= conv_std_logic_vector(0, TSTAMP_FP_WIDTH);
     tx_etstamp_ins_ctrl_ingress_timestamp_96b_23 	<= X"000000000000000000000000";
     tx_etstamp_ins_ctrl_ingress_timestamp_64b_23 	<= X"0000000000000000";
     tx_etstamp_ins_ctrl_timestamp_insert_23 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_update_23 	<= '0';
     tx_etstamp_ins_ctrl_checksum_zero_23 			<= '0';
     tx_etstamp_ins_ctrl_checksum_correct_23 		<= '0';
     tx_etstamp_ins_ctrl_residence_time_calc_format_23 <= '0';
     tx_etstamp_ins_ctrl_timestamp_format_23 		<= '0';
	 tx_etstamp_ins_ctrl_offset_timestamp_23 		<= X"0000";
	 tx_etstamp_ins_ctrl_offset_correction_field_23 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_field_23 	<= X"0000";
	 tx_etstamp_ins_ctrl_offset_checksum_correction_23 <= X"0000";	 
   end generate;
  
  Single_DUT_without_FIFO: if (MAX_CHANNELS = 1) generate
   begin
     -- NightFury PHYIP signals
     tx_cal_busy        <= tx_cal_busy_0;
     rx_is_lockedtodata <= rx_is_lockedtodata_0;
     rx_cal_busy        <= rx_cal_busy_0;

     led_link         <= led_link_0;
    --input of DUT
     ff_rx_dsav       <= '0'; 
     rx_afull_clk     <= rx_clk;
     rx_afull_channel <= (others => '0');
     rx_afull_data    <= "00";
     rx_afull_valid   <= '1' ;
     data_tx_data_0   <= ff_tx_data;
     data_tx_eop_0    <= ff_tx_eop;
     data_tx_error_0  <= ff_tx_err;
     data_tx_sop_0    <= ff_tx_sop;
     data_tx_valid_0  <= ff_tx_wren;
     tx_crc_fwd_0     <= ff_tx_crc_fwd;
     data_rx_ready_0  <= ff_rx_rdy;
     tbi_tx_clk_0     <= tx_clk_1000mbps;
     tbi_rx_clk_0     <= rx_clk_1000mbps;
     m_rx_d_0         <= m_rx_data;
     m_rx_en_0        <= m_rx_en;
     m_rx_err_0       <= m_rx_err;
     set_10_0         <= '0';
     set_1000_0       <= '0';
     xon_gen_0        <= '0';
     xoff_gen_0       <= '0';
     magic_sleep_n_0  <= magic_sleep_n;
     m_rx_col_0       <= m_rx_col;
     m_rx_crs_0       <= m_rx_crs;
     gm_rx_d_0        <= gm_rx_data;
     gm_rx_dv_0       <= gm_rx_en;
     gm_rx_err_0      <= gm_rx_err;
     rxp_0       <= txp_0 ;


    --output of DUT
     ff_rx_err_stat   <= pkt_class_data_0 (0) & data_rx_error_0(4) & "0000000000000000" & (pkt_class_data_0(1) or pkt_class_data_0(0)) & data_rx_error_0(3 downto 0) when (pkt_class_valid_0='1') else (others => '0') ;
     ff_rx_err        <= data_rx_error_0 (0) or data_rx_error_0 (1) or data_rx_error_0 (2) or data_rx_error_0 (3) or data_rx_error_0 (4);
     ff_rx_vlan       <= pkt_class_data_0 (1) when (pkt_class_valid_0='1') else '0' ;
     ff_rx_bcast      <= pkt_class_data_0 (2) when (pkt_class_valid_0='1') else '0' ;
     ff_rx_mcast      <= pkt_class_data_0 (3) when (pkt_class_valid_0='1') else '0' ;
     ff_rx_ucast      <= pkt_class_data_0 (4) when (pkt_class_valid_0='1') else '0' ;
     ff_tx_clk        <= mac_tx_clk_0;
     ff_rx_clk        <= mac_rx_clk_0;
     ff_tx_rdy        <= data_tx_ready_0;
     ff_rx_data       <= data_rx_data_0;
     ff_rx_dval       <= data_rx_valid_0;
     ff_rx_eop        <= data_rx_eop_0;
     ff_rx_sop        <= data_rx_sop_0;
     rx_err           <= data_rx_error_0 & ff_rx_err;
     m_tx_data        <= m_tx_d_0;
     m_tx_en          <= m_tx_en_0;
     m_tx_err         <= m_tx_err_0;
     gm_tx_data       <= gm_tx_d_0;
     gm_tx_en         <= gm_tx_en_0;
     gm_tx_err        <= gm_tx_err_0;
	 magic_wakeup 	  <= magic_wakeup_0;

  end generate;

  FourPort_DUT_without_FIFO: if (MAX_CHANNELS = 4) generate
   begin
     -- NightFury PHYIP signals
     tx_cal_busy        <= tx_cal_busy_0 or tx_cal_busy_1 or tx_cal_busy_2 or tx_cal_busy_3;
     rx_is_lockedtodata <= rx_is_lockedtodata_0 and rx_is_lockedtodata_1 and rx_is_lockedtodata_2 and rx_is_lockedtodata_3;
     rx_cal_busy        <= rx_cal_busy_0 or rx_cal_busy_1 or rx_cal_busy_2 or rx_cal_busy_3;
    
     led_link         <= led_link_0;
     --input of DUT
     ff_rx_dsav       <= '0'; 
     rx_afull_clk     <= rx_clk;
     rx_afull_channel <= (others => '0');
     rx_afull_data    <= "00";
     rx_afull_valid   <= '1' ;
     data_tx_data_0   <= ff_tx_data;
     data_tx_eop_0    <= ff_tx_eop;
     data_tx_error_0  <= ff_tx_err;
     data_tx_sop_0    <= ff_tx_sop;
     data_tx_valid_0  <= ff_tx_wren;
     tx_crc_fwd_0     <= ff_tx_crc_fwd;
     data_rx_ready_3  <= ff_rx_rdy;
     tbi_tx_clk_0     <= tx_clk_1000mbps;
     tbi_rx_clk_0     <= rx_clk_1000mbps;
     tbi_tx_clk_1     <= tx_clk_1000mbps;
     tbi_rx_clk_1     <= rx_clk_1000mbps;
     tbi_tx_clk_2     <= tx_clk_1000mbps;
     tbi_rx_clk_2     <= rx_clk_1000mbps;
     tbi_tx_clk_3     <= tx_clk_1000mbps;
     tbi_rx_clk_3     <= rx_clk_1000mbps;
     set_10_0         <= '0';
     set_1000_0       <= '0';
     set_10_1         <= '0';
     set_1000_1       <= '0';
     set_10_2         <= '0';
     set_1000_2       <= '0';
     set_10_3         <= '0';
     set_1000_3       <= '0';
     xon_gen_0        <= '0';
     xoff_gen_0       <= '0';
     xon_gen_1        <= '0';
     xoff_gen_1       <= '0';
     xon_gen_2        <= '0';
     xoff_gen_2       <= '0';
     xon_gen_3        <= '0';
     xoff_gen_3       <= '0';

     magic_sleep_n_0  <= magic_sleep_n;
     magic_sleep_n_1  <= magic_sleep_n;
     magic_sleep_n_2  <= magic_sleep_n;
     magic_sleep_n_3  <= magic_sleep_n;


    --output of DUT
     ff_rx_err_stat   <= pkt_class_data_3 (0) & data_rx_error_3(4) & "0000000000000000" & (pkt_class_data_3(1) or pkt_class_data_3(0)) & data_rx_error_3(3 downto 0) when (pkt_class_valid_3='1') else (others => '0') ;
     ff_rx_err        <= data_rx_error_3 (0) or data_rx_error_3 (1) or data_rx_error_3 (2) or data_rx_error_3 (3) or data_rx_error_3 (4);
     ff_rx_vlan       <= pkt_class_data_3 (1) when (pkt_class_valid_3='1') else '0' ;
     ff_rx_bcast      <= pkt_class_data_3 (2) when (pkt_class_valid_3='1') else '0' ;
     ff_rx_mcast      <= pkt_class_data_3 (3) when (pkt_class_valid_3='1') else '0' ;
     ff_rx_ucast      <= pkt_class_data_3 (4) when (pkt_class_valid_3='1') else '0' ;
     ff_tx_clk        <= mac_tx_clk_0;
     ff_rx_clk        <= mac_rx_clk_0;
     ff_tx_rdy        <= data_tx_ready_0;
     ff_rx_data       <= data_rx_data_3;
     ff_rx_dval       <= data_rx_valid_3;
     ff_rx_eop        <= data_rx_eop_3;
     ff_rx_sop        <= data_rx_sop_3;
     rx_err           <= data_rx_error_3 & ff_rx_err;
	 magic_wakeup 	  <= magic_wakeup_3;

    --loopback
     data_rx_ready_0  <= '1';--data_tx_ready_1;
     tx_crc_fwd_1     <= ff_tx_crc_fwd;
 
 
    u_ch0_2_ch1 : loopback_adapter  
    port map(
        
      -- Interface:clk                     
      clk      => mac_tx_clk_0,
      reset    => reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_0,
      in_data  => data_rx_data_0,
      in_startofpacket => data_rx_sop_0,
      in_endofpacket => data_rx_eop_0,
      in_error => data_rx_error_0,
      -- Interface:out
      out_ready => data_tx_ready_1,
      out_valid => data_tx_valid_1,
      out_data => data_tx_data_1,
      out_startofpacket => data_tx_sop_1,
      out_endofpacket => data_tx_eop_1,
      out_error => data_tx_error_1
    );
 
     data_rx_ready_1  <= '1';
     tx_crc_fwd_2     <= ff_tx_crc_fwd;
 
    u_ch1_2_ch2 : loopback_adapter 
    port map(
      -- Interface:clk                     
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_1,
      in_data=>data_rx_data_1,
      in_startofpacket=>data_rx_sop_1,
      in_endofpacket=>data_rx_eop_1,
      in_error=>data_rx_error_1,
      -- Interface:out
      out_ready=>data_tx_ready_2,
      out_valid=>data_tx_valid_2,
      out_data=>data_tx_data_2,
      out_startofpacket=>data_tx_sop_2,
      out_endofpacket=>data_tx_eop_2,
      out_error=>data_tx_error_2
    );
 
     data_rx_ready_2  <= '1';
     tx_crc_fwd_3     <= ff_tx_crc_fwd;
 
    u_ch2_2_ch3: loopback_adapter 
    port map (
      -- Interface:clk                     
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_2,
      in_data=>data_rx_data_2,
      in_startofpacket=>data_rx_sop_2,
      in_endofpacket=>data_rx_eop_2,
      in_error=>data_rx_error_2,
      -- Interface:out
      out_ready=>data_tx_ready_3,
      out_valid=>data_tx_valid_3,
      out_data=>data_tx_data_3,
      out_startofpacket=>data_tx_sop_3,
      out_endofpacket=>data_tx_eop_3,
      out_error=>data_tx_error_3
    );
 
    
    --assigning to GMII/MII TX monitoring
     gm_tx_data       <= gm_tx_d_0;
     gm_tx_en         <= gm_tx_en_0;
     gm_tx_err        <= gm_tx_err_0;
     m_tx_data        <= m_tx_d_0;
     m_tx_en          <= m_tx_en_0;
     m_tx_err         <= m_tx_err_0;
 
     gm_rx_d_0        <= gm_tx_d_0;
     gm_rx_dv_0       <= gm_tx_en_0;
     gm_rx_err_0      <= gm_tx_err_0;
     m_rx_d_0         <= m_tx_d_0;
     m_rx_en_0        <= m_tx_en_0;
     m_rx_err_0       <= m_tx_err_0;
     m_rx_col_0       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_0       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_0     <= tx_control_0;
     rgmii_in_0       <= rgmii_out_0;
     rxp_0       <= txp_0 ;
 
     gm_rx_d_1        <= gm_tx_d_1;
     gm_rx_dv_1       <= gm_tx_en_1;
     gm_rx_err_1      <= gm_tx_err_1;
     m_rx_d_1         <= m_tx_d_1;
     m_rx_en_1        <= m_tx_en_1;
     m_rx_err_1       <= m_tx_err_1;
     m_rx_col_1       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_1       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_1     <= tx_control_1;
     rgmii_in_1       <= rgmii_out_1;
      rxp_1       <= txp_1 ;

     gm_rx_d_2        <= gm_tx_d_2;
     gm_rx_dv_2       <= gm_tx_en_2;
     gm_rx_err_2      <= gm_tx_err_2;
     m_rx_d_2         <= m_tx_d_2;
     m_rx_en_2        <= m_tx_en_2;
     m_rx_err_2       <= m_tx_err_2;
     m_rx_col_2       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_2       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_2     <= tx_control_2;
     rgmii_in_2       <= rgmii_out_2;
     rxp_2       <= txp_2 ;
 
     gm_rx_d_3        <= gm_tx_d_3;
     gm_rx_dv_3       <= gm_tx_en_3;
     gm_rx_err_3      <= gm_tx_err_3;
     m_rx_d_3         <= m_tx_d_3;
     m_rx_en_3        <= m_tx_en_3;
     m_rx_err_3       <= m_tx_err_3;
     m_rx_col_3       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_3       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_3     <= tx_control_3;
     rgmii_in_3       <= rgmii_out_3;
     rxp_3       <= txp_3 ;

  end generate;
   
  EightPort_DUT_without_FIFO: if (MAX_CHANNELS = 8) generate
   begin
     -- NightFury PHYIP signals
     tx_cal_busy        <= tx_cal_busy_0 or tx_cal_busy_1 or tx_cal_busy_2 or tx_cal_busy_3 or
                           tx_cal_busy_4 or tx_cal_busy_5 or tx_cal_busy_6 or tx_cal_busy_7;
     rx_is_lockedtodata <= rx_is_lockedtodata_0 and rx_is_lockedtodata_1 and rx_is_lockedtodata_2 and rx_is_lockedtodata_3 and
                           rx_is_lockedtodata_4 and rx_is_lockedtodata_5 and rx_is_lockedtodata_6 and rx_is_lockedtodata_7;
     rx_cal_busy        <= rx_cal_busy_0 or rx_cal_busy_1 or rx_cal_busy_2 or rx_cal_busy_3 or
                           rx_cal_busy_4 or rx_cal_busy_5 or rx_cal_busy_6 or rx_cal_busy_7;

     led_link         <= led_link_0;  
     --input of DUT
     ff_rx_dsav       <= '0'; 
     rx_afull_clk     <= rx_clk;
     rx_afull_channel <= (others => '0');
     rx_afull_data    <= "00";
     rx_afull_valid   <= '1' ;
     data_tx_data_0   <= ff_tx_data;
     data_tx_eop_0    <= ff_tx_eop;
     data_tx_error_0  <= ff_tx_err;
     data_tx_sop_0    <= ff_tx_sop;
     data_tx_valid_0  <= ff_tx_wren;
     tx_crc_fwd_0     <= ff_tx_crc_fwd;
     data_rx_ready_7  <= ff_rx_rdy;
     tbi_tx_clk_0     <= tx_clk_1000mbps;
     tbi_rx_clk_0     <= rx_clk_1000mbps;
     tbi_tx_clk_1     <= tx_clk_1000mbps;
     tbi_rx_clk_1     <= rx_clk_1000mbps;
     tbi_tx_clk_2     <= tx_clk_1000mbps;
     tbi_rx_clk_2     <= rx_clk_1000mbps;
     tbi_tx_clk_3     <= tx_clk_1000mbps;
     tbi_rx_clk_3     <= rx_clk_1000mbps;
     tbi_tx_clk_4     <= tx_clk_1000mbps;
     tbi_rx_clk_4     <= rx_clk_1000mbps;
     tbi_tx_clk_5     <= tx_clk_1000mbps;
     tbi_rx_clk_5     <= rx_clk_1000mbps;
     tbi_tx_clk_6     <= tx_clk_1000mbps;
     tbi_rx_clk_6     <= rx_clk_1000mbps;
     tbi_tx_clk_7     <= tx_clk_1000mbps;
     tbi_rx_clk_7     <= rx_clk_1000mbps;
     set_10_0         <= '0';
     set_1000_0       <= '0';
     set_10_1         <= '0';
     set_1000_1       <= '0';
     set_10_2         <= '0';
     set_1000_2       <= '0';
     set_10_3         <= '0';
     set_1000_3       <= '0';
     set_10_4         <= '0';
     set_1000_4       <= '0';
     set_10_4         <= '0';
     set_1000_4       <= '0';
     set_10_5         <= '0';
     set_1000_5       <= '0';
     set_10_6         <= '0';
     set_1000_6       <= '0';
     set_10_7         <= '0';
     set_1000_7       <= '0';
     xon_gen_0        <= '0';
     xoff_gen_0       <= '0';
     xon_gen_1        <= '0';
     xoff_gen_1       <= '0';
     xon_gen_2        <= '0';
     xoff_gen_2       <= '0';
     xon_gen_3        <= '0';
     xoff_gen_3       <= '0';
     xon_gen_4        <= '0';
     xoff_gen_4       <= '0';
     xon_gen_5        <= '0';
     xoff_gen_5       <= '0';
     xon_gen_6        <= '0';
     xoff_gen_6       <= '0';
     xon_gen_7        <= '0';
     xoff_gen_7       <= '0';

     magic_sleep_n_0  <= magic_sleep_n;
     magic_sleep_n_1  <= magic_sleep_n;
     magic_sleep_n_2  <= magic_sleep_n;
     magic_sleep_n_3  <= magic_sleep_n;
     magic_sleep_n_4  <= magic_sleep_n;
     magic_sleep_n_5  <= magic_sleep_n;
     magic_sleep_n_6  <= magic_sleep_n;
     magic_sleep_n_7  <= magic_sleep_n;


    --output of DUT
     ff_rx_err_stat   <= pkt_class_data_7 (0) & data_rx_error_7(4) & "0000000000000000" & (pkt_class_data_7(1) or pkt_class_data_7(0)) & data_rx_error_7(3 downto 0) when (pkt_class_valid_7='1') else (others => '0') ;
     ff_rx_err        <= data_rx_error_7 (0) or data_rx_error_7 (1) or data_rx_error_7 (2) or data_rx_error_7 (3) or data_rx_error_7 (4);
     ff_rx_vlan       <= pkt_class_data_7 (1) when (pkt_class_valid_7='1') else '0' ;
     ff_rx_bcast      <= pkt_class_data_7 (2) when (pkt_class_valid_7='1') else '0' ;
     ff_rx_mcast      <= pkt_class_data_7 (3) when (pkt_class_valid_7='1') else '0' ;
     ff_rx_ucast      <= pkt_class_data_7 (4) when (pkt_class_valid_7='1') else '0' ;
     ff_tx_clk        <= mac_tx_clk_0;
     ff_rx_clk        <= mac_rx_clk_0;
     ff_tx_rdy        <= data_tx_ready_0;
     ff_rx_data       <= data_rx_data_7;
     ff_rx_dval       <= data_rx_valid_7;
     ff_rx_eop        <= data_rx_eop_7;
     ff_rx_sop        <= data_rx_sop_7;
     rx_err           <= data_rx_error_7 & ff_rx_err;
	 magic_wakeup 	  <= magic_wakeup_7;

    --loopback
     data_rx_ready_0  <= '1';--data_tx_ready_1;
     tx_crc_fwd_1     <= ff_tx_crc_fwd;
 
 
    u_ch0_2_ch1 : loopback_adapter  
    port map(
        
      -- Interface:clk                     
      clk      => mac_tx_clk_0,
      reset    => reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_0,
      in_data  => data_rx_data_0,
      in_startofpacket => data_rx_sop_0,
      in_endofpacket => data_rx_eop_0,
      in_error => data_rx_error_0,
      -- Interface:out
      out_ready => data_tx_ready_1,
      out_valid => data_tx_valid_1,
      out_data => data_tx_data_1,
      out_startofpacket => data_tx_sop_1,
      out_endofpacket => data_tx_eop_1,
      out_error => data_tx_error_1
    );
 
     data_rx_ready_1  <= '1';
     tx_crc_fwd_2     <= ff_tx_crc_fwd;
 
    u_ch1_2_ch2 : loopback_adapter 
    port map(
      -- Interface:clk                     
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_1,
      in_data=>data_rx_data_1,
      in_startofpacket=>data_rx_sop_1,
      in_endofpacket=>data_rx_eop_1,
      in_error=>data_rx_error_1,
      -- Interface:out
      out_ready=>data_tx_ready_2,
      out_valid=>data_tx_valid_2,
      out_data=>data_tx_data_2,
      out_startofpacket=>data_tx_sop_2,
      out_endofpacket=>data_tx_eop_2,
      out_error=>data_tx_error_2
    );
 
     data_rx_ready_2  <= '1';
     tx_crc_fwd_3     <= ff_tx_crc_fwd;
 
    u_ch2_2_ch3: loopback_adapter 
    port map (
      -- Interface:clk                     
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_2,
      in_data=>data_rx_data_2,
      in_startofpacket=>data_rx_sop_2,
      in_endofpacket=>data_rx_eop_2,
      in_error=>data_rx_error_2,
      -- Interface:out
      out_ready=>data_tx_ready_3,
      out_valid=>data_tx_valid_3,
      out_data=>data_tx_data_3,
      out_startofpacket=>data_tx_sop_3,
      out_endofpacket=>data_tx_eop_3,
      out_error=>data_tx_error_3
    );
 
      data_rx_ready_3  <= '1';
     tx_crc_fwd_4     <= ff_tx_crc_fwd;
 
    u_ch3_2_ch4: loopback_adapter 
    port map (
      -- Interface:clk                     
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_3,
      in_data=>data_rx_data_3,
      in_startofpacket=>data_rx_sop_3,
      in_endofpacket=>data_rx_eop_3,
      in_error=>data_rx_error_3,
      -- Interface:out
      out_ready=>data_tx_ready_4,
      out_valid=>data_tx_valid_4,
      out_data=>data_tx_data_4,
      out_startofpacket=>data_tx_sop_4,
      out_endofpacket=>data_tx_eop_4,
      out_error=>data_tx_error_4
  );
 
     data_rx_ready_4  <= '1';
     tx_crc_fwd_5     <= ff_tx_crc_fwd;
 
    u_ch4_2_ch5: loopback_adapter  
    port map (
      -- Interface:clk                     
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_4,
      in_data=>data_rx_data_4,
      in_startofpacket=>data_rx_sop_4,
      in_endofpacket=>data_rx_eop_4,
      in_error=>data_rx_error_4,
      -- Interface:out
      out_ready=>data_tx_ready_5,
      out_valid=>data_tx_valid_5,
      out_data=>data_tx_data_5,
      out_startofpacket=>data_tx_sop_5,
      out_endofpacket=>data_tx_eop_5,
      out_error=>data_tx_error_5
    );
 
     data_rx_ready_5  <= '1';
     tx_crc_fwd_6     <= ff_tx_crc_fwd;
 
    u_ch5_2_ch6: loopback_adapter  
    port map(
      -- Interface:clk                     
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_5,
      in_data=>data_rx_data_5,
      in_startofpacket=>data_rx_sop_5,
      in_endofpacket=>data_rx_eop_5,
      in_error=>data_rx_error_5,
      -- Interface:out
      out_ready=>data_tx_ready_6,
      out_valid=>data_tx_valid_6,
      out_data=>data_tx_data_6,
      out_startofpacket=>data_tx_sop_6,
      out_endofpacket=>data_tx_eop_6,
      out_error=>data_tx_error_6
    );
 
     data_rx_ready_6  <= '1';
     tx_crc_fwd_7     <= ff_tx_crc_fwd;
 
    u_ch6_2_ch7: loopback_adapter 
    port map (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_6,
      in_data=>data_rx_data_6,
      in_startofpacket=>data_rx_sop_6,
      in_endofpacket=>data_rx_eop_6,
      in_error=>data_rx_error_6,
      -- Interface:out
      out_ready=>data_tx_ready_7,
      out_valid=>data_tx_valid_7,
      out_data=>data_tx_data_7,
      out_startofpacket=>data_tx_sop_7,
      out_endofpacket=>data_tx_eop_7,
      out_error=>data_tx_error_7
    );
   
    --assigning to GMII/MII TX monitoring
     gm_tx_data       <= gm_tx_d_0;
     gm_tx_en         <= gm_tx_en_0;
     gm_tx_err        <= gm_tx_err_0;
     m_tx_data        <= m_tx_d_0;
     m_tx_en          <= m_tx_en_0;
     m_tx_err         <= m_tx_err_0;
 
     gm_rx_d_0        <= gm_tx_d_0;
     gm_rx_dv_0       <= gm_tx_en_0;
     gm_rx_err_0      <= gm_tx_err_0;
     m_rx_d_0         <= m_tx_d_0;
     m_rx_en_0        <= m_tx_en_0;
     m_rx_err_0       <= m_tx_err_0;
     m_rx_col_0       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_0       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_0     <= tx_control_0;
     rgmii_in_0       <= rgmii_out_0;
     rxp_0       <= txp_0 ;

     gm_rx_d_1        <= gm_tx_d_1;
     gm_rx_dv_1       <= gm_tx_en_1;
     gm_rx_err_1      <= gm_tx_err_1;
     m_rx_d_1         <= m_tx_d_1;
     m_rx_en_1        <= m_tx_en_1;
     m_rx_err_1       <= m_tx_err_1;
     m_rx_col_1       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_1       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_1     <= tx_control_1;
     rgmii_in_1       <= rgmii_out_1;
     rxp_1       <= txp_1 ;
 
     gm_rx_d_2        <= gm_tx_d_2;
     gm_rx_dv_2       <= gm_tx_en_2;
     gm_rx_err_2      <= gm_tx_err_2;
     m_rx_d_2         <= m_tx_d_2;
     m_rx_en_2        <= m_tx_en_2;
     m_rx_err_2       <= m_tx_err_2;
     m_rx_col_2       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_2       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_2     <= tx_control_2;
     rgmii_in_2       <= rgmii_out_2;
     rxp_2       <= txp_2 ;
 
     gm_rx_d_3        <= gm_tx_d_3;
     gm_rx_dv_3       <= gm_tx_en_3;
     gm_rx_err_3      <= gm_tx_err_3;
     m_rx_d_3         <= m_tx_d_3;
     m_rx_en_3        <= m_tx_en_3;
     m_rx_err_3       <= m_tx_err_3;
     m_rx_col_3       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_3       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_3     <= tx_control_3;
     rgmii_in_3       <= rgmii_out_3;
     rxp_3       <= txp_3 ;

     gm_rx_d_4        <= gm_tx_d_4;
     gm_rx_dv_4       <= gm_tx_en_4;
     gm_rx_err_4      <= gm_tx_err_4;
     m_rx_d_4         <= m_tx_d_4;
     m_rx_en_4        <= m_tx_en_4;
     m_rx_err_4       <= m_tx_err_4;
     m_rx_col_4       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_4       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_4     <= tx_control_4;
     rgmii_in_4       <= rgmii_out_4;
     rxp_4       <= txp_4 ;
 
     gm_rx_d_5        <= gm_tx_d_5;
     gm_rx_dv_5       <= gm_tx_en_5;
     gm_rx_err_5      <= gm_tx_err_5;
     m_rx_d_5         <= m_tx_d_5;
     m_rx_en_5        <= m_tx_en_5;
     m_rx_err_5       <= m_tx_err_5;
     m_rx_col_5       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_5       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_5     <= tx_control_5;
     rgmii_in_5       <= rgmii_out_5;
     rxp_5       <= txp_5 ;
 
     gm_rx_d_6        <= gm_tx_d_6;
     gm_rx_dv_6       <= gm_tx_en_6;
     gm_rx_err_6      <= gm_tx_err_6;
     m_rx_d_6         <= m_tx_d_6;
     m_rx_en_6        <= m_tx_en_6;
     m_rx_err_6       <= m_tx_err_6;
     m_rx_col_6       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_6       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_6     <= tx_control_6;
     rgmii_in_6       <= rgmii_out_6;
     rxp_6       <= txp_6 ;
 
     gm_rx_d_7        <= gm_tx_d_7;
     gm_rx_dv_7       <= gm_tx_en_7;
     gm_rx_err_7      <= gm_tx_err_7;
     m_rx_d_7         <= m_tx_d_7;
     m_rx_en_7        <= m_tx_en_7;
     m_rx_err_7       <= m_tx_err_7;
     m_rx_col_7       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_7       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_7     <= tx_control_7;
     rgmii_in_7       <= rgmii_out_7;
     rxp_7       <= txp_7 ;

  end generate;
   
  TwelvePort_DUT_without_FIFO: if (MAX_CHANNELS = 12) generate
   begin
     -- NightFury PHYIP signals
     tx_cal_busy        <= tx_cal_busy_0 or tx_cal_busy_1 or tx_cal_busy_2 or tx_cal_busy_3 or
                           tx_cal_busy_4 or tx_cal_busy_5 or tx_cal_busy_6 or tx_cal_busy_7 or
                           tx_cal_busy_8 or tx_cal_busy_9 or tx_cal_busy_10 or tx_cal_busy_11;
     rx_is_lockedtodata <= rx_is_lockedtodata_0 and rx_is_lockedtodata_1 and rx_is_lockedtodata_2 and rx_is_lockedtodata_3 and
                           rx_is_lockedtodata_4 and rx_is_lockedtodata_5 and rx_is_lockedtodata_6 and rx_is_lockedtodata_7 and
                           rx_is_lockedtodata_8 and rx_is_lockedtodata_9 and rx_is_lockedtodata_10 and rx_is_lockedtodata_11;
     rx_cal_busy        <= rx_cal_busy_0 or rx_cal_busy_1 or rx_cal_busy_2 or rx_cal_busy_3 or
                           rx_cal_busy_4 or rx_cal_busy_5 or rx_cal_busy_6 or rx_cal_busy_7 or
                           rx_cal_busy_8 or rx_cal_busy_9 or rx_cal_busy_10 or rx_cal_busy_11;
 
     led_link         <= led_link_0; 
    --input of DUT
     ff_rx_dsav       <= '0'; 
     rx_afull_clk     <= rx_clk;
     rx_afull_channel <= (others => '0');
     rx_afull_data    <= "00";
     rx_afull_valid   <= '1' ;
     data_tx_data_0   <= ff_tx_data;
     data_tx_eop_0    <= ff_tx_eop;
     data_tx_error_0  <= ff_tx_err;
     data_tx_sop_0    <= ff_tx_sop;
     data_tx_valid_0  <= ff_tx_wren;
     tx_crc_fwd_0     <= ff_tx_crc_fwd;
     data_rx_ready_11  <= ff_rx_rdy;
     tbi_tx_clk_0     <= tx_clk_1000mbps;
     tbi_rx_clk_0     <= rx_clk_1000mbps;
     tbi_tx_clk_1     <= tx_clk_1000mbps;
     tbi_rx_clk_1     <= rx_clk_1000mbps;
     tbi_tx_clk_2     <= tx_clk_1000mbps;
     tbi_rx_clk_2     <= rx_clk_1000mbps;
     tbi_tx_clk_3     <= tx_clk_1000mbps;
     tbi_rx_clk_3     <= rx_clk_1000mbps;
     tbi_tx_clk_4     <= tx_clk_1000mbps;
     tbi_rx_clk_4     <= rx_clk_1000mbps;
     tbi_tx_clk_5     <= tx_clk_1000mbps;
     tbi_rx_clk_5     <= rx_clk_1000mbps;
     tbi_tx_clk_6     <= tx_clk_1000mbps;
     tbi_rx_clk_6     <= rx_clk_1000mbps;
     tbi_tx_clk_7     <= tx_clk_1000mbps;
     tbi_rx_clk_7     <= rx_clk_1000mbps;
     tbi_tx_clk_8     <= tx_clk_1000mbps;
     tbi_rx_clk_8     <= rx_clk_1000mbps;
     tbi_tx_clk_9     <= tx_clk_1000mbps;
     tbi_rx_clk_9     <= rx_clk_1000mbps;
     tbi_tx_clk_10     <= tx_clk_1000mbps;
     tbi_rx_clk_10     <= rx_clk_1000mbps;
     tbi_tx_clk_11     <= tx_clk_1000mbps;
     tbi_rx_clk_11     <= rx_clk_1000mbps;

     set_10_0         <= '0';
     set_1000_0       <= '0';
     set_10_1         <= '0';
     set_1000_1       <= '0';
     set_10_2         <= '0';
     set_1000_2       <= '0';
     set_10_3         <= '0';
     set_1000_3       <= '0';
     set_10_4         <= '0';
     set_1000_4       <= '0';
     set_10_4         <= '0';
     set_1000_4       <= '0';
     set_10_5         <= '0';
     set_1000_5       <= '0';
     set_10_6         <= '0';
     set_1000_6       <= '0';
     set_10_7         <= '0';
     set_1000_7       <= '0';
     set_10_8         <= '0';
     set_1000_8       <= '0';
     set_10_9         <= '0';
     set_1000_9       <= '0';
     set_10_10         <= '0';
     set_1000_10       <= '0';
     set_10_11         <= '0';
     set_1000_11       <= '0';
 
     xon_gen_0        <= '0';
     xoff_gen_0       <= '0';
     xon_gen_1        <= '0';
     xoff_gen_1       <= '0';
     xon_gen_2        <= '0';
     xoff_gen_2       <= '0';
     xon_gen_3        <= '0';
     xoff_gen_3       <= '0';
     xon_gen_4        <= '0';
     xoff_gen_4       <= '0';
     xon_gen_5        <= '0';
     xoff_gen_5       <= '0';
     xon_gen_6        <= '0';
     xoff_gen_6       <= '0';
     xon_gen_7        <= '0';
     xoff_gen_7       <= '0';
     xon_gen_8        <= '0';
     xoff_gen_8       <= '0';
     xon_gen_9        <= '0';
     xoff_gen_9       <= '0';
     xon_gen_10        <= '0';
     xoff_gen_10       <= '0';
     xon_gen_11        <= '0';
     xoff_gen_11       <= '0';

     magic_sleep_n_0  <= magic_sleep_n;
     magic_sleep_n_1  <= magic_sleep_n;
     magic_sleep_n_2  <= magic_sleep_n;
     magic_sleep_n_3  <= magic_sleep_n;
     magic_sleep_n_4  <= magic_sleep_n;
     magic_sleep_n_5  <= magic_sleep_n;
     magic_sleep_n_6  <= magic_sleep_n;
     magic_sleep_n_7  <= magic_sleep_n;
     magic_sleep_n_8  <= magic_sleep_n;
     magic_sleep_n_9  <= magic_sleep_n;
     magic_sleep_n_10  <= magic_sleep_n;
     magic_sleep_n_11  <= magic_sleep_n;


    --output of DUT
     ff_rx_err_stat   <= pkt_class_data_11 (0) & data_rx_error_11(4) & "0000000000000000" & (pkt_class_data_11(1) or pkt_class_data_11(0)) & data_rx_error_11(3 downto 0) when (pkt_class_valid_11='1') else (others => '0') ;
     ff_rx_err        <= data_rx_error_11 (0) or data_rx_error_11 (1) or data_rx_error_11 (2) or data_rx_error_11 (3) or data_rx_error_11 (4);
     ff_rx_vlan       <= pkt_class_data_11 (1) when (pkt_class_valid_11='1') else '0' ;
     ff_rx_bcast      <= pkt_class_data_11 (2) when (pkt_class_valid_11='1') else '0' ;
     ff_rx_mcast      <= pkt_class_data_11 (3) when (pkt_class_valid_11='1') else '0' ;
     ff_rx_ucast      <= pkt_class_data_11 (4) when (pkt_class_valid_11='1') else '0' ;
     ff_tx_clk        <= mac_tx_clk_0;
     ff_rx_clk        <= mac_rx_clk_0;
     ff_tx_rdy        <= data_tx_ready_0;
     ff_rx_data       <= data_rx_data_11;
     ff_rx_dval       <= data_rx_valid_11;
     ff_rx_eop        <= data_rx_eop_11;
     ff_rx_sop        <= data_rx_sop_11;
     rx_err           <= data_rx_error_11 & ff_rx_err;
	 magic_wakeup 	  <= magic_wakeup_11;

    --loopback
     data_rx_ready_0  <= '1';--data_tx_ready_1;
     tx_crc_fwd_1     <= ff_tx_crc_fwd;
 
 
    u_ch0_2_ch1 : loopback_adapter  
    port map(
        
      -- Interface:clk                     
      clk      => mac_tx_clk_0,
      reset    => reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_0,
      in_data  => data_rx_data_0,
      in_startofpacket => data_rx_sop_0,
      in_endofpacket => data_rx_eop_0,
      in_error => data_rx_error_0,
      -- Interface:out
      out_ready => data_tx_ready_1,
      out_valid => data_tx_valid_1,
      out_data => data_tx_data_1,
      out_startofpacket => data_tx_sop_1,
      out_endofpacket => data_tx_eop_1,
      out_error => data_tx_error_1
    );
 
     data_rx_ready_1  <= '1';
     tx_crc_fwd_2     <= ff_tx_crc_fwd;
 
    u_ch1_2_ch2 : loopback_adapter 
    port map(
      -- Interface:clk                     
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_1,
      in_data=>data_rx_data_1,
      in_startofpacket=>data_rx_sop_1,
      in_endofpacket=>data_rx_eop_1,
      in_error=>data_rx_error_1,
      -- Interface:out
      out_ready=>data_tx_ready_2,
      out_valid=>data_tx_valid_2,
      out_data=>data_tx_data_2,
      out_startofpacket=>data_tx_sop_2,
      out_endofpacket=>data_tx_eop_2,
      out_error=>data_tx_error_2
    );
 
     data_rx_ready_2  <= '1';
     tx_crc_fwd_3     <= ff_tx_crc_fwd;
 
    u_ch2_2_ch3: loopback_adapter 
    port map (
      -- Interface:clk                     
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_2,
      in_data=>data_rx_data_2,
      in_startofpacket=>data_rx_sop_2,
      in_endofpacket=>data_rx_eop_2,
      in_error=>data_rx_error_2,
      -- Interface:out
      out_ready=>data_tx_ready_3,
      out_valid=>data_tx_valid_3,
      out_data=>data_tx_data_3,
      out_startofpacket=>data_tx_sop_3,
      out_endofpacket=>data_tx_eop_3,
      out_error=>data_tx_error_3
    );
 
      data_rx_ready_3  <= '1';
     tx_crc_fwd_4     <= ff_tx_crc_fwd;
 
    u_ch3_2_ch4: loopback_adapter 
    port map (
      -- Interface:clk                     
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_3,
      in_data=>data_rx_data_3,
      in_startofpacket=>data_rx_sop_3,
      in_endofpacket=>data_rx_eop_3,
      in_error=>data_rx_error_3,
      -- Interface:out
      out_ready=>data_tx_ready_4,
      out_valid=>data_tx_valid_4,
      out_data=>data_tx_data_4,
      out_startofpacket=>data_tx_sop_4,
      out_endofpacket=>data_tx_eop_4,
      out_error=>data_tx_error_4
  );
 
     data_rx_ready_4  <= '1';
     tx_crc_fwd_5     <= ff_tx_crc_fwd;
 
    u_ch4_2_ch5: loopback_adapter  
    port map (
      -- Interface:clk                     
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_4,
      in_data=>data_rx_data_4,
      in_startofpacket=>data_rx_sop_4,
      in_endofpacket=>data_rx_eop_4,
      in_error=>data_rx_error_4,
      -- Interface:out
      out_ready=>data_tx_ready_5,
      out_valid=>data_tx_valid_5,
      out_data=>data_tx_data_5,
      out_startofpacket=>data_tx_sop_5,
      out_endofpacket=>data_tx_eop_5,
      out_error=>data_tx_error_5
    );
 
     data_rx_ready_5  <= '1';
     tx_crc_fwd_6     <= ff_tx_crc_fwd;
 
    u_ch5_2_ch6: loopback_adapter  
    port map(
      -- Interface:clk                     
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_5,
      in_data=>data_rx_data_5,
      in_startofpacket=>data_rx_sop_5,
      in_endofpacket=>data_rx_eop_5,
      in_error=>data_rx_error_5,
      -- Interface:out
      out_ready=>data_tx_ready_6,
      out_valid=>data_tx_valid_6,
      out_data=>data_tx_data_6,
      out_startofpacket=>data_tx_sop_6,
      out_endofpacket=>data_tx_eop_6,
      out_error=>data_tx_error_6
    );
 
     data_rx_ready_6  <= '1';
     tx_crc_fwd_7     <= ff_tx_crc_fwd;
 
    u_ch6_2_ch7: loopback_adapter 
    port map (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_6,
      in_data=>data_rx_data_6,
      in_startofpacket=>data_rx_sop_6,
      in_endofpacket=>data_rx_eop_6,
      in_error=>data_rx_error_6,
      -- Interface:out
      out_ready=>data_tx_ready_7,
      out_valid=>data_tx_valid_7,
      out_data=>data_tx_data_7,
      out_startofpacket=>data_tx_sop_7,
      out_endofpacket=>data_tx_eop_7,
      out_error=>data_tx_error_7
    );
  
     data_rx_ready_7  <= '1';
     tx_crc_fwd_8    <= ff_tx_crc_fwd;
 
    u_ch7_2_ch8 : loopback_adapter 
    port map  (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_7,
      in_data=>data_rx_data_7,
      in_startofpacket=>data_rx_sop_7,
      in_endofpacket=>data_rx_eop_7,
      in_error=>data_rx_error_7,
      -- Interface:out
      out_ready=>data_tx_ready_8,
      out_valid=>data_tx_valid_8,
      out_data=>data_tx_data_8,
      out_startofpacket=>data_tx_sop_8,
      out_endofpacket=>data_tx_eop_8,
      out_error=>data_tx_error_8
    );
 
     data_rx_ready_8  <= '1';
     tx_crc_fwd_9     <= ff_tx_crc_fwd;
 
    u_ch8_2_ch9: loopback_adapter  
    port map(
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_8,
      in_data=>data_rx_data_8,
      in_startofpacket=>data_rx_sop_8,
      in_endofpacket=>data_rx_eop_8,
      in_error=>data_rx_error_8,
      -- Interface:out
      out_ready=>data_tx_ready_9,
      out_valid=>data_tx_valid_9,
      out_data=>data_tx_data_9,
      out_startofpacket=>data_tx_sop_9,
      out_endofpacket=>data_tx_eop_9,
      out_error=>data_tx_error_9
    );
 
     data_rx_ready_9  <= '1';
     tx_crc_fwd_10     <= ff_tx_crc_fwd;
 
    u_ch9_2_ch10: loopback_adapter
     port map  (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_9,
      in_data=>data_rx_data_9,
      in_startofpacket=>data_rx_sop_9,
      in_endofpacket=>data_rx_eop_9,
      in_error=>data_rx_error_9,
      -- Interface:out
      out_ready=>data_tx_ready_10,
      out_valid=>data_tx_valid_10,
      out_data=>data_tx_data_10,
      out_startofpacket=>data_tx_sop_10,
      out_endofpacket=>data_tx_eop_10,
      out_error=>data_tx_error_10
    );
 
     data_rx_ready_10  <= '1';
     tx_crc_fwd_11     <= ff_tx_crc_fwd;
 
    u_ch10_2_ch11 :loopback_adapter
     port map (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_10,
      in_data=>data_rx_data_10,
      in_startofpacket=>data_rx_sop_10,
      in_endofpacket=>data_rx_eop_10,
      in_error=>data_rx_error_10,
      -- Interface:out
      out_ready=>data_tx_ready_11,
      out_valid=>data_tx_valid_11,
      out_data=>data_tx_data_11,
      out_startofpacket=>data_tx_sop_11,
      out_endofpacket=>data_tx_eop_11,
      out_error=>data_tx_error_11
    ); 
    --assigning to GMII/MII TX monitoring
     gm_tx_data       <= gm_tx_d_0;
     gm_tx_en         <= gm_tx_en_0;
     gm_tx_err        <= gm_tx_err_0;
     m_tx_data        <= m_tx_d_0;
     m_tx_en          <= m_tx_en_0;
     m_tx_err         <= m_tx_err_0;
 
     gm_rx_d_0        <= gm_tx_d_0;
     gm_rx_dv_0       <= gm_tx_en_0;
     gm_rx_err_0      <= gm_tx_err_0;
     m_rx_d_0         <= m_tx_d_0;
     m_rx_en_0        <= m_tx_en_0;
     m_rx_err_0       <= m_tx_err_0;
     m_rx_col_0       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_0       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_0     <= tx_control_0;
     rgmii_in_0       <= rgmii_out_0;
     rxp_0       <= txp_0 ;
 
     gm_rx_d_1        <= gm_tx_d_1;
     gm_rx_dv_1       <= gm_tx_en_1;
     gm_rx_err_1      <= gm_tx_err_1;
     m_rx_d_1         <= m_tx_d_1;
     m_rx_en_1        <= m_tx_en_1;
     m_rx_err_1       <= m_tx_err_1;
     m_rx_col_1       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_1       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_1     <= tx_control_1;
     rgmii_in_1       <= rgmii_out_1;
     rxp_1       <= txp_1 ;
 
     gm_rx_d_2        <= gm_tx_d_2;
     gm_rx_dv_2       <= gm_tx_en_2;
     gm_rx_err_2      <= gm_tx_err_2;
     m_rx_d_2         <= m_tx_d_2;
     m_rx_en_2        <= m_tx_en_2;
     m_rx_err_2       <= m_tx_err_2;
     m_rx_col_2       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_2       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_2     <= tx_control_2;
     rgmii_in_2       <= rgmii_out_2;
     rxp_2       <= txp_2 ;
 
     gm_rx_d_3        <= gm_tx_d_3;
     gm_rx_dv_3       <= gm_tx_en_3;
     gm_rx_err_3      <= gm_tx_err_3;
     m_rx_d_3         <= m_tx_d_3;
     m_rx_en_3        <= m_tx_en_3;
     m_rx_err_3       <= m_tx_err_3;
     m_rx_col_3       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_3       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_3     <= tx_control_3;
     rgmii_in_3       <= rgmii_out_3;
     rxp_3       <= txp_3 ;

     gm_rx_d_4        <= gm_tx_d_4;
     gm_rx_dv_4       <= gm_tx_en_4;
     gm_rx_err_4      <= gm_tx_err_4;
     m_rx_d_4         <= m_tx_d_4;
     m_rx_en_4        <= m_tx_en_4;
     m_rx_err_4       <= m_tx_err_4;
     m_rx_col_4       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_4       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_4     <= tx_control_4;
     rgmii_in_4       <= rgmii_out_4;
     rxp_4       <= txp_4 ;
 
     gm_rx_d_5        <= gm_tx_d_5;
     gm_rx_dv_5       <= gm_tx_en_5;
     gm_rx_err_5      <= gm_tx_err_5;
     m_rx_d_5         <= m_tx_d_5;
     m_rx_en_5        <= m_tx_en_5;
     m_rx_err_5       <= m_tx_err_5;
     m_rx_col_5       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_5       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_5     <= tx_control_5;
     rgmii_in_5       <= rgmii_out_5;
     rxp_5       <= txp_5 ;
 
     gm_rx_d_6        <= gm_tx_d_6;
     gm_rx_dv_6       <= gm_tx_en_6;
     gm_rx_err_6      <= gm_tx_err_6;
     m_rx_d_6         <= m_tx_d_6;
     m_rx_en_6        <= m_tx_en_6;
     m_rx_err_6       <= m_tx_err_6;
     m_rx_col_6       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_6       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_6     <= tx_control_6;
     rgmii_in_6       <= rgmii_out_6;
     rxp_6       <= txp_6 ;
 
     gm_rx_d_7        <= gm_tx_d_7;
     gm_rx_dv_7       <= gm_tx_en_7;
     gm_rx_err_7      <= gm_tx_err_7;
     m_rx_d_7         <= m_tx_d_7;
     m_rx_en_7        <= m_tx_en_7;
     m_rx_err_7       <= m_tx_err_7;
     m_rx_col_7       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_7       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_7     <= tx_control_7;
     rgmii_in_7       <= rgmii_out_7;
     rxp_7       <= txp_7 ;

     gm_rx_d_8        <= gm_tx_d_8;
     gm_rx_dv_8       <= gm_tx_en_8;
     gm_rx_err_8      <= gm_tx_err_8;
     m_rx_d_8         <= m_tx_d_8;
     m_rx_en_8        <= m_tx_en_8;
     m_rx_err_8       <= m_tx_err_8;
     m_rx_col_8       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_8       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_8     <= tx_control_8;
     rgmii_in_8       <= rgmii_out_8;
     rxp_8       <= txp_8 ;
 
     gm_rx_d_9        <= gm_tx_d_9;
     gm_rx_dv_9       <= gm_tx_en_9;
     gm_rx_err_9      <= gm_tx_err_9;
     m_rx_d_9         <= m_tx_d_9;
     m_rx_en_9        <= m_tx_en_9;
     m_rx_err_9       <= m_tx_err_9;
     m_rx_col_9       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_9       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_9     <= tx_control_9;
     rgmii_in_9       <= rgmii_out_9;
     rxp_9       <= txp_9 ;
 
     gm_rx_d_10        <= gm_tx_d_10;
     gm_rx_dv_10       <= gm_tx_en_10;
     gm_rx_err_10      <= gm_tx_err_10;
     m_rx_d_10         <= m_tx_d_10;
     m_rx_en_10        <= m_tx_en_10;
     m_rx_err_10       <= m_tx_err_10;
     m_rx_col_10       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_10       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_10     <= tx_control_10;
     rgmii_in_10       <= rgmii_out_10;
     rxp_10       <= txp_10 ;
 
     gm_rx_d_11        <= gm_tx_d_11;
     gm_rx_dv_11       <= gm_tx_en_11;
     gm_rx_err_11      <= gm_tx_err_11;
     m_rx_d_11         <= m_tx_d_11;
     m_rx_en_11        <= m_tx_en_11;
     m_rx_err_11       <= m_tx_err_11;
     m_rx_col_11       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_11       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_11     <= tx_control_11;
     rgmii_in_11       <= rgmii_out_11;
     rxp_11       <= txp_11 ;

  end generate;
   
  SixteenPort_DUT_without_FIFO: if (MAX_CHANNELS = 16) generate
   begin
     -- NightFury PHYIP signals
     tx_cal_busy        <= tx_cal_busy_0 or tx_cal_busy_1 or tx_cal_busy_2 or tx_cal_busy_3 or
                           tx_cal_busy_4 or tx_cal_busy_5 or tx_cal_busy_6 or tx_cal_busy_7 or
                           tx_cal_busy_8 or tx_cal_busy_9 or tx_cal_busy_10 or tx_cal_busy_11 or
                           tx_cal_busy_12 or tx_cal_busy_13 or tx_cal_busy_14 or tx_cal_busy_15;
     rx_is_lockedtodata <= rx_is_lockedtodata_0 and rx_is_lockedtodata_1 and rx_is_lockedtodata_2 and rx_is_lockedtodata_3 and
                           rx_is_lockedtodata_4 and rx_is_lockedtodata_5 and rx_is_lockedtodata_6 and rx_is_lockedtodata_7 and
                           rx_is_lockedtodata_8 and rx_is_lockedtodata_9 and rx_is_lockedtodata_10 and rx_is_lockedtodata_11 and
                           rx_is_lockedtodata_12 and rx_is_lockedtodata_13 and rx_is_lockedtodata_14 and rx_is_lockedtodata_15;
     rx_cal_busy        <= rx_cal_busy_0 or rx_cal_busy_1 or rx_cal_busy_2 or rx_cal_busy_3 or
                           rx_cal_busy_4 or rx_cal_busy_5 or rx_cal_busy_6 or rx_cal_busy_7 or
                           rx_cal_busy_8 or rx_cal_busy_9 or rx_cal_busy_10 or rx_cal_busy_11 or
                           rx_cal_busy_12 or rx_cal_busy_13 or rx_cal_busy_14 or rx_cal_busy_15;
 
     led_link         <= led_link_0;
    --input of DUT
     ff_rx_dsav       <= '0'; 
     rx_afull_clk     <= rx_clk;
     rx_afull_channel <= (others => '0');
     rx_afull_data    <= "00";
     rx_afull_valid   <= '1' ;
     data_tx_data_0   <= ff_tx_data;
     data_tx_eop_0    <= ff_tx_eop;
     data_tx_error_0  <= ff_tx_err;
     data_tx_sop_0    <= ff_tx_sop;
     data_tx_valid_0  <= ff_tx_wren;
     tx_crc_fwd_0     <= ff_tx_crc_fwd;
     data_rx_ready_15  <= ff_rx_rdy;
     tbi_tx_clk_0     <= tx_clk_1000mbps;
     tbi_rx_clk_0     <= rx_clk_1000mbps;
     tbi_tx_clk_1     <= tx_clk_1000mbps;
     tbi_rx_clk_1     <= rx_clk_1000mbps;
     tbi_tx_clk_2     <= tx_clk_1000mbps;
     tbi_rx_clk_2     <= rx_clk_1000mbps;
     tbi_tx_clk_3     <= tx_clk_1000mbps;
     tbi_rx_clk_3     <= rx_clk_1000mbps;
     tbi_tx_clk_4     <= tx_clk_1000mbps;
     tbi_rx_clk_4     <= rx_clk_1000mbps;
     tbi_tx_clk_5     <= tx_clk_1000mbps;
     tbi_rx_clk_5     <= rx_clk_1000mbps;
     tbi_tx_clk_6     <= tx_clk_1000mbps;
     tbi_rx_clk_6     <= rx_clk_1000mbps;
     tbi_tx_clk_7     <= tx_clk_1000mbps;
     tbi_rx_clk_7     <= rx_clk_1000mbps;
     tbi_tx_clk_8     <= tx_clk_1000mbps;
     tbi_rx_clk_8     <= rx_clk_1000mbps;
     tbi_tx_clk_9     <= tx_clk_1000mbps;
     tbi_rx_clk_9     <= rx_clk_1000mbps;
     tbi_tx_clk_10     <= tx_clk_1000mbps;
     tbi_rx_clk_10     <= rx_clk_1000mbps;
     tbi_tx_clk_11     <= tx_clk_1000mbps;
     tbi_rx_clk_11     <= rx_clk_1000mbps;
     tbi_tx_clk_12     <= tx_clk_1000mbps;
     tbi_rx_clk_12     <= rx_clk_1000mbps;
     tbi_tx_clk_13     <= tx_clk_1000mbps;
     tbi_rx_clk_13     <= rx_clk_1000mbps;
     tbi_tx_clk_14     <= tx_clk_1000mbps;
     tbi_rx_clk_14     <= rx_clk_1000mbps;
     tbi_tx_clk_15     <= tx_clk_1000mbps;
     tbi_rx_clk_15     <= rx_clk_1000mbps;
     set_10_0         <= '0';
     set_1000_0       <= '0';
     set_10_1         <= '0';
     set_1000_1       <= '0';
     set_10_2         <= '0';
     set_1000_2       <= '0';
     set_10_3         <= '0';
     set_1000_3       <= '0';
     set_10_4         <= '0';
     set_1000_4       <= '0';
     set_10_4         <= '0';
     set_1000_4       <= '0';
     set_10_5         <= '0';
     set_1000_5       <= '0';
     set_10_6         <= '0';
     set_1000_6       <= '0';
     set_10_7         <= '0';
     set_1000_7       <= '0';
     set_10_8         <= '0';
     set_1000_8       <= '0';
     set_10_9         <= '0';
     set_1000_9       <= '0';
     set_10_10         <= '0';
     set_1000_10       <= '0';
     set_10_11         <= '0';
     set_1000_11       <= '0';
     set_10_12         <= '0';
     set_1000_12       <= '0';
     set_10_13         <= '0';
     set_1000_13       <= '0';
     set_10_14         <= '0';
     set_1000_14       <= '0';
     set_10_15         <= '0';
     set_1000_15       <= '0';
 
     xon_gen_0        <= '0';
     xoff_gen_0       <= '0';
     xon_gen_1        <= '0';
     xoff_gen_1       <= '0';
     xon_gen_2        <= '0';
     xoff_gen_2       <= '0';
     xon_gen_3        <= '0';
     xoff_gen_3       <= '0';
     xon_gen_4        <= '0';
     xoff_gen_4       <= '0';
     xon_gen_5        <= '0';
     xoff_gen_5       <= '0';
     xon_gen_6        <= '0';
     xoff_gen_6       <= '0';
     xon_gen_7        <= '0';
     xoff_gen_7       <= '0';
     xon_gen_8        <= '0';
     xoff_gen_8       <= '0';
     xon_gen_9        <= '0';
     xoff_gen_9       <= '0';
     xon_gen_10        <= '0';
     xoff_gen_10       <= '0';
     xon_gen_11        <= '0';
     xoff_gen_11       <= '0';
     xon_gen_12        <= '0';
     xoff_gen_12       <= '0';
     xon_gen_13        <= '0';
     xoff_gen_13       <= '0';
     xon_gen_14        <= '0';
     xoff_gen_14       <= '0';
     xon_gen_15        <= '0';
     xoff_gen_15       <= '0';

     magic_sleep_n_0  <= magic_sleep_n;
     magic_sleep_n_1  <= magic_sleep_n;
     magic_sleep_n_2  <= magic_sleep_n;
     magic_sleep_n_3  <= magic_sleep_n;
     magic_sleep_n_4  <= magic_sleep_n;
     magic_sleep_n_5  <= magic_sleep_n;
     magic_sleep_n_6  <= magic_sleep_n;
     magic_sleep_n_7  <= magic_sleep_n;
     magic_sleep_n_8  <= magic_sleep_n;
     magic_sleep_n_9  <= magic_sleep_n;
     magic_sleep_n_10  <= magic_sleep_n;
     magic_sleep_n_11  <= magic_sleep_n;
     magic_sleep_n_12  <= magic_sleep_n;
     magic_sleep_n_13  <= magic_sleep_n;
     magic_sleep_n_14  <= magic_sleep_n;
     magic_sleep_n_15  <= magic_sleep_n;


    --output of DUT
     ff_rx_err_stat   <= pkt_class_data_15(0) & data_rx_error_15(4) & "0000000000000000" & (pkt_class_data_15(1) or pkt_class_data_15(0)) & data_rx_error_15(3 downto 0) when (pkt_class_valid_15='1') else (others => '0') ;
     ff_rx_err        <= data_rx_error_15 (0) or data_rx_error_15 (1) or data_rx_error_15 (2) or data_rx_error_15(3) or data_rx_error_15(4);
     ff_rx_vlan       <= pkt_class_data_15 (1) when (pkt_class_valid_15='1') else '0' ;
     ff_rx_bcast      <= pkt_class_data_15 (2) when (pkt_class_valid_15='1') else '0' ;
     ff_rx_mcast      <= pkt_class_data_15 (3) when (pkt_class_valid_15='1') else '0' ;
     ff_rx_ucast      <= pkt_class_data_15 (4) when (pkt_class_valid_15='1') else '0' ;
     ff_tx_clk        <= mac_tx_clk_0;
     ff_rx_clk        <= mac_rx_clk_0;
     ff_tx_rdy        <= data_tx_ready_0;
     ff_rx_data       <= data_rx_data_15;
     ff_rx_dval       <= data_rx_valid_15;
     ff_rx_eop        <= data_rx_eop_15;
     ff_rx_sop        <= data_rx_sop_15;
     rx_err           <= data_rx_error_15 & ff_rx_err;
	 magic_wakeup 	  <= magic_wakeup_15;

    --loopback
     data_rx_ready_0  <= '1';--data_tx_ready_1;
     tx_crc_fwd_1     <= ff_tx_crc_fwd;
 
 
    u_ch0_2_ch1 : loopback_adapter  
    port map(
        
      -- Interface:clk                     
      clk      => mac_tx_clk_0,
      reset    => reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_0,
      in_data  => data_rx_data_0,
      in_startofpacket => data_rx_sop_0,
      in_endofpacket => data_rx_eop_0,
      in_error => data_rx_error_0,
      -- Interface:out
      out_ready => data_tx_ready_1,
      out_valid => data_tx_valid_1,
      out_data => data_tx_data_1,
      out_startofpacket => data_tx_sop_1,
      out_endofpacket => data_tx_eop_1,
      out_error => data_tx_error_1
    );
 
     data_rx_ready_1  <= '1';
     tx_crc_fwd_2     <= ff_tx_crc_fwd;
 
    u_ch1_2_ch2 : loopback_adapter 
    port map(
      -- Interface:clk                     
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_1,
      in_data=>data_rx_data_1,
      in_startofpacket=>data_rx_sop_1,
      in_endofpacket=>data_rx_eop_1,
      in_error=>data_rx_error_1,
      -- Interface:out
      out_ready=>data_tx_ready_2,
      out_valid=>data_tx_valid_2,
      out_data=>data_tx_data_2,
      out_startofpacket=>data_tx_sop_2,
      out_endofpacket=>data_tx_eop_2,
      out_error=>data_tx_error_2
    );
 
     data_rx_ready_2  <= '1';
     tx_crc_fwd_3     <= ff_tx_crc_fwd;
 
    u_ch2_2_ch3: loopback_adapter 
    port map (
      -- Interface:clk                     
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_2,
      in_data=>data_rx_data_2,
      in_startofpacket=>data_rx_sop_2,
      in_endofpacket=>data_rx_eop_2,
      in_error=>data_rx_error_2,
      -- Interface:out
      out_ready=>data_tx_ready_3,
      out_valid=>data_tx_valid_3,
      out_data=>data_tx_data_3,
      out_startofpacket=>data_tx_sop_3,
      out_endofpacket=>data_tx_eop_3,
      out_error=>data_tx_error_3
    );
 
      data_rx_ready_3  <= '1';
     tx_crc_fwd_4     <= ff_tx_crc_fwd;
 
    u_ch3_2_ch4: loopback_adapter 
    port map (
      -- Interface:clk                     
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_3,
      in_data=>data_rx_data_3,
      in_startofpacket=>data_rx_sop_3,
      in_endofpacket=>data_rx_eop_3,
      in_error=>data_rx_error_3,
      -- Interface:out
      out_ready=>data_tx_ready_4,
      out_valid=>data_tx_valid_4,
      out_data=>data_tx_data_4,
      out_startofpacket=>data_tx_sop_4,
      out_endofpacket=>data_tx_eop_4,
      out_error=>data_tx_error_4
  );
 
     data_rx_ready_4  <= '1';
     tx_crc_fwd_5     <= ff_tx_crc_fwd;
 
    u_ch4_2_ch5: loopback_adapter  
    port map (
      -- Interface:clk                     
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_4,
      in_data=>data_rx_data_4,
      in_startofpacket=>data_rx_sop_4,
      in_endofpacket=>data_rx_eop_4,
      in_error=>data_rx_error_4,
      -- Interface:out
      out_ready=>data_tx_ready_5,
      out_valid=>data_tx_valid_5,
      out_data=>data_tx_data_5,
      out_startofpacket=>data_tx_sop_5,
      out_endofpacket=>data_tx_eop_5,
      out_error=>data_tx_error_5
    );
 
     data_rx_ready_5  <= '1';
     tx_crc_fwd_6     <= ff_tx_crc_fwd;
 
    u_ch5_2_ch6: loopback_adapter  
    port map(
      -- Interface:clk                     
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_5,
      in_data=>data_rx_data_5,
      in_startofpacket=>data_rx_sop_5,
      in_endofpacket=>data_rx_eop_5,
      in_error=>data_rx_error_5,
      -- Interface:out
      out_ready=>data_tx_ready_6,
      out_valid=>data_tx_valid_6,
      out_data=>data_tx_data_6,
      out_startofpacket=>data_tx_sop_6,
      out_endofpacket=>data_tx_eop_6,
      out_error=>data_tx_error_6
    );
 
     data_rx_ready_6  <= '1';
     tx_crc_fwd_7     <= ff_tx_crc_fwd;
 
    u_ch6_2_ch7: loopback_adapter 
    port map (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_6,
      in_data=>data_rx_data_6,
      in_startofpacket=>data_rx_sop_6,
      in_endofpacket=>data_rx_eop_6,
      in_error=>data_rx_error_6,
      -- Interface:out
      out_ready=>data_tx_ready_7,
      out_valid=>data_tx_valid_7,
      out_data=>data_tx_data_7,
      out_startofpacket=>data_tx_sop_7,
      out_endofpacket=>data_tx_eop_7,
      out_error=>data_tx_error_7
    );
  
     data_rx_ready_7  <= '1';
     tx_crc_fwd_8    <= ff_tx_crc_fwd;
 
    u_ch7_2_ch8 : loopback_adapter 
    port map  (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_7,
      in_data=>data_rx_data_7,
      in_startofpacket=>data_rx_sop_7,
      in_endofpacket=>data_rx_eop_7,
      in_error=>data_rx_error_7,
      -- Interface:out
      out_ready=>data_tx_ready_8,
      out_valid=>data_tx_valid_8,
      out_data=>data_tx_data_8,
      out_startofpacket=>data_tx_sop_8,
      out_endofpacket=>data_tx_eop_8,
      out_error=>data_tx_error_8
    );
 
     data_rx_ready_8  <= '1';
     tx_crc_fwd_9     <= ff_tx_crc_fwd;
 
    u_ch8_2_ch9: loopback_adapter  
    port map(
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_8,
      in_data=>data_rx_data_8,
      in_startofpacket=>data_rx_sop_8,
      in_endofpacket=>data_rx_eop_8,
      in_error=>data_rx_error_8,
      -- Interface:out
      out_ready=>data_tx_ready_9,
      out_valid=>data_tx_valid_9,
      out_data=>data_tx_data_9,
      out_startofpacket=>data_tx_sop_9,
      out_endofpacket=>data_tx_eop_9,
      out_error=>data_tx_error_9
    );
 
     data_rx_ready_9  <= '1';
     tx_crc_fwd_10     <= ff_tx_crc_fwd;
 
    u_ch9_2_ch10: loopback_adapter
     port map  (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_9,
      in_data=>data_rx_data_9,
      in_startofpacket=>data_rx_sop_9,
      in_endofpacket=>data_rx_eop_9,
      in_error=>data_rx_error_9,
      -- Interface:out
      out_ready=>data_tx_ready_10,
      out_valid=>data_tx_valid_10,
      out_data=>data_tx_data_10,
      out_startofpacket=>data_tx_sop_10,
      out_endofpacket=>data_tx_eop_10,
      out_error=>data_tx_error_10
    );
 
     data_rx_ready_10  <= '1';
     tx_crc_fwd_11     <= ff_tx_crc_fwd;
 
    u_ch10_2_ch11 :loopback_adapter
     port map (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_10,
      in_data=>data_rx_data_10,
      in_startofpacket=>data_rx_sop_10,
      in_endofpacket=>data_rx_eop_10,
      in_error=>data_rx_error_10,
      -- Interface:out
      out_ready=>data_tx_ready_11,
      out_valid=>data_tx_valid_11,
      out_data=>data_tx_data_11,
      out_startofpacket=>data_tx_sop_11,
      out_endofpacket=>data_tx_eop_11,
      out_error=>data_tx_error_11
    ); 
    
     data_rx_ready_11  <= '1';
     tx_crc_fwd_12     <= ff_tx_crc_fwd;
 
    u_ch11_2_ch12:loopback_adapter  
    port map(
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_11,
      in_data=>data_rx_data_11,
      in_startofpacket=>data_rx_sop_11,
      in_endofpacket=>data_rx_eop_11,
      in_error=>data_rx_error_11,
      -- Interface:out
      out_ready=>data_tx_ready_12,
      out_valid=>data_tx_valid_12,
      out_data=>data_tx_data_12,
      out_startofpacket=>data_tx_sop_12,
      out_endofpacket=>data_tx_eop_12,
      out_error=>data_tx_error_12
    );
 
     data_rx_ready_12  <= '1';
     tx_crc_fwd_13     <= ff_tx_crc_fwd;
 
    u_ch12_2_ch13:loopback_adapter 
    port map (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_12,
      in_data=>data_rx_data_12,
      in_startofpacket=>data_rx_sop_12,
      in_endofpacket=>data_rx_eop_12,
      in_error=>data_rx_error_12,
      -- Interface:out
      out_ready=>data_tx_ready_13,
      out_valid=>data_tx_valid_13,
      out_data=>data_tx_data_13,
      out_startofpacket=>data_tx_sop_13,
      out_endofpacket=>data_tx_eop_13,
      out_error=>data_tx_error_13
    );
 
     data_rx_ready_13  <= '1';
     tx_crc_fwd_14     <= ff_tx_crc_fwd;
 
    u_ch13_2_ch14:loopback_adapter  
    port map(
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_13,
      in_data=>data_rx_data_13,
      in_startofpacket=>data_rx_sop_13,
      in_endofpacket=>data_rx_eop_13,
      in_error=>data_rx_error_13,
      -- Interface:out
      out_ready=>data_tx_ready_14,
      out_valid=>data_tx_valid_14,
      out_data=>data_tx_data_14,
      out_startofpacket=>data_tx_sop_14,
      out_endofpacket=>data_tx_eop_14,
      out_error=>data_tx_error_14
    );
 
     data_rx_ready_14  <= '1';
     tx_crc_fwd_15     <= ff_tx_crc_fwd;
 
    u_ch14_2_ch15:loopback_adapter 
    port map (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_14,
      in_data=>data_rx_data_14,
      in_startofpacket=>data_rx_sop_14,
      in_endofpacket=>data_rx_eop_14,
      in_error=>data_rx_error_14,
      -- Interface:out
      out_ready=>data_tx_ready_15,
      out_valid=>data_tx_valid_15,
      out_data=>data_tx_data_15,
      out_startofpacket=>data_tx_sop_15,
      out_endofpacket=>data_tx_eop_15,
      out_error=>data_tx_error_15
    );
 

--assigning to GMII/MII TX monitoring
     gm_tx_data       <= gm_tx_d_0;
     gm_tx_en         <= gm_tx_en_0;
     gm_tx_err        <= gm_tx_err_0;
     m_tx_data        <= m_tx_d_0;
     m_tx_en          <= m_tx_en_0;
     m_tx_err         <= m_tx_err_0;
 
     gm_rx_d_0        <= gm_tx_d_0;
     gm_rx_dv_0       <= gm_tx_en_0;
     gm_rx_err_0      <= gm_tx_err_0;
     m_rx_d_0         <= m_tx_d_0;
     m_rx_en_0        <= m_tx_en_0;
     m_rx_err_0       <= m_tx_err_0;
     m_rx_col_0       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_0       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_0     <= tx_control_0;
     rgmii_in_0       <= rgmii_out_0;
     rxp_0       <= txp_0 ;

     gm_rx_d_1        <= gm_tx_d_1;
     gm_rx_dv_1       <= gm_tx_en_1;
     gm_rx_err_1      <= gm_tx_err_1;
     m_rx_d_1         <= m_tx_d_1;
     m_rx_en_1        <= m_tx_en_1;
     m_rx_err_1       <= m_tx_err_1;
     m_rx_col_1       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_1       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_1     <= tx_control_1;
     rgmii_in_1       <= rgmii_out_1;
     rxp_1       <= txp_1 ;
 
     gm_rx_d_2        <= gm_tx_d_2;
     gm_rx_dv_2       <= gm_tx_en_2;
     gm_rx_err_2      <= gm_tx_err_2;
     m_rx_d_2         <= m_tx_d_2;
     m_rx_en_2        <= m_tx_en_2;
     m_rx_err_2       <= m_tx_err_2;
     m_rx_col_2       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_2       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_2     <= tx_control_2;
     rgmii_in_2       <= rgmii_out_2;
     rxp_2       <= txp_2 ;
 
     gm_rx_d_3        <= gm_tx_d_3;
     gm_rx_dv_3       <= gm_tx_en_3;
     gm_rx_err_3      <= gm_tx_err_3;
     m_rx_d_3         <= m_tx_d_3;
     m_rx_en_3        <= m_tx_en_3;
     m_rx_err_3       <= m_tx_err_3;
     m_rx_col_3       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_3       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_3     <= tx_control_3;
     rgmii_in_3       <= rgmii_out_3;
     rxp_3       <= txp_3 ;

     gm_rx_d_4        <= gm_tx_d_4;
     gm_rx_dv_4       <= gm_tx_en_4;
     gm_rx_err_4      <= gm_tx_err_4;
     m_rx_d_4         <= m_tx_d_4;
     m_rx_en_4        <= m_tx_en_4;
     m_rx_err_4       <= m_tx_err_4;
     m_rx_col_4       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_4       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_4     <= tx_control_4;
     rgmii_in_4       <= rgmii_out_4;
     rxp_4       <= txp_4 ;
 
     gm_rx_d_5        <= gm_tx_d_5;
     gm_rx_dv_5       <= gm_tx_en_5;
     gm_rx_err_5      <= gm_tx_err_5;
     m_rx_d_5         <= m_tx_d_5;
     m_rx_en_5        <= m_tx_en_5;
     m_rx_err_5       <= m_tx_err_5;
     m_rx_col_5       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_5       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_5     <= tx_control_5;
     rgmii_in_5       <= rgmii_out_5;
     rxp_5       <= txp_5 ;
 
     gm_rx_d_6        <= gm_tx_d_6;
     gm_rx_dv_6       <= gm_tx_en_6;
     gm_rx_err_6      <= gm_tx_err_6;
     m_rx_d_6         <= m_tx_d_6;
     m_rx_en_6        <= m_tx_en_6;
     m_rx_err_6       <= m_tx_err_6;
     m_rx_col_6       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_6       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_6     <= tx_control_6;
     rgmii_in_6       <= rgmii_out_6;
     rxp_6       <= txp_6 ;
 
     gm_rx_d_7        <= gm_tx_d_7;
     gm_rx_dv_7       <= gm_tx_en_7;
     gm_rx_err_7      <= gm_tx_err_7;
     m_rx_d_7         <= m_tx_d_7;
     m_rx_en_7        <= m_tx_en_7;
     m_rx_err_7       <= m_tx_err_7;
     m_rx_col_7       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_7       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_7     <= tx_control_7;
     rgmii_in_7       <= rgmii_out_7;
     rxp_7       <= txp_7 ;

     gm_rx_d_8        <= gm_tx_d_8;
     gm_rx_dv_8       <= gm_tx_en_8;
     gm_rx_err_8      <= gm_tx_err_8;
     m_rx_d_8         <= m_tx_d_8;
     m_rx_en_8        <= m_tx_en_8;
     m_rx_err_8       <= m_tx_err_8;
     m_rx_col_8       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_8       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_8     <= tx_control_8;
     rgmii_in_8       <= rgmii_out_8;
     rxp_8       <= txp_8 ;
 
     gm_rx_d_9        <= gm_tx_d_9;
     gm_rx_dv_9       <= gm_tx_en_9;
     gm_rx_err_9      <= gm_tx_err_9;
     m_rx_d_9         <= m_tx_d_9;
     m_rx_en_9        <= m_tx_en_9;
     m_rx_err_9       <= m_tx_err_9;
     m_rx_col_9       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_9       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_9     <= tx_control_9;
     rgmii_in_9       <= rgmii_out_9;
     rxp_9       <= txp_9 ;
 
     gm_rx_d_10        <= gm_tx_d_10;
     gm_rx_dv_10       <= gm_tx_en_10;
     gm_rx_err_10      <= gm_tx_err_10;
     m_rx_d_10         <= m_tx_d_10;
     m_rx_en_10        <= m_tx_en_10;
     m_rx_err_10       <= m_tx_err_10;
     m_rx_col_10       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_10       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_10     <= tx_control_10;
     rgmii_in_10       <= rgmii_out_10;
     rxp_10       <= txp_10 ;
 
     gm_rx_d_11        <= gm_tx_d_11;
     gm_rx_dv_11       <= gm_tx_en_11;
     gm_rx_err_11      <= gm_tx_err_11;
     m_rx_d_11         <= m_tx_d_11;
     m_rx_en_11        <= m_tx_en_11;
     m_rx_err_11       <= m_tx_err_11;
     m_rx_col_11       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_11       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_11     <= tx_control_11;
     rgmii_in_11       <= rgmii_out_11;
     rxp_11       <= txp_11 ;

     gm_rx_d_12        <= gm_tx_d_12;
     gm_rx_dv_12       <= gm_tx_en_12;
     gm_rx_err_12      <= gm_tx_err_12;
     m_rx_d_12         <= m_tx_d_12;
     m_rx_en_12        <= m_tx_en_12;
     m_rx_err_12       <= m_tx_err_12;
     m_rx_col_12       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_12       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_12     <= tx_control_12;
     rgmii_in_12       <= rgmii_out_12;
     rxp_12       <= txp_12 ;
 
     gm_rx_d_13        <= gm_tx_d_13;
     gm_rx_dv_13       <= gm_tx_en_13;
     gm_rx_err_13      <= gm_tx_err_13;
     m_rx_d_13         <= m_tx_d_13;
     m_rx_en_13        <= m_tx_en_13;
     m_rx_err_13       <= m_tx_err_13;
     m_rx_col_13       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_13       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_13     <= tx_control_13;
     rgmii_in_13       <= rgmii_out_13;
     rxp_13       <= txp_13 ;
 
     gm_rx_d_14        <= gm_tx_d_14;
     gm_rx_dv_14       <= gm_tx_en_14;
     gm_rx_err_14      <= gm_tx_err_14;
     m_rx_d_14         <= m_tx_d_14;
     m_rx_en_14        <= m_tx_en_14;
     m_rx_err_14       <= m_tx_err_14;
     m_rx_col_14       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_14       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_14     <= tx_control_14;
     rgmii_in_14       <= rgmii_out_14;
     rxp_14       <= txp_14 ;
 
     gm_rx_d_15        <= gm_tx_d_15;
     gm_rx_dv_15       <= gm_tx_en_15;
     gm_rx_err_15      <= gm_tx_err_15;
     m_rx_d_15         <= m_tx_d_15;
     m_rx_en_15        <= m_tx_en_15;
     m_rx_err_15       <= m_tx_err_15;
     m_rx_col_15       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_15       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_15     <= tx_control_15;
     rgmii_in_15       <= rgmii_out_15;
     rxp_15       <= txp_15 ;

  end generate;
   
  TwentyPort_DUT_without_FIFO: if (MAX_CHANNELS = 20) generate
   begin
     -- NightFury PHYIP signals
     tx_cal_busy        <= tx_cal_busy_0 or tx_cal_busy_1 or tx_cal_busy_2 or tx_cal_busy_3 or
                           tx_cal_busy_4 or tx_cal_busy_5 or tx_cal_busy_6 or tx_cal_busy_7 or
                           tx_cal_busy_8 or tx_cal_busy_9 or tx_cal_busy_10 or tx_cal_busy_11 or
                           tx_cal_busy_12 or tx_cal_busy_13 or tx_cal_busy_14 or tx_cal_busy_15 or
                           tx_cal_busy_16 or tx_cal_busy_17 or tx_cal_busy_18 or tx_cal_busy_19;
     rx_is_lockedtodata <= rx_is_lockedtodata_0 and rx_is_lockedtodata_1 and rx_is_lockedtodata_2 and rx_is_lockedtodata_3 and
                           rx_is_lockedtodata_4 and rx_is_lockedtodata_5 and rx_is_lockedtodata_6 and rx_is_lockedtodata_7 and
                           rx_is_lockedtodata_8 and rx_is_lockedtodata_9 and rx_is_lockedtodata_10 and rx_is_lockedtodata_11 and
                           rx_is_lockedtodata_12 and rx_is_lockedtodata_13 and rx_is_lockedtodata_14 and rx_is_lockedtodata_15 and
                           rx_is_lockedtodata_16 and rx_is_lockedtodata_17 and rx_is_lockedtodata_18 and rx_is_lockedtodata_19;
     rx_cal_busy        <= rx_cal_busy_0 or rx_cal_busy_1 or rx_cal_busy_2 or rx_cal_busy_3 or
                           rx_cal_busy_4 or rx_cal_busy_5 or rx_cal_busy_6 or rx_cal_busy_7 or
                           rx_cal_busy_8 or rx_cal_busy_9 or rx_cal_busy_10 or rx_cal_busy_11 or
                           rx_cal_busy_12 or rx_cal_busy_13 or rx_cal_busy_14 or rx_cal_busy_15 or
                           rx_cal_busy_16 or rx_cal_busy_17 or rx_cal_busy_18 or rx_cal_busy_19;

     led_link         <= led_link_0;
    --input of DUT
     ff_rx_dsav       <= '0'; 
     rx_afull_clk     <= rx_clk;
     rx_afull_channel <= (others => '0');
     rx_afull_data    <= "00";
     rx_afull_valid   <= '1' ;
     data_tx_data_0   <= ff_tx_data;
     data_tx_eop_0    <= ff_tx_eop;
     data_tx_error_0  <= ff_tx_err;
     data_tx_sop_0    <= ff_tx_sop;
     data_tx_valid_0  <= ff_tx_wren;
     tx_crc_fwd_0     <= ff_tx_crc_fwd;
     data_rx_ready_19  <= ff_rx_rdy;
     tbi_tx_clk_0     <= tx_clk_1000mbps;
     tbi_rx_clk_0     <= rx_clk_1000mbps;
     tbi_tx_clk_1     <= tx_clk_1000mbps;
     tbi_rx_clk_1     <= rx_clk_1000mbps;
     tbi_tx_clk_2     <= tx_clk_1000mbps;
     tbi_rx_clk_2     <= rx_clk_1000mbps;
     tbi_tx_clk_3     <= tx_clk_1000mbps;
     tbi_rx_clk_3     <= rx_clk_1000mbps;
     tbi_tx_clk_4     <= tx_clk_1000mbps;
     tbi_rx_clk_4     <= rx_clk_1000mbps;
     tbi_tx_clk_5     <= tx_clk_1000mbps;
     tbi_rx_clk_5     <= rx_clk_1000mbps;
     tbi_tx_clk_6     <= tx_clk_1000mbps;
     tbi_rx_clk_6     <= rx_clk_1000mbps;
     tbi_tx_clk_7     <= tx_clk_1000mbps;
     tbi_rx_clk_7     <= rx_clk_1000mbps;
     tbi_tx_clk_8     <= tx_clk_1000mbps;
     tbi_rx_clk_8     <= rx_clk_1000mbps;
     tbi_tx_clk_9     <= tx_clk_1000mbps;
     tbi_rx_clk_9     <= rx_clk_1000mbps;
     tbi_tx_clk_10     <= tx_clk_1000mbps;
     tbi_rx_clk_10     <= rx_clk_1000mbps;
     tbi_tx_clk_11     <= tx_clk_1000mbps;
     tbi_rx_clk_11     <= rx_clk_1000mbps;
     tbi_tx_clk_12     <= tx_clk_1000mbps;
     tbi_rx_clk_12     <= rx_clk_1000mbps;
     tbi_tx_clk_13     <= tx_clk_1000mbps;
     tbi_rx_clk_13     <= rx_clk_1000mbps;
     tbi_tx_clk_14     <= tx_clk_1000mbps;
     tbi_rx_clk_14     <= rx_clk_1000mbps;
     tbi_tx_clk_15     <= tx_clk_1000mbps;
     tbi_rx_clk_15     <= rx_clk_1000mbps;
     tbi_tx_clk_16     <= tx_clk_1000mbps;
     tbi_rx_clk_16     <= rx_clk_1000mbps;
     tbi_tx_clk_17     <= tx_clk_1000mbps;
     tbi_rx_clk_17     <= rx_clk_1000mbps;
     tbi_tx_clk_18     <= tx_clk_1000mbps;
     tbi_rx_clk_18     <= rx_clk_1000mbps;
     tbi_tx_clk_19     <= tx_clk_1000mbps;
     tbi_rx_clk_19     <= rx_clk_1000mbps;
     set_10_0         <= '0';
     set_1000_0       <= '0';
     set_10_1         <= '0';
     set_1000_1       <= '0';
     set_10_2         <= '0';
     set_1000_2       <= '0';
     set_10_3         <= '0';
     set_1000_3       <= '0';
     set_10_4         <= '0';
     set_1000_4       <= '0';
     set_10_4         <= '0';
     set_1000_4       <= '0';
     set_10_5         <= '0';
     set_1000_5       <= '0';
     set_10_6         <= '0';
     set_1000_6       <= '0';
     set_10_7         <= '0';
     set_1000_7       <= '0';
     set_10_8         <= '0';
     set_1000_8       <= '0';
     set_10_9         <= '0';
     set_1000_9       <= '0';
     set_10_10         <= '0';
     set_1000_10       <= '0';
     set_10_11         <= '0';
     set_1000_11       <= '0';
     set_10_12         <= '0';
     set_1000_12       <= '0';
     set_10_13         <= '0';
     set_1000_13       <= '0';
     set_10_14         <= '0';
     set_1000_14       <= '0';
     set_10_15         <= '0';
     set_1000_15       <= '0';
     set_10_16         <= '0';
     set_1000_16       <= '0';
     set_10_17         <= '0';
     set_1000_17       <= '0';
     set_10_18         <= '0';
     set_1000_18       <= '0';
     set_10_19         <= '0';
     set_1000_19       <= '0';
 
     xon_gen_0        <= '0';
     xoff_gen_0       <= '0';
     xon_gen_1        <= '0';
     xoff_gen_1       <= '0';
     xon_gen_2        <= '0';
     xoff_gen_2       <= '0';
     xon_gen_3        <= '0';
     xoff_gen_3       <= '0';
     xon_gen_4        <= '0';
     xoff_gen_4       <= '0';
     xon_gen_5        <= '0';
     xoff_gen_5       <= '0';
     xon_gen_6        <= '0';
     xoff_gen_6       <= '0';
     xon_gen_7        <= '0';
     xoff_gen_7       <= '0';
     xon_gen_8        <= '0';
     xoff_gen_8       <= '0';
     xon_gen_9        <= '0';
     xoff_gen_9       <= '0';
     xon_gen_10        <= '0';
     xoff_gen_10       <= '0';
     xon_gen_11        <= '0';
     xoff_gen_11       <= '0';
     xon_gen_12        <= '0';
     xoff_gen_12       <= '0';
     xon_gen_13        <= '0';
     xoff_gen_13       <= '0';
     xon_gen_14        <= '0';
     xoff_gen_14       <= '0';
     xon_gen_15        <= '0';
     xoff_gen_15       <= '0';
     xon_gen_16        <= '0';
     xoff_gen_16       <= '0';
     xon_gen_17        <= '0';
     xoff_gen_17       <= '0';
     xon_gen_18        <= '0';
     xoff_gen_18       <= '0';
     xon_gen_19        <= '0';
     xoff_gen_19       <= '0';

     magic_sleep_n_0  <= magic_sleep_n;
     magic_sleep_n_1  <= magic_sleep_n;
     magic_sleep_n_2  <= magic_sleep_n;
     magic_sleep_n_3  <= magic_sleep_n;
     magic_sleep_n_4  <= magic_sleep_n;
     magic_sleep_n_5  <= magic_sleep_n;
     magic_sleep_n_6  <= magic_sleep_n;
     magic_sleep_n_7  <= magic_sleep_n;
     magic_sleep_n_8  <= magic_sleep_n;
     magic_sleep_n_9  <= magic_sleep_n;
     magic_sleep_n_10  <= magic_sleep_n;
     magic_sleep_n_11  <= magic_sleep_n;
     magic_sleep_n_12  <= magic_sleep_n;
     magic_sleep_n_13  <= magic_sleep_n;
     magic_sleep_n_14  <= magic_sleep_n;
     magic_sleep_n_15  <= magic_sleep_n;
     magic_sleep_n_16  <= magic_sleep_n;
     magic_sleep_n_17  <= magic_sleep_n;
     magic_sleep_n_18  <= magic_sleep_n;
     magic_sleep_n_19  <= magic_sleep_n;


    --output of DUT
     ff_rx_err_stat   <= pkt_class_data_19(0) & data_rx_error_19(4) & "0000000000000000" & (pkt_class_data_19(1) or pkt_class_data_19(0)) & data_rx_error_19(3 downto 0) when (pkt_class_valid_19='1') else (others => '0') ;
     ff_rx_err        <= data_rx_error_19 (0) or data_rx_error_19 (1) or data_rx_error_19(2) or data_rx_error_19(3) or data_rx_error_19(4);
     ff_rx_vlan       <= pkt_class_data_19 (1) when (pkt_class_valid_19='1') else '0' ;
     ff_rx_bcast      <= pkt_class_data_19 (2) when (pkt_class_valid_19='1') else '0' ;
     ff_rx_mcast      <= pkt_class_data_19 (3) when (pkt_class_valid_19='1') else '0' ;
     ff_rx_ucast      <= pkt_class_data_19 (4) when (pkt_class_valid_19='1') else '0' ;
     ff_tx_clk        <= mac_tx_clk_0;
     ff_rx_clk        <= mac_rx_clk_0;
     ff_tx_rdy        <= data_tx_ready_0;
     ff_rx_data       <= data_rx_data_19;
     ff_rx_dval       <= data_rx_valid_19;
     ff_rx_eop        <= data_rx_eop_19;
     ff_rx_sop        <= data_rx_sop_19;
     rx_err           <= data_rx_error_19 & ff_rx_err;
	 magic_wakeup 	  <= magic_wakeup_19;

    --loopback
     data_rx_ready_0  <= '1';--data_tx_ready_1;
     tx_crc_fwd_1     <= ff_tx_crc_fwd;
 
 
    u_ch0_2_ch1 : loopback_adapter  
    port map(
        
      -- Interface:clk                     
      clk      => mac_tx_clk_0,
      reset    => reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_0,
      in_data  => data_rx_data_0,
      in_startofpacket => data_rx_sop_0,
      in_endofpacket => data_rx_eop_0,
      in_error => data_rx_error_0,
      -- Interface:out
      out_ready => data_tx_ready_1,
      out_valid => data_tx_valid_1,
      out_data => data_tx_data_1,
      out_startofpacket => data_tx_sop_1,
      out_endofpacket => data_tx_eop_1,
      out_error => data_tx_error_1
    );
 
     data_rx_ready_1  <= '1';
     tx_crc_fwd_2     <= ff_tx_crc_fwd;
 
    u_ch1_2_ch2 : loopback_adapter 
    port map(
      -- Interface:clk                     
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_1,
      in_data=>data_rx_data_1,
      in_startofpacket=>data_rx_sop_1,
      in_endofpacket=>data_rx_eop_1,
      in_error=>data_rx_error_1,
      -- Interface:out
      out_ready=>data_tx_ready_2,
      out_valid=>data_tx_valid_2,
      out_data=>data_tx_data_2,
      out_startofpacket=>data_tx_sop_2,
      out_endofpacket=>data_tx_eop_2,
      out_error=>data_tx_error_2
    );
 
     data_rx_ready_2  <= '1';
     tx_crc_fwd_3     <= ff_tx_crc_fwd;
 
    u_ch2_2_ch3: loopback_adapter 
    port map (
      -- Interface:clk                     
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_2,
      in_data=>data_rx_data_2,
      in_startofpacket=>data_rx_sop_2,
      in_endofpacket=>data_rx_eop_2,
      in_error=>data_rx_error_2,
      -- Interface:out
      out_ready=>data_tx_ready_3,
      out_valid=>data_tx_valid_3,
      out_data=>data_tx_data_3,
      out_startofpacket=>data_tx_sop_3,
      out_endofpacket=>data_tx_eop_3,
      out_error=>data_tx_error_3
    );
 
      data_rx_ready_3  <= '1';
     tx_crc_fwd_4     <= ff_tx_crc_fwd;
 
    u_ch3_2_ch4: loopback_adapter 
    port map (
      -- Interface:clk                     
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_3,
      in_data=>data_rx_data_3,
      in_startofpacket=>data_rx_sop_3,
      in_endofpacket=>data_rx_eop_3,
      in_error=>data_rx_error_3,
      -- Interface:out
      out_ready=>data_tx_ready_4,
      out_valid=>data_tx_valid_4,
      out_data=>data_tx_data_4,
      out_startofpacket=>data_tx_sop_4,
      out_endofpacket=>data_tx_eop_4,
      out_error=>data_tx_error_4
  );
 
     data_rx_ready_4  <= '1';
     tx_crc_fwd_5     <= ff_tx_crc_fwd;
 
    u_ch4_2_ch5: loopback_adapter  
    port map (
      -- Interface:clk                     
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_4,
      in_data=>data_rx_data_4,
      in_startofpacket=>data_rx_sop_4,
      in_endofpacket=>data_rx_eop_4,
      in_error=>data_rx_error_4,
      -- Interface:out
      out_ready=>data_tx_ready_5,
      out_valid=>data_tx_valid_5,
      out_data=>data_tx_data_5,
      out_startofpacket=>data_tx_sop_5,
      out_endofpacket=>data_tx_eop_5,
      out_error=>data_tx_error_5
    );
 
     data_rx_ready_5  <= '1';
     tx_crc_fwd_6     <= ff_tx_crc_fwd;
 
    u_ch5_2_ch6: loopback_adapter  
    port map(
      -- Interface:clk                     
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_5,
      in_data=>data_rx_data_5,
      in_startofpacket=>data_rx_sop_5,
      in_endofpacket=>data_rx_eop_5,
      in_error=>data_rx_error_5,
      -- Interface:out
      out_ready=>data_tx_ready_6,
      out_valid=>data_tx_valid_6,
      out_data=>data_tx_data_6,
      out_startofpacket=>data_tx_sop_6,
      out_endofpacket=>data_tx_eop_6,
      out_error=>data_tx_error_6
    );
 
     data_rx_ready_6  <= '1';
     tx_crc_fwd_7     <= ff_tx_crc_fwd;
 
    u_ch6_2_ch7: loopback_adapter 
    port map (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_6,
      in_data=>data_rx_data_6,
      in_startofpacket=>data_rx_sop_6,
      in_endofpacket=>data_rx_eop_6,
      in_error=>data_rx_error_6,
      -- Interface:out
      out_ready=>data_tx_ready_7,
      out_valid=>data_tx_valid_7,
      out_data=>data_tx_data_7,
      out_startofpacket=>data_tx_sop_7,
      out_endofpacket=>data_tx_eop_7,
      out_error=>data_tx_error_7
    );
  
     data_rx_ready_7  <= '1';
     tx_crc_fwd_8    <= ff_tx_crc_fwd;
 
    u_ch7_2_ch8 : loopback_adapter 
    port map  (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_7,
      in_data=>data_rx_data_7,
      in_startofpacket=>data_rx_sop_7,
      in_endofpacket=>data_rx_eop_7,
      in_error=>data_rx_error_7,
      -- Interface:out
      out_ready=>data_tx_ready_8,
      out_valid=>data_tx_valid_8,
      out_data=>data_tx_data_8,
      out_startofpacket=>data_tx_sop_8,
      out_endofpacket=>data_tx_eop_8,
      out_error=>data_tx_error_8
    );
 
     data_rx_ready_8  <= '1';
     tx_crc_fwd_9     <= ff_tx_crc_fwd;
 
    u_ch8_2_ch9: loopback_adapter  
    port map(
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_8,
      in_data=>data_rx_data_8,
      in_startofpacket=>data_rx_sop_8,
      in_endofpacket=>data_rx_eop_8,
      in_error=>data_rx_error_8,
      -- Interface:out
      out_ready=>data_tx_ready_9,
      out_valid=>data_tx_valid_9,
      out_data=>data_tx_data_9,
      out_startofpacket=>data_tx_sop_9,
      out_endofpacket=>data_tx_eop_9,
      out_error=>data_tx_error_9
    );
 
     data_rx_ready_9  <= '1';
     tx_crc_fwd_10     <= ff_tx_crc_fwd;
 
    u_ch9_2_ch10: loopback_adapter
     port map  (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_9,
      in_data=>data_rx_data_9,
      in_startofpacket=>data_rx_sop_9,
      in_endofpacket=>data_rx_eop_9,
      in_error=>data_rx_error_9,
      -- Interface:out
      out_ready=>data_tx_ready_10,
      out_valid=>data_tx_valid_10,
      out_data=>data_tx_data_10,
      out_startofpacket=>data_tx_sop_10,
      out_endofpacket=>data_tx_eop_10,
      out_error=>data_tx_error_10
    );
 
     data_rx_ready_10  <= '1';
     tx_crc_fwd_11     <= ff_tx_crc_fwd;
 
    u_ch10_2_ch11 :loopback_adapter
     port map (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_10,
      in_data=>data_rx_data_10,
      in_startofpacket=>data_rx_sop_10,
      in_endofpacket=>data_rx_eop_10,
      in_error=>data_rx_error_10,
      -- Interface:out
      out_ready=>data_tx_ready_11,
      out_valid=>data_tx_valid_11,
      out_data=>data_tx_data_11,
      out_startofpacket=>data_tx_sop_11,
      out_endofpacket=>data_tx_eop_11,
      out_error=>data_tx_error_11
    ); 
    
     data_rx_ready_11  <= '1';
     tx_crc_fwd_12     <= ff_tx_crc_fwd;
 
    u_ch11_2_ch12:loopback_adapter  
    port map(
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_11,
      in_data=>data_rx_data_11,
      in_startofpacket=>data_rx_sop_11,
      in_endofpacket=>data_rx_eop_11,
      in_error=>data_rx_error_11,
      -- Interface:out
      out_ready=>data_tx_ready_12,
      out_valid=>data_tx_valid_12,
      out_data=>data_tx_data_12,
      out_startofpacket=>data_tx_sop_12,
      out_endofpacket=>data_tx_eop_12,
      out_error=>data_tx_error_12
    );
 
     data_rx_ready_12  <= '1';
     tx_crc_fwd_13     <= ff_tx_crc_fwd;
 
    u_ch12_2_ch13:loopback_adapter 
    port map (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_12,
      in_data=>data_rx_data_12,
      in_startofpacket=>data_rx_sop_12,
      in_endofpacket=>data_rx_eop_12,
      in_error=>data_rx_error_12,
      -- Interface:out
      out_ready=>data_tx_ready_13,
      out_valid=>data_tx_valid_13,
      out_data=>data_tx_data_13,
      out_startofpacket=>data_tx_sop_13,
      out_endofpacket=>data_tx_eop_13,
      out_error=>data_tx_error_13
    );
 
     data_rx_ready_13  <= '1';
     tx_crc_fwd_14     <= ff_tx_crc_fwd;
 
    u_ch13_2_ch14:loopback_adapter  
    port map(
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_13,
      in_data=>data_rx_data_13,
      in_startofpacket=>data_rx_sop_13,
      in_endofpacket=>data_rx_eop_13,
      in_error=>data_rx_error_13,
      -- Interface:out
      out_ready=>data_tx_ready_14,
      out_valid=>data_tx_valid_14,
      out_data=>data_tx_data_14,
      out_startofpacket=>data_tx_sop_14,
      out_endofpacket=>data_tx_eop_14,
      out_error=>data_tx_error_14
    );
 
     data_rx_ready_14  <= '1';
     tx_crc_fwd_15     <= ff_tx_crc_fwd;
 
    u_ch14_2_ch15:loopback_adapter 
    port map (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_14,
      in_data=>data_rx_data_14,
      in_startofpacket=>data_rx_sop_14,
      in_endofpacket=>data_rx_eop_14,
      in_error=>data_rx_error_14,
      -- Interface:out
      out_ready=>data_tx_ready_15,
      out_valid=>data_tx_valid_15,
      out_data=>data_tx_data_15,
      out_startofpacket=>data_tx_sop_15,
      out_endofpacket=>data_tx_eop_15,
      out_error=>data_tx_error_15
    );

     data_rx_ready_15  <= '1';
     tx_crc_fwd_16     <= ff_tx_crc_fwd;
 
    u_ch15_2_ch16: loopback_adapter 
    port map (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_15,
      in_data=>data_rx_data_15,
      in_startofpacket=>data_rx_sop_15,
      in_endofpacket=>data_rx_eop_15,
      in_error=>data_rx_error_15,
      -- Interface:out
      out_ready=>data_tx_ready_16,
      out_valid=>data_tx_valid_16,
      out_data=>data_tx_data_16,
      out_startofpacket=>data_tx_sop_16,
      out_endofpacket=>data_tx_eop_16,
      out_error=>data_tx_error_16
    );
 
     data_rx_ready_16  <= '1';
     tx_crc_fwd_17     <= ff_tx_crc_fwd;
 
    u_ch16_2_ch17: loopback_adapter  
    port map(
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_16,
      in_data=>data_rx_data_16,
      in_startofpacket=>data_rx_sop_16,
      in_endofpacket=>data_rx_eop_16,
      in_error=>data_rx_error_16,
      -- Interface:out
      out_ready=>data_tx_ready_17,
      out_valid=>data_tx_valid_17,
      out_data=>data_tx_data_17,
      out_startofpacket=>data_tx_sop_17,
      out_endofpacket=>data_tx_eop_17,
      out_error=>data_tx_error_17
    );
 
     data_rx_ready_17  <= '1';
     tx_crc_fwd_18     <= ff_tx_crc_fwd;
 
    u_ch17_2_ch18: loopback_adapter  
    port map (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_17,
      in_data=>data_rx_data_17,
      in_startofpacket=>data_rx_sop_17,
      in_endofpacket=>data_rx_eop_17,
      in_error=>data_rx_error_17,
      -- Interface:out
      out_ready=>data_tx_ready_18,
      out_valid=>data_tx_valid_18,
      out_data=>data_tx_data_18,
      out_startofpacket=>data_tx_sop_18,
      out_endofpacket=>data_tx_eop_18,
      out_error=>data_tx_error_18
    );
 
     data_rx_ready_18  <= '1';
     tx_crc_fwd_19     <= ff_tx_crc_fwd;
 
    u_ch18_2_ch19: loopback_adapter
    port map  (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_18,
      in_data=>data_rx_data_18,
      in_startofpacket=>data_rx_sop_18,
      in_endofpacket=>data_rx_eop_18,
      in_error=>data_rx_error_18,
      -- Interface:out
      out_ready=>data_tx_ready_19,
      out_valid=>data_tx_valid_19,
      out_data=>data_tx_data_19,
      out_startofpacket=>data_tx_sop_19,
      out_endofpacket=>data_tx_eop_19,
      out_error=>data_tx_error_19
    );
 

--assigning to GMII/MII TX monitoring
     gm_tx_data       <= gm_tx_d_0;
     gm_tx_en         <= gm_tx_en_0;
     gm_tx_err        <= gm_tx_err_0;
     m_tx_data        <= m_tx_d_0;
     m_tx_en          <= m_tx_en_0;
     m_tx_err         <= m_tx_err_0;
 
     gm_rx_d_0        <= gm_tx_d_0;
     gm_rx_dv_0       <= gm_tx_en_0;
     gm_rx_err_0      <= gm_tx_err_0;
     m_rx_d_0         <= m_tx_d_0;
     m_rx_en_0        <= m_tx_en_0;
     m_rx_err_0       <= m_tx_err_0;
     m_rx_col_0       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_0       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_0     <= tx_control_0;
     rgmii_in_0       <= rgmii_out_0;
     rxp_0       <= txp_0 ;

     gm_rx_d_1        <= gm_tx_d_1;
     gm_rx_dv_1       <= gm_tx_en_1;
     gm_rx_err_1      <= gm_tx_err_1;
     m_rx_d_1         <= m_tx_d_1;
     m_rx_en_1        <= m_tx_en_1;
     m_rx_err_1       <= m_tx_err_1;
     m_rx_col_1       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_1       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_1     <= tx_control_1;
     rgmii_in_1       <= rgmii_out_1;
     rxp_1       <= txp_1 ;
 
     gm_rx_d_2        <= gm_tx_d_2;
     gm_rx_dv_2       <= gm_tx_en_2;
     gm_rx_err_2      <= gm_tx_err_2;
     m_rx_d_2         <= m_tx_d_2;
     m_rx_en_2        <= m_tx_en_2;
     m_rx_err_2       <= m_tx_err_2;
     m_rx_col_2       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_2       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_2     <= tx_control_2;
     rgmii_in_2       <= rgmii_out_2;
     rxp_2       <= txp_2 ;
 
     gm_rx_d_3        <= gm_tx_d_3;
     gm_rx_dv_3       <= gm_tx_en_3;
     gm_rx_err_3      <= gm_tx_err_3;
     m_rx_d_3         <= m_tx_d_3;
     m_rx_en_3        <= m_tx_en_3;
     m_rx_err_3       <= m_tx_err_3;
     m_rx_col_3       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_3       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_3     <= tx_control_3;
     rgmii_in_3       <= rgmii_out_3;
     rxp_3       <= txp_3 ;

     gm_rx_d_4        <= gm_tx_d_4;
     gm_rx_dv_4       <= gm_tx_en_4;
     gm_rx_err_4      <= gm_tx_err_4;
     m_rx_d_4         <= m_tx_d_4;
     m_rx_en_4        <= m_tx_en_4;
     m_rx_err_4       <= m_tx_err_4;
     m_rx_col_4       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_4       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_4     <= tx_control_4;
     rgmii_in_4       <= rgmii_out_4;
     rxp_4       <= txp_4 ;
 
     gm_rx_d_5        <= gm_tx_d_5;
     gm_rx_dv_5       <= gm_tx_en_5;
     gm_rx_err_5      <= gm_tx_err_5;
     m_rx_d_5         <= m_tx_d_5;
     m_rx_en_5        <= m_tx_en_5;
     m_rx_err_5       <= m_tx_err_5;
     m_rx_col_5       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_5       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_5     <= tx_control_5;
     rgmii_in_5       <= rgmii_out_5;
     rxp_5       <= txp_5 ;
 
     gm_rx_d_6        <= gm_tx_d_6;
     gm_rx_dv_6       <= gm_tx_en_6;
     gm_rx_err_6      <= gm_tx_err_6;
     m_rx_d_6         <= m_tx_d_6;
     m_rx_en_6        <= m_tx_en_6;
     m_rx_err_6       <= m_tx_err_6;
     m_rx_col_6       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_6       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_6     <= tx_control_6;
     rgmii_in_6       <= rgmii_out_6;
     rxp_6       <= txp_6 ;
 
     gm_rx_d_7        <= gm_tx_d_7;
     gm_rx_dv_7       <= gm_tx_en_7;
     gm_rx_err_7      <= gm_tx_err_7;
     m_rx_d_7         <= m_tx_d_7;
     m_rx_en_7        <= m_tx_en_7;
     m_rx_err_7       <= m_tx_err_7;
     m_rx_col_7       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_7       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_7     <= tx_control_7;
     rgmii_in_7       <= rgmii_out_7;
     rxp_7       <= txp_7 ;

     gm_rx_d_8        <= gm_tx_d_8;
     gm_rx_dv_8       <= gm_tx_en_8;
     gm_rx_err_8      <= gm_tx_err_8;
     m_rx_d_8         <= m_tx_d_8;
     m_rx_en_8        <= m_tx_en_8;
     m_rx_err_8       <= m_tx_err_8;
     m_rx_col_8       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_8       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_8     <= tx_control_8;
     rgmii_in_8       <= rgmii_out_8;
     rxp_8       <= txp_8 ;
 
     gm_rx_d_9        <= gm_tx_d_9;
     gm_rx_dv_9       <= gm_tx_en_9;
     gm_rx_err_9      <= gm_tx_err_9;
     m_rx_d_9         <= m_tx_d_9;
     m_rx_en_9        <= m_tx_en_9;
     m_rx_err_9       <= m_tx_err_9;
     m_rx_col_9       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_9       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_9     <= tx_control_9;
     rgmii_in_9       <= rgmii_out_9;
     rxp_9       <= txp_9 ;
 
     gm_rx_d_10        <= gm_tx_d_10;
     gm_rx_dv_10       <= gm_tx_en_10;
     gm_rx_err_10      <= gm_tx_err_10;
     m_rx_d_10         <= m_tx_d_10;
     m_rx_en_10        <= m_tx_en_10;
     m_rx_err_10       <= m_tx_err_10;
     m_rx_col_10       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_10       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_10     <= tx_control_10;
     rgmii_in_10       <= rgmii_out_10;
     rxp_10       <= txp_10 ;
 
     gm_rx_d_11        <= gm_tx_d_11;
     gm_rx_dv_11       <= gm_tx_en_11;
     gm_rx_err_11      <= gm_tx_err_11;
     m_rx_d_11         <= m_tx_d_11;
     m_rx_en_11        <= m_tx_en_11;
     m_rx_err_11       <= m_tx_err_11;
     m_rx_col_11       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_11       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_11     <= tx_control_11;
     rgmii_in_11       <= rgmii_out_11;
     rxp_11       <= txp_11 ;

     gm_rx_d_12        <= gm_tx_d_12;
     gm_rx_dv_12       <= gm_tx_en_12;
     gm_rx_err_12      <= gm_tx_err_12;
     m_rx_d_12         <= m_tx_d_12;
     m_rx_en_12        <= m_tx_en_12;
     m_rx_err_12       <= m_tx_err_12;
     m_rx_col_12       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_12       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_12     <= tx_control_12;
     rgmii_in_12       <= rgmii_out_12;
     rxp_12       <= txp_12 ;
 
     gm_rx_d_13        <= gm_tx_d_13;
     gm_rx_dv_13       <= gm_tx_en_13;
     gm_rx_err_13      <= gm_tx_err_13;
     m_rx_d_13         <= m_tx_d_13;
     m_rx_en_13        <= m_tx_en_13;
     m_rx_err_13       <= m_tx_err_13;
     m_rx_col_13       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_13       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_13     <= tx_control_13;
     rgmii_in_13       <= rgmii_out_13;
     rxp_13       <= txp_13 ;
 
     gm_rx_d_14        <= gm_tx_d_14;
     gm_rx_dv_14       <= gm_tx_en_14;
     gm_rx_err_14      <= gm_tx_err_14;
     m_rx_d_14         <= m_tx_d_14;
     m_rx_en_14        <= m_tx_en_14;
     m_rx_err_14       <= m_tx_err_14;
     m_rx_col_14       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_14       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_14     <= tx_control_14;
     rgmii_in_14       <= rgmii_out_14;
     rxp_14       <= txp_14 ;
 
     gm_rx_d_15        <= gm_tx_d_15;
     gm_rx_dv_15       <= gm_tx_en_15;
     gm_rx_err_15      <= gm_tx_err_15;
     m_rx_d_15         <= m_tx_d_15;
     m_rx_en_15        <= m_tx_en_15;
     m_rx_err_15       <= m_tx_err_15;
     m_rx_col_15       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_15       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_15     <= tx_control_15;
     rgmii_in_15       <= rgmii_out_15;
     rxp_15       <= txp_15 ;

     gm_rx_d_16        <= gm_tx_d_16;
     gm_rx_dv_16       <= gm_tx_en_16;
     gm_rx_err_16      <= gm_tx_err_16;
     m_rx_d_16         <= m_tx_d_16;
     m_rx_en_16        <= m_tx_en_16;
     m_rx_err_16       <= m_tx_err_16;
     m_rx_col_16       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_16       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_16     <= tx_control_16;
     rgmii_in_16       <= rgmii_out_16;
     rxp_16       <= txp_16 ;
 
     gm_rx_d_17        <= gm_tx_d_17;
     gm_rx_dv_17       <= gm_tx_en_17;
     gm_rx_err_17      <= gm_tx_err_17;
     m_rx_d_17         <= m_tx_d_17;
     m_rx_en_17        <= m_tx_en_17;
     m_rx_err_17       <= m_tx_err_17;
     m_rx_col_17       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_17       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_17     <= tx_control_17;
     rgmii_in_17       <= rgmii_out_17;
     rxp_17       <= txp_17 ;
 
     gm_rx_d_18        <= gm_tx_d_18;
     gm_rx_dv_18       <= gm_tx_en_18;
     gm_rx_err_18      <= gm_tx_err_18;
     m_rx_d_18         <= m_tx_d_18;
     m_rx_en_18        <= m_tx_en_18;
     m_rx_err_18       <= m_tx_err_18;
     m_rx_col_18       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_18       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_18     <= tx_control_18;
     rgmii_in_18       <= rgmii_out_18;
     rxp_18       <= txp_18 ;
 
     gm_rx_d_19        <= gm_tx_d_19;
     gm_rx_dv_19       <= gm_tx_en_19;
     gm_rx_err_19      <= gm_tx_err_19;
     m_rx_d_19         <= m_tx_d_19;
     m_rx_en_19        <= m_tx_en_19;
     m_rx_err_19       <= m_tx_err_19;
     m_rx_col_19       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_19       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_19     <= tx_control_19;
     rgmii_in_19       <= rgmii_out_19;
     rxp_19       <= txp_19 ;

  end generate;
  
   
  TwentyfourPort_DUT_without_FIFO: if (MAX_CHANNELS = 24) generate
   begin
     -- NightFury PHYIP signals
     tx_cal_busy        <= tx_cal_busy_0 or tx_cal_busy_1 or tx_cal_busy_2 or tx_cal_busy_3 or
                           tx_cal_busy_4 or tx_cal_busy_5 or tx_cal_busy_6 or tx_cal_busy_7 or
                           tx_cal_busy_8 or tx_cal_busy_9 or tx_cal_busy_10 or tx_cal_busy_11 or
                           tx_cal_busy_12 or tx_cal_busy_13 or tx_cal_busy_14 or tx_cal_busy_15 or
                           tx_cal_busy_16 or tx_cal_busy_17 or tx_cal_busy_18 or tx_cal_busy_19 or
                           tx_cal_busy_20 or tx_cal_busy_21 or tx_cal_busy_22 or tx_cal_busy_23;
     rx_is_lockedtodata <= rx_is_lockedtodata_0 and rx_is_lockedtodata_1 and rx_is_lockedtodata_2 and rx_is_lockedtodata_3 and
                           rx_is_lockedtodata_4 and rx_is_lockedtodata_5 and rx_is_lockedtodata_6 and rx_is_lockedtodata_7 and
                           rx_is_lockedtodata_8 and rx_is_lockedtodata_9 and rx_is_lockedtodata_10 and rx_is_lockedtodata_11 and
                           rx_is_lockedtodata_12 and rx_is_lockedtodata_13 and rx_is_lockedtodata_14 and rx_is_lockedtodata_15 and
                           rx_is_lockedtodata_16 and rx_is_lockedtodata_17 and rx_is_lockedtodata_18 and rx_is_lockedtodata_19 and
                           rx_is_lockedtodata_20 and rx_is_lockedtodata_21 and rx_is_lockedtodata_22 and rx_is_lockedtodata_23;
     rx_cal_busy        <= rx_cal_busy_0 or rx_cal_busy_1 or rx_cal_busy_2 or rx_cal_busy_3 or
                           rx_cal_busy_4 or rx_cal_busy_5 or rx_cal_busy_6 or rx_cal_busy_7 or
                           rx_cal_busy_8 or rx_cal_busy_9 or rx_cal_busy_10 or rx_cal_busy_11 or
                           rx_cal_busy_12 or rx_cal_busy_13 or rx_cal_busy_14 or rx_cal_busy_15 or
                           rx_cal_busy_16 or rx_cal_busy_17 or rx_cal_busy_18 or rx_cal_busy_19 or
                           rx_cal_busy_20 or rx_cal_busy_21 or rx_cal_busy_22 or rx_cal_busy_23;

     led_link         <= led_link_0;
    --input of DUT
     ff_rx_dsav       <= '0'; 
     rx_afull_clk     <= rx_clk;
     rx_afull_channel <= (others => '0');
     rx_afull_data    <= "00";
     rx_afull_valid   <= '1' ;
     data_tx_data_0   <= ff_tx_data;
     data_tx_eop_0    <= ff_tx_eop;
     data_tx_error_0  <= ff_tx_err;
     data_tx_sop_0    <= ff_tx_sop;
     data_tx_valid_0  <= ff_tx_wren;
     tx_crc_fwd_0     <= ff_tx_crc_fwd;
     data_rx_ready_23  <= ff_rx_rdy;
     tbi_tx_clk_0     <= tx_clk_1000mbps;
     tbi_rx_clk_0     <= rx_clk_1000mbps;
     tbi_tx_clk_1     <= tx_clk_1000mbps;
     tbi_rx_clk_1     <= rx_clk_1000mbps;
     tbi_tx_clk_2     <= tx_clk_1000mbps;
     tbi_rx_clk_2     <= rx_clk_1000mbps;
     tbi_tx_clk_3     <= tx_clk_1000mbps;
     tbi_rx_clk_3     <= rx_clk_1000mbps;
     tbi_tx_clk_4     <= tx_clk_1000mbps;
     tbi_rx_clk_4     <= rx_clk_1000mbps;
     tbi_tx_clk_5     <= tx_clk_1000mbps;
     tbi_rx_clk_5     <= rx_clk_1000mbps;
     tbi_tx_clk_6     <= tx_clk_1000mbps;
     tbi_rx_clk_6     <= rx_clk_1000mbps;
     tbi_tx_clk_7     <= tx_clk_1000mbps;
     tbi_rx_clk_7     <= rx_clk_1000mbps;
     tbi_tx_clk_8     <= tx_clk_1000mbps;
     tbi_rx_clk_8     <= rx_clk_1000mbps;
     tbi_tx_clk_9     <= tx_clk_1000mbps;
     tbi_rx_clk_9     <= rx_clk_1000mbps;
     tbi_tx_clk_10     <= tx_clk_1000mbps;
     tbi_rx_clk_10     <= rx_clk_1000mbps;
     tbi_tx_clk_11     <= tx_clk_1000mbps;
     tbi_rx_clk_11     <= rx_clk_1000mbps;
     tbi_tx_clk_12     <= tx_clk_1000mbps;
     tbi_rx_clk_12     <= rx_clk_1000mbps;
     tbi_tx_clk_13     <= tx_clk_1000mbps;
     tbi_rx_clk_13     <= rx_clk_1000mbps;
     tbi_tx_clk_14     <= tx_clk_1000mbps;
     tbi_rx_clk_14     <= rx_clk_1000mbps;
     tbi_tx_clk_15     <= tx_clk_1000mbps;
     tbi_rx_clk_15     <= rx_clk_1000mbps;
     tbi_tx_clk_16     <= tx_clk_1000mbps;
     tbi_rx_clk_16     <= rx_clk_1000mbps;
     tbi_tx_clk_17     <= tx_clk_1000mbps;
     tbi_rx_clk_17     <= rx_clk_1000mbps;
     tbi_tx_clk_18     <= tx_clk_1000mbps;
     tbi_rx_clk_18     <= rx_clk_1000mbps;
     tbi_tx_clk_19     <= tx_clk_1000mbps;
     tbi_rx_clk_19     <= rx_clk_1000mbps;
     tbi_tx_clk_20     <= tx_clk_1000mbps;
     tbi_rx_clk_20     <= rx_clk_1000mbps;
     tbi_tx_clk_21     <= tx_clk_1000mbps;
     tbi_rx_clk_21     <= rx_clk_1000mbps;
     tbi_tx_clk_22     <= tx_clk_1000mbps;
     tbi_rx_clk_22     <= rx_clk_1000mbps;
     tbi_tx_clk_23     <= tx_clk_1000mbps;
     tbi_rx_clk_23     <= rx_clk_1000mbps;
     set_10_0         <= '0';
     set_1000_0       <= '0';
     set_10_1         <= '0';
     set_1000_1       <= '0';
     set_10_2         <= '0';
     set_1000_2       <= '0';
     set_10_3         <= '0';
     set_1000_3       <= '0';
     set_10_4         <= '0';
     set_1000_4       <= '0';
     set_10_4         <= '0';
     set_1000_4       <= '0';
     set_10_5         <= '0';
     set_1000_5       <= '0';
     set_10_6         <= '0';
     set_1000_6       <= '0';
     set_10_7         <= '0';
     set_1000_7       <= '0';
     set_10_8         <= '0';
     set_1000_8       <= '0';
     set_10_9         <= '0';
     set_1000_9       <= '0';
     set_10_10         <= '0';
     set_1000_10       <= '0';
     set_10_11         <= '0';
     set_1000_11       <= '0';
     set_10_12         <= '0';
     set_1000_12       <= '0';
     set_10_13         <= '0';
     set_1000_13       <= '0';
     set_10_14         <= '0';
     set_1000_14       <= '0';
     set_10_15         <= '0';
     set_1000_15       <= '0';
     set_10_16         <= '0';
     set_1000_16       <= '0';
     set_10_17         <= '0';
     set_1000_17       <= '0';
     set_10_18         <= '0';
     set_1000_18       <= '0';
     set_10_19         <= '0';
     set_1000_19       <= '0';
     set_10_20         <= '0';
     set_1000_20       <= '0';
     set_10_21         <= '0';
     set_1000_21       <= '0';
     set_10_22         <= '0';
     set_1000_22       <= '0';
     set_10_23         <= '0';
     set_1000_23       <= '0';
 
     xon_gen_0        <= '0';
     xoff_gen_0       <= '0';
     xon_gen_1        <= '0';
     xoff_gen_1       <= '0';
     xon_gen_2        <= '0';
     xoff_gen_2       <= '0';
     xon_gen_3        <= '0';
     xoff_gen_3       <= '0';
     xon_gen_4        <= '0';
     xoff_gen_4       <= '0';
     xon_gen_5        <= '0';
     xoff_gen_5       <= '0';
     xon_gen_6        <= '0';
     xoff_gen_6       <= '0';
     xon_gen_7        <= '0';
     xoff_gen_7       <= '0';
     xon_gen_8        <= '0';
     xoff_gen_8       <= '0';
     xon_gen_9        <= '0';
     xoff_gen_9       <= '0';
     xon_gen_10        <= '0';
     xoff_gen_10       <= '0';
     xon_gen_11        <= '0';
     xoff_gen_11       <= '0';
     xon_gen_12        <= '0';
     xoff_gen_12       <= '0';
     xon_gen_13        <= '0';
     xoff_gen_13       <= '0';
     xon_gen_14        <= '0';
     xoff_gen_14       <= '0';
     xon_gen_15        <= '0';
     xoff_gen_15       <= '0';
     xon_gen_16        <= '0';
     xoff_gen_16       <= '0';
     xon_gen_17        <= '0';
     xoff_gen_17       <= '0';
     xon_gen_18        <= '0';
     xoff_gen_18       <= '0';
     xon_gen_19        <= '0';
     xoff_gen_19       <= '0';
     xon_gen_20        <= '0';
     xoff_gen_20       <= '0';
     xon_gen_21        <= '0';
     xoff_gen_21       <= '0';
     xon_gen_22        <= '0';
     xoff_gen_22       <= '0';
     xon_gen_23        <= '0';
     xoff_gen_23       <= '0';

     magic_sleep_n_0  <= magic_sleep_n;
     magic_sleep_n_1  <= magic_sleep_n;
     magic_sleep_n_2  <= magic_sleep_n;
     magic_sleep_n_3  <= magic_sleep_n;
     magic_sleep_n_4  <= magic_sleep_n;
     magic_sleep_n_5  <= magic_sleep_n;
     magic_sleep_n_6  <= magic_sleep_n;
     magic_sleep_n_7  <= magic_sleep_n;
     magic_sleep_n_8  <= magic_sleep_n;
     magic_sleep_n_9  <= magic_sleep_n;
     magic_sleep_n_10  <= magic_sleep_n;
     magic_sleep_n_11  <= magic_sleep_n;
     magic_sleep_n_12  <= magic_sleep_n;
     magic_sleep_n_13  <= magic_sleep_n;
     magic_sleep_n_14  <= magic_sleep_n;
     magic_sleep_n_15  <= magic_sleep_n;
     magic_sleep_n_16  <= magic_sleep_n;
     magic_sleep_n_17  <= magic_sleep_n;
     magic_sleep_n_18  <= magic_sleep_n;
     magic_sleep_n_19  <= magic_sleep_n;
     magic_sleep_n_20  <= magic_sleep_n;
     magic_sleep_n_21  <= magic_sleep_n;
     magic_sleep_n_22  <= magic_sleep_n;
     magic_sleep_n_23  <= magic_sleep_n;


    --output of DUT
     ff_rx_err_stat   <= pkt_class_data_23(0) & data_rx_error_23(4) & "0000000000000000" & (pkt_class_data_23(1) or pkt_class_data_23(0)) & data_rx_error_23(3 downto 0) when (pkt_class_valid_23='1') else (others => '0') ;
     ff_rx_err        <= data_rx_error_23 (0) or data_rx_error_23 (1) or data_rx_error_23(2) or data_rx_error_23(3) or data_rx_error_23(4);
     ff_rx_vlan       <= pkt_class_data_23(1) when (pkt_class_valid_23='1') else '0' ;
     ff_rx_bcast      <= pkt_class_data_23(2) when (pkt_class_valid_23='1') else '0' ;
     ff_rx_mcast      <= pkt_class_data_23(3) when (pkt_class_valid_23='1') else '0' ;
     ff_rx_ucast      <= pkt_class_data_23(4) when (pkt_class_valid_23='1') else '0' ;
     ff_tx_clk        <= mac_tx_clk_0;
     ff_rx_clk        <= mac_rx_clk_0;
     ff_tx_rdy        <= data_tx_ready_0;
     ff_rx_data       <= data_rx_data_23;
     ff_rx_dval       <= data_rx_valid_23;
     ff_rx_eop        <= data_rx_eop_23;
     ff_rx_sop        <= data_rx_sop_23;
     rx_err           <= data_rx_error_23 & ff_rx_err;
	 magic_wakeup 	  <= magic_wakeup_23;

    --loopback
     data_rx_ready_0  <= '1';--data_tx_ready_1;
     tx_crc_fwd_1     <= ff_tx_crc_fwd;
 
 
    u_ch0_2_ch1 : loopback_adapter  
    port map(
        
      -- Interface:clk                     
      clk      => mac_tx_clk_0,
      reset    => reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_0,
      in_data  => data_rx_data_0,
      in_startofpacket => data_rx_sop_0,
      in_endofpacket => data_rx_eop_0,
      in_error => data_rx_error_0,
      -- Interface:out
      out_ready => data_tx_ready_1,
      out_valid => data_tx_valid_1,
      out_data => data_tx_data_1,
      out_startofpacket => data_tx_sop_1,
      out_endofpacket => data_tx_eop_1,
      out_error => data_tx_error_1
    );
 
     data_rx_ready_1  <= '1';
     tx_crc_fwd_2     <= ff_tx_crc_fwd;
 
    u_ch1_2_ch2 : loopback_adapter 
    port map(
      -- Interface:clk                     
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_1,
      in_data=>data_rx_data_1,
      in_startofpacket=>data_rx_sop_1,
      in_endofpacket=>data_rx_eop_1,
      in_error=>data_rx_error_1,
      -- Interface:out
      out_ready=>data_tx_ready_2,
      out_valid=>data_tx_valid_2,
      out_data=>data_tx_data_2,
      out_startofpacket=>data_tx_sop_2,
      out_endofpacket=>data_tx_eop_2,
      out_error=>data_tx_error_2
    );
 
     data_rx_ready_2  <= '1';
     tx_crc_fwd_3     <= ff_tx_crc_fwd;
 
    u_ch2_2_ch3: loopback_adapter 
    port map (
      -- Interface:clk                     
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_2,
      in_data=>data_rx_data_2,
      in_startofpacket=>data_rx_sop_2,
      in_endofpacket=>data_rx_eop_2,
      in_error=>data_rx_error_2,
      -- Interface:out
      out_ready=>data_tx_ready_3,
      out_valid=>data_tx_valid_3,
      out_data=>data_tx_data_3,
      out_startofpacket=>data_tx_sop_3,
      out_endofpacket=>data_tx_eop_3,
      out_error=>data_tx_error_3
    );
 
      data_rx_ready_3  <= '1';
     tx_crc_fwd_4     <= ff_tx_crc_fwd;
 
    u_ch3_2_ch4: loopback_adapter 
    port map (
      -- Interface:clk                     
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_3,
      in_data=>data_rx_data_3,
      in_startofpacket=>data_rx_sop_3,
      in_endofpacket=>data_rx_eop_3,
      in_error=>data_rx_error_3,
      -- Interface:out
      out_ready=>data_tx_ready_4,
      out_valid=>data_tx_valid_4,
      out_data=>data_tx_data_4,
      out_startofpacket=>data_tx_sop_4,
      out_endofpacket=>data_tx_eop_4,
      out_error=>data_tx_error_4
  );
 
     data_rx_ready_4  <= '1';
     tx_crc_fwd_5     <= ff_tx_crc_fwd;
 
    u_ch4_2_ch5: loopback_adapter  
    port map (
      -- Interface:clk                     
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_4,
      in_data=>data_rx_data_4,
      in_startofpacket=>data_rx_sop_4,
      in_endofpacket=>data_rx_eop_4,
      in_error=>data_rx_error_4,
      -- Interface:out
      out_ready=>data_tx_ready_5,
      out_valid=>data_tx_valid_5,
      out_data=>data_tx_data_5,
      out_startofpacket=>data_tx_sop_5,
      out_endofpacket=>data_tx_eop_5,
      out_error=>data_tx_error_5
    );
 
     data_rx_ready_5  <= '1';
     tx_crc_fwd_6     <= ff_tx_crc_fwd;
 
    u_ch5_2_ch6: loopback_adapter  
    port map(
      -- Interface:clk                     
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_5,
      in_data=>data_rx_data_5,
      in_startofpacket=>data_rx_sop_5,
      in_endofpacket=>data_rx_eop_5,
      in_error=>data_rx_error_5,
      -- Interface:out
      out_ready=>data_tx_ready_6,
      out_valid=>data_tx_valid_6,
      out_data=>data_tx_data_6,
      out_startofpacket=>data_tx_sop_6,
      out_endofpacket=>data_tx_eop_6,
      out_error=>data_tx_error_6
    );
 
     data_rx_ready_6  <= '1';
     tx_crc_fwd_7     <= ff_tx_crc_fwd;
 
    u_ch6_2_ch7: loopback_adapter 
    port map (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_6,
      in_data=>data_rx_data_6,
      in_startofpacket=>data_rx_sop_6,
      in_endofpacket=>data_rx_eop_6,
      in_error=>data_rx_error_6,
      -- Interface:out
      out_ready=>data_tx_ready_7,
      out_valid=>data_tx_valid_7,
      out_data=>data_tx_data_7,
      out_startofpacket=>data_tx_sop_7,
      out_endofpacket=>data_tx_eop_7,
      out_error=>data_tx_error_7
    );
  
     data_rx_ready_7  <= '1';
     tx_crc_fwd_8    <= ff_tx_crc_fwd;
 
    u_ch7_2_ch8 : loopback_adapter 
    port map  (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_7,
      in_data=>data_rx_data_7,
      in_startofpacket=>data_rx_sop_7,
      in_endofpacket=>data_rx_eop_7,
      in_error=>data_rx_error_7,
      -- Interface:out
      out_ready=>data_tx_ready_8,
      out_valid=>data_tx_valid_8,
      out_data=>data_tx_data_8,
      out_startofpacket=>data_tx_sop_8,
      out_endofpacket=>data_tx_eop_8,
      out_error=>data_tx_error_8
    );
 
     data_rx_ready_8  <= '1';
     tx_crc_fwd_9     <= ff_tx_crc_fwd;
 
    u_ch8_2_ch9: loopback_adapter  
    port map(
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_8,
      in_data=>data_rx_data_8,
      in_startofpacket=>data_rx_sop_8,
      in_endofpacket=>data_rx_eop_8,
      in_error=>data_rx_error_8,
      -- Interface:out
      out_ready=>data_tx_ready_9,
      out_valid=>data_tx_valid_9,
      out_data=>data_tx_data_9,
      out_startofpacket=>data_tx_sop_9,
      out_endofpacket=>data_tx_eop_9,
      out_error=>data_tx_error_9
    );
 
     data_rx_ready_9  <= '1';
     tx_crc_fwd_10     <= ff_tx_crc_fwd;
 
    u_ch9_2_ch10: loopback_adapter
     port map  (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_9,
      in_data=>data_rx_data_9,
      in_startofpacket=>data_rx_sop_9,
      in_endofpacket=>data_rx_eop_9,
      in_error=>data_rx_error_9,
      -- Interface:out
      out_ready=>data_tx_ready_10,
      out_valid=>data_tx_valid_10,
      out_data=>data_tx_data_10,
      out_startofpacket=>data_tx_sop_10,
      out_endofpacket=>data_tx_eop_10,
      out_error=>data_tx_error_10
    );
 
     data_rx_ready_10  <= '1';
     tx_crc_fwd_11     <= ff_tx_crc_fwd;
 
    u_ch10_2_ch11 :loopback_adapter
     port map (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_10,
      in_data=>data_rx_data_10,
      in_startofpacket=>data_rx_sop_10,
      in_endofpacket=>data_rx_eop_10,
      in_error=>data_rx_error_10,
      -- Interface:out
      out_ready=>data_tx_ready_11,
      out_valid=>data_tx_valid_11,
      out_data=>data_tx_data_11,
      out_startofpacket=>data_tx_sop_11,
      out_endofpacket=>data_tx_eop_11,
      out_error=>data_tx_error_11
    ); 
    
     data_rx_ready_11  <= '1';
     tx_crc_fwd_12     <= ff_tx_crc_fwd;

    u_ch11_2_ch12:loopback_adapter  
    port map(
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_11,
      in_data=>data_rx_data_11,
      in_startofpacket=>data_rx_sop_11,
      in_endofpacket=>data_rx_eop_11,
      in_error=>data_rx_error_11,
      -- Interface:out
      out_ready=>data_tx_ready_12,
      out_valid=>data_tx_valid_12,
      out_data=>data_tx_data_12,
      out_startofpacket=>data_tx_sop_12,
      out_endofpacket=>data_tx_eop_12,
      out_error=>data_tx_error_12
    );
 
     data_rx_ready_12  <= '1';
     tx_crc_fwd_13     <= ff_tx_crc_fwd;
 
    u_ch12_2_ch13:loopback_adapter 
    port map (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_12,
      in_data=>data_rx_data_12,
      in_startofpacket=>data_rx_sop_12,
      in_endofpacket=>data_rx_eop_12,
      in_error=>data_rx_error_12,
      -- Interface:out
      out_ready=>data_tx_ready_13,
      out_valid=>data_tx_valid_13,
      out_data=>data_tx_data_13,
      out_startofpacket=>data_tx_sop_13,
      out_endofpacket=>data_tx_eop_13,
      out_error=>data_tx_error_13
    );
 
     data_rx_ready_13  <= '1';
     tx_crc_fwd_14     <= ff_tx_crc_fwd;
 
    u_ch13_2_ch14:loopback_adapter  
    port map(
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_13,
      in_data=>data_rx_data_13,
      in_startofpacket=>data_rx_sop_13,
      in_endofpacket=>data_rx_eop_13,
      in_error=>data_rx_error_13,
      -- Interface:out
      out_ready=>data_tx_ready_14,
      out_valid=>data_tx_valid_14,
      out_data=>data_tx_data_14,
      out_startofpacket=>data_tx_sop_14,
      out_endofpacket=>data_tx_eop_14,
      out_error=>data_tx_error_14
    );
 
     data_rx_ready_14  <= '1';
     tx_crc_fwd_15     <= ff_tx_crc_fwd;
 
    u_ch14_2_ch15:loopback_adapter 
    port map (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_14,
      in_data=>data_rx_data_14,
      in_startofpacket=>data_rx_sop_14,
      in_endofpacket=>data_rx_eop_14,
      in_error=>data_rx_error_14,
      -- Interface:out
      out_ready=>data_tx_ready_15,
      out_valid=>data_tx_valid_15,
      out_data=>data_tx_data_15,
      out_startofpacket=>data_tx_sop_15,
      out_endofpacket=>data_tx_eop_15,
      out_error=>data_tx_error_15
    );

     data_rx_ready_15  <= '1';
     tx_crc_fwd_16     <= ff_tx_crc_fwd;
 
    u_ch15_2_ch16: loopback_adapter 
    port map (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_15,
      in_data=>data_rx_data_15,
      in_startofpacket=>data_rx_sop_15,
      in_endofpacket=>data_rx_eop_15,
      in_error=>data_rx_error_15,
      -- Interface:out
      out_ready=>data_tx_ready_16,
      out_valid=>data_tx_valid_16,
      out_data=>data_tx_data_16,
      out_startofpacket=>data_tx_sop_16,
      out_endofpacket=>data_tx_eop_16,
      out_error=>data_tx_error_16
    );
 
     data_rx_ready_16  <= '1';
     tx_crc_fwd_17     <= ff_tx_crc_fwd;
 
    u_ch16_2_ch17: loopback_adapter  
    port map(
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_16,
      in_data=>data_rx_data_16,
      in_startofpacket=>data_rx_sop_16,
      in_endofpacket=>data_rx_eop_16,
      in_error=>data_rx_error_16,
      -- Interface:out
      out_ready=>data_tx_ready_17,
      out_valid=>data_tx_valid_17,
      out_data=>data_tx_data_17,
      out_startofpacket=>data_tx_sop_17,
      out_endofpacket=>data_tx_eop_17,
      out_error=>data_tx_error_17
    );
 
     data_rx_ready_17  <= '1';
     tx_crc_fwd_18     <= ff_tx_crc_fwd;

    u_ch17_2_ch18: loopback_adapter  
    port map (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_17,
      in_data=>data_rx_data_17,
      in_startofpacket=>data_rx_sop_17,
      in_endofpacket=>data_rx_eop_17,
      in_error=>data_rx_error_17,
      -- Interface:out
      out_ready=>data_tx_ready_18,
      out_valid=>data_tx_valid_18,
      out_data=>data_tx_data_18,
      out_startofpacket=>data_tx_sop_18,
      out_endofpacket=>data_tx_eop_18,
      out_error=>data_tx_error_18
    );
 
     data_rx_ready_18  <= '1';
     tx_crc_fwd_19     <= ff_tx_crc_fwd;
 
    u_ch18_2_ch19: loopback_adapter
    port map  (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_18,
      in_data=>data_rx_data_18,
      in_startofpacket=>data_rx_sop_18,
      in_endofpacket=>data_rx_eop_18,
      in_error=>data_rx_error_18,
      -- Interface:out
      out_ready=>data_tx_ready_19,
      out_valid=>data_tx_valid_19,
      out_data=>data_tx_data_19,
      out_startofpacket=>data_tx_sop_19,
      out_endofpacket=>data_tx_eop_19,
      out_error=>data_tx_error_19
    );
 
     data_rx_ready_19  <= '1';
     tx_crc_fwd_20     <= ff_tx_crc_fwd;
 
    u_ch19_2_ch20: loopback_adapter 
    port map (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_19,
      in_data=>data_rx_data_19,
      in_startofpacket=>data_rx_sop_19,
      in_endofpacket=>data_rx_eop_19,
      in_error=>data_rx_error_19,
      -- Interface:out
      out_ready=>data_tx_ready_20,
      out_valid=>data_tx_valid_20,
      out_data=>data_tx_data_20,
      out_startofpacket=>data_tx_sop_20,
      out_endofpacket=>data_tx_eop_20,
      out_error=>data_tx_error_20
    );
 
     data_rx_ready_20  <= '1';
     tx_crc_fwd_21     <= ff_tx_crc_fwd;
 
    u_ch20_2_ch21: loopback_adapter 
    port map (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_20,
      in_data=>data_rx_data_20,
      in_startofpacket=>data_rx_sop_20,
      in_endofpacket=>data_rx_eop_20,
      in_error=>data_rx_error_20,
      -- Interface:out
      out_ready=>data_tx_ready_21,
      out_valid=>data_tx_valid_21,
      out_data=>data_tx_data_21,
      out_startofpacket=>data_tx_sop_21,
      out_endofpacket=>data_tx_eop_21,
      out_error=>data_tx_error_21
    );
 
     data_rx_ready_21  <= '1';
     tx_crc_fwd_22     <= ff_tx_crc_fwd;
 
    u_ch21_2_ch22: loopback_adapter 
    port map (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_21,
      in_data=>data_rx_data_21,
      in_startofpacket=>data_rx_sop_21,
      in_endofpacket=>data_rx_eop_21,
      in_error=>data_rx_error_21,
      -- Interface:out
      out_ready=>data_tx_ready_22,
      out_valid=>data_tx_valid_22,
      out_data=>data_tx_data_22,
      out_startofpacket=>data_tx_sop_22,
      out_endofpacket=>data_tx_eop_22,
      out_error=>data_tx_error_22
    );
 
     data_rx_ready_22  <= '1';
     tx_crc_fwd_23     <= ff_tx_crc_fwd;
 
    u_ch22_2_ch23: loopback_adapter 
    port map (
      clk=>mac_tx_clk_0,
      reset =>reset,
      -- Interface:in
      in_ready => open,
      in_valid => data_rx_valid_22,
      in_data=>data_rx_data_22,
      in_startofpacket=>data_rx_sop_22,
      in_endofpacket=>data_rx_eop_22,
      in_error=>data_rx_error_22,
      -- Interface:out
      out_ready=>data_tx_ready_23,
      out_valid=>data_tx_valid_23,
      out_data=>data_tx_data_23,
      out_startofpacket=>data_tx_sop_23,
      out_endofpacket=>data_tx_eop_23,
      out_error=>data_tx_error_23
    );
 


--assigning to GMII/MII TX monitoring
     gm_tx_data       <= gm_tx_d_0;
     gm_tx_en         <= gm_tx_en_0;
     gm_tx_err        <= gm_tx_err_0;
     m_tx_data        <= m_tx_d_0;
     m_tx_en          <= m_tx_en_0;
     m_tx_err         <= m_tx_err_0;

 
     gm_rx_d_0        <= gm_tx_d_0;
     gm_rx_dv_0       <= gm_tx_en_0;
     gm_rx_err_0      <= gm_tx_err_0;
     m_rx_d_0         <= m_tx_d_0;
     m_rx_en_0        <= m_tx_en_0;
     m_rx_err_0       <= m_tx_err_0;
     m_rx_col_0       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_0       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_0     <= tx_control_0;
     rgmii_in_0       <= rgmii_out_0;
     rxp_0       <= txp_0 ;
 
     gm_rx_d_1        <= gm_tx_d_1;
     gm_rx_dv_1       <= gm_tx_en_1;
     gm_rx_err_1      <= gm_tx_err_1;
     m_rx_d_1         <= m_tx_d_1;
     m_rx_en_1        <= m_tx_en_1;
     m_rx_err_1       <= m_tx_err_1;
     m_rx_col_1       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_1       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_1     <= tx_control_1;
     rgmii_in_1       <= rgmii_out_1;
     rxp_1       <= txp_1 ;
 
     gm_rx_d_2        <= gm_tx_d_2;
     gm_rx_dv_2       <= gm_tx_en_2;
     gm_rx_err_2      <= gm_tx_err_2;
     m_rx_d_2         <= m_tx_d_2;
     m_rx_en_2        <= m_tx_en_2;
     m_rx_err_2       <= m_tx_err_2;
     m_rx_col_2       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_2       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_2     <= tx_control_2;
     rgmii_in_2       <= rgmii_out_2;
     rxp_2       <= txp_2 ;
 
     gm_rx_d_3        <= gm_tx_d_3;
     gm_rx_dv_3       <= gm_tx_en_3;
     gm_rx_err_3      <= gm_tx_err_3;
     m_rx_d_3         <= m_tx_d_3;
     m_rx_en_3        <= m_tx_en_3;
     m_rx_err_3       <= m_tx_err_3;
     m_rx_col_3       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_3       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_3     <= tx_control_3;
     rgmii_in_3       <= rgmii_out_3;
     rxp_3       <= txp_3 ;

     gm_rx_d_4        <= gm_tx_d_4;
     gm_rx_dv_4       <= gm_tx_en_4;
     gm_rx_err_4      <= gm_tx_err_4;
     m_rx_d_4         <= m_tx_d_4;
     m_rx_en_4        <= m_tx_en_4;
     m_rx_err_4       <= m_tx_err_4;
     m_rx_col_4       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_4       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_4     <= tx_control_4;
     rgmii_in_4       <= rgmii_out_4;
     rxp_4       <= txp_4 ;
 
     gm_rx_d_5        <= gm_tx_d_5;
     gm_rx_dv_5       <= gm_tx_en_5;
     gm_rx_err_5      <= gm_tx_err_5;
     m_rx_d_5         <= m_tx_d_5;
     m_rx_en_5        <= m_tx_en_5;
     m_rx_err_5       <= m_tx_err_5;
     m_rx_col_5       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_5       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_5     <= tx_control_5;
     rgmii_in_5       <= rgmii_out_5;
     rxp_5       <= txp_5 ;
 
     gm_rx_d_6        <= gm_tx_d_6;
     gm_rx_dv_6       <= gm_tx_en_6;
     gm_rx_err_6      <= gm_tx_err_6;
     m_rx_d_6         <= m_tx_d_6;
     m_rx_en_6        <= m_tx_en_6;
     m_rx_err_6       <= m_tx_err_6;
     m_rx_col_6       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_6       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_6     <= tx_control_6;
     rgmii_in_6       <= rgmii_out_6;
     rxp_6       <= txp_6 ;
 
     gm_rx_d_7        <= gm_tx_d_7;
     gm_rx_dv_7       <= gm_tx_en_7;
     gm_rx_err_7      <= gm_tx_err_7;
     m_rx_d_7         <= m_tx_d_7;
     m_rx_en_7        <= m_tx_en_7;
     m_rx_err_7       <= m_tx_err_7;
     m_rx_col_7       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_7       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_7     <= tx_control_7;
     rgmii_in_7       <= rgmii_out_7;
     rxp_7       <= txp_7 ;

     gm_rx_d_8        <= gm_tx_d_8;
     gm_rx_dv_8       <= gm_tx_en_8;
     gm_rx_err_8      <= gm_tx_err_8;
     m_rx_d_8         <= m_tx_d_8;
     m_rx_en_8        <= m_tx_en_8;
     m_rx_err_8       <= m_tx_err_8;
     m_rx_col_8       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_8       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_8     <= tx_control_8;
     rgmii_in_8       <= rgmii_out_8;
     rxp_8       <= txp_8 ;
 
     gm_rx_d_9        <= gm_tx_d_9;
     gm_rx_dv_9       <= gm_tx_en_9;
     gm_rx_err_9      <= gm_tx_err_9;
     m_rx_d_9         <= m_tx_d_9;
     m_rx_en_9        <= m_tx_en_9;
     m_rx_err_9       <= m_tx_err_9;
     m_rx_col_9       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_9       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_9     <= tx_control_9;
     rgmii_in_9       <= rgmii_out_9;
     rxp_9       <= txp_9 ;
 
     gm_rx_d_10        <= gm_tx_d_10;
     gm_rx_dv_10       <= gm_tx_en_10;
     gm_rx_err_10      <= gm_tx_err_10;
     m_rx_d_10         <= m_tx_d_10;
     m_rx_en_10        <= m_tx_en_10;
     m_rx_err_10       <= m_tx_err_10;
     m_rx_col_10       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_10       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_10     <= tx_control_10;
     rgmii_in_10       <= rgmii_out_10;
     rxp_10       <= txp_10 ;
 
     gm_rx_d_11        <= gm_tx_d_11;
     gm_rx_dv_11       <= gm_tx_en_11;
     gm_rx_err_11      <= gm_tx_err_11;
     m_rx_d_11         <= m_tx_d_11;
     m_rx_en_11        <= m_tx_en_11;
     m_rx_err_11       <= m_tx_err_11;
     m_rx_col_11       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_11       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_11     <= tx_control_11;
     rgmii_in_11       <= rgmii_out_11;
     rxp_11       <= txp_11 ;

     gm_rx_d_12        <= gm_tx_d_12;
     gm_rx_dv_12       <= gm_tx_en_12;
     gm_rx_err_12      <= gm_tx_err_12;
     m_rx_d_12         <= m_tx_d_12;
     m_rx_en_12        <= m_tx_en_12;
     m_rx_err_12       <= m_tx_err_12;
     m_rx_col_12       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_12       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_12     <= tx_control_12;
     rgmii_in_12       <= rgmii_out_12;
     rxp_12       <= txp_12 ;
 
     gm_rx_d_13        <= gm_tx_d_13;
     gm_rx_dv_13       <= gm_tx_en_13;
     gm_rx_err_13      <= gm_tx_err_13;
     m_rx_d_13         <= m_tx_d_13;
     m_rx_en_13        <= m_tx_en_13;
     m_rx_err_13       <= m_tx_err_13;
     m_rx_col_13       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_13       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_13     <= tx_control_13;
     rgmii_in_13       <= rgmii_out_13;
     rxp_13       <= txp_13 ;
 
     gm_rx_d_14        <= gm_tx_d_14;
     gm_rx_dv_14       <= gm_tx_en_14;
     gm_rx_err_14      <= gm_tx_err_14;
     m_rx_d_14         <= m_tx_d_14;
     m_rx_en_14        <= m_tx_en_14;
     m_rx_err_14       <= m_tx_err_14;
     m_rx_col_14       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_14       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_14     <= tx_control_14;
     rgmii_in_14       <= rgmii_out_14;
     rxp_14       <= txp_14 ;
 
     gm_rx_d_15        <= gm_tx_d_15;
     gm_rx_dv_15       <= gm_tx_en_15;
     gm_rx_err_15      <= gm_tx_err_15;
     m_rx_d_15         <= m_tx_d_15;
     m_rx_en_15        <= m_tx_en_15;
     m_rx_err_15       <= m_tx_err_15;
     m_rx_col_15       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_15       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_15     <= tx_control_15;
     rgmii_in_15       <= rgmii_out_15;
     rxp_15       <= txp_15 ;

     gm_rx_d_16        <= gm_tx_d_16;
     gm_rx_dv_16       <= gm_tx_en_16;
     gm_rx_err_16      <= gm_tx_err_16;
     m_rx_d_16         <= m_tx_d_16;
     m_rx_en_16        <= m_tx_en_16;
     m_rx_err_16       <= m_tx_err_16;
     m_rx_col_16       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_16       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_16     <= tx_control_16;
     rgmii_in_16       <= rgmii_out_16;
     rxp_16       <= txp_16 ;
 
     gm_rx_d_17        <= gm_tx_d_17;
     gm_rx_dv_17       <= gm_tx_en_17;
     gm_rx_err_17      <= gm_tx_err_17;
     m_rx_d_17         <= m_tx_d_17;
     m_rx_en_17        <= m_tx_en_17;
     m_rx_err_17       <= m_tx_err_17;
     m_rx_col_17       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_17       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_17     <= tx_control_17;
     rgmii_in_17       <= rgmii_out_17;
     rxp_17       <= txp_17 ;
 
     gm_rx_d_18        <= gm_tx_d_18;
     gm_rx_dv_18       <= gm_tx_en_18;
     gm_rx_err_18      <= gm_tx_err_18;
     m_rx_d_18         <= m_tx_d_18;
     m_rx_en_18        <= m_tx_en_18;
     m_rx_err_18       <= m_tx_err_18;
     m_rx_col_18       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_18       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_18     <= tx_control_18;
     rgmii_in_18       <= rgmii_out_18;
     rxp_18       <= txp_18 ;
 
     gm_rx_d_19        <= gm_tx_d_19;
     gm_rx_dv_19       <= gm_tx_en_19;
     gm_rx_err_19      <= gm_tx_err_19;
     m_rx_d_19         <= m_tx_d_19;
     m_rx_en_19        <= m_tx_en_19;
     m_rx_err_19       <= m_tx_err_19;
     m_rx_col_19       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_19       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_19     <= tx_control_19;
     rgmii_in_19       <= rgmii_out_19;
     rxp_19       <= txp_19 ;

     gm_rx_d_20        <= gm_tx_d_20;
     gm_rx_dv_20       <= gm_tx_en_20;
     gm_rx_err_20      <= gm_tx_err_20;
     m_rx_d_20         <= m_tx_d_20;
     m_rx_en_20        <= m_tx_en_20;
     m_rx_err_20       <= m_tx_err_20;
     m_rx_col_20       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_20       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_20     <= tx_control_20;
     rgmii_in_20       <= rgmii_out_20;
     rxp_20       <= txp_20 ;
 
     gm_rx_d_21        <= gm_tx_d_21;
     gm_rx_dv_21       <= gm_tx_en_21;
     gm_rx_err_21      <= gm_tx_err_21;
     m_rx_d_21         <= m_tx_d_21;
     m_rx_en_21        <= m_tx_en_21;
     m_rx_err_21       <= m_tx_err_21;
     m_rx_col_21       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_21       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_21     <= tx_control_21;
     rgmii_in_21       <= rgmii_out_21;
     rxp_21       <= txp_21 ;
 
     gm_rx_d_22        <= gm_tx_d_22;
     gm_rx_dv_22       <= gm_tx_en_22;
     gm_rx_err_22      <= gm_tx_err_22;
     m_rx_d_22         <= m_tx_d_22;
     m_rx_en_22        <= m_tx_en_22;
     m_rx_err_22       <= m_tx_err_22;
     m_rx_col_22       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_22       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_22     <= tx_control_22;
     rgmii_in_22       <= rgmii_out_22;
     rxp_22       <= txp_22 ;
 
     gm_rx_d_23        <= gm_tx_d_23;
     gm_rx_dv_23       <= gm_tx_en_23;
     gm_rx_err_23      <= gm_tx_err_23;
     m_rx_d_23         <= m_tx_d_23;
     m_rx_en_23        <= m_tx_en_23;
     m_rx_err_23       <= m_tx_err_23;
     m_rx_col_23       <= '0'; --always disable Half Duplex support for multi-port simulation
     m_rx_crs_23       <= '0'; --always disable Half Duplex support for multi-port simulation
     rx_control_23     <= tx_control_23;
     rgmii_in_23       <= rgmii_out_23;
     rxp_23       <= txp_23 ;
   
  end generate; 
   
   rx_set_locktodata(0) <= '0';
   rx_set_locktoref(0) <= '0';
   rx_cdr_refclk <= ref_clk;

   rx_set_locktodata_0(0) <= '0';
   rx_set_locktoref_0(0) <= '0';
   rx_cdr_refclk_0 <= ref_clk;
   tx_serial_clk_0 <= tx_serial_clk;
   tx_analogreset_0 <= tx_analogreset;
   tx_digitalreset_0 <= tx_digitalreset;
   rx_analogreset_0 <= rx_analogreset;
   rx_digitalreset_0 <= rx_digitalreset;

   rx_set_locktodata_1(0) <= '0';
   rx_set_locktoref_1(0) <= '0';
   rx_cdr_refclk_1 <= ref_clk;
   tx_serial_clk_1 <= tx_serial_clk;
   tx_analogreset_1 <= tx_analogreset;
   tx_digitalreset_1 <= tx_digitalreset;
   rx_analogreset_1 <= rx_analogreset;
   rx_digitalreset_1 <= rx_digitalreset;

   rx_set_locktodata_2(0) <= '0';
   rx_set_locktoref_2(0) <= '0';
   rx_cdr_refclk_2 <= ref_clk;
   tx_serial_clk_2 <= tx_serial_clk;
   tx_analogreset_2 <= tx_analogreset;
   tx_digitalreset_2 <= tx_digitalreset;
   rx_analogreset_2 <= rx_analogreset;
   rx_digitalreset_2 <= rx_digitalreset;

   rx_set_locktodata_3(0) <= '0';
   rx_set_locktoref_3(0) <= '0';
   rx_cdr_refclk_3 <= ref_clk;
   tx_serial_clk_3 <= tx_serial_clk;
   tx_analogreset_3 <= tx_analogreset;
   tx_digitalreset_3 <= tx_digitalreset;
   rx_analogreset_3 <= rx_analogreset;
   rx_digitalreset_3 <= rx_digitalreset;

   rx_set_locktodata_4(0) <= '0';
   rx_set_locktoref_4(0) <= '0';
   rx_cdr_refclk_4 <= ref_clk;
   tx_serial_clk_4 <= tx_serial_clk;
   tx_analogreset_4 <= tx_analogreset;
   tx_digitalreset_4 <= tx_digitalreset;
   rx_analogreset_4 <= rx_analogreset;
   rx_digitalreset_4 <= rx_digitalreset;

   rx_set_locktodata_5(0) <= '0';
   rx_set_locktoref_5(0) <= '0';
   rx_cdr_refclk_5 <= ref_clk;
   tx_serial_clk_5 <= tx_serial_clk;
   tx_analogreset_5 <= tx_analogreset;
   tx_digitalreset_5 <= tx_digitalreset;
   rx_analogreset_5 <= rx_analogreset;
   rx_digitalreset_5 <= rx_digitalreset;

   rx_set_locktodata_6(0) <= '0';
   rx_set_locktoref_6(0) <= '0';
   rx_cdr_refclk_6 <= ref_clk;
   tx_serial_clk_6 <= tx_serial_clk;
   tx_analogreset_6 <= tx_analogreset;
   tx_digitalreset_6 <= tx_digitalreset;
   rx_analogreset_6 <= rx_analogreset;
   rx_digitalreset_6 <= rx_digitalreset;

   rx_set_locktodata_7(0) <= '0';
   rx_set_locktoref_7(0) <= '0';
   rx_cdr_refclk_7 <= ref_clk;
   tx_serial_clk_7 <= tx_serial_clk;
   tx_analogreset_7 <= tx_analogreset;
   tx_digitalreset_7 <= tx_digitalreset;
   rx_analogreset_7 <= rx_analogreset;
   rx_digitalreset_7 <= rx_digitalreset;

   rx_set_locktodata_8(0) <= '0';
   rx_set_locktoref_8(0) <= '0';
   rx_cdr_refclk_8 <= ref_clk;
   tx_serial_clk_8 <= tx_serial_clk;
   tx_analogreset_8 <= tx_analogreset;
   tx_digitalreset_8 <= tx_digitalreset;
   rx_analogreset_8 <= rx_analogreset;
   rx_digitalreset_8 <= rx_digitalreset;

   rx_set_locktodata_9(0) <= '0';
   rx_set_locktoref_9(0) <= '0';
   rx_cdr_refclk_9 <= ref_clk;
   tx_serial_clk_9 <= tx_serial_clk;
   tx_analogreset_9 <= tx_analogreset;
   tx_digitalreset_9 <= tx_digitalreset;
   rx_analogreset_9 <= rx_analogreset;
   rx_digitalreset_9 <= rx_digitalreset;

   rx_set_locktodata_10(0) <= '0';
   rx_set_locktoref_10(0) <= '0';
   rx_cdr_refclk_10 <= ref_clk;
   tx_serial_clk_10 <= tx_serial_clk;
   tx_analogreset_10 <= tx_analogreset;
   tx_digitalreset_10 <= tx_digitalreset;
   rx_analogreset_10 <= rx_analogreset;
   rx_digitalreset_10 <= rx_digitalreset;

   rx_set_locktodata_11(0) <= '0';
   rx_set_locktoref_11(0) <= '0';
   rx_cdr_refclk_11 <= ref_clk;
   tx_serial_clk_11 <= tx_serial_clk;
   tx_analogreset_11 <= tx_analogreset;
   tx_digitalreset_11 <= tx_digitalreset;
   rx_analogreset_11 <= rx_analogreset;
   rx_digitalreset_11 <= rx_digitalreset;

   rx_set_locktodata_12(0) <= '0';
   rx_set_locktoref_12(0) <= '0';
   rx_cdr_refclk_12 <= ref_clk;
   tx_serial_clk_12 <= tx_serial_clk;
   tx_analogreset_12 <= tx_analogreset;
   tx_digitalreset_12 <= tx_digitalreset;
   rx_analogreset_12 <= rx_analogreset;
   rx_digitalreset_12 <= rx_digitalreset;

   rx_set_locktodata_13(0) <= '0';
   rx_set_locktoref_13(0) <= '0';
   rx_cdr_refclk_13 <= ref_clk;
   tx_serial_clk_13 <= tx_serial_clk;
   tx_analogreset_13 <= tx_analogreset;
   tx_digitalreset_13 <= tx_digitalreset;
   rx_analogreset_13 <= rx_analogreset;
   rx_digitalreset_13 <= rx_digitalreset;

   rx_set_locktodata_14(0) <= '0';
   rx_set_locktoref_14(0) <= '0';
   rx_cdr_refclk_14 <= ref_clk;
   tx_serial_clk_14 <= tx_serial_clk;
   tx_analogreset_14 <= tx_analogreset;
   tx_digitalreset_14 <= tx_digitalreset;
   rx_analogreset_14 <= rx_analogreset;
   rx_digitalreset_14 <= rx_digitalreset;

   rx_set_locktodata_15(0) <= '0';
   rx_set_locktoref_15(0) <= '0';
   rx_cdr_refclk_15 <= ref_clk;
   tx_serial_clk_15 <= tx_serial_clk;
   tx_analogreset_15 <= tx_analogreset;
   tx_digitalreset_15 <= tx_digitalreset;
   rx_analogreset_15 <= rx_analogreset;
   rx_digitalreset_15 <= rx_digitalreset;

   rx_set_locktodata_16(0) <= '0';
   rx_set_locktoref_16(0) <= '0';
   rx_cdr_refclk_16 <= ref_clk;
   tx_serial_clk_16 <= tx_serial_clk;
   tx_analogreset_16 <= tx_analogreset;
   tx_digitalreset_16 <= tx_digitalreset;
   rx_analogreset_16 <= rx_analogreset;
   rx_digitalreset_16 <= rx_digitalreset;

   rx_set_locktodata_17(0) <= '0';
   rx_set_locktoref_17(0) <= '0';
   rx_cdr_refclk_17 <= ref_clk;
   tx_serial_clk_17 <= tx_serial_clk;
   tx_analogreset_17 <= tx_analogreset;
   tx_digitalreset_17 <= tx_digitalreset;
   rx_analogreset_17 <= rx_analogreset;
   rx_digitalreset_17 <= rx_digitalreset;

   rx_set_locktodata_18(0) <= '0';
   rx_set_locktoref_18(0) <= '0';
   rx_cdr_refclk_18 <= ref_clk;
   tx_serial_clk_18 <= tx_serial_clk;
   tx_analogreset_18 <= tx_analogreset;
   tx_digitalreset_18 <= tx_digitalreset;
   rx_analogreset_18 <= rx_analogreset;
   rx_digitalreset_18 <= rx_digitalreset;

   rx_set_locktodata_19(0) <= '0';
   rx_set_locktoref_19(0) <= '0';
   rx_cdr_refclk_19 <= ref_clk;
   tx_serial_clk_19 <= tx_serial_clk;
   tx_analogreset_19 <= tx_analogreset;
   tx_digitalreset_19 <= tx_digitalreset;
   rx_analogreset_19 <= rx_analogreset;
   rx_digitalreset_19 <= rx_digitalreset;

   rx_set_locktodata_20(0) <= '0';
   rx_set_locktoref_20(0) <= '0';
   rx_cdr_refclk_20 <= ref_clk;
   tx_serial_clk_20 <= tx_serial_clk;
   tx_analogreset_20 <= tx_analogreset;
   tx_digitalreset_20 <= tx_digitalreset;
   rx_analogreset_20 <= rx_analogreset;
   rx_digitalreset_20 <= rx_digitalreset;

   rx_set_locktodata_21(0) <= '0';
   rx_set_locktoref_21(0) <= '0';
   rx_cdr_refclk_21 <= ref_clk;
   tx_serial_clk_21 <= tx_serial_clk;
   tx_analogreset_21 <= tx_analogreset;
   tx_digitalreset_21 <= tx_digitalreset;
   rx_analogreset_21 <= rx_analogreset;
   rx_digitalreset_21 <= rx_digitalreset;

   rx_set_locktodata_22(0) <= '0';
   rx_set_locktoref_22(0) <= '0';
   rx_cdr_refclk_22 <= ref_clk;
   tx_serial_clk_22 <= tx_serial_clk;
   tx_analogreset_22 <= tx_analogreset;
   tx_digitalreset_22 <= tx_digitalreset;
   rx_analogreset_22 <= rx_analogreset;
   rx_digitalreset_22 <= rx_digitalreset;

   rx_set_locktodata_23(0) <= '0';
   rx_set_locktoref_23(0) <= '0';
   rx_cdr_refclk_23 <= ref_clk;
   tx_serial_clk_23 <= tx_serial_clk;
   tx_analogreset_23 <= tx_analogreset;
   tx_digitalreset_23 <= tx_digitalreset;
   rx_analogreset_23 <= rx_analogreset;
   rx_digitalreset_23 <= rx_digitalreset;

   reconfig_clk(0) <= ref_clk;
   reconfig_reset(0) <= reset;
   reconfig_address <= conv_std_logic_vector(0, 10);
   reconfig_write(0) <= '0';
   reconfig_read(0) <= '0';
   reconfig_writedata <= conv_std_logic_vector(0, 32);

   reconfig_clk_0(0) <= ref_clk;
   reconfig_reset_0(0) <= reset;
   reconfig_address_0 <= conv_std_logic_vector(0, 10);
   reconfig_write_0(0) <= '0';
   reconfig_read_0(0) <= '0';
   reconfig_writedata_0 <= conv_std_logic_vector(0, 32);

   reconfig_clk_1(0) <= ref_clk;
   reconfig_reset_1(0) <= reset;
   reconfig_address_1 <= conv_std_logic_vector(0, 10);
   reconfig_write_1(0) <= '0';
   reconfig_read_1(0) <= '0';
   reconfig_writedata_1 <= conv_std_logic_vector(0, 32);

   reconfig_clk_2(0) <= ref_clk;
   reconfig_reset_2(0) <= reset;
   reconfig_address_2 <= conv_std_logic_vector(0, 10);
   reconfig_write_2(0) <= '0';
   reconfig_read_2(0) <= '0';
   reconfig_writedata_2 <= conv_std_logic_vector(0, 32);

   reconfig_clk_3(0) <= ref_clk;
   reconfig_reset_3(0) <= reset;
   reconfig_address_3 <= conv_std_logic_vector(0, 10);
   reconfig_write_3(0) <= '0';
   reconfig_read_3(0) <= '0';
   reconfig_writedata_3 <= conv_std_logic_vector(0, 32);

   reconfig_clk_4(0) <= ref_clk;
   reconfig_reset_4(0) <= reset;
   reconfig_address_4 <= conv_std_logic_vector(0, 10);
   reconfig_write_4(0) <= '0';
   reconfig_read_4(0) <= '0';
   reconfig_writedata_4 <= conv_std_logic_vector(0, 32);

   reconfig_clk_5(0) <= ref_clk;
   reconfig_reset_5(0) <= reset;
   reconfig_address_5 <= conv_std_logic_vector(0, 10);
   reconfig_write_5(0) <= '0';
   reconfig_read_5(0) <= '0';
   reconfig_writedata_5 <= conv_std_logic_vector(0, 32);

   reconfig_clk_6(0) <= ref_clk;
   reconfig_reset_6(0) <= reset;
   reconfig_address_6 <= conv_std_logic_vector(0, 10);
   reconfig_write_6(0) <= '0';
   reconfig_read_6(0) <= '0';
   reconfig_writedata_6 <= conv_std_logic_vector(0, 32);

   reconfig_clk_7(0) <= ref_clk;
   reconfig_reset_7(0) <= reset;
   reconfig_address_7 <= conv_std_logic_vector(0, 10);
   reconfig_write_7(0) <= '0';
   reconfig_read_7(0) <= '0';
   reconfig_writedata_7 <= conv_std_logic_vector(0, 32);

   reconfig_clk_8(0) <= ref_clk;
   reconfig_reset_8(0) <= reset;
   reconfig_address_8 <= conv_std_logic_vector(0, 10);
   reconfig_write_8(0) <= '0';
   reconfig_read_8(0) <= '0';
   reconfig_writedata_8 <= conv_std_logic_vector(0, 32);

   reconfig_clk_9(0) <= ref_clk;
   reconfig_reset_9(0) <= reset;
   reconfig_address_9 <= conv_std_logic_vector(0, 10);
   reconfig_write_9(0) <= '0';
   reconfig_read_9(0) <= '0';
   reconfig_writedata_9 <= conv_std_logic_vector(0, 32);

   reconfig_clk_10(0) <= ref_clk;
   reconfig_reset_10(0) <= reset;
   reconfig_address_10 <= conv_std_logic_vector(0, 10);
   reconfig_write_10(0) <= '0';
   reconfig_read_10(0) <= '0';
   reconfig_writedata_10 <= conv_std_logic_vector(0, 32);

   reconfig_clk_11(0) <= ref_clk;
   reconfig_reset_11(0) <= reset;
   reconfig_address_11 <= conv_std_logic_vector(0, 10);
   reconfig_write_11(0) <= '0';
   reconfig_read_11(0) <= '0';
   reconfig_writedata_11 <= conv_std_logic_vector(0, 32);

   reconfig_clk_12(0) <= ref_clk;
   reconfig_reset_12(0) <= reset;
   reconfig_address_12 <= conv_std_logic_vector(0, 10);
   reconfig_write_12(0) <= '0';
   reconfig_read_12(0) <= '0';
   reconfig_writedata_12 <= conv_std_logic_vector(0, 32);

   reconfig_clk_13(0) <= ref_clk;
   reconfig_reset_13(0) <= reset;
   reconfig_address_13 <= conv_std_logic_vector(0, 10);
   reconfig_write_13(0) <= '0';
   reconfig_read_13(0) <= '0';
   reconfig_writedata_13 <= conv_std_logic_vector(0, 32);

   reconfig_clk_14(0) <= ref_clk;
   reconfig_reset_14(0) <= reset;
   reconfig_address_14 <= conv_std_logic_vector(0, 10);
   reconfig_write_14(0) <= '0';
   reconfig_read_14(0) <= '0';
   reconfig_writedata_14 <= conv_std_logic_vector(0, 32);

   reconfig_clk_15(0) <= ref_clk;
   reconfig_reset_15(0) <= reset;
   reconfig_address_15 <= conv_std_logic_vector(0, 10);
   reconfig_write_15(0) <= '0';
   reconfig_read_15(0) <= '0';
   reconfig_writedata_15 <= conv_std_logic_vector(0, 32);

   reconfig_clk_16(0) <= ref_clk;
   reconfig_reset_16(0) <= reset;
   reconfig_address_16 <= conv_std_logic_vector(0, 10);
   reconfig_write_16(0) <= '0';
   reconfig_read_16(0) <= '0';
   reconfig_writedata_16 <= conv_std_logic_vector(0, 32);

   reconfig_clk_17(0) <= ref_clk;
   reconfig_reset_17(0) <= reset;
   reconfig_address_17 <= conv_std_logic_vector(0, 10);
   reconfig_write_17(0) <= '0';
   reconfig_read_17(0) <= '0';
   reconfig_writedata_17 <= conv_std_logic_vector(0, 32);

   reconfig_clk_18(0) <= ref_clk;
   reconfig_reset_18(0) <= reset;
   reconfig_address_18 <= conv_std_logic_vector(0, 10);
   reconfig_write_18(0) <= '0';
   reconfig_read_18(0) <= '0';
   reconfig_writedata_18 <= conv_std_logic_vector(0, 32);

   reconfig_clk_19(0) <= ref_clk;
   reconfig_reset_19(0) <= reset;
   reconfig_address_19 <= conv_std_logic_vector(0, 10);
   reconfig_write_19(0) <= '0';
   reconfig_read_19(0) <= '0';
   reconfig_writedata_19 <= conv_std_logic_vector(0, 32);

   reconfig_clk_20(0) <= ref_clk;
   reconfig_reset_20(0) <= reset;
   reconfig_address_20 <= conv_std_logic_vector(0, 10);
   reconfig_write_20(0) <= '0';
   reconfig_read_20(0) <= '0';
   reconfig_writedata_20 <= conv_std_logic_vector(0, 32);

   reconfig_clk_21(0) <= ref_clk;
   reconfig_reset_21(0) <= reset;
   reconfig_address_21 <= conv_std_logic_vector(0, 10);
   reconfig_write_21(0) <= '0';
   reconfig_read_21(0) <= '0';
   reconfig_writedata_21 <= conv_std_logic_vector(0, 32);

   reconfig_clk_22(0) <= ref_clk;
   reconfig_reset_22(0) <= reset;
   reconfig_address_22 <= conv_std_logic_vector(0, 10);
   reconfig_write_22(0) <= '0';
   reconfig_read_22(0) <= '0';
   reconfig_writedata_22 <= conv_std_logic_vector(0, 32);

   reconfig_clk_23(0) <= ref_clk;
   reconfig_reset_23(0) <= reset;
   reconfig_address_23 <= conv_std_logic_vector(0, 10);
   reconfig_write_23(0) <= '0';
   reconfig_read_23(0) <= '0';
   reconfig_writedata_23 <= conv_std_logic_vector(0, 32);

   i_reset_model: NF_PHYIP_RESET_MODEL
   port map (
      clk => ref_clk,
      reset => reset,
      tx_serial_clk => tx_serial_clk,
      tx_analogreset => tx_analogreset,
      tx_digitalreset => tx_digitalreset,
      tx_ready => tx_ready,
      rx_analogreset => rx_analogreset,
      rx_digitalreset => rx_digitalreset,
      rx_ready => rx_ready,
      tx_cal_busy => tx_cal_busy,
      rx_is_lockedtodata => rx_is_lockedtodata,
      rx_cal_busy => rx_cal_busy
   );

  -- $<RTL_CORE_INSTANCE>
                                 
   -- MAC Configuration
   -- -----------------

        mac_addr        <= X"EE1122334450" ;
        sup_mac_addr_0  <= X"EE2233445560" ;
        sup_mac_addr_1  <= X"EE3344556670" ;
        sup_mac_addr_2  <= X"EE4455667780" ;
        sup_mac_addr_3  <= X"EE5566778890" ;
        frm_length_max  <= conv_std_logic_vector(TB_MACLENMAX, 16) ;
                
   -- MDIO Slave Model
   -- ----------------
   MDIO_PORT_MAP_GEN: if (ENABLE_MDIO= 1) generate
   begin
   
        process
        begin
        
                mdio <= 'H' ;
                wait ;
                
        end process ;
   
        mdio_in <= mdio ;
        mdio    <= 'H' when (mdio_oen='1') else mdio_out ; 
   
                
        MDIO_1: top_mdio_slave port map (

                reset           => reset, 
                mdc             => mdc ,
                mdio            => mdio ,
                dev_addr        => phy_addr1 ,
                conf_done       => mdio1_done) ;
                
        phy_addr1 <= conv_std_logic_vector(TB_MDIO_ADDR1, 5) ;
   end generate;
        
   -- Checking FIFO Signals
   -- ---------------------
   
        process(reset, ff_rx_clk)
        begin
        
                if (reset='1') then
                
                        ff_rx_ucast_reg <= '0' ;
                        ff_rx_bcast_reg <= '0' ;
                        ff_rx_mcast_reg <= '0' ;
                        ff_rx_vlan_reg  <= '0' ;
                        
                elsif (ff_rx_clk='1') and (ff_rx_clk'event) then
                
                        if (ff_rx_sop='1') then
                        
                                ff_rx_ucast_reg <= ff_rx_ucast ;
                                ff_rx_bcast_reg <= ff_rx_bcast ;
                                ff_rx_mcast_reg <= ff_rx_mcast ;
                                ff_rx_vlan_reg  <= ff_rx_vlan ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(ff_rx_clk)
        
                variable ln : line ;
        
        begin
        
                if (ff_rx_clk='1') and (ff_rx_clk'event) then
        
                        if (mff_frm_rcvd='1') then
                
                                if (mff_dst_reg=X"FFFFFFFFFFFF" and ff_rx_bcast_reg='0') then
                                
                                        write(ln, string'(" ")) ; 
                                        writeline(output, ln) ; 
                                        write(ln, NOW) ;
                                        write(ln, string'(" - Error: FIFO Broadcast Frame Error")) ;
                                        writeline(output, ln) ; 
                                                                        
                                end if ;
                        
                                if (mff_dst_reg/=X"FFFFFFFFFFFF" and mff_dst_reg(0)='1' and ff_rx_mcast_reg='0' and mff_is_pause='0') then
                                
                                        write(ln, string'(" ")) ; 
                                        writeline(output, ln) ; 
                                        write(ln, NOW) ;
                                        write(ln, string'(" - Error: FIFO Multicast Frame Error")) ;
                                        writeline(output, ln) ; 
                                                                
                                end if ;
                        
                                if (mff_dst_reg(0)='0' and ff_rx_ucast_reg='0' and mff_is_pause='0') then
                                
                                        write(ln, string'(" ")) ; 
                                        writeline(output, ln) ; 
                                        write(ln, NOW) ;
                                        write(ln, string'(" - Error: FIFO Unicast Frame Error")) ;
                                        writeline(output, ln) ; 
                                                                
                                end if ;
                                
                                if (ff_rx_vlan_reg='1' and mff_is_vlan='0') then
                                
                                        write(ln, string'(" ")) ; 
                                        writeline(output, ln) ; 
                                        write(ln, NOW) ;
                                        write(ln, string'(" - Error: FIFO VLAN Frame Error")) ;
                                        writeline(output, ln) ; 
                                                                
                                end if ;
                        
                        end if ;
                        
                end if ;
                
        end process ;        

                                   
   -- Frame generator feeds TX FIFO (simulate user application) 
   -- ---------------------------------------------------------
        Client_TRAFFIC_non_zero_latency: if (MAX_CHANNELS = 0) generate
        FF_GEN: ethgenerator 
        
                generic map (  
                        THOLD           => 2 ns,
                        LATENCY         => TX_FIFO_AF - 3
                     )
        
                port map (
        
                        reset           => reset ,          
                        rx_clk          => ff_tx_clk_gen ,         -- FIFO Transmit Interface
                        enable          => ff_tx_rdy,
                        rxd             => ff_tx_data ,            
                        rx_dv           => ff_tx_wren_gen ,       
                        rx_er           => ff_tx_err ,          
                        sop             => ff_tx_sop ,            
                        eop             => ff_tx_eop ,            
                        mac_reverse     => ff_mac_reverse ,    -- CONFIGURATION
                        dst             => ff_dst ,        
                        src             => ff_src ,       
                        prmble_len      => ff_prmble_len , 
                        pquant          => ff_pquant ,    
                        vlan_ctl        => ff_vlan_ctl ,  
                        len             => ff_len ,       
                        frmtype         => ff_frmtype ,    
                        cntstart        => ff_cntstart ,  
                        cntstep         => ff_cntstep ,   
                        ipg_len         => ff_ipg_len ,   
                        payload_err     => ff_payload_err ,
                        prmbl_err       => ff_prmbl_err , 
                        crc_err         => ff_crc_err ,   
                        vlan_en         => ff_vlan_en ,   
                        pause_gen       => '0' ,          -- not applicable on FIFO interface
                        wrong_pause_op  => '0' ,  
                        wrong_pause_lgth=> '0' ,
                        pad_en          => ff_pad_en ,    
                        phy_err         => ff_phy_err ,   
                        end_err         => ff_end_err , 
                        magic           => '0' ,  
                        data_only       => '1' , 
                        stack_vlan      => ff_stack_vlan_en ,
                        start           => ff_start_ether_gen ,
                        done            => ff_ether_gen_done) ;
           end generate;


           Client_TRAFFIC_zero_latency: if (MAX_CHANNELS > 0) generate
               FF_GEN: top_ethgenerator_8 
               
                       generic map (  
                                       
                               THOLD           => 2 ns,
                               ENABLE_SHIFT16  => ENABLE_SHIFT16,
                               ZERO_LATENCY    => 1
                               )
               
                       port map (
               
                               reset           => reset ,          
                               clk             => ff_tx_clk_gen ,         -- FIFO Transmit Interface
                               enable          => ff_tx_rdy,
                               dout            => ff_tx_data ,            
                               dval            => ff_tx_wren_gen ,       
                               derror          => ff_tx_err ,          
                               sop             => ff_tx_sop ,            
                               eop             => ff_tx_eop ,            
                               mac_reverse     => ff_mac_reverse ,    -- CONFIGURATION
                               dst             => ff_dst ,        
                               src             => ff_src ,       
                               prmble_len      => ff_prmble_len , 
                               pquant          => ff_pquant ,    
                               vlan_ctl        => ff_vlan_ctl ,  
                               len             => ff_len ,       
                               frmtype         => ff_frmtype ,    
                               cntstart        => ff_cntstart ,  
                               cntstep         => ff_cntstep ,   
                               ipg_len         => ff_ipg_len ,   
                               payload_err     => ff_payload_err ,
                               prmbl_err       => ff_prmbl_err , 
                               crc_err         => ff_crc_err ,   
                               vlan_en         => ff_vlan_en ,   
                               stack_vlan      => ff_stack_vlan_en ,
                               pause_gen       => '0' ,          -- not applicable on FIFO interface
                               pad_en          => ff_pad_en ,    
                               phy_err         => ff_phy_err ,   
                               end_err         => ff_end_err , 
                               data_only       => '1' , 
                               start           => ff_start_ether_gen ,
                               done            => ff_ether_gen_done) ;
              end generate;



        -- FIFO Monitor RX (user appl)
        -- ----------------------------

                FF_MON: ETHMONITOR 
        
        
         generic map (  ENABLE_SHIFT16 => ENABLE_SHIFT16
            )

        port map (

                        reset           => reset,         -- active high
                        tx_clk          => ff_rx_clk, 
                        txd             => ff_rx_data,
                        tx_dv           => ff_rx_dval,
                        tx_er           => '0',
                        tx_sop          => ff_rx_sop ,
                        tx_eop          => ff_rx_eop ,                        
                        dst             => mff_dst,           
                        src             => mff_src,           
                        prmble_len      => mff_prmble_len,    
                        pquant          => mff_pquant,
                        vlan_ctl        => mff_vlan_ctl,
                        len             => mff_len,     
                        frmtype         => mff_frmtype,
                        payload         => mff_payload,      
                        payload_vld     => mff_payload_vld,
                        is_vlan         => mff_is_vlan,
                        is_stack_vlan   => mff_is_stack_vlan,  
                        is_pause        => mff_is_pause,      
                        crc_err         => mff_crc_err,     
                        prmbl_err       => mff_prmbl_err,
                        len_err         => mff_len_err,      
                        payload_err     => mff_payload_err,
                        frame_err       => mff_frame_err,  
                        pause_op_err    => mff_pause_op_err,
                        pause_dst_err   => mff_pause_dst_err,
                        mac_err         => mff_mac_err, 
                        end_err         => mff_end_err, 
                        jumbo_en        => jumbo_enable,      
                        data_only       => '1',              -- FIFO interface: data mode
                        frm_rcvd        => mff_frm_rcvd );     
                                         
                                       
   -- FIFO Generator model configuration (user application TX)
   -- -----------------------------------------------------
                                       
        ff_mac_reverse  <= '0' ;   
        ff_dst          <= X"EE1122334450" ;        
        ff_src          <= X"AA6655443322" ;       
        ff_prmble_len   <= 8 ; 
        ff_pquant       <= conv_std_logic_vector(200, 16) ;    
        ff_vlan_ctl     <= X"1234" ; 
        ff_frmtype      <= X"0000" ;    
        ff_cntstart     <= 0 ;  
        ff_cntstep      <= 1 ;   
        ff_ipg_len      <= 4 ;  
        ff_payload_err  <= '0' ;
        ff_prmbl_err    <= '0' ; 
        ff_crc_err      <= '0' ;  
        ff_vlan_en      <= '1' when( TB_ENA_VLAN>0 and (txframe_cnt mod  TB_ENA_VLAN) = TB_ENA_VLAN-1) else '0';
        ff_stack_vlan_en<= '1' when( TB_ENA_VLAN>0 and (txframe_cnt mod  (3*TB_ENA_VLAN)) = TB_ENA_VLAN-1) else '0';
        ff_pad_en       <= '0' ;    
        ff_phy_err      <= '1' when (TB_TX_FF_ERR=TRUE) else '0' ;   
        ff_end_err      <= '0' ;   

   -- --------------------------------------------------------------------------------    
   -- TX PATH Simulation
   -- --------------------------------------------------------------------------------    
        rxframe_cnt <= txframe_cnt;

    
        ff_tx_clk_gen <= ff_tx_clk ;--     and ff_tx_clk_gen_en;   -- hold the generator if FIFO signals full
        ff_tx_wren    <= ff_tx_wren_gen;-- and ff_tx_clk_gen_en;   -- and stop writing during hold
    
        ff_start_ether_gen <= '1' after 1 us when (state=SIM and sim_start='1' and txsim_done='0' and txframe_cnt < TB_TXFRAMES and HD_ENA=FALSE and ENA_INVERT_LB=FALSE) else
                              '1' after 1 us when (state=SIM and sim_start='1' and txsim_done='0' and rxframe_cnt >= TB_RXFRAMES and txframe_cnt < TB_TXFRAMES and HD_ENA=TRUE and ENA_INVERT_LB=FALSE) else '0'; -- START Generator

        process( reset, ff_tx_clk ) 
    
                variable ln: integer;
    
        begin
        
                if( reset='1' ) then
        
                        txframe_cnt             <= 0;
                        tx_vlan_sent            <= 0;
                        tx_stack_vlan_sent      <= 0;
                        tx_payload_err_sent     <= 0;
                        tx_good_sent            <= 0;
                        txsim_done              <= '0';
                        ff_tx_clk_gen_en        <= '1';            
                        ff_len                  <= conv_std_logic_vector(TB_LENSTART, 16);
            
                elsif( ff_tx_clk'event and ff_tx_clk='1' ) then

                   -- FIFO frame generator simulation finished
                   
                        if (ENA_INVERT_LB=TRUE and txframe_cnt >= TB_RXFRAMES) then
                        
                                txsim_done <= '1'; -- STOP after last frame sent        
            
                        elsif( (txframe_cnt >= TB_TXFRAMES) and ( ff_ether_gen_done='1')) then

                                txsim_done <= '1'; -- STOP after last frame sent

                        end if;

                   -- configure generator for every frame
                   
                        if (ENA_INVERT_LB=TRUE) then
                        
                                txframe_cnt <= TB_RXFRAMES ;

                        elsif( (ff_tx_sop='1' and ff_tx_wren='1' and ENABLE_ENA = 8 and ((ff_tx_clk_gen_en='1' and ENABLE_MACLITE = 1) or ENABLE_MACLITE = 0)) or 
                               (ff_tx_sop='1' and ff_tx_wren='1' and ENABLE_ENA = 0 and (ff_tx_clk_gen_en='1' and MAX_CHANNELS > 0))  ) then
            
                                txframe_cnt  <= txframe_cnt + 1;                       -- TX FRAMEs sent to FIFO

                           -- increment payload length  
                
                                ln := (conv_integer( ff_len ) + TB_LENSTEP) mod (TB_LENMAX+1);  -- increment length for next frame
                                                       
                                if (ln < 0) then  -- incase increment was negative
                        
                                        ln := TB_LENMAX;
                                       
                                end if;                        
                        
                                ff_len <= conv_std_logic_vector(ln,16);

                           -- update counters
                
                                if( ff_vlan_en='1' and ff_stack_vlan_en='0') then  
                                        
                                        tx_vlan_sent <= tx_vlan_sent+1;
                                       
                                end if;
                                
                                if(  ff_vlan_en='1' and  ff_stack_vlan_en='1' ) then  
                                        
                                        tx_stack_vlan_sent <= tx_stack_vlan_sent+1;
                                       
                                end if;

                                if( ff_payload_err='1' ) then  
                                        
                                        tx_payload_err_sent <= tx_payload_err_sent+1;
                
                                end if;
                
                                if( ff_frmtype=X"0000" and ff_phy_err = '0' and ff_end_err = '0') then  
                                        
                                        tx_good_sent <= tx_good_sent+1;
                
                                end if;
           
                        end if;                

                elsif( ff_tx_clk'event and ff_tx_clk='0' ) then
        
                        ff_tx_clk_gen_en <= ff_tx_rdy;               -- stop the generator clock if the FIFO signals "full"
                
                end if;
    
        end process; 

                
   -- -----------------------------------------------------------------------------------
   -- TX/RX Pause Frame control block
   -- -----------------------------------------------------------------------------------

        process(reset, tx_clk)
    
                variable cnt : integer;
    
        begin
        
                if( reset='1') then
        
                        tx_pause_wait <= '0';
                        tx_pause_cnt  <= 0;
            
                elsif(tx_clk'event and tx_clk='1') then
        
                        if( tx_pause_cnt /= 0 ) then
            
                                if( gm_ether_gen_done='1' ) then      -- wait for TX to finish current frame

                                        tx_pause_cnt <= tx_pause_cnt-1;

                                end if;
                
                        else
            
                                tx_pause_wait <= '0';
                
                        end if;
                
                        if(mgm_frm_rcvd='1' and mgm_is_pause='1' and mgm_frame_err='0' and mgm_crc_err='0' and
                           TB_PAUSECONTROL=true) then
            
                                cnt := conv_integer( '0' & mgm_pquant);
                                cnt := cnt * 64;
                
                                tx_pause_cnt  <= cnt;         -- set pause counter
                                tx_pause_wait <= '1';        -- stop TX
                
                        end if;
        
                end if;
        
        end process;

   -- force generated pause frame
   -- ---------------------------        
    
        process(reset, tx_clk)
        begin
        
                if( reset='1') then
        
                        force_xoff_pause_cnt <= 0;
                        force_xon_pause_cnt  <= 0;
                        xoff_gen             <= '0';
                        xon_gen              <= '0' ;
            
                elsif(tx_clk'event and tx_clk='1') then
                
                   -- Xoff Frame Generation
                   -- ---------------------
                        
                        if (force_xoff_pause_cnt < TB_TRIGGERXOFF and state=SIM) then
            
                                force_xoff_pause_cnt <= force_xoff_pause_cnt + 1 ;  
            
                        elsif (force_xoff_pause_cnt=TB_TRIGGERXOFF and state=SIM) then
            
                                force_xoff_pause_cnt <= force_xoff_pause_cnt + 1 ;
                        
                        end if ;
                        
                        if (TB_TRIGGERXOFF=0 or HD_ENA=TRUE) then
                        
                                xoff_gen <= '0' ;
            
                        elsif (force_xoff_pause_cnt=TB_TRIGGERXOFF and state=SIM) then --and eth_mode=1000 and state=SIM) then
            
                                xoff_gen <= '1' ;   
                        
                        else
            
                                xoff_gen <= '0' ;   
            
                        end if ;
                        
                   -- Xon Frame Generation
                   -- --------------------
                        
                        if (force_xon_pause_cnt < TB_TRIGGERXON and state=SIM) then
            
                                force_xon_pause_cnt <= force_xon_pause_cnt + 1 ;    
            
                        elsif (force_xon_pause_cnt=TB_TRIGGERXON and state=SIM) then
            
                                force_xon_pause_cnt <= force_xon_pause_cnt + 1 ;
                        
                        end if ;
                        
                        if (TB_TRIGGERXON=0 or HD_ENA=TRUE) then
                        
                                xon_gen <= '0' ;
            
                        elsif (force_xon_pause_cnt=TB_TRIGGERXON and state=SIM) then
            
                                xon_gen <= '1' ;    
                        
                        else
            
                                xon_gen <= '0' ;    
            
                        end if ; 
        
                end if;
           
        end process;

   -- Total (Including Collision) Frames
   -- ----------------------------------
   
        process(reset, tx_clk)
        begin
        
                if (reset='1') then
                
                        tx_frm_all <= 0 ;
                        
                elsif (tx_clk='1') and (tx_clk'event) then
                
                        if (m_mgm_frm_rcvd='1') then
                        
                                tx_frm_all <= tx_frm_all+1 ;
                                
                        end if ;
                        
                end if ;
                
        end process ; 

    -- Expected signals: decide when we should expect something to happen
    -- ------------------------------------------------------------------
    
    process( rx_clk, reset ) 
    begin
        if( reset='1' ) then

            expect1     <= '0';
            expect2     <= '0';

        elsif( rx_clk='1' and rx_clk'event ) then

            if( gm_sop='1' and expect2='0' ) then
            
                expect2     <= '1';  -- immediately expect something
                expect1     <= '0';  -- and nothing else
                
            elsif( gm_sop='1' ) then
            
                expect1     <= '1';  -- ok, when done later, immediately expect something else coming
                
            end if;

            -- if a final event happend that indicates that something was received and
            -- therefore some expected behaviour occured we can continue to watch
            -- for new expected data

            if( pause_rcv='1' or       -- has no status fifo write
                frm_type_err='1' or    -- has no status fifo write (but should have, can strip down pipeline: TODO !!!!!)
                frm_align_err='1' or   -- has no status fifo write 
                ff_rx_eop='1') then    -- was: rx_stat_wren


                if( frm_align_err='1' and expect1='1' ) then
                
                    -- overlapped frame has an alignment error, but before the last frame
                    -- has been checked... so we have to do special things here
                    -- see alignment error checking behaviour.
                    
                    expect1 <= '0';  -- clear it, as it is processed now already
                    
                else
                
                    expect2     <='0';     -- pulse for at least 1 cycle    
                    
                end if;
                
            end if;
            
            -- if a new expectation was already inserted before we were done with the old, 
            -- immediately restart it now as we have processed the last expected (2)
            
            if( expect1='1' and expect2='0' ) then    -- there is something to expect !
            
                expect1 <= '0';
                expect2 <= '1';
                
            end if;
        end if;
    end process;


    -- FIFO INTERFACE receive statistics counters
    -- ------------------------------------------
    
    process( ff_rx_clk, reset ) 
    begin
        if( reset='1' ) then

            rx_good_rcvd            <= 0;
            rx_payload_err_rcvd     <= 0;
            rx_wrong_status_rcvd    <= 0;
            rx_length_err_rcvd      <= 0;
            rx_crc_err_rcvd         <= 0;
            rx_fifo_overflow_rcvd   <= 0;
            rx_gmii_err_rcvd        <= 0;
            rx_vlan_rcvd            <= 0;
            rx_stack_vlan_rcvd      <= 0;
            rx_broadcast_rcvd       <= 0;
            rx_wrong_mac_rcvd       <= 0;
            rx_multicast_rcvd       <= 0;
            rx_non_discard_rcvd     <= 0;
            last_err_stat           <= (others => '0' );
            ff_last_length          <= (others => '0' );
            rx_length_mismatch_rcvd <= 0;
            ff_frmlen               <= 0;
            rx_col_rcvd             <= 0 ;
            mff_dst_reg             <= (others=>'0') ;

        elsif( ff_rx_clk='1' and ff_rx_clk'event ) then
        
                mff_dst_reg <= mff_dst ;

          -- count number of bytes received for the frame
          -- --------------------------------------------

             if(ff_rx_sop='1') then
             
                ff_frmlen <= 1;
             
             elsif(ff_rx_dval='1') then
             
                ff_frmlen <= ff_frmlen+1;
             
             end if;
           
             if (mff_frm_rcvd='1' and mff_end_err='0' and TB_MACPADEN=TRUE) then
             
                    mff_rxcnt <= mff_rxcnt+1 ;
                
                    if(mff_payload_err='1') then

                        rx_payload_err_rcvd <= rx_payload_err_rcvd+1;
                      
                    end if;
                    
                  -- verify that the status word length field really matches what we find in the frame
                  -- ---------------------------------------------------------------------------------
                    
                    if( mff_len /= ff_last_length and mff_is_pause='0') then
                        
                        rx_length_mismatch_rcvd <= rx_length_mismatch_rcvd + 1;
                        
                    end if;
                                    
                    if( last_err_stat="0000" ) then -- only good ones
                    
                        if(mff_dst_reg=X"FFFFFFFFFFFF") then
                    
                                rx_broadcast_rcvd <= rx_broadcast_rcvd+1;
                                
                        elsif (ENABLE_SUP_ADDR=0) then
    
                                if(mff_dst_reg(0)='0' and (mac_addr /= mff_dst_reg) ) then  -- unicast but not for me
            
                                        rx_wrong_mac_rcvd <= rx_wrong_mac_rcvd+1;     
                    
                                elsif(mff_dst_reg(0)='1' and mff_is_pause='0') then  -- multicast, but not broadcast
                
                                        rx_multicast_rcvd <= rx_multicast_rcvd + 1;
                
                                end if;
                                
                        else
                        
                                if(mff_dst_reg(0)='0' and mac_addr /= mff_dst_reg and sup_mac_addr_0 /= mff_dst_reg and sup_mac_addr_1 /= mff_dst_reg and sup_mac_addr_2 /= mff_dst_reg and sup_mac_addr_3 /= mff_dst_reg) then  -- unicast but not for me
            
                                        rx_wrong_mac_rcvd <= rx_wrong_mac_rcvd+1;     
                    
                                elsif(mff_dst_reg(0)='1' and mff_is_pause='0') then  -- multicast, but not broadcast
                
                                        rx_multicast_rcvd <= rx_multicast_rcvd + 1;
                
                                end if;
                                
                        end if ;        
                    
                    end if;
                    
             elsif (mff_frm_rcvd='1' and TB_MACPADEN=FALSE) then
             
                        mff_rxcnt <= mff_rxcnt+1 ;                
                    
                  -- verify that the status word length field really matches what we find in the frame
                  -- ---------------------------------------------------------------------------------                   
                                                        
                        if(mff_dst_reg=X"FFFFFFFFFFFF") then
                    
                                rx_broadcast_rcvd <= rx_broadcast_rcvd+1;
    
                        elsif (ENABLE_SUP_ADDR=0) then
    
                                if(mff_dst_reg(0)='0' and (mac_addr /= mff_dst_reg) ) then  -- unicast but not for me
            
                                        rx_wrong_mac_rcvd <= rx_wrong_mac_rcvd+1;     
                    
                                elsif(mff_dst_reg(0)='1' and mff_is_pause='0') then  -- multicast, but not broadcast
                
                                        rx_multicast_rcvd <= rx_multicast_rcvd + 1;
                
                                end if;
                                
                        else
                        
                                if(mff_dst_reg(0)='0' and mac_addr /= mff_dst_reg and sup_mac_addr_0 /= mff_dst_reg and sup_mac_addr_1 /= mff_dst_reg and sup_mac_addr_2 /= mff_dst_reg and sup_mac_addr_3 /= mff_dst_reg) then  -- unicast but not for me
            
                                        rx_wrong_mac_rcvd <= rx_wrong_mac_rcvd+1;     
                    
                                elsif(mff_dst_reg(0)='1' and mff_is_pause='0') then  -- multicast, but not broadcast
                
                                        rx_multicast_rcvd <= rx_multicast_rcvd + 1;
                
                                end if;
                                
                        end if ;                       
                    
             end if;

             -- now check reception of good frames on FIFO interface
             -- (we have no Preamble and CRC there, so do not check these errors on the MFF status)
             
                         
             if( (ff_rx_eop='1' and mff_is_pause='0'and ENABLE_ENA = 8) or 
                  (ff_rx_eop='1' and mff_is_pause='0'and ff_rx_dval = '1' and ff_rx_rdy = '1' and MAX_CHANNELS > 0) ) then           -- good frames should come out
                
                rx_non_discard_rcvd <= rx_non_discard_rcvd +1;
             
                -- remember the length as it was given from the FIFO
             
                ff_last_length  <= ff_rx_err_stat(20 downto 5);

                rx_non_discard_rcvd <= rx_non_discard_rcvd +1;

                last_err_stat( 3 downto 0 ) <= ff_rx_err_stat(3 downto 0);  -- save it for the monitor checks
                
                if( ff_rx_err_stat(3 downto 0) = 0 and mff_is_pause='0') then
                    
                    rx_good_rcvd <= rx_good_rcvd +1 ;
                    
                    if( ff_rx_err_stat(4)='1' and ff_rx_err_stat(22)='0' ) then
            
                        rx_vlan_rcvd <= rx_vlan_rcvd +1;
                        
                    end if;
                    
                    if( ff_rx_err_stat(4)='1' and ff_rx_err_stat(22)='1' ) then
            
                        rx_stack_vlan_rcvd <= rx_stack_vlan_rcvd +1;
                        
                    end if;
                    
                    if(ff_rx_err_stat(21) ='1') then
                    
                        rx_col_rcvd <= rx_col_rcvd+1;
                        
                    end if;
                
                elsif (mff_is_pause='0') then  -- some error occured
                    
                    rx_wrong_status_rcvd <= rx_wrong_status_rcvd+1;
                    
                    if(ff_rx_err_stat(0) ='1' ) then
                    
                        rx_length_err_rcvd <= rx_length_err_rcvd+1;
                        
                    elsif(ff_rx_err_stat(1) ='1') then
                    
                        rx_crc_err_rcvd <= rx_crc_err_rcvd+1;
                    
                    end if;
                        
                    if(ff_rx_err_stat(2) ='1') then
                     
                        rx_fifo_overflow_rcvd <= rx_fifo_overflow_rcvd + 1;                    
                    
                    end if;
                    
                    if(ff_rx_err_stat(3) ='1') then
                    
                        rx_gmii_err_rcvd <= rx_gmii_err_rcvd+1;
                        
                    end if;
                
                end if;
                
             end if;
    
        end if;
        
    end process;

    promis_en <= '1' when TB_PROMIS_ENA else '0' ;

    
   -- Core Statistic Registers
   -- ------------------------
   
        process(reset, reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reset='1') then
                
                        rx_pause_rcvd <= 0 ;
                        
                elsif (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RD_PAUSE_RX and reg_busy='0') then
                        
                                rx_pause_rcvd <= conv_integer(reg_data_out) ;
                                                                                                
                                write(ln, string'("- ---------------------------------------------------------------------------------------- -")) ;
                                writeline(output, ln) ; 
                                write(ln, string'(" ")) ; 
                                writeline(output, ln) ; 
                                write(ln, string'(" Core Statistic Counters")) ;
                                writeline(output, ln) ;
                                write(ln, string'(" ")) ;
                                writeline(output, ln) ; 
                                write(ln, string'("     - Number of Received Pause Frames : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RD_PAUSE_TX and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Transmitted Pause Frames : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_UNICAST and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Unicast Frames : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_MLTCAST and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Multicast Frames : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_BRDCAST and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Broadcast Frames : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=TX_UNICAST and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Transmitted Unicast Frames : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=TX_MLTCAST and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Transmitted Multicast Frames : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=TX_BRDCAST and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Transmitted Broadcast Frames : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=TX_FRM_ERR and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Frames Transmitted with an Error : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                write(ln, string'(" ")) ;
                                writeline(output, ln) ; 
                                write(ln, string'(" RMON Counters")) ;
                                writeline(output, ln) ;
                                write(ln, string'(" ")) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_FRM_ERR and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Frames Received with an Error : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_FRM_DROP and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Frames Dropped Because of FIFO Overflow : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_UNDERSZ_FRM and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Undersized Frames : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_OVERSZ_FRM and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Oversized Frames : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_64_FRM and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received 64-Bytes Frames : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_65_127_FRM and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Frames with Size Between 65 and 127 Bytes : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_128_255_FRM and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Frames with Size Between 128 and 255 Bytes : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_256_511_FRM and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Frames with Size Between 256 and 511 Bytes : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_512_1023_FRM and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Frames with Size Between 512 and 1023 Bytes : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_1024_1518_FRM and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Frames with Size Between 1024 and 1518 Bytes : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_1519_X_FRM and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Frames with Size Between 1519 and Max Frame Length : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_JABBER and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Jabber Frames (Oversize with Wrong CRC) : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_FRAGMENT and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Fragments (Undersized with Wrong CRC) : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RD_SW_RESET and reg_busy='0') then
                        
                                write(ln, string'("- ---------------------------------------------------------------------------------------- -")) ;
                                writeline(output, ln) ;
                                write(ln, string'(" ")) ;
                                write(ln, string'("     ")) ;
                                writeline(output, ln) ;
                        
                                if (reg_data_out(13)='0') then       
                        
                                        
                                        write(ln, string'("   - SW Reset Register Cleared")) ;
                                        writeline(output, ln) ;
                                        
                                else
                                
                                        write(ln, string'("   - Error: SW Reset Register NOT Cleared")) ;
                                        writeline(output, ln) ;
                                        
                                end if ;  
                                
                                if (reg_data_out(0)='0') then       
                        
                                        
                                        write(ln, string'("   - MAC Transmit Disabled")) ;
                                        writeline(output, ln) ;
                                        
                                else
                                
                                        write(ln, string'("   - Error: MAC Transmit NOT Disabled")) ;
                                        writeline(output, ln) ;
                                        
                                end if ;  
                                
                                if (reg_data_out(1)='0') then       
                        
                                        
                                        write(ln, string'("   - MAC Receive Disabled")) ;
                                        writeline(output, ln) ;
                                        
                                else
                                
                                        write(ln, string'("   - Error: MAC Receive NOT Disabled")) ;
                                        writeline(output, ln) ;
                                        
                                end if ;                                                                        
                                
                                write(ln, string'(" ")) ;    
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RD_FRM_TX and reg_busy='0') then
                                                       
                                write(ln, string'("     - Number of Transmitted Correct Frames - With Pause Frames : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RD_FRM_RX and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Correct Frames - With Pause Frames : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RD_CRC_ERR and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Frames Received with CRC Error : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RD_ALIGN_ERR and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Frames Received with an Alignment Error : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RD_TX_OCTETS and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Transmitted Octets : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RD_RX_OCTETS and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Octets : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;

    -- Frames that should be discarded
    -- -------------------------------
    
        process( rx_clk, reset ) 
        begin
        
                if( reset='1' ) then
        
                        rx_discard_sent <= 0;
                        rx_discard_rcvd <= 0;
            
                elsif( rx_clk='1' and rx_clk'event ) then

                        if( ff_tx_sop='1' ) then
            
                                if(((ff_dst(0)='0') and (ff_dst /= mac_addr and ff_dst /= sup_mac_addr_0 and ff_dst /= sup_mac_addr_1 and ff_dst /= sup_mac_addr_2 and ff_dst /= sup_mac_addr_3) and promis_en='0') or  -- invalid unicast mac address ?
                                   ((ff_dst(0)='1') and multicast_wrong and promis_en='0' and ff_dst/=X"FFFFFFFFFFFF" ) or
                                    (ff_prmbl_err='1') ) then
                    
                                        rx_discard_sent <= rx_discard_sent + 1;
                    
                                end if;

                        end if;
                            
                        rx_discard_rcvd <= rxframe_cnt - rx_non_discard_rcvd;

                end if;
    
        end process;

    -- Block RX FIFO Read
    -- ------------------

        ff_rx_rdy <= '0' when (stop_rx_fifo_read='1' and rx_hold_cnt < TB_HOLDREAD) else '1';

        process( ff_rx_clk, reset ) 
        begin
        
                if( reset='1' ) then

                        stop_rx_fifo_read <= '0';
                        rx_hold_cnt       <= 0;
                        rx_fifo_cnt       <= 0;
            
                elsif( ff_rx_clk='1' and ff_rx_clk'event ) then
        
                        if( ff_rx_sop='1' ) then
            
                                rx_fifo_cnt <= rx_fifo_cnt+1;     -- count each Frame read from the FIFO
                
                        end if;
        
                        if( TB_STOPREAD/=0 and TB_STOPREAD<rx_fifo_cnt and stop_rx_fifo_read='0')  then
            
                                stop_rx_fifo_read <= '1';
                
                        end if;
            
                        if( stop_rx_fifo_read='1' and rx_hold_cnt<TB_HOLDREAD ) then
            
                                rx_hold_cnt <= rx_hold_cnt + 1;
                
                        end if;

                end if;
    
        end process;
                            
   -- Control State Machine
   -- ---------------------
   
        process(reset, reg_clk)
        begin
        
                if (reset='1') then
                
                        state <= IDLE ;
                        
                elsif (reg_clk='1') and (reg_clk'event) then
                
                        state <= nextstate ;
                        
                end if ;
                
        end process ;
        
        process(state,sim_start, reg_busy, lut_prog_cnt, txsim_done, ff_rx_dsav, gm_tx_en, sim_cnt_end, reg_wakeup, gm_ether_gen_done)
        begin
        
                case state is
                
                        when IDLE =>
                        
                                if (sim_start='1' ) then
                                
                                nextstate <= pcs_read_ver ;

                                else
                                
                                        nextstate <= IDLE ;
                                        
                                end if ;

-- PCS related

                        when pcs_read_ver =>
      
                                if ((reg_busy='0' and reg_busy'event)) then
         
                                        nextstate <= pcs_wr_scratch;   
         
                                else
         
                                        nextstate <= pcs_read_ver;   
         
                                end if ;
                        
                        when pcs_wr_scratch =>
      
                                if ((reg_busy='0' and reg_busy'event)) then
         
                                        nextstate <= pcs_rd_scratch;   
         
                                else
         
                                        nextstate <= pcs_wr_scratch;   
                                
                                end if ;
      
                        when pcs_rd_scratch =>
      
                                if ((reg_busy='0' and reg_busy'event)) then
         
                                        nextstate <= pcs_if_control;   
         
                                else
         
                                        nextstate <= pcs_rd_scratch;   
         
                                end if ;
                        
                        when pcs_if_control =>
      
                                if ((reg_busy='0' and reg_busy'event)) then         
         
                                        nextstate <= pcs_wait_link; 
                                          
         
                                else
         
                                        nextstate <= pcs_if_control;   
         
                                end if ;
                        
                        when pcs_wait_link =>
      
                                if (led_link = '1') then
         
                                        nextstate <= pcs_read_phy_control;   
         
                                else
         
                                        nextstate <= pcs_wait_link;   
         
                                end if;
                                
                        when pcs_read_phy_control =>
      
                                if ((reg_busy='0' and reg_busy'event)) then
         
                                        nextstate <= pcs_read_sync_status;   
         
                                else
         
                                        nextstate <= pcs_read_phy_control;   
         
                                end if ;
                        
                        when pcs_read_sync_status =>
      
                                if ((reg_busy='0' and reg_busy'event)) then
         
                                        if (tb_ena_autoneg) then
            
                                                nextstate <= pcs_prog_ability;   
            
                                        else
            
                                                nextstate <= pcs_autoneg_disable;   
            
                                        end if ;
         
                                else
         
                                        nextstate <= pcs_read_sync_status;   
         
                                end if ;
      
                        when pcs_autoneg_disable =>
      
                                if ((reg_busy='0' and reg_busy'event)) then
             if (ENABLE_ENA = 8) then
                nextstate <= READ_VER;  
             else
              --multi-port fifoless
                                      reg_iteration := reg_iteration + 1;
                 if (MAX_CHANNELS = reg_iteration) then
                                        nextstate <= READ_VER;   
                                        reg_iteration := 0;
                 else
                   nextstate <= pcs_autoneg_disable;
                 end if; 
               end if;
         
                                else
         
                                        nextstate <= pcs_autoneg_disable;   
         
                                end if ;


                                
-- MAC related
                                
                        when READ_VER =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_SCRATCH ;
                                        
                                else
                                
                                        nextstate <= READ_VER ;
                                        
                                end if ;
                                
                        when WR_SCRATCH =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RD_SCRATCH ;
                                        
                                else
                                
                                        nextstate <= WR_SCRATCH ;
                                        
                                end if ;
                                
                        when RD_SCRATCH =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= MAC_CONFIG ;
                                        
                                else
                                
                                        nextstate <= RD_SCRATCH ;
                                        
                                end if ; 

                        when MAC_CONFIG =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                     if (ENABLE_ENA = 8) then
                                        nextstate <= WR_MAC1 ;
                                     else
                                        
                                       --multi-port fifoless
                                        reg_iteration := reg_iteration + 1;
                                        if (MAX_CHANNELS = reg_iteration) then
                                            nextstate <= WR_IPG_LEN;
                                        else
                                            nextstate <= MAC_CONFIG;
                                        end if;
                                      end if;
                                else
                                
                                        nextstate <= MAC_CONFIG ;
                                        
                                end if ; 
                                
                        when WR_MAC1 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_MAC2 ;
                                        
                                else
                                
                                        nextstate <= WR_MAC1 ;
                                        
                                end if ; 
                                
                        when WR_MAC2 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_IPG_LEN ;
                                        
                                else
                                
                                        nextstate <= WR_MAC2 ;
                                        
                                end if ; 
                                
                        when WR_IPG_LEN =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_FRM_LENGTH ;
                                        
                                else
                                
                                        nextstate <= WR_IPG_LEN ;
                                        
                                end if ; 
                                
                        when WR_FRM_LENGTH =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_PAUSE_QUANTA ;
                                        
                                else
                                
                                        nextstate <= WR_FRM_LENGTH ;
                                        
                                end if ;
                                
                        when WR_PAUSE_QUANTA =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        if (ENABLE_ENA = 0) then
                                           nextstate <= SIM ;
                                        else
                                           nextstate <= WR_RX_SE ;
                                        end if ;
                                        
                                else
                                
                                        nextstate <= WR_PAUSE_QUANTA ;
                                        
                                end if ; 
                                
                        when WR_RX_SE =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_RX_SF ;
                                        
                                else
                                
                                        nextstate <= WR_RX_SE ;
                                        
                                end if ; 
                                
                        when WR_RX_SF =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_TX_SE ;
                                        
                                else
                                
                                        nextstate <= WR_RX_SF ;
                                        
                                end if ; 
                                
                        when WR_TX_SE =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_TX_SF ;
                                        
                                else
                                
                                        nextstate <= WR_TX_SE ;
                                        
                                end if ;
                                
                        when WR_TX_SF =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_RX_AE ;
                                        
                                else
                                
                                        nextstate <= WR_TX_SF ;
                                        
                                end if ;
                                
                        when WR_RX_AE =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_RX_AF ;
                                        
                                else
                                
                                        nextstate <= WR_RX_AE ;
                                        
                                end if ;  
                                
                        when WR_RX_AF =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_TX_AE ;
                                        
                                else
                                
                                        nextstate <= WR_RX_AF ;
                                        
                                end if ; 
                                
                        when WR_TX_AE =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_TX_AF ;
                                        
                                else
                                
                                        nextstate <= WR_TX_AE ;
                                        
                                end if ; 
                                
                        when WR_TX_AF =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        if (TB_MDIO_SIMULATION=TRUE and ENABLE_MDIO = 1) then
                                
                                                nextstate <= WR_MDIO_ADDR1 ;
                                                
                                        else
                                        
                                                nextstate <= LUT_PROG_INC ;
                                                
                                        end if ;
                                        
                                else
                                
                                        nextstate <= WR_TX_AF ;
                                        
                                end if ;           
                                
                        when WR_MDIO_ADDR1 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WRITE_MDIO1 ;
                                        
                                else
                                
                                        nextstate <= WR_MDIO_ADDR1 ;
                                        
                                end if ;                                                              
                                
                        when WRITE_MDIO1 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= READ_MDIO1 ;
                                        
                                else
                                
                                        nextstate <= WRITE_MDIO1 ;
                                        
                                end if ;
                                
                        when READ_MDIO1 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= LUT_PROG ;
                                        
                                else
                                
                                        nextstate <= READ_MDIO1 ;
                                        
                                end if ;
                                
                        when LUT_PROG_INC =>
                        
                                if (lut_prog_cnt=MCAST_TABLEN-1) then
                                
                                        if (ENABLE_SUP_ADDR=1) then
                                        
                                                nextstate <= WR_SUP_MAC0_0 ;
                                                
                                        else
                                
                                                nextstate <= SIM ;
                                                
                                        end if ;
                                        
                                else
                                
                                        nextstate <= LUT_PROG ;
                                        
                                end if ;
                                
                        when WR_SUP_MAC0_0 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_SUP_MAC0_1 ;
                                        
                                else
                                
                                        nextstate <= WR_SUP_MAC0_0 ;
                                        
                                end if ;
                                
                        when WR_SUP_MAC0_1 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_SUP_MAC1_0 ;
                                        
                                else
                                
                                        nextstate <= WR_SUP_MAC0_1 ;
                                        
                                end if ;
                        
                        when WR_SUP_MAC1_0 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_SUP_MAC1_1 ;
                                        
                                else
                                
                                        nextstate <= WR_SUP_MAC1_0 ;
                                        
                                end if ; 
                                
                        when WR_SUP_MAC1_1 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_SUP_MAC2_0 ;
                                        
                                else
                                
                                        nextstate <= WR_SUP_MAC1_1 ;
                                        
                                end if ; 
                                
                        when WR_SUP_MAC2_0 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_SUP_MAC2_1 ;
                                        
                                else
                                
                                        nextstate <= WR_SUP_MAC2_0 ; 
                                        
                                end if ;
                                
                        when WR_SUP_MAC2_1 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_SUP_MAC3_0 ;
                                        
                                else
                                
                                        nextstate <= WR_SUP_MAC2_1 ; 
                                        
                                end if ;
                                        
                        when WR_SUP_MAC3_0 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_SUP_MAC3_1 ;
                                        
                                else
                                
                                        nextstate <= WR_SUP_MAC3_0 ; 
                                        
                                end if ;
                                
                        when WR_SUP_MAC3_1 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= SIM ;
                                        
                                else
                                
                                        nextstate <= WR_SUP_MAC3_1 ; 
                                        
                                end if ;        
                                
                        when LUT_PROG =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= LUT_PROG_INC ;
                                        
                                else
                                
                                        nextstate <= LUT_PROG ;
                                        
                                end if ;
                                
                        when SIM =>
                        
                                if (txsim_done='1' and ff_rx_dsav/='1') then
                                
                                        nextstate <= END_SIM_WAIT;
                                        
                                else
                        
                                        nextstate <= SIM ;
                                        
                                end if ;
                                
                        when END_SIM_WAIT =>
                        
                                if (sim_cnt_end > 1000) then
                                
                                        nextstate <= RD_PAUSE_RX ;
                                                                                                                                                                                                                        
                                else
                                
                                        nextstate <= END_SIM_WAIT ;
                                        
                                end if ; 
                                
                        when RD_PAUSE_RX =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RD_FRM_TX ;
                                                                        
                                else
                                
                                        nextstate <= RD_PAUSE_RX ;
                                        
                                end if ; 
                                
                        when RD_FRM_TX =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RD_FRM_RX ;
                                        
                                else
                                
                                        nextstate <= RD_FRM_TX ;
                                        
                                end if ;
                                
                        when RD_FRM_RX =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RD_CRC_ERR ;
                                        
                                else
                                
                                        nextstate <= RD_FRM_RX ;
                                        
                                end if ;
                                
                        when RD_CRC_ERR =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RD_TX_OCTETS ;
                                        
                                else
                                
                                        nextstate <= RD_CRC_ERR ;
                                        
                                end if ;
                                
                        when RD_TX_OCTETS =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RD_RX_OCTETS ;
                                        
                                else
                                
                                        nextstate <= RD_TX_OCTETS ;
                                        
                                end if ;
                                
                        when RD_RX_OCTETS =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RD_ALIGN_ERR ;
                                        
                                else
                                
                                        nextstate <= RD_RX_OCTETS ;
                                        
                                end if ;
                                
                        when RD_ALIGN_ERR =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RD_PAUSE_TX ;
                                        
                                else
                                
                                        nextstate <= RD_ALIGN_ERR ;
                                        
                                end if ;
                                
                        when RD_PAUSE_TX =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_UNICAST ;
                                        
                                else
                                
                                        nextstate <= RD_PAUSE_TX ;
                                        
                                end if ;
                                
                        when RX_UNICAST =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_MLTCAST ;
                                        
                                else
                                
                                        nextstate <= RX_UNICAST ;
                                        
                                end if ;
                                
                        when RX_MLTCAST =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_BRDCAST ;
                                        
                                else
                                
                                        nextstate <= RX_MLTCAST ;
                                        
                                end if ;
                                
                        when RX_BRDCAST =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= TX_FRM_DISCARD ;
                                        
                                else
                                
                                        nextstate <= RX_BRDCAST ;
                                        
                                end if ;
                                
                        when TX_FRM_DISCARD =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= TX_UNICAST ;
                                        
                                else
                                
                                        nextstate <= TX_FRM_DISCARD ;
                                        
                                end if ;
                                
                        when TX_UNICAST =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= TX_MLTCAST ;
                                        
                                else
                                
                                        nextstate <= TX_UNICAST ;
                                        
                                end if ;
                                
                        when TX_MLTCAST =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= TX_BRDCAST ;
                                        
                                else
                                
                                        nextstate <= TX_MLTCAST ;
                                        
                                end if ;
                                
                        when TX_BRDCAST =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_FRM_ERR ;
                                        
                                else
                                
                                        nextstate <= TX_BRDCAST ;
                                        
                                end if ;
                                
                        when RX_FRM_ERR =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= TX_FRM_ERR ;
                                        
                                else
                                
                                        nextstate <= RX_FRM_ERR ;
                                        
                                end if ;
                                
                        when TX_FRM_ERR =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_FRM_DROP ;
                                        
                                else
                                
                                        nextstate <= TX_FRM_ERR ;
                                        
                                end if ;
                                
                        when RX_FRM_DROP =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_UNDERSZ_FRM ;
                                        
                                else
                                
                                        nextstate <= RX_FRM_DROP ;
                                        
                                end if ;
                                
                        when RX_UNDERSZ_FRM =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_OVERSZ_FRM ;
                                        
                                else
                                
                                        nextstate <= RX_UNDERSZ_FRM ;
                                        
                                end if ;
                                
                        when RX_OVERSZ_FRM =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_64_FRM ;
                                        
                                else
                                
                                        nextstate <= RX_OVERSZ_FRM ;
                                        
                                end if ;
                                
                        when RX_64_FRM =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_65_127_FRM ;
                                        
                                else
                                
                                        nextstate <= RX_64_FRM ;
                                        
                                end if ;
                                
                        when RX_65_127_FRM =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_128_255_FRM ;
                                        
                                else
                                
                                        nextstate <= RX_65_127_FRM ;
                                        
                                end if ;
                                
                        when RX_128_255_FRM =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_256_511_FRM ;
                                        
                                else
                                
                                        nextstate <= RX_128_255_FRM ;
                                        
                                end if ;
                                
                        when RX_256_511_FRM =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_512_1023_FRM ;
                                        
                                else
                                
                                        nextstate <= RX_256_511_FRM ;
                                        
                                end if ;
                                
                        when RX_512_1023_FRM =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_1024_1518_FRM ;
                                        
                                else
                                
                                        nextstate <= RX_512_1023_FRM ;
                                        
                                end if ;
                                
                        when RX_1024_1518_FRM =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_1519_X_FRM ;
                                        
                                else
                                
                                        nextstate <= RX_1024_1518_FRM ;
                                        
                                end if ;
                                
                        when RX_1519_X_FRM =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_JABBER ;
                                        
                                else
                                
                                        nextstate <= RX_1519_X_FRM ;
                                        
                                end if ;   
                                
                        when RX_JABBER =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_FRAGMENT ;
                                        
                                else
                                
                                        nextstate <= RX_JABBER ;
                                        
                                end if ;
                                
                        when RX_FRAGMENT =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        if (re_read_ena=TRUE) then
                                        
                                                nextstate <= RD_SW_RESET ;
                                                
                                        else
                                
                                                nextstate   <= SW_RESET ;
                                                re_read_ena <= TRUE ;
                                                
                                        end if ; 
                                                                                                                        
                                else
                                
                                        nextstate   <= RX_FRAGMENT ;
                                        
                                end if ;
                                
                        when SW_RESET =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <=  RD_PAUSE_RX;
                                                                                        
                                else
                                
                                        nextstate   <=  SW_RESET;
                                                                                        
                                end if ;
-- This testbench was architectured by default to work in a loopback mode (TB_RXFRAMES=0). 
-- Due to that factor, the existing testbench could not be used to test MAGIC PACKET DETECTION 
-- because if the MAC is put to sleep then the transmit engine of the MAC will be disabled. 
-- This will break the loopback mechanism and also the testbench flow.                                       
                        when RD_SW_RESET =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        if (ENA_MAGIC=TRUE and TB_RXFRAMES/=0) then
                                        
                                                nextstate <= WR_ENA_MAGIC ;
                                                
                                        else
                                
                                                nextstate <= END_SIM ;
                                                
                                        end if ;
                                        
                                else
                                
                                        nextstate <= RD_SW_RESET ;
                                        
                                end if ;
                                
                        when WR_ENA_MAGIC =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= NODE_SLEEP1 ;
                                                                                        
                                else
                                
                                        nextstate   <= WR_ENA_MAGIC ;
                                                                                        
                                end if ; 
                                
                        when NODE_SLEEP1 =>
                        
                                if (sim_cnt_end=50) then
                                
                                        nextstate <= GEN_MAGIC ;
                                        
                                else
                                
                                        nextstate <= NODE_SLEEP1 ;
                                        
                                end if ;
                                
                        when GEN_MAGIC =>
                        
                                if (gm_ether_gen_done='0') then
                        
                                        nextstate <= NODE_SLEEP2 ;
                                        
                                else
                                
                                        nextstate <= GEN_MAGIC ;
                                        
                                end if ;
                                
                        when NODE_SLEEP2 => 
                        
                                if (reg_wakeup='1') then
                                
                                        nextstate <= NODE_ON ;
                                        
                                else
                                
                                        nextstate <= NODE_SLEEP2 ;
                                        
                                end if ;
                                
                        when NODE_ON =>
                        
                                if (ENA_SLEEP_PIN) then
                                
                                        if (reg_wakeup='0') then
                                        
                                                nextstate <= END_SIM ;
                                                
                                        else
                                        
                                                nextstate <= NODE_ON ;
                                                
                                        end if ;
                                        
                                else
                                
                                        if (reg_busy='0' and reg_busy'event) then
                                
                                                nextstate <= END_SIM ;
                                                                                        
                                        else
                                
                                                nextstate   <= END_SIM1 ;
                                                                                        
                                        end if ;         
                                        
                                end if ; 
                                
                        when END_SIM1 =>
                        
                                if (reg_wakeup='0') then
                                        
                                        nextstate <= END_SIM ;
                                                
                                else
                                        
                                        nextstate <= END_SIM1 ;
                                                
                                end if ;
                                                                                
                        when END_SIM =>
                        
                                nextstate <= END_SIM ;                                                        
                                
                        when others  =>
                                                                                     
                                nextstate <= IDLE ;
                end case ;
                
        end process ;
        
   -- End of Simulation Delay
   -- -----------------------
   
        process(reset, reg_clk)
        begin
        
                if (reset='1') then
                
                        sim_cnt_end <= 0 ;
                        
                elsif (reg_clk='1') and (reg_clk'event) then
                
                        if (nextstate=NODE_SLEEP1) then
                        
                                sim_cnt_end <= sim_cnt_end+1 ;       
                
                        elsif (nextstate=END_SIM_WAIT) then
                        
                                sim_cnt_end <= sim_cnt_end+1 ;
                                
                        else
                        
                                sim_cnt_end <= 0 ;        
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
   -- LUT Table Address and PHY Port Counter
   -- --------------------------------------
   
        process(reset, reg_clk)
        begin
        
                if (reset='1') then
                
                        lut_prog_cnt <= 0 ;
                        
                elsif (reg_clk='1') and (reg_clk'event) then
                
                        if (state=LUT_PROG_INC) then
                        
                                lut_prog_cnt <= lut_prog_cnt+1 ;      
                                                                        
                        end if ;
                        
                end if ;
                
        end process ;
        
    -- Register Interface
    -- ------------------
    
        process
        begin
        
                reg_clk <= '1' ;
                wait for 25 ns ;
                reg_clk <= '0' ;
                wait for 25 ns ;
                
        end process ;
        
        process(reset, reg_clk)
        
                variable hash_code  : std_logic_vector(5 downto 0) ;
                variable mcast_addr : std_logic_vector(47 downto 0) ;
        
        begin
        
                if (reset='1') then
                
                        reg_wr      <= '0' ;
                        reg_rd      <= '0' ;
                        reg_addr    <= (others=>'0') ;
                        reg_data_in <= (others=>'0') ;
                        
                elsif (reg_clk='1') and (reg_clk'event) then
        
--PCS  registers programming

                    if (nextstate=pcs_read_ver) then

                            reg_addr    <= conv_std_logic_vector(145, 14);   
                            reg_rd      <= '1';   
                            reg_wr      <= '0';   
                            reg_data_in <= (others=>'0');   

                    elsif (nextstate=pcs_if_control ) then

                            reg_addr  <= conv_std_logic_vector(148, 14);   
                            reg_rd    <= '0';   
                            reg_wr    <= '1';  

                            if (tb_sgmii_ena=TRUE) then

                                    reg_data_in(0) <= '1';
           
                            else

                                    reg_data_in(0) <= '0';

                            end if ;

                            if (tb_sgmii_auto_conf=TRUE) then       

                                    reg_data_in(1) <= '1';        

                            else

                                    reg_data_in(1) <= '0';

                            end if ;

                            if (tb_sgmii_auto_conf=TRUE) then

                                    reg_data_in(3 downto 2) <= "00";

                            elsif (tb_sgmii_1000=TRUE) then  

                                    reg_data_in(3 downto 2) <= "10";
           
                            elsif (tb_sgmii_100=TRUE) then       

                                    reg_data_in(3 downto 2) <= "01";        

                            else       

                                    reg_data_in(3 downto 2) <= "00";        
                           
                            end if ;

                            if (tb_sgmii_hd=TRUE) then       

                                    reg_data_in(4) <= '1';
            
                            else

                                    reg_data_in(4) <= '0';
            
                            end if ;

                            reg_data_in(31 downto 5) <= (others=>'0');   

                    elsif (nextstate=pcs_wr_scratch) then

                            reg_addr    <= conv_std_logic_vector(144, 14);   
                            reg_rd      <= '0';   
                            reg_wr      <= '1';   
                            reg_data_in <= X"0000AAAA";   

                    elsif (nextstate=pcs_rd_scratch ) then

                            reg_addr    <= conv_std_logic_vector(144, 14);   
                            reg_rd      <= '1';   
                            reg_wr      <= '0';   
                            reg_data_in <= (others=>'0');   

                    elsif (nextstate=pcs_read_sync_status or nextstate = pcs_read_status or 
                           nextstate = pcs_read_status_2 ) then

                            reg_addr    <= conv_std_logic_vector(129, 14);   
                            reg_rd      <= '1';   
                            reg_wr      <= '0';   
                            reg_data_in <= (others=>'0');   

                    elsif (nextstate=pcs_read_phy_control ) then

                            reg_addr     <= conv_std_logic_vector(128, 14);   
                            reg_rd       <= '1';   
                            reg_wr       <= '0';   
                            reg_data_in  <= (others=>'0');   

                    elsif (nextstate=pcs_autoneg_disable ) then

                            reg_addr    <= conv_std_logic_vector((128+(256 * reg_iteration)), 14);   
                            reg_rd      <= '0';   
                            reg_wr      <= '1';   
                            reg_data_in <= X"0000" & "0000000000000000";   

-- MAC register programming
        
                        elsif (nextstate=READ_VER) then
                
                                reg_wr      <= '0' after 5 ns ;
                                reg_rd      <= '1' after 5 ns ;
                                reg_addr    <= conv_std_logic_vector(0, 14) after 5 ns;
                                reg_data_in <= (others=>'0') after 5 ns; 
                        
                        elsif (nextstate=WR_SCRATCH) then
                
                                reg_wr      <= '1' after 5 ns;
                                reg_rd      <= '0' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(1, 14) after 5 ns;
                                reg_data_in <= X"AAAAAAAA" after 5 ns;
                        
                        elsif (nextstate=RD_SCRATCH) then
                
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(1, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns; 
                                
                        elsif (nextstate=MAC_CONFIG or nextstate=WR_ENA_MAGIC or (nextstate=NODE_ON and ENA_SLEEP_PIN=FALSE)) then
                
                                reg_wr      <= '1' after 5 ns;
                                reg_rd      <= '0' after 5 ns;
                                reg_addr    <= conv_std_logic_vector((2 +(256 * reg_iteration)), 14) after 5 ns;
                                reg_data_in <= (others=>'0') ;
                                
                           -- Enable Tx and Rx
                           -- ----------------
                           
                                reg_data_in(0) <= '1' after 5 ns;
                                reg_data_in(1) <= '1' after 5 ns;

                           -- XON_Gen
                                reg_data_in(2) <= xon_gen after 5 ns;
                                
                           -- Speed Selection
                           -- ---------------
                                
                                if (ETH_MODE=1000) then
                                
                                        reg_data_in(3) <= '1' after 5 ns;
                                        
                                else
                                
                                        reg_data_in(3) <= '0' after 5 ns;
                                        
                                end if ;
                                
                                
                           -- Unicast Filtering
                           -- -----------------
                           
                                if (TB_PROMIS_ENA=TRUE) then
                                
                                        reg_data_in(4) <= '1' after 5 ns;
                                        
                                else
                                
                                        reg_data_in(4) <= '0' after 5 ns;
                                        
                                end if ;
                                
                           -- Enable Padding
                           -- --------------
                           
                                if (TB_MACPADEN=TRUE) then
                                
                                        reg_data_in(5) <= '1' after 5 ns;
                                        
                                else
                                
                                        reg_data_in(5) <= '0' after 5 ns;
                                        
                                end if ;
                                
                           -- CRC Forwarding Enable
                           -- ---------------------
                           
                                if (TB_MACFWDCRC=TRUE) then
                                
                                        reg_data_in(6) <= '1' after 5 ns;
                                        
                                else
                                
                                        reg_data_in(6) <= '0' after 5 ns;
                                        
                                end if ;
                                
                           -- Enable Pause Frame Forwarding
                           -- -----------------------------
                           
                                if (TB_MACFWD_PAUSE=TRUE) then 
                                
                                        reg_data_in(7) <= '1' after 5 ns;
                                        
                                else
                                
                                        reg_data_in(7) <= '0' after 5 ns;
                                        
                                end if ;
                                
                           -- Ignore Pause Frames
                           -- -------------------
                           
                                if (TB_MACIGNORE_PAUSE=TRUE) then
                                
                                        reg_data_in(8) <= '1' after 5 ns;
                                        
                                else
                                
                                        reg_data_in(8) <= '0' after 5 ns;
                                        
                                end if ;
                                
                           -- Source MAC Address Insertion
                           -- ----------------------------
                           
                                if (TB_MACINSERT_ADDR=TRUE) then
                                
                                        reg_data_in(9) <= '1' after 5 ns;
                                        
                                else
                                
                                        reg_data_in(9) <= '0' after 5 ns;
                                        
                                end if ;

                                
                           -- Enable Half Duplex
                           -- ------------------
                                
                                if (HD_ENA=TRUE and ENABLE_HD_LOGIC=1) then
                                        
                                        reg_data_in(10) <= '1' after 5 ns;
                                        
                                else
                                
                                        reg_data_in(10) <= '0' after 5 ns;
                                        
                                end if ; 
                                
                           -- Internal Loopback
                           -- -----------------
                                
                                if (ENABLE_GMII_LOOPBACK=1 and TB_RXFRAMES=0) then
                                        
                                        reg_data_in(15) <= '1' after 5 ns;
                                        
                                else
                                
                                        reg_data_in(15) <= '0' after 5 ns;
                                        
                                end if ;  
                                
                           -- Source MAC Address Selection 
                           -- -----------------------------
                           
                                if (ENABLE_SUP_ADDR=1) then
                                        
                                        reg_data_in(18 downto 16) <= conv_std_logic_vector(TB_ADDR_SEL, 3) after 5 ns;
                                        
                                else
                                
                                        reg_data_in(18 downto 16) <= "000" after 5 ns;
                                        
                                end if ;   
                                
                                reg_data_in(14) <= '0' ;
                                
                           -- Magic Packet Enable
                           -- -------------------
                                
                                if (ENA_MAGIC=TRUE and ENABLE_MAGIC_DETECT=1) then
                                
                                        reg_data_in(19) <= '1' ;
                                        
                                else
                                
                                        reg_data_in(19) <= '0' ;
                                        
                                end if ;
                                
                                if (nextstate=WR_ENA_MAGIC and ENA_SLEEP_PIN=FALSE) then
                                
                                        reg_data_in(20) <= '1' ;
                                        
                                else
                                
                                        reg_data_in(20) <= '0' ;
                                        
                                end if ;
                                
                                reg_data_in(21) <= '0' ; 
                                
                           -- XOFF_Gen
                                reg_data_in(22) <= xoff_gen after 5 ns;

                           -- 10Mbps Speed Selection
                           -- ---------------
                           
                                if (ETH_MODE=10) then
                                
                                        reg_data_in(25) <= '1' after 5 ns;
                                        
                                else
                                
                                        reg_data_in(25) <= '0' after 5 ns;
                                        
                                end if ;                                                                                  
                                
                   -- Discard any errored in received frames
                           -- ---------------
                           
                                if (TB_MACRX_ERR_DISC=1) then
                                
                                        reg_data_in(26) <= '1' after 5 ns;
                                        
                                else
                                
                                        reg_data_in(26) <= '0' after 5 ns;
                                        
                                end if ;                                                                                  
                                
                        elsif (nextstate=WR_MAC1) then
                        
                                reg_wr      <= '1' after 5 ns;
                                reg_rd      <= '0' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(3, 14) after 5 ns;
                                reg_data_in <= mac_addr(31 downto 0) after 5 ns;
                                
                        elsif (nextstate=WR_MAC2) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(4, 14) after 5 ns;
                                reg_data_in(15 downto 0)  <= mac_addr(47 downto 32) after 5 ns; 
                                reg_data_in(31 downto 16) <= (others=>'0') after 5 ns;
                                
                        elsif (nextstate=WR_IPG_LEN) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(23, 14) after 5 ns;
                                reg_data_in(15 downto 0)  <= conv_std_logic_vector(TB_IPG_LENGTH, 16) after 5 ns; 
                                reg_data_in(31 downto 16) <= (others=>'0') after 5 ns; 
                                
                        elsif (nextstate=WR_SUP_MAC0_0) then
                        
                                reg_wr      <= '1' after 5 ns;
                                reg_rd      <= '0' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(192, 14) after 5 ns;
                                reg_data_in <= sup_mac_addr_0(31 downto 0)   after 5 ns;
                                
                        elsif (nextstate=WR_SUP_MAC0_1) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(193, 14) after 5 ns;
                                reg_data_in(15 downto 0)  <= sup_mac_addr_0(47 downto 32) after 5 ns; 
                                reg_data_in(31 downto 16) <= (others=>'0') after 5 ns;
                                
                        elsif (nextstate=WR_SUP_MAC1_0) then
                        
                                reg_wr      <= '1' after 5 ns;
                                reg_rd      <= '0' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(194, 14) after 5 ns;
                                reg_data_in <= sup_mac_addr_1(31 downto 0)   after 5 ns;
                                
                        elsif (nextstate=WR_SUP_MAC1_1) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(195, 14) after 5 ns;
                                reg_data_in(15 downto 0)  <= sup_mac_addr_1(47 downto 32) after 5 ns; 
                                reg_data_in(31 downto 16) <= (others=>'0') after 5 ns;
                                
                        elsif (nextstate=WR_SUP_MAC2_0) then
                        
                                reg_wr      <= '1' after 5 ns;
                                reg_rd      <= '0' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(196, 14) after 5 ns;
                                reg_data_in <= sup_mac_addr_2(31 downto 0)   after 5 ns;
                                
                        elsif (nextstate=WR_SUP_MAC2_1) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(197, 14) after 5 ns;
                                reg_data_in(15 downto 0)  <= sup_mac_addr_2(47 downto 32) after 5 ns; 
                                reg_data_in(31 downto 16) <= (others=>'0') after 5 ns;
                                
                        elsif (nextstate=WR_SUP_MAC3_0) then
                        
                                reg_wr      <= '1' after 5 ns;
                                reg_rd      <= '0' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(198, 14) after 5 ns;
                                reg_data_in <= sup_mac_addr_3(31 downto 0)   after 5 ns;
                                
                        elsif (nextstate=WR_SUP_MAC3_1) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(199, 14) after 5 ns;
                                reg_data_in(15 downto 0)  <= sup_mac_addr_3(47 downto 32) after 5 ns; 
                                reg_data_in(31 downto 16) <= (others=>'0') after 5 ns;
                                
                        elsif (nextstate=WR_FRM_LENGTH) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(5, 14) after 5 ns;
                                reg_data_in(15 downto 0)  <= conv_std_logic_vector(TB_MACLENMAX, 16) after 5 ns; 
                                reg_data_in(31 downto 16) <= (others=>'0') after 5 ns;  
                                
                        elsif (nextstate=WR_PAUSE_QUANTA) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(6, 14) after 5 ns;
                                reg_data_in(15 downto 0)  <= conv_std_logic_vector(TB_MACPAUSEQ, 16) after 5 ns; 
                                reg_data_in(31 downto 16) <= (others=>'0') after 5 ns; 
                                
                        elsif (nextstate=WR_RX_SE) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(7, 14) after 5 ns;
                                reg_data_in               <= conv_std_logic_vector(RX_FIFO_SECTION_EMPTY, 32) after 5 ns; 
                                
                        elsif (nextstate=WR_RX_SF) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(8, 14) after 5 ns;
                                reg_data_in               <= conv_std_logic_vector(RX_FIFO_SECTION_FULL, 32) after 5 ns;
                                
                        elsif (nextstate=WR_TX_SE) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(9, 14) after 5 ns;
                                reg_data_in               <= conv_std_logic_vector(TX_FIFO_SECTION_EMPTY, 32) after 5 ns; 
                                
                        elsif (nextstate=WR_TX_SF) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(10, 14) after 5 ns;
                                reg_data_in               <= conv_std_logic_vector(TX_FIFO_SECTION_FULL, 32) after 5 ns;
                                
                        elsif (nextstate=WR_RX_AE) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(11, 14) after 5 ns;
                                reg_data_in(15 downto 0)  <= conv_std_logic_vector(RX_FIFO_AE, 16) after 5 ns; 
                                reg_data_in(31 downto 16) <= (others=>'0') after 5 ns;
                                
                        elsif (nextstate=WR_RX_AF) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(12, 14) after 5 ns;
                                reg_data_in(15 downto 0)  <= conv_std_logic_vector(RX_FIFO_AF, 16) after 5 ns; 
                                reg_data_in(31 downto 16) <= (others=>'0') after 5 ns;
                                
                        elsif (nextstate=WR_TX_AE) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(13, 14) after 5 ns;
                                reg_data_in(15 downto 0)  <= conv_std_logic_vector(TX_FIFO_AE, 16) after 5 ns; 
                                reg_data_in(31 downto 16) <= (others=>'0') after 5 ns;
                                
                        elsif (nextstate=WR_TX_AF) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(14, 14) after 5 ns;
                                reg_data_in(15 downto 0)  <= conv_std_logic_vector(TX_FIFO_AF, 16) after 5 ns; 
                                reg_data_in(31 downto 16) <= (others=>'0') after 5 ns;
                                
                        elsif (nextstate=WR_MDIO_ADDR1) then
                        
                                reg_wr                   <= '1' after 5 ns;
                                reg_rd                   <= '0' after 5 ns;
                                reg_addr                 <= conv_std_logic_vector(16, 14) after 5 ns;
                                reg_data_in(4 downto 0)  <= conv_std_logic_vector(TB_MDIO_ADDR1, 5) after 5 ns; 
                                reg_data_in(31 downto 5) <= (others=>'0') after 5 ns;   
                                
                        elsif (nextstate=WRITE_MDIO1) then
                
                                reg_wr      <= '1' after 5 ns;
                                reg_rd      <= '0' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(160, 14) after 5 ns;
                                reg_data_in <= X"55555555" after 5 ns; 
                                
                        elsif (nextstate=READ_MDIO1) then
                
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(160, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns; 
                                
                        elsif (nextstate=LUT_PROG) then
                        
                                mcast_addr :=  MCAST_ADDRESSLIST(lut_prog_cnt);
        
                                for i in 0 to 5 loop
               
                                        hash_code(i) := xor_reduce(mcast_addr((i*8)+7 downto i*8)) ;
                       
                                end loop ;
                        
                                reg_wr               <= '1' after 5 ns;
                                reg_rd               <= '0' after 5 ns;
                                reg_addr(7 downto 6) <= "01" after 5 ns;
                                reg_addr(5 downto 0) <= hash_code after 5 ns; 
                                reg_data_in          <= X"00000001" after 5 ns;
                                
                        elsif (nextstate=RD_FRM_TX) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(26, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns; 
                                
                        elsif (nextstate=RD_FRM_RX) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(27, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns; 
                                
                        elsif (nextstate=RD_CRC_ERR) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(28, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns; 
                                
                        elsif (nextstate=RD_ALIGN_ERR) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(29, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;
                                
                        elsif (nextstate=RD_TX_OCTETS) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(30, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;
                                
                        elsif (nextstate=RD_RX_OCTETS) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(31, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;
                                
                        elsif (nextstate=RD_PAUSE_TX) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(32, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns; 
                                
                        elsif (nextstate=RD_PAUSE_RX) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(33, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;
                                
                        elsif (nextstate=RX_UNICAST) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(36, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;
                                
                        elsif (nextstate=RX_MLTCAST) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(37, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;  
                                
                        elsif (nextstate=RX_BRDCAST) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(38, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;  
                                
                        elsif (nextstate=TX_FRM_DISCARD) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(39, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;  
                                
                        elsif (nextstate=TX_UNICAST) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(40, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;
                                
                        elsif (nextstate=TX_MLTCAST) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(41, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;  
                                
                        elsif (nextstate=TX_BRDCAST) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(42, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;  
                                
                        elsif (nextstate=RX_FRM_ERR) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(34, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;  
                                
                        elsif (nextstate=TX_FRM_ERR) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(35, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns; 
                                
                        elsif (nextstate=RX_FRM_DROP) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(43, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;  
                                
                        elsif (nextstate=RX_UNDERSZ_FRM) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(46, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;   
                                
                        elsif (nextstate=RX_OVERSZ_FRM) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(47, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;
                                
                        elsif (nextstate=RX_64_FRM) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(48, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns; 
                                
                        elsif (nextstate=RX_65_127_FRM) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(49, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;  
                                
                        elsif (nextstate=RX_128_255_FRM) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(50, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns; 
                                
                        elsif (nextstate=RX_256_511_FRM) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(51, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns; 
                                
                        elsif (nextstate=RX_512_1023_FRM) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(52, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns; 
                                
                        elsif (nextstate=RX_1024_1518_FRM) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(53, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns; 
                               
                        elsif (nextstate=RX_1519_X_FRM) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(54, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;
                                
                        elsif (nextstate=RX_JABBER) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(55, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns; 
                                
                        elsif (nextstate=RX_FRAGMENT) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(56, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns; 
                                        
                        elsif (nextstate=SW_RESET) then
                
                                reg_wr          <= '1' after 5 ns;
                                reg_rd          <= '0' after 5 ns;
                                reg_addr        <= conv_std_logic_vector(2, 14) after 5 ns;
                                
                                reg_data_in(12 downto 0)  <= (others=>'0') ;
                                reg_data_in(13)           <= '1' ;
                                reg_data_in(31 downto 14) <= (others=>'0') ;
                                
                        elsif (nextstate=RD_SW_RESET) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(2, 14) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;                                                     
                        
                        else
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '0' after 5 ns;
                                reg_addr    <= (others=>'0') after 5 ns;
                                reg_data_in <= (others=>'0') after 5 ns;
                           
                        end if ;
                        
                end if ;
                                
        end process ;
        
   -- Colision Detection
   -- ------------------
        
        process(m_rx_col)
        
                variable ln : line ;
                
        begin
        
                if (m_rx_col='1' and m_rx_col'event and m_tx_en='1') then
                
                        writeline(OUTPUT, ln); 
                        write(ln, NOW );
                        write(ln, string'(" - Collision, Frame Re-Transmitted after Back Off Period"));
                        writeline(OUTPUT, ln); 
                        
                end if ;
                
        end process ; 
        
    -- Version
    -- -------

        process(reg_clk)
        
                variable ln : line ;
                
        begin
        
                if (reg_clk='0' and reg_clk'event) then
        
                        if (state=READ_VER and reg_busy='0') then
                
                                writeline(output, ln) ;
                                write(ln, string'(" ")) ;
                                writeline(output, ln) ;
                                write(ln, string'(" - ---------------------------------------------------------------------------------------- -")) ;
                                writeline(output, ln) ;
                                write(ln, string'(" -- Testbench for 8-Bit Core 10/100/1000 MAC + 1000 Base-X PCS / SGMII + PMA --")) ;
                                writeline(output, ln) ;
                                write(ln, string'(" --   (c) ALTERA CORPORATION 2007  --")) ;
                                writeline(output, ln) ;
                                write(ln, string'(" - ---------------------------------------------------------------------------------------- -")) ;
                                writeline(output, ln) ;
                                write(ln, string'(" ")) ;
                                writeline(output, ln) ;
                                

                                                                        
                                write(ln, string'("   - Altera Design Version : ")) ;
                                write(ln, conv_integer(reg_data_out(15 downto 8))) ;
                                write(ln, string'(".")) ;                               
                                write(ln, conv_integer(reg_data_out(7 downto 0))) ;
                                writeline(output, ln) ; 
                                write(ln, string'(" ")) ;                               
                                writeline(output, ln) ;
                                                        
          
                                
                                if (ETH_MODE=1000 and HD_ENA=TRUE) then
                                
                                        write(ln, string'(" Error: Half Duplex must Disabled for Gigabit Operation")) ;  
                                        writeline(output, ln) ;
                                        write(ln, string'(" ")) ;
                                        writeline(output, ln) ;
                                        assert false report "Simulation Set Up Error" severity failure ;
                                        
                                end if ;
                                
                                if (HD_ENA=TRUE and ENABLE_HD_LOGIC=0) then
                                
                                        write(ln, string'(" Error: Half Duplex Logic is Disabled, Design Operates only Support Full Duplex Operation")) ;  
                                        writeline(output, ln) ;
                                        write(ln, string'(" ")) ;
                                        writeline(output, ln) ;
                                        assert false report "Design Set Up Error" severity failure ;
                                        
                                end if ;
                                
                                if (ENABLE_SUP_ADDR=1 and (TB_ADDR_SEL=1 or TB_ADDR_SEL=2 or TB_ADDR_SEL=3)) then
                                
                                        write(ln, string'(" Error: Address Selection must be 0, 4, 5, 6 or 7")) ;  
                                        writeline(output, ln) ;
                                        write(ln, string'(" ")) ;
                                        writeline(output, ln) ;
                                        assert false report "Design Set Up Error" severity failure ;
                                        
                                end if ;
                                
                                if (TB_MACPADEN=TRUE and TB_MACFWDCRC=TRUE) then
                                
                                        write(ln, string'(" Warning: Setting Padding Termination and Forward CRC Options may Results in Simulation Errors")) ;  
                                        writeline(output, ln) ;
                                        
                                end if ;
                                
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
   -- Simulation Info
   -- --------------- 
        
        process(mff_is_pause) 
        
                variable ln : line ;
                       
        begin
        
                if (mff_is_pause='1') then                              
                        
                        write(ln, NOW) ;
                        write(ln, string'(" - Pause Frame Received on FIFO Interface")) ; 
                        writeline(output, ln) ;
                        
                end if ;       
                                                      
        end process ;     
        
        process(xoff_gen)
        
                variable ln    : line;        
                file     log   : text open write_mode is LOG_FILE;
        
        begin
        
           -- Forced Xoff Frame tranmsitted
           -- -----------------------------
        
                if (xoff_gen='1' and xoff_gen'event) then
        
                        write(ln, NOW );
                        write(ln, string'(" - Xoff Pause Frame Generation Requested with Command Pin"));
                        writeline_log(log,ln);
                        write(ln, string'(" ")) ;                              
                        writeline(output, ln) ;

                end if; 
                
        end process ; 
        
        process(xon_gen)
        
                variable ln    : line;        
                file     log   : text open write_mode is LOG_FILE;
        
        begin
        
           -- Forced Xoff Frame tranmsitted
           -- -----------------------------
        
                if (xon_gen='1' and xon_gen'event) then
        
                        write(ln, NOW );
                        write(ln, string'(" - Xon Pause Frame Generation Requested with Command Pin"));
                        writeline_log(log,ln);

                end if; 
                
        end process ;           
        
    -- Scratch Register
    -- ----------------
    
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=WR_SCRATCH ) then
                
                        write(ln, string'("   - Write Scratch : 0xaaaaaaaa")) ;
                        writeline(output, ln) ;                              
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
                
        begin
        
                if (reg_clk='0' and reg_clk'event) then
                
                        if (state=RD_SCRATCH and reg_busy='0' ) then
                
                                write(ln, string'("   - Read Scratch: 0x")) ;
                                WRITE_HEX(ln, reg_data_out) ;
                                writeline(output, ln) ;
                                write(ln, string'(" ")) ;                              
                                writeline(output, ln) ;
                                readback_scratch <= reg_data_out;
                        end if ;
                        
                end if ;
                
        end process ;
                        
    -- Core Configuration
    -- ------------------
    
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=MAC_CONFIG ) then
                
                        write(ln, string'("   - MAC Configuration")) ;
                        writeline(output, ln) ;  
                        write(ln, string'(" ")) ;                            
                        writeline(output, ln) ;
                        
                end if ;
                
        end process ;   
        
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=WR_MAC1 ) then
                
                        write(ln, string'("   - Write MAC Address")) ;
                        writeline(output, ln) ;  
                        write(ln, string'(" ")) ;                            
                        writeline(output, ln) ;
                        
                end if ;
                
        end process ;
        
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=WR_SUP_MAC0_0 ) then
                
                        write(ln, string'("   - Setting Supplemental MAC Addresses")) ;
                        writeline(output, ln) ; 
                        write(ln, string'(" ")) ;                             
                        writeline(output, ln) ;
                        
                end if ;
                
        end process ;   
        
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=LUT_PROG and lut_prog_cnt=1) then
                
                        write(ln, string'("   - Load Hash Table")) ;
                        writeline(output, ln) ; 
                        write(ln, string'(" ")) ;                             
                        writeline(output, ln) ;
                        
                end if ;
                
        end process ; 
        
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=WR_FRM_LENGTH ) then
                
                        write(ln, string'("   - Write Maximum Frame Length")) ;
                        writeline(output, ln) ; 
                        write(ln, string'(" ")) ;                             
                        writeline(output, ln) ;
                        
                end if ;
                
        end process ;  
        
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=WR_PAUSE_QUANTA ) then
                
                        write(ln, string'("   - Write Pause Quanta")) ;
                        writeline(output, ln) ;
                        write(ln, string'(" ")) ;                              
                        writeline(output, ln) ;
                        
                end if ;
                
        end process ;    
        
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=WR_RX_SE ) then
                
                        write(ln, string'("   - Setting FIFO thresholds")) ;
                        writeline(output, ln) ; 
                        write(ln, string'(" ")) ;                             
                        writeline(output, ln) ;
                        
                end if ;
                
        end process ; 
        
    -- MDIO Test
    -- ---------
    
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=WR_MDIO_ADDR1) then
                
                        write(ln, string'("   - Programming MDIO Base Address 1")) ;
                        writeline(output, ln) ;
                        write(ln, string'(" ")) ;                              
                        writeline(output, ln) ;
                        
                end if ;
                
        end process ;  
        
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=WRITE_MDIO1) then
                
                        write(ln, string'("   - Write MDIO Slave 1 Register 0 : 0x5555")) ;
                        writeline(output, ln) ;                              
                        
                end if ;
                
        end process ; 
        
        
        process(reg_clk)
        
                variable ln : line ;
                
        begin
        
                if (reg_clk='1' and reg_clk'event) then
        
                        if (state=READ_MDIO1 and reg_busy='0') then
                
                                write(ln, string'("   - Read MDIO Slave 1 Register 0 : 0x")) ;
                                write_hex(ln, reg_data_out(15 downto 0)) ;
                                writeline(output, ln) ;  
                                write(ln, string'(" ")) ;                            
                                writeline(output, ln) ;
                                readback_MDIO1_addr0(15 downto 0) <= reg_data_out(15 downto 0);
                        end if ;
                        
                end if ;
                
        end process ;  
        
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=SIM) then
                
                        write(ln, string'("- ---------------------------------------------------------------------------------------- -")) ;
                        writeline(output, ln) ; 
                        write(ln, string'(" ")) ;
                        writeline(output, ln) ;                               
                        
                end if ;
                
                if (state=END_SIM) then
                
                        write(ln, string'("- ---------------------------------------------------------------------------------------- -")) ;
                        writeline(output, ln) ;
                        write(ln, string'(" ")) ;  
                        writeline(output, ln) ;                               
                        
                end if ;
                
        end process ;  
        
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=SW_RESET) then
                
                        write(ln, string'("- ---------------------------------------------------------------------------------------- -")) ;
                        writeline(output, ln) ; 
                        write(ln, string'(" ")) ;
                        writeline(output, ln) ;  
                        write(ln, string'("   - Clearing Statistics")) ;
                        writeline(output, ln) ;  
                        write(ln, string'(" ")) ;
                        writeline(output, ln) ;                                                    
                        write(ln, string'("- ---------------------------------------------------------------------------------------- -")) ;
                        writeline(output, ln) ;
                        write(ln, string'(" ")) ;  
                        writeline(output, ln) ;                               
                        
                end if ;
                
        end process ; 

   -- Magic Packet Detection
   -- ----------------------
           
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=WR_ENA_MAGIC) then
                
                        write(ln, string'("- ---------------------------------------------------------------------------------------- -")) ;
                        writeline(output, ln) ; 
                        write(ln, string'(" ")) ;
                        writeline(output, ln) ;  
                        write(ln, string'("   - Magic Packet Detection Test")) ;
                        writeline(output, ln) ;  
                        write(ln, string'(" ")) ;  
                        writeline(output, ln) ;                               
                        
                end if ;
                
        end process ; 
        
        process(magic_sleep_n)
        
                variable ln : line ;
                
        begin
        
                if (magic_sleep_n='0' and magic_sleep_n'event) then
                
                        write(ln, string'("       Set Core in Sleep Mode with External Pin")) ;
                        writeline(output, ln) ;  
                        write(ln, string'(" ")) ;  
                        writeline(output, ln) ;                               
                        
                end if ;
                
                if (magic_sleep_n='1' and magic_sleep_n'event) then
                
                        write(ln, string'("       Set Core in Normal Mode with External Pin")) ;
                        writeline(output, ln) ;  
                        write(ln, string'(" ")) ;  
                        writeline(output, ln) ;                               
                        
                end if ;
                
        end process ;  
        
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=WR_ENA_MAGIC) then
                
                        write(ln, string'("       Set Core in Sleep Mode with Register Access")) ;
                        writeline(output, ln) ;  
                        write(ln, string'(" ")) ;  
                        writeline(output, ln) ;                               
                        
                end if ;
                
                if (state=NODE_ON) then
                
                        write(ln, string'("       Set Core in Normal Mode with Register Access")) ;
                        writeline(output, ln) ;  
                        write(ln, string'(" ")) ;  
                        writeline(output, ln) ;                               
                        
                end if ;
                
        end process ; 
        
        process(reg_wakeup)
        
                variable ln : line ;
                
        begin
        
                if (reg_wakeup='1' and reg_wakeup'event) then
                
                        write(ln, string'("       Magic Packet Detected, Wakeup Request Asserted")) ;
                        writeline(output, ln) ;  
                        write(ln, string'(" ")) ;  
                        writeline(output, ln) ;                               
                        
                end if ;
                
                if (reg_wakeup='0' and reg_wakeup'event and NOW>100 ns) then
                
                        write(ln, string'("       Wakeup Request De-Asserted")) ;
                        writeline(output, ln) ;  
                        write(ln, string'(" ")) ;  
                        writeline(output, ln) ;                               
                        
                end if ;
                
        end process ;       
        

   --  register test status
   --  -----------------------
   process (reset,state,nextstate)
       variable ln : line ;
   begin

       if (reset = '1') then
          register_test <= 0;   
       else
          if (nextstate = END_SIM_WAIT and state = SIM) then
                -- expected scratch register readback is 0xaaaaaaaa
                -- expected MDIO slave 1 address 0 register readback is 0x5555
                --
                if (readback_scratch /= x"aaaaaaaa") then
                     write(ln, string'("      Register test failed on SCRATCH register")) ;
                     writeline(output, ln) ;  
                     register_test <= 1;
                end if;

                 if (TB_MDIO_SIMULATION=TRUE and ENABLE_MDIO = 1) then
                   if ( readback_MDIO1_addr0 /= x"5555" ) then

                     write(ln, string'("      Register test failed on MDIO Slave 1 register")) ;
                     writeline(output, ln) ;  
                     register_test <= 1;

                   end if;
                 end if;
          end if;
       end if;   
   end process;

        
    -- End of Simulation Status
    -- ------------------------
    
        process( rx_clk, reset ) 

                variable ln             : line;        
                file log                : text open write_mode is LOG_FILE;   
                variable rx_no_errs     : boolean;
                variable tx_no_errs     : boolean;
        
        begin
    
                if( reset='1' ) then
    
                        promis_en_dly <= '0';
                        ff_rx_rdy_dly <= '1';

                elsif( rx_clk='1' and rx_clk'event ) then

                        if( sim_stop='1' ) then
                        
                                if (TB_MACPADEN=TRUE) then

                                        rx_no_errs := (rx_good_sent            = rx_good_rcvd) and
                                                      (rx_payload_err_sent     = rx_payload_err_rcvd) and
                                                      (rx_pause_sent           = rx_pause_rcvd) and
                                                      (rx_align_err_sent       = rx_align_err_rcvd) and
                                                      (rx_discard_sent         = rx_discard_rcvd) and
                                                      (rx_wrong_status_sent    = rx_wrong_status_rcvd) and
                                                      (rx_vlan_sent            = rx_vlan_rcvd) and
                                                      (rx_stack_vlan_sent      = rx_stack_vlan_rcvd) and
                                                      (rx_wrong_mac_sent       = rx_wrong_mac_rcvd) and
                                                      (rx_multicast_sent_total = rx_multicast_rcvd + rx_multicast_denied);
                                                      
                                else
                                
                                        rx_no_errs := (rx_good_sent            = rx_good_rcvd) and
                                                      (rx_pause_sent           = rx_pause_rcvd) and
                                                      (rx_align_err_sent       = rx_align_err_rcvd) and
                                                      (rx_discard_sent         = rx_discard_rcvd) and
                                                      (rx_wrong_status_sent    = rx_wrong_status_rcvd) and
                                                      (rx_vlan_sent            = rx_vlan_rcvd) and
                                                      (rx_stack_vlan_sent      = rx_stack_vlan_rcvd) and
                                                      (rx_wrong_mac_sent       = rx_wrong_mac_rcvd) and
                                                      (rx_multicast_sent_total = rx_multicast_rcvd + rx_multicast_denied);
                                                      
                                end if ;        
                                              
                           -- Loopback Simulation
                           -- -------------------

                                if( TB_RXFRAMES=0 ) then
                
                                        rx_no_errs := (rx_good_rcvd = tx_good_sent) and      -- THE RX monitor should have received all the TX monitor got
                                                      (rx_payload_err_rcvd = tx_payload_err_sent) and
                                                      (tx_good_sent = tb_txframes);
                                
                                end if;
                                
                                if (ENA_INVERT_LB=FALSE) then

                                        tx_no_errs := (((tx_good_sent      = tx_good_rcvd) and TB_TX_FF_ERR=FALSE) or ((tx_good_sent = tx_phy_err_rcvd) and TB_TX_FF_ERR=TRUE))and
                                              (tx_payload_err_sent = tx_payload_err_rcvd) and
                                              (tx_align_err_rcvd   = 0) and
                                              (tx_crc_err_rcvd     = 0) and
                                              (tx_pause_err_rcvd   = 0) and
                                              (tx_wrong_src_rcvd   = 0);
                                              
                                else
                                
                                        tx_no_errs := (tx_good_rcvd = rx_good_sent) and
                                              (tx_align_err_rcvd   = 0) and
                                              (tx_crc_err_rcvd     = rx_crc_err_sent) and
                                              (tx_pause_err_rcvd   = 0) ;
                                              
                                end if ;       
                                
                                if( TB_RXFRAMES > 0) then
                                                        
                                        write(ln, string'(" Statistics MAC Rx Path") );
                    
                                        writeline(output, ln) ;
                                        writeline(output, ln) ;
                                        write(ln, string'(" "));
                                        writeline(output, ln) ;
                
                                        write(ln, string'("     - Frames sent in RX path total: "));
                                        write(ln, rxframe_cnt); 
                                        writeline(output, ln) ;
                
                                        write(ln, string'("      - Broadcast sent total: "));
                                        write(ln, rx_broadcast_sent); 
                                        writeline(output, ln) ;
                                        
                                        write(ln, string'("      - Broadcast received: "));
                                        write(ln, rx_broadcast_rcvd); 
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - wrong_mac_sent (good during promiscuous): "));
                                        write(ln, rx_wrong_mac_sent); 
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - wrong_mac_rcvd: "));
                                        write(ln, rx_wrong_mac_rcvd); 
                                        writeline(output, ln) ;
    
                                        write(ln, string'("      - multicast_sent_total: "));
                                        write(ln, rx_multicast_sent_total); 
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - multicast_sent (good): "));
                                        write(ln, rx_multicast_sent); 
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - multicast_rcvd (good): "));
                                        write(ln, rx_multicast_rcvd); 
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - multicast_denied: "));
                                        write(ln, rx_multicast_denied); 
                                        writeline(output, ln) ;
    
                                        write(ln, string'("      - good_sent: ") );
                                        write(ln, rx_good_sent);
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - good_rcvd: ") );
                                        write(ln, rx_good_rcvd);
                                        writeline(output, ln) ;
    
                                        write(ln, string'("      - wrong_status_sent: ") );
                                        write(ln, rx_wrong_status_sent);
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - wrong_status_rcvd: ") );
                                        write(ln, rx_wrong_status_rcvd);
                                        writeline(output, ln) ;
    
                                        write(ln, string'("      - pause_sent: ") );
                                        write(ln, rx_pause_sent);
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - pause_rcvd: ") );
                                        write(ln, rx_pause_rcvd);
                                        writeline(output, ln) ;
    
                                        write(ln, string'("      - vlan_sent: ") );
                                        write(ln, rx_vlan_sent);
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - vlan_rcvd: ") );
                                        write(ln, rx_vlan_rcvd);
                                        writeline(output, ln) ;
                                        
                                        write(ln, string'("      - stack_vlan_sent: ") );
                                        write(ln, rx_stack_vlan_sent);
                                        writeline(output, ln) ;
                                        
                                        write(ln, string'("      - stack_vlan_rcvd: ") );
                                        write(ln, rx_stack_vlan_rcvd);
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - vlan_wrong_type_sent: ") );
                                        write(ln, rx_vlan_wrong_type_sent);
                                        writeline(output, ln) ;
    
                                        write(ln, string'("      - discard_sent: ") );
                                        write(ln, rx_discard_sent);
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - discard_rcvd: ") );
                                        write(ln, rx_discard_rcvd);
                                        writeline(output, ln) ;
    
                                        write(ln, string'("      - align_err_sent: ") );
                                        write(ln, rx_align_err_sent);
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - align_err_rcvd: ") );
                                        write(ln, rx_align_err_rcvd);
                                        writeline(output, ln) ;
    
                                        write(ln, string'("      - length_err_rcvd: ") );
                                        write(ln, rx_length_err_rcvd);
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - length_mismatch_rcvd: ") );
                                        write(ln, rx_length_mismatch_rcvd);
                                        writeline(output, ln) ;
    
                                        write(ln, string'("      - crc_err_sent: ") );
                                        write(ln, rx_crc_err_sent);
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - crc_err_rcvd: ") );
                                        write(ln, rx_crc_err_rcvd);
                                        writeline(output, ln) ;
                                        
                                        if (TB_MACPADEN=TRUE) then
    
                                                write(ln, string'("      - payload_err_sent: ") );
                                                write(ln, rx_payload_err_sent);
                                                writeline(output, ln) ;
                    
                                                write(ln, string'("      - payload_err_rcvd: ") );
                                                write(ln, rx_payload_err_rcvd);
                                                writeline(output, ln) ;
                                                
                                        end if ;

                                        write(ln, string'("      - fifo_overflow_rcvd: ") );
                                        write(ln, rx_fifo_overflow_rcvd);
                                        writeline(output, ln) ;
    
                                        write(ln, string'("      - rx_gmii_err_sent: ") );
                                        write(ln, rx_gmii_err_sent);
                                        writeline(output, ln) ;

                                        write(ln, string'("      - rx_gmii_err_rcvd: ") );
                                        write(ln, rx_gmii_err_rcvd);
                                        writeline(output, ln) ;
                    
                                        if (HD_ENA) then
                    
                                                write(ln, string'("      - rx_col_sent: ") );
                                                write(ln, rx_col_sent);
                                                writeline(output, ln) ; 
                    
                                                write(ln, string'("      - rx_col_rcvd: ") );
                                                write(ln, rx_col_rcvd);
                                                writeline(output, ln) ;  
                        
                                        end if ;      

                                end if;

                                if( TB_TXFRAMES > 0) then
                                
                                        write(ln, string'("  "));
                                        writeline(output, ln) ;
                    
                                        write(ln, string'(" Statistics MAC Tx Path") );
                    
                                        writeline(output, ln) ;
                                        write(ln, string'("  "));
                                        writeline(output, ln) ;

                                        write(ln, string'("     - Frames sent in TX path total: "));
                                        write(ln, txframe_cnt); 
                                        writeline(output, ln) ;

                                        if (TB_TX_FF_ERR=FALSE) then
                                        
                                                write(ln, string'("      - tx_good_sent: "));
                                                write(ln, tx_good_sent); 
                                                writeline(output, ln) ;
                                                
                                        else
                                        
                                                write(ln, string'("      - tx_error_sent: "));
                                                write(ln, tx_good_sent); 
                                                writeline(output, ln) ;
                                                
                                        end if ;        

                                        write(ln, string'("      - tx_vlan_sent: "));
                                        write(ln, tx_vlan_sent); 
                                        writeline(output, ln) ;

                                        write(ln, string'("      - tx_stack_vlan_sent: "));
                                        write(ln, tx_stack_vlan_sent); 
                                        writeline(output, ln) ;

                                        write(ln, string'("      - payload_err_sent: "));
                                        write(ln, tx_payload_err_sent); 
                                        writeline(output, ln) ;
                                                

                                end if; -- TB_TXFRAMES


                                if(TB_RXFRAMES=0) then
                    
                                        write(ln, string'(" ")); 
                                        writeline(output, ln) ;
                                        
                                        write(ln, string'(" Statistics MAC Rx Path - Loopback Test")); 
                                        writeline(output, ln) ;
                                        
                                        write(ln, string'(" ")); 
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - rx_good_rcvd: ") );
                                        write(ln, rx_good_rcvd);
                                        writeline(output, ln) ;

                                        write(ln, string'("      - rx_fifo_overflow_rcvd: ") );
                                        write(ln, rx_fifo_overflow_rcvd);
                                        writeline(output, ln) ;

                                        write(ln, string'("      - rx_payload_err_rcvd: ") );
                                        write(ln, rx_payload_err_rcvd);
                                        writeline(output, ln) ;
                        
                                        write(ln, string'("      - rx_crc_err_rcvd: ") );
                                        write(ln, rx_crc_err_rcvd);
                                        writeline(output, ln) ;

                                        if( tx_pause_rcvd=0 and TB_TRIGGERXOFF>0) then

                                                write(ln, string'("ERROR: Pause Frame Generation (pin pause_gen) had no effect") );
                                                writeline(output, ln) ;
                    
                                        end if;
                    
                                writeline(output, ln) ; 
                                write(ln, string'(" ")); 
                                writeline(output, ln) ;
                                
                                        if (rx_no_errs = false or register_test /= 0) then 
                                        write(ln, string'("-- Loopback Simulation Ended with Error(s) !"));
                                else
                                  write(ln, string'("-- Loopback Simulation Ended with no Error"));
                                end if;
                                writeline(output, ln) ;

                                
                                end if;
                                

                                if(TB_RXFRAMES>0) then
                                        writeline(output, ln) ; 
                                write(ln, string'(" ")); 
                                writeline(output, ln) ;

                                        if (rx_no_errs = false or tx_no_errs=false or register_test /= 0) then 
                                                write(ln, string'("-- Simulation Ended with Error(s) !"));
                                        else
                                          write(ln, string'("-- Simulation Ended with no Error"));
                                        end if;
                                writeline(output, ln) ; 

                                end if;

                                
                                write(ln, string'(" ")); 
                                writeline(output, ln) ;
                                write(ln, string'("- ---------------------------------------------------------------------------------------- -")) ;
                                writeline(output, ln) ;
                                assert false report "End of Simulation - Break" severity failure  ;

                        end if;
            

                   -- Inform of Unexpected Signals Behaviour
                   -- --------------------------------------
        
                        if( expect2='0' and TB_RXFRAMES/=0) then  -- RX test is active and nothing is expected to happen

                                if( (pause_rcv or frm_align_err or frm_type_err or frm_length_err or frm_crc_err) = '1' ) then
                
                                        write(ln, NOW);
                                        write(ln, string'("    - Warning :"));

                                        if( pause_rcv='1' ) then 
                                        
                                                write(ln, string'(" Unexpected RX pause_rcv") );
                                                writeline(output, ln) ;
                                        
                                        end if;
            
                                        if( frm_align_err='1') then 
                                        
                                                write(ln, string'(" Unexpected RX frm_align_err") );
                                                writeline(output, ln) ;
                                        end if;
            
                                        if( frm_type_err='1' ) then 
                                        
                                                write(ln, string'(" Unexpected RX frm_type_err") );
                                                writeline(output, ln) ;
                                        
                                        end if;
            
                                        if( frm_length_err='1')then 
                                        
                                                write(ln, string'(" Unexpected RX frm_length_err") );
                                                writeline(output, ln) ;
                                        
                                        end if;

                                        if( frm_crc_err   ='1')then 
                                        
                                                write(ln, string'(" Unexpected RX frm_crc_err") );
                                                writeline(output, ln) ;
                                        
                                        end if;
            
                                end if;

                      end if;

                   -- Promiscuous Mode Change
                   -- -----------------------
                   
                        promis_en_dly <= promis_en;

                        if( promis_en /= promis_en_dly ) then
        
                                write(ln, NOW );

                                if( promis_en='1' and NOW>100 ns) then 
                
                                        write(ln, string'(" - Promiscuous Mode enabled with multicast sent: ") );
                                        write(ln, rx_multicast_sent );
                                        write(ln, string'(", rcvd:"));
                                        write(ln, rx_multicast_rcvd );
                                        write(ln, string'(", denied:"));
                                        write(ln, rx_multicast_denied );
                                        writeline(output, ln) ;
            
                                else                
                        
                                        write(ln, string'(" - Promiscuous Mode disabled") );
                                        writeline(output, ln) ;
            
                                end if;
            
                        end if;                
        
                   -- FIFO Read Stop
                   -- --------------
                   
                        ff_rx_rdy_dly <= ff_rx_rdy;
        
                        if( ff_rx_rdy_dly /= ff_rx_rdy ) then
        
                                write(ln, NOW );

                                if( ff_rx_rdy='0' ) then 
            
                                        write(ln, string'("    - RX FIFO Read Stop"));
                
                                else
            
                                        write(ln, string'("    - RX FIFO Read Start"));
        
                                end if;
            
                                writeline(output, ln) ;

                        end if;
        
                end if;
    
        end process;                                  

    -- Global Simulation STOP
    -- -----------------------
    
        process( reset, rx_clk ) 
        begin
        
                if( reset='1' ) then
        
                        delay_cnt <= 0;
                        sim_stop  <= '0' ;
            
                elsif( rx_clk='1' and rx_clk'event) then
        
                        if(state=END_SIM) then
                
                                delay_cnt <= delay_cnt + 1;
                                
                                if (delay_cnt=150) then
                                
                                        sim_stop <= '1' ;
                                        
                                end if ;
                
                                if( delay_cnt > 200 ) then
                
                                        assert false severity failure  ;                                        
                    
                                end if;
                
                        elsif(gm_tx_en='1') then
            
                                delay_cnt <= 0;
               
                        end if;
             
                end if;
        
        end process;
end a ;                                
