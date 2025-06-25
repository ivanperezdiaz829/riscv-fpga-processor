NUMBER OF ADDRESS BITS: 6

CLASS cke 1
DEFINE cke cke_1 1
DEFINE cke cke_0 0

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
CLASS ca 20 23 1
`else
CLASS ca 20
`endif
DEFINE ca ca_nop         1111111111_1111111111
DEFINE ca ca_mr1_calib   AC_ROM_MR1_CALIB
DEFINE ca ca_mr1         AC_ROM_MR1
DEFINE ca ca_mr2         AC_ROM_MR2
DEFINE ca ca_mr3         AC_ROM_MR3
DEFINE ca ca_mr10_zqc    1111111100_0010100000
DEFINE ca ca_mr63_reset  0000000000_1111110000
DEFINE ca ca_act_b0      0000000000_0000000010
DEFINE ca ca_act_b1      0000000000_0010000010
DEFINE ca ca_pre_all     0000000000_0000011011
DEFINE ca ca_write_b0_c0 0000000000_0000000001
DEFINE ca ca_write_b1_c0 0000000000_0010000001
DEFINE ca ca_write_b0_c1 0000000100_0000000001
DEFINE ca ca_write_b1_c1 0000000100_0010000001
DEFINE ca ca_read_b0_c0  0000000000_0000000101
DEFINE ca ca_read_b1_c0  0000000000_0010000101
DEFINE ca ca_read_b0_c1  0000000100_0000000101
DEFINE ca ca_read_b1_c1  0000000100_0010000101
DEFINE ca ca_ref         0000000000_0000001100

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

TEMPLATE cs.cke.wdata_valid.rdata_en.dqs_ena.ca

# Initialization commands
LABEL ac_init_cke_0              cke_0 | cs_off | ca_nop         | wdata_valid_0 | dqs_ena_0  | rdata_en_0
LABEL ac_mr1_calib               cke_1 | cs_on  | ca_mr1_calib   | wdata_valid_0 | dqs_ena_0  | rdata_en_0
LABEL ac_mr1                     cke_1 | cs_on  | ca_mr1         | wdata_valid_0 | dqs_ena_0  | rdata_en_0
LABEL ac_mr2                     cke_1 | cs_on  | ca_mr2         | wdata_valid_0 | dqs_ena_0  | rdata_en_0
LABEL ac_mr3                     cke_1 | cs_on  | ca_mr3         | wdata_valid_0 | dqs_ena_0  | rdata_en_0
LABEL ac_mr10_zqc                cke_1 | cs_on  | ca_mr10_zqc    | wdata_valid_0 | dqs_ena_0  | rdata_en_0
LABEL ac_mr63_reset              cke_1 | cs_on  | ca_mr63_reset  | wdata_valid_0 | dqs_ena_0  | rdata_en_0

# Generic commands
LABEL ac_des                     cke_1 | cs_off | ca_nop         | wdata_valid_0 | dqs_ena_0  | rdata_en_0

# Activate / precharge commands
LABEL ac_act_b0                  cke_1 | cs_on  | ca_act_b0      | wdata_valid_0 | dqs_ena_0  | rdata_en_0
LABEL ac_act_b1                  cke_1 | cs_on  | ca_act_b1      | wdata_valid_0 | dqs_ena_0  | rdata_en_0
LABEL ac_pre_all                 cke_1 | cs_on  | ca_pre_all     | wdata_valid_0 | dqs_ena_0  | rdata_en_0

# These commands open the data pipeline and are to be used only for guaranteed writes
LABEL ac_write_b0_c0             cke_1 | cs_on  | ca_write_b0_c0 | wdata_valid_1 | dqs_ena_1  | rdata_en_0
LABEL ac_write_b1_c0             cke_1 | cs_on  | ca_write_b1_c0 | wdata_valid_1 | dqs_ena_1  | rdata_en_0
LABEL ac_write_b0_c1             cke_1 | cs_on  | ca_write_b0_c1 | wdata_valid_1 | dqs_ena_1  | rdata_en_0
LABEL ac_write_b1_c1             cke_1 | cs_on  | ca_write_b1_c1 | wdata_valid_1 | dqs_ena_1  | rdata_en_0
`if HALF_RATE
LABEL ac_write_predata           cke_1 | cs_off | ca_nop         | wdata_valid_0 | dqs_ena_10 | rdata_en_0
`else
LABEL ac_write_predata           cke_1 | cs_off | ca_nop         | wdata_valid_0 | dqs_ena_1  | rdata_en_0
`endif
LABEL ac_write_data              cke_1 | cs_off | ca_nop         | wdata_valid_1 | dqs_ena_1  | rdata_en_0
LABEL ac_write_postdata          cke_1 | cs_off | ca_nop         | wdata_valid_0 | dqs_ena_0  | rdata_en_0
LABEL ac_write_b0_c0_nodata      cke_1 | cs_on  | ca_write_b0_c0 | wdata_valid_0 | dqs_ena_0  | rdata_en_0
LABEL ac_write_b0_c0_nodata_wl_1 cke_1 | cs_on  | ca_write_b0_c0 | wdata_valid_0 | dqs_ena_1  | rdata_en_0

# Read commands
LABEL ac_read_b0_c0              cke_1 | cs_on  | ca_read_b0_c0  | wdata_valid_0 | dqs_ena_0 | rdata_en_1
LABEL ac_read_b1_c0              cke_1 | cs_on  | ca_read_b1_c0  | wdata_valid_0 | dqs_ena_0 | rdata_en_1
LABEL ac_read_b0_c1              cke_1 | cs_on  | ca_read_b0_c1  | wdata_valid_0 | dqs_ena_0 | rdata_en_1
LABEL ac_read_b1_c1              cke_1 | cs_on  | ca_read_b1_c1  | wdata_valid_0 | dqs_ena_0 | rdata_en_1
LABEL ac_read_en                 cke_1 | cs_off | ca_nop         | wdata_valid_0 | dqs_ena_0 | rdata_en_1
LABEL ac_read_b0_c1_norden       cke_1 | cs_on  | ca_read_b0_c1  | wdata_valid_0 | dqs_ena_0 | rdata_en_0

# Refresh
LABEL ac_refresh                 cke_1 | cs_on  | ca_ref         | wdata_valid_0 | dqs_ena_0 | rdata_en_0
