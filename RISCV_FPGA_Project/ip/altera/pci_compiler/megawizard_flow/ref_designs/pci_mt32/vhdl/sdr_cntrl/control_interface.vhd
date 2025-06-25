--  pci_mt32 Reference Design
--  MODULE NAME: control_interface
--  COMPANY:  Altera Coporation.
--            www.altera.com    

--  FUNCTIONAL DESCRIPTION:
--  This module is the command interface module for the SDR SDRAM controller.

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
use ieee.std_logic_arith.all;



entity control_interface is
        
    generic (ASIZE : integer := 32);

    port (
         CLK            : in      std_logic;                              -- System Clock
         RESET_N        : in      std_logic;                              -- System Reset
         CMD            : in      std_logic_vector(2 downto 0);           -- Command input
         ADDR           : in      std_logic_vector(ASIZE-1 downto 0);     -- Address
         REF_ACK        : in      std_logic;                              -- Refresh request acknowledge
         CM_ACK         : in      std_logic;                              -- Command acknowledge
         NOP            : out     std_logic;                              -- Decoded NOP command
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
         CMD_ACK        : out     std_logic                               -- Command acknowledge
         );
end control_interface;






architecture RTL of control_interface is



    -- signal declarations
    signal    LOAD_REG1      :    std_logic;
    signal    LOAD_REG2      :    std_logic;
    signal    REF_PER        :    std_logic_vector(15 downto 0);
    signal    timer          :    signed(15 downto 0);
    signal    timer_zero     :    std_logic;
    signal    SADDR_int      :    std_logic_vector(ASIZE-1 downto 0);
    signal    CMD_ACK_int    :    std_logic;
    signal    SC_BL_int      :    std_logic_vector(3 downto 0);
        


begin

    -- This module decodes the commands from the CMD input to individual
    -- command lines, NOP, READA, WRITEA, REFRESH, PRECHARGE, LOAD_MODE.
    -- ADDR is register in order to keep it aligned with decoded command.
    process(CLK, RESET_N)
    begin
         if (RESET_N = '0') then
              NOP            <= '0';
              READA          <= '0';
              WRITEA         <= '0';
              REFRESH        <= '0';
              PRECHARGE      <= '0';
              LOAD_MODE      <= '0';
              load_reg1      <= '0';
              load_reg2      <= '0';
              SADDR_int      <= (others => '0');
         elsif rising_edge(CLK) then
              SADDR_int <= ADDR;                                -- register the address to keep proper
                                                                          -- alignment with the command
                                                                     
              if (CMD = "000") then                             -- NOP command
                          NOP <= '1';
              else
                          NOP <= '0';
              end if;
                                
              if (CMD = "001") then                             -- READA command
                          READA <= '1';
              else
                          READA <= '0';
              end if;
                         
              if (CMD = "010") then                             -- WRITEA command
                          WRITEA <= '1';
              else
                          WRITEA <= '0';
              end if;
                                
              if (CMD = "011") then                             -- REFRESH command
                          REFRESH <= '1';
              else
                          REFRESH <= '0';
              end if;
                                
              if (CMD = "100") then                             -- PRECHARGE command
                          PRECHARGE <= '1';
              else
                          PRECHARGE <= '0';
              end if;
                                
              if (CMD = "101") then                             -- LOAD_MODE command
                          LOAD_MODE <= '1';
              else
                          LOAD_MODE <= '0';
              end if;
                                
              if ((CMD = "110")  and (CMD_ACK_int='0')) then     --LOAD_REG1 command
                          LOAD_REG1 <= '1';
              else   
                          LOAD_REG1 <= '0';
              end if;

              if ((CMD = "111") and (CMD_ACK_int='0')) then     --LOAD_REG2 command
                          LOAD_REG2 <= '1';
              else
                          LOAD_REG2 <= '0';
              end if;
         end if;
    end process;





    -- This always block processes the LOAD_REG1 and LOAD_REG2 commands.
    -- The register data comes in on SADDR and is distributed to the various
    -- registers.
    process(CLK, RESET_N)
    begin
         if (RESET_N = '0') then
              SC_CL     <= (others => '0');
              SC_RC     <= (others => '0');
              SC_RRD    <= (others => '0');
              SC_PM     <= '0';
              SC_BL_int <= (others => '0');
              REF_PER   <= (others => '0');

         elsif rising_edge(CLK) then
              if (LOAD_REG1 = '1') then                         -- LOAD_REG1 command
                   SC_CL     <= SADDR_int(1 downto 0);          -- CAS Latency
                   SC_RC     <= SADDR_int(3 downto 2);          -- RC delay
                   SC_RRD    <= SADDR_int(7 downto 4);          -- RRD delay
                   SC_PM     <= SADDR_int(8);                   -- Page Mode
                   SC_BL_int <= SADDR_int(12 downto 9);         -- Burst length
              end if;
              if (LOAD_REG2 = '1') then                         -- LOAD_REG2 command
                          REF_PER   <= SADDR_int(15 downto 0);         -- REFRESH Period
              end if;
         end if;
    end process;

    SADDR <= SADDR_int;
    SC_BL <= SC_BL_int;




    --  This always block generates the command acknowledge, CMD_ACK, for the
    -- commands that are handled by this module, LOAD_RE1,2, and it lets
    -- the command ack from the lower module pass through when necessary.
    process(CLK, RESET_N)
    begin
         if (RESET_N = '0') then
              CMD_ACK_int <= '0';
         elsif rising_edge(CLK) then
         if (((CM_ACK = '1') or (LOAD_REG1 = '1') or (LOAD_REG2 = '1'))) then
              CMD_ACK_int <= '1';
              else
                   CMD_ACK_int <= '0';
              end if;
         end if;
    end process;
        
    CMD_ACK <= CMD_ACK_int;


 


    -- This always block implements the refresh timer.  The timer is a 16std_logic
    -- downcounter and a REF_REQ is generated whenever the counter reaches the
    -- count of zero.  After reaching zero, the counter reloads with the value that
    -- was loaded into the refresh period register with the LOAD_REG2 command.
    -- Note that the refresh counter is disabled when the controller is in 
    -- page mode operation.
    process(CLK, RESET_N)
    begin
         if (RESET_N = '0') then
              timer           <= (others => '0');
              timer_zero      <= '0';
              REF_REQ         <= '0';
         elsif rising_edge(CLK) then
              if (timer_zero = '1') then
                          timer <= signed(REF_PER);
              elsif (not (SC_BL_int = "0000")) then             -- only run timer if not in page mode
                   timer <= timer - 1;
              end if;
                   
              if (timer=0 and not (SC_BL_int = "0000")) then
                          timer_zero <= '1';                           -- count has reached zero, issue ref_req and reload
                          REF_REQ    <= '1';                           -- the timer
              else 
                   if (REF_ACK = '1') then                      -- wait for the ack to come back from the lower
                                  timer_zero <= '0';
                                  REF_REQ    <= '0';
                             end if;
              end if;
         end if;
    end process;



end RTL;

