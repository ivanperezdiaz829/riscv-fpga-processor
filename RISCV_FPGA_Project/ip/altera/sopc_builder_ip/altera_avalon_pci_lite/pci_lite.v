// megafunction wizard: %PCI Avalon Compiler v8.0%
// GENERATION: XML

// ============================================================
// Megafunction Name(s):
// 			altpciav_lite
// ============================================================
// Generated by PCI Avalon Compiler 8.0 [Altera, IP Toolbench 1.3.0 Build 110]
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
// ************************************************************
// Copyright (C) 1991-2008 Altera Corporation
// Any megafunction design, and related net list (encrypted or decrypted),
// support information, device programming or simulation file, and any other
// associated documentation or information provided by Altera or a partner
// under Altera's Megafunction Partnership Program may be used only to
// program PLD devices (but not masked PLD devices) from Altera.  Any other
// use of such megafunction design, net list, support information, device
// programming or simulation file, or any other related documentation or
// information is prohibited for any other purpose, including, but not
// limited to modification, reverse engineering, de-compiling, or use with
// any other silicon devices, unless such use is explicitly licensed under
// a separate agreement with Altera or a megafunction partner.  Title to
// the intellectual property, including patents, copyrights, trademarks,
// trade secrets, or maskworks, embodied in any such megafunction design,
// net list, support information, device programming or simulation file, or
// any other related documentation or information provided by Altera or a
// megafunction partner, remains with Altera, the megafunction partner, or
// their respective licensors.  No other licenses, including any licenses
// needed under any third party's intellectual property, are provided herein.
// altera message_off 10230
(*altera_attribute = {"-name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030"} *) module pci_lite 
  #(
   		parameter MASTER_ENABLE = 0,
   		parameter MASTER_HOST_BRIDGE = 0,
		parameter BAR_PREFETCHABLE = 0,
		parameter BAR_NONPREFETCHABLE = 0,
		parameter BAR_IO = 0,
		parameter BAR_PREFETCHABLE_SIZE = 20,
		parameter BAR_NONPREFETCHABLE_SIZE = 20,
		parameter BAR_IO_SIZE = 10,
		parameter BAR_PREFETCHABLE_AV_ADDR_TRANS = 32'h00000000,
		parameter BAR_NONPREFETCHABLE_AV_ADDR_TRANS = 32'h00000000,
		parameter BAR_IO_AV_ADDR_TRANS = 32'h00000000,
                parameter PCI_MASTER_ADDR_MAP_NUM_ENTRIES = 1,
		parameter PCI_MASTER_ADDR_MAP_PASS_THRU_BITS = 20,
		parameter CONF_DEVICE_ID = 16'h0004,
		parameter CONF_CLASS_CODE = 24'hff0000,
		parameter CONF_MAX_LATENCY = 8'h00,
		parameter CONF_MIN_GRANT = 8'h00,
		parameter CONF_REVISION_ID = 8'h01,
		parameter CONF_SUBSYSTEM_ID = 16'h0000,
		parameter CONF_SUBSYSTEM_VEND_ID = 16'h0000,
		parameter CONF_VEND_ID = 16'h1172,
		parameter MAX_READ_DWORDS_BURST = 128
	)
