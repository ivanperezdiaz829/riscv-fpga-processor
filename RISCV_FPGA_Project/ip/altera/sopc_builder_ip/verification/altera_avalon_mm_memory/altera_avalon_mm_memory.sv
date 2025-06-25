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


// $File: //acds/rel/13.1/ip/sopc/components/verification/altera_avalon_mm_memory/altera_avalon_mm_memory.sv $
// $Revision: #1 $
// $Date: 2013/08/11 $
// $Author: swbranch $
//-----------------------------------------------------------------------------
// =head1 NAME
// altera_avalon_mm_memory
// =head1 SYNOPSIS
// Memory with Avalon Slave Interface
//-----------------------------------------------------------------------------
// =head1 DESCRIPTION
// This is a simple one port memory with a standard Avalon Slave interface.
// The memory will never assert waitrequest for read or write operations, but
// will assert waitrequest while reset is asserted.
//-----------------------------------------------------------------------------

module altera_avalon_mm_memory(
			       clk,   
			       reset,
				  
 			       avs_waitrequest,
 			       avs_write,
 			       avs_read,
 			       avs_address,
 			       avs_byteenable,
 			       avs_writedata,
 			       avs_readdata,
 			       avs_readdatavalid			   
			       );

   // =head1 PARAMETERS
   parameter AV_ADDRESS_W     = 10; // address width
   parameter AV_SYMBOL_W      = 8;  // data symbol width 
   parameter AV_NUMSYMBOLS    = 4;  // number of symbols per word

   localparam AV_DATA_W       = AV_SYMBOL_W * AV_NUMSYMBOLS;   
   localparam SIZE            = 2 ** AV_ADDRESS_W;
   
   // =head1 PINS
   // =head2 Clock Interface   
   input                      clk;
   input                      reset;
   
   // =head2 Avalon Slave Interface
   output                     avs_waitrequest;
   output                     avs_readdatavalid;
   output [AV_DATA_W-1:0]     avs_readdata;
   input                      avs_write;
   input                      avs_read;
   input  [AV_ADDRESS_W-1:0]  avs_address;
   input  [AV_NUMSYMBOLS-1:0] avs_byteenable;
   input  [AV_DATA_W-1:0]     avs_writedata;

   //--------------------------------------------------------------------------
   // Outputs
   //--------------------------------------------------------------------------
   logic [AV_DATA_W-1:0]      avs_readdata;
   logic 		      avs_waitrequest;
   logic 		      avs_readdatavalid;
   
   //--------------------------------------------------------------------------   
   // Private Data Structures
   // =pod
   // All internal data types are packed. SystemVerilog struct or array 
   // slices can be accessed directly and can be assigned to a logic array 
   // in Verilog or a std_logic_vector in VHDL.
   // Read command transactions expect an associated Response transaction to
   // be pushed in by the test bench. Write transactions do not currently
   // require a response.
   // =cut
   //--------------------------------------------------------------------------
   logic [AV_DATA_W-1:0]      mem [0:SIZE-1];
   logic [AV_DATA_W-1:0]      next_avs_readdata;

   //--------------------------------------------------------------------------   
   // synthesis translate_off
   import verbosity_pkg::*;

   string             	      message = "*unitialized*";   
   
   //--------------------------------------------------------------------------
   // =head1 Public Methods API
   // =pod
   // This section describes the public methods in the application programming
   // interface (API). In this case the application program is the test bench
   // which instantiates and controls and queries state in this BFM component.
   // Test programs must only use these public access methods and events to 
   // communicate with this BFM component. The API and the module pins
   // are the only interfaces in this component that are guaranteed to be
   // stable. The API will be maintained for the life of the product. 
   // While we cannot prevent a test program from directly accessing internal
   // tasks, functions, or data private to the BFM, there is no guarantee that
   // these will be present in the future. In fact, it is best for the user
   // to assume that the underlying implementation of this component can 
   // and will change.
   // =cut
   //--------------------------------------------------------------------------

   function automatic string get_version();  // public
      // Return BFM version as a string of three integers separated by periods.
      // For example, version 9.1 sp1 is encoded as "9.1.1".      
      string ret_version = "13.1";
      return ret_version;
   endfunction
   
   //=cut      
   //--------------------------------------------------------------------------
   // Private Methods
   //--------------------------------------------------------------------------

   function automatic void hello();
      // Introduction Message to console      
      $sformat(message, "%m: - Hello from altera_avalon_mm_memory");
      print(VERBOSITY_INFO, message);            
      $sformat(message, "%m: -   $Revision: #1 $");
      print(VERBOSITY_INFO, message);            
      $sformat(message, "%m: -   $Date: 2013/08/11 $");
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   AV_ADDRESS_W=%0d", AV_ADDRESS_W);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   AV_SYMBOL_W=%0d", AV_SYMBOL_W);
      print(VERBOSITY_INFO, message);      
      $sformat(message, "%m: -   AV_NUMSYMBOLS=%0d", AV_NUMSYMBOLS);
      print(VERBOSITY_INFO, message);      
      print_divider(VERBOSITY_INFO);
   endfunction

   initial begin
      hello();
   end
   
   function automatic bit [AV_DATA_W-1:0] data_mask(
      bit [AV_NUMSYMBOLS-1:0] symbol_enable
   );
      bit [AV_DATA_W-1:0]     mask = '1;

      for (int i=0; i<AV_NUMSYMBOLS; i=i+1) begin
	 for (int k=0; k<AV_SYMBOL_W; k=k+1) begin
	    mask[i*AV_SYMBOL_W + k] = symbol_enable[i];
	 end
      end
      
      return mask;
   endfunction 
   
   always @(posedge clk or posedge reset) begin
      if (reset) begin      
	 avs_waitrequest <= 1'b1; // assert wait during reset only
      end else begin
	 avs_waitrequest <= 1'b0; // no wait on read or write transactions
      end	 
   end

   always @(*) begin
      next_avs_readdata = mem[avs_address];
   end

   always @(posedge clk or posedge reset) begin   
      if (reset) begin
	 avs_readdata <= 0;
	 avs_readdatavalid <= 0;
      end else if (avs_write) begin
	 mem[avs_address] <= avs_writedata & data_mask(avs_byteenable);
	 avs_readdatavalid <= 0;
	 
	 // synthesis translate_off
	 $sformat(message, "%m: - Write address: %x data: %x",
		  avs_address, avs_writedata);
	 print(VERBOSITY_DEBUG, message);      	 
	 // synthesis translate_on   		 
      end else if (avs_read) begin
	 avs_readdata <= next_avs_readdata & data_mask(avs_byteenable);
	 avs_readdatavalid <= 1;

	 // synthesis translate_off
	 $sformat(message, "%m: - Read address: %x data: %x",
		  avs_address, avs_writedata);
	 print(VERBOSITY_DEBUG, message);      	 	 
	 // synthesis translate_on
      end else begin
	 avs_readdatavalid <= 0;	 
      end
   end 

   // synthesis translate_on  
   //--------------------------------------------------------------------------
   
endmodule
   




 
