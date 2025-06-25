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


// (C) 2001-2010 Altera Corporation. All rights reserved.
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

// baeckler - 09-28-2009

module alt_ntrlkn_sample_channel_client #(
					  parameter WORDS = 8,
					  parameter LOG_WORDS = 4,
					  parameter EMPTY_BITS = 6,
					  parameter BUFFER_WORDS = 2*WORDS,
					  parameter [BUFFER_WORDS*64-1:0] TX_STRING  = 
					  // ........--------........--------........--------........--------
					  {"Alpha Bravo Charlie Delta Golf Hotel India Juliet Kilo Lima Mike" },
					  parameter [BUFFER_WORDS*64-1:0] RX_STRING  = 
					  // ........--------........--------........--------........--------
					  {"Alpha Bravo Charlie Delta Golf Hotel India Juliet Kilo Lima Mike" }
					  )
   (
    input tx_clk,tx_arst,
    input rx_clk,rx_arst,
    output din_ready,
   
    input [WORDS*64-1:0] avl_data_in,
    input avl_sop_in,
    input avl_eop_in,
    input avl_data_valid_in,
    input [EMPTY_BITS-1:0] avl_empty_in,
    input avl_error_in,

    output [WORDS*64-1:0] avl_data_out,
    output avl_sop_out,
    output [EMPTY_BITS-1:0] avl_empty_out,
    output avl_eop_out,
    output avl_valid_out,
    output avl_error_out,
    input avl_ready_in,
   
    output [31:0] tx_counter,
    output [31:0] rx_counter

    );

   //generate block should correct one of 3 modules to instantiate based on the
   //WORDS parameter
   generate
      if(WORDS == 8) begin: words_8
	 //instantiation of the 8 word version of the sample_channel_client
	 alt_ntrlkn_sample_channel_client_8_word sample_channel_client_8 (
									  .tx_clk(tx_clk),
									  .tx_arst(tx_arst),
									  .din_ready(din_ready),
									  .rx_clk(rx_clk),
									  .rx_arst(rx_arst),
									  .avl_data_in(avl_data_in),
									  .avl_sop_in(avl_sop_in),
									  .avl_eop_in(avl_eop_in),
									  .avl_data_valid_in(avl_data_valid_in),
									  .avl_empty_in(avl_empty_in),
									  .avl_error_in(avl_error_in),
									  .avl_data_out(avl_data_out),
									  .avl_sop_out(avl_sop_out),
									  .avl_empty_out(avl_empty_out),
									  .avl_eop_out(avl_eop_out),
									  .avl_valid_out(avl_valid_out),
									  .avl_error_out(avl_error_out),
									  .avl_ready_in(avl_ready_in),
									  .tx_counter(tx_counter),
									  .rx_counter(rx_counter)
									  );
	 //pass on all paramters and directly pass through all inputs/outputs
	 defparam sample_channel_client_8.WORDS 	= WORDS;
	 defparam sample_channel_client_8.LOG_WORDS 	= LOG_WORDS;
	 defparam sample_channel_client_8.BUFFER_WORDS 	= BUFFER_WORDS;
	 defparam sample_channel_client_8.TX_STRING 	= TX_STRING;
	 defparam sample_channel_client_8.RX_STRING 	= RX_STRING;
	 
	 
      end
      else if(WORDS == 4) begin: words_4
 	 //instantiation of the 4 word version of the sample_channel_client
	 alt_ntrlkn_sample_channel_client_4_word sample_channel_client_4 (
									  .tx_clk(tx_clk),
									  .tx_arst(tx_arst),
									  .din_ready(din_ready),
									  .rx_clk(rx_clk),
									  .rx_arst(rx_arst),	    
									  .avl_data_in(avl_data_in),
									  .avl_sop_in(avl_sop_in),
									  .avl_eop_in(avl_eop_in),
									  .avl_data_valid_in(avl_data_valid_in),
									  .avl_empty_in(avl_empty_in),
									  .avl_error_in(avl_error_in),
									  .avl_data_out(avl_data_out),
									  .avl_sop_out(avl_sop_out),
									  .avl_empty_out(avl_empty_out),
									  .avl_eop_out(avl_eop_out),
									  .avl_valid_out(avl_valid_out),
									  .avl_error_out(avl_error_out),
									  .avl_ready_in(avl_ready_in),
									  .tx_counter(tx_counter),
									  .rx_counter(rx_counter)
									  );
	 //pass on all paramters and directly pass through all inputs/outputs
	 defparam sample_channel_client_4.WORDS 	= WORDS;
	 defparam sample_channel_client_4.LOG_WORDS 	= LOG_WORDS;
	 defparam sample_channel_client_4.BUFFER_WORDS 	= BUFFER_WORDS;
	 defparam sample_channel_client_4.TX_STRING 	= TX_STRING;
	 defparam sample_channel_client_4.RX_STRING 	= RX_STRING;
      end
      else if(WORDS == 2) begin: words_2
	 //instantiation of the 2 word version of the sample_channel_client	 
	 alt_ntrlkn_sample_channel_client_2_word sample_channel_client_2 (
									  .tx_clk(tx_clk),
									  .tx_arst(tx_arst),
									  .din_ready(din_ready),
									  .rx_clk(rx_clk),
									  .rx_arst(rx_arst),	    
									  .avl_data_in(avl_data_in),
									  .avl_sop_in(avl_sop_in),
									  .avl_eop_in(avl_eop_in),
									  .avl_data_valid_in(avl_data_valid_in),
									  .avl_empty_in(avl_empty_in),
									  .avl_error_in(avl_error_in),

									  .avl_data_out(avl_data_out),
									  .avl_sop_out(avl_sop_out),
									  .avl_empty_out(avl_empty_out),
									  .avl_eop_out(avl_eop_out),
									  .avl_valid_out(avl_valid_out),
									  .avl_error_out(avl_error_out),
									  .avl_ready_in(avl_ready_in),
	    
									  .tx_counter(tx_counter),
									  .rx_counter(rx_counter)
									  );
	 //pass on all paramters and directly pass through all inputs/outputs
	 defparam sample_channel_client_2.WORDS 	= WORDS;
	 defparam sample_channel_client_2.LOG_WORDS 	= LOG_WORDS;
	 defparam sample_channel_client_2.BUFFER_WORDS 	= BUFFER_WORDS;
	 defparam sample_channel_client_2.TX_STRING 	= TX_STRING;
	 defparam sample_channel_client_2.RX_STRING 	= RX_STRING;	 
      end
      else begin: words_2_by_default
	 //instantiation of the 2 word version of the sample_channel_client
	 //Should only accept parameter values of 2, 4, or 8 for WORDS
	 //Choose 2 word by default  	 
	 alt_ntrlkn_sample_channel_client_2_word sample_channel_client_2 (
									  .tx_clk(tx_clk),
									  .tx_arst(tx_arst),
									  .din_ready(din_ready),
									  .rx_clk(rx_clk),
									  .rx_arst(rx_arst),	    
									  .avl_data_in(avl_data_in),
									  .avl_sop_in(avl_sop_in),
									  .avl_eop_in(avl_eop_in),
									  .avl_data_valid_in(avl_data_valid_in),
									  .avl_empty_in(avl_empty_in),
									  .avl_error_in(avl_error_in),
									  .avl_data_out(avl_data_out),
									  .avl_sop_out(avl_sop_out),
									  .avl_empty_out(avl_empty_out),
									  .avl_eop_out(avl_eop_out),
									  .avl_valid_out(avl_valid_out),
									  .avl_error_out(avl_error_out),
									  .avl_ready_in(avl_ready_in),
									  .tx_counter(tx_counter),
									  .rx_counter(rx_counter)
									  );
	 //pass on all paramters and directly pass through all inputs/outputs
	 defparam sample_channel_client_2.WORDS 	= WORDS;
	 defparam sample_channel_client_2.LOG_WORDS 	= LOG_WORDS;
	 defparam sample_channel_client_2.BUFFER_WORDS 	= BUFFER_WORDS;
	 defparam sample_channel_client_2.TX_STRING 	= TX_STRING;
	 defparam sample_channel_client_2.RX_STRING 	= RX_STRING;	 
      end
      
   endgenerate
   

endmodule
