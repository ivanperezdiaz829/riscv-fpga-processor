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


module mgmt_master #( 
    parameter CLOCKS_PER_SECOND = 125000000,  // Used for time calculations
    parameter PIO_OUT_SIZE      = 8,          // Width of PIO output port
    parameter PIO_IN_SIZE       = 8,          // Width of PIO input port
    parameter [PIO_OUT_SIZE-1:0] PIO_OUT_INIT_VALUE = 0,  // Initial value for pio_out registers
    parameter ROM_DEPTH         = 512         // Depth of command ROM
//  parameter INIT_FILE_NAME    = ""          // If specified, ROM will be initialized from file using $readmemh
  ) (
  input                           clk,
  input                           reset,

  output  reg                     av_write,
  output  reg                     av_read,
  output  reg [30:0]              av_address,
  output  reg [31:0]              av_writedata,
  input       [31:0]              av_readdata,
  input                           av_waitrequest,

  output  reg [PIO_OUT_SIZE-1:0]  pio_out,
  input       [ PIO_IN_SIZE-1:0]  pio_in
);

// Define macro to user program if not provided.
`ifndef MGMT_PROGRAM_TASK
  `define MGMT_PROGRAM_TASK th_mgmt_program
  `define MGMT_UNDEF
`endif

import mgmt_functions_h::*;
import mgmt_commands_h::*;

//localparam  LOAD_FROM_FILE = (INIT_FILE_NAME == "") ? 0 : 1;
//localparam  FILETYPE="hex";
localparam  ADDR_WIDTH = clogb2(ROM_DEPTH);

reg   [ROM_WIDTH-1:0]   rom [0:(ROM_DEPTH-1)];  // Command storage ROM
wire  [ADDR_WIDTH-1:0]  rom_address;
wire                    rom_read;
reg   [ ROM_WIDTH-1:0]  rom_data;

//*********************************************************************
//************************ Command ROM ********************************
// Output addressed ROM contents
always @ (posedge clk)
  if(rom_read)
    rom_data  <= rom[rom_address];

//********************** End Command ROM ******************************
//*********************************************************************


mgmt_cpu #(
    .PIO_OUT_SIZE       (PIO_OUT_SIZE),
    .PIO_IN_SIZE        (PIO_IN_SIZE ),
    .PIO_OUT_INIT_VALUE (PIO_OUT_INIT_VALUE),
    .ROM_DEPTH          (ROM_DEPTH   )
    ) mgmt_cpu_inst (
  .clk            (clk            ),
  .reset          (reset          ),
                                  
  .av_write       (av_write       ),
  .av_read        (av_read        ),
  .av_address     (av_address     ),
  .av_writedata   (av_writedata   ),
  .av_readdata    (av_readdata    ),
  .av_waitrequest (av_waitrequest ),

  .rom_address    (rom_address    ),
  .rom_read       (rom_read       ),
  .rom_data       (rom_data       ),
                                  
  .pio_out        (pio_out        ), .pio_in         (pio_in         )
);


//generate if(LOAD_FROM_FILE == 0) begin : load_ram
  integer i;
  initial begin
    clocks_per_second = CLOCKS_PER_SECOND;
    pre_process();  // Pre process
    `MGMT_PROGRAM_TASK::`MGMT_PROGRAM_TASK();
    $display("[mgmt_master - %m] mgmt program resulted in %0d ROM commands. ROM capacity is %0d commands.", rom_i, ROM_DEPTH);
    post_process(); // Post process program
    // Copy program from temporary prog_rom to rom
    for(i=0;i<ROM_DEPTH;i=i+1) begin
      rom[i] = prog_rom[i];
    end
  end
//end
//
//else begin
//  if(FILETYPE == "hex") begin
//    initial begin
//      $readmemh(INIT_FILE_NAME, rom);
//    end
//  end else begin
//    initial begin
//      $readmemb(INIT_FILE_NAME, rom);
//    end
//  end
//end
//endgenerate

// Undefine previously defined macros
`ifdef MGMT_UNDEF
  `undef MGMT_PROGRAM_TASK
  `undef MGMT_UNDEF
`endif

endmodule
