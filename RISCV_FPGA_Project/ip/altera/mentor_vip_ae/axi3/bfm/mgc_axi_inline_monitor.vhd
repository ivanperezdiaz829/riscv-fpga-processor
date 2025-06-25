-- *****************************************************************************
--
-- Copyright 2007-2013 Mentor Graphics Corporation
-- All Rights Reserved.
--
-- THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF
-- MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
--
-- *****************************************************************************
--            Version: 20130911_Questa_10.2c
-- *****************************************************************************

-- Title: mgc_axi_inline_monitor
--
--
-- This is a wrapper around the SystemVerilog BFM wrapper
-- It provides a semi-abstract interface to the VHDL BFM interface package
-- and routes the BFM signals through to the DUT in the testbench
--

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.all;
use work.mgc_axi_bfm_pkg.all;

entity mgc_axi_inline_monitor_vhd is
    generic(
            AXI_ADDRESS_WIDTH : integer := 64;
            AXI_RDATA_WIDTH : integer := 1024;
            AXI_WDATA_WIDTH : integer := 1024;
            AXI_ID_WIDTH : integer := 18;
            index : integer range 0 to 511 := 0
           );
    port(
        ACLK            : in std_logic;
        ARESETn         : in std_logic;
        master_AWVALID         : out std_logic;
        master_AWADDR          : out std_logic_vector(((AXI_ADDRESS_WIDTH) - 1) downto 0);
        master_AWLEN           : out std_logic_vector(3 downto 0);
        master_AWSIZE          : out std_logic_vector(2 downto 0);
        master_AWBURST         : out std_logic_vector(1 downto 0);
        master_AWLOCK          : out std_logic_vector(1 downto 0);
        master_AWCACHE         : out std_logic_vector(3 downto 0);
        master_AWPROT          : out std_logic_vector(2 downto 0);
        master_AWID            : out std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
        master_AWREADY         : in std_logic;
        master_AWUSER          : out std_logic_vector(7 downto 0);
        master_ARVALID         : out std_logic;
        master_ARADDR          : out std_logic_vector(((AXI_ADDRESS_WIDTH) - 1) downto 0);
        master_ARLEN           : out std_logic_vector(3 downto 0);
        master_ARSIZE          : out std_logic_vector(2 downto 0);
        master_ARBURST         : out std_logic_vector(1 downto 0);
        master_ARLOCK          : out std_logic_vector(1 downto 0);
        master_ARCACHE         : out std_logic_vector(3 downto 0);
        master_ARPROT          : out std_logic_vector(2 downto 0);
        master_ARID            : out std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
        master_ARREADY         : in std_logic;
        master_ARUSER          : out std_logic_vector(7 downto 0);
        master_RVALID          : in std_logic;
        master_RLAST           : in std_logic;
        master_RDATA           : in std_logic_vector(((AXI_RDATA_WIDTH) - 1) downto 0);
        master_RRESP           : in std_logic_vector(1 downto 0);
        master_RID             : in std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
        master_RREADY          : out std_logic;
        master_WVALID          : out std_logic;
        master_WLAST           : out std_logic;
        master_WDATA           : out std_logic_vector(((AXI_WDATA_WIDTH) - 1) downto 0);
        master_WSTRB           : out std_logic_vector((((AXI_WDATA_WIDTH / 8)) - 1) downto 0);
        master_WID             : out std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
        master_WREADY          : in std_logic;
        master_BVALID          : in std_logic;
        master_BRESP           : in std_logic_vector(1 downto 0);
        master_BID             : in std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
        master_BREADY          : out std_logic;

        slave_AWVALID         : in std_logic;
        slave_AWADDR          : in std_logic_vector(((AXI_ADDRESS_WIDTH) - 1) downto 0);
        slave_AWLEN           : in std_logic_vector(3 downto 0);
        slave_AWSIZE          : in std_logic_vector(2 downto 0);
        slave_AWBURST         : in std_logic_vector(1 downto 0);
        slave_AWLOCK          : in std_logic_vector(1 downto 0);
        slave_AWCACHE         : in std_logic_vector(3 downto 0);
        slave_AWPROT          : in std_logic_vector(2 downto 0);
        slave_AWID            : in std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
        slave_AWREADY         : out std_logic;
        slave_AWUSER          : in std_logic_vector(7 downto 0);
        slave_ARVALID         : in std_logic;
        slave_ARADDR          : in std_logic_vector(((AXI_ADDRESS_WIDTH) - 1) downto 0);
        slave_ARLEN           : in std_logic_vector(3 downto 0);
        slave_ARSIZE          : in std_logic_vector(2 downto 0);
        slave_ARBURST         : in std_logic_vector(1 downto 0);
        slave_ARLOCK          : in std_logic_vector(1 downto 0);
        slave_ARCACHE         : in std_logic_vector(3 downto 0);
        slave_ARPROT          : in std_logic_vector(2 downto 0);
        slave_ARID            : in std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
        slave_ARREADY         : out std_logic;
        slave_ARUSER          : in std_logic_vector(7 downto 0);
        slave_RVALID          : out std_logic;
        slave_RLAST           : out std_logic;
        slave_RDATA           : out std_logic_vector(((AXI_RDATA_WIDTH) - 1) downto 0);
        slave_RRESP           : out std_logic_vector(1 downto 0);
        slave_RID             : out std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
        slave_RREADY          : in std_logic;
        slave_WVALID          : in std_logic;
        slave_WLAST           : in std_logic;
        slave_WDATA           : in std_logic_vector(((AXI_WDATA_WIDTH) - 1) downto 0);
        slave_WSTRB           : in std_logic_vector((((AXI_WDATA_WIDTH / 8)) - 1) downto 0);
        slave_WID             : in std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
        slave_WREADY          : out std_logic;
        slave_BVALID          : out std_logic;
        slave_BRESP           : out std_logic_vector(1 downto 0);
        slave_BID             : out std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
        slave_BREADY          : in std_logic
        );
