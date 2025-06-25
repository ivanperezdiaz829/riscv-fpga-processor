//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
//     Logic Core:             PCI Megacore Function
//     Company:                Altera Corporation.
//                             www.altera.com
//     Author :                Penang IP Group Ching Lee Fong
//			       
//     Description:    PCI Avalon Light PCI Bus Access Module
//
//     Copyright 2007 Altera Corporation. All rights reserved.  This source code is highly
//     confidential and proprietary information of Altera and is being provided in accordance with
//     and subject to the protections of a Non-Disclosure Agreement which governs its use and
//     disclosure.  Altera products and services are protected under numerous U.S. and foreign
//    patents, maskwork rights, copyrights and other intellectual property laws.  Altera assumes
//     no responsibility or liability arising out of the application or use of this source code.
//
//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////

module altpciav_lite_pba 
  #(
    parameter CG_PCI_DATA_WIDTH = 32,
    parameter CB_A2P_ADDR_MAP_IS_FIXED = 0 ,
    parameter CB_A2P_ADDR_MAP_NUM_ENTRIES = 16 ,
    parameter CB_A2P_ADDR_MAP_PASS_THRU_BITS = 12 ,
    parameter CG_AVALON_S_ADDR_WIDTH = 32 ,
    parameter CG_PCI_ADDR_WIDTH = 32 ,
    parameter [1023:0] CB_A2P_ADDR_MAP_FIXED_TABLE = 0

    )

(

pci_clk_i,
pci_rstn_i,

pba_clk_i,
pba_rstn_i,
pba_chipselect_i,
pba_address_i,
pba_byteenable_i,
pba_read_i,
pba_readdata_o,
pba_write_i,
pba_writedata_i,
pba_readdatavalid_o,
pba_waitrequest_o,
pba_burstcount_i,
pba_begintransfer_i,
pba_beginbursttransfer_i,

//l_ldat_ackn_i,
//l_hdat_ackn_i,
lm_adr_ackn_i,
lm_ackn_i,
l_dato_i,
lm_tsr_i,
stat_reg_i,
cmd_reg_i,
lm_dxfrn_i,
//cachesize_i,
lm_lastn_o,
lm_req32n_o,
//lm_reqn_o,
lm_rdyn_o,
l_adi_o,
l_cben_o,

    AdTrAddress_i,   // Register (DWORD) specific address
    AdTrByteEnable_i,// Register Byte Enables
    AdTrWriteVld_i,  // Valid Write Cycle in
    AdTrWriteData_i, // Write Data in
    AdTrReadVld_i,   // Read Valid in
    AdTrReadData_o,  // Read Data out
    AdTrReadVld_o  // Read Valid out (piped)
);

// Port Declaration
input pci_clk_i;
input pci_rstn_i;

input pba_clk_i;
input pba_rstn_i;
input pba_chipselect_i;
input [CG_AVALON_S_ADDR_WIDTH-1 : (CG_PCI_DATA_WIDTH/32)+1 ]pba_address_i;
input [(CG_PCI_DATA_WIDTH/8)-1 : 0]pba_byteenable_i;
input pba_read_i;
output [CG_PCI_DATA_WIDTH-1 : 0]pba_readdata_o;
input pba_write_i;
input [CG_PCI_DATA_WIDTH-1 : 0]pba_writedata_i;
output pba_readdatavalid_o;
output pba_waitrequest_o;
input [7:0]pba_burstcount_i;
input pba_begintransfer_i;
input pba_beginbursttransfer_i;

//input l_ldat_ackn_i;
//input l_hdat_ackn_i;
input lm_adr_ackn_i;
input lm_ackn_i;
input [CG_PCI_DATA_WIDTH-1 : 0]l_dato_i;
input [9:0]lm_tsr_i;
input [6:0]stat_reg_i;
input [6:0]cmd_reg_i;
input lm_dxfrn_i;
//input cachesize_i;
output lm_lastn_o;
output lm_req32n_o;
//output lm_reqn_o;
output lm_rdyn_o;
output [CG_PCI_DATA_WIDTH-1 : 0]l_adi_o;
output [(CG_PCI_DATA_WIDTH/8)-1 : 0]l_cben_o;

input [11:2]   AdTrAddress_i;   // Register (DWORD) specific address
input  [3:0]  AdTrByteEnable_i;// Register Byte Enables
input    AdTrWriteVld_i;  // Valid Write Cycle in
input  [31:0]  AdTrWriteData_i; // Write Data in
input    AdTrReadVld_i;   // Read Valid in
output [31:0]   AdTrReadData_o;  // Read Data out
output    AdTrReadVld_o; // Read Valid out (piped)

// Wire and Regs
wire [CG_PCI_DATA_WIDTH-1 : 0]data_fifo_out;
wire [CG_PCI_DATA_WIDTH-1 : 0]pci_addr;
wire [CG_PCI_DATA_WIDTH-1 : 0]pci_address_o;
wire [(CG_PCI_DATA_WIDTH/8)-1 : 0]pci_cmd_o;
wire [(CG_PCI_DATA_WIDTH/8)-1 : 0]pci_ben_o;

