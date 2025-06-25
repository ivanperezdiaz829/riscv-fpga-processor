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


(* altera_attribute = "-name IP_TOOL_NAME altera_usb_debug_fifos; -name IP_TOOL_VERSION 13.1" *)

module altera_usb_debug_fifos #(
    parameter DEVICE_FAMILY         = "StratixIV",
    parameter USE_DCFIFO            = 0,
    parameter FIFO_DEPTH            = 256,
    parameter USE_I2C               = 1,
    parameter I2CADDR               = 8'h6e,
    parameter PURPOSE               = -1,
    parameter I2C_RAM_FILE          = "altera_usb_debug_i2c_ram.hex",
    parameter NUM_MGMT_CHANNELBITS  = 2,
    parameter NUM_MGMT_DATABITS     = 2,
    parameter ENABLE_LOOPBACK       = 1,
    //derived parameters
    parameter FIFO_DEPTH_WIDTH = alt_clogb2(FIFO_DEPTH),
    parameter MGMT_CHANNEL_WIDTH  = (NUM_MGMT_CHANNELBITS) ? NUM_MGMT_CHANNELBITS : 1,
    parameter MGMT_DATA_WIDTH     = (NUM_MGMT_DATABITS)    ? NUM_MGMT_DATABITS    : 1
)(
    //io interface
    input  wire                     fpga_clk,
    input  wire                     fpga_arst_n,
    output wire                     fpga_full,
    output wire                     fpga_empty,
    input  wire                     fpga_wr_n,
    input  wire                     fpga_rd_n,
    input  wire                     fpga_oe_n,
    inout  wire               [7:0] fpga_data,
    inout  wire               [1:0] fpga_addr,

    inout  tri                      fpga_scl,
    inout  tri                      fpga_sda,
    output wire                     mgmt_valid,             //av_clk_out domain
    output wire [MGMT_CHANNEL_WIDTH-1:0] mgmt_channel,
    output wire    [MGMT_DATA_WIDTH-1:0] mgmt_data,


    //internal interface
    input  wire                     av_clk,
    output wire                     av_clk_out,
    output wire                     av_arst_out,

    //usb_to_fpga
    input  wire                     avst_src_ready,
    output wire                     avst_src_valid,
    output wire               [7:0] avst_src_data,

    //fgpa_to_usb
    output wire                     avst_sink_ready,
    input  wire                     avst_sink_valid,
    input  wire               [7:0] avst_sink_data
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
//----------------------------------------------------------------------------
wire  [7:0] fpga_mgmt_detect;
wire  [7:0] fpga_mgmt_reset;
wire  [7:0] fpga_mgmt_flush;
wire        sense_reset;
wire        av_mgmt_reset;
wire        av_loopback;
//----------------------------------------------------------------------------
wire [((FIFO_DEPTH_WIDTH>8)?FIFO_DEPTH_WIDTH:8):0] usbout_level;
wire       usbout_full;
wire       usbout_almost_full;
wire       usbout_write;
wire [7:0] usbout_wdata;

wire       usbout_empty;
wire       usbout_almost_empty;
wire       usbout_read;
wire [7:0] usbout_rdata;

wire [((FIFO_DEPTH_WIDTH>8)?FIFO_DEPTH_WIDTH:8):0] usbin_level;
wire       usbin_full;
wire       usbin_almost_full;
wire       usbin_write;
wire [7:0] usbin_wdata;

wire       usbin_empty;
wire       usbin_almost_empty;
wire       usbin_read;
wire [7:0] usbin_rdata;

wire       avst_src_ready1;
wire       avst_src_valid1;
wire [7:0] avst_src_data1;
wire [7:0] avst_src_data2;

wire       avst_sink_ready1;
wire       avst_sink_valid1;
wire [7:0] avst_sink_data1;
//----------------------------------------------------------------------------
generate
if (USE_DCFIFO) begin:g_cc

altera_reset_synchronizer
#(
    .DEPTH          (2),
    .ASYNC_RESET    (1)
)reset_synchroniser(
    .clk            (av_clk),
    .reset_in       (fpga_mgmt_reset[0]),
    .reset_out      (av_mgmt_reset)
);

