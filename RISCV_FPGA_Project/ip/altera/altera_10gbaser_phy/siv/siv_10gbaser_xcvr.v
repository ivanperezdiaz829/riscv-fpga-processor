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


// (C) 2001-2010 Altera Corporation. All rights reserved.
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

//this is the top level of siv 10gbaser PHY: it include PCS, PMA, PMA controller, reset controller is separated into each sub module. 
//It decode the mgmt according to memory map aggrement.
module siv_10gbaser_xcvr #(
        parameter num_channels = 4,   // define the channel numbers
        parameter sys_clk_in_mhz = 50, //system clock for the avalone interface. It is limited by reconfig speed. This parameter will affact the reset hold time.
        parameter starting_channel_number = 0, //physical start channel number, useful in SIV
        parameter ref_clk_freq = "322.265625 MHz", // support both 322.265625 MHz, 644.53125 MHz
        parameter pll_type = "AUTO",     // PLL type for each PLL
        parameter tx_termination = "OCT_85_OHMS", //Select the Transmitter termination resistance
        parameter tx_common_mode = "0.65V",//
        parameter tx_preemp_pretap = 0,//Select the Pre-emphasis pre-tap setting 0-7
        parameter tx_preemp_pretap_inv = 0,//0/1. Determine whether the pre-emphasis control signal for the pretap needed to be inverted or not.?true? ? Invert the pre-emphasis control signal for the pre tap.?false? ? Do not invert the pre-emphasis control signal for the pretap.
        parameter tx_preemp_tap_1 = 5,//0-15 Select the Pre-emphasis first post-tap setting
        parameter tx_preemp_tap_2 = 0,//0-7 Select the Pre-emphasis second post-tap setting
        parameter tx_preemp_tap_2_inv = 0,//0/1.Select the Pre-emphasis second post-tap polarity setting
        parameter tx_vod_selection = 1,//0-7 Select the Transitter VOD control setting
        parameter rx_termination = "OCT_100_OHMS", //OCT_85_OHMS,OCT_100_OHMS,OCT_120_OHMS,OCT_150_OHMS  Select the Receiver termination resistance                    
        parameter rx_common_mode = "0.82v",
        parameter rx_eq_dc_gain = 0, //0-4 Select the Receiver DC gain                                       
        parameter rx_eq_ctrl = 14,//0-16   Select the Receiver static equalizer setting 
        parameter high_precision_latadj = 1, // latency_adj port width
        parameter latadj_width          = 16, // latency_adj port width
        parameter reconfig_interfaces = 1  // reconfiger interface = num_channels/4 for SIV
)(
        input wire                                  mgmt_clk, //         mgmt_clk.clk
        input wire                                  mgmt_clk_rstn, //     mgmt_clk_rst.reset_n
        input wire                                  mgmt_read, //         phy_mgmt.read
        input wire                                  mgmt_write, //                 .write
        input wire [7:0]                            mgmt_address, //                 .address
        input wire [31:0]                           mgmt_writedata, //                 .writedata
        output wire [31:0]                          mgmt_readdata, //                 .readdata
        output wire                                 mgmt_waitrequest, //                 .waitrequest
        input wire                                  xgmii_tx_clk, //     xgmii_tx_clk.clk
        input wire                                  pll_ref_clk, //      pll_ref_clk.clk
        output wire                                 xgmii_rx_clk, //     xgmii_rx_clk.clk

        output wire                                 tx_ready, //         tx_ready.data
        output wire                                 rx_ready, //        rx_ready0.data
        output wire [num_channels -1 : 0]           block_lock, //output indicate rx tested block_lock  
        output wire [num_channels -1 : 0]           hi_ber, //output indicate rx tested hi bit error
        output wire [num_channels -1 : 0]           rx_recovered_clk,
        output wire [num_channels -1 : 0]           rx_data_ready, 
        input wire                                  cal_blk_clk, //calibration block clock
        input wire [72*num_channels -1 : 0]         xgmii_tx_dc, //    xgmii_tx_dc_0.data
        output wire [72*num_channels -1 : 0]        xgmii_rx_dc, //    xgmii_rx_dc_0.data
        output wire [num_channels -1 : 0]           tx_serial_data, // tx_serial_data_0.export
        input wire [num_channels -1 : 0]            rx_serial_data, // rx_serial_data_0.export
        input wire [3:0]                            reconfig_to_gxb,
        output wire [reconfig_interfaces * 17 -1:0] reconfig_from_gxb,

        output wire [latadj_width*num_channels-1:0] tx_latency_adj,
        output wire [latadj_width*num_channels-1:0] rx_latency_adj

        );
