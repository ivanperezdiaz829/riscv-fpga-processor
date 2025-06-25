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

(* altera_attribute = "-name IP_TOOL_NAME altera_mem_if_ddr3_controller; -name IP_TOOL_VERSION 13.1; -name FITTER_ADJUST_HC_SHORT_PATH_GUARDBAND 100" *)
module alt_mem_if_ddr3_controller_top (
    afi_clk,
    afi_reset_n,
    afi_half_clk,
    
    avl_ready,
    avl_read_req,
    avl_write_req,
    avl_wdata_req,
    avl_size,
    avl_burstbegin,
    avl_addr,
    avl_rdata_valid,
    avl_rdata,
    avl_wdata,
    avl_be,
    local_rdata_error,
    local_autopch_req,
    local_multicast,
    local_refresh_req,
    local_refresh_chip,
    local_refresh_ack,
    local_self_rfsh_req,
    local_self_rfsh_chip,
    local_self_rfsh_ack,
    local_power_down_ack,
    
    local_init_done,
	local_cal_success,
	local_cal_fail,

    afi_cal_success,
    afi_cal_fail,
    afi_cal_req,
    afi_init_req,
	afi_wlat,
	afi_rlat,
    afi_rrank,
    afi_wrank,

    afi_mem_clk_disable,
    

    afi_cke,
    afi_cs_n,
    afi_ras_n,
    afi_cas_n,
    afi_we_n,
    afi_ba,
    afi_addr,
	afi_rst_n,  
    afi_odt,
    afi_dqs_burst,
    afi_wdata_valid,
    afi_wdata,
    afi_dm,
    afi_rdata_en,
    afi_rdata_en_full,
    afi_rdata,
    afi_rdata_valid,
    afi_ctl_refresh_done,
    afi_seq_busy,
    afi_ctl_long_idle,
    
    csr_write_req,
    csr_read_req,
    csr_addr,
    csr_be,
    csr_wdata,
    csr_waitrequest,
    csr_rdata,
    csr_rdata_valid,
    
    ecc_interrupt

);

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

    localparam  MEM_TYPE                       = "DDR3";
    parameter   AVL_SIZE_WIDTH                 = 0;
    parameter   AVL_ADDR_WIDTH                 = 0;
    parameter   AVL_DATA_WIDTH                 = 0;
    parameter   AVL_BE_WIDTH                   = 0;
    localparam  LOCAL_IF_TYPE                  = "AVALON";
    parameter   AFI_ADDR_WIDTH                 = 0;
    parameter   AFI_BANKADDR_WIDTH             = 0;
    parameter   AFI_CONTROL_WIDTH              = 0;
    parameter   AFI_CS_WIDTH                   = 0;
    parameter   AFI_CLK_EN_WIDTH               = 0;
    parameter   AFI_ODT_WIDTH                  = 0;
    parameter   AFI_DM_WIDTH                   = 0;
    parameter   AFI_DQ_WIDTH                   = 0;
    parameter   AFI_WRITE_DQS_WIDTH            = 0;
    parameter   AFI_RATE_RATIO                 = 0;
    parameter   AFI_WLAT_WIDTH                 = 0;
    parameter   AFI_RLAT_WIDTH                 = 0;
    parameter   AFI_RRANK_WIDTH                = 0;
    parameter   AFI_WRANK_WIDTH                = 0;
    parameter   MEM_IF_CS_WIDTH                = 0;
    parameter   MEM_IF_CHIP_BITS               = 0;
    parameter   MEM_IF_ODT_WIDTH               = 0;
    parameter   MEM_IF_CLK_EN_WIDTH            = 0;
    parameter   MEM_IF_ADDR_WIDTH              = 0;
    parameter   MEM_IF_ROW_ADDR_WIDTH          = 0;
    parameter   MEM_IF_COL_ADDR_WIDTH          = 0;
    parameter   MEM_IF_BANKADDR_WIDTH          = 0;
    parameter   MEM_IF_DQS_WIDTH               = 0;
    parameter   MEM_IF_DQ_WIDTH                = 0;
    parameter   MEM_IF_DM_WIDTH                = 0;
    parameter   MEM_IF_CLK_PAIR_COUNT          = 0;
    parameter   MEM_IF_CS_PER_DIMM             = 0;
    parameter   BYTE_ENABLE                    = 0;
    parameter   DWIDTH_RATIO                   = 0;
    parameter   CTL_LOOK_AHEAD_DEPTH           = 0;
    parameter   CTL_CMD_QUEUE_DEPTH            = 0;
    parameter   CTL_HRB_ENABLED                = 0;
    parameter   CTL_ECC_ENABLED                = 0;
    parameter   CTL_ECC_AUTO_CORRECTION_ENABLED= 0;
    parameter   CTL_ECC_CSR_ENABLED            = 0;
    parameter   CTL_ECC_MULTIPLES_40_72        = 0;
    parameter   CTL_CSR_ENABLED                = 0;
    parameter   CTL_CSR_READ_ONLY              = 0;
    parameter   CTL_ODT_ENABLED                = 0;
    parameter   CTL_REGDIMM_ENABLED            = 0;
    parameter   CSR_ADDR_WIDTH                 = 0;
    parameter   CSR_DATA_WIDTH                 = 0;
    parameter   CTL_OUTPUT_REGD                = 0;
    parameter   CTL_USR_REFRESH                = 0;
	parameter   CTL_SELF_REFRESH               = 0;
    parameter   MEM_WTCL_INT                   = 0;
    parameter   MEM_ADD_LAT                    = 0;
    parameter   MEM_TCL                        = 0;
    parameter   MEM_TRRD                       = 0;
    parameter   MEM_TFAW                       = 0;
    parameter   MEM_TRFC                       = 0;
    parameter   MEM_TREFI                      = 0;
    parameter   MEM_TRCD                       = 0;
    parameter   MEM_TRP                        = 0;
    parameter   MEM_TWR                        = 0;
    parameter   MEM_TWTR                       = 0;
    parameter   MEM_TRTP                       = 0;
    parameter   MEM_TRAS                       = 0;
    parameter   MEM_TRC                        = 0;
    parameter   MEM_AUTO_PD_CYCLES             = 0;
    parameter   MEM_IF_RD_TO_WR_TURNAROUND_OCT = 0;
    parameter   MEM_IF_WR_TO_RD_TURNAROUND_OCT = 0;
    parameter   ADDR_ORDER                     = 0;
    parameter   LOW_LATENCY                    = 0;
    parameter   CTL_DYNAMIC_BANK_ALLOCATION    = 0;
    parameter   CTL_DYNAMIC_BANK_NUM           = 0;
    parameter   ENABLE_BURST_MERGE             = 0;

	parameter   CTL_AUTOPCH_EN                 = 0;
	parameter   MULTICAST_EN                   = 0;


    parameter   CTL_CS_WIDTH                   = 0;


// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

// Clock and reset interface
    input                               afi_clk;
    input                               afi_reset_n;
    input                               afi_half_clk;
 
// Avalon data slave interface
    output                              avl_ready;
    input                               avl_read_req;
    input                               avl_write_req;
    output                              avl_wdata_req;
    input  [AVL_SIZE_WIDTH-1:0]         avl_size;
    input                               avl_burstbegin;
    input  [AVL_ADDR_WIDTH-1:0]         avl_addr;
    output                              avl_rdata_valid;
    output [AVL_DATA_WIDTH-1:0]         avl_rdata;
    input  [AVL_DATA_WIDTH-1:0]         avl_wdata;
    input  [AVL_BE_WIDTH-1:0]           avl_be;
    output                              local_rdata_error;
    input                               local_autopch_req;
    input                               local_multicast;
    input                               local_refresh_req;
    input  [CTL_CS_WIDTH-1:0]           local_refresh_chip;
    output                              local_refresh_ack;
    input                               local_self_rfsh_req;
    input  [CTL_CS_WIDTH-1:0]           local_self_rfsh_chip;
    output                              local_self_rfsh_ack;
    output                              local_power_down_ack;
    
    input                               afi_cal_success;
    input                               afi_cal_fail;
    output                              afi_cal_req;
    output                              afi_init_req;

	output								local_init_done;
	output								local_cal_success;
	output								local_cal_fail;

    wire  [(MEM_IF_DQS_WIDTH*CTL_CS_WIDTH) - 1:0]      ctl_cal_byte_lane_sel_n;
    
    output  [AFI_CLK_EN_WIDTH - 1:0]                        afi_cke;
    output  [AFI_CS_WIDTH - 1:0]                            afi_cs_n;
    output  [AFI_CONTROL_WIDTH - 1:0]                       afi_ras_n;
    output  [AFI_CONTROL_WIDTH - 1:0]                       afi_cas_n;
    output  [AFI_CONTROL_WIDTH - 1:0]                       afi_rst_n;  
    output  [AFI_CONTROL_WIDTH - 1:0]                       afi_we_n;
    output  [AFI_BANKADDR_WIDTH - 1:0]                      afi_ba;
    output  [AFI_ADDR_WIDTH - 1:0]                          afi_addr;
    output  [AFI_ODT_WIDTH - 1:0]                           afi_odt;
    output  [AFI_WRITE_DQS_WIDTH - 1:0]                     afi_dqs_burst;
    output  [AFI_WRITE_DQS_WIDTH - 1:0]                     afi_wdata_valid;
    output  [AFI_DQ_WIDTH - 1:0]                            afi_wdata;
    output  [AFI_DM_WIDTH - 1:0]                            afi_dm;
    output  [AFI_RATE_RATIO - 1:0]                          afi_rdata_en;
    output  [AFI_RATE_RATIO - 1:0]                          afi_rdata_en_full;
    input   [AFI_DQ_WIDTH - 1:0]                            afi_rdata;
    input   [AFI_RATE_RATIO - 1:0]                          afi_rdata_valid;
    input   [AFI_WLAT_WIDTH - 1:0]                          afi_wlat;
    input   [AFI_RLAT_WIDTH - 1:0]                          afi_rlat;
	output  [AFI_RRANK_WIDTH - 1 : 0]                       afi_rrank;
	output  [AFI_WRANK_WIDTH - 1 : 0]                       afi_wrank;
	output  [MEM_IF_CLK_PAIR_COUNT - 1:0]                   afi_mem_clk_disable;
	output  [CTL_CS_WIDTH - 1 : 0]                      afi_ctl_refresh_done;
	input   [CTL_CS_WIDTH - 1 : 0]                      afi_seq_busy;
	output  [CTL_CS_WIDTH - 1 : 0]                      afi_ctl_long_idle;
    
    input                                                   csr_write_req;
    input                                                   csr_read_req;
    input   [CSR_ADDR_WIDTH - 1 : 0]                        csr_addr;
    input   [(CSR_DATA_WIDTH / 8) - 1 : 0]                  csr_be;
    input   [CSR_DATA_WIDTH - 1 : 0]                        csr_wdata;
    output                                                  csr_waitrequest;
    output  [CSR_DATA_WIDTH - 1 : 0]                        csr_rdata;
    output                                                  csr_rdata_valid;
    
    output                                                  ecc_interrupt;
    
    wire afi_init_req;


