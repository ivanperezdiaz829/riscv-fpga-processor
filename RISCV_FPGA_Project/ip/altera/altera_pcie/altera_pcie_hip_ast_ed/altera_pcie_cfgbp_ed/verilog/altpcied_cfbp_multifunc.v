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


module altpcied_cfbp_multifunc

#(
   parameter DEVIDE_ID         = 16'hE001,
   parameter VENDOR_ID         = 16'h1172,
   parameter SUBSYS_ID         = 16'h1234,
   parameter SUBVENDOR_ID      = 16'h5678,
   parameter BAR0_PREFETCHABLE = 1,  
   parameter BAR0_TYPE         = 2,  
   parameter BAR0_MEMSPACE     = 0,  
   parameter TGT_BAR0_WIDTH    = 20  
)
  ( 
    // clock, reset inputs
    input          Clk_i,
    input          Rstn_i,
    
    // Config interface
    input [31:0]                         cfg_addr_i,
    input [31:0]                         cfg_wrdata_i,
    input [ 3:0]                         cfg_be_i,
    input                                cfg_rden_i,
    input                                cfg_wren_i,
    input                                cfg_writeresponserequest_i,
    output reg                           cfg_waitrequest_o,
    output reg                           cfg_writeresponsevalid_o,
    output reg [ 2:0]                    cfg_writeresponse_o,
    output reg                           cfg_rddatavalid_o,
    output reg [31:0]                    cfg_rddata_o,
    output reg [ 2:0]                    cfg_readresponse_o,       


    //=====================
    // cfg_ctl definition 
    // [13]   = mem_en;
    // [12:0] = {bus, dev} 
    output  wire                             f0_mem_en_o,
    output  wire [31 : TGT_BAR0_WIDTH]       f0_bar0_msb_o,
    output  wire [31 : 0]                    f0_bar1_o,
    output  wire                             f1_mem_en_o,
    output  wire [31 : TGT_BAR0_WIDTH]       f1_bar0_msb_o,
    output  wire [31 : 0]                    f1_bar1_o,
    output  wire [12:0]                      ep_bus_dev_o 

  );
  

localparam      FUNC_0 = 3'h0;
localparam      FUNC_1 = 3'h1;

reg             func1_sel;
wire  [ 2:0]    cfg_func;
wire            cfg_rden1, cfg_wren1;

wire            f0_waitrequest;
wire            f0_writeresponsevalid;
wire  [ 2:0]    f0_writeresponse;
wire            f0_rddatavalid;
wire  [31:0]    f0_rddata;
wire  [ 2:0]    f0_readresponse;               
wire  [12:0]    f0_ep_bus_dev; 
wire  [12:0]    f1_ep_bus_dev; 
wire            f1_waitrequest;
wire            f1_writeresponsevalid;
wire  [ 2:0]    f1_writeresponse;
wire            f1_rddatavalid;
wire  [31:0]    f1_rddata;
wire  [ 2:0]    f1_readresponse;       

assign cfg_func     = cfg_addr_i[18:16];
assign cfg_rden1    = cfg_rden_i & (cfg_func == FUNC_1);
assign cfg_wren1    = cfg_wren_i & (cfg_func == FUNC_1) & cfg_writeresponserequest_i;


always @(posedge Clk_i or negedge Rstn_i) begin 
    if(~Rstn_i)   
       func1_sel <= 1'b0;
    else if (f1_writeresponsevalid | f1_rddatavalid)  
       func1_sel <= 1'b0;
    else if (cfg_rden1 | cfg_wren1) 
       func1_sel <= 1'b1;
end

