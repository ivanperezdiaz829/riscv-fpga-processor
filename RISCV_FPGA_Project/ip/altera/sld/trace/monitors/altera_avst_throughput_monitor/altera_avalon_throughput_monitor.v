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


module altera_avalon_throughput_monitor #(
   parameter 
   BC_W            = 5
   ) (
   input              avs_clock,
   input              if_clock,
   input              avs_reset,
   input              if_reset,

   input              if_read,
   input              if_write,
   input   [BC_W-1:0] if_burstcount,
   input              if_waitrequest,
   input              if_readdatavalid,

   //avalon count interface
   input       [ 1:0] avs_address,
   input              avs_read,
   output      [31:0] avs_readdata,
   output             avs_waitrequest,

   //avalon status interface
   input        [1:0] ctl_address, //not really used, but keeps qsys happy
   output      [31:0] ctl_readdata
   );

localparam   MANUFACTURER_ID = 16'h03,
             REVISION_NUM    = 16'h01;

assign ctl_readdata = {MANUFACTURER_ID, REVISION_NUM};

wire        togl_to_pmon, togl_from_pmon;
wire [31:0] count_data;
wire [ 1:0] reg_address;

   //module provides read access to all counters
   altera_pmon_count_csr count_csr (
      .avs_clock             (avs_clock),
      .avs_reset             (avs_reset),
      .avs_read              (avs_read),
      .avs_address           (avs_address),
      .avs_waitrequest       (avs_waitrequest),
      .avs_readdata          (avs_readdata),

      .toglout               (togl_to_pmon),
      .toglin                (togl_from_pmon),
      .address               (reg_address),
      .count_data            (count_data)
      );


   //the counters themselves
   altera_pmon_counters #(.BC_W (BC_W)) pcounters (
      .if_clock              (if_clock),
      .if_reset              (if_reset),
      .if_read               (if_read),
      .if_write              (if_write),
      .if_burstcount         (if_burstcount),
      .if_waitrequest        (if_waitrequest),
      .if_readdatavalid      (if_readdatavalid),

      .address               (reg_address),
      .toglin                (togl_to_pmon),
      .toglout               (togl_from_pmon),
      .count_data            (count_data)
      );

endmodule
