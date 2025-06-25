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


module altpcied_cfbp_cfgspace

#(
   parameter FUNC_NO           = 0,
   parameter DEVIDE_ID         = 16'hE001,    
   parameter VENDOR_ID         = 16'h1172,    
   parameter SUBSYS_ID         = 16'h1234,    // x1234
   parameter SUBVENDOR_ID      = 16'h5678,   // x5678,
   parameter BAR0_PREFETCHABLE = 1,       // Must be set for 64bit addressing
   parameter BAR0_TYPE         = 2'h2,       // x0: 32bit or x2: 64bit decoder
   parameter BAR0_MEMSPACE     = 0,       // 0: memory space, 1: IO Space
   parameter BAR1_PREFETCHABLE = 0,  
   parameter BAR1_TYPE         = 0,  
   parameter BAR1_MEMSPACE     = 0,  
   parameter TGT_BAR0_WIDTH    = 20       // Claim 1MB of memory space  
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
    output wire                          cfg_waitrequest_o,
    output wire                          cfg_writeresponsevalid_o,
    output wire [ 2:0]                   cfg_writeresponse_o,
    output wire                          cfg_rddatavalid_o,
    output wire [31:0]                   cfg_rddata_o,
    output wire [ 2:0]                   cfg_readresponse_o,


    //=====================
    // cfg_ctl definition 
    // [13]   = mem_en;
    // [12:0] = {bus, dev} 
    output wire                         mem_en_o,
    output wire [31 : TGT_BAR0_WIDTH]   bar0_msb_o,
    output  [31 : 0]                    bar1_o,
    output wire [12:0]                  ep_bus_dev_o // Bus and device number are common for all function 

  );
  
  // Completion Status
  localparam CFG_SC               = 3'h0; // Successful completion with non-zero data
  localparam CFG_UR               = 3'h1;
  localparam CFG_CRS              = 3'h2;
  localparam CFG_CA               = 3'h3;
  localparam CFG_SC0              = 3'h4; // Successful completion with zero data 

  // CFG registers dw address
  localparam DEV_VENDOR_ID        = 9'h0;
  localparam STATUS_COMMAND       = 9'h1;
  localparam BIST_HDR_TYPE        = 9'h3;
  localparam BAR0_REG             = 9'h4;
  localparam BAR1_REG             = 9'h5;
  localparam SUBSYS_ID_VENDOR_ID  = 9'h11;

  wire            cfg_rden, cfg_wren;
  wire   [31:0]   cfg_wdata;  
  wire   [11:0]   cfg_addr;
  wire   [ 9:0]   cfg_dw_addr;
  wire            cfg_hi_word;
  reg    [31:0]   cfg_rdata, cfg_rdata_r;
  wire   [ 7:0]   cfg_busno;
  wire   [ 4:0]   cfg_devno;
  wire   [ 3:0]   cfg_be;
  wire   [ 2:0]   cfg_func;
  reg    [ 7:0]   ep_busno;
  reg    [ 4:0]   ep_devno;
  reg             cfg_rddatavalid_r, cfg_wrresponsevalid_r;

  // Command Status Register
  reg             io_space_en, mem_space_en, bus_master, parity_err_response, serr_en, int_disable;
  wire   [15:0]   pri_status;

  // PCI legacy registers
  wire   [31:0]   dev_vendor_id_r;
  wire   [15:0]   dev_id, vend_id;
  wire   [31:0]   status_cmd_r;
  wire   [15:0]   sub_sys_id, sub_vend_id;
  wire   [31:0]   subsys_id_vendor_id_r;

  // PCI BARs
  reg    [31:TGT_BAR0_WIDTH]   bar0_msb;
  wire   [31:0]   bar0_r;
  wire   [31:0]   bar1_r;
  reg    [31:7]   bar1_msb;
  wire            bar0_prefetch, bar0_mem_space;
  wire   [ 1:0]   bar0_type;
  reg             bar1_prefetch, bar1_mem_space;
  reg    [1:0]    bar1_type;
  // Header type
  wire   [31:0]   cfg_dw_reg3;
