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

module altera_xcvr_detlatency_expansion #(
  parameter full_data_width= 80,
  parameter dwidth_size = 7
) (
  input [dwidth_size-1:0] idwidth,
  input [dwidth_size-1:0] odwidth,
  input [full_data_width-1:0] datain,
  input                     datain_clk, 
  input                     dataout_clk,
  input                     rst_inclk,
  input                     rst_outclk,
  output reg  [full_data_width-1:0] dataout
);

//idwidth or odwidth for 32 bit PLD-PCS data will have extra 1 bit because need to include the actual value: eg: value 32 need 6 bit, 64 need 7 bits
localparam FULL_DATA_WIDTH_SHIFT = full_data_width+1;

wire [dwidth_size-1:0] sync_idwidth;
wire [dwidth_size-1:0] sync_odwidth;
reg  [full_data_width-1:0] datain_first[2:0];
reg  [full_data_width-1:0] datain_second[2:0];
reg  [full_data_width-1:0] data_combined;
wire [FULL_DATA_WIDTH_SHIFT-1:0] datain_first_w;
wire [FULL_DATA_WIDTH_SHIFT-1:0] datain_first_shifted;
wire [FULL_DATA_WIDTH_SHIFT-1:0] datain_second_w;
wire [FULL_DATA_WIDTH_SHIFT-1:0] datain_second_shifted;

wire [FULL_DATA_WIDTH_SHIFT-1:0] datain_all_ones_shifted;
wire [full_data_width-1:0] datain_mask;
wire [full_data_width-1:0] masked_datain;
reg [FULL_DATA_WIDTH_SHIFT-1:0] datain_all_ones;
wire [FULL_DATA_WIDTH_SHIFT-1:0] dataout_all_ones_shifted;
wire [full_data_width-1:0] dataout_mask;
wire [full_data_width-1:0] dataout_w;
reg [FULL_DATA_WIDTH_SHIFT-1:0] dataout_all_ones;

reg sel_pos_neg;
wire sync_outclk_rstn;
wire sync_inclk_rstn;

genvar i;
generate
    for(i=0;i<FULL_DATA_WIDTH_SHIFT;i=i+1)
    begin: datain_second_loop
        if(i<full_data_width)
        begin
            assign datain_second_w[i] = datain_second[0][i];
            //assign datain_second_w[i] = masked_datain[i];
            assign datain_first_w[i] = datain_first[0][i];
        end
        else
        begin
            assign datain_second_w[i] = 1'b0;
            assign datain_first_w[i] = 1'b0;
        end
    end
endgenerate

//datain need to always pad the unused bit with 0s
//for simulation: need to compile altera_mf for lpm_clshift simulation model
lpm_clshift    
#(
    .lpm_shifttype("LOGICAL"),
    .lpm_type("LPM_CLSHIFT"),
    .lpm_pipeline(2),
    .lpm_width(FULL_DATA_WIDTH_SHIFT),
    .lpm_widthdist(dwidth_size) 
)
expansion_datain_second_shifter_inst 
(
    .aclr (~sync_inclk_rstn),
    .clock (datain_clk),
    //.clken (sel_pos_neg),
    .data (datain_second_w),
    .direction (1'b0),
    .distance (sync_idwidth),
    .result (datain_second_shifted)
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
    .lpm_pipeline(2),
    .lpm_width(FULL_DATA_WIDTH_SHIFT),
    .lpm_widthdist(dwidth_size) 
)
expansion_datain_first_shifter_inst 
(
    .aclr (~sync_inclk_rstn),
    .clock (datain_clk),
    //.clken (sel_pos_neg),
    .data (datain_first_w),
    .direction (1'b0),
    .distance (sync_idwidth),
    .result (datain_first_shifted)
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
expansion_datain_mask_inst 
(
    .aclr (~sync_inclk_rstn),
    .clock (datain_clk),
    .data (datain_all_ones),
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

lpm_clshift    
#(
    .lpm_shifttype("LOGICAL"),
    .lpm_type("LPM_CLSHIFT"),
    .lpm_pipeline(1),
    .lpm_width(FULL_DATA_WIDTH_SHIFT),
    .lpm_widthdist(dwidth_size)
)
expansion_dataout_mask_inst 
(
    .aclr (~sync_outclk_rstn),
    .clock (dataout_clk),
    .data (dataout_all_ones),
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

altera_xcvr_detlatency_synchronizer
#(
    .width (dwidth_size),
    .stages(2)
)sync_idwidth_exp_inst(
    .clk(datain_clk),
    .rst(~sync_inclk_rstn),
    .dat_in(idwidth),
    .dat_out(sync_idwidth)
);


altera_xcvr_detlatency_synchronizer
#(
    .width (dwidth_size),
    .stages(2)
)sync_odwidth_exp_inst(
    .clk(dataout_clk),
    .rst(~sync_outclk_rstn),
    .dat_in(odwidth),
    .dat_out(sync_odwidth)
);


altera_xcvr_detlatency_synchronizer
#(
    .width (full_data_width),
    .stages(1)
)sync_dataout_exp_inst(
    .clk(dataout_clk),
    .rst(~sync_outclk_rstn),
    .dat_in(data_combined),
    .dat_out(dataout_w)
);

altera_xcvr_detlatency_reset_control #(
    .num_external_resets(2)
) rst_ctrl_inclk_exp_inst(
    .external_rstn({~rst_inclk,~rst_outclk}),
    .clk(datain_clk),
    .rstn(sync_inclk_rstn)
);

