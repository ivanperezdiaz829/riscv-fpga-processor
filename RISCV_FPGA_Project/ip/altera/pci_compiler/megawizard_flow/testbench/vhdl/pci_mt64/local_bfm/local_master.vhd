-- ------------------------------------------------------------------
--   Altera PCI testbench
--   MODULE NAME: local_master

--*********************************************************************
--  FUNCTIONAL DESCRIPTION:
--  This file implements the local master design

--  The DMA engine triggers the local master. The local master can perform
--  32- and 64-bit memory read/write transactions with the LPM RAM block
--  and 32-bit single-cycle I/O read/write transactions with an I/O register
--  defined in the top local file. 
--  The local master uses prefetch logic for burst memory write transactions 
--  and uses the last_gen block to generate the  lm_lastn signal.
--  The local master ignores byte enables for all memory and I/O
--  transactions.
--  This Reference design will not retry the transaction for any target
--  initiated terminations
--*********************************************************************


--   REVISION HISTORY:
--   Revision 1.3 Description: Changed the code to make it synthesizable.
--   Revision 1.2 Description: Changed the address_inc logic.
--   Revision 1.1 Description: No change.
--   Revision 1.0 Description: Initial Release.
-- 
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
-----------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity local_master is
  port (
   
    Clk                  : in std_logic;                           -- Clk                                                 
    Rstn                 : in std_logic;                           -- Reset                                              
                                                                                                                         
    PciData_i            : in std_logic_vector (31 downto 0);      -- PCI data out                                       
    PciLDataAck_n_i      : in std_logic;                           -- PCI low dword data acknowledge                     
    PciHDataAck_n_i      : in std_logic;                           -- PCI high dword data acknowledge                    
    PciAdrAck_n_i        : in std_logic;                           -- PCI master address acknoweledge                    
    PciAck_n_i           : in std_logic;                           -- PCI master acknoweledge                            
    PciDxfr_n_i          : in std_logic;                           -- PCI master data transfer                           
    PciLmTsr_i           : in std_logic_vector (9 downto 0);       -- PCI master status register                         
    PciAd_o              : out std_logic_vector (63 downto 0);     -- PCI address Output                                 
    PciCben_o            : out std_logic_vector (7 downto 0);      -- PCI command and byte enable                        
    PciReq32_n_o         : out std_logic;                          -- PCI master request for 32 bit transfer             
    PciReq64_n_o         : out std_logic;                          -- PCI master request for 64 bit transfer             
    PciRdy_n_o           : out std_logic;                          -- PCI master ready                                   
    PciLastTx_n_o        : out std_logic;                          -- PCI mater last dword Transfer                      
                                                                                                                         
    DmaSa_i              : in std_logic_vector (31 downto 0);      -- DMA system address register input                  
    DmaBcLa_i            : in std_logic_vector (31 downto 0);      -- DMA byte count and local address reg. input        
    DmaStrtMstr_i        : in std_logic;                           -- DMA start master input                             
    PrftchReg_i          : in std_logic_vector (63 downto 0);      -- Prefetch register                                  
    DmaMstrDone_o        : out std_logic;                          -- DMA master done                                    
    MstrDataTx_o         : out std_logic;                          -- Data transfer master                               
    MstrPrftchOn_o       : out std_logic;                          -- Prefetch on                                        
    MstrIOWren_o         : out std_logic;                                                                                
    IODat_i              : in std_logic_vector (31 downto 0);                                                            
                                                                                                                         
    SramAddr_o           : out std_logic_vector (7 downto 0);      -- SRAM Address_o to the memory                       
    SramHighWrEn_o       : out std_logic;                          -- SRAM wr enable to the high dword section of the mem
    SramLowWrEn_o        : out std_logic;                          -- SRAM wr enable to the low dword section of the mem 
    SramHighDw_i         : in std_logic_vector (31 downto 0);      -- SRAM high dword output from the memory.            
    SramLowDw_i          : in std_logic_vector (31 downto 0)       -- SRAM low dword output from the memory.             

   );
end local_master;



