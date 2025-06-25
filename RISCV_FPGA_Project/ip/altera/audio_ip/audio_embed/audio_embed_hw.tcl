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


# +----------------------------------
# | 
# | Audio Embed v10.1
# | Altera Corporation 2009.08.19.17:10:07
# | 
# +-----------------------------------

#package require -exact sopc 12.0
package require -exact qsys 12.0

# +-----------------------------------
# | module audio_embed
# | 
set_module_property DESCRIPTION "Audio Embed"
set_module_property NAME audio_embed
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property GROUP "Interface Protocols/SDI"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Audio Embed"
set_module_property DATASHEET_URL http://www.altera.com/literature/ug/ug_sdi.pdf
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false

# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
#set module_dir [get_module_property MODULE_DIRECTORY]
#add_file ${module_dir}/../verilog/audio_embed_cs_insert.v {SYNTHESIS}
#add_file ${module_dir}/../verilog/audio_embed_frame_seq.v {SYNTHESIS}
#add_file ${module_dir}/../verilog/audio_embed_sine_clock.v {SYNTHESIS}
#add_file ${module_dir}/../verilog/audio_embed_sine_gen.v {SYNTHESIS}
#add_file ${module_dir}/../verilog/audio_embed_sine_lut.v {SYNTHESIS}
#add_file ${module_dir}/../verilog/audio_embed_sine_ram.v {SYNTHESIS}
#add_file ${module_dir}/../verilog/audio_embed_input_fifo.v {SYNTHESIS}
#add_file ${module_dir}/../verilog/audio_embed_hd_packet.v {SYNTHESIS}
#add_file ${module_dir}/../verilog/audio_embed_sd_packet.v {SYNTHESIS}
#add_file ${module_dir}/../verilog/audio_embed_hd_control_packet.v {SYNTHESIS}
#add_file ${module_dir}/../verilog/audio_embed_video_input.v {SYNTHESIS}
#add_file ${module_dir}/../verilog/audio_embed_core.sv {SYNTHESIS}
#add_file ${module_dir}/../verilog/audio_embed_registers.v {SYNTHESIS}
#add_file ${module_dir}/../verilog/altera_audemb_reset_synchronizer.v {SYNTHESIS}
#add_file ${module_dir}/../verilog/audio_embed.v {SYNTHESIS}
#add_file ${module_dir}/../../clocked_audio_output/verilog/cao_fifo.v {SYNTHESIS}
#add_file ${module_dir}/../../clocked_audio_output/verilog/cao_merge.v {SYNTHESIS}
#add_file ${module_dir}/../../clocked_audio_output/verilog/cao_avalon.v {SYNTHESIS}
#add_file ${module_dir}/../../clocked_audio_output/verilog/altera_cao_reset_synchronizer.v {SYNTHESIS}

# | 
# +-----------------------------------

# +-----------------------------------
# | IEEE Encryption
# |

add_fileset          simulation_verilog SIM_VERILOG   generate_files
add_fileset          simulation_vhdl    SIM_VHDL      generate_files
add_fileset          synthesis_fileset  QUARTUS_SYNTH generate_ed_files

set_fileset_property simulation_verilog TOP_LEVEL   audio_embed
set_fileset_property simulation_vhdl    TOP_LEVEL   audio_embed
set_fileset_property synthesis_fileset  TOP_LEVEL   audio_embed

