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


module sdi_ii_tb_tx_checker
# (
    // module parameter port list
    parameter
        FAMILY                  = "Stratix V"           ,
        VIDEO_STANDARD          = "Triple_Standard"     ,
        RX_EN_A2B_CONV          = 0                     ,
        RX_EN_B2A_CONV          = 0                     ,
        RX_INC_ERR_TOLERANCE    = 0                     ,
        XCVR_TX_PLL_SEL         = 0
)
(
    // port list
    ref_clk,
    sdi_serial,
    sdi_serial_b,
    tx_status,
    chk_tx,  //Signal from test control to check checker status
    tx_std,
    tx_clkout,
    tx_clkout_match
);

    //--------------------------------------------------------------------------
    // local parameter declarations
    //--------------------------------------------------------------------------
    //localparam CLK148_PERIOD         = 67340;
    //localparam CLK75_PERIOD          = 134680;
    //localparam CLK27_PERIOD          = 370370;
    localparam TIMEOUT_COUNT         = (RX_EN_A2B_CONV == 1'b1 | RX_EN_B2A_CONV == 1'b1) ? 350000 : 88000; //Number of samples received to timeout the test
    localparam mode_sd = (VIDEO_STANDARD == "sd");
    localparam mode_hd = (VIDEO_STANDARD == "hd") | (VIDEO_STANDARD == "dl");
    localparam mode_dl = (VIDEO_STANDARD == "dl");
    localparam mode_3g = (VIDEO_STANDARD == "threeg");
    localparam mode_ds = (VIDEO_STANDARD == "ds");   
    localparam mode_tr = (VIDEO_STANDARD == "tr");
    localparam err_tolerance = RX_INC_ERR_TOLERANCE ? 15 : 4;

    //--------------------------------------------------------------------------
    // port declaration
    //--------------------------------------------------------------------------

    input    ref_clk;
    input    tx_clkout;
    input    sdi_serial;
    input    sdi_serial_b;
    input    tx_status;
    output   tx_clkout_match;
    input [1:0]    chk_tx;
    input [1:0]    tx_std;

    //--------------------------------------------------------------------------
    // port type declaration
    //--------------------------------------------------------------------------

    wire    ref_clk;
    wire    tx_clkout;
    wire    sdi_serial;
    wire    tx_status;


    //--------------------------------------------------------------------------
    //
    // module definition
    //
    //--------------------------------------------------------------------------
    wire    descrambled;
    wire    tx_sclk;
    wire    trs_spotted;
    reg     reset;
    wire    late_flag;
    wire    early_flag;
    wire    miss_trs;
    wire    first_trs;
    wire    error_no_trs;
    wire    error_no_trs2;
    wire    error_tx_notlocked;
    wire    tx_locked;
    wire    tx_lockedflag;
    wire    descrambled_b;
    wire    tx_sclk_b;
    wire    trs_spotted_b;
    wire    late_flag_b;
    wire    early_flag_b;
    wire    miss_trs_b;
    wire    first_trs_b;
    wire    error_no_trs_b;
    wire    error_no_trs2_b;
    wire    error_tx_notlocked_b;
    wire    tx_locked_b;
    wire    tx_lockedflag_b;


    tb_tx_clkout_check u_clkout
    (
       .tx_clkout         (tx_clkout),
       .tx_status         (tx_status),
       .tx_clkout_match   (tx_clkout_match)
    );
	defparam u_clkout.VIDEO_STANDARD = VIDEO_STANDARD;


    tb_serial_descrambler u_descr
    (
      .ref_clk          (ref_clk),
      .sdi_serial       (sdi_serial),
      .tx_std           (tx_std),
      .tx_status        (tx_status),
      .tx_sclk          (tx_sclk),
      .descrambled      (descrambled),
      .trs_spotted      (trs_spotted)
    );
	
    tb_serial_check_counter u_count
    (
      .enable                (~chk_tx[0]),
      .tx_sclk               (tx_sclk),
      .descrambled           (descrambled),
      .trs_spotted           (trs_spotted),
      .rst                   (reset),
      .late_flag             (late_flag),
      .early_flag            (early_flag),
      .miss_trs              (miss_trs),
      .first_trs             (first_trs),
      .error_no_trs          (error_no_trs),
      .error_no_trs2         (error_no_trs2),
      .error_tx_notlocked    (error_tx_notlocked),
      .tx_locked             (tx_locked),
      .tx_lockedflag         (tx_lockedflag)
    );
    defparam u_count.err_tolerance = err_tolerance;
    defparam u_count.timeout_count = TIMEOUT_COUNT;

    generate
    if (mode_dl) begin : link_b
    tb_serial_descrambler u_descr_b
    (
      .ref_clk          (ref_clk),
      .sdi_serial       (sdi_serial_b),
      .tx_std           (tx_std),
      .tx_status        (tx_status),
      .tx_sclk          (tx_sclk_b),
      .descrambled      (descrambled_b),
      .trs_spotted      (trs_spotted_b)
    );
	
    tb_serial_check_counter u_count_b
    (
      .enable                (~chk_tx[0]),
      .tx_sclk               (tx_sclk_b),
      .descrambled           (descrambled_b),
      .trs_spotted           (trs_spotted_b),
      .rst                   (reset),
      .late_flag             (late_flag_b),
      .early_flag            (early_flag_b),
      .miss_trs              (miss_trs_b),
      .first_trs             (first_trs_b),
      .error_no_trs          (error_no_trs_b),
      .error_no_trs2         (error_no_trs2_b),
      .error_tx_notlocked    (error_tx_notlocked_b),
      .tx_locked             (tx_locked_b),
      .tx_lockedflag         (tx_lockedflag_b)
    );
    defparam u_count_b.err_tolerance = err_tolerance;
    defparam u_count_b.timeout_count = TIMEOUT_COUNT;

    end
    endgenerate

    //--------------------------------------------------------------------------------------------------
    // Display messages from serial_check_counter
    //--------------------------------------------------------------------------------------------------

    always @ (tx_sclk or tx_sclk_b)
    begin
      if (tx_sclk) begin
        reset = 1'b0;
        if (error_no_trs) begin
          `tdisplay("-- FAILED in transmit test: TRS never seen in output data");
          $stop(0);
        end
        if (error_no_trs2) begin
          $display("-- FAILED in transmit test: No TRS observed after waiting for %d words", TIMEOUT_COUNT/20);
          $stop(0);
        end
        if (first_trs) begin
          `tdisplay("-- Testbench : TRS spotted in transmitted data");
        end
        if (error_tx_notlocked) begin
          $display("-- FAILED in transmit test: Serial checker is not locked. Spacing between TRS is incorrect.");
          $stop(0);
        end
      end

      if (tx_sclk_b) begin
        reset = 1'b0;
        if (error_no_trs_b) begin
          `tdisplay("-- FAILED in transmit test: TRS never seen in output data (link B).");
          $stop(0);
        end
        if (error_no_trs2_b) begin
          $display("-- FAILED in transmit test: No TRS observed after waiting for %d words (link B).", TIMEOUT_COUNT/20);
          $stop(0);
        end
        if (first_trs_b) begin
          `tdisplay("-- Testbench : TRS spotted in transmitted data (link B).");
        end
        if (error_tx_notlocked_b) begin
          $display("-- FAILED in transmit test: Serial checker is not locked. Spacing between TRS is incorrect (link B).");
          $stop(0);
        end
      end
    end

    //--------------------------------------------------------------------------------
    // Detect negative edge of tx_locked  
    // Capture the error if it is not during reconfig state 
    //--------------------------------------------------------------------------------
    reg early_trs = 1'b0;        //Asserted when early_flag is true during falling edge of tx_locked, used for displaying error msg when chk_tx = 1
    reg late_trs = 1'b0;         //Asserted when late_flag is true during falling edge of tx_locked, used for displaying error msg when chk_tx = 1
    reg early_trs_b = 1'b0;
    reg late_trs_b = 1'b0;

    always @ (tx_locked or tx_locked_b)
    begin
      early_trs = 1'b0; 
      late_trs = 1'b0;       
      early_trs_b = 1'b0;
      late_trs_b = 1'b0;

      if (~tx_locked)
        if (~chk_tx[0])
          if (late_flag) late_trs = 1'b1;
          else if (early_flag) early_trs = 1'b1;

      if (~tx_locked_b)
        if (~chk_tx[0])
          if (late_flag_b) late_trs_b = 1'b1;
          else if (early_flag_b) early_trs_b = 1'b1;
    end
    //--------------------------------------------------------------------------
    // Print checker status
    //--------------------------------------------------------------------------
    reg [6:0] result_reg = 7'b1111111;
    reg     result_regb = 1'b1;
    reg [3:0] index = 4'b0000;
    integer outfile;
    integer j;
    integer error_counter;

    always @(chk_tx)
    begin
      if (~chk_tx[0]) reset = 1'b1;

      if (chk_tx[0]) begin                

        if (tx_locked && (~(early_trs || late_trs || miss_trs))) begin
          $display("\n ##### Test %d TRANSMIT OK \n",index);
          result_reg[index] = 1'b0;
        end

        else if (tx_locked) begin
          if (early_trs)
            $display ("FAILED in test %d: Transmitter is locked currently. It is unlocked before due to early TRS detected.", index);
          if (late_trs) 
            $display ("FAILED in test %d: Transmitter is locked currently. It is unlocked before due to late TRS detected.", index);
          if (miss_trs) 
            $display ("FAILED in test %d: Transmitter is locked currently. It is unlocked before due to missing EAV/SAV.",index);
        end

        else if (~tx_locked) begin
          if (~tx_lockedflag)
            $display("FAILED in test %d: Serial checker is not locked.", index);

          else begin
            if (early_trs)
              $display ("FAILED in test %d: Transmitter is not locked currently. It is unlocked due to early TRS detected.", index);
            if (late_trs)
              $display ("FAILED in test %d: Transmitter is not locked currently. It is unlocked due to late TRS detected.", index);
            if (miss_trs)
              $display ("FAILED in test %d: Transmitter is not locked currently. It is unlocked due to missing EAV/SAV.", index);
          end
        end	    

        if (tx_locked_b && (~(early_trs_b || late_trs_b || miss_trs_b))) begin
          $display(" ##### Test %d TRANSMIT (LINK B) OK \n",index);
          result_regb = 1'b0;
        end

        else if (tx_locked_b) begin
          if (early_trs_b) 
            $display ("FAILED in test %d: Transmitter is locked currently. It is unlocked before due to early TRS detected (link B).", index);
          if (late_trs_b)
            $display ("FAILED in test %d: Transmitter is locked currently. It is unlocked before due to late TRS detected (link B).", index);
          if (miss_trs_b)
            $display ("FAILED in test %d: Transmitter is locked currently. It is unlocked before due to missing EAV/SAV (link B).",index);
        end

        else if (~tx_locked_b) begin
          if (~tx_lockedflag_b)
            $display("FAILED in test %d: Serial checker is not locked (link B).", index);

          else begin
            if (early_trs_b)
              $display ("FAILED in test %d: Transmitter is not locked currently. It is unlocked due to early TRS detected (link B).", index);
            if (late_trs_b)
              $display ("FAILED in test %d: Transmitter is not locked currently. It is unlocked due to late TRS detected (link B).", index);
            if (miss_trs_b)
              $display ("FAILED in test %d: Transmitter is not locked currently. It is unlocked due to missing EAV/SAV (link B).", index);
          end
        end
        index = index + 1;

      end

      //Print overall result when all tests are done
      if (chk_tx[1]) begin
        error_counter = result_reg [0];

        for (j = 1; j < index; j = j + 1)
          error_counter = error_counter + result_reg [j];
        if (mode_dl)
          error_counter = error_counter + result_regb;

        if (error_counter == 0)
          $display (" ##### TRANSMIT TEST COMPLETED SUCCESSFULLY! #####\n");
        else 
          $display (" ##### FAILED: TRANSMIT TEST COMPLETED WITH ERROR(S) #####\n");

      end
    end
    //--------------------------------------------------------------------------
    //--------------------------------------------------------------------------    
    initial begin  
      #(10000);
      outfile = $fopen ("output.log","w");
      $fdisplay (outfile, "3G sim\n");
    end

    reg tx_status_reg = 1'b0;
    always @ (posedge tx_status)
    begin
       tx_status_reg <= tx_status;
    end

    initial begin
      #(1200000000);
      if (~tx_status_reg) begin 
        `tdisplay("-- FAILED : Transceiver Tx PLL not locked"); 
        $stop(0);
      end
    end
    //--------------------------------------------------------------------------
    // [END] comment
    //--------------------------------------------------------------------------




endmodule