assign afi_ctl_refresh_done = {CTL_CS_WIDTH{1'b0}};
assign afi_ctl_long_idle    = {CTL_CS_WIDTH{1'b0}};

alt_ddrx_controller # (
    
    .MEM_TYPE                       ( MEM_TYPE                       ),
    .LOCAL_SIZE_WIDTH               ( AVL_SIZE_WIDTH                 ),
    .LOCAL_ADDR_WIDTH               ( AVL_ADDR_WIDTH                 ),
    .LOCAL_DATA_WIDTH               ( AVL_DATA_WIDTH                 ),
    .LOCAL_IF_TYPE                  ( LOCAL_IF_TYPE                  ),
    .MEM_IF_CS_WIDTH                ( CTL_CS_WIDTH                   ),
    .MEM_IF_CHIP_BITS               ( MEM_IF_CHIP_BITS               ),
    .MEM_IF_CKE_WIDTH               ( MEM_IF_CLK_EN_WIDTH            ),
    .MEM_IF_ODT_WIDTH               ( MEM_IF_ODT_WIDTH               ),
    .MEM_IF_ADDR_WIDTH              ( MEM_IF_ADDR_WIDTH              ),
    .MEM_IF_ROW_WIDTH               ( MEM_IF_ROW_ADDR_WIDTH          ),
    .MEM_IF_COL_WIDTH               ( MEM_IF_COL_ADDR_WIDTH          ),
    .MEM_IF_BA_WIDTH                ( MEM_IF_BANKADDR_WIDTH          ),
    .MEM_IF_DQS_WIDTH               ( MEM_IF_DQS_WIDTH               ),
    .MEM_IF_DQ_WIDTH                ( MEM_IF_DQ_WIDTH                ),
    .MEM_IF_DM_WIDTH                ( MEM_IF_DM_WIDTH                ),
    .MEM_IF_CLK_PAIR_COUNT          ( MEM_IF_CLK_PAIR_COUNT          ),
    .MEM_IF_CS_PER_DIMM             ( MEM_IF_CS_PER_DIMM             ),
    .DWIDTH_RATIO                   ( DWIDTH_RATIO                   ),
    .CTL_LOOK_AHEAD_DEPTH           ( CTL_LOOK_AHEAD_DEPTH           ),
    .CTL_CMD_QUEUE_DEPTH            ( CTL_CMD_QUEUE_DEPTH            ),
    .CTL_HRB_ENABLED                ( CTL_HRB_ENABLED                ),
    .CTL_ECC_ENABLED                ( CTL_ECC_ENABLED                ),
    .CTL_ECC_RMW_ENABLED            ( CTL_ECC_AUTO_CORRECTION_ENABLED),
    .CTL_ECC_CSR_ENABLED            ( CTL_ECC_CSR_ENABLED            ),
    .CTL_ECC_MULTIPLES_40_72        ( CTL_ECC_MULTIPLES_40_72        ),
    .CTL_CSR_ENABLED                ( CTL_CSR_ENABLED                ),
    .CTL_CSR_READ_ONLY              ( CTL_CSR_READ_ONLY              ),
    .CTL_ODT_ENABLED                ( CTL_ODT_ENABLED                ),
    .CTL_REGDIMM_ENABLED            ( CTL_REGDIMM_ENABLED            ),
    .CSR_ADDR_WIDTH                 ( CSR_ADDR_WIDTH                 ),
    .CSR_DATA_WIDTH                 ( CSR_DATA_WIDTH                 ),
    .CTL_OUTPUT_REGD                ( CTL_OUTPUT_REGD                ),
    .CTL_USR_REFRESH                ( CTL_USR_REFRESH                ),
    .MEM_CAS_WR_LAT                 ( MEM_WTCL_INT                   ),
    .MEM_ADD_LAT                    ( MEM_ADD_LAT                    ),
    .MEM_TCL                        ( MEM_TCL                        ),
    .MEM_TRRD                       ( MEM_TRRD                       ),
    .MEM_TFAW                       ( MEM_TFAW                       ),
    .MEM_TRFC                       ( MEM_TRFC                       ),
    .MEM_TREFI                      ( MEM_TREFI                      ),
    .MEM_TRCD                       ( MEM_TRCD                       ),
    .MEM_TRP                        ( MEM_TRP                        ),
    .MEM_TWR                        ( MEM_TWR                        ),
    .MEM_TWTR                       ( MEM_TWTR                       ),
    .MEM_TRTP                       ( MEM_TRTP                       ),
    .MEM_TRAS                       ( MEM_TRAS                       ),
    .MEM_TRC                        ( MEM_TRC                        ),
    .MEM_AUTO_PD_CYCLES             ( MEM_AUTO_PD_CYCLES             ),
    .MEM_IF_RD_TO_WR_TURNAROUND_OCT ( MEM_IF_RD_TO_WR_TURNAROUND_OCT ),
    .MEM_IF_WR_TO_RD_TURNAROUND_OCT ( MEM_IF_WR_TO_RD_TURNAROUND_OCT ),
    .ADDR_ORDER                     ( ADDR_ORDER                     ),
    .MULTICAST_WR_EN                ( MULTICAST_EN                   ),
    .LOW_LATENCY                    ( LOW_LATENCY                    ),
    .CTL_DYNAMIC_BANK_ALLOCATION    ( CTL_DYNAMIC_BANK_ALLOCATION    ),
    .CTL_DYNAMIC_BANK_NUM           ( CTL_DYNAMIC_BANK_NUM           ),
    .ENABLE_BURST_MERGE             ( ENABLE_BURST_MERGE             ),
    .USE_BYTEENABLE                 ( BYTE_ENABLE                    )
    
) alt_ddrx_controller_inst (
    
    .ctl_clk                        ( afi_clk                        ),
    .ctl_reset_n                    ( afi_reset_n                    ),
    .ctl_half_clk                   ( afi_half_clk                   ),
    .ctl_half_clk_reset_n           ( afi_reset_n                    ),
    .local_ready                    ( avl_ready                      ),
    .local_read_req                 ( avl_read_req                   ),
    .local_write_req                ( avl_write_req                  ),
    .local_wdata_req                ( avl_wdata_req                  ),
    .local_size                     ( avl_size                       ),
    .local_burstbegin               ( avl_burstbegin                 ),
    .local_addr                     ( avl_addr                       ),
    .local_rdata_valid              ( avl_rdata_valid                ),
    .local_rdata_error              ( local_rdata_error              ),
    .local_rdata                    ( avl_rdata                      ),
    .local_wdata                    ( avl_wdata                      ),
    .local_be                       ( avl_be                         ),
    .local_autopch_req              ( local_autopch_req              ),
    .local_multicast                ( local_multicast                ),
    .local_refresh_req              ( local_refresh_req              ),
    .local_refresh_chip             ( local_refresh_chip             ),
    .local_refresh_ack              ( local_refresh_ack              ),
    .local_self_rfsh_req            ( local_self_rfsh_req            ),
    .local_self_rfsh_chip           ( local_self_rfsh_chip           ),
    .local_self_rfsh_ack            ( local_self_rfsh_ack            ),
    .local_power_down_ack           ( local_power_down_ack           ),
    .local_init_done                ( local_init_done                ),
    .ctl_cal_success                ( afi_cal_success                ),
    .ctl_cal_fail                   ( afi_cal_fail                   ),
    .ctl_cal_req                    ( afi_cal_req                    ),
    .ctl_mem_clk_disable            ( afi_mem_clk_disable            ),
    .ctl_cal_byte_lane_sel_n        ( ctl_cal_byte_lane_sel_n        ),
    .afi_cke                        ( afi_cke                        ),
    .afi_cs_n                       ( afi_cs_n                       ),
    .afi_ras_n                      ( afi_ras_n                      ),
    .afi_cas_n                      ( afi_cas_n                      ),
    .afi_rst_n                      ( afi_rst_n                      ),  
    .afi_we_n                       ( afi_we_n                       ),
    .afi_ba                         ( afi_ba                         ),
    .afi_addr                       ( afi_addr                       ),
    .afi_odt                        ( afi_odt                        ),
    .afi_dqs_burst                  ( afi_dqs_burst                  ),
    .afi_wdata_valid                ( afi_wdata_valid                ),
    .afi_wdata                      ( afi_wdata                      ),
    .afi_dm                         ( afi_dm                         ),
    .afi_doing_read                 ( afi_rdata_en                   ),
    .afi_doing_read_full            ( afi_rdata_en_full              ),
    .afi_rdata                      ( afi_rdata                      ),
    .afi_rdata_valid                ( afi_rdata_valid                ),
    .afi_wlat                       ( afi_wlat                       ),
    .csr_write_req                  ( csr_write_req                  ),
    .csr_read_req                   ( csr_read_req                   ),
    .csr_addr                       ( csr_addr                       ),
    .csr_be                         ( csr_be                         ),
    .csr_wdata                      ( csr_wdata                      ),
    .csr_waitrequest                ( csr_waitrequest                ),
    .csr_rdata                      ( csr_rdata                      ),
    .csr_rdata_valid                ( csr_rdata_valid                ),
    .ecc_interrupt                  ( ecc_interrupt                  )
    
);


assign local_cal_success = afi_cal_success;
assign local_cal_fail = afi_cal_fail;
assign afi_init_req = 1'b0;


endmodule
