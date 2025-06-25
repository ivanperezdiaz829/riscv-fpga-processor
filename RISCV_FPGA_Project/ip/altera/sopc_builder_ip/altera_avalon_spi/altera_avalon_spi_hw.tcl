package require -exact qsys 12.0
source $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/common/embedded_ip_hwtcl_common.tcl

#-------------------------------------------------------------------------------
# module properties
#-------------------------------------------------------------------------------

set_module_property NAME {altera_avalon_spi}
set_module_property DISPLAY_NAME {SPI (3 Wire Serial)}
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

add_documentation_link {Data Sheet} {http://www.altera.com/literature/hb/nios2/n2cpu_nii51011.pdf}

#-------------------------------------------------------------------------------
# module parameters
#-------------------------------------------------------------------------------

# parameters
add_parameter clockPhase INTEGER
set_parameter_property clockPhase DEFAULT_VALUE {0}
set_parameter_property clockPhase DISPLAY_NAME {Clock phase}
set_parameter_property clockPhase ALLOWED_RANGES {0 1}
set_parameter_property clockPhase AFFECTS_GENERATION {1}
set_parameter_property clockPhase HDL_PARAMETER {0}

add_parameter clockPolarity INTEGER
set_parameter_property clockPolarity DEFAULT_VALUE {0}
set_parameter_property clockPolarity DISPLAY_NAME {Clock polarity}
set_parameter_property clockPolarity ALLOWED_RANGES {0 1}
set_parameter_property clockPolarity AFFECTS_GENERATION {1}
set_parameter_property clockPolarity HDL_PARAMETER {0}

add_parameter dataWidth INTEGER
set_parameter_property dataWidth DEFAULT_VALUE {8}
set_parameter_property dataWidth DISPLAY_NAME {Width}
set_parameter_property dataWidth UNITS {Bits}
set_parameter_property dataWidth ALLOWED_RANGES {8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32}
set_parameter_property dataWidth AFFECTS_GENERATION {1}
set_parameter_property dataWidth HDL_PARAMETER {0}

add_parameter disableAvalonFlowControl BOOLEAN
set_parameter_property disableAvalonFlowControl DEFAULT_VALUE {false}
set_parameter_property disableAvalonFlowControl DISPLAY_NAME {Disable flow control on Avalon slave interface}
set_parameter_property disableAvalonFlowControl AFFECTS_GENERATION {1}
set_parameter_property disableAvalonFlowControl VISIBLE {0}
set_parameter_property disableAvalonFlowControl HDL_PARAMETER {0}

add_parameter insertDelayBetweenSlaveSelectAndSClk BOOLEAN
set_parameter_property insertDelayBetweenSlaveSelectAndSClk DEFAULT_VALUE {false}
set_parameter_property insertDelayBetweenSlaveSelectAndSClk DISPLAY_NAME {Specify delay}
set_parameter_property insertDelayBetweenSlaveSelectAndSClk AFFECTS_GENERATION {1}
set_parameter_property insertDelayBetweenSlaveSelectAndSClk HDL_PARAMETER {0}

add_parameter insertSync BOOLEAN
set_parameter_property insertSync DEFAULT_VALUE {false}
set_parameter_property insertSync DISPLAY_NAME {Insert Synchronizers}
set_parameter_property insertSync AFFECTS_GENERATION {1}
set_parameter_property insertSync HDL_PARAMETER {0}

add_parameter lsbOrderedFirst BOOLEAN
set_parameter_property lsbOrderedFirst DEFAULT_VALUE {false}
set_parameter_property lsbOrderedFirst DISPLAY_NAME {Shift direction}
set_parameter_property lsbOrderedFirst ALLOWED_RANGES {{false:MSB first} {true:LSB first}}
set_parameter_property lsbOrderedFirst AFFECTS_GENERATION {1}
set_parameter_property lsbOrderedFirst HDL_PARAMETER {0}

add_parameter masterSPI BOOLEAN
set_parameter_property masterSPI DEFAULT_VALUE {true}
set_parameter_property masterSPI DISPLAY_NAME {Type}
set_parameter_property masterSPI ALLOWED_RANGES {true:Master false:Slave}
set_parameter_property masterSPI AFFECTS_GENERATION {1}
set_parameter_property masterSPI HDL_PARAMETER {0}

add_parameter numberOfSlaves INTEGER
set_parameter_property numberOfSlaves DEFAULT_VALUE {1}
set_parameter_property numberOfSlaves DISPLAY_NAME {Number of select (SS_n) signals (one for each slave)}
set_parameter_property numberOfSlaves ALLOWED_RANGES {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32}
set_parameter_property numberOfSlaves AFFECTS_GENERATION {1}
set_parameter_property numberOfSlaves HDL_PARAMETER {0}

add_parameter syncRegDepth INTEGER
set_parameter_property syncRegDepth DEFAULT_VALUE {2}
set_parameter_property syncRegDepth DISPLAY_NAME {Depth}
set_parameter_property syncRegDepth ALLOWED_RANGES {2 3}
set_parameter_property syncRegDepth AFFECTS_GENERATION {1}
set_parameter_property syncRegDepth HDL_PARAMETER {0}

add_parameter targetClockRate LONG
set_parameter_property targetClockRate DEFAULT_VALUE {128000}
set_parameter_property targetClockRate DISPLAY_NAME {SPI clock (SCLK) rate}
set_parameter_property targetClockRate UNITS {Hertz}
set_parameter_property targetClockRate ALLOWED_RANGES {1:2147483647}
set_parameter_property targetClockRate AFFECTS_GENERATION {1}
set_parameter_property targetClockRate HDL_PARAMETER {0}

add_parameter targetSlaveSelectToSClkDelay FLOAT
set_parameter_property targetSlaveSelectToSClkDelay DEFAULT_VALUE {0.0}
set_parameter_property targetSlaveSelectToSClkDelay DISPLAY_NAME {Target delay}
set_parameter_property targetSlaveSelectToSClkDelay UNITS {Nanoseconds}
set_parameter_property targetSlaveSelectToSClkDelay ALLOWED_RANGES {0.0:1.7976931348623157E308}
set_parameter_property targetSlaveSelectToSClkDelay AFFECTS_GENERATION {1}
set_parameter_property targetSlaveSelectToSClkDelay HDL_PARAMETER {0}

# system info parameters
add_parameter avalonSpec STRING
set_parameter_property avalonSpec DISPLAY_NAME {avalonSpec}
set_parameter_property avalonSpec VISIBLE {0}
set_parameter_property avalonSpec AFFECTS_GENERATION {1}
set_parameter_property avalonSpec HDL_PARAMETER {0}
set_parameter_property avalonSpec SYSTEM_INFO {avalon_spec}
set_parameter_property avalonSpec SYSTEM_INFO_TYPE {AVALON_SPEC}

add_parameter inputClockRate LONG
set_parameter_property inputClockRate DEFAULT_VALUE {0}
set_parameter_property inputClockRate DISPLAY_NAME {inputClockRate}
set_parameter_property inputClockRate VISIBLE {0}
set_parameter_property inputClockRate AFFECTS_GENERATION {1}
set_parameter_property inputClockRate HDL_PARAMETER {0}
set_parameter_property inputClockRate SYSTEM_INFO {clock_rate clk}
set_parameter_property inputClockRate SYSTEM_INFO_TYPE {CLOCK_RATE}
set_parameter_property inputClockRate SYSTEM_INFO_ARG {clk}

# derived parameters
add_parameter actualClockRate FLOAT
set_parameter_property actualClockRate DEFAULT_VALUE {0.0}
set_parameter_property actualClockRate DISPLAY_NAME {Actual clock rate}
set_parameter_property actualClockRate DERIVED {1}
set_parameter_property actualClockRate UNITS {Hertz}
set_parameter_property actualClockRate AFFECTS_GENERATION {1}
set_parameter_property actualClockRate HDL_PARAMETER {0}

add_parameter actualSlaveSelectToSClkDelay FLOAT
set_parameter_property actualSlaveSelectToSClkDelay DEFAULT_VALUE {0.0}
set_parameter_property actualSlaveSelectToSClkDelay DISPLAY_NAME {Actual delay}
set_parameter_property actualSlaveSelectToSClkDelay DERIVED {1}
set_parameter_property actualSlaveSelectToSClkDelay UNITS {Nanoseconds}
set_parameter_property actualSlaveSelectToSClkDelay AFFECTS_GENERATION {1}
set_parameter_property actualSlaveSelectToSClkDelay HDL_PARAMETER {0}

add_parameter legacySignalsAllow BOOLEAN
set_parameter_property legacySignalsAllow DEFAULT_VALUE {true}
set_parameter_property legacySignalsAllow DISPLAY_NAME {legacySignalsAllow}
set_parameter_property legacySignalsAllow DERIVED {1}
set_parameter_property legacySignalsAllow VISIBLE {0}
set_parameter_property legacySignalsAllow AFFECTS_GENERATION {1}
set_parameter_property legacySignalsAllow HDL_PARAMETER {0}

add_parameter slaveDataBusWidth INTEGER
set_parameter_property slaveDataBusWidth DEFAULT_VALUE {16}
set_parameter_property slaveDataBusWidth DISPLAY_NAME {slaveDataBusWidth}
set_parameter_property slaveDataBusWidth DERIVED {1}
set_parameter_property slaveDataBusWidth VISIBLE {0}
set_parameter_property slaveDataBusWidth AFFECTS_GENERATION {1}
set_parameter_property slaveDataBusWidth HDL_PARAMETER {0}
set_parameter_property slaveDataBusWidth ALLOWED_RANGES {16 32}

#-------------------------------------------------------------------------------
# module GUI
#-------------------------------------------------------------------------------

# display group
add_display_item {} {To Hide (no longer valid in Qsys)} GROUP
add_display_item {} {Master/Slave} GROUP
add_display_item {} {Data register} GROUP
add_display_item {} {Timing} GROUP
add_display_item {} {Synchronizer Stages} GROUP

# group parameter
add_display_item {To Hide (no longer valid in Qsys)} legacySignalsAllow PARAMETER  
add_display_item {To Hide (no longer valid in Qsys)} disableAvalonFlowControl PARAMETER 
add_display_item {To Hide (no longer valid in Qsys)} slaveDataBusWidth PARAMETER 

add_display_item {Master/Slave} masterSPI PARAMETER
add_display_item {Master/Slave} numberOfSlaves PARAMETER
add_display_item {Master/Slave} targetClockRate PARAMETER
add_display_item {Master/Slave} actualClockRate PARAMETER
add_display_item {Master/Slave} insertDelayBetweenSlaveSelectAndSClk PARAMETER
add_display_item {Master/Slave} targetSlaveSelectToSClkDelay PARAMETER
add_display_item {Master/Slave} actualSlaveSelectToSClkDelay PARAMETER

add_display_item {Data register} dataWidth PARAMETER
add_display_item {Data register} lsbOrderedFirst PARAMETER

add_display_item {Timing} clockPolarity PARAMETER
add_display_item {Timing} clockPhase PARAMETER

add_display_item {Synchronizer Stages} insertSync PARAMETER
add_display_item {Synchronizer Stages} syncRegDepth PARAMETER

#-------------------------------------------------------------------------------
# module validation
#-------------------------------------------------------------------------------

proc validate {} {

	# read parameter
	set avalonSpec [ get_parameter_value avalonSpec ]
	set clockPhase [ get_parameter_value clockPhase ]
	set clockPolarity [ get_parameter_value clockPolarity ]
	set dataWidth [ get_parameter_value dataWidth ]
	set disableAvalonFlowControl [ proc_get_boolean_parameter disableAvalonFlowControl ]
	set inputClockRate [ get_parameter_value inputClockRate ]
	set insertDelayBetweenSlaveSelectAndSClk [ proc_get_boolean_parameter insertDelayBetweenSlaveSelectAndSClk ]
	set insertSync [ proc_get_boolean_parameter insertSync ]
	set lsbOrderedFirst [ proc_get_boolean_parameter lsbOrderedFirst ]
	set masterSPI [ proc_get_boolean_parameter masterSPI ]
	set numberOfSlaves [ get_parameter_value numberOfSlaves ]
	set syncRegDepth [ get_parameter_value syncRegDepth ]
	set targetClockRate [ get_parameter_value targetClockRate ]
	set targetSlaveSelectToSClkDelay [ get_parameter_value targetSlaveSelectToSClkDelay ]

	set actualClockRate [ get_parameter_value actualClockRate ]
	set actualSlaveSelectToSClkDelay [ get_parameter_value actualSlaveSelectToSClkDelay ]
	set legacySignalsAllow [ proc_get_boolean_parameter legacySignalsAllow ]
	set slaveDataBusWidth [ get_parameter_value slaveDataBusWidth ]
	
	# validate parameter
	set_parameter_property numberOfSlaves  ENABLED $masterSPI
	set_parameter_property targetClockRate ENABLED $masterSPI
	set_parameter_property actualClockRate ENABLED $masterSPI
    
	set master_need_delay [ expr { $masterSPI }  && { $insertDelayBetweenSlaveSelectAndSClk } ]
	set_parameter_property targetSlaveSelectToSClkDelay         ENABLED $master_need_delay
	set_parameter_property actualSlaveSelectToSClkDelay         ENABLED $master_need_delay
	set_parameter_property insertDelayBetweenSlaveSelectAndSClk ENABLED $masterSPI
	set_parameter_property syncRegDepth                         ENABLED $insertSync

	if { [ expr $inputClockRate != 0 ] } {
	    set targetClockDivisor [ expr int(ceil( double($inputClockRate) / double($targetClockRate))) ]	
	    if { [ expr $targetClockDivisor % 2 ] == 1 } {
	        set targetClockDivisor [ expr $targetClockDivisor + 1 ]
	    }	
	    set actualClockRate [ expr $inputClockRate / $targetClockDivisor ]
        
	    set delayQuantumInNanoseconds [ expr double(1.0e9) /  ( 2.0 * $actualClockRate ) ]
	    if { $insertDelayBetweenSlaveSelectAndSClk } {
	        set numberOfDelayQuanta [ expr double($targetSlaveSelectToSClkDelay) / double($delayQuantumInNanoseconds) ]
	        set roundedUpDelayQuanta [ expr int(ceil($numberOfDelayQuanta)) ]
	        if { [ expr $roundedUpDelayQuanta < 1 ] } {
	            set roundedUpDelayQuanta 1
	        }     
	        set actualSlaveSelectToSClkDelay [ expr double($roundedUpDelayQuanta * $delayQuantumInNanoseconds) ]
	    }        
	}   

	# embedded software assignments
	set slaveDataBusWidth 16
	if { [ expr $dataWidth > 16 ] } {
	    set slaveDataBusWidth 32
	}

	set_module_assignment embeddedsw.CMacro.CLOCKMULT       {1}
	set_module_assignment embeddedsw.CMacro.CLOCKPHASE      $clockPhase 
	set_module_assignment embeddedsw.CMacro.CLOCKPOLARITY   $clockPolarity
	set_module_assignment embeddedsw.CMacro.CLOCKUNITS      {"Hz"}
	set_module_assignment embeddedsw.CMacro.DATABITS        $dataWidth
	set_module_assignment embeddedsw.CMacro.DATAWIDTH       $slaveDataBusWidth
	set_module_assignment embeddedsw.CMacro.DELAYMULT       {"1.0E-9"}
	set_module_assignment embeddedsw.CMacro.DELAYUNITS      {"ns"}
	set_module_assignment embeddedsw.CMacro.EXTRADELAY      $insertDelayBetweenSlaveSelectAndSClk
	set_module_assignment embeddedsw.CMacro.INSERT_SYNC     $insertSync
	set_module_assignment embeddedsw.CMacro.ISMASTER        $masterSPI
	set_module_assignment embeddedsw.CMacro.LSBFIRST        $lsbOrderedFirst
	set_module_assignment embeddedsw.CMacro.NUMSLAVES       $numberOfSlaves
	set_module_assignment embeddedsw.CMacro.PREFIX          {"spi_"}       
	set_module_assignment embeddedsw.CMacro.SYNC_REG_DEPTH  $syncRegDepth
	set_module_assignment embeddedsw.CMacro.TARGETCLOCK     "${targetClockRate}u"
	set_module_assignment embeddedsw.CMacro.TARGETSSDELAY   "\"$targetSlaveSelectToSClkDelay\""
     
	set_parameter_value actualClockRate                  $actualClockRate
	set_parameter_value actualSlaveSelectToSClkDelay     $actualSlaveSelectToSClkDelay
	set_parameter_value legacySignalsAllow               0
	set_parameter_value slaveDataBusWidth                $slaveDataBusWidth
	
	# Device tree parameters
	set_module_assignment embeddedsw.dts.vendor "altr"
	set_module_assignment embeddedsw.dts.group "spi"
	set_module_assignment embeddedsw.dts.name "spi"
	set_module_assignment embeddedsw.dts.compatible "altr,spi-1.0"
}

#-------------------------------------------------------------------------------
# module elaboration
#-------------------------------------------------------------------------------

proc elaborate {} {

	# read parameter
	set avalonSpec [ get_parameter_value avalonSpec ]
	set clockPhase [ get_parameter_value clockPhase ]
	set clockPolarity [ get_parameter_value clockPolarity ]
	set dataWidth [ get_parameter_value dataWidth ]
	set disableAvalonFlowControl [ proc_get_boolean_parameter disableAvalonFlowControl ]
	set inputClockRate [ get_parameter_value inputClockRate ]
	set insertDelayBetweenSlaveSelectAndSClk [ proc_get_boolean_parameter insertDelayBetweenSlaveSelectAndSClk ]
	set insertSync [ proc_get_boolean_parameter insertSync ]
	set lsbOrderedFirst [ proc_get_boolean_parameter lsbOrderedFirst ]
	set masterSPI [ proc_get_boolean_parameter masterSPI ]
	set numberOfSlaves [ get_parameter_value numberOfSlaves ]
	set syncRegDepth [ get_parameter_value syncRegDepth ]
	set targetClockRate [ get_parameter_value targetClockRate ]
	set targetSlaveSelectToSClkDelay [ get_parameter_value targetSlaveSelectToSClkDelay ]

	set actualClockRate [ get_parameter_value actualClockRate ]
	set actualSlaveSelectToSClkDelay [ get_parameter_value actualSlaveSelectToSClkDelay ]
	set legacySignalsAllow [ proc_get_boolean_parameter legacySignalsAllow ]
	set slaveDataBusWidth [ get_parameter_value slaveDataBusWidth ]

	# interfaces
	add_interface clk clock sink
	set_interface_property clk clockRate {0.0}
	set_interface_property clk externallyDriven {0}

	add_interface_port clk clk clk Input 1


	add_interface reset reset sink
	set_interface_property reset associatedClock {clk}
	set_interface_property reset synchronousEdges {DEASSERT}

	add_interface_port reset reset_n reset_n Input 1


	add_interface spi_control_port avalon slave
	set_interface_property spi_control_port addressAlignment {NATIVE}
	set_interface_property spi_control_port addressGroup {0}
	set_interface_property spi_control_port addressSpan {8}
	set_interface_property spi_control_port addressUnits {WORDS}
	set_interface_property spi_control_port alwaysBurstMaxBurst {0}
	set_interface_property spi_control_port associatedClock {clk}
	set_interface_property spi_control_port associatedReset {reset}
	set_interface_property spi_control_port bitsPerSymbol {8}
	set_interface_property spi_control_port burstOnBurstBoundariesOnly {0}
	set_interface_property spi_control_port burstcountUnits {WORDS}
	set_interface_property spi_control_port constantBurstBehavior {0}
	set_interface_property spi_control_port explicitAddressSpan {0}
	set_interface_property spi_control_port holdTime {0}
	set_interface_property spi_control_port interleaveBursts {0}
	set_interface_property spi_control_port isBigEndian {0}
	set_interface_property spi_control_port isFlash {0}
	set_interface_property spi_control_port isMemoryDevice {0}
	set_interface_property spi_control_port isNonVolatileStorage {0}
	set_interface_property spi_control_port linewrapBursts {0}
	set_interface_property spi_control_port maximumPendingReadTransactions {0}
	set_interface_property spi_control_port minimumUninterruptedRunLength {1}
	set_interface_property spi_control_port printableDevice {0}
	set_interface_property spi_control_port readLatency {0}
	set_interface_property spi_control_port readWaitStates {1}
	set_interface_property spi_control_port readWaitTime {1}
	set_interface_property spi_control_port registerIncomingSignals {0}
	set_interface_property spi_control_port registerOutgoingSignals {0}
	set_interface_property spi_control_port setupTime {0}
	set_interface_property spi_control_port timingUnits {Cycles}
	set_interface_property spi_control_port transparentBridge {0}
	set_interface_property spi_control_port wellBehavedWaitrequest {0}
	set_interface_property spi_control_port writeLatency {0}
	set_interface_property spi_control_port writeWaitStates {1}
	set_interface_property spi_control_port writeWaitTime {1}

	add_interface_port spi_control_port data_from_cpu writedata Input $slaveDataBusWidth 
	add_interface_port spi_control_port data_to_cpu readdata Output $slaveDataBusWidth
	add_interface_port spi_control_port mem_addr address Input 3
	add_interface_port spi_control_port read_n read_n Input 1
	add_interface_port spi_control_port spi_select chipselect Input 1
	add_interface_port spi_control_port write_n write_n Input 1

	set_interface_assignment spi_control_port embeddedsw.configuration.isFlash {0}
	set_interface_assignment spi_control_port embeddedsw.configuration.isMemoryDevice {0}
	set_interface_assignment spi_control_port embeddedsw.configuration.isNonVolatileStorage {0}
	set_interface_assignment spi_control_port embeddedsw.configuration.isPrintableDevice {0}

	add_interface irq interrupt sender
	set_interface_property irq associatedAddressablePoint {spi_control_port}
	set_interface_property irq associatedClock {clk}
	set_interface_property irq associatedReset {reset}
	set_interface_property irq irqScheme {NONE}

	add_interface_port irq irq irq Output 1


    add_interface external conduit conduit
    if { $masterSPI } {
        add_interface_port external MISO export Input 1
        add_interface_port external MOSI export Output 1
        add_interface_port external SCLK export Output 1
        add_interface_port external SS_n export Output $numberOfSlaves
    } else {
        add_interface_port external MISO export Output 1
        add_interface_port external MOSI export Input 1
        add_interface_port external SCLK export Input 1
        add_interface_port external SS_n export Input 1
    }
}

#-------------------------------------------------------------------------------
# module generation
#-------------------------------------------------------------------------------
# generate
proc generate {output_name output_directory rtl_ext simgen} {
	global env
	set QUARTUS_ROOTDIR         "$env(QUARTUS_ROOTDIR)"
	set component_directory     "$QUARTUS_ROOTDIR/../ip/altera/sopc_builder_ip/altera_avalon_spi"
	set component_config_file   "$output_directory/${output_name}_component_configuration.pl"

	# read parameter
	set actualClockRate [ get_parameter_value actualClockRate ]
	set actualSlaveSelectToSClkDelay [ get_parameter_value actualSlaveSelectToSClkDelay ]
	set avalonSpec [ get_parameter_value avalonSpec ]
	set clockPhase [ get_parameter_value clockPhase ]
	set clockPolarity [ get_parameter_value clockPolarity ]
	set dataWidth [ get_parameter_value dataWidth ]
	set disableAvalonFlowControl [ proc_get_boolean_parameter disableAvalonFlowControl ]
	set inputClockRate [ get_parameter_value inputClockRate ]
	set insertDelayBetweenSlaveSelectAndSClk [ proc_get_boolean_parameter insertDelayBetweenSlaveSelectAndSClk ]
	set insertSync [ proc_get_boolean_parameter insertSync ]
	set legacySignalsAllow [ proc_get_boolean_parameter legacySignalsAllow ]
	set lsbOrderedFirst [ proc_get_boolean_parameter lsbOrderedFirst ]
	set masterSPI [ proc_get_boolean_parameter masterSPI ]
	set numberOfSlaves [ get_parameter_value numberOfSlaves ]
	set syncRegDepth [ get_parameter_value syncRegDepth ]
	set targetClockRate [ get_parameter_value targetClockRate ]
	set targetSlaveSelectToSClkDelay [ get_parameter_value targetSlaveSelectToSClkDelay ]

	set actualClockRate [ get_parameter_value actualClockRate ]
	set actualSlaveSelectToSClkDelay [ get_parameter_value actualSlaveSelectToSClkDelay ]
	set legacySignalsAllow [ proc_get_boolean_parameter legacySignalsAllow ]
	set slaveDataBusWidth [ get_parameter_value slaveDataBusWidth ]

	# prepare config file
	set component_config    [open $component_config_file "w"]

	puts $component_config "# ${output_name} Component Configuration File"
	puts $component_config "return {"

	puts $component_config "\tdatabits			=> $dataWidth,"
	puts $component_config "\tdatawidth			=> $slaveDataBusWidth,"
	puts $component_config "\ttargetclock			=> $targetClockRate,"
	puts $component_config "\tclockunits			=> \"Hz\","
	puts $component_config "\tclockmult			=> 1,"
	puts $component_config "\tnumslaves			=> $numberOfSlaves,"
	puts $component_config "\tismaster			=> $masterSPI,"
	puts $component_config "\tallow_legacy_signals		=> $legacySignalsAllow,"
	puts $component_config "\tclockpolarity			=> $clockPolarity,"
	puts $component_config "\tclockphase			=> $clockPhase,"
	puts $component_config "\tlsbfirst			=> $lsbOrderedFirst,"
	puts $component_config "\textradelay			=> $insertDelayBetweenSlaveSelectAndSClk,"
	puts $component_config "\tinsert_sync			=> $insertSync,"
	puts $component_config "\tsync_reg_depth		=> $syncRegDepth,"
	puts $component_config "\tdisableAvalonFlowControl	=> $disableAvalonFlowControl,"
	puts $component_config "\ttargetssdelay			=> \"$targetSlaveSelectToSClkDelay\","
	puts $component_config "\tdelayunits			=> \"ns\","
	puts $component_config "\tdelaymult			=> \"0.000000001\","
	puts $component_config "\tprefix			=> \"spi_\","
	puts $component_config "\tinputClockRate		=> $inputClockRate,"
	
	puts $component_config "};"
	close $component_config

	# generate rtl
	proc_generate_component_rtl  "$component_config_file" "$component_directory" "$output_name" "$output_directory" "$rtl_ext" "$simgen"
	proc_add_generated_files "$output_name" "$output_directory" "$rtl_ext" "$simgen"
}
