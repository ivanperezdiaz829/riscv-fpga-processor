// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.



//--------------------------------------------------------------------------------
// Initialization
//--------------------------------------------------------------------------------
task reset_tx;
begin
  tx_rst = 1'b1;
  tx_phy_mgmt_clk_rst = 1'b1;
  //tx_rst_smpte372 = 1'b1;
  repeat (20) @(negedge tx_ref_clk);
  tx_rst = 1'b0;
  tx_phy_mgmt_clk_rst = 1'b0;
  repeat (5) @(negedge tx_ref_clk);
  //tx_rst_smpte372 = 1'b0;
end
endtask

task reset_tx_long;
begin
  tx_rst = 1'b1;
  tx_phy_mgmt_clk_rst = 1'b1;
  //tx_rst_smpte372 = 1'b1;
  repeat (500) @(negedge tx_ref_clk);
  tx_rst = 1'b0;
  tx_phy_mgmt_clk_rst = 1'b0;
  //tx_rst_smpte372 = 1'b0;
end
endtask

task reset_rx;
begin
  rx_rst = 1'b1;
  rx_phy_mgmt_clk_rst = 1'b1;
  rx_rst_smpte372 = 1'b1;
  repeat (20) @(negedge rx_ref_clk);
  rx_rst = 1'b0;
  rx_phy_mgmt_clk_rst = 1'b0;
  rx_rst_smpte372 = 1'b0;
end
endtask

task reset_rxchker;
begin
  rx_chk_rst = 1'b1;
  repeat (20) @(negedge rx_ref_clk);
  rx_chk_rst = 1'b0;
end
endtask

task reset_reconfig;
begin
  t_recon_rst = 1'b1;
  repeat (20) @(negedge reconfig_clk);
  t_recon_rst = 1'b0;
end
endtask

