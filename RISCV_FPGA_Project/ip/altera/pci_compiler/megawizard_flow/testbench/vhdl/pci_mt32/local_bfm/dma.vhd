-- ------------------------------------------------------------------
--   Altera PCI testbench
--   MODULE NAME: dma
--   COMPANY:  Altera Coporation.
--             www.altera.com    

--******************************************************************************************************
--  FUNCTIONAL DESCRIPTION:
-- This file describes the dma engine
-- it has two 32 bit registers dma_sa and dma_bc_la.
-- In order to initiate PCI transactions with Altera PCI MegaCore as Master, 
-- you need to perform 32 bit single cycle write to dma_sa 
-- followed by a 32 bit single cycle write to dma_bc_la. 
-- On being triggered the master control unit will request for the bus 
-- and execute the transaction as decoded by the dma_bc_la.
-- dma_sa:  This  register defines the system address (sa). 
--         This address is driven on the address phase of the PCI transaction.
-- dma_bc_la: This register defines the byte count(bc) ,local address(la), 
--            transaction width(32/64) and data direction
-- dma_bc_la register definition
--               [31..28]        [27..16]     [15..8]        [7..0]
--       Transaction width       Reserved     Byte Count     Local Address
--        and data direction
-- The following table describes the functions that can be performed 
-- depending on the value of dma_bc_la[31:28]
-- dma_bc_la[31:28]      Function
--          0000        32 bit Memory Read
--          0010        64 bit Memory Read
--          0100        32 bit IO Read
--          0110        32 bit IO write
--          1000        32 bit Memory write
--          1010        64 bit Memory write
--

-- This design implements  BAR2 for the dma_sa and dma_bc_la registers
---------------------------------------------------------------------------------------------------- 
-- Memory Region  Mapping       Block size  Address Offset  Description
----------------------------------------------------------------------------------------------------
-- BAR2           Memory Mapped 1 Kbyte     000-3FF         Maps the trg_termination register and
--                                                          DMA engine registers. Only the lower 24
--                                                          Bytes of the address space are used.
----------------------------------------------------------------------------------------------------
-- BAR2 Register Mapping
----------------------------------------------------------------------------------------------------
-- Address Space Range Reserved Mnemonic                Register Name
-- BAR2          00h-03h        targ_termination_reg    Target termination register.
-- BAR2          04h-07h        dma_sa[31:0]            DMA system address register
-- BAR2          08h-0Bh        dma_bc_la[31:0]         DMA byte count and local address register

--******************************************************************************************************

--   REVISION HISTORY:  
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

entity dma is
  port (
    Clk                  : in std_logic;                        -- Clk                                       
    Rstn                 : in std_logic;                        -- Reset                                     
                                                                                                             
    Pcil_dat_i           : in std_logic_vector (31 downto 0);   -- PCI Data Input                            
    Pcil_adr_i           : in std_logic_vector (31 downto 0);   -- PCI Address                               
    Pcil_cmd_i           : in std_logic_vector (3 downto 0);    -- PCI Command                               
                                                                                                             
    Pcilt_rdy_n_o        : out std_logic;                       -- PCI local Trdyn                           
    Pcilt_frame_n_i      : in std_logic;                        -- PCI Local framen                          
    Pcilt_ack_n_i        : in std_logic;                        -- PCI local ackowledgement                  
    Pcilt_dxfr_n_i       : in std_logic;                        -- PCI local data transfer                   
    Pcilt_tsr_i          : in std_logic_vector (11 downto 0);   -- PCI local status register                 
                                                                                                             
    Mstr_done_i          : in std_logic;                        -- Master Done Input                         
    Mstr_strt_o          : out std_logic;                       -- Master Start Ouput                        
    Mstr_dma_sa_o        : out std_logic_vector (31 downto 0);  -- Master dma and system address             
    Mstr_dma_bc_la_o     : out std_logic_vector (31 downto 0)   -- Master dma, byte_count, and local address 
    
   );
end dma;

architecture dma_rtl of dma is

  signal dma_bytecnt_locaddr  : std_logic_vector (31 downto 0);
  signal dma_sect_addr        : std_logic_vector (31 downto 0);
  signal nxstate              : std_logic_vector (3 downto 0);
  signal state                : std_logic_vector (3 downto 0);
  signal sx_data_tx           : std_logic;

  constant IDLE               : std_logic_vector := "0000";
  constant LD_SA              : std_logic_vector := "0011";
  constant LD_BC_LA           : std_logic_vector := "0101";
  constant MSTR_ACTIVE        : std_logic_vector := "1001";

begin

