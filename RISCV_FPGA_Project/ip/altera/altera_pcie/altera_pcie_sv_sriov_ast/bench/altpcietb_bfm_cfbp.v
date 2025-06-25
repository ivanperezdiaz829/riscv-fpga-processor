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


   // Test Parameters
   localparam GEN2 = 2;
   localparam GEN1 = 1;

   localparam [2:0] MAX_BAR = 4; //Phase1 for SR-IOV
   localparam [8:0] MAX_VF  = 2; //Phase1 for SR-IOV - Max = 32

   localparam TEST_PF_CONFIG       = 1'b1;
   localparam TEST_VF_CONFIG       = 1'b1;
   localparam TEST_PF_MEM          = 1'b1;
   localparam TEST_VF_MEM          = 1'b1;
   localparam TEST_LMI             = 1'b1;
   localparam TEST_MSI             = 1'b1;
   localparam TEST_LEGACY_INT      = 1'b1;
   localparam TEST_VF_ACCESS_W_VF_DISABLE = 1'b0;

   // Host scratch memory space for storing read data
   localparam  REG_SHARE_RD = SCR_MEM_DOWNSTREAM_RD + 32'h200;
   localparam  REG_SHARE_WR = SCR_MEM_DOWNSTREAM_WR + 32'h200;

   localparam  MEM_SHARE_RD = SCR_MEM_DOWNSTREAM_RD + 32'h400;
   localparam  MEM_SHARE_WR = SCR_MEM_DOWNSTREAM_WR + 32'h400;

   // Config dw addresses
   localparam DEV_VENDOR_ID        = 9'h0;
   localparam STATUS_COMMAND       = 9'h1;
   localparam REVISIONID_CLASSCODE = 9'h2;
   localparam BIST_HDR_TYPE        = 9'h3;
   localparam BAR0_REG             = 9'h4;
   localparam BAR1_REG             = 9'h5;
   localparam BAR3_REG             = 9'h7;
   localparam SUBSYS_ID_VENDOR_ID  = 9'hB;
   localparam CAP_POINTER          = 9'hD;


   // Local parameters for EP config space in byte address
   localparam CFG_SHARE_RD = SCR_MEM_DOWNSTREAM_RD; 

   localparam CAPABILITY_REG       = 10'h34;

   localparam MSI_BASE_ADDR        = 10'h50;
   localparam MSI_LOWER_ADDR       = 10'h54;
   localparam MSI_UPPER_ADDR       = 10'h58;
   localparam MSI_DATA             = 10'h5C;

   localparam MSIX_BASE_ADDR       = 10'h68;
   localparam MSIX_TABLE_OFFSET    = 10'h6C;
   localparam MSIX_PBA_OFFSET      = 10'h70;

   localparam PM_CAP_BASE_ADDR     = 10'h78;
   localparam PM_CONTROL_STATUS    = 10'h7C;
   localparam PCIE_CAP_BASE_ADDR   = 10'h80;
   localparam PCIE_DEV_CAP_ADDR    = 10'h84;
   localparam PCIE_DEV_CTL_STATUS_ADDR = 10'h88;
   localparam PCIE_LINK_CAP_ADDR   = 10'h8C;
   localparam PCIE_LINK_CTL_STATUS_ADDR   = 10'h90;
   localparam PCIE_DEV_CAP2_ADDR          = 10'hA4;
   localparam PCIE_DEV_CTL_STATUS2_ADDR   = 10'hA8;
   localparam PCIE_LINK_CAP2_ADDR         = 10'hAC;
   localparam PCIE_LINK_CTL_STATUS2_ADDR  = 10'hB0;


   localparam ARI_CAP_BASE_ADDR = 10'h100;
   localparam ARI_CAP_REG_ADDR  = 10'h104;

   localparam SR_IOV_CAP_BASE_ADDR = 10'h180;
   localparam SR_IOV_CAP_REG_ADDR = SR_IOV_CAP_BASE_ADDR + 4;
   localparam SR_IOV_CTL_REG_ADDR = SR_IOV_CAP_BASE_ADDR + 8;
   localparam SR_IOV_INITIAL_VF_COUNT_REG_ADDR = SR_IOV_CAP_BASE_ADDR + 12;
   localparam SR_IOV_NUM_VFS_REG_ADDR = SR_IOV_CAP_BASE_ADDR + 16;
   localparam SR_IOV_VF_OFFSET_STRIDE_REG_ADDR = SR_IOV_CAP_BASE_ADDR + 20;
   localparam SR_IOV_VF_DEVICE_ID_REG_ADDR = SR_IOV_CAP_BASE_ADDR + 24;
   localparam SR_IOV_SUPPORTED_PAGE_SIZES_REG_ADDR = SR_IOV_CAP_BASE_ADDR + 28;
   localparam SR_IOV_SYSTEM_PAGE_SIZE_REG_ADDR = SR_IOV_CAP_BASE_ADDR + 32;
   localparam SR_IOV_VF_BAR0_ADDR = SR_IOV_CAP_BASE_ADDR + 9*4;
   localparam SR_IOV_VF_BAR1_ADDR = SR_IOV_CAP_BASE_ADDR + 10*4;
   localparam SR_IOV_VF_BAR2_ADDR = SR_IOV_CAP_BASE_ADDR + 11*4;
   localparam SR_IOV_VF_BAR3_ADDR = SR_IOV_CAP_BASE_ADDR + 12*4;
   localparam SR_IOV_VF_BAR4_ADDR = SR_IOV_CAP_BASE_ADDR + 13*4;
   localparam SR_IOV_VF_BAR5_ADDR = SR_IOV_CAP_BASE_ADDR + 14*4;
   
   localparam PCIE_CAP_DEVICE_CAP_REG_ADDR = PCIE_CAP_BASE_ADDR + 1*4;
   localparam PCIE_CAP_DEVICE_CTL_REG_ADDR = PCIE_CAP_BASE_ADDR + 2*4;
   localparam PCIE_CAP_DEVICE_STATUS_REG_ADDR = PCIE_CAP_BASE_ADDR + 2*4;   
   localparam PCIE_CAP_LINK_CAP_REG_ADDR = PCIE_CAP_BASE_ADDR + 3*4;
   localparam PCIE_CAP_LINK_CTL_REG_ADDR = PCIE_CAP_BASE_ADDR + 4*4;
   localparam PCIE_CAP_LINK_STATUS_REG_ADDR = PCIE_CAP_BASE_ADDR + 4*4;
   localparam PCIE_CAP_DEVICE_CAP2_REG_ADDR = PCIE_CAP_BASE_ADDR + 9*4;
   localparam PCIE_CAP_DEVICE_CTL2_REG_ADDR = PCIE_CAP_BASE_ADDR + 10*4;
   localparam PCIE_CAP_LINK_CAP2_REG_ADDR = PCIE_CAP_BASE_ADDR + 11*4;
   localparam PCIE_CAP_LINK_CTL2_REG_ADDR = PCIE_CAP_BASE_ADDR + 12*4;
   localparam PCIE_CAP_LINK_STATUS2_REG_ADDR = PCIE_CAP_BASE_ADDR + 12*4;

// MSI addr

   //=====================================================
   // Mailbox register for LMI and MSI interrupts in byte
   //=====================================================
  localparam      LMI_CTL_STATUS_ADDR = 12'h400; // 0x400 Byte addr
  localparam      LMI_RDATA_ADDR      = 12'h404;
  localparam      LMI_WDATA_ADDR      = 12'h408;
  localparam      INT_CTL_STATUS_ADDR = 12'h40C; // DW address

   // Interrupt 
  localparam      MBOX_INTA  = 4'b0001;
  localparam      MBOX_INTB  = 4'b0010;
  localparam      MBOX_INTC  = 4'b0100;
  localparam      MBOX_INTD  = 4'b1000;

  // register0 => First address for all PF and VFs
   localparam  REG0_ADDR = 32'h0; // Offset from setup_bar
  
//============================================================================
//
// New tasks for Config-Bypass start here
//
//============================================================================
   task ebfm_cfg_rp;   // Wrapper task called by End Point
      input    ep_bus_num;
      integer  ep_bus_num;
      input    rp_max_rd_req_size;
      integer  rp_max_rd_req_size;
      input    display_rp_config;    // 1 to display
      integer  display_rp_config;
      output   activity_toggle;
      reg      activity_toggle;

      begin
         ebfm_cfg_rp_main (ep_bus_num, rp_max_rd_req_size, display_rp_config, activity_toggle);
      end

   endtask

