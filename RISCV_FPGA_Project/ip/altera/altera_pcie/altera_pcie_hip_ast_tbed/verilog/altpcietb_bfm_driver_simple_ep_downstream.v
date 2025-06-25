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


// /**
//  * This Verilog HDL file is used for simulation in
//  * the simple downstream design example
//  */
`timescale 1 ps / 1 ps
`define STR_SEP "---------"

module altpcietb_bfm_driver_simple_ep_downstream (input clk_in,
                             input INTA,
                             input INTB,
                             input INTC,
                             input INTD,
                             input rstn,
                             output dummy_out);

   // Global parameter

   parameter  TEST_LEVEL            = 1;
   parameter  TL_BFM_MODE           = 1'b0;      // 0 means full stack RP BFM mode, 1 means TL-only RP BFM (remove CFG accesses to RP internal cfg space)
   parameter  TL_BFM_RP_CAP_REG     = 32'h42;    // In TL BFM mode, pass PCIE Capabilities reg thru parameter (- there is no RP config space).
                                                 // {specify:  port type, cap version}
   parameter  TL_BFM_RP_DEV_CAP_REG = 32'h05;    // In TL BFM mode, pass Device Capabilities reg thru parameter (- there is no RP config space)..
                                                 // {specify:  maxpayld size}
   localparam DISPLAY_ALL           = 1;
   localparam SCR_MEM               = 2048;  // Share memory base address used by DMA
   localparam SCR_MEMSLAVE          = 64;    // Share memory base address used by RC Slave module
   localparam SCR_MEM_DOWNSTREAM_WR = SCR_MEMSLAVE;
   localparam SCR_MEM_DOWNSTREAM_RD = SCR_MEMSLAVE+2048;
   localparam MAX_RCPAYLOAD         = 128;
   localparam RCSLAVE_MAXLEN = 10;  // maximum number of read/write

   localparam TIMEOUT_POLLING       = 2048;  // number of clock' for timout
                                             // using the chaining DMA module


   // Information used by driver for polling Chaining DMA status for completion.
   // These must correspond to the _DESCx_CTL_MSI and _DESCx_CTL_EPLAST parameters above.
   localparam DEBUG_PRG = 0;

   `include "altpcietb_bfm_constants.v"
   `include "altpcietb_bfm_log.v"
   `include "altpcietb_bfm_shmem.v"
   `include "altpcietb_bfm_rdwr.v"
   `include "altpcietb_bfm_configure.v"

   // The clk_in and rstn signals are provided for possible use in controlling
   // the transactions issued, they are not currently used.

// ebfm_display_verb
// overload ebfm_display by turning on/off verbose when DISPLAY_ALL>0
function ebfm_display_verb(
   input integer msg_type,
   input [EBFM_MSG_MAX_LEN*8:1] message);
   reg unused_result;
   begin
      if (DISPLAY_ALL==1)
         unused_result = ebfm_display(msg_type, message);
      ebfm_display_verb = 1'b0 ;
   end
endfunction

// purpose: Examine the DUT's BAR setup and pick a reasonable BAR to use
task find_mem_bar;
   input bar_table;
   integer bar_table;
   input[5:0] allowed_bars;
   input min_log2_size;
   integer min_log2_size;
   output sel_bar;
   integer sel_bar;

   integer cur_bar;
   reg[31:0] bar32;
   integer log2_size;
   reg is_mem;
   reg is_pref;
   reg is_64b;

   begin
      // find_mem_bar
      cur_bar = 0;
      begin : sel_bar_loop
         while (cur_bar < 6)
         begin
            ebfm_cfg_decode_bar(bar_table, cur_bar,
                                log2_size, is_mem, is_pref, is_64b);
            if ((is_mem == 1'b1) &
                (log2_size >= min_log2_size) &
                ((allowed_bars[cur_bar]) == 1'b1))
            begin
               sel_bar = cur_bar;
               disable sel_bar_loop ;
            end
            if (is_64b == 1'b1)
            begin
               cur_bar = cur_bar + 2;
            end
            else
            begin
               cur_bar = cur_bar + 1;
            end
         end
         sel_bar = 7 ; // Invalid BAR if we get this far...
      end
   end
endtask

task scr_memory_compare(
   input integer byte_length,     // downstream wr/rd length in byte
   input integer scr_memorya,     //
   input integer scr_memoryb);     //
   integer i;
   reg [7:0] bytea;
   reg [7:0] byteb;
   reg [31:0] addra;
   reg [31:0] addrb;
   reg unused_result ;

   begin

      //unused_result = ebfm_display_verb(EBFM_MSG_INFO, "TASK:scr_memory_compare");
      addra = scr_memorya;
      addrb = scr_memoryb;

      for (i=0;i<byte_length;i=i+1) begin
         bytea=shmem_read(addra,1);
         byteb=shmem_read(addrb,1);
         addra=addra+1;
         addrb=addrb+1;

      end

      unused_result = ebfm_display_verb(EBFM_MSG_INFO, {"===================  ",dimage4(byte_length) ," bytes  ====================="});
      unused_result = ebfm_display_verb(EBFM_MSG_INFO, {dimage4(byte_length), " bytes transfer - RC memory content"} );
      unused_result =shmem_display(scr_memorya,byte_length,4,scr_memorya+byte_length,EBFM_MSG_INFO);
      unused_result =shmem_display(scr_memoryb,byte_length,4,scr_memoryb+byte_length,EBFM_MSG_INFO);
   end
endtask
task downstream_loop(
   input integer bar_table,       // Pointer to the BAR sizing and
   input integer setup_bar,       // Pointer to the BAR sizing and
   input  integer loop,           // Number of Write/read iteration
   input integer byte_length,     // downstream wr/rd length in byte
   input integer epmem_address,   // Downstream EP memory address in byte
   input  [63:0] start_val);      // Starting write data value

   reg unused_result ;
   reg [63:0] Istart_val;
   reg [31:0] Iepmem_address;
   integer i;
   reg [31:0] Ibyte_length;

   reg [31:0] cfg_reg ;
   reg [31:0] cfg_maxpload_byte ;
   reg [7:0] avalon_waddr ;
   reg [31:0] avalon_waddr_qw_max;
   reg [31:0] avalon_waddr_qw_min;
   reg [31:0] cfg_dw1 ;


   begin
      unused_result = ebfm_display_verb(EBFM_MSG_INFO, `STR_SEP);
      unused_result = ebfm_display_verb(EBFM_MSG_INFO, "TASK:downstream_loop ");


      cfg_maxpload_byte = 0;
      // Retrieve Device cfg from RC Slave
      // Set EP MWr mode

      cfg_reg = 32'h0;

      case (cfg_reg[7:5])
         3'b000 :cfg_maxpload_byte[12:7 ] = 6'b000001;// 128B
         3'b001 :cfg_maxpload_byte[12:7 ] = 6'b000010;// 256B
         3'b010 :cfg_maxpload_byte[12:7 ] = 6'b000100;// 512B
         3'b011 :cfg_maxpload_byte[12:7 ] = 6'b001000;// 1024B
         3'b100 :cfg_maxpload_byte[12:7 ] = 6'b010000;// 2048B
         default:cfg_maxpload_byte[12:7 ] = 6'b100000;// 4096B
      endcase

      Ibyte_length = ((byte_length>cfg_maxpload_byte)||
                                     (byte_length<4))?4:byte_length;
      Istart_val   = start_val;
      for (i=0;i<loop;i=i+1) begin
         downstream_write( bar_table,
                           setup_bar,
                           epmem_address,
                           Istart_val,
                           Ibyte_length);
         downstream_read ( bar_table,
                           setup_bar,
                           epmem_address,
                           Ibyte_length);
         scr_memory_compare(Ibyte_length,
                            SCR_MEM_DOWNSTREAM_WR,
                            SCR_MEM_DOWNSTREAM_RD);
         Istart_val   = Istart_val+cfg_maxpload_byte;
         Ibyte_length = ((Ibyte_length>cfg_maxpload_byte-4)||
                                     (Ibyte_length<4))?4:Ibyte_length+4;
      end
   end
