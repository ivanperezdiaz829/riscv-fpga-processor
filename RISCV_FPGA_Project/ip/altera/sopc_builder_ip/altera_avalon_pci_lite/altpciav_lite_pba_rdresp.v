//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
//     Logic Core:             PCI Megacore Function
//     Company:                Altera Corporation.
//                             www.altera.com
//     Author :                PNSE Group
//
//     Description:    PCI Avalon Light PCI Bus Access Read Response Module
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

module altpciav_lite_pba_rdresp 
  #(
    parameter CG_PCI_DATA_WIDTH = 32
    )
(
 l_dato_i,
 lm_dxfrn_i,
 lm_adr_ackn_i,
 pba_waitrequest_o,
 pba_readdatavalid_o,

 pba_read_state
);

//port declaration
input [CG_PCI_DATA_WIDTH-1 : 0]l_dato_i;
input lm_dxfrn_i;
input lm_adr_ackn_i;
output pba_readdatavalid_o;
output pba_waitrequest_o;
input pba_read_state;



assign pba_waitrequest_o = lm_adr_ackn_i;
assign pba_readdatavalid_o = pba_read_state & ~lm_dxfrn_i;

endmodule
