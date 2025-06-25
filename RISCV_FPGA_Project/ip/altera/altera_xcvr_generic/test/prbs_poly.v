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
// Title         : prbs_poly
// Description : Generates PRBS polynominal
// Supported Patterns - 7, 10, 23, 31
// Supported Data widths = 8, 10, 16, 20, 32, 40, 64
//
//-----------------------------------------------------------------------------
// File          : prbs_checker.v
//-----------------------------------------------------------------------------



`timescale 1ps / 1ps

module prbs_poly (
			     dout,
			     clk,
			     nreset,
			     data_in, 
			     insert_error
			     ) ;
   parameter DATA_WIDTH = 10;
   parameter PRBS = 7;
   parameter PATTERN = 97;
   
   input [0:0] clk;
   input [0:0] nreset;
   
   input [DATA_WIDTH - 1:0] data_in;
   input [0:0] 		    insert_error;

   
   output [DATA_WIDTH - 1:0] dout;

   wire [DATA_WIDTH - 1:0] dout_wire;
   assign 		   dout[DATA_WIDTH - 1:1] = dout_wire[DATA_WIDTH - 1:1];
   assign 		   dout[0] = insert_error ^ dout_wire[0];

   


 
  //Parameter Error Checking for prbs_poly
   localparam 		   x = 33;
   localparam 		   parameter_encode = (PRBS * x) + DATA_WIDTH;
   initial /* synthesis enable_verilog_initial_construct */
     begin                  //PRBS * x + DATA_WIDTH
	if(parameter_encode == (7   * x +    10) ||
	   parameter_encode == (10  * x +    10) ||
	   parameter_encode == (23  * x +    10) ||
	   parameter_encode == (31  * x +    10) ||
	   parameter_encode == (7   * x +    20) ||
	   parameter_encode == (10  * x +    20) ||
	   parameter_encode == (23  * x +    20) ||
	   parameter_encode == (31  * x +    20) ||
	   parameter_encode == (7   * x +    16) ||
	   parameter_encode == (10  * x +    16) ||
	   parameter_encode == (23  * x +    16) ||
	   parameter_encode == (31  * x +    16) ||
	   parameter_encode == (7   * x +    8)  ||
	   parameter_encode == (10  * x +    8)  ||
	   parameter_encode == (23  * x +    8)  ||
	   parameter_encode == (31  * x +    8)  ||
	   parameter_encode == (7   * x +    32) ||
	   parameter_encode == (10  * x +    32) ||
	   parameter_encode == (23  * x +    32) ||
	   parameter_encode == (31  * x +    32) ||
	   parameter_encode == (7   * x +    40) ||
	   parameter_encode == (10  * x +    40) ||
	   parameter_encode == (23  * x +    40) ||
	   parameter_encode == (31  * x +    40) ||
	   parameter_encode == (7   * x +    64) ||
	   parameter_encode == (10  * x +    64) ||
	   parameter_encode == (23  * x +    64) ||
	   parameter_encode == (31  * x +    64)
	   ) begin
	   $display("Info: Instaniting PRBS Module with parameters:PRBS=%d DATAWIDTH=%d", PRBS, DATA_WIDTH);
	end
	else begin
	   $display("Error: You have specified incorrect parameters to module:prbs_poly.  See prbs_poly.v for supported parameters");
	end
   end

   

   generate
      case(parameter_encode)
	(7  *  x  + 10):   prbs7_10bit_msb  atso_poly_inst(.dout(dout_wire),.clk(clk), .data_in(data_in), .nreset(nreset));
	(10 *  x  + 10):   prbs10_10bit_msb atso_poly_inst(.dout(dout_wire),.clk(clk), .data_in(data_in), .nreset(nreset));
	(23 *  x  + 10):   prbs23_10bit_msb atso_poly_inst(.dout(dout_wire),.clk(clk), .data_in(data_in), .nreset(nreset));
	(31 *  x  + 10):   prbs31_10bit_msb atso_poly_inst(.dout(dout_wire),.clk(clk), .data_in(data_in), .nreset(nreset));
	(7  *  x  + 20):   prbs7_20bit_msb  atso_poly_inst(.dout(dout_wire),.clk(clk), .data_in(data_in), .nreset(nreset));
	(10 *  x  + 20):   prbs10_20bit_msb atso_poly_inst(.dout(dout_wire),.clk(clk), .data_in(data_in), .nreset(nreset));
	(23 *  x  + 20):   prbs23_20bit_msb atso_poly_inst(.dout(dout_wire),.clk(clk), .data_in(data_in), .nreset(nreset));
	(31 *  x  + 20):   prbs31_20bit_msb atso_poly_inst(.dout(dout_wire),.clk(clk), .data_in(data_in), .nreset(nreset));
	(7  *  x  + 16):   prbs7_16bit_msb  atso_poly_inst(.dout(dout_wire),.clk(clk), .data_in(data_in), .nreset(nreset));
	(10 *  x  + 16):   prbs10_16bit_msb atso_poly_inst(.dout(dout_wire),.clk(clk), .data_in(data_in), .nreset(nreset));
	(23 *  x  + 16):   prbs23_16bit_msb atso_poly_inst(.dout(dout_wire),.clk(clk), .data_in(data_in), .nreset(nreset));
	(31 *  x  + 16):   prbs31_16bit_msb atso_poly_inst(.dout(dout_wire),.clk(clk), .data_in(data_in), .nreset(nreset));
	(7  *  x  + 8) :   prbs7_8bit_msb   atso_poly_inst(.dout(dout_wire),.clk(clk), .data_in(data_in), .nreset(nreset));
	(10 *  x  + 8) :   prbs10_8bit_msb  atso_poly_inst(.dout(dout_wire),.clk(clk), .data_in(data_in), .nreset(nreset));
	(23 *  x  + 8) :   prbs23_8bit_msb  atso_poly_inst(.dout(dout_wire),.clk(clk), .data_in(data_in), .nreset(nreset));
	(31 *  x  + 8) :   prbs31_8bit_msb  atso_poly_inst(.dout(dout_wire),.clk(clk), .data_in(data_in), .nreset(nreset));
	(7  *  x  + 32):   prbs7_32bit_msb  atso_poly_inst(.dout(dout_wire),.clk(clk), .data_in(data_in), .nreset(nreset));
	(10 *  x  + 32):   prbs10_32bit_msb atso_poly_inst(.dout(dout_wire),.clk(clk), .data_in(data_in), .nreset(nreset));
	(23 *  x  + 32):   prbs23_32bit_msb atso_poly_inst(.dout(dout_wire),.clk(clk), .data_in(data_in), .nreset(nreset));
	(31 *  x  + 32):   prbs31_32bit_msb atso_poly_inst(.dout(dout_wire),.clk(clk), .data_in(data_in), .nreset(nreset));
	(7  *  x  + 40):   prbs7_40bit_msb  atso_poly_inst(.dout(dout_wire),.clk(clk), .data_in(data_in), .nreset(nreset));
	(10 *  x  + 40):   prbs10_40bit_msb atso_poly_inst(.dout(dout_wire),.clk(clk), .data_in(data_in), .nreset(nreset));
	(23 *  x  + 40):   prbs23_40bit_msb atso_poly_inst(.dout(dout_wire),.clk(clk), .data_in(data_in), .nreset(nreset));
	(31 *  x  + 40):   prbs31_40bit_msb atso_poly_inst(.dout(dout_wire),.clk(clk), .data_in(data_in), .nreset(nreset));
	// New for 64-bit
	(7 *  x  + 64):   prbs7_64bit_msb atso_poly_inst(.dout(dout_wire),.clk(clk), .data_in(data_in), .nreset(nreset));
	(10 *  x  + 64):   prbs10_64bit_msb atso_poly_inst(.dout(dout_wire),.clk(clk), .data_in(data_in), .nreset(nreset));
	(23 *  x  + 64):   prbs23_64bit_msb atso_poly_inst(.dout(dout_wire),.clk(clk), .data_in(data_in), .nreset(nreset));	
	(31 *  x  + 64):   prbs31_64bit_msb atso_poly_inst(.dout(dout_wire),.clk(clk), .data_in(data_in), .nreset(nreset));			
	
      endcase
	 
   endgenerate
   
endmodule // atso_prbs_poly


module prbs7_10bit_msb 
    (dout,
     clk, 
     data_in,
     nreset
     ) ;
    localparam 			   DATA_WIDTH = 10; 
    localparam 			   PRBS = 7;
    output [DATA_WIDTH -1:0] 	   dout;
    input [DATA_WIDTH -1:0] 	   data_in;
    input 			   clk;
    input 			   nreset;
    

   reg [DATA_WIDTH-1:0] 	   x;
   
   assign dout[DATA_WIDTH-1:0]  = x[DATA_WIDTH-1:0];
   always @ (posedge clk) begin
       if(~nreset) begin
	 x <= data_in;
      end
      else begin
	 x[0] <= data_in[2] ^ data_in[4];
	 x[1] <= data_in[3] ^ data_in[5];
	 x[2] <= data_in[4] ^ data_in[6];
	 x[3] <= data_in[0] ^ data_in[5] ^ data_in[6];
	 x[4] <= data_in[0] ^ data_in[1];
	 x[5] <= data_in[1] ^ data_in[2];
	 x[6] <= data_in[2] ^ data_in[3];
	 x[7] <= data_in[3] ^ data_in[4];
	 x[8] <= data_in[4] ^ data_in[5];
	 x[9] <= data_in[5] ^ data_in[6];
      end // else: !if(~nreset)
   end // always @ (posedge clk)
endmodule // prbs7_10bit_msb


module prbs10_10bit_msb(dout,
			clk, 
			data_in,
			nreset
			);
    localparam 		   DATA_WIDTH = 10; 
   localparam 		   PRBS = 10;
   output [DATA_WIDTH -1:0]dout;
   input [DATA_WIDTH -1:0] data_in;
   input 		   clk;
   input 		   nreset;

   reg [PRBS-1:0] 	   x;
   
   assign dout[DATA_WIDTH-1:0]  = x[DATA_WIDTH-1:0];
    always @ (posedge clk) begin
       if(~nreset) begin
	  x <= data_in;
       end
       else begin
	  x[0] <= data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[9];
	  x[1] <= data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[7];
	  x[2] <= data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[8];
	  x[3] <= data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[9];
	  x[4] <= data_in[0] ^ data_in[4] ^ data_in[7];
	  x[5] <= data_in[1] ^ data_in[5] ^ data_in[8];
	  x[6] <= data_in[2] ^ data_in[6] ^ data_in[9];
	  x[7] <= data_in[0] ^ data_in[7];
	  x[8] <= data_in[1] ^ data_in[8];
	  x[9] <= data_in[2] ^ data_in[9];
       end // else: !if(~nreset)
    end // always @ (posedge clk or negedge nreset)
endmodule // prbs10_10bit_msb


module prbs23_10bit_msb(dout,
			clk, 
			data_in,
			nreset
		       ) ;
    localparam DATA_WIDTH = 10;
    localparam PRBS = 23;
   output [DATA_WIDTH -1:0]dout;
   input [DATA_WIDTH -1:0] data_in;
   input 		   clk;
   input 		   nreset;

   reg [PRBS-1:0] x;

   assign dout[DATA_WIDTH-1:0]  = x[DATA_WIDTH-1:0];
   always @ (posedge clk ) begin
      if(~nreset) begin
	 x <= data_in;
      end
      else begin
	 x[0] <= data_in[8]  ^ x[13];
	 x[1] <= data_in[9]  ^ x[14];
	 x[2] <= x[10] ^ x[15];
	 x[3] <= x[11] ^ x[16];
	 x[4] <= x[12] ^ x[17];
	 x[5] <= x[13] ^ x[18];
	 x[6] <= x[14] ^ x[19];
	 x[7] <= x[15] ^ x[20];
	 x[8] <= x[16] ^ x[21];
	 x[9] <= x[17] ^ x[22];
	 x[10] <= data_in[0];
	 x[11] <= data_in[1];
	 x[12] <= data_in[2];
	 x[13] <= data_in[3];
	 x[14] <= data_in[4];
	 x[15] <= data_in[5];
	 x[16] <= data_in[6];
	 x[17] <= data_in[7];
	 x[18] <= data_in[8];
	 x[19] <= data_in[9];
	 x[20] <= x[10];
	 x[21] <= x[11];
	 x[22] <= x[12];
      end // else: !if(~nreset)
   end // always @ (posedge clk )
endmodule // prbs23_10bit_msb

module prbs31_10bit_msb(dout,
			clk, 
			data_in,
			nreset
		       ) ;
    localparam 		   DATA_WIDTH = 10;
    localparam 		   PRBS = 31;
   output [DATA_WIDTH -1:0]dout;
   input [DATA_WIDTH -1:0] data_in;
   input 		   clk;
   input 		   nreset;

   
   reg [PRBS-1:0] x;

   assign dout[DATA_WIDTH-1:0]  = x[DATA_WIDTH-1:0];
   always @ (posedge clk ) begin
      if(~nreset) begin
	 x <= data_in;
      end
      else begin
	 x[0] <= data_in[2] ^ x[21] ^ x[24] ^ x[27] ^ x[30];
	 x[1] <= data_in[0] ^ x[22] ^ x[25] ^ x[28];
	 x[2] <= data_in[1] ^ x[23] ^ x[26] ^ x[29];
	 x[3] <= data_in[2] ^ x[24] ^ x[27] ^ x[30];
	 x[4] <= data_in[0] ^ x[25] ^ x[28];
	 x[5] <= data_in[1] ^ x[26] ^ x[29];
	 x[6] <= data_in[2] ^ x[27] ^ x[30];
	 x[7] <= data_in[0] ^ x[28];
	 x[8] <= data_in[1] ^ x[29];
	 x[9] <= data_in[2] ^ x[30];
	 x[10] <= data_in[0];
	 x[11] <= data_in[1];
	 x[12] <= data_in[2];
	 x[13] <= data_in[3];
	 x[14] <= data_in[4];
	 x[15] <= data_in[5];
	 x[16] <= data_in[6];
	 x[17] <= data_in[7];
	 x[18] <= data_in[8];
	 x[19] <= data_in[9];
	 x[20] <= x[10];
	 x[21] <= x[11];
	 x[22] <= x[12];
	 x[23] <= x[13];
	 x[24] <= x[14];
	 x[25] <= x[15];
	 x[26] <= x[16];
	 x[27] <= x[17];
	 x[28] <= x[18];
	 x[29] <= x[19];
	 x[30] <= x[20];
      end // else: !if(~nreset)
   end // always @ (posedge clk )
endmodule // prbs31_10bit_msb


module prbs7_20bit_msb(dout,
		       clk, 
		       data_in,
		       nreset
		       ) ;
    localparam 		   DATA_WIDTH = 20;
   localparam 		   PRBS = 7;
   output [DATA_WIDTH -1:0]dout;
   input [DATA_WIDTH -1:0] data_in;
   input 		   clk;
   input 		   nreset;
   
   reg [DATA_WIDTH-1:0] 	   x;
   assign dout[DATA_WIDTH-1:0]  = x[DATA_WIDTH-1:0];
   always @ (posedge clk ) begin
      if(~nreset) begin
	 x <= data_in;
      end
      else begin
         x[0] <= data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[6];
         x[1] <= data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[6];
         x[2] <= data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3];
         x[3] <= data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4];
         x[4] <= data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[5];
         x[5] <= data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6];
         x[6] <= data_in[0] ^ data_in[4] ^ data_in[5];
         x[7] <= data_in[1] ^ data_in[5] ^ data_in[6];
         x[8] <= data_in[0] ^ data_in[2];
         x[9] <= data_in[1] ^ data_in[3];
         x[10] <= data_in[2] ^ data_in[4];
         x[11] <= data_in[3] ^ data_in[5];
         x[12] <= data_in[4] ^ data_in[6];
         x[13] <= data_in[0] ^ data_in[5] ^ data_in[6];
         x[14] <= data_in[0] ^ data_in[1];
         x[15] <= data_in[1] ^ data_in[2];
         x[16] <= data_in[2] ^ data_in[3];
         x[17] <= data_in[3] ^ data_in[4];
         x[18] <= data_in[4] ^ data_in[5];
         x[19] <= data_in[5] ^ data_in[6];
      end 
   end // always @ (posedge clk )
endmodule // prbs31_10bit_msb




module prbs10_20bit_msb(dout,
			clk, 
			data_in,
			nreset
			) ;
   localparam 		   DATA_WIDTH = 20;
   localparam 		   PRBS = 10;
   output [DATA_WIDTH -1:0]dout;
   input [DATA_WIDTH -1:0] data_in;
   input 		   clk;
   input 		   nreset;
  

   
   reg [DATA_WIDTH-1:0] 	   x;
   assign dout[DATA_WIDTH-1:0]  = x[DATA_WIDTH-1:0];
   always @ (posedge clk ) begin
      if(~nreset)begin
	 x <= data_in;
      end
      else begin
	 x[0] <= data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[6] ^ data_in[8];
	 x[1] <= data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7] ^ data_in[9];
	 x[2] <= data_in[0] ^ data_in[2] ^ data_in[4] ^ data_in[7] ^ data_in[8];
	 x[3] <= data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[8] ^ data_in[9];
	 x[4] <= data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[6] ^ data_in[9];
	 x[5] <= data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[5] ^ data_in[7];
	 x[6] <= data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[6] ^ data_in[8];
	 x[7] <= data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7] ^ data_in[9];
	 x[8] <= data_in[0] ^ data_in[4] ^ data_in[7] ^ data_in[8];
	 x[9] <= data_in[1] ^ data_in[5] ^ data_in[8] ^ data_in[9];
	 x[10] <= data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[9];
	 x[11] <= data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[7];
	 x[12] <= data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[8];
	 x[13] <= data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[9];
	 x[14] <= data_in[0] ^ data_in[4] ^ data_in[7];
	 x[15] <= data_in[1] ^ data_in[5] ^ data_in[8];
	 x[16] <= data_in[2] ^ data_in[6] ^ data_in[9];
	 x[17] <= data_in[0] ^ data_in[7];
	 x[18] <= data_in[1] ^ data_in[8];
	 x[19] <= data_in[2] ^ data_in[9];
      end 
   end // always @ (posedge clk )
endmodule // prbs10_20bit_msb

module prbs23_20bit_msb(dout,
			clk, 
			data_in,
			nreset
			);
   localparam 		   DATA_WIDTH = 20;
   localparam 		   PRBS = 23;
   output [DATA_WIDTH -1:0]dout;
   input [DATA_WIDTH -1:0] data_in;
   input 		   clk;
   input 		   nreset;

   
   reg [PRBS-1:0] 	   x;
   assign dout[DATA_WIDTH-1:0]  = x[DATA_WIDTH-1:0];
   
   always @ (posedge clk ) begin
    if(~nreset) begin
	x <= data_in;
    end
    else begin
       x[0] <= data_in[3] ^ data_in[16] ^ x[21];
       x[1] <= data_in[4] ^ data_in[17] ^ x[22];
       x[2] <= data_in[0] ^ data_in[5];
       x[3] <= data_in[1] ^ data_in[6];
       x[4] <= data_in[2] ^ data_in[7];
       x[5] <= data_in[3] ^ data_in[8];
       x[6] <= data_in[4] ^ data_in[9];
       x[7] <= data_in[5] ^ data_in[10];
       x[8] <= data_in[6] ^ data_in[11];
       x[9] <= data_in[7] ^ data_in[12];
       x[10] <= data_in[8] ^ data_in[13];
       x[11] <= data_in[9] ^ data_in[14];
       x[12] <= data_in[10] ^ data_in[15];
       x[13] <= data_in[11] ^ data_in[16];
       x[14] <= data_in[12] ^ data_in[17];
       x[15] <= data_in[13] ^ data_in[18];
       x[16] <= data_in[14] ^ data_in[19];
       x[17] <= data_in[15] ^ x[20];
       x[18] <= data_in[16] ^ x[21];
       x[19] <= data_in[17] ^ x[22];
       x[20] <= data_in[0];
       x[21] <= data_in[1];
       x[22] <= data_in[2];
    end 
   end // always @ (posedge clk )
endmodule // prbs23_20bit_msb




module prbs31_20bit_msb(dout,
			clk, 
			data_in,
			nreset
		       );
   localparam 		   DATA_WIDTH = 20;
   localparam 		   PRBS = 31;
   output [DATA_WIDTH -1:0]dout;
   input [DATA_WIDTH -1:0] data_in;
   input 		   clk;
   input 		   nreset;
   
   reg [PRBS-1:0] 	   x;
   assign dout[DATA_WIDTH-1:0]  = x[DATA_WIDTH-1:0];
   always @ (posedge clk ) begin
    if(~nreset) begin
       x <= data_in;
    end
    else begin
       x[0] <= data_in[1] ^ data_in[11] ^ data_in[14] ^ data_in[17] ^ x[20] ^ x[23] ^ x[26] ^ x[29];
       x[1] <= data_in[2] ^ data_in[12] ^ data_in[15] ^ data_in[18] ^ x[21] ^ x[24] ^ x[27] ^ x[30];
       x[2] <= data_in[0] ^ data_in[13] ^ data_in[16] ^ data_in[19] ^ x[22] ^ x[25] ^ x[28];
       x[3] <= data_in[1] ^ data_in[14] ^ data_in[17] ^ x[20] ^ x[23] ^ x[26] ^ x[29];
       x[4] <= data_in[2] ^ data_in[15] ^ data_in[18] ^ x[21] ^ x[24] ^ x[27] ^ x[30];
       x[5] <= data_in[0] ^ data_in[16] ^ data_in[19] ^ x[22] ^ x[25] ^ x[28];
       x[6] <= data_in[1] ^ data_in[17] ^ x[20] ^ x[23] ^ x[26] ^ x[29];
       x[7] <= data_in[2] ^ data_in[18] ^ x[21] ^ x[24] ^ x[27] ^ x[30];
       x[8] <= data_in[0] ^ data_in[19] ^ x[22] ^ x[25] ^ x[28];
       x[9] <= data_in[1] ^ x[20] ^ x[23] ^ x[26] ^ x[29];
       x[10] <= data_in[2] ^ x[21] ^ x[24] ^ x[27] ^ x[30];
       x[11] <= data_in[0] ^ x[22] ^ x[25] ^ x[28];
       x[12] <= data_in[1] ^ x[23] ^ x[26] ^ x[29];
       x[13] <= data_in[2] ^ x[24] ^ x[27] ^ x[30];
       x[14] <= data_in[0] ^ x[25] ^ x[28];
       x[15] <= data_in[1] ^ x[26] ^ x[29];
       x[16] <= data_in[2] ^ x[27] ^ x[30];
       x[17] <= data_in[0] ^ x[28];
       x[18] <= data_in[1] ^ x[29];
       x[19] <= data_in[2] ^ x[30];
       x[20] <= data_in[0];
       x[21] <= data_in[1];
       x[22] <= data_in[2];
       x[23] <= data_in[3];
       x[24] <= data_in[4];
       x[25] <= data_in[5];
       x[26] <= data_in[6];
       x[27] <= data_in[7];
       x[28] <= data_in[8];
       x[29] <= data_in[9];
       x[30] <= data_in[10];
    end 
   end // always @ (posedge clk )
endmodule // prbs31_20bit_msb

module prbs7_16bit_msb(dout,
		       clk, 
		       data_in,
		       nreset
		       ) ;

   localparam 		   DATA_WIDTH = 16;
   localparam 		   PRBS = 7;
   output [DATA_WIDTH -1:0]dout;
   input [DATA_WIDTH -1:0] data_in;
   input 		   clk;
   input 		   nreset;
  

   
   reg [DATA_WIDTH-1:0] 	   x;
   assign dout[DATA_WIDTH-1:0]  = x[DATA_WIDTH-1:0];
   
   always @ (posedge clk ) begin
     if(~nreset)begin
	x <= data_in;
     end
     else begin
	x[0] <= data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[5];
        x[1] <= data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6];
        x[2] <= data_in[0] ^ data_in[4] ^ data_in[5];
        x[3] <= data_in[1] ^ data_in[5] ^ data_in[6];
        x[4] <= data_in[0] ^ data_in[2];
        x[5] <= data_in[1] ^ data_in[3];
        x[6] <= data_in[2] ^ data_in[4];
        x[7] <= data_in[3] ^ data_in[5];
        x[8] <= data_in[4] ^ data_in[6];
        x[9] <= data_in[0] ^ data_in[5] ^ data_in[6];
        x[10] <= data_in[0] ^ data_in[1];
        x[11] <= data_in[1] ^ data_in[2];
        x[12] <= data_in[2] ^ data_in[3];
        x[13] <= data_in[3] ^ data_in[4];
        x[14] <= data_in[4] ^ data_in[5];
        x[15] <= data_in[5] ^ data_in[6];
     end 
   end // always @ (posedge clk )
endmodule // prbs7_16bit_msb


module prbs10_16bit_msb(dout,
			clk, 
			data_in,
			nreset
			) ;
   localparam 		   DATA_WIDTH = 16;
   localparam 		   PRBS = 10;
   output [DATA_WIDTH -1:0]dout;
   input [DATA_WIDTH -1:0] data_in;
   input 		   clk;
   input 		   nreset;

   
   reg [DATA_WIDTH-1:0] 	   x;
   assign dout[DATA_WIDTH-1:0]  = x[DATA_WIDTH-1:0];
   
   always @ (posedge clk ) begin
     if(~nreset)begin
	x <= data_in;
     end
     else begin
	x[0] <= data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[6] ^ data_in[9];
	x[1] <= data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[5] ^ data_in[7];
	x[2] <= data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[6] ^ data_in[8];
	x[3] <= data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7] ^ data_in[9];
	x[4] <= data_in[0] ^ data_in[4] ^ data_in[7] ^ data_in[8];
	x[5] <= data_in[1] ^ data_in[5] ^ data_in[8] ^ data_in[9];
	x[6] <= data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[9];
	x[7] <= data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[7];
	x[8] <= data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[8];
	x[9] <= data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[9];
	x[10] <= data_in[0] ^ data_in[4] ^ data_in[7];
	x[11] <= data_in[1] ^ data_in[5] ^ data_in[8];
	x[12] <= data_in[2] ^ data_in[6] ^ data_in[9];
	x[13] <= data_in[0] ^ data_in[7];
	x[14] <= data_in[1] ^ data_in[8];
	x[15] <= data_in[2] ^ data_in[9];
     end 
   end // always @ (posedge clk )
endmodule // prbs10_16bit_msb



module prbs23_16bit_msb(dout,
			clk, 
			data_in,
			nreset
			) ;
   localparam 		   DATA_WIDTH = 16;
   localparam 		   PRBS = 23;
   output [DATA_WIDTH -1:0]dout;
   input [DATA_WIDTH -1:0] data_in;
   input 		   clk;
   input 		   nreset;
  

   
   reg [PRBS-1:0] 	   x;
   assign dout[DATA_WIDTH-1:0]  = x[DATA_WIDTH-1:0];
   
   always @ (posedge clk ) begin
     if(~nreset)begin
	x <= data_in;
     end
     else begin
	x[0] <= data_in[2] ^ data_in[7];
	x[1] <= data_in[3] ^ data_in[8];
	x[2] <= data_in[4] ^ data_in[9];
	x[3] <= data_in[5] ^ data_in[10];
	x[4] <= data_in[6] ^ data_in[11];
	x[5] <= data_in[7] ^ data_in[12];
	x[6] <= data_in[8] ^ data_in[13];
	x[7] <= data_in[9] ^ data_in[14];
	x[8] <= data_in[10] ^ data_in[15];
	x[9] <= data_in[11] ^ x[16];
	x[10] <= data_in[12] ^ x[17];
	x[11] <= data_in[13] ^ x[18];
	x[12] <= data_in[14] ^ x[19];
	x[13] <= data_in[15] ^ x[20];
	x[14] <= x[16] ^ x[21];
	x[15] <= x[17] ^ x[22];
	x[16] <= data_in[0];
	x[17] <= data_in[1];
	x[18] <= data_in[2];
	x[19] <= data_in[3];
	x[20] <= data_in[4];
	x[21] <= data_in[5];
	x[22] <= data_in[6];
     end 
   end // always @ (posedge clk )
endmodule // prbs23_16bit_msb


module prbs31_16bit_msb(dout,
			clk, 
			data_in,
			nreset
			) ;
   localparam 		   DATA_WIDTH = 16;
   localparam 		   PRBS = 31;
   output [DATA_WIDTH -1:0]dout;
   input [DATA_WIDTH -1:0] data_in;
   input 		   clk;
   input 		   nreset;
  

   
   reg [PRBS-1:0] 	   x;
   assign dout[DATA_WIDTH-1:0]  = x[DATA_WIDTH-1:0];
   
   always @ (posedge clk ) begin
     if(~nreset)begin
	x <= data_in;
     end
     else begin
	x[0] <= data_in[2] ^ data_in[15] ^ x[18] ^ x[21] ^ x[24] ^ x[27] ^ x[30];
	x[1] <= data_in[0] ^ x[16] ^ x[19] ^ x[22] ^ x[25] ^ x[28];
	x[2] <= data_in[1] ^ x[17] ^ x[20] ^ x[23] ^ x[26] ^ x[29];
	x[3] <= data_in[2] ^ x[18] ^ x[21] ^ x[24] ^ x[27] ^ x[30];
	x[4] <= data_in[0] ^ x[19] ^ x[22] ^ x[25] ^ x[28];
	x[5] <= data_in[1] ^ x[20] ^ x[23] ^ x[26] ^ x[29];
	x[6] <= data_in[2] ^ x[21] ^ x[24] ^ x[27] ^ x[30];
	x[7] <= data_in[0] ^ x[22] ^ x[25] ^ x[28];
	x[8] <= data_in[1] ^ x[23] ^ x[26] ^ x[29];
	x[9] <= data_in[2] ^ x[24] ^ x[27] ^ x[30];
	x[10] <= data_in[0] ^ x[25] ^ x[28];
	x[11] <= data_in[1] ^ x[26] ^ x[29];
	x[12] <= data_in[2] ^ x[27] ^ x[30];
	x[13] <= data_in[0] ^ x[28];
	x[14] <= data_in[1] ^ x[29];
	x[15] <= data_in[2] ^ x[30];
	x[16] <= data_in[0];
	x[17] <= data_in[1];
	x[18] <= data_in[2];
	x[19] <= data_in[3];
	x[20] <= data_in[4];
	x[21] <= data_in[5];
	x[22] <= data_in[6];
	x[23] <= data_in[7];
	x[24] <= data_in[8];
	x[25] <= data_in[9];
	x[26] <= data_in[10];
	x[27] <= data_in[11];
	x[28] <= data_in[12];
	x[29] <= data_in[13];
	x[30] <= data_in[14];
     end 
   end // always @ (posedge clk )
endmodule // prbs31_16bit_msb



module prbs7_8bit_msb(dout,
		      clk, 
		      data_in,
		      nreset
		      ) ;
	 
   localparam 		   DATA_WIDTH = 8;
   localparam 		   PRBS = 7;
   output [DATA_WIDTH -1:0]dout;
   input [DATA_WIDTH -1:0] data_in;
   input 		   clk;
   input 		   nreset;
  

   
   reg [DATA_WIDTH-1:0]    x;
   assign dout[DATA_WIDTH-1:0]  = x[DATA_WIDTH-1:0];
   
   always @ (posedge clk ) begin
      if(~nreset)begin
	 x <= data_in;
      end
      else begin
	 x[0] <= data_in[4] ^ data_in[6];
	 x[1] <= data_in[0] ^ data_in[5] ^ data_in[6];
	 x[2] <= data_in[0] ^ data_in[1];
	 x[3] <= data_in[1] ^ data_in[2];
	 x[4] <= data_in[2] ^ data_in[3];
	 x[5] <= data_in[3] ^ data_in[4];
	 x[6] <= data_in[4] ^ data_in[5];
	 x[7] <= data_in[5] ^ data_in[6];
      end 
   end // always @ (posedge clk )
endmodule // prbs7_8bit_msb


module prbs10_8bit_msb(dout,
		       clk, 
		       data_in,
		       nreset
		      ) ;

    localparam 		   DATA_WIDTH = 8;
    localparam 		   PRBS = 10;  
    output [DATA_WIDTH -1:0] dout;
    input [DATA_WIDTH -1:0]  data_in;
    input 		     clk;
    input 		     nreset;
    
   
   reg [PRBS-1:0]    x;
   assign dout[DATA_WIDTH-1:0]  = x[DATA_WIDTH-1:0];
   
   always @ (posedge clk ) begin
      if(~nreset)begin
	 x <= data_in;
      end
      else begin
	 x[0] <= data_in[1] ^ data_in[2] ^ data_in[5] ^ x[8];
	 x[1] <= data_in[2] ^ data_in[3] ^ data_in[6] ^ x[9];
	 x[2] <= data_in[0] ^ data_in[4] ^ data_in[7];
	 x[3] <= data_in[1] ^ data_in[5] ^ x[8];
	 x[4] <= data_in[2] ^ data_in[6] ^ x[9];
	 x[5] <= data_in[0] ^ data_in[7];
	 x[6] <= data_in[1] ^ x[8];
	 x[7] <= data_in[2] ^ x[9];
	 x[8] <= data_in[0];
	 x[9] <= data_in[1];
      end 
   end // always @ (posedge clk )
endmodule // prbs10_8bit_msb




module prbs23_8bit_msb(dout,
		       clk, 
		       data_in,
		       nreset
		       ) ;
   localparam 		   DATA_WIDTH = 8;
   localparam 		   PRBS = 23;
   output [DATA_WIDTH -1:0]dout;
   input [DATA_WIDTH -1:0] data_in;
   input 		   clk;
   input 		   nreset;
  

   
   reg [PRBS-1:0] 	   x;
   assign 		   dout[DATA_WIDTH-1:0]  = x[DATA_WIDTH-1:0];
   
   always @ (posedge clk ) begin
      if(~nreset)begin
	 x <= data_in;
      end
      else begin
         x[0] <= x[10] ^ x[15];
	 x[1] <= x[11] ^ x[16];
	 x[2] <= x[12] ^ x[17];
	 x[3] <= x[13] ^ x[18];
	 x[4] <= x[14] ^ x[19];
	 x[5] <= x[15] ^ x[20];
	 x[6] <= x[16] ^ x[21];
	 x[7] <= x[17] ^ x[22];
	 x[8] <= data_in[0];
	 x[9] <= data_in[1];
	 x[10] <= data_in[2];
	 x[11] <= data_in[3];
	 x[12] <= data_in[4];
	 x[13] <= data_in[5];
	 x[14] <= data_in[6];
	 x[15] <= data_in[7];
	 x[16] <= x[8];
	 x[17] <= x[9];
	 x[18] <= x[10];
	 x[19] <= x[11];
	 x[20] <= x[12];
	 x[21] <= x[13];
	 x[22] <= x[14];
      end 
   end // always @ (posedge clk )
endmodule // prbs23_8bit_msb


module prbs31_8bit_msb(dout,
		       clk, 
		       data_in,
		       nreset
		       ) ;
   localparam 		   DATA_WIDTH = 8;
   localparam 		   PRBS = 31;
   output [DATA_WIDTH -1:0]dout;
   input [DATA_WIDTH -1:0] data_in;
   input 		   clk;
   input 		   nreset;
  

   
   reg [PRBS-1:0] 	   x;
   assign 		   dout[DATA_WIDTH-1:0]  = x[DATA_WIDTH-1:0];
   
   always @ (posedge clk ) begin
      if(~nreset)begin
	 x <= data_in;
      end
      else begin
         x[0] <= data_in[1] ^ x[23] ^ x[26] ^ x[29];
	 x[1] <= data_in[2] ^ x[24] ^ x[27] ^ x[30];
	 x[2] <= data_in[0] ^ x[25] ^ x[28];
	 x[3] <= data_in[1] ^ x[26] ^ x[29];
	 x[4] <= data_in[2] ^ x[27] ^ x[30];
	 x[5] <= data_in[0] ^ x[28];
	 x[6] <= data_in[1] ^ x[29];
	 x[7] <= data_in[2] ^ x[30];
	 x[8] <= data_in[0];
	 x[9] <= data_in[1];
	 x[10] <= data_in[2];
	 x[11] <= data_in[3];
	 x[12] <= data_in[4];
	 x[13] <= data_in[5];
	 x[14] <= data_in[6];
	 x[15] <= data_in[7];
	 x[16] <= x[8];
	 x[17] <= x[9];
	 x[18] <= x[10];
	 x[19] <= x[11];
	 x[20] <= x[12];
	 x[21] <= x[13];
	 x[22] <= x[14];
	 x[23] <= x[15];
	 x[24] <= x[16];
	 x[25] <= x[17];
	 x[26] <= x[18];
	 x[27] <= x[19];
	 x[28] <= x[20];
	 x[29] <= x[21];
	 x[30] <= x[22];
      end 
   end // always @ (posedge clk )
endmodule // prbs31_8bit_msb



module prbs7_32bit_msb(dout,
		       clk, 
		       data_in,
		       nreset
		       ) ;
    localparam 		   DATA_WIDTH = 32;   
    output [DATA_WIDTH -1:0] dout;
    input [DATA_WIDTH -1:0]  data_in;
    input 		     clk;
    input 		     nreset;
  
   
   
    reg [DATA_WIDTH-1:0]   x;
    assign dout[DATA_WIDTH-1:0]  = x[DATA_WIDTH-1:0];
   
   always @ (*) begin
      if(~nreset)begin
	 x =data_in;
      end
      else begin
	 x[0] = data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[6];
	 x[1] = data_in[0] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6];
	 x[2] = data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[5];
	 x[3] = data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[6];
	 x[4] = data_in[0] ^ data_in[2] ^ data_in[3];
	 x[5] = data_in[1] ^ data_in[3] ^ data_in[4];
	 x[6] = data_in[2] ^ data_in[4] ^ data_in[5];
	 x[7] = data_in[3] ^ data_in[5] ^ data_in[6];
	 x[8] = data_in[0] ^ data_in[4];
	 x[9] = data_in[1] ^ data_in[5];
	 x[10] = data_in[2] ^ data_in[6];
	 x[11] = data_in[0] ^ data_in[3] ^ data_in[6];
	 x[12] = data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[6];
	 x[13] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[6];
	 x[14] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3];
	 x[15] = data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4];
	 x[16] = data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[5];
	 x[17] = data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6];
	 x[18] = data_in[0] ^ data_in[4] ^ data_in[5];
	 x[19] = data_in[1] ^ data_in[5] ^ data_in[6];
	 x[20] = data_in[0] ^ data_in[2];
	 x[21] = data_in[1] ^ data_in[3];
	 x[22] = data_in[2] ^ data_in[4];
	 x[23] = data_in[3] ^ data_in[5];
	 x[24] = data_in[4] ^ data_in[6];
	 x[25] = data_in[0] ^ data_in[5] ^ data_in[6];
	 x[26] = data_in[0] ^ data_in[1];
	 x[27] = data_in[1] ^ data_in[2];
	 x[28] = data_in[2] ^ data_in[3];
	 x[29] = data_in[3] ^ data_in[4];
	 x[30] = data_in[4] ^ data_in[5];
	 x[31] = data_in[5] ^ data_in[6];
      end 
   end // always @ (posedge clk )
endmodule // prbs7_32bit_msb

module prbs10_32bit_msb(dout,
			clk, 
			data_in,
			nreset
			) ;
   localparam 		   DATA_WIDTH = 32;
   output [DATA_WIDTH -1:0]dout;
   input [DATA_WIDTH -1:0] data_in;
   input 		   clk;
   input 		   nreset;
  

   
   reg [DATA_WIDTH-1:0]    x;
   assign 		   dout[DATA_WIDTH-1:0]  = x[DATA_WIDTH-1:0];

   always @ (*) begin
      if(~nreset) begin
	 x = data_in;
      end
      else begin
      	 x[0] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[6];
	 x[1] = data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7];
	 x[2] = data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[7] ^ data_in[8];
	 x[3] = data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[8] ^ data_in[9];
	 x[4] = data_in[0] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[9];
	 x[5] = data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
	 x[6] = data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[8];
	 x[7] = data_in[2] ^ data_in[3] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[9];
	 x[8] = data_in[0] ^ data_in[4] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[9];
	 x[9] = data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[7] ^ data_in[8] ^ data_in[9];
	 x[10] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[6] ^ data_in[8] ^ data_in[9];
	 x[11] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[7] ^ data_in[9];
	 x[12] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[6] ^ data_in[8];
	 x[13] = data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7] ^ data_in[9];
	 x[14] = data_in[0] ^ data_in[2] ^ data_in[4] ^ data_in[7] ^ data_in[8];
	 x[15] = data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[8] ^ data_in[9];
	 x[16] = data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[6] ^ data_in[9];
	 x[17] = data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[5] ^ data_in[7];
	 x[18] = data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[6] ^ data_in[8];
	 x[19] = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7] ^ data_in[9];
	 x[20] = data_in[0] ^ data_in[4] ^ data_in[7] ^ data_in[8];
	 x[21] = data_in[1] ^ data_in[5] ^ data_in[8] ^ data_in[9];
	 x[22] = data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[9];
	 x[23] = data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[7];
	 x[24] = data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[8];
	 x[25] = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[9];
	 x[26] = data_in[0] ^ data_in[4] ^ data_in[7];
	 x[27] = data_in[1] ^ data_in[5] ^ data_in[8];
	 x[28] = data_in[2] ^ data_in[6] ^ data_in[9];
	 x[29] = data_in[0] ^ data_in[7];
	 x[30] = data_in[1] ^ data_in[8];
	 x[31] = data_in[2] ^ data_in[9];
      end 
   end // always @ (posedge clk )
endmodule // prbs10_32bit_msb

				

module prbs23_32bit_msb(dout,
			clk, 
			data_in,
			nreset
 			) ;
   localparam 		   DATA_WIDTH = 32;
   output [DATA_WIDTH -1:0]dout;
   input [DATA_WIDTH -1:0] data_in;
   input 		   clk;
   input 		   nreset;
  

   
    reg [DATA_WIDTH-1:0]   x;
    assign dout[DATA_WIDTH-1:0]  = x[DATA_WIDTH-1:0];


   always @(*)
     begin     
	if(~nreset) begin
	   x = data_in;
	end
	else
	  begin
   	     x[0] = data_in[4] ^ data_in[14];
	     x[1] = data_in[5] ^ data_in[15];
	     x[2] = data_in[6] ^ data_in[16];
	     x[3] = data_in[7] ^ data_in[17];
	     x[4] = data_in[8] ^ data_in[18];
	     x[5] = data_in[9] ^ data_in[19];
	     x[6] = data_in[10] ^ data_in[20];
	     x[7] = data_in[11] ^ data_in[21];
	     x[8] = data_in[12] ^ data_in[22];
	     x[9] = data_in[0] ^ data_in[13] ^ data_in[18];
	     x[10] = data_in[1] ^ data_in[14] ^ data_in[19];
	     x[11] = data_in[2] ^ data_in[15] ^ data_in[20];
	     x[12] = data_in[3] ^ data_in[16] ^ data_in[21];
	     x[13] = data_in[4] ^ data_in[17] ^ data_in[22];
	     x[14] = data_in[0] ^ data_in[5];
	     x[15] = data_in[1] ^ data_in[6];
	     x[16] = data_in[2] ^ data_in[7];
	     x[17] = data_in[3] ^ data_in[8];
	     x[18] = data_in[4] ^ data_in[9];
	     x[19] = data_in[5] ^ data_in[10];
	     x[20] = data_in[6] ^ data_in[11];
	     x[21] = data_in[7] ^ data_in[12];
	     x[22] = data_in[8] ^ data_in[13];
	     x[23] = data_in[9] ^ data_in[14];
	     x[24] = data_in[10] ^ data_in[15];
	     x[25] = data_in[11] ^ data_in[16];
	     x[26] = data_in[12] ^ data_in[17];
	     x[27] = data_in[13] ^ data_in[18];
	     x[28] = data_in[14] ^ data_in[19];
	     x[29] = data_in[15] ^ data_in[20];
	     x[30] = data_in[16] ^ data_in[21];
	     x[31] = data_in[17] ^ data_in[22];
	  end // else: !if(~nreset)
     end // always @ (*)
   
   

   
endmodule // prbs23_32bit_msb


module prbs31_32bit_msb(dout,
			clk, 
			data_in,
			nreset
			) ;
   localparam 		   DATA_WIDTH = 32;
   output [DATA_WIDTH -1:0]dout;
   input [DATA_WIDTH -1:0] data_in;
   input 		   clk;
   input 		   nreset;

   
   reg [DATA_WIDTH-1:0]    x;
   assign 		   dout[DATA_WIDTH-1:0]  = x[DATA_WIDTH-1:0];
   

   always @ (posedge clk ) begin
      if(~nreset)begin
	 x = data_in;
      end
      else begin
	 x[0] = data_in[1] ^ data_in[5] ^ data_in[8] ^ data_in[11] ^ data_in[14] ^ data_in[17] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[29] ^ data_in[30];
	 x[1] = data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[9] ^ data_in[12] ^ data_in[15] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30];
	 x[2] = data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[7] ^ data_in[10] ^ data_in[13] ^ data_in[16] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[28];
	 x[3] = data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[8] ^ data_in[11] ^ data_in[14] ^ data_in[17] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[29];
	 x[4] = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[9] ^ data_in[12] ^ data_in[15] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30];
	 x[5] = data_in[0] ^ data_in[4] ^ data_in[7] ^ data_in[10] ^ data_in[13] ^ data_in[16] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[28];
	 x[6] = data_in[1] ^ data_in[5] ^ data_in[8] ^ data_in[11] ^ data_in[14] ^ data_in[17] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[29];
	 x[7] = data_in[2] ^ data_in[6] ^ data_in[9] ^ data_in[12] ^ data_in[15] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30];
	 x[8] = data_in[0] ^ data_in[7] ^ data_in[10] ^ data_in[13] ^ data_in[16] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[28];
	 x[9] = data_in[1] ^ data_in[8] ^ data_in[11] ^ data_in[14] ^ data_in[17] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[29];
	 x[10] = data_in[2] ^ data_in[9] ^ data_in[12] ^ data_in[15] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30];
	 x[11] = data_in[0] ^ data_in[10] ^ data_in[13] ^ data_in[16] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[28];
	 x[12] = data_in[1] ^ data_in[11] ^ data_in[14] ^ data_in[17] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[29];
	 x[13] = data_in[2] ^ data_in[12] ^ data_in[15] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30];
	 x[14] = data_in[0] ^ data_in[13] ^ data_in[16] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[28];
	 x[15] = data_in[1] ^ data_in[14] ^ data_in[17] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[29];
	 x[16] = data_in[2] ^ data_in[15] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30];
	 x[17] = data_in[0] ^ data_in[16] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[28];
	 x[18] = data_in[1] ^ data_in[17] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[29];
	 x[19] = data_in[2] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30];
	 x[20] = data_in[0] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[28];
	 x[21] = data_in[1] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[29];
	 x[22] = data_in[2] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30];
	 x[23] = data_in[0] ^ data_in[22] ^ data_in[25] ^ data_in[28];
	 x[24] = data_in[1] ^ data_in[23] ^ data_in[26] ^ data_in[29];
	 x[25] = data_in[2] ^ data_in[24] ^ data_in[27] ^ data_in[30];
	 x[26] = data_in[0] ^ data_in[25] ^ data_in[28];
	 x[27] = data_in[1] ^ data_in[26] ^ data_in[29];
	 x[28] = data_in[2] ^ data_in[27] ^ data_in[30];
	 x[29] = data_in[0] ^ data_in[28];
	 x[30] = data_in[1] ^ data_in[29];
	 x[31] =  data_in[2] ^ data_in[30];
      end // else: !if(~nreset)
   end // always @ (posedge clk )
endmodule // prbs31_32bit_msb


module prbs7_40bit_msb(dout,
		       clk, 
		       data_in,
		       nreset
			) ;
   localparam 		   DATA_WIDTH = 40;
   output [DATA_WIDTH -1:0]dout;
   input [DATA_WIDTH -1:0] data_in;
   input 		   clk;
   input 		   nreset;
  

   
   reg [DATA_WIDTH-1:0]    x;
   assign 		   dout[DATA_WIDTH-1:0]  = x[DATA_WIDTH-1:0];
   
   always @ (*) begin
      if(~nreset) begin
	 x = data_in;
      end
      else begin
	 x[0] = data_in[0] ^ data_in[3] ^ data_in[4] ^ data_in[5];
	 x[1] = data_in[1] ^ data_in[4] ^ data_in[5] ^ data_in[6];
	 x[2] = data_in[0] ^ data_in[2] ^ data_in[5];
	 x[3] = data_in[1] ^ data_in[3] ^ data_in[6];
	 x[4] = data_in[0] ^ data_in[2] ^ data_in[4] ^ data_in[6];
	 x[5] = data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[6];
	 x[6] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[4];
	 x[7] = data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[5];
	 x[8] = data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[6];
	 x[9] = data_in[0] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6];
	 x[10] = data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[5];
	 x[11] = data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[6];
	 x[12] = data_in[0] ^ data_in[2] ^ data_in[3];
	 x[13] = data_in[1] ^ data_in[3] ^ data_in[4];
	 x[14] = data_in[2] ^ data_in[4] ^ data_in[5];
	 x[15] = data_in[3] ^ data_in[5] ^ data_in[6];
	 x[16] = data_in[0] ^ data_in[4];
	 x[17] = data_in[1] ^ data_in[5];
	 x[18] = data_in[2] ^ data_in[6];
	 x[19] = data_in[0] ^ data_in[3] ^ data_in[6];
	 x[20] = data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[6];
	 x[21] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[6];
	 x[22] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3];
	 x[23] = data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4];
	 x[24] = data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[5];
	 x[25] = data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6];
	 x[26] = data_in[0] ^ data_in[4] ^ data_in[5];
	 x[27] = data_in[1] ^ data_in[5] ^ data_in[6];
	 x[28] = data_in[0] ^ data_in[2];
	 x[29] = data_in[1] ^ data_in[3];
	 x[30] = data_in[2] ^ data_in[4];
	 x[31] = data_in[3] ^ data_in[5];
	 x[32] = data_in[4] ^ data_in[6];
	 x[33] = data_in[0] ^ data_in[5] ^ data_in[6];
	 x[34] = data_in[0] ^ data_in[1];
	 x[35] = data_in[1] ^ data_in[2];
	 x[36] = data_in[2] ^ data_in[3];
	 x[37] = data_in[3] ^ data_in[4];
	 x[38] = data_in[4] ^ data_in[5];
	 x[39] = data_in[5] ^ data_in[6];
      end 
   end // always @ (posedge clk )
endmodule // prbs7_40bit_msb


module prbs10_40bit_msb(dout,
			clk, 
			data_in,
			nreset
			) ;
   localparam 		   DATA_WIDTH = 40;
   output [DATA_WIDTH -1:0]dout;
   input [DATA_WIDTH -1:0] data_in;
   input 		   clk;
   input 		   nreset;
  

   
    reg [DATA_WIDTH-1:0]   x;
    assign dout[DATA_WIDTH-1:0]  = x[DATA_WIDTH-1:0];
   always @ (*) begin
      if(~nreset) begin
	 x = data_in;
      end
      else begin
	 x[0] = data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[9];
	 x[1] = data_in[0] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
	 x[2] = data_in[1] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[8];
	 x[3] = data_in[2] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[9];
	 x[4] = data_in[0] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[9];
	 x[5] = data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[7] ^ data_in[8] ^ data_in[9];
	 x[6] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[8] ^ data_in[9];
	 x[7] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[9];
	 x[8] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[6];
	 x[9] = data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7];
	 x[10] = data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[7] ^ data_in[8];
	 x[11] = data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[8] ^ data_in[9];
	 x[12] = data_in[0] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[9];
	 x[13] = data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
	 x[14] = data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[8];
	 x[15] = data_in[2] ^ data_in[3] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[9];
	 x[16] = data_in[0] ^ data_in[4] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[9];
	 x[17] = data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[7] ^ data_in[8] ^ data_in[9];
	 x[18] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[6] ^ data_in[8] ^ data_in[9];
	 x[19] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[7] ^ data_in[9];
	 x[20] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[6] ^ data_in[8];
	 x[21] = data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7] ^ data_in[9];
	 x[22] = data_in[0] ^ data_in[2] ^ data_in[4] ^ data_in[7] ^ data_in[8];
	 x[23] = data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[8] ^ data_in[9];
	 x[24] = data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[6] ^ data_in[9];
	 x[25] = data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[5] ^ data_in[7];
	 x[26] = data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[6] ^ data_in[8];
	 x[27] = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7] ^ data_in[9];
	 x[28] = data_in[0] ^ data_in[4] ^ data_in[7] ^ data_in[8];
	 x[29] = data_in[1] ^ data_in[5] ^ data_in[8] ^ data_in[9];
	 x[30] = data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[9];
	 x[31] = data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[7];
	 x[32] = data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[8];
	 x[33] = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[9];
	 x[34] = data_in[0] ^ data_in[4] ^ data_in[7];
	 x[35] = data_in[1] ^ data_in[5] ^ data_in[8];
	 x[36] = data_in[2] ^ data_in[6] ^ data_in[9];
	 x[37] = data_in[0] ^ data_in[7];
	 x[38] = data_in[1] ^ data_in[8];
	 x[39] = data_in[2] ^ data_in[9];
      end 
   end // always @ (posedge clk )
endmodule // prbs10_40bit_msb

module prbs23_40bit_msb(dout,
			clk, 
			data_in,
			nreset
			) ;
   localparam 		   DATA_WIDTH = 40;
   output [DATA_WIDTH -1:0]dout;
   input [DATA_WIDTH -1:0] data_in;
   input 		   clk;
   input 		   nreset;

   
    reg [DATA_WIDTH-1:0]   x;
    assign dout[DATA_WIDTH-1:0]  = x[DATA_WIDTH-1:0];
   always @ (*) begin
      if(~nreset) begin
	 x = data_in;
      end
      else begin
	 x[0] = data_in[6] ^ data_in[14] ^ data_in[19];
	 x[1] = data_in[7] ^ data_in[15] ^ data_in[20];
	 x[2] = data_in[8] ^ data_in[16] ^ data_in[21];
	 x[3] = data_in[9] ^ data_in[17] ^ data_in[22];
	 x[4] = data_in[0] ^ data_in[10];
	 x[5] = data_in[1] ^ data_in[11];
	 x[6] = data_in[2] ^ data_in[12];
	 x[7] = data_in[3] ^ data_in[13];
	 x[8] = data_in[4] ^ data_in[14];
	 x[9] = data_in[5] ^ data_in[15];
	 x[10] = data_in[6] ^ data_in[16];
	 x[11] = data_in[7] ^ data_in[17];
	 x[12] = data_in[8] ^ data_in[18];
	 x[13] = data_in[9] ^ data_in[19];
	 x[14] = data_in[10] ^ data_in[20];
	 x[15] = data_in[11] ^ data_in[21];
	 x[16] = data_in[12] ^ data_in[22];
	 x[17] = data_in[0] ^ data_in[13] ^ data_in[18];
	 x[18] = data_in[1] ^ data_in[14] ^ data_in[19];
	 x[19] = data_in[2] ^ data_in[15] ^ data_in[20];
	 x[20] = data_in[3] ^ data_in[16] ^ data_in[21];
	 x[21] = data_in[4] ^ data_in[17] ^ data_in[22];
	 x[22] = data_in[0] ^ data_in[5];
	 x[23] = data_in[1] ^ data_in[6];
	 x[24] = data_in[2] ^ data_in[7];
	 x[25] = data_in[3] ^ data_in[8];
	 x[26] = data_in[4] ^ data_in[9];
	 x[27] = data_in[5] ^ data_in[10];
	 x[28] = data_in[6] ^ data_in[11];
	 x[29] = data_in[7] ^ data_in[12];
	 x[30] = data_in[8] ^ data_in[13];
	 x[31] = data_in[9] ^ data_in[14];
	 x[32] = data_in[10] ^ data_in[15];
	 x[33] = data_in[11] ^ data_in[16];
	 x[34] = data_in[12] ^ data_in[17];
	 x[35] = data_in[13] ^ data_in[18];
	 x[36] = data_in[14] ^ data_in[19];
	 x[37] = data_in[15] ^ data_in[20];
	 x[38] = data_in[16] ^ data_in[21];
	 x[39] = data_in[17] ^ data_in[22];
      end 
   end // always @ (posedge clk )
endmodule // prbs23_40bit_msb



module prbs31_40bit_msb(dout,
			clk, 
			data_in,
			nreset
			) ;
   localparam 		   DATA_WIDTH = 40;
   output [DATA_WIDTH -1:0]dout;
   input [DATA_WIDTH -1:0] data_in;
   input 		   clk;
   input 		   nreset;

   
    reg [DATA_WIDTH-1:0]   x;
    assign dout[DATA_WIDTH-1:0]  = x[DATA_WIDTH-1:0];
    always @ (*) begin
       if(~nreset)begin
	  x = data_in;
       end
       else begin
	  x[0] = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[9] ^ data_in[12] ^ data_in[15] ^ data_in[18] ^ data_in[21] ^ data_in[22] ^ data_in[24] ^ data_in[27] ^ data_in[28] ^ data_in[30];
	  x[1] = data_in[0] ^ data_in[4] ^ data_in[7] ^ data_in[10] ^ data_in[13] ^ data_in[16] ^ data_in[19] ^ data_in[22] ^ data_in[23] ^ data_in[25] ^ data_in[28] ^ data_in[29];
	  x[2] = data_in[1] ^ data_in[5] ^ data_in[8] ^ data_in[11] ^ data_in[14] ^ data_in[17] ^ data_in[20] ^ data_in[23] ^ data_in[24] ^ data_in[26] ^ data_in[29] ^ data_in[30];
	  x[3] = data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[9] ^ data_in[12] ^ data_in[15] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[25] ^ data_in[27] ^ data_in[30];
	  x[4] = data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[7] ^ data_in[10] ^ data_in[13] ^ data_in[16] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[26] ^ data_in[28];
	  x[5] = data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[8] ^ data_in[11] ^ data_in[14] ^ data_in[17] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[27] ^ data_in[29];
	  x[6] = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[9] ^ data_in[12] ^ data_in[15] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[28] ^ data_in[30];
	  x[7] = data_in[0] ^ data_in[4] ^ data_in[7] ^ data_in[10] ^ data_in[13] ^ data_in[16] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[28] ^ data_in[29];
	  x[8] = data_in[1] ^ data_in[5] ^ data_in[8] ^ data_in[11] ^ data_in[14] ^ data_in[17] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[29] ^ data_in[30];
	  x[9] = data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[9] ^ data_in[12] ^ data_in[15] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30];
	  x[10] = data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[7] ^ data_in[10] ^ data_in[13] ^ data_in[16] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[28];
	  x[11] = data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[8] ^ data_in[11] ^ data_in[14] ^ data_in[17] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[29];
	  x[12] = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[9] ^ data_in[12] ^ data_in[15] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30];
	  x[13] = data_in[0] ^ data_in[4] ^ data_in[7] ^ data_in[10] ^ data_in[13] ^ data_in[16] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[28];
	  x[14] = data_in[1] ^ data_in[5] ^ data_in[8] ^ data_in[11] ^ data_in[14] ^ data_in[17] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[29];
	  x[15] = data_in[2] ^ data_in[6] ^ data_in[9] ^ data_in[12] ^ data_in[15] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30];
	  x[16] = data_in[0] ^ data_in[7] ^ data_in[10] ^ data_in[13] ^ data_in[16] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[28];
	  x[17] = data_in[1] ^ data_in[8] ^ data_in[11] ^ data_in[14] ^ data_in[17] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[29];
	  x[18] = data_in[2] ^ data_in[9] ^ data_in[12] ^ data_in[15] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30];
	  x[19] = data_in[0] ^ data_in[10] ^ data_in[13] ^ data_in[16] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[28];
	  x[20] = data_in[1] ^ data_in[11] ^ data_in[14] ^ data_in[17] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[29];
	  x[21] = data_in[2] ^ data_in[12] ^ data_in[15] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30];
	  x[22] = data_in[0] ^ data_in[13] ^ data_in[16] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[28];
	  x[23] = data_in[1] ^ data_in[14] ^ data_in[17] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[29];
	  x[24] = data_in[2] ^ data_in[15] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30];
	  x[25] = data_in[0] ^ data_in[16] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[28];
	  x[26] = data_in[1] ^ data_in[17] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[29];
	  x[27] = data_in[2] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30];
	  x[28] = data_in[0] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[28];
	  x[29] = data_in[1] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[29];
	  x[30] = data_in[2] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30];
	  x[31] = data_in[0] ^ data_in[22] ^ data_in[25] ^ data_in[28];
	  x[32] = data_in[1] ^ data_in[23] ^ data_in[26] ^ data_in[29];
	  x[33] = data_in[2] ^ data_in[24] ^ data_in[27] ^ data_in[30];
	  x[34] = data_in[0] ^ data_in[25] ^ data_in[28];
	  x[35] = data_in[1] ^ data_in[26] ^ data_in[29];
	  x[36] = data_in[2] ^ data_in[27] ^ data_in[30];
	  x[37] = data_in[0] ^ data_in[28];
	  x[38] = data_in[1] ^ data_in[29];
	  x[39] = data_in[2] ^ data_in[30];
       end 
    end // always @ (posedge clk )
endmodule // prbs31_40bit_msb

// 64 bit polynominal code
//-------------------------------------------------
// prbs23_64bit_msb.v
//
// Polynomial: x^23 + x^18 + 1
// Shifted by: 64 bits per clock cycle
// Transmit MSB first
//-------------------------------------------------
`timescale 1ns / 10ps

