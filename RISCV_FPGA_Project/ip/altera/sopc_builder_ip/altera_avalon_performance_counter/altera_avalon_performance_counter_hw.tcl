package require -exact qsys 12.0
source $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/common/embedded_ip_hwtcl_common.tcl

#-------------------------------------------------------------------------------
# module properties
#-------------------------------------------------------------------------------

#TODO#16: update name to altera_avalon_performance_counter
set_module_property NAME {altera_avalon_performance_counter}
set_module_property DISPLAY_NAME {Performance Counter Unit}
set_module_property VERSION {13.1}
set_module_property GROUP {Peripherals/Debug and Performance}
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

add_documentation_link {Data Sheet } {http://www.altera.com/literature/hb/nios2/qts_qii55001.pdf}

#-------------------------------------------------------------------------------
# module parameters
#-------------------------------------------------------------------------------

# parameters

add_parameter numberOfSections INTEGER
set_parameter_property numberOfSections DEFAULT_VALUE {3}
set_parameter_property numberOfSections DISPLAY_NAME {Number of simultaneously-measured sections}
set_parameter_property numberOfSections ALLOWED_RANGES {1 2 3 4 5 6 7}
set_parameter_property numberOfSections AFFECTS_GENERATION {1}
set_parameter_property numberOfSections HDL_PARAMETER {0}

# system info parameters

# derived parameters

add_parameter control_slave_address_width INTEGER
set_parameter_property control_slave_address_width DEFAULT_VALUE {3}
set_parameter_property control_slave_address_width DISPLAY_NAME {control slave address width}
set_parameter_property control_slave_address_width ALLOWED_RANGES {0:256}
set_parameter_property control_slave_address_width AFFECTS_GENERATION {1}
set_parameter_property control_slave_address_width DERIVED {1}
set_parameter_property control_slave_address_width VISIBLE {0}
set_parameter_property control_slave_address_width HDL_PARAMETER {0}

#-------------------------------------------------------------------------------
# module GUI
#-------------------------------------------------------------------------------

# display group
add_display_item {} {Configuration} GROUP
add_display_item {} {Description} GROUP

# group parameter
add_display_item {Configuration} numberOfSections PARAMETER

add_display_item {Description} DESCRIPTION parameter

add_display_item {Description} "1" TEXT "<html>This peripheral and associated software macros allow minimally-intrusive, <br>\
real-time hardware profiling of your software program. <br><br>\
You can simultaneously measure several <i>sections</i> of your program. <br>\
Each measured section uses both a <b>64-bit</b> time-counter and a 32-bit occurrence counter.<br>\
The time counter measures the total time spent in a section of code with single-clock resolution.<br>\
The occurrence-counter measures how many times a section of code is entered.<br><br>\
Macros declared in this peripheral's header file make it easy to start and stop counters <br>\
when entering and exiting sections of C-code.<br>\
C library routines allow you to retrieve and analyze the results.<br> <br>\
See the datasheet in the Documentation links for more information.<br></html>"


#-------------------------------------------------------------------------------
# module validation
#-------------------------------------------------------------------------------

proc validate {} {

	# read user and system info parameter

	set numberOfSections [ get_parameter_value numberOfSections ]

	# validate parameter and update derived parameter
	set calculated_address_width [expr log10(($numberOfSections+1)*4)/log10(2)]
	set ceil_width [expr ceil($calculated_address_width)]

	# embedded software assignments

	set_module_assignment embeddedsw.CMacro.HOW_MANY_SECTIONS "$numberOfSections"

	# save derived parameter

	set_parameter_value control_slave_address_width $ceil_width
}

#-------------------------------------------------------------------------------
# module elaboration
#-------------------------------------------------------------------------------

proc elaborate {} {

	# read parameter

	set control_slave_address_width [ get_parameter_value control_slave_address_width ]

	# interfaces

	add_interface clk clock sink
	set_interface_property clk clockRate {0.0}
	set_interface_property clk externallyDriven {0}

	add_interface_port clk clk clk Input 1

	add_interface reset reset sink
	set_interface_property reset associatedClock {clk}
	set_interface_property reset synchronousEdges {DEASSERT}

	add_interface_port reset reset_n reset_n Input 1

	add_interface control_slave avalon slave
	set_interface_property control_slave addressAlignment {NATIVE}
	set_interface_property control_slave addressGroup {0}
	set_interface_property control_slave addressSpan {16}
	set_interface_property control_slave addressUnits {WORDS}
	set_interface_property control_slave alwaysBurstMaxBurst {0}
	set_interface_property control_slave associatedClock {clk}
	set_interface_property control_slave associatedReset {reset}
	set_interface_property control_slave bitsPerSymbol {8}
	set_interface_property control_slave bridgesToMaster {}
	set_interface_property control_slave burstOnBurstBoundariesOnly {0}
	set_interface_property control_slave burstcountUnits {WORDS}
	set_interface_property control_slave constantBurstBehavior {0}
	set_interface_property control_slave explicitAddressSpan {0}
	set_interface_property control_slave holdTime {0}
	set_interface_property control_slave interleaveBursts {0}
	set_interface_property control_slave isBigEndian {0}
	set_interface_property control_slave isFlash {0}
	set_interface_property control_slave isMemoryDevice {0}
	set_interface_property control_slave isNonVolatileStorage {0}
	set_interface_property control_slave linewrapBursts {0}
	set_interface_property control_slave maximumPendingReadTransactions {0}
	set_interface_property control_slave minimumUninterruptedRunLength {1}
	set_interface_property control_slave printableDevice {0}
	set_interface_property control_slave readLatency {1}
	set_interface_property control_slave readWaitStates {0}
	set_interface_property control_slave readWaitTime {0}
	set_interface_property control_slave registerIncomingSignals {0}
	set_interface_property control_slave registerOutgoingSignals {0}
	set_interface_property control_slave setupTime {0}
	set_interface_property control_slave timingUnits {Cycles}
	set_interface_property control_slave transparentBridge {0}
	set_interface_property control_slave wellBehavedWaitrequest {0}
	set_interface_property control_slave writeLatency {0}
	set_interface_property control_slave writeWaitStates {0}
	set_interface_property control_slave writeWaitTime {0}

	add_interface_port control_slave address address Input "$control_slave_address_width"
	add_interface_port control_slave begintransfer begintransfer Input 1
	add_interface_port control_slave readdata readdata Output 32
	add_interface_port control_slave write write Input 1
	add_interface_port control_slave writedata writedata Input 32

	set_interface_assignment control_slave embeddedsw.configuration.isFlash {0}
	set_interface_assignment control_slave embeddedsw.configuration.isMemoryDevice {0}
	set_interface_assignment control_slave embeddedsw.configuration.isNonVolatileStorage {0}
	set_interface_assignment control_slave embeddedsw.configuration.isPrintableDevice {0}

}

#-------------------------------------------------------------------------------
# module generation
#-------------------------------------------------------------------------------

# generate
proc generate {output_name output_directory rtl_ext simulation} {
	global env
	set QUARTUS_ROOTDIR         "$env(QUARTUS_ROOTDIR)"
	set component_directory     "$QUARTUS_ROOTDIR/../ip/altera/sopc_builder_ip/altera_avalon_performance_counter"
	set component_config_file   "$output_directory/${output_name}_component_configuration.pl"

	# read parameter

	set numberOfSections [ get_parameter_value numberOfSections ]

	# prepare config file
	set component_config    [open $component_config_file "w"]

	puts $component_config "# ${output_name} Component Configuration File"
	puts $component_config "return {"

	puts $component_config "\thow_many_sections            => \"$numberOfSections\","

	puts $component_config "};"
	close $component_config

	# generate rtl
	proc_generate_component_rtl  "$component_config_file" "$component_directory" "$output_name" "$output_directory" "$rtl_ext" "$simulation"
	proc_add_generated_files "$output_name" "$output_directory" "$rtl_ext" "$simulation"
}

