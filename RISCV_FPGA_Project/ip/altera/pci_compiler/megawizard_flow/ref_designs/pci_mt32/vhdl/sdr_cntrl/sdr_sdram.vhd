--  pci_mt32 Reference Design
--  MODULE NAME: sdr_sdram
--  COMPANY:  Altera Coporation.
--            www.altera.com    

--  FUNCTIONAL DESCRIPTION:
--  This module is the top level module for the SDR SDRAM controller.


--  Copyright (C) 1991-2004 Altera Corporation, All rights reserved.  
--  Altera products are protected under numerous U.S. and foreign patents, 
--  maskwork rights, copyrights and other intellectual property laws. 
--  This reference design file, and your use thereof, is subject to and 
--  governed by the terms and conditions of the applicable Altera Reference 
--  Design License Agreement (either as signed by you or found at www.altera.com).  
--  By using this reference design file, you indicate your acceptance of such terms 
--  and conditions between you and Altera Corporation.  In the event that you do
--  not agree with such terms and conditions, you may not use the reference design 
--  file and please promptly destroy any copies you have made. 
--  This reference design file is being provided on an "as-is" basis and as an 
--  accommodation and therefore all warranties, representations or guarantees 
--  of any kind (whether express, implied or statutory) including, without limitation, 
--  warranties of merchantability, non-infringement, or fitness for a particular purpose, 
--  are specifically disclaimed.  By making this reference design file available, 
--  Altera expressly does not recommend, suggest or require that this reference design 
--  file be used in combination with any other product not provided by Altera.
-----------------------------------------------------------------------------------





library ieee;
use ieee.std_logic_1164.all;
    


entity sdr_sdram is
        
    generic (
         ASIZE          : integer := 26;
         DSIZE          : integer := 64;
         ROWSIZE        : integer := 12;
         COLSIZE        : integer := 8;
         BANKSIZE       : integer := 2;
         ROWSTART       : integer := 8;         
         COLSTART       : integer := 0;         
         BANKSTART      : integer := 20                 
    );

    port (
         CLK            : in      std_logic;                                   --System Clock
         RESET_N        : in      std_logic;                                   --System Reset
         ADDR           : in      std_logic_vector(ASIZE-1 downto 0);          --Address for controller requests
         CMD            : in      std_logic_vector(2 downto 0);                --Controller command 
         CMDACK         : out     std_logic;                                   --Controller command acknowledgement
         DATAIN         : in      std_logic_vector(DSIZE-1 downto 0);          --Data input
         DATAOUT        : out     std_logic_vector(DSIZE-1 downto 0);          --Data output
         DM             : in      std_logic_vector(DSIZE/8-1 downto 0);        --Data mask input
         SA             : out     std_logic_vector(11 downto 0);               --SDRAM address output
         BA             : out     std_logic_vector(1 downto 0);                --SDRAM bank address
         CS_N           : out     std_logic_vector(1 downto 0);                --SDRAM Chip Selects
         CKE            : out     std_logic;                                   --SDRAM clock enable
         RAS_N          : out     std_logic;                                   --SDRAM Row address Strobe
         CAS_N          : out     std_logic;                                   --SDRAM Column address Strobe
         WE_N           : out     std_logic;                                   --SDRAM write enable
         DQ             : inout   std_logic_vector(DSIZE-1 downto 0);          --SDRAM data bus
         DQM            : out     std_logic_vector(DSIZE/8-1 downto 0)  ;       --SDRAM data mask lines
         probe          : out     std_logic_vector(7 downto 0)
        );
end sdr_sdram;





architecture RTL of sdr_sdram is

