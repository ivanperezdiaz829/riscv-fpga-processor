-- *****************************************************************************
--
-- Copyright 2007-2013 Mentor Graphics Corporation
-- All Rights Reserved.
--
-- THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF
-- MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
--
-- *****************************************************************************

library ieee ;
use ieee.std_logic_1164.all;

library work;
use work.all;

entity top is
end top;

architecture top_a of top is
  signal ACLK    : std_logic := '0';
  signal ARESETn : std_logic := '0';
  signal AWVALID : std_logic;
  signal AWADDR  : std_logic_vector(31 downto 0);
  signal AWLEN   : std_logic_vector(3 downto 0);
  signal AWSIZE  : std_logic_vector(2 downto 0);
  signal AWBURST : std_logic_vector(1 downto 0);
  signal AWLOCK  : std_logic_vector(1 downto 0);
  signal AWCACHE : std_logic_vector(3 downto 0);
  signal AWPROT  : std_logic_vector(2 downto 0);
  signal AWID    : std_logic_vector(17 downto 0);
  signal AWREADY : std_logic; 
  signal AWUSER  : std_logic_vector(7 downto 0);
  signal ARVALID : std_logic;
  signal ARADDR  : std_logic_vector(31 downto 0);
  signal ARLEN   : std_logic_vector(3 downto 0);
  signal ARSIZE  : std_logic_vector(2 downto 0);
  signal ARBURST : std_logic_vector(1 downto 0);
  signal ARLOCK  : std_logic_vector(1 downto 0);
  signal ARCACHE : std_logic_vector(3 downto 0);
  signal ARPROT  : std_logic_vector(2 downto 0);
  signal ARID    : std_logic_vector(17 downto 0);
  signal ARREADY : std_logic; 
  signal ARUSER  : std_logic_vector(7 downto 0);
  signal RVALID  : std_logic;
  signal RLAST   : std_logic; 
  signal RDATA   : std_logic_vector(31 downto 0); 
  signal RRESP   : std_logic_vector(1 downto 0); 
  signal RID     : std_logic_vector(17 downto 0); 
  signal RREADY  : std_logic;
  signal WVALID  : std_logic;
  signal WLAST   : std_logic;
  signal WDATA   : std_logic_vector(31 downto 0);
  signal WSTRB   : std_logic_vector(3 downto 0);
  signal WID     : std_logic_vector(17 downto 0);
  signal WREADY  : std_logic;
  signal BVALID  : std_logic; 
  signal BRESP   : std_logic_vector(1 downto 0); 
  signal BID     : std_logic_vector(17 downto 0);
  signal BREADY  : std_logic; 
 
  component mgc_axi_master_vhd
  generic (AXI_ADDRESS_WIDTH : integer := 32;
           AXI_RDATA_WIDTH : integer := 1024;
           AXI_WDATA_WIDTH : integer := 1024;
           AXI_ID_WIDTH : integer := 18;
           index : integer range 0 to 511 :=0
          );
  port(
    ACLK    : in std_logic;
    ARESETn : in std_logic;
    AWVALID : out std_logic;
    AWADDR  : out std_logic_vector(((AXI_ADDRESS_WIDTH) - 1) downto 0);
    AWLEN   : out std_logic_vector(3 downto 0);
    AWSIZE  : out std_logic_vector(2 downto 0);
    AWBURST : out std_logic_vector(1 downto 0);
    AWLOCK  : out std_logic_vector(1 downto 0);
    AWCACHE : out std_logic_vector(3 downto 0);
    AWPROT  : out std_logic_vector(2 downto 0);
    AWID    : out std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
    AWREADY : in std_logic; 
    AWUSER  : out std_logic_vector(7 downto 0);
    ARVALID : out std_logic;
    ARADDR  : out std_logic_vector(((AXI_ADDRESS_WIDTH) - 1) downto 0);
    ARLEN   : out std_logic_vector(3 downto 0);
    ARSIZE  : out std_logic_vector(2 downto 0);
    ARBURST : out std_logic_vector(1 downto 0);
    ARLOCK  : out std_logic_vector(1 downto 0);
    ARCACHE : out std_logic_vector(3 downto 0);
    ARPROT  : out std_logic_vector(2 downto 0);
    ARID    : out std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
    ARREADY : in std_logic; 
    ARUSER  : out std_logic_vector(7 downto 0);
    RVALID  : in std_logic;
    RLAST   : in std_logic; 
    RDATA   : in std_logic_vector(((AXI_RDATA_WIDTH) - 1) downto 0); 
    RRESP   : in std_logic_vector(1 downto 0); 
    RID     : in std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0); 
    RREADY  : out std_logic;
    WVALID  : out std_logic;
    WLAST   : out std_logic;
    WDATA   : out std_logic_vector(((AXI_WDATA_WIDTH) - 1) downto 0);
    WSTRB   : out std_logic_vector((((AXI_WDATA_WIDTH / 8)) - 1) downto 0);
    WID     : out std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
    WREADY  : in std_logic;
    BVALID  : in std_logic; 
    BRESP   : in std_logic_vector(1 downto 0); 
    BID     : in std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
    BREADY  : out std_logic
   ); 
  end component;


  component mgc_axi_slave_vhd
  generic (AXI_ADDRESS_WIDTH : integer := 32;
           AXI_RDATA_WIDTH : integer := 1024;
           AXI_WDATA_WIDTH : integer := 1024;
           AXI_ID_WIDTH : integer := 18;
           index : integer range 0 to 511 :=0
          );
  port(
    ACLK    : in std_logic;
    ARESETn : in std_logic;
    AWVALID : in std_logic;
    AWADDR  : in std_logic_vector(((AXI_ADDRESS_WIDTH) - 1) downto 0);
    AWLEN   : in std_logic_vector(3 downto 0);
    AWSIZE  : in std_logic_vector(2 downto 0);
    AWBURST : in std_logic_vector(1 downto 0);
    AWLOCK  : in std_logic_vector(1 downto 0);
    AWCACHE : in std_logic_vector(3 downto 0);
    AWPROT  : in std_logic_vector(2 downto 0);
    AWID    : in std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
    AWREADY : out std_logic; 
    AWUSER  : in std_logic_vector(7 downto 0);
    ARVALID : in std_logic;
    ARADDR  : in std_logic_vector(((AXI_ADDRESS_WIDTH) - 1) downto 0);
    ARLEN   : in std_logic_vector(3  downto 0);
    ARSIZE  : in std_logic_vector(2 downto 0);
    ARBURST : in std_logic_vector(1 downto 0);
    ARLOCK  : in std_logic_vector(1 downto 0);
    ARCACHE : in std_logic_vector(3 downto 0);
    ARPROT  : in std_logic_vector(2 downto 0);
    ARID    : in std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
    ARREADY : out std_logic; 
    ARUSER  : in std_logic_vector(7 downto 0);
    RVALID  : out std_logic;
    RLAST   : out std_logic; 
    RDATA   : out std_logic_vector(((AXI_RDATA_WIDTH) - 1) downto 0); 
    RRESP   : out std_logic_vector(1 downto 0); 
    RID     : out std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0); 
    RREADY  : in std_logic;
    WVALID  : in std_logic;
    WLAST   : in std_logic;
    WDATA   : in std_logic_vector(((AXI_WDATA_WIDTH) - 1) downto 0);
    WSTRB   : in std_logic_vector((((AXI_WDATA_WIDTH / 8)) - 1) downto 0);
    WID     : in std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
    WREADY  : out std_logic;
    BVALID  : out std_logic; 
    BRESP   : out std_logic_vector(1 downto 0); 
    BID     : out std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
    BREADY  : in std_logic
   ); 
  end component;

  component mgc_axi_monitor_vhd
  generic (AXI_ADDRESS_WIDTH : integer := 32;
           AXI_RDATA_WIDTH : integer := 1024;
           AXI_WDATA_WIDTH : integer := 1024;
           AXI_ID_WIDTH : integer := 18;
           index : integer range 0 to 511 :=0
          );
  port(
    ACLK    : in std_logic;
    ARESETn : in std_logic;
    AWVALID : in std_logic;
    AWADDR  : in std_logic_vector(((AXI_ADDRESS_WIDTH) - 1) downto 0);
    AWLEN   : in std_logic_vector(3 downto 0);
    AWSIZE  : in std_logic_vector(2 downto 0);
    AWBURST : in std_logic_vector(1 downto 0);
    AWLOCK  : in std_logic_vector(1 downto 0);
    AWCACHE : in std_logic_vector(3 downto 0);
    AWPROT  : in std_logic_vector(2 downto 0);
    AWID    : in std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
    AWREADY : in std_logic; 
    AWUSER  : in std_logic_vector(7 downto 0);
    ARVALID : in std_logic;
    ARADDR  : in std_logic_vector(((AXI_ADDRESS_WIDTH) - 1) downto 0);
    ARLEN   : in std_logic_vector(3 downto 0);
    ARSIZE  : in std_logic_vector(2 downto 0);
    ARBURST : in std_logic_vector(1 downto 0);
    ARLOCK  : in std_logic_vector(1 downto 0);
    ARCACHE : in std_logic_vector(3 downto 0);
    ARPROT  : in std_logic_vector(2 downto 0);
    ARID    : in std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
    ARREADY : in std_logic; 
    ARUSER  : in std_logic_vector(7 downto 0);
    RVALID  : in std_logic;
    RLAST   : in std_logic; 
    RDATA   : in std_logic_vector(((AXI_RDATA_WIDTH) - 1) downto 0); 
    RRESP   : in std_logic_vector(1 downto 0); 
    RID     : in std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0); 
    RREADY  : in std_logic;
    WVALID  : in std_logic;
    WLAST   : in std_logic;
    WDATA   : in std_logic_vector(((AXI_WDATA_WIDTH) - 1) downto 0);
    WSTRB   : in std_logic_vector((((AXI_WDATA_WIDTH / 8)) - 1) downto 0);
    WID     : in std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
    WREADY  : in std_logic;
    BVALID  : in std_logic; 
    BRESP   : in std_logic_vector(1 downto 0); 
    BID     : in std_logic_vector(((AXI_ID_WIDTH) - 1) downto 0);
    BREADY  : in std_logic
  );  
  end component;

  component master_test_program
   generic (AXI_ADDRESS_WIDTH : integer := 32;
           AXI_RDATA_WIDTH : integer := 1024;
           AXI_WDATA_WIDTH : integer := 1024;
           AXI_ID_WIDTH : integer := 18;
           index : integer range 0 to 511 :=0
          );
  end component;

  component slave_test_program
   generic (AXI_ADDRESS_WIDTH : integer := 32;
           AXI_RDATA_WIDTH : integer := 1024;
           AXI_WDATA_WIDTH : integer := 1024;
           AXI_ID_WIDTH : integer := 18;
           index : integer range 0 to 511 :=0
          );
  end component;

  component monitor_test_program
   generic (AXI_ADDRESS_WIDTH : integer := 32;
           AXI_RDATA_WIDTH : integer := 1024;
           AXI_WDATA_WIDTH : integer := 1024;
           AXI_ID_WIDTH : integer := 18;
           index : integer range 0 to 511 :=0
          );
  end component;

