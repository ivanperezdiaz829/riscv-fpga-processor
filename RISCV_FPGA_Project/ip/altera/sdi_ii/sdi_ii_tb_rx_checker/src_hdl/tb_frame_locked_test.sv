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

module tb_frame_locked_test (
   rst,
   enable,
   clk,
   vid_std,
   trs_locked,
   trs_locked_b,
   frame_locked,
   frame_locked_b,
   align_locked,
   v,
   rx_eav,
   rx_trs,
   tx_format,
   rx_format,
   proceed,
   complete,
   error
);
    
   parameter  err_tolerance = 4;
   parameter  mode_dl = 1'b0;
//--------------------------------------------------------------------------
// local parameter declaration
//--------------------------------------------------------------------------
   localparam timeout_frame = err_tolerance + 4;

//--------------------------------------------------------------------------
// port declaration
//--------------------------------------------------------------------------

   input         rst;
   input         enable;
   input         clk;
   input [1:0]   vid_std;
   input         trs_locked;
   input         trs_locked_b;
   input         frame_locked;
   input         frame_locked_b;
   input         align_locked;
   input         v;
   input         rx_eav;
   input         rx_trs;
   input [3:0]   tx_format;
   input [3:0]   rx_format;
   output        proceed;
   output        complete;
   output        error;

   wire          frame_locked_detected = mode_dl ? (frame_locked || frame_locked_b) : frame_locked;
   wire          trs_locked_detected = mode_dl ? (trs_locked || trs_locked_b) : trs_locked;
//---------------------------------------------------------------------------
// Check format detected
//---------------------------------------------------------------------------
   reg error;
   reg fmt_err;

   always @ (posedge frame_locked or posedge rst)
   begin
     if (rst) fmt_err = 1'b1;
     else begin
       if (tx_format == rx_format) fmt_err = 1'b0;
       else fmt_err = 1'b1;
     end
   end

   always @ (negedge fmt_err or posedge rst)
   begin
     if (rst) error = 1'b1;
     else error = 1'b0;
   end

