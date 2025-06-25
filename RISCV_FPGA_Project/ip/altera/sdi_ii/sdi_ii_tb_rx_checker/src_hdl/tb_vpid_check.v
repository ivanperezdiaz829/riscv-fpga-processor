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





`timescale 100 fs / 100 fs

module tb_vpid_check
(
   // port list
   clk,
   enable,
   dl_mapping,
   vid_std,
   rxdata,
   rxdata_valid,
   rxdata_b,
   rxdata_valid_b,
   rx_v,
   rx_vpid_byte1,
   rx_vpid_byte2,
   rx_vpid_byte3,
   rx_vpid_byte4,
   rx_vpid_valid,
   rx_vpid_checksum_error,
   rx_vpid_byte1_b,
   rx_vpid_byte2_b,
   rx_vpid_byte3_b,
   rx_vpid_byte4_b,
   rx_vpid_valid_b,
   rx_vpid_checksum_error_b,
   tx_format,
   rx_line_f0,
   rx_line_f1,
   error_out,
   test_complete
);

parameter rx_a2b = 1'b0;
parameter rx_b2a = 1'b0;
parameter vpid_ins = 1'b1;
parameter vpid_ext = 1'b1;
parameter gen_anc = 1'b1;
parameter gen_vpid = 1'b1;
parameter vpid_gen_count = 3;
parameter err_vpid = 1'b0;
parameter vpid_overwrite = 1'b1;
parameter en_vpid_b = 1'b0;
parameter mode_sd = 1'b1;
parameter mode_hd = 1'b0;
parameter mode_dl = 1'b0;
parameter mode_3g = 1'b0;
parameter mode_ds = 1'b0;
parameter mode_tr = 1'b0;

//--------------------------------------------------------------------------------------------------------------------------------------------------------
//Test case 1: No ANC packet - GEN_ANC = 0, VPID_INS = 1, VPID_EXT = 1
//
//Test case 2: VPID packet exists, overwrite the VPID info if enabled - GEN_ANC = 1, GEN_VPID = 1, VPID_PKT_COUNT = 1, TEST_VPID_OVERWRITE = 1 or 0
//             Note: If TEST_VPID_OVERWRITE is disabled, vpid_bytes and vpid_valid wouldn't get updated as DID info is invalid.
//
//Test case 3: Other ANC packet exists, VPID is inserted later - GEN_ANC = 1, GEN_VPID = 0, VPID_PKT_COUNT = 1 (changable), VPID_INS = 1
//
//Test case 4: Receive errorneous VPID packets - GEN_ANC = 1, GEN_VPID = 1, VPID_GEN_COUNT = 1, ERR_VPID = 1, VPID_INS = 0, VPID_EXT = 1 
//----------------------------------------------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------
// port declaration
//--------------------------------------------------------------------------
localparam check_vpid_once = (vpid_ins && !gen_anc && !err_vpid) || (gen_anc && gen_vpid && (vpid_gen_count == 1) && !err_vpid);
localparam check_vpid_multiple = (gen_anc && gen_vpid && (vpid_gen_count > 1) && !err_vpid);
localparam check_did_then_vpid = ((gen_anc && !gen_vpid) && vpid_ins && !err_vpid);
localparam check_vpid_error = (err_vpid);

input          clk;
input          enable;
input          dl_mapping;
input          rxdata_valid;
input          rxdata_valid_b;
input [19:0]   rxdata;
input [19:0]   rxdata_b;
input [1:0]    vid_std;
input          rx_v;
input [7:0]    rx_vpid_byte1;
input [7:0]    rx_vpid_byte2;
input [7:0]    rx_vpid_byte3;
input [7:0]    rx_vpid_byte4;
input          rx_vpid_valid;
input          rx_vpid_checksum_error;
input [7:0]    rx_vpid_byte1_b;
input [7:0]    rx_vpid_byte2_b;
input [7:0]    rx_vpid_byte3_b;
input [7:0]    rx_vpid_byte4_b;
input          rx_vpid_valid_b;
input          rx_vpid_checksum_error_b;
input [3:0]    tx_format;
input [10:0]   rx_line_f0;
input [10:0]   rx_line_f1;
output         error_out;
output         test_complete;

//-----------------------------------------------------------------------------------------------------------------------
// Interlaced format has 2 vpid lines per frame. In test mode video format, SD and HD are transmitting interlaced format.
// This is added for faster checking.
//------------------------------------------------------------------------------------------------------------------------
reg interlaced;

always @ (vid_std)
begin
   if (vid_std[1] == 1'b0 && ~mode_dl) begin
      interlaced = 1'b1;
   end else begin
      interlaced = 1'b0;
   end
end

reg [10:0] vpid_line_f0;
reg [10:0] vpid_line_f1;
always @ (tx_format)
begin
   case (tx_format)
      4'd0 : begin vpid_line_f0 <= 11'd13; vpid_line_f1 <= 11'd276; end
      4'd1 : begin vpid_line_f0 <= 11'd9; vpid_line_f1 <= 11'd322; end
      4'd2 : begin vpid_line_f0 <= 11'd10; vpid_line_f1 <= 11'd572; end
      4'd3 : begin vpid_line_f0 <= 11'd10; vpid_line_f1 <= 11'd572; end
      4'd4 : begin vpid_line_f0 <= 11'd10; vpid_line_f1 <= 11'd572; end
      4'd5 : begin vpid_line_f0 <= 11'd10; vpid_line_f1 <= 11'd572; end
      default : begin vpid_line_f0 <= 11'd10; vpid_line_f1 <= 11'd0; end
   endcase
end

//-----------------------------------------------------------------------------------------------------------------------
// Rxdata register for 3GB case so that data_clk can be aligned with 3gb data
//------------------------------------------------------------------------------------------------------------------------
reg [119:0]   rxdata_3gb;
reg           trs_3gb_detected;

always @ (posedge clk or posedge enable)
begin
   if (~enable) begin
      rxdata_3gb <= 120'd0;
      trs_3gb_detected <= 1'b0;
   end else begin
      if (vid_std == 2'b10) begin
         rxdata_3gb[119:20] <= rxdata_3gb[99:0];
         rxdata_3gb[19:0] <= rxdata;

         if (rxdata_3gb[119:0] == {{2{20'hfffff}}, {4{20'h00000}}}) begin
            trs_3gb_detected <= 1'b1;
         end
      end else begin
         rxdata_3gb <= 120'd0;
         trs_3gb_detected <= 1'b0;
      end
   end
end

//------------------------------------------------------------------------------------------------------------------
// Create a clock corresponds to the data rate of receiving video standard
//------------------------------------------------------------------------------------------------------------------
reg           data_clk;
// reg      data_clk_b;
integer       clk_3gb_counter = 0;

always @ (clk)
begin
   if (vid_std == 2'b10) begin
      if (clk && trs_3gb_detected) begin
        clk_3gb_counter = clk_3gb_counter + 1;
      end

     if (clk_3gb_counter == 2) begin
       data_clk = 1'b0;
       clk_3gb_counter = 0;
     end
     else if (clk_3gb_counter == 1) data_clk = 1'b1;
   end

   else begin
     if (rxdata_valid && clk) data_clk = 1'b1;
     else data_clk = 1'b0;

     // if (rxdata_valid_b && clk) data_clk_b = 1'b1;
     // else data_clk_b = 1'b0;
   end
end

//------------------------------------------------------------------------------------------------------------------
// Signal indicating an ANC packet is detected
//------------------------------------------------------------------------------------------------------------------
reg      anc_detected_a;
reg      second_adf_a;
reg      first_adf_a;
reg      anc_detected_b;
reg      second_adf_b;
reg      first_adf_b;
reg      check_msb;
reg      check_done;

always @ (posedge data_clk or posedge check_done or posedge enable)
begin
   if (~enable) begin
      anc_detected_a <= 1'b0;
      anc_detected_b <= 1'b0;
      second_adf_a <= 1'b0;
      second_adf_b <= 1'b0;
      first_adf_a <= 1'b0;
      first_adf_b <= 1'b0;
      check_msb <= 1'b0;
   end else if (check_done) begin
      check_msb <= 1'b0;
   end else begin
      anc_detected_a <= 1'b0;
      if (second_adf_a && (rxdata[19:10] == 10'h3ff || rxdata[9:0] == 10'h3ff)) begin
         if (rxdata[19:10] == 10'h3ff) begin
            check_msb <= 1'b1;
         end
         anc_detected_a <= 1'b1;
      end else begin
         second_adf_a = 1'b0;
         if (first_adf_a && (rxdata[19:10] == 10'h3ff || rxdata[9:0] == 10'h3ff)) begin
            second_adf_a <= 1'b1;
         end else begin
            first_adf_a = 1'b0;
            if (rxdata[19:10] == 10'd0 || rxdata[9:0] == 10'd0) begin
               first_adf_a <= 1'b1;
            end
         end
      end

      anc_detected_b <= 1'b0;
      if (second_adf_b && (rxdata_b[19:10] == 10'h3ff || rxdata_b[9:0] == 10'h3ff)) begin
         if (rxdata_b[19:10] == 10'h3ff) begin
            check_msb <= 1'b1;
         end
         anc_detected_b <= 1'b1;
      end else begin
         second_adf_b = 1'b0;
         if (first_adf_b && (rxdata_b[19:10] == 10'h3ff || rxdata_b[9:0] == 10'h3ff)) begin
            second_adf_b <= 1'b1;
         end else begin
            first_adf_b = 1'b0;
            if (rxdata_b[19:10] == 10'd0 || rxdata_b[9:0] == 10'd0) begin
               first_adf_b <= 1'b1;
            end
         end
      end
   end
end

wire [9:0] rxdata_tocheck;
wire [9:0] rxdata_tocheck_b;
assign rxdata_tocheck = rxdata[19:10];
assign rxdata_tocheck_b = rxdata_b[19:10];

//------------------------------------------------------------------------------------------------------------------
// Detect checksum error
//------------------------------------------------------------------------------------------------------------------
reg checksum_error_det;
reg   check_vpid_valid_low;

always @ (rx_vpid_checksum_error or rx_vpid_checksum_error_b or check_vpid_valid_low)
begin
   if (check_vpid_valid_low) begin
     if (rx_vpid_checksum_error || rx_vpid_checksum_error_b) checksum_error_det = 1'b1;
   end
   else checksum_error_det = 1'b0;
end

//------------------------------------------------------------------------------------------------------------------
// Determine the sequence of the test depending on the passed in parameters
//------------------------------------------------------------------------------------------------------------------
reg   check_vpid_ins;
reg   check_vpid_false;
reg   check_vpid_byte;
reg   check_err_vpid_byte;
// reg   check_done;
reg   vpid_error;
reg   error_out;
reg   test_complete;
wire  anc_detected = anc_detected_a || anc_detected_b;

always @ (enable)
begin
   if (enable) begin
     // Check VPID packet for a single frame
     if (check_vpid_once) begin
       if (rx_b2a) begin
         repeat (2) @(posedge anc_detected);
       end else begin
         @(posedge anc_detected);
       end
       $display ("VPID packet detected. Checking VPID...");
       check_vpid_ins = 1'b1;
       wait (check_done);
       if (vpid_error || error_out) error_out = 1'b1;
       else error_out = 1'b0;
       check_vpid_ins =  1'b0;

       if (interlaced) begin
         $display("Receiving format is interlaced format. Waiting for the next VPID packet...");
         @(posedge anc_detected);
         $display ("VPID packet detected. Checking VPID...");
         check_vpid_ins = 1'b1;
         wait (check_done);
         if (vpid_error || error_out) error_out = 1'b1;
         else error_out = 1'b0;
         check_vpid_ins =  1'b0;
       end

       if (vpid_overwrite) begin
          if (vpid_line_f0 == rx_line_f0 && vpid_line_f1 == rx_line_f1) begin
             if (~error_out) begin
                error_out = 1'b0;
             end
          end else begin
             $display ("Line_f0 and line_f1 between tx and rx are not match.");
             error_out = 1'b1;
          end
       end
       test_complete = 1'b1;
     end

     // Check VPID packets for multiple frames
     if (check_vpid_multiple) begin
       if (rx_b2a) begin
         @(posedge anc_detected);
       end
       repeat (vpid_gen_count) begin
         @(posedge anc_detected);
         $display ("VPID packet detected. Checking VPID...");
         check_vpid_ins = 1'b1;
         wait (check_done);
         if (vpid_error || error_out) error_out = 1'b1;
         else error_out = 1'b0;
         check_vpid_ins =  1'b0;
       end

       if (interlaced) begin
         repeat (vpid_gen_count) begin
           $display("Receiving format is interlaced format. Waiting for the next VPID packet...");
           @(posedge anc_detected);
           $display ("VPID packet detected. Checking VPID...");
           check_vpid_ins = 1'b1;
           wait (check_done);
           if (vpid_error || error_out) error_out = 1'b1;
           else error_out = 1'b0;
           check_vpid_ins =  1'b0;
         end
       end

       if (vpid_overwrite) begin
          if (vpid_line_f0 == rx_line_f0 && vpid_line_f1 == rx_line_f1) begin
             if (~error_out) begin
                error_out = 1'b0;
             end
          end else begin
             $display ("Line_f0 and line_f1 between tx and rx are not match.");
             error_out = 1'b1;
          end
       end
       test_complete = 1'b1;
     end

     // Check for VPID packet after other ANC packets
     if (check_did_then_vpid) begin
       if (rx_b2a) begin
         @(posedge anc_detected);
       end
       repeat (vpid_gen_count) begin
         @(posedge anc_detected);
         $display ("ANC packet detected.");
         check_vpid_false = 1'b1;
         wait (check_done);
         if (vpid_error || error_out) error_out = 1'b1;
         else error_out = 1'b0;
         check_vpid_false = 1'b0;
       end
       @(posedge anc_detected);
       $display ("VPID packet detected. Checking VPID...");
       check_vpid_ins = 1'b1;
       wait (check_done);
       if (vpid_error || error_out) error_out = 1'b1;
       else error_out = 1'b0;
       check_vpid_ins =  1'b0;

       if (interlaced) begin
         repeat (vpid_gen_count) begin
           $display("Receiving format is interlaced format. Waiting for the next VPID packet...");
           @(posedge anc_detected);
           $display ("ANC packet detected.");
           check_vpid_false = 1'b1;
           wait (check_done);
           if (vpid_error || error_out) error_out = 1'b1;
           else error_out = 1'b0;
           check_vpid_false = 1'b0;
         end
         @(posedge anc_detected);
         $display ("VPID packet detected. Checking VPID...");
         check_vpid_ins = 1'b1;
         wait (check_done);
         if (vpid_error || error_out) error_out = 1'b1;
         else error_out = 1'b0;
         check_vpid_ins =  1'b0;
       end

       if (vpid_overwrite) begin
          if (vpid_line_f0 == rx_line_f0 && vpid_line_f1 == rx_line_f1) begin
             if (~error_out) begin
                error_out = 1'b0;
             end
          end else begin
             $display ("Line_f0 and line_f1 between tx and rx are not match.");
             error_out = 1'b1;
          end
       end
       test_complete = 1'b1;
     end

     // Check whether VPID bytes is updated upon receiving bad VPID packet
     // then monitor vpid_valid signal after receiving a good VPID packet followed by missing VPID packets for a few frames 
     if (check_vpid_error) begin
       if (rx_b2a) begin
         repeat (2) @(posedge anc_detected);
       end else begin
         @(posedge anc_detected);
       end
       $display ("VPID packet detected, however vpid_valid signal should be low.");
       check_vpid_valid_low = 1'b1;
       wait (check_done);
       if (vpid_error) begin
          error_out = 1'b1;
          $display ("vpid_valid signal is HIGH.");
       end else begin
          error_out = 1'b0;
          $display ("vpid_valid signal is LOW.");
       end
       if (~checksum_error_det || error_out ) begin
          $display ("rx_vpid_checksum_error is LOW.");
          error_out = 1'b1;
       end else begin
          $display ("rx_vpid_checksum_error is HIGH.");
          error_out = 1'b0;
       end
       check_vpid_valid_low = 1'b0;

       if (interlaced) begin
         $display("Receiving format is interlaced format. Waiting for the next VPID packet...");
         @(posedge anc_detected);
         $display ("VPID packet detected, however vpid_valid signal should be low.");
         check_vpid_valid_low = 1'b1;
         wait (check_done);
         if (vpid_error || error_out) begin
            error_out = 1'b1;
            $display ("vpid_valid signal is HIGH.");
         end else begin
            error_out = 1'b0;
            $display ("vpid_valid signal is LOW.");
         end
         if (~checksum_error_det || error_out ) begin
            $display ("rx_vpid_checksum_error is LOW.");
            error_out = 1'b1;
         end else begin
            $display ("rx_vpid_checksum_error is HIGH.");
            error_out = 1'b0;
         end
         check_vpid_valid_low = 1'b0;
       end

       $display ("Test proceeds to receiving a valid VPID packet. Waiting for the VPID packet...");
       @(posedge anc_detected);
       $display ("VPID packet detected. Checking VPID...");
       check_vpid_ins = 1'b1;
       wait (check_done);
       if (vpid_error || error_out) error_out = 1'b1;
       else error_out = 1'b0;
       check_vpid_ins =  1'b0;

       if (interlaced) begin
         $display("Receiving format is interlaced format. Waiting for the next VPID packet...");
         @(posedge anc_detected);
         $display ("VPID packet detected. Checking VPID...");
         check_vpid_ins = 1'b1;
         wait (check_done);
         if (vpid_error || error_out) error_out = 1'b1;
         else error_out = 1'b0;
         check_vpid_ins =  1'b0;
       end

       //if (vpid_overwrite) begin
       //   if (tx_line_f0 == rx_line_f0 && tx_line_f1 == rx_line_f1) begin
       //      if (~error_out) begin
       //         error_out = 1'b0;
       //      end
       //   end else begin
       //      $display ("Line_f0 and line_f1 between tx and rx are not match.");
       //      error_out = 1'b1;
       //   end
       //end

       $display ("Test proceeds to receiving a few non-valid VPID packet. Expecting vpid_valid signal to be deasserted after a few frames.");
       if (mode_dl) begin
          repeat (7) @(negedge rx_v);
       end else begin
          repeat (5) @(negedge rx_v);
       end
       check_vpid_valid_low = 1'b1;
       wait (check_done);
         if (vpid_error || error_out) begin
            error_out = 1'b1;
            $display ("vpid_valid signal is HIGH.");
         end else begin
            error_out = 1'b0;
            $display ("vpid_valid signal is LOW.");
         end
       check_vpid_valid_low =  1'b0;
       test_complete = 1'b1;
     end
   end

   else begin
     check_vpid_ins = 1'b0;
     check_vpid_false = 1'b0;
     check_vpid_byte = 1'b0;
     check_err_vpid_byte = 1'b0;
     check_vpid_valid_low = 1'b0;
     test_complete = 1'b0;
   end
end

//------------------------------------------------------------------------------------------------------------------
// Calculate checksum upon receiving a good VPID packet
//------------------------------------------------------------------------------------------------------------------
reg         init_cs;
reg         calc_cs;
reg [8:0]   checksum;
reg [8:0]   checksum_b;

always @ (posedge init_cs or posedge calc_cs)
begin
   if (init_cs) begin
     checksum = {(rxdata_tocheck[7]^rxdata_tocheck[6]^rxdata_tocheck[5]^rxdata_tocheck[4]^rxdata_tocheck[3]^rxdata_tocheck[2]^rxdata_tocheck[1]^rxdata_tocheck[0]), rxdata_tocheck[7:0]};
     checksum_b = {(rxdata_tocheck_b[7]^rxdata_tocheck_b[6]^rxdata_tocheck_b[5]^rxdata_tocheck_b[4]^rxdata_tocheck_b[3]^rxdata_tocheck_b[2]^rxdata_tocheck_b[1]^rxdata_tocheck_b[0]), rxdata_tocheck_b[7:0]};
   end
   else if (calc_cs) begin
     checksum = checksum + {(rxdata_tocheck[7]^rxdata_tocheck[6]^rxdata_tocheck[5]^rxdata_tocheck[4]^rxdata_tocheck[3]^rxdata_tocheck[2]^rxdata_tocheck[1]^rxdata_tocheck[0]), rxdata_tocheck[7:0]};
     checksum_b = checksum_b + {(rxdata_tocheck_b[7]^rxdata_tocheck_b[6]^rxdata_tocheck_b[5]^rxdata_tocheck_b[4]^rxdata_tocheck_b[3]^rxdata_tocheck_b[2]^rxdata_tocheck_b[1]^rxdata_tocheck_b[0]), rxdata_tocheck_b[7:0]};
   end
end

//------------------------------------------------------------------------------------------------------------------
// Check received data when certain task is enabled in the sequence
//------------------------------------------------------------------------------------------------------------------
reg [7:0]   vpid_byte1;
reg [7:0]   vpid_byte1_b;
reg [7:0]   vpid_byte2;
reg [7:0]   vpid_byte2_b;
reg [7:0]   vpid_byte3;
reg [7:0]   vpid_byte3_b;
reg [7:0]   vpid_byte4;
reg [7:0]   vpid_byte4_b;
reg [7:0]   err_vpid_byte1;
reg [7:0]   vpid_byte4_3gb;
reg         vpid_present_in_a;
reg         vpid_present_in_b;
reg         vpid_pkt_a_correct;
reg         vpid_pkt_b_correct;

always @ (check_vpid_ins or check_vpid_false or check_vpid_valid_low)
begin
   check_done = 1'b0;

   // Check VPID packet
   if (check_vpid_ins) begin
     vpid_error = 1'b1;
     init_cs = 1'b0;
     calc_cs = 1'b0;
     vpid_present_in_a = 1'b0;
     vpid_present_in_b = 1'b0;
     @(posedge data_clk);
     //If vpid_overwrite is disabled, did = 341 and vpid_valid wouldn't be asserted
     if (rxdata_tocheck == vpid_overwrite ? 10'h241 : 10'h341 || rxdata_tocheck_b == vpid_overwrite ? 10'h241 : 10'h341) begin
        if (rxdata_tocheck[7:0] == 8'h41) begin
           vpid_present_in_a = 1'b1;
        end
        if (rxdata_tocheck_b[7:0] == 8'h41) begin
           vpid_present_in_b = 1'b1;
        end

        if (vid_std[1]) begin
           if (rxdata_tocheck == rxdata[9:0]) begin
              vpid_error = 1'b0;
           end
        end else begin
           vpid_error = 1'b0;
        end
     end else begin
        vpid_error = 1'b1;
     end
     init_cs = 1'b1;
     @(posedge data_clk);
     init_cs = 1'b0;
     if (vpid_present_in_a) begin
        if (rxdata_tocheck == 10'h101 && ~vpid_error) begin
           if (vid_std[1]) begin
              if (rxdata_tocheck == rxdata[9:0]) begin
                 vpid_error = 1'b0;
              end
           end else begin
              vpid_error = 1'b0;
           end
        end else begin
           vpid_error = 1'b1;
           $display("Expecting 10'h101 but received %h", rxdata_tocheck);
        end
     end
     if (vpid_present_in_b) begin
        if (rxdata_tocheck_b == 10'h101 && ~vpid_error) begin
           vpid_error = 1'b0;
        end else begin
           vpid_error = 1'b1;
           $display("Expecting 10'h101 but received %h", rxdata_tocheck_b);
        end
     end
     calc_cs = 1'b1;
     #(1);
     calc_cs = 1'b0;
     @(posedge data_clk);
     if (vpid_present_in_a) begin
        if (rxdata_tocheck == 10'h104 && ~vpid_error) begin
           if (vid_std[1]) begin
              if (rxdata_tocheck == rxdata[9:0]) begin
                 vpid_error = 1'b0;
              end
           end else begin
              vpid_error = 1'b0;
           end
        end else begin
           vpid_error = 1'b1;
           $display("Expecting 10'h104 but received %h", rxdata_tocheck);
        end
     end
     if (vpid_present_in_b) begin
        if (rxdata_tocheck_b == 10'h104 && ~vpid_error) begin
           vpid_error = 1'b0;
        end else begin
           vpid_error = 1'b1;
           $display("Expecting 10'h104 but received %h", rxdata_tocheck_b);
        end
     end
     calc_cs = 1'b1;
     #(1);
     calc_cs = 1'b0;
     @(posedge data_clk);
     if (vpid_present_in_a) begin
        if (rxdata_tocheck[8] == rxdata_tocheck[7]^rxdata_tocheck[6]^rxdata_tocheck[5]^rxdata_tocheck[4]^rxdata_tocheck[3]^rxdata_tocheck[2]^rxdata_tocheck[1]^rxdata_tocheck[0] && rxdata_tocheck[9] == ~rxdata_tocheck[8] && ~vpid_error) begin
           if (vid_std[1]) begin
              if (rxdata_tocheck == rxdata[9:0]) begin
                 vpid_error = 1'b0;
              end
           end else begin
              vpid_error = 1'b0;
           end
        end else begin
           vpid_error = 1'b1;
           $display("rxdata_tocheck = %h, rxdata_tocheck[8] = %b, expected value should be %b", rxdata_tocheck, rxdata_tocheck[8], rxdata_tocheck[7]^rxdata_tocheck[6]^rxdata_tocheck[5]^rxdata_tocheck[4]^rxdata_tocheck[3]^rxdata_tocheck[2]^rxdata_tocheck[1]^rxdata_tocheck[0]);
        end
     end
     if (vpid_present_in_b) begin
         if (rxdata_tocheck_b[8] == rxdata_tocheck_b[7]^rxdata_tocheck_b[6]^rxdata_tocheck_b[5]^rxdata_tocheck_b[4]^rxdata_tocheck_b[3]^rxdata_tocheck_b[2]^rxdata_tocheck_b[1]^rxdata_tocheck_b[0] && rxdata_tocheck_b[9] == ~rxdata_tocheck_b[8] && ~vpid_error) begin
            vpid_error = 1'b0;
         end else begin
            vpid_pkt_b_correct = 1'b0;
            $display("rxdata_tocheck_b = %h, rxdata_tocheck_b[8] = %b, expected value should be %b", rxdata_tocheck_b, rxdata_tocheck_b[8], rxdata_tocheck_b[7]^rxdata_tocheck_b[6]^rxdata_tocheck_b[5]^rxdata_tocheck_b[4]^rxdata_tocheck_b[3]^rxdata_tocheck_b[2]^rxdata_tocheck_b[1]^rxdata_tocheck_b[0]);
         end
     end
     vpid_byte1[7:4] = (vpid_present_in_a) ? rxdata_tocheck[7:4] : vpid_byte1[7:4];
     vpid_byte1_b[7:4] = (vpid_present_in_b) ? rxdata_tocheck_b[7:4] : ((vid_std==2'b10) ? rxdata_tocheck[7:4] : vpid_byte1_b[7:4]);
     vpid_byte1[3:0] = (vpid_present_in_a) ? (dl_mapping ? (vid_std == 2'b10 ? 4'hA : 4'h7) :
                                              rxdata_tocheck[3:0]) :
                        vpid_byte1[3:0];
     vpid_byte1_b[3:0] = (vpid_present_in_b) ? (dl_mapping ? (vid_std == 2'b10 ? 4'hA : 4'h7) :
                                                rxdata_tocheck[3:0]) :
                          (vid_std == 2'b10 ? rxdata_tocheck[3:0] : vpid_byte1_b[3:0]);
     calc_cs = 1'b1;
     #(1);
     calc_cs = 1'b0;
     @(posedge data_clk);
     if (vpid_present_in_a) begin
        if (rxdata_tocheck[8] == rxdata_tocheck[7]^rxdata_tocheck[6]^rxdata_tocheck[5]^rxdata_tocheck[4]^rxdata_tocheck[3]^rxdata_tocheck[2]^rxdata_tocheck[1]^rxdata_tocheck[0] && rxdata_tocheck[9] == ~rxdata_tocheck[8] && ~vpid_error) begin
           if (vid_std[1]) begin
              if (rxdata_tocheck == rxdata[9:0]) begin
                 vpid_error = 1'b0;
              end
           end else begin
              vpid_error = 1'b0;
           end
        end else begin
            vpid_error = 1'b1;
            $display("rxdata_tocheck = %h, rxdata_tocheck[8] = %b, expected value should be %b", rxdata_tocheck, rxdata_tocheck[8], rxdata_tocheck[7]^rxdata_tocheck[6]^rxdata_tocheck[5]^rxdata_tocheck[4]^rxdata_tocheck[3]^rxdata_tocheck[2]^rxdata_tocheck[1]^rxdata_tocheck[0]);
        end
     end
     if (vpid_present_in_b) begin
         if (rxdata_tocheck_b[8] == rxdata_tocheck_b[7]^rxdata_tocheck_b[6]^rxdata_tocheck_b[5]^rxdata_tocheck_b[4]^rxdata_tocheck_b[3]^rxdata_tocheck_b[2]^rxdata_tocheck_b[1]^rxdata_tocheck_b[0] && rxdata_tocheck_b[9] == ~rxdata_tocheck_b[8] && ~vpid_error) begin
            vpid_error = 1'b0;
         end else begin
            vpid_error = 1'b1;
            $display("rxdata_tocheck_b = %h, rxdata_tocheck_b[8] = %b, expected value should be %b", rxdata_tocheck_b, rxdata_tocheck_b[8], rxdata_tocheck_b[7]^rxdata_tocheck_b[6]^rxdata_tocheck_b[5]^rxdata_tocheck_b[4]^rxdata_tocheck_b[3]^rxdata_tocheck_b[2]^rxdata_tocheck_b[1]^rxdata_tocheck_b[0]);
         end
     end
     vpid_byte2 = (vpid_present_in_a) ? rxdata_tocheck[7:0] : vpid_byte2;
     vpid_byte2_b = (vpid_present_in_b) ? rxdata_tocheck_b[7:0] : ((vid_std==2'b10) ? rxdata_tocheck[7:0] : vpid_byte2_b);
     calc_cs = 1'b1;
     #(1);
     calc_cs = 1'b0;
     @(posedge data_clk);
     if (vpid_present_in_a) begin
        if (rxdata_tocheck[8] == rxdata_tocheck[7]^rxdata_tocheck[6]^rxdata_tocheck[5]^rxdata_tocheck[4]^rxdata_tocheck[3]^rxdata_tocheck[2]^rxdata_tocheck[1]^rxdata_tocheck[0] && rxdata_tocheck[9] == ~rxdata_tocheck[8] && ~vpid_error) begin
           if (vid_std[1]) begin
              if (rxdata_tocheck == rxdata[9:0]) begin
                 vpid_error = 1'b0;
              end
           end else begin
              vpid_error = 1'b0;
           end
        end else begin
           vpid_error = 1'b1;
           $display("rxdata_tocheck = %h, rxdata_tocheck[8] = %b, expected value should be %b", rxdata_tocheck, rxdata_tocheck[8], rxdata_tocheck[7]^rxdata_tocheck[6]^rxdata_tocheck[5]^rxdata_tocheck[4]^rxdata_tocheck[3]^rxdata_tocheck[2]^rxdata_tocheck[1]^rxdata_tocheck[0]);
        end
     end
     if (vpid_present_in_b) begin
         if (rxdata_tocheck_b[8] == rxdata_tocheck_b[7]^rxdata_tocheck_b[6]^rxdata_tocheck_b[5]^rxdata_tocheck_b[4]^rxdata_tocheck_b[3]^rxdata_tocheck_b[2]^rxdata_tocheck_b[1]^rxdata_tocheck_b[0] && rxdata_tocheck_b[9] == ~rxdata_tocheck_b[8] && ~vpid_error) begin
            vpid_error = 1'b0;
         end else begin
            vpid_error = 1'b1;
            $display("rxdata_tocheck_b = %h, rxdata_tocheck_b[8] = %b, expected value should be %b", rxdata_tocheck_b, rxdata_tocheck_b[8], rxdata_tocheck_b[7]^rxdata_tocheck_b[6]^rxdata_tocheck_b[5]^rxdata_tocheck_b[4]^rxdata_tocheck_b[3]^rxdata_tocheck_b[2]^rxdata_tocheck_b[1]^rxdata_tocheck_b[0]);
         end
     end
     vpid_byte3 = (vpid_present_in_a) ? rxdata_tocheck[7:0] : vpid_byte3;
     vpid_byte3_b = (vpid_present_in_b) ? rxdata_tocheck_b[7:0] : ((vid_std==2'b10) ? rxdata_tocheck[7:0] : vpid_byte3_b);
     calc_cs = 1'b1;
     #(1);
     calc_cs = 1'b0;
     @(posedge data_clk);
     if (vpid_present_in_a) begin
        if (rxdata_tocheck[8] == rxdata_tocheck[7]^rxdata_tocheck[6]^rxdata_tocheck[5]^rxdata_tocheck[4]^rxdata_tocheck[3]^rxdata_tocheck[2]^rxdata_tocheck[1]^rxdata_tocheck[0] && rxdata_tocheck[9] == ~rxdata_tocheck[8] && ~vpid_error) begin
           if (vid_std[1]) begin
              if (rxdata_tocheck == rxdata[9:0]) begin
                 vpid_error = 1'b0;
              end
           end else begin
              vpid_error = 1'b0;
           end
        end else begin
           vpid_error = 1'b1;
           $display("rxdata_tocheck = %h, rxdata_tocheck[8] = %b, expected value should be %b", rxdata_tocheck, rxdata_tocheck[8], rxdata_tocheck[7]^rxdata_tocheck[6]^rxdata_tocheck[5]^rxdata_tocheck[4]^rxdata_tocheck[3]^rxdata_tocheck[2]^rxdata_tocheck[1]^rxdata_tocheck[0]);
        end
     end
     if (vpid_present_in_b) begin
         if (rxdata_tocheck_b[8] == rxdata_tocheck_b[7]^rxdata_tocheck_b[6]^rxdata_tocheck_b[5]^rxdata_tocheck_b[4]^rxdata_tocheck_b[3]^rxdata_tocheck_b[2]^rxdata_tocheck_b[1]^rxdata_tocheck_b[0] && rxdata_tocheck_b[9] == ~rxdata_tocheck_b[8] && ~vpid_error) begin
            vpid_error = 1'b0;
         end else begin
            vpid_error = 1'b1;
            $display("rxdata_tocheck_b = %h, rxdata_tocheck_b[8] = %b, expected value should be %b", rxdata_tocheck_b, rxdata_tocheck_b[8], rxdata_tocheck_b[7]^rxdata_tocheck_b[6]^rxdata_tocheck_b[5]^rxdata_tocheck_b[4]^rxdata_tocheck_b[3]^rxdata_tocheck_b[2]^rxdata_tocheck_b[1]^rxdata_tocheck_b[0]);
         end
     end
     vpid_byte4 = (vpid_present_in_a) ? rxdata_tocheck[7:0] : vpid_byte4;
     vpid_byte4_b = (vpid_present_in_b) ? rxdata_tocheck_b[7:0] : ((vid_std==2'b10) ? {rxdata_tocheck[7], 1'b1, rxdata_tocheck[5:0]} : vpid_byte4_b);
     calc_cs = 1'b1;
     #(1);
     calc_cs = 1'b0;
     @(posedge data_clk);
     if ((rxdata_tocheck == {~checksum[8], checksum} || rxdata_tocheck_b == {~checksum_b[8], checksum_b} )&& !vpid_error) begin
        if (vid_std[1]) begin
           if (rxdata_tocheck == rxdata[9:0]) begin
              vpid_error = 1'b0;
           end
        end else begin
           vpid_error = 1'b0;
        end
     end else begin
        $display("Error in checksum. Rxdata = %h, Expected checksum = %h", rxdata_tocheck, {~checksum[8], checksum});
        vpid_error = 1'b1;
     end
     repeat (2) @(posedge data_clk);
     if (vpid_overwrite) begin
       if (vpid_present_in_a) begin
         if (rx_vpid_valid) begin
           if (rx_vpid_byte1 == vpid_byte1 && rx_vpid_byte2 == vpid_byte2 && rx_vpid_byte3 == vpid_byte3 && rx_vpid_byte4 == vpid_byte4 && !vpid_error) begin
              if (vid_std[1]) begin
                 if (rxdata_tocheck == rxdata[9:0]) begin
                    vpid_error = 1'b0;
                 end
              end else begin
                 vpid_error = 1'b0;
              end
           end else begin
             $display("Error in vpid_byte. Expected vpid_byte1 = %h, vpid_byte2 = %h, vpid_byte3 = %h, vpid_byte4 = %h", vpid_byte1, vpid_byte2, vpid_byte3, vpid_byte4);
             vpid_error = 1'b1;
           end
         end else begin
           $display("Rx_vpid_valid is not asserted.");
           vpid_error = 1'b1;
         end
       end
       if (vpid_present_in_b) begin
         if (rx_vpid_valid_b) begin
           if (rx_vpid_byte1_b == vpid_byte1_b && rx_vpid_byte2_b == vpid_byte2_b && rx_vpid_byte3_b == vpid_byte3_b && rx_vpid_byte4_b == vpid_byte4_b && !vpid_error) begin
             vpid_error = 1'b0;
           end else begin
             $display("Error in vpid_byte. Expected vpid_byte1_b = %h, vpid_byte2_b = %h, vpid_byte3_b = %h, vpid_byte4_b = %h", vpid_byte1_b, vpid_byte2_b, vpid_byte3_b, vpid_byte4_b);
             vpid_error = 1'b1;
           end
         end else begin
           $display("Rx_vpid_valid_b is not asserted.");
           vpid_error = 1'b1;
         end
       end
     end
     check_done = 1'b1;
   end

   // Check other ANC packet, if vpid is inserted here then assert error signal
   else if (check_vpid_false) begin
     vpid_error = 1'b1;
     @(posedge data_clk);
     if (anc_detected_a) begin
        if (rxdata_tocheck[7:0] != 8'h41) begin
           vpid_error = 1'b0;
        end else begin
           $display("Other anc packet should be present before VPID packet, current packet detected rxdata_tocheck[7:0] = %h", rxdata_tocheck[7:0]);
           vpid_error = 1'b1;
        end
     end
     if (anc_detected_b) begin
        if (rxdata_tocheck_b[7:0] != 8'h41) begin
           vpid_error = 1'b0;
        end else begin
           $display("Other anc packet should be present before VPID packet, current packet detected rxdata_tocheck_b[7:0] = %h", rxdata_tocheck_b[7:0]);
           vpid_error = 1'b1;
        end
     end
     check_done = 1'b1;
   end

   // Check vpid_valid signal remains low
   else if (check_vpid_valid_low) begin
     vpid_error = 1'b1;
     repeat (10) @(posedge data_clk);
     if (en_vpid_b) begin
       if (~rx_vpid_valid && ~rx_vpid_valid_b) vpid_error = 1'b0;
       else vpid_error = 1'b1;
     end else begin
       if (~rx_vpid_valid) vpid_error = 1'b0;
       else vpid_error = 1'b1;
     end       
     check_done = 1'b1;
   end

end

endmodule
