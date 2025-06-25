--  pci_mt32 Reference Design
--  MODULE NAME:  backend
--  COMPANY:  Altera Coporation.
--            www.altera.com    

--  FUNCTIONAL DESCRIPTION:
--  This module is the top level of the local interface logic
--  to the pci mt64 core and the sdram controller

-- Copyright (C) 1991-2004 Altera Corporation
-- Any megafunction design, and related net list (encrypted or decrypted),
-- support information, device programming or simulation file, and any other
-- associated documentation or information provided by Altera or a partner
-- under Altera's Megafunction Partnership Program may be used only to
-- program PLD devices (but not masked PLD devices) from Altera.  Any other
-- use of such megafunction design, net list, support information, device
-- programming or simulation file, or any other related documentation or
-- information is prohibited for any other purpose, including, but not
-- limited to modification, reverse engineering, de-compiling, or use with
-- any other silicon devices, unless such use is explicitly licensed under
-- a separate agreement with Altera or a megafunction partner.  Title to
-- the intellectual property, including patents, copyrights, trademarks,
-- trade secrets, or maskworks, embodied in any such megafunction design,
-- net list, support information, device programming or simulation file, or
-- any other related documentation or information provided by Altera or a
-- megafunction partner, remains with Altera, the megafunction partner, or
-- their respective licensors.  No other licenses, including any licenses
-- needed under any third party's intellectual property, are provided herein.
---------------------------------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.components.all;

entity backend is
Port 	(	-- pci core interface
  		clk			: in std_logic;
  		rstn			: in std_logic;
  		l_adi			: out std_logic_vector(31 downto 0);
  		l_cbeni			: out std_logic_vector(3 downto 0);
  		l_dato			: in std_logic_vector(31 downto 0);
  		l_adro			: in std_logic_vector(31 downto 0);
  		l_beno			: in std_logic_vector(3 downto 0);
  		l_cmdo			: in std_logic_vector(3 downto 0);
  		lm_req32n		: out std_logic;
  		lm_lastn		: out std_logic;
  		lm_rdyn			: out std_logic;
  		lm_adr_ackn		: in std_logic;
  		lm_ackn			: in std_logic;
  		lm_dxfrn		: in std_logic;
  		lm_tsr			: in std_logic_vector(9 downto 0);
	
  		
  		lt_abortn		: out std_logic;
  		lt_discn		: out std_logic;
  		lt_rdyn			: out std_logic;
  		lt_framen		: in std_logic;
  		lt_ackn			: in std_logic;
  		lt_dxfrn		: in std_logic;
  		lt_tsr			: in std_logic_vector(11 downto 0);
  		lirqn			: out std_logic;
  		stat_reg		: in std_logic_vector(5 downto 0);
  		
  		-- sdram controller interface
  		
  		sdram_trigger		: out std_logic;
  		csr_reg			: out std_logic_vector(8 downto 0);
  		bcr_reg			: out std_logic_vector(16 downto 0);
  		lar_reg			: out std_logic_vector(25 downto 0);
  		targ_wr			: out std_logic;
  		targ_rd			: out std_logic;
  		abrt_wr			: out std_logic;
  		abrt_rd			: out std_logic;
  		p2s_fifo_dato		: out std_logic_vector(31 downto 0);		
  		
  		p2s_fifo_empty		: out std_logic;
  		p2s_fifo_usedw		: out std_logic_vector(6 downto 0);
  		p2s_fifo_rdreq		: in std_logic;
  		s2p_fifo_dati		: in std_logic_vector(31 downto 0);
  		s2p_fifo_wrreq		: in std_logic;
  		sdram_end_txfr		: in std_logic;
  		sdram_cfg_dat		: out std_logic_vector(31 downto 0);
  		sdram_adr		: out std_logic_vector(25 downto 0);
  		bar0_hit		: out std_logic;
  		bar1_hit		: out std_logic;
  		abrt_wr_wod             : out std_logic
  						 
	);
	
end backend;

architecture rtl of backend is