begin

master_vhd: mgc_axi_master_vhd
generic map(AXI_ADDRESS_WIDTH => 32,
            AXI_RDATA_WIDTH   => 32,
            AXI_WDATA_WIDTH   => 32,
            AXI_ID_WIDTH      => 18,
            index             => 0)
port map(
  ACLK    => ACLK,
  ARESETn => ARESETn,
  AWVALID => AWVALID,
  AWADDR  => AWADDR,
  AWLEN   => AWLEN,
  AWSIZE  => AWSIZE,
  AWBURST => AWBURST,
  AWLOCK  => AWLOCK,
  AWCACHE => AWCACHE,
  AWPROT  => AWPROT, 
  AWID    => AWID,
  AWREADY => AWREADY,
  AWUSER  => AWUSER,
  ARVALID => ARVALID,
  ARADDR  => ARADDR,
  ARLEN   => ARLEN,
  ARSIZE  => ARSIZE,
  ARBURST => ARBURST,
  ARLOCK  => ARLOCK,
  ARCACHE => ARCACHE,
  ARPROT  => ARPROT,
  ARID    => ARID,
  ARREADY => ARREADY, 
  ARUSER  => ARUSER,
  RVALID  => RVALID,
  RLAST   => RLAST,
  RDATA   => RDATA, 
  RRESP   => RRESP,
  RID     => RID,
  RREADY  => RREADY,
  WVALID  => WVALID,
  WLAST   => WLAST,
  WDATA   => WDATA,
  WSTRB   => WSTRB,
  WID     => WID,
  WREADY  => WREADY,
  BVALID  => BVALID,
  BRESP   => BRESP,
  BID     => BID,
  BREADY  => BREADY
 );

 slave_vhd: mgc_axi_slave_vhd
 generic map(AXI_ADDRESS_WIDTH => 32,
             AXI_RDATA_WIDTH   => 32,
             AXI_WDATA_WIDTH   => 32,
             AXI_ID_WIDTH      => 18,
             index             => 1)
 port map(
  ACLK    => ACLK,
  ARESETn => ARESETn,
  AWVALID => AWVALID,
  AWADDR  => AWADDR,
  AWLEN   => AWLEN,
  AWSIZE  => AWSIZE,
  AWBURST => AWBURST,
  AWLOCK  => AWLOCK,
  AWCACHE => AWCACHE,
  AWPROT  => AWPROT, 
  AWID    => AWID,
  AWREADY => AWREADY,
  AWUSER  => AWUSER,
  ARVALID => ARVALID,
  ARADDR  => ARADDR,
  ARLEN   => ARLEN,
  ARSIZE  => ARSIZE,
  ARBURST => ARBURST,
  ARLOCK  => ARLOCK,
  ARCACHE => ARCACHE,
  ARPROT  => ARPROT,
  ARID    => ARID,
  ARREADY => ARREADY, 
  ARUSER  => ARUSER,
  RVALID  => RVALID,
  RLAST   => RLAST,
  RDATA   => RDATA, 
  RRESP   => RRESP,
  RID     => RID,
  RREADY  => RREADY,
  WVALID  => WVALID,
  WLAST   => WLAST,
  WDATA   => WDATA,
  WSTRB   => WSTRB,
  WID     => WID,
  WREADY  => WREADY,
  BVALID  => BVALID,
  BRESP   => BRESP,
  BID     => BID,
  BREADY  => BREADY
 );

 monitor_vhd: mgc_axi_monitor_vhd
 generic map(AXI_ADDRESS_WIDTH => 32,
             AXI_RDATA_WIDTH   => 32,
             AXI_WDATA_WIDTH   => 32,
             AXI_ID_WIDTH      => 18,
             index             => 2)
