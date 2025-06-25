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


module altpcieav_desc_control (
      input logic                                   Clk_i,
      input logic                                   Rstn_i,

      // Descriptor Table Master Interface
      output   logic                                DTMRead_o,
      output   logic [63:0]                         DTMAddress_o,
      input    logic                                DTMWaitRequest_i,
      input    logic [255:0]                        DTMReadData_i,
      input    logic                                DTMReadDataValid_i,

      // Read DMA AST Tx port
      output   logic  [159:0]                       RdDdmaTxData_o,
      output   logic                                RdDdmaTxValid_o,
      input    logic                                RdDdmaTxReady_i,

      // Read DMA AST Rx port
      input   logic  [31:0]                         RdDdmaRxData_i,
      input   logic                                 RdDdmaRxValid_i,

      // Write DMA AST Tx port
      output   logic  [159:0]                       WrDdmaTxData_o,
      output   logic                                WrDdmaTxValid_o,
      input    logic                                WrDdmaTxReady_i,

      // Write DMA AST Rx port
      input   logic  [31:0]                         WrDdmaRxData_i,
      input   logic                                 WrDdmaRxValid_i,

      // Master Control
      output  logic                                 DCMRead_o,
      output  logic                                 DCMWrite_o,
      output  logic  [63:0]                         DCMAddress_o,
      output  logic  [31:0]                         DCMWriteData_o,
      output  logic  [3:0]                          DCMByteEnable_o,
      input   logic                                 DCMWaitRequest_i,
      input   logic  [31:0]                         DCMReadData_i,
      input   logic                                 DCMReadDataValid_i,

      // Slave Control
      input  logic                                  DCSChipSelect_i,
      input  logic                                  DCSRead_i,
      input  logic                                  DCSWrite_i,
      input  logic  [11:0]                          DCSAddress_i,
      input  logic  [31:0]                          DCSWriteData_i,
      input  logic  [3:0]                           DCSByteEnable_i,
      output logic                                  DCSWaitRequest_o,
      output logic  [31:0]                          DCSReadData_o,

      // MSI supported signals
      input  logic  [81:0]			    MsiIntfc_i
  );

localparam DTFCTL_IDLE = 4'h1;
localparam DTFCTL_FETCH_TABLE = 4'h2;
localparam DTFCTL_TABLE_WAIT = 4'h4;
localparam DTFCTL_DONE = 4'h8;

localparam DTMWRCTL_IDLE = 3'h1;
localparam DTMWRCTL_COPY_TABLE = 3'h2;
localparam DTMWRCTL_DONE = 3'h4;

localparam DTMRDCTL_IDLE = 3'h1;
localparam DTMRDCTL_COPY_TABLE = 3'h2;
localparam DTMRDCTL_DONE = 3'h4;

localparam WRCTL_IDLE = 8'h01;
localparam WRCTL_PUSH_DESC = 8'h02;
localparam WRCTL_PUSH_DESC_WAIT = 8'h04;
localparam WRCTL_PAUSED = 8'h08;
localparam WRCTL_PAUSE_WAIT = 8'h10;
localparam WRCTL_ABORTED = 8'h20;
localparam WRCTL_FLUSHED = 8'h40;
localparam WRCTL_DONE = 8'h80;

localparam RDCTL_IDLE = 8'h01;
localparam RDCTL_PUSH_DESC = 8'h02;
localparam RDCTL_PUSH_DESC_WAIT = 8'h04;
localparam RDCTL_PAUSED = 8'h08;
localparam RDCTL_PAUSE_WAIT = 8'h10;
localparam RDCTL_ABORTED = 8'h20;
localparam RDCTL_FLUSHED = 8'h40;
localparam RDCTL_DONE = 8'h80;

localparam DCMCTL_IDLE = 9'h001;
localparam DCMCTL_RDCPL = 9'h002;
localparam DCMCTL_WRCPL = 9'h004;
localparam DCMCTL_RDMSI = 9'h008;
localparam DCMCTL_WRMSI = 9'h010;
localparam DCMCTL_WRITE_WRCRA = 9'h020;
localparam DCMCTL_WRITE_RDCRA = 9'h040;
localparam DCMCTL_ABNORMAL_WRCPL = 9'h80;
localparam DCMCTL_ABNORMAL_RDCPL = 9'h100;


logic [15:0] reg_decode;
logic [31:0] reg_read_data_reg;
logic [31:0] reg_mux_out;

logic	     wr_control_wren;
logic	     wr_rcdt_address_low_wrena;
logic	     wr_rcdt_address_hi_wrena;
logic	     wr_last_index_wrena;
logic	     wr_epdt_address_low_wrena;
logic	     wr_epdt_address_hi_wrena;
logic	     rd_control_wren;
logic	     rd_rcdt_address_low_wrena;
logic	     rd_rcdt_address_hi_wrena;
logic	     rd_last_index_wrena;
logic	     rd_epdt_address_low_wrena;
logic	     rd_epdt_address_hi_wrena;

logic [31:0] wr_ctl_reg;
logic [31:0] wr_status_reg;
logic [31:0] wr_rcdt_address_low_reg;
logic [31:0] wr_rcdt_address_hi_reg;
logic [63:0] wr_rcdt_address;
logic [31:0] wr_last_index_reg;
logic [31:0] wr_epdt_address_low_reg;
logic [31:0] wr_epdt_address_hi_reg ;
logic [31:0] wr_perf_reg;
logic [31:0] rd_ctl_reg;
logic [31:0] rd_status_reg;
logic [31:0] rd_rcdt_address_low_reg;
logic [31:0] rd_rcdt_address_hi_reg;
logic [63:0] rd_rcdt_address;
logic [31:0] rd_last_index_reg;
logic [31:0] rd_epdt_address_low_reg;
logic [31:0] rd_epdt_address_hi_reg;
logic [31:0] rd_perf_reg;

logic register_access;
logic register_access_reg;
logic register_access_rise;
logic register_ready_reg;


logic wr_loop_reg;
logic wr_flush_reg;
logic wr_abort_reg;
logic wr_resume_reg;
logic wr_pause_reg;
logic wr_last_enable_reg;
logic wr_msi_enable_reg;
logic wr_dma_start_reg;
logic [7:0] wr_num_descriptor_reg;
logic wr_flush_clear;
logic wr_abort_clear;
logic wr_resume_clear;
logic wr_pause_clear;
logic wr_dma_start_reg_clr;
logic wr_pause_rr;
logic wr_resume_rr;
logic wr_abort_rr;
logic wr_flush_rr;
logic wr_pause_rise;
logic wr_resume_rise;
logic wr_abort_rise;
logic wr_flush_rise;
logic wr_dma_start_rr;
logic wr_dma_start_rise;
//logic [7:0] wr_stat_reg;
logic [7:0] last_wr_id;
logic [31:0] wr_perf_cntr;
logic [31:0] wr_mover_status_reg;
logic [31:0] wr_mover_status_rr;
logic wr_mover_status_flushed;
logic wr_mover_status_aborted;
logic wr_mover_status_paused;
//logic wr_mover_status_flush_re;
//logic wr_mover_status_abort_re;
//logic wr_mover_status_pause_re;
logic wr_mover_status_busy;
logic wr_mover_status_done;
logic [7:0] wr_mover_status_id;

logic rd_loop_reg;
logic rd_flush_reg;
logic rd_abort_reg;
logic rd_resume_reg;
logic rd_pause_reg;
logic rd_last_enable_reg;
logic rd_msi_enable_reg;
logic rd_dma_start_reg;
logic [7:0] rd_num_descriptor_reg;
logic rd_flush_clear;
logic rd_abort_clear;
logic rd_resume_clear;
logic rd_pause_clear;
logic rd_dma_start_reg_clr;
logic rd_pause_rr;
logic rd_resume_rr;
logic rd_abort_rr;
logic rd_flush_rr;
logic rd_pause_rise;
logic rd_resume_rise;
logic rd_abort_rise;
logic rd_flush_rise;
logic rd_dma_start_rr;
logic rd_dma_start_rise;
//logic [7:0] rd_stat_reg;
logic [7:0] last_rd_id;
logic [31:0] rd_perf_cntr;
logic [31:0] rd_mover_status_reg;
logic [31:0] rd_mover_status_rr;
logic rd_mover_status_flushed;
logic rd_mover_status_paused;
logic rd_mover_status_aborted;
//logic rd_mover_status_flush_re;
//logic rd_mover_status_pause_re;
//logic rd_mover_status_abort_re;
logic rd_mover_status_busy;
logic rd_mover_status_done;
logic [7:0] rd_mover_status_id;

