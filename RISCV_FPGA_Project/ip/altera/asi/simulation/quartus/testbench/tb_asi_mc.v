//--------------------------------------------------------------------------------------------------
// (c)2003 Altera Corporation. All rights reserved.
//
// Altera products are protected under numerous U.S. and foreign patents,
// maskwork rights, copyrights and other intellectual property laws.
//
// This reference design file, and your use thereof, is subject to and governed
// by the terms and conditions of the applicable Altera Reference Design License
// Agreement (either as signed by you or found at www.altera.com).  By using
// this reference design file, you indicate your acceptance of such terms and
// conditions between you and Altera Corporation.  In the event that you do not
// agree with such terms and conditions, you may not use the reference design
// file and please promptly destroy any copies you have made.
//
// This reference design file is being provided on an �as-is� basis and as an
// accommodation and therefore all warranties, representations or guarantees of
// any kind (whether express, implied or statutory) including, without
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or
// require that this reference design file be used in combination with any
// other product not provided by Altera.
//--------------------------------------------------------------------------------------------------
// File          : $RCSfile: tb_asi_mc.v,v $
// Last modified : $Date: 2013/08/11 $
// Export tag    : $Name:  $
//--------------------------------------------------------------------------------------------------
//
// Testbench for ASI reference design
//
// Two instances of the demo are used
// One of the instance is set as a PRBS generator
// and the other one as a loopback from receive to transmit
// Clock frequency shift and random jitter are introduced to show
// show how the ASI receiver can cope
//--------------------------------------------------------------------------------------------------

`timescale 1 ps / 1 ps

module tb_asi_mc ;



reg	refclk = 1'b0;			// Parallel clock : 27Mhz
reg	refclk_source = 1'b0;		// Parallel clock for the ASI source : 27Mhz +/- 100ppm
reg	rst = 1'b1;

wire	asi_test_tx;			// Transmit port of the ASI source
reg	asi_rx;				// Receive port of the unit under test
wire	[7:0]	rx_data;		// Received parallel data of the UUT	
wire   [7:0]  rx_ts_status; // status bits of asi_rx, e.g. start/end of packet etc. 
wire   rxclk;                

reg 	[10:0] random_delay;
reg 	[10:0] random_delay_temp;

parameter   select_packet_gen = 1'b1;
 



wire [7:0] gen_dat;
wire gen_ena;
wire check_error;
   


//--------------------------------------------------------------------------------------------------
// Packet generator, source of test data to ASI tranmitter   
//--------------------------------------------------------------------------------------------------   
   auk_ts_packet_gen u_gen 
     (
      .clk                  (refclk),
      .rst                  (rst),
      .enable               (1'b1),
      .id                   (8'h00),
      .len_188_204n         (1'b1),
      .gap                  (10),                            
      .ts_data              (gen_dat),
      .ts_valid             (gen_ena),
      .ts_start             (),
      .ts_end               ()
      );
   
//--------------------------------------------------------------------------------------------------
// ASI MegaCore transmitter
//--------------------------------------------------------------------------------------------------
      
   wire tx_clk270;
   wire tx_clk27;

      

   pll_x10_top u_tx_pll
     (
      .inclk0   (refclk),
      .areset   (rst),
      .c0       (tx_clk270),
      .c1       (tx_clk27), 
      .locked   ()
      );



   asi_tx_sim u_tx 
     (
	  .rst(rst),
	  .tx_refclk(tx_clk27),
	  .tx_clk270(tx_clk270),
	  .tx_data(gen_dat),
	  .tx_en(gen_ena),
	  .asi_tx(asi_test_tx)
      );

 
//--------------------------------------------------------------------------------------------------
// ASI MegaCore receiver
//--------------------------------------------------------------------------------------------------
   
   wire ts_lock_test;




   wire  sclk_rx;
   wire  sclk90_rx;
   wire  rx_clk135;
   
   
   stratix_c2_pll_sclk u_rx_pll
     (
      .inclk0   (refclk),
      .c0       (sclk_rx),
      .c1       (sclk90_rx),
      .c2       (rx_clk135),
      .locked   (rx_pll_locked)
      );
  
      
   asi_rx u_rx 
     (
      .rst(rst),
      .rx_serial_clk(sclk_rx),
      .rx_serial_clk90(sclk90_rx),
      .rx_clk135(rx_clk135),
      .asi_rx(asi_rx),
      .rx_data(rx_data),
      .rx_ts_status(rx_ts_status),
      .rx_data_clk(rxclk)
      );

  
   assign ts_lock_test = rx_ts_status[5] | rx_ts_status[4];   

//--------------------------------------------------------------------------------------------------
// Packet checker, checks incoming received data.
//--------------------------------------------------------------------------------------------------
   

   auk_ts_packet_check u_check 
     (
      .clk              (rxclk),
      .rst              (rst),
      .ts_valid         (rx_ts_status[0]),
      .ts_data          (rx_data),
      .ts_start         (rx_ts_status[1]),
      .ts_end           (rx_ts_status[2]),
      .ts_lock          (rx_ts_status[5:4]),
      .id               (8'h00),
      .check_id         (1'b0),
      .error            (check_error)
      );
 
 
// Inject random jitter by delaying the ASI serial stream 
always @(asi_test_tx) 
begin
  random_delay_temp = $random;
  if (random_delay_temp> 1220) random_delay = 1220;
  else random_delay = random_delay_temp;
  asi_rx = #(random_delay) asi_test_tx;
end

  
// reference clock period definition
  parameter REFCLK_LO_PERIOD = 37037/2;
  parameter REFCLK_HI_PERIOD = 37037/2;
  
// reference clock period definition for the ASI source : +/-100ppm from a perfect 27Mhz clock
  parameter REFCLK_SRC_LO_PERIOD = 37027/2;
  parameter REFCLK_SRC_HI_PERIOD = 37027/2;
  
// reference clocks
initial begin
  forever begin
    #(REFCLK_LO_PERIOD);
    refclk = 1'b1;
    #(REFCLK_HI_PERIOD);
    refclk = 1'b0;
  end
end
initial begin
#1220;
  forever begin
    #(REFCLK_SRC_LO_PERIOD);
    refclk_source = 1'b1;
    #(REFCLK_SRC_HI_PERIOD);
    refclk_source = 1'b0;
  end
end


//--------------------------------------------------------------------------------------------------
// Check results 
//--------------------------------------------------------------------------------------------------
initial begin

  repeat (1) @(negedge refclk);
  rst = 1'b1; 
  repeat (4) @(negedge refclk);
  rst = 1'b0;
  repeat (1000) @(negedge refclk);
  
  if (~ts_lock_test) 
  begin
    $display("\n**** RECEIVE TEST FAILED! Incorrect word_sync operation ****\n");  
    $stop(0);
  end

  
  repeat (2000) @(negedge refclk);
  
  $display("\n**** RECEIVE TEST COMPLETED SUCCESSFULLY! ****\n");
  $stop(0);
end

always @(refclk)
  if (check_error)
  begin
    $display("\n**** RECEIVE TEST FAILED! Incorrect pattern received ****\n");  
    $stop(0);
  end





endmodule
