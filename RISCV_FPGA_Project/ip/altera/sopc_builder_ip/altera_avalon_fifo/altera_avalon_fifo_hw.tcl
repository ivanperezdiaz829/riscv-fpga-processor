package require -exact qsys 12.0
source $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/common/embedded_ip_hwtcl_common.tcl

#-------------------------------------------------------------------------------
# module properties
#-------------------------------------------------------------------------------

set_module_property NAME {altera_avalon_fifo}
set_module_property DISPLAY_NAME {On-Chip FIFO Memory}
set_module_property VERSION {13.1}
set_module_property GROUP {Memories and Memory Controllers/On-Chip}
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

add_documentation_link {Data Sheet } {http://www.altera.com/literature/hb/nios2/qts_qii55002.pdf}

#-------------------------------------------------------------------------------
# module parameters
#-------------------------------------------------------------------------------

# parameters

add_parameter avalonMMAvalonMMDataWidth INTEGER
set_parameter_property avalonMMAvalonMMDataWidth DEFAULT_VALUE {32}
set_parameter_property avalonMMAvalonMMDataWidth DISPLAY_NAME {Data width}
set_parameter_property avalonMMAvalonMMDataWidth ALLOWED_RANGES {8 16 32 64 128 256}
set_parameter_property avalonMMAvalonMMDataWidth AFFECTS_GENERATION {1}
set_parameter_property avalonMMAvalonMMDataWidth HDL_PARAMETER {0}

add_parameter avalonMMAvalonSTDataWidth INTEGER
set_parameter_property avalonMMAvalonSTDataWidth DEFAULT_VALUE {32}
set_parameter_property avalonMMAvalonSTDataWidth DISPLAY_NAME {avalonMMAvalonSTDataWidth}
set_parameter_property avalonMMAvalonSTDataWidth VISIBLE {0}
set_parameter_property avalonMMAvalonSTDataWidth ALLOWED_RANGES {8 16 32 64 128 256}
set_parameter_property avalonMMAvalonSTDataWidth AFFECTS_GENERATION {1}
set_parameter_property avalonMMAvalonSTDataWidth HDL_PARAMETER {0}

add_parameter bitsPerSymbol INTEGER
set_parameter_property bitsPerSymbol DEFAULT_VALUE {16}
set_parameter_property bitsPerSymbol DISPLAY_NAME {Bits per symbol}
set_parameter_property bitsPerSymbol ALLOWED_RANGES {1:32}
set_parameter_property bitsPerSymbol AFFECTS_GENERATION {1}
set_parameter_property bitsPerSymbol HDL_PARAMETER {0}

add_parameter channelWidth INTEGER
set_parameter_property channelWidth DEFAULT_VALUE {8}
set_parameter_property channelWidth DISPLAY_NAME {Channel width}
set_parameter_property channelWidth ALLOWED_RANGES {0:8}
set_parameter_property channelWidth AFFECTS_GENERATION {1}
set_parameter_property channelWidth HDL_PARAMETER {0}

add_parameter errorWidth INTEGER
set_parameter_property errorWidth DEFAULT_VALUE {8}
set_parameter_property errorWidth DISPLAY_NAME {Error width}
set_parameter_property errorWidth ALLOWED_RANGES {0:8}
set_parameter_property errorWidth AFFECTS_GENERATION {1}
set_parameter_property errorWidth HDL_PARAMETER {0}

add_parameter fifoDepth INTEGER
set_parameter_property fifoDepth DEFAULT_VALUE {16}
set_parameter_property fifoDepth DISPLAY_NAME {Depth}
set_parameter_property fifoDepth ALLOWED_RANGES {8 16 32 64 128 256 512 1024 2048 4096 8192}
set_parameter_property fifoDepth AFFECTS_GENERATION {1}
set_parameter_property fifoDepth HDL_PARAMETER {0}

add_parameter fifoInputInterfaceOptions STRING
set_parameter_property fifoInputInterfaceOptions DEFAULT_VALUE {AVALONMM_WRITE}
set_parameter_property fifoInputInterfaceOptions DISPLAY_NAME {Input type}
set_parameter_property fifoInputInterfaceOptions ALLOWED_RANGES {AVALONMM_WRITE AVALONST_SINK}
set_parameter_property fifoInputInterfaceOptions AFFECTS_GENERATION {1}
set_parameter_property fifoInputInterfaceOptions HDL_PARAMETER {0}

add_parameter fifoOutputInterfaceOptions STRING
set_parameter_property fifoOutputInterfaceOptions DEFAULT_VALUE {AVALONMM_READ}
set_parameter_property fifoOutputInterfaceOptions DISPLAY_NAME {Output type}
set_parameter_property fifoOutputInterfaceOptions ALLOWED_RANGES {AVALONMM_READ AVALONST_SOURCE}
set_parameter_property fifoOutputInterfaceOptions AFFECTS_GENERATION {1}
set_parameter_property fifoOutputInterfaceOptions HDL_PARAMETER {0}

add_parameter showHiddenFeatures BOOLEAN
set_parameter_property showHiddenFeatures DEFAULT_VALUE {false}
set_parameter_property showHiddenFeatures DISPLAY_NAME {showHiddenFeatures}
set_parameter_property showHiddenFeatures VISIBLE {0}
set_parameter_property showHiddenFeatures AFFECTS_GENERATION {1}
set_parameter_property showHiddenFeatures HDL_PARAMETER {0}

add_parameter singleClockMode BOOLEAN
set_parameter_property singleClockMode DEFAULT_VALUE {true}
set_parameter_property singleClockMode DISPLAY_NAME {Clock setting}
set_parameter_property singleClockMode ALLOWED_RANGES {{true:Single clock mode} {false:Dual clock mode}}
set_parameter_property singleClockMode AFFECTS_GENERATION {1}
set_parameter_property singleClockMode HDL_PARAMETER {0}

add_parameter singleResetMode BOOLEAN
set_parameter_property singleResetMode DEFAULT_VALUE {false}
set_parameter_property singleResetMode DISPLAY_NAME {singleResetMode}
set_parameter_property singleResetMode AFFECTS_GENERATION {1}
set_parameter_property singleResetMode HDL_PARAMETER {0}

add_parameter symbolsPerBeat INTEGER
set_parameter_property symbolsPerBeat DEFAULT_VALUE {2}
set_parameter_property symbolsPerBeat DISPLAY_NAME {Symbols per beat}
set_parameter_property symbolsPerBeat ALLOWED_RANGES {1:32}
set_parameter_property symbolsPerBeat AFFECTS_GENERATION {1}
set_parameter_property symbolsPerBeat HDL_PARAMETER {0}

add_parameter useBackpressure BOOLEAN
set_parameter_property useBackpressure DEFAULT_VALUE {true}
set_parameter_property useBackpressure DISPLAY_NAME {Allow backpressure}
set_parameter_property useBackpressure AFFECTS_GENERATION {1}
set_parameter_property useBackpressure HDL_PARAMETER {0}

add_parameter useIRQ BOOLEAN
set_parameter_property useIRQ DEFAULT_VALUE {true}
set_parameter_property useIRQ DISPLAY_NAME {Enable IRQ for status ports}
set_parameter_property useIRQ AFFECTS_GENERATION {1}
set_parameter_property useIRQ HDL_PARAMETER {0}

add_parameter usePacket BOOLEAN
set_parameter_property usePacket DEFAULT_VALUE {true}
set_parameter_property usePacket DISPLAY_NAME {Enable packet data}
set_parameter_property usePacket AFFECTS_GENERATION {1}
set_parameter_property usePacket HDL_PARAMETER {0}

add_parameter useReadControl BOOLEAN
set_parameter_property useReadControl DEFAULT_VALUE {false}
set_parameter_property useReadControl DISPLAY_NAME {Create status interface for output}
set_parameter_property useReadControl AFFECTS_GENERATION {1}
set_parameter_property useReadControl HDL_PARAMETER {0}

add_parameter useRegister BOOLEAN
set_parameter_property useRegister DEFAULT_VALUE {false}
set_parameter_property useRegister DISPLAY_NAME {FIFO implementation}
set_parameter_property useRegister ALLOWED_RANGES {{true:Construct FIFO from registers} {false:Construct FIFO from embedded memory blocks}}
set_parameter_property useRegister AFFECTS_GENERATION {1}
set_parameter_property useRegister HDL_PARAMETER {0}

add_parameter useWriteControl BOOLEAN
set_parameter_property useWriteControl DEFAULT_VALUE {true}
set_parameter_property useWriteControl DISPLAY_NAME {Create status interface for input}
set_parameter_property useWriteControl AFFECTS_GENERATION {1}
set_parameter_property useWriteControl HDL_PARAMETER {0}

# system info parameters

add_parameter deviceFamilyString STRING
set_parameter_property deviceFamilyString DISPLAY_NAME {deviceFamilyString}
set_parameter_property deviceFamilyString VISIBLE {0}
set_parameter_property deviceFamilyString AFFECTS_GENERATION {1}
set_parameter_property deviceFamilyString HDL_PARAMETER {0}
set_parameter_property deviceFamilyString SYSTEM_INFO {device_family}
set_parameter_property deviceFamilyString SYSTEM_INFO_TYPE {DEVICE_FAMILY}

# derived parameters
  add_parameter derived_use_avalonMM_wr_slave BOOLEAN
  set_parameter_property derived_use_avalonMM_wr_slave DEFAULT_VALUE {true}
  set_parameter_property derived_use_avalonMM_wr_slave DISPLAY_NAME {derived_use_avalonMM_wr_slave} 
  set_parameter_property derived_use_avalonMM_wr_slave VISIBLE {0}
  set_parameter_property derived_use_avalonMM_wr_slave DERIVED {1}
  set_parameter_property derived_use_avalonMM_wr_slave AFFECTS_GENERATION {1}
  set_parameter_property derived_use_avalonMM_wr_slave HDL_PARAMETER {0}
 
  add_parameter derived_use_avalonST_sink BOOLEAN
  set_parameter_property derived_use_avalonST_sink DEFAULT_VALUE {false}
  set_parameter_property derived_use_avalonST_sink DISPLAY_NAME {derived_use_avalonST_sink} 
  set_parameter_property derived_use_avalonST_sink VISIBLE {0}
  set_parameter_property derived_use_avalonST_sink DERIVED {1}
  set_parameter_property derived_use_avalonST_sink AFFECTS_GENERATION {1}
  set_parameter_property derived_use_avalonST_sink HDL_PARAMETER {0}
 
  add_parameter derived_use_avalonMM_rd_slave BOOLEAN
  set_parameter_property derived_use_avalonMM_rd_slave DEFAULT_VALUE {true}
  set_parameter_property derived_use_avalonMM_rd_slave DISPLAY_NAME {derived_use_avalonMM_rd_slave} 
  set_parameter_property derived_use_avalonMM_rd_slave VISIBLE {0}
  set_parameter_property derived_use_avalonMM_rd_slave DERIVED {1}
  set_parameter_property derived_use_avalonMM_rd_slave AFFECTS_GENERATION {1}
  set_parameter_property derived_use_avalonMM_rd_slave HDL_PARAMETER {0}
 
  add_parameter derived_use_avalonST_source BOOLEAN
  set_parameter_property derived_use_avalonST_source DEFAULT_VALUE {false}
  set_parameter_property derived_use_avalonST_source DISPLAY_NAME {derived_use_avalonST_source} 
  set_parameter_property derived_use_avalonST_source VISIBLE {0}
  set_parameter_property derived_use_avalonST_source DERIVED {1}
  set_parameter_property derived_use_avalonST_source AFFECTS_GENERATION {1}
  set_parameter_property derived_use_avalonST_source HDL_PARAMETER {0}
 
  add_parameter derived_sink_source_avalonST_width INTEGER
  set_parameter_property derived_sink_source_avalonST_width DEFAULT_VALUE {32}
  set_parameter_property derived_sink_source_avalonST_width DISPLAY_NAME {derived_sink_source_avalonST_width}
  set_parameter_property derived_sink_source_avalonST_width VISIBLE {0}
  set_parameter_property derived_sink_source_avalonST_width DERIVED {1}
  set_parameter_property derived_sink_source_avalonST_width AFFECTS_GENERATION {1}
  set_parameter_property derived_sink_source_avalonST_width HDL_PARAMETER {0}

#-------------------------------------------------------------------------------
# module GUI
#-------------------------------------------------------------------------------

# display group
add_display_item {} singleResetMode PARAMETER
add_display_item {} {Basic options} GROUP
add_display_item {} {Status port} GROUP
add_display_item {} {Input} GROUP
add_display_item {} {Output} GROUP
add_display_item {} {Avalon-MM port settings} GROUP
add_display_item {} {Avalon-ST port settings} GROUP

# group parameter
add_display_item {Basic options} fifoDepth PARAMETER
add_display_item {Basic options} useBackpressure PARAMETER
add_display_item {Basic options} singleClockMode PARAMETER
add_display_item {Basic options} useRegister PARAMETER

add_display_item {Status port} useWriteControl PARAMETER
add_display_item {Status port} useReadControl PARAMETER
add_display_item {Status port} useIRQ PARAMETER

add_display_item {Input} fifoInputInterfaceOptions PARAMETER

add_display_item {Output} fifoOutputInterfaceOptions PARAMETER

add_display_item {Avalon-MM port settings} avalonMMAvalonMMDataWidth PARAMETER

add_display_item {Avalon-ST port settings} bitsPerSymbol PARAMETER
add_display_item {Avalon-ST port settings} symbolsPerBeat PARAMETER
add_display_item {Avalon-ST port settings} errorWidth PARAMETER
add_display_item {Avalon-ST port settings} channelWidth PARAMETER
add_display_item {Avalon-ST port settings} usePacket PARAMETER


#-------------------------------------------------------------------------------
# module validation
#-------------------------------------------------------------------------------

proc validate {} {

	# read user and system info parameter
	set avalonMMAvalonMMDataWidth [ get_parameter_value avalonMMAvalonMMDataWidth ]
	set avalonMMAvalonSTDataWidth [ get_parameter_value avalonMMAvalonSTDataWidth ]
	set bitsPerSymbol [ get_parameter_value bitsPerSymbol ]
	set channelWidth [ get_parameter_value channelWidth ]
	set deviceFamilyString [ get_parameter_value deviceFamilyString ]
	set errorWidth [ get_parameter_value errorWidth ]
	set fifoDepth [ get_parameter_value fifoDepth ]
	set fifoInputInterfaceOptions [ get_parameter_value fifoInputInterfaceOptions ]
	set fifoOutputInterfaceOptions [ get_parameter_value fifoOutputInterfaceOptions ]
	set showHiddenFeatures [ proc_get_boolean_parameter showHiddenFeatures ]
	set singleClockMode [ proc_get_boolean_parameter singleClockMode ]
	set singleResetMode [ proc_get_boolean_parameter singleResetMode ]
	set symbolsPerBeat [ get_parameter_value symbolsPerBeat ]
	set useBackpressure [ proc_get_boolean_parameter useBackpressure ]
	set useIRQ [ proc_get_boolean_parameter useIRQ ]
	set usePacket [ proc_get_boolean_parameter usePacket ]
	set useReadControl [ proc_get_boolean_parameter useReadControl ]
	set useRegister [ proc_get_boolean_parameter useRegister ]
	set useWriteControl [ proc_get_boolean_parameter useWriteControl ]

	# validate parameter and update derived parameter
        set derived_use_avalonMM_wr_slave [ proc_get_boolean_parameter derived_use_avalonMM_wr_slave ]
        set derived_use_avalonST_sink [ proc_get_boolean_parameter derived_use_avalonST_sink ]
        set derived_use_avalonMM_rd_slave [ proc_get_boolean_parameter derived_use_avalonMM_rd_slave ]
        set derived_use_avalonST_source [ proc_get_boolean_parameter derived_use_avalonST_source ]  
        set derived_sink_source_avalonST_width [ get_parameter_value derived_sink_source_avalonST_width ]  
        
	# GUI parameter enabling and disabling
# ---- part 1 validate GUI interactive ----
  if { !(($fifoInputInterfaceOptions=="AVALONMM_WRITE") && ($fifoOutputInterfaceOptions=="AVALONMM_READ")) } {
    # At least one Avalon-ST interface
    set_parameter_property avalonMMAvalonMMDataWidth ENABLED {false}	  
    	        
    # Enable all Avalon-ST related parameters
    set_parameter_property bitsPerSymbol ENABLED {true}	  
    set_parameter_property symbolsPerBeat ENABLED {true}	  
    set_parameter_property errorWidth ENABLED {true}	  
    set_parameter_property channelWidth ENABLED {true}	  
    set_parameter_property usePacket ENABLED {true}
    
      if { !(($fifoInputInterfaceOptions=="AVALONST_SINK") && ($fifoOutputInterfaceOptions=="AVALONST_SOURCE")) } {
        set_parameter_property avalonMMAvalonSTDataWidth ENABLED {true} 
      } else {
        set_parameter_property avalonMMAvalonSTDataWidth ENABLED {false}    
      }
      
  } else {
    # Both interfaces are Avalon-MM
    set_parameter_property avalonMMAvalonMMDataWidth ENABLED {true}
    
    # Disabled all Avalon-ST related parameters
    set_parameter_property bitsPerSymbol ENABLED {false}	  
    set_parameter_property symbolsPerBeat ENABLED {false}	  
    set_parameter_property errorWidth ENABLED {false}	  
    set_parameter_property channelWidth ENABLED {false}	  
    set_parameter_property usePacket ENABLED {false}
    set_parameter_property avalonMMAvalonSTDataWidth ENABLED {false} 	  
  }	  

  if { $useReadControl || $useWriteControl } {
    set_parameter_property useIRQ ENABLED {true}  	  
  } else {
    set_parameter_property useIRQ ENABLED {false}  	  
  }
  
  # update enum derived parameter
  switch $fifoInputInterfaceOptions {
    AVALONMM_WRITE {
      set derived_use_avalonMM_wr_slave 1
      set derived_use_avalonST_sink 0
    }
    AVALONST_SINK {
      set derived_use_avalonMM_wr_slave 0
      set derived_use_avalonST_sink 1
    } 
  }
  
  switch $fifoOutputInterfaceOptions {
    AVALONMM_READ {
      set derived_use_avalonMM_rd_slave 1
      set derived_use_avalonST_source 0
    }
    AVALONST_SOURCE {
      set derived_use_avalonMM_rd_slave 0
      set derived_use_avalonST_source 1
    } 
  }
  
# ---- part 2 validate GUI input parameter ----
  # validate useWriteControl and useReadControl 
  if { $singleClockMode } {
      if { $useReadControl } {
        send_message error "RDCLOCK control slave cannot be used in single clock mode."
      }  
  }

  # validate useRegister
  if { $useRegister && ($fifoDepth > 16) } {
    send_message warning "Logic elements are used for FIFO."
  }

  # validate FIFO Depth
  if { $fifoDepth != (1 << int([ expr ceil(log($fifoDepth)/log(2)) ]) ) } {
    send_message error "FIFO depth must be power of 2."   
  }
  
  # validate bitsPerSymbol and symbolsPerBeat
  set derived_sink_source_avalonST_width [expr $bitsPerSymbol*$symbolsPerBeat]
  if { $derived_sink_source_avalonST_width > 256 } {
    send_message error "The Avalon-ST data width of $result_of_multiple bits is too large. Valid Avalon-ST data width is 1~256 bits."   
  }
  
  # validate Data Width
  if { ($fifoInputInterfaceOptions=="AVALONMM_WRITE") && ($fifoOutputInterfaceOptions=="AVALONST_SOURCE") ||
       ($fifoInputInterfaceOptions=="AVALONST_SINK") && ($fifoOutputInterfaceOptions=="AVALONMM_READ") } {
      if { !$showHiddenFeatures && ($avalonMMAvalonSTDataWidth != 32) } {
        send_message error "Invalid parameter value for avalonMMAvalonSTDataWidth. It must be set to 32."
      }      
      
      if { !$showHiddenFeatures } {
        send_message info "For Avalon-ST and Avalon-MM combinations, data width is 32 bits."
      }
       
      set avalonMM_bits_per_symbol [ expr double(1<< [log2ceil $bitsPerSymbol]) ]
      set max_symbols_per_cycle [ expr double($avalonMMAvalonSTDataWidth/$avalonMM_bits_per_symbol) ]
      set cycles_per_beat [ expr double($symbolsPerBeat/$max_symbols_per_cycle) ] 
      
      if { $cycles_per_beat != 1 } {
        send_message error "Combination of Bits per symbol and Symbols per beat values must yield a data width of 32 bits."
      }
      
  } elseif { ($fifoInputInterfaceOptions=="AVALONMM_WRITE") && ($fifoOutputInterfaceOptions=="AVALONMM_READ") } {
      if { $avalonMMAvalonMMDataWidth != 32 } {
        send_message warning "The Nios II HAL drivers for the Altera Avalon FIFO support only 32-bit data width.
        If you connect this FIFO to a Nios II CPU, you will need to access the registers directly."
      }          
  }

  # validate Device family
  if { $deviceFamilyString == "Unknown" || $deviceFamilyString == "NONE" } {
    send_message error "Device family is unknown."
  }	  
  
  
	
	# embedded software assignments

	set_module_assignment embeddedsw.CMacro.FIFO_DEPTH $fifoDepth
	set_module_assignment embeddedsw.CMacro.AVALONMM_AVALONMM_DATA_WIDTH $avalonMMAvalonMMDataWidth
	
	if {($fifoInputInterfaceOptions=="AVALONMM_WRITE") && ($fifoOutputInterfaceOptions=="AVALONMM_READ")} {
	  set_module_assignment embeddedsw.CMacro.USE_AVALONMM_WRITE_SLAVE {1}
	  set_module_assignment embeddedsw.CMacro.USE_AVALONMM_READ_SLAVE {1}
	  set_module_assignment embeddedsw.CMacro.USE_AVALONST_SINK {0}
	  set_module_assignment embeddedsw.CMacro.USE_AVALONST_SOURCE {0}
	  
        } elseif {($fifoInputInterfaceOptions=="AVALONMM_WRITE") && ($fifoOutputInterfaceOptions=="AVALONST_SOURCE")} {	
	  set_module_assignment embeddedsw.CMacro.USE_AVALONMM_WRITE_SLAVE {1}
	  set_module_assignment embeddedsw.CMacro.USE_AVALONMM_READ_SLAVE {0}
	  set_module_assignment embeddedsw.CMacro.USE_AVALONST_SINK {0}
	  set_module_assignment embeddedsw.CMacro.USE_AVALONST_SOURCE {1}
	  
        } elseif {($fifoInputInterfaceOptions=="AVALONST_SINK") && ($fifoOutputInterfaceOptions=="AVALONMM_READ")} {
	  set_module_assignment embeddedsw.CMacro.USE_AVALONMM_WRITE_SLAVE {0}
	  set_module_assignment embeddedsw.CMacro.USE_AVALONMM_READ_SLAVE {1}
	  set_module_assignment embeddedsw.CMacro.USE_AVALONST_SINK {1}
	  set_module_assignment embeddedsw.CMacro.USE_AVALONST_SOURCE {0}   
	  
        } else {  
          set_module_assignment embeddedsw.CMacro.USE_AVALONMM_WRITE_SLAVE {0}
	  set_module_assignment embeddedsw.CMacro.USE_AVALONMM_READ_SLAVE {0}
	  set_module_assignment embeddedsw.CMacro.USE_AVALONST_SINK {1}
	  set_module_assignment embeddedsw.CMacro.USE_AVALONST_SOURCE {1}	
	}
		
	set_module_assignment embeddedsw.CMacro.SINGLE_CLOCK_MODE $singleClockMode
	set_module_assignment embeddedsw.CMacro.USE_BACKPRESSURE $useBackpressure
	set_module_assignment embeddedsw.CMacro.USE_IRQ $useIRQ
	set_module_assignment embeddedsw.CMacro.USE_READ_CONTROL $useReadControl
	set_module_assignment embeddedsw.CMacro.USE_REGISTER $useRegister
	set_module_assignment embeddedsw.CMacro.USE_WRITE_CONTROL $useWriteControl

	set_module_assignment embeddedsw.CMacro.AVALONMM_AVALONST_DATA_WIDTH $avalonMMAvalonSTDataWidth
	set_module_assignment embeddedsw.CMacro.BITS_PER_SYMBOL $bitsPerSymbol
	set_module_assignment embeddedsw.CMacro.CHANNEL_WIDTH $channelWidth
	set_module_assignment embeddedsw.CMacro.ERROR_WIDTH $errorWidth
	set_module_assignment embeddedsw.CMacro.SYMBOLS_PER_BEAT $symbolsPerBeat
        set_module_assignment embeddedsw.CMacro.USE_PACKET $usePacket
	
	# update derived parameter
  set_parameter_value derived_use_avalonMM_wr_slave $derived_use_avalonMM_wr_slave 
  set_parameter_value derived_use_avalonST_sink $derived_use_avalonST_sink 
  set_parameter_value derived_use_avalonMM_rd_slave $derived_use_avalonMM_rd_slave 
  set_parameter_value derived_use_avalonST_source $derived_use_avalonST_source 
  set_parameter_value derived_sink_source_avalonST_width $derived_sink_source_avalonST_width 
  
}

#-------------------------------------------------------------------------------
# module elaboration
#-------------------------------------------------------------------------------
proc elaborate {} {

	# read parameter

	set avalonMMAvalonMMDataWidth [ get_parameter_value avalonMMAvalonMMDataWidth ]
	set avalonMMAvalonSTDataWidth [ get_parameter_value avalonMMAvalonSTDataWidth ]
	set bitsPerSymbol [ get_parameter_value bitsPerSymbol ]
	set channelWidth [ get_parameter_value channelWidth ]
	set deviceFamilyString [ get_parameter_value deviceFamilyString ]
	set errorWidth [ get_parameter_value errorWidth ]
	set fifoDepth [ get_parameter_value fifoDepth ]
	set fifoInputInterfaceOptions [ get_parameter_value fifoInputInterfaceOptions ]
	set fifoOutputInterfaceOptions [ get_parameter_value fifoOutputInterfaceOptions ]
	set showHiddenFeatures [ proc_get_boolean_parameter showHiddenFeatures ]
	set singleClockMode [ proc_get_boolean_parameter singleClockMode ]
	set singleResetMode [ proc_get_boolean_parameter singleResetMode ]
	set symbolsPerBeat [ get_parameter_value symbolsPerBeat ]
	set useBackpressure [ proc_get_boolean_parameter useBackpressure ]
	set useIRQ [ proc_get_boolean_parameter useIRQ ]
	set usePacket [ proc_get_boolean_parameter usePacket ]
	set useReadControl [ proc_get_boolean_parameter useReadControl ]
	set useRegister [ proc_get_boolean_parameter useRegister ]
	set useWriteControl [ proc_get_boolean_parameter useWriteControl ]

	# interfaces
        set empty_width [ expr int(ceil(log($symbolsPerBeat)/log(2))) ]
        set derived_sink_source_avalonST_width [ get_parameter_value derived_sink_source_avalonST_width ]
        
        # -- update clock association --
        if { $singleClockMode } {
          add_interface clk_in clock sink
	  set_interface_property clk_in clockRate {0.0}
	  set_interface_property clk_in externallyDriven {0}
	  add_interface_port clk_in wrclock clk Input 1
                                 
	  add_interface reset_in reset sink
	  set_interface_property reset_in associatedClock {clk_in}
	  set_interface_property reset_in synchronousEdges {DEASSERT}
	  add_interface_port reset_in reset_n reset_n Input 1	
        } else {
          add_interface clk_in clock sink
	  set_interface_property clk_in clockRate {0.0}
	  set_interface_property clk_in externallyDriven {0}
	  add_interface_port clk_in wrclock clk Input 1
          
	  add_interface reset_in reset sink
	  set_interface_property reset_in associatedClock {clk_in}
	  set_interface_property reset_in synchronousEdges {DEASSERT}
	  add_interface_port reset_in wrreset_n reset_n Input 1
        
	  add_interface clk_out clock sink
	  set_interface_property clk_out clockRate {0.0}
	  set_interface_property clk_out externallyDriven {0}
	  add_interface_port clk_out rdclock clk Input 1
          
	  add_interface reset_out reset sink
	  set_interface_property reset_out associatedClock {clk_out}
	  set_interface_property reset_out synchronousEdges {DEASSERT}
	  add_interface_port reset_out rdreset_n reset_n Input 1
        }
        
        # -- update connection points --
        if {($fifoInputInterfaceOptions=="AVALONMM_WRITE") && ($fifoOutputInterfaceOptions=="AVALONMM_READ")} {
          # Avalon write slave interface 
          add_interface in avalon slave
	  set_interface_property in addressAlignment {DYNAMIC}
	  set_interface_property in addressGroup {0}
	  set_interface_property in addressSpan {4}
	  set_interface_property in addressUnits {WORDS}
	  set_interface_property in alwaysBurstMaxBurst {0}
	  set_interface_property in associatedClock {clk_in}
	  set_interface_property in associatedReset {reset_in}
	  set_interface_property in bitsPerSymbol {8}
	  set_interface_property in burstOnBurstBoundariesOnly {0}
	  set_interface_property in burstcountUnits {WORDS}
	  set_interface_property in constantBurstBehavior {0}
	  set_interface_property in explicitAddressSpan {0}
	  set_interface_property in holdTime {0}
	  set_interface_property in interleaveBursts {0}
	  set_interface_property in isBigEndian {0}
	  set_interface_property in isFlash {0}
	  set_interface_property in isMemoryDevice {0}
	  set_interface_property in isNonVolatileStorage {0}
	  set_interface_property in linewrapBursts {0}
	  set_interface_property in maximumPendingReadTransactions {0}
	  set_interface_property in minimumUninterruptedRunLength {1}
	  set_interface_property in printableDevice {0}
	  set_interface_property in readLatency {0}
	  set_interface_property in readWaitStates {1}
	  set_interface_property in readWaitTime {1}
	  set_interface_property in registerIncomingSignals {0}
	  set_interface_property in registerOutgoingSignals {0}
	  set_interface_property in setupTime {0}
	  set_interface_property in timingUnits {Cycles}
	  set_interface_property in transparentBridge {0}
	  set_interface_property in wellBehavedWaitrequest {0}
	  set_interface_property in writeLatency {0}
	  set_interface_property in writeWaitStates {0}
	  set_interface_property in writeWaitTime {0}
          
	  add_interface_port in avalonmm_write_slave_writedata writedata Input $avalonMMAvalonMMDataWidth
	  add_interface_port in avalonmm_write_slave_write write Input 1
	  
	  set_interface_assignment in embeddedsw.configuration.isFlash {0}
	  set_interface_assignment in embeddedsw.configuration.isMemoryDevice {0}
	  set_interface_assignment in embeddedsw.configuration.isNonVolatileStorage {0}
	  set_interface_assignment in embeddedsw.configuration.isPrintableDevice {0}	
          
	  # Avalon read slave interface 
	  add_interface out avalon slave
	  set_interface_property out addressAlignment {DYNAMIC}
	  set_interface_property out addressGroup {0}
	  set_interface_property out addressSpan {4}
	  set_interface_property out addressUnits {WORDS}
	  set_interface_property out alwaysBurstMaxBurst {0}
	  if { $singleClockMode } {
	  set_interface_property out associatedClock {clk_in}
	  set_interface_property out associatedReset {reset_in}
	  } else {
	  set_interface_property out associatedClock {clk_out}
	  set_interface_property out associatedReset {reset_out}	  
	  }
	  set_interface_property out bitsPerSymbol {8}
	  set_interface_property out burstOnBurstBoundariesOnly {0}
	  set_interface_property out burstcountUnits {WORDS}
	  set_interface_property out constantBurstBehavior {0}
	  set_interface_property out explicitAddressSpan {0}
	  set_interface_property out holdTime {0}
	  set_interface_property out interleaveBursts {0}
	  set_interface_property out isBigEndian {0}
	  set_interface_property out isFlash {0}
	  set_interface_property out isMemoryDevice {0}
	  set_interface_property out isNonVolatileStorage {0}
	  set_interface_property out linewrapBursts {0}
	  set_interface_property out maximumPendingReadTransactions {0}
	  set_interface_property out minimumUninterruptedRunLength {1}
	  set_interface_property out printableDevice {0}
	  set_interface_property out readLatency {1}
	  set_interface_property out readWaitStates {0}
	  set_interface_property out readWaitTime {0}
	  set_interface_property out registerIncomingSignals {0}
	  set_interface_property out registerOutgoingSignals {0}
	  set_interface_property out setupTime {0}
	  set_interface_property out timingUnits {Cycles}
	  set_interface_property out transparentBridge {0}
	  set_interface_property out wellBehavedWaitrequest {0}
	  set_interface_property out writeLatency {0}
	  set_interface_property out writeWaitStates {0}
	  set_interface_property out writeWaitTime {0}
          
	  add_interface_port out avalonmm_read_slave_readdata readdata Output $avalonMMAvalonMMDataWidth
	  add_interface_port out avalonmm_read_slave_read read Input 1
	  
	  set_interface_assignment out embeddedsw.configuration.isFlash {0}
	  set_interface_assignment out embeddedsw.configuration.isMemoryDevice {0}
	  set_interface_assignment out embeddedsw.configuration.isNonVolatileStorage {0}
	  set_interface_assignment out embeddedsw.configuration.isPrintableDevice {0} 
	  
	  # Add ports for back pressure
	  if { $useBackpressure } {
	    add_interface_port in avalonmm_write_slave_waitrequest waitrequest Output 1
            add_interface_port out avalonmm_read_slave_waitrequest waitrequest Output 1  
	  }	  
	  
        } elseif {($fifoInputInterfaceOptions=="AVALONMM_WRITE") && ($fifoOutputInterfaceOptions=="AVALONST_SOURCE")} {
          # Avalon write slave interface 
          add_interface in avalon slave
	  set_interface_property in addressAlignment {DYNAMIC}
	  set_interface_property in addressGroup {0}
	  set_interface_property in addressSpan {8}
	  set_interface_property in addressUnits {WORDS}
	  set_interface_property in alwaysBurstMaxBurst {0}
	  set_interface_property in associatedClock {clk_in}
	  set_interface_property in associatedReset {reset_in}
	  set_interface_property in bitsPerSymbol {8}
	  set_interface_property in burstOnBurstBoundariesOnly {0}
	  set_interface_property in burstcountUnits {WORDS}
	  set_interface_property in constantBurstBehavior {0}
	  set_interface_property in explicitAddressSpan {0}
	  set_interface_property in holdTime {0}
	  set_interface_property in interleaveBursts {0}
	  set_interface_property in isBigEndian {0}
	  set_interface_property in isFlash {0}
	  set_interface_property in isMemoryDevice {0}
	  set_interface_property in isNonVolatileStorage {0}
	  set_interface_property in linewrapBursts {0}
	  set_interface_property in maximumPendingReadTransactions {0}
	  set_interface_property in minimumUninterruptedRunLength {1}
	  set_interface_property in printableDevice {0}
	  set_interface_property in readLatency {0}
	  set_interface_property in readWaitStates {1}
	  set_interface_property in readWaitTime {1}
	  set_interface_property in registerIncomingSignals {0}
	  set_interface_property in registerOutgoingSignals {0}
	  set_interface_property in setupTime {0}
	  set_interface_property in timingUnits {Cycles}
	  set_interface_property in transparentBridge {0}
	  set_interface_property in wellBehavedWaitrequest {0}
	  set_interface_property in writeLatency {0}
	  set_interface_property in writeWaitStates {0}
	  set_interface_property in writeWaitTime {0}
          
	  add_interface_port in avalonmm_write_slave_writedata writedata Input $avalonMMAvalonSTDataWidth
	  add_interface_port in avalonmm_write_slave_write write Input 1
	  add_interface_port in avalonmm_write_slave_address address Input 1
	  
	  set_interface_assignment in embeddedsw.configuration.isFlash {0}
	  set_interface_assignment in embeddedsw.configuration.isMemoryDevice {0}
	  set_interface_assignment in embeddedsw.configuration.isNonVolatileStorage {0}
	  set_interface_assignment in embeddedsw.configuration.isPrintableDevice {0}
	  
	  # Source Interface
	  add_interface out avalon_streaming source
	  if { $singleClockMode } {
	  set_interface_property out associatedClock {clk_in}
	  set_interface_property out associatedReset {reset_in}
	  } else {
	  set_interface_property out associatedClock {clk_out}
	  set_interface_property out associatedReset {reset_out}	  
	  }
	  set_interface_property out beatsPerCycle {1}
	  set_interface_property out dataBitsPerSymbol $bitsPerSymbol
	  set_interface_property out emptyWithinPacket {0}
	  set_interface_property out firstSymbolInHighOrderBits {1}
	  set_interface_property out highOrderSymbolAtMSB {0}
	  set_interface_property out maxChannel [ expr int(pow(2,$channelWidth)) - 1 ] 
	  set_interface_property out readyLatency {0}
	  set_interface_property out symbolsPerBeat $symbolsPerBeat
          
	  add_interface_port out avalonst_source_valid valid Output 1
	  add_interface_port out avalonst_source_data data Output $derived_sink_source_avalonST_width
	  if { [ expr $channelWidth !=0 ] } {
	      add_interface_port out avalonst_source_channel channel Output $channelWidth
	  }
	  if { [ expr $errorWidth !=0 ] } {
	      add_interface_port out avalonst_source_error error Output $errorWidth
	  }
	  
	    if { $usePacket } {
	      add_interface_port out avalonst_source_startofpacket startofpacket Output 1
	      add_interface_port out avalonst_source_endofpacket endofpacket Output 1
	        if { $empty_width > 0 } {
	          add_interface_port out avalonst_source_empty empty Output $empty_width    
	        }       
	    }
	  
	    if { $useBackpressure } {
	      add_interface_port in avalonmm_write_slave_waitrequest waitrequest Output 1
              add_interface_port out avalonst_source_ready ready Input 1 
              set_interface_property out readyLatency {1}
	    }

        } elseif {($fifoInputInterfaceOptions=="AVALONST_SINK") && ($fifoOutputInterfaceOptions=="AVALONMM_READ")} {
	  # Sink Interface 
	  add_interface in avalon_streaming sink
	  set_interface_property in associatedClock {clk_in}
	  set_interface_property in associatedReset {reset_in}
	  set_interface_property in beatsPerCycle {1}
	  set_interface_property in dataBitsPerSymbol $bitsPerSymbol
	  set_interface_property in emptyWithinPacket {0}
	  set_interface_property in firstSymbolInHighOrderBits {1}
	  set_interface_property in highOrderSymbolAtMSB {0}
	  set_interface_property in maxChannel [ expr int(pow(2,$channelWidth)) - 1 ] 
	  set_interface_property in readyLatency {0}
	  set_interface_property in symbolsPerBeat $symbolsPerBeat
          
	  add_interface_port in avalonst_sink_valid valid Input 1
	  add_interface_port in avalonst_sink_data data Input $derived_sink_source_avalonST_width
	  if { [ expr $channelWidth !=0 ] } {
	      add_interface_port in avalonst_sink_channel channel Input $channelWidth
	  }
	  if { [ expr $errorWidth !=0 ] } {
	      add_interface_port in avalonst_sink_error error Input $errorWidth
	  }
	  
	  # Avalon read slave interface 
	  add_interface out avalon slave
	  set_interface_property out addressAlignment {DYNAMIC}
	  set_interface_property out addressGroup {0}
	  set_interface_property out addressSpan {8}
	  set_interface_property out addressUnits {WORDS}
	  set_interface_property out alwaysBurstMaxBurst {0}
	  if { $singleClockMode } {
	  set_interface_property out associatedClock {clk_in}
	  set_interface_property out associatedReset {reset_in}
	  } else {
	  set_interface_property out associatedClock {clk_out}                                        
	  set_interface_property out associatedReset {reset_out}	  
	  }
	  set_interface_property out bitsPerSymbol {8}
	  set_interface_property out burstOnBurstBoundariesOnly {0}
	  set_interface_property out burstcountUnits {WORDS}
	  set_interface_property out constantBurstBehavior {0}
	  set_interface_property out explicitAddressSpan {0}
	  set_interface_property out holdTime {0}
	  set_interface_property out interleaveBursts {0}
	  set_interface_property out isBigEndian {0}
	  set_interface_property out isFlash {0}
	  set_interface_property out isMemoryDevice {0}
	  set_interface_property out isNonVolatileStorage {0}
	  set_interface_property out linewrapBursts {0}
	  set_interface_property out maximumPendingReadTransactions {0}
	  set_interface_property out minimumUninterruptedRunLength {1}
	  set_interface_property out printableDevice {0}
	  set_interface_property out readLatency {1}
	  set_interface_property out readWaitStates {0}
	  set_interface_property out readWaitTime {0}
	  set_interface_property out registerIncomingSignals {0}
	  set_interface_property out registerOutgoingSignals {0}
	  set_interface_property out setupTime {0}
	  set_interface_property out timingUnits {Cycles}
	  set_interface_property out transparentBridge {0}
	  set_interface_property out wellBehavedWaitrequest {0}
	  set_interface_property out writeLatency {0}
	  set_interface_property out writeWaitStates {0}
	  set_interface_property out writeWaitTime {0}
          
	  add_interface_port out avalonmm_read_slave_readdata readdata Output $avalonMMAvalonSTDataWidth
	  add_interface_port out avalonmm_read_slave_read read Input 1
	  add_interface_port out avalonmm_read_slave_address address Input 1
	  
	  set_interface_assignment out embeddedsw.configuration.isFlash {0}
	  set_interface_assignment out embeddedsw.configuration.isMemoryDevice {0}
	  set_interface_assignment out embeddedsw.configuration.isNonVolatileStorage {0}
	  set_interface_assignment out embeddedsw.configuration.isPrintableDevice {0} 
	  
	  if { $usePacket } {
	    add_interface_port in avalonst_sink_startofpacket startofpacket Input 1
	    add_interface_port in avalonst_sink_endofpacket endofpacket Input 1
	      if { $empty_width > 0 } {
	        add_interface_port in avalonst_sink_empty empty Input $empty_width      
	      }	      
	  }	  
	  
	  if { $useBackpressure } {
	    add_interface_port out avalonmm_read_slave_waitrequest waitrequest Output 1
            add_interface_port in avalonst_sink_ready ready Output 1
            set_interface_property in readyLatency {1}  
	  }	  
	  	  	  
        } else {
          # Sink Interface 
	  add_interface in avalon_streaming sink
	  set_interface_property in associatedClock {clk_in}
	  set_interface_property in associatedReset {reset_in}
	  set_interface_property in beatsPerCycle {1}
	  set_interface_property in dataBitsPerSymbol $bitsPerSymbol
	  set_interface_property in emptyWithinPacket {0}
	  set_interface_property in firstSymbolInHighOrderBits {1}
	  set_interface_property in highOrderSymbolAtMSB {0}
	  set_interface_property in maxChannel [ expr int(pow(2,$channelWidth)) - 1 ] 
	  set_interface_property in readyLatency {0}
	  set_interface_property in symbolsPerBeat $symbolsPerBeat
          
	  add_interface_port in avalonst_sink_valid valid Input 1
	  add_interface_port in avalonst_sink_data data Input $derived_sink_source_avalonST_width
	  if { [ expr $channelWidth !=0 ] } {
	      add_interface_port in avalonst_sink_channel channel Input $channelWidth
	  }
	  if { [ expr $errorWidth !=0 ] } {
	      add_interface_port in avalonst_sink_error error Input $errorWidth
	  }
	  
	  if { $usePacket } {
	    add_interface_port in avalonst_sink_startofpacket startofpacket Input 1
	    add_interface_port in avalonst_sink_endofpacket endofpacket Input 1
	      if { $empty_width > 0 } {                                       
	        add_interface_port in avalonst_sink_empty empty Input $empty_width      
	      }	      
	  }	  
	  
	  if { $useBackpressure } {
            add_interface_port in avalonst_sink_ready ready Output 1
            set_interface_property in readyLatency {1}  
	  }
	  
	  # Source Interface
	  add_interface out avalon_streaming source
	  if { $singleClockMode } {
	  set_interface_property out associatedClock {clk_in}
	  set_interface_property out associatedReset {reset_in}
	  } else {
	  set_interface_property out associatedClock {clk_out}
	  set_interface_property out associatedReset {reset_out}	  
	  }
	  set_interface_property out beatsPerCycle {1}
	  set_interface_property out dataBitsPerSymbol $bitsPerSymbol
	  set_interface_property out emptyWithinPacket {0}
	  set_interface_property out firstSymbolInHighOrderBits {1}
	  set_interface_property out highOrderSymbolAtMSB {0}
	  set_interface_property out maxChannel [ expr int(pow(2,$channelWidth)) - 1 ] 
	  set_interface_property out readyLatency {0}
	  set_interface_property out symbolsPerBeat $symbolsPerBeat
          
	  add_interface_port out avalonst_source_valid valid Output 1
	  add_interface_port out avalonst_source_data data Output $derived_sink_source_avalonST_width
	  if { [ expr $channelWidth !=0 ] } {
	      add_interface_port out avalonst_source_channel channel Output $channelWidth
	  }
	  if { [ expr $errorWidth !=0 ] } {
	      add_interface_port out avalonst_source_error error Output $errorWidth
	  }
	  
	    if { $usePacket } {
	      add_interface_port out avalonst_source_startofpacket startofpacket Output 1
	      add_interface_port out avalonst_source_endofpacket endofpacket Output 1
	        if { $empty_width > 0 } {
	          add_interface_port out avalonst_source_empty empty Output $empty_width    
	        }       
	    }
	  
	    if { $useBackpressure } {
              add_interface_port out avalonst_source_ready ready Input 1 
              set_interface_property out readyLatency {1}
	    }
        	
        }
        
        # Read Control Slave is enabled                          
        if { $useReadControl } {
          add_interface out_csr avalon slave
	  set_interface_property out_csr addressAlignment {DYNAMIC}
	  set_interface_property out_csr addressGroup {0}
	  set_interface_property out_csr addressSpan {32}
	  set_interface_property out_csr addressUnits {WORDS}
	  set_interface_property out_csr alwaysBurstMaxBurst {0}
	  if { $singleClockMode } {
	  set_interface_property out_csr associatedClock {clk_in}
	  set_interface_property out_csr associatedReset {reset_in}
	  } else {
	  set_interface_property out_csr associatedClock {clk_out}
	  set_interface_property out_csr associatedReset {reset_out}	  
	  }
	  set_interface_property out_csr bitsPerSymbol {8}
	  set_interface_property out_csr burstOnBurstBoundariesOnly {0}
	  set_interface_property out_csr burstcountUnits {WORDS}
	  set_interface_property out_csr constantBurstBehavior {0}
	  set_interface_property out_csr explicitAddressSpan {0}
	  set_interface_property out_csr holdTime {0}
	  set_interface_property out_csr interleaveBursts {0}
	  set_interface_property out_csr isBigEndian {0}
	  set_interface_property out_csr isFlash {0}
	  set_interface_property out_csr isMemoryDevice {0}
	  set_interface_property out_csr isNonVolatileStorage {0}
	  set_interface_property out_csr linewrapBursts {0}
	  set_interface_property out_csr maximumPendingReadTransactions {0}
	  set_interface_property out_csr minimumUninterruptedRunLength {1}
	  set_interface_property out_csr printableDevice {0}
	  set_interface_property out_csr readLatency {0}
	  set_interface_property out_csr readWaitStates {1}
	  set_interface_property out_csr readWaitTime {1}
	  set_interface_property out_csr registerIncomingSignals {0}
	  set_interface_property out_csr registerOutgoingSignals {0}
	  set_interface_property out_csr setupTime {0}
	  set_interface_property out_csr timingUnits {Cycles}
	  set_interface_property out_csr transparentBridge {0}
	  set_interface_property out_csr wellBehavedWaitrequest {0}
	  set_interface_property out_csr writeLatency {0}
	  set_interface_property out_csr writeWaitStates {0}
	  set_interface_property out_csr writeWaitTime {0}
          
	  add_interface_port out_csr rdclk_control_slave_address address Input 3
	  add_interface_port out_csr rdclk_control_slave_read read Input 1
	  add_interface_port out_csr rdclk_control_slave_writedata writedata Input 32
	  add_interface_port out_csr rdclk_control_slave_write write Input 1
	  add_interface_port out_csr rdclk_control_slave_readdata readdata Output 32
          
	  set_interface_assignment out_csr embeddedsw.configuration.isFlash {0}
	  set_interface_assignment out_csr embeddedsw.configuration.isMemoryDevice {0}
	  set_interface_assignment out_csr embeddedsw.configuration.isNonVolatileStorage {0}
	  set_interface_assignment out_csr embeddedsw.configuration.isPrintableDevice {0} 
	  
	    # if use IRQ for read control slave
	    if { $useIRQ } {
	      add_interface out_irq interrupt sender
	      set_interface_property out_irq associatedAddressablePoint {out_csr}
	      set_interface_property out_irq irqScheme {NONE}
	      add_interface_port out_irq rdclk_control_slave_irq irq Output 1    
	    }
        }

        # Write Control Slave is enabled
        if { $useWriteControl } {
          add_interface in_csr avalon slave
	  set_interface_property in_csr addressAlignment {DYNAMIC}
	  set_interface_property in_csr addressGroup {0}
	  set_interface_property in_csr addressSpan {32}
	  set_interface_property in_csr addressUnits {WORDS}
	  set_interface_property in_csr alwaysBurstMaxBurst {0}
	  set_interface_property in_csr associatedClock {clk_in}
	  set_interface_property in_csr associatedReset {reset_in}
	  set_interface_property in_csr bitsPerSymbol {8}
	  set_interface_property in_csr burstOnBurstBoundariesOnly {0}
	  set_interface_property in_csr burstcountUnits {WORDS}
	  set_interface_property in_csr constantBurstBehavior {0}
	  set_interface_property in_csr explicitAddressSpan {0}
	  set_interface_property in_csr holdTime {0}
	  set_interface_property in_csr interleaveBursts {0}
	  set_interface_property in_csr isBigEndian {0}
	  set_interface_property in_csr isFlash {0}
	  set_interface_property in_csr isMemoryDevice {0}
	  set_interface_property in_csr isNonVolatileStorage {0}
	  set_interface_property in_csr linewrapBursts {0}
	  set_interface_property in_csr maximumPendingReadTransactions {0}
	  set_interface_property in_csr minimumUninterruptedRunLength {1}
	  set_interface_property in_csr printableDevice {0}
	  set_interface_property in_csr readLatency {0}
	  set_interface_property in_csr readWaitStates {1}
	  set_interface_property in_csr readWaitTime {1}
	  set_interface_property in_csr registerIncomingSignals {0}
	  set_interface_property in_csr registerOutgoingSignals {0}
	  set_interface_property in_csr setupTime {0}
	  set_interface_property in_csr timingUnits {Cycles}
	  set_interface_property in_csr transparentBridge {0}
	  set_interface_property in_csr wellBehavedWaitrequest {0}
	  set_interface_property in_csr writeLatency {0}
	  set_interface_property in_csr writeWaitStates {0}
	  set_interface_property in_csr writeWaitTime {0}
          
	  add_interface_port in_csr wrclk_control_slave_address address Input 3
	  add_interface_port in_csr wrclk_control_slave_read read Input 1
	  add_interface_port in_csr wrclk_control_slave_writedata writedata Input 32
	  add_interface_port in_csr wrclk_control_slave_write write Input 1
	  add_interface_port in_csr wrclk_control_slave_readdata readdata Output 32
          
	  set_interface_assignment in_csr embeddedsw.configuration.isFlash {0}
	  set_interface_assignment in_csr embeddedsw.configuration.isMemoryDevice {0}
	  set_interface_assignment in_csr embeddedsw.configuration.isNonVolatileStorage {0}
	  set_interface_assignment in_csr embeddedsw.configuration.isPrintableDevice {0} 
	  
	    # if use IRQ for write control slave 
	    if { $useIRQ } {
	      add_interface in_irq interrupt sender
	      set_interface_property in_irq associatedAddressablePoint {in_csr}
	      set_interface_property in_irq irqScheme {NONE}
	      add_interface_port in_irq wrclk_control_slave_irq irq Output 1	    
	    }
        }
       
        # update derived parameter
        set_parameter_value derived_sink_source_avalonST_width $derived_sink_source_avalonST_width 
}

#-------------------------------------------------------------------------------
# module generation
#-------------------------------------------------------------------------------

# generate
proc generate {output_name output_directory rtl_ext simgen} {
	global env
	set QUARTUS_ROOTDIR         "$env(QUARTUS_ROOTDIR)"
	set component_directory     "$QUARTUS_ROOTDIR/../ip/altera/sopc_builder_ip/altera_avalon_fifo"
	set component_config_file   "$output_directory/${output_name}_component_configuration.pl"

	# read parameter

	set avalonMMAvalonMMDataWidth [ get_parameter_value avalonMMAvalonMMDataWidth ]
	set avalonMMAvalonSTDataWidth [ get_parameter_value avalonMMAvalonSTDataWidth ]
	set bitsPerSymbol [ get_parameter_value bitsPerSymbol ]
	set channelWidth [ get_parameter_value channelWidth ]
	set deviceFamilyString [ get_parameter_value deviceFamilyString ]
	set errorWidth [ get_parameter_value errorWidth ]
	set fifoDepth [ get_parameter_value fifoDepth ]
	set fifoInputInterfaceOptions [ get_parameter_value fifoInputInterfaceOptions ]
	set fifoOutputInterfaceOptions [ get_parameter_value fifoOutputInterfaceOptions ]
	set showHiddenFeatures [ proc_get_boolean_parameter showHiddenFeatures ]
	set singleClockMode [ proc_get_boolean_parameter singleClockMode ]
	set singleResetMode [ proc_get_boolean_parameter singleResetMode ]
	set symbolsPerBeat [ get_parameter_value symbolsPerBeat ]
	set useBackpressure [ proc_get_boolean_parameter useBackpressure ]
	set useIRQ [ proc_get_boolean_parameter useIRQ ]
	set usePacket [ proc_get_boolean_parameter usePacket ]
	set useReadControl [ proc_get_boolean_parameter useReadControl ]
	set useRegister [ proc_get_boolean_parameter useRegister ]
	set useWriteControl [ proc_get_boolean_parameter useWriteControl ]

	#update derived parameter 
	set derived_device_family [ string2upper_noSpace "$deviceFamilyString" ]
	
	# prepare config file
	set component_config    [open $component_config_file "w"]

	puts $component_config "# ${output_name} Component Configuration File"
	puts $component_config "return {"

	puts $component_config "\tDevice_Family		=> $derived_device_family,"
	puts $component_config "\tUse_Register		=> $useRegister,"
	puts $component_config "\tSingle_Clock_Mode	=> $singleClockMode,"
	puts $component_config "\tFIFO_Depth		=> $fifoDepth,"
	puts $component_config "\tUse_Write_Control	=> $useWriteControl,"
	puts $component_config "\tUse_Read_Control	=> $useReadControl,"
	puts $component_config "\tUse_IRQ		=> $useIRQ,"
	
	if {($fifoInputInterfaceOptions=="AVALONMM_WRITE") && ($fifoOutputInterfaceOptions=="AVALONMM_READ")} {
	puts $component_config "\tUse_AvalonMM_Write_Slave	=> 1,"
	puts $component_config "\tUse_AvalonMM_Read_Slave	=> 1,"
	puts $component_config "\tUse_AvalonST_Sink		=> 0,"
	puts $component_config "\tUse_AvalonST_Source		=> 0,"
	
	} elseif {($fifoInputInterfaceOptions=="AVALONMM_WRITE") && ($fifoOutputInterfaceOptions=="AVALONST_SOURCE")} {	
	puts $component_config "\tUse_AvalonMM_Write_Slave	=> 1,"
	puts $component_config "\tUse_AvalonMM_Read_Slave	=> 0,"
	puts $component_config "\tUse_AvalonST_Sink		=> 0,"
	puts $component_config "\tUse_AvalonST_Source		=> 1,"
	
	} elseif {($fifoInputInterfaceOptions=="AVALONST_SINK") && ($fifoOutputInterfaceOptions=="AVALONMM_READ")} {
	puts $component_config "\tUse_AvalonMM_Write_Slave	=> 0,"
	puts $component_config "\tUse_AvalonMM_Read_Slave	=> 1,"
	puts $component_config "\tUse_AvalonST_Sink		=> 1,"
	puts $component_config "\tUse_AvalonST_Source		=> 0,"
	
	} else {  
	puts $component_config "\tUse_AvalonMM_Write_Slave	=> 0,"
	puts $component_config "\tUse_AvalonMM_Read_Slave	=> 0,"
	puts $component_config "\tUse_AvalonST_Sink		=> 1,"
	puts $component_config "\tUse_AvalonST_Source		=> 1,"
	}
	
	puts $component_config "\tUse_Backpressure		=> $useBackpressure,"
	puts $component_config "\tAvalonMM_AvalonMM_Data_Width	=> $avalonMMAvalonMMDataWidth,"
	puts $component_config "\tBits_Per_Symbol		=> $bitsPerSymbol,"
	puts $component_config "\tSymbols_Per_Beat		=> $symbolsPerBeat,"
	puts $component_config "\tAvalonMM_AvalonST_Data_Width	=> $avalonMMAvalonSTDataWidth,"
	puts $component_config "\tError_Width			=> $errorWidth,"
	puts $component_config "\tChannel_Width			=> $channelWidth,"
	puts $component_config "\tUse_Packet			=> $usePacket,"

	puts $component_config "};"
	close $component_config

	# generate rtl
	proc_generate_component_rtl  "$component_config_file" "$component_directory" "$output_name" "$output_directory" "$rtl_ext" "$simgen"
	proc_add_generated_files "$output_name" "$output_directory" "$rtl_ext" "$simgen"
}