architecture local_master_rtl of local_master is

  component lm_lastn_gen
    generic (
             width : natural := 7);           
    port (
    clk           : in  std_logic;
    rstn          : in  std_logic;
    wr_rdn        : in  std_logic;
    lm_req32n     : in  std_logic;
    lm_req64n     : in  std_logic; 
    lm_dxfrn      : in  std_logic;
    l_hdat_ackn   : in  std_logic;
    l_ldat_ackn   : in  std_logic;    
    lm_tsr        : in  std_logic_vector(9 downto 0);
    xfr_length    : in  std_logic_vector(width downto 0);
    abnormal_term : in  std_logic;
    lm_lastn      : out std_logic);       
  end component;

   

------------------------------------------------------------------------------
------------------Local Declarations-------------------------------------------
------------------------------------------------------------------------------


  constant IDLE               : std_logic_vector := "00000000"; --Idle                          
  constant REQ_BUS            : std_logic_vector := "00000011"; --Request Bus                   
  constant RD_ADDR            : std_logic_vector := "00000101"; --Read Address phase            
  constant RD_CHK             : std_logic_vector := "00001001"; --Read Check Phase              
  constant RD_DATA            : std_logic_vector := "00010001"; --Read data phase               
  constant WR_ADDR            : std_logic_vector := "00100001"; --Write Address phase           
  constant WR_CHK             : std_logic_vector := "01000001"; --Write Check phase             
  constant WR_DATA            : std_logic_vector := "10000001"; --Write Data phase              
  
  signal state                : std_logic_vector (7 downto 0);
  signal nxt_state            : std_logic_vector (7 downto 0);

 
  signal ad_temp              : std_logic_vector (63 downto 0);

  signal cben                 : std_logic_vector (3 downto 0);
  signal dma_sa_cnt           : std_logic_vector (31 downto 0);
  signal dmabcala_temp        : std_logic;

  signal io_rd_reg            : std_logic;
  signal io_wr_reg            : std_logic;

  signal lm_req32n            : std_logic;
  signal lm_req64n            : std_logic;
  

  signal mem_rd_reg           : std_logic;
  signal mem_tx               : std_logic;
  signal mem_wr_reg           : std_logic;
  
  signal mstr_disengage       : std_logic;
  signal abnormal_term        : std_logic;
  signal mstr_done            : std_logic;  
  signal pci_bcr              : std_logic_vector (7 downto 0);
  
  signal prftch_on            : std_logic;

  signal sram_addr            : std_logic_vector (7 downto 0);
  signal sram_addr_inc        : std_logic;
  signal sram_data            : std_logic_vector (63 downto 0);
  signal sram_high_addr_en    : std_logic;
  signal sram_low_addr_en     : std_logic;
  
  signal sx_data_tx           : std_logic;
  signal wr_rdn               : std_logic;

  signal addrinc_32pci64local : std_logic;
  signal addrinc_64pci64local : std_logic;

  signal cben_concat          : std_logic_vector (3 downto 0);

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


-- ***************************************************
-- state_machine_controller:
-- ****************************************************

  process (DmaBcLa_i,DmaStrtMstr_i,PciAck_n_i,PciAdrAck_n_i,PciLmTsr_i,mstr_disengage,mstr_done,state)
  begin

    case  state  is

      when IDLE =>
        
        -- Signal from DMA engine to start the Master Transaction
        if  ( DmaStrtMstr_i = '1' ) then
          nxt_state <= REQ_BUS ;
        else
          nxt_state <= IDLE ;
        end if;
            
      
      
      when REQ_BUS =>
        -- dma_bc_la[31:28]      Function          
        --          0000        32 bit Memory Read 
        --          0010        64 bit Memory Read 
        --          0100        32 bit IO Read     
        --          0110        32 bit IO write    
        --          1000        32 bit Memory write
        --          1010        64 bit Memory write
        
        if  ( ( DmaBcLa_i(31 downto 30) = "00")  or  ( DmaBcLa_i(31 downto 29) = "010") ) then
          nxt_state <= RD_ADDR ;
        elsif  ( ( DmaBcLa_i(31 downto 30) = "10")  or  ( DmaBcLa_i(31 downto 29) = "011") ) then
          nxt_state <= WR_ADDR ;
        else
          nxt_state <= IDLE ;
        end if;

