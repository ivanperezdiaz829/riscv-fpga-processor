package require -exact qsys 12.0
source $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/common/embedded_ip_hwtcl_common.tcl

#-------------------------------------------------------------------------------
# module properties
#-------------------------------------------------------------------------------

set_module_property NAME {altera_avalon_cf}
set_module_property DISPLAY_NAME {Altera Avalon Compact Flash}
set_module_property VERSION {13.1}
set_module_property GROUP {Memories and Memory Controllers/External Memory Interfaces/Flash Interfaces}
set_module_property AUTHOR {Altera Corporation}
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property INTERNAL false
set_module_property HIDE_FROM_SOPC true
set_module_property EDITABLE true
set_module_property ELABORATION_CALLBACK elaborate

# generation fileset

add_fileset quartus_synth QUARTUS_SYNTH sub_quartus_synth
add_fileset sim_verilog SIM_VERILOG sub_sim_verilog
add_fileset sim_vhdl SIM_VHDL sub_sim_vhdl

# links to documentation

add_documentation_link {Data Sheet } {http://www.altera.com/literature/hb/nios2/qts_qii55005.pdf}
add_documentation_link {Vendor's Website} {http://www.eurekatech.com}

#-------------------------------------------------------------------------------
# module parameters
#-------------------------------------------------------------------------------

# parameters

# system info parameters
add_parameter clockRate LONG
set_parameter_property clockRate DEFAULT_VALUE {0}
set_parameter_property clockRate DISPLAY_NAME {clockRate}
set_parameter_property clockRate VISIBLE {0}
set_parameter_property clockRate AFFECTS_GENERATION {1}
set_parameter_property clockRate HDL_PARAMETER {0}
set_parameter_property clockRate SYSTEM_INFO {clock_rate clk}
set_parameter_property clockRate SYSTEM_INFO_TYPE {CLOCK_RATE}
set_parameter_property clockRate SYSTEM_INFO_ARG {clk}

#-------------------------------------------------------------------------------
# module GUI
#-------------------------------------------------------------------------------

# display group
add_display_item {} {Interface details} GROUP

# 
# display items
# 
add_display_item {Interface details} DESCRIPTION parameter
add_display_item {Interface details} "1" TEXT "<html>The CompactFlash interface exports I/O pins suitable for using the CompactFlash socket \
on Nios development boards.<br>This interface supports only <b>True IDE</b> mode.<br>\
<br>\
Software support includes: register definitions, I/O access macros and initialization <br>\
routines with the Nios II HAL. For complete access to the IDE interface additional <br>\
software is required; the Nios II eCOS distribution and Micrium uC/FS file systems <br>\
each include such support. Additional examples may be available on the Nios Community Forum website at <br>\
http://www.niosforum.com."

#-------------------------------------------------------------------------------
# module validation
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# module elaboration
#-------------------------------------------------------------------------------

proc elaborate {} {

	# 
	# connection point clk
	# 
	add_interface clk clock end
	set_interface_property clk clockRate 0
	set_interface_property clk ENABLED true

	add_interface_port clk clk clk Input 1


	# 
	# connection point external
	# 
	add_interface external conduit end
	set_interface_property external associatedClock ""
	set_interface_property external associatedReset ""
	set_interface_property external ENABLED true

	add_interface_port external data_cf export Bidir 16
	add_interface_port external we_n export Output 1
	add_interface_port external rfu export Output 1
	add_interface_port external reset_n_cf export Output 1
	add_interface_port external power export Output 1
	add_interface_port external iowr_n export Output 1
	add_interface_port external iord_n export Output 1
	add_interface_port external cs_n export Output 2
	add_interface_port external addr export Output 11
	add_interface_port external iordy export Input 1
	add_interface_port external intrq export Input 1
	add_interface_port external detect_n export Input 1
	add_interface_port external atasel_n export Output 1


	# 
	# connection point reset
	# 
	add_interface reset reset end
	set_interface_property reset associatedClock clk
	set_interface_property reset synchronousEdges DEASSERT
	set_interface_property reset ENABLED true

	add_interface_port reset av_reset_n reset_n Input 1


	# 
	# connection point ide
	# 
	add_interface ide avalon end
	set_interface_property ide addressAlignment NATIVE
	set_interface_property ide addressUnits WORDS
	set_interface_property ide associatedClock clk
	set_interface_property ide associatedReset reset
	set_interface_property ide burstOnBurstBoundariesOnly false
	set_interface_property ide explicitAddressSpan 0
	set_interface_property ide holdTime 30
	set_interface_property ide isMemoryDevice false
	set_interface_property ide isNonVolatileStorage false
	set_interface_property ide linewrapBursts false
	set_interface_property ide maximumPendingReadTransactions 0
	set_interface_property ide printableDevice false
	set_interface_property ide readLatency 0
	set_interface_property ide readWaitStates 530
	set_interface_property ide readWaitTime 530
	set_interface_property ide setupTime 70
	set_interface_property ide timingUnits Nanoseconds
	set_interface_property ide writeWaitStates 500
	set_interface_property ide writeWaitTime 500
	set_interface_property ide ENABLED true

	add_interface_port ide av_ide_chipselect_n chipselect_n Input 1
	add_interface_port ide av_ide_read_n read_n Input 1
	add_interface_port ide av_ide_write_n write_n Input 1
	add_interface_port ide av_ide_writedata writedata Input 16
	add_interface_port ide av_ide_address address Input 4
	add_interface_port ide av_ide_readdata readdata Output 16


	# 
	# connection point ide_irq
	# 
	add_interface ide_irq interrupt end
	set_interface_property ide_irq associatedAddressablePoint ide
	set_interface_property ide_irq associatedClock clk
	set_interface_property ide_irq associatedReset reset
	set_interface_property ide_irq ENABLED true

	add_interface_port ide_irq av_ide_irq irq Output 1


	# 
	# connection point ctl_irq
	# 
	add_interface ctl_irq interrupt end
	set_interface_property ctl_irq associatedAddressablePoint ctl
	set_interface_property ctl_irq associatedClock clk
	set_interface_property ctl_irq associatedReset reset
	set_interface_property ctl_irq ENABLED true

	add_interface_port ctl_irq av_ctl_irq irq Output 1


	# 
	# connection point ctl
	# 
	add_interface ctl avalon end
	set_interface_property ctl addressAlignment NATIVE
	set_interface_property ctl addressUnits WORDS
	set_interface_property ctl associatedClock clk
	set_interface_property ctl associatedReset reset
	set_interface_property ctl burstOnBurstBoundariesOnly false
	set_interface_property ctl explicitAddressSpan 0
	set_interface_property ctl holdTime 1
	set_interface_property ctl isMemoryDevice false
	set_interface_property ctl isNonVolatileStorage false
	set_interface_property ctl linewrapBursts false
	set_interface_property ctl maximumPendingReadTransactions 0
	set_interface_property ctl printableDevice false
	set_interface_property ctl readLatency 0
	set_interface_property ctl readWaitTime 1
	set_interface_property ctl setupTime 1
	set_interface_property ctl timingUnits Cycles
	set_interface_property ctl writeWaitStates 1
	set_interface_property ctl writeWaitTime 1
	set_interface_property ctl ENABLED true

	add_interface_port ctl av_ctl_address address Input 2
	add_interface_port ctl av_ctl_chipselect_n chipselect_n Input 1
	add_interface_port ctl av_ctl_read_n read_n Input 1
	add_interface_port ctl av_ctl_write_n write_n Input 1
	add_interface_port ctl av_ctl_readdata readdata Output 4
	add_interface_port ctl av_ctl_writedata writedata Input 4
}

#-------------------------------------------------------------------------------
# module generation
#-------------------------------------------------------------------------------
# generate
proc generate {output_name output_directory rtl_ext simgen} {
	global env
	set QUARTUS_ROOTDIR         "$env(QUARTUS_ROOTDIR)"
	set component_directory     "$QUARTUS_ROOTDIR/../ip/altera/sopc_builder_ip/altera_avalon_cf"
	set component_config_file   "$output_directory/${output_name}_component_configuration.pl"

	# read parameter
	set clockRate [ get_parameter_value clockRate ]
	
	# prepare config file
	set component_config    [open $component_config_file "w"]

	#NOTE: the config file content format is in return {key => value, key => value,};
	puts $component_config "# ${output_name} Component Configuration File"
	puts $component_config "return {"

	puts $component_config "\tclock_speed         	=> $clockRate,"

	puts $component_config "};"
	close $component_config

	# generate rtl
	proc_generate_component_rtl  "$component_config_file" "$component_directory" "$output_name" "$output_directory" "$rtl_ext" "$simgen"
	proc_add_generated_files "$output_name" "$output_directory" "$rtl_ext" "$simgen"
}

