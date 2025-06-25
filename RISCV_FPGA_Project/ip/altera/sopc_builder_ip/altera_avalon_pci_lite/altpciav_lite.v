//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
//     Logic Core:             PCI Megacore Function
//     Company:                Altera Corporation.
//                             www.altera.com
//     Author :                PNSE Group
//			       
//     Description:    PCI Avalon Light Top Level Module
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
//`define RTL_VERIFICATION

module altpciav_lite(
               // system global signals
               clk,
               // PCI signals
               gntn,
               idsel,
               framen,
               irdyn,
               devseln,
               trdyn,
               stopn,
               //req64n,
               //ack64n,
               intan,
               reqn,
               serrn,
               ad,
               cben,
               par,
               //par64,
               perrn,

               // Avalon Non-Prefechable port signals
               AvlClk_i,
               rstn,
               NpmIrq_i,

              // Avalon slave port for bursting to PCI
               PbaChipSelect_i,
               PbaAddress_i,
               PbaByteEnable_i,
               PbaRead_i,
               PbaReadData_o,
               PbaWrite_i,
               PbaWriteData_i,
               PbaReadDataValid_o,
               PbaWaitRequest_o,
               PbaBurstCount_i,
               PbaBeginTransfer_i,
               PbaBeginBurstTransfer_i,
               PbaResetRequest_o,

              // PCI to Avalon Prefetchable
               PmAddress_o,
               PmByteEnable_o,
               PmRead_o,
               PmReadData_i,
               PmWrite_o,
               PmWriteData_o,
               PmReadDataValid_i,
               PmWaitRequest_i,
               PmBurstCount_o,
               PmBeginTransfer_o,
               PmBeginBurstTransfer_o,
               PmIrq_i,
               PmResetRequest_o,

               // Control Register Avalon Slave Ports
               CraChipSelect_i,
               CraAddress_i,
               CraByteEnable_i,
               CraRead_i,
               CraReadData_o,
               CraWrite_i,
               CraWriteData_i,
               CraWaitRequest_o,
               //CraIrq_o,
               CraBeginTransfer_i,
               CraResetRequest_o,
               
               BarActive_o
);

function integer clogb2;
      input [31:0] depth;
      begin
         depth = depth - 1 ;
         for (clogb2 = 0; depth > 0; clogb2 = clogb2 + 1)
           depth = depth >> 1 ;
      end
   endfunction // clogb2



// All Parameters for the altpciav_lite
// Note: Not All Parameters are used in the altpciav_lite, however, all
// parameters are defined in order to re-use the same Software Model that generates pci_compiler.v

// PCI core parameters
parameter CPCICOMP_DEVICE_ID = 16'h0004;
parameter CPCICOMP_CLASS_CODE = 24'hFF0000;
parameter CPCICOMP_MAX_LATENCY = 8'h00;
parameter CPCICOMP_MIN_GRANT = 8'h00;
parameter CPCICOMP_REVISION_ID = 8'h01;
parameter CPCICOMP_SUBSYSTEM_ID = 16'h0000;
parameter CPCICOMP_SUBSYSTEM_VEND_ID = 16'h0000;
parameter CPCICOMP_VEND_ID = 16'h1172;
parameter CPCICOMP_BAR0 = 32'hFFF00008;
parameter CPCICOMP_BAR1 = 32'hFFF00000;
parameter CPCICOMP_BAR2 = 32'hFFF00008;
parameter CPCICOMP_BAR3 = 32'hFFF00008;
parameter CPCICOMP_BAR4 = 32'hFFF00008;
parameter CPCICOMP_BAR5 = 32'hFFF00008;
parameter CPCICOMP_EXP_ROM_BAR = 32'hFFF0000;
parameter CPCICOMP_NUMBER_OF_BARS = 2;
parameter CPCICOMP_HARDWIRE_BAR0 = 32'hFFF00000;
parameter CPCICOMP_HARDWIRE_BAR1 = 32'hFFF00000;
parameter CPCICOMP_HARDWIRE_BAR2 = 32'hFFF00000;
parameter CPCICOMP_HARDWIRE_BAR3 = 32'hFFF00000;
parameter CPCICOMP_HARDWIRE_BAR4 = 32'hFFF00000;
parameter CPCICOMP_HARDWIRE_BAR5 = 32'hFFF00000;
parameter CPCICOMP_HARDWIRE_EXP_ROM_BAR = 32'hFFF0000;
parameter CPCICOMP_CAP_PTR = 8'h40;
parameter CPCICOMP_CIS_PTR = 32'h00000000;
parameter CPCICOMP_ENABLE_BITS = 32'h00000000;
parameter CPCICOMP_INTERRUPT_PIN_REG = 8'h01;
parameter CPCICOMP_PCI_66MHZ_CAPABLE = "YES";

