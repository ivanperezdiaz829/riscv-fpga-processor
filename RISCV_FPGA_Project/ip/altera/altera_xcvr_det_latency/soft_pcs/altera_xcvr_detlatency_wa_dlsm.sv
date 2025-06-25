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



`timescale 1 ps / 1 ps

module altera_xcvr_detlatency_wa_dlsm #(
  parameter dwidth_size = 40
) (
  data_width,
  rcvd_clk,
  soft_reset,
  boundary_loc,
  encdt_rse,
  rslip_separation,
  rassert_sync_status_imm,
  sync_status,
  toggle_number,
  boundary_slip,
  current_state
);
      
        
input [dwidth_size-1 : 0] data_width;
input        rcvd_clk;          //reocvered clock                
input        soft_reset;        //reset synchronized to rcvd_clk
input [6:0]  boundary_loc;      //boundary_locdetected by pattern detection logic
input        encdt_rse;         //rising edge resets the SM to IDLE state

input [9:0]  rslip_separation;          // CRAM which controls the distance between 2 rising edge of boundary_slip pulses  
input        rassert_sync_status_imm;   //Controls the whether to assert sync_status right after boundary_slip toggling is done

output       sync_status;         // inidcates boundary_slipping is done. 
output [6:0] toggle_number;       //to test bus
output       boundary_slip;       // to PMA indicating to slip a bit 
output [1:0] current_state;       //for test bus


reg        sync_status;
reg        boundary_slip;
reg  [1:0] current_state;
reg  [1:0] next_state;

reg [9:0] slip_separation_cnt;
reg  [6:0] toggle_cnt;
reg  [6:0] toggle_number;
reg [6:0]  num_of_toggles;
                      
reg [9:0] slip_separation_cnt_d;
reg  [6:0] toggle_cnt_d;
reg  [6:0] toggle_number_d;
reg        sync_status_d;
reg        boundary_slip_d;
reg        sync_status_int;

localparam   IDLE         = 2'b00; 
localparam   TOGGLE_HIGH  = 2'b01; 
localparam   TOGGLE_LOW   = 2'b10; 
localparam   SYNC         = 2'b11;


assign num_of_toggles = (boundary_loc < data_width) ? (boundary_loc) : 7'h7f;
 
//-----------------------------------------------
//Next State decoding logic 
//-----------------------------------------------


always @(posedge soft_reset or posedge rcvd_clk)
begin
   if (soft_reset)
   begin
      current_state  <= IDLE;
   end
   else
   begin
      current_state  <= next_state;
   end
end




always @( current_state or encdt_rse or num_of_toggles or toggle_number or 
          toggle_cnt or slip_separation_cnt or rslip_separation or rassert_sync_status_imm)
       
begin
     case (current_state)
        IDLE:
             if( encdt_rse ||  (num_of_toggles == 7'h7f) )
             begin
                 next_state = IDLE;
             end
             else if( num_of_toggles == 7'h00)
             begin
                 next_state = SYNC;
             end
             else 
             begin
                 next_state = TOGGLE_HIGH;
             end

        TOGGLE_HIGH:
             if( encdt_rse )
             begin
                 next_state = IDLE;
             end
             else if( slip_separation_cnt < 10'h002 )
             begin
                 next_state = TOGGLE_HIGH;
             end
             else 
             begin
                 next_state = TOGGLE_LOW; 
             end
         
        TOGGLE_LOW:
             if(encdt_rse || (~(toggle_cnt < toggle_number) & ~(slip_separation_cnt < rslip_separation ) & ~rassert_sync_status_imm ) )
             begin
                 next_state = IDLE;
             end
             else if( slip_separation_cnt < rslip_separation  )
             begin
                 next_state = TOGGLE_LOW;
             end
             else if(toggle_cnt < toggle_number) 
             begin
                 next_state = TOGGLE_HIGH; 
             end
             else 
             begin
                 next_state = SYNC; 
             end
           
           SYNC:
             if( encdt_rse )
             begin
                 next_state = IDLE;
             end
             else 
             begin
                 next_state = SYNC;
             end
           default:next_state =IDLE;
     endcase
end 



//Output Decoding logic
//always @(next_state or current_state or num_of_toggles or slip_separation_cnt or toggle_number or toggle_cnt  or sync_status or boundary_slip)
always @(next_state or current_state or num_of_toggles or slip_separation_cnt or toggle_number or toggle_cnt )
begin

   slip_separation_cnt_d = slip_separation_cnt;
   toggle_number_d       = toggle_number;
   toggle_cnt_d          = toggle_cnt;
   sync_status_d         = 1'b0;
   boundary_slip_d       = 1'b0;
   
   case (next_state)
     
      IDLE :
         begin
             slip_separation_cnt_d = 10'h000;
             toggle_number_d       = 7'h00;
             toggle_cnt_d          = 7'h00; 
             sync_status_d         = 1'b0; 
             boundary_slip_d       = 1'b0;
         end

      TOGGLE_HIGH :
         begin
              slip_separation_cnt_d =  (current_state != TOGGLE_HIGH)  ? 10'h000 : (slip_separation_cnt + 10'h001) ;
              toggle_number_d          = (current_state == IDLE) ? num_of_toggles : toggle_number;
              boundary_slip_d       = 1'b1;
         end

      TOGGLE_LOW :
         begin
              toggle_cnt_d          = (current_state == TOGGLE_HIGH ) ? (toggle_cnt + 7'h01)  : toggle_cnt;
              slip_separation_cnt_d = slip_separation_cnt + 10'h001 ;
              boundary_slip_d       = 1'b0;
         end

      SYNC :
         begin
             sync_status_d         = 1'b1;
         end

   endcase 
end 
          
always @(posedge soft_reset or posedge rcvd_clk)
begin
   if (soft_reset)
   begin
       slip_separation_cnt <= 10'h000; 
       toggle_number       <= 7'h00;       
       toggle_cnt          <= 7'h00;       
       sync_status_int     <= 1'b0;       
       sync_status         <= 1'b0;       
       boundary_slip       <= 1'b0;      
   end
   else
   begin
       slip_separation_cnt <= slip_separation_cnt_d; 
       toggle_number       <= toggle_number_d;        
       toggle_cnt          <= toggle_cnt_d;           
       sync_status_int     <= sync_status_d;          
       sync_status         <= sync_status_int;          
       boundary_slip       <= boundary_slip_d;       
   end
end

endmodule //deterministic latency_sm     


