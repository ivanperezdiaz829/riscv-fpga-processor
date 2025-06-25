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
// baeckler - 03-28-2010

module alt_e100_lock_timer (
	input clk,
	input arst,
	input fully_locked,
	output reg [23:0] locked_time
);

parameter USEC_MAX_VAL = 9'd48; // clk MHz minus 2

reg [8:0] usec_cntr;
reg usec_max;
always @(posedge clk or posedge arst) begin
    if (arst) begin
        usec_max <= 0;
        usec_cntr <= 0;
    end else begin
        usec_max <= (usec_cntr == USEC_MAX_VAL);
        if (usec_max || !fully_locked) usec_cntr <= 0;
        else usec_cntr <= usec_cntr + 1'b1;
    end
end

reg [9:0] msec_cntr;
reg msec_max;
always @(posedge clk or posedge arst) begin
    if (arst) begin
        msec_max <= 0;
        msec_cntr <= 0;
    end else begin
        msec_max <= (msec_cntr == 10'd998);
        if ((usec_max && msec_max) || !fully_locked) msec_cntr <= 0;
        else if (usec_max) msec_cntr <= msec_cntr + 1'b1;
    end
end

reg [9:0] sec_cntr;
reg sec_max;
always @(posedge clk or posedge arst) begin
    if (arst) begin
        sec_max <= 0;
        sec_cntr <= 0;
    end else begin
        sec_max <= (sec_cntr == 10'd998);
        if ((sec_max && msec_max && usec_max) || !fully_locked) sec_cntr <= 0;
        else if (usec_max && msec_max) sec_cntr <= sec_cntr + 1'b1;
    end
end

// monitor locked time in seconds
always @(posedge clk or posedge arst) begin
    if (arst) begin
        locked_time <= 0;
    end else begin
        if (!fully_locked) locked_time <= 0;
        else if (sec_max && msec_max && usec_max) locked_time <= locked_time + 1'b1;
    end
end

endmodule
