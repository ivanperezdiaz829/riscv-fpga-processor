NUMBER OF ADDRESS BITS: 7

# Reserved For Future Use
CLASS rff 4
DEFINE rff rff_0 0000

# Commands
CLASS cmd 4
DEFINE cmd cmd_def 0000
DEFINE cmd cmd_rdp 0100
DEFINE cmd cmd_ret 1000
DEFINE cmd cmd_rdp_lfsr 0110
DEFINE cmd cmd_wdp_lfsr 0010
DEFINE cmd cmd_rdp_dm_lfsr 0111
DEFINE cmd cmd_wdp_dm_lfsr 0011

# DO address
CLASS do 4
DEFINE do do_0 0000
DEFINE do do_1 1100
DEFINE do do_A 0001
DEFINE do do_5 1101
DEFINE do do_x 1011
DEFINE do do_y 1001

# DM address
CLASS dm 3
DEFINE dm dm_0 000

# JUMP
CLASS jump 1
DEFINE jump jump_0 0
DEFINE jump jump_1 1

CLASS jump_reg 2
DEFINE jump_reg jump_reg_0 00
DEFINE jump_reg jump_reg_1 01
DEFINE jump_reg jump_reg_2 10
DEFINE jump_reg jump_reg_3 11

TEMPLATE rff.cmd.jump.jump_reg.ac.do.dm

# STICKY commands will return leaving the interface in a non-idle state

# The idle instruction MUST ALWAYS be the first one in the ROM or crazy
# things will happen @ start-up ! ! ! 
LABEL IDLE rff_0 | cmd_ret | jump_0 | jump_reg_0 | ac_nop | do_0 | dm_0 # IDLE

LABEL NOP rff_0 | cmd_def | jump_0 | jump_reg_0 | ac_nop | do_0 | dm_0 # NOP
LABEL __NL rff_0 | cmd_ret | jump_0 | jump_reg_0 | ac_nop | do_0 | dm_0 # return

LABEL IDLE_LOOP2 rff_0 | cmd_def | jump_1 | jump_reg_0 | ac_nop | do_0 | dm_0 # reg_0 jnz
LABEL IDLE_LOOP1 rff_0 | cmd_def | jump_1 | jump_reg_1 | ac_nop | do_0 | dm_0 # reg_1 jnz
LABEL __NL       rff_0 | cmd_ret | jump_0 | jump_reg_0 | ac_nop | do_0 | dm_0 # IDLE = STICKY
	
# Reset = 0
LABEL INIT_RESET_0 rff_0 | cmd_def | jump_0 | jump_reg_0 | ac_init_reset_0 | do_0 | dm_0 # INIT_RESET_0
LABEL INIT_RESET_0_inloop rff_0 | cmd_def | jump_0 | jump_reg_0 | ac_init_reset_0 | do_0 | dm_0 # INIT_RESET_0_inloop
LABEL __NL rff_0 | cmd_def | jump_1 | jump_reg_1 | ac_init_reset_0 | do_0 | dm_0 # reg_1 jnz
LABEL __NL rff_0 | cmd_def | jump_1 | jump_reg_0 | ac_init_reset_0 | do_0 | dm_0 # reg_0 jnz
LABEL __NL rff_0 | cmd_ret | jump_0 | jump_reg_0 | ac_init_reset_0 | do_0 | dm_0 # INIT_RESET_0 = STICKY

# Initialization MRS commands
LABEL MRS0 rff_0 | cmd_def | jump_0 | jump_reg_0 | ac_mrs0 | do_0 | dm_0 # MRS0
LABEL __NL rff_0 | cmd_ret | jump_0 | jump_reg_0 | ac_nop | do_0 | dm_0 # return
LABEL MRS0_QUAD_RANK rff_0 | cmd_def | jump_0 | jump_reg_0 | ac_mrs0_quad_rank | do_0 | dm_0 # MRS0_QUAD_RANK
LABEL __NL rff_0 | cmd_ret | jump_0 | jump_reg_0 | ac_nop | do_0 | dm_0 # return

