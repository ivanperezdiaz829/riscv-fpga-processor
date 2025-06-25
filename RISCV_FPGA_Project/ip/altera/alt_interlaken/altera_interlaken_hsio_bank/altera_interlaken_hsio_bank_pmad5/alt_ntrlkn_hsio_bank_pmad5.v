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


`timescale 1 ps / 1 ps
// baeckler - 01-26-2009
//GXB reconfig, and bus ordering. The GXB power up sequence 
//now moved to alt_interlaken_rsd dir. 7-20-11  JZ

module alt_ntrlkn_hsio_bank_pmad5 #(
					   parameter WORD_LEN = 20,		  // do not change
					   parameter LANES = 5,			  // do not change
                                           parameter SIM_FAST_RESET = 0,
					   parameter LANE_RATE = "6250 Mbps",
					   parameter INPUT_CLOCK_FREQUENCY = "312.5 MHz",
					   parameter INPUT_CLOCK_PERIOD = 3200
      
					   )
      (
	input  ref_clk,             // pll reference clock
	input  clk_in,              // transmit core clk, common_tx_clk
	output clk_out,             // to core logic if this quad is running the show, otherwise discard.
        input  cal_blk_clk,         //Slow clock that the reset controller run on

        input  pll_powerdown,       //In cal_blk_clk domain
        input  tx_digitalreset,     //In cal_blk_clk domain
        input  rx_digitalreset,     //In cal_blk_clk domain
        input  tx_lane_arst_early,  //One cycle earlier than tx_lane_arst in clk_in or common_tx_clk domain
        input  rx_lane_arst_early,  //Not used here. But may needed for extra flop of rx_dataout in common_rx_clk domain
        input  rx_analogreset,      //In cal_blk_clk domain
        output reco_busy,           //In cal_blk_clk domain
        output pll_locked_n,
        output rx_freqlocked_n,

	input [WORD_LEN*LANES-1:0] tx_datain,  // serial data to be sent, synchronous to clk_in
	
	input common_rx_clk, // received serial data on common clock
	output reg  [WORD_LEN*LANES-1:0] rx_dataout,
	output [LANES-1:0] rx_clk,		
	
	// board HSIO pins
	output [LANES-1:0] tx_pin,
	input [LANES-1:0] rx_pin,
	
	// diagnostic ports 
	input serial_loopback,		// serial loopback in the GX block TX -> RX
	input tx_error_inject,          // on rising edge, invert 1 TX bit
	input freq_ref, 		// timebase
	
	
	// analog reconfig
	input [24:0] new_analog_params,
	input rd_analog, wr_analog   // rising edge, new settings must be stable	
);

      reg [24:0] analog_params = 25'd0;
      reg        reco_busy_r;

      /////////////////////////////////////
             // power on reset, calibration domain
      /////////////////////////////////////
      reg [7:0] cal_arst_cntr /* synthesis preserve */;
      reg       cal_arst;
      initial cal_arst_cntr = 0;

      always @(posedge cal_blk_clk) begin
            if (&cal_arst_cntr) begin
                  cal_arst <= 1'b0;
            end
            else begin
                  cal_arst_cntr <= cal_arst_cntr + 1'b1;
                  cal_arst <= 1'b1;
            end
      end


      //The reco_busy is red. Need to check with Reka.
      always @(posedge cal_blk_clk or posedge cal_arst) begin
            if (cal_arst) begin
                  reco_busy_r <= 1'b0;
            end
            else begin
                  reco_busy_r <= reco_busy; // reco_busy;
            end
      end
      //////////////////////////////

      wire [LANES*WORD_LEN-1:0] tx_datain_to_fifo_w;
      wire [LANES*WORD_LEN-1:0] rev_rx_dataout;
      wire [LANES*WORD_LEN-1:0] rx_dataout_i;

      wire [LANES-1:0] 		gxb_rx_freqlocked;

      // The GX block is sending the least significant bit
      // out first.  Fix it.
      genvar 			x,y;
      generate 
	    for (x=0; x<LANES; x=x+1) 
	      begin : bk
		    for (y=0; y<WORD_LEN; y=y+1)
		      begin : ah
			    assign rx_dataout_i[x*WORD_LEN+y] = rev_rx_dataout[x*WORD_LEN+(WORD_LEN-1-y)];
			    assign tx_datain_to_fifo_w[x*WORD_LEN+y] = tx_datain[x*WORD_LEN+(WORD_LEN-1-y)];					
		      end
	      end
      endgenerate

reg tx_lane_arst;
always @(posedge clk_in)
              tx_lane_arst <= tx_lane_arst_early;

// Error injection in the TX datastream 
// 1 bit invert on the rising edge of the inject input
reg error_bit;
reg last_err_inject;
      always @(posedge clk_in or posedge tx_lane_arst) begin
	    if (tx_lane_arst) begin
		  last_err_inject <= 0;
		  error_bit <= 0;
	    end
	    else begin
		  last_err_inject <= tx_error_inject;
		  error_bit <= 1'b0;
		  if (tx_error_inject & !last_err_inject) begin
			error_bit <= 1'b1;
		  end
	    end
      end

      // TX output registers
      reg [LANES*WORD_LEN-1:0] tx_datain_to_fifo;
      always @(posedge clk_in or posedge tx_lane_arst) begin
	    if (tx_lane_arst) tx_datain_to_fifo <= 0;
	    else tx_datain_to_fifo <= tx_datain_to_fifo_w ^ error_bit;
      end

      /////////////////////////////////////////
      // GXB reconfiguration logic
      /////////////////////////////////////////

      wire [3:0] reconfig_to_gxb;
      wire 	 reconfig_clk = cal_blk_clk;
      wire [84:0] reconfig_fromgxb;

      wire [3:0]  rx_eqctrl;
      wire [2:0]  rx_eqdcgain;
      wire [4:0]  tx_preemp_0t;
      wire [4:0]  tx_preemp_1t;
      wire [4:0]  tx_preemp_2t;
      wire [2:0]  tx_vodctrl;

      reg 	  reco_write;
      reg 	  reco_read;
      wire 	  reco_valid;

      wire [79:0] rx_eqctrl_out;
      wire [59:0] rx_eqdcgain_out;
      wire [99:0] tx_preemp_0t_out;
      wire [99:0] tx_preemp_1t_out;
      wire [99:0] tx_preemp_2t_out;
      wire [59:0] tx_vodctrl_out;

      alt_ntrlkn_reconfig_pmad5 rc (
	       .reconfig_clk(reconfig_clk),
	       .reconfig_fromgxb(reconfig_fromgxb),
	       .busy(reco_busy),
	       .reconfig_togxb(reconfig_to_gxb),
	    
	       .rx_eqctrl(rx_eqctrl),
	       .rx_eqdcgain(rx_eqdcgain),
	       .tx_preemp_0t(tx_preemp_0t),
	       .tx_preemp_1t(tx_preemp_1t),
	       .tx_preemp_2t(tx_preemp_2t),
	       .tx_vodctrl(tx_vodctrl),
	       .write_all(reco_write),
	    
	       .read(reco_read),
	       .data_valid(reco_valid),
	       .rx_eqctrl_out(rx_eqctrl_out),
	       .rx_eqdcgain_out(rx_eqdcgain_out),
	       .tx_preemp_0t_out(tx_preemp_0t_out),
	       .tx_preemp_1t_out(tx_preemp_1t_out),
	       .tx_preemp_2t_out(tx_preemp_2t_out),
	       .tx_vodctrl_out(tx_vodctrl_out)
	       );	

      reg 	  wr_gx,rd_gx,last_wr_gx, last_rd_gx;

      assign {rx_eqctrl,rx_eqdcgain,
	      tx_preemp_0t,tx_preemp_1t,tx_preemp_2t,
	      tx_vodctrl} = analog_params;

      wire [24:0] readback_params;

      assign readback_params = {
				rx_eqctrl_out [3:0],
				rx_eqdcgain_out [2:0],
				tx_preemp_0t_out [4:0],
				tx_preemp_1t_out [4:0],
				tx_preemp_2t_out [4:0],
				tx_vodctrl_out [2:0]
				};

      localparam 
	ST_IDLE = 4'h0,
	ST_WRITE_TO_GX = 4'h1,
	ST_WRITE_WAIT = 4'h2,
	ST_READ_FROM_GX = 4'h3,
	ST_READ_WAIT = 4'h4, 
	ST_PAUSE = 4'h5;

      reg [19:0]  timer;
      reg 	  timer_max;

      reg [3:0]   state = ST_IDLE /* synthesis preserve */;
      always @(posedge reconfig_clk) begin
	    
	    timer <= timer + 1'b1;
	    timer_max <= &timer;
	    reco_write <= 0;
	    reco_read <= 0;
	    last_wr_gx <= wr_gx;
	    last_rd_gx <= rd_gx;
	    wr_gx <= wr_analog;
	    rd_gx <= rd_analog;
	    
	    case (state)
	      ST_IDLE: begin
		    timer <= 0;
		    timer_max <= 0;
		    if (wr_gx & !last_wr_gx) begin
			  state <= ST_WRITE_TO_GX;
			  analog_params <= new_analog_params;
		    end
		    if (rd_gx & !last_rd_gx) begin
			  state <= ST_READ_FROM_GX;
		    end
	      end
	      ST_WRITE_TO_GX : begin
		    reco_write <= 1'b1;				
		    state <= ST_WRITE_WAIT;
	      end
	      ST_WRITE_WAIT : begin
		    if (timer_max & !reco_busy_r) 
		      state <= ST_READ_FROM_GX; // readback
	      end
	      ST_READ_FROM_GX : begin
		    reco_read <= 1'b1;
		    state <= ST_READ_WAIT;
	      end	
	      ST_READ_WAIT : begin
		    if (timer_max) begin
			  if (!reco_busy_r & reco_valid) begin
				analog_params <= readback_params;
			  end
			  else begin
				// GX to reg read failure
				analog_params <= 25'h7DEAD7;
			  end
			  state <= ST_IDLE;
		    end
	      end	
	    endcase		
      end

      /////////////////////////////////////////
      // x5 actual IO bank
      /////////////////////////////////////////

wire             pll_locked;

assign rx_freqlocked_n = ~(&gxb_rx_freqlocked);
assign pll_locked_n = ~pll_locked;

wire [LANES-1:0] tx_clkout;
wire [LANES*WORD_LEN-1:0] tx_datain_from_fifo;
reg [LANES*WORD_LEN-1:0] 	tx_prelaunch /* synthesis preserve */;
reg [LANES*WORD_LEN-1:0] 	tx_launch /* synthesis preserve */;
alt_ntrlkn_gxb_pmad5 gx (
				.cal_blk_clk(cal_blk_clk),
				.pll_inclk(ref_clk),
				.rx_cruclk({LANES{ref_clk}}),
				.pll_powerdown(pll_powerdown),
				.gxb_powerdown(pll_powerdown),
				.cal_blk_powerdown(1'b0),
				.reconfig_clk(reconfig_clk),
				.reconfig_togxb(reconfig_to_gxb),
				.rx_analogreset({LANES{rx_analogreset}}),
				.rx_datain(rx_pin),
				.tx_datain(tx_launch),
				.pll_locked(pll_locked),
				.reconfig_fromgxb(reconfig_fromgxb),
				.rx_freqlocked(gxb_rx_freqlocked),
				.rx_clkout(rx_clk[4:0]),
				.rx_dataout(rev_rx_dataout),
				.tx_clkout(tx_clkout),
				.rx_seriallpbken({LANES{serial_loopback}}),
				.tx_dataout(tx_pin)
				);
      defparam gx.effective_data_rate = LANE_RATE;
      defparam gx.input_clock_frequency = INPUT_CLOCK_FREQUENCY;
      defparam gx.input_clock_period = INPUT_CLOCK_PERIOD;
      
      reg [LANES-1:0] fifo_purge_tx = 0 /* synthesis preserve */;
      always @(posedge clk_in) 
              fifo_purge_tx <= {LANES{tx_lane_arst_early}};

      //////////////////////////////////
      // TX phase FIFOs
      //////////////////////////////////

      genvar 			i;
      generate
	    for (i=0;i<LANES;i=i+1) begin : txd
		  // cross to lane TX domain
		  alt_ntrlkn_pma_fifo_pmad5 txf (
			   .wrclk(clk_in),
			   .data(tx_datain_to_fifo[WORD_LEN*(i+1)-1:WORD_LEN*i]),
			   .wrsclr(fifo_purge_tx[i]),
	
			   .rdclk(~tx_clkout[i]),
			   .q(tx_datain_from_fifo[WORD_LEN*(i+1)-1:WORD_LEN*i])
			   );
		  
		  // register tx fifo outs
		  always @(negedge tx_clkout[i]) begin
			tx_prelaunch [WORD_LEN*(i+1)-1:WORD_LEN*i] <=
								     tx_datain_from_fifo [WORD_LEN*(i+1)-1:WORD_LEN*i];
		  end
		  
		  // negative phased data for the transmitter
		  always @(negedge tx_clkout[i]) begin
			tx_launch [WORD_LEN*(i+1)-1:WORD_LEN*i] <=
								  tx_prelaunch  [WORD_LEN*(i+1)-1:WORD_LEN*i];
		  end		
	    end
      endgenerate
      
      //////////////////////////////////
      // RX cap regs
      //////////////////////////////////
      wire [WORD_LEN*LANES-1:0] rx_dataout_from_fifo;
      reg [WORD_LEN*LANES-1:0] 	rx_dataout_to_fifo;
      reg [WORD_LEN*LANES-1:0] 	rx_capture /* synthesis preserve */;

      generate
	    for (i=0;i<LANES;i=i+1) begin : rr
		  // capture
		  always @(negedge rx_clk[i]) begin
			rx_capture [WORD_LEN*(i+1)-1:WORD_LEN*i] <=
								   rx_dataout_i [WORD_LEN*(i+1)-1:WORD_LEN*i];
		  end			
		  
		  //Double flopped. Can be removed if timing is not an issue. 
		  always @(negedge rx_clk[i]) begin
			rx_dataout_to_fifo [WORD_LEN*(i+1)-1:WORD_LEN*i] <=
									   rx_capture [WORD_LEN*(i+1)-1:WORD_LEN*i];				
		  end

                   reg [2:0] rx_purge_sync = 0 /* synthesis preserve */
                /* synthesis ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_false_path -from [get_keepers *cntr\[19\]] -to [get_keepers *rx_purge_sync\[*\]]\" " */;

                always @(negedge rx_clk[i] or posedge rx_lane_arst_early) begin
                        if (rx_lane_arst_early) rx_purge_sync <= 0;
                        else rx_purge_sync <= {rx_purge_sync[1:0],1'b1};
                end
                wire fifo_purge_rx = !rx_purge_sync[2];

		  
		  // leave the PCLK to common domain
		  alt_ntrlkn_pma_fifo_pmad5 rxf (
			   .wrclk(~rx_clk[i]),
			   .data(rx_dataout_to_fifo[WORD_LEN*(i+1)-1:WORD_LEN*i]),
                           .wrsclr(fifo_purge_rx),

			   .rdclk(common_rx_clk),
			   .q(rx_dataout_from_fifo[WORD_LEN*(i+1)-1:WORD_LEN*i])
			   );
		  
		  // re-register the read FIFO outs
		  always @(posedge common_rx_clk) begin
			rx_dataout [WORD_LEN*(i+1)-1:WORD_LEN*i] <=
								   rx_dataout_from_fifo [WORD_LEN*(i+1)-1:WORD_LEN*i];											
		  end						
	    end
      endgenerate
      

      ///////////////////////////////////////
      // drive the core logic clock and reset
      // Core may only drop out of reset when
      // GX is roughly ready to send data.
      // RX will still be unstable
      //
      assign clk_out = tx_clkout[0];


      
      //////////////////////////////////////////
      // Clock rate monitor
      //////////////////////////////////////////

      alt_ntrlkn_frequency_monitor_pmad5 fm
	(
	 .signal({clk_out,rx_clk[LANES-1:0]}),
	 .ref_clk(freq_ref),
	 .khz_counters()
	 );
      defparam fm .NUM_SIGNALS = LANES+1;
      defparam fm .REF_KHZ = 20'd50000;

endmodule // altera_interlaken_hsio_bank_pmad5
