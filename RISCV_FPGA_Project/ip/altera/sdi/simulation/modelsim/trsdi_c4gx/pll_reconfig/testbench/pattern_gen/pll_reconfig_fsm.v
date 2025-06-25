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
// State mahcine to control the PLL reconfiguration megafunction
//--------------------------------------------------------------------------------------------------

module pll_reconfig_fsm
  (
   input        rst,
   input        sys_clk,   
   input        start_reconfig,
   input [7:0]  rom_address_out,
   input        busy,
   output       pll_reconfig,
   output       reset_rom_address,
   output       write_from_rom
   );


   reg     start_reconfig_d1;
   wire    start_reconfig_blip;
  

   // Generate a one clock wide start pulse
   always @ (posedge sys_clk or posedge rst )
     begin
        if (rst) start_reconfig_d1 <= 1'b0;
        else start_reconfig_d1 <= start_reconfig;
     end 

   assign   start_reconfig_blip = start_reconfig & ~start_reconfig_d1;
   

   wire    reconfig_clk;
   assign  reconfig_clk = sys_clk;
   

   reg    t_pll_reconfig;
   reg    t_reset_rom_address;
   reg    t_write_from_rom;
  
   parameter [2:0] IDLE                 = 3'b000;
   parameter [2:0] READ_MIF_FROM_ROM    = 3'b001;
   parameter [2:0] WAIT_FOR_PARAM_WRITE = 3'b110;
   parameter [2:0] RECONFIG             = 3'b111;      
   parameter [7:0] MAX_ROM_ADDR         = 8'd144;
   
   reg [2:0]       state;
   
   always @ (posedge reconfig_clk or posedge rst )
     begin
        if (rst) begin
           state <= IDLE;
           t_pll_reconfig <= 1'b0;
           t_reset_rom_address <= 1'b1;
           t_write_from_rom <= 1'b0;
        end
        else begin
           
           t_pll_reconfig <= 1'b0;
           t_reset_rom_address <= 1'b0;
           t_write_from_rom <= 1'b0;

           
           case (state)

             IDLE : 
               begin
                  if (start_reconfig_blip == 1'b1) begin
                     state <= READ_MIF_FROM_ROM;                     
                  end
               end

             READ_MIF_FROM_ROM:
               begin
                  t_write_from_rom <= 1'b1;
                  if (rom_address_out == MAX_ROM_ADDR - 1) begin
                     state <= RECONFIG;
                  end
               end

             RECONFIG :
               begin
                  t_pll_reconfig <= 1'b1;
                  state <= WAIT_FOR_PARAM_WRITE;
               end


             WAIT_FOR_PARAM_WRITE :
               begin
                  if (busy == 1'b0) begin
                     t_reset_rom_address <= 1'b1;
                     state <= IDLE;                    
                  end
               end
             
             default :
               state <= IDLE;

           endcase // case(state)
        end // else: !if(rst)
     end // always @ (posedge reconfig_clk or posedge rst )

   assign pll_reconfig = t_pll_reconfig;
   assign reset_rom_address = t_reset_rom_address;
   assign write_from_rom = t_write_from_rom;
   
   

   
endmodule