module prbs23_64bit_msb (dout, clk, data_in, nreset);

   localparam DATA_WIDTH = 64;
   
   output [DATA_WIDTH -1:0]dout;
   input [DATA_WIDTH -1:0] data_in;
   input 		   clk;
   input 		   nreset;
   
   reg [DATA_WIDTH-1:0]    x = 64'd0;
   
   assign dout[DATA_WIDTH-1:0]  = x[DATA_WIDTH-1:0];
   
   always @(*)
     begin
	if (~nreset)
	  x  = data_in;
	else
	  begin
	     x[0] = data_in[0] ^ data_in[5] ^ data_in[8] ^ data_in[18];
	     x[1] = data_in[1] ^ data_in[6] ^ data_in[9] ^ data_in[19];
	     x[2] = data_in[2] ^ data_in[7] ^ data_in[10] ^ data_in[20];
	     x[3] = data_in[3] ^ data_in[8] ^ data_in[11] ^ data_in[21];
	     x[4] = data_in[4] ^ data_in[9] ^ data_in[12] ^ data_in[22];
	     x[5] = data_in[0] ^ data_in[5] ^ data_in[10] ^ data_in[13] ^ data_in[18];
	     x[6] = data_in[1] ^ data_in[6] ^ data_in[11] ^ data_in[14] ^ data_in[19];
	     x[7] = data_in[2] ^ data_in[7] ^ data_in[12] ^ data_in[15] ^ data_in[20];
	     x[8] = data_in[3] ^ data_in[8] ^ data_in[13] ^ data_in[16] ^ data_in[21];
	     x[9] = data_in[4] ^ data_in[9] ^ data_in[14] ^ data_in[17] ^ data_in[22];
	     x[10] = data_in[0] ^ data_in[5] ^ data_in[10] ^ data_in[15];
	     x[11] = data_in[1] ^ data_in[6] ^ data_in[11] ^ data_in[16];
	     x[12] = data_in[2] ^ data_in[7] ^ data_in[12] ^ data_in[17];
	     x[13] = data_in[3] ^ data_in[8] ^ data_in[13] ^ data_in[18];
	     x[14] = data_in[4] ^ data_in[9] ^ data_in[14] ^ data_in[19];
	     x[15] = data_in[5] ^ data_in[10] ^ data_in[15] ^ data_in[20];
	     x[16] = data_in[6] ^ data_in[11] ^ data_in[16] ^ data_in[21];
	     x[17] = data_in[7] ^ data_in[12] ^ data_in[17] ^ data_in[22];
	     x[18] = data_in[0] ^ data_in[8] ^ data_in[13];
	     x[19] = data_in[1] ^ data_in[9] ^ data_in[14];
	     x[20] = data_in[2] ^ data_in[10] ^ data_in[15];
	     x[21] = data_in[3] ^ data_in[11] ^ data_in[16];
	     x[22] = data_in[4] ^ data_in[12] ^ data_in[17];
	     x[23] = data_in[5] ^ data_in[13] ^ data_in[18];
	     x[24] = data_in[6] ^ data_in[14] ^ data_in[19];
	     x[25] = data_in[7] ^ data_in[15] ^ data_in[20];
	     x[26] = data_in[8] ^ data_in[16] ^ data_in[21];
	     x[27] = data_in[9] ^ data_in[17] ^ data_in[22];
	     x[28] = data_in[0] ^ data_in[10];
	     x[29] = data_in[1] ^ data_in[11];
	     x[30] = data_in[2] ^ data_in[12];
	     x[31] = data_in[3] ^ data_in[13];
	     x[32] = data_in[4] ^ data_in[14];
	     x[33] = data_in[5] ^ data_in[15];
	     x[34] = data_in[6] ^ data_in[16];
	     x[35] = data_in[7] ^ data_in[17];
	     x[36] = data_in[8] ^ data_in[18];
	     x[37] = data_in[9] ^ data_in[19];
	     x[38] = data_in[10] ^ data_in[20];
	     x[39] = data_in[11] ^ data_in[21];
	     x[40] = data_in[12] ^ data_in[22];
	     x[41] = data_in[0] ^ data_in[13] ^ data_in[18];
	     x[42] = data_in[1] ^ data_in[14] ^ data_in[19];
	     x[43] = data_in[2] ^ data_in[15] ^ data_in[20];
	     x[44] = data_in[3] ^ data_in[16] ^ data_in[21];
	     x[45] = data_in[4] ^ data_in[17] ^ data_in[22];
	     x[46] = data_in[0] ^ data_in[5];
	     x[47] = data_in[1] ^ data_in[6];
	     x[48] = data_in[2] ^ data_in[7];
	     x[49] = data_in[3] ^ data_in[8];
	     x[50] = data_in[4] ^ data_in[9];
	     x[51] = data_in[5] ^ data_in[10];
	     x[52] = data_in[6] ^ data_in[11];
	     x[53] = data_in[7] ^ data_in[12];
	     x[54] = data_in[8] ^ data_in[13];
	     x[55] = data_in[9] ^ data_in[14];
	     x[56] = data_in[10] ^ data_in[15];
	     x[57] = data_in[11] ^ data_in[16];
	     x[58] = data_in[12] ^ data_in[17];
	     x[59] = data_in[13] ^ data_in[18];
	     x[60] = data_in[14] ^ data_in[19];
	     x[61] = data_in[15] ^ data_in[20];
	     x[62] = data_in[16] ^ data_in[21];
	     x[63] = data_in[17] ^ data_in[22];
	  end // else: !if(~nreset)
    end // always @ (*)
   
   
