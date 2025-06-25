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


// $File: //acds/rel/13.1/ip/sopc/components/verification/altera_avalon_clock_reset_source/altera_avalon_clock_reset_source.sv $
// $Revision: #1 $
// $Date: 2013/08/11 $
// $Author: swbranch $
//------------------------------------------------------------------------------
// Clock and reset generator

`timescale 1ns / 1ns

module altera_avalon_clock_reset_source (
					 clk, 
					 reset,
					 dummy_src, 
					 dummy_snk  
					 );
   output clk;
   output reset;

   // work around for SOPC Builder restriction - to be removed in the future
   output dummy_src;
   input  dummy_snk;
   
   parameter CLOCK_PERIOD          = 10;  // clock period in ns
   parameter RESET_DEASSERT_CYCLES = 50;  // deassert reset afte delay
   parameter ASSERT_HIGH_RESET     = 1;   // reset pin polarity

// synthesis translate_off
   import verbosity_pkg::*;

   localparam HALF_CLOCK_PERIOD   = CLOCK_PERIOD/2;
   localparam RESET_DEASSERT_TIME = RESET_DEASSERT_CYCLES * CLOCK_PERIOD;
   
   logic clk;
   logic reset;

   logic dummy_src;
   assign dummy_src = 'z;   

   string message = "";

   function automatic void hello();
      $sformat(message, "%m: - Hello from clock_reset_source.");
      print(VERBOSITY_INFO, message);            
      $sformat(message, "%m: -   $Revision: #1 $");
      print(VERBOSITY_INFO, message);            
      $sformat(message, "%m: -   $Date: 2013/08/11 $");
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   CLOCK_PERIOD          = %0d", 
	       CLOCK_PERIOD);      
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   RESET_DEASSERT_CYCLES = %0d", 
	       RESET_DEASSERT_CYCLES); 
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   ASSERT_HIGH_RESET     = %0d",
	       ASSERT_HIGH_RESET);      
      print(VERBOSITY_INFO, message);
      print_divider(VERBOSITY_INFO);      
   endfunction

   function automatic string get_version();  // public
      // Return BFM version as a string of three integers separated by periods.
      // For example, version 9.1 sp1 is encoded as "9.1.1".      
      string ret_version = "13.1";
      return ret_version;            
   endfunction
   
   task automatic assert_reset();  // public
      $sformat(message, "%m: Reset asserted");
      print(VERBOSITY_INFO, message);       
     
      if (ASSERT_HIGH_RESET > 0) begin
	 reset <= 1'b1;
      end else begin
	 reset <= 1'b0;
      end
   endtask

   task automatic deassert_reset();  // public
      $sformat(message, "%m: Reset deasserted");
      print(VERBOSITY_INFO, message);       
      
      if (ASSERT_HIGH_RESET > 0) begin      
	 reset <= 1'b0;
      end else begin
	 reset <= 1'b1;
      end
   endtask
   
   initial begin
      hello();
      clk <= 1'b0;
      forever #HALF_CLOCK_PERIOD clk <= ~clk; 
   end
   
   initial begin
      assert_reset();
      #RESET_DEASSERT_TIME deassert_reset();
   end
// synthesis translate_on

endmodule

