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


/*
    0x00    ro      (64) id
    0x01    ro      (01) version
    0x02    ro      (00) purpose
    0x03    ro      (00) detect   (clock detect)
    0x04    rw      (00) reset    reset[7:0]
    0x05    rw      (00) reserved    flush[7:0]
    0x06    rw      (00) h2t fifo level
    0x07    rw      (00) t2h fifo level
    0x08    rw      (00) mgmt_data[31:25]
    0x09    rw      (00) mgmt_data[23:16]
    0x0a    rw      (00) mgmt_data[15:8]
    0x0b    rw      (00) mgmt_channel[31:25]
    0x0c    rw      (00) mgmt_channel[23:16]
    0x0d    rw      (00) mgmt_channel[15:8]
    0x0e    rw      (00) mgmt_channel[7:0]
    0x0f    rw      (00) mgmt_data[7:0]

    0x0x    rw      (00) ram
*/

module altera_usb_debug_i2c_slave #(
    parameter DEVICE_FAMILY         = "StratixIV",
    parameter ADDR_LEN              = 64,
    parameter PURPOSE               = -1,
    parameter RAM_FILE              = "altera_usb_debug_i2c_ram.hex",
    parameter NUM_MGMT_CHANNELBITS  = 2,
    parameter NUM_MGMT_DATABITS     = 2,
    //derived parameters
    parameter ADDR_WIDTH     = alt_clogb2(ADDR_LEN),
    parameter CHANNEL_WIDTH  = (NUM_MGMT_CHANNELBITS) ? NUM_MGMT_CHANNELBITS : 1,
    parameter DATA_WIDTH     = (NUM_MGMT_DATABITS)    ? NUM_MGMT_DATABITS    : 1
)(
    input  wire                     clk,
    input  wire                     arst,
    output reg                      waitrequest,
    input  wire    [ADDR_WIDTH-1:0] address,
    input  wire                     write,
    input  wire               [7:0] writedata,
    input  wire                     read,
    output wire               [7:0] readdata,
    output reg                      readvalid,

    input  wire               [7:0] mgmt_detect,
    output reg                [7:0] mgmt_reset,
    output reg                [7:0] mgmt_flush,
    input  wire               [7:0] mgmt_level0,
    input  wire               [7:0] mgmt_level1,
    output reg                      mgmt_valid,
    output wire [CHANNEL_WIDTH-1:0] mgmt_channel,
    output wire    [DATA_WIDTH-1:0] mgmt_data,
    output reg                      sense_reset
);
function integer alt_clogb2;
input [31:0] value;
integer i;
begin
    alt_clogb2 = 32;
    for (i=31; i>0; i=i-1) begin
        if (2**i>=value) begin
            alt_clogb2 = i;
        end
    end
end
endfunction
localparam ZERO      = 32'h0;
localparam ONE       = 32'h1;
localparam TWO       = 32'h2;
localparam THREE     = 32'h3;
localparam FOUR      = 32'h4;
localparam FIVE      = 32'h5;
localparam SIX       = 32'h6;
localparam SEVEN     = 32'h7;
localparam EIGHT     = 32'h8;
localparam NINE      = 32'h9;
localparam TEN       = 32'ha;
localparam ELEVEN    = 32'hb;
localparam TWELVE    = 32'hc;
localparam THIRTEEN  = 32'hd;
localparam FOURTEEN  = 32'he;
localparam FIFTEEN   = 32'hf;

localparam HEX_10    = 32'h10;
localparam HEX_11    = 32'h11;
localparam HEX_12    = 32'h12;
localparam HEX_13    = 32'h13;
localparam HEX_14    = 32'h14;
localparam HEX_15    = 32'h15;
localparam HEX_16    = 32'h16;
localparam HEX_17    = 32'h17;
localparam HEX_18    = 32'h18;
localparam HEX_19    = 32'h19;
localparam HEX_1A    = 32'h1A;
localparam HEX_1B    = 32'h1B;
localparam HEX_1C    = 32'h1C;
localparam HEX_1D    = 32'h1D;
localparam HEX_1E    = 32'h1E;
localparam HEX_1F    = 32'h1F;

reg  [31:0] mgmt_channel32;
reg  [31:0] mgmt_data32;
reg         reg_select_1;
reg   [7:0] reg_readdata_1;
wire  [7:0] ram_readdata_1;
wire  [7:0] ident_readdata;
reg   [3:0] ident_contrib;

//read/write, WS=0, RL=1

