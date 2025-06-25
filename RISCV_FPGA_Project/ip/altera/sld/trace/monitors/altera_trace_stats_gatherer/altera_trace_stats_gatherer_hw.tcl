# (C) 2001-2013 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License Subscription 
# Agreement, Altera MegaCore Function License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


# $Id: //acds/rel/13.1/ip/sld/trace/monitors/altera_trace_stats_gatherer/altera_trace_stats_gatherer_hw.tcl#2 $
# $Revision: #2 $
# $Date: 2013/08/15 $
# $Author: aferrucc $
# 
package require -exact qsys 13.0
package require -exact altera_terp 1.0

# 
# module altera_trace_stats_gatherer
# 
set_module_property DESCRIPTION ""
set_module_property NAME altera_trace_stats_gatherer
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Verification/Debug & Performance"
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Altera Trace Statistics Gatherer"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL AUTO
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property ELABORATION_CALLBACK elaborate

add_fileset impl_fileset QUARTUS_SYNTH generate
add_fileset impl_fileset SIM_VERILOG generate
add_fileset impl_fileset SIM_VHDL generate

# parameter groups
add_display_item {} {Sample period} GROUP
add_display_item {} {Initial settings} GROUP
add_display_item {} {SYSTEM_INFO} GROUP
add_display_item {} {Derived parameters} GROUP

# 
# parameters
# 
add_parameter START_ENABLED BOOLEAN false
set_parameter_property START_ENABLED DISPLAY_NAME START_ENABLED
set_parameter_property START_ENABLED UNITS None
set_parameter_property START_ENABLED HDL_PARAMETER false

add_parameter SAMPLE_PERIOD FLOAT 1
set_parameter_property SAMPLE_PERIOD HDL_PARAMETER false
set_parameter_property SAMPLE_PERIOD DISPLAY_NAME "Sample period"

add_parameter SAMPLE_PERIOD_UNITS STRING MSEC
set_parameter_property SAMPLE_PERIOD_UNITS HDL_PARAMETER false
set_parameter_property SAMPLE_PERIOD_UNITS DISPLAY_NAME "Units of sample period"
set_parameter_property SAMPLE_PERIOD_UNITS ALLOWED_RANGES {USEC:us MSEC:ms SEC:s}

add_parameter MAX_SAMPLE_PERIOD FLOAT 10
set_parameter_property MAX_SAMPLE_PERIOD HDL_PARAMETER false
set_parameter_property MAX_SAMPLE_PERIOD DISPLAY_NAME "Maximum sample period"

add_parameter MAX_SAMPLE_PERIOD_UNITS STRING MSEC
set_parameter_property MAX_SAMPLE_PERIOD_UNITS HDL_PARAMETER false
set_parameter_property MAX_SAMPLE_PERIOD_UNITS DISPLAY_NAME "Units of maximum sample period"
set_parameter_property MAX_SAMPLE_PERIOD_UNITS ALLOWED_RANGES {USEC:us MSEC:ms SEC:s}

# not-visible parameters
add_parameter CAPTURE_DATAWIDTH INTEGER 32
set_parameter_property CAPTURE_DATAWIDTH UNITS None
set_parameter_property CAPTURE_DATAWIDTH HDL_PARAMETER false
set_parameter_property CAPTURE_DATAWIDTH VISIBLE false

add_parameter CAPTURE_EMPTYWIDTH INTEGER 2
set_parameter_property CAPTURE_EMPTYWIDTH UNITS None
set_parameter_property CAPTURE_EMPTYWIDTH HDL_PARAMETER false
set_parameter_property CAPTURE_EMPTYWIDTH VISIBLE false

add_parameter CONTROL_DATAWIDTH INTEGER 32
set_parameter_property CONTROL_DATAWIDTH UNITS None
set_parameter_property CONTROL_DATAWIDTH HDL_PARAMETER false
set_parameter_property CONTROL_DATAWIDTH VISIBLE false