--*****************************************************************
-- Read 
-- The following three states implement Master read operation
--######
-- During RD_ADDR state, Address and command is placed on the local side of the PCI bus
-- Transition to RD_CHK state** when lm_tsr(1) and lm_adr_ackn is valid
--######
-- In Rd_chk state it is important to check for lm_tsr(2) state.
-- This state is required because in order to start the transaction Arbiter has to 
-- keep the gntn asserted for three clocks, if the gntn is deasserted in less than three clocks
-- Master will initiate the transaction, in such cases the Read state machine should go back to 
-- RD_ADDR state and assert Address and command on the local side.
-- This explanation is also given in "Note to Table 3-10" in Master Local-side signals
-- This state is needed only if you are implementing the application for open systems
-- where you do not have control on how many clocks arbiter asserts gntn
--######
-- RD_DATA  state is the data phase
-- The Master transaction is completed for any one of the following
-- 1. Completed the intended number of dword transfers, indicated by mstr_done and PciAck_n_i
-- 2. There was target termination. indicated by mstr_disengage
-- mstr_done and mstr_disengage are derived from lm_tsr bits
--*****************************************************************


      when RD_ADDR =>
        if  ( PciAdrAck_n_i = '0'  and  PciLmTsr_i(1) = '1') then
          nxt_state <= RD_CHK ;
        else
          nxt_state <= RD_ADDR ;
        end if;
      
      when RD_CHK =>
        if  ( PciLmTsr_i(2) = '1' ) then
          nxt_state <= RD_DATA ;
        else
          nxt_state <= RD_ADDR ;
        end if;
      
      when RD_DATA =>
        if  ( ( mstr_done = '1'  or  mstr_disengage = '1' )  and  PciAck_n_i = '1' ) then
          nxt_state <= IDLE ;
        else
          nxt_state <= RD_DATA ;
        end if;
      
--*****************************************************************
-- Write
-- The following three states implement Master read operation
--######
-- During WR_ADDR state, Address and command is placed on the local side of the PCI bus
-- Transition to WR_CHK state** when lm_tsr(1) and lm_adr_ackn is valid
--######
-- In WR_CHK state it is important to check for lm_tsr(2) state.
-- This state is required because in order to start the transaction Arbiter has to 
-- keep the gntn asserted for three clocks, if the gntn is deasserted in less than three clocks
-- Master will initiate the transaction, in such cases the Write state machine should go back to 
-- WR_ADDR state and assert Address and command on the local side.
-- This explanation is also given in "Note to Table 3-10" in Master Local-side signals
-- This state is needed only if you are implementing the application for open systems
-- where you do not have control on how many clocks arbiter asserts gntn
--######
-- WR_DATA  state is the data phase
-- The Master transaction is completed for any one of the following
-- 1. Completed the intended number of dword transfers, indicated by mstr_done and PciAck_n_i
-- 2. There was target termination. indicated by mstr_disengage
-- mstr_done and mstr_disengage are derived from lm_tsr bits
--*****************************************************************

      
      when WR_ADDR =>
        if  ( PciAdrAck_n_i = '0'  and  PciLmTsr_i(1) = '1') then
          nxt_state <= WR_CHK ;
        else
          nxt_state <= WR_ADDR ;
        end if;
      
      when WR_CHK =>
        if  ( PciLmTsr_i(2) = '1' ) then
          nxt_state <= WR_DATA ;
        else
          nxt_state <= WR_ADDR ;
        end if;
      
      when WR_DATA =>
        if  ( ( mstr_done = '1'  or  mstr_disengage = '1')  and  PciAck_n_i = '1' ) then
          nxt_state <= IDLE ;
        else
          nxt_state <= WR_DATA ;
        end if;
      
-- *****************************************************************
    when OTHERS =>
        nxt_state <= IDLE ;
    end case;
  
  end process;

-- ------------------------------------------------------------------


-------------------------------------------------------------------- ---------------
-- Assert prefetch in REQUEST state and the transaction is Master write transaction.
-- This signal is asserted for one clock to the Prefetch file
-- Explanation of Prefetch is given in the prefetch file.           
------------------------------------------------------------------------------------                                               
prftch_on <= '1' when ( DmaBcLa_i(31 downto 30) = "10"   and  state(1) = '1') else '0' ;
MstrPrftchOn_o <= prftch_on ;


--Master done signal to DMA Engine
DmaMstrDone_o <= ( mstr_done or mstr_disengage ) and ( state(4) or state(7) ) ;

--Indication of Read or Write Transaction
wr_rdn <= ( state(5) or state(6) or state(7) ) ;


