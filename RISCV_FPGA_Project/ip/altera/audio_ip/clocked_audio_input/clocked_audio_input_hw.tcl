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


# +-----------------------------------
# |
# | Altera Corporation 2010.08.19.17:19:07
# | Clocked Audio Input v10.1
# | 
# +-----------------------------------

#package require -exact sopc 12.0
package require -exact qsys 12.0

# +-----------------------------------
# | module clocked_audio_input
# | 
set_module_property DESCRIPTION "Clocked Audio Input"
set_module_property NAME clocked_audio_input
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property GROUP "Interface Protocols/SDI"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Clocked Audio Input"
set_module_property DATASHEET_URL http://www.altera.com/literature/ug/ug_sdi.pdf
#set_module_property TOP_LEVEL_HDL_FILE ../verilog/clocked_audio_input.v
#set_module_property TOP_LEVEL_HDL_MODULE clocked_audio_input
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
#set_module_property SIMULATION_MODEL_IN_VERILOG true
#set_module_property SIMULATION_MODEL_IN_VHDL true
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
#set module_dir [get_module_property MODULE_DIRECTORY]
#add_file ${module_dir}/../verilog/cai_avalon.v {SYNTHESIS}
#add_file ${module_dir}/../verilog/cai_registers.v {SYNTHESIS}
#add_file ${module_dir}/../verilog/altera_cai_reset_synchronizer.v {SYNTHESIS}
#add_file ${module_dir}/../verilog/clocked_audio_input.v {SYNTHESIS}
# | 
# +-----------------------------------

# +-----------------------------------
# | IEEE Encryption
# |

add_fileset          simulation_verilog SIM_VERILOG   generate_files
add_fileset          simulation_vhdl    SIM_VHDL      generate_files
add_fileset          synthesis_fileset  QUARTUS_SYNTH generate_ed_files

set_fileset_property simulation_verilog TOP_LEVEL   clocked_audio_input
set_fileset_property simulation_vhdl    TOP_LEVEL   clocked_audio_input
set_fileset_property synthesis_fileset  TOP_LEVEL   clocked_audio_input