add_parameter DATA_ADDRESSWIDTH INTEGER 32
set_parameter_property DATA_ADDRESSWIDTH UNITS None
set_parameter_property DATA_ADDRESSWIDTH HDL_PARAMETER false
set_parameter_property DATA_ADDRESSWIDTH SYSTEM_INFO {ADDRESS_WIDTH data}
set_parameter_property DATA_ADDRESSWIDTH VISIBLE false

add_parameter CONFIG_ADDRESSWIDTH INTEGER 32
set_parameter_property CONFIG_ADDRESSWIDTH UNITS None
set_parameter_property CONFIG_ADDRESSWIDTH HDL_PARAMETER false
set_parameter_property CONFIG_ADDRESSWIDTH SYSTEM_INFO {ADDRESS_WIDTH config}
set_parameter_property CONFIG_ADDRESSWIDTH VISIBLE false

add_parameter CLOCK_RATE INTEGER
set_parameter_property CLOCK_RATE SYSTEM_INFO {CLOCK_RATE clock}
set_parameter_property CLOCK_RATE HDL_PARAMETER false
set_parameter_property CLOCK_RATE TYPE LONG
set_parameter_property CLOCK_RATE VISIBLE false

add_parameter ADDRESS_MAP STRING
set_parameter_property ADDRESS_MAP SYSTEM_INFO {ADDRESS_MAP data}
set_parameter_property ADDRESS_MAP HDL_PARAMETER false
set_parameter_property ADDRESS_MAP TYPE STRING
set_parameter_property ADDRESS_MAP VISIBLE false

add_parameter TIMER_RELOAD INTEGER 
set_parameter_property TIMER_RELOAD TYPE INTEGER
set_parameter_property TIMER_RELOAD UNITS None
set_parameter_property TIMER_RELOAD HDL_PARAMETER false
set_parameter_property TIMER_RELOAD DERIVED true
set_parameter_property TIMER_RELOAD VISIBLE false 

add_parameter COUNT_WIDTH INTEGER
set_parameter_property COUNT_WIDTH HDL_PARAMETER false
set_parameter_property COUNT_WIDTH DERIVED true
set_parameter_property COUNT_WIDTH VISIBLE false

add_parameter FULL_TS_LENGTH INTEGER 24
set_parameter_property FULL_TS_LENGTH DEFAULT_VALUE 24
set_parameter_property FULL_TS_LENGTH DISPLAY_NAME FULL_TS_LENGTH
set_parameter_property FULL_TS_LENGTH TYPE INTEGER
set_parameter_property FULL_TS_LENGTH UNITS None
set_parameter_property FULL_TS_LENGTH VISIBLE false
set_parameter_property FULL_TS_LENGTH HDL_PARAMETER false

add_parameter NUM_SLAVES INTEGER
set_parameter_property NUM_SLAVES HDL_PARAMETER false
set_parameter_property NUM_SLAVES DERIVED true
set_parameter_property NUM_SLAVES VISIBLE false

add_parameter USE_INTERNAL_FIFO BOOLEAN false
set_parameter_property USE_INTERNAL_FIFO DISPLAY_NAME INTERNAL_FIFO
set_parameter_property USE_INTERNAL_FIFO UNITS None
set_parameter_property USE_INTERNAL_FIFO HDL_PARAMETER false

# The docs say INTEGER_LIST is a list of 32-bit integers.  Is it really limited
# to 32 bits? If so, I can't represent a 64-bit base address, and I need
# another solution.
add_parameter BASE_ADDRESSES INTEGER_LIST
set_parameter_property BASE_ADDRESSES HDL_PARAMETER false
set_parameter_property BASE_ADDRESSES DERIVED true
set_parameter_property BASE_ADDRESSES VISIBLE false

add_parameter END_ADDRESSES INTEGER_LIST
set_parameter_property END_ADDRESSES HDL_PARAMETER false
set_parameter_property END_ADDRESSES DERIVED true
set_parameter_property END_ADDRESSES VISIBLE false

add_parameter SPANS INTEGER_LIST
set_parameter_property SPANS HDL_PARAMETER false
set_parameter_property SPANS DERIVED true
set_parameter_property SPANS VISIBLE false

