NUMBER OF ADDRESS BITS: 6

CLASS cke 1
DEFINE cke cke_1 1
DEFINE cke cke_0 0

CLASS cmd 3 # we#.cas#.ras#
DEFINE cmd cmd_des 111
DEFINE cmd cmd_nop 111
DEFINE cmd cmd_mrs 000
DEFINE cmd cmd_act 110
DEFINE cmd cmd_pre 010
DEFINE cmd cmd_ref 100
DEFINE cmd cmd_write_bl8 001
DEFINE cmd cmd_read_bl8 101
DEFINE cmd cmd_zqcl 011

`if HALF_RATE
CLASS cs 2
DEFINE cs cs_off 11
DEFINE cs cs_on  01
`else
CLASS cs 1
DEFINE cs cs_off 1
DEFINE cs cs_on  0
`endif

`if HARD_PHY
CLASS ba 3 4 1
`else
CLASS ba 3
`endif
DEFINE ba ba_0 000
DEFINE ba ba_1 001
DEFINE ba ba_2 010
DEFINE ba ba_3 011

`if HARD_PHY
CLASS add 13 16 0
`else
CLASS add 13 MEM_ADDR_WIDTH 0
`endif
DEFINE add add_0 0_0000_0000_0000
DEFINE add add_1 0_0000_0000_1000
DEFINE add add_0_a10_h 0_0100_0000_0000
DEFINE add add_mr_user AC_ROM_MR0
DEFINE add add_mr_calib AC_ROM_MR0_CALIB
DEFINE add add_emr AC_ROM_MR1

`if HALF_RATE
CLASS dqs_ena 2
DEFINE dqs_ena dqs_ena_0 00
DEFINE dqs_ena dqs_ena_10 10
DEFINE dqs_ena dqs_ena_1 11
`else
CLASS dqs_ena 1
DEFINE dqs_ena dqs_ena_0 0
DEFINE dqs_ena dqs_ena_1 1
`endif

CLASS rdata_en 2 # rdata_en_full.rdata_en
DEFINE rdata_en rdata_en_0 00
DEFINE rdata_en rdata_en_1 11

`if HARD_PHY
CLASS wdata_valid 1 2 0
`else
CLASS wdata_valid 1
`endif
DEFINE wdata_valid wdata_valid_0 0
DEFINE wdata_valid wdata_valid_1 1

TEMPLATE cs.cke.wdata_valid.rdata_en.dqs_ena.cmd.ba.add

# Generic commands
LABEL ac_des cke_1 | cs_off | cmd_des | ba_0 | add_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
LABEL ac_nop cke_1 | cs_off | cmd_nop | ba_0 | add_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0

# Initialization commands
LABEL ac_init_cke_0 cke_0 | cs_off | cmd_des | ba_0 | add_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
LABEL ac_init_cke_1 cke_1 | cs_off | cmd_des | ba_0 | add_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
LABEL ac_mr_user cke_1 | cs_on | cmd_mrs | ba_0 | add_mr_user | wdata_valid_0 | dqs_ena_0 | rdata_en_0
LABEL ac_mr_calib cke_1 | cs_on | cmd_mrs | ba_0 | add_mr_calib | wdata_valid_0 | dqs_ena_0 | rdata_en_0
LABEL ac_emr cke_1 | cs_on | cmd_mrs | ba_2 | add_emr | wdata_valid_0 | dqs_ena_0 | rdata_en_0
LABEL ac_zqcl cke_1 | cs_on | cmd_zqcl | ba_0 | add_0_a10_h | wdata_valid_0 | dqs_ena_0 | rdata_en_0

# Activate / precharge commands
LABEL ac_act_0 cke_1 | cs_on | cmd_act | ba_0 | add_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
LABEL ac_act_1 cke_1 | cs_on | cmd_act | ba_2 | add_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
LABEL ac_pre_all cke_1 | cs_on | cmd_pre | ba_0 | add_0_a10_h | wdata_valid_0 | dqs_ena_0 | rdata_en_0

# Refresh
LABEL ac_ref cke_1 | cs_on | cmd_ref | ba_0 | add_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0

# These commands open the data pipeline and are to be used only for guaranteed writes
LABEL ac_write_bank_0_col_0 cke_1 | cs_on | cmd_write_bl8 | ba_0 | add_0 | wdata_valid_1 | dqs_ena_1 | rdata_en_0
LABEL ac_write_bank_1_col_0 cke_1 | cs_on | cmd_write_bl8 | ba_2 | add_0 | wdata_valid_1 | dqs_ena_1 | rdata_en_0
LABEL ac_write_bank_0_col_1 cke_1 | cs_on | cmd_write_bl8 | ba_0 | add_1 | wdata_valid_1 | dqs_ena_1 | rdata_en_0
LABEL ac_write_bank_1_col_1 cke_1 | cs_on | cmd_write_bl8 | ba_2 | add_1 | wdata_valid_1 | dqs_ena_1 | rdata_en_0
`if HALF_RATE
LABEL ac_write_predata cke_1 | cs_off | cmd_des | ba_0 | add_0 | wdata_valid_0 | dqs_ena_10 | rdata_en_0
`else
LABEL ac_write_predata cke_1 | cs_off | cmd_des | ba_0 | add_0 | wdata_valid_0 | dqs_ena_1 | rdata_en_0
`endif
LABEL ac_write_data cke_1 | cs_off | cmd_des | ba_0 | add_0 | wdata_valid_1 | dqs_ena_1 | rdata_en_0
LABEL ac_write_postdata cke_1 | cs_off | cmd_des | ba_0 | add_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
LABEL ac_write_bank_0_col_0_nodata cke_1 | cs_on | cmd_write_bl8 | ba_0 | add_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
LABEL ac_write_bank_0_col_0_nodata_wl_1 cke_1 | cs_on | cmd_write_bl8 | ba_0 | add_0 | wdata_valid_0 | dqs_ena_1 | rdata_en_0

# Read commands
LABEL ac_read_bank_0_0 cke_1 | cs_on | cmd_read_bl8 | ba_0 | add_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_1
LABEL ac_read_bank_1_0 cke_1 | cs_on | cmd_read_bl8 | ba_2 | add_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_1
LABEL ac_read_bank_0_1 cke_1 | cs_on | cmd_read_bl8 | ba_0 | add_1 | wdata_valid_0 | dqs_ena_0 | rdata_en_1
LABEL ac_read_bank_1_1 cke_1 | cs_on | cmd_read_bl8 | ba_2 | add_1 | wdata_valid_0 | dqs_ena_0 | rdata_en_1
LABEL ac_read_en cke_1 | cs_off | cmd_nop | ba_0 | add_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_1
LABEL ac_read_bank_0_1_norden cke_1 | cs_on | cmd_read_bl8 | ba_0 | add_1 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