endtask

/////////////////////////////////////////////////////////////////////////
//
// TASK:downstream_write
// Prior to run DMA test, this task clears the performance counters
//
task downstream_write(
   input integer bar_table,          // Pointer to the BAR sizing and
   input integer setup_bar,          // Pointer to the BAR sizing and
   input integer address,            // Downstream EP memory address in byte
   input [63:0] data,
   input integer byte_length);      // BAR to be used for setting up

   reg unused_result ;

   begin

      // Write a data
      shmem_fill(SCR_MEM_DOWNSTREAM_WR,SHMEM_FILL_DWORD_INC,byte_length,data);
      ebfm_barwr(bar_table,setup_bar,address,SCR_MEM_DOWNSTREAM_WR,byte_length,0);

   end

endtask

/////////////////////////////////////////////////////////////////////////
//
// TASK:downstream_read
// Prior to run DMA test, this task clears the performance counters
//
task downstream_read(
   input integer bar_table,          // Pointer to the BAR sizing and
   input integer setup_bar,          // Pointer to the BAR sizing and
   input integer address,            // Downstream EP memory address in byte
   input integer byte_length);      // BAR to be used for setting up

   reg unused_result ;
   begin
      // read a data
      shmem_fill(SCR_MEM_DOWNSTREAM_RD,SHMEM_FILL_DWORD_INC,byte_length,64'hFADE_FADE_FADE_FADE);
      ebfm_barrd_wait(bar_table,setup_bar,address,SCR_MEM_DOWNSTREAM_RD,byte_length,0);
   end

endtask

///////////////////////////////////////////////////////////////////////////////
//
//
// Main Program
//
// Start of the test bench driver altpcietb_bfm_driver
//
   reg activity_toggle;
   reg timer_toggle ;
   time time_stamp ;
   localparam TIMEOUT = 2000000000;
   reg [31:0] err_status;

   initial
     begin
        time_stamp = $time ;
        activity_toggle = 1'b0;
        timer_toggle    = 1'b0;
   end

   // behavioral
   always
   begin : main
      // If you want to relocate the bar_table, modify the BAR_TABLE_POINTER in altpcietb_bfm_shmem.
      // Directly modifying the bar_table at this location may disable overwrite protection for the bar_table
      // If the bar_table is overwritten incorrectly, this will break the testbench functionality.
      parameter bar_table = BAR_TABLE_POINTER; // Default BAR_TABLE_SIZE is 64 bytes
      integer tgt_bar;
      integer dma_bar, rc_slave_bar;
      reg     addr_map_4GB_limit;
      reg     unused_result ;
      reg [15:0] msi_control_register;

      // This constant defines where we save the sizes and programmed addresses
      // of the Endpoint Device Under Test BARs
      // tgt_bar indicates which bar to use for testing the target memory of the
      // reference design.

      // Setup the Root Port and Endpoint Configuration Spaces
      addr_map_4GB_limit = 1'b0;
      unused_result = ebfm_display_verb(EBFM_MSG_WARNING,
           "----> Starting ebfm_cfg_rp_ep task 0");
      ebfm_cfg_rp_ep(
                     bar_table,         // BAR Size/Address info for Endpoint
                     1,                 // Bus Number for Endpoint Under Test
                     1,                 // Device Number for Endpoint Under Test
                     512,               // Maximum Read Request Size for Root Port
                     1,                 // Display EP Config Space after setup
                     addr_map_4GB_limit // Limit the BAR assignments to 4GB address map
                     );

      activity_toggle <= ~activity_toggle ;

      ///////////////////////////////////////////
      // Test the chained DMA example design
      find_mem_bar(bar_table, 6'b111111, 8, rc_slave_bar);
      downstream_loop(
         bar_table,               // Pointer to the BAR sizing and
         rc_slave_bar,            // Pointer to the BAR sizing and
         RCSLAVE_MAXLEN,          // Number of Write/read iteration
         4,                       // downstream wr/rd length in byte
         0,                       // Downstream EP memory address in byte
                                  // (need to be qword aligned)
         64'hFADE_0000_0000_0001);// Starting write data value

      unused_result = ebfm_log_stop_sim(1);
      unused_result = ebfm_display(EBFM_MSG_INFO, "PASSED");
      forever #100000;
   end

   always
     begin
        #(TIMEOUT)
          timer_toggle <= ! timer_toggle ;
     end

   // purpose: this is a watchdog timer, if it sees no activity on the activity
   // toggle signal for 200 us it ends the simulation
   always @(activity_toggle or timer_toggle)
     begin : watchdog
        reg unused_result ;

        if ( ($time - time_stamp) >= TIMEOUT)
          begin
             unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, "Simulation stopped due to inactivity!");
          end
        time_stamp <= $time ;
     end

endmodule
