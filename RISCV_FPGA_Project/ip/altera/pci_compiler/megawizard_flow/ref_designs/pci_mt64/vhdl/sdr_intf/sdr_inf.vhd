
--  pci_mt64 Reference Design
--  MODULE NAME: sdr_inf
--  COMPANY:  Altera Coporation.
--            www.altera.com    

--  FUNCTIONAL DESCRIPTION:
--  This is the Top file which instantiates all the files used 
-- ** in this design.

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
 
 
entity sdr_inf is
  port (
        clk : in STD_LOGIC;
        reset_n : in STD_LOGIC;
        cmdack : in STD_LOGIC;
        cmd : out STD_LOGIC_VECTOR (2 downto 0);
        addr : out STD_LOGIC_VECTOR (25 downto 0);
        dmn : out STD_LOGIC_VECTOR (7 downto 0);
        target_write : in STD_LOGIC;
        target_read : in STD_LOGIC;
        abort_wr : in STD_LOGIC;
        abort_wr_wod : in STD_LOGIC;
        abort_rd : in STD_LOGIC;
        dma_req_sdram : in STD_LOGIC;
        dma_csr : in STD_LOGIC_VECTOR (8 downto 0);
        dma_bcr : in STD_LOGIC_VECTOR (16 downto 0);
        dma_lar : in STD_LOGIC_VECTOR (25 downto 0);
        pci_fifo_emptyn : in STD_LOGIC;
        ben : in STD_LOGIC_VECTOR (7 downto 0);
        s_adri : in STD_LOGIC_VECTOR (25 downto 0);
        bar0_hit : in STD_LOGIC;
        bar1_hit : in STD_LOGIC;
        rdusedw : in STD_LOGIC_VECTOR (6 downto 0);
        rd_req : out STD_LOGIC;
        wr_req : out STD_LOGIC;
        probe_top : out STD_LOGIC_VECTOR (7 downto 0);
        end_sdram_txfr : out STD_LOGIC
        );
