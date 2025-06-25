NUMBER OF ADDRESS BITS: 7

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

TEMPLATE cmd.jump.jump_reg.ac.do.dm

# STICKY commands will return leaving the interface in a non-idle state

# The idle instruction MUST ALWAYS be the first one in the ROM or crazy
# things will happen @ start-up ! ! ! 
LABEL IDLE cmd_ret | jump_0 | jump_reg_0 | ac_init_reset_0_cke_0 | do_0 | dm_0 # IDLE

# NOTE: DDR3 is very tight for space, so for the DDR3 specific functions, where
# possible, we remove the final return instruction and instead have the last
# instruction jump to this label to perform the return.
LABEL RETURN cmd_ret | jump_0 | jump_reg_0 | ac_des | do_0 | dm_0 # return 

LABEL MRS0_DLL_RESET cmd_def | jump_1 | jump_reg_0 | ac_mrs0_dll_reset | do_0 | dm_0 # MRS0_DLL_RESET and Jump to RETURN

LABEL MRS1 cmd_def | jump_1 | jump_reg_0 | ac_mrs1 | do_0 | dm_0 # MRS1 and Jump to RETURN

LABEL MRS2 cmd_def | jump_1 | jump_reg_0 | ac_mrs2 | do_0 | dm_0 # MRS2 and Jump to RETURN

LABEL MRS3 cmd_def | jump_1 | jump_reg_0 | ac_mrs3 | do_0 | dm_0 # MRS3 and Jump to RETURN

LABEL ZQCL cmd_def | jump_1 | jump_reg_0 | ac_zqcl | do_0 | dm_0 # ZQCL and Jump to RETURN

LABEL MRS0_USER cmd_def | jump_1 | jump_reg_0 | ac_mrs0_user | do_0 | dm_0 # MRS0 and Jump to RETURN

# Mirrored version of the MRS commands for multi-rank designs
LABEL MRS0_DLL_RESET_MIRR cmd_def | jump_1 | jump_reg_0 | ac_mrs0_dll_reset_mirr | do_0 | dm_0 # MRS0_DLL_RESET and Jump to RETURN

LABEL MRS1_MIRR cmd_def | jump_1 | jump_reg_0 | ac_mrs1_mirr | do_0 | dm_0 # MRS1 and Jump to RETURN

LABEL MRS2_MIRR cmd_def | jump_1 | jump_reg_0 | ac_mrs2_mirr | do_0 | dm_0 # MRS2 and Jump to RETURN

LABEL MRS3_MIRR cmd_def | jump_1 | jump_reg_0 | ac_mrs3_mirr | do_0 | dm_0 # MRS3 and Jump to RETURN

LABEL MRS0_USER_MIRR cmd_def | jump_1 | jump_reg_0 | ac_mrs0_user_mirr | do_0 | dm_0 # MRS0 and Jump to RETURN

# Activate banks 0 and 1
LABEL ACTIVATE_0_AND_1 cmd_def | jump_0 | jump_reg_0 | ac_act_0 | do_0 | dm_0
LABEL ACTIVATE_0_AND_1_WAIT1 cmd_def | jump_1 | jump_reg_0 | ac_des | do_0 | dm_0 # NOP
LABEL ACTIVATE_1 cmd_def | jump_0 | jump_reg_0 | ac_act_1 | do_0 | dm_0
LABEL ACTIVATE_0_AND_1_WAIT2 cmd_def | jump_1 | jump_reg_1 | ac_des | do_0 | dm_0 # NOP
LABEL __NL cmd_ret | jump_0 | jump_reg_0 | ac_des | do_0 | dm_0 # return

# Precharge all banks
LABEL PRECHARGE_ALL cmd_def | jump_0 | jump_reg_0 | ac_pre_all | do_0 | dm_0
LABEL __NL cmd_ret | jump_0 | jump_reg_0 | ac_des | do_0 | dm_0 # return

