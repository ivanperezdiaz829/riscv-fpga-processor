//--------------------------------------------------------------------------------------------------
// (c)2007 Altera Corporation. All rights reserved.
//
// Altera products are protected under numerous U.S. and foreign patents,
// maskwork rights, copyrights and other intellectual property laws.
//
// This reference design file, and your use thereof, is subject to and governed
// by the terms and conditions of the applicable Altera Reference Design License
// Agreement (either as signed by you or found at www.altera.com).  By using
// this reference design file, you indicate your acceptance of such terms and
// conditions between you and Altera Corporation.  In the event that you do not
// agree with such terms and conditions, you may not use the reference design
// file and please promptly destroy any copies you have made.
//
// This reference design file is being provided on an "as-is" basis and as an
// accommodation and therefore all warranties, representations or guarantees of
// any kind (whether express, implied or statutory) including, without
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or
// require that this reference design file be used in combination with any
// other product not provided by Altera.
//--------------------------------------------------------------------------------------------------
//
//--------------------------------------------------------------------------------------------------
//
//--------------------------------------------------------------------------------------------------

module pll_reconfig_control
  (
   input         rst,
   input         sys_clk,
   //input         rx_clk,
   input         start_reconfig,
   input  [1:0]  std_select,
   input  [3:0]  serdes_status,
   output [2:0]  rx_pll_outclk,
   //output [3:0]  heartbeat
   
   input sdi_ref,
   output          pll_areset,
   output          pll_configupdate,
   output          pll_scanclk,
   output          pll_scanclkena,
   output          pll_scandata,
   input           pll_scandataout,
   input           pll_scandone
  );


   wire          reconfig_clk;
   assign        reconfig_clk = sys_clk;

   wire          busy;
   wire          pll_out_clk;
   wire          pll_out_clk_d2;
   
   wire          rom_ena;
   wire [7:0]    rom_address_out;
   wire          rom_data;


   wire          pll_reconfig;
   wire          reset_rom_address;
   wire          write_from_rom;

//--------------------------------------------------------------------------------------------------
// ROM megafunctions.  These two ROMS store the PLL settings for HD and SD/3G operation.  The
// ROMSs have a MIF (Memory Initialization File) associated with them.  These files set the contents
// of the ROMs.  
//--------------------------------------------------------------------------------------------------   
   
   wire    rom_data_sd;
   wire    rom_data_hd;

   pll_rom_hd pll_rom_hd_inst
     (
      .address          (rom_address_out),
      .clock            (reconfig_clk),
      .rden             (rom_ena),
      .q                (rom_data_hd)
      );


   wire    rom_data_3g;   
   
   pll_rom_3g pll_rom_3g_inst
     (
      .address          (rom_address_out),
      .clock            (reconfig_clk),
      .rden             (rom_ena),
      .q                (rom_data_3g)
      );


   // select which rom output is used to reload PLL.
   assign  rom_data = std_select[1] ? rom_data_3g : (std_select[0] ? rom_data_hd : rom_data_sd);
   
//--------------------------------------------------------------------------------------------------
// This code block controls the PLL reconfiguration megafunction.  It also provides the address bus
// to the ROMS above.
//--------------------------------------------------------------------------------------------------   
   
   pll_reconfig_fsm pll_reconfig_fsm_inst
     (
      .rst                      (rst),
      .sys_clk                  (sys_clk),   
      .start_reconfig           (start_reconfig),
      .rom_address_out          (rom_address_out),
      .busy                     (busy),
      .pll_reconfig             (pll_reconfig),
      .reset_rom_address        (reset_rom_address),
      .write_from_rom           (write_from_rom)
      );


//--------------------------------------------------------------------------------------------------
// This is an instance of the PLL reconfiguration megafunction.  This takes the parallel data from
// ROMS storing the alternative PLL settings and serialises it.  This serial interface is connected
// to the ALTPLL (see below) 
//--------------------------------------------------------------------------------------------------   

   
   pll_reconfig_mega pll_reconfig_mega_inst
	 ( 
       .busy                    (busy),
       .clock                   (reconfig_clk),
       .counter_param           (),
       .counter_type            (),
       .data_in                 (),
       .data_out                (),
       .pll_areset              (pll_areset),
       .pll_areset_in           (rst),
       .pll_configupdate        (pll_configupdate),
       .pll_scanclk             (pll_scanclk),
       .pll_scanclkena          (pll_scanclkena),
       .pll_scandata            (pll_scandata),
       .pll_scandataout         (pll_scandataout),
       .pll_scandone            (pll_scandone),       
       .read_param              (1'b0),
       .reconfig                (pll_reconfig),
       .reset                   (rst),
       .reset_rom_address       (reset_rom_address),
       .rom_address_out         (rom_address_out),
       .rom_data_in             (rom_data),
       .write_from_rom          (write_from_rom),
       .write_param             (1'b0),
       .write_rom_ena           (rom_ena)
       );

endmodule