endmodule // prbs23_64bit_msb   

//-------------------------------------------------
// prbs7_64bit_msb.v -- PRBS 7
//
// Polynomial: x^7 + x^6 + 1
// Shifted by: 64 bits per clock cycle
// Transmit MSB first
//-------------------------------------------------
`timescale 1ns / 10ps

module prbs7_64bit_msb (dout, clk, data_in, nreset);

   localparam DATA_WIDTH = 64;   

   output [DATA_WIDTH -1:0]dout;
   input [DATA_WIDTH -1:0] data_in;
   input 		   clk;
   input 		   nreset;

  reg [DATA_WIDTH-1:0] x = 64'd0;   

   always @(*)
     begin
	if (~nreset)
	  x  = data_in;
	else
	  begin
             x[0] = data_in[2] ^ data_in[3] ^ data_in[5] ^ data_in[6];
             x[1] = data_in[0] ^ data_in[3] ^ data_in[4];
             x[2] = data_in[1] ^ data_in[4] ^ data_in[5];
             x[3] = data_in[2] ^ data_in[5] ^ data_in[6];
             x[4] = data_in[0] ^ data_in[3];
             x[5] = data_in[1] ^ data_in[4];
             x[6] = data_in[2] ^ data_in[5];
             x[7] = data_in[3] ^ data_in[6];
             x[8] = data_in[0] ^ data_in[4] ^ data_in[6];
             x[9] = data_in[0] ^ data_in[1] ^ data_in[5] ^ data_in[6];
             x[10] = data_in[0] ^ data_in[1] ^ data_in[2];
             x[11] = data_in[1] ^ data_in[2] ^ data_in[3];
             x[12] = data_in[2] ^ data_in[3] ^ data_in[4];
             x[13] = data_in[3] ^ data_in[4] ^ data_in[5];
             x[14] = data_in[4] ^ data_in[5] ^ data_in[6];
             x[15] = data_in[0] ^ data_in[5];
             x[16] = data_in[1] ^ data_in[6];
             x[17] = data_in[0] ^ data_in[2] ^ data_in[6];
             x[18] = data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[6];
             x[19] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[6];
             x[20] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[5] ^ data_in[6];
             x[21] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4];
             x[22] = data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[5];
             x[23] = data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6];
             x[24] = data_in[0] ^ data_in[3] ^ data_in[4] ^ data_in[5];
             x[25] = data_in[1] ^ data_in[4] ^ data_in[5] ^ data_in[6];
             x[26] = data_in[0] ^ data_in[2] ^ data_in[5];
             x[27] = data_in[1] ^ data_in[3] ^ data_in[6];
             x[28] = data_in[0] ^ data_in[2] ^ data_in[4] ^ data_in[6];
             x[29] = data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[6];
             x[30] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[4];
             x[31] = data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[5];
             x[32] = data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[6];
             x[33] = data_in[0] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6];
             x[34] = data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[5];
             x[35] = data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[6];
             x[36] = data_in[0] ^ data_in[2] ^ data_in[3];
             x[37] = data_in[1] ^ data_in[3] ^ data_in[4];
             x[38] = data_in[2] ^ data_in[4] ^ data_in[5];
             x[39] = data_in[3] ^ data_in[5] ^ data_in[6];
             x[40] = data_in[0] ^ data_in[4];
             x[41] = data_in[1] ^ data_in[5];
             x[42] = data_in[2] ^ data_in[6];
             x[43] = data_in[0] ^ data_in[3] ^ data_in[6];
             x[44] = data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[6];
             x[45] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[6];
             x[46] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3];
             x[47] = data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4];
             x[48] = data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[5];
             x[49] = data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6];
             x[50] = data_in[0] ^ data_in[4] ^ data_in[5];
             x[51] = data_in[1] ^ data_in[5] ^ data_in[6];
             x[52] = data_in[0] ^ data_in[2];
             x[53] = data_in[1] ^ data_in[3];
             x[54] = data_in[2] ^ data_in[4];
             x[55] = data_in[3] ^ data_in[5];
             x[56] = data_in[4] ^ data_in[6];
             x[57] = data_in[0] ^ data_in[5] ^ data_in[6];
             x[58] = data_in[0] ^ data_in[1];
             x[59] = data_in[1] ^ data_in[2];
             x[60] = data_in[2] ^ data_in[3];
             x[61] = data_in[3] ^ data_in[4];
             x[62] = data_in[4] ^ data_in[5];
             x[63] = data_in[5] ^ data_in[6];
	  end // else: !if(~nreset)
     end // always @ (*)
   
	     
endmodule // prbs7_64bit_msb


//-------------------------------------------------
// prbs10_64bit_msb.v -- PRBS 10
//
// Polynomial: x^10 + x^3 + 1
// Shifted by: 64 bits per clock cycle
// Transmit MSB first
//-------------------------------------------------
`timescale 1ns / 10ps