-- component declarations
        
    component command
         generic (
              ASIZE          : integer := 23;
              DSIZE          : integer := 32;
              ROWSIZE        : integer := 12;
              COLSIZE        : integer := 9;
              BANKSIZE       : integer := 2;
              ROWSTART       : integer := 9;          -- Starting position of the row address within ADDR   
              COLSTART       : integer := 0;          -- Starting position of the column address within ADDR
              BANKSTART      : integer := 20          -- Starting position of the bank address within ADDR
         );
         port (
              CLK            : in      std_logic;                              -- System Clock
              RESET_N        : in      std_logic;                              -- System Reset
              SADDR          : in      std_logic_vector(ASIZE-1 downto 0);     -- Address
              NOP            : in      std_logic;                              -- Decoded NOP command
              READA          : in      std_logic;                              -- Decoded READA command
              WRITEA         : in      std_logic;                              -- Decoded WRITEA command
              REFRESH        : in      std_logic;                              -- Decoded REFRESH command
              PRECHARGE      : in      std_logic;                              -- Decoded PRECHARGE command
              LOAD_MODE      : in      std_logic;                              -- Decoded LOAD_MODE command
              SC_CL          : in      std_logic_vector(1 downto 0);           -- Programmed CAS latency
              SC_RC          : in      std_logic_vector(1 downto 0);           -- Programmed RC delay
              SC_RRD         : in      std_logic_vector(3 downto 0);           -- Programmed RRD delay
              SC_PM          : in      std_logic;                              -- programmed Page Mode
              SC_BL          : in      std_logic_vector(3 downto 0);           -- Programmed burst length
              REF_REQ        : in      std_logic;                              -- Hidden refresh request
              REF_ACK        : out     std_logic;                              -- Refresh request acknowledge
              CM_ACK         : out     std_logic;                              -- Command acknowledge
              OE             : out     std_logic;                              -- OE signal for data path module
              SA             : out     std_logic_vector(11 downto 0);          -- SDRAM address
              BA             : out     std_logic_vector(1 downto 0);           -- SDRAM bank address
              CS_N           : out     std_logic_vector(1 downto 0);           -- SDRAM chip selects
              CKE            : out     std_logic;                              -- SDRAM clock enable
              RAS_N          : out     std_logic;                              -- SDRAM RAS
              CAS_N          : out     std_logic;                              -- SDRAM CAS
              WE_N           : out     std_logic   ;                            -- SDRAM WE_N
              probe          : out     std_logic_vector(7 downto 0)
         );
    end component;
        
        
    component sdr_data_path
         generic (
              DSIZE : integer := 32
         );
         port (
              CLK            : in      std_logic;                              -- System Clock
                  RESET_N        : in      std_logic;                              -- System Reset
                  OE             : in      std_logic;                              -- Data output(to the SDRAM) enable
                  DATAIN         : in      std_logic_vector(DSIZE-1 downto 0);     -- Data input from the host
                  DM             : in      std_logic_vector(DSIZE/8-1 downto 0);   -- byte data masks
                  DATAOUT        : out     std_logic_vector(DSIZE-1 downto 0);     -- Read data output to host
                  DQIN           : in      std_logic_vector(DSIZE-1 downto 0);     -- SDRAM data bus
                  DQOUT          : out     std_logic_vector(DSIZE-1 downto 0);
              DQM            : out     std_logic_vector(DSIZE/8-1 downto 0)    -- SDRAM data mask ouputs
             );
    end component;
        
        
    component control_interface
         generic (
              ASIZE : integer := 32
         );
         port (
                  CLK            : in      std_logic;                              -- System Clock
                  RESET_N        : in      std_logic;                              -- System Reset
                  CMD            : in      std_logic_vector(2 downto 0);           -- Command input
                  ADDR           : in      std_logic_vector(ASIZE-1 downto 0);     -- Address
                  REF_ACK        : in      std_logic;                              -- Refresh request acknowledge
                  CM_ACK         : in      std_logic;                              -- Command acknowledge
                  NOP             : out     std_logic;                              -- Decoded NOP command
                  READA          : out     std_logic;                              -- Decoded READA command
                  WRITEA         : out     std_logic;                              -- Decoded WRITEA command
                  REFRESH        : out     std_logic;                              -- Decoded REFRESH command
                  PRECHARGE      : out     std_logic;                              -- Decoded PRECHARGE command
                  LOAD_MODE      : out     std_logic;                              -- Decoded LOAD_MODE command
                  SADDR          : out     std_logic_vector(ASIZE-1 downto 0);     -- Registered version of ADDR
                  SC_CL          : out     std_logic_vector(1 downto 0);           -- Programmed CAS latency
                  SC_RC          : out     std_logic_vector(1 downto 0);           -- Programmed RC delay
                  SC_RRD         : out     std_logic_vector(3 downto 0);           -- Programmed RRD delay
                  SC_PM          : out     std_logic;                              -- programmed Page Mode
                  SC_BL          : out     std_logic_vector(3 downto 0);           -- Programmed burst length
                  REF_REQ        : out     std_logic;                              -- Hidden refresh request
                  CMD_ACK        : out     std_logic                                  -- Command acknowledge
             );
    end component;

    attribute syn_black_box: boolean;

        component pll1
         port (
              inclock        : in      std_logic;
              clock1         : out     std_logic;
              locked         : out     std_logic
         );
    end component;
 attribute syn_black_box of pll1: component is true;            
         
         
         
        

    -- signal declarations
    signal    ISA       :    std_logic_vector(11 downto 0);                    --SDRAM address output
    signal    IBA       :    std_logic_vector(1 downto 0);                     --SDRAM bank address
    signal    ICS_N     :    std_logic_vector(1 downto 0);                     --SDRAM Chip Selects
    signal    ICKE      :    std_logic;                                        --SDRAM clock enable
    signal    IRAS_N    :    std_logic;                                        --SDRAM Row address Strobe
    signal    ICAS_N    :    std_logic;                                        --SDRAM Column address Strobe
    signal    IWE_N     :    std_logic; 
    signal    DQIN      :    std_logic_vector(DSIZE-1 downto 0);
    signal    IDATAOUT  :    std_logic_vector(DSIZE-1 downto 0);
    signal    DQOUT     :    std_logic_vector(DSIZE-1 downto 0);                                       --SDRAM write enable
                                                                               
    signal    saddr     :    std_logic_vector(ASIZE-1 downto 0);            
    signal    sc_cl     :    std_logic_vector(1 downto 0);                   
    signal    sc_rc     :    std_logic_vector(1 downto 0);                   
    signal    sc_rrd    :    std_logic_vector(3 downto 0);                   
    signal    sc_pm     :    std_logic;                   
    signal    sc_bl     :    std_logic_vector(3 downto 0);                   
    signal    load_mode :    std_logic;                       
    signal    nop       :    std_logic;                 
    signal    reada     :    std_logic;                   
    signal    writea    :    std_logic;                    
    signal    refresh   :    std_logic;                     
    signal    precharge :    std_logic;                       
    signal    oe        :    std_logic;                
    signal    ref_req   :    std_logic;                
    signal    ref_ack   :    std_logic;                
    signal    cm_ack    :    std_logic;                
                             
    signal    CLK133    :    std_logic;                    
    signal    CLK133B   :    std_logic; 
    signal    clklocked :    std_logic;     
    signal    cmd_probe :    std_logic_vector(7 downto 0);               

