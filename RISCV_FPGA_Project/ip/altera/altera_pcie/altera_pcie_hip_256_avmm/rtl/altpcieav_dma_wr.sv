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



module altpcieav_dma_wr # (
   parameter DMA_WIDTH            = 256,           
   parameter DMA_BE_WIDTH         = 5,             
   parameter DMA_BRST_CNT_W       = 5,
   parameter WRDMA_AVL_ADDR_WIDTH = 20             
   )
   (
   input    logic                     Clk_i,
   input    logic                     Rstn_i,
      
   // Avalon-MM Interface
   // Upstream PCIe Write DMA master port 
  
   output   logic                     WrDmaRead_o,
   output   logic[63:0]               WrDmaAddress_o,
   output   logic[DMA_BRST_CNT_W-1:0] WrDmaBurstCount_o,
   input    logic                     WrDmaWaitRequest_i,
   input    logic                     WrDmaReadDataValid_i,
   input    logic[DMA_WIDTH-1:0]      WrDmaReadData_i,
      
   /// AST Inteface
   // Write DMA AST Rx port                       
   input    logic[159:0]              WrDmaRxData_i, 
   input    logic                     WrDmaRxValid_i, 
   output   logic                     WrDmaRxReady_o,
                                             
   // Write DMA AST Tx port                       
   output   logic[31:0]               WrDmaTxData_o, 
   output   logic                     WrDmaTxValid_o,
      
   // Rx fifo Interface
   output   logic                     RxFifoRdReq_o,
   input    logic[265:0]              RxFifoDataq_i,
   input    logic[3:0]                RxFifoCount_i,
      
   // Tx fifo Interface
   output   logic                     TxFifoWrReq_o,
   output   logic[259:0]              TxFifoData_o,
   input    logic[3:0]                TxFifoCount_i,      
     
   // General CRA interface
   input    logic                     WrDMACntrlLoad_i,
   input    logic[31:0]               WrDMACntrlData_i,
   output   logic[31:0]               WrDMAStatus_o,
      
   // Arbiter Interface                                               
   output   logic                     WrDmaArbReq_o,     
   input    logic                     WrDmaReadArbReq_i,
   input    logic                     WrDmaTxsArbReq_i, 	
   input    logic                     WrDmaArbGranted_i,          
     
   input    logic[15:0]               BusDev_i,
   input    logic[31:0]               DevCsr_i,
   input    logic                     MasterEnable
   );
 
   localparam ALLOW_ANY_FILE_SIZE = 1;
   localparam AVST_ADDR_ALIGN     = 1;   
  
   localparam  RD_IDLE 	   = 6'h01;              
   localparam  RD_DEASSERT = 6'h02;              
   localparam  RD_CONT     = 6'h03;               
  
   localparam  WR_IDLE 	   = 6'h01;              
   localparam  WR_DATA_RCV = 6'h02;               
   localparam  WR_PAUSE    = 6'h03;               
   localparam  WR_DATA_RD  = 6'h04;              
   localparam  WR_SEND     = 6'h05;    
  
   localparam  START_FILE        = 3'h0;    
   localparam  CONT_FILE 	 = 3'h1;
   localparam  WAIT_LASTPKT_PROC = 3'h2;
   localparam  FILE_SIZE_WIDTH   = 18;       
  
   // tlp_gen_sm states
   localparam  INIT       = 2'h0;
   localparam  START_DATA = 2'h1;
   localparam  CONT_DATA  = 2'h2;
   localparam  LAST_DATA  = 2'h3;

   // avst_sm states
   localparam   AVST_START_STATE      = 2'h0;
   localparam   AVST_DATA_STATE       = 2'h1;
   localparam   AVST_EXTRA_DATA_STATE = 2'h2;
  
   logic        desc_fifo_rdreq;
   logic        desc_fifo_wrreq;
   logic        desc_fifo_rst;
   logic[159:0] desc_fifo_data;
   logic[3:0]   desc_fifo_count;
   logic        desc_fifo_empty;   
 
   logic[63:0]  cur_dest_addr_reg;
   logic[63:0]  cur_src_addr_reg; 
   logic[17:0]  cur_dma_dw_count;
   logic[7:0]   cur_desc_id_reg;
 
   logic        cur_dma_abort;
   logic        cur_dma_abort_reg; 
   logic        cur_dma_pause;   
   logic        cur_dma_pause_reg;   
   logic        flush_all_desc;
   logic        flush_all_desc_reg;
   logic        cur_dma_resume_reg;
   logic        cur_dma_resume;

   logic        wr_pause_state;
   logic        wr_idle_state;
   logic[5:0]   wrdma_sm;        
   logic[5:0]   rdmem_sm;        

   logic        data_fifo_empty;
   logic[8:0]   data_fifo_count;
   logic[255:0] data_fifo_data;
   logic[255:0] data_fifo_data_r;
   logic        write_data_fifo_wrreq;
   logic[17:0]  dw_cnt_write;
   logic[8:0]   curr_fifo_depth;

   logic[10:0]  max_payld_size;

   logic        hdr_valid;       // means there is a pkt available
   logic        hdr_valid_r;
   logic        hdr_valid_rr;
   logic        hdr_valid_wdata;
   logic[63:0]  hdr_address;     // pcie target address
   logic[10:0]  hdr_size;        // pcie payload size
   logic[7:0]   hdr_file_num;    // file # being transferred
   logic        hdr_file_end;    // means this tlp is the last for the file	
   logic        hdr_advance;
   logic[2:0]   hdr_gen_sm;      // controls break up of file into multiple TLPs
   logic[63:0]  curr_addr;       // start address of current TLP

   logic[FILE_SIZE_WIDTH-1:0]file_size_remain; // number of DWs remaining to be transferred                            
   logic[10:0]  max_payld_size_reg;            // input pipe reg for fmax
   logic[63:0]  curr_addr_plus_maxpload;
   logic[63:0]  file_addr_plus_maxpload;
   logic[63:0]  curr_addr_plus_filesizerem;
   logic[63:0]  file_addr_plus_filesize;
   logic[FILE_SIZE_WIDTH-1:0] file_size;
   logic[63:0]  file_addr;	
   logic[7:0]   file_num;
 
   logic        tlp_start;
   logic[127:0] tlp_desc;
   logic[7:0]   tlp_end;
   logic[7:0]   tlp_file_num;	 
  
   logic        tlp_advance; 
   logic        tlp_val;             // issues a TLP cycle - rcvr must accept
   logic        tlp_read;            // read TLP data from fifo 
   logic[255:0] tlp_data;
   logic        tlp_file_end;
   logic[9:0]   hdr_size_remain;     // number of payload DW remaining to be transferred including this cycle
   logic[1:0]   tlp_gen_sm;          // state machine keeps track of start and end of packet transfer cycles    
   logic[1:0]   payld_count_ctl;     //TBD is this required to pop from FIFO?

   logic[7:0]   tlp_byte_ena;        // PciE byte enable field
   logic        tlp_4dw_hdr;         // PciE address requires 4DW header
   logic[7:0]   fmt_type;            // PciE format/type field
   logic        hdr_file_end_hold;

   logic[9:0]   tlp_length_n;

   logic        file_advance;
   logic        file_valid;

   logic[255:0] avst_data;      // AVST TX interface:  256bits, 1 beat per cycle (1 TLP per cycle)
   logic        avst_valid;
   logic        avst_sop;
   logic        avst_eop;
   logic[1:0]   avst_empty;
   logic        avst_file_end; 
   logic[7:0]   avst_file_num;
   logic        avst_ready;  
  
   logic[255:0] tlp_data_hold;       // hold value from last cycle
   logic[7:0]   tlp_end_hold;        // hold value from last cycle
   logic        tlp_file_end_hold;
						  
   logic[1:0]   avst_sm;             // AVST State machine
						 
   logic        tlp_4dw_hdr_av;      // tlp header is 4DW
   logic        tlp_odd_dwaddr;      // tlp address is an odd DW (- not QW aligned)  
   logic        tlp_odd_dwaddr_av;   // tlp address is an odd DW (- not QW aligned)  
   logic[255:0] tlp_data_shifted_n;  // shifted version of TLP payload (current data + deferred data)
   logic[7:0]   tlp_end_shifted_n;   // shifted version of the TLP end vector (which indicates the last DW of the TLP payload)
   logic[2:0]   payld_shift_n;       // # of DWs of payload shifted in with desc phase
   logic[2:0]   payld_shift;
   logic[2:0]   hdr_partial_word_sel;
   logic[2:0]   hdr_partial_word_en;

