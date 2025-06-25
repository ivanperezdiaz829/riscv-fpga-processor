--------------------------------------------------------------------
--  pci_mt32 Reference Design
--  MODULE NAME: vhdl_components
--  COMPANY:  Altera Coporation.
--            www.altera.com    

--  FUNCTIONAL DESCRIPTION:
--  This module contains component declarations for all
--  instantiated modules

--  This fifo is used to validate the bytes to be written in the SDRAM.

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



library IEEE;
use IEEE.std_logic_1164.all;


package components is
    
    
   
    
   -------------------------------------------------------------------------------------------
    component dma_sm
        
     Port (
        clk                                     : in std_logic;         -- clock
        rstn                                    : in std_logic;         -- reset
        normal_termination                      : in std_logic; 
        stop                                    : in std_logic;
        lm_tsr                                  : in std_logic_vector(9 downto 0);
        err_pend                                : in std_logic;
        start                                   : in std_logic;
        start_chain                             : in std_logic;
        chain_end                               : in std_logic;
        p2s_fifo_empty                          : in std_logic;
        s2p_fifo_usedw                          : in std_logic_vector(6 downto 0);
        direction                               : in std_logic;                 -- data direction (master write = 1; master read = 0)
        dma_bcr                                 : in std_logic_vector(16 downto 0);
        local_busy                              : in std_logic;
        req                                     : out std_logic;        
        dma_done                                : out std_logic;        
        dma_error                               : out std_logic;        
        chain_acr_ld                            : out std_logic;
        chain_bcr_ld                            : out std_logic;
        dma_fifo_rd                             : out std_logic;
        local_start                             : out std_logic;
        chain_dma_loading                       : out std_logic 
       
        );
        
    end component;
    
    
    component dma_reg
    
      Port (
       clk                        : in std_logic;                               -- clock
        rstn                       : in std_logic;                               -- reset
   
        adr                        : in std_logic_vector(7 downto 0);            -- address of the register to be accessed
        dati                       : in std_logic_vector(31 downto 0);           -- data input to the register
        wen                        : in std_logic;                               -- write enable to the register
        acr_ld                     : in std_logic;                               -- load acr in chaining mode
        bcr_ld                     : in std_logic;                               -- load bcr in chaining mode
        acr_cnten                  : in std_logic;                               -- address counter count enable
        lar_cnten                  : in std_logic;                               -- local address counter count enable
        bcr_cnten                  : in std_logic;                               -- byte counter count enable
        isr_in                     : in std_logic_vector(5 downto 0);            -- set signal for the interrupt status register      
        dma_on                     : in std_logic;                               -- indicate dma is in progress, input to csr(6)
        cs                         : in std_logic;                               -- chip select
        acr                        : out std_logic_vector(31 downto 0);          -- address counter
        bcr                        : out std_logic_vector(16 downto 0);          -- byte counter
        csr                        : out std_logic_vector(8 downto 0);           -- control and status register
        isr                        : out std_logic_vector(5 downto 0);           -- interrupt status register
        lar                        : out std_logic_vector(25 downto 0);          -- local address register
        dato                       : out std_logic_vector(31 downto 0);          -- data outputs from the DMA registers
        dma_reg_hit                : out std_logic_vector(4 downto 0)
      
           );
    end component;
  -----------------------------------------------------------------------------------------------------
        
    component LPM_FIFO
        generic (LPM_WIDTH : natural;    -- MUST be greater than 0
                 LPM_WIDTHU : natural := 1;    -- MUST be greater than 0
                 LPM_NUMWORDS : natural;    -- MUST be greater than 0
                                 LPM_SHOWAHEAD : string := "OFF";
                                 LPM_TYPE : string := "LPM_FIFO";
                                 LPM_HINT : string := "UNUSED");
        port (  DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
                CLOCK : in std_logic;
                WRREQ : in std_logic;
                RDREQ : in std_logic;
                ACLR : in std_logic := '0';
                SCLR : in std_logic := '0';
                Q : out std_logic_vector(LPM_WIDTH-1 downto 0);
                USEDW : out std_logic_vector(LPM_WIDTHU-1 downto 0);
                FULL : out std_logic;
                EMPTY : out std_logic 
                );
