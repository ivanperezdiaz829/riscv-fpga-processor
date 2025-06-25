# ====================================================
# Pin & Location Assignments for Cyclone Memory Board
# These are for the x16 memory device
#
# This board uses the following byte groups 
#
# For the x16:  DQS0 = 0T, DQS1 = 1B
# For the x8:   DQS0 = 1R
# ====================================================

set_location_assignment PIN_28 -to clock_source
set_location_assignment PIN_240 -to reset_n
set_location_assignment PIN_38 -to clk_to_sdram\[0\]
set_location_assignment PIN_39 -to clk_to_sdram_n\[0\]

set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"

#set_location_assignment PIN_152 -to x16_ddr_clk_fdbk_in
#set_location_assignment PIN_43 -to x16_ddr_clk_fdbk_out

# x16 address and command
set_location_assignment PIN_218 -to ddr_a\[0\]
set_location_assignment PIN_220 -to ddr_a\[10\]
set_location_assignment PIN_203 -to ddr_a\[11\]
set_location_assignment PIN_215 -to ddr_a\[1\]
set_location_assignment PIN_213 -to ddr_a\[2\]
set_location_assignment PIN_205 -to ddr_a\[3\]
set_location_assignment PIN_181 -to ddr_a\[4\]
set_location_assignment PIN_183 -to ddr_a\[5\]
set_location_assignment PIN_197 -to ddr_a\[6\]
set_location_assignment PIN_199 -to ddr_a\[7\]
set_location_assignment PIN_200 -to ddr_a\[8\]
set_location_assignment PIN_201 -to ddr_a\[9\]
set_location_assignment PIN_239 -to ddr_ba\[0\]
set_location_assignment PIN_222 -to ddr_ba\[1\]
set_location_assignment PIN_79 -to ddr_cas_n
set_location_assignment PIN_81 -to ddr_cke\[0\]
set_location_assignment PIN_86 -to ddr_cs_n\[0\]
set_location_assignment PIN_84 -to ddr_ras_n
set_location_assignment PIN_82 -to ddr_we_n

# x8 address and command
#set_location_assignment PIN_11 -to x8_ddr_a\[0\]
#set_location_assignment PIN_14 -to x8_ddr_a\[10\]
#set_location_assignment PIN_47 -to x8_ddr_a\[11\]
#set_location_assignment PIN_6 -to X8_ddr_a\[1\]
#set_location_assignment PIN_4 -to X8_ddr_a\[2\]
#set_location_assignment PIN_2 -to X8_ddr_a\[3\]
#set_location_assignment PIN_59 -to x8_ddr_a\[4\]
#set_location_assignment PIN_57 -to x8_ddr_a\[5\]
#set_location_assignment PIN_55 -to x8_ddr_a\[6\]
#set_location_assignment PIN_53 -to x8_ddr_a\[7\]
#set_location_assignment PIN_50 -to x8_ddr_a\[8\]
#set_location_assignment PIN_48 -to x8_ddr_a\[9\]
#set_location_assignment PIN_45 -to x8_ddr_ba\[0\]
#set_location_assignment PIN_19 -to x8_ddr_ba\[1\]
#set_location_assignment PIN_179 -to x8_ddr_cas_n
#set_location_assignment PIN_137 -to x8_ddr_cke\[0\]
#set_location_assignment PIN_122 -to x8_ddr_cs_n\[0\]
#set_location_assignment PIN_162 -to x8_ddr_ras_n
#set_location_assignment PIN_166 -to x8_ddr_we_n

#set_location_assignment PIN_153 -to x8_clock_source
#set_location_assignment PIN_29 -to x8_ddr_clk_fdbk_in
#set_location_assignment PIN_118 -to x8_ddr_clk_fdbk_out
#set_location_assignment PIN_144 -to x8_ddr_clk_to_sdram\[0\]
#set_location_assignment PIN_143 -to x8_ddr_clk_to_sdram_n\[0\]

# user i/o
set_location_assignment PIN_93 -to header\[0\]
set_location_assignment PIN_87 -to header\[10\]
set_location_assignment PIN_88 -to header\[11\]
set_location_assignment PIN_202 -to header\[12\]
set_location_assignment PIN_204 -to header\[13\]
set_location_assignment PIN_207 -to header\[14\]
set_location_assignment PIN_208 -to header\[15\]
set_location_assignment PIN_95 -to header\[1\]
set_location_assignment PIN_96 -to header\[2\]
set_location_assignment PIN_97 -to header\[3\]
set_location_assignment PIN_98 -to header\[4\]
set_location_assignment PIN_99 -to header\[5\]
set_location_assignment PIN_100 -to header\[6\]
set_location_assignment PIN_101 -to header\[7\]
set_location_assignment PIN_119 -to header\[8\]
set_location_assignment PIN_120 -to header\[9\]
set_location_assignment PIN_1 -to sev_seg_1_a
set_location_assignment PIN_5 -to sev_seg_1_b
set_location_assignment PIN_3 -to sev_seg_1_c
set_location_assignment PIN_8 -to sev_seg_1_d
set_location_assignment PIN_7 -to sev_seg_1_dp
set_location_assignment PIN_12 -to sev_seg_1_e
set_location_assignment PIN_15 -to sev_seg_1_f
set_location_assignment PIN_13 -to sev_seg_1_g
set_location_assignment PIN_49 -to sev_seg_2_a
set_location_assignment PIN_42 -to sev_seg_2_b
set_location_assignment PIN_54 -to sev_seg_2_c
set_location_assignment PIN_44 -to sev_seg_2_d
set_location_assignment PIN_56 -to sev_seg_2_dp
set_location_assignment PIN_58 -to sev_seg_2_e
set_location_assignment PIN_60 -to sev_seg_2_f
set_location_assignment PIN_46 -to sev_seg_2_g
set_location_assignment PIN_20 -to uart_cts
set_location_assignment PIN_124 -to uart_rts
set_location_assignment PIN_21 -to uart_rx
set_location_assignment PIN_139 -to uart_tx
set_location_assignment PIN_182 -to user_dip\[0\]
set_location_assignment PIN_184 -to user_dip\[1\]
set_location_assignment PIN_196 -to user_dip\[2\]
set_location_assignment PIN_198 -to user_dip\[3\]
set_location_assignment PIN_16 -to user_led\[0\]
set_location_assignment PIN_17 -to user_led\[1\]
set_location_assignment PIN_18 -to user_led\[2\]
set_location_assignment PIN_41 -to user_led\[3\]
set_location_assignment PIN_61 -to user_pb\[0\]
set_location_assignment PIN_62 -to user_pb\[1\]
set_location_assignment PIN_63 -to user_pb\[2\]
set_location_assignment PIN_64 -to user_pb\[3\]

