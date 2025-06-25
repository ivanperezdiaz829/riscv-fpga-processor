-- ------------------------------------------------------------------
--   Altera PCI testbench
--   MODULE NAME: local_target
--   COMPANY:  Altera Coporation.
--             www.altera.com

--******************************************************************************************************
--  FUNCTIONAL DESCRIPTION:
--  This file implements the local Target Design
--  The local target consists of a simple state machine that performs 32- or
--  64-bit memory read/write transactions with the LPM memory and 32-bit
--  single-cycle I/O read/write transactions with an I/O register defined in
--  the top_local. 
--
--  The local target uses prefetch logic for burst read
--  transactions and ignores byte enables for all memory and I/O
--  transactions. 

----------------------------------------------------------------------------------------------------
-- BAR2 Register Mapping
----------------------------------------------------------------------------------------------------
-- Address Space Range Reserved Mnemonic                Register Name
-- BAR2          00h-03h        targ_termination_reg    Target termination register.
-- BAR2          04h-07h        dma_sa[31:0]            DMA system address register
-- BAR2          08h-0Bh        dma_bc_la[31:0]         DMA byte count and local address register
--
--  Depending on the value of the target termination register, the local target
--  performs the terminations 

--  targ_termination_reg Setting    Target Termination
--  xxxxxxx0                        Normal Termination
--  xxxxxxx1                        Target Retry
--  xxxxxxx2                        Disconnect
--******************************************************************************************************



--   REVISION HISTORY:
--   Revision 1.3 Description : Changed the code to make it synthesizable.
--   Revision 1.2 Description : No change.
--   Revision 1.1 Description : No change.
--   Revision 1.0 Description : Initial Release.


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
--  This reference design file is being provided on an 'as-is' basis and as an 
--  accommodation and therefore all warranties, representations or guarantees 
--  of any kind (whether express, implied or statutory) including, without limitation, 
--  warranties of merchantability, non-infringement, or fitness for a particular purpose, 
--  are specifically disclaimed.  By making this reference design file available, 
--  Altera expressly does not recommend, suggest or require that this reference design 
--  file be used in combination with any other product not provided by Altera.
-----------------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity local_target is
  port (
    
    Clk                  : in std_logic;                          -- Clock                                      
    Rstn                 : in std_logic;                          -- Reset                                
                                                                                                          
    Pcil_dat_i           : in std_logic_vector (31 downto 0);     -- PCI local data out                   
    Pcil_adr_i           : in std_logic_vector (31 downto 0);     -- PCI local SramAddr_o out             
    Pcil_ben_i           : in std_logic_vector (3 downto 0);      -- PCI local byte enable out            
    Pcil_cmd_i           : in std_logic_vector (3 downto 0);      -- PCI local command out                
    Pcilt_abort_n_o      : out std_logic;                         -- PCI local target abort               
    Pcilt_disc_n_o       : out std_logic;                         -- PCI local target disconnect          
    Pcilt_rdy_n_o        : out std_logic;                         -- PCI local target ready               
    Pcilt_frame_n_i      : in std_logic;                          -- PCI local target frame               
    Pcilt_ack_n_i        : in std_logic;                          -- PCI local target acknowledge         
    Pcilt_dxfr_n_i       : in std_logic;                          -- PCI local target data transfer       
    Pcilt_tsr_i          : in std_logic_vector (11 downto 0);     -- PCI local target status register     
    Pcilirq_n_o          : out std_logic;                         -- PCI local interrupt                  
    PciAd_o              : out std_logic_vector (31 downto 0);    -- PCI data output from target          
                                                                                                          
    TrgtDataTx_o         : out std_logic;                         -- Target successful data transfer      
    TrgtPrftchOn_o       : out std_logic;                        -- Target prefetch on                   
    PrftchReg_i          : in std_logic_vector (31 downto 0);     -- Target prefetch register             
    TrgtDone_o           : out std_logic;                         -- Target done                          
    TrgtIOWren_o         : out std_logic;                         -- Target IO Write Enable               
                                                                                                          
    SramDw_i             : in std_logic_vector (31 downto 0);     -- SramAddr_o to the memory             
    SramWrEn_o           : out std_logic;                         -- Sram write enable of the high dword  
    SramAddr_o           : out std_logic_vector (7 downto 0);     -- Sram low dword out from the memory   
                                                                                                          
    IODat_i              : in std_logic_vector (31 downto 0)      -- IO Data                              
                                                                    
   );
