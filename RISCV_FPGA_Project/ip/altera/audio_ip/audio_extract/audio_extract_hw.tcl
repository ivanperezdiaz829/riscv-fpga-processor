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
# | Audio Extract v10.1
# | Altera Corporation 2010.08.19.17:16:07# 
# +-----------------------------------

#package require -exact sopc 12.0
package require -exact qsys 12.0

# +-----------------------------------
# | module audio_extract
# | 
set_module_property DESCRIPTION "Audio Extract"
set_module_property NAME audio_extract
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property GROUP "Interface Protocols/SDI"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Audio Extract"
set_module_property DATASHEET_URL http://www.altera.com/literature/ug/ug_sdi.pdf
#set_module_property TOP_LEVEL_HDL_FILE ../verilog/audio_extract.v
#set_module_property TOP_LEVEL_HDL_MODULE audio_extract
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
#set_module_property SIMULATION_MODEL_IN_VERILOG true
#set_module_property SIMULATION_MODEL_IN_VHDL true
# | 
# +-----------------------------------

# +-----------------------------------
# | IEEE Encryption
# |

add_fileset          simulation_verilog SIM_VERILOG   generate_files
add_fileset          simulation_vhdl    SIM_VHDL      generate_files
add_fileset          synthesis_fileset  QUARTUS_SYNTH generate_ed_files

set_fileset_property simulation_verilog TOP_LEVEL   audio_extract
set_fileset_property simulation_vhdl    TOP_LEVEL   audio_extract
set_fileset_property synthesis_fileset  TOP_LEVEL   audio_extract


