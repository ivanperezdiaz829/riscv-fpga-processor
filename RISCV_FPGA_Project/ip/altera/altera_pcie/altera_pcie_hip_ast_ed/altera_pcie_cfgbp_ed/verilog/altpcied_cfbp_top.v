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
   parameter ast_width_hwtcl        = "Avalon-ST 128-bit",
   parameter AVALON_WADDR           = 20,
   parameter AVALON_WDATA           = 128,
   parameter CB_RXM_DATA_WIDTH      = 32,
   parameter DEVIDE_ID              = 16'hE001,
   parameter VENDOR_ID              = 16'h1172,
   parameter SUBSYS_ID              = 16'h1234,
   parameter SUBVENDOR_ID           = 16'h5678,
   parameter BAR0_PREFETCHABLE      = 1'b1,  
   parameter BAR0_TYPE              = 2'h2, // support 64bit 
   parameter BAR0_MEMSPACE          = 1'b0,  
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
    output        TxStValid_o
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
    wire                           f0_mem_en;
    wire                           f1_mem_en;
    wire  [31 : AVALON_WADDR]      f0_bar0_msb;
    wire  [31 : 0]                 f0_bar1;
    wire  [31 : AVALON_WADDR]      f1_bar0_msb;
    wire  [31 : 0]                 f1_bar1;
    wire  [12:0]                   ep_bus_dev; // Bus and device number are common for all function 
   //====================
   //  Controller
   //====================

   localparam AVALON_ST_128         = 1;

  generate begin : cfgbp_app_ctrl
      if (ast_width_hwtcl=="Avalon-ST 256-bit") begin
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
            
                   .RxmWrite_0_o               ( RxmWrite_0                 ),
                   .RxmAddress_0_o             ( RxmAddress_0               ),
                   .RxmWriteData_0_o           ( RxmWriteData_0             ),
                   .RxmByteEnable_0_o          ( RxmByteEnable_0            ),
                   .RxmWaitRequest_0_i         ( RxmWaitRequest_0           ),
                   .RxmRead_0_o                ( RxmRead_0                  ),
                   .RxmReadData_0_i            ( RxmReadData_0              ),
                   .RxmReadDataValid_0_i       ( RxmReadDataValid_0         ),
                   .RxmFunc1Sel_o              ( RxmFunc1Sel                ),
                   .cfg_addr_o                 ( cfg_addr                   ),
                   .cfg_wrdata_o               ( cfg_wrdata                 ),
                   .cfg_be_o                   ( cfg_be                     ),
                   .cfg_rden_o                 ( cfg_rden                   ),
                   .cfg_wren_o                 ( cfg_wren                   ),
                   .cfg_waitrequest_i          ( cfg_waitrequest            ),
                   .cfg_writeresponserequest_o ( cfg_writeresponserequest   ),
                   .cfg_writeresponsevalid_i   ( cfg_writeresponsevalid     ),
                   .cfg_writeresponse_i        ( cfg_writeresponse          ),
                   .cfg_rddatavalid_i          ( cfg_rddatavalid            ),
                   .cfg_rddata_i               ( cfg_rddata                 ),
                   .cfg_readresponse_i         ( cfg_readresponse           ),
                                                                              
                   .f0_mem_en                  ( f0_mem_en                  ),
                   .f1_mem_en                  ( f1_mem_en                  ),
                   .f0_bar0_msb                ( f0_bar0_msb                ),
                   .f0_bar1                    ( f0_bar1                    ),
                   .f1_bar0_msb                ( f1_bar0_msb                ),
                   .f1_bar1                    ( f1_bar1                    ),
                   .ep_bus_dev                 ( ep_bus_dev                 )
            );
      
      end else if (ast_width_hwtcl=="Avalon-ST 128-bit") begin
            altpcied_cfbp_128b_control # (
               .AVALON_WDATA        (AVALON_WDATA),
               .AVALON_WADDR        (AVALON_WADDR),
               .CB_RXM_DATA_WIDTH   (CB_RXM_DATA_WIDTH)
            )
              altpcied_cfbp_128b_control ( 
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
            
                   .RxmWrite_0_o               ( RxmWrite_0                 ),
                   .RxmAddress_0_o             ( RxmAddress_0               ),
                   .RxmWriteData_0_o           ( RxmWriteData_0             ),
                   .RxmByteEnable_0_o          ( RxmByteEnable_0            ),
                   .RxmWaitRequest_0_i         ( RxmWaitRequest_0           ),
                   .RxmRead_0_o                ( RxmRead_0                  ),
                   .RxmReadData_0_i            ( RxmReadData_0              ),
                   .RxmReadDataValid_0_i       ( RxmReadDataValid_0         ),
                   .RxmFunc1Sel_o              ( RxmFunc1Sel                ),
                   .cfg_addr_o                 ( cfg_addr                   ),
                   .cfg_wrdata_o               ( cfg_wrdata                 ),
                   .cfg_be_o                   ( cfg_be                     ),
                   .cfg_rden_o                 ( cfg_rden                   ),
                   .cfg_wren_o                 ( cfg_wren                   ),
                   .cfg_waitrequest_i          ( cfg_waitrequest            ),
                   .cfg_writeresponserequest_o ( cfg_writeresponserequest   ),
                   .cfg_writeresponsevalid_i   ( cfg_writeresponsevalid     ),
                   .cfg_writeresponse_i        ( cfg_writeresponse          ),
                   .cfg_rddatavalid_i          ( cfg_rddatavalid            ),
                   .cfg_rddata_i               ( cfg_rddata                 ),
                   .cfg_readresponse_i         ( cfg_readresponse           ),
                                                                              
                   .f0_mem_en                  ( f0_mem_en                  ),
                   .f1_mem_en                  ( f1_mem_en                  ),
                   .f0_bar0_msb                ( f0_bar0_msb                ),
                   .f0_bar1                    ( f0_bar1                    ),
                   .f1_bar0_msb                ( f1_bar0_msb                ),
                   .f1_bar1                    ( f1_bar1                    ),
                   .ep_bus_dev                 ( ep_bus_dev                 )
            );
      
      end else if (ast_width_hwtcl=="Avalon-ST 64-bit") begin
            altpcied_cfbp_64b_control # (
               .AVALON_WDATA        (AVALON_WDATA),
               .AVALON_WADDR        (AVALON_WADDR),
               .CB_RXM_DATA_WIDTH   (CB_RXM_DATA_WIDTH)
            )
              altpcied_cfbp_64b_control ( 
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
            
                   .RxmWrite_0_o               ( RxmWrite_0                 ),
                   .RxmAddress_0_o             ( RxmAddress_0               ),
                   .RxmWriteData_0_o           ( RxmWriteData_0             ),
                   .RxmByteEnable_0_o          ( RxmByteEnable_0            ),
                   .RxmWaitRequest_0_i         ( RxmWaitRequest_0           ),
                   .RxmRead_0_o                ( RxmRead_0                  ),
                   .RxmReadData_0_i            ( RxmReadData_0              ),
                   .RxmReadDataValid_0_i       ( RxmReadDataValid_0         ),
                   .RxmFunc1Sel_o              ( RxmFunc1Sel                ),
                   .cfg_addr_o                 ( cfg_addr                   ),
                   .cfg_wrdata_o               ( cfg_wrdata                 ),
                   .cfg_be_o                   ( cfg_be                     ),
                   .cfg_rden_o                 ( cfg_rden                   ),
                   .cfg_wren_o                 ( cfg_wren                   ),
                   .cfg_waitrequest_i          ( cfg_waitrequest            ),
                   .cfg_writeresponserequest_o ( cfg_writeresponserequest   ),
                   .cfg_writeresponsevalid_i   ( cfg_writeresponsevalid     ),
                   .cfg_writeresponse_i        ( cfg_writeresponse          ),
                   .cfg_rddatavalid_i          ( cfg_rddatavalid            ),
                   .cfg_rddata_i               ( cfg_rddata                 ),
                   .cfg_readresponse_i         ( cfg_readresponse           ),
                                                                              
                   .f0_mem_en                  ( f0_mem_en                  ),
                   .f1_mem_en                  ( f1_mem_en                  ),
                   .f0_bar0_msb                ( f0_bar0_msb                ),
                   .f0_bar1                    ( f0_bar1                    ),
                   .f1_bar0_msb                ( f1_bar0_msb                ),
                   .f1_bar1                    ( f1_bar1                    ),
                   .ep_bus_dev                 ( ep_bus_dev                 )
            );
      end
  end  // generate
  endgenerate

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
       .RxmWaitRequest_0_o          ( RxmWaitRequest_0            ),
       .RxmRead_0_i                 ( RxmRead_0                   ),
       .RxmReadData_0_o             ( RxmReadData_0               ),    
       .RxmReadDataValid_0_o        ( RxmReadDataValid_0          ),
       .RxmFunc1Sel_i               ( RxmFunc1Sel                 ) 
  );

   //====================
   //  Config 
   //====================