proc generate_files {name} {
  if {1} {
    add_fileset_file mentor/cai_avalon.v                      VERILOG_ENCRYPT PATH mentor/src_hdl/cai_avalon.v                     {MENTOR_SPECIFIC}
    add_fileset_file mentor/cai_registers.v                   VERILOG_ENCRYPT PATH mentor/src_hdl/cai_registers.v                  {MENTOR_SPECIFIC}
    add_fileset_file mentor/altera_cai_reset_synchronizer.v   VERILOG_ENCRYPT PATH mentor/src_hdl/altera_cai_reset_synchronizer.v  {MENTOR_SPECIFIC}
    add_fileset_file mentor/clocked_audio_input.v             VERILOG_ENCRYPT PATH mentor/src_hdl/clocked_audio_input.v            {MENTOR_SPECIFIC}
  }
  if {1} {
    add_fileset_file aldec/cai_avalon.v                      VERILOG_ENCRYPT PATH aldec/src_hdl/cai_avalon.v                     {ALDEC_SPECIFIC}
    add_fileset_file aldec/cai_registers.v                   VERILOG_ENCRYPT PATH aldec/src_hdl/cai_registers.v                  {ALDEC_SPECIFIC}
    add_fileset_file aldec/altera_cai_reset_synchronizer.v   VERILOG_ENCRYPT PATH aldec/src_hdl/altera_cai_reset_synchronizer.v  {ALDEC_SPECIFIC}
    add_fileset_file aldec/clocked_audio_input.v             VERILOG_ENCRYPT PATH aldec/src_hdl/clocked_audio_input.v            {ALDEC_SPECIFIC}
  }
  if {0} {
    add_fileset_file cadence/cai_avalon.v                      VERILOG_ENCRYPT PATH cadence/src_hdl/cai_avalon.v                     {CADENCE_SPECIFIC}
    add_fileset_file cadence/cai_registers.v                   VERILOG_ENCRYPT PATH cadence/src_hdl/cai_registers.v                  {CADENCE_SPECIFIC}
    add_fileset_file cadence/altera_cai_reset_synchronizer.v   VERILOG_ENCRYPT PATH cadence/src_hdl/altera_cai_reset_synchronizer.v  {CADENCE_SPECIFIC}
    add_fileset_file cadence/clocked_audio_input.v             VERILOG_ENCRYPT PATH cadence/src_hdl/clocked_audio_input.v            {CADENCE_SPECIFIC}
  }
  if {0} {
    add_fileset_file synopsys/cai_avalon.v                      VERILOG_ENCRYPT PATH synopsys/src_hdl/cai_avalon.v                     {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/cai_registers.v                   VERILOG_ENCRYPT PATH synopsys/src_hdl/cai_registers.v                  {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/altera_cai_reset_synchronizer.v   VERILOG_ENCRYPT PATH synopsys/src_hdl/altera_cai_reset_synchronizer.v  {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/clocked_audio_input.v             VERILOG_ENCRYPT PATH synopsys/src_hdl/clocked_audio_input.v            {SYNOPSYS_SPECIFIC}
  }
}

proc generate_ed_files {name} {
    add_fileset_file cai_avalon.v                      VERILOG PATH src_hdl/cai_avalon.v                     {SYNTHESIS}
    add_fileset_file cai_registers.v                   VERILOG PATH src_hdl/cai_registers.v                  {SYNTHESIS}
    add_fileset_file altera_cai_reset_synchronizer.v   VERILOG PATH src_hdl/altera_cai_reset_synchronizer.v  {SYNTHESIS}
    add_fileset_file clocked_audio_input.v             VERILOG PATH src_hdl/clocked_audio_input.v            {SYNTHESIS}
    add_fileset_file clocked_audio_input.ocp           OTHER   PATH clocked_audio_input.ocp                  {SYNTHESIS}
    add_fileset_file clocked_audio_input.sdc           SDC     PATH clocked_audio_input.sdc                  {SYNTHESIS}
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
#add_parameter G_CAI_I2S INTEGER 0
#set_parameter_property G_CAI_I2S DISPLAY_NAME "I2S Audio Interface"
#set_parameter_property G_CAI_I2S DESCRIPTION ""
#set_parameter_property G_CAI_I2S AFFECTS_ELABORATION false
#set_parameter_property G_CAI_I2S ALLOWED_RANGES 0:1
#set_parameter_property G_CAI_I2S DISPLAY_HINT boolean
add_parameter G_CAI_FIFO_DEPTH INTEGER 4
set_parameter_property G_CAI_FIFO_DEPTH DISPLAY_NAME "Fifo Size (2^3 to 2^10)"
set_parameter_property G_CAI_FIFO_DEPTH UNITS None
set_parameter_property G_CAI_FIFO_DEPTH DESCRIPTION "Defines the internal FIFO depth"
set_parameter_property G_CAI_FIFO_DEPTH AFFECTS_ELABORATION false
set_parameter_property G_CAI_FIFO_DEPTH ALLOWED_RANGES 3:10
set_parameter_property G_CAI_FIFO_DEPTH IS_HDL_PARAMETER true
add_parameter G_CAI_INCLUDE_CTRL_REG INTEGER 0
set_parameter_property G_CAI_INCLUDE_CTRL_REG DISPLAY_NAME "Include Avalon-MM Control Interface"
set_parameter_property G_CAI_INCLUDE_CTRL_REG UNITS None
set_parameter_property G_CAI_INCLUDE_CTRL_REG DESCRIPTION "Includes the Avalon-MM control interface"
set_parameter_property G_CAI_INCLUDE_CTRL_REG AFFECTS_ELABORATION true
set_parameter_property G_CAI_INCLUDE_CTRL_REG ALLOWED_RANGES 0:1
set_parameter_property G_CAI_INCLUDE_CTRL_REG DISPLAY_HINT boolean
set_parameter_property G_CAI_INCLUDE_CTRL_REG IS_HDL_PARAMETER true
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point control_clock
# | 
add_interface control_clock clock sink
set_interface_property control_clock ENABLED true
add_interface_port control_clock reg_clk clk Input 1
add_interface_port control_clock reg_reset reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point conduit_aes_audio
# |
add_interface conduit_aes_audio conduit end
set_interface_property conduit_aes_audio ENABLED true
add_interface_port conduit_aes_audio aes_clk export Input 1
add_interface_port conduit_aes_audio aes_de export Input 1
add_interface_port conduit_aes_audio aes_ws export Input 1
add_interface_port conduit_aes_audio aes_data export Input 1
# |
# +-----------------------------------

# +-----------------------------------
# | connection point dout_clock
# | 
add_interface dout_clock clock sink
set_interface_property dout_clock ENABLED true
add_interface_port dout_clock aud_clk clk Input 1
add_interface_port dout_clock reset reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point dout
# | 
# Declare the interface
add_interface dout avalon_streaming start
# Set interface properties
set_interface_property dout dataBitsPerSymbol 24
set_interface_property dout errorDescriptor ""
set_interface_property dout maxChannel 255
set_interface_property dout readyLatency 1
set_interface_property dout symbolsPerBeat 1
set_interface_property dout ASSOCIATED_CLOCK dout_clock
# Declare signals
add_interface_port dout aud_ready ready Input 1
add_interface_port dout aud_valid valid Output 1
add_interface_port dout aud_sop startofpacket Output 1
add_interface_port dout aud_eop endofpacket Output 1
add_interface_port dout aud_channel channel Output 8
add_interface_port dout aud_data data Output 24
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
  set avalon_mm 0
  if { [get_parameter_value G_CAI_INCLUDE_CTRL_REG] > 0 } {
    set avalon_mm 1
  }
  
  #if { $avalon_mm > 0 } {
  add_interface control avalon end
  set_interface_property control addressAlignment NATIVE
  set_interface_property control addressSpan 8
  set_interface_property control bridgesToMaster ""
  set_interface_property control burstOnBurstBoundariesOnly false
  set_interface_property control holdTime 0
  set_interface_property control isMemoryDevice false
  set_interface_property control isNonVolatileStorage false
  set_interface_property control linewrapBursts false
  set_interface_property control maximumPendingReadTransactions 1
  set_interface_property control printableDevice false
  set_interface_property control readLatency 0
  set_interface_property control readWaitTime 1
  set_interface_property control setupTime 0
  set_interface_property control timingUnits Cycles
  set_interface_property control writeWaitTime 0
  
  set_interface_property control ASSOCIATED_CLOCK control_clock
  set_interface_property control ENABLED true
  
  add_interface_port control reg_base_addr address Input 3
  add_interface_port control reg_burstcount burstcount Input 3
  add_interface_port control reg_waitrequest waitrequest Output 1
  add_interface_port control reg_write write Input 1
  add_interface_port control reg_writedata writedata Input 8
  add_interface_port control reg_read read Input 1
  add_interface_port control reg_readdatavalid readdatavalid Output 1
  add_interface_port control reg_readdata readdata Output 8
    
  #} else {
  add_interface conduit_control conduit end
  set_interface_property conduit_control ENABLED true
  add_interface_port conduit_control channel0 export Input 8
  add_interface_port conduit_control channel1 export Input 8
  add_interface_port conduit_control fifo_status export Output 8
  add_interface_port conduit_control fifo_reset export Input 1
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
    
    set_port_property channel0 termination true
    set_port_property channel1 termination true
    set_port_property fifo_status termination true
    set_port_property fifo_reset termination true
    
  } else {
    set_port_property reg_base_addr termination true
    set_port_property reg_burstcount termination true
    set_port_property reg_waitrequest termination true
    set_port_property reg_write termination true
    set_port_property reg_writedata termination true
    set_port_property reg_read termination true
    set_port_property reg_readdatavalid termination true
    set_port_property reg_readdata termination true
    
    set_port_property channel0 termination false
    set_port_property channel1 termination false
    set_port_property fifo_status termination false
    set_port_property fifo_reset termination false
  }
  
  
  
}
