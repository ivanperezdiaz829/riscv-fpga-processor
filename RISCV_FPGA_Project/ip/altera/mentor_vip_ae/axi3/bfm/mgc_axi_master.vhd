-- *****************************************************************************
--
-- Copyright 2007-2013 Mentor Graphics Corporation
-- All Rights Reserved.
--
-- THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF
-- MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
--
-- *****************************************************************************
-- dvc           Version: 20130911_Questa_10.2c
-- *****************************************************************************

-- Title: axi_master_bfm
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

entity mgc_axi_master_vhd is
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
        AWVALID         : out std_logic;
        AWADDR          : out std_logic_vector(((AXI_ADDRESS_WIDTH) - 1) downto 0);
        AWLEN           : out std_logic_vector(3 downto 0);
        AWSIZE          : out std_logic_vector(2 downto 0);
        AWBURST         : out std_logic_vector(1 downto 0);
        AWLOCK          : out std_logic_vector(1 downto 0);
        AWCACHE         : out std_logic_vector(3 downto 0);
        AWPROT          : out std_logic_vector(2 downto 0);
        AWID            : out std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
        AWREADY         : in std_logic;
        AWUSER          : out std_logic_vector(7 downto 0);
        ARVALID         : out std_logic;
        ARADDR          : out std_logic_vector(((AXI_ADDRESS_WIDTH) - 1) downto 0);
        ARLEN           : out std_logic_vector(3 downto 0);
        ARSIZE          : out std_logic_vector(2 downto 0);
        ARBURST         : out std_logic_vector(1 downto 0);
        ARLOCK          : out std_logic_vector(1 downto 0);
        ARCACHE         : out std_logic_vector(3 downto 0);
        ARPROT          : out std_logic_vector(2 downto 0);
        ARID            : out std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
        ARREADY         : in std_logic;
        ARUSER          : out std_logic_vector(7 downto 0);
        RVALID          : in std_logic;
        RLAST           : in std_logic;
        RDATA           : in std_logic_vector(((AXI_RDATA_WIDTH) - 1) downto 0);
        RRESP           : in std_logic_vector(1 downto 0);
        RID             : in std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
        RREADY          : out std_logic;
        WVALID          : out std_logic;
        WLAST           : out std_logic;
        WDATA           : out std_logic_vector(((AXI_WDATA_WIDTH) - 1) downto 0);
        WSTRB           : out std_logic_vector((((AXI_WDATA_WIDTH / 8)) - 1) downto 0);
        WID             : out std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
        WREADY          : in std_logic;
        BVALID          : in std_logic;
        BRESP           : in std_logic_vector(1 downto 0);
        BID             : in std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
        BREADY          : out std_logic
        );
end mgc_axi_master_vhd;

architecture master_a of mgc_axi_master_vhd is