// Unused Outputs
assign RxFifoRdReq_o = 1'b0;                     

always_comb
begin
   case(DevCsr_i[7:5])
      3'b000  : max_payld_size = 10'h20;	//128b
      3'b001  : max_payld_size = 10'h40;	//256b
      3'b010  : max_payld_size = 10'h80;	//512b
      default : max_payld_size = 10'h80;	//512b
   endcase
end 

/// current descriptor
always_ff @ (posedge Clk_i or negedge Rstn_i) 
begin                
   if(~Rstn_i) begin
      cur_dest_addr_reg <= 64'h0;
      cur_src_addr_reg  <= 64'h0;
      cur_dma_dw_count  <= 18'h0;
      cur_desc_id_reg   <= 8'h0;
   end
   else if(desc_fifo_rdreq) begin
      cur_dest_addr_reg <= desc_fifo_data[127:64];
      cur_src_addr_reg  <= desc_fifo_data[63:0];
      cur_dma_dw_count  <= desc_fifo_data[145:128];
      cur_desc_id_reg   <= desc_fifo_data[153:146];
   end
end
     

// current Descriptor Control Register

assign cur_dma_pause  = WrDMACntrlData_i[0];
assign cur_dma_resume = WrDMACntrlData_i[1];
assign cur_dma_abort  = WrDMACntrlData_i[2];
assign flush_all_desc = WrDMACntrlData_i[3];

always_ff @ (posedge Clk_i or negedge Rstn_i) 
begin                
   if(~Rstn_i) begin 
      cur_dma_abort_reg  <= 1'b0;
      flush_all_desc_reg <= 1'b0;
   end
   else if(WrDMACntrlLoad_i) begin
      cur_dma_abort_reg  <=  cur_dma_abort;
      flush_all_desc_reg <=  flush_all_desc;
   end
   else if ((cur_dma_abort_reg | flush_all_desc_reg) & wr_idle_state) begin
      cur_dma_abort_reg  <= 1'b0;
      flush_all_desc_reg <= 1'b0;
   end
end


always_ff @ (posedge Clk_i or negedge Rstn_i) 
begin                
   if(~Rstn_i) begin 
      cur_dma_pause_reg <= 1'b0;
   end
   else if(WrDMACntrlLoad_i) begin
      cur_dma_pause_reg <= cur_dma_pause;
   end
   else if (cur_dma_pause_reg & cur_dma_resume_reg) begin
      cur_dma_pause_reg <= 1'b0;
   end
end

always_ff @ (posedge Clk_i or negedge Rstn_i) 
begin                
   if(~Rstn_i) begin 
      cur_dma_resume_reg <= 1'b0;
   end
   else if(WrDMACntrlLoad_i) begin
      cur_dma_resume_reg <=  cur_dma_resume;
   end
   else if (~wr_pause_state) begin
      cur_dma_resume_reg <= 1'b0;
   end
end



// Descriptor Status Register
assign WrDMAStatus_o  = {wr_pause_state, !wr_idle_state, avst_file_end, avst_file_num}; //TBD
assign WrDmaTxData_o  = {wr_pause_state, !wr_idle_state, avst_file_end, avst_file_num};
assign WrDmaTxValid_o = avst_file_end;

// TLP data out to the HIP interface
assign TxFifoWrReq_o   = avst_valid; 
assign TxFifoData_o    = {avst_empty, avst_eop, avst_sop, avst_data};
                     
// Desc FIFO signals 
assign desc_fifo_wrreq = WrDmaRxValid_i & MasterEnable;	
assign WrDmaRxReady_o  = (desc_fifo_count < 3);
assign desc_fifo_empty = (desc_fifo_count == 0);
assign desc_fifo_rst   = cur_dma_pause | cur_dma_abort | flush_all_desc;
assign wr_idle_state   = (wrdma_sm == WR_IDLE)  || avst_file_end;
assign wr_pause_state  = (wrdma_sm == WR_PAUSE);

// Data FIFO signals
//assign data_fifo_empty     = (data_fifo_count == 0);
assign data_fifo_rdreq       = tlp_read && !data_fifo_empty; 
assign write_data_fifo_wrreq = WrDmaReadDataValid_i;

// Descriptor FIFO
altpcie_fifo #(
   .FIFO_DEPTH(6),    
   .DATA_WIDTH(160)   
   )
   write_desc_fifo (
      .clk(Clk_i),       
      .rstn(Rstn_i),      
      .srst(desc_fifo_rst),      
      .wrreq(desc_fifo_wrreq),     
      .rdreq(desc_fifo_rdreq), 
      .data(WrDmaRxData_i),      
      .q(desc_fifo_data),         
      .fifo_count(desc_fifo_count) 
   );

