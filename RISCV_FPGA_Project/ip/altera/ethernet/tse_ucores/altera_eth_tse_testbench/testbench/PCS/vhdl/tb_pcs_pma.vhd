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
-- $RCSfile: tb_pcs_pma.vhd,v $
-- $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/testbench/PCS/vhdl/tb_pcs_pma.vhd,v $
--
-- $Revision: #1 $
-- $Date: 2013/08/11 $
-- Check in by : $Author: swbranch $
-- Author      : SKNg/TTChong
--
-- Project     : Triple Speed Ethernet - 1000 Base-X PCS / SGMII
--
-- Description : (Simulation only)
--
-- Testbench with PCS under test implemented with Altera Transceivers
--
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
use     std.textio.all ;
use     work.altera_ethmodels_pack.all;

entity tb is
generic(
    -- Simulation Settings (Testbench)
    -- -------------------------------
        
        TB_TXFRAMES             : integer := 5 ; -- number of frames to send in Txs path
        TB_TXIPG                : integer := 12 ; -- Inter Packet Gap used by RX generator
        TB_LENSTART             : integer := 100 ; -- length to start (incremented each new frame by TB_LENSTEP)
        TB_LENSTEP              : integer := 1 ; -- steps the length should increase with each frame
        TB_LENMAX               : integer := 1500 ; -- max. payload length for generation
        TB_MACLENMAX            : integer := 1518; -- max. frame length configuration of MAC
        TB_PHYERR               : boolean := FALSE; -- Generate PHY Error
        TB_ENA_AUTONEG          : boolean := FALSE ; -- Enable Auto-Negotiation
        TB_PCS_LINK_TIMER       : integer := 512 ; -- Link Timer
        TB_PARTNER_LINK_TIMER   : integer := 128 ; -- Link Timer
        TB_TX_ERR               : boolean := FALSE ; -- Enable GMII Error
        TB_PARTNER_PS1          : boolean := TRUE ; -- Pause Support Encoding
        TB_PARTNER_PS2          : boolean := FALSE ; -- Pause Support Encoding
        TB_PARTNER_RF1          : boolean := FALSE ; -- Remote Fault Encoding
        TB_PARTNER_RF2          : boolean := FALSE ; -- Remote Fault Encoding
        TB_PCS_PS1              : boolean := TRUE ; -- Pause Support Encoding
        TB_PCS_PS2              : boolean := FALSE ; -- Pause Support Encoding
        TB_PCS_RF1              : boolean := FALSE ; -- Remote Fault Encoding
        TB_PCS_RF2              : boolean := FALSE ; -- Remote Fault Encoding
        TB_ISOLATE              : boolean := FALSE ; -- Remote Fault Encoding
        TB_SGMII_ENA            : boolean := FALSE ; -- Enable SGMII Interface
        TB_SGMII_AUTO_CONF      : boolean := FALSE ; -- Enable SGMII Auto-Configuration
        TB_SGMII_1000           : boolean := TRUE ; -- Enable SGMII Gigabit
        TB_SGMII_100            : boolean := FALSE ; -- Enable SGMII 100Mbps
        TB_SGMII_10             : boolean := FALSE ; -- Enable SGMII 10Mbps
        TB_SGMII_HD             : boolean := FALSE --Enable SGMII Half-Duplex Operation
        
); -- end generic


-- Core Settings
-- WARNING: DO NOT MODIFY THESE PARAMETERS
-- ------------------
-- $<RTL_PARAMETERS>
  
  constant reconfig_to_width : INTEGER := get_reconfig_to_width (DEVICE_FAMILY);
  constant reconfig_from_width : INTEGER := get_reconfig_from_width (DEVICE_FAMILY);
end tb ;

architecture a of tb is

