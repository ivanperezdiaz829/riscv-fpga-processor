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


// Downstream only EP application 64-bits
//
// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on
/////////////////////////////////////////////////////////////////////////////////////////////////////
// RX Header
// Downstream Memory TLP Format Header
//       ||31                                                                  0||
//       ||7|6|5|4|3|2|1|0|7|6|5|4|3|2|1|0 | 7|6 |5|4 |3|2|1|0 | 7|6|5|4|3|2|1|0||
// rx_h0 ||R|Fmt| type    |R|TC   |  R     |TD|EP|Attr|R  |  Length             ||
// rx_h1 ||     Requester ID               |     Tag           |LastBE  |FirstBE||
// rx_h2 ||                          Address [63:32]                            ||
// rx_h4 ||                          Address [31: 2]                        | R ||
//
// Downstream Completer TLP Format Header
//       ||31                                                                  0||
//       ||7|6|5|4|3|2|1|0|7|6|5|4|3|2|1|0 | 7|6 |5|4 |3|2|1|0 | 7|6|5|4|3|2|1|0||
// rx_h0 ||R|Fmt| type    |R|TC   |  R     |TD|EP|Attr|R  |  Length             ||
// rx_h1 ||    Completer ID                |Cplst| |  Byte Count                ||
// rx_h2 ||     Requester ID               |     Tag           |LastBE  |FirstBE||
//
//
module altpcied_ep_64bit_downstream # (
   parameter MAX_NUM_FUNC_SUPPORT             = 8,
   parameter num_of_func_hwtcl                = MAX_NUM_FUNC_SUPPORT,
   parameter device_family_hwtcl              = "Stratix V",
   parameter use_crc_forwarding_hwtcl         = 0,
   parameter pld_clockrate_hwtcl              = 125000000,
   parameter lane_mask_hwtcl                  = "x4",
   parameter max_payload_size_hwtcl           = 256,
   parameter gen123_lane_rate_mode_hwtcl      = "Gen1 (2.5 Gbps)",
   parameter ast_width_hwtcl                  = "Avalon-ST 64-bit",
   parameter port_width_data_hwtcl            = 64,
   parameter port_width_be_hwtcl              = 8,
   parameter extend_tag_field_hwtcl           = 32,
   parameter avalon_waddr_hwltcl              = 12,
   parameter check_bus_master_ena_hwtcl       = 1,
   parameter check_rx_buffer_cpl_hwtcl        = 1,
   parameter port_type_hwtcl                  = "Native endpoint",
   parameter apps_type_hwtcl                  = 2,
   parameter multiple_packets_per_cycle_hwtcl = 0,
   parameter use_ast_parity                   = 0

) (
      input                                           pld_clk,
      input                                           rst_pldclk,
      input [12: 0]                                   cfg_busdev,

      // AST TX
      output  [port_width_data_hwtcl-1  : 0]          tx_st_data,
      output  [((device_family_hwtcl == "Arria V" || device_family_hwtcl == "Cyclone V")?1:2)-1:0] tx_st_empty,
      output  [multiple_packets_per_cycle_hwtcl:0]    tx_st_eop,
      output  [multiple_packets_per_cycle_hwtcl:0]    tx_st_err,
      output  [multiple_packets_per_cycle_hwtcl:0]    tx_st_sop,
      output  [multiple_packets_per_cycle_hwtcl:0]    tx_st_valid,
      output  [port_width_be_hwtcl-1:0]               tx_st_parity,
      input                                           tx_st_ready,
      input                                           tx_fifo_empty,

      // AST RX
      input [port_width_be_hwtcl-1  :0]            rx_st_parity,
      input [port_width_data_hwtcl-1:0]            rx_st_data,
      output                                       rx_st_ready,
      input [multiple_packets_per_cycle_hwtcl:0]   rx_st_sop,
      input [multiple_packets_per_cycle_hwtcl:0]   rx_st_valid,
      input [((device_family_hwtcl == "Arria V" || device_family_hwtcl == "Cyclone V")?1:2)-1:0] rx_st_empty,
      input [multiple_packets_per_cycle_hwtcl:0]   rx_st_eop,
      input [multiple_packets_per_cycle_hwtcl:0]   rx_st_err,

      output                            rx_st_mask

);

function integer clogb2 (input integer depth);
begin
   clogb2 = 0;
   for(clogb2=0; depth>1; clogb2=clogb2+1)
      depth = depth >> 1;
