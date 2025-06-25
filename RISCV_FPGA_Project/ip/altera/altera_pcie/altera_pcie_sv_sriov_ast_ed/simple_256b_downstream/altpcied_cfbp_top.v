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


//==================================================================================================
// This block parse the RX commands on Avalon-ST interface and convert it to the request to either
// 1. Config Space or 
// 2. Target memory requests
//==================================================================================================

module altpcied_cfbp_top #(
   parameter ast_width_hwtcl        = "Avalon-ST 256-bit",
   parameter AVALON_WADDR           = 20,
   parameter AVALON_WDATA           = 128,
   parameter CB_RXM_DATA_WIDTH      = 32,
   parameter VF_COUNT               = 32,
   parameter INTENDED_DEVICE_FAMILY="Stratix V"
   )(

   input                         Clk_i,
   input                         Rstn_i,
   //==============================
   // RX Avalon streaming interface 
   //==============================
    output         RxStMask_o,
    input          RxStSop_i,
    input          RxStEop_i,
    input [AVALON_WDATA-1:0]   RxStData_i,
    input          RxStValid_i,
    output         RxStReady_o,

   //==============================
   // TX Avalon streaming interface 
   //==============================
    input         TxStReady_i,
    output        TxStSop_o,
    output        TxStEop_o,
    output [((INTENDED_DEVICE_FAMILY == "Arria V" || INTENDED_DEVICE_FAMILY == "Cyclone V")?1:2)-1:0]        TxStEmpty_o,
    output [AVALON_WDATA-1:0] TxStData_o,
    output        TxStValid_o,
    output        TxStErr_o,

    //============================
    // Config informations
    //============================
    input [7:0]     rx_st_bar_hit_tlp0, // BAR hit information for first TLP in this cycle
    input [7:0]     rx_st_bar_hit_fn_tlp0, // Target Function for first TLP in this cycle
    input [7:0]     rx_st_bar_hit_tlp1, // BAR hit information for second TLP in this cycle
    input [7:0]     rx_st_bar_hit_fn_tlp1, // Target Function for second TLP in this cycle
    input [7:0]     bus_num_f0,       // Captured bus number for Function 0
    input [4:0]     device_num_f0,     // Captured device number for Function 0
    input                mem_space_en_pf,  // Memory Space Enable for PF 0
    input                bus_master_en_pf, // Bus Master Enable for PF 0
    input [VF_COUNT-1:0] mem_space_en_vf,  // Memory Space Enable for VFs (common for all VFs)
    input [VF_COUNT-1:0] bus_master_en_vf, // Bus Master Enable for VFs

   // MSI Interrupts
   input                  app_intx_disable,     // INTX Disable from PCI Command Register of PF 0
   input                  app_msi_enable_pf,    // MSI Enable setting of PF 0
   input [2:0]            app_msi_multi_msg_enable_pf,// MSI Multiple Msg field setting of PF 0
   input [VF_COUNT-1:0]   app_msi_enable_vf,// MSI Enable setting of VFs
   input [VF_COUNT*3-1:0] app_msi_multi_msg_enable_vf, // MSI Multiple Msg field setting of VFs

   output                 app_msi_req,
   input                  app_msi_ack,
   output  [7 : 0]        app_msi_req_fn,
   output  [4 : 0]        app_msi_num,
   output  [2 : 0]        app_msi_tc,
  
   // Legacy interrupts
   output                 app_int_sts_a,
   output                 app_int_sts_b,
   output                 app_int_sts_c,
   output                 app_int_sts_d,
   output [2:0]           app_int_sts_fn, // Function Num associated with the Legacy interrupt request
   output                 app_int_pend_status,  // Interrupt pending stats from Function
   input                  app_int_ack,

   // LMI interface
   input                  lmi_ack,
   input [31 : 0]         lmi_dout,
   output  [11 : 0]       lmi_addr,
   output  [ 8 : 0]       lmi_func,  // [7:0] =  Function Number,
                                     // [ 8] = 0 => access to Hard IP register
                                     // [ 8] = 1 => access to SR-IOV bridge config space
   output  [31 : 0]       lmi_din,
   output  wire           lmi_rden,
   output  wire           lmi_wren

   );


   wire                            RxmWrite_0;  
   wire [AVALON_WADDR-1:0]         RxmAddress_0;
   wire [CB_RXM_DATA_WIDTH-1:0]    RxmWriteData_0;
   wire [3:0]                      RxmByteEnable_0;
   wire                            RxmWaitRequest_0;
   wire                            RxmRead_0;
   wire  [CB_RXM_DATA_WIDTH-1:0]   RxmReadData_0;          // this comes from Avalon Slave to be routed to Tx completion
   wire                            RxmReadDataValid_0;     // this comes from Avalon Slave to be routed to Tx completion
   wire                            RxmFunc1Sel;            // Select function 1  
   wire                            mbox_sel;

   wire                            tgt_RxmWaitRequest_0;
   wire  [CB_RXM_DATA_WIDTH-1:0]   tgt_RxmReadData_0;          
   wire                            tgt_RxmReadDataValid_0;     
   wire                            mbox_RxmWaitRequest_0;
   wire  [CB_RXM_DATA_WIDTH-1:0]   mbox_RxmReadData_0;          
   wire                            mbox_RxmReadDataValid_0;     

    // Config interface
    wire [31:0]                    cfg_addr;
    wire [31:0]                    cfg_wrdata;
    wire [ 3:0]                    cfg_be;
    wire                           cfg_rden;
    wire                           cfg_wren;
    wire                           cfg_waitrequest;
    wire                           cfg_writeresponserequest;
    wire                           cfg_writeresponsevalid;
    wire  [ 2:0]                   cfg_writeresponse;
    wire                           cfg_rddatavalid;
    wire  [31:0]                   cfg_rddata;
    wire  [ 2:0]                   cfg_readresponse;
    wire  [7:0]                    rxm_bar_hit_tlp0; 
    wire  [7:0]                    rxm_bar_hit_fn_tlp0; 
   //====================
   //  Controller
   //====================

            altpcied_cfbp_256b_control # (
               .AVALON_WDATA        (AVALON_WDATA),
               .AVALON_WADDR        (AVALON_WADDR),
               .CB_RXM_DATA_WIDTH   (CB_RXM_DATA_WIDTH)
            )
              altpcied_cfbp_256b_control ( 
                   .Clk_i                      ( Clk_i                      ),
                   .Rstn_i                     ( Rstn_i                     ),
                   .RxStMask_o                 ( RxStMask_o                 ),
                   .RxStSop_i                  ( RxStSop_i                  ),
                   .RxStEop_i                  ( RxStEop_i                  ),
                   .RxStData_i                 ( RxStData_i                 ),
                   .RxStValid_i                ( RxStValid_i                ),
                   .RxStReady_o                ( RxStReady_o                ),
                   .TxStReady_i                ( TxStReady_i                ),
                   .TxStSop_o                  ( TxStSop_o                  ),
                   .TxStEop_o                  ( TxStEop_o                  ),
                   .TxStEmpty_o                ( TxStEmpty_o                ), 
                   .TxStData_o                 ( TxStData_o                 ),
                   .TxStValid_o                ( TxStValid_o                ),
                   .TxStErr_o                  ( TxStErr_o                  ),
            
                   .RxmWrite_0_o               ( RxmWrite_0                 ),
                   .RxmAddress_0_o             ( RxmAddress_0               ),
                   .RxmWriteData_0_o           ( RxmWriteData_0             ),
                   .RxmByteEnable_0_o          ( RxmByteEnable_0            ),
                   .RxmWaitRequest_0_i         ( RxmWaitRequest_0           ),
                   .RxmRead_0_o                ( RxmRead_0                  ),
                   .RxmReadData_0_i            ( RxmReadData_0              ),
                   .RxmReadDataValid_0_i       ( RxmReadDataValid_0         ),
                   .mbox_sel_o                 ( mbox_sel                   ),
                   .cfg_addr_o                 ( cfg_addr                   ),
                   .cfg_wrdata_o               ( cfg_wrdata                 ),
                   .cfg_be_o                   ( cfg_be                     ),
                   .cfg_rden_o                 ( cfg_rden                   ),
                   .cfg_wren_o                 ( cfg_wren                   ),
                   .cfg_waitrequest_i          ( cfg_waitrequest            ),
                   .cfg_writeresponserequest_o ( cfg_writeresponserequest   ),
                   .cfg_writeresponsevalid_i   ( 1'b0),
                   .cfg_writeresponse_i        ( 3'h0),
                   .cfg_rddatavalid_i          ( 1'b0),
                   .cfg_rddata_i               ( 32'h0),
                   .cfg_readresponse_i         ( 3'h0),

                   .rx_st_bar_hit_tlp0    ( rx_st_bar_hit_tlp0),
                   .rx_st_bar_hit_fn_tlp0 ( rx_st_bar_hit_fn_tlp0),
                   .rx_st_bar_hit_tlp1    ( rx_st_bar_hit_tlp1),
                   .rx_st_bar_hit_fn_tlp1 ( rx_st_bar_hit_fn_tlp1),
                   .rxm_bar_hit_tlp0_o    ( rxm_bar_hit_tlp0),
                   .rxm_bar_hit_fn_tlp0_o ( rxm_bar_hit_fn_tlp0),
                   .bus_num_f0            ( bus_num_f0),
                   .device_num_f0         ( device_num_f0)
            );

   //====================
   //  Target 
   //====================
   altpcied_cfbp_target #(
      .AVALON_WADDR          (AVALON_WADDR) ,  
      .CB_RXM_DATA_WIDTH     (CB_RXM_DATA_WIDTH )
   ) altpcied_cfbp_target (
       .Clk_i                       ( Clk_i                       ),
       .Rstn_i                      ( Rstn_i                      ),
       .RxmWrite_0_i                ( RxmWrite_0                  ),
       .RxmAddress_0_i              ( RxmAddress_0                ),
       .RxmWriteData_0_i            ( RxmWriteData_0              ),
       .RxmByteEnable_0_i           ( RxmByteEnable_0             ),
       .RxmWaitRequest_0_o          ( tgt_RxmWaitRequest_0        ),
       .RxmRead_0_i                 ( RxmRead_0                   ),
       .RxmReadData_0_o             ( tgt_RxmReadData_0           ),    
       .RxmReadDataValid_0_o        ( tgt_RxmReadDataValid_0      ),
       .rxm_bar_hit_tlp0_i          ( rxm_bar_hit_tlp0            ),
       .rxm_bar_hit_fn_tlp0_i       ( rxm_bar_hit_fn_tlp0         )
  );

  
   //=======================
   //  Mail-Box registers
   //=======================
  altpcied_cfbp_mbox # (
      .AVALON_WADDR          (AVALON_WADDR) ,  
      .CB_RXM_DATA_WIDTH     (CB_RXM_DATA_WIDTH ),
      .VF_COUNT              (VF_COUNT )
  ) altpcied_cfbp_mbox (
       .Clk_i                       ( Clk_i                       ),
       .Rstn_i                      ( Rstn_i                      ),
       .RxmWrite_0_i                ( RxmWrite_0                  ),
       .RxmAddress_0_i              ( RxmAddress_0                ),
       .RxmWriteData_0_i            ( RxmWriteData_0              ),
       .RxmByteEnable_0_i           ( RxmByteEnable_0             ),
       .RxmWaitRequest_0_o          ( mbox_RxmWaitRequest_0       ),
       .RxmRead_0_i                 ( RxmRead_0                   ),
       .RxmReadData_0_o             ( mbox_RxmReadData_0          ),    
       .RxmReadDataValid_0_o        ( mbox_RxmReadDataValid_0     ),
       .mbox_sel_i                  ( mbox_sel                    ),
   // Config control signas
       .mem_space_en_pf             ( mem_space_en_pf),
       .bus_master_en_pf            ( bus_master_en_pf),
       .mem_space_en_vf             ( mem_space_en_vf),
       .bus_master_en_vf            ( bus_master_en_vf),

   // MSI Interrupts
       .app_intx_disable            ( app_intx_disable            ),     
       .app_msi_enable_pf           ( app_msi_enable_pf           ),   
       .app_msi_multi_msg_enable_pf ( app_msi_multi_msg_enable_pf ),
       .app_msi_enable_vf           ( app_msi_enable_vf           ),
       .app_msi_multi_msg_enable_vf ( app_msi_multi_msg_enable_vf ),

       .app_msi_req_o               ( app_msi_req                 ),
       .app_msi_ack_i               ( app_msi_ack                 ),
       .app_msi_req_fn_o            ( app_msi_req_fn              ),
       .app_msi_num_o               ( app_msi_num                 ),
       .app_msi_tc_o                ( app_msi_tc                  ),
       
   // Legacy interrupts
       .app_int_sts_a_o             ( app_int_sts_a               ),
       .app_int_sts_b_o             ( app_int_sts_b               ),
       .app_int_sts_c_o             ( app_int_sts_c               ),
       .app_int_sts_d_o             ( app_int_sts_d               ),
       .app_int_sts_fn_o            ( app_int_sts_fn              ), 
       .app_int_pend_status_o       ( app_int_pend_status         ),
       .app_int_ack_i               ( app_int_ack                 ),

   // LMI interface
       .lmi_ack_i                   ( lmi_ack                     ),
       .lmi_dout_i                  ( lmi_dout                    ),
       .lmi_addr_o                  ( lmi_addr                    ),
       .lmi_func_o                  ( lmi_func                    ),  
       .lmi_din_o                   ( lmi_din                     ),
       .lmi_rden_o                  ( lmi_rden                    ),
       .lmi_wren_o                  ( lmi_wren                    )
  );

altpcied_tgt_mux # (
      .AVALON_WADDR          (AVALON_WADDR) ,  
      .CB_RXM_DATA_WIDTH     (CB_RXM_DATA_WIDTH )
  ) altpcied_tgt_mux (
       .Clk_i                       ( Clk_i                       ),
       .Rstn_i                      ( Rstn_i                      ),
       .tgt_RxmWaitRequest_0_i      ( tgt_RxmWaitRequest_0        ),
       .tgt_RxmReadData_0_i         ( tgt_RxmReadData_0           ),    
       .tgt_RxmReadDataValid_0_i    ( tgt_RxmReadDataValid_0      ),
       .mbox_RxmWaitRequest_0_i     ( mbox_RxmWaitRequest_0       ),
       .mbox_RxmReadData_0_i        ( mbox_RxmReadData_0          ),    
       .mbox_RxmReadDataValid_0_i   ( mbox_RxmReadDataValid_0     ),
       .RxmWaitRequest_0_o          ( RxmWaitRequest_0            ),
       .RxmReadData_0_o             ( RxmReadData_0               ),    
       .RxmReadDataValid_0_o        ( RxmReadDataValid_0          ),
       .mbox_sel_i                  ( mbox_sel                    )
  );

   endmodule

