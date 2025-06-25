//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
//     Logic Core:             PCI/Avalon Bridge Lite Function
//     Company:                Altera Corporation.
//                             www.altera.com
//     Author :                Penang IP Group Ong Hui Leang
//
//     Description:    PCI Avalon Light Avalon Master Module
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

module altpciav_lite_master 
#(  
    parameter  CG_PCI_TARGET_ONLY = 0,
    parameter  CG_PCI_DATA_WIDTH = 64,
    parameter  CG_AVALON_M_ADDR_WIDTH = 32,
    parameter  CB_P2A_PREF_DISCARD_CYCLES = 2047,
    parameter  CPCICOMP_NUMBER_OF_BARS = 1,
    parameter  CB_P2A_MR_INIT_DWORDS_B0 = 8
  ) 
    
( 
  input                                PciClk_i,
  input                                Rstn_i,
  
  // PCI core interface
  input                                LtFramen_i,
  input                                LtDxfrn_i,
  input [11:0]                         LtTsr_i,
  input [3:0]                          LtCmd_i,
  input [31:0]                         LtAddr_i,
  input [CG_PCI_DATA_WIDTH-1 : 0]      LtDat_i,
  input [(CG_PCI_DATA_WIDTH/8)-1 : 0]  LtBen_i,
  output                               LtRdyn_o,
  output                               LtDiscn_o,
  output                               LtAbortn_o,
  output [CG_PCI_DATA_WIDTH-1 : 0]     LtDat_o,

  //  for 64-bit core implementation
  //  input                                LdatAckn_i,
  //  input                                HdatAckn_i,
  
  // Avalom PM port interface
  input                                 PmClk_i,
  input                                 PmRstn_i,
  input                                 PmWaitRequest_i,
  input                                 PmReadDataValid_i,
  input   [CG_PCI_DATA_WIDTH-1 : 0]     PmReadData_i,
  output                                PmWrite_o,
  output [CG_AVALON_M_ADDR_WIDTH-1 : 0] PmAddr_o,
  output [CG_PCI_DATA_WIDTH-1 : 0]      PmWriteData_o,
  output [(CG_PCI_DATA_WIDTH/8)-1 : 0]  PmByteEnable_o,
  output [7:0]                          PmBurstCount_o,
  output                                PmRead_o,
  output                                PmBeginBurstTransfer_o,
  output                                PmBeginTransfer_o,
  
// parameter inputs
  input [31:0]                        cpcicomp_bar0_i,
  input [31:0]                        cpcicomp_bar1_i,
  input [31:0]                        cpcicomp_bar2_i,
  input [31:0]                        cpcicomp_bar3_i,
  input [31:0]                        cpcicomp_bar4_i,
  input [31:0]                        cpcicomp_bar5_i,
  input [31:0]                        cpcicomp_exp_rom_bar_i,
  input [31:0]                        cb_p2a_avalon_addr_b0_i,
  input [31:0]                        cb_p2a_avalon_addr_b1_i,
  input [31:0]                        cb_p2a_avalon_addr_b2_i,
  input [31:0]                        cb_p2a_avalon_addr_b3_i,
  input [31:0]                        cb_p2a_avalon_addr_b4_i,
  input [31:0]                        cb_p2a_avalon_addr_b5_i,
  input [31:0]                        cb_p2a_avalon_addr_b6_i,
  input [4:0]                         cb_p2a_nonp_max_init_lat_i,
  
  output [2:0]                        baractive
);

//command data reg
  wire [17:0]                         rwinfo_header_fr_pci;
  wire [CG_PCI_DATA_WIDTH-1:0]        avl_addr_header_fr_pci;
  wire [(CG_PCI_DATA_WIDTH/8)-1 : 0]  ben_header_fr_pci;
  wire [CG_PCI_DATA_WIDTH-1:0]        wr_data_fr_pci;
  wire                                cdreg_wr_fr_pci;
  wire                                cdreg_rd_fr_pci;
  wire                                avl_rdreq_fr_pci;
  wire [7:0]                          wrfifo_dat_avail;
  wire [7:0]                          rdfifo_dat_avail;
  wire	                              fifo_rd_req;
  wire	                              avl_wr_done;
  wire	                              avl_rd_done;
  wire	                              rdfifo_flush;
  wire				      rdfifo_data_req;

  wire [17:0]                         rwinfo_to_avl;
  wire [CG_PCI_DATA_WIDTH-1:0]        avl_addr_to_avl;
  wire [(CG_PCI_DATA_WIDTH/8)-1 : 0]  ben_to_avl;
  wire [((CG_PCI_DATA_WIDTH/8) + CG_PCI_DATA_WIDTH) -1:0]        wr_data_to_avl;
  wire [CG_PCI_DATA_WIDTH-1:0]        rd_data_fr_avl;
  wire [CG_PCI_DATA_WIDTH-1:0]        rd_data_to_pci;
  wire [CG_PCI_DATA_WIDTH-1:0]        rdfifo_data;
  wire                                rddata_valid_fr_avl;
  

