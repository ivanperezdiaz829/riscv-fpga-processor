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


// baeckler - 01-31-2010
// buffer inbound SOP/EOP annotated data
// and regroup so that SOP appears in the first word

// dshih may 9, 2011; add arst to DCFIFO

`timescale 1 ps / 1 ps

module alt_ntrlkn_4l_6g_regroup_2 #(
			      parameter WORD_WIDTH = 64,
			      parameter ADDR_WIDTH = 11,
			      parameter NUM_WORDS = 2 // do not override
			      )(	
					input clk, arst,
					input [1:0] din_num_valid,  // 0..2 valid, grouped toward left
					input [NUM_WORDS-1:0] din_sop,		// per input word
					input [4*NUM_WORDS-1:0] din_eopbits, // per input word	
					input [NUM_WORDS*WORD_WIDTH-1:0] din,  
					
   					output reg[NUM_WORDS*WORD_WIDTH-1:0] avl_dout,
					output reg avl_dout_sop,
					output reg avl_dout_eop,
					output reg[3:0]	avl_empty,
					output reg  avl_valid,
					output reg  avl_error,

					output reg overflow	
					);

// NOTE: this is not a rigorous mathematical definition of LOG2(v).
// This function computes the number of bits required to represent "v".
// So log2(256) will be  9 rather than 8 (256 = 9'b1_0000_0000).

function integer log2;
  input integer val;
  begin
	 log2 = 0;
	 while (val > 0) begin
	    val = val >> 1;
		log2 = log2 + 1;
	 end
  end
endfunction

  // synthesis translate off
  genvar j;
    generate
       for (j=0; j<NUM_WORDS*WORD_WIDTH; j=j+1) begin : chk 
	  always @(posedge clk) begin
	     if (din_num_valid != 0 && din[j] === 1'bx) begin
		$display ("Warning : Garbage data entering regrouper at time %d",$time);
						     end
	  end
       end
    endgenerate
   // synthesis translate on

     /////////////////////////////////////////////////
   // write pointer
     /////////////////////////////////////////////////
 
     reg [ADDR_WIDTH-1:0] wraddr;
       always @(posedge clk or posedge arst) begin
	  if (arst) wraddr <= {ADDR_WIDTH{1'b0}};
	    else wraddr <= wraddr + din_num_valid;
	      end

   /////////////////////////////////////////////////
     // figure out SOP addresses
   /////////////////////////////////////////////////

       reg [1:0] sop_ofs, din_num_valid_r;
	 
	 // SOP will occur 1 word after EOP
	 //  check EOP rather than SOP to facilitate flushing
	 always @(posedge clk or posedge arst) begin
	    if (arst) begin
	       sop_ofs <= 2'h0;
						     din_num_valid_r <= 2'h0;
						     end
	    else begin
	       if (din_eopbits[1*4+3] | din_eopbits[1*4+0]) sop_ofs <= 2'd1;
		 else if (din_eopbits[0*4+3] | din_eopbits[0*4+0]) sop_ofs <= 2'd2;
		   else sop_ofs <= 2'd0;
						     din_num_valid_r <= din_num_valid;
						     end
	 end

   /////////////////////////////////////////////////
	 // Use the write info to build max width
   // read schedule
   /////////////////////////////////////////////////

     wire brs_wr_overflow, brs_rd_overflow;
       wire [1:0] rd_num_valid;
	 
	 alt_ntrlkn_4l_6g_buffered_read_scheduler_2 brs 
	   (
	    .clk_wr(clk),
 	    .aclr_wr(arst),
	    .wr_num_valid(din_num_valid_r),    // max of 100..
	    .wr_eop_position(sop_ofs), // 1 for MS word, 2,3... 8.   0 for no EOP
	    .wr_overflow(brs_wr_overflow),
	
	    .clk_mid(clk), // faster if desired, to compact 0's in the read stream
  	    .aclr_mid(arst),
	    .rd_overflow(brs_rd_overflow),
	
	    .clk_rd(clk),
	    .aclr_rd(arst),
        .rd_num_valid(rd_num_valid) // read max of 100.. when possible, hit SOP boundaries
	    );
	     defparam brs .VALID_WIDTH = 2;
   						     
	       /////////////////////////////////////////////////
	     // manage the read address
	       /////////////////////////////////////////////////
	       
	       reg [ADDR_WIDTH-1:0] rdaddr = {ADDR_WIDTH{1'b0}};
		 
		 reg [ADDR_WIDTH-1:0] holding;
		   always @(posedge clk or posedge arst) begin
		      if (arst) holding <= {ADDR_WIDTH{1'b0}};
			else holding <= wraddr - rdaddr;
			  end

   // synthesis translate off
   always @(posedge clk) begin
      if (holding[ADDR_WIDTH-1]) begin
	 $display ("Warning : regroup holding count is impossibly high");
						     end	
   end
   // synthesis translate on
   
   // update the read address
   reg rdena = 1'b0;
     always @(posedge clk or posedge arst) begin
	if (arst) begin		
	   rdaddr <= {ADDR_WIDTH{1'b0}};
						     rdena <= 1'b0;
						     end
	else begin
	   rdena <= |rd_num_valid;
						     rdaddr <= rdaddr + rd_num_valid;
						     end
     end

   /////////////////////////////////////////////////
   // pick out valid reads
   /////////////////////////////////////////////////
   reg [7:0] rdena_delay;
 
     always @(posedge clk or posedge arst) begin
	if (arst) begin		
	   rdena_delay <= 8'h0;		
						     end
	else begin
	   rdena_delay <= {rdena_delay[6:0],rdena};
						     end
     end

   /////////////////////////////////////////////////
   // word addressable storage
   /////////////////////////////////////////////////
   localparam EXT_WORD_WIDTH = WORD_WIDTH + 4 + 1;
     wire [EXT_WORD_WIDTH * NUM_WORDS-1:0] ext_din, ext_dout;
       wire [EXT_WORD_WIDTH * NUM_WORDS*2-1:0] ext_din_double; // For use with alt_ntrlkn_4l_6g_wide_word_ram_4
   wire [EXT_WORD_WIDTH * NUM_WORDS*2-1:0] ext_dout_double; // For use with alt_ntrlkn_4l_6g_wide_word_ram_4
   
   // embed SOP/EOP in data words
   genvar i;
	  generate
	     for (i=0; i<NUM_WORDS; i=i+1) begin : pack_din
		assign ext_din[(i+1)*EXT_WORD_WIDTH-1:i*EXT_WORD_WIDTH] =
	  {din_sop[i],	
	   din_eopbits[(i+1)*4-1:i*4],	
	   din[(i+1)*WORD_WIDTH-1:i*WORD_WIDTH]};
	  end	
	  endgenerate

   // Using the alt_ntrlkn_4l_6g_wide_word_ram_4 block here...
   assign ext_din_double = {ext_din,{(EXT_WORD_WIDTH*NUM_WORDS){1'b0}}};
	  assign ext_dout = ext_dout_double[EXT_WORD_WIDTH*NUM_WORDS*2-1:EXT_WORD_WIDTH*NUM_WORDS]; 
	  alt_ntrlkn_4l_6g_wide_word_ram_4 mem 
	  (
	   .clk(clk),
	   .arst(arst),
	   .din(ext_din_double),
	   .wr_addr(wraddr),		// addressing is in words
	   .we(1'b1),
	   .dout(ext_dout_double),
	   .rd_addr(rdaddr)
	   );
	  defparam mem .WORD_WIDTH = EXT_WORD_WIDTH;
	  defparam mem .NUM_WORDS = 4;  // barrel shifter mod required to override
   defparam mem .ADDR_WIDTH = ADDR_WIDTH;
 
     // separate SOP/EOP from readback data words
     wire [NUM_WORDS-1:0] rd_sop;	
       wire [NUM_WORDS-1:0] rd_eopbits3,rd_eopbits2,rd_eopbits1,rd_eopbits0;
	 wire [NUM_WORDS*WORD_WIDTH-1:0] rd_dout;
	   generate
	      for (i=0; i<NUM_WORDS; i=i+1) begin : unpack
		 assign {rd_sop[i],
			 rd_eopbits3[i],
			 rd_eopbits2[i],
			 rd_eopbits1[i],
			 rd_eopbits0[i],
			 rd_dout[(i+1)*WORD_WIDTH-1:i*WORD_WIDTH]} =
			      ext_dout[(i+1)*EXT_WORD_WIDTH-1:i*EXT_WORD_WIDTH];
			      end	
	   endgenerate

   always @(posedge clk or posedge arst) begin
      if (arst) begin		
         avl_dout_sop 	 <= 1'b0;	
	 avl_dout 	 <= {NUM_WORDS*WORD_WIDTH{1'b0}};
	 avl_dout_eop 	 <= 1'b0;
	 avl_error 	 <= 1'b0;
	 avl_empty 	 <= 4'd0;
	 avl_valid 	 <= 1'b0;
      end
      else begin
	 avl_dout_sop 	 <= rd_sop[NUM_WORDS-1];	
	 avl_dout 	 <= rd_dout;

	 if (rdena_delay[4]) begin
	    if (rd_eopbits3[1] | rd_eopbits0[1]) begin
	       //1 word valid
	       avl_valid <= 1'b1;
	       
	       
	       case({rd_eopbits3[1],rd_eopbits2[1],rd_eopbits1[1],rd_eopbits0[1]})
		 4'b0000: begin
		    avl_dout_eop <= 1'b0;
		    avl_error 	 <= 1'b0;
		    avl_empty 	 <= 4'd8;    
		 end
		 
		 4'b0001: begin
		    avl_error <= 1'b1;
		    avl_empty <= 4'd0;
		    avl_dout_eop   <= 1'b1;	    
		 end
		 4'b1000: begin
		    avl_error 	 <= 1'b0;
		    avl_empty 	 <= 4'd8;
		    avl_dout_eop <= 1'b1;    
		 end
		 4'b1001: begin
		    avl_error 	 <= 1'b0;
		    avl_empty 	 <= 4'd15;
		    avl_dout_eop <= 1'b1;
		 end
		 4'b1010: begin
		    avl_error <= 1'b0;
		    avl_empty <= 4'd14;
		    avl_dout_eop   <= 1'b1;		
		 end
		 4'b1011: begin
		    avl_error <= 1'b0;
		    avl_empty <= 4'd13;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1100: begin
		    avl_error <= 1'b0;
		    avl_empty <= 4'd12;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1101: begin
		    avl_error <= 1'b0;
		    avl_empty <= 4'd11;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1110: begin
		    avl_error <= 1'b0;
		    avl_empty <= 4'd10;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1111: begin
		    avl_error <= 1'b0;
		    avl_empty <= 4'd9;
		    avl_dout_eop   <= 1'b1;
		 end
		 default: begin
		    avl_error 	 <= 1'b1;
		    avl_empty 	 <= 4'd0;
		    avl_dout_eop <= 1'b1;
		 end
	       endcase // case ({rd_eopbits3[1],rd_eopbits2[1],rd_eopbits1[1],rd_eopbits0[1]})
	       
	    end // if (rd_eopbits3[1] | rd_eopbits0[1])
	    
	    else begin
	       //2 words valid
	       avl_valid 	 <= 1'b1;
	       
	       case({rd_eopbits3[0],rd_eopbits2[0],rd_eopbits1[0],rd_eopbits0[0]})
		 4'b0000: begin
		    avl_dout_eop <= 1'b0;
		    avl_error 	 <= 1'b0;
		    avl_empty 	 <= 4'd0;    
		 end
		 
		 4'b0001: begin
		    avl_error <= 1'b1;
		    avl_empty <= 4'd0;
		    avl_dout_eop   <= 1'b1;	    
		 end
		 4'b1000: begin
		    avl_error 	 <= 1'b0;
		    avl_empty 	 <= 4'd0;
		    avl_dout_eop <= 1'b1;    
		 end
		 4'b1001: begin
		    avl_error 	 <= 1'b0;
		    avl_empty 	 <= 4'd7;
		    avl_dout_eop <= 1'b1;
		 end
		 4'b1010: begin
		    avl_error <= 1'b0;
		    avl_empty <= 4'd6;
		    avl_dout_eop   <= 1'b1;		
		 end
		 4'b1011: begin
		    avl_error <= 1'b0;
		    avl_empty <= 4'd5;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1100: begin
		    avl_error <= 1'b0;
		    avl_empty <= 4'd4;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1101: begin
		    avl_error <= 1'b0;
		    avl_empty <= 4'd3;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1110: begin
		    avl_error <= 1'b0;
		    avl_empty <= 4'd2;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1111: begin
		    avl_error <= 1'b0;
		    avl_empty <= 4'd1;
		    avl_dout_eop   <= 1'b1;
		 end
		 default: begin
		    avl_error      <= 1'b1;
		    avl_empty      <= 4'd0;
		    avl_dout_eop   <= 1'b1;
		 end
	       endcase // case ({rd_eopbits3[0],rd_eopbits2[0],rd_eopbits1[0],rd_eopbits0[0]})
	       
	    end // else: !if(rd_eopbits3[1] | rd_eopbits0[1])
	    
	 end // if (rdena_delay[4])
	 
	 else begin
	    avl_dout 	 <= {NUM_WORDS*WORD_WIDTH{1'b0}};
	    avl_dout_sop <= 1'b0;
	    avl_empty 	 <= 4'd0;
	    avl_error 	 <= 1'b0;
	    avl_valid 	 <= 1'b0;
	    avl_dout_eop <= 1'b0;
	    
	 end // else: !if(rdena_delay[4])
	 
      end
   end

   initial overflow 				= 1'b0;
     always @(posedge clk) begin
	overflow <= brs_wr_overflow | brs_rd_overflow | (holding[ADDR_WIDTH-1]);
						  end

endmodule