(
        // Irq
        NIrq_i,
	
        // Avalon Master Ports Pm
	PmReadData_i,
	PmReadDataValid_i,
	PmWaitRequest_i,
	PmAddress_o,
	PmRead_o,
	PmWrite_o,
	PmByteEnable_o,
	PmWriteData_o,
	PmBurstCount_o,
        
        // Avalon Master Ports Npm
	NpmReadData_i,
	NpmReadDataValid_i,
	NpmWaitRequest_i,
	NpmAddress_o,
	NpmRead_o,
	NpmWrite_o,
	NpmByteEnable_o,
	NpmWriteData_o,
        
        // Avalon Master Ports IO
	IoReadData_i,
	IoReadDataValid_i,
	IoWaitRequest_i,
	IoAddress_o,
	IoRead_o,
	IoWrite_o,
	IoByteEnable_o,
	IoWriteData_o,
	IoBurstCount_o,
        
        // Avalon Slave Ports
        PbaChipSelect_i,
	PbaByteEnable_i,
	PbaWriteData_i,
	PbaAddress_i,
	PbaRead_i,
	PbaWrite_i,
	PbaBurstCount_i,
	PbaBeginTransfer_i,
	PbaBeginBurstTransfer_i,
	PbaReadData_o,
	PbaReadDataValid_o,
	PbaWaitRequest_o,
	

        // CRA ports
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
 
        // PCI export ports
        AvlClk_i,
	rstn,
        gntn,
	idsel,
	reqn,
	intan,
	ad,
	cben,
	framen,
	irdyn,
	devseln,
	trdyn,
	stopn,
	perrn,
	par,
	serrn
);
	
        // Irq
        input		NIrq_i;

        // Avalon Master Ports Pm
	input	[31:0]	PmReadData_i;
	input		PmReadDataValid_i;
	input		PmWaitRequest_i;
	output	[BAR_PREFETCHABLE_SIZE-1:0]	PmAddress_o;
	output		PmRead_o;
	output		PmWrite_o;
	output	[3:0]	PmByteEnable_o;
	output	[31:0]	PmWriteData_o;
	output	[7:0]	PmBurstCount_o;

        // Avalon Master Ports Npm
	input	[31:0]	NpmReadData_i;
	input		NpmReadDataValid_i;
	input		NpmWaitRequest_i;
	output	[BAR_NONPREFETCHABLE_SIZE-1:0]	NpmAddress_o;
	output		NpmRead_o;
	output		NpmWrite_o;
	output	[3:0]	NpmByteEnable_o;
	output	[31:0]	NpmWriteData_o;
        
        // Avalon Master Ports IO
	input	[31:0]	IoReadData_i;
	input		IoReadDataValid_i;
	input		IoWaitRequest_i;
	output	[BAR_IO_SIZE-1:0]	IoAddress_o;
	output		IoRead_o;
	output		IoWrite_o;
	output	[3:0]	IoByteEnable_o;
	output	[31:0]	IoWriteData_o;
	output	[7:0]	IoBurstCount_o;
        
        // PCI export ports
        input		AvlClk_i;
	input		rstn;
	input		gntn;
	input		idsel;
	inout	[31:0]	ad;
	inout	[3:0]	cben;
	inout		framen;
	inout		irdyn;
	inout		devseln;
	inout		trdyn;
	inout		stopn;
	inout		perrn;
	inout		par;
	inout		serrn;
	output		reqn;
	output		intan;
	
        // Avalon Slave Ports
        input		PbaChipSelect_i;
	input	[3:0]	PbaByteEnable_i;
	input	[31:0]	PbaWriteData_i;
	input	[PCI_MASTER_ADDR_MAP_PASS_THRU_BITS-1:2]	PbaAddress_i;
	input		PbaRead_i;
	input		PbaWrite_i;
	input	[7:0]	PbaBurstCount_i;
	input		PbaBeginTransfer_i;
	input		PbaBeginBurstTransfer_i;
	output	[31:0]	PbaReadData_o;
	output		PbaReadDataValid_o;
	output		PbaWaitRequest_o;

        // CRA Slave Porst
        input           CraChipSelect_i;
        input   [13:2]  CraAddress_i;
        input   [3:0]   CraByteEnable_i;
        input           CraRead_i;
        input           CraWrite_i;
        input   [31:0]  CraWriteData_i;
        input           CraBeginTransfer_i;
        output  [31:0]  CraReadData_o;
        output          CraWaitRequest_o;
//        output          CraIrq_o;


