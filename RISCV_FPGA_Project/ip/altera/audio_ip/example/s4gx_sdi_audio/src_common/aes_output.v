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



`timescale 1 ps / 1 ps

module aes_output (
  aud_clk,
  aud_ws,
  aud_data,
  aes_data);

  input aud_clk;
  input aud_ws;
  input aud_data;
  output aes_data;
  wire aes_data;

  reg aud_ws_d1;
  reg aud_data_d1;
  reg [4:0] aes_sample_count;
  reg [7:0] aes_preamble;
  reg bpm_parity;
  reg [0:0] aes_data_l;
  reg [0:0] aes_data_h;
  wire [0:0] aes_data_vec;

//------------------------------------------------------------------------------
//MODULE BODY
//------------------------------------------------------------------------------

  //---------------------------------------------------------------------------
  // Track Data So We Can Replace The Preamble
  //---------------------------------------------------------------------------
  always @(posedge aud_clk)
  begin
    begin
      aud_ws_d1 <= aud_ws;
      if (aud_ws != aud_ws_d1) begin
        aes_sample_count <= {5{1'b0}};
      end else begin
        aes_sample_count <= aes_sample_count + 5'd1;
      end
    end
  end

  always @(posedge aud_clk)
  begin
    begin
      aud_data_d1 <= aud_data;
      if (aes_sample_count == 5'b00001) begin
        if (aud_data_d1 == 1'b0 && aud_data ==  1'b0) begin //X
          aes_preamble <= 8'b01000111;
        end else if (aud_data_d1 == 1'b1) begin //Y
          aes_preamble <= 8'b00100111;
        end else begin
          aes_preamble <= 8'b00010111;
        end
      end
      if (aes_sample_count == 5'b11111) begin
        bpm_parity <= aes_data_l[0] ^ (~ aud_data);
      end
    end
  end

  always @(posedge aud_clk)
  begin
    begin
      if (aes_sample_count[4:2] == 3'b000) begin
        aes_data_h[0] <= bpm_parity ^ aes_preamble[{aes_sample_count[1:0] , 1'b0}];
        aes_data_l[0] <= bpm_parity ^ aes_preamble[{aes_sample_count[1:0] , 1'b1}];
      end else begin
        aes_data_h[0] <= ~ aes_data_l[0]; //first word always toggles
        aes_data_l[0] <= aes_data_l[0] ^ (~ aud_data);
      end
    end
  end

  //---------------------------------------------------------------------------
  // USE DDR PRIMITIVE OUT
  //---------------------------------------------------------------------------
  altddio_out #(
    .extend_oe_disable       ("UNUSED"),
    .intended_device_family  ("Arria II GX"),
    .lpm_type                ("altddio_out"),
    .oe_reg                  ("UNUSED"),
    .power_up_high           ("OFF"),
    .width                   (1))
  altddio_out_component(
    .datain_h                (aes_data_h),
    .datain_l                (aes_data_l),
    .outclock                (aud_clk),
    .outclocken              (1'b1),
    .aset                    (1'b0),
    .aclr                    (1'b0),
    .sset                    (1'b0),
    .sclr                    (1'b0),
    .oe                      (1'b1),
    .dataout                 (aes_data_vec),
    .oe_out                  ());

  assign aes_data = aes_data_vec[0];

endmodule