// Desc. Table Fetch State Machine Registers
logic [3:0] dtf_state;
logic [3:0] dtf_nxt_state;
logic [6:0] dt_copy_addr_incr_reg;
logic [6:0] dt_copy_addr_incr_reg_lookahead;
logic	    dt_copy_addr_incr;
logic [6:0] dt_copy_readvalid_addr_incr_reg;
logic [6:0] local_rddt_mem_addr_incr_reg;
logic [6:0] local_wrdt_mem_addr_incr_reg;
logic local_rddt_mem_addr_incr_reg_clr;
logic local_wrdt_mem_addr_incr_reg_clr;
logic rdwr_table_fetch_on;
logic is_current_dtf_read;
//logic is_current_dt_copy_read_reg;
//logic is_current_dt_copy_read;
//logic is_current_dt_copy_read_reg_clr;
logic rddt_copy_start_reg;
logic rddt_copy_start;
logic rddt_copy_start_reg_clr;
logic wrdt_copy_start_reg;
logic wrdt_copy_start;
logic wrdt_copy_start_reg_clr;


// Descriptor Table Master Rd/Wr State Machines Registers
logic [2:0] dtm_wr_state;
logic [2:0] dtm_wr_nxt_state;
logic dt_start_wr_exec_reg;
logic dt_start_wr_exec;
logic dt_start_wr_exec_reg_clr;
logic [2:0] dtm_rd_state;
logic [2:0] dtm_rd_nxt_state;
logic dt_start_rd_exec_reg;
logic dt_start_rd_exec;
logic dt_start_rd_exec_reg_clr;

// DMA RD & DMA WR Execute State Machine Registers
logic [7:0] wr_state;
logic [7:0] wr_nxt_state;
logic write_wrdma_cpl_ctl;
logic write_wrdma_abnormal_event_cpl_ctl;
logic wrctl_push_desc_done_reg;
logic [7:0] rd_state;
logic [7:0] rd_nxt_state;
logic write_rddma_cpl_ctl;
logic write_rddma_abnormal_event_cpl_ctl;
logic rdctl_push_desc_done_reg;

// Desc. Control Master (Tx Slave Control) State Machine Registers
logic [8:0] dcm_state;
logic [8:0] dcm_nxt_state;
logic write_rddma_cpl_ctl_pending_reg;
logic write_rddma_cpl_ctl_pending;
logic write_wrdma_cpl_ctl_pending_reg;
logic write_wrdma_cpl_ctl_pending;
logic write_wrdma_cpl_ctl_pending_clr;
logic write_rddma_cpl_ctl_pending_clr;
logic write_wrdma_abnormal_event_cpl_pending_reg;
logic write_rddma_abnormal_event_cpl_pending_reg;
logic write_wrdma_abnormal_event_cpl_pending_clr;
logic write_rddma_abnormal_event_cpl_pending_clr;
logic send_rddma_cpl;
logic send_wrdma_cpl;
logic send_wrdma_abnormal_event_cpl;
logic send_rddma_abnormal_event_cpl;
logic send_dma_cpl_msi;
logic write_wrcra;
logic write_rdcra;

logic [5:0] wrcpl_fifo_count;
logic [5:0] rdcpl_fifo_count;
logic [7:0] wr_eplast;
logic [7:0] rd_eplast;
logic [7:0] wr_eplast_reg;
logic [7:0] rd_eplast_reg;
logic readcpl_fifo_rdreq, writecpl_fifo_rdreq;
logic eplast_fifo_toggle, eplast_fifo_toggle_r;

//////***********  The Slave Interface for Register Access from PCIe RP  *************///////
/// register address decode
always_comb   begin
   case (DCSAddress_i)
     12'h000 : reg_decode[15:0] = 16'b0000_0000_0000_0001;
     12'h004 : reg_decode[15:0] = 16'b0000_0000_0000_0010;
     12'h008 : reg_decode[15:0] = 16'b0000_0000_0000_0100;
     12'h00C : reg_decode[15:0] = 16'b0000_0000_0000_1000;
     12'h010 : reg_decode[15:0] = 16'b0000_0000_0001_0000;
     12'h014 : reg_decode[15:0] = 16'b0000_0000_0010_0000;
     12'h018 : reg_decode[15:0] = 16'b0000_0000_0100_0000;
     12'h01C : reg_decode[15:0] = 16'b0000_0000_1000_0000;
     12'h100 : reg_decode[15:0] = 16'b0000_0001_0000_0000;
     12'h104 : reg_decode[15:0] = 16'b0000_0010_0000_0000;
     12'h108 : reg_decode[15:0] = 16'b0000_0100_0000_0000;
     12'h10C : reg_decode[15:0] = 16'b0000_1000_0000_0000;
     12'h110 : reg_decode[15:0] = 16'b0001_0000_0000_0000;
     12'h114 : reg_decode[15:0] = 16'b0010_0000_0000_0000;
     12'h118 : reg_decode[15:0] = 16'b0100_0000_0000_0000;
     12'h11C : reg_decode[15:0] = 16'b1000_0000_0000_0000;
     default : reg_decode[15:0] = 16'b0000_0000_0000_0001;
   endcase
end

assign  wr_control_wren            =  reg_decode[0] & DCSWrite_i & DCSChipSelect_i;
assign  wr_rcdt_address_low_wrena  =  reg_decode[2] & DCSWrite_i & DCSChipSelect_i;
assign  wr_rcdt_address_hi_wrena   =  reg_decode[3] & DCSWrite_i & DCSChipSelect_i;
assign  wr_last_index_wrena        =  reg_decode[4] & DCSWrite_i & DCSChipSelect_i;
assign  wr_epdt_address_low_wrena  =  reg_decode[5] & DCSWrite_i & DCSChipSelect_i;
assign  wr_epdt_address_hi_wrena   =  reg_decode[6] & DCSWrite_i & DCSChipSelect_i;

assign  rd_control_wren            =  reg_decode[8] & DCSWrite_i & DCSChipSelect_i;
assign  rd_rcdt_address_low_wrena  =  reg_decode[10] & DCSWrite_i & DCSChipSelect_i;
assign  rd_rcdt_address_hi_wrena   =  reg_decode[11] & DCSWrite_i & DCSChipSelect_i;
assign  rd_last_index_wrena        =  reg_decode[12] & DCSWrite_i & DCSChipSelect_i;
assign  rd_epdt_address_low_wrena  =  reg_decode[13] & DCSWrite_i & DCSChipSelect_i;
assign  rd_epdt_address_hi_wrena   =  reg_decode[14] & DCSWrite_i & DCSChipSelect_i;

// Read decode mux
always_comb begin
   case (reg_decode)
     16'b0000_0000_0000_0001: reg_mux_out = wr_ctl_reg;
     16'b0000_0000_0000_0010: reg_mux_out = wr_status_reg;
     16'b0000_0000_0000_0100: reg_mux_out = wr_rcdt_address_low_reg;
     16'b0000_0000_0000_1000: reg_mux_out = wr_rcdt_address_hi_reg;
     16'b0000_0000_0001_0000: reg_mux_out = wr_last_index_reg;
     16'b0000_0000_0010_0000: reg_mux_out = wr_epdt_address_low_reg;
     16'b0000_0000_0100_0000: reg_mux_out = wr_epdt_address_hi_reg;
     16'b0000_0000_1000_0000: reg_mux_out = wr_perf_reg;
     16'b0000_0001_0000_0000: reg_mux_out = rd_ctl_reg;
     16'b0000_0010_0000_0000: reg_mux_out = rd_status_reg;
     16'b0000_0100_0000_0000: reg_mux_out = rd_rcdt_address_low_reg;
     16'b0000_1000_0000_0000: reg_mux_out = rd_rcdt_address_hi_reg;
     16'b0001_0000_0000_0000: reg_mux_out = rd_last_index_reg;
     16'b0010_0000_0000_0000: reg_mux_out = rd_epdt_address_low_reg;
     16'b0100_0000_0000_0000: reg_mux_out = rd_epdt_address_hi_reg;
     16'b1000_0000_0000_0000: reg_mux_out = rd_perf_reg;
     default :		      reg_mux_out = 32'h0;
   endcase
end

always_ff @(posedge Clk_i or negedge Rstn_i) begin
    if(~Rstn_i) begin
      reg_read_data_reg <= 32'h0;
    end
    else if( DCSRead_i & DCSChipSelect_i) begin
      reg_read_data_reg <= reg_mux_out;
    end
    else begin
      reg_read_data_reg <= 32'h0;
    end
end

assign DCSReadData_o = reg_read_data_reg;

/// Ready/Wait signal

assign register_access = (DCSRead_i | DCSWrite_i) & DCSChipSelect_i;

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      register_access_reg <= 1'b0;
   end
   else begin
      register_access_reg <= register_access;
   end
end

assign register_access_rise = ~register_access_reg & register_access;

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      register_ready_reg <= 1'b0;
   end
   else begin
      register_ready_reg <= register_access_rise;
   end