signal	ad_loaded_reg			: std_logic;
signal	dma_reg_wen			: std_logic;
signal	dma_fifo_wen			: std_logic;
signal	tw_cmd				: std_logic;
signal	dma_reg_cs			: std_logic;
signal	bcr_cnten			: std_logic;
signal	acr_cnten			: std_logic;
signal	lar_cnten			: std_logic;
signal	s2p_fifo_empty			: std_logic;
signal	mstr_busy			: std_logic;
signal	mstr_stop			: std_logic;
signal	mstr_abort			: std_logic;
signal	lm_last				: std_logic;
signal	local_busy			: std_logic;
signal	err_pend			: std_logic;
signal	isr_rd				: std_logic;	
signal	isr				: std_logic_vector(5 downto 0);
signal	csr				: std_logic_vector(8 downto 0);				
signal	bcr				: std_logic_vector(16 downto 0);			
signal	lar				: std_logic_vector(25 downto 0);			
signal	acr				: std_logic_vector(31 downto 0);
signal	dma_request			: std_logic;		
signal	local_start			: std_logic;
signal	dma_dato			: std_logic_vector(31 downto 0);			
signal	dati				: std_logic_vector(31 downto 0);						-- data input to to pci core
signal	dma_rd_reg			: std_logic;
signal	tr_cmd				: std_logic;
signal	s2p_fifo_usedw			: std_logic_vector(6 downto 0);
signal	p2s_fifo_full			: std_logic;
signal	lt_rdy				: std_logic;
signal	targ_p2s_lfifo_wrreq		: std_logic;
signal	targ_p2s_hfifo_wrreq		: std_logic;
signal	targ_s2p_fifo_rdreq		: std_logic;
signal	lm_req			        : std_logic;
signal	lm_rdy				: std_logic;
signal	mstr_p2s_fifo_wrreq		: std_logic;
signal	mstr_s2p_fifo_rdreq		: std_logic;
signal	p2s_fifo_wrreq			: std_logic;
signal	p2s_fifoi			: std_logic_vector(31 downto 0);
signal	s2p_fifo_flush			: std_logic;
signal	mw_fifo_flush			: std_logic;
signal	tr_fifo_flush			: std_logic;
signal	mw_flush_sel			: std_logic;
signal	s2p_fifo_dato			: std_logic_vector(31 downto 0);
signal	s2p_fifo_dato_int		: std_logic_vector(31 downto 0);
signal	dma_access			: std_logic;
signal	s2p_fifo_rdreq			: std_logic;
signal	p2s_fifo_flush			: std_logic;
signal	s2p_fifo_full			: std_logic;
signal	p2s_fifo_empty_int		: std_logic;
signal	lt_disc				: std_logic;
signal	local_irq			: std_logic;
signal	targ_disc			: std_logic;	
signal	targ_disc_reg			: std_logic;
signal	targ_disc_rise			: std_logic;
signal	targ_retry			: std_logic;
signal	targ_retry_reg			: std_logic;
signal	targ_retry_rise			: std_logic;
signal	timer_expired			: std_logic;
signal	timer_expire_reg		: std_logic;
signal	timer_expire_rise		: std_logic;
signal	data_phase_reg			: std_logic;
signal	data_phase_fall			: std_logic;
signal	bcr_zero			: std_logic;
signal	lm_last_reg			: std_logic;
signal  l_adro_reg                      : std_logic_vector(25 downto 0);
signal  lt_framen_reg                   : std_logic;
signal  lt_framen_fall                  : std_logic;
signal  targ_p2s_fifo_wrreq             : std_logic;
signal  s2p_fifo_underflow              : std_logic;
signal  s2p_fifo_underflow_reg          : std_logic;
signal  s2p_fifo_underflow_rise         : std_logic;
signal  s2p_fifo_almost_empty           : std_logic;
signal  bcr_lte_3                       : std_logic;
signal  xfr_cntr                        : std_logic_vector(5 downto 0);
signal  stop_dma                        : std_logic;
signal  s2p_fifo_empty_reg              : std_logic;
signal  s2p_fifo_empty_fall             : std_logic;
signal  s2p_fifo_empty_fall_sr          : std_logic;
signal  s2pfifoempty_sr_reg             : std_logic;
signal  fifo_pre_read                   : std_logic;