-- This signal feeds lm_rdy signal of the PCI core
-- This reference design indicates that it is always ready to
-- accept data or always ready with the data when the state machine is in the following states.

PciRdy_n_o <= not ( state(3) or state(4) or state(6) or state(7) ) ;

-- 32-bit or 64-bit request based on the command inthe dmabcala register from the DMA engine.
lm_req64n <= '0' when (state(1) = '1'  and  ( DmaBcLa_i(31 downto 29) = "001"  or  DmaBcLa_i(31 downto 29) = "101" )) else '1' ;
lm_req32n <= '0' when ((state(1) = '1'  and not ( DmaBcLa_i(31 downto 29) = "001"  or  DmaBcLa_i(31 downto 29) = "101" ))) else '1' ;
PciReq64_n_o <= lm_req64n ;
PciReq32_n_o <= lm_req32n ;


-- Master done signal 
mstr_done <= not ( PciLmTsr_i(2) or PciLmTsr_i(3) or PciLmTsr_i(8) or PciLmTsr_i(9) ) ;

-- Master disengage signal.
mstr_disengage <= ( PciLmTsr_i(4) or PciLmTsr_i(5) or PciLmTsr_i(6) or PciLmTsr_i(7) ) ;
abnormal_term <= mstr_disengage and (state(4) or state(7));

-- Successful data transfer on the local side.
sx_data_tx <= not ( PciDxfr_n_i ) and not ( PciAck_n_i ) ;


-- Byte Counter 
pci_bcr <= DmaBcLa_i(15 downto 8) ;


-- Sram Data.
sram_data(31 downto 0) <= SramLowDw_i ;
sram_data(63 downto 32) <= SramHighDw_i ;



-------------------------------------------------------------------------------------------
-- Reference
-- dma_bc_la[31:28]      Function
--          0000        32 bit Memory Read
--          0010        64 bit Memory Read
--          0100        32 bit IO Read
--          0110        32 bit IO write
--          1000        32 bit Memory write
--          1010        64 bit Memory write

-- Prefetch is required during Master Write transaction 
-- This signal indicates a successful data transfer to the Prefetch file
-- For 64-bit transfer it is same as sx_data_tx
-- For 32-bit transactions it is sram_high_addr_en and sx_data_tx.
-- sram_high_addr_en is required because we are fetching
-- 64 bits of data at a time from SRAM
-------------------------------------------------------------------------------------------

MstrDataTx_o <= '1' when ( ( sx_data_tx = '1' and  DmaBcLa_i(31 downto 29) = "101" )  or  
                            ( sx_data_tx = '1' and  sram_high_addr_en = '1'  and  DmaBcLa_i(31 downto 29) = "100" )) else '0' ;



-- Enable for IO reg in the top_local if it is an IO transaction   
MstrIOWren_o <= state(4) and sx_data_tx and io_rd_reg ;


-- Memory transaction indicator
mem_tx <= state(0) and ( mem_rd_reg or mem_wr_reg ) ;


---------------------------------------------------------------------------------------------------------------------------



-- Address for SRAM
SramAddr_o  <=  sram_addr  when  (DmaStrtMstr_i = '1')  else  (others => '0') ;


-- SRAM Write Enable 

dmabcala_temp <= '1' when ( DmaBcLa_i(31 downto 29) = "001"  or  DmaBcLa_i(31 downto 29) = "101" ) else '0' ;

SramLowWrEn_o <= ( ( state(4) and mem_rd_reg and dmabcala_temp and not PciLDataAck_n_i and sx_data_tx ) or 
                   ( state(4) and mem_rd_reg and not dmabcala_temp and sram_low_addr_en and sx_data_tx ) ) ;

SramHighWrEn_o <= ( ( state(4) and mem_rd_reg and dmabcala_temp and not PciHDataAck_n_i and sx_data_tx ) or 
                    ( state(4) and mem_rd_reg and not dmabcala_temp and sram_high_addr_en and sx_data_tx ) ) ;


-- SRAM Address Incrementing logic.
sram_addr_inc <= ( not PciHDataAck_n_i and sx_data_tx and state(7) ) ;

addrinc_64pci64local <= '1' when (sx_data_tx = '1'  and  PciHDataAck_n_i = '0'  and  ( DmaBcLa_i(31 downto 29) = "101"  or  DmaBcLa_i(31 downto 29) = "001" )) else '0' ;

