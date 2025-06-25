package require -exact qsys 13.1
source $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/common/embedded_ip_hwtcl_common.tcl

#-------------------------------------------------------------------------------
# module properties
#-------------------------------------------------------------------------------

set_module_property NAME {altera_avalon_dma}
set_module_property DISPLAY_NAME {DMA Controller}
set_module_property VERSION {13.1}
set_module_property GROUP {Bridges and Adapters/DMA}
set_module_property AUTHOR {Altera Corporation}
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property INTERNAL false
set_module_property HIDE_FROM_SOPC true
set_module_property EDITABLE true
set_module_property VALIDATION_CALLBACK validate
set_module_property ELABORATION_CALLBACK elaborate

# generation fileset

add_fileset quartus_synth QUARTUS_SYNTH sub_quartus_synth_dma
add_fileset sim_verilog SIM_VERILOG sub_sim_verilog_dma
add_fileset sim_vhdl SIM_VHDL sub_sim_vhdl_dma

# links to documentation

add_documentation_link {Data Sheet} {http://www.altera.com/literature/hb/nios2/n2cpu_nii51006.pdf}

#-------------------------------------------------------------------------------
# module parameters
#-------------------------------------------------------------------------------

# parameters

add_parameter allowByteTransactions BOOLEAN
set_parameter_property allowByteTransactions DEFAULT_VALUE {true}
set_parameter_property allowByteTransactions DISPLAY_NAME {byte}
set_parameter_property allowByteTransactions AFFECTS_GENERATION {1}
set_parameter_property allowByteTransactions HDL_PARAMETER {0}

add_parameter allowDoubleWordTransactions BOOLEAN
set_parameter_property allowDoubleWordTransactions DEFAULT_VALUE {true}
set_parameter_property allowDoubleWordTransactions DISPLAY_NAME {doubleword}
set_parameter_property allowDoubleWordTransactions AFFECTS_GENERATION {1}
set_parameter_property allowDoubleWordTransactions HDL_PARAMETER {0}

add_parameter allowHalfWordTransactions BOOLEAN
set_parameter_property allowHalfWordTransactions DEFAULT_VALUE {true}
set_parameter_property allowHalfWordTransactions DISPLAY_NAME {halfword}
set_parameter_property allowHalfWordTransactions AFFECTS_GENERATION {1}
set_parameter_property allowHalfWordTransactions HDL_PARAMETER {0}

add_parameter allowQuadWordTransactions BOOLEAN
set_parameter_property allowQuadWordTransactions DEFAULT_VALUE {true}
set_parameter_property allowQuadWordTransactions DISPLAY_NAME {quadword}
set_parameter_property allowQuadWordTransactions AFFECTS_GENERATION {1}
set_parameter_property allowQuadWordTransactions HDL_PARAMETER {0}

add_parameter allowWordTransactions BOOLEAN
set_parameter_property allowWordTransactions DEFAULT_VALUE {true}
set_parameter_property allowWordTransactions DISPLAY_NAME {word}
set_parameter_property allowWordTransactions AFFECTS_GENERATION {1}
set_parameter_property allowWordTransactions HDL_PARAMETER {0}

add_parameter bigEndian BOOLEAN
set_parameter_property bigEndian DEFAULT_VALUE {false}
set_parameter_property bigEndian DISPLAY_NAME {bigEndian}
set_parameter_property bigEndian VISIBLE {0}
set_parameter_property bigEndian AFFECTS_GENERATION {1}
set_parameter_property bigEndian HDL_PARAMETER {0}

add_parameter burstEnable BOOLEAN
set_parameter_property burstEnable DEFAULT_VALUE {false}
set_parameter_property burstEnable DISPLAY_NAME {Enable burst transfers}
set_parameter_property burstEnable AFFECTS_GENERATION {1}
set_parameter_property burstEnable HDL_PARAMETER {0}

add_parameter fifoDepth INTEGER
set_parameter_property fifoDepth DEFAULT_VALUE {32}
set_parameter_property fifoDepth DISPLAY_NAME {Data transfer FIFO depth}
set_parameter_property fifoDepth ALLOWED_RANGES {4 8 16 32 64 128 256 512 1024 2048 4096}
set_parameter_property fifoDepth AFFECTS_GENERATION {1}
set_parameter_property fifoDepth HDL_PARAMETER {0}

add_parameter maxBurstSize INTEGER
set_parameter_property maxBurstSize DEFAULT_VALUE {128}
set_parameter_property maxBurstSize DISPLAY_NAME {Maximum burst size (words)}
set_parameter_property maxBurstSize ALLOWED_RANGES {1 2 4 8 16 32 64 128 256 512 1024}
set_parameter_property maxBurstSize AFFECTS_GENERATION {1}
set_parameter_property maxBurstSize HDL_PARAMETER {0}

add_parameter minimumDmaTransactionRegisterWidth INTEGER
set_parameter_property minimumDmaTransactionRegisterWidth DEFAULT_VALUE {13}
set_parameter_property minimumDmaTransactionRegisterWidth DISPLAY_NAME {Width of the DMA length register (1-32) (bits)}
set_parameter_property minimumDmaTransactionRegisterWidth ALLOWED_RANGES {1:32}
set_parameter_property minimumDmaTransactionRegisterWidth AFFECTS_GENERATION {1}
set_parameter_property minimumDmaTransactionRegisterWidth HDL_PARAMETER {0}

add_parameter useRegistersForFIFO BOOLEAN
set_parameter_property useRegistersForFIFO DEFAULT_VALUE {false}
set_parameter_property useRegistersForFIFO DISPLAY_NAME {Construct FIFO from registers}
set_parameter_property useRegistersForFIFO AFFECTS_GENERATION {1}
set_parameter_property useRegistersForFIFO HDL_PARAMETER {0}

# system info parameters

add_parameter avalonSpec STRING
set_parameter_property avalonSpec DISPLAY_NAME {avalonSpec}
set_parameter_property avalonSpec VISIBLE {0}
set_parameter_property avalonSpec AFFECTS_GENERATION {1}
set_parameter_property avalonSpec HDL_PARAMETER {0}
set_parameter_property avalonSpec SYSTEM_INFO {avalon_spec}
set_parameter_property avalonSpec SYSTEM_INFO_TYPE {AVALON_SPEC}

add_parameter readAddressMap STRING
set_parameter_property readAddressMap DISPLAY_NAME {readAddressMap}
set_parameter_property readAddressMap AFFECTS_GENERATION {1}
set_parameter_property readAddressMap HDL_PARAMETER {0}
set_parameter_property readAddressMap SYSTEM_INFO {address_map read_master}
set_parameter_property readAddressMap SYSTEM_INFO_TYPE {ADDRESS_MAP}
set_parameter_property readAddressMap SYSTEM_INFO_ARG {read_master}

add_parameter readSlaveAddressWidthMax INTEGER
set_parameter_property readSlaveAddressWidthMax DEFAULT_VALUE {0}
set_parameter_property readSlaveAddressWidthMax DISPLAY_NAME {readSlaveAddressWidthMax}
set_parameter_property readSlaveAddressWidthMax AFFECTS_GENERATION {1}
set_parameter_property readSlaveAddressWidthMax HDL_PARAMETER {0}
set_parameter_property readSlaveAddressWidthMax SYSTEM_INFO {address_width read_master}
set_parameter_property readSlaveAddressWidthMax SYSTEM_INFO_TYPE {ADDRESS_WIDTH}
set_parameter_property readSlaveAddressWidthMax SYSTEM_INFO_ARG {read_master}

add_parameter readSlaveDataWidthMax INTEGER
set_parameter_property readSlaveDataWidthMax DEFAULT_VALUE {16}
set_parameter_property readSlaveDataWidthMax DISPLAY_NAME {readSlaveDataWidthMax}
set_parameter_property readSlaveDataWidthMax AFFECTS_GENERATION {1}
set_parameter_property readSlaveDataWidthMax HDL_PARAMETER {0}
set_parameter_property readSlaveDataWidthMax SYSTEM_INFO {max_slave_data_width read_master}
set_parameter_property readSlaveDataWidthMax SYSTEM_INFO_TYPE {MAX_SLAVE_DATA_WIDTH}
set_parameter_property readSlaveDataWidthMax SYSTEM_INFO_ARG {read_master}

add_parameter writeAddressMap STRING
set_parameter_property writeAddressMap DISPLAY_NAME {writeAddressMap}
set_parameter_property writeAddressMap AFFECTS_GENERATION {1}
set_parameter_property writeAddressMap HDL_PARAMETER {0}
set_parameter_property writeAddressMap SYSTEM_INFO {address_map write_master}
set_parameter_property writeAddressMap SYSTEM_INFO_TYPE {ADDRESS_MAP}
set_parameter_property writeAddressMap SYSTEM_INFO_ARG {write_master}

add_parameter writeSlaveAddressWidthMax INTEGER
set_parameter_property writeSlaveAddressWidthMax DEFAULT_VALUE {0}
set_parameter_property writeSlaveAddressWidthMax DISPLAY_NAME {writeSlaveAddressWidthMax}
set_parameter_property writeSlaveAddressWidthMax AFFECTS_GENERATION {1}
set_parameter_property writeSlaveAddressWidthMax HDL_PARAMETER {0}
set_parameter_property writeSlaveAddressWidthMax SYSTEM_INFO {address_width write_master}
set_parameter_property writeSlaveAddressWidthMax SYSTEM_INFO_TYPE {ADDRESS_WIDTH}
set_parameter_property writeSlaveAddressWidthMax SYSTEM_INFO_ARG {write_master}

add_parameter writeSlaveDataWidthMax INTEGER
set_parameter_property writeSlaveDataWidthMax DEFAULT_VALUE {16}
set_parameter_property writeSlaveDataWidthMax DISPLAY_NAME {writeSlaveDataWidthMax}
set_parameter_property writeSlaveDataWidthMax AFFECTS_GENERATION {1}
set_parameter_property writeSlaveDataWidthMax HDL_PARAMETER {0}
set_parameter_property writeSlaveDataWidthMax SYSTEM_INFO {max_slave_data_width write_master}
set_parameter_property writeSlaveDataWidthMax SYSTEM_INFO_TYPE {MAX_SLAVE_DATA_WIDTH}
set_parameter_property writeSlaveDataWidthMax SYSTEM_INFO_ARG {write_master}


# derived parameters

add_parameter actualDmaTransactionRegisterWidth INTEGER
set_parameter_property actualDmaTransactionRegisterWidth DEFAULT_VALUE {16}
set_parameter_property actualDmaTransactionRegisterWidth DISPLAY_NAME {actualDmaTransactionRegisterWidth}
set_parameter_property actualDmaTransactionRegisterWidth DERIVED {1}
set_parameter_property actualDmaTransactionRegisterWidth AFFECTS_GENERATION {1}
set_parameter_property actualDmaTransactionRegisterWidth HDL_PARAMETER {0}

add_parameter allowLegacySignals BOOLEAN
set_parameter_property allowLegacySignals DEFAULT_VALUE {false}
set_parameter_property allowLegacySignals DISPLAY_NAME {allowLegacySignals}
set_parameter_property allowLegacySignals DERIVED {1}
set_parameter_property allowLegacySignals AFFECTS_GENERATION {1}
set_parameter_property allowLegacySignals HDL_PARAMETER {0}

add_parameter minimumNumberOfByteTransfers LONG
set_parameter_property minimumNumberOfByteTransfers DEFAULT_VALUE {0}
set_parameter_property minimumNumberOfByteTransfers DISPLAY_NAME {minimumNumberOfByteTransfers}
set_parameter_property minimumNumberOfByteTransfers DERIVED {1}
set_parameter_property minimumNumberOfByteTransfers AFFECTS_GENERATION {1}
set_parameter_property minimumNumberOfByteTransfers HDL_PARAMETER {0}

add_parameter readMaximumSlaveSpan LONG
set_parameter_property readMaximumSlaveSpan DEFAULT_VALUE {0}
set_parameter_property readMaximumSlaveSpan DISPLAY_NAME {readMaximumSlaveSpan}
set_parameter_property readMaximumSlaveSpan DERIVED {1}
set_parameter_property readMaximumSlaveSpan AFFECTS_GENERATION {1}
set_parameter_property readMaximumSlaveSpan HDL_PARAMETER {0}

add_parameter writeMaximumSlaveSpan LONG
set_parameter_property writeMaximumSlaveSpan DEFAULT_VALUE {0}
set_parameter_property writeMaximumSlaveSpan DISPLAY_NAME {writeMaximumSlaveSpan}
set_parameter_property writeMaximumSlaveSpan DERIVED {1}
set_parameter_property writeMaximumSlaveSpan AFFECTS_GENERATION {1}
set_parameter_property writeMaximumSlaveSpan HDL_PARAMETER {0}

#-------------------------------------------------------------------------------
# module GUI
#-------------------------------------------------------------------------------

# display group

# group parameter

add_display_item {} {DMA Parameters} GROUP tab

add_display_item {DMA Parameters} {Transfer size} GROUP
add_display_item {Transfer size} minimumDmaTransactionRegisterWidth PARAMETER
add_display_item {Transfer size} mindmatransactiondisplay TEXT ""

add_display_item {DMA Parameters} {Burst transactions} GROUP
add_display_item {Burst transactions} burstEnable PARAMETER
add_display_item {Burst transactions} maxBurstSize PARAMETER

add_display_item {DMA Parameters} {FIFO depth} GROUP
add_display_item {FIFO depth} fifoDepth PARAMETER
add_display_item {FIFO depth} fifo_depth TEXT "<html>Set the depth to at least twice the maximum read latency of the slave interface connected to the read master port of the DMA controller. <br> A depth that is too low reduces transfer throughput.</html>"

add_display_item {DMA Parameters} {FIFO implementation} GROUP
add_display_item {FIFO implementation} useRegistersForFIFO PARAMETER
add_display_item {FIFO implementation} fifo_impl TEXT "Enable to construct FIFO from register, else default to using embedded memory blocks."


add_display_item {} {Advanced} GROUP tab

add_display_item {Advanced} {Allowed transactions} GROUP
add_display_item {Allowed transactions} allowByteTransactions PARAMETER
add_display_item {Allowed transactions} allowHalfWordTransactions PARAMETER
add_display_item {Allowed transactions} allowWordTransactions PARAMETER
add_display_item {Allowed transactions} allowDoubleWordTransactions PARAMETER
add_display_item {Allowed transactions} allowQuadWordTransactions PARAMETER

set_parameter_property readAddressMap VISIBLE {false}
set_parameter_property readSlaveAddressWidthMax VISIBLE {false}
set_parameter_property readSlaveDataWidthMax VISIBLE {false}
set_parameter_property writeAddressMap VISIBLE {false}
set_parameter_property writeSlaveAddressWidthMax VISIBLE {false}
set_parameter_property writeSlaveDataWidthMax VISIBLE {false}
set_parameter_property allowLegacySignals VISIBLE {false}
set_parameter_property minimumNumberOfByteTransfers VISIBLE {false}
set_parameter_property readMaximumSlaveSpan VISIBLE {false}
set_parameter_property writeMaximumSlaveSpan VISIBLE {false}
set_parameter_property actualDmaTransactionRegisterWidth VISIBLE {false}

#-------------------------------------------------------------------------------
# module validation
#-------------------------------------------------------------------------------
proc proc_num2unsigned {NUMBER} {
    return [ format "%u" $NUMBER ]
}

proc proc_num2hex {NUMBER} {
    return [ format "0x%08x" $NUMBER ]
}

proc proc_decode_address_map {slave_map_param} {
    set address_map_xml [ get_parameter_value $slave_map_param ]
    return [ decode_address_map $address_map_xml ]
}

proc proc_get_address_map_slaves_name {slave_map_param} {
    set slaves_name [list]
    set address_map_dec [ proc_decode_address_map $slave_map_param]

    foreach slave_info $address_map_dec {
        array set slave_info_array $slave_info
        lappend slaves_name "$slave_info_array(name)"
    }

    foreach dup_check $slaves_name {
        set tmp($dup_check) 1
    }
    set slaves_name [ array names tmp ]

    if {$slaves_name == ""} {
	     set slaves_name "NONE"   
	}
	
    return $slaves_name
}

proc proc_get_address_map_slaves_max_address_span {slave_map_param} {
    set slaves_max_address_span 0
    set address_map_dec [ proc_decode_address_map $slave_map_param]

    foreach slave_info $address_map_dec {
        array set slave_info_array $slave_info
        set slaves_start_address "[ proc_num2hex $slave_info_array(start) ]"
        set slaves_end_address "[ proc_num2hex $slave_info_array(end) ]"
        set slaves_address_span [ expr $slaves_end_address - $slaves_start_address ]
        
        if { [expr $slaves_address_span > $slaves_max_address_span ] } {
            set slaves_max_address_span $slaves_address_span
        }
    }
    return $slaves_max_address_span
}

proc proc_span2width { n } {
    return [expr int(ceil(log($n)/log(2)))]    
}

proc validate {} {

	# read user and system info parameter

	set allowByteTransactions [ proc_get_boolean_parameter allowByteTransactions ]
	set allowDoubleWordTransactions [ proc_get_boolean_parameter allowDoubleWordTransactions ]
	set allowHalfWordTransactions [ proc_get_boolean_parameter allowHalfWordTransactions ]
	set allowQuadWordTransactions [ proc_get_boolean_parameter allowQuadWordTransactions ]
	set allowWordTransactions [ proc_get_boolean_parameter allowWordTransactions ]
	set avalonSpec [ get_parameter_value avalonSpec ]
	set bigEndian [ proc_get_boolean_parameter bigEndian ]
	set burstEnable [ proc_get_boolean_parameter burstEnable ]
	set fifoDepth [ get_parameter_value fifoDepth ]
	set maxBurstSize [ get_parameter_value maxBurstSize ]
	set minimumDmaTransactionRegisterWidth [ get_parameter_value minimumDmaTransactionRegisterWidth ]
	set readAddressMap [ get_parameter_value readAddressMap ]
	set readSlaveAddressWidthMax [ get_parameter_value readSlaveAddressWidthMax ]
	set readSlaveDataWidthMax [ get_parameter_value readSlaveDataWidthMax ]
	set useRegistersForFIFO [ proc_get_boolean_parameter useRegistersForFIFO ]
	set writeAddressMap [ get_parameter_value writeAddressMap ]
	set writeSlaveAddressWidthMax [ get_parameter_value writeSlaveAddressWidthMax ]
	set writeSlaveDataWidthMax [ get_parameter_value writeSlaveDataWidthMax ]

	# validate parameter and update derived parameter

	# GUI parameter enabling and disabling

	# Validate FIFO and burst enable
	if { $useRegistersForFIFO && $burstEnable} {
	    send_message warning "Construct FIFO from memory blocks instead of registers to avoid excessive LE usage."
	}
	
	# Validate transaction settings
	if { !($allowByteTransactions || $allowHalfWordTransactions || $allowWordTransactions || $allowDoubleWordTransactions || $allowQuadWordTransactions) } {
	     send_message error "At least one type of transaction must be allowed."   
	}
	
	# validate big endian
	if { $bigEndian } {
	    if { $allowHalfWordTransactions || $allowWordTransactions || $allowDoubleWordTransactions || $allowQuadWordTransactions} {
	         send_message error "Big-endian mode only supports byte transactions."   
	    }
	}
	
	# Enable burst size if burst enabled
	if { $burstEnable } {
	    set_parameter_property maxBurstSize ENABLED "true"
	} else {
	    set_parameter_property maxBurstSize ENABLED "false"   
	}
	
	# Update mim byte transfer
	set minimumNumberOfByteTransfers [expr {pow(2,$minimumDmaTransactionRegisterWidth) - 1} ]
	set mindmatransactiondisplay "<html>The maximum transaction size will be at least $minimumNumberOfByteTransfers bytes. <br>\
The maximum may be automatically increased to encompass the slave span.</html>"
	set_display_item_property mindmatransactiondisplay TEXT $mindmatransactiondisplay  
	
	# Finding the span for read and write 
	set readMaximumSlaveSpan [ proc_get_address_map_slaves_max_address_span  readAddressMap ]
	set writeMaximumSlaveSpan [ proc_get_address_map_slaves_max_address_span  writeAddressMap ]

	# Legacy signal is always 0, since this is Qsys only
	set allowLegacySignals 0
	
	if { $readMaximumSlaveSpan > $writeMaximumSlaveSpan } {
	    set maxspan [log2ceil [ expr $readMaximumSlaveSpan + 1] ]
	} else {
	    set maxspan [ log2ceil [ expr $writeMaximumSlaveSpan + 1 ] ]
	}

	if { $maxspan > $minimumDmaTransactionRegisterWidth } {
	    set actualDmaTransactionRegisterWidth $maxspan
	} else {
	    set actualDmaTransactionRegisterWidth $minimumDmaTransactionRegisterWidth
	}
	
	# find whether is it connected to its own port slave
	set read_slave [ proc_get_address_map_slaves_name readAddressMap ]
	set write_slave [ proc_get_address_map_slaves_name writeAddressMap ]
	
	set search_read_slave [ regexp {control_port_slave} $read_slave ]
	set search_write_slave [ regexp {control_port_slave} $write_slave ]
	
	if {$search_read_slave || $search_write_slave} {
	    set actualDmaTransactionRegisterWidth 5
	}
	
	# embedded software assignments

	set_module_assignment embeddedsw.CMacro.ALLOW_BYTE_TRANSACTIONS "$allowByteTransactions"
	set_module_assignment embeddedsw.CMacro.ALLOW_DOUBLEWORD_TRANSACTIONS "$allowDoubleWordTransactions"
	set_module_assignment embeddedsw.CMacro.ALLOW_HW_TRANSACTIONS "$allowHalfWordTransactions"
	set_module_assignment embeddedsw.CMacro.ALLOW_QUADWORD_TRANSACTIONS "$allowQuadWordTransactions"
	set_module_assignment embeddedsw.CMacro.ALLOW_WORD_TRANSACTIONS "$allowWordTransactions"
	set_module_assignment embeddedsw.CMacro.LENGTHWIDTH "$minimumDmaTransactionRegisterWidth"
	set_module_assignment embeddedsw.CMacro.MAX_BURST_SIZE "$maxBurstSize"


	# save derived parameter

	set_parameter_value actualDmaTransactionRegisterWidth $actualDmaTransactionRegisterWidth
	set_parameter_value allowLegacySignals $allowLegacySignals
	set_parameter_value minimumNumberOfByteTransfers $minimumNumberOfByteTransfers
	set_parameter_value readMaximumSlaveSpan $readMaximumSlaveSpan
	set_parameter_value writeMaximumSlaveSpan $writeMaximumSlaveSpan

}

#-------------------------------------------------------------------------------
# module elaboration
#-------------------------------------------------------------------------------

proc elaborate {} {

	# read parameter

	set actualDmaTransactionRegisterWidth [ get_parameter_value actualDmaTransactionRegisterWidth ]
	set allowByteTransactions [ proc_get_boolean_parameter allowByteTransactions ]
	set allowDoubleWordTransactions [ proc_get_boolean_parameter allowDoubleWordTransactions ]
	set allowHalfWordTransactions [ proc_get_boolean_parameter allowHalfWordTransactions ]
	set allowLegacySignals [ proc_get_boolean_parameter allowLegacySignals ]
	set allowQuadWordTransactions [ proc_get_boolean_parameter allowQuadWordTransactions ]
	set allowWordTransactions [ proc_get_boolean_parameter allowWordTransactions ]
	set avalonSpec [ get_parameter_value avalonSpec ]
	set bigEndian [ proc_get_boolean_parameter bigEndian ]
	set burstEnable [ proc_get_boolean_parameter burstEnable ]
	set fifoDepth [ get_parameter_value fifoDepth ]
	set maxBurstSize [ get_parameter_value maxBurstSize ]
	set minimumDmaTransactionRegisterWidth [ get_parameter_value minimumDmaTransactionRegisterWidth ]
	set minimumNumberOfByteTransfers [ get_parameter_value minimumNumberOfByteTransfers ]
	set readAddressMap [ get_parameter_value readAddressMap ]
	set readMaximumSlaveSpan [ get_parameter_value readMaximumSlaveSpan ]
	set readSlaveAddressWidthMax [ get_parameter_value readSlaveAddressWidthMax ]
	set readSlaveDataWidthMax [ get_parameter_value readSlaveDataWidthMax ]
	set useRegistersForFIFO [ proc_get_boolean_parameter useRegistersForFIFO ]
	set writeAddressMap [ get_parameter_value writeAddressMap ]
	set writeMaximumSlaveSpan [ get_parameter_value writeMaximumSlaveSpan ]
	set writeSlaveAddressWidthMax [ get_parameter_value writeSlaveAddressWidthMax ]
	set writeSlaveDataWidthMax [ get_parameter_value writeSlaveDataWidthMax ]

	if {$writeSlaveAddressWidthMax > $readSlaveAddressWidthMax} {
	    set actualcontrolslaveDataWidth $writeSlaveAddressWidthMax
	} else {
	    set actualcontrolslaveDataWidth $readSlaveAddressWidthMax
	}
	if {$actualcontrolslaveDataWidth < $actualDmaTransactionRegisterWidth} {
	    set actualcontrolslaveDataWidth $actualDmaTransactionRegisterWidth
	}
	if {$actualcontrolslaveDataWidth < 13} {
	    set actualcontrolslaveDataWidth 13
	}
	
	set read_slave [ proc_get_address_map_slaves_name readAddressMap ]
	set write_slave [ proc_get_address_map_slaves_name writeAddressMap ]

	set search_read_slave [ regexp {control_port_slave} $read_slave ]
	set search_write_slave [ regexp {control_port_slave} $write_slave ]

	set read_slave_no 0
    foreach i $read_slave {
        set read_slave_no [ expr {$read_slave_no + 1} ]
    }

	set write_slave_no 0
    foreach i $write_slave {
        set write_slave_no [ expr {$write_slave_no + 1} ]
    }
    

    set maximumTransactionSize 8
    if { $allowQuadWordTransactions } {
        set maximumTransactionSize 128
    } elseif { $allowDoubleWordTransactions } {
        set maximumTransactionSize 64
    } elseif { $allowWordTransactions } {
        set maximumTransactionSize 32
    } elseif { $allowHalfWordTransactions } {
        set maximumTransactionSize 16
    } else {
        set maximumTransactionSize 8
    }
    
	# Find read master data width
	if { $readSlaveDataWidthMax > 0 } {
	    set actualreadSlaveDataWidth $readSlaveDataWidthMax
	} else {
	    set actualreadSlaveDataWidth 8
	}
	
	if { $actualreadSlaveDataWidth > $maximumTransactionSize } {
	    set actualreadSlaveDataWidth $maximumTransactionSize
	}
	
	# Find write master data width
	if { $writeSlaveDataWidthMax > 0 } {
	    set actualwriteSlaveDataWidth $writeSlaveDataWidthMax
	} else {
	    set actualwriteSlaveDataWidth 8
	}
	
	if { $actualwriteSlaveDataWidth > $maximumTransactionSize } {
	    set actualwriteSlaveDataWidth $maximumTransactionSize
	}
	
	if { $actualreadSlaveDataWidth > $actualwriteSlaveDataWidth } {
	    set actualwriteSlaveDataWidth $actualreadSlaveDataWidth
	} else {
	    set actualreadSlaveDataWidth $actualwriteSlaveDataWidth
	}
	
	# interfaces

	add_interface clk clock sink
	set_interface_property clk clockRate {0.0}
	set_interface_property clk externallyDriven {0}
	set_interface_property clk ptfSchematicName {}

	add_interface_port clk clk clk Input 1


	add_interface reset reset sink
	set_interface_property reset associatedClock {clk}
	set_interface_property reset synchronousEdges {DEASSERT}

	add_interface_port reset system_reset_n reset_n Input 1


	add_interface control_port_slave avalon slave
	set_interface_property control_port_slave addressAlignment {NATIVE}
	set_interface_property control_port_slave addressGroup {0}
	set_interface_property control_port_slave addressSpan {8}
	set_interface_property control_port_slave addressUnits {WORDS}
	set_interface_property control_port_slave alwaysBurstMaxBurst {0}
	set_interface_property control_port_slave associatedClock {clk}
	set_interface_property control_port_slave associatedReset {reset}
	set_interface_property control_port_slave bitsPerSymbol {8}
	set_interface_property control_port_slave bridgesToMaster {}
	set_interface_property control_port_slave burstOnBurstBoundariesOnly {0}
	set_interface_property control_port_slave burstcountUnits {WORDS}
	set_interface_property control_port_slave constantBurstBehavior {0}
	set_interface_property control_port_slave explicitAddressSpan {0}
	set_interface_property control_port_slave holdTime {0}
	set_interface_property control_port_slave interleaveBursts {0}
	set_interface_property control_port_slave isBigEndian {0}
	set_interface_property control_port_slave isFlash {0}
	set_interface_property control_port_slave isMemoryDevice {0}
	set_interface_property control_port_slave isNonVolatileStorage {0}
	set_interface_property control_port_slave linewrapBursts {0}
	set_interface_property control_port_slave maximumPendingReadTransactions {0}
	set_interface_property control_port_slave minimumUninterruptedRunLength {1}
	set_interface_property control_port_slave printableDevice {0}
	set_interface_property control_port_slave readLatency {0}
	set_interface_property control_port_slave readWaitStates {1}
	set_interface_property control_port_slave readWaitTime {1}
	set_interface_property control_port_slave registerIncomingSignals {0}
	set_interface_property control_port_slave registerOutgoingSignals {0}
	set_interface_property control_port_slave setupTime {0}
	set_interface_property control_port_slave timingUnits {Cycles}
	set_interface_property control_port_slave transparentBridge {0}
	set_interface_property control_port_slave wellBehavedWaitrequest {0}
	set_interface_property control_port_slave writeLatency {0}
	set_interface_property control_port_slave writeWaitStates {1}
	set_interface_property control_port_slave writeWaitTime {1}

	add_interface_port control_port_slave dma_ctl_address address Input 3
	add_interface_port control_port_slave dma_ctl_chipselect chipselect Input 1
	add_interface_port control_port_slave dma_ctl_readdata readdata Output "$actualcontrolslaveDataWidth"
	add_interface_port control_port_slave dma_ctl_write_n write_n Input 1
	add_interface_port control_port_slave dma_ctl_writedata writedata Input "$actualcontrolslaveDataWidth"
	# Legacy signal
	#add_interface_port control_port_slave dma_ctl_readyfordata readyfordata output 1

	set_interface_assignment control_port_slave embeddedsw.configuration.affectsTransactionsOnMasters {read_master write_master}

	add_interface irq interrupt sender
	set_interface_property irq associatedAddressablePoint {dma_0.control_port_slave}
	set_interface_property irq associatedClock {clk}
	set_interface_property irq associatedReset {reset}
	set_interface_property irq irqScheme {NONE}

	add_interface_port irq dma_ctl_irq irq Output 1


	add_interface read_master avalon master
	set_interface_property read_master adaptsTo {}
	set_interface_property read_master addressGroup {0}
	set_interface_property read_master addressUnits {SYMBOLS}
	set_interface_property read_master alwaysBurstMaxBurst {0}
	set_interface_property read_master associatedClock {clk}
	set_interface_property read_master associatedReset {reset}
	set_interface_property read_master bitsPerSymbol {8}
	set_interface_property read_master burstOnBurstBoundariesOnly {0}
	set_interface_property read_master burstcountUnits {WORDS}
	set_interface_property read_master constantBurstBehavior {0}
	set_interface_property read_master dBSBigEndian {0}
	set_interface_property read_master doStreamReads {1}
	set_interface_property read_master doStreamWrites {0}
	set_interface_property read_master holdTime {0}
	set_interface_property read_master interleaveBursts {0}
	set_interface_property read_master isAsynchronous {0}
	set_interface_property read_master isBigEndian "$bigEndian"
	set_interface_property read_master isReadable {1}
	set_interface_property read_master isWriteable {0}
	set_interface_property read_master linewrapBursts {0}
	set_interface_property read_master maxAddressWidth {32}
	set_interface_property read_master maximumPendingReadTransactions {0}
	set_interface_property read_master readLatency {0}
	set_interface_property read_master readWaitTime {1}
	set_interface_property read_master registerIncomingSignals {0}
	set_interface_property read_master registerOutgoingSignals {0}
	set_interface_property read_master setupTime {0}
	set_interface_property read_master timingUnits {Cycles}
	set_interface_property read_master writeWaitTime {0}

	# Minimum width is 5
	if { $readSlaveAddressWidthMax > 5 } {
	    set actualreadSlaveAddressWidth $readSlaveAddressWidthMax
	
	} else {
	    set actualreadSlaveAddressWidth 5    
	}

	if { [ expr { $search_read_slave && $read_slave_no == "1" } ] } {
	    set actualreadSlaveDataWidth 16
	    set actualreadSlaveAddressWidth 5
	}
	
	if { $read_slave == "NONE" } {
	    set actualreadSlaveDataWidth 8
	}
	
	add_interface_port read_master read_address address Output "$actualreadSlaveAddressWidth"
	add_interface_port read_master read_chipselect chipselect Output 1
	add_interface_port read_master read_read_n read_n Output 1
	add_interface_port read_master read_readdata readdata Input "$actualreadSlaveDataWidth"
	add_interface_port read_master read_readdatavalid readdatavalid Input 1
	add_interface_port read_master read_waitrequest waitrequest Input 1


	add_interface write_master avalon master
	set_interface_property write_master adaptsTo {}
	set_interface_property write_master addressGroup {0}
	set_interface_property write_master addressUnits {SYMBOLS}
	set_interface_property write_master alwaysBurstMaxBurst {0}
	set_interface_property write_master associatedClock {clk}
	set_interface_property write_master associatedReset {reset}
	set_interface_property write_master bitsPerSymbol {8}
	set_interface_property write_master burstOnBurstBoundariesOnly {0}
	set_interface_property write_master burstcountUnits {WORDS}
	set_interface_property write_master constantBurstBehavior {0}
	set_interface_property write_master dBSBigEndian {0}
	set_interface_property write_master doStreamReads {0}
	set_interface_property write_master doStreamWrites {1}
	set_interface_property write_master holdTime {0}
	set_interface_property write_master interleaveBursts {0}
	set_interface_property write_master isAsynchronous {0}
	set_interface_property write_master isBigEndian "$bigEndian"
	set_interface_property write_master isReadable {0}
	set_interface_property write_master isWriteable {1}
	set_interface_property write_master linewrapBursts {0}
	set_interface_property write_master maxAddressWidth {32}
	set_interface_property write_master maximumPendingReadTransactions {0}
	set_interface_property write_master readLatency {0}
	set_interface_property write_master readWaitTime {1}
	set_interface_property write_master registerIncomingSignals {0}
	set_interface_property write_master registerOutgoingSignals {0}
	set_interface_property write_master setupTime {0}
	set_interface_property write_master timingUnits {Cycles}
	set_interface_property write_master writeWaitTime {0}

	# Minimum width is 5
	if { $writeSlaveAddressWidthMax > 5 } {
	    set actualwriteSlaveAddressWidth $writeSlaveAddressWidthMax
	
	} else {
	    set actualwriteSlaveAddressWidth 5    
	}
	
	if { [ expr { $search_write_slave && $write_slave_no == "1" } ] } {
	    set actualwriteSlaveDataWidth 16
	    set actualwriteSlaveAddressWidth 5
	}
	
	if { $write_slave == "NONE" } {
	    set actualwriteSlaveDataWidth 8
	}
	add_interface_port write_master write_address address Output "$actualwriteSlaveAddressWidth"
	add_interface_port write_master write_chipselect chipselect Output 1
	add_interface_port write_master write_waitrequest waitrequest Input 1
	add_interface_port write_master write_write_n write_n Output 1
	add_interface_port write_master write_writedata writedata Output "$actualwriteSlaveDataWidth"

	# Write_byteenable only require when more than 1 type of transaction is supported
	set write_byteenable_width [ expr { $actualwriteSlaveDataWidth/8 }]
	
	set allowed_transaction 1
	if { $actualwriteSlaveDataWidth >= 16 } {
		set allowed_transaction [ expr {$allowed_transaction + $allowHalfWordTransactions} ]
	}
	if { $actualwriteSlaveDataWidth >= 32 } {
		set allowed_transaction [ expr {$allowed_transaction + $allowWordTransactions} ]
	}
	if { $actualwriteSlaveDataWidth >= 64 } {
		set allowed_transaction [ expr {$allowed_transaction + $allowDoubleWordTransactions} ]
	}
	if { $actualwriteSlaveDataWidth >= 128 } {
		set allowed_transaction [ expr {$allowed_transaction + $allowQuadWordTransactions} ]
	}
	if { [ expr {$allowed_transaction > 1} && { $write_slave != "NONE" } ] } {
	    add_interface_port write_master write_byteenable byteenable Output "$write_byteenable_width"
	}

	set burstcountportwidth [expr { [ log2ceil $maxBurstSize ] } + 1]
	if { $burstEnable } {
	    add_interface_port write_master write_burstcount burstcount Output $burstcountportwidth
	    add_interface_port read_master read_burstcount burstcount Output $burstcountportwidth
	}

	# Any elaboration on allowLegacySignals is diabled - deprecated
}

#-------------------------------------------------------------------------------
# module generation
#-------------------------------------------------------------------------------
proc proc_add_generated_files_dma {NAME output_directory rtl_ext simulation} {
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
proc generate {output_name output_directory rtl_ext simulation} {
	global env
	set QUARTUS_ROOTDIR         "$env(QUARTUS_ROOTDIR)"
	set component_directory     "$QUARTUS_ROOTDIR/../ip/altera/sopc_builder_ip/altera_avalon_dma"
	set component_config_file   "$output_directory/${output_name}_component_configuration.pl"

	# read parameter

	set actualDmaTransactionRegisterWidth [ get_parameter_value actualDmaTransactionRegisterWidth ]
	set allowByteTransactions [ proc_get_boolean_parameter allowByteTransactions ]
	set allowDoubleWordTransactions [ proc_get_boolean_parameter allowDoubleWordTransactions ]
	set allowHalfWordTransactions [ proc_get_boolean_parameter allowHalfWordTransactions ]
	set allowLegacySignals [ proc_get_boolean_parameter allowLegacySignals ]
	set allowQuadWordTransactions [ proc_get_boolean_parameter allowQuadWordTransactions ]
	set allowWordTransactions [ proc_get_boolean_parameter allowWordTransactions ]
	set avalonSpec [ get_parameter_value avalonSpec ]
	set bigEndian [ proc_get_boolean_parameter bigEndian ]
	set burstEnable [ proc_get_boolean_parameter burstEnable ]
	set fifoDepth [ get_parameter_value fifoDepth ]
	set maxBurstSize [ get_parameter_value maxBurstSize ]
	set minimumDmaTransactionRegisterWidth [ get_parameter_value minimumDmaTransactionRegisterWidth ]
	set minimumNumberOfByteTransfers [ get_parameter_value minimumNumberOfByteTransfers ]
	set readAddressMap [ get_parameter_value readAddressMap ]
	set readMaximumSlaveSpan [ get_parameter_value readMaximumSlaveSpan ]
	set readSlaveAddressWidthMax [ get_parameter_value readSlaveAddressWidthMax ]
	set readSlaveDataWidthMax [ get_parameter_value readSlaveDataWidthMax ]
	set useRegistersForFIFO [ proc_get_boolean_parameter useRegistersForFIFO ]
	set writeAddressMap [ get_parameter_value writeAddressMap ]
	set writeMaximumSlaveSpan [ get_parameter_value writeMaximumSlaveSpan ]
	set writeSlaveAddressWidthMax [ get_parameter_value writeSlaveAddressWidthMax ]
	set writeSlaveDataWidthMax [ get_parameter_value writeSlaveDataWidthMax ]


	 # These are the control bit reset values for the DMA. Nothing touches these, ever, unless you 
	 # manually edit the PTF. So they're not module properties, but I have to put them here
	 # because the WSA (and the generator) demands that they be present. I've tried to rename them
	 # to be as meaningful as possible.
	
	set readaddressResetValue 0
	set writeaddressResetValue 0
	set lengthResetValue 0
	set controlByteResetValue 0
	set controlHalfWordResetValue 0
	set controlWordResetValue 1
	set controlDoubleWordResetValue 0
	set controlQuadWordResetValue 0
	set controlExecutionEnableResetValue  0
	set controlInterruptEnableResetValue  0
	set controlReadEOPEnableResetValue  0
	set controlWriteEOPEnableResetValue  0
	set controlLengthEnableResetValue  1
	set controlReadFixedAddressResetValue  0
	set controlWriteFixedAddressResetValue  0
	set controlSoftwareResetResetValue  0
	
	# Get the slave names in list and pass down
	set write_slave [ proc_get_address_map_slaves_name writeAddressMap ]
	set read_slave [ proc_get_address_map_slaves_name readAddressMap ]
	
	set search_read_slave [ regexp {control_port_slave} $read_slave ]
	set search_write_slave [ regexp {control_port_slave} $write_slave ]
	
	if { $search_write_slave } {
	    set writeSlaveAddressWidthMax 5
	    set writeSlaveDataWidthMax 16
	}
	if { $search_read_slave } {
	    set readSlaveAddressWidthMax 5
	    set readSlaveDataWidthMax 16
	}
	
	if { [ expr { $write_slave == "NONE" && $read_slave == "NONE" } ] } {
	    set allowByteTransactions 0
	    set allowDoubleWordTransactions 0
	    set allowHalfWordTransactions 0
	    set allowQuadWordTransactions 0
	    set allowWordTransactions 0
	}

	if {$readMaximumSlaveSpan > $writeMaximumSlaveSpan} {
	     set max_slave_address_span $readMaximumSlaveSpan
	} else {
	     set max_slave_address_span $writeMaximumSlaveSpan
	}
	regsub -all { } $read_slave {,} read_slave
	regsub -all { } $write_slave {,} write_slave

	# prepare config file
	set component_config    [open $component_config_file "w"]

	puts $component_config "# ${output_name} Component Configuration File"
	puts $component_config "return {"

	    puts $component_config "\treadaddress_reset_value             => $readaddressResetValue,"
	    puts $component_config "\twriteaddress_reset_value            => $writeaddressResetValue,"
	    puts $component_config "\tlength_reset_value                  => $lengthResetValue,"
	    puts $component_config "\tcontrol_byte_reset_value            => $controlByteResetValue,"
	    puts $component_config "\tcontrol_hw_reset_value              => $controlHalfWordResetValue,"
	    puts $component_config "\tcontrol_word_reset_value            => $controlWordResetValue,"
	    puts $component_config "\tcontrol_doubleword_reset_value      => $controlDoubleWordResetValue,"
	    puts $component_config "\tcontrol_quadword_reset_value        => $controlQuadWordResetValue,"
	    puts $component_config "\tcontrol_softwarereset_reset_value   => $controlSoftwareResetResetValue,"
	    puts $component_config "\tcontrol_go_reset_value              => $controlExecutionEnableResetValue,"
	    puts $component_config "\tcontrol_i_en_reset_value            => $controlInterruptEnableResetValue,"
	    puts $component_config "\tcontrol_reen_reset_value            => $controlReadEOPEnableResetValue,"
	    puts $component_config "\tcontrol_ween_reset_value            => $controlWriteEOPEnableResetValue,"
	    puts $component_config "\tcontrol_leen_reset_value            => $controlLengthEnableResetValue,"
	    puts $component_config "\tcontrol_rcon_reset_value            => $controlReadFixedAddressResetValue,"
	    puts $component_config "\tcontrol_wcon_reset_value            => $controlWriteFixedAddressResetValue,"
	    puts $component_config "\tlengthwidth                         => $minimumDmaTransactionRegisterWidth,"
	    puts $component_config "\tburst_enable                        => $burstEnable,"
	    puts $component_config "\tfifo_in_logic_elements              => $useRegistersForFIFO,"
	    puts $component_config "\tallow_byte_transactions             => $allowByteTransactions,"
	    puts $component_config "\tallow_hw_transactions               => $allowHalfWordTransactions,"
	    puts $component_config "\tallow_word_transactions             => $allowWordTransactions,"
	    puts $component_config "\tallow_doubleword_transactions       => $allowDoubleWordTransactions,"
	    puts $component_config "\tallow_quadword_transactions         => $allowQuadWordTransactions,"
	    puts $component_config "\tmax_burst_size                      => $maxBurstSize,"
	    puts $component_config "\tbig_endian                          => $bigEndian,"
	    puts $component_config "\tallow_legacy_signals                => $allowLegacySignals,"
	    puts $component_config "\tfifo_depth                          => $fifoDepth,"
	    puts $component_config "\tread_data_width                     => $readSlaveDataWidthMax,"
	    puts $component_config "\twrite_data_width                    => $writeSlaveDataWidthMax,"
	    puts $component_config "\tread_address_width                  => $readSlaveAddressWidthMax,"
	    puts $component_config "\twrite_address_width                 => $writeSlaveAddressWidthMax,"
	    puts $component_config "\tmax_slave_address_span              => $max_slave_address_span,"
	    puts $component_config "\tuser_defined_fifo_depth             => 1,"
	    puts $component_config "\tread_slave_name                     => \"$read_slave\","
	    puts $component_config "\twrite_slave_name                    => \"$write_slave\","

	puts $component_config "};"
	close $component_config

	# generate rtl
	proc_generate_component_rtl  "$component_config_file" "$component_directory" "$output_name" "$output_directory" "$rtl_ext" "$simulation"
	proc_add_generated_files_dma "$output_name" "$output_directory" "$rtl_ext" "$simulation"
}

proc sub_quartus_synth_dma {NAME} {
    set rtl_ext "v"
    set simgen  0
    set output_directory [ create_temp_file "" ]

    generate                    "$NAME" "$output_directory" "$rtl_ext" "$simgen"
}

proc sub_sim_verilog_dma {NAME} {
    set rtl_ext "v"
    set simgen  1
    set output_directory [ create_temp_file "" ]

    generate                    "$NAME" "$output_directory" "$rtl_ext" "$simgen"
}

proc sub_sim_vhdl_dma {NAME} {
    set rtl_ext "vhd"
    set simgen  1
    set output_directory [ create_temp_file "" ]

    generate                    "$NAME" "$output_directory" "$rtl_ext" "$simgen"
}