//////////////////////////////////////////////////////////////////////////////     
/////                 MASTER PCI CONTROL                     /////////////////     
//////////////////////////////////////////////////////////////////////////////
altpciav_lite_mpci_cntrl                                                                                                                           
#(                              
    .CG_PCI_TARGET_ONLY(CG_PCI_TARGET_ONLY),                                                                                     
    .CG_PCI_DATA_WIDTH(CG_PCI_DATA_WIDTH),
    .CB_P2A_PREF_DISCARD_CYCLES(CB_P2A_PREF_DISCARD_CYCLES),
    .CPCICOMP_NUMBER_OF_BARS(CPCICOMP_NUMBER_OF_BARS),                         
    .CB_P2A_MR_INIT_DWORDS_B0(CB_P2A_MR_INIT_DWORDS_B0)                                                                                                                 
  )                                                                                            
master_pci_cntrl                                                                                
(    
    .PciClk_i(PciClk_i),
    .Rstn_i(Rstn_i),
    
    // PCI core interface
    .LtFramen_i(LtFramen_i),
    .LtDxfrn_i(LtDxfrn_i),
    .LdatAckn_i(1'b1),
    .HdatAckn_i(1'b1),
    .LtTsr_i(LtTsr_i),
    .LtCmd_i(LtCmd_i),
    .LtAddr_i(LtAddr_i),
    .LtDat_i(LtDat_i),
    .LtBen_i(LtBen_i),
    .LtRdyn_o(LtRdyn_o),
    .LtDiscn_o(LtDiscn_o),
    .LtAbortn_o(LtAbortn_o),
    .LtDat_o(LtDat_o),

     // parameter inputs
    .cpcicomp_bar0_i(cpcicomp_bar0_i), 
    .cpcicomp_bar1_i(cpcicomp_bar1_i),
    .cpcicomp_bar2_i(cpcicomp_bar2_i),
    .cpcicomp_bar3_i(cpcicomp_bar3_i),
    .cpcicomp_bar4_i(cpcicomp_bar4_i),
    .cpcicomp_bar5_i(cpcicomp_bar5_i),
    .cpcicomp_exp_rom_bar_i(cpcicomp_exp_rom_bar_i),
    .cb_p2a_avalon_addr_b0_i(cb_p2a_avalon_addr_b0_i),
    .cb_p2a_avalon_addr_b1_i(cb_p2a_avalon_addr_b1_i),
    .cb_p2a_avalon_addr_b2_i(cb_p2a_avalon_addr_b2_i),
    .cb_p2a_avalon_addr_b3_i(cb_p2a_avalon_addr_b3_i),
    .cb_p2a_avalon_addr_b4_i(cb_p2a_avalon_addr_b4_i),
    .cb_p2a_avalon_addr_b5_i(cb_p2a_avalon_addr_b5_i),
    .cb_p2a_avalon_addr_b6_i(cb_p2a_avalon_addr_b6_i),
    .cb_p2a_nonp_max_init_lat_i(cb_p2a_nonp_max_init_lat_i),

    //command data reg
    .avl_rddata_ready_i(rddata_valid_fr_avl), 
    .avl_rdfifo_data_avail_i(rdfifo_dat_avail),
    .rd_data_i(rd_data_to_pci),
    .rd_fifo_data_i(rdfifo_data),
    .rd_fifo_data_req_o(rdfifo_data_req),
    .rwinfo_header_o(rwinfo_header_fr_pci),
    .avl_addr_header_o(avl_addr_header_fr_pci),
    .ben_header_o(ben_header_fr_pci),
    .wr_data_o(wr_data_fr_pci),
    .cdreg_rd(cdreg_rd_fr_pci),
    .cdreg_wr(cdreg_wr_fr_pci),
    .avl_rdreq(avl_rdreq_fr_pci),
    .avl_wr_done_i(avl_wr_done),
    .avl_rd_done_i(avl_rd_done),
    .rdfifo_flush_o(rdfifo_flush),
    .BarActive(baractive)
);

//////////////////////////////////////////////////////////////////////////////     
/////                 MASTER CD CONTROL                       /////////////////     
//////////////////////////////////////////////////////////////////////////////
altpciav_lite_mcd
#(
    .CG_PCI_DATA_WIDTH(CG_PCI_DATA_WIDTH)
  )
master_cd
(
    //input 
    .PciClk_i(PciClk_i),
    .Rstn_i(Rstn_i),
    .rwinfo_header_i(rwinfo_header_fr_pci),
    .avl_addr_header_i(avl_addr_header_fr_pci),
    .ben_header_i(ben_header_fr_pci),
    .wr_data_i(wr_data_fr_pci),
    .cdreg_rd_i(cdreg_rd_fr_pci),
    .cdreg_wr_i(cdreg_wr_fr_pci),
    .rd_data_i(rd_data_fr_avl),
    .rddata_ready_i(rddata_valid_fr_avl),
 
    //output
    .rwinfo_reg_o(rwinfo_to_avl),
    .avl_addr_reg_o(avl_addr_to_avl),
    .ben_reg_o(ben_to_avl),
    .rd_data_reg_o(rd_data_to_pci)
  );

//////////////////////////////////////////////////////////////////////////////     
/////                 MASTER AVL CONTROL                     /////////////////     
//////////////////////////////////////////////////////////////////////////////

altpciav_lite_mavl_cntrl 
#(
    .CG_PCI_DATA_WIDTH(CG_PCI_DATA_WIDTH),
    .CG_AVALON_M_ADDR_WIDTH(CG_AVALON_M_ADDR_WIDTH)
  ) 