task initialize;
begin
  reset_rxchker();
  if (rst_recon_test) reset_reconfig();
  reset_rx();  
  reset_tx();
  tx_chk_start_chk = 2'b00;
  rx_chk_start_chk = 2'b00;
  rx_chk_start_chk_ch0 = 2'b00;
  dead_data = 1'b0;
  dead_data_b = 1'b0;
  delaydata(0, 0, 2'b00);
  disturb_bit = 1'b0;
  disturb_eav = 1'b0;
  disturb_sav = 1'b0;
  disturb_v = 1'b0;
  t_disturb_after_sav = 1'b0;
  t_disturb_after_eav = 1'b0;
  tx_pll_sel_task = 1'b0;
  tx_start_reconfig_task = 1'b0;  
  gate_tx_refclk = 1'b0;
  gate_tx_refclk_alt = 1'b0;
  gate_rx_refclk = 1'b0;
end
endtask

//--------------------------------------------------------------------------------
// Transmit desired video standard
//--------------------------------------------------------------------------------
task transmit_3G;
  input [3:0]   i_tx_format;
  input [3*8:0] i_3g_std;
  input [2*8:0] i_dl_mapping;  
begin
  tx_format = i_tx_format; 
  // enable_3gb = i_enable_3gb;
  tx_std = (i_3g_std == "3GB") ? 2'b10 : 2'b11;
  dl_mapping = (i_dl_mapping == "DL") ? 1'b1 : 1'b0;
  if (multi_recon) rx_check_multi();
  else             rx_check();
  if (reset_test) begin
    reset_seq_test();
  end
end 
endtask 

task transmit_HD;
  input [3:0]   i_tx_format;
  input [2*8:0] i_dl_mapping;
  begin
  tx_format = i_tx_format;
  // enable_3gb = 1'b0;
  tx_std = 2'b01;
  dl_mapping = (i_dl_mapping == "DL") ? 1'b1 : 1'b0;
  if (multi_recon) rx_check_multi();
  else             rx_check();
  if (reset_test) begin
    reset_seq_test();
  end
  end
endtask

task transmit_SD;
  input [3:0]   i_tx_format;
  begin
  tx_format = i_tx_format;
  // enable_3gb = 1'b0;
  tx_std = 2'b00;
  dl_mapping = 1'b0;
  if (multi_recon) rx_check_multi();
  else             rx_check();
  if (reset_test) begin
    reset_seq_test();
  end
  end
endtask

task transmit_HD_recon;
  input [3:0]   i_tx_format;
  input [2*8:0] i_dl_mapping;
  begin
  tx_format = i_tx_format;
  tx_std = 2'b01;
  dl_mapping = (i_dl_mapping == "DL") ? 1'b1 : 1'b0;
end
endtask

task transmit_3G_recon;
  input [3:0]   i_tx_format;
  input [3*8:0] i_3g_std;
  input [2*8:0] i_dl_mapping;  
begin
  tx_format = i_tx_format; 
  tx_std = (i_3g_std == "3GB") ? 2'b10 : 2'b11;
  dl_mapping = (i_dl_mapping == "DL") ? 1'b1 : 1'b0;
end 
endtask

//--------------------------------------------------------------------------------
// Check rx_checker status
//--------------------------------------------------------------------------------
task rx_check;
begin
  
  if(rst_recon_test) begin
    if (~is_first_recon) begin
      if (rst_recon_pre_ow) begin
        @ (posedge pre_mcounter_ow);
        $display ("Resetting core before overwritting m counter...");
        reset_rx();
      end else begin
        @ (posedge post_mcounter_ow);
        $display ("Resetting core after overwritting m counter...");
        reset_rx();
      end
    end 
  end
  
  @(posedge rx_chk_done[1]);
  tx_chk_start_chk = 2'b01;
  @(negedge rx_chk_done[1]);
  rx_chk_start_chk = 2'b01;
  if (txpll_test) tx_pll_test_states();
  if (txpll_recon_test) tx_pll_recon_test_states();
  if (trs_test) trstest_states();
  if (frame_test) frametest_states();
  if (dl_sync) hddlsync_states();
  if (disturb_serial) begin
    waitforchecker_proceed();
    t_disturb_after_eav = 1'b1;
    waitforchecker_proceed();
    t_disturb_after_eav = 1'b0;
    t_disturb_after_sav = 1'b1;
  end
  @(posedge rx_chk_done[1]);
  t_disturb_after_sav = 1'b0;
  tx_chk_start_chk = 2'b00;
  rx_chk_start_chk = 2'b00;
end
endtask

task rx_check_multi;
begin
  @(posedge rx_chk_done[1] or posedge rx_chk_done_ch0[1]);
  if (rx_chk_done[1]) begin
    if (~rx_chk_done_ch0[1]) @(posedge  rx_chk_done_ch0[1]);
    tx_chk_start_chk = 2'b01; 
  end else if (rx_chk_done_ch0[1]) begin 
    if (~rx_chk_done[1]) @(posedge  rx_chk_done[1]);
    tx_chk_start_chk = 2'b01;
  end   
 
  @(negedge rx_chk_done[1] or negedge rx_chk_done_ch0[1]);
  if (rx_chk_done[1]) @(negedge rx_chk_done[1]);  
  else if (rx_chk_done_ch0[1]) @(negedge rx_chk_done_ch0[1]); 
  rx_chk_start_chk     = 2'b01;
  rx_chk_start_chk_ch0 = 2'b01;  

  if (disturb_serial) begin
    @(posedge rx_chk_done[1] or posedge rx_chk_done_ch0[1]);
    @(negedge rx_chk_done[1] or negedge rx_chk_done_ch0[1]);
    t_disturb_after_eav = 1'b1;
    @(posedge rx_chk_done[1] or posedge rx_chk_done_ch0[1]);
    @(negedge rx_chk_done[1] or negedge rx_chk_done_ch0[1]);
    t_disturb_after_eav = 1'b0;
    t_disturb_after_sav = 1'b1;
  end

  @(posedge rx_chk_done[1] or  posedge rx_chk_done_ch0[1]);
  t_disturb_after_sav = 1'b0;
  rx_chk_start_chk = 2'b00;
  if (~rx_chk_done_ch0[1]) @(posedge rx_chk_done_ch0[1]);  
  rx_chk_start_chk_ch0 = 2'b00;
  tx_chk_start_chk = 2'b00;
end
endtask

//--------------------------------------------------------------------------------
// HD Dual Link Sync Tasks
//--------------------------------------------------------------------------------
task delaydata;
  input i_dlylinka;
  input i_dlylinkb;
  input [1:0] i_dlycycle;
begin
  enable_dly = i_dlylinka;
  enable_dly_b = i_dlylinkb;
  dly_cycle = i_dlycycle;
end
endtask

task hddlsync_states;
begin
//-----------------------------------------------------------------------
// State 1 : Transmit delayed and non-delayed data in either link
//-----------------------------------------------------------------------
  delaydata(1,0,2'b11);
  $display("Transmitting delayed data in link A.");
  waitforchecker_proceed();
  delaydata(0,0,2'b11);
  $display("Transmitting non-delayed data in link A.");
  waitforchecker_proceed();
  delaydata(0,1,2'b11);
  $display("Transmitting delayed data in link B.");
  waitforchecker_proceed();
  delaydata(0,0,2'b11);
  $display("Transmitting non-delayed data in link B.");
  waitforchecker_proceed();
//---------------------------------------------------------------------------------
// State 2 : Unplug either link and recover with delayed data within a single line
//---------------------------------------------------------------------------------
  dead_data_b = 1'b1;
  $display("Link B is unplugged.");
  waitforchecker_proceed();
  dead_data_b = 1'b0;
  delaydata(0,1,2'b11);
  $display("Link B is recovered with delayed data.");
  waitforchecker_proceed();
  delaydata(0,0,2'b11);
  dead_data = 1'b1;
  $display("Link A is unplugged.");
  waitforchecker_proceed();
  dead_data = 1'b0;
  delaydata(1,0,2'b11);
  $display("Link A is recovered with delayed data.");
  waitforchecker_proceed();
//-----------------------------------------------------------------------
// State 3 : Unplug either link and recover with delayed data after 3 us
//-----------------------------------------------------------------------
  dead_data_b = 1'b1;
  $display("Link B is unplugged.");
  waitforchecker_proceed();
  dead_data_b = 1'b0;
  delaydata(0,1,2'b11);
  $display("Link B is recovered with delayed data.");
  waitforchecker_proceed();
  delaydata(0,0,2'b11);
  dead_data = 1'b1;
  $display("Link A is unplugged.");
  waitforchecker_proceed();
  dead_data = 1'b0;
  delaydata(1,0,2'b11);
  $display("Link A is recovered with delayed data.");
  waitforchecker_proceed();
//--------------------------------------------------------------------------------------------
// State 3 : Transmit delayed data until FIFO used for hd dual link sync is overflowed
//---------------------------------------------------------------------------------------------
  repeat (2) begin
    delaydata(0,0,2'b11);
    $display("Transmitting non-delayed data in link A.");
    waitforchecker_proceed();
    delaydata(0,1,2'b11);
    $display("Transmitting delayed data in link B.");
    waitforchecker_proceed();
  end
  repeat (2) begin
    delaydata(0,0,2'b11);
    $display("Transmitting non-delayed data in link B.");
    waitforchecker_proceed();
    delaydata(1,0,2'b11);
    $display("Transmitting delayed data in link A.");
    waitforchecker_proceed();
  end
end
endtask

//--------------------------------------------------------------------------------
// Tx PLL Select 
//--------------------------------------------------------------------------------

task tx_pll_test_states;
begin
//--------------------------------------------------
// State 1: Switch from TX_PLL_SEL 0 To TX_PLL_SEL 1
//--------------------------------------------------
waitforchecker_proceed();
$display("Start of TX PLL Select Test");
tx_start_reconfig_task = 1'b1;
tx_pll_sel_task = 1'b1;
$display("State 1: Switch from TX_PLL_SEL 0 To TX_PLL_SEL 1 and waiting for tx_reconfig_done to assert...");

if (DIRECTION == "tx") begin 
  gate_tx_refclk = 1'b1;
  $display("Gate Off tx_refclk");
end

waitforchecker_proceed();
$display("Reconfig Done and Set Reconfig To Low");
tx_start_reconfig_task = 1'b0;
$display("Reset Tx");
reset_tx();

if (DIRECTION == "tx") begin 
  reset_rx();
  $display("Waiting for trs_locked to assert...");
  waitforchecker_proceed();
  $display("trs_locked asserted, ungating rx_refclk");
  gate_tx_refclk = 1'b0;
  $display("State 1 Success: TRS_LOCKED asserted and remain asserted");
end else if (DIRECTION == "du") begin
  $display("Gate Off rx_refclk");
  gate_rx_refclk = 1'b1;
  $display("Checking tx_clkout..");
  tx_clkout_match_posedge();
  $display("tx_clkout is correct, ungating rx_refclk and reset rx");
  gate_rx_refclk = 1'b0;
  reset_rx();
  $display("Waiting for trs_locked to assert...");
  waitforchecker_proceed();
  $display("State 1 Success: TRS_LOCKED remain asserted");
end

//--------------------------------------------------
// State 2: Switch from TX_PLL_SEL 1 To TX_PLL_SEL 0
//--------------------------------------------------
waitforchecker_proceed();
tx_start_reconfig_task = 1'b1;
tx_pll_sel_task = 1'b0;
gate_tx_refclk_alt = 1'b1;
$display("State 2: Switch from TX_PLL_SEL 1 To TX_PLL_SEL 0 and waiting for tx_reconfig_done to assert...");
$display("Gate Off tx_refclk_alt");
waitforchecker_proceed();
$display("Reconfig Done and Set Reconfig To Low");
tx_start_reconfig_task = 1'b0;
$display("Resetting ...");
reset_tx();
reset_rx();
$display("Waiting for trs_locked to assert...");
waitforchecker_proceed();
$display("State 2 Success: TRS_LOCKED asserted and remain asserted.");
gate_tx_refclk_alt = 1'b0;
$display("Resetting ...");
reset_tx();
reset_rx();
$display("Waiting for trs_locked to assert...");
//reset_rx();
end
endtask

//--------------------------------------------------------------------------------
// Tx PLL Select Reconfig   
//--------------------------------------------------------------------------------
task tx_pll_recon_test_states;
begin
$display("Start of TX PLL Reconfig Test");
//---------------------------------------------------------------------------------------------------------------------
// State 1: Switch from TX_PLL_SEL 0 To TX_PLL_SEL 1 and Test tx_start_reconfig assert after rx_start_reconfig (3G=>HD)
//---------------------------------------------------------------------------------------------------------------------
$display("State 1: Test tx_start_reconfig assert after rx_start_reconfig");
waitforchecker_proceed();
tx_pll_sel_task = 1'b1;
$display("Set PLL SEL To 1");
if (DIRECTION == "tx") begin 
gate_tx_refclk = 1'b1;
$display("Gate Off tx_refclk");
end
transmit_HD_recon(4'b0101, "--");
$display("Start Transmitting from 3G to HD");
waitforchecker_posedge_proceed();
tx_start_reconfig_task = 1'b1;
$display("tx_start_reconfig set to High and wait for tx_reconfig_done to assert...");
waitforchecker_posedge_proceed();
tx_start_reconfig_task = 1'b0;
$display("TX Reconfig Done and set tx_start_reconfig to LOW");
reset_tx();
$display("Reset TX and now wait for trs_locked to assert...");
if (DIRECTION == "du") begin 
gate_rx_refclk = 1'b1;
$display("Gate Off rx_refclk");
end

if (DIRECTION == "tx") begin 
waitforchecker_proceed();
gate_tx_refclk = 1'b0;
$display("State 1 Success: TRS_LOCKED asserted and remain asserted");
end
else if (DIRECTION == "du") begin
tx_clkout_match_posedge();
gate_rx_refclk = 1'b0;
reset_rx();
$display("PLL_ALT is locked, ungating rx_refclk and reset rx");
waitforchecker_proceed();
$display("State 1 Success: TRS_LOCKED remain asserted");
end

//---------------------------------------------------------------------------------------------------------------------
// State 2: Switch from TX_PLL_SEL 1 To TX_PLL_SEL 0 and Test tx_start_reconfig assert at the same time as rx_start_reconfig (HD=>3G)
//---------------------------------------------------------------------------------------------------------------------
waitforchecker_proceed();
$display("State 2: Test tx_start_reconfig assert same time as rx_start_reconfig");
tx_pll_sel_task = 1'b0;
$display("Set PLL SEL To 0");
gate_tx_refclk_alt = 1'b1;
$display("Gate Off tx_refclk_alt");
transmit_3G_recon(4'b1101, "3GA", "--");
$display("Start Transmitting from HD to 3G");
waitforchecker_posedge_proceed();
tx_start_reconfig_task = 1'b1;
$display("tx_start_reconfig set to High and wait for tx_reconfig_done to assert...");
waitforchecker_posedge_proceed();
tx_start_reconfig_task = 1'b0;
$display("TX Reconfig Done and set tx_start_reconfig to LOW");
reset_tx();
$display("Reset TX and now wait for trs_locked to assert...");
waitforchecker_proceed();
gate_tx_refclk_alt = 1'b0;
$display("State 2 Success: TRS_LOCKED asserted and remain asserted");


//---------------------------------------------------------------------------------------------------------------------
// State 3: Switch from TX_PLL_SEL 0 To TX_PLL_SEL 1 and Test tx_start_reconfig assert before rx_start_reconfig (3G=>HD)
//---------------------------------------------------------------------------------------------------------------------
waitforchecker_proceed();
$display("State 3: Test tx_start_reconfig assert before rx_start_reconfig");
tx_pll_sel_task = 1'b1;
$display("Set PLL SEL To 1");
if (DIRECTION == "tx") begin 
gate_tx_refclk = 1'b1;
$display("Gate Off tx_refclk");
end
transmit_HD_recon(4'b0101, "--");
$display("Start Transmitting from 3G to HD");
waitforchecker_posedge_proceed();
tx_start_reconfig_task = 1'b1;
$display("tx_start_reconfig set to High and wait for tx_reconfig_done to assert...");
waitforchecker_posedge_proceed();
tx_start_reconfig_task = 1'b0;
$display("TX Reconfig Done and set tx_start_reconfig to LOW");
reset_tx();
$display("Reset TX and now wait for trs_locked to assert...");
if (DIRECTION == "du") begin 
gate_rx_refclk = 1'b1;
$display("Gate Off rx_refclk");
end

if (DIRECTION == "tx") begin 
waitforchecker_proceed();
gate_tx_refclk = 1'b0;
$display("State 3 Success: TRS_LOCKED asserted and remain asserted");
end
else if (DIRECTION == "du") begin
tx_clkout_match_posedge();
gate_rx_refclk = 1'b0;
reset_rx();
$display("PLL_ALT is locked, ungating rx_refclk and reset rx");
waitforchecker_proceed();
$display("State 3 Success: TRS_LOCKED asserted and remain asserted");
end

//--------------------------------
// Reset Back to PLL 0 and 3G STD
//--------------------------------
waitforchecker_proceed();
$display("Change PLL back to 0 and Re-transmit 3G Standard");
tx_pll_sel_task = 1'b0;
$display("Set PLL SEL To 0");
tx_start_reconfig_task = 1'b1;
$display("tx_start_reconfig set to High and wait for tx_reconfig_done to assert...");
gate_tx_refclk_alt = 1'b1;
$display("Gate Off tx_refclk_alt");
transmit_3G_recon(4'b1101, "3GA", "--");
$display("Start Transmitting from HD to 3G");
waitforchecker_posedge_proceed();
tx_start_reconfig_task = 1'b0;
$display("TX Reconfig Done and set tx_start_reconfig to LOW");
reset_tx();
$display("Reset TX and now wait for trs_locked to assert...");
waitforchecker_proceed();
gate_tx_refclk_alt = 1'b0;
$display("Success: TRS_LOCKED remain asserted");
end
endtask

//--------------------------------------------------------------------------------
// Rx Format Detect Task
//--------------------------------------------------------------------------------
task trstest_states;
begin
//-----------------------------------------------------------------------------------------------------
// State 1 : Unplug the data link between tx and rx and reconnect with delayed data within single line
//------------------------------------------------------------------------------------------------------
  waitforchecker_proceed();
  $display("Start of TRS locked test.");
  $display("\nState 1: RP168 - Dead data within a single line.");
  dead_data = 1'b1;
  dead_data_b = 1'b1;
  $display("Data link is unplugged...");
  waitforchecker_proceed();
  $display("Recover with delayed data...");
  delaydata(1,1,2'b11);
  dead_data = 1'b0;
  dead_data_b = 1'b0;
  waitforchecker_proceed();

  waitforchecker_proceed();
  dead_data = 1'b1;
  dead_data_b = 1'b1;
  $display("Data link is unplugged...");
  waitforchecker_proceed();
  $display("Recover with non-delayed data...");
  delaydata(0,0,2'b11);
  dead_data = 1'b0;
  dead_data_b = 1'b0;
  waitforchecker_proceed();
//----------------------------------------------------------------------------------------------
// State 2 : Unplug the data link between tx and rx and reconnect with delayed data after 3 us
//----------------------------------------------------------------------------------------------
  waitforchecker_proceed();
  if ( tx_std == 2'b01 ) begin
    $display("\nState 2: RP168 - 6us dead time.");
  end else begin
    $display("\nState 2: RP168 - 3us dead time.");
  end
  dead_data = 1'b1;
  dead_data_b = 1'b1;
  $display("Data link is unplugged...");
  waitforchecker_proceed();
  $display("Recover with delayed data...");
  delaydata(1,1,2'b11);
  dead_data = 1'b0;
  dead_data_b = 1'b0;
  waitforchecker_proceed();

  waitforchecker_proceed();
  dead_data = 1'b1;
  dead_data_b = 1'b1;
  $display("Data link is unplugged...");
  waitforchecker_proceed();
  $display("Recover with non-delayed data...");
  delaydata(0,0,2'b11);
  dead_data = 1'b0;
  dead_data_b = 1'b0;
  //waitforchecker_proceed();

//----------------------------------------------------------------------------------------
// State 3 : Transmit few consecutive lines with missing EAV then SAV 
//----------------------------------------------------------------------------------------
  waitforchecker_proceed();
  $display("\nState 3: Missing EAV/SAV in consecutive lines without exceeding the tolerance level.");  
  $display ("Interrupting bits in EAV for %d times...", err_tolerance[3:0]);
  missing_trs("eav");
  waitforchecker_proceed();
  disturb_eav = 1'b0;
  $display ("Recovering data...");
  waitforchecker_proceed();
  $display ("Interrupting bits in SAV for %d times...", err_tolerance[3:0]);
  missing_trs("sav");
  waitforchecker_proceed();
  disturb_sav = 1'b0;
  $display ("Recovering data...");
//----------------------------------------------------------------------------------------
// State 4 : Continue to pass missing EAV and SAV until err_tolerance is exceeded
//----------------------------------------------------------------------------------------
  waitforchecker_proceed();
  $display("\nState 4: Missing EAV/SAV in consecutive lines exceeding the tolerance level.");  
  $display ("Interrupting bits in both EAV and SAV for %d times...", err_tolerance[3:0] + 1'b1);
  $display ("Trs_locked should be deasserted due to %d missing EAVs", err_tolerance[3:0] + 1'b1);
  missing_trs("sav");
  missing_trs("eav");
  waitforchecker_proceed();
  $display ("Recovering data...");
  disturb_sav = 1'b0;
  disturb_eav = 1'b0;
  waitforchecker_proceed();
  $display ("Interrupting bits in SAV for %d times...", err_tolerance[3:0] + 1'b1);
  missing_trs("sav");
//----------------------------------------------------------------------------------------
// State 5 : Pass missing EAV / SAV or delay / early data to rx when rx is unlocked
//----------------------------------------------------------------------------------------
  waitforchecker_proceed();
  $display ("Recovering data...");
  disturb_sav = 1'b0;
  waitforchecker_proceed();
  repeat (2) begin
    $display ("Missing EAV in every 6 lines");
    missing_trs("eav");
    waitforchecker_proceed();
    disturb_eav = 1'b0;
    $display ("Recovering data...");
    waitforchecker_proceed();
  end
  repeat (2) begin
    $display ("Missing SAV in every 6 lines");
    missing_trs("sav");
    waitforchecker_proceed();
    disturb_sav = 1'b0;
    $display ("Recovering data...");
    waitforchecker_proceed();
  end

  $display ("Transmitting delayed data");
  delaydata(1,1,2'b11);
  waitforchecker_proceed();
  waitforchecker_proceed();
  $display ("Recovering data...");
  delaydata(0,0,2'b11);

  waitforchecker_proceed();
end
endtask

//----------------------------------------------------------------------------------------------------------------------
//This task is only valid for certain tx_format(s) - Tested ( format 1 for SD, format 5 for HD, format 13 for 3G)
//----------------------------------------------------------------------------------------------------------------------
task missing_trs;
input [3*8:0] sel_trs;
begin
  if (sel_trs == "eav") begin
    disturb_eav = 1'b1;
    //disturb_sav = 1'b0;
    case (tx_format) 
      4'b0001 : eavword_count = 740;
      4'b0011 : eavword_count = 1970;
      4'b1100 : eavword_count = 1970;
      4'b1101 : begin
                  if (tx_std == 2'b10) eavword_count = 3950;
                  else eavword_count = 1970;
                end
      default : eavword_count = 1970;
    endcase
  end

  else if (sel_trs == "sav") begin
    disturb_sav = 1'b1;
    //disturb_eav = 1'b0;
    case (tx_format)
      4'b0001 : savword_count = 580;
      4'b0011 : savword_count = 1890;
      4'b1100 : savword_count = 1190;
      4'b1101 : begin
                  if (tx_std == 2'b10) savword_count = 5910;
                  else savword_count = 2950;
                end
      default : savword_count = 2950;
    endcase
  end
end
endtask

task waitforchecker_proceed;
begin
  @(posedge rx_chk_done[1]);
  @(negedge rx_chk_done[1]);
end
endtask

task tx_clkout_match_posedge;
begin
  @(posedge tx_clkout_match);
end
endtask

task waitforchecker_posedge_proceed;
begin
  @(posedge rx_check_posedge);
end
endtask

//--------------------------------------------------------------------------------
// Frame Locked Test Task
//--------------------------------------------------------------------------------
task frametest_states;
begin
//----------------------------------------------------------------------------------------
// State 1 : Unplug the data link between tx and rx and reconnect with delayed data
//----------------------------------------------------------------------------------------
  waitforchecker_proceed();
  dead_data = 1'b1;
  $display("Data link is unplugged...");
  waitforchecker_proceed();
  $display("Recover with delayed data...");
  delaydata(1,0,2'b11);
  dead_data = 1'b0;
  waitforchecker_proceed();

  waitforchecker_proceed();
  dead_data = 1'b1;
  $display("Data link is unplugged...");
  waitforchecker_proceed();
  $display("Recover with non-delayed data...");
  delaydata(0,0,2'b11);
  dead_data = 1'b0;
  waitforchecker_proceed();
  reset_rx();
//----------------------------------------------------------------------------------------
// State 2 : Transmit missing EAV in few lines in a frame to check ERR_TOLERANCE lvl
//----------------------------------------------------------------------------------------
  waitforchecker_proceed();
  repeat (err_tolerance) begin
    $display ("Transmitting data with missing EAV in a frame");
    missing_trs("eav");
    waitforchecker_proceed(); 
    disturb_eav = 1'b0;
    waitforchecker_proceed();
    waitforchecker_proceed();
  end
//-------------------------------------------------------------------------------------------------------------------------------
// State 3 : Transmit missing EAV in few lines in a frame exceeding ERR_TOLERANCE lvl and see whether frame locked is deasserted
//-------------------------------------------------------------------------------------------------------------------------------
    $display ("Continue to pass missing EAV after reaching error tolerance level...");
    missing_trs("eav");
    waitforchecker_proceed();
    disturb_eav = 1'b0;
    waitforchecker_proceed();
    reset_rx();
//----------------------------------------------------------------------------------------
// State 4 : Transmit missing EAV in few lines in a frame when frame_locked is low
//----------------------------------------------------------------------------------------
    waitforchecker_proceed();
    $display ("Missing EAV when frame_locked is deasserted...");
    missing_trs("eav");
    waitforchecker_proceed();
    disturb_eav = 1'b0;
    waitforchecker_proceed();
//----------------------------------------------------------------------------------------
// State 5 : For 3G case, switch from 3GA to 3GB or vice versa
//----------------------------------------------------------------------------------------
    if (tx_std[1]) begin
      reset_rx();
      waitforchecker_proceed();
      // enable_3gb = ~enable_3gb;
      tx_std[0] = ~tx_std[0];
      dl_mapping = ~dl_mapping;
      if (tx_std == 2'b10) $display ("Transmitting 3GB standard...");
      else $display ("Transmitting 3GA standard...");
      //waitforchecker_proceed();
    end
    waitforchecker_proceed();
end
endtask


//-----------------------------------------------------------------------
// Reset Sequence Test
//-----------------------------------------------------------------------
task reset_seq_test;
begin
  $display ("Resetting core first followed by resetting xcvr...");
  rx_rst = 1'b1;
  repeat (20) @(negedge rx_ref_clk);  
  rx_phy_mgmt_clk_rst = 1'b1;
  repeat (20) @(negedge rx_ref_clk);
  rx_rst = 1'b0;
  repeat (20) @(negedge rx_ref_clk);
  rx_phy_mgmt_clk_rst = 1'b0;
  tx_rst = 1'b1;
  repeat (20) @(negedge tx_ref_clk);  
  tx_phy_mgmt_clk_rst = 1'b1;
  repeat (20) @(negedge tx_ref_clk);
  tx_rst = 1'b0;
  repeat (20) @(negedge tx_ref_clk);
  tx_phy_mgmt_clk_rst = 1'b0;  
  rx_check();

  $display ("Resetting xcvr first followed by resetting core...");
  rx_phy_mgmt_clk_rst = 1'b1;
  repeat (20) @(negedge rx_ref_clk);  
  rx_rst = 1'b1;
  repeat (20) @(negedge rx_ref_clk);
  rx_phy_mgmt_clk_rst = 1'b0;
  repeat (20) @(negedge rx_ref_clk);
  rx_rst = 1'b0;
  tx_phy_mgmt_clk_rst = 1'b1;
  repeat (20) @(negedge tx_ref_clk);  
  tx_rst = 1'b1;
  repeat (20) @(negedge tx_ref_clk);
  tx_phy_mgmt_clk_rst = 1'b0;
  repeat (20) @(negedge tx_ref_clk);
  tx_rst = 1'b0;  
  rx_check();
  
end
endtask

//--------------------------------------------------------------------------------
// Print final result
//--------------------------------------------------------------------------------
task printresult;
begin
  #(1);
  tx_chk_start_chk = 2'b10;
  #(1);
  rx_chk_start_chk = 2'b10;
  rx_chk_start_chk_ch0 = 2'b10;
end
endtask 

//--------------------------------------------------------------------------------
// End Simulation
//--------------------------------------------------------------------------------
task complete_sim;
begin
  @(posedge rx_chk_completed or posedge rx_chk_completed_ch0);
  if (~rx_chk_completed) @(posedge rx_chk_completed);
  if (~rx_chk_completed_ch0) @(posedge rx_chk_completed_ch0);
  $stop(0);
end
endtask 