end component;

-------------------------------------------------------------------------------------------------------------
component data_fifo

port    (
        clk                                     : in std_logic;         -- clock
        rstn                                    : in std_logic;         -- reset
        pci2sdram_fifo_ldati                    : in std_logic_vector(31 downto 0);
        pci2sdram_fifo_hdati                    : in std_logic_vector(31 downto 0);
        pci2sdram_fifo_ldat_wrreq               : in std_logic;
        pci2sdram_fifo_hdat_wrreq               : in std_logic;
        pci2sdram_fifo_ldat_rdreq               : in std_logic;
        pci2sdram_fifo_hdat_rdreq               : in std_logic;
        pci2sdram_fifo_flush                    : in std_logic;
        
        sdram2pci_fifo_dati                     : in std_logic_vector(63 downto 0);
        sdram2pci_fifo_wrreq                    : in std_logic;
        sdram2pci_fifo_rdreq                    : in std_logic;
        sdram2pci_fifo_flush                    : in std_logic;
        
        ben_fifo_ldati                          : in std_logic_vector(3 downto 0);
        ben_fifo_hdati                          : in std_logic_vector(3 downto 0);
        ben_fifo_hdat_wrreq                     : in std_logic;
        ben_fifo_ldat_wrreq                     : in std_logic;
        ben_fifo_hdat_rdreq                     : in std_logic;
        ben_fifo_ldat_rdreq                     : in std_logic;
        ben_fifo_flush                          : in std_logic;
        
        pci2sdram_fifo_ldato                    : out std_logic_vector(31 downto 0);
        pci2sdram_fifo_hdato                    : out std_logic_vector(31 downto 0);
        pci2sdram_fifo_ldat_full                : out std_logic;
        pci2sdram_fifo_hdat_full                : out std_logic;
        pci2sdram_fifo_ldat_empty               : out std_logic;
        pci2sdram_fifo_hdat_empty               : out std_logic;
        pci2sdram_fifo_ldat_usedw               : out std_logic_vector(6 downto 0);
        pci2sdram_fifo_hdat_usedw               : out std_logic_vector(6 downto 0);
        
        sdram2pci_fifo_dato                     : out std_logic_vector(63 downto 0);
        sdram2pci_fifo_usedw                    : out std_logic_vector(6 downto 0);
        sdram2pci_fifo_full                     : out std_logic;
        sdram2pci_fifo_empty                    : out std_logic;
        
        ben_fifo_hdato                          : out std_logic_vector(3 downto 0);     
        ben_fifo_ldato                          : out std_logic_vector(3 downto 0)
       
        );
end component;
        

-------------------------------------------------------------------------------------------------------

component cnten

port    (
        clk                                     : in std_logic;         -- clock
        rstn                                    : in std_logic;         -- reset
        pci_dxfr                                : in std_logic;         -- data transfer on the pci bus
        lm_dxfrn                                : in std_logic;
        l_hdat_ackn                             : in std_logic;
        wr_rdn                                  : in std_logic;
        abrt_rd                                 : in std_logic;
        lm_req32                                : in std_logic;
        lm_req64                                : in std_logic;
        grant                                   : in std_logic;
        single_cycle_reg                        : in std_logic;
        bcr_zero                                : in std_logic;
        trans64                                 : in std_logic;
        data_phase                              : in std_logic;
                
        bcr_cnten                               : out std_logic;
        acr_cnten                               : buffer std_logic;
        lar_cnten                               : out std_logic
       
        );
end component;
        
----------------------------------------------------------------------------------------------------
component last_gen

port (
    lm_lastn      : out std_logic;
    clk           : in  std_logic;          -- clock
    rstn          : in  std_logic;          -- active low reset
    wr_rdn        : in  std_logic;          -- write = 1 and read = 0
    lm_req32n     : in  std_logic;          -- 32-bit request
    lm_req64n     : in  std_logic;          -- 64-bit request
    lm_dxfrn      : in  std_logic;          -- local master data transfer
    l_hdat_ackn   : in  std_logic;          -- local high data acknowledge
    l_ldat_ackn   : in  std_logic;          -- local low data acknowledge
    lm_tsr        : in  std_logic_vector(9 downto 0);
                                            -- local master transaction status register
    xfr_length    : in  std_logic_vector(10 downto 0);
                                            -- # of transfers required
    abnormal_term : in  std_logic);         -- Active high signal indicating an
                                            -- abnormal  termination occured. This signal
                                            -- should  indicate that one of the
                                            -- following conditions occured
                                            -- Latency timeout
                                            -- Target Disconnect
                                            -- Target retry
                                            -- Target abort
                                            -- Master abort

