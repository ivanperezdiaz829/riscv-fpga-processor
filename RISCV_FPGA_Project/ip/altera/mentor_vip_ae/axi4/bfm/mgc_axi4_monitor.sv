// *****************************************************************************
//
// Copyright 2007-2012 Mentor Graphics Corporation
// All Rights Reserved.
//
// THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF
// MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
//
// *****************************************************************************
// dvc           Version: 20120809_Questa_10.1b
// *****************************************************************************
//
// Title: axi4_monitor_module
//

// import package for the axi4 interface
import mgc_axi4_pkg::*;

interface mgc_axi4_monitor #(int AXI4_ADDRESS_WIDTH = 64, int AXI4_RDATA_WIDTH = 1024, int AXI4_WDATA_WIDTH = 1024, int AXI4_ID_WIDTH = 18, int AXI4_USER_WIDTH = 8, int AXI4_REGION_MAP_SIZE = 16, int index = 0)
(
    input ACLK,
    input ARESETn,
    input AWVALID,
    input [((AXI4_ADDRESS_WIDTH) - 1):0]  AWADDR,
    input [2:0] AWPROT,
    input [3:0] AWREGION,
    input [7:0] AWLEN,
    input [2:0] AWSIZE,
    input [1:0] AWBURST,
    input AWLOCK,
    input [3:0] AWCACHE,
    input [3:0] AWQOS,
    input [((AXI4_ID_WIDTH) - 1):0]  AWID,
    input [((AXI4_USER_WIDTH) - 1):0]  AWUSER,
    input AWREADY,
    input ARVALID,
    input [((AXI4_ADDRESS_WIDTH) - 1):0]  ARADDR,
    input [2:0] ARPROT,
    input [3:0] ARREGION,
    input [7:0] ARLEN,
    input [2:0] ARSIZE,
    input [1:0] ARBURST,
    input ARLOCK,
    input [3:0] ARCACHE,
    input [3:0] ARQOS,
    input [((AXI4_ID_WIDTH) - 1):0]  ARID,
    input [((AXI4_USER_WIDTH) - 1):0]  ARUSER,
    input ARREADY,
    input RVALID,
    input [((AXI4_RDATA_WIDTH) - 1):0]  RDATA,
    input [1:0] RRESP,
    input RLAST,
    input [((AXI4_ID_WIDTH) - 1):0]  RID,
    input RREADY,
    input WVALID,
    input [((AXI4_WDATA_WIDTH) - 1):0]  WDATA,
    input [(((AXI4_WDATA_WIDTH / 8)) - 1):0]  WSTRB,
    input WLAST,
    input WREADY,
    input BVALID,
    input [1:0] BRESP,
    input [((AXI4_ID_WIDTH) - 1):0]  BID,
    input BREADY
`ifdef _MGC_VIP_VHDL_INTERFACE
    // VHDL application interface.
    // Parallel path 0
  , input  bit [AXI4_VHD_WAIT_ON:0] req_p0,
    input  int transaction_id_in_p0,
    input  int value_in0_p0,
    input  int value_in1_p0,
    input  int value_in2_p0,
    input  int value_in3_p0,
    input  axi4_max_bits_t value_in_max_p0,
    output bit [AXI4_VHD_WAIT_ON:0] ack_p0,
    output int transaction_id_out_p0,
    output int value_out0_p0,
    output int value_out1_p0,
    output axi4_max_bits_t value_out_max_p0,

    // Parallel path 1
    input  bit [AXI4_VHD_WAIT_ON:0] req_p1,
    input  int transaction_id_in_p1,
    input  int value_in0_p1,
    input  int value_in1_p1,
    input  int value_in2_p1,
    input  int value_in3_p1,
    input  axi4_max_bits_t value_in_max_p1,
    output bit [AXI4_VHD_WAIT_ON:0] ack_p1,
    output int transaction_id_out_p1,
    output int value_out0_p1,
    output int value_out1_p1,
    output axi4_max_bits_t value_out_max_p1,

    // Parallel path 2
    input  bit [AXI4_VHD_WAIT_ON:0] req_p2,
    input  int transaction_id_in_p2,
    input  int value_in0_p2,
    input  int value_in1_p2,
    input  int value_in2_p2,
    input  int value_in3_p2,
    input  axi4_max_bits_t value_in_max_p2,
    output bit [AXI4_VHD_WAIT_ON:0] ack_p2,
    output int transaction_id_out_p2,
    output int value_out0_p2,
    output int value_out1_p2,
    output axi4_max_bits_t value_out_max_p2,

    // Parallel path 3
    input  bit [AXI4_VHD_WAIT_ON:0] req_p3,
    input  int transaction_id_in_p3,
    input  int value_in0_p3,
    input  int value_in1_p3,
    input  int value_in2_p3,
    input  int value_in3_p3,
    input  axi4_max_bits_t value_in_max_p3,
    output bit [AXI4_VHD_WAIT_ON:0] ack_p3,
    output int transaction_id_out_p3,
    output int value_out0_p3,
    output int value_out1_p3,
    output axi4_max_bits_t value_out_max_p3,

    // Parallel path 4
    input  bit [AXI4_VHD_WAIT_ON:0] req_p4,
    input  int transaction_id_in_p4,
    input  int value_in0_p4,
    input  int value_in1_p4,
    input  int value_in2_p4,
    input  int value_in3_p4,
    input  axi4_max_bits_t value_in_max_p4,
    output bit [AXI4_VHD_WAIT_ON:0] ack_p4,
    output int transaction_id_out_p4,
    output int value_out0_p4,
    output int value_out1_p4,
    output axi4_max_bits_t value_out_max_p4,

    // Parallel path 5
    input  bit [AXI4_VHD_WAIT_ON:0] req_p5,
    input  int transaction_id_in_p5,
    input  int value_in0_p5,
    input  int value_in1_p5,
    input  int value_in2_p5,
    input  int value_in3_p5,
    input  axi4_max_bits_t value_in_max_p5,
    output bit [AXI4_VHD_WAIT_ON:0] ack_p5,
    output int transaction_id_out_p5,
    output int value_out0_p5,
    output int value_out1_p5,
    output axi4_max_bits_t value_out_max_p5,

    // Parallel path 6
    input  bit [AXI4_VHD_WAIT_ON:0] req_p6,
    input  int transaction_id_in_p6,
    input  int value_in0_p6,
    input  int value_in1_p6,
    input  int value_in2_p6,
    input  int value_in3_p6,
    input  axi4_max_bits_t value_in_max_p6,
    output bit [AXI4_VHD_WAIT_ON:0] ack_p6,
    output int transaction_id_out_p6,
    output int value_out0_p6,
    output int value_out1_p6,
    output axi4_max_bits_t value_out_max_p6,

    // Parallel path 7
    input  bit [AXI4_VHD_WAIT_ON:0] req_p7,
    input  int transaction_id_in_p7,
    input  int value_in0_p7,
    input  int value_in1_p7,
    input  int value_in2_p7,
    input  int value_in3_p7,
    input  axi4_max_bits_t value_in_max_p7,
    output bit [AXI4_VHD_WAIT_ON:0] ack_p7,
    output int transaction_id_out_p7,
    output int value_out0_p7,
    output int value_out1_p7,
    output axi4_max_bits_t value_out_max_p7
`endif
);

`ifdef MODEL_TECH
  `ifdef _MGC_VIP_VHDL_INTERFACE
    `include "mgc_axi4_monitor.mti.svp"
  `endif
`endif

`ifdef MODEL_TECH
  `define call_for_axi4_bfm(XXX) axi4.XXX
`else
  `define call_for_axi4_bfm(XXX) axi4.do_``XXX
`endif

    // Interface instance
    mgc_common_axi4 #(AXI4_ADDRESS_WIDTH, AXI4_RDATA_WIDTH, AXI4_WDATA_WIDTH, AXI4_ID_WIDTH, AXI4_USER_WIDTH, AXI4_REGION_MAP_SIZE) axi4 ( ACLK, ARESETn );
    assign axi4.AWVALID = AWVALID;
    assign axi4.AWADDR = AWADDR;
    assign axi4.AWPROT = AWPROT;
    assign axi4.AWREGION = AWREGION;
    assign axi4.AWLEN = AWLEN;
    assign axi4.AWSIZE = AWSIZE;
    assign axi4.AWBURST = AWBURST;
    assign axi4.AWLOCK = AWLOCK;
    assign axi4.AWCACHE = AWCACHE;
    assign axi4.AWQOS = AWQOS;
    assign axi4.AWID = AWID;
    assign axi4.AWUSER = AWUSER;
    assign axi4.AWREADY = AWREADY;
    assign axi4.ARVALID = ARVALID;
    assign axi4.ARADDR = ARADDR;
    assign axi4.ARPROT = ARPROT;
    assign axi4.ARREGION = ARREGION;
    assign axi4.ARLEN = ARLEN;
    assign axi4.ARSIZE = ARSIZE;
    assign axi4.ARBURST = ARBURST;
    assign axi4.ARLOCK = ARLOCK;
    assign axi4.ARCACHE = ARCACHE;
    assign axi4.ARQOS = ARQOS;
    assign axi4.ARID = ARID;
    assign axi4.ARUSER = ARUSER;
    assign axi4.ARREADY = ARREADY;
    assign axi4.RVALID = RVALID;
    assign axi4.RDATA = RDATA;
    assign axi4.RRESP = RRESP;
    assign axi4.RLAST = RLAST;
    assign axi4.RID = RID;
    assign axi4.RREADY = RREADY;
    assign axi4.WVALID = WVALID;
    assign axi4.WDATA = WDATA;
    assign axi4.WSTRB = WSTRB;
    assign axi4.WLAST = WLAST;
    assign axi4.WREADY = WREADY;
    assign axi4.BVALID = BVALID;
    assign axi4.BRESP = BRESP;
    assign axi4.BID = BID;
    assign axi4.BREADY = BREADY;