component mgc_axi_master
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
        AWVALID         : out std_logic;
        AWADDR          : out std_logic_vector(((AXI_ADDRESS_WIDTH) - 1) downto 0);
        AWLEN           : out std_logic_vector(3 downto 0);
        AWSIZE          : out std_logic_vector(2 downto 0);
        AWBURST         : out std_logic_vector(1 downto 0);
        AWLOCK          : out std_logic_vector(1 downto 0);
        AWCACHE         : out std_logic_vector(3 downto 0);
        AWPROT          : out std_logic_vector(2 downto 0);
        AWID            : out std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
        AWREADY         : in std_logic;
        AWUSER          : out std_logic_vector(7 downto 0);
        ARVALID         : out std_logic;
        ARADDR          : out std_logic_vector(((AXI_ADDRESS_WIDTH) - 1) downto 0);
        ARLEN           : out std_logic_vector(3 downto 0);
        ARSIZE          : out std_logic_vector(2 downto 0);
        ARBURST         : out std_logic_vector(1 downto 0);
        ARLOCK          : out std_logic_vector(1 downto 0);
        ARCACHE         : out std_logic_vector(3 downto 0);
        ARPROT          : out std_logic_vector(2 downto 0);
        ARID            : out std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
        ARREADY         : in std_logic;
        ARUSER          : out std_logic_vector(7 downto 0);
        RVALID          : in std_logic;
        RLAST           : in std_logic;
        RDATA           : in std_logic_vector(((AXI_RDATA_WIDTH) - 1) downto 0);
        RRESP           : in std_logic_vector(1 downto 0);
        RID             : in std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
        RREADY          : out std_logic;
        WVALID          : out std_logic;
        WLAST           : out std_logic;
        WDATA           : out std_logic_vector(((AXI_WDATA_WIDTH) - 1) downto 0);
        WSTRB           : out std_logic_vector((((AXI_WDATA_WIDTH / 8)) - 1) downto 0);
        WID             : out std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
        WREADY          : in std_logic;
        BVALID          : in std_logic;
        BRESP           : in std_logic_vector(1 downto 0);
        BID             : in std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
        BREADY          : out std_logic;

    --  VHDL application interface
    --  Parallel path 0
        req_p0                           : in std_logic_vector(AXI_VHD_WAIT_ON downto 0);
        transaction_id_in_p0             : in integer;
        value_in0_p0                     : in integer;
        value_in1_p0                     : in integer;
        value_in_max_p0                  : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
        ack_p0                           : out std_logic_vector(AXI_VHD_WAIT_ON downto 0);
        transaction_id_out_p0            : out integer;
        value_out0_p0                    : out integer;
        value_out_max_p0                 : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);

    --  Parallel path 1
        req_p1                           : in std_logic_vector(AXI_VHD_WAIT_ON downto 0);
        transaction_id_in_p1             : in integer;
        value_in0_p1                     : in integer;
        value_in1_p1                     : in integer;
        value_in_max_p1                  : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
        ack_p1                           : out std_logic_vector(AXI_VHD_WAIT_ON downto 0);
        transaction_id_out_p1            : out integer;
        value_out0_p1                    : out integer;
        value_out_max_p1                 : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);

    --  Parallel path 2
        req_p2                           : in std_logic_vector(AXI_VHD_WAIT_ON downto 0);
        transaction_id_in_p2             : in integer;
        value_in0_p2                     : in integer;
        value_in1_p2                     : in integer;
        value_in_max_p2                  : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
        ack_p2                           : out std_logic_vector(AXI_VHD_WAIT_ON downto 0);
        transaction_id_out_p2            : out integer;
        value_out0_p2                    : out integer;
        value_out_max_p2                 : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);

    --  Parallel path 3
        req_p3                           : in std_logic_vector(AXI_VHD_WAIT_ON downto 0);
        transaction_id_in_p3             : in integer;
        value_in0_p3                     : in integer;
        value_in1_p3                     : in integer;
        value_in_max_p3                  : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
        ack_p3                           : out std_logic_vector(AXI_VHD_WAIT_ON downto 0);
        transaction_id_out_p3            : out integer;
        value_out0_p3                    : out integer;
        value_out_max_p3                 : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);

    --  Parallel path 4
        req_p4                           : in std_logic_vector(AXI_VHD_WAIT_ON downto 0);
        transaction_id_in_p4             : in integer;
        value_in0_p4                     : in integer;
        value_in1_p4                     : in integer;
        value_in_max_p4                  : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
        ack_p4                           : out std_logic_vector(AXI_VHD_WAIT_ON downto 0);
        transaction_id_out_p4            : out integer;
        value_out0_p4                    : out integer;
        value_out_max_p4                 : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);

    --  Parallel path 5
        req_p5                           : in std_logic_vector(AXI_VHD_WAIT_ON downto 0);
        transaction_id_in_p5             : in integer;
        value_in0_p5                     : in integer;
        value_in1_p5                     : in integer;
        value_in_max_p5                  : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
        ack_p5                           : out std_logic_vector(AXI_VHD_WAIT_ON downto 0);
        transaction_id_out_p5            : out integer;
        value_out0_p5                    : out integer;
        value_out_max_p5                 : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);

    --  Parallel path 6
        req_p6                           : in std_logic_vector(AXI_VHD_WAIT_ON downto 0);
        transaction_id_in_p6             : in integer;
        value_in0_p6                     : in integer;
        value_in1_p6                     : in integer;
        value_in_max_p6                  : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
        ack_p6                           : out std_logic_vector(AXI_VHD_WAIT_ON downto 0);
        transaction_id_out_p6            : out integer;
        value_out0_p6                    : out integer;
        value_out_max_p6                 : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);

    --  Parallel path 7
        req_p7                           : in std_logic_vector(AXI_VHD_WAIT_ON downto 0);
        transaction_id_in_p7             : in integer;
        value_in0_p7                     : in integer;
        value_in1_p7                     : in integer;
        value_in_max_p7                  : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
        ack_p7                           : out std_logic_vector(AXI_VHD_WAIT_ON downto 0);
        transaction_id_out_p7            : out integer;
        value_out0_p7                    : out integer;
        value_out_max_p7                 : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0)
     );