LABEL MRS1 rff_0 | cmd_def | jump_0 | jump_reg_0 | ac_mrs1 | do_0 | dm_0 # MRS1
LABEL __NL rff_0 | cmd_ret | jump_0 | jump_reg_0 | ac_nop | do_0 | dm_0 # return

LABEL MRS2 rff_0 | cmd_def | jump_0 | jump_reg_0 | ac_mrs2 | do_0 | dm_0 # MRS2
LABEL __NL rff_0 | cmd_ret | jump_0 | jump_reg_0 | ac_nop | do_0 | dm_0 # return

# Set MRS before handoff to user
LABEL MRS1_CALIB rff_0 | cmd_def | jump_0 | jump_reg_0 | ac_mrs1_calib | do_0 | dm_0 # MRS1_CALIB
LABEL __NL rff_0 | cmd_ret | jump_0 | jump_reg_0 | ac_nop | do_0 | dm_0 # return

LABEL MRS2_CALIB rff_0 | cmd_def | jump_0 | jump_reg_0 | ac_mrs2_calib | do_0 | dm_0 # MRS2_CALIB
LABEL __NL rff_0 | cmd_ret | jump_0 | jump_reg_0 | ac_nop | do_0 | dm_0 # return

# Write 0 and 1
LABEL GUARANTEED_WRITE rff_0 | cmd_def | jump_0 | jump_reg_0 | ac_write_bank_0_col_1 | do_5 | dm_0 # ** WRITE 5 @ B0C1 - CMD
LABEL GUARANTEED_WRITE_WAIT0 rff_0 | cmd_def | jump_1 | jump_reg_0 | ac_write_data | do_5 | dm_0 # ** WRITE data and loop
LABEL __NL rff_0 | cmd_def | jump_0 | jump_reg_0 | ac_write_bank_1_col_0 | do_5 | dm_0 # ** WRITE 5 @ B1C0 - CMD
LABEL GUARANTEED_WRITE_WAIT1 rff_0 | cmd_def | jump_1 | jump_reg_1 | ac_write_data | do_5 | dm_0 # ** WRITE data and loop
LABEL __NL rff_0 | cmd_def | jump_0 | jump_reg_0 | ac_write_bank_1_col_1 | do_A | dm_0 # ** WRITE A @ B1C1 - CMD
LABEL GUARANTEED_WRITE_WAIT2 rff_0 | cmd_def | jump_1 | jump_reg_2 | ac_write_data | do_A | dm_0 # ** WRITE data and loop
LABEL __NL rff_0 | cmd_def | jump_0 | jump_reg_0 | ac_write_bank_0_col_0 | do_A | dm_0 # ** WRITE A @ B0C0 - CMD
LABEL GUARANTEED_WRITE_WAIT3 rff_0 | cmd_def | jump_1 | jump_reg_3 | ac_write_data | do_A | dm_0 # ** WRITE A data and loop
LABEL __NL rff_0 | cmd_ret | jump_0 | jump_reg_0 | ac_nop | do_0 | dm_0 # return

# Read B2B composite test
LABEL READ_B2B rff_0 | cmd_rdp | jump_0 | jump_reg_0 | ac_read_bank_0_col_0 | do_A | dm_0
LABEL __NL rff_0 | cmd_rdp | jump_0 | jump_reg_0 | ac_read_bank_1_col_0 | do_5 | dm_0
LABEL READ_B2B_WAIT1 rff_0 | cmd_def | jump_1 | jump_reg_1 | ac_nop | do_0 | dm_0
LABEL __NL rff_0 | cmd_rdp | jump_0 | jump_reg_0 | ac_read_bank_0_col_1 | do_5 | dm_0
LABEL __NL rff_0 | cmd_rdp | jump_0 | jump_reg_0 | ac_read_bank_1_col_1 | do_A | dm_0
LABEL READ_B2B_WAIT2 rff_0 | cmd_def | jump_1 | jump_reg_2 | ac_nop | do_0 | dm_0
LABEL __NL rff_0 | cmd_def | jump_1 | jump_reg_0 | ac_nop | do_0 | dm_0 # reg_0 jnz
LABEL __NL rff_0 | cmd_def | jump_1 | jump_reg_3 | ac_nop | do_0 | dm_0 # reg_3 jnz
LABEL __NL rff_0 | cmd_ret | jump_0 | jump_reg_0 | ac_nop | do_0 | dm_0 # return

