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




#**************************************************************
# Create Clock
#**************************************************************
create_clock -name {alt_ntrlkn_sample_channel_client_1_tx_clk_clk} -period 10.24 -waveform { 0.000 5.12 } [get_ports {alt_ntrlkn_sample_channel_client_1_tx_clk_clk}]
create_clock -name {alt_ntrlkn_sample_channel_client_0_tx_clk_clk} -period 10.24 -waveform { 0.000 5.12 } [get_ports {alt_ntrlkn_sample_channel_client_0_tx_clk_clk}]
create_clock -name {alt_ntrlkn_sample_channel_client_1_rx_clk_clk} -period 10.24 -waveform { 0.000 5.12 } [get_ports {alt_ntrlkn_sample_channel_client_1_rx_clk_clk}]
create_clock -name {alt_ntrlkn_sample_channel_client_0_rx_clk_clk} -period 10.24 -waveform { 0.000 5.12 } [get_ports {alt_ntrlkn_sample_channel_client_0_rx_clk_clk}]

create_clock -name {interlaken_0_tx_mac_clk_clk} -period 10.24 -waveform { 0.000 5.12 } [get_ports {interlaken_0_tx_mac_clk_clk}]
create_clock -name {interalken_0_rx_mac_clk_clk} -period 10.24 -waveform { 0.000 5.12 } [get_ports { interlaken_0_rx_mac_clk_clk }]

#50 MHz
create_clock -name {interlaken_0_cal_blk_clk} -period 20.000 -waveform { 0.000 10.000 } [get_ports {interlaken_0_cal_blk_clk}]
#**************************************************************
# Create Generated Clock
#**************************************************************

derive_pll_clocks -create_base_clocks
#GXB inclk frequency
create_clock -name {interlaken_0_ref_clk} -period 156.25MHz [get_ports {interlaken_0_ref_clk_clk}] 

derive_clock_uncertainty


#**************************************************************
# Set False Paths
#**************************************************************
set_false_path -from [get_keepers *lane_status_monitor:lsm|*error*d*]
set_false_path -from [get_keepers *lane_status_monitor:lsm|*word*locked*d*]
set_false_path -from [get_keepers *lane_status_monitor:lsm|*sync*locked*d*]

#**************************************************************
# Adjust clock to clock default transfer rules
# NOTE: You should analyze your design and adjust the clock-to-clock
#       relationships as needed.
#**************************************************************

if {$::TimeQuestInfo(nameofexecutable) eq "quartus_fit"} {
    foreach_in_collection src_clk [all_clocks] {
        foreach_in_collection dst_clk [all_clocks] {
            if {$src_clk != $dst_clk} {
               # Fitter - transfers are critical (1ns)
               set_max_delay -from [get_clock_info -name $src_clk] -to [get_clock_info -name $dst_clk] 1.000
            }
        }
    }
}

