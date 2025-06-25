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


   localparam CFG_SHARE_RD          = SCR_MEM_DOWNSTREAM_RD; 

   // Config dw addresses
   localparam DEV_VENDOR_ID        = 9'h0;
   localparam STATUS_COMMAND       = 9'h1;
   localparam BIST_HDR_TYPE        = 9'h3;
   localparam BAR0_REG             = 9'h4;
   localparam BAR1_REG             = 9'h5;
   localparam SUBSYS_ID_VENDOR_ID  = 9'h11;

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
   // root port and the endpoint on the link
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
             wait (top_tb.top_inst.dut.altpcie_hip_256_pipen1b.ltssmstate == 5'hf);

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

         wait (top_tb.top_inst.dut.altpcie_hip_256_pipen1b.ltssmstate == 5'hf);

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
         wait (top_tb.top_inst.dut.altpcie_hip_256_pipen1b.ltssmstate == 5'hf);
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

      max_len           = 100; // in byte
      min_len           = 2;
      inc_len           = 10;
      dw_byte_length    = 4; 
      wdata             = 32'hbabeface;

     //=========================
     // 1. 32bit Register access
     //=========================
     // Even address
      unused_result = ebfm_display(EBFM_MSG_INFO, `STR_SEP);
      unused_result = ebfm_display(EBFM_MSG_INFO, {"TASK:my_test => 1.11 Write to 32bit register at addr = 0x", himage8(REG0_ADDR), " with wdata=0x", himage8(wdata)});
      ebfm_barwr_imm(   bar_table,      // BAR table in the host memory
                        setup_bar,      // Current BAR that contains the register 
                        REG0_ADDR,       // Register address offset from the current setup_bar
                        wdata,          // Write data value
                        dw_byte_length, // byte_len => 4B = 32bits
                        0);             // Traffic Class => always zero for this bench


      unused_result = ebfm_display(EBFM_MSG_INFO, {"TASK:my_test => 1.12 Read from 32bit register at addr = 0x", himage8(REG0_ADDR)});
      ebfm_barrd_wait(  bar_table,      // BAR table in the host memory
                        setup_bar,      // Current BAR that contains the register 
                        REG0_ADDR,       // Register address offset from the current setup_bar
                        REG_SHARE_RD,   // Share memory where read_data is stored
                        dw_byte_length, // byte_len => 4B = 32bits
                        0); 

      rdata = shmem_read(REG_SHARE_RD,dw_byte_length) ;

      if (rdata != wdata) 
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"TASK:my_test => 1.13  Mismatched reg data: Expected = 0x", himage8(wdata), " -- Actual = 0x", himage8(rdata)}); 
      else 
          unused_result = ebfm_display(EBFM_MSG_INFO, "TASK:my_test => 1.13  Register compare matches!");
      
      
     // odd address
      wdata             = 32'h12345678;
      unused_result = ebfm_display(EBFM_MSG_INFO, `STR_SEP);
      unused_result = ebfm_display(EBFM_MSG_INFO, {"TASK:my_test => 1.21 Write to 32bit register at addr = 0x", himage8(REG1_ADDR), " -- Actual = 0x", himage8(wdata)});
      ebfm_barwr_imm(   bar_table,      // BAR table in the host memory
                        setup_bar,      // Current BAR that contains the register 
                        REG1_ADDR,       // Register address offset from the current setup_bar
                        wdata,          // Write data value
                        dw_byte_length, // byte_len => 4B = 32bits
                        0);             // Traffic Class => always zero for this bench


      unused_result = ebfm_display(EBFM_MSG_INFO, {"TASK:my_test => 1.22 Read from 32bit register at addr = 0x", himage8(REG1_ADDR)});
      ebfm_barrd_wait(  bar_table,      // BAR table in the host memory
                        setup_bar,      // Current BAR that contains the register 
                        REG1_ADDR,       // Register address offset from the current setup_bar
                        REG_SHARE_RD,   // Share memory where read_data is stored
                        dw_byte_length, // byte_len => 4B = 32bits
                        0); 

      rdata = shmem_read(REG_SHARE_RD,dw_byte_length) ;

      if (rdata != wdata) 
          unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"TASK:my_test => 1.23  Mismatched reg data: Expected = 0x", himage8(wdata), " -- Actual = 0x", himage8(rdata)}); 
      else 
          unused_result = ebfm_display(EBFM_MSG_INFO, "TASK:my_test => 1.23  Register compare matches!");
     //=========================
     // 2. Memory burst access
     //=========================
     // Burst with Even address
         unused_result = ebfm_display(EBFM_MSG_INFO, `STR_SEP);
         unused_result = ebfm_display(EBFM_MSG_INFO, "TASK:my_test => 2.11 Fill write memory with QWORD_INC pattern");

         mem_addr          = MEM0_ADDR;
         burst_byte_length = min_len;  
         wdata             = 32'h10203040;   // Start write data pattern
         
         while (burst_byte_length < max_len) begin
            shmem_fill(MEM_SHARE_WR, SHMEM_FILL_QWORD_INC, burst_byte_length, wdata);

            unused_result = ebfm_display(EBFM_MSG_INFO, {"TASK:my_test => 2.12 Memory write burst at addr=0x", himage2(mem_addr), " with wdata=0x", himage8(wdata)});
            ebfm_barwr( bar_table,        // BAR table in the host memory
                        setup_bar,        // Current BAR that contains the register 
                        mem_addr,         // Start memory address => offset from setup_bar
                        MEM_SHARE_WR,     // Start host shared memory address where write data are stored
                        burst_byte_length,// Burst length in byte 
                        0);               // Traffic Class (always 0)

            unused_result = ebfm_display(EBFM_MSG_INFO, "TASK:my_test => 2.21 Memory Read burst");
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
               unused_result = ebfm_display(EBFM_MSG_INFO, "TASK:my_test => 2.3 Check for memory read/write data");
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
            unused_result = ebfm_display(EBFM_MSG_INFO, "TASK:my_test => 2.11 Fill write memory with QWORD_INC pattern");
            wdata             = 32'h50607080;   // Start write data pattern
            shmem_fill(MEM_SHARE_WR, SHMEM_FILL_QWORD_INC, burst_byte_length, wdata);

            unused_result = ebfm_display(EBFM_MSG_INFO, {"TASK:my_test => 2.12 Memory write burst at addr=0x", himage2(mem_addr), " with wdata=0x", himage8(wdata)});
            ebfm_barwr(    bar_table,        // BAR table in the host memory
                        setup_bar,        // Current BAR that contains the register 
                        mem_addr,        // Start memory address => offset from setup_bar
                        MEM_SHARE_WR,     // Start host shared memory address where write data are stored
                        burst_byte_length,// Burst length in byte 
                        0);               // Traffic Class (always 0)

            unused_result = ebfm_display(EBFM_MSG_INFO, "TASK:my_test => 2.21 Memory Read burst");
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
               unused_result = ebfm_display(EBFM_MSG_INFO, "TASK:my_test => 2.3 Check for memory read/write data");
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
   input [31:0]   cfg_wdata
   );  

   // Local parameters
   reg         unused_result ;
   reg [31:0]  rdata;        // 32b General purpose write data
   reg [ 2:0]  compl_status;
   integer     dw_byte_length;      // downstream memory wr/rd length in byte

   begin
     
     dw_byte_length = 4;
     unused_result = ebfm_display(EBFM_MSG_INFO, {"Read Modified WRite to config register = 0x", himage8(cfg_addr), " in func = 0x", himage8(ep_func)});

     unused_result = ebfm_display(EBFM_MSG_INFO, `STR_SEP);
     cfg_addr = {STATUS_COMMAND, 2'h0};

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
     cfg_wdata = rdata | 16'h6;

     unused_result = ebfm_display(EBFM_MSG_INFO, {"Config write with data = ", himage8(cfg_wdata)});
     ebfm_cfgwr_imm_wait (
                           ep_bus,           // EP Bus number
                           ep_dev,           // EP Dev number 
                           ep_func,          // EP Func number
                           cfg_addr,         // Config register address in byte 
                           dw_byte_length,   // Byte length 
                           cfg_wdata,            // Config Write data 
                           compl_status);    // Completion Status


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
     if ((rdata != cfg_wdata) & (ep_func < 2))
         unused_result = ebfm_display (EBFM_MSG_ERROR_FATAL, {"Error: Mismatched: Expected = ", himage8(cfg_wdata), "  -----, ", "Actual = ", himage8(rdata)}); 
     else 
         unused_result = ebfm_display(EBFM_MSG_INFO, {"After cfg_rd_modified_wr, config_data = 0x", himage8(rdata)});
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

   begin

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
     cfg_rd_modified_wr (ep_bus, ep_func, ep_func, {STATUS_COMMAND, 2'h0}, 32'h7);

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

   integer     ep_func;
   integer     rc_slave_bar;
      reg      unused_result ;

   begin

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
            cfg_rd_modified_wr (ep_bus, ep_func, ep_func, {STATUS_COMMAND, 2'h0}, 32'h7);

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
           
            find_mem_bar(bar_table, 6'b000001, 8, rc_slave_bar);
            my_test (
               USE_CONFIG_BYPASS_HWTCL,
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
               USE_CONFIG_BYPASS_HWTCL,
               bar_table,               // Pointer to the BAR sizing and
               rc_slave_bar             // Pointer to the BAR sizing and
            );       


      //================== END of Config Bypass test ====================================      
   end
endtask

task sriov_test; 
   input integer  ep_bus;
   input integer  bar_table;
   input integer  display_rp_config;    // 1 to display
   input integer  display_ep_config;    // 1 to display
   input reg      addr_map_4GB_limit;
   output reg     activity_toggle;

   reg         unused_result ;

   begin
    unused_result = ebfm_display (EBFM_MSG_INFO, {"SR_IOV test will be available in 14.0"});

   end
endtask
