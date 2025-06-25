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
// File          : $RCSfile: tb_sdi_megacore_top.v,v $
// Last modified : $Date: 2008/04/17 15:24:39 $
// Export tag    : $Name:  $
//--------------------------------------------------------------------------------------------------
//
// Simple testbench for a triple rate SDI Megacore.
//
// Demonstrate DPRIO (PLL reconfig) by receiving various video streams (ie. HD->3G->SD->HD->SD)
//
//--------------------------------------------------------------------------------------------------


`timescale 100 fs / 100 fs
module tb_sdi_megacore_top (
  );


reg refclk = 1'b0;
reg refclk75 = 1'b0; 
wire sdi_ref75;
  
wire sdi_ref;
reg ref27 = 1'b0;
reg ref67 = 1'b0;   
reg calclk = 1'b0;
wire gxb2_cal_clk;
reg rst = 1'b0;
wire serial_tx;
reg serial_rx = 1'b0;
wire align_locked;
//wire trs_locked;

wire [19:0] gen_data;
wire gen_trs;
wire [10:0] gen_ln;
wire [10:0] rx_status;
wire  tx_status;   
   



//--------------------------------------------------------------------------------------------------
// Clocks.
// The transceiver is configured for 1485Mbps operation with a 74.25MHz reference clock.
// 74.25MHz is equivalent to 13468ps.
// 100fs resolution specified so serial period is an integer
//--------------------------------------------------------------------------------------------------

// Comment out this line if HD1485 simulation required.
//`define hd3g_mode 


parameter CLK148_PERIOD         = 67340;
parameter CLK75_PERIOD          = 134680;
parameter CLK67_PERIOD          = 148148;      
parameter CLK27_PERIOD          = 370370;
parameter CLK50_PERIOD          = 200000;


   parameter REFCLK_PERIOD      = CLK148_PERIOD;   
   parameter RESULT_TRS_COUNT   = 44;
   
parameter SERIAL_PERIOD = REFCLK_PERIOD/20;
   
always #(REFCLK_PERIOD/2) refclk = ~refclk;
assign sdi_ref = refclk;

always #(CLK75_PERIOD/2) refclk75 = ~refclk75;
assign sdi_ref75 = refclk75;

   
   
always #(CLK148_PERIOD/2) calclk = ~calclk;
assign gxb2_cal_clk = calclk;
   

always #(CLK67_PERIOD/2) ref67 = ~ref67;
   wire sdi_ref67;
   assign sdi_ref67 = ref67;

reg ref50 = 1'b0;
wire sdi_ref50;
always #(CLK50_PERIOD/2) ref50 = ~ref50;
   assign sdi_ref50 = ref50;
   
always #(CLK27_PERIOD/2) ref27 = ~ref27;
   wire sdi_reconfig_clk;
   wire sdi_ref27;
   assign sdi_ref27 = ref27;
   assign sdi_reconfig_clk = ref27;
   
   
   


   
//--------------------------------------------------------------------------------------------------
// Reset
//--------------------------------------------------------------------------------------------------
//initial begin
//  repeat (20) @(negedge refclk);
//  rst = 1'b0;
//end

initial begin
 

   repeat (4) @(negedge refclk);
  rst = 1'b1; 
  repeat (8) @(negedge refclk);
  rst = 1'b0;
  repeat (8) @(negedge refclk);
  rst = 1'b1; 
  repeat (8) @(negedge refclk);
  rst = 1'b0; 
   
end

   
reg srst = 1'b0;
initial begin
  repeat (4) @(negedge sdi_reconfig_clk);
  srst = 1'b1; 
  repeat (12) @(negedge sdi_reconfig_clk);
  srst = 1'b0;
end

   reg patt_rst = 1'b1;
   initial begin
      repeat (500) @ (posedge sdi_ref);
      patt_rst = 1'b0;
   end
   
