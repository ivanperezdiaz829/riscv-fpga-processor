--  pci_mt64 Reference Design
--  MODULE NAME:  mstr_cntrl
--  COMPANY:  Altera Coporation.
--            www.altera.com    

--  FUNCTIONAL DESCRIPTION:
--  Master control module. This module interface to the local
--  master signal of the core and the DMA engine and control the master transfer
--  of the core. It generates all of the local control signals necessary for 
--  the core to operate as a bus master.

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

entity mstr_cntrl is
    Port (
        clk                                     : in std_logic;         -- clock
        rstn                                    : in std_logic;         -- reset
        lm_ackn                                 : in std_logic; 
        lm_dxfrn                                : in std_logic;
        l_ldat_ackn                             : in std_logic;
        l_hdat_ackn                             : in std_logic;
        lm_tsr                                  : in std_logic_vector(9 downto 0);
        s2p_fifo_empty                          : in std_logic;
        p2s_lfifo_full                          : in std_logic;
        p2s_hfifo_full                          : in std_logic;
        p2s_fifo_empty                          : in std_logic;
        s2p_fifo_usedw                          : in std_logic_vector(6 downto 0);
        byte_cnt                                : in std_logic_vector(16 downto 0);                     
        wr_rdn                                  : in std_logic;
        dma_req                                 : in std_logic;
        end_sdram_txfr                          : in std_logic; 
        stat_reg                                : in std_logic_vector(5 downto 0);      
        local_start                             : in std_logic;                                 -- indicating a new request is sent to local from DMA
        dma_on                                  : in std_logic;
    
              
        lm_req32                                : buffer std_logic;
        lm_req64                                : buffer std_logic;
        lm_rdy                                  : out std_logic;
        lm_last                                 : out std_logic;
        p2s_hfifo_wrreq                         : out std_logic;
        p2s_lfifo_wrreq                         : out std_logic;
        s2p_fifo_rdreq                          : out std_logic;
        hdat_msk                                : out std_logic;
        ldat_msk                                : out std_logic;
        busy                                    : out std_logic;
        stop                                    : out std_logic;
        err_pend                                : out std_logic;
        abort                                   : out std_logic;
        scwr_hdat_sel                           : out std_logic;
        scrd_hdat_sel                           : out std_logic;
        bcr_cnten                               : out std_logic;
        acr_cnten                               : buffer std_logic;
        lar_cnten                               : out std_logic;
        mw_fifo_flush                           : out std_logic
                                                                         
        );

end mstr_cntrl;
        
architecture rtl of mstr_cntrl is

constant MW_IDLE                                : std_logic_vector(3 downto 0) := "1000";       -- one hot encoding
constant MW_WAIT                                : std_logic_vector(3 downto 0) := "0100";
constant MW_RDY                                 : std_logic_vector(3 downto 0) := "0010";
constant MW_STANDBY                                             : std_logic_vector(3 downto 0) := "0001";

constant MR_IDLE                                : std_logic_vector(3 downto 0) := "1000";
constant MR_WAIT                                : std_logic_vector(3 downto 0) := "0100";
constant MR_RDY                                 : std_logic_vector(3 downto 0) := "0010";
constant MR_WTBUSIDLE                           : std_logic_vector(3 downto 0) := "0001";




