--  pci_mt64 Reference Design

--  MODULE NAME: chip_top

--  COMPANY:  Altera Coporation.

--            www.altera.com    



--  FUNCTIONAL DESCRIPTION:

-- This module is the top level module that instatiates 

-- ** all components that are implemented in the FPGA device. The following

-- ** modules are instantiated:

-- ** 1. pci_top: pci_mt64

-- ** 2. backend interface

-- ** 3. sdram interface

-- ** 4. sdram controller



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

library work;

use ieee.std_logic_1164.all;

use ieee.std_logic_arith.all;

use ieee.std_logic_unsigned.all;

use work.components.all;



entity chip_top is

Port    (       -- PCI bus interface

                clk             : in std_logic;

                rstn            : in std_logic;

                idsel           : in std_logic;

                gntn            : in std_logic;

                reqn            : out std_logic;

                ad              : inout std_logic_vector(63 downto 0);

                cben            : inout std_logic_vector(7 downto 0);

                par             : inout std_logic;

                par64           : inout std_logic;

                req64n          : inout std_logic;

                framen          : inout std_logic;                      

                irdyn           : inout std_logic;

                ack64n          : inout std_logic;

                devseln         : inout std_logic;

                trdyn           : inout std_logic;

                stopn           : inout std_logic;

                perrn           : inout std_logic;

                serrn           : out std_logic;

                intan           : out std_logic;

                

                -- SDRAM module interface

                

                s_a             : out std_logic_vector(11 downto 0);    

                s_ba            : out std_logic_vector(1 downto 0);

                s_csn           : out std_logic_vector(1 downto 0);

                s_cke           : out std_logic;

                s_rasn          : out std_logic;

                s_casn          : out std_logic;

                s_wen           : out std_logic;

                s_dqmb          : out std_logic_vector(7 downto 0);

                s_dq            : inout std_logic_vector(63 downto 0)



                -- clock for SDRAM DIMM



                --clock1         : out std_logic

                                                         

        );





end chip_top;





architecture rtl of chip_top is





signal  l_adi           : std_logic_vector(63 downto 0);

signal  l_cbeni         : std_logic_vector(7 downto 0);                 

signal  l_adro64        : std_logic_vector(63 downto 0);

signal  l_adro          : std_logic_vector(31 downto 0);    

signal  l_beno          : std_logic_vector(7 downto 0);        

signal  l_cmdo          : std_logic_vector(3 downto 0);        

signal  l_dato          : std_logic_vector(63 downto 0);        

signal  lm_tsr          : std_logic_vector(9 downto 0);        

signal  lt_tsr          : std_logic_vector(11 downto 0);        

signal  stat_reg        : std_logic_vector(6 downto 0);              

signal  lirqn           : std_logic;        

signal  lm_lastn        : std_logic;    

signal  lm_rdyn         : std_logic;      

signal  lm_req32n       : std_logic;    

signal  lm_req64n       : std_logic;     

signal  lt_abortn       : std_logic;    

signal  lt_discn        : std_logic;     

signal  lt_rdyn         : std_logic;       

      

signal  l_hdat_ackn     : std_logic;  

signal  l_ldat_ackn     : std_logic;   

signal  lm_ackn         : std_logic;   

signal  lm_adr_ackn     : std_logic;  

signal  lm_dxfrn        : std_logic;      

signal  lt_ackn         : std_logic;      

signal  lt_dxfrn        : std_logic;     

signal  lt_framen       : std_logic;    



signal  sdram_trigger   : std_logic;    

signal  csr_reg         : std_logic_vector(8 downto 0);             

signal  bcr_reg         : std_logic_vector(16 downto 0);        

signal  lar_reg         : std_logic_vector(25 downto 0);    

signal  targ_wr         : std_logic;           

signal  targ_rd         : std_logic;        

signal  abrt_wr         : std_logic; 

signal  abrt_wr_wod             : std_logic;        

signal  abrt_rd         : std_logic;        

signal  p2s_lfifo_dato  : std_logic_vector(31 downto 0);

signal  p2s_hfifo_dato  : std_logic_vector(31 downto 0);

signal  p2s_lfifo_empty : std_logic;    

signal  p2s_lfifo_usedw : std_logic_vector(6 downto 0); 

