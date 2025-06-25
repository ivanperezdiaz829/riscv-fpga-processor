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


module altpcieav_cra 
  (
      input logic                                   Clk_i,
      input logic                                   Rstn_i,
      
      input  logic                                  CraChipSelect_i,
      input  logic                                  CraRead_i,           
      input  logic                                  CraWrite_i,          
      input  logic  [9:0]                           CraAddress_i,
      input  logic  [31:0]                          CraWriteData_i,
      input  logic  [3:0]                           CraByteEnable_i,
      output logic                                  CraWaitRequest_o,
      output logic  [31:0]                          CraReadData_o,     
      input  logic  [31:0]                          CurrentRdID_i,
      input  logic  [31:0]                          CurrentWrID_i,
      output                                        RdDMACntrlLoad_o,
      output logic [3:0]                            RdDMACntrlData_o,
      output                                        WrDMACntrlLoad_o,
      output logic [3:0]                            WrDMACntrlData_o,
      input  logic  [31:0]                          PciCmd_i,
      input  logic  [31:0]                          MsiDataCrl_i,
      input  logic  [31:0]                          MsiAddrLow_i,
      input  logic  [31:0]                          MsiAddrHi_i,
      input  logic  [31:0]                          MsiXCtrl_i,  
      input  logic  [31:0]                          LinkStatus_i
   );

logic  [15:0]                     addr_decode;
logic                             rd_cntrl_wrena;
logic                             wr_cntrl_wrena;
logic  [31:0]                     reg_mux_out;
logic                             register_ready_reg;
logic  [31:0]                     rd_cntrl_reg;
logic  [31:0]                     wr_cntrl_reg;
logic                             register_access;
logic                             register_access_sreg;
logic                             register_access_reg;
logic                             register_access_rise;  
logic  [31:0]                     read_data_reg;  



always_comb
  begin
  case (CraAddress_i)
     10'h000 : addr_decode[15:0] = 10'b00_0000_0001;
     10'h004 : addr_decode[15:0] = 10'b00_0000_0010;
     10'h008 : addr_decode[15:0] = 10'b00_0000_0100;
     10'h00C : addr_decode[15:0] = 10'b00_0000_1000;
     10'h010 : addr_decode[15:0] = 10'b00_0001_0000;
     10'h014 : addr_decode[15:0] = 10'b00_0010_0000;
     10'h100 : addr_decode[15:0] = 10'b00_0100_0000;
     10'h104 : addr_decode[15:0] = 10'b00_1000_0000;
     10'h200 : addr_decode[15:0] = 10'b01_0000_0000;
     10'h204 : addr_decode[15:0] = 10'b10_0000_0000;
     default : addr_decode[15:0] = 10'b00_0000_0001;
    endcase
  end   
   
assign  rd_cntrl_wrena          =  addr_decode[6] & CraWrite_i & CraChipSelect_i;        
assign  wr_cntrl_wrena          =  addr_decode[8] & CraWrite_i & CraChipSelect_i;   
  
// Read decode mux
always_comb
  begin
  case (addr_decode)
     10'b00_0000_0001: reg_mux_out = PciCmd_i;
     10'b00_0000_0010: reg_mux_out = MsiDataCrl_i;
     10'b00_0000_0100: reg_mux_out = MsiAddrLow_i;
     10'b00_0000_1000: reg_mux_out = MsiAddrHi_i;
     10'b00_0001_0000: reg_mux_out = MsiXCtrl_i;
     10'b00_0010_0000: reg_mux_out = LinkStatus_i;
     10'b00_0100_0000: reg_mux_out = rd_cntrl_reg;
     10'b00_1000_0000: reg_mux_out = CurrentRdID_i;
     10'b01_0000_0000: reg_mux_out = wr_cntrl_reg;                                             
     10'b10_0000_0000: reg_mux_out = CurrentWrID_i;                                          
     default :         reg_mux_out = 32'h0;
    endcase
  end   
  
/// Register definition

assign WrDMACntrlLoad_o = wr_cntrl_wrena & register_ready_reg;
assign RdDMACntrlLoad_o = rd_cntrl_wrena & register_ready_reg;

// Rd Control
always_ff @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      rd_cntrl_reg <= 32'h0;
    else if(rd_cntrl_wrena)
      rd_cntrl_reg <= CraWriteData_i;
    else if(RdDMACntrlLoad_o)
      rd_cntrl_reg <= 32'h0; 
  end   

// Wr Control
always_ff @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      wr_cntrl_reg <= 32'h0;
    else if(wr_cntrl_wrena)
      wr_cntrl_reg <= CraWriteData_i;
    else if(RdDMACntrlLoad_o)
      wr_cntrl_reg <= 32'h0; 
  end     
  
always_ff @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      read_data_reg <= 32'h0;
    else if( CraRead_i & CraChipSelect_i)
      read_data_reg <= reg_mux_out;
    else
      read_data_reg <= 32'h0;
  end   


always_ff @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      register_access_sreg <= 1'b0;
    else if (register_ready_reg)
      register_access_sreg <= 1'b0;
     else if( (CraRead_i | CraWrite_i) & CraChipSelect_i)
      register_access_sreg <= 1'b1;
  end   
  
assign register_access = register_access_sreg;

always_ff @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      register_access_reg <= 1'b0;
    else
      register_access_reg <= register_access;
  end   
  
assign register_access_rise = ~register_access_reg & register_access;

always_ff @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      register_ready_reg <= 1'b0;
    else
      register_ready_reg <= register_access_rise;
  end   

assign CraWaitRequest_o = ~register_ready_reg;

assign CraReadData_o = read_data_reg;

assign RdDMACntrlData_o = rd_cntrl_reg[3:0];
assign WrDMACntrlData_o = wr_cntrl_reg[3:0];

endmodule
  