add_parameter SPANWIDTH INTEGER
set_parameter_property SPANWIDTH HDL_PARAMETER false
set_parameter_property SPANWIDTH DERIVED true
set_parameter_property SPANWIDTH VISIBLE false

add_parameter PAYLOAD_SIZE INTEGER
set_parameter_property PAYLOAD_SIZE HDL_PARAMETER false
set_parameter_property PAYLOAD_SIZE DERIVED true
set_parameter_property PAYLOAD_SIZE VISIBLE false

add_parameter PAYLOAD_COUNTER_WIDTH INTEGER
set_parameter_property PAYLOAD_COUNTER_WIDTH HDL_PARAMETER false
set_parameter_property PAYLOAD_COUNTER_WIDTH DERIVED true
set_parameter_property PAYLOAD_COUNTER_WIDTH VISIBLE false

add_parameter FIFO_SIZE INTEGER
set_parameter_property FIFO_SIZE HDL_PARAMETER false
set_parameter_property FIFO_SIZE DERIVED true
set_parameter_property FIFO_SIZE VISIBLE false

add_parameter EMPTY_THRESHOLD INTEGER
set_parameter_property EMPTY_THRESHOLD HDL_PARAMETER false
set_parameter_property EMPTY_THRESHOLD DERIVED true
set_parameter_property EMPTY_THRESHOLD VISIBLE false

# 
# display items
# 
add_display_item {Sample period} SAMPLE_PERIOD PARAMETER
add_display_item {Sample period} SAMPLE_PERIOD_UNITS PARAMETER
add_display_item {Sample period} MAX_SAMPLE_PERIOD PARAMETER
add_display_item {Sample period} MAX_SAMPLE_PERIOD_UNITS PARAMETER

add_display_item {Initial settings} START_ENABLED PARAMETER

# 
# connection point capture
# 
add_interface capture avalon_streaming start
set_interface_property capture associatedClock clock
set_interface_property capture associatedReset reset
set_interface_property capture dataBitsPerSymbol 8
set_interface_property capture errorDescriptor ""
set_interface_property capture firstSymbolInHighOrderBits true
set_interface_property capture maxChannel 0
set_interface_property capture readyLatency 0
set_interface_property capture ENABLED true
set_interface_property capture EXPORT_OF ""
set_interface_property capture PORT_NAME_MAP ""
set_interface_property capture SVD_ADDRESS_GROUP ""

add_interface_port capture capture_endofpacket endofpacket Output 1
add_interface_port capture capture_data data Output CAPTURE_DATAWIDTH
add_interface_port capture capture_valid valid Output 1
add_interface_port capture capture_ready ready Input 1
add_interface_port capture capture_startofpacket startofpacket Output 1
add_interface_port capture capture_empty empty Output CAPTURE_EMPTYWIDTH

set_interface_assignment capture debug.providesServices {traceMonitor internalMaster}
set_interface_assignment capture debug.interfaceGroup {associatedControl control}
set_interface_assignment capture debug.visible true

set_interface_assignment capture debug.param.setting.Enable {
  proc get_value {c i} {expr [trace_read_monitor $c $i 4] != 0}
  proc set_value {c i v} {trace_write_monitor $c $i 4 [expr ($v != 0) ? 1 : 0]}
  set hints boolean
}

set_interface_assignment capture debug.param.setting.Interval {
  proc get_value {c i} {expr [ trace_read_monitor $c $i 5] + 1}
    proc set_value {c i v} {trace_write_monitor $c $i 5 [expr $v - 1]}
}