end component;

  -- Parallel path 0
  signal req_p0                           : std_logic_vector(AXI_VHD_WAIT_ON downto 0);
  signal transaction_id_in_p0             : integer;
  signal value_in0_p0                     : integer;
  signal value_in1_p0                     : integer;
  signal value_in_max_p0                  : std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
  signal ack_p0                           : std_logic_vector(AXI_VHD_WAIT_ON downto 0);
  signal transaction_id_out_p0            : integer;
  signal value_out0_p0                    : integer;
  signal value_out_max_p0                 : std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);

  -- Parallel path 1
  signal req_p1                           : std_logic_vector(AXI_VHD_WAIT_ON downto 0);
  signal transaction_id_in_p1             : integer;
  signal value_in0_p1                     : integer;
  signal value_in1_p1                     : integer;
  signal value_in_max_p1                  : std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
  signal ack_p1                           : std_logic_vector(AXI_VHD_WAIT_ON downto 0);
  signal transaction_id_out_p1            : integer;
  signal value_out0_p1                    : integer;
  signal value_out_max_p1                 : std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);

  -- Parallel path 2
  signal req_p2                           : std_logic_vector(AXI_VHD_WAIT_ON downto 0);
  signal transaction_id_in_p2             : integer;
  signal value_in0_p2                     : integer;
  signal value_in1_p2                     : integer;
  signal value_in_max_p2                  : std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
  signal ack_p2                           : std_logic_vector(AXI_VHD_WAIT_ON downto 0);
  signal transaction_id_out_p2            : integer;
  signal value_out0_p2                    : integer;
  signal value_out_max_p2                 : std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);

  -- Parallel path 3
  signal req_p3                           : std_logic_vector(AXI_VHD_WAIT_ON downto 0);
  signal transaction_id_in_p3             : integer;
  signal value_in0_p3                     : integer;
  signal value_in1_p3                     : integer;
  signal value_in_max_p3                  : std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
  signal ack_p3                           : std_logic_vector(AXI_VHD_WAIT_ON downto 0);
  signal transaction_id_out_p3            : integer;
  signal value_out0_p3                    : integer;
  signal value_out_max_p3                 : std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);

  -- Parallel path 4
  signal req_p4                           : std_logic_vector(AXI_VHD_WAIT_ON downto 0);
  signal transaction_id_in_p4             : integer;
  signal value_in0_p4                     : integer;
  signal value_in1_p4                     : integer;
  signal value_in_max_p4                  : std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
  signal ack_p4                           : std_logic_vector(AXI_VHD_WAIT_ON downto 0);
  signal transaction_id_out_p4            : integer;
  signal value_out0_p4                    : integer;
  signal value_out_max_p4                 : std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);

  -- Parallel path 5
  signal req_p5                           : std_logic_vector(AXI_VHD_WAIT_ON downto 0);
  signal transaction_id_in_p5             : integer;
  signal value_in0_p5                     : integer;
  signal value_in1_p5                     : integer;
  signal value_in_max_p5                  : std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
  signal ack_p5                           : std_logic_vector(AXI_VHD_WAIT_ON downto 0);
  signal transaction_id_out_p5            : integer;
  signal value_out0_p5                    : integer;
  signal value_out_max_p5                 : std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);

  -- Parallel path 6
  signal req_p6                           : std_logic_vector(AXI_VHD_WAIT_ON downto 0);
  signal transaction_id_in_p6             : integer;
  signal value_in0_p6                     : integer;
  signal value_in1_p6                     : integer;
  signal value_in_max_p6                  : std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
  signal ack_p6                           : std_logic_vector(AXI_VHD_WAIT_ON downto 0);
  signal transaction_id_out_p6            : integer;
  signal value_out0_p6                    : integer;
  signal value_out_max_p6                 : std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);

  -- Parallel path 7
  signal req_p7                           : std_logic_vector(AXI_VHD_WAIT_ON downto 0);
  signal transaction_id_in_p7             : integer;
  signal value_in0_p7                     : integer;
  signal value_in1_p7                     : integer;
  signal value_in_max_p7                  : std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
  signal ack_p7                           : std_logic_vector(AXI_VHD_WAIT_ON downto 0);
  signal transaction_id_out_p7            : integer;
  signal value_out0_p7                    : integer;
  signal value_out_max_p7                 : std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);