proc generate_files {name} {
  if {1} {
    add_fileset_file mentor/audio_extract_clock.v                 VERILOG_ENCRYPT PATH mentor/src_hdl/audio_extract_clock.v                                    {MENTOR_SPECIFIC}
    add_fileset_file mentor/audio_extract_vid_clock.v             VERILOG_ENCRYPT PATH mentor/src_hdl/audio_extract_vid_clock.v                                {MENTOR_SPECIFIC}
    add_fileset_file mentor/audio_extract_core.v                  VERILOG_ENCRYPT PATH mentor/src_hdl/audio_extract_core.v                                     {MENTOR_SPECIFIC}
    add_fileset_file mentor/audio_extract_registers.v             VERILOG_ENCRYPT PATH mentor/src_hdl/audio_extract_registers.v                                {MENTOR_SPECIFIC}
    add_fileset_file mentor/altera_audext_reset_synchronizer.v    VERILOG_ENCRYPT PATH mentor/src_hdl/altera_audext_reset_synchronizer.v                       {MENTOR_SPECIFIC}
    add_fileset_file mentor/audio_extract.v                       VERILOG_ENCRYPT PATH mentor/src_hdl/audio_extract.v                                          {MENTOR_SPECIFIC}
    add_fileset_file mentor/cai_avalon.v                          VERILOG_ENCRYPT PATH ../clocked_audio_input/mentor/src_hdl/cai_avalon.v                      {MENTOR_SPECIFIC}
  }
  if {1} {
    add_fileset_file aldec/audio_extract_clock.v                 VERILOG_ENCRYPT PATH aldec/src_hdl/audio_extract_clock.v                                    {ALDEC_SPECIFIC}
    add_fileset_file aldec/audio_extract_vid_clock.v             VERILOG_ENCRYPT PATH aldec/src_hdl/audio_extract_vid_clock.v                                {ALDEC_SPECIFIC}
    add_fileset_file aldec/audio_extract_core.v                  VERILOG_ENCRYPT PATH aldec/src_hdl/audio_extract_core.v                                     {ALDEC_SPECIFIC}
    add_fileset_file aldec/audio_extract_registers.v             VERILOG_ENCRYPT PATH aldec/src_hdl/audio_extract_registers.v                                {ALDEC_SPECIFIC}
    add_fileset_file aldec/altera_audext_reset_synchronizer.v    VERILOG_ENCRYPT PATH aldec/src_hdl/altera_audext_reset_synchronizer.v                       {ALDEC_SPECIFIC}
    add_fileset_file aldec/audio_extract.v                       VERILOG_ENCRYPT PATH aldec/src_hdl/audio_extract.v                                          {ALDEC_SPECIFIC}
    add_fileset_file aldec/cai_avalon.v                          VERILOG_ENCRYPT PATH ../clocked_audio_input/aldec/src_hdl/cai_avalon.v                      {ALDEC_SPECIFIC}
  }
  if {0} {
    add_fileset_file cadence/audio_extract_clock.v                 VERILOG_ENCRYPT PATH cadence/src_hdl/audio_extract_clock.v                                    {CADENCE_SPECIFIC}
    add_fileset_file cadence/audio_extract_vid_clock.v             VERILOG_ENCRYPT PATH cadence/src_hdl/audio_extract_vid_clock.v                                {CADENCE_SPECIFIC}
    add_fileset_file cadence/audio_extract_core.v                  VERILOG_ENCRYPT PATH cadence/src_hdl/audio_extract_core.v                                     {CADENCE_SPECIFIC}
    add_fileset_file cadence/audio_extract_registers.v             VERILOG_ENCRYPT PATH cadence/src_hdl/audio_extract_registers.v                                {CADENCE_SPECIFIC}
    add_fileset_file cadence/altera_audext_reset_synchronizer.v    VERILOG_ENCRYPT PATH cadence/src_hdl/altera_audext_reset_synchronizer.v                       {CADENCE_SPECIFIC}
    add_fileset_file cadence/audio_extract.v                       VERILOG_ENCRYPT PATH cadence/src_hdl/audio_extract.v                                          {CADENCE_SPECIFIC}
    add_fileset_file cadence/cai_avalon.v                          VERILOG_ENCRYPT PATH ../clocked_audio_input/cadence/src_hdl/cai_avalon.v                      {CADENCE_SPECIFIC}
  }
  if {0} {
    add_fileset_file synopsys/audio_extract_clock.v                 VERILOG_ENCRYPT PATH synopsys/src_hdl/audio_extract_clock.v                                    {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/audio_extract_vid_clock.v             VERILOG_ENCRYPT PATH synopsys/src_hdl/audio_extract_vid_clock.v                                {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/audio_extract_core.v                  VERILOG_ENCRYPT PATH synopsys/src_hdl/audio_extract_core.v                                     {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/audio_extract_registers.v             VERILOG_ENCRYPT PATH synopsys/src_hdl/audio_extract_registers.v                                {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/altera_audext_reset_synchronizer.v    VERILOG_ENCRYPT PATH synopsys/src_hdl/altera_audext_reset_synchronizer.v                       {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/audio_extract.v                       VERILOG_ENCRYPT PATH synopsys/src_hdl/audio_extract.v                                          {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/cai_avalon.v                          VERILOG_ENCRYPT PATH ../clocked_audio_input/synopsys/src_hdl/cai_avalon.v                      {SYNOPSYS_SPECIFIC}
  }
}

proc generate_ed_files {name} {
    add_fileset_file audio_extract_clock.v                 VERILOG PATH src_hdl/audio_extract_clock.v                                    {SYNTHESIS}
    add_fileset_file audio_extract_vid_clock.v             VERILOG PATH src_hdl/audio_extract_vid_clock.v                                {SYNTHESIS}
    add_fileset_file audio_extract_core.v                  VERILOG PATH src_hdl/audio_extract_core.v                                     {SYNTHESIS}
    add_fileset_file audio_extract_registers.v             VERILOG PATH src_hdl/audio_extract_registers.v                                {SYNTHESIS}
    add_fileset_file altera_audext_reset_synchronizer.v    VERILOG PATH src_hdl/altera_audext_reset_synchronizer.v                       {SYNTHESIS}
    add_fileset_file audio_extract.v                       VERILOG PATH src_hdl/audio_extract.v                                          {SYNTHESIS}
    add_fileset_file cai_avalon.v                          VERILOG PATH ../clocked_audio_input/src_hdl/cai_avalon.v                      {SYNTHESIS}
    add_fileset_file audio_extract.ocp                     OTHER   PATH audio_extract.ocp                                                {SYNTHESIS}
    add_fileset_file audio_extract.sdc                     SDC     PATH audio_extract.sdc                                                {SYNTHESIS}
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
#add_parameter G_AUDEXT_OUTPUT_I2S INTEGER 0
#set_parameter_property G_AUDEXT_OUTPUT_I2S DISPLAY_NAME "I2S Audio Interface"
#set_parameter_property G_AUDEXT_OUTPUT_I2S DESCRIPTION ""
#set_parameter_property G_AUDEXT_OUTPUT_I2S AFFECTS_ELABORATION false
#set_parameter_property G_AUDEXT_OUTPUT_I2S ALLOWED_RANGES 0:1
#set_parameter_property G_AUDEXT_OUTPUT_I2S DISPLAY_HINT boolean
#add_parameter G_AUDEXT_OUTPUT_ASYNC INTEGER 0
#set_parameter_property G_AUDEXT_OUTPUT_ASYNC DISPLAY_NAME "Async Audio Interface"
#set_parameter_property G_AUDEXT_OUTPUT_ASYNC DESCRIPTION ""
#set_parameter_property G_AUDEXT_OUTPUT_ASYNC AFFECTS_ELABORATION false
#set_parameter_property G_AUDEXT_OUTPUT_ASYNC ALLOWED_RANGES 0:1
#set_parameter_property G_AUDEXT_OUTPUT_ASYNC DISPLAY_HINT boolean
#add_parameter G_AUDEXT_OUTPUT_PARALLEL INTEGER 0
#set_parameter_property G_AUDEXT_OUTPUT_PARALLEL DISPLAY_NAME "Parallel Audio Interface"
#set_parameter_property G_AUDEXT_OUTPUT_PARALLEL DESCRIPTION ""
#set_parameter_property G_AUDEXT_OUTPUT_PARALLEL AFFECTS_ELABORATION true
#set_parameter_property G_AUDEXT_OUTPUT_PARALLEL ALLOWED_RANGES 0:1
#set_parameter_property G_AUDEXT_OUTPUT_PARALLEL DISPLAY_HINT boolean
add_parameter G_AUDEXT_INCLUDE_SD_EDP INTEGER 1
set_parameter_property G_AUDEXT_INCLUDE_SD_EDP DISPLAY_NAME "Include SD-SDI 24bit Support"
set_parameter_property G_AUDEXT_INCLUDE_SD_EDP DESCRIPTION "Enables extra logic to recover EDP ancillary packets from SD-SDI inputs"
set_parameter_property G_AUDEXT_INCLUDE_SD_EDP AFFECTS_ELABORATION false
set_parameter_property G_AUDEXT_INCLUDE_SD_EDP ALLOWED_RANGES 0:1
set_parameter_property G_AUDEXT_INCLUDE_SD_EDP DISPLAY_HINT boolean
set_parameter_property G_AUDEXT_INCLUDE_SD_EDP IS_HDL_PARAMETER true
add_parameter G_AUDEXT_INCLUDE_CSRAM INTEGER 1
set_parameter_property G_AUDEXT_INCLUDE_CSRAM DISPLAY_NAME "Channel Status RAM"
set_parameter_property G_AUDEXT_INCLUDE_CSRAM DESCRIPTION "Stores the received channel status data"
set_parameter_property G_AUDEXT_INCLUDE_CSRAM AFFECTS_ELABORATION false
set_parameter_property G_AUDEXT_INCLUDE_CSRAM ALLOWED_RANGES 0:1
set_parameter_property G_AUDEXT_INCLUDE_CSRAM DISPLAY_HINT boolean
set_parameter_property G_AUDEXT_INCLUDE_CSRAM IS_HDL_PARAMETER true
add_parameter G_AUDEXT_INCLUDE_ERROR INTEGER 1
set_parameter_property G_AUDEXT_INCLUDE_ERROR DISPLAY_NAME "Include Error Checking"
set_parameter_property G_AUDEXT_INCLUDE_ERROR DESCRIPTION "Enables the extra error-checking logic to use the error status register"
set_parameter_property G_AUDEXT_INCLUDE_ERROR AFFECTS_ELABORATION false
set_parameter_property G_AUDEXT_INCLUDE_ERROR ALLOWED_RANGES 0:1
set_parameter_property G_AUDEXT_INCLUDE_ERROR DISPLAY_HINT boolean
set_parameter_property G_AUDEXT_INCLUDE_ERROR IS_HDL_PARAMETER true
add_parameter G_AUDEXT_INCLUDE_STATUS INTEGER 1
set_parameter_property G_AUDEXT_INCLUDE_STATUS DISPLAY_NAME "Include Status Register"
set_parameter_property G_AUDEXT_INCLUDE_STATUS DESCRIPTION "Enables extra logic to report the audio FIFO status on the fifo_status port or register"
set_parameter_property G_AUDEXT_INCLUDE_STATUS AFFECTS_ELABORATION false
set_parameter_property G_AUDEXT_INCLUDE_STATUS ALLOWED_RANGES 0:1
set_parameter_property G_AUDEXT_INCLUDE_STATUS DISPLAY_HINT boolean
set_parameter_property G_AUDEXT_INCLUDE_STATUS IS_HDL_PARAMETER true
add_parameter G_AUDEXT_INCLUDE_CLOCK INTEGER 1
set_parameter_property G_AUDEXT_INCLUDE_CLOCK DISPLAY_NAME "Include Clock"
set_parameter_property G_AUDEXT_INCLUDE_CLOCK DESCRIPTION "Enables the logic to recover both a sample rate clock and a 64x sample rate clock"
set_parameter_property G_AUDEXT_INCLUDE_CLOCK AFFECTS_ELABORATION false
set_parameter_property G_AUDEXT_INCLUDE_CLOCK ALLOWED_RANGES 0:1
set_parameter_property G_AUDEXT_INCLUDE_CLOCK DISPLAY_HINT boolean
set_parameter_property G_AUDEXT_INCLUDE_CLOCK IS_HDL_PARAMETER true
add_parameter G_AUDEXT_INCLUDE_AVALON_ST INTEGER 0
set_parameter_property G_AUDEXT_INCLUDE_AVALON_ST DISPLAY_NAME "Include Avalon-ST Interface"
set_parameter_property G_AUDEXT_INCLUDE_AVALON_ST DESCRIPTION "Includes the SDI Clocked Audio Input MegaCore"
set_parameter_property G_AUDEXT_INCLUDE_AVALON_ST AFFECTS_ELABORATION true
set_parameter_property G_AUDEXT_INCLUDE_AVALON_ST ALLOWED_RANGES 0:1
set_parameter_property G_AUDEXT_INCLUDE_AVALON_ST DISPLAY_HINT boolean
set_parameter_property G_AUDEXT_INCLUDE_AVALON_ST IS_HDL_PARAMETER true
add_parameter G_AUDEXT_INCLUDE_CTRL_REG INTEGER 0
set_parameter_property G_AUDEXT_INCLUDE_CTRL_REG DISPLAY_NAME "Include Avalon-MM Control Interface"
set_parameter_property G_AUDEXT_INCLUDE_CTRL_REG DESCRIPTION "Includes the Avalon-MM control interface"
set_parameter_property G_AUDEXT_INCLUDE_CTRL_REG AFFECTS_ELABORATION true
set_parameter_property G_AUDEXT_INCLUDE_CTRL_REG ALLOWED_RANGES 0:1
set_parameter_property G_AUDEXT_INCLUDE_CTRL_REG DISPLAY_HINT boolean
set_parameter_property G_AUDEXT_INCLUDE_CTRL_REG IS_HDL_PARAMETER true

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
add_interface_port conduit_video vid_clk export Input 1
add_interface_port conduit_video reset export Input 1
add_interface_port conduit_video vid_std export Input 2
add_interface_port conduit_video vid_datavalid export Input 1
add_interface_port conduit_video vid_data export Input 20
add_interface_port conduit_video vid_locked export Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point conduit_audio_clocks
# | 
add_interface conduit_audio_clocks conduit end
set_interface_property conduit_audio_clocks ENABLED true
add_interface_port conduit_audio_clocks fix_clk export Input 1
add_interface_port conduit_audio_clocks aud_clk_out export Output 1
add_interface_port conduit_audio_clocks aud_clk48_out export Output 1
# |
# +-----------------------------------

# +-----------------------------------
# | connection point conduit_audio
# | 
#add_interface conduit_audio conduit end
#set_interface_property conduit_audio ENABLED true
#add_interface_port conduit_audio aud_clk export Input 1
#add_interface_port conduit_audio aud_ws_in export Input 1
#add_interface_port conduit_audio aud_de export Output 1
#add_interface_port conduit_audio aud_ws export Output 1
# | 
# +-----------------------------------
#validation call back for disabling parameters
#set_module_property VALIDATION_CALLBACK my_validation_callback

#proc my_validation_callback {} {
#   set family [get_parameter_value FAMILY]	

#	if { $family == "Cyclone V"} {
#		send_message error "Device family not supported: Cyclone V"
#   } 
#}
# +-----------------------------------
# Create the interfaces on elaboration
# |
set_module_property ELABORATION_CALLBACK my_elaboration_callback

proc my_elaboration_callback {} {

  #set aud_data_xwidth [expr [get_parameter_value G_AUDEXT_OUTPUT_PARALLEL] * 31]
  set aud_data_xwidth 0
  set aud_data_width [expr 1 + ${aud_data_xwidth}]
  
  set avalon_st 0
  if { [get_parameter_value G_AUDEXT_INCLUDE_AVALON_ST] > 0 } {
    set avalon_st 1
  }

  set avalon_mm 0
  if { [get_parameter_value G_AUDEXT_INCLUDE_CTRL_REG] > 0 } {
    set avalon_mm 1
  }

  
  # connection point conduit_audio
  add_interface conduit_audio conduit end
  set_interface_property conduit_audio ENABLED true  
  add_interface_port conduit_audio aud_ws_in export Input 1
  add_interface_port conduit_audio aud_de export Output 1
  add_interface_port conduit_audio aud_ws export Output 1
  add_interface_port conduit_audio aud_z export Output 1
  #add_interface_port conduit_audio aud_data export Output 24
  
  
  if { $avalon_st > 0 } {
    # Set interface properties
    add_interface aud_dout_clock clock sink  
    set_interface_property aud_dout_clock ENABLED true 
    add_interface_port aud_dout_clock aud_clk clk Input 1
    
    # Declare the interface    
    add_interface aud_dout avalon_streaming start
    set_interface_property aud_dout dataBitsPerSymbol 24
    set_interface_property aud_dout errorDescriptor ""
    set_interface_property aud_dout maxChannel 255
    set_interface_property aud_dout readyLatency 1
    set_interface_property aud_dout symbolsPerBeat 1
    set_interface_property aud_dout ASSOCIATED_CLOCK aud_dout_clock
    
    # Declare signals 
    add_interface_port aud_dout aud_ready ready Input 1
    add_interface_port aud_dout aud_valid valid Output 1
    add_interface_port aud_dout aud_sop startofpacket Output 1
    add_interface_port aud_dout aud_eop endofpacket Output 1
    add_interface_port aud_dout aud_channel channel Output 8
    add_interface_port aud_dout aud_data data Output 24
  } else {
    
    #declare terminated Avalon port
    add_interface_port conduit_audio aud_ready ready Input 1
    add_interface_port conduit_audio aud_valid valid Output 1
    add_interface_port conduit_audio aud_sop startofpacket Output 1
    add_interface_port conduit_audio aud_eop endofpacket Output 1
    add_interface_port conduit_audio aud_channel channel Output 8
    
    #declare conduit port
    add_interface_port conduit_audio aud_clk export Input 1
    add_interface_port conduit_audio aud_data export Output ${aud_data_width}
  }
  
  # aud_data need to be std_logic_vector in VHDL
  set_port_property aud_data VHDL_TYPE std_logic_vector
  
  if { $avalon_st > 0 } {
    #set_port_property aud_clk termination false
    set_port_property aud_ready termination false
    set_port_property aud_valid termination false
    set_port_property aud_sop termination false
    set_port_property aud_eop termination false
    set_port_property aud_channel termination false
    #set_port_property aud_data termination false
    
    #set_port_property aud_clk termination true
    set_port_property aud_ws_in termination true
    set_port_property aud_de termination true
    set_port_property aud_ws termination true
    set_port_property aud_z termination true
    #set_port_property aud_data termination true
    
    
  } else {
    #set_port_property aud_clk termination true
    set_port_property aud_ready termination true
    set_port_property aud_valid termination true
    set_port_property aud_sop termination true
    set_port_property aud_eop termination true
    set_port_property aud_channel termination true
    #set_port_property aud_data termination true
    
    #set_port_property aud_clk termination false
    set_port_property aud_ws_in termination false
    set_port_property aud_de termination false
    set_port_property aud_ws termination false
    set_port_property aud_z termination false
    #set_port_property aud_data termination false
  }

  #add_interface_port conduit_audio aud_data export Output ${aud_data_width}
  #set_port_property aud_data vhdl_type std_logic_vector

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
  add_interface_port conduit_control audio_presence export Output 8
  add_interface_port conduit_control audio_status export Output 8
  add_interface_port conduit_control sd_edp_presence export Output 8
  add_interface_port conduit_control error_status export Output 8
  add_interface_port conduit_control error_reset export Input 8
  add_interface_port conduit_control fifo_status export Output 8
  add_interface_port conduit_control fifo_reset export Input 1
  add_interface_port conduit_control clock_status export Output 8
  add_interface_port conduit_control csram_addr export Input 6
  add_interface_port conduit_control csram_data export Output 8
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
    set_port_property audio_presence termination true
    set_port_property audio_status termination true
    set_port_property sd_edp_presence termination true
    set_port_property error_status termination true
    set_port_property error_reset termination true
    set_port_property fifo_status termination true
    set_port_property fifo_reset termination true
    set_port_property clock_status termination true
    set_port_property csram_addr termination true
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
    set_port_property audio_presence termination false
    set_port_property audio_status termination false
    set_port_property sd_edp_presence termination false
    set_port_property error_status termination false
    set_port_property error_reset termination false
    set_port_property fifo_status termination false
    set_port_property fifo_reset termination false
    set_port_property clock_status termination false
    set_port_property csram_addr termination false
    set_port_property csram_data termination false
  }
    
}
# | 
# +-----------------------------------
