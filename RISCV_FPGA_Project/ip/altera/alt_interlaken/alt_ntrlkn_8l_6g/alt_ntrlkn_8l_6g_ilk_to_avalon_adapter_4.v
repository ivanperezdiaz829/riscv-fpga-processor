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


module alt_ntrlkn_8l_6g_ilk_to_avalon_adapter_4
  #(
    parameter WORDS = 4,
    parameter LOG_WORDS = 3
    )
   (
    // Avalon side
    output [WORDS*64-1:0] avl_data,
    output avl_sop,

    output reg avl_eop,
    output reg avl_valid,

    output reg [4:0] avl_empty,
    output reg avl_error,

    // Interlaken side
    input ilk_valid,
    input [WORDS*64-1:0] ilk_data,
    input [LOG_WORDS-1:0] ilk_num_valid, // integer signaling how many valid words
    input ilk_sop,
    input [3:0] ilk_eopbits // avl eop, empty, and error encoded here
    );

   genvar i;

   assign avl_data   = ilk_data;

   assign avl_sop    = ilk_sop;

   always @(ilk_num_valid or ilk_eopbits or ilk_valid) begin
      //assign avl_valid, avl_error, avl_eop,  and avl_empty
      if(ilk_valid === 1) begin
	 case(ilk_num_valid)
	   0: begin
	      avl_valid <= 0;
	      avl_error <= 0;
	      avl_empty <= 0;
	      avl_eop   <= 0;

	   end
	   1: begin
	      avl_valid <= 1;

	      case(ilk_eopbits)
		4'b0000: begin
		   avl_eop   <= 0;
		   avl_error <= 0;
		   avl_empty <= 24;

		end

		4'b0001: begin
		   avl_error <= 1;
		   avl_empty <= 0;
		   avl_eop   <= 1;

		end
		4'b1000: begin
		   avl_error <= 0;
		   avl_empty <= 24;
		   avl_eop   <= 1;

		end
		4'b1001: begin
		   avl_error <= 0;
		   avl_empty <= 31;
		   avl_eop   <= 1;
		end
		4'b1010: begin
		   avl_error <= 0;
		   avl_empty <= 30;
		   avl_eop   <= 1;
		end
		4'b1011: begin
		   avl_error <= 0;
		   avl_empty <= 29;
		   avl_eop   <= 1;
		end
		4'b1100: begin
		   avl_error <= 0;
		   avl_empty <= 28;
		   avl_eop   <= 1;
		end
		4'b1101: begin
		   avl_error <= 0;
		   avl_empty <= 27;
		   avl_eop   <= 1;
		end
		4'b1110: begin
		   avl_error <= 0;
		   avl_empty <= 26;
		   avl_eop   <= 1;
		end
		4'b1111: begin
		   avl_error <= 0;
		   avl_empty <= 25;
		   avl_eop   <= 1;
		end
		default: begin
		   avl_error <= 1;
		   avl_empty <= 0;
		   avl_eop   <= 1;
		end

	      endcase // case (ilk_eopbits)

	   end
	   2: begin
	      avl_valid <= 1;

	      case(ilk_eopbits)
		4'b0000: begin
		   avl_eop   <= 0;
		   avl_error <= 0;
		   avl_empty <= 16;

		end

		4'b0001: begin
		   avl_error <= 1;
		   avl_empty <= 0;
		   avl_eop   <= 1;

		end
		4'b1000: begin
		   avl_error <= 0;
		   avl_empty <= 16;
		   avl_eop   <= 1;

		end
		4'b1001: begin
		   avl_error <= 0;
		   avl_empty <= 23;
		   avl_eop   <= 1;
		end
		4'b1010: begin
		   avl_error <= 0;
		   avl_empty <= 22;
		   avl_eop   <= 1;
		end
		4'b1011: begin
		   avl_error <= 0;
		   avl_empty <= 21;
		   avl_eop   <= 1;
		end
		4'b1100: begin
		   avl_error <= 0;
		   avl_empty <= 20;
		   avl_eop   <= 1;
		end
		4'b1101: begin
		   avl_error <= 0;
		   avl_empty <= 19;
		   avl_eop   <= 1;
		end
		4'b1110: begin
		   avl_error <= 0;
		   avl_empty <= 18;
		   avl_eop   <= 1;
		end
		4'b1111: begin
		   avl_error <= 0;
		   avl_empty <= 17;
		   avl_eop   <= 1;
		end
		default: begin
		   avl_error <= 1;
		   avl_empty <= 0;
		   avl_eop   <= 1;
		end

	      endcase // case (ilk_eopbits)

	   end
	   3: begin
	      avl_valid <= 1;

	      case(ilk_eopbits)
		4'b0000: begin
		   avl_eop   <= 0;
		   avl_error <= 0;
		   avl_empty <= 8;

		end

		4'b0001: begin
		   avl_error <= 1;
		   avl_empty <= 0;
		   avl_eop   <= 1;

		end
		4'b1000: begin
		   avl_error <= 0;
		   avl_empty <= 8;
		   avl_eop   <= 1;

		end
		4'b1001: begin
		   avl_error <= 0;
		   avl_empty <= 15;
		   avl_eop   <= 1;
		end
		4'b1010: begin
		   avl_error <= 0;
		   avl_empty <= 14;
		   avl_eop   <= 1;
		end
		4'b1011: begin
		   avl_error <= 0;
		   avl_empty <= 13;
		   avl_eop   <= 1;
		end
		4'b1100: begin
		   avl_error <= 0;
		   avl_empty <= 12;
		   avl_eop   <= 1;
		end
		4'b1101: begin
		   avl_error <= 0;
		   avl_empty <= 11;
		   avl_eop   <= 1;
		end
		4'b1110: begin
		   avl_error <= 0;
		   avl_empty <= 10;
		   avl_eop   <= 1;
		end
		4'b1111: begin
		   avl_error <= 0;
		   avl_empty <= 9;
		   avl_eop   <= 1;
		end
		default: begin
		   avl_error <= 1;
		   avl_empty <= 0;
		   avl_eop   <= 1;
		end

	      endcase // case (ilk_eopbits)

	   end
	   4: begin
	      avl_valid <= 1;

	      case(ilk_eopbits)
		4'b0000: begin
		   avl_eop   <= 0;
		   avl_error <= 0;
		   avl_empty <= 0;

		end

		4'b0001: begin
		   avl_error <= 1;
		   avl_empty <= 0;
		   avl_eop   <= 1;

		end
		4'b1000: begin
		   avl_error <= 0;
		   avl_empty <= 0;
		   avl_eop   <= 1;

		end
		4'b1001: begin
		   avl_error <= 0;
		   avl_empty <= 7;
		   avl_eop   <= 1;
		end
		4'b1010: begin
		   avl_error <= 0;
		   avl_empty <= 6;
		   avl_eop   <= 1;
		end
		4'b1011: begin
		   avl_error <= 0;
		   avl_empty <= 5;
		   avl_eop   <= 1;
		end
		4'b1100: begin
		   avl_error <= 0;
		   avl_empty <= 4;
		   avl_eop   <= 1;
		end
		4'b1101: begin
		   avl_error <= 0;
		   avl_empty <= 3;
		   avl_eop   <= 1;
		end
		4'b1110: begin
		   avl_error <= 0;
		   avl_empty <= 2;
		   avl_eop   <= 1;
		end
		4'b1111: begin
		   avl_error <= 0;
		   avl_empty <= 1;
		   avl_eop   <= 1;
		end
		default: begin
		   avl_error <= 1;
		   avl_empty <= 0;
		   avl_eop   <= 1;
		end

	      endcase // case (ilk_eopbits)

	   end

	   default: begin
	      avl_error <= 0;
	      avl_empty <= 0;
	      avl_eop   <= 0;
	      avl_valid <= 0;

	   end

	 endcase // case (ilk_num_valid)
      end // if (ilk_valid === 1)
      else begin
	 avl_error <= 0;
	 avl_empty <= 0;
	 avl_eop   <= 0;
	 avl_valid <= 0;
      end // else: !if(ilk_valid === 1)

   end

endmodule