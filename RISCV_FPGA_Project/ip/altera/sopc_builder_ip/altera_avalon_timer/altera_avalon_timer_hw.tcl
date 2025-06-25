package require -exact qsys 13.1
source $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/common/embedded_ip_hwtcl_common.tcl

#-------------------------------------------------------------------------------
# module properties
#-------------------------------------------------------------------------------

set_module_property NAME {altera_avalon_timer}
set_module_property DISPLAY_NAME {Interval Timer}
set_module_property VERSION {13.1}
set_module_property GROUP {Peripherals/Microcontroller Peripherals}
set_module_property AUTHOR {Altera Corporation}
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property INTERNAL false
set_module_property HIDE_FROM_SOPC true
set_module_property EDITABLE true
set_module_property VALIDATION_CALLBACK validate
set_module_property ELABORATION_CALLBACK elaborate

# generation fileset

add_fileset quartus_synth QUARTUS_SYNTH sub_quartus_synth_timer
add_fileset sim_verilog SIM_VERILOG sub_sim_verilog_timer
add_fileset sim_vhdl SIM_VHDL sub_sim_vhdl_timer

# links to documentation

add_documentation_link {Data Sheet } {http://www.altera.com/literature/hb/nios2/n2cpu_nii51008.pdf}

#-------------------------------------------------------------------------------
# module parameters
#-------------------------------------------------------------------------------

# parameters

add_parameter alwaysRun BOOLEAN
set_parameter_property alwaysRun DEFAULT_VALUE {false}
set_parameter_property alwaysRun DISPLAY_NAME {No Start/Stop control bits}
set_parameter_property alwaysRun AFFECTS_GENERATION {1}
set_parameter_property alwaysRun HDL_PARAMETER {0}

add_parameter counterSize INTEGER
set_parameter_property counterSize DEFAULT_VALUE {32}
set_parameter_property counterSize DISPLAY_NAME {Counter Size}
set_parameter_property counterSize ALLOWED_RANGES {32 64}
set_parameter_property counterSize AFFECTS_GENERATION {1}
set_parameter_property counterSize HDL_PARAMETER {0}

add_parameter fixedPeriod BOOLEAN
set_parameter_property fixedPeriod DEFAULT_VALUE {false}
set_parameter_property fixedPeriod DISPLAY_NAME {Fixed period}
set_parameter_property fixedPeriod AFFECTS_GENERATION {1}
set_parameter_property fixedPeriod HDL_PARAMETER {0}

add_parameter period STRING
set_parameter_property period DEFAULT_VALUE {1}
set_parameter_property period DISPLAY_NAME {Period}
set_parameter_property period AFFECTS_GENERATION {1}
set_parameter_property period HDL_PARAMETER {0}

add_parameter periodUnits STRING
set_parameter_property periodUnits DEFAULT_VALUE {MSEC}
set_parameter_property periodUnits DISPLAY_NAME {Units}
set_parameter_property periodUnits ALLOWED_RANGES {USEC:us MSEC:ms SEC:s CLOCKS:clocks}
set_parameter_property periodUnits AFFECTS_GENERATION {1}
set_parameter_property periodUnits HDL_PARAMETER {0}

add_parameter resetOutput BOOLEAN
set_parameter_property resetOutput DEFAULT_VALUE {false}
set_parameter_property resetOutput DISPLAY_NAME {System reset on timeout (Watchdog)}
set_parameter_property resetOutput AFFECTS_GENERATION {1}
set_parameter_property resetOutput HDL_PARAMETER {0}

add_parameter snapshot BOOLEAN
set_parameter_property snapshot DEFAULT_VALUE {true}
set_parameter_property snapshot DISPLAY_NAME {Readable snapshot}
set_parameter_property snapshot AFFECTS_GENERATION {1}
set_parameter_property snapshot HDL_PARAMETER {0}

add_parameter timeoutPulseOutput BOOLEAN
set_parameter_property timeoutPulseOutput DEFAULT_VALUE {false}
set_parameter_property timeoutPulseOutput DISPLAY_NAME {Timeout pulse (1 clock wide)}
set_parameter_property timeoutPulseOutput AFFECTS_GENERATION {1}
set_parameter_property timeoutPulseOutput HDL_PARAMETER {0}

# system info parameters

add_parameter systemFrequency LONG
set_parameter_property systemFrequency DEFAULT_VALUE {0}
set_parameter_property systemFrequency DISPLAY_NAME {systemFrequency}
set_parameter_property systemFrequency VISIBLE {0}
set_parameter_property systemFrequency AFFECTS_GENERATION {1}
set_parameter_property systemFrequency HDL_PARAMETER {0}
set_parameter_property systemFrequency SYSTEM_INFO {clock_rate clk}
set_parameter_property systemFrequency SYSTEM_INFO_TYPE {CLOCK_RATE}
set_parameter_property systemFrequency SYSTEM_INFO_ARG {clk}

# derived parameters

add_parameter timerPreset STRING
set_parameter_property timerPreset DEFAULT_VALUE {FULL_FEATURED}
set_parameter_property timerPreset DISPLAY_NAME {Presets}
set_parameter_property timerPreset ALLOWED_RANGES {CUSTOM SIMPLE_PERIODIC_INTERRUPT FULL_FEATURED WATCHDOG}
set_parameter_property timerPreset AFFECTS_GENERATION {1}
set_parameter_property timerPreset HDL_PARAMETER {0}
set_parameter_property timerPreset VISIBLE {0}
set_parameter_property timerPreset DERIVED {1}

add_parameter periodUnitsString STRING
set_parameter_property periodUnitsString DEFAULT_VALUE {ms}
set_parameter_property periodUnitsString DISPLAY_NAME {periodUnitsString}
set_parameter_property periodUnitsString VISIBLE {0}
set_parameter_property periodUnitsString DERIVED {1}
set_parameter_property periodUnitsString AFFECTS_GENERATION {1}
set_parameter_property periodUnitsString HDL_PARAMETER {0}

add_parameter valueInSecond INTEGER
set_parameter_property valueInSecond DEFAULT_VALUE {0}
set_parameter_property valueInSecond DISPLAY_NAME {valueInSecond}
set_parameter_property valueInSecond VISIBLE {0}
set_parameter_property valueInSecond DERIVED {1}
set_parameter_property valueInSecond AFFECTS_GENERATION {1}
set_parameter_property valueInSecond HDL_PARAMETER {0}

add_parameter loadValue STRING
set_parameter_property loadValue DEFAULT_VALUE {0}
set_parameter_property loadValue DISPLAY_NAME {loadValue}
set_parameter_property loadValue VISIBLE {0}
set_parameter_property loadValue DERIVED {1}
set_parameter_property loadValue AFFECTS_GENERATION {1}
set_parameter_property loadValue HDL_PARAMETER {0}

add_parameter mult INTEGER
set_parameter_property mult DEFAULT_VALUE {0}
set_parameter_property mult DISPLAY_NAME {mult}
set_parameter_property mult VISIBLE {0}
set_parameter_property mult DERIVED {1}
set_parameter_property mult AFFECTS_GENERATION {1}
set_parameter_property mult HDL_PARAMETER {0}

add_parameter ticksPerSec INTEGER
set_parameter_property ticksPerSec DEFAULT_VALUE {0}
set_parameter_property ticksPerSec DISPLAY_NAME {ticksPerSec}
set_parameter_property ticksPerSec VISIBLE {0}
set_parameter_property ticksPerSec DERIVED {1}
set_parameter_property ticksPerSec AFFECTS_GENERATION {1}
set_parameter_property ticksPerSec HDL_PARAMETER {0}

add_parameter slave_address_width INTEGER
set_parameter_property slave_address_width DEFAULT_VALUE {3}
set_parameter_property slave_address_width DISPLAY_NAME {slave_address_width}
set_parameter_property slave_address_width VISIBLE {0}
set_parameter_property slave_address_width DERIVED {1}
set_parameter_property slave_address_width AFFECTS_GENERATION {1}
set_parameter_property slave_address_width HDL_PARAMETER {0}


#-------------------------------------------------------------------------------
# module GUI
#-------------------------------------------------------------------------------

# display group
add_display_item {} {Timeout period} GROUP
add_display_item {} {Timer counter size} GROUP
add_display_item {} {Registers} GROUP
add_display_item {} {Output signals} GROUP

# group parameter
add_display_item {Registers} alwaysRun PARAMETER

add_display_item {Registers} fixedPeriod PARAMETER

add_display_item {Registers} snapshot PARAMETER

add_display_item {Timer counter size} counterSize PARAMETER

add_display_item {Timeout period} period PARAMETER

add_display_item {Timeout period} periodUnits PARAMETER

add_display_item {Output signals} resetOutput PARAMETER

add_display_item {Output signals} timeoutPulseOutput PARAMETER

#-------------------------------------------------------------------------------
# module validation
#-------------------------------------------------------------------------------

proc validate {} {

	# read parameter

	set alwaysRun [ proc_get_boolean_parameter alwaysRun ]
	set counterSize [ get_parameter_value counterSize ]
	set fixedPeriod [ proc_get_boolean_parameter fixedPeriod ]
	set period [ get_parameter_value period ]
	set periodUnits [ get_parameter_value periodUnits ]
	set timerPreset [ get_parameter_value timerPreset ]
	set resetOutput [ proc_get_boolean_parameter resetOutput ]
	set snapshot [ proc_get_boolean_parameter snapshot ]
	set systemFrequency [ get_parameter_value systemFrequency ]
	set timeoutPulseOutput [ proc_get_boolean_parameter timeoutPulseOutput ]
	set periodUnitsString [ get_parameter_value periodUnitsString ]
	set valueInSecond [ get_parameter_value valueInSecond ]
	set loadValue [ get_parameter_value loadValue ]
	set mult [ get_parameter_value mult ]
	set ticksPerSec [ get_parameter_value ticksPerSec ]
	set slave_address_width [ get_parameter_value slave_address_width ]

	# validate parameter

    if { $periodUnits == "USEC" } {
        set periodUnitsString "us"
        set valueInSecond {0.000001}
    } elseif { $periodUnits == "MSEC" } {
        set periodUnitsString "ms"
        set valueInSecond {0.001}
    } elseif { $periodUnits == "SEC" } {
        set periodUnitsString "s"
        set valueInSecond {1.0}
    } else {
        set periodUnitsString "clocks"
        set valueInSecond {0.0}
    }
    
    if { $counterSize == "64" } {
        set slave_address_width 4
    } else {
        set slave_address_width 3
    }
    
    # validate period for illegal non-numerical character
    if { ![ proc_isNumerical $period ] } {
        send_message error "Period $period contain illegal character."
    }
    
    # validate period units
    if { [ expr  { $systemFrequency > 0 } || { $periodUnitsString == "clocks" } ] } {
        # verify the period unit and do rounding if necessary
        if { $periodUnitsString == "clocks" } {
            set roundedPeriod [ proc_doRounding $period ]
            if { $roundedPeriod != $period } {
                send_message warning "Period is in units of $periodUnitsString. The period is rounded to $roundedPeriod."
                set period $roundedPeriod
            }
        }
        
        # validate load value
        if { $periodUnitsString == "clocks" } {
            set mult [ expr 1.0 / $systemFrequency ]
            set roundedCycle [ proc_doRounding $period ]
        } else {
            set mult $valueInSecond
            set periodInCycle [ expr $systemFrequency * $period * $valueInSecond ]
            if { $periodInCycle < pow(2,$counterSize) } {
                set roundedCycle [ proc_doRounding $periodInCycle ]
            } else {
                set roundedCycle $periodInCycle
            }
        }
        set loadValue [ expr $roundedCycle - 1 ]
        
        if { [ expr { $period == 0 } || { $mult == 0 } ] } {
            set ticksPerSec 0
        } else {
            set ticksPerSec [ expr 1 / ( $period * $mult ) ]
        }
        
        if { [ expr $loadValue < 1 ] } {
            send_message error "Period is too small for this frequency."
        } elseif { [ expr $loadValue > [ expr pow(2,$counterSize) - 1 ] ] } {
            send_message error "Period $period $periodUnitsString is too large for ${counterSize}-bit counter."
        }
    } else {
        send_message warning "Period validation cannot be done because input clock is unknown."
    }
    
    # validate watchdog period can be written
    if { [ expr { $fixedPeriod == "0" } && { $resetOutput == "1" } ] } {
        send_message warning "Watch dog period can be re-written."
    }
    
    # validate watchdog period can be stopped
    if { [ expr { $alwaysRun == "0" } && { $resetOutput == "1" } ] } {
        send_message warning "Watch dog counter can be stopped."
    }

    # update preset value for software usage
    if { [expr { $alwaysRun == "1" } && { $timeoutPulseOutput == "0" } && { $resetOutput == "0" } && { $snapshot == "0" } && { $fixedPeriod == "1" }] } {
        set timerPreset "SIMPLE_PERIODIC_INTERRUPT"
    } elseif { [expr { $alwaysRun == "0" } && { $timeoutPulseOutput == "0" } && { $resetOutput == "0" } && { $snapshot == "1" } && { $fixedPeriod == "0" }] } {
        set timerPreset "FULL_FEATURED"
    } elseif { [expr { $alwaysRun == "1" } && { $timeoutPulseOutput == "0" } && { $resetOutput == "1" } && { $snapshot == "0" } && { $fixedPeriod == "1" }] } {
        set timerPreset "WATCHDOG"
    } else {
        set timerPreset "CUSTOM"
    }

	# embedded software assignments

	set_module_assignment embeddedsw.CMacro.ALWAYS_RUN "$alwaysRun"
	set_module_assignment embeddedsw.CMacro.COUNTER_SIZE "$counterSize"
	set_module_assignment embeddedsw.CMacro.FIXED_PERIOD "$fixedPeriod"
	set_module_assignment embeddedsw.CMacro.FREQ "$systemFrequency"
	set_module_assignment embeddedsw.CMacro.LOAD_VALUE "$loadValue"
	set_module_assignment embeddedsw.CMacro.MULT "$mult"
	set_module_assignment embeddedsw.CMacro.PERIOD "$period"
	set_module_assignment embeddedsw.CMacro.PERIOD_UNITS "$periodUnitsString"
	set_module_assignment embeddedsw.CMacro.RESET_OUTPUT "$resetOutput"
	set_module_assignment embeddedsw.CMacro.SNAPSHOT "$snapshot"
	set_module_assignment embeddedsw.CMacro.TICKS_PER_SEC "$ticksPerSec"
	set_module_assignment embeddedsw.CMacro.TIMEOUT_PULSE_OUTPUT "$timeoutPulseOutput"

	# Device tree parameters
	set_module_assignment embeddedsw.dts.vendor "altr"
	if { [ expr { $timerPreset == "FULL_FEATURED" } ] } {
		set_module_assignment embeddedsw.dts.group "timer"
		set_module_assignment embeddedsw.dts.name "timer"
		set_module_assignment embeddedsw.dts.compatible "altr,timer-1.0"
		set_module_assignment embeddedsw.dts.params.clock-frequency $systemFrequency
	} elseif { [ expr { $timerPreset == "WATCHDOG" } ] } {
		set_module_assignment embeddedsw.dts.group "watchdog"
		set_module_assignment embeddedsw.dts.name "wdt"
		set_module_assignment embeddedsw.dts.compatible "altr,wdt-1.0"
		set_module_assignment embeddedsw.dts.params.clock-frequency $systemFrequency
		set_module_assignment embeddedsw.dts.params.timeout $loadValue
	}

	# update derived parameter
	
	set_parameter_value periodUnitsString $periodUnitsString
	set_parameter_value timerPreset $timerPreset
	set_parameter_value valueInSecond $valueInSecond
	set_parameter_value loadValue $loadValue
	set_parameter_value mult $mult
	set_parameter_value ticksPerSec $ticksPerSec
	set_parameter_value slave_address_width $slave_address_width

}

#-------------------------------------------------------------------------------
# module elaboration
#-------------------------------------------------------------------------------

proc elaborate {} {

	# read parameter

	set resetOutput [ proc_get_boolean_parameter resetOutput ]
	set timeoutPulseOutput [ proc_get_boolean_parameter timeoutPulseOutput ]
	set slave_address_width [ get_parameter_value slave_address_width ]

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
	set_interface_property s1 printableDevice {0}
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
	set_interface_property s1 writeWaitStates {0}
	set_interface_property s1 writeWaitTime {0}

	add_interface_port s1 address address Input $slave_address_width
	add_interface_port s1 writedata writedata Input 16
	add_interface_port s1 readdata readdata Output 16
	add_interface_port s1 chipselect chipselect Input 1
	add_interface_port s1 write_n write_n Input 1

	set_interface_assignment s1 embeddedsw.configuration.isTimerDevice {1}

	add_interface irq interrupt sender
	set_interface_property irq associatedAddressablePoint {s1}
	set_interface_property irq associatedClock {clk}
	set_interface_property irq associatedReset {reset}
	set_interface_property irq irqScheme {NONE}

	add_interface_port irq irq irq Output 1
	
    if { $resetOutput == "1" } {
        add_interface resetrequest reset source
        set_interface_property resetrequest associatedClock {clk}
        set_interface_property resetrequest associatedResetSinks {none}
        set_interface_property resetrequest synchronousEdges {NONE}
    
        add_interface_port resetrequest resetrequest reset Output 1
    }
    
    if { $timeoutPulseOutput == "1" } {
        add_interface external_port conduit conduit
    
        add_interface_port external_port timeout_pulse export Output 1
    }

}

#-------------------------------------------------------------------------------
# module generation
#-------------------------------------------------------------------------------

proc proc_add_generated_files_timer {NAME output_directory rtl_ext simulation} {
    # add files
    set gen_files [ glob -directory ${output_directory} ${NAME}* ]

    if { "$rtl_ext" == "vhd" } {
        set language "VHDL"
        set rtl_sim_ext "vho"
    } else {
        set language "VERILOG"
        set rtl_sim_ext "vo"
    }
    
    foreach my_file $gen_files {
        # get filename
        set file_name [ file tail $my_file ]
        # add files
        if { [ string match "*.mif" "$file_name" ] } {
            add_fileset_file "$file_name" MIF PATH $my_file
        } elseif { [ string match "*.dat" "$file_name" ] } {
            add_fileset_file "$file_name" DAT PATH $my_file
        } elseif { [ string match "*.hex" "$file_name" ] } {
            add_fileset_file "$file_name" HEX PATH $my_file
        } elseif { [ string match "*.do" "$file_name" ] } {
            add_fileset_file "$file_name" OTHER PATH "$my_file"
        } elseif { [ string match "*.ocp" "$file_name" ] } {
            add_fileset_file "$file_name" OTHER PATH "$my_file"
        } elseif { [ string match "*.sdc" "$file_name" ] } {
            add_fileset_file "$file_name" SDC PATH "$my_file"
        } elseif { [ string match "*.pl" "$file_name" ] } {
            # do nothing
        } elseif { [ string match "*.${rtl_sim_ext}" "$file_name" ] } {
            if { $simulation } {
                add_fileset_file "$file_name" $language PATH "$my_file"
            }
        } elseif { [ string match "*.${rtl_ext}" "$file_name" ] } {
            add_fileset_file "$file_name" $language PATH "$my_file"
        } else {
            add_fileset_file "$file_name" OTHER PATH "$my_file"
        }
    }
}

# generate
proc generate {output_name output_directory rtl_ext simgen} {
	global env
	set QUARTUS_ROOTDIR         "$env(QUARTUS_ROOTDIR)"
	set component_directory     "$QUARTUS_ROOTDIR/../ip/altera/sopc_builder_ip/altera_avalon_timer"
	set component_config_file   "$output_directory/${output_name}_component_configuration.pl"

	# read parameter

	set alwaysRun [ proc_get_boolean_parameter alwaysRun ]
	set counterSize [ get_parameter_value counterSize ]
	set fixedPeriod [ proc_get_boolean_parameter fixedPeriod ]
	set period [ get_parameter_value period ]
	set resetOutput [ proc_get_boolean_parameter resetOutput ]
	set snapshot [ proc_get_boolean_parameter snapshot ]
	set systemFrequency [ get_parameter_value systemFrequency ]
	set timeoutPulseOutput [ proc_get_boolean_parameter timeoutPulseOutput ]
	set timerPreset [ get_parameter_value timerPreset ]
	set periodUnitsString [ get_parameter_value periodUnitsString ]
	set loadValue [ get_parameter_value loadValue ]
	set mult [ get_parameter_value mult ]
	set ticksPerSec [ get_parameter_value ticksPerSec ]
	
	# prepare config file
	set component_config    [open $component_config_file "w"]

	puts $component_config "# ${output_name} Component Configuration File"
	puts $component_config "return {"

	puts $component_config "\talways_run              => \"$alwaysRun\","
	puts $component_config "\tclock_frequency         => \"$systemFrequency\","
	puts $component_config "\tcounter_size            => \"$counterSize\","
	puts $component_config "\tfixed_period            => \"$fixedPeriod\","
	puts $component_config "\tload_value              => \"$loadValue\","
	puts $component_config "\tmult                    => \"$mult\","
	puts $component_config "\tperiod                  => \"$period\","
	puts $component_config "\tperiod_units            => \"$periodUnitsString\","
	puts $component_config "\treset_output            => \"$resetOutput\","
	puts $component_config "\tsnapshot                => \"$snapshot\","
	puts $component_config "\tticks_per_sec           => \"$ticksPerSec\","
	puts $component_config "\ttimeout_pulse_output    => \"$timeoutPulseOutput\","

	puts $component_config "};"
	close $component_config

	# generate rtl
	proc_generate_component_rtl  "$component_config_file" "$component_directory" "$output_name" "$output_directory" "$rtl_ext" "$simgen"
	proc_add_generated_files_timer "$output_name" "$output_directory" "$rtl_ext" "$simgen"
}

proc sub_quartus_synth_timer {NAME} {
    set rtl_ext "v"
    set simgen  0
    set output_directory [ create_temp_file "" ]

    generate                    "$NAME" "$output_directory" "$rtl_ext" "$simgen"
}

proc sub_sim_verilog_timer {NAME} {
    set rtl_ext "v"
    set simgen  1
    set output_directory [ create_temp_file "" ]

    generate                    "$NAME" "$output_directory" "$rtl_ext" "$simgen"
}

proc sub_sim_vhdl_timer {NAME} {
    set rtl_ext "vhd"
    set simgen  1
    set output_directory [ create_temp_file "" ]

    generate                    "$NAME" "$output_directory" "$rtl_ext" "$simgen"
}