module prbs10_64bit_msb (dout, clk, data_in, nreset);


   localparam DATA_WIDTH = 64;
   
   output [DATA_WIDTH -1:0]dout;
   input [DATA_WIDTH -1:0] data_in;
   input 		   clk;
   input 		   nreset;
   
   reg [DATA_WIDTH-1:0]    x = 64'd0;
   
   assign dout[DATA_WIDTH-1:0]  = x[DATA_WIDTH-1:0];

   always @(*)
     begin
	if (~nreset)
	  x  = data_in;
	else
	  begin
	     x[0] = data_in[3] ^ data_in[4] ^ data_in[5];
             x[1] = data_in[4] ^ data_in[5] ^ data_in[6];
             x[2] = data_in[5] ^ data_in[6] ^ data_in[7];
             x[3] = data_in[6] ^ data_in[7] ^ data_in[8];
             x[4] = data_in[7] ^ data_in[8] ^ data_in[9];
             x[5] = data_in[0] ^ data_in[3] ^ data_in[8] ^ data_in[9];
             x[6] = data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[4] ^ data_in[9];
             x[7] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[5];
             x[8] = data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6];
             x[9] = data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
             x[10] = data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[8];
             x[11] = data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[9];
             x[12] = data_in[0] ^ data_in[3] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[9];
             x[13] = data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[4] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[9];
             x[14] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[7] ^ data_in[8] ^ data_in[9];
             x[15] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[8] ^ data_in[9];
             x[16] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[9];
             x[17] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[6] ^ data_in[7] ^ data_in[8];
             x[18] = data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[7] ^ data_in[8] ^ data_in[9];
             x[19] = data_in[0] ^ data_in[2] ^ data_in[4] ^ data_in[8] ^ data_in[9];
             x[20] = data_in[0] ^ data_in[1] ^ data_in[5] ^ data_in[9];
             x[21] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[6];
             x[22] = data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[7];
             x[23] = data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[8];
             x[24] = data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[9];
             x[25] = data_in[0] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
             x[26] = data_in[1] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[8];
             x[27] = data_in[2] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[9];
             x[28] = data_in[0] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[9];
             x[29] = data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[7] ^ data_in[8] ^ data_in[9];
             x[30] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[8] ^ data_in[9];
             x[31] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[9];
             x[32] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[6];
             x[33] = data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7];
             x[34] = data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[7] ^ data_in[8];
             x[35] = data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[8] ^ data_in[9];
             x[36] = data_in[0] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[9];
             x[37] = data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
             x[38] = data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[8];
             x[39] = data_in[2] ^ data_in[3] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[9];
             x[40] = data_in[0] ^ data_in[4] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[9];
             x[41] = data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[7] ^ data_in[8] ^ data_in[9];
             x[42] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[6] ^ data_in[8] ^ data_in[9];
             x[43] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[7] ^ data_in[9];
             x[44] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[6] ^ data_in[8];
             x[45] = data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7] ^ data_in[9];
             x[46] = data_in[0] ^ data_in[2] ^ data_in[4] ^ data_in[7] ^ data_in[8];
             x[47] = data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[8] ^ data_in[9];
             x[48] = data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[6] ^ data_in[9];
             x[49] = data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[5] ^ data_in[7];
             x[50] = data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[6] ^ data_in[8];
             x[51] = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7] ^ data_in[9];
             x[52] = data_in[0] ^ data_in[4] ^ data_in[7] ^ data_in[8];
             x[53] = data_in[1] ^ data_in[5] ^ data_in[8] ^ data_in[9];
             x[54] = data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[9];
             x[55] = data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[7];
             x[56] = data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[8];
             x[57] = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[9];
             x[58] = data_in[0] ^ data_in[4] ^ data_in[7];
             x[59] = data_in[1] ^ data_in[5] ^ data_in[8];
             x[60] = data_in[2] ^ data_in[6] ^ data_in[9];
             x[61] = data_in[0] ^ data_in[7];
             x[62] = data_in[1] ^ data_in[8];
             x[63] = data_in[2] ^ data_in[9];
	  end
     end
