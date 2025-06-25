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
`define tdisplay(MYSTRING) $display("%t:%s \n", $time,  MYSTRING)

module tb_serial_check_counter
(
    // port list
    enable,
    tx_sclk,
    descrambled,
    trs_spotted,
    rst,

    late_flag,
    early_flag,
    miss_trs,
    first_trs,
    error_no_trs,
    error_no_trs2,
    error_tx_notlocked,
    tx_locked,
    tx_lockedflag
);

    //--------------------------------------------------------------------------
    // port declaration
    //--------------------------------------------------------------------------
    input   enable;
    input   tx_sclk;
    input   descrambled;
    input   trs_spotted;
    input   rst;
    output  late_flag;
    output  early_flag;
    output  miss_trs;
    output  first_trs;
    output  error_no_trs;
    output  error_no_trs2;
    output  error_tx_notlocked;
    output  tx_locked;
    output  tx_lockedflag;
	
    parameter err_tolerance   = 1;
    parameter timeout_count   = 88000; //Number of samples received to timeout the test
    //--------------------------------------------------------------------------
    // local parameter declarations
    //--------------------------------------------------------------------------
    localparam CLK148_PERIOD  = 67340;
    localparam CLK75_PERIOD   = 134680;
    localparam CLK27_PERIOD   = 370370;

    //--------------------------------------------------------------------------------------------------
    // Reconstruct parallel tx data
    //--------------------------------------------------------------------------------------------------
    reg aligned = 1'b0;
    reg [19:0] t_txword;
    reg [19:0] txword;
    reg tx_locked = 1'b0; 
    reg tx_lockedflag = 1'b0;    //Asserted when tx_locked is '1', reset only when check_checker signal = 1  
    reg late_flag;               //Asserted when current count larger than expected count
    reg early_flag;              //Asserted when current count smaller than expected count
    reg miss_trs = 1'b0;         //Asserted when current TRS (EAV or SAV) is same as previous TRS 
    reg last_trs;                //Store the value of bit 6 (H) from last XYZ, H = 1 in EAV, 0 in SAV
    reg error_no_trs, error_no_trs2;
    reg first_trs;
    reg error_tx_notlocked;
    //event word_tick;
    integer bitn;
    integer trs_count = 0;       //Count the number of trs received
    integer sample_count = 0;    //Count the number of sample received after each trs
    integer current_count1 = 0;  //This value is obtained from sample_count 
    integer previous_count1 = 0; //Obtained from current_count
    integer expect_count1 = 0;   //Obtained from current_count when current_count is equal to previous_count
    integer current_count2 = 0;
    integer previous_count2 = 0;
    integer expect_count2 = 0;
    integer check_counter = 0;   //This counter is incremented when current count is equal to expected count
    integer error_count = err_tolerance; //counter to store number of errors

    always @ (posedge tx_sclk or posedge rst)
    begin
       if (rst) begin
          txword = 20'd0;
	      t_txword = 20'd0;
		  bitn = 0;
	   end else begin
	        // Make parallel word once bit alignment known
        if (aligned) begin
          t_txword[bitn] = descrambled;
          if (bitn==19) begin
            bitn = 0;
            txword = t_txword;
            //-> word_tick;
          end
          else begin
            bitn = bitn + 1;
          end
        end
	end
   end

    always @ (posedge tx_sclk or posedge rst)
    begin
      if (rst) begin
        previous_count1 = 0;
        previous_count2 = 0;
        expect_count1 = 0;
        expect_count2 = 0;
        tx_locked = 1'b0;
        check_counter = 0;
        aligned = 1'b0;
        miss_trs = 1'b0;
        trs_count = 1'b0;
        tx_lockedflag = 1'b0;
        error_count = 0;
      end
      else if (enable) begin
        sample_count = sample_count + 1;
        first_trs = 1'b0;

        // Take bit 6 of XYZ to determine whether current TRS is SAV or EAV
        if (sample_count == 7) begin
          if (descrambled == last_trs) begin
            if (error_count < err_tolerance) error_count = error_count + 1;
            else begin
              miss_trs = 1'b1;
              tx_locked = 1'b0;
              check_counter = 0;
              error_count = 0;
            end
          end
          else
            if (trs_count != 0) last_trs = descrambled;
        end

        if (sample_count == timeout_count) begin
          if (~aligned) begin
            error_no_trs = 1'b1;
          end
          else begin
            error_no_trs2 = 1'b1;
          end
        end

        if (trs_spotted) begin
          if (~aligned) begin
            first_trs = 1'b1;
            aligned = 1'b1;
            bitn = 0;
            trs_count = trs_count + 1;
            error_count = 0;
          end
          else begin
            trs_count = trs_count + 1;

            if (trs_count%2 == 0) begin
              current_count1 = sample_count;

              //Compare current spacing with reference
              if (current_count1 == expect_count1) 
                check_counter = check_counter + 1;
              else if (current_count1 == previous_count1) begin
                expect_count1 = current_count1;
                check_counter = check_counter + 1;
              end
              //Compare current spacing with previous spacing. Keep the count as reference if they are the same
              else begin
                if (error_count < err_tolerance) error_count = error_count + 1;
                else begin
                  tx_locked = 1'b0;
                  check_counter = 0;
                  error_count = 0;
                  if (current_count1 > expect_count1) late_flag = 1'b1;
                  if (current_count1 < expect_count1) early_flag = 1'b1;
                end
              end

              previous_count1 = current_count1;
            end

            else begin
              current_count2 = sample_count;

              if (current_count2 == expect_count2) 
                check_counter = check_counter + 1;
              else if (current_count2 == previous_count2) begin
                expect_count2 = current_count2;
                check_counter = check_counter + 1;
              end

              else begin
                if (error_count < err_tolerance) error_count = error_count + 1;
                else begin
                  tx_locked = 1'b0;
                  check_counter = 0;
                  error_count = 0;
                  if (current_count2 > expect_count2) late_flag = 1'b1;
                  if (current_count2 < expect_count2) early_flag = 1'b1;
                end
              end

              previous_count2 = current_count2;
            end
          //Lock checker when 3 lines with consistent spacing are detected
            if (check_counter == 4) begin
              tx_locked = 1'b1;
              tx_lockedflag = 1'b1;
              error_count = 0;
              early_flag = 1'b0;
              late_flag = 1'b0;
            end
          end
          sample_count = 0;
        end

        if (trs_count == 16) begin
          if (tx_lockedflag == 1'b0) begin
            error_tx_notlocked = 1'b1;
          end
        end
      end
    end

    //--------------------------------------------------------------------------
    // [END] comment
    //--------------------------------------------------------------------------
endmodule
