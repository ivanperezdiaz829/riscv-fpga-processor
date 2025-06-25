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


module altpcieav_dma_rd # (

      parameter DMA_WIDTH                       = 256,
      parameter DMA_BE_WIDTH                    = 5,
      parameter DMA_BRST_CNT_W                  = 4,
      parameter RDDMA_AVL_ADDR_WIDTH            = 20

   )
  (
      input logic                                  Clk_i,
      input logic                                  Rstn_i,

      // Avalon-MM Interface
      output  logic                                RdDmaWrite_o,
      output  logic  [63:0]                        RdDmaAddress_o,
      output  logic  [DMA_WIDTH-1:0]               RdDmaWriteData_o,
      output  logic  [4:0]                         RdDmaBurstCount_o,
      output  logic  [DMA_BE_WIDTH-1:0]            RdDmaWriteEnable_o,
      input   logic                                RdDmaWaitRequest_i,

      /// AST Inteface
      // Read DMA AST Rx port
      input   logic  [159:0]                       RdDmaRxData_i,
      input   logic                                RdDmaRxValid_i,
      output  logic                                RdDmaRxReady_o,

      // Read DMA AST Tx port
      output   logic  [31:0]                       RdDmaTxData_o,
      output   logic                               RdDmaTxValid_o,

      // Rx fifo Interface
      output logic                                 RxFifoRdReq_o,
      input  logic [265:0]                         RxFifoDataq_i,
      input  logic [3:0]                           RxFifoCount_i,
      
      /// Tag predecode
      output  logic                                 PreDecodeTagRdReq_o,   
      input   logic [7:0]                           PreDecodeTag_i,        
      input   logic [3:0]                           PreDecodeTagCount_i,  

      // Tx fifo Interface
      output logic                                 TxFifoWrReq_o,
      output logic [259:0]                         TxFifoData_o,
      input  logic [3:0]                           TxFifoCount_i,

      // General CRA interface
      input                                        RdDMACntrlLoad_i,
      input   logic [31:0]                         RdDMACntrlData_i,
      output  logic [31:0]                         RdDMAStatus_o,

       // Arbiter Interface
      output  logic                                RdDMmaArbReq_o,
      input   logic                                RdDMmaArbGranted_i,

      input   logic   [12:0]                       BusDev_i,
      input   logic   [31:0]                       DevCsr_i,       
      input   logic                                MasterEnable_i


  );

  localparam  RD_IDLE                = 9'h001;
  localparam  RD_POP_DESC            = 9'h002;
  localparam  RD_ARB_REQ             = 9'h004;
  localparam  RD_SEND                = 9'h008;
  localparam  RD_WAIT_TAG            = 9'h010;
  localparam  RD_PAUSE               = 9'h020;
  localparam  RD_PIPE                = 9'h040;
  localparam  RD_CHECK_SUB_DESC      = 9'h080;
  localparam  RD_LD_SUB_DESC         = 9'h100;


  localparam RDCPL_IDLE             = 2'b01;
  localparam RDCPL_WRITE            = 2'b10;




  logic                                 flush_all_desc;
  logic                                 rd_pop_desc_state;
  logic  [159:0]                        desc_head;
  logic  [3:0]                          desc_fifo_count;
  logic                                 desc_fifo_wrreq;
  logic  [159:0]                        desc_fifo_wrdat;
  logic  [63:0]                         cur_dest_addr_reg;
  logic  [63:0]                         cur_src_addr_reg;
  logic                                 rd_header_state;
  logic  [7:0]                          cur_desc_id_reg;
  logic                                 cur_dma_abort_reg;
  logic                                 cur_dma_pause_reg;
  logic                                 cur_dma_pause;
  logic                                 flush_all_desc_reg;
  logic                                 cur_dma_abort;
  logic                                 cur_dma_resume_reg;
  logic                                 cur_dma_resume;
  logic                                 rd_pause_state;
  logic  [17:0]                         remain_dwcnt_reg;      
  logic  [9:0]                          adjusted_dw_count;    
  logic  [9:0]                          adjusted_dw_count_reg;   
  
  logic  [9:0]                          rd_dw_size; 
  logic  [9:0]                          rd_dw_size_reg;
  logic  [9:0]                          cur_dest_end_addr;
  logic  [9:0]                          max_rd_dw;   
  logic  [9:0]                          max_rd; 
  
  logic  [10:0]                         dw_to_4KB;     
  logic  [10:0]                         dw_to_128;           
  logic  [10:0]                         dw_to_256;   
  logic  [10:0]                         dw_to_512;     
  
  logic                                 alignment_sel;
  logic                                 to_4KB_sel;
  logic                                 remain_dw_sel;
  logic  [1:0]                          rdsize_sel_reg;
  logic                                 last_rd_segment;
  logic  [8:0]                          rd_dma_state;
  logic  [8:0]                          rd_dma_nxt_state;
  logic                                 desc_fifo_empty;
  logic                                 tag_available;


  logic                                 rd_arb_req_state;
  logic                                 rd_arb_req_state_reg;
  logic                                 arbiter_req_rise;
  logic                                 tag_fifo_wrreq;
  logic                                 tag_fifo_rdreq;
  logic  [3:0]                          tag_fifo_wrdat;
  logic  [3:0]                          tag;
  logic  [4:0]                          tag_fifo_count;
  logic  [5:0]                          tag_counter;
  logic  [7:0]                          rd_tag_reg;
  logic  [31:0]                         first_avmm_be;
  logic  [7:0]                          tag_desc_id_reg [16];
  logic [RDDMA_AVL_ADDR_WIDTH-1:0]      tag_address_reg [16];
  logic [31:0]                          tag_fbe_reg [16];
  logic [9:0]                           tag_remain_dw_reg[16];
  logic [9:0]                           remain_dw;
  logic [15:0]                           tag_desc_last_rd_reg;
  logic                                 cpl_update_tag;
  logic [RDDMA_AVL_ADDR_WIDTH-1:0]      next_dest_addr_reg;
  logic [RDDMA_AVL_ADDR_WIDTH-1:0]      avmm_addr_reg;
  logic [1:0]                           rd_cpl_state;
  logic [1:0]                           rdcpl_nxt_state;
  logic                                 rx_sop;
  logic                                 rx_eop_reg;
  logic [9:0]                           rx_dwlen;
  logic [7:0]                           cpl_tag;
  logic [7:0]                           rx_cpl_addr;
  logic                                 addr_bit2;
  logic [11:0]                          cpl_bytecount;
  logic                                 is_cpl_wd;
  logic                                 last_cpl;
  logic [255:0]                         avmm_write_data;
  
  logic [31:0]                          avmm_write_data_dw0;
  logic [31:0]                          avmm_write_data_dw1;
  logic [31:0]                          avmm_write_data_dw2;
  logic [31:0]                          avmm_write_data_dw3;
  logic [31:0]                          avmm_write_data_dw4;
  logic [31:0]                          avmm_write_data_dw5;
  logic [31:0]                          avmm_write_data_dw6;
  logic [31:0]                          avmm_write_data_dw7;
  
  logic                                 rdcpl_idle_state;
  logic                                 rdcpl_write_state;
  logic [7:0]                           first_valid_addr;
  logic                                 rd_idle_state;
  logic                                 is_rd32;
  logic [7:0]                           cmd;
  logic [15:0]                          requestor_id;
  logic [31:0]                          tlp_dw2;
  logic [31:0]                          tlp_dw3;
  logic [63:0]                          req_header1;
  logic [63:0]                          req_header2;
  logic [12:0]                          bytes_to_4KB;                   
  logic [7:0]                           bytes_to_128; 
  logic [8:0]                           bytes_to_256;
  logic [9:0]                           bytes_to_512;  

  logic [265:0]                         tlp_reg;
  logic [31:0]                          tlp_reg_dw0;
  logic [31:0]                          tlp_reg_dw1;
  logic [31:0]                          tlp_reg_dw2;
  logic [31:0]                          tlp_reg_dw3;
  logic [31:0]                          tlp_reg_dw4;
  logic [31:0]                          tlp_reg_dw5;
  logic [31:0]                          tlp_reg_dw6;
  logic [31:0]                          tlp_reg_dw7;
  logic [265:0]                         tlp_hold_reg;
  logic [31:0]                          tlp_hold_reg_dw4;
  logic [31:0]                          tlp_hold_reg_dw5;
  logic [31:0]                          tlp_hold_reg_dw6;
  logic [31:0]                          tlp_hold_reg_dw7;
  logic [265:0]                         tlp_fifo;
  logic [31:0]                          tlp_fifo_dw0;
  logic [31:0]                          tlp_fifo_dw1;
  logic [31:0]                          tlp_fifo_dw2;
  logic [31:0]                          tlp_fifo_dw3;
  
  logic [31:0]                          avmm_fbe_reg;
  logic [31:0]                          tag_first_enable_reg;
  logic                                 avmm_first_write_reg;
  logic [31:0]                          avmm_lbe_reg;          
  logic [31:0]                          avmm_fbe;    
  logic [31:0]                          avmm_fbe_pre;  
  logic [7:0]                           cpl_desc_id_reg;
  logic                                 last_cpl_reg;
  logic [7:0]                           cpl_tag_reg;
  logic [9:0]                           rx_dwlen_reg;
  logic [4:0]                           avmm_burst_cnt_reg;
  logic [4:0]                           avmm_burst_cntr;
  logic                                 cpl_addr_bit2;
  logic                                 cpl_addr_bit2_reg;
  logic [1:0]                           tx_tlp_empty;
  logic                                 desc_busy;
  logic                                 rx_fifo_empty;
  logic                                 tag_release;
  logic                                 latch_header;
  logic                                 latch_header_from_write_state;
  logic                                 latch_header_from_idle_state;
  logic                                 latch_header_reg;
  logic  [63:0]                         sub_desc_src_addr_reg;
  logic  [63:0]                         sub_desc_dest_addr_reg;
  logic  [17:0]                         sub_desc_length_reg;
  logic                                 sub_desc_load;
  logic                                 sub_desc_load_reg;
  logic  [12:0]                         bytes_to_4K;
  logic  [10:0]                         dw_to_4K;
  logic  [63:0]                         next_sub_src_addr;
  logic  [63:0]                         next_sub_dest_addr;
  logic  [17:0]                         next_length;
  logic                                 rd_check_sub_desc_state;
  logic                                 load_cur_desc_size;
  logic                                 load_cur_desc_size_reg;
  logic                                 rd_pipe_state;
  logic                                 last_sub_desc_reg;
  logic                                 last_sub_desc;
  logic                                 rd_pipe_state_reg;
  logic  [17:0]                         main_desc_remain_length_reg;
  logic  [17:0]                         orig_desc_dw_reg;
  logic  [17:0]                         culmutive_sent_dw;
  logic  [17:0]                         culmutive_remain_dw;
  logic  [15:0]                          tag_outstanding_reg;
  logic                                 last_desc_cpl_reg;
  logic                                 rd_header_state_reg;
  logic                                 cpl_on_progress_sreg;
  logic                                 tx_fifo_ok;
  logic                                 tag_release_queuing;
  logic                                 tag_queu_rdreq;
  logic [3:0]                           released_tag;
  logic [3:0]                           tag_queu_count;
  logic                                 write_stall_reg;
  logic [10:0]                          dw_to_legal_bound;
  logic [4:0]                           avmm_burst_cnt;        
  logic [9:0]                           first_dw_holes;  
  logic [9:0]                           first_dw_holes_pre;  
  logic [9:0]                           first_dw_holes_pre_reg;     
  logic [9:0]                           empty_dw_reg;
  logic [31:0]                          updated_fbe;  
  logic [31:0]                          updated_fbe_reg;  
  logic [31:0]                          adjusted_avmm_fbe;
  logic [31:0]                          adjusted_avmm_lbe;
  logic                                 desc_completed;
  logic                                 desc_flushed;  
  logic                                 desc_aborted;  
  logic                                 desc_paused;        
  logic [4:0]                           flush_count;
  logic                                 b2b_same_tag;      
  logic                                 valid_cpl_available;
  
  