always @(posedge clk or posedge arst) begin
    if (arst) begin
        waitrequest <= 1'b1;
        reg_select_1 <= 1'b0;
        reg_readdata_1 <= 8'h00;
        readvalid <= 1'b0;
        sense_reset <= 1'b0;

        mgmt_reset <= 8'h00;
        mgmt_flush <= 8'h00;
        mgmt_valid <= 1'b0;
        mgmt_channel32 <= 32'h0;
        mgmt_data32 <= 32'h0;
        ident_contrib <= 4'h0;
    end
    else begin
        waitrequest <= 1'b0;
        reg_select_1 <= 1'b0;
        readvalid <= 1'b0;
        sense_reset <= 1'b0;
        mgmt_valid <= 1'b0;

        if (write & ~waitrequest) begin
            case (address)
            FOUR[0+:ADDR_WIDTH]: begin
                mgmt_reset <= writedata;
            end
            FIVE[0+:ADDR_WIDTH]: begin
                mgmt_flush <= writedata;
            end
            EIGHT[0+:ADDR_WIDTH]: begin
                mgmt_data32[24+:8] <= writedata;
            end
            NINE[0+:ADDR_WIDTH]: begin
                mgmt_data32[16+:8] <= writedata;
            end
            TEN[0+:ADDR_WIDTH]: begin
                mgmt_data32[8+:8] <= writedata;
            end
            ELEVEN[0+:ADDR_WIDTH]: begin
                mgmt_channel32[24+:8] <= writedata;
            end
            TWELVE[0+:ADDR_WIDTH]: begin
                mgmt_channel32[16+:8] <= writedata;
            end
            THIRTEEN[0+:ADDR_WIDTH]: begin
                mgmt_channel32[8+:8] <= writedata;
            end
            FOURTEEN[0+:ADDR_WIDTH]: begin
                mgmt_channel32[0+:8] <= writedata;
            end
            FIFTEEN[0+:ADDR_WIDTH]: begin
                mgmt_data32[0+:8] <= writedata;
                mgmt_valid <= 1'b1;
            end
            HEX_1F[0+:ADDR_WIDTH]: begin
                ident_contrib <= writedata[4+:4];
            end
            endcase
        end
        if (read) begin
            reg_readdata_1 <= 8'h00;
            readvalid <= 1'b1;
            case (address)
            ZERO[0+:ADDR_WIDTH]: begin
                if (PURPOSE >= 0) begin
                    reg_select_1 <= 1'b1;
                    reg_readdata_1 <= 8'h6e;    //id
                end
            end
            ONE[0+:ADDR_WIDTH]: begin
                if (PURPOSE >= 0) begin
                    reg_select_1 <= 1'b1;
                    reg_readdata_1 <= 8'h03;    //version
                end
            end
            TWO[0+:ADDR_WIDTH]: begin
                if (PURPOSE >= 0) begin
                    reg_select_1 <= 1'b1;
                    reg_readdata_1 <= PURPOSE[0+:8];
                end
            end
            THREE[0+:ADDR_WIDTH]: begin
                reg_select_1 <= 1'b1;
                reg_readdata_1 <= mgmt_detect;
                sense_reset <= 1'b1;
            end
            SIX[0+:ADDR_WIDTH]: begin
                reg_select_1 <= 1'b1;
                reg_readdata_1 <= mgmt_level0;
            end
            SEVEN[0+:ADDR_WIDTH]: begin
                reg_select_1 <= 1'b1;
                reg_readdata_1 <= mgmt_level1;
            end
            HEX_10[0+:ADDR_WIDTH], HEX_11[0+:ADDR_WIDTH], HEX_12[0+:ADDR_WIDTH], HEX_13[0+:ADDR_WIDTH], 
            HEX_14[0+:ADDR_WIDTH], HEX_15[0+:ADDR_WIDTH], HEX_16[0+:ADDR_WIDTH], HEX_17[0+:ADDR_WIDTH], 
            HEX_18[0+:ADDR_WIDTH], HEX_19[0+:ADDR_WIDTH], HEX_1A[0+:ADDR_WIDTH], HEX_1B[0+:ADDR_WIDTH], 
            HEX_1C[0+:ADDR_WIDTH], HEX_1D[0+:ADDR_WIDTH], HEX_1E[0+:ADDR_WIDTH], HEX_1F[0+:ADDR_WIDTH]: begin
                reg_select_1 <= 1'b1;
                reg_readdata_1 <= ident_readdata;
            end
            endcase
        end
    end
end
assign readdata = (reg_select_1) ? reg_readdata_1 : ram_readdata_1;
assign mgmt_channel = mgmt_channel32[0+:CHANNEL_WIDTH];
assign mgmt_data    = mgmt_data32[0+:DATA_WIDTH];

altera_connection_identification_rom #(
    .width     (8)
)ident_rom(
    .address   (address[3:0]),
    .readdata  (ident_readdata),
    .writedata (ident_contrib)
);

generate
if (PURPOSE < 0) begin:g_use_i2c_ram
//64x8=512bits = 1xlutram
//256x8=2Kbits = .25 x M9K
altsyncram #(
    .intended_device_family (DEVICE_FAMILY),
    .operation_mode         ("DUAL_PORT"),
    .width_a                (8),
    .widthad_a              (ADDR_WIDTH),
    .numwords_a             (ADDR_LEN),
    .width_b                (8),
    .widthad_b              (ADDR_WIDTH),
    .numwords_b             (ADDR_LEN),
    .maximum_depth          (0),
    .lpm_type               ("altsyncram"),
    .width_byteena_a        (1),
    .byte_size              (8),
    .address_aclr_a         ("NONE"),
    .indata_aclr_a          ("NONE"),
    .wrcontrol_aclr_a       ("NONE"),
    .address_aclr_b         ("NONE"),
    .address_reg_b          ("CLOCK0"),
    .outdata_aclr_b         ("NONE"),
    .outdata_reg_b          ("UNREGISTERED"),
    .ram_block_type         ("AUTO"),
    .read_during_write_mode_mixed_ports ("DONT_CARE"),
    .init_file              (RAM_FILE)
)i2c_ram(
    .clock0                 (clk),
    .address_a              (address),
    .wren_a                 (write),
    .data_a                 (writedata),

    .address_b              (address),
    .q_b                    (ram_readdata_1)
//synthesis translate_off
    ,.aclr0 ()
    ,.aclr1 ()
    ,.addressstall_a ()
    ,.addressstall_b ()
    ,.byteena_a ()
    ,.byteena_b ()
    ,.clock1 ()
    ,.clocken0 ()
    ,.clocken1 ()
    ,.clocken2 ()
    ,.clocken3 ()
    ,.data_b ()
    ,.eccstatus ()
    ,.q_a ()
    ,.rden_a ()
    ,.rden_b ()
    ,.wren_b ()
//synthesis translate_on
);
end
else begin:g_no_i2c_ram
    assign ram_readdata_1 = 8'h0;
end
endgenerate

endmodule