end local_target;


architecture local_target_rtl of local_target is

  constant IDLE               : std_logic_vector := "00000";  --state 0;
  constant TRGT_WR            : std_logic_vector := "00011";  --state 1;
  constant TRGT_RD_PRFTCH     : std_logic_vector := "00101";  --state 2;
  constant TRGT_RD            : std_logic_vector := "01001";  --state 3;
  constant TRGT_TERM_DEMO     : std_logic_vector := "10001";  --state 4;

  signal state                : std_logic_vector (4 downto 0);
  signal nxt_state            : std_logic_vector (4 downto 0);
  

  signal sram_addr            : std_logic_vector (7 downto 0); --  SRAM Address
  signal prftch_on            : std_logic;                     -- prefetch on  
  signal prftch_reg           : std_logic;

  signal ad_temp              : std_logic_vector (31 downto 0);
  
  signal io_rd                : std_logic;                    -- IO Read Transaction     
  signal io_wr                : std_logic;                    -- IO Write Transaction    
  signal mem_rd               : std_logic;                    -- Memory Read Transaction 
  signal mem_wr               : std_logic;                    -- Memory Write Transaction
                                                               
  signal sx_data_tx           : std_logic;                    -- successful data transfer 
  
  signal trgt_done            : std_logic;                    -- Target done signal              
  signal trgt_rd_tx           : std_logic;                    -- Target read transaction signal 
  signal trgt_wr_tx           : std_logic;                    -- Target Write transaction signal
    
  signal trgt_demo            : std_logic;
  signal trgt_term_demo_reg   : std_logic_vector (3 downto 0);   --  Target Termination Demo Register
  


begin