# Refresh
LABEL REFRESH_ALL cmd_def | jump_0 | jump_reg_0 | ac_ref | do_0 | dm_0
LABEL __NL cmd_def | jump_1 | jump_reg_0 | ac_des | do_0 | dm_0 # NOP
LABEL __NL cmd_ret | jump_0 | jump_reg_0 | ac_des | do_0 | dm_0 # return

# Guaranteed Writes
LABEL GUARANTEED_WRITE cmd_def | jump_0 | jump_reg_0 | ac_write_bank_0_col_1 | do_5 | dm_0
LABEL GUARANTEED_WRITE_WAIT2 cmd_def | jump_1 | jump_reg_2 | ac_write_data | do_5 | dm_0
LABEL __NL cmd_def | jump_0 | jump_reg_0 | ac_write_bank_1_col_0 | do_5 | dm_0
LABEL GUARANTEED_WRITE_WAIT0 cmd_def | jump_1 | jump_reg_0 | ac_write_data | do_5 | dm_0
LABEL __NL cmd_def | jump_0 | jump_reg_0 | ac_write_bank_1_col_1 | do_A | dm_0
LABEL GUARANTEED_WRITE_WAIT3 cmd_def | jump_1 | jump_reg_3 | ac_write_data | do_A | dm_0
LABEL __NL cmd_def | jump_0 | jump_reg_0 | ac_write_bank_0_col_0 | do_A | dm_0
LABEL GUARANTEED_WRITE_WAIT1 cmd_def | jump_1 | jump_reg_1 | ac_write_data | do_A | dm_0
LABEL __NL cmd_ret | jump_0 | jump_reg_0 | ac_des | do_0 | dm_0 # return

# LFSR WRITE READ
LABEL LFSR_WR_RD_BANK_0_WL_1 cmd_def | jump_1 | jump_reg_2 | ac_write_bank_0_col_0_nodata_wl_1 | do_0 | dm_0 # Write Command + DQS enable
LABEL LFSR_WR_RD_BANK_0 cmd_def | jump_1 | jump_reg_2 | ac_write_bank_0_col_0_nodata | do_0 | dm_0 # Write command
LABEL LFSR_WR_RD_BANK_0_NOP cmd_def | jump_1 | jump_reg_3 | ac_des_odt_1 | do_0 | dm_0 # NOP - latency spacer
LABEL LFSR_WR_RD_BANK_0_DQS cmd_def | jump_0 | jump_reg_0 | ac_write_predata | do_0 | dm_0 # DQS enable
LABEL LFSR_WR_RD_BANK_0_DATA cmd_wdp_lfsr | jump_0 | jump_reg_0 | ac_write_data | do_1 | dm_0 # First bit of data
`if HALF_RATE
LABEL __NL cmd_wdp_lfsr | jump_0 | jump_reg_0 | ac_write_data | do_1 | dm_0
`endif
`if FULL_RATE
LABEL __NL cmd_wdp_lfsr | jump_0 | jump_reg_0 | ac_write_data | do_1 | dm_0
LABEL __NL cmd_wdp_lfsr | jump_0 | jump_reg_0 | ac_write_data | do_1 | dm_0
LABEL __NL cmd_wdp_lfsr | jump_0 | jump_reg_0 | ac_write_data | do_1 | dm_0
`endif
LABEL __NL cmd_def | jump_0 | jump_reg_0 | ac_write_postdata | do_0 | dm_0
LABEL __NL cmd_def | jump_0 | jump_reg_0 | ac_des | do_0 | dm_0
`if HALF_RATE
LABEL __NL cmd_def | jump_0 | jump_reg_0 | ac_des | do_0 | dm_0
`endif
`if FULL_RATE
LABEL __NL cmd_def | jump_0 | jump_reg_0 | ac_des | do_0 | dm_0
LABEL __NL cmd_def | jump_0 | jump_reg_0 | ac_des | do_0 | dm_0
LABEL __NL cmd_def | jump_0 | jump_reg_0 | ac_des | do_0 | dm_0
`endif
LABEL __NL cmd_rdp_lfsr | jump_0 | jump_reg_0 | ac_read_bank_0_0 | do_0 | dm_0
`if HALF_RATE
LABEL __NL cmd_rdp_lfsr | jump_0 | jump_reg_0 | ac_read_en | do_0 | dm_0
`endif
`if FULL_RATE
LABEL __NL cmd_rdp_lfsr | jump_0 | jump_reg_0 | ac_read_en | do_0 | dm_0
LABEL __NL cmd_rdp_lfsr | jump_0 | jump_reg_0 | ac_read_en | do_0 | dm_0
LABEL __NL cmd_rdp_lfsr | jump_0 | jump_reg_0 | ac_read_en | do_0 | dm_0
`endif
LABEL LFSR_WR_RD_BANK_0_WAIT cmd_def | jump_1 | jump_reg_1 | ac_des | do_0 | dm_0
LABEL __NL cmd_def | jump_1 | jump_reg_0 | ac_des | do_0 | dm_0 # reg_0 jnz
LABEL __NL cmd_ret | jump_0 | jump_reg_0 | ac_des | do_0 | dm_0 # return