proc generate_files {name} {
  if {1} {
    add_fileset_file mentor/audio_embed_cs_insert.v               VERILOG_ENCRYPT PATH mentor/src_hdl/audio_embed_cs_insert.v                                  {MENTOR_SPECIFIC}
    add_fileset_file mentor/audio_embed_frame_seq.v               VERILOG_ENCRYPT PATH mentor/src_hdl/audio_embed_frame_seq.v                                  {MENTOR_SPECIFIC}
    add_fileset_file mentor/audio_embed_sine_clock.v              VERILOG_ENCRYPT PATH mentor/src_hdl/audio_embed_sine_clock.v                                 {MENTOR_SPECIFIC}
    add_fileset_file mentor/audio_embed_sine_gen.v                VERILOG_ENCRYPT PATH mentor/src_hdl/audio_embed_sine_gen.v                                   {MENTOR_SPECIFIC}
    add_fileset_file mentor/audio_embed_input_fifo.v              VERILOG_ENCRYPT PATH mentor/src_hdl/audio_embed_input_fifo.v                                 {MENTOR_SPECIFIC}
    add_fileset_file mentor/audio_embed_sine_lut.v                VERILOG_ENCRYPT PATH mentor/src_hdl/audio_embed_sine_lut.v                                   {MENTOR_SPECIFIC}
    add_fileset_file mentor/audio_embed_sine_ram.v                VERILOG_ENCRYPT PATH mentor/src_hdl/audio_embed_sine_ram.v                                   {MENTOR_SPECIFIC}
    add_fileset_file mentor/audio_embed_hd_packet.v               VERILOG_ENCRYPT PATH mentor/src_hdl/audio_embed_hd_packet.v                                  {MENTOR_SPECIFIC}
    add_fileset_file mentor/audio_embed_sd_packet.v               VERILOG_ENCRYPT PATH mentor/src_hdl/audio_embed_sd_packet.v                                  {MENTOR_SPECIFIC}
    add_fileset_file mentor/audio_embed_video_input.v             VERILOG_ENCRYPT PATH mentor/src_hdl/audio_embed_video_input.v                                {MENTOR_SPECIFIC}
    add_fileset_file mentor/audio_embed_registers.v               VERILOG_ENCRYPT PATH mentor/src_hdl/audio_embed_registers.v                                  {MENTOR_SPECIFIC}
    add_fileset_file mentor/audio_embed.v                         VERILOG_ENCRYPT PATH mentor/src_hdl/audio_embed.v                                            {MENTOR_SPECIFIC}
    add_fileset_file mentor/audio_embed_strip.v                   VERILOG_ENCRYPT PATH mentor/src_hdl/audio_embed_strip.v                                      {MENTOR_SPECIFIC}
    add_fileset_file mentor/audio_embed_core.v                    VERILOG_ENCRYPT PATH mentor/src_hdl/audio_embed_core.v                                       {MENTOR_SPECIFIC}
    add_fileset_file mentor/audio_embed_control_packet.v          VERILOG_ENCRYPT PATH mentor/src_hdl/audio_embed_control_packet.v                             {MENTOR_SPECIFIC}
    add_fileset_file mentor/altera_audemb_reset_synchronizer.v    VERILOG_ENCRYPT PATH mentor/src_hdl/altera_audemb_reset_synchronizer.v                             {MENTOR_SPECIFIC}
    add_fileset_file mentor/cao_fifo.v                            VERILOG_ENCRYPT PATH ../clocked_audio_output/mentor/src_hdl/cao_fifo.v                       {MENTOR_SPECIFIC}
    add_fileset_file mentor/cao_merge.v                           VERILOG_ENCRYPT PATH ../clocked_audio_output/mentor/src_hdl/cao_merge.v                      {MENTOR_SPECIFIC}
    add_fileset_file mentor/cao_avalon.v                          VERILOG_ENCRYPT PATH ../clocked_audio_output/mentor/src_hdl/cao_avalon.v                     {MENTOR_SPECIFIC}
  }
  
  if {1} {
    add_fileset_file aldec/audio_embed_cs_insert.v               VERILOG_ENCRYPT PATH aldec/src_hdl/audio_embed_cs_insert.v                                  {ALDEC_SPECIFIC}
    add_fileset_file aldec/audio_embed_frame_seq.v               VERILOG_ENCRYPT PATH aldec/src_hdl/audio_embed_frame_seq.v                                  {ALDEC_SPECIFIC}
    add_fileset_file aldec/audio_embed_sine_clock.v              VERILOG_ENCRYPT PATH aldec/src_hdl/audio_embed_sine_clock.v                                 {ALDEC_SPECIFIC}
    add_fileset_file aldec/audio_embed_sine_gen.v                VERILOG_ENCRYPT PATH aldec/src_hdl/audio_embed_sine_gen.v                                   {ALDEC_SPECIFIC}
    add_fileset_file aldec/audio_embed_input_fifo.v              VERILOG_ENCRYPT PATH aldec/src_hdl/audio_embed_input_fifo.v                                 {ALDEC_SPECIFIC}
    add_fileset_file aldec/audio_embed_sine_lut.v                VERILOG_ENCRYPT PATH aldec/src_hdl/audio_embed_sine_lut.v                                   {ALDEC_SPECIFIC}
    add_fileset_file aldec/audio_embed_sine_ram.v                VERILOG_ENCRYPT PATH aldec/src_hdl/audio_embed_sine_ram.v                                   {ALDEC_SPECIFIC}
    add_fileset_file aldec/audio_embed_hd_packet.v               VERILOG_ENCRYPT PATH aldec/src_hdl/audio_embed_hd_packet.v                                  {ALDEC_SPECIFIC}
    add_fileset_file aldec/audio_embed_sd_packet.v               VERILOG_ENCRYPT PATH aldec/src_hdl/audio_embed_sd_packet.v                                  {ALDEC_SPECIFIC}
    add_fileset_file aldec/audio_embed_video_input.v             VERILOG_ENCRYPT PATH aldec/src_hdl/audio_embed_video_input.v                                {ALDEC_SPECIFIC}
    add_fileset_file aldec/audio_embed_registers.v               VERILOG_ENCRYPT PATH aldec/src_hdl/audio_embed_registers.v                                  {ALDEC_SPECIFIC}
    add_fileset_file aldec/audio_embed.v                         VERILOG_ENCRYPT PATH aldec/src_hdl/audio_embed.v                                            {ALDEC_SPECIFIC}
    add_fileset_file aldec/audio_embed_strip.v                   VERILOG_ENCRYPT PATH aldec/src_hdl/audio_embed_strip.v                                      {ALDEC_SPECIFIC}
    add_fileset_file aldec/audio_embed_core.v                    VERILOG_ENCRYPT PATH aldec/src_hdl/audio_embed_core.v                                       {ALDEC_SPECIFIC}
    add_fileset_file aldec/audio_embed_control_packet.v          VERILOG_ENCRYPT PATH aldec/src_hdl/audio_embed_control_packet.v                             {ALDEC_SPECIFIC}
    add_fileset_file aldec/altera_audemb_reset_synchronizer.v    VERILOG_ENCRYPT PATH aldec/src_hdl/altera_audemb_reset_synchronizer.v                       {ALDEC_SPECIFIC}
    add_fileset_file aldec/cao_fifo.v                            VERILOG_ENCRYPT PATH ../clocked_audio_output/aldec/src_hdl/cao_fifo.v                       {ALDEC_SPECIFIC}
    add_fileset_file aldec/cao_merge.v                           VERILOG_ENCRYPT PATH ../clocked_audio_output/aldec/src_hdl/cao_merge.v                      {ALDEC_SPECIFIC}
    add_fileset_file aldec/cao_avalon.v                          VERILOG_ENCRYPT PATH ../clocked_audio_output/aldec/src_hdl/cao_avalon.v                     {ALDEC_SPECIFIC}
  }
  
  if {0} {
    add_fileset_file cadence/audio_embed_cs_insert.v               VERILOG_ENCRYPT PATH cadence/src_hdl/audio_embed_cs_insert.v                                  {CADENCE_SPECIFIC}
    add_fileset_file cadence/audio_embed_frame_seq.v               VERILOG_ENCRYPT PATH cadence/src_hdl/audio_embed_frame_seq.v                                  {CADENCE_SPECIFIC}
    add_fileset_file cadence/audio_embed_sine_clock.v              VERILOG_ENCRYPT PATH cadence/src_hdl/audio_embed_sine_clock.v                                 {CADENCE_SPECIFIC}
    add_fileset_file cadence/audio_embed_sine_gen.v                VERILOG_ENCRYPT PATH cadence/src_hdl/audio_embed_sine_gen.v                                   {CADENCE_SPECIFIC}
    add_fileset_file cadence/audio_embed_input_fifo.v              VERILOG_ENCRYPT PATH cadence/src_hdl/audio_embed_input_fifo.v                                 {CADENCE_SPECIFIC}
    add_fileset_file cadence/audio_embed_sine_lut.v                VERILOG_ENCRYPT PATH cadence/src_hdl/audio_embed_sine_lut.v                                   {CADENCE_SPECIFIC}
    add_fileset_file cadence/audio_embed_sine_ram.v                VERILOG_ENCRYPT PATH cadence/src_hdl/audio_embed_sine_ram.v                                   {CADENCE_SPECIFIC}
    add_fileset_file cadence/audio_embed_hd_packet.v               VERILOG_ENCRYPT PATH cadence/src_hdl/audio_embed_hd_packet.v                                  {CADENCE_SPECIFIC}
    add_fileset_file cadence/audio_embed_sd_packet.v               VERILOG_ENCRYPT PATH cadence/src_hdl/audio_embed_sd_packet.v                                  {CADENCE_SPECIFIC}
    add_fileset_file cadence/audio_embed_video_input.v             VERILOG_ENCRYPT PATH cadence/src_hdl/audio_embed_video_input.v                                {CADENCE_SPECIFIC}
    add_fileset_file cadence/audio_embed_registers.v               VERILOG_ENCRYPT PATH cadence/src_hdl/audio_embed_registers.v                                  {CADENCE_SPECIFIC}
    add_fileset_file cadence/audio_embed.v                         VERILOG_ENCRYPT PATH cadence/src_hdl/audio_embed.v                                            {CADENCE_SPECIFIC}
    add_fileset_file cadence/audio_embed_strip.v                   VERILOG_ENCRYPT PATH cadence/src_hdl/audio_embed_strip.v                                      {CADENCE_SPECIFIC}
    add_fileset_file cadence/audio_embed_core.v                    VERILOG_ENCRYPT PATH cadence/src_hdl/audio_embed_core.v                                       {CADENCE_SPECIFIC}
    add_fileset_file cadence/audio_embed_control_packet.v          VERILOG_ENCRYPT PATH cadence/src_hdl/audio_embed_control_packet.v                             {CADENCE_SPECIFIC}
    add_fileset_file cadence/altera_audemb_reset_synchronizer.v    VERILOG_ENCRYPT PATH cadence/src_hdl/altera_audemb_reset_synchronizer.v                       {CADENCE_SPECIFIC}
    add_fileset_file cadence/cao_fifo.v                            VERILOG_ENCRYPT PATH ../clocked_audio_output/cadence/src_hdl/cao_fifo.v                       {CADENCE_SPECIFIC}
    add_fileset_file cadence/cao_merge.v                           VERILOG_ENCRYPT PATH ../clocked_audio_output/cadence/src_hdl/cao_merge.v                      {CADENCE_SPECIFIC}
    add_fileset_file cadence/cao_avalon.v                          VERILOG_ENCRYPT PATH ../clocked_audio_output/cadence/src_hdl/cao_avalon.v                     {CADENCE_SPECIFIC}
    
  }
  
  if {0} {
    add_fileset_file synopsys/audio_embed_cs_insert.v               VERILOG_ENCRYPT PATH synopsys/src_hdl/audio_embed_cs_insert.v                                  {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/audio_embed_frame_seq.v               VERILOG_ENCRYPT PATH synopsys/src_hdl/audio_embed_frame_seq.v                                  {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/audio_embed_sine_clock.v              VERILOG_ENCRYPT PATH synopsys/src_hdl/audio_embed_sine_clock.v                                 {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/audio_embed_sine_gen.v                VERILOG_ENCRYPT PATH synopsys/src_hdl/audio_embed_sine_gen.v                                   {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/audio_embed_input_fifo.v              VERILOG_ENCRYPT PATH synopsys/src_hdl/audio_embed_input_fifo.v                                 {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/audio_embed_sine_lut.v                VERILOG_ENCRYPT PATH synopsys/src_hdl/audio_embed_sine_lut.v                                   {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/audio_embed_sine_ram.v                VERILOG_ENCRYPT PATH synopsys/src_hdl/audio_embed_sine_ram.v                                   {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/audio_embed_hd_packet.v               VERILOG_ENCRYPT PATH synopsys/src_hdl/audio_embed_hd_packet.v                                  {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/audio_embed_sd_packet.v               VERILOG_ENCRYPT PATH synopsys/src_hdl/audio_embed_sd_packet.v                                  {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/audio_embed_video_input.v             VERILOG_ENCRYPT PATH synopsys/src_hdl/audio_embed_video_input.v                                {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/audio_embed_registers.v               VERILOG_ENCRYPT PATH synopsys/src_hdl/audio_embed_registers.v                                  {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/audio_embed.v                         VERILOG_ENCRYPT PATH synopsys/src_hdl/audio_embed.v                                            {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/audio_embed_strip.v                   VERILOG_ENCRYPT PATH synopsys/src_hdl/audio_embed_strip.v                                      {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/audio_embed_core.v                    VERILOG_ENCRYPT PATH synopsys/src_hdl/audio_embed_core.v                                       {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/audio_embed_control_packet.v          VERILOG_ENCRYPT PATH synopsys/src_hdl/audio_embed_control_packet.v                             {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/altera_audemb_reset_synchronizer.v    VERILOG_ENCRYPT PATH synopsys/src_hdl/altera_audemb_reset_synchronizer.v                       {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/cao_fifo.v                            VERILOG_ENCRYPT PATH ../clocked_audio_output/synopsys/src_hdl/cao_fifo.v                       {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/cao_merge.v                           VERILOG_ENCRYPT PATH ../clocked_audio_output/synopsys/src_hdl/cao_merge.v                      {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/cao_avalon.v                          VERILOG_ENCRYPT PATH ../clocked_audio_output/synopsys/src_hdl/cao_avalon.v                     {SYNOPSYS_SPECIFIC}
    
  }
}

proc generate_ed_files {name} {
    add_fileset_file audio_embed_cs_insert.v               VERILOG PATH src_hdl/audio_embed_cs_insert.v                                  {SYNTHESIS}
    add_fileset_file audio_embed_frame_seq.v               VERILOG PATH src_hdl/audio_embed_frame_seq.v                                  {SYNTHESIS}
    add_fileset_file audio_embed_sine_clock.v              VERILOG PATH src_hdl/audio_embed_sine_clock.v                                 {SYNTHESIS}
    add_fileset_file audio_embed_sine_gen.v                VERILOG PATH src_hdl/audio_embed_sine_gen.v                                   {SYNTHESIS}
    add_fileset_file audio_embed_input_fifo.v              VERILOG PATH src_hdl/audio_embed_input_fifo.v                                 {SYNTHESIS}
    add_fileset_file audio_embed_sine_lut.v                VERILOG PATH src_hdl/audio_embed_sine_lut.v                                   {SYNTHESIS}
    add_fileset_file audio_embed_sine_ram.v                VERILOG PATH src_hdl/audio_embed_sine_ram.v                                   {SYNTHESIS}
    add_fileset_file audio_embed_hd_packet.v               VERILOG PATH src_hdl/audio_embed_hd_packet.v                                  {SYNTHESIS}
    add_fileset_file audio_embed_sd_packet.v               VERILOG PATH src_hdl/audio_embed_sd_packet.v                                  {SYNTHESIS}
    add_fileset_file audio_embed_video_input.v             VERILOG PATH src_hdl/audio_embed_video_input.v                                {SYNTHESIS}
    add_fileset_file audio_embed_registers.v               VERILOG PATH src_hdl/audio_embed_registers.v                                  {SYNTHESIS}
    add_fileset_file audio_embed.v                         VERILOG PATH src_hdl/audio_embed.v                                            {SYNTHESIS}
    add_fileset_file audio_embed_strip.v                   VERILOG PATH src_hdl/audio_embed_strip.v                                      {SYNTHESIS}
    add_fileset_file audio_embed_core.v                    VERILOG PATH src_hdl/audio_embed_core.v                                       {SYNTHESIS}
    add_fileset_file audio_embed_control_packet.v          VERILOG PATH src_hdl/audio_embed_control_packet.v                             {SYNTHESIS}
    add_fileset_file altera_audemb_reset_synchronizer.v    VERILOG PATH src_hdl/altera_audemb_reset_synchronizer.v                       {SYNTHESIS}
    add_fileset_file cao_fifo.v                            VERILOG PATH ../clocked_audio_output/src_hdl/cao_fifo.v                       {SYNTHESIS}
    add_fileset_file cao_merge.v                           VERILOG PATH ../clocked_audio_output/src_hdl/cao_merge.v                      {SYNTHESIS}
    add_fileset_file cao_avalon.v                          VERILOG PATH ../clocked_audio_output/src_hdl/cao_avalon.v                     {SYNTHESIS}
    add_fileset_file audio_embed.ocp                       OTHER   PATH audio_embed.ocp                                                  {SYNTHESIS}
    add_fileset_file audio_embed.sdc                       SDC     PATH audio_embed.sdc                                                  {SYNTHESIS}
}

# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# |
add_parameter FAMILY string "Cyclone IV"
set_parameter_property FAMILY DISPLAY_NAME "Device family selected"
set_parameter_property FAMILY DESCRIPTION "Current device family selected"
set_parameter_property FAMILY SYSTEM_INFO {DEVICE_FAMILY}
set_parameter_property FAMILY VISIBLE false

add_parameter G_AUDEMB_NUM_GROUPS INTEGER 1
set_parameter_property G_AUDEMB_NUM_GROUPS DISPLAY_NAME "Number of Supported Audio Groups" 
set_parameter_property G_AUDEMB_NUM_GROUPS UNITS None
set_parameter_property G_AUDEMB_NUM_GROUPS DESCRIPTION "Specified the maximum number of audio groups supported"
set_parameter_property G_AUDEMB_NUM_GROUPS AFFECTS_ELABORATION true
set_parameter_property G_AUDEMB_NUM_GROUPS ALLOWED_RANGES 1:4
set_parameter_property G_AUDEMB_NUM_GROUPS IS_HDL_PARAMETER true
# I2S, Asynchronous Input and Parallel Input will be supported in 11.0
#add_parameter G_AUDEMB_INPUT_I2S INTEGER 0
#set_parameter_property G_AUDEMB_INPUT_I2S DISPLAY_NAME "I2S Audio Interface"
#set_parameter_property G_AUDEMB_INPUT_I2S DESCRIPTION ""
#set_parameter_property G_AUDEMB_INPUT_I2S AFFECTS_ELABORATION false
#set_parameter_property G_AUDEMB_INPUT_I2S ALLOWED_RANGES 0:1
#set_parameter_property G_AUDEMB_INPUT_I2S DISPLAY_HINT boolean
#set_parameter_property G_AUDEMB_INPUT_I2S IS_HDL_PARAMETER true
add_parameter G_AUDEMB_INPUT_ASYNC INTEGER 1
set_parameter_property G_AUDEMB_INPUT_ASYNC DISPLAY_NAME "Async Audio Interface"
set_parameter_property G_AUDEMB_INPUT_ASYNC DESCRIPTION "Turn on to enable the Asynchronous input"
set_parameter_property G_AUDEMB_INPUT_ASYNC AFFECTS_ELABORATION false
set_parameter_property G_AUDEMB_INPUT_ASYNC ALLOWED_RANGES 0:1
set_parameter_property G_AUDEMB_INPUT_ASYNC DISPLAY_HINT boolean
set_parameter_property G_AUDEMB_INPUT_ASYNC IS_HDL_PARAMETER true
#add_parameter G_AUDEMB_INPUT_PARALLEL INTEGER 0
#set_parameter_property G_AUDEMB_INPUT_PARALLEL DISPLAY_NAME "Parallel Audio Interface"
#set_parameter_property G_AUDEMB_INPUT_PARALLEL DESCRIPTION ""
#set_parameter_property G_AUDEMB_INPUT_PARALLEL AFFECTS_ELABORATION true
#set_parameter_property G_AUDEMB_INPUT_PARALLEL ALLOWED_RANGES 0:1
#set_parameter_property G_AUDEMB_INPUT_PARALLEL DISPLAY_HINT boolean
#set_parameter_property G_AUDEMB_INPUT_PARALLEL IS_HDL_PARAMETER true
add_parameter G_AUDEMB_FREQ_FIXCLK INTEGER 24
set_parameter_property G_AUDEMB_FREQ_FIXCLK DISPLAY_NAME "Frequency of fix_clk"
set_parameter_property G_AUDEMB_FREQ_FIXCLK DESCRIPTION "Specifies the frequency of the fix_clk signal"
set_parameter_property G_AUDEMB_FREQ_FIXCLK AFFECTS_ELABORATION false
set_parameter_property G_AUDEMB_FREQ_FIXCLK ALLOWED_RANGES {0 "24:24.576" 25 50 100 200}
set_parameter_property G_AUDEMB_FREQ_FIXCLK IS_HDL_PARAMETER true
add_parameter G_AUDEMB_INCLUDE_SD_EDP INTEGER 1
set_parameter_property G_AUDEMB_INCLUDE_SD_EDP DISPLAY_NAME "Include SD-SDI 24bit Support"
set_parameter_property G_AUDEMB_INCLUDE_SD_EDP DESCRIPTION "Enables extra logic to recover EDP ancillary packets from SD-SDI inputs"
set_parameter_property G_AUDEMB_INCLUDE_SD_EDP AFFECTS_ELABORATION false
set_parameter_property G_AUDEMB_INCLUDE_SD_EDP ALLOWED_RANGES 0:1
set_parameter_property G_AUDEMB_INCLUDE_SD_EDP DISPLAY_HINT boolean
set_parameter_property G_AUDEMB_INCLUDE_SD_EDP IS_HDL_PARAMETER true
add_parameter G_AUDEMB_INCLUDE_STRIP INTEGER 1
set_parameter_property G_AUDEMB_INCLUDE_STRIP DISPLAY_NAME "Cleanly Remove Existing Audio"
set_parameter_property G_AUDEMB_INCLUDE_STRIP DESCRIPTION "Enables the removal of existing embedded audio data"
set_parameter_property G_AUDEMB_INCLUDE_STRIP AFFECTS_ELABORATION false
set_parameter_property G_AUDEMB_INCLUDE_STRIP ALLOWED_RANGES {0 1 2}
set_parameter_property G_AUDEMB_INCLUDE_STRIP IS_HDL_PARAMETER true
add_parameter G_AUDEMB_INCLUDE_CSRAM INTEGER 1
set_parameter_property G_AUDEMB_INCLUDE_CSRAM DISPLAY_NAME "Channel Status RAM"
set_parameter_property G_AUDEMB_INCLUDE_CSRAM DESCRIPTION "Enables the storage of the custom channel status data"
set_parameter_property G_AUDEMB_INCLUDE_CSRAM AFFECTS_ELABORATION false
set_parameter_property G_AUDEMB_INCLUDE_CSRAM ALLOWED_RANGES {0 1 2}
set_parameter_property G_AUDEMB_INCLUDE_CSRAM IS_HDL_PARAMETER true
add_parameter G_AUDEMB_INCLUDE_SINE INTEGER 1
set_parameter_property G_AUDEMB_INCLUDE_SINE DISPLAY_NAME "Frequency Sine Wave Generator"
set_parameter_property G_AUDEMB_INCLUDE_SINE DESCRIPTION "Enables a four-frequency sine wave generator"
set_parameter_property G_AUDEMB_INCLUDE_SINE AFFECTS_ELABORATION false
set_parameter_property G_AUDEMB_INCLUDE_SINE ALLOWED_RANGES 0:1
set_parameter_property G_AUDEMB_INCLUDE_SINE DISPLAY_HINT boolean
set_parameter_property G_AUDEMB_INCLUDE_SINE IS_HDL_PARAMETER true
add_parameter G_AUDEMB_INCLUDE_CLOCK INTEGER 1
set_parameter_property G_AUDEMB_INCLUDE_CLOCK DISPLAY_NAME "Include Clock"
set_parameter_property G_AUDEMB_INCLUDE_CLOCK DESCRIPTION "Enables a 48kHz pulse generator synchronous to the video clock"
set_parameter_property G_AUDEMB_INCLUDE_CLOCK AFFECTS_ELABORATION false
set_parameter_property G_AUDEMB_INCLUDE_CLOCK ALLOWED_RANGES 0:1
set_parameter_property G_AUDEMB_INCLUDE_CLOCK DISPLAY_HINT boolean
set_parameter_property G_AUDEMB_INCLUDE_CLOCK IS_HDL_PARAMETER true
add_parameter G_AUDEMB_INCLUDE_AVALON_ST INTEGER 0
set_parameter_property G_AUDEMB_INCLUDE_AVALON_ST DISPLAY_NAME "Include Avalon-ST Interface"
set_parameter_property G_AUDEMB_INCLUDE_AVALON_ST DESCRIPTION "Includes the SDI Clocked Audio Output MegaCore"
set_parameter_property G_AUDEMB_INCLUDE_AVALON_ST AFFECTS_ELABORATION true
set_parameter_property G_AUDEMB_INCLUDE_AVALON_ST ALLOWED_RANGES 0:1
set_parameter_property G_AUDEMB_INCLUDE_AVALON_ST DISPLAY_HINT boolean
set_parameter_property G_AUDEMB_INCLUDE_AVALON_ST IS_HDL_PARAMETER true
add_parameter G_AUDEMB_INCLUDE_CTRL_REG INTEGER 0
set_parameter_property G_AUDEMB_INCLUDE_CTRL_REG DISPLAY_NAME "Include Avalon-MM Control Interface"
set_parameter_property G_AUDEMB_INCLUDE_CTRL_REG DESCRIPTION "Includes the Avalon-MM control interface"
set_parameter_property G_AUDEMB_INCLUDE_CTRL_REG AFFECTS_ELABORATION true
set_parameter_property G_AUDEMB_INCLUDE_CTRL_REG ALLOWED_RANGES 0:1
set_parameter_property G_AUDEMB_INCLUDE_CTRL_REG DISPLAY_HINT boolean
set_parameter_property G_AUDEMB_INCLUDE_CTRL_REG IS_HDL_PARAMETER true


# | 
# +-----------------------------------

# +-----------------------------------
# | connection point register_clock
# | 
add_interface register_clock clock sink
set_interface_property register_clock ENABLED true
add_interface_port register_clock reg_clk clk Input 1
add_interface_port register_clock reg_reset reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point conduit_video
# | 
add_interface conduit_video conduit end
set_interface_property conduit_video ENABLED true
add_interface_port conduit_video fix_clk export Input 1
add_interface_port conduit_video vid_clk export Input 1
add_interface_port conduit_video reset export Input 1
add_interface_port conduit_video vid_std export Input 2
add_interface_port conduit_video vid_datavalid export Input 1
add_interface_port conduit_video vid_data export Input 20
add_interface_port conduit_video vid_std_rate export Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point conduit_output
# | 
add_interface conduit_output conduit end
set_interface_property conduit_output ENABLED true
add_interface_port conduit_output vid_clk48 export Output 1
add_interface_port conduit_output vid_out_datavalid export Output 1
add_interface_port conduit_output vid_out_data export Output 20
add_interface_port conduit_output vid_out_ln export Output 11
add_interface_port conduit_output vid_out_trs export Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point conduit_audio
# | 
#add_interface conduit_audio conduit end
#set_interface_property conduit_audio ENABLED true
# | 
# +-----------------------------------
#validation call back for disabling parameters
#set_module_property VALIDATION_CALLBACK my_validation_callback

#proc my_validation_callback {} {
#   set family [get_parameter_value FAMILY]

#if { $family == "Cyclone V"} {
#send_message error "Device family not supported: Cyclone V"
#   } 
#}
# +-----------------------------------
# Create the interfaces on elaboration
# |
set_module_property ELABORATION_CALLBACK my_elaboration_callback

proc my_elaboration_callback {} {
  set num_aud_pairs [expr [get_parameter_value G_AUDEMB_NUM_GROUPS] * 2]
  set num_aud_pairs_max 8
  #set aud_data_xwidth [expr [get_parameter_value G_AUDEMB_INPUT_PARALLEL] * 31]
  set aud_data_xwidth 0
  set aud_data_width [expr 1 + ${aud_data_xwidth}]
  set total_aud_data_width [expr ${aud_data_width} * ${num_aud_pairs}]

  set avalon_st 0
  if { [get_parameter_value G_AUDEMB_INCLUDE_AVALON_ST] > 0 } {
    set avalon_st 1
  }

  set avalon_mm 0
  if { [get_parameter_value G_AUDEMB_INCLUDE_CTRL_REG] > 0 } {
    set avalon_mm 1
  }   
  
  #if { $avalon_st > 0 }
  for {set pair 0} {$pair < $num_aud_pairs_max} {incr pair} {
    add_interface aud${pair}_din_clock clock sink  
    set_interface_property aud${pair}_din_clock ENABLED true
    add_interface_port aud${pair}_din_clock aud${pair}_clk clk Input 1
    add_interface aud${pair}_din avalon_streaming end
    set_interface_property aud${pair}_din dataBitsPerSymbol 24
    set_interface_property aud${pair}_din errorDescriptor ""
    set_interface_property aud${pair}_din maxChannel 255
    set_interface_property aud${pair}_din readyLatency 1
    set_interface_property aud${pair}_din symbolsPerBeat 1
    set_interface_property aud${pair}_din ASSOCIATED_CLOCK aud${pair}_din_clock
    add_interface_port aud${pair}_din aud${pair}_ready ready Output 1
    add_interface_port aud${pair}_din aud${pair}_valid valid Input 1
    add_interface_port aud${pair}_din aud${pair}_sop startofpacket Input 1
    add_interface_port aud${pair}_din aud${pair}_eop endofpacket Input 1
    add_interface_port aud${pair}_din aud${pair}_channel channel Input 8
    add_interface_port aud${pair}_din aud${pair}_data data Input 24
    
    add_interface conduit_audio conduit end
    set_interface_property conduit_audio ENABLED true
    add_interface_port conduit_audio aud_clk export Input ${num_aud_pairs}
    add_interface_port conduit_audio aud_de export Input ${num_aud_pairs}
    add_interface_port conduit_audio aud_ws export Input ${num_aud_pairs}
    add_interface_port conduit_audio aud_data export Input ${total_aud_data_width}
    
  }


  if { $avalon_st > 0 } {
    for {set pair 0} {$pair < $num_aud_pairs} {incr pair} {
      set_port_property aud${pair}_clk termination false
      set_port_property aud${pair}_ready termination false
      set_port_property aud${pair}_valid termination false
      set_port_property aud${pair}_sop termination false
      set_port_property aud${pair}_eop termination false
      set_port_property aud${pair}_channel termination false
      set_port_property aud${pair}_data termination false
    }
    
    for {set pair $num_aud_pairs} {$pair < $num_aud_pairs_max} {incr pair} {
      set_port_property aud${pair}_clk termination true
      set_port_property aud${pair}_ready termination true
      set_port_property aud${pair}_valid termination true
      set_port_property aud${pair}_sop termination true
      set_port_property aud${pair}_eop termination true
      set_port_property aud${pair}_channel termination true
      set_port_property aud${pair}_data termination true
    }
    
    set_port_property aud_clk termination true
    set_port_property aud_de termination true
    set_port_property aud_ws termination true
    set_port_property aud_data termination true
    
  } else {
    for {set pair 0} {$pair < $num_aud_pairs_max} {incr pair} {
      set_port_property aud${pair}_clk termination true
      set_port_property aud${pair}_ready termination true
      set_port_property aud${pair}_valid termination true
      set_port_property aud${pair}_sop termination true
      set_port_property aud${pair}_eop termination true
      set_port_property aud${pair}_channel termination true
      set_port_property aud${pair}_data termination true
    }
    
    set_port_property aud_clk termination false
    set_port_property aud_de termination false
    set_port_property aud_ws termination false
    set_port_property aud_data termination false
    
  }

  #if { $avalon_mm > 0 } {
  add_interface avalon_slave_control avalon end
  set_interface_property avalon_slave_control addressAlignment NATIVE
  set_interface_property avalon_slave_control addressSpan 64
  set_interface_property avalon_slave_control bridgesToMaster ""
  set_interface_property avalon_slave_control burstOnBurstBoundariesOnly false
  set_interface_property avalon_slave_control holdTime 0
  set_interface_property avalon_slave_control isMemoryDevice false
  set_interface_property avalon_slave_control isNonVolatileStorage false
  set_interface_property avalon_slave_control linewrapBursts false
  set_interface_property avalon_slave_control maximumPendingReadTransactions 1
  set_interface_property avalon_slave_control printableDevice false
  set_interface_property avalon_slave_control readLatency 0
  set_interface_property avalon_slave_control readWaitTime 1
  set_interface_property avalon_slave_control setupTime 0
  set_interface_property avalon_slave_control timingUnits Cycles
  set_interface_property avalon_slave_control writeWaitTime 0
  set_interface_property avalon_slave_control ASSOCIATED_CLOCK register_clock
  set_interface_property avalon_slave_control ENABLED true

  add_interface_port avalon_slave_control reg_base_addr address Input 6
  add_interface_port avalon_slave_control reg_burstcount burstcount Input 6
  add_interface_port avalon_slave_control reg_waitrequest waitrequest Output 1
  #add_interface_port avalon_slave_control reg_byteenable byteenable Input 1
  add_interface_port avalon_slave_control reg_write write Input 1
  add_interface_port avalon_slave_control reg_writedata writedata Input 8
  add_interface_port avalon_slave_control reg_read read Input 1
  add_interface_port avalon_slave_control reg_readdatavalid readdatavalid Output 1
  add_interface_port avalon_slave_control reg_readdata readdata Output 8 
  #} else {
  add_interface conduit_control conduit end
  set_interface_property conduit_control ENABLED true
  add_interface_port conduit_control audio_control export Input 8
  add_interface_port conduit_control extended_control export Input 8
  add_interface_port conduit_control video_status export Output 8
  add_interface_port conduit_control sd_edp_control export Input 8
  add_interface_port conduit_control audio_status export Output 8
  add_interface_port conduit_control cs_control export Input 16
  add_interface_port conduit_control strip_control export Input 8
  add_interface_port conduit_control strip_status export Output 8
  add_interface_port conduit_control sine_freq_ch1 export Input 8
  add_interface_port conduit_control sine_freq_ch2 export Input 8
  add_interface_port conduit_control sine_freq_ch3 export Input 8
  add_interface_port conduit_control sine_freq_ch4 export Input 8
  add_interface_port conduit_control csram_addr export Input 6
  add_interface_port conduit_control csram_we export Input 1
  add_interface_port conduit_control csram_data export Input 8
  #}
  
  
      
  if { $avalon_mm > 0 } {
    set_port_property reg_base_addr termination false
    set_port_property reg_burstcount termination false
    set_port_property reg_waitrequest termination false
    set_port_property reg_write termination false
    set_port_property reg_writedata termination false
    set_port_property reg_read termination false
    set_port_property reg_readdatavalid termination false
    set_port_property reg_readdata termination false

    set_port_property audio_control termination true
    set_port_property extended_control termination true
    set_port_property video_status termination true
    set_port_property sd_edp_control termination true
    set_port_property audio_status termination true
    set_port_property cs_control termination true
    set_port_property strip_control termination true
    set_port_property strip_status termination true
    set_port_property sine_freq_ch1 termination true
    set_port_property sine_freq_ch2 termination true
    set_port_property sine_freq_ch3 termination true
    set_port_property sine_freq_ch4 termination true
    set_port_property csram_addr termination true
    set_port_property csram_we termination true
    set_port_property csram_data termination true
  } else {
    set_port_property reg_base_addr termination true
    set_port_property reg_burstcount termination true
    set_port_property reg_waitrequest termination true
    set_port_property reg_write termination true
    set_port_property reg_writedata termination true
    set_port_property reg_read termination true
    set_port_property reg_readdatavalid termination true
    set_port_property reg_readdata termination true
    
    set_port_property audio_control termination false
    set_port_property extended_control termination false
    set_port_property video_status termination false
    set_port_property sd_edp_control termination false
    set_port_property audio_status termination false
    set_port_property cs_control termination false
    set_port_property strip_control termination false
    set_port_property strip_status termination false
    set_port_property sine_freq_ch1 termination false
    set_port_property sine_freq_ch2 termination false
    set_port_property sine_freq_ch3 termination false
    set_port_property sine_freq_ch4 termination false
    set_port_property csram_addr termination false
    set_port_property csram_we termination false
    set_port_property csram_data termination false
  }

  # set include_csram 0
  # if { [get_parameter_value G_AUDEMB_INCLUDE_CSRAM] > 0 } {
  #     set include_csram 1
  # } 
  # if { $avalon_mm > 0 || $avalon_st > 0 || $include_csram > 0 } {
  #     add_interface register_clock clock sink
  #     set_interface_property register_clock ENABLED true
  #     add_interface_port register_clock reg_clk clk Input 1
  #     add_interface_port register_clock reg_reset reset Input 1
  # }
}
# | 
# +-----------------------------------