end component;

-------------------------------------------------------------------------------------
component mstr_fifo_cntrl

port(   clk                     : in std_logic;         -- clock
        rstn                    : in std_logic;         -- reset
        bcr_zero                : in std_logic;         -- the byte counter has counted down to zero
        lm_dxfrn                : in std_logic;         -- data transfer on the local side
        wr_rdn                  : in std_logic;         
        l_ldat_ackn             : in std_logic;         -- low dword is transferred on the local side
        l_hdat_ackn             : in std_logic;         -- high dword is transferred on the local side
        lm_tsr                  : in std_logic_vector(9 downto 0);
        single_cycle_reg        : in std_logic;
        
        
        p2s_lfifo_wr            : buffer std_logic;     -- pci2sdram low fifo write signal (master read)
        p2s_hfifo_wr            : buffer std_logic;     -- pci2sdram high fifo write signal (master read)
        s2p_fifo_rdreq          : out std_logic;        -- sdram2pci fifo read request (master write)  
        ldat_msk                : out std_logic; --   master read low dword byte enable used to mask the 
                                                                    --   invalid dword before writting qword data to the sdram
        hdat_msk                : out std_logic  --   master read high byte enable used to mask the 
                                                                    --   invalid dword before writting qword data to the sdram                                     
        );
        
end component;

---------------------------------------------------------------------------------------------------
component targ_fifo_cntrl

port(   clk                     : in std_logic;         
        rstn                    : in std_logic;
        lt_framen_fall          : in std_logic;
        lt_framen               : in std_logic;
        tw_cmd                  : in std_logic;
        tr_cmd                  : in std_logic;
        sdram_hit               : in std_logic;
        adr                     : in std_logic_vector(7 downto 0);
        tw_sdram_busy           : in std_logic;
        lt_dxfrn                : in std_logic;
        l_ldat_ackn             : in std_logic;
        l_hdat_ackn             : in std_logic;
        lt_tsr7                 : in std_logic; 
        tw_idle                 : in std_logic;     
        ldat_msk                : out std_logic;
        hdat_msk                : out std_logic;
        p2s_lfifo_wr            : out std_logic;
        p2s_hfifo_wr            : out std_logic;
        s2p_fifo_rdreq          : out std_logic
                                            
        );
        
end component;

------------------------------------------------------------------------------------------------------
component dma

port(   clk                     : in std_logic;                     -- clock
      rstn                    : in std_logic;                     -- reset
      start                   : in std_logic;                     -- trigger state machine
      dati                    : in std_logic_vector(31 downto 0); -- data input
      adr                     : in std_logic_vector(7 downto 0);  -- address of the dma register
      reg_wen                 : in std_logic;                     -- dma register write enable
      fifo_wen                : in std_logic;                     -- dma fifo write enable
      wr_rdn                  : in std_logic;                     -- write/read signal to dma registers
      cs                      : in std_logic;                     -- chip select (dma_register)
      bcr_cnten               : in std_logic;                     -- byte counter count enable
      acr_cnten               : in std_logic;                     -- address counter count enable
      lar_cnten               : in std_logic;                     -- local address counter count enable
      p2s_fifo_empty          : in std_logic;                     -- high and low p2s both empty
      s2p_fifo_usedw          : in std_logic_vector(6 downto 0);                
      mstr_busy               : in std_logic;
      stop                    : in std_logic;                     -- PCI core signals stop current dma
      abort                   : in std_logic;                     -- PCI core signals abort current dma
      last_xfr                : in std_logic;                     -- PCI core signals last transfer
      local_busy              : in std_logic;                     -- sdram is busy
      err_pend                : in std_logic;                     -- target abort, parity error, master abort
      lm_tsr                  : in std_logic_vector(9 downto 0);  -- master status std_logics
      isr_rd                  : in std_logic;                     -- isr read signal 
   
      isr                     : out std_logic_vector(5 downto 0);
      csr                     : out std_logic_vector(8 downto 0);
      bcr                     : out std_logic_vector(16 downto 0);
      acr                     : out std_logic_vector(31 downto 0);
      lar                     : out std_logic_vector(25 downto 0);
      req                     : out std_logic;                     -- dma requesting a PCI core for data transfer
      local_start             : out std_logic;                     -- dma requesting sdram controller to start data transfer
      dato                    : out std_logic_vector(31 downto 0);  -- dma register read data output   
      probe                   : out std_logic_vector(7 downto 0)    
                                            
        );
        
