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


###############################################################################
## Filename: audio_extract.sdc
##
## Description: Timing Constraint file for audio_extract Megacore
##
###############################################################################

# This path is available only when clocks are generated.
set aud_clock_collection [get_keepers -nowarn {*audio_extract_core*|*:g_clock.u_audio_extract_clock|aud_counter[15]}]
foreach_in_collection keeper $aud_clock_collection {
  set aud_clock_keeper_name [get_object_info -name $keeper]
  create_clock -name {aud_clk} -period 200.000 -waveform { 0.000 100.000 } [get_keepers $aud_clock_keeper_name]
}

set_false_path -to [get_keepers {*audio_extract_core:*|aud_radd_msb_meta[*]}]
set_false_path -to [get_keepers {*audio_extract_core:*|aud_wadd_msb_meta[*]}]
