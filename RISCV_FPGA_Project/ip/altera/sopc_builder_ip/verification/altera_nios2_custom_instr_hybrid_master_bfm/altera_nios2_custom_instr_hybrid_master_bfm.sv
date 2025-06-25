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


// $File: //acds/main/ip/sopc/components/verification/altera_nios2_custom_instr_hybrid_master_bfm/altera_nios2_custom_instr_hybrid_master_bfm.sv $
// $Revision: #15 $
// $Date: 2010/07/20 $
// $Author: wkleong $
//-----------------------------------------------------------------------------
// =head1 NAME
// altera_nios2_custom_instr_hybrid_master_bfm
// =head1 SYNOPSIS
// NiosII Custom Instruction Hybrid Master BFM
//-----------------------------------------------------------------------------
// =head1 DESCRIPTION
// This is a Bus Functional Model (BFM) for 
//  NiosII Custom Instruction Hybrid Master.
//-----------------------------------------------------------------------------
`timescale 1ns / 1ns

module altera_nios2_custom_instr_hybrid_master_bfm (
   clk,
   reset,
   
   multi_clk,
   multi_reset,
   multi_clk_en,
   
   multi_dataa,
   multi_datab,
   multi_result,
   multi_start,
   multi_done,
   multi_n,
   multi_a,
   multi_b,
   multi_c,
   multi_readra,
   multi_readrb,
   multi_writerc,
   
   combo_dataa,
   combo_datab,
   combo_result,
   combo_n,
   combo_a,
   combo_b,
   combo_c,
   combo_readra,
   combo_readrb,
   combo_writerc
);

   // =head1 PARAMETERS
   
   // =head2 Multi Cycles Parameter
   parameter NUM_OPERANDS_MULTI  = 2;  // Number of operands
   parameter USE_RESULT_MULTI    = 1;  // Using result
   parameter USE_READRA_MULTI    = 0;  // Using register a
   parameter USE_READRB_MULTI    = 0;  // Using register b
   parameter USE_WRITERC_MULTI   = 0;  // Using register c
   
   // =head2 Combinatorial Parameters
   parameter NUM_OPERANDS_COMBO  = 2;  // Number of operands
   parameter USE_RESULT_COMBO    = 1;  // Using result
   parameter USE_READRA_COMBO    = 0;  // Using register a
   parameter USE_READRB_COMBO    = 0;  // Using register b
   parameter USE_WRITERC_COMBO   = 0;  // Using register c
   
   parameter EXT_WIDTH           = 8;  // Width of port n
   
   localparam WORD_WIDTH         = 32;
   localparam ADDR_WIDTH         = 5;
   localparam MUST_USE_EXTENSION = 1;
   
   // =head1 PINS
   // =head2 Clock Interface
   input                            clk;
   input                            reset;
   
   // =head2 Multi Cycles Port
   output                           multi_clk;
   output                           multi_reset;
   output                           multi_clk_en;
   
   output [WORD_WIDTH-1: 0]         multi_dataa;
   output [WORD_WIDTH-1: 0]         multi_datab;
   input  [WORD_WIDTH-1: 0]         multi_result;
   
   output                           multi_start;
   input                            multi_done;
   
   output [EXT_WIDTH-1: 0]          multi_n;
   
   output [ADDR_WIDTH-1: 0]         multi_a;
   output [ADDR_WIDTH-1: 0]         multi_b;
   output [ADDR_WIDTH-1: 0]         multi_c;
   output                           multi_readra;
   output                           multi_readrb;
   output                           multi_writerc;
   
   // =head2 Combinatorial Port
   output [WORD_WIDTH-1: 0]         combo_dataa;
   output [WORD_WIDTH-1: 0]         combo_datab;
   input  [WORD_WIDTH-1: 0]         combo_result;
   
   output [EXT_WIDTH-1: 0]          combo_n;
   
   output [ADDR_WIDTH-1: 0]         combo_a;
   output [ADDR_WIDTH-1: 0]         combo_b;
   output [ADDR_WIDTH-1: 0]         combo_c;
   output                           combo_readra;
   output                           combo_readrb;
   output                           combo_writerc;
   // =cut
   
   typedef logic [WORD_WIDTH-1: 0]        ci_data_t;
   typedef logic [ADDR_WIDTH-1: 0]        ci_addr_t;
   typedef logic [EXT_WIDTH-1: 0]   multi_n_t;
   typedef logic [EXT_WIDTH-1: 0]   combo_n_t;
   
   // Multi Cycles Port
   logic                            multi_clk;
   logic                            multi_reset;
   logic                            multi_clk_en;
   
   ci_data_t                        multi_dataa;
   ci_data_t                        multi_datab;
   
   logic                            multi_start;
   logic                            multi_done;
   
   multi_n_t                        multi_n;
   
   ci_addr_t                        multi_a;
   ci_addr_t                        multi_b;
   ci_addr_t                        multi_c;
   logic                            multi_readra;
   logic                            multi_readrb;
   logic                            multi_writerc;
   
   //Combinatorial Port
   ci_data_t                        combo_dataa;
   ci_data_t                        combo_datab;
   
   combo_n_t                        combo_n;
   
   ci_addr_t                        combo_a;
   ci_addr_t                        combo_b;
   ci_addr_t                        combo_c;
   logic                            combo_readra;
   logic                            combo_readrb;
   logic                            combo_writerc;
   
   // synthesis translate_on
   // Multi Cycle Master
   altera_nios2_custom_instr_master_bfm #(
      .NUM_OPERANDS     (NUM_OPERANDS_MULTI  ),
      .USE_RESULT       (USE_RESULT_MULTI    ),
      .USE_MULTI_CYCLE  (1                   ),
      .FIXED_LENGTH     (2                   ),
      .USE_START        (1                   ),
      .USE_DONE         (1                   ),
      .USE_EXTENSION    (MUST_USE_EXTENSION  ),
      .EXT_WIDTH        (EXT_WIDTH           ),
      .USE_READRA       (USE_READRA_MULTI    ),
      .USE_READRB       (USE_READRB_MULTI    ),
      .USE_WRITERC      (USE_WRITERC_MULTI   )
   ) multi_master (
      .clk           (clk           ),
      .reset         (reset         ),
      .ci_clk        (multi_clk     ),
      .ci_reset      (multi_reset   ),
      .ci_clk_en     (multi_clk_en  ),
      .ci_dataa      (multi_dataa   ),
      .ci_datab      (multi_datab   ),
      .ci_result     (multi_result  ),
      .ci_start      (multi_start   ),
      .ci_done       (multi_done    ),
      .ci_n          (multi_n       ),
      .ci_a          (multi_a       ),
      .ci_b          (multi_b       ),
      .ci_c          (multi_c       ),
      .ci_readra     (multi_readra  ),
      .ci_readrb     (multi_readrb  ),
      .ci_writerc    (multi_writerc )
   );
   
   // Combinatorial Master
   altera_nios2_custom_instr_master_bfm #(
      .NUM_OPERANDS     (NUM_OPERANDS_COMBO  ),
      .USE_RESULT       (USE_RESULT_COMBO    ),
      .USE_MULTI_CYCLE  (0                   ),
      .FIXED_LENGTH     (2                   ),
      .USE_START        (0                   ),
      .USE_DONE         (0                   ),
      .USE_EXTENSION    (MUST_USE_EXTENSION  ),
      .EXT_WIDTH        (EXT_WIDTH           ),
      .USE_READRA       (USE_READRA_COMBO    ),
      .USE_READRB       (USE_READRB_COMBO    ),
      .USE_WRITERC      (USE_WRITERC_COMBO   )
   ) combo_master (
      .clk           (clk           ),
      .reset         (reset         ),
      .ci_clk        (              ),
      .ci_reset      (              ),
      .ci_clk_en     (              ),
      .ci_dataa      (combo_dataa   ),
      .ci_datab      (combo_datab   ),
      .ci_result     (combo_result  ),
      .ci_start      (              ),
      .ci_done       (              ),
      .ci_n          (combo_n       ),
      .ci_a          (combo_a       ),
      .ci_b          (combo_b       ),
      .ci_c          (combo_c       ),
      .ci_readra     (combo_readra  ),
      .ci_readrb     (combo_readrb  ),
      .ci_writerc    (combo_writerc )
   );
   
   
   

endmodule

// =head1 SEE ALSO
// altera_nios2_combo_instr_master_bfm/
// altera_nios2_combo_instr_slave_bfm/
// =cut