# 
# connection point control
# 
add_interface control avalon end
set_interface_property control addressUnits SYMBOLS
set_interface_property control associatedClock clock
set_interface_property control associatedReset reset
set_interface_property control bitsPerSymbol 8
set_interface_property control burstOnBurstBoundariesOnly false
set_interface_property control burstcountUnits WORDS
set_interface_property control explicitAddressSpan 0
set_interface_property control holdTime 0
set_interface_property control linewrapBursts false
set_interface_property control maximumPendingReadTransactions 1
set_interface_property control readLatency 0
set_interface_property control readWaitTime 0
set_interface_property control setupTime 0
set_interface_property control timingUnits Cycles
set_interface_property control writeWaitTime 1
set_interface_property control ENABLED true
set_interface_property control EXPORT_OF ""
set_interface_property control PORT_NAME_MAP ""
set_interface_property control SVD_ADDRESS_GROUP ""

proc get_control_addresswidth {} {
  return 6
}

add_interface_port control control_address address Input [ get_control_addresswidth ]
add_interface_port control control_read read Input 1
add_interface_port control control_write write Input 1
add_interface_port control control_writedata writedata Input CONTROL_DATAWIDTH
add_interface_port control control_readdata readdata Output CONTROL_DATAWIDTH
add_interface_port control control_readdatavalid readdatavalid Output 1
add_interface_port control control_waitrequest waitrequest Output 1
set_interface_assignment control embeddedsw.configuration.isFlash 0
set_interface_assignment control embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment control embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment control embeddedsw.configuration.isPrintableDevice 0


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset reset Input 1


# 
# connection point data
# 
add_interface data avalon start
set_interface_property data addressUnits SYMBOLS
set_interface_property data associatedClock clock
set_interface_property data associatedReset reset
set_interface_property data bitsPerSymbol 8
set_interface_property data burstOnBurstBoundariesOnly false
set_interface_property data burstcountUnits WORDS
set_interface_property data doStreamReads false
set_interface_property data doStreamWrites false
set_interface_property data holdTime 0
set_interface_property data linewrapBursts false
set_interface_property data maximumPendingReadTransactions 0
set_interface_property data readLatency 0
set_interface_property data readWaitTime 0
set_interface_property data setupTime 0
set_interface_property data timingUnits Cycles
set_interface_property data writeWaitTime 0
set_interface_property data ENABLED true
set_interface_property data EXPORT_OF ""
set_interface_property data PORT_NAME_MAP ""
set_interface_property data SVD_ADDRESS_GROUP ""

set_interface_assignment data debug.controlledBy capture
set_interface_assignment data debug.visible true

add_interface_port data data_readdata readdata Input CAPTURE_DATAWIDTH
add_interface_port data data_byteenable byteenable Output CAPTURE_DATAWIDTH/8
add_interface_port data data_read read Output 1
add_interface_port data data_address address Output DATA_ADDRESSWIDTH
add_interface_port data data_readdatavalid readdatavalid Input 1
add_interface_port data data_waitrequest waitrequest Input 1

# 
# connection point config
# 
add_interface config avalon start
set_interface_property config addressUnits SYMBOLS
set_interface_property config associatedClock clock
set_interface_property config associatedReset reset
set_interface_property config bitsPerSymbol 8
set_interface_property config burstOnBurstBoundariesOnly false
set_interface_property config burstcountUnits WORDS
set_interface_property config doStreamReads false
set_interface_property config doStreamWrites false
set_interface_property config holdTime 0
set_interface_property config linewrapBursts false
set_interface_property config maximumPendingReadTransactions 0
set_interface_property config readLatency 0
set_interface_property config readWaitTime 0
set_interface_property config setupTime 0
set_interface_property config timingUnits Cycles
set_interface_property config writeWaitTime 0
set_interface_property config ENABLED true
set_interface_property config EXPORT_OF ""
set_interface_property config PORT_NAME_MAP ""
set_interface_property config SVD_ADDRESS_GROUP ""

add_interface_port config config_readdata readdata Input CAPTURE_DATAWIDTH
add_interface_port config config_writedata writedata Output CAPTURE_DATAWIDTH
add_interface_port config config_byteenable byteenable Output CAPTURE_DATAWIDTH/8
add_interface_port config config_read read Output 1
add_interface_port config config_write write Output 1
add_interface_port config config_address address Output CONFIG_ADDRESSWIDTH
add_interface_port config config_readdatavalid readdatavalid Input 1
add_interface_port config config_waitrequest waitrequest Input 1