end mgc_axi_inline_monitor_vhd;

architecture inline_monitor_a of mgc_axi_inline_monitor_vhd is

component mgc_axi_monitor_vhd is
    generic(
            AXI_ADDRESS_WIDTH : integer := 64;
            AXI_RDATA_WIDTH : integer := 1024;
            AXI_WDATA_WIDTH : integer := 1024;
            AXI_ID_WIDTH : integer := 18;
            index : integer range 0 to 511 := 0
           );
    port(
        ACLK            : in std_logic;
        ARESETn         : in std_logic;
        AWVALID         : in std_logic;
        AWADDR          : in std_logic_vector(((AXI_ADDRESS_WIDTH) - 1) downto 0);
        AWLEN           : in std_logic_vector(3 downto 0);
        AWSIZE          : in std_logic_vector(2 downto 0);
        AWBURST         : in std_logic_vector(1 downto 0);
        AWLOCK          : in std_logic_vector(1 downto 0);
        AWCACHE         : in std_logic_vector(3 downto 0);
        AWPROT          : in std_logic_vector(2 downto 0);
        AWID            : in std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
        AWREADY         : in std_logic;
        AWUSER          : in std_logic_vector(7 downto 0);
        ARVALID         : in std_logic;
        ARADDR          : in std_logic_vector(((AXI_ADDRESS_WIDTH) - 1) downto 0);
        ARLEN           : in std_logic_vector(3 downto 0);
        ARSIZE          : in std_logic_vector(2 downto 0);
        ARBURST         : in std_logic_vector(1 downto 0);
        ARLOCK          : in std_logic_vector(1 downto 0);
        ARCACHE         : in std_logic_vector(3 downto 0);
        ARPROT          : in std_logic_vector(2 downto 0);
        ARID            : in std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
        ARREADY         : in std_logic;
        ARUSER          : in std_logic_vector(7 downto 0);
        RVALID          : in std_logic;
        RLAST           : in std_logic;
        RDATA           : in std_logic_vector(((AXI_RDATA_WIDTH) - 1) downto 0);
        RRESP           : in std_logic_vector(1 downto 0);
        RID             : in std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
        RREADY          : in std_logic;
        WVALID          : in std_logic;
        WLAST           : in std_logic;
        WDATA           : in std_logic_vector(((AXI_WDATA_WIDTH) - 1) downto 0);
        WSTRB           : in std_logic_vector((((AXI_WDATA_WIDTH / 8)) - 1) downto 0);
        WID             : in std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
        WREADY          : in std_logic;
        BVALID          : in std_logic;
        BRESP           : in std_logic_vector(1 downto 0);
        BID             : in std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
        BREADY          : in std_logic
        );
