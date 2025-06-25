package require -exact qsys 12.0
source $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/common/embedded_ip_hwtcl_common.tcl

#-------------------------------------------------------------------------------
# module properties
#-------------------------------------------------------------------------------

set_module_property NAME {altera_avalon_lcd_16207}
set_module_property DISPLAY_NAME {Altera Avalon LCD 16207}
set_module_property DESCRIPTION {The Optrex 16207 LCD Controller core provides the hardware interface required for a Nios II processor to display characters on an Optrex 16207 (or equivalent) 16x2-character LCD panel. Device drivers are provided in the HAL system library for the Nios II processor. There are no user-configurable settings.}
set_module_property VERSION {13.1}
set_module_property GROUP {Peripherals/Display}
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

add_documentation_link {Data Sheet } {http://www.altera.com/literature/hb/nios2/n2cpu_nii51019.pdf}

#-------------------------------------------------------------------------------
# module parameters
#-------------------------------------------------------------------------------

# parameters


#-------------------------------------------------------------------------------
# module GUI
#-------------------------------------------------------------------------------

# display group
add_display_item {} {Description} GROUP

# 
# display items
# 
add_display_item {Description} DESCRIPTION parameter
add_display_item {Description} "1" TEXT "<html>The Optrex 16207 LCD Controller core provides the hardware interface required<br>\
for a Nios II processor to display characters on an Optrex 16207 (or equivalent)<br>\
16x2-character LCD panel. <br><br>\
Device drivers are provided in the HAL system library for the Nios II processor.<br><br>\
There are no user-configurable settings.</html>"

#-------------------------------------------------------------------------------
# module validation
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# module elaboration
#-------------------------------------------------------------------------------

proc elaborate {} {

	# 
	# connection point reset
	# 
	add_interface reset reset end
	set_interface_property reset associatedClock clk
	set_interface_property reset synchronousEdges DEASSERT
	set_interface_property reset ENABLED true

	add_interface_port reset reset_n reset_n Input 1


	# 
	# connection point clk
	# 
	add_interface clk clock end
	set_interface_property clk clockRate 0
	set_interface_property clk ENABLED true

	add_interface_port clk clk clk Input 1


	# 
	# connection point control_slave
	# 
	add_interface control_slave avalon end
	set_interface_property control_slave addressAlignment NATIVE
	set_interface_property control_slave addressUnits WORDS
	set_interface_property control_slave associatedClock clk
	set_interface_property control_slave associatedReset reset
	set_interface_property control_slave burstOnBurstBoundariesOnly false
	set_interface_property control_slave explicitAddressSpan 0
	set_interface_property control_slave holdTime 250
	set_interface_property control_slave isMemoryDevice false
	set_interface_property control_slave isNonVolatileStorage false
	set_interface_property control_slave linewrapBursts false
	set_interface_property control_slave maximumPendingReadTransactions 0
	set_interface_property control_slave printableDevice false
	set_interface_property control_slave readLatency 0
	set_interface_property control_slave readWaitStates 250
	set_interface_property control_slave readWaitTime 250
	set_interface_property control_slave setupTime 250
	set_interface_property control_slave timingUnits Nanoseconds
	set_interface_property control_slave writeWaitStates 250
	set_interface_property control_slave writeWaitTime 250
	set_interface_property control_slave ENABLED true

	add_interface_port control_slave begintransfer begintransfer Input 1
	add_interface_port control_slave read read Input 1
	add_interface_port control_slave write write Input 1
	add_interface_port control_slave readdata readdata Output 8
	add_interface_port control_slave writedata writedata Input 8
	add_interface_port control_slave address address Input 2

	set_interface_assignment control_slave embeddedsw.configuration.isPrintableDevice {1}

	# 
	# connection point external
	# 
	add_interface external conduit end
	set_interface_property external associatedClock ""
	set_interface_property external associatedReset ""
	set_interface_property external ENABLED true

	add_interface_port external LCD_RS export Output 1
	add_interface_port external LCD_RW export Output 1
	add_interface_port external LCD_data export Bidir 8
	add_interface_port external LCD_E export Output 1
}

#-------------------------------------------------------------------------------
# module generation
#-------------------------------------------------------------------------------
# generate
proc generate {output_name output_directory rtl_ext simgen} {
	global env
	set QUARTUS_ROOTDIR         "$env(QUARTUS_ROOTDIR)"
	set component_directory     "$QUARTUS_ROOTDIR/../ip/altera/sopc_builder_ip/altera_avalon_lcd_16207"
	set component_config_file   "$output_directory/${output_name}_component_configuration.pl"

	# read parameter
	
	# prepare config file
	set component_config    [open $component_config_file "w"]

	#NOTE: the config file content format is in return {key => value, key => value,};
	puts $component_config "# ${output_name} Component Configuration File"
	puts $component_config "return {"

	puts $component_config "};"
	close $component_config

	# generate rtl
	proc_generate_component_rtl  "$component_config_file" "$component_directory" "$output_name" "$output_directory" "$rtl_ext" "$simgen"
	proc_add_generated_files "$output_name" "$output_directory" "$rtl_ext" "$simgen"
}

