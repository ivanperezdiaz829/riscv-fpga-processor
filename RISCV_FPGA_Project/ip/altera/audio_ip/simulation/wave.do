# (C) 2001-2013 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License Subscription 
# Agreement, Altera MegaCore Function License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Audio Test Source}
add wave -noupdate -format Logic /testbench/u_audio_test_source/aud_clk
add wave -noupdate -format Logic /testbench/u_audio_test_source/aud_clk48
add wave -noupdate -format Logic /testbench/u_audio_test_source/aud_reset
add wave -noupdate -format Logic /testbench/u_audio_test_source/aud_de
add wave -noupdate -format Logic /testbench/u_audio_test_source/aud_ws
add wave -noupdate -format Logic /testbench/u_audio_test_source/aud_data
add wave -noupdate -divider {Video Test Source}
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_frb_timing_top/vid_clk
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_frb_timing_top/vid_reset
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_frb_timing_top/timing_std
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_frb_timing_top/timing_data
add wave -noupdate -divider {Insert SMPTE352}
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_insert_smpte352/vid_clk
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_insert_smpte352/vid_reset
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_insert_smpte352/vid_std
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_insert_smpte352/vid_en
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_insert_smpte352/vid_data
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_insert_smpte352/vid_out_en
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_insert_smpte352/vid_out_data
add wave -noupdate -divider {Audio Embed 0 - Video Input}
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_embed_0/reset
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_embed_0/vid_clk
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_audio_embed_0/vid_std
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_audio_embed_0/vid_data
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_embed_0/vid_datavalid
add wave -noupdate -divider {Audio Embed 0 - AES Audio Input}
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_audio_embed_0/aud_clk
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_audio_embed_0/aud_data
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_audio_embed_0/aud_de
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_audio_embed_0/aud_ws
add wave -noupdate -divider {Audio Embed 0 - Register Interface}
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_audio_embed_0/reg_base_addr
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_audio_embed_0/reg_burstcount
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_embed_0/reg_clk
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_embed_0/reg_read
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_audio_embed_0/reg_readdata
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_embed_0/reg_readdatavalid
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_embed_0/reg_reset
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_embed_0/reg_waitrequest
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_embed_0/reg_write
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_audio_embed_0/reg_writedata
add wave -noupdate -divider {Audio Embed 0 - Video Output}
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_audio_embed_0/vid_out_data
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_embed_0/vid_out_datavalid
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_audio_embed_0/vid_out_ln
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_embed_0/vid_out_trs
add wave -noupdate -divider {Audio Extract 0 - Video Input}
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_extract_0/reset
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_extract_0/vid_clk
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_audio_extract_0/vid_data
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_extract_0/vid_datavalid
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_extract_0/vid_locked
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_extract_0/vid_clk
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_audio_extract_0/vid_std
add wave -noupdate -divider {Audio Extract 0 - Register Interface}
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_audio_extract_0/reg_base_addr
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_audio_extract_0/reg_burstcount
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_extract_0/reg_clk
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_extract_0/reg_read
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_audio_extract_0/reg_readdata
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_extract_0/reg_readdatavalid
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_extract_0/reg_reset
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_extract_0/reg_waitrequest
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_extract_0/reg_write
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_audio_extract_0/reg_writedata
add wave -noupdate -divider {Audio Extract 0 - AES Audio Output}
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_extract_0/fix_clk
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_extract_0/aud_clk_out
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_extract_0/aud_clk48_out
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_extract_0/aud_clk
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_extract_0/aud_ws_in
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_extract_0/aud_de
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_extract_0/aud_ws
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_audio_extract_0/aud_data
add wave -noupdate -divider {CAI - AES Input}
add wave -noupdate -format Logic -radix hexadecimal /testbench/g_cai/u_clocked_audio_input_0/aes_clk
add wave -noupdate -format Logic -radix hexadecimal /testbench/g_cai/u_clocked_audio_input_0/aes_data
add wave -noupdate -format Logic -radix hexadecimal /testbench/g_cai/u_clocked_audio_input_0/aes_de
add wave -noupdate -format Logic -radix hexadecimal /testbench/g_cai/u_clocked_audio_input_0/aes_ws
add wave -noupdate -divider {CAI - Avalon ST Audio Output}
add wave -noupdate -format Logic -radix hexadecimal /testbench/g_cai/u_clocked_audio_input_0/aud_clk
add wave -noupdate -format Literal -radix hexadecimal /testbench/g_cai/u_clocked_audio_input_0/aud_channel
add wave -noupdate -format Literal -radix hexadecimal /testbench/g_cai/u_clocked_audio_input_0/aud_data
add wave -noupdate -format Logic -radix hexadecimal /testbench/g_cai/u_clocked_audio_input_0/aud_eop
add wave -noupdate -format Logic -radix hexadecimal /testbench/g_cai/u_clocked_audio_input_0/aud_ready
add wave -noupdate -format Logic -radix hexadecimal /testbench/g_cai/u_clocked_audio_input_0/aud_sop
add wave -noupdate -format Logic -radix hexadecimal /testbench/g_cai/u_clocked_audio_input_0/aud_valid
add wave -noupdate -divider {CAO - Avalon ST Audio Input}
add wave -noupdate -format Logic -radix hexadecimal /testbench/g_cao/u_clocked_audio_output_0/aud_clk
add wave -noupdate -format Literal -radix hexadecimal /testbench/g_cao/u_clocked_audio_output_0/aud_channel
add wave -noupdate -format Literal -radix hexadecimal /testbench/g_cao/u_clocked_audio_output_0/aud_data
add wave -noupdate -format Logic -radix hexadecimal /testbench/g_cao/u_clocked_audio_output_0/aud_eop
add wave -noupdate -format Logic -radix hexadecimal /testbench/g_cao/u_clocked_audio_output_0/aud_ready
add wave -noupdate -format Logic -radix hexadecimal /testbench/g_cao/u_clocked_audio_output_0/aud_sop
add wave -noupdate -format Logic -radix hexadecimal /testbench/g_cao/u_clocked_audio_output_0/aud_valid
add wave -noupdate -divider {CAO - AES Audio Output}
add wave -noupdate -format Logic -radix hexadecimal /testbench/g_cao/u_clocked_audio_output_0/aes_clk
add wave -noupdate -format Logic -radix hexadecimal /testbench/g_cao/u_clocked_audio_output_0/aes_de
add wave -noupdate -format Logic -radix hexadecimal /testbench/g_cao/u_clocked_audio_output_0/aes_ws
add wave -noupdate -format Logic -radix hexadecimal /testbench/g_cao/u_clocked_audio_output_0/aes_data
add wave -noupdate -divider {Testbench Self Check}
add wave -noupdate -format Literal -radix hexadecimal /testbench/aud_extract_sample
add wave -noupdate -format Literal -radix hexadecimal /testbench/aes_avalon_sample
add wave -noupdate -format Logic -radix hexadecimal /testbench/sim_checker_enable
add wave -noupdate -format Logic -radix hexadecimal /testbench/aes_avalon_sim_checker_enable
add wave -noupdate -format Literal -radix hexadecimal /testbench/sim_errors
add wave -noupdate -format Literal -radix hexadecimal /testbench/aes_avalon_sim_errors
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {348 ps} 0}
configure wave -namecolwidth 239
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1675 ps}
