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
module alt_xcvr_reconfig_offset_cancellation_civ
#(
    parameter device_family = "Cyclone IV",      
    parameter number_of_reconfig_interfaces = 1
)
(
    input wire reconfig_clk,        // this will be the reconfig clk
    input wire reset,
    
    //avalon MM slave
    input wire offset_cancellation_address,             // MM address
    input wire [31:0] offset_cancellation_writedata,
    input wire offset_cancellation_write,
    input wire offset_cancellation_read,
    
    //output MM slave
    output wire [31:0] offset_cancellation_readdata,      // from MM
    
    output wire offset_cancellation_done,
      
    // input from base_reconfig
    input wire offset_cancellation_irq_from_base,
    input wire offset_cancellation_waitrequest_from_base,
    output wire offset_cancellation_waitrequest,
      
    // output to base_reconfig
    // Avalon MM Master
    output wire [4:0] offset_cancellation_address_base,   // 3 bit MM
    output wire [31:0] offset_cancellation_writedata_base,  
    output wire offset_cancellation_write_base,                         // start write to GXB
    output wire offset_cancellation_read_base,                          // start read from GXB
    
    // input from base reconfig
    input wire [31:0] offset_cancellation_readdata_base,         // data from read command
    
    // Avalon ST
    input wire [number_of_reconfig_interfaces*16 - 1 : 0] testbus_data 
);
        
 	alt_xcvr_reconfig_offset_cancellation_tgx_civ 
        #(
    	    .device_family(device_family),      
            .number_of_reconfig_interfaces(number_of_reconfig_interfaces)
        ) offset_cancellation_tgx 
        (
            .reconfig_clk(reconfig_clk),
            .reset(reset),
            .offset_cancellation_address(offset_cancellation_address),
            .offset_cancellation_writedata(offset_cancellation_writedata),
            .offset_cancellation_write(offset_cancellation_write),
            .offset_cancellation_read(offset_cancellation_read),
            .offset_cancellation_readdata(offset_cancellation_readdata),
            .offset_cancellation_done(offset_cancellation_done),
            .offset_cancellation_irq_from_base(offset_cancellation_irq_from_base),
            .offset_cancellation_waitrequest_from_base(offset_cancellation_waitrequest_from_base),
            .offset_cancellation_waitrequest(offset_cancellation_waitrequest),
            .offset_cancellation_address_base(offset_cancellation_address_base),
            .offset_cancellation_writedata_base(offset_cancellation_writedata_base),  
            .offset_cancellation_write_base(offset_cancellation_write_base),
            .offset_cancellation_read_base(offset_cancellation_read_base),
            .offset_cancellation_readdata_base(offset_cancellation_readdata_base),
            .testbus_data(testbus_data)
        );

endmodule


