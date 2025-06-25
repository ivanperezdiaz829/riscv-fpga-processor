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


//---------------------------------------------------------------------
task avalon_write_embed;
  input integer address;
  input integer data;

  integer TB_AVALON_TIMEOUT;
  integer break;
  reg [5:0] temp_address;
  reg [7:0] temp_data;
begin
  TB_AVALON_TIMEOUT = 1000;
  temp_address = address;
  temp_data = data;   

  @(posedge reg_clk);
  #1;
  reg_base_addr = temp_address;
  reg_burstcount = 0;
  reg_write_embed = 1'b1;
  reg_writedata = temp_data;
  reg_read_embed = 1'b0;

  @(posedge reg_clk);
  #1;

  break = 0;
  while (break < TB_AVALON_TIMEOUT && reg_waitrequest_embed == 1'b1) begin
    @(posedge reg_clk);
    #1;
    break = break + 1;
  end
      
  reg_write_embed = 0;
  reg_base_addr = 0;
  reg_writedata = 0;

end
endtask

//---------------------------------------------------------------------
task avalon_write_extract;
  input integer address;
  input integer data;

  integer TB_AVALON_TIMEOUT;
  integer break;
  reg [5:0] temp_address;
  reg [7:0] temp_data;
begin
  TB_AVALON_TIMEOUT = 1000;
  temp_address = address;
  temp_data = data;   

  @(posedge reg_clk);
  #1;
  reg_base_addr = temp_address;
  reg_burstcount = 0;
  reg_write_extract = 1'b1;
  reg_writedata = temp_data;
  reg_read_extract = 1'b0;

  @(posedge reg_clk);
  #1;

  break = 0;
  while (break < TB_AVALON_TIMEOUT && reg_waitrequest_extract == 1'b1) begin
    @(posedge reg_clk);
    #1;
    break = break + 1;
  end
      
  reg_write_extract = 0;
  reg_base_addr = 0;
  reg_writedata = 0;

end
endtask

task avalon_read_extract;
  input integer address;
  inout integer data;

  reg [5:0] temp_address;
begin
  temp_address = address;

  @(posedge reg_clk);
  #1;
  reg_base_addr = temp_address;
  reg_burstcount = 0;
  reg_write_extract = 1'b0;
  reg_writedata = 0;
  reg_read_extract = 1'b1;
  @(posedge reg_clk);
  #1;
  reg_read_extract = 1'b0;
  @(posedge reg_clk);
  #1;
  reg_base_addr = 0;
  data = reg_readdata_extract;
  #1;
  
end
endtask

//---------------------------------------------------------------------
task avalon_write_cai;
  input integer address;
  input integer data;

  integer TB_AVALON_TIMEOUT;
  integer break;
  reg [5:0] temp_address;
  reg [7:0] temp_data;
begin
  TB_AVALON_TIMEOUT = 1000;
  temp_address = address;
  temp_data = data;   

  @(posedge reg_clk);
  #1;
  reg_base_addr = temp_address;
  reg_burstcount = 0;
  reg_write_cai = 1'b1;
  reg_writedata = temp_data;
  reg_read_cai = 1'b0;

  @(posedge reg_clk);
  #1;

  break = 0;
  while (break < TB_AVALON_TIMEOUT && reg_waitrequest_cai == 1'b1) begin
    @(posedge reg_clk);
    #1;
    break = break + 1;
  end
      
  reg_write_cai = 0;
  reg_base_addr = 0;
  reg_writedata = 0;

end
endtask

task avalon_read_cai;
  input integer address;
  inout integer data;

  reg [5:0] temp_address;
begin
  temp_address = address;

  @(posedge reg_clk);
  #1;
  reg_base_addr = temp_address;
  reg_burstcount = 0;
  reg_write_cai = 1'b0;
  reg_writedata = 0;
  reg_read_cai = 1'b1;
  @(posedge reg_clk);
  #1;
  reg_read_cai = 1'b0;
  @(posedge reg_clk);
  #1;
  reg_base_addr = 0;
  data = reg_readdata_cai;
  #1;
  
end
endtask

//---------------------------------------------------------------------
task avalon_write_cao;
  input integer address;
  input integer data;

  integer TB_AVALON_TIMEOUT;
  integer break;
  reg [5:0] temp_address;
  reg [7:0] temp_data;
begin
  TB_AVALON_TIMEOUT = 1000;
  temp_address = address;
  temp_data = data;   

  @(posedge reg_clk);
  #1;
  reg_base_addr = temp_address;
  reg_burstcount = 0;
  reg_write_cao = 1'b1;
  reg_writedata = temp_data;
  reg_read_cao = 1'b0;

  @(posedge reg_clk);
  #1;

  break = 0;
  while (break < TB_AVALON_TIMEOUT && reg_waitrequest_cao == 1'b1) begin
    @(posedge reg_clk);
    #1;
    break = break + 1;
  end
      
  reg_write_cao = 0;
  reg_base_addr = 0;
  reg_writedata = 0;

end
endtask

task avalon_read_cao;
  input integer address;
  inout integer data;

  reg [5:0] temp_address;
begin
  temp_address = address;

  @(posedge reg_clk);
  #1;
  reg_base_addr = temp_address;
  reg_burstcount = 0;
  reg_write_cao = 1'b0;
  reg_writedata = 0;
  reg_read_cao = 1'b1;
  @(posedge reg_clk);
  #1;
  reg_read_cao = 1'b0;
  @(posedge reg_clk);
  #1;
  reg_base_addr = 0;
  data = reg_readdata_cao;
  #1;
  
end
endtask

//---------------------------------------------------------------------
task avalon_read_extract_avalon;
  input integer address;
  inout integer data;
    
  reg [5:0] temp_address;
begin
  temp_address = address;

  @(posedge reg_clk);
  #1;
  reg_base_addr = temp_address;
  reg_burstcount = 0;
  reg_write_extract = 1'b0;
  reg_writedata = 0;
  reg_read_extract = 1'b1;
  @(posedge reg_clk);
  #1;
  reg_read_extract = 1'b0;
  @(posedge reg_clk);
  #1;
  reg_base_addr = 0;
  data = reg_readdata_extract_avalon;
  #1;
  
end
endtask