///========================================== 
/// CFG control derived from inputs
///========================================== 
  assign cfg_busno   = cfg_addr_i[23:19];
  assign cfg_devno   = cfg_addr_i[31:24];
  assign cfg_func    = cfg_addr_i[18:16];
  assign cfg_addr    = cfg_addr_i[11:0]; //byte address
  assign cfg_dw_addr = cfg_addr_i[11:2]; //dword address
  assign cfg_hi_word = cfg_addr_i[1];
  assign cfg_rden    = cfg_rden_i & (cfg_func == FUNC_NO);
  assign cfg_wren    = cfg_wren_i & (cfg_func == FUNC_NO) & cfg_writeresponserequest_i;
  assign cfg_wdata   = cfg_wrdata_i;
  assign cfg_be      = cfg_be_i;
  
//==================================
// EP Bus and Device number
//==================================
always @(posedge Clk_i or negedge Rstn_i) begin
    if(~Rstn_i) begin
       ep_busno   <= 8'h0;
       ep_devno   <= 5'h0;
    end else if (cfg_wren) begin
       ep_busno   <= cfg_busno;
       ep_devno   <= cfg_devno;
    end
end

//=========================
// dw0: ID registers
//=========================
  assign dev_id                  = DEVIDE_ID;
  assign vend_id                 = VENDOR_ID;
  assign sub_sys_id              = SUBSYS_ID;
  assign sub_vend_id             = SUBVENDOR_ID;

  assign dev_vendor_id_r         = {dev_id,vend_id };
  assign subsys_id_vendor_id_r   = {sub_sys_id, sub_vend_id};

//=========================
// dw1: Command Status register
//=========================
always @(posedge Clk_i or negedge Rstn_i) begin
    if(~Rstn_i) begin
      io_space_en    <= 1'b0;
      mem_space_en   <= 1'b0;
      bus_master     <= 1'b0;
    end else if (cfg_wren & (cfg_dw_addr == STATUS_COMMAND) & !cfg_hi_word & cfg_be[0]) begin
      io_space_en    <= cfg_wdata[0];
      mem_space_en   <= cfg_wdata[1];
      bus_master     <= cfg_wdata[2];
    end
end

always @(posedge Clk_i or negedge Rstn_i) begin
    if(~Rstn_i) begin
      parity_err_response <= 1'b0;
      serr_en        <= 1'b0;
      int_disable    <= 1'b0;
    end else if (cfg_wren & (cfg_dw_addr == STATUS_COMMAND) & cfg_hi_word & cfg_be[1]) begin
      parity_err_response <= cfg_wdata[6];
      serr_en        <= cfg_wdata[ 8];
      int_disable    <= cfg_wdata[10];
    end
end

assign pri_status   = 16'h0;
assign status_cmd_r = { pri_status, 
                        5'h0, int_disable,1'b0, serr_en, 1'b0, parity_err_response, 3'h0, bus_master, mem_space_en, io_space_en};