signal  p2s_fifo_rdreq  : std_logic;

signal  s2p_fifo_dati   : std_logic_vector(63 downto 0);

signal  s2p_fifo_wrreq  : std_logic;

signal  sdram_end_txfr  : std_logic;

signal  sdram_cfg_dat   : std_logic_vector(31 downto 0);                

signal  sdram_adr       : std_logic_vector(25 downto 0);      

signal  bar0_hit        : std_logic;      

signal  bar1_hit        : std_logic;       

signal  data_mask       : std_logic_vector(7 downto 0); 

    

signal  cmdack          : std_logic;             

signal  cmd             : std_logic_vector(2 downto 0);                 

signal  addr            : std_logic_vector(25 downto 0);                

signal  dmn             : std_logic_vector(7 downto 0);                 

            

signal  sdram_wr_dat    : std_logic_vector(63 downto 0);

signal  sdram_rd_dat    : std_logic_vector(63 downto 0);    

        

        

begin   

        

        

        sdram_wr_dat <= (p2s_hfifo_dato & p2s_lfifo_dato);

        s2p_fifo_dati <= sdram_rd_dat;



        l_adro <= l_adro64(31 downto 0);

-- instantiate the pci core



pci_core: pci_top



port map (



                l_adi           =>      l_adi,                  

                l_cbeni         =>      l_cbeni,        

                l_adro          =>      l_adro64,

                l_beno          =>      l_beno,

                l_cmdo          =>      l_cmdo,

                l_dato          =>      l_dato,

                lm_tsr          =>      lm_tsr,

                lt_tsr          =>      lt_tsr,

                stat_reg        =>      stat_reg,

                ad              =>      ad,

                cben            =>      cben,

                clk             =>      clk,

                gntn            =>      gntn,

                idsel           =>      idsel,

                lirqn           =>      lirqn,

                lm_lastn        =>      lm_lastn,

                lm_rdyn         =>      lm_rdyn,

                lm_req32n       =>      lm_req32n,

                lm_req64n       =>      lm_req64n,

                lt_abortn       =>      lt_abortn,

                lt_discn        =>      lt_discn,

                lt_rdyn         =>      lt_rdyn,

                rstn            =>      rstn,

                intan           =>      intan,

                l_hdat_ackn     =>      l_hdat_ackn,

                l_ldat_ackn     =>      l_ldat_ackn,

                lm_ackn         =>      lm_ackn,

                lm_adr_ackn     =>      lm_adr_ackn,

                lm_dxfrn        =>      lm_dxfrn,

                lt_ackn         =>      lt_ackn,

                lt_dxfrn        =>      lt_dxfrn,

                lt_framen       =>      lt_framen,

                reqn            =>      reqn,

                serrn           =>      serrn,

                ack64n          =>      ack64n,

                devseln         =>      devseln,

                framen          =>      framen,

                irdyn           =>      irdyn,

                par             =>      par,

                par64           =>      par64,

                perrn           =>      perrn,

                req64n          =>      req64n,

                stopn           =>      stopn,

                trdyn           =>      trdyn

        );

        

---------------------------------------------------------------------------------



--back-end logic instantiation



backend0 : backend



