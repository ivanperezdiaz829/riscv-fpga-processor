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
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all ;

entity reset_controller is
generic (
   DEVICE                   : in integer := 0
);
   port (
      clk                   : in  std_logic;
      reset                 : in  std_logic;
      pll_locked            : in  std_logic;
      pll_configupdate      : in  std_logic_vector(1 downto 0);
      pll_reconfig_done     : in  std_logic_vector(1 downto 0);
      pll_areset            : in  std_logic_vector(1 downto 0);
      rx_freqlocked         : in  std_logic;
      reconfig_busy         : in  std_logic;
      reconfig_write        : in  std_logic;
      reconfig_done         : in  std_logic;
      tx_digitalreset       : out std_logic;
      rx_digitalreset       : out std_logic;
      rx_analogreset        : out std_logic;
      done                  : out std_logic;
      s_int_out             : out std_logic
   );
end reset_controller;

architecture rtl of reset_controller is
   type   STATE_TYPE            is (IDLE, 
                                    RECONFIG_GX,
                                    RECONFIG_PLL, 
                                    RESET_1_STATE, 
                                    RESET_2_STATE, 
                                    RESET_3_STATE, 
                                    RESET_DONE
                                   );
   signal count_4_cycles        : std_logic_vector (1 downto 0);
   signal count_10_cycles       : std_logic_vector (3 downto 0);
   signal line_rate_counter     : std_logic_vector (9 downto 0);
   --signal line_rate             : integer;
   constant line_rate           : integer := 1000;
   signal reset_trigger         : std_logic;
   signal reset_complete        : std_logic;
   signal s_pll_reconfig_done   : std_logic;
   signal s_pll_areset          : std_logic;
   signal s_tx_digitalreset     : std_logic;
   signal s_rx_digitalreset     : std_logic;
   signal s_rx_analogreset      : std_logic;
   signal s_reset_hold          : std_logic;
   signal s_reset_hold_1        : std_logic;
   signal s_reset_hold_2        : std_logic;
   signal freq_unlocked_cnt     : std_logic_vector(2 downto 0);
   signal STATE                 : STATE_TYPE;
   signal pll_locked_d1         : std_logic;
   signal s_int : std_logic := '0';
   signal s_tmp : std_logic;
   ATTRIBUTE ALTERA_ATTRIBUTE   : string;
   ATTRIBUTE ALTERA_ATTRIBUTE OF pll_locked_d1 : SIGNAL IS
     "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS";
   signal pll_locked_d2         : std_logic;
   signal rx_freqlocked_d1      : std_logic;
   ATTRIBUTE ALTERA_ATTRIBUTE OF rx_freqlocked_d1 : SIGNAL IS
     "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS";
   signal rx_freqlocked_d2      : std_logic;
   signal reconfig_busy_d1      : std_logic;
   ATTRIBUTE ALTERA_ATTRIBUTE OF reconfig_busy_d1 : SIGNAL IS
     "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS";
   signal reconfig_busy_d2      : std_logic;   
   signal pll_reconfig_done_d1 : std_logic_vector(1 downto 0);
   ATTRIBUTE ALTERA_ATTRIBUTE OF pll_reconfig_done_d1 : SIGNAL IS
  "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS";
   signal pll_reconfig_done_d2 : std_logic_vector(1 downto 0);
   
 begin
   
   s_int_out <= s_int;

   s_reset_hold_1  <=  pll_configupdate(0) or pll_configupdate(1);

   -- Note:
   -- C4GX require the write to be aligned with the tx_digitalreset according to the reset sequence for dynamic reconfig UG
   gen_c4gx_reset_seq:
   if DEVICE = 3 generate
      s_tmp<=(reconfig_write or s_reset_hold) and s_int;
      tx_digitalreset <= s_tmp or s_tx_digitalreset;
      rx_digitalreset <= s_tmp or s_rx_digitalreset;
      rx_analogreset <= s_tmp or s_rx_analogreset;
   end generate;

   gen_reset_seq:
   if DEVICE /= 3 generate
      tx_digitalreset <= s_reset_hold_1 or s_reset_hold_2 or s_reset_hold or s_tx_digitalreset or reconfig_write;
      rx_digitalreset <= s_reset_hold_1 or s_reset_hold_2 or s_reset_hold or s_rx_digitalreset or reconfig_write;
      rx_analogreset  <= s_reset_hold_1 or s_reset_hold_2 or s_reset_hold or s_rx_analogreset or reconfig_write;
   end generate;
    
   process(clk, reset)
   begin
      if (reset = '1') then
         pll_locked_d1    <= '0';
         pll_locked_d2    <= '0';
         rx_freqlocked_d1 <= '0';
         rx_freqlocked_d2 <= '0';
         reconfig_busy_d1 <= '0';
         reconfig_busy_d2 <= '0';
         pll_reconfig_done_d1 <= "00";
         pll_reconfig_done_d2 <= "00";
         s_reset_hold_2   <= '0';
         s_reset_hold <= '0';
         elsif (clk'event and clk = '1') then
         if ((reconfig_write = '1' or reconfig_busy = '1') and reconfig_done ='0') then
            s_reset_hold <= '1';
         else
            s_reset_hold <= '0';
         end if;
         pll_locked_d1    <= pll_locked;
         pll_locked_d2    <= pll_locked_d1;
         rx_freqlocked_d1 <= rx_freqlocked;
         rx_freqlocked_d2 <= rx_freqlocked_d1;
         reconfig_busy_d1 <= reconfig_busy;
         reconfig_busy_d2 <= reconfig_busy_d1;
         pll_reconfig_done_d1 <=pll_reconfig_done;
         pll_reconfig_done_d2 <=pll_reconfig_done_d1;
         s_reset_hold_2 <= s_reset_hold_1;
      end if;
   end process;
 
   FSM: 
   process(clk, reset)
   begin
      if (reset = '1') then
         STATE                 <= IDLE;
         count_4_cycles        <= "00";
         count_10_cycles       <= "0000";
         line_rate_counter     <= (others => '0');
         s_pll_reconfig_done   <= '0';
         s_pll_areset          <= '0';
         s_tx_digitalreset     <= '1';
         s_rx_digitalreset     <= '1';
         s_rx_analogreset      <= '1';
         reset_complete        <= '0';
         -- SPR:366490
         s_int <='0';
      elsif (clk'event and clk = '1') then
         case STATE is
            when IDLE =>
               --line_rate <= 1000;
               if (reconfig_write = '1') then
                  STATE <= RECONFIG_GX;
               elsif (reset = '0' or reset_trigger = '1') then
                  STATE <= RESET_1_STATE;  
               else 
                  STATE <= IDLE;
               end if;
               reset_complete    <= '0';
               s_tx_digitalreset <= '1';
               s_rx_digitalreset <= '1';
               s_rx_analogreset  <= '1';  
          
            when RECONFIG_GX =>
               reset_complete <= '0';
               if (reconfig_done = '1') then
                  s_tx_digitalreset <= '0';
                  if (count_10_cycles = "1010") then
                     s_rx_analogreset <= '0';
                     count_10_cycles  <= "0000";
                     STATE            <= RESET_3_STATE;
                  else
                     count_10_cycles  <= count_10_cycles + '1';
                     STATE            <= RECONFIG_GX;
                  end if;
               else
                  -- SPR:366490
                  s_int <= '0';
                  s_tx_digitalreset <= '1';
                  s_rx_digitalreset <= '1';
                  s_rx_analogreset  <= '1';
                  count_10_cycles   <= "0000"; 
                  STATE             <= RECONFIG_GX;
               end if;
            
            when RECONFIG_PLL => 
            if (pll_reconfig_done_d2(0) = '1' or pll_reconfig_done_d2(1) = '1') then
               s_pll_reconfig_done <= '1';
            end if;
            if (pll_areset(0) = '1' or pll_areset(1) = '1')then  
               s_pll_areset <='1';
            end if;                      
            if (pll_areset(0) = '0' or pll_areset(1) = '0') and (s_pll_areset='1' and s_pll_reconfig_done='1') then
                STATE <= RESET_1_STATE;
            else
               -- SPR:366490
               s_int <= '0';
               s_tx_digitalreset <= '1';
               s_rx_digitalreset <= '1';
               s_rx_analogreset  <= '1';
               STATE <= RECONFIG_PLL;
            end if;
                          
            when RESET_1_STATE =>
               reset_complete <= '0';
               s_pll_reconfig_done <='0';
               s_pll_areset <='0';
               if (reconfig_write = '1') then
                  STATE             <= RECONFIG_GX;
                elsif (pll_configupdate(0) = '1' or pll_configupdate(1) = '1') then
                  STATE             <= RECONFIG_PLL;
               elsif (pll_locked_d2 = '1') then
                  s_tx_digitalreset <= '0';
                  STATE             <= RESET_2_STATE;
               else
                  STATE             <= RESET_1_STATE;
               end if;

            when RESET_2_STATE =>
               reset_complete <= '0';
               if (reconfig_write = '1') then
                  STATE <= RECONFIG_GX;
               elsif (pll_configupdate(0) = '1' or pll_configupdate(1) = '1') then
                  STATE             <= RECONFIG_PLL;
               elsif (reconfig_busy_d2 = '0') then
                  if (count_4_cycles = "11") then
                     s_rx_analogreset <= '0';
                     count_4_cycles   <= "00";
                     STATE	      <= RESET_3_STATE;
                  else
                     count_4_cycles   <= count_4_cycles + '1';
                     STATE            <= RESET_2_STATE;
                  end if;
               else 
                  STATE <= RESET_2_STATE;
               end if;

            when RESET_3_STATE =>
               if (reconfig_write = '1') then
                  STATE                <= RECONFIG_GX;
               elsif (pll_configupdate(0) = '1' or pll_configupdate(1) = '1') then
                  STATE             <= RECONFIG_PLL;
               elsif (rx_freqlocked_d2 = '1') then
                  if (line_rate_counter = line_rate) then
                     line_rate_counter <= (others => '0');
                     s_rx_digitalreset <= '0';
                     reset_complete    <= '1';
                     STATE             <= RESET_DONE;
                  else
                     line_rate_counter <= line_rate_counter + '1';
                     STATE <= RESET_3_STATE;
                  end if;
               else
                  STATE <= RESET_3_STATE;
               end if;

                          
            when RESET_DONE =>
--          Temporary fix for case:30602
--               if (reset_trigger = '1') then
--                  STATE             <= IDLE;  
--                  reset_complete    <= '0';
--               elsif (reconfig_write = '1')then
               if (reconfig_write = '1')then
                  STATE             <= RECONFIG_GX;
                  reset_complete    <= '0';
               elsif (pll_configupdate(0) = '1' or pll_configupdate(1) = '1') then
                  STATE             <= RECONFIG_PLL;
                  reset_complete    <= '0';
               else 
                  s_tx_digitalreset <= '0';
                  s_rx_digitalreset <= '0';
                  s_rx_analogreset  <= '0';
                  STATE             <= RESET_DONE;
                  reset_complete    <= '1';
                  -- SPR:366490
                  s_int <= '1';
               end if;

            when others =>
               STATE          <= IDLE;
               reset_complete <= '0';

         end case;

      end if;
   end process FSM;
  
   DETECT_FREQUNLOCKED:
   process(clk, reset)
   begin
      if (reset = '1') then
         freq_unlocked_cnt <= "000";
      elsif (clk'event and clk = '1') then
         if (reset_complete = '1' and (rx_freqlocked_d2 = '0' or pll_locked_d2 = '0')) then
            freq_unlocked_cnt <= freq_unlocked_cnt + "001" ;
         else
            freq_unlocked_cnt <= "000";
         end if;
      end if;
   end process DETECT_FREQUNLOCKED;

   reset_trigger <= '1' when freq_unlocked_cnt = "111" else '0';
   done <= reset_complete;

end rtl;