set_interface_assignment data debug.interfaceGroup {associatedConfig config}

# Convert the given value and time unit (USEC, MSEC, SEC) to seconds.
proc get_seconds { value_param unit_param } {
  set value [ get_parameter_value $value_param ]
  set unit [ get_parameter $unit_param ]
  set multiplier 0
  set multiplier [
    switch $unit {
      USEC    { set multiplier 0.000001 }
      MSEC    { set multiplier 0.001 }
      SEC     { set multiplier 1 }
    }
  ]

  return [ expr $value * $multiplier ]
}

# Compute the count value needed to encode the given period (time value,
# cycles) at the given clock rate.
proc get_cycles { period_param units_param clockrate_param } {
  set seconds [ get_seconds $period_param $units_param ]
  set cycles [ expr $seconds * [ get_parameter_value $clockrate_param ] ]
  return $cycles
}

# Compute the counter width needed to encode the given period (time value,
# cycles) at the given clock rate.
# N.b. this assumes a 0-based encoding, e.g. for an 8-cycle counter, values 0
# through 7 need representation, which requires 3 bits.
proc get_bit_width { period_param units_param clockrate_param } {
  set cycles [ get_cycles $period_param $units_param $clockrate_param ]
  set count_width [ expr ceil(log($cycles) / log(2.0)) ]
  return $count_width
}

proc elaborate {} {
  if { [ get_parameter_value CLOCK_RATE] == 0 } {
    send_message error "This component requires a known clock rate, but clock rate = 0"
  }

  set raw_addr_map [ get_parameter_value ADDRESS_MAP ]
  set addr_map [ decode_address_map $raw_addr_map ]
  foreach slave_info $addr_map {
    array set slave_info_array $slave_info
  }

  # calculate and assign the NUM_SLAVES parameter
  set num_slaves [ llength $addr_map ]
  set_parameter_value NUM_SLAVES $num_slaves

  # assign the BASE_ADDRESSES values
  set ba [ list ]
  foreach slave_info $addr_map {
    array set slave_info_array $slave_info
    lappend ba $slave_info_array(start)
  }
  set_parameter_value BASE_ADDRESSES $ba

  # assign the END_ADDRESSES values
  set end [ list ]
  foreach slave_info $addr_map {
    array set slave_info_array $slave_info
    lappend end $slave_info_array(end)
  }
  set_parameter_value END_ADDRESSES $end

  # assign the SPANS values
  # in passing, compute 
  #   the span counter width
  #   the payload size
  #   the payload counter width
  # Nb the SPANS are 0-based - that is, a slave with span=0x100 has
  # a SPANS value of 0xFF.  That's because the counter in the hardware
  # uses the 0 count for the final read within a span.
  set max_span -1
  set spans [ list ]
  set capture_numsymbols [ expr [ get_parameter_value CAPTURE_DATAWIDTH ] / 8 ]
  set payload_size 0
  foreach slave_info $addr_map {
    array set slave_info_array $slave_info
    set end $slave_info_array(end)
    set start $slave_info_array(start)
    set span [ expr -1 + ($end - $start) / $capture_numsymbols ]
    set payload_size [ expr $payload_size + $span + 1 ]
    if { $span > $max_span } {
      set max_span $span
    }
    lappend spans $span
  }
  
  set_parameter_value SPANS $spans
  set_parameter_value SPANWIDTH [ expr ceil(log($max_span + 1) / log(2.0)) ]
  set_parameter_value PAYLOAD_SIZE $payload_size
  set payload_counter_width [ expr ceil(log($payload_size) / log(2.0)) ]
  set_parameter_value PAYLOAD_COUNTER_WIDTH $payload_counter_width
  set packet_size [ expr $payload_size + 1 ]
  set fifo_size [ expr 2 ** ceil(log($packet_size) / log(2.0)) ]
  set_parameter_value FIFO_SIZE $fifo_size
  set empty_threshold [ expr $fifo_size - $packet_size ] 
  set_parameter_value EMPTY_THRESHOLD $empty_threshold

  # calculate and assign the COUNT_WIDTH parameter
  # function of: MAX_SAMPLE_PERIOD_UNITS, MAX_SAMPLE_PERIOD, CLOCK_RATE
  set count_width [ get_bit_width MAX_SAMPLE_PERIOD MAX_SAMPLE_PERIOD_UNITS CLOCK_RATE ]
  set_parameter_value COUNT_WIDTH $count_width

  # calculate and assign the TIMER_RELOAD parameter
  # function of: SAMPLE_PERIOD_UNITS, SAMPLE_PERIOD, CLOCK_RATE
  set_parameter_value TIMER_RELOAD [ expr -1 + [ get_cycles SAMPLE_PERIOD SAMPLE_PERIOD_UNITS CLOCK_RATE ] ]

  # validate that the max sample period is <= the sample period
  if { [ get_seconds SAMPLE_PERIOD SAMPLE_PERIOD_UNITS ] > [ get_seconds MAX_SAMPLE_PERIOD MAX_SAMPLE_PERIOD_UNITS ] } {
    send_message error {sample period must be <= max sample period}
  }
}

