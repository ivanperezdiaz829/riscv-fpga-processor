--  pci_mt32 Reference Design
--  MODULE NAME: SDR Data Path
--  COMPANY:  Altera Coporation.
--            www.altera.com    

--  FUNCTIONAL DESCRIPTION:
--  This module is the data path module for the SDR SDRAM controller.

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


entity sdr_data_path is
        
    generic (DSIZE : integer := 32);

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
end sdr_data_path;



architecture RTL of sdr_data_path is

            
    -- signal declarations 
    signal    DIN1      : std_logic_vector(DSIZE-1 downto 0);
    signal    DIN2      : std_logic_vector(DSIZE-1 downto 0);
    signal    DM1       : std_logic_vector(DSIZE/8-1 downto 0);         


begin

        -- This always block is a two stage pipe line delay that keeps the
        -- data aligned with the command sequence in the other modules.
        -- The pipeline is in both directions.
    process(CLK, RESET_N)
    begin
         if (RESET_N = '0') then
              DIN1      <= (others => '0');
              DIN2      <= (others => '0');
              DM1       <= (others => '0');
                          DQM       <= (others => '0');
         elsif rising_edge(CLK) then
              DIN1      <= DATAIN;
              DIN2      <= DIN1;
              
              DM1       <= DM;
              DQM       <= DM1;


         end if;
    end process;

DATAOUT <= DQIN;
DQOUT   <= DIN2;


end RTL;