end component;

-------------------------------------------------------------------------------------------------------------------------
component targ_cntrl

port(     clk                                   : in std_logic;         -- clock
        rstn                                    : in std_logic;         -- reset
        lt_framen                               : in std_logic;
        lt_dxfrn                                : in std_logic;
        lt_tsr                                  : in std_logic_vector(11 downto 0);
        adr                                     : in std_logic_vector(25 downto 0);     -- target address
        cmd                                     : in std_logic_vector(3 downto 0);      -- target command
        s2p_fifo_usedw                          : in std_logic_vector(6 downto 0);      -- words in the sdram-to-pci fifo
        p2s_fifo_full                           : in std_logic;                         -- pci-to-sdram low fifo full
        sdram_end_txfr                          : in std_logic;                         -- sdram has finish current data access
        
        retry                                   : out std_logic;
        lt_rdy                                  : out std_logic;                        -- local target ready
        targ_rd                                 : out std_logic;                        -- indicate target read cycle to sdram
        targ_wr                                 : out std_logic;                        -- indicate target write cycle to sdram
        p2s_fifo_wrreq                          : out std_logic;                        -- pci-to-sdram low fifo write
        s2p_fifo_rdreq                          : out std_logic;                        -- sdram-to-pci fifo read
        
        dma_reg_cs                              : out std_logic;                -- dma register chip select
        dma_reg_wen                             : out std_logic;                -- dma register write enable
        dma_fifo_wen                            : out std_logic;                -- dma fifo write enable
        isr_rd                                  : out std_logic;                -- isr register read
        tr_fifo_flush                           : out std_logic               -- target read fifo flush
                                            
        );
        
end component;

------------------------------------------------------------------------------------------------------------------------------
component mstr_cntrl

port(   clk                                     : in std_logic;         -- clock
        rstn                                    : in std_logic;         -- reset
        lm_ackn                                 : in std_logic; 
        lm_dxfrn                                : in std_logic;
        lm_tsr                                  : in std_logic_vector(9 downto 0);

        p2s_fifo_full                           : in std_logic;
        

        s2p_fifo_usedw                          : in std_logic_vector(6 downto 0);
        byte_cnt                                : in std_logic_vector(16 downto 0);                     
        wr_rdn                                  : in std_logic;
        dma_req                                 : in std_logic;
       
        stat_reg                                : in std_logic_vector(5 downto 0);      
        local_start                             : in std_logic;                                 -- indicating a new request is sent to local from DMA
      
    
              
        lm_req                          : buffer std_logic;
    
        lm_rdy                                  : out std_logic;
        lm_last                                 : out std_logic;

        p2s_fifo_wrreq                          : out std_logic;
        s2p_fifo_rdreq                          : out std_logic;
     
        busy                                    : out std_logic;
        stop                                    : out std_logic;
        err_pend                                : out std_logic;
        abort                                   : out std_logic;
        bcr_cnten                               : out std_logic;
        acr_cnten                               : buffer std_logic;
        lar_cnten                               : out std_logic;
        mw_fifo_flush                           : out std_logic
                                            
        );
        
end component;

-----------------------------------------------------------------------------------------------------------------------
component datapath_fifo

