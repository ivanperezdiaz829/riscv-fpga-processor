package require -exact qsys 12.0
source $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/common/embedded_ip_hwtcl_common.tcl

#-------------------------------------------------------------------------------
# module properties
#-------------------------------------------------------------------------------

set_module_property NAME {altera_avalon_epcs_flash_controller}
set_module_property DISPLAY_NAME {EPCS/EPCQx1 Serial Flash Controller}
set_module_property VERSION {13.1}
set_module_property GROUP {Memories and Memory Controllers/External Memory Interfaces/Memory Interfaces/Flash}
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

add_documentation_link {Data Sheet} {http://www.altera.com/literature/hb/nios2/n2cpu_nii51012.pdf}

#-------------------------------------------------------------------------------
# module parameters
#-------------------------------------------------------------------------------

# parameters

add_parameter autoSelectASMIAtom BOOLEAN
set_parameter_property autoSelectASMIAtom DEFAULT_VALUE {true}
set_parameter_property autoSelectASMIAtom DISPLAY_NAME {Automatically select dedicated active serial interface, if supported}
set_parameter_property autoSelectASMIAtom AFFECTS_GENERATION {1}
set_parameter_property autoSelectASMIAtom HDL_PARAMETER {0}

add_parameter useASMIAtom BOOLEAN
set_parameter_property useASMIAtom DEFAULT_VALUE {false}
set_parameter_property useASMIAtom DISPLAY_NAME {use dedicated active serial interface}
set_parameter_property useASMIAtom AFFECTS_GENERATION {1}
set_parameter_property useASMIAtom HDL_PARAMETER {0}


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

add_parameter deviceFamilyString STRING
set_parameter_property deviceFamilyString DISPLAY_NAME {deviceFamilyString}
set_parameter_property deviceFamilyString VISIBLE {0}
set_parameter_property deviceFamilyString AFFECTS_GENERATION {1}
set_parameter_property deviceFamilyString HDL_PARAMETER {0}
set_parameter_property deviceFamilyString SYSTEM_INFO {device_family}
set_parameter_property deviceFamilyString SYSTEM_INFO_TYPE {DEVICE_FAMILY}

add_parameter autoInitializationFileName STRING
set_parameter_property autoInitializationFileName DISPLAY_NAME {autoInitializationFileName}
set_parameter_property autoInitializationFileName VISIBLE {0}
set_parameter_property autoInitializationFileName AFFECTS_GENERATION {1}
set_parameter_property autoInitializationFileName HDL_PARAMETER {0}
set_parameter_property autoInitializationFileName SYSTEM_INFO {unique_id}
set_parameter_property autoInitializationFileName SYSTEM_INFO_TYPE {UNIQUE_ID}


# derived parameters

add_parameter register_offset INTEGER
set_parameter_property register_offset DEFAULT_VALUE {512}
set_parameter_property register_offset DISPLAY_NAME {register_offset}
set_parameter_property register_offset VISIBLE {0}
set_parameter_property register_offset AFFECTS_GENERATION {1}
set_parameter_property register_offset HDL_PARAMETER {0}
set_parameter_property register_offset DERIVED {1}
set_parameter_property register_offset ALLOWED_RANGES {512 1024}

add_parameter iuseASMIAtom BOOLEAN
set_parameter_property iuseASMIAtom DEFAULT_VALUE {true}
set_parameter_property iuseASMIAtom DISPLAY_NAME {iuseASMIAtom}
set_parameter_property iuseASMIAtom VISIBLE {0}
set_parameter_property iuseASMIAtom AFFECTS_GENERATION {1}
set_parameter_property iuseASMIAtom HDL_PARAMETER {0}
set_parameter_property iuseASMIAtom DERIVED {1}


#-------------------------------------------------------------------------------
# module GUI
#-------------------------------------------------------------------------------
proc add_text_message {GROUP MSG} {
    
    global seperator_id
    set seperator_id [ expr { $seperator_id + 1 } ]
    set ID "text_${seperator_id}"
    
    add_display_item $GROUP $ID text $MSG
}

set seperator_id 0



# display group

# group parameter
add_display_item {} {Configuration} GROUP
add_display_item {Configuration} autoSelectASMIAtom PARAMETER
add_display_item {Configuration} useASMIAtom PARAMETER


add_display_item  {} {DESCRIPTION}  GROUP
add_text_message  {DESCRIPTION}  "<html> The EPCS Serial Flash Controller core enables Nios II systems to access an Altera EPCS serial<br>\
configuration device connected to the FPGA. <br><br>\
Altera provides device drivers for the Nios II processor which allows you to read and write the <br>\
EPCS from Nios II software. <br><br>\
You can disable dedicated Active Serial (AS) interface pins and use regular I/O pins instead,<br>\
in devices that support dedicated AS interface. When you choose to user regular I/O pins or <br>\
when you pick a device that does not support dedicated AS interface, the EPCS Serial Flash Controller signals<br>\
are exported to the top level design.  <html>"


#-------------------------------------------------------------------------------
# module validation
#-------------------------------------------------------------------------------

proc validate {} {

	# read user and system info parameter

	set autoSelectASMIAtom [ proc_get_boolean_parameter autoSelectASMIAtom ]
	set clockRate [ get_parameter_value clockRate ]
	set deviceFamilyString [ get_parameter_value deviceFamilyString ]
	set useASMIAtom [ proc_get_boolean_parameter useASMIAtom ]
	
	# validate parameter and update derived parameter
	set register_offset  [ get_parameter_value register_offset ]
	set iuseASMIAtom [ proc_get_boolean_parameter iuseASMIAtom ]
	set autoInitializationFileName [ get_parameter_value autoInitializationFileName ]
 
	if { [string match -nocase "UNKNOWN" $deviceFamilyString ] || [string match -nocase "" $deviceFamilyString ] } {
		send_message error "Device family is unknown."     
   	} 
	
	if { [ string match -nocase "MAX*" $deviceFamilyString ] || [ string match -nocase "Stratix" $deviceFamilyString ] || [ string match -nocase "Stratix GX" $deviceFamilyString ]} {
		send_message error "Selected device family does not support this module. Use a EPCS-capable device."
	} 

	if { [string match -nocase "CYCLONE" $deviceFamilyString ] || [string match -nocase "CYCLONE II" $deviceFamilyString ]} {
		
		set register_offset  512
	} else {
		set register_offset  1024
	}

	if { [string match -nocase "HARDCOPY" $deviceFamilyString ] || [string match -nocase "HARDCOPY II" $deviceFamilyString ] || [ string match -nocase "CYCLONE III" $deviceFamilyString ] || [ string match -nocase "TARPON" $deviceFamilyString ] || [ string match -nocase "STINGRAY" $deviceFamilyString ] || [ string match -nocase "CYCLONE IV E" $deviceFamilyString ] || [ string match -nocase "CYCLONE III LS" $deviceFamilyString ] || [ string match -nocase "CYCLONE IV GX" $deviceFamilyString ]} {
		set iuseASMIAtom 0
		if { $autoSelectASMIAtom } {
			set_parameter_property useASMIAtom ENABLED {false}
			send_message info "Dedicated AS interface is not supported, signals are exported to top level design."
		} else {
			set_parameter_property useASMIAtom ENABLED {true}
			if { $useASMIAtom } {
				send_message error "Dedicated AS interface is not supported, please deselect the dedicated AS interface option."
			}
		}
	} else {
		if { $autoSelectASMIAtom } {
			set_parameter_property useASMIAtom ENABLED {false}
			set iuseASMIAtom 1
		}
		if { !$autoSelectASMIAtom } {
			set_parameter_property useASMIAtom ENABLED {true}
			if { $useASMIAtom } {
				set iuseASMIAtom 1
			} else {
				send_message info "Normal pins are used, signals are exported to top level design."
				set iuseASMIAtom 0
			}
		}
	}

	# GUI parameter enabling and disabling

	# embedded software assignments

	set_module_assignment embeddedsw.CMacro.REGISTER_OFFSET "$register_offset"
	set_module_assignment embeddedsw.memoryInfo.DAT_SYM_INSTALL_DIR {SIM_DIR}
	set_module_assignment embeddedsw.memoryInfo.FLASH_INSTALL_DIR {APP_DIR}
	set_module_assignment embeddedsw.memoryInfo.GENERATE_DAT_SYM {1}
	set_module_assignment embeddedsw.memoryInfo.GENERATE_FLASH {1}
	set_module_assignment embeddedsw.memoryInfo.GENERATE_HEX {1}
	set_module_assignment embeddedsw.memoryInfo.HEX_INSTALL_DIR {SIM_DIR}
	set_module_assignment embeddedsw.memoryInfo.IS_EPCS {1}
	set_module_assignment embeddedsw.memoryInfo.IS_FLASH {1}
	set_module_assignment embeddedsw.memoryInfo.MEM_INIT_DATA_WIDTH {32}
	set_module_assignment embeddedsw.memoryInfo.MEM_INIT_FILENAME "${autoInitializationFileName}_boot_rom"
	set_module_assignment postgeneration.simulation.init_file.param_name {INIT_FILE}
	set_module_assignment postgeneration.simulation.init_file.type {MEM_INIT}


	# save derived parameter
	set_parameter_value register_offset $register_offset
	set_parameter_value iuseASMIAtom $iuseASMIAtom
}

#-------------------------------------------------------------------------------
# module elaboration
#-------------------------------------------------------------------------------

proc elaborate {} {

	# read parameter

	set autoSelectASMIAtom [ proc_get_boolean_parameter autoSelectASMIAtom ]
	set clockRate [ get_parameter_value clockRate ]
	set deviceFamilyString [ get_parameter_value deviceFamilyString ]
	set useASMIAtom [ proc_get_boolean_parameter useASMIAtom ]
	set iuseASMIAtom [ proc_get_boolean_parameter iuseASMIAtom ]
	set autoInitializationFileName [ get_parameter_value autoInitializationFileName ]

	# interfaces

	add_interface clk clock sink
	set_interface_property clk clockRate {0.0}
	set_interface_property clk externallyDriven {0}

	add_interface_port clk clk clk Input 1


	add_interface reset reset sink
	set_interface_property reset associatedClock {clk}
	set_interface_property reset synchronousEdges {DEASSERT}

	add_interface_port reset reset_n reset_n Input 1
	add_interface_port reset reset_req reset_req Input 1


	add_interface epcs_control_port avalon slave
	set_interface_property epcs_control_port addressAlignment {DYNAMIC}
	set_interface_property epcs_control_port addressGroup {0}
	set_interface_property epcs_control_port addressSpan {2048}
	set_interface_property epcs_control_port addressUnits {WORDS}
	set_interface_property epcs_control_port alwaysBurstMaxBurst {0}
	set_interface_property epcs_control_port associatedClock {clk}
	set_interface_property epcs_control_port associatedReset {reset}
	set_interface_property epcs_control_port bitsPerSymbol {8}
	set_interface_property epcs_control_port burstOnBurstBoundariesOnly {0}
	set_interface_property epcs_control_port burstcountUnits {WORDS}
	set_interface_property epcs_control_port constantBurstBehavior {0}
	set_interface_property epcs_control_port explicitAddressSpan {0}
	set_interface_property epcs_control_port holdTime {0}
	set_interface_property epcs_control_port interleaveBursts {0}
	set_interface_property epcs_control_port isBigEndian {0}
	set_interface_property epcs_control_port isFlash {1}
	set_interface_property epcs_control_port isMemoryDevice {1}
	set_interface_property epcs_control_port isNonVolatileStorage {1}
	set_interface_property epcs_control_port linewrapBursts {0}
	set_interface_property epcs_control_port maximumPendingReadTransactions {0}
	set_interface_property epcs_control_port minimumUninterruptedRunLength {1}
	set_interface_property epcs_control_port printableDevice {0}
	set_interface_property epcs_control_port readLatency {0}
	set_interface_property epcs_control_port readWaitStates {1}
	set_interface_property epcs_control_port readWaitTime {1}
	set_interface_property epcs_control_port registerIncomingSignals {0}
	set_interface_property epcs_control_port registerOutgoingSignals {0}
	set_interface_property epcs_control_port setupTime {0}
	set_interface_property epcs_control_port timingUnits {Cycles}
	set_interface_property epcs_control_port transparentBridge {0}
	set_interface_property epcs_control_port wellBehavedWaitrequest {0}
	set_interface_property epcs_control_port writeLatency {0}
	set_interface_property epcs_control_port writeWaitStates {1}
	set_interface_property epcs_control_port writeWaitTime {1}

	add_interface_port epcs_control_port address address Input 9
	add_interface_port epcs_control_port chipselect chipselect Input 1
	add_interface_port epcs_control_port dataavailable dataavailable Output 1
	add_interface_port epcs_control_port endofpacket endofpacket Output 1
	add_interface_port epcs_control_port read_n read_n Input 1
	add_interface_port epcs_control_port readdata readdata Output 32
	add_interface_port epcs_control_port readyfordata readyfordata Output 1
	add_interface_port epcs_control_port write_n write_n Input 1
	add_interface_port epcs_control_port writedata writedata Input 32

	set_interface_assignment epcs_control_port embeddedsw.configuration.isFlash {1}
	set_interface_assignment epcs_control_port embeddedsw.configuration.isMemoryDevice {1}
	set_interface_assignment epcs_control_port embeddedsw.configuration.isNonVolatileStorage {1}

	add_interface irq interrupt sender
	set_interface_property irq associatedAddressablePoint {epcs_control_port}
	set_interface_property irq associatedClock {clk}
	set_interface_property irq associatedReset {reset}
	set_interface_property irq irqScheme {NONE}

	add_interface_port irq irq irq Output 1

	if { !$iuseASMIAtom } {
		add_interface external conduit conduit
	
		add_interface_port external dclk export Output 1
		add_interface_port external sce export Output 1
		add_interface_port external sdo export Output 1
		add_interface_port external data0 export Input 1
	}

}

#-------------------------------------------------------------------------------
# module generation
#-------------------------------------------------------------------------------

# generate
proc generate {output_name output_directory rtl_ext simulation} {
	global env
	set QUARTUS_ROOTDIR         "$env(QUARTUS_ROOTDIR)"
	set component_directory     "$QUARTUS_ROOTDIR/../ip/altera/sopc_builder_ip/altera_avalon_epcs_flash_controller"
	set component_config_file   "$output_directory/${output_name}_component_configuration.pl"

	# read parameter

	set autoSelectASMIAtom [ proc_get_boolean_parameter autoSelectASMIAtom ]
	set clockRate [ get_parameter_value clockRate ]
	set deviceFamilyString [ get_parameter_value deviceFamilyString ]
	set useASMIAtom [ proc_get_boolean_parameter useASMIAtom ]
	set iuseASMIAtom [ proc_get_boolean_parameter iuseASMIAtom ]
	set autoInitializationFileName [ get_parameter_value autoInitializationFileName ]
	set register_offset [ get_parameter_value register_offset ]


	#update derived parameter 
	set derived_device_family [ string2upper_noSpace "$deviceFamilyString" ]
	
	# prepare config file
	set component_config    [open $component_config_file "w"]

	puts $component_config "# ${output_name} Component Configuration File"
	puts $component_config "return {"

	puts $component_config "\tdatabits      	=> \"8\","
	puts $component_config "\ttargetclock   	=> \"20\","
	puts $component_config "\tclockunits   	 	=> \"MHz\","
	puts $component_config "\tclockmult             => \"1000000\","
	puts $component_config "\tnumslaves             => \"1\","
	puts $component_config "\tismaster              => 1,"
	puts $component_config "\tclockpolarity         => \"0\","
	puts $component_config "\tclockphase            => \"0\","
	puts $component_config "\tlsbfirst              => 0,"
	puts $component_config "\textradelay            => \"0\","
	puts $component_config "\ttargetssdelay         => \"100\","
	puts $component_config "\tdelayunits            => \"us\","
	puts $component_config "\tdelaymult             => \"1e-06\","
	puts $component_config "\tprefix                => \"epcs_\","
	puts $component_config "\tregister_offset       => \"$register_offset\","
	puts $component_config "\tignore_legacy_check   => 1,"
	puts $component_config "\tuse_asmi_atom         => $iuseASMIAtom," 
	puts $component_config "\tinputClockRate 	=> $clockRate,"
        puts $component_config "\tdevice_family         => \"$derived_device_family\","



	puts $component_config "};"
	close $component_config

	# generate rtl
	proc_generate_component_rtl  "$component_config_file" "$component_directory" "$output_name" "$output_directory" "$rtl_ext" "$simulation"
	proc_add_generated_files "$output_name" "$output_directory" "$rtl_ext" "$simulation"

}

                