begin

 
        -- instantiate the control interface module
    control1 : control_interface
         generic map (
              ASIZE => ASIZE
         )
         port map  (
                  CLK       => CLK133,
                  RESET_N   => RESET_N,
                  CMD       => CMD,
                  ADDR      => ADDR,
                  REF_ACK   => ref_ack,
                  CM_ACK    => cm_ack,
                  NOP       => nop,
                  READA     => reada,
                  WRITEA    => writea,
                  REFRESH   => refresh,
                  PRECHARGE => precharge,
                  LOAD_MODE => load_mode,
                  SADDR     => saddr,
                  SC_CL     => sc_cl,
                  SC_RC     => sc_rc,
                  SC_RRD    => sc_rrd,
                  SC_PM     => sc_pm,
                  SC_BL     => sc_bl,
                  REF_REQ   => ref_req,
                  CMD_ACK   => CMDACK
         );
                        
                        
    -- instantiate the command module
    command1 : command
         generic map(
              ASIZE             => ASIZE,               
              DSIZE             => DSIZE,               
              ROWSIZE   => ROWSIZE,     
              COLSIZE   => COLSIZE,     
              BANKSIZE  => BANKSIZE, 
              ROWSTART  => ROWSTART, 
              COLSTART  => COLSTART, 
              BANKSTART         => BANKSTART
         )
         port map  (
                  CLK       => CLK133,
                  RESET_N   => RESET_N,
                  SADDR     => saddr,
                  NOP       => nop,
                  READA     => reada,
                  WRITEA    => writea,
                  REFRESH   => refresh,
                  PRECHARGE => precharge,
                  LOAD_MODE => load_mode,
                  SC_CL     => sc_cl,
                  SC_RC     => sc_rc,
                  SC_RRD    => sc_rrd,
                  SC_PM     => sc_pm,
                  SC_BL     => sc_bl,
                  REF_REQ   => ref_req,
                  REF_ACK   => ref_ack,
                  CM_ACK    => cm_ack,
                  OE        => oe,
                  SA        => ISA,
                  BA        => IBA,
                  CS_N      => ICS_N,
                  CKE       => ICKE,
                  RAS_N     => IRAS_N,
                  CAS_N     => ICAS_N,
                  WE_N      => IWE_N,
                  probe     => cmd_probe
         );
            
                        
    -- instantiate the data path module
    data_path1 : sdr_data_path 
         generic map (
              DSIZE => DSIZE
         )
         port map  (
                  CLK       => CLK133,
                  RESET_N   => RESET_N,
                  OE        => oe,
                  DATAIN    => DATAIN,
                  DM        => DM,
                  DATAOUT   => IDATAOUT,
                  DQM       => DQM,
              DQIN      => DQIN,
              DQOUT     => DQOUT
            );
            
            CLK133 <= CLK;
  --  pll : pll1
  --       port map (
  --            inclock => CLK,
  --            locked  => clklocked,
  --            clock1  => CLK133
  --       );
              
            
    -- Add a level flops to the sdram i/o that can be place
    -- by the router into the I/O cells
    process(CLK133)
    begin
         if rising_edge(CLK133) then
              SA        <= ISA;
              BA        <= IBA;
              CS_N      <= ICS_N;
              CKE       <= ICKE;
              RAS_N     <= IRAS_N;
              CAS_N     <= ICAS_N;
              WE_N      <= IWE_N;
              DQIN      <= DQ;
              DATAOUT   <= IDATAOUT;
         end if;
    end process;

    -- tri-state the data bus using the OE signal from the main controller.
        
DQ <= DQOUT when OE = '1' else (others => 'Z');

probe(4 downto 0) <= cmd_probe(4 downto 0);
probe(5) <= CM_ACK;
probe(7 downto 6) <= "00";


end RTL;