end sdr_inf;
 

 
architecture sdr_inf of sdr_inf is
  signal visual_0_addr : STD_LOGIC_VECTOR(25 downto 0 );--    ----- created for output, which is read or nets with declaration delay .
  signal visual_0_rd_req : STD_LOGIC;--    ----- created for output, which is read or nets with declaration delay .
  signal visual_0_wr_req : STD_LOGIC;--    ----- created for output, which is read or nets with declaration delay .
  signal visual_0_end_sdram_txfr : STD_LOGIC;--    ----- created for output, which is read or nets with declaration delay .
 
 
  component addr_cntr
      port (
            clk : in STD_LOGIC := 'Z';
            reset_n : in STD_LOGIC := 'Z';
            load_reg_data : in STD_LOGIC_VECTOR (15 downto 0) := "ZZZZZZZZZZZZZZZZ";
            bar0_hit : in STD_LOGIC := 'Z';
            bar1_hit : in STD_LOGIC := 'Z';
            target_write : in STD_LOGIC := 'Z';
            dma_req_sdram : in STD_LOGIC := 'Z';
            dma_bcr : in STD_LOGIC_VECTOR (16 downto 0) := "ZZZZZZZZZZZZZZZZZ";
            dma_on_bit : in STD_LOGIC := 'Z';
            tr_mw_sm : in STD_LOGIC_VECTOR (4 downto 0) := "ZZZZZ";
            tw_mr_sm : in STD_LOGIC_VECTOR (4 downto 0) := "ZZZZZ";
            s_adri : in STD_LOGIC_VECTOR (25 downto 0) := "ZZZZZZZZZZZZZZZZZZZZZZZZZZ";
            dma_lar : in STD_LOGIC_VECTOR (25 downto 0) := "ZZZZZZZZZZZZZZZZZZZZZZZZZZ";
            target_read : in STD_LOGIC := 'Z';
            cmdack : in STD_LOGIC := 'Z';
            data_cntr_zero : in STD_LOGIC := 'Z';
            rd_wr_ctrl_cntr_7 : in STD_LOGIC := 'Z';
            rd_req : in STD_LOGIC := 'Z';
            wr_req : in STD_LOGIC := 'Z';
            dis_monitor_sig : in STD_LOGIC := 'Z';
            addr : out STD_LOGIC_VECTOR(25 downto 0 );
            addr_monitor_7 : out STD_LOGIC := 'Z';
            addr_monitor_6 : out STD_LOGIC := 'Z';
            low_addr_not_zero : out STD_LOGIC;
            ld_addr_monitor : out STD_LOGIC;
            low_addr_7 : out STD_LOGIC;
            data_cntr : out STD_LOGIC_VECTOR(13 downto 0 )
            );
  end component;
  component cmd_sm
      port (
            clk : in STD_LOGIC := 'Z';
            reset_n : in STD_LOGIC := 'Z';
            bar0_hit : in STD_LOGIC := 'Z';
            tw_mr_cmd_req : in STD_LOGIC := 'Z';
            tr_mw_cmd_req : in STD_LOGIC := 'Z';
            s_adri : in STD_LOGIC_VECTOR (25 downto 0) := "ZZZZZZZZZZZZZZZZZZZZZZZZZZ";
            cmdack : in STD_LOGIC := 'Z';
            cmd : out STD_LOGIC_VECTOR(2 downto 0 )
            );
  end component;
  component ctrl_logic
      port (
            clk : in STD_LOGIC := 'Z';
            reset_n : in STD_LOGIC := 'Z';
            tr_mw_sm : in STD_LOGIC_VECTOR (4 downto 0) := "ZZZZZ";
            tw_mr_sm : in STD_LOGIC_VECTOR (4 downto 0) := "ZZZZZ";
            cmdack : in STD_LOGIC := 'Z';
            load_fifodata : in STD_LOGIC := 'Z';
            rdusedw_dec0 : in STD_LOGIC := 'Z';
            ben : in STD_LOGIC_VECTOR (7 downto 0) := "ZZZZZZZZ";
            rdusedw : in STD_LOGIC_VECTOR (6 downto 0) := "ZZZZZZZ";
            rdusedw_zero : in STD_LOGIC := 'Z';
            end_sdram_txfr : in STD_LOGIC := 'Z';
            dma_on_bit : in STD_LOGIC := 'Z';
            data_cntr_zero : in STD_LOGIC := 'Z';
            tr_mw_cmd_req : in STD_LOGIC := 'Z';
            addr_monitor_7 : in STD_LOGIC := 'Z';
            addr_monitor_6 : in STD_LOGIC := 'Z';
            low_addr_7 : in STD_LOGIC := 'Z';
            low_addr_not_zero : in STD_LOGIC := 'Z';
            ld_addr_monitor : in STD_LOGIC := 'Z';
            addr : in STD_LOGIC_VECTOR (25 downto 0) := "ZZZZZZZZZZZZZZZZZZZZZZZZZZ";
            rd_wr_ctrl_cntr : out STD_LOGIC_VECTOR (2 downto 0) := "ZZZ";
            rd_wr_ctrl_cntr_7 : out STD_LOGIC;
            rd_req : out STD_LOGIC;
            wr_req : out STD_LOGIC := 'Z';
            dmn : out STD_LOGIC_VECTOR(7 downto 0 )
            );
  end component;
  component tw_mr_sm
      port (
            clk : in STD_LOGIC := 'Z';
            reset_n : in STD_LOGIC := 'Z';
            target_write : in STD_LOGIC := 'Z';
            ext_bcr_zero : in STD_LOGIC := 'Z';
            bar1_hit : in STD_LOGIC := 'Z';
            rdusedw : in STD_LOGIC_VECTOR (6 downto 0) := "ZZZZZZZ";
            cmdack : in STD_LOGIC := 'Z';
            rd_wr_ctrl_cntr_7 : in STD_LOGIC := 'Z';
            pci_fifo_emptyn : in STD_LOGIC := 'Z';
            dma_req_sdram : in STD_LOGIC := 'Z';
            abort_wr : in STD_LOGIC := 'Z';
            abort_wr_wod : in STD_LOGIC := 'Z';
            dma_on_bit : in STD_LOGIC := 'Z';
            dma_csr : in STD_LOGIC_VECTOR (8 downto 0) := "ZZZZZZZZZ";
            data_cntr_upper_zero : in STD_LOGIC := 'Z';
            end_sdram_txfr : in STD_LOGIC := 'Z';
            low_addr_not_zero : in STD_LOGIC := 'Z';
            tw_mr_sm : out STD_LOGIC_VECTOR(4 downto 0 );
            tw_mr_cmd_req : out STD_LOGIC;
            rdusedw_dec0 : out STD_LOGIC;
            rdusedw_zero : out STD_LOGIC;
            end_of_wrxfr : out STD_LOGIC;
            probe : out STD_LOGIC_VECTOR (7 downto 0) := "ZZZZZZZZ"
            );
  end component;
  component regs
      port (
            bar0_hit : in STD_LOGIC := 'Z';
            s_adri : in STD_LOGIC_VECTOR (7 downto 0) := "ZZZZZZZZ";
            load_reg_data : out STD_LOGIC_VECTOR(15 downto 0 )
            );
  end component;
  component tr_mw_sm
      port (
            clk : in STD_LOGIC := 'Z';
            reset_n : in STD_LOGIC := 'Z';
            target_read : in STD_LOGIC := 'Z';
            bar1_hit : in STD_LOGIC := 'Z';
            cmdack : in STD_LOGIC := 'Z';
            rd_wr_ctrl_cntr : in STD_LOGIC_VECTOR (2 downto 0) := "ZZZ";
            abort_rd : in STD_LOGIC := 'Z';
            dma_req_sdram : in STD_LOGIC := 'Z';
            dma_on_bit : in STD_LOGIC := 'Z';
            data_cntr : in STD_LOGIC_VECTOR (13 downto 0) := "ZZZZZZZZZZZZZZ";
            data_cntr_zero : out STD_LOGIC;
            data_cntr_upper_zero : out STD_LOGIC;
            end_sdram_txfr : in STD_LOGIC := 'Z';
            dma_csr : in STD_LOGIC_VECTOR (8 downto 0) := "ZZZZZZZZZ";
            rd_req : in STD_LOGIC := 'Z';
            wr_req : in STD_LOGIC := 'Z';
            tw_mr_sm : in STD_LOGIC_VECTOR (4 downto 0) := "ZZZZZ";
            tr_mw_sm : out STD_LOGIC_VECTOR(4 downto 0 );
            tr_mw_cmd_req : out STD_LOGIC;
            dis_monitor_sig : out STD_LOGIC;
            abort_rd_lat : out STD_LOGIC;
            end_of_rdxfr : out STD_LOGIC
            );
  end component;
  signal rd_wr_ctrl_cntr_7 : STD_LOGIC ;
    -------implicit signal, created by Visual HDL
  signal low_addr_7 : STD_LOGIC ; -------implicit signal, created by Visual HDL
  signal dis_monitor_sig : STD_LOGIC ;
    -------implicit signal, created by Visual HDL
  signal addr_monitor_7 : STD_LOGIC ;
    -------implicit signal, created by Visual HDL
  signal addr_monitor_6 : STD_LOGIC ;
    -------implicit signal, created by Visual HDL
  signal ld_addr_monitor : STD_LOGIC ;
    -------implicit signal, created by Visual HDL
  signal tw_mr_cmd_req : STD_LOGIC ;
    -------implicit signal, created by Visual HDL
  signal tr_mw_cmd_req : STD_LOGIC ;
    -------implicit signal, created by Visual HDL
  signal rdusedw_dec0 : STD_LOGIC ;
    -------implicit signal, created by Visual HDL
  signal rdusedw_zero : STD_LOGIC ;
    -------implicit signal, created by Visual HDL
  signal visual_0_tr_mw_sm : STD_LOGIC_VECTOR(4 downto 0 );
  signal visual_0_tw_mr_sm : STD_LOGIC_VECTOR(4 downto 0 );
  signal load_reg_data : STD_LOGIC_VECTOR(15 downto 0 );
  signal data_cntr : STD_LOGIC_VECTOR(13 downto 0 );
  signal rd_wr_ctrl_cntr : STD_LOGIC_VECTOR(2 downto 0 );
  signal target_rdwr : STD_LOGIC;
  signal end_of_wrxfr : STD_LOGIC;
  signal end_of_rdxfr : STD_LOGIC;
  signal data_cntr_zero : STD_LOGIC;
  signal abort_rd_lat : STD_LOGIC;
  signal low_addr_not_zero : STD_LOGIC;
  signal data_cntr_upper_zero : STD_LOGIC;
  signal ext_bcr_zero_dec1 : STD_LOGIC;
  signal ext_bcr_zero_dec2 : STD_LOGIC;
  signal ext_bcr_zero_dec3 : STD_LOGIC;
  signal ext_bcr_zero : STD_LOGIC;
  signal dma_on_bit : STD_LOGIC;
