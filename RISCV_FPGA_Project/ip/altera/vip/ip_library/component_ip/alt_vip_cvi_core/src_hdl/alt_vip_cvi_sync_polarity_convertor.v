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


module alt_vip_cvi_sync_polarity_convertor(
    input rst,
    input clk,
    
    input sync_in,
    input datavalid,
    input de,
    output sync_out);

wire de_negedge;
reg de_reg;
wire needs_invert_nxt;
reg needs_invert;
wire invert_sync_nxt;
reg invert_sync;

assign de_negedge = de_reg & ~de;
assign needs_invert_nxt = (de & sync_in) | needs_invert;
assign invert_sync_nxt = (de_negedge) ? needs_invert_nxt : invert_sync;

always @ (posedge rst or posedge clk) begin
    if(rst) begin
        de_reg <= 1'b0;
        needs_invert <= 1'b0;
        invert_sync <= 1'b0;
    end else begin
        if(datavalid) begin
            de_reg <= de;
            needs_invert <= needs_invert_nxt & ~de_negedge;
            invert_sync <= invert_sync_nxt;
        end
    end
end

assign sync_out = sync_in ^ invert_sync_nxt;

endmodule