always_comb
  begin
    case(DevCsr_i[14:12])
      3'b000  : max_rd_dw = 32;
      3'b001  : max_rd_dw = 64;
      default : max_rd_dw = 128;
    endcase
  end

  // Descriptor FIFO
   altpcie_fifo
   #(
    .FIFO_DEPTH(6),
    .DATA_WIDTH(160)
    )
 read_desc_fifo
(
      .clk(Clk_i),
      .rstn(Rstn_i),
      .srst(flush_all_desc & RdDMACntrlLoad_i ),
      .wrreq(desc_fifo_wrreq),
      .rdreq(rd_pop_desc_state),
      .data(desc_fifo_wrdat),
      .q(desc_head),
      .fifo_count(desc_fifo_count)
);
assign desc_fifo_empty = (desc_fifo_count == 0);
assign desc_fifo_wrreq   = RdDmaRxValid_i;
assign desc_fifo_wrdat   = RdDmaRxData_i;

/// current descriptor

  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           cur_dest_addr_reg <= 64'h0;
       else if(rd_pop_desc_state)
           cur_dest_addr_reg <= desc_head[127:64];
       else if(rd_header_state)
           cur_dest_addr_reg <=  cur_dest_addr_reg + {rd_dw_size, 2'b00};
     end


  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         cur_src_addr_reg  <= 64'h0;
       else if(rd_pop_desc_state)
         cur_src_addr_reg  <= desc_head[63:0];
       else if (rd_header_state)
         cur_src_addr_reg  <= cur_src_addr_reg + {rd_dw_size[9:0], 2'b00};
     end


  /// current Desc ID

      always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
        begin
         cur_desc_id_reg  <= 8'h0;
         orig_desc_dw_reg <= 18'h0;
        end
       else if(rd_pop_desc_state)
        begin
         cur_desc_id_reg  <= desc_head[153:146];
         orig_desc_dw_reg      <= desc_head[145:128];
        end

     end
/// current desc control reg

assign cur_dma_pause = RdDMACntrlData_i[0];
assign cur_dma_resume = RdDMACntrlData_i[1];
assign cur_dma_abort = RdDMACntrlData_i[2];
assign flush_all_desc = RdDMACntrlData_i[3];

 always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         begin
           cur_dma_abort_reg  <= 1'b0;
           flush_all_desc_reg <= 1'b0;
         end
       else if(RdDMACntrlLoad_i)
         begin
           cur_dma_abort_reg  <=  cur_dma_abort;
           flush_all_desc_reg <=  flush_all_desc;
         end
       else if ((cur_dma_abort_reg | flush_all_desc_reg) & rd_idle_state)
         begin
           cur_dma_abort_reg  <= 1'b0;
           flush_all_desc_reg <= 1'b0;
         end
     end


 always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         begin
           cur_dma_pause_reg  <= 1'b0;
         end
       else if(RdDMACntrlLoad_i)
         begin
           cur_dma_pause_reg  <= cur_dma_pause;
         end
       else if (cur_dma_pause_reg & cur_dma_resume_reg)
         begin
           cur_dma_pause_reg  <= 1'b0;
         end
     end

always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         begin
           cur_dma_resume_reg <= 1'b0;
         end
       else if(RdDMACntrlLoad_i)
         begin
           cur_dma_resume_reg <=  cur_dma_resume;
         end
       else if (~rd_pause_state)
         begin
           cur_dma_resume_reg  <= 1'b0;
         end
     end

/// for un-aligned DMA where the address is not 32*n, the first TLP will bring it to 32-bytes aligned address



  /// the reaming byte count after a read TLP is sent
  /// for the current sub descriptor
always @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      remain_dwcnt_reg <= 18'h0;
    else if(rd_pipe_state)
      remain_dwcnt_reg <=(orig_desc_dw_reg <= dw_to_4KB)? orig_desc_dw_reg : dw_to_4KB;
    else if(load_cur_desc_size_reg)
       remain_dwcnt_reg <= sub_desc_length_reg[17:0];
    else if(rd_header_state)
      remain_dwcnt_reg <= remain_dwcnt_reg - rd_dw_size;
  end

  assign bytes_to_4KB = (cur_src_addr_reg[11:0] == 12'h0)? 13'h1000 : (13'h1000 - cur_src_addr_reg[11:0]);   
  assign bytes_to_128[7:0] = (cur_src_addr_reg[6:0] == 7'h0)? 8'h80 : (8'h80 - cur_src_addr_reg[6:0]);     
  assign bytes_to_256[8:0] = (cur_src_addr_reg[7:0] == 8'h0)? 9'h100 : (9'h100 - cur_src_addr_reg[7:0]);   
  assign bytes_to_512[9:0] = (cur_src_addr_reg[8:0] == 9'h0)? 10'h200 : (10'h200 - cur_src_addr_reg[8:0]);
  
  assign dw_to_4KB   = bytes_to_4KB[12:2];
  assign dw_to_128   = {5'h0, bytes_to_128[7:2]};  
  assign dw_to_256   = {4'h0, bytes_to_256[8:2]};   
  assign dw_to_512   = {3'h0, bytes_to_512[9:2]};
  
  always_comb
    begin
      case(max_rd_dw)   
        10'd32 : max_rd = dw_to_128;
        10'd64 : max_rd = dw_to_256;  
        default: max_rd = dw_to_512;
      endcase
    end


 assign  to_4KB_sel       = 1'b0;
 assign  remain_dw_sel    = (remain_dwcnt_reg <= max_rd) & (remain_dwcnt_reg <= dw_to_4KB);

 always @(posedge Clk_i or negedge Rstn_i)
    begin
      if(~Rstn_i)
        begin
          rdsize_sel_reg <= 2'b00;
          rd_dw_size_reg[9:0] <= 10'h0; 
        end
      else
        begin
          rdsize_sel_reg <= {remain_dw_sel,to_4KB_sel};
          rd_dw_size_reg[9:0] <= rd_dw_size;
      end
    end

  always_comb
    begin
      case(rdsize_sel_reg)
        2'b10  :  rd_dw_size   = remain_dwcnt_reg;
        default:  rd_dw_size   = max_rd;
      endcase
    end


 assign last_rd_segment = ((remain_dwcnt_reg <= max_rd) & (remain_dwcnt_reg <= dw_to_4KB) );


/// Read control state machine

assign tx_fifo_ok = (TxFifoCount_i <= 4'hD);

  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           rd_dma_state <= RD_IDLE;
         else
           rd_dma_state <= rd_dma_nxt_state;
     end

 always_comb
  begin
    case(rd_dma_state)
      RD_IDLE :
        if(~desc_fifo_empty & MasterEnable_i)
          rd_dma_nxt_state <= RD_POP_DESC;
        else
          rd_dma_nxt_state <= RD_IDLE;

      RD_POP_DESC:
          rd_dma_nxt_state <= RD_PIPE;

     RD_PIPE:
       if(tag_available)
          rd_dma_nxt_state <= RD_ARB_REQ;
        else
          rd_dma_nxt_state <= RD_WAIT_TAG;

      RD_ARB_REQ:
        if(cur_dma_abort_reg | flush_all_desc_reg)
          rd_dma_nxt_state <= RD_IDLE;
        else if(cur_dma_pause_reg)
          rd_dma_nxt_state <= RD_PAUSE;
        else if(RdDMmaArbGranted_i & tx_fifo_ok)
          rd_dma_nxt_state <= RD_SEND;
        else
          rd_dma_nxt_state <= RD_ARB_REQ;

      RD_SEND:
        if(cur_dma_abort_reg | flush_all_desc_reg) 
          rd_dma_nxt_state <= RD_IDLE;
        else if(last_rd_segment)
          rd_dma_nxt_state <= RD_CHECK_SUB_DESC;
        else if(cur_dma_pause_reg)
          rd_dma_nxt_state <= RD_PAUSE;
        else if(tag_available)
          rd_dma_nxt_state <= RD_ARB_REQ;
        else
          rd_dma_nxt_state <= RD_WAIT_TAG;

      RD_WAIT_TAG:
        if(tag_available)
          rd_dma_nxt_state <= RD_ARB_REQ;
        else
         rd_dma_nxt_state <= RD_WAIT_TAG;

       RD_PAUSE:
         if(cur_dma_resume_reg & tag_available)
            rd_dma_nxt_state <= RD_ARB_REQ;
         else
           rd_dma_nxt_state <= RD_PAUSE;

      RD_CHECK_SUB_DESC:
        if(last_sub_desc_reg)
           rd_dma_nxt_state <= RD_IDLE;
        else
           rd_dma_nxt_state <= RD_LD_SUB_DESC;

      RD_LD_SUB_DESC:
         if(tag_available)
          rd_dma_nxt_state <= RD_ARB_REQ;
        else
          rd_dma_nxt_state <= RD_WAIT_TAG;

      default:
        rd_dma_nxt_state <= RD_IDLE;
    endcase
  end

  // state assignment
  assign rd_idle_state      = rd_dma_state[0];
  assign rd_pop_desc_state  = rd_dma_state[1];
  assign rd_header_state    = rd_dma_state[3];
  assign rd_arb_req_state   = rd_dma_state[2];
  assign rd_pause_state     = rd_dma_state[5];
  assign rd_pipe_state      = rd_dma_state[6];
  assign rd_check_sub_desc_state  = rd_dma_state[7];
  assign load_cur_desc_size  = rd_dma_state[8];

  assign sub_desc_load =  rd_check_sub_desc_state & ~last_sub_desc_reg;

  assign RdDMmaArbReq_o =  rd_arb_req_state;

/// tag management

     altpcie_fifo
   #(
    .FIFO_DEPTH(16),
    .DATA_WIDTH(4)
    )
 tag_fifo
(
      .clk(Clk_i),
      .rstn(Rstn_i),
      .srst(1'b0),
      .wrreq(tag_fifo_wrreq),
      .rdreq(tag_fifo_rdreq),
      .data(tag_fifo_wrdat),
      .q(tag),
      .fifo_count(tag_fifo_count)
);


   always_ff @(posedge Clk_i or negedge Rstn_i)
         begin
           if(~Rstn_i)
            begin
              rd_arb_req_state_reg <= 1'b0;
              sub_desc_load_reg <= 1'b0;
              load_cur_desc_size_reg <= 1'b0;
              rd_header_state_reg <= 1'b0;
            end
           else
            begin
              rd_arb_req_state_reg <= rd_arb_req_state;
              sub_desc_load_reg    <= sub_desc_load;
              load_cur_desc_size_reg   <= load_cur_desc_size;
              rd_header_state_reg <= rd_header_state;
            end
         end

assign  arbiter_req_rise =  ~rd_arb_req_state_reg & rd_arb_req_state;

/// init counter
 always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           tag_counter <= 6'h0;
         else if(tag_counter < 6'b100000 )
           tag_counter <= tag_counter + 1;
     end

 assign tag_fifo_wrreq = (tag_counter[5:4] == 2'b01) | tag_release; /// 8 consecutive writes to initialize 8 tags
 assign tag_fifo_wrdat[3:0] = (tag_counter[5:4] == 2'b01)? tag_counter[3:0] : released_tag[3:0];

  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           rd_tag_reg <= 8'h0;
         else if(tag_fifo_rdreq)
           rd_tag_reg <= {4'b0000, tag[3:0]};
     end


 assign tag_available = (tag_fifo_count != 0) & (  (~tag_outstanding_reg[0] & tag[3:0] == 4'h0)  |
                                                   (~tag_outstanding_reg[1] & tag[3:0] == 4'h1)  |
                                                   (~tag_outstanding_reg[2] & tag[3:0] == 4'h2)  |
                                                   (~tag_outstanding_reg[3] & tag[3:0] == 4'h3)  |
                                                   (~tag_outstanding_reg[4] & tag[3:0] == 4'h4)  |
                                                   (~tag_outstanding_reg[5] & tag[3:0] == 4'h5)  |
                                                   (~tag_outstanding_reg[6] & tag[3:0] == 4'h6)  |
                                                   (~tag_outstanding_reg[7] & tag[3:0] == 4'h7)  |
                                                   (~tag_outstanding_reg[8] & tag[3:0] == 4'h8)  |
                                                   (~tag_outstanding_reg[9] & tag[3:0] == 4'h9)  |
                                                   (~tag_outstanding_reg[10] & tag[3:0] == 4'hA)  |
                                                   (~tag_outstanding_reg[11] & tag[3:0] == 4'hB)  |
                                                   (~tag_outstanding_reg[12] & tag[3:0] == 4'hC)  |
                                                   (~tag_outstanding_reg[13] & tag[3:0] == 4'hD)  |
                                                   (~tag_outstanding_reg[14] & tag[3:0] == 4'hE)  |
                                                   (~tag_outstanding_reg[15] & tag[3:0] == 4'hF)  
                                                 );
 //  assign tag_available = 1'b1;
 assign tag_fifo_rdreq = arbiter_req_rise;


 // calculate first byte enable for the first TLP     
 
 
 
 
 
 
always_comb
  begin
    case(cur_dest_addr_reg[4:0])
        5'h0:
            case (rd_dw_size_reg)
              10'h1 :  first_avmm_be[31:0] = 32'h0000_000F;
              10'h2 :  first_avmm_be[31:0] = 32'h0000_00FF;
              10'h3 :  first_avmm_be[31:0] = 32'h0000_0FFF;
              10'h4 :  first_avmm_be[31:0] = 32'h0000_FFFF;
              10'h5 :  first_avmm_be[31:0] = 32'h000F_FFFF;
              10'h6 :  first_avmm_be[31:0] = 32'h00FF_FFFF;
              10'h7 :  first_avmm_be[31:0] = 32'h0FFF_FFFF;
              default: first_avmm_be[31:0] = 32'hFFFF_FFFF;
            endcase
        5'h4:
            case (rd_dw_size_reg)
              10'h1 :  first_avmm_be[31:0] = 32'h0000_00F0;
              10'h2 :  first_avmm_be[31:0] = 32'h0000_0FF0;
              10'h3 :  first_avmm_be[31:0] = 32'h0000_FFF0;
              10'h4 :  first_avmm_be[31:0] = 32'h000F_FFF0;
              10'h5 :  first_avmm_be[31:0] = 32'h00FF_FFF0;
              10'h6 :  first_avmm_be[31:0] = 32'h0FFF_FFF0;
              10'h7 :  first_avmm_be[31:0] = 32'hFFFF_FFF0;
              default: first_avmm_be[31:0] = 32'hFFFF_FFF0;
            endcase
         5'h8:
            case (rd_dw_size_reg)
              10'h1 :  first_avmm_be[31:0] = 32'h0000_0F00;
              10'h2 :  first_avmm_be[31:0] = 32'h0000_FF00;
              10'h3 :  first_avmm_be[31:0] = 32'h000F_FF00;
              10'h4 :  first_avmm_be[31:0] = 32'h00FF_FF00;
              10'h5 :  first_avmm_be[31:0] = 32'h0FFF_FF00;
              10'h6 :  first_avmm_be[31:0] = 32'hFFFF_FF00;
              default: first_avmm_be[31:0] = 32'hFFFF_FF00;
            endcase
          5'hC:
            case (rd_dw_size_reg)
              10'h1 :  first_avmm_be[31:0] = 32'h0000_F000;
              10'h2 :  first_avmm_be[31:0] = 32'h000F_F000;
              10'h3 :  first_avmm_be[31:0] = 32'h00FF_F000;
              10'h4 :  first_avmm_be[31:0] = 32'h0FFF_F000;
              10'h5 :  first_avmm_be[31:0] = 32'hFFFF_F000;
              default: first_avmm_be[31:0] = 32'hFFFF_F000;
            endcase
          5'h10:
            case (rd_dw_size_reg)
              10'h1 :  first_avmm_be[31:0] = 32'h000F_0000;
              10'h2 :  first_avmm_be[31:0] = 32'h00FF_0000;
              10'h3 :  first_avmm_be[31:0] = 32'h0FFF_0000;
              10'h4 :  first_avmm_be[31:0] = 32'hFFFF_0000;
              default: first_avmm_be[31:0] = 32'hFFFF_0000;
            endcase
          5'h14:
            case (rd_dw_size_reg)
              10'h1 :  first_avmm_be[31:0] = 32'h00F0_0000;
              10'h2 :  first_avmm_be[31:0] = 32'h0FF0_0000;
              10'h3 :  first_avmm_be[31:0] = 32'hFFF0_0000;
              default: first_avmm_be[31:0] = 32'hFFF0_0000;
            endcase
          5'h18:
            case (rd_dw_size_reg)
              10'h1 :  first_avmm_be[31:0] = 32'h0F00_0000;
              10'h2 :  first_avmm_be[31:0] = 32'hFF00_0000;
              default: first_avmm_be[31:0] = 32'hFF00_0000;
            endcase
         5'h1C:
            case (rd_dw_size_reg)
              10'h1 :  first_avmm_be[31:0] = 32'hF000_0000;
              default: first_avmm_be[31:0] = 32'hF000_0000;
            endcase
       default: first_avmm_be[31:0] = 32'hFFFF_FFFF;
      endcase
  end
                     
// calculate the updated FBE after each completion
/// based on the first FBE and the Rx CPL length

always_comb
  begin
  	case(adjusted_dw_count_reg[2:0])
  		3'h1 : updated_fbe <= 32'hFFFF_FFF0;
  		3'h2 : updated_fbe <= 32'hFFFF_FF00;
  		3'h3 : updated_fbe <= 32'hFFFF_F000;
  		3'h4 : updated_fbe <= 32'hFFFF_0000;
  		3'h5 : updated_fbe <= 32'hFFF0_0000;    
  		3'h6 : updated_fbe <= 32'hFF00_0000;
  	  3'h7 : updated_fbe <= 32'hF000_0000;	
  	  default:updated_fbe <= 32'hFFFF_FFFF;
  	endcase 
  end
                     
                     
/// calculate the last avalon-MM BE


/// LSB of dest address after each read. Used to calculate the mask last mask of the associated completion
assign cur_dest_end_addr[9:0] = cur_dest_addr_reg[9:0] + {rd_dw_size_reg[7:0], 2'b00};


 /// tag aray
 generate
  genvar i;
  for(i=0; i< 16; i=i+1)
    begin: tag_status_register

  always_ff @(posedge Clk_i or negedge Rstn_i)
    begin
      if(~Rstn_i)
         tag_outstanding_reg[i] <= 1'b0;
      else if(rd_header_state & rd_tag_reg == i)
         tag_outstanding_reg[i] <= 1'b1;
      else if(tag_release & released_tag == i)
         tag_outstanding_reg[i] <= 1'b0;
    end

// marking the last TLP read for this descriptor

  always_ff @(posedge Clk_i or negedge Rstn_i)
    begin
      if(~Rstn_i)
         tag_desc_last_rd_reg[i] <= 1'b0;
      else if(rd_header_state_reg & rd_tag_reg == i & last_sub_desc_reg & remain_dwcnt_reg[11:0] == 0)
         tag_desc_last_rd_reg[i] <= 1'b1;
      else if(tag_release & released_tag == i)
         tag_desc_last_rd_reg[i] <= 1'b0;
    end


    always_ff @(posedge Clk_i or negedge Rstn_i)
         begin
           if(~Rstn_i)
              tag_desc_id_reg[i] <= 16'h0;
           else if(rd_header_state & rd_tag_reg == i)
              tag_desc_id_reg[i] <= cur_desc_id_reg;
         end


      always_ff @(posedge Clk_i or negedge Rstn_i)
         begin
           if(~Rstn_i)
              tag_address_reg[i] <= {(RDDMA_AVL_ADDR_WIDTH){1'b0}};
           else if(rd_header_state & rd_tag_reg == i)
              tag_address_reg[i] <= cur_dest_addr_reg[RDDMA_AVL_ADDR_WIDTH-1:0];
           else if(cpl_update_tag & cpl_tag_reg == i)
              tag_address_reg[i] <= next_dest_addr_reg[RDDMA_AVL_ADDR_WIDTH-1:0];
         end

       always_ff @(posedge Clk_i or negedge Rstn_i)
         begin
           if(~Rstn_i)
              tag_fbe_reg[i] <= 32'hFFFF_FFFF;
           else if(rd_header_state & rd_tag_reg == i)
              tag_fbe_reg[i] <= first_avmm_be[31:0];
           else if(latch_header_reg & cpl_tag_reg == i)
              tag_fbe_reg[i] <= updated_fbe;
         end


// Store the total read DW's for each tag
   always_ff @(posedge Clk_i or negedge Rstn_i)
    begin
      if(~Rstn_i)
         tag_remain_dw_reg[i] <= 10'b0;
      else if(rd_header_state & rd_tag_reg == i )
         tag_remain_dw_reg[i] <= rd_dw_size;
      else if((latch_header & cpl_tag == i))  
         tag_remain_dw_reg[i] <= remain_dw - rx_dwlen;
    end

    end
  endgenerate


/// holding updated FBE values for used in B2B tag case
       always_ff @(posedge Clk_i or negedge Rstn_i)         
         begin                                              
           if(~Rstn_i)                                      
              updated_fbe_reg <= 32'hFFFF_FFFF;              
           else if(latch_header_reg)     
              updated_fbe_reg <= updated_fbe;                
         end

/// Processing the CPL TLP comming back from TLP reads

  assign rx_sop        = RxFifoDataq_i[256];
  assign rx_dwlen      = RxFifoDataq_i[9:0];
  assign cpl_tag       = RxFifoDataq_i[79:72];
  assign rx_cpl_addr   = RxFifoDataq_i[71:64];
  assign cpl_addr_bit2 =  rx_cpl_addr[2];
  assign cpl_bytecount = RxFifoDataq_i[43:32];
  assign is_cpl_wd     = RxFifoDataq_i[30] & (RxFifoDataq_i[28:24]==5'b01010);
  assign last_cpl      = ((cpl_bytecount[11:2] == rx_dwlen ) | (cpl_bytecount <= 8)) & is_cpl_wd & rx_sop;



  assign rx_fifo_empty = (RxFifoCount_i == 4'h0);
   always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           rd_cpl_state <= RDCPL_IDLE;
         else
           rd_cpl_state <= rdcpl_nxt_state;
      end
//////////////////////////////////////////////
//// Completion state machine //////////////
///////////////////////////////////////////////

assign valid_cpl_available = (is_cpl_wd & rx_sop & cpl_tag <= 15 & ~rx_fifo_empty);

always_comb
  begin
    case(rd_cpl_state)
      RDCPL_IDLE :
        if(valid_cpl_available)
          rdcpl_nxt_state <= RDCPL_WRITE;
        else
          rdcpl_nxt_state <= RDCPL_IDLE;
      RDCPL_WRITE:
         if(avmm_burst_cntr == 1 & (~valid_cpl_available | avmm_burst_cnt_reg == 1)  & ~RdDmaWaitRequest_i)
           rdcpl_nxt_state <= RDCPL_IDLE;
         else
            rdcpl_nxt_state <= RDCPL_WRITE;
      default:
   rdcpl_nxt_state <= RDCPL_IDLE;
    endcase
  end

assign rdcpl_idle_state  = rd_cpl_state[0];
assign rdcpl_write_state =  rd_cpl_state[1];

  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         begin
           latch_header_reg <= 1'b0;
           adjusted_dw_count_reg <= 10'h0;
         end
       else
        begin
           latch_header_reg <= latch_header;   
           adjusted_dw_count_reg <= adjusted_dw_count;
        end
      end

// assign tag_release  = latch_header_reg &  last_cpl_reg;

  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           cpl_on_progress_sreg <= 1'b0;
       else if(latch_header)
           cpl_on_progress_sreg <= 1'b1;
       else if(rx_eop_reg)
           cpl_on_progress_sreg <= 1'b0;
      end

assign tag_release_queuing  = (latch_header_reg &  last_cpl_reg & rx_eop_reg)  |
                             (cpl_on_progress_sreg & last_cpl_reg & rx_eop_reg) ;

 altpcie_fifo
   #(
    .FIFO_DEPTH(4),
    .DATA_WIDTH(4)
    )
 tag_queu  // tag release queu
(
      .clk(Clk_i),
      .rstn(Rstn_i),
      .srst(1'b0),
      .wrreq(tag_release_queuing),
      .rdreq(tag_queu_rdreq),
      .data(cpl_tag_reg[3:0]),
      .q(released_tag),
      .fifo_count(tag_queu_count)
);
 always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
          write_stall_reg <= 1'b0;
       else
           write_stall_reg <= rdcpl_write_state & RdDmaWaitRequest_i;
     end

assign tag_queu_rdreq = (tag_queu_count != 0 ) & ~write_stall_reg;
assign tag_release = tag_queu_rdreq;


assign latch_header_from_idle_state   =  (rdcpl_idle_state & (is_cpl_wd & rx_sop & cpl_tag <= 15 & ~rx_fifo_empty));
assign latch_header_from_write_state  =   (rdcpl_write_state & avmm_burst_cntr == 1 & valid_cpl_available   & ~RdDmaWaitRequest_i & avmm_burst_cnt_reg != 1);

assign latch_header = latch_header_from_idle_state |
                      latch_header_from_write_state;

assign cpl_update_tag =  latch_header & ~last_cpl_reg;
assign next_dest_addr_reg =  avmm_addr_reg + {rx_dwlen_reg[9:0], 2'b00};

// latching the header

assign avmm_burst_cnt[4:0] =(adjusted_dw_count[2:0] == 3'b000)? {1'b0, adjusted_dw_count[6:3]} :  {1'b0, adjusted_dw_count[6:3] + 4'h1};  

  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         begin
           rx_dwlen_reg <= 10'h0;
           avmm_burst_cnt_reg <= 5'h0;
           cpl_addr_bit2_reg  <= 1'b0;
           last_cpl_reg  <= 1'b0;
         end
       else if(latch_header)
         begin
            rx_dwlen_reg <= rx_dwlen;
            avmm_burst_cnt_reg <=avmm_burst_cnt;
            cpl_addr_bit2_reg <= cpl_addr_bit2;
            last_cpl_reg <= last_cpl;
         end
      end
      
      
always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           cpl_tag_reg <= 8'hFE;
       else if(latch_header)
            cpl_tag_reg <= cpl_tag;
       else if(tag_release_queuing)
             cpl_tag_reg <= 8'hFE;
      end

// burst counter

  always_comb  /// decode empty holes
     begin
      casez (updated_fbe_reg[31:0])
         32'h????_??F0: first_dw_holes <= 10'h1;
         32'h????_?F0?: first_dw_holes <= 10'h2;
         32'h????_F0??: first_dw_holes <= 10'h3;
         32'h???F_0???: first_dw_holes <= 10'h4;
         32'h??F0_????: first_dw_holes <= 10'h5;
         32'h?F0?_????: first_dw_holes <= 10'h6;
         32'hF0??_????: first_dw_holes <= 10'h7;
        default      : first_dw_holes <= 10'h0;
    endcase
end

  always_comb  /// predecode empty holes
     begin
      casez (avmm_fbe_pre[31:0])
        
         32'h????_??F0: first_dw_holes_pre <= 10'h1;
         32'h????_?F0?: first_dw_holes_pre <= 10'h2;
         32'h????_F0??: first_dw_holes_pre <= 10'h3;
         32'h???F_0???: first_dw_holes_pre <= 10'h4;
         32'h??F0_????: first_dw_holes_pre <= 10'h5;
         32'h?F0?_????: first_dw_holes_pre <= 10'h6;
         32'hF0??_????: first_dw_holes_pre <= 10'h7;
        default      :  first_dw_holes_pre <= 10'h0;
    endcase
end

  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           first_dw_holes_pre_reg<= 10'h0;
       else
           first_dw_holes_pre_reg <= first_dw_holes_pre;
      end



assign empty_dw_reg = b2b_same_tag?  first_dw_holes : first_dw_holes_pre_reg;


assign adjusted_dw_count = rx_dwlen[6:0] + empty_dw_reg[6:0];



 always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           avmm_burst_cntr <= 5'h0;
       else if(latch_header)
            avmm_burst_cntr <=  (adjusted_dw_count[2:0] == 3'b000)? {1'b0, adjusted_dw_count[6:3]} :  {1'b0, adjusted_dw_count[6:3] + 4'h1};
       else if(rdcpl_write_state & ~RdDmaWaitRequest_i)
            avmm_burst_cntr <= avmm_burst_cntr - 1'b1;
      end

 // pipe register
   always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         begin
           tlp_reg[265:0] <= 266'h0;
         end
       else if(RxFifoRdReq_o)
         begin
            tlp_reg[265:0] <= tlp_fifo;
         end
      end
      
  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           tlp_hold_reg[265:0] <= 266'h0;
       else if(rdcpl_write_state & ~RdDmaWaitRequest_i)
            tlp_hold_reg[265:0] <= tlp_reg;
      end

  assign tlp_fifo[265:0] = RxFifoDataq_i[265:0];
  assign rx_eop_reg = tlp_reg[257];

assign tlp_reg_dw0 = tlp_reg[31:0];
assign tlp_reg_dw1 = tlp_reg[63:32];
assign tlp_reg_dw2 = tlp_reg[95:64];
assign tlp_reg_dw3 = tlp_reg[127:96];
assign tlp_reg_dw4 = tlp_reg[159:128];
assign tlp_reg_dw5 = tlp_reg[191:160];
assign tlp_reg_dw6 = tlp_reg[223:192];
assign tlp_reg_dw7 = tlp_reg[255:224];

assign tlp_hold_reg_dw4 = tlp_hold_reg[159:128];
assign tlp_hold_reg_dw5 = tlp_hold_reg[191:160];
assign tlp_hold_reg_dw6 = tlp_hold_reg[223:192];
assign tlp_hold_reg_dw7 = tlp_hold_reg[255:224];


assign tlp_fifo_dw0 = tlp_fifo[31:0];
assign tlp_fifo_dw1 = tlp_fifo[63:32];
assign tlp_fifo_dw2 = tlp_fifo[95:64];
assign tlp_fifo_dw3 = tlp_fifo[127:96];



 // load the AVMM address and BE registers based on tag

assign b2b_same_tag = (cpl_tag == cpl_tag_reg);
  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           avmm_addr_reg <= {(RDDMA_AVL_ADDR_WIDTH){1'b0}};
       else if(latch_header & ~b2b_same_tag)   
           case (cpl_tag[7:0])
             8'h0 : avmm_addr_reg <= tag_address_reg[0][RDDMA_AVL_ADDR_WIDTH-1:0];
             8'h1 : avmm_addr_reg <= tag_address_reg[1][RDDMA_AVL_ADDR_WIDTH-1:0];
             8'h2 : avmm_addr_reg <= tag_address_reg[2][RDDMA_AVL_ADDR_WIDTH-1:0];
             8'h3 : avmm_addr_reg <= tag_address_reg[3][RDDMA_AVL_ADDR_WIDTH-1:0];
             8'h4 : avmm_addr_reg <= tag_address_reg[4][RDDMA_AVL_ADDR_WIDTH-1:0];
             8'h5 : avmm_addr_reg <= tag_address_reg[5][RDDMA_AVL_ADDR_WIDTH-1:0];
             8'h6 : avmm_addr_reg <= tag_address_reg[6][RDDMA_AVL_ADDR_WIDTH-1:0];
             8'h7 : avmm_addr_reg <= tag_address_reg[7][RDDMA_AVL_ADDR_WIDTH-1:0];       
             8'h8 : avmm_addr_reg <= tag_address_reg[8][RDDMA_AVL_ADDR_WIDTH-1:0]; 
             8'h9 : avmm_addr_reg <= tag_address_reg[9][RDDMA_AVL_ADDR_WIDTH-1:0]; 
             8'hA : avmm_addr_reg <= tag_address_reg[10][RDDMA_AVL_ADDR_WIDTH-1:0]; 
             8'hB : avmm_addr_reg <= tag_address_reg[11][RDDMA_AVL_ADDR_WIDTH-1:0]; 
             8'hC : avmm_addr_reg <= tag_address_reg[12][RDDMA_AVL_ADDR_WIDTH-1:0]; 
             8'hD : avmm_addr_reg <= tag_address_reg[13][RDDMA_AVL_ADDR_WIDTH-1:0]; 
             8'hE : avmm_addr_reg <= tag_address_reg[14][RDDMA_AVL_ADDR_WIDTH-1:0]; 
             8'hF : avmm_addr_reg <= tag_address_reg[15][RDDMA_AVL_ADDR_WIDTH-1:0]; 

             default : avmm_addr_reg <= {(RDDMA_AVL_ADDR_WIDTH){1'b0}};
         endcase
       else if(latch_header)   /// same tag, just update the register not the tag ram
           avmm_addr_reg <= avmm_addr_reg + {rx_dwlen_reg[9:0], 2'b00};
      end
                                            
/// FBE needs ajusted if CPL length is small < 8                                            
   always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           avmm_fbe_reg <= 32'h0;
       else if(latch_header)
             avmm_fbe_reg <=(adjusted_dw_count < 8)? adjusted_avmm_fbe :  avmm_fbe;
       else if(rdcpl_write_state & ~RdDmaWaitRequest_i)
            avmm_fbe_reg <= 32'hFFFF_FFFF;
      end

       always_comb
         begin
          case (cpl_tag[7:0])
             8'h0 : avmm_fbe <= tag_fbe_reg[0];
             8'h1 : avmm_fbe <= tag_fbe_reg[1];
             8'h2 : avmm_fbe <= tag_fbe_reg[2];
             8'h3 : avmm_fbe <= tag_fbe_reg[3];
             8'h4 : avmm_fbe <= tag_fbe_reg[4];
             8'h5 : avmm_fbe <= tag_fbe_reg[5];
             8'h6 : avmm_fbe <= tag_fbe_reg[6];
             8'h7 : avmm_fbe <= tag_fbe_reg[7];
             8'h8 : avmm_fbe <= tag_fbe_reg[8];  
             8'h9 : avmm_fbe <= tag_fbe_reg[9];  
             8'hA : avmm_fbe <= tag_fbe_reg[10];  
             8'hB : avmm_fbe <= tag_fbe_reg[11];  
             8'hC : avmm_fbe <= tag_fbe_reg[12];  
             8'hD : avmm_fbe <= tag_fbe_reg[13];  
             8'hE : avmm_fbe <= tag_fbe_reg[14];  
             8'hF : avmm_fbe <= tag_fbe_reg[15];  
             default : avmm_fbe <= 32'hFFFFFFFF;
           endcase
         end
                 /// predecode
       always_comb
         begin
          case (PreDecodeTag_i[7:0])
             8'h0 : avmm_fbe_pre <= tag_fbe_reg[0];
             8'h1 : avmm_fbe_pre <= tag_fbe_reg[1];
             8'h2 : avmm_fbe_pre <= tag_fbe_reg[2];
             8'h3 : avmm_fbe_pre <= tag_fbe_reg[3];
             8'h4 : avmm_fbe_pre <= tag_fbe_reg[4];
             8'h5 : avmm_fbe_pre <= tag_fbe_reg[5];
             8'h6 : avmm_fbe_pre <= tag_fbe_reg[6];
             8'h7 : avmm_fbe_pre <= tag_fbe_reg[7];
             8'h8 : avmm_fbe_pre <= tag_fbe_reg[8];  
             8'h9 : avmm_fbe_pre <= tag_fbe_reg[9];  
             8'hA : avmm_fbe_pre <= tag_fbe_reg[10];  
             8'hB : avmm_fbe_pre <= tag_fbe_reg[11];  
             8'hC : avmm_fbe_pre <= tag_fbe_reg[12];  
             8'hD : avmm_fbe_pre <= tag_fbe_reg[13];  
             8'hE : avmm_fbe_pre <= tag_fbe_reg[14];  
             8'hF : avmm_fbe_pre <= tag_fbe_reg[15];  
             default : avmm_fbe_pre <= 32'hFFFFFFFF;
           endcase
         end

/// mask some BE for small payload
always_comb
  begin
  	case(adjusted_dw_count[2:0])
  		3'h1 : adjusted_avmm_fbe <= 32'h0000_000F & avmm_fbe[31:0];
  		3'h2 : adjusted_avmm_fbe <= 32'h0000_00FF & avmm_fbe[31:0];
  		3'h3 : adjusted_avmm_fbe <= 32'h0000_0FFF & avmm_fbe[31:0];
  		3'h4 : adjusted_avmm_fbe <= 32'h0000_FFFF & avmm_fbe[31:0];
  		3'h5 : adjusted_avmm_fbe <= 32'h000F_FFFF & avmm_fbe[31:0];    
  		3'h6 : adjusted_avmm_fbe <= 32'h00FF_FFFF & avmm_fbe[31:0];
  	  3'h7 : adjusted_avmm_fbe <= 32'h0FFF_FFFF & avmm_fbe[31:0];	
  	  default:adjusted_avmm_fbe <= 32'h0000_0000;
  	endcase 
  end
             
always_comb
  begin
  	case(adjusted_dw_count[2:0])
  		3'h1 : adjusted_avmm_lbe <= 32'h0000_000F ;
  		3'h2 : adjusted_avmm_lbe <= 32'h0000_00FF ;
  		3'h3 : adjusted_avmm_lbe <= 32'h0000_0FFF ;
  		3'h4 : adjusted_avmm_lbe <= 32'h0000_FFFF ;
  		3'h5 : adjusted_avmm_lbe <= 32'h000F_FFFF ;    
  		3'h6 : adjusted_avmm_lbe <= 32'h00FF_FFFF ;
  	  3'h7 : adjusted_avmm_lbe <= 32'h0FFF_FFFF ;	
  	 default:adjusted_avmm_lbe <= 32'hFFFF_FFFF;
  	endcase 
  end             

   always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           tag_first_enable_reg <= 32'hFFFFFFFF;
       else if(latch_header)
           tag_first_enable_reg <= avmm_fbe;
      end


 always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           avmm_first_write_reg <= 1'b0;
       else if(latch_header)
           avmm_first_write_reg <= 1'b1;
       else if(rdcpl_write_state & ~RdDmaWaitRequest_i)
            avmm_first_write_reg <= 1'b0;
      end

      always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           cpl_desc_id_reg <= 7'h0;
       else if(latch_header)
           case (cpl_tag[7:0])
             8'h0 : cpl_desc_id_reg <= tag_desc_id_reg[0];
             8'h1 : cpl_desc_id_reg <= tag_desc_id_reg[1];
             8'h2 : cpl_desc_id_reg <= tag_desc_id_reg[2];
             8'h3 : cpl_desc_id_reg <= tag_desc_id_reg[3];
             8'h4 : cpl_desc_id_reg <= tag_desc_id_reg[4];
             8'h5 : cpl_desc_id_reg <= tag_desc_id_reg[5];
             8'h6 : cpl_desc_id_reg <= tag_desc_id_reg[6];
             8'h7 : cpl_desc_id_reg <= tag_desc_id_reg[7];
             8'h8 : cpl_desc_id_reg <= tag_desc_id_reg[8];
             8'h9 : cpl_desc_id_reg <= tag_desc_id_reg[9];
             8'hA : cpl_desc_id_reg <= tag_desc_id_reg[10];
             8'hB : cpl_desc_id_reg <= tag_desc_id_reg[11];
             8'hC : cpl_desc_id_reg <= tag_desc_id_reg[12];
             8'hD : cpl_desc_id_reg <= tag_desc_id_reg[13];
             8'hE : cpl_desc_id_reg <= tag_desc_id_reg[14];
             8'hF : cpl_desc_id_reg <= tag_desc_id_reg[15];
             default : cpl_desc_id_reg <= 7'h0;
         endcase
      end


   always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           last_desc_cpl_reg <= 7'h0;
       else if(latch_header)
           case (cpl_tag[7:0])
             8'h0 : last_desc_cpl_reg <= tag_desc_last_rd_reg[0];
             8'h1 : last_desc_cpl_reg <= tag_desc_last_rd_reg[1];
             8'h2 : last_desc_cpl_reg <= tag_desc_last_rd_reg[2];
             8'h3 : last_desc_cpl_reg <= tag_desc_last_rd_reg[3];
             8'h4 : last_desc_cpl_reg <= tag_desc_last_rd_reg[4];
             8'h5 : last_desc_cpl_reg <= tag_desc_last_rd_reg[5];
             8'h6 : last_desc_cpl_reg <= tag_desc_last_rd_reg[6];
             8'h7 : last_desc_cpl_reg <= tag_desc_last_rd_reg[7];
             8'h8 : last_desc_cpl_reg <= tag_desc_last_rd_reg[8];
             8'h9 : last_desc_cpl_reg <= tag_desc_last_rd_reg[9];
             8'hA : last_desc_cpl_reg <= tag_desc_last_rd_reg[10];
             8'hB : last_desc_cpl_reg <= tag_desc_last_rd_reg[11];
             8'hC : last_desc_cpl_reg <= tag_desc_last_rd_reg[12];
             8'hD : last_desc_cpl_reg <= tag_desc_last_rd_reg[13];
             8'hE : last_desc_cpl_reg <= tag_desc_last_rd_reg[14];
             8'hF : last_desc_cpl_reg <= tag_desc_last_rd_reg[15];
             default : last_desc_cpl_reg <= 1'b0;
         endcase
      end
                      
       always_comb
         begin
          case (cpl_tag[7:0])
             8'h0 : remain_dw <= tag_remain_dw_reg[0];
             8'h1 : remain_dw <= tag_remain_dw_reg[1];
             8'h2 : remain_dw <= tag_remain_dw_reg[2];
             8'h3 : remain_dw <= tag_remain_dw_reg[3];
             8'h4 : remain_dw <= tag_remain_dw_reg[4];
             8'h5 : remain_dw <= tag_remain_dw_reg[5];
             8'h6 : remain_dw <= tag_remain_dw_reg[6];
             8'h7 : remain_dw <= tag_remain_dw_reg[7];
             8'h8 : remain_dw <= tag_remain_dw_reg[8];  
             8'h9 : remain_dw <= tag_remain_dw_reg[9];  
             8'hA : remain_dw <= tag_remain_dw_reg[10];  
             8'hB : remain_dw <= tag_remain_dw_reg[11];  
             8'hC : remain_dw <= tag_remain_dw_reg[12];  
             8'hD : remain_dw <= tag_remain_dw_reg[13];  
             8'hE : remain_dw <= tag_remain_dw_reg[14];  
             8'hF : remain_dw <= tag_remain_dw_reg[15];  
             default : remain_dw <= 32'h0;
           endcase
         end                  

                      

 always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           avmm_lbe_reg <= 32'hFFFF_FFFF;
       else if(latch_header)
           avmm_lbe_reg <=adjusted_avmm_lbe;
     //  else if(rdcpl_write_state /*& rx_eop_reg */ & ~RdDmaWaitRequest_i)
      //     avmm_lbe_reg <= 32'hFFFF_FFFF;
      end


/// Muxing the data based on CPL address bit 2  and AVMM FBE

// calculate the first valid address based on FBE

  always_comb
    begin
      casez (tag_first_enable_reg[31:0])
        32'h????_??F0 :first_valid_addr[7:0] <= 8'h04;
        32'h????_?F00 :first_valid_addr[7:0] <= 8'h08;
        32'h????_F000 :first_valid_addr[7:0] <= 8'h0C;
        32'h???F_0000 :first_valid_addr[7:0] <= 8'h10;
        32'h??F0_0000 :first_valid_addr[7:0] <= 8'h14;
        32'h?F00_0000 :first_valid_addr[7:0] <= 8'h18;
        32'hF000_0000 :first_valid_addr[7:0] <= 8'h1C;
        32'hFFFF_FFFF: first_valid_addr[7:0] <= 8'h00;
        default:  first_valid_addr[7:0] <= 8'h00;
      endcase
    end
    

 always_comb
    begin
     case(cpl_addr_bit2_reg)
      1'b1:
        begin
          case (first_valid_addr[7:0])
            8'h04 :
              begin
                avmm_write_data_dw0    = tlp_reg_dw2;   
                avmm_write_data_dw1    = tlp_reg_dw3;
                avmm_write_data_dw2    = tlp_reg_dw4;
                avmm_write_data_dw3    = tlp_reg_dw5;
                avmm_write_data_dw4    = tlp_reg_dw6;
                avmm_write_data_dw5    = tlp_reg_dw7;
                avmm_write_data_dw6    = tlp_fifo_dw0;  
                avmm_write_data_dw7    = tlp_fifo_dw1;
              end

            8'h08 :
              begin
                avmm_write_data_dw0    = tlp_reg_dw1;   
                avmm_write_data_dw1    = tlp_reg_dw2;   
                avmm_write_data_dw2    = tlp_reg_dw3;   
                avmm_write_data_dw3    = tlp_reg_dw4;   
                avmm_write_data_dw4    = tlp_reg_dw5;   
                avmm_write_data_dw5    = tlp_reg_dw6;   
                avmm_write_data_dw6    = tlp_reg_dw7;  
                avmm_write_data_dw7    = tlp_fifo_dw0;  
              end

            8'h0C :
              begin
                avmm_write_data_dw0    = tlp_reg_dw0;   
                avmm_write_data_dw1    = tlp_reg_dw1;   
                avmm_write_data_dw2    = tlp_reg_dw2;   
                avmm_write_data_dw3    = tlp_reg_dw3;   
                avmm_write_data_dw4    = tlp_reg_dw4;   
                avmm_write_data_dw5    = tlp_reg_dw5;   
                avmm_write_data_dw6    = tlp_reg_dw6;  
                avmm_write_data_dw7    = tlp_reg_dw7;                 
              end

            8'h10 :
              begin
                avmm_write_data_dw0    = tlp_hold_reg_dw7;   
                avmm_write_data_dw1    = tlp_reg_dw0;   
                avmm_write_data_dw2    = tlp_reg_dw1;   
                avmm_write_data_dw3    = tlp_reg_dw2; 
                avmm_write_data_dw4    = tlp_reg_dw3;   
                avmm_write_data_dw5    = tlp_reg_dw4;   
                avmm_write_data_dw6    = tlp_reg_dw5;  
                avmm_write_data_dw7    = tlp_reg_dw6;   
              end

            8'h14 :
              begin
                avmm_write_data_dw0    = tlp_hold_reg_dw6;   
                avmm_write_data_dw1    = tlp_hold_reg_dw7;   
                avmm_write_data_dw2    = tlp_reg_dw0; 
                avmm_write_data_dw3    = tlp_reg_dw1; 
                avmm_write_data_dw4    = tlp_reg_dw2;   
                avmm_write_data_dw5    = tlp_reg_dw3;   
                avmm_write_data_dw6    = tlp_reg_dw4;  
                avmm_write_data_dw7    = tlp_reg_dw5;                 
              end

            8'h18 :
              begin
                avmm_write_data_dw0    = tlp_hold_reg_dw5;   
                avmm_write_data_dw1    = tlp_hold_reg_dw6;   
                avmm_write_data_dw2    = tlp_hold_reg_dw7; 
                avmm_write_data_dw3    = tlp_reg_dw0; 
                avmm_write_data_dw4    = tlp_reg_dw1; 
                avmm_write_data_dw5    = tlp_reg_dw2;
                avmm_write_data_dw6    = tlp_reg_dw3;  
                avmm_write_data_dw7    = tlp_reg_dw4;                   
              end

            8'h1C :
              begin
                avmm_write_data_dw0    = tlp_hold_reg_dw4;   
                avmm_write_data_dw1    = tlp_hold_reg_dw5;   
                avmm_write_data_dw2    = tlp_hold_reg_dw6; 
                avmm_write_data_dw3    = tlp_hold_reg_dw7; 
                avmm_write_data_dw4    = tlp_reg_dw0; 
                avmm_write_data_dw5    = tlp_reg_dw1;
                avmm_write_data_dw6    = tlp_reg_dw2;  
                avmm_write_data_dw7    = tlp_reg_dw3;                           
              end

            default :  // 8'h0
              begin
                avmm_write_data_dw0    = tlp_reg_dw3;   
                avmm_write_data_dw1    = tlp_reg_dw4;   
                avmm_write_data_dw2    = tlp_reg_dw5; 
                avmm_write_data_dw3    = tlp_reg_dw6; 
                avmm_write_data_dw4    = tlp_reg_dw7; 
                avmm_write_data_dw5    = tlp_fifo_dw0;
                avmm_write_data_dw6    = tlp_fifo_dw1;  
                avmm_write_data_dw7    = tlp_fifo_dw2;
              end
          endcase
        end

     1'b0:
        begin
          case (first_valid_addr[7:0])
            8'h04 :
              begin
              	avmm_write_data_dw0    = tlp_reg_dw3;
                avmm_write_data_dw1    = tlp_reg_dw4;      
                avmm_write_data_dw2    = tlp_reg_dw5;      
                avmm_write_data_dw3    = tlp_reg_dw6;      
                avmm_write_data_dw4    = tlp_reg_dw7;      
                avmm_write_data_dw5    = tlp_fifo_dw0;      
                avmm_write_data_dw6    = tlp_fifo_dw1;     
                avmm_write_data_dw7    = tlp_fifo_dw2;     
              end

            8'h08 :
              begin
              	avmm_write_data_dw0    = tlp_reg_dw2;
                avmm_write_data_dw1    = tlp_reg_dw3;  
                avmm_write_data_dw2    = tlp_reg_dw4;      
                avmm_write_data_dw3    = tlp_reg_dw5;      
                avmm_write_data_dw4    = tlp_reg_dw6;      
                avmm_write_data_dw5    = tlp_reg_dw7;      
                avmm_write_data_dw6    = tlp_fifo_dw0;     
                avmm_write_data_dw7    = tlp_fifo_dw1;   
              end

            8'h0C :
              begin
                avmm_write_data_dw0    = tlp_reg_dw1;
                avmm_write_data_dw1    = tlp_reg_dw2;  
                avmm_write_data_dw2    = tlp_reg_dw3;  
                avmm_write_data_dw3    = tlp_reg_dw4;      
                avmm_write_data_dw4    = tlp_reg_dw5;      
                avmm_write_data_dw5    = tlp_reg_dw6;      
                avmm_write_data_dw6    = tlp_reg_dw7;     
                avmm_write_data_dw7    = tlp_fifo_dw0;                  
              end

            8'h10 :
              begin
                avmm_write_data_dw0    = tlp_reg_dw0;
                avmm_write_data_dw1    = tlp_reg_dw1;  
                avmm_write_data_dw2    = tlp_reg_dw2;  
                avmm_write_data_dw3    = tlp_reg_dw3;  
                avmm_write_data_dw4    = tlp_reg_dw4;      
                avmm_write_data_dw5    = tlp_reg_dw5;      
                avmm_write_data_dw6    = tlp_reg_dw6;     
                avmm_write_data_dw7    = tlp_reg_dw7;            
              end

            8'h14 :
              begin
                avmm_write_data_dw0    = tlp_hold_reg_dw7;
                avmm_write_data_dw1    = tlp_reg_dw0;  
                avmm_write_data_dw2    = tlp_reg_dw1;  
                avmm_write_data_dw3    = tlp_reg_dw2;  
                avmm_write_data_dw4    = tlp_reg_dw3;   
                avmm_write_data_dw5    = tlp_reg_dw4;      
                avmm_write_data_dw6    = tlp_reg_dw5;     
                avmm_write_data_dw7    = tlp_reg_dw6;  
              end

            8'h18 :
              begin
                avmm_write_data_dw0    = tlp_hold_reg_dw6;
                avmm_write_data_dw1    = tlp_hold_reg_dw7;  
                avmm_write_data_dw2    = tlp_reg_dw0;  
                avmm_write_data_dw3    = tlp_reg_dw1;  
                avmm_write_data_dw4    = tlp_reg_dw2;   
                avmm_write_data_dw5    = tlp_reg_dw3;  
                avmm_write_data_dw6    = tlp_reg_dw4;     
                avmm_write_data_dw7    = tlp_reg_dw5;  
              end

            8'h1C :
              begin
                avmm_write_data_dw0    = tlp_hold_reg_dw5;
                avmm_write_data_dw1    = tlp_hold_reg_dw6;  
                avmm_write_data_dw2    = tlp_hold_reg_dw7;  
                avmm_write_data_dw3    = tlp_reg_dw0;  
                avmm_write_data_dw4    = tlp_reg_dw1;   
                avmm_write_data_dw5    = tlp_reg_dw2;  
                avmm_write_data_dw6    = tlp_reg_dw3;   
                avmm_write_data_dw7    = tlp_reg_dw4;
              end

            default :  // 8'h0
              begin
                avmm_write_data_dw0    = tlp_reg_dw4;
                avmm_write_data_dw1    = tlp_reg_dw5;  
                avmm_write_data_dw2    = tlp_reg_dw6;  
                avmm_write_data_dw3    = tlp_reg_dw7;  
                avmm_write_data_dw4    = tlp_fifo_dw0;   
                avmm_write_data_dw5    = tlp_fifo_dw1;  
                avmm_write_data_dw6    = tlp_fifo_dw2;   
                avmm_write_data_dw7    = tlp_fifo_dw3;
              end
          endcase
        end
       default:
         begin
         	      avmm_write_data_dw0    = 32'h0;
                avmm_write_data_dw1    = 32'h0;  
                avmm_write_data_dw2    = 32'h0;  
                avmm_write_data_dw3    = 32'h0;  
                avmm_write_data_dw4    = 32'h0;   
                avmm_write_data_dw5    = 32'h0;  
                avmm_write_data_dw6    = 32'h0;   
                avmm_write_data_dw7    = 32'h0;
         end
    endcase
    end


/// Tx Fifo Interface for sending read TLP
assign is_rd32 = (cur_src_addr_reg[63:32] == 32'h0);
assign cmd = is_rd32? 8'h00 : 8'h20;
assign requestor_id = {BusDev_i, 3'b000};

assign tlp_dw2     = is_rd32?  cur_src_addr_reg[31:0] : cur_src_addr_reg[63:32];
assign tlp_dw3     = cur_src_addr_reg[31:0];

assign req_header1 = {requestor_id[15:0], rd_tag_reg[7:0], 8'hFF, cmd[7:0], 8'h0, 6'h0, rd_dw_size[9:0]};
assign req_header2 = { tlp_dw3, tlp_dw2 };
assign tx_tlp_empty = 2'b10;
assign TxFifoData_o = {tx_tlp_empty, 1'b1,1'b1,128'h0,req_header2, req_header1};
assign TxFifoWrReq_o = rd_header_state;

/// AVMM Write interface
assign RdDmaWrite_o   = rdcpl_write_state;
assign RdDmaAddress_o = {{(64-RDDMA_AVL_ADDR_WIDTH){1'b0}},avmm_addr_reg[RDDMA_AVL_ADDR_WIDTH-1:5], 5'b00000};
assign RdDmaWriteData_o = {avmm_write_data_dw7, avmm_write_data_dw6, avmm_write_data_dw5, avmm_write_data_dw4, avmm_write_data_dw3, avmm_write_data_dw2, avmm_write_data_dw1, avmm_write_data_dw0};
assign RdDmaWriteEnable_o =  avmm_first_write_reg? avmm_fbe_reg : (avmm_burst_cntr == 1 )? avmm_lbe_reg : 32'hFFFF_FFFF;
// assign RdDmaBurstCount_o = (RdDmaWriteEnable_o == 32'hFFFF_FFFF)? avmm_burst_cnt_reg: 5'b00001;
assign RdDmaBurstCount_o = avmm_burst_cnt_reg;
/// Update to the Desc controller
//assign reported_desc_id = tag_release? cpl_desc_id_reg : cur_desc_id_reg;
assign desc_completed   = (tag_release_queuing & last_desc_cpl_reg & last_cpl_reg);
assign desc_flushed     = ~flush_all_desc_reg &  flush_all_desc;
assign desc_aborted     = ~cur_dma_abort_reg  & cur_dma_abort;
assign desc_paused      =  ~cur_dma_pause_reg  & cur_dma_pause;
assign flush_count      = desc_flushed? (desc_fifo_count + 1) : 0;
assign desc_busy        = ~rd_idle_state;
assign RdDmaTxData_o = {15'h0, flush_count, desc_flushed, desc_aborted, desc_paused, desc_busy, desc_completed,cpl_desc_id_reg[7:0]};
assign RdDmaTxValid_o = desc_completed | desc_flushed | desc_aborted |  desc_paused;

assign RdDMAStatus_o[7:0]  = cur_desc_id_reg;
assign RdDMAStatus_o[31:8] = 24'h0;

// Rx FIFO interface
assign RxFifoRdReq_o = (rdcpl_idle_state &  (is_cpl_wd & rx_sop & cpl_tag <= 15 & ~rx_fifo_empty) ) |
                       ( rdcpl_write_state & ~( avmm_burst_cntr==2 & rx_sop | avmm_burst_cnt_reg == 1 & rx_sop) & ~RdDmaWaitRequest_i & ~rx_fifo_empty);  /// do not read if avmm is behind and there is a valid sop at the fifo OR burst count is 1

assign RdDmaRxReady_o = desc_fifo_count < 4'h3;

/// Sub descriptors:


  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         begin
           sub_desc_src_addr_reg <= 64'h0;
           sub_desc_dest_addr_reg <= 64'h0;
         end
       else if(rd_pop_desc_state)
         begin
           sub_desc_src_addr_reg <= desc_head[63:0];
           sub_desc_dest_addr_reg <= desc_head[127:64];
         end
       else if(sub_desc_load)
         begin
           sub_desc_src_addr_reg <= next_sub_src_addr[63:0] ;
           sub_desc_dest_addr_reg <= next_sub_dest_addr[63:0];
         end
     end


      always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         begin
           sub_desc_length_reg <= 18'h0;
         end
       else if(rd_pipe_state)
         begin
           sub_desc_length_reg <= (orig_desc_dw_reg <= dw_to_4KB)? orig_desc_dw_reg : dw_to_4KB;
         end
       else if(sub_desc_load_reg)
         begin
           sub_desc_length_reg <= (main_desc_remain_length_reg <= dw_to_legal_bound)? main_desc_remain_length_reg : dw_to_legal_bound;
         end
     end


   assign bytes_to_4K  = (sub_desc_src_addr_reg[11:0] == 12'h0)? 13'h1000 : 13'h1000 - sub_desc_src_addr_reg[11:0];
   
   assign dw_to_4K =  bytes_to_4K[12:2];
   
   assign dw_to_legal_bound = dw_to_4K;
   
   assign next_sub_src_addr[63:0] = sub_desc_src_addr_reg[63:0] + bytes_to_4K[12:0];
   assign next_sub_dest_addr[63:0] = sub_desc_dest_addr_reg + bytes_to_4K[12:0];

   /// main descriptor outstanding logic, remaining after sub-descriptor is loaded

   always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         begin
           rd_pipe_state_reg <= 1'b0;
         end
       else
         begin
           rd_pipe_state_reg <= rd_pipe_state;
         end
     end


   always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
         begin
           main_desc_remain_length_reg <= 18'h0;
         end
       else if(rd_pipe_state_reg) // delay one clock
         begin
           main_desc_remain_length_reg <= orig_desc_dw_reg;
         end
       else if(sub_desc_load)
         begin
           main_desc_remain_length_reg <= main_desc_remain_length_reg - sub_desc_length_reg;
         end
     end

   assign last_sub_desc = (main_desc_remain_length_reg <= dw_to_legal_bound);

   always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           last_sub_desc_reg <= 1'b0;
       else
           last_sub_desc_reg <= last_sub_desc;
     end

// predecode tag interface

assign PreDecodeTagRdReq_o = latch_header;

/// for monotoring purpose

  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           culmutive_sent_dw <= 18'h0;
       else if(rd_pop_desc_state)
          culmutive_sent_dw <= 18'h0;
       else if(rd_header_state)
          culmutive_sent_dw <=  culmutive_sent_dw + rd_dw_size;
     end
       
  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           culmutive_remain_dw <= 18'h0;
       else if(rd_pop_desc_state)
          culmutive_remain_dw <= desc_head[145:128];
       else if(rd_header_state)
          culmutive_remain_dw <=  culmutive_remain_dw - rd_dw_size;
     end
 
endmodule