altpcied_cfbp_multifunc # (
   .DEVIDE_ID           ( DEVIDE_ID           ),
   .VENDOR_ID           ( VENDOR_ID           ),
   .SUBSYS_ID           ( SUBSYS_ID           ),
   .SUBVENDOR_ID        ( SUBVENDOR_ID        ),
   .BAR0_PREFETCHABLE   ( BAR0_PREFETCHABLE   ),
   .BAR0_TYPE           ( BAR0_TYPE           ),
   .BAR0_MEMSPACE       ( BAR0_MEMSPACE       ),
   .TGT_BAR0_WIDTH      ( AVALON_WADDR        ) 
) altpcied_cfbp_multifunc
  ( 
     .Clk_i                        ( Clk_i                    ),
     .Rstn_i                       ( Rstn_i                   ),
     .cfg_addr_i                   ( cfg_addr                 ),
     .cfg_wrdata_i                 ( cfg_wrdata               ),
     .cfg_be_i                     ( cfg_be                   ),
     .cfg_rden_i                   ( cfg_rden                 ),
     .cfg_wren_i                   ( cfg_wren                 ),
     .cfg_writeresponserequest_i   ( cfg_writeresponserequest ),
     .cfg_waitrequest_o            ( cfg_waitrequest          ),
     .cfg_writeresponsevalid_o     ( cfg_writeresponsevalid   ),
     .cfg_writeresponse_o          ( cfg_writeresponse        ),
     .cfg_rddatavalid_o            ( cfg_rddatavalid          ),
     .cfg_rddata_o                 ( cfg_rddata               ),
     .cfg_readresponse_o           ( cfg_readresponse         ),
     .f0_mem_en_o                  ( f0_mem_en                ),
     .f0_bar0_msb_o                ( f0_bar0_msb              ),
     .f0_bar1_o                    ( f0_bar1                  ),
     .f1_mem_en_o                  ( f1_mem_en                ),
     .f1_bar0_msb_o                ( f1_bar0_msb              ),
     .f1_bar1_o                    ( f1_bar1                  ),
     .ep_bus_dev_o                 ( ep_bus_dev               )
  );
  
   endmodule