# LFSR test
LABEL LFSR_WR_RD_BANK_0 rff_0 | cmd_def | jump_1 | jump_reg_2 | ac_write_0 | do_0 | dm_0 # ** WRITE @ 0 - CMD
LABEL LFSR_WR_RD_BANK_0_NOP rff_0 | cmd_def | jump_1 | jump_reg_3 | ac_nop | do_0 | dm_0 # Wait for write latency
LABEL LFSR_WR_RD_BANK_0_DATA rff_0 | cmd_wdp_lfsr | jump_0 | jump_reg_0 | ac_write_data | do_0 | dm_0 # ** WRITE data LFSR
LABEL __NL rff_0 | cmd_def | jump_0 | jump_reg_0 | ac_nop | do_0 | dm_0 # no-op
LABEL __NL rff_0 | cmd_def | jump_0 | jump_reg_0 | ac_nop | do_0 | dm_0 # no-op
LABEL __NL rff_0 | cmd_def | jump_0 | jump_reg_0 | ac_nop | do_0 | dm_0 # no-op
LABEL __NL rff_0 | cmd_def | jump_0 | jump_reg_0 | ac_nop | do_0 | dm_0 # no-op
LABEL __NL rff_0 | cmd_rdp_lfsr | jump_0 | jump_reg_0 | ac_read_0 | do_0 | dm_0 # ** READ @ 0 - CMD
LABEL LFSR_WR_RD_BANK_0_WAIT rff_0 | cmd_def | jump_1 | jump_reg_1 | ac_nop | do_0 | dm_0 # no-op
LABEL __NL rff_0 | cmd_def | jump_1 | jump_reg_0 | ac_nop | do_0 | dm_0 # reg_0 jnz
LABEL __NL rff_0 | cmd_ret | jump_0 | jump_reg_0 | ac_nop | do_0 | dm_0 # return

# LFSR test with DM
LABEL LFSR_WR_RD_DM_BANK_0 rff_0 | cmd_def | jump_1 | jump_reg_2 | ac_write_0 | do_0 | dm_0 # ** WRITE @ 0 - CMD
LABEL LFSR_WR_RD_DM_BANK_0_NOP rff_0 | cmd_def | jump_1 | jump_reg_3 | ac_nop | do_0 | dm_0 # Wait for write latency
LABEL LFSR_WR_RD_DM_BANK_0_DATA rff_0 | cmd_wdp_dm_lfsr | jump_0 | jump_reg_0 | ac_write_data | do_0 | dm_0 # ** WRITE data LFSR
LABEL __NL rff_0 | cmd_def | jump_0 | jump_reg_0 | ac_nop | do_0 | dm_0 # no-op
LABEL __NL rff_0 | cmd_def | jump_0 | jump_reg_0 | ac_nop | do_0 | dm_0 # no-op
LABEL __NL rff_0 | cmd_def | jump_0 | jump_reg_0 | ac_nop | do_0 | dm_0 # no-op
LABEL __NL rff_0 | cmd_def | jump_0 | jump_reg_0 | ac_nop | do_0 | dm_0 # no-op
LABEL __NL rff_0 | cmd_rdp_dm_lfsr | jump_0 | jump_reg_0 | ac_read_0 | do_0 | dm_0 # ** READ @ 0 - CMD
LABEL LFSR_WR_RD_DM_BANK_0_WAIT rff_0 | cmd_def | jump_1 | jump_reg_1 | ac_nop | do_0 | dm_0 # no-op
LABEL __NL rff_0 | cmd_def | jump_1 | jump_reg_0 | ac_nop | do_0 | dm_0 # reg_0 jnz
LABEL __NL rff_0 | cmd_ret | jump_0 | jump_reg_0 | ac_nop | do_0 | dm_0 # return