end
endfunction
function integer addr_width_delta (input integer num_of_func);
begin
   if (num_of_func > 1) begin
      addr_width_delta = clogb2(MAX_NUM_FUNC_SUPPORT);
   end
   else begin
      addr_width_delta = 0;
   end
end
endfunction

localparam TLP_FMT_4DW_W        =2'b11    ;// TLP FMT field  -> 64 bits Write
localparam TLP_FMT_3DW_W        =2'b10    ;// TLP FMT field  -> 32 bits Write
localparam TLP_FMT_4DW_R        =2'b01    ;// TLP FMT field  -> 64 bits Read
localparam TLP_FMT_3DW_R        =2'b00    ;// TLP FMT field  -> 32 bits Read

localparam TLP_FMT_CPL          =2'b00    ;// TLP FMT field  -> Completion w/o data
localparam TLP_FMT_CPLD         =2'b10    ;// TLP FMT field  -> Completion with data

localparam TLP_TYPE_WRITE       =5'b00000 ;// TLP Type field -> write
localparam TLP_TYPE_READ        =5'b00000 ;// TLP Type field -> read
localparam TLP_TYPE_READ_LOCKED =5'b00001 ;// TLP Type field -> read_lock
localparam TLP_TYPE_CPLD        =5'b01010 ;// TLP Type field -> Completion with data
localparam TLP_TYPE_IO          =5'b00010 ;// TLP Type field -> IO

localparam TLP_TC_DEFAULT       =3'b000   ;// Default TC of the TLP
localparam TLP_TD_DEFAULT       =1'b0     ;// Default TD of the TL#
localparam TLP_EP_DEFAULT       =1'b0     ;// Default EP of the TLP
localparam TLP_ATTR_DEFAULT     =2'b0     ;// Default EP of the TLP


//synthesis translate_off
localparam ALTPCIE_ED_SIM_ONLY  = 1;
//synthesis translate_on
//synthesis read_comments_as_HDL on
//localparam ALTPCIE_ED_SIM_ONLY  = 0;
//synthesis read_comments_as_HDL off

localparam [255:0] ZEROS = 256'h0;

// Reset synchronizer


//////////////////////////////////////////////////////////////////////
//
// 64 Bit Interface
//

wire [1:0]  rx_st_fmt;
wire [4:0]  rx_st_type;
wire [9:0]  rx_st_len;

wire [31:0] tx_st_data_dw0;
wire [31:0] tx_st_data_dw1;

wire [31:0] rx_st_data_dw0;
wire [31:0] rx_st_data_dw1;

wire [31:0] tx_h0;
wire [31:0] tx_h1;
wire [31:0] tx_h2;

wire        tlp_read      ;
wire        tlp_write     ;

reg [31:0] reg_0  ;
reg [31:0] reg_4  ;
reg [3:0]  read_stage;

reg [31:0]  rx_h0;
reg [31:0]  rx_h1;

reg          tlp_write_r;
wire  [9:0]  tx_h0_len;
reg   [9:0]  tx_h0_len_r;
reg   [9:0]  tx_st64_len;
wire  [6:0]  tx_h2_lower_add;
reg   [6:0]  tx_h2_lower_add_r;

wire        tlp_3dw_header;
reg         tlp_3dw_header_r;

wire   tlp_addr_qwaligned;
reg    tlp_addr_qwaligned_r;

wire        tlp_sop;
reg         rx_eop_r;
reg         rx_sop_r;
reg         rx_sop_rr;
reg         tx_Cplh_cycle01;
reg         tx_Cplh_cycle23;
reg         tx_Cpld_cycle;
reg         tx_cpld_in_progress;
reg [63:0]  tx_st64_data;
reg         tx_st64_eop;
reg         tx_st64_valid;
reg         tx_st64_empty;
reg [15:0]  rp_requester_id;
reg [7:0]   rp_requester_tag;

assign {rx_st_data_dw1, rx_st_data_dw0} = rx_st_data;
assign rx_st_fmt                        = rx_st_data_dw0[30:29];
assign rx_st_type                       = rx_st_data_dw0[28:24];
assign rx_st_len                        = rx_st_data_dw0[9:0];
assign rx_st_mask                       = 1'b0;