wire [CG_AVALON_S_ADDR_WIDTH-1 : 0]av_addr;
wire [1:0]addr_space_type;
wire addr_trans_done;

wire read_wait;
wire fifo_rd_req;
wire [31:0]fifo_data;
wire [7:0]avl_mstr_burst;
wire avl_mstr_wr_req;
wire avl_mstr_rd_req;
wire pba_write_state;
wire pba_read_state;
wire av_addr_vld;
wire lb_write_state_rise;
wire lb_req_state_rise;
wire lb_busy;
wire [7:0] rdusedw;

wire avl_fifo_wr_req;
wire valid_loc_data_xfr;
wire unfinished_write;
wire unfinished_read;
wire fifo_empty;

assign valid_loc_data_xfr = !lm_dxfrn_i;
assign read_wait = pba_readdatavalid_o | (lm_dxfrn_i & ~lm_rdyn_o);

//reg test;
//always @(posedge pci_clk_i or negedge pci_rstn_i)
//begin
//if (~pci_rstn_i)
//   test <= 1'b0;
//else if (~lm_rdyn_o)
//   test <= 1'b1;
//else if (lm_lastn_o)
//test <= 1'b0;
//else
//   test <= 1'b0;
//end

// the lite_pba_loc Module
// instantiation of the PBA PCI interface module
altpciav_lite_pba_loc 
  #(
   .CG_PCI_DATA_WIDTH(CG_PCI_DATA_WIDTH)
    )
lite_pba_loc(

 .pci_clk_i(pci_clk_i),
 .pci_rstn_i(pci_rstn_i),
 //.l_ldat_ackn_i(l_ldat_ackn_i),
 //.l_hdat_ackn_i(l_hdat_ackn_i),
 .lm_adr_ackn_i(lm_adr_ackn_i),
 .lm_ackn_i(lm_ackn_i),
 .l_adi_o(l_adi_o),
 .l_cben_o(l_cben_o),
 .l_dato_i(l_dato_i),
 .lm_tsr_i(lm_tsr_i),
 .stat_reg_i(stat_reg_i),
 .cmd_reg_i(cmd_reg_i),
 .lm_dxfrn_i(lm_dxfrn_i),
// .cachesize_i(cachesize_i),
 .lm_lastn_o(lm_lastn_o),
 //.lm_reqn_o(lm_reqn_o),
 .lm_req32n_o(lm_req32n_o),
 .lm_rdyn_o(lm_rdyn_o),

 .fifo_data_i(fifo_data),
 .fifo_rd_req_o(fifo_rd_req),

 .pci_address_o(pci_address_o),
 .pci_cmd_o(pci_cmd_o),
 .pci_ben_o(pci_ben_o),

 .avl_mstr_wr_req(avl_mstr_wr_req),
 .avl_mstr_burst_i(avl_mstr_burst),
 .avl_mstr_rd_req(avl_mstr_rd_req),

 .pba_writedata_i(data_fifo_out),
 .pba_readdata_o(pba_readdata_o),
 .pba_readdatavalid_o(pba_readdatavalid_o),
 .pba_write_state_i(pba_write_state),
 .lb_write_state_rise_o(lb_write_state_rise),
 .lb_req_state_rise_o(lb_req_state_rise),
 .lb_busy_o(lb_busy),
 .rdusedw_i(rdusedw),
 .unfinished_write_i(unfinished_write),
 .unfinished_read_i(unfinished_read)
);


// the lite_pba_avl Module
// instantiation of the PBA avalon interface module
altpciav_lite_pba_avl 
  #(
   .CG_PCI_DATA_WIDTH(CG_PCI_DATA_WIDTH),
   .CG_AVALON_S_ADDR_WIDTH(CG_AVALON_S_ADDR_WIDTH)
    )