port(   clk                     : in std_logic;
        rstn                    : in std_logic;
        p2s_fifoi               : in std_logic_vector(31 downto 0);
       
        p2s_fifo_wrreq          : in std_logic;
     
        p2s_fifo_rdreq          : in std_logic;
      
        p2s_fifo_flush          : in std_logic;
        
        s2p_fifo_dati           : in std_logic_vector(31 downto 0);
        s2p_fifo_wrreq          : in std_logic;
        s2p_fifo_rdreq          : in std_logic;
        s2p_fifo_flush          : in std_logic;
       
     
     
        
        p2s_fifo_out            : out std_logic_vector(31 downto 0);
       
        p2s_fifo_full           : out std_logic;
       
        p2s_fifo_empty          : out std_logic;
    
        p2s_fifo_usedw          : out std_logic_vector(6 downto 0);
      
        
        s2p_fifo_dato           : out std_logic_vector(31 downto 0);
        s2p_fifo_usedw          : out std_logic_vector(6 downto 0);
        s2p_fifo_full           : out std_logic;
        s2p_fifo_empty          : out std_logic
                                            
        );
        
end component;

----------------------------------------------------------------------------------------
component pci_top

port (
         l_adi : IN std_logic_vector(31 downto 0);
      l_cbeni : IN std_logic_vector(3 downto 0);
      cache : OUT std_logic_vector(7 downto 0);
      cmd_reg : OUT std_logic_vector(6 downto 0);
      l_adro : OUT std_logic_vector(31 downto 0);
      l_beno : OUT std_logic_vector(3 downto 0);
      l_cmdo : OUT std_logic_vector(3 downto 0);
      l_dato : OUT std_logic_vector(31 downto 0);
      lm_tsr : OUT std_logic_vector(9 downto 0);
      lt_tsr : OUT std_logic_vector(11 downto 0);
      stat_reg : OUT std_logic_vector(6 downto 0);
      ad : INOUT std_logic_vector(31 downto 0);
      cben : INOUT std_logic_vector(3 downto 0);
      clk : IN std_logic;
      gntn : IN std_logic;
      idsel : IN std_logic;
      lirqn : IN std_logic;
      lm_lastn : IN std_logic;
      lm_rdyn : IN std_logic;
      lm_req32n : IN std_logic;
      lt_abortn : IN std_logic;
      lt_discn : IN std_logic;
      lt_rdyn : IN std_logic;
      rstn : IN std_logic;
      intan : OUT std_logic;
      lm_ackn : OUT std_logic;
      lm_adr_ackn : OUT std_logic;
      lm_dxfrn : OUT std_logic;
      lt_ackn : OUT std_logic;
      lt_dxfrn : OUT std_logic;
      lt_framen : OUT std_logic;
      reqn : OUT std_logic;
      serrn : OUT std_logic;
      devseln : INOUT std_logic;
      framen : INOUT std_logic;
      irdyn : INOUT std_logic;
      par : INOUT std_logic;
      perrn : INOUT std_logic;
      stopn : INOUT std_logic;
      trdyn : INOUT std_logic
        
        );
end component;


--------------------------------------------------------------------

component sdr_inf

port (
         clk : in STD_LOGIC;
        reset_n : in STD_LOGIC;
        cmdack : in STD_LOGIC;
        cmd : out STD_LOGIC_VECTOR (2 downto 0);
        addr : out STD_LOGIC_VECTOR (25 downto 0);
        dmn : out STD_LOGIC_VECTOR (3 downto 0);
        target_write : in STD_LOGIC;
        target_read : in STD_LOGIC;
        abort_wr : in STD_LOGIC;
        abort_rd : in STD_LOGIC;
        dma_req_sdram : in STD_LOGIC;
        dma_csr : in STD_LOGIC_VECTOR (8 downto 0);
        dma_bcr : in STD_LOGIC_VECTOR (16 downto 0);
        dma_lar : in STD_LOGIC_VECTOR (25 downto 0);
        pci_fifo_emptyn : in STD_LOGIC;
        ben : in STD_LOGIC_VECTOR (3 downto 0);
        s_adri : in STD_LOGIC_VECTOR (25 downto 0);
        bar0_hit : in STD_LOGIC;
        bar1_hit : in STD_LOGIC;
        rdusedw : in STD_LOGIC_VECTOR (6 downto 0);
        rd_req : out STD_LOGIC;
        wr_req : out STD_LOGIC;
        end_sdram_txfr : out STD_LOGIC;
        abort_wr_wod : in std_logic
        
        );
        