//wire		ResetRequest_o;
wire	[31:0]	Address_o;
wire		Write_o;
wire    [3:0]	ByteEnable_o;
wire	[31:0]	WriteData_o;
wire    [7:0]	BurstCount_o;
// Requires muxing
wire		Read_o;
reg     [31:0]	ReadData_i;
reg		ReadDataValid_i;
reg		WaitRequest_i;
wire    [2:0]   BarActive_o;
        
        // Avalon Master Ports Pm
	assign PmAddress_o = Address_o;
	assign PmByteEnable_o = ByteEnable_o;
	assign PmWriteData_o = WriteData_o;
	assign PmBurstCount_o = BurstCount_o;

        // Avalon Master Ports Npm
	assign NpmAddress_o = Address_o;
	assign NpmByteEnable_o = ByteEnable_o;
	assign NpmWriteData_o = WriteData_o;
        
        // Avalon Master Ports IO
	assign IoAddress_o = Address_o;
	assign IoByteEnable_o = ByteEnable_o;
	assign IoWriteData_o = WriteData_o;
	assign IoBurstCount_o = BurstCount_o;
	
        always @ * 
        begin 
        if (BarActive_o == 3'b001) 
           WaitRequest_i = PmWaitRequest_i;
        else if (BarActive_o == 3'b010)
           WaitRequest_i = NpmWaitRequest_i;
        else if (BarActive_o == 3'b100)
           WaitRequest_i = IoWaitRequest_i;
        else 
           WaitRequest_i = 1'b0;
        end

	assign PmRead_o  = (BarActive_o == 3'b001) ? Read_o : 1'b0;
	assign NpmRead_o = (BarActive_o == 3'b010) ? Read_o : 1'b0; 
	assign IoRead_o  = (BarActive_o == 3'b100) ? Read_o : 1'b0;
	
        assign PmWrite_o  = (BarActive_o == 3'b001) ? Write_o : 1'b0;
	assign NpmWrite_o = (BarActive_o == 3'b010) ? Write_o : 1'b0; 
	assign IoWrite_o  = (BarActive_o == 3'b100) ? Write_o : 1'b0;
        
        always @ * 
        begin 
        if (BarActive_o == 3'b001) 
	   ReadData_i = PmReadData_i;
        else if (BarActive_o == 3'b010)
	   ReadData_i = NpmReadData_i;
        else if (BarActive_o == 3'b100)
	   ReadData_i = IoReadData_i;
        else
	   ReadData_i = 32'b0;
	end

        always @ * 
        begin 
        if (BarActive_o == 3'b001) 
           ReadDataValid_i = PmReadDataValid_i;
        else if (BarActive_o == 3'b010)
           ReadDataValid_i = NpmReadDataValid_i;
        else if (BarActive_o == 3'b100)
	   ReadDataValid_i = IoReadDataValid_i;
        else
	   ReadDataValid_i = 1'b0;
        end

        altpciav_lite	altpciav_lite_inst(
		.AvlClk_i(AvlClk_i),
		.rstn(rstn),
		.clk(AvlClk_i),
		.PmReadData_i(ReadData_i),
		.PmReadDataValid_i(ReadDataValid_i),
		.PmWaitRequest_i(WaitRequest_i),
		.NpmIrq_i(NIrq_i),
                .BarActive_o(BarActive_o),
		.PbaChipSelect_i(PbaChipSelect_i),
		.PbaByteEnable_i(PbaByteEnable_i),
		.PbaWriteData_i(PbaWriteData_i),
		.PbaAddress_i(PbaAddress_i),
		.PbaRead_i(PbaRead_i),
		.PbaWrite_i(PbaWrite_i),
		.PbaBurstCount_i(PbaBurstCount_i),
		.PbaBeginTransfer_i(PbaBeginTransfer_i),
		.PbaBeginBurstTransfer_i(PbaBeginBurstTransfer_i),
		.gntn(gntn),
		.idsel(idsel),
		.PmAddress_o(Address_o),
		.PmRead_o(Read_o),
		.PmWrite_o(Write_o),
		.PmByteEnable_o(ByteEnable_o),
		.PmWriteData_o(WriteData_o),
		.PmBurstCount_o(BurstCount_o),
		.PbaReadData_o(PbaReadData_o),
		.PbaReadDataValid_o(PbaReadDataValid_o),
		.PbaWaitRequest_o(PbaWaitRequest_o),
                .CraChipSelect_i(CraChipSelect_i),
                .CraAddress_i(CraAddress_i),
                .CraByteEnable_i(CraByteEnable_i),
                .CraRead_i(CraRead_i),
                .CraReadData_o(CraReadData_o),
                .CraWrite_i(CraWrite_i),
                .CraWriteData_i(CraWriteData_i),
                .CraWaitRequest_o(CraWaitRequest_o),
                //.CraIrq_o(CraIrq_o),
                .CraBeginTransfer_i(CraBeginTransfer_i),
                .reqn(reqn),
		.intan(intan),
		.ad(ad),
		.cben(cben),
		.framen(framen),
		.irdyn(irdyn),
		.devseln(devseln),
		.trdyn(trdyn),
		.stopn(stopn),
		.perrn(perrn),
		.par(par),
		.serrn(serrn));

defparam
		altpciav_lite_inst.CG_PCI_TARGET_ONLY = MASTER_ENABLE ? 0 : 1,
		altpciav_lite_inst.CG_HOST_BRIDGE_MODE = MASTER_HOST_BRIDGE,
		altpciav_lite_inst.CG_PCI_DATA_WIDTH = 32,
		altpciav_lite_inst.CG_AVALON_S_ADDR_WIDTH = PCI_MASTER_ADDR_MAP_PASS_THRU_BITS + log2ceil(PCI_MASTER_ADDR_MAP_NUM_ENTRIES),
		altpciav_lite_inst.CG_COMMON_CLOCK_MODE = 1,
		altpciav_lite_inst.CG_IMPL_PCI_ARBITER = 0,
		altpciav_lite_inst.CG_PCI_ARB_NUM_REQ_GNT = 2,
		altpciav_lite_inst.CG_IMPL_CRA_AV_SLAVE_PORT = 0,
		altpciav_lite_inst.CG_IMPL_PREF_AV_MASTER_PORT = 1,
		altpciav_lite_inst.CG_IMPL_NONP_AV_MASTER_PORT = 1,
		altpciav_lite_inst.CG_IMPL_PREF_NONP_INDEPENDENT = 0,
		altpciav_lite_inst.CG_IMPL_PCI_AVL_LITE  = 1,
		altpciav_lite_inst.INTENDED_DEVICE_FAMILY = "Stratix II",
                altpciav_lite_inst.CPCICOMP_DEVICE_ID = CONF_DEVICE_ID,
		altpciav_lite_inst.CPCICOMP_CLASS_CODE = CONF_CLASS_CODE,
		altpciav_lite_inst.CPCICOMP_MAX_LATENCY = CONF_MAX_LATENCY,
		altpciav_lite_inst.CPCICOMP_MIN_GRANT = CONF_MIN_GRANT,
		altpciav_lite_inst.CPCICOMP_REVISION_ID = CONF_REVISION_ID,
		altpciav_lite_inst.CPCICOMP_SUBSYSTEM_ID =CONF_SUBSYSTEM_ID,
		altpciav_lite_inst.CPCICOMP_SUBSYSTEM_VEND_ID =CONF_SUBSYSTEM_VEND_ID,
		altpciav_lite_inst.CPCICOMP_VEND_ID =CONF_VEND_ID,
		altpciav_lite_inst.CPCICOMP_BAR0 = (BAR_PREFETCHABLE) ? ((32'hFFFFFFFF << BAR_PREFETCHABLE_SIZE)|32'h8) : (BAR_NONPREFETCHABLE) ? (32'hFFFFFFFF << BAR_NONPREFETCHABLE_SIZE) : ((32'hFFFFFFFF << BAR_IO_SIZE)|32'h1),
		altpciav_lite_inst.CPCICOMP_BAR1 = (BAR_NONPREFETCHABLE & BAR_PREFETCHABLE) ? (32'hFFFFFFFF << BAR_NONPREFETCHABLE_SIZE) : ((32'hFFFFFFFF << BAR_IO_SIZE)|32'h1),
		altpciav_lite_inst.CPCICOMP_BAR2 = ((32'hFFFFFFFF << BAR_IO_SIZE)|32'h1),
		altpciav_lite_inst.CPCICOMP_BAR3 = 32'hfff00008,
		altpciav_lite_inst.CPCICOMP_BAR4 = 32'hfff00008,
		altpciav_lite_inst.CPCICOMP_BAR5 = 32'hfff00008,
		altpciav_lite_inst.CPCICOMP_HARDWIRE_BAR0 = 32'h00000000,
		altpciav_lite_inst.CPCICOMP_HARDWIRE_BAR1 = 32'h00000000,
		altpciav_lite_inst.CPCICOMP_HARDWIRE_BAR2 = 32'h00000000,
		altpciav_lite_inst.CPCICOMP_HARDWIRE_BAR3 = 32'h00000000,
		altpciav_lite_inst.CPCICOMP_HARDWIRE_BAR4 = 32'h00000000,
		altpciav_lite_inst.CPCICOMP_HARDWIRE_BAR5 = 32'h00000000,
		altpciav_lite_inst.CPCICOMP_NUMBER_OF_BARS = (BAR_PREFETCHABLE + BAR_NONPREFETCHABLE + BAR_IO),
		altpciav_lite_inst.CPCICOMP_ENABLE_BITS = MASTER_HOST_BRIDGE ? 32'h001a2000 : 32'h001a0000,
		altpciav_lite_inst.CPCICOMP_PCI_66MHZ_CAPABLE = "YES",
		altpciav_lite_inst.CB_A2P_PERF_PROFILE = 2,
		altpciav_lite_inst.CB_A2P_ADDR_MAP_NUM_ENTRIES = PCI_MASTER_ADDR_MAP_NUM_ENTRIES,
		altpciav_lite_inst.CB_A2P_ADDR_MAP_PASS_THRU_BITS = PCI_MASTER_ADDR_MAP_PASS_THRU_BITS,
		altpciav_lite_inst.CB_A2P_ADDR_MAP_IS_FIXED = 0,
		altpciav_lite_inst.CB_A2P_ADDR_MAP_FIXED_TABLE =1024'h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
		altpciav_lite_inst.CB_P2A_PERF_PROFILE = 2,
                altpciav_lite_inst.CB_P2A_AVALON_ADDR_B0 = BAR_PREFETCHABLE_AV_ADDR_TRANS,
		altpciav_lite_inst.CB_P2A_AVALON_ADDR_B1 = BAR_NONPREFETCHABLE_AV_ADDR_TRANS,
		altpciav_lite_inst.CB_P2A_AVALON_ADDR_B2 = BAR_IO_AV_ADDR_TRANS,
		altpciav_lite_inst.CB_P2A_AVALON_ADDR_B3 = 32'h00000000,
		altpciav_lite_inst.CB_P2A_AVALON_ADDR_B4 = 32'h00000000,
		altpciav_lite_inst.CB_P2A_AVALON_ADDR_B5 = 32'h00000000,
		altpciav_lite_inst.CG_ALLOW_PARM_READBACK = 0,
		altpciav_lite_inst.CB_P2A_MR_INIT_DWORDS_B0 = MAX_READ_DWORDS_BURST,
		altpciav_lite_inst.CB_P2A_MR_INIT_DWORDS_B1 = MAX_READ_DWORDS_BURST,
		altpciav_lite_inst.CB_P2A_MR_INIT_DWORDS_B2 = MAX_READ_DWORDS_BURST,
		altpciav_lite_inst.CB_P2A_MR_INIT_DWORDS_B3 = MAX_READ_DWORDS_BURST,
		altpciav_lite_inst.CB_P2A_MR_INIT_DWORDS_B4 = MAX_READ_DWORDS_BURST,
		altpciav_lite_inst.CB_P2A_MR_INIT_DWORDS_B5 = MAX_READ_DWORDS_BURST,
		altpciav_lite_inst.CB_P2A_SUPPORT_IO_TRANS = 1;
    // --------------------------------------------------
    // Calculates the log2ceil of the input value
    // --------------------------------------------------
    function integer log2ceil;
        input integer val;
        integer i;

        begin
            i = 1;
            log2ceil = 0;

            while (i < val) begin
                log2ceil = log2ceil + 1;
                i = i << 1; 
            end
        end
    endfunction
endmodule

