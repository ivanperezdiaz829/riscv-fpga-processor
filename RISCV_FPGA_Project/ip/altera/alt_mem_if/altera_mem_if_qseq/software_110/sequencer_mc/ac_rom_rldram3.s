NUMBER OF ADDRESS BITS: 6

CLASS cs 2
DEFINE cs cs_on 10
DEFINE cs cs_on_all 00
DEFINE cs cs_off 11

CLASS reset 1
DEFINE reset reset_0 0
DEFINE reset reset_1 1

CLASS cmd 2 # we#, ref#
DEFINE cmd cmd_nop 11
DEFINE cmd cmd_mrs 00
DEFINE cmd cmd_read 11
DEFINE cmd cmd_write 01
DEFINE cmd cmd_ref 10

CLASS ba 4
DEFINE ba ba_0 0000
DEFINE ba ba_1 0001
DEFINE ba ba_2 0010
DEFINE ba ba_4 0100
DEFINE ba ba_8 1000

CLASS add 12 MEM_ADDR_WIDTH 0
DEFINE add add_0 0000_0000_0000
DEFINE add add_1 0000_0000_1000
DEFINE add add_mrs0 AC_ROM_MR0
DEFINE add add_mrs0_quad_rank AC_ROM_MR0_QUAD_RANK
DEFINE add add_mrs1 AC_ROM_MR1
DEFINE add add_mrs1_calib AC_ROM_MR1_CALIB
DEFINE add add_mrs2 AC_ROM_MR2
DEFINE add add_mrs2_calib AC_ROM_MR2_CALIB

CLASS rdata_en 1
DEFINE rdata_en rdata_en_0 0
DEFINE rdata_en rdata_en_1 1

CLASS wdata_valid 1
DEFINE wdata_valid wdata_valid_0 0
DEFINE wdata_valid wdata_valid_1 1

TEMPLATE cs.cmd.reset.ba.add.wdata_valid.rdata_en

# Generic commands
LABEL ac_nop cs_off | cmd_nop | reset_1 | ba_0 | add_0 | wdata_valid_0 | rdata_en_0

# Initialization commands
LABEL ac_init_reset_0 cs_off | cmd_nop | reset_0 | ba_0 | add_0 | wdata_valid_0 | rdata_en_0
LABEL ac_mrs0 cs_on | cmd_mrs | reset_1 | ba_0 | add_mrs0 | wdata_valid_0 | rdata_en_0
LABEL ac_mrs0_quad_rank cs_on | cmd_mrs | reset_1 | ba_0 | add_mrs0_quad_rank | wdata_valid_0 | rdata_en_0
LABEL ac_mrs1 cs_on | cmd_mrs | reset_1 | ba_1 | add_mrs1 | wdata_valid_0 | rdata_en_0
LABEL ac_mrs1_calib cs_on | cmd_mrs | reset_1 | ba_1 | add_mrs1_calib | wdata_valid_0 | rdata_en_0
LABEL ac_mrs2 cs_on | cmd_mrs | ba_2 | add_mrs2 | reset_1 | wdata_valid_0 | rdata_en_0
LABEL ac_mrs2_calib cs_on | cmd_mrs | ba_2 | add_mrs2_calib | reset_1 | wdata_valid_0 | rdata_en_0

# Write Commands
LABEL ac_write_bank_0_col_0 cs_on_all | cmd_write | reset_1 | ba_4 | add_0 | wdata_valid_0 | rdata_en_0
LABEL ac_write_bank_0_col_1 cs_on_all | cmd_write | reset_1 | ba_4 | add_1 | wdata_valid_0 | rdata_en_0
LABEL ac_write_bank_1_col_0 cs_on_all | cmd_write | reset_1 | ba_8 | add_0 | wdata_valid_0 | rdata_en_0
LABEL ac_write_bank_1_col_1 cs_on_all | cmd_write | reset_1 | ba_8 | add_1 | wdata_valid_0 | rdata_en_0
LABEL ac_write_0 cs_on_all | cmd_write | reset_1 | ba_4 | add_0 | wdata_valid_0 | rdata_en_0
LABEL ac_write_1 cs_on_all | cmd_write | reset_1 | ba_8 | add_0 | wdata_valid_0 | rdata_en_0
LABEL ac_write_data cs_off | cmd_nop | reset_1 | ba_0 | add_0 | wdata_valid_1 | rdata_en_0

# Read Commands
LABEL ac_read_0 cs_on_all | cmd_read | ba_4 | reset_1 | add_0 | wdata_valid_0 | rdata_en_1
LABEL ac_read_1 cs_on_all | cmd_read | ba_8 | reset_1 | add_0 | wdata_valid_0 | rdata_en_1
LABEL ac_read_bank_0_col_0 cs_on_all | cmd_read | ba_4 | reset_1 | add_0 | wdata_valid_0 | rdata_en_1
LABEL ac_read_bank_0_col_1 cs_on_all | cmd_read | ba_4 | reset_1 | add_1 | wdata_valid_0 | rdata_en_1
LABEL ac_read_bank_1_col_0 cs_on_all | cmd_read | ba_8 | reset_1 | add_0 | wdata_valid_0 | rdata_en_1
LABEL ac_read_bank_1_col_1 cs_on_all | cmd_read | ba_8 | reset_1 | add_1 | wdata_valid_0 | rdata_en_1