port map (

                clk             =>      clk,                            

                rstn            =>      rstn,           

                l_adi           =>      l_adi,

                l_cbeni         =>      l_cbeni,        

                l_dato          =>      l_dato,

                l_adro          =>      l_adro, 

                l_beno          =>      l_beno, 

                l_cmdo          =>      l_cmdo, 

                l_hdat_ackn     =>      l_hdat_ackn,    

                l_ldat_ackn     =>      l_ldat_ackn,            

                lm_req32n       =>      lm_req32n,      

                lm_req64n       =>      lm_req64n,      

                lm_lastn        =>      lm_lastn,       

                lm_rdyn         =>      lm_rdyn ,

                lm_adr_ackn     =>      lm_adr_ackn,    

                lm_ackn         =>      lm_ackn ,

                lm_dxfrn        =>      lm_dxfrn,       

                lm_tsr          =>      lm_tsr  ,

                lt_abortn       =>      lt_abortn,              

                lt_discn        =>      lt_discn,       

                lt_rdyn         =>      lt_rdyn ,       

                lt_framen       =>      lt_framen,      

                lt_ackn         =>      lt_ackn ,

                lt_dxfrn        =>      lt_dxfrn,               

                lt_tsr          =>      lt_tsr  ,

                lirqn           =>      lirqn   ,

                stat_reg (5 downto 0)        =>      stat_reg (5 downto 0),                       

                                

                sdram_trigger   =>      sdram_trigger,  

                csr_reg         =>      csr_reg ,

                bcr_reg         =>      bcr_reg ,

                lar_reg         =>      lar_reg ,

                targ_wr         =>      targ_wr ,

                targ_rd         =>      targ_rd ,

                abrt_wr         =>      abrt_wr ,

                abrt_rd         =>      abrt_rd ,

                p2s_lfifo_dato  =>      p2s_lfifo_dato, 

                p2s_hfifo_dato  =>      p2s_hfifo_dato  ,

                p2s_lfifo_empty =>      p2s_lfifo_empty ,

                p2s_lfifo_usedw =>      p2s_lfifo_usedw ,

                p2s_fifo_rdreq  =>      p2s_fifo_rdreq  ,

                s2p_fifo_dati   =>      s2p_fifo_dati   ,

                s2p_fifo_wrreq  =>      s2p_fifo_wrreq  ,

                sdram_end_txfr  =>      sdram_end_txfr  ,

                sdram_cfg_dat   =>      sdram_cfg_dat   ,

                sdram_adr       =>      sdram_adr,

                bar0_hit        =>      bar0_hit,

                bar1_hit        =>      bar1_hit,

                data_mask       =>      data_mask,

                abrt_wr_wod     =>      abrt_wr_wod 

                

        );

        



---------------------------------------------------------------------------



-- SDRAM interface instantiation



sdr_inf0 : sdr_inf



port map (

                clk             =>      clk,            

                reset_n    =>      rstn,

                cmdack          =>      cmdack,

                cmd             =>      cmd,

                addr            =>      addr,

                dmn             =>      dmn,

                target_write    =>      targ_wr,

                target_read     =>      targ_rd,

                abort_wr        =>      abrt_wr,

                abort_wr_wod     =>      abrt_wr_wod,

                abort_rd        =>      abrt_rd,

                dma_req_sdram   =>      sdram_trigger,

                dma_csr         =>      csr_reg,

                dma_bcr         =>      bcr_reg,

                dma_lar         =>      lar_reg,

                pci_fifo_emptyn =>      p2s_lfifo_empty,

                ben             =>      data_mask,

                s_adri          =>      l_adro(25 downto 0),

                bar0_hit        =>      bar0_hit,

                bar1_hit        =>      bar1_hit,

                rdusedw         =>      p2s_lfifo_usedw,

                rd_req          =>      p2s_fifo_rdreq,

                wr_req          =>      s2p_fifo_wrreq,         

                end_sdram_txfr  =>      sdram_end_txfr

     

                                        

        );                              

                                        

--------------------------------------------------------------------------------------

-- Single Data Rate SDRAM controller instantiation



sdr_sdram0: sdr_sdram



generic map     (

                ASIZE           =>      26,          

                DSIZE           =>      64,

                ROWSIZE         =>      12,  

                COLSIZE         =>      8,        

                BANKSIZE        =>      2,  

                ROWSTART        =>      8,      

                COLSTART        =>      0,       

                BANKSTART       =>      20      

                        

                )               

                                        

port map        (



                CLK             =>      clk,   

                RESET_N         =>      rstn,    

                ADDR            =>      addr,               

                CMD             =>      cmd,          

                CMDACK          =>      cmdack,      

                DATAIN          =>      sdram_wr_dat,   

                DATAOUT         =>      sdram_rd_dat,          

                DM              =>      dmn,            

                SA              =>      s_a,         

                BA              =>      s_ba,       

                CS_N            =>      s_csn,       

                CKE             =>      s_cke,    

                RAS_N           =>      s_rasn,     

                CAS_N           =>      s_casn,           

                WE_N            =>      s_wen,

                DQ              =>      s_dq,                   

                DQM             =>      s_dqmb

                

                );

--------------------------------------------------------------------------------------



         



      

                                                        

end rtl;                                        

                                                        

                                                        

                                        

                                        

                                        

                                        

                                        













