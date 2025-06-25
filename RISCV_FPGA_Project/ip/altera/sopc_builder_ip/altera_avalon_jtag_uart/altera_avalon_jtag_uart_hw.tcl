package require -exact qsys 12.0
source $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/common/embedded_ip_hwtcl_common.tcl

#-------------------------------------------------------------------------------
# module properties
#-------------------------------------------------------------------------------

set_module_property NAME {altera_avalon_jtag_uart}
set_module_property DISPLAY_NAME {JTAG UART}
set_module_property VERSION {13.1}
set_module_property GROUP {Interface Protocols/Serial}
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

add_documentation_link {Data Sheet } {http://www.altera.com/literature/hb/nios2/n2cpu_nii51009.pdf}

#-------------------------------------------------------------------------------
# module parameters
#-------------------------------------------------------------------------------

# parameters

add_parameter allowMultipleConnections BOOLEAN
set_parameter_property allowMultipleConnections DEFAULT_VALUE {false}
set_parameter_property allowMultipleConnections DISPLAY_NAME {Allow multiple connections to Avalon JTAG slave}
set_parameter_property allowMultipleConnections AFFECTS_GENERATION {1}
set_parameter_property allowMultipleConnections HDL_PARAMETER {0}

add_parameter hubInstanceID INTEGER
set_parameter_property hubInstanceID DEFAULT_VALUE {0}
set_parameter_property hubInstanceID DISPLAY_NAME {hubInstanceID}
set_parameter_property hubInstanceID VISIBLE {0}
set_parameter_property hubInstanceID AFFECTS_GENERATION {1}
set_parameter_property hubInstanceID HDL_PARAMETER {0}

add_parameter readBufferDepth INTEGER
set_parameter_property readBufferDepth DEFAULT_VALUE {64}
set_parameter_property readBufferDepth DISPLAY_NAME {Buffer depth (bytes)}
set_parameter_property readBufferDepth ALLOWED_RANGES {8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768}
set_parameter_property readBufferDepth AFFECTS_GENERATION {1}
set_parameter_property readBufferDepth HDL_PARAMETER {0}

add_parameter readIRQThreshold INTEGER
set_parameter_property readIRQThreshold DEFAULT_VALUE {8}
set_parameter_property readIRQThreshold DISPLAY_NAME {IRQ threshold}
set_parameter_property readIRQThreshold ALLOWED_RANGES {0:255}
set_parameter_property readIRQThreshold AFFECTS_GENERATION {1}
set_parameter_property readIRQThreshold HDL_PARAMETER {0}

add_parameter simInputCharacterStream STRING
set_parameter_property simInputCharacterStream DISPLAY_NAME {Contents}
set_parameter_property simInputCharacterStream VISIBLE {0}
set_parameter_property simInputCharacterStream DISPLAY_HINT {rows:6}
set_parameter_property simInputCharacterStream AFFECTS_GENERATION {1}
set_parameter_property simInputCharacterStream HDL_PARAMETER {0}

add_parameter simInteractiveOptions STRING
set_parameter_property simInteractiveOptions DEFAULT_VALUE {NO_INTERACTIVE_WINDOWS}
set_parameter_property simInteractiveOptions DISPLAY_NAME {Options}
set_parameter_property simInteractiveOptions VISIBLE {0}
set_parameter_property simInteractiveOptions ALLOWED_RANGES {NO_INTERACTIVE_WINDOWS INTERACTIVE_ASCII_OUTPUT INTERACTIVE_INPUT_OUTPUT}
set_parameter_property simInteractiveOptions AFFECTS_GENERATION {1}
set_parameter_property simInteractiveOptions HDL_PARAMETER {0}

add_parameter useRegistersForReadBuffer BOOLEAN
set_parameter_property useRegistersForReadBuffer DEFAULT_VALUE {false}
set_parameter_property useRegistersForReadBuffer DISPLAY_NAME {Construct using registers instead of memory blocks}
set_parameter_property useRegistersForReadBuffer AFFECTS_GENERATION {1}
set_parameter_property useRegistersForReadBuffer HDL_PARAMETER {0}

add_parameter useRegistersForWriteBuffer BOOLEAN
set_parameter_property useRegistersForWriteBuffer DEFAULT_VALUE {false}
set_parameter_property useRegistersForWriteBuffer DISPLAY_NAME {Construct using registers instead of memory blocks}
set_parameter_property useRegistersForWriteBuffer AFFECTS_GENERATION {1}
set_parameter_property useRegistersForWriteBuffer HDL_PARAMETER {0}

add_parameter useRelativePathForSimFile BOOLEAN
set_parameter_property useRelativePathForSimFile DEFAULT_VALUE {false}
set_parameter_property useRelativePathForSimFile DISPLAY_NAME {useRelativePathForSimFile}
set_parameter_property useRelativePathForSimFile VISIBLE {0}
set_parameter_property useRelativePathForSimFile AFFECTS_GENERATION {1}
set_parameter_property useRelativePathForSimFile HDL_PARAMETER {0}

add_parameter writeBufferDepth INTEGER
set_parameter_property writeBufferDepth DEFAULT_VALUE {64}
set_parameter_property writeBufferDepth DISPLAY_NAME {Buffer depth (bytes)}
set_parameter_property writeBufferDepth ALLOWED_RANGES {8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768}
set_parameter_property writeBufferDepth AFFECTS_GENERATION {1}
set_parameter_property writeBufferDepth HDL_PARAMETER {0}

add_parameter writeIRQThreshold INTEGER
set_parameter_property writeIRQThreshold DEFAULT_VALUE {8}
set_parameter_property writeIRQThreshold DISPLAY_NAME {IRQ threshold}
set_parameter_property writeIRQThreshold ALLOWED_RANGES {0:255}
set_parameter_property writeIRQThreshold AFFECTS_GENERATION {1}
set_parameter_property writeIRQThreshold HDL_PARAMETER {0}

# system info parameters

add_parameter avalonSpec STRING
set_parameter_property avalonSpec DISPLAY_NAME {avalonSpec}
set_parameter_property avalonSpec VISIBLE {0}
set_parameter_property avalonSpec AFFECTS_GENERATION {1}
set_parameter_property avalonSpec HDL_PARAMETER {0}
set_parameter_property avalonSpec SYSTEM_INFO {avalon_spec}
set_parameter_property avalonSpec SYSTEM_INFO_TYPE {AVALON_SPEC}

# derived parameters

add_parameter legacySignalAllow BOOLEAN
set_parameter_property legacySignalAllow DEFAULT_VALUE {true}
set_parameter_property legacySignalAllow DISPLAY_NAME {legacySignalAllow}
set_parameter_property legacySignalAllow VISIBLE {0}
set_parameter_property legacySignalAllow DERIVED {1}
set_parameter_property legacySignalAllow AFFECTS_GENERATION {1}
set_parameter_property legacySignalAllow HDL_PARAMETER {0}

add_parameter enableInteractiveInput BOOLEAN
set_parameter_property enableInteractiveInput DEFAULT_VALUE {false}
set_parameter_property enableInteractiveInput DISPLAY_NAME {enableInteractiveInput}
set_parameter_property enableInteractiveInput VISIBLE {0}
set_parameter_property enableInteractiveInput DERIVED {1}
set_parameter_property enableInteractiveInput AFFECTS_GENERATION {1}
set_parameter_property enableInteractiveInput HDL_PARAMETER {0}

add_parameter enableInteractiveOutput BOOLEAN
set_parameter_property enableInteractiveOutput DEFAULT_VALUE {false}
set_parameter_property enableInteractiveOutput DISPLAY_NAME {enableInteractiveOutput}
set_parameter_property enableInteractiveOutput VISIBLE {0}
set_parameter_property enableInteractiveOutput DERIVED {1}
set_parameter_property enableInteractiveOutput AFFECTS_GENERATION {1}
set_parameter_property enableInteractiveOutput HDL_PARAMETER {0}

#-------------------------------------------------------------------------------
# module GUI
#-------------------------------------------------------------------------------

# display group
add_display_item {} {Write FIFO (Data from Avalon to JTAG)} GROUP
add_display_item {} {Read FIFO (Data from JTAG to Avalon)} GROUP
add_display_item {} {Allow multiple connections} GROUP

# group parameter
add_display_item {Write FIFO (Data from Avalon to JTAG)} writeBufferDepth PARAMETER
add_display_item {Write FIFO (Data from Avalon to JTAG)} writeIRQThreshold PARAMETER
add_display_item {Write FIFO (Data from Avalon to JTAG)} useRegistersForWriteBuffer PARAMETER

add_display_item {Read FIFO (Data from JTAG to Avalon)} readBufferDepth PARAMETER
add_display_item {Read FIFO (Data from JTAG to Avalon)} readIRQThreshold PARAMETER
add_display_item {Read FIFO (Data from JTAG to Avalon)} useRegistersForReadBuffer PARAMETER

add_display_item {Allow multiple connections} allowMultipleConnections PARAMETER

#-------------------------------------------------------------------------------
# module validation
#-------------------------------------------------------------------------------

proc validate {} {

	# read user and system info parameter

	set allowMultipleConnections [ proc_get_boolean_parameter allowMultipleConnections ]
	set avalonSpec [ get_parameter_value avalonSpec ]
	set hubInstanceID [ get_parameter_value hubInstanceID ]
	set readBufferDepth [ get_parameter_value readBufferDepth ]
	set readIRQThreshold [ get_parameter_value readIRQThreshold ]
	set simInputCharacterStream [ get_parameter_value simInputCharacterStream ]
	set simInteractiveOptions [ get_parameter_value simInteractiveOptions ]
	set useRegistersForReadBuffer [ proc_get_boolean_parameter useRegistersForReadBuffer ]
	set useRegistersForWriteBuffer [ proc_get_boolean_parameter useRegistersForWriteBuffer ]
	set useRelativePathForSimFile [ proc_get_boolean_parameter useRelativePathForSimFile ]
	set writeBufferDepth [ get_parameter_value writeBufferDepth ]
	set writeIRQThreshold [ get_parameter_value writeIRQThreshold ]

	# validate parameter and update derived parameter
	set legacySignalAllow [ proc_get_boolean_parameter legacySignalAllow ]
	set enableInteractiveInput [ proc_get_boolean_parameter enableInteractiveInput ]
	set enableInteractiveOutput [ proc_get_boolean_parameter enableInteractiveOutput ]
	
	# GUI parameter enabling and disabling
	if { $simInteractiveOptions == "NO_INTERACTIVE_WINDOWS" } {
	  set_parameter_property simInputCharacterStream ENABLED {false} 
	} else {
	  set_parameter_property simInputCharacterStream ENABLED {true}	
	}
	
	# Validate IRQ thresholds
	if { $readIRQThreshold >= $readBufferDepth } {
	  send_message warning "Read IRQ effectively disabled when threshold >= depth"
	}
	if { $writeIRQThreshold >= $writeBufferDepth } {
	  send_message warning "Write IRQ effectively disabled when threshold >= depth"
	}
	
	# Validate read buffer register usage
	if { ($readBufferDepth > 64) && $useRegistersForReadBuffer } {
	  send_message error "Read FIFO must use memory blocks for depths of >64 bytes"
	}
	
	# Validate write buffer register usage
	if { $writeBufferDepth > 64 && $useRegistersForWriteBuffer } {
	  send_message error "Write FIFO must use memory blocks for depths of >64 bytes"
	}
	
	# set simInteractiveOptions Enum 
	switch $simInteractiveOptions {
          NO_INTERACTIVE_WINDOWS {
            set enableInteractiveInput 0
            set enableInteractiveOutput 0
          }
          
          INTERACTIVE_ASCII_OUTPUT {
            set enableInteractiveInput 0
            set enableInteractiveOutput 1
          } 
          
          INTERACTIVE_INPUT_OUTPUT {
            set enableInteractiveInput 1
            set enableInteractiveOutput 0
          } 
        }
        
	# embedded software assignments

	set_module_assignment embeddedsw.CMacro.WRITE_DEPTH $writeBufferDepth
	set_module_assignment embeddedsw.CMacro.READ_DEPTH $readBufferDepth
	set_module_assignment embeddedsw.CMacro.WRITE_THRESHOLD $writeIRQThreshold
	set_module_assignment embeddedsw.CMacro.READ_THRESHOLD $readIRQThreshold
	
	# Device tree parameters
	set_module_assignment embeddedsw.dts.vendor "altr"
	set_module_assignment embeddedsw.dts.group "serial"
	set_module_assignment embeddedsw.dts.name "juart"
	set_module_assignment embeddedsw.dts.compatible "altr,juart-1.0"

	# update derived parameter

	set_parameter_value legacySignalAllow 0
	set_parameter_value enableInteractiveInput $enableInteractiveInput
	set_parameter_value enableInteractiveOutput $enableInteractiveOutput

}

#-------------------------------------------------------------------------------
# module elaboration
#-------------------------------------------------------------------------------

proc elaborate {} {

	# read parameter

	set allowMultipleConnections [ proc_get_boolean_parameter allowMultipleConnections ]
	set avalonSpec [ get_parameter_value avalonSpec ]
	set hubInstanceID [ get_parameter_value hubInstanceID ]
	set legacySignalAllow [ proc_get_boolean_parameter legacySignalAllow ]
	set readBufferDepth [ get_parameter_value readBufferDepth ]
	set readIRQThreshold [ get_parameter_value readIRQThreshold ]
	set simInputCharacterStream [ get_parameter_value simInputCharacterStream ]
	set simInteractiveOptions [ get_parameter_value simInteractiveOptions ]
	set useRegistersForReadBuffer [ proc_get_boolean_parameter useRegistersForReadBuffer ]
	set useRegistersForWriteBuffer [ proc_get_boolean_parameter useRegistersForWriteBuffer ]
	set useRelativePathForSimFile [ proc_get_boolean_parameter useRelativePathForSimFile ]
	set writeBufferDepth [ get_parameter_value writeBufferDepth ]
	set writeIRQThreshold [ get_parameter_value writeIRQThreshold ]

	# interfaces

	add_interface clk clock sink
	set_interface_property clk clockRate {0.0}
	set_interface_property clk externallyDriven {0}
	
	add_interface_port clk clk clk Input 1

	add_interface reset reset sink
	set_interface_property reset associatedClock {clk}
	set_interface_property reset synchronousEdges {DEASSERT}
	
	add_interface_port reset rst_n reset_n Input 1

	add_interface avalon_jtag_slave avalon slave
	set_interface_property avalon_jtag_slave addressAlignment {NATIVE}
	set_interface_property avalon_jtag_slave addressGroup {0}
	set_interface_property avalon_jtag_slave addressSpan {2}
	set_interface_property avalon_jtag_slave addressUnits {WORDS}
	set_interface_property avalon_jtag_slave alwaysBurstMaxBurst {0}
	set_interface_property avalon_jtag_slave associatedClock {clk}
	set_interface_property avalon_jtag_slave associatedReset {reset}
	set_interface_property avalon_jtag_slave bitsPerSymbol {8}
	set_interface_property avalon_jtag_slave burstOnBurstBoundariesOnly {0}
	set_interface_property avalon_jtag_slave burstcountUnits {WORDS}
	set_interface_property avalon_jtag_slave constantBurstBehavior {0}
	set_interface_property avalon_jtag_slave explicitAddressSpan {0}
	set_interface_property avalon_jtag_slave holdTime {0}
	set_interface_property avalon_jtag_slave interleaveBursts {0}
	set_interface_property avalon_jtag_slave isBigEndian {0}
	set_interface_property avalon_jtag_slave isFlash {0}
	set_interface_property avalon_jtag_slave isMemoryDevice {0}
	set_interface_property avalon_jtag_slave isNonVolatileStorage {0}
	set_interface_property avalon_jtag_slave linewrapBursts {0}
	set_interface_property avalon_jtag_slave maximumPendingReadTransactions {0}
	set_interface_property avalon_jtag_slave minimumUninterruptedRunLength {1}
	set_interface_property avalon_jtag_slave printableDevice {1}
	set_interface_property avalon_jtag_slave readLatency {0}
	set_interface_property avalon_jtag_slave readWaitStates {1}
	set_interface_property avalon_jtag_slave readWaitTime {1}
	set_interface_property avalon_jtag_slave registerIncomingSignals {0}
	set_interface_property avalon_jtag_slave registerOutgoingSignals {0}
	set_interface_property avalon_jtag_slave setupTime {0}
	set_interface_property avalon_jtag_slave timingUnits {Cycles}
	set_interface_property avalon_jtag_slave transparentBridge {0}
	set_interface_property avalon_jtag_slave wellBehavedWaitrequest {0}
	set_interface_property avalon_jtag_slave writeLatency {0}
	set_interface_property avalon_jtag_slave writeWaitStates {0}
	set_interface_property avalon_jtag_slave writeWaitTime {0}

        set svd_path [file join $::env(QUARTUS_ROOTDIR) .. ip altera sopc_builder_ip altera_avalon_jtag_uart altera_avalon_jtag_uart.svd]
        set_interface_property avalon_jtag_slave CMSIS_SVD_FILE $svd_path

	add_interface_port avalon_jtag_slave av_chipselect chipselect Input 1
	add_interface_port avalon_jtag_slave av_address address Input 1
	add_interface_port avalon_jtag_slave av_read_n read_n Input 1
	add_interface_port avalon_jtag_slave av_readdata readdata Output 32
	add_interface_port avalon_jtag_slave av_write_n write_n Input 1
	add_interface_port avalon_jtag_slave av_writedata writedata Input 32
	add_interface_port avalon_jtag_slave av_waitrequest waitrequest Output 1

	set_interface_assignment avalon_jtag_slave embeddedsw.configuration.isPrintableDevice {1}


	add_interface irq interrupt sender
	set_interface_property irq associatedAddressablePoint {avalon_jtag_slave}
	set_interface_property irq associatedClock {clk}
	set_interface_property irq associatedReset {reset}
	set_interface_property irq irqScheme {NONE}
	
	add_interface_port irq av_irq irq Output 1

}

#-------------------------------------------------------------------------------
# module generation
#-------------------------------------------------------------------------------
# generate
proc generate {output_name output_directory rtl_ext simgen} {
	global env
	set QUARTUS_ROOTDIR         "$env(QUARTUS_ROOTDIR)"
	set component_directory     "$QUARTUS_ROOTDIR/../ip/altera/sopc_builder_ip/altera_avalon_jtag_uart"
	set component_config_file   "$output_directory/${output_name}_component_configuration.pl"

	# read parameter

	set allowMultipleConnections [ proc_get_boolean_parameter allowMultipleConnections ]
	set avalonSpec [ get_parameter_value avalonSpec ]
	set hubInstanceID [ get_parameter_value hubInstanceID ]
	set readBufferDepth [ get_parameter_value readBufferDepth ]
	set readIRQThreshold [ get_parameter_value readIRQThreshold ]
	set simInputCharacterStream [ get_parameter_value simInputCharacterStream ]
	set simInteractiveOptions [ get_parameter_value simInteractiveOptions ]
	set useRegistersForReadBuffer [ proc_get_boolean_parameter useRegistersForReadBuffer ]
	set useRegistersForWriteBuffer [ proc_get_boolean_parameter useRegistersForWriteBuffer ]
	set useRelativePathForSimFile [ proc_get_boolean_parameter useRelativePathForSimFile ]
	set writeBufferDepth [ get_parameter_value writeBufferDepth ]
	set writeIRQThreshold [ get_parameter_value writeIRQThreshold ]

	set legacySignalAllow [ proc_get_boolean_parameter legacySignalAllow ]
	set enableInteractiveInput [ proc_get_boolean_parameter enableInteractiveInput ]
	set enableInteractiveOutput [ proc_get_boolean_parameter enableInteractiveOutput ]
	
	# prepare config file
	set component_config    [open $component_config_file "w"]

	puts $component_config "# ${output_name} Component Configuration File"
	puts $component_config "return {"

	puts $component_config "\tallow_legacy_signals		=> $legacySignalAllow,"
        puts $component_config "\twrite_depth			=> $writeBufferDepth,"
        puts $component_config "\tread_depth			=> $readBufferDepth,"
        puts $component_config "\twrite_threshold		=> $writeIRQThreshold,"
        puts $component_config "\tread_threshold		=> $readIRQThreshold,"
        puts $component_config "\tread_char_stream		=> \"\"," 
        puts $component_config "\tshowascii			=> 1,"
        puts $component_config "\trelativepath			=> 1,"
        puts $component_config "\tread_le			=> $useRegistersForReadBuffer,"
        puts $component_config "\twrite_le			=> $useRegistersForWriteBuffer,"
        #puts $component_config "\taltera_show_unreleased_jtag_uart_features	=> $allowMultipleConnections,"
        

	puts $component_config "};"
	close $component_config

	# generate rtl
	proc_generate_component_rtl  "$component_config_file" "$component_directory" "$output_name" "$output_directory" "$rtl_ext" "$simgen"
	proc_add_generated_files "$output_name" "$output_directory" "$rtl_ext" "$simgen"
}
