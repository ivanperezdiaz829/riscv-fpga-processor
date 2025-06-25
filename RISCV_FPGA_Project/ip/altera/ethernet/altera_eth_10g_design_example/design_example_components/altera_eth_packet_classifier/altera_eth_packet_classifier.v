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
module altera_eth_packet_classifier(
    //Common clock and reset
    clk,
    reset,
    
    //Av-ST Data Sink
    data_sink_sop,
    data_sink_eop,
    data_sink_valid,
    data_sink_data,
    data_sink_ready,
    data_sink_empty,
    data_sink_error,
    
    //Av-ST Data Source
    data_src_sop,
    data_src_eop,
    data_src_valid,
    data_src_data,
    data_src_ready,
    data_src_empty,
    data_src_error,
    
    //timestamp
    tx_etstamp_ins_ctrl_in_residence_time_update,
    tx_etstamp_ins_ctrl_in_ingress_timestamp_96b,
    tx_etstamp_ins_ctrl_in_ingress_timestamp_64b,
    tx_etstamp_ins_ctrl_in_residence_time_calc_format,
    
    tx_egress_timestamp_request_in_valid,
    tx_egress_timestamp_request_in_fingerprint,
    
    tx_etstamp_ins_ctrl_out_ingress_timestamp_96b,
    tx_etstamp_ins_ctrl_out_ingress_timestamp_64b,
    tx_etstamp_ins_ctrl_out_residence_time_calc_format,
    
    tx_egress_timestamp_request_out_valid,
    tx_egress_timestamp_request_out_fingerprint,
    
    //operation mode
    clock_mode,
    pkt_with_crc,  //1 = packet with crc; 0 = packet without crc
    
    //Offset locations
    tx_etstamp_ins_ctrl_out_offset_timestamp,
    tx_etstamp_ins_ctrl_out_offset_correction_field,
    tx_etstamp_ins_ctrl_out_offset_checksum_field,
    tx_etstamp_ins_ctrl_out_offset_checksum_correction,
    
    tx_etstamp_ins_ctrl_out_checksum_zero,
    tx_etstamp_ins_ctrl_out_checksum_correct,
    tx_etstamp_ins_ctrl_out_timestamp_format, //is ieee1588v1
    tx_etstamp_ins_ctrl_out_timestamp_insert,
    tx_etstamp_ins_ctrl_out_residence_time_update
);
    //Avalon Streaming
    parameter BITSPERSYMBOL                     = 8;       // Streaming Data symbol width in bits
    parameter SYMBOLSPERBEAT                    = 8;       // Streaming Number of symbols per word
    localparam ERROR_WIDTH                      = 1;       // Streaming port error width
    localparam EMPTY_WIDTH                      = log2ceil(SYMBOLSPERBEAT);
    localparam DATA_WIDTH                       = BITSPERSYMBOL * SYMBOLSPERBEAT;
    
    //octet offset
    localparam MAC_LENGTH_TYPE_OFFSET           = 12;
    localparam IPV4_PROTOCOL_OFFSET             = 23;
    localparam IPV6_PROTOCOL_OFFSET             = 20;
    localparam IPV4_UDP_OFFSET                  = 34;
    localparam IPV6_UDP_OFFSET                  = 54;
    localparam PTP_MSG_TYPE_OFFSET              = 14;
    localparam IPV4_MSG_TYPE_OFFSET             = 42;
    localparam IPV6_MSG_TYPE_OFFSET             = 62;

    localparam MAC_LENGTH_TYPE_OFFSET_BYTECOUNT = (div(MAC_LENGTH_TYPE_OFFSET, SYMBOLSPERBEAT)) * SYMBOLSPERBEAT;
    localparam IPV4_PROTOCOL_OFFSET_BYTECOUNT   = (div(IPV4_PROTOCOL_OFFSET, SYMBOLSPERBEAT)) * SYMBOLSPERBEAT;
    localparam IPV6_PROTOCOL_OFFSET_BYTECOUNT   = (div(IPV6_PROTOCOL_OFFSET, SYMBOLSPERBEAT)) * SYMBOLSPERBEAT;
    localparam IPV4_UDP_PORT_OFFSET_BYTECOUNT   = (div((IPV4_UDP_OFFSET+2), SYMBOLSPERBEAT)) * SYMBOLSPERBEAT;
    localparam IPV6_UDP_PORT_OFFSET_BYTECOUNT   = (div((IPV6_UDP_OFFSET+2), SYMBOLSPERBEAT)) * SYMBOLSPERBEAT;
    localparam PTP_MSG_TYPE_OFFSET_BYTECOUNT    = (div(PTP_MSG_TYPE_OFFSET, SYMBOLSPERBEAT)) * SYMBOLSPERBEAT;
    localparam IPV4_MSG_TYPE_OFFSET_BYTECOUNT   = (div(IPV4_MSG_TYPE_OFFSET, SYMBOLSPERBEAT)) * SYMBOLSPERBEAT;
    localparam IPV6_MSG_TYPE_OFFSET_BYTECOUNT   = (div(IPV6_MSG_TYPE_OFFSET, SYMBOLSPERBEAT)) * SYMBOLSPERBEAT;
    localparam PTP_MSG_FLAG_OFFSET_BYTECOUNT    = (div((PTP_MSG_TYPE_OFFSET+6), SYMBOLSPERBEAT)) * SYMBOLSPERBEAT;
    localparam IPV4_MSG_FLAG_OFFSET_BYTECOUNT   = (div((IPV4_MSG_TYPE_OFFSET+6), SYMBOLSPERBEAT)) * SYMBOLSPERBEAT;
    localparam IPV6_MSG_FLAG_OFFSET_BYTECOUNT   = (div((IPV6_MSG_TYPE_OFFSET+6), SYMBOLSPERBEAT)) * SYMBOLSPERBEAT;

    //type
    localparam PTP_LENGTH_TYPE                  = 16'h88F7;    // PTP Length/Type field
    localparam IPV4_LENGTH_TYPE                 = 16'h0800;    // IPv4 Length/Type field
    localparam IPV6_LENGTH_TYPE                 = 16'h86DD;    // IPv6 Length/Type field
    localparam VLAN_LENGTH_TYPE                 = 16'h8100;    // VLAN Length/Type field
    localparam PROTOCOL_UDP                     = 8'h11;       // UDP Protocol field
    localparam UDP_PORT_PTP_EVENT               = 16'd319;     // UDP Port for PTP event messages
    localparam UDP_PORT_PTP_MISC                = 16'd320;     // UDP Port for PTP non-event messages
  
    //ether type        
    localparam TYPE_PTP                         = 6'h0;
    localparam TYPE_PTP_VLAN                    = 6'h1;
    localparam TYPE_PTP_SVLAN                   = 6'h2;

    localparam TYPE_UDP_IPV4                    = 6'h3;
    localparam TYPE_UDP_IPV4_VLAN               = 6'h4;
    localparam TYPE_UDP_IPV4_SVLAN              = 6'h5;

    localparam TYPE_UDP_IPV6                    = 6'h6;
    localparam TYPE_UDP_IPV6_VLAN               = 6'h7;
    localparam TYPE_UDP_IPV6_SVLAN              = 6'h8;

    localparam TYPE_NONE_PTP                    = 6'h9;

    //message type                              
    localparam MSG_SYNC                         = 4'h0;
    localparam MSG_DELAY_REQ                    = 4'h1;
    localparam MSG_PDELAY_REQ                   = 4'h2;
    localparam MSG_PDELAY_RESP                  = 4'h3;
    localparam MSG_FOLLOW_UP                    = 4'h8;
    localparam MSG_PDELAY_RESP_FOLLOW_UP        = 4'hA;

    // Width of timestamp                       
    localparam TIMESTAMP_S_WIDTH                = 48;
    localparam TIMESTAMP_NS_WIDTH               = 32;
    localparam TIMESTAMP_FNS_WIDTH              = 16;
    localparam TIMESTAMP_NS_FNS_WIDTH           = TIMESTAMP_NS_WIDTH + TIMESTAMP_FNS_WIDTH;
    localparam TIMESTAMP_WIDTH                  = TIMESTAMP_S_WIDTH + TIMESTAMP_NS_FNS_WIDTH;
    
    // Width of correctionField
    localparam CORRECTION_FIELD_WIDTH           = 64;
    
    parameter TSTAMP_FP_WIDTH                   = 4;
    
    //clock operation mode
    localparam ORDINARY_CLOCK                   = 2'h0;
    localparam BOUNDARY_CLOCK                   = 2'h1;
    localparam E2E_TRANSPARENT_CLOCK            = 2'h2;
    localparam P2P_TRANSPARENT_CLOCK            = 2'h3;

    //FIFO width
    localparam FIFO_REQ_CTRL_WIDTH              = 68;
    localparam FIFO_INS_CTRL_WIDTH              = 6 + TSTAMP_FP_WIDTH + TIMESTAMP_WIDTH + CORRECTION_FIELD_WIDTH;

    //FIFO depth
    localparam MAX_PACKET_SIZE                  = 2048;                           // Bytecount need to to power of 2
    localparam PKT_FIFO_DEPTH                   = MAX_PACKET_SIZE/SYMBOLSPERBEAT; // FIFO depth should have minimum of MAX_PACKET_SIZE/SYMBOLSPERBEAT
    localparam CTRL_FIFO_DEPTH                  = MAX_PACKET_SIZE/64;             // Assuming packet minimum size is 64 bytes

    // ----------------------------------------------------------------------------
    // Number of bytes and pipeline required to analyze the content of the frame
    // ----------------------------------------------------------------------------  
    localparam AVST_PLINE_BYTE_REQ              = 10;                             // largest required field- length type = 2 bytes + 8 bytes for stacked VLAN
    localparam AVST_PLINE_DEPTH                 = divceil(AVST_PLINE_BYTE_REQ, SYMBOLSPERBEAT) - 1;
    localparam WIDE_PLINE_DATABUS_WIDTH         = (AVST_PLINE_DEPTH + 1) * DATA_WIDTH;
    localparam WIDE_PLINE_DATA_REQ              = (AVST_PLINE_DEPTH + 1) * SYMBOLSPERBEAT;

    // Checksum correction offset calculated at data_sink_eop. 
    // Offset location located at 2 bytes before EOP and (1+AVST_PLINE_DEPTH) cycle after the byte_count calculated
    localparam CHECKSUM_CORRECTION_CAL          = ((AVST_PLINE_DEPTH+1) * SYMBOLSPERBEAT) - 2;
    
    
    //Common clock and Reset
    input                                   clk;
    input                                   reset;
    
    //Avalon ST DataIn (Sink) Interface
    input                                   data_sink_sop;
    input                                   data_sink_eop;
    input                                   data_sink_valid;
    output                                  data_sink_ready;
    input       [(DATA_WIDTH)-1:0]          data_sink_data;
    input       [((EMPTY_WIDTH>0) ? (EMPTY_WIDTH-1):0) : 0]         data_sink_empty;
    input       [(ERROR_WIDTH)-1:0]         data_sink_error;
    
    //Avalon ST DataOut (Source) Interface
    output                                  data_src_sop;
    output                                  data_src_eop;
    output                                  data_src_valid;
    input                                   data_src_ready;
    output      [(DATA_WIDTH)-1:0]          data_src_data;
    output      [((EMPTY_WIDTH>0) ? (EMPTY_WIDTH-1):0) : 0]         data_src_empty;
    output      [(ERROR_WIDTH)-1:0]         data_src_error;
    
    //timestamp 
    ////input tx_etstamp_ins_ctrl_in_residence_time_update;
    input                                   tx_etstamp_ins_ctrl_in_residence_time_update;
    input      [TIMESTAMP_WIDTH-1:0]        tx_etstamp_ins_ctrl_in_ingress_timestamp_96b;
    input      [CORRECTION_FIELD_WIDTH-1:0] tx_etstamp_ins_ctrl_in_ingress_timestamp_64b;
    input                                   tx_etstamp_ins_ctrl_in_residence_time_calc_format;
                                        
    input                                   tx_egress_timestamp_request_in_valid;
    input      [TSTAMP_FP_WIDTH-1:0]        tx_egress_timestamp_request_in_fingerprint;
    
    ////output reg tx_etstamp_ins_ctrl_out_residence_time_update;
    output wire [TIMESTAMP_WIDTH-1:0 ]       tx_etstamp_ins_ctrl_out_ingress_timestamp_96b;
    output wire [CORRECTION_FIELD_WIDTH-1:0] tx_etstamp_ins_ctrl_out_ingress_timestamp_64b;
    output wire                              tx_etstamp_ins_ctrl_out_residence_time_calc_format;
                                    
    output wire                              tx_egress_timestamp_request_out_valid;
    output wire [TSTAMP_FP_WIDTH-1:0]        tx_egress_timestamp_request_out_fingerprint;
    
    input       [1:0]                       clock_mode;
    input                                   pkt_with_crc;
    
    output wire  [15:0]                      tx_etstamp_ins_ctrl_out_offset_timestamp;
    output wire  [15:0]                      tx_etstamp_ins_ctrl_out_offset_correction_field;
    output wire  [15:0]                      tx_etstamp_ins_ctrl_out_offset_checksum_field;
    output wire  [15:0]                      tx_etstamp_ins_ctrl_out_offset_checksum_correction;
    
    output wire                              tx_etstamp_ins_ctrl_out_checksum_zero;
    output wire                              tx_etstamp_ins_ctrl_out_checksum_correct;
    output wire                             tx_etstamp_ins_ctrl_out_timestamp_format; //is ieee1588v1
    output wire                              tx_etstamp_ins_ctrl_out_timestamp_insert;
    output wire                              tx_etstamp_ins_ctrl_out_residence_time_update;
    
    reg         [5:0]                       ethertype; 
    reg                                     ethertype_valid;
    reg                                     offset_location_valid;
    reg                                     msg_valid;
    reg                                     insertion_valid;
    
    //Hold data to be align with data_src_sop
    reg                                     tx_etstamp_ins_ctrl_out_timestamp_insert_reg;
    reg                                     tx_etstamp_ins_ctrl_out_residence_time_update_reg;
    reg     [TIMESTAMP_WIDTH-1:0]           tx_etstamp_ins_ctrl_out_ingress_timestamp_96b_reg;
    reg     [CORRECTION_FIELD_WIDTH-1:0]    tx_etstamp_ins_ctrl_out_ingress_timestamp_64b_reg;
    reg                                     tx_etstamp_ins_ctrl_out_residence_time_calc_format_reg;   
    reg                                     tx_egress_timestamp_request_out_valid_reg;
    reg     [TSTAMP_FP_WIDTH-1:0]           tx_egress_timestamp_request_out_fingerprint_reg;        
    reg     [15:0]                          tx_etstamp_ins_ctrl_out_offset_checksum_correction_reg;                       
    reg     [15:0]                          tx_etstamp_ins_ctrl_out_offset_timestamp_reg;
    reg     [15:0]                          tx_etstamp_ins_ctrl_out_offset_correction_field_reg;
    reg     [15:0]                          tx_etstamp_ins_ctrl_out_offset_checksum_field_reg;
    reg     [7:0]       msg_type;
    reg     [15:0]      msg_flag;
    reg                 is_udp;
    reg                 is_ptp_port;
    reg                 decode_in_progress;

    reg     [15:0]      byte_count;
    reg                tx_etstamp_ins_ctrl_out_checksum_zero_reg;
    reg                tx_etstamp_ins_ctrl_out_checksum_correct_reg;

    wire                tx_etstamp_ins_ctrl_out_ptp_udp_ipv4_wire;
    wire                tx_etstamp_ins_ctrl_out_ptp_udp_ipv4_wire_out;
    wire                tx_etstamp_ins_ctrl_out_ptp_udp_ipv6_wire;
    wire                tx_etstamp_ins_ctrl_out_ptp_udp_ipv6_wire_out;
    wire                eth_frame_start;
    wire                eth_frame_end;
    wire                data_sink_frame_end;
    
    // Length/Type field
    wire    [15:0]      mac_length_type_untagged;
    wire    [15:0]      mac_length_type_vlan;
    wire    [15:0]      mac_length_type_svlan;
    
    // Protocol field of IPv4 header
    wire    [7:0]       ipv4_protocol_untagged;
    wire    [7:0]       ipv4_protocol_vlan;
    wire    [7:0]       ipv4_protocol_svlan;
    wire    [7:0]       ipv6_protocol_untagged;
    wire    [7:0]       ipv6_protocol_vlan;
    wire    [7:0]       ipv6_protocol_svlan;
    
    // UDP port number in UDP/IPv4 header
    wire    [15:0]      ipv4_udp_port_untagged;
    wire    [15:0]      ipv4_udp_port_vlan;
    wire    [15:0]      ipv4_udp_port_svlan;
    wire    [15:0]      ipv6_udp_port_untagged;
    wire    [15:0]      ipv6_udp_port_vlan;
    wire    [15:0]      ipv6_udp_port_svlan;
        
    wire    [7:0]       msg_type_ptp_untaged;
    wire    [7:0]       msg_type_ptp_vlan;
    wire    [7:0]       msg_type_ptp_svlan;
    wire    [7:0]       msg_type_ipv4_untaged;
    wire    [7:0]       msg_type_ipv4_vlan;
    wire    [7:0]       msg_type_ipv4_svlan;   
    wire    [7:0]       msg_type_ipv6_untaged;
    wire    [7:0]       msg_type_ipv6_vlan;
    wire    [7:0]       msg_type_ipv6_svlan;       
    wire    [15:0]      msg_flag_ptp_untaged;
    wire    [15:0]      msg_flag_ptp_vlan;
    wire    [15:0]      msg_flag_ptp_svlan;
    wire    [15:0]      msg_flag_ipv4_untaged;
    wire    [15:0]      msg_flag_ipv4_vlan;
    wire    [15:0]      msg_flag_ipv4_svlan;
    wire    [15:0]      msg_flag_ipv6_untaged;
    wire    [15:0]      msg_flag_ipv6_vlan;
    wire    [15:0]      msg_flag_ipv6_svlan;

    wire                is_udp_ptp;

    wire fifo_pkt_out_valid;
    wire fifo_pkt_out_ready;
    wire [(FIFO_INS_CTRL_WIDTH-1):0] fifo_ins_ctrl_in_data;
    wire fifo_ins_ctrl_in_valid;

    wire [(FIFO_INS_CTRL_WIDTH-1):0] fifo_ins_ctrl_out_data;
    wire fifo_ins_ctrl_out_valid;
    wire fifo_ins_ctrl_out_ready;
    wire [1:0] clock_mode_out;
    wire pkt_with_crc_out;
    wire tx_etstamp_ins_ctrl_in_residence_time_update_wire;
    wire tx_etstamp_ins_ctrl_out_residence_time_update_reg_w;
    wire [(FIFO_REQ_CTRL_WIDTH-1):0] fifo_req_ctrl_in_data;
    wire fifo_req_ctrl_in_valid;

    wire [(FIFO_REQ_CTRL_WIDTH-1):0] fifo_req_ctrl_out_data;
    wire fifo_req_ctrl_out_valid;
    wire fifo_req_ctrl_out_ready;
    wire decode_valid_out;
    wire fifo_data_all_valid;



    // ###########################################################################################
    // -----------------------------------------------------------------------------------
    // Avalon-ST Register Pipeline 
    // These pipeline registers register enough data so that the frame decoding could be done
    // -----------------------------------------------------------------------------------
    // ###########################################################################################
    
    // Wire signals for the pipeline stages
    wire pline_sop      [0:AVST_PLINE_DEPTH];
    wire pline_eop      [0:AVST_PLINE_DEPTH];
    wire pline_valid    [0:AVST_PLINE_DEPTH];
    wire pline_ready    [0:AVST_PLINE_DEPTH];
    wire [((EMPTY_WIDTH>0) ? (EMPTY_WIDTH-1):0) : 0]    pline_empty     [0:AVST_PLINE_DEPTH];
    wire [(DATA_WIDTH)-1:0]     pline_data      [0:AVST_PLINE_DEPTH];
    wire [(ERROR_WIDTH)-1:0]    pline_error     [0:AVST_PLINE_DEPTH];
    
    // Wide data bus consist of frame content from multiple pipelines
    wire [WIDE_PLINE_DATABUS_WIDTH-1:0]     wide_pline_databus;
    wire [BITSPERSYMBOL-1:0]                wide_pline_data         [0:WIDE_PLINE_DATA_REQ - 1];
    wire [15:0] checksum_correction_cal_wire;

    // Input to the pipeline stages from the ports
    assign pline_sop[0]                     = data_sink_sop;
    assign pline_eop[0]                     = data_sink_eop;
    assign pline_data[0]                    = data_sink_data;
    assign pline_valid[0]                   = data_sink_valid;
    assign data_sink_ready                  = pline_ready[0];
    assign pline_empty[0]                   = data_sink_empty;
    assign pline_error[0]                   = data_sink_error;
    assign wide_pline_databus [(DATA_WIDTH)-1 : 0] = pline_data[0];

    //Indicating packet decoding complete
    assign decode_valid_out =  (decode_in_progress & eth_frame_end)? 1'b1 : ethertype_valid & insertion_valid & offset_location_valid;

    //Indicating data valid in all fifo
    assign fifo_data_all_valid = fifo_pkt_out_valid & fifo_ins_ctrl_out_valid & fifo_req_ctrl_out_valid;
    assign data_src_valid = data_src_sop ? fifo_data_all_valid : fifo_pkt_out_valid;

    // fifo_ins_ctrl signals
    assign fifo_ins_ctrl_in_data =  {clock_mode,
                                     pkt_with_crc,
                tx_etstamp_ins_ctrl_in_residence_time_update,
                                     tx_etstamp_ins_ctrl_in_ingress_timestamp_96b,
                                     tx_etstamp_ins_ctrl_in_ingress_timestamp_64b,
                                     tx_etstamp_ins_ctrl_in_residence_time_calc_format,
                                     tx_egress_timestamp_request_in_valid,
                                     tx_egress_timestamp_request_in_fingerprint
                                     };
    assign fifo_ins_ctrl_in_valid = data_sink_sop & data_sink_valid & data_sink_ready;
    assign {clock_mode_out,
            pkt_with_crc_out,
            tx_etstamp_ins_ctrl_in_residence_time_update_wire,
            tx_etstamp_ins_ctrl_out_ingress_timestamp_96b,
            tx_etstamp_ins_ctrl_out_ingress_timestamp_64b,
            tx_etstamp_ins_ctrl_out_residence_time_calc_format,
            tx_egress_timestamp_request_out_valid,
            tx_egress_timestamp_request_out_fingerprint} = fifo_ins_ctrl_out_data;
    assign fifo_ins_ctrl_out_ready = fifo_data_all_valid & data_src_sop & data_src_ready;


    // fifo_req_ctrl signals
    assign fifo_req_ctrl_in_data =  {tx_etstamp_ins_ctrl_out_offset_timestamp_reg,
                                     tx_etstamp_ins_ctrl_out_offset_correction_field_reg,
                                     tx_etstamp_ins_ctrl_out_offset_checksum_field_reg,
                                     tx_etstamp_ins_ctrl_out_offset_checksum_correction_reg,
                                     tx_etstamp_ins_ctrl_out_ptp_udp_ipv4_wire,
                                     tx_etstamp_ins_ctrl_out_ptp_udp_ipv6_wire,
                                     tx_etstamp_ins_ctrl_out_timestamp_insert_reg,
                                     tx_etstamp_ins_ctrl_out_residence_time_update_reg
                                     };
    assign fifo_req_ctrl_in_valid = decode_valid_out;
    assign {tx_etstamp_ins_ctrl_out_offset_timestamp,
            tx_etstamp_ins_ctrl_out_offset_correction_field,
            tx_etstamp_ins_ctrl_out_offset_checksum_field,
            tx_etstamp_ins_ctrl_out_offset_checksum_correction,
            tx_etstamp_ins_ctrl_out_ptp_udp_ipv4_wire_out,
            tx_etstamp_ins_ctrl_out_ptp_udp_ipv6_wire_out,
            tx_etstamp_ins_ctrl_out_timestamp_insert,
            tx_etstamp_ins_ctrl_out_residence_time_update_reg_w
            } = fifo_req_ctrl_out_data;
    assign fifo_req_ctrl_out_ready = fifo_data_all_valid & data_src_sop & data_src_ready;
    assign tx_etstamp_ins_ctrl_out_residence_time_update = tx_etstamp_ins_ctrl_out_residence_time_update_reg_w & tx_etstamp_ins_ctrl_in_residence_time_update_wire;
    assign tx_etstamp_ins_ctrl_out_checksum_zero = tx_etstamp_ins_ctrl_out_ptp_udp_ipv4_wire_out & (tx_etstamp_ins_ctrl_out_timestamp_insert | tx_etstamp_ins_ctrl_out_residence_time_update);
    assign tx_etstamp_ins_ctrl_out_checksum_correct = tx_etstamp_ins_ctrl_out_ptp_udp_ipv6_wire_out & (tx_etstamp_ins_ctrl_out_timestamp_insert | tx_etstamp_ins_ctrl_out_residence_time_update);
    
    // fifo_pkt signals
    assign fifo_pkt_out_ready = data_src_sop ? (fifo_data_all_valid & data_src_ready) : data_src_ready;

    // Locate frame start and frame end at the last pipeline
    assign eth_frame_start = pline_valid[AVST_PLINE_DEPTH] & pline_ready[AVST_PLINE_DEPTH] & pline_sop[AVST_PLINE_DEPTH];
    assign eth_frame_end = pline_valid[AVST_PLINE_DEPTH] & pline_ready[AVST_PLINE_DEPTH] & pline_eop[AVST_PLINE_DEPTH];
    assign data_sink_frame_end = data_sink_valid & data_sink_ready & data_sink_eop;

    // Length/Type field for untagged/VLAN/Stacked VLAN frames
    assign mac_length_type_untagged = {wide_pline_data[MAC_LENGTH_TYPE_OFFSET % SYMBOLSPERBEAT], wide_pline_data[(MAC_LENGTH_TYPE_OFFSET % SYMBOLSPERBEAT) +1]};
    assign mac_length_type_vlan = {wide_pline_data[(MAC_LENGTH_TYPE_OFFSET % SYMBOLSPERBEAT) +4], wide_pline_data[(MAC_LENGTH_TYPE_OFFSET % SYMBOLSPERBEAT) +5]};
    assign mac_length_type_svlan = {wide_pline_data[(MAC_LENGTH_TYPE_OFFSET % SYMBOLSPERBEAT) +8], wide_pline_data[(MAC_LENGTH_TYPE_OFFSET % SYMBOLSPERBEAT) +9]};
    
    // Protocol field
    assign ipv4_protocol_untagged = wide_pline_data[IPV4_PROTOCOL_OFFSET % SYMBOLSPERBEAT];
    assign ipv4_protocol_vlan = wide_pline_data[(IPV4_PROTOCOL_OFFSET % SYMBOLSPERBEAT) +4];
    assign ipv4_protocol_svlan = wide_pline_data[(IPV4_PROTOCOL_OFFSET % SYMBOLSPERBEAT) +8];
    assign ipv6_protocol_untagged = wide_pline_data[IPV6_PROTOCOL_OFFSET % SYMBOLSPERBEAT];
    assign ipv6_protocol_vlan = wide_pline_data[(IPV6_PROTOCOL_OFFSET % SYMBOLSPERBEAT) +4];
    assign ipv6_protocol_svlan = wide_pline_data[(IPV6_PROTOCOL_OFFSET % SYMBOLSPERBEAT) +8];
    
    // UDP port number
    assign ipv4_udp_port_untagged = {wide_pline_data[(IPV4_UDP_OFFSET+2) % SYMBOLSPERBEAT], wide_pline_data[((IPV4_UDP_OFFSET+2) % SYMBOLSPERBEAT) +1]};
    assign ipv4_udp_port_vlan = {wide_pline_data[((IPV4_UDP_OFFSET+2) % SYMBOLSPERBEAT) +4], wide_pline_data[((IPV4_UDP_OFFSET+2) % SYMBOLSPERBEAT) +5]};
    assign ipv4_udp_port_svlan = {wide_pline_data[((IPV4_UDP_OFFSET+2) % SYMBOLSPERBEAT) +8], wide_pline_data[((IPV4_UDP_OFFSET+2) % SYMBOLSPERBEAT) +9]};
    assign ipv6_udp_port_untagged = {wide_pline_data[(IPV6_UDP_OFFSET+2) % SYMBOLSPERBEAT], wide_pline_data[((IPV6_UDP_OFFSET+2) % SYMBOLSPERBEAT) +1]};
    assign ipv6_udp_port_vlan = {wide_pline_data[((IPV6_UDP_OFFSET+2) % SYMBOLSPERBEAT) +4], wide_pline_data[((IPV6_UDP_OFFSET+2) % SYMBOLSPERBEAT) +5]};
    assign ipv6_udp_port_svlan = {wide_pline_data[((IPV6_UDP_OFFSET+2) % SYMBOLSPERBEAT) +8], wide_pline_data[((IPV6_UDP_OFFSET+2) % SYMBOLSPERBEAT) +9]};

    // Message type field
    assign msg_type_ptp_untaged = wide_pline_data[(PTP_MSG_TYPE_OFFSET % SYMBOLSPERBEAT)];
    assign msg_type_ptp_vlan = wide_pline_data[(PTP_MSG_TYPE_OFFSET % SYMBOLSPERBEAT) +4];
    assign msg_type_ptp_svlan = wide_pline_data[(PTP_MSG_TYPE_OFFSET % SYMBOLSPERBEAT) +8];
    assign msg_type_ipv4_untaged = wide_pline_data[(IPV4_MSG_TYPE_OFFSET % SYMBOLSPERBEAT)];
    assign msg_type_ipv4_vlan = wide_pline_data[(IPV4_MSG_TYPE_OFFSET % SYMBOLSPERBEAT) +4];
    assign msg_type_ipv4_svlan = wide_pline_data[(IPV4_MSG_TYPE_OFFSET % SYMBOLSPERBEAT) +8];
    assign msg_type_ipv6_untaged = wide_pline_data[(IPV6_MSG_TYPE_OFFSET % SYMBOLSPERBEAT)];
    assign msg_type_ipv6_vlan = wide_pline_data[(IPV6_MSG_TYPE_OFFSET % SYMBOLSPERBEAT) +4];
    assign msg_type_ipv6_svlan = wide_pline_data[(IPV6_MSG_TYPE_OFFSET % SYMBOLSPERBEAT) +8];

    // Message flag field
    assign msg_flag_ptp_untaged = {wide_pline_data[(PTP_MSG_TYPE_OFFSET + 6) % SYMBOLSPERBEAT], wide_pline_data[((PTP_MSG_TYPE_OFFSET + 6) % SYMBOLSPERBEAT) +1]};
    assign msg_flag_ptp_vlan = {wide_pline_data[((PTP_MSG_TYPE_OFFSET + 6) % SYMBOLSPERBEAT) +4], wide_pline_data[((PTP_MSG_TYPE_OFFSET + 6) % SYMBOLSPERBEAT) +5]};
    assign msg_flag_ptp_svlan = {wide_pline_data[((PTP_MSG_TYPE_OFFSET + 6) % SYMBOLSPERBEAT) +8], wide_pline_data[((PTP_MSG_TYPE_OFFSET + 6) % SYMBOLSPERBEAT) +9]};
    assign msg_flag_ipv4_untaged = {wide_pline_data[(IPV4_MSG_TYPE_OFFSET + 6) % SYMBOLSPERBEAT], wide_pline_data[((IPV4_MSG_TYPE_OFFSET + 6) % SYMBOLSPERBEAT) +1]};
    assign msg_flag_ipv4_vlan = {wide_pline_data[((IPV4_MSG_TYPE_OFFSET + 6) % SYMBOLSPERBEAT) +4], wide_pline_data[((IPV4_MSG_TYPE_OFFSET + 6) % SYMBOLSPERBEAT) +5]};
    assign msg_flag_ipv4_svlan = {wide_pline_data[((IPV4_MSG_TYPE_OFFSET + 6) % SYMBOLSPERBEAT) +8], wide_pline_data[((IPV4_MSG_TYPE_OFFSET + 6) % SYMBOLSPERBEAT) +9]};
    assign msg_flag_ipv6_untaged = {wide_pline_data[(IPV6_MSG_TYPE_OFFSET + 6) % SYMBOLSPERBEAT], wide_pline_data[((IPV6_MSG_TYPE_OFFSET + 6) % SYMBOLSPERBEAT) +1]};
    assign msg_flag_ipv6_vlan = {wide_pline_data[((IPV6_MSG_TYPE_OFFSET + 6) % SYMBOLSPERBEAT) +4], wide_pline_data[((IPV6_MSG_TYPE_OFFSET + 6) % SYMBOLSPERBEAT) +5]};
    assign msg_flag_ipv6_svlan = {wide_pline_data[((IPV6_MSG_TYPE_OFFSET + 6) % SYMBOLSPERBEAT) +8], wide_pline_data[((IPV6_MSG_TYPE_OFFSET + 6) % SYMBOLSPERBEAT) +9]};

    assign is_udp_ptp = (ethertype == TYPE_UDP_IPV4 | ethertype == TYPE_UDP_IPV4_VLAN | ethertype == TYPE_UDP_IPV4_SVLAN |
                         ethertype == TYPE_UDP_IPV6 | ethertype == TYPE_UDP_IPV6_VLAN | ethertype == TYPE_UDP_IPV6_SVLAN ) ? (is_ptp_port & is_udp) : 1'b1;
    assign tx_etstamp_ins_ctrl_out_ptp_udp_ipv4_wire = (ethertype == TYPE_UDP_IPV4 | ethertype == TYPE_UDP_IPV4_VLAN | ethertype == TYPE_UDP_IPV4_SVLAN) & is_ptp_port & is_udp;
    assign tx_etstamp_ins_ctrl_out_ptp_udp_ipv6_wire = (ethertype == TYPE_UDP_IPV6 | ethertype == TYPE_UDP_IPV6_VLAN | ethertype == TYPE_UDP_IPV6_SVLAN) & is_ptp_port & is_udp;

    assign checksum_correction_cal_wire = pkt_with_crc_out? CHECKSUM_CORRECTION_CAL[15:0] - 3'd4 : CHECKSUM_CORRECTION_CAL[15:0];

    // THis signal is tied to 0 indicating 1588 1 step mode
    assign tx_etstamp_ins_ctrl_out_timestamp_format = 1'b0; 

    // ------------------------------------------------------------------------------------
    // This generate block generates the logic to stoare the Avalon-ST data in a pipeline
    // and present them as 1 wide data bus to the other logic blocks. 
    // ------------------------------------------------------------------------------------
    genvar i_gen;
    generate for (i_gen=0; i_gen < AVST_PLINE_DEPTH; i_gen=i_gen+1)
        begin : ST_PLINE_STAGE
        
            altera_avalon_st_pipeline_stage #(
                .SYMBOLS_PER_BEAT (SYMBOLSPERBEAT),
                .BITS_PER_SYMBOL (BITSPERSYMBOL),
                .USE_PACKETS (1),
                .USE_EMPTY (1),
                .PIPELINE_READY (0),
                .CHANNEL_WIDTH (0),
                .ERROR_WIDTH (ERROR_WIDTH),
                .PACKET_WIDTH (2),
                .EMPTY_WIDTH (EMPTY_WIDTH)
            ) data_pipeline (
                .clk(clk),
                .reset(reset),
                
                .in_valid(pline_valid[i_gen]),
                .in_ready(pline_ready[i_gen]),
                .in_data(pline_data[i_gen]),
                .in_startofpacket(pline_sop[i_gen]),
                .in_endofpacket(pline_eop[i_gen]),
                .in_empty(pline_empty[i_gen]),
                .in_error(pline_error[i_gen]),
                .in_channel(1'b0),
                
                .out_valid(pline_valid[i_gen+1]),
                .out_ready(pline_ready[i_gen+1]),
                .out_data(pline_data[i_gen+1]),
                .out_startofpacket(pline_sop[i_gen+1]),
                .out_endofpacket(pline_eop[i_gen+1]),
                .out_empty(pline_empty[i_gen+1]),
                .out_error(pline_error[i_gen+1]),
                .out_channel()
            );
             
            assign wide_pline_databus [((i_gen+2)*DATA_WIDTH)-1 : ((i_gen+1)*DATA_WIDTH)] = pline_data[i_gen+1];
            
        end
    endgenerate

    // ------------------------------------------------------------------------------------
    // This generate block generates the data for each byte in the wide pipeline data bus
    // ------------------------------------------------------------------------------------
    generate for (i_gen=0; i_gen < WIDE_PLINE_DATA_REQ; i_gen=i_gen+1)
        begin : WIDE_PLINE_DATA_GEN
            assign wide_pline_data[WIDE_PLINE_DATA_REQ - 1 - i_gen] = wide_pline_databus[((i_gen+1) * BITSPERSYMBOL) - 1: i_gen * BITSPERSYMBOL];
        end
    endgenerate
    

    altera_avalon_sc_fifo  #(
                .SYMBOLS_PER_BEAT    (SYMBOLSPERBEAT),
                .BITS_PER_SYMBOL     (BITSPERSYMBOL),
                .FIFO_DEPTH          (PKT_FIFO_DEPTH),
                .CHANNEL_WIDTH       (0),
                .ERROR_WIDTH         (ERROR_WIDTH),
                .USE_PACKETS         (1),
                .USE_FILL_LEVEL      (0),
                .EMPTY_LATENCY       (3),
                .USE_MEMORY_BLOCKS   (1),
                .USE_STORE_FORWARD   (0),
                .USE_ALMOST_FULL_IF  (0),
                .USE_ALMOST_EMPTY_IF (0)
    ) fifo_pkt (
        .clk               (clk),                           //       clk.clk
        .reset             (reset),                         // clk_reset.reset
        .csr_address       (2'b0),                          //       csr.address
        .csr_read          (1'b0),                          //          .read
        .csr_write         (1'b0),                          //          .write
        .csr_readdata      (),                              //          .readdata
        .csr_writedata     (32'b0),                         //          .writedata
        .in_data           (pline_data[AVST_PLINE_DEPTH]),  //        in.data
        .in_valid          (pline_valid[AVST_PLINE_DEPTH]), //          .valid
        .in_ready          (pline_ready[AVST_PLINE_DEPTH]), //          .ready
        .in_startofpacket  (pline_sop[AVST_PLINE_DEPTH]),   //          .startofpacket
        .in_endofpacket    (pline_eop[AVST_PLINE_DEPTH]),   //          .endofpacket
        .in_empty          (pline_empty[AVST_PLINE_DEPTH]), //          .empty
        .in_error          (pline_error[AVST_PLINE_DEPTH]), //          .error
        .out_data          (data_src_data),                 //       out.data
        .out_valid         (fifo_pkt_out_valid),                //          .valid
        .out_ready         (fifo_pkt_out_ready),                //          .ready
        .out_startofpacket (data_src_sop),                  //          .startofpacket
        .out_endofpacket   (data_src_eop),                  //          .endofpacket
        .out_empty         (data_src_empty),                //          .empty
        .out_error         (data_src_error),                //          .error
        .almost_full_data  (),                              // (terminated)
        .almost_empty_data (),                              // (terminated)
        .in_channel        (1'b0),                          // (terminated)
        .out_channel       ()                               // (terminated)
    );
    

 
    
    altera_avalon_sc_fifo #(
                .SYMBOLS_PER_BEAT    (1),
                .BITS_PER_SYMBOL     (FIFO_INS_CTRL_WIDTH), 
                .FIFO_DEPTH          (CTRL_FIFO_DEPTH),
                .CHANNEL_WIDTH       (0),
                .ERROR_WIDTH         (0),
                .USE_PACKETS         (0),
                .USE_FILL_LEVEL      (0),
                .EMPTY_LATENCY       (3),
                .USE_MEMORY_BLOCKS   (1),
                .USE_STORE_FORWARD   (0),
                .USE_ALMOST_FULL_IF  (0),
                .USE_ALMOST_EMPTY_IF (0)
        ) fifo_ins_ctrl (
                .clk               (clk),                                  //       clk.clk
                .reset             (reset),                                // clk_reset.reset
                .in_data           (fifo_ins_ctrl_in_data),                //        in.data
                .in_valid          (fifo_ins_ctrl_in_valid),               //          .valid
                .in_ready          (),                                     //          .ready
                .out_data          (fifo_ins_ctrl_out_data),               //       out.data
                .out_valid         (fifo_ins_ctrl_out_valid),              //          .valid
                .out_ready         (fifo_ins_ctrl_out_ready),              //          .ready
                .csr_address       (2'b0),                                 // (terminated)
                .csr_read          (1'b0),                                 // (terminated)
                .csr_write         (1'b0),                                 // (terminated)
                .csr_readdata      (),                                     // (terminated)
                .csr_writedata     (32'b0),                                // (terminated)
                .almost_full_data  (),                                     // (terminated)
                .almost_empty_data (),                                     // (terminated)
                .in_startofpacket  (1'b0),                                 // (terminated)
                .in_endofpacket    (1'b0),                                 // (terminated)
                .out_startofpacket (),                                     // (terminated)
                .out_endofpacket   (),                                     // (terminated)
                .in_empty          (1'b0),                                 // (terminated)
                .out_empty         (),                                     // (terminated)
                .in_error          (1'b0),                                 // (terminated)
                .out_error         (),                                     // (terminated)
                .in_channel        (1'b0),                                 // (terminated)
                .out_channel       ()                                      // (terminated)
        );

    
    altera_avalon_sc_fifo #(
                .SYMBOLS_PER_BEAT    (1),
                .BITS_PER_SYMBOL     (FIFO_REQ_CTRL_WIDTH), 
                .FIFO_DEPTH          (CTRL_FIFO_DEPTH),
                .CHANNEL_WIDTH       (0),
                .ERROR_WIDTH         (0),
                .USE_PACKETS         (0),
                .USE_FILL_LEVEL      (0),
                .EMPTY_LATENCY       (3),
                .USE_MEMORY_BLOCKS   (1),
                .USE_STORE_FORWARD   (0),
                .USE_ALMOST_FULL_IF  (0),
                .USE_ALMOST_EMPTY_IF (0)
        ) fifo_req_ctrl (
                .clk               (clk),                                  //       clk.clk
                .reset             (reset),                                // clk_reset.reset
                .in_data           (fifo_req_ctrl_in_data),                //        in.data
                .in_valid          (fifo_req_ctrl_in_valid),               //          .valid
                .in_ready          (),                                     //          .ready
                .out_data          (fifo_req_ctrl_out_data),               //       out.data
                .out_valid         (fifo_req_ctrl_out_valid),              //          .valid
                .out_ready         (fifo_req_ctrl_out_ready),              //          .ready
                .csr_address       (2'b0),                                 // (terminated)
                .csr_read          (1'b0),                                 // (terminated)
                .csr_write         (1'b0),                                 // (terminated)
                .csr_readdata      (),                                     // (terminated)
                .csr_writedata     (32'b0),                                // (terminated)
                .almost_full_data  (),                                     // (terminated)
                .almost_empty_data (),                                     // (terminated)
                .in_startofpacket  (1'b0),                                 // (terminated)
                .in_endofpacket    (1'b0),                                 // (terminated)
                .out_startofpacket (),                                     // (terminated)
                .out_endofpacket   (),                                     // (terminated)
                .in_empty          (1'b0),                                 // (terminated)
                .out_empty         (),                                     // (terminated)
                .in_error          (1'b0),                                 // (terminated)
                .out_error         (),                                     // (terminated)
                .in_channel        (1'b0),                                 // (terminated)
                .out_channel       ()                                      // (terminated)
        );
    
    
    // All the fields above are only valid at the start of packet, which is, if the valid, ready and the SOP in the last 
    // pipeline stage are asserted
    always @(posedge clk or posedge reset) begin
        if (reset == 1'b1) begin
            byte_count <= 16'b0;
        end
        else begin
            if(eth_frame_start) begin
                byte_count <= SYMBOLSPERBEAT[15:0];
            end
            else if(pline_valid[AVST_PLINE_DEPTH] & pline_ready[AVST_PLINE_DEPTH]) begin
                byte_count <= byte_count + SYMBOLSPERBEAT[15:0];
            end
        end
    end
    
   
    // Packet decoding
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ethertype <= 6'h3F;
            ethertype_valid <= 1'h0;
        end else begin
            if(decode_valid_out) begin
                    ethertype <= 6'h3F;
                    ethertype_valid <= 1'h0;
            end else if (MAC_LENGTH_TYPE_OFFSET_BYTECOUNT == byte_count) begin
                if (mac_length_type_untagged == PTP_LENGTH_TYPE) begin
                    ethertype <= TYPE_PTP;
                end else if (mac_length_type_untagged == IPV4_LENGTH_TYPE) begin
                    ethertype <= TYPE_UDP_IPV4;
                end else if (mac_length_type_untagged == IPV6_LENGTH_TYPE) begin
                    ethertype <= TYPE_UDP_IPV6;
                end else if (mac_length_type_untagged == VLAN_LENGTH_TYPE && 
                             mac_length_type_vlan     == PTP_LENGTH_TYPE) begin
                    ethertype <= TYPE_PTP_VLAN;
                end else if (mac_length_type_untagged == VLAN_LENGTH_TYPE && 
                             mac_length_type_vlan     == IPV4_LENGTH_TYPE) begin
                    ethertype <= TYPE_UDP_IPV4_VLAN;
                end else if (mac_length_type_untagged == VLAN_LENGTH_TYPE && 
                             mac_length_type_vlan     == IPV6_LENGTH_TYPE) begin
                    ethertype <= TYPE_UDP_IPV6_VLAN;
                end else if (mac_length_type_untagged == VLAN_LENGTH_TYPE && 
                             mac_length_type_vlan     == VLAN_LENGTH_TYPE && 
                             mac_length_type_svlan    == PTP_LENGTH_TYPE) begin
                    ethertype <= TYPE_PTP_SVLAN;
                end else if (mac_length_type_untagged == VLAN_LENGTH_TYPE && 
                             mac_length_type_vlan     == VLAN_LENGTH_TYPE && 
                             mac_length_type_svlan    == IPV4_LENGTH_TYPE) begin
                    ethertype <= TYPE_UDP_IPV4_SVLAN;
                end else if (mac_length_type_untagged == VLAN_LENGTH_TYPE && 
                             mac_length_type_vlan     == VLAN_LENGTH_TYPE && 
                             mac_length_type_svlan    == IPV6_LENGTH_TYPE) begin
                    ethertype <= TYPE_UDP_IPV6_SVLAN;
                end else begin
                    ethertype <= TYPE_NONE_PTP;
                end
                    ethertype_valid <= 1'b1;
            end
        end
    end
    
    //decode whether it is udp for ipv4 and ipv6
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            is_udp <= 1'b0;
        end else begin
            if(decode_valid_out) begin
                    is_udp <= 1'b0;
            end else begin
                if (IPV4_PROTOCOL_OFFSET_BYTECOUNT == byte_count) begin
                    if (ethertype == TYPE_UDP_IPV4) begin
                        if (ipv4_protocol_untagged == PROTOCOL_UDP) begin
                            is_udp <= 1'b1;
                        end
                    end else if (ethertype == TYPE_UDP_IPV4_VLAN) begin
                        if (ipv4_protocol_vlan == PROTOCOL_UDP) begin
                            is_udp <= 1'b1;
                        end
                    end else if (ethertype == TYPE_UDP_IPV4_SVLAN) begin
                        if (ipv4_protocol_svlan == PROTOCOL_UDP) begin
                            is_udp <= 1'b1;
                        end
                    end
                end
                if (IPV6_PROTOCOL_OFFSET_BYTECOUNT == byte_count) begin
                    if (ethertype == TYPE_UDP_IPV6 && ipv6_protocol_untagged == PROTOCOL_UDP) begin
                        if (ipv6_protocol_untagged == PROTOCOL_UDP) begin
                            is_udp <= 1'b1;
                        end
                    end else if (ethertype == TYPE_UDP_IPV6_VLAN && ipv6_protocol_vlan == PROTOCOL_UDP) begin
                        if (ipv6_protocol_vlan == PROTOCOL_UDP) begin
                            is_udp <= 1'b1;
                        end
                    end else if (ethertype == TYPE_UDP_IPV6_SVLAN && ipv6_protocol_svlan == PROTOCOL_UDP) begin
                        if (ipv6_protocol_svlan == PROTOCOL_UDP) begin
                            is_udp <= 1'b1;
                        end
                    end
                end
            end
        end
    end
    
    //decode whether it is udp ptp port for ipv4 and ipv6
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            is_ptp_port <= 1'b0;
        end else begin
            if(decode_valid_out) begin
                    is_ptp_port <= 1'b0;
            end else begin
                if (IPV4_UDP_PORT_OFFSET_BYTECOUNT == byte_count) begin
                    if (ethertype == TYPE_UDP_IPV4) begin
                        if (ipv4_udp_port_untagged == UDP_PORT_PTP_EVENT || ipv4_udp_port_untagged == UDP_PORT_PTP_MISC) begin
                            is_ptp_port <= 1'b1;
                        end
                    end else if (ethertype == TYPE_UDP_IPV4_VLAN) begin
                        if (ipv4_udp_port_vlan == UDP_PORT_PTP_EVENT || ipv4_udp_port_vlan == UDP_PORT_PTP_MISC) begin
                            is_ptp_port <= 1'b1;
                        end
                    end else if (ethertype == TYPE_UDP_IPV4_SVLAN) begin
                        if (ipv4_udp_port_svlan == UDP_PORT_PTP_EVENT || ipv4_udp_port_svlan == UDP_PORT_PTP_MISC) begin
                            is_ptp_port <= 1'b1;
                        end
                    end
                end
                if (IPV6_UDP_PORT_OFFSET_BYTECOUNT == byte_count) begin
                    if (ethertype == TYPE_UDP_IPV6) begin
                        if (ipv6_udp_port_untagged == UDP_PORT_PTP_EVENT || ipv6_udp_port_untagged == UDP_PORT_PTP_MISC) begin
                            is_ptp_port <= 1'b1;
                        end
                    end else if (ethertype == TYPE_UDP_IPV6_VLAN) begin
                        if (ipv6_udp_port_vlan == UDP_PORT_PTP_EVENT || ipv6_udp_port_vlan == UDP_PORT_PTP_MISC) begin
                            is_ptp_port <= 1'b1;
                        end
                    end else if (ethertype == TYPE_UDP_IPV6_SVLAN) begin
                        if (ipv6_udp_port_svlan == UDP_PORT_PTP_EVENT || ipv6_udp_port_svlan == UDP_PORT_PTP_MISC) begin
                            is_ptp_port <= 1'b1;
                        end
                    end
                end
            end
        end
    end
    
    // Determine timestamp insert & residence time update
    always @(posedge clk or posedge reset) begin
        if(reset) begin
                    msg_valid <= 1'b0;
                    msg_type <= 8'b0;
                    msg_flag <= 16'b0;
    end else begin
            if(decode_valid_out) begin
                    msg_valid <= 1'b0;
                    msg_type <= 1'b0;
                    msg_flag <= 1'b0;
            end else begin
                // Decode message type
                if (PTP_MSG_TYPE_OFFSET_BYTECOUNT == byte_count) begin
                    //message type field of TYPE_PTP may required in same cycle with length field
                    if (MAC_LENGTH_TYPE_OFFSET_BYTECOUNT == byte_count) begin
                        if (mac_length_type_untagged == PTP_LENGTH_TYPE) begin
                            msg_type <= msg_type_ptp_untaged;
                        end else if (mac_length_type_untagged == VLAN_LENGTH_TYPE && 
                                     mac_length_type_vlan     == PTP_LENGTH_TYPE) begin
                            msg_type <= msg_type_ptp_vlan;
                        end else if (mac_length_type_untagged == VLAN_LENGTH_TYPE && 
                                     mac_length_type_vlan     == VLAN_LENGTH_TYPE && 
                                     mac_length_type_svlan    == PTP_LENGTH_TYPE) begin
                            msg_type <= msg_type_ptp_svlan;
                        end
                    end else begin
                        if (ethertype == TYPE_PTP) begin
                            msg_type <= msg_type_ptp_untaged;
                        end else if (ethertype == TYPE_PTP_VLAN) begin
                            msg_type <= msg_type_ptp_vlan;
                        end else if (ethertype == TYPE_PTP_SVLAN) begin
                            msg_type <= msg_type_ptp_svlan;
                        end
                    end
                end else if (IPV4_MSG_TYPE_OFFSET_BYTECOUNT == byte_count) begin
                    if (ethertype == TYPE_UDP_IPV4) begin
                        msg_type <= msg_type_ipv4_untaged;
                    end else if (ethertype == TYPE_UDP_IPV4_VLAN) begin
                        msg_type <= msg_type_ipv4_vlan;
                    end else if (ethertype == TYPE_UDP_IPV4_SVLAN) begin
                        msg_type <= msg_type_ipv4_svlan;
                    end
                end else if (IPV6_MSG_TYPE_OFFSET_BYTECOUNT == byte_count) begin
                    if (ethertype == TYPE_UDP_IPV6) begin
                        msg_type <= msg_type_ipv6_untaged;
                    end else if (ethertype == TYPE_UDP_IPV6_VLAN) begin
                        msg_type <= msg_type_ipv6_vlan;
                    end else if (ethertype == TYPE_UDP_IPV6_SVLAN) begin
                        msg_type <= msg_type_ipv6_svlan;
                    end
                end

                if (PTP_MSG_FLAG_OFFSET_BYTECOUNT == byte_count) begin
                    if (ethertype == TYPE_PTP) begin
                        msg_flag <= msg_flag_ptp_untaged;
                        msg_valid <= 1'b1;
                    end else if (ethertype == TYPE_PTP_VLAN) begin
                        msg_flag <= msg_flag_ptp_vlan;
                        msg_valid <= 1'b1;
                    end else if (ethertype == TYPE_PTP_SVLAN) begin
                        msg_flag <= msg_flag_ptp_svlan;
                        msg_valid <= 1'b1;
                    end
                end else if (IPV4_MSG_FLAG_OFFSET_BYTECOUNT == byte_count) begin
                    if (ethertype == TYPE_UDP_IPV4) begin
                        msg_flag <= msg_flag_ipv4_untaged;
                        msg_valid <= 1'b1 & ethertype_valid;
                    end else if (ethertype == TYPE_UDP_IPV4_VLAN) begin
                        msg_flag <= msg_flag_ipv4_vlan;
                        msg_valid <= 1'b1;
                    end else if (ethertype == TYPE_UDP_IPV4_SVLAN) begin
                        msg_flag <= msg_flag_ipv4_svlan;
                        msg_valid <= 1'b1;
                    end
                end else if (IPV6_MSG_FLAG_OFFSET_BYTECOUNT == byte_count) begin
                    if (ethertype == TYPE_UDP_IPV6) begin
                        msg_flag <= msg_flag_ipv6_untaged;
                        msg_valid <= 1'b1;
                    end else if (ethertype == TYPE_UDP_IPV6_VLAN) begin
                        msg_flag <= msg_flag_ipv6_vlan;
                        msg_valid <= 1'b1;
                    end else if (ethertype == TYPE_UDP_IPV6_SVLAN) begin
                        msg_flag <= msg_flag_ipv6_svlan;
                        msg_valid <= 1'b1;
                    end
                end
            end
        end
    end


    always @(posedge clk or posedge reset) begin
        if(reset) begin
                    tx_etstamp_ins_ctrl_out_timestamp_insert_reg <= 1'b0;
                    tx_etstamp_ins_ctrl_out_residence_time_update_reg <= 1'b0;
                    insertion_valid <= 1'b0;
        end else begin
            if(decode_valid_out) begin
                    tx_etstamp_ins_ctrl_out_timestamp_insert_reg <= 1'b0;
                    tx_etstamp_ins_ctrl_out_residence_time_update_reg <= 1'b0;
                    insertion_valid <= 1'b0;
            end else 
                if (msg_valid) begin
                    if (clock_mode_out == ORDINARY_CLOCK || clock_mode_out == BOUNDARY_CLOCK) begin
                        if (msg_type[3:0] == MSG_SYNC && msg_flag[1] == 1'b0) begin
                            tx_etstamp_ins_ctrl_out_timestamp_insert_reg <= 1'b1 & is_udp_ptp;
                        end
                        if (msg_type[3:0] == MSG_PDELAY_RESP && msg_flag[1] == 1'b0) begin
                            tx_etstamp_ins_ctrl_out_residence_time_update_reg <= 1'b1 & is_udp_ptp;
                        end
                    end
                
                    if (clock_mode_out == E2E_TRANSPARENT_CLOCK) begin
                        if (msg_type[3:0] == MSG_SYNC || msg_type[3:0] == MSG_DELAY_REQ || msg_type[3:0] == MSG_PDELAY_RESP || msg_type[3:0] == MSG_PDELAY_REQ) begin
                            tx_etstamp_ins_ctrl_out_residence_time_update_reg <= 1'b1 & is_udp_ptp;
                        end
                    end
    
                    if (clock_mode_out == P2P_TRANSPARENT_CLOCK) begin
                        if (msg_type[3:0] == MSG_SYNC || msg_type[3:0] == MSG_DELAY_REQ || (msg_type[3:0] == MSG_PDELAY_RESP && msg_flag[1] == 1'b0)) begin
                            tx_etstamp_ins_ctrl_out_residence_time_update_reg <= 1'b1 & is_udp_ptp;
                        end
                    end
                    insertion_valid <= 1'b1;                    
               end else begin
                   if (ethertype == TYPE_NONE_PTP) begin
                       insertion_valid <= 1'b1;                    
                   end
               end
          end
    end

    
    
    
    // Offset calculation
    always @(*) begin
        case (ethertype)
            TYPE_PTP: begin
                tx_etstamp_ins_ctrl_out_offset_timestamp_reg = 16'd48;
                tx_etstamp_ins_ctrl_out_offset_correction_field_reg = 16'd22;
                tx_etstamp_ins_ctrl_out_offset_checksum_field_reg = 16'd0;
            end
    
            TYPE_PTP_VLAN: begin
                tx_etstamp_ins_ctrl_out_offset_timestamp_reg = 16'd52;
                tx_etstamp_ins_ctrl_out_offset_correction_field_reg = 16'd26;
                tx_etstamp_ins_ctrl_out_offset_checksum_field_reg = 16'd0;
            end
    
            TYPE_PTP_SVLAN: begin
                tx_etstamp_ins_ctrl_out_offset_timestamp_reg = 16'd56;
                tx_etstamp_ins_ctrl_out_offset_correction_field_reg = 16'd30;
                tx_etstamp_ins_ctrl_out_offset_checksum_field_reg = 16'd0;
            end
    
            TYPE_UDP_IPV4: begin
                tx_etstamp_ins_ctrl_out_offset_timestamp_reg = 16'd76;
                tx_etstamp_ins_ctrl_out_offset_correction_field_reg = 16'd50;
                tx_etstamp_ins_ctrl_out_offset_checksum_field_reg = 16'd40;
            end
    
            TYPE_UDP_IPV4_VLAN: begin
                tx_etstamp_ins_ctrl_out_offset_timestamp_reg = 16'd80;
                tx_etstamp_ins_ctrl_out_offset_correction_field_reg = 16'd54;
                tx_etstamp_ins_ctrl_out_offset_checksum_field_reg = 16'd44;
            end
            
            TYPE_UDP_IPV4_SVLAN: begin
                tx_etstamp_ins_ctrl_out_offset_timestamp_reg = 16'd84;
                tx_etstamp_ins_ctrl_out_offset_correction_field_reg = 16'd58;
                tx_etstamp_ins_ctrl_out_offset_checksum_field_reg = 16'd48;
            end
    
            TYPE_UDP_IPV6: begin
                tx_etstamp_ins_ctrl_out_offset_timestamp_reg = 16'd96;
                tx_etstamp_ins_ctrl_out_offset_correction_field_reg = 16'd70;
                tx_etstamp_ins_ctrl_out_offset_checksum_field_reg = 16'd60;
            end
    
            TYPE_UDP_IPV6_VLAN: begin
                tx_etstamp_ins_ctrl_out_offset_timestamp_reg = 16'd100;
                tx_etstamp_ins_ctrl_out_offset_correction_field_reg = 16'd74;
                tx_etstamp_ins_ctrl_out_offset_checksum_field_reg = 16'd64;
            end
    
            TYPE_UDP_IPV6_SVLAN: begin
                tx_etstamp_ins_ctrl_out_offset_timestamp_reg = 16'd104;
                tx_etstamp_ins_ctrl_out_offset_correction_field_reg = 16'd78;
                tx_etstamp_ins_ctrl_out_offset_checksum_field_reg = 16'd68;
            end
        default: begin
                tx_etstamp_ins_ctrl_out_offset_timestamp_reg = 16'd0;
                tx_etstamp_ins_ctrl_out_offset_correction_field_reg = 16'd0;
                tx_etstamp_ins_ctrl_out_offset_checksum_field_reg = 16'd0;
            end
        endcase
    end
    
    always @( posedge clk or posedge reset ) begin
        if(reset) begin
            tx_etstamp_ins_ctrl_out_offset_checksum_correction_reg <= 16'h0;
            offset_location_valid <= 0;
        end else begin
            if(decode_valid_out) begin
                tx_etstamp_ins_ctrl_out_offset_checksum_correction_reg <= 16'h0;
                offset_location_valid <= 1'b0;
            end else if (ethertype == TYPE_UDP_IPV4 || 
                ethertype == TYPE_UDP_IPV4_VLAN ||
                ethertype == TYPE_UDP_IPV4_SVLAN ||
                ethertype == TYPE_UDP_IPV6 ||
                ethertype == TYPE_UDP_IPV6_VLAN ||
                ethertype == TYPE_UDP_IPV6_SVLAN) begin
                
                if (ethertype_valid && data_sink_frame_end) begin 
                    tx_etstamp_ins_ctrl_out_offset_checksum_correction_reg <= (byte_count - data_sink_empty) + (checksum_correction_cal_wire) ;
                    offset_location_valid <= 1'b1;
                end
            end else if (ethertype == TYPE_PTP ||
                         ethertype == TYPE_PTP_VLAN ||
                         ethertype == TYPE_PTP_SVLAN ||
                         ethertype == TYPE_NONE_PTP) begin
                    //tx_etstamp_ins_ctrl_out_offset_checksum_correction_reg <= 16'h0;
                    offset_location_valid <= 1'b1;
            end
        end
    end
    
    always @( posedge clk or posedge reset ) begin
        if(reset) begin
            decode_in_progress <= 1'b0;
        end else begin
            if(decode_valid_out) begin
                decode_in_progress <= 1'b0;
            end else if (eth_frame_start) begin
                decode_in_progress <= 1'b1;
            end else if (eth_frame_end) begin
                decode_in_progress <= 1'b0;
            end

        end
    end


    // --------------------------------------------------
    // Calculates the log2ceil of the input value
    // --------------------------------------------------
    function integer log2ceil;
        input integer val;
        integer i;
        
        begin
            i = 1;
            log2ceil = 0;
            
            while (i < val) begin
                log2ceil = log2ceil + 1;
                i = i << 1; 
            end
        end
    endfunction
    
    // --------------------------------------------------
    // Calculates the divceil of the input value (m/n)
    // --------------------------------------------------
    function integer divceil;
        input integer m;
        input integer n;
        integer i;
        
        begin
            i = m % n;
            divceil = (m/n);
            if (i > 0) begin
                divceil = divceil + 1;
            end
        end
    endfunction

    // --------------------------------------------------
    // Calculates the division of the input value (m/n)
    // --------------------------------------------------
    function integer div;
        input integer m;
        input integer n;
        
        begin
            div = (m/n);
        end
    endfunction


endmodule 