lite_pba_avl(
 .pci_clk_i(pci_clk_i),
 .pci_rstn_i(pci_rstn_i),
 .pba_clk_i(pba_clk_i),
 .pba_rstn_i(pba_rstn_i),
 .pba_chipselect_i(pba_chipselect_i),
 .pba_address_i(pba_address_i),
 .pba_byteenable_i(pba_byteenable_i),
 .pba_read_i(pba_read_i),
 .pba_write_i(pba_write_i),
 .pba_writedata_i(pba_writedata_i),
 .pba_burstcount_i(pba_burstcount_i),
 .pba_begintransfer_i(pba_begintransfer_i),
 .pba_beginbursttransfer_i(pba_beginbursttransfer_i),
 
 //Test
 .valid_loc_data_xfr(valid_loc_data_xfr),
 .lm_tsr_i(lm_tsr_i),
 //
 .pba_address_o(av_addr),
 
 .pci_address_i(pci_addr),
 .pci_address_vld_i(addr_trans_done),
 .pci_cmd_space_i(addr_space_type),
 .pci_ben_i(pci_ben_o),
 .read_wait(read_wait),
 
 .pci_address_o(pci_address_o),
 .pci_cmd_o(pci_cmd_o),
 .pci_ben_o(pci_ben_o),

 .pba_waitrequest_o(pba_waitrequest_o),

 .pba_write_state(pba_write_state),
 .pba_read_state(pba_read_state),

 .avl_mstr_wr_req(avl_mstr_wr_req),
 .avl_mstr_burst_o(avl_mstr_burst),
 .avl_mstr_rd_req(avl_mstr_rd_req),
 
 .pba_adr_vld_o(av_addr_vld),
 .rd_done_i(lm_lastn_o),
 .lb_write_state_rise_i(lb_write_state_rise),
 .lb_req_state_rise_i(lb_req_state_rise),
 .lb_busy_i(lb_busy),
 //.test(test),
 .avl_fifo_wr_req_o(avl_fifo_wr_req),
 //.unfinished_write_o(unfinished_write),
 //.unfinished_read_o(unfinished_read),
 .rdusedw_i(rdusedw),
 .fifo_empty_i(fifo_empty)
);

// instantiation of the read response module
altpciav_lite_pba_rdresp
  #(
   .CG_PCI_DATA_WIDTH(CG_PCI_DATA_WIDTH)
    )
pba_rdresp(
 .lm_adr_ackn_i(lm_adr_ackn_i),
 .lm_dxfrn_i(lm_dxfrn_i),
 .l_dato_i(l_dato_i),
 .pba_read_state(pba_read_state)

);

// instantiation of the address translation module

//wire AdTrReadVld_i =1;

 altpciav_lite_a2p_addrtrans
  #(
    .CB_A2P_ADDR_MAP_IS_FIXED(CB_A2P_ADDR_MAP_IS_FIXED),
    .CB_A2P_ADDR_MAP_NUM_ENTRIES(CB_A2P_ADDR_MAP_NUM_ENTRIES),
    .CB_A2P_ADDR_MAP_PASS_THRU_BITS(CB_A2P_ADDR_MAP_PASS_THRU_BITS),
    .CG_AVALON_S_ADDR_WIDTH(CG_AVALON_S_ADDR_WIDTH),
    .CG_PCI_ADDR_WIDTH(CG_PCI_ADDR_WIDTH),
    .CG_PCI_DATA_WIDTH(CG_PCI_DATA_WIDTH),
    .CB_A2P_ADDR_MAP_FIXED_TABLE(CB_A2P_ADDR_MAP_FIXED_TABLE)
    )


a2p_addr_trans
  (

    .PbaClk_i(pba_clk_i),        // Clock For Avalon to PCI Trans
    .PbaRstn_i(pba_rstn_i),       // Reset signal
    .PbaAddress_i(av_addr),    // Must be a byte specific address
    .PbaByteEnable_i(pba_byteenable_i),
    .PbaAddrVld_i(av_addr_vld),    // Valid indication in
    .PciAddr_o(pci_addr),       // Is a byte specific address
    .PciAddrSpace_o(addr_space_type),  // DAC Needed
    .PciAddrVld_o(addr_trans_done),    // Valid indication out (piped)
    .CraClk_i(pba_clk_i),        // Clock for register access port
//    .CraRstn_i(pba_rstn_i),       // Reset signal
    .AdTrAddress_i(AdTrAddress_i),   // Register (DWORD) specific address
    .AdTrByteEnable_i(AdTrByteEnable_i),// Register Byte Enables
    .AdTrWriteVld_i(AdTrWriteVld_i),  // Valid Write Cycle in
    .AdTrWriteData_i(AdTrWriteData_i), // Write Data in
    .AdTrReadVld_i(AdTrReadVld_i),   // Read Valid in
    .AdTrReadData_o(AdTrReadData_o),  // Read Data out
    .AdTrReadVld_o(AdTrReadVld_o)  // Read Valid out (piped)

  );

// Write data fifo
altpciav_lite_pba_wrfifo
 #(
   .CG_PCI_DATA_WIDTH(CG_PCI_DATA_WIDTH)

)
lite_pba_wrfifo
   (

 .pci_clk_i(pci_clk_i),
 .pci_rstn_i(pci_rstn_i),
 .pba_clk_i(pba_clk_i),
 .pba_rstn_i(pba_rstn_i),
 .pba_write_i(avl_fifo_wr_req),
 .pba_chipselect_i(pba_chipselect_i),
 .pba_byteenable_i(pba_byteenable_i),
 .pba_writedata_i(pba_writedata_i),

 .fifo_rd_req_i(fifo_rd_req),
 .fifo_data_o(fifo_data),
 .rdusedw_o(rdusedw),
 .fifo_empty_o(fifo_empty)
);




endmodule
