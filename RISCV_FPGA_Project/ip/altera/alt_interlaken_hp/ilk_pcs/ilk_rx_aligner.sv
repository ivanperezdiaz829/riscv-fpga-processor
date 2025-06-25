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
   // RX aligner
   /////////////////////////////////////////////////

module ilk_rx_aligner #(
        parameter       NUM_LANES     = 8,
        parameter       BITS_PER_LANE = 64
    ) (
        output reg                                rx_lanes_aligned, 
        output reg [1:0]                          rxa_sm, 
        output reg                                rx_cadence, 
        output reg [NUM_LANES-1:0]                rx_valid, 
        output reg [NUM_LANES-1:0]                rx_control, 
        output reg [NUM_LANES*BITS_PER_LANE-1:0]  rx_dout,
        output reg                                rx_fifo_clr,
        output reg                                any_loss_of_meta,
        output reg                                any_control,
        output reg                                all_control,
        output reg [4:0]                          rxa_timer,

        input wire [NUM_LANES-1:0]                rx_pempty,
        input wire [NUM_LANES-1:0]                rx_pfull,
        input wire [NUM_LANES-1:0]                rx_metalock,
        input wire [NUM_LANES-1:0]                rx_valid_np,     //from Native PHY
        input wire [NUM_LANES*BITS_PER_LANE-1:0]  rx_dout_np,      //from Native PHY
        input wire [NUM_LANES*10-1:0]             rx_control_np,   //from Native PHY

        input wire                                clk_rx_common,
        input wire                                srst_rx_common
    );

   wire [NUM_LANES-1:0] rx_control_early;

   genvar k;
   generate 
     for (k=0;k<NUM_LANES;k=k+1) begin : rx_control_early_gen
        assign rx_control_early[k] = rx_control_np [10*k+1];
     end
   endgenerate

   wire [NUM_LANES-1:0] rx_metalock_s;
   ilk_status_sync #( .WIDTH( NUM_LANES ) ) rx_metalock_sync (
       .clk(clk_rx_common),.din(rx_metalock),.dout(rx_metalock_s)
   );

   reg   [NUM_LANES*BITS_PER_LANE-1:0] rx_dout_i;
   reg                 [NUM_LANES-1:0] rx_valid_i, rx_control_i;
   reg                                 rx_purge;
   always @(posedge clk_rx_common) begin
      any_loss_of_meta <= (~&rx_metalock_s);
      rx_dout_i        <= rx_dout_np;
      rx_valid_i       <= rx_valid_np;
      rx_control_i     <= rx_control_early;
      rx_fifo_clr      <= rx_purge;
   end


   // framing control words (as opposed to burst ctrl or idle) have bit 63 = 0
   wire [NUM_LANES-1:0] rx_bit63;
   genvar i;
   generate
      for (i=0; i<NUM_LANES; i=i+1) begin : b63
         assign rx_bit63[i] = rx_dout_i[(i*64)+63];
      end
   endgenerate

   reg  [NUM_LANES-1:0] rx_control_r;
   wire [NUM_LANES-1:0] rx_framing_i = rx_control_i & ~rx_bit63;
   reg                  rx_any_pfull;
   reg                  rx_none_pempty;

   wire [NUM_LANES-1:0] rx_pfull_s;
   ilk_status_sync #( 
        .WIDTH( NUM_LANES ) 
   ) rx_pfull_sync (
        .clk(clk_rx_common),
        .din(rx_pfull),
        .dout(rx_pfull_s)
   );

   always @(posedge clk_rx_common) begin
      if (srst_rx_common) begin
         any_control    <= 1'b0;
         all_control    <= 1'b0;
         rx_control_r   <= {NUM_LANES{1'b0}};
         rx_any_pfull   <= 1'b0;
         rx_none_pempty <= 1'b0;
      end
      else begin
         any_control    <= |(rx_valid_i & rx_framing_i);
         all_control    <= &(rx_valid_i & rx_framing_i);
         rx_control_r   <= rx_control_i;
         rx_any_pfull   <= |rx_pfull_s;
         rx_none_pempty <= ~|rx_pempty;
      end
   end
   assign rx_control = rx_control_r;

   localparam RXA_INIT          = 2'h0;
   localparam RXA_TRIAL_RELEASE = 2'h1;
   localparam RXA_TRIAL_ENGAGE  = 2'h2;
   localparam RXA_MONITOR_LOCK  = 2'h3;

   reg [2:0] bad_align_cntr;
   reg       rx_align_locked;

   assign rx_backup = {NUM_LANES{1'b0}};

   always @(posedge clk_rx_common) begin

      if (srst_rx_common) begin
         rxa_sm          <= 2'b0;
         rx_align_locked <= 1'b0;
         rx_purge        <= 1'b0;
         bad_align_cntr  <= 3'b0;
         rxa_timer       <= 5'h0;
      end
      else begin

         if (!rxa_timer[4]) begin
            rxa_timer <= rxa_timer + 1'b1;
         end

         if (any_loss_of_meta) begin
            rxa_sm          <= RXA_INIT;
            rx_purge        <= 1'b1;
            rx_align_locked <= 1'b0;
         end
         else begin
            case (rxa_sm)
               RXA_INIT          : begin
                                      rx_purge        <= 1'b1;
                                      rxa_timer       <= 5'h0;
                                      rx_align_locked <= 1'b0;
                                      rxa_sm          <= RXA_TRIAL_RELEASE;
                                   end

               RXA_TRIAL_RELEASE : begin
                                      if (|rxa_timer[4:3]) begin
                                         rx_purge <= 1'b0;
                                         if (rx_any_pfull) begin
                                            // will be overflowing soon - try again
                                            rxa_sm <= RXA_INIT;
                                         end
                                         if (rx_none_pempty) begin
                                            // life in all lanes - start reading
                                            rxa_sm <= RXA_TRIAL_ENGAGE;
                                         end
                                      end
                                   end

               RXA_TRIAL_ENGAGE  : begin
                                      if (any_control) begin
                                         if (all_control) begin
                                            // confirmation of good alignment, declare lock
                                            rxa_sm         <= RXA_MONITOR_LOCK;
                                            bad_align_cntr <= 3'b0;
                                         end
                                         else begin
                                            // false start, try again
                                            rxa_sm <= RXA_INIT;
                                         end
                                      end
                                   end

               RXA_MONITOR_LOCK  : begin
                                      rx_align_locked <= 1'b1;
                                      if (rxa_timer[4] && any_control) begin
                                         if (all_control) begin
                                            // good alignment detected
                                            bad_align_cntr <= 3'b0;
                                         end
                                         else begin
                                            bad_align_cntr <= bad_align_cntr + 1'b1;
                                            rxa_timer      <= 5'h0;
                                            if (bad_align_cntr[2]) begin
                                               // after 4 bad alignments something is very wrong
                                               // release and try again
                                               rxa_sm <= RXA_INIT;
                                            end
                                         end
                                      end
                                   end
            endcase
         end
      end
   end

   assign rx_lanes_aligned = rx_align_locked;

   // call 2 out of 3 lanes showing framing a drop - to tolerate some bit error on the control bits
   wire rx_framing_decision = (rx_framing_i[0] & rx_framing_i[1]) |
                              (rx_framing_i[0] & rx_framing_i[2]) |
                              (rx_framing_i[1] & rx_framing_i[2]);

   // rx output registers - drop the framing layer words
   always @(posedge clk_rx_common) begin
      if (srst_rx_common) begin
         rx_valid <= {NUM_LANES{1'b0}};
         rx_dout  <= {(NUM_LANES*BITS_PER_LANE){1'b0}};
      end
      else begin
         rx_valid <= rx_valid_i & ~{NUM_LANES{rx_framing_decision}};
         rx_dout  <= rx_dout_i;
      end
   end

   /////////////////////////////////////////////////
   // cadence
   /////////////////////////////////////////////////

   // used a smoothed version of the RX fifo to push new data out
   reg last_rx_cadence;
   reg                 [NUM_LANES-1:0] rx_pempty_r;

   always @(posedge clk_rx_common) begin
      rx_pempty_r <= rx_pempty;
   end

   always @(posedge clk_rx_common) begin
      if (srst_rx_common) begin
         rx_cadence      <= 1'b0;
         last_rx_cadence <= 1'b0;
      end
      else begin
         last_rx_cadence <= rx_cadence;
         rx_cadence      <= (~|rx_pempty_r) && (!last_rx_cadence || !rx_cadence);
      end
   end

endmodule //ilk_rx_aligner
