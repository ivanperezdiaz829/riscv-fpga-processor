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


   /////////////////////////////////////////////////
   // TX aligner
   /////////////////////////////////////////////////
   //Added extra pipe tx_empty_r, tx_empty_rr so that pcs domain will not be
   //Bottle neck. JZ 5-23-12
   
module ilk_tx_aligner #(
        parameter       NUM_LANES = 8
    ) (

        output reg [2:0]                txa_sm,
        output reg                      tx_from_fifo,
        output reg                      tx_lanes_aligned,
        output reg                      tx_force_fill,
        output reg                      tx_cadence,
        output reg                      all_tx_full,
        output reg                      any_tx_empty,
        output reg                      any_tx_frame,
        output reg                      any_tx_full,

        input wire [NUM_LANES-1:0]      tx_frame,
        input wire [NUM_LANES-1:0]      tx_empty,
        input wire [NUM_LANES-1:0]      tx_full,
        input wire [NUM_LANES-1:0]      tx_pfull,
        input wire [NUM_LANES-1:0]      tx_pempty,

        input wire                      clk_tx_common,
        input wire                      srst_tx_common
   );
  

   wire [NUM_LANES-1:0] tx_frame_s;
   ilk_status_sync #( .WIDTH( NUM_LANES ) ) tx_frame_sync (.clk(clk_tx_common),.din(tx_frame),.dout(tx_frame_s));

   wire [NUM_LANES-1:0] tx_empty_rr;
   ilk_status_sync #( .WIDTH( NUM_LANES ) ) tx_empty_sync (.clk(clk_tx_common),.din(tx_empty),.dout(tx_empty_rr));

   wire [NUM_LANES-1:0] tx_pempty_s;
   ilk_status_sync #( .WIDTH( NUM_LANES ) ) tx_pempty_sync (.clk(clk_tx_common),.din(tx_pempty),.dout(tx_pempty_s));

   reg                 [NUM_LANES-1:0] tx_full_r;
   reg                 [NUM_LANES-1:0] tx_pfull_r;

   always @(posedge clk_tx_common) begin
      if (srst_tx_common) begin
         all_tx_full  <= 1'b0;
         any_tx_full  <= 1'b0;
         any_tx_empty <= 1'b1;
         any_tx_frame <= 1'b0;
         tx_full_r    <= { NUM_LANES{ 1'b0 }};
         tx_pfull_r   <= { NUM_LANES{ 1'b0 }};
      end
      else begin
      all_tx_full  <= &tx_full_r;
      any_tx_full  <= |tx_full_r;
      any_tx_empty <= |tx_empty_rr;
      any_tx_frame <= |tx_frame_s;
      tx_full_r    <= tx_full;
      tx_pfull_r   <= tx_pfull; 
      end
   end

   localparam TXA_INIT           = 3'h0;
   localparam TXA_FILL           = 3'h1;
   localparam TXA_PREFRAME_WAIT  = 3'h2;
   localparam TXA_POSTFRAME_WAIT = 3'h3;
   localparam TXA_ENABLE         = 3'h4;
   localparam TXA_ALIGNED        = 3'h5;
   localparam TXA_ERROR0         = 3'h6;
   localparam TXA_ERROR1         = 3'h7;


   reg       tx_aligned;
   reg [3:0] tx_frame_countdown;

   assign tx_lanes_aligned = tx_aligned;
   assign tx_pcsfifo_pfull = |tx_pfull_r;

always @(posedge clk_tx_common) begin
	if (srst_tx_common) begin
		txa_sm <= TXA_INIT;
		tx_from_fifo <= 1'b1;
		tx_aligned <= 1'b0;
		tx_force_fill <= 1'b0;
		tx_frame_countdown <= 4'hf;
	end
	else begin
		
		// defaults
		tx_aligned <= 1'b0;
		tx_force_fill <= 1'b0;
		
		case (txa_sm) 
			TXA_INIT : begin
				txa_sm <= TXA_FILL;
				tx_from_fifo <= 1'b1;
			end
			TXA_FILL :	begin
				tx_from_fifo <= 1'b0;
				tx_force_fill <= 1'b1;
				if (all_tx_full) txa_sm <= TXA_PREFRAME_WAIT;
			end
			TXA_PREFRAME_WAIT : begin
                                // wait until you see a frame being transmitted
				tx_frame_countdown <= 4'hf;
				if (any_tx_frame) txa_sm <= TXA_POSTFRAME_WAIT;				
			end
			TXA_POSTFRAME_WAIT : begin
                                // wait for ~16 ticks after any TX framing activity
				if (any_tx_frame)  tx_frame_countdown <= 4'hf;
				else tx_frame_countdown <= tx_frame_countdown - 1'b1;
				if (~|tx_frame_countdown) txa_sm <= TXA_ENABLE;
				if (!all_tx_full) txa_sm <= TXA_ERROR0; // this would be an error - start over
			end
			TXA_ENABLE :  begin
				tx_from_fifo <= 1'b1;
//			        if (!all_tx_full) txa_sm <= TXA_ALIGNED;
  			        if (!any_tx_full) txa_sm <= TXA_ALIGNED;  //This will make sure no one is full
								   //and wait longer to be more robust. 3-22-12
			end
			TXA_ALIGNED : begin
				tx_aligned <= 1'b1;
				if (any_tx_empty || any_tx_full) txa_sm <= TXA_ERROR0; // this would be an error - start over 
			end		
			TXA_ERROR0 : txa_sm <= TXA_ERROR1;
			TXA_ERROR1 : txa_sm <= TXA_INIT;
			
			default : txa_sm <= TXA_ERROR0;
		endcase		
	end
end

   /////////////////////////////////////////////////
   // cadence
   /////////////////////////////////////////////////
   // used a smoothed version of the TX fifo to accept new data
   reg last_tx_cadence;

   always @(posedge clk_tx_common) begin
      if (srst_tx_common) begin
         tx_cadence      <= 1'b0;
         last_tx_cadence <= 1'b0;
      end
      else begin
         last_tx_cadence <= tx_cadence;
         tx_cadence      <= (|tx_pempty_s) && (!last_tx_cadence || !tx_cadence);
         //tx_cadence      <= (|tx_pempty) && (!last_tx_cadence || !tx_cadence);
      end
   end

endmodule //ilk_tx_aligner