# LFSR WRITE READ DM
LABEL LFSR_WR_RD_DM_BANK_0_WL_1 cmd_def | jump_1 | jump_reg_2 | ac_write_bank_0_col_0_nodata_wl_1 | do_0 | dm_0 # Write Command + DQS enable
LABEL LFSR_WR_RD_DM_BANK_0 cmd_def | jump_1 | jump_reg_2 | ac_write_bank_0_col_0_nodata | do_0 | dm_0 # Write command
LABEL LFSR_WR_RD_DM_BANK_0_NOP cmd_def | jump_1 | jump_reg_3 | ac_des_odt_1 | do_0 | dm_0 # NOP - latency spacer
LABEL LFSR_WR_RD_DM_BANK_0_DQS cmd_def | jump_0 | jump_reg_0 | ac_write_predata | do_0 | dm_0 # DQS enable
LABEL LFSR_WR_RD_DM_BANK_0_DATA cmd_wdp_dm_lfsr | jump_0 | jump_reg_0 | ac_write_data | do_1 | dm_0 # First bit of data
`if HALF_RATE
LABEL __NL cmd_wdp_dm_lfsr | jump_0 | jump_reg_0 | ac_write_data | do_1 | dm_0
`endif
`if FULL_RATE
LABEL __NL cmd_wdp_dm_lfsr | jump_0 | jump_reg_0 | ac_write_data | do_1 | dm_0
LABEL __NL cmd_wdp_dm_lfsr | jump_0 | jump_reg_0 | ac_write_data | do_1 | dm_0
LABEL __NL cmd_wdp_dm_lfsr | jump_0 | jump_reg_0 | ac_write_data | do_1 | dm_0
`endif
LABEL __NL cmd_def | jump_0 | jump_reg_0 | ac_write_postdata | do_0 | dm_0
LABEL __NL cmd_def | jump_0 | jump_reg_0 | ac_des | do_0 | dm_0
`if HALF_RATE
LABEL __NL cmd_def | jump_0 | jump_reg_0 | ac_des | do_0 | dm_0
`endif
`if FULL_RATE
LABEL __NL cmd_def | jump_0 | jump_reg_0 | ac_des | do_0 | dm_0
LABEL __NL cmd_def | jump_0 | jump_reg_0 | ac_des | do_0 | dm_0
LABEL __NL cmd_def | jump_0 | jump_reg_0 | ac_des | do_0 | dm_0
`endif
LABEL __NL cmd_rdp_dm_lfsr | jump_0 | jump_reg_0 | ac_read_bank_0_0 | do_0 | dm_0
`if HALF_RATE
LABEL __NL cmd_rdp_dm_lfsr | jump_0 | jump_reg_0 | ac_read_en | do_0 | dm_0
`endif
`if FULL_RATE
LABEL __NL cmd_rdp_dm_lfsr | jump_0 | jump_reg_0 | ac_read_en | do_0 | dm_0
LABEL __NL cmd_rdp_dm_lfsr | jump_0 | jump_reg_0 | ac_read_en | do_0 | dm_0
LABEL __NL cmd_rdp_dm_lfsr | jump_0 | jump_reg_0 | ac_read_en | do_0 | dm_0
`endif
LABEL LFSR_WR_RD_DM_BANK_0_WAIT cmd_def | jump_1 | jump_reg_1 | ac_des | do_0 | dm_0
LABEL __NL cmd_def | jump_1 | jump_reg_0 | ac_des | do_0 | dm_0 # reg_0 jnz
LABEL __NL cmd_ret | jump_0 | jump_reg_0 | ac_des | do_0 | dm_0 # return