altera_std_synchronizer #(
    .depth      (3)
)loopback_synchronizer(
    .clk        (av_clk),
    .reset_n    (1'b1),
    .din        (fpga_mgmt_reset[1]),
    .dout       (av_loopback)
);

reg  clock_sense /* synthesis altera_attribute = "-name SDC_STATEMENT \"set_false_path -from [get_keepers {*altera_usb_debug_fifos:*|sense_reset}] -to [get_keepers {*altera_usb_debug_fifos:*|clock_sense}]\"" */;
wire fpga_clock_sense /* synthesis altera_attribute = "-name SDC_STATEMENT \"set_false_path -from [get_keepers {*altera_usb_debug_fifos:*|fpga_mgmt_reset}] -to [get_keepers {*altera_usb_debug_fifos:*|altera_reset_synchronizer:*}]\"" */;

//what to use to reset the clock_sense?
always @(posedge av_clk or posedge sense_reset) begin
    if (sense_reset) begin
        clock_sense <= 1'b0;
    end
    else begin
        clock_sense <= 1'b1;
    end
end
altera_std_synchronizer #(
    .depth      (3)
)clock_sensor_synchronizer(
    .clk        (fpga_clk),
    .reset_n    (1'b1),
    .din        (clock_sense),
    .dout       (fpga_clock_sense)
);

assign av_clk_out = av_clk;
assign av_arst_out = av_mgmt_reset;
assign fpga_mgmt_detect = {7'h0, fpga_clock_sense};
end
else begin:g_no_cc
assign av_clk_out = fpga_clk;
assign av_arst_out = fpga_mgmt_reset[0];
assign av_loopback = fpga_mgmt_reset[1];
assign fpga_mgmt_detect = {7'h0, 1'b1};            //clock is always active
end
endgenerate
//----------------------------------------------------------------------------
wire                          fpga_mgmt_valid;             //fpga_clk domain
wire [MGMT_CHANNEL_WIDTH-1:0] fpga_mgmt_channel;
wire    [MGMT_DATA_WIDTH-1:0] fpga_mgmt_data;

generate
if (USE_DCFIFO) begin:g_mgm_cc
    altera_avalon_st_clock_crosser #(
        .SYMBOLS_PER_BEAT       (1),
        .BITS_PER_SYMBOL        (MGMT_CHANNEL_WIDTH+MGMT_DATA_WIDTH),
        .USE_OUTPUT_PIPELINE    (0),
        .FORWARD_SYNC_DEPTH     (2),
        .BACKWARD_SYNC_DEPTH    (2)
    )altera_avalon_st_clock_crosser(
        .in_clk                 (fpga_clk),
        .in_reset               (fpga_mgmt_reset[0]),
        .in_ready               (),
        .in_valid               (fpga_mgmt_valid),
        .in_data                ({fpga_mgmt_channel,fpga_mgmt_data}),
        .out_clk                (av_clk),
        .out_reset              (av_mgmt_reset),
        .out_ready              (1'b1),
        .out_valid              (mgmt_valid),
        .out_data               ({mgmt_channel,mgmt_data})
    );
end
else begin:g_no_mgm_cc
    assign mgmt_valid   = fpga_mgmt_valid;
    assign mgmt_channel = fpga_mgmt_channel;
    assign mgmt_data    = fpga_mgmt_data;
end
endgenerate
//----------------------------------------------------------------------------
assign fpga_full       = usbout_almost_full;
assign fpga_empty      = usbin_empty;
assign usbout_write    = ~fpga_wr_n;
assign usbin_read      = ~fpga_rd_n;
assign fpga_addr       = 2'bz; // Currently unused
assign usbout_wdata    = fpga_data;
assign fpga_data       = (~fpga_oe_n) ? usbin_rdata : 8'hz;
//----------------------------------------------------------------------------
generate
if (USE_DCFIFO) begin:g_use_dcfifo
    dcfifo	#(
        .intended_device_family (DEVICE_FAMILY),
        .lpm_type               ("dcfifo"),
        .lpm_width              (8),
        .lpm_numwords           (1<<FIFO_DEPTH_WIDTH),
        .lpm_widthu             (1+FIFO_DEPTH_WIDTH),
        .add_ram_output_register("ON"),
        .lpm_showahead          ("ON"),
        .overflow_checking      ("OFF"),
        .underflow_checking     ("OFF"),
        .use_eab                ("ON"),
        .add_usedw_msb_bit      ("ON"),
        .lpm_hint               ("MAXIMIZE_SPEED=7,"),
        .rdsync_delaypipe       (5),
        .write_aclr_synch       ("ON"),
        .wrsync_delaypipe       (5)
    )usbout_fifo(
        .wrclk                  (fpga_clk),
        .wrusedw                (usbout_level[0+:1+FIFO_DEPTH_WIDTH]),
        .wrfull                 (usbout_full),
        .wrreq                  (usbout_write & ~usbout_full),
        .data                   (usbout_wdata),

        .rdclk                  (av_clk_out),
        .aclr                   (av_arst_out),
        .rdusedw                (),
        .rdempty                (usbout_empty),
        .rdreq                  (usbout_read & ~usbout_empty),
        .q                      (usbout_rdata)
    // synopsys translate_off
        ,.wrempty ()
        ,.rdfull ()
    // synopsys translate_on
    );
    assign usbout_almost_full = (usbout_level[0+:1+FIFO_DEPTH_WIDTH] > (1<<FIFO_DEPTH_WIDTH)-4) ? 1'b1 : 1'b0;

    dcfifo	#(
        .intended_device_family (DEVICE_FAMILY),
        .lpm_type               ("dcfifo"),
        .lpm_width              (8),
        .lpm_numwords           (1<<FIFO_DEPTH_WIDTH),
        .lpm_widthu             (1+FIFO_DEPTH_WIDTH),
        .add_ram_output_register("ON"),
        .lpm_showahead          ("ON"),
        .overflow_checking      ("OFF"),
        .underflow_checking     ("OFF"),
        .use_eab                ("ON"),
        .add_usedw_msb_bit      ("ON"),
        .lpm_hint               ("MAXIMIZE_SPEED=7,"),
        .rdsync_delaypipe       (5),
        .write_aclr_synch       ("ON"),
        .wrsync_delaypipe       (5)
    )usbin_fifo(
        .wrclk                  (av_clk_out),
        .wrusedw                (),
        .wrfull                 (usbin_full),
        .wrreq                  (usbin_write & ~usbin_full),
        .data                   (usbin_wdata),

        .rdclk                  (fpga_clk),
        .aclr                   (fpga_mgmt_reset[0]),
        .rdusedw                (usbin_level[0+:1+FIFO_DEPTH_WIDTH]),
        .rdempty                (usbin_empty),
        .rdreq                  (usbin_read & ~usbin_empty),
        .q                      (usbin_rdata)
    // synopsys translate_off
        ,.wrempty ()
        ,.rdfull ()
    // synopsys translate_on
    );