set_instance_assignment -name IO_STANDARD "2.5 V" -to header\[0\]
set_instance_assignment -name IO_STANDARD "2.5 V" -to header\[10\]
set_instance_assignment -name IO_STANDARD "2.5 V" -to header\[11\]
set_instance_assignment -name IO_STANDARD "2.5 V" -to header\[12\]
set_instance_assignment -name IO_STANDARD "2.5 V" -to header\[13\]
set_instance_assignment -name IO_STANDARD "2.5 V" -to header\[14\]
set_instance_assignment -name IO_STANDARD "2.5 V" -to header\[15\]
set_instance_assignment -name IO_STANDARD "2.5 V" -to header\[1\]
set_instance_assignment -name IO_STANDARD "2.5 V" -to header\[2\]
set_instance_assignment -name IO_STANDARD "2.5 V" -to header\[3\]
set_instance_assignment -name IO_STANDARD "2.5 V" -to header\[4\]
set_instance_assignment -name IO_STANDARD "2.5 V" -to header\[5\]
set_instance_assignment -name IO_STANDARD "2.5 V" -to header\[6\]
set_instance_assignment -name IO_STANDARD "2.5 V" -to header\[7\]
set_instance_assignment -name IO_STANDARD "2.5 V" -to header\[8\]
set_instance_assignment -name IO_STANDARD "2.5 V" -to header\[9\]
set_instance_assignment -name IO_STANDARD "2.5 V" -to sev_seg_1_a
set_instance_assignment -name IO_STANDARD "2.5 V" -to sev_seg_1_b
set_instance_assignment -name IO_STANDARD "2.5 V" -to sev_seg_1_c
set_instance_assignment -name IO_STANDARD "2.5 V" -to sev_seg_1_d
set_instance_assignment -name IO_STANDARD "2.5 V" -to sev_seg_1_dp
set_instance_assignment -name IO_STANDARD "2.5 V" -to sev_seg_1_e
set_instance_assignment -name IO_STANDARD "2.5 V" -to sev_seg_1_f
set_instance_assignment -name IO_STANDARD "2.5 V" -to sev_seg_1_g
set_instance_assignment -name IO_STANDARD "2.5 V" -to sev_seg_2_a
set_instance_assignment -name IO_STANDARD "2.5 V" -to sev_seg_2_b
set_instance_assignment -name IO_STANDARD "2.5 V" -to sev_seg_2_c
set_instance_assignment -name IO_STANDARD "2.5 V" -to sev_seg_2_d
set_instance_assignment -name IO_STANDARD "2.5 V" -to sev_seg_2_dp
set_instance_assignment -name IO_STANDARD "2.5 V" -to sev_seg_2_e
set_instance_assignment -name IO_STANDARD "2.5 V" -to sev_seg_2_f
set_instance_assignment -name IO_STANDARD "2.5 V" -to sev_seg_2_g
set_instance_assignment -name IO_STANDARD "2.5 V" -to reset_n
set_instance_assignment -name IO_STANDARD "2.5 V" -to uart_cts
set_instance_assignment -name IO_STANDARD "2.5 V" -to uart_rts
set_instance_assignment -name IO_STANDARD "2.5 V" -to uart_rx
set_instance_assignment -name IO_STANDARD "2.5 V" -to uart_tx
set_instance_assignment -name IO_STANDARD "2.5 V" -to user_dip\[0\]
set_instance_assignment -name IO_STANDARD "2.5 V" -to user_dip\[1\]
set_instance_assignment -name IO_STANDARD "2.5 V" -to user_dip\[2\]
set_instance_assignment -name IO_STANDARD "2.5 V" -to user_dip\[3\]
set_instance_assignment -name IO_STANDARD "2.5 V" -to user_led\[0\]
set_instance_assignment -name IO_STANDARD "2.5 V" -to user_led\[1\]
set_instance_assignment -name IO_STANDARD "2.5 V" -to user_led\[2\]
set_instance_assignment -name IO_STANDARD "2.5 V" -to user_led\[3\]
set_instance_assignment -name IO_STANDARD "2.5 V" -to user_pb\[0\]
set_instance_assignment -name IO_STANDARD "2.5 V" -to user_pb\[1\]
set_instance_assignment -name IO_STANDARD "2.5 V" -to user_pb\[2\]
set_instance_assignment -name IO_STANDARD "2.5 V" -to user_pb\[3\]




