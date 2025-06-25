package require -exact qsys 12.0
source $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/common/embedded_ip_hwtcl_common.tcl

#-------------------------------------------------------------------------------
# module properties
#-------------------------------------------------------------------------------

set_module_property NAME {altera_avalon_uart}
set_module_property DISPLAY_NAME {UART (RS-232 Serial Port)}
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

add_documentation_link {Data Sheet} {http://www.altera.com/literature/hb/nios2/n2cpu_nii51010.pdf}

#-------------------------------------------------------------------------------
# module parameters
#-------------------------------------------------------------------------------

# parameters

add_parameter baud INTEGER
set_parameter_property baud DEFAULT_VALUE {115200}
set_parameter_property baud DISPLAY_NAME {Baud rate (bps)}
set_parameter_property baud ALLOWED_RANGES {115200 57600 38400 31250 28800 19200 14400 9600 4800 2400 1200 300}
set_parameter_property baud AFFECTS_GENERATION {1}
set_parameter_property baud HDL_PARAMETER {0}

add_parameter dataBits INTEGER
set_parameter_property dataBits DEFAULT_VALUE {8}
set_parameter_property dataBits DISPLAY_NAME {Data bits}
set_parameter_property dataBits ALLOWED_RANGES {7 8 9}
set_parameter_property dataBits AFFECTS_GENERATION {1}
set_parameter_property dataBits HDL_PARAMETER {0}

add_parameter fixedBaud BOOLEAN
set_parameter_property fixedBaud DEFAULT_VALUE {true}
set_parameter_property fixedBaud DISPLAY_NAME {Fixed baud rate}
set_parameter_property fixedBaud DESCRIPTION {Baud rate cannot be changed by software (Divisor register is not writable)}
set_parameter_property fixedBaud AFFECTS_GENERATION {1}
set_parameter_property fixedBaud HDL_PARAMETER {0}

add_parameter parity STRING
set_parameter_property parity DEFAULT_VALUE {NONE}
set_parameter_property parity DISPLAY_NAME {Parity}
set_parameter_property parity ALLOWED_RANGES {NONE EVEN ODD}
set_parameter_property parity AFFECTS_GENERATION {1}
set_parameter_property parity HDL_PARAMETER {0}

add_parameter simCharStream STRING
set_parameter_property simCharStream DISPLAY_NAME {Contents}
set_parameter_property simCharStream VISIBLE {0}
set_parameter_property simCharStream DISPLAY_HINT {rows:6}
set_parameter_property simCharStream AFFECTS_GENERATION {1}
set_parameter_property simCharStream HDL_PARAMETER {0}

add_parameter simInteractiveInputEnable BOOLEAN
set_parameter_property simInteractiveInputEnable DEFAULT_VALUE {false}
set_parameter_property simInteractiveInputEnable DISPLAY_NAME {Interactive stimulus window}
set_parameter_property simInteractiveInputEnable VISIBLE {0}
set_parameter_property simInteractiveInputEnable DESCRIPTION {Create ModelSim alias to open an interactive stimulus window}
set_parameter_property simInteractiveInputEnable AFFECTS_GENERATION {1}
set_parameter_property simInteractiveInputEnable HDL_PARAMETER {0}

add_parameter simInteractiveOutputEnable BOOLEAN
set_parameter_property simInteractiveOutputEnable DEFAULT_VALUE {false}
set_parameter_property simInteractiveOutputEnable DISPLAY_NAME {Streaming output window}
set_parameter_property simInteractiveOutputEnable VISIBLE {0}
set_parameter_property simInteractiveOutputEnable DESCRIPTION {Create ModelSim alias to open streaming output window}
set_parameter_property simInteractiveOutputEnable AFFECTS_GENERATION {1}
set_parameter_property simInteractiveOutputEnable HDL_PARAMETER {0}

add_parameter simTrueBaud BOOLEAN
set_parameter_property simTrueBaud DEFAULT_VALUE {false}
set_parameter_property simTrueBaud DISPLAY_NAME {Option}
set_parameter_property simTrueBaud VISIBLE {0}
set_parameter_property simTrueBaud ALLOWED_RANGES {{false:Accelerated (Use divisor = 2)} {true:Actual (Use true baud divisor)}}
set_parameter_property simTrueBaud AFFECTS_GENERATION {1}
set_parameter_property simTrueBaud HDL_PARAMETER {0}

add_parameter stopBits INTEGER
set_parameter_property stopBits DEFAULT_VALUE {1}
set_parameter_property stopBits DISPLAY_NAME {Stop bits}
set_parameter_property stopBits ALLOWED_RANGES {1 2}
set_parameter_property stopBits AFFECTS_GENERATION {1}
set_parameter_property stopBits HDL_PARAMETER {0}

add_parameter syncRegDepth INTEGER
set_parameter_property syncRegDepth DEFAULT_VALUE {2}
set_parameter_property syncRegDepth DISPLAY_NAME {Synchronizer stages}
set_parameter_property syncRegDepth ALLOWED_RANGES {2 3 4 5}
set_parameter_property syncRegDepth AFFECTS_GENERATION {1}
set_parameter_property syncRegDepth HDL_PARAMETER {0}

add_parameter useCtsRts BOOLEAN
set_parameter_property useCtsRts DEFAULT_VALUE {false}
set_parameter_property useCtsRts DISPLAY_NAME {Include CTS/RTS}
set_parameter_property useCtsRts DESCRIPTION {Include CTS/RTS pins and control register bits}
set_parameter_property useCtsRts AFFECTS_GENERATION {1}
set_parameter_property useCtsRts HDL_PARAMETER {0}

add_parameter useEopRegister BOOLEAN
set_parameter_property useEopRegister DEFAULT_VALUE {false}
set_parameter_property useEopRegister DISPLAY_NAME {Include end-of-packet}
set_parameter_property useEopRegister DESCRIPTION {Include end-of-packet register}
set_parameter_property useEopRegister AFFECTS_GENERATION {1}
set_parameter_property useEopRegister HDL_PARAMETER {0}

add_parameter useRelativePathForSimFile BOOLEAN
set_parameter_property useRelativePathForSimFile DEFAULT_VALUE {false}
set_parameter_property useRelativePathForSimFile DISPLAY_NAME {useRelativePathForSimFile}
set_parameter_property useRelativePathForSimFile VISIBLE {0}
set_parameter_property useRelativePathForSimFile AFFECTS_GENERATION {1}
set_parameter_property useRelativePathForSimFile HDL_PARAMETER {0}

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

# derived parameters

add_parameter baudError FLOAT
set_parameter_property baudError DEFAULT_VALUE {0.0}
set_parameter_property baudError DISPLAY_NAME {Baud error}
set_parameter_property baudError DERIVED {1}
set_parameter_property baudError AFFECTS_GENERATION {1}
set_parameter_property baudError HDL_PARAMETER {0}

add_parameter parityFisrtChar STRING
set_parameter_property parityFisrtChar DEFAULT_VALUE {N}
set_parameter_property parityFisrtChar DISPLAY_NAME {parityFisrtChar}
set_parameter_property parityFisrtChar VISIBLE {0}
set_parameter_property parityFisrtChar DERIVED {1}
set_parameter_property parityFisrtChar AFFECTS_GENERATION {1}
set_parameter_property parityFisrtChar HDL_PARAMETER {0}

#-------------------------------------------------------------------------------
# module GUI
#-------------------------------------------------------------------------------

# display group
add_display_item {} {Basic settings} GROUP
add_display_item {} {Baud rate} GROUP

# group parameter
add_display_item {Basic settings} parity PARAMETER
add_display_item {Basic settings} dataBits PARAMETER
add_display_item {Basic settings} stopBits PARAMETER
add_display_item {Basic settings} syncRegDepth PARAMETER
add_display_item {Basic settings} useCtsRts PARAMETER
add_display_item {Basic settings} useEopRegister PARAMETER

add_display_item {Baud rate} baud PARAMETER
add_display_item {Baud rate} baudError PARAMETER
add_display_item {Baud rate} fixedBaud PARAMETER

#-------------------------------------------------------------------------------
# module validation
#-------------------------------------------------------------------------------
proc calculateMinBaud { systemClock } {
  if { !$systemClock } {
    return 0
  }
  
  return [ expr int(ceil(double($systemClock)/double(65535)))]
}

proc calculateDivisorBits { divisor } {
  if {$divisor == 1} {
    return 1	
  } else {
    return [ expr ceil(log($divisor)/log(2.0))]
  }
}

proc calculateDivisor { systemClock myBaud } {
  if { !$systemClock } {
    return 1
  }
  
  set divisor [ expr round( double($systemClock)/double($myBaud) )]
  return $divisor
}

proc calculateActualBaud { systemClock myBaud } {
  return [ expr double($systemClock)/double([calculateDivisor $systemClock $myBaud])]
}

proc calculateBaudError { systemClock myBaud } {
  if { !$systemClock } {
    return 0 
  }	

  set actualBaud [ expr [calculateActualBaud $systemClock $myBaud] ]
  set baudDiff [ expr abs($actualBaud - $myBaud) ]
  set calculatedError [ expr ( 100.0*$baudDiff )/ $myBaud ]
  
  return $calculatedError
}

proc roundBaudError { calculatedError } {
  if { $calculatedError < 0.01 } {
    return 0.01
  }
  return [ expr double( round(($calculatedError*100.0)/100.0) ) ]
}

proc validate {} {

	# read user and system info parameter

	set baud [ get_parameter_value baud ]
	set clockRate [ get_parameter_value clockRate ]
	set dataBits [ get_parameter_value dataBits ]
	set fixedBaud [ proc_get_boolean_parameter fixedBaud ]
	set parity [ get_parameter_value parity ]
	set simCharStream [ get_parameter_value simCharStream ]
	set simInteractiveInputEnable [ proc_get_boolean_parameter simInteractiveInputEnable ]
	set simInteractiveOutputEnable [ proc_get_boolean_parameter simInteractiveOutputEnable ]
	set simTrueBaud [ proc_get_boolean_parameter simTrueBaud ]
	set stopBits [ get_parameter_value stopBits ]
	set syncRegDepth [ get_parameter_value syncRegDepth ]
	set useCtsRts [ proc_get_boolean_parameter useCtsRts ]
	set useEopRegister [ proc_get_boolean_parameter useEopRegister ]
	set useRelativePathForSimFile [ proc_get_boolean_parameter useRelativePathForSimFile ]
	
	# validate parameter and update derived parameter
	set baudError [ get_parameter_value baudError ]
	set parityFisrtChar [ get_parameter_value parityFisrtChar ]
	
	# GUI parameter enabling and disabling
    if { $clockRate > 0 } {
        # Validate baud error too large warning
        if { [calculateBaudError $clockRate $baud] >= 3.0 } {
          send_message warning "Baud error too large, UART may not function"	
        }
    	
        #Validate baud rate too low error
        set divisor [ calculateDivisor $clockRate $baud ]
        set minBaud [ calculateMinBaud $clockRate ]           	    
          if { [calculateDivisorBits $divisor] > 16 } {   
          send_message error "Baud rate too low, must be at least $minBaud bps"
        }
                                      
    } else {
      send_message warning "No Baud rate validation because the clock rate is unknown"		
    }
	
    # update Baud error display
    set baudError [ roundBaudError [calculateBaudError $clockRate $baud] ]
    
	# embedded software assignments
	set parityFisrtChar [ string index $parity "0" ]
	
	set_module_assignment embeddedsw.CMacro.BAUD $baud
	set_module_assignment embeddedsw.CMacro.DATA_BITS $dataBits
	set_module_assignment embeddedsw.CMacro.FIXED_BAUD $fixedBaud
	set_module_assignment embeddedsw.CMacro.PARITY "'$parityFisrtChar'"
	set_module_assignment embeddedsw.CMacro.STOP_BITS $stopBits
	set_module_assignment embeddedsw.CMacro.SYNC_REG_DEPTH $syncRegDepth
	set_module_assignment embeddedsw.CMacro.USE_CTS_RTS $useCtsRts
	set_module_assignment embeddedsw.CMacro.USE_EOP_REGISTER $useEopRegister
	set_module_assignment embeddedsw.CMacro.SIM_TRUE_BAUD $simTrueBaud
	set_module_assignment embeddedsw.CMacro.SIM_CHAR_STREAM "\"$simCharStream\""
	set_module_assignment embeddedsw.CMacro.FREQ $clockRate
	
	# Device tree parameters
	set_module_assignment embeddedsw.dts.vendor "altr"
	set_module_assignment embeddedsw.dts.group "serial"
	set_module_assignment embeddedsw.dts.name "uart"
	set_module_assignment embeddedsw.dts.compatible "altr,uart-1.0"
	set_module_assignment {embeddedsw.dts.params.current-speed} $baud
	set_module_assignment {embeddedsw.dts.params.clock-frequency} $clockRate
	 
	# update derived parameter

	set_parameter_value baudError $baudError
	set_parameter_value parityFisrtChar $parityFisrtChar
}

#-------------------------------------------------------------------------------
# module elaboration
#-------------------------------------------------------------------------------

proc elaborate {} {

	# read parameter

	set baud [ get_parameter_value baud ]
	set baudError [ get_parameter_value baudError ]
	set clockRate [ get_parameter_value clockRate ]
	set dataBits [ get_parameter_value dataBits ]
	set fixedBaud [ proc_get_boolean_parameter fixedBaud ]
	set parity [ get_parameter_value parity ]
	set simCharStream [ get_parameter_value simCharStream ]
	set simInteractiveInputEnable [ proc_get_boolean_parameter simInteractiveInputEnable ]
	set simInteractiveOutputEnable [ proc_get_boolean_parameter simInteractiveOutputEnable ]
	set simTrueBaud [ proc_get_boolean_parameter simTrueBaud ]
	set stopBits [ get_parameter_value stopBits ]
	set syncRegDepth [ get_parameter_value syncRegDepth ]
	set useCtsRts [ proc_get_boolean_parameter useCtsRts ]
	set useEopRegister [ proc_get_boolean_parameter useEopRegister ]
	set useRelativePathForSimFile [ proc_get_boolean_parameter useRelativePathForSimFile ]

	# interfaces

	add_interface clk clock sink
	set_interface_property clk clockRate {0.0}
	set_interface_property clk externallyDriven {0}
	add_interface_port clk clk clk Input 1

	add_interface reset reset sink
	set_interface_property reset associatedClock {clk}
	set_interface_property reset synchronousEdges {DEASSERT}
	add_interface_port reset reset_n reset_n Input 1

	add_interface s1 avalon slave
	set_interface_property s1 addressAlignment {NATIVE}
	set_interface_property s1 addressGroup {0}
	set_interface_property s1 addressSpan {8}
	set_interface_property s1 addressUnits {WORDS}
	set_interface_property s1 alwaysBurstMaxBurst {0}
	set_interface_property s1 associatedClock {clk}
	set_interface_property s1 associatedReset {reset}
	set_interface_property s1 bitsPerSymbol {8}
	set_interface_property s1 burstOnBurstBoundariesOnly {0}
	set_interface_property s1 burstcountUnits {WORDS}
	set_interface_property s1 constantBurstBehavior {0}
	set_interface_property s1 explicitAddressSpan {0}
	set_interface_property s1 holdTime {0}
	set_interface_property s1 interleaveBursts {0}
	set_interface_property s1 isBigEndian {0}
	set_interface_property s1 isFlash {0}
	set_interface_property s1 isMemoryDevice {0}
	set_interface_property s1 isNonVolatileStorage {0}
	set_interface_property s1 linewrapBursts {0}
	set_interface_property s1 maximumPendingReadTransactions {0}
	set_interface_property s1 minimumUninterruptedRunLength {1}
	set_interface_property s1 printableDevice {1}
	set_interface_property s1 readLatency {0}
	set_interface_property s1 readWaitStates {1}
	set_interface_property s1 readWaitTime {1}
	set_interface_property s1 registerIncomingSignals {0}
	set_interface_property s1 registerOutgoingSignals {0}
	set_interface_property s1 setupTime {0}
	set_interface_property s1 timingUnits {Cycles}
	set_interface_property s1 transparentBridge {0}
	set_interface_property s1 wellBehavedWaitrequest {0}
	set_interface_property s1 writeLatency {0}
	set_interface_property s1 writeWaitStates {1}
	set_interface_property s1 writeWaitTime {1}
	
	add_interface_port s1 address address Input 3
	add_interface_port s1 begintransfer begintransfer Input 1
	add_interface_port s1 chipselect chipselect Input 1
	add_interface_port s1 read_n read_n Input 1
	add_interface_port s1 write_n write_n Input 1
	add_interface_port s1 writedata writedata Input 16
	add_interface_port s1 readdata readdata Output 16
	add_interface_port s1 dataavailable dataavailable Output 1 
	add_interface_port s1 readyfordata readyfordata Output 1
	if { $useEopRegister } { 
	  add_interface_port s1 endofpacket endofpacket Output 1
	} 
	set_interface_assignment s1 embeddedsw.configuration.isPrintableDevice {1}

	add_interface external_connection conduit conduit
	add_interface_port external_connection rxd export Input 1
	add_interface_port external_connection txd export Output 1
	if { $useCtsRts } {
	  add_interface_port external_connection cts_n export Input 1
	  add_interface_port external_connection rts_n export Output 1
	}

	add_interface irq interrupt sender
	set_interface_property irq associatedAddressablePoint {s1}
	set_interface_property irq associatedClock {clk}
	set_interface_property irq associatedReset {reset}
	set_interface_property irq irqScheme {NONE}

	add_interface_port irq irq irq Output 1


}

#-------------------------------------------------------------------------------
# module generation
#-------------------------------------------------------------------------------
# generate
proc generate {output_name output_directory rtl_ext simgen} {
	global env
	set QUARTUS_ROOTDIR         "$env(QUARTUS_ROOTDIR)"
	set component_directory     "$QUARTUS_ROOTDIR/../ip/altera/sopc_builder_ip/altera_avalon_uart"
	set component_config_file   "$output_directory/${output_name}_component_configuration.pl"

	# read parameter

	set baud [ get_parameter_value baud ]
	set baudError [ get_parameter_value baudError ]
	set clockRate [ get_parameter_value clockRate ]
	set dataBits [ get_parameter_value dataBits ]
	set fixedBaud [ proc_get_boolean_parameter fixedBaud ]
	set parity [ get_parameter_value parity ]
	set simCharStream [ get_parameter_value simCharStream ]
	set simInteractiveInputEnable [ proc_get_boolean_parameter simInteractiveInputEnable ]
	set simInteractiveOutputEnable [ proc_get_boolean_parameter simInteractiveOutputEnable ]
	set simTrueBaud [ proc_get_boolean_parameter simTrueBaud ]
	set stopBits [ get_parameter_value stopBits ]
	set syncRegDepth [ get_parameter_value syncRegDepth ]
	set useCtsRts [ proc_get_boolean_parameter useCtsRts ]
	set useEopRegister [ proc_get_boolean_parameter useEopRegister ]
	set useRelativePathForSimFile [ proc_get_boolean_parameter useRelativePathForSimFile ]

	set parityFisrtChar [ get_parameter_value parityFisrtChar ]
	
	# prepare config file
	set component_config    [open $component_config_file "w"]

	puts $component_config "# ${output_name} Component Configuration File"
	puts $component_config "return {"

	puts $component_config "\tbaud			=> $baud,"
	puts $component_config "\tdata_bits		=> $dataBits,"
	puts $component_config "\tfixed_baud		=> $fixedBaud,"
	puts $component_config "\tparity		=> \"$parityFisrtChar\","
	puts $component_config "\tstop_bits		=> $stopBits,"
	puts $component_config "\tsync_reg_depth	=> $syncRegDepth,"
	puts $component_config "\tuse_cts_rts		=> $useCtsRts,"
	puts $component_config "\tuse_eop_register	=> $useEopRegister,"
	puts $component_config "\tsim_true_baud		=> $simTrueBaud,"
	puts $component_config "\tsim_char_stream	=> \"$simCharStream\","
	puts $component_config "\trelativepath		=> 1,"
	puts $component_config "\tsystem_clk_freq	=> $clockRate,"

	puts $component_config "};"
	close $component_config

	# generate rtl
	proc_generate_component_rtl  "$component_config_file" "$component_directory" "$output_name" "$output_directory" "$rtl_ext" "$simgen"
	proc_add_generated_files "$output_name" "$output_directory" "$rtl_ext" "$simgen"
}

