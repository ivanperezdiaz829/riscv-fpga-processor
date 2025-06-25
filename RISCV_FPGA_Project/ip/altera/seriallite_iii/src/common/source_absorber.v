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


`timescale 1ns/1ns

module source_absorber #
(
   parameter                  lanes = 4,
   parameter                  ecc_enable = 0
)
(
   // Clocks and reset
   input                      user_clock,
   input                      user_clock_reset,
   input					  interface_clock,
   input					  interface_reset,

   // Streaming data interface

   input    [(lanes*64)-1:0]  si_data,
   input    [3:0]             si_sync,
   input                      si_valid,
   input                      si_start_of_burst,
   input                      si_end_of_burst,
   input                      read_en,

   // Adaptation Interface
   output   [(lanes*64)-1:0]  adpt_data,
   output   [3:0]             adpt_sync,
   output                     adpt_valid,
   output                     adpt_start_of_burst,
   output                     adpt_end_of_burst,
   
   // status signals
   
   output		    absorber_fifo_overflow,
   output   [1:0]           ecc_status
   
);

   
   wire             fifo_read;
   wire 	    fifo_empty ;
   wire             absorber_fifo_full ;
   wire             user_clock_reset_sync;
   wire             fifo_valid_out;

   wire                 dc_fifo_empty_int;
   wire  [2*lanes:0]    ecc_fifo_empty_int;

   assign   adpt_valid = (ecc_enable == 1) ? fifo_valid_out : ~dc_fifo_empty_int;
   //assign   adpt_valid = ~fifo_empty;
   assign   absorber_fifo_overflow = absorber_fifo_full & si_valid;

   assign   fifo_read = read_en & ((ecc_enable == 1) ? (~(|ecc_fifo_empty_int)) : (~dc_fifo_empty_int));

	// User Clock Reset Synchronizer
    dp_sync #
    (
      .dp_width(1),
      .dp_reset(1'b1)
    )
    interface_clk_reset_sync
    (
      .async_reset_n(~user_clock_reset),
      .sync_reset_n(1'b1),/* synthesis altera_attribute="disable_da_rule=r105" */ 
      .clk(user_clock),
      .sync_ctrl(2'd2),
      .d(1'b0),
      .o(user_clock_reset_sync)
    );
	

//
     // Lane rate adaptation FIFO instantiation
     //
     genvar lane;
     wire [2*lanes:0] err, uncor;

     assign   ecc_status = {|err, |uncor};


generate
 if (ecc_enable) begin : ecc_p     

    // delay the data-valid and fifo empty signals
    delay_regs d (
        .clk(interface_clock),
	.din({fifo_read, |ecc_fifo_empty_int}),
	.dout({fifo_valid_out, fifo_empty})
    );
    defparam d .LATENCY = 3;
    defparam d .WIDTH = 2;


    for (lane = 0; lane < 2*lanes; lane = lane + 1) begin : ecc_lanes
        
        dcfifo_s5m20k dcfifo_ecc_d 
        (
            .aclr       (user_clock_reset_sync),

            .wclk       (user_clock),
            .wdata      (si_data[32*(lane+1)-1:32*lane]),
            .wreq       (si_valid),

            .rclk       (interface_clock),
            .rdata      (adpt_data[32*(lane+1)-1:32*lane]),
            .rreq       (fifo_read),
            .rempty     (ecc_fifo_empty_int[lane]),

            .ecc_status ({err[lane], uncor[lane]})
        );
        defparam dcfifo_ecc_d .WIDTH = 32;
        defparam dcfifo_ecc_d .DISABLE_WUSED = 1'b1;
        defparam dcfifo_ecc_d .DISABLE_RUSED = 1'b1;

    end     
     
        dcfifo_s5m20k dcfifo_ecc_ctrl 
        (
            .aclr       (user_clock_reset_sync),

            .wclk       (user_clock),
            .wdata      ({si_sync[3:0], si_start_of_burst, si_end_of_burst}),
            .wreq       (si_valid),

            .wfull      (absorber_fifo_full), 

            .rclk       (interface_clock),
            .rdata      ({adpt_sync[3:0], adpt_start_of_burst, adpt_end_of_burst}),
            .rreq       (fifo_read),
            .rempty     (ecc_fifo_empty_int[2*lanes]),

            .ecc_status ({err[2*lanes], uncor[2*lanes]})
        );
        defparam dcfifo_ecc_ctrl .WIDTH = 32;
        defparam dcfifo_ecc_ctrl .DISABLE_WUSED = 1'b1;
        defparam dcfifo_ecc_ctrl .DISABLE_RUSED = 1'b1;

  end
  else begin
     dcfifo #
     (
        .intended_device_family("Stratix V"),
        .lpm_numwords(16),
        .lpm_showahead("ON"),
        .lpm_type("dcfifo"),
        .lpm_width((lanes*64)+6),
        .lpm_widthu($clog2(16)),
        .overflow_checking("ON"),
        .rdsync_delaypipe(5),
        .read_aclr_synch("ON"),
        .underflow_checking("ON"),
        .use_eab("ON"),
        .write_aclr_synch("ON"),
        .wrsync_delaypipe(5)
     )
     lane_fifo
     (
        .aclr(user_clock_reset_sync),
        .wrclk(user_clock),
        .wrreq(si_valid),
        .data({si_data[((lanes*64)-1):0], si_sync[3:0], si_start_of_burst, si_end_of_burst}),
        .wrempty(),
        .wrfull(absorber_fifo_full), // error condition
        .wrusedw(),
        .rdclk(interface_clock), 
        .rdreq(fifo_read),
        .q({adpt_data[((lanes*64)-1):0], adpt_sync[3:0], adpt_start_of_burst, adpt_end_of_burst}),
        .rdempty(dc_fifo_empty_int),
        .rdfull(),
        .rdusedw()
     );
  end
endgenerate

endmodule		 