begin

  --  Parallel path 0
  req_p0                                              <= axi_tr_if_0(index).req;
  transaction_id_in_p0                                <= axi_tr_if_0(index).transaction_id;
  value_in0_p0                                        <= axi_tr_if_0(index).value_0;
  value_in1_p0                                        <= axi_tr_if_0(index).value_1;
  value_in_max_p0                                     <= axi_tr_if_0(index).value_max;
  axi_tr_if_local(index)(AXI_PATH_0).ack              <= ack_p0;
  axi_tr_if_local(index)(AXI_PATH_0).transaction_id   <= transaction_id_out_p0;
  axi_tr_if_local(index)(AXI_PATH_0).value_0          <= value_out0_p0;
  axi_tr_if_local(index)(AXI_PATH_0).value_max        <= value_out_max_p0;

  --  Parallel path 1
  req_p1                                              <= axi_tr_if_1(index).req;
  transaction_id_in_p1                                <= axi_tr_if_1(index).transaction_id;
  value_in0_p1                                        <= axi_tr_if_1(index).value_0;
  value_in1_p1                                        <= axi_tr_if_1(index).value_1;
  value_in_max_p1                                     <= axi_tr_if_1(index).value_max;
  axi_tr_if_local(index)(AXI_PATH_1).ack              <= ack_p1;
  axi_tr_if_local(index)(AXI_PATH_1).transaction_id   <= transaction_id_out_p1;
  axi_tr_if_local(index)(AXI_PATH_1).value_0          <= value_out0_p1;
  axi_tr_if_local(index)(AXI_PATH_1).value_max        <= value_out_max_p1;

  --  Parallel path 2
  req_p2                                              <= axi_tr_if_2(index).req;
  transaction_id_in_p2                                <= axi_tr_if_2(index).transaction_id;
  value_in0_p2                                        <= axi_tr_if_2(index).value_0;
  value_in1_p2                                        <= axi_tr_if_2(index).value_1;
  value_in_max_p2                                     <= axi_tr_if_2(index).value_max;
  axi_tr_if_local(index)(AXI_PATH_2).ack              <= ack_p2;
  axi_tr_if_local(index)(AXI_PATH_2).transaction_id   <= transaction_id_out_p2;
  axi_tr_if_local(index)(AXI_PATH_2).value_0          <= value_out0_p2;
  axi_tr_if_local(index)(AXI_PATH_2).value_max        <= value_out_max_p2;

  --  Parallel path 3
  req_p3                                              <= axi_tr_if_3(index).req;
  transaction_id_in_p3                                <= axi_tr_if_3(index).transaction_id;
  value_in0_p3                                        <= axi_tr_if_3(index).value_0;
  value_in1_p3                                        <= axi_tr_if_3(index).value_1;
  value_in_max_p3                                     <= axi_tr_if_3(index).value_max;
  axi_tr_if_local(index)(AXI_PATH_3).ack              <= ack_p3;
  axi_tr_if_local(index)(AXI_PATH_3).transaction_id   <= transaction_id_out_p3;
  axi_tr_if_local(index)(AXI_PATH_3).value_0          <= value_out0_p3;
  axi_tr_if_local(index)(AXI_PATH_3).value_max        <= value_out_max_p3;

  --  Parallel path 4
  req_p4                                              <= axi_tr_if_4(index).req;
  transaction_id_in_p4                                <= axi_tr_if_4(index).transaction_id;
  value_in0_p4                                        <= axi_tr_if_4(index).value_0;
  value_in1_p4                                        <= axi_tr_if_4(index).value_1;
  value_in_max_p4                                     <= axi_tr_if_4(index).value_max;
  axi_tr_if_local(index)(AXI_PATH_4).ack              <= ack_p4;
  axi_tr_if_local(index)(AXI_PATH_4).transaction_id   <= transaction_id_out_p4;
  axi_tr_if_local(index)(AXI_PATH_4).value_0          <= value_out0_p4;
  axi_tr_if_local(index)(AXI_PATH_4).value_max        <= value_out_max_p4;

  -- Instantiation of the SystemVerilog BFM:
  mgc_axi_master_inst: mgc_axi_master
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
        AWVALID    => AWVALID,
        AWADDR     => AWADDR,
        AWLEN      => AWLEN,
        AWSIZE     => AWSIZE,
        AWBURST    => AWBURST,
        AWLOCK     => AWLOCK,
        AWCACHE    => AWCACHE,
        AWPROT     => AWPROT,
        AWID       => AWID,
        AWREADY    => AWREADY,
        AWUSER     => AWUSER,
        ARVALID    => ARVALID,
        ARADDR     => ARADDR,
        ARLEN      => ARLEN,
        ARSIZE     => ARSIZE,
        ARBURST    => ARBURST,
        ARLOCK     => ARLOCK,
        ARCACHE    => ARCACHE,
        ARPROT     => ARPROT,
        ARID       => ARID,
        ARREADY    => ARREADY,
        ARUSER     => ARUSER,
        RVALID     => RVALID,
        RLAST      => RLAST,
        RDATA      => RDATA,
        RRESP      => RRESP,
        RID        => RID,
        RREADY     => RREADY,
        WVALID     => WVALID,
        WLAST      => WLAST,
        WDATA      => WDATA,
        WSTRB      => WSTRB,
        WID        => WID,
        WREADY     => WREADY,
        BVALID     => BVALID,
        BRESP      => BRESP,
        BID        => BID,
        BREADY     => BREADY,

        -- VHDL application interface
        --  Parallel path 0
        req_p0                 =>  req_p0,
        transaction_id_in_p0   =>  transaction_id_in_p0,
        value_in0_p0           =>  value_in0_p0,
        value_in1_p0           =>  value_in1_p0,
        value_in_max_p0        =>  value_in_max_p0,
        ack_p0                 =>  ack_p0,
        transaction_id_out_p0  =>  transaction_id_out_p0,
        value_out0_p0          =>  value_out0_p0,
        value_out_max_p0       =>  value_out_max_p0,

        --  Parallel path 1
        req_p1                 =>  req_p1,
        transaction_id_in_p1   =>  transaction_id_in_p1,
        value_in0_p1           =>  value_in0_p1,
        value_in1_p1           =>  value_in1_p1,
        value_in_max_p1        =>  value_in_max_p1,
        ack_p1                 =>  ack_p1,
        transaction_id_out_p1  =>  transaction_id_out_p1,
        value_out0_p1          =>  value_out0_p1,
        value_out_max_p1       =>  value_out_max_p1,

        --  Parallel path 2
        req_p2                 =>  req_p2,
        transaction_id_in_p2   =>  transaction_id_in_p2,
        value_in0_p2           =>  value_in0_p2,
        value_in1_p2           =>  value_in1_p2,
        value_in_max_p2        =>  value_in_max_p2,
        ack_p2                 =>  ack_p2,
        transaction_id_out_p2  =>  transaction_id_out_p2,
        value_out0_p2          =>  value_out0_p2,
        value_out_max_p2       =>  value_out_max_p2,

        --  Parallel path 3
        req_p3                 =>  req_p3,
        transaction_id_in_p3   =>  transaction_id_in_p3,
        value_in0_p3           =>  value_in0_p3,
        value_in1_p3           =>  value_in1_p3,
        value_in_max_p3        =>  value_in_max_p3,
        ack_p3                 =>  ack_p3,
        transaction_id_out_p3  =>  transaction_id_out_p3,
        value_out0_p3          =>  value_out0_p3,
        value_out_max_p3       =>  value_out_max_p3,

        --  Parallel path 4
        req_p4                 =>  req_p4,
        transaction_id_in_p4   =>  transaction_id_in_p4,
        value_in0_p4           =>  value_in0_p4,
        value_in1_p4           =>  value_in1_p4,
        value_in_max_p4        =>  value_in_max_p4,
        ack_p4                 =>  ack_p4,
        transaction_id_out_p4  =>  transaction_id_out_p4,
        value_out0_p4          =>  value_out0_p4,
        value_out_max_p4       =>  value_out_max_p4,

        --  Parallel path 5
        req_p5                 =>  req_p5,
        transaction_id_in_p5   =>  transaction_id_in_p5,
        value_in0_p5           =>  value_in0_p5,
        value_in1_p5           =>  value_in1_p5,
        value_in_max_p5        =>  value_in_max_p5,
        ack_p5                 =>  ack_p5,
        transaction_id_out_p5  =>  transaction_id_out_p5,
        value_out0_p5          =>  value_out0_p5,
        value_out_max_p5       =>  value_out_max_p5,

        --  Parallel path 6
        req_p6                 =>  req_p6,
        transaction_id_in_p6   =>  transaction_id_in_p6,
        value_in0_p6           =>  value_in0_p6,
        value_in1_p6           =>  value_in1_p6,
        value_in_max_p6        =>  value_in_max_p6,
        ack_p6                 =>  ack_p6,
        transaction_id_out_p6  =>  transaction_id_out_p6,
        value_out0_p6          =>  value_out0_p6,
        value_out_max_p6       =>  value_out_max_p6,

        --  Parallel path 7
        req_p7                 =>  req_p7,
        transaction_id_in_p7   =>  transaction_id_in_p7,
        value_in0_p7           =>  value_in0_p7,
        value_in1_p7           =>  value_in1_p7,
        value_in_max_p7        =>  value_in_max_p7,
        ack_p7                 =>  ack_p7,
        transaction_id_out_p7  =>  transaction_id_out_p7,
        value_out0_p7          =>  value_out0_p7,
        value_out_max_p7       =>  value_out_max_p7
     );
end master_a;