# Clear DQS Enable
LABEL CLEAR_DQS_ENABLE cmd_def | jump_0 | jump_reg_0 | ac_read_bank_0_1_norden | do_x | dm_0
LABEL __NL cmd_def | jump_0 | jump_reg_0 | ac_des | do_x | dm_0
LABEL __NL cmd_ret | jump_0 | jump_reg_0 | ac_des | do_0 | dm_0 # return

# Guaranteed Read test command
`if QUARTER_RATE
LABEL GUARANTEED_READ cmd_def | jump_1 | jump_reg_0 | ac_read_bank_0_1_norden | do_5 | dm_0
`else
LABEL GUARANTEED_READ cmd_def | jump_0 | jump_reg_0 | ac_read_bank_0_1_norden | do_5 | dm_0
`endif
`if HALF_RATE
LABEL __NL cmd_def | jump_1 | jump_reg_0 | ac_nop | do_5 | dm_0
`endif
`if FULL_RATE
LABEL __NL cmd_def | jump_0 | jump_reg_0 | ac_nop | do_5 | dm_0
LABEL __NL cmd_def | jump_0 | jump_reg_0 | ac_nop | do_5 | dm_0
LABEL __NL cmd_def | jump_1 | jump_reg_0 | ac_nop | do_5 | dm_0
`endif
LABEL __NL cmd_rdp | jump_0 | jump_reg_0 | ac_read_bank_0_1 | do_5 | dm_0
`if HALF_RATE
LABEL __NL cmd_rdp | jump_0 | jump_reg_0 | ac_read_en | do_5 | dm_0
`endif
`if FULL_RATE
LABEL __NL cmd_rdp | jump_0 | jump_reg_0 | ac_read_en | do_5 | dm_0
LABEL __NL cmd_rdp | jump_0 | jump_reg_0 | ac_read_en | do_5 | dm_0
LABEL __NL cmd_rdp | jump_0 | jump_reg_0 | ac_read_en | do_5 | dm_0
`endif
`if QUARTER_RATE
LABEL GUARANTEED_READ_CONT cmd_def | jump_1 | jump_reg_1 | ac_read_bank_0_1_norden | do_5 | dm_0
`else
LABEL GUARANTEED_READ_CONT cmd_def | jump_0 | jump_reg_0 | ac_read_bank_0_1_norden | do_5 | dm_0
`endif
`if HALF_RATE
LABEL __NL cmd_def | jump_1 | jump_reg_1 | ac_nop | do_5 | dm_0
`endif
`if FULL_RATE
LABEL __NL cmd_def | jump_0 | jump_reg_0 | ac_nop | do_5 | dm_0
LABEL __NL cmd_def | jump_0 | jump_reg_0 | ac_nop | do_5 | dm_0
LABEL __NL cmd_def | jump_1 | jump_reg_1 | ac_nop | do_5 | dm_0
`endif
LABEL __NL cmd_ret | jump_0 | jump_reg_0 | ac_des | do_0 | dm_0 # return