begin
 
  end_sdram_txfr <= visual_0_end_sdram_txfr;
  addr <= visual_0_addr;
  rd_req <= visual_0_rd_req;
  wr_req <= visual_0_wr_req;
 
  --  decode signals of external byte count register
  -- /*always @(posedge clk or negedge reset_n)
  -- begin
  --   if (reset_n == 1'b0)
  --     begin
  --       ext_bcr_zero_dec1 <= 1'b0;
  --       ext_bcr_zero_dec2 <= 1'b0;
  --       ext_bcr_zero_dec3 <= 1'b0;
  --     end
  --   else
  --     begin
  --       ext_bcr_zero_dec1 <= ~(dma_bcr[16] | dma_bcr[15] | dma_bcr[14] | dma_bcr[13]);
  --       ext_bcr_zero_dec2 <= ~(dma_bcr[12] | dma_bcr[11] | dma_bcr[10] | dma_bcr[9]);
  --       ext_bcr_zero_dec3 <= ~(dma_bcr[8] | dma_bcr[7] | dma_bcr[6] | dma_bcr[5]);
  --     end
  -- end
  --
  -- always @(posedge clk or negedge reset_n)
  -- begin
  --   if (reset_n == 1'b0)
  --     ext_bcr_zero <= 1'b0;
  --   else if (ext_bcr_zero_dec1 & ext_bcr_zero_dec2 & ext_bcr_zero_dec3 & !dma_bcr[4] & !dma_bcr[3])
  --     ext_bcr_zero <= 1'b1;
  --   else
  --     ext_bcr_zero <= 1'b0;
  -- end*/
  ext_bcr_zero <= '1' when (dma_bcr(16 downto 3) = "00000000000000") else '0';
  process (clk, reset_n)
 
  begin
    if reset_n = '0' then
      dma_on_bit <= '0';
    elsif (clk'event and clk = '1' ) then
      if (dma_req_sdram) = '1'  then
        dma_on_bit <= '1';
      else
        if (visual_0_tr_mw_sm(0)) = '1'  and (visual_0_tw_mr_sm(0)) = '1'  then
          dma_on_bit <= '0';
        end if ;
      end if ;
    end if ;
  end process ;
 
  target_rdwr <= target_write or target_read;
  visual_0_end_sdram_txfr <= end_of_wrxfr or end_of_rdxfr;
 
  addr_cntr1: addr_cntr
    port map (
              clk => clk,
              reset_n => reset_n,
              load_reg_data => load_reg_data,
              bar0_hit => bar0_hit,
              bar1_hit => bar1_hit,
              target_write => target_write,
              target_read => target_read,
              dma_req_sdram => dma_req_sdram,
              dma_bcr => dma_bcr,
              tr_mw_sm => visual_0_tr_mw_sm,
              tw_mr_sm => visual_0_tw_mr_sm,
              dma_on_bit => dma_on_bit,
              s_adri => s_adri,
              dma_lar => dma_lar,
              cmdack => cmdack,
              rd_req => visual_0_rd_req,
              wr_req => visual_0_wr_req,
              data_cntr_zero => data_cntr_zero,
              rd_wr_ctrl_cntr_7 => rd_wr_ctrl_cntr_7,
              low_addr_7 => low_addr_7,
              dis_monitor_sig => dis_monitor_sig,
              addr => visual_0_addr,
              addr_monitor_7 => addr_monitor_7,
              addr_monitor_6 => addr_monitor_6,
              low_addr_not_zero => low_addr_not_zero,
              ld_addr_monitor => ld_addr_monitor,
              data_cntr => data_cntr);
 
  --  inputs
  --  outputs
  cmd_sm1: cmd_sm
    port map (
              clk => clk,
              reset_n => reset_n,
              bar0_hit => bar0_hit,
              s_adri => s_adri,
              cmdack => cmdack,
              tw_mr_cmd_req => tw_mr_cmd_req,
              tr_mw_cmd_req => tr_mw_cmd_req,
              cmd => cmd);
 
  --  inputs
  --  outputs
  ctrl1: ctrl_logic
    port map (
              clk => clk,
              reset_n => reset_n,
              tw_mr_sm => visual_0_tw_mr_sm,
              tr_mw_sm => visual_0_tr_mw_sm,
              cmdack => cmdack,
              load_fifodata => tw_mr_cmd_req,
              ben => ben,
              rd_req => visual_0_rd_req,
              addr => visual_0_addr,
              wr_req => visual_0_wr_req,
              rdusedw_dec0 => rdusedw_dec0,
              rdusedw_zero => rdusedw_zero,
              end_sdram_txfr => visual_0_end_sdram_txfr,
              rdusedw => rdusedw,
              data_cntr_zero => data_cntr_zero,
              dma_on_bit => dma_on_bit,
              tr_mw_cmd_req => tr_mw_cmd_req,
              addr_monitor_7 => addr_monitor_7,
              addr_monitor_6 => addr_monitor_6,
              low_addr_7 => low_addr_7,
              low_addr_not_zero => low_addr_not_zero,
              ld_addr_monitor => ld_addr_monitor,
              rd_wr_ctrl_cntr => rd_wr_ctrl_cntr,
              rd_wr_ctrl_cntr_7 => rd_wr_ctrl_cntr_7,
              dmn => dmn);
 
  --  inputs
  --  outputs
  tw_mr_sm1: tw_mr_sm
    port map (
              clk => clk,
              reset_n => reset_n,
              target_write => target_write,
              ext_bcr_zero => ext_bcr_zero,
              data_cntr_upper_zero => data_cntr_upper_zero,
              bar1_hit => bar1_hit,
              rdusedw => rdusedw,
              cmdack => cmdack,
              rd_wr_ctrl_cntr_7 => rd_wr_ctrl_cntr_7,
              pci_fifo_emptyn => pci_fifo_emptyn,
              dma_req_sdram => dma_req_sdram,
              rdusedw_zero => rdusedw_zero,
              end_sdram_txfr => visual_0_end_sdram_txfr,
              abort_wr => abort_wr,
              dma_on_bit => dma_on_bit,
              low_addr_not_zero => low_addr_not_zero,
              dma_csr => dma_csr,
              tw_mr_sm => visual_0_tw_mr_sm,
              tw_mr_cmd_req => tw_mr_cmd_req,
              rdusedw_dec0 => rdusedw_dec0,
              end_of_wrxfr => end_of_wrxfr,
              abort_wr_wod => abort_wr_wod,
              probe => probe_top);
 
  --  inputs
  --              .rd_req(rd_req),
  --  outputs
  regs1: regs
                           --  inputs
    port map (
              bar0_hit => bar0_hit,
              s_adri => s_adri(7 downto 0),
              load_reg_data => load_reg_data);
 
  --  outputs
  tr_mw_sm1: tr_mw_sm
    port map (
              clk => clk,
              reset_n => reset_n,
              target_read => target_read,
              bar1_hit => bar1_hit,
              cmdack => cmdack,
              rd_wr_ctrl_cntr => rd_wr_ctrl_cntr,
              dma_req_sdram => dma_req_sdram,
              data_cntr_zero => data_cntr_zero,
              data_cntr_upper_zero => data_cntr_upper_zero,
              data_cntr => data_cntr,
              abort_rd => abort_rd,
              abort_rd_lat => abort_rd_lat,
              end_sdram_txfr => visual_0_end_sdram_txfr,
              rd_req => visual_0_rd_req,
              wr_req => visual_0_wr_req,
              dma_on_bit => dma_on_bit,
              dma_csr => dma_csr,
              tw_mr_sm => visual_0_tw_mr_sm,
              tr_mw_sm => visual_0_tr_mw_sm,
              tr_mw_cmd_req => tr_mw_cmd_req,
              dis_monitor_sig => dis_monitor_sig,
              end_of_rdxfr => end_of_rdxfr);
  --  inputs
  --  outputs
 
end ;

