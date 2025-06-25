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


// (C) 2001-2012 Altera Corporation. All rights reserved.
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


//****************************************************************************
// Control & status registers for the KR PHY IP FEC-module
// the address range is 0XB0 - 0XBF 
// only 0XB2 - 0XB4 is implemented now
//****************************************************************************
`timescale 1 ps / 1 ps

module alt_e40_csr_krfec   
  #(
  parameter REG_OFFS = 0
  ) (
  // user data (avalon-MM formatted) 
  input  wire        clk,
  input  wire        reset,
  input  wire [7:0]  address,
  input  wire        read,
  output reg  [31:0] readdata,
  input  wire        write,
  input  wire [31:0] writedata,
				// FEC status sync
  output reg  [9:0]  write_en,
  input  wire [9:0]  write_en_ack,
  // FEC input/outputs
  output wire        fec_tx_trans_err,
  output wire        fec_tx_burst_err,
  output wire [3:0]  fec_tx_burst_err_len,
  output wire        fec_tx_enc_query,
  output wire        fec_rx_signok_en,
  output wire        fec_rx_fast_search_en,
  output wire        fec_rx_blksync_cor_en,
  output wire        fec_rx_dv_start,
  output wire        fec_err_ins,
  input  wire [31:0] fec_corr_blks,
  input  wire [31:0] fec_uncr_blks,
  // read/write control outputs
  output reg        clr_corr_blks,
  output reg        clr_uncr_blks
);

  import alt_e40_csr_krtop_h::*;


  reg  [3:0] clr_crr_sc_bit;     // generate self_clear signal for corrected
  reg  [3:0] clr_unc_sc_bit;     // genertae self_clear signal for uncorrected
  reg [11:0] reg_add_b2;
  
  reg [31:0] fec_corr_blks_int;
  reg [31:0] fec_uncr_blks_int;
  reg [9:0] write_en_ack1,write_en_ack2;

  always @(posedge clk or posedge reset) begin
    if (reset == 1'b1) begin
      reg_add_b2      <= 'd0;
      reg_add_b2[7] <= 1'b1; // signok default 1
      reg_add_b2[8] <= 1'b1; // fast search default 1
      reg_add_b2[10] <= 1'b1; // dv_start default with_blklock
      readdata    <= 32'd0;
      clr_crr_sc_bit  <= 'd0;
      clr_unc_sc_bit  <= 'd0;
    end // if reset
    else begin
      readdata    <= 32'd0;	 
      clr_crr_sc_bit  <= {1'b0, clr_crr_sc_bit[3:1]};
      clr_unc_sc_bit  <= {1'b0, clr_unc_sc_bit[3:1]};
      // decode read & write for each supported address
      case (address)
      (ADDR_KRFEC_STATUS + REG_OFFS): begin //0xB2
        readdata[11:0] <= reg_add_b2;
        if (write) begin
          reg_add_b2      <= writedata[11:0];
        end  // if write
      end  // base
      (ADDR_KRFEC_CRRBLKS + REG_OFFS): begin
        readdata <= fec_corr_blks_int;
	  if (read)  begin 
          clr_crr_sc_bit[3:2] <= 2'b11;
        end // read
      end  // crrblks
      (ADDR_KRFEC_UNCBLKS + REG_OFFS): begin
        readdata <= fec_uncr_blks_int;
          if (read) begin 
           clr_unc_sc_bit[3:2] <= 2'b11;
          end  //read
      end  // uncblks
      endcase
      
      if(reg_add_b2[11]) reg_add_b2[11] <= 1'b0; // clear after write
      
    end // else
  end // always
  
  // cdc for status fields
  always @(posedge clk or posedge reset) begin
    if (reset == 1'b1) begin
      fec_corr_blks_int <= 'd0;
      fec_uncr_blks_int <= 'd0;
	  write_en <= 10'b0;
	  write_en_ack1 <= 10'b0;
	  write_en_ack2 <= 10'b0;
    end // if reset
    else begin
	  write_en_ack1 <= write_en_ack;
	  write_en_ack2 <= write_en_ack1;
	  
	  if(write_en == 10'b0 && write_en_ack2 == 10'b0) begin
        write_en <= {10{1'b1}};
		fec_corr_blks_int <= fec_corr_blks;
		fec_uncr_blks_int <= fec_uncr_blks;
	  end else if(&write_en_ack2) begin
	    write_en <= 'd0;
	  end
	  
    end // else
  end // always
 
 /// drive outputs
  assign fec_tx_trans_err       = reg_add_b2[0]  ; 
  assign fec_tx_burst_err       = reg_add_b2[1]  ;
  assign fec_tx_burst_err_len   = reg_add_b2[5:2] ;
  assign fec_tx_enc_query       = reg_add_b2[6]   ;
  assign fec_rx_signok_en       = reg_add_b2[7]   ;
  assign fec_rx_fast_search_en  = reg_add_b2[8]   ;
  assign fec_rx_blksync_cor_en  = reg_add_b2[9]   ;
  assign fec_rx_dv_start        = reg_add_b2[10]  ;
  assign fec_err_ins            = reg_add_b2[11]  ;
  assign clr_corr_blks          = clr_crr_sc_bit[0];
  assign clr_uncr_blks          = clr_unc_sc_bit[0];

endmodule