end
else begin:g_use_scfifo
    scfifo #(
        .intended_device_family (DEVICE_FAMILY),
        .lpm_type               ("scfifo"),
        .lpm_width              (8),
        .lpm_numwords           (1<<FIFO_DEPTH_WIDTH),
        .lpm_widthu             (FIFO_DEPTH_WIDTH),
        .almost_empty_value     (2),
        .almost_full_value      ((1<<FIFO_DEPTH_WIDTH)-2),
        .add_ram_output_register("ON"),
        .lpm_showahead          ("ON"),
        .overflow_checking      ("OFF"),
        .underflow_checking     ("OFF"),
        .use_eab                ("ON")
    )usbout_fifo(
        .clock                  (fpga_clk),
        .aclr                   (av_arst_out),
        .usedw                  (usbout_level[0+:FIFO_DEPTH_WIDTH]),

        //fx2 interface
        .full                   (usbout_full),
        .almost_full            (usbout_almost_full),
        .wrreq                  (usbout_write & ~usbout_full),
        .data                   (usbout_wdata),

        //fpga interface
        .empty                  (usbout_empty),
        .almost_empty           (usbout_almost_empty),
        .rdreq                  (usbout_read & ~usbout_empty),
        .q                      (usbout_rdata)
    // synopsys translate_off
        ,.sclr ()
    // synopsys translate_on
    );
    assign usbout_level[FIFO_DEPTH_WIDTH] = usbout_full;

    scfifo #(
        .intended_device_family (DEVICE_FAMILY),
        .lpm_type               ("scfifo"),
        .lpm_width              (8),
        .lpm_numwords           (1<<FIFO_DEPTH_WIDTH),
        .lpm_widthu             (FIFO_DEPTH_WIDTH),
        .almost_empty_value     (2),
        .almost_full_value      ((1<<FIFO_DEPTH_WIDTH)-2),
        .add_ram_output_register("ON"),
        .lpm_showahead          ("ON"),
        .overflow_checking      ("OFF"),
        .underflow_checking     ("OFF"),
        .use_eab                ("ON")
    )usbin_fifo(
        .clock                  (fpga_clk),
        .aclr                   (av_arst_out),
        .usedw                  (usbin_level[0+:FIFO_DEPTH_WIDTH]),

        //fpga interface
        .full                   (usbin_full),
        .almost_full            (usbin_almost_full),
        .wrreq                  (usbin_write & ~usbin_full),
        .data                   (usbin_wdata),

        //fx2 interface
        .empty                  (usbin_empty),
        .almost_empty           (usbin_almost_empty),
        .rdreq                  (usbin_read & ~usbin_empty),
        .q                      (usbin_rdata)
    // synopsys translate_off
        ,.sclr ()
    // synopsys translate_on
    );
    assign usbin_level[FIFO_DEPTH_WIDTH]  = usbin_full;