`ifdef _MGC_VIP_VHDL_INTERFACE
    // Port-signal assignment
    bit [AXI4_VHD_WAIT_ON:0] req_p[8];
    int transaction_id_in_p[8];
    int value_in0_p[8];
    int value_in1_p[8];
    int value_in2_p[8];
    int value_in3_p[8];
    axi4_max_bits_t value_in_max_p[8];
    bit [AXI4_VHD_WAIT_ON:0] ack_p[8];
    int transaction_id_out_p[8];
    int value_out0_p[8];
    int value_out1_p[8];
    axi4_max_bits_t value_out_max_p[8];

    // Parallel path 0
    assign req_p[0]               = req_p0;
    assign transaction_id_in_p[0] = transaction_id_in_p0;
    assign value_in0_p[0]         = value_in0_p0;
    assign value_in1_p[0]         = value_in1_p0;
    assign value_in2_p[0]         = value_in2_p0;
    assign value_in3_p[0]         = value_in3_p0;
    assign value_in_max_p[0]      = value_in_max_p0;
    assign ack_p0                 = ack_p[0];
    assign transaction_id_out_p0  = transaction_id_out_p[0];
    assign value_out0_p0          = value_out0_p[0];
    assign value_out1_p0          = value_out1_p[0];
    assign value_out_max_p0       = value_out_max_p[0];

    // Parallel path 1
    assign req_p[1]               = req_p1;
    assign transaction_id_in_p[1] = transaction_id_in_p1;
    assign value_in0_p[1]         = value_in0_p1;
    assign value_in1_p[1]         = value_in1_p1;
    assign value_in2_p[1]         = value_in2_p1;
    assign value_in3_p[1]         = value_in3_p1;
    assign value_in_max_p[1]      = value_in_max_p1;
    assign ack_p1                 = ack_p[1];
    assign transaction_id_out_p1  = transaction_id_out_p[1];
    assign value_out0_p1          = value_out0_p[1];
    assign value_out1_p1          = value_out1_p[1];
    assign value_out_max_p1       = value_out_max_p[1];

    // Parallel path 2
    assign req_p[2]               = req_p2;
    assign transaction_id_in_p[2] = transaction_id_in_p2;
    assign value_in0_p[2]         = value_in0_p2;
    assign value_in1_p[2]         = value_in1_p2;
    assign value_in2_p[2]         = value_in2_p2;
    assign value_in3_p[2]         = value_in3_p2;
    assign value_in_max_p[2]      = value_in_max_p2;
    assign ack_p2                 = ack_p[2];
    assign transaction_id_out_p2  = transaction_id_out_p[2];
    assign value_out0_p2          = value_out0_p[2];
    assign value_out1_p2          = value_out1_p[2];
    assign value_out_max_p2       = value_out_max_p[2];

    // Parallel path 3
    assign req_p[3]               = req_p3;
    assign transaction_id_in_p[3] = transaction_id_in_p3;
    assign value_in0_p[3]         = value_in0_p3;
    assign value_in1_p[3]         = value_in1_p3;
    assign value_in2_p[3]         = value_in2_p3;
    assign value_in3_p[3]         = value_in3_p3;
    assign value_in_max_p[3]      = value_in_max_p3;
    assign ack_p3                 = ack_p[3];
    assign transaction_id_out_p3  = transaction_id_out_p[3];
    assign value_out0_p3          = value_out0_p[3];
    assign value_out1_p3          = value_out1_p[3];
    assign value_out_max_p3       = value_out_max_p[3];

    // Parallel path 4
    assign req_p[4]               = req_p4;
    assign transaction_id_in_p[4] = transaction_id_in_p4;
    assign value_in0_p[4]         = value_in0_p4;
    assign value_in1_p[4]         = value_in1_p4;
    assign value_in2_p[4]         = value_in2_p4;
    assign value_in3_p[4]         = value_in3_p4;
    assign value_in_max_p[4]      = value_in_max_p4;
    assign ack_p4                 = ack_p[4];
    assign transaction_id_out_p4  = transaction_id_out_p[4];
    assign value_out0_p4          = value_out0_p[4];
    assign value_out1_p4          = value_out1_p[4];
    assign value_out_max_p4       = value_out_max_p[4];

    // Parallel path 5
    assign req_p[5]               = req_p5;
    assign transaction_id_in_p[5] = transaction_id_in_p5;
    assign value_in0_p[5]         = value_in0_p5;
    assign value_in1_p[5]         = value_in1_p5;
    assign value_in2_p[5]         = value_in2_p5;
    assign value_in3_p[5]         = value_in3_p5;
    assign value_in_max_p[5]      = value_in_max_p5;
    assign ack_p5                 = ack_p[5];
    assign transaction_id_out_p5  = transaction_id_out_p[5];
    assign value_out0_p5          = value_out0_p[5];
    assign value_out1_p5          = value_out1_p[5];
    assign value_out_max_p5       = value_out_max_p[5];

    // Parallel path 6
    assign req_p[6]               = req_p6;
    assign transaction_id_in_p[6] = transaction_id_in_p6;
    assign value_in0_p[6]         = value_in0_p6;
    assign value_in1_p[6]         = value_in1_p6;
    assign value_in2_p[6]         = value_in2_p6;
    assign value_in3_p[6]         = value_in3_p6;
    assign value_in_max_p[6]      = value_in_max_p6;
    assign ack_p6                 = ack_p[6];
    assign transaction_id_out_p6  = transaction_id_out_p[6];
    assign value_out0_p6          = value_out0_p[6];
    assign value_out1_p6          = value_out1_p[6];
    assign value_out_max_p6       = value_out_max_p[6];

    // Parallel path 7
    assign req_p[7]               = req_p7;
    assign transaction_id_in_p[7] = transaction_id_in_p7;
    assign value_in0_p[7]         = value_in0_p7;
    assign value_in1_p[7]         = value_in1_p7;
    assign value_in2_p[7]         = value_in2_p7;
    assign value_in3_p[7]         = value_in3_p7;
    assign value_in_max_p[7]      = value_in_max_p7;
    assign ack_p7                 = ack_p[7];
    assign transaction_id_out_p7  = transaction_id_out_p[7];
    assign value_out0_p7          = value_out0_p[7];
    assign value_out1_p7          = value_out1_p[7];
    assign value_out_max_p7       = value_out_max_p[7];

    // Transaction ID and array 
    bit unsigned [7:0] circular_id;
    axi4_transaction transaction_array[256];
    bit unsigned [7:0]  axi4_transaction_id_queue[8][$];

    // Dynamic array for helper methods
    bit [((AXI4_ADDRESS_WIDTH) - 1):0]   helper_wr_addr_p[8][];
    bit [7:0] helper_wr_data_p[8][]; 
    bit [((AXI4_ADDRESS_WIDTH) - 1):0]   helper_read_addr_p[8][]; 
    bit [((AXI4_ADDRESS_WIDTH) - 1):0]   helper_set_read_addr_p[8][];
    bit [7:0] helper_set_read_data_p[8][];

   // API call starts here
   generate
    genvar gg;
    for(gg = 0; gg < 8; ++gg)
    begin

    //------------------------------------------------------------------------------
    //
    // destruct_transaction hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_DESTRUCT_TRANSACTION]);
        ack_p[gg][AXI4_VHD_DESTRUCT_TRANSACTION] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          if(transaction_array[transaction_id_in_p[gg]].transaction_done == 1)
          begin
            $display("%0t: %m (%d): Warning: Destructing a transaction with ID = %d which is not finished yet", $time, index, transaction_id_in_p[gg]);
          end
          transaction_array[transaction_id_in_p[gg]] = null;
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_DESTRUCT_TRANSACTION", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_DESTRUCT_TRANSACTION] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // push_transaction_id hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_PUSH_TRANSACTION_ID]);
        ack_p[gg][AXI4_VHD_PUSH_TRANSACTION_ID] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          axi4_transaction_id_queue[value_in0_p[gg]].push_back(transaction_id_in_p[gg]); 
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_PUSH_TRANSACTION_ID", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_PUSH_TRANSACTION_ID] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // pop_transaction_id hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_POP_TRANSACTION_ID]);
        ack_p[gg][AXI4_VHD_POP_TRANSACTION_ID] = 1;
        wait(axi4_transaction_id_queue[value_in0_p[gg]].size > 0);
        transaction_id_out_p[gg]  = axi4_transaction_id_queue[value_in0_p[gg]].pop_front(); 
        ack_p[gg][AXI4_VHD_POP_TRANSACTION_ID] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // print hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_PRINT]);
        ack_p[gg][AXI4_VHD_PRINT] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          transaction_array[transaction_id_in_p[gg]].print(value_in0_p[gg]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_PRINT", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_PRINT] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_write_addr_data hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_WRITE_ADDR_DATA]);
        ack_p[gg][AXI4_VHD_GET_WRITE_ADDR_DATA] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          if(value_in1_p[gg] == 0)
          begin
            helper_wr_addr_p[gg].delete();
            helper_wr_data_p[gg].delete();
            void'(get_write_addr_data(transaction_array[transaction_id_in_p[gg]], value_in0_p[gg], helper_wr_addr_p[gg], helper_wr_data_p[gg]));
          end
          value_out0_p[gg] = helper_wr_addr_p[gg].size();
          value_out_max_p[gg] = helper_wr_addr_p[gg][value_in1_p[gg]];
          value_out1_p[gg] = helper_wr_data_p[gg][value_in1_p[gg]];
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_WRITE_ADDR_DATA", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_WRITE_ADDR_DATA] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_read_addr hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_READ_ADDR]);
        ack_p[gg][AXI4_VHD_GET_READ_ADDR] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          if(value_in1_p[gg] == 0)
          begin
            helper_read_addr_p[gg].delete();
            void'(get_read_addr(transaction_array[transaction_id_in_p[gg]], value_in0_p[gg], helper_read_addr_p[gg]));
          end
          value_out0_p[gg] = helper_read_addr_p[gg].size();
          value_out_max_p[gg] = helper_read_addr_p[gg][value_in1_p[gg]];
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_READ_ADDR", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_READ_ADDR] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // set_read_data hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_SET_READ_DATA]);
        ack_p[gg][AXI4_VHD_SET_READ_DATA] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          if(value_in1_p[gg] == 0)
          begin
            helper_set_read_addr_p[gg] = new[value_in2_p[gg]];
            helper_set_read_data_p[gg] = new[value_in2_p[gg]];
          end
          helper_set_read_addr_p[gg][value_in1_p[gg]] = value_in_max_p[gg];
          helper_set_read_data_p[gg][value_in1_p[gg]] = value_in3_p[gg];
          if(value_in2_p[gg] == (value_in1_p[gg] + 1))
          begin
            set_read_data(transaction_array[transaction_id_in_p[gg]], value_in0_p[gg], helper_set_read_addr_p[gg], helper_set_read_data_p[gg]);
          end
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_SET_READ_DATA", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_SET_READ_DATA] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // set_read_or_write hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_SET_READ_OR_WRITE]);
        ack_p[gg][AXI4_VHD_SET_READ_OR_WRITE] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          transaction_array[transaction_id_in_p[gg]].set_read_or_write(axi4_rw_e'(value_in0_p[gg]));
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_SET_READ_OR_WRITE", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_SET_READ_OR_WRITE] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_read_or_write hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_READ_OR_WRITE]);
        ack_p[gg][AXI4_VHD_GET_READ_OR_WRITE] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          value_out0_p[gg] = transaction_array[transaction_id_in_p[gg]].get_read_or_write();
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_READ_OR_WRITE", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_READ_OR_WRITE] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // set_addr hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_SET_ADDR]);
        ack_p[gg][AXI4_VHD_SET_ADDR] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          transaction_array[transaction_id_in_p[gg]].set_addr(value_in_max_p[gg]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_SET_ADDR", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_SET_ADDR] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_addr hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_ADDR]);
        ack_p[gg][AXI4_VHD_GET_ADDR] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          value_out_max_p[gg] = transaction_array[transaction_id_in_p[gg]].get_addr();
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_ADDR", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_ADDR] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // set_prot hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_SET_PROT]);
        ack_p[gg][AXI4_VHD_SET_PROT] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          transaction_array[transaction_id_in_p[gg]].set_prot(axi4_prot_e'(value_in0_p[gg]));
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_SET_PROT", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_SET_PROT] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_prot hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_PROT]);
        ack_p[gg][AXI4_VHD_GET_PROT] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          value_out0_p[gg] = transaction_array[transaction_id_in_p[gg]].get_prot();
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_PROT", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_PROT] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // set_region hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_SET_REGION]);
        ack_p[gg][AXI4_VHD_SET_REGION] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          transaction_array[transaction_id_in_p[gg]].set_region(value_in_max_p[gg]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_SET_REGION", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_SET_REGION] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_region hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_REGION]);
        ack_p[gg][AXI4_VHD_GET_REGION] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          value_out_max_p[gg] = transaction_array[transaction_id_in_p[gg]].get_region();
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_REGION", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_REGION] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // set_size hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_SET_SIZE]);
        ack_p[gg][AXI4_VHD_SET_SIZE] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          transaction_array[transaction_id_in_p[gg]].set_size(axi4_size_e'(value_in0_p[gg]));
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_SET_SIZE", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_SET_SIZE] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_size hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_SIZE]);
        ack_p[gg][AXI4_VHD_GET_SIZE] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          value_out0_p[gg] = transaction_array[transaction_id_in_p[gg]].get_size();
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_SIZE", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_SIZE] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // set_burst hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_SET_BURST]);
        ack_p[gg][AXI4_VHD_SET_BURST] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          transaction_array[transaction_id_in_p[gg]].set_burst(axi4_burst_e'(value_in0_p[gg]));
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_SET_BURST", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_SET_BURST] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_burst hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_BURST]);
        ack_p[gg][AXI4_VHD_GET_BURST] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          value_out0_p[gg] = transaction_array[transaction_id_in_p[gg]].get_burst();
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_BURST", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_BURST] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // set_lock hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_SET_LOCK]);
        ack_p[gg][AXI4_VHD_SET_LOCK] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          transaction_array[transaction_id_in_p[gg]].set_lock(axi4_lock_e'(value_in0_p[gg]));
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_SET_LOCK", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_SET_LOCK] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_lock hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_LOCK]);
        ack_p[gg][AXI4_VHD_GET_LOCK] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          value_out0_p[gg] = transaction_array[transaction_id_in_p[gg]].get_lock();
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_LOCK", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_LOCK] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // set_cache hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_SET_CACHE]);
        ack_p[gg][AXI4_VHD_SET_CACHE] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          transaction_array[transaction_id_in_p[gg]].set_cache(axi4_cache_e'(value_in0_p[gg]));
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_SET_CACHE", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_SET_CACHE] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_cache hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_CACHE]);
        ack_p[gg][AXI4_VHD_GET_CACHE] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          value_out0_p[gg] = transaction_array[transaction_id_in_p[gg]].get_cache();
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_CACHE", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_CACHE] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // set_qos hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_SET_QOS]);
        ack_p[gg][AXI4_VHD_SET_QOS] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          transaction_array[transaction_id_in_p[gg]].set_qos(value_in_max_p[gg]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_SET_QOS", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_SET_QOS] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_qos hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_QOS]);
        ack_p[gg][AXI4_VHD_GET_QOS] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          value_out_max_p[gg] = transaction_array[transaction_id_in_p[gg]].get_qos();
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_QOS", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_QOS] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // set_id hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_SET_ID]);
        ack_p[gg][AXI4_VHD_SET_ID] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          transaction_array[transaction_id_in_p[gg]].set_id(value_in_max_p[gg]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_SET_ID", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_SET_ID] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_id hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_ID]);
        ack_p[gg][AXI4_VHD_GET_ID] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          value_out_max_p[gg] = transaction_array[transaction_id_in_p[gg]].get_id();
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_ID", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_ID] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // set_burst_length hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_SET_BURST_LENGTH]);
        ack_p[gg][AXI4_VHD_SET_BURST_LENGTH] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          transaction_array[transaction_id_in_p[gg]].set_burst_length(value_in_max_p[gg]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_SET_BURST_LENGTH", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_SET_BURST_LENGTH] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_burst_length hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_BURST_LENGTH]);
        ack_p[gg][AXI4_VHD_GET_BURST_LENGTH] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          value_out_max_p[gg] = transaction_array[transaction_id_in_p[gg]].get_burst_length();
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_BURST_LENGTH", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_BURST_LENGTH] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // set_addr_user hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_SET_ADDR_USER]);
        ack_p[gg][AXI4_VHD_SET_ADDR_USER] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          transaction_array[transaction_id_in_p[gg]].set_addr_user(value_in_max_p[gg]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_SET_ADDR_USER", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_SET_ADDR_USER] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_addr_user hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_ADDR_USER]);
        ack_p[gg][AXI4_VHD_GET_ADDR_USER] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          value_out_max_p[gg] = transaction_array[transaction_id_in_p[gg]].get_addr_user();
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_ADDR_USER", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_ADDR_USER] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // set_data_words hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_SET_DATA_WORDS]);
        ack_p[gg][AXI4_VHD_SET_DATA_WORDS] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          transaction_array[transaction_id_in_p[gg]].set_data_words(value_in_max_p[gg], value_in0_p[gg]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_SET_DATA_WORDS", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_SET_DATA_WORDS] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_data_words hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_DATA_WORDS]);
        ack_p[gg][AXI4_VHD_GET_DATA_WORDS] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          value_out_max_p[gg] = transaction_array[transaction_id_in_p[gg]].get_data_words(value_in0_p[gg]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_DATA_WORDS", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_DATA_WORDS] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // set_write_strobes hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_SET_WRITE_STROBES]);
        ack_p[gg][AXI4_VHD_SET_WRITE_STROBES] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          transaction_array[transaction_id_in_p[gg]].set_write_strobes(value_in_max_p[gg], value_in0_p[gg]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_SET_WRITE_STROBES", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_SET_WRITE_STROBES] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_write_strobes hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_WRITE_STROBES]);
        ack_p[gg][AXI4_VHD_GET_WRITE_STROBES] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          value_out_max_p[gg] = transaction_array[transaction_id_in_p[gg]].get_write_strobes(value_in0_p[gg]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_WRITE_STROBES", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_WRITE_STROBES] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // set_resp hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_SET_RESP]);
        ack_p[gg][AXI4_VHD_SET_RESP] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          transaction_array[transaction_id_in_p[gg]].set_resp(axi4_response_e'(value_in0_p[gg]), value_in1_p[gg]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_SET_RESP", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_SET_RESP] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_resp hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_RESP]);
        ack_p[gg][AXI4_VHD_GET_RESP] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          value_out0_p[gg] = transaction_array[transaction_id_in_p[gg]].get_resp(value_in0_p[gg]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_RESP", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_RESP] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // set_address_valid_delay hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_SET_ADDRESS_VALID_DELAY]);
        ack_p[gg][AXI4_VHD_SET_ADDRESS_VALID_DELAY] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          transaction_array[transaction_id_in_p[gg]].set_address_valid_delay(value_in0_p[gg]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_SET_ADDRESS_VALID_DELAY", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_SET_ADDRESS_VALID_DELAY] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_address_valid_delay hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_ADDRESS_VALID_DELAY]);
        ack_p[gg][AXI4_VHD_GET_ADDRESS_VALID_DELAY] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          value_out0_p[gg] = transaction_array[transaction_id_in_p[gg]].get_address_valid_delay();
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_ADDRESS_VALID_DELAY", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_ADDRESS_VALID_DELAY] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // set_data_valid_delay hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_SET_DATA_VALID_DELAY]);
        ack_p[gg][AXI4_VHD_SET_DATA_VALID_DELAY] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          transaction_array[transaction_id_in_p[gg]].set_data_valid_delay(value_in0_p[gg], value_in1_p[gg]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_SET_DATA_VALID_DELAY", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_SET_DATA_VALID_DELAY] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_data_valid_delay hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_DATA_VALID_DELAY]);
        ack_p[gg][AXI4_VHD_GET_DATA_VALID_DELAY] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          value_out0_p[gg] = transaction_array[transaction_id_in_p[gg]].get_data_valid_delay(value_in0_p[gg]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_DATA_VALID_DELAY", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_DATA_VALID_DELAY] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // set_write_response_valid_delay hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_SET_WRITE_RESPONSE_VALID_DELAY]);
        ack_p[gg][AXI4_VHD_SET_WRITE_RESPONSE_VALID_DELAY] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          transaction_array[transaction_id_in_p[gg]].set_write_response_valid_delay(value_in0_p[gg]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_SET_WRITE_RESPONSE_VALID_DELAY", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_SET_WRITE_RESPONSE_VALID_DELAY] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_write_response_valid_delay hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_WRITE_RESPONSE_VALID_DELAY]);
        ack_p[gg][AXI4_VHD_GET_WRITE_RESPONSE_VALID_DELAY] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          value_out0_p[gg] = transaction_array[transaction_id_in_p[gg]].get_write_response_valid_delay();
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_WRITE_RESPONSE_VALID_DELAY", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_WRITE_RESPONSE_VALID_DELAY] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // set_address_ready_delay hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_SET_ADDRESS_READY_DELAY]);
        ack_p[gg][AXI4_VHD_SET_ADDRESS_READY_DELAY] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          transaction_array[transaction_id_in_p[gg]].set_address_ready_delay(value_in0_p[gg]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_SET_ADDRESS_READY_DELAY", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_SET_ADDRESS_READY_DELAY] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_address_ready_delay hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_ADDRESS_READY_DELAY]);
        ack_p[gg][AXI4_VHD_GET_ADDRESS_READY_DELAY] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          value_out0_p[gg] = transaction_array[transaction_id_in_p[gg]].get_address_ready_delay();
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_ADDRESS_READY_DELAY", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_ADDRESS_READY_DELAY] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // set_data_ready_delay hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_SET_DATA_READY_DELAY]);
        ack_p[gg][AXI4_VHD_SET_DATA_READY_DELAY] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          transaction_array[transaction_id_in_p[gg]].set_data_ready_delay(value_in0_p[gg], value_in1_p[gg]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_SET_DATA_READY_DELAY", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_SET_DATA_READY_DELAY] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_data_ready_delay hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_DATA_READY_DELAY]);
        ack_p[gg][AXI4_VHD_GET_DATA_READY_DELAY] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          value_out0_p[gg] = transaction_array[transaction_id_in_p[gg]].get_data_ready_delay(value_in0_p[gg]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_DATA_READY_DELAY", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_DATA_READY_DELAY] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // set_write_response_ready_delay hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_SET_WRITE_RESPONSE_READY_DELAY]);
        ack_p[gg][AXI4_VHD_SET_WRITE_RESPONSE_READY_DELAY] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          transaction_array[transaction_id_in_p[gg]].set_write_response_ready_delay(value_in0_p[gg]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_SET_WRITE_RESPONSE_READY_DELAY", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_SET_WRITE_RESPONSE_READY_DELAY] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_write_response_ready_delay hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_WRITE_RESPONSE_READY_DELAY]);
        ack_p[gg][AXI4_VHD_GET_WRITE_RESPONSE_READY_DELAY] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          value_out0_p[gg] = transaction_array[transaction_id_in_p[gg]].get_write_response_ready_delay();
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_WRITE_RESPONSE_READY_DELAY", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_WRITE_RESPONSE_READY_DELAY] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // set_gen_write_strobes hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_SET_GEN_WRITE_STROBES]);
        ack_p[gg][AXI4_VHD_SET_GEN_WRITE_STROBES] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          transaction_array[transaction_id_in_p[gg]].set_gen_write_strobes(value_in0_p[gg]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_SET_GEN_WRITE_STROBES", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_SET_GEN_WRITE_STROBES] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_gen_write_strobes hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_GEN_WRITE_STROBES]);
        ack_p[gg][AXI4_VHD_GET_GEN_WRITE_STROBES] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          value_out0_p[gg] = transaction_array[transaction_id_in_p[gg]].get_gen_write_strobes();
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_GEN_WRITE_STROBES", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_GEN_WRITE_STROBES] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // set_operation_mode hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_SET_OPERATION_MODE]);
        ack_p[gg][AXI4_VHD_SET_OPERATION_MODE] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          transaction_array[transaction_id_in_p[gg]].set_operation_mode(axi4_operation_mode_e'(value_in0_p[gg]));
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_SET_OPERATION_MODE", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_SET_OPERATION_MODE] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_operation_mode hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_OPERATION_MODE]);
        ack_p[gg][AXI4_VHD_GET_OPERATION_MODE] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          value_out0_p[gg] = transaction_array[transaction_id_in_p[gg]].get_operation_mode();
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_OPERATION_MODE", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_OPERATION_MODE] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // set_write_data_mode hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_SET_WRITE_DATA_MODE]);
        ack_p[gg][AXI4_VHD_SET_WRITE_DATA_MODE] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          transaction_array[transaction_id_in_p[gg]].set_write_data_mode(axi4_write_data_mode_e'(value_in0_p[gg]));
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_SET_WRITE_DATA_MODE", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_SET_WRITE_DATA_MODE] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_write_data_mode hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_WRITE_DATA_MODE]);
        ack_p[gg][AXI4_VHD_GET_WRITE_DATA_MODE] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          value_out0_p[gg] = transaction_array[transaction_id_in_p[gg]].get_write_data_mode();
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_WRITE_DATA_MODE", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_WRITE_DATA_MODE] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // set_data_beat_done hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_SET_DATA_BEAT_DONE]);
        ack_p[gg][AXI4_VHD_SET_DATA_BEAT_DONE] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          transaction_array[transaction_id_in_p[gg]].set_data_beat_done(value_in0_p[gg], value_in1_p[gg]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_SET_DATA_BEAT_DONE", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_SET_DATA_BEAT_DONE] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_data_beat_done hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_DATA_BEAT_DONE]);
        ack_p[gg][AXI4_VHD_GET_DATA_BEAT_DONE] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          value_out0_p[gg] = transaction_array[transaction_id_in_p[gg]].get_data_beat_done(value_in0_p[gg]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_DATA_BEAT_DONE", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_DATA_BEAT_DONE] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // set_transaction_done hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_SET_TRANSACTION_DONE]);
        ack_p[gg][AXI4_VHD_SET_TRANSACTION_DONE] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          transaction_array[transaction_id_in_p[gg]].set_transaction_done(value_in0_p[gg]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_SET_TRANSACTION_DONE", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_SET_TRANSACTION_DONE] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_transaction_done hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_TRANSACTION_DONE]);
        ack_p[gg][AXI4_VHD_GET_TRANSACTION_DONE] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          value_out0_p[gg] = transaction_array[transaction_id_in_p[gg]].get_transaction_done();
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_TRANSACTION_DONE", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_TRANSACTION_DONE] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // set_config hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_SET_CONFIG]);
        ack_p[gg][AXI4_VHD_SET_CONFIG] = 1;
        set_config(axi4_config_e'(value_in0_p[gg]), value_in_max_p[gg]);
        ack_p[gg][AXI4_VHD_SET_CONFIG] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_config hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_CONFIG]);
        ack_p[gg][AXI4_VHD_GET_CONFIG] = 1;
        value_out_max_p[gg] = get_config(axi4_config_e'(value_in0_p[gg]));
        ack_p[gg][AXI4_VHD_GET_CONFIG] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // create_monitor_transaction hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_CREATE_MONITOR_TRANSACTION]);
        ack_p[gg][AXI4_VHD_CREATE_MONITOR_TRANSACTION] = 1;
        if((transaction_array[circular_id] != null) && (transaction_array[circular_id].transaction_done == 0))
        begin
          $display("%0t: %m (%d): Warning: Trying to create monitor_transaction id %d which is previously incomplete", $time, index, circular_id);
        end
        transaction_array[circular_id] = create_monitor_transaction();
        transaction_id_out_p[gg] = circular_id;
        ++circular_id;
        ack_p[gg][AXI4_VHD_CREATE_MONITOR_TRANSACTION] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_rw_transaction hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_RW_TRANSACTION]);
        ack_p[gg][AXI4_VHD_GET_RW_TRANSACTION] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          get_rw_transaction(transaction_array[transaction_id_in_p[gg]]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_RW_TRANSACTION", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_RW_TRANSACTION] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_write_data_burst hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_WRITE_DATA_BURST]);
        ack_p[gg][AXI4_VHD_GET_WRITE_DATA_BURST] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          get_write_data_burst(transaction_array[transaction_id_in_p[gg]]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_WRITE_DATA_BURST", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_WRITE_DATA_BURST] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_read_addr_phase hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_READ_ADDR_PHASE]);
        ack_p[gg][AXI4_VHD_GET_READ_ADDR_PHASE] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          get_read_addr_phase(transaction_array[transaction_id_in_p[gg]]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_READ_ADDR_PHASE", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_READ_ADDR_PHASE] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_read_data_burst hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_READ_DATA_BURST]);
        ack_p[gg][AXI4_VHD_GET_READ_DATA_BURST] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          get_read_data_burst(transaction_array[transaction_id_in_p[gg]]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_READ_DATA_BURST", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_READ_DATA_BURST] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_read_data_phase hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_READ_DATA_PHASE]);
        ack_p[gg][AXI4_VHD_GET_READ_DATA_PHASE] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          get_read_data_phase(transaction_array[transaction_id_in_p[gg]], value_in0_p[gg]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_READ_DATA_PHASE", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_READ_DATA_PHASE] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_write_addr_phase hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_WRITE_ADDR_PHASE]);
        ack_p[gg][AXI4_VHD_GET_WRITE_ADDR_PHASE] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          get_write_addr_phase(transaction_array[transaction_id_in_p[gg]]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_WRITE_ADDR_PHASE", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_WRITE_ADDR_PHASE] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_write_data_phase hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_WRITE_DATA_PHASE]);
        ack_p[gg][AXI4_VHD_GET_WRITE_DATA_PHASE] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          get_write_data_phase(transaction_array[transaction_id_in_p[gg]], value_in0_p[gg], value_out0_p[gg]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_WRITE_DATA_PHASE", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_WRITE_DATA_PHASE] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_write_response_phase hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_WRITE_RESPONSE_PHASE]);
        ack_p[gg][AXI4_VHD_GET_WRITE_RESPONSE_PHASE] = 1;
        if(transaction_array[transaction_id_in_p[gg]] != null)
        begin
          get_write_response_phase(transaction_array[transaction_id_in_p[gg]]);
        end
        else
        begin
          $display("%0t: %m (%d): Error: Transaction with ID = %d is not created before AXI4_VHD_GET_WRITE_RESPONSE_PHASE", $time, index, transaction_id_in_p[gg]);
        end
        ack_p[gg][AXI4_VHD_GET_WRITE_RESPONSE_PHASE] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_read_addr_ready hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_READ_ADDR_READY]);
        ack_p[gg][AXI4_VHD_GET_READ_ADDR_READY] = 1;
        get_read_addr_ready(value_out0_p[gg]);
        ack_p[gg][AXI4_VHD_GET_READ_ADDR_READY] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_read_data_ready hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_READ_DATA_READY]);
        ack_p[gg][AXI4_VHD_GET_READ_DATA_READY] = 1;
        get_read_data_ready(value_out0_p[gg]);
        ack_p[gg][AXI4_VHD_GET_READ_DATA_READY] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_write_addr_ready hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_WRITE_ADDR_READY]);
        ack_p[gg][AXI4_VHD_GET_WRITE_ADDR_READY] = 1;
        get_write_addr_ready(value_out0_p[gg]);
        ack_p[gg][AXI4_VHD_GET_WRITE_ADDR_READY] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_write_data_ready hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_WRITE_DATA_READY]);
        ack_p[gg][AXI4_VHD_GET_WRITE_DATA_READY] = 1;
        get_write_data_ready(value_out0_p[gg]);
        ack_p[gg][AXI4_VHD_GET_WRITE_DATA_READY] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // get_write_resp_ready hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_GET_WRITE_RESP_READY]);
        ack_p[gg][AXI4_VHD_GET_WRITE_RESP_READY] = 1;
        get_write_resp_ready(value_out0_p[gg]);
        ack_p[gg][AXI4_VHD_GET_WRITE_RESP_READY] <= 0;
    end

    //------------------------------------------------------------------------------
    //
    // wait_on hook for VHDL environment.
    //
    //------------------------------------------------------------------------------
    initial forever begin
    @(posedge req_p[gg][AXI4_VHD_WAIT_ON]);
        ack_p[gg][AXI4_VHD_WAIT_ON] = 1;
        wait_on(axi4_wait_e'(value_in0_p[gg]), value_in1_p[gg]);
        ack_p[gg][AXI4_VHD_WAIT_ON] <= 0;
    end

    end   // for loop
    endgenerate
`endif    // _MGC_VIP_VHDL_INTERFACE

    //------------------------------------------------------------------------------
    //
    // Function: set_config
    //
    //------------------------------------------------------------------------------
    // This function sets the configuration of the BFM.
    //------------------------------------------------------------------------------
    function void set_config(input axi4_config_e config_name, input axi4_max_bits_t config_val);
        case ( config_name )
            AXI4_CONFIG_INTERFACE_TYPE                                       : `call_for_axi4_bfm(set_config_interface_type                                      )(axi4_interface_type_e'(config_val));
            AXI4_CONFIG_SETUP_TIME                                           : `call_for_axi4_bfm(set_config_setup_time                                          )(config_val);
            AXI4_CONFIG_HOLD_TIME                                            : `call_for_axi4_bfm(set_config_hold_time                                           )(config_val);
            AXI4_CONFIG_BURST_TIMEOUT_FACTOR                                 : `call_for_axi4_bfm(set_config_burst_timeout_factor                                )(config_val);
            AXI4_CONFIG_MAX_TRANSACTION_TIME_FACTOR                          : `call_for_axi4_bfm(set_config_max_transaction_time_factor                         )(config_val);
            AXI4_CONFIG_ENABLE_RLAST                                         : `call_for_axi4_bfm(set_config_enable_rlast                                        )(config_val);
            AXI4_CONFIG_ENABLE_SLAVE_EXCLUSIVE                               : `call_for_axi4_bfm(set_config_enable_slave_exclusive                              )(config_val);
            AXI4_CONFIG_AXI4LITE_axi4                                        : `call_for_axi4_bfm(set_config_axi4lite_interface                                  )(config_val);
            AXI4_CONFIG_AXI4LITE_TR_ID                                       : `call_for_axi4_bfm(set_config_axi4lite_tr_id                                      )(config_val);
            AXI4_CONFIG_ENABLE_ALL_ASSERTIONS                                : `call_for_axi4_bfm(set_config_enable_all_assertions                               )(config_val);
            AXI4_CONFIG_ENABLE_ASSERTION                                     : `call_for_axi4_bfm(set_config_enable_assertion                                    )(config_val);
            AXI4_CONFIG_MAX_LATENCY_AWVALID_ASSERTION_TO_AWREADY             : `call_for_axi4_bfm(set_config_max_latency_AWVALID_assertion_to_AWREADY            )(config_val);
            AXI4_CONFIG_MAX_LATENCY_ARVALID_ASSERTION_TO_ARREADY             : `call_for_axi4_bfm(set_config_max_latency_ARVALID_assertion_to_ARREADY            )(config_val);
            AXI4_CONFIG_MAX_LATENCY_RVALID_ASSERTION_TO_RREADY               : `call_for_axi4_bfm(set_config_max_latency_RVALID_assertion_to_RREADY              )(config_val);
            AXI4_CONFIG_MAX_LATENCY_BVALID_ASSERTION_TO_BREADY               : `call_for_axi4_bfm(set_config_max_latency_BVALID_assertion_to_BREADY              )(config_val);
            AXI4_CONFIG_MAX_LATENCY_WVALID_ASSERTION_TO_WREADY               : `call_for_axi4_bfm(set_config_max_latency_WVALID_assertion_to_WREADY              )(config_val);
            AXI4_CONFIG_ENABLE_QOS                                           : `call_for_axi4_bfm(set_config_enable_qos                                          )(config_val);
            AXI4_CONFIG_READ_DATA_REORDERING_DEPTH                           : `call_for_axi4_bfm(set_config_read_data_reordering_depth                          )(config_val);
            AXI4_CONFIG_SLAVE_START_ADDR                                     : `call_for_axi4_bfm(set_config_slave_start_addr                                    )(config_val);
            AXI4_CONFIG_SLAVE_END_ADDR                                       : `call_for_axi4_bfm(set_config_slave_end_addr                                      )(config_val);
            AXI4_CONFIG_MAX_OUTSTANDING_WR                                   : `call_for_axi4_bfm(set_config_max_outstanding_wr                                  )(config_val);
            AXI4_CONFIG_MAX_OUTSTANDING_RD                                   : `call_for_axi4_bfm(set_config_max_outstanding_rd                                  )(config_val);
            AXI4_CONFIG_NUM_OUTSTANDING_WR_PHASE                             : `call_for_axi4_bfm(set_config_num_outstanding_wr_phase                            )(config_val);
            AXI4_CONFIG_NUM_OUTSTANDING_RD_PHASE                             : `call_for_axi4_bfm(set_config_num_outstanding_rd_phase                            )(config_val);
            default : $display("%0t: %m: Config %s not a valid option to set_config().", $time, config_name.name());
        endcase
    endfunction

    //------------------------------------------------------------------------------
    //
    // Function: get_config
    //
    //------------------------------------------------------------------------------
    // This function gets the configuration of the BFM.
    //------------------------------------------------------------------------------
    function axi4_max_bits_t get_config( input axi4_config_e config_name );
        case ( config_name )
            AXI4_CONFIG_INTERFACE_TYPE                                       : return `call_for_axi4_bfm(get_config_interface_type)();
            AXI4_CONFIG_SETUP_TIME                                           : return `call_for_axi4_bfm(get_config_setup_time)();
            AXI4_CONFIG_HOLD_TIME                                            : return `call_for_axi4_bfm(get_config_hold_time)();
            AXI4_CONFIG_BURST_TIMEOUT_FACTOR                                 : return `call_for_axi4_bfm(get_config_burst_timeout_factor)();
            AXI4_CONFIG_MAX_TRANSACTION_TIME_FACTOR                          : return `call_for_axi4_bfm(get_config_max_transaction_time_factor)();
            AXI4_CONFIG_ENABLE_RLAST                                         : return `call_for_axi4_bfm(get_config_enable_rlast)();
            AXI4_CONFIG_ENABLE_SLAVE_EXCLUSIVE                               : return `call_for_axi4_bfm(get_config_enable_slave_exclusive)();
            AXI4_CONFIG_AXI4LITE_axi4                                        : return `call_for_axi4_bfm(get_config_axi4lite_interface)();
            AXI4_CONFIG_AXI4LITE_TR_ID                                       : return `call_for_axi4_bfm(get_config_axi4lite_tr_id)();
            AXI4_CONFIG_ENABLE_ALL_ASSERTIONS                                : return `call_for_axi4_bfm(get_config_enable_all_assertions)();
            AXI4_CONFIG_ENABLE_ASSERTION                                     : return `call_for_axi4_bfm(get_config_enable_assertion)();
            AXI4_CONFIG_MAX_LATENCY_AWVALID_ASSERTION_TO_AWREADY             : return `call_for_axi4_bfm(get_config_max_latency_AWVALID_assertion_to_AWREADY)();
            AXI4_CONFIG_MAX_LATENCY_ARVALID_ASSERTION_TO_ARREADY             : return `call_for_axi4_bfm(get_config_max_latency_ARVALID_assertion_to_ARREADY)();
            AXI4_CONFIG_MAX_LATENCY_RVALID_ASSERTION_TO_RREADY               : return `call_for_axi4_bfm(get_config_max_latency_RVALID_assertion_to_RREADY)();
            AXI4_CONFIG_MAX_LATENCY_BVALID_ASSERTION_TO_BREADY               : return `call_for_axi4_bfm(get_config_max_latency_BVALID_assertion_to_BREADY)();
            AXI4_CONFIG_MAX_LATENCY_WVALID_ASSERTION_TO_WREADY               : return `call_for_axi4_bfm(get_config_max_latency_WVALID_assertion_to_WREADY)();
            AXI4_CONFIG_ENABLE_QOS                                           : return `call_for_axi4_bfm(get_config_enable_qos)();
            AXI4_CONFIG_READ_DATA_REORDERING_DEPTH                           : return `call_for_axi4_bfm(get_config_read_data_reordering_depth)();
            AXI4_CONFIG_SLAVE_START_ADDR                                     : return `call_for_axi4_bfm(get_config_slave_start_addr)();
            AXI4_CONFIG_SLAVE_END_ADDR                                       : return `call_for_axi4_bfm(get_config_slave_end_addr)();
            AXI4_CONFIG_MAX_OUTSTANDING_WR                                   : return `call_for_axi4_bfm(get_config_max_outstanding_wr)();
            AXI4_CONFIG_MAX_OUTSTANDING_RD                                   : return `call_for_axi4_bfm(get_config_max_outstanding_rd)();
            AXI4_CONFIG_NUM_OUTSTANDING_WR_PHASE                             : return `call_for_axi4_bfm(get_config_num_outstanding_wr_phase)();
            AXI4_CONFIG_NUM_OUTSTANDING_RD_PHASE                             : return `call_for_axi4_bfm(get_config_num_outstanding_rd_phase)();
            default : $display("%0t: %m: Config %s not a valid option to get_config().", $time, config_name.name());
        endcase
    endfunction

    //------------------------------------------------------------------------------
    //
    // Function: create_monitor_transaction
    //
    //------------------------------------------------------------------------------
    // This function creates a monitor transaction.
    //------------------------------------------------------------------------------
    function automatic axi4_transaction create_monitor_transaction();
      axi4_transaction trans   = new();
      trans.driver_name.itoa(index);
      trans.driver_name                    = {"Monitor: index = ", trans.driver_name, ":"};
      return trans;
    endfunction

    //------------------------------------------------------------------------------
    //
    // Task: get_rw_transaction()
    //
    //-------------------------------------------------------------------------------------------------
    // This task waits for a complete rw_transaction and copies the information
    // back to the axi4_transaction.
    //-------------------------------------------------------------------------------------------------
    task automatic get_rw_transaction(axi4_transaction trans);
        bit [((AXI4_USER_WIDTH) - 1):0] lwdata_user_data [];
        bit [((AXI4_USER_WIDTH) - 1):0] lresp_user_data [];
        bit lwrite_data_with_address;

        bit [((((AXI4_RDATA_WIDTH > AXI4_WDATA_WIDTH) ? AXI4_RDATA_WIDTH : AXI4_WDATA_WIDTH)) - 1):0] ldata_words [];
        bit [(((AXI4_WDATA_WIDTH / 8)) - 1) : 0] lwrite_strobes[];

        int lwrite_address_to_data_delay;
        int lwrite_data_to_address_delay;
        int lwrite_data_beats_delay[];

        int i;

        `call_for_axi4_bfm(dvc_get_rw_transaction)(
            QUESTA_MVC::QUESTA_MVC_COMMS_RECEIVED,
            `call_for_axi4_bfm(get_axi4__monitor_end)(),
            trans.read_or_write,
            trans.addr,
            trans.prot,
            trans.region,
            trans.size,
            trans.burst,
            trans.lock,
            trans.cache,
            trans.qos,
            trans.id,
            trans.burst_length,
            trans.addr_user,
            ldata_words,
            lwrite_strobes,
            lwdata_user_data,
            trans.resp,
            lresp_user_data,
            trans.address_valid_delay,
            trans.data_valid_delay,
            trans.write_response_valid_delay,
            trans.address_ready_delay,
            trans.data_ready_delay,
            trans.write_response_ready_delay,
            lwrite_data_with_address,
            lwrite_address_to_data_delay,
            lwrite_data_to_address_delay,
            lwrite_data_beats_delay,
            0, 1
        );

        trans.data_words = new[(ldata_words.size())];
        for (i = 0; i < ldata_words.size(); i++)
          trans.data_words[i] = ldata_words[i];

        trans.write_strobes = new[(lwrite_strobes.size())];
        for (i = 0; i < lwrite_strobes.size(); i++)
          trans.write_strobes[i] = lwrite_strobes[i];

        if( lwrite_data_with_address == 1'b1 )
            trans.write_data_mode = AXI4_DATA_WITH_ADDRESS;

    endtask

    //------------------------------------------------------------------------------
    //
    // Task: get_write_data_burst()
    //
    //-------------------------------------------------------------------------------------------------
    // This task waits for a complete write_data_burst and copies the information
    // back to the axi4_transaction.
    //-------------------------------------------------------------------------------------------------
    task automatic get_write_data_burst(axi4_transaction trans);
        int unsigned i;
        bit last;

        while (last == 1'b0)
        begin
            get_write_data_phase(trans, i, last);
            ++i;
        end
    endtask

    //------------------------------------------------------------------------------
    //
    // Task: get_read_addr_phase()
    //
    //-------------------------------------------------------------------------------------------------
    // This task waits for a complete read_addr_phase and copies the information
    // back to the axi4_transaction.
    //-------------------------------------------------------------------------------------------------
    task automatic get_read_addr_phase(axi4_transaction trans);
        `call_for_axi4_bfm(dvc_get_read_addr_channel_phase)(
            QUESTA_MVC::QUESTA_MVC_COMMS_RECEIVED,
            `call_for_axi4_bfm(get_axi4__monitor_end)(),
            trans.addr,
            trans.prot,
            trans.region,
            trans.burst_length,
            trans.size,
            trans.burst,
            trans.lock,
            trans.cache,
            trans.qos,
            trans.id,
            trans.addr_user,
            trans.address_valid_delay,
            trans.address_ready_delay,
            0, 1
        );
    endtask

    //------------------------------------------------------------------------------
    //
    // Task: get_read_data_burst()
    //
    //-------------------------------------------------------------------------------------------------
    // This task waits for a complete read_data_burst and copies the information
    // back to the axi4_transaction.
    //-------------------------------------------------------------------------------------------------
    task automatic get_read_data_burst(axi4_transaction trans);
        int unsigned i;

        while (trans.transaction_done == 1'b0)
        begin
            get_read_data_phase(trans, i);
            ++i;
        end
    endtask

    //------------------------------------------------------------------------------
    //
    // Task: get_read_data_phase()
    //
    //-------------------------------------------------------------------------------------------------
    // This task waits for a complete read_data_phase and copies the information
    // back to the axi4_transaction.
    // On completion, this task sets the data_beat_done[index] to 1.
    // This task sets the transaction_done to 1 on completion of transaction.
    //-------------------------------------------------------------------------------------------------
    task automatic get_read_data_phase(axi4_transaction trans, int index = 0);
        bit [((AXI4_ID_WIDTH) - 1) : 0] trans_id;
        bit [((AXI4_USER_WIDTH) - 1):0]  luser_data;
        bit last;

        trans_id = trans.id;

        if (trans.data_words.size() <= index)
          trans.data_words = new[(index + 1)](trans.data_words);

        if (trans.resp.size() <= index)
          trans.resp = new[(index + 1)](trans.resp);

        if (trans.data_ready_delay.size() <= index)
          trans.data_ready_delay = new[(index + 1)](trans.data_ready_delay);

        if (trans.data_beat_done.size() <= index)
          trans.data_beat_done = new[(index + 1)](trans.data_beat_done);

        if (trans.data_beat_done[index] == 1'b0)
        begin
          do
            `call_for_axi4_bfm(dvc_get_read_channel_phase)(
              QUESTA_MVC::QUESTA_MVC_COMMS_RECEIVED,
              `call_for_axi4_bfm(get_axi4__monitor_end)(),
              trans.data_words[index],
              trans.resp[index],
              last,
              trans.id,
              luser_data,
              trans.data_ready_delay[index],
              0, 1
            );
          while (trans.id != trans_id);

          trans.transaction_done      = last;
          trans.data_beat_done[index] = 1'b1;
        end
    endtask

    //------------------------------------------------------------------------------
    //
    // Task: get_write_addr_phase()
    //
    //-------------------------------------------------------------------------------------------------
    // This task waits for a complete write_addr_phase and copies the information
    // back to the axi4_transaction.
    //-------------------------------------------------------------------------------------------------
    task automatic get_write_addr_phase(axi4_transaction trans);
        `call_for_axi4_bfm(dvc_get_write_addr_channel_phase)(
            QUESTA_MVC::QUESTA_MVC_COMMS_RECEIVED,
            `call_for_axi4_bfm(get_axi4__monitor_end)(),
            trans.addr,
            trans.prot,
            trans.region,
            trans.burst_length,
            trans.size,
            trans.burst,
            trans.lock,
            trans.cache,
            trans.qos,
            trans.id,
            trans.addr_user,
            trans.address_valid_delay,
            trans.address_ready_delay,
            0, 1
        );
    endtask

    //------------------------------------------------------------------------------
    //
    // Task: get_write_data_phase()
    //
    //-------------------------------------------------------------------------------------------------
    // This task waits for a complete write_data_phase and copies the information
    // back to the axi4_transaction.
    // On completion, this task sets the data_beat_done[index] to 1.
    //-------------------------------------------------------------------------------------------------
    task automatic get_write_data_phase(axi4_transaction trans, int index = 0, output bit last);
        bit [((AXI4_ID_WIDTH) - 1) : 0] trans_id;
        bit [((AXI4_USER_WIDTH) - 1):0]  luser_data;

        trans_id = trans.id;

        if (trans.data_words.size() <= index)
          trans.data_words = new[(index + 1)](trans.data_words);

        if (trans.write_strobes.size() <= index)
          trans.write_strobes = new[(index + 1)](trans.write_strobes);

        if (trans.data_ready_delay.size() <= index)
          trans.data_ready_delay = new[(index + 1)](trans.data_ready_delay);

        if (trans.data_beat_done.size() <= index)
          trans.data_beat_done = new[(index + 1)](trans.data_beat_done);

        if (trans.data_beat_done[index] == 1'b0)
        begin
          do
            `call_for_axi4_bfm(dvc_get_write_channel_phase)(
              QUESTA_MVC::QUESTA_MVC_COMMS_RECEIVED,
              `call_for_axi4_bfm(get_axi4__monitor_end)(),
              trans.data_words[index],
              trans.write_strobes[index],
              last,
              luser_data,
              trans.data_ready_delay[index],
              0, 1
            );
          while (trans.id != trans_id);

          trans.data_beat_done[index] = 1'b1;
        end
    endtask

    //------------------------------------------------------------------------------
    //
    // Task: get_write_response_phase()
    //
    //-------------------------------------------------------------------------------------------------
    // This task waits for a complete write_response_phase and copies the information
    // back to the axi4_transaction.
    // This task also sets the transaction_done to 1 on completion of the write_response_phase.
    //-------------------------------------------------------------------------------------------------
    task automatic get_write_response_phase(axi4_transaction trans);
        bit [((AXI4_ID_WIDTH) - 1) : 0] trans_id;
        bit [((AXI4_USER_WIDTH) - 1):0]  luser_data;

        trans_id = trans.id;

        if (trans.resp.size() == 0)
          trans.resp = new[1];

        if (trans.transaction_done == 1'b0)
        begin
          do
          `call_for_axi4_bfm(dvc_get_write_resp_channel_phase)(
              QUESTA_MVC::QUESTA_MVC_COMMS_RECEIVED,
              `call_for_axi4_bfm(get_axi4__monitor_end)(),
              trans.resp[0],
              trans.id,
              luser_data,
              trans.write_response_ready_delay,
              0, 1
          );
          while (trans.id != trans_id);

          trans.transaction_done = 1;
        end
    endtask

    //------------------------------------------------------------------------------
    //
    // Task: get_read_addr_ready()
    //
    //-------------------------------------------------------------------------------------------------
    // This task waits for a complete read_addr_ready and copies the information
    // back to the axi4_transaction.
    //-------------------------------------------------------------------------------------------------
    task automatic get_read_addr_ready(output bit ready);
        `call_for_axi4_bfm(dvc_get_read_addr_channel_ready)(
            QUESTA_MVC::QUESTA_MVC_COMMS_RECEIVED,
            `call_for_axi4_bfm(get_axi4__monitor_end)(),
            ready,
            0, 1
        );
    endtask

    //------------------------------------------------------------------------------
    //
    // Task: get_read_data_ready()
    //
    //-------------------------------------------------------------------------------------------------
    // This task waits for a complete read_data_ready and copies the information
    // back to the axi4_transaction.
    //-------------------------------------------------------------------------------------------------
    task automatic get_read_data_ready(output bit ready);
        `call_for_axi4_bfm(dvc_get_read_channel_ready)(
            QUESTA_MVC::QUESTA_MVC_COMMS_RECEIVED,
            `call_for_axi4_bfm(get_axi4__monitor_end)(),
            ready,
            0, 1
        );
    endtask

    //------------------------------------------------------------------------------
    //
    // Task: get_write_addr_ready()
    //
    //-------------------------------------------------------------------------------------------------
    // This task waits for a complete write_addr_ready and copies the information
    // back to the axi4_transaction.
    //-------------------------------------------------------------------------------------------------
    task automatic get_write_addr_ready(output bit ready);
        `call_for_axi4_bfm(dvc_get_write_addr_channel_ready)(
            QUESTA_MVC::QUESTA_MVC_COMMS_RECEIVED,
            `call_for_axi4_bfm(get_axi4__monitor_end)(),
            ready,
            0, 1
        );
    endtask

    //------------------------------------------------------------------------------
    //
    // Task: get_write_data_ready()
    //
    //-------------------------------------------------------------------------------------------------
    // This task waits for a complete write_data_ready and copies the information
    // back to the axi4_transaction.
    //-------------------------------------------------------------------------------------------------
    task automatic get_write_data_ready(output bit ready);
        `call_for_axi4_bfm(dvc_get_write_channel_ready)(
            QUESTA_MVC::QUESTA_MVC_COMMS_RECEIVED,
            `call_for_axi4_bfm(get_axi4__monitor_end)(),
            ready,
            0, 1
        );
    endtask

    //------------------------------------------------------------------------------
    //
    // Task: get_write_resp_ready()
    //
    //-------------------------------------------------------------------------------------------------
    // This task waits for a complete write_resp_ready and copies the information
    // back to the axi4_transaction.
    //-------------------------------------------------------------------------------------------------
    task automatic get_write_resp_ready(output bit ready);
        `call_for_axi4_bfm(dvc_get_write_resp_channel_ready)(
            QUESTA_MVC::QUESTA_MVC_COMMS_RECEIVED,
            `call_for_axi4_bfm(get_axi4__monitor_end)(),
            ready,
            0, 1
        );
    endtask

    //------------------------------------------------------------------------------
    //
    // Function: get_write_addr_data
    //
    //-----------------------------------------------------------------------------------------------
    // HELPER API:
    // This function takes axi4_transaction(write type) and index as input. Then it provides
    // address and data of the memory (Memory needs to be written on the
    // provided address with the provided data). If corresponding index does
    // not exist then this function returns false otherwise it returns true.
    //-----------------------------------------------------------------------------------------------
    function automatic bit get_write_addr_data(input axi4_transaction trans,
                                               input int index = 0,
                                               output bit [((AXI4_ADDRESS_WIDTH) - 1) : 0] addr[],
                                               output bit [7:0] data[]);
      if (trans.read_or_write == AXI4_TRANS_WRITE)
      begin
        if (index < trans.data_words.size())
        begin
          int unsigned i;
          int unsigned wrap_boundary;
          bit [((AXI4_ADDRESS_WIDTH) - 1) : 0] index_start_addr;
          bit [((AXI4_ADDRESS_WIDTH) - 1) : 0] base_addr;
          bit [((AXI4_ADDRESS_WIDTH) - 1) : 0] end_addr;

          wrap_boundary = ( trans.burst_length + 1 ) * ( 1 << trans.size );
          base_addr = trans.addr - (trans.addr % wrap_boundary);
          end_addr = base_addr + wrap_boundary;

          if (trans.burst == AXI4_INCR)
            index_start_addr = trans.addr + (index * (1 << trans.size)) - (trans.addr % (1 << trans.size));
          else if (trans.burst == AXI4_WRAP)
          begin
            index_start_addr = trans.addr + (index * (1 << trans.size));

            while (index_start_addr >= end_addr)
              index_start_addr = base_addr + index_start_addr - end_addr;
          end

          for (i = 0 ; i < (AXI4_WDATA_WIDTH/8) ; i++)
          begin
            if (trans.write_strobes[index][i] == 1'b1)
            begin
              int unsigned data_array_size;
              data_array_size = data.size();
              data = new[(data_array_size + 1)](data);
              addr = new[(data_array_size + 1)](addr);

              data[data_array_size] = trans.data_words[index][((8 * (i + 1)) - 1) -: 8];

              if (trans.burst == AXI4_FIXED)
                addr[data_array_size] = trans.addr - (trans.addr % (AXI4_WDATA_WIDTH/8)) + i;
              else if (trans.burst == AXI4_INCR)
              begin
                if (index == 0)
                  addr[data_array_size] = trans.addr - (trans.addr % (AXI4_WDATA_WIDTH/8)) + i;
                else  // index > 0
                  addr[data_array_size] = index_start_addr - (index_start_addr % (AXI4_WDATA_WIDTH/8)) + i;
              end
              else if (trans.burst == AXI4_WRAP)
              begin
                addr[data_array_size] = index_start_addr - (index_start_addr % (AXI4_WDATA_WIDTH/8)) + i;

                while (addr[data_array_size] >= end_addr)
                  addr[data_array_size] = base_addr + addr[data_array_size] - end_addr;
              end
            end
          end

          return 1'b1;
        end
      end

      return 1'b0;
    endfunction

    //------------------------------------------------------------------------------
    //
    // Function: get_read_addr
    //
    //-----------------------------------------------------------------------------------------------
    // HELPER API:
    // This function takes axi4_transaction(read type) and index as input. Then it provides
    // addresses of the memory which will be accessed for that particular
    // index.
    // If corresponding index can not exist (based on burst length of read transfer)
    // then this function returns false otherwise it returns true.
    //-----------------------------------------------------------------------------------------------
    function automatic bit get_read_addr(input axi4_transaction trans,
                                         input int index = 0,
                                         output bit [((AXI4_ADDRESS_WIDTH) - 1) : 0] addr[]);
      if (trans.read_or_write == AXI4_TRANS_READ)
      begin
        if (index <= trans.burst_length)
        begin
          int unsigned i;
          int unsigned wrap_boundary;
          int unsigned addr_array_size;
          bit [((AXI4_ADDRESS_WIDTH) - 1) : 0] index_start_addr;
          bit [((AXI4_ADDRESS_WIDTH) - 1) : 0] base_addr;
          bit [((AXI4_ADDRESS_WIDTH) - 1) : 0] end_addr;

          wrap_boundary = ( trans.burst_length + 1 ) * ( 1 << trans.size );
          base_addr = trans.addr - (trans.addr % wrap_boundary);
          end_addr = base_addr + wrap_boundary;

          if (index == 0)
            index_start_addr = trans.addr;
          else  // index > 0
          begin
            if (trans.burst == AXI4_FIXED)
              index_start_addr = trans.addr;
            else if (trans.burst == AXI4_INCR)
              index_start_addr = trans.addr + (index * (1 << trans.size)) - (trans.addr % (1 << trans.size));
            else if (trans.burst == AXI4_WRAP)
            begin
              index_start_addr = trans.addr + (index * (1 << trans.size));

              while (index_start_addr >= end_addr)
                index_start_addr = base_addr + index_start_addr - end_addr;
            end
          end

          if (index == 0)
            addr_array_size = (1 << trans.size) - (trans.addr % (1 << trans.size));
          else
            addr_array_size = (1 << trans.size);

          addr = new[addr_array_size];

          for (i = 0 ; i < addr_array_size ; i++)
          begin
            if ((trans.burst == AXI4_FIXED) || (trans.burst == AXI4_INCR))
              addr[i] = index_start_addr + i;
            else if (trans.burst == AXI4_WRAP)
            begin
              addr[i] = index_start_addr + i;

              while (addr[i] >= end_addr)
                addr[i] = base_addr + addr[i] - end_addr;
            end
          end

          return 1'b1;
        end
      end

      return 1'b0;
    endfunction

    //------------------------------------------------------------------------------
    //
    // Function: set_read_data
    //
    //-----------------------------------------------------------------------------------------------
    // HELPER API:
    // This function takes axi4_transaction(read type), index of the read response/data beat,
    // address array from which data need to be read and data read from memory as input.
    // Then it sets the data beats in the data_words field of the
    // axi4_transaction trans.
    //-----------------------------------------------------------------------------------------------
    function automatic void set_read_data(input axi4_transaction trans,
                                          input int index = 0,
                                          input bit [((AXI4_ADDRESS_WIDTH) - 1) : 0] addr[],
                                          input bit [7:0] data[]);
      if (trans.read_or_write == AXI4_TRANS_READ)
      begin
        int unsigned i;
        int start_byte_index;

        start_byte_index = (addr[0] % (AXI4_RDATA_WIDTH/8));

        for (i = 0 ; i < addr.size() ; i++)
        begin
          trans.data_words[index][((8 * (start_byte_index + 1)) - 1) -: 8] = data[i];
          start_byte_index++;
        end
      end
    endfunction

    //------------------------------------------------------------------------------
    //
    // Task: wait_on()
    //
    //------------------------------------------------------------------------------
    // This task waits for at least one particular event from the BFM.
    //------------------------------------------------------------------------------
    task automatic wait_on( axi4_wait_e phase, input int count = 1 );
        case( phase )
            AXI4_CLOCK_POSEDGE : `call_for_axi4_bfm(wait_for_ACLK)( QUESTA_MVC::QUESTA_MVC_POSEDGE,     count );
            AXI4_CLOCK_NEGEDGE : `call_for_axi4_bfm(wait_for_ACLK)( QUESTA_MVC::QUESTA_MVC_NEGEDGE,     count );
            AXI4_CLOCK_ANYEDGE : `call_for_axi4_bfm(wait_for_ACLK)( QUESTA_MVC::QUESTA_MVC_ANYEDGE,     count );
            AXI4_CLOCK_0_TO_1  : `call_for_axi4_bfm(wait_for_ACLK)( QUESTA_MVC::QUESTA_MVC_0_TO_1_EDGE, count );
            AXI4_CLOCK_1_TO_0  : `call_for_axi4_bfm(wait_for_ACLK)( QUESTA_MVC::QUESTA_MVC_1_TO_0_EDGE, count );
            AXI4_RESET_POSEDGE : `call_for_axi4_bfm(wait_for_ARESETn)( QUESTA_MVC::QUESTA_MVC_POSEDGE,     count );
            AXI4_RESET_NEGEDGE : `call_for_axi4_bfm(wait_for_ARESETn)( QUESTA_MVC::QUESTA_MVC_NEGEDGE,     count );
            AXI4_RESET_ANYEDGE : `call_for_axi4_bfm(wait_for_ARESETn)( QUESTA_MVC::QUESTA_MVC_ANYEDGE,     count );
            AXI4_RESET_0_TO_1  : `call_for_axi4_bfm(wait_for_ARESETn)( QUESTA_MVC::QUESTA_MVC_0_TO_1_EDGE, count );
            AXI4_RESET_1_TO_0  : `call_for_axi4_bfm(wait_for_ARESETn)( QUESTA_MVC::QUESTA_MVC_1_TO_0_EDGE, count );
            default : $display("%0t: %m: Phase %s not supported in wait_on().", $time, phase.name());
        endcase
    endtask

endinterface

