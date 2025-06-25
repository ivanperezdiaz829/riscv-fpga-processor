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
module alt_e40_avalon_kr4_tb ();

`include "dynamic_parameters.v"

parameter WORDS = 4;//Don't change

localparam NUM_LANES = 4;
localparam NUM_VLANES = 4;

reg fail = 1'b0;

// no domain
reg mac_rx_arst_ST = 1'b0;
reg mac_tx_arst_ST = 1'b0;
reg pcs_rx_arst_ST = 1'b0;
reg pcs_tx_arst_ST = 1'b0;
reg pma_arst_ST = 1'b0;

reg clk_din = 1'b0;
wire clk_txmac;
wire clk_rxmac;
wire clk_txfifo;
wire clk_rxfifo;
reg clk_ref = 1'b0;

// status register bus
reg clk_status = 1'b0;
reg [15:0] status_addr = 16'h0;
reg status_read_1 = 1'b0;
reg status_read_2 = 1'b0;
reg status_write_1 = 1'b0;
reg status_write_2 = 1'b0;
reg [31:0] status_writedata = 32'b0;
reg [31:0] request_writedata = 32'b0;
wire [31:0] status_readdata_1;
wire [31:0] status_readdata_2;
wire status_readdata_valid_1;
wire status_readdata_valid_2;

// input domain (from user toward pins)
wire   [WORDS*64-1:0] l4_tx_data_1;
wire   [4  :0]        l4_tx_empty_1;
wire                  l4_tx_startofpacket_1;
wire                  l4_tx_endofpacket_1;
wire                  l4_tx_ready_1;
reg                   l4_tx_valid_1 = 1'b1;

wire   [WORDS*64-1:0] l4_tx_data_2;
wire   [4  :0]        l4_tx_empty_2;
wire                  l4_tx_startofpacket_2;
wire                  l4_tx_endofpacket_2;
wire                  l4_tx_ready_2;
reg                   l4_tx_valid_2 = 1'b1;

wire                  txfifo_wrfull;
wire   [15:0]         txfifo_wrusedw;

// output domain (from pins toward user)
wire   [WORDS*64-1:0] l4_rx_data_1;
wire   [4  :0]        l4_rx_empty_1;
wire                  l4_rx_startofpacket_1;
wire                  l4_rx_endofpacket_1;
wire                  l4_rx_error_1;
wire                  l4_rx_valid_1;
wire                  l4_rx_fcs_valid_1;
wire                  l4_rx_fcs_error_1;

wire   [WORDS*64-1:0] l4_rx_data_2;
wire   [4  :0]        l4_rx_empty_2;
wire                  l4_rx_startofpacket_2;
wire                  l4_rx_endofpacket_2;
wire                  l4_rx_error_2;
wire                  l4_rx_valid_2;
wire                  l4_rx_fcs_valid_2;
wire                  l4_rx_fcs_error_2;
	
wire                  rxfifo_wrfull;
wire   [15:0]         rxfifo_rdusedw;
wire                  rxfifo_empty;

//serdes
wire [NUM_LANES-1:0] rx_serial_1;
wire [NUM_LANES-1:0] tx_serial_1;

wire [NUM_LANES-1:0] rx_serial_2;
wire [NUM_LANES-1:0] tx_serial_2;

// pause generation
reg         pause_insert_tx_1 = 1'b0;      // generate pause
reg  [15:0] pause_insert_time_1 = 16'h10;  // generated pause time
reg         pause_insert_mcast_1 = 1'b0;   // generate mcast pause
reg  [47:0] pause_insert_dst_1 = 48'b0;    // generated pause destination addr
reg  [47:0] pause_insert_src_1 = 48'h0;    // generated pause source addr

reg         pause_insert_tx_2 = 1'b0;      // generate pause
reg  [15:0] pause_insert_time_2 = 16'h10;  // generated pause time
reg         pause_insert_mcast_2 = 1'b0;   // generate mcast pause
reg  [47:0] pause_insert_dst_2 = 48'b0;    // generated pause destination addr
reg  [47:0] pause_insert_src_2 = 48'h0;    // generated pause source addr

/////////////////////////////////
// Memory Map Register R/W Handler
/////////////////////////////////

localparam ST_INIT            = 2'b00;
localparam ST_REGULAR_POLLING = 2'b01;
localparam ST_REFRESH_CNTR    = 2'b10;
localparam ST_WRITE_REQUEST   = 2'b11;

reg [1:0] handler_state = ST_INIT;
reg handler_start = 1'b0;

reg refresh_cntr  = 1'b0;
wire refreshing_cntr = (handler_state == ST_REFRESH_CNTR);

reg write_request_1 = 1'b0;
reg write_request_2 = 1'b0;
wire handling_write_request = (handler_state == ST_WRITE_REQUEST);

// regular polling registers
wire [11*10-1:0] rp_addr_lst = {
					10'hd2,     // LT status
					10'hc2,     // AN status
					10'hb1,     // KR status
					10'h10,		//io_locks
					10'h22b,    //CNTR_TX_ST_HI
					10'h22a,    //CNTR_TX_ST_LO
					10'h17,		//phy_hw_err
					10'h16,		//bip_err
					10'h15,		//framing_err
					10'h14,		//rx_aggregate
					10'h13		//am_locks
					};
reg [11*32-1:0] rp_data_lst_1 = 0;
reg [11*32-1:0] rp_data_lst_2 = 0;
int rp_index = 0;

wire [NUM_LANES-1:0] lt_lock_error_1;
wire [NUM_LANES-1:0] lt_error_1;
wire [NUM_LANES-1:0] lt_failure_1;
wire [NUM_LANES-1:0] lt_start_up_1;
wire [NUM_LANES-1:0] lt_frame_lock_1;
wire [NUM_LANES-1:0] lt_trained_1;
assign lt_lock_error_1[3]             = rp_data_lst_1[10*32 + 29];
assign lt_error_1[3]                  = rp_data_lst_1[10*32 + 28];
assign lt_failure_1[3]                = rp_data_lst_1[10*32 + 27];
assign lt_start_up_1[3]               = rp_data_lst_1[10*32 + 26];
assign lt_frame_lock_1[3]             = rp_data_lst_1[10*32 + 25];
assign lt_trained_1[3]                = rp_data_lst_1[10*32 + 24];
assign lt_lock_error_1[2]             = rp_data_lst_1[10*32 + 21];
assign lt_error_1[2]                  = rp_data_lst_1[10*32 + 20];
assign lt_failure_1[2]                = rp_data_lst_1[10*32 + 19];
assign lt_start_up_1[2]               = rp_data_lst_1[10*32 + 18];
assign lt_frame_lock_1[2]             = rp_data_lst_1[10*32 + 17];
assign lt_trained_1[2]                = rp_data_lst_1[10*32 + 16];
assign lt_lock_error_1[1]             = rp_data_lst_1[10*32 + 13];
assign lt_error_1[1]                  = rp_data_lst_1[10*32 + 12];
assign lt_failure_1[1]                = rp_data_lst_1[10*32 + 11];
assign lt_start_up_1[1]               = rp_data_lst_1[10*32 + 10];
assign lt_frame_lock_1[1]             = rp_data_lst_1[10*32 + 9];
assign lt_trained_1[1]                = rp_data_lst_1[10*32 + 8];
assign lt_lock_error_1[0]             = rp_data_lst_1[10*32 + 5];
assign lt_error_1[0]                  = rp_data_lst_1[10*32 + 4];
assign lt_failure_1[0]                = rp_data_lst_1[10*32 + 3];
assign lt_start_up_1[0]               = rp_data_lst_1[10*32 + 2];
assign lt_frame_lock_1[0]             = rp_data_lst_1[10*32 + 1];
assign lt_trained_1[0]                = rp_data_lst_1[10*32 + 0];
wire [5:0] an_link_mode_1             = rp_data_lst_1[ 9*32 + 12 +:6];
wire an_failure_1                     = rp_data_lst_1[ 9*32 + 9];
wire an_fec_neg_1                     = rp_data_lst_1[ 9*32 + 8];
wire an_lp_able_1                     = rp_data_lst_1[ 9*32 + 7];
wire an_link_up_1                     = rp_data_lst_1[ 9*32 + 6];
wire an_able_1                        = rp_data_lst_1[ 9*32 + 5];
wire an_rx_idle_1                     = rp_data_lst_1[ 9*32 + 4];
wire an_adv_rf_1                      = rp_data_lst_1[ 9*32 + 3];
wire an_complete_1                    = rp_data_lst_1[ 9*32 + 2];
wire an_page_recv_1                   = rp_data_lst_1[ 9*32 + 1];
wire kr_fec_err_ind_abl_1             = rp_data_lst_1[ 8*32 + 17];
wire kr_fec_abl_1                     = rp_data_lst_1[ 8*32 + 16];
wire [5:0] kr_reco_mode_1             = rp_data_lst_1[ 8*32 + 8 +:6];
wire kr_an_timeout_1                  = rp_data_lst_1[ 8*32 + 1];
wire kr_link_ready_1                  = rp_data_lst_1[ 8*32 + 0];
wire pma_tx_ready_1                   = rp_data_lst_1[ 7*32 + 1];
wire pma_rx_ready_1                   = rp_data_lst_1[ 7*32 + 0];
wire [63:0] tx_start_cnt_rp_1         = rp_data_lst_1[ 5*32 +:64];   // number of frame starts sent
wire deskew_failure_1                 = rp_data_lst_1[ 4*32 + 6 ];   // skew exceedes capability - automatic retry
wire [NUM_VLANES-1:0] bip_error_1     = rp_data_lst_1[ 3*32 +: NUM_VLANES];   // pulse, VLANE parity error
wire [NUM_VLANES-1:0] framing_error_1 = rp_data_lst_1[ 2*32 +: NUM_VLANES];   // pulse, incorrect 64-66 framing
wire lanes_deskewed_1                 = rp_data_lst_1[ 1*32 + 1 ];   // lane to lane skew corrected
wire all_locked_1                     = rp_data_lst_1[ 1*32 + 0 ];   // all lanes word and marker locked
wire [NUM_VLANES-1:0] am_locked_1     = rp_data_lst_1[ 0*32 +: NUM_VLANES];   // vlane alignment marker lock

wire [NUM_LANES-1:0] lt_lock_error_2;
wire [NUM_LANES-1:0] lt_error_2;
wire [NUM_LANES-1:0] lt_failure_2;
wire [NUM_LANES-1:0] lt_start_up_2;
wire [NUM_LANES-1:0] lt_frame_lock_2;
wire [NUM_LANES-1:0] lt_trained_2;
assign lt_lock_error_2[3]             = rp_data_lst_2[10*32 + 29];
assign lt_error_2[3]                  = rp_data_lst_2[10*32 + 28];
assign lt_failure_2[3]                = rp_data_lst_2[10*32 + 27];
assign lt_start_up_2[3]               = rp_data_lst_2[10*32 + 26];
assign lt_frame_lock_2[3]             = rp_data_lst_2[10*32 + 25];
assign lt_trained_2[3]                = rp_data_lst_2[10*32 + 24];
assign lt_lock_error_2[2]             = rp_data_lst_2[10*32 + 21];
assign lt_error_2[2]                  = rp_data_lst_2[10*32 + 20];
assign lt_failure_2[2]                = rp_data_lst_2[10*32 + 19];
assign lt_start_up_2[2]               = rp_data_lst_2[10*32 + 18];
assign lt_frame_lock_2[2]             = rp_data_lst_2[10*32 + 17];
assign lt_trained_2[2]                = rp_data_lst_2[10*32 + 16];
assign lt_lock_error_2[1]             = rp_data_lst_2[10*32 + 13];
assign lt_error_2[1]                  = rp_data_lst_2[10*32 + 12];
assign lt_failure_2[1]                = rp_data_lst_2[10*32 + 11];
assign lt_start_up_2[1]               = rp_data_lst_2[10*32 + 10];
assign lt_frame_lock_2[1]             = rp_data_lst_2[10*32 + 9];
assign lt_trained_2[1]                = rp_data_lst_2[10*32 + 8];
assign lt_lock_error_2[0]             = rp_data_lst_2[10*32 + 5];
assign lt_error_2[0]                  = rp_data_lst_2[10*32 + 4];
assign lt_failure_2[0]                = rp_data_lst_2[10*32 + 3];
assign lt_start_up_2[0]               = rp_data_lst_2[10*32 + 2];
assign lt_frame_lock_2[0]             = rp_data_lst_2[10*32 + 1];
assign lt_trained_2[0]                = rp_data_lst_2[10*32 + 0];
wire [5:0] an_link_mode_2             = rp_data_lst_2[ 9*32 + 12 +:6];
wire an_failure_2                     = rp_data_lst_2[ 9*32 + 9];
wire an_fec_neg_2                     = rp_data_lst_2[ 9*32 + 8];
wire an_lp_able_2                     = rp_data_lst_2[ 9*32 + 7];
wire an_link_up_2                     = rp_data_lst_2[ 9*32 + 6];
wire an_able_2                        = rp_data_lst_2[ 9*32 + 5];
wire an_rx_idle_2                     = rp_data_lst_2[ 9*32 + 4];
wire an_adv_rf_2                      = rp_data_lst_2[ 9*32 + 3];
wire an_complete_2                    = rp_data_lst_2[ 9*32 + 2];
wire an_page_recv_2                   = rp_data_lst_2[ 9*32 + 1];
wire kr_fec_err_ind_abl_2             = rp_data_lst_2[ 8*32 + 17];
wire kr_fec_abl_2                     = rp_data_lst_2[ 8*32 + 16];
wire [5:0] kr_reco_mode_2             = rp_data_lst_2[ 8*32 + 8 +:6];
wire kr_an_timeout_2                  = rp_data_lst_2[ 8*32 + 1];
wire kr_link_ready_2                  = rp_data_lst_2[ 8*32 + 0];
wire pma_tx_ready_2                   = rp_data_lst_2[ 7*32 + 1];
wire pma_rx_ready_2                   = rp_data_lst_2[ 7*32 + 0];
wire [63:0] tx_start_cnt_rp_2         = rp_data_lst_2[ 5*32 +:64];   // number of frame starts sent
wire deskew_failure_2                 = rp_data_lst_2[ 4*32 + 6 ];   // skew exceedes capability - automatic retry
wire [NUM_VLANES-1:0] bip_error_2     = rp_data_lst_2[ 3*32 +: NUM_VLANES];   // pulse, VLANE parity error
wire [NUM_VLANES-1:0] framing_error_2 = rp_data_lst_2[ 2*32 +: NUM_VLANES];   // pulse, incorrect 64-66 framing
wire lanes_deskewed_2                 = rp_data_lst_2[ 1*32 + 1 ];   // lane to lane skew corrected
wire all_locked_2                     = rp_data_lst_2[ 1*32 + 0 ];   // all lanes word and marker locked
wire [NUM_VLANES-1:0] am_locked_2     = rp_data_lst_2[ 0*32 +: NUM_VLANES];   // vlane alignment marker lock

// refreshing counters
wire [21*10-1:0] rc_addr_lst = {
					10'hbd,     // FEC uncorr lane 3
					10'hbc,     // FEC corr lane 3
					10'hba,     // FEC uncorr lane 2
					10'hb9,     // FEC corr lane 2
					10'hb7,     // FEC uncorr lane 1
					10'hb6,     // FEC corr lane 1
					10'hb4,     // FEC uncorr lane 0
					10'hb3,     // FEC corr lane 0
					10'h2b8,	//CNTR_RX_FCS
					10'h2b6,	//CNTR_RX_RUNT
					10'h2b4,	//CNTR_RX_EBLK
					10'h2b1,	//CNTR_RXF_DB_HI
					10'h2b0,	//CNTR_RXF_DB_LO
					10'h2af,	//CNTR_RXF_ST_HI
					10'h2ae,	//CNTR_RXF_ST_LO
					10'h2ad,	//CNTR_RX_DB_HI
					10'h2ac,	//CNTR_RX_DB_LO
					10'h2ab,	//CNTR_RX_ST_HI
					10'h2aa,	//CNTR_RX_ST_LO
					10'h22b,    //CNTR_TX_ST_HI
					10'h22a     //CNTR_TX_ST_LO
					};
reg [21*32-1:0] rc_data_lst_1 = 0;
reg [21*32-1:0] rc_data_lst_2 = 0;
int rc_index = 0;

wire [31:0] fec_uncorr_l3_1    = rc_data_lst_1[21*32 -1 -:32];
wire [31:0] fec_corr_l3_1      = rc_data_lst_1[20*32 -1 -:32];
wire [31:0] fec_uncorr_l2_1    = rc_data_lst_1[19*32 -1 -:32];
wire [31:0] fec_corr_l2_1      = rc_data_lst_1[18*32 -1 -:32];
wire [31:0] fec_uncorr_l1_1    = rc_data_lst_1[17*32 -1 -:32];
wire [31:0] fec_corr_l1_1      = rc_data_lst_1[16*32 -1 -:32];
wire [31:0] fec_uncorr_l0_1    = rc_data_lst_1[15*32 -1 -:32];
wire [31:0] fec_corr_l0_1      = rc_data_lst_1[14*32 -1 -:32];
wire [31:0] fcs_error_cnt_1    = rc_data_lst_1[13*32 -1 -:32];   // CRC 32 errors
wire [31:0] runt_cnt_1         = rc_data_lst_1[12*32 -1 -:32];   // packets < 64 byte long
wire [31:0] rx_err_block_cnt_1 = rc_data_lst_1[11*32 -1 -:32];   // MII decode to error blocks
wire [63:0] rx_acc_dblk_cnt_1  = rc_data_lst_1[10*32 -1 -:64];   // number of data blocks received + accepted
wire [63:0] rx_acc_start_cnt_1 = rc_data_lst_1[ 8*32 -1 -:64];   // number of fram starts received + accepted
wire [63:0] rx_dblk_cnt_1      = rc_data_lst_1[ 6*32 -1 -:64];   // number of data blocks received
wire [63:0] rx_start_cnt_1     = rc_data_lst_1[ 4*32 -1 -:64];   // number of fram starts received
wire [63:0] tx_start_cnt_1     = rc_data_lst_1[ 2*32 -1 -:64];   // number of frame starts sent

wire [31:0] fec_uncorr_l3_2    = rc_data_lst_2[21*32 -1 -:32];
wire [31:0] fec_corr_l3_2      = rc_data_lst_2[20*32 -1 -:32];
wire [31:0] fec_uncorr_l2_2    = rc_data_lst_2[19*32 -1 -:32];
wire [31:0] fec_corr_l2_2      = rc_data_lst_2[18*32 -1 -:32];
wire [31:0] fec_uncorr_l1_2    = rc_data_lst_2[17*32 -1 -:32];
wire [31:0] fec_corr_l1_2      = rc_data_lst_2[16*32 -1 -:32];
wire [31:0] fec_uncorr_l0_2    = rc_data_lst_2[15*32 -1 -:32];
wire [31:0] fec_corr_l0_2      = rc_data_lst_2[14*32 -1 -:32];
wire [31:0] fcs_error_cnt_2    = rc_data_lst_2[13*32 -1 -:32];   // CRC 32 errors
wire [31:0] runt_cnt_2         = rc_data_lst_2[12*32 -1 -:32];   // packets < 64 byte long
wire [31:0] rx_err_block_cnt_2 = rc_data_lst_2[11*32 -1 -:32];   // MII decode to error blocks
wire [63:0] rx_acc_dblk_cnt_2  = rc_data_lst_2[10*32 -1 -:64];   // number of data blocks received + accepted
wire [63:0] rx_acc_start_cnt_2 = rc_data_lst_2[ 8*32 -1 -:64];   // number of fram starts received + accepted
wire [63:0] rx_dblk_cnt_2      = rc_data_lst_2[ 6*32 -1 -:64];   // number of data blocks received
wire [63:0] rx_start_cnt_2     = rc_data_lst_2[ 4*32 -1 -:64];   // number of fram starts received
wire [63:0] tx_start_cnt_2     = rc_data_lst_2[ 2*32 -1 -:64];   // number of frame starts sent

reg [15:0] wr_addr = 16'h0;
reg print_cntr_value = 1'b0;
reg clr_history = 1'b0;
reg done_1, done_2;

// handler FSM
always @ (negedge clk_status) begin
print_cntr_value <= 1'b0;
case (handler_state)
	ST_INIT:
	if (handler_start)
		begin
			status_addr <= {6'h00, rp_addr_lst[rp_index*10+9 -: 10]};
			status_read_1 <= 1'b1;
			status_read_2 <= 1'b1;
			done_1 <= 1'b0;
			done_2 <= 1'b0;
			handler_state <= ST_REGULAR_POLLING;
		end
	ST_REGULAR_POLLING:
	begin
		if ( status_readdata_valid_1 ) begin
			// $display ("status_addr: %h, status_readdata_1; %h", status_addr, status_readdata_1);
			rp_data_lst_1 [rp_index*32+31 -: 32] <= status_readdata_1;
			done_1 <= 1'b1;
		end
		else begin
			status_read_1 <= 1'b0;
		end
		
		if ( status_readdata_valid_2 ) begin
			// $display ("status_addr: %h, status_readdata_2; %h", status_addr, status_readdata_2);
			rp_data_lst_2 [rp_index*32+31 -: 32] <= status_readdata_2;
			done_2 <= 1'b1;
		end
		else begin
			status_read_2 <= 1'b0;
		end
		
		status_write_1 <= 1'b0;
		status_write_2 <= 1'b0;
		
		if(done_1 && done_2) begin
			done_1 <= 1'b0;
			done_2 <= 1'b0;
			rp_index = (rp_index == 10) ? 0 : (rp_index + 1);
			if (write_request_1) begin
				handler_state <= ST_WRITE_REQUEST;
				status_write_1  <= 1'b1;
				status_writedata <= request_writedata;
				status_addr   <= wr_addr;
			end
			else if (write_request_2) begin
				handler_state <= ST_WRITE_REQUEST;
				status_write_2  <= 1'b1;
				status_writedata <= request_writedata;
				status_addr   <= wr_addr;
			end
			else if (refresh_cntr) begin
				handler_state <= ST_REFRESH_CNTR;
				status_read_1   <= 1'b1;
				status_read_2   <= 1'b1;
				status_addr   <= {6'h00, rc_addr_lst[rc_index*10+9 -: 10]};
			end
			else begin
				status_read_1   <= 1'b1;
				status_read_2   <= 1'b1;
				status_addr   <= {6'h00, rp_addr_lst[rp_index*10+9 -: 10]};
			end
		end

		
	end
	ST_REFRESH_CNTR:
	begin
		if ( status_readdata_valid_1 ==1 ) begin
			rc_data_lst_1 [rc_index*32+31 -: 32] <= status_readdata_1;
			done_1 <= 1'b1;
		end
		else begin
			status_read_1 <= 1'b0;
		end
		
		if ( status_readdata_valid_2 ==1 ) begin
			rc_data_lst_2 [rc_index*32+31 -: 32] <= status_readdata_2;
			done_2 <= 1'b1;
		end
		else begin
			status_read_2 <= 1'b0;
		end
		
		status_write_1 <= 1'b0;
		status_write_2 <= 1'b0;
		
		if(done_1 && done_2) begin
			done_1 <= 1'b0;
			done_2 <= 1'b0;
			if (rc_index == 20) begin
				print_cntr_value <= 1'b1;
				if (write_request_1) begin
					handler_state <= ST_WRITE_REQUEST;
					status_write_1  <= 1'b1;
					status_writedata <= request_writedata;
					status_addr   <= wr_addr;
				end
				else if (write_request_2) begin
					handler_state <= ST_WRITE_REQUEST;
					status_write_2  <= 1'b1;
					status_writedata <= request_writedata;
					status_addr   <= wr_addr;
				end
				else if (refresh_cntr) begin
					status_read_1   <= 1'b1;
					status_read_2   <= 1'b1;
					status_addr   <= {6'h00, rc_addr_lst[ 9: 0]};
				end
				else begin
					handler_state <= ST_REGULAR_POLLING;
					status_read_1   <= 1'b1;
					status_read_2   <= 1'b1;
					status_addr   <= {6'h00, rp_addr_lst[rp_index*10+9 -: 10]};
				end
				rc_index = 0;
			end
			else begin
				rc_index 	   = rc_index + 1;
				status_read_1   <= 1'b1;
				status_read_2   <= 1'b1;
				status_addr   <= {6'h00, rc_addr_lst[rc_index*10+9 -: 10]};
			end
		end

	end
	ST_WRITE_REQUEST:
	begin
		if (clr_history) begin // clr_history will always assert if the handler it's writing 1 to statistics cntr clear
			rp_data_lst_1 [127 :64] <= 0;	// clear framing_err and bip_err in rp_data_lst_1
			rp_data_lst_2 [127 :64] <= 0;	// clear framing_err and bip_err in rp_data_lst_2
		end
		status_write_1  <= 1'b0;
		status_write_2  <= 1'b0;
		if (write_request_1) begin
			handler_state <= ST_WRITE_REQUEST;
			status_write_1  <= 1'b1;
			status_writedata <= request_writedata;
			status_addr   <= wr_addr;
		end
		else if (write_request_2) begin
			handler_state <= ST_WRITE_REQUEST;
			status_write_2  <= 1'b1;
			status_writedata <= request_writedata;
			status_addr   <= wr_addr;
		end
		else if (refresh_cntr) begin
			handler_state <= ST_REFRESH_CNTR;
			status_read_1   <= 1'b1;
			status_read_2   <= 1'b1;
			status_addr   <= {6'h00, rc_addr_lst[rc_index*10+9 -: 10]};
		end
		else begin
			handler_state <= ST_REGULAR_POLLING;
			status_read_1   <= 1'b1;
			status_read_2   <= 1'b1;
			status_addr   <= {6'h00, rp_addr_lst[rp_index*10+9 -: 10]};
		end
	end
endcase
end

//frame_history and bip_history
reg [NUM_VLANES-1:0] bip_history_1 = 0;
reg [NUM_VLANES-1:0] bip_history_2 = 0;
reg [NUM_VLANES-1:0] frame_history_1 = 0;
reg [NUM_VLANES-1:0] frame_history_2 = 0;

always @(posedge clk_din) begin
	if (clr_history) begin
		bip_history_1 = 0;
		bip_history_2 = 0;
		frame_history_1 = 0;
		frame_history_2 = 0;
	end
	else begin
		bip_history_1 = bip_history_1 | bip_error_1;
		bip_history_2 = bip_history_2 | bip_error_2;
		frame_history_1 = frame_history_1 | framing_error_1;
		frame_history_2 = frame_history_2 | framing_error_2;
	end
end

// display cntr
always @ (posedge clk_status)
if (print_cntr_value) begin
	$display ("Counters Refreshed, dut 1:");
	$display ("\t fcs_error_cnt_1: %d", fcs_error_cnt_1);
	$display ("\t runt_cnt_1: %d", runt_cnt_1);
	$display ("\t rx_err_block_cnt_1: %d", rx_err_block_cnt_1);
	$display ("\t rx_acc_dblk_cnt_1: %d", rx_acc_dblk_cnt_1);
	$display ("\t rx_acc_start_cnt_1: %d", rx_acc_start_cnt_1);
	$display ("\t rx_dblk_cnt_1: %d", rx_dblk_cnt_1);
	$display ("\t rx_start_cnt_1: %d", rx_start_cnt_1);
	$display ("\t tx_start_cnt_1: %d", tx_start_cnt_1);
	$display ("\t fec_corr_l0_1: %d", fec_corr_l0_1);
	$display ("\t fec_uncorr_l0_1: %d", fec_uncorr_l0_1);
	$display ("\t fec_corr_l1_1: %d", fec_corr_l1_1);
	$display ("\t fec_uncorr_l1_1: %d", fec_uncorr_l1_1);
	$display ("\t fec_corr_l2_1: %d", fec_corr_l2_1);
	$display ("\t fec_uncorr_l2_1: %d", fec_uncorr_l2_1);
	$display ("\t fec_corr_l3_1: %d", fec_corr_l3_1);
	$display ("\t fec_uncorr_l3_1: %d", fec_uncorr_l3_1);
	$display ("Counters Refreshed, dut 2:");
	$display ("\t fcs_error_cnt_2: %d", fcs_error_cnt_2);
	$display ("\t runt_cnt_2: %d", runt_cnt_2);
	$display ("\t rx_err_block_cnt_2: %d", rx_err_block_cnt_2);
	$display ("\t rx_acc_dblk_cnt_2: %d", rx_acc_dblk_cnt_2);
	$display ("\t rx_acc_start_cnt_2: %d", rx_acc_start_cnt_2);
	$display ("\t rx_dblk_cnt_2: %d", rx_dblk_cnt_2);
	$display ("\t rx_start_cnt_2: %d", rx_start_cnt_2);
	$display ("\t tx_start_cnt_2: %d", tx_start_cnt_2);
	$display ("\t fec_corr_l0_2: %d", fec_corr_l0_2);
	$display ("\t fec_uncorr_l0_2: %d", fec_uncorr_l0_2);
	$display ("\t fec_corr_l1_2: %d", fec_corr_l1_2);
	$display ("\t fec_uncorr_l1_2: %d", fec_uncorr_l1_2);
	$display ("\t fec_corr_l2_2: %d", fec_corr_l2_2);
	$display ("\t fec_uncorr_l2_2: %d", fec_uncorr_l2_2);
	$display ("\t fec_corr_l3_2: %d", fec_corr_l3_2);
	$display ("\t fec_uncorr_l3_2: %d", fec_uncorr_l3_2);
end

//Simulation Monitor
reg [8:0] monitor=0;
reg reset_monitor_cnt = 0;  // assert when wiping stats. Display the monitor values 0x30 cycles after stats_clr is written to csr.

// framing_error and bip_error self-clear their values after each read access of them
// the displayed values are the lanes with error during the period
reg [NUM_VLANES-1:0] framing_error_1_in_monitor_period = 0;
reg [NUM_VLANES-1:0] framing_error_2_in_monitor_period = 0;
reg [NUM_VLANES-1:0] bip_error_1_in_monitor_period = 0;
reg [NUM_VLANES-1:0] bip_error_2_in_monitor_period = 0;

always @ (posedge clk_status) begin
	if (reset_monitor_cnt)
		monitor <= 9'h1cf;
	else
		monitor <= monitor + 1;
	
	if (clr_history) begin
		framing_error_1_in_monitor_period = 0;
		framing_error_2_in_monitor_period = 0;
		bip_error_1_in_monitor_period = 0;
		bip_error_2_in_monitor_period = 0;
	end
	
	if (&monitor) begin
		$display ("\t+------------------------------------------------------------");
		$display ("\t| Simulation Monitor at time %d (dut 1):", $time);
		$display ("\t|\t am_locked_1: %h \tall_locked_1: %h \tlanes_deskewed_1: %h", am_locked_1[NUM_VLANES-1:0], all_locked_1, lanes_deskewed_1);
		$display ("\t|\t framing_error_1:%h \tbip_error_1: %h", framing_error_1_in_monitor_period[NUM_VLANES-1:0], bip_error_1_in_monitor_period[NUM_VLANES-1:0]);
		$display ("\t|\t deskew_failure_1: %h \tpma_rx_ready_1:%b  pma_tx_ready_1:%b", deskew_failure_1, pma_rx_ready_1, pma_tx_ready_1);
		$display ("\t|\t kr_link_ready_1: %b \tkr_an_timeout_1:%b  kr_reco_mode_1:%h", kr_link_ready_1, kr_an_timeout_1, kr_reco_mode_1);
		$display ("\t|\t an_complete_1: %b \tan_rx_idle_1:%b  an_link_up_1:%b", an_complete_1, an_rx_idle_1, an_link_up_1);
		$display ("\t|\t an_fec_neg_1: %b \tan_failure_1:%b  an_link_mode_1:%h", an_fec_neg_1, an_failure_1, an_link_mode_1);
		$display ("\t|\t lt_trained_1: %h \tlt_frame_lock_1: %h \tlt_failure_1:%h", lt_trained_1, lt_frame_lock_1, lt_failure_1);
		$display ("\t|\t lt_error_1: %h \tlt_lock_error_1: %h", lt_error_1, lt_lock_error_1);
		$display ("\t|\t Number of packets sent: %d", tx_start_cnt_rp_1[63:0] );
		$display ("\t+------------------------------------------------------------");
		$display ("\t| Simulation Monitor at time %d (dut 2):", $time);
		$display ("\t|\t am_locked_2: %h \tall_locked_2: %h \tlanes_deskewed_2: %h", am_locked_2[NUM_VLANES-1:0], all_locked_2, lanes_deskewed_2);
		$display ("\t|\t framing_error_2:%h \tbip_error_2: %h", framing_error_2_in_monitor_period[NUM_VLANES-1:0], bip_error_2_in_monitor_period[NUM_VLANES-1:0]);
		$display ("\t|\t deskew_failure_2: %h \tpma_rx_ready_2:%b  pma_tx_ready_2:%b", deskew_failure_2, pma_rx_ready_2, pma_tx_ready_2);
		$display ("\t|\t kr_link_ready_2: %b \tkr_an_timeout_2:%b  kr_reco_mode_2:%h", kr_link_ready_2, kr_an_timeout_2, kr_reco_mode_2);
		$display ("\t|\t an_complete_2: %b \tan_rx_idle_2:%b  an_link_up_2:%b", an_complete_2, an_rx_idle_2, an_link_up_2);
		$display ("\t|\t an_fec_neg_2: %b \tan_failure_2:%b  an_link_mode_2:%h", an_fec_neg_2, an_failure_2, an_link_mode_2);
		$display ("\t|\t lt_trained_2: %h \tlt_frame_lock_2: %h \tlt_failure_2:%h", lt_trained_2, lt_frame_lock_2, lt_failure_2);
		$display ("\t|\t lt_error_2: %h \tlt_lock_error_2: %h", lt_error_2, lt_lock_error_2);
		$display ("\t|\t Number of packets sent: %d", tx_start_cnt_rp_2[63:0] );
		$display ("\t+------------------------------------------------------------");
		
		framing_error_1_in_monitor_period = 0;
		framing_error_2_in_monitor_period = 0;
		bip_error_1_in_monitor_period = 0;
		bip_error_2_in_monitor_period = 0;
	end
	else begin
		framing_error_1_in_monitor_period = framing_error_1_in_monitor_period | framing_error_1;
		framing_error_2_in_monitor_period = framing_error_2_in_monitor_period | framing_error_2;
		bip_error_1_in_monitor_period = bip_error_1_in_monitor_period | bip_error_1;
		bip_error_2_in_monitor_period = bip_error_2_in_monitor_period | bip_error_2;
	end
end

/////////////////////////////////
// error injection
// injecting the error with a too high frequency will cause loss of lock
/////////////////////////////////
reg enable_errors = 1'b0;
reg [5:0] err_injection_period = 0;	// inject one bit error with the frequency of ~10GHz/1024.
reg [9:0] err_pos = 0;
reg [NUM_LANES-1:0] bit_error = 0;

always @(posedge clk_ref) begin
	err_injection_period <= err_injection_period + 1'b1;
	if (enable_errors &(&err_injection_period) )
		begin
			err_pos <= $random;
			bit_error[err_pos%NUM_LANES] <= 1'b1;
		end
	else
		begin
			bit_error <= 0;
		end
end


wire [9:0] rx_serial_1_r;
wire [9:0] rx_serial_2_r;
genvar g;
generate
for (g=0; g<NUM_LANES; g=g+1) begin : lanes_with_error
	assign rx_serial_2_r[g] = tx_serial_1[g]^bit_error[g];
	assign rx_serial_1_r[g] = tx_serial_2[g];
end
endgenerate

//////////////////////////////////////
// disturb the propagation delay...
//////////////////////////////////////

// virtual clock with period = 2ps
reg virtual_clk;
initial virtual_clk = 0;
always #1  virtual_clk=~virtual_clk;

generate 
for (g=0; g<NUM_LANES; g=g+1) begin : lag
	reg [7:0] lag_dist_1;
	reg [7:0] lag_dist_2;
	initial lag_dist_1 = $random;
	initial lag_dist_2 = $random;
	
	reg [255:0] lags_1 = 0;
	reg [255:0] lags_2 = 0;

	always @(posedge  virtual_clk) begin
		lags_1 <= (lags_1 << 1) | rx_serial_1_r[g];
		lags_2 <= (lags_2 << 1) | rx_serial_2_r[g];
	end
	
	assign rx_serial_1[g] = lags_1[lag_dist_1];
	assign rx_serial_2[g] = lags_2[lag_dist_2];
end
endgenerate


/////////////////////////////////
// monitor lane locking
/////////////////////////////////

genvar i;
generate 
	for (i=0; i<NUM_VLANES; i=i+1) begin : mon0
		always @(posedge am_locked_1[i]) begin
			if (am_locked_1[i] === 1'b1) begin
				$display ("DUT 1 Lane %d fully locked at time %d",i,$time);
			end
		end
		always @(posedge am_locked_2[i]) begin
			if (am_locked_2[i] === 1'b1) begin
				$display ("DUT 2 Lane %d fully locked at time %d",i,$time);
			end
		end
	end
endgenerate

always @(posedge pma_tx_ready_1) begin
	$display ("DUT 1 TX interface is ready at time %d",$time);
end
always @(posedge pma_tx_ready_2) begin
	$display ("DUT 2 TX interface is ready at time %d",$time);
end

always @(posedge pma_rx_ready_1) begin
	$display ("DUT 1 RX interface is ready at time %d",$time);
end
always @(posedge pma_rx_ready_2) begin
	$display ("DUT 2 RX interface is ready at time %d",$time);
end

always @(posedge all_locked_1) begin
	$display ("DUT 1 All lanes locked at time %d",$time);
end
always @(posedge all_locked_2) begin
	$display ("DUT 2 All lanes locked at time %d",$time);
end

always @(posedge lanes_deskewed_1) begin
	$display ("DUT 1 Lanes deskewed at time %d",$time);
end
always @(posedge lanes_deskewed_2) begin
	$display ("DUT 2 Lanes deskewed at time %d",$time);
end

always @(posedge deskew_failure_1) begin
	$display ("DUT 1 Deskew failure at time %d -> retry",$time);
end
always @(posedge deskew_failure_2) begin
	$display ("DUT 2 Deskew failure at time %d -> retry",$time);
end

always @(posedge an_complete_1) begin
    $display ("DUT 1 AN complete at time %d",$time);
end
always @(posedge an_complete_2) begin
    $display ("DUT 2 AN complete at time %d",$time);
end

generate 
	for (i=0; i<NUM_LANES; i=i+1) begin : monlt
		always @(posedge lt_frame_lock_1[i]) begin
			$display ("DUT 1 Lane %d LT frame lock at time %d",i,$time);
		end
		always @(posedge lt_frame_lock_2[i]) begin
			$display ("DUT 2 Lane %d LT frame lock at time %d",i,$time);
		end

		always @(posedge lt_trained_1[i]) begin
			$display ("DUT 1 Lane %d LT done at time %d",i,$time);
		end		
		always @(posedge lt_trained_2[i]) begin
			$display ("DUT 2 Lane %d LT done at time %d",i,$time);
		end

		always @(posedge lt_error_1[i]) begin
			$display ("DUT 1 Lane %d LT error (BER too high) at time %d",i,$time);
		end
		always @(posedge lt_error_2[i]) begin
			$display ("DUT 2 Lane %d LT error (BER too high) at time %d",i,$time);
		end
		
		always @(posedge lt_failure_1[i]) begin
			$display ("DUT 1 Lane %d LT failure (timeout) at time %d",i,$time);
		end		
		always @(posedge lt_failure_2[i]) begin
			$display ("DUT 2 Lane %d LT failure (timeout) at time %d",i,$time);
		end
	end
endgenerate

///////////////////////////////////
// generate some simple data to send
///////////////////////////////////

reg sample_rom_idle_1 = 1'b1;
reg packet_gen_idle_1 = 1'b1;
reg tx_src_select_1 = 1'b0;

wire [WORDS*64-1:0] din_1, din_tr_1,din_ps_1;	// regular left to right
wire [WORDS-1:0] din_start_1, din_start_tr_1,din_start_ps_1;  // first of any 8 bytes
wire [WORDS*8-1:0] din_end_pos_1, din_end_pos_tr_1,din_end_pos_ps_1; // any byte

alt_e40_avalon_tb_sample_tx_rom txr_1 (
	.clk(clk_din),
	.ena(din_ack_1),
	.idle(sample_rom_idle_1),
	
	.dout_start(din_start_tr_1),
	.dout_endpos(din_end_pos_tr_1),
	.dout(din_tr_1)
);
defparam txr_1 .DEVICE_FAMILY = DEVICE_FAMILY;
defparam txr_1 .WORDS         = WORDS;

alt_e40_avalon_tb_packet_gen ps_1 (
	.clk(clk_din),
	.ena(din_ack_1),
	.idle(packet_gen_idle_1),
		
	.sop(din_start_ps_1),
	.eop(din_end_pos_ps_1),
	.dout(din_ps_1),
	.sernum()
);
defparam ps_1 .WORDS = WORDS;

assign din_start_1 = tx_src_select_1 ? din_start_ps_1 : din_start_tr_1;
assign din_end_pos_1 = tx_src_select_1 ? din_end_pos_ps_1 : din_end_pos_tr_1;
assign din_1 = tx_src_select_1 ? din_ps_1 : din_tr_1;

reg sample_rom_idle_2 = 1'b1;
reg packet_gen_idle_2 = 1'b1;
reg tx_src_select_2 = 1'b0;

wire [WORDS*64-1:0] din_2, din_tr_2,din_ps_2;	// regular left to right
wire [WORDS-1:0] din_start_2, din_start_tr_2,din_start_ps_2;  // first of any 8 bytes
wire [WORDS*8-1:0] din_end_pos_2, din_end_pos_tr_2,din_end_pos_ps_2; // any byte

alt_e40_avalon_tb_sample_tx_rom txr_2 (
	.clk(clk_din),
	.ena(din_ack_2),
	.idle(sample_rom_idle_2),
	
	.dout_start(din_start_tr_2),
	.dout_endpos(din_end_pos_tr_2),
	.dout(din_tr_2)
);
defparam txr_2 .DEVICE_FAMILY = DEVICE_FAMILY;
defparam txr_2 .WORDS         = WORDS;

alt_e40_avalon_tb_packet_gen ps_2 (
	.clk(clk_din),
	.ena(din_ack_2),
	.idle(packet_gen_idle_2),
		
	.sop(din_start_ps_2),
	.eop(din_end_pos_ps_2),
	.dout(din_ps_2),
	.sernum()
);
defparam ps_2 .WORDS = WORDS;

assign din_start_2 = tx_src_select_2 ? din_start_ps_2 : din_start_tr_2;
assign din_end_pos_2 = tx_src_select_2 ? din_end_pos_ps_2 : din_end_pos_tr_2;
assign din_2 = tx_src_select_2 ? din_ps_2 : din_tr_2;

// monitor the input traffic
reg [WORDS*64-1:0] tmp_din_1 = 0;
reg [WORDS*64-1:0] tmp_din_2 = 0;
reg pending_1 = 1'b0;
reg pending_2 = 1'b0;
reg [WORDS*8-1:0] tmp_eop_1 = 0;
reg [WORDS*8-1:0] tmp_eop_2 = 0;
integer r;

always @(posedge clk_din) begin
	if (din_ack_1) begin
		tmp_din_1 = din_1;
		tmp_eop_1 = din_end_pos_1;

		for (r=0; r<WORDS; r=r+1) begin
			if (!pending_1) begin
				if (|tmp_eop_1[WORDS*8-1:(WORDS-1)*8]) begin
					$display ("DUT1: Sending an EOP not during pending packet");
					fail = 1'b1;
				end
				if (din_start_1[WORDS-1-r]) begin
					pending_1 = 1'b1;
				end
			end
			else begin
				// pending_1
				if (din_start_1[WORDS-1-r]) begin
					$display ("DUT1: Sending an SOP during pending packet");
					fail = 1'b1;
				end	
				if (|tmp_eop_1[WORDS*8-1:(WORDS-1)*8]) begin
					pending_1 = 1'b0;
				end
			end
			tmp_din_1 = tmp_din_1 << 8*8;
			tmp_eop_1 = tmp_eop_1 << 8;
		end
	end
	if (din_ack_2) begin
		tmp_din_2 = din_2;
		tmp_eop_2 = din_end_pos_2;

		for (r=0; r<WORDS; r=r+1) begin
			if (!pending_2) begin
				if (|tmp_eop_2[WORDS*8-1:(WORDS-1)*8]) begin
					$display ("DUT2: Sending an EOP not during pending packet");
					fail = 1'b1;
				end
				if (din_start_2[WORDS-1-r]) begin
					pending_2 = 1'b1;
				end
			end
			else begin
				// pending_2
				if (din_start_2[WORDS-1-r]) begin
					$display ("DUT2: Sending an SOP during pending packet");
					fail = 1'b1;
				end	
				if (|tmp_eop_2[WORDS*8-1:(WORDS-1)*8]) begin
					pending_2 = 1'b0;
				end
			end
			tmp_din_2 = tmp_din_2 << 8*8;
			tmp_eop_2 = tmp_eop_2 << 8;
		end
	end
end

///////////////////////////////////
// simple RX packet sanity check
///////////////////////////////////

reg clr_sanity = 1'b1;
wire [31:0] bad_term_cnt_1, bad_serial_cnt_1, bad_dest_cnt_1;
reg  [8*WORDS-1 :0] sanity_eop_1 = 0;

always @(*) begin
	for (r=0; r<8*WORDS; r=r+1) begin
		if (r==l4_rx_empty_1 && l4_rx_endofpacket_1)
			sanity_eop_1[r] = 1'b1;
		else
			sanity_eop_1[r] = 1'b0;
	end
end

alt_e40_avalon_tb_packet_gen_sanity_check psc_1 (
	.clk(clk_rxmac),
	.clr_cntrs(clr_sanity),
	.sop({l4_rx_startofpacket_1,3'b0}),
	.eop(sanity_eop_1),
	.din(l4_rx_data_1),
	.din_valid(l4_rx_valid_1),
	
	.bad_term_cnt(bad_term_cnt_1),
	.bad_serial_cnt(bad_serial_cnt_1),
	.bad_dest_cnt(bad_dest_cnt_1),
	
	.sernum()
);
defparam psc_1 .WORDS = WORDS;

wire [31:0] bad_term_cnt_2, bad_serial_cnt_2, bad_dest_cnt_2;
reg  [8*WORDS-1 :0] sanity_eop_2 = 0;

always @(*) begin
	for (r=0; r<8*WORDS; r=r+1) begin
		if (r==l4_rx_empty_2 && l4_rx_endofpacket_2)
			sanity_eop_2[r] = 1'b1;
		else
			sanity_eop_2[r] = 1'b0;
	end
end

alt_e40_avalon_tb_packet_gen_sanity_check psc_2 (
	.clk(clk_rxmac),
	.clr_cntrs(clr_sanity),
	.sop({l4_rx_startofpacket_2,3'b0}),
	.eop(sanity_eop_2),
	.din(l4_rx_data_2),
	.din_valid(l4_rx_valid_2),
	
	.bad_term_cnt(bad_term_cnt_2),
	.bad_serial_cnt(bad_serial_cnt_2),
	.bad_dest_cnt(bad_dest_cnt_2),
	
	.sernum()
);
defparam psc_2 .WORDS = WORDS;

function [4:0] one_hot_to_binary;
input [WORDS*8-1:0] one_hot;
integer i;
begin
	if (|one_hot) begin
		for (i=0; i<WORDS*8; i=i+1) if (one_hot[i]) one_hot_to_binary = i;
	end else
		one_hot_to_binary = 5'b0;
	end
endfunction

//////////////////////////////////////////
// DUTS
//////////////////////////////////////////
assign l4_tx_startofpacket_1 = |din_start_1;
assign l4_tx_empty_1 = one_hot_to_binary(din_end_pos_1);
assign l4_tx_endofpacket_1 = |din_end_pos_1;
assign l4_tx_data_1 = din_1;
assign din_ack_1 = l4_tx_ready_1;

wire    [367:0] reconfig_from_xcvr_1;
wire    [559:0] reconfig_to_xcvr_1;

wire  [6-1:0]    seq_pcs_mode_1;
wire  [4*6-1:0]  seq_pma_vod_1;
wire  [4*5-1:0]  seq_pma_postap1_1;
wire  [4*4-1:0]  seq_pma_pretap_1;
wire  [4-1:0]    seq_start_rc_1;
wire  [4-1:0]    lt_start_rc_1;
wire  [4*3-1:0]  tap_to_upd_1;  
wire  [4-1:0]    hdsk_rc_busy_1;
wire  [4-1:0]    baser_ll_mif_done_1;
wire  [4-1:0]    dfe_start_rc_1;
wire  [4*2-1:0]  dfe_mode_1;
wire  [4-1:0]    ctle_start_rc_1;
wire  [4*4-1:0]  ctle_rc_1;
wire  [4*2-1:0]  ctle_mode_1;

ENET_ENTITY_QMEGA_06072013 dut_1 (
    .mac_rx_arst_ST         (mac_rx_arst_ST),          // i
    .mac_tx_arst_ST         (mac_tx_arst_ST),          // i
    .pcs_rx_arst_ST         (pcs_rx_arst_ST),          // i
    .pcs_tx_arst_ST         (pcs_tx_arst_ST),          // i
    .pma_arst_ST            (pma_arst_ST),             // i

    .clk_txmac(clk_txmac),    // MAC + PCS clock - at least 312.5Mhz
    .clk_rxmac(clk_rxmac),    // MAC + PCS clock - at least 312.5Mhz
    .clk_ref(clk_ref),      // GX PLL reference
    
    // status register bus
    .clk_status(clk_status),
    .status_addr(status_addr),
    .status_read(status_read_1),
    .status_write(status_write_1),
    .status_writedata(status_writedata),
    .status_readdata(status_readdata_1),
    .status_readdata_valid(status_readdata_valid_1),
    
    .l4_tx_data(l4_tx_data_1),
    .l4_tx_empty(l4_tx_empty_1),
    .l4_tx_startofpacket(l4_tx_startofpacket_1),
    .l4_tx_endofpacket(l4_tx_endofpacket_1),
    .l4_tx_ready(l4_tx_ready_1),
    .l4_tx_valid(l4_tx_valid_1),

    .l4_rx_data(l4_rx_data_1),
    .l4_rx_empty(l4_rx_empty_1),
    .l4_rx_startofpacket(l4_rx_startofpacket_1),
    .l4_rx_endofpacket(l4_rx_endofpacket_1),
    .l4_rx_error(l4_rx_error_1),
    .l4_rx_valid(l4_rx_valid_1),
    .l4_rx_fcs_valid(l4_rx_fcs_valid_1),
    .l4_rx_fcs_error(l4_rx_fcs_error_1),

    .tx_serial(tx_serial_1),
    .rx_serial(rx_serial_1),

    // pause generation
    .pause_insert_tx        (pause_insert_tx_1),         // i
    .pause_insert_time      (pause_insert_time_1),       // i
    .pause_insert_mcast     (pause_insert_mcast_1),      // i
    .pause_insert_dst       (pause_insert_dst_1),        // i
    .pause_insert_src       (pause_insert_src_1),        // i
	
    .reconfig_from_xcvr  (reconfig_from_xcvr_1[367:0]),          // output [367:0]
    .reconfig_to_xcvr    (reconfig_to_xcvr_1[559:0]),            // input [559:0]
    
    .rc_busy(hdsk_rc_busy_1),            // reconfig is busy servicing request
                                         // for lane [3:0] 
    .lt_start_rc(lt_start_rc_1),         // start the TX EQ reconfig for lane 3-0
    .main_rc(seq_pma_vod_1),             // main tap value for reconfig
    .post_rc(seq_pma_postap1_1),         // post tap value for reconfig
    .pre_rc(seq_pma_pretap_1),           // pre tap value for reconfig
    .tap_to_upd(tap_to_upd_1),           // specific TX EQ tap to update
                                         // bit-2 = main, bit-1 = post, ...
    .en_lcl_rxeq(/*unused*/),            // Enable local RX Equalization
    .rxeq_done(4'hF),                    // Local RX Equalization is finished
    .seq_start_rc(seq_start_rc_1),       // start the PCS reconfig for lane 3-0
    .dfe_start_rc(dfe_start_rc_1),       // start DFE reconfig for lane 3-0
    .dfe_mode(dfe_mode_1),               // DFE mode 00=disabled, 01=triggered, 10=continuous
    .ctle_start_rc(ctle_start_rc_1),     // start CTLE reconfig for lane 3-0
    .ctle_rc(ctle_rc_1),                 // CTLE manual setting for lane 3-0
    .ctle_mode(ctle_mode_1),             // CTLE mode 00=manual, 01=one-time, 10=continuous
    .pcs_mode_rc(seq_pcs_mode_1),        // PCS mode for reconfig - 1 hot
                                         // bit 0 = AN mode = low_lat, PLL LTR, 66:40
                                         // bit 1 = LT mode = low_lat, PLL LTD, 66:40
                                         // bit 2 = (N/A) 10G data mode = 10GBASE-R, 66:40
                                         // bit 3 = (N/A) GigE data mode = 8G PCS
                                         // bit 4 = (N/A) XAUI data mode = future?
                                         // bit 5 = 10G-FEC/40G data mode = low lat, 64:64
    .reco_mif_done(|baser_ll_mif_done_1) // PMA reconfiguration done (resets the PHYs)
);
    defparam dut_1.ENET_ENTITY_QMEGA_06072013_inst.FAST_SIMULATION = 1;
	
assign l4_tx_startofpacket_2 = |din_start_2;
assign l4_tx_empty_2 = one_hot_to_binary(din_end_pos_2);
assign l4_tx_endofpacket_2 = |din_end_pos_2;
assign l4_tx_data_2 = din_2;
assign din_ack_2 = l4_tx_ready_2;

wire    [367:0] reconfig_from_xcvr_2;
wire    [559:0] reconfig_to_xcvr_2;

wire  [6-1:0]    seq_pcs_mode_2;
wire  [4*6-1:0]  seq_pma_vod_2;
wire  [4*5-1:0]  seq_pma_postap1_2;
wire  [4*4-1:0]  seq_pma_pretap_2;
wire  [4-1:0]    seq_start_rc_2;
wire  [4-1:0]    lt_start_rc_2;
wire  [4*3-1:0]  tap_to_upd_2;  
wire  [4-1:0]    hdsk_rc_busy_2;
wire  [4-1:0]    baser_ll_mif_done_2;
wire  [4-1:0]    dfe_start_rc_2;
wire  [4*2-1:0]  dfe_mode_2;
wire  [4-1:0]    ctle_start_rc_2;
wire  [4*4-1:0]  ctle_rc_2;
wire  [4*2-1:0]  ctle_mode_2;

ENET_ENTITY_QMEGA_06072013 dut_2 (
    .mac_rx_arst_ST         (mac_rx_arst_ST),          // i
    .mac_tx_arst_ST         (mac_tx_arst_ST),          // i
    .pcs_rx_arst_ST         (pcs_rx_arst_ST),          // i
    .pcs_tx_arst_ST         (pcs_tx_arst_ST),          // i
    .pma_arst_ST            (pma_arst_ST),             // i

    .clk_txmac(clk_txmac),    // MAC + PCS clock - at least 312.5Mhz
    .clk_rxmac(clk_rxmac),    // MAC + PCS clock - at least 312.5Mhz
    .clk_ref(~clk_ref),      // GX PLL reference
    
    // status register bus
    .clk_status(clk_status),
    .status_addr(status_addr),
    .status_read(status_read_2),
    .status_write(status_write_2),
    .status_writedata(status_writedata),
    .status_readdata(status_readdata_2),
    .status_readdata_valid(status_readdata_valid_2),
    
    .l4_tx_data(l4_tx_data_2),
    .l4_tx_empty(l4_tx_empty_2),
    .l4_tx_startofpacket(l4_tx_startofpacket_2),
    .l4_tx_endofpacket(l4_tx_endofpacket_2),
    .l4_tx_ready(l4_tx_ready_2),
    .l4_tx_valid(l4_tx_valid_2),

    .l4_rx_data(l4_rx_data_2),
    .l4_rx_empty(l4_rx_empty_2),
    .l4_rx_startofpacket(l4_rx_startofpacket_2),
    .l4_rx_endofpacket(l4_rx_endofpacket_2),
    .l4_rx_error(l4_rx_error_2),
    .l4_rx_valid(l4_rx_valid_2),
    .l4_rx_fcs_valid(l4_rx_fcs_valid_2),
    .l4_rx_fcs_error(l4_rx_fcs_error_2),

    .tx_serial(tx_serial_2),
    .rx_serial(rx_serial_2),

    // pause generation
    .pause_insert_tx        (pause_insert_tx_2),         // i
    .pause_insert_time      (pause_insert_time_2),       // i
    .pause_insert_mcast     (pause_insert_mcast_2),      // i
    .pause_insert_dst       (pause_insert_dst_2),        // i
    .pause_insert_src       (pause_insert_src_2),        // i
	
    .reconfig_from_xcvr  (reconfig_from_xcvr_2[367:0]),          // output [367:0]
    .reconfig_to_xcvr    (reconfig_to_xcvr_2[559:0]),            // input [559:0]
    
    .rc_busy(hdsk_rc_busy_2),            // reconfig is busy servicing request
                                         // for lane [3:0] 
    .lt_start_rc(lt_start_rc_2),         // start the TX EQ reconfig for lane 3-0
    .main_rc(seq_pma_vod_2),             // main tap value for reconfig
    .post_rc(seq_pma_postap1_2),         // post tap value for reconfig
    .pre_rc(seq_pma_pretap_2),           // pre tap value for reconfig
    .tap_to_upd(tap_to_upd_2),           // specific TX EQ tap to update
                                         // bit-2 = main, bit-1 = post, ...
    .en_lcl_rxeq(/*unused*/),            // Enable local RX Equalization
    .rxeq_done(4'hF),                    // Local RX Equalization is finished
    .seq_start_rc(seq_start_rc_2),       // start the PCS reconfig for lane 3-0
    .dfe_start_rc(dfe_start_rc_2),       // start DFE reconfig for lane 3-0
    .dfe_mode(dfe_mode_2),               // DFE mode 00=disabled, 01=triggered, 10=continuous
    .ctle_start_rc(ctle_start_rc_2),     // start CTLE reconfig for lane 3-0
    .ctle_rc(ctle_rc_2),                 // CTLE manual setting for lane 3-0
    .ctle_mode(ctle_mode_2),             // CTLE mode 00=manual, 01=one-time, 10=continuous
    .pcs_mode_rc(seq_pcs_mode_2),        // PCS mode for reconfig - 1 hot
                                         // bit 0 = AN mode = low_lat, PLL LTR, 66:40
                                         // bit 1 = LT mode = low_lat, PLL LTD, 66:40
                                         // bit 2 = (N/A) 10G data mode = 10GBASE-R, 66:40
                                         // bit 3 = (N/A) GigE data mode = 8G PCS
                                         // bit 4 = (N/A) XAUI data mode = future?
                                         // bit 5 = 10G-FEC/40G data mode = low lat, 64:64
    .reco_mif_done(|baser_ll_mif_done_2) // PMA reconfiguration done (resets the PHYs)
);
    defparam dut_2.ENET_ENTITY_QMEGA_06072013_inst.FAST_SIMULATION = 1;

//////////////////////////////////////////
// RECO BUNDLES
//////////////////////////////////////////

sv_rcn_bundle #(
    .PMA_RD_AFTER_WRITE(1),
    .PLLS(4),                 // virtual TX plls (pre-merge)
    .CHANNELS(4),             // arbitrary number of channels
    .MAP_PLLS(0),             // remap logical channels to account for PLLs?
    .SYNTH_1588_1G(0),        // GigE data-path is not 1588-enabled 
    .SYNTH_1588_10G(0),       // 10GBASE-R data-path is not 1588-enabled
    .KR_PHY_SYNTH_AN(1),      // AN enabled
    .KR_PHY_SYNTH_LT(1),      // LT enabled
    .KR_PHY_SYNTH_DFE(1),
    .KR_PHY_SYNTH_CTLE(1),
    .KR_PHY_SYNTH_GIGE(0),    // GigE not enabled    
    .ENA_RECONFIG_CONTROLLER_DFE_RCFG(1),
    .ENA_RECONFIG_CONTROLLER_CTLE_RCFG(1),
    .DISABLE_CTLE_DFE_BEFORE_AN(2'b01), // disable DFE upon AN
    .PRI_RR(1)                // use round-robin priority in arbiter
) reco_bundle_1 (
    .reconfig_clk(clk_status),
    .reconfig_reset(pma_arst_ST),

    .reconfig_from_xcvr(reconfig_from_xcvr_1),
    .reconfig_to_xcvr(reconfig_to_xcvr_1),
    .reconfig_mgmt_busy(), // unused

    .seq_pcs_mode({4{seq_pcs_mode_1}}),
    .seq_pma_vod(seq_pma_vod_1),
    .seq_pma_postap1(seq_pma_postap1_1),
    .seq_pma_pretap(seq_pma_pretap_1),
    .seq_start_rc(seq_start_rc_1),
    .lt_start_rc(lt_start_rc_1),
    .tap_to_upd(tap_to_upd_1),
    .hdsk_rc_busy(hdsk_rc_busy_1),
    .baser_ll_mif_done(baser_ll_mif_done_1),
    
    .dfe_start_rc      (dfe_start_rc_1),
    .dfe_mode          (dfe_mode_1),
    .ctle_start_rc     (ctle_start_rc_1),
    .ctle_rc           (ctle_rc_1),
    .ctle_mode         (ctle_mode_1)
);


sv_rcn_bundle #(
    .PMA_RD_AFTER_WRITE(1),
    .PLLS(4),                 // virtual TX plls (pre-merge)
    .CHANNELS(4),             // arbitrary number of channels
    .MAP_PLLS(0),             // remap logical channels to account for PLLs?
    .SYNTH_1588_1G(0),        // GigE data-path is not 1588-enabled 
    .SYNTH_1588_10G(0),       // 10GBASE-R data-path is not 1588-enabled
    .KR_PHY_SYNTH_AN(1),      // AN enabled
    .KR_PHY_SYNTH_LT(1),      // LT enabled
    .KR_PHY_SYNTH_DFE(1),
    .KR_PHY_SYNTH_CTLE(1),
    .KR_PHY_SYNTH_GIGE(0),    // GigE not enabled    
    .ENA_RECONFIG_CONTROLLER_DFE_RCFG(1),
    .ENA_RECONFIG_CONTROLLER_CTLE_RCFG(1),
    .DISABLE_CTLE_DFE_BEFORE_AN(2'b01), // disable DFE upon AN
    .PRI_RR(1)                // use round-robin priority in arbiter
) reco_bundle_2 (
    .reconfig_clk(clk_status),
    .reconfig_reset(pma_arst_ST),

    .reconfig_from_xcvr(reconfig_from_xcvr_2),
    .reconfig_to_xcvr(reconfig_to_xcvr_2),
    .reconfig_mgmt_busy(), // unused

    .seq_pcs_mode({4{seq_pcs_mode_2}}),
    .seq_pma_vod(seq_pma_vod_2),
    .seq_pma_postap1(seq_pma_postap1_2),
    .seq_pma_pretap(seq_pma_pretap_2),
    .seq_start_rc(seq_start_rc_2),
    .lt_start_rc(lt_start_rc_2),
    .tap_to_upd(tap_to_upd_2),
    .hdsk_rc_busy(hdsk_rc_busy_2),
    .baser_ll_mif_done(baser_ll_mif_done_2),
    
    .dfe_start_rc      (dfe_start_rc_2),
    .dfe_mode          (dfe_mode_2),
    .ctle_start_rc     (ctle_start_rc_2),
    .ctle_rc           (ctle_rc_2),
    .ctle_mode         (ctle_mode_2)
);

/////////////////////////////////
// watchdogs
/////////////////////////////////

// write initial values to registers
int skip_cnt=0;

initial begin
	@(posedge (pma_tx_ready_1 & pma_rx_ready_1));
	#35000000 if (!lanes_deskewed_1) begin
		$display ("DUT 1 Failed to align and deskew in a reasonable time");
		fail = 1'b1;
		$stop();
	end
end
initial begin
	@(posedge (pma_tx_ready_2 & pma_rx_ready_2));
	#35000000 if (!lanes_deskewed_2) begin
		$display ("DUT 2 Failed to align and deskew in a reasonable time");
		fail = 1'b1;
		$stop();
	end
end

reg expecting_loss_of_lock_1 = 0;
initial begin
	#100
	@(negedge lanes_deskewed_1) begin
		if (expecting_loss_of_lock_1 == 1) begin
			$display ("\t+-----------------------------------------------");
			$display ("\t|  DUT 1 Expected loss of lock");
			$display ("\t+-----------------------------------------------");
		end else begin
			$display ("\t+-----------------------------------------------");
			$display ("\t|  DUT 1 Unexpected loss of lock");
			$display ("\t+-----------------------------------------------");
			fail = 1'b1;
			$stop();
		end
	end
end
reg expecting_loss_of_lock_2 = 0;
initial begin
	#100
	@(negedge lanes_deskewed_2) begin
		if (expecting_loss_of_lock_2 == 1) begin
			$display ("\t+-----------------------------------------------");
			$display ("\t|  DUT 2 Expected loss of lock");
			$display ("\t+-----------------------------------------------");
		end else begin
			$display ("\t+-----------------------------------------------");
			$display ("\t|  DUT 2 Unexpected loss of lock");
			$display ("\t+-----------------------------------------------");
			fail = 1'b1;
			$stop();
		end
	end
end

/////////////////////////////////
// stimulus
/////////////////////////////////

reg enough_starts_1 = 1'b0;
reg enough_starts_2 = 1'b0;
reg more_enough_starts_1 = 1'b0;
reg more_enough_starts_2 = 1'b0;

always @(posedge clk_rxmac) begin
	enough_starts_1 <= (tx_start_cnt_rp_1 >= 64'h100);
	enough_starts_2 <= (tx_start_cnt_rp_2 >= 64'h100);
	more_enough_starts_1 <= (tx_start_cnt_rp_1 >= 64'h400);
	more_enough_starts_2 <= (tx_start_cnt_rp_2 >= 64'h400);
end
 
integer cw = 0;

initial begin
	#1000;
	$display("*****************************************");
	$display("**     40g-KR4 Ethernet Testbench");
	$display("**");
	$display("**");
	$display("** Target Device: 		%s",DEVICE_FAMILY);
	$display("** IP Configuration: 		%s", MAC_CONFIG);
	$display("** Variant Name: 			%s", VARIANT_NAME);
	$display("** Status Clock Rate: 	%d KHz", STATUS_CLK_KHZ);
    
	if (HAS_MAC == 1'b0) begin
		$display("**");
		$display("** This variant is PHY only");
	end else if (HAS_PHY == 1'b0) begin
		$display("**");
		$display("** This variant is MAC only");
	
		if (HAS_ADAPTERS == 1'b1) $display("** Interface: 			Avalon-ST");
		else $display("** Interface: 			Custom-ST");

	end else begin
		$display("**");
		$display("** This variant is MAC & PHY");
		if (HAS_ADAPTERS == 1'b1) $display("** Interface: 			Avalon-ST");
		else $display("** Interface: 			Custom-ST");
	end
    
	if (HAS_MAC == 1'b0 || HAS_PHY == 1'b0 ||  VARIANT != 3 || HAS_ADAPTERS == 1'b0) begin
		$display("***************************************************************************");
		$display("** This testbench only supports full duplex Avalon-ST variants with a MAC and a PHY");
		$display("**");
		$display("**");
	    $display("**");
		$display("** Testbench complete.");
		$display("**");
		$display("*****************************************");
		#100000;
		$finish;
	end
	
	
	$display("*****************************************");
	$display("** Reseting the IP Core...");
	$display("**");
	$display("**");

	mac_tx_arst_ST = 1'b1;
	mac_rx_arst_ST = 1'b1;
	pcs_tx_arst_ST = 1'b1;
	pcs_rx_arst_ST = 1'b1;
	pma_arst_ST = 1'b1;

	repeat (10) begin
			@(negedge clk_status);
	end

	mac_tx_arst_ST = 1'b0;
	mac_rx_arst_ST = 1'b0;
	pcs_tx_arst_ST = 1'b0;
	pcs_rx_arst_ST = 1'b0;
	pma_arst_ST = 1'b0;
	
	repeat (10) @(negedge clk_status);
	
	handler_start = 1;
	$display("*****************************************");
	$display("** Waiting for alignment and deskew...");
	$display("**");
	$display("**");
	
    @(posedge pma_tx_ready_1 & pma_rx_ready_1 & lanes_deskewed_1 &
	          pma_tx_ready_2 & pma_rx_ready_2 & lanes_deskewed_2);

	$display ("\n#########################\n#########################");
	$display ("\nnormal traffic - switch to packet generator");
	$display ("OK.  Wiping stats...");
	@(negedge clk_din);
	clr_sanity = 1'b1;
	clr_history = 1'b1;
	// reset stats counters and start normal operation
	reset_monitor_cnt = 1'b1;
	@(negedge clk_status) begin wr_addr = 16'h102;	request_writedata = 32'b1000; write_request_1 = 1; end
	@(posedge handling_write_request) 
	begin write_request_1 = 0;  wr_addr = 16'h102;	request_writedata = 32'b1000; write_request_2 = 1; end
	@(negedge clk_status) begin write_request_1 = 0; write_request_2 = 0; end
	repeat (2) @(negedge clk_status);
	reset_monitor_cnt = 1'b0;
	clr_history = 1'b0;
	clr_sanity = 1'b0;
	
	$display("*****************************************");
	$display("** Starting packet generator traffic...");
	$display("**");
	$display("**");
	sample_rom_idle_1 = 1'b1;
	sample_rom_idle_2 = 1'b1;
	packet_gen_idle_1 = 1'b0;
	packet_gen_idle_2 = 1'b0;
	tx_src_select_1 = 1'b1;
	tx_src_select_2 = 1'b1;

	@(posedge more_enough_starts_1 && more_enough_starts_2);
	@(negedge clk_din) begin packet_gen_idle_1 = 1'b1; packet_gen_idle_2 = 1'b1; end
	for (cw=0; cw<1000; cw=cw+1'b1) begin : stl3
		if (|din_start_1 || |din_start_2) cw = 0; // oops - still going
		@(negedge clk_din);
	end
	tx_src_select_1 = 1'b0;
	tx_src_select_2 = 1'b0;
	
	@(negedge clk_status) refresh_cntr = 1'b1;
	@(posedge refreshing_cntr) refresh_cntr = 1'b0;
	@(negedge print_cntr_value);	// counter refresh done
	
	$display ("DUT 1 Sent %d packets",tx_start_cnt_1);
	$display ("DUT 2 Received %d packets",rx_start_cnt_2);
	if (tx_start_cnt_1 !== rx_start_cnt_2) begin
		$display ("Count mismatch");
		fail = 1'b1;
	end
	if (runt_cnt_2 !== 0) begin
		$display ("Runts in RX data");
		fail = 1'b1;
	end
	if (fcs_error_cnt_2 !== 0) begin
		$display ("FCS errors in RX data");
		fail = 1'b1;
	end
	if (bip_history_2 != 0 || frame_history_2 != 0) begin
		$display ("BIP or framing errors detected during normal operation");
		fail = 1'b1;	
	end
	if (rx_acc_start_cnt_2 !== rx_start_cnt_2) begin
		$display ("DOE fifo accepted starts does not match total RX starts");
		fail = 1'b1;
	end
	if (bad_term_cnt_2 !== 0 || bad_serial_cnt_2 !== 0 || bad_dest_cnt_2 !== 0) begin
		$display ("Errors detected by packet gen sanity check");
		fail = 1'b1;		
	end
	
	$display ("DUT 2 Sent %d packets",tx_start_cnt_2);
	$display ("DUT 1 Received %d packets",rx_start_cnt_1);
	if (tx_start_cnt_2 !== rx_start_cnt_1) begin
		$display ("Count mismatch");
		fail = 1'b1;
	end
	if (runt_cnt_1 !== 0) begin
		$display ("Runts in RX data");
		fail = 1'b1;
	end
	if (fcs_error_cnt_1 !== 0) begin
		$display ("FCS errors in RX data");
		fail = 1'b1;
	end
	if (bip_history_1 != 0 || frame_history_1 != 0) begin
		$display ("BIP or framing errors detected during normal operation");
		fail = 1'b1;	
	end
	if (rx_acc_start_cnt_1 !== rx_start_cnt_1) begin
		$display ("DOE fifo accepted starts does not match total RX starts");
		fail = 1'b1;
	end
	if (bad_term_cnt_1 !== 0 || bad_serial_cnt_1 !== 0 || bad_dest_cnt_1 !== 0) begin
		$display ("Errors detected by packet gen sanity check");
		fail = 1'b1;		
	end
	
	clr_sanity = 1'b1;
	
	if (fail) $stop();

//////////////////////////////////
// Finishing
	if (!fail) begin
		$display ("PASS");
	end
    
	$display("**");
	$display("** Testbench complete.");
	$display("**");
	$display("*****************************************");
	#100000;
    
//UNCOMMENT FOLLOWING FOR WAVEFORM DUMPING   -- ncsim
//   $dumpall;
//   $dumpflush;
        $finish();
   
end

/////////////////////////////////
// clock drivers
/////////////////////////////////
always begin
	clk_din = ~clk_din;
	#(MAC_CLK_PERIOD/2);
end

assign clk_txmac = clk_din;
assign clk_rxmac = ~clk_txmac;
assign clk_txfifo = ~clk_txmac; //make it un-sync
assign clk_rxfifo = ~clk_rxmac; //make it un-sync

always begin
	clk_status = ~clk_status;
	#(500000000/STATUS_CLK_KHZ);
end

always begin
	clk_ref = ~clk_ref;
	#(REF_CLK_PERIOD/2);
end

endmodule