# Read B2B composite test command
LABEL READ_B2B cmd_rdp | jump_0 | jump_reg_0 | ac_read_bank_0_0 | do_A | dm_0
`if HALF_RATE
LABEL __NL cmd_rdp | jump_0 | jump_reg_0 | ac_read_en | do_A | dm_0
`endif
`if FULL_RATE
LABEL __NL cmd_rdp | jump_0 | jump_reg_0 | ac_read_en | do_A | dm_0
LABEL __NL cmd_rdp | jump_0 | jump_reg_0 | ac_read_en | do_A | dm_0
LABEL __NL cmd_rdp | jump_0 | jump_reg_0 | ac_read_en | do_A | dm_0
`endif
LABEL __NL cmd_rdp | jump_0 | jump_reg_0 | ac_read_bank_1_0 | do_5 | dm_0
`if HALF_RATE
LABEL __NL cmd_rdp | jump_0 | jump_reg_0 | ac_read_en | do_5 | dm_0
`endif
`if FULL_RATE
LABEL __NL cmd_rdp | jump_0 | jump_reg_0 | ac_read_en | do_5 | dm_0
LABEL __NL cmd_rdp | jump_0 | jump_reg_0 | ac_read_en | do_5 | dm_0
LABEL __NL cmd_rdp | jump_0 | jump_reg_0 | ac_read_en | do_5 | dm_0
`endif
LABEL READ_B2B_WAIT1 cmd_def | jump_1 | jump_reg_1 | ac_des | do_0 | dm_0
LABEL __NL cmd_rdp | jump_0 | jump_reg_0 | ac_read_bank_0_1 | do_5 | dm_0
`if HALF_RATE
LABEL __NL cmd_rdp | jump_0 | jump_reg_0 | ac_read_en | do_5 | dm_0
`endif
`if FULL_RATE
LABEL __NL cmd_rdp | jump_0 | jump_reg_0 | ac_read_en | do_5 | dm_0
LABEL __NL cmd_rdp | jump_0 | jump_reg_0 | ac_read_en | do_5 | dm_0
LABEL __NL cmd_rdp | jump_0 | jump_reg_0 | ac_read_en | do_5 | dm_0
`endif
LABEL __NL cmd_rdp | jump_0 | jump_reg_0 | ac_read_bank_1_1 | do_A | dm_0
`if HALF_RATE
LABEL __NL cmd_rdp | jump_0 | jump_reg_0 | ac_read_en | do_A | dm_0
`endif
`if FULL_RATE
LABEL __NL cmd_rdp | jump_0 | jump_reg_0 | ac_read_en | do_A | dm_0
LABEL __NL cmd_rdp | jump_0 | jump_reg_0 | ac_read_en | do_A | dm_0
LABEL __NL cmd_rdp | jump_0 | jump_reg_0 | ac_read_en | do_A | dm_0
`endif
LABEL __NL cmd_def | jump_0 | jump_reg_0 | ac_read_bank_0_1_norden | do_0 | dm_0
LABEL READ_B2B_WAIT2 cmd_def | jump_1 | jump_reg_2 | ac_des | do_0 | dm_0
LABEL __NL cmd_def | jump_1 | jump_reg_0 | ac_des | do_0 | dm_0 # reg_0 jnz
LABEL __NL cmd_def | jump_1 | jump_reg_3 | ac_des | do_0 | dm_0 # reg_3 jnz
LABEL __NL cmd_ret | jump_0 | jump_reg_0 | ac_des | do_0 | dm_0 # return

# Reset = 0 , CKE = 0
LABEL INIT_RESET_0_CKE_0 cmd_def | jump_0 | jump_reg_0 | ac_init_reset_0_cke_0 | do_0 | dm_0 # INIT_RESET_0_CKE_0
LABEL INIT_RESET_0_CKE_0_inloop cmd_def | jump_0 | jump_reg_0 | ac_init_reset_0_cke_0 | do_0 | dm_0 # INIT_RESET_0_CKE_0_inloop
LABEL __NL cmd_def | jump_1 | jump_reg_1 | ac_init_reset_0_cke_0 | do_0 | dm_0 # reg_1 jnz
LABEL __NL cmd_def | jump_1 | jump_reg_0 | ac_init_reset_0_cke_0 | do_0 | dm_0 # reg_0 jnz
LABEL __NL cmd_ret | jump_0 | jump_reg_0 | ac_init_reset_0_cke_0 | do_0 | dm_0 # INIT_RESET_0_CKE_0 = STICKY

