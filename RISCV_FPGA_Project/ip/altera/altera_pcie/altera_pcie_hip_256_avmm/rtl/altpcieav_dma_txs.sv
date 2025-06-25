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


module altpcieav_dma_txs # (

      parameter TX_S_ADDR_WIDTH              = 31

   )
  (
      input logic                                  Clk_i,
      input logic                                  Rstn_i,

   // TXS Slave Port
      input   logic                               TxsChipSelect_i,
      input  logic                                TxsWrite_i,
      input  logic  [TX_S_ADDR_WIDTH-1:0]         TxsAddress_i,
      input  logic  [31:0]                        TxsWriteData_i,
      input  logic  [3:0]                         TxsByteEnable_i,
      output logic                                TxsWaitRequest_o,
      input  logic                                TxsRead_i,
      output logic  [31:0]                        TxsReadData_o,
      output logic                                TxsReadDataValid_o,

       // Rx fifo Interface
      output logic                                 RxFifoRdReq_o,
      input  logic [265:0]                         RxFifoDataq_i,
      input  logic [3:0]                           RxFifoCount_i,

          // Tx fifo Interface
      output logic                                 TxFifoWrReq_o,
      output logic [259:0]                         TxFifoData_o,
      input  logic [3:0]                           TxFifoCount_i,

     // Arbiter Interface
      output logic                                 TxsArbReq_o,
      input logic                                  TxsArbGranted_i,

      input                                        MasterEnable_i,
      input  logic [12:0]                          BusDev_i

  );

      //state machine encoding
     localparam  TXS_IDLE                  = 7'h01;
     localparam  TXS_ARB_REQ               = 7'h02;
     localparam  TXS_WRITE_HEADER          = 7'h04;
     localparam  TXS_READ_HEADER           = 7'h08;
     localparam  TXS_WAIT_CPL              = 7'h10;
     localparam  TXS_RDATA_VALID           = 7'h20;


   logic                                             tx_fifo_ok;
   logic                                             rx_fifo_empty;
   logic    [5:0]                                    txs_state;
   logic    [5:0]                                    txs_nxt_state;
   logic                                             rx_sop;
   logic                                             is_cpl_wd;
   logic    [4:0]                                    cpl_tag;
   logic    [TX_S_ADDR_WIDTH-1:0]                 txs_address_reg;
   logic    [31:0]                                   txs_data_reg;
   logic                                             is_avrd_reg;
   logic                                             is_avwr_reg;
   logic    [3:0]                                    fbe_reg;
   logic    [63:0]                                   full_tlp_address;
   logic                                             is_64_req;
   logic    [15:0]                                   requestor_id;
   logic    [31:0]                                   tlp_dw2;
   logic    [31:0]                                   tlp_dw3;
   logic    [31:0]                                   tlp_dw4;
   logic    [7:0]                                    cmd;
   logic    [255:0]                                  tx_tlp_data;
   logic                                             tx_tlp_sop;
   logic                                             tx_tlp_eop;
   logic    [1:0]                                    tx_tlp_emp;
   logic    [259:0]                                  tx_fifo_wrdata;
   logic                                             tx_fifo_wrreq;
   logic                                             cpl_addr_bit2;
   logic    [31:0]                                   cpl_data;
   logic                                             is_cpl_wd_reg;
   logic    [4:0]                                    cpl_tag_reg;
   logic    [31:0]                                   cpl_data_reg;
   logic                                             txs_write_header_st;
   logic                                             txs_read_header_st;
   logic    [63:0]                                   req_header1;
   logic    [63:0]                                   req_header2;
   logic                                             txs_ready;




 assign tx_fifo_ok    = (TxFifoCount_i <= 4'd12);
 assign rx_fifo_empty = (RxFifoCount_i == 4'h0);


  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           txs_state <= TXS_IDLE;
         else
           txs_state <= txs_nxt_state;
         end


always_comb
  begin
    case(txs_state)
      TXS_IDLE :
       if(TxsChipSelect_i & MasterEnable_i & (TxsWrite_i | TxsRead_i))
          txs_nxt_state <= TXS_ARB_REQ;
        else
          txs_nxt_state <= TXS_IDLE;

      TXS_ARB_REQ :
        if(TxsArbGranted_i & TxsWrite_i & tx_fifo_ok)
          txs_nxt_state <= TXS_WRITE_HEADER;
        else if(TxsArbGranted_i & TxsRead_i & tx_fifo_ok)
          txs_nxt_state <= TXS_READ_HEADER;
        else
           txs_nxt_state <= TXS_ARB_REQ;

      TXS_WRITE_HEADER:
         txs_nxt_state <= TXS_IDLE;

      TXS_READ_HEADER:
         txs_nxt_state <= TXS_WAIT_CPL;

      TXS_WAIT_CPL:
        if(rx_sop & is_cpl_wd & cpl_tag == 16 & ~rx_fifo_empty)
          txs_nxt_state <= TXS_RDATA_VALID;
        else
          txs_nxt_state <= TXS_WAIT_CPL;

      TXS_RDATA_VALID:
       txs_nxt_state <= TXS_IDLE;

      default:
        txs_nxt_state <= TXS_IDLE;
    endcase
end

  assign rdata_valid_st        =  txs_state[5];
  assign txs_write_header_st =  txs_state[2];
  assign txs_read_header_st  =  txs_state[3];
  assign txs_wait_cpl_st =  txs_state[4];
  assign txs_ready =   txs_write_header_st | rdata_valid_st;
  assign TxsWaitRequest_o = ~txs_ready;
  assign TxsArbReq_o = txs_state[1];

//  Latch the address and data from AVMM

   always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         begin
           txs_address_reg <= 0;
           txs_data_reg    <= 32'h0;
           is_avrd_reg     <= 1'b0;
           is_avwr_reg     <= 1'b0;
           fbe_reg         <= 4'h0;

         end
       else if(TxsChipSelect_i & (TxsWrite_i | TxsRead_i))
         begin
           txs_address_reg  <= TxsAddress_i;
           txs_data_reg     <= TxsWriteData_i;
           is_avrd_reg      <= TxsRead_i;
           is_avwr_reg      <= TxsWrite_i;
           fbe_reg          <= TxsByteEnable_i;
         end
      end

// forming the Request TLP

assign full_tlp_address = {{(64-TX_S_ADDR_WIDTH){1'b0}}, txs_address_reg[TX_S_ADDR_WIDTH-1:0]};
assign is_64_req        = (full_tlp_address[63:32] != 32'h0);
assign requestor_id     = {BusDev_i, 3'b000};

assign tlp_dw2          = ~is_64_req? full_tlp_address[31:0] : full_tlp_address[63:32];
assign tlp_dw3          = ~is_64_req? txs_data_reg : full_tlp_address[31:0];
assign tlp_dw4          = txs_data_reg;


always_comb
  begin
    case({is_64_req, is_avwr_reg, is_avrd_reg})
      3'b001  : cmd = 8'h00;
      3'b010  : cmd = 8'h40;
      3'b101  : cmd = 8'h20;
      default : cmd = 8'h60;
    endcase
 end

assign req_header1 = {requestor_id[15:0], 8'd16, 4'h0, fbe_reg, cmd[7:0], 8'h0, 16'h1};
assign req_header2 = { tlp_dw3, tlp_dw2 };

assign tx_tlp_data      = {64'h0, tlp_dw4,tlp_dw4, req_header2, req_header1};
assign tx_tlp_sop  = txs_write_header_st | txs_read_header_st;
assign tx_tlp_eop  = txs_write_header_st | txs_read_header_st;
assign tx_tlp_emp[1:0] = (is_avrd_reg | (is_avwr_reg & full_tlp_address[2] & ~is_64_req))?   2'b10 : 2'b01;

// Tx fifo interface

assign   tx_fifo_wrdata[259:0] = {tx_tlp_emp, tx_tlp_eop, tx_tlp_sop, tx_tlp_data};
assign   tx_fifo_wrreq  = txs_read_header_st | txs_write_header_st;
assign   TxFifoWrReq_o = tx_fifo_wrreq;
assign   TxFifoData_o  = tx_fifo_wrdata;

/// Completion Data path
assign RxFifoRdReq_o = (rx_sop & is_cpl_wd & cpl_tag == 16 & ~rx_fifo_empty) & txs_wait_cpl_st;
assign rx_sop        = RxFifoDataq_i[256];

assign is_cpl_wd     = RxFifoDataq_i[30] & (RxFifoDataq_i[28:24]==5'b01010);
assign cpl_tag       = RxFifoDataq_i[76:72];
assign cpl_addr_bit2 = RxFifoDataq_i[66];
assign cpl_data      = cpl_addr_bit2?  RxFifoDataq_i[127:96] :  RxFifoDataq_i[159:128];

// latching the cpl information
 always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         begin
           is_cpl_wd_reg      <= 1'b0;
           cpl_tag_reg        <= 5'h0;
           cpl_data_reg       <= 32'h0;
         end
       else if(~rx_fifo_empty & is_cpl_wd & rx_sop & cpl_tag == 16 )
       begin
           is_cpl_wd_reg      <= is_cpl_wd;
           cpl_tag_reg        <= cpl_tag;
           cpl_data_reg       <= cpl_data;
       end
     end



assign TxsReadData_o    =  cpl_data_reg;
assign TxsReadDataValid_o = rdata_valid_st;

endmodule






