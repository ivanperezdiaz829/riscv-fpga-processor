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

// baeckler - 09-28-2009

module alt_ntrlkn_sample_channel_client_2_word #(

					  // these are for readability, some edits
					  // required to modify
					  parameter WORDS = 2,
					  parameter LOG_WORDS = 2,
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
   
    input [WORDS*64-1:0] avl_data_in,
    input avl_sop_in,
    input avl_eop_in,
    input avl_data_valid_in,
    input[3:0] avl_empty_in,
    input avl_error_in,
   
    output din_ready,

    output reg [WORDS*64-1:0] avl_data_out,
    output reg avl_sop_out,
    output reg[3:0] avl_empty_out,
    output reg avl_eop_out,
    output reg avl_valid_out,
    output reg avl_error_out,
   
    //input dout_ready,
    input avl_ready_in,
    
    output reg [31:0] tx_counter,
    output reg [31:0] rx_counter
    )
  /* synthesis ALTERA_ATTRIBUTE = "OPTIMIZATION_TECHNIQUE=SPEED" */ ;

   wire dout_ready  = avl_ready_in;
   
   //////////////////////////
  // rebuffer resets
   //////////////////////////

   wire [WORDS*65-1:0] din;
   reg [LOG_WORDS-1:0] num_din_valid;  
   wire [BUFFER_WORDS*64-1:0] packet_buffer;
   wire [BUFFER_WORDS-1:0] packet_toggle;
   
   assign din[63:0] = avl_data_in[63:0];
   assign din[64]  = 1'b0;
   assign din[128:65] = avl_data_in[127:64];
   assign din[129]  = 1'b0;

   always @(avl_empty_in or avl_data_valid_in or avl_eop_in) begin
      if(avl_data_valid_in == 0) begin
	 num_din_valid <= 3'b000;
	 
      end
      else begin
	 if(avl_eop_in === 0) begin
	    //each word must be filled out
	    case(avl_empty_in)
	      0: begin
		 num_din_valid <= 2'b10;
		 
	      end
	      8: begin
		 num_din_valid <= 2'b01;
		 
	      end
	      16: begin
		 num_din_valid <= 2'b00;
		 
	      end
	      default: begin
		 num_din_valid <= 2'b00;
		 
	      end
	      
	    endcase // case (avl_empty_in)
	    
	 end
	 else begin
	    if(avl_empty_in < 8) begin
	       num_din_valid <= 2'b10;
	       
	    end
	    else if(avl_empty_in < 16) begin
	       num_din_valid <= 2'b01;
	       
	    end
	    else begin
	       num_din_valid <= 2'b00;
	    end
	    
	    
	 end
	 
      end
      
   end
   
   
   reg [2:0] rst_sync0 = 0 /* synthesis preserve */
			 /* synthesis ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_false_path -from [get_fanins -async *sample_channel_client*rst_sync0\[*\]] -to [get_keepers *sample_channel_client*rst_sync0\[*\]]\" " */;	
   always @(posedge tx_clk or posedge tx_arst) begin
      if (tx_arst) rst_sync0 <= 0;
      else rst_sync0 <= {rst_sync0[1:0],1'b1};
   end
   wire tx_arst_local = ~rst_sync0[2];

   reg [2:0] rst_sync1 = 0 /* synthesis preserve */
	     /* synthesis ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_false_path -from [get_fanins -async *sample_channel_client*rst_sync1\[*\]] -to [get_keepers *sample_channel_client*rst_sync1\[*\]]\" " */;	
   always @(posedge rx_clk or posedge rx_arst) begin
      if (rx_arst) rst_sync1 <= 0;
      else rst_sync1 <= {rst_sync1[1:0],1'b1};
   end
   wire rx_arst_local = ~rst_sync1[2];

   //////////////////////////
   // transmitter
   //////////////////////////

   reg[LOG_WORDS-1:0] num_dout_valid;
   reg [1:0] tx_state;
   localparam TX_INIT 			 = 2'b00,
     TX_SEND_A 				 = 2'b10,
     TX_SEND_B 				 = 2'b11;

   always @(posedge tx_clk or posedge tx_arst_local) begin
      if (tx_arst_local) begin


      	 tx_counter 			<= {32{1'b0}};
	 avl_data_out 			<= {64{1'b0}};
	 avl_sop_out 			<= 1'b0;
	 avl_empty_out 			<= 4'b0000;
	 avl_error_out 			<= 1'b0;
	 avl_eop_out 			<= 1'b0;
	 avl_valid_out 			<= 1'b0;	 
	 num_dout_valid 		<= {LOG_WORDS{1'b0}};
	 tx_state 			<= TX_INIT;
      end
      else begin
	 if (dout_ready) num_dout_valid <= {LOG_WORDS{1'b0}};
	 
	 case (tx_state) 
	   TX_INIT : begin
	      tx_state <= TX_SEND_A;			
	   end 
	   TX_SEND_A : begin
	      num_dout_valid 				   <= {1'b1,{(LOG_WORDS-1){1'b0}}};
	      avl_data_out 				   <= TX_STRING [BUFFER_WORDS*64-1:WORDS*64];
	      avl_sop_out 				   <= 1'b1;
	      avl_empty_out 				   <= 4'b0000;
	      avl_eop_out 				   <= 1'b0;
	      avl_valid_out 				   <= 1'b1;
	      avl_error_out 				   <= 1'b0;
	      if (dout_ready) tx_state <= TX_SEND_B;
	      
	   end
	   TX_SEND_B : begin
	      num_dout_valid <= {1'b1,{(LOG_WORDS-1){1'b0}}};
	      avl_data_out   <= TX_STRING [WORDS*64-1:0];
	      avl_sop_out    <= 1'b0;
	      avl_eop_out    <= 1'b1;
	      avl_valid_out  <= 1'b1;
	      avl_empty_out  <= 4'b0000;
	      avl_error_out  <= 1'b0;
	      if (dout_ready ) begin
		 tx_state    <= TX_SEND_A; 
		 tx_counter  <= tx_counter + 1'b1;
	      end
	   end
	 endcase
      end
   end

   /////////////////////////////////
   // receiver input regs
   /////////////////////////////////

   assign din_ready 	      = 1'b1;
   reg [WORDS*65-1:0] datwords_r;

   always @(posedge rx_clk or posedge rx_arst_local) begin
      if (rx_arst_local) begin
	 datwords_r <= 0;
      end
      else begin
	 datwords_r <= din;
      end
   end

   //////////////////////////////////////////
   // identify payload and delimiter words
   //////////////////////////////////////////

   // only burst control words have valid channel / SOP info
   // burst control or idle words have valid EOP info, referring to previous data
   reg [WORDS-1:0] rx_eop, valid_eop_info;
   wire [WORDS-1:0] payload_0,packet_delimiter_0;
   reg [WORDS-1:0] payload;
   
   reg [WORDS-1:0] packet_delimiter;
   
   genvar i,j;
   always @(num_din_valid or avl_eop_in) begin
      case(num_din_valid)
	1: begin
	   valid_eop_info[1] <= avl_eop_in;
	   valid_eop_info[0] <= 1'b0;
	   rx_eop[1] 	     <= avl_eop_in;
	   rx_eop[0] 	     <= 1'b0;
	end
	2: begin
	   valid_eop_info[0] <= avl_eop_in;
	   valid_eop_info[1] <= 1'b0;
	   rx_eop[0] 	     <= avl_eop_in;
	   rx_eop[1] 	     <= 1'b0;
	   
	end
	default: begin
	   valid_eop_info[1:0] <= 2'b0;
	   rx_eop[1:0] <= 2'b0;
	   
	end
	
      endcase // case (num_din_valid)
   end // always @ (num_din_valid or avl_eop_in)
   
   generate
      for (i=0; i<WORDS; i=i+1)
	begin : cc

	   assign packet_delimiter_0[i]  = (valid_eop_info[i] & rx_eop[i]);
	   assign payload_0[i] 		 = num_din_valid[1];
	   
	end
   endgenerate

   // break up the data for simulation visibility
   // synthesis translate off
   wire [64:0] datwords_v0, datwords_v1;
   assign {datwords_v0, datwords_v1} = datwords_r;
   // synthesis translate on

   reg [WORDS*65-1:0] datwords_rr;
   reg [WORDS-1:0] payload_rr,packet_delimiter_rr;

   always @(posedge rx_clk or posedge rx_arst_local) begin
      if (rx_arst_local) begin
	 packet_delimiter    <= {WORDS{1'b0}};
	 payload 	     <= {WORDS{1'b0}};
	 
      end	
      else begin
	 packet_delimiter    <= packet_delimiter_0;
	 payload 	     <= payload_0;
	 
      end
   end
   
   always @(posedge rx_clk or posedge rx_arst_local) begin
      if (rx_arst_local) begin
	 payload_rr 	     <= {WORDS{1'b0}};
	 packet_delimiter_rr <= {WORDS{1'b0}};
	 datwords_rr 	     <= 64'b0;
      end	
      else begin
	 payload_rr 	     <= payload;
	 packet_delimiter_rr <= packet_delimiter;	
	 datwords_rr 	     <= datwords_r;
      end
   end

   reg [WORDS-1:0] payload_rrr,payload_adder_rrr,packet_delimiter_rrr;

   always @(posedge rx_clk or posedge rx_arst_local) begin
      if (rx_arst_local) begin
	 payload_rrr <= {WORDS{1'b0}};
	 payload_adder_rrr <= {WORDS{1'b0}};
	 packet_delimiter_rrr <= {WORDS{1'b0}};
      end	
      else begin
	 payload_rrr <= payload_rr;
	 payload_adder_rrr <= payload_rr & ~packet_delimiter_rr;
	 packet_delimiter_rrr <= packet_delimiter_rr;
      end
   end


   //////////////////////////////////////////
   // select buffer slots for RX data 
   //////////////////////////////////////////

   localparam SLOT_BITS = LOG_WORDS + 1;

   wire [(SLOT_BITS-1) * WORDS-1:0] holding_words;
   wire [(SLOT_BITS-1) * WORDS-1:0] next_holding_words;
   wire [SLOT_BITS * WORDS-1:0] send_to;

   generate 
      for (i=0; i<WORDS; i=i+1) 
	begin : st
	   assign send_to [(i+1)*SLOT_BITS-1:i*SLOT_BITS] =
	     payload_rrr[i] ? 
	     {1'b0,holding_words[(i+1)*(SLOT_BITS-1)-1:i*(SLOT_BITS-1)]} :
	     {SLOT_BITS{1'b1}}; // send it nowhere
	   
	   assign next_holding_words [(i+1)*(SLOT_BITS-1)-1:i*(SLOT_BITS-1)] =
									      (packet_delimiter_rrr[i] ? 0 : holding_words[(i+1)*(SLOT_BITS-1)-1:i*(SLOT_BITS-1)]) 
	     + payload_adder_rrr[i];
	end
   endgenerate

   reg [(SLOT_BITS-1)-1:0] holding_reg;
   assign holding_words = 
			  {holding_reg,next_holding_words[(SLOT_BITS-1)*WORDS-1:(SLOT_BITS-1)]};
   
   always @(posedge rx_clk or posedge rx_arst_local) begin
      if (rx_arst_local) holding_reg <= 0;
      else holding_reg <= next_holding_words[(SLOT_BITS-1)-1:0];
   end	

   // register the slot assignments
   reg [SLOT_BITS * WORDS-1:0] send_to_rrr, send_to_rrrr;
   always @(posedge rx_clk or posedge rx_arst_local) begin
      if (rx_arst_local) begin
	 send_to_rrrr <= 0;
      end
      else begin
	 send_to_rrrr <= send_to;		
      end
   end

   // stall the data
   reg [WORDS*65-1:0] datwords_rrr, datwords_rrrr, datwords_r5, datwords_r6;

   always @(posedge rx_clk or posedge rx_arst_local) begin
      if (rx_arst_local) begin
	 datwords_rrr <= 0;
	 datwords_rrrr <= 0;
	 datwords_r5 <= 0;
	 datwords_r6 <= 0;		
      end	
      else begin
	 datwords_rrr <= datwords_rr;
	 datwords_rrrr <= datwords_rrr;
	 datwords_r5 <= datwords_rrrr;
	 datwords_r6 <= datwords_r5;
      end
   end

   //////////////////////////////////////////
   // build a select array
   //////////////////////////////////////////

   wire [BUFFER_WORDS*(LOG_WORDS-1)-1:0] read_from_r6;
   wire [BUFFER_WORDS-1:0] read_fresh_r6;

   generate
      for (i=0; i<BUFFER_WORDS; i=i+1) 
	begin : sl
	   wire [SLOT_BITS-1:0] this_slot = i[SLOT_BITS-1:0];
	   
	   reg [WORDS-1:0] tmp_select;
	   wire fresh = |tmp_select;
	   
	   for (j=0;j<WORDS;j=j+1) 
	     begin : mx
		always @(posedge rx_clk) begin
		   tmp_select[j] <= (send_to_rrrr[(j+1)*SLOT_BITS-1:j*SLOT_BITS] == this_slot);
		end
	     end	
	   
	   /// tick
	   
	   reg [LOG_WORDS-2:0] src_sel;
	   reg src_fresh;
	   
	   always @(posedge rx_clk) begin
	      src_fresh <= fresh;			
	      
	      src_sel[0] <= |(tmp_select & 16'haaaa);

	   end
	   
	   assign read_fresh_r6 [i] = src_fresh;
	   assign read_from_r6 [(i+1)*(LOG_WORDS-1)-1:i*(LOG_WORDS-1)] = src_sel;
	   
	   /// tick
	   
	end
   endgenerate

   //////////////////////////////////////////
   // move RX data into packet buffer 
   //////////////////////////////////////////

   reg [BUFFER_WORDS*64-1:0] packet_buffer_rev;
   wire [BUFFER_WORDS*64-1:0] packet_buffer_w;
   reg [BUFFER_WORDS-1:0] packet_toggle_rev;
   wire [BUFFER_WORDS*64-1:0] exp_fresh_data;

   generate
      for (i=0; i<BUFFER_WORDS; i=i+1) 
	begin : bf

	   wire control_bit;
	   assign exp_fresh_data [(i+1)*64-1:i*64] = {64{read_fresh_r6[i]}};

	   alt_ntrlkn_bus_mux bm (.din(datwords_r6),
		       .sel(read_from_r6[(i+1)*(LOG_WORDS-1)-1:i*(LOG_WORDS-1)]),
		       .dout({control_bit,packet_buffer_w[(i+1)*64-1:i*64]}));
	   defparam bm .DAT_WIDTH = 65;
	   defparam bm .SEL_WIDTH = LOG_WORDS-1;						
	   
	end
   endgenerate

   always @(posedge rx_clk or posedge rx_arst_local) begin
      if (rx_arst_local) begin
	 packet_buffer_rev <= 0;
	 packet_toggle_rev <= 0;
      end
      else begin
	 packet_buffer_rev <= 
			      (exp_fresh_data & packet_buffer_w) |
			      (~exp_fresh_data & packet_buffer_rev);
	 packet_toggle_rev <= packet_toggle_rev ^ read_fresh_r6;
      end
   end

   // reverse buffer words to 1st received on the left (most significant)
   generate
      for (i=0; i<BUFFER_WORDS; i=i+1) 
	begin : rev
	   assign packet_buffer[(i+1)*64-1:i*64] = 
	     packet_buffer_rev[((BUFFER_WORDS-1-i)+1)*64-1:(BUFFER_WORDS-1-i)*64];
	   assign packet_toggle[i] = packet_toggle_rev[BUFFER_WORDS-1-i];
	end
   endgenerate

   //////////////////////////////////////////
   // Compare buffer to the expected RX data
   //////////////////////////////////////////

   wire [BUFFER_WORDS-1:0] word_match_w;
   reg [BUFFER_WORDS-1:0] word_match;

   generate
      for (i=0; i<BUFFER_WORDS; i=i+1) 
	begin : wcmp
	   assign word_match_w[i] = 
	     packet_buffer[(i+1)*64-1:i*64] ==
	     RX_STRING[(i+1)*64-1:i*64];
	end
   endgenerate

   reg [BUFFER_WORDS-1:0] packet_toggle_r;
   always @(posedge rx_clk or posedge rx_arst_local) begin
      if (rx_arst_local) begin
	 word_match <= 0;
	 packet_toggle_r <= 0;
      end
      else begin
	 word_match <= word_match_w;		
	 packet_toggle_r <= packet_toggle;
      end	
   end

   //////////////////////////////////////////
   // Count successful RX packets
   //////////////////////////////////////////
   reg desired_toggle;
   reg [BUFFER_WORDS-1:0] accepted;
   reg rx_packet_accept;

   always @(posedge rx_clk or posedge rx_arst_local) begin
      if (rx_arst_local) begin
	 desired_toggle <= 0;
	 accepted <= 0;		
	 rx_packet_accept <= 1'b0;
	 rx_counter <= 0;
      end
      else begin
	 rx_packet_accept <= 1'b0;
	 if (&accepted) begin
	    rx_packet_accept <= 1'b1;
	    desired_toggle <= ~desired_toggle;
	    accepted <= 0;
	 end
	 else begin
	    accepted <= accepted | 
			(word_match & 
			 ({BUFFER_WORDS{desired_toggle}} ~^ packet_toggle_r));
	 end		 		
	 if (rx_packet_accept) begin
	    rx_counter <= rx_counter + 1'b1;
	 end
      end
   end

endmodule