//===============================================================
// dw3: 
// [31:24] = Bist[7:0] = not supported = 8'h0
// [23:16] = Header type =>  multifunc, type0 => bit[7]=1 bit[6:0]=0
// [15:8]  = latency timer = 8'h0
// [7:0]   = cache line size not used for PCIe, hardwire to 0
//===============================================================
assign cfg_dw_reg3 = {8'h0, 1'b1, 7'h0, 8'h0, 8'h0};

//===============================================================
// dw4: Bar0 address register: 
// For this design example, the target only claim 1MB of memory 
//===============================================================
always @(posedge Clk_i or negedge Rstn_i) begin
    if(~Rstn_i)
      bar0_msb <= 22'h0; 
    else if (cfg_wren & (cfg_dw_addr == BAR0_REG)) begin
      bar0_msb[31:24]             <= cfg_be[3] ? cfg_wdata[31:24] : bar0_msb[31:24]; 
      bar0_msb[23:TGT_BAR0_WIDTH] <= cfg_be[2] ? cfg_wdata[23:TGT_BAR0_WIDTH] : bar0_msb[23:TGT_BAR0_WIDTH]; 
    end  
end

assign bar0_prefetch = BAR0_PREFETCHABLE;
assign bar0_type     = BAR0_TYPE;
assign bar0_mem_space = BAR0_MEMSPACE;

assign bar0_r = {bar0_msb, 16'h0, bar0_prefetch, bar0_type, bar0_mem_space};

//======================================================================
// BAR1 address register
// BAR1 is not supported for this design example. 
// So, if BAR0 is 32'b addressing, it will return zero.
//======================================================================
always @(posedge Clk_i or negedge Rstn_i) begin
    if(~Rstn_i) begin
      bar1_msb       <=  {(32-TGT_BAR0_WIDTH){1'b0}}; 
      bar1_prefetch  <=  1'b0;
      bar1_type      <=  2'h0;
      bar1_mem_space <=  1'b0;
    end else if (cfg_wren & (cfg_dw_addr == BAR1_REG) & (BAR0_TYPE == 2'h2) ) begin
      bar1_msb[31:24] <= cfg_be[3] ? cfg_wdata[31:24] : bar1_msb[31:24]; 
      bar1_msb[23:16] <= cfg_be[2] ? cfg_wdata[23:16] : bar1_msb[23:16]; 
      bar1_msb[15: 8] <= cfg_be[1] ? cfg_wdata[15: 8] : bar1_msb[15: 8]; 
      bar1_msb[ 7 ]   <= cfg_be[0] ? cfg_wdata[ 7]    : bar1_msb[ 7]; 
      bar1_prefetch   <= cfg_be[0] ? cfg_wdata[3]     : 1'b0; 
      bar1_type       <= cfg_be[0] ? cfg_wdata[2:1]   : 2'h0;
      bar1_mem_space  <= cfg_be[0] ? cfg_wdata[0]     : 1'b0;
    end  
end

assign bar1_r = {bar1_msb, 3'h0, bar1_prefetch, bar1_type, bar1_mem_space};

//===================================
// CFG Read data and read response
//===================================
always @(*) begin
   case (cfg_dw_addr) 
      DEV_VENDOR_ID :      cfg_rdata   <= dev_vendor_id_r;
      STATUS_COMMAND:      cfg_rdata   <= status_cmd_r;
      BIST_HDR_TYPE :      cfg_rdata   <= cfg_dw_reg3;
      BAR0_REG:            cfg_rdata   <= bar0_r; 
      BAR1_REG:            cfg_rdata   <= bar1_r; 
      SUBSYS_ID_VENDOR_ID: cfg_rdata   <= subsys_id_vendor_id_r;
      default:             cfg_rdata   <= 32'h0;
   endcase
end

always @(posedge Clk_i or negedge Rstn_i)  begin
    if(~Rstn_i) begin
      cfg_rddatavalid_r       <= 1'b0;  
      cfg_wrresponsevalid_r   <= 1'b0;
    end else begin
      cfg_rddatavalid_r       <= cfg_rden;  
      cfg_rdata_r             <= cfg_rdata;  
      cfg_wrresponsevalid_r   <= cfg_wren;
    end   
end

//=========================
// Output registers
//=========================
assign cfg_writeresponse_o      = CFG_SC;
assign cfg_readresponse_o       = CFG_SC;
assign cfg_waitrequest_o        = 1'b0;
assign cfg_writeresponsevalid_o = cfg_wrresponsevalid_r;
assign cfg_rddatavalid_o        = cfg_rddatavalid_r;
assign cfg_rddata_o             = cfg_rdata_r;


assign   mem_en_o       = mem_space_en;
assign   bar0_msb_o     = bar0_msb;
assign   bar1_o         = bar1_r;
assign   ep_bus_dev_o   = {ep_busno, ep_devno}; // Bus and device number are common for all function 

endmodule