//============================================================================
   // purpose: Performs all of the steps neccesary to configure the
   // root port on the link
   task ebfm_cfg_rp_main;
      input    ep_bus_num;
      integer  ep_bus_num;
      input    rp_max_rd_req_size;
      integer  rp_max_rd_req_size;
      input    display_rp_config;    // 1 to display
      integer  display_rp_config;
      output   activity_toggle;
      reg      activity_toggle;


      reg[31:0] io_min_v;
      reg[31:0] io_max_v;
      reg[63:0] m32min_v;
      reg[63:0] m32max_v;
      reg[63:0] m64min_v;
      reg[63:0] m64max_v;
      reg[2:0] compl_status;
      reg bar_ok;

      reg dummy ;

      integer i ;

      begin  // ebfm_cfg_rp_main
         io_min_v = EBFM_BAR_IO_MIN ;
         io_max_v = EBFM_BAR_IO_MAX ;
         m32min_v = {32'h00000000,EBFM_BAR_M32_MIN};
         m32max_v = {32'h00000000,EBFM_BAR_M32_MAX};
         m64min_v = EBFM_BAR_M64_MIN;
         m64max_v = EBFM_BAR_M64_MAX;
         if  (display_rp_config == 1'b1) // Limit the BAR allocation to less than 4GB
      begin
           m32max_v[31:0] = m32max_v[31:0] & 32'h7fff_ffff;
           m64min_v = 64'h0000_0000_8000_0000;
      end

         // Wait until the Root Port is done being reset before proceeding further
         #10;

         req_intf_wait_reset_end;

         // Unlock the bfm shared memory for initialization
         bfm_shmem_common.protect_bfm_shmem = 1'b0;

         if (~TL_BFM_MODE) begin
             // Perform the basic configuration of the Root Port
             ebfm_cfg_rp_basic((ep_bus_num - RP_PRI_BUS_NUM), 1);
         end

         if ((display_rp_config == 1) & ~TL_BFM_MODE) begin
            dummy = ebfm_display(EBFM_MSG_INFO, "Completed initial configuration of Root Port.");
         end

         if (display_rp_config == 1 & ~TL_BFM_MODE) begin
             // Ensure link is at L0
             wait (top_tb.top_inst.dut.altpcie_sv_hip_ast_hwtcl.altpcie_hip_256_pipen1b.ltssmstate == 5'hf);

             ebfm_display_read_only(1, RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, CFG_SCRATCH_SPACE);
             ebfm_display_rp_bar(RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, CFG_SCRATCH_SPACE);
             ebfm_display_msi(RP_PRI_BUS_NUM,RP_PRI_DEV_NUM,0,CFG_SCRATCH_SPACE) ;
             ebfm_display_aer(1, RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, CFG_SCRATCH_SPACE) ;
             ebfm_display_slot_cap (1, RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, CFG_SCRATCH_SPACE) ;
         end

         activity_toggle <= 1;
         dummy = ebfm_display(EBFM_MSG_INFO, "Activity_toggle flag is set");

         ebfm_cfg_pcie_rp_cap(CFG_SCRATCH_SPACE, rp_max_rd_req_size, display_rp_config);

         if (~TL_BFM_MODE) begin
             // Configure Root Port Address Windows
             ebfm_cfg_rp_addr(
             (m32max_v + 1),    // Pref32 grew down
             (m64min_v - 1),    // Pref64 grew up
             (EBFM_BAR_M32_MIN),    // NonP started here
             (m32min_v[31:0] - 1),  // NonP ended here
             (EBFM_BAR_IO_MIN), // I/O Started Here
             (io_min_v - 1));   // I/O ended Here
         end

         // Protect the critical BFM data from being accidentally overwritten.
         bfm_shmem_common.protect_bfm_shmem = 1'b1;

      end
   endtask

//============================================================================
   // purpose: Performs all of the steps neccesary to configure the
   // root port on the link. The task will wait for link up. Enumerating BARs 
   // are not done in this task 
   task ebfm_cfg_rp_to_linkup;
      input   integer   ep_bus_num;
      input   integer   rp_max_rd_req_size;
      input   integer   display_rp_config;    // 1 to display
      output  reg       activity_toggle;
      reg[2:0] compl_status;
      reg dummy ;
      integer i ;


      begin  // ebfm_cfg_rp_main

         // Wait until the Root Port is done being reset before proceeding further
         #10;

         req_intf_wait_reset_end;

         // Unlock the bfm shared memory for initialization
         bfm_shmem_common.protect_bfm_shmem = 1'b0;

         if (~TL_BFM_MODE) begin
             // Perform the basic configuration of the Root Port
             ebfm_cfg_rp_basic((ep_bus_num - RP_PRI_BUS_NUM), 1);
         end

         if ((display_rp_config == 1) & ~TL_BFM_MODE) begin
            dummy = ebfm_display(EBFM_MSG_INFO, "Start initial configuration of Root Port.");
         end

         if (display_rp_config == 1 & ~TL_BFM_MODE) begin
             // Ensure link is at L0
             wait (top_tb.top_inst.dut.altpcie_sv_hip_ast_hwtcl.altpcie_hip_256_pipen1b.ltssmstate == 5'hf);

             ebfm_display_read_only(1, RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, CFG_SCRATCH_SPACE);
             ebfm_display_rp_bar(RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, CFG_SCRATCH_SPACE);
             ebfm_display_msi(RP_PRI_BUS_NUM,RP_PRI_DEV_NUM,0,CFG_SCRATCH_SPACE) ;
             ebfm_display_aer(1, RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, CFG_SCRATCH_SPACE) ;
             ebfm_display_slot_cap (1, RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, CFG_SCRATCH_SPACE) ;
         end

         activity_toggle <= 1;
         dummy = ebfm_display(EBFM_MSG_INFO, "Set Activity_toggle flag ");

         ebfm_cfg_pcie_rp_cap(CFG_SCRATCH_SPACE, rp_max_rd_req_size, display_rp_config);

         // Protect the critical BFM data from being accidentally overwritten.
         bfm_shmem_common.protect_bfm_shmem = 1'b1;
         dummy = ebfm_display(EBFM_MSG_INFO, "End configuration of Root Port.");

      end
   endtask

//========================================================
   // purpose: configure the PCI Express Capabilities
   task ebfm_cfg_pcie_rp_cap;
      input    CFG_SCRATCH_SPACE;
      integer  CFG_SCRATCH_SPACE;
      input    rp_max_rd_req_size;
      integer  rp_max_rd_req_size;
      input    display_rp_config;
      integer  display_rp_config;

      reg[2:0] compl_status;
      integer EP_PCIE_CAP ;
      integer EP_DEV_CAP ;
      integer EP_DEV_CAP2 ;
      integer EP_DEV_CTRL2 ;
      integer EP_LINK_CTRL2 ;
      integer EP_LINK_CAP ;
      integer RP_PCIE_CAP ;
      integer RP_DEV_CAP ;
      integer RP_DEV_CS;
      integer RP_LINK_CTRL;
      integer RP_DEV_CAP2;
      integer RP_LINK_CAP;
      reg[31:0] ep_pcie_cap_r;
      reg[31:0] rp_pcie_cap_r;
      reg[31:0] ep_dev_cap_r;
      reg[31:0] rp_dev_cap_r;
      reg[15:0] ep_dev_control;
      reg[15:0] rp_dev_control;
      reg[15:0] rp_dev_cs;
      integer max_size;

      reg dummy ;

      begin // ebfm_cfg_pcie_cap
         ep_dev_control = {16{1'b0}} ;
         rp_dev_control = {16{1'b0}} ;
         EP_PCIE_CAP = CFG_SCRATCH_SPACE + 0;
         EP_DEV_CAP  = CFG_SCRATCH_SPACE + 4;
         EP_LINK_CAP = CFG_SCRATCH_SPACE + 8;
         RP_PCIE_CAP = CFG_SCRATCH_SPACE + 16;
         RP_DEV_CAP  = CFG_SCRATCH_SPACE + 20;
         EP_DEV_CAP2  = CFG_SCRATCH_SPACE + 24;
         RP_DEV_CS   = CFG_SCRATCH_SPACE + 36;
         RP_LINK_CTRL = CFG_SCRATCH_SPACE + 40;
         RP_DEV_CAP2  = CFG_SCRATCH_SPACE + 44;
         RP_LINK_CAP  = CFG_SCRATCH_SPACE + 48;

         // Read the RP PCI Express Capabilities (at a known address in the MegaCore
         // function)
         if (display_rp_config==1 & ~TL_BFM_MODE) begin
            ebfm_display_rc_link_status_reg (RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, RP_LINK_CTRL);
            ebfm_display_link_control_reg   (1, RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, RP_LINK_CTRL);
         end

         if (TL_BFM_MODE) begin
             rp_pcie_cap_r = TL_BFM_RP_CAP_REG;
             rp_dev_cap_r = TL_BFM_RP_DEV_CAP_REG;
         end
         else begin
             ebfm_cfgrd_nowt(RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, 128, 4, RP_PCIE_CAP);
             ebfm_cfgrd_nowt(RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, 128 + 36, 4, RP_DEV_CAP2);
             ebfm_cfgrd_nowt(RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, 128 + 12, 4, RP_LINK_CAP);
             ebfm_cfgrd_wait(RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, 132 , 4, RP_DEV_CAP, compl_status);

             rp_pcie_cap_r = shmem_read(RP_PCIE_CAP, 4);
             rp_dev_cap_r  = shmem_read(RP_DEV_CAP, 4);
         end

         // Check for correct PCI-Express Capability ID
         if ((rp_pcie_cap_r[7:0] != 8'h10) & ~TL_BFM_MODE)
         begin
            dummy = ebfm_display(EBFM_MSG_ERROR_FATAL_TB_ERR, "PCI Express Capabilities not at expected Root Port config address");
         end

         if (display_rp_config==1 & ~TL_BFM_MODE) begin
                display_pcie_cap(
                     1,
                     rp_pcie_cap_r,
                     rp_dev_cap_r,
                     shmem_read(RP_LINK_CAP, 4),
                     shmem_read(RP_DEV_CAP2, 4)
                 );
          end

         //==========================================================
         // Configure Device Control Register at offset 0x8
         //==========================================================
         // Error Reporting Enables (RP BFM does not handle for now)
         //[0] = Correctable Error Reporting Enable
         //[1] = Non-Fatal Error Reporting Enable
         //[2] = Fatal Error Reporting Enable
         //[3] = Unsupported Request Reporting Enable
         rp_dev_control[3:0] = {4{1'b0}};
         //[4] = Enable Relaxed Ordering
         rp_dev_control[4] = 1'b1;

         //[8] = Extended Tag Field Enable
         if (EBFM_NUM_TAG > 32)
         begin
            rp_dev_control[8] = 1'b1;
         end
         else
         begin
            rp_dev_control[8] = 1'b0;
         end
         // [9] Disable Phantom Functions
         rp_dev_control[9] = 1'b0;
         // [10] Disable Aux Power PM Enable
         rp_dev_control[10] = 1'b0;
         // [11] Enable No Snoop
         rp_dev_control[11] = 1'b0;

         if (~TL_BFM_MODE) begin
             ebfm_cfgwr_imm_nowt(RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, PCIE_CAP_PTR + 8, 4, {16'h0000, rp_dev_control});
         end

         if (display_rp_config==1 & ~TL_BFM_MODE) begin
             ebfm_display_dev_control_status_reg(1, RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, RP_LINK_CTRL);
             ebfm_display_vc(1, RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, RP_LINK_CTRL) ;
         end

      end
   endtask

//=============================================

   task ebfm_display_rc_link_status_reg;
      input    bnm; // RP BUSNO
      integer  bnm;
      input    dev; // RP DEVNO
      integer  dev;
      input    fnc; // RP Func
      integer  fnc;
      input    CFG_SCRATCH_SPACE; // for Link Control read data
      integer  CFG_SCRATCH_SPACE;

      reg[2:0] compl_status;
      reg[15:0] link_sts;
      reg[15:0] link_ctrl;
      reg[15:0] link_cap;
      reg[15:0] ep_cfbp_link_control2_reg;

      reg dummy ;

      time time_stamp ;
      localparam TIMEOUT = 2000000000;

      begin
         ebfm_cfgrd_wait(bnm, dev, fnc, PCIE_CAP_PTR + 16, 4, CFG_SCRATCH_SPACE, compl_status);
         link_sts  = shmem_read(CFG_SCRATCH_SPACE + 2, 2);
         link_ctrl = shmem_read(CFG_SCRATCH_SPACE,2);

         ebfm_cfgrd_wait(bnm, dev, fnc, PCIE_CAP_PTR + 12, 4, CFG_SCRATCH_SPACE, compl_status);
         link_cap = shmem_read(CFG_SCRATCH_SPACE ,2);

         dummy = ebfm_display(EBFM_MSG_INFO, {"  RP PCI Express Link Capability Register (", himage4(link_cap), "):"});
         dummy = ebfm_display(EBFM_MSG_INFO, {"  RP PCI Express Link Status Register (", himage4(link_sts), "):"});
         dummy = ebfm_display(EBFM_MSG_INFO, {"  RP PCI Express Max Link Speed (", himage4(link_cap[3:0]), "):"});
         dummy = ebfm_display(EBFM_MSG_INFO, {"  RP PCI Express Current Link Speed (", himage4(link_sts[3:0]), "):"});
         dummy = ebfm_display(EBFM_MSG_INFO, {"    Negotiated Link Width: x", dimage1(link_sts[9:4])}) ;


         if ((link_sts[12]) == 1'b1) // Slot Clock Configuration is set in Link Status[12] indicates common clock 
         begin
            dummy = ebfm_display(EBFM_MSG_INFO, "        Slot Clock Config: System Reference Clock Used and retrain the link");
            // Setting common clk cfg bit at bit[6] of Link Control Register at Offset 0x10 (16)
            link_ctrl = 16'h0040 | link_ctrl;
            ebfm_cfgwr_imm_wait(bnm,dev,fnc,144,2, {16'h0000, link_ctrl}, compl_status);
            // retrain the link
            if (~TL_BFM_MODE) begin
                 ebfm_cfgwr_imm_wait(RP_PRI_BUS_NUM,RP_PRI_DEV_NUM,fnc,144,2, 32'h0000_0060, compl_status);
            end
         end
         else
         begin
            dummy = ebfm_display(EBFM_MSG_INFO, "        Slot Clock Config: Local Clock Used");
         end

         wait (top_tb.top_inst.dut.altpcie_sv_hip_ast_hwtcl.altpcie_hip_256_pipen1b.ltssmstate == 5'hf);

         // check link speed
         ebfm_cfgrd_wait(bnm, dev, fnc, PCIE_CAP_PTR + 16, 4, CFG_SCRATCH_SPACE, compl_status);
         link_sts  = shmem_read(CFG_SCRATCH_SPACE + 2, 2);
         if (link_sts[3:0] == 4'h1)
           dummy = ebfm_display(EBFM_MSG_INFO, {"       Current Link Speed: 2.5GT/s"}) ;
         else if (link_sts[3:0] == 4'h2)
           dummy = ebfm_display(EBFM_MSG_INFO, {"       Current Link Speed: 5.0GT/s"}) ;
         else if (link_sts[3:0] == 4'h3)
           dummy = ebfm_display(EBFM_MSG_INFO, {"       Current Link Speed: 8.0GT/s"}) ;
         else
           dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, {"       Current Link Speed is Unsupported"}) ;

         ep_cfbp_link_control2_reg = top_tb.top_inst.dut.cfgbp_link2csr;

         time_stamp <= $time ;
         // Wait for the link to come up to the expected speed if the Target Link Speed of the EP Link Control register 
         // is the same as RP Current Link Speed in the Link Status Register
         while (link_sts[3:0] != ep_cfbp_link_control2_reg[3:0]) 
         begin
             if (~TL_BFM_MODE) begin
                // Write to Link Control register
                 //ebfm_cfgwr_imm_wait(RP_PRI_BUS_NUM,RP_PRI_DEV_NUM,fnc,144,2, 32'h0000_0020, compl_status);
                 ebfm_cfgwr_imm_wait(RP_PRI_BUS_NUM,RP_PRI_DEV_NUM,fnc,PCIE_CAP_PTR + 16,2, 32'h0000_0020, compl_status);
             end

             // Reading link_sts[3:0] until it is equal link_cap[3:0] or timeout
             ebfm_cfgrd_wait(bnm, dev, fnc, PCIE_CAP_PTR + 16, 4, CFG_SCRATCH_SPACE, compl_status);
             link_sts  = shmem_read(CFG_SCRATCH_SPACE + 2, 2);
            
            //dummy = ebfm_display(EBFM_MSG_INFO, {"Debug: RP PCI Express Max Link Speed (", himage4(link_cap[3:0]), "):"});
            //dummy = ebfm_display(EBFM_MSG_INFO, {"Debug: RP PCI Express Current Link Speed (", himage4(link_sts[3:0]), "):"});

            if ( ($time - time_stamp) >= TIMEOUT)
            begin
               dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, "ERROR: Link speed does not match with value in Link_Cap[3:0] => Simulation stopped!");
            end
               time_stamp <= $time ;
         end

         dummy = ebfm_display(EBFM_MSG_INFO, {"Wait for Link to enter L0 after negotiated to the expected speed of EP Target Link Speed (", himage4(ep_cfbp_link_control2_reg[3:0]), "):"}) ;
         wait (top_tb.top_inst.dut.altpcie_sv_hip_ast_hwtcl.altpcie_hip_256_pipen1b.ltssmstate == 5'hf);
         // Make sure the config Rd is not sent before the retraining starts
         ebfm_cfgrd_wait(bnm, dev, fnc, PCIE_CAP_PTR + 16, 4, CFG_SCRATCH_SPACE, compl_status);
         link_sts  = shmem_read(CFG_SCRATCH_SPACE + 2, 2);
         if (link_sts[3:0] == 4'h1)
             dummy = ebfm_display(EBFM_MSG_INFO, {"           New Link Speed: 2.5GT/s"}) ;
         else if (link_sts[3:0] == 4'h2)
             dummy = ebfm_display(EBFM_MSG_INFO, {"           New Link Speed: 5.0GT/s"}) ;
         else if (link_sts[3:0] == 4'h3)
             dummy = ebfm_display(EBFM_MSG_INFO, {"           New Link Speed: 8.0GT/s"}) ;
         else
             dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, {"       New Link Speed is Unsupported"}) ;

         if (link_sts[3:0] != link_cap[3:0])
           dummy = ebfm_display(EBFM_MSG_INFO, "           Link fails to operate at Maximum Rate") ;

     dummy = ebfm_display(EBFM_MSG_INFO,"");


      end
   endtask

//======================================================================
// The following tasks were in altpcietb_bfm_driver_chaining.v
//======================================================================
   // purpose: Performs all of the steps neccesary to configure the
   // root port and the endpoint on the link
   task ebfm_cfg_rp_ep_generic;
      input integer bar_table;
      input integer ep_bus_num;
      input integer ep_dev_num;
      input integer ep_func;
      input integer rp_max_rd_req_size;
      input integer display_ep_config;    // 1 to display
      input integer display_rp_config;    // 1 to display
      input         addr_map_4GB_limit;
      // Add ouput base to be used for enumerating other functions
      inout[31:0] io_min;
      inout[31:0] io_max;
      inout[63:0] m32min;
      inout[63:0] m32max;
      inout[63:0] m64min;
      inout[63:0] m64max;

      reg[31:0] io_min_v;
      reg[31:0] io_max_v;
      reg[63:0] m32min_v;
      reg[63:0] m32max_v;
      reg[63:0] m64min_v;
      reg[63:0] m64max_v;

      reg[2:0] compl_status;
      reg      bar_ok;

      reg dummy ;

      integer i ;

      begin  


         io_min_v = io_min;
         io_max_v = io_max;
         m32min_v = m32min;
         m32max_v = m32max;
         m64min_v = m64min;
         m64max_v = m64max;

         if  (display_rp_config == 1'b1) begin // Limit the BAR allocation to less than 4GB
           m32max_v[31:0] = m32max_v[31:0] & 32'h7fff_ffff;
           m64min_v = 64'h0000_0000_8000_0000;
         end

         // Wait until the Root Port is done being reset before proceeding further
         #10;

         req_intf_wait_reset_end;

         // Unlock the bfm shared memory for initialization
         bfm_shmem_common.protect_bfm_shmem = 1'b0;

         if (TL_BFM_MODE) begin
             dummy = ebfm_display(EBFM_MSG_INFO, "*****************************************************************************************");
             dummy = ebfm_display(EBFM_MSG_INFO, "   In TL-ONLY SIMULATION MODE -- Bypassing Data Link Layer, Phy Layer, and Transceiver");
             dummy = ebfm_display(EBFM_MSG_INFO, "*****************************************************************************************");

         end

         if (~TL_BFM_MODE) begin
             // Perform the basic configuration of the Root Port
             ebfm_cfg_rp_basic((ep_bus_num - RP_PRI_BUS_NUM), 1);
         end

         if (((display_ep_config == 1) | (display_rp_config == 1)) & ~TL_BFM_MODE) begin
            dummy = ebfm_display(EBFM_MSG_INFO, "Completed initial configuration of Root Port.");
         end

         // Ensure link is at L0
         wait (top_tb.top_inst.dut.altpcie_sv_hip_ast_hwtcl.altpcie_hip_256_pipen1b.ltssmstate == 5'hf);

         if (display_ep_config == 1)
         begin
            ebfm_display_read_only(0, (ep_bus_num - RP_PRI_BUS_NUM), 1, 0, CFG_SCRATCH_SPACE);
            ebfm_display_msi(ep_bus_num,1,0,CFG_SCRATCH_SPACE) ;
            ebfm_display_msix(ep_bus_num,1,0,CFG_SCRATCH_SPACE) ;
            ebfm_display_aer(0, ep_bus_num,1,0,CFG_SCRATCH_SPACE) ;
         end

         if (display_rp_config == 1 & ~TL_BFM_MODE) begin
             // dummy write to ensure link is at L0
             //ebfm_cfgwr_imm_wait(ep_bus_num, ep_dev_num, ep_func, 4, 4, 32'h00000007, compl_status);

             ebfm_display_read_only(1, RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, CFG_SCRATCH_SPACE);
             ebfm_display_rp_bar(RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, CFG_SCRATCH_SPACE);
             ebfm_display_msi(RP_PRI_BUS_NUM,RP_PRI_DEV_NUM,0,CFG_SCRATCH_SPACE) ;
             ebfm_display_aer(1, RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, CFG_SCRATCH_SPACE) ;
             ebfm_display_slot_cap (1, RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, CFG_SCRATCH_SPACE) ;
         end

         ebfm_cfg_pcie_cap((ep_bus_num - RP_PRI_BUS_NUM), 1, 0, CFG_SCRATCH_SPACE, rp_max_rd_req_size, display_ep_config, display_rp_config);

         // Configure BARs (Throw away the updated min/max addresses)
         ebfm_cfg_bars(ep_bus_num, ep_dev_num, ep_func, bar_table, bar_ok,
                       io_min_v, io_max_v, m32min_v, m32max_v, m64min_v, m64max_v,
                       display_ep_config, addr_map_4GB_limit);
         if (bar_ok == 1'b1)
         begin
            if ((display_ep_config == 1) | (display_rp_config == 1))
            begin
               dummy = ebfm_display(EBFM_MSG_INFO, "Completed configuration of Endpoint BARs.");
            end
         end
         else
         begin
            dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, "Unable to assign all of the Endpoint BARs.");
         end

         if (~TL_BFM_MODE) begin
             // Configure Root Port Address Windows
             ebfm_cfg_rp_addr(
             (m32max_v + 1),    // Pref32 grew down
             (m64min_v - 1),    // Pref64 grew up
             (EBFM_BAR_M32_MIN),    // NonP started here
             (m32min_v[31:0] - 1),  // NonP ended here
             (EBFM_BAR_IO_MIN), // I/O Started Here
             (io_min_v - 1));   // I/O ended Here
         end

         ebfm_cfgwr_imm_wait(ep_bus_num, ep_dev_num, ep_func, 4, 4, 32'h00000007, compl_status);

         // Protect the critical BFM data from being accidentally overwritten.
         bfm_shmem_common.protect_bfm_shmem = 1'b1;
         
         // Save the new starting memory bases to be used for enumerating other functions
         io_min = io_min_v;
         io_max = io_max_v;
         m32min = m32min_v;
         m32max = m32max_v;
         m64min = m64min_v;
         m64max = m64max_v;
      end
   endtask

//=======================================================================
// my_test:
//   Demonstrate how to use config_rd, config_wr, mrd, and mwr to 32bit
//   registers or bursting it
//=======================================================================
task my_test (
   input use_config_bypass_hwtcl,
   input integer bar_table,       // Pointer to the BAR sizing and
   input integer setup_bar);        // Pointer to the BAR sizing and

   // Local parameters
//   localparam  CFG_SHARE_RD = SCR_MEM_DOWNSTREAM_RD; 

   localparam  REG_SHARE_RD = SCR_MEM_DOWNSTREAM_RD + 32'h200;
   localparam  REG_SHARE_WR = SCR_MEM_DOWNSTREAM_WR + 32'h200;

   localparam  MEM_SHARE_RD = SCR_MEM_DOWNSTREAM_RD + 32'h400;
   localparam  MEM_SHARE_WR = SCR_MEM_DOWNSTREAM_WR + 32'h400;
   
   localparam  REG0_ADDR = 32'h0; // Offset from setup_bar
   localparam  REG1_ADDR = 32'h4; // Offset from setup_bar
   localparam  MEM0_ADDR = 32'h0; // Offset from setup_bar
   localparam  MEM1_ADDR = 32'h4; // Offset from setup_bar

   // variables
   reg         unused_result ;
   reg [31:0]  wdata, rdata;        // 32b General purpose write data
   reg [31:0]  epmem_address;       // EP memory address offset from current setup_bar
   reg [31:0]  config_address;      // Config_address
   reg [ 2:0]  compl_status;

   integer     dw_byte_length;      // downstream memory wr/rd length in byte
   integer     burst_byte_length;   // downstream config wr/rd length in byte
   integer     max_len, min_len, inc_len;
   integer     ep_bus, ep_dev, ep_func;
   integer     mem_addr;

   begin

      unused_result = ebfm_display(EBFM_MSG_INFO, `STR_SEP);
      unused_result = ebfm_display(EBFM_MSG_INFO, "TASK:my_test => Setup");

      max_len           = 20; // in byte
      min_len           = 2;
      inc_len           = 10;
      dw_byte_length    = 4; 
      wdata             = 32'hbabeface;

     //=========================
     // 1. 32bit Register access
     //=========================
     // Even address
      unused_result = ebfm_display(EBFM_MSG_INFO, `STR_SEP);
      unused_result = ebfm_display(EBFM_MSG_INFO, {"TASK: 1.11 Write to 32bit register at addr = 0x", himage8(REG0_ADDR), " with wdata=0x", himage8(wdata)});
      ebfm_barwr_imm(   bar_table,      // BAR table in the host memory
                        setup_bar,      // Current BAR that contains the register 
                        REG0_ADDR,       // Register address offset from the current setup_bar
                        wdata,          // Write data value
                        dw_byte_length, // byte_len => 4B = 32bits
                        0);             // Traffic Class => always zero for this bench


      unused_result = ebfm_display(EBFM_MSG_INFO, {"TASK: 1.12 Read from 32bit register at addr = 0x", himage8(REG0_ADDR)});
      ebfm_barrd_wait(  bar_table,      // BAR table in the host memory
                        setup_bar,      // Current BAR that contains the register 
                        REG0_ADDR,       // Register address offset from the current setup_bar
                        REG_SHARE_RD,   // Share memory where read_data is stored
                        dw_byte_length, // byte_len => 4B = 32bits
                        0); 

      rdata = shmem_read(REG_SHARE_RD,dw_byte_length) ;

      if (rdata != wdata) 
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"TASK:1.13  Mismatched reg data: Expected = 0x", himage8(wdata), " -- Actual = 0x", himage8(rdata)}); 
      else 
          unused_result = ebfm_display(EBFM_MSG_INFO, "TASK: 1.13  Register compare matches!");
      
      
     // odd address
      wdata             = 32'h12345678;
      unused_result = ebfm_display(EBFM_MSG_INFO, `STR_SEP);
      unused_result = ebfm_display(EBFM_MSG_INFO, {"TASK: 1.21 Write to 32bit register at addr = 0x", himage8(REG1_ADDR), " -- Actual = 0x", himage8(wdata)});
      ebfm_barwr_imm(   bar_table,      // BAR table in the host memory
                        setup_bar,      // Current BAR that contains the register 
                        REG1_ADDR,       // Register address offset from the current setup_bar
                        wdata,          // Write data value
                        dw_byte_length, // byte_len => 4B = 32bits
                        0);             // Traffic Class => always zero for this bench


      unused_result = ebfm_display(EBFM_MSG_INFO, {"TASK: 1.22 Read from 32bit register at addr = 0x", himage8(REG1_ADDR)});
      ebfm_barrd_wait(  bar_table,      // BAR table in the host memory
                        setup_bar,      // Current BAR that contains the register 
                        REG1_ADDR,       // Register address offset from the current setup_bar
                        REG_SHARE_RD,   // Share memory where read_data is stored
                        dw_byte_length, // byte_len => 4B = 32bits
                        0); 

      rdata = shmem_read(REG_SHARE_RD,dw_byte_length) ;

      if (rdata != wdata) 
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"TASK: 1.23  Mismatched reg data: Expected = 0x", himage8(wdata), " -- Actual = 0x", himage8(rdata)}); 
      else 
          unused_result = ebfm_display(EBFM_MSG_INFO, "TASK: 1.23  Register compare matches!");
     //=========================
     // 2. Memory burst access
     //=========================
     // Burst with Even address
         unused_result = ebfm_display(EBFM_MSG_INFO, `STR_SEP);
         unused_result = ebfm_display(EBFM_MSG_INFO, "TASK: 2.11 Fill write memory with QWORD_INC pattern");

         mem_addr          = MEM0_ADDR;
         burst_byte_length = min_len;  
         wdata             = 32'h10203040;   // Start write data pattern
         
         while (burst_byte_length < max_len) begin
            shmem_fill(MEM_SHARE_WR, SHMEM_FILL_QWORD_INC, burst_byte_length, wdata);

            unused_result = ebfm_display(EBFM_MSG_INFO, {"TASK: 2.12 Memory write burst at addr=0x", himage2(mem_addr), " with wdata=0x", himage8(wdata)});
            ebfm_barwr( bar_table,        // BAR table in the host memory
                        setup_bar,        // Current BAR that contains the register 
                        mem_addr,         // Start memory address => offset from setup_bar
                        MEM_SHARE_WR,     // Start host shared memory address where write data are stored
                        burst_byte_length,// Burst length in byte 
                        0);               // Traffic Class (always 0)

            unused_result = ebfm_display(EBFM_MSG_INFO, "TASK: 2.21 Memory Read burst");
            // Initialize MEM_SHARE_RD 
            shmem_fill(MEM_SHARE_RD, SHMEM_FILL_QWORD_INC,burst_byte_length,64'hFADE_FADE_FADE_FADE); 

            // Read data and store them in MEM_SHARE_RD
            ebfm_barrd_wait(  bar_table,        // BAR table in the host memory
                        setup_bar,        // Current BAR that contains the register
                        mem_addr,         // Start memory address => offset from setup_bar
                        MEM_SHARE_RD,     // Start host shared memory address where read data are stored
                        burst_byte_length,// Burst length in byte
                        0);               // Traffic Class (always 0)
     
            if (!use_config_bypass_hwtcl) begin
               unused_result = ebfm_display(EBFM_MSG_INFO, "TASK: 2.3 Check for memory read/write data");
               scr_memory_compare(burst_byte_length,
                         MEM_SHARE_WR,
                         MEM_SHARE_RD);
            end
            // Increment burst length and address
            mem_addr          = mem_addr + 4;
            burst_byte_length = burst_byte_length + inc_len;

         end
     //==========================
     // Burst with odd address
     //==========================

         mem_addr          = MEM1_ADDR;
         burst_byte_length = min_len;

         while (burst_byte_length < max_len) begin
            unused_result = ebfm_display(EBFM_MSG_INFO, `STR_SEP);
            unused_result = ebfm_display(EBFM_MSG_INFO, "TASK: 2.11 Fill write memory with QWORD_INC pattern");
            wdata             = 32'h50607080;   // Start write data pattern
            shmem_fill(MEM_SHARE_WR, SHMEM_FILL_QWORD_INC, burst_byte_length, wdata);

            unused_result = ebfm_display(EBFM_MSG_INFO, {"TASK: 2.12 Memory write burst at addr=0x", himage2(mem_addr), " with wdata=0x", himage8(wdata)});
            ebfm_barwr(    bar_table,        // BAR table in the host memory
                        setup_bar,        // Current BAR that contains the register 
                        mem_addr,        // Start memory address => offset from setup_bar
                        MEM_SHARE_WR,     // Start host shared memory address where write data are stored
                        burst_byte_length,// Burst length in byte 
                        0);               // Traffic Class (always 0)

            unused_result = ebfm_display(EBFM_MSG_INFO, "TASK: 2.21 Memory Read burst");
            // Initialize MEM_SHARE_RD 
            shmem_fill(MEM_SHARE_RD, SHMEM_FILL_QWORD_INC,burst_byte_length,64'hFADE_FADE_FADE_FADE); 

            // Read data and store them in MEM_SHARE_RD
            ebfm_barrd_wait(  bar_table,        // BAR table in the host memory
                        setup_bar,        // Current BAR that contains the register
                        mem_addr,        // Start memory address => offset from setup_bar
                        MEM_SHARE_RD,     // Start host shared memory address where read data are stored
                        burst_byte_length,// Burst length in byte
                        0);               // Traffic Class (always 0)
     
            if (!use_config_bypass_hwtcl) begin
               unused_result = ebfm_display(EBFM_MSG_INFO, "TASK: 2.3 Check for memory read/write data");
               scr_memory_compare(burst_byte_length,
                         MEM_SHARE_WR,
                         MEM_SHARE_RD);
            end
            // Increment burst length and address
            mem_addr          = mem_addr + 4;
            burst_byte_length = burst_byte_length + inc_len;

         end // while loop   

 end // task
endtask

task cfg_rd_modified_wr (
   input integer  ep_bus,
   input integer  ep_dev,
   input integer  ep_func,
   input [31:0]   cfg_addr,
   input [31:0]   cfg_wdata,
   input          check_en
   );  

   // Local parameters
   reg         unused_result ;
   reg [31:0]  rdata, new_wdata;        // 32b General purpose write data
   reg [ 2:0]  compl_status;
   integer     dw_byte_length;      // downstream memory wr/rd length in byte

   begin
     
     dw_byte_length = 4;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"Read Modified WRite to config register = 0x", himage8(cfg_addr), " in func = 0x", himage8(ep_func)});

     unused_result = ebfm_display(EBFM_MSG_INFO, `STR_SEP);
     unused_result = ebfm_display(EBFM_MSG_INFO, "Read config reg");
     ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_dev,           // EP Dev number 
                           ep_func,          // EP Func number
                           cfg_addr,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);     // Completion Status

     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"Original config read data = ", himage8(rdata)});
     new_wdata = rdata | cfg_wdata; 

     unused_result = ebfm_display(EBFM_MSG_INFO, {"Config write with data = ", himage8(new_wdata)});
     ebfm_cfgwr_imm_wait (
                           ep_bus,           // EP Bus number
                           ep_dev,           // EP Dev number 
                           ep_func,          // EP Func number
                           cfg_addr,         // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           new_wdata,        // Config Write data 
                           compl_status);    // Completion Status

    if (check_en) begin
         ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_dev,           // EP Dev number 
                           ep_func,          // EP Func number
                           cfg_addr,         // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);    // Completion Status

         rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;

         //=========================================================================
         // Since only two functions are supported for config_bypass, only compare
         // the result when it is func0 or func1
         //=========================================================================
         if ((rdata != new_wdata) & (ep_func < 2) )
            unused_result = ebfm_display (EBFM_MSG_ERROR_FATAL, {"Error: Mismatched: Expected = ", himage8(new_wdata), "  -----, ", "Actual = ", himage8(rdata)}); 
         else 
            unused_result = ebfm_display(EBFM_MSG_INFO, {"After cfg_rd_modified_wr, config_data = 0x", himage8(rdata)});
      end // check_en    

  end // task
endtask

//=======================================================
// Enumerate the Config Space based on function number
//=======================================================
task enum_ep_cfg_space(
   input integer  ep_bus,
   input integer  ep_dev,
   input integer  ep_func,
   input integer  bar_table,
   input integer  display_ep_config,    // 1 to display
   input addr_map_4GB_limit
   );        // Pointer to the BAR sizing and

   // Local parameters
   localparam  CFG_SHARE_RD = SCR_MEM_DOWNSTREAM_RD; 

  
   // Local variables
   reg         unused_result ;
   reg [31:0]  wdata, rdata, exp_data;        // 32b General purpose write data
   reg [31:0]  epmem_address;       // EP memory address offset from current setup_bar
   reg [31:0]  config_address;      // Config_address
   reg [ 2:0]  compl_status;

   reg[31:0] io_min_v;
   reg[31:0] io_max_v;
   reg[63:0] m32min_v;
   reg[63:0] m32max_v;
   reg[63:0] m64min_v;
   reg[63:0] m64max_v;

   integer     dw_byte_length;      // downstream memory wr/rd length in byte
   reg         bar_ok;
   reg         check_en;

   begin
     check_en = 1;

     io_min_v = EBFM_BAR_IO_MIN ;
     io_max_v = EBFM_BAR_IO_MAX ;
     m32min_v = {32'h00000000,EBFM_BAR_M32_MIN};
     m32max_v = {32'h00000000,EBFM_BAR_M32_MAX};
     m64min_v = EBFM_BAR_M64_MIN;
     m64max_v = EBFM_BAR_M64_MAX;

     dw_byte_length = 4;
     //================================
     // Enumerate Config Space for EP
     //================================
     unused_result = ebfm_display(EBFM_MSG_INFO, {"cfgbp_enum_config_space =>  Setup config space for func = ", himage8(ep_func)});

     //=========================
     // 1. Config Read access
     //=========================
     config_address = {DEV_VENDOR_ID, 2'h0};
     exp_data       = 32'hE0011172;

      unused_result = ebfm_display(EBFM_MSG_INFO, " Config Read");
      ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_dev,           // EP Dev number 
                           ep_func,          // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);     // Completion Status

     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     if (rdata != exp_data) begin
         unused_result = ebfm_display (EBFM_MSG_ERROR_FATAL, {"Error: Mismatched: Expected = ", himage8(exp_data), "  -----, ", "Actual = ", himage8(rdata)}); 
     end else begin
         unused_result = ebfm_display (EBFM_MSG_INFO, {"CfgRD at addr =0x", himage8(config_address), " returns data = 0x", himage8(rdata)});
     end


     //============================
     // 2. Status Command register
     //============================
     unused_result = ebfm_display(EBFM_MSG_INFO, `STR_SEP);
     unused_result = ebfm_display(EBFM_MSG_INFO, {"Set Bus_Master and Memory_Space_Enable bit in Command register", himage8(ep_func)});
     cfg_rd_modified_wr (ep_bus, ep_func, ep_func, {STATUS_COMMAND, 2'h0}, 32'h6, 0);

     //=========================
     // 3. Setup BAR registers
     //=========================
     config_address = {BAR0_REG, 2'h0};
     wdata = 32'hFFFFFFFF;
     // Write all F to BAR0
     ebfm_cfgwr_imm_wait (
                           ep_bus,           // EP Bus number
                           ep_dev,           // EP Dev number 
                           ep_func,          // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           wdata,            // Config Write data 
                           compl_status);    // Completion Status

      // Read back to check for size
      ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_dev,           // EP Dev number 
                           ep_func,          // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);     // Completion Status

     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     unused_result = ebfm_display (EBFM_MSG_INFO, {"CfgRD at BAR0 (addr =0x", himage8(config_address), ") returns data = 0x", himage8(rdata)});

     // Setup the base address
     wdata = 32'h80000000;
     ebfm_cfgwr_imm_wait (
                           ep_bus,           // EP Bus number
                           ep_dev,           // EP Dev number 
                           ep_func,          // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           wdata,            // Config Write data 
                           compl_status);    // Completion Status

      // Read back to check for size
      ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_dev,           // EP Dev number 
                           ep_func,          // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);     // Completion Status

     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     if (rdata[31:4] != wdata[31:4]) begin
         unused_result = ebfm_display (EBFM_MSG_ERROR_FATAL, {"Error: Mismatched: Expected = ", himage8(wdata), "  -----, ", "Actual = ", himage8(rdata)}); 
     end else begin
         unused_result = ebfm_display (EBFM_MSG_INFO, {"CfgRD at addr =0x", himage8(config_address), " returns data = 0x", himage8(rdata)});
     end

    // Unlock the bfm shared memory for initialization
     bfm_shmem_common.protect_bfm_shmem = 1'b0;

     ebfm_cfg_bars(ep_bus, ep_dev, ep_func, bar_table, bar_ok,
                       io_min_v, io_max_v, m32min_v, m32max_v, m64min_v, m64max_v,
                       display_ep_config, addr_map_4GB_limit);

     if (bar_ok == 1'b1) begin
        if (display_ep_config == 1) begin
           unused_result = ebfm_display(EBFM_MSG_INFO, "Completed configuration of Endpoint BARs.");
        end
     end else begin
           unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, "Unable to assign all of the Endpoint BARs.");
     end

    // Protect the critical BFM data from being accidentally overwritten.
     bfm_shmem_common.protect_bfm_shmem = 1'b1;

   end
endtask
//=======================================================
// Enumerate the Config Space based on function number
//=======================================================
task enum_ep_BARs(
   input integer  ep_bus,
   input integer  ep_dev,
   input integer  ep_func,
   input integer  bar_table,
   input integer  display_ep_config,    // 1 to display
   input          addr_map_4GB_limit,

   // Add ouput base to be used for enumerating other functions
   inout[31:0] io_min,
   inout[31:0] io_max,
   inout[63:0] m32min,
   inout[63:0] m32max,
   inout[63:0] m64min,
   inout[63:0] m64max
 
   );        // Pointer to the BAR sizing and

   // Local parameters
   localparam  CFG_SHARE_RD = SCR_MEM_DOWNSTREAM_RD; 

   // Local variables
   reg         unused_result ;
   reg [31:0]  wdata, rdata, exp_data;        // 32b General purpose write data
   reg [31:0]  epmem_address;       // EP memory address offset from current setup_bar
   reg [31:0]  config_address;      // Config_address
   reg [ 2:0]  compl_status;

   reg[31:0] io_min_v;
   reg[31:0] io_max_v;
   reg[63:0] m32min_v;
   reg[63:0] m32max_v;
   reg[63:0] m64min_v;
   reg[63:0] m64max_v;

   reg         bar_ok;
   reg         check_en;

   begin
     check_en = 0;

     io_min_v = io_min;
     io_max_v = io_max;
     m32min_v = m32min;
     m32max_v = m32max;
     m64min_v = m64min;
     m64max_v = m64max;

     if  (display_ep_config == 1'b1) begin // Limit the BAR allocation to less than 4GB
           m32max_v[31:0] = m32max_v[31:0] & 32'h7fff_ffff;
           m64min_v = 64'h0000_0000_8000_0000;
     end

     //================================
     // Enumerate Config Space for EP
     //================================
     unused_result = ebfm_display(EBFM_MSG_INFO, {"Setup BARs for EP for function = 0x", himage8(ep_func)});

     //============================
     // 2. Status Command register: Set memory_enable=1 and bus_master=1
     //============================
     unused_result = ebfm_display(EBFM_MSG_INFO, `STR_SEP);
     unused_result = ebfm_display(EBFM_MSG_INFO, {"Set Bus_Master and Memory_Space_Enable bit in Command register for function = 0x", himage8(ep_func)});
     cfg_rd_modified_wr (ep_bus, ep_func, ep_func, {STATUS_COMMAND, 2'h0}, 32'h7, check_en);

     //================================
     // Setup BAR for PF function
     //================================
    // Unlock the bfm shared memory for initialization
     bfm_shmem_common.protect_bfm_shmem = 1'b0;

     ebfm_cfg_bars(ep_bus, ep_dev, ep_func, bar_table, bar_ok,
                       io_min_v, io_max_v, m32min_v, m32max_v, m64min_v, m64max_v,
                       display_ep_config, addr_map_4GB_limit);

     if (bar_ok == 1'b1) begin
        if (display_ep_config == 1) begin
           unused_result = ebfm_display(EBFM_MSG_INFO, "Completed configuration of Endpoint BARs.");
        end
     end else begin
           unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, "Unable to assign all of the Endpoint BARs.");
     end

     //================================
     // Setup BAR for root port
     //================================
         unused_result = ebfm_display(EBFM_MSG_INFO, "Setup RP BARs");
         if (~TL_BFM_MODE) begin
             // Configure Root Port Address Windows
             ebfm_cfg_rp_addr(
             (m32max_v + 1),        // Pref32 grew down
             (m64min_v - 1),        // Pref64 grew up
             (EBFM_BAR_M32_MIN),// NonP started here
             (m32min_v[31:0] - 1),  // NonP ended here
             (EBFM_BAR_IO_MIN), // I/O Started Here
             (io_min_v - 1));       // I/O ended Here
         end

         // Save the new starting memory bases to be used for enumerating other functions
         io_min = io_min_v;
         io_max = io_max_v;
         m32min = m32min_v;
         m32max = m32max_v;
         m64min = m64min_v;
         m64max = m64max_v;

    // Protect the critical BFM data from being accidentally overwritten.
     bfm_shmem_common.protect_bfm_shmem = 1'b1;

   end
endtask


//======================================
// Config test for 2Function
//======================================
task config_test (
   input integer  ep_bus,
   input integer  ep_dev,
   input integer  ep_func,
   input integer  bar_table,
   input integer  display_ep_config    // 1 to display
);

   // Local parameters
   localparam CFG_SHARE_RD = SCR_MEM_DOWNSTREAM_RD; 

   localparam CAPABILITY_REG       = 10'h34;

   localparam MSI_BASE_ADDR        = 10'h50;
   localparam MSI_LOWER_ADDR       = 10'h54;
   localparam MSI_UPPER_ADDR       = 10'h58;
   localparam MSI_DATA             = 10'h5C;

   localparam MSIX_BASE_ADDR       = 10'h68;
   localparam MSIX_TABLE_OFFSET    = 10'h6C;
   localparam MSIX_PBA_OFFSET      = 10'h70;

   localparam PM_CAP_BASE_ADDR     = 10'h78;
   localparam PM_CONTROL_STATUS    = 10'h7C;
   localparam PCIE_CAP_BASE_ADDR       = 10'h80;
   

   reg         unused_result ;
   reg [31:0]  wdata, rdata, exp_data, high_data;        // 32b General purpose write data
   reg [31:0]  epmem_address;       // EP memory address offset from current setup_bar
   reg [31:0]  config_address;      // Config_address
   reg [ 2:0]  compl_status;
   integer     dw_byte_length;      // downstream memory wr/rd length in byte
   reg         msix_present;
   
   begin
     unused_result = ebfm_display(EBFM_MSG_INFO, {"Check config_space for func = ", himage8(ep_func)});
     dw_byte_length    = 4; 
     wdata             = 32'hbabeface;

     //===============================================
     // 1. Read PCI Cap Pointer register at 0x34 and extract next pointer at [15:8]. Check that it is = 0x50 for MSI
      config_address = CAPABILITY_REG;
      ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_dev,           // EP Dev number 
                           ep_func,          // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);     // Completion Status

     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"Read from PCI Capabilities Pointer = ", himage8(rdata)});

     if (rdata[7:0] != MSI_BASE_ADDR ) 
         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Expected Next Cap Pointer = 0x", himage8(MSI_BASE_ADDR), " -- Actual = 0x", himage8(rdata[15:8])}); 
    

     //===============================================
     // 2. Read MSI Cap at 0x50 and check
     //    a. [ 7: 0] CapID = 0x5, 
     //       [15: 8] Next_Ptr = 0x68 for MSI-X
     //    b. [31:16] Message Control = 0x84  
     //       [15: 9] = 0 - when read (RS)
     //       [    8] = 1 - Per vector masking capable (RO)
     //       [    7] = 1 - 64b address capable (RO)
     //       [ 6: 4] = Multiple Message Enable encoded in power of 2 (R/W) (0=1, 1=2, 2=4, 3=8, 4=16, 5=32) (RW)
     //       [ 3: 1] = Multiple Message capable in power of 2 (R/W)        (0=1, 1=2, 2=4, 3=8, 4=16, 5=32) (RO)
     //       [    0] = MSI Enable 
     //    c. Read Lower MSI address
     //       [31:2]  = dword address if MSI_ENBLE bit is set, return 0 is disabled
     //       [ 1:0]  = Always return 0 on read
     //    d. Read Upper MSI address - Implemented if 64bit address capable. 
     //    e. Read message data for MSI
     //       [15:0] = Message data
     
      config_address = MSI_BASE_ADDR;
      ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_dev,           // EP Dev number 
                           ep_func,          // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);     // Completion Status

     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"Read from MSI Capability register = ", himage8(rdata)});

     if (rdata[7:0] != 8'h5) 
         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Invalid MSI Cap ID. Expected = 0x5 -- Actual = 0x", himage8(rdata[7:0])}); 

     if (rdata[15:8] != PM_CAP_BASE_ADDR) 
         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Expected Next Cap Pointer = 0x", himage8(PM_CAP_BASE_ADDR), " -- Actual = 0x", himage8(rdata[15:8])}); 
     
      high_data = {16'h0, rdata[31:16]};
      
      if (high_data[15:9] != 0) 
         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : MSI Reserved bit[15:9] must be zero -- Actual = 0x", himage8(rdata[15:9])}); 

      // Other bits
      unused_result = ebfm_display(EBFM_MSG_INFO, {"MSI Per Vector Masking Capable  = 0x", himage8(rdata[8])}); 
         
      if (high_data[7] == 0) 
         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : MSI does not support 64bit -- bit[7] = 0x", himage8(rdata[7])}); 

      unused_result = ebfm_display(EBFM_MSG_INFO, {"MSI  Multiple Message Enable  = 0x", himage8(rdata[6:4])}); 
      unused_result = ebfm_display(EBFM_MSG_INFO, {"MSI  Multiple Message capable = 0x", himage8(rdata[3:1])}); 
      unused_result = ebfm_display(EBFM_MSG_INFO, {"MSI  Multiple Enable          = 0x", himage8(rdata[0])}); 
      
      //---------------------------------
      // MSI Lower address
     //    c. Read Lower MSI address
     //       [31:2]  = dword address if MSI_ENBLE bit is set, return 0 is disabled
     //       [ 1:0]  = Always return 0 on read

      config_address = MSI_LOWER_ADDR;
     wdata    = 32'h1234567A;
     exp_data = 32'h12345678; // Lower two bits should be zero

      ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_dev,           // EP Dev number 
                           ep_func,          // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);     // Completion Status

     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"Read from MSI Lower Address at 0x54 = ", himage8(rdata)});

     // Setup the MSI Lower address

     unused_result = ebfm_display(EBFM_MSG_INFO, {"Write MSI Lower Address with wdata = ", himage8(wdata)});

     ebfm_cfgwr_imm_wait (
                           ep_bus,           // EP Bus number
                           ep_dev,           // EP Dev number 
                           ep_func,          // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           wdata,            // Config Write data 
                           compl_status);    // Completion Status

     ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_dev,           // EP Dev number 
                           ep_func,          // EP Func number
                           config_address,         // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);    // Completion Status

     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     if (rdata != exp_data) 
         unused_result = ebfm_display (EBFM_MSG_ERROR_FATAL, {"Error: Mismatched: Expected = ", himage8(exp_data), "  -----, ", "Actual = ", himage8(rdata)}); 

      //---------------------------------
      // MSI Upper address

     config_address = MSI_UPPER_ADDR;
     wdata    = 32'habcdef1a;
     exp_data = 32'habcdef1a; // Lower two bits should be zero

      ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_dev,           // EP Dev number 
                           ep_func,          // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);     // Completion Status

     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"Read from MSI Upper Address at 0x58 = ", himage8(rdata)});

     // Setup the MSI Upper address

     unused_result = ebfm_display(EBFM_MSG_INFO, {"Write MSI Upper Address with wdata = ", himage8(wdata)});

     ebfm_cfgwr_imm_wait (
                           ep_bus,           // EP Bus number
                           ep_dev,           // EP Dev number 
                           ep_func,          // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           wdata,            // Config Write data 
                           compl_status);    // Completion Status

     ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_dev,           // EP Dev number 
                           ep_func,          // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);    // Completion Status

     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"Write MSI Upper Address with rdata = ", himage8(rdata)});

     if (rdata != exp_data) 
         unused_result = ebfm_display (EBFM_MSG_ERROR_FATAL, {"Error: Mismatched: Expected = ", himage8(exp_data), "  -----, ", "Actual = ", himage8(rdata)}); 

      //---------------------------------
      // MSI Data

      config_address = MSI_DATA;
      wdata    = 32'h87654321;
      exp_data = 32'h4321; // Only bit[15:2] are writable and lower two bits should be zero

      ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_dev,           // EP Dev number 
                           ep_func,          // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);     // Completion Status

     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"Read from MSI Data = ", himage8(rdata)});

     ebfm_cfgwr_imm_wait (
                           ep_bus,           // EP Bus number
                           ep_dev,           // EP Dev number 
                           ep_func,          // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           wdata,            // Config Write data 
                           compl_status);    // Completion Status

     ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_dev,           // EP Dev number 
                           ep_func,          // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);    // Completion Status

     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     if (rdata != exp_data) 
         unused_result = ebfm_display (EBFM_MSG_ERROR_FATAL, {"Error: Mismatched: Expected = ", himage8(exp_data), "  -----, ", "Actual = ", himage8(rdata)}); 
     //===============================================
     // 3. Read MSI-X Cap at 0x68 and check
     //    a. [ 7: 0] CapID = 0x11, 
     //       [15: 8] Next_Ptr = 0x78 for PM Cap
     //    b. [31:16] Message Control = 0x84  
     //       [15   ] = MSI-X Enable (RW)
     //       [14   ] = Function Mask
     //       [13:11] = Reserved
     //       [10: 0] = Table Size
     //    c. Table Offset at 0x68 + 4 = 0x6C
     //       [31:3]  = Table Offset => function base address registers to point to the base of the MSI-X table (RO).
     //       [ 2:0] Table BIR => Indicate which base address register is used to map the MSI-X Table into Memory Space (0=10h, 1=14h, 2=18h, 3 = 1ch, 4 = 20h, 5 = 24h)
     //    d. PBA offset at 0x68 + 8 = 0x70
     //       [31:3]  = PBA Offset
     //       [ 2:0]  = PBA BIR
   msix_present = 0;
   if (msix_present) begin
      config_address = MSIX_BASE_ADDR;
      ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_dev,           // EP Dev number 
                           ep_func,          // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);     // Completion Status

     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"Read from MSIX Capability register = ", himage8(rdata)});

     if (rdata[7:0] != 8'h11) 
         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Invalid MSI Cap ID. Expected = 0x5 -- Actual = 0x", himage8(rdata[7:0])}); 

     if (rdata[15:8] != PM_CAP_BASE_ADDR) 
         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Expected Next Cap Pointer = 0x", himage8(PM_CAP_BASE_ADDR), " -- Actual = 0x", himage8(rdata[15:8])}); 
     
     //----------------
      high_data = {16'h0, rdata[31:16]};
      unused_result = ebfm_display(EBFM_MSG_INFO, {"MSI-X  Multiple Enable          = 0x", himage8(rdata[15])}); 
      unused_result = ebfm_display(EBFM_MSG_INFO, {"MSI-X  Functional Mask          = 0x", himage8(rdata[14])}); 

      if (high_data[13:11] != 0) 
         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : MSI-X Reserved bit[13:1] must be zero -- Actual = 0x", himage8(rdata[13:11])}); 

      unused_result = ebfm_display(EBFM_MSG_INFO, {"MSI-X Table Size = 0x", himage8(rdata[10:0])}); 
   end

     //===============================================
     // 4. PM Capabilty at 0x78 => Check PCI Bus Power Management Interface Specification, Rev 1.2 
     //    a. [ 7: 0] CapID = 0x1, 
     //       [15: 8] Next_Ptr = 0x80 for PCI-Express
     //       [31:16] PCI Express Cap Pointer
     //       [18:16] Version
     //       [19]    PM Clock
     //       [20]    Reserved
     //       [21]    Device Specification Initialization (DSI)
     //       [24:22] Aux Current
     //       [25]    D1 Support
     //       [26]    D2 Support
     //       [31:27] PME Support
//      config_address = PM_CAP_BASE_ADDR;
//      ebfm_cfgrd_wait(    
//                           ep_bus,           // EP Bus number
//                           ep_dev,           // EP Dev number 
//                           ep_func,          // EP Func number
//                           config_address,   // Config register address in byte 
//                           dw_byte_length,   // Byte length 
//                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
//                           compl_status);     // Completion Status
//
//     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
//     unused_result = ebfm_display(EBFM_MSG_INFO, {"Read from PM Capability register = ", himage8(rdata)});
//
//     if (rdata[7:0] != 8'h1) 
//         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Invalid PM Capability ID. Expected = 0x1 -- Actual = 0x", himage8(rdata[7:0])}); 
//
//     if (rdata[15:8]!= PCIE_CAP_BASE_ADDR) 
//         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Expected Next Cap Pointer = 0x", himage8(PCIE_CAP_BASE_ADDR), " -- Actual = 0x", himage8(rdata[15:8])}); 
//
//
//     if (rdata[18:16] != 3'h3) 
//         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Invalid PM Version Number. Expected = 0x3 -- Actual = 0x", himage8(rdata[18:16])}); 
//
//     // Check writable bits
//      wdata    = 32'hFFFFFFFF;
//
//     ebfm_cfgwr_imm_wait (
//                           ep_bus,           // EP Bus number
//                           ep_dev,           // EP Dev number 
//                           ep_func,          // EP Func number
//                           config_address,   // Config register address in byte 
//                           dw_byte_length,   // Byte length 
//                           wdata,            // Config Write data 
//                           compl_status);    // Completion Status
//
//     ebfm_cfgrd_wait(    
//                           ep_bus,           // EP Bus number
//                           ep_dev,           // EP Dev number 
//                           ep_func,          // EP Func number
//                           config_address,   // Config register address in byte 
//                           dw_byte_length,   // Byte length 
//                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
//                           compl_status);    // Completion Status
//
//     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
//     unused_result = ebfm_display(EBFM_MSG_INFO, {"Read from PM Base Register at 0x78 = ", himage8(rdata)});
//
//
//     if (rdata[7:0] != 8'h1) 
//         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Invalid PM Capability ID. Expected = 0x1 -- Actual = 0x", himage8(rdata[7:0])}); 
//
//     if (rdata[15:8]!= PCIE_CAP_BASE_ADDR) 
//         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Expected Next Cap Pointer = 0x", himage8(PCIE_CAP_BASE_ADDR), " -- Actual = 0x", himage8(rdata[15:8])}); 
//
//     if (rdata[31:16] != 3) 
//         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Invalid PM Capability bit[31:16]. Expected = 0x0 -- Actual = 0x", himage8(rdata[31:16])}); 
//     //===============================================
//     // 5. PM Control Status register at 0x7C 
//     // [1:0] = 0 Power State (RW)
//     // [7:0] = 0 (Reserved)
//     // [  8] = 0 PME Enable (RWS)
//     // [12:9] = 0 Data Select (RW)
//     // [14:13] = 0 Dat Scale (RO)
//     // [15]   = 1 PME Status (RW1CS) ??????
//
//      config_address = PM_CONTROL_STATUS;
//      ebfm_cfgrd_wait(    
//                           ep_bus,           // EP Bus number
//                           ep_dev,           // EP Dev number 
//                           ep_func,          // EP Func number
//                           config_address,   // Config register address in byte 
//                           dw_byte_length,   // Byte length 
//                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
//                           compl_status);     // Completion Status
//
//     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
//     unused_result = ebfm_display(EBFM_MSG_INFO, {"Read from PM Control Status register = ", himage8(rdata)});
//
//
//      wdata    = 32'hFFFFFFFF;
//    //exp_data = 32'h0008000; // Only PME Status bit at [15] = 1 
//      exp_data = 32'h0000000; // Only PME Status bit at [15] = 1 
//
//     ebfm_cfgwr_imm_wait (
//                           ep_bus,           // EP Bus number
//                           ep_dev,           // EP Dev number 
//                           ep_func,          // EP Func number
//                           config_address,   // Config register address in byte 
//                           dw_byte_length,   // Byte length 
//                           wdata,            // Config Write data 
//                           compl_status);    // Completion Status
//
//     ebfm_cfgrd_wait(    
//                           ep_bus,           // EP Bus number
//                           ep_dev,           // EP Dev number 
//                           ep_func,          // EP Func number
//                           config_address,   // Config register address in byte 
//                           dw_byte_length,   // Byte length 
//                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
//                           compl_status);    // Completion Status
//
//     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
//     unused_result = ebfm_display(EBFM_MSG_INFO, {"Read from PM Control Status register = ", himage8(rdata)});
//
//     //----------------------
//     // Check writable bits
//     if (rdata[7:2] != 0) 
//         unused_result = ebfm_display (EBFM_MSG_ERROR_FATAL, {"ERROR: Reserved bit must be zero  -----, ", "Actual = ", himage8(rdata[7:2])}); 
//
//     if (rdata[8] == 0) 
//         unused_result = ebfm_display (EBFM_MSG_INFO, {"ERROR: PME Enable is RWS  -----, ", "Actual = ", himage8(rdata[8])}); 
//
//     if (rdata[12:9] == 0) 
//         unused_result = ebfm_display (EBFM_MSG_INFO, {"ERROR: PME Data Select is RW  -----, ", "Actual = ", himage8(rdata[12:9])}); 
//
//     if (rdata[14:13] != 0) 
//         unused_result = ebfm_display (EBFM_MSG_INFO, {"ERROR: PME Data Scale is RO  -----, ", "Actual = ", himage8(rdata[14:13])}); 
//
//     if (rdata[15] == 0) 
//         unused_result = ebfm_display (EBFM_MSG_INFO, {"ERROR: PME Status is RW  -----, ", "Actual = ", himage8(rdata[15])}); 
//
//    //----------------------------
//    // Reset PME register
//      wdata    = 32'h0;
//
//     ebfm_cfgwr_imm_wait (
//                           ep_bus,           // EP Bus number
//                           ep_dev,           // EP Dev number 
//                           ep_func,          // EP Func number
//                           config_address,   // Config register address in byte 
//                           dw_byte_length,   // Byte length 
//                           wdata,            // Config Write data 
//                           compl_status);    // Completion Status
//
//     ebfm_cfgrd_wait(    
//                           ep_bus,           // EP Bus number
//                           ep_dev,           // EP Dev number 
//                           ep_func,          // EP Func number
//                           config_address,   // Config register address in byte 
//                           dw_byte_length,   // Byte length 
//                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
//                           compl_status);    // Completion Status
//
//     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
//     unused_result = ebfm_display(EBFM_MSG_INFO, {"After reset => Read from PM Base Register at 0x78 = ", himage8(rdata)});

     //===============================================
     // 6. PCI Express Cap at 0x80
     // Protect the critical BFM data from being accidentally overwritten.
     // bfm_shmem_common.protect_bfm_shmem = 1'b1;

   end

endtask


//======================================
// Target Link Speed tests - TD 1-41 
//======================================
task vf_cfg_test (
   input reg [7:0]  pf_bus,
   input reg [7:0]  pf_func,
   input reg [7:0]  ep_bus,
   input reg [7:0]  ep_func,
   input integer    bar_table,
   input reg        sriov_ph1,
   input reg        display
);

   reg         unused_result ;
   reg [31:0]  wdata, rdata, exp_data;        // 32b General purpose write data
   reg [31:0]  epmem_address;       // EP memory address offset from current setup_bar
   reg [31:0]  config_address;      // Config_address
   reg [ 2:0]  compl_status;
   integer     dw_byte_length;      // downstream memory wr/rd length in byte
   reg         check_en; 
   integer i;
   integer msi_present, msix_present;

   begin

     check_en = 1;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"Check config_space for VF at func = ", himage8(ep_func)});
     dw_byte_length    = 4; 

     //===============================================
     // 1. Read Link Cap and expected TLS = Gen2
      config_address = {DEV_VENDOR_ID, 2'h0};
      ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_func[7:3],     // EP Dev number 
                           ep_func[2:0],     // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);    // Completion Status

     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;

     exp_data          = 32'hffffffff;
     if (rdata != exp_data) begin 
        unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected = 0x", himage8(exp_data), " -- Actual = 0x", himage8(rdata)}); 
     end else begin
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read DEV_VENDOR_ID from addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});
     end
     //===============================================
     // 2.1 Read Command and Status Register
      config_address = {STATUS_COMMAND, 2'h0};
      ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_func[7:3],     // EP Dev number 
                           ep_func[2:0],     // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);     // Completion Status

     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read STATUS_COMMAND at addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});

     exp_data          = { 11'h0, 1'b1, 20'h0};
     if (rdata != exp_data) 
         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected = 0x", himage8(exp_data), " -- Actual = 0x", himage8(rdata)}); 

     //===================================================
     // 2.2 Write Command/Status register
     wdata             = 32'hffffffff;
      // Command
     exp_data[15:0] = {
                 5'h0,    // [15:11] Reserved
                 1'b0,    // [10]  Interupt Disable
                 1'b0,    // [9]   Reserved
                 1'b0,    // [8]   SERR# Enable => Reserved 
                 1'b0,    // [7]   Reserved 
                 1'b0,    // [6]   Parity Error Response => Reserved
                 3'h0,    // [5:3] Reserved
                 1'b1,    // [2] BME
                 1'b0,    // [1] MSE
                 1'b0     // [0] io_space
                }; 
      // Status
     exp_data[31:16] = {
                 1'h0,    // [31]    Receive Master Abort
                 1'h0,    // [30]    Signaled System Error
                 1'b0,    // [29]    Receive_Master Abort   
                 1'b0,    // [28]    Receive Target Abort
                 1'b0,    // [27]    Signal Target Abort
                 2'h0,    // [26:25] Reserved 
                 1'b0,    // [24]    Master Data Parity Error
                 3'h0,    // [23:21] Reserved
                 1'b1,    // [20]   => [4]Indicates the present of PCI Extended Cap
                 1'b0,    // [19]   =>  [3] Interrupt Status
                 3'h0     // [18:16] Not implemented 
                }; 

    unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Write all F to STATUS_COMMAND at addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});
     ebfm_cfgwr_imm_wait (
                           ep_bus,           // EP Bus number
                           ep_func[7:3],     // EP Dev number 
                           ep_func[2:0],     // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           wdata,            // Config Write data 
                           compl_status);    // Completion Status

      ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_func[7:3],     // EP Dev number 
                           ep_func[2:0],     // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);     // Completion Status

     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     if (rdata != exp_data) begin
        unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected = 0x", himage8(exp_data), " -- Actual = 0x", himage8(rdata)}); 
      //  unused_result = ebfm_display(EBFM_MSG_INFO, {"ERROR : expected = 0x", himage8(exp_data), " -- Actual = 0x", himage8(rdata)}); 
     end else begin
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read STATUS_COMMAND at addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});
     end

     //===================================================
     // 4. Revision ID and class code
     //===================================================
      config_address = {REVISIONID_CLASSCODE, 2'h0};
      
      unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read PF RevisionID and Classcode at addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});
      ebfm_cfgrd_wait(  pf_bus, pf_func[7:3],  pf_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
      exp_data      = shmem_read(CFG_SHARE_RD, dw_byte_length) ;

      unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read VF RevisionID and Classcode at addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});
      ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
      rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;

      if (rdata != exp_data) begin 
        unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected = 0x", himage8(exp_data), " -- Actual = 0x", himage8(rdata)}); 
      end else begin
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read from addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});
      end

     //===================================================
     // 5. BIST_HDR_TYPE register
     //===================================================
      config_address = {BIST_HDR_TYPE, 2'h0};
      ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
      rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     
     if (sriov_ph1) 
        exp_data          = 32'h0;
     else // multi functions
        exp_data          = {8'h0, 1'b1, 23'h0};

     if (rdata != exp_data) begin 
        unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected = 0x", himage8(exp_data), " -- Actual = 0x", himage8(rdata)}); 
     end else begin
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read from addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});
     end

     //===================================================
     //  6. Base Address register for VF BAR0 to BAR3
     //===================================================
     for (i = BAR0_REG; i <= BAR3_REG; i = i + 1) begin
        config_address = {i, 2'h0};
        wdata = 32'hFFFFFFFF;
        exp_data          = 32'h0;

        // Read back to check for size
        ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
        unused_result = ebfm_display (EBFM_MSG_INFO, {"CfgRD at addr =0x", himage8(config_address), " returns data = 0x", himage8(rdata)});

        if (rdata != exp_data) begin
          unused_result = ebfm_display (EBFM_MSG_ERROR_FATAL, {"Error: Mismatched: Expected = ", himage8(wdata), "  -----, ", "Actual = ", himage8(rdata)}); 
        end

        // Write all F to BAR0
        ebfm_cfgwr_imm_wait ( ep_bus, ep_func[7:3], ep_func[2:0], config_address, dw_byte_length, wdata, compl_status );   

        // Read back to check for size
        ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
        unused_result = ebfm_display (EBFM_MSG_INFO, {"CfgRD at BAR0 (addr =0x", himage8(config_address), ") returns data = 0x", himage8(rdata)});
     
        // For VF, expected to see zero
        if (rdata != exp_data) begin
          unused_result = ebfm_display (EBFM_MSG_ERROR_FATAL, {"Error: Mismatched: Expected = ", himage8(wdata), "  -----, ", "Actual = ", himage8(rdata)}); 
        end
      end // for i..

     //===================================================
     // 7. Subsystem Vendor ID and Subsystem ID reg
     //===================================================
      config_address = {SUBSYS_ID_VENDOR_ID, 2'h0};
      
      ebfm_cfgrd_wait(  pf_bus, pf_func[7:3],  pf_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
      exp_data      = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
      unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read PF SUBSYS_ID_VENDOR_ID at addr = ", himage8(config_address), " with rdata = 0x", himage8(exp_data)});

      ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
      rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
      unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read VF SUBSYS_ID_VENDOR_ID at addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});

      if (rdata != exp_data) begin 
        unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected = 0x", himage8(exp_data), " -- Actual = 0x", himage8(rdata)}); 
      end else begin
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read from addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});
      end

     //===================================================
     // 8. CAP_POINTERS 
     //===================================================
      config_address = {CAP_POINTER, 2'h0};
      
      unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read VF CAP_POINTERS at addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});
      ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
      rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;

      if (rdata[7:0] == 8'hx50) begin 
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------>  First Cap pointer is MSI at byte address = ", himage8(rdata[7:0])});
        msi_present = 1;
      end else if (rdata[7:0] == 8'h68 ) begin
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------>  First Cap pointer is MSI-X at byte address = ", himage8(rdata[7:0])});
        msix_present = 1;
      end else begin
        unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : unexpected first pointer = 0x", himage8(rdata[7:0])}); 
      end

      if (rdata[31:8] != 0) begin
        unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : unexpected value = 0x", himage8(rdata[31:0])}); 
      end  

     //===================================================
     // 8. MSI
     //===================================================
     if (msi_present) begin 
        config_address = MSI_BASE_ADDR;
      
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read MSI_BASE_ADDR at addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});
        ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;

        if (rdata[7:0] != 8'h5) begin
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected value = 0x5, but actual value = ", himage8(rdata[7:0])}); 
        end  

        if (rdata[15:8] == 8'h68 ) begin
          unused_result = ebfm_display(EBFM_MSG_INFO, {"------>  Next MSI pointer is MSI-X at byte address = ", himage8(rdata[15:8])});
          msix_present = 1;
        end else if (rdata[15:8] == 8'h80) begin
          unused_result = ebfm_display(EBFM_MSG_INFO, {"------>  Next MSI pointer is PCI-Express Cap at byte address = ", himage8(rdata[15:8])});
        end else begin  
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Unexpected MSI Next Pointer value  = ", himage8(rdata[15:8])}); 
        end 

        // Check MSI Enable bit
        if (rdata[16] != 0) begin 
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected MSI Enable value = 0x0, but actual value = ", himage8(rdata[16])}); 
        end  

        // Check Multiple Message Capable
        exp_data = top_tb.top_inst.dut.VF_MSI_MULTI_MSG_CAPABLE;
        if (rdata[19:17] != exp_data[2:0] ) begin 
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected VF_MSI_MULTI_MSG_CAPABLE value = ", himage8 (exp_data[2:0]) ," -- actual value = ", himage8(rdata[16])}); 
        end  

        // Check Multiple Message Enable
        if (rdata[22:20] != 0) begin 
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected Multiple Message Enable value = 0x0, but actual value = ", himage8(rdata[22:20])}); 
        end  

        // Check 64bt Address Capable
        exp_data = top_tb.top_inst.dut.VF_MSI_64BIT_CAPABLE;
        if (rdata[23] != exp_data ) begin 
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected VF_MSI_64BIT_CAPABLE value = ", himage8 (exp_data) ," -- actual value = ", himage8(rdata[23])}); 
        end  

        // MSI Per vector Masking Capable
        exp_data = 0;
        if (rdata[24] != 0 ) begin 
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected MSI Per vector Masking Capable value = ", himage8 (exp_data) ," -- actual value = ", himage8(rdata[24])}); 
        end  

        // Not implemented
        exp_data = 0;
        if (rdata[31:25] != 0 ) begin 
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected MSI Not implemented value = ", himage8 (exp_data) ," -- actual value = ", himage8(rdata[31:25])}); 
        end  

        //=================================================
        // Check writable fields of MSI Control register
        //=================================================
        wdata = 32'hff5fffff;
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Write all F's into MSI Control at addr = ", himage8(config_address), " with wdata = 0x", himage8(wdata)});
        ebfm_cfgwr_imm_wait ( ep_bus, ep_func[7:3], ep_func[2:0], config_address, dw_byte_length, wdata, compl_status );   

        ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;

        // Check MSI Enable bit
        if (rdata[16] != 1) begin 
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected value = 0x1, but actual value = ", himage8(rdata[16])}); 
        end  

        // Check Multiple Message Enable
        if (rdata[22:20] != 3'h5) begin 
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected value = 0x5, but actual value = ", himage8(rdata[22:20])}); 
        end  

        //=================================================
        // Check MSI low address Register
        //=================================================
        config_address = MSI_LOWER_ADDR;
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Check MSI_LOWER_ADDR at addr = ", himage8(config_address)});
       // ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    

        wdata = 32'hffffffff;
        ebfm_cfgwr_imm_wait ( ep_bus, ep_func[7:3], ep_func[2:0], config_address, dw_byte_length, wdata, compl_status );   

        exp_data = {wdata[31:2], 2'h0};

        ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;

        if (rdata != exp_data ) begin 
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected MSI_LOWER_ADDR value = ", himage8 (exp_data) ," -- actual value = ", himage8(rdata)}); 
        end  

        //=================================================
        // Check MSI high address Register
        //=================================================
        config_address = MSI_UPPER_ADDR;
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Check MSI_UPPER_ADDR at addr = ", himage8(config_address)});
        //ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    

        wdata = 32'hffffffff;
        ebfm_cfgwr_imm_wait ( ep_bus, ep_func[7:3], ep_func[2:0], config_address, dw_byte_length, wdata, compl_status );   

        ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;

        exp_data = wdata;
        if (rdata != exp_data ) begin 
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected MSI_UPPER_ADDR value = ", himage8 (exp_data) ," -- actual value = ", himage8(rdata)}); 
        end  

        //=================================================
        // Check MSI Data
        //=================================================
        config_address = MSI_DATA;
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Check MSI_DATA at addr = ", himage8(config_address)});
        //ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    

        wdata = 32'hffffffff;
        ebfm_cfgwr_imm_wait ( ep_bus, ep_func[7:3], ep_func[2:0], config_address, dw_byte_length, wdata, compl_status );   

        ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;

        exp_data = 32'hffff;
        if (rdata != exp_data ) begin 
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected MSI_DATA value = ", himage8 (exp_data) ," -- actual value = ", himage8(rdata)}); 
        end  
      end // msi_present

     //===================================================
     // 8. MSIX
     //===================================================
     if (msix_present) begin 
        config_address = MSIX_BASE_ADDR;
      
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Check MSIX_BASE_ADDR at addr = ", himage8(config_address)});
        ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;

        if (rdata[7:0] != 8'h11) begin
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected MSIX_BASE_ADDR value = 0x11, but actual value = ", himage8(rdata[7:0])}); 
        end  

        // Next Cap pointer 
        if (rdata[15:8] != 8'h80) begin
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected MSIX Next Cap pointer value = 0x80, but actual value = ", himage8(rdata[15:8])}); 
        end 
        
        // Check MSIX Table Size[26:16]
        exp_data = top_tb.top_inst.dut.VF_MSIX_TBL_SIZE;
        if (rdata[26:16] != exp_data ) begin 
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected MSIX Table Size value = ", himage8 (exp_data) ," -- actual value = ", himage8(rdata[26:16])}); 
        end  
      
        // Reserved bit, function mask and MSIX Enable
        exp_data = 0;
        if (rdata[31:27] != exp_data) begin 
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected Reserved bit, function mask and MSIX Enable value = ", himage8 (exp_data) ," -- actual value = ", himage8(rdata[31:27])}); 
        end  
        
        //=====================================
        // Check writable bits of MSIX_BASE_ADDR
        //
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Write all F's to MSIX_BASE_ADDR at addr = ", himage8(config_address)});
        wdata = 32'hffffffff;
        ebfm_cfgwr_imm_wait ( ep_bus, ep_func[7:3], ep_func[2:0], config_address, dw_byte_length, wdata, compl_status );   
        ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;

        // MSIX function Mask
        exp_data = 1;
        if (rdata[30] != exp_data[0]) begin 
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected MSIX Fuction Mask value = ", himage8 (exp_data) ," -- actual value = ", himage8(rdata[30])}); 
        end  
        
        // MSIX Enable
        exp_data = 1;
        if (rdata[31] != exp_data[0]) begin 
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected MSIX Enable value = ", himage8 (exp_data) ," -- actual value = ", himage8(rdata[31])}); 
        end  
        
        //=====================================
        // Check MSIX_TABLE_OFFSET
        //
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Check MSIX_TABLE_OFFSET at addr = ", himage8(config_address)});
        config_address = MSIX_TABLE_OFFSET;
        ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;

        // Table BAR Indicator Register (BIR)
        exp_data = top_tb.top_inst.dut.VF_MSIX_TBL_BIR;
        if (rdata[2:0] != exp_data ) begin 
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected VF_MSIX_TBL_BIR value = ", himage8 (exp_data) ," -- actual value = ", himage8(rdata[2:0])}); 
        end  
      
        // Table Offset
        exp_data = top_tb.top_inst.dut.VF_MSIX_TBL_OFFSET;
        if (rdata[31:3] != exp_data ) begin 
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected VF_MSIX_TBL_OFFSET value = ", himage8 (exp_data) ," -- actual value = ", himage8(rdata[31:3])}); 
        end  
         
        //=====================================
        // Check RO bits of MSIX_TABLE_OFFSET
        //
        wdata = 32'hffffffff;
        ebfm_cfgwr_imm_wait ( ep_bus, ep_func[7:3], ep_func[2:0], config_address, dw_byte_length, wdata, compl_status );   
        ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;

        // Table BAR Indicator Register (BIR)
        exp_data = top_tb.top_inst.dut.VF_MSIX_TBL_BIR;
        if (rdata[2:0] != exp_data ) begin 
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected VF_MSIX_TBL_BIR value = ", himage8 (exp_data) ," -- actual value = ", himage8(rdata[2:0])}); 
        end  
      
        // Table Offset
        exp_data = top_tb.top_inst.dut.VF_MSIX_TBL_OFFSET;
        if (rdata[31:3] != exp_data ) begin 
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected VF_MSIX_TBL_OFFSET value = ", himage8 (exp_data) ," -- actual value = ", himage8(rdata[31:3])}); 
        end  

        //=======================================
        // Test MSIX Pending Bit Array Register
        //=======================================
        config_address = MSIX_PBA_OFFSET;
      
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Check MSIX_PBA_OFFSET at addr = ", himage8(config_address)});
        ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
        
        // Check MSIX PBA Offset
        exp_data = top_tb.top_inst.dut.VF_MSIX_PBA_OFFSET;
        if (rdata[31:3] != exp_data) begin
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected VF_MSIX_PBA_OFFSET value = 0x11, but actual value = ", himage8(rdata[31:3])}); 
        end  

        // Check MSIX BIR 
        exp_data = top_tb.top_inst.dut.VF_MSIX_PBA_BIR;
        if (rdata[2:0] != exp_data) begin
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected VF_MSIX_PBA_BIR value = 0x11, but actual value = ", himage8(rdata[2:0])}); 
        end  
      end // msix_present

      //=======================================
      // 9 PCI Express Cap at 0x80
      //=======================================
        config_address = PCIE_CAP_BASE_ADDR;
      
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Check PCIE_CAP_BASE_ADDR at addr = ", himage8(config_address)});
        ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
        exp_data = {16'h2, 16'h10};
        if (rdata != exp_data) begin
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected VF_MSIX_PBA_BIR value = 0x11, but actual value = ", himage8(rdata)}); 
        end  

        //=====================================
        // Check RO bits of PCIE_CAP_BASE_ADDR
        //
        wdata = 32'hffffffff;
        ebfm_cfgwr_imm_wait ( ep_bus, ep_func[7:3], ep_func[2:0], config_address, dw_byte_length, wdata, compl_status );   
        ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;

        exp_data = {16'h2, 16'h10};
        if (rdata != exp_data) begin
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected VF_MSIX_PBA_BIR value = 0x11, but actual value = ", himage8(rdata)}); 
        end  
      //=======================================
      // 10 PCI Express Device Cap at 0x84
      //=======================================
        config_address = PCIE_DEV_CAP_ADDR;
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Check PCIE_DEV_CAP_ADDR at addr = ", himage8(config_address)});
        // Read  Dev Cap of PF0 
        ebfm_cfgrd_wait(  pf_bus, pf_func[7:3],  pf_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        exp_data      = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read PF PCIE_DEV_CAP_ADDR at addr = ", himage8(config_address), " with rdata = 0x", himage8(exp_data)});

        // Read  Dev Cap of PF0 
        ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read VF PCIE_DEV_CAP_ADDR at addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});

        // MPS 
        if (rdata[2:0] != exp_data[2:0]) begin
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected MPS value = ", himage8(exp_data[2:0]),", but actual value = ", himage8(rdata[2:0])}); 
        end  

        // Not Implemented
        if (rdata[4:3] != 0) begin
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected value = 0,  but actual value = ", himage8(rdata[4:3])}); 
        end  

        // Extended Tag Support
        if (rdata[5] != exp_data[5]) begin
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected Extended Tag value = ", himage8(exp_data[5]),", but actual value = ", himage8(rdata[5])}); 
        end  

        // Acceptable L0s, L1, and Reserved bits
        if (rdata[14:6] != 0) begin
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected Acceptable L0s, L1, and Reserved bits value = ", himage8(exp_data[14:6]),", but actual value = ", himage8(rdata[14:6])}); 
        end  
        // Role-Based Error Reporting Support 
        if (rdata[15] != exp_data[15]) begin
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected Role-Based Error Reporting Support value = ", himage8(exp_data[5]),", but actual value = ", himage8(rdata[5])}); 
        end  

        // FLR Capable 
        if (rdata[28] != exp_data[28]) begin
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected FLR Capable value = ", himage8(exp_data[28]),", but actual value = ", himage8(rdata[28])}); 
        end  

        // Reserved bits
        if (rdata[31:29] != 0) begin
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected Reserved bits value = 0, but actual value = ", himage8(rdata[31:29])}); 
        end

      //=======================================
      // 11 PCI Express Device Control Status at 0x88
      //=======================================
        config_address = PCIE_DEV_CTL_STATUS_ADDR;
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Check PCIE_DEV_CTL_STATUS_ADDR at addr = ", himage8(config_address)});

        ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read VF PCIE_DEV_CTL_STATUS_ADDR at addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});

        if (rdata[31:0] != 0) begin
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected Reserved bits value = 0, but actual value = ", himage8(rdata[31:29])}); 
        end

      //=======================================
      // 12 PCIE_LINK_CAP_ADDR
      //=======================================
        config_address = PCIE_LINK_CAP_ADDR;

        ebfm_cfgrd_wait(  pf_bus, pf_func[7:3],  pf_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        exp_data      = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read PF PCIE_LINK_CAP_ADDR at addr = ", himage8(config_address), " with rdata = 0x", himage8(exp_data)});

        // Read  Dev Cap of PF0 
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read VF PCIE_LINK_CAP_ADDR at addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});
        ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;

        if (rdata[31:0] != exp_data) begin
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected PCIE_LINK_CAP_ADDR value = ", himage8(exp_data),", but actual value = ", himage8(rdata)}); 
        end

      //=======================================
      // 13.  PCIE_LINK_CTL_STATUS_ADDR
      //=======================================
        config_address = PCIE_LINK_CTL_STATUS_ADDR;
        ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read VF PCIE_LINK_CTL_STATUS_ADDR at addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});

        if (rdata[31:0] != 0) begin
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected PCIE_LINK_CTL_STATUS_ADDR value = 0, but actual value = ", himage8(rdata)}); 
        end

      //=======================================
      // 14.  PCIE_DEV_CAP2_ADDR
      //=======================================
        config_address = PCIE_DEV_CAP2_ADDR;

        ebfm_cfgrd_wait(  pf_bus, pf_func[7:3],  pf_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        exp_data      = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read PF PCIE_DEV_CAP2_ADDR at addr = ", himage8(config_address), " with rdata = 0x", himage8(exp_data)});

        // Read  Dev Cap of PF0 
        ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read VF PCIE_DEV_CAP2_ADDR at addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});

        if (rdata[31:0] != exp_data) begin
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected PCIE_DEV_CAP2_ADDR value = ", himage8(exp_data),", but actual value = ", himage8(rdata)}); 
        end

      //=======================================
      // 15 PCI Express Device Control Status2 
      //=======================================
        config_address = PCIE_DEV_CTL_STATUS2_ADDR;
        ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read VF PCIE_DEV_CTL_STATUS2_ADDR at addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});

        if (rdata[31:0] != 0) begin
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected PCIE_DEV_CTL_STATUS2_ADDR value = 0, but actual value = ", himage8(rdata)}); 
        end

      //=======================================
      // 16 PCIE_LINK_CAP2_ADDR
      //=======================================
        config_address = PCIE_LINK_CAP2_ADDR;
        ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read VF PCIE_LINK_CAP2_ADDR at addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});

        if (rdata[31:0] != 0) begin
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected PCIE_LINK_CAP2_ADDR value = 0, but actual value = ", himage8(rdata)}); 
        end

      //=======================================
      // 17 PCIE_LINK_CTL_STATUS2_ADDR
      //=======================================
        config_address = PCIE_LINK_CAP2_ADDR;
        ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read VF PCIE_LINK_CTL_STATUS2_ADDR at addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});

        if (rdata[31:0] != 0) begin
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected PCIE_LINK_CTL_STATUS2_ADDR value = 0, but actual value = ", himage8(rdata)}); 
        end

      //=======================================
      // 18 ARI CAP
      //=======================================
        config_address = ARI_CAP_BASE_ADDR;
        ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read VF ARI_CAP_BASE_ADDR at addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});

        // ARI Extended CAP ID
        if (rdata[15:0] != 16'hE) begin
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected ARI Extended CAP ID value = 0xE, but actual value = ", himage8(rdata[15:0])}); 
        end

        // ARI Cap Version
        if (rdata[19:16] != 4'h1) begin
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected ARI Extended CAP ID value = 0xE, but actual value = ", himage8(rdata[19:16])}); 
        end

        // ARI Next Cap Pointer
        if (rdata[31:20] != 12'h0) begin
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected ARI Mext CAP Pointer value = 0x0, but actual value = ", himage8(rdata[31:20])}); 
        end
        
      //=======================================
      // 19 ARI CAP Control 
      //=======================================
        config_address = ARI_CAP_REG_ADDR;
        ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read VF ARI_CAP_BASE_ADDR at addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});

        if (rdata[31:0] != 0) begin
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : expected PCIE_LINK_CTL_STATUS2_ADDR value = 0, but actual value = ", himage8(rdata)}); 
        end

   end // task body

endtask

//======================================
// Main Config_Bypass test
//======================================
task config_bypass_test; 
   input integer  ep_bus;
   input integer  ep_dev;
   input integer  bar_table;
   input integer  display_rp_config;    // 1 to display
   input integer  display_ep_config;    // 1 to display
   input reg      addr_map_4GB_limit;
   output reg     activity_toggle;
   reg         unused_result ;

   begin
     unused_result = ebfm_display(EBFM_MSG_INFO, {"This test is a place holder for 13.1 config-bypass test"});
     unused_result = ebfm_display(EBFM_MSG_INFO, {"To run SR-IOV test, set parameter RUN_SRIOV_TEST = 1 in altpcietb_bfm_rp_g3x8_cfgbp.v for Gen3"});

   end  
endtask

task config_bypass_test2; 
   input use_config_bypass_hwtcl;
   input integer  ep_bus;
   input integer  ep_dev;
   input integer  bar_table;
   input integer  display_rp_config;    // 1 to display
   input integer  display_ep_config;    // 1 to display
   input reg      addr_map_4GB_limit;
   output reg     activity_toggle;

   integer     ep_func;
   integer     rc_slave_bar;
   reg         unused_result ;
   reg         check_en;

   begin
     check_en = 1;

      //================== Start Config Bypass test ====================================      
            unused_result = ebfm_display(EBFM_MSG_INFO,
                  "----> Starting ebfm_cfg_rp task 0");
            ebfm_cfg_rp(
                     ep_bus,            // Max EP Bus Number hanging off from RP
                     512,               // RP Maximum Read Request Size 
                     display_rp_config, // Display RP Config Space after setup
                     activity_toggle
                     );

            //======================
            // Enumerate function 2
            //======================
            ep_func        = 2;
            unused_result = ebfm_display(EBFM_MSG_INFO, {"Enumerate EP function = 0x", himage2(ep_func)});
            cfg_rd_modified_wr (ep_bus, ep_func, ep_func, {STATUS_COMMAND, 2'h0}, 32'h7, check_en);

            //======================
            // Enumerate function 0
            //======================
            ep_func        = 0;
            unused_result = ebfm_display(EBFM_MSG_INFO, {"Enumerate EP function = 0x", himage2(ep_func)});
            enum_ep_cfg_space ( ep_bus,   // busno
                                ep_dev,   // devno
                                ep_func,  // funcno
                                bar_table,
                                display_ep_config,        // display_ep_config
                                0         // addr_map_4GB_limit
                              );

            find_mem_bar(bar_table, 6'b000011, 8, rc_slave_bar);
       
            my_test (
               use_config_bypass_hwtcl,
               bar_table,               // Pointer to the BAR sizing and
               rc_slave_bar             // Pointer to the BAR sizing and
            );       
     
          //======================
          // Enumerate function 1
          //======================
            ep_func        = 1;
            unused_result = ebfm_display(EBFM_MSG_INFO, {"Enumerate EP function = 0x", himage2(ep_func)});
            enum_ep_cfg_space ( ep_bus,   // busno
                                ep_dev,   // devno
                                ep_func,  // funcno
                                bar_table,
                                display_ep_config,        // display_ep_config
                                0         // addr_map_4GB_limit
                              );
          
            find_mem_bar(bar_table, 6'b000001, 8, rc_slave_bar);
            my_test (
               use_config_bypass_hwtcl,
               bar_table,               // Pointer to the BAR sizing and
               rc_slave_bar             // Pointer to the BAR sizing and
            );       


      //================== END of Config Bypass test ====================================      
   end
endtask

//====================================================== 
// Test downstream target test
//====================================================== 

task cfbp_target_test; 
   input reg [7:0] ep_bus;
   input reg [4:0] ep_dev;
   input reg [2:0] ep_func;
   input integer  bar_table;
   input integer  setup_bar;    // 1 to display
   input reg [31:0] wdata;
   input reg      dw_test;      // 1: run dw test only, 0: burst test


//   localparam  REG_SHARE_RD = SCR_MEM_DOWNSTREAM_RD + 32'h200;
//   localparam  REG_SHARE_WR = SCR_MEM_DOWNSTREAM_WR + 32'h200;
//
//   localparam  MEM_SHARE_RD = SCR_MEM_DOWNSTREAM_RD + 32'h400;
//   localparam  MEM_SHARE_WR = SCR_MEM_DOWNSTREAM_WR + 32'h400;
   
   localparam  REG0_ADDR = 32'h0; // Offset from setup_bar
   localparam  REG1_ADDR = 32'h4; // Offset from setup_bar
   localparam  MEM0_ADDR = 32'h0; // Offset from setup_bar
   localparam  MEM1_ADDR = 32'h4; // Offset from setup_bar

   // variables
   reg         unused_result ;
   reg [31:0]  rdata;        // 32b General purpose write data
   reg [31:0]  epmem_address;       // EP memory address offset from current setup_bar
   reg [31:0]  config_address;      // Config_address
   reg [ 2:0]  compl_status;

   integer     dw_byte_length;      // downstream memory wr/rd length in byte
   integer     burst_byte_length;   // downstream config wr/rd length in byte
   integer     max_len, min_len, inc_len;
   integer     mem_addr;

   begin
     //======================
     // F0 Downstream test 
     //======================
      unused_result = ebfm_display(EBFM_MSG_INFO, `STR_SEP);
      unused_result = ebfm_display(EBFM_MSG_INFO, {"TASK: Memory downstream test for func_no = ", himage8({ep_dev, ep_func})});

      max_len           = 16; // in byte
      min_len           = 4;
      inc_len           = 4; // Must be dword aligned due to the restriction in DMA APP
      dw_byte_length    = 4; 

     //=========================
     // 1. 32bit Register access
     //=========================
     // Even address
      unused_result = ebfm_display(EBFM_MSG_INFO, `STR_SEP);
      unused_result = ebfm_display(EBFM_MSG_INFO, {"TASK: 1.11 Write to 32bit register at addr = 0x", himage8(REG0_ADDR), " with wdata=0x", himage8(wdata)});
      ebfm_barwr_imm(   bar_table,      // BAR table in the host memory
                        setup_bar,      // Current BAR that contains the register 
                        REG0_ADDR,       // Register address offset from the current setup_bar
                        wdata,          // Write data value
                        dw_byte_length, // byte_len => 4B = 32bits
                        0);             // Traffic Class => always zero for this bench


      unused_result = ebfm_display(EBFM_MSG_INFO, {"TASK: 1.12 Read from 32bit register at addr = 0x", himage8(REG0_ADDR)});
      ebfm_barrd_wait(  bar_table,      // BAR table in the host memory
                        setup_bar,      // Current BAR that contains the register 
                        REG0_ADDR,       // Register address offset from the current setup_bar
                        REG_SHARE_RD,   // Share memory where read_data is stored
                        dw_byte_length, // byte_len => 4B = 32bits
                        0); 

      rdata = shmem_read(REG_SHARE_RD,dw_byte_length) ;

      if (rdata != wdata) 
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"TASK: 1.13  Mismatched reg data: Expected = 0x", himage8(wdata), " -- Actual = 0x", himage8(rdata)}); 
      else 
          unused_result = ebfm_display(EBFM_MSG_INFO, "TASK: 1.13  Register compare matches!");

     //=========================
     // 2. Memory burst access
     //=========================
     // Burst with Even address
     if (dw_test == 0) begin
         unused_result = ebfm_display(EBFM_MSG_INFO, `STR_SEP);
         unused_result = ebfm_display(EBFM_MSG_INFO, "TASK: 2.11 Fill write memory with QWORD_INC pattern");

         mem_addr          = MEM0_ADDR;
         burst_byte_length = min_len;  
         wdata             = 32'h10203040;   // Start write data pattern
         
         while (burst_byte_length < max_len) begin
            shmem_fill(MEM_SHARE_WR, SHMEM_FILL_QWORD_INC, burst_byte_length, wdata);

            unused_result = ebfm_display(EBFM_MSG_INFO, {"TASK: 2.12 Memory write burst at addr=0x", himage2(mem_addr), " with wdata=0x", himage8(wdata)});
            ebfm_barwr( bar_table,        // BAR table in the host memory
                        setup_bar,        // Current BAR that contains the register 
                        mem_addr,         // Start memory address => offset from setup_bar
                        MEM_SHARE_WR,     // Start host shared memory address where write data are stored
                        burst_byte_length,// Burst length in byte 
                        0);               // Traffic Class (always 0)

            unused_result = ebfm_display(EBFM_MSG_INFO, "TASK: 2.21 Memory Read burst");
            // Initialize MEM_SHARE_RD 
            shmem_fill(MEM_SHARE_RD, SHMEM_FILL_QWORD_INC,burst_byte_length,64'hFADE_FADE_FADE_FADE); 

            // Read data and store them in MEM_SHARE_RD
            ebfm_barrd_wait(  bar_table,        // BAR table in the host memory
                        setup_bar,        // Current BAR that contains the register
                        mem_addr,         // Start memory address => offset from setup_bar
                        MEM_SHARE_RD,     // Start host shared memory address where read data are stored
                        burst_byte_length,// Burst length in byte
                        0);               // Traffic Class (always 0)
     
             unused_result = ebfm_display(EBFM_MSG_INFO, "TASK: 2.3 Check for memory read/write data");
             scr_memory_compare(burst_byte_length,
                         MEM_SHARE_WR,
                         MEM_SHARE_RD);
            // Increment burst length and address
            mem_addr          = mem_addr + 8; // 16 and 8 = work => Must be qword-aligned
            burst_byte_length = burst_byte_length + inc_len;

         end
      end // end dword test 
   end
endtask
//====================================================== 
// Test downstream Write 
//====================================================== 

task cfbp_target_write ; 
   input reg [7:0] ep_func;
   input integer  bar_table;
   input integer  setup_bar;    // 1 to display
   input reg [31:0] wdata;
   input reg      dw_test;      // 1: run dw test only, 0: burst test

   localparam  REG0_ADDR = 32'h0; // Offset from setup_bar

   // variables
   reg         unused_result ;
   reg [31:0]  rdata;        // 32b General purpose write data
   reg [ 2:0]  compl_status;
   integer     dw_byte_length;      // downstream memory wr/rd length in byte

   begin
     //======================
     // F0 Downstream test 
     //======================
      unused_result = ebfm_display(EBFM_MSG_INFO, `STR_SEP);
      unused_result = ebfm_display(EBFM_MSG_INFO, {"TASK: Memory downstream test for func_no = ", himage8(ep_func)});

      dw_byte_length    = 4; 

     //=========================
     // 1. 32bit Register access
     //=========================
     // Even address
      unused_result = ebfm_display(EBFM_MSG_INFO, `STR_SEP);
      unused_result = ebfm_display(EBFM_MSG_INFO, {"TASK: 1.11 Write to 32bit register at addr = 0x", himage8(REG0_ADDR), " with wdata=0x", himage8(wdata)});
      ebfm_barwr_imm(   bar_table,      // BAR table in the host memory
                        setup_bar,      // Current BAR that contains the register 
                        REG0_ADDR,       // Register address offset from the current setup_bar
                        wdata,          // Write data value
                        dw_byte_length, // byte_len => 4B = 32bits
                        0);             // Traffic Class => always zero for this bench


      unused_result = ebfm_display(EBFM_MSG_INFO, {"TASK: 1.12 Read from 32bit register at addr = 0x", himage8(REG0_ADDR)});
      ebfm_barrd_wait(  bar_table,      // BAR table in the host memory
                        setup_bar,      // Current BAR that contains the register 
                        REG0_ADDR,       // Register address offset from the current setup_bar
                        REG_SHARE_RD,   // Share memory where read_data is stored
                        dw_byte_length, // byte_len => 4B = 32bits
                        0); 

      rdata = shmem_read(REG_SHARE_RD,dw_byte_length) ;

      if (rdata != wdata) 
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"TASK: 1.13  Mismatched reg data: Expected = 0x", himage8(wdata), " -- Actual = 0x", himage8(rdata)}); 
      else 
          unused_result = ebfm_display(EBFM_MSG_INFO, "TASK: 1.13  Register compare matches!");
   end
endtask

//======================================
// Check ARI CAP
//======================================
task check_ari_cap; 
   input integer  ep_bus;

   reg [7:0]   ep_func;
   reg         unused_result ;
   reg [31:0]  wdata, rdata, exp_data;        // 32b General purpose write data
   reg [31:0]  config_address;      // Config_address
   reg [ 2:0]  compl_status;
   integer     dw_byte_length;      // downstream memory wr/rd length in byte
   
   begin
      ep_func = 0;
      dw_byte_length    = 4; 

     //==========================================================
     // 1. Read ARI Enhanced Cap register at DW addr = 0x40h

      config_address = ARI_CAP_BASE_ADDR;
      ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_func[7:3],     // EP Dev number 
                           ep_func[2:0],     // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);    // Completion Status

     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"Read ARI Enhanced Cap register at DW address 0x40h  = ", himage8(rdata)});

     if (rdata[15:0] != 16'hE) 
         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Expected ARI Cap ID = 0xE -- Actual = 0x", himage8(rdata[15:0])}); 
    
     if (rdata[19:16] != 4'h1) 
         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Expected ARI Cap version = 0x1 -- Actual = 0x", himage8(rdata[19:16])}); 

     if (rdata[31:20] != 12'h180) 
         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Expected ARI Next Cap Pointer to point to SR-IOV at byte address 0x180  -- Actual = 0x", himage8(rdata[31:20])}); 

     //==========================================================
     // 2. Read ARI Cap and Control register at DW addr = 0x41h

      config_address = ARI_CAP_REG_ADDR;
      ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_func[7:3],     // EP Dev number 
                           ep_func[2:0],     // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);     // Completion Status

     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"Read ARI Cap and Control register at DW address 0x41h  = ", himage8(rdata)});

     if (rdata[31:0] != 16'h0) 
         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Expected ARI Cap and Control = 0x0-- Actual = 0x", himage8(rdata[31:0])}); 
    
     //===============================================
      unused_result = ebfm_display(EBFM_MSG_INFO, {"Ending check_ari_cap "});
   end
endtask

//======================================
// Setup SR-IOV Cap 
//======================================
task enum_sriov_cap; 
   input integer  ep_bus;
   output reg[15:0] num_active_vfs;
   output reg[15:0] vf_offset;
   output reg[15:0] vf_stride;
   output reg[31:0] sys_pg_size;
   input  reg       check_all;

   reg [7:0]   ep_func;
   reg         unused_result ;
   reg [31:0]  wdata, rdata, exp_data;        // 32b General purpose write data
   reg [31:0]  config_address;      // Config_address
   reg [ 2:0]  compl_status;
   integer     dw_byte_length;      // downstream memory wr/rd length in byte
   
   begin
      
      ep_func = 0;
      dw_byte_length    = 4; 

      //===========================================================================
      // Temporarily replace EBFM_MSG_ERROR_FATAL with EBFM_MSG_INFO to debug
      //===========================================================================
     
     //==========================================================
     // 1. Read SR_IOV_CAP_BASE_ADDR at dw addr = 0x60h

      config_address = SR_IOV_CAP_BASE_ADDR;
      ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_func[7:3],     // EP Dev number 
                           ep_func[2:0],     // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);     // Completion Status

     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"Read SR-IOV Base register at DW address 0x60h  = ", himage8(rdata)});

     if (rdata[15:0] != 16'h10) 
         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Expected SR-IOV Cap ID = 0x10 -- Actual = 0x", himage8(rdata[15:0])}); 
    
     if (rdata[19:16] != 4'h1) 
         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Expected SR-IOV Cap version = 0x1 -- Actual = 0x", himage8(rdata[19:16])}); 

     if (rdata[31:20] != 12'h200) 
         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Expected SR-IOV Next Cap Pointer to point to Secondary PCIe Capability at byte address 0x200  -- Actual = 0x", himage8(rdata[31:20])}); 

     //==========================================================
     // 2. Read SR-IOV Cap register at DW addr = 0x61h
    if (check_all) begin
      config_address = SR_IOV_CAP_REG_ADDR;
      ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_func[7:3],     // EP Dev number 
                           ep_func[2:0],     // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);     // Completion Status

     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"Read SR-IOV Cap Register at DW address 0x61h  = ", himage8(rdata)});

     if (rdata[31:0] != 16'h2) 
         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Expected SR-IOV Cap set only ARI_CAP bit = 0x2 -- Actual = 0x", himage8(rdata[31:0])}); 
    
     //==========================================================
     // 3. Read SR-IOV Initial VF Count register at DW addr = 0x63h

      config_address = SR_IOV_INITIAL_VF_COUNT_REG_ADDR;
      ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_func[7:3],     // EP Dev number 
                           ep_func[2:0],     // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);     // Completion Status

     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"Read SR_IOV_INITIAL_VF_COUNT_REG_ADDR at DW address 0x63h  = ", himage8(rdata)});

     exp_data = top_tb.top_inst.dut.VF_COUNT;

     if (rdata[15:0] != exp_data[15:0]) 
         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Expected SR-IOV Initial VFs = ", himage8(exp_data[15:0])," -- Actual = 0x", himage8(rdata[15:0])}); 
    
     if (rdata[31:16] != exp_data[15:0]) 
         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Expected SR-IOV Total VFs   = ", himage8(exp_data[15:0])," -- Actual = 0x", himage8(rdata[31:16])}); 
   end // check_all

     //==========================================================
     // 4. Read SR_IOV_NUM_VFS_REG_ADDR register at DW addr = 0x64h

      config_address = SR_IOV_NUM_VFS_REG_ADDR;
      ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_func[7:3],     // EP Dev number 
                           ep_func[2:0],     // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);     // Completion Status

     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"Read SR_IOV_NUM_VFS_REG_ADDR at DW address 0x64h  = ", himage8(rdata)});

     if (rdata[15:0] != 16'h0) 
         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Expected default Number VFs = 0x0 -- Actual = 0x", himage8(rdata[15:0])}); 
    
     if (rdata[31:16] != 16'h0) 
         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Expected Functional_Dependency_List = 0x0 -- Actual = 0x", himage8(rdata[31:16])}); 

     //=======================
     //4.2 Set Num VF =  MAX_VF
     //=======================
     config_address = SR_IOV_NUM_VFS_REG_ADDR;
     wdata    = MAX_VF;
     exp_data = wdata; 

     unused_result = ebfm_display(EBFM_MSG_INFO, {"Set Num VFs = ", himage8(wdata) ," for PF0"});

     ebfm_cfgwr_imm_wait (
                           ep_bus,           // EP Bus number
                           ep_func[7:3],     // EP Dev number 
                           ep_func[2:0],     // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           wdata,            // Config Write data 
                           compl_status);    // Completion Status

     ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_func[7:3],     // EP Dev number 
                           ep_func[2:0],     // EP Func number
                           config_address,         // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);    // Completion Status

     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     if (rdata != exp_data) 
         unused_result = ebfm_display (EBFM_MSG_ERROR_FATAL, {"Error: Mismatched: Expected = ", himage8(exp_data), "  -----, ", "Actual = ", himage8(rdata)}); 
         
     num_active_vfs = rdata[15:0];

     //==========================================================
     // 5. Read SR_IOV_VF_OFFSET_STRIDE_REG_ADDR register at DW addr = 0x65h

    if (check_all) begin
      config_address = SR_IOV_VF_OFFSET_STRIDE_REG_ADDR;
      ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_func[7:3],     // EP Dev number 
                           ep_func[2:0],     // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);     // Completion Status

     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"Read SR_IOV_VF_OFFSET_STRIDE_REG_ADDR at DW address 0x65h  = ", himage8(rdata)});

     if (rdata[15:0] != 16'd32) 
         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Expected VF Offset = 32 -- Actual = 0x", himage8(rdata[15:0])}); 
    
     if (rdata[31:16] != 16'h1) 
         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Expected VF Stride = 0x1 -- Actual = 0x", himage8(rdata[31:16])}); 

     vf_offset = rdata[15:0];    
     vf_stride = rdata[31:16];

     //==========================================================
     // 6. Read SR_IOV_VF_DEVICE_ID_REG_ADDR register at DW addr = 0x66h

      config_address = SR_IOV_VF_DEVICE_ID_REG_ADDR;
      ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_func[7:3],     // EP Dev number 
                           ep_func[2:0],     // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);     // Completion Status

     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"Read SR_IOV_VF_DEVICE_ID_REG_ADDR at DW address 0x65h  = ", himage8(rdata)});

     exp_data = top_tb.top_inst.dut.VF_DEVICE_ID;

     if (rdata[15:0] != 16'h0) 
         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Expected reserved value = 0 -- Actual = 0x", himage8(rdata[15:0])}); 
    
     if (rdata[31:16] != exp_data[15:0]) 
         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Expected VF Device ID =", himage8(exp_data) , " -- Actual = 0x", himage8(rdata[31:16])}); 

     //==========================================================
     // 7. SR_IOV_SUPPORTED_PAGE_SIZES_REG_ADDR register at DW addr = 0x67h

      config_address = SR_IOV_SUPPORTED_PAGE_SIZES_REG_ADDR;
      ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_func[7:3],     // EP Dev number 
                           ep_func[2:0],     // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);     // Completion Status

     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"Read SR_IOV_SUPPORTED_PAGE_SIZES_REG_ADDR at DW address 0x65h  = ", himage8(rdata)});

     exp_data = top_tb.top_inst.dut.SYSTEM_PAGE_SIZES_SUPPORTED;

    
     if (rdata[31:0] != exp_data) 
         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Expected SYSTEM_PAGE_SIZES_SUPPORTED =", himage8(exp_data) , " -- Actual = 0x", himage8(rdata[31:0])}); 

  end //check_all
     //==========================================================
     // 8. SR_IOV_SYSTEM_PAGE_SIZE_REG_ADDR register at DW addr = 0x68h

      config_address = SR_IOV_SYSTEM_PAGE_SIZE_REG_ADDR;
      ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_func[7:3],     // EP Dev number 
                           ep_func[2:0],     // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);     // Completion Status

     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"Read SR_IOV_SYSTEM_PAGE_SIZE_REG_ADDR at DW address 0x68h  = ", himage8(rdata)});

     exp_data = 1; // default to 4KB
    
     if (rdata[31:0] != exp_data) 
         unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Expected SR_IOV_SYSTEM_PAGE_SIZE_REG =", himage8(exp_data) , " -- Actual = 0x", himage8(rdata[31:0])}); 

     sys_pg_size =rdata;

     //==========================================================
     // 9. Write all one to VF BAR0 register
     //==========================================================
    if (check_all) begin
      config_address = SR_IOV_VF_BAR0_ADDR;
      wdata    = 32'hffffffff;
      exp_data[31:23] = 20'hfffff; 

      ebfm_cfgwr_imm_wait (
                           ep_bus,           // EP Bus number
                           ep_func[7:3],     // EP Dev number 
                           ep_func[2:0],     // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           wdata,            // Config Write data 
                           compl_status);    // Completion Status

     ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_func[7:3],     // EP Dev number 
                           ep_func[2:0],     // EP Func number
                           config_address,         // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);    // Completion Status

     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"Read BAR0 at DW address = ", himage8(config_address), "with data =", himage8(rdata)});

     if (rdata[31:23] != exp_data[31:23]) 
         unused_result = ebfm_display (EBFM_MSG_ERROR_FATAL, {"Error: Mismatched: Expected = ", himage8(exp_data), "  -----, ", "Actual = ", himage8(rdata)}); 
         
     //==========================================================
     // 10. Write all one to VF BAR1 register
     //==========================================================
     if (rdata[2] == 0) begin // 32 bit addressing 
       config_address = SR_IOV_VF_BAR1_ADDR;
       wdata    = 32'hffffffff;
       exp_data[31:23] = 20'hfffff; 

       ebfm_cfgwr_imm_wait (
                           ep_bus,           // EP Bus number
                           ep_func[7:3],     // EP Dev number 
                           ep_func[2:0],     // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           wdata,            // Config Write data 
                           compl_status);    // Completion Status

        ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_func[7:3],     // EP Dev number 
                           ep_func[2:0],     // EP Func number
                           config_address,         // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);    // Completion Status

        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
        unused_result = ebfm_display(EBFM_MSG_INFO, {"Read BAR1 at DW address = ", himage8(config_address), "with data =", himage8(rdata)});

        if (rdata[31:23] != exp_data[31:23]) 
          unused_result = ebfm_display (EBFM_MSG_ERROR_FATAL, {"Error: Mismatched: Expected = ", himage8(exp_data), "  -----, ", "Actual = ", himage8(rdata)}); 
         

        unused_result = ebfm_display(EBFM_MSG_INFO, {"Ending enum_sriov_cap"});
      end //if rdata[2]   
  end //check_all
 end
endtask

//======================================
// Setup VF_EN and MSE in SR-IOV Cap
//======================================
task enable_vf_mse ; 
   input integer   ep_bus;
   input reg [7:0] ep_func;

   reg         unused_result ;
   reg [31:0]  wdata, rdata, exp_data;        // 32b General purpose write data
   reg [31:0]  config_address;      // Config_address
   reg [ 2:0]  compl_status;
   integer     dw_byte_length;      // downstream memory wr/rd length in byte
   
   begin
      
      dw_byte_length    = 4; 

     //============================================================================
     //9. SR_IOV_CTL_REG_ADDR at dw addr 0x62: 
     // a. Set VF_EN=1 => bit[0]=1,  and 
     // b. Set VF_MSE = => bit[3]=1 
     // b. Set ARI_Cap_Hierarchy => bit[4]= 1 
     //============================================================================
      config_address = SR_IOV_CTL_REG_ADDR;
      wdata    = {27'h0, 1'b1, 1'b1, 2'b0, 1'b1};
      exp_data = wdata; 

      unused_result = ebfm_display(EBFM_MSG_INFO, {"SR_IOV_CTL_REG_ADDR: Set VF_Enable and ARI Cap bit with wdata = ", himage8(wdata)});

      ebfm_cfgwr_imm_wait (
                           ep_bus,           // EP Bus number
                           ep_func[7:3],     // EP Dev number 
                           ep_func[2:0],     // EP Func number
                           config_address,   // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           wdata,            // Config Write data 
                           compl_status);    // Completion Status

      ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           ep_func[7:3],     // EP Dev number 
                           ep_func[2:0],     // EP Func number
                           config_address,         // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);    // Completion Status

      rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
      if (rdata != exp_data) 
         unused_result = ebfm_display (EBFM_MSG_ERROR_FATAL, {"Error: Mismatched: Expected = ", himage8(exp_data), "  -----, ", "Actual = ", himage8(rdata)}); 

   end
endtask
//===============================================
// Configure VF BARs
//   a. Find out BAR size: Write all 1 to each BAR and then read back to
//   find the BAR Size.
//   b. Program BAR with the next valid value. All VF resources must be
//   alighed with System_Page_Size
//      - If BAR size < System_Page_Size, program the base address with
//      System_page_size
//      - If BAR size > System_Page_Size, program the base address using
//      the current aperture size 
//   c. For each VF from 1 to NumVFs-1, derive BAR# values from the value of VF0 BAR#
//    => Multiply by the apperture derived from system page size with minimum size
//    of 4KB.
//      - Program the Sharememory with the calculated value and then
//      transfer them to VFs BARs
//
//===============================================
   // purpose: configure a set of bars
   task ebfm_cfg_sriov_bars;
      input integer bnm;         // Bus Number
      input [4:0] dev;         // Device Number
      input [2:0] fnc;         // Function Number
      input [63:0] bar_table;   // Base Address in Shared Memory to
      input reg [31:0]  sys_pg_size; // in byte address
      input reg[15:0]   num_vfs;
      input reg[ 2:0]   max_bar;

      inout reg [63:0] m32min;
      inout reg [63:0] m32max;
      inout reg [63:0] m64min;
      inout reg [63:0] m64max;

      inout reg [136:0] vf_bar0;
      inout reg [136:0] vf_bar1;
      inout reg [136:0] vf_bar2;
      inout reg [136:0] vf_bar3;
      inout reg [136:0] vf_bar4;
      inout reg [136:0] vf_bar5;

      input         addr_map_4GB_limit;
      input integer display;
      output         bar_ok;

      reg[63:0] m32min_v;
      reg[63:0] m32max_v;
      reg[63:0] m64min_v;
      reg[63:0] m64max_v;
      reg typ1;
      reg[2:0] compl_status;
      integer nbar;
      reg[63:0] bars[0:6];
      reg[63:0] vf_bars[0:TOTAL_VF-1][0:6];
      integer sm_bar[0:6];
      reg[8:0] bar_lsb[0:6];

      reg [7:0] htype ;
      reg dummy ;
      reg [63:0] bars_xhdl ;
      integer    i;
      reg        unused_result ;
      reg[139:0] vf_bar;   // tbar = temporary bar
      begin  // ebfm_cfg_bars
         m32min_v = m32min ;
         m32max_v = m32max ;
         m64min_v = m64min ;
         m64max_v = m64max ;
         sm_bar[0] = 0 ;
         sm_bar[1] = 1 ;
         sm_bar[2] = 2 ;
         sm_bar[3] = 3 ;
         sm_bar[4] = 4 ;
         sm_bar[5] = 5 ;
         sm_bar[6] = 6 ;

         bar_ok = 1'b1;

        // Unlock the bfm shared memory for initialization
          bfm_shmem_common.protect_bfm_shmem = 1'b0;
          if (display) begin
            unused_result = ebfm_display (EBFM_MSG_INFO , {" ====> Call ebfm_cfg_sriov_bars:"}); 
            unused_result = ebfm_display (EBFM_MSG_INFO , {"------------ bar_table :", himage8(bar_table)}); 
            unused_result = ebfm_display (EBFM_MSG_INFO , {"------------ func:", himage8({dev, fnc})}); 
          end
         //===============================
         // 1. VF BAR table 
         //===============================
         // 1a. Initialize 32 entries by filling it with all 1 for write
         shmem_fill(bar_table, SHMEM_FILL_ONE, 32, {64{1'b0}});

         // 1b. Clear the last bit of the ROMBAR which is the enable bit...
         shmem_write(bar_table + 24, 8'hFE, 1) ;
         // 1c. Read Header Type Field into last DWORD
         ebfm_cfgrd_wait(bnm, dev, fnc, 12, 4, bar_table + 28, compl_status);

         htype = shmem_read(bar_table + 30, 1) ;
         if (htype[6:0] == 7'b0000001)
         begin
            typ1 = 1'b1;
         end
         else
         begin
            typ1 = 1'b0;
         end

         // 1d. Write to each BAR with value in bar_table which is all one as
         // done in step 1a.
         cfg_wr_vf0_bars(bnm, dev, fnc, bar_table, max_bar, display);

         //1e. Fill the content of 28 byte of bar_table with all zero. These
         //locations are used to store the real BARs base addresses later 
         shmem_fill(bar_table, SHMEM_FILL_ZERO, 28, {64{1'b0}});

         //1f. Initialize the scratch area wich is used to store the BAR read
         shmem_fill(bar_table + 32, SHMEM_FILL_ZERO, 32, {64{1'b0}});
         cfg_rd_vf0_bars(bnm, dev, fnc, bar_table + 32, max_bar, display);

         // Load each BAR into the local BAR array
         // Find the Least Significant Writable bit in each BAR
         nbar = 0;
         while (nbar < max_bar)
           begin
              // Read the current BAR value from share memory
              bars[nbar] = shmem_read((bar_table + 32 + (nbar * 4)), 8);
              bars_xhdl = bars[nbar]; // assign it to temp variable bars_xhdl
              if (display) begin 
                unused_result = ebfm_display (EBFM_MSG_INFO , {"=====    Set bars_xhdl = ", himage8(bars_xhdl)}); 
              end

              if ((bars_xhdl[2]) == 1'b0)  // this is 32bit addressing....
                begin
                   // 32 bit
                   if ((bars_xhdl[31]) == 1'b1) // check the sign bit and extend it
                     begin
                        // if valid, extend the sign bits
                        bars_xhdl[63:32] = {32{1'b1}};
                     end
                   else
                     begin
                        // if not valid
                        bars_xhdl[63:32] = {32{1'b0}};
                     end
                end
              else
                begin
                   // 64-bit BAR, mark the next one invalid. Applicable for
                   // BAR[1], BAR[3], and BAR[5]
                   bar_lsb[nbar + 1] = 64;
                end
              // Update the new signed extended value in bars_xhdl to array bars[]
              bars[nbar] = bars_xhdl ;
              if (display) begin 
                unused_result = ebfm_display (EBFM_MSG_INFO , {"=====    Set bars[", himage8(nbar), "] = ", himage8(bars_xhdl)}); 
              end
              // If current BAR is not present, invalidate it  
              if (bars_xhdl[63:4] == 0)
                begin
                   bar_lsb[nbar] = 64;
                   if (display) begin 
                      unused_result = ebfm_display (EBFM_MSG_INFO , {"=====   Invalid BAR because bars_xhdl[63:4] = 0"}); 
                      unused_result = ebfm_display (EBFM_MSG_INFO , {"=====   Set bar_lsb[", himage8(nbar), "] = 64"}); 
                   end
                end
              else // Current BAR is valid, find the first bit that is set to 1
                begin // and assign it to appropriate bit in bars_lsb and exit xhdl_3
                   begin : xhdl_3
                      integer j;
                      for(j = 4; j <= 63; j = j + 1)
                        begin : lsb_loop
                           if ((bars_xhdl[j]) == 1'b1)
                             begin
                                bar_lsb[nbar] = j; //Mark the first non-zero bit location to array bar_lsb
                                if (display) begin
                                  unused_result = ebfm_display (EBFM_MSG_INFO , {"===== xhdl_3:  Set bar_lsb[", himage8(nbar), "] = ", himage8(j)}); 
                                end
                                disable xhdl_3 ;
                             end
                        end
                   end // j
                end //current valid BAR

              // Goto next valid BAR by incrementing 1 for 32bit BARs or 2 for 64bit BARs.
              bars_xhdl = bars[nbar]; // Why need to recopy???
              if ((bars_xhdl[2]) == 1'b0)
                begin
                   nbar = nbar + 1;
                end
              else
                begin
                   nbar = nbar + 2;
                end

                if (display) begin
                  unused_result = ebfm_display (EBFM_MSG_INFO , {"===== xhdl_3:  Update nbar = ", himage8(nbar)}); 
                end
           end // i

         begin : xhdl_4
            integer i;
            //for(i = 0; i <= 5; i = i + 1)
            for(i = 0; i < max_bar; i = i + 1)
              begin
                 // Sort the BARs in order smallest to largest
                 begin : xhdl_5
                    integer j;
                    for(j = i + 1; j < max_bar; j = j + 1) // <=6
                      begin
                         if (display) begin
                            unused_result = ebfm_display (EBFM_MSG_INFO , {"sorting BARs: "}); 
                         end
                         if (bar_lsb[sm_bar[j]] < bar_lsb[sm_bar[i]])
                           begin
                              nbar = sm_bar[i];
                              sm_bar[i] = sm_bar[j];
                              sm_bar[j] = nbar;
                              if (display) begin
                                unused_result = ebfm_display (EBFM_MSG_INFO , {"sm_bar[", himage8(i), "] = ", himage8(sm_bar[i])}); 
                                unused_result = ebfm_display (EBFM_MSG_INFO , {"sm_bar[", himage8(j), "] = ", himage8(sm_bar[j])}); 
                              end  
                           end
                      end
                 end // j
              end
         end // i

        //=========================================================================
         // Now fill all of the 32-bit Non-Prefetchable BARs, Smallest to Largest
         begin : xhdl_7
            integer i, j;
            for(i = 0; i < max_bar; i = i + 1) // <=6
              begin
                 if (bar_lsb[sm_bar[i]] < 64) // if valid BAR
                   begin
                      bars_xhdl = bars[sm_bar[i]];
                      // bit[0]=0 for mem, bit[1]= rs, bit[2]=0 for 32bit addressing, and bit[3]=0 for non-prefetchable 
                      if (bars_xhdl[3:0] == 4'b0000) 
                        begin
                           assign_vf0_bar(bars[sm_bar[i]], sm_bar[i], bar_lsb[sm_bar[i]], m32min_v, m32max_v,sys_pg_size, vf_bar,num_vfs, display);
                           save_vf_bar (vf_bar, vf_bar0, vf_bar1, vf_bar2, vf_bar3, vf_bar4, vf_bar5, display);
                        end
                   end
              end
         end // i
         // Now fill all of the 32-bit Prefetchable BARs (and 64-bit Prefetchable BARs if addr_map_4GB_limit is set),
         // Largest to Smallest. From the top of memory.
         begin : xhdl_8
            integer i;
            if (display) begin
              unused_result = ebfm_display (EBFM_MSG_INFO , {"=====  Start xhdl_8"}); 
            end
            for(i = 6; i >= 0; i = i - 1)
              begin
                 if (bar_lsb[sm_bar[i]] < 64)
                   begin
                      bars_xhdl = bars[sm_bar[i]];
                      // bit[0]=0 for mem, bit[1]= rs, bit[2]=0 for 32bit addressing, and bit[3]=1 for prefetchable 
                      if (bars_xhdl[3:0] == 4'b1000 ||
                         (addr_map_4GB_limit && bars_xhdl[3:0] == 4'b1100))
                        begin
                           assign_vf0_bar(bars[sm_bar[i]], sm_bar[i], bar_lsb[sm_bar[i]], m32min_v, m32max_v,sys_pg_size, vf_bar, num_vfs, display);
                           save_vf_bar (vf_bar, vf_bar0, vf_bar1, vf_bar2, vf_bar3, vf_bar4, vf_bar5, display);
                        end
                   end
              end
         end // i
         // Now fill all of the 64-bit Prefetchable BARs, Smallest to Largest, if addr_map_4GB_limit is not set.
         if (addr_map_4GB_limit == 1'b0)
         begin : xhdl_9
            integer i;
            if (display) begin
              unused_result = ebfm_display (EBFM_MSG_INFO , {"=====  Start xhdl_9"}); 
            end  
            for(i = 0; i < max_bar; i = i + 1) //7
            begin
               if (bar_lsb[sm_bar[i]] < 64)
                 begin
                    bars_xhdl = bars[sm_bar[i]];
                      // bit[0]=0 for mem, bit[1]= rs, bit[2]=1 for 64bit addressing, and bit[3]=1 for prefetchable 
                    if (bars_xhdl[3:0] == 4'b1100)
                      begin
                           assign_vf0_bar(bars[sm_bar[i]], sm_bar[i], bar_lsb[sm_bar[i]], m64min_v, m64max_v,sys_pg_size, vf_bar, num_vfs, display);
                           save_vf_bar (vf_bar, vf_bar0, vf_bar1, vf_bar2, vf_bar3, vf_bar4, vf_bar5, display);
                      end
                 end
            end
         end // igg
         // Now put all of the BARs back in memory
         nbar = 0;
         if (display == 1)
           begin
              dummy = ebfm_display(EBFM_MSG_INFO, "");
              dummy = ebfm_display(EBFM_MSG_INFO, "BAR Address Assignments:");
              dummy = ebfm_display(EBFM_MSG_INFO, {"BAR   ", " ", "Size      ", " ", "Assigned Address ", " ", "Type"});
              dummy = ebfm_display(EBFM_MSG_INFO, {"---   ", " ", "----      ", " ", "---------------- ", " "});
           end
         while (nbar < max_bar) //7
           begin
              // Show the user what we have done
              if (display == 1) begin
                describe_bar(nbar, bar_lsb[nbar], bars[nbar],1'b0) ;
              end  
              bars_xhdl = bars[nbar];
              // Check and see if the BAR was unabled to be assigned!!
              if (bars_xhdl[32] === 1'bx) begin
                 bar_ok = 1'b0;
                 // Clean up the X's...
                 bars[nbar] = {{60{1'b0}},bars[nbar][3:0]} ;
              end

              bars_xhdl = bars[nbar];
              if ((bars_xhdl[2]) != 1'b1) begin // 32bit BAR 
                 shmem_write(bar_table + (nbar * 4), bars_xhdl[31:0], 4);
                 nbar = nbar + 1;
              end else begin //64bit BAR
                 shmem_write(bar_table + (nbar * 4), bars_xhdl[63:0], 8);
                 nbar = nbar + 2;
              end
           end

         unused_result = ebfm_display (EBFM_MSG_INFO , {"===== Now put all of the BARs back in memory"}); 

         cfg_wr_vf0_bars(bnm, dev, fnc, bar_table, max_bar, display);
         // Turn off the lowest bit of the ExpROM BAR so rest of the BFM knows it is a memory BAR
         shmem_write(bar_table + 24, 8'h00, 1) ;

         m64max = m64max_v;
         m64min = m64min_v;
         m32max = m32max_v;
         m32min = m32min_v;

        // lock the bfm shared memory for initialization
          bfm_shmem_common.protect_bfm_shmem = 1'b1;
      end
   endtask

//=============================================================================
// Assign VF BARs in SR-IOV structure
// a. Discover the bar size
// b. Multiply the value from (a) to determine the total amount of space the
// BAR or BAR pari will map after VF_Enable and VF_MSE are set
//=============================================================================
//===============================================
   task assign_vf0_bar;
      inout   reg [63:0] bar;  // BAR value
      input   reg [ 2:0] bar_no; // BAR number [0:5]
      input   reg [ 9:0] bsize_pos; // 1st bit position indicating the size  
      inout   reg [63:0] amin; // amin = address minimum
      input   reg [63:0] amax; // amax = address maximum
      input   reg [31:0] sys_pg_size; // in byte address
      output  reg [139:0] vf_bar;  // [139:131]: bsize position; [130:128] = BAR_INDEX, [127:64] = VF offset, [63:0] = VF bar size
      input   reg [15:0] num_vfs;
      input   integer    display;

      reg[63:0] tbar;   // tbar = temporary bar
      reg       unused_result ;
      reg[43:0] page_size;
      reg[63:0] bsiz;

      begin
         tbar = {bar[63:4], 4'b0000};
         bsiz = (~tbar) + 1;

         if (display == 1) begin
            unused_result = ebfm_display (EBFM_MSG_INFO , {"==>>>  Beginning of assign_vf0_bar: "}); 
            unused_result = ebfm_display (EBFM_MSG_INFO , {"=====    bar_value   = ", himage8(bar)}); 
            unused_result = ebfm_display (EBFM_MSG_INFO , {"=====    tbar        = ", himage8(tbar)}); 
            unused_result = ebfm_display (EBFM_MSG_INFO , {"=====    amin        = ", himage8(amin)}); 
         end
        
         page_size = 1 << ((sys_pg_size -1) + 12 ); //n=1: page_size = 4KB, n=2: page_size = 8KB, ...64KB, 256KB,1KB, and 4KB

         if (bsiz < page_size) begin
            bsiz = page_size;
            tbar = (amin + bsiz);
         end else if ((amin  & ~tbar) == 0) begin
         // If current BAR is smaller than sys_pg_size(sps), align it to sps
            tbar = tbar & amin; // Lowest assignment
         end else begin
            // The lower bits were not 0, then we have to round up to the
            // next boundary
            tbar = (amin + bsiz) & tbar ;
         end

         if ((tbar + bsiz - 1) > amax) begin
            // We cant make the assignment
            unused_result = ebfm_display (EBFM_MSG_INFO , {"ERROR ==>>> Can't make the BAR assignment"}); 
            bar[63:4] = {60{1'bx}};
         end else begin
            bar[63:4] = tbar[63:4];
            amin = tbar + (bsiz * num_vfs);
         end

         // Save VF BAR offset and size
         vf_bar = {bar_no[2:0],     //[139:137]
                   bsize_pos[8:0],  //[136:128]
                   bar[63:0],       //[127: 64] = bar_value
                   bsiz};           //[ 63:  0]

         if (display == 1) begin
            unused_result = ebfm_display (EBFM_MSG_INFO , {"==>>>  At the end of assign_vf0_bar: "}); 
            unused_result = ebfm_display (EBFM_MSG_INFO , {"=====    bar_no      = ", himage8(bar_no)}); 
            unused_result = ebfm_display (EBFM_MSG_INFO , {"=====    bsize_pos   = ", himage8(bsize_pos)}); 
            unused_result = ebfm_display (EBFM_MSG_INFO , {"=====    bar_value   = ", himage8(bar)}); 
            unused_result = ebfm_display (EBFM_MSG_INFO , {"=====    bsiz        = ", himage8(bsiz)}); 
            unused_result = ebfm_display (EBFM_MSG_INFO , {"=====    tbar        = ", himage8(tbar)}); 
            unused_result = ebfm_display (EBFM_MSG_INFO , {"=====    amin        = ", himage8(amin)}); 
            unused_result = ebfm_display (EBFM_MSG_INFO , {"=====    sys_pg_size = ", himage8(sys_pg_size)}); 
            unused_result = ebfm_display (EBFM_MSG_INFO , {"=====    page_size   = ", himage8(page_size)}); 
            unused_result = ebfm_display (EBFM_MSG_INFO , {"=====    vf_bar      = ", himage16(vf_bar)}); 
         end
      end
   endtask

//===============================================
// Assign subsequence VF BARs
// Subsequence VF BARs are derived from those of VF0 
//===============================================
   task assign_vf_bar;
      inout   reg [63:0]  bar_table; 
      input   reg [  2:0] bar_no;
      input   reg [63:0]  bar_value;
      input   reg [  8:0] bsize_pos;
      input   integer     display;
      output  reg         bar_ok;


      reg         unused_result ;
      reg [63:0] bars_xhdl ;

      begin

        // Unlock the bfm shared memory for initialization
         bfm_shmem_common.protect_bfm_shmem = 1'b0;

         bars_xhdl = bar_value;

         if (bsize_pos < 64) begin
              // Show the user what we have done
              // describe_bar(bar_no, bsize_pos, bar_value,1'b0) ;

              // Check and see if the BAR was unabled to be assigned!!
              if (bars_xhdl[32] === 1'bx) begin
                 bar_ok = 1'b0;
                 // Clean up the X's...
                 bars_xhdl=  {{60{1'b0}},bar_value[3:0]} ;
              end

              if (bars_xhdl[2] != 1'b1) begin // 32bit BAR 
                 shmem_write(bar_table + (bar_no * 4), bars_xhdl[31:0], 4);
              end else begin //64bit BAR
                 shmem_write(bar_table + (bar_no * 4), bars_xhdl[63:0], 8);
              end
         end

         if (display == 1) begin
            unused_result = ebfm_display (EBFM_MSG_INFO , {"==>>>  assign_vf_bar for bar_no = ", himage8(bar_no)}); 
          //unused_result = ebfm_display (EBFM_MSG_INFO , {"=====   vf_table  = ", himage8(bar_table), "-- bars_xhdl = ", himage8(bars_xhdl)}); 
            unused_result = ebfm_display (EBFM_MSG_INFO , {"=====   bar_no    = ", himage8(bar_no)}); 
            unused_result = ebfm_display (EBFM_MSG_INFO , {"=====   bar_value = ", himage8(bar_value)}); 
            unused_result = ebfm_display (EBFM_MSG_INFO , {"=====   bsize_pos = ", himage8(bsize_pos)}); 
         end

        // lock the bfm shared memory for initialization
          bfm_shmem_common.protect_bfm_shmem = 1'b1;
      end
   endtask


//===============================================
// Save VF BAR to appropriate BAR variables
//===============================================
   task save_vf_bar;
      input   reg [139:0] vf_bar; //[130:128] = index, [127:64]= offset, [63:0] = size
      inout   reg [136:0] vf_bar0; //[136:128]= size_position [127:64]= offset, [63:0] = size
      inout   reg [136:0] vf_bar1; //[136:128]= size_position [127:64]= offset, [63:0] = size
      inout   reg [136:0] vf_bar2; //[136:128]= size_position [127:64]= offset, [63:0] = size
      inout   reg [136:0] vf_bar3; //[136:128]= size_position [127:64]= offset, [63:0] = size
      inout   reg [136:0] vf_bar4; //[136:128]= size_position [127:64]= offset, [63:0] = size
      inout   reg [136:0] vf_bar5; //[136:128]= size_position [127:64]= offset, [63:0] = size
      input   integer    display;

      integer   i;
      reg           unused_result ;
      reg [2:0]     bar_no;
      reg [63:0]    offset;
      reg [63:0]    size;
      reg [ 8:0]    bsize_pos;

      begin
         bar_no  = vf_bar[139:137];
         bsize_pos = vf_bar[136:128];  
         offset = vf_bar[127:64];
         size   = vf_bar[63:0];

         if (display == 1) begin
            unused_result = ebfm_display (EBFM_MSG_INFO , {"==>>>  save_vf_bar: "}); 
            unused_result = ebfm_display (EBFM_MSG_INFO , {"=====    bar_no       = ", himage8(vf_bar[139:137])}); 
            unused_result = ebfm_display (EBFM_MSG_INFO , {"=====    bsize_pos    = ", himage8(vf_bar[136:128])}); 
            unused_result = ebfm_display (EBFM_MSG_INFO , {"=====    amin offset  = ", himage8(vf_bar[127:64])}); 
            unused_result = ebfm_display (EBFM_MSG_INFO , {"=====    bsize        = ", himage8(vf_bar[63:0])}); 
         end

         if      (bar_no == 3'h0) vf_bar0 = vf_bar[136:0];
         else if (bar_no == 3'h1) vf_bar1 = vf_bar[136:0];
         else if (bar_no == 3'h2) vf_bar2 = vf_bar[136:0];
         else if (bar_no == 3'h3) vf_bar3 = vf_bar[136:0];
         else if (bar_no == 3'h4) vf_bar4 = vf_bar[136:0];
         else if (bar_no == 3'h5) vf_bar5 = vf_bar[136:0];
         else begin
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Invalid VF_BAR bar_no =", himage8(bar_no)}); 
         end  

         if (display == 1) begin
            if      (bar_no == 3'h0) unused_result = ebfm_display (EBFM_MSG_INFO , {"=====  vf_bar0  = ", himage8(vf_bar0)}); 
            else if (bar_no == 3'h1) unused_result = ebfm_display (EBFM_MSG_INFO , {"=====  vf_bar1  = ", himage8(vf_bar1)}); 
            else if (bar_no == 3'h2) unused_result = ebfm_display (EBFM_MSG_INFO , {"=====  vf_bar2  = ", himage8(vf_bar2)}); 
            else if (bar_no == 3'h3) unused_result = ebfm_display (EBFM_MSG_INFO , {"=====  vf_bar3  = ", himage8(vf_bar3)}); 
            else if (bar_no == 3'h4) unused_result = ebfm_display (EBFM_MSG_INFO , {"=====  vf_bar4  = ", himage8(vf_bar4)});  
            else if (bar_no == 3'h5) unused_result = ebfm_display (EBFM_MSG_INFO , {"=====  vf_bar5  = ", himage8(vf_bar5)}); 
         end  

      end
   endtask

//============================================
// Write VF0 BARs into SR-IOV Cap
//============================================

   task cfg_wr_vf0_bars;
      input [7:0]     bnm;
      input [4:0]     dev;
      input [2:0]     fnc;
      input [63:0]    bar_base;
      input reg[2:0]  max_bar;
      input integer   display;

      reg [2:0]  min_bar;
      reg [11:0] dw_addr;
      reg [2:0]  compl_status;
      reg [63:0] rdata;
      reg        unused_result ;

      begin
         
         // VF_BAR0 is at dw_addr 0x69
         dw_addr = 12'h69; 
         min_bar = 0; 
         
         begin : xhdl_0
            reg [11:0] i;
            for(i = min_bar ; i < max_bar; i = i + 1)
            begin
              rdata = shmem_read (bar_base + (i * 4), 4);
              ebfm_cfgwr_imm_nowt(bnm, dev, fnc, (dw_addr * 4), 4, rdata );
              if (display == 1)begin
                unused_result = ebfm_display (EBFM_MSG_INFO , {"===== Write to VF0 BAR[", himage8(i), "] at dw_addr = ",himage8(dw_addr) , " with wdata = ", himage8(rdata)}); 
              end  
              dw_addr = dw_addr + 1;
            end
         end // i
      end
   endtask

//============================================
// Read VF0 BARs into SR-IOV Cap
//============================================

   task cfg_rd_vf0_bars;
      input [7:0]     bnm;
      input [4:0]     dev;
      input [2:0]     fnc;
      input [63:0]    bar_base;
      input reg[2:0]  max_bar; // 4 for Phase1 and 6 for Phase2
      input integer   display;

      reg [2:0]  min_bar;
      reg [11:0] dw_addr;
      reg [2:0]  compl_status;
      reg [63:0] rdata;
      reg        unused_result ;
      reg[63:0]  shmem_addr;
      reg[63:0]  cfg_addr;

      begin

         // VF_BAR0 is at dw_addr 0x69
         dw_addr = 12'h69; // SRIOV Offset to VF0 BAR0
         min_bar = 0; 

         if (display == 1) begin
            unused_result = ebfm_display (EBFM_MSG_INFO , {"==>>> xhdl_1:  cfg_rd_vf0_bars: "}); 
            unused_result = ebfm_display (EBFM_MSG_INFO , {"=====    fnc          = ", himage8({dev, fnc})}); 
            unused_result = ebfm_display (EBFM_MSG_INFO , {"=====    bar_base     = ", himage8(bar_base)}); 
         end

         begin : xhdl_1
            integer i;

            for(i = min_bar ; i < max_bar; i = i + 1)
            begin
               cfg_addr = (dw_addr * 4);
               shmem_addr = bar_base + (i * 4);

               ebfm_cfgrd_wait(    
                           bnm,           // EP Bus number
                           dev,           // EP Dev number 
                           fnc,           // EP Func number
                           cfg_addr,      // Config register address in byte 
                           4,             // Byte length 
                           shmem_addr,      // Config Scratch Space where Config RD data is stored 
                           compl_status);    // Completion Status

               rdata = shmem_read (shmem_addr, 4);
  
               if (display == 1)begin
                  unused_result = ebfm_display (EBFM_MSG_INFO , {"=====  cfg_rd at addr= ", himage8(dw_addr), " to shmem_addr =", himage8(shmem_addr), " with rdata = ", himage8(rdata)}); 
               end   
               dw_addr = dw_addr + 1;
            end
         end // i
      end
   endtask

   //===========================================================================
   // purpose: Describes the attributes of the BAR and the assigned address
   //===========================================================================
   task describe_sriov_bar;
      input reg        func_type; // 0 = PF, 1 = VF
      input reg [15:0] func_num;
      input reg [ 2:0] bar_num;
      input reg [ 8:0] bsize_pos;
      input reg [63:0] bar;
      input            addr_unused ;

      reg[(8)*8:1] func_str;
      reg[(6)*8:1] bar_num_str;
      reg[(10)*8:1] bar_size_str;
      reg[(16)*8:1] bar_type_str;
      reg bar_enabled;
      reg[(17)*8:1] addr_str;

      reg dummy ;

      begin  // describe_sriov_bar
         bar_enabled  = 1'b1 ;

         //============================
         // Find BAR Size 
         //============================
         case (bsize_pos)
            4  : bar_size_str = " 16 Bytes ";
            5  : bar_size_str = " 32 Bytes ";
            6  : bar_size_str = " 64 Bytes ";
            7  : bar_size_str = "128 Bytes ";
            8  : bar_size_str = "256 Bytes ";
            9  : bar_size_str = "512 Bytes ";
            10 : bar_size_str = "  1 KBytes";
            11 : bar_size_str = "  2 KBytes";
            12 : bar_size_str = "  4 KBytes";
            13 : bar_size_str = "  8 KBytes";
            14 : bar_size_str = " 16 KBytes";
            15 : bar_size_str = " 32 KBytes";
            16 : bar_size_str = " 64 KBytes";
            17 : bar_size_str = "128 KBytes";
            18 : bar_size_str = "256 KBytes";
            19 : bar_size_str = "512 KBytes";
            20 : bar_size_str = "  1 MBytes";
            21 : bar_size_str = "  2 MBytes";
            22 : bar_size_str = "  4 MBytes";
            23 : bar_size_str = "  8 MBytes";
            24 : bar_size_str = " 16 MBytes";
            25 : bar_size_str = " 32 MBytes";
            26 : bar_size_str = " 64 MBytes";
            27 : bar_size_str = "128 MBytes";
            28 : bar_size_str = "256 MBytes";
            29 : bar_size_str = "512 MBytes";
            30 : bar_size_str = "  1 GBytes";
            31 : bar_size_str = "  2 GBytes";
            32 : bar_size_str = "  4 GBytes";
            33 : bar_size_str = "  8 GBytes";
            34 : bar_size_str = " 16 GBytes";
            35 : bar_size_str = " 32 GBytes";
            36 : bar_size_str = " 64 GBytes";
            37 : bar_size_str = "128 GBytes";
            38 : bar_size_str = "256 GBytes";
            39 : bar_size_str = "512 GBytes";
            40 : bar_size_str = "  1 TBytes";
            41 : bar_size_str = "  2 TBytes";
            42 : bar_size_str = "  4 TBytes";
            43 : bar_size_str = "  8 TBytes";
            44 : bar_size_str = " 16 TBytes";
            45 : bar_size_str = " 32 TBytes";
            46 : bar_size_str = " 64 TBytes";
            47 : bar_size_str = "128 TBytes";
            48 : bar_size_str = "256 TBytes";
            49 : bar_size_str = "512 TBytes";
            50 : bar_size_str = "  1 PBytes";
            51 : bar_size_str = "  2 PBytes";
            52 : bar_size_str = "  4 PBytes";
            53 : bar_size_str = "  8 PBytes";
            54 : bar_size_str = " 16 PBytes";
            55 : bar_size_str = " 32 PBytes";
            56 : bar_size_str = " 64 PBytes";
            57 : bar_size_str = "128 PBytes";
            58 : bar_size_str = "256 PBytes";
            59 : bar_size_str = "512 PBytes";
            60 : bar_size_str = "  1 EBytes";
            61 : bar_size_str = "  2 EBytes";
            62 : bar_size_str = "  4 EBytes";
            63 : bar_size_str = "  8 EBytes";
            default :
                     begin
                        bar_size_str = "Disabled  ";
                        bar_enabled = 0;
                     end
         endcase

         //============================
         // Define BAR type
         //============================
         if (bar_num == 6) begin
            bar_num_str = "ExpROM";
         end
         else begin
            bar_num_str = {"BAR", dimage1(bar_num), "  "};
         end

         //============================
         // Display function type
         //============================
         if (func_type == 0) begin 
            func_str = {"PF", himage2(func_num), "    "};
         end else begin 
            func_str = {"VF", himage2(func_num), "    "};
         end

         //============================
         // Display BAR value and type in bar_num_str
         //============================
         if (bar_enabled)
         begin
            if ((bar[2]) == 1'b1)
            begin
               bar_num_str = {"BAR", dimage1(bar_num+1), ":", dimage1(bar_num)};
            end
            if (addr_unused == 1'b1 )
              begin
                 addr_str = "Not used in RP   ";
              end
            else
              begin
                 if ( (bar[32] == 1'b0) | (bar[32] == 1'b1) )
                   begin
                      if ((bar[2]) == 1'b1) // 64bit BAR
                        begin
                           addr_str[136:73] = himage8(bar[63:32]);
                        end
                      else // 32bit BAR
                        begin
                           addr_str[136:73] = "        ";
                        end
                      addr_str[72:65] = " ";
                      addr_str[64:1] = himage8({bar[31:4], 4'b0000});
                   end
                 else
                   begin
                      addr_str = "Unassigned!!!    ";
                   end // else: !if( (bar[32] == 1'b0) | (bar[32] == 1'b1) )
              end // else: !if(addr_unused == 1'b1 )
            if ((bar[0]) == 1'b1)
              begin
                 bar_type_str = "IO Space        ";
              end
            else
            begin
               if ((bar[3]) == 1'b1)
               begin
                  bar_type_str = "Prefetchable    ";
               end
               else
               begin
                  bar_type_str = "Non-Prefetchable";
               end
            end
            dummy = ebfm_display(EBFM_MSG_INFO, {bar_num_str, " ", func_str, " ", bar_size_str,
            " ", addr_str, " ", bar_type_str});
         end //bar_enabled
         else
         begin
            dummy = ebfm_display(EBFM_MSG_INFO, {bar_num_str, " ", func_str, " ", bar_size_str});
         end

      end
   endtask
//===========================================================================
// purpose: Examine the DUT's BAR setup and pick a reasonable BAR to use
// Copy this task here because ebfm_cfg_decode_bar() looks for bar_value at
// bar_table + 32 offset. However, the valid bar value should be at bar_table
//===========================================================================
task find_mem_bar_sriov;
   input  integer   bar_table;
   input  reg [5:0] allowed_bars;
   input  integer   min_log2_size;
   input  integer   max_bar;
   output integer   sel_bar;

   integer cur_bar;
   reg[31:0] bar32;
   integer log2_size;
   reg is_mem;
   reg is_pref;
   reg is_64b;

   begin
      // find_mem_bar_sriov
      cur_bar = 0;
      begin : sel_bar_loop
         while (cur_bar < max_bar)
         begin
            ebfm_cfg_decode_bar_sriov (bar_table, cur_bar,
                                log2_size, is_mem, is_pref, is_64b);
            if ((is_mem == 1'b1) &
                (log2_size >= min_log2_size) &
                ((allowed_bars[cur_bar]) == 1'b1))
            begin
               sel_bar = cur_bar;
               disable sel_bar_loop ;
            end
            if (is_64b == 1'b1)
            begin
               cur_bar = cur_bar + 2;
            end
            else
            begin
               cur_bar = cur_bar + 1;
            end
         end
         sel_bar = 7 ; // Invalid BAR if we get this far...
      end
   end
endtask
   //========================================================================
   // purpose: returns whether specified BAR is memory or I/O and the size
   // Check if BAR is valid.
   // The different between this version and ebfm_cfg_decode_bar() is that the
   // base value is retrieved starting from bar_table rather than
   // (bar_table + 32)
   //========================================================================
   task ebfm_cfg_decode_bar_sriov;
      input   integer bar_table;   // Pointer to BAR info
      input   integer bar_num;     // bar number to check
      output  integer log2_size;  // Log base 2 of the Size
      output  is_mem;     // Is memory (not I/O)
      output  is_pref;    // Is prefetchable
      output  is_64b;     // Is 64bit

      reg[63:0] bar64;
      parameter[31:0] ZERO32 = {32{1'b0}};
      integer maxlsb;
      integer bar_entry;
      reg         unused_result ;

      begin
         //bar64 = shmem_read((bar_table + 32 + (bar_num * 4)), 8);
         bar64 = shmem_read((bar_table + (bar_num * 4)), 8);
         bar_entry = bar_table  + (bar_num * 4);
      
   //      unused_result = ebfm_display(EBFM_MSG_INFO, {"======> ebfm_cfg_decode_bar_sriov: bar_table = ",himage8(bar_table)," bar_no = ", himage8(bar_num),"-- shmem_read[", himage8(bar_entry),"] with rdata = ", himage8(bar64)});

         // Check if BAR is unassigned
         if (bar64[31:0] == ZERO32)
         begin
            log2_size = 0;
            is_mem = 1'b0;
            is_pref = 1'b0;
            is_64b = 1'b0;
         end
         else
         begin
            is_mem = ~bar64[0];
            is_pref = (~bar64[0]) & bar64[3];
            is_64b = (~bar64[0]) & bar64[2];
            if (((bar64[0]) == 1'b1) | ((bar64[2]) == 1'b0))
            begin
               maxlsb = 31;
            end
            else
            begin
               maxlsb = 63;
            end
            begin : xhdl_10
               integer i;
               for(i = 4; i <= maxlsb; i = i + 1)
               begin : check_loop
                  if ((bar64[i]) == 1'b1)
                  begin
                     log2_size = i;
                     disable xhdl_10 ;
                  end
               end
            end // i in 4 to maxlsb
         end
      end
   endtask

//====================================================== 
// Test LMI Read
//==================================
// LMI Control registers
// [31]   = Start LMI access
// [30]   = LMI_busy
// [29:25]= Reserved => 5 bits
// [24]   = LMI_src: 0 = HIP, 1 = SRIOV bridge
// [23:16]= target function number
// [15:13]= Reserved => 3 bits
// [12]   = lmi_cmd: 0  => read, 1 => Write
// [11:0] = lmi_addr
//==================================
//====================================================== 
task sriov_lmi_rd; 
   input  integer    bar_table;
   input  integer    setup_bar;    // 1 to display
   input  reg        sriov_config;        // 1 = SRIOV config space, 0 = HIP config-space
   input  reg [ 7:0] lmi_func;       
   input  reg [11:0] lmi_addr;       
   output reg [31:0] lmi_rdata;     

   reg [31:0] lmi_ctl;        // LMI control
   reg        lmi_cmd;        // 1= write; 0 = read 
   reg        lmi_start;      // 1= Start LMI,

   // variables
   reg         unused_result ;
   reg [31:0]  rdata;        // 32b General purpose write data
   integer     dw_byte_length;      // downstream memory wr/rd length in byte
  
   // Start test
   begin
      dw_byte_length = 4;

      unused_result = ebfm_display(EBFM_MSG_INFO, `STR_SEP);
      if (sriov_config == 1) begin
        unused_result = ebfm_display(EBFM_MSG_INFO, {"TASK:Start LMI Read to SRIOV config at addr = 0x", himage8(lmi_addr), " of func =0x", himage8(lmi_func)});
      end else begin
        unused_result = ebfm_display(EBFM_MSG_INFO, {"TASK:Start LMI Read to HIP config space at addr = 0x", himage8(lmi_addr), " of func =0x", himage8(lmi_func)});
        if (lmi_func != 0) begin
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {" =====> LMI access to HIP configspace only valid with lmi_func = 0. Current lmi_func", himage8(lmi_func)}); 
        end  
      end

      lmi_start = 1'b1;
      lmi_cmd   = 0; // for read
      lmi_ctl   = {lmi_start, 1'b0, 5'h0, sriov_config, lmi_func, 3'h0, lmi_cmd, lmi_addr};
      // Write to LMI_CTL_STATUS to start LMI read
      unused_result = ebfm_display(EBFM_MSG_INFO, {"=========>  Write to LMI_CTL_STATUS_ADDR at addr = 0x", himage8(LMI_CTL_STATUS_ADDR), " with wdata=0x", himage8(lmi_ctl)});
      ebfm_barwr_imm(   bar_table, setup_bar, LMI_CTL_STATUS_ADDR, lmi_ctl, dw_byte_length, 0 );         

      // Pooling on busy status of LMI_CTL_STATUS until busy goes low
      rdata = 0;
      unused_result = ebfm_display(EBFM_MSG_INFO, {"=========> Pooling on busy status of LMI_CTL_STATUS_ADDR at addr = 0x", himage8(LMI_CTL_STATUS_ADDR)});

      while (rdata[30] == 0) begin
        ebfm_barrd_wait(  bar_table, setup_bar, LMI_CTL_STATUS_ADDR, REG_SHARE_RD, dw_byte_length, 0 );        
        rdata = shmem_read(REG_SHARE_RD,dw_byte_length) ;
        unused_result = ebfm_display(EBFM_MSG_INFO, {"=========>  Read LMI_CTL_STATUS_ADDR at addr = 0x", himage8(LMI_CTL_STATUS_ADDR), "with rdata=", himage8(rdata)});
      end

      // Read LMI_rdata and return its read value
      ebfm_barrd_wait(  bar_table, setup_bar, LMI_RDATA_ADDR, REG_SHARE_RD, dw_byte_length, 0 );        
      lmi_rdata = shmem_read(REG_SHARE_RD,dw_byte_length) ;
      unused_result = ebfm_display(EBFM_MSG_INFO, {"=========>  Read LMI_RDATA_ADDR at addr = 0x", himage8(LMI_RDATA_ADDR), "with rdata=", himage8(rdata)});

   end // end test 
endtask

//====================================================== 
// Test LMI Write
//==================================
// LMI Control registers
// [31]   = Start LMI access
// [30]   = LMI_busy
// [29:25]= Reserved => 5 bits
// [24]   = LMI_src: 0 = HIP, 1 = SRIOV bridge
// [23:16]= target function number
// [15:13]= Reserved => 3 bits
// [12]   = lmi_cmd: 0  => read, 1 => Write
// [11:0] = lmi_addr
//==================================
//====================================================== 
task sriov_lmi_wr; 
   input  integer    bar_table;
   input  integer    setup_bar;    // 1 to display
   input  reg        sriov_config;        // 1 = SRIOV config space, 0 = HIP config-space
   input  reg [ 7:0] lmi_func;       
   input  reg [11:0] lmi_addr;       
   input reg [31:0]  lmi_wdata;     

   reg [31:0] lmi_ctl;        // LMI control
   reg        lmi_cmd;        // 1= write; 0 = read 
   reg        lmi_start;      // 1= Start LMI,

   // variables
   reg         unused_result ;
   reg [31:0]  rdata;        // 32b General purpose write data
   integer     dw_byte_length;      // downstream memory wr/rd length in byte
  
   // Start test
   begin
      dw_byte_length = 4;

      unused_result = ebfm_display(EBFM_MSG_INFO, `STR_SEP);
      if (sriov_config == 1) begin
        unused_result = ebfm_display(EBFM_MSG_INFO, {"TASK:Start LMI Write to SRIOV config at addr = 0x", himage8(lmi_addr), " of func =0x", himage8(lmi_func), " with wdata=", himage8(lmi_wdata)});
      end else begin
        unused_result = ebfm_display(EBFM_MSG_INFO, {"TASK:Start LMI Write to HIP config at addr = 0x", himage8(lmi_addr), " of func =0x", himage8(lmi_func), " with wdata=", himage8(lmi_wdata)});
        if (lmi_func != 0) begin
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {" =====> LMI access to HIP configspace only valid with lmi_func = 0. Current lmi_func", himage8(lmi_func)}); 
        end  
      end
      
      // Setup LMI_WDATA
      ebfm_barwr_imm(   bar_table, setup_bar, LMI_WDATA_ADDR, lmi_wdata, dw_byte_length, 0 );         
      unused_result = ebfm_display(EBFM_MSG_INFO, {"=========>  Write to LMI_WDATA_ADDR at addr = 0x", himage8(LMI_WDATA_ADDR), " with wdata=0x", himage8(lmi_wdata)});
     
      lmi_start = 1'b1;
      lmi_cmd   = 1; // for write
      lmi_ctl   = {lmi_start, 1'b0, 5'h0, sriov_config, lmi_func, 3'h0, lmi_cmd, lmi_addr};
      // Write to LMI_CTL_STATUS to start LMI read
      unused_result = ebfm_display(EBFM_MSG_INFO, {"=========>  Write to LMI_CTL_STATUS_ADDR at addr = 0x", himage8(LMI_CTL_STATUS_ADDR), " with wdata=0x", himage8(lmi_ctl)});
      ebfm_barwr_imm(   bar_table, setup_bar, LMI_CTL_STATUS_ADDR, lmi_ctl, dw_byte_length, 0 );         

      // Pooling on busy status of LMI_CTL_STATUS until busy goes low
      rdata = 0;
      unused_result = ebfm_display(EBFM_MSG_INFO, {"=========> Pooling on busy status of LMI_CTL_STATUS_ADDR at addr = 0x", himage8(LMI_CTL_STATUS_ADDR)});

      while (rdata[30] == 0) begin
        ebfm_barrd_wait(  bar_table, setup_bar, LMI_CTL_STATUS_ADDR, REG_SHARE_RD, dw_byte_length, 0 );        
        rdata = shmem_read(REG_SHARE_RD,dw_byte_length) ;
        unused_result = ebfm_display(EBFM_MSG_INFO, {"=========>  Read LMI_CTL_STATUS_ADDR at addr = 0x", himage8(LMI_CTL_STATUS_ADDR), "with rdata=", himage8(rdata)});
      end
   end // end test 
endtask

//====================================================== 
// Test LMI interface
//====================================================== 
task sriov_lmi_test; 
   input integer    bar_table;
   input integer    setup_bar;    // 1 to display
   input reg [7:0]  ep_bus;
   input reg [7:0]  ep_func;       
   input reg        sriov_config; // 1 = SRIOV config space, 0 = HIP config-space

   // variables
   reg         unused_result ;
   reg [31:0]  rdata, exp_data, lmi_rdata, wdata;        // 32b General purpose write data
   integer     dw_byte_length;      // downstream memory wr/rd length in byte
   reg [31:0]  config_address;      // Config_address
   reg [7:0]   pf_func;
   reg [ 2:0]  compl_status;

   begin
      dw_byte_length = 4;
     //======================
     // LMI test
     //======================
      unused_result = ebfm_display(EBFM_MSG_INFO, `STR_SEP);
      unused_result = ebfm_display(EBFM_MSG_INFO, {"TASK: sriov_lmi_test for func_no = ", himage8(ep_func), " with sriov_config =", himage2(sriov_config) });

     // Default value:
      sriov_config  = 1; //targeting SRIOV config space
      pf_func       = 8'h0; // PF0
     //======================================
     // 1. Read Device ID and Vendor ID
     //======================================
      config_address = {DEV_VENDOR_ID, 2'h0};
      sriov_lmi_rd(   bar_table, setup_bar, sriov_config,ep_func,config_address,rdata);
      unused_result = ebfm_display(EBFM_MSG_INFO, {"=========>  Read Device ID and Vendor ID at addr = ", himage8(config_address), " with rdata=0x", himage8(rdata)});
      
      if (ep_func == 0) begin // PF0
        exp_data       = 32'hE0011172;
      end else begin // VF 
        exp_data       = 32'hffffffff;
      end

      if (rdata != exp_data) begin
         unused_result = ebfm_display (EBFM_MSG_ERROR_FATAL, {"Error: Mismatched: Expected = ", himage8(exp_data), "  -----, ", "Actual = ", himage8(rdata)}); 
      end   
     //==================================================
     // 2. Write and Read MSI_LOWER_ADDR
     //==================================================
      config_address = MSI_LOWER_ADDR;
      wdata = 32'hcafebabc;
      sriov_lmi_wr( bar_table, setup_bar, sriov_config,ep_func,config_address,wdata);
      unused_result = ebfm_display(EBFM_MSG_INFO, {"------> LMI Write to MSI_LOWER_ADDR at addr = ", himage8(config_address), " with wdata = 0x", himage8(wdata)});
      exp_data = wdata;
      
      // Read back via Config interface
   //   ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
   //   rdata      = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
   //   if (rdata != exp_data) begin
   //     unused_result = ebfm_display (EBFM_MSG_ERROR_FATAL, {"Error: Config_Rd Mismatched: Expected = ", himage8(exp_data), "  -----, ", "Actual = ", himage8(rdata)}); 
   //   end else begin
   //     unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Config read MSI_LOWER_ADDR at addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});
   //   end

      // Read back via LMI interface
      sriov_lmi_rd(   bar_table, setup_bar, sriov_config,ep_func,config_address,lmi_rdata);
      if (lmi_rdata != exp_data) begin
        unused_result = ebfm_display (EBFM_MSG_ERROR_FATAL, {"Error: LMI_Rd MSI_LOWER_ADDR Mismatched: Expected = ", himage8(exp_data), "  -----, ", "Actual = ", himage8(lmi_rdata)}); 
      end begin
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> LMI read MSI_LOWER_ADDR at addr = ", himage8(config_address), " with rdata = 0x", himage8(lmi_rdata)});
      end
   end
endtask

/////////////////////////////////////////////////////////////////////////
//
// TASK: sriov_msi_poll
//   Polling process to track in shared memeory received MSI from EP
//
// input argument
//    max_number_of_msi  : Total Number of MSI to track
//    msi_address        : MSI Address in shared memeory
//    msi_expected_data  : Expected MSI data
task sriov_msi_poll(
   input integer max_number_of_msi,
   input integer msi_address,
   input integer msi_expected_data
   );

   reg unused_result ;
   integer msi_received;
   integer msi_count;
   reg pol_ip;

   begin
      unused_result = ebfm_display_verb(EBFM_MSG_INFO, `STR_SEP);
      unused_result = ebfm_display(EBFM_MSG_INFO, {"========> TASK: sriov_msi_poll at host msi_address = ", himage8(msi_address), " with expected data = 0x", himage8(msi_expected_data)});
      for (msi_count=0; msi_count < max_number_of_msi;msi_count=msi_count+1)
      begin
         pol_ip=0;
         fork
         // Set timeout failure if expected MSI is not received
         begin:timeout_msi
            repeat (100000) @(posedge clk_in);
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL,
                     "MSI timeout occured, MSI never received, Test Fails");
            disable wait_for_msi;
         end
         // Polling memory for expected MSI data value
         // at the assigned MSI address location
         begin:wait_for_msi
            forever
               begin
                  repeat (50) @(posedge clk_in);
                  msi_received = shmem_read (msi_address, 2);
                  if (pol_ip==0)
                     unused_result = ebfm_display(EBFM_MSG_INFO,{
                                       "   Polling MSI Address:",
                                       himage4(msi_address),
                                       "---> Data:",
                                       himage4(msi_received),
                                       "......"});

                  pol_ip=0;
                  if (msi_received == msi_expected_data)
                     begin
                        unused_result = ebfm_display(EBFM_MSG_INFO,
                                    {"    Received Expected MSI Data (",
                                   dimage4(msi_count),
                                   ") : ",
                                   himage4(msi_received)});
                      //  shmem_write( msi_address , 32'h1111_FADE, 4);
                        disable timeout_msi;
                        disable wait_for_msi;

                        if (DISPLAY_ALL==1)
                        unused_result = shmem_display(SCR_MEM+256,
                                             4*4,
                                             4,
                                             SCR_MEM+256+(4*4),
                                             EBFM_MSG_INFO);

                     end //if (msi_received)
               end // forever
         end //wait_for_msi
         join
      end
   end
endtask

//===========================================
// MSI Interrupt Test
//===========================================
//=================================
// Interrupt control and status
//
// [31]    = Start interrupt
// [30]    = Interrupt pending 
// [19:16] = legacy interrupt type: [16] = intA,[17]=intB,[18]=intC,[19]=INTD
// [13: 8] = msi_number => Must be <= msi_multiple_msg_cable
// [ 7: 0] = int_func => interrupt function number
//
//=================================

task sriov_msi_test;
   input  integer    bar_table;
   input  integer    setup_bar;    // 1 to display
   input  reg [7:0]  ep_bus;
   input  reg [ 7:0] ep_func;       
   input  reg [7:0]  pf_func;
   input  reg [11:0] msi_num;       

   // variables
   reg         unused_result ;
   reg [31:0]  rdata, exp_data, lmi_rdata, wdata;        // 32b General purpose write data
   integer     dw_byte_length;      // downstream memory wr/rd length in byte
   reg [31:0]  config_address;      // Config_address
   reg [ 2:0]  compl_status;

   reg         int_start;
   reg [3:0]   int_type;
   reg [31:0]  int_ctl;
   integer     msi_count;
   reg         msi_en;
   reg [2:0]   msi_multi_msg_en, msi_multi_msg_cap;
   
   localparam integer MSI_ADDRESS = SCR_MEM-16;

   begin // start MSI test
      unused_result = ebfm_display(EBFM_MSG_INFO,   {"======> Start MSI Test for current function = ", himage8(ep_func), " of PF = 0x", himage8(pf_func)});
      dw_byte_length = 4;

      unused_result = ebfm_display(EBFM_MSG_INFO,   {"======> Clear MSI_DATA = 0 at host MSI_ADDRESS = ", himage8(MSI_ADDRESS)});
      shmem_write( MSI_ADDRESS , 32'h0, 4);

   // 1. Set Int_Disable = 1
        config_address = {STATUS_COMMAND, 2'h0};
        ebfm_cfgrd_wait(  ep_bus, pf_func[7:3],  pf_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read STATUS_COMMAND at addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});

        wdata = {rdata[31:11], 1'b1, rdata[9:3], 3'h6};
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Set Int_Disable in STATUS_COMMAND at addr = ", himage8(config_address), " with wdata = 0x", himage8(wdata)});
        ebfm_cfgwr_imm_wait ( ep_bus, pf_func[7:3], pf_func[2:0], config_address, dw_byte_length, wdata, compl_status );   
   
        exp_data = wdata;
        ebfm_cfgrd_wait(  ep_bus, pf_func[7:3],  pf_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read STATUS_COMMAND at addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});

        if (rdata[10] != 1'b1) begin
          unused_result = ebfm_display (EBFM_MSG_ERROR_FATAL, {"Error: LMI_Rd STATUS_COMMAND Mismatched: Expected = ", himage8(exp_data[10]), "  -----, ", "Actual = ", himage8(rdata[10])}); 
        end

   //===========================
   // 2. Set MSI Address 
     config_address = MSI_LOWER_ADDR;
     wdata = MSI_ADDRESS;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Set MSI_LOWER_ADDR at addr = ", himage8(config_address), " with wdata = 0x", himage8(wdata)});
     ebfm_cfgwr_imm_wait ( ep_bus, ep_func[7:3], ep_func[2:0], config_address, dw_byte_length, wdata, compl_status );   

     // Must program MSI_UPPER_ADDR to avoid unknown driven on msi_64bit signal
     config_address = MSI_UPPER_ADDR;
     wdata = 32'h0;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Set MSI_UPPER_ADDRat addr = ", himage8(config_address), " with wdata = 0x", himage8(wdata)});
     ebfm_cfgwr_imm_wait ( ep_bus, ep_func[7:3], ep_func[2:0], config_address, dw_byte_length, wdata, compl_status );   

     // read back and check
     ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;

     if (rdata != wdata) begin
       unused_result = ebfm_display (EBFM_MSG_ERROR_FATAL, {"Error: MSI_LOWER_ADDR mismatched: Expected = ", himage8(wdata), "  -----, ", "Actual = ", himage8(rdata)}); 
     end

   //===========================
   // 3. Set MSI Data
     config_address = MSI_DATA;
     wdata = msi_num;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Set MSI_DATA at addr = ", himage8(config_address), " with wdata = 0x", himage8(wdata)});
     ebfm_cfgwr_imm_wait ( ep_bus, ep_func[7:3], ep_func[2:0], config_address, dw_byte_length, wdata, compl_status );   

     // read back and check
     ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;

     if (rdata != wdata) begin
       unused_result = ebfm_display (EBFM_MSG_ERROR_FATAL, {"Error: MSI_DATA mismatched: Expected = ", himage8(wdata), "  -----, ", "Actual = ", himage8(rdata)}); 
     end
   //===========================
   // 4. Set MSI_EN = 1
     config_address = MSI_BASE_ADDR;
     ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read MSI_BASE_ADDR at addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});
     msi_en = 1;
     msi_multi_msg_en      = 5;

     if (ep_func == 0) begin 
      msi_multi_msg_cap     = top_tb.top_inst.dut.msi_multi_message_capable_hwtcl;
     end else begin
      msi_multi_msg_cap     = top_tb.top_inst.dut.VF_MSI_MULTI_MSG_CAPABLE;
     end

     wdata = {rdata[31:23], msi_multi_msg_en, 3'h0, msi_en, rdata[15:0]};
     unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Set MSI_EN in MSI Control at addr = ", himage8(config_address), " with wdata = 0x", himage8(wdata)});
     ebfm_cfgwr_imm_wait ( ep_bus, ep_func[7:3], ep_func[2:0], config_address, dw_byte_length, wdata, compl_status );   

     exp_data = wdata;
     ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read MSI_BASE_ADDR at addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});

     if (rdata[22:20] != msi_multi_msg_en) begin
       unused_result = ebfm_display (EBFM_MSG_ERROR_FATAL, {"Error: msi_multi_msg_en at bit [22:20] is not set: Expected = ", himage8(msi_multi_msg_en), "  -----, ", "Actual = ", himage8(rdata[22:20])}); 
     end

     if (rdata[19:17] != msi_multi_msg_cap) begin
       unused_result = ebfm_display (EBFM_MSG_ERROR_FATAL, {"Error: msi_multi_msg_cap at bit[19:17]  is not set: Expected = ", himage8(msi_multi_msg_cap), "  -----, ", "Actual = ", himage8(rdata[19:17])}); 
     end

     if (rdata[16] != msi_en) begin
       unused_result = ebfm_display (EBFM_MSG_ERROR_FATAL, {"Error: MSI_BASE_ADDR => MSI_EN at bit 16 is not set: Expected = ", himage8(msi_en), "  -----, ", "Actual = ", himage8(rdata)}); 
     end
   //===========================
   // 4. Clear Interrupt Mask
   // By default all masks are all off (0)
   //===========================

   //===========================
   // 5. Write to INT_CTRL_STATUS to send MSI Interrupt
      int_start     = 1'b1;
      int_type[3:0] = 1'b0; // don't care because it is MSI interrupt
      int_ctl   = {int_start, 1'b0, 10'h0, int_type[3:0], 3'h0, msi_num[4:0], ep_func[7:0]};
      unused_result = ebfm_display(EBFM_MSG_INFO, {"=========> Start MSI Interrupt by setting INT_CTL_STATUS_ADDR at addr = 0x", himage8(INT_CTL_STATUS_ADDR), " with wdata = ", himage8(int_ctl) });
      ebfm_barwr_imm(   bar_table, setup_bar, INT_CTL_STATUS_ADDR, int_ctl, dw_byte_length, 0 );         

   // 6. Wait for Int_pending status to go low
      rdata = 0;
      unused_result = ebfm_display(EBFM_MSG_INFO, {"=========> Pooling on Int_Pending status of INT_CTL_STATUS_ADDR at addr = 0x", himage8(INT_CTL_STATUS_ADDR)});

      while (rdata[30] == 1) begin
        ebfm_barrd_wait(  bar_table, setup_bar, INT_CTL_STATUS_ADDR, REG_SHARE_RD, dw_byte_length, 0 );        
        rdata = shmem_read(REG_SHARE_RD,dw_byte_length) ;
        unused_result = ebfm_display(EBFM_MSG_INFO, {"=========>  Read INT_CTL_STATUS_ADDR at addr = 0x", himage8(INT_CTL_STATUS_ADDR), "with rdata=", himage8(rdata)});
      end

   // 7. Pooling for MSI interrupt data at MSI address
      msi_count = 1;
      sriov_msi_poll( msi_count, MSI_ADDRESS, msi_num);

      unused_result = ebfm_display_verb(EBFM_MSG_INFO, `STR_SEP);
      unused_result = ebfm_display_verb(EBFM_MSG_INFO, "Completed MSI Interrupt test");

   end // end test 

endtask

//===========================================
// MSI Interrupt Test
//===========================================
//=================================
// Interrupt control and status
//
// [31]    = Start interrupt
// [30]    = Interrupt pending 
// [19:16] = legacy interrupt type: [16] = intA,[17]=intB,[18]=intC,[19]=INTD
// [13: 8] = msi_number => Must be <= msi_multiple_msg_cable
// [ 7: 0] = int_func => interrupt function number
//
//=================================

task sriov_legacy_int_test;
   input  integer    bar_table;
   input  integer    setup_bar;    // 1 to display
   input  reg [7:0]  ep_bus;
   input  reg [ 7:0] ep_func;       
   input  reg [7:0]  pf_func;
   input  reg [3:0]  int_type;   //[0] = INTA, [1]=INTB, [2]=INTC, [3]=INTD

   // variables
   reg         unused_result ;
   reg [31:0]  rdata, exp_data, lmi_rdata, wdata;        // 32b General purpose write data
   integer     dw_byte_length;      // downstream memory wr/rd length in byte
   reg [31:0]  config_address;      // Config_address
   reg [ 2:0]  compl_status;

   reg         int_start, int_clear;
   reg [31:0]  int_ctl;
   integer     msi_count;
   
   localparam integer MSI_ADDRESS = SCR_MEM-16;

   begin 
      dw_byte_length = 4;
      unused_result = ebfm_display(EBFM_MSG_INFO,   {"======> Start Legacy Interrupt test for current function = ", himage8(ep_func), " of PF = 0x", himage8(pf_func)});

   // 1. Set Int_Disable = 0
        config_address = {STATUS_COMMAND, 2'h0};
        ebfm_cfgrd_wait(  ep_bus, pf_func[7:3],  pf_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read STATUS_COMMAND at addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});

        wdata = {rdata[31:11], 1'b0, rdata[9:0]};
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Clear Int_Disable in STATUS_COMMAND at addr = ", himage8(config_address), " with wdata = 0x", himage8(wdata)});
        ebfm_cfgwr_imm_wait ( ep_bus, pf_func[7:3], pf_func[2:0], config_address, dw_byte_length, wdata, compl_status );   
   
        exp_data = wdata;
        ebfm_cfgrd_wait(  ep_bus, pf_func[7:3],  pf_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
        rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
        unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read STATUS_COMMAND at addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});
        if (rdata[10] != 1'b0) begin
          unused_result = ebfm_display (EBFM_MSG_ERROR_FATAL, {"Error: STATUS_COMMAND Mismatched: Expected = ", himage8(exp_data[10]), "  -----, ", "Actual = ", himage8(rdata[10])}); 
        end

   //===========================
   // 2. Clear MSI_EN = 1
     config_address = MSI_BASE_ADDR;
     ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read MSI_BASE_ADDR at addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});

     wdata = {rdata[31:17], 1'b0, rdata[15:0]};
     unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Clear MSI_EN in MSI Control at addr = ", himage8(config_address), " with wdata = 0x", himage8(wdata)});
     ebfm_cfgwr_imm_wait ( ep_bus, ep_func[7:3], ep_func[2:0], config_address, dw_byte_length, wdata, compl_status );   

     exp_data = wdata;
     ebfm_cfgrd_wait(  ep_bus, ep_func[7:3],  ep_func[2:0], config_address, dw_byte_length, CFG_SHARE_RD, compl_status);    
     rdata = shmem_read(CFG_SHARE_RD, dw_byte_length) ;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"------> Read MSI_BASE_ADDR at addr = ", himage8(config_address), " with rdata = 0x", himage8(rdata)});

     if (rdata[16] == 1'b1) begin
       unused_result = ebfm_display (EBFM_MSG_ERROR_FATAL, {"Error: MSI_BASE_ADDR => MSI_EN at bit 16 is not set: Expected = ", himage8(exp_data), "  -----, ", "Actual = ", himage8(rdata)}); 
     end

   //===========================
   // 3. Write to INT_CTRL_STATUS to send Legacy Interrupt
     int_start     = 1'b1;
     int_ctl   = {int_start, 1'b0, 10'h0, int_type[3:0], 3'h0, 5'h0, ep_func[7:0]};
      ebfm_barwr_imm(   bar_table, setup_bar, INT_CTL_STATUS_ADDR, int_ctl, dw_byte_length, 0 );         

   // 4. Pooling for Legacy interrupt pin
      unused_result = ebfm_display_verb(EBFM_MSG_INFO, "Wait INT_PIN asserted");
      #10
      if      (int_type == MBOX_INTA) 
        wait(INTA);
      else if (int_type == MBOX_INTB)
        wait(INTB);
      else if (int_type == MBOX_INTC)
        wait(INTC);
      else   
        wait(INTD);

   // 5. Clear Legacy Interrupt
      unused_result = ebfm_display_verb(EBFM_MSG_INFO, "Clear legacy INT to send deassert interrupt");
     int_start     = 1'b0;
     int_clear       = 1'b1;
     int_ctl   = {int_start, 1'b0, int_clear, 9'h0, int_type[3:0], 3'h0, 5'h0, ep_func[7:0]};
      ebfm_barwr_imm(   bar_table, setup_bar, INT_CTL_STATUS_ADDR, int_ctl, dw_byte_length, 0 );         

   // 6. Check that Int_pending status goes low
      rdata = 0;
      unused_result = ebfm_display(EBFM_MSG_INFO, {"=========> Check for Int_Pending to go low => bit[30] of INT_CTL_STATUS_ADDR at addr = 0x", himage8(INT_CTL_STATUS_ADDR)});

      while (rdata[30] == 1) begin
        ebfm_barrd_wait(  bar_table, setup_bar, INT_CTL_STATUS_ADDR, REG_SHARE_RD, dw_byte_length, 0 );        
        rdata = shmem_read(REG_SHARE_RD,dw_byte_length) ;
        unused_result = ebfm_display(EBFM_MSG_INFO, {"=========>  Read INT_CTL_STATUS_ADDR at addr = 0x", himage8(INT_CTL_STATUS_ADDR), "with rdata=", himage8(rdata)});
      end

   // 7. Wait for Int_pin to be deasserted 
      #10
      if      (int_type == MBOX_INTA) 
        wait(!INTA);
      else if (int_type == MBOX_INTB)
        wait(!INTB);
      else if (int_type == MBOX_INTC)
        wait(!INTC);
      else   
        wait(!INTD);

      unused_result = ebfm_display_verb(EBFM_MSG_INFO, `STR_SEP);
      unused_result = ebfm_display_verb(EBFM_MSG_INFO, "Completed Legacy Interrupt test");
   end // end test 

endtask

//======================================
// SR-IOV test
//======================================
task sriov_test; 
   input integer  ep_bus;
   input integer  bar_table;
   input integer  display_rp_config;    // 1 to display
   input integer  display_ep_config;    // 1 to display
   input reg      addr_map_4GB_limit;
   output reg     activity_toggle;
   
      integer     slave_bar;
      reg [7:0]   ep_func;
      reg [7:0]   min_vf_func;
      reg [7:0]   max_vf_func;
      //integer     ep_dev;
      reg         unused_result ;
      reg[31:0]   io_min;
      reg[31:0]   io_max;
      reg[63:0]   m32min;
      reg[63:0]   m32max;
      reg[63:0]   m64min;
      reg[63:0]   m64max;

      // VF Bar table pointer
      reg[63:0]   vf_table [TOTAL_VF-1 : 0];
      reg[15:0]   num_vfs, vf_offset, vf_stride;
      integer     i, j;
      reg         bar_ok;
      reg [31:0]  sys_pg_size; // in byte address

      reg [136:0] vf_bar0;
      reg [136:0] vf_bar1;
      reg [136:0] vf_bar2;
      reg [136:0] vf_bar3;
      reg [136:0] vf_bar4;
      reg [136:0] vf_bar5;
      reg [136:0] cur_bar;
      reg [  2:0] bar_no;
      reg [63:0]  bar_value;
      reg [  8:0] bsize_pos;
      reg [63:0]  bsize;
      reg         dw_test; 
      reg [31:0]  wdata;
      reg [ 7:0]  bar64;
      reg [ 6:0]  sel_bar;

      reg [31:0]  config_address;      // Config_address
      reg [31:0]  rdata, exp_data;        // 32b General purpose write data
      reg [ 2:0]  compl_status;
      reg [7:0]   cur_pf;
      reg         sriov_config; // 1 = SRIOV config space, 0 = HIP config-space
      reg [11:0]  msi_num;       
      reg [7:0]   pf_func;
      reg [3:0]   int_type;
      reg [31:0]  wdata_list [31:0];

   begin

      io_min = EBFM_BAR_IO_MIN ;
      io_max = EBFM_BAR_IO_MAX ;
      m32min = {32'h00000000,EBFM_BAR_M32_MIN};
      m32max = {32'h00000000,EBFM_BAR_M32_MAX};
      m64min = EBFM_BAR_M64_MIN;
      m64max = EBFM_BAR_M64_MAX;

      //================== Start Config Bypass test ====================================      
            unused_result = ebfm_display(EBFM_MSG_INFO, {"Starting SR-IOV test"});
            unused_result = ebfm_display(EBFM_MSG_INFO,
                  "----> Starting ebfm_cfg_rp task 0");
            ebfm_cfg_rp_to_linkup(
                     ep_bus,            // Max EP Bus Number hanging off from RP
                     512,               // RP Maximum Read Request Size 
                     display_rp_config, // Display RP Config Space after setup
                     activity_toggle
                     );


            //====================================================
            // Check that accessing to PF[4-7] should return UR
            //====================================================
            config_address = {DEV_VENDOR_ID, 2'h0};
            exp_data       = 32'h0;
            ep_func        = 4;
           
            if (TEST_VF_ACCESS_W_VF_DISABLE) begin
              for (cur_pf = ep_func; cur_pf  < 8; cur_pf= cur_pf+1) begin 
                unused_result = ebfm_display(EBFM_MSG_INFO, {" TEST_VF_ACCESS_W_VF_DISABLE: Config Read to Dev_VENDOR_ID of PF =", himage8(ep_func)});
                ebfm_cfgrd_wait(    
                           ep_bus,           // EP Bus number
                           cur_pf[7:3],           // EP Dev number 
                           cur_pf[2:0],          // EP Func number
                           config_address,   // Config register address in byte 
                           4,   // Byte length 
                           CFG_SHARE_RD,     // Config Scratch Space where Config RD data is stored 
                           compl_status);     // Completion Status
              
                if (compl_status != 1) begin // Expect UR = 1, 
                  unused_result = ebfm_display (EBFM_MSG_ERROR_FATAL, {"Error: Expected UR status, but compl_status", himage8(compl_status)}); 
                end

                rdata = shmem_read(CFG_SHARE_RD, 4) ;
                if (rdata != exp_data) begin
                  unused_result = ebfm_display (EBFM_MSG_ERROR_FATAL, {"Error: Mismatched: Expected = ", himage8(exp_data), "  -----, ", "Actual = ", himage8(rdata)}); 
                end else begin
                  unused_result = ebfm_display (EBFM_MSG_INFO, {"CfgRD at addr =0x", himage8(config_address), " returns data = 0x", himage8(rdata)});
                end
              end //for
           end // TEST_VF_ACCESS_W_VF_DISABLE
            //======================
            // Enumerate PF function0
            //======================
            ep_func        = 0;
            unused_result = ebfm_display(EBFM_MSG_INFO, {"Enumerate EP PF function = 0x", himage2(ep_func)});
            enum_ep_BARs  ( 
                     ep_bus,   // busno
                     ep_func[7:3],   // ep func[7:3] for SR-IOV and dev_non for non-sriov
                     ep_func[2:0],  // ep func[2:0] 
                     bar_table,
                     display_ep_config,        // display_ep_config
                     0,         // addr_map_4GB_limit
                     io_min,
                     io_max,
                     m32min,
                     m32max,
                     m64min,
                     m64max
                              );

            
            check_ari_cap (
                     ep_bus   // busno
            );

            enum_sriov_cap (
                     ep_bus,   // busno
                     num_vfs,
                     vf_offset, // N/A
                     vf_stride,  // N/A
                     sys_pg_size,
                     0           // 1: check_all, 0 = partial setup
            );          

            // Define VF BAR Table pointer 
            unused_result = ebfm_display (EBFM_MSG_INFO , {"BAR_TABLE_POINTER = ", himage8(BAR_TABLE_POINTER)}); 

            for ( i=0; i < num_vfs; i= i + 1 ) begin
              vf_table[i] = BAR_TABLE_POINTER - BAR_TABLE_SIZE * (i + 1);
              unused_result = ebfm_display (EBFM_MSG_INFO , {"vf_table[", himage8(i),"]  = ", himage8(vf_table[i])}); 
            end  

            //==============================================================
            // Setup VF BAR0 in SR-IOV CAP and save the size and offset in
            // appropriate VF_BARs 
            //==============================================================
            ep_func = 0; // PF0 function number
            ebfm_cfg_sriov_bars (
                     ep_bus,   // busno
                     ep_func[7:3],   // ep func[7:3] for SR-IOV and dev_non for non-sriov
                     ep_func[2:0],  // ep func[2:0] 
                     vf_table[0],
                     sys_pg_size, 
                     num_vfs,
                     MAX_BAR,
                     m32min,
                     m32max,
                     m64min,
                     m64max,
                     vf_bar0,
                     vf_bar1,
                     vf_bar2,
                     vf_bar3,
                     vf_bar4,
                     vf_bar5,
                     addr_map_4GB_limit,
                     0, //display_ep_config,      
                     bar_ok
            );
            
            //======================================
            // Assign BAR value into each VF_Table
            //======================================
          if (display_ep_config == 1) begin
              unused_result = ebfm_display(EBFM_MSG_INFO, "");
              unused_result = ebfm_display(EBFM_MSG_INFO, "BAR Address Assignments:");
              unused_result = ebfm_display(EBFM_MSG_INFO, {"BAR   ","Func      ", " ", "Size      ", " ", "Assigned Address ", " ", "Type"});
              unused_result = ebfm_display(EBFM_MSG_INFO, {"---   ","----      ", " ", "----      ", " ", "---------------- ", " "});
           end

            bar_no = 0;
            bar64= 0;

            while ( bar_no < MAX_BAR) begin
              if      (bar_no == 0) cur_bar = vf_bar0;
              else if (bar_no == 1) cur_bar = vf_bar1;
              else if (bar_no == 2) cur_bar = vf_bar2;
              else if (bar_no == 3) cur_bar = vf_bar3;
              else if (bar_no == 4) cur_bar = vf_bar4;
              else if (bar_no == 5) cur_bar = vf_bar5;
              else begin
                unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Invalid VF_BAR bar_no =", himage8(bar_no)}); 
              end  

                bsize     = cur_bar[ 63: 0];
                bsize_pos = cur_bar[136:128];
                bar_value = cur_bar[127:64];
              
              for (j = 0; j < num_vfs; j = j + 1) begin
                describe_sriov_bar (1, j, bar_no, bsize_pos, bar_value, 0);

                if (j> 0) begin
                  assign_vf_bar ( vf_table[j], 
                              bar_no,
                              bar_value,
                              bsize_pos,
                              0, //display_ep_config,      
                              bar_ok
                              );
                end

                bar_value =  bar_value + bsize;
              end // end for

              if (bar_value[2] != 1'b1) begin // 32bit BAR 
                 bar64[bar_no] = 0;
                 bar_no = bar_no + 1;
              end else begin //64bit BAR
                 bar64[bar_no] = 1;
                 bar_no = bar_no + 2;
              end
            end //end while

            //====================================
            // Setup VF_EN and MSE in SR-IOV cap
            //====================================
            enable_vf_mse (
                     ep_bus,   // busno
                     ep_func  // ep func[7:0] for SR-IOV and dev_non for non-sriov
            );

            //======================
            // Run config test
            //======================
          if (TEST_PF_CONFIG) begin 
              config_test (
                  ep_bus,
                  ep_func[7:3],
                  ep_func[2:0],
                  bar_table,
                  display_ep_config    // 1 to display
              );
          end // TEST_PF_CONFIG 

          if (TEST_VF_CONFIG) begin 
              min_vf_func = 32; // VF0 function number with stride = 32
              max_vf_func = (MAX_VF + 32) - 1; // Last VF function number

              for (ep_func = min_vf_func; ep_func <= max_vf_func; ep_func = ep_func + 1) begin 
                vf_cfg_test (
                  ep_bus, // PF busno
                  8'h0,   // PF0 function     
                  ep_bus, // VF busno
                  ep_func[7:0],
                  bar_table,
                  1,                   //sriov_ph1
                  display_ep_config    // 1 to display
                );
              end //for ep_func  
           end // TEST_VF_CONFIG


         //====================================
         // Run downstream test on PF0
         //====================================
          if (TEST_PF_MEM) begin
              unused_result = ebfm_display (EBFM_MSG_INFO , {"=====> Test PF0 downstream memory traffic "}); 
              find_mem_bar (bar_table, 6'b000001, 8, slave_bar);

              if (slave_bar < 7) begin
                my_test (
                  USE_CONFIG_BYPASS_HWTCL,
                  bar_table,               // Pointer to the BAR table
                  slave_bar                // current BAR 
                );       
              end  
          end // TEST_PF_MEM
        //==============================
        // Run downstream test on VF0
        //==============================
          if (TEST_VF_MEM) begin
              unused_result = ebfm_display (EBFM_MSG_INFO , {"=====> Test active VFs downstream memory traffic "}); 
            min_vf_func = 32; // VF0 function number with stride = 32
            max_vf_func = (MAX_VF + 32); // Last VF function number
            wdata       = 32'hbabeface;

            dw_test = 1;
            bar_no = 0;
            while ( bar_no < MAX_BAR) begin
              if      (bar_no == 0) sel_bar = 6'b000001;
              else if (bar_no == 1) sel_bar = 6'b000010;
              else if (bar_no == 2) sel_bar = 6'b000100;
              else if (bar_no == 3) sel_bar = 6'b001000;
              else if (bar_no == 4) sel_bar = 6'b010000;
              else if (bar_no == 5) sel_bar = 6'b100000;
              else begin
                unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Invalid bar_no =", himage8(bar_no)}); 
              end  

              if (display_ep_config == 1) begin
                unused_result = ebfm_display (EBFM_MSG_INFO , {">>>>>>>=====================================================================>>>>>>"}); 
                unused_result = ebfm_display (EBFM_MSG_INFO , {"=====> Start testing BAR  [", himage1(bar_no),"] with sel_bar = ", himage2(sel_bar)}); 
                unused_result = ebfm_display (EBFM_MSG_INFO , {">>>>>>>=====================================================================>>>>>>"}); 
              end
             
              //=====================================
              // test downstream write-read sequence
              //=====================================
              for (ep_func = min_vf_func; ep_func < max_vf_func; ep_func = ep_func + 1) begin 
                find_mem_bar_sriov(vf_table[ep_func-min_vf_func], sel_bar, 8, MAX_BAR, slave_bar);
                if (slave_bar < 7) begin
                    cfbp_target_test (
                        ep_bus,         // busno
                        ep_func[7:3],   // ep func[7:3] for SR-IOV and dev_non for non-sriov
                        ep_func[2:0],   // ep func[2:0] 
                        vf_table[ep_func-min_vf_func],
                        slave_bar ,      // current BAR 
                        wdata, 
                        dw_test          // 1 = dword test only
                  );
                end else begin
                    unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Invalid VF_BAR bar_no =0"}); 
                end
                wdata = wdata + 1;
              end // ep_func

              //=====================================
              // test downstream write sequence
              //=====================================
              i = 0;
              wdata       = 32'hcafeba00;
              for (ep_func = min_vf_func; ep_func < max_vf_func; ep_func = ep_func + 1) begin 
                wdata_list[i] = wdata;
                find_mem_bar_sriov(vf_table[ep_func-min_vf_func], sel_bar, 8, MAX_BAR, slave_bar);
                if (slave_bar < 7) begin
                    ebfm_barwr_imm( vf_table[ep_func-min_vf_func], slave_bar,REG0_ADDR, wdata, 4, 0 );     
                end else begin
                    unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Invalid VF_BAR bar_no =0"}); 
                end
                wdata = wdata + 1;
                i     = i + 1;
              end // ep_func

              //=====================================
              // test downstream read sequence
              //=====================================
              i = 0;
              for (ep_func = min_vf_func; ep_func < max_vf_func; ep_func = ep_func + 1) begin 
                find_mem_bar_sriov(vf_table[ep_func-min_vf_func], sel_bar, 8, MAX_BAR, slave_bar);
                if (slave_bar < 7) begin
                    ebfm_barrd_wait(vf_table[ep_func-min_vf_func], slave_bar, REG0_ADDR, REG_SHARE_RD, 4, 0);
                    rdata = shmem_read(REG_SHARE_RD,4) ;

                    if (rdata != wdata_list[i]) 
                      unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"Mismatched VF[",himage4(ep_func) , "] data: Expected = 0x", himage8(wdata_list[i]), " -- Actual = 0x", himage8(rdata)}); 
                    else 
                      unused_result = ebfm_display(EBFM_MSG_INFO, {"Read VF[",himage4(ep_func) , "] with data: Expected = 0x", himage8(rdata)}); 

                end else begin
                    unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"ERROR : Invalid VF_BAR bar_no =0"}); 
                end
                wdata = wdata + 1;
                i     = i + 1;
              end // ep_func
              //=====================================
              // Move to next valid BAR
              //=====================================
              if (bar64[bar_no] == 1'b0) begin // 32bit BAR 
                 bar_no = bar_no + 1;
              end else begin //64bit BAR
                 bar_no = bar_no + 2;
              end
            end //end while
          end // TEST_VF_MEM

         //====================================
         // Test LMI interface
         //====================================
          if (TEST_LMI) begin
            unused_result = ebfm_display (EBFM_MSG_INFO , {"=====>  Test LMI Interface "}); 
            ep_func       = 0; // PF0
            slave_bar     = 0;
            sriov_config  = 1; // 1 = SRIOV config space, 0 = HIP config-space

            // test LMI to PF0
              sriov_lmi_test (
                bar_table,
                slave_bar,
                ep_bus,
                ep_func,       
                sriov_config // 1 = SRIOV config space, 0 = HIP config-space
              );  

            // test LMI to VF
            min_vf_func = 32; // VF0 function number with stride = 32
            max_vf_func = (MAX_VF + 32) - 1; // Last VF function number
            for (ep_func = min_vf_func; ep_func <= max_vf_func; ep_func = ep_func + 1) begin 
              sriov_lmi_test (
                bar_table,
                slave_bar,
                ep_bus,
                ep_func,       
                sriov_config // 1 = SRIOV config space, 0 = HIP config-space
              );  
            end // for ep_func
          end // TEST_LMI

         //====================================
         // Test MSI interface
         //====================================
         if (TEST_MSI) begin
              unused_result = ebfm_display (EBFM_MSG_INFO , {"=====>  Test MSI Interrupt"}); 
              pf_func       = 0;
              ep_func       = 0; // PF0
              msi_num       = 12'h567;
              slave_bar     = 0;

              sriov_msi_test (
                bar_table,
                slave_bar,
                ep_bus,
                ep_func,       
                pf_func,       
                msi_num
              );  

            // test MSI for all VF
            min_vf_func = 32; // VF0 function number with stride = 32
            max_vf_func = (MAX_VF + 32) - 1; // Last VF function number
            for (ep_func = min_vf_func; ep_func <= max_vf_func; ep_func = ep_func + 1) begin 
              sriov_msi_test (
                bar_table,
                slave_bar,
                ep_bus,
                ep_func,       
                pf_func,       
                msi_num
              );  
            end // for ep_func
         end

         //====================================
         // Test MSI interface
         //====================================
         if (TEST_LEGACY_INT) begin
              unused_result = ebfm_display (EBFM_MSG_INFO , {"=====>  Test Legacy Interrupt for PF0"}); 
              pf_func       = 0;
              ep_func       = 0; // PF0
              msi_num       = 12'h567;
              slave_bar     = 0;
              int_type      = MBOX_INTA;

              sriov_legacy_int_test(
                bar_table,
                slave_bar,
                ep_bus,
                ep_func,       
                pf_func,       
                int_type
              );  

         end // end test_legacy_int

          unused_result = ebfm_display(EBFM_MSG_INFO, {"Ending SR-IOV test"});

      //================== END of SR-IOV test ====================================      
   end
endtask
