--  pci_mt32 Reference Design
--  MODULE NAME:  dma_sm
--  COMPANY:  Altera Coporation.
--            www.altera.com    

--  FUNCTIONAL DESCRIPTION:
--  This module implented the main DMA state machine which
--  controls the operation of the DMA transaction

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
use ieee.std_logic_unsigned.all;


entity dma_sm is
    Port (
        clk                                     : in std_logic;        
        rstn                                    : in std_logic;           
        normal_termination                      : in std_logic;           -- lm_lastn has asserted
        stop                                    : in std_logic;           -- the core has to release the bus
        lm_tsr                                  : in std_logic_vector(9 downto 0);
        err_pend                                : in std_logic;
        start                                   : in std_logic;
        start_chain                             : in std_logic;           -- chaining mode started
        chain_end                               : in std_logic;           -- end of the chain DMA
        p2s_fifo_empty                          : in std_logic;
        s2p_fifo_usedw                          : in std_logic_vector(6 downto 0);
        direction                               : in std_logic;                -- data direction (master write = 1; master read = 0)
        dma_bcr                                 : in std_logic_vector(16 downto 0);
        local_busy                              : in std_logic;               -- sdram controller is busy
        req                                     : out std_logic;              -- request the bus
        dma_done                                : out std_logic;                        
        dma_error                               : out std_logic;        
        chain_acr_ld                            : out std_logic;             -- loading the acr with data in the descriptor FIFO
        chain_bcr_ld                            : out std_logic;             -- loading the bcr with data in the descriptor FIFO
        dma_fifo_rd                             : out std_logic;             -- read the descriptor FIFO
        local_start                             : out std_logic;             -- trigger the SDRAM interface to start a new SDRAM access
        chain_dma_loading                       : out std_logic            -- loading the acr and bcr from dma fifo in progress
                                                                             -- used as mux select for data to the bcr and acr
        
        );
        
end dma_sm;

architecture rtl of dma_sm is

-- main state machine state encoding
constant IDLE                                    : std_logic_vector(11 downto 0) := "100000000000";     -- one hot encoding
constant DMA_REG_VALID                           : std_logic_vector(11 downto 0) := "010000000000";
constant WAIT_FOR_REQUEST                        : std_logic_vector(11 downto 0) := "001000000000";
constant REQUEST                                 : std_logic_vector(11 downto 0) := "000100000000";
constant WAIT_TSR_RESET                          : std_logic_vector(11 downto 0) := "000010000000";
constant STAND_BY                                : std_logic_vector(11 downto 0) := "000001000000";
constant DATA_TRANSFER                           : std_logic_vector(11 downto 0) := "000000100000";
constant ERROR                                   : std_logic_vector(11 downto 0) := "000000010000";
constant LOAD_DMA                                : std_logic_vector(11 downto 0) := "000000001000";
constant WAIT_P2S_FIFO_EMPTY                     : std_logic_vector(11 downto 0) := "000000000100";
constant WAIT_FOR_SDRAM_END                      : std_logic_vector(11 downto 0) := "000000000010";
constant DONE                                    : std_logic_vector(11 downto 0) := "000000000001";

-- DMA register load state machine encoding
constant LOAD_IDLE                               : std_logic_vector(4 downto 0) := "10000";     -- one hot encoding
constant FIFO_RD_INIT                            : std_logic_vector(4 downto 0) := "01000";
constant LOAD_ACR                                : std_logic_vector(4 downto 0) := "00100";
constant LOAD_BCR                                : std_logic_vector(4 downto 0) := "00010";
constant LOAD_DONE                               : std_logic_vector(4 downto 0) := "00001";


signal  dma_load_state                           : std_logic_vector(4 downto 0);
signal  dma_state                                : std_logic_vector(11 downto 0);
signal  bcr_eq_zero                              : std_logic;
signal  dma_ld_done                              : std_logic;
signal  dma_ld_trigger                           : std_logic;
signal  dma_reg_loaded                           : std_logic;
signal  dma_nxt_state                            : std_logic_vector(11 downto 0);
signal  dma_load_nxt_state                       : std_logic_vector(4 downto 0);
signal  stopSR                                   : std_logic;

begin
        
bcr_eq_zero <= '1' when dma_bcr(16 downto 2)=0
                   else '0';
                   
