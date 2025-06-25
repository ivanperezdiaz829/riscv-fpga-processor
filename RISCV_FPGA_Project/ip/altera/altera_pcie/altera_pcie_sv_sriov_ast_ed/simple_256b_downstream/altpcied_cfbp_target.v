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
   input  [7:0]                          rxm_bar_hit_tlp0_i,  
   input  [7:0]                          rxm_bar_hit_fn_tlp0_i 

  );

  // Memory register dword addresses
  localparam      F0_REG0_ADDR   = 19'h0;
  localparam      F0_REG1_ADDR   = 19'h1;
  // VF register address
  localparam      VF0_REG_ADDR   = 5'd0;
  localparam      VF1_REG_ADDR   = 5'd1;
  localparam      VF2_REG_ADDR   = 5'd2;
  localparam      VF3_REG_ADDR   = 5'd3;
  localparam      VF4_REG_ADDR   = 5'd4;
  localparam      VF5_REG_ADDR   = 5'd5;
  localparam      VF6_REG_ADDR   = 5'd6;
  localparam      VF7_REG_ADDR   = 5'd7;
  localparam      VF8_REG_ADDR   = 5'd8;
  localparam      VF9_REG_ADDR   = 5'd9;
  localparam      VF10_REG_ADDR  = 5'd10;
  localparam      VF11_REG_ADDR  = 5'd11;
  localparam      VF12_REG_ADDR  = 5'd12;
  localparam      VF13_REG_ADDR  = 5'd13;
  localparam      VF14_REG_ADDR  = 5'd14;
  localparam      VF15_REG_ADDR  = 5'd15;
  localparam      VF16_REG_ADDR  = 5'd16;
  localparam      VF17_REG_ADDR  = 5'd17;
  localparam      VF18_REG_ADDR  = 5'd18;
  localparam      VF19_REG_ADDR  = 5'd19;
  localparam      VF20_REG_ADDR  = 5'd20;
  localparam      VF21_REG_ADDR  = 5'd21;
  localparam      VF22_REG_ADDR  = 5'd22;
  localparam      VF23_REG_ADDR  = 5'd23;
  localparam      VF24_REG_ADDR  = 5'd24;
  localparam      VF25_REG_ADDR  = 5'd25;
  localparam      VF26_REG_ADDR  = 5'd26;
  localparam      VF27_REG_ADDR  = 5'd27;
  localparam      VF28_REG_ADDR  = 5'd28;
  localparam      VF29_REG_ADDR  = 5'd29;
  localparam      VF30_REG_ADDR  = 5'd30;
  localparam      VF31_REG_ADDR  = 5'd31;

  wire            rxm_rden, rxm_wren;
  wire   [CB_RXM_DATA_WIDTH-1:0]   rxm_wdata;  
  wire   [AVALON_WADDR-1:0]   rxm_addr; 
  reg    [31:0]   rxm_rdata_r;
  wire   [ 3:0]   rxm_be;
  reg             rxm_rddatavalid_r;
  wire            func1_sel;

  wire   [AVALON_WADDR-1 :2]   tgt_dw_addr; // MSB bit is for func1 access: Double the target address size for func1
  reg    [31:0]   f0_reg0, f0_reg1;
  wire    [31:0]   vf0_reg,  vf1_reg,  vf2_reg, vf3_reg, vf4_reg, vf5_reg, vf6_reg, vf7_reg;
  wire    [31:0]   vf8_reg,  vf9_reg,  vf10_reg, vf11_reg, vf12_reg, vf13_reg, vf14_reg, vf15_reg;
  wire    [31:0]   vf16_reg, vf17_reg, vf18_reg, vf19_reg, vf20_reg, vf21_reg, vf22_reg, vf23_reg;
  wire    [31:0]   vf24_reg, vf25_reg, vf26_reg, vf27_reg, vf28_reg, vf29_reg, vf30_reg, vf31_reg;
  wire   vf0_wr,  vf1_wr,  vf2_wr,  vf3_wr,  vf4_wr,  vf5_wr,  vf6_wr,  vf7_wr;
  wire   vf8_wr,  vf9_wr,  vf10_wr, vf11_wr, vf12_wr, vf13_wr, vf14_wr, vf15_wr;
  wire   vf16_wr, vf17_wr, vf18_wr, vf19_wr, vf20_wr, vf21_wr, vf22_wr, vf23_wr;
  wire   vf24_wr, vf25_wr, vf26_wr, vf27_wr, vf28_wr, vf29_wr, vf30_wr, vf31_wr;
  wire   vf_sel, pf0_sel, pf0_wr;


