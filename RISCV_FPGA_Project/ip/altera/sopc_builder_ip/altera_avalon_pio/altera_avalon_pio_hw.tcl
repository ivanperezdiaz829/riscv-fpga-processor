package require -exact qsys 12.0
source $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/common/embedded_ip_hwtcl_common.tcl

#-------------------------------------------------------------------------------
# module properties
#-------------------------------------------------------------------------------

set_module_property NAME {altera_avalon_pio}
set_module_property DISPLAY_NAME {PIO (Parallel I/O)}
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

add_fileset quartus_synth QUARTUS_SYNTH sub_quartus_synth
add_fileset sim_verilog SIM_VERILOG sub_sim_verilog
add_fileset sim_vhdl SIM_VHDL sub_sim_vhdl

# links to documentation

add_documentation_link {Data Sheet } {http://www.altera.com/literature/hb/nios2/n2cpu_nii51007.pdf}

#-------------------------------------------------------------------------------
# module parameters
#-------------------------------------------------------------------------------

# parameters
add_parameter bitClearingEdgeCapReg BOOLEAN
set_parameter_property bitClearingEdgeCapReg DEFAULT_VALUE {false}
set_parameter_property bitClearingEdgeCapReg DISPLAY_NAME {Enable bit-clearing for edge capture register}
set_parameter_property bitClearingEdgeCapReg AFFECTS_GENERATION {1}
set_parameter_property bitClearingEdgeCapReg HDL_PARAMETER {0}

add_parameter bitModifyingOutReg BOOLEAN
set_parameter_property bitModifyingOutReg DEFAULT_VALUE {false}
set_parameter_property bitModifyingOutReg DISPLAY_NAME {Enable individual bit setting/clearing}
set_parameter_property bitModifyingOutReg AFFECTS_GENERATION {1}
set_parameter_property bitModifyingOutReg HDL_PARAMETER {0}

add_parameter captureEdge BOOLEAN
set_parameter_property captureEdge DEFAULT_VALUE {false}
set_parameter_property captureEdge DISPLAY_NAME {Synchronously capture}
set_parameter_property captureEdge AFFECTS_GENERATION {1}
set_parameter_property captureEdge HDL_PARAMETER {0}

add_parameter direction STRING
set_parameter_property direction DEFAULT_VALUE {Output}
set_parameter_property direction DISPLAY_NAME {Direction}
set_parameter_property direction ALLOWED_RANGES {Bidir Input InOut Output}
set_parameter_property direction DISPLAY_HINT {radio}
set_parameter_property direction AFFECTS_GENERATION {1}
set_parameter_property direction HDL_PARAMETER {0}

add_parameter edgeType STRING
set_parameter_property edgeType DEFAULT_VALUE {RISING}
set_parameter_property edgeType DISPLAY_NAME {Edge Type}
set_parameter_property edgeType ALLOWED_RANGES {RISING FALLING ANY}
set_parameter_property edgeType AFFECTS_GENERATION {1}
set_parameter_property edgeType HDL_PARAMETER {0}

add_parameter generateIRQ BOOLEAN
set_parameter_property generateIRQ DEFAULT_VALUE {false}
set_parameter_property generateIRQ DISPLAY_NAME {Generate IRQ}
set_parameter_property generateIRQ AFFECTS_GENERATION {1}
set_parameter_property generateIRQ HDL_PARAMETER {0}

add_parameter irqType STRING
set_parameter_property irqType DEFAULT_VALUE {LEVEL}
set_parameter_property irqType DISPLAY_NAME {IRQ Type}
set_parameter_property irqType ALLOWED_RANGES {LEVEL EDGE}
set_parameter_property irqType AFFECTS_GENERATION {1}
set_parameter_property irqType HDL_PARAMETER {0}   

add_parameter resetValue LONG
set_parameter_property resetValue DEFAULT_VALUE {0}
set_parameter_property resetValue DISPLAY_NAME {Output Port Reset Value}
set_parameter_property resetValue ALLOWED_RANGES {0:4294967295}
set_parameter_property resetValue DISPLAY_HINT {hexadecimal}
set_parameter_property resetValue AFFECTS_GENERATION {1}
set_parameter_property resetValue HDL_PARAMETER {0}

add_parameter simDoTestBenchWiring BOOLEAN
set_parameter_property simDoTestBenchWiring DEFAULT_VALUE {false}
set_parameter_property simDoTestBenchWiring DISPLAY_NAME {Hardwire PIO inputs in test bench}
set_parameter_property simDoTestBenchWiring AFFECTS_GENERATION {1}
set_parameter_property simDoTestBenchWiring HDL_PARAMETER {0}

add_parameter simDrivenValue LONG
set_parameter_property simDrivenValue DEFAULT_VALUE {0}
set_parameter_property simDrivenValue DISPLAY_NAME {Drive inputs to}
set_parameter_property simDrivenValue ALLOWED_RANGES {0:4294967295}
set_parameter_property simDrivenValue DISPLAY_HINT {hexadecimal}
set_parameter_property simDrivenValue AFFECTS_GENERATION {1}
set_parameter_property simDrivenValue HDL_PARAMETER {0}

add_parameter width INTEGER
set_parameter_property width DEFAULT_VALUE {8}
set_parameter_property width DISPLAY_NAME {Width (1-32 bits)}
set_parameter_property width ALLOWED_RANGES {1:32}
set_parameter_property width AFFECTS_GENERATION {1}
set_parameter_property width HDL_PARAMETER {0}

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
  add_parameter derived_has_tri BOOLEAN
  set_parameter_property derived_has_tri DEFAULT_VALUE {false}
  set_parameter_property derived_has_tri DISPLAY_NAME {derived_has_tri} 
  set_parameter_property derived_has_tri VISIBLE {0}
  set_parameter_property derived_has_tri DERIVED {1}
  set_parameter_property derived_has_tri AFFECTS_GENERATION {1}
  set_parameter_property derived_has_tri HDL_PARAMETER {0}
 
  add_parameter derived_has_out BOOLEAN
  set_parameter_property derived_has_out DEFAULT_VALUE {false}
  set_parameter_property derived_has_out DISPLAY_NAME {derived_has_out} 
  set_parameter_property derived_has_out VISIBLE {0}
  set_parameter_property derived_has_out DERIVED {1}
  set_parameter_property derived_has_out AFFECTS_GENERATION {1}
  set_parameter_property derived_has_out HDL_PARAMETER {0}
 
  add_parameter derived_has_in BOOLEAN
  set_parameter_property derived_has_in DEFAULT_VALUE {false}
  set_parameter_property derived_has_in DISPLAY_NAME {derived_has_in} 
  set_parameter_property derived_has_in VISIBLE {0}
  set_parameter_property derived_has_in DERIVED {1}
  set_parameter_property derived_has_in AFFECTS_GENERATION {1}
  set_parameter_property derived_has_in HDL_PARAMETER {0}

  add_parameter derived_do_test_bench_wiring BOOLEAN
  set_parameter_property derived_do_test_bench_wiring DEFAULT_VALUE {false}
  set_parameter_property derived_do_test_bench_wiring DISPLAY_NAME {derived_do_test_bench_wiring} 
  set_parameter_property derived_do_test_bench_wiring VISIBLE {0}
  set_parameter_property derived_do_test_bench_wiring DERIVED {1}
  set_parameter_property derived_do_test_bench_wiring AFFECTS_GENERATION {1}
  set_parameter_property derived_do_test_bench_wiring HDL_PARAMETER {0}

  add_parameter derived_capture BOOLEAN                                  
  set_parameter_property derived_capture DEFAULT_VALUE {false}
  set_parameter_property derived_capture DISPLAY_NAME {derived_capture} 
  set_parameter_property derived_capture VISIBLE {0}
  set_parameter_property derived_capture DERIVED {1}
  set_parameter_property derived_capture AFFECTS_GENERATION {1}
  set_parameter_property derived_capture HDL_PARAMETER {0}                 

  add_parameter derived_edge_type STRING
  set_parameter_property derived_edge_type DEFAULT_VALUE {RISING}
  set_parameter_property derived_edge_type DISPLAY_NAME {derived_edge_type} 
  set_parameter_property derived_edge_type VISIBLE {0}
  set_parameter_property derived_edge_type DERIVED {1}
  set_parameter_property derived_edge_type AFFECTS_GENERATION {1}
  set_parameter_property derived_edge_type HDL_PARAMETER {0}

  add_parameter derived_irq_type STRING
  set_parameter_property derived_irq_type DEFAULT_VALUE {LEVEL}
  set_parameter_property derived_irq_type DISPLAY_NAME {derived_irq_type} 
  set_parameter_property derived_irq_type VISIBLE {0}
  set_parameter_property derived_irq_type DERIVED {1}
  set_parameter_property derived_irq_type AFFECTS_GENERATION {1}
  set_parameter_property derived_irq_type HDL_PARAMETER {0}
  
  add_parameter derived_has_irq BOOLEAN
  set_parameter_property derived_has_irq DEFAULT_VALUE {false}
  set_parameter_property derived_has_irq DISPLAY_NAME {derived_has_irq} 
  set_parameter_property derived_has_irq VISIBLE {0}
  set_parameter_property derived_has_irq DERIVED {1}
  set_parameter_property derived_has_irq AFFECTS_GENERATION {1}
  set_parameter_property derived_has_irq HDL_PARAMETER {0}  

  
#-------------------------------------------------------------------------------
# module GUI
#-------------------------------------------------------------------------------

# display group
add_display_item {} {Basic Settings} GROUP
add_display_item {} {Output Register} GROUP
add_display_item {} {Edge capture register} GROUP
add_display_item {} {Interrupt} GROUP
add_display_item {} {Test bench wiring} GROUP

# group parameter
add_display_item {Basic Settings} width PARAMETER
add_display_item {Basic Settings} direction PARAMETER
set_display_item_property direction DISPLAY_HINT {radio}
add_display_item {Basic Settings} resetValue PARAMETER
set_display_item_property resetValue DISPLAY_HINT {hexadecimal}

add_display_item {Output Register} bitModifyingOutReg PARAMETER

add_display_item {Edge capture register} captureEdge PARAMETER
add_display_item {Edge capture register} edgeType PARAMETER
add_display_item {Edge capture register} bitClearingEdgeCapReg PARAMETER

add_display_item {Interrupt} generateIRQ PARAMETER
add_display_item {Interrupt} irqType PARAMETER
add_display_item {Interrupt} irqTypeText TEXT "<html><b>Level</b>: Interrupt CPU when any unmasked I/O pin is logic true<br>\
<b>Edge</b>: Interrupt CPU when any unmasked bit in the edge-capture<br>\
register is logic true. Available when synchronous capture is enabled<br><br>" 

add_display_item {Test bench wiring} simDoTestBenchWiring PARAMETER
add_display_item {Test bench wiring} simDrivenValue PARAMETER
set_display_item_property simDrivenValue DISPLAY_HINT {hexadecimal}

#-------------------------------------------------------------------------------
# module validation
#-------------------------------------------------------------------------------

proc validate {} {

	# read parameter
	set bitClearingEdgeCapReg [ proc_get_boolean_parameter bitClearingEdgeCapReg ]
	set bitModifyingOutReg [ proc_get_boolean_parameter bitModifyingOutReg ]
	set captureEdge [ proc_get_boolean_parameter captureEdge ]
	set direction [ get_parameter_value direction ]
	set edgeType [ get_parameter_value edgeType ]
	set generateIRQ [ proc_get_boolean_parameter generateIRQ ]
	set irqType [ get_parameter_value irqType ]
	set resetValue [ get_parameter_value resetValue ]
	set simDoTestBenchWiring [ proc_get_boolean_parameter simDoTestBenchWiring ]
	set simDrivenValue [ get_parameter_value simDrivenValue ]
	set width [ get_parameter_value width ]
	set clockRate [ get_parameter_value clockRate ]
	# add derived parameter
	set derived_has_tri [ proc_get_boolean_parameter derived_has_tri ]
	set derived_has_out [ proc_get_boolean_parameter derived_has_out ]
	set derived_has_in [ proc_get_boolean_parameter derived_has_in ] 
	set derived_do_test_bench_wiring [ proc_get_boolean_parameter derived_do_test_bench_wiring ] 
	set derived_capture [ proc_get_boolean_parameter derived_capture ] 
	set derived_edge_type [ get_parameter_value derived_edge_type ] 
	set derived_irq_type [ get_parameter_value derived_irq_type ] 
	set derived_has_irq [ get_parameter_value derived_has_irq ] 
	
	
	# validate parameter
  
# ---- part 1 validate GUI interactive ----  	
  #Disable and set all the input-related parameters if the PIO is output only 
  ## Input related parameter               
  set enable_option_for_input [ expr {$direction != "Output"} ]
  
  set_parameter_property captureEdge ENABLED $enable_option_for_input
  set_parameter_property generateIRQ ENABLED $enable_option_for_input
  set_parameter_property simDoTestBenchWiring ENABLED $enable_option_for_input
  set_parameter_property edgeType ENABLED $enable_option_for_input
  set_parameter_property irqType ENABLED $enable_option_for_input
  set_parameter_property simDrivenValue ENABLED $enable_option_for_input
  
  ## edgeType parameter                           
  if { $captureEdge && ($direction != "Output") } {
    set_parameter_property edgeType ENABLED {true}
  } else {
    set_parameter_property edgeType ENABLED {false}
  }
  
  ## bitClearingEdgeCapReg parameter	
  if { $captureEdge && ($direction != "Output") } {
    set_parameter_property bitClearingEdgeCapReg ENABLED {true}
  } else {
    set_parameter_property bitClearingEdgeCapReg ENABLED {false}
  }
  
  ## bitModifyingOutReg parameter
  if { $direction != "Input" } {
    set_parameter_property bitModifyingOutReg ENABLED {true}
  } else {
    set_parameter_property bitModifyingOutReg ENABLED {false}
  }
  
  ## resetValue parameter
  if { $direction == "Input" } {
    set_parameter_property resetValue ENABLED {false}
  } else {
    set_parameter_property resetValue ENABLED {true}
  }
  
  ## irqType parameter	
  if { $generateIRQ && ($direction != "Output") } {
    set_parameter_property irqType ENABLED {true}
  } else {
    set_parameter_property irqType ENABLED {false}
  }
  
  ## irqType legal range	
  if { $captureEdge } {
    set_parameter_property irqType ALLOWED_RANGES {LEVEL EDGE}
  } else {
    set_parameter_property irqType ALLOWED_RANGES {LEVEL}
  }
# ---- part 2 validate GUI input parameter ----
  # Edge interrupt validation  
  if { !$captureEdge && $generateIRQ &&  ($irqType == "EDGE") && ($direction != "Output")} {
    send_message error "Edge interrupt option is invalid because synchronously capture option is disabled" 
  } 
  
  # Simulation validation 
  if { $simDoTestBenchWiring && ($direction != "Output") } {
    set_parameter_property simDrivenValue ENABLED {true}  
      if { $simDrivenValue >= [expr {pow(2,$width)}] } {
        send_message error "Driven simulation value exceeds PIO data width." 
      }
    
  } else {
    set_parameter_property simDrivenValue ENABLED {false}         
  }
          
  # Input PIO is hardwired in testbench validation     
  if { !$simDoTestBenchWiring && ($direction != "Output")} {
    send_message info "PIO inputs are not hardwired in test bench. Undefined values will be read from PIO inputs during simulation." 
  } 
  
  # Reset value validation 
  if { $direction != "Input" } {
      if { $resetValue >= [expr {pow(2, $width)}] } {
        send_message error "Reset value exceeds PIO data width." 
      }
  }	
  
	# embedded software assignments
# ---- part 3 update software assignment with validation value ----	
  set derived_do_test_bench_wiring [ expr {$simDoTestBenchWiring && ($direction != "Output")}]
  set derived_capture [ expr {$captureEdge && ($direction != "Output")}]  
  set derived_edge_type [ expr {[ expr {$captureEdge && ($direction != "Output")}] ? $edgeType : "NONE" }]
  set derived_irq_type [ expr {[ expr {$generateIRQ && ($direction != "Output")}] ? $irqType : "NONE" }]
  set derived_has_irq [ expr {$generateIRQ && ($direction != "Output")} ]
  
  switch $direction {
    Bidir {
      set derived_has_tri 1
      set derived_has_out 0
      set derived_has_in  0  
    }
    Input {
      set derived_has_tri 0
      set derived_has_out 0
      set derived_has_in  1
    } 
    InOut {
      set derived_has_tri 0
      set derived_has_out 1
      set derived_has_in  1
    } 
    Output {
      set derived_has_tri 0
      set derived_has_out 1
      set derived_has_in  0   
    }
  }
  
	set_module_assignment embeddedsw.CMacro.DO_TEST_BENCH_WIRING "$derived_do_test_bench_wiring"
	set_module_assignment embeddedsw.CMacro.DRIVEN_SIM_VALUE "$simDrivenValue"
	set_module_assignment embeddedsw.CMacro.HAS_TRI "$derived_has_tri"
	set_module_assignment embeddedsw.CMacro.HAS_OUT "$derived_has_out"
	set_module_assignment embeddedsw.CMacro.HAS_IN "$derived_has_in"
	set_module_assignment embeddedsw.CMacro.CAPTURE "$derived_capture" 
	set_module_assignment embeddedsw.CMacro.BIT_CLEARING_EDGE_REGISTER "$bitClearingEdgeCapReg"
	set_module_assignment embeddedsw.CMacro.BIT_MODIFYING_OUTPUT_REGISTER "$bitModifyingOutReg"
	set_module_assignment embeddedsw.CMacro.DATA_WIDTH "$width"
	set_module_assignment embeddedsw.CMacro.RESET_VALUE "$resetValue"
        set_module_assignment embeddedsw.CMacro.EDGE_TYPE "$derived_edge_type"
	set_module_assignment embeddedsw.CMacro.IRQ_TYPE "$derived_irq_type" 
	set_module_assignment embeddedsw.CMacro.FREQ "$clockRate" 

	# Device tree parameters
	set_module_assignment embeddedsw.dts.vendor "altr"
	set_module_assignment embeddedsw.dts.group "gpio"
	set_module_assignment embeddedsw.dts.name "pio"
	set_module_assignment embeddedsw.dts.compatible "altr,pio-1.0"
	set_module_assignment embeddedsw.dts.params.width $width
	set_module_assignment embeddedsw.dts.params.resetvalue $resetValue

  # update derived parameter
  set_parameter_value derived_has_tri $derived_has_tri 
  set_parameter_value derived_has_out $derived_has_out
  set_parameter_value derived_has_in $derived_has_in 
  set_parameter_value derived_do_test_bench_wiring $derived_do_test_bench_wiring 
  set_parameter_value derived_capture $derived_capture 
  set_parameter_value derived_edge_type $derived_edge_type 
  set_parameter_value derived_irq_type $derived_irq_type 
  set_parameter_value derived_has_irq $derived_has_irq

	if { $derived_has_irq } {
		# only allow active high
		if {$irqType == "LEVEL"} {
			set_module_assignment embeddedsw.dts.params.level_trigger 1
		}
		if {$irqType == "EDGE"} {
			set_module_assignment embeddedsw.dts.params.level_trigger 0
			if {$edgeType == "RISING"} {
				set_module_assignment embeddedsw.dts.params.edge_type 0
			}
			if {$edgeType == "FALLING"} {
				set_module_assignment embeddedsw.dts.params.edge_type 1
			}
			if {$edgeType == "ANY"} {
				set_module_assignment embeddedsw.dts.params.edge_type 2
			}
		}
	}
}

#-------------------------------------------------------------------------------
# module elaboration
#-------------------------------------------------------------------------------

proc elaborate {} {

	# read parameter
	set bitClearingEdgeCapReg [ proc_get_boolean_parameter bitClearingEdgeCapReg ]
	set bitModifyingOutReg [ proc_get_boolean_parameter bitModifyingOutReg ]
	set captureEdge [ proc_get_boolean_parameter captureEdge ]
	set clockRate [ get_parameter_value clockRate ]
	set direction [ get_parameter_value direction ]
	set edgeType [ get_parameter_value edgeType ]
	set generateIRQ [ proc_get_boolean_parameter generateIRQ ]
	set irqType [ get_parameter_value irqType ]
	set resetValue [ get_parameter_value resetValue ]
	set simDoTestBenchWiring [ proc_get_boolean_parameter simDoTestBenchWiring ]
	set simDrivenValue [ get_parameter_value simDrivenValue ]
	set width [ get_parameter_value width ]
        # add derived parameter
	set derived_has_tri [ proc_get_boolean_parameter derived_has_tri ]
	set derived_has_out [ proc_get_boolean_parameter derived_has_out ]
	set derived_has_in [ proc_get_boolean_parameter derived_has_in ]
	
	# interfaces
# ---- part 1 validate/update port interface parameter  ----

  set has_any_output [ expr { $derived_has_tri || $derived_has_out } ]
  set slave_addr_in_width [ expr { $bitModifyingOutReg ? 3 : 2 } ]	
  
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
	set_interface_property s1 addressSpan {4}
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

        set svd_path [file join $::env(QUARTUS_ROOTDIR) .. ip altera sopc_builder_ip altera_avalon_pio altera_avalon_pio.svd]
        set_interface_property s1 CMSIS_SVD_FILE $svd_path


	add_interface_port s1 address address Input $slave_addr_in_width	
        if { $has_any_output || $generateIRQ || $captureEdge } { 	
          add_interface_port s1 write_n write_n Input 1
          add_interface_port s1 writedata writedata Input 32
          add_interface_port s1 chipselect chipselect Input 1
        }	             
	add_interface_port s1 readdata readdata Output 32

	set_interface_assignment s1 embeddedsw.configuration.isFlash {0}
	set_interface_assignment s1 embeddedsw.configuration.isMemoryDevice {0}
	set_interface_assignment s1 embeddedsw.configuration.isNonVolatileStorage {0}
	set_interface_assignment s1 embeddedsw.configuration.isPrintableDevice {0}

	add_interface external_connection conduit conduit

	#add_interface_port external_connection out_port export Output 8
        if { $derived_has_tri } { add_interface_port external_connection bidir_port export bidir $width }
        if { $derived_has_in }  { add_interface_port external_connection in_port export input $width }
        if { $derived_has_out } { add_interface_port external_connection out_port export output $width }
		        
        if { $generateIRQ && ($direction != "Output") } {
	  # only allow active high
	  if {$irqType == "LEVEL"} {
		set irq_tx_type "ACTIVE_HIGH"
	  } 
	  if {$irqType == "EDGE"} {
	  	set irq_tx_type "RISING_EDGE"
	  }
          add_interface irq interrupt sender
	  set_interface_property irq associatedAddressablePoint {s1}
	  set_interface_property irq associatedClock {clk}
	  set_interface_property irq associatedReset {reset}
	  set_interface_property irq irqScheme {NONE}

	  add_interface_port irq irq irq Output 1

          set_interface_assignment irq embeddedsw.dts.irq.tx_type $irq_tx_type
	}
}

#-------------------------------------------------------------------------------
# module generation
#-------------------------------------------------------------------------------
# generate
proc generate {output_name output_directory rtl_ext simgen} {
	global env
	set QUARTUS_ROOTDIR         "$env(QUARTUS_ROOTDIR)"
	set component_directory     "$QUARTUS_ROOTDIR/../ip/altera/sopc_builder_ip/altera_avalon_pio"
	set component_config_file   "$output_directory/${output_name}_component_configuration.pl"

	# read parameter
	set bitClearingEdgeCapReg [ proc_get_boolean_parameter bitClearingEdgeCapReg ]
	set bitModifyingOutReg [ proc_get_boolean_parameter bitModifyingOutReg ]
	set captureEdge [ proc_get_boolean_parameter captureEdge ]
	set clockRate [ get_parameter_value clockRate ]
	set direction [ get_parameter_value direction ]
	set edgeType [ get_parameter_value edgeType ]
	set generateIRQ [ proc_get_boolean_parameter generateIRQ ]
	set irqType [ get_parameter_value irqType ]
	set resetValue [ get_parameter_value resetValue ]
	set simDoTestBenchWiring [ proc_get_boolean_parameter simDoTestBenchWiring ]
	set simDrivenValue [ get_parameter_value simDrivenValue ]
	set width [ get_parameter_value width ]
        # add derived parameter
	set derived_has_tri [ proc_get_boolean_parameter derived_has_tri ]
	set derived_has_out [ proc_get_boolean_parameter derived_has_out ]
	set derived_has_in [ proc_get_boolean_parameter derived_has_in ]
	set derived_do_test_bench_wiring [ proc_get_boolean_parameter derived_do_test_bench_wiring ] 
	set derived_capture [ proc_get_boolean_parameter derived_capture ] 
	set derived_edge_type [ get_parameter_value derived_edge_type ] 
	set derived_irq_type [ get_parameter_value derived_irq_type ] 
	set derived_has_irq [ proc_get_boolean_parameter derived_has_irq ] 
	
	# prepare config file
	set component_config    [open $component_config_file "w"]

	#NOTE: the config file content format is in return {key => value, key => value,};
	puts $component_config "# ${output_name} Component Configuration File"
	puts $component_config "return {"

	puts $component_config "\tDo_Test_Bench_Wiring         	=> $derived_do_test_bench_wiring,"
    	puts $component_config "\tDriven_Sim_Value           	=> $simDrivenValue,"
    	puts $component_config "\thas_tri              		=> $derived_has_tri,"
    	puts $component_config "\thas_out            		=> $derived_has_out,"
    	puts $component_config "\thas_in                	=> $derived_has_in,"
    	puts $component_config "\tcapture                  	=> $derived_capture,"
    	puts $component_config "\tData_Width            	=> $width,"
    	puts $component_config "\treset_value            	=> $resetValue,"                    
    	puts $component_config "\tedge_type    			=> $derived_edge_type,"
    	puts $component_config "\tirq_type              	=> $derived_irq_type,"
    	puts $component_config "\tbit_clearing_edge_register    => $bitClearingEdgeCapReg,"
    	puts $component_config "\tbit_modifying_output_register => $bitModifyingOutReg,"
    	puts $component_config "\thas_irq 			=> $derived_has_irq,"

	puts $component_config "};"
	close $component_config

	# generate rtl
	proc_generate_component_rtl  "$component_config_file" "$component_directory" "$output_name" "$output_directory" "$rtl_ext" "$simgen"
	proc_add_generated_files "$output_name" "$output_directory" "$rtl_ext" "$simgen"
}

