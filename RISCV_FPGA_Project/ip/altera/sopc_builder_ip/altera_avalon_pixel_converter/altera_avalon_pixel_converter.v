////////////////////////////////////////////////////////////////
//
// Video Pixel Converter
//     (altera_avalon_pixel_converter.v)
//
// Author: wwkong
//
// OVERVIEW
//     This core converts 32-bit data in the format of B-G-R-0 to 24-bit data
//     of format B-G-R by discarding the Least Significant Byte (LSB)
//
// DEPLOYMENT
//     This core is implemented as an SOPC Builder component with a
//     single Avalon-ST data-sink (input) and Avalon-ST data-source
//     (output) signals. An associated TCL Metadata file declares this
//     core and  its interfaces for use in an SOPC Builder system.
//         
// PLACEMENT IN A SYSTEM
//     The outputs from this core can directly drive an LCD display
//     module.  The input is a sequential stream of 32-bit pixel-data in
//     "BGR0".  The output is a sequential stream of 24-bit pixel-data in "BGR".
//
// PARAMETERS
//     No parameter
//
// Typical system
//
//           +--------+        
//           |        |        
//   B,G,R,0 |  This  |  B,G,R  
//   ----/-->|  Core  |----/-->
//     32    |        |    24  
//           +--------+        
//                           
////////////////////////////////////////////////////////////////

module altera_avalon_pixel_converter
(
  // Global Signals
  clk,
  reset_n,

  // Avalon ST sink
  ready_out,
  valid_in,
  data_in,
  sop_in,
  eop_in,
  empty_in,

  // Avalon ST source
  ready_in,
  valid_out,
  data_out,
  sop_out,
  eop_out,
  empty_out
);

  parameter	SOURCE_SYMBOLS_PER_BEAT = 3;
  localparam 	SOURCE_EMPTY_WIDTH = (log2(SOURCE_SYMBOLS_PER_BEAT));
  // Global Signals
  input			clk;
  input 		reset_n;
  

  // Avalon ST sink
  output 		ready_out;
  input 		valid_in;
  input [31:0]	data_in;
  input 		sop_in;
  input 		eop_in;
  input [1:0]   empty_in;

  // Avalon ST source
  input 		ready_in;
  output 		valid_out;
  output [23:0]	data_out;
  output 		sop_out;
  output 		eop_out;
  output [(SOURCE_EMPTY_WIDTH - 1):0]	empty_out;

  function integer log2;
   	input [31:0]        value;
	for (log2=0; value>0; log2=log2+1)
		value = value>>1;
  endfunction

  assign ready_out = ready_in;
  assign valid_out = valid_in;
  assign sop_out = sop_in;
  assign eop_out = eop_in;
  assign empty_out = empty_in;

  assign data_out = data_in[31:8];

endmodule


// synthesis translate_off
// Testbench for the altera_avalon_pixel_converter