endmodule // prbs10_64bit_msb


//-------------------------------------------------
// prbs31_64bit_msb.v -- PRBS 31
//
// Polynomial: x^31 + x^3 + 1
// Shifted by: 64 bits per clock cycle
// Transmit MSB first
//-------------------------------------------------
`timescale 1ns / 10ps

module prbs31_64bit_msb (dout, clk, data_in, nreset);

   localparam DATA_WIDTH = 64;
   
   output [DATA_WIDTH -1:0]dout;
   input [DATA_WIDTH -1:0] data_in;
   input 		   clk;
   input 		   nreset;
   
   reg [DATA_WIDTH-1:0]    x = 64'd0;
   
   assign dout[DATA_WIDTH-1:0]  = x[DATA_WIDTH-1:0];
   
  
   always @(*)
     begin
	if (~nreset)
	  x  = data_in;
	else
	  begin   

	     x[0] = data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[6] ^ data_in[9] ^ data_in[10] ^ data_in[12] ^ data_in[15] ^ data_in[16] ^ data_in[18] ^ data_in[21] ^ data_in[22] ^ data_in[24] ^ data_in[27] ^ data_in[28] ^ data_in[29] ^ data_in[30];
             x[1] = data_in[0] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[7] ^ data_in[10] ^ data_in[11] ^ data_in[13] ^ data_in[16] ^ data_in[17] ^ data_in[19] ^ data_in[22] ^ data_in[23] ^ data_in[25] ^ data_in[28] ^ data_in[29] ^ data_in[30];
             x[2] = data_in[0] ^ data_in[1] ^ data_in[5] ^ data_in[6] ^ data_in[8] ^ data_in[11] ^ data_in[12] ^ data_in[14] ^ data_in[17] ^ data_in[18] ^ data_in[20] ^ data_in[23] ^ data_in[24] ^ data_in[26] ^ data_in[29] ^ data_in[30];
             x[3] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7] ^ data_in[9] ^ data_in[12] ^ data_in[13] ^ data_in[15] ^ data_in[18] ^ data_in[19] ^ data_in[21] ^ data_in[24] ^ data_in[25] ^ data_in[27] ^ data_in[30];
             x[4] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[7] ^ data_in[8] ^ data_in[10] ^ data_in[13] ^ data_in[14] ^ data_in[16] ^ data_in[19] ^ data_in[20] ^ data_in[22] ^ data_in[25] ^ data_in[26] ^ data_in[28];
             x[5] = data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[5] ^ data_in[8] ^ data_in[9] ^ data_in[11] ^ data_in[14] ^ data_in[15] ^ data_in[17] ^ data_in[20] ^ data_in[21] ^ data_in[23] ^ data_in[26] ^ data_in[27] ^ data_in[29];
             x[6] = data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[6] ^ data_in[9] ^ data_in[10] ^ data_in[12] ^ data_in[15] ^ data_in[16] ^ data_in[18] ^ data_in[21] ^ data_in[22] ^ data_in[24] ^ data_in[27] ^ data_in[28] ^ data_in[30];
             x[7] = data_in[0] ^ data_in[4] ^ data_in[5] ^ data_in[7] ^ data_in[10] ^ data_in[11] ^ data_in[13] ^ data_in[16] ^ data_in[17] ^ data_in[19] ^ data_in[22] ^ data_in[23] ^ data_in[25] ^ data_in[28] ^ data_in[29];
             x[8] = data_in[1] ^ data_in[5] ^ data_in[6] ^ data_in[8] ^ data_in[11] ^ data_in[12] ^ data_in[14] ^ data_in[17] ^ data_in[18] ^ data_in[20] ^ data_in[23] ^ data_in[24] ^ data_in[26] ^ data_in[29] ^ data_in[30];
             x[9] = data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7] ^ data_in[9] ^ data_in[12] ^ data_in[13] ^ data_in[15] ^ data_in[18] ^ data_in[19] ^ data_in[21] ^ data_in[24] ^ data_in[25] ^ data_in[27] ^ data_in[30];
             x[10] = data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[7] ^ data_in[8] ^ data_in[10] ^ data_in[13] ^ data_in[14] ^ data_in[16] ^ data_in[19] ^ data_in[20] ^ data_in[22] ^ data_in[25] ^ data_in[26] ^ data_in[28];
             x[11] = data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[8] ^ data_in[9] ^ data_in[11] ^ data_in[14] ^ data_in[15] ^ data_in[17] ^ data_in[20] ^ data_in[21] ^ data_in[23] ^ data_in[26] ^ data_in[27] ^ data_in[29];
             x[12] = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[9] ^ data_in[10] ^ data_in[12] ^ data_in[15] ^ data_in[16] ^ data_in[18] ^ data_in[21] ^ data_in[22] ^ data_in[24] ^ data_in[27] ^ data_in[28] ^ data_in[30];
             x[13] = data_in[0] ^ data_in[4] ^ data_in[7] ^ data_in[10] ^ data_in[11] ^ data_in[13] ^ data_in[16] ^ data_in[17] ^ data_in[19] ^ data_in[22] ^ data_in[23] ^ data_in[25] ^ data_in[28] ^ data_in[29];
             x[14] = data_in[1] ^ data_in[5] ^ data_in[8] ^ data_in[11] ^ data_in[12] ^ data_in[14] ^ data_in[17] ^ data_in[18] ^ data_in[20] ^ data_in[23] ^ data_in[24] ^ data_in[26] ^ data_in[29] ^ data_in[30];
             x[15] = data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[9] ^ data_in[12] ^ data_in[13] ^ data_in[15] ^ data_in[18] ^ data_in[19] ^ data_in[21] ^ data_in[24] ^ data_in[25] ^ data_in[27] ^ data_in[30];
             x[16] = data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[7] ^ data_in[10] ^ data_in[13] ^ data_in[14] ^ data_in[16] ^ data_in[19] ^ data_in[20] ^ data_in[22] ^ data_in[25] ^ data_in[26] ^ data_in[28];
             x[17] = data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[8] ^ data_in[11] ^ data_in[14] ^ data_in[15] ^ data_in[17] ^ data_in[20] ^ data_in[21] ^ data_in[23] ^ data_in[26] ^ data_in[27] ^ data_in[29];
             x[18] = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[9] ^ data_in[12] ^ data_in[15] ^ data_in[16] ^ data_in[18] ^ data_in[21] ^ data_in[22] ^ data_in[24] ^ data_in[27] ^ data_in[28] ^ data_in[30];
             x[19] = data_in[0] ^ data_in[4] ^ data_in[7] ^ data_in[10] ^ data_in[13] ^ data_in[16] ^ data_in[17] ^ data_in[19] ^ data_in[22] ^ data_in[23] ^ data_in[25] ^ data_in[28] ^ data_in[29];
             x[20] = data_in[1] ^ data_in[5] ^ data_in[8] ^ data_in[11] ^ data_in[14] ^ data_in[17] ^ data_in[18] ^ data_in[20] ^ data_in[23] ^ data_in[24] ^ data_in[26] ^ data_in[29] ^ data_in[30];
             x[21] = data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[9] ^ data_in[12] ^ data_in[15] ^ data_in[18] ^ data_in[19] ^ data_in[21] ^ data_in[24] ^ data_in[25] ^ data_in[27] ^ data_in[30];
             x[22] = data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[7] ^ data_in[10] ^ data_in[13] ^ data_in[16] ^ data_in[19] ^ data_in[20] ^ data_in[22] ^ data_in[25] ^ data_in[26] ^ data_in[28];
             x[23] = data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[8] ^ data_in[11] ^ data_in[14] ^ data_in[17] ^ data_in[20] ^ data_in[21] ^ data_in[23] ^ data_in[26] ^ data_in[27] ^ data_in[29];
             x[24] = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[9] ^ data_in[12] ^ data_in[15] ^ data_in[18] ^ data_in[21] ^ data_in[22] ^ data_in[24] ^ data_in[27] ^ data_in[28] ^ data_in[30];
             x[25] = data_in[0] ^ data_in[4] ^ data_in[7] ^ data_in[10] ^ data_in[13] ^ data_in[16] ^ data_in[19] ^ data_in[22] ^ data_in[23] ^ data_in[25] ^ data_in[28] ^ data_in[29];
             x[26] = data_in[1] ^ data_in[5] ^ data_in[8] ^ data_in[11] ^ data_in[14] ^ data_in[17] ^ data_in[20] ^ data_in[23] ^ data_in[24] ^ data_in[26] ^ data_in[29] ^ data_in[30];
             x[27] = data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[9] ^ data_in[12] ^ data_in[15] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[25] ^ data_in[27] ^ data_in[30];
             x[28] = data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[7] ^ data_in[10] ^ data_in[13] ^ data_in[16] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[26] ^ data_in[28];
             x[29] = data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[8] ^ data_in[11] ^ data_in[14] ^ data_in[17] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[27] ^ data_in[29];
             x[30] = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[9] ^ data_in[12] ^ data_in[15] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[28] ^ data_in[30];
             x[31] = data_in[0] ^ data_in[4] ^ data_in[7] ^ data_in[10] ^ data_in[13] ^ data_in[16] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[28] ^ data_in[29];
             x[32] = data_in[1] ^ data_in[5] ^ data_in[8] ^ data_in[11] ^ data_in[14] ^ data_in[17] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[29] ^ data_in[30];
             x[33] = data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[9] ^ data_in[12] ^ data_in[15] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30];
             x[34] = data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[7] ^ data_in[10] ^ data_in[13] ^ data_in[16] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[28];
             x[35] = data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[8] ^ data_in[11] ^ data_in[14] ^ data_in[17] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[29];
             x[36] = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[9] ^ data_in[12] ^ data_in[15] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30];
             x[37] = data_in[0] ^ data_in[4] ^ data_in[7] ^ data_in[10] ^ data_in[13] ^ data_in[16] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[28];
             x[38] = data_in[1] ^ data_in[5] ^ data_in[8] ^ data_in[11] ^ data_in[14] ^ data_in[17] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[29];
             x[39] = data_in[2] ^ data_in[6] ^ data_in[9] ^ data_in[12] ^ data_in[15] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30];
             x[40] = data_in[0] ^ data_in[7] ^ data_in[10] ^ data_in[13] ^ data_in[16] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[28];
             x[41] = data_in[1] ^ data_in[8] ^ data_in[11] ^ data_in[14] ^ data_in[17] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[29];
             x[42] = data_in[2] ^ data_in[9] ^ data_in[12] ^ data_in[15] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30];
             x[43] = data_in[0] ^ data_in[10] ^ data_in[13] ^ data_in[16] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[28];
             x[44] = data_in[1] ^ data_in[11] ^ data_in[14] ^ data_in[17] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[29];
             x[45] = data_in[2] ^ data_in[12] ^ data_in[15] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30];
             x[46] = data_in[0] ^ data_in[13] ^ data_in[16] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[28];
             x[47] = data_in[1] ^ data_in[14] ^ data_in[17] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[29];
             x[48] = data_in[2] ^ data_in[15] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30];
             x[49] = data_in[0] ^ data_in[16] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[28];
             x[50] = data_in[1] ^ data_in[17] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[29];
             x[51] = data_in[2] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30];
             x[52] = data_in[0] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[28];
             x[53] = data_in[1] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[29];
             x[54] = data_in[2] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30];
             x[55] = data_in[0] ^ data_in[22] ^ data_in[25] ^ data_in[28];
             x[56] = data_in[1] ^ data_in[23] ^ data_in[26] ^ data_in[29];
             x[57] = data_in[2] ^ data_in[24] ^ data_in[27] ^ data_in[30];
             x[58] = data_in[0] ^ data_in[25] ^ data_in[28];
             x[59] = data_in[1] ^ data_in[26] ^ data_in[29];
             x[60] = data_in[2] ^ data_in[27] ^ data_in[30];
             x[61] = data_in[0] ^ data_in[28];
             x[62] = data_in[1] ^ data_in[29];
             x[63] = data_in[2] ^ data_in[30];
	  end // else: !if(~nreset)
     end // always @ (*)
endmodule // prbs31_64bit_msb



