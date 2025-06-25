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

module altera_xcvr_detlatency_tx_dwidth_adapter #(
  parameter full_idwidth= 80,
  parameter full_odwidth= 80,
  parameter idwidth_size = 7,
  parameter odwidth_size = 7,
  parameter full_ser_words_in = 8,
  parameter full_ser_words_out = 8,
  parameter ser_words_in_size = 4,
  parameter ser_words_out_size = 4
) (
  input                   datain_clk, 
  input                   dataout_clk,
  input                   rst_inclk,
  input                   rst_outclk,
  input [idwidth_size-1:0] idwidth,
  input [odwidth_size-1:0] odwidth,
  input [ser_words_in_size-1:0] ser_words_in,
  input [ser_words_out_size-1:0] ser_words_out,
  input  [full_idwidth-1:0] datain,
  input  [full_ser_words_in-1:0] datakin,
  output [full_odwidth-1:0] dataout,
  output [full_ser_words_out-1:0] datakout,
  output error
);

localparam FULL_DATA_WIDTH = (full_idwidth > full_odwidth)? full_idwidth : full_odwidth;
localparam FULL_SER_WORDS = (full_ser_words_in > full_ser_words_out)? full_ser_words_in : full_ser_words_out;
localparam DWIDTH_SIZE = (idwidth_size > odwidth_size)? idwidth_size : odwidth_size;
localparam SER_WORDS_SIZE = (ser_words_in_size > ser_words_out_size)? ser_words_in_size : ser_words_out_size;

wire [1:0] error_w;
reg error_r;

//for padding the unused bits and truncating the unused bits
wire [FULL_DATA_WIDTH-1 : 0] datain_ser_deser;
wire [FULL_DATA_WIDTH-1 : 0] dataout_ser_deser;
wire [FULL_SER_WORDS-1 : 0] datakin_ser_deser;
wire [FULL_SER_WORDS-1 : 0] datakout_ser_deser;
wire [DWIDTH_SIZE-1 : 0] idwidth_w;
wire [DWIDTH_SIZE-1 : 0] odwidth_w;
wire [SER_WORDS_SIZE-1 : 0] ser_words_in_w;
wire [SER_WORDS_SIZE-1 : 0] ser_words_out_w;

assign error = error_r;

always @(posedge dataout_clk or posedge rst_outclk)
begin
    if(rst_outclk)
        error_r <= 1'b0;
    else
        error_r <= |error_w;
end

genvar i;
generate
begin
    for(i=0;i<FULL_DATA_WIDTH; i=i+1)
    begin: datain_gen
        if(i<full_idwidth)
            assign datain_ser_deser[i] = datain[i];
        else
            assign datain_ser_deser[i] = 1'b0;

    end
    
    for(i=0;i<full_odwidth; i=i+1)
    begin: dataout_gen
        assign dataout[i] = dataout_ser_deser[i];
    end
        
    for(i=0;i<FULL_SER_WORDS; i=i+1)
    begin: datakin_gen
        if(i<full_ser_words_in)
            assign datakin_ser_deser[i] = datakin[i];
        else
            assign datakin_ser_deser[i] = 1'b0;

    end
    
    for(i=0;i<full_ser_words_out; i=i+1)
    begin: datakout_gen
        assign datakout[i] = datakout_ser_deser[i];
    end
    
    for(i=0;i<DWIDTH_SIZE; i=i+1)
    begin: idwidth_gen
        if(i<idwidth_size)
            assign idwidth_w[i] = idwidth[i];
        else
            assign idwidth_w[i] = 1'b0;
    end
	 
	 for(i=0;i<DWIDTH_SIZE; i=i+1)
    begin: odwidth_gen
        if(i<odwidth_size)
            assign odwidth_w[i] = odwidth[i];
        else
            assign odwidth_w[i] = 1'b0;
    end
    
    for(i=0;i<SER_WORDS_SIZE; i=i+1)
    begin: ser_words_in_gen
        if(i<ser_words_in_size)
            assign ser_words_in_w[i] = ser_words_in[i];
        else
            assign ser_words_in_w[i] = 1'b0;
    end
	 
	 for(i=0;i<SER_WORDS_SIZE; i=i+1)
    begin: ser_words_out_gen
        if(i<ser_words_out_size)
            assign ser_words_out_w[i] = ser_words_out[i];
        else
            assign ser_words_out_w[i] = 1'b0;
    end
        
end        
endgenerate

    altera_xcvr_detlatency_ser_deser #(
        .full_data_width(FULL_DATA_WIDTH),
        .dwidth_size(DWIDTH_SIZE)
    ) data_inst(
        .idwidth(idwidth_w),
        .odwidth(odwidth_w),
        .datain(datain_ser_deser),
        .datain_clk(datain_clk), 
        .dataout_clk(dataout_clk),
        .rst_inclk(rst_inclk),
        .rst_outclk(rst_outclk),
        .dataout(dataout_ser_deser),
        .error(error_w[0])
    );
    
    altera_xcvr_detlatency_ser_deser #(
        .full_data_width(FULL_SER_WORDS),
        .dwidth_size(SER_WORDS_SIZE)
    )datak_inst(
        .idwidth(ser_words_in_w),
        .odwidth(ser_words_out_w),
        .datain(datakin_ser_deser),
        .datain_clk(datain_clk), 
        .dataout_clk(dataout_clk),
        .rst_inclk(rst_inclk),
        .rst_outclk(rst_outclk),
        .dataout(datakout_ser_deser),
        .error(error_w[1])
    );
  

endmodule