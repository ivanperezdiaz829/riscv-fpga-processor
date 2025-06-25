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


module altpcieav_dma_rxm # (

      parameter BAR0_SIZE_MASK                             = 1,
      parameter BAR1_SIZE_MASK                             = 1,
      parameter BAR2_SIZE_MASK                             = 1,
      parameter BAR3_SIZE_MASK                             = 1,
      parameter BAR4_SIZE_MASK                             = 1,
      parameter BAR5_SIZE_MASK                             = 1,
      parameter BAR0_TYPE                                  = 64,
      parameter BAR1_TYPE                                  = 1,
      parameter BAR2_TYPE                                  = 32,
      parameter BAR3_TYPE                                  = 32,
      parameter BAR4_TYPE                                  = 32,
      parameter BAR5_TYPE                                  = 32,
      parameter AVMM_WIDTH                                 = 32
      
   )
  (
      input logic                                Clk_i,
      input logic                                Rstn_i,
      
      // Rx fifo Interface
      output logic                               RxFifoRdReq_o,
      input  logic [265:0]                       RxFifoDataq_i,
      input  logic [3:0]                         RxFifoCount_i,
      
      // Tx fifo Interface
      output logic                               TxFifoWrReq_o,
      output logic [259:0]                       TxFifoData_o,
      input  logic [3:0]                         TxFifoCount_i,
      
      input  logic [12:0]                        CfgBusDev_i,
  
  // Arbiter Interface
      output logic                               RxmArbCplReq_o,
      input logic                                RxmArbGranted_i,      

      // Avalon- RX Master
      // Avalon Rx Master interface 0
      output logic                                 RxmWrite_0_o,
      output logic [BAR0_TYPE-1:0]                 RxmAddress_0_o,
      output logic [AVMM_WIDTH-1:0]                RxmWriteData_0_o,
      output logic [(AVMM_WIDTH/8)-1:0]            RxmByteEnable_0_o,
      input  logic                                 RxmWaitRequest_0_i,
      output logic                                 RxmRead_0_o,
      input  logic [AVMM_WIDTH-1:0]                RxmReadData_0_i,
      input  logic                                 RxmReadDataValid_0_i,
              
      // Avallogic on Rx Master interface 1
      output logic                                 RxmWrite_1_o,
      output logic [BAR1_TYPE-1:0]                 RxmAddress_1_o,
      output logic [AVMM_WIDTH-1:0]                RxmWriteData_1_o,
      output logic [(AVMM_WIDTH/8)-1:0]            RxmByteEnable_1_o,
      input  logic                                 RxmWaitRequest_1_i,
      output logic                                 RxmRead_1_o,
      input  logic [AVMM_WIDTH-1:0]                RxmReadData_1_i,
      input  logic                                 RxmReadDataValid_1_i,
             
      // Aval on Rx Master interface 2
      output logic                                 RxmWrite_2_o,
      output logic [BAR2_TYPE-1:0]                 RxmAddress_2_o,
      output logic [AVMM_WIDTH-1:0]                RxmWriteData_2_o,
      output logic [(AVMM_WIDTH/8)-1:0]            RxmByteEnable_2_o,
      input  logic                                 RxmWaitRequest_2_i,
      output logic                                 RxmRead_2_o,
      input  logic [AVMM_WIDTH-1:0]                RxmReadData_2_i,
      input  logic                                 RxmReadDataValid_2_i,
              
      // Avallogic on Rx Master interface 3
      output logic                                 RxmWrite_3_o,
      output logic [BAR3_TYPE-1:0]                 RxmAddress_3_o,
      output logic [AVMM_WIDTH-1:0]                RxmWriteData_3_o,
      output logic [(AVMM_WIDTH/8)-1:0]            RxmByteEnable_3_o,
      input  logic                                 RxmWaitRequest_3_i,
      output logic                                 RxmRead_3_o,
      input  logic [AVMM_WIDTH-1:0]                RxmReadData_3_i,
      input  logic                                 RxmReadDataValid_3_i,
              
      // Avallogic on Rx Master interface 4
      output logic                                 RxmWrite_4_o,
      output logic [BAR4_TYPE-1:0]                 RxmAddress_4_o,
      output logic [AVMM_WIDTH-1:0]                RxmWriteData_4_o,
      output logic [(AVMM_WIDTH/8)-1:0]            RxmByteEnable_4_o,
      input  logic                                 RxmWaitRequest_4_i,
      output logic                                 RxmRead_4_o,
      input  logic [AVMM_WIDTH-1:0]                RxmReadData_4_i,
      input  logic                                 RxmReadDataValid_4_i,
             
      // Avallogic on Rx Master interface 5
      output logic                                 RxmWrite_5_o,
      output logic [BAR5_TYPE-1:0]                 RxmAddress_5_o,
      output logic [AVMM_WIDTH-1:0]                RxmWriteData_5_o,
      output logic [(AVMM_WIDTH/8)-1:0]            RxmByteEnable_5_o,
      input  logic                                 RxmWaitRequest_5_i,
      output logic                                 RxmRead_5_o,
      input  logic [AVMM_WIDTH-1:0]                RxmReadData_5_i,
      input  logic                                 RxmReadDataValid_5_i
  
  );
  
  
    //state machine encoding
   localparam  RXM_IDLE                = 7'h01;   
   localparam  RXM_WRITE               = 7'h02;
   localparam  RXM_READ                = 7'h04;
   localparam  RXM_CLEAR_BUF           = 7'h08;
   localparam  RXM_CPL_REQ             = 7'h10;
   localparam  RXM_SEND_CPL            = 7'h20;
   localparam  RXM_POP_TLP             = 7'h40;
  
   logic                  rx_sop;        
   logic                  rx_eop;        
   logic                  is_read;       
   logic                  is_write;      
   logic                  is_msg;        
   logic                  is_msg_wd;     
   logic                  is_msg_wod;    
   logic                  is_flush;      
   logic [3:0]            rx_lbe;        
   logic [3:0]            rx_fbe;        
   logic [9:0]            rx_dwlen;      
   logic [15:0]           cpl_req_id;    
   logic [7:0]            cpl_tag;       
   logic [2:0]            cpl_tc;        
   logic [1:0]            cpl_attr;      
   logic [11:0]            rx_byte_len;   
   logic                  rx_3dw_header; 
   logic [63:0]           rx_addr;
   logic [5:0]            bar_decode;    
   logic                  is_valid_read;  
   logic                  is_write_32;    
   logic                  is_flush_wr32;  
   logic                  is_flush_wr64;  
   logic                  addr_bit2;      
   logic                  is_valid_write; 
   logic                  is_unsupported_write;
   logic                  is_valid_read_reg;     
   logic                  is_flush_reg;          
   logic                  rx_eop_reg;            
   logic [31:0]           rx_tlp_dw3_reg;        
   logic [31:0]           rx_tlp_dw4_reg;        
   logic [31:0]           rx_tlp_dw5_reg;        
   logic                  rx_3dw_header_reg;     
   logic                  addr_bit2_reg;         
   logic [63:0]           rx_addr_reg;           
   logic [3:0]            rx_fbe_reg;            
   logic [3:0]            rx_lbe_reg;            
   logic [11:0]           rx_byte_len_reg;       
   logic [7:0]            cpl_tag_reg;           
   logic [15:0]           cpl_req_id_reg;        
   logic [2:0]            cpl_tc_reg;            
   logic [1:0]            cpl_attr_reg;          
   logic [5:0]            bar_decode_reg;           
   logic [6:0]            rxm_state;
   logic [6:0]            rxm_nxt_state;   
   logic                  rx_fifo_empty;  
   logic                  tx_fifo_ok;           
   logic                  tx_cpl_req;  
   logic                  rxm_wr_ena;  
   logic                  rxm_rd_ena;  
   logic                  rxm_idle_st;
   logic                  tx_cpl_send; 
   logic                  dump_rx_buffer;                   
   logic                  rx_dw3_sel;
   logic                  rx_dw4_sel;
   logic                  rx_dw5_sel;
   logic [31:0]           rxm_write_data;
   logic [5:0]            rxm_read_data_sel;       
   logic [31:0]           rxm_read_data;                
   logic [31:0]           rxm_cpl_data_reg;
   logic                  cpl_data_available_reg;              
   logic [11:0]           normal_byte_count;
   logic [11:0]           abort_byte_count;                      
   logic [11:0]           remain_bytes;
   logic [9:0]            dw_len;            
   logic [6:0]            lower_addr;              
   logic [255:0]          tx_tlp_data;
   logic                  tx_tlp_sop;   
   logic                  tx_tlp_eop;   
   logic [1:0]            tx_tlp_empty;         
   logic [259:0]          tx_fifo_wrdata;
   logic                  tx_fifo_wrreq;     
   logic                  rxm_wait_req;
   logic                  rxm_read_data_valid;
   logic                  rxm_read_data_valid_0;
   logic                  rxm_wait_request_0;
   logic  [31:0]          rxm_read_data_0;
   logic                  rxm_read_data_valid_1;
   logic                  rxm_wait_request_1;
   logic  [31:0]          rxm_read_data_1;
   logic                  rxm_read_data_valid_2;
   logic                  rxm_wait_request_2;
   logic  [31:0]          rxm_read_data_2;
   logic                  rxm_read_data_valid_3;
   logic                  rxm_wait_request_3;
   logic  [31:0]          rxm_read_data_3;
   logic                  rxm_read_data_valid_4;
   logic                  rxm_wait_request_4;
   logic  [31:0]          rxm_read_data_4;
   logic                  rxm_read_data_valid_5;
   logic                  rxm_wait_request_5;
   logic  [31:0]          rxm_read_data_5;         
   logic  [95:0]          cpl_header;     
   logic                  is_cpl_wd;
   
   
  
  // decode the Rx header to extract various information to support the state machine
  assign rx_sop        = RxFifoDataq_i[256];
  assign rx_eop        = RxFifoDataq_i[257];
  assign is_read       = ~RxFifoDataq_i[30] & (RxFifoDataq_i[28:26]== 3'b000) & ~RxFifoDataq_i[24];
  assign is_write      = RxFifoDataq_i[30] & (RxFifoDataq_i[28:24]==5'b00000);
  assign is_msg        = RxFifoDataq_i[29:27] == 3'b110;
  assign is_msg_wd     = RxFifoDataq_i[30] & is_msg;
  assign is_msg_wod    = ~RxFifoDataq_i[30] & is_msg;
  assign is_flush      = (is_read & rx_lbe == 4'h0 & rx_fbe == 4'h0);   /// read with no byte enable to flush
  assign rx_lbe        = RxFifoDataq_i[39:36];
  assign rx_fbe        = RxFifoDataq_i[35:32];
  assign rx_dwlen      = RxFifoDataq_i[9:0];
  assign cpl_req_id    = RxFifoDataq_i[63:48];
  assign cpl_tag       = RxFifoDataq_i[47:40];
  assign cpl_tc        = RxFifoDataq_i[22:20];
  assign cpl_attr      = RxFifoDataq_i[13:12];
  assign rx_byte_len   = {rx_dwlen[9:0], 2'b00}; 
  assign rx_3dw_header = ~RxFifoDataq_i[29];
  assign rx_addr[63:0] = RxFifoDataq_i[29]? {RxFifoDataq_i[95:64], RxFifoDataq_i[127:96]} : {32'h0, RxFifoDataq_i[95:64]};
  assign  bar_decode    = RxFifoDataq_i[265:260];
  assign is_valid_read   = is_read & (rx_dwlen == 4'h1);
  assign is_write_32    = is_write & rx_3dw_header;
  assign is_flush_wr32  = is_valid_write & is_write_32 &  rx_fbe == 4'h0;  
  assign is_flush_wr64   = is_valid_write & ~is_write_32 & rx_fbe == 4'h0;
  assign addr_bit2       = rx_3dw_header?   RxFifoDataq_i[66]: RxFifoDataq_i[98];
  assign is_valid_write  = is_write & (rx_dwlen == 4'h1);     
  assign is_unsupported_write = is_write & (rx_dwlen > 4'h1) ;  
  assign is_cpl_wd     = RxFifoDataq_i[30] & (RxFifoDataq_i[28:24]==5'b01010);  
  assign rx_fifo_empty = (RxFifoCount_i == 4'h0);
  assign tx_fifo_ok    = (TxFifoCount_i <= 4'hC);
  assign rxm_wait_req  = (rxm_wait_request_5 | rxm_wait_request_4 | rxm_wait_request_3 | rxm_wait_request_2 | rxm_wait_request_1 | rxm_wait_request_0);
  
  
  always_ff @ (posedge Clk_i or negedge Rstn_i) 
     begin                
       if(~Rstn_i) 
         begin                  
           is_valid_read_reg  <= 1'b0;
           is_flush_reg       <= 1'b0;
           rx_eop_reg         <= 1'b0;
           rx_tlp_dw3_reg     <= 32'h0;
           rx_tlp_dw4_reg     <= 32'h0;
           rx_tlp_dw5_reg     <= 32'h0;
           rx_3dw_header_reg  <= 1'b0;
           addr_bit2_reg      <= 1'b0;
           rx_addr_reg        <= 64'h0;
           rx_fbe_reg         <= 4'h0;
           rx_lbe_reg         <= 4'h0;
           rx_byte_len_reg    <= 12'h0;
           cpl_tag_reg        <= 8'h0;
           cpl_req_id_reg     <= 16'h0;
           cpl_tc_reg         <= 3'h0;
           cpl_attr_reg       <= 2'h0;
           bar_decode_reg     <= 6'h0;
           
         end                    
       else if(RxFifoRdReq_o ) // reading the header
       begin
           is_valid_read_reg  <= is_valid_read;
           is_flush_reg       <= is_flush;
           rx_eop_reg         <= rx_eop;
           rx_tlp_dw3_reg     <= RxFifoDataq_i[127:96];
           rx_tlp_dw4_reg     <= RxFifoDataq_i[159:128];
           rx_tlp_dw5_reg     <= RxFifoDataq_i[191:160];
           rx_3dw_header_reg  <= rx_3dw_header;
           addr_bit2_reg      <= addr_bit2;
           rx_addr_reg        <= rx_addr;
           rx_fbe_reg         <= rx_fbe;
           rx_lbe_reg         <= rx_lbe;
           rx_byte_len_reg    <= rx_byte_len;
           cpl_tag_reg        <= cpl_tag;
           cpl_req_id_reg     <= cpl_req_id;
           cpl_tc_reg         <= cpl_tc;
           cpl_attr_reg       <= cpl_attr;
           bar_decode_reg     <= bar_decode;
       end
     end 
  
  
   always_ff @ (posedge Clk_i or negedge Rstn_i) 
     begin                
       if(~Rstn_i) 
           rxm_state <= RXM_IDLE;
         else
           rxm_state <= rxm_nxt_state;
         end
         
  always_comb
  begin
    case(rxm_state)
        
      RXM_IDLE :
        if((is_msg_wod | is_flush_wr32 | is_unsupported_write & rx_eop | is_msg_wd & rx_eop ) & rx_sop & ~rx_fifo_empty)
          rxm_nxt_state <= RXM_POP_TLP;
        else if(rx_sop  & is_valid_write & ~rx_fifo_empty)
          rxm_nxt_state <= RXM_WRITE;
        else if(rx_sop & is_valid_read & ~rx_fifo_empty)
           rxm_nxt_state <= RXM_READ;
        else if(rx_sop & ~rx_eop & ~rx_fifo_empty &(is_unsupported_write | is_msg_wd))
           rxm_nxt_state <= RXM_CLEAR_BUF;
        else if(~rx_fifo_empty  & rx_sop & ~is_cpl_wd & (!is_valid_read | is_flush))   // not a valid read or flush
           rxm_nxt_state <= RXM_CPL_REQ;                 // completion without data
        else
          rxm_nxt_state <= RXM_IDLE;
          
       RXM_WRITE:
         if(~rxm_wait_req)
            rxm_nxt_state <= RXM_IDLE;
         else
           rxm_nxt_state <= RXM_WRITE;
           
       RXM_READ:
         if(~rxm_wait_req)
           rxm_nxt_state <= RXM_CPL_REQ;
         else
           rxm_nxt_state <= RXM_READ;
       
       RXM_CLEAR_BUF:
         if(rx_eop)
           rxm_nxt_state <= RXM_IDLE;
         else
           rxm_nxt_state <= RXM_CLEAR_BUF;
           
       RXM_CPL_REQ:
         if( RxmArbGranted_i & tx_fifo_ok &  (is_valid_read_reg & cpl_data_available_reg | ~is_valid_read_reg | is_flush_reg) )
           rxm_nxt_state <= RXM_SEND_CPL;
         else
           rxm_nxt_state <= RXM_CPL_REQ;
           
       RXM_SEND_CPL:
         rxm_nxt_state <= RXM_IDLE;  
       
       RXM_POP_TLP:
         rxm_nxt_state <= RXM_IDLE;
         
        default:
          rxm_nxt_state <= RXM_IDLE;
    endcase;
  end
  
assign rxm_idle_st = rxm_state[0]; 
assign tx_cpl_req  = rxm_state[4] | rxm_state[5];
assign rxm_wr_ena  = rxm_state[1];
assign rxm_rd_ena  = rxm_state[2];
assign tx_cpl_send = rxm_state[5];   
assign rxm_pop_tlp_st =   rxm_state[6]; 
assign dump_rx_buffer =  rxm_state[3];         
assign RxmArbCplReq_o = tx_cpl_req;  
// Write Request to the AVMM
 assign RxmWrite_0_o = rxm_wr_ena & bar_decode_reg[0];
 assign RxmRead_0_o  = rxm_rd_ena & bar_decode_reg[0];
 
assign RxmWrite_1_o = rxm_wr_ena & bar_decode_reg[1];
assign RxmRead_1_o  = rxm_rd_ena & bar_decode_reg[1]; 

assign RxmWrite_2_o = rxm_wr_ena & bar_decode_reg[2]; 
assign RxmRead_2_o  = rxm_rd_ena & bar_decode_reg[2];

assign RxmWrite_3_o = rxm_wr_ena & bar_decode_reg[3]; 
assign RxmRead_3_o  = rxm_rd_ena & bar_decode_reg[3];

assign RxmWrite_4_o = rxm_wr_ena & bar_decode_reg[4]; 
assign RxmRead_4_o  = rxm_rd_ena & bar_decode_reg[4];

assign RxmWrite_5_o = rxm_wr_ena & bar_decode_reg[5]; 
assign RxmRead_5_o  = rxm_rd_ena & bar_decode_reg[5];

assign rx_dw3_sel = rx_3dw_header_reg & addr_bit2_reg;
assign rx_dw4_sel = ~addr_bit2_reg;
assign rx_dw5_sel = ~rx_3dw_header_reg & addr_bit2_reg;

always_comb
  begin
  case ({rx_dw5_sel, rx_dw4_sel, rx_dw3_sel})
      3'b010 : rxm_write_data = rx_tlp_dw4_reg;
      3'b100 : rxm_write_data = rx_tlp_dw5_reg;
      default: rxm_write_data = rx_tlp_dw3_reg;
    endcase
  end
 
 
assign RxmWriteData_0_o = rxm_write_data;
assign RxmWriteData_1_o = rxm_write_data;
assign RxmWriteData_2_o = rxm_write_data;
assign RxmWriteData_3_o = rxm_write_data;
assign RxmWriteData_4_o = rxm_write_data;
assign RxmWriteData_5_o = rxm_write_data;
  
           
assign RxmAddress_0_o = rx_addr_reg[BAR0_TYPE-1:0];
assign RxmAddress_1_o = rx_addr_reg[BAR1_TYPE-1:0];
assign RxmAddress_2_o = rx_addr_reg[BAR2_TYPE-1:0];
assign RxmAddress_3_o = rx_addr_reg[BAR3_TYPE-1:0];
assign RxmAddress_4_o = rx_addr_reg[BAR4_TYPE-1:0];
assign RxmAddress_5_o = rx_addr_reg[BAR5_TYPE-1:0];

assign RxmByteEnable_0_o[3:0] = rx_fbe_reg;
assign RxmByteEnable_1_o[3:0] = rx_fbe_reg;
assign RxmByteEnable_2_o[3:0] = rx_fbe_reg;
assign RxmByteEnable_3_o[3:0] = rx_fbe_reg;
assign RxmByteEnable_4_o[3:0] = rx_fbe_reg;
assign RxmByteEnable_5_o[3:0] = rx_fbe_reg;

/// Read Completion data

  // tie off the unavailable interface input to prevent X propagation
  /// Tie off the inputs when not available

    assign rxm_read_data_valid_0 = RxmReadDataValid_0_i;
    assign rxm_wait_request_0    = RxmWaitRequest_0_i;  
    assign rxm_read_data_0       = RxmReadData_0_i;     


generate if (BAR1_TYPE <= 1)  
  begin
    assign rxm_read_data_valid_1 = 1'b0;
    assign rxm_wait_request_1    = 1'b0;
    assign rxm_read_data_1       = 64'h0;
  end
else
  begin
    assign rxm_read_data_valid_1 = RxmReadDataValid_1_i; 
    assign rxm_wait_request_1    = RxmWaitRequest_1_i & bar_decode_reg[1]; 
    assign rxm_read_data_1       = RxmReadData_1_i;
  end
endgenerate


generate if (BAR2_TYPE <= 1)  
  begin
    assign rxm_read_data_valid_2 = 1'b0;
    assign rxm_wait_request_2    = 1'b0;
    assign rxm_read_data_2       = 64'h0;
  end
else
  begin
    assign rxm_read_data_valid_2 = RxmReadDataValid_2_i; 
    assign rxm_wait_request_2    = RxmWaitRequest_2_i & bar_decode_reg[2]; 
    assign rxm_read_data_2       = RxmReadData_2_i;
  end
endgenerate


generate if (BAR3_TYPE <= 1)  
  begin
    assign rxm_read_data_valid_3 = 1'b0;
    assign rxm_wait_request_3    = 1'b0;
    assign rxm_read_data_3       = 64'h0;
  end
else
  begin
    assign rxm_read_data_valid_3 = RxmReadDataValid_3_i; 
    assign rxm_wait_request_3    = RxmWaitRequest_3_i & & bar_decode_reg[3]; 
    assign rxm_read_data_3       = RxmReadData_3_i;
  end
endgenerate


generate if (BAR4_TYPE <= 1)  
  begin
    assign rxm_read_data_valid_4 = 1'b0;
    assign rxm_wait_request_4    = 1'b0;
    assign rxm_read_data_4       = 64'h0;
  end
else
  begin
    assign rxm_read_data_valid_4 = RxmReadDataValid_4_i; 
    assign rxm_wait_request_4    = RxmWaitRequest_4_i & bar_decode_reg[4]; 
    assign rxm_read_data_4       = RxmReadData_4_i;
  end
endgenerate

generate if (BAR5_TYPE <= 1)  
  begin
    assign rxm_read_data_valid_5 = 1'b0;
    assign rxm_wait_request_5    = 1'b0;
    assign rxm_read_data_5       = 64'h0;
  end
else
  begin
    assign rxm_read_data_valid_5 = RxmReadDataValid_5_i; 
    assign rxm_wait_request_5    = RxmWaitRequest_5_i & bar_decode_reg[5]; 
    assign rxm_read_data_5       = RxmReadData_5_i;
  end
endgenerate


assign rxm_read_data_sel = {rxm_read_data_valid_5 , rxm_read_data_valid_4 , rxm_read_data_valid_3 , rxm_read_data_valid_2 , rxm_read_data_valid_1 , rxm_read_data_valid_0};

always @*   
 begin
  case(rxm_read_data_sel)
    6'b000010 : rxm_read_data = rxm_read_data_1;
    6'b000100 : rxm_read_data = rxm_read_data_2;
    6'b001000 : rxm_read_data = rxm_read_data_3;
    6'b010000 : rxm_read_data = rxm_read_data_4;
    6'b100000 : rxm_read_data = rxm_read_data_5;
    default   : rxm_read_data = rxm_read_data_0;
  endcase
end

  always_ff @ (posedge Clk_i or negedge Rstn_i) 
     begin                
       if(~Rstn_i) 
         begin                  
           rxm_cpl_data_reg  <= 32'b0;
         end                    
       else if(RxmReadDataValid_0_i | RxmReadDataValid_1_i | RxmReadDataValid_2_i | RxmReadDataValid_3_i | RxmReadDataValid_4_i | RxmReadDataValid_5_i)
       begin
           rxm_cpl_data_reg  <= rxm_read_data;
       end
     end 
         
   always_ff @ (posedge Clk_i or negedge Rstn_i) 
     begin                
       if(~Rstn_i) 
           cpl_data_available_reg  <= 1'b0;
       else if(rxm_idle_st)  // idle
           cpl_data_available_reg  <= 1'b0;         
       else if(RxmReadDataValid_0_i | RxmReadDataValid_1_i | RxmReadDataValid_2_i | RxmReadDataValid_3_i | RxmReadDataValid_4_i | RxmReadDataValid_5_i)
           cpl_data_available_reg  <= 1'b1;
     end          
        
// Forming the Completion TLP
always @(rx_fbe_reg)   // only first completion uses the fbe for byte count
 begin
  case(rx_fbe_reg)
    4'b0001 : normal_byte_count = 12'h1;
    4'b0010 : normal_byte_count = 12'h1;
    4'b0100 : normal_byte_count = 12'h1;
    4'b1000 : normal_byte_count = 12'h1;
    4'b0011 : normal_byte_count = 12'h2;
    4'b0110 : normal_byte_count = 12'h2;
    4'b1100 : normal_byte_count = 12'h2;
    4'b0111 : normal_byte_count = 12'h3;
    4'b1110 : normal_byte_count = 12'h3;
    default : normal_byte_count = 12'h4;
  endcase
end

always @*  // only first completion uses the fbe for byte count
 begin
  case({rx_fbe_reg, rx_lbe_reg})
    8'b1000_0001 : abort_byte_count = rx_byte_len_reg - 6;
    8'b1000_0011 : abort_byte_count = rx_byte_len_reg - 5;
    8'b1000_1111 : abort_byte_count = rx_byte_len_reg - 3;
    
    8'b1100_0001 : abort_byte_count = rx_byte_len_reg - 5;
    8'b1100_0011 : abort_byte_count = rx_byte_len_reg - 4;
    8'b1100_1111 : abort_byte_count = rx_byte_len_reg - 2;
    
    8'b1111_0001 : abort_byte_count = rx_byte_len_reg - 3;
    8'b1111_0011 : abort_byte_count = rx_byte_len_reg - 2;
    default      : abort_byte_count = rx_byte_len_reg;
  endcase
end    
      
assign remain_bytes = is_flush_reg? 12'h1 : ~is_valid_read_reg? abort_byte_count: normal_byte_count;  
assign dw_len = (tx_cpl_req & ~is_valid_read_reg)?  10'h0 : 10'h1;   // abort is cpl wod
      
// calculate the 7 bit lower address of the first enable byte
// based on the first byte enable

always @(rx_fbe_reg, is_flush_reg, rx_addr_reg)
 begin
  casex({rx_fbe_reg, is_flush_reg})
    5'bxxx10 : lower_addr = {rx_addr_reg[6:2], 2'b00};
    5'bxx100 : lower_addr = {rx_addr_reg[6:2], 2'b01};
    5'bx1000 : lower_addr = {rx_addr_reg[6:2], 2'b10};
    5'b10000 : lower_addr = {rx_addr_reg[6:2], 2'b11};
    5'bxxxx1 : lower_addr = {rx_addr_reg[6:2], 2'b00};
    default  : lower_addr = 7'b0000000;
  endcase
end      

    
assign cpl_header = {     cpl_req_id_reg, cpl_tag_reg, 1'b0,lower_addr,  
                          CfgBusDev_i,3'b000, ~is_valid_read_reg ,3'b000, remain_bytes,                                      
                          1'b0, is_valid_read_reg, 6'b001010, 1'b0, cpl_tc_reg, 4'h0, 2'h0, cpl_attr_reg, 2'b00, dw_len
                     }; 
                           
      
assign tx_tlp_data[255:0] = {64'h0,32'h0,rxm_cpl_data_reg,rxm_cpl_data_reg,cpl_header};
assign tx_tlp_sop         = tx_cpl_send;
assign tx_tlp_eop         = tx_cpl_send;
assign tx_tlp_empty[1:0]  = addr_bit2_reg? 2'b10 : 2'b01;

assign tx_fifo_wrdata[259:0] = {tx_tlp_empty, tx_tlp_eop, tx_tlp_sop, tx_tlp_data};
assign tx_fifo_wrreq         = tx_cpl_send;

// Rx Fifo interface
assign RxFifoRdReq_o = (~rx_fifo_empty & (is_read | is_write) & rx_sop & rxm_idle_st ) | dump_rx_buffer | rxm_pop_tlp_st;

// Tx fifo interface
assign   TxFifoWrReq_o = tx_fifo_wrreq;
assign   TxFifoData_o  = tx_fifo_wrdata;
                        
 
endmodule  