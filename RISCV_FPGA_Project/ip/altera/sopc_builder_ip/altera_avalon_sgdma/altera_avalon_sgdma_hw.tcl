package require -exact qsys 12.0
source $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/common/embedded_ip_hwtcl_common.tcl

#-------------------------------------------------------------------------------
# module properties
#-------------------------------------------------------------------------------

set_module_property NAME {altera_avalon_sgdma}
set_module_property DISPLAY_NAME {Scatter-Gather DMA Controller}
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

add_fileset quartus_synth QUARTUS_SYNTH sub_quartus_synth
add_fileset sim_verilog SIM_VERILOG sub_sim_verilog
add_fileset sim_vhdl SIM_VHDL sub_sim_vhdl

# links to documentation

add_documentation_link {Data Sheet} {http://www.altera.com/literature/hb/nios2/qts_qii55003.pdf}

#-------------------------------------------------------------------------------
# module parameters
#-------------------------------------------------------------------------------

# parameters

add_parameter addressWidth INTEGER
set_parameter_property addressWidth DEFAULT_VALUE {32}
set_parameter_property addressWidth DISPLAY_NAME {addressWidth}
set_parameter_property addressWidth VISIBLE {0}
set_parameter_property addressWidth ALLOWED_RANGES {16 32}
set_parameter_property addressWidth AFFECTS_GENERATION {1}
set_parameter_property addressWidth HDL_PARAMETER {0}

add_parameter alwaysDoMaxBurst BOOLEAN
set_parameter_property alwaysDoMaxBurst DEFAULT_VALUE {true}
set_parameter_property alwaysDoMaxBurst DISPLAY_NAME {alwaysDoMaxBurst}
set_parameter_property alwaysDoMaxBurst VISIBLE {0}
set_parameter_property alwaysDoMaxBurst AFFECTS_GENERATION {1}
set_parameter_property alwaysDoMaxBurst HDL_PARAMETER {0}

add_parameter avalonMMByteReorderMode INTEGER
set_parameter_property avalonMMByteReorderMode DEFAULT_VALUE {0}
set_parameter_property avalonMMByteReorderMode DISPLAY_NAME {Avalon MM data master byte reorder mode}
set_parameter_property avalonMMByteReorderMode ALLOWED_RANGES {{0:No Reordering} {1:Byte Swap}}
set_parameter_property avalonMMByteReorderMode AFFECTS_GENERATION {1}
set_parameter_property avalonMMByteReorderMode HDL_PARAMETER {0}

add_parameter dataTransferFIFODepth INTEGER
set_parameter_property dataTransferFIFODepth DEFAULT_VALUE {2}
set_parameter_property dataTransferFIFODepth DISPLAY_NAME {dataTransferFIFODepth}
set_parameter_property dataTransferFIFODepth VISIBLE {0}
set_parameter_property dataTransferFIFODepth ALLOWED_RANGES {2 4 8 16 32 64}
set_parameter_property dataTransferFIFODepth AFFECTS_GENERATION {1}
set_parameter_property dataTransferFIFODepth HDL_PARAMETER {0}

add_parameter enableBurstTransfers BOOLEAN
set_parameter_property enableBurstTransfers DEFAULT_VALUE {false}
set_parameter_property enableBurstTransfers DISPLAY_NAME {Enable burst transfers}
set_parameter_property enableBurstTransfers AFFECTS_GENERATION {1}
set_parameter_property enableBurstTransfers HDL_PARAMETER {0}

add_parameter enableDescriptorReadMasterBurst BOOLEAN
set_parameter_property enableDescriptorReadMasterBurst DEFAULT_VALUE {false}
set_parameter_property enableDescriptorReadMasterBurst DISPLAY_NAME {Enable bursting on descriptor read master}
set_parameter_property enableDescriptorReadMasterBurst AFFECTS_GENERATION {1}
set_parameter_property enableDescriptorReadMasterBurst HDL_PARAMETER {0}

add_parameter enableUnalignedTransfers BOOLEAN
set_parameter_property enableUnalignedTransfers DEFAULT_VALUE {false}
set_parameter_property enableUnalignedTransfers DISPLAY_NAME {Allow unaligned transfers}
set_parameter_property enableUnalignedTransfers AFFECTS_GENERATION {1}
set_parameter_property enableUnalignedTransfers HDL_PARAMETER {0}

add_parameter internalFIFODepth INTEGER
set_parameter_property internalFIFODepth DEFAULT_VALUE {2}
set_parameter_property internalFIFODepth DISPLAY_NAME {internalFIFODepth}
set_parameter_property internalFIFODepth VISIBLE {0}
set_parameter_property internalFIFODepth ALLOWED_RANGES {2 3 4}
set_parameter_property internalFIFODepth AFFECTS_GENERATION {1}
set_parameter_property internalFIFODepth HDL_PARAMETER {0}

add_parameter readBlockDataWidth INTEGER
set_parameter_property readBlockDataWidth DEFAULT_VALUE {32}
set_parameter_property readBlockDataWidth DISPLAY_NAME {Data width}
set_parameter_property readBlockDataWidth ALLOWED_RANGES {8 16 32 64}
set_parameter_property readBlockDataWidth AFFECTS_GENERATION {1}
set_parameter_property readBlockDataWidth HDL_PARAMETER {0}

add_parameter readBurstcountWidth INTEGER
set_parameter_property readBurstcountWidth DEFAULT_VALUE {4}
set_parameter_property readBurstcountWidth DISPLAY_NAME {Read burstcount signal width}
set_parameter_property readBurstcountWidth ALLOWED_RANGES {1:16}
set_parameter_property readBurstcountWidth AFFECTS_GENERATION {1}
set_parameter_property readBurstcountWidth HDL_PARAMETER {0}

add_parameter sinkErrorWidth INTEGER
set_parameter_property sinkErrorWidth DEFAULT_VALUE {0}
set_parameter_property sinkErrorWidth DISPLAY_NAME {Sink error width}
set_parameter_property sinkErrorWidth ALLOWED_RANGES {0:7}
set_parameter_property sinkErrorWidth AFFECTS_GENERATION {1}
set_parameter_property sinkErrorWidth HDL_PARAMETER {0}

add_parameter sourceErrorWidth INTEGER
set_parameter_property sourceErrorWidth DEFAULT_VALUE {0}
set_parameter_property sourceErrorWidth DISPLAY_NAME {Source error width}
set_parameter_property sourceErrorWidth ALLOWED_RANGES {0:7}
set_parameter_property sourceErrorWidth AFFECTS_GENERATION {1}
set_parameter_property sourceErrorWidth HDL_PARAMETER {0}

add_parameter transferMode STRING
set_parameter_property transferMode DEFAULT_VALUE {MEMORY_TO_MEMORY}
set_parameter_property transferMode DISPLAY_NAME {Transfer mode}
set_parameter_property transferMode ALLOWED_RANGES {{MEMORY_TO_MEMORY:Memory To Memory} {MEMORY_TO_STREAM:Memory To Stream} {STREAM_TO_MEMORY:Stream To Memory}}
set_parameter_property transferMode AFFECTS_GENERATION {1}
set_parameter_property transferMode HDL_PARAMETER {0}

add_parameter writeBurstcountWidth INTEGER
set_parameter_property writeBurstcountWidth DEFAULT_VALUE {4}
set_parameter_property writeBurstcountWidth DISPLAY_NAME {Write burstcount signal width}
set_parameter_property writeBurstcountWidth ALLOWED_RANGES {1:16}
set_parameter_property writeBurstcountWidth AFFECTS_GENERATION {1}
set_parameter_property writeBurstcountWidth HDL_PARAMETER {0}

# system info parameters

add_parameter deviceFamilyString STRING
set_parameter_property deviceFamilyString DISPLAY_NAME {deviceFamilyString}
set_parameter_property deviceFamilyString VISIBLE {0}
set_parameter_property deviceFamilyString AFFECTS_GENERATION {1}
set_parameter_property deviceFamilyString HDL_PARAMETER {0}
set_parameter_property deviceFamilyString SYSTEM_INFO {device_family}
set_parameter_property deviceFamilyString SYSTEM_INFO_TYPE {DEVICE_FAMILY}

# derived parameters

add_parameter actualDataTransferFIFODepth INTEGER
set_parameter_property actualDataTransferFIFODepth DEFAULT_VALUE {0}
set_parameter_property actualDataTransferFIFODepth DISPLAY_NAME {Data transfer FIFO depth}
set_parameter_property actualDataTransferFIFODepth DERIVED {1}
set_parameter_property actualDataTransferFIFODepth AFFECTS_GENERATION {1}
set_parameter_property actualDataTransferFIFODepth HDL_PARAMETER {0}

add_parameter commandFIFODataWidth INTEGER
set_parameter_property commandFIFODataWidth DEFAULT_VALUE {0}
set_parameter_property commandFIFODataWidth DISPLAY_NAME {common FIFO data width}
set_parameter_property commandFIFODataWidth VISIBLE {0}
set_parameter_property commandFIFODataWidth DERIVED {1}
set_parameter_property commandFIFODataWidth AFFECTS_GENERATION {1}
set_parameter_property commandFIFODataWidth HDL_PARAMETER {0}

add_parameter symbolsPerBeat INTEGER
set_parameter_property symbolsPerBeat DEFAULT_VALUE {0}
set_parameter_property symbolsPerBeat DISPLAY_NAME {Symbols Per Beat}
set_parameter_property symbolsPerBeat VISIBLE {0}
set_parameter_property symbolsPerBeat DERIVED {1}
set_parameter_property symbolsPerBeat AFFECTS_GENERATION {1}
set_parameter_property symbolsPerBeat HDL_PARAMETER {0}

add_parameter byteEnableWidth INTEGER
set_parameter_property byteEnableWidth DEFAULT_VALUE {0}
set_parameter_property byteEnableWidth DISPLAY_NAME {Byte Enable Width}
set_parameter_property byteEnableWidth VISIBLE {0}
set_parameter_property byteEnableWidth DERIVED {1}
set_parameter_property byteEnableWidth AFFECTS_GENERATION {1}
set_parameter_property byteEnableWidth HDL_PARAMETER {0}

add_parameter emptyWidth INTEGER
set_parameter_property emptyWidth DEFAULT_VALUE {0}
set_parameter_property emptyWidth DISPLAY_NAME {Empty Width}
set_parameter_property emptyWidth VISIBLE {0}
set_parameter_property emptyWidth DERIVED {1}
set_parameter_property emptyWidth AFFECTS_GENERATION {1}
set_parameter_property emptyWidth HDL_PARAMETER {0}

add_parameter hasReadBlock BOOLEAN
set_parameter_property hasReadBlock DEFAULT_VALUE {false}
set_parameter_property hasReadBlock DISPLAY_NAME {Has Read Block} 
set_parameter_property hasReadBlock VISIBLE {0}
set_parameter_property hasReadBlock DERIVED {1}
set_parameter_property hasReadBlock AFFECTS_GENERATION {1}
set_parameter_property hasReadBlock HDL_PARAMETER {0}  

add_parameter hasWriteBlock BOOLEAN
set_parameter_property hasWriteBlock DEFAULT_VALUE {false}
set_parameter_property hasWriteBlock DISPLAY_NAME {Has Write Block} 
set_parameter_property hasWriteBlock VISIBLE {0}
set_parameter_property hasWriteBlock DERIVED {1}
set_parameter_property hasWriteBlock AFFECTS_GENERATION {1}
set_parameter_property hasWriteBlock HDL_PARAMETER {0}  

#-------------------------------------------------------------------------------
# module GUI
#-------------------------------------------------------------------------------

# display group
add_display_item {} {Transfer options} GROUP
add_display_item {} {Data and error widths} GROUP
add_display_item {} {FIFO depth} GROUP

# group parameter
add_display_item {Transfer options} transferMode PARAMETER
add_display_item {Transfer options} enableDescriptorReadMasterBurst PARAMETER
add_display_item {Transfer options} enableUnalignedTransfers PARAMETER
add_display_item {Transfer options} enableBurstTransfers PARAMETER
add_display_item {Transfer options} readBurstcountWidth PARAMETER
add_display_item {Transfer options} writeBurstcountWidth PARAMETER
add_display_item {Transfer options} avalonMMByteReorderMode PARAMETER

add_display_item {Data and error widths} readBlockDataWidth PARAMETER
add_display_item {Data and error widths} sourceErrorWidth PARAMETER
add_display_item {Data and error widths} sinkErrorWidth PARAMETER

add_display_item {FIFO depth} actualDataTransferFIFODepth PARAMETER

#-------------------------------------------------------------------------------
# module validation
#-------------------------------------------------------------------------------

proc validate {} {

	# read user and system info parameter

	set addressWidth [ get_parameter_value addressWidth ]
	set alwaysDoMaxBurst [ proc_get_boolean_parameter alwaysDoMaxBurst ]
	set avalonMMByteReorderMode [ get_parameter_value avalonMMByteReorderMode ]
	set dataTransferFIFODepth [ get_parameter_value dataTransferFIFODepth ]
	set deviceFamilyString [ get_parameter_value deviceFamilyString ]
	set enableBurstTransfers [ proc_get_boolean_parameter enableBurstTransfers ]
	set enableDescriptorReadMasterBurst [ proc_get_boolean_parameter enableDescriptorReadMasterBurst ]
	set enableUnalignedTransfers [ proc_get_boolean_parameter enableUnalignedTransfers ]
	set internalFIFODepth [ get_parameter_value internalFIFODepth ]
	set readBlockDataWidth [ get_parameter_value readBlockDataWidth ]
	set readBurstcountWidth [ get_parameter_value readBurstcountWidth ]
	set sinkErrorWidth [ get_parameter_value sinkErrorWidth ]
	set sourceErrorWidth [ get_parameter_value sourceErrorWidth ]
	set transferMode [ get_parameter_value transferMode ]
	set writeBurstcountWidth [ get_parameter_value writeBurstcountWidth ]

	# validate parameter and update derived parameter
	set actualDataTransferFIFODepth [ get_parameter_value actualDataTransferFIFODepth ]
	set byteEnableWidth [ get_parameter_value byteEnableWidth ]
	set commandFIFODataWidth [ get_parameter_value commandFIFODataWidth ]
	set emptyWidth [ get_parameter_value emptyWidth ]
	set hasReadBlock [ proc_get_boolean_parameter hasReadBlock ]
	set hasWriteBlock [ proc_get_boolean_parameter hasWriteBlock ]
	set symbolsPerBeat [ get_parameter_value symbolsPerBeat ]

	set memory_to_memory [ expr "{$transferMode}" == "{MEMORY_TO_MEMORY}" ]
	set memory_to_stream [ expr "{$transferMode}" == "{MEMORY_TO_STREAM}" ]
	set stream_to_memory [ expr "{$transferMode}" == "{STREAM_TO_MEMORY}" ]
	set hasReadBlock [ expr $memory_to_memory || $memory_to_stream ]
	set hasWriteBlock [ expr $memory_to_memory || $stream_to_memory ]
	
	set actualDataTransferFIFODepth [ expr 128 * 32 / ( 2 * $readBlockDataWidth ) ]
	set byteEnableWidth [ expr $readBlockDataWidth / 8 ]
	set commandFIFODataWidth [ expr (2 * 8) + (2 * $addressWidth) + 8 + 16 ]
	set symbolsPerBeat [ expr $readBlockDataWidth / 8 ]
	set emptyWidth [ log2ceil $symbolsPerBeat ]
	
	if { $deviceFamilyString == "Unknown" || $deviceFamilyString == "NONE" } {
		send_message error "Device family is unknown."
	}

	# GUI parameter enabling and disabling
	set_parameter_property sinkErrorWidth ENABLED "$stream_to_memory"
	set_parameter_property sourceErrorWidth ENABLED "$memory_to_stream"
	set_parameter_property dataTransferFIFODepth ENABLED "$memory_to_memory"
	
	if { $enableBurstTransfers && $hasReadBlock } {
	    set_parameter_property readBurstcountWidth ENABLED 1
	} else {
	    set_parameter_property readBurstcountWidth ENABLED 0
	}
	
	if { $enableBurstTransfers && $hasWriteBlock } {
	    set_parameter_property writeBurstcountWidth ENABLED 1
	} else {
	    set_parameter_property writeBurstcountWidth ENABLED 0
	}
	
	if { !$enableBurstTransfers } {
	    set_parameter_property enableUnalignedTransfers ENABLED 1
	} else {
	    set_parameter_property enableUnalignedTransfers ENABLED 0
	}
	
	if { !$enableBurstTransfers } {
	    set_parameter_property dataTransferFIFODepth ENABLED 1
	} else {
	    set_parameter_property dataTransferFIFODepth ENABLED 0
	}
	
	if { $enableBurstTransfers } {
	    set_parameter_property alwaysDoMaxBurst ENABLED 1
	} else {
	    set_parameter_property alwaysDoMaxBurst ENABLED 0
	}
	
	if { !$enableUnalignedTransfers } {
	    set_parameter_property enableBurstTransfers ENABLED 1
	} else {
	    set_parameter_property enableBurstTransfers ENABLED 0
	}
	
	# embedded software assignments

	set_module_assignment embeddedsw.CMacro.ADDRESS_WIDTH $addressWidth
	set_module_assignment embeddedsw.CMacro.ALWAYS_DO_MAX_BURST "$alwaysDoMaxBurst"
	set_module_assignment embeddedsw.CMacro.ATLANTIC_CHANNEL_DATA_WIDTH {4}
	set_module_assignment embeddedsw.CMacro.AVALON_MM_BYTE_REORDER_MODE "$avalonMMByteReorderMode"
	set_module_assignment embeddedsw.CMacro.BURST_DATA_WIDTH {8}
	set_module_assignment embeddedsw.CMacro.BURST_TRANSFER "$enableBurstTransfers"
	set_module_assignment embeddedsw.CMacro.BYTES_TO_TRANSFER_DATA_WIDTH {16}
	set_module_assignment embeddedsw.CMacro.CHAIN_WRITEBACK_DATA_WIDTH {32}
	set_module_assignment embeddedsw.CMacro.COMMAND_FIFO_DATA_WIDTH "$commandFIFODataWidth"
	set_module_assignment embeddedsw.CMacro.CONTROL_DATA_WIDTH {8}
	set_module_assignment embeddedsw.CMacro.CONTROL_SLAVE_ADDRESS_WIDTH {4}
	set_module_assignment embeddedsw.CMacro.CONTROL_SLAVE_DATA_WIDTH {32}
	set_module_assignment embeddedsw.CMacro.DESCRIPTOR_READ_BURST "$enableDescriptorReadMasterBurst"
	set_module_assignment embeddedsw.CMacro.DESC_DATA_WIDTH {32}
	set_module_assignment embeddedsw.CMacro.HAS_READ_BLOCK "$hasReadBlock"
	set_module_assignment embeddedsw.CMacro.HAS_WRITE_BLOCK "$hasWriteBlock"
	set_module_assignment embeddedsw.CMacro.IN_ERROR_WIDTH "$sinkErrorWidth"
	set_module_assignment embeddedsw.CMacro.OUT_ERROR_WIDTH "$sourceErrorWidth"
	set_module_assignment embeddedsw.CMacro.READ_BLOCK_DATA_WIDTH "$readBlockDataWidth"
	set_module_assignment embeddedsw.CMacro.READ_BURSTCOUNT_WIDTH "$readBurstcountWidth"
	set_module_assignment embeddedsw.CMacro.STATUS_TOKEN_DATA_WIDTH {24}
	set_module_assignment embeddedsw.CMacro.STREAM_DATA_WIDTH "$readBlockDataWidth"
	if { $memory_to_stream || $stream_to_memory } {
		set_module_assignment embeddedsw.CMacro.SYMBOLS_PER_BEAT "$symbolsPerBeat"
	}
	set_module_assignment embeddedsw.CMacro.UNALIGNED_TRANSFER "$enableUnalignedTransfers"
	set_module_assignment embeddedsw.CMacro.WRITE_BLOCK_DATA_WIDTH "$readBlockDataWidth"
	set_module_assignment embeddedsw.CMacro.WRITE_BURSTCOUNT_WIDTH "$writeBurstcountWidth"


	# save derived parameter

	set_parameter_value actualDataTransferFIFODepth $actualDataTransferFIFODepth
	set_parameter_value byteEnableWidth $byteEnableWidth
	set_parameter_value commandFIFODataWidth $commandFIFODataWidth
	set_parameter_value emptyWidth $emptyWidth
	set_parameter_value hasReadBlock $hasReadBlock
	set_parameter_value hasWriteBlock $hasWriteBlock
	set_parameter_value symbolsPerBeat $symbolsPerBeat

}

#-------------------------------------------------------------------------------
# module elaboration
#-------------------------------------------------------------------------------

proc elaborate {} {

	# read parameter

	set actualDataTransferFIFODepth [ get_parameter_value actualDataTransferFIFODepth ]
	set addressWidth [ get_parameter_value addressWidth ]
	set alwaysDoMaxBurst [ proc_get_boolean_parameter alwaysDoMaxBurst ]
	set avalonMMByteReorderMode [ get_parameter_value avalonMMByteReorderMode ]
	set byteEnableWidth [ get_parameter_value byteEnableWidth ]
	set commandFIFODataWidth [ get_parameter_value commandFIFODataWidth ]
	set dataTransferFIFODepth [ get_parameter_value dataTransferFIFODepth ]
	set deviceFamilyString [ get_parameter_value deviceFamilyString ]
	set emptyWidth [ get_parameter_value emptyWidth ]
	set enableBurstTransfers [ proc_get_boolean_parameter enableBurstTransfers ]
	set enableDescriptorReadMasterBurst [ proc_get_boolean_parameter enableDescriptorReadMasterBurst ]
	set enableUnalignedTransfers [ proc_get_boolean_parameter enableUnalignedTransfers ]
	set hasReadBlock [ proc_get_boolean_parameter hasReadBlock ]
	set hasWriteBlock [ proc_get_boolean_parameter hasWriteBlock ]
	set internalFIFODepth [ get_parameter_value internalFIFODepth ]
	set readBlockDataWidth [ get_parameter_value readBlockDataWidth ]
	set readBurstcountWidth [ get_parameter_value readBurstcountWidth ]
	set sinkErrorWidth [ get_parameter_value sinkErrorWidth ]
	set sourceErrorWidth [ get_parameter_value sourceErrorWidth ]
	set symbolsPerBeat [ get_parameter_value symbolsPerBeat ]
	set transferMode [ get_parameter_value transferMode ]
	set writeBurstcountWidth [ get_parameter_value writeBurstcountWidth ]

	set memory_to_memory [ expr "{$transferMode}" == "{MEMORY_TO_MEMORY}" ]
	set memory_to_stream [ expr "{$transferMode}" == "{MEMORY_TO_STREAM}" ]
	set stream_to_memory [ expr "{$transferMode}" == "{STREAM_TO_MEMORY}" ]

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


	add_interface csr avalon slave
	set_interface_property csr addressAlignment {DYNAMIC}
	set_interface_property csr addressGroup {0}
	set_interface_property csr addressSpan {64}
	set_interface_property csr addressUnits {WORDS}
	set_interface_property csr alwaysBurstMaxBurst {0}
	set_interface_property csr associatedClock {clk}
	set_interface_property csr associatedReset {reset}
	set_interface_property csr bitsPerSymbol {8}
	set_interface_property csr bridgesToMaster {}
	set_interface_property csr burstOnBurstBoundariesOnly {0}
	set_interface_property csr burstcountUnits {WORDS}
	set_interface_property csr constantBurstBehavior {0}
	set_interface_property csr explicitAddressSpan {0}
	set_interface_property csr holdTime {0}
	set_interface_property csr interleaveBursts {0}
	set_interface_property csr isBigEndian {0}
	set_interface_property csr isFlash {0}
	set_interface_property csr isMemoryDevice {0}
	set_interface_property csr isNonVolatileStorage {0}
	set_interface_property csr linewrapBursts {0}
	set_interface_property csr maximumPendingReadTransactions {0}
	set_interface_property csr minimumUninterruptedRunLength {1}
	set_interface_property csr printableDevice {0}
	set_interface_property csr readLatency {0}
	set_interface_property csr readWaitStates {1}
	set_interface_property csr readWaitTime {1}
	set_interface_property csr registerIncomingSignals {0}
	set_interface_property csr registerOutgoingSignals {0}
	set_interface_property csr setupTime {0}
	set_interface_property csr timingUnits {Cycles}
	set_interface_property csr transparentBridge {0}
	set_interface_property csr wellBehavedWaitrequest {0}
	set_interface_property csr writeLatency {0}
	set_interface_property csr writeWaitStates {0}
	set_interface_property csr writeWaitTime {0}

	add_interface_port csr csr_chipselect chipselect Input 1
	add_interface_port csr csr_address address Input 4
	add_interface_port csr csr_read read Input 1
	add_interface_port csr csr_write write Input 1
	add_interface_port csr csr_writedata writedata Input 32
	add_interface_port csr csr_readdata readdata Output 32

	if { $memory_to_memory } {
	    set_interface_assignment csr embeddedsw.configuration.affectsTransactionsOnMasters {m_read m_write}
	} elseif { $memory_to_stream } {
	    set_interface_assignment csr embeddedsw.configuration.affectsTransactionsOnMasters {m_read}
	} else {
	    set_interface_assignment csr embeddedsw.configuration.affectsTransactionsOnMasters {m_write}
	}

	add_interface descriptor_read avalon master
	set_interface_property descriptor_read adaptsTo {}
	set_interface_property descriptor_read addressGroup {0}
	set_interface_property descriptor_read addressUnits {SYMBOLS}
	set_interface_property descriptor_read alwaysBurstMaxBurst {0}
	set_interface_property descriptor_read associatedClock {clk}
	set_interface_property descriptor_read associatedReset {reset}
	set_interface_property descriptor_read bitsPerSymbol {8}
	set_interface_property descriptor_read burstOnBurstBoundariesOnly {0}
	set_interface_property descriptor_read burstcountUnits {WORDS}
	set_interface_property descriptor_read constantBurstBehavior {0}
	set_interface_property descriptor_read dBSBigEndian {0}
	set_interface_property descriptor_read doStreamReads {0}
	set_interface_property descriptor_read doStreamWrites {0}
	set_interface_property descriptor_read holdTime {0}
	set_interface_property descriptor_read interleaveBursts {0}
	set_interface_property descriptor_read isAsynchronous {0}
	set_interface_property descriptor_read isBigEndian {0}
	set_interface_property descriptor_read isReadable {0}
	set_interface_property descriptor_read isWriteable {0}
	set_interface_property descriptor_read linewrapBursts {0}
	set_interface_property descriptor_read maxAddressWidth {32}
	set_interface_property descriptor_read maximumPendingReadTransactions {0}
	set_interface_property descriptor_read readLatency {0}
	set_interface_property descriptor_read readWaitTime {1}
	set_interface_property descriptor_read registerIncomingSignals {0}
	set_interface_property descriptor_read registerOutgoingSignals {0}
	set_interface_property descriptor_read setupTime {0}
	set_interface_property descriptor_read timingUnits {Cycles}
	set_interface_property descriptor_read writeWaitTime {0}

	add_interface_port descriptor_read descriptor_read_readdata readdata Input 32
	add_interface_port descriptor_read descriptor_read_readdatavalid readdatavalid Input 1
	add_interface_port descriptor_read descriptor_read_waitrequest waitrequest Input 1
	add_interface_port descriptor_read descriptor_read_address address Output 32
	add_interface_port descriptor_read descriptor_read_read read Output 1
	if {$enableDescriptorReadMasterBurst} {
		add_interface_port descriptor_read descriptor_read_burstcount burstcount Output 4
	}


	add_interface descriptor_write avalon master
	set_interface_property descriptor_write adaptsTo {}
	set_interface_property descriptor_write addressGroup {0}
	set_interface_property descriptor_write addressUnits {SYMBOLS}
	set_interface_property descriptor_write alwaysBurstMaxBurst {0}
	set_interface_property descriptor_write associatedClock {clk}
	set_interface_property descriptor_write associatedReset {reset}
	set_interface_property descriptor_write bitsPerSymbol {8}
	set_interface_property descriptor_write burstOnBurstBoundariesOnly {0}
	set_interface_property descriptor_write burstcountUnits {WORDS}
	set_interface_property descriptor_write constantBurstBehavior {0}
	set_interface_property descriptor_write dBSBigEndian {0}
	set_interface_property descriptor_write doStreamReads {0}
	set_interface_property descriptor_write doStreamWrites {0}
	set_interface_property descriptor_write holdTime {0}
	set_interface_property descriptor_write interleaveBursts {0}
	set_interface_property descriptor_write isAsynchronous {0}
	set_interface_property descriptor_write isBigEndian {0}
	set_interface_property descriptor_write isReadable {0}
	set_interface_property descriptor_write isWriteable {1}
	set_interface_property descriptor_write linewrapBursts {0}
	set_interface_property descriptor_write maxAddressWidth {32}
	set_interface_property descriptor_write maximumPendingReadTransactions {0}
	set_interface_property descriptor_write readLatency {0}
	set_interface_property descriptor_write readWaitTime {1}
	set_interface_property descriptor_write registerIncomingSignals {0}
	set_interface_property descriptor_write registerOutgoingSignals {0}
	set_interface_property descriptor_write setupTime {0}
	set_interface_property descriptor_write timingUnits {Cycles}
	set_interface_property descriptor_write writeWaitTime {0}

	add_interface_port descriptor_write descriptor_write_waitrequest waitrequest Input 1
	add_interface_port descriptor_write descriptor_write_address address Output 32
	add_interface_port descriptor_write descriptor_write_write write Output 1
	add_interface_port descriptor_write descriptor_write_writedata writedata Output 32


	add_interface csr_irq interrupt sender
	set_interface_property csr_irq associatedAddressablePoint {csr}
	set_interface_property csr_irq associatedClock {clk}
	set_interface_property csr_irq associatedReset {reset}
	set_interface_property csr_irq irqScheme {NONE}

	add_interface_port csr_irq csr_irq irq Output 1

	if { $hasReadBlock } {
	add_interface m_read avalon master
	set_interface_property m_read adaptsTo {}
	set_interface_property m_read addressGroup {0}
	set_interface_property m_read addressUnits {SYMBOLS}
	set_interface_property m_read alwaysBurstMaxBurst {0}
	set_interface_property m_read associatedClock {clk}
	set_interface_property m_read associatedReset {reset}
	set_interface_property m_read bitsPerSymbol {8}
	set_interface_property m_read burstOnBurstBoundariesOnly {0}
	set_interface_property m_read burstcountUnits {WORDS}
	set_interface_property m_read constantBurstBehavior {0}
	set_interface_property m_read dBSBigEndian {0}
	set_interface_property m_read doStreamReads {0}
	set_interface_property m_read doStreamWrites {0}
	set_interface_property m_read holdTime {0}
	set_interface_property m_read interleaveBursts {0}
	set_interface_property m_read isAsynchronous {0}
	set_interface_property m_read isBigEndian {0}
	set_interface_property m_read isReadable {0}
	set_interface_property m_read isWriteable {0}
	set_interface_property m_read linewrapBursts {0}
	set_interface_property m_read maxAddressWidth {32}
	set_interface_property m_read maximumPendingReadTransactions {0}
	set_interface_property m_read readLatency {0}
	set_interface_property m_read readWaitTime {1}
	set_interface_property m_read registerIncomingSignals {0}
	set_interface_property m_read registerOutgoingSignals {0}
	set_interface_property m_read setupTime {0}
	set_interface_property m_read timingUnits {Cycles}
	set_interface_property m_read writeWaitTime {0}

	add_interface_port m_read m_read_readdata readdata Input "$readBlockDataWidth"
	add_interface_port m_read m_read_readdatavalid readdatavalid Input 1
	add_interface_port m_read m_read_waitrequest waitrequest Input 1
	add_interface_port m_read m_read_address address Output "$addressWidth"
	add_interface_port m_read m_read_read read Output 1
	if {$enableBurstTransfers} {
		add_interface_port m_read m_read_burstcount burstcount Output "$readBurstcountWidth"
	}
	}

	if { $stream_to_memory } {
	add_interface in avalon_streaming sink
	set_interface_property in associatedClock {clk}
	set_interface_property in associatedReset {reset}
	set_interface_property in beatsPerCycle {1}
	set_interface_property in dataBitsPerSymbol {8}
	set_interface_property in emptyWithinPacket {0}
	set_interface_property in firstSymbolInHighOrderBits {1}
	set_interface_property in highOrderSymbolAtMSB {0}
	set_interface_property in maxChannel {0}
	set_interface_property in readyLatency {0}
	set_interface_property in symbolsPerBeat "$symbolsPerBeat"

	add_interface_port in in_startofpacket startofpacket Input 1
	add_interface_port in in_endofpacket endofpacket Input 1
	add_interface_port in in_data data Input "$readBlockDataWidth"
	add_interface_port in in_valid valid Input 1
	add_interface_port in in_ready ready Output 1
	if { $symbolsPerBeat > 1 } {
		add_interface_port in in_empty empty Input "$emptyWidth"
	}
	if { $sinkErrorWidth != 0 } {
		add_interface_port in in_error error Input "$sinkErrorWidth"
	}
	}
	
	if { $hasWriteBlock } {
	add_interface m_write avalon master
	set_interface_property m_write adaptsTo {}
	set_interface_property m_write addressGroup {0}
	set_interface_property m_write addressUnits {SYMBOLS}
	set_interface_property m_write alwaysBurstMaxBurst {0}
	set_interface_property m_write associatedClock {clk}
	set_interface_property m_write associatedReset {reset}
	set_interface_property m_write bitsPerSymbol {8}
	set_interface_property m_write burstOnBurstBoundariesOnly {0}
	set_interface_property m_write burstcountUnits {WORDS}
	set_interface_property m_write constantBurstBehavior {0}
	set_interface_property m_write dBSBigEndian {0}
	set_interface_property m_write doStreamReads {0}
	set_interface_property m_write doStreamWrites {0}
	set_interface_property m_write holdTime {0}
	set_interface_property m_write interleaveBursts {0}
	set_interface_property m_write isAsynchronous {0}
	set_interface_property m_write isBigEndian {0}
	set_interface_property m_write isReadable {0}
	set_interface_property m_write isWriteable {1}
	set_interface_property m_write linewrapBursts {0}
	set_interface_property m_write maxAddressWidth {32}
	set_interface_property m_write maximumPendingReadTransactions {0}
	set_interface_property m_write readLatency {0}
	set_interface_property m_write readWaitTime {1}
	set_interface_property m_write registerIncomingSignals {0}
	set_interface_property m_write registerOutgoingSignals {0}
	set_interface_property m_write setupTime {0}
	set_interface_property m_write timingUnits {Cycles}
	set_interface_property m_write writeWaitTime {0}

	add_interface_port m_write m_write_waitrequest waitrequest Input 1
	add_interface_port m_write m_write_address address Output "$addressWidth"
	add_interface_port m_write m_write_write write Output 1
	add_interface_port m_write m_write_writedata writedata Output "$readBlockDataWidth"
	if { $byteEnableWidth > 1 } {
		add_interface_port m_write m_write_byteenable byteenable Output "$byteEnableWidth"
	}
	if { $enableBurstTransfers } {
		add_interface_port m_write m_write_burstcount burstcount Output "$writeBurstcountWidth"
	}
	}

	if { $memory_to_stream } {
	add_interface out avalon_streaming source
	set_interface_property out associatedClock {clk}
	set_interface_property out associatedReset {reset}
	set_interface_property out beatsPerCycle {1}
	set_interface_property out dataBitsPerSymbol {8}
	set_interface_property out emptyWithinPacket {0}
	set_interface_property out firstSymbolInHighOrderBits {1}
	set_interface_property out highOrderSymbolAtMSB {0}
	set_interface_property out maxChannel {0}
	set_interface_property out readyLatency {0}
	set_interface_property out symbolsPerBeat "$symbolsPerBeat"

	add_interface_port out out_data data Output "$readBlockDataWidth"
	add_interface_port out out_valid valid Output 1
	add_interface_port out out_ready ready Input 1
	add_interface_port out out_endofpacket endofpacket Output 1
	add_interface_port out out_startofpacket startofpacket Output 1
	if { $symbolsPerBeat > 1 } {
		add_interface_port out out_empty empty Output "$emptyWidth"
	}
	if { $sourceErrorWidth != 0 } {
		add_interface_port out out_error error Output "$sourceErrorWidth"
	}
	}

}

#-------------------------------------------------------------------------------
# module generation
#-------------------------------------------------------------------------------

proc sub_quartus_synth {NAME} {
    set rtl_ext "v"
    set simulation  0
    set output_directory [ add_fileset_file dummy.txt OTHER TEMP "" ]

    generate                    "$NAME" "$output_directory" "$rtl_ext" "$simulation"
}

proc sub_sim_verilog {NAME} {
    set rtl_ext "v"
    set simulation  1
    set output_directory [ add_fileset_file dummy.txt OTHER TEMP "" ]

    generate                    "$NAME" "$output_directory" "$rtl_ext" "$simulation"
}

proc sub_sim_vhdl {NAME} {
    set rtl_ext "vhd"
    set simulation  1
    set output_directory [ add_fileset_file dummy.txt OTHER TEMP "" ]

    generate                    "$NAME" "$output_directory" "$rtl_ext" "$simulation"
}

# generate
proc generate {output_name output_directory rtl_ext simulation} {
	global env
	set QUARTUS_ROOTDIR         "$env(QUARTUS_ROOTDIR)"
	set component_directory     "$QUARTUS_ROOTDIR/../ip/altera/sopc_builder_ip/altera_avalon_sgdma"
	set component_config_file   "$output_directory/${output_name}_component_configuration.pl"

	# read parameter

	set actualDataTransferFIFODepth [ get_parameter_value actualDataTransferFIFODepth ]
	set addressWidth [ get_parameter_value addressWidth ]
	set alwaysDoMaxBurst [ proc_get_boolean_parameter alwaysDoMaxBurst ]
	set avalonMMByteReorderMode [ get_parameter_value avalonMMByteReorderMode ]
	set byteEnableWidth [ get_parameter_value byteEnableWidth ]
	set commandFIFODataWidth [ get_parameter_value commandFIFODataWidth ]
	set dataTransferFIFODepth [ get_parameter_value dataTransferFIFODepth ]
	set deviceFamilyString [ get_parameter_value deviceFamilyString ]
	set emptyWidth [ get_parameter_value emptyWidth ]
	set enableBurstTransfers [ proc_get_boolean_parameter enableBurstTransfers ]
	set enableDescriptorReadMasterBurst [ proc_get_boolean_parameter enableDescriptorReadMasterBurst ]
	set enableUnalignedTransfers [ proc_get_boolean_parameter enableUnalignedTransfers ]
	set hasReadBlock [ proc_get_boolean_parameter hasReadBlock ]
	set hasWriteBlock [ proc_get_boolean_parameter hasWriteBlock ]
	set internalFIFODepth [ get_parameter_value internalFIFODepth ]
	set readBlockDataWidth [ get_parameter_value readBlockDataWidth ]
	set readBurstcountWidth [ get_parameter_value readBurstcountWidth ]
	set sinkErrorWidth [ get_parameter_value sinkErrorWidth ]
	set sourceErrorWidth [ get_parameter_value sourceErrorWidth ]
	set symbolsPerBeat [ get_parameter_value symbolsPerBeat ]
	set transferMode [ get_parameter_value transferMode ]
	set writeBurstcountWidth [ get_parameter_value writeBurstcountWidth ]

	#update derived parameter 
	set derived_device_family [ string2upper_noSpace "$deviceFamilyString" ]

	# prepare config file
	set component_config    [open $component_config_file "w"]

	puts $component_config "# ${output_name} Component Configuration File"
	puts $component_config "return {"

	puts $component_config "\tread_block_data_width	=> $readBlockDataWidth,"
	puts $component_config "\twrite_block_data_width	=> $readBlockDataWidth,"
	puts $component_config "\tstream_data_width	=> $readBlockDataWidth,"
	puts $component_config "\taddress_width	=> $addressWidth,"
	puts $component_config "\thas_read_block	=> $hasReadBlock,"
	puts $component_config "\thas_write_block	=> $hasWriteBlock,"
	puts $component_config "\tread_burstcount_width	=> $readBurstcountWidth,"
	puts $component_config "\twrite_burstcount_width	=> $writeBurstcountWidth,"
	puts $component_config "\tburst_transfer	=> $enableBurstTransfers,"
	puts $component_config "\talways_do_max_burst	=> $alwaysDoMaxBurst,"
	puts $component_config "\tdescriptor_read_burst	=> $enableDescriptorReadMasterBurst,"
	puts $component_config "\tunaligned_transfer	=> $enableUnalignedTransfers,"
	puts $component_config "\tavalon_mm_byte_reorder_mode	=> $avalonMMByteReorderMode,"
	puts $component_config "\tcontrol_slave_data_width	=> 32,"
	puts $component_config "\tcontrol_slave_address_width	=> 4,"
	puts $component_config "\tdesc_data_width	=> 32,"
	puts $component_config "\tdescriptor_writeback_data_width	=> 32,"
	puts $component_config "\tstatus_token_data_width	=> 24,"
	puts $component_config "\tbytes_to_transfer_data_width	=> 16,"
	puts $component_config "\tburst_data_width	=> 8,"
	puts $component_config "\tcontrol_data_width	=> 8,"
	puts $component_config "\tstatus_data_width	=> 8,"
	puts $component_config "\tatlantic_channel_data_width	=> 4,"
	puts $component_config "\tcommand_fifo_data_width	=> $commandFIFODataWidth,"
	puts $component_config "\tsymbols_per_beat	=> $symbolsPerBeat,"
	puts $component_config "\tin_error_width	=> $sinkErrorWidth,"
	puts $component_config "\tout_error_width	=> $sourceErrorWidth,"
	puts $component_config "\tDevice_Family	=> $derived_device_family,"

	puts $component_config "};"
	close $component_config

	# generate rtl
	proc_generate_component_rtl  "$component_config_file" "$component_directory" "$output_name" "$output_directory" "$rtl_ext" "$simulation"
	proc_add_generated_files "$output_name" "$output_directory" "$rtl_ext" "$simulation"
}

