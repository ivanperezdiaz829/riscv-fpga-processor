NUMBER OF ADDRESS BITS: 6

CLASS cs 2
DEFINE cs cs_on 01
DEFINE cs cs_on_all 00
DEFINE cs cs_opp 10
DEFINE cs cs_off 11

CLASS cmd 2 # we#, ref#
DEFINE cmd cmd_nop 11
DEFINE cmd cmd_mrs 00
DEFINE cmd cmd_read 11
DEFINE cmd cmd_write 01
DEFINE cmd cmd_ref 10

CLASS ba 3
DEFINE ba ba_0 000
DEFINE ba ba_1 001
DEFINE ba ba_2 010
DEFINE ba ba_3 011
DEFINE ba ba_4 100
DEFINE ba ba_5 101
DEFINE ba ba_6 110
DEFINE ba ba_7 111

CLASS add 10 MEM_ADDR_WIDTH 0
DEFINE add add_0 00_0000_0000
DEFINE add add_1 00_0000_1000
DEFINE add add_mrs AC_ROM_MR0
DEFINE add add_mrs_calib_dll_off AC_ROM_MR0_CALIB_DLL_OFF
DEFINE add add_mrs_calib_dll_on AC_ROM_MR0_CALIB_DLL_ON

CLASS rdata_en 1
DEFINE rdata_en rdata_en_0 0
DEFINE rdata_en rdata_en_1 1

CLASS wdata_valid 1
DEFINE wdata_valid wdata_valid_0 0
DEFINE wdata_valid wdata_valid_1 1

TEMPLATE cs.cmd.ba.add.wdata_valid.rdata_en

# Generic commands
LABEL ac_nop cs_off | cmd_nop | ba_0 | add_0 | wdata_valid_0 | rdata_en_0

# Initialization commands
# Note that the dummy MRS commands and the first valid MRS command must all
# be issued at consecutive clock cycles per spec, hence cs_on_all
LABEL ac_mrs_dummy cs_on_all | cmd_mrs | ba_0 | add_0 | wdata_valid_0 | rdata_en_0
LABEL ac_mrs_calib_dll_off cs_opp | cmd_mrs | ba_0 | add_mrs_calib_dll_off | wdata_valid_0 | rdata_en_0
LABEL ac_mrs_calib_dll_on cs_on | cmd_mrs | ba_0 | add_mrs_calib_dll_on | wdata_valid_0 | rdata_en_0
LABEL ac_mrs cs_on | cmd_mrs | ba_0 | add_mrs | wdata_valid_0 | rdata_en_0
LABEL ac_ref_0 cs_on | cmd_ref | ba_0 | add_0 | wdata_valid_0 | rdata_en_0
LABEL ac_ref_1 cs_on | cmd_ref | ba_1 | add_0 | wdata_valid_0 | rdata_en_0
LABEL ac_ref_2 cs_on | cmd_ref | ba_2 | add_0 | wdata_valid_0 | rdata_en_0
LABEL ac_ref_3 cs_on | cmd_ref | ba_3 | add_0 | wdata_valid_0 | rdata_en_0
LABEL ac_ref_4 cs_on | cmd_ref | ba_4 | add_0 | wdata_valid_0 | rdata_en_0
LABEL ac_ref_5 cs_on | cmd_ref | ba_5 | add_0 | wdata_valid_0 | rdata_en_0
LABEL ac_ref_6 cs_on | cmd_ref | ba_6 | add_0 | wdata_valid_0 | rdata_en_0
LABEL ac_ref_7 cs_on | cmd_ref | ba_7 | add_0 | wdata_valid_0 | rdata_en_0

# Write Commands
LABEL ac_write_bank_0_col_0 cs_on | cmd_write | ba_0 | add_0 | wdata_valid_0 | rdata_en_0
LABEL ac_write_bank_0_col_1 cs_on | cmd_write | ba_0 | add_1 | wdata_valid_0 | rdata_en_0
LABEL ac_write_bank_1_col_0 cs_on | cmd_write | ba_7 | add_0 | wdata_valid_0 | rdata_en_0
LABEL ac_write_bank_1_col_1 cs_on | cmd_write | ba_7 | add_1 | wdata_valid_0 | rdata_en_0
LABEL ac_write_0 cs_on | cmd_write | ba_0 | add_0 | wdata_valid_0 | rdata_en_0
LABEL ac_write_1 cs_on | cmd_write | ba_1 | add_0 | wdata_valid_0 | rdata_en_0
LABEL ac_write_data cs_off | cmd_nop | ba_0 | add_0 | wdata_valid_1 | rdata_en_0

# Read Commands
LABEL ac_read_0 cs_on | cmd_read | ba_0 | add_0 | wdata_valid_0 | rdata_en_1
LABEL ac_read_1 cs_on | cmd_read | ba_1 | add_0 | wdata_valid_0 | rdata_en_1
LABEL ac_read_bank_0_col_0 cs_on | cmd_read | ba_0 | add_0 | wdata_valid_0 | rdata_en_1
LABEL ac_read_bank_0_col_1 cs_on | cmd_read | ba_0 | add_1 | wdata_valid_0 | rdata_en_1
LABEL ac_read_bank_1_col_0 cs_on | cmd_read | ba_7 | add_0 | wdata_valid_0 | rdata_en_1
LABEL ac_read_bank_1_col_1 cs_on | cmd_read | ba_7 | add_1 | wdata_valid_0 | rdata_en_1
LABEL ac_read_data cs_off | cmd_nop | ba_0 | add_0 | wdata_valid_0 | rdata_en_1