-- ********************************************
-- nxt_state_generator:
-- ********************************************
  process (Clk,Rstn)
  begin
    if  ( Rstn = '0' ) then
      state <= IDLE ;
    elsif(Clk'event and Clk='1') then            
      state <= nxt_state ;
    end if;

  end process;


-- ************************
-- state_machine_controller:
-- ************************
  process (state,trgt_demo,trgt_done,trgt_rd_tx,trgt_wr_tx)
  begin
    case  state  is
      
      when IDLE =>
        if  ( trgt_wr_tx = '1' ) then
          nxt_state <= TRGT_WR ;
        elsif  ( trgt_rd_tx = '1' ) then
          nxt_state <= TRGT_RD_PRFTCH ;
        elsif  ( trgt_demo = '1' ) then
          nxt_state <= TRGT_TERM_DEMO ;
        else
          nxt_state <= IDLE ;
        end if;

      -- Target Write     
      when TRGT_WR =>
        if  ( trgt_done = '1' ) then
          nxt_state <= IDLE ;
        else
          nxt_state <= TRGT_WR ;
        end if;
      
      -- Target Read Prefetch      
      when TRGT_RD_PRFTCH =>
        nxt_state <= TRGT_RD ;
      
      -- Target Read      
      when TRGT_RD =>
        if  ( trgt_done = '1' ) then
          nxt_state <= IDLE ;
        else
          nxt_state <= TRGT_RD ;
        end if;
      
      -- Target Termination Demo state 
      when TRGT_TERM_DEMO =>
        if  ( trgt_done = '1' ) then
          nxt_state <= IDLE ;
        else
          nxt_state <= TRGT_TERM_DEMO ;
        end if;
      
      
      when OTHERS =>
        nxt_state <= IDLE ;
    
    end case;
  end process;



---------------------------------------------------------------------------------------
--  Memory write transaction
--  The command is memory write and Pcilt_tsr_i(0) is bar0 hit
---------------------------------------------------------------------------------------
mem_wr <= '1' when ( Pcilt_frame_n_i = '0' and (Pcil_cmd_i = "0111" or Pcil_cmd_i = "1111") and Pcilt_tsr_i(0) = '1') else '0' ;


---------------------------------------------------------------------------------------
--  Memory read transaction
--  The Command is memory read and Pcilt_tsr_i(0) is bar0 hit
---------------------------------------------------------------------------------------
mem_rd <= '1' when ( Pcilt_frame_n_i = '0' and (Pcil_cmd_i = "0110" or Pcil_cmd_i = "1100" or Pcil_cmd_i = "1110") and Pcilt_tsr_i(0) = '1') else '0' ;
  

---------------------------------------------------------------------------------------
--  IO Write transaction
--  The command is io write and Pcilt_tsr_i(1) is bar1 hit.
---------------------------------------------------------------------------------------
io_wr <= '1' when ( Pcilt_frame_n_i = '0' and Pcil_cmd_i = "0011" and Pcilt_tsr_i(1) = '1') else '0' ;

  
---------------------------------------------------------------------------------------
--  IO read transaction
--  The command is io read and Pcilt_tsr_i(1) is bar1 hit.
---------------------------------------------------------------------------------------
io_rd <= '1' when ( Pcilt_frame_n_i = '0' and Pcil_cmd_i = "0010" and Pcilt_tsr_i(1) = '1') else '0' ;



-----------------------------------------------------------------------------------------
-- This command register is for demonstartion purpose with the help of which
-- retry and disconnect has been implemented
-- command write and Pcilt_tsr_i(2) which is a bar2 hit

--Based on the value that is written in the targ_demo register
--The following transaction will perform the following
--  targ_termination_reg Setting    Target Termination
--  xxxxxxx0                        Normal Termination
--  xxxxxxx1                        Target Retry
--  xxxxxxx2                        Disconnect       
-----------------------------------------------------------------------------------------
trgt_demo <= '1' when ( Pcilt_frame_n_i = '0' and Pcil_cmd_i = "0111" and Pcilt_tsr_i(2) = '1' and
                      Pcil_adr_i(3 downto 0) = "0000") else '0' ;
                      

-----------------------------------------------------------------------------------------                                
-- Target write or Read indicator
-----------------------------------------------------------------------------------------                                
                    
trgt_wr_tx <= mem_wr or io_wr ;
trgt_rd_tx <= mem_rd or io_rd ;


-----------------------------------------------------------------------------------------
-- The current target transaction is done when lt_tsr(8) and lt_ackn are inactive
-----------------------------------------------------------------------------------------
trgt_done <= not (Pcilt_tsr_i(8)) and Pcilt_ack_n_i ;


-----------------------------------------------------------------------------------------
-- Prefetch the data from memory for Target Read transaction
-----------------------------------------------------------------------------------------
  prftch_on <= mem_rd and state(2) ;
  
-----------------------------------------------------------------------------------------  
-- A successful data transfer is assertion of lt_dxfrn and lt_ackn
-----------------------------------------------------------------------------------------
  sx_data_tx <= not ( Pcilt_dxfr_n_i ) and not ( Pcilt_ack_n_i ) ;


-----------------------------------------------------------------------------------------
-- Sram Low Write enable is asserted when the state is target write, 
-- successful data transfer on the local side
-----------------------------------------------------------------------------------------
  SramWrEn_o <= state(1) and sx_data_tx and mem_wr;


-----------------------------------------------------------------------------------------
-- Target is ready to write and read except when the target termination demo register
-- is having a value that will make the target state machine go in a demo mode
-- to assert lt_discn.
-----------------------------------------------------------------------------------------
Pcilt_rdy_n_o <= '0' when ( ((state(1) = '1' or state(3) = '1') and 
                               ( trgt_term_demo_reg(3 downto 0) = "0010"or trgt_term_demo_reg(3 downto 0) = "0000"))  
                                or state(4) = '1')  else '1' ;
  
  
  
  TrgtDataTx_o <= sx_data_tx ;
  TrgtPrftchOn_o <= prftch_on ;
  TrgtDone_o <= trgt_done and ( state(1) or state(3) or state(4) ) ;
  Pcilirq_n_o <= '1';
  TrgtIOWren_o <= io_wr and state(1) and sx_data_tx ;
  SramAddr_o <= sram_addr ;
  Pcilt_abort_n_o <= '1';
  


--************************************************************************************
-- Address/Data
-- Based on the trasaction
-- If it is an IO transaction the data phase will have IO data(in this 
-- referece design the IO data is coming from the top_local wherein the IO
-- register is incorporated else
-- it is target read transaction
-- The data during target read transaction comes from
-- Prefetch Register:
-- Prefetch register is required in this kind of design because
-- inputs to the SRAM are registered, hence there will be a delay of one
-- clock to get the valid data for the give address for example
-- if address(1) is provided in clock x. the SRAM will give the data corresponding
-- to address(1) in clock x+1
-- Hence if there is a successful data transfer on the local side we need to provide the
-- next data immediately.
-- If we fetch data directly from SRAM we cannot provide data immediately because of the
-- registered inputs. hence this design performs the following
-- 1. We prefetch the data and increment the SRAM address
-- 2. Provide the Prefetch data as the first data.
-- 3. Switch to SRAM data as soon as prefetch data is transferred

-- Note that this design is assuming that there will be no wait states from Master
-- or target.
-- If the design has to take target waits into consideration
-- The below given logic will be different.

--************************************************************************************


  process (IODat_i,ad_temp,io_rd,io_wr,mem_rd,mem_wr,state)
  begin
    if  ( state(3) = '1' and  io_rd = '1' ) then            
      PciAd_o(31 downto 0) <= IODat_i ;
    elsif (state(3) = '1' and mem_rd = '1') then      
        PciAd_o(31 downto 0) <= ad_temp ;
    else
        PciAd_o <= (others => '0') ;
    end if;    
  end process;

  process (PrftchReg_i,SramDw_i,prftch_reg)
  begin
    if  ( prftch_reg = '1' ) then
      ad_temp <= PrftchReg_i ;
    else
      ad_temp <= SramDw_i ;
    end if;
  end process;

  process (Clk,Rstn)
  begin
    if  ( Rstn = '0' ) then
      prftch_reg <= '0';
    elsif(Clk'event and Clk='1') then
    
      if  ( prftch_on = '1' ) then
        prftch_reg <= '1';
      elsif  ( sx_data_tx = '1' ) then
        prftch_reg <= '0';
      end if;
    
    end if;
  end process;
  
  
--****************************************************************************************************
--Target Termination Demo Register
----------------------------------------------------------------------------------------------------
-- BAR2 Register Mapping
----------------------------------------------------------------------------------------------------
-- Address Space Range Reserved Mnemonic                Register Name
-- BAR2          00h-03h        targ_termination_reg    Target termination register.
--  Depending on the value of the target termination register, the local target
--  performs the terminations 

--  targ_termination_reg Setting    Target Termination
--  xxxxxxx0                        Normal Termination
--  xxxxxxx1                        Target Retry
--  xxxxxxx2                        Disconnect
--****************************************************************************************************

  process (Clk,Rstn)
  begin
    if  ( Rstn = '0' ) then
      trgt_term_demo_reg <= "0000";
    elsif(Clk'event and Clk='1') then
      if  ( ( state(1) = '1' or state(3) = '1' ) and trgt_done = '1' ) then
        trgt_term_demo_reg <= "0000";
      elsif  ( sx_data_tx = '1'  and  state(4) = '1') then
        trgt_term_demo_reg <= Pcil_dat_i(3 downto 0) ;
      end if;
    
    end if;
  end process;

--************************************************************************************
-- Target Disconnect signal
-- Assert Target disconnect signal based on the value given in the
-- target termination demo register(trgt_term_demo_reg)
--************************************************************************************

  process (Clk,Rstn)
  begin
    if  ( Rstn = '0' ) then
      Pcilt_disc_n_o <= '1';
    elsif(Clk'event and Clk='1') then
      if  ( ( state(1) = '1' or state(3) = '1') and 
            ( trgt_term_demo_reg(3 downto 0) = "0010" or trgt_term_demo_reg(3 downto 0) = "0001") ) then
        Pcilt_disc_n_o <= '0';
      else
        Pcilt_disc_n_o <= '1';
      end if;
    
    end if;
  end process;
  

-- ********************************
-- SramAddr_o incrementer
-- ********************************  

  process (Clk,Rstn)
  begin
    if  ( Rstn = '0' ) then
      sram_addr <= (others => '0') ;
    elsif(Clk'event and Clk='1') then
      
      if  ( state(0) = '0' ) then
        sram_addr <= Pcil_adr_i(9 downto 2) ;
      elsif  ( sx_data_tx = '1' or  prftch_on = '1' ) then
        sram_addr <= sram_addr + 1;
      end if;
    end if;
  end process;


end local_target_rtl;
