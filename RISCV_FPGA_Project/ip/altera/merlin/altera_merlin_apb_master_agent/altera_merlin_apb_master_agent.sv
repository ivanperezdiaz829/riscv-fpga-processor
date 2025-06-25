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


// (C) 2001-2012 Altera Corporation. All rights reserved.
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


// $Id: //acds/rel/13.1/ip/merlin/altera_merlin_apb_master_agent/altera_merlin_apb_master_agent.sv#1 $
// $Revision: #1 $
// $Date: 2013/08/11 $
// $Author: swbranch $

//-------------------------------------------------
// APB master agent
// 
// Accepts APB transactions and procedures Merlin Packet
// Accepts response packet, converts back to APB transactions
//-------------------------------------------------

`timescale 1 ps / 1 ps
module altera_merlin_apb_master_agent 
  #(
    // ---------------------
    // APB master parameters
    // ---------------------
    parameter ADDR_WIDTH                = 32,
    parameter DATA_WIDTH                = 32,
    // ------------------------------
    // Merlin packet field parameters
    // ------------------------------
    parameter PKT_PROTECTION_H          = 80,
    parameter PKT_PROTECTION_L          = 80,
    parameter PKT_BEGIN_BURST           = 81,
    parameter PKT_BURSTWRAP_H           = 79,
    parameter PKT_BURSTWRAP_L           = 77,
    parameter PKT_BURST_SIZE_H          = 86,
    parameter PKT_BURST_SIZE_L          = 84,
    parameter PKT_BURST_TYPE_H          = 94,
    parameter PKT_BURST_TYPE_L          = 93,
    parameter PKT_BYTE_CNT_H            = 76,
    parameter PKT_BYTE_CNT_L            = 74,
    parameter PKT_ADDR_H                = 73,
    parameter PKT_ADDR_L                = 42,
    parameter PKT_TRANS_COMPRESSED_READ = 41,
    parameter PKT_TRANS_POSTED          = 40,
    parameter PKT_TRANS_WRITE           = 39,
    parameter PKT_TRANS_READ            = 38,
    parameter PKT_TRANS_LOCK            = 82,
    parameter PKT_TRANS_EXCLUSIVE       = 83,
    parameter PKT_DATA_H                = 37,
    parameter PKT_DATA_L                = 6,
    parameter PKT_BYTEEN_H              = 5,
    parameter PKT_BYTEEN_L              = 2,
    parameter PKT_SRC_ID_H              = 1,
    parameter PKT_SRC_ID_L              = 1,
    parameter PKT_DEST_ID_H             = 0,
    parameter PKT_DEST_ID_L             = 0,
    parameter PKT_THREAD_ID_H           = 88,
    parameter PKT_THREAD_ID_L           = 87,
    parameter PKT_CACHE_H               = 92,
    parameter PKT_CACHE_L               = 89,
    parameter PKT_DATA_SIDEBAND_H       = 105,
    parameter PKT_DATA_SIDEBAND_L       = 98,
    parameter PKT_QOS_H                 = 109,
    parameter PKT_QOS_L                 = 106,
    parameter PKT_ADDR_SIDEBAND_H       = 97,
    parameter PKT_ADDR_SIDEBAND_L       = 93,
    parameter PKT_RESPONSE_STATUS_H     = 111,
    parameter PKT_RESPONSE_STATUS_L     = 110,
	parameter PKT_ORI_BURST_SIZE_L      = 112,
	parameter PKT_ORI_BURST_SIZE_H      = 114,
    parameter ST_DATA_W                 = 115,
    parameter ST_CHANNEL_W              = 1,
    parameter AUTO_CLK_CLOCK_RATE       = "-1",
    parameter SYMBOL_WIDTH              = 8,
    parameter ID                        = 1,
    parameter SECURE_ACCESS_BIT         = 1'b1,
    // ---------------------
    // Derived Parameters
    // ---------------------
    parameter PKT_SRC_ID_W              = PKT_SRC_ID_H - PKT_SRC_ID_L + 1

  ) 
   (
    // ---------------------
    // APB slave signals
    // ---------------------
    input [ADDR_WIDTH-1:0]      paddr, 
    //input [2:0]                           pprot, 
    input                       psel, 
    input                       penable, 
    input                       pwrite,
    input [DATA_WIDTH-1:0]      pwdata,
    //input [(DATA_WIDTH/SYMBOL_WIDTH)-1:0] pstrb, 
    output reg                  pready,
    output reg [DATA_WIDTH-1:0] prdata,
    output reg                  pslverr,
    // ------------------------------
    // Addition signals for Debug APB
    // ------------------------------
    input                       paddr31,

    // --------------------------------
    // Avalon-ST command packet signals
    // --------------------------------
    output reg                  cp_valid, 
    input                       cp_ready,
    output reg [ST_DATA_W-1:0]  cp_data,
    output reg                  cp_startofpacket, 
    output reg                  cp_endofpacket,
    // ---------------------------------
    // Avalon-ST response packet signals
    // ---------------------------------
    input                       rp_valid,
    output reg                  rp_ready,
    input [ST_DATA_W-1:0]       rp_data,
    input [ST_CHANNEL_W-1:0]    rp_channel,
    input                       rp_startofpacket,
    input                       rp_endofpacket,
    // --------------------------
    // Clock , reset (reset high)
    // --------------------------
    input                       clk,
    input                       reset
    );
    // -------------------------------------------------------
    // APB only sends non-bursting and full-size transactions
    // Do some default assignments to construct  Merlin packet, 
    // to avoid QIS warning
    // -------------------------------------------------------
    localparam NUMSYMBOLS        = DATA_WIDTH/SYMBOL_WIDTH;
    localparam PKT_BYTE_CNT_W    = PKT_BYTE_CNT_H - PKT_BYTE_CNT_L + 1;
    localparam PKT_PROTECTION_W  = PKT_PROTECTION_H - PKT_PROTECTION_L + 1;
    localparam BURST_SIZE        = clogb2(NUMSYMBOLS);
    
    wire [31:0] bytecount_value_int  = NUMSYMBOLS;
    wire [31:0] burstwrap_value_int  = NUMSYMBOLS;
    wire [2:0]  burst_size           = BURST_SIZE[2:0];
    wire [31:0] id_int               = ID;
    
    // --------------------------             
    // State machine: declaration
    // --------------------------
    enum        
    {
     IDLE,       
     SEND_PACKET,
     RESPONSE_WAIT
     } state, next_state;

    // --------------------------             
    // State machine: update state
    // --------------------------            
    always_ff @(posedge clk, posedge reset)
        begin
            if (reset)
                state <= IDLE;
            else
                state <= next_state;
        end
            
    // -----------------------------------             
    // State machine: next state condition
    // -----------------------------------
    always_comb 
        begin
            case(state)
                IDLE:
                    if (psel == 1)
                        next_state  = SEND_PACKET;
                    else
                        next_state  = IDLE;
                SEND_PACKET:
                    if (cp_ready == 1)
                        next_state  = RESPONSE_WAIT;
                    else
                        next_state  = SEND_PACKET;
                RESPONSE_WAIT:
                    if (penable == 1)
                        next_state  = RESPONSE_WAIT;
                    else
                        next_state  = IDLE;
            endcase // case (state)
        end // always_comb
    
    // -----------------------------------             
    // State machine: state output logic
    // -----------------------------------
    always_comb
        begin
            case(state)
                IDLE:
                    cp_valid  = 0;
                SEND_PACKET:
                    cp_valid  = 1;
                RESPONSE_WAIT:
                    cp_valid  = 0;
            endcase
        end // always_comb
    
    
    // -----------------------------------             
    // Signal control
    // -----------------------------------
    always_ff @(posedge clk)
        begin
            pready <= rp_valid;

        end
    
    always_comb
        begin
            cp_startofpacket  = '1;
            cp_endofpacket    = '1;
            rp_ready          = '1;
        end
    // --------------------------------------
    // APB requires the data keep unchanged
    // --------------------------------------
    reg pslverr_reg;
    
    always_ff @(posedge clk, posedge reset)
        begin
            if (reset)
                prdata  <= '0;
            else if (rp_valid) begin
                prdata       <= rp_data[PKT_DATA_H : PKT_DATA_L];
                pslverr_reg  <= rp_data[PKT_RESPONSE_STATUS_H];
            end
        end
    
  
    // --------------------------------------
    // Command & Response Construction
    // --------------------------------------
    always_comb 
        begin
            cp_data                                            = '0; // default assignment; override below as needed.
            pslverr                                            = '0;
            
            cp_data[PKT_PROTECTION_L]                          = 1'b0;
            cp_data[PKT_PROTECTION_L+1]                        = SECURE_ACCESS_BIT[0];
            cp_data[PKT_PROTECTION_L+2]                        = 1'b0;
            cp_data[PKT_BURSTWRAP_H:PKT_BURSTWRAP_L  ]         = burstwrap_value_int[PKT_BYTE_CNT_W-1:0];
            cp_data[PKT_BYTE_CNT_H :PKT_BYTE_CNT_L   ]         = bytecount_value_int[PKT_BYTE_CNT_W-1:0];
            cp_data[PKT_ADDR_H     :PKT_ADDR_L       ]         = paddr;
            cp_data[PKT_TRANS_EXCLUSIVE              ]         = 1'b0;
            cp_data[PKT_TRANS_LOCK                   ]         = 1'b0;
            // APB is non-bursting master, so compressed_read  = 0
            cp_data[PKT_TRANS_COMPRESSED_READ        ]         = 1'b0;
            cp_data[PKT_TRANS_READ                   ]         = ~pwrite;
            cp_data[PKT_TRANS_WRITE                  ]         = pwrite;

            // All transactionss from APB are non-posted; need response
            cp_data[PKT_TRANS_POSTED                 ]         = '0; 
            cp_data[PKT_DATA_H     :PKT_DATA_L       ]         = pwdata;
            cp_data[PKT_BYTEEN_H   :PKT_BYTEEN_L     ]         = '1;
            cp_data[PKT_BURST_SIZE_H:PKT_BURST_SIZE_L]         = burst_size;
			cp_data[PKT_ORI_BURST_SIZE_H:PKT_ORI_BURST_SIZE_L] = burst_size;
            cp_data[PKT_BURST_TYPE_H:PKT_BURST_TYPE_L]         = 2'b01; // INCR only
            cp_data[PKT_SRC_ID_H   :PKT_SRC_ID_L     ]         = id_int[PKT_SRC_ID_W-1:0];
            cp_data[PKT_THREAD_ID_H:PKT_THREAD_ID_L  ]         = '0;
            cp_data[PKT_CACHE_H    :PKT_CACHE_L      ]         = '0;
            cp_data[PKT_QOS_H      : PKT_QOS_L]                = '0;        

            // This signal is DEBUG APB, use address side-band to carry from master to slave
            cp_data[PKT_ADDR_SIDEBAND_H:PKT_ADDR_SIDEBAND_L]   = paddr31; 
            cp_data[PKT_DATA_SIDEBAND_H :PKT_DATA_SIDEBAND_L]  = '0;

            if (pready)
                pslverr  = pslverr_reg;
            else
                pslverr  = '0;
            

        end // always @ *
    
    // ------------------------------
    // Utility functions
    // ------------------------------
    function integer clogb2;
        input [31:0] value;
        begin
            for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1)
                value  = value >> 1;
            clogb2 = clogb2 - 1;
        end
    endfunction // clogb2
    
    
endmodule
