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





//============================================================================
// Define Parameters 
//============================================================================
`define XGMII_IDLE_D            64'h0707_0707_0707_0707
`define XGMII_IDLE_C             8'b11111111
`define XGMII_START              8'hFB
`define XGMII_TERMINATE          8'hFD
`define FRAME_TYPE_CONSTANT      4'b0001
`define FRAME_TYPE_CONSTANT_CRC  4'b1001
`define FRAME_TYPE_INCREMENT     4'b0010
`define FRAME_TYPE_RANDOM        4'b0100
`define MAX_FRAME                6

`define BUS_WIDTH 8
`define PATTERN 8'hBC   // 20'b1010000011_0101111100
`define SER_WORDS 1
`define LANES 1

`timescale 1 ps/1 ps



module  test_harness #(
  parameter CLOCKS_PER_SECOND    = 125_000_000, // mgmt_master time calculations
  parameter TEST_HARNESS_TIMOUT  = 500us,      // mgmt_master program timeout
  parameter SYNTH_GMII           = 1,          // Include GMII PCS logic.  Must always be enabled when 1G mode is enabled.
  parameter SYNTH_SEQ_DE         = 1,          // Include Sequencer logic in the PHY.
  parameter SYNTH_FEC_DE         = 0           // Synthesize/include the FEC logic+10GSoft PCS.
  )(
  input  wire         xgmii_rx_clk,
  output wire         xgmii_tx_clk,
  input  wire         phy_mgmt_clk,
  input  wire         phy_mgmt_clk_reset,
  input  wire         tx_ready,
  input  wire         rx_ready,
  input  wire         rx_ready_gmii,

  output reg           reset_rc_bundle,
  output reg           reset_rmt_rc_bndl,
  output reg   [1:0]   reconfig_req,
  output reg   [1:0]   reconfig_rom1_rom0bar,
  input  wire  [1:0]   reconfig_busy,

  // GMII ports
  input wire          tx_clkout_1g,
  input wire          rx_clkout_1g,
  output wire [7:0]   gmii_tx_d,
  input  wire [7:0]   gmii_rx_d,
  output wire         gmii_tx_en,
  input  wire         gmii_rx_en,
  output wire         gmii_tx_err,
  input  wire         gmii_rx_err,
  input  wire         gmii_rx_dv ,

  // XMGII ports
  output wire [71:0]  xgmii_tx_dc,
  input  wire [71:0]  xgmii_rx_dc,

  // mgmt master ports
  output wire [15:0]  phy_mgmt_address,     
  output wire         phy_mgmt_read,        
  input  wire [31:0]  phy_mgmt_readdata,    
  input  wire         phy_mgmt_waitrequest,
  output wire         phy_mgmt_write,       
  output wire [31:0]  phy_mgmt_writedata    
);


   wire               xgmii_tx_clk_from_xgmii_src;
   wire               frame_done;
   wire        [63:0] xgmii_rx_d_mon;
   wire         [7:0] xgmii_rx_c_mon;
   wire        [63:0] xgmii_tx_d_mon;
   wire         [7:0] xgmii_tx_c_mon;
   wire         [7:0] tx_parallel_data;
   wire         [7:0] rx_parallel_data;
   wire               rx_datak;
   reg                tx_datak;
   wire               fifo_full;
   wire               checker_pass;

   reg                frame_sof_reg=0;
   reg         [13:0] frame_length_reg=0;
   reg          [3:0] frame_type_reg=0;
   reg         [15:0] frame_ifg_reg=0;
   reg         [63:0] frame_constant_reg=0;
   reg                test_done = 0;
   wire                rx_mismatch,match;
   reg                rx_sync_lock_ff2;
   wire                sync_aquired;
   reg         [7:0]  gmii_tx_d1;
   reg                gmii_tx_en1;
   wire                word_alignment_status_wire;
   reg         [1:0]  reconfig_busy_syn;
   reg                reconfig_busy_sync_d,reconfig_busy_pulse;

   wire                test_pass ;  
   wire                packet_complete_gen,packet_complete_chk,rx_mismatch_gmii ;
   wire                ch_pass ;
   wire                tx_clkout,rx_clkout,reset_gige_sync,error_flag_ch,rx_mismatch_pulse;
   integer             num_frame = 0;
   reg [13:0] FRAME_LENGTH_LIST [0:(`MAX_FRAME-1)]= '{50, 100, 500, 1000, 1500, 80};
   reg [3:0]  FRAME_TYPE_LIST  [0:(`MAX_FRAME-1)]= '{`FRAME_TYPE_INCREMENT, `FRAME_TYPE_RANDOM, `FRAME_TYPE_INCREMENT, `FRAME_TYPE_RANDOM, `FRAME_TYPE_RANDOM, `FRAME_TYPE_RANDOM};

