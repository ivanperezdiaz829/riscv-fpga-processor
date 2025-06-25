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


package hutil_pkg;
`define DATE "June_2012"
`ifdef TBID
`else
  `define TBID "rapidio2_testbench"
`endif

`ifdef AUTHOR
`else
  `define AUTHOR "ALTERA"
`endif

//initial begin
//  $display("%s", "$Id: tb_hutil.sv,v 1.5 2012/06/15 12:39:07 santosm Exp $");
//end

`define INFO     32'h00000001
`define DEBUG    32'h00000002
`define WARNING  32'h00000004
`define FAILURE  32'h00000008

static integer err_cnt;
static integer exp_err_cnt;
static integer chk_cnt;
static integer exp_chk_cnt;
static integer err_limit;
static integer info_cnt;

function init(int no_of_checks=0);
  err_limit = 10;
  exp_err_cnt = 0;
  exp_chk_cnt = no_of_checks; 
  err_cnt = 0;
  chk_cnt = 0;
  info_cnt = 0;
  init = 1;
endfunction 


reg error_mark; // useful on waveform viewers for showing errors
reg verbose;
reg [256:1] tbid = `TBID;

//initial begin
//  error_mark = 0;
////  verbose = `VERBOSE;
//  tbid = `TBID;
//end

// For delayed error detection.
  reg delaying_errors;
  integer delayed_errors;
  //initial begin
  //  delaying_errors = 0;
  //  delayed_errors = 0;
  //end

  task delay_errors;
    input on_off;
    begin
      delaying_errors = on_off;
    end
  endtask
  
  task clear_delayed_errors;
    begin
      delayed_errors = 0;
    end
  endtask
  
  task add_delayed_errors;
    begin
      if( delayed_errors != 0 )begin
        err_cnt = err_cnt + delayed_errors;
        delayed_errors = 0;
        $display("%0t - TOTAL ERRORS %0d", $stime, err_cnt);
        if (err_cnt > err_limit) begin 
          $display("EXITING: err_cnt greater than err_limit - ",$stime);
          exit;
        end
      end
    end
  endtask
  
// *************************************************
// *************************************************
// *************************************************

task verify;
input [800:1] check_msg;
begin 
  $display("%0t - VERIFY %0d of %0d: %0s", $stime,chk_cnt,exp_chk_cnt,check_msg); 
end 
endtask 

task info;
  input [800:1] info_msg;
  begin
    info_cnt = info_cnt + 1;
    $display("%0t - %m INFO #%0d: %0s", $stime,info_cnt,info_msg);
  end
endtask

task donecheck; 
input string check_msg; 
begin 
  chk_cnt = chk_cnt + 1; 
  $display("%0t - %m DONECHECK #%0d: %0s", $stime,chk_cnt,check_msg);
end
endtask

task error;
  input [800:1] error_msg;
    begin
      if( delaying_errors )begin
        delayed_errors = delayed_errors + 1;
        $display("%0t - %m DELAYED ERROR #%0d: %0s", $stime, delayed_errors ,error_msg);
      end else begin
        err_cnt = err_cnt + 1;
        $display("%0t - %m ERROR #%0d: %0s", $stime,err_cnt,error_msg);
      end
    error_mark <= ~error_mark;
    if (err_cnt > err_limit) begin 
      $display("%m EXITING: err_cnt greater than err_limit - ",$stime);
      exit;
    end
  end
endtask

// *************************************************
// *************************************************
// *************************************************

task exit;
begin
  $display("***************************************************************");
  $write("$$$ End of testbench %s at : ",`TBID);
  $display($stime);
`ifdef WC_SDF
    $display("$$$ WORST_CASE gate simulation");
`endif
`ifdef NC_SDF
    $display("$$$ NOMINAL_CASE gate simulation");
`endif
`ifdef BC_SDF
    $display("$$$ BEST_CASE gate simulation");
`endif
`ifdef GATE
    $display("$$$ GATE simulation");
`endif
`ifdef RTL
    $display("$$$ RTL simulation");
`endif
      $display("%m chk_cnt = %d, exp_chk_cnt = %d", chk_cnt, exp_chk_cnt);
      $display("%m err_cnt = %d, exp_err_cnt = %d", err_cnt, exp_err_cnt);
      $display("%m $$$ AUTHOR: %s", `AUTHOR);
      $display("%m $$$ DATE: %s",`DATE);
      $write("%m $$$ Exit status for testbench %s : ", `TBID);
      if (err_cnt != exp_err_cnt) begin 
        $write(" TESTBENCH_FAILED "); 
      end else if (exp_chk_cnt == 0 ) begin 
        $write(" TESTBENCH_INCOMPLETE"); 
      end else if (chk_cnt != exp_chk_cnt) begin 
        $write(" TESTBENCH_INCOMPLETE "); 
      end else begin 
        $write(" TESTBENCH_PASSED ");
      end 
      $write("\n");
      $display("***************************************************************");
  #1000; // add trailer to help waveform viewer