# Reset = 1 , CKE = 0
LABEL INIT_RESET_1_CKE_0 cmd_def | jump_0 | jump_reg_0 | ac_init_reset_1_cke_0 | do_0 | dm_0 # INIT_RESET_1_CKE_0
LABEL INIT_RESET_1_CKE_0_inloop_1 cmd_def | jump_0 | jump_reg_0 | ac_init_reset_1_cke_0 | do_0 | dm_0 # INIT_RESET_1_CKE_0_inloop_1
LABEL __NL cmd_def | jump_0 | jump_reg_0 | ac_init_reset_1_cke_0 | do_0 | dm_0 # INIT_RESET_1_CKE_0
LABEL __NL cmd_def | jump_0 | jump_reg_0 | ac_init_reset_1_cke_0 | do_0 | dm_0 # INIT_RESET_1_CKE_0
LABEL __NL cmd_def | jump_1 | jump_reg_1 | ac_init_reset_1_cke_0 | do_0 | dm_0 # reg_1 jnz
LABEL __NL cmd_def | jump_1 | jump_reg_0 | ac_init_reset_1_cke_0 | do_0 | dm_0 # reg_0 jnz
LABEL __NL cmd_ret | jump_0 | jump_reg_0 | ac_init_reset_1_cke_0 | do_0 | dm_0 # INIT_RESET_1_CKE_0 = STICKY

# RDIMM command
LABEL RDIMM_CMD cmd_def | jump_1 | jump_reg_0 | ac_rdimm | do_0 | dm_0 # RDIMM command and Jump to RETURN

LABEL IDLE_LOOP2 cmd_def | jump_1 | jump_reg_0 | ac_des | do_0 | dm_0 # reg_0 jnz
LABEL IDLE_LOOP1 cmd_def | jump_1 | jump_reg_1 | ac_des | do_0 | dm_0 # reg_1 jnz
LABEL __NL       cmd_ret | jump_0 | jump_reg_0 | ac_des | do_0 | dm_0 # IDLE = STICKY
	
# Read for tracking
`if QUARTER_RATE
LABEL SGLE_READ cmd_rdp | jump_0 | jump_reg_0 | ac_read_tracking | do_A | dm_0
`else
LABEL SGLE_READ cmd_rdp | jump_0 | jump_reg_0 | ac_read_bank_1_0 | do_A | dm_0
`endif
LABEL __NL cmd_ret | jump_0 | jump_reg_0 | ac_des | do_0 | dm_0 # return


`if GUARANTEED_READ_BRINGUP_TEST

################################################
# Guaranteed Read Test support
################################################

# 0/1/A/5 Guaranteed Writes
LABEL GUARANTEED_WRITE_0_1_A_5 cmd_def | jump_0 | jump_reg_0 | ac_write_bank_0_col_1 | do_0 | dm_0
LABEL GUARANTEED_WRITE_0_1_A_5_WAIT0 cmd_def | jump_1 | jump_reg_0 | ac_write_data | do_0 | dm_0
LABEL __NL cmd_def | jump_0 | jump_reg_0 | ac_write_bank_1_col_0 | do_A | dm_0
LABEL GUARANTEED_WRITE_0_1_A_5_WAIT1 cmd_def | jump_1 | jump_reg_1 | ac_write_data | do_A | dm_0
LABEL __NL cmd_def | jump_0 | jump_reg_0 | ac_write_bank_1_col_1 | do_1 | dm_0
LABEL GUARANTEED_WRITE_0_1_A_5_WAIT2 cmd_def | jump_1 | jump_reg_2 | ac_write_data | do_1 | dm_0
LABEL __NL cmd_def | jump_0 | jump_reg_0 | ac_write_bank_0_col_0 | do_5 | dm_0
LABEL GUARANTEED_WRITE_0_1_A_5_WAIT3 cmd_def | jump_1 | jump_reg_3 | ac_write_data | do_5 | dm_0
LABEL __NL cmd_ret | jump_0 | jump_reg_0 | ac_des | do_0 | dm_0 # return