// -----------------------------------------------------------------------------------------------
// In Cyclone IV GX SR 150, no DPA local divider, hence channel reconfiguration cannot be done 
// Demonstrates PLL reconfiguration for SDI triple rate in Cyclone IV GX SR150
// -----------------------------------------------------------------------------------------------
   wire [1:0]   rx_std;
   wire         sdi_start_reconfig;
   //wire [3:0]   sdi_reconfig_togxb;
   //wire         sdi_reconfig_fromgxb;
   //wire [67:0]  rc_fromgxb;
   //wire [3:0]   multi_reconfig_done;

   wire pll_areset, pll_configupdate, pll_scanclk, pll_scanclkena, pll_scandata, pll_scandataout, pll_scandone;
    
   pll_reconfig_control pll_reconfig_control_inst
        (
         .rst                 (srst),
         .sys_clk             (sdi_ref50),
         .start_reconfig      (sdi_start_reconfig),
         .std_select          (rx_std),
         .serdes_status       (),
         .sdi_ref             (sdi_ref),
         .pll_areset          (pll_areset),
         .pll_configupdate    (pll_configupdate),
         .pll_scanclk         (pll_scanclk),
         .pll_scanclkena      (pll_scanclkena),
         .pll_scandata        (pll_scandata),
         .pll_scandataout     (pll_scandataout),
         .pll_scandone        (pll_scandone)
         );
   
   
//--------------------------------------------------------------------------------------------------
// DUT
//--------------------------------------------------------------------------------------------------
   
   wire [19:0] rxdata;
   wire [21:0] rx_ln;
   wire [1:0]  rx_data_valid_out;
   wire        rx_clk;
   wire [1:0]  rx_F;
   wire [1:0]  rx_V;
   wire [1:0]  rx_H;
   wire [1:0]  rx_AP;
   reg [1:0]   tx_std;



   wire        tx_pclk;
   assign      tx_pclk = tx_std[1] ? sdi_ref : (tx_std[0] ? sdi_ref75 : sdi_ref27);
 
   wire        patt_hd_sdn;
   assign      patt_hd_sdn = tx_std[1] ? 1'b1 : tx_std[0];

   wire        patt_clk;

   assign      patt_clk = tx_std[1] ? sdi_ref : (tx_std[0] ? sdi_ref75 : sdi_ref27);
                     
   reg [3:0] sdi_start_reconfig_dly;
   reg       reconfig_blip;
   reg [3:0] reconfig_count;
   reg       recon_rst = 1'b0;
   reg       reset_reconfig_count;
   reg [3:0] locked_dly;
   reg       locked_blip;
   reg [4:0] test_state = 5'b00000;
   
   

   // create blip to mark start of reconfig.
   always @ (posedge sdi_ref)
     begin
        if (rst) begin
           sdi_start_reconfig_dly <= 3'b0;
           reconfig_blip <= 1'b0;
           reconfig_count <= 4'b0;
           locked_dly <= 3'b0;
           locked_blip <= 1'b0;
             
        end
        else begin

           sdi_start_reconfig_dly <= {sdi_start_reconfig_dly[2:0],sdi_start_reconfig};
           reconfig_blip <= sdi_start_reconfig_dly[2] & ~sdi_start_reconfig_dly[3];

           locked_dly <= {locked_dly[2:0], (rx_status[3] & rx_status[2])};
           locked_blip <= locked_dly[2] & ~locked_dly[3];
           
           // Upon released from reset, the reconfig_count may not be accurate because
           // the power up state of curr_gxb_std_is_hd could be 1 due to simgen random
           // power up issue. This causes the Rx core initiate reconfig once to 3G.
           // But the test expects the Rx core is power up with 3G and no reconfig   
           if (reconfig_blip & test_state != 0) begin
              reconfig_count <= reconfig_count + 1;
           end
           if (reset_reconfig_count) reconfig_count <= 0;
           
        end
     end


