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

module audio_test_source (
  aud_clk,
  aud_clk48,
  aud_reset,

  aud_de,
  aud_ws,
  aud_data);

  //local parameters
  localparam [191:0] cs = {8'b10011011 , 8'b00000000 , 8'b00000000 , 8'b00000000 ,
                           8'b00000000 , 8'b00000000 , 8'b00000000 , 8'b00000000 ,
                           8'b00000000 , 8'b00000000 , 8'b00000000 , 8'b00000000 ,
                           8'b00000000 , 8'b00000000 , 8'b00000000 , 8'b00000000 ,
                           8'b00000000 , 8'b00000000 , 8'b00000000 , 8'b00000010 ,
                           8'b00000000 , 8'b00000000 , 8'b00000010 , 8'b00111101};

  input aud_clk;
  input aud_clk48;
  input aud_reset;
  output aud_de;
  wire aud_de;
  output aud_ws;
  wire aud_ws;
  output aud_data;
  wire aud_data;

  wire csb;
  reg aud_clk48_d1;
  reg aud_clk48_d2;
  reg aud_start_delay = 1'b0;
  reg aud_start_delayed = 1'b0;
  reg [7:0] aud_zcount = 190; //{8{1'b0}};
  wire aud_p;
  reg aud_z = 1'b1;
  reg [18:0] aud_sample = {8{1'b0}};
  reg [5:0] aud_count = {8{1'b1}};
  wire [31:0] aud_word;
  reg aud_ws_int = 1'b0;

//------------------------------------------------------------------------------
//MODULE BODY
//------------------------------------------------------------------------------

  always @(posedge aud_clk)
  begin
    begin
      if (aud_reset == 1'b1) begin
        aud_clk48_d1 <= 1'b0;
        aud_clk48_d2 <= 1'b0;
      end else begin
        aud_clk48_d1 <= aud_clk48;
        aud_clk48_d2 <= aud_clk48_d1;
      end
    end
  end

  always @(posedge aud_clk)
  begin
    begin
      if (aud_reset == 1'b1) begin
        aud_start_delay <= 1'b0;
        aud_start_delayed <= 1'b0;
      end else if (aud_clk48_d1 == 1'b1 && aud_clk48_d2 == 1'b0) begin
        aud_start_delay <= 1'b1;
        aud_start_delayed <= aud_start_delay;
      end
    end
  end

  always @(posedge aud_clk)
  begin
    begin
      if (aud_reset == 1'b1) begin
        aud_sample <= {19{1'b0}};
        aud_zcount <= {8{1'b0}};
        aud_z <= 1'b1;
      end else if (aud_clk48_d1 == 1'b0 && aud_clk48_d2 == 1'b1 && aud_start_delayed == 1'b1) begin
        aud_sample <= aud_sample + 19'd1;
        if (aud_zcount == 191) begin
          aud_zcount <= {8{1'b0}};
          aud_z <= 1'b1;
        end else begin
          aud_zcount <= aud_zcount + 8'd1;
          aud_z <= 1'b0;
        end
      end
    end
  end

  assign csb = cs[aud_zcount];

  assign aud_p = csb ^
           aud_clk48_d2   ^ aud_sample[3] ^ aud_sample[2] ^ aud_sample[1] ^ aud_sample[0] ^ aud_sample[18] ^ aud_sample[17] ^ aud_sample[16] ^
           aud_sample[15] ^ aud_sample[14] ^ aud_sample[13] ^ aud_sample[12] ^ aud_sample[11] ^ aud_sample[10] ^ aud_sample[9 ] ^ aud_sample[8 ] ^
           aud_sample[7 ] ^ aud_sample[6 ] ^ aud_sample[5 ] ^ aud_sample[4 ] ^ aud_sample[3 ] ^ aud_sample[2 ] ^ aud_sample[1 ] ^ aud_sample[0 ];

  assign aud_word = {aud_p , csb , 2'b00 , aud_clk48_d2 , aud_sample , aud_sample[3:0] , 2'b00 , (aud_z & ~ aud_clk48_d2) , aud_clk48_d2};

  always @(posedge aud_clk)
  begin
    begin
      if (aud_reset == 1'b1) begin
        aud_count <= {6{1'b1}};
      end else if (aud_clk48_d1 != aud_clk48_d2 && aud_start_delay == 1'b1) begin
        aud_count <= {6{1'b0}};
      end else if (aud_count[5] == 1'b0) begin
          aud_count <= aud_count + 6'd1;
      end
    end
  end

  always @(posedge aud_clk)
  begin
    begin
      if (aud_reset == 1'b1) begin
        aud_ws_int <= 1'b0;
      end else if (aud_count[4:0] == 5'b11110) begin
        aud_ws_int <= ~ aud_clk48_d2;
      end
    end
  end

  assign aud_de = (~ aud_count[5]) & (~ aud_reset);
  assign aud_ws = aud_ws_int;
  assign aud_data = aud_word[aud_count[4:0]];

endmodule
