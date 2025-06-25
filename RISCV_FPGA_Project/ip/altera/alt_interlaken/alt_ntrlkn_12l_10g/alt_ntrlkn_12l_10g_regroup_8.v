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

module alt_ntrlkn_12l_10g_regroup_8 #(
			      parameter WORD_WIDTH = 64,
			      parameter ADDR_WIDTH = 11,
			      parameter NUM_WORDS = 8 // do not override
			      )(
				input clk, arst,
				input [3:0] din_num_valid,  // 0..8 valid, grouped toward left
				input [NUM_WORDS-1:0] din_sop,		// per input word
				input [4*NUM_WORDS-1:0] din_eopbits, // per input word
				input [NUM_WORDS*WORD_WIDTH-1:0] din,
				output reg[NUM_WORDS*WORD_WIDTH-1:0] avl_dout,
				output reg avl_dout_sop,
				output reg avl_dout_eop,
				output reg[5:0]	avl_empty,
				output reg  avl_valid,
				output reg  avl_error,
				output reg overflow = 1'b0
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

   reg [3:0] sop_ofs, din_num_valid_r;

   // SOP will occur 1 word after EOP
   //  check EOP rather than SOP to facilitate flushing
   always @(posedge clk or posedge arst) begin
      if (arst) begin
	 sop_ofs <= 4'h0;
	 din_num_valid_r <= 4'h0;
      end
      else begin
	 if (din_eopbits[7*4+3] | din_eopbits[7*4+0]) sop_ofs <= 4'd1;
	 else if (din_eopbits[6*4+3] | din_eopbits[6*4+0]) sop_ofs <= 4'd2;
	 else if (din_eopbits[5*4+3] | din_eopbits[5*4+0]) sop_ofs <= 4'd3;
	 else if (din_eopbits[4*4+3] | din_eopbits[4*4+0]) sop_ofs <= 4'd4;
	 else if (din_eopbits[3*4+3] | din_eopbits[3*4+0]) sop_ofs <= 4'd5;
	 else if (din_eopbits[2*4+3] | din_eopbits[2*4+0]) sop_ofs <= 4'd6;
	 else if (din_eopbits[1*4+3] | din_eopbits[1*4+0]) sop_ofs <= 4'd7;
	 else if (din_eopbits[0*4+3] | din_eopbits[0*4+0]) sop_ofs <= 4'd8;
	 else sop_ofs <= 3'd0;

	 din_num_valid_r <= din_num_valid;
      end
   end

   /////////////////////////////////////////////////
   // Use the write info to build max width
   // read schedule
   /////////////////////////////////////////////////

   wire brs_wr_overflow, brs_rd_overflow;
   wire [3:0] rd_num_valid;

   alt_ntrlkn_12l_10g_buffered_read_scheduler_8 brs
     (
      .clk_wr(clk),
 	  .aclr_wr(arst),
      .wr_num_valid(din_num_valid_r),    // max of 100..
      .wr_eop_position(sop_ofs), // 1 for MS word, 2,3... 8.   0 for no EOP
      .wr_overflow(brs_wr_overflow),

      .clk_mid(clk), // faster if desired, to compact any 0's in the read stream
	  .aclr_mid(arst),
      .rd_overflow(brs_rd_overflow),

      .clk_rd(clk),
	  .aclr_rd(arst),
      .rd_num_valid(rd_num_valid) // read max of 100.. when possible, hit SOP boundaries
      );
   defparam brs .VALID_WIDTH = 4;

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

   alt_ntrlkn_12l_10g_wide_word_ram_8 mem
     (
      .clk(clk),
      .arst(arst),
      .din(ext_din),
      .wr_addr(wraddr),		// addressing is in words
      .we(1'b1),
      .dout(ext_dout),
      .rd_addr(rdaddr)
      );
   defparam mem .WORD_WIDTH = EXT_WORD_WIDTH;
   defparam mem .NUM_WORDS = 8;  // barrel shifter mod required to override
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
	 avl_dout 		 <= {NUM_WORDS*WORD_WIDTH{1'b0}};
	 avl_dout_eop 	 <= 1'b0;
	 avl_error 	 <= 1'b0;
	 avl_empty 	 <= 6'd0;
	 avl_valid 	 <= 1'b0;
      end
      else begin
	 avl_dout_sop 	 <= rd_sop[NUM_WORDS-1];	
	 avl_dout 		 <= rd_dout;

	 if (rdena_delay[5]) begin
            if (rd_eopbits3[7] | rd_eopbits0[7]) begin
	       //1 word valid
 	       avl_valid <= 1;
	       
	       case({rd_eopbits3[7],rd_eopbits2[7],rd_eopbits1[7],rd_eopbits0[7]})
		 4'b0000: begin
		    avl_dout_eop <= 1'b0;
		    avl_error 	 <= 1'b0;
		    avl_empty 	 <= 6'd56;    
		 end
		 
		 4'b0001: begin
		    avl_error <= 1'b1;
		    avl_empty <= 6'd0;
		    avl_dout_eop   <= 1'b1;	    
		 end
		 4'b1000: begin
		    avl_error 	 <= 1'b0;
		    avl_empty 	 <= 6'd56;
		    avl_dout_eop <= 1'b1;    
		 end
		 4'b1001: begin
		    avl_error 	 <= 1'b0;
		    avl_empty 	 <= 6'd63;
		    avl_dout_eop <= 1'b1;
		 end
		 4'b1010: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd62;
		    avl_dout_eop   <= 1'b1;		
		 end
		 4'b1011: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd61;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1100: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd60;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1101: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd59;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1110: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd58;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1111: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd57;
		    avl_dout_eop   <= 1'b1;
		 end
		 default: begin
		    avl_error 	 <= 1'b1;
		    avl_empty 	 <= 6'd0;
		    avl_dout_eop <= 1'b1;
		 end
	       endcase // case ({rd_eopbits3[7],rd_eopbits2[7],rd_eopbits1[7],rd_eopbits0[7]})
            end // if (rd_eopbits3[7] | rd_eopbits0[7])
            else if (rd_eopbits3[6] | rd_eopbits0[6]) begin
	       //2 words valid
	       avl_valid <= 1;
	       
	       case( {rd_eopbits3[6],rd_eopbits2[6],rd_eopbits1[6],rd_eopbits0[6]})
		 4'b0000: begin
		    avl_dout_eop   <= 1'b0;
		    avl_error <= 1'b0;
		    avl_empty <= 6'd48;
		    
		 end
		 
		 4'b0001: begin
		    avl_error <= 1'b1;
		    avl_empty <= 6'd0;
		    avl_dout_eop   <= 1'b1;
		    
		 end
		 4'b1000: begin
		    avl_error 	 <= 1'b0;
		    avl_empty 	 <= 6'd48;
		    avl_dout_eop <= 1'b1;
		    
		 end
		 4'b1001: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd55;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1010: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd54;
		    avl_dout_eop   <= 1'b1;		
		 end
		 4'b1011: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd53;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1100: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd52;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1101: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd51;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1110: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd50;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1111: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd49;
		    avl_dout_eop   <= 1'b1;
		 end
		 default: begin
		    avl_error <= 1'b1;
		    avl_empty <= 6'd0;
		    avl_dout_eop   <= 1'b1;
		 end
		 
	       endcase // case ( {rd_eopbits3[6],rd_eopbits2[6],rd_eopbits1[6],rd_eopbits0[6]})
            end // if (rd_eopbits3[6] | rd_eopbits0[6])
            else if (rd_eopbits3[5] | rd_eopbits0[5]) begin
	       //3 words valid
	       avl_valid <= 1;
	       
	       case({rd_eopbits3[5],rd_eopbits2[5],rd_eopbits1[5],rd_eopbits0[5]})
		 4'b0000: begin
		    avl_dout_eop <= 1'b0;
		    avl_error <= 1'b0;
		    avl_empty <= 6'd40;
		    
		 end
		 
		 4'b0001: begin
		    avl_error <= 1'b1;
		    avl_empty <= 6'd0;
		    avl_dout_eop   <= 1'b1;
		    
		 end
		 4'b1000: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd40;
		    avl_dout_eop   <= 1'b1;
		    
		 end
		 4'b1001: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd47;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1010: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd46;
		    avl_dout_eop   <= 1'b1;		
		 end
		 4'b1011: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd45;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1100: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd44;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1101: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd43;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1110: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd42;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1111: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd41;
		    avl_dout_eop   <= 1'b1;
		 end
		 default: begin
		    avl_error <= 1'b1;
		    avl_empty <= 6'd0;
		    avl_dout_eop   <= 1'b1;
		 end
		 
	       endcase // case ({rd_eopbits3[5],rd_eopbits2[5],rd_eopbits1[5],rd_eopbits0[5]})
            end // if (rd_eopbits3[5] | rd_eopbits0[5])
            else if (rd_eopbits3[4] | rd_eopbits0[4]) begin
	       //4 words valid
	       avl_valid <= 1;
	       
	       case( {rd_eopbits3[4],rd_eopbits2[4],rd_eopbits1[4],rd_eopbits0[4]})
		 4'b0000: begin
		    avl_dout_eop   <= 1'b0;
		    avl_error <= 1'b0;
		    avl_empty <= 6'd32;
		    
		 end
		 
		 4'b0001: begin
		    avl_error <= 1'b1;
		    avl_empty <= 6'd0;
		    avl_dout_eop   <= 1'b1;
		    
		 end
		 4'b1000: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd32;
		    avl_dout_eop   <= 1'b1;
		    
		 end
		 4'b1001: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd39;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1010: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd38;
		    avl_dout_eop   <= 1'b1;		
		 end
		 4'b1011: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd37;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1100: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd36;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1101: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd35;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1110: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd34;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1111: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd33;
		    avl_dout_eop   <= 1'b1;
		 end
		 default: begin
		    avl_error <= 1'b1;
		    avl_empty <= 6'd0;
		    avl_dout_eop   <= 1'b1;
		 end
		 
	       endcase // case ( {rd_eopbits3[4],rd_eopbits2[4],rd_eopbits1[4],rd_eopbits0[4]})
            end // if (rd_eopbits3[4] | rd_eopbits0[4])
            else if (rd_eopbits3[3] | rd_eopbits0[3]) begin
	       //5 words valid
	       avl_valid <= 1'b1;
	       
	       case( {rd_eopbits3[3],rd_eopbits2[3],rd_eopbits1[3],rd_eopbits0[3]})
		 4'b0000: begin
		    avl_dout_eop   <= 1'b0;
		    avl_error <= 1'b0;
		    avl_empty <= 6'd24;
		    
		 end
		 
		 4'b0001: begin
		    avl_error <= 1'b1;
		    avl_empty <= 6'd0;
		    avl_dout_eop   <= 1'b1;
		    
		 end
		 4'b1000: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd24;
		    avl_dout_eop   <= 1'b1;
		    
		 end
		 4'b1001: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd31;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1010: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd30;
		    avl_dout_eop   <= 1'b1;		
		 end
		 4'b1011: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd29;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1100: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd28;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1101: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd27;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1110: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd26;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1111: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd25;
		    avl_dout_eop   <= 1'b1;
		 end
		 default: begin
		    avl_error <= 1'b1;
		    avl_empty <= 6'd0;
		    avl_dout_eop   <= 1'b1;
		 end
		 
	       endcase // case ( {rd_eopbits3[3],rd_eopbits2[3],rd_eopbits1[3],rd_eopbits0[3]})
            end // if (rd_eopbits3[3] | rd_eopbits0[3])
            else if (rd_eopbits3[2] | rd_eopbits0[2]) begin
	       //6 words valid
	       avl_valid <= 1'b1;
	       
	       case( {rd_eopbits3[2],rd_eopbits2[2],rd_eopbits1[2],rd_eopbits0[2]})
		 4'b0000: begin
		    avl_dout_eop   <= 1'b0;
		    avl_error <= 1'b0;
		    avl_empty <= 6'd16;
		    
		 end
		 
		 4'b0001: begin
		    avl_error <= 1'b1;
		    avl_empty <= 6'd0;
		    avl_dout_eop   <= 1'b1;
		    
		 end
		 4'b1000: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd16;
		    avl_dout_eop   <= 1'b1;
		    
		 end
		 4'b1001: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd23;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1010: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd22;
		    avl_dout_eop   <= 1'b1;		
		 end
		 4'b1011: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd21;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1100: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd20;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1101: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd19;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1110: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd18;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1111: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd17;
		    avl_dout_eop   <= 1'b1;
		 end
		 default: begin
		    avl_error 	 <= 1'b1;
		    avl_empty 	 <= 6'd0;
		    avl_dout_eop <= 1'b1;
		 end
		 
	       endcase // case ( {rd_eopbits3[2],rd_eopbits2[2],rd_eopbits1[2],rd_eopbits0[2]})
            end // if (rd_eopbits3[2] | rd_eopbits0[2])
            else if (rd_eopbits3[1] | rd_eopbits0[1]) begin
	       //7 words valid
	       avl_valid <= 1'b1;
	       
	       case({rd_eopbits3[1],rd_eopbits2[1],rd_eopbits1[1],rd_eopbits0[1]})
		 4'b0000: begin
		    avl_dout_eop   <= 1'b0;
		    avl_error <= 1'b0;
		    avl_empty <= 6'd8;
		    
		 end
		 
		 4'b0001: begin
		    avl_error <= 1'b1;
		    avl_empty <= 6'd0;
		    avl_dout_eop   <= 1'b1;
		    
		 end
		 4'b1000: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd8;
		    avl_dout_eop   <= 1'b1;
		    
		 end
		 4'b1001: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd15;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1010: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd14;
		    avl_dout_eop   <= 1'b1;		
		 end
		 4'b1011: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd13;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1100: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd12;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1101: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd11;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1110: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd10;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1111: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd9;
		    avl_dout_eop   <= 1'b1;
		 end
		 default: begin
		    avl_error 	 <= 1'b1;
		    avl_empty 	 <= 6'd0;
		    avl_dout_eop <= 1'b1;
		 end
		 
	       endcase // case ({rd_eopbits3[1],rd_eopbits2[1],rd_eopbits1[1],rd_eopbits0[1]})
            end // if (rd_eopbits3[1] | rd_eopbits0[1])
            else begin
	       //8 words valid
	       avl_valid <= 1'b1;
	       
	       case({rd_eopbits3[0],rd_eopbits2[0],rd_eopbits1[0],rd_eopbits0[0]})
		 4'b0000: begin
		    avl_dout_eop   <= 1'b0;
		    avl_error <= 1'b0;
		    avl_empty <= 6'd0;
		    
		 end
		 
		 4'b0001: begin
		    avl_error <= 1'b1;
		    avl_empty <= 6'd0;
		    avl_dout_eop   <= 1'b1;
		    
		 end
		 4'b1000: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd0;
		    avl_dout_eop   <= 1'b1;
		    
		 end
		 4'b1001: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd7;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1010: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd6;
		    avl_dout_eop   <= 1'b1;		
		 end
		 4'b1011: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd5;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1100: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd4;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1101: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd3;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1110: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd2;
		    avl_dout_eop   <= 1'b1;
		 end
		 4'b1111: begin
		    avl_error <= 1'b0;
		    avl_empty <= 6'd1;
		    avl_dout_eop   <= 1'b1;
		 end
		 default: begin
		    avl_error <= 1'b1;
		    avl_empty <= 6'd0;
		    avl_dout_eop   <= 1'b1;
		 end
		 
	       endcase // case ({rd_eopbits3[0],rd_eopbits2[0],rd_eopbits1[0],rd_eopbits0[0]})
            end 
	 end // if (rdena_delay[5])
	 
	 else begin
 	    avl_dout 		 <= {NUM_WORDS*WORD_WIDTH{1'b0}};
	    avl_dout_sop 	         <= 1'b0;
	    avl_empty 		 <= 6'd0;
	    avl_error 		 <= 1'b0;
	    avl_valid 		 <= 1'b0;
	    avl_dout_eop 	         <= 1'b0;
	 end
      end
   end

   always @(posedge clk) begin
      overflow <= brs_wr_overflow |
                  brs_rd_overflow |
                  (holding[ADDR_WIDTH-1]);
   end

endmodule
