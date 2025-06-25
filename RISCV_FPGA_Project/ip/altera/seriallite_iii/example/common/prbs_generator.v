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


//-----------------------------------------------------------------------------
// Title         : prbs_generator
//-----------------------------------------------------------------------------
// File          : prbs_generator.v
// Supported Patterns - 7, 10, 23, 31
// Supported Data widths = 8, 10, 16, 20, 32, 40, 64
//-----------------------------------------------------------------------------

module prbs_generator 
#(
  parameter PRBS_INITIAL_VALUE = 97,
  parameter DATA_WIDTH = 8,
  parameter PRBS = 23,
  parameter XAUI_PATTERN = 97
  )(clk, 
    nreset,
    xaui_word_align,
    dout, 
    insert_error,
    pause);
    output [DATA_WIDTH-1:0] dout;
    input          clk;
    input          xaui_word_align;
    input          nreset;
    input          insert_error;
    input          pause;  
       
    reg [DATA_WIDTH-1:0]    dout_reg;
    wire [DATA_WIDTH-1:0]   data_wire;
    
    always@(posedge clk or negedge nreset)begin
   if(~nreset)begin
       dout_reg  <= PRBS_INITIAL_VALUE;
   end
   else if(~xaui_word_align)begin
       dout_reg <= XAUI_PATTERN;
   end
   else begin
      if (!pause)
        dout_reg <= data_wire;
   end
       
    end
    assign     dout   = dout_reg;
       
   prbs_poly atso_prbs_poly_inst(.clk(clk),
                  .data_in(dout),
                  .insert_error(insert_error),
                  .dout(data_wire),
                  .nreset(nreset)
             );
   defparam   atso_prbs_poly_inst.DATA_WIDTH = DATA_WIDTH;
   defparam   atso_prbs_poly_inst.PRBS = PRBS;
   
   
endmodule