module test_altera_avalon_pixel_converter;
   integer      result;
   
   reg          clk;
   reg          reset_n;
   
   reg [31:0]   data_in;
   reg          valid_in;
   reg          sop_in;
   reg          eop_in;
   reg [1:0]    empty_in;
   reg          ready_in;
   
   wire [23:0]  data_out;
   wire         valid_out;
   wire         sop_out;
   wire         eop_out;
   wire [1:0]   empty_out;
   wire         ready_out;
   
   /* The DUT */
   altera_avalon_pixel_converter dut (
     // Global Signals
     .clk(clk),
     .reset_n(reset_n),
   
     // Avalon ST sink
     .ready_out(ready_out),
     .valid_in(valid_in),
     .data_in(data_in),
     .sop_in(sop_in),
     .eop_in(eop_in),
     .empty_in(empty_in),

     // Avalon ST source
     .ready_in(ready_in),
     .valid_out(valid_out),
     .data_out(data_out),
     .sop_out(sop_out),
     .eop_out(eop_out),
     .empty_out(empty_out)
   );
   
   
   
   /* Clock Generator */
   always 
   begin
      clk <= 1'b1 ; 
      #10; 
      clk <= 1'b0 ; 
      #10;
   end
   
   
      
   initial
   begin
      result <= 1;
		
		/* Reset the system */
		reset_n <= 0;
		@(negedge clk);
		reset_n <= 1;
		
		/* Testing Valid Signal */
		$display("\n### Testing Valid Signal ... ###\n");
		data_in  <= 32'h0;
      valid_in <= 1'h1;
      sop_in   <= 1'h0;
      eop_in   <= 1'h0;
      empty_in <= 2'h0;
      ready_in <= 1'h0;
      #1;
		if (data_out  == 24'h0 &&
          valid_out == 1'h1 &&
          sop_out   == 1'h0 &&
          eop_out   == 1'h0 &&
          empty_out == 2'h0 &&
          ready_out == 1'h0)
		begin
			$display("---Passed");
		end
		else
		begin
			$display("---Failed");
			result <= 0;
		end
		
		
		
		/* Testing SOP Signal */
		$display("\n### Testing SOP Signal ... ###\n");
		data_in  <= 32'h0;
      valid_in <= 1'h0;
      sop_in   <= 1'h1;
      eop_in   <= 1'h0;
      empty_in <= 2'h0;
      ready_in <= 1'h0;
      #1;
		if (data_out  == 24'h0 &&
          valid_out == 1'h0 &&
          sop_out   == 1'h1 &&
          eop_out   == 1'h0 &&
          empty_out == 2'h0 &&
          ready_out == 1'h0)
		begin
			$display("---Passed");
		end
		else
		begin
			$display("---Failed");
			result <= 0;
		end
		
		
		
		/* Testing EOP Signal */
		$display("\n### Testing EOP Signal ... ###\n");
		data_in  <= 32'h0;
      valid_in <= 1'h0;
      sop_in   <= 1'h0;
      eop_in   <= 1'h1;
      empty_in <= 2'h0;
      ready_in <= 1'h0;
      #1;
		if (data_out  == 24'h0 &&
          valid_out == 1'h0 &&
          sop_out   == 1'h0 &&
          eop_out   == 1'h1 &&
          empty_out == 2'h0 &&
          ready_out == 1'h0)
		begin
			$display("---Passed");
		end
		else
		begin
			$display("---Failed");
			result <= 0;
		end
		
		
		
		/* Testing Ready Signal */
		$display("\n### Testing Ready Signal ... ###\n");
		data_in  <= 32'h0;
      valid_in <= 1'h0;
      sop_in   <= 1'h0;
      eop_in   <= 1'h0;
      empty_in <= 2'h0;
      ready_in <= 1'h1;
      #1;
		if (data_out  == 24'h0 &&
          valid_out == 1'h0 &&
          sop_out   == 1'h0 &&
          eop_out   == 1'h0 &&
          empty_out == 2'h0 &&
          ready_out == 1'h1)
		begin
			$display("---Passed");
		end
		else
		begin
			$display("---Failed");
			result <= 0;
		end
		
		
		
		/* Testing Data Signal */
		$display("\n### Testing Data Signal ... ###\n");
		data_in  <= 32'h11223344;
      valid_in <= 1'h0;
      sop_in   <= 1'h0;
      eop_in   <= 1'h0;
      empty_in <= 2'h0;
      ready_in <= 1'h0;
      #1;
		if (data_out  == 24'h112233 &&
          valid_out == 1'h0 &&
          sop_out   == 1'h0 &&
          eop_out   == 1'h0 &&
          empty_out == 2'h0 &&
          ready_out == 1'h0)
		begin
			$display("---Passed");
		end
		else
		begin
			$display("---Failed");
			result <= 0;
		end
		
		
		
		/* Display overall result */
		#1;
		if (result == 1)
		begin
			$display("\n\n------ Simulation Passed ------\n\n");
		end
		else
		begin
			$display("\n\n------ Simulation Failed ------\n\n");
		end
		
		
		$stop;
		
       
   end
   
   

endmodule

// synthesis translate_on