-- ********************************************
-- nxt_state_generator:
-- ********************************************

  process (Clk,Rstn)
  begin
    
    if  ( Rstn = '0' ) then
      state <= IDLE ;
    elsif(Clk'event and Clk='1') then
      state <= nxstate ;
    end if;
  
  end process;
  

-- ***************************************************
-- state_machine_controller:
-- ****************************************************

  process (Mstr_done_i,Pcil_adr_i,Pcil_cmd_i,Pcilt_frame_n_i,Pcilt_tsr_i,state,sx_data_tx)
  begin
    case  state  is
      when IDLE =>
        
        -- lt_framen is active, command is target write
        -- lt_tsr(2) indicates it is a BAR2 hit
        -- and address is 04h                  
        if  ( Pcilt_frame_n_i = '0' and Pcil_cmd_i(3 downto 0) = "0111" 
             and Pcilt_tsr_i(2) = '1' and Pcil_adr_i(3 downto 0) = "0100") then
          nxstate <= LD_SA ;
        else
          nxstate <= IDLE ;
        end if;
      
      -- Load System Address
      when LD_SA =>
        
        if  ( sx_data_tx = '1' ) then
          nxstate <= LD_BC_LA ;
        else
          nxstate <= LD_SA ;
        end if;
      
      -- Load Command, Byte Count and Local address
      when LD_BC_LA =>
        
        if  ( sx_data_tx = '1' ) then
          nxstate <= MSTR_ACTIVE ;
        else
          nxstate <= LD_BC_LA ;
        end if;
      
      -- Remain in Master active state till Master Controller finishes the transaction
      -- Described in dma_bytecnt_locaddr

      when MSTR_ACTIVE =>
        
        if  ( Mstr_done_i = '1' ) then
          nxstate <= IDLE ;
        else
          nxstate <= MSTR_ACTIVE ;
        end if;
      
      when OTHERS =>
          nxstate <= IDLE ;
    
    end case;
  
  end process;

------------------------------------------------------------------
-----------------Logic--------------------------------------------
------------------------------------------------------------------

  Mstr_dma_sa_o <= dma_sect_addr ; --  load system address                 
  Mstr_dma_bc_la_o <= dma_bytecnt_locaddr; --  load byte count and local address 
  sx_data_tx <= not ( Pcilt_dxfr_n_i ) and not ( Pcilt_ack_n_i ) ; -- successful_data transfer

-- lt_rdyn signal is driven to indicate that DMA engine is ready to accpt data
-- to load dma_sa and dma_bc_la
  Pcilt_rdy_n_o  <=  '0' when  (state(1) = '1'  or state(2) = '1')  else  '1';
  
--***********************************************************************
--DMA System Address
--During Master Read or Write this address will
--be put on PCI bus during address phase
--***********************************************************************
  process (Clk,Rstn)
  begin
    if  ( Rstn = '0' ) then
      dma_sect_addr <= (others => '0');
    
    elsif(Clk'event and Clk='1') then
    
      if  ( state(0) = '0' ) then
        dma_sect_addr <= (others => '0');
      elsif  ( state(1) = '1' and sx_data_tx = '1'  and Pcil_adr_i(3 downto 0) = "0100") then
        dma_sect_addr <= Pcil_dat_i(31 downto 0) ;
      end if;
    
    end if;
  end process;
  

--**************************************************************************
--DMA Command Byte Count and Local Address
--This register indicates the Master state machine regarding the following
--What operation to perfrom
-- dma_bc_la[31:28]      Function
--          0000        32 bit Memory Read
--          0010        64 bit Memory Read
--          0100        32 bit IO Read
--          0110        32 bit IO write
--          1000        32 bit Memory write
--          1010        64 bit Memory write
--What is the bytes to transfer.
--And what is the local side SRAM Memory address.
--*************************************************************************
  process (Clk,Rstn)
  begin
    if  ( Rstn = '0' ) then
      dma_bytecnt_locaddr <= (others => '0');
    
    elsif(Clk'event and Clk='1') then
    
      if  ( state(0) = '0' ) then
        dma_bytecnt_locaddr <= (others => '0');
      elsif  ( state(2) = '1' and sx_data_tx = '1' and Pcil_adr_i(3 downto 0) = "1000") then
        dma_bytecnt_locaddr <= Pcil_dat_i(31 downto 0) ;
      end if;
    
    end if;
  end process;
  
--***********************************************************************
--Master Start Register
--This signal will trigger Master State machine in local_master
--***********************************************************************

  process (Clk,Rstn)
  begin
    if  ( Rstn = '0' ) then
      Mstr_strt_o <= '0';
    
    elsif(Clk'event and Clk='1') then
    
      if  ( Mstr_done_i = '1' ) then
        Mstr_strt_o <= '0';
      else
        Mstr_strt_o <= state(3) ;
      end if;
    
    end if;
  end process;


end dma_rtl;