////////////// start with non-synthesizable construct to assert req ////////////////
//////////////////////////////////////////////////////////////////////////////////

initial
begin
@ (posedge reconfig_busy);
$display ("on reset- Reconfig_busy is high");
@ (negedge reconfig_busy);
$display ("Reconfig-busy low");
#1000;
@ (posedge phy_mgmt_clk);
@ (posedge reconfig_busy);
@ (posedge phy_mgmt_clk);
$display("Request acknowledged...");
@ (negedge reconfig_busy);
$display("Request served...");
@ (negedge reconfig_rom1_rom0bar);
$display("Entering 10G mode...");
end

////////////// end of non-synthesizable construct to assert req //////////////////
//////////////////////////////////////////////////////////////////////////////////

///// CLK and RESET GENERATION

assign xgmii_tx_clk = xgmii_rx_clk;
assign tx_clkout = tx_clkout_1g ;
assign rx_clkout = rx_clkout_1g ;
///// 
  wire idle, idle_one_pulse;
  reg idle_dly;
  assign idle_one_pulse = idle & ~idle_dly;

wire start_xgmii_test;

always @ (posedge xgmii_rx_clk) begin
		if (phy_mgmt_clk_reset | start_xgmii_test)
		  idle_dly <= 1'b0;
		else if (rx_sync_lock_ff2 == 1'd1)
		  idle_dly <= idle;
		else
		  idle_dly <= 1'b0;
	end

	always @ (posedge xgmii_rx_clk) begin
		if ((rx_sync_lock_ff2 == 1'd1) && rx_ready ) begin
			if (!fifo_full && !test_done) begin
  			frame_sof_reg    <= idle_one_pulse;
	  		frame_length_reg <= FRAME_LENGTH_LIST[num_frame]; 
				frame_type_reg   <= FRAME_TYPE_LIST[num_frame];
				frame_constant_reg <= 2;
				frame_ifg_reg    <= 20;
			end
		end
	end



always @ (posedge xgmii_rx_clk) begin
if (start_xgmii_test)
	num_frame <= 0;
else if (rx_sync_lock_ff2 && frame_done &&  !fifo_full && !test_done)
	num_frame <= num_frame+1;
end

always @ (posedge xgmii_rx_clk )
begin
 if (start_xgmii_test)
  test_done <= 0;
 else if (num_frame == `MAX_FRAME) 
 test_done <= 1;
end
  assign test_pass = rx_sync_lock_ff2&checker_pass&!rx_mismatch;
  
//============================================================================
// Instantiate the mgmt master program control
// Need to have the program in the file th_mgmt_prog_n.sv
//============================================================================
  wire [30:16] conwar;   // get rid of connection warnings
  wire [15:12] conwar2;   // get rid of connection warnings
  wire master_bfm_done;
  wire gige_sync_start;
  wire fec_test;

  assign fec_test = SYNTH_FEC_DE ? 1'b1 : 1'b0 ;

`define MGMT_PROGRAM_TASK th_mgmt_prog
  th_mgmt_master #( 
   .CLOCKS_PER_SECOND(CLOCKS_PER_SECOND), // Used for time calculations
    .PIO_OUT_SIZE(16),                    // Width of PIO output port
    .PIO_IN_SIZE(16),                     // Width of PIO input port
    .ROM_DEPTH(512),                     // Depth of command ROM
    .PIO_OUT_INIT_VALUE(2)               // INIT value for PIO-- make reconfig_rom1_rom0bar =1 to select 1G mode
    ) th_master_bfm (
    .clk            (phy_mgmt_clk),
    .reset          (phy_mgmt_clk_reset),
    .av_write       (phy_mgmt_write),
    .av_read        (phy_mgmt_read),
    .av_address     ({conwar, phy_mgmt_address}),
    .av_writedata   (phy_mgmt_writedata),
    .av_readdata    (phy_mgmt_readdata),
    .av_waitrequest (phy_mgmt_waitrequest),
    .pio_out        ({conwar2,
                      reconfig_req[1],         // bit 11
                      reconfig_rom1_rom0bar[1],// bit 10
                      testcase_fail,           // bit 9
                      reset_gige_sync,         // bit 8
                      reset_rmt_rc_bndl,       // bit 7
                      reset_rc_bundle,         // bit 6
                      start_xgmii_test,        // bit 5
                      rx_sync_lock_ff2,        // bit 4
                      gige_sync_start,         // bit 3
                      reconfig_req[0],         // bit 2
                      reconfig_rom1_rom0bar[0],// bit 1
                      master_bfm_done}),       // bit 0
    .pio_in         ({9'b0,
                      reconfig_busy[1],      // bit 6
                      ch_pass,               // bit 5
                      test_pass,             // bit 4
                      1'b0,                  // bit 3 (placeholder)
                      tx_ready,              // bit 2
                      rx_ready,              // bit 1
                      reconfig_busy[0]})     // bit 0
    );
`undef MGMT_PROGRAM_TASK

// check mgmt master program results and finish
  always @(master_bfm_done)
  begin
    if (master_bfm_done) begin
      $display("\nInfo: Test Harness master_bfm_done = 1; Test Harness mgmt program done at time %t", $realtime);
      #100ns
      $display("Test case Passed");
      $finish();
      end
  end // always

  always @(testcase_fail)
  begin
    if (testcase_fail) begin
      $display("\nInfo: Test Harness testcase_fail= 1; Test Harness mgmt program done at time %t", $realtime);
      #100ns
      $display("Test case failed: ERROR");
      $finish();
      end
  end // always
`ifdef ALTERA_RESERVED_XCVR_FULL_KR_TIMERS
`else // not FULL_KR_TIMERS
  initial
    begin
    //  #15us
      #TEST_HARNESS_TIMOUT
      $display("Test case failed: TIMEOUT");
      $finish();
  end
`endif // FULL_KR_TIMERS


//============================================================================
// Instantiate the XGMII gen/chk
//============================================================================
   xgmii_src tx_generator (
         .clock(xgmii_tx_clk),
         .reset(phy_mgmt_clk_reset| start_xgmii_test),
         .frame_sof(frame_sof_reg),
         .frame_length(frame_length_reg),
         .frame_type(frame_type_reg),
         .frame_ifg(frame_ifg_reg),
         .frame_constant(frame_constant_reg),
         .frame_done(frame_done),
         .xgmii_tx_clk(xgmii_tx_clk_from_xgmii_src),
         .xgmii_tx(xgmii_tx_dc),
         .xgmii_rx_clk(xgmii_rx_clk),
         .xgmii_rx(xgmii_rx_dc),
         .xgmii_rx_d_mon(xgmii_rx_d_mon),
         .xgmii_rx_c_mon(xgmii_rx_c_mon),
         .xgmii_tx_d_mon(xgmii_tx_d_mon),
         .xgmii_tx_c_mon(xgmii_tx_c_mon)
        ); // module xgmii_src

   xgmii_sink rx_checker (
          .clock(xgmii_tx_clk),
          .reset(phy_mgmt_clk_reset| start_xgmii_test),
          .xgmii_tx_clk(xgmii_tx_clk_from_xgmii_src),
          .xgmii_tx(xgmii_tx_dc),
          .xgmii_rx_clk(xgmii_rx_clk),
          .xgmii_rx(xgmii_rx_dc),
          .test_done(test_done),
          .rx_ready(rx_ready),
          .fifo_full(fifo_full),
          .fifo_empty(),
          .read_stored_data(),
          .checker_pass(checker_pass),
          .rx_mismatch(rx_mismatch),
          .idle_state(idle),
          .xgmii_rx_d_mon(xgmii_rx_d_mon),
          .xgmii_rx_c_mon(xgmii_rx_c_mon),
          .xgmii_tx_d_mon(xgmii_tx_d_mon),
          .xgmii_tx_c_mon(xgmii_tx_c_mon)
    ); // module xgmii_sink





//============================================================================
// GMII GEN and CHECKER
//============================================================================
//generate  

//if (SYNTH_GMII) begin : GMII_GEN_CHK
gige_pattern_gen #(
.PREAMBLE_VAL   (8'h55),
.SFD_VAL        (8'hD5),
.PREAMBLE_REPEAT(6'h7),
.DATA_BYTES     (12'h100) ,
.IPG_BYTES      (8'h10),
.PACKETS        (8'h10)  /// from 1 to 256
) gige_pattern_gen_inst ( 
.gmii_tx_clk        (tx_clkout_1g),
.phy_mgmt_clk_reset (phy_mgmt_clk_reset| reset_gige_sync ),
.gmii_start         (gige_sync_start),
.gmii_tx_d          (gmii_tx_d          ),
.gmii_tx_en         (gmii_tx_en         ),
.gmii_tx_err        (gmii_tx_err        ),
.packet_complete    (packet_complete_gen) 
);

gige_pattern_chk  #(
.PREAMBLE_VAL   (8'h55),
.SFD_VAL        (8'hD5),
.PREAMBLE_REPEAT(6'h7),
.DATA_BYTES     (12'h100),
.IPG_BYTES      (8'h10),
.PACKETS        (8'h10)  /// from 1 to 256
) gige_pattern_chk_inst ( 
.gmii_rx_clk       (tx_clkout_1g), // gige pattern checker uses tx_clkout - GMII has RM fifo
.phy_mgmt_clk_reset(phy_mgmt_clk_reset| reset_gige_sync ),
.gmii_start        (1'b1),
.gmii_rx_d         (gmii_rx_d         ),
.gmii_rx_dv        (gmii_rx_en        ), // need to modify module to replace rx_en with rx_dv
.packet_complete   (packet_complete_chk), 
.rx_mismatch       (rx_mismatch_gmii  ) 
);

assign ch_pass = packet_complete_chk & packet_complete_gen & !rx_mismatch_gmii ;
/*end
// **** CAN REMOVE THIS PORTION OF IF GENERATE IF YOU WANT.
else begin : PRBS_GEN_CHK_W_SYNC_GENC

/// RAW PCS PATTERN - NOT GMII SPECIFIC
	  // PRBS Gen ch0
	  prbs_generator prbs_generator_ch0_inst (.clk (tx_clkout),
//	  atso_prbs_generator prbs_generator_ch0_inst (.clk (tx_clkout),
//						 .nreset (word_alignment_status_wire & !reconfig_busy),
						 .nreset (sync_aquired),
						 .insert_error(1'b0),
						 .pause(1'b0),
						 .xaui_word_align(1'b1),
						 .dout (tx_parallel_data[7:0]));
	  defparam prbs_generator_ch0_inst.PRBS_INITIAL_VALUE = `PATTERN;
	  defparam prbs_generator_ch0_inst.DATA_WIDTH = `BUS_WIDTH;
	  defparam prbs_generator_ch0_inst.PRBS = 23;

	  
	  
	  // PRBS Verifier ch0
	  prbs_checker prbs_verify_ch0_inst(.lock(ch_pass),
//	  atso_prbs_checker prbs_verify_ch0_inst(.lock(ch_pass),
						.errorFlag(error_flag_ch),
						.clk(rx_clkout),
//						.nreset(word_alignment_status_wire & !reconfig_busy),
						.nreset(sync_aquired),
						 .pause(1'b0),
						.dataIn(rx_parallel_data[7:0]));
	  defparam prbs_verify_ch0_inst.PRBS_INITIAL_VALUE = `PATTERN;
	  defparam prbs_verify_ch0_inst.DATA_WIDTH = `BUS_WIDTH;
	  defparam prbs_verify_ch0_inst.PRBS = 23;
	  defparam prbs_verify_ch0_inst.NUM_CYCLES_FOR_LOCK = 20;


   ////// TX control code logic
          always @(posedge tx_clkout or posedge phy_mgmt_clk_reset)
             begin
					if (phy_mgmt_clk_reset)
					begin
					  tx_datak <= 0;
					end
					else
					  begin
						if ((tx_parallel_data[7:0] == `PATTERN) && (!word_alignment_status_wire))
						 begin
								tx_datak <= 1'b1;
						 end
						else
						 begin
								tx_datak <= 1'b0;  
						 end // else: !if(!word_alignment_status_wire[0])
					  end	
				end


assign word_alignment_status_wire = rx_sync_lock_ff2 & rx_ready_gmii ;

assign gmii_tx_d  = sync_aquired ? tx_parallel_data : gmii_tx_d1;
assign gmii_tx_en = sync_aquired ? tx_datak         : gmii_tx_en1;
assign gmii_tx_err = 0 ;

assign rx_parallel_data = gmii_rx_d ;
assign rx_datak         = gmii_rx_en ;

assign match = (gmii_rx_d == `PATTERN ) ? 1'b1 :1'b0 ;



gige_sync_fsm gige_sync_fsm (

.gmii_tx_clk       (tx_clkout          ),      						// 1g-tx clk from PHY
.phy_mgmt_clk_reset(phy_mgmt_clk_reset | reset_gige_sync ),   	//  master reset
.gige_sync_start   (gige_sync_start		),       					// start signal for FSM
.sync_aquired      (sync_aquired       ),    						//  done signal indicating 3 synchronization sets have been sent 
.sync_d            (gmii_tx_d1         ),          				// gige data 
.sync_k            (gmii_tx_en1        )           				// gige control
);

end


endgenerate
*/
endmodule