-- $<RTL_CORE_INSTANCE_COMPONENT>

        component ethgenerator

                generic (  
                
                        THOLD  : time );

                port (

                        reset           : in std_logic ;     -- active high
                        rx_clk          : in std_logic ;
                        enable          : in std_logic ;
                        rxd             : out std_logic_vector(7 downto 0);
                        rx_dv           : out std_logic;
                        rx_er           : out std_logic;                
                        sop             : out std_logic;   -- pulse with first character
                        eop             : out std_logic;   -- pulse with last  character
                        mac_reverse     : in std_logic;                     -- 1: dst/src are sent MSB first
                        dst             : in std_logic_vector(47 downto 0); -- destination address
                        src             : in std_logic_vector(47 downto 0); -- source address
                        prmble_len      : in integer range 0 to 40;         -- length of preamble
                        pquant          : in std_logic_vector(15 downto 0); -- Pause Quanta value
                        vlan_ctl        : in std_logic_vector(15 downto 0); -- VLAN control info
                        len             : in std_logic_vector(15 downto 0); -- Length of payload
                        frmtype         : in std_logic_vector(15 downto 0); -- if non-null: type field instead length
                        cntstart        : in integer range 0 to 255;  -- payload data counter start (first byte of payload)
                        cntstep         : in integer range 0 to 255;  -- payload counter step (2nd byte in paylaod)
                        ipg_len         : in integer range 0 to 32768;  -- inter packet gap (delay after CRC)
                        wrong_pause_op  : in std_logic ;                    -- Generate Pause Frame with Wrong Opcode       
                        wrong_pause_lgth: in std_logic ;                    -- Generate Pause Frame with Wrong Opcode              
                        payload_err     : in std_logic;  -- generate payload pattern error (last payload byte is wrong)
                        prmbl_err       : in std_logic;
                        crc_err         : in std_logic;
                        vlan_en         : in std_logic;
                        pause_gen       : in std_logic;
                        pad_en          : in std_logic;
                        phy_err         : in std_logic;
                        end_err         : in std_logic;  -- keep rx_dv high one cycle after end of frame
                        magic           : in std_logic;  
                        stack_vlan      : in std_logic;   
                        data_only       : in std_logic;  -- if set omits preamble, padding, CRC
                        start           : in  std_logic;
                        done            : out std_logic );
      
        end component ;
        
        component ethgenerator2 

                generic (  
                
                        THOLD  : time := 1 ns);

                port (

                        reset           : in std_logic ;     -- active high
                        rx_clk          : in std_logic ;
                        rxd             : out std_logic_vector(7 downto 0);
                        rx_dv           : out std_logic;
                        rx_er           : out std_logic;
                        sop             : out std_logic;   -- pulse with first character
                        eop             : out std_logic;   -- pulse with last  character       
                        ethernet_speed  : in std_logic;
                        mii_mode        : in std_logic;   -- 4-bit Nibbles (Fast Ethernet)
                        rgmii_mode      : in std_logic;   -- 4-bit DDR (Reduced Gigabit)     
                        mac_reverse     : in std_logic;                     -- 1: dst/src are sent MSB first
                        dst             : in std_logic_vector(47 downto 0); -- destination address
                        src             : in std_logic_vector(47 downto 0); -- source address
                        prmble_len      : in integer range 0 to 40;         -- length of preamble
                        pquant          : in std_logic_vector(15 downto 0); -- Pause Quanta value
                        vlan_ctl        : in std_logic_vector(15 downto 0); -- VLAN control info
                        len             : in std_logic_vector(15 downto 0); -- Length of payload
                        frmtype         : in std_logic_vector(15 downto 0); -- if non-null: type field instead length
                        cntstart        : in integer range 0 to 255;  -- payload data counter start (first byte of payload)
                        cntstep         : in integer range 0 to 255;  -- payload counter step (2nd byte in paylaod)
                        ipg_len         : in integer range 0 to 32768;  -- inter packet gap (delay after CRC)  
                        wrong_pause_op  : in std_logic ;                    -- Generate Pause Frame with Wrong Opcode       
                        wrong_pause_lgth: in std_logic ;                    -- Generate Pause Frame with Wrong Opcode       
                        payload_err     : in std_logic;  -- generate payload pattern error (last payload byte is wrong)
                        prmbl_err       : in std_logic;
                        crc_err         : in std_logic;
                        vlan_en         : in std_logic;
                        pause_gen       : in std_logic;
                        pad_en          : in std_logic;
                        phy_err         : in std_logic;
                        end_err         : in std_logic;  -- keep rx_dv high one cycle after end of frame
                        magic           : in std_logic;     
                        stack_vlan      : in std_logic;   
                        data_only       : in std_logic;  -- if set omits preamble, padding, CRC
                        start           : in  std_logic;
                        done            : out std_logic );
      
        end component ;        
        
        component ethmonitor port (

                reset           : in std_logic ;                                -- active high
                tx_clk          : in std_logic ;
                txd             : in std_logic_vector(7 downto 0);
                tx_dv           : in std_logic;
                tx_er           : in std_logic;
                tx_sop          : in std_logic;
                tx_eop          : in std_logic;
                dst             : out std_logic_vector(47 downto 0);            -- destination address
                src             : out std_logic_vector(47 downto 0);            -- source address     
                prmble_len      : out integer range 0 to 10000;                 -- length of preamble
                pquant          : out std_logic_vector(15 downto 0);            -- Pause Quanta value
                vlan_ctl        : out std_logic_vector(15 downto 0);            -- VLAN control info
                len             : out std_logic_vector(15 downto 0);            -- Length of payload
                frmtype         : out std_logic_vector(15 downto 0);            -- if non-null: type field instead length      
                payload         : out std_logic_vector(7 downto 0);
                payload_vld     : out std_logic;        
                is_vlan         : out std_logic;
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
        
        component ethmonitor2 port (

                reset           : in std_logic ;     -- active high
                tx_clk          : in std_logic ;
                txd             : in std_logic_vector(7 downto 0);
                tx_dv           : in std_logic;
                tx_er           : in std_logic;
                tx_sop          : in std_logic;
                tx_eop          : in std_logic;       
                ethernet_speed  : in std_logic;
                mii_mode        : in std_logic;   -- 4-bit Nibbles (Fast Ethernet)
                rgmii_mode      : in std_logic;   -- 4-bit DDR (Reduced Gigabit)
                dst             : out std_logic_vector(47 downto 0); -- destination address
                src             : out std_logic_vector(47 downto 0); -- source address
                prmble_len      : out integer range 0 to 10000;         -- length of preamble
                pquant          : out std_logic_vector(15 downto 0); -- Pause Quanta value
                vlan_ctl        : out std_logic_vector(15 downto 0); -- VLAN control info
                len             : out std_logic_vector(15 downto 0); -- Length of payload
                frmtype         : out std_logic_vector(15 downto 0); -- if non-null: type field instead length
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
        
   -- Reset Control
   -- -------------
   
        signal reset            : std_logic ;
        signal reset_model      : std_logic := '0';

   -- Host Interface
   -- --------------
   
        signal reg_clk          : std_logic ;                           -- Register Interface Clock
        signal reg_rd           : std_logic ;                           -- Register Read Enable
        signal reg_wr           : std_logic ;                           -- Register Write Enable
        signal reg_addr         : std_logic_vector(4 downto 0) ;        -- Register Address
        signal reg_data_in      : std_logic_vector(15 downto 0) ;       -- Register Input Data 
        signal reg_data_out     : std_logic_vector(15 downto 0) ;       -- Register Output Data
        signal reg_busy         : std_logic ;                           -- Access Busy                
        signal reg_busy_reg     : std_logic ;                           -- Access Busy                
        
   -- PCS Status
   -- ----------
   
        signal led_crs          : std_logic ;                           -- Carrier Sense
        signal led_an           : std_logic ;                           -- Auto-Negotiation Status
        signal led_link         : std_logic ;                           -- Valid Link 
        signal hd_ena           : std_logic ;                           -- Half-Duplex Enable
        signal set_10           : std_logic ;                           -- 10Mbps Link Indication
        signal set_100          : std_logic ;                           -- 100Mbps Link Indication
        signal set_1000         : std_logic ;                           -- Gigabit Link Indication
        signal led_char_err     : std_logic ;                           -- Character Error
        signal led_disp_err     : std_logic ;                           -- Disparity Error

   -- RECONFIG BLOCK       SIGNALS
   -- -----------            
      signal   reconfig_clk      : std_logic ;                        -- Reconfig clk
      signal   reconfig_busy        : std_logic ;                        -- Reconfig Busy
      signal   reconfig_togxb   : std_logic_vector(reconfig_to_width-1 downto 0) ; 
      signal   reconfig_fromgxb   : std_logic_vector(reconfig_from_width-1 downto 0) ;        

-- RECOVERED CLOCK
      signal   rx_recovclkout        : std_logic ;    
        
   -- Serdes Interface
   -- ----------------
   
        signal ref_clk          : std_logic ;                           -- Serdes 125MHz Reference Clock
        signal cdr_ref_clk_0    : std_logic ;                           -- CDR reference clock
        signal clk_out          : std_logic ;
        signal rxp              : std_logic ;                           -- 1.25Gbps Serial Input
        signal txp              : std_logic ;                           -- 1.25Gbps Serial Output

   -- Serdes Interface
   -- ----------------

        signal rx_kchar         : std_logic ;                           -- Special Character Indication
        signal rx_frame         : std_logic_vector(7 downto 0) ;        -- Frame
        signal rx_char_err      : std_logic ;                           -- Decoder Error
        signal tx_kchar         : std_logic ;                           -- Special Character Indication
        signal tx_frame         : std_logic_vector(7 downto 0) ;        -- Frame
        signal gmii_crs         : std_logic ;                           -- Carrier Sense           
        signal comma            : std_logic ;                           -- Comma Detected            
        signal dec_sync         : std_logic ;                           -- Decoder Synchronized
        signal dec_err          : std_logic ;                           -- Decoded Symbol Error
        signal rx_sync          : std_logic ;                           -- Receiver Synchronized
        signal an_restart_rst   : std_logic ;                           -- Reset Autonegotiation Command        

        signal rx_clk           : std_logic;                            -- GMII / MII Receive Clock 
        signal tx_clk           : std_logic;                            -- GMII / MII Transmit Clock 
        signal rx_clkena        : std_logic;
        signal tx_clkena        : std_logic;
        signal rx_clk_sig       : std_logic;
        signal tx_clk_sig       : std_logic;
        signal rx_en1           : std_logic;
        signal rx_en2           : std_logic;
        signal tx_en1           : std_logic;
        signal tx_en2           : std_logic;

   -- MII Transmit
   -- ------------

        signal mii_tx_en        : std_logic ;                           -- Enable
        signal mii_txen_tmp     : std_logic ;                           -- Enable
        signal mii_tx_d         : std_logic_vector(3 downto 0);         -- Data
        signal mii_txd          : std_logic_vector(7 downto 0);         -- Data
        signal mii_tx_err       : std_logic ;                           -- Error
        signal mii_txerr_tmp    : std_logic ;                           -- Error  

   -- MII Receive
   -- -----------

        signal mii_rx_dv        : std_logic;                            -- Enable
        signal mii_rx_d         : std_logic_vector(3 downto 0);         -- Data
        signal mii_rxd_tmp      : std_logic_vector(7 downto 0);         -- Data
        signal mii_rx_err       : std_logic;                            -- Error 
        
   -- GMII Receive
   -- ------------
   
        signal gmii_rx_dv       : std_logic ;                           -- Enable
        signal gmii_rx_d        : std_logic_vector(7 downto 0) ;        -- Data
        signal gmii_rx_err      : std_logic ;                           -- Error 
        
   -- Parnert GMII Transmit
   -- ---------------------
             
        signal part_gmii_txclk  : std_logic ;                           -- 125MHz Transmit Clock
        signal part_gmii_txen   : std_logic ;                           -- Enable
        signal part_gmii_txd    : std_logic_vector(7 downto 0) ;        -- Data
        signal part_gmii_txerr  : std_logic ;                           -- Error
        
   -- Partner GMII Receive
   -- --------------------
   
        signal part_gmii_rxdv   : std_logic ;                           -- Enable
        signal part_gmii_rxd    : std_logic_vector(7 downto 0) ;        -- Data
        signal part_gmii_rxerr  : std_logic ;                           -- Error 
        
   -- GMII Transmit
   -- -------------
             
        signal gmii_tx_en       : std_logic ;                           -- Enable
        signal gmii_tx_d        : std_logic_vector(7 downto 0) ;        -- Data
        signal gmii_tx_err      : std_logic ;                           -- Error        
        
   -- Autonegotiaition Signals
   -- ------------------------
   
        signal an_enable        : std_logic ;                           -- Enable Autonegotiation
        signal an_restart       : std_logic ;                           -- Restart Autonegotiation        
        signal an_ability       : std_logic_vector(15 downto 0) ;       -- Autonegotiation Ability Register
        signal an_done          : std_logic ;                           -- Autonegotiation Done
        signal an_ack           : std_logic ;                           -- Acknowledge Indication
        signal an_link_timer    : std_logic_vector(20 downto 1) ;       -- Link Timer Maximum Value
        signal page_receive     : std_logic ;                           -- Page Receive Indication
        signal lp_ability       : std_logic_vector(15 downto 0) ;       -- Link Partner Ability Register
        signal lp_ability_reg   : std_logic_vector(15 downto 0) ;       -- Link Partner Ability Register
        signal lp_ability_ena   : std_logic ;                           -- Link Partner Ability Valid
        signal link_timer_reg   : std_logic_vector(31 downto 0) ;       -- Link Timer Value
                 
   -- Model Configuration
   -- -------------------
   
        signal mac_dst          : std_logic_vector(47 downto 0) ;       -- Destination Address
        signal mac_scr          : std_logic_vector(47 downto 0) ;       -- Source Address
        signal mac_reverse      : std_logic ;                           -- Reverse MAC Address
        signal prmble_len       : integer range 0 to 15 ;               -- Preamble Length
        signal pquant           : std_logic_vector(15 downto 0) ;       -- Pause Quanta
        signal vlan_ctl         : std_logic_vector(15 downto 0);        -- VLAN control info
        signal frmtype          : std_logic_vector(15 downto 0);        -- if non-null: type field instead length      
        signal cntstart         : integer range 0 to 255;               -- payload data counter start (first byte of payload)
        signal cntstep          : integer range 0 to 255;               -- payload counter step (2nd byte in paylaod)
        signal ipg_len          : integer range 0 to 32768;             -- inter packet gap (delay after CRC)                
        signal payload_err      : std_logic;                            -- generate payload pattern error (last payload byte is wrong)
        signal prmbl_err        : std_logic;                            -- Insert Preamble Error
        signal crc_err          : std_logic;                            -- Insert CRC Error
        signal vlan_en          : std_logic;                            -- Generate VLAN Frame
        signal pause_gen        : std_logic;                            -- Generate Pause Frame
        signal pad_en           : std_logic;                            -- Pad Short Frames
        signal phy_err          : std_logic;                            -- Insert GMII Error
        signal end_err          : std_logic;                            -- keep rx_dv high one cycle after end of frame
        signal data_only        : std_logic;                            -- if set omits preamble, padding, CRC
        signal tx_len           : std_logic_vector(15 downto 0);        -- Length of payload
        
   -- Simulation Control
   -- ------------------
   
        signal frm_gen_ena_gmii : std_logic ;                           -- Enable Frame Genaration
        signal frm_gen_ena_mii  : std_logic ;                           -- Enable Frame Genaration
        signal tx_sop_gmii      : std_logic ;                           -- Start of Generated Frame 
        signal tx_sop_mii       : std_logic ;                           -- Start of Generated Frame 
        signal tx_eop           : std_logic ;                           -- End of Generated Frame
        signal frm_rcv_gmii     : std_logic ;                           -- Frame Receive
        signal frm_rcv_mii      : std_logic ;                           -- Frame Receive
        signal rx_crc_err_gmii  : std_logic ;                           -- CRC Error
        signal rx_crc_err_mii   : std_logic ;                           -- CRC Error
        signal rx_preamble_err  : std_logic ;                           -- Preamble Error
        signal rx_data_err      : std_logic ;                           -- Data Error
        signal rx_payload_vld   : std_logic ;                           -- Payload Valid
        signal rx_payload_vld_gmii  : std_logic ;                       -- Payload Valid
        signal rx_payload_vld_mii   : std_logic ;                       -- Payload Valid
        signal end_cnt          : integer ;                             -- End of Simulation Pause
        signal rx_dst           : std_logic_vector(47 downto 0) ;       -- Received Destination MAC address
        signal rx_src           : std_logic_vector(47 downto 0) ;       -- Received Source MAC address
        signal rx_dst_gmii      : std_logic_vector(47 downto 0) ;       -- Received Destination MAC address
        signal rx_src_gmii      : std_logic_vector(47 downto 0) ;       -- Received Source MAC address
        signal rx_dst_mii       : std_logic_vector(47 downto 0) ;       -- Received Destination MAC address
        signal rx_src_mii       : std_logic_vector(47 downto 0) ;       -- Received Source MAC address
        signal rx_frm_err_gmii  : std_logic ;                           -- Errored Frame Indication
        signal rx_frm_err_mii   : std_logic ;                           -- Errored Frame Indication
        signal sim_start        : std_logic;                            -- when to start simulation
        
   -- Event Counters
   -- --------------
   
        signal tx_frm_cnt       : integer := 0 ;                        -- Number of Transmitted Frames
        signal tx_gmii_err_cnt  : integer := 0 ;                        -- Number of GMII Error
        signal rx_frm_cnt       : integer := 0 ;                        -- Number of Received Frames
        signal rx_crc_err_cnt   : integer := 0 ;                        -- Number of CRC Error
        signal rx_pbl_err_cnt   : integer := 0 ;                        -- Number of Premable Error
        signal rx_dst_err_cnt   : integer := 0 ;                        -- Number of MAC Destination Address Error
        signal rx_src_err_cnt   : integer := 0 ;                        -- Number of MAC Source Address Error
        signal rx_gmii_err_cnt  : integer := 0 ;                        -- Number of GMII Error
        
   -- Simulation Control
   -- ------------------
        
        type stm_typ is (idle, read_ver, wr_scratch, rd_scratch, read_phy_control, read_sync_status,
                         prog_ability, prog_timer_1, prog_timer_2, autoneg_enable, start_autoneg,
                         wait_autoneg, read_autoneg_expansion, read_autoneg_status, read_part_ability,
                         wait_link, sim, stop_tbi, start_tbi, read_status, read_status_2, ena_sw_reset,
                         read_sw_reset, disable_isolate, end_sim, autoneg_disable, if_control) ;        
        
        signal state            : stm_typ ;
        signal nextstate        : stm_typ ;
        
        signal gnd              : std_logic ;
        signal vcc              : std_logic ;
                        
    -- register write/read test
    -- ----------------------------
         signal readback_scratch     : std_logic_vector(15 downto 0) ;
         
         signal register_test        : integer;
                        
begin
        
        gnd <= '0' ;
        vcc <= '1' ;
        link_timer_reg <= conv_std_logic_vector(TB_PCS_LINK_TIMER, 32);

        -- Clock generation for Gigabit and 10/100 operations
	    process(reset, tx_clk)
        begin
                if (reset='1') then
                    tx_en1 <= '0' ;
					tx_en2 <= '0' ;
                elsif (tx_clk='1') and (tx_clk'event) then
                    tx_en1 <= tx_clkena ;
					tx_en2 <= tx_en1 ;                                 
                end if ;
				
        end process ;

	    process(reset, rx_clk)
        begin
                if (reset='1') then
                    rx_en1 <= '0' ;
					rx_en2 <= '0' ;
                elsif (rx_clk='1') and (rx_clk'event) then
                    rx_en1 <= rx_clkena ;
					rx_en2 <= rx_en1 ;                                 
                end if ;
				
        end process ;
		
		-- For testbench purposes, the clock enable of the 125MHz clock is used to mimic the 2.5/25MHz clock with a short duty cycle .
		rx_clk_sig  <= rx_clk when ((ENABLE_SGMII = 0) or ((rx_en1='1') and (rx_en2='1'))) else rx_clkena ;
        tx_clk_sig  <= tx_clk when ((ENABLE_SGMII = 0) or ((tx_en1='1') and (tx_en2='1'))) else tx_clkena ;


		
-- $<RTL_CORE_INSTANCE>
   rxp <= txp; 
   mii_tx_d <= mii_txd(3 downto 0);
                
   -- Clocks
   -- ------
       
        process
        begin
        
                ref_clk <= '1' ;
                wait for 4 ns;
                ref_clk <= '0' ;
                wait for 4 ns ;
                
        end process ;
        
        process
        begin
        
                reg_clk <= '1' ;
                wait for 10 ns;
                reg_clk <= '0' ;
                wait for 10 ns ;
                
        end process ;
                       
   -- Reset Control
   -- -------------

        reset       <= '0', '1' after 50 ns, '0' after 2000 ns ;           
        sim_start   <= '0', '1' after 3000 ns;   
        reconfig_clk    <= ref_clk;
        cdr_ref_clk_0   <= ref_clk;
        reconfig_busy   <= '0';
        reconfig_togxb  <= conv_std_logic_vector(0, reconfig_to_width) when (isPhyIp(DEVICE_FAMILY)) else conv_std_logic_vector(2, reconfig_to_width);

        process(led_link)
        
                variable ln : line ;
                
        begin
                
                if (led_link='1') then
                
                        write(ln, string'("  - Link Acquired")) ;
                        writeline(output, ln) ;  
                        write(ln, string'(" ")) ;                            
                        writeline(output, ln) ; 
                        
                elsif (led_link='0' and NOW>10 ns) then
                
                        write(ln, string'("  - Link Lost")) ;
                        writeline(output, ln) ;  
                        write(ln, string'(" ")) ;                            
                        writeline(output, ln) ; 
                        
                end if ;
                
        end process ;                            
        
   -- Ethernet Frame Generator Configuration
   -- --------------------------------------
   
        mac_dst         <= X"AABBCCDDEEFF" ;
        mac_scr         <= X"112233445566" ;          
        prmble_len      <= 8 ;       
        pquant          <= X"0000" ;           
        vlan_ctl        <= X"0000" ;         
        frmtype         <= X"0000" ;          
        cntstart        <= 2 ;         
        cntstep         <= 1 ;          
        ipg_len         <= TB_TXIPG ;          
        payload_err     <= '0' ;      
        prmbl_err       <= '0' ;        
        crc_err         <= '0' ;          
        vlan_en         <= '0' ;          
        pause_gen       <= '0' ;        
        pad_en          <= '1' ;           
        phy_err         <= '1' when ((tx_frm_cnt mod 10)=5 and TB_TX_ERR) else '0' ;         
        end_err         <= '0' ;         
        data_only       <= '0' ;
        mac_reverse     <= '0' ;
        
        mii_tx_en  <= mii_txen_tmp when (led_link='1') else '0' ;
        mii_tx_err <= mii_txerr_tmp when (led_link='1') else '0' ;
        
        U_FRM_GEN2: ethgenerator2 
        
                generic map (
        
                        THOLD => 4 ns)
                
                port map (

                        reset           => reset ,       
                        rx_clk          => tx_clk_sig ,       
                        rxd             => mii_txd ,             
                        rx_dv           => mii_txen_tmp ,          
                        rx_er           => mii_txerr_tmp ,         
                        sop             => tx_sop_mii ,          
                        eop             => open ,                    
                        ethernet_speed  => '0',
                        mii_mode        => '1' ,           
                        rgmii_mode      => '0' ,         
                        mac_reverse     => mac_reverse , 
                        dst             => mac_dst ,             
                        src             => mac_scr ,             
                        prmble_len      => prmble_len ,   
                        pquant          => pquant ,           
                        vlan_ctl        => vlan_ctl ,       
                        len             => tx_len ,              
                        frmtype         => frmtype ,         
                        cntstart        => cntstart ,       
                        cntstep         => cntstep ,         
                        ipg_len         => ipg_len ,         
                        payload_err     => payload_err , 
                        prmbl_err       => prmbl_err ,     
                        crc_err         => crc_err ,
                        magic           => '0' ,  
                        wrong_pause_op  => '0' , 
                        wrong_pause_lgth=> '0' ,      
                        vlan_en         => '0' ,            
                        stack_vlan      => '0' ,         
                        pause_gen       => pause_gen ,     
                        pad_en          => pad_en ,           
                        phy_err         => phy_err ,         
                        end_err         => end_err , 
                        data_only       => data_only ,     
                        start           => frm_gen_ena_mii,   
                        done            => open);         
        
        FRM_GEN: ethgenerator

                generic map (
                
                        THOLD           => 2 ns)

                port map (

                        reset           => reset ,          
                        rx_clk          => tx_clk_sig , 
                        enable          => '1',
                        rxd             => gmii_tx_d ,
                        rx_dv           => gmii_tx_en ,
                        rx_er           => gmii_tx_err ,
                        sop             => tx_sop_gmii ,
                        eop             => tx_eop ,
                        mac_reverse     => mac_reverse ,
                        dst             => mac_dst ,
                        src             => mac_scr ,
                        prmble_len      => prmble_len ,
                        pquant          => pquant ,
                        vlan_ctl        => vlan_ctl ,
                        len             => tx_len ,
                        frmtype         => frmtype ,
                        cntstart        => cntstart ,
                        cntstep         => cntstep ,       
                        ipg_len         => ipg_len ,
                        wrong_pause_op  => '0' ,
                        wrong_pause_lgth=> '0' ,
                        magic           => '0' ,
                        stack_vlan      => '0' ,
                        payload_err     => payload_err ,
                        prmbl_err       => prmbl_err ,
                        crc_err         => crc_err ,
                        vlan_en         => crc_err ,
                        pause_gen       => pause_gen ,
                        pad_en          => pad_en ,
                        phy_err         => phy_err ,
                        end_err         => end_err ,
                        data_only       => data_only ,
                        start           => frm_gen_ena_gmii ,
                        done            => open) ;
                        
   -- Ethernet Generator Enable / Disable
   -- -----------------------------------
        
        process(reset, tx_clk_sig)
        begin
        
                if (reset='1') then
      
                        frm_gen_ena_gmii <= '0';  
                        frm_gen_ena_mii  <= '0';  
      
                elsif (tx_clk_sig='1') and (tx_clk_sig'event) then
      
      
                        if ((tb_sgmii_ena=FALSE) or (tb_sgmii_ena=TRUE and tb_sgmii_1000=TRUE)) then
        
        
                                frm_gen_ena_mii <= '0';
      
                                if (tx_frm_cnt >= tb_txframes) then
                
                                        frm_gen_ena_gmii <= '0';   
                
                                elsif (state = sim ) then
                
                                        frm_gen_ena_gmii <= '1' after 500 ns;   
                
                                end if ;
        
        
                        else
        
                                frm_gen_ena_gmii <= '0';
      
                                if (tx_frm_cnt >= tb_txframes) then
                
                                        frm_gen_ena_mii <= '0';   
                
                                elsif (state = sim) then
                
                                        frm_gen_ena_mii <= '1' after 500 ns ;   
                
                                end if ;
        
                        end if ;
        
                end if ;
                
        end process ;                   
                                        
   -- Frame Length
   -- ------------
   
        process(reset, tx_clk_sig)
        begin
        
                if (reset='1') then
                
                        tx_len <= conv_std_logic_vector(TB_LENSTART, 16) ;
                        
                elsif (tx_clk_sig='1') and (tx_clk_sig'event) then
                
                        if (tx_sop_gmii='1' or tx_sop_mii='1') then
                        
                                if (tx_len+TB_LENSTEP>=TB_MACLENMAX) then
                                
                                        tx_len <= conv_std_logic_vector(TB_LENSTART, 16) ;
                                        
                                else
                        
                                        tx_len <= (tx_len+TB_LENSTEP) ;
                                        
                                end if ;
                                                                
                        end if ;
                        
                end if ;
                
        end process ; 
        
   -- Transmit Frame Counter                     
   -- ----------------------             
        
        process(reset, tx_clk_sig)
        begin
        
                if (reset='1') then
                
                        tx_frm_cnt <= 0 ;
                        
                elsif (tx_clk_sig='1') and (tx_clk_sig'event) then
                
                        if (tx_sop_gmii='1' or tx_sop_mii='1') then
                        
                                tx_frm_cnt <= tx_frm_cnt+1 ;
                                                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reset, tx_clk_sig)
        begin
        
                if (reset='1') then
                
                        tx_gmii_err_cnt <= 0 ;
                        
                elsif (tx_clk_sig='1') and (tx_clk_sig'event) then
                
                        if ((tx_sop_gmii='1' or tx_sop_mii='1') and phy_err='1') then
                        
                                tx_gmii_err_cnt <= tx_gmii_err_cnt+1 ;
                                                                
                        end if ;
                        
                end if ;
                
        end process ;                 
        
   -- Receive Model
   -- -------------
   
        mii_rxd_tmp <= "0000"&mii_rx_d ;
   
        U_MON2: ethmonitor2 port map (

                reset           => reset,
                tx_clk          => rx_clk_sig,
                txd             => mii_rxd_tmp,
                tx_dv           => mii_rx_dv,
                tx_er           => mii_rx_err,
                tx_sop          => '0',
                tx_eop          => '0',
                ethernet_speed  => '0',
                mii_mode        => '1',
                rgmii_mode      => '0',
                dst             => rx_dst_mii,
                src             => rx_src_mii,
                prmble_len      => open,
                pquant          => open,
                vlan_ctl        => open,
                len             => open,
                frmtype         => open,
                payload         => open,
                payload_vld     => rx_payload_vld_mii,
                is_vlan         => open,
                is_pause        => open,
                crc_err         => rx_crc_err_mii,
                prmbl_err       => rx_preamble_err,
                len_err         => open,
                payload_err     => rx_data_err,
                frame_err       => open,
                pause_op_err    => open,
                pause_dst_err   => open,
                mac_err         => rx_frm_err_mii,
                end_err         => open,
                jumbo_en        => '1',
                data_only       => '0',
                is_stack_vlan   => open,
                frm_rcvd        => frm_rcv_mii);
   
        FRM_MON: ethmonitor port map (

                reset           => reset ,           
                tx_clk          => rx_clk_sig ,
                txd             => gmii_rx_d ,
                tx_dv           => gmii_rx_dv ,
                tx_er           => gmii_rx_err ,
                tx_sop          => '0' ,
                tx_eop          => '0' ,
                dst             => rx_dst_gmii ,
                src             => rx_src_gmii ,
                prmble_len      => open ,
                pquant          => open ,
                vlan_ctl        => open ,
                len             => open ,
                frmtype         => open ,    
                payload         => open ,
                payload_vld     => rx_payload_vld_gmii ,
                is_vlan         => open ,
                is_pause        => open ,
                crc_err         => rx_crc_err_gmii ,
                prmbl_err       => rx_preamble_err ,
                len_err         => open ,
                payload_err     => rx_data_err ,
                frame_err       => open ,
                pause_op_err    => open ,
                pause_dst_err   => open ,
                mac_err         => rx_frm_err_gmii ,
                end_err         => open ,
                jumbo_en        => '1' ,
                data_only       => '0' ,
                frm_rcvd        => frm_rcv_gmii) ;        

        rx_dst         <= rx_dst_gmii when ((tb_sgmii_ena=FALSE) or (tb_sgmii_ena=TRUE and tb_sgmii_1000=TRUE)) else rx_dst_mii ;
        rx_src         <= rx_src_gmii when ((tb_sgmii_ena=FALSE) or (tb_sgmii_ena=TRUE and tb_sgmii_1000=TRUE)) else rx_src_mii ;
        rx_payload_vld <= rx_payload_vld_gmii when ((tb_sgmii_ena=FALSE) or (tb_sgmii_ena=TRUE and tb_sgmii_1000=TRUE)) else rx_payload_vld_mii ;
        
   -- GMII Receive Statistics
   -- -----------------------
           
        process(reset, rx_clk_sig)
        
                variable LN          : line ;
        
        begin
        
                if (reset='1') then
                
                        rx_frm_cnt     <= 0 ;
                        rx_crc_err_cnt <= 0 ;
                        rx_pbl_err_cnt <= 0 ;
                        
                elsif (rx_clk_sig='1') and (rx_clk_sig'event) then
                        
                   -- Number of Frames Received
                   -- -------------------------
                
                        if (frm_rcv_gmii='1' or frm_rcv_mii='1') then
                
                                rx_frm_cnt <= rx_frm_cnt+1 ;
                        
                        end if ;
                
                   -- Number of CRC Errors
                   -- --------------------
                
                        if (frm_rcv_gmii='1' and rx_crc_err_gmii='1' and rx_frm_err_gmii='0') then
                        
                                rx_crc_err_cnt <= rx_crc_err_cnt+1 ;
                        
                                write(LN, string'(" - GMII Rx: CRC Error on Frame ")) ;
                                write(LN, rx_frm_cnt+1) ;
                                writeline(output, LN) ;
                        
                        end if ;
                        
                        if (frm_rcv_mii='1' and rx_crc_err_mii='1' and rx_frm_err_mii='0' and rx_frm_cnt>0) then
                        
                                rx_crc_err_cnt <= rx_crc_err_cnt+1 ;
                        
                                write(LN, string'(" - MII Rx: CRC Error on Frame ")) ;
                                write(LN, rx_frm_cnt+1) ;
                                writeline(output, LN) ;
                        
                        end if ;
                        
                   -- Number of GMII Errors
                   -- ---------------------
                
                        if ((frm_rcv_gmii='1' or frm_rcv_mii='1') and (rx_frm_err_mii='1' or rx_frm_err_gmii='1') and rx_frm_cnt>0) then
                        
                                rx_gmii_err_cnt <= rx_gmii_err_cnt+1 ;
                        
                                write(LN, string'(" - GMII / MII Rx: GMII Error on Frame ")) ;
                                write(LN, rx_frm_cnt+1) ;
                                writeline(output, LN) ;
                        
                        end if ;
                
                   -- Number of Preamble Errors
                   -- -------------------------
                
                        if (rx_preamble_err='1') then
                        
                                rx_pbl_err_cnt <= rx_pbl_err_cnt+1 ;
                                        
                                write(LN, string'(" - GMII Rx: Preamble Error on Frame ")) ;
                                write(LN, rx_frm_cnt+1) ;
                                writeline(output, LN) ;
                        
                        end if ;
                        
                   -- Number of Source MAC Address Errors
                   -- -----------------------------------
                
                        if ((frm_rcv_gmii='1' or frm_rcv_mii='1') and rx_src /= mac_scr and (rx_frm_err_mii='0' and rx_frm_err_gmii='0') and 
                             tb_sgmii_10=FALSE and tx_frm_cnt>0) then
                        
                                rx_src_err_cnt <= rx_src_err_cnt+1 ;
                                        
                                write(LN, string'(" - GMII Rx: Wrong Destination MAC Address on Frame ")) ;
                                write(LN, rx_frm_cnt+1) ;
                                writeline(output, LN) ;
                        
                        end if ;
                        
                   -- Number of Source MAC Address Errors
                   -- -----------------------------------
                
                        if ((frm_rcv_gmii='1'  or  frm_rcv_mii='1') and rx_dst /= mac_dst and (rx_frm_err_mii='0' and rx_frm_err_gmii='0') and 
                             tb_sgmii_10=FALSE and tx_frm_cnt>0) then
                        
                                rx_dst_err_cnt <= rx_dst_err_cnt+1 ;
                                        
                                write(LN, string'(" - GMII Rx: Wrong Destination MAC Address on Frame ")) ;
                                write(LN, rx_frm_cnt+1) ;
                                writeline(output, LN) ;
                        
                        end if ;
                
                   -- Data Error
                   -- ----------
                
                        if (rx_data_err='1' and rx_payload_vld='1') then
                
                                write(LN, string'(" - GMII Rx: Data Error on Frame ")) ;
                                write(LN, rx_frm_cnt+1) ;
                                write(LN, string'(" at ")) ;
                                write(LN, NOW) ;
                                writeline(output, LN) ; 
                        
                        end if ;
                        
                end if ;
                
        end process ; 
        
   -- Simulation Control
   -- ------------------

        process(reset, reg_clk)
        begin

                if (reset='1') then
                
                        reg_busy_reg <= '0' ;                
       
                elsif (reg_clk='1') and (reg_clk'event) then
        
                        reg_busy_reg <= reg_busy ;
                
                end if ;
                
        end process ;

        process(reset, reg_clk)        
        begin
   
                if (reset='1') then
      
                        state <= idle;   
      
                elsif (reg_clk='1') and (reg_clk'event) then
      
                        state <= nextstate;   
                
                end if ;
   
        end process ;

        process(state,sim_start, reg_busy_reg, reg_busy, led_link, rx_frm_cnt, end_cnt, led_an)
        begin
   
                case state is

                        when idle =>
      
                                if (sim_start='1' ) then
                                
                                nextstate <= read_ver;   
      
                                else
                                
                                        nextstate <= idle ;
                                        
                                end if ;
      
                        when read_ver =>
      
                                if (reg_busy = '0' and reg_busy_reg = '1') then
         
                                        nextstate <= wr_scratch;   
         
                                else
         
                                        nextstate <= read_ver;   
         
                                end if ;
                        
                        when wr_scratch =>
      
                                if (reg_busy = '0' and reg_busy_reg = '1') then
         
                                        nextstate <= rd_scratch;   
         
                                else
         
                                        nextstate <= wr_scratch;   
                                
                                end if ;
      
                        when rd_scratch =>
      
                                if (reg_busy = '0' and reg_busy_reg = '1') then
         
                                        nextstate <= if_control;   
         
                                else
         
                                        nextstate <= rd_scratch;   
         
                                end if ;
                        
                        when if_control =>
      
                                if (reg_busy = '0' and reg_busy_reg = '1') then         
         
                                        nextstate <= wait_link; 
                                          
         
                                else
         
                                        nextstate <= if_control;   
         
                                end if ;
                        
                        when wait_link =>
      
                                if (led_link = '1') then
         
                                        nextstate <= read_phy_control;   
         
                                else
         
                                        nextstate <= wait_link;   
         
                                end if;
                                
                        when read_phy_control =>
      
                                if (reg_busy = '0' and reg_busy_reg = '1') then
         
                                        nextstate <= read_sync_status;   
         
                                else
         
                                        nextstate <= read_phy_control;   
         
                                end if ;
                        
                        when read_sync_status =>
      
                                if (reg_busy = '0' and reg_busy_reg = '1') then
         
                                        if (tb_ena_autoneg) then
            
                                                nextstate <= prog_ability;   
            
                                        else
            
                                                nextstate <= autoneg_disable;   
            
                                        end if ;
         
                                else
         
                                        nextstate <= read_sync_status;   
         
                                end if ;
      
                        when autoneg_disable =>
      
                                if (reg_busy = '0' and reg_busy_reg = '1') then
         
                                        nextstate <= sim;   
         
                                else
         
                                        nextstate <= autoneg_disable;   
         
                                end if ;
                        
                        when prog_ability =>
      
                                if (reg_busy = '0' and reg_busy_reg = '1') then
         
                                        nextstate <= prog_timer_1;   
         
                                else
         
                                        nextstate <= prog_ability;   
                                
                                end if ;
      
                        when prog_timer_1 =>
      
                                if (reg_busy = '0' and reg_busy_reg = '1') then
         
                                        nextstate <= prog_timer_2;   
         
                                else
         
                                        nextstate <= prog_timer_1;   
                
                                end if ;
                                
                        when prog_timer_2 =>
      
                                if (reg_busy = '0' and reg_busy_reg = '1') then
         
                                        nextstate <= autoneg_enable;   
         
                                else
         
                                        nextstate <= prog_timer_2;   
         
                                end if ;
                                
                        when autoneg_enable =>
      
                                if (reg_busy = '0' and reg_busy_reg = '1') then
         
                                        nextstate <= start_autoneg;   
         
                                else
         
                                        nextstate <= autoneg_enable;   
         
                                end if ;
                                
                        when start_autoneg =>
      
                                if (reg_busy = '0' and reg_busy_reg = '1') then
         
                                        nextstate <= wait_autoneg;   
         
                                else
         
                                        nextstate <= start_autoneg;   
         
                                end if ;
                                
                        when wait_autoneg =>
      
                                if (led_an='1') then
         
                                        nextstate <= read_autoneg_expansion;   
         
                                else
         
                                        nextstate <= wait_autoneg;   
         
                                end if ;
                        
                        when read_autoneg_expansion =>
      
                                if (reg_busy = '0' and reg_busy_reg = '1') then
         
                                        nextstate <= read_autoneg_status;   
         
                                else
         
                                        nextstate <= read_autoneg_expansion;   
         
                                end if ;
                                
                        when read_autoneg_status =>
      
                                if (reg_busy = '0' and reg_busy_reg = '1') then
         
                                        nextstate <= read_part_ability;   
         
                                else
         
                                        nextstate <= read_autoneg_status;   
         
                                end if ;
                                
                        when read_part_ability =>
      
                                if (reg_busy = '0' and reg_busy_reg = '1') then
         
                                        nextstate <= sim;   
         
                                else
         
                                        nextstate <= read_part_ability;   
         
                                end if ;
                        when sim =>
      
                                if (rx_frm_cnt = tb_txframes) then
         
                                        nextstate <= end_sim;
                   
                                else
         
                                        nextstate <= sim;   
         
                                end if ;
                                
                        when stop_tbi =>
      
                                if (end_cnt > 500) then
         
                                        nextstate <= ena_sw_reset;   
         
                                else
         
                                        nextstate <= stop_tbi;   
         
                                end if ;

                        when ena_sw_reset =>
      
                                if (reg_busy = '0' and reg_busy_reg = '1') then
         
                                        nextstate <= read_sw_reset;   

                                else
         
                                        nextstate <= ena_sw_reset;   
         
                                end if;
                                
                        when read_sw_reset =>
      
                                if (reg_busy = '0' and reg_busy_reg = '1') then
         
                                        nextstate <= start_tbi;   
         
                                else
         
                                        nextstate <= read_sw_reset;   
         
                                end if;
                                
                        when start_tbi =>
      
                                nextstate <= read_status;   
            
                        when read_status =>
      
                                if (reg_busy = '0' and reg_busy_reg = '1') then
         
                                        nextstate <= read_status_2;   
         
                                else
         
                                        nextstate <= read_status;   
         
                                end if ;
                                
                        when read_status_2 =>
      
                                if (reg_busy = '0' and reg_busy_reg = '1') then
         
                                        if (tb_isolate) then
            
                                                nextstate <= read_status;   
            
                                        else
            
                                                nextstate <= end_sim;   
            
                                        end if ;
                                else
         
                                        nextstate <= read_status_2;   
         
                                end if ;      

                        when disable_isolate =>
      
                                if (reg_busy = '0' and reg_busy_reg = '1') then
         
                                        nextstate <= end_sim;   
         
                                else
         
                                        nextstate <= disable_isolate;   
         
                                end if ;
                                
                        when end_sim =>
      
                                nextstate <= end_sim;   
      
                end case ;
   
        end process ;
        
   -- Register Programming
   -- --------------------
   
        process(reset, reg_clk)
        begin
   
                if (reset='1') then
   
                        reg_wr      <= '0'; 
                        reg_rd      <= '0'; 
                        reg_addr    <=  (others=>'0');  
                        reg_data_in <=  (others=>'0');
                        
                elsif (reg_clk='1') and (reg_clk'event) then
          
                        if (nextstate=read_ver) then
      
                                reg_addr    <= "10001";   
                                reg_rd      <= '1';   
                                reg_wr      <= '0';   
                                reg_data_in <= (others=>'0');   
      
                        elsif (nextstate=if_control ) then
      
                                reg_addr  <= "10100";   
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
       
                                reg_data_in(15 downto 5) <= (others=>'0');   
      
                        elsif (nextstate=wr_scratch) then
      
                                reg_addr    <= "10000";   
                                reg_rd      <= '0';   
                                reg_wr      <= '1';   
                                reg_data_in <= X"AAAA";   
      
                        elsif (nextstate=rd_scratch ) then
      
                                reg_addr    <= "10000";   
                                reg_rd      <= '1';   
                                reg_wr      <= '0';   
                                reg_data_in <= (others=>'0');   
      
                        elsif (nextstate=read_sync_status or nextstate = read_status or 
                               nextstate = read_status_2 ) then
      
                                reg_addr    <= "00001";   
                                reg_rd      <= '1';   
                                reg_wr      <= '0';   
                                reg_data_in <= (others=>'0');   
      
                        elsif (nextstate=read_phy_control ) then
      
                                reg_addr     <= "00000";   
                                reg_rd       <= '1';   
                                reg_wr       <= '0';   
                                reg_data_in  <= (others=>'0');   
      
                        elsif (nextstate=prog_ability ) then
      
                                reg_addr                <= "00100";   
                                reg_rd                  <= '0';   
                                reg_wr                  <= '1';   
                                reg_data_in(4 downto 0) <= "00000";   
                                reg_data_in(5)          <= '1';   
                                reg_data_in(6)          <= '0';   
      
                                if (tb_pcs_ps1) then
         
                                        reg_data_in(7) <= '1';   
         
                                else
         
                                        reg_data_in(7) <= '0';   
         
                                end if ;
      
                                if (tb_pcs_ps2) then
         
                                        reg_data_in(8) <= '1';   
         
                                else
         
                                        reg_data_in(8) <= '0';   
                                
                                end if ;
      
                                reg_data_in(11 downto 9) <= "000" ;   
                                
                                if (tb_pcs_rf1) then
         
                                        reg_data_in(12) <= '1';   
         
                                else
         
                                        reg_data_in(12) <= '0';   
                                
                                end if ;
      
                                if (tb_pcs_rf2) then
         
                                        reg_data_in(13) <= '1';   
         
                                else
         
                                        reg_data_in(13) <= '0';   
         
                                end if ;
                                
                                reg_data_in(15 downto 14) <= "00";   
                              
                        elsif (nextstate=prog_timer_1 ) then
      
                                reg_addr    <= "10010";   
                                reg_rd      <= '0';   
                                reg_wr      <= '1';   
                                reg_data_in <= link_timer_reg(15 downto 0);   
      
                        elsif (nextstate=prog_timer_2 ) then
      
                                reg_addr    <= "10011";   
                                reg_rd      <= '0';   
                                reg_wr      <= '1';   
                                reg_data_in <= link_timer_reg(31 downto 16);   
      
                        elsif (nextstate=autoneg_enable ) then
      
                                reg_addr    <= "00000";   
                                reg_rd      <= '0';   
                                reg_wr      <= '1';   
                                reg_data_in <= "0001000000000000";   
      
                        elsif (nextstate=autoneg_disable ) then
      
                                reg_addr    <= "00000";   
                                reg_rd      <= '0';   
                                reg_wr      <= '1';   
                                reg_data_in <= "0000001000000000";   
      
                        elsif (nextstate=start_autoneg ) then
      
                                reg_addr    <= "00000";   
                                reg_rd      <= '0';   
                                reg_wr      <= '1';   
                                reg_data_in <= "0001001000000000";   
      
                        elsif (nextstate=read_part_ability ) then
      
                                reg_addr    <= "00101";   
                                reg_rd      <= '1';   
                                reg_wr      <= '0';   
                                reg_data_in <= (others=>'0');   
      
                        elsif (nextstate=read_autoneg_status ) then
      
                                reg_addr    <= "00001";   
                                reg_rd      <= '1';   
                                reg_wr      <= '0';   
                                reg_data_in <= (others=>'0');   
      
                        elsif (nextstate=read_autoneg_expansion ) then
      
                                reg_addr    <= "00110";   
                                reg_rd      <= '1';   
                                reg_wr      <= '0';   
                                reg_data_in <= (others=>'0');   
      
                        elsif (nextstate=ena_sw_reset ) then
      
                                reg_addr    <= "00000";   
                                reg_rd      <= '0';   
                                reg_wr      <= '1';   
                                reg_data_in <= (others=>'0');   
      
                        elsif (nextstate=read_sw_reset ) then
      
                                reg_addr    <= "00000";   
                                reg_rd      <= '1';   
                                reg_wr      <= '0';   
                                reg_data_in <= (others=>'0');      
      
                        elsif (nextstate=disable_isolate ) then
      
                                reg_addr    <= "00000";   
                                reg_rd      <= '0';   
                                reg_wr      <= '1';   
                                reg_data_in <= (others=>'0');   
      
                        else
      
                                reg_addr     <= "00000";   
                                reg_rd       <= '0';   
                                reg_wr       <= '0';   
                                reg_data_in  <= (others=>'0');   
      
                        end if ;
                        
                end if ;
                
        end process ;
        
   -- Simulation Status
   -- -----------------
   
        process(reg_clk)
        
                variable ln : line ;
                
        begin
        
           if (reg_clk='0' and reg_clk'event) then
        
                if (state=read_ver and reg_busy='0' and reg_busy_reg='1') then
                
                                writeline(output, ln) ;
                                write(ln, string'(" ")) ;
                                writeline(output, ln) ;
                                write(ln, string'(" - ---------------------------------------------------------------------------------------- -")) ;
                                writeline(output, ln) ;
                                write(ln, string'(" -- Testbench for 1000Base-X PCS with SGMII + PMA --")) ;
                                writeline(output, ln) ;
                                write(ln, string'(" -- (c) ALTERA CORPORATION 2007  --")) ;
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
          
                elsif (state=rd_scratch and reg_busy='0' and reg_busy_reg='1' ) then
                
                        write(ln, string'("   - Read Scratch Register : 0x")) ;
                        write_hex(ln, (reg_data_out)) ;
                        writeline(output, ln) ;
                        readback_scratch <= reg_data_out;
   
                elsif ((state=read_sync_status or state=read_status or state=read_status_2) and reg_busy='0' and reg_busy_reg='1' ) then
                
                        write(ln, string'("   - Check Link Status : ")) ;
                        writeline(output, ln) ;
                        writeline(output, ln) ;
      
                        if (reg_data_out(2)='1') then
        
                                write(ln, string'("             Link Acquired")) ;
                                writeline(output, ln) ;
                
                        else
        
                                write(ln, string'("             Link not Acquired")) ;
                                writeline(output, ln) ;
                
                        end if ;
                        
                        writeline(output, ln) ;
                        
                elsif (state=read_sw_reset and reg_busy='0' and reg_busy_reg='1' ) then
     
                        write(ln, string'("  - Check if Self-Clearing MDIO Reset Bit is Cleared : ")) ;
                        writeline(output, ln) ;
        
                        if (reg_data_out(15)='1') then
        
                                write(ln, string'("             Reset Command bit not Cleared")) ;
                                writeline(output, ln) ; 
                
                        else
        
                                write(ln, string'("             Reset Command bit Correctly Cleared")) ;
                                writeline(output, ln) ;
                
                        end if ;
                           
                elsif (state=read_phy_control and reg_busy='0' and reg_busy_reg='1' ) then
     
                        writeline(output, ln) ;
                        write(ln, string'("  - Checking PCS Capabilies (MDIO Control Register):")) ;
                        writeline(output, ln) ;
                        writeline(output, ln) ;

                        if (reg_data_out(6)='1' and reg_data_out(13)='0') then
        
                                write(ln, string'("             Speed: 1000Mbps")) ; 
                                writeline(output, ln) ;
                
                        else
        
                                write(ln, string'("             Speed: ERROR")) ; 
                                writeline(output, ln) ;
                
                        end if ;  
     
                        if (reg_data_out(7)='0') then
     
                                write(ln, string'("             Colision Test: Not Supported")) ;
                                writeline(output, ln) ;
                
                        else
        
                                write(ln, string'("             Colision Test: ERROR")) ;
                                writeline(output, ln) ;
                
                        end if ;
                        
                        writeline(output, ln) ;
     
                elsif (state=read_autoneg_expansion and reg_busy='0' and reg_busy_reg='1' ) then
      
                        if (reg_data_out(2)='1') then
        
                                write(ln, string'("             Page(s) Received from Link Partner")) ;
                                writeline(output, ln) ;
                
                        else
        
                                write(ln, string'("             Page NOT Received from Link Partner")) ; 
                                writeline(output, ln) ; 
                
                        end if ;
                        
                        writeline(output, ln) ;
     
                elsif (state=read_autoneg_status and reg_busy='0' and reg_busy_reg='1' ) then
     
                        if (reg_data_out(5)='1') then
        
                                write(ln, string'("             Auto-Negotiation Completed")) ;  
                                writeline(output, ln) ;
                
                        else
        
                                write(ln, string'("             Auto-Negotiation Not Completed")) ;
                                writeline(output, ln) ;
                
                        end if ;
                        
                        writeline(output, ln) ;
                        
                elsif (state=read_part_ability and reg_busy='0' and reg_busy_reg='1' ) then
     
                        write(ln, string'("  - Advertised Link Partner Ability:"));
                        writeline(output, ln) ;
                        writeline(output, ln) ;
        
                        if (tb_sgmii_ena=FALSE) then
        
                                if (reg_data_out(15)='1') then
        
                                        write(ln, string'("             Link Partner Supports Next Page")) ; 
                                        writeline(output, ln) ;
                
                                else
        
                                        write(ln, string'("             Link Partner does not Support Next Page")) ;
                                        writeline(output, ln) ;
                                        
                                end if ;
                
                                if (reg_data_out(8 downto 7)="11") then
        
                                        write(ln, string'("             Link Partner Advertises Symetric and Asymetric Pause Support"));
                                        writeline(output, ln) ;
                
                                elsif (reg_data_out(8 downto 7)="10") then
        
                                        write(ln, string'("             Link Partner Advertises Asymetric Towards Link Partner Support"));
                                        writeline(output, ln) ;
                
                                elsif (reg_data_out(8 downto 7)="01") then
        
                                        write(ln, string'("             Link Partner Advertises Symetric Pause Support"));   
                                        writeline(output, ln) ;
                
                                else
        
                                        write(ln, string'("             Link Partner Advertises no Support Pause"));
                                        writeline(output, ln) ;
                                        
                                end if ;  
                         
                                if (reg_data_out(13 downto 12)="00") then
        
                                        write(ln, string'("             Link Partner Advertises no Remote Fault")); 
                                        writeline(output, ln) ;
                
                                else
                
                                        write(ln, string'("             Link Partner Advertises a Remote Fault")); 
                                        writeline(output, ln) ;
                                        
                                end if ; 
                
                                if (reg_data_out(6)='1') then
        
                                        write(ln, string'("             Link Partner Supports Half Duplex Operation"));
                                        writeline(output, ln) ;
                
                                else
        
                                        write(ln, string'("             Link Partner does not Support Half Duplex Operation"));
                                        writeline(output, ln) ;
                
                                end if ;            

                                if (reg_data_out(5)='1') then
        
                                        write(ln, string'("             Link Partner Supports Full Duplex Operation")); 
                                        writeline(output, ln) ; 
                
                                else
        
                                        write(ln, string'("             Link Partner does not Support Full Duplex Operation"));
                                        writeline(output, ln) ;
                
                                end if ;
                                
                                writeline(output, ln) ;
                
                        else
        
                                if (reg_data_out(11 downto 10)="00") then
        
                                        write(ln, string'("             Link Partner Supports 10Mbps Operation"));
                                        writeline(output, ln) ; 
                
                                elsif (reg_data_out(11 downto 10)="01") then
        
                                        write(ln, string'("             Link Partner Supports 100Mbps Operation")); 
                                        writeline(output, ln) ;
                
                                else
        
                                        write(ln, string'("             Link Partner Supports Gigabit Operation"));
                                        writeline(output, ln) ;
                
                                end if ;
                
                                if (reg_data_out(12)='0') then
        
                                        write(ln, string'("             Link Partner Supports Full Duplex Operation"));
                                        writeline(output, ln) ;  
                
                                else
        
                                        write(ln, string'("             Link Partner does not Support Full Duplex Operation"));
                                        writeline(output, ln) ;
                
                                end if ;
                                
                                writeline(output, ln) ;
                
                        end if ;                  

                end if ;
                
           end if;
      
        end process ;
        
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=WR_SCRATCH) then
                
                        write(ln, string'("   - write Scratch Register : 0xaaaa")) ;
                        writeline(output, ln) ;
                        
                elsif (state=PROG_ABILITY) then
                
                        write(ln, string'("   - Set Core Ability")) ;
                        writeline(output, ln) ;
                        write(ln, string'(" ")) ;                               
                        writeline(output, ln) ; 
                        
                elsif (state=AUTONEG_ENABLE) then
                
                        
                        write(ln, string'("   - Enable Auto Negotiation")) ;
                        writeline(output, ln) ;
                        write(ln, string'(" ")) ;                               
                        writeline(output, ln) ;  
                        
                elsif (state=PROG_TIMER_1) then
                
                        
                        write(ln, string'("   - Programming Link Timer")) ;
                        writeline(output, ln) ;
                        write(ln, string'(" ")) ;                               
                        writeline(output, ln) ; 
                        
                elsif (state=START_AUTONEG) then
                
                        
                        write(ln, string'("   - Start Auto-Negotiation")) ;
                        writeline(output, ln) ;
                        write(ln, string'(" ")) ;                               
                        writeline(output, ln) ;  
                        
                elsif (state=READ_PART_ABILITY) then
                
                        write(ln, string'("   - Read Partner Ability")) ;
                        writeline(output, ln) ;
                        write(ln, string'(" ")) ;                               
                        writeline(output, ln) ; 
                        
                elsif (state=READ_AUTONEG_STATUS) then
                
                        write(ln, string'("   - Read Auto-Negotiation Results")) ;
                        writeline(output, ln) ;
                        write(ln, string'(" ")) ;                               
                        writeline(output, ln) ; 
                        
                elsif (state=READ_AUTONEG_EXPANSION) then
                
                        write(ln, string'("   - Read Auto-Negotiation Expansion Register")) ;
                        writeline(output, ln) ;
                        write(ln, string'(" ")) ;                               
                        writeline(output, ln) ;
                        
                elsif (state=ENA_SW_RESET) then
                
                        write(LN, string'(" -- ---------------------------------------------------------- --")) ;  
                        writeline(output, LN) ;
                        write(LN, string'(" ")) ;   
                        writeline(output, LN) ;
                        write(LN, string'("   Test Self Clearing MDIO Reset Command bit")) ; 
                        writeline(output, LN) ; 
                        write(LN, string'(" ")) ;   
                        writeline(output, LN) ; 
                        
                elsif (state=DISABLE_ISOLATE) then
                                        
                        write(LN, string'("   Disable PHY Isolation")) ; 
                        writeline(output, LN) ; 
                        write(LN, string'(" ")) ;   
                        writeline(output, LN) ;
                        write(LN, string'(" -- ---------------------------------------------------------- --")) ;  
                        writeline(output, LN) ;
                        write(LN, string'(" ")) ;   
                        writeline(output, LN) ;                                                 
                        
                elsif (state=SIM) then
                
                        
                        write(LN, string'(" -- ---------------------------------------------------------- --")) ;  
                        writeline(output, LN) ;
                        write(LN, string'(" ")) ;   
                        writeline(output, LN) ;
                        write(LN, string'("    Start Simulation")) ; 
                        writeline(output, LN) ; 
                        write(LN, string'(" ")) ;   
                        writeline(output, LN) ;                                                                                                                 
                        
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
               if (nextstate = END_SIM and state = SIM) then
                     -- expected scratch register readback is 0xaaaa
                     if (readback_scratch /= x"aaaa") then
                          write(ln, string'("      Register test failed on SCRATCH register")) ;
                          writeline(output, ln) ;  
                          register_test <= 1;
                     end if;
     
               end if;
            end if;   
        end process;


        
   -- End of Simulation
   -- -----------------
   
        process(reset, rx_clk_sig)
        
                variable ln : line ;
        
        begin
        
                if (reset='1') then
                
                        end_cnt <= 0 ;
                        
                elsif (rx_clk_sig='1') and (rx_clk_sig'event) then
                
                        if (state=STOP_TBI) then
                        
                                if (end_cnt=50) then
                                
                                        write(LN, string'(" ")) ;   
                                        writeline(output, LN) ;                                        
                                        write(LN, string'("    End of Simulation")) ; 
                                        writeline(output, LN) ;
                                        write(LN, string'(" ")) ;   
                                        writeline(output, LN) ;
                                        write(LN, string'(" -- ---------------------------------------------------------- --")) ;  
                                        writeline(output, LN) ;
                                        write(LN, string'(" ")) ;
                                        writeline(output, LN) ;
                                        write(LN, string'("   Checking Latch Low Link MDIO bit")) ;
                                        writeline(output, LN) ;
                                        write(LN, string'(" ")) ;
                                        writeline(output, LN) ;
                        
                                        end_cnt <= end_cnt+1 ;
                                        
                                else
                                
                                        end_cnt <= end_cnt+1 ;
                                        
                                end if ;                
                
                        elsif (state=END_SIM) then
                        
                                if (end_cnt=300) then
                                                                           
                                        write(LN, string'(" -- ---------------------------------------------------------- --")) ;  
                                        writeline(output, LN) ;
                                        write(LN, string'(" ")) ;
                                        writeline(output, LN) ;
                                        write(LN, string'("   Simulation Results:")) ;   
                                        writeline(output, LN) ;
                                        write(LN, string'(" ")) ;   
                                        writeline(output, LN) ;
                                        write(LN, string'("        - Transmitted Frames: ")) ;
                                        write(LN, tx_frm_cnt) ;   
                                        writeline(output, LN) ;
                                        write(LN, string'("        - Received Frames: ")) ;
                                        write(LN, rx_frm_cnt) ;   
                                        writeline(output, LN) ;
                                        write(LN, string'("        - CRC Errors: ")) ;
                                        write(LN, rx_crc_err_cnt) ;   
                                        writeline(output, LN) ;
                                        write(LN, string'("        - Preamble Errors: ")) ;
                                        write(LN, rx_pbl_err_cnt) ;
                                        writeline(output, LN) ; 
                                        write(LN, string'("        - MII / GMII Error Received: ")) ;
                                        write(LN, rx_gmii_err_cnt) ;
                                        writeline(output, LN) ; 
                                        write(LN, string'("        - MII / GMII Error Transmitted: ")) ;
                                        write(LN, tx_gmii_err_cnt) ;
                                        writeline(output, LN) ;
                                        write(LN, string'("        - Header Errors (Wrong Source MAC Address): ")) ;
                                        write(LN, rx_src_err_cnt) ;
                                        writeline(output, LN) ; 
                                        write(LN, string'("        - Header Errors (Wrong Destination MAC Address): ")) ;
                                        write(LN, rx_dst_err_cnt) ;
                                        writeline(output, LN) ;                                        
                                        write(LN, string'(" ")) ;   
                                        writeline(output, LN) ;
                                        
                                        end_cnt <= end_cnt+1 ;
                                        
                                elsif (end_cnt=500) then
                                

                                        if ((rx_frm_cnt        = tx_frm_cnt) and
                                            (rx_crc_err_cnt    = 0) and
                                            (rx_pbl_err_cnt    = 0) and
                                            (rx_gmii_err_cnt   = tx_gmii_err_cnt) and
                                            (register_test     = 0) and
                                            (rx_src_err_cnt    = 0) and
                                            (rx_dst_err_cnt    = 0) and
                                            (tx_frm_cnt        = tb_txframes) ) then
                                        
                                                write(LN, string'(" -- -- Loopback Simulation Ended with no Error  --")) ;  
                                                writeline(output, LN) ;
                                        else
                                                write(LN, string'(" -- -- Loopback Simulation Ended with Error ! --")) ;  
                                                writeline(output, LN) ;

                                        end if;
                                        
                        
                                        write(LN, string'(" -- ---------------------------------------------------------- --")) ;  
                                        writeline(output, LN) ;

                                
                                        assert false report "End of simulation - forced by testbench" severity failure  ;
                                        
                                else
                                
                                        end_cnt <= end_cnt+1 ;
                                        
                                        
                                end if ;
                                
                        else
                        
                                end_cnt <= 0 ;        
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
end a ;                                