signal  mw_state                                : std_logic_vector(3 downto 0);
signal  mr_state                                : std_logic_vector(3 downto 0);
signal  timer_expired                           : std_logic;
signal  targ_disc                               : std_logic;
signal  targ_retry                              : std_logic;
signal  timer_expire_rise                       : std_logic;
signal  targ_disc_rise                          : std_logic;
signal  targ_retry_rise                         : std_logic;
signal  timer_expire_reg                        : std_logic;
signal  targ_disc_reg                           : std_logic;
signal  targ_retry_reg                          : std_logic;
signal  lm_last_int                             : std_logic;
signal  lm_last_reg                             : std_logic;
signal  lm_wr_rdy                               : std_logic;
signal  lm_rd_rdy                               : std_logic;
signal  pci_bcr                                 : std_logic_vector(13 downto 0);
signal  data_phase                              : std_logic;
signal  data_phase_reg                          : std_logic;
signal  data_phase_rise                         : std_logic;
signal  data_phase_fall                         : std_logic;
signal  bcr_zero                                : std_logic;
signal  single_cycle_reg                        : std_logic;
signal  three_cycle_reg                         : std_logic;
signal  bcr_one                                 : std_logic;
signal  bcr_two                                 : std_logic;
signal  bcr_three                               : std_logic;
signal  request_reg                             : std_logic;
signal  p2s_lfifo_wr                            : std_logic;
signal  p2s_hfifo_wr                            : std_logic;
signal  mr_tff                                  : std_logic;
signal  sc_lfifo_wr                             : std_logic;
signal  sc_hfifo_wr                             : std_logic;
signal  sc_mr                                   : std_logic;
signal  p2s_hfifo_wr_d                          : std_logic;
signal  p2s_lfifo_wr_d                          : std_logic;
signal  abrt_rd                                 : std_logic;
signal  two_cycle_reg                           : std_logic;
signal  ldat_msk_d                              : std_logic;
signal  hdat_msk_d                              : std_logic;
signal  mw_tff                                  : std_logic;
signal  mw_nxt_state                            : std_logic_vector(3 downto 0);
signal  local_bcr                               : std_logic_vector(13 downto 0);
signal  mr_nxt_state                            : std_logic_vector(3 downto 0); 
signal  lm_lastn                    : std_logic;
signal  lm_req32n                   : std_logic;
signal  lm_req64n                   : std_logic;


begin

