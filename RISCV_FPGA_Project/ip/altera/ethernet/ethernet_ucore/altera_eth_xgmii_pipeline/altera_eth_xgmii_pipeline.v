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


`timescale 1ns / 1ns
module altera_eth_xgmii_pipeline(

    //Common clock and Reset
    clk,
    reset,
    
    // XGMII data
    xgmii_sink_data,
    xgmii_src_data
    
);

    // =head1 GLOBAL PARAMETERS

    // =head2 Avalon Streaming
    // =head1 LOCAL PARAMETERS
    localparam XGMII_BITSPERSYMBOL      = 9; // Streaming Data symbol width in bits
    localparam XGMII_SYMBOLSPERBEAT     = 8; // Streaming Number of symbols per word
    localparam XGMII_DATAWIDTH          = XGMII_BITSPERSYMBOL * XGMII_SYMBOLSPERBEAT;
    
    // Symbols used in the core
    // Symbols that represent data on the lane
    localparam SYMBOL_IDLE              = 8'h07;




    // =head1 PINS
    // =pod 
    // A
    // =cut

    // =head2 Clock Interface
    input                                                clk;
    input                                                reset;	  

    // =head2 XGMII DataIn (Sink) Interface
    input       [(XGMII_DATAWIDTH)-1:0]                  xgmii_sink_data;

    // =head2 XGMII DataOut (Source) Interface
    // =cut
    output reg  [(XGMII_DATAWIDTH)-1:0]                  xgmii_src_data;
    
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            xgmii_src_data <= {8{1'b1, SYMBOL_IDLE}};
        end
        else begin
            xgmii_src_data <= xgmii_sink_data;
        end
    end
    
endmodule
// =head1 SEE AL