// Data FIFO 
scfifo write_data_fifo(
   .aclr(~Rstn_i),
   .clock(Clk_i),
   .data(WrDmaReadData_i),
   .rdreq(data_fifo_rdreq),
   .sclr(1'b0),
   .wrreq(write_data_fifo_wrreq),
   .empty(data_fifo_empty),
   .full(),
   .q(data_fifo_data),
   .usedw(data_fifo_count),
   .almost_empty(),
   .almost_full()
   );

   defparam
      write_data_fifo.add_ram_output_register = "OFF",
      write_data_fifo.intended_device_family = "Stratix V",
      write_data_fifo.lpm_hint = "RAM_BLOCK_TYPE=M20K",
      write_data_fifo.lpm_numwords = 512,
      write_data_fifo.lpm_showahead = "ON",
      write_data_fifo.lpm_type = "scfifo",
      write_data_fifo.lpm_width = 256,
      write_data_fifo.lpm_widthu = 9,
      write_data_fifo.overflow_checking = "ON",
      write_data_fifo.underflow_checking = "ON",
      write_data_fifo.use_eab = "ON";


always_ff @ (posedge Clk_i or negedge Rstn_i) 
begin                
   if(~Rstn_i) begin
      rdmem_sm          <= RD_IDLE;
      WrDmaRead_o       <= 1'b0;
      dw_cnt_write      <= 18'h0;
      WrDmaBurstCount_o <= 5'h0;
      WrDmaAddress_o    <= 64'h0;
      curr_fifo_depth   <= 9'h0;
   end
   else begin
      case (rdmem_sm) 
         RD_IDLE: begin
            if (desc_fifo_rdreq) begin
               rdmem_sm        <= RD_DEASSERT;
               WrDmaRead_o     <= 1'b1;
               WrDmaAddress_o  <= desc_fifo_data[63:0];
               curr_fifo_depth <= 9'h1ff - data_fifo_count - 2*max_payld_size/8;  // buffer for the 1st request (2 TLPS)
               if (desc_fifo_data[145:128] <= max_payld_size) begin
                  WrDmaBurstCount_o <= desc_fifo_data[135:131] + |desc_fifo_data[130:128];
                  dw_cnt_write      <= 18'h0; 
               end
               else if (max_payld_size == 8'h80) begin
                  WrDmaBurstCount_o <= max_payld_size/8;
                  dw_cnt_write      <= desc_fifo_data[145:128] - max_payld_size;
               end
               else begin
                  if (desc_fifo_data[145:128] <= 2*max_payld_size) begin
                     WrDmaBurstCount_o <= desc_fifo_data[135:131] + |desc_fifo_data[130:128];
                     dw_cnt_write      <= 18'h0; 
                  end
                  else begin
                     WrDmaBurstCount_o <= 2*(max_payld_size/8);
                     dw_cnt_write      <= desc_fifo_data[145:128] - 2*max_payld_size; 
                  end
               end
            end
            else begin
               rdmem_sm          <= RD_IDLE;
               WrDmaRead_o       <= 1'b0;
               dw_cnt_write      <= 18'h0;
               WrDmaBurstCount_o <= 5'h0;
               WrDmaAddress_o    <= 64'h0;
               curr_fifo_depth   <= 9'h0;
            end
         end

         RD_DEASSERT: begin
            if (WrDmaRead_o && ~WrDmaWaitRequest_i) begin 
               WrDmaRead_o <= 1'b0;
               rdmem_sm    <= RD_CONT;
            end
            else begin
               WrDmaRead_o <= 1'b1;
               rdmem_sm    <= RD_DEASSERT;
            end
         end

         RD_CONT: begin
            if ((dw_cnt_write != 17'h0) && ~WrDmaRead_o) begin
               rdmem_sm <= RD_CONT; 
               if ((file_size - dw_cnt_write) < (curr_fifo_depth * 8)) begin 
                  WrDmaAddress_o  <= WrDmaAddress_o + (WrDmaBurstCount_o * 32);            
                  WrDmaRead_o     <= 1'b1;
                  rdmem_sm        <= RD_DEASSERT;
                  // Check if there is buffer for atleast 1 TLP and avoid rollover of curr_fifo_depth count
                  curr_fifo_depth <= (curr_fifo_depth > max_payld_size/8) ? (curr_fifo_depth - max_payld_size/8) : curr_fifo_depth; 
                  if (dw_cnt_write <= max_payld_size) begin
                     WrDmaBurstCount_o <= dw_cnt_write[7:3] + |dw_cnt_write[2:0];
                     dw_cnt_write      <= 17'h0;
                  end
                  else begin
                     WrDmaBurstCount_o <= max_payld_size/8;
                     dw_cnt_write      <= dw_cnt_write - max_payld_size;
                  end
               end
               // Buffer for unfinished reads - 2 from previous state and 1 from this state
               else if (hdr_valid_wdata && (data_fifo_count < 9'h1ff - 3*(max_payld_size/8))) begin
                  WrDmaAddress_o <= WrDmaAddress_o + (WrDmaBurstCount_o * 32);            
                  WrDmaRead_o    <= 1'b1;
                  rdmem_sm       <= RD_DEASSERT;
                     if (dw_cnt_write <= max_payld_size) begin
                        WrDmaBurstCount_o <= dw_cnt_write[7:3] + |dw_cnt_write[2:0];
                        dw_cnt_write      <= 17'h0;
                     end
                     else begin
                        WrDmaBurstCount_o <= max_payld_size/8;
                        dw_cnt_write      <= dw_cnt_write - max_payld_size;
                     end
               end
            end
            else begin
               rdmem_sm    <= RD_IDLE; 
               WrDmaRead_o <= 1'b0;
            end
         end

         default: begin
            rdmem_sm <= RD_IDLE;
         end
      endcase
   end
end
 
  
always_ff @ (posedge Clk_i or negedge Rstn_i) 
begin                
   if(~Rstn_i) begin
      wrdma_sm        <= WR_IDLE;
      desc_fifo_rdreq <= 1'b0;
      WrDmaArbReq_o   <= 1'b0;
      file_valid      <= 1'b0;
   end  
   else begin
      case(wrdma_sm)
         WR_IDLE: begin
            if(~desc_fifo_empty) begin
               wrdma_sm        <= WR_DATA_RCV;
               desc_fifo_rdreq <= 1'b1;
            end
            else begin
               wrdma_sm        <= WR_IDLE;
               desc_fifo_rdreq <= 1'b0;
            end	
         end			

         WR_DATA_RCV: begin
            desc_fifo_rdreq <= 1'b0;
            if(cur_dma_abort_reg | flush_all_desc_reg) begin
               wrdma_sm <= WR_IDLE;
            end
            else if(cur_dma_pause_reg) begin
               wrdma_sm <= WR_PAUSE;
            end
            else begin  
               if(hdr_gen_sm == START_FILE) begin
                  wrdma_sm      <= WR_DATA_RD;
                  if (WrDmaTxsArbReq_i | (WrDmaReadArbReq_i && |tlp_end_hold))
                     WrDmaArbReq_o <= 1'b0;
                  else
                     WrDmaArbReq_o <= 1'b1;
               end
               else begin
                  wrdma_sm      <= WR_DATA_RCV;
                  if(WrDmaReadArbReq_i && |tlp_end_hold)
                     WrDmaArbReq_o <= 1'b0;
                  else
                     WrDmaArbReq_o <= 1'b1;
               end
            end
         end			

         WR_PAUSE: begin
            if(cur_dma_resume_reg)
               wrdma_sm <= WR_DATA_RCV;	
            else
               wrdma_sm <= WR_PAUSE;
         end  			  

         WR_DATA_RD: begin
            WrDmaArbReq_o <= 1'b1;
            if(WrDmaArbGranted_i) begin
               wrdma_sm      <= WR_SEND;
               file_valid <= 1'b1;
            end
            else begin
               wrdma_sm      <= WR_DATA_RD;
               file_valid <= 1'b0;
            end
         end			  

         WR_SEND: begin
            file_valid <= 1'b0;
            if(file_size_remain <= (file_size/2) && (dw_cnt_write == 18'h0) && (WrDmaRead_o == 1'b0)) begin	
               if(~desc_fifo_empty) begin
                  wrdma_sm        <= WR_DATA_RCV; 
                  desc_fifo_rdreq <= 1'b1;
                  WrDmaArbReq_o <= 1'b1;
               end
               else if(avst_file_end) begin
                  wrdma_sm <= WR_IDLE;
                  WrDmaArbReq_o <= 1'b0;
               end	
               else if(WrDmaReadArbReq_i && |tlp_end_hold) begin
                  wrdma_sm <= WR_SEND;
                  WrDmaArbReq_o <= 1'b0;
               end
               else begin
                  wrdma_sm <= WR_SEND;
                  WrDmaArbReq_o <= 1'b1;
               end
            end
            else if(avst_file_end) begin	
               wrdma_sm      <= WR_IDLE;
               WrDmaArbReq_o <= 1'b0;
            end
            else if(WrDmaReadArbReq_i && |tlp_end_hold) begin
               wrdma_sm <= WR_SEND;
               WrDmaArbReq_o <= 1'b0;
            end
            else begin
               wrdma_sm      <= WR_SEND;
               WrDmaArbReq_o <= 1'b1;
            end
         end

         default: begin
            wrdma_sm <= WR_IDLE; 
         end
      endcase
   end
end
 
 
// calculations for detecting 4K address boundary crossing
// - can be simplified if max_payld_size is assumed to be constant
// - or if okay to generate 1 pkt every 2 clocks.
assign file_size = cur_dma_dw_count;
assign file_addr = cur_dest_addr_reg;
assign file_num  = cur_desc_id_reg;

assign curr_addr_plus_filesizerem = curr_addr + {file_size_remain, 2'h0};
assign file_addr_plus_filesize    = file_addr + {file_size, 2'h0};
assign curr_addr_plus_maxpload    = curr_addr + {max_payld_size_reg, 2'h0};    
assign file_addr_plus_maxpload    = file_addr + {max_payld_size_reg, 2'h0}; 

               
always_ff @ (posedge Clk_i or negedge Rstn_i) begin
   if (~Rstn_i) begin 
      hdr_gen_sm         <= START_FILE;
      hdr_valid          <= 1'b0;
      hdr_address        <= 64'h00000000_00000000;
      hdr_size           <= 11'h000;
      hdr_file_num       <= 8'h0;
      hdr_file_end       <= 1'b0; 
      max_payld_size_reg <= 11'h000;
      curr_addr          <= 64'h00000000_00000000;
      file_advance       <= 1'b0;
      file_size_remain   <= {FILE_SIZE_WIDTH{1'b0}};
   end
   else begin
      max_payld_size_reg    <= max_payld_size;
      //-------------------------------------------
      // break file request down into TLP requests
      //-------------------------------------------

      case (hdr_gen_sm)  
         START_FILE: begin 
            hdr_valid        <= 1'b0;
            file_advance     <= 1'b0;  
            file_size_remain <= {FILE_SIZE_WIDTH{1'b0}};
            if (file_valid) begin 
               hdr_file_num <= file_num;
               hdr_address  <= file_addr;  
               hdr_valid    <= 1'b1;                       
               file_advance <= 1'b0;
               if (ALLOW_ANY_FILE_SIZE & (file_size <= max_payld_size_reg)) begin       // file request fits in one TLP
                  if (file_addr[12] != file_addr_plus_filesize[12]) begin               // handle 4K bound
                     hdr_size <= 11'h400 - {1'h0, file_addr[11:2]};    
                     if (file_size == (11'h400 - {1'h0, file_addr[11:2]})) begin       // file ends at 4K boundary, send all
                        hdr_file_end <= 1'b1;  
                        hdr_gen_sm   <= WAIT_LASTPKT_PROC;
                     end
                     else begin                                                                // file crosses 4K boundary, send partial
                        hdr_file_end <= 1'b0;  
                        hdr_gen_sm   <= CONT_FILE;
                     end
                     // calculate remaining file size and next tlp addr 
                     curr_addr        <= {file_addr[63:12], 12'h000} + 64'h00000000_00001000; // 4K boundary
                     file_size_remain <= file_size - (11'h400 - {1'h0, file_addr[11:2]});     // in DWs
                  end
                  else begin                                                                  // no 4K boundary - send entire file in 1 TLP
                     hdr_size     <= file_size; 
                     hdr_file_end <= 1'b1;   
                     hdr_gen_sm   <= WAIT_LASTPKT_PROC; 
                     file_advance <= 1'b0;
                  end
               end 
               else begin                                                                     // requires more than one TLP
                  hdr_gen_sm   <= CONT_FILE;
                  hdr_file_end <= 1'b0;   
                  file_advance <= 1'b0;
                  if (file_addr[12] != file_addr_plus_maxpload[12]) begin                     // break at 4K bound
                     hdr_size <= 11'h400 - {1'h0, file_addr[11:2]};               
                     // advance address, 
                     curr_addr        <= {file_addr[63:12], 12'h000} + 64'h00000000_00001000; // 4K boundary address
                     file_size_remain <= file_size - (11'h400 - {1'h0, file_addr[11:2]}); 
                  end
                  else begin                                                                  // no 4K bound - use max payload packet
                     hdr_size         <= max_payld_size_reg; 
                     curr_addr        <= file_addr[63:0] + {max_payld_size_reg, 2'h0};    
                     file_size_remain <= file_size - max_payld_size_reg; 
                  end
               end
            end
            else begin 
               file_advance <= hdr_advance; 
               hdr_valid    <= 1'b0;
               hdr_file_end <= 1'b0;  
               hdr_gen_sm   <= hdr_gen_sm;
            end
         end

         CONT_FILE: begin
            // file request requires another TLP to complete
            if (hdr_advance) begin 
               hdr_address <= curr_addr; 
               hdr_valid   <= 1'b1;
               if (file_size_remain <= max_payld_size_reg) begin                                  // could fit remaining file in one TLP
                  // 4K addr bound crossing - break TLP at 4K bound
                  if (curr_addr[12] != curr_addr_plus_filesizerem[12]) begin                      // handle 4K boundary 
                     hdr_size     <= (11'h400 - {1'h0, curr_addr[11:2]});   
                     if (file_size_remain == (11'h400 - {1'h0, curr_addr[11:2]})) begin           // file ends at 4K boundary, send all in one TLP
                        hdr_file_end <= 1'b1;  
                        hdr_gen_sm   <= WAIT_LASTPKT_PROC;
                     end
                     else begin                                                                   // file crosses 4K boundary, send partial
                        hdr_file_end <= 1'b0;  
                        hdr_gen_sm   <= CONT_FILE;
                     end
                     // calculate remaining file size and next tlp addr 
                     curr_addr        <= {curr_addr[63:12], 12'h000} + 64'h00000000_00001000;    // 4K boundary address 
                     file_size_remain <= file_size_remain - (11'h400 - {1'h0, curr_addr[11:2]});  
                  end
                  else begin                                                                     // send remaining file in one TLP
                     hdr_size     <= file_size_remain;
                     hdr_gen_sm   <= WAIT_LASTPKT_PROC; 
                     hdr_file_end <= 1'b1;  
                     file_advance <= 1'b0; 
                  end
               end 
               else begin                                                                        // remaining file does not fit in one TLP
                  hdr_file_end <= 1'b0;   
                  hdr_valid    <= 1'b1;
                  if (curr_addr[12] != curr_addr_plus_maxpload[12]) begin                       // break at 4K boundary
                     hdr_size   <= 11'h400 - {1'h0, curr_addr[11:2]} ;               
                     hdr_gen_sm <= CONT_FILE;  
                     // calculate remaining file size and next tlp addr 
                     curr_addr        <= {curr_addr[63:12], 12'h000} + 64'h00000000_00001000;   // 4K boundary address
                     file_size_remain <= file_size_remain - (11'h400 - {1'h0, curr_addr[11:2]}); 
                  end
                  else begin                                                                    // no 4K boundary - send max payload
                     hdr_size   <= max_payld_size_reg;
                     hdr_gen_sm <= CONT_FILE;  
                     // calculate next tlp size/addr  
                     curr_addr        <= curr_addr_plus_maxpload;   
                     file_size_remain <= file_size_remain - max_payld_size_reg;
                  end
               end 
            end
            else begin
               hdr_valid    <= 1'b0;
               file_advance <= 1'b0;
            end
         end 

         WAIT_LASTPKT_PROC: begin
            hdr_valid    <= 1'b0;
            file_advance <= 1'b0;
            // wait for last pkt to end processing
            // before requesting new file.   
            if (hdr_advance) begin
               hdr_gen_sm   <= START_FILE;  
               hdr_valid    <= 1'b0;
               file_advance <= 1'b1; 
            end
         end
         default: begin
            hdr_gen_sm   <= START_FILE;
         end
      endcase  // hdr_gen_sm
   end
end 

// Wait till there is enough data for a complete TLP till the
// header valid signal is issued to the TLP generator
always_ff @ (posedge Clk_i or negedge Rstn_i) begin
   if (~Rstn_i) begin 
      hdr_valid_r  <= 1'b0;
      hdr_valid_rr <= 1'b0;
   end
   else begin
      if (avst_ready || tlp_advance)
         hdr_valid_rr <= hdr_valid_r;
      else
         hdr_valid_rr <= hdr_valid_rr;
      // Latch hrd_valid till enough data is accumulated
      if (hdr_valid_wdata)
         hdr_valid_r <= 1'b0;
      else if (hdr_valid)
         hdr_valid_r <= 1'b1;
      else if ((((data_fifo_count*8)+hdr_partial_word_sel) >= hdr_size) && avst_ready)
         hdr_valid_r <= 1'b0;
   end
end
	
assign hdr_valid_wdata = (~hdr_valid_r && hdr_valid_rr) || 
                         (hdr_valid && (((data_fifo_count*8)+hdr_partial_word_sel) >= hdr_size) 
                         && tlp_advance && ~WrDmaReadArbReq_i);

//TLP generator


// Assign partial word select on next TLP 
// It is latched on the previous TLP
always_ff @ (posedge Clk_i or negedge Rstn_i) begin
   if (~Rstn_i) 
      hdr_partial_word_en <= 3'h0;
   else if (hdr_valid)
      hdr_partial_word_en <= hdr_partial_word_sel; 
end

 
// convert header size to pcie TLP length field
assign tlp_length_n = hdr_size[10] ? 10'h000 : hdr_size[9:0];  


// calculate the fmt_type field
// MEMWR with 4DW or 3DW address
assign tlp_4dw_hdr    = |hdr_address[63:32];
assign tlp_odd_dwaddr = hdr_address[2];
assign fmt_type       = tlp_4dw_hdr ?  8'h60 : 8'h40;   

// calculate PciE TLP first byte enable field
assign tlp_byte_ena[3:0] = (hdr_address[1:0]==2'h0) ?  4'b1111 :
                           (hdr_address[1:0]==2'h1) ?  4'b1110 :
                           (hdr_address[1:0]==2'h2) ?  4'b1100 : 4'b1000 ;

// calculate PciE TLP last byte enable field
// - for now restrict file size to whole DWs
assign tlp_byte_ena[7:4] = (hdr_size < 11'h2)       ?  4'b0000 :
                           (hdr_address[1:0]==2'h0) ?  4'b1111 :
                           (hdr_address[1:0]==2'h1) ?  4'b0111 :
                           (hdr_address[1:0]==2'h2) ?  4'b0011 : 4'b0001 ;
                              
   
always @ (posedge Clk_i or negedge Rstn_i) begin
   if (~Rstn_i) begin 
      tlp_val              <= 1'b0;
      tlp_read             <= 1'b0;
      tlp_start            <= 1'b0;
      tlp_end              <= 8'h0;  
      tlp_desc             <= 128'h0; 
      tlp_file_num         <= 8'h0;
      tlp_file_end         <= 1'b0; 
      tlp_gen_sm           <= INIT;
      hdr_size_remain      <= 10'h0;
      payld_count_ctl      <= 2'b00;     
      hdr_file_end_hold    <= 1'b0;
      hdr_advance          <= 1'b0;
      hdr_partial_word_sel <= 3'h0;
   end
   else begin    
   //-----------------------------------
   // payload state machine
   // - issue desc cycle + data cycles
   // - indicate start + end cycles
   //-----------------------------------
      case (tlp_gen_sm) 
         INIT: begin 
            tlp_gen_sm           <= START_DATA;
            payld_count_ctl      <= 2'b01;  // initialize payload counters
            hdr_partial_word_sel <= 3'h0;
            tlp_val              <= 1'b0;
            tlp_read             <= 1'b0;
         end

         START_DATA: begin 
            hdr_partial_word_sel <= tlp_file_end ? 3'h0 : hdr_partial_word_sel;       
            if (hdr_valid_wdata) begin			 
               tlp_file_num <= hdr_file_num;
               tlp_val      <= tlp_advance;	
               tlp_read     <= (hdr_size <= hdr_partial_word_sel) ? 1'b0 : tlp_advance;	
               tlp_start    <= 1'b1; 
               tlp_desc     <= tlp_4dw_hdr ? {fmt_type, 8'h00, 6'h0, tlp_length_n, BusDev_i, 8'h0, tlp_byte_ena, hdr_address[63:2], 2'h0} : 
                                             {fmt_type, 8'h00, 6'h0, tlp_length_n, BusDev_i, 8'h0, tlp_byte_ena, hdr_address[31:2], 34'h0};   
               hdr_file_end_hold <= hdr_file_end;
               // more than 1 data phase, allow one more dw when addr alignment required
               if (hdr_size + (tlp_4dw_hdr & tlp_odd_dwaddr & AVST_ADDR_ALIGN) > 11'h4) begin 
                  tlp_gen_sm      <= tlp_advance ? CONT_DATA : tlp_gen_sm;   
                  payld_count_ctl <= tlp_advance ? 2'b10 : 2'b00;        // advance payload counters
                  if (hdr_size < 11'd9) begin
                     case (hdr_size)
                        11'h8:   tlp_end <= 8'b1000_0000;
                        11'h7:   tlp_end <= 8'b0100_0000;
                        11'h6:   tlp_end <= 8'b0010_0000;
                        11'h5:   tlp_end <= 8'b0001_0000;
                        11'h4:   tlp_end <= 8'b0000_1000;
                        11'h3:   tlp_end <= 8'b0000_0100;
                        11'h2:   tlp_end <= 8'b0000_0010;
                        11'h1:   tlp_end <= 8'b0000_0001;
                        default: tlp_end <= 8'b0000_0000;
                     endcase
                     case (hdr_size) 
                        10'h8:   hdr_partial_word_sel <= 3'h0; 
                        10'h7:   hdr_partial_word_sel <= 3'h1; 
                        10'h6:   hdr_partial_word_sel <= 3'h2; 
                        10'h5:   hdr_partial_word_sel <= 3'h3;
                        10'h4:   hdr_partial_word_sel <= 3'h4;
                        10'h3:   hdr_partial_word_sel <= 3'h5; 
                        10'h2:   hdr_partial_word_sel <= 3'h6; 
                        10'h1:   hdr_partial_word_sel <= 3'h7; 
                        10'h0:   hdr_partial_word_sel <= 3'h0; 
                        default: hdr_partial_word_sel <= 3'h0; 
                     endcase
                     hdr_size_remain <= hdr_size;
                     tlp_file_end    <= hdr_file_end;
                  end
                  else begin
                     tlp_end         <= 8'h00;  
                     hdr_size_remain <= (hdr_size - 11'h8 - hdr_partial_word_sel); 
                     tlp_file_end    <= 1'b0;
                  end
               end
               else begin                                           // only 1 data phase
                  tlp_gen_sm      <= START_DATA;  
                  hdr_advance     <= tlp_advance;  
                  tlp_file_end    <= hdr_file_end;
                  payld_count_ctl <= tlp_advance ? 2'b01 : 2'b00;  // initialize payload counters
                  hdr_size_remain <= hdr_size;
                  case (hdr_size) 
                     11'h8:   tlp_end <= 8'b1000_0000;
                     11'h7:   tlp_end <= 8'b0100_0000;
                     11'h6:   tlp_end <= 8'b0010_0000;
                     11'h5:   tlp_end <= 8'b0001_0000;
                     11'h4:   tlp_end <= 8'b0000_1000;
                     11'h3:   tlp_end <= 8'b0000_0100;
                     11'h2:   tlp_end <= 8'b0000_0010;
                     11'h1:   tlp_end <= 8'b0000_0001;
                     default: tlp_end <= 8'b0000_0000;
                  endcase 
                  case (hdr_size) 
                     10'h8:   hdr_partial_word_sel <= 3'h0; 
                     10'h7:   hdr_partial_word_sel <= 3'h1; 
                     10'h6:   hdr_partial_word_sel <= 3'h2; 
                     10'h5:   hdr_partial_word_sel <= 3'h3;
                     10'h4:   hdr_partial_word_sel <= 3'h4;
                     10'h3:   hdr_partial_word_sel <= 3'h5; 
                     10'h2:   hdr_partial_word_sel <= 3'h6; 
                     10'h1:   hdr_partial_word_sel <= 3'h7; 
                     10'h0:   hdr_partial_word_sel <= 3'h0; 
                     default: hdr_partial_word_sel <= 3'h0; 
                  endcase
               end
            end
            else begin   
               tlp_start       <= tlp_start;
               tlp_end         <= tlp_end;   
               tlp_file_end    <= tlp_file_end; 
               payld_count_ctl <= 2'b00;
               tlp_val         <= 1'b0;
               tlp_read        <= 1'b0;
               hdr_advance     <= 1'b0;  
            end
         end

         CONT_DATA: begin     
            tlp_val  <= (hdr_size < 11'd9) ? 1'b0 : tlp_advance;
            tlp_read <= ((hdr_size - hdr_partial_word_sel < 11'd9) || (hdr_size_remain == 10'h0) ||
                        (hdr_file_end_hold && (hdr_size_remain > max_payld_size_reg))) ? 1'b0 : tlp_advance;
            if (tlp_advance) begin  
               tlp_start       <= 1'b0; 
               hdr_size_remain <= hdr_size_remain - 10'h8;	
               if(hdr_size_remain + hdr_partial_word_sel < 10'h9) begin // generating last data cycle of TLP 
                  case (hdr_size_remain + hdr_partial_word_sel) 
                     10'h8:   tlp_end <= 8'b1000_0000; 
                     10'h7:   tlp_end <= 8'b0100_0000; 
                     10'h6:   tlp_end <= 8'b0010_0000; 
                     10'h5:   tlp_end <= 8'b0001_0000; 
                     10'h4:   tlp_end <= 8'b0000_1000; 
                     10'h3:   tlp_end <= 8'b0000_0100; 
                     10'h2:   tlp_end <= 8'b0000_0010; 
                     10'h1:   tlp_end <= 8'b0000_0001; 
                     10'h0:   tlp_end <= 8'b0000_0001; 
                     default: tlp_end <= 8'b0000_0000; 
                  endcase
                  case (hdr_size_remain) 
                     10'h8:   hdr_partial_word_sel <= 3'h0; 
                     10'h7:   hdr_partial_word_sel <= 3'h1; 
                     10'h6:   hdr_partial_word_sel <= 3'h2; 
                     10'h5:   hdr_partial_word_sel <= 3'h3;
                     10'h4:   hdr_partial_word_sel <= 3'h4;
                     10'h3:   hdr_partial_word_sel <= 3'h5; 
                     10'h2:   hdr_partial_word_sel <= 3'h6; 
                     10'h1:   hdr_partial_word_sel <= 3'h7; 
                     10'h0:   hdr_partial_word_sel <= 3'h0; 
                     default: hdr_partial_word_sel <= 3'h0; 
                  endcase
                  tlp_gen_sm      <= START_DATA;
                  hdr_advance     <= 1'b1;
                  tlp_file_end    <= hdr_file_end_hold;
                  payld_count_ctl <= 2'b01;             // intialize payload counters					  
               end
               else begin                               // need more data cycles
                  tlp_end         <= 8'h00; 
                  tlp_gen_sm      <= tlp_gen_sm;    
                  payld_count_ctl <= 2'b10;             // advance payload counters
                  tlp_file_end    <= 1'b0; 
                  hdr_advance     <= 1'b0;
               end
            end
            else begin  
               payld_count_ctl <= 2'b00; 
               hdr_advance     <= 1'b0;
            end			
         end

         default: begin 
            tlp_gen_sm <= INIT;
         end
      endcase  // tlp_gen_sm 
   end
end

//----------------------------------------------------------------	
// AVST Fifo Interface
//----------------------------------------------------------------
assign avst_ready        = (TxFifoCount_i < 10);
assign tlp_odd_dwaddr_av = tlp_desc[125] ? tlp_desc[2] : tlp_desc[34];
assign tlp_4dw_hdr_av    = tlp_desc[125];

// Data to AVST Interface
always_ff @ (posedge Clk_i or negedge Rstn_i) begin
   if (~Rstn_i) begin
      data_fifo_data_r <= 256'h0;
      payld_shift      <= 1'b0;
   end
   else begin
      payld_shift      <= payld_shift_n;
      if (data_fifo_rdreq)
         data_fifo_data_r <= data_fifo_data;
      else
         data_fifo_data_r <= data_fifo_data_r;
   end
end

//-----------------------------------------------------------------
// Select data appropriately from two 256 bit data words when only 
// a part of the word is used in a TLP, the rest of the word needs 
// to be used in another TLP
//----------------------------------------------------------------
always @ (*) begin 	//(data_fifo_data or data_fifo_data_r or hdr_partial_word_en)
   case (hdr_partial_word_en)
      3'b000:  tlp_data = data_fifo_data;
      3'b001:  tlp_data = {data_fifo_data[223:0], data_fifo_data_r[255:224]};
      3'b010:  tlp_data = {data_fifo_data[191:0], data_fifo_data_r[255:192]};
      3'b011:  tlp_data = {data_fifo_data[159:0], data_fifo_data_r[255:160]};
      3'b100:  tlp_data = {data_fifo_data[127:0], data_fifo_data_r[255:128]};
      3'b101:  tlp_data = {data_fifo_data[95:0], data_fifo_data_r[255:96]};
      3'b110:  tlp_data = {data_fifo_data[63:0], data_fifo_data_r[255:64]};
      3'b111:  tlp_data = {data_fifo_data[31:0], data_fifo_data_r[255:32]};
      default: tlp_data = data_fifo_data;
   endcase
end


//------------------------------------------------------------
// shift payload 
// - some payload is sent along with header, the rest are  
//   deferred to next cycle.  
//------------------------------------------------------------

assign payld_shift_n = ~tlp_val ? payld_shift :
            (AVST_ADDR_ALIGN & tlp_4dw_hdr_av & tlp_odd_dwaddr_av)   ? 3'h3 :        // 4DW hdr, odd addr - fit 3 DWs of payld in first cycle
            (AVST_ADDR_ALIGN & tlp_4dw_hdr_av & ~tlp_odd_dwaddr_av)  ? 3'h4 :        // 4DW hdr, even addr - fit 4 DWs of payld in first cycle
            (AVST_ADDR_ALIGN & ~tlp_4dw_hdr_av & ~tlp_odd_dwaddr_av) ? 3'h4 :        // 3DW hdr, even addr - fit 4 DWs of payld in first cycle
            (AVST_ADDR_ALIGN & ~tlp_4dw_hdr_av & tlp_odd_dwaddr_av)  ? 3'h5 :        // 3DW hdr, odd addr - fit 5 DWs of payld in first cycle
            (~AVST_ADDR_ALIGN & tlp_4dw_hdr_av)                      ? 3'h4 : 3'h5 ; // No addr align  
  
assign tlp_end_shifted_n = (payld_shift_n==3'h3) ? {(tlp_end[2:0] & {3{tlp_val}}), tlp_end_hold[7:3]} :
                           (payld_shift_n==3'h4) ? {(tlp_end[3:0] & {4{tlp_val}}), tlp_end_hold[7:4]} :
                                                   {(tlp_end[4:0] & {5{tlp_val}}), tlp_end_hold[7:5]} ; 
										 
assign tlp_data_shifted_n = (payld_shift_n==3'h3) ? {tlp_data[95:0],  tlp_data_hold[255:96]}  :
 (payld_shift_n==3'h4) ? {tlp_data[127:0], tlp_data_hold[255:128]} :
 {tlp_data[159:0], tlp_data_hold[255:160]} ;
		 
		 
always_ff @ (posedge Clk_i or negedge Rstn_i) begin
   if (~Rstn_i) begin 
      avst_data         <= 256'h0;  
      avst_valid        <= 1'b0;
      avst_sop          <= 1'b0;
      avst_eop          <= 1'b0;
      avst_empty        <= 2'h0;
      avst_file_num     <= 8'h0;
      avst_file_end     <= 1'b0;
      tlp_data_hold     <= 256'h0;
      tlp_end_hold      <= 8'h0; 
      tlp_file_end_hold <= 1'b0;
      avst_sm           <= AVST_START_STATE; 
      tlp_advance       <= 1'b0;
   end	 
   else begin 	
      tlp_data_hold     <= tlp_val ? tlp_data : tlp_data_hold;		 	  
      if (~tlp_desc[126]) begin   // no payloadr
         avst_empty <= 2'h2;   
      end
      else begin
         case (tlp_end_shifted_n)
            8'b0000_0000: avst_empty <= 2'h0;
            8'b1000_0000: avst_empty <= 2'h0;
            8'b0100_0000: avst_empty <= 2'h0;
            8'b0010_0000: avst_empty <= 2'h1;
            8'b0001_0000: avst_empty <= 2'h1;
            8'b0000_1000: avst_empty <= 2'h2;
            8'b0000_0100: avst_empty <= 2'h2;
            default:      avst_empty <= 2'h3; 
         endcase 
      end 
      //----------------------------------------------------------
      // this controller processes every tlp_val it receives.
      // it is not throttled by the downstream module.
      // instead, the downstream module directly throttles the
      // tlp generator.  
      // this module can also stall the tlp generator when address
      // alignment causes an extra data cycle to be inserted into
      // the datastream.
      //----------------------------------------------------------
      case (avst_sm) 
         AVST_START_STATE: begin
            if (tlp_start & tlp_val) begin                           
               //----------------------------
               // avst data = desc + data 
               //---------------------------- 
               if (AVST_ADDR_ALIGN) begin
                  case ({tlp_4dw_hdr_av, tlp_odd_dwaddr_av})
                     2'b11:   avst_data <= {tlp_data[95:0], 32'h0, tlp_desc[31:0], tlp_desc[63:32], tlp_desc[95:64], tlp_desc[127:96]};  
                     2'b10:   avst_data <= {tlp_data[127:0], tlp_desc[31:0], tlp_desc[63:32], tlp_desc[95:64], tlp_desc[127:96]};  
                     2'b00:   avst_data <= {tlp_data[127:0], 32'h0, tlp_desc[63:32], tlp_desc[95:64], tlp_desc[127:96]};  
                     default: avst_data <= {tlp_data[159:0], tlp_desc[63:32], tlp_desc[95:64], tlp_desc[127:96]};  
                  endcase
               end
               else begin
                  if (tlp_4dw_hdr_av) begin 
                     avst_data <= {tlp_data[127:0], tlp_desc[31:0], tlp_desc[63:32], tlp_desc[95:64], tlp_desc[127:96]};  
                  end
                  else begin
                     avst_data <= {tlp_data[159:0], tlp_desc[63:32], tlp_desc[95:64], tlp_desc[127:96]};  
                  end                               
               end 
               //------------------------
               // avst control signals
               //------------------------
               avst_sop      <= 1'b1;
               avst_valid    <= 1'b1;
               avst_file_num <= tlp_file_num;
               if (~tlp_desc[126]) begin                       // no payload
                  avst_eop      <= 1'b1; 
                  avst_file_end <= tlp_file_end;
                  avst_sm       <= AVST_START_STATE; 
                  tlp_end_hold  <= 8'h00;
                  tlp_advance   <= avst_ready;                        
               end
               else if (|tlp_end & ~|tlp_end_shifted_n) begin // rcving end of payload, but needs to be deferred to next cycle
                  avst_eop          <= 1'b0; 
                  avst_file_end     <= 1'b0;
                  avst_sm           <= AVST_EXTRA_DATA_STATE; // insert extra data cycle for deferred data
                  tlp_end_hold      <= tlp_end; 
                  tlp_file_end_hold <= tlp_file_end;
                  tlp_advance       <= 1'b0; 
               end
               else if (|tlp_end) begin                       // rcving end of payload that can fit in current AVST cycle
                  avst_eop      <= 1'b1; 
                  avst_file_end <= tlp_file_end;
                  avst_sm       <= AVST_START_STATE; 
                  tlp_end_hold  <= 8'h00;
                  tlp_advance   <= avst_ready; 
               end
               else begin                                     // not rcving end of payload
                  avst_eop      <= 1'b0; 
                  avst_file_end <= 1'b0;
                  avst_sm       <= AVST_DATA_STATE;
                  tlp_end_hold  <= tlp_end;
                  tlp_advance   <= avst_ready;
               end 
            end
            else begin
               avst_valid    <= 1'b0;
               avst_sop      <= 1'b0;
               avst_eop      <= 1'b0;
               avst_file_end <= 1'b0; 
               tlp_advance   <= avst_ready;
            end
         end

         AVST_DATA_STATE: begin 
            //----------------------
            // avst data format
            //----------------------
            avst_data <= tlp_data_shifted_n;  
            //------------------------
            // avst conrol signals
            //------------------------
            avst_sop    <= 1'b0; 
            avst_valid  <= tlp_val;  
            if (|tlp_end & ~|tlp_end_shifted_n) begin      // rcving end of payload, but needs to be deferred to next cycle
               avst_eop          <= 1'b0; 
               avst_file_end     <= 1'b0;
               avst_sm           <= AVST_EXTRA_DATA_STATE; // insert extra data cycle for deferred data
               tlp_end_hold      <= tlp_end; 
               tlp_file_end_hold <= tlp_file_end;
               tlp_advance       <= avst_ready;	
            end
            else if (|tlp_end) begin                      // rcving end of payload that can fit in current AVST cycle
               avst_eop      <= 1'b1; 
               avst_file_end <= tlp_file_end;
               avst_sm       <= AVST_START_STATE; 
               tlp_end_hold  <= 8'h00;  
               tlp_advance   <= avst_ready; 
            end
            else begin                                    // not rcving end of payload
               avst_eop      <= 1'b0; 
               avst_file_end <= 1'b0;
               avst_sm       <= AVST_DATA_STATE;
               tlp_end_hold  <= tlp_end; 
               tlp_advance   <= avst_ready; 
            end  
         end

         AVST_EXTRA_DATA_STATE: begin
            // This state is required when Address alignment 
            // causes an extra data cycle to be inserted into 
            // the data stream.
            //----------------------
            // avst data format
            //----------------------
            avst_data <= tlp_data_shifted_n;  
            //------------------------
            // avst conrol signals
            //------------------------
            avst_valid    <= 1'b1;
            avst_eop      <= 1'b1; 
            avst_sop      <= 1'b0; 
            avst_file_end <= tlp_file_end_hold;
            avst_sm       <= AVST_START_STATE; 
            tlp_end_hold  <= 8'h00;
            tlp_advance   <= avst_ready;  
         end
         default: begin
            avst_sm       <= AVST_START_STATE;
         end
      endcase // avst_sm
   end   
end

//wrdma_assertions wrdma_assertions_inst(
//   );

endmodule

//program wrdma_assertions(
//   );

//endprogram