begin
	
  ad_loaded_reg <= isr(4);
  
  tw_cmd <= '1' when l_cmdo = "0111"
	else '0';
	
  tr_cmd <= '1' when l_cmdo = "0110"
  	else '0';
  	
  p2s_fifo_empty <= p2s_fifo_empty_int;
 

	
  process(clk, rstn)		-- SRFF
    begin
      if(rstn='0') then
        local_busy <= '0';
      elsif(clk'event and clk='1') then
        if(local_start='1') then	-- set when local_start
          local_busy <= '1';
        elsif(sdram_end_txfr='1') then
          local_busy <= '0';		-- reset when sdram controller signal end of sdram access
        end if;
      end if;
  end process;
  

 
          s2p_fifo_dato_int <= s2p_fifo_dato(31 downto 0);
   
  
  -- mux to select between dma register output and the sdram-to-pci fifo
  process(dma_dato, s2p_fifo_dato_int,  dma_rd_reg)		-- low dword mux
    begin
      case dma_rd_reg is
        when '1' 	=>
          dati <= dma_dato(31 downto 0);
        when others	=>
          dati <= s2p_fifo_dato_int;
        end case;
      end process;
      
  
  
  -- generate the mux select signal for dma_dato/s2p_fifo_dato mux
  
process(clk,rstn) 
  begin
    if(rstn='0') then
      dma_rd_reg <= '0';
    elsif(clk'event and clk='1') then
      dma_rd_reg <= dma_access and tr_cmd;
    end if;
  end process;
  

-- mux the address and data 
process(lm_tsr, dati, acr)	
    begin
      case lm_tsr(1) is
        when '1' 	=>			-- address selected (acr)
          l_adi(31 downto 0) <= acr;
        when others	=>
          l_adi(31 downto 0) <= dati;
        end case;
end process;  

process(lm_tsr, csr)	
    begin
      case lm_tsr(1) is
        when '1' 	=>			-- select command
          l_cbeni(3 downto 0) <= "011" & csr(3);
        when others	=>
          l_cbeni(3 downto 0) <= (others => '0');
        end case;
end process; 


-- assign lt_rdyn
lt_rdyn <= (not lt_rdy);

-- assign request signals
lm_req32n <= not lm_req;


-- assign lm_rdyn
lm_rdyn <= not lm_rdy;

-- assign lm_lastn
lm_lastn <= not (lm_last or s2p_fifo_underflow_rise);
bcr_lte_3 <= '1' when (bcr <= 3) else '0';
s2p_fifo_almost_empty <= '1' when (xfr_cntr = "111111") else '0';
s2p_fifo_underflow <= s2p_fifo_almost_empty and lm_tsr(3);

 process(clk, rstn)
             begin
               if(rstn='0') then
                 xfr_cntr    <= (others => '0'); 
               elsif(clk'event and clk='1') then  
                   if(local_start='1') then
                     xfr_cntr <= (others => '0');      
                   elsif(bcr_cnten = '1') then
                     xfr_cntr <= xfr_cntr + 1;
                   end if;
               end if;
             end process;


process(clk,rstn)
begin
 if(rstn='0') then
   s2p_fifo_underflow_reg <= '0';
 elsif (clk'event and clk='1') then
   s2p_fifo_underflow_reg <= s2p_fifo_underflow;
 end if;
end process;


s2p_fifo_underflow_rise <= s2p_fifo_underflow and not s2p_fifo_underflow_reg;

-- logic to pre-read the first word in the s2p fifo for master write
-- to emulate the show ahead functionality

-- the show ahead read signal is asserted for one clock
-- period when the fifo is coming out of empty for the first
-- time during the current master write / target read access


process(clk,rstn)
begin
 if(rstn = '0') then
   s2p_fifo_empty_reg <= '1';
 elsif(clk'event and clk = '1') then
    s2p_fifo_empty_reg <= s2p_fifo_empty;
 end if;
end process;

s2p_fifo_empty_fall <= s2p_fifo_empty_reg and not s2p_fifo_empty;

process(clk, rstn)
begin
  if(rstn = '0') then
    s2p_fifo_empty_fall_sr <= '0';
  elsif (clk'event and clk = '1') then
    if(s2p_fifo_empty_fall='1') then
      s2p_fifo_empty_fall_sr <= '1';
     elsif(data_phase_fall = '1' or (sdram_end_txfr='1' and  csr(6)='0') ) then
      s2p_fifo_empty_fall_sr <= '0';
    end if;
  end if;
end process;

-- detecting the rising edge of the sr flop
process(clk,rstn)
 begin
   if(rstn = '0') then
     s2pfifoempty_sr_reg <= '0';
   elsif(clk'event and clk = '1') then
     s2pfifoempty_sr_reg <= s2p_fifo_empty_fall_sr;
   end if;
 end process;
 
 fifo_pre_read <= not s2pfifoempty_sr_reg and s2p_fifo_empty_fall_sr;


-- sdram-to-pci fifo read request
s2p_fifo_rdreq <= targ_s2p_fifo_rdreq or mstr_s2p_fifo_rdreq  or fifo_pre_read ;  -- pre-read to emulate show ahead functionality

-- pci-to-sdram fifo write request
p2s_fifo_wrreq <= targ_p2s_fifo_wrreq or mstr_p2s_fifo_wrreq;


-- 

process(clk,rstn) 	-- register the low dword data input to the fifo
  begin
    if(rstn='0') then
      p2s_fifoi <= (others=>'0');
    elsif(clk'event and clk='1') then
      p2s_fifoi <= l_dato(31 downto 0);
    end if;
end process;

-- sdram-to-pci fifo flush
s2p_fifo_flush <= (mw_flush_sel and mw_fifo_flush) or (tr_fifo_flush and not mw_flush_sel); -- muxing mater write and target read flush
mw_flush_sel <= csr(3) and csr(6);	-- master write and dma_on   
lt_discn <= (not lt_disc);
lt_abortn <= '1';



dma0: dma

Port map (
		clk		=>	clk,          	
		rstn          	=>	rstn,
		start		=>	ad_loaded_reg,		-- isr(4)
		dati		=>	l_dato(31 downto 0),
		adr		=>	l_adro_reg(7 downto 0),
		reg_wen		=>	dma_reg_wen,
		fifo_wen	=>	dma_fifo_wen,
		wr_rdn		=>	tw_cmd,
		cs		=>	dma_reg_cs,
		bcr_cnten	=>	bcr_cnten,
		acr_cnten	=>	acr_cnten,
		lar_cnten	=>	lar_cnten,
		p2s_fifo_empty	=>	p2s_fifo_empty_int,
		s2p_fifo_usedw	=>	s2p_fifo_usedw,
		mstr_busy	=>	mstr_busy,	-- not used
		stop		=>	stop_dma,
		abort		=>	mstr_abort,		-- not used
		last_xfr	=>	lm_last,
		local_busy	=>	local_busy,	-- srff set when local_start, reset when sdram_end_txfr
		err_pend	=>	err_pend,	-- target abort, parity error, master abort
		lm_tsr		=>	lm_tsr,
		isr_rd		=> 	isr_rd,		
		isr		=>	isr,
		csr		=>	csr,
		bcr		=>	bcr,
		acr		=>	acr,
		lar		=>	lar,
		req		=>	dma_request,
		local_start	=>	local_start,
		dato		=>	dma_dato
		
		
	);
	


targ_cntrl0: targ_cntrl

Port map(
		clk        	=>	clk , 	
		rstn          	=>	rstn,	
		lt_framen	=>	lt_framen,
		lt_dxfrn	=>	lt_dxfrn,
		lt_tsr		=>	lt_tsr,
		adr		=>	l_adro_reg(25 downto 0),
		cmd		=>	l_cmdo(3 downto 0),
		s2p_fifo_usedw	=>	s2p_fifo_usedw,
		p2s_fifo_full   =>      p2s_fifo_full,	
		sdram_end_txfr	=>	sdram_end_txfr,
		retry		=>	lt_disc,
		lt_rdy		=>	lt_rdy,
		targ_rd		=>	targ_rd,
		targ_wr		=>	targ_wr,
		p2s_fifo_wrreq	=>	targ_p2s_fifo_wrreq,
		s2p_fifo_rdreq	=>	targ_s2p_fifo_rdreq,
		dma_reg_cs	=>	dma_reg_cs,
		dma_reg_wen	=>	dma_reg_wen,
		tr_fifo_flush	=> 	tr_fifo_flush,
		dma_fifo_wen	=>	dma_fifo_wen,
		isr_rd		=>	isr_rd
		
		
);

mstr_cntrl0 : mstr_cntrl

Port map (
		clk    		=>	clk,     	
                rstn         	=> 	rstn,
                lm_ackn		=>	lm_ackn,
                lm_dxfrn	=>	lm_dxfrn,
                lm_tsr		=>	lm_tsr,
                p2s_fifo_full	=>	p2s_fifo_full,
                s2p_fifo_usedw	=>	s2p_fifo_usedw,
                byte_cnt	=>	bcr,
                wr_rdn		=>	csr(3),
                dma_req		=>  	dma_request,   	
                stat_reg	=>	stat_reg,
                local_start	=>	local_start,
                lm_req	=>	lm_req,
                lm_rdy		=>	lm_rdy,
                lm_last		=>	lm_last,
                p2s_fifo_wrreq	=>	mstr_p2s_fifo_wrreq,
                s2p_fifo_rdreq	=>     	mstr_s2p_fifo_rdreq,
                busy		=>	mstr_busy,
                stop		=>	mstr_stop,
                err_pend	=>	err_pend,
                abort		=>	mstr_abort,
                bcr_cnten	=>	bcr_cnten,
                acr_cnten	=>	acr_cnten,
                lar_cnten	=>	lar_cnten,
                mw_fifo_flush	=>	mw_fifo_flush
                
);


datapath_fifo0 : datapath_fifo

port map (
		clk      	=>	clk,	    		
		rstn          	=>	rstn,
		p2s_fifoi	=>	p2s_fifoi,
		p2s_fifo_wrreq	=>	p2s_fifo_wrreq,
		p2s_fifo_rdreq	=>	p2s_fifo_rdreq,		-- low and high read signals are the same signal from sdram 
		p2s_fifo_flush	=>	p2s_fifo_flush,
		s2p_fifo_dati	=>	s2p_fifo_dati,
		s2p_fifo_wrreq	=>	s2p_fifo_wrreq,
		s2p_fifo_rdreq	=>	s2p_fifo_rdreq,	
		s2p_fifo_flush	=>	s2p_fifo_flush,
		p2s_fifo_out	=>	p2s_fifo_dato,
		p2s_fifo_full	=>	p2s_fifo_full,
		p2s_fifo_empty	=>	p2s_fifo_empty_int,
		p2s_fifo_usedw	=>	p2s_fifo_usedw,
		s2p_fifo_dato	=>	s2p_fifo_dato,
		s2p_fifo_usedw	=>	s2p_fifo_usedw,
		s2p_fifo_full	=>	s2p_fifo_full,
		s2p_fifo_empty	=>	s2p_fifo_empty
                        
		
		
);


                
process(clk,rstn)
begin
  if(rstn='0') then
    lt_framen_reg <= '0';
  elsif(clk'event and clk='1') then
    lt_framen_reg <= lt_framen;
  end if;
end process;

lt_framen_fall <= not lt_framen and lt_framen_reg;


bcr_zero <= '1' when (bcr = 0)
  		else '0';
timer_expired <= lm_tsr(4) and not bcr_zero and lm_ackn and csr(6);
targ_disc <= lm_tsr(6) or lm_tsr(7);
targ_retry <= lm_tsr(5);

-- registered signals for edge detection
process(clk, rstn)
  begin
    if(rstn='0') then
      timer_expire_reg <= '0';
      targ_retry_reg <= '0';
      targ_disc_reg <= '0';
      data_phase_reg <= '0';
    elsif(clk'event and clk='1') then
      timer_expire_reg <= timer_expired;
      targ_retry_reg <= targ_retry;
      targ_disc_reg <= targ_disc;
      data_phase_reg <= lm_tsr(3);
    end if;
  end process;
  
  -- edge detection
  data_phase_fall <= data_phase_reg and not lm_tsr(3);
  targ_retry_rise <= not targ_retry_reg and targ_retry;
  targ_disc_rise <= not targ_disc_reg and targ_disc;
  timer_expire_rise <= not timer_expire_reg and timer_expired;
  -- lm_last latched
  process(clk, rstn)		-- SRFF
    begin
      if(rstn='0') then
        lm_last_reg <= '0';
      elsif(clk'event and clk='1') then
        if(lm_last='1') then	-- set when local_start
          lm_last_reg <= '1';
        elsif(dma_request='1') then
          lm_last_reg <= '0';		-- reset when sdram controller signal end of sdram access
        end if;
      end if;
  end process;


-- register l_adro[25..0]
 process(clk, rstn)		-- SRFF
    begin
      if(rstn='0') then
        l_adro_reg <= (others => '0');
      elsif(clk'event and clk='0') then
        l_adro_reg <= l_adro(25 downto 0);
      end if;
  end process;

sdram_trigger <= local_start;
sdram_cfg_dat <= l_dato(31 downto 0);
sdram_adr <= l_adro_reg(25 downto 0);
bar0_hit <= lt_tsr(0);
bar1_hit <= lt_tsr(1);
dma_access <= lt_tsr(0) and not l_adro_reg(19);
lar_reg <= lar;
bcr_reg <= bcr;
csr_reg <= csr;
local_irq <= isr(1) or (isr(3) and not csr(5));
lirqn <= not local_irq; 

stop_dma <= mstr_stop or s2p_fifo_underflow_rise; 
abrt_wr_wod <=  targ_retry_rise and not csr(3) ;
abrt_wr <= ((timer_expire_rise or targ_disc_rise) and not csr(3))
           or (lm_last_reg and not bcr_zero and data_phase_fall) ;  -- lm_last got asserted but there is more data to be transferred;
           
abrt_rd <= ((timer_expire_rise or targ_disc_rise or targ_retry_rise) and csr(3))
           or (lm_last_reg and not bcr_zero and data_phase_fall)   -- lm_last got asserted but there is more data to be transferred
           or s2p_fifo_underflow_rise;
 

p2s_fifo_flush <= '0';


end rtl;






































