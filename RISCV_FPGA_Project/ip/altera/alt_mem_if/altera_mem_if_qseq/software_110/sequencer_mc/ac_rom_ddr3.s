NUMBER OF ADDRESS BITS: 6

CLASS cke 1
DEFINE cke cke_1 1
DEFINE cke cke_0 0

CLASS odt 1
DEFINE odt odt_0 0
DEFINE odt odt_1 1

CLASS reset 1
DEFINE reset reset_0 0
DEFINE reset reset_1 1

CLASS cmd 3 # we#.cas#.ras#
DEFINE cmd cmd_des 111
DEFINE cmd cmd_nop 111
DEFINE cmd cmd_mrs 000
DEFINE cmd cmd_act 110
DEFINE cmd cmd_pre 010
DEFINE cmd cmd_write_bl8 001
DEFINE cmd cmd_read_bl8 101
DEFINE cmd cmd_zqcl 011
DEFINE cmd cmd_ref 100

`if FULL_RATE
CLASS cs 1
DEFINE cs cs_off 1
DEFINE cs cs_on  0
`endif
`if HALF_RATE
CLASS cs 2
DEFINE cs cs_off 11
DEFINE cs cs_on  01
DEFINE cs cs_opp 10
`endif
`if QUARTER_RATE
CLASS cs 2
DEFINE cs cs_off 11
DEFINE cs cs_on  01
DEFINE cs cs_opp 10
`endif

CLASS ba 3
DEFINE ba ba_0 000
DEFINE ba ba_1 001
DEFINE ba ba_2 010
DEFINE ba ba_3 011

# Mirrored Bank Address for use in dual-rank designs
# Swap 0,1
DEFINE ba ba_0_mirr 000
DEFINE ba ba_1_mirr 010
DEFINE ba ba_2_mirr 001
DEFINE ba ba_3_mirr 011

