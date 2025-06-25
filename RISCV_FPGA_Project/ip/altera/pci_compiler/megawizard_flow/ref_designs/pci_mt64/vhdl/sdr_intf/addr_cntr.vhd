--------------------------------------------------------------------
--  pci_mt64 Reference Design
--  MODULE NAME: addr_cntr
--  COMPANY:  Altera Coporation.
--            www.altera.com    

--  FUNCTIONAL DESCRIPTION:
--  This file consists of
-- ** 1. Address Counter which is output as the address to the sdram controller.
-- ** 2. Data Counter which is used as the reference for the data count during
-- ** the master read/master write access

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
 
 
entity addr_cntr is
  port (
        clk : in STD_LOGIC;
        reset_n : in STD_LOGIC;
        load_reg_data : in STD_LOGIC_VECTOR (15 downto 0);
        bar0_hit : in STD_LOGIC;
        bar1_hit : in STD_LOGIC;
        target_write : in STD_LOGIC;
        dma_req_sdram : in STD_LOGIC;
        dma_bcr : in STD_LOGIC_VECTOR (16 downto 0);
        dma_on_bit : in STD_LOGIC;
        tr_mw_sm : in STD_LOGIC_VECTOR (4 downto 0);
        tw_mr_sm : in STD_LOGIC_VECTOR (4 downto 0);
        s_adri : in STD_LOGIC_VECTOR (25 downto 0);
        dma_lar : in STD_LOGIC_VECTOR (25 downto 0);
        target_read : in STD_LOGIC;
        cmdack : in STD_LOGIC;
        data_cntr_zero : in STD_LOGIC;
        rd_wr_ctrl_cntr_7 : in STD_LOGIC;
        rd_req : in STD_LOGIC;
        wr_req : in STD_LOGIC;
        dis_monitor_sig : in STD_LOGIC;
        addr : out STD_LOGIC_VECTOR(25 downto 0 );
        addr_monitor_7 : out STD_LOGIC;
        addr_monitor_6 : out STD_LOGIC;
        low_addr_not_zero : out STD_LOGIC;
        ld_addr_monitor : out STD_LOGIC;
        low_addr_7 : out STD_LOGIC;
        data_cntr : out STD_LOGIC_VECTOR(13 downto 0 )
        );
end addr_cntr;
 

 
architecture addr_cntr of addr_cntr is
  signal visual_0_addr : STD_LOGIC_VECTOR(25 downto 0 );--    ----- created for output, which is read or nets with declaration delay .
  signal visual_0_addr_monitor_7 : STD_LOGIC;--    ----- created for output, which is read or nets with declaration delay .
  signal visual_0_low_addr_not_zero : STD_LOGIC;--    ----- created for output, which is read or nets with declaration delay .
  signal visual_0_ld_addr_monitor : STD_LOGIC;--    ----- created for output, which is read or nets with declaration delay .
  signal visual_0_data_cntr : STD_LOGIC_VECTOR(13 downto 0 );--    ----- created for output, which is read or nets with declaration delay .
 
  
  signal addr_monitor : STD_LOGIC_VECTOR(2 downto 0 );
  --  internal registers
  signal addr_load : STD_LOGIC;  --  load enable for the address counter
  signal del_cmdack : STD_LOGIC;  --  cmdack delayed by one clock cycle
  --  internal signals
  signal addrin : STD_LOGIC_VECTOR(25 downto 0 );  --  address loaded when load enable is active
  signal datacnten : STD_LOGIC;  --  clock enable signal for data counter
  signal low_addr_cnt_not_zero : STD_LOGIC;  --  control signal which indicates that the lower 3 address bits are not zero