process(clk,rstn)
begin
  if(rstn='0') then
    stopSR <= '0';
  elsif(clk'event and clk='1') then
    if(stop='1') then
      stopSR <= '1';    
    elsif(dma_ld_done='1' or dma_reg_loaded='1') then
      stopSR <= '0';    
    end if;
  end if;
end process;
                   
-- DMA state machine

process (clk, rstn)     -- current state registers
    begin
        if rstn ='0' then
          dma_state             <= IDLE;  
        elsif clk'event and clk='1' then
          dma_state <= dma_nxt_state;
        end if;
    end process;
    
 -- next state logic
process(dma_state, start, start_chain, local_busy, bcr_eq_zero, direction, lm_tsr, dma_ld_done, chain_end, normal_termination, stopSR, err_pend, p2s_fifo_empty, dma_bcr, s2p_fifo_usedw)
    begin
           
          case dma_state is
          -- idle state. triggered when start signal is asserted
            when IDLE      =>   
                if (start = '1')  then
                  dma_nxt_state <= DMA_REG_VALID;
                elsif (start_chain = '1' and local_busy = '0') then
                  dma_nxt_state <= LOAD_DMA;
                else
                  dma_nxt_state <= IDLE;
                end if;

        -- DMA register valid. at this state, all the DMA register has valid data
        -- this state also signal the SDRAM interface logic to start an SDRAM access
        -- and latch the DMA registers values into its internal registers
            when DMA_REG_VALID     =>
                dma_nxt_state <= WAIT_FOR_REQUEST;
             
        -- Wait for request state. This state the state machine 
        -- stays in wait for request until the fifo is filled with all the needed data
        -- if the transfer length is less than 32, otherwise transfer when there are
        -- at least 32 dwords in the FIFO to avoid long wait states for master write transaction.
        -- For master read, request the bus immediately
        
            when WAIT_FOR_REQUEST   =>   
                if(bcr_eq_zero = '1') then        -- byte count reaches zero
                  dma_nxt_state <= DONE;
                elsif (   (direction = '0'    
                          or (local_busy='0' and dma_bcr(16 downto 2) < 64 and direction = '1' )
                       or (s2p_fifo_usedw = "1000000" and dma_bcr(16 downto 2) >= 64 and direction = '1' )) -- if need to transfer 32 or more, wait for 32 dwords before requesting the bus
                      and lm_tsr(3) = '0') then
                  dma_nxt_state <= REQUEST;
                else
                   dma_nxt_state <= WAIT_FOR_REQUEST;
                end if;
                
        -- Request state. Requesting the PCI bus         
            when REQUEST  => 
                dma_nxt_state <= WAIT_TSR_RESET;
        -- Wait for master status std_logic to be reset. After request, waits for all the 
        -- lm_tsr std_logics to be reset and this will happen after the bus is granted 
            when WAIT_TSR_RESET  =>
                if (lm_tsr(1) = '1') then               -- bus granted
                  dma_nxt_state <= STAND_BY;
                else
                  dma_nxt_state <= WAIT_TSR_RESET;
                end if;
         -- Load DMA. this state sets the triggering the loading of the bcr and acr from
         -- the descriptor FIFO for chaining mode operation
         -- when loading of acr and bcr is done, go to wait for request state.
            when LOAD_DMA  =>
                 if (dma_ld_done = '1') then            -- bus granted
                  dma_nxt_state <= WAIT_FOR_REQUEST;
                else
                  dma_nxt_state <= LOAD_DMA;
                end if;
                             
          -- stand by and waits for the data phase occurs on the pci bus before going to data transfer state
                        
             when STAND_BY  =>
          -- if lm_lastn has asserted, go to DONE only if all data has been transferred
                if( normal_termination = '1' and ((direction = '0' and (bcr_eq_zero = '1')) or direction = '1') and chain_end = '1') then
                  dma_nxt_state <= DONE;
          -- lm_lastn has asserted but not the last DMA in a chain
                elsif (normal_termination = '1' and chain_end = '0') then
                  dma_nxt_state <= WAIT_p2s_fifo_EMPTY;
          -- must get off the bus and the SDRAM controller is not busy
                elsif (stopSR = '1' and local_busy = '0') then
                  dma_nxt_state <= DMA_REG_VALID;
          -- must get off the bus and the sdram controller is busy
                elsif (stopSR = '1' and local_busy= '1') then
                  dma_nxt_state <= WAIT_FOR_SDRAM_END;
          -- PCI core enters the data phase
                elsif (lm_tsr(3) = '1') then    -- lm_ackn = 0
                  dma_nxt_state <= DATA_TRANSFER;
                else
                  dma_nxt_state <= STAND_BY;
                end if;
        
        -- Data transfer on the PCI bus
             when DATA_TRANSFER  =>
                if (normal_termination = '1'  and bcr_eq_zero = '1' and chain_end = '1') then
                  dma_nxt_state <= DONE;
                elsif (stopSR = '1' and local_busy = '1' ) or (normal_termination='1' and bcr_eq_zero='0' and lm_tsr(3)='0') then
                  dma_nxt_state <= WAIT_FOR_SDRAM_END; -- wait for end of sdram txfr before asserting dma_reg_valid
                elsif (stopSR = '1' and local_busy = '0' and lm_tsr(3) = '0')  then -- if end_sdram_txfr already assserted and no more data xfer, assert dma_reg_valid
                  dma_nxt_state <= DMA_REG_VALID;       
                elsif (err_pend = '1') then
                  dma_nxt_state <= ERROR;
                elsif (normal_termination = '1' and chain_end = '0') THEN
                  dma_nxt_state <= WAIT_p2s_FIFO_EMPTY;
                else
                  dma_nxt_state <= DATA_TRANSFER;
                end if;
                
         -- Wait for PCI-to-SDRAM FIFO empty
         -- for master read, waits for the sdram to read all data in the
         -- FIFO and stores them into the SDRAM before going to IDLE
         
            when WAIT_P2S_FIFO_EMPTY  =>
                if (p2s_fifo_empty = '1') THEN
                  dma_nxt_state <= IDLE;
                else
                  dma_nxt_state <= WAIT_P2S_FIFO_EMPTY;
                end if; 
         -- Wait for sdram end the transfer. wait for the SDRAM to complete the 
         -- current SDRAM cycle before triggering a new SDRAM access
            when WAIT_FOR_SDRAM_END  =>
                if(local_busy = '0' and lm_tsr(3) = '0') THEN
                  dma_nxt_state <= DMA_REG_VALID ;
                else
                  dma_nxt_state <= WAIT_FOR_SDRAM_END;
                end if;
         -- the DMA is done
            when DONE  =>
                dma_nxt_state <= IDLE;
        -- DMA error due to pariry
             when ERROR  =>
                dma_nxt_state <= IDLE;
                        
            when OTHERS         =>
                dma_nxt_state   <= IDLE;
          end case;
      end process;


-- output assignment

    req <= dma_state(8);
    dma_ld_trigger <= dma_state(3);
    dma_reg_loaded <= dma_state(10);
    dma_done <= dma_state(0);
    dma_error <= dma_state(4);
    


-- chain dma load state machine controls the load to acr and bcr from the chain dma fifo for each dma in a chain

 make_dma_load_state : process (clk, rstn)
    begin
        if rstn ='0' then
           dma_load_state <= LOAD_IDLE;
        elsif(clk'event and clk='1') then
           dma_load_state <= dma_load_nxt_state;
        end if;
        
  end process;
  
  
process(dma_load_state, dma_ld_trigger)
  begin 
    case dma_load_state is
        when LOAD_IDLE      => 
                 
          if dma_ld_trigger = '1'  then
             dma_load_nxt_state <= FIFO_RD_INIT;
          else
             dma_load_nxt_state <= LOAD_IDLE;
          end if;
                  
        when FIFO_RD_INIT     =>
                 
           dma_load_nxt_state <= LOAD_ACR;
             
        when LOAD_ACR   => 
 
           dma_load_nxt_state <= LOAD_BCR;
                           
        when LOAD_BCR  => 
 
           dma_load_nxt_state <= LOAD_DONE;
                           
        when LOAD_DONE  =>
 
           dma_load_nxt_state <= LOAD_IDLE;
                  
          
        when OTHERS         =>

          dma_load_nxt_state <= LOAD_IDLE;
       end case;
   
end process;

chain_acr_ld <= dma_load_state(2);
chain_bcr_ld <= dma_load_state(1);
dma_fifo_rd <= dma_load_state(3) or dma_load_state(2);
dma_ld_done <= dma_load_state(0);

      
      
-- assign outputs

local_start <= dma_ld_done or dma_reg_loaded;
chain_dma_loading <= dma_ld_trigger;



      
end rtl;
















