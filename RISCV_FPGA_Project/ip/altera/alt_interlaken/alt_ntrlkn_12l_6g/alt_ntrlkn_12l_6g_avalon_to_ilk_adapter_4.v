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
module alt_ntrlkn_12l_6g_avalon_to_ilk_adapter_4
  #(
    parameter WORDS = 4,
    parameter LOG_WORDS = 3
    )
   (
    // Avalon side
    input [WORDS*64-1:0] avl_data,
    input avl_sop,

    input avl_eop,
    input avl_valid,

    input [4:0] avl_empty,
    input avl_error,
    output avl_ready,

    // Interlaken side
    output [WORDS*64-1:0] ilk_data,
    output reg [LOG_WORDS-1:0] ilk_num_valid, // integer signaling how many valid words
    output ilk_sop,
    output reg [3:0] ilk_eopbits, // avl eop, empty, and error encoded here
    output ilk_valid,
    input ilk_ready
    );

   genvar i;
   wire valid_eop_error_w = |(avl_eop & avl_valid & avl_error);
   assign ilk_data = avl_data; // interlaken data

   always @(avl_valid or avl_empty or avl_eop or valid_eop_error_w) begin
      if(avl_eop === 1'b0 && avl_valid === 1'b1) begin
	 //not end of packet, any valid word should be filled out
	 case(avl_empty)
	   5'b00000: begin
	      ilk_num_valid <= 4;
	      ilk_eopbits 	 <= 4'b0000;

	   end
	   5'b01000: begin
	      ilk_num_valid <= 3;
	      ilk_eopbits 	 <= 4'b0000;

	   end
	   5'b10000: begin
	      ilk_num_valid <= 2;
	      ilk_eopbits 	 <= 4'b0000;

	   end
	   5'b11000: begin
	      ilk_num_valid <= 1;
	      ilk_eopbits 	 <= 4'b0000;

	   end
	   default: begin
	      //any other value should not be valid in non-eop
	      //default to nothing valid
	      ilk_num_valid <= 0;
	      ilk_eopbits 	 <= 4'b0000;

	   end

	 endcase // case (avl_empty)

      end // if (avl_eop 	  === 4'b0000 && avl_valid === 1'b1)
      else if(avl_valid === 1'b1) begin
	 //enter this section on valid data with eop
	 if(avl_empty < 5'b01000) begin
	    ilk_num_valid <= 4;

	 end
	 else if(avl_empty < 5'b10000) begin
	    ilk_num_valid 	 <= 3;

	 end
	 else if(avl_empty < 5'b11000) begin
	    ilk_num_valid <= 2;

	 end
	 else begin
	    ilk_num_valid <= 1;

	 end

	 //Now need to determing EOP bits from empty value
	 if(valid_eop_error_w) begin
	    ilk_eopbits   <= 4'b0001;

	 end
	 else begin
      	    case (avl_empty[2:0])
	      3'b000 : ilk_eopbits <= 4'b1000;
	      3'b001 : ilk_eopbits <= 4'b1111;
	      3'b010 : ilk_eopbits <= 4'b1110;
	      3'b011 : ilk_eopbits <= 4'b1101;
	      3'b100 : ilk_eopbits <= 4'b1100;
	      3'b101 : ilk_eopbits <= 4'b1011;
	      3'b110 : ilk_eopbits <= 4'b1010;
	      3'b111 : ilk_eopbits <= 4'b1001;
	    endcase // case (avl_empty[2:0])
	 end // else: !if(valid_eop_error_w)

      end
      else begin
	 //enter this section if no valid data
	 ilk_num_valid 	 <= 0;
	 ilk_eopbits 	 <= 4'b0000;

      end


   end



   assign ilk_sop = avl_sop;


   assign ilk_valid = avl_valid;

   assign avl_ready = ilk_ready; // ready

endmodule