-- local bcr counter keeps tracks of number of qwords get transfer on the local side
process(clk, rstn)
  begin
    if(rstn='0') then
       local_bcr <= (others => '0'); 
    elsif(clk'event and clk='1') then
       if (dma_req='1') then    -- load at request
         local_bcr <= byte_cnt(16 downto 3);           
       elsif(lm_dxfrn = '0') then
         local_bcr <= local_bcr - 1;
       end if;
    end if;
end process;


pci_bcr <= "00000000000010" when (byte_cnt(16 downto 3)= "00000000000001")  else  byte_cnt(16 downto 3);
data_phase <= lm_tsr(3);

process(clk,rstn)       -- register lm_tsr(3)
begin
  if(rstn='0') then
    data_phase_reg <= '0';
  elsif(clk'event and clk='1') then
    data_phase_reg <= data_phase;
  end if;
end process;

data_phase_rise <= not data_phase_reg and data_phase;



bcr_zero <= '1' when (byte_cnt=0)
                else '0';
                
bcr_one <= '1' when (byte_cnt(16 downto 3)=1)
                else '0';
                
bcr_two <= '1' when (byte_cnt(16 downto 3)=2)
                else '0';

bcr_three <= '1' when (byte_cnt(16 downto 3)=3)
                else '0';

--process(clk,rstn)     -- register lm_tsr(3)
--begin
 -- if(rstn='0') then
  --  single_cycle_reg <= '0';
  --elsif(clk'event and clk='1') then
   -- if(local_start='1') then
     -- single_cycle_reg <= bcr_one;
    --end if;
  --end if;
--end process;
      
   

-- this is the master write state machine that controls the ready signal lm_rdy


process(clk,rstn)
  begin
    if rstn = '0' then
      mw_state <= MW_IDLE;
    elsif (clk'event and clk = '1') then
      mw_state <= mw_nxt_state;
    end if;
  end process;
  
  process(mw_state, lm_tsr, wr_rdn, s2p_fifo_usedw, local_bcr, lm_dxfrn)  
    begin
      case mw_state is
        when MW_IDLE =>
          if(lm_tsr(1)='1' and wr_rdn='1') then
            mw_nxt_state <= MW_STANDBY;
          else
            mw_nxt_state <= MW_IDLE;
          end if;
        when MW_STANDBY =>
          if(local_bcr = 0) then
            mw_nxt_state <= MW_IDLE;
          else 
          mw_nxt_state <= MW_WAIT;
          end if;
        when MW_WAIT =>
            mw_nxt_state <= MW_RDY;
        
        when MW_RDY =>
          if(s2p_fifo_usedw=1 and lm_dxfrn='0') then-- fifo almost empty 
            mw_nxt_state <= MW_STANDBY;
          else 
            mw_nxt_state <= MW_RDY;
          end if;
        when OTHERS =>
          mw_nxt_state <= MW_IDLE;
        end case;
    end process;
          
  lm_wr_rdy <= mw_state(1);
  
  
-- this is the master read state machine that controls the ready signal lm_rdy


process(clk, rstn)              
  begin
    if (rstn='0') then
      mr_state <= MR_IDLE;
    elsif(clk'event and clk='1') then
      mr_state <= mr_nxt_state;
    end if;
  end process;
  
process(mr_state, data_phase_rise, wr_rdn, p2s_lfifo_full, p2s_hfifo_full, bcr_zero, timer_expired, targ_retry, targ_disc, lm_tsr)  
  begin 
      case mr_state is
        when MR_IDLE =>
          if(data_phase_rise='1' and wr_rdn='0') then
            mr_nxt_state <= MR_RDY;
          else
            mr_nxt_state <= MR_IDLE;
          end if;
        when MR_RDY     =>
          if(p2s_lfifo_full ='1' or p2s_hfifo_full ='1' ) then
            mr_nxt_state <= MR_WAIT;
          elsif (bcr_zero='1' or timer_expired='1' or targ_retry='1' or targ_disc='1') then
            mr_nxt_state <= MR_WTBUSIDLE;       -- wait for pci bus idle ( last data has been read)
          else 
            mr_nxt_state <= MR_RDY;
          end if;
                
        when MR_WTBUSIDLE       => -- keep lm_rdy asserted to tranfer the rest of data in the pipe to the local side
          if (lm_tsr(3)='0') THEN
            mr_nxt_state <= MR_IDLE;
          else 
            mr_nxt_state <= MR_WTBUSIDLE;
          end if;

        when MR_WAIT            =>
          if (p2s_lfifo_full='1' or p2s_hfifo_full='1' ) THEN
            mr_nxt_state <= MR_WAIT;
          else
            mr_nxt_state <= MR_RDY;
          end if;
        when OTHERS             =>
          mr_nxt_state <= MR_IDLE;
      end case;         
  
  end process;
            
lm_rd_rdy <= mr_state(1) or mr_state(0);
-- muxing the lm_rdy signal

process(wr_rdn, lm_wr_rdy, lm_rd_rdy)
  begin
    case wr_rdn is
      when '0' =>
        lm_rdy <= lm_rd_rdy;
      when OTHERS =>
        lm_rdy <= lm_wr_rdy;
    end case;
  end process;
  
  
-- muxing the req signal to lm_req32 and lm_req64

process(clk,rstn) -- set the single_cycle_reg,  when bcr equal to 1,2 at the begining of master transaction
  begin
    if(rstn='0') then
      single_cycle_reg <= '0';
      two_cycle_reg <= '0';
      three_cycle_reg <= '0';
    elsif(clk'event and clk='1') then
      if(local_start='1') then 
        single_cycle_reg <= bcr_one;
        two_cycle_reg <= bcr_two;
        three_cycle_reg <= bcr_three;
      end if;
    end if;
  end process;
   
process(clk,rstn)               -- register the dma_request signal from dma block
  begin
    if(rstn='0') then
      request_reg <= '0';
    elsif(clk'event and clk='1') then
        request_reg <= dma_req;
    end if;
   
 end process;

-- transfer in 32-std_logic mode when transfer length is single qword 
 -- or two qwords read                                          

lm_req32 <= single_cycle_reg and request_reg ;
            
-- otherwise transfer in 64-std_logic mode            
            
            
lm_req64 <=     not single_cycle_reg and request_reg;


     

busy <= lm_tsr(0) or lm_tsr(1) or lm_tsr(2) or lm_tsr(3); -- request, grant, address phase, or data phase  
stop <= timer_expire_rise or targ_disc_rise or targ_retry_rise;
timer_expired <= lm_tsr(4) and not bcr_zero and lm_ackn;
targ_disc <= lm_tsr(6) or lm_tsr(7);
targ_retry <= lm_tsr(5);
err_pend <= stat_reg(2) or stat_reg(3) or stat_reg(4) or stat_reg(5); -- abort, system err, par err
abort <= stat_reg(2);


-- instantiation of master fifo control module

fifo_cntrl0 : mstr_fifo_cntrl

port map (      clk             => clk,
                rstn            => rstn,        
                bcr_zero        => bcr_zero,    
                lm_dxfrn        => lm_dxfrn,    
                wr_rdn          => wr_rdn,      
                l_ldat_ackn     => l_ldat_ackn, 
                l_hdat_ackn     => l_hdat_ackn, 
                lm_tsr          => lm_tsr,
                single_cycle_reg => single_cycle_reg,   
      
                p2s_lfifo_wr => p2s_lfifo_wr,   
                p2s_hfifo_wr => p2s_hfifo_wr,   
                s2p_fifo_rdreq  => s2p_fifo_rdreq,      
                ldat_msk        => ldat_msk_d,  
                hdat_msk        => hdat_msk_d
                
        );
        
 -- generating the write requests to the pci-to-sdram fifos (low and high)
 -- When there is a single 64 std_logic master read transaction, the master control
 -- logic will request a 32 std_logic transaction and transfer 2 32-std_logic data in 
 -- a burst instead of a 64-std_logic single data phase
 -- The write request to the low dword fifo will be generated when the first
 -- data is transferred from the core to the local side, and then the high dword
 -- fifo write will be generated
 
 -- toggle flip flops to select high or low data when there is a
 -- single 64-std_logic master transaction 
 
 process(clk, local_start)
   begin
     if(local_start='1') then
       mr_tff <= '0';           -- reset when local start
     elsif(clk'event and clk='1') then
       if(lm_dxfrn='0') then
         mr_tff <= not mr_tff;
       end if;
     end if;
   end process;
   
   
   process(clk, rstn)
   begin
     if(rstn='0') then
       mw_tff <= '0';
     elsif(clk'event and clk='1') then
       if(local_start='1') then
         mw_tff <= '0';
       elsif(lm_dxfrn='0' and single_cycle_reg='1' and wr_rdn='1') then -- single cycle write data transfer
         mw_tff <= not mw_tff;
       end if;
     end if;
   end process;
   
   sc_lfifo_wr <= not lm_dxfrn and not mr_tff;
   sc_hfifo_wr <= not lm_dxfrn and mr_tff;
   
   -- mux the pci-to-sdram fifo write request for single 64-std_logic transfer
   
   sc_mr <= single_cycle_reg and not wr_rdn and dma_on; -- single 64-std_logic master read indicator used as mux sel
   
   process(sc_mr, sc_lfifo_wr, p2s_lfifo_wr)            -- low dword mux
     begin
       case sc_mr is
         when '1' =>                            -- single 64-std_logic master read
           p2s_lfifo_wr_d <= sc_lfifo_wr;       
         when others    =>
           p2s_lfifo_wr_d <= p2s_lfifo_wr;
         end case;
       end process;
       
       
   process(sc_mr, sc_hfifo_wr, p2s_hfifo_wr)            -- high dword mux (master read)
     begin
       case sc_mr is
         when '1' =>                            -- single 64-std_logic master read
           p2s_hfifo_wr_d <= sc_hfifo_wr;       
         when others    =>
           p2s_hfifo_wr_d <= p2s_hfifo_wr;
         end case;
       end process;
       
    
   -- register the output for fifo write request
   
process(clk, rstn)
     begin
       if(rstn='0') then
         p2s_lfifo_wrreq <= '0';
         p2s_hfifo_wrreq <= '0';
       elsif(clk'event and clk='1') then
         p2s_lfifo_wrreq <= p2s_lfifo_wr_d;
         p2s_hfifo_wrreq <= p2s_hfifo_wr_d;
       end if;
     end process;
     
-- register the mask std_logics
process(clk, rstn)
begin
       if(rstn='0') then
         ldat_msk <= '0';
         hdat_msk <= '0';
       elsif(clk'event and clk='1') then
         ldat_msk <= ldat_msk_d;
         hdat_msk <= hdat_msk_d;
       end if;
end process;

     
 -- single cycle master transaction handling signals
 scwr_hdat_sel <= mw_tff;

 
 -- count enable generation for bcr, acr, lar
 
 process(clk,rstn)      -- register timer_expire, targ_retry, targ_disc
 begin
   if(rstn='0') then
     timer_expire_reg <= '0';
     targ_disc_reg <= '0';
     targ_retry_reg <= '0';
   elsif(clk'event and clk='1') then
     timer_expire_reg <= timer_expired;
     targ_disc_reg <= targ_disc;
     targ_retry_reg <= targ_retry;
   end if;
 end process;



timer_expire_rise <= not timer_expire_reg and timer_expired;
targ_disc_rise <= not targ_disc_reg and targ_disc;
targ_retry_rise <= not targ_retry_reg and targ_retry;

 
abrt_rd <= timer_expire_rise or targ_disc_rise or targ_retry_rise;
 
cnten0 : cnten

Port map (      clk             =>      clk,
                rstn            =>      rstn,   
                pci_dxfr        =>      lm_tsr(8),
                lm_dxfrn        =>      lm_dxfrn,
                l_hdat_ackn     =>      l_hdat_ackn,
                wr_rdn          =>      wr_rdn,
                abrt_rd         =>      abrt_rd,
                lm_req32        =>      lm_req32,
                lm_req64        =>      lm_req64,
                grant           =>      lm_tsr(1),
                single_cycle_reg        =>      single_cycle_reg,
                bcr_zero        =>      bcr_zero,
                trans64         =>      lm_tsr(9),
                data_phase      =>      lm_tsr(3),
                
                bcr_cnten       =>      bcr_cnten,
                acr_cnten       =>      acr_cnten,
                lar_cnten       =>      lar_cnten
        
        );
        
       
-- lm_lastn generation

last : last_gen
port map(
    lm_lastn        => lm_lastn,
    clk             => clk,
    rstn            => rstn,
    wr_rdn          => wr_rdn,
    lm_req32n       => lm_req32n,
    lm_req64n       => lm_req64n,
    lm_dxfrn        => lm_dxfrn,
    l_hdat_ackn    => l_hdat_ackn,
    l_ldat_ackn    => l_ldat_ackn,
    lm_tsr         =>  lm_tsr,
    xfr_length    => pci_bcr(10 downto 0),
    abnormal_term =>  data_phase_fall
    );
       
lm_req32n <= not lm_req32;
lm_req64n <= not lm_req64;      
lm_last <= not lm_lastn;
        
-- master write fifo flush signal
-- when timer expire, target disconnect, target retry or end of data phase
process(clk,rstn)
begin
  if(rstn='0') then
    mw_fifo_flush <= '0';
  elsif(clk'event and clk='1') then
    if((abrt_rd='1' and data_phase='1') or data_phase_fall='1') then
      mw_fifo_flush <= '1';                     -- flush when abort sdram read or end of data phase
    elsif(local_start='1') then
      mw_fifo_flush <= '0';                     -- remove flush at the beginning master transaction
    end if;
  end if;
end process;
    
data_phase_fall <= not data_phase and data_phase_reg;
    
end rtl;        
                
                                        
                
                
                
                
                
                
                
                
                
                
                
                
                











