assign tx_st_data         = tx_st64_data ;
assign tx_st_empty[1]     = 1'b0;
assign tx_st_empty[0]     = 1'b0;
assign tx_st_eop[0]       = tx_st64_eop;
assign tx_st_err[0]       = 1'b0;
assign tx_st_sop[0]       = (tx_Cplh_cycle01==1'b1)?1'b1:1'b0;
assign tx_st_valid[0]     = tx_st64_valid;
assign tx_st_parity       = 16'h0;

assign tlp_sop            = ((rx_st_valid[0]==1'b1)&&(rx_st_sop[0]==1'b1)) ?1'b1:1'b0;
assign tlp_write          = ((tlp_sop==1'b1)&&(rx_st_fmt[1]==1'b1)&&(rx_st_type==5'h0))?1'b1:1'b0;
assign tlp_read           = ((tlp_sop==1'b1)&&(rx_st_fmt[1]==1'b0)&&(rx_st_type==5'h0))?1'b1:1'b0;
assign tlp_3dw_header     = ((tlp_sop==1'b1)&&(rx_st_fmt[0]==1'b1))?1'b0:1'b1;
assign tx_h2_lower_add    = ((rx_sop_r==1'b1)&&(tlp_3dw_header_r==1'b0))?rx_st_data_dw1[6:0]:rx_st_data_dw0[6:0];
assign tlp_addr_qwaligned = ((rx_sop_r==1'b1)&&(tx_h2_lower_add[2:0]==3'b000))?1'b1:1'b0;
assign tx_h0_len          = rx_st_data_dw0[9:0];

assign rx_st_ready   = (tx_cpld_in_progress==1'b1)?1'b0:1'b1;

// CPLD Header
assign tx_h0[9:0]   = tx_h0_len[9:0];
assign tx_h0[15:10] = 6'h00;
assign tx_h0[23:16] = 8'h00;
assign tx_h0[28:24] = 5'b01010;    // FMT CPLD
assign tx_h0[31:29] = 3'b010;      // CPLD with data
assign tx_h1[11:0]  = {tx_h0_len,2'h0}; // Byte count
assign tx_h1[15:12] = 4'h0;
assign tx_h1[31:16] = {cfg_busdev[12:0],3'h0};// Bus /Dev /Function=0
assign tx_h2[6:0]   = tx_h2_lower_add[6:0];
assign tx_h2[7]     = 1'b0;
assign tx_h2[31:8]  = {rp_requester_id, rp_requester_tag};

always @(posedge pld_clk or posedge rst_pldclk) begin : p_rx_h
   if (rst_pldclk == 1'b1) begin
      rx_h0                <= 32'h0;
      rx_h1                <= 32'h0;
      rx_eop_r             <= 1'b0;
      rx_sop_r             <= 1'b0;
      rx_sop_rr            <= 1'b0;
      tlp_write_r          <= 1'b0;
      tlp_3dw_header_r     <= 1'b0;
      tlp_addr_qwaligned_r <= 1'b0;
      tx_h2_lower_add_r    <= 7'h0;
      tx_h0_len_r          <= 10'h0;
      // Data
      reg_0                <= 32'h0;  // Byte address 0x0
      reg_4                <= 32'h0;  // Byte address 0x4
      read_stage           <= 4'h0;

      //read
      tx_Cplh_cycle01      <= 1'b0;
      tx_Cplh_cycle23      <= 1'b0;
      tx_Cpld_cycle        <= 1'b0;
      tx_cpld_in_progress  <= 1'b0;
      tx_st64_len          <= 10'h0;
      tx_st64_data         <= 64'h0;
      tx_st64_eop          <= 1'b0;
      tx_st64_valid        <= 1'b0;
      tx_st64_empty        <= 1'b0;
      rp_requester_id      <= 16'h0;
      rp_requester_tag     <= 8'h0;

   end
   else begin
      if (rx_st_valid[0]==1'b1) begin
         rx_sop_r  <= tlp_sop;
         rx_sop_rr <= rx_sop_r ;
         rx_h0     <= rx_st_data_dw0;
         rx_h1     <= rx_st_data_dw1;
         rx_eop_r  <= rx_st_eop[0];
         if (rx_st_eop[0]==1'b1) begin
            tlp_write_r          <= 1'b0;
         end
         else if (rx_st_sop[0]==1'b1) begin
            tlp_write_r          <= tlp_write;
            tlp_3dw_header_r     <= tlp_3dw_header;
            tx_h0_len_r          <= tx_h0_len;
            rp_requester_id      <= rx_st_data_dw1[31:16];
            rp_requester_tag     <= rx_st_data_dw1[15: 8];
         end
         else if (rx_sop_r==1'b1) begin
            tlp_addr_qwaligned_r <= tlp_addr_qwaligned;
            tx_h2_lower_add_r    <= tx_h2_lower_add;
         end
         else if (tlp_write_r==1'b1) begin
            tx_h0_len_r<=(tx_h0_len_r>10'h2)?tx_h0_len_r-10'h2:10'h0;
         end
      end

      // Write
      if (tlp_write_r==1'b1) begin
         if (rx_sop_r==1'b0) begin
            {reg_4, reg_0} <= (tx_h0_len_r> 10'h1)?{rx_st_data_dw1,rx_st_data_dw0}:{reg_4,rx_st_data_dw0};
         end
         else if (tlp_3dw_header_r==1'b1) begin
            {reg_4, reg_0} <= (tx_h2_lower_add[2]==1'b1)?{rx_st_data_dw1,reg_0}:{reg_4,rx_st_data_dw1};
         end
      end
      // Read
      if (tlp_read==1'b1) begin
         tx_Cplh_cycle01 <= 1'b1;
         tx_Cplh_cycle23 <= 1'b0;
         tx_Cpld_cycle   <= 1'b0;
      end
      else if (tx_st_ready==1'b1) begin
         tx_Cplh_cycle01   <= 1'b0;
         tx_Cplh_cycle23   <= tx_Cplh_cycle01;
         if ((tx_Cplh_cycle23==1'b1)||(tx_Cpld_cycle==1'b1)) begin
            tx_Cpld_cycle <= (tx_st64_len>10'h1)?1'b1:1'b0;
         end
      end

      if (tx_Cpld_cycle==1'b1) begin
         tx_cpld_in_progress    <= (tx_st64_eop==1'b1)?1'b0:1'b1;
         tx_st64_eop            <= (tx_st_ready==1'b0)?1'b0:
                                   (tx_st64_eop==1'b1)?1'b0:
                                   (tx_st64_len>10'h2)?1'b0:1'b1;
         tx_st64_valid          <= (tx_st_ready==1'b0)?1'b0:
                                   (tx_st64_eop==1'b1)?1'b0:1'b1;
         tx_st64_empty          <= (tx_st64_len==10'h3)?1'b1:1'b0;
         if (tx_st_ready==1'b1) begin
            tx_st64_len  <= (tx_st64_len>10'h1)?tx_st64_len-10'h2:10'h0;
            tx_st64_data <= {reg_4, reg_0};
         end
      end
      else if (tx_Cplh_cycle23==1'b1) begin
         tx_cpld_in_progress    <= (tx_st64_eop==1'b1)?1'b0:1'b1;
         tx_st64_eop            <= (tx_st_ready==1'b0)?1'b0:
                                   (tx_st64_eop==1'b1)?1'b0:
                                   (tx_st64_len>10'h2)?1'b0:1'b1;
         tx_st64_valid          <= (tx_st_ready ==1'b0)?1'b0:
                                   (tx_st64_eop==1'b1)?1'b0:1'b1;
         tx_st64_empty          <= (tx_st64_len==10'h3)?1'b1:1'b0;
         if (tx_st_ready==1'b1) begin
            tx_st64_len  <= (tx_st64_len>10'h1)?tx_st64_len-10'h2:10'h0;
            tx_st64_data <= {reg_4, reg_0};
         end
      end
      else if (tx_Cplh_cycle01==1'b1) begin
         tx_cpld_in_progress    <= 1'b1;
         tx_st64_eop            <= ((tlp_addr_qwaligned==1'b0)&&(tx_h0_len==10'h1))?1'b1:1'b0;
         tx_st64_valid          <= (tx_st_ready ==1'b0)?1'b0:1'b1;
         tx_st64_empty          <= 1'b0;
         if (tlp_addr_qwaligned==1'b0) begin
            tx_st64_len         <= (tx_h0_len>10'h1)?tx_h0_len-10'h1:10'h0;
            tx_st64_data        <= {(tx_h2_lower_add[2]==1'b1)?reg_4:reg_0,tx_h2};
         end
         else begin
            tx_st64_data           <= {32'hCAFE_FADE,tx_h2};
         end
      end
      else if (tlp_read==1'b1) begin
         tx_cpld_in_progress    <= 1'b0;
         tx_st64_len            <= tx_h0_len;
         tx_st64_data           <= {tx_h1,tx_h0};
         tx_st64_valid          <= (tx_st_ready==1'b1)?1'b1:1'b0;
         tx_st64_empty          <= 1'b0;
         tx_st64_eop            <= 1'b0;
      end
      else begin
         tx_cpld_in_progress    <= 1'b0;
         tx_st64_eop            <= 1'b0;
         tx_st64_empty          <= 1'b0;
         tx_st64_valid          <= 1'b0;
      end
   end
end


endmodule