end component;

begin

-- connect master and slave ends:
    master_AWVALID        <= slave_AWVALID;
    master_AWADDR         <= slave_AWADDR;
    master_AWLEN          <= slave_AWLEN;
    master_AWSIZE         <= slave_AWSIZE;
    master_AWBURST        <= slave_AWBURST;
    master_AWLOCK         <= slave_AWLOCK;
    master_AWCACHE        <= slave_AWCACHE;
    master_AWPROT         <= slave_AWPROT;
    master_AWID           <= slave_AWID;
    slave_AWREADY         <= master_AWREADY;
    master_AWUSER         <= slave_AWUSER;
    master_ARVALID        <= slave_ARVALID;
    master_ARADDR         <= slave_ARADDR;
    master_ARLEN          <= slave_ARLEN;
    master_ARSIZE         <= slave_ARSIZE;
    master_ARBURST        <= slave_ARBURST;
    master_ARLOCK         <= slave_ARLOCK;
    master_ARCACHE        <= slave_ARCACHE;
    master_ARPROT         <= slave_ARPROT;
    master_ARID           <= slave_ARID;
    slave_ARREADY         <= master_ARREADY;
    master_ARUSER         <= slave_ARUSER;
    slave_RVALID          <= master_RVALID;
    slave_RLAST           <= master_RLAST;
    slave_RDATA           <= master_RDATA;
    slave_RRESP           <= master_RRESP;
    slave_RID             <= master_RID;
    master_RREADY         <= slave_RREADY;
    master_WVALID         <= slave_WVALID;
    master_WLAST          <= slave_WLAST;
    master_WDATA          <= slave_WDATA;
    master_WSTRB          <= slave_WSTRB;
    master_WID            <= slave_WID;
    slave_WREADY          <= master_WREADY;
    slave_BVALID          <= master_BVALID;
    slave_BRESP           <= master_BRESP;
    slave_BID             <= master_BID;
    master_BREADY         <= slave_BREADY;

-- Instantiation of the VHDL monitor:
mgc_axi_monitor_vhd_inst: mgc_axi_monitor_vhd
    generic map(
        AXI_ADDRESS_WIDTH => AXI_ADDRESS_WIDTH,
        AXI_RDATA_WIDTH => AXI_RDATA_WIDTH,
        AXI_WDATA_WIDTH => AXI_WDATA_WIDTH,
        AXI_ID_WIDTH    => AXI_ID_WIDTH,
        index           => index
    )
    port map(
        ACLK       => ACLK,
        ARESETn    => ARESETn,
        AWVALID    => slave_AWVALID,
        AWADDR     => slave_AWADDR,
        AWLEN      => slave_AWLEN,
        AWSIZE     => slave_AWSIZE,
        AWBURST    => slave_AWBURST,
        AWLOCK     => slave_AWLOCK,
        AWCACHE    => slave_AWCACHE,
        AWPROT     => slave_AWPROT,
        AWID       => slave_AWID,
        AWREADY    => master_AWREADY,
        AWUSER     => slave_AWUSER,
        ARVALID    => slave_ARVALID,
        ARADDR     => slave_ARADDR,
        ARLEN      => slave_ARLEN,
        ARSIZE     => slave_ARSIZE,
        ARBURST    => slave_ARBURST,
        ARLOCK     => slave_ARLOCK,
        ARCACHE    => slave_ARCACHE,
        ARPROT     => slave_ARPROT,
        ARID       => slave_ARID,
        ARREADY    => master_ARREADY,
        ARUSER     => slave_ARUSER,
        RVALID     => master_RVALID,
        RLAST      => master_RLAST,
        RDATA      => master_RDATA,
        RRESP      => master_RRESP,
        RID        => master_RID,
        RREADY     => slave_RREADY,
        WVALID     => slave_WVALID,
        WLAST      => slave_WLAST,
        WDATA      => slave_WDATA,
        WSTRB      => slave_WSTRB,
        WID        => slave_WID,
        WREADY     => master_WREADY,
        BVALID     => master_BVALID,
        BRESP      => master_BRESP,
        BID        => master_BID,
        BREADY     => slave_BREADY
        );
end inline_monitor_a;
