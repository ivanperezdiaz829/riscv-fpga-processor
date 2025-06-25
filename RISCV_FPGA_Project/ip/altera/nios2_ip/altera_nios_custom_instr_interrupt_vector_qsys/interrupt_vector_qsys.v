//Legal Notice: (C)2010 Altera Corporation. All rights reserved.  Your
//use of Altera Corporation's design tools, logic functions and other
//software and tools, and its AMPP partner logic functions, and any
//output files any of the foregoing (including device programming or
//simulation files), and any associated documentation or information are
//expressly subject to the terms and conditions of the Altera Program
//License Subscription Agreement or other applicable license agreement,
//including, without limitation, that your use is for the sole purpose
//of programming logic devices manufactured by Altera and sold by Altera
//or its authorized distributors.  Please refer to the applicable
//agreement for further details.

// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module cpu_0_interrupt_vector_compute_result (
                                               // inputs:
                                                estatus,
                                                ipending,

                                               // outputs:
                                                result
                                             )
;

  output  [ 31: 0] result;
  input            estatus;
  input   [ 31: 0] ipending;

  wire    [ 31: 0] result;
  wire             result_no_interrupts;
  wire    [ 30: 0] result_offset;
  assign result_no_interrupts = (ipending == 0) | (estatus == 0);
  assign result_offset = ipending[0] ? 0 : 
                         ipending[1] ? 8 : 
                         ipending[2] ? 16 : 
                         ipending[3] ? 24 : 
                         ipending[4] ? 32 : 
                         ipending[5] ? 40 : 
                         ipending[6] ? 48 : 
                         ipending[7] ? 56 : 
                         ipending[8] ? 64 : 
                         ipending[9] ? 72 : 
                         ipending[10] ? 80 : 
                         ipending[11] ? 88 : 
                         ipending[12] ? 96 : 
                         ipending[13] ? 104 : 
                         ipending[14] ? 112 : 
                         ipending[15] ? 120 : 
                         ipending[16] ? 128 : 
                         ipending[17] ? 136 : 
                         ipending[18] ? 144 : 
                         ipending[19] ? 152 : 
                         ipending[20] ? 160 : 
                         ipending[21] ? 168 : 
                         ipending[22] ? 176 : 
                         ipending[23] ? 184 :
                         ipending[24] ? 192 : 
                         ipending[25] ? 200 : 
                         ipending[26] ? 208 : 
                         ipending[27] ? 216 : 
                         ipending[28] ? 224 : 
                         ipending[29] ? 232 : 
                         ipending[30] ? 240 : 248;
  assign result = {result_no_interrupts, result_offset};

endmodule


// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module interrupt_vector_qsys (
                               // inputs:
                                estatus,
                                ipending,

                               // outputs:
                                result
                             )
;

  output  [ 31: 0] result;
  input            estatus;
  input   [ 31: 0] ipending;

  wire    [ 31: 0] result;
  //interrupt_vector, which is an e_custom_instruction_slave
  cpu_0_interrupt_vector_compute_result the_cpu_0_interrupt_vector_compute_result
    (
      .estatus  (estatus),
      .ipending (ipending),
      .result   (result)
    );


endmodule

