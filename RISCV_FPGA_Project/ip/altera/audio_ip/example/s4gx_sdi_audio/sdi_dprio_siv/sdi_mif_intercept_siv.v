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


module sdi_mif_intercept_siv 
  (
   input  [5:0]         reconfig_address,
   input  [15:0]        rom_data_in,
   input                select_hd,
   input [3:0]          rcru_m,
   output [15:0]        rom_data_out   
  );

   reg [15:0]          rom_data_out_int;


// Only one word has to chage between HD and 3G, this code simply intercepts that
// word out of the 3G rom and replaces it with the HD value.
always @ (*)
  begin
     if (reconfig_address == 6'd29) begin
        if (select_hd == 1'b1) begin
           rom_data_out_int <= rom_data_in;
           rom_data_out_int[12:7] <= 6'b001101;
        end
        else begin
           rom_data_out_int <= rom_data_in;
           rom_data_out_int[12:7] <= 6'b010100;
        end // else: !if(select_hd == 1'b1)

     end // if (reconfig_address == 6'd29)
     else
     rom_data_out_int <= rom_data_in;
  end // always @ (*)
   

  assign rom_data_out = rom_data_out_int;
   
   
endmodule