///========================================== 
/// CFG control derived from inputs
///========================================== 
  assign rxm_addr    = RxmAddress_0_i; //byte address
  assign rxm_rden    = RxmRead_0_i;
  assign rxm_wren    = RxmWrite_0_i;
  assign rxm_wdata   = RxmWriteData_0_i;
  assign rxm_be      = RxmByteEnable_0_i;
  assign vf_sel  = (rxm_bar_hit_fn_tlp0_i[7:5]== 3'h1);
  assign pf0_sel = (rxm_bar_hit_fn_tlp0_i[7:5]== 3'h0);
  assign pf0_wr  = (rxm_bar_hit_fn_tlp0_i[7:0]== 8'h0) & rxm_wren;
  
//==================================
// Derive target address
//==================================
assign tgt_dw_addr = rxm_addr[AVALON_WADDR-1: 2]; 

//==================================
// Func0 register0
//==================================
always @(posedge Clk_i or negedge Rstn_i) begin
    if(~Rstn_i) begin
       f0_reg0    <= 32'h0;
    end else if (pf0_wr & (tgt_dw_addr == F0_REG0_ADDR)) begin
       f0_reg0[31:24]  <= rxm_be[3] ? rxm_wdata[31:24] : f0_reg0[31:24];
       f0_reg0[23:16]  <= rxm_be[2] ? rxm_wdata[23:16] : f0_reg0[31:24];
       f0_reg0[16: 8]  <= rxm_be[1] ? rxm_wdata[15: 8] : f0_reg0[15: 8];
       f0_reg0[ 7: 0]  <= rxm_be[0] ? rxm_wdata[ 7: 0] : f0_reg0[ 7: 0];
    end
end

//==================================
// Func0 registers
//==================================
always @(posedge Clk_i or negedge Rstn_i) begin
    if(~Rstn_i) begin
       f0_reg1    <= 32'h0;
    end else if (pf0_wr & (tgt_dw_addr == F0_REG1_ADDR)) begin
       f0_reg1[31:24]  <= rxm_be[3] ? rxm_wdata[31:24] : f0_reg1[31:24];
       f0_reg1[23:16]  <= rxm_be[2] ? rxm_wdata[23:16] : f0_reg1[31:24];
       f0_reg1[16: 8]  <= rxm_be[1] ? rxm_wdata[15: 8] : f0_reg1[15: 8];
       f0_reg1[ 7: 0]  <= rxm_be[0] ? rxm_wdata[ 7: 0] : f0_reg1[ 7: 0];
    end
end
//=========================
// VF write
wire any_bar_hit = |(rxm_bar_hit_tlp0_i) ;

assign vf0_wr  =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd0)  & any_bar_hit & rxm_wren;
assign vf1_wr  =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd1)  & any_bar_hit & rxm_wren;
assign vf2_wr  =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd2)  & any_bar_hit & rxm_wren;
assign vf3_wr  =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd3)  & any_bar_hit & rxm_wren;
assign vf4_wr  =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd4)  & any_bar_hit & rxm_wren;
assign vf5_wr  =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd5)  & any_bar_hit & rxm_wren;
assign vf6_wr  =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd6)  & any_bar_hit & rxm_wren;
assign vf7_wr  =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd7)  & any_bar_hit & rxm_wren;
assign vf8_wr  =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd8)  & any_bar_hit & rxm_wren;
assign vf9_wr  =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd9)  & any_bar_hit & rxm_wren;
assign vf10_wr =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd10) & any_bar_hit & rxm_wren;
assign vf11_wr =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd11) & any_bar_hit & rxm_wren;
assign vf12_wr =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd12) & any_bar_hit & rxm_wren;
assign vf13_wr =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd13) & any_bar_hit & rxm_wren;
assign vf14_wr =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd14) & any_bar_hit & rxm_wren;
assign vf15_wr =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd15) & any_bar_hit & rxm_wren;
assign vf16_wr =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd16) & any_bar_hit & rxm_wren;
assign vf17_wr =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd17) & any_bar_hit & rxm_wren;
assign vf18_wr =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd18) & any_bar_hit & rxm_wren;
assign vf19_wr =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd19) & any_bar_hit & rxm_wren;
assign vf20_wr =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd20) & any_bar_hit & rxm_wren;
assign vf21_wr =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd21) & any_bar_hit & rxm_wren;
assign vf22_wr =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd22) & any_bar_hit & rxm_wren;
assign vf23_wr =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd23) & any_bar_hit & rxm_wren;
assign vf24_wr =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd24) & any_bar_hit & rxm_wren;
assign vf25_wr =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd25) & any_bar_hit & rxm_wren;
assign vf26_wr =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd26) & any_bar_hit & rxm_wren;
assign vf27_wr =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd27) & any_bar_hit & rxm_wren;
assign vf28_wr =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd28) & any_bar_hit & rxm_wren;
assign vf29_wr =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd29) & any_bar_hit & rxm_wren;
assign vf30_wr =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd30) & any_bar_hit & rxm_wren;
assign vf31_wr =  vf_sel & (rxm_bar_hit_fn_tlp0_i[4:0] == 5'd31) & any_bar_hit & rxm_wren;

//=========================
// VF Registers
//=========================

vf_reg vf0_reg_i  (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf0_wr,  vf0_reg);
vf_reg vf1_reg_i  (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf1_wr,  vf1_reg);
vf_reg vf2_reg_i  (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf2_wr,  vf2_reg);
vf_reg vf3_reg_i  (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf3_wr,  vf3_reg);
vf_reg vf4_reg_i  (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf4_wr,  vf4_reg);
vf_reg vf5_reg_i  (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf5_wr,  vf5_reg);
vf_reg vf6_reg_i  (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf6_wr,  vf6_reg);
vf_reg vf7_reg_i  (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf7_wr,  vf7_reg);
vf_reg vf8_reg_i  (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf8_wr,  vf8_reg);
vf_reg vf9_reg_i  (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf9_wr,  vf9_reg);
vf_reg vf10_reg_i (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf10_wr, vf10_reg);
vf_reg vf11_reg_i (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf11_wr, vf11_reg);
vf_reg vf12_reg_i (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf12_wr, vf12_reg);
vf_reg vf13_reg_i (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf13_wr, vf13_reg);
vf_reg vf14_reg_i (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf14_wr, vf14_reg);
vf_reg vf15_reg_i (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf15_wr, vf15_reg);
vf_reg vf16_reg_i (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf16_wr, vf16_reg);
vf_reg vf17_reg_i (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf17_wr, vf17_reg);
vf_reg vf18_reg_i (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf18_wr, vf18_reg);
vf_reg vf19_reg_i (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf19_wr, vf19_reg);
vf_reg vf20_reg_i (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf20_wr, vf20_reg);
vf_reg vf21_reg_i (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf21_wr, vf21_reg);
vf_reg vf22_reg_i (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf22_wr, vf22_reg);
vf_reg vf23_reg_i (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf23_wr, vf23_reg);
vf_reg vf24_reg_i (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf24_wr, vf24_reg);
vf_reg vf25_reg_i (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf25_wr, vf25_reg);
vf_reg vf26_reg_i (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf26_wr, vf26_reg);
vf_reg vf27_reg_i (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf27_wr, vf27_reg);
vf_reg vf28_reg_i (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf28_wr, vf28_reg);
vf_reg vf29_reg_i (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf29_wr, vf29_reg);
vf_reg vf30_reg_i (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf30_wr, vf30_reg);
vf_reg vf31_reg_i (Clk_i, Rstn_i, rxm_be, rxm_wdata, vf31_wr, vf31_reg);

//=========================
// Read data 
//=========================
always @(posedge Clk_i or negedge Rstn_i) begin
    if(~Rstn_i)   rxm_rddatavalid_r <= 1'b0;
    else          rxm_rddatavalid_r <= rxm_rden; 
end

always @(posedge Clk_i or negedge Rstn_i) begin
    if(~Rstn_i)         rxm_rdata_r <= 32'b0;
    else if (rxm_rden & pf0_sel) begin
      case (tgt_dw_addr[6:2])
        F0_REG0_ADDR:   rxm_rdata_r <= f0_reg0;
        F0_REG1_ADDR:   rxm_rdata_r <= f0_reg1;
        default:        rxm_rdata_r <= 32'h0;
      endcase  
    end else if (rxm_rden & vf_sel) begin
      case (rxm_bar_hit_fn_tlp0_i[4:0])
        VF0_REG_ADDR:   rxm_rdata_r <= vf0_reg;
        VF1_REG_ADDR:   rxm_rdata_r <= vf1_reg;
        VF2_REG_ADDR:   rxm_rdata_r <= vf2_reg;
        VF3_REG_ADDR:   rxm_rdata_r <= vf3_reg;
        VF4_REG_ADDR:   rxm_rdata_r <= vf4_reg;
        VF5_REG_ADDR:   rxm_rdata_r <= vf5_reg;
        VF6_REG_ADDR:   rxm_rdata_r <= vf6_reg;
        VF7_REG_ADDR:   rxm_rdata_r <= vf7_reg;
        VF8_REG_ADDR:   rxm_rdata_r <= vf8_reg;
        VF9_REG_ADDR:   rxm_rdata_r <= vf9_reg;
        VF10_REG_ADDR:  rxm_rdata_r <= vf10_reg;
        VF11_REG_ADDR:  rxm_rdata_r <= vf11_reg;
        VF12_REG_ADDR:  rxm_rdata_r <= vf12_reg;
        VF13_REG_ADDR:  rxm_rdata_r <= vf13_reg;
        VF14_REG_ADDR:  rxm_rdata_r <= vf14_reg;
        VF15_REG_ADDR:  rxm_rdata_r <= vf15_reg;
        VF16_REG_ADDR:  rxm_rdata_r <= vf16_reg;
        VF17_REG_ADDR:  rxm_rdata_r <= vf17_reg;
        VF18_REG_ADDR:  rxm_rdata_r <= vf18_reg;
        VF19_REG_ADDR:  rxm_rdata_r <= vf19_reg;
        VF20_REG_ADDR:  rxm_rdata_r <= vf20_reg;
        VF21_REG_ADDR:  rxm_rdata_r <= vf21_reg;
        VF22_REG_ADDR:  rxm_rdata_r <= vf22_reg;
        VF23_REG_ADDR:  rxm_rdata_r <= vf23_reg;
        VF24_REG_ADDR:  rxm_rdata_r <= vf24_reg;
        VF25_REG_ADDR:  rxm_rdata_r <= vf25_reg;
        VF26_REG_ADDR:  rxm_rdata_r <= vf26_reg;
        VF27_REG_ADDR:  rxm_rdata_r <= vf27_reg;
        VF28_REG_ADDR:  rxm_rdata_r <= vf28_reg;
        VF29_REG_ADDR:  rxm_rdata_r <= vf29_reg;
        VF30_REG_ADDR:  rxm_rdata_r <= vf30_reg;
        VF31_REG_ADDR:  rxm_rdata_r <= vf31_reg;
        default:        rxm_rdata_r <= 32'h0;
      endcase
    end else begin
      rxm_rdata_r <= 32'h0;
    end
end

//=========================
// Output registers
//=========================
   assign RxmWaitRequest_0_o     = 1'b0;
   assign RxmReadData_0_o        = rxm_rdata_r;          
   assign RxmReadDataValid_0_o   = rxm_rddatavalid_r;     


endmodule

//=========================
// VF Register
//=========================
module vf_reg (
   input              Clk_i,
   input              Rstn_i,
   input  [3:0]       wr_be_i,
   input  [31:0]      wdata_i,
   input              wr_en_i,
   output [31:0]      data_o
);   
  reg [31:0] data_reg;

  always @(posedge Clk_i or negedge Rstn_i) begin
    if(~Rstn_i) begin
       data_reg    <= 32'h0;
    end else if (wr_en_i) begin
       data_reg[31:24]  <= wr_be_i[3] ? wdata_i[31:24] : data_reg[31:24];
       data_reg[23:16]  <= wr_be_i[2] ? wdata_i[23:16] : data_reg[31:24];
       data_reg[16: 8]  <= wr_be_i[1] ? wdata_i[15: 8] : data_reg[15: 8];
       data_reg[ 7: 0]  <= wr_be_i[0] ? wdata_i[ 7: 0] : data_reg[ 7: 0];
    end
  end

  assign data_o = data_reg;

endmodule

