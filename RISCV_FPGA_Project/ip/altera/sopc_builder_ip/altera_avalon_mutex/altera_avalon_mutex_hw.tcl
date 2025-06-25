package require -exact qsys 12.0
source $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/common/embedded_ip_hwtcl_common.tcl

#-------------------------------------------------------------------------------
# module properties
#-------------------------------------------------------------------------------

set_module_property NAME {altera_avalon_mutex}
set_module_property DISPLAY_NAME {Altera Avalon Mutex}
set_module_property DESCRIPTION {The initial owner must release the mutex before it can be acquired by another owner. Nios II processors use their cpuid register value for the owner field. SOPC Builder assigns cpuid values to each Nios II core, starting from 0x0000, and incrementing in the order that the Nios II components appear on the System Contents tab.}
set_module_property VERSION {13.1}
set_module_property GROUP {Microcontroller Peripherals}
set_module_property AUTHOR {Altera Corporation}
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property INTERNAL false
set_module_property HIDE_FROM_SOPC true
set_module_property EDITABLE true
set_module_property VALIDATION_CALLBACK validate
set_module_property ELABORATION_CALLBACK elaborate

# generation fileset

add_fileset quartus_synth QUARTUS_SYNTH sub_quartus_synth
add_fileset sim_verilog SIM_VERILOG sub_sim_verilog
add_fileset sim_vhdl SIM_VHDL sub_sim_vhdl

# links to documentation

add_documentation_link {Data Sheet } {http://www.altera.com/literature/hb/nios2/n2cpu_nii51020.pdf}

#-------------------------------------------------------------------------------
# module parameters
#-------------------------------------------------------------------------------

# parameters
add_parameter initialValue INTEGER 0
set_parameter_property initialValue DEFAULT_VALUE 0
set_parameter_property initialValue DISPLAY_NAME "Initial Value"
set_parameter_property initialValue TYPE INTEGER
set_parameter_property initialValue UNITS None
set_parameter_property initialValue ALLOWED_RANGES 0:65535
set_parameter_property initialValue DISPLAY_HINT "Hexadecimal"
set_parameter_property initialValue HDL_PARAMETER false

add_parameter initialOwner INTEGER 0
set_parameter_property initialOwner DEFAULT_VALUE 0
set_parameter_property initialOwner DISPLAY_NAME "Initial Owner"
set_parameter_property initialOwner TYPE INTEGER
set_parameter_property initialOwner UNITS None
set_parameter_property initialOwner ALLOWED_RANGES 0:65535
set_parameter_property initialOwner DISPLAY_HINT "Hexadecimal"
set_parameter_property initialOwner HDL_PARAMETER false

#-------------------------------------------------------------------------------
# module GUI
#-------------------------------------------------------------------------------

# display group
add_display_item {} {Initial Settings} GROUP

# 
# display items
# 
add_display_item {Initial Settings} initialValue parameter
add_display_item {Initial Settings} "1" TEXT "<html>The initial value must be between 0x0 and 0xFFFF.<BR>Set to a non-zero value to allow an initial owner.<\html>"

add_display_item {Initial Settings} initialOwner parameter
add_display_item {Initial Settings} "2" TEXT "The initial owner must be between 0x0 and 0xFFFF."

#-------------------------------------------------------------------------------
# module validation
#-------------------------------------------------------------------------------

proc validate { }  {
	set initialValue [get_parameter_value initialValue]
	set initialOwner [get_parameter_value initialOwner]
	
	if { $initialValue == 0 } {
		set_parameter_property initialOwner ENABLED false
		send_message info "The initial owner must release the mutex before it can be acquired by another owner. Nios II processors use their cpuid register value for the owner field. SOPC Builder assigns cpuid values to each Nios II core, starting from 0x0000, and incrementing in the order that the Nios II components appear on the System Contents tab."
	} else {
		set_parameter_property initialOwner ENABLED true
		send_message info "The initial owner must release the mutex before it can be acquired by another owner. Nios II processors use their cpuid register value for the owner field. SOPC Builder assigns cpuid values to each Nios II core, starting from 0x0000, and incrementing in the order that the Nios II components appear on the System Contents tab."
	}

	set_module_assignment embeddedsw.CMacro.VALUE_WIDTH "16"
	set_module_assignment embeddedsw.CMacro.VALUE_INIT "$initialValue"
	set_module_assignment embeddedsw.CMacro.OWNER_WIDTH "16"
	set_module_assignment embeddedsw.CMacro.OWNER_INIT "$initialOwner"

	# Set DTS parameters
	set_module_assignment embeddedsw.dts.vendor "altr"
	set_module_assignment embeddedsw.dts.group "mutex"
	set_module_assignment embeddedsw.dts.compatible "altr,hwmutex-1.0"
}

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
	# connection point s1
	# 
	add_interface s1 avalon end
	set_interface_property s1 addressAlignment NATIVE
	set_interface_property s1 addressUnits WORDS
	set_interface_property s1 associatedClock clk
	set_interface_property s1 associatedReset reset
	set_interface_property s1 burstOnBurstBoundariesOnly false
	set_interface_property s1 explicitAddressSpan 0
	set_interface_property s1 holdTime 0
	set_interface_property s1 isMemoryDevice false
	set_interface_property s1 isNonVolatileStorage false
	set_interface_property s1 linewrapBursts false
	set_interface_property s1 maximumPendingReadTransactions 0
	set_interface_property s1 printableDevice false
	set_interface_property s1 readLatency 0
	set_interface_property s1 readWaitTime 1
	set_interface_property s1 setupTime 0
	set_interface_property s1 timingUnits Cycles
	set_interface_property s1 writeWaitTime 0
	set_interface_property s1 ENABLED true

	add_interface_port s1 chipselect chipselect Input 1
	add_interface_port s1 data_from_cpu writedata Input 32
	add_interface_port s1 read read Input 1
	add_interface_port s1 write write Input 1
	add_interface_port s1 data_to_cpu readdata Output 32
	add_interface_port s1 address address Input 1

}

#-------------------------------------------------------------------------------
# module generation
#-------------------------------------------------------------------------------
# generate
proc generate {output_name output_directory rtl_ext simgen} {
	global env
	set QUARTUS_ROOTDIR         "$env(QUARTUS_ROOTDIR)"
	set component_directory     "$QUARTUS_ROOTDIR/../ip/altera/sopc_builder_ip/altera_avalon_mutex"
	set component_config_file   "$output_directory/${output_name}_component_configuration.pl"

	# read parameter
	set initialValue [get_parameter_value initialValue]
	set initialOwner [get_parameter_value initialOwner]
	
	# prepare config file
	set component_config    [open $component_config_file "w"]

	#NOTE: the config file content format is in return {key => value, key => value,};
	puts $component_config "# ${output_name} Component Configuration File"
	puts $component_config "return {"

	puts $component_config "\tvalue_init         	=> $initialValue,"
	puts $component_config "\towner_init         	=> $initialOwner,"
	puts $component_config "\tvalue_width        	=> 16,"
	puts $component_config "\towner_width        	=> 16,"

	puts $component_config "};"
	close $component_config

	# generate rtl
	proc_generate_component_rtl  "$component_config_file" "$component_directory" "$output_name" "$output_directory" "$rtl_ext" "$simgen"
	proc_add_generated_files "$output_name" "$output_directory" "$rtl_ext" "$simgen"
}

