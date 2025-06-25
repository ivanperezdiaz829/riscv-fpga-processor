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

module altera_xcvr_detlatency_ser_deser #(
  parameter full_data_width = 80,
  parameter dwidth_size = 7
) (
  input [dwidth_size-1:0]   idwidth,
  input [dwidth_size-1:0]   odwidth,
  input [full_data_width-1:0]  datain,

  input                     datain_clk, 
  input                     dataout_clk,
  input                     rst_inclk,
  input                     rst_outclk,
  output [full_data_width-1:0] dataout,
  output                    error
);

//idwidth or odwidth for 32 bit PLD-PCS data will have extra 1 bit because need to include the actual value: eg: value 32 need 6 bit, 64 need 7 bits
localparam FULL_DATA_WIDTH_SHIFT = full_data_width+1;

wire [dwidth_size-1:0]   idwidth_div2;
wire [dwidth_size-1:0]   odwidth_div2;
wire idwidth_odwidth_aeb;
wire idwidth_odwidthdiv2_aeb;
wire idwidthdiv2_odwidth_aeb;
wire [full_data_width-1:0] dataout_expansion;
wire [full_data_width-1:0] dataout_reduction;
wire [dwidth_size-1:0] sync_idwidth;
wire [dwidth_size-1:0] sync_odwidth;
wire [full_data_width-1:0] sync_datain;
reg [5:0] ready;
wire rstn;

//use error port to indicate if there is invalid idwidth:odwidth ratio
/*
initial
begin
    if ((idwidth_odwidth_aeb != 1'b1) && () && ())
            $display("Critical Warning: ser_deser module only supports by 1 and by 2. Your idwidth is '%d' and odwidth is '%d'", idwidth, odwidth);
end
*/

//error indicator for the unsupported idwidth:odwidth ratio
assign error = (~idwidth_odwidth_aeb) & (~idwidth_odwidthdiv2_aeb) & (~idwidthdiv2_odwidth_aeb) & ready[5];

//output 0 for invalid idwidth:odwidth ratio
assign dataout = (idwidth_odwidth_aeb)? sync_datain : (idwidth_odwidthdiv2_aeb)? dataout_expansion : (idwidthdiv2_odwidth_aeb)? dataout_reduction : {full_data_width{1'b0}};

//error only valid after 5 clock cycle for the synchronization take place
always @(posedge dataout_clk or negedge rstn)
begin
    if(~rstn)
    begin
        ready <= 5'd0;
    end
    else
    begin
        ready[0] <= 1'b1;
        ready[1] <= ready[0];
        ready[2] <= ready[1];
        ready[3] <= ready[2];
        ready[4] <= ready[3];
        ready[5] <= ready[4];
        
    end
end


lpm_clshift 
#(
    .lpm_shifttype("LOGICAL"),
    .lpm_type("LPM_CLSHIFT"),
    .lpm_width(dwidth_size),
    .lpm_widthdist(1)
)
ser_deser_idwidth_div2_inst
(
    .data (sync_idwidth),
    .direction (1'b1), //for right shift
    .distance (1'b1),
    .result (idwidth_div2)
    // synopsys translate_off
    ,
    .aclr (),
    .clken (),
    .clock (),
    .overflow (),
    .underflow ()
    // synopsys translate_on
);

lpm_clshift 
#(
    .lpm_shifttype("LOGICAL"),
    .lpm_type("LPM_CLSHIFT"),
    .lpm_width(dwidth_size),
    .lpm_widthdist(1)
)
ser_deser_odwidth_div2_inst
(
    .data (sync_odwidth),
    .direction (1'b1), //for right shift
    .distance (1'b1),
    .result (odwidth_div2)
    // synopsys translate_off
    ,
    .aclr (),
    .clken (),
    .clock (),
    .overflow (),
    .underflow ()
    // synopsys translate_on
);


lpm_compare 
#(
    .lpm_representation("UNSIGNED"),
    .lpm_type("LPM_COMPARE"),
    .lpm_pipeline(1),
    .lpm_width(dwidth_size)
)
ser_deser_idwidth_odwidth_compare_inst (
    .dataa (sync_idwidth),
    .datab (sync_odwidth),
    .aeb (idwidth_odwidth_aeb),
    .aclr (~rstn),
    .agb (),
    .ageb (),
    .alb (),
    .aleb (),
    .aneb (),
    .clken (1'b1),
    .clock (dataout_clk)
);

lpm_compare 
#(
    .lpm_representation("UNSIGNED"),
    .lpm_type("LPM_COMPARE"),
    .lpm_pipeline(1),
    .lpm_width(dwidth_size)
)
ser_deser_idwidth_odwidthdiv2_compare_inst (
    .dataa (sync_idwidth),
    .datab (odwidth_div2),
    .aeb (idwidth_odwidthdiv2_aeb),
    .aclr (~rstn),
    .agb (),
    .ageb (),
    .alb (),
    .aleb (),
    .aneb (),
    .clken (1'b1),
    .clock (dataout_clk)
);

lpm_compare 
#(
    .lpm_representation("UNSIGNED"),
    .lpm_type("LPM_COMPARE"),
    .lpm_pipeline(1),
    .lpm_width(dwidth_size)
)
ser_deser_idwidthdiv2_odwidth_compare_inst (
    .dataa (idwidth_div2),
    .datab (sync_odwidth),
    .aeb (idwidthdiv2_odwidth_aeb),
    .aclr (~rstn),
    .agb (),
    .ageb (),
    .alb (),
    .aleb (),
    .aneb (),
    .clken (1'b1),
    .clock (dataout_clk)
);



altera_xcvr_detlatency_expansion  #(
    .full_data_width(full_data_width),
    .dwidth_size(dwidth_size)
)
ser_deser_expansion_inst
(
    .idwidth(idwidth),
    .odwidth(odwidth),
    .datain(datain),
    .datain_clk(datain_clk), 
    .dataout_clk(dataout_clk),
    .rst_inclk(rst_inclk),
    .rst_outclk(rst_outclk),
    .dataout(dataout_expansion)
);

altera_xcvr_detlatency_reduction #(
    .full_data_width(full_data_width),
    .dwidth_size(dwidth_size)
)
ser_deser_reduction_inst (
    .idwidth(idwidth),
    .odwidth(odwidth),
    .datain(datain),
    .datain_clk(datain_clk), 
    .dataout_clk(dataout_clk),
    .rst_inclk(rst_inclk),
    .rst_outclk(rst_outclk),
    .dataout(dataout_reduction)
);


altera_xcvr_detlatency_synchronizer #(
    .width (full_data_width),
    .stages(2)
)sync_odwidth_ser_deser_inst(
    .clk(dataout_clk),
    .rst(~rstn),
    .dat_in(datain),
    .dat_out(sync_datain)
);

altera_xcvr_detlatency_synchronizer
#(
    .width (dwidth_size),
    .stages(2)
)sync_idwidth_ser_deser_inst(
    .clk(dataout_clk),
    .rst(~rstn),
    .dat_in(idwidth),
    .dat_out(sync_idwidth)
);

altera_xcvr_detlatency_synchronizer
#(
    .width (dwidth_size),
    .stages(2)
)sync_dataout_ser_deser_inst(
    .clk(dataout_clk),
    .rst(~rstn),
    .dat_in(odwidth),
    .dat_out(sync_odwidth)
);


altera_xcvr_detlatency_reset_control #(
    .num_external_resets(2)
) fifo_tx_pma_clk_rst_inst(
    .external_rstn({~rst_inclk,~rst_outclk}),
    .clk(dataout_clk),
    .rstn(rstn)
);  

endmodule