end

assign DCSWaitRequest_o = ~register_ready_reg;

assign wr_ctl_reg[31:0] = {16'h0, wr_loop_reg, wr_flush_reg, wr_abort_reg, wr_resume_reg, wr_pause_reg, wr_last_enable_reg, wr_msi_enable_reg, wr_dma_start_reg, wr_num_descriptor_reg[7:0]};
// Registers definition

// number of descriptor in the table stored in RP memory
// used to calculate the length of the table
always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      wr_num_descriptor_reg <= 8'h0;
   end
   else if(wr_control_wren & DCSByteEnable_i[0]) begin
      wr_num_descriptor_reg[7:0] <= DCSWriteData_i[7:0];
   end
end

/// DMA start bit

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      wr_dma_start_reg <= 1'b0;
   end
   else if(wr_control_wren & DCSByteEnable_i[1]) begin
      wr_dma_start_reg <= DCSWriteData_i[8];
   end
   else if(wr_dma_start_reg_clr) begin
      wr_dma_start_reg <= 1'b0;
   end
end

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      wr_dma_start_rr <= 1'b0;
   end
   else begin
      wr_dma_start_rr <= wr_dma_start_reg;
   end
end

//Go bit rising edge
assign wr_dma_start_rise = wr_dma_start_reg & ~wr_dma_start_rr;


// MSI and LAST enable
always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      wr_msi_enable_reg  <= 1'b0;
      wr_last_enable_reg <= 1'b0;
      wr_loop_reg	 <= 1'b0;
   end
   else if(wr_control_wren & DCSByteEnable_i[1]) begin
      wr_msi_enable_reg  <= DCSWriteData_i[9];
      wr_last_enable_reg <= DCSWriteData_i[10];
      wr_loop_reg <= DCSWriteData_i[15];
   end
end

/// pause, resume, abort, flush bits
always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      wr_pause_reg  <= 1'b0;
      wr_resume_reg <= 1'b0;
      wr_abort_reg  <= 1'b0;
      wr_flush_reg  <= 1'b0;
   end
   else if(wr_control_wren & DCSByteEnable_i[1]) begin
      wr_pause_reg  <= DCSWriteData_i[11];
      wr_resume_reg <= DCSWriteData_i[12];
      wr_abort_reg  <= DCSWriteData_i[13];
      wr_flush_reg  <= DCSWriteData_i[14];
   end
   else begin
      if(wr_pause_clear) begin
	 wr_pause_reg  <= 1'b0;
      end
      if(wr_resume_clear) begin
	 wr_resume_reg  <= 1'b0;
      end
      if(wr_abort_clear) begin
	 wr_abort_reg  <= 1'b0;
      end
      if(wr_flush_clear) begin
	 wr_flush_reg  <= 1'b0;
      end
   end
end

assign wr_pause_clear = ((dcm_state==DCMCTL_ABNORMAL_WRCPL) && (dcm_nxt_state==DCMCTL_IDLE))?1'b1:1'b0;
assign wr_resume_clear = ((dcm_state==DCMCTL_ABNORMAL_WRCPL) && (dcm_nxt_state==DCMCTL_IDLE))?1'b1:1'b0;
assign wr_abort_clear = ((dcm_state==DCMCTL_ABNORMAL_WRCPL) && (dcm_nxt_state==DCMCTL_IDLE))?1'b1:1'b0;
assign wr_flush_clear = ((dcm_state==DCMCTL_ABNORMAL_WRCPL) && (dcm_nxt_state==DCMCTL_IDLE))?1'b1:1'b0;


always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      wr_pause_rr <= 1'b0;
      wr_resume_rr <= 1'b0;
      wr_abort_rr <= 1'b0;
      wr_flush_rr <= 1'b0;
   end
   else begin
      wr_pause_rr <= wr_pause_reg;
      wr_resume_rr <= wr_resume_reg;
      wr_abort_rr <= wr_abort_reg;
      wr_flush_rr <= wr_flush_reg;
   end
end

assign wr_pause_rise = wr_pause_reg & ~wr_pause_rr;
assign wr_resume_rise = wr_resume_reg & ~wr_resume_rr;
assign wr_abort_rise = wr_abort_reg & ~wr_abort_rr;
assign wr_flush_rise = wr_flush_reg & ~wr_flush_rr;

// Write Status
//always_ff @(posedge Clk_i or negedge Rstn_i) begin
//  if(~Rstn_i) begin
//     wr_stat_reg <= 8'h0;
//  end
//  else begin
//     wr_stat_reg <= last_wr_id;
//  end
//end

assign wr_status_reg[31:0] = {24'h0, last_wr_id};

// Write Last Desc ID to be processed
always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      wr_last_index_reg <= 7'h0;
   end
   else if(wr_last_index_wrena && DCSByteEnable_i[0]) begin
      wr_last_index_reg[6:0] <= DCSWriteData_i[6:0];
   end
end

// RC Address Reg
always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      wr_rcdt_address_low_reg <= 32'h0;
   end
   else if(wr_rcdt_address_low_wrena) begin
      wr_rcdt_address_low_reg[31:0] <= DCSWriteData_i[31:0];
   end
end

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      wr_rcdt_address_hi_reg <= 32'h0;
   end
   else if(wr_rcdt_address_hi_wrena) begin
      wr_rcdt_address_hi_reg[31:0] <= DCSWriteData_i[31:0];
   end
end

assign wr_rcdt_address = {wr_rcdt_address_hi_reg, wr_rcdt_address_low_reg} + 64'h20;

// EP Address Reg

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      wr_epdt_address_low_reg <= 32'h0;
   end
   else if(wr_epdt_address_low_wrena) begin
      wr_epdt_address_low_reg[31:0] <= DCSWriteData_i[31:0];
   end
end

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      wr_epdt_address_hi_reg <= 32'h0;
   end
   else if(wr_epdt_address_hi_wrena) begin
      wr_epdt_address_hi_reg[31:0] <= DCSWriteData_i[31:0];
   end
end

/// Write Performance Register
always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      wr_perf_reg <= 32'h0;
   end
   else begin
      wr_perf_reg[31:0] <= wr_perf_cntr[31:0];
   end
end
assign wr_perf_cntr = 32'h0;              //TODO


// Write Data Mover Status Register loaded via the mover local Tx Ast port
always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      wr_mover_status_reg <= 32'h0;
   end
   else if(WrDdmaRxValid_i) begin
      wr_mover_status_reg[31:0] <= WrDdmaRxData_i[31:0];
   end
   else begin
      wr_mover_status_reg[31:0] <= 32'h0;
   end
end

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      wr_mover_status_rr <= 32'h0;
   end
   else begin
      wr_mover_status_rr <= wr_mover_status_reg;
   end
end

assign wr_mover_status_flushed = wr_mover_status_reg[12];
assign wr_mover_status_aborted = wr_mover_status_reg[11];
assign wr_mover_status_paused = wr_mover_status_reg[10];
//assign wr_mover_status_flush_re = wr_mover_status_reg[12];// & ~wr_mover_status_rr[12];
//assign wr_mover_status_abort_re = wr_mover_status_reg[11];// & ~wr_mover_status_rr[11];
//assign wr_mover_status_pause_re = wr_mover_status_reg[10];// & ~wr_mover_status_rr[10];
assign wr_mover_status_busy = wr_mover_status_reg[9];
assign wr_mover_status_done = wr_mover_status_reg[8]; // & ~wr_mover_status_rr[8]);
assign wr_mover_status_id = wr_mover_status_reg[7:0];


// DMA Read Registers

assign rd_ctl_reg[31:0] = {16'h0, rd_loop_reg, rd_flush_reg, rd_abort_reg, rd_resume_reg, rd_pause_reg, rd_last_enable_reg, rd_msi_enable_reg, rd_dma_start_reg, rd_num_descriptor_reg[7:0]};

// number of descriptor in the table stored in RP mem
// used to calculate the length of the table
always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      rd_num_descriptor_reg <= 8'h0;
   end
   else if(rd_control_wren & DCSByteEnable_i[0]) begin
      rd_num_descriptor_reg[7:0] <= DCSWriteData_i[7:0];
   end
end

/// DMA start bit

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      rd_dma_start_reg <= 1'b0;
   end
   else if(rd_control_wren & DCSByteEnable_i[1]) begin
      rd_dma_start_reg <= DCSWriteData_i[8];
   end
   else if(rd_dma_start_reg_clr) begin
      rd_dma_start_reg <= 1'b0;
   end
end

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      rd_dma_start_rr <= 1'b0;
   end
   else begin
      rd_dma_start_rr <= rd_dma_start_reg;
   end
end

//Go bit rising edge
assign rd_dma_start_rise = rd_dma_start_reg & ~rd_dma_start_rr;

// MSI and LAST enable
always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      rd_msi_enable_reg  <= 1'b0;
      rd_last_enable_reg <= 1'b0;
      rd_loop_reg	 <= 1'b0;
   end
   else if(rd_control_wren & DCSByteEnable_i[1]) begin
      rd_msi_enable_reg  <= DCSWriteData_i[9];
      rd_last_enable_reg <= DCSWriteData_i[10];
      rd_loop_reg	 <= DCSWriteData_i[15];
   end
end

/// pause, resume, abort, flush bits

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      rd_pause_reg  <= 1'b0;
      rd_resume_reg <= 1'b0;
      rd_abort_reg  <= 1'b0;
      rd_flush_reg  <= 1'b0;
   end
   else if(rd_control_wren & DCSByteEnable_i[1]) begin
      rd_pause_reg  <= DCSWriteData_i[11];
      rd_resume_reg <= DCSWriteData_i[12];
      rd_abort_reg  <= DCSWriteData_i[13];
      rd_flush_reg  <= DCSWriteData_i[14];
   end
   else begin
      if(rd_pause_clear) begin
	 rd_pause_reg  <= 1'b0;
      end
      if(rd_resume_clear) begin
	 rd_resume_reg  <= 1'b0;
      end
      if(rd_abort_clear) begin
	 rd_abort_reg  <= 1'b0;
      end
      if(rd_flush_clear) begin
	 rd_flush_reg  <= 1'b0;
      end
   end
end

assign rd_pause_clear = ((dcm_state==DCMCTL_ABNORMAL_WRCPL) && (dcm_nxt_state==DCMCTL_IDLE))?1'b1:1'b0;
assign rd_resume_clear = ((dcm_state==DCMCTL_ABNORMAL_WRCPL) && (dcm_nxt_state==DCMCTL_IDLE))?1'b1:1'b0;
assign rd_abort_clear = ((dcm_state==DCMCTL_ABNORMAL_WRCPL) && (dcm_nxt_state==DCMCTL_IDLE))?1'b1:1'b0;
assign rd_flush_clear = ((dcm_state==DCMCTL_ABNORMAL_WRCPL) && (dcm_nxt_state==DCMCTL_IDLE))?1'b1:1'b0;


always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      rd_pause_rr <= 1'b0;
      rd_resume_rr <= 1'b0;
      rd_abort_rr <= 1'b0;
      rd_flush_rr <= 1'b0;
   end
   else begin
      rd_pause_rr <= rd_pause_reg;
      rd_resume_rr <= rd_resume_reg;
      rd_abort_rr <= rd_abort_reg;
      rd_flush_rr <= rd_flush_reg;
   end
end

assign rd_pause_rise = rd_pause_reg & ~rd_pause_rr;
assign rd_resume_rise = rd_resume_reg & ~rd_resume_rr;
assign rd_abort_rise = rd_abort_reg & ~rd_abort_rr;
assign rd_flush_rise = rd_flush_reg & ~rd_flush_rr;


// Read Status
//always_ff @(posedge Clk_i or negedge Rstn_i) begin
//  if(~Rstn_i) begin
//     rd_stat_reg <= 8'h0;
//  end
//  else begin
//     rd_stat_reg <= last_rd_id;
//  end
//end

assign rd_status_reg[31:0] = {24'h0, last_rd_id};

// Read Last Desc ID to be processed
always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      rd_last_index_reg <= 7'h0;
   end
   else if(rd_last_index_wrena && DCSByteEnable_i[0]) begin
      rd_last_index_reg[6:0] <= DCSWriteData_i[6:0];
   end
end

// RC Address Reg
always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      rd_rcdt_address_low_reg <= 32'h0;
   end
   else if(rd_rcdt_address_low_wrena) begin
      rd_rcdt_address_low_reg[31:0] <= DCSWriteData_i[31:0];
   end
end

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      rd_rcdt_address_hi_reg <= 32'h0;
   end
   else if(rd_rcdt_address_hi_wrena) begin
      rd_rcdt_address_hi_reg[31:0] <= DCSWriteData_i[31:0];
   end
end

assign rd_rcdt_address = {rd_rcdt_address_hi_reg, rd_rcdt_address_low_reg} + 64'h20;

// EP Address Reg
always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      rd_epdt_address_low_reg <= 32'h0;
   end
   else if(rd_epdt_address_low_wrena) begin
      rd_epdt_address_low_reg[31:0] <= DCSWriteData_i[31:0];
   end
end

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      rd_epdt_address_hi_reg <= 32'h0;
   end
   else if(rd_epdt_address_hi_wrena) begin
      rd_epdt_address_hi_reg[31:0] <= DCSWriteData_i[31:0];
   end
end

/// Read Performance Register
always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      rd_perf_reg <= 32'h0;
   end
   else begin
      rd_perf_reg[31:0] <= rd_perf_cntr[31:0];
   end
end
assign rd_perf_cntr = 32'h0;              //TODO

/// Read Data Mover Interface

// Read Data Mover Status Register loaded via the mover local Tx Ast port
always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      rd_mover_status_reg <= 32'h0;
   end
   else if(RdDdmaRxValid_i) begin
      rd_mover_status_reg[31:0] <= RdDdmaRxData_i[31:0];
   end
   else begin
      rd_mover_status_reg[31:0] <= 32'h0;
   end
end

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      rd_mover_status_rr <= 32'h0;
   end
   else begin
      rd_mover_status_rr[31:0] <= rd_mover_status_reg[31:0];
   end
end

assign rd_mover_status_flushed = rd_mover_status_reg[12];
assign rd_mover_status_aborted = rd_mover_status_reg[11];
assign rd_mover_status_paused = rd_mover_status_reg[10];
//assign rd_mover_status_flush_re = rd_mover_status_reg[12];// & ~rd_mover_status_rr[12];
//assign rd_mover_status_abort_re = rd_mover_status_reg[11];// & ~rd_mover_status_rr[11];
//assign rd_mover_status_pause_re = rd_mover_status_reg[10];// & ~rd_mover_status_rr[10];
assign rd_mover_status_busy = rd_mover_status_reg[9];
assign rd_mover_status_done = rd_mover_status_reg[8]; //(rd_mover_status_reg[8] & ~rd_mover_status_rr[8]);
assign rd_mover_status_id = rd_mover_status_reg[7:0];

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      dt_copy_addr_incr_reg <= 7'h0;
   end
   else if (dt_copy_addr_incr) begin
      dt_copy_addr_incr_reg[6:0] <= dt_copy_addr_incr_reg[6:0] + 7'h1;
   end
   else if ((dtm_wr_state==DTMWRCTL_DONE) || (dtm_rd_state==DTMRDCTL_DONE)) begin
      dt_copy_addr_incr_reg <= 7'h0;
   end
end

assign dt_copy_addr_incr = ~DTMWaitRequest_i & DTMRead_o;

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      dt_copy_readvalid_addr_incr_reg <= 7'h0;
   end
   else if(DTMReadDataValid_i) begin
      dt_copy_readvalid_addr_incr_reg[6:0] <= dt_copy_readvalid_addr_incr_reg[6:0] + 7'h1;
   end
   else if ((dtm_rd_state==DTMRDCTL_DONE) || (dtm_wr_state==DTMWRCTL_DONE))begin
      dt_copy_readvalid_addr_incr_reg <= 7'h0;
   end
end


always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      local_rddt_mem_addr_incr_reg <= 7'h0;
   end
   else if((rd_state==RDCTL_PUSH_DESC) && (RdDdmaTxReady_i)) begin
      local_rddt_mem_addr_incr_reg[6:0] <= local_rddt_mem_addr_incr_reg[6:0] + 7'h1;
   end
   else if (local_rddt_mem_addr_incr_reg_clr) begin
      local_rddt_mem_addr_incr_reg <= 7'h0;
   end
end

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      local_wrdt_mem_addr_incr_reg <= 7'h0;
   end
   else if((wr_state==WRCTL_PUSH_DESC) && (WrDdmaTxReady_i)) begin
      local_wrdt_mem_addr_incr_reg[6:0] <= local_wrdt_mem_addr_incr_reg[6:0] + 7'h1;
   end
   else if (local_wrdt_mem_addr_incr_reg_clr) begin
      local_wrdt_mem_addr_incr_reg <= 7'h0;
   end
end


//Desc. Table in Local Memory   (word addressed)
reg [159:0] local_rd_dt_mem [0:127];
reg [159:0] local_wr_dt_mem [0:127];

always_ff @(posedge Clk_i) begin
   if((DTMReadDataValid_i==1'b1) && (dtm_rd_state==DTMRDCTL_COPY_TABLE))begin
      local_rd_dt_mem[dt_copy_readvalid_addr_incr_reg] <= DTMReadData_i[159:0];
   end
end

always_ff @(posedge Clk_i) begin
   if((DTMReadDataValid_i==1'b1) && (dtm_wr_state==DTMWRCTL_COPY_TABLE))begin
      local_wr_dt_mem[dt_copy_readvalid_addr_incr_reg] <= DTMReadData_i[159:0];
   end
end


/// Descriptor Table Fetch State Machine

always_ff @ (posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      dtf_state <= DTFCTL_IDLE;
   end
   else begin
      dtf_state <= dtf_nxt_state;
   end
end

always_comb begin
   case(dtf_state)
      DTFCTL_IDLE:
	 if(rd_dma_start_rise | wr_dma_start_rise) begin  // Go bit rise
	    dtf_nxt_state <= DTFCTL_FETCH_TABLE;
	 end
	 else begin
	    dtf_nxt_state <= DTFCTL_IDLE;
	 end
      DTFCTL_FETCH_TABLE:
	 if(RdDdmaTxReady_i) begin
	    dtf_nxt_state <= DTFCTL_TABLE_WAIT;
	 end
	 else begin
	    dtf_nxt_state <= DTFCTL_FETCH_TABLE;
	 end
      DTFCTL_TABLE_WAIT:
	 if(rd_dma_start_rise | wr_dma_start_rise) begin
	    dtf_nxt_state <= DTFCTL_FETCH_TABLE;
	 end
	 else if((rd_mover_status_id[6:0] == 7'h7F) && rd_mover_status_done) begin
	    dtf_nxt_state <= (rdwr_table_fetch_on)?DTFCTL_TABLE_WAIT:DTFCTL_DONE;
	 end
	 else begin
	    dtf_nxt_state <= DTFCTL_TABLE_WAIT;
	 end
      DTFCTL_DONE:
	 dtf_nxt_state <= DTFCTL_IDLE;
      default:
	 dtf_nxt_state <= DTFCTL_IDLE;
   endcase
end

always_ff @ (posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      RdDdmaTxValid_o <= 1'b0;
      RdDdmaTxData_o <= 160'h0;
   end
   else if (RdDdmaTxReady_i) begin
      if (dtf_state==DTFCTL_FETCH_TABLE) begin
	 RdDdmaTxData_o <= (is_current_dtf_read)? {6'h0, 1'b1, 7'h7F, 8'h0, rd_num_descriptor_reg[6:0], 3'b000, rd_epdt_address_hi_reg, rd_epdt_address_low_reg, rd_rcdt_address}:{6'h0, 1'b0, 7'h7F, 8'h0, wr_num_descriptor_reg[6:0], 3'b000, wr_epdt_address_hi_reg, wr_epdt_address_low_reg, wr_rcdt_address};
	 RdDdmaTxValid_o <= 1'b1;
      end
      else if ((rd_state==RDCTL_PUSH_DESC) && (local_rddt_mem_addr_incr_reg<=rd_last_index_reg) && (~(rd_mover_status_paused|rd_mover_status_aborted|rd_mover_status_flushed))) begin
	 RdDdmaTxData_o <= local_rd_dt_mem[local_rddt_mem_addr_incr_reg];
	 RdDdmaTxValid_o <= 1'b1;
      end
      else begin
	 RdDdmaTxValid_o <= 1'b0;
	 RdDdmaTxData_o <= RdDdmaTxData_o;
      end
   end
   else begin
      RdDdmaTxValid_o <= 1'b0;
      RdDdmaTxData_o <= RdDdmaTxData_o;
   end
end

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      rdwr_table_fetch_on <= 1'b0;
   end
   else if ((dtf_state==DTFCTL_TABLE_WAIT) && (rd_dma_start_rise|wr_dma_start_rise) ) begin
      rdwr_table_fetch_on <= 1'b1;
   end
   else if ((dtf_state==DTFCTL_TABLE_WAIT) && (rd_mover_status_id[6:0]==7'h7F) && rd_mover_status_done) begin
      rdwr_table_fetch_on <= 1'b0;
   end
end

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      is_current_dtf_read <= 1'b0;
   end
   else if ((dtf_state==DTFCTL_IDLE) && (rd_dma_start_rise | wr_dma_start_rise)) begin
      is_current_dtf_read <= (rd_dma_start_reg==1'b1)?1'b1:1'b0;
   end
   else if (dtf_state==DTFCTL_TABLE_WAIT) begin
      if (rd_dma_start_rise | wr_dma_start_rise)begin
      is_current_dtf_read <= ~is_current_dtf_read;
      end
      else if ((rd_mover_status_id[6:0]==7'h7F) && rd_mover_status_done && rdwr_table_fetch_on) begin
	 is_current_dtf_read <= ~is_current_dtf_read;
      end
   end
end

//assign is_current_dt_copy_read = ((dtf_state==DTFCTL_TABLE_WAIT) && (rd_mover_status_id[7:0] == 8'hFF) && rd_mover_status_done)? 1'b1:1'b0;
//assign is_current_dt_copy_read_reg_clr = (dtm_rd_state==DTMRDCTL_DONE) ? 1'b1:1'b0;
//
//always_ff @(posedge Clk_i or negedge Rstn_i) begin
//  if(~Rstn_i) begin
//     is_current_dt_copy_read_reg <= 1'b0;
//  end
//  else if (is_current_dt_copy_read) begin
//     is_current_dt_copy_read_reg <= 1'b1;
//  end
//  else if (is_current_dt_copy_read_reg_clr) begin
//     is_current_dt_copy_read_reg <= 1'b0;
//  end
//end

assign rddt_copy_start = ((dtf_state==DTFCTL_TABLE_WAIT) && (rd_mover_status_id[7:0] == 8'hFF) && rd_mover_status_done)? 1'b1:1'b0;
assign rddt_copy_start_reg_clr     = (dtm_rd_state==DTMRDCTL_DONE)? 1'b1:1'b0;
assign wrdt_copy_start = ((dtf_state==DTFCTL_TABLE_WAIT) && (rd_mover_status_id[7:0] == 8'h7F) && rd_mover_status_done)? 1'b1:1'b0;
assign wrdt_copy_start_reg_clr     = (dtm_wr_state==DTMWRCTL_DONE)? 1'b1:1'b0;


always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      rddt_copy_start_reg <= 1'b0;
   end
   else if (rddt_copy_start) begin
      rddt_copy_start_reg <= 1'b1;
   end
   else if (rddt_copy_start_reg_clr) begin
      rddt_copy_start_reg <= 1'b0;
   end
end

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      wrdt_copy_start_reg <= 1'b0;
   end
   else if (wrdt_copy_start) begin
      wrdt_copy_start_reg <= 1'b1;
   end
   else if (wrdt_copy_start_reg_clr) begin
      wrdt_copy_start_reg <= 1'b0;
   end
end

/// Descriptor Table Master Control State Machine (separate for Read & Write Desc. Tables)

always_ff @ (posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      dtm_wr_state <= DTMWRCTL_IDLE;
   end
   else begin
      dtm_wr_state <= dtm_wr_nxt_state;
   end
end

always_comb begin
   case(dtm_wr_state)
      DTMWRCTL_IDLE:
	 if((wrdt_copy_start_reg == 1'b1) && (dtm_rd_state==DTMRDCTL_IDLE)) begin
	    dtm_wr_nxt_state <= DTMWRCTL_COPY_TABLE;
	 end
	 else begin
	    dtm_wr_nxt_state <= DTMWRCTL_IDLE;
	 end
      DTMWRCTL_COPY_TABLE:
      if(dt_copy_readvalid_addr_incr_reg == wr_num_descriptor_reg ) begin
	 dtm_wr_nxt_state <= DTMWRCTL_DONE;
      end
      else begin
	 dtm_wr_nxt_state <= DTMWRCTL_COPY_TABLE;
      end
      DTMWRCTL_DONE:
	 dtm_wr_nxt_state <= DTMWRCTL_IDLE;
      default:
	 dtm_wr_nxt_state <= DTMWRCTL_IDLE;
   endcase
end

assign dt_start_wr_exec = (dtm_wr_state==DTMWRCTL_DONE)? 1'b1:1'b0;

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      dt_start_wr_exec_reg <= 1'b0;
   end
   else if (dt_start_wr_exec) begin
      dt_start_wr_exec_reg <= 1'b1;
   end
   else if (dt_start_wr_exec_reg_clr) begin
      dt_start_wr_exec_reg <= 1'b0;
   end
end


always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      dtm_rd_state <= DTMRDCTL_IDLE;
   end
   else begin
      dtm_rd_state <= dtm_rd_nxt_state;
   end
end

always_comb begin
   case(dtm_rd_state)
      DTMRDCTL_IDLE:
	 if((rddt_copy_start_reg==1'b1) && (dtm_wr_state==DTMWRCTL_IDLE)) begin
	    dtm_rd_nxt_state <= DTMRDCTL_COPY_TABLE;
	 end
	 else begin
	    dtm_rd_nxt_state <= DTMRDCTL_IDLE;
	 end
      DTMRDCTL_COPY_TABLE:
      if(dt_copy_readvalid_addr_incr_reg == rd_num_descriptor_reg) begin
	 dtm_rd_nxt_state <= DTMRDCTL_DONE;
      end
      else begin
	 dtm_rd_nxt_state <= DTMRDCTL_COPY_TABLE;
      end
      DTMRDCTL_DONE:
	 dtm_rd_nxt_state <= DTMRDCTL_IDLE;
      default:
	 dtm_rd_nxt_state <= DTMRDCTL_IDLE;
   endcase
end

assign dt_start_rd_exec = (dtm_rd_state==DTMRDCTL_DONE)? 1'b1:1'b0;

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      dt_start_rd_exec_reg <= 1'b0;
   end
   else if (dt_start_rd_exec) begin
      dt_start_rd_exec_reg <= 1'b1;
   end
   else if (dt_start_rd_exec_reg_clr) begin
      dt_start_rd_exec_reg <= 1'b0;
   end
end

assign dt_copy_addr_incr_reg_lookahead = (dt_copy_addr_incr)? (dt_copy_addr_incr_reg + 7'h1) : dt_copy_addr_incr_reg;

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      DTMAddress_o <= 64'h0;
      DTMRead_o <= 1'b0;
   end
   else begin
      if ((dtm_rd_state==DTMRDCTL_COPY_TABLE) && (dt_copy_addr_incr_reg_lookahead < rd_num_descriptor_reg)) begin
         DTMAddress_o <= {rd_epdt_address_hi_reg, rd_epdt_address_low_reg} + {dt_copy_addr_incr_reg_lookahead, 5'h0};
         DTMRead_o <= 1'b1;
      end
      else if ((dtm_wr_state==DTMWRCTL_COPY_TABLE) && (dt_copy_addr_incr_reg_lookahead < wr_num_descriptor_reg)) begin
         DTMAddress_o <= {wr_epdt_address_hi_reg, wr_epdt_address_low_reg} + {dt_copy_addr_incr_reg_lookahead, 5'h0};
         DTMRead_o <= 1'b1;
      end
      else begin
         DTMAddress_o <= 64'h0;
         DTMRead_o <= 1'b0;
      end
   end
end

/// DMA Write Execute State Machine

always_ff @ (posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      wr_state <= WRCTL_IDLE;
   end
   else begin
      wr_state <= wr_nxt_state;
   end
end

always_comb begin
   case(wr_state)
      WRCTL_IDLE:
	 if(dt_start_wr_exec_reg==1'b1)  begin
	    wr_nxt_state <= WRCTL_PUSH_DESC;
	 end
	 else begin
	    wr_nxt_state <= WRCTL_IDLE;
	 end
      WRCTL_PUSH_DESC:
	 if (wr_mover_status_paused | wr_mover_status_aborted | wr_mover_status_flushed) begin
	    wr_nxt_state <= (wr_mover_status_flushed)? WRCTL_FLUSHED:(wr_mover_status_aborted)? WRCTL_ABORTED:(wr_mover_status_paused)? WRCTL_PAUSED:WRCTL_PUSH_DESC;
	 end
	 else if(~WrDdmaTxReady_i) begin
	    wr_nxt_state <= WRCTL_PUSH_DESC_WAIT;
	 end
	 else if(local_wrdt_mem_addr_incr_reg <= wr_last_index_reg) begin
	    wr_nxt_state <= WRCTL_PUSH_DESC;
	 end
	 else begin
	    wr_nxt_state <= WRCTL_PUSH_DESC_WAIT;
	 end
      WRCTL_PUSH_DESC_WAIT:
	 if(wr_mover_status_done) begin
	    wr_nxt_state <= (wr_mover_status_id[6:0]==wr_last_index_reg)? WRCTL_DONE:(wrctl_push_desc_done_reg==1'b1)? WRCTL_PUSH_DESC_WAIT:WRCTL_PUSH_DESC;
	 end
	 else if (wr_mover_status_paused | wr_mover_status_aborted | wr_mover_status_flushed) begin
	    wr_nxt_state <= (wr_mover_status_flushed)? WRCTL_FLUSHED:(wr_mover_status_aborted)? WRCTL_ABORTED:(wr_mover_status_paused)? WRCTL_PAUSED:WRCTL_PUSH_DESC;
	 end
	 else begin
	    wr_nxt_state <= WRCTL_PUSH_DESC_WAIT;
	 end
      WRCTL_PAUSED:
         wr_nxt_state <= WRCTL_PAUSE_WAIT;
      WRCTL_PAUSE_WAIT:
	 wr_nxt_state <= (wr_mover_status_busy)? WRCTL_PUSH_DESC:WRCTL_PAUSE_WAIT;
      WRCTL_ABORTED:
	 wr_nxt_state <= WRCTL_PUSH_DESC;
      WRCTL_FLUSHED:
	 wr_nxt_state <=  WRCTL_IDLE;
      WRCTL_DONE:
	 wr_nxt_state <=  WRCTL_IDLE;
     default:
	wr_nxt_state <=  WRCTL_IDLE;
   endcase
end

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      WrDdmaTxValid_o <= 1'b0;
      WrDdmaTxData_o  <= 160'h0;
   end
   else if ((wr_state==WRCTL_PUSH_DESC) && (local_wrdt_mem_addr_incr_reg<=wr_last_index_reg) && (~(wr_mover_status_paused|wr_mover_status_aborted|wr_mover_status_flushed))) begin
      WrDdmaTxData_o  <= local_wr_dt_mem[local_wrdt_mem_addr_incr_reg];
      WrDdmaTxValid_o <= WrDdmaTxReady_i;
   end
   else begin
      WrDdmaTxValid_o <= 1'b0;
      WrDdmaTxData_o <= WrDdmaTxData_o;
   end
end

assign local_wrdt_mem_addr_incr_reg_clr = ((wr_state==WRCTL_FLUSHED) || (wrctl_push_desc_done_reg==1'b1))? 1'b1:1'b0;
assign local_rddt_mem_addr_incr_reg_clr = ((rd_state==RDCTL_FLUSHED) || (rdctl_push_desc_done_reg==1'b1))? 1'b1:1'b0;
assign write_wrdma_cpl_ctl = (wr_last_enable_reg==1'b1)?(((wr_state==WRCTL_PUSH_DESC_WAIT) | (wr_state==WRCTL_PUSH_DESC)) & wr_mover_status_done):(wr_nxt_state==WRCTL_DONE)?1'b1:1'b0;
assign write_wrdma_abnormal_event_cpl_ctl = ((wr_state==WRCTL_PAUSED) | (wr_state==WRCTL_ABORTED) | (wr_state==WRCTL_FLUSHED))? 1'b1:1'b0;
assign dt_start_wr_exec_reg_clr = ((wr_state==WRCTL_FLUSHED) || (wr_state==WRCTL_DONE))? 1'b1:1'b0;
assign wr_dma_start_reg_clr = ((wr_state==WRCTL_FLUSHED) || ((dcm_state==DCMCTL_WRCPL) & (wr_eplast_reg==wr_last_index_reg) & (~DCMWaitRequest_i)))? 1'b1:1'b0;

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      wrctl_push_desc_done_reg <= 1'b0;
   end
   else if ((wr_state==WRCTL_PUSH_DESC) && (local_wrdt_mem_addr_incr_reg > wr_last_index_reg)) begin
      wrctl_push_desc_done_reg <= 1'b1;
   end
   else if ((wr_state==WRCTL_FLUSHED) || (wr_state==WRCTL_DONE)) begin
      wrctl_push_desc_done_reg <= 1'b0;
   end
end

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      last_wr_id <= 8'h0;
   end
   else if ((wr_state==WRCTL_PUSH_DESC_WAIT) && (wr_mover_status_done)) begin
      last_wr_id <= wr_mover_status_id;
   end
   else if ((dcm_nxt_state==DCMCTL_IDLE) && ((dcm_state==DCMCTL_WRCPL) || (dcm_state==DCMCTL_WRMSI))) begin
      last_wr_id <= 8'h0;
   end
end


/// DMA Read Execute State Machine

always_ff @ (posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      rd_state <= RDCTL_IDLE;
   end
   else begin
      rd_state <= rd_nxt_state;
   end
end

always_comb begin
   case(rd_state)
      RDCTL_IDLE:
	 if(dt_start_rd_exec_reg==1'b1) begin
	    rd_nxt_state <= RDCTL_PUSH_DESC;
	 end
	 else begin
	    rd_nxt_state <= RDCTL_IDLE;
	 end
      RDCTL_PUSH_DESC:
	 if (rd_mover_status_paused | rd_mover_status_aborted | rd_mover_status_flushed) begin
	    rd_nxt_state <= (rd_mover_status_flushed)? RDCTL_FLUSHED:(rd_mover_status_aborted)? RDCTL_ABORTED:(rd_mover_status_paused)? RDCTL_PAUSED:RDCTL_PUSH_DESC;
	 end
	 else if((~RdDdmaTxReady_i) || (dtf_state==DTFCTL_FETCH_TABLE)) begin
	    rd_nxt_state <= RDCTL_PUSH_DESC_WAIT;
	 end
	 else if(local_rddt_mem_addr_incr_reg <= rd_last_index_reg) begin
	    rd_nxt_state <= RDCTL_PUSH_DESC;
	 end
	 else begin
	    rd_nxt_state <= RDCTL_PUSH_DESC_WAIT;
	 end
      RDCTL_PUSH_DESC_WAIT:
	 if(rd_mover_status_done) begin
	    rd_nxt_state <= (rd_mover_status_id[6:0]==rd_last_index_reg)? RDCTL_DONE:(rdctl_push_desc_done_reg==1'b1)? RDCTL_PUSH_DESC_WAIT:RDCTL_PUSH_DESC;
	 end
	 else if (rd_mover_status_paused | rd_mover_status_aborted | rd_mover_status_flushed) begin
	    rd_nxt_state <= (rd_mover_status_flushed)? RDCTL_FLUSHED:(rd_mover_status_aborted)? RDCTL_ABORTED:(rd_mover_status_paused)? RDCTL_PAUSED:RDCTL_PUSH_DESC;
	 end
	 else begin
	    rd_nxt_state <= RDCTL_PUSH_DESC_WAIT;
	 end
      RDCTL_PAUSED:
         rd_nxt_state <= RDCTL_PAUSE_WAIT;
      RDCTL_PAUSE_WAIT:
	 rd_nxt_state <= (rd_mover_status_busy)? RDCTL_PUSH_DESC:RDCTL_PAUSE_WAIT;
      RDCTL_ABORTED:
	 rd_nxt_state <= RDCTL_PUSH_DESC;
      RDCTL_FLUSHED:
	 rd_nxt_state <=  RDCTL_IDLE;
      RDCTL_DONE:
	 rd_nxt_state <= RDCTL_IDLE;
      default:
	 rd_nxt_state <= RDCTL_IDLE;
   endcase
end

assign write_rddma_cpl_ctl = (rd_last_enable_reg==1'b1)? (((rd_state==RDCTL_PUSH_DESC_WAIT) | (rd_state==RDCTL_PUSH_DESC)) & rd_mover_status_done):(rd_nxt_state==RDCTL_DONE)?1'b1:1'b0;
assign write_rddma_abnormal_event_cpl_ctl = ((rd_state==RDCTL_PAUSED) | (rd_state==WRCTL_ABORTED) | (rd_state==WRCTL_FLUSHED))? 1'b1:1'b0;
assign dt_start_rd_exec_reg_clr = ((rd_state==RDCTL_FLUSHED) || (rd_state==RDCTL_DONE))? 1'b1:1'b0;
assign rd_dma_start_reg_clr = ((rd_state==RDCTL_FLUSHED) || ((dcm_state==DCMCTL_RDCPL) & (rd_eplast_reg==rd_last_index_reg) & (~DCMWaitRequest_i)))? 1'b1:1'b0;

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      rdctl_push_desc_done_reg <= 1'b0;
   end
   else if ((rd_state==RDCTL_PUSH_DESC) && (local_rddt_mem_addr_incr_reg > rd_last_index_reg)) begin
      rdctl_push_desc_done_reg <= 1'b1;
   end
   else if ((rd_state==RDCTL_FLUSHED) || (rd_state==RDCTL_DONE)) begin
      rdctl_push_desc_done_reg <= 1'b0;
   end
end

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      last_rd_id <= 8'h0;
   end
   else if ((rd_state==RDCTL_PUSH_DESC_WAIT) && (rd_mover_status_done)) begin
      last_rd_id <= rd_mover_status_id;
   end
   else if ((dcm_nxt_state==DCMCTL_IDLE) && ((dcm_state==DCMCTL_RDCPL) || (dcm_state==DCMCTL_RDMSI))) begin
      last_rd_id <= 8'h0;
   end
end


////////DESC. CTL MASTER PORT

assign write_wrdma_cpl_ctl_pending_clr		   = (dcm_nxt_state==DCMCTL_WRCPL)? 1'b1:1'b0;
assign write_rddma_cpl_ctl_pending_clr		   = (dcm_nxt_state==DCMCTL_RDCPL)? 1'b1:1'b0;
assign write_wrdma_abnormal_event_cpl_pending_clr  = (dcm_nxt_state==DCMCTL_ABNORMAL_WRCPL)? 1'b1:1'b0;
assign write_rddma_abnormal_event_cpl_pending_clr  = (dcm_nxt_state==DCMCTL_ABNORMAL_RDCPL)? 1'b1:1'b0;
assign send_wrdma_abnormal_event_cpl		   = (dcm_nxt_state==DCMCTL_ABNORMAL_WRCPL)? 1'b1:1'b0;
assign send_rddma_abnormal_event_cpl		   = (dcm_nxt_state==DCMCTL_ABNORMAL_RDCPL)? 1'b1:1'b0;
assign send_wrdma_cpl				   = (dcm_nxt_state==DCMCTL_WRCPL)? 1'b1:1'b0;
assign send_rddma_cpl				   = (dcm_nxt_state==DCMCTL_RDCPL)? 1'b1:1'b0;
assign send_dma_cpl_msi				   = ((dcm_nxt_state==DCMCTL_RDMSI) || (dcm_nxt_state==DCMCTL_WRMSI))? 1'b1:1'b0;
assign write_wrcra				   = (dcm_nxt_state==DCMCTL_WRITE_WRCRA)? 1'b1:1'b0;
assign write_rdcra				   = (dcm_nxt_state==DCMCTL_WRITE_RDCRA)? 1'b1:1'b0;

assign write_wrdma_cpl_ctl_pending = |wrcpl_fifo_count;
assign write_rddma_cpl_ctl_pending = |rdcpl_fifo_count;

assign writecpl_fifo_rdreq = (dcm_nxt_state==DCMCTL_IDLE) & write_wrdma_cpl_ctl_pending & (~write_rddma_cpl_ctl_pending | eplast_fifo_toggle_r);
assign readcpl_fifo_rdreq  = (dcm_nxt_state==DCMCTL_IDLE) & write_rddma_cpl_ctl_pending & (~write_wrdma_cpl_ctl_pending | ~eplast_fifo_toggle_r);

altpcie_fifo #(
   .FIFO_DEPTH(64),
   .DATA_WIDTH(8)
) writecpl_fifo (
   .clk(Clk_i),
   .rstn(Rstn_i),
   .srst(wr_dma_start_rise),
   .wrreq(write_wrdma_cpl_ctl),
   .rdreq(writecpl_fifo_rdreq),
   .data(wr_mover_status_id),
   .q(wr_eplast),
   .fifo_count(wrcpl_fifo_count)
);

always_ff @ (posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      wr_eplast_reg <= 8'h0;
   end
   else if (writecpl_fifo_rdreq) begin
      wr_eplast_reg <= wr_eplast;
   end
end

altpcie_fifo #(
   .FIFO_DEPTH(64),
   .DATA_WIDTH(8)
) readcpl_fifo (
   .clk(Clk_i),
   .rstn(Rstn_i),
   .srst(rd_dma_start_rise),
   .wrreq(write_rddma_cpl_ctl),
   .rdreq(readcpl_fifo_rdreq),
   .data(rd_mover_status_id),
   .q(rd_eplast),
   .fifo_count(rdcpl_fifo_count)
);

always_ff @ (posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      rd_eplast_reg <= 8'h0;
   end
   else if (readcpl_fifo_rdreq) begin
      rd_eplast_reg <= rd_eplast;
   end
end

always_ff @ (posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      write_wrdma_cpl_ctl_pending_reg <= 1'b0;
   end
   else begin
      write_wrdma_cpl_ctl_pending_reg <= write_wrdma_cpl_ctl_pending;
   end
end

always_ff @ (posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      write_rddma_cpl_ctl_pending_reg <= 1'b0;
   end
   else begin
      write_rddma_cpl_ctl_pending_reg <= write_rddma_cpl_ctl_pending;
   end
end

always_ff @ (posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      write_wrdma_abnormal_event_cpl_pending_reg <= 1'b0;
   end
   else if (write_wrdma_abnormal_event_cpl_ctl) begin
      write_wrdma_abnormal_event_cpl_pending_reg <= 1'b1;
   end
   else if (write_wrdma_abnormal_event_cpl_pending_clr) begin
      write_wrdma_abnormal_event_cpl_pending_reg <= 1'b0;
   end
end

always_ff @ (posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      write_rddma_abnormal_event_cpl_pending_reg <= 1'b0;
   end
   else if (write_rddma_abnormal_event_cpl_ctl) begin
      write_rddma_abnormal_event_cpl_pending_reg <= 1'b1;
   end
   else if (write_rddma_abnormal_event_cpl_pending_clr) begin
      write_rddma_abnormal_event_cpl_pending_reg <= 1'b0;
   end
end

always_ff @ (posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      eplast_fifo_toggle <= 1'b0;                    //0 for RdCpl_Fifo, 1 for WrCpl_Fifo
   end
   else if (write_rddma_cpl_ctl_pending_reg & write_wrdma_cpl_ctl_pending_reg) begin
      if (writecpl_fifo_rdreq | readcpl_fifo_rdreq) begin
	 eplast_fifo_toggle <= ~eplast_fifo_toggle;
      end
   end
end

always_ff @(posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      eplast_fifo_toggle_r <= 1'b0;
   end
   else begin
      eplast_fifo_toggle_r <= eplast_fifo_toggle;
   end
end

always_ff @ (posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      dcm_state <= DCMCTL_IDLE;
   end
   else begin
      dcm_state <= dcm_nxt_state;
   end
end

always_comb begin
   case(dcm_state)
      DCMCTL_IDLE:
	 if(wr_pause_rise | wr_resume_rise | wr_abort_rise | wr_flush_rise) begin
	    dcm_nxt_state <= DCMCTL_WRITE_WRCRA;
	 end
	 else if (rd_pause_rise | rd_resume_rise | rd_abort_rise | rd_flush_rise)  begin
	    dcm_nxt_state <= DCMCTL_WRITE_RDCRA;
	 end
	 else if (write_wrdma_abnormal_event_cpl_pending_reg) begin
	    dcm_nxt_state <= DCMCTL_ABNORMAL_WRCPL;
	 end
	 else if (write_rddma_abnormal_event_cpl_pending_reg) begin
	    dcm_nxt_state <= DCMCTL_ABNORMAL_RDCPL;
	 end
         else if (write_rddma_cpl_ctl_pending_reg & write_wrdma_cpl_ctl_pending_reg) begin
            dcm_nxt_state <= (eplast_fifo_toggle_r==1'b1)?DCMCTL_WRCPL:DCMCTL_RDCPL;
         end
	 else if(write_rddma_cpl_ctl_pending_reg) begin
	    dcm_nxt_state <= DCMCTL_RDCPL;
	 end
	 else if(write_wrdma_cpl_ctl_pending_reg) begin
	    dcm_nxt_state <= DCMCTL_WRCPL;
	 end
	 else begin
	    dcm_nxt_state <= DCMCTL_IDLE;
	 end
      DCMCTL_RDCPL:
      if(DCMWaitRequest_i) begin
	 dcm_nxt_state <= DCMCTL_RDCPL;
      end
      else if(rd_msi_enable_reg & MsiIntfc_i[80] & MsiIntfc_i[81]) begin
	 dcm_nxt_state <= DCMCTL_RDMSI;
      end
      else begin
	 dcm_nxt_state <= DCMCTL_IDLE;
      end
      DCMCTL_WRCPL:
      if(DCMWaitRequest_i) begin
	 dcm_nxt_state <= DCMCTL_WRCPL;
      end
      else if(wr_msi_enable_reg & MsiIntfc_i[80] & MsiIntfc_i[81]) begin
	 dcm_nxt_state <= DCMCTL_WRMSI;
      end
      else begin
	 dcm_nxt_state <= DCMCTL_IDLE;
      end
      DCMCTL_RDMSI:
      if(DCMWaitRequest_i) begin
	 dcm_nxt_state <= DCMCTL_RDMSI;
      end
      else begin
	 dcm_nxt_state <= DCMCTL_IDLE;
      end
      DCMCTL_WRMSI:
      if(DCMWaitRequest_i) begin
	 dcm_nxt_state <= DCMCTL_WRMSI;
      end
      else begin
	 dcm_nxt_state <= DCMCTL_IDLE;
      end
      DCMCTL_WRITE_WRCRA:
      if(DCMWaitRequest_i) begin
	 dcm_nxt_state <= DCMCTL_WRITE_WRCRA;
      end
      else begin
	 dcm_nxt_state <= DCMCTL_IDLE;
      end
      DCMCTL_WRITE_RDCRA:
      if(DCMWaitRequest_i) begin
	 dcm_nxt_state <= DCMCTL_WRITE_RDCRA;
      end
      else begin
	 dcm_nxt_state <= DCMCTL_IDLE;
      end
      DCMCTL_ABNORMAL_WRCPL:
      if(DCMWaitRequest_i) begin
	 dcm_nxt_state <= DCMCTL_ABNORMAL_WRCPL;
      end
      else begin
	 dcm_nxt_state <= DCMCTL_IDLE;
      end
      DCMCTL_ABNORMAL_RDCPL:
      if(DCMWaitRequest_i) begin
	 dcm_nxt_state <= DCMCTL_ABNORMAL_RDCPL;
      end
      else begin
	 dcm_nxt_state <= DCMCTL_IDLE;
      end
      default:
	 dcm_nxt_state <= DCMCTL_IDLE;
   endcase
end

assign DCMRead_o = 1'b0;

always_ff @ (posedge Clk_i or negedge Rstn_i) begin
   if(~Rstn_i) begin
      DCMWrite_o <= 1'b0;
      DCMAddress_o <= 64'h0;
      DCMWriteData_o <= 32'h0;
      DCMByteEnable_o <= 4'h0;
   end
   else begin
      if(write_rdcra) begin
	 DCMWrite_o <= 1'b1;
	 DCMByteEnable_o <= 4'h1;
	 DCMAddress_o <= 64'h0100;
	 DCMWriteData_o <= (rd_flush_reg)? 32'h8:(rd_abort_reg)? 32'h4:(rd_resume_reg)? 32'h2:(rd_pause_reg)? 32'h1:32'h0;
      end
      else if(write_wrcra) begin
	 DCMWrite_o <= 1'b1;
	 DCMByteEnable_o <= 4'h1;
	 DCMAddress_o <= 64'h0200;
	 DCMWriteData_o <= (wr_flush_reg)? 32'h8:(wr_abort_reg)? 32'h4:(wr_resume_reg)? 32'h2:(wr_pause_reg)? 32'h1:32'h0;
      end
      else if(send_wrdma_abnormal_event_cpl) begin
	 DCMWrite_o <= 1'b1;
	 DCMByteEnable_o <= 4'h3;
	 DCMAddress_o <= {wr_rcdt_address_hi_reg, wr_rcdt_address_low_reg} + 4'h4;
	 DCMWriteData_o <= {53'h0, wr_status_reg[12:10], wr_status_reg[7:0]};
      end
      else if(send_rddma_abnormal_event_cpl) begin
	 DCMWrite_o <= 1'b1;
	 DCMByteEnable_o <= 4'h3;
	 DCMAddress_o <= {rd_rcdt_address_hi_reg, rd_rcdt_address_low_reg} + 4'h4;
	 DCMWriteData_o <= {53'h0, rd_status_reg[12:10], rd_status_reg[7:0]};
      end
      else if(send_dma_cpl_msi)begin
	 DCMWrite_o <= 1'b1;
	 DCMByteEnable_o <= 4'h3;
	 DCMAddress_o <= MsiIntfc_i[63:0];
	 DCMWriteData_o <= {16'h0, MsiIntfc_i[79:64]};
      end
      else if(send_rddma_cpl || send_wrdma_cpl) begin
	 DCMWrite_o <= 1'b1;
	 DCMByteEnable_o <= 4'h1;
	 DCMAddress_o <= (send_rddma_cpl)? {rd_rcdt_address_hi_reg, rd_rcdt_address_low_reg}:(send_wrdma_cpl)? {wr_rcdt_address_hi_reg, wr_rcdt_address_low_reg}:64'h0;  ;
	 DCMWriteData_o <= (send_rddma_cpl)? rd_eplast_reg:(send_wrdma_cpl)? wr_eplast_reg:32'h0;
      end
      else begin
	 DCMWrite_o <= 1'b0;
	 DCMAddress_o <= DCMAddress_o;
	 DCMWriteData_o <= DCMWriteData_o;
	 DCMByteEnable_o <= 4'h0;
      end
   end
end

endmodule