addrinc_32pci64local <= '1' when (sx_data_tx = '1'  and  sram_high_addr_en = '1'  and  ( DmaBcLa_i(31 downto 29) = "100"  or  DmaBcLa_i(31 downto 29) = "000" )) else '0' ;
                                                                                                                                                                         

sram_low_addr_en <= '1' when ( state(0) = '1'  and  mem_tx = '1' and  not  ( dma_sa_cnt(3 downto 0) = "0100"  or  dma_sa_cnt(3 downto 0) = "1100" ) ) else '0' ;
sram_high_addr_en <= '1' when ( state(0) = '1'  and  mem_tx = '1' and    ( dma_sa_cnt(3 downto 0) = "0100"  or  dma_sa_cnt(3 downto 0) = "1100" ) ) else '0' ;

-----------------------------------------------------------------------------------------------------------------------------




-- ********************************************
-- Cben Output to the Core
-- ********************************************

  process (cben,state)
  begin
    if  ( state(2) = '1'  or  state(5) = '1' ) then
      PciCben_o(7 downto 4) <= (others => '0') ;
      PciCben_o(3 downto 0) <= cben ;
   else    
     PciCben_o(7 downto 0) <= (others => '0') ;
   end if;
  end process;

--*******************************************************************
-- Address/Data
-- Based on the trasaction
-- The first phase on PciAd_o is always DmaSa_i(Sytem Address) that will
-- be the address phase on the PCI bus.
-- If it is an IO transaction the data phase will have IO data(in this 
-- referece design the IO data is coming from the top_local wherein the IO
-- register is incorporated else
-- it is memory write transaction
--*******************************************************************

  process (DmaSa_i,IODat_i,ad_temp,io_wr_reg,mem_wr_reg,state)
  begin
       if  ( state(2) = '1'  or  state(5) = '1' ) then  -- Address Phase      
         PciAd_o(63 downto 32) <=  (others => '0') ;
         PciAd_o(31 downto 0) <= DmaSa_i ;
       elsif  ( ( state(6) = '1' or  state(7) = '1' )  and  io_wr_reg = '1' ) then -- IO Data
         PciAd_o(63 downto 32) <= (others => '0') ;
         PciAd_o(31 downto 0) <= IODat_i ;
       
       elsif  ( ( state(6) = '1' or  state(7) = '1' )  and  mem_wr_reg = '1' ) then -- SRAM Data 
         PciAd_o(63 downto 0) <= ad_temp ;    
       else
         PciAd_o(63 downto 0) <= (others => '0') ;
       end if;
  end process;



--*******************************************************************
-- Based on the kind of transaction on the PCI bus

-- 64 Bit PCI and 64 Bit Local side.
-- 

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

-- 32 Bit PCI and 64 Bit Local side.
-- For this kind of transaction we can always get the valid data from the prefetch register.

-- Note that this design is assuming that there will be no wait states from target.
-- The below given logic will be different If the design has to take target waits 
-- into consideration The below given logic will be different.

--*******************************************************************
  process (DmaBcLa_i,PciLmTsr_i,PrftchReg_i,SramHighDw_i,SramLowDw_i,sram_high_addr_en,sram_low_addr_en)
  begin
   
    -------------------------------------
    -- 64 Bit PCI and 64 Bit Local side.
    -------------------------------------
    if  ( DmaBcLa_i(31 downto 29) = "101" and  PciLmTsr_i(8) = '0' ) then
    
      ad_temp(63 downto 32) <= PrftchReg_i(63 downto 32) ;
      ad_temp(31 downto 0) <= PrftchReg_i(31 downto 0) ;

    elsif  ( DmaBcLa_i(31 downto 29) = "101" and  PciLmTsr_i(8) = '1' ) then
    
        ad_temp(63 downto 32) <= SramHighDw_i ;
        ad_temp(31 downto 0) <= SramLowDw_i ;
     
     
     -------------------------------------
     -- 32 Bit PCI and 64 Bit Local side. 
     -------------------------------------     
     elsif  ( DmaBcLa_i(31 downto 29) = "100" and  sram_high_addr_en = '1' ) then
        ad_temp(63 downto 32) <= (others => '0') ;        
        ad_temp(31 downto 0) <= PrftchReg_i(63 downto 32) ;
      
     elsif  ( DmaBcLa_i(31 downto 29) = "100" and  sram_low_addr_en = '1') then
        ad_temp(63 downto 32) <= (others => '0') ;        
        ad_temp(31 downto 0) <= PrftchReg_i(31 downto 0) ;
     else
        ad_temp <= (others => '0') ;        
    
     end if;
    
  end process;

-- ********************************************
-- Memory Read Register
-- ********************************************

  process (Clk,Rstn)
  begin
    if  ( Rstn = '0' ) then
      mem_rd_reg <= '0';
    elsif(Clk'event and Clk='1') then  
      if (state(0) = '1' and ( DmaBcLa_i(31 downto 30) = "00")) then
        mem_rd_reg <= '1';
      else 
        mem_rd_reg <= '0';
       end if;
    end if;
  end process;

-- ********************************************
-- Memory Write Register
-- ********************************************

  process (Clk,Rstn)
  begin
    if  ( Rstn = '0' ) then
      mem_wr_reg <= '0';
    elsif(Clk'event and Clk='1') then  
      if (state(0) = '1' and ( DmaBcLa_i(31 downto 30) = "10")) then 
          mem_wr_reg <= '1';
      else
          mem_wr_reg <= '0';
      end if;      
    end if;
  end process;

-- ********************************************
-- IO Read Register
-- ********************************************

  process (Clk,Rstn)
  begin
    if  ( Rstn = '0' ) then
      io_rd_reg <= '0';
    elsif(Clk'event and Clk='1') then  
      if (state(0) = '1' and ( DmaBcLa_i(31 downto 29) = "010")) then
            io_rd_reg <= '1';
      else
            io_rd_reg <= '0';
      end if;      
    end if;
  end process;

-- ********************************************
-- IO Write Register
-- ********************************************

  process (Clk,Rstn)
  begin
    if  ( Rstn = '0' ) then
      io_wr_reg <= '0';
    elsif(Clk'event and Clk='1') then  
      if (state(0) = '1' and ( DmaBcLa_i(31 downto 29) = "011")) then
          io_wr_reg <= '1';
      else
            io_wr_reg <= '0';
      end if;      
    end if;
  end process;

cben_concat <= mem_rd_reg & mem_wr_reg & io_rd_reg & io_wr_reg; 
-- ********************************************
-- Cben Logic
-- ********************************************

  process (cben,io_rd_reg,io_wr_reg,mem_rd_reg,mem_wr_reg,cben_concat)
  begin
    case  cben_concat  is
      when "1000"  =>  cben <= "0110";
      when "0100"  =>  cben <= "0111";
      when "0010"  =>  cben <= "0010";
      when "0001"  =>  cben <= "0011";
      when others  =>  cben <= "0000";
    end case;
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
        sram_addr <= DmaBcLa_i(7 downto 0) ;
      elsif  ( addrinc_64pci64local = '1' or  prftch_on = '1'  or  addrinc_32pci64local = '1' ) then
        sram_addr <= sram_addr + 1;
      end if;
    
    end if;
  end process;

-- ********************************
-- Counter for DMA System Address
-- ********************************

  process (Clk,Rstn)
  begin
    if  ( Rstn = '0' ) then
      dma_sa_cnt <= (others => '0') ;    
    
    elsif(Clk'event and Clk='1') then  
    
      if  ( state(0) = '0' ) then
        dma_sa_cnt <= DmaSa_i ;
      elsif  ( sx_data_tx = '1'  and  mem_tx = '1' ) then
        dma_sa_cnt <= dma_sa_cnt + 4 ;
      end if;
    
    end if;
  end process;

  last_gen0 : lm_lastn_gen
  
    port map (
    clk            =>  Clk,
    rstn           =>  Rstn,
    wr_rdn         =>  wr_rdn, 
    lm_req32n      =>  lm_req32n,
    lm_req64n      =>  lm_req64n,
    lm_dxfrn       =>  PciDxfr_n_i,
    l_ldat_ackn    =>  PciLDataAck_n_i,
    l_hdat_ackn    =>  PciHDataAck_n_i,
    lm_tsr         =>  PciLmTsr_i,
    xfr_length     =>  pci_bcr,
    abnormal_term  =>  abnormal_term,
    lm_lastn       =>  PciLastTx_n_o);       

end local_master_rtl;