//Bridge parameters           
parameter CB_P2A_SUPPORT_IO_TRANS = 0;
parameter CG_IMPL_PREF_NONP_INDEPENDENT = 0;
parameter CG_IMPL_PCI_AVL_LITE = 0;
parameter CB_P2A_NONP_IGNORE_INIT_LAT = 0;
parameter CB_P2A_NONP_MAX_INIT_LAT = (CG_IMPL_PREF_NONP_INDEPENDENT == 1)? 5'h17 : 5'h17;
parameter CB_P2A_NONP_DISCARD_CYCLES = 32768;
parameter CB_P2A_AVALON_ADDR_B0 = 32'h00000000;
parameter CB_P2A_AVALON_ADDR_B1 = 32'h00000000;
parameter CB_P2A_AVALON_ADDR_B2 = 32'h00000000;
parameter CB_P2A_AVALON_ADDR_B3 = 32'h00000000;
parameter CB_P2A_AVALON_ADDR_B4 = 32'h00000000;
parameter CB_P2A_AVALON_ADDR_B5 = 32'h00000000;
parameter CB_P2A_AVALON_ADDR_B6 = 32'h00000000;


///// performance profile parameters and core configuration
parameter CG_HOST_BRIDGE_MODE = 0;
parameter CG_PCI_DATA_WIDTH = 32;
parameter CG_COMMON_CLOCK_MODE = 0;
parameter CG_PCI_TARGET_ONLY = 1;
parameter CB_P2A_PERF_PROFILE = 1;
parameter CB_P2A_NUM_PNDG_READS = (CB_P2A_PERF_PROFILE == 3)?  4 : 1;
parameter CB_A2P_PERF_PROFILE = 1;
parameter CB_A2P_NUM_PNDG_READS = (CB_A2P_PERF_PROFILE == 3)?  4 : 1;
parameter CG_IMPL_CRA_AV_SLAVE_PORT = 0;
parameter CG_IMPL_PREF_AV_MASTER_PORT = 1;
parameter CG_IMPL_NONP_AV_MASTER_PORT = 1;
//////////////////////////////////////////////////////////////////////////
parameter CB_A2P_CD_BUFFER_DEPTH = 128;
parameter INTENDED_DEVICE_FAMILY = "Stratix";
parameter CB_A2P_NUM_BYPASSABLE_READS = 4;
parameter CB_A2P_ADDR_MAP_PASS_THRU_BITS = 19;
parameter CB_A2P_ADDR_MAP_IS_FIXED = 1;
parameter CB_A2P_ADDR_MAP_NUM_ENTRIES = 2;
parameter CG_AVALON_S_ADDR_WIDTH = 20;
parameter [1023:0] CB_A2P_ADDR_MAP_FIXED_TABLE = {{896{1'b0}},64'h0000000000080000,{64{1'b0}}};
parameter CG_PCI_ADDR_WIDTH = CG_PCI_DATA_WIDTH;
parameter CB_A2P_RESP_BUFFER_DEPTH = 128;
parameter CB_A2P_CD_WRITE_THRESHOLD = 8;
parameter CB_A2P_WRITE_FAIL_FLUSH_ENA = 1;
parameter CG_ALLOW_JTAG_PARM_MOD = 0;
parameter CG_ALLOW_PARM_READBACK = 0;
parameter CB_A2P_ADDR_MAP_IS_READABLE = 1;
parameter CB_A2P_RESP_BUFFER_THRESHOLD = 128;
parameter CG_AVALON_M_ADDR_WIDTH = 32;
parameter CB_A2P_MAX_PCI_RETRY = 32768;
parameter CB_P2A_BURST_BOUNDARY_B0 = 8;
parameter CB_P2A_BURST_BOUNDARY_B1 = 8;
parameter CB_P2A_BURST_BOUNDARY_B2 = 8;
parameter CB_P2A_BURST_BOUNDARY_B3 = 8;
parameter CB_P2A_BURST_BOUNDARY_B4 = 8;
parameter CB_P2A_BURST_BOUNDARY_B5 = 8;

parameter CB_P2A_MR_INIT_DWORDS_B0 = CG_PCI_DATA_WIDTH/32;
parameter CB_P2A_MR_INIT_DWORDS_B1 = CG_PCI_DATA_WIDTH/32;
parameter CB_P2A_MR_INIT_DWORDS_B2 = CG_PCI_DATA_WIDTH/32;
parameter CB_P2A_MR_INIT_DWORDS_B3 = CG_PCI_DATA_WIDTH/32;
parameter CB_P2A_MR_INIT_DWORDS_B4 = CG_PCI_DATA_WIDTH/32;
parameter CB_P2A_MR_INIT_DWORDS_B5 = CG_PCI_DATA_WIDTH/32;

parameter CB_P2A_MRL_REF_BURSTS_B0 = 1;
parameter CB_P2A_MRL_REF_BURSTS_B1 = 1;
parameter CB_P2A_MRL_REF_BURSTS_B2 = 1;
parameter CB_P2A_MRL_REF_BURSTS_B3 = 1;
parameter CB_P2A_MRL_REF_BURSTS_B4 = 1;
parameter CB_P2A_MRL_REF_BURSTS_B5 = 1;
parameter CB_P2A_MRM_REF_BURSTS_B0 = 2;
parameter CB_P2A_MRM_REF_BURSTS_B1 = 2;
parameter CB_P2A_MRM_REF_BURSTS_B2 = 2;
parameter CB_P2A_MRM_REF_BURSTS_B3 = 2;
parameter CB_P2A_MRM_REF_BURSTS_B4 = 2;
parameter CB_P2A_MRM_REF_BURSTS_B5 = 2;
parameter CB_P2A_REF_THRESHOLD_B0 = 4;
parameter CB_P2A_REF_THRESHOLD_B1 = 4;
parameter CB_P2A_REF_THRESHOLD_B2 = 4;
parameter CB_P2A_REF_THRESHOLD_B3 = 4;
parameter CB_P2A_REF_THRESHOLD_B4 = 4;
parameter CB_P2A_REF_THRESHOLD_B5 = 4;
parameter CB_P2A_PREF_DISCARD_CYCLES = 2047;
parameter CB_P2A_RESP_BUFFER_DEPTH = 128;
parameter CB_A2P_READ_FAIL_COMPLETE_ENA = 1;
parameter CB_P2A_CD_BUFFER_DEPTH = 128;

parameter CG_PCI_ARB_NUM_REQ_GNT = 5;
parameter CG_IMPL_PCI_ARBITER = 0;           


parameter PNTR_WIDTH = (CB_P2A_NUM_PNDG_READS == 4)? 2 : 1;   

// derived parameters
parameter CG_PCI_BEN_WIDTH = CG_PCI_DATA_WIDTH >> 3;
parameter CG_PCI_CORE_TYPE = CG_PCI_TARGET_ONLY + CG_PCI_DATA_WIDTH;
                                   
parameter BUFF_ADDR_WIDTH = 7;                               
parameter A2P_ORDER_WIDTH = BUFF_ADDR_WIDTH + PNTR_WIDTH + 4;
parameter BOUNDARY_CNTR_WIDTH = clogb2(CB_P2A_BURST_BOUNDARY_B0);


//////////////////////////////////////////
// Port Declaration
//////////////////////////////////////////
// Global signals
input clk;

// PCI signals
input  gntn;
input  idsel;
inout  framen;
inout  irdyn;
inout  devseln;
inout  trdyn;
inout  stopn;
//inout  req64n;
//inout  ack64n;
inout intan;
inout  serrn;
inout  [CG_PCI_DATA_WIDTH-1:0] ad;
inout  [CG_PCI_BEN_WIDTH-1:0] cben;
inout  par;
//inout  par64;
inout  perrn;
output reqn;

// Avalon Non-Prefechable Master port signals
input AvlClk_i;
input rstn;
input  NpmIrq_i;

// Avalon PCI Bus Access Slave port signals
input                                   PbaChipSelect_i;
input  [CG_AVALON_S_ADDR_WIDTH-1:(CG_PCI_DATA_WIDTH/32)+1]  PbaAddress_i;
input  [(CG_PCI_DATA_WIDTH/8)-1 : 0]    PbaByteEnable_i;
input                                   PbaRead_i;
input                                   PbaWrite_i;
input  [CG_PCI_DATA_WIDTH-1 : 0]        PbaWriteData_i;
input  [7:0]                            PbaBurstCount_i;
input                                   PbaBeginTransfer_i;
input                                   PbaBeginBurstTransfer_i;
output  [CG_PCI_DATA_WIDTH-1 : 0]       PbaReadData_o;
output                                  PbaReadDataValid_o;
output                                  PbaWaitRequest_o;

// Avalon Prefechable Master port signals
input   [CG_PCI_DATA_WIDTH-1:0]         PmReadData_i;
input                                   PmReadDataValid_i;
input                                   PmWaitRequest_i;
input                                   PmIrq_i;
output  [31:0]                          PmAddress_o;
output  [(CG_PCI_DATA_WIDTH/8)-1:0]     PmByteEnable_o;
output                                  PmRead_o;
output                                  PmWrite_o;
output  [CG_PCI_DATA_WIDTH-1:0]         PmWriteData_o;
output  [7:0]                           PmBurstCount_o;
output                                  PmBeginTransfer_o;
output                                  PmBeginBurstTransfer_o;

// Control register Avalon slave ports
input                                   CraChipSelect_i;
input  [13:2]                           CraAddress_i;
input  [3:0]                            CraByteEnable_i;
input                                   CraRead_i;
output  [31:0]                           CraReadData_o;
input                                   CraWrite_i;
input  [31:0]                           CraWriteData_i;
output                                  CraWaitRequest_o;
//output                                  CraIrq_o;
input                                   CraBeginTransfer_i;

// Avalon Reset request signals
output                                  PmResetRequest_o ;
output                                  CraResetRequest_o;
output                                  PbaResetRequest_o;
output [2:0]                                 BarActive_o;

//////////////////////////////////////////
// Wire and Regs
//////////////////////////////////////////
wire [CG_PCI_BEN_WIDTH-1:0] l_cbeni;    
wire  [CG_PCI_DATA_WIDTH-1:0] l_adi;      
wire lm_req32n;  
wire lm_lastn;  
wire lm_rdyn;    
wire lt_rdyn ;    
wire lt_abortn;  
wire lt_discn;   
wire lirqn;      
wire [CG_PCI_DATA_WIDTH-1:0] l_adro;     
wire [CG_PCI_DATA_WIDTH-1:0] l_dato;     
wire [CG_PCI_BEN_WIDTH-1:0] l_beno;     
wire [3:0] l_cmdo;     
//wire l_ldat_ackn;
//wire l_hdat_ackn;
wire lm_adr_ackn;
wire lm_ackn;   
wire lm_dxfrn;  
wire [9:0] lm_tsr;     
wire [6:0] stat_reg;
wire [6:0] cmd_reg;
wire lt_framen;  
wire lt_ackn;    
wire lt_dxfrn;   
wire [11:0] lt_tsr;
wire [7:0] cache;

wire [CG_PCI_DATA_WIDTH-1:0] p_l_adi;
wire [CG_PCI_DATA_WIDTH-1:0] mstr_l_adi;

wire            cr_wrreq_vld;   // Valid Write Cycle to AddrTrans  
wire            cr_rdreq_vld;   // Read Valid out to AddrTrans
wire   [11:2]   cr_addr;        // Address to AddrTrans
wire   [31:0]   cr_wrdat;       // Write Data to AddrTrans
wire   [3:0]    cr_bena;        // Write Byte Enables to AddrTrans
wire   [31:0]         cr_rddat;       // Read Data in from AddrTrans
wire            cr_rddat_vld_sig;  // Read Valid in from AddrTrans

//////////////////////////////////////////////////////////////////////////////     
/////                    PCI CORE                            /////////////////     
//////////////////////////////////////////////////////////////////////////////
`ifdef RTL_VERIFICATION
                                                                                                                                                                                                     
                                                                                                                                                                                                     
generate
  case (CG_PCI_CORE_TYPE)
    32:  // MT32
begin
    pci_megacore pci_core_mt32
      (
            .clk(clk),
                  .rstn(rstn),
                  .gntn(gntn),
                  .l_cbeni(l_cbeni),
                  .idsel(idsel),
                  .l_adi(l_adi),
                  .lm_req32n(lm_req32n),
                  .lm_lastn(lm_lastn),
                  .lm_rdyn(lm_rdyn),
                  .lt_rdyn(lt_rdyn),
                  .lt_abortn(lt_abortn),
                  .lt_discn(lt_discn),
                  .lirqn(lirqn),
                  .framen(framen),
                  .irdyn(irdyn),
                  .devseln(devseln),
                  .trdyn(trdyn),
                  .stopn(stopn),
                  .intan(intan),
                  .reqn(reqn),
                  .serrn(serrn),
                  .l_adro(l_adro),
                  .l_dato(l_dato),
                  .l_beno(l_beno),
                  .l_cmdo(l_cmdo),
                  .lm_adr_ackn(lm_adr_ackn),
                  .lm_ackn(lm_ackn),
                  .lm_dxfrn(lm_dxfrn),
                  .lm_tsr(lm_tsr),
                  .cache(cache),
                  .cmd_reg(cmd_reg),
                  .stat_reg(stat_reg),
                  .lt_framen(lt_framen),
                  .lt_ackn(lt_ackn),
                  .lt_dxfrn(lt_dxfrn),
                  .lt_tsr(lt_tsr),
                  .ad(ad),
                  .cben(cben),
                  .par(par),
                  .perrn(perrn)
              );
                                                                                                                                                                                                     
   //assign l_ldat_ackn = 1'b0;
   //assign l_hdat_ackn = 1'b1;
end
                                                                                                                                                                                                     
   33:  // T32
   begin
    pci_megacore pci_core_t32
      (
            .clk(clk),
                  .rstn(rstn),
                  .idsel(idsel),
                  .l_adi(l_adi),
                  .lt_rdyn(lt_rdyn),
                  .lt_abortn(lt_abortn),
                  .lt_discn(lt_discn),
                  .lirqn(lirqn),
                  .framen(framen),
                  .irdyn(irdyn),
                  .devseln(devseln),
                  .trdyn(trdyn),
                  .stopn(stopn),
                  .intan(intan),
                  .serrn(serrn),
                  .l_adro(l_adro),
                  .l_dato(l_dato),
                  .l_beno(l_beno),
                  .l_cmdo(l_cmdo),
                  .cmd_reg(cmd_reg),
                  .stat_reg(stat_reg),
                  .lt_framen(lt_framen),
                  .lt_ackn(lt_ackn),
                  .lt_dxfrn(lt_dxfrn),
                  .lt_tsr(lt_tsr),
                  .ad(ad),
                  .cben(cben),
                  .par(par),
                  .perrn(perrn)
              );
                                                                                                                                                                                                     
   //assign l_ldat_ackn = 1'b0;
   //assign l_hdat_ackn = 1'b1;
   assign reqn = 1'b1;
    end

    endcase
endgenerate
                                                                                                                                                                                                     
`else           /////// NOT RTL VERIFICATION

generate
  case (CG_PCI_CORE_TYPE)
    32:  // MT32
begin
  pci_mt32     pci_mt32_inst(
                .clk(clk),
                .rstn(rstn),
                .gntn(gntn),
                .idsel(idsel),
                .l_adi(l_adi),
                .l_cbeni(l_cbeni),
                .lm_req32n(lm_req32n),
                .lm_lastn(lm_lastn),
                .lm_rdyn(lm_rdyn),
                .lt_rdyn(lt_rdyn),
                .lt_abortn(lt_abortn),
                .lt_discn(lt_discn),
                .lirqn(lirqn),
                .framen_in(framen),
                .irdyn_in(irdyn),
                .devseln_in(devseln),
                .trdyn_in(trdyn),
                .stopn_in(stopn),
                .intan(intan),
                .reqn(reqn),
                .serrn(serrn),
                .l_adro(l_adro),
                .l_dato(l_dato),
                .l_beno(l_beno),
                .l_cmdo(l_cmdo),
                .lm_adr_ackn(lm_adr_ackn),
                .lm_ackn(lm_ackn),
                .lm_dxfrn(lm_dxfrn),
                .lm_tsr(lm_tsr),
                .lt_framen(lt_framen),
                .lt_ackn(lt_ackn),
                .lt_dxfrn(lt_dxfrn),
                .lt_tsr(lt_tsr),
                .cmd_reg(cmd_reg),
                .stat_reg(stat_reg),
                .cache(cache),
                .framen_out(framen),
                .irdyn_out(irdyn),
                .devseln_out(devseln),
                .trdyn_out(trdyn),
                .stopn_out(stopn),
                .ad(ad),
                .cben(cben),
                .par(par),
                .perrn(perrn));
                                                                                                                                                                                                     
       
       	defparam
                pci_mt32_inst.CLASS_CODE = CPCICOMP_CLASS_CODE,
                pci_mt32_inst.DEVICE_ID = CPCICOMP_DEVICE_ID,
                pci_mt32_inst.REVISION_ID = CPCICOMP_REVISION_ID,
                pci_mt32_inst.SUBSYSTEM_ID = CPCICOMP_SUBSYSTEM_ID,
                pci_mt32_inst.SUBSYSTEM_VENDOR_ID = CPCICOMP_SUBSYSTEM_VEND_ID,
                pci_mt32_inst.TARGET_DEVICE = "NEW",
                pci_mt32_inst.VENDOR_ID = CPCICOMP_VEND_ID,
                pci_mt32_inst.MIN_GRANT = CPCICOMP_MIN_GRANT,
                pci_mt32_inst.MAX_LATENCY = CPCICOMP_MAX_LATENCY,
                pci_mt32_inst.CAP_PTR = CPCICOMP_CAP_PTR,
                pci_mt32_inst.CIS_PTR = CPCICOMP_CIS_PTR,
                pci_mt32_inst.BAR0 = CPCICOMP_BAR0,
                pci_mt32_inst.BAR1 = CPCICOMP_BAR1,
                pci_mt32_inst.BAR2 = CPCICOMP_BAR2,
                pci_mt32_inst.BAR3 = CPCICOMP_BAR3,
                pci_mt32_inst.BAR4 = CPCICOMP_BAR4,
                pci_mt32_inst.BAR5 = CPCICOMP_BAR5,
                pci_mt32_inst.NUMBER_OF_BARS= CPCICOMP_NUMBER_OF_BARS,
                pci_mt32_inst.HARDWIRE_BAR0 = CPCICOMP_HARDWIRE_BAR0 ,
                pci_mt32_inst.HARDWIRE_BAR1 = CPCICOMP_HARDWIRE_BAR1 ,
                pci_mt32_inst.HARDWIRE_BAR2 = CPCICOMP_HARDWIRE_BAR2 ,
                pci_mt32_inst.HARDWIRE_BAR3 = CPCICOMP_HARDWIRE_BAR3 ,
                pci_mt32_inst.HARDWIRE_BAR4 = CPCICOMP_HARDWIRE_BAR4 ,
                pci_mt32_inst.HARDWIRE_BAR5 = CPCICOMP_HARDWIRE_BAR5 ,
                pci_mt32_inst.HARDWIRE_EXP_ROM = CPCICOMP_HARDWIRE_EXP_ROM_BAR,
                pci_mt32_inst.EXP_ROM_BAR = CPCICOMP_EXP_ROM_BAR,
                pci_mt32_inst.PCI_66MHZ_CAPABLE = CPCICOMP_PCI_66MHZ_CAPABLE,
                pci_mt32_inst.INTERRUPT_PIN_REG = CPCICOMP_INTERRUPT_PIN_REG,
                pci_mt32_inst.ENABLE_BITS = CPCICOMP_ENABLE_BITS;
                                                                                                                                                                                                     
                                                                                                                                                                                                     
   //assign l_ldat_ackn = 1'b0;
   //assign l_hdat_ackn = 1'b1;
end
                                                                                                                                                                                                     
   33:  // T32
   begin
   pci_t32      pci_t32_inst(
                .clk(clk),
                .rstn(rstn),
                .idsel(idsel),
                .l_adi(l_adi),
                .lt_rdyn(lt_rdyn),
                .lt_abortn(lt_abortn),
                .lt_discn(lt_discn),
                .lirqn(lirqn),
                .cben(cben),
                .framen_in(framen),
                .irdyn_in(irdyn),
                .intan(intan),
                .serrn(serrn),
                .l_adro(l_adro),
                .l_dato(l_dato),
                .l_beno(l_beno),
                .l_cmdo(l_cmdo),
                .lt_framen(lt_framen),
                .lt_ackn(lt_ackn),
                .lt_dxfrn(lt_dxfrn),
                .lt_tsr(lt_tsr),
                .cmd_reg(cmd_reg),
                .stat_reg(stat_reg),
                .perrn(perrn),
                .devseln_out(devseln),
                .trdyn_out(trdyn),
                .stopn_out(stopn),
                .ad(ad),
                .par(par));
                                                                                                                      
	 defparam
                pci_t32_inst.CLASS_CODE = CPCICOMP_CLASS_CODE,
                pci_t32_inst.DEVICE_ID = CPCICOMP_DEVICE_ID,
                pci_t32_inst.REVISION_ID = CPCICOMP_REVISION_ID,
                pci_t32_inst.SUBSYSTEM_ID = CPCICOMP_SUBSYSTEM_ID,
                pci_t32_inst.SUBSYSTEM_VENDOR_ID = CPCICOMP_SUBSYSTEM_VEND_ID,
                pci_t32_inst.TARGET_DEVICE = "NEW",
                pci_t32_inst.VENDOR_ID = CPCICOMP_VEND_ID,
                pci_t32_inst.MIN_GRANT = CPCICOMP_MIN_GRANT,
                pci_t32_inst.MAX_LATENCY = CPCICOMP_MAX_LATENCY,
                pci_t32_inst.CAP_PTR = CPCICOMP_CAP_PTR,
                pci_t32_inst.CIS_PTR = CPCICOMP_CIS_PTR,
                pci_t32_inst.BAR0 = CPCICOMP_BAR0,
                pci_t32_inst.BAR1 = CPCICOMP_BAR1,
                pci_t32_inst.BAR2 = CPCICOMP_BAR2,
                pci_t32_inst.BAR3 = CPCICOMP_BAR3,
                pci_t32_inst.BAR4 = CPCICOMP_BAR4,
                pci_t32_inst.BAR5 = CPCICOMP_BAR5,
                pci_t32_inst.NUMBER_OF_BARS= CPCICOMP_NUMBER_OF_BARS,
                pci_t32_inst.HARDWIRE_BAR0 = CPCICOMP_HARDWIRE_BAR0 ,
                pci_t32_inst.HARDWIRE_BAR1 = CPCICOMP_HARDWIRE_BAR1 ,
                pci_t32_inst.HARDWIRE_BAR2 = CPCICOMP_HARDWIRE_BAR2 ,
                pci_t32_inst.HARDWIRE_BAR3 = CPCICOMP_HARDWIRE_BAR3 ,
                pci_t32_inst.HARDWIRE_BAR4 = CPCICOMP_HARDWIRE_BAR4 ,
                pci_t32_inst.HARDWIRE_BAR5 = CPCICOMP_HARDWIRE_BAR5 ,
                pci_t32_inst.HARDWIRE_EXP_ROM = CPCICOMP_HARDWIRE_EXP_ROM_BAR,
                pci_t32_inst.EXP_ROM_BAR = CPCICOMP_EXP_ROM_BAR,
                pci_t32_inst.PCI_66MHZ_CAPABLE = CPCICOMP_PCI_66MHZ_CAPABLE,
                pci_t32_inst.INTERRUPT_PIN_REG = CPCICOMP_INTERRUPT_PIN_REG,
                pci_t32_inst.ENABLE_BITS = CPCICOMP_ENABLE_BITS;
                                                                                                                                                                                                     
                                                                                                                                                                                                     
   //assign l_ldat_ackn = 1'b0;
   //assign l_hdat_ackn = 1'b1;
   assign reqn = 1'b1;
 end
    endcase
endgenerate
                                                                                                                                                                                                     
                                                                                                                                                                                                     
`endif  ////////// END RTL VERIFICATION

//////////////////////////////////////////////////////////////////////////////     
/////                    AVALON TO PCI ACCESS                /////////////////     
//////////////////////////////////////////////////////////////////////////////
generate if (CG_PCI_TARGET_ONLY == 0)
begin
altpciav_lite_pba
  #(
   .CG_PCI_DATA_WIDTH(CG_PCI_DATA_WIDTH),
   .CG_AVALON_S_ADDR_WIDTH(CG_AVALON_S_ADDR_WIDTH),
   .CB_A2P_ADDR_MAP_NUM_ENTRIES(CB_A2P_ADDR_MAP_NUM_ENTRIES),
   .CB_A2P_ADDR_MAP_PASS_THRU_BITS(CB_A2P_ADDR_MAP_PASS_THRU_BITS),
   .CB_A2P_ADDR_MAP_FIXED_TABLE(CB_A2P_ADDR_MAP_FIXED_TABLE)
    )
lite_pba
(
  // system global signals
 .pci_clk_i(clk),
 .pci_rstn_i(rstn),

 // avalon slave port signals
 .pba_clk_i(AvlClk_i),
 .pba_rstn_i(rstn),
 .pba_chipselect_i(PbaChipSelect_i),
 .pba_address_i(PbaAddress_i),
 .pba_byteenable_i(PbaByteEnable_i),
 .pba_read_i(PbaRead_i),
 .pba_readdata_o(PbaReadData_o),
 .pba_write_i(PbaWrite_i),
 .pba_writedata_i(PbaWriteData_i),
 .pba_readdatavalid_o(PbaReadDataValid_o),
 .pba_waitrequest_o(PbaWaitRequest_o),
 .pba_burstcount_i(PbaBurstCount_i),
 .pba_begintransfer_i(PbaBeginTransfer_i),
 .pba_beginbursttransfer_i(PbaBeginBurstTransfer_i),

  // PCI core interface                
 //.l_ldat_ackn_i(l_ldat_ackn),
 //.l_hdat_ackn_i(l_hdat_ackn),
 .lm_adr_ackn_i(lm_adr_ackn),
 .l_dato_i(l_dato),
 .lm_tsr_i(lm_tsr),
 .stat_reg_i(stat_reg),
 .cmd_reg_i(cmd_reg),
 .lm_dxfrn_i(lm_dxfrn),
// .cachesize_i(cache),
 .lm_lastn_o(lm_lastn),
 .lm_req32n_o(lm_req32n),
 .lm_rdyn_o(lm_rdyn),
 .lm_ackn_i(lm_ackn),
 .l_adi_o(mstr_l_adi),
 .l_cben_o(l_cbeni),

.AdTrAddress_i(cr_addr),    // Register (DWORD) specific address
.AdTrByteEnable_i(cr_bena), // Register Byte Enables
.AdTrWriteVld_i(cr_wrreq_vld),   // Valid Write Cycle in  
.AdTrWriteData_i(cr_wrdat),  // Write Data in 
.AdTrReadVld_i(cr_rdreq_vld),    // Read Valid in
.AdTrReadData_o(cr_rddat),   // Read Data out
.AdTrReadVld_o(cr_rddat_vld_sig)    // Read Valid out (piped) 

   
); 

end
else
  begin
    //default value if no driver (target only)
    assign mstr_l_adi = 0;
    assign PbaReadData_o = 0;
    assign PbaReadDataValid_o =0;
    assign PbaWaitRequest_o = 0;
    
  end

endgenerate // end altpciav_lite_pba

//////////////////////////////////////////////////////////////////////////////     
/////                    PCI TO AVALON PREFETCHABLE          /////////////////     
//////////////////////////////////////////////////////////////////////////////
// 1. hide the npm output in the altpciav_lite_master
// 
generate if((CG_IMPL_PREF_AV_MASTER_PORT == 1) | (CG_IMPL_NONP_AV_MASTER_PORT ==1))
begin
altpciav_lite_master
#(   .CG_PCI_TARGET_ONLY(CG_PCI_TARGET_ONLY),
     .CG_PCI_DATA_WIDTH(CG_PCI_DATA_WIDTH),
     .CG_AVALON_M_ADDR_WIDTH(CG_AVALON_M_ADDR_WIDTH),
     .CB_P2A_PREF_DISCARD_CYCLES(CB_P2A_PREF_DISCARD_CYCLES),
     .CPCICOMP_NUMBER_OF_BARS(CPCICOMP_NUMBER_OF_BARS),       
     .CB_P2A_MR_INIT_DWORDS_B0(CB_P2A_MR_INIT_DWORDS_B0)
 ) 
lite_master
( 
 // system global signals
 .PciClk_i(clk),
 .Rstn_i(rstn),

 // avalon master port signals
 .PmClk_i(AvlClk_i),
 .PmRstn_i(rstn),
 .PmWaitRequest_i(PmWaitRequest_i),
 .PmReadDataValid_i(PmReadDataValid_i),
 .PmReadData_i(PmReadData_i),
 .PmWrite_o(PmWrite_o),
 .PmAddr_o(PmAddress_o),
 .PmWriteData_o(PmWriteData_o),
 .PmByteEnable_o(PmByteEnable_o),
 .PmBurstCount_o(PmBurstCount_o),
 .PmRead_o(PmRead_o),
 .PmBeginTransfer_o(PmBeginTransfer_o),
 .PmBeginBurstTransfer_o(PmBeginBurstTransfer_o),

  // PCI core interface                
 .LtFramen_i(lt_framen),
 .LtDxfrn_i(lt_dxfrn),
 .LtTsr_i(lt_tsr),
 .LtCmd_i(l_cmdo),
 .LtAddr_i(l_adro[31:0]),
 .LtDat_i(l_dato),
 .LtBen_i(l_beno),
 .LtRdyn_o(lt_rdyn),
 .LtDiscn_o(lt_discn),
 .LtAbortn_o(lt_abortn),
 .LtDat_o(p_l_adi), //l_adi out depend whether it is from master or pba

 //parameter inputs
 .cpcicomp_bar0_i(CPCICOMP_BAR0), 
 .cpcicomp_bar1_i(CPCICOMP_BAR1),
 .cpcicomp_bar2_i(CPCICOMP_BAR2),
 .cpcicomp_bar3_i(CPCICOMP_BAR3),
 .cpcicomp_bar4_i(CPCICOMP_BAR4),
 .cpcicomp_bar5_i(CPCICOMP_BAR5),
 .cpcicomp_exp_rom_bar_i(CPCICOMP_EXP_ROM_BAR),
 .cb_p2a_avalon_addr_b0_i(CB_P2A_AVALON_ADDR_B0),
 .cb_p2a_avalon_addr_b1_i(CB_P2A_AVALON_ADDR_B1),
 .cb_p2a_avalon_addr_b2_i(CB_P2A_AVALON_ADDR_B2),
 .cb_p2a_avalon_addr_b3_i(CB_P2A_AVALON_ADDR_B3),
 .cb_p2a_avalon_addr_b4_i(CB_P2A_AVALON_ADDR_B4),
 .cb_p2a_avalon_addr_b5_i(CB_P2A_AVALON_ADDR_B5),
 .cb_p2a_avalon_addr_b6_i(CB_P2A_AVALON_ADDR_B6),
 .cb_p2a_nonp_max_init_lat_i(CB_P2A_NONP_MAX_INIT_LAT),
 .baractive(BarActive_o)
);
end
endgenerate // end altpciav_lite_master

//////////////////////////////////////////////////////////////////////////////   
/////                    CONTROL REGISTER ACCESS             /////////////////   
//////////////////////////////////////////////////////////////////////////////   
    assign lirqn = !NpmIrq_i;

generate if(CG_PCI_TARGET_ONLY == 0)
altpciav_lite_control_register
  #(
    .INTENDED_DEVICE_FAMILY(INTENDED_DEVICE_FAMILY)
    //.CG_NUM_A2P_MAILBOX(CG_NUM_A2P_MAILBOX),
    //.CG_NUM_P2A_MAILBOX(CG_NUM_P2A_MAILBOX)

        )
cntrl_reg
  (
   // Avalon Interface signals (all synchronous to CraClk_i)
   .CraClk_i(AvlClk_i),           // Clock for register access port
   .CraRstn_i(rstn),          // Reset signal  
   .CraChipSelect_i(CraChipSelect_i),    // Chip Select signals
   .CraAddress_i(CraAddress_i),       // Register (DWORD) specific address
   .CraByteEnable_i(CraByteEnable_i),    // Register Byte Enables
   .CraRead_i(CraRead_i),          // Read indication
   .CraReadData_o(CraReadData_o),      // Read data lines
   .CraWrite_i(CraWrite_i),         // Write indication 
   .CraWriteData_i(CraWriteData_i),     // Write Data in 
   .CraWaitRequest_o(CraWaitRequest_o),   // Wait indication out 
   .CraBeginTransfer_i(CraBeginTransfer_i), // Start of Transfer indication
  
   // Avalon Interrupt Signals

   // All synchronous to CraClk_i
   //.CraIrq_o(CraIrq_o),           // Interrupt Request out
   .NpmIrq_i(NpmIrq_i),           // NonP Master Interrupt in
   
   // Modified Avalon signals to the Address Translation logic
   // All synchronous to CraClk_i
   .AdTrWriteReqVld_o(cr_wrreq_vld),  // Valid Write Cycle to AddrTrans  
   .AdTrReadReqVld_o(cr_rdreq_vld),   // Read Valid out to AddrTrans
   .AdTrAddress_o(cr_addr),      // Address to AddrTrans
   .AdTrWriteData_o(cr_wrdat),    // Write Data to AddrTrans
   .AdTrByteEnable_o(cr_bena),   // Write Byte Enables to AddrTrans
   .AdTrReadData_i(cr_rddat),     // Read Data in from AddrTrans
   .AdTrReadDataVld_i(cr_rddat_vld_sig)  // Read Valid in from AddrTrans

   ) ;

else
  begin
    assign CraReadData_o = 0;
    assign CraWaitRequest_o = 1'b0;
    //assign CraIrq_o = 1'b0;
  end

endgenerate

assign l_adi=(~lt_framen)? p_l_adi : mstr_l_adi;

//assign l_ldat_ackn = 1'b0;
//assign l_hdat_ackn = 1'b1;

/// reset connections
assign PmResetRequest_o =  rstn;
assign CraResetRequest_o = rstn;
assign PbaResetRequest_o = rstn;

endmodule
