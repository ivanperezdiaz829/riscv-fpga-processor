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

module tb_trs_locked_test (
    //port list
    enable,
    clk,
    trs_locked,
    align_locked,
    rxdata,
    rx_eav,
    rx_trs,
    proceed,
    complete,
    error
);

    //--------------------------------------------------------------------------
    // parameter declaration
    //--------------------------------------------------------------------------

    parameter  err_tolerance = 4;
    localparam timeout_trscount = 200;
    //--------------------------------------------------------------------------
    // port declaration
    //--------------------------------------------------------------------------

    input         enable;
    input         clk;
    input         trs_locked;
    input         align_locked;
    input         rx_eav;
    input         rx_trs;
    input  [19:0] rxdata;
    output        proceed;
    output        complete;
    output        error;

    //--------------------------------------------------------------------------
    // port type declaration
    //--------------------------------------------------------------------------
    reg      proceed;
    reg      complete;
    reg      error;
    reg      trs_detect;
    reg      start_trs_sequence_high;
    reg      start_trs_sequence_low;
    reg      start_align_sequence_high;
    //reg      start_align_sequence_low;
    integer  timeout_count;

    //---------------------------------------------------------------------------
    // Rx Format detect test
    //---------------------------------------------------------------------------	
    always @ (posedge clk)
    begin
      if (proceed == 1'b1) timeout_count = 0;
      // if (rx_trs && (complete == 1'b0)) timeout_count = timeout_count + 1;
      if (timeout_count == timeout_trscount) begin
        $display ("Trs_locked test timeout!");
        $stop(0);
      end
      proceed <= 1'b0;
      error <= 1'b0;
    end

    always @ (posedge rx_trs)
    begin
      if (~complete) begin
         timeout_count = timeout_count + 1;
      end
    end

    wire rxdata_trs = (rxdata[9:0] == 10'h3ff);
    reg rx_no_trs;

    always @ (rxdata)
    begin
      if (rxdata_trs & ~rx_trs) begin
         rx_no_trs = 1'b1;
      end else begin
         rx_no_trs = 1'b0;
      end
    end
	
    //---------------------------------------------------------------------------
    // Sequence for assertion checking.
    // sequence trs_h : check for trs_locked is equals to high as long as start_trs_sequence_high=1'b1, else flag error.
    // sequence trs_l : check for trs_locked is equals to low as long as start_trs_sequence_low=1'b1, else flag error.
    // sequence align_h : check for align_locked is equals to high as long as start_align_sequence_high=1'b1, else flag error.
    // sequence align_l : check for align_locked is equals to low as long as start_align_sequence_low=1'b1, else flag error.
    //----------------------------------------------------------------------------
    wire flag_trs;
    wire flag_align;

    assign flag_trs = trs_locked ? 1'b1 : 1'b0;	  
    assign flag_align = align_locked ? 1'b1 : 1'b0;	
	
    sequence trs_h;
       @(posedge clk) 
       start_trs_sequence_high;
    endsequence

    sequence trs_l;
       @(posedge clk) 
       start_trs_sequence_low;
    endsequence

    sequence align_h;
       @(posedge clk) 
       start_align_sequence_high;
    endsequence

    // sequence align_l;
       // @(posedge clk) 
       // start_align_sequence_low;
    // endsequence

    property check_trs_lock_high; 
       @(posedge clk)
       trs_h |=> flag_trs==1;
    endproperty

    property check_trs_lock_low; 
       @(posedge clk)
       trs_l |=>  flag_trs==0;
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
   req_trs_assert : assert property (check_trs_lock_high)
                 else begin
	         error <= 1'b1;
                 $display ("\n Error occured. Trs_locked is deasserted during RP168 switching.", $time);
                 $stop(0);
		 end

   req_trs_deassert : assert property (check_trs_lock_low)
                 else begin
		 error <= 1'b1;
                 $display ("\n Error occured. Trs_locked is asserted at the scenario when it should deassert", $time);
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
		  
		  
    always @ (posedge enable)
    begin
      complete <= 1'b0;	  
      start_trs_sequence_high <= 1'b1;
      start_align_sequence_high <= 1'b1;
      //--------------------------------------------------
      // State 1: RP168 Switching - dead data within a single line
      //--------------------------------------------------
      repeat (2) begin
        @(posedge rx_eav);
        proceed <= 1'b1;
        repeat (15) @(posedge clk);
        proceed <= 1'b1;       
        repeat (3) begin
           @(posedge rx_trs);
           @(posedge rx_eav);
        end
          $display("Trs_locked remains asserted. Test passed.");
          proceed <= 1'b1;
      end
       
      //--------------------------------------------------
      // State 2: RP168 Switching  - dead time = 3us
      //--------------------------------------------------
      repeat (2) begin
        @(posedge rx_eav);
        proceed <= 1'b1;
        repeat (446) @(posedge clk); // 3us for 3G clock rate and 6us for HD clock rate
        proceed <= 1'b1;
	repeat (3) begin
           @(posedge rx_trs);
           @(posedge rx_eav);
        end
          $display("Trs_locked remains asserted. Test passed.");
          proceed <= 1'b1;
      end
      
      //--------------------------------------------------
      // State 3: Testing on Error Tolerance Level 
      //--------------------------------------------------
      repeat (2) begin
        repeat (err_tolerance) @(posedge rx_no_trs);
        proceed <= 1'b1;
        repeat (2) @(posedge rx_trs);
           proceed <= 1'b1;
           $display("Trs_locked remains asserted. Test passed."); 
      end

      //--------------------------------------------------
      // State 3: Exceed Error Tolerance
      //--------------------------------------------------
      repeat (2*err_tolerance + 1) @(posedge rx_no_trs);
	  //repeat (6) @(posedge clk);
	    start_trs_sequence_high <= 1'b0;
	  @(negedge trs_locked);
	    //start_trs_sequence_low <= 1'b1;
	    start_align_sequence_high <= 1'b0;
	  @(negedge align_locked);
	    //start_align_sequence_low <= 1'b1;
      repeat (6) @(posedge rxdata);
        $display("Trs_locked is deasserted. Test passed.");
      proceed <= 1'b1;
	    //start_align_sequence_low <= 1'b0;
	  @(posedge align_locked)
	    start_align_sequence_high <= 1'b1;
	  repeat (6) @(posedge rx_eav); 
	    start_trs_sequence_low <= 1'b0;
      @(posedge trs_locked);
	    start_trs_sequence_high <= 1'b1;
      repeat (4) @(posedge rx_trs);
      proceed <= 1'b1;

      repeat (err_tolerance + 1) @(posedge rx_no_trs);
	  //repeat (6) @(posedge clk);
	    start_trs_sequence_high <= 1'b0;
	  @(negedge trs_locked);
	    start_trs_sequence_low <= 1'b1;
	    start_align_sequence_high <= 1'b0;
	  @(negedge align_locked)
	    //start_align_sequence_low <= 1'b1;
      repeat (6) @(posedge rxdata);
        $display("Trs_locked is deasserted. Test passed.");
      proceed <= 1'b1;
        //start_align_sequence_low<=1'b0;
	    @(posedge align_locked)
	    start_align_sequence_high<=1'b1;
      //------------------------------------------------------------------------------
      // State 4: Received missing EAV/SAV or delayed data when trs_locked is low
      //------------------------------------------------------------------------------
      //Missing EAV
      repeat (2) begin
        repeat (5) @(posedge rx_eav);
        proceed <= 1'b1;
        repeat (2) @(posedge rx_trs);
        proceed <= 1'b1;
      end
      //Missing SAV
      @(posedge rx_trs);
      repeat (2) begin
        repeat (10) @(posedge rx_trs);
        proceed <= 1'b1;
        repeat (2) @(posedge rx_trs);
        proceed <= 1'b1;
      end
      //Late or Early data
      repeat (2) begin
        repeat (10) @(posedge rx_trs);
        proceed <= 1'b1;
        @(posedge rx_trs);
      end
      $display("Trs_locked remains deasserted. Test passed.");
      //Data recovered
      proceed <= 1'b1;
	  repeat (6) @(posedge rx_eav);
	    start_trs_sequence_low<=1'b0;
      @(posedge trs_locked);
	    start_trs_sequence_high<=1'b1;
      proceed <= 1'b1;
        $display ("Trs_locked test done!");
      complete <= 1'b1;
	  start_trs_sequence_low <= 1'b0;
	  start_trs_sequence_high <= 1'b0;
	  //start_align_sequence_low <= 1'b0;
	  start_align_sequence_high <= 1'b0;
    end

endmodule
