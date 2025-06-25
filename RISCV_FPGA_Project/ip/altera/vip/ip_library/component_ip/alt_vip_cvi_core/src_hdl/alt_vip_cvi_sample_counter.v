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


module alt_vip_cvi_sample_counter
    #(parameter
        NUMBER_OF_COLOUR_PLANES = 0,
        COLOUR_PLANES_ARE_IN_PARALLEL = 0,
        LOG2_NUMBER_OF_COLOUR_PLANES = 0)
    (
    input wire rst,
    input wire clk, 
    input wire sclr,
    
    input wire count_cycle,
    input wire hd_sdn,
    
    output wire count_sample,
    output wire start_of_sample,
    output wire [LOG2_NUMBER_OF_COLOUR_PLANES-1:0] sample_ticks);

generate
    if(NUMBER_OF_COLOUR_PLANES == 1) begin
        assign count_sample = count_cycle;
        assign start_of_sample = 1'b1;
        assign sample_ticks = 1'b0;
    end else begin
        reg [LOG2_NUMBER_OF_COLOUR_PLANES-1:0] count_valids;
        wire new_sample;
        
        assign new_sample = count_valids == (NUMBER_OF_COLOUR_PLANES - 1);
        
        always @ (posedge rst or posedge clk) begin
            if(rst) begin
                count_valids <= {LOG2_NUMBER_OF_COLOUR_PLANES{1'b0}};
            end else begin
                if(sclr)
                    count_valids <= {{LOG2_NUMBER_OF_COLOUR_PLANES-1{1'b0}}, count_cycle};
                else
                    count_valids <= (count_cycle) ? (new_sample) ? {LOG2_NUMBER_OF_COLOUR_PLANES{1'b0}} : count_valids + 1'b1 : count_valids;
            end
        end
        
        assign count_sample = (hd_sdn) ? count_cycle : count_cycle & new_sample; 
        assign start_of_sample = (hd_sdn) ? 1'b1 : (count_valids == {LOG2_NUMBER_OF_COLOUR_PLANES{1'b0}});
        assign sample_ticks = count_valids;
    end
endgenerate

endmodule
