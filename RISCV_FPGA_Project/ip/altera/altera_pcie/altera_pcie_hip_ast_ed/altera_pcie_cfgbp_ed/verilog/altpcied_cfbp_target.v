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


module altpcied_cfbp_target

#(
   parameter AVALON_WADDR          = 20,  // Claim 2MB of memory space per function 
   parameter CB_RXM_DATA_WIDTH     = 32
)
  ( 
   // clock, reset inputs
   input          Clk_i,
   input          Rstn_i,

   input                                 RxmWrite_0_i,  
   input [AVALON_WADDR-1:0]              RxmAddress_0_i,
   input [CB_RXM_DATA_WIDTH-1:0]         RxmWriteData_0_i,
   input [3:0]                           RxmByteEnable_0_i,
   output                                RxmWaitRequest_0_o,
   input                                 RxmRead_0_i,
   output  [CB_RXM_DATA_WIDTH-1:0]       RxmReadData_0_o,          
   output                                RxmReadDataValid_0_o,     
   input                                 RxmFunc1Sel_i            // Select function 1  

  );

  // Memory register dword addresses
  localparam      F0_REG0_ADDR  = 19'h0;
  localparam      F0_REG1_ADDR  = 19'h1;
  localparam      F1_REG0_ADDR  = 19'h40000;
  localparam      F1_REG1_ADDR  = 19'h40001;

  wire            rxm_rden, rxm_wren;
  wire   [CB_RXM_DATA_WIDTH-1:0]   rxm_wdata;  
  wire   [AVALON_WADDR-1:0]   rxm_addr; 
  reg    [31:0]   rxm_rdata_r;
  wire   [ 3:0]   rxm_be;
  reg             rxm_rddatavalid_r;
  wire            func1_sel;

  wire   [AVALON_WADDR :2]   tgt_dw_addr; // MSB bit is for func1 access: Double the target address size for func1
  reg    [31:0]   f0_reg0, f0_reg1;
  reg    [31:0]   f1_reg0, f1_reg1;

///========================================== 
/// CFG control derived from inputs
///========================================== 
  assign rxm_addr    = RxmAddress_0_i; //byte address
  assign rxm_rden    = RxmRead_0_i;
  assign rxm_wren    = RxmWrite_0_i;
  assign rxm_wdata   = RxmWriteData_0_i;
  assign rxm_be      = RxmByteEnable_0_i;
  assign func1_sel   = RxmFunc1Sel_i;
  
//==================================
// Derive target address
//==================================
assign tgt_dw_addr = func1_sel ? {1'b1, rxm_addr[AVALON_WADDR-1: 2]} :  {1'b0, rxm_addr[AVALON_WADDR-1: 2]}; 

//==================================
// Func0 registers
//==================================
always @(posedge Clk_i or negedge Rstn_i) begin
    if(~Rstn_i) begin
       f0_reg0    <= 32'h0;
    end else if (rxm_wren & (tgt_dw_addr == F0_REG0_ADDR)) begin
       f0_reg0[31:24]  <= rxm_be[3] ? rxm_wdata[31:24] : f0_reg0[31:24];
       f0_reg0[23:16]  <= rxm_be[2] ? rxm_wdata[23:16] : f0_reg0[31:24];
       f0_reg0[16: 8]  <= rxm_be[1] ? rxm_wdata[16: 8] : f0_reg0[16: 8];
       f0_reg0[ 7: 0]  <= rxm_be[0] ? rxm_wdata[ 7: 0] : f0_reg0[ 7: 0];
    end
end

always @(posedge Clk_i or negedge Rstn_i) begin
    if(~Rstn_i) begin
       f0_reg1    <= 32'h0;
    end else if (rxm_wren & (tgt_dw_addr == F0_REG1_ADDR)) begin
       f0_reg1[31:24]  <= rxm_be[3] ? rxm_wdata[31:24] : f0_reg1[31:24];
       f0_reg1[23:16]  <= rxm_be[2] ? rxm_wdata[23:16] : f0_reg1[31:24];
       f0_reg1[16: 8]  <= rxm_be[1] ? rxm_wdata[16: 8] : f0_reg1[16: 8];
       f0_reg1[ 7: 0]  <= rxm_be[0] ? rxm_wdata[ 7: 0] : f0_reg1[ 7: 0];
    end
end

//==================================
// Func1 registers
//==================================
always @(posedge Clk_i or negedge Rstn_i) begin
    if(~Rstn_i) begin
       f1_reg0    <= 32'h0;
    end else if (rxm_wren & (tgt_dw_addr == F1_REG0_ADDR)) begin
       f1_reg0[31:24]  <= rxm_be[3] ? rxm_wdata[31:24] : f1_reg0[31:24];
       f1_reg0[23:16]  <= rxm_be[2] ? rxm_wdata[23:16] : f1_reg0[31:24];
       f1_reg0[16: 8]  <= rxm_be[1] ? rxm_wdata[16: 8] : f1_reg0[16: 8];
       f1_reg0[ 7: 0]  <= rxm_be[0] ? rxm_wdata[ 7: 0] : f1_reg0[ 7: 0];
    end
end

always @(posedge Clk_i or negedge Rstn_i) begin
    if(~Rstn_i) begin
       f1_reg1    <= 32'h0;
    end else if (rxm_wren & (tgt_dw_addr == F1_REG1_ADDR)) begin
       f1_reg1[31:24]  <= rxm_be[3] ? rxm_wdata[31:24] : f1_reg1[31:24];
       f1_reg1[23:16]  <= rxm_be[2] ? rxm_wdata[23:16] : f1_reg1[31:24];
       f1_reg1[16: 8]  <= rxm_be[1] ? rxm_wdata[16: 8] : f1_reg1[16: 8];
       f1_reg1[ 7: 0]  <= rxm_be[0] ? rxm_wdata[ 7: 0] : f1_reg1[ 7: 0];
    end
end


//=========================
// Read data 
//=========================
always @(posedge Clk_i or negedge Rstn_i) begin
    if(~Rstn_i)   rxm_rddatavalid_r <= 1'b0;
    else          rxm_rddatavalid_r <= rxm_rden; 
end

always @(posedge Clk_i or negedge Rstn_i) begin
    if(~Rstn_i)            rxm_rdata_r <= 32'b0;
    else if (rxm_rden) begin
         case (tgt_dw_addr)
            F0_REG0_ADDR:  rxm_rdata_r <= f0_reg0;
            F0_REG1_ADDR:  rxm_rdata_r <= f0_reg1;
            F1_REG0_ADDR:  rxm_rdata_r <= f1_reg0;
            F1_REG1_ADDR:  rxm_rdata_r <= f1_reg1;
            default:       rxm_rdata_r <= 32'h0;
         endcase
    end  
end
//=========================
// Output registers
//=========================
   assign RxmWaitRequest_0_o     = 1'b0;
   assign RxmReadData_0_o        = rxm_rdata_r;          
   assign RxmReadDataValid_0_o   = rxm_rddatavalid_r;     


endmodule