end component;


--------------------------------------------------------------------------------

component backend

Port    (       -- pci core interface
               clk                      : in std_logic;
                rstn                    : in std_logic;
                l_adi                   : out std_logic_vector(31 downto 0);
                l_cbeni                 : out std_logic_vector(3 downto 0);
                l_dato                  : in std_logic_vector(31 downto 0);
                l_adro                  : in std_logic_vector(31 downto 0);
                l_beno                  : in std_logic_vector(3 downto 0);
                l_cmdo                  : in std_logic_vector(3 downto 0);
                lm_req32n               : out std_logic;
                lm_lastn                : out std_logic;
                lm_rdyn                 : out std_logic;
                lm_adr_ackn             : in std_logic;
                lm_ackn                 : in std_logic;
                lm_dxfrn                : in std_logic;
                lm_tsr                  : in std_logic_vector(9 downto 0);
        
                
                lt_abortn               : out std_logic;
                lt_discn                : out std_logic;
                lt_rdyn                 : out std_logic;
                lt_framen               : in std_logic;
                lt_ackn                 : in std_logic;
                lt_dxfrn                : in std_logic;
                lt_tsr                  : in std_logic_vector(11 downto 0);
                lirqn                   : out std_logic;
                stat_reg                : in std_logic_vector(5 downto 0);
                
                -- sdram controller interface
                
                sdram_trigger           : out std_logic;
                csr_reg                 : out std_logic_vector(8 downto 0);
                bcr_reg                 : out std_logic_vector(16 downto 0);
                lar_reg                 : out std_logic_vector(25 downto 0);
                targ_wr                 : out std_logic;
                targ_rd                 : out std_logic;
                abrt_wr                 : out std_logic;
                abrt_rd                 : out std_logic;
                p2s_fifo_dato           : out std_logic_vector(31 downto 0);            
                
                p2s_fifo_empty          : out std_logic;
                p2s_fifo_usedw          : out std_logic_vector(6 downto 0);
                p2s_fifo_rdreq          : in std_logic;
                s2p_fifo_dati           : in std_logic_vector(31 downto 0);
                s2p_fifo_wrreq          : in std_logic;
                sdram_end_txfr          : in std_logic;
                sdram_cfg_dat           : out std_logic_vector(31 downto 0);
                sdram_adr               : out std_logic_vector(25 downto 0);
                bar0_hit                : out std_logic;
                bar1_hit                : out std_logic;
                abrt_wr_wod             : out std_logic
                
                                                         
        );

end component;

------------------------------------------------------------------------------------------------------------

component sdr_sdram
        
    generic (
         ASIZE          : integer := 23;
         DSIZE          : integer := 32;
         ROWSIZE        : integer := 12;
         COLSIZE        : integer := 9;
         BANKSIZE       : integer := 2;
         ROWSTART       : integer := 9;         
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
         DQM            : out     std_logic_vector(DSIZE/8-1 downto 0)         --SDRAM data mask lines
        );
end component;

component fifo_128x32
        PORT
        (
                data            : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                wrreq           : IN STD_LOGIC ;
                rdreq           : IN STD_LOGIC ;
                clock           : IN STD_LOGIC ;
                aclr            : IN STD_LOGIC ;
                sclr            : IN STD_LOGIC ;
                q               : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                full            : OUT STD_LOGIC ;
                empty           : OUT STD_LOGIC ;
                usedw           : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
        );
end component;


component fifo_256x32
        PORT
        (
                data            : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                wrreq           : IN STD_LOGIC ;
                rdreq           : IN STD_LOGIC ;
                clock           : IN STD_LOGIC ;
                aclr            : IN STD_LOGIC ;
                sclr            : IN STD_LOGIC ;
                q               : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                empty           : OUT STD_LOGIC 
        );
end component;


component apex_pll
        PORT
        (
                inclock         : IN STD_LOGIC ;
                clock1          : OUT STD_LOGIC 
        );
end component;
end components;








