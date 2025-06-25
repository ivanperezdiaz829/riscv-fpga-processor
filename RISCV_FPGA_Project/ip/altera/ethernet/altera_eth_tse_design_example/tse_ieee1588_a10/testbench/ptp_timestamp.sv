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


`ifndef PTP_TIMESTAMP__SV
`define PTP_TIMESTAMP__SV

`include "avalon_if_params_pkg.sv"

// Get the Avalon interface parameters definition from the package
import avalon_if_params_pkt::*;
    
    
// Class file to handle creation of PTP Timestamp
class ptp_timestamp;
    
    bit egress_timestamp_valid;
    bit ingress_timestamp_valid;
    bit ingress_timestamp_format;
    bit timestamp_req_valid;
    
    bit[47:0] egress_time_96b_second;
    bit[31:0] egress_time_96b_nsecond;
    bit[15:0] egress_time_96b_fnsecond;
    bit[47:0] egress_time_64b_nsecond;
    bit[15:0] egress_time_64b_fnsecond;
    bit[TIMESTAMP_FINGERPRINT_WIDTH-1:0]  egress_fingerprint;
    
    bit[47:0] ingress_time_96b_second;
    bit[31:0] ingress_time_96b_nsecond;
    bit[15:0] ingress_time_96b_fnsecond;
    bit[47:0] ingress_time_64b_nsecond;
    bit[15:0] ingress_time_64b_fnsecond;
    bit[TIMESTAMP_FINGERPRINT_WIDTH-1:0]  ingress_fingerprint;
   
endclass

`endif
