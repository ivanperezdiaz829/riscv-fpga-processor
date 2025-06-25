--  pci_mt32 Reference Design
--  MODULE NAME: cmd_sm
--  COMPANY:  Altera Coporation.
--            www.altera.com    

--  FUNCTIONAL DESCRIPTION:
--  This file consists of state machine which is required
-- ** to generate the command signal to the SDR Sdram controller

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
use ieee.STD_LOGIC_1164.all;
use ieee.STD_LOGIC_ARITH.all;
use ieee.STD_LOGIC_MISC.all;
use ieee.STD_LOGIC_UNSIGNED.all;
 
 
entity cmd_sm is
  port (
        clk : in STD_LOGIC;
        rstn : in STD_LOGIC;
        bar0_hit : in STD_LOGIC;
        tw_mr_cmd_req : in STD_LOGIC;
        tr_mw_cmd_req : in STD_LOGIC;
        s_adri : in STD_LOGIC_VECTOR (25 downto 0);
        cmdack : in STD_LOGIC;
        cmd : out STD_LOGIC_VECTOR(2 downto 0 )
        );
end cmd_sm;
 
-- /**********************************************************************
--  copyright message here.
--
-- ** module: cmd_sm.v
--
-- ** author: altera
--
-- ** description: This file consists of state machine which is required
-- ** to generate the command signal to the SDR Sdram controller
-- ***********************************************************************/
 
architecture cmd_sm of cmd_sm is
 
  
  signal visual_0_cmd_sm : STD_LOGIC;
  constant IDLE_ST : std_logic := '0';
  constant ACTIVE_ST : std_logic := '1';
  --  different command definitions
  --  Internal signals
  signal config_reg1_wr : STD_LOGIC;
  signal config_reg2_wr : STD_LOGIC;
  signal sdram_mode_reg_wr : STD_LOGIC;
  signal prechg : STD_LOGIC;
  --  Internal registers
  signal s_adri_dec1 : STD_LOGIC;
  signal sel_lmr : STD_LOGIC;
  signal sel_cr1 : STD_LOGIC;
  signal sel_cr2 : STD_LOGIC;
  signal sel_pcg : STD_LOGIC;
  signal bar0_hit_reg : std_logic;
  signal bar0_hit_rise : std_logic;
begin
 
 process(clk,rstn)
  begin
  if( rstn = '0' ) then
    bar0_hit_reg <= '0';
  elsif (clk'event and clk='1') then
    bar0_hit_reg <= bar0_hit;
  end if;
end process;

bar0_hit_rise <= not bar0_hit_reg and bar0_hit; 
  --  control signals for generating the command output for initialising the sdram controller and
  --  sdram memory
  process (clk, rstn)
    variable case_var : STD_LOGIC_VECTOR(3 downto 0);
       -- Generated for case statement
 
  begin
    if rstn = '0' then
      sel_lmr <= '0';
      sel_cr1 <= '0';
      sel_cr2 <= '0';
      sel_pcg <= '0';
    elsif (clk'event and clk = '1' ) then
      if (bar0_hit_rise) = '1'  then
        case_var := s_adri(5 downto 2) ;
        case case_var is
          when "0111" =>
            sel_cr1 <= '1';--  s_adri[7:0] = 1C
          when "1000" =>
            sel_cr2 <= '1';--  s_adri[7:0] = 20
          when "0110" =>
            sel_lmr <= '1';--  s_adri[7:0] = 18
          when "1001" =>
            sel_pcg <= '1';--  s_adri[7:0] = 24
          when others  =>
            sel_lmr <= '0';
            sel_cr1 <= '0';
            sel_cr2 <= '0';
            sel_pcg <= '0';
        end case  ;
      else
        sel_lmr <= '0';
        sel_cr1 <= '0';
        sel_cr2 <= '0';
        sel_pcg <= '0';
      end if ;
    end if ;
  end process ;
 
  --  decoding the common signals i,e s_adri[7:6] & s_adri[2:0]
  --  which is used along with the control signals for
  --  generating the command output
  process (clk, rstn)
 
  begin
    if rstn = '0' then
      s_adri_dec1 <= '0';
    elsif (clk'event and clk = '1' ) then
      s_adri_dec1 <= not(s_adri(7)) and not(s_adri(6)) and not(s_adri(1)) and
                     not(s_adri(0));
    end if ;
  end process ;
 
  config_reg1_wr <= sel_cr1 and s_adri_dec1;  --  select enable for config reg 1
  config_reg2_wr <= sel_cr2 and s_adri_dec1;  --  select enable for config reg 2
  sdram_mode_reg_wr <= sel_lmr and s_adri_dec1;  --  select enable for load mode reg
  prechg <= sel_pcg and s_adri_dec1;  --  select enable for precharge
  -- STATE MACHINE FOR GENERATING THE COMMAND OUTPUT TO THE SDRAM CONTROLLER
  process (clk, rstn)
 
  begin
    if rstn = '0' then
      visual_0_cmd_sm <= IDLE_ST;
      cmd(2 downto 0) <= "000";
    elsif (clk'event and clk = '1' ) then
      case visual_0_cmd_sm is
        when IDLE_ST =>
          if (tr_mw_cmd_req) = '1'  then
            --  Idle state
            --  When any one of the operation occurs the state machine goes from the
            --  idle state to the active state
            --  The CMD signal indicates the corresponding operation
            --  Target read/master write operation
            cmd <= "001";
            visual_0_cmd_sm <= ACTIVE_ST;
          else
            if (tw_mr_cmd_req) = '1'  then
              --  Target write/master read operation
              cmd <= "010";
              visual_0_cmd_sm <= ACTIVE_ST;
            else
              if (config_reg1_wr) = '1'  then
                --  Configuration register 1
                cmd <= "110";
                visual_0_cmd_sm <= ACTIVE_ST;
              else
                if (config_reg2_wr) = '1'  then
                  --  Configuration register 2
                  cmd <= "111";
                  visual_0_cmd_sm <= ACTIVE_ST;
                else
                  if (sdram_mode_reg_wr) = '1'  then
                    --  Load Mode Register
                    cmd <= "101";
                    visual_0_cmd_sm <= ACTIVE_ST;
                  else
                    if (prechg) = '1'  then
                      --  Precharge
                      cmd <= "100";
                      visual_0_cmd_sm <= ACTIVE_ST;
                    end if ;
                  end if ;
                end if ;
              end if ;
            end if ;
          end if ;
        when ACTIVE_ST =>
          if (cmdack) = '1'  then
            --  When the command acknowledge signal is asserted from sdram controller
            --  the state machine goes to the idle state
            --  Also the CMD signal becomes NOP
            visual_0_cmd_sm <= IDLE_ST;
            cmd <= "000";
          else
            visual_0_cmd_sm <= ACTIVE_ST;
          end if ;
        when others =>
          null;
      end case  ;
    end if ;
  end process ;
 
 
end ;