end
endgenerate

assign usbout_read      = avst_src_ready1;
assign avst_src_valid1  = ~usbout_empty;
assign avst_src_data1   = usbout_rdata;

assign avst_sink_ready1 = ~usbin_full;
assign usbin_write      = avst_sink_valid1;
assign usbin_wdata      = avst_sink_data1;
//----------------------------------------------------------------------------
    localparam ADDR_LEN       = 64;
    localparam ADDR_WIDTH     = alt_clogb2(ADDR_LEN);
generate
if (USE_I2C) begin:g_use_i2c
    wire        waitrequest;
    wire  [7:0] address;
    wire        write;
    wire  [7:0] writedata;
    wire        read;
    wire  [7:0] readdata;
    wire        readvalid;

    altera_usb_debug_i2c #(
        .DEVICE_FAMILY  (DEVICE_FAMILY),
        .I2CADDR        (I2CADDR)
    )i2c(
        .scl            (fpga_scl),
        .sda            (fpga_sda),

        .clk            (fpga_clk),
        .arst           (~fpga_arst_n),             //!!! not mgmt_reset[0]
        .waitrequest    (waitrequest),
        .address        (address),
        .write          (write),
        .writedata      (writedata),
        .read           (read),
        .readdata       (readdata),
        .readvalid      (readvalid)
    );
    altera_usb_debug_i2c_slave #(
        .DEVICE_FAMILY  (DEVICE_FAMILY),
        .ADDR_LEN       (ADDR_LEN),
        .PURPOSE        (PURPOSE),
        .RAM_FILE       (I2C_RAM_FILE),
        .NUM_MGMT_CHANNELBITS (NUM_MGMT_CHANNELBITS),
        .NUM_MGMT_DATABITS    (NUM_MGMT_DATABITS)
    )i2c_slave(
        .clk            (fpga_clk),
        .arst           (~fpga_arst_n),            //!!! not mgmt_reset[0]
        .waitrequest    (waitrequest),
        .address        (address[0+:ADDR_WIDTH]),
        .write          (write),
        .writedata      (writedata),
        .read           (read),
        .readdata       (readdata),
        .readvalid      (readvalid),

        .mgmt_detect    (fpga_mgmt_detect),
        .mgmt_reset     (fpga_mgmt_reset),
        .mgmt_flush     (fpga_mgmt_flush),
        .mgmt_level0    ((usbout_level[FIFO_DEPTH_WIDTH:8])? 8'hff : usbout_level[0+:8]),
        .mgmt_level1    ((usbin_level[FIFO_DEPTH_WIDTH:8]) ? 8'hff : usbin_level[0+:8]),
        .mgmt_valid     (fpga_mgmt_valid),
        .mgmt_channel   (fpga_mgmt_channel),
        .mgmt_data      (fpga_mgmt_data),
        .sense_reset    (sense_reset)
    );
end
else begin:g_no_i2c
    assign fpga_scl = 1'bz;
    assign fpga_sda = 1'bz;
end
endgenerate
//----------------------------------------------------------------------------
generate
if (ENABLE_LOOPBACK) begin:g_enable_loopback
    altera_usb_debug_prbs8 prbs8(
        .in_prbs    (avst_src_data1),
        .out_prbs   (avst_src_data2)
    );

    assign avst_src_ready1  = (av_loopback) ? avst_sink_ready1 : avst_src_ready;
    assign avst_src_valid   = (av_loopback) ? 1'b0             : avst_src_valid1;
    assign avst_src_data    =                                    avst_src_data1;

    assign avst_sink_ready  = (av_loopback) ? 1'b0             : avst_sink_ready1;
    assign avst_sink_valid1 = (av_loopback) ? avst_src_valid1  : avst_sink_valid;
    assign avst_sink_data1  = (av_loopback) ? avst_src_data2   : avst_sink_data;
end
else begin:g_disable_loopback
    assign avst_src_ready1  = avst_src_ready;
    assign avst_src_valid   = avst_src_valid1;
    assign avst_src_data    = avst_src_data1;

    assign avst_sink_ready  = avst_sink_ready1;
    assign avst_sink_valid1 = avst_sink_valid;
    assign avst_sink_data1  = avst_sink_data;
end
endgenerate
//----------------------------------------------------------------------------
endmodule
