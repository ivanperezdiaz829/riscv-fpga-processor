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

module altera_xcvr_detlatency_reduction #(
  parameter full_data_width= 80,
  parameter dwidth_size = 7
) (
  input [dwidth_size-1:0] idwidth,
  input [dwidth_size-1:0] odwidth,
  input [full_data_width-1:0] datain,
  input                    datain_clk, 
  input                    dataout_clk,
  input                    rst_inclk,
  input                    rst_outclk,
  output reg [full_data_width-1:0] dataout
);

//idwidth or odwidth for 32 bit PLD-PCS data will have extra 1 bit because need to include the actual value: eg: value 32 need 6 bit, 64 need 7 bits
localparam FULL_DATA_WIDTH_SHIFT = full_data_width+1;

reg  sel;
wire rstn;
wire [full_data_width-1:0] dataout_d;
wire [FULL_DATA_WIDTH_SHIFT-1:0] dataout_second_full;
wire [full_data_width-1:0] dataout_second;
reg [full_data_width-1:0] dataout_first[2:0];
wire [full_data_width-1:0] dataout_mask;
reg [FULL_DATA_WIDTH_SHIFT-1:0] data_all_ones;
wire [FULL_DATA_WIDTH_SHIFT-1:0] dataout_all_ones_shifted;
wire [FULL_DATA_WIDTH_SHIFT-1:0] datain_all_ones_shifted;
wire [full_data_width-1:0] masked_datain;
wire [full_data_width-1:0] datain_mask;
wire [FULL_DATA_WIDTH_SHIFT-1:0] masked_datain_w;
wire [full_data_width-1:0] sync_datain;
wire [dwidth_size-1:0] sync_idwidth;
wire [dwidth_size-1:0] sync_odwidth;


genvar i;
generate
    for(i=0;i<FULL_DATA_WIDTH_SHIFT;i=i+1)
    begin: masked_datain_w_loop
        if(i<full_data_width)
            assign masked_datain_w[i] = masked_datain[i];
        else
            assign masked_datain_w[i] = 1'b0;
    end
endgenerate

//datain need to always pad the unused bit with 0s
//for simulation: need to compile altera_mf for lpm_clshift simulation model
lpm_clshift    
#(
    .lpm_shifttype("LOGICAL"),
    .lpm_type("LPM_CLSHIFT"),
    .lpm_pipeline(3),
    .lpm_width(FULL_DATA_WIDTH_SHIFT),
    .lpm_widthdist(dwidth_size)
)
reduction_dataout_second_shifter_inst 
(
    .aclr (~rstn),
    .clock (dataout_clk),
    
    .data (masked_datain_w),
    .direction (1'b1),
    .distance (sync_odwidth),
    .result (dataout_second_full)
    // synopsys translate_off
    ,
    //.aclr(),
    //.clock(),
    .clken (),
    .overflow (),
    .underflow ()
    // synopsys translate_on
);

lpm_clshift    
#(
    .lpm_shifttype("LOGICAL"),
    .lpm_type("LPM_CLSHIFT"),
    .lpm_pipeline(1),
    .lpm_width(FULL_DATA_WIDTH_SHIFT),
    .lpm_widthdist(dwidth_size)
)
reduction_dataout_mask_inst 
(
    .aclr (~rstn),
    .clock (dataout_clk),
    .data (data_all_ones),
    .direction (1'b0),
    .distance (sync_odwidth),
    .result (dataout_all_ones_shifted)
    // synopsys translate_off
    ,
    .clken (),
    .overflow (),
    .underflow ()
    // synopsys translate_on
);

lpm_clshift    
#(
    .lpm_shifttype("LOGICAL"),
    .lpm_type("LPM_CLSHIFT"),
    .lpm_pipeline(1),
    .lpm_width(FULL_DATA_WIDTH_SHIFT),
    .lpm_widthdist(dwidth_size)
)
reduction_datain_mask_inst 
(
    .aclr (~rstn),
    .clock (dataout_clk),
    .data (data_all_ones),
    .direction (1'b0),
    .distance (sync_idwidth),
    .result (datain_all_ones_shifted)
    // synopsys translate_off
    ,
    .clken (),
    .overflow (),
    .underflow ()
    // synopsys translate_on
);

altera_xcvr_detlatency_synchronizer #(
    .width (full_data_width),
    .stages(2)
)sync_datain_red_inst(
    .clk(dataout_clk),
    .rst(~rstn),
    .dat_in(datain),
    .dat_out(sync_datain)
);

altera_xcvr_detlatency_synchronizer #(
    .width (dwidth_size),
    .stages(2)
)sync_idwidth_red_inst(
    .clk(dataout_clk),
    .rst(~rstn),
    .dat_in(idwidth),
    .dat_out(sync_idwidth)
);

altera_xcvr_detlatency_synchronizer #(
    .width (dwidth_size),
    .stages(2)
)sync_odwidth_red_inst(
    .clk(dataout_clk),
    .rst(~rstn),
    .dat_in(odwidth),
    .dat_out(sync_odwidth)
);

//for 2-stagepipelining with dataout_second
/*
altera_xcvr_detlatency_synchronizer #(
    .width (dwidth_size),
    .stages(2)
)sync_dataout_first_red_inst(
    .clk(dataout_clk),
    .rst(~rstn),
    .dat_in({dataout_mask & sync_datain[full_data_width-1:0]}),
    .dat_out(dataout_first)
);
*/

// older data located at the lower half. Send the older data out first -- sel=0 goes out first
assign dataout_second = dataout_second_full[full_data_width-1:0];
assign dataout_d = (~sel)? dataout_second : dataout_first[2]; 
assign dataout_mask = ~dataout_all_ones_shifted[full_data_width-1:0];
assign datain_mask = ~datain_all_ones_shifted[full_data_width-1:0];

//assign masked_datain = sync_datain & datain_mask;
assign masked_datain = datain & datain_mask;


//for 2-stage pipelining with dataout_second
always @ (posedge dataout_clk or negedge rstn)
begin
    if (~rstn)
    begin
        //dataout_second <= {full_data_width{1'b0}};
        dataout_first[0] <= {full_data_width{1'b0}};
        dataout_first[1] <= {full_data_width{1'b0}};
        dataout_first[2] <= {full_data_width{1'b0}};
    end
    else
    begin
        //dataout_second <= dataout_second_full[full_data_width-1:0];
        //dataout_first[0] <= {dataout_mask & sync_datain[full_data_width-1:0]};
       // dataout_first[0] <= {dataout_mask & datain[full_data_width-1:0]};
        dataout_first[0] <= {datain_mask & datain[full_data_width-1:0]};
        dataout_first[1] <= dataout_first[0];
        dataout_first[2] <= dataout_first[1];
        
    end
end

always @ (posedge dataout_clk or negedge rstn)
begin
    if (~rstn)
        data_all_ones <= {FULL_DATA_WIDTH_SHIFT{1'b1}};
    else
        data_all_ones <= {FULL_DATA_WIDTH_SHIFT{1'b1}};
end

always @ (posedge dataout_clk or negedge rstn)
begin
    if (~rstn)
        sel <= 1'b0;
    else
        sel <= ~sel;
end

always @ (posedge dataout_clk or negedge rstn)
begin
    if (~rstn)
        dataout <= {full_data_width{1'b0}};
    else
        dataout <= dataout_d & dataout_mask;
end

altera_xcvr_detlatency_reset_control #(
    .num_external_resets(2)
) fifo_tx_pma_clk_rst_inst(
    .external_rstn({~rst_inclk,~rst_outclk}),
    .clk(dataout_clk),
    .rstn(rstn)
);      
        
endmodule