//---------------------------------------------------------------------------
// Test timeout
//---------------------------------------------------------------------------
   reg      proceed;
   reg      complete;
   reg      v_dly;
   integer  timeout_count;

   always @ (posedge clk or posedge rst)
   begin
     if (rst) begin
       v_dly <= 1'b0;
       timeout_count <= 0;
     end
     else if (enable) begin
       v_dly <= v;
       if (proceed == 1'b1) timeout_count <= 0;
       if (v == 1'b1 && v_dly == 1'b0 && complete == 1'b0) timeout_count <= timeout_count + 1;
       if (timeout_count == timeout_frame) begin
         $display ("Frame_locked test timeout!");
         $stop(0);
       end
       proceed <= 1'b0;
     end
   end

//---------------------------------------------------------------------------
// Error Counter
//---------------------------------------------------------------------------
   reg reach_tol_lvl;
   integer count_error;
   reg inc_err_count;

   always @ (posedge inc_err_count or posedge rst or posedge complete)
   begin
     if (rst || complete) begin
       count_error = 0;
       reach_tol_lvl = 1'b0;
     end
     else if (inc_err_count) begin
       count_error = count_error + 1;
       if (count_error >= err_tolerance) reach_tol_lvl = 1'b1;
     end
   end

//---------------------------------------------------------------------------
// 3G test stage indicator
//---------------------------------------------------------------------------
    // reg std3g_switched;
    // reg test3g_1stprt;
    // reg test3g_2ndprt;

    // always @ (posedge std3g_switched or posedge rst or posedge complete)
    // begin
      // if (rst || complete) begin
        // test3g_1stprt = 1'b0;
        // test3g_2ndprt = 1'b1;
      // end
      // else if (std3g_switched) begin
        // test3g_1stprt = 1'b0;
        // test3g_2ndprt = 1'b1;
      // end
    // end
	
    reg      start_frame_sequence_high;
    reg      start_frame_sequence_low;
    reg      start_align_sequence_high;
    //reg      start_align_sequence_low;
	
    //---------------------------------------------------------------------------
    // Sequence for assertion checking.
    // sequence frame_h : check for frame_locked is equals to high as long as start_frame_sequence_high=1'b1, else flag error.
    // sequence frame_l : check for frame_locked is equals to low as long as start_frame_sequence_low=1'b1, else flag error.
    // sequence align_h : check for align_locked is equals to high as long as start_align_sequence_high=1'b1, else flag error.
    // sequence align_l : check for align_locked is equals to low as long as start_align_sequence_low=1'b1, else flag error.
    //----------------------------------------------------------------------------
    wire flag_frame;
    wire flag_align;    

    assign flag_frame = frame_locked ? 1'b1 : 1'b0;	
    assign flag_align = align_locked ? 1'b1 : 1'b0;	
	
    sequence frame_h;
       @(posedge clk) 
       start_frame_sequence_high;
    endsequence

    sequence frame_l;
       @(posedge clk) 
       start_frame_sequence_low;
    endsequence

    sequence align_h;
       @(posedge clk) 
       start_align_sequence_high;
    endsequence

    // sequence align_l;
       // @(posedge clk) 
       // start_align_sequence_low;
    // endsequence

    property check_frame_lock_high; 
       @(posedge clk)
       frame_h |=> flag_frame==1;
    endproperty

    property check_frame_lock_low; 
       @(posedge clk)
       frame_l |=>  flag_frame==0;
    endproperty
 
    property check_align_lock_high; 
       @(posedge clk)
       align_h |=> flag_align==1;
    endproperty

    // property check_align_lock_low; 
       // @(posedge clk)
       // align_l |=>  flag_align==0;
    // endproperty

   //=================================================
   // Assertion Directive Layer
   //=================================================
   req_frame_assert : assert property (check_frame_lock_high)
                 else begin
		 error <= 1'b1;
                 $display ("\n Error occured. frame_locked is deasserted during RP168 switching.", $time);
                 $stop(0);
		 end

   req_frame_deassert : assert property (check_frame_lock_low)
                 else begin
		 error <= 1'b1;
                 $display ("\n Error occured. frame_locked is asserted at the scenario when it should deassert", $time);
                 $stop(0);
		 end
		  
   req_align_assert : assert property (check_align_lock_high)
                 else begin
		 error <= 1'b1;
                 $display ("\n Error occured. Align_locked is deasserted during RP168 switching.", $time);
                 $stop(0);
		 end

   // req_align_deassert : assert property (check_align_lock_low)
                 // else begin
		 // error <= 1'b1;
                 // $display ("\n Error occured. Align_locked is asserted at the scenario when it should deassert", $time);
                 // $stop(0);
		 // end	
	
	
	
//---------------------------------------------------------------------------
// Test state machine
//---------------------------------------------------------------------------

   parameter [3:0] WAIT_FOR_FRAMELOCK = 4'b0000;
   parameter [3:0] RCV_LATE_DATA = 4'b0001;
   parameter [3:0] RCV_EARLY_DATA = 4'b0010;
   parameter [3:0] WRONG_LINECOUNT = 4'b0011;
   parameter [3:0] EXCEED_ERR_TOLER = 4'b0100;
   parameter [3:0] WRONG_LINECOUNT_NOLOCK = 4'b0101;
   parameter [3:0] THREEG_STD_SWITCH = 4'b0110;
   parameter [3:0] CHECK_FRAMELOCK = 4'b0111;
   parameter [3:0] ERROR_DETECTED = 4'b1000;
   parameter [3:0] TEST_COMPLETE = 4'b1001;

   reg [3:0] current_state;
   reg [3:0] next_state;
   integer   test_state;

   always @ (posedge clk or posedge rst)
   begin
     if (rst) begin
       current_state <= WAIT_FOR_FRAMELOCK;
       test_state <= 0;
     end
     else begin
       current_state <= next_state;
     end
   end

   always @ (current_state or enable or frame_locked_detected or v or rx_eav or reach_tol_lvl)
   begin
     complete = 1'b0;
     next_state  = current_state;
     inc_err_count = 1'b0;
     //std3g_switched = 1'b0;

     case (current_state)
       WAIT_FOR_FRAMELOCK     : begin
                                  if (enable && (trs_locked || trs_locked_b) ) begin
				    start_align_sequence_high = 1'b1;
                                    $display("Waiting for frame_locked...");
                                    if (test_state == 4) begin
                                    next_state = WRONG_LINECOUNT_NOLOCK;
                                    $display ("This test is to test whether frame_locked remains low when line count is wrong in a frame.");
                                    end
                                    else begin
                                      if (~frame_locked_detected) begin
					start_frame_sequence_low = 1'b0;
                                        @(posedge frame_locked_detected);
                                      end
                                      $display ("Frame_locked detected.");
                                      $display ("Waiting for rx_v to be deasserted... \n");
                                      @(negedge v);
                                      if (test_state == 0) next_state = RCV_LATE_DATA;
                                      if (test_state == 2) next_state = WRONG_LINECOUNT;
                                      if (test_state == 5) next_state = THREEG_STD_SWITCH;
                                    end
                                  end
                                end

       RCV_LATE_DATA          : begin
	                          start_frame_sequence_high = 1'b1;
                                  repeat (2) @(posedge rx_eav);
                                  proceed = 1'b1;
                                  repeat (15) @(posedge clk);
                                  if (frame_locked_detected) begin
                                    proceed = 1'b1;
                                    next_state = CHECK_FRAMELOCK;
                                  end
                                  else 
                                    next_state = ERROR_DETECTED; 
                                end

       RCV_EARLY_DATA         : begin
                                  repeat (2) @(posedge rx_eav);
                                  proceed = 1'b1;
                                  repeat (15) @(posedge clk);
                                  if (frame_locked_detected) begin
                                    proceed = 1'b1;
                                    next_state = CHECK_FRAMELOCK;
                                  end
                                  else 
                                    next_state = ERROR_DETECTED; 
                                end

       WRONG_LINECOUNT        : begin
	                          start_frame_sequence_high = 1'b1;
                                  repeat (2) @(posedge rx_eav);
                                  proceed = 1'b1;
                                  inc_err_count = 1'b1;
                                  repeat (err_tolerance + 1) @(posedge rx_trs);
                                  proceed = 1'b1;
                                  next_state = CHECK_FRAMELOCK;
                                end

       EXCEED_ERR_TOLER       : begin
                                  repeat (2) @(posedge rx_eav);
                                  proceed = 1'b1;
                                  repeat (err_tolerance + 1) @(posedge rx_trs);
                                  proceed = 1'b1;
                                  next_state = CHECK_FRAMELOCK;	
                                  start_align_sequence_high = 1'b0;
				  start_frame_sequence_high = 1'b0;
                                end

       WRONG_LINECOUNT_NOLOCK : begin
                                  if (trs_locked_detected) $display ("Trs_locked is asserted.");
                                  else begin
                                    $display ("Waiting for trs_locked...");
                                    @(posedge trs_locked_detected);
                                  end
                                  repeat (2) @(posedge rx_eav);
                                  proceed = 1'b1;
                                  repeat (err_tolerance + 1) @(posedge rx_trs);
                                  proceed = 1'b1;
                                  next_state = CHECK_FRAMELOCK;
                                end

       THREEG_STD_SWITCH      : begin
                                  //if (test3g_1stprt) begin
                                  $display ("Switching from 3GA to 3GB/ 3GB to 3GA.");
                                  proceed = 1'b1;
                                  //repeat (err_tolerance) @(negedge v);
                                  //next_state = CHECK_FRAMELOCK;
                                  $display ("Frame locked should be deasserted after exceeded error tolerance level.");
                                  @(negedge frame_locked_detected);
				  start_frame_sequence_low = 1'b1;
                                  if(trs_locked_detected) begin
                                    $display("Frame_locked is deasserted. Test passed. \n");
                                  end else begin
                                    $display("\n Error occured. Trs_locked should remained high.");
                                    $stop(0);
                                  end
                                  //end
                                  //else if (test3g_2ndprt) begin
                                  $display ("Waiting for frame locked to be asserted...");
                                  @(negedge v);
                                  next_state = CHECK_FRAMELOCK;
				  start_frame_sequence_low  = 1'b0;
                                  //end
                                end

       CHECK_FRAMELOCK        : begin
                                  $display ("Wait until rx_v is deasserted...");
                                  @(negedge v);
                                  if (frame_locked_detected) begin
                                    if (test_state == 0) begin
                                      proceed = 1'b1;
                                      $display ("Frame_locked remains asserted. Test passed. \n");
                                      next_state = RCV_EARLY_DATA;
                                      test_state = test_state + 1;
                                    end

                                    else if (test_state == 1) begin
                                      proceed = 1'b1;
                                      $display ("Frame_locked remains asserted. Test passed. \n");
                                      next_state = WAIT_FOR_FRAMELOCK;
                                      test_state = test_state + 1;
                                      $display ("Reset rx...");
				      start_frame_sequence_high = 1'b0;
				      start_align_sequence_high = 1'b0;
                                      @(negedge frame_locked_detected);
				      start_frame_sequence_low = 1'b1;
                                    end

                                    else if (test_state == 2) begin
                                      proceed = 1'b1;
                                      $display ("Frame_locked remains asserted. Test passed. \n");
                                      if (reach_tol_lvl) begin
                                        next_state = EXCEED_ERR_TOLER;
                                        test_state = test_state + 1;
                                      end
                                      else next_state = WRONG_LINECOUNT;
                                    end

                                    else if (test_state == 3 || test_state == 4) begin
                                      next_state = ERROR_DETECTED;
                                    end

                                    else if (test_state == 5) begin
				      start_frame_sequence_high = 1'b0;
				      start_frame_sequence_low  = 1'b0;
				      start_align_sequence_high = 1'b0;
				      //start_align_sequence_low  = 1'b0;
                                      //if (test3g_1stprt) next_state = ERROR_DETECTED;
                                      //else if (test3g_2ndprt) begin
                                      $display ("Frame locked is asserted. Test passed.");
                                      next_state = TEST_COMPLETE;
                                      //end
                                    end
                                  end

                                  else begin
                                    if (test_state == 3) begin									 
				      start_frame_sequence_low = 1'b1;
                                      proceed = 1'b1;
                                      $display("Frame_locked is deasserted. Test passed. \n");
                                      next_state = WAIT_FOR_FRAMELOCK;
                                      test_state = test_state + 1;
                                      $display ("Reset rx...");
                                      @(negedge trs_locked);
                                    end

                                    else if (test_state == 4) begin
				      start_align_sequence_high = 1'b0;
                                      proceed = 1'b1;
                                      $display("Frame_locked is not asserted. Test passed. \n");
                                      if (vid_std[1]) begin
                                        next_state = WAIT_FOR_FRAMELOCK;
                                        test_state = test_state + 1;
                                        $display ("Reset rx...");
                                        @(negedge trs_locked);
                                      end
                                      else next_state = TEST_COMPLETE;
					start_frame_sequence_high = 1'b0;
					start_frame_sequence_low  = 1'b0;
					start_align_sequence_high = 1'b0;
					//start_align_sequence_low  = 1'b0;
                                    end

                                    // else if (test_state == 5 && test3g_1stprt) begin
                                    // $display("Frame_locked is deasserted. Test passed. \n");
                                    // std3g_switched = 1'b1;
                                    // next_state = THREEG_STD_SWITCH;
                                    // end

                                    else next_state = ERROR_DETECTED; 
                                  end
                                end

       ERROR_DETECTED         : begin
                                 // error = 1'b1;
                                  if (test_state == 0 || test_state == 1) $display ("\n Error occured. Frame_locked is deasserted during RP168 switching.");
                                  else if (test_state == 2) $display ("\n Error occured. Frame_locked is deasserted before exceeding ERR_TOLERANCE level.");
                                  else if (test_state == 3) $display ("\n Error occured. Frame_locked remains high after exceeding ERR_TOLERANCE level.");
                                  else if (test_state == 4) $display ("\n Error occured. Frame_locked is asserted when line number is not match.");
                                  else if (test_state == 5) $display ("\n Error occured. Frame_locked is not asserted after 2 frames.");
                               //if (test3g_1stprt) $display ("\n Error occured. Frame_locked remains high when video standard switches from 3GA to 3GB or vice versa.");
                               //if (test3g_2ndprt) $display ("\n Error occured. Frame_locked is not asserted after 2 frames.");

                               // Test should be able to proceed to next state when an error occured. Currently not supported as more efforts need to be done to be aligned with test control clock.
                               //next_state = WAIT_FOR_FRAMELOCK;
                                  $stop(0);
                                end

       TEST_COMPLETE          : begin
                                  if (test_state != 5) begin
                                    $display ("Waiting for frame_locked to complete the test...");
                                    @(posedge frame_locked_detected);
                                    $display ("Frame_locked detected.");
                                  end
                                  proceed = 1'b1;
                                  complete = 1'b1;
                                  $display ("Frame locked test completed.");
                                  @(negedge enable);
                                  next_state = WAIT_FOR_FRAMELOCK;
                                  test_state = 0;
                                end

       default : next_state = WAIT_FOR_FRAMELOCK;

     endcase
   end

endmodule
