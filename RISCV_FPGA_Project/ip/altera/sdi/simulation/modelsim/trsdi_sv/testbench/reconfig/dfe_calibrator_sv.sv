// (C) 2001-2011 Altera Corporation. All rights reserved.
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


// DFE Calibrator
//
// This module outputs the DFE offset cancellation register 
// data for one test bus input. 
// 
// The module calculates the average offset that causes the
// test bus signal to toggle or make a single transition.
// 
// The offset count is an input. The output is the offset count 
// until the average is calculated. The average is the final output.
// 
//
// $Header$

`timescale 1 ns / 1 ps

module dfe_calibrator_sv (
input  wire       clk,
input  wire       reset,

input  wire       enable,          // cycle enable
input  wire [4:0] count,           // offset count (linear)
input  wire       count_tc,        // offset counter terminal count

input  wire       testbus,         // dfe testbus signal
input  wire       testbus_ready,   // dfe testbus signal stable
  
output reg  [3:0] offset,          // offset cancellation value)
output wire       done             // calibration done
); 

reg  [2:0]        state;
reg  [4:0]        low_offset;
reg  [4:0]        last_offset;
wire [5:0]        temp;
wire [5:0]        temp2;
reg  [4:0]        average_offset;
reg  [4:0]        linear_offset;
wire              testbus_toggle;
(*altera_attribute =
" -name SYNCHRONIZATION_REGISTER_CHAIN_LENGTH 3;  -name AUTO_SHIFT_REGISTER_RECOGNITION OFF"  *)
reg  [2:0]        testbus_toggle_ff;
(*altera_attribute = 
" -name SYNCHRONIZATION_REGISTER_CHAIN_LENGTH 3;  -name AUTO_SHIFT_REGISTER_RECOGNITION OFF"  *)
reg  [2:0]        testbus_ff;
wire              testbus_toggle_sync;
wire              testbus_sync;
reg               last_testbus;
wire              testbus_edge; 

parameter NO_ACTIVITY_OFFSET = 4'h9; // offset count for no toggling or edge

// state assigments
localparam [2:0] PRELOAD     = 3'h0;
localparam [2:0] LOW_NOEDGE  = 3'h1;
localparam [2:0] LOW         = 3'h2;
localparam [2:0] HIGH        = 3'h3;
localparam [2:0] AVERAGE     = 3'h4;

// control
always @(posedge clk)
begin
    if (reset)
        state <= PRELOAD;
    else
       case (state)
         // save initial testbus state
           PRELOAD:     if (enable && !testbus_toggle_sync)
                           state <= LOW;
                       else if (enable && testbus_toggle_sync)
                           state <= LOW_NOEDGE;
       
           // toggle detected during preload -- preload not valid
           // don't look for a single edge
           LOW_NOEDGE: if (enable && testbus_toggle_sync && !count_tc)
                           state <= HIGH;
                       else if (enable && count_tc)
                           state <= AVERAGE;
        
           // no toggle detected during preload 
           // single edge could be possible    
           LOW:        if (enable && testbus_toggle_sync && !count_tc)
                           state <= HIGH;
                       else if ((enable && count_tc) || (enable && testbus_edge ))
                           state <= AVERAGE;
                                
           // wait for DFE signal to stop toggling     
           HIGH:       if ((enable && !testbus_toggle_sync) || (enable && count_tc))
                           state <= AVERAGE;
                                     
           // set final calibration value           
           AVERAGE:    state <= AVERAGE;
           
           default: state <= PRELOAD;     
       endcase
end

// done
assign done = (state == AVERAGE);

// low offset count
always @(posedge clk)
begin
    if ((enable && (state == LOW_NOEDGE) && testbus_toggle_sync) ||
        (enable && (state == LOW)        && testbus_toggle_sync))
        low_offset <=  count; 
end

// last offset count
always @(posedge clk)
begin
    if (enable)
        last_offset <= count; 
end 

// interim values 
assign temp  = low_offset + last_offset;
assign temp2 = low_offset + count; 

// average offset
always @(posedge clk)
begin
    // normal toggle
    if (enable && (state == HIGH) && !testbus_toggle_sync)
        average_offset <= temp[4:1];
    
    //  normal toggling continues at terminal count
    else if (enable && (state == HIGH) && testbus_toggle_sync && count_tc)
        average_offset <= temp2[4:1];
    
    // toggling starts at end
    else if ((enable && (state == LOW)        && testbus_toggle_sync && count_tc) ||
             (enable && (state == LOW_NOEDGE) && testbus_toggle_sync && count_tc))  
        average_offset <= count;
        
    // no activity
    else if ((enable && (state == LOW) && !testbus_edge && !testbus_toggle_sync && count_tc) ||
             (enable && (state == LOW_NOEDGE) && !testbus_toggle_sync && count_tc)) 
        average_offset <= NO_ACTIVITY_OFFSET;
    
    // single edge
    else if (enable && (state == LOW) && testbus_edge) 
       average_offset <= count;
        
end
   
// multiplex count and average
assign linear_offset = (state == AVERAGE) ? average_offset : count;
 
// encode offset 
 always @(posedge clk)
 begin 
     case (linear_offset)
         5'h00:    offset <= 4'he;
         5'h01:    offset <= 4'hf; 
         5'h02:    offset <= 4'he; 
         5'h03:    offset <= 4'hd; 
         5'h04:    offset <= 4'hc; 
         5'h05:    offset <= 4'hb; 
         5'h06:    offset <= 4'ha;
         5'h07:    offset <= 4'h9;
         5'h08:    offset <= 4'h8;
         5'h09:    offset <= 4'h0;
         5'h0a:    offset <= 4'h1;
         5'h0b:    offset <= 4'h2;
         5'h0c:    offset <= 4'h3;
         5'h0d:    offset <= 4'h4;
         5'h0e:    offset <= 4'h5;
         5'h0f:    offset <= 4'h6;
         5'h10:    offset <= 4'h7;
         default:  offset <= 4'h0; 
     endcase;
end
			
// test bus toogle detection
alt_cal_dfe_edge_detect inst_alt_cal_dfe_edge_detect(
  .reset      (testbus_ready),
  .testbus    (testbus),
  .pd_edge    (testbus_toggle)
);

// synchronize
always @(posedge clk)
begin
    testbus_toggle_ff <= {testbus_toggle_ff[1:0], testbus_toggle};
    testbus_ff        <= {testbus_ff[1:0], testbus};
end 

assign testbus_toggle_sync = testbus_toggle_ff[2];
assign testbus_sync        = testbus_ff[2];

// testbus edge detection
always @(posedge clk)
begin
    if (enable) 
        last_testbus <= testbus_sync;
end 
 
assign testbus_edge = last_testbus ^ testbus_sync; 
    
endmodule    
