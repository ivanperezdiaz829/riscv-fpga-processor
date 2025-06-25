`timescale 1ns / 1ns

module altera_avalon_st_pipeline_stage (
                                 clk,
                                 reset,
                                 in_ready,
                                 in_valid,
                                 in_data,
                                 out_ready,
                                 out_valid,
                                 out_data
                                );

  parameter  SYMBOLS_PER_BEAT  = 1;
  parameter  BITS_PER_SYMBOL   = 8;
  localparam DATA_WIDTH = SYMBOLS_PER_BEAT * BITS_PER_SYMBOL;
                            
  input clk;
  input reset;
  output reg in_ready;
  input in_valid;
  input [DATA_WIDTH-1:0] in_data;

  input out_ready;
  output out_valid;
  output [DATA_WIDTH-1:0] out_data;

  reg full0;
  reg full1;
  reg [DATA_WIDTH-1:0] data0;
  reg [DATA_WIDTH-1:0] data1;

  assign out_valid = full1;
  assign out_data  = data1;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      in_ready <= 1'b0;
      full0    <= 1'b0;
      full1    <= 1'b0;
      data0    <= 'b0;
      data1    <= 'b0;
    end else begin
      // we always fill data1 first, so in_ready is if full0 is low and we have
      // space

      // no data in pipeline
      if (~full0 & ~full1) begin
        in_ready <= 1'b1;
        if (in_valid) begin
          full1 <= 1'b1;
          data1 <= in_data;
        end
      end // ~f1 & ~f0

      // one datum in pipeline
      if (full1 & ~full0) begin
        in_ready <= 1'b1;
        if (in_valid & out_ready) begin
          //data shifts through
          data1 <= in_data;
        end // iv & or
        if (in_valid & ~out_ready) begin
          // fill up data0
          full0 <= 1'b1;
          data0 <= in_data;
          in_ready <= 1'b0;
        end //iv & ~or
        if (~in_valid & out_ready) begin
          // back to empty
          full1 <= 1'b0;
        end //~iv & or
      end // f1 & ~f0
      
      // two data in pipeline
      if (full1 & full0) begin
        in_ready <= 1'b0;
        if (out_ready) begin
          // go back to one datum state
          data1 <= data0;
          full0 <= 1'b0;
          in_ready <= 1'b1;
        end // end go back to one datum state
      end
    end //if ~reset_n
  end //always

endmodule