begin
 
  low_addr_not_zero <= visual_0_low_addr_not_zero;
  data_cntr <= visual_0_data_cntr;
  ld_addr_monitor <= visual_0_ld_addr_monitor;
  addr <= visual_0_addr;
  addr_monitor_7 <= visual_0_addr_monitor_7;
 
  --  Definitions
  --  Generation of address signals which is output to the sdram controller
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      visual_0_addr <= "00000000000000000000000000";
    elsif (clk'event and clk = '1' ) then
      if (addr_load) = '1'  then
        --  the address is loaded at the start of transaction
        visual_0_addr <= addrin;
      else
        if (del_cmdack) = '1'  then
          if (visual_0_low_addr_not_zero = '0' ) then
            --  the address is incremented after every 8 QUAD WORD(64 Bit) transfer
            visual_0_addr(25 downto 3) <= ext(ext(visual_0_addr(25 downto 3),32)
                                          + 1,abs(25-3)+1);  --  when the incoming lower 3 address bits are zero
          else
            --  When the incoming lower address bits are not zero then the three
            --  lower address are set to zero which indicates that the boundary of seven
            visual_0_addr(2 downto 0) <= "000";  --  has been reached during the previous transaction
            visual_0_addr(25 downto 3) <= ext(ext(visual_0_addr(25 downto 3),32)
                                          + 1,abs(25-3)+1);  --  also the other bits are incremented after every 8 QUAD WORD transfer
          end if ;
        end if ;
      end if ;
    end if ;
  end process ;
 
  --  Command acknowledge signal delayed by one clock cycle
  --  this is used as the clock enable for the address counter
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      del_cmdack <= '0';
    elsif (clk'event and clk = '1' ) then
      del_cmdack <= cmdack;
    end if ;
  end process ;
 
  --  Data counter which indicates the no. of data remaining during
  --  master read/ write transfer
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      visual_0_data_cntr(13 downto 0) <= "00000000000000";
    elsif (clk'event and clk = '1' ) then
      if (dma_req_sdram) = '1'  then
        visual_0_data_cntr <= dma_bcr(16 downto 3);
      else
        if (datacnten) = '1'  then
          visual_0_data_cntr <= ext(ext(visual_0_data_cntr,32) - 1,abs(13-0)+1);
        end if ;
      end if ;
    end if ;
  end process ;
 
  --  This is the address loaded at the start of any transfer to the address counter
  --  During config/load mode reg access, load_reg_data from reg.v module is loaded
  --  During master read/write access, dma_lar is loaded
  --  Druing target read/write access, s_adri is loaded
  process (target_write, bar0_hit, s_adri, dma_req_sdram, load_reg_data, dma_lar
    )
 
  begin
    if (target_write) = '1'  and (bar0_hit) = '1'  and (s_adri(19) = '0' ) then
      --  loaded when regs are loaded
      addrin <= (STD_LOGIC_VECTOR(STD_LOGIC_VECTOR'("0000000000")& load_reg_data
                ));
    else
      if dma_req_sdram = '1' then
        --  loaded when master read/write access to the memory
        addrin <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR'("0000")& dma_lar(24 downto
                  3));
      else
        addrin <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR'("00000")& s_adri(23 downto
                  3));
      end if ;
    end if ;
  end process ;
 
  --  The address load enable signal for the address counter
  process (target_write, bar0_hit, tw_mr_sm, dma_req_sdram, tr_mw_sm,
    target_read)
 
  begin
    if (target_write) = '1'  and (bar0_hit) = '1'  then
      --  loaded when regs are loaded
      addr_load <= '1';
    else
      if ((tw_mr_sm(0) = '1' and (target_write) = '1' )) or ((tr_mw_sm(0) = '1'
         and (target_read) = '1' )) then
        --  loaded when target write access to the sdram memory
        --  loaded when target read access to the sdram memory
        addr_load <= '1';
      else
        if dma_req_sdram = '1' then
          --  loaded when master read/write access to the memory
          addr_load <= '1';
        else
          addr_load <= '0';
        end if ;
      end if ;
    end if ;
  end process ;
 
  --  The clock enable signal for the data counter
  --  It is enabled during master read/write access to sdram
  datacnten <= (((wr_req or rd_req)) and dma_on_bit and not(data_cntr_zero)
    );
  -- /**** THE LOGIC BELOW IS ADDED IN ORDER TO COMPENSATE FOR THE ADDRESS WRAPPING IN THE SDRAM ****/
  --  Generation of load enable signal for address monitor counter
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      visual_0_ld_addr_monitor <= '0';
    elsif (clk'event and clk = '1' ) then
      if ((((tw_mr_sm(0) = '1' and (target_write) = '1' )) or ((tr_mw_sm(0) = '1'
          and (target_read) = '1' )))) and (bar1_hit) = '1'  then
        --  loaded when target write access to the sdram memory
        --  loaded when target read access to the sdram memory
        visual_0_ld_addr_monitor <= '1';
      else
        if dma_req_sdram = '1' then
          --  loaded when master read/write access to the memory
          visual_0_ld_addr_monitor <= '1';
        else
          visual_0_ld_addr_monitor <= '0';
        end if ;
      end if ;
    end if ;
  end process ;
 
  --  control signals which is the decoded value of address monitor
  visual_0_addr_monitor_7 <= (and_reduce(addr_monitor(2 downto 0))) and
    visual_0_low_addr_not_zero;
  addr_monitor_6 <= (addr_monitor(2) and addr_monitor(1) and not(addr_monitor(0))
    ) and visual_0_low_addr_not_zero;
  --  Address Monitor counter
  --  This counter increments when the data is read from the fifo
  --  If the starting three lower address is other than zero then this counter is incremented
  --  When this counter reaches 111 then the address is incremented which indicates that
  --  the next lower 3 bit address should be 000
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      addr_monitor <= "000";
    elsif (clk'event and clk = '1' ) then
      if (visual_0_ld_addr_monitor) = '1'  then
        --  the address is loaded at the start of transaction
        addr_monitor <= visual_0_addr(2 downto 0);
      else
        if (((rd_req) = '1'  or (wr_req) = '1' )) and (visual_0_addr_monitor_7
            = '0' ) then
          --  the address is incremented after every 8 DWORD(64 Bit) transfer
          addr_monitor(2 downto 0) <= ext(ext(addr_monitor(2 downto 0),32) + 1
                                      ,abs(2-0)+1);
        end if ;
      end if ;
    end if ;
  end process ;
 
  --  control signal which indicates that the lower address is seven
  --  this signal is required because it gives the indication that
  --  the lower address is 111 and the next immediate address has to be 000
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      low_addr_7 <= '0';
    elsif (clk'event and clk = '1' ) then
      if (visual_0_ld_addr_monitor) = '1'  and visual_0_addr(2 downto 0) = "111"
          then
        low_addr_7 <= '1';
      else
        if (rd_wr_ctrl_cntr_7) = '1'  then
          low_addr_7 <= '0';
        end if ;
      end if ;
    end if ;
  end process ;
 
  --  signal which indicates that addr is not zero
  low_addr_cnt_not_zero <= or_reduce(visual_0_addr(2 downto 0));
  --  This signal is generated when the lower address in not zero and is deasserted at the
  --  the end of first eight transaction on the sdram bus
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      visual_0_low_addr_not_zero <= '0';
    elsif (clk'event and clk = '1' ) then
      if (visual_0_ld_addr_monitor) = '1'  and (low_addr_cnt_not_zero) = '1'
          then
        visual_0_low_addr_not_zero <= '1';
      else
        if (((rd_wr_ctrl_cntr_7) = '1'  and (tw_mr_sm(0) = '0' ))) or (
           dis_monitor_sig) = '1'  then
          visual_0_low_addr_not_zero <= '0';
        end if ;
      end if ;
    end if ;
  end process ;
 
 
end ;