master_avl_cntrl
( 
    .PciClk_i(PciClk_i),
    .Rstn_i(Rstn_i),
  
 // Avalon Interface
    .PmClk_i(PciClk_i),
    .PmRstn_i(Rstn_i),
    .PmWaitRequest_i(PmWaitRequest_i),
    .PmReadDataValid_i(PmReadDataValid_i),
    .PmReadData_i(PmReadData_i),
    .PmWrite_o(PmWrite_o),
    .PmAddr_o(PmAddr_o),
    .PmWriteData_o(PmWriteData_o),
    .PmByteEnable_o(PmByteEnable_o),
    .PmBurstCount_o(PmBurstCount_o),
    .PmRead_o(PmRead_o),
    .PmBeginBurstTransfer_o(PmBeginBurstTransfer_o),
    .PmBeginTransfer_o(PmBeginTransfer_o),
    .BarActive(baractive),

 // command data register
    .rwinfo_i(rwinfo_to_avl),
    .avl_addr_i(avl_addr_to_avl),
    .ben_i(ben_to_avl),
    .wr_data_i(wr_data_to_avl),
    .avl_wrreq(cdreg_rd_fr_pci),
    .avl_rdreq(avl_rdreq_fr_pci),
    .rd_data_o(rd_data_fr_avl),
    .rddata_valid_o(rddata_valid_fr_avl),
    .fifo_dat_avail_i(wrfifo_dat_avail), 
    .fifo_rd_req_o(fifo_rd_req), 
    .avl_wr_done_o(avl_wr_done),
    .avl_rd_done_o(avl_rd_done) 
);

// Write data fifo
altpciav_lite_fifo
  #(
    .COMMON_CLOCK(1) ,
    .ADDR_WIDTH(7) ,
    .DATA_WIDTH(36),
    .USE_RAM_OUTPUT_REGISTER(1)
    )
lite_mpci_wrfifo (
                                .wrclk (PciClk_i),
                                .rdreq ( fifo_rd_req |(PmWrite_o & ~PmWaitRequest_i)),
                                .aclr (~Rstn_i),
                                .rdclk (PciClk_i),
                                .wrreq (rwinfo_header_fr_pci[16] & ~LtDxfrn_i),
                                .data ({LtBen_i, LtDat_i}),
                                .rdempty (),
                                .wrusedw (),
                                .q(wr_data_to_avl),
                                .rdusedw (wrfifo_dat_avail)
                                );


// Read resp fifo
altpciav_lite_fifo
  #(
    .COMMON_CLOCK(1) ,
    .ADDR_WIDTH(7) ,
    .DATA_WIDTH(32)  ,
    .USE_RAM_OUTPUT_REGISTER(1)
    )
lite_mpci_rdfifo (
                                .wrclk (PciClk_i),
                                .rdreq (rdfifo_data_req ),
                                .aclr (~Rstn_i | rdfifo_flush),
                                .rdclk (PciClk_i),
                                .wrreq (rddata_valid_fr_avl),
                                .data (rd_data_fr_avl),
                                .rdempty (),
                                .wrusedw (),
                                .q(rdfifo_data),
                                .rdusedw (rdfifo_dat_avail)
                                );

endmodule