`ifdef BATCH
  $finish(2);
`else
  // running interactive. halt so Veriwell wavefore window stays open
  //$stop;
  $finish;
`endif
end
endtask

// *************************************************
// *************************************************
// *************************************************

reg expect_fault;

task expect_n;
  input [800:1] signal_name;
  input [31:0] expected_value;
  input [31:0] actual_value;
  input [4:0] width;

  reg [31:0] masked_expect;
  begin
    masked_expect = expected_value ^ (64'hx << width);
    check(signal_name, masked_expect, actual_value);
  end
endtask

`ifdef EXPECT_WIDTH
parameter expect_width = `EXPECT_WIDTH;
`else
parameter expect_width = 32;
`endif

task check;
// Takes a signal name (string), a 32 bit expected value, 
// a 32 bit unsigned maximum value which can have Xs in some bits
// to inhibit comparison of those bits.
// Calls error if the actual is not equal to the expected bits
// Xs in the expected value suppress comparison in those positions
// Xs in the actual cause an error unless the actual has Xs in the same positions

  input [800:1] signal_name;
  input [expect_width-1:0] expected_value;
  input [expect_width-1:0] actual_value;
parameter nbytes = expect_width/8;
  reg [expect_width-1:0] mask;

  begin
    mask = expected_value ^ expected_value;
    if ((actual_value ^ mask) !== expected_value) begin
      error("signal did not have expected value");
      $display("%m signal %0s\nexpected %b\ngot      %b",
      signal_name, expected_value, actual_value);
      $write("         ");
      repeat(nbytes) $write("|      |");
      $write("\n");
      $display("%m hexadecimal:\nexpected %x\ngot      %x",
      expected_value, actual_value);
      expect_fault = 1;
    end else begin
      expect_fault = 0;
    end
  end
endtask

task expect_1;
  input [800:1] signal_name;
  input expected_value;
  input actual_value;

  begin
    if (actual_value !== expected_value) begin
      error("signal did not have expected value");
      $display("%m signal %0s expected %b got %b",
      signal_name, expected_value, actual_value);
      expect_fault = 1;
    end else begin
      expect_fault = 0;
    end
  end

endtask

// ****************************************************************************
// 12/5/2009 [HLONG]: 
// 1. Expected value is from the transmitting queue.
// 2. Actual value is the receiving queue.
// 3. [4/9/2009] By just shifting the expected value to right is not always
// correct. Sometimes, IO transaction would overtake drbell.
// ****************************************************************************
task write_order_check;
  input [800:1] signal_name;
  input[39:0] expected_value;
  input[39:0] actual_value;
  reg  [4:0]  shift_count;
  reg  [5:0]  i; 
  
  begin
    shift_count = 5'd0;
    if (actual_value !== expected_value) begin
      for (i = 6'd0; i < 6'd40; i = i +1'b1) begin
        if (expected_value [i] != actual_value [i]) begin
          if ((expected_value[i] == 1'b1) && (expected_value[i+1] == 1'b0)) begin
            expected_value[i] = 1'b0;
            expected_value[i+1] = 1'b1;
          end else if ((expected_value[i] == 1'b1) && (expected_value[i+1] == 1'b1)) begin
            expected_value = expected_value << 1;
          end
        end
      end
    end
  
    if (i === 6'd40) begin
      if (actual_value !== expected_value) begin
        error("signal did not have expected value");
        $display("%m signal %0s expected %b got %b",
        signal_name, expected_value, actual_value);
        expect_fault = 1;
      end else begin
        expect_fault = 0;
      end
    end
  end

endtask
endpackage

// *************************************************
// *************************************************
// *************************************************


//always begin 
//  $timeformat(-9, 0, " ns", 0);
//  #1000;
//  if (verbose) begin
//    $display("Testbench %0s elapsed time %t", `TBID, $stime);
//  end
//end 


// ************************************************
// ************************************************
// ************************************************