//===================================
// Instantiate function 0
//===================================
altpcied_cfbp_cfgspace
#(
   .FUNC_NO           (FUNC_0            ), 
   .DEVIDE_ID         (DEVIDE_ID         ), 
   .VENDOR_ID         (VENDOR_ID         ), 
   .SUBSYS_ID         (SUBSYS_ID         ), 
   .SUBVENDOR_ID      (SUBVENDOR_ID      ), 
   .BAR0_PREFETCHABLE (BAR0_PREFETCHABLE ),   
   .BAR0_TYPE         (BAR0_TYPE         ), 
   .BAR0_MEMSPACE     (BAR0_MEMSPACE     ) 
)  
  cfgspace_f0( 
      .Clk_i                       (Clk_i ),
      .Rstn_i                      (Rstn_i), 
      .cfg_addr_i                  (cfg_addr_i                   ),
      .cfg_wrdata_i                (cfg_wrdata_i                 ),
      .cfg_be_i                    (cfg_be_i                     ),
      .cfg_rden_i                  (cfg_rden_i                   ),
      .cfg_wren_i                  (cfg_wren_i                   ),
      .cfg_writeresponserequest_i  (cfg_writeresponserequest_i   ),
      .cfg_waitrequest_o           (f0_waitrequest                ),
      .cfg_writeresponsevalid_o    (f0_writeresponsevalid         ),
      .cfg_writeresponse_o         (f0_writeresponse              ),
      .cfg_rddatavalid_o           (f0_rddatavalid                ),
      .cfg_rddata_o                (f0_rddata                     ),
      .cfg_readresponse_o          (f0_readresponse               ),
      .mem_en_o                    (f0_mem_en_o                   ),
      .bar0_msb_o                  (f0_bar0_msb_o                 ),
      .bar1_o                      (f0_bar1_o                     ),
      .ep_bus_dev_o                (f0_ep_bus_dev                 )
  );
  
//===================================
// Instantiate function 1
//===================================
altpcied_cfbp_cfgspace
#(
   .FUNC_NO           (FUNC_1            ), 
   .DEVIDE_ID         (DEVIDE_ID         ), 
   .VENDOR_ID         (VENDOR_ID         ), 
   .SUBSYS_ID         (SUBSYS_ID         ), 
   .SUBVENDOR_ID      (SUBVENDOR_ID      ), 
   .BAR0_PREFETCHABLE (BAR0_PREFETCHABLE ),   
   .BAR0_TYPE         (BAR0_TYPE         ), 
   .BAR0_MEMSPACE     (BAR0_MEMSPACE     ) 
)  
  cfgspace_f1( 
      .Clk_i                       (Clk_i ),
      .Rstn_i                      (Rstn_i), 
      .cfg_addr_i                  (cfg_addr_i                   ),
      .cfg_wrdata_i                (cfg_wrdata_i                 ),
      .cfg_be_i                    (cfg_be_i                     ),
      .cfg_rden_i                  (cfg_rden_i                   ),
      .cfg_wren_i                  (cfg_wren_i                   ),
      .cfg_writeresponserequest_i  (cfg_writeresponserequest_i   ),
      .cfg_waitrequest_o           (f1_waitrequest                ),
      .cfg_writeresponsevalid_o    (f1_writeresponsevalid         ),
      .cfg_writeresponse_o         (f1_writeresponse              ),
      .cfg_rddatavalid_o           (f1_rddatavalid                ),
      .cfg_rddata_o                (f1_rddata                     ),
      .cfg_readresponse_o          (f1_readresponse               ),
      .mem_en_o                    (f1_mem_en_o                   ),
      .bar0_msb_o                  (f1_bar0_msb_o                 ),
      .bar1_o                      (f1_bar1_o                     ),
      .ep_bus_dev_o                (f1_ep_bus_dev                 )
  );
  
//===================================
// Muxing outputs 
//===================================
always @(*) begin
   if (func1_sel) begin
      cfg_waitrequest_o        <= f1_waitrequest       ;
      cfg_writeresponsevalid_o <= f1_writeresponsevalid;
      cfg_writeresponse_o      <= f1_writeresponse     ;
      cfg_rddatavalid_o        <= f1_rddatavalid       ;
      cfg_rddata_o             <= f1_rddata            ;
      cfg_readresponse_o       <= f1_readresponse      ;
   end else begin
      cfg_waitrequest_o        <= f0_waitrequest       ;
      cfg_writeresponsevalid_o <= f0_writeresponsevalid;
      cfg_writeresponse_o      <= f0_writeresponse     ;
      cfg_rddatavalid_o        <= f0_rddatavalid       ;
      cfg_rddata_o             <= f0_rddata            ;
      cfg_readresponse_o       <= f0_readresponse      ;
   end
end

assign ep_bus_dev_o = f0_ep_bus_dev;

endmodule