altera_xcvr_detlatency_reset_control #(
    .num_external_resets(2)
) rst_ctrl_outclk_exp_inst(
    .external_rstn({~rst_inclk,~rst_outclk}),
    .clk(dataout_clk),
    .rstn(sync_outclk_rstn)
);

assign datain_mask = ~datain_all_ones_shifted[full_data_width-1:0];
assign dataout_mask = ~dataout_all_ones_shifted[full_data_width-1:0];
assign masked_datain = datain & datain_mask;
//assign dataout = dataout_w & dataout_mask;
assign dataout = data_combined & dataout_mask;

//assign data_combined = {datain_second_shifted[full_data_width-1:0] | datain_first[1]};


always @ (posedge datain_clk or negedge sync_inclk_rstn)
begin
    if(~sync_inclk_rstn)
        sel_pos_neg <= 1'b0;
    else
        sel_pos_neg <= ~sel_pos_neg;
end

always @ (posedge datain_clk or negedge sync_inclk_rstn)
begin
    if(~sync_inclk_rstn)
    begin
        datain_first[0] <= {full_data_width{1'b0}};
        datain_first[1] <= {full_data_width{1'b0}};
        datain_first[2] <= {full_data_width{1'b0}};
        datain_second[0] <= {full_data_width{1'b0}};
        datain_second[1] <= {full_data_width{1'b0}};
        datain_second[2] <= {full_data_width{1'b0}};
    end
    else
    begin
        
        datain_first[1] <= datain_first[0];
        datain_first[2] <= datain_first[1];
        
        datain_second[1] <= datain_second[0];
        datain_second[2] <= datain_second[1];
        
        if(~sel_pos_neg)
        begin
            datain_first[0] <= masked_datain;
        end
        else
        begin
            datain_second[0] <= masked_datain;
            //datain_second <= masked_datain;
        end
    end
end

always @ (posedge dataout_clk or negedge sync_outclk_rstn)
begin
    if(~sync_outclk_rstn)
        data_combined <= {full_data_width{1'b0}};
    else
    begin
        //data comes out at 3rd clock cycle
        if(~sel_pos_neg)
        //data_combined <= {datain_second_shifted[full_data_width-1:0] | datain_first[1]};
            data_combined <= {datain_second_shifted[full_data_width-1:0] | datain_first[2]};
        else
            data_combined <= {datain_first_shifted[full_data_width-1:0] | datain_second[2]};
    end
end


always @ (posedge datain_clk or negedge sync_inclk_rstn)
begin
    if (~sync_inclk_rstn)
        datain_all_ones <= {FULL_DATA_WIDTH_SHIFT{1'b1}};
    else
        datain_all_ones <= {FULL_DATA_WIDTH_SHIFT{1'b1}};
end

always @ (posedge dataout_clk or negedge sync_outclk_rstn)
begin
    if (~sync_outclk_rstn)
        dataout_all_ones <= {FULL_DATA_WIDTH_SHIFT{1'b1}};
    else
        dataout_all_ones <= {FULL_DATA_WIDTH_SHIFT{1'b1}};
end



endmodule