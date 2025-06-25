//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
//     Logic Core:             PCI Megacore Function
//     Company:                Altera Corporation.
//                             www.altera.com
//     Author :                PNSE Group
//			       
//     Description:    PCI Avalon Light PCI Bus Access Avalon Bus Module (Avalon side FSM)
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

module altpciav_lite_pba_wrfifo
  #(
    parameter CG_PCI_DATA_WIDTH = 32
    )
(

pci_clk_i,
pci_rstn_i,

pba_clk_i,
pba_rstn_i,
pba_write_i,
pba_chipselect_i,
pba_byteenable_i,
pba_writedata_i,

fifo_rd_req_i,

fifo_data_o,
fifo_empty_o,
rdusedw_o
);

// Port Declaration
input pci_clk_i;
input pci_rstn_i;

input pba_clk_i;
input pba_rstn_i;

input pba_write_i;
input pba_chipselect_i;
input [(CG_PCI_DATA_WIDTH/8)-1 : 0]pba_byteenable_i;
input [CG_PCI_DATA_WIDTH-1 : 0]pba_writedata_i;

input fifo_rd_req_i;

output [CG_PCI_DATA_WIDTH-1 : 0]fifo_data_o;
output fifo_empty_o;
output [7:0]rdusedw_o;

wire [35:0]  wr_data;
wire wr_req;
wire rd_req;


assign wr_req = pba_write_i & pba_chipselect_i;
assign wr_data = {~(pba_byteenable_i), pba_writedata_i};

assign rd_req = fifo_rd_req_i;

altpciav_lite_fifo
  #(
    .COMMON_CLOCK(1) ,
    .ADDR_WIDTH(7) ,
    .DATA_WIDTH(36)  ,
    .USE_RAM_OUTPUT_REGISTER(1)
    )
 low_data_fifo (
                                .wrclk (pba_clk_i),
                                .rdreq (rd_req),
                                .aclr (~pba_rstn_i),
                                .rdclk (pci_clk_i),
                                .wrreq (wr_req),
                                .data (wr_data),
                                .rdempty (fifo_empty_o),
                                .wrusedw (),
                                .q(fifo_data_o),
                                .rdusedw (rdusedw_o)
                                );

endmodule
