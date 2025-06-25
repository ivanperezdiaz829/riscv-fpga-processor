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


`timescale 1 ns / 1 ps

module alt_xcvr_interlaken_amm_slave #(
		   parameter nsigs = 16,        //lpm_size
		   parameter nsigs_w = 4,       // address width
		   parameter dwid = 32          // data width
		   ) (
    input clk,
    input reset,
    input write,
    input [nsigs_w-1:0] address,
    input [dwid-1:0] 	datain,
    output reg [dwid-1:0] dataout,

    input [(dwid*nsigs)-1:0] busin,
    output [(dwid*nsigs)-1:0] busout
		      );

   reg [(dwid*nsigs)-1:0]     outreg /* synthesis altera_attribute="PRESERVE_REGISTER=ON;POWER_UP_LEVEL=LOW" */;
   assign busout = outreg;

   wire [dwid-1:0] 	      mux_dataout;


// use LPM_MUX for Quartus Synthesis and ilk_mux for simulation
`ifdef ALTERA_RESERVED_QIS   
   lpm_mux	#(             // for synthesis use lpm_mux
`else
   ilk_mux	#(            // for simulation use ilk_mux
`endif
		   .lpm_size(nsigs),
		  .lpm_type("LPM_MUX"),

		  .lpm_width(dwid),
		  .lpm_widths(nsigs_w)
		  ) lpm_mux_component (
		  		       .sel (address),
				       .data (busin),
				       .result (mux_dataout)
				       // synopsys translate_off
				       ,.aclr (),.clken (),.clock ()
				       // synopsys translate_on
				       );

   
   wire [nsigs-1:0] 	      enables;
   lpm_decode #(
		.lpm_decodes(nsigs),
		.lpm_type("LPM_DECODE"),
		.lpm_width(nsigs_w)
		) lpm_decode_component (
					.data (address),
					.eq (enables)
					// synopsys translate_off
					,.aclr (),.clken (),.clock (),.enable ()
					// synopsys translate_on
					);
   wire [(dwid*nsigs)-1:0]    big_enables;
   
   genvar 		      s;
   generate
      for(s = 0; s < nsigs; s = s + 1) begin: assign_enables
	 assign big_enables[(s*dwid)+(dwid-1):(s*dwid)] = {dwid{enables[s]}};
      end
   endgenerate

   always @(posedge clk) begin
      if (reset) begin
	 dataout <= 1'b0;
	 outreg <= {(dwid*nsigs){1'b0}};
      end
      else begin
	 dataout <= mux_dataout;
	 //outreg <= {nsigs{1'b0}};
	 if (write) begin
	    outreg <= (big_enables & {nsigs{datain}}) | ((~big_enables) & outreg);
	 end
      end
   end

endmodule