localparam rx_analog_reset_hold_time = sys_clk_in_mhz * 4; //rx_analog_reset_hold_time, recommand 4us
localparam pll_reset_hold_time = sys_clk_in_mhz; //pll_reset_hold_time, recommand 1us


wire tx_pll_locked;             
wire [num_channels -1 : 0]rx_is_lockedtodata;
wire [num_channels -1 : 0]rx_is_lockedtoref;

wire [num_channels * 40 -1 : 0]pma_parallel_rx_data;
wire [num_channels * 40 -1 : 0]pma_parallel_tx_data;

wire reset_controller_pll_powerdown;
wire reset_controller_tx_digitalreset;
wire reset_controller_rx_analogreset;
wire reset_controller_rx_digitalreset;

wire [num_channels -1 : 0] csr_pll_powerdown;
wire [num_channels -1 : 0] csr_tx_digitalreset;
wire [num_channels -1 : 0] csr_rx_analogreset;
wire [num_channels -1 : 0] csr_rx_digitalreset;
wire [num_channels -1 : 0] csr_reset_tx_digital;
wire [num_channels -1 : 0] csr_reset_rx_digital;
wire csr_reset_all ;            // power-up to 1 to trigger auto-init sequence

wire [num_channels -1 : 0]rx_pma_clk;           
wire [num_channels -1 : 0]tx_pma_clk;           



wire enable_pma_ctrl;
wire enable_pcs ;
wire enable_ch;
wire enable_pcs_pma;
wire  [31:0]pma_mgmt_writedata;
wire  [31:0]pma_mgmt_readdata;
wire  [1:0]pma_mgmt_address;
wire  pma_mgmt_read;
wire  pma_mgmt_write;

wire  [31:0]pcs_pma_mgmt_writedata;
wire  [7:0]pcs_pma_mgmt_address;
wire  pcs_pma_mgmt_read ;
wire  pcs_pma_mgmt_write; 
wire  [31:0]pcs_pma_mgmt_readdata ;

wire pma_controller_cal_blk_pdn ; 
wire pma_controller_gxb_pdn;
wire tx_pma_ready;
wire rx_pma_ready;
wire tx_pll_pdn;


//instiatiate pcs, pma, pcs map block
siv_10gbaser_pcs_pma_map  #(
.num_channels           (num_channels),
.sys_clk_in_mhz         (sys_clk_in_mhz),
.starting_channel_number        (starting_channel_number),
.ref_clk_freq   (ref_clk_freq),
.pll_type       (pll_type),
.tx_termination         (tx_termination),
.tx_common_mode         (tx_common_mode),
.tx_preemp_pretap       (tx_preemp_pretap ),
.tx_preemp_pretap_inv   (tx_preemp_pretap_inv ),//?TRUE? or ?FALSE?. Determine whether the pre-emphasis control signal for the pretap needed to be inverted or not.?true? ? Invert the pre-emphasis control signal for the pre tap.?false? ? Do not invert the pre-emphasis control signal for the pretap.
.tx_preemp_tap_1        (tx_preemp_tap_1 ),//0-15
.tx_preemp_tap_2        (tx_preemp_tap_2 ),//0-7
.tx_preemp_tap_2_inv    (tx_preemp_tap_2_inv ),//?TRUE? or ?FALSE?.
.tx_vod_selection       (tx_vod_selection ),//0-7
.rx_termination         (rx_termination ), //OCT_85_OHMS,OCT_100_OHMS,OCT_120_OHMS,OCT_150_OHMS                      
.rx_common_mode         (rx_common_mode),
.rx_eq_dc_gain          (rx_eq_dc_gain ), //0-4                                        
.rx_eq_ctrl             (rx_eq_ctrl),//0-16
.high_precision_latadj  (high_precision_latadj),
.latadj_width           (latadj_width),
.reconfig_interfaces (reconfig_interfaces)
)pcs_pma_inst(
.mgmt_clk       (mgmt_clk),              //         mgmt_clk.clk
.mgmt_clk_rstn  (mgmt_clk_rstn),                //     mgmt_clk_rst.reset_n
.mgmt_read      (pcs_pma_mgmt_read),             //         phy_mgmt.read
.mgmt_write     (pcs_pma_mgmt_write),            //                 .write
.mgmt_address   (pcs_pma_mgmt_address),          //                 .address
.mgmt_writedata (pcs_pma_mgmt_writedata),        //                 .writedata
.mgmt_readdata  (pcs_pma_mgmt_readdata),         //                 .readdata
.mgmt_waitrequest(),     //                 .waitrequest
.xgmii_tx_clk   (xgmii_tx_clk),          //     xgmii_tx_clk.clk
.pll_ref_clk    (pll_ref_clk),           //      pll_ref_clk.clk
.xgmii_rx_clk   (xgmii_rx_clk),          //     xgmii_rx_clk.clk
.rx_oc_busy     (reconfig_to_gxb[3]),                   // RX channel offset cancellation status
.tx_ready       (tx_ready),              //         tx_ready.data
.rx_ready       (rx_ready),                     //        rx_ready0.data
.rx_recovered_clk(rx_recovered_clk),
.rx_data_ready   (rx_data_ready),
.block_lock     ( block_lock),          
.hi_ber         ( hi_ber),              
.xgmii_tx_dc    (xgmii_tx_dc),          //    xgmii_tx_dc_0.data
.xgmii_rx_dc    (xgmii_rx_dc),          //    xgmii_rx_dc_0.data
.tx_serial_data ( tx_serial_data),      // tx_serial_data_0.export
.rx_serial_data (rx_serial_data),       // rx_serial_data_0.export
.reconfig_to_gxb(reconfig_to_gxb),
.reconfig_from_gxb( reconfig_from_gxb),
.pma_controller_gxb_pdn(pma_controller_gxb_pdn),
.tx_pll_locked  (tx_pll_locked),
.tx_pll_pdn     (tx_pll_pdn),
.cal_blk_clk    (cal_blk_clk), //calibration block clock
.pma_controller_cal_blk_pdn     (pma_controller_cal_blk_pdn),
.tx_latency_adj(tx_latency_adj),
.rx_latency_adj(rx_latency_adj)
);