proc generate { instance_name } {
  # Get the terp filename
  set this_dir      [ get_module_property MODULE_DIRECTORY ]
  set template_file [ file join $this_dir "altera_trace_stats_gatherer.sv.terp" ]

  # read the terp filename
  set template_fh [ open $template_file r ]
  set template    [ read $template_fh ]
  close $template_fh

  # set terp parameters
  set params(output_name) $instance_name
  set params(capture_datawidth) [ get_parameter_value CAPTURE_DATAWIDTH ]
  set params(capture_emptywidth) [ get_parameter_value CAPTURE_EMPTYWIDTH ]
  set params(control_datawidth) [ get_parameter_value CONTROL_DATAWIDTH ]
  set params(control_addresswidth)  [ get_control_addresswidth ]
  set params(data_addresswidth) [ get_parameter_value DATA_ADDRESSWIDTH ]
  set params(config_addresswidth) [ get_parameter_value CONFIG_ADDRESSWIDTH ]
  set params(base_addresses) [ get_parameter_value BASE_ADDRESSES ]
  set params(end_addresses) [ get_parameter_value END_ADDRESSES ]
  set params(spans) [ get_parameter_value SPANS ]
  set params(spanwidth) [ get_parameter_value SPANWIDTH ]
  set params(num_slaves)     [ get_parameter_value NUM_SLAVES ]
  set params(count_width) [ get_parameter_value COUNT_WIDTH ]
  set params(timer_reload) [ get_parameter_value TIMER_RELOAD ]
  set params(full_ts_length) [ get_parameter_value FULL_TS_LENGTH ]
  set params(payload_size) [ get_parameter_value PAYLOAD_SIZE ]
  set params(payload_counter_width) [ get_parameter_value PAYLOAD_COUNTER_WIDTH ]

  set params(clock_rate) [ get_parameter_value CLOCK_RATE ]
  set params(sample_period) [ get_parameter_value SAMPLE_PERIOD ]
  set params(sample_period_units) [ get_parameter_value SAMPLE_PERIOD_UNITS ]
  set params(start_enabled) [ get_parameter_value START_ENABLED ]
  set params(use_internal_fifo) [ get_parameter_value USE_INTERNAL_FIFO ]
  set params(fifo_size) [ get_parameter_value FIFO_SIZE ]
  set params(empty_threshold) [ get_parameter_value EMPTY_THRESHOLD ]
  # generate hdl
  set result          [ altera_terp $template params ]

  # get output filename
  set output_file     [ create_temp_file ${instance_name}.sv ]
  set output_handle   [ open $output_file w ]

  # write the hdl
  puts $output_handle $result
  close $output_handle

  # declare the generated file.
  add_fileset_file ${instance_name}.sv SYSTEM_VERILOG PATH ${output_file}
}