`if HARD_PHY
CLASS add 13 16 0
`else
CLASS add 13 MEM_ADDR_WIDTH 0
`endif
DEFINE add add_0 0_0000_0000_0000
DEFINE add add_1 0_0000_0000_1000
DEFINE add add_0_a10_h 0_0100_0000_0000
DEFINE add add_0_a12_h 1_0000_0000_0000
DEFINE add add_mrs0_user AC_ROM_MR0
DEFINE add add_mrs0_dll_reset AC_ROM_MR0_DLL_RESET
DEFINE add add_mrs1 AC_ROM_MR1
DEFINE add add_mrs2 AC_ROM_MR2
DEFINE add add_mrs3 AC_ROM_MR3

# Mirrored MRS Addresses for use in dual-rank designs
# Swap 3,4 - 5,6 - 7,8
DEFINE add add_mrs0_user_mirr AC_ROM_MR0_MIRR
DEFINE add add_mrs0_dll_reset_mirr AC_ROM_MR0_DLL_RESET_MIRR
DEFINE add add_mrs1_mirr AC_ROM_MR1_MIRR
DEFINE add add_mrs2_mirr AC_ROM_MR2_MIRR
DEFINE add add_mrs3_mirr AC_ROM_MR3_MIRR

`if FULL_RATE
CLASS dqs_ena 1
DEFINE dqs_ena dqs_ena_0 0
DEFINE dqs_ena dqs_ena_1 1
`endif
`if HALF_RATE
CLASS dqs_ena 2
DEFINE dqs_ena dqs_ena_0 00
DEFINE dqs_ena dqs_ena_10 10
DEFINE dqs_ena dqs_ena_1 11
`endif
`if QUARTER_RATE
CLASS dqs_ena 4
DEFINE dqs_ena dqs_ena_0 0000
DEFINE dqs_ena dqs_ena_1000 1000
DEFINE dqs_ena dqs_ena_1 1111
`endif

CLASS rdata_en 2 # rdata_en_full.rdata_en
DEFINE rdata_en rdata_en_0 00
DEFINE rdata_en rdata_en_1 11

CLASS wdata_valid 1
DEFINE wdata_valid wdata_valid_0 0
DEFINE wdata_valid wdata_valid_1 1

TEMPLATE cs.cke.odt.wdata_valid.rdata_en.dqs_ena.cmd.reset.ba.add

# Initialization commands
LABEL ac_init_reset_0_cke_0 cke_0 | reset_0 | cs_off | cmd_des | ba_0 | add_0 | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
LABEL ac_init_reset_1_cke_0 cke_0 | reset_1 | cs_off | cmd_des | ba_0 | add_0 | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
LABEL ac_mrs0_user cke_1 | reset_1 | cs_on | cmd_mrs | ba_0 | add_mrs0_user | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
LABEL ac_mrs0_dll_reset cke_1 | reset_1 | cs_on | cmd_mrs | ba_0 | add_mrs0_dll_reset | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
LABEL ac_mrs1 cke_1 | reset_1 | cs_on | cmd_mrs | ba_1 | add_mrs1 | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
LABEL ac_mrs2 cke_1 | reset_1 | cs_on | cmd_mrs | ba_2 | add_mrs2 | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
LABEL ac_mrs3 cke_1 | reset_1 | cs_on | cmd_mrs | ba_3 | add_mrs3 | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
LABEL ac_zqcl cke_1 | reset_1 | cs_on | cmd_zqcl | ba_0 | add_0_a10_h | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0

# Mirrored initialization commands
LABEL ac_mrs0_user_mirr cke_1 | reset_1 | cs_on | cmd_mrs | ba_0_mirr | add_mrs0_user_mirr | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
LABEL ac_mrs0_dll_reset_mirr cke_1 | reset_1 | cs_on | cmd_mrs | ba_0_mirr | add_mrs0_dll_reset_mirr | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
LABEL ac_mrs1_mirr cke_1 | reset_1 | cs_on | cmd_mrs | ba_1_mirr | add_mrs1_mirr | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
LABEL ac_mrs2_mirr cke_1 | reset_1 | cs_on | cmd_mrs | ba_2_mirr | add_mrs2_mirr | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
LABEL ac_mrs3_mirr cke_1 | reset_1 | cs_on | cmd_mrs | ba_3_mirr | add_mrs3_mirr | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0

# Generic commands
LABEL ac_des       cke_1 | reset_1 | cs_off | cmd_des | ba_0 | add_0 | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
LABEL ac_des_odt_1 cke_1 | reset_1 | cs_off | cmd_des | ba_0 | add_0 | odt_1 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
LABEL ac_nop       cke_1 | reset_1 | cs_off | cmd_nop | ba_0 | add_0 | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0

# Activate / precharge commands
LABEL ac_act_0 cke_1 | reset_1 | cs_on | cmd_act | ba_0 | add_0 | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
LABEL ac_act_1 cke_1 | reset_1 | cs_on | cmd_act | ba_3 | add_0 | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
LABEL ac_pre_all cke_1 | reset_1 | cs_on | cmd_pre | ba_0 | add_0_a10_h | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0

# Refresh
LABEL ac_ref cke_1 | reset_1 | cs_on | cmd_ref | ba_0 | add_0 | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0

# These commands open the data pipeline and are to be used only for guaranteed writes
LABEL ac_write_bank_0_col_0 cke_1 | reset_1 | cs_on | cmd_write_bl8 | ba_0 | add_0 | odt_1 | wdata_valid_1 | dqs_ena_1 | rdata_en_0
LABEL ac_write_bank_1_col_0 cke_1 | reset_1 | cs_on | cmd_write_bl8 | ba_3 | add_0 | odt_1 | wdata_valid_1 | dqs_ena_1 | rdata_en_0
LABEL ac_write_bank_0_col_1 cke_1 | reset_1 | cs_on | cmd_write_bl8 | ba_0 | add_1 | odt_1 | wdata_valid_1 | dqs_ena_1 | rdata_en_0
LABEL ac_write_bank_1_col_1 cke_1 | reset_1 | cs_on | cmd_write_bl8 | ba_3 | add_1 | odt_1 | wdata_valid_1 | dqs_ena_1 | rdata_en_0
`if FULL_RATE
LABEL ac_write_predata cke_1 | reset_1 | cs_off | cmd_des | ba_0 | add_0 | odt_1 | wdata_valid_0 | dqs_ena_1 | rdata_en_0
`endif
`if HALF_RATE
LABEL ac_write_predata cke_1 | reset_1 | cs_off | cmd_des | ba_0 | add_0 | odt_1 | wdata_valid_0 | dqs_ena_10 | rdata_en_0
`endif
`if QUARTER_RATE
LABEL ac_write_predata cke_1 | reset_1 | cs_off | cmd_des | ba_0 | add_0 | odt_1 | wdata_valid_0 | dqs_ena_1000 | rdata_en_0
`endif
LABEL ac_write_data cke_1 | reset_1 | cs_off | cmd_des | ba_0 | add_0 | odt_1 | wdata_valid_1 | dqs_ena_1 | rdata_en_0
LABEL ac_write_postdata cke_1 | reset_1 | cs_off | cmd_des | ba_0 | add_0 | odt_1 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
LABEL ac_write_bank_0_col_0_nodata cke_1 | reset_1 | cs_on | cmd_write_bl8 | ba_0 | add_0 | odt_1 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
`if FULL_RATE
LABEL ac_write_bank_0_col_0_nodata_wl_1 cke_1 | reset_1 | cs_on | cmd_write_bl8 | ba_0 | add_0 | odt_1 | wdata_valid_0 | dqs_ena_1 | rdata_en_0
`endif
`if HALF_RATE
LABEL ac_write_bank_0_col_0_nodata_wl_1 cke_1 | reset_1 | cs_on | cmd_write_bl8 | ba_0 | add_0 | odt_1 | wdata_valid_0 | dqs_ena_10 | rdata_en_0
`endif
`if QUARTER_RATE
LABEL ac_write_bank_0_col_0_nodata_wl_1 cke_1 | reset_1 | cs_on | cmd_write_bl8 | ba_0 | add_0 | odt_1 | wdata_valid_0 | dqs_ena_1000 | rdata_en_0
`endif

# Read commands
LABEL ac_read_bank_0_0 cke_1 | reset_1 | cs_on | cmd_read_bl8 | ba_0 | add_0 | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_1
LABEL ac_read_bank_1_0 cke_1 | reset_1 | cs_on | cmd_read_bl8 | ba_3 | add_0 | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_1
LABEL ac_read_bank_0_1 cke_1 | reset_1 | cs_on | cmd_read_bl8 | ba_0 | add_1 | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_1
LABEL ac_read_bank_1_1 cke_1 | reset_1 | cs_on | cmd_read_bl8 | ba_3 | add_1 | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_1
LABEL ac_read_en cke_1 | reset_1 | cs_off | cmd_nop | ba_0 | add_0 | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_1
LABEL ac_read_bank_0_1_norden cke_1 | reset_1 | cs_on | cmd_read_bl8 | ba_0 | add_1 | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
`if GUARANTEED_READ_BRINGUP_TEST
LABEL ac_read_bank_0_0_norden cke_1 | reset_1 | cs_on | cmd_read_bl8 | ba_0 | add_0 | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
LABEL ac_read_bank_1_0_norden cke_1 | reset_1 | cs_on | cmd_read_bl8 | ba_3 | add_0 | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
LABEL ac_read_bank_1_1_norden cke_1 | reset_1 | cs_on | cmd_read_bl8 | ba_3 | add_1 | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
`endif # GUARANTEED_READ_BRINGUP_TEST
`if QUARTER_RATE
LABEL ac_read_tracking cke_1 | reset_1 | cs_on | cmd_read_bl8 | ba_3 | add_0_a12_h | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_1
`endif

# RDIMM command 
# It's like a nop with CS turned on. The address portion of this command
# will be overridden from the C-code with the 
LABEL ac_rdimm cke_1 | reset_1 | cs_on | cmd_nop | ba_0 | add_0 | odt_0 | wdata_valid_0 | dqs_ena_0 | rdata_en_0