//instiate pma ctroller block
        alt_pma_controller_tgx #(
                .number_of_plls(1),
                .sync_depth(3),
                .tx_pll_reset_hold_time(pll_reset_hold_time)
        ) alt_pma_controller_tgx_i (
                .cal_blk_clk    (mgmt_clk),
                .gx_pdn (pma_controller_gxb_pdn),
                .clk    (mgmt_clk),
                .rst    (!mgmt_clk_rstn),
                .pma_mgmt_writedata     (pma_mgmt_writedata),
                .pma_mgmt_readdata      (pma_mgmt_readdata),
                .pma_mgmt_waitrequest   (),
                .pma_mgmt_address       (pma_mgmt_address),
                .pma_mgmt_read  (pma_mgmt_read),
                .pma_mgmt_write (pma_mgmt_write),
                .pll_locked     (tx_pll_locked),
                .pll_pdn        (tx_pll_pdn),
                .cal_blk_pdn    (pma_controller_cal_blk_pdn),
                .tx_pll_ready   ()
        );

assign enable_pma_ctrl = (!mgmt_address[7]) & (!mgmt_address[6]) & mgmt_address[5];//080 shift 2 bit at lsb
assign enable_pcs = (mgmt_address[7]) & !(mgmt_address[6]) & !(mgmt_address[5]);//200 shift 2 bits at the lsb
assign enable_ch = (!mgmt_address[7]) & (mgmt_address[6]);//180 shift 2 bits at lsb     
assign enable_pcs_pma = enable_pcs | enable_ch;

assign pma_mgmt_writedata = mgmt_writedata;
assign pma_mgmt_address = mgmt_address[1:0];
assign pma_mgmt_read = enable_pma_ctrl & mgmt_read;
assign pma_mgmt_write = enable_pma_ctrl & mgmt_write;

assign pcs_pma_mgmt_writedata = mgmt_writedata;
assign pcs_pma_mgmt_address     = mgmt_address[7:0];
assign pcs_pma_mgmt_read = enable_pcs_pma & mgmt_read;
assign pcs_pma_mgmt_write = enable_pcs_pma & mgmt_write;

assign mgmt_readdata = (pma_mgmt_readdata & {32{pma_mgmt_read & !mgmt_waitrequest}}) | (pcs_pma_mgmt_readdata & {32{pcs_pma_mgmt_read & !mgmt_waitrequest}}) ;

//waite generate, in read command, sub module will get data 1 clock later.
altera_wait_generate wait_gen(
 .rst(!mgmt_clk_rstn),
.clk(mgmt_clk),
.launch_signal(mgmt_read),
.wait_req(mgmt_waitrequest)
 );


endmodule
