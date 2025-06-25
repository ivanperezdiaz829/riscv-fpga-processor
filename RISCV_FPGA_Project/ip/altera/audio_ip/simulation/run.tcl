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


transcript on
write transcript aud_transcript

if {[file exist [project env]] > 0} {
    project close
}

set env_quartus $env(QUARTUS_ROOTDIR)

set quartusdir $env_quartus/eda/sim_lib/

if {[file exist work] == 0} {
    vlib work
}

vlib atom_lib
vlog -work atom_lib "$quartusdir/220model.v"
vlog -work atom_lib "$quartusdir/sgate.v"
vlog -work atom_lib "$quartusdir/altera_primitives.v"
vlog -work atom_lib "$quartusdir/altera_mf.v"

vlib common_lib
vmap work common_lib

vlib audio_embed_avalon_top_lib
vmap work audio_embed_avalon_top_lib
vlib audio_embed_top_lib
vmap work audio_embed_top_lib
vlib audio_extract_avalon_top_lib
vmap work audio_extract_avalon_top_lib
vlib audio_extract_top_lib
vmap work audio_extract_top_lib
vlib clocked_audio_input_top_lib
vmap work clocked_audio_input_top_lib
vlib clocked_audio_output_top_lib
vmap work clocked_audio_output_top_lib

vlog -work work src_common/*.v

# Please refer to the SDI user guide on how to generate 
# the following .vo files before you run this script
vlog megacore_build/audio_embed_avalon_top_sim/submodules/mentor/*.v   -work audio_embed_avalon_top_lib
#vlog megacore_build/audio_embed_avalon_top_sim/submodules/mentor/*.sv   -work audio_embed_avalon_top_lib
vlog megacore_build/audio_embed_avalon_top_sim/audio_embed_avalon_top.v  -work audio_embed_avalon_top_lib
vlog megacore_build/audio_embed_top_sim/submodules/mentor/*.v   -work audio_embed_top_lib
vlog megacore_build/audio_embed_top_sim/audio_embed_top.v  -work audio_embed_top_lib
vlog megacore_build/audio_extract_avalon_top_sim/submodules/mentor/*.v   -work audio_extract_avalon_top_lib
vlog megacore_build/audio_extract_avalon_top_sim/audio_extract_avalon_top.v  -work audio_extract_avalon_top_lib
vlog megacore_build/audio_extract_top_sim/submodules/mentor/*.v   -work audio_extract_top_lib
vlog megacore_build/audio_extract_top_sim/audio_extract_top.v  -work audio_extract_top_lib
vlog megacore_build/clocked_audio_input_top_sim/submodules/mentor/*.v   -work clocked_audio_input_top_lib
vlog megacore_build/clocked_audio_input_top_sim/clocked_audio_input_top.v  -work clocked_audio_input_top_lib
vlog megacore_build/clocked_audio_output_top_sim/submodules/mentor/*.v   -work clocked_audio_output_top_lib
vlog megacore_build/clocked_audio_output_top_sim/clocked_audio_output_top.v  -work clocked_audio_output_top_lib


vlog -work work testbench.v

vsim -t 1ps -voptargs="+acc" work.testbench -L work -L atom_lib -L common_lib \
-L audio_embed_avalon_top_lib \
-L audio_embed_top_lib \
-L audio_extract_avalon_top_lib \
-L audio_extract_top_lib \
-L clocked_audio_input_top_lib \
-L clocked_audio_output_top_lib 
do wave.do
run -all
