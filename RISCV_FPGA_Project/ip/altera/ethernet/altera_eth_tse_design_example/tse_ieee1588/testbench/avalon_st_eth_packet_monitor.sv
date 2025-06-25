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


`ifndef AVALON_ST_ETH_PACKET_MONITOR__SV
`define AVALON_ST_ETH_PACKET_MONITOR__SV

`include "eth_mac_frame.sv"

`timescale 1ns / 1ns

// Monitor the Avalon-ST interface signals and display the packets
module avalon_st_eth_packet_monitor(
    clk,
    reset,
    
    startofpacket,
    endofpacket,
    valid,
    ready,
    data,
    empty,
    error
);
    // Width of error signals
    parameter  ST_ERROR_W           = 5;
    
    // Width of empty signals
    parameter  ST_EMPTY_W           = 3;
    
    // Width of each symbol
    parameter  ST_SYMBOL_W          = 8;
    
    // Number of symbols for beat
    parameter  ST_NUMSYMBOLS        = 1;
    
    // Width of data signals
    localparam ST_DATA_W            = ST_SYMBOL_W * ST_NUMSYMBOLS;
    
    
    
    // Port lists
    input  wire                     clk;
    input  wire                     reset;
    
    input  wire                     startofpacket;
    input  wire                     endofpacket;
    input  wire                     valid;
    input  wire                     ready;
    input  wire [ST_DATA_W - 1:0]   data;
    input  wire [ST_EMPTY_W - 1:0]  empty;
    input  wire [ST_ERROR_W - 1:0]  error;
    
    
    
    // Events
    event frame_complete;
    
    
    
    // Internal Variables
    // Frame contents
    bit [ST_SYMBOL_W - 1:0] frame_data[];
    eth_mac_frame mac_frame_q[$];
    eth_mac_frame mac_frame;
    
    // Is the monitor processing packet?
    bit packet_in_progress;
    
    int unsigned i;
    int unsigned frame_data_size_prev;
    
    always @(posedge clk or posedge reset) begin
        // Clear previous frame_data
        if(reset) begin
            packet_in_progress = 0;
        end
        
        // Start monitoring on valid start of packet
        if(startofpacket && valid && ready) begin
            frame_data = new[0];
            packet_in_progress = 1;
        end
        
        // Get packet content when there is valid transaction
        if(valid && ready && packet_in_progress) begin
            frame_data_size_prev = frame_data.size();
            
            // Allocate additional space for new valid transaction
            frame_data = new[frame_data_size_prev + ST_NUMSYMBOLS](frame_data);
            
            // Store the content byte-by-byte extracted from data signal
            for(i = 0; i < ST_NUMSYMBOLS; i++) begin
                frame_data[frame_data_size_prev + i] = data >> (ST_SYMBOL_W * (ST_NUMSYMBOLS - i - 1));
            end
            
            // Truncate number of symbols which are indicated by empty at the end of packet
            if(endofpacket && (empty != 0)) begin
                frame_data = new[frame_data.size() - empty](frame_data);
            end
            
            // Stop monitoring and display packet content
            if(endofpacket) begin
                packet_in_progress = 0;
                
                // Copy the content of collected frame data into the MAC Frame object
                mac_frame = new();
                mac_frame.frame_content = new[frame_data.size()](frame_data);
                // for(i = 0; i < frame_data.size(); i++) begin
                    // mac_frame.frame_content[i] = frame_data[i];
                // end
                mac_frame_q.push_back(mac_frame);
                
                // Display time capture the frame
                $display("%0t : Frame monitored by %m", $time());
                $display("%0t : Frame length : %0d", $time(), frame_data.size());
                
                // Display content of the frame
                $display(get_frame_content(frame_data));  

                -> frame_complete;
            end
        end
    end
    
    // Function returning string which contain formatted packet content
    function automatic string get_frame_content(bit [ST_SYMBOL_W - 1:0] frame_data[]);
        int unsigned i;
        
        string str;
        str = "";
        
        // Display line break
        for(i = 0; i < 16; i++) begin
            if(i == 0) begin
                str = {str, $psprintf("\t--------")};
            end
            
            if(i % 8 == 0) begin
                str = {str, $psprintf("-")};
            end
            
            str = {str, $psprintf("---")};
        end
        
        // Display header
        for(i = 0; i < 16; i++) begin
            if(i == 0) begin
                str = {str, $psprintf("\n\t      | ")};
            end
            
            if(i % 8 == 0) begin
                str = {str, $psprintf(" ")};
            end
            
            str = {str, $psprintf("%02d ", i)};
        end
        
        // Display line break
        for(i = 0; i < 16; i++) begin
            if(i == 0) begin
                str = {str, $psprintf("\n\t--------")};
            end
            
            if(i % 8 == 0) begin
                str = {str, $psprintf("-")};
            end
            
            str = {str, $psprintf("---")};
        end
        
        // Display content
        for(i = 0; i < frame_data.size(); i++) begin
            
            if(i % 16 == 0) begin
                str = {str, $psprintf("\n\t %4x | ", i)};
            end
            
            if(i % 8 == 0) begin
                str = {str, $psprintf(" ")};
            end
            
            str = {str, $psprintf("%2x ", frame_data[i])};
        end
        
        // Display line break
        for(i = 0; i < 16; i++) begin
            if(i == 0) begin
                str = {str, $psprintf("\n\t--------")};
            end
            
            if(i % 8 == 0) begin
                str = {str, $psprintf("-")};
            end
            
            str = {str, $psprintf("---")};
        end
        
        str = {str, $psprintf("\n")};
        
        return str;
    endfunction
    
endmodule

`endif