//------------------------------------------------------------------------------------------

   reg enable_sd_search = 1'b1;
   reg enable_hd_search = 1'b1;
   reg enable_3g_search = 1'b1;
   reg [15:0] result_reg = 16'b1111111111111111;
   // this reset added as when clock switching happends beteen some video standards,
   // the fifo in the tx core overflows causing its output to be X until next reset.
   // This isn't an issue in RTL or hardware flows but prevents simgen flow
   // from running correctly.
   reg        tx_overflow_rst;
   
   integer outfile;
   
initial begin  
   #(10000);
   outfile = $fopen ("output.log","w");
   //r = $fprintf(file, "Formatted %d %x", a, b);
   $fdisplay (outfile, "3G sim\n");
end


   always @ (posedge sdi_ref)
     begin
        

        reset_reconfig_count <= 1'b0;
        tx_overflow_rst <= 1'b0;
        
        case (test_state)
          
//////////////////////
          // 3G to 3G
          5'b00000 : begin
             tx_std <= 2'b11;
             enable_3g_search <= 1'b1;
             enable_hd_search <= 1'b1;
             enable_sd_search <= 1'b1;             
             if (locked_blip == 1'b1) begin
                $display("\n ##### Test 0: Locked to 3G.  Expected count = 0, actual count = %d \n",reconfig_count);
                if (reconfig_count == 0) result_reg[0] <= 1'b0;
                test_state <= test_state + 1;
                reset_reconfig_count <= 1'b1;   
             end

          end // case: 3'b000

          // 3G to HD
          5'b00001 : begin
             tx_std <= 2'b01;
             enable_3g_search <= 1'b1;
             enable_hd_search <= 1'b1;
             enable_sd_search <= 1'b1;             
             if (locked_blip == 1'b1) begin
                $display("\n ##### Test 1: Locked to HD.  Expected count = 1, actual count = %d \n",reconfig_count);
                if (reconfig_count == 1) result_reg[1] <= 1'b0;
                test_state <= test_state + 1;
                reset_reconfig_count <= 1'b1;
             end
          end // case: 3'b001
          

          // HD to 3G
          5'b00010 : begin
             tx_std <= 2'b11;
             enable_3g_search <= 1'b1;
             enable_hd_search <= 1'b1;
             enable_sd_search <= 1'b1;             
             if (locked_blip == 1'b1) begin
                $display("\n ##### Test 2: Locked to 3G.  Expected count = 1, actual count = %d \n",reconfig_count);
                if (reconfig_count == 1) result_reg[2] <= 1'b0;                
                test_state <= test_state + 1;
                reset_reconfig_count <= 1'b1;
             end
          end // case: 3'b010


////////////////////////////////
          
          // 3G to SD
          5'b00011 : begin
             tx_std <= 2'b00;
             enable_3g_search <= 1'b1;
             enable_hd_search <= 1'b1;
             enable_sd_search <= 1'b1;             
             if (locked_blip == 1'b1) begin
                $display("\n ##### Test 3: Locked to SD.  Expected count = 0, actual count = %d \n",reconfig_count);
                if (reconfig_count == 0) result_reg[3] <= 1'b0;                                
                test_state <= test_state + 1;
                reset_reconfig_count <= 1'b1;
             end
          end // case: 3'b010

          // SD to HD
          5'b00100 : begin
             tx_std <= 2'b01;
             enable_3g_search <= 1'b1;
             enable_hd_search <= 1'b1;
             enable_sd_search <= 1'b1;             
             if (locked_blip == 1'b1) begin
                $display("\n ##### Test 4: Locked to HD.  Expected count = 1, actual count = %d \n",reconfig_count);
                if (reconfig_count == 1) result_reg[4] <= 1'b0;                                
                test_state <= test_state + 1;
                reset_reconfig_count <= 1'b1;
             end
          end // case: 3'b010      

         // HD to SD
          5'b00101 : begin
             tx_std <= 2'b00;
             enable_3g_search <= 1'b1;
             enable_hd_search <= 1'b1;
             enable_sd_search <= 1'b1;             
             if (locked_blip == 1'b1) begin
                $display("\n ##### Test 5: Locked to SD.  Expected count = 1, actual count = %d \n",reconfig_count);
                if (reconfig_count == 1) result_reg[5] <= 1'b0;                                
                test_state <= test_state + 1;
                reset_reconfig_count <= 1'b1;
             end
          end // case: 3'b010  
          
          // SD to 3G
          5'b00110 : begin
             tx_std <= 2'b11;
             enable_3g_search <= 1'b1;
             enable_hd_search <= 1'b1;
             enable_sd_search <= 1'b1;             
             if (locked_blip == 1'b1) begin
                $display("\n ##### Test 6: Locked to 3G.  Expected count = 0, actual count = %d \n",reconfig_count);
                if (reconfig_count == 0) result_reg[6] <= 1'b0;                                
                test_state <= 5'b01110;
                reset_reconfig_count <= 1'b1;
             end
          end // case: 3'b010  
     
//////////////////////
//////////////////////
//////////////////////
//////////////////////
//////////////////////
//////////////////////

          // not currently included in test run due to test_state + 2 from above.
          // 3G to 3G
          5'b00111 : begin
             tx_std <= 2'b11;
             enable_3g_search <= 1'b1;
             enable_hd_search <= 1'b0;
             enable_sd_search <= 1'b0;             
             if (locked_blip == 1'b1) begin
                $display("\n ##### Test 0: Locked.  Expected count = 0, actual count = %d \n",reconfig_count);
                if (reconfig_count == 0) result_reg[7] <= 1'b0;
                test_state <= test_state + 1;
                reset_reconfig_count <= 1'b1;   
             end

          end // case: 3'b000

          // 3G to HD
          5'b01000 : begin
             tx_std <= 2'b01;
             enable_3g_search <= 1'b0;
             enable_hd_search <= 1'b1;
             enable_sd_search <= 1'b0;             
             if (locked_blip == 1'b1) begin
                $display("\n ##### Test 8: Locked.  Expected count = 1, actual count = %d \n",reconfig_count);
                if (reconfig_count == 1) result_reg[8] <= 1'b0;
                test_state <= test_state + 1;
                reset_reconfig_count <= 1'b1;
             end
          end // case: 3'b001
          

          // HD to 3G
          5'b01001 : begin
             tx_std <= 2'b11;
             enable_3g_search <= 1'b1;
             enable_hd_search <= 1'b0;
             enable_sd_search <= 1'b0;             
             if (locked_blip == 1'b1) begin
                $display("\n ##### Test 9: Locked.  Expected count = 1, actual count = %d \n",reconfig_count);
                if (reconfig_count == 1) result_reg[9] <= 1'b0;                
                test_state <= test_state + 1;
                reset_reconfig_count <= 1'b1;
                tx_overflow_rst <= 1'b1;
             end
          end // case: 3'b010


////////////////////////////////
          
          // 3G to SD
          5'b01010 : begin
             tx_overflow_rst <= 1'b0;
             tx_std <= 2'b00;
             enable_3g_search <= 1'b0;
             enable_hd_search <= 1'b0;
             enable_sd_search <= 1'b1;             
             if (locked_blip == 1'b1) begin
                $display("\n ##### Test 10: Locked.  Expected count = 0, actual count = %d \n",reconfig_count);
                if (reconfig_count == 0) result_reg[10] <= 1'b0;                                
                test_state <= test_state + 1;
                reset_reconfig_count <= 1'b1;
                        tx_overflow_rst <= 1'b1;
             end
          end // case: 3'b010

          // SD to HD
          5'b01011 : begin
             tx_overflow_rst <= 1'b0;
             tx_std <= 2'b01;
             enable_3g_search <= 1'b0;
             enable_hd_search <= 1'b1;
             enable_sd_search <= 1'b0;             
             if (locked_blip == 1'b1) begin
                $display("\n ##### Test 11: Locked.  Expected count = 1, actual count = %d \n",reconfig_count);
                if (reconfig_count == 1) result_reg[11] <= 1'b0;                                
                test_state <= test_state + 1;
                reset_reconfig_count <= 1'b1;
                tx_overflow_rst <= 1'b1;
             end
          end // case: 3'b010      

         // HD to SD
          5'b01100 : begin
             tx_overflow_rst <= 1'b0;             
             tx_std <= 2'b00;
             enable_3g_search <= 1'b1;
             enable_hd_search <= 1'b0;
             enable_sd_search <= 1'b1;             
             if (locked_blip == 1'b1) begin
                $display("\n ##### Test 12: Locked.  Expected count = 1, actual count = %d \n",reconfig_count);
                if (reconfig_count == 1) result_reg[12] <= 1'b0;                                
                test_state <= test_state + 1;
                reset_reconfig_count <= 1'b1;
								tx_overflow_rst <= 1'b1;
             end
          end // case: 3'b010  
          
          // SD to 3G
          5'b01101 : begin
             tx_std <= 2'b11;
						 tx_overflow_rst <= 1'b0;
             enable_3g_search <= 1'b1;
             enable_hd_search <= 1'b0;
             enable_sd_search <= 1'b1;             
             if (locked_blip == 1'b1) begin
                $display("\n ##### Test 13: Locked.  Expected count = 0, actual count = %d \n",reconfig_count);
                if (reconfig_count == 0) result_reg[13] <= 1'b0;                                
                test_state <= test_state + 1;
                reset_reconfig_count <= 1'b1;
             end
          end // case: 3'b010

         // Final check of individual tests.
          5'b01110 : begin

             if (result_reg[0]) $fdisplay(outfile, "\n ## Test 0: FAILED. ##"); 
             else $fdisplay(outfile,"\n ## Test 0: RAN SUCESSFULLY. ##");

             if (result_reg[1]) $fdisplay(outfile, "\n ## Test 1: FAILED. ##"); 
             else $fdisplay(outfile,"\n ## Test 1: RAN SUCESSFULLY. ##");

             if (result_reg[2]) $fdisplay(outfile, "\n ## Test 2: FAILED. ##"); 
             else $fdisplay(outfile,"\n ## Test 2: RAN SUCESSFULLY. ##");

             if (result_reg[3]) $fdisplay(outfile, "\n ## Test 3: FAILED. ##"); 
             else $fdisplay(outfile,"\n ## Test 3: RAN SUCESSFULLY. ##");

             if (result_reg[4]) $fdisplay(outfile, "\n ## Test 4: FAILED. ##"); 
             else $fdisplay(outfile,"\n ## Test 4: RAN SUCESSFULLY. ##");

             if (result_reg[5]) $fdisplay(outfile, "\n ## Test 5: FAILED. ##"); 
             else $fdisplay(outfile,"\n ## Test 5: RAN SUCESSFULLY. ##");

             if (result_reg[6]) $fdisplay(outfile, "\n ## Test 6: FAILED. ##"); 
             else $fdisplay(outfile,"\n ## Test 6: RAN SUCESSFULLY. ##");

             // this test not needed
             //if (result_reg[7]) $fdisplay(outfile, "\n ## Test 7: FAILED. ##"); 
             //else $fdisplay(outfile,"\n ## Test 7: RAN SUCESSFULLY. ##");
			/*
             if (result_reg[8]) $fdisplay(outfile, "\n ## Test 8: FAILED. ##"); 
             else $fdisplay(outfile,"\n ## Test 8: RAN SUCESSFULLY. ##");

             if (result_reg[9]) $fdisplay(outfile, "\n ## Test 9: FAILED. ##"); 
             else $fdisplay(outfile,"\n ## Test 9: RAN SUCESSFULLY. ##");

             if (result_reg[10]) $fdisplay(outfile, "\n ## Test 10: FAILED. ##"); 
             else $fdisplay(outfile,"\n ## Test 10: RAN SUCESSFULLY. ##");

             if (result_reg[11]) $fdisplay(outfile, "\n ## Test 11: FAILED. ##"); 
             else $fdisplay(outfile,"\n ## Test 11: RAN SUCESSFULLY. ##");

             if (result_reg[12]) $fdisplay(outfile, "\n ## Test 12: FAILED. ##"); 
             else $fdisplay(outfile,"\n ## Test 12: RAN SUCESSFULLY. ##");

             if (result_reg[13]) $fdisplay(outfile, "\n ## Test 13: FAILED. ##"); 
             else $fdisplay(outfile,"\n ## Test 13: RAN SUCESSFULLY. ##");
			*/
             $stop(0);
             
             
          end // case: 3'b010  

        endcase // case(test_state)

    end // always @ (posedge sdi_ref)
  
  trsdi_duplex duplex_inst
  (
   .rst_tx                     (rst | tx_overflow_rst),
   .tx_pclk                    (tx_pclk),
   .tx_serial_refclk           (sdi_ref),
   .txdata                     (gen_data),
   .tx_ln                      ({11'b0,gen_ln}),
   .tx_trs                     (gen_trs),
   .enable_ln                  (1'b1),
   .enable_crc                 (1'b1),
   .gxb4_cal_clk               (gxb2_cal_clk),
   .sdi_reconfig_clk           (),
   .sdi_reconfig_togxb         (4'b0010),  // value required when not performing channel reconfig
                                           // In hardware, these port should be hooked up with altgx_reconfig
                                           // for offset cancellation purpose
   .tx_std                     (tx_std),
   .sdi_tx                     (serial_tx),
   .tx_status                  (tx_status),
   .gxb_tx_clkout              (),
   .sdi_reconfig_fromgxb       (),


   .rst_rx                   (rst),
   .rx_serial_refclk         (sdi_ref),
   .rx_coreclk               (sdi_ref),
   .sdi_rx                   (serial_rx),
   .enable_hd_search         (enable_hd_search),
   .enable_sd_search         (enable_sd_search),
   .enable_3g_search         (enable_3g_search),
   .sdi_gxb_powerdown        (1'b0),
   .rx_std_flag_hd_sdn       (),
   .rxdata                   (rxdata),
   .rx_F                     (rx_F),
   .rx_V                     (rx_V),
   .rx_H                     (rx_H),
   .rx_AP                    (rx_AP),
   .rx_ln                    (rx_ln),
   .crc_error_y              (),
   .crc_error_c              (),
   .rx_anc_data              (),
   .rx_anc_valid             (),
   .rx_anc_error             (),
   .rx_status                (rx_status),
   .rx_data_valid_out        (rx_data_valid_out),
   .rx_clk                   (rx_clk),
   .sdi_start_reconfig       (sdi_start_reconfig),
   .rx_std                   (rx_std),       
   .pll_areset               (pll_areset),
   .pll_configupdate         (pll_configupdate),
   .pll_scanclk              (pll_scanclk),
   .pll_scanclkena           (pll_scanclkena),
   .pll_scandata             (pll_scandata),
   .pll_scandataout          (pll_scandataout),
   .pll_scandone             (pll_scandone)
   );
   
  
   assign align_locked = rx_status[2] & rx_status[3] & rx_status[4];
   

//--------------------------------------------------------------------------------------------------
// Transmit pattern
//--------------------------------------------------------------------------------------------------

        
   

pattern_gen_sync u_gen (
  .clk                      (patt_clk),
  .rst                      (patt_rst),
  .hd_sdn                   (patt_hd_sdn),
  .bar_75_100n              (1'b1),
  .select_std               (tx_std),
  .enable                   (~rst),
  .patho                    (1'b0),
  .blank                    (1'b0),
  .no_color                 (1'b0),

  .dout                     (gen_data),
  .trs                      (gen_trs),
  .ln                       (gen_ln),

  .lines_per_frame          (11'd20),
  .words_per_active_line    (13'd16),
  .words_per_total_line     (13'd32),
  .f_rise_line              (11'd21),
  .v_fall_line_1            (11'd2),
  .v_rise_line_1            (11'd18),
  .v_fall_line_2            (11'd0),
  .v_rise_line_2            (11'd0),
  .patho_change_line_1      (11'd0),
  .patho_change_line_2      (11'd0)
  );


//--------------------------------------------------------------------------------------------------
// Sample the serial tx data
//--------------------------------------------------------------------------------------------------
reg sample;
event tx_sclk;
initial begin
  // Wait for PLL to lock
   @(posedge tx_status);
  // Wait a few clocks to skip the spurious output from the transceiver at startup
   repeat (4) @(posedge refclk);
      

  // Wait for start of first bit
  @(posedge serial_tx);

  // Wait half a bit period to align with centre of data
  #(SERIAL_PERIOD/2);
  // Continuously sample
  $display("-- Testbench : Start sampling serial tx data");
  forever begin
    sample = serial_tx;
    -> tx_sclk;
    #(SERIAL_PERIOD);
  end
end

//--------------------------------------------------------------------------------------------------
// Descramble serial tx data
//--------------------------------------------------------------------------------------------------
reg [8:0] tx_lfsr = 9'b0;
reg tx_nrzi;
reg last_sample = 1'b0;
reg descrambled;
always @ (tx_sclk)
begin
  tx_nrzi = last_sample ^ sample;
  last_sample = sample;
  descrambled = tx_nrzi ^ tx_lfsr[4] ^ tx_lfsr[8];
  tx_lfsr[8:0] = {tx_lfsr[7:0], tx_nrzi};
end

//--------------------------------------------------------------------------------------------------
// Reconstruct parallel tx data
//--------------------------------------------------------------------------------------------------
reg [59:0] shiftreg;
reg aligned = 1'b0;
integer bit;
reg [9:0] t_txword;
reg [9:0] txword;
event word_tick;
integer trs_count = 0;

always @ (tx_sclk)
begin
  // Make parallel word once bit alignment known
 if (aligned) begin
    t_txword[bit] = descrambled;
    if (bit==9) begin
      bit = 0;
      txword = t_txword;
      -> word_tick;
    end
    else
      bit = bit + 1;
  end
  // Shift register to detect TRS
  shiftreg = {shiftreg[58:0], descrambled};
  if (shiftreg=={10'h3FF, 10'h3FF, 10'h000, 10'h000, 10'h000, 10'h000}) begin
    if (~aligned) begin
      $display("-- Testbench : TRS spotted in transmitted data");
      aligned = 1'b1;
      bit = 0;
      trs_count = 1;
    end
    else
      trs_count = trs_count + 1;
  end
end


//--------------------------------------------------------------------------------------------------
// Connect tx to rx
//--------------------------------------------------------------------------------------------------

initial begin
  #200000;
  forever begin
    @(serial_tx);
    if (serial_tx==1'b0 | serial_tx==1'b1)
      serial_rx = serial_tx;
  end
end

//--------------------------------------------------------------------------------------------------
// Check LN output
//--------------------------------------------------------------------------------------------------
reg [10:0] last_ln;
reg [10:0] expected_ln;
reg bad_ln;
initial begin
  bad_ln = 0;
  @(negedge rst);
  @(rx_ln[10:0]);
  @(rx_ln[10:0]);
  expected_ln = (last_ln+1)%11;
  if (expected_ln==0)
    expected_ln = 1;
  last_ln = rx_ln[10:0];
  forever begin
    @(rx_ln[10:0]);
    if (rx_ln[10:0]!=expected_ln) begin
      $display("**** Bad LN received. Got %d, expected %d", rx_ln[10:0], expected_ln);
      bad_ln = 1;
    end
    last_ln = rx_ln[10:0];
  end
end

endmodule
