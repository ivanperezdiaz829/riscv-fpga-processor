//--------------------------------------------------------------------------------------------------
// (c)2008 Altera Corporation. All rights reserved.
//
// Altera products are protected under numerous U.S. and foreign patents,
// maskwork rights, copyrights and other intellectual property laws.
//
// This reference design file, and your use thereof, is subject to and governed
// by the terms and conditions of the applicable Altera Reference Design License
// Agreement (either as signed by you or found at www.altera.com).  By using
// this reference design file, you indicate your acceptance of such terms and
// conditions between you and Altera Corporation.  In the event that you do not
// agree with such terms and conditions, you may not use the reference design
// file and please promptly destroy any copies you have made.
//
// This reference design file is being provided on an "as-is" basis and as an
// accommodation and therefore all warranties, representations or guarantees of
// any kind (whether express, implied or statutory) including, without
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or
// require that this reference design file be used in combination with any
// other product not provided by Altera.
//--------------------------------------------------------------------------------------------------


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