port map(
  ACLK    => ACLK,
  ARESETn => ARESETn,
  AWVALID => AWVALID,
  AWADDR  => AWADDR,
  AWLEN   => AWLEN,
  AWSIZE  => AWSIZE,
  AWBURST => AWBURST,
  AWLOCK  => AWLOCK,
  AWCACHE => AWCACHE,
  AWPROT  => AWPROT, 
  AWID    => AWID,
  AWREADY => AWREADY,
  AWUSER  => AWUSER,
  ARVALID => ARVALID,
  ARADDR  => ARADDR,
  ARLEN   => ARLEN,
  ARSIZE  => ARSIZE,
  ARBURST => ARBURST,
  ARLOCK  => ARLOCK,
  ARCACHE => ARCACHE,
  ARPROT  => ARPROT,
  ARID    => ARID,
  ARREADY => ARREADY, 
  ARUSER  => ARUSER,
  RVALID  => RVALID,
  RLAST   => RLAST,
  RDATA   => RDATA, 
  RRESP   => RRESP,
  RID     => RID,
  RREADY  => RREADY,
  WVALID  => WVALID,
  WLAST   => WLAST,
  WDATA   => WDATA,
  WSTRB   => WSTRB,
  WID     => WID,
  WREADY  => WREADY,
  BVALID  => BVALID,
  BRESP   => BRESP,
  BID     => BID,
  BREADY  => BREADY
 );

mas_test: master_test_program
 generic map(AXI_ADDRESS_WIDTH => 32,
             AXI_RDATA_WIDTH   => 32,
             AXI_WDATA_WIDTH   => 32,
             AXI_ID_WIDTH      => 18,
             index             => 0);

slv_test: slave_test_program
 generic map(AXI_ADDRESS_WIDTH => 32,
             AXI_RDATA_WIDTH   => 32,
             AXI_WDATA_WIDTH   => 32,
             AXI_ID_WIDTH      => 18,
             index             => 1);

mon_test: monitor_test_program
 generic map(AXI_ADDRESS_WIDTH => 32,
             AXI_RDATA_WIDTH   => 32,
             AXI_WDATA_WIDTH   => 32,
             AXI_ID_WIDTH      => 18,
             index             => 2);

  -- Clock and reset generation 
  process
  begin
    ARESETn <= '0';
    wait for 100 ns;
    ARESETn <= '1';
    wait;
  end process;
  
  process
  begin
      ACLK <=  not ACLK;
      wait for 5 ns;
  end process;

end top_a;