# read test
LABEL DO_TEST_READ cmd_rdp | jump_0 | jump_reg_0 | ac_read_bank_1_0_norden | do_A | dm_0  # prologue of (0xAA)+
`if FULL_RATE
LABEL __NL         cmd_rdp | jump_0 | jump_reg_0 | ac_nop           | do_A | dm_0
LABEL __NL         cmd_rdp | jump_0 | jump_reg_0 | ac_nop           | do_A | dm_0
`endif
LABEL __NL         cmd_rdp | jump_1 | jump_reg_0 | ac_nop           | do_A | dm_0
LABEL __NL         cmd_rdp | jump_0 | jump_reg_0 | ac_read_bank_1_1 | do_1 | dm_0         # read 0xff
LABEL __NL         cmd_rdp | jump_0 | jump_reg_0 | ac_read_en       | do_1 | dm_0
`if FULL_RATE
LABEL __NL         cmd_rdp | jump_0 | jump_reg_0 | ac_read_en       | do_1 | dm_0
LABEL __NL         cmd_rdp | jump_0 | jump_reg_0 | ac_read_en       | do_1 | dm_0
`endif
LABEL __NL         cmd_rdp | jump_0 | jump_reg_0 | ac_read_bank_0_0 | do_5 | dm_0         # read 0x55
LABEL __NL         cmd_rdp | jump_0 | jump_reg_0 | ac_read_en       | do_5 | dm_0
`if FULL_RATE
LABEL __NL         cmd_rdp | jump_0 | jump_reg_0 | ac_read_en       | do_5 | dm_0
LABEL __NL         cmd_rdp | jump_0 | jump_reg_0 | ac_read_en       | do_5 | dm_0
`endif
LABEL __NL         cmd_rdp | jump_0 | jump_reg_0 | ac_read_bank_1_1 | do_1 | dm_0         # read 0xff
LABEL __NL         cmd_rdp | jump_0 | jump_reg_0 | ac_read_en       | do_1 | dm_0
`if FULL_RATE
LABEL __NL         cmd_rdp | jump_0 | jump_reg_0 | ac_read_en       | do_1 | dm_0
LABEL __NL         cmd_rdp | jump_0 | jump_reg_0 | ac_read_en       | do_1 | dm_0
`endif
LABEL __NL         cmd_rdp | jump_0 | jump_reg_0 | ac_read_bank_0_0 | do_5 | dm_0         # read 0x55
LABEL __NL         cmd_rdp | jump_0 | jump_reg_0 | ac_read_en       | do_5 | dm_0
`if FULL_RATE
LABEL __NL         cmd_rdp | jump_0 | jump_reg_0 | ac_read_en       | do_5 | dm_0
LABEL __NL         cmd_rdp | jump_0 | jump_reg_0 | ac_read_en       | do_5 | dm_0
`endif
LABEL DO_TEST_READ_POST_WAIT cmd_rdp | jump_0 | jump_reg_0 | ac_read_bank_1_0_norden | do_A | dm_0 # epilogue of (0xAA)+
`if FULL_RATE
LABEL __NL         cmd_rdp | jump_0 | jump_reg_0 | ac_nop           | do_A | dm_0
LABEL __NL         cmd_rdp | jump_0 | jump_reg_0 | ac_nop           | do_A | dm_0
`endif
LABEL __NL         cmd_rdp | jump_1 | jump_reg_1 | ac_nop           | do_A | dm_0
LABEL __NL cmd_ret | jump_0 | jump_reg_0 | ac_des | do_0 | dm_0 # return


# clear buffer
LABEL DO_CLEAR_DI_BUF cmd_def | jump_0 | jump_reg_0 | ac_read_bank_0_1 | do_0 | dm_0
LABEL __NL         cmd_def | jump_1 | jump_reg_0 | ac_read_en       | do_0 | dm_0
LABEL __NL cmd_ret | jump_0 | jump_reg_0 | ac_des | do_0 | dm_0 # return

`endif # GUARANTEED_READ_BRINGUP_TEST
