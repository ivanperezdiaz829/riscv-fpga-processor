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



# $Id: //acds/rel/13.1/ip/merlin/altera_tristate_controller_translator/altera_tristate_controller_translator_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

# +-----------------------------------
# | 
# | altera_tristate_controller_translator "Tristate Controller Translator" v1.0
# | 2008.10.15.13:20:06
# | 
# | 
# +-----------------------------------

package require -exact sopc 9.1

# +-----------------------------------
# | module altera_tristate_controller_translator
# | 
set_module_property NAME altera_tristate_controller_translator
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"
set_module_property GROUP "Tristate Components"
set_module_property DISPLAY_NAME "Tristate Controller Translator"
set_module_property TOP_LEVEL_HDL_FILE altera_tristate_controller_translator.sv
set_module_property TOP_LEVEL_HDL_MODULE altera_tristate_controller_translator
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ELABORATION_CALLBACK elaborate
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property INTERNAL true
set_module_property ANALYZE_HDL FALSE
set_module_property DATASHEET_URL http://www.altera.com/literature/hb/qts/qsys_interconnect.pdf
# | 
# +-----------------------------------

add_file altera_tristate_controller_translator.sv {SYNTHESIS SIMULATION}

# +-----------------------------------
# | parameters
# |
add_parameter UAV_DATA_W INTEGER 32
set_parameter_property UAV_DATA_W AFFECTS_ELABORATION true
set_parameter_property UAV_DATA_W HDL_PARAMETER true
set_parameter_property UAV_DATA_W DESCRIPTION {Width of the readdata, writedata signals - network side}
set_parameter_property UAV_DATA_W DISPLAY_NAME {Network Data width}

add_parameter UAV_BYTEENABLE_W INTEGER 4
set_parameter_property UAV_BYTEENABLE_W AFFECTS_ELABORATION true
set_parameter_property UAV_BYTEENABLE_W HDL_PARAMETER true
set_parameter_property UAV_BYTEENABLE_W DESCRIPTION {Width of the byteenable signal - networkside}
set_parameter_property UAV_BYTEENABLE_W DISPLAY_NAME {Network byteenable width}

add_parameter UAV_ADDRESS_W INTEGER 32
set_parameter_property UAV_ADDRESS_W AFFECTS_ELABORATION true
set_parameter_property UAV_ADDRESS_W HDL_PARAMETER true
set_parameter_property UAV_ADDRESS_W DESCRIPTION {Width of the address signal - network side}
set_parameter_property UAV_ADDRESS_W DISPLAY_NAME {Network address width}

add_parameter UAV_BURSTCOUNT_W INTEGER 4
set_parameter_property UAV_BURSTCOUNT_W AFFECTS_ELABORATION true
set_parameter_property UAV_BURSTCOUNT_W HDL_PARAMETER true
set_parameter_property UAV_BURSTCOUNT_W DESCRIPTION {Width of the burstcount signal - network side}
set_parameter_property UAV_BURSTCOUNT_W DISPLAY_NAME {Network burstcount width}

add_parameter MAX_PENDING_READ_TRANSACTIONS INTEGER 64
set_parameter_property MAX_PENDING_READ_TRANSACTIONS AFFECTS_ELABORATION true
set_parameter_property MAX_PENDING_READ_TRANSACTIONS HDL_PARAMETER false
set_parameter_property MAX_PENDING_READ_TRANSACTIONS ALLOWED_RANGES "0:32000"
set_parameter_property MAX_PENDING_READ_TRANSACTIONS DESCRIPTION {Avalon-MM maxPendingReadTransactions interface property}
set_parameter_property MAX_PENDING_READ_TRANSACTIONS DISPLAY_NAME {maxPendingReadTransactions}

add_parameter READLATENCY INTEGER 0
set_parameter_property READLATENCY AFFECTS_ELABORATION true
set_parameter_property READLATENCY HDL_PARAMETER false
set_parameter_property READLATENCY ALLOWED_RANGES "0:32000"
set_parameter_property READLATENCY DESCRIPTION {Avalon-MM readlatency interface property}
set_parameter_property READLATENCY DISPLAY_NAME {Read Latency}

add_parameter TURNAROUND_TIME INTEGER 0
set_parameter_property TURNAROUND_TIME AFFECTS_ELABORATION true
set_parameter_property TURNAROUND_TIME HDL_PARAMETER false
set_parameter_property TURNAROUND_TIME ALLOWED_RANGES "0:32000"
set_parameter_property TURNAROUND_TIME DISPLAY_NAME {Pin Turnaround Time}
set_parameter_property TURNAROUND_TIME DESCRIPTION {The required amount of time needed to transistion from a read to a write transaction}

add_parameter TIMING_UNITS INTEGER 1
set_parameter_property TIMING_UNITS HDL_PARAMETER false
set_parameter_property TIMING_UNITS ALLOWED_RANGES {"1:Cycles" "0:Nanoseconds"}
set_parameter_property TIMING_UNITS DESCRIPTION {Timing in cycles or nanoseconds}
set_parameter_property TIMING_UNITS DISPLAY_NAME {Timing units}

add_parameter ZERO_WRITE_DELAY INTEGER 0
set_parameter_property ZERO_WRITE_DELAY AFFECTS_ELABORATION false
set_parameter_property ZERO_WRITE_DELAY HDL_PARAMETER true
set_parameter_property ZERO_WRITE_DELAY ALLOWED_RANGES "0:1"
set_parameter_property ZERO_WRITE_DELAY DESCRIPTION {Zero write delay}
set_parameter_property ZERO_WRITE_DELAY DISPLAY_NAME {Zero write delay}

add_parameter ZERO_READ_DELAY INTEGER 0
set_parameter_property ZERO_READ_DELAY AFFECTS_ELABORATION false
set_parameter_property ZERO_READ_DELAY HDL_PARAMETER true
set_parameter_property ZERO_READ_DELAY ALLOWED_RANGES "0:1"
set_parameter_property ZERO_READ_DELAY DESCRIPTION {Zero read delay}
set_parameter_property ZERO_READ_DELAY DISPLAY_NAME {Zero read delay}

add_parameter IS_MEMORY_DEVICE INTEGER 0
set_parameter_property IS_MEMORY_DEVICE HDL_PARAMETER false
set_parameter_property IS_MEMORY_DEVICE ALLOWED_RANGES {"0:False" "1:True"}
set_parameter_property IS_MEMORY_DEVICE DESCRIPTION {isMemoryDevice}
set_parameter_property IS_MEMORY_DEVICE DISPLAY_NAME {isMemoryDevice}

add_parameter TURNAROUND_TIME_CYCLES INTEGER 0
set_parameter_property TURNAROUND_TIME_CYCLES DESCRIPTION {Turnaround time}
set_parameter_property TURNAROUND_TIME_CYCLES DISPLAY_NAME {Turnaround time}
set_parameter_property TURNAROUND_TIME_CYCLES AFFECTS_ELABORATION false
set_parameter_property TURNAROUND_TIME_CYCLES HDL_PARAMETER true
set_parameter_property TURNAROUND_TIME_CYCLES DERIVED true
set_parameter_property TURNAROUND_TIME_CYCLES VISIBLE false

add_parameter READLATENCY_CYCLES INTEGER 0
set_parameter_property READLATENCY_CYCLES DESCRIPTION {Readlatency in cycles}
set_parameter_property READLATENCY_CYCLES DISPLAY_NAME {Readlatency Cycles}
set_parameter_property READLATENCY_CYCLES AFFECTS_ELABORATION false
set_parameter_property READLATENCY_CYCLES HDL_PARAMETER true
set_parameter_property READLATENCY_CYCLES DERIVED true
set_parameter_property READLATENCY_CYCLES VISIBLE false

add_parameter CLOCK_RATE LONG 1
set_parameter_property CLOCK_RATE SYSTEM_INFO "CLOCK_RATE clk"
set_parameter_property CLOCK_RATE AFFECTS_ELABORATION true
set_parameter_property CLOCK_RATE DERIVED true
set_parameter_property CLOCK_RATE VISIBLE false

# | 
# +-----------------------------------




# +-----------------------------------
# | connection point clk
# | 
add_interface clk clock end
set_interface_property clk ptfSchematicName ""

add_interface_port clk clk clk Input 1

# +-----------------------------------
# | connection point reset
# | 
add_interface reset reset end
add_interface_port reset reset reset Input 1
set_interface_property reset ASSOCIATED_CLOCK clk
# | 
# +-----------------------------------

add_interface avalon_universal_slave_0 avalon slave clk
set_interface_property avalon_universal_slave_0 associatedReset reset
set_interface_property avalon_universal_slave_0 addressUnits SYMBOLS
set_interface_property avalon_universal_slave_0 burstcountUnits SYMBOLS
set_interface_property avalon_universal_slave_0 constantBurstBehavior 0

add_interface avalon_universal_master_0 avalon master clk
set_interface_property avalon_universal_master_0 associatedReset reset
set_interface_property avalon_universal_master_0 constantBurstBehavior 0
set_interface_property avalon_universal_master_0 burstcountUnits SYMBOLS
set_interface_property avalon_universal_master_0 addressUnits SYMBOLS

add_interface conduit_start conduit start


proc convertToCycles { num } {

    set clock_rate [get_parameter_value CLOCK_RATE]
    if { $clock_rate != 0 && $clock_rate != 1} {
	set clock_period [expr 1.0 / $clock_rate ]
	
	#Convert to ns
	set clock_period [expr $clock_period * 1000000000]
	
	set numCycles [expr $num / $clock_period]
	return [expr ceil($numCycles) ]
    }

    return $num
}

proc elaborate {} {

    set turnaround_time [get_parameter_value TURNAROUND_TIME ]
    set readlatency     [get_parameter_value READLATENCY     ]

    if { [get_parameter_value TIMING_UNITS] == 0 } {
	set turnaround_time  [convertToCycles $turnaround_time  ]
    } 

    set_parameter_value TURNAROUND_TIME_CYCLES $turnaround_time
    set_parameter_value READLATENCY_CYCLES $readlatency

#Declare the agent-side universal avalon interface
    add_interface_port  avalon_universal_slave_0  s0_uav_address             address            input  [ get_parameter_value UAV_ADDRESS_W ]
    add_interface_port  avalon_universal_slave_0  s0_uav_burstcount          burstcount         input  [ get_parameter_value UAV_BURSTCOUNT_W ]

    add_interface_port  avalon_universal_slave_0  s0_uav_read                read               input  1
    add_interface_port  avalon_universal_slave_0  s0_uav_write               write              input  1
    add_interface_port  avalon_universal_slave_0  s0_uav_waitrequest         waitrequest        output 1
    add_interface_port  avalon_universal_slave_0  s0_uav_readdatavalid       readdatavalid      output 1
    add_interface_port  avalon_universal_slave_0  s0_uav_byteenable          byteenable         input  [ get_parameter_value UAV_BYTEENABLE_W ]
    add_interface_port  avalon_universal_slave_0  s0_uav_readdata            readdata           output [ get_parameter_value UAV_DATA_W ]
    add_interface_port  avalon_universal_slave_0  s0_uav_writedata           writedata          input  [ get_parameter_value UAV_DATA_W ]
    add_interface_port  avalon_universal_slave_0  s0_uav_lock lock        input  1
    add_interface_port  avalon_universal_slave_0  s0_uav_debugaccess         debugaccess        input  1
    
    set_interface_property avalon_universal_slave_0 writeWaitTime 0
    set_interface_property avalon_universal_slave_0 addressAlignment DYNAMIC
    set_interface_property avalon_universal_slave_0 readWaitTime 0
    set_interface_property avalon_universal_slave_0 readLatency 0
    set_interface_property avalon_universal_slave_0  maximumPendingReadTransactions [get_parameter_value MAX_PENDING_READ_TRANSACTIONS]
    set_interface_property avalon_universal_slave_0 isMemoryDevice [ get_parameter_value IS_MEMORY_DEVICE ]

    # Declare type STD_LOGIC_VECTOR for multi-bit ports which are 1-bit under
    # some parameterizations.
    set_port_property   s0_uav_address VHDL_TYPE STD_LOGIC_VECTOR
    set_port_property   s0_uav_burstcount VHDL_TYPE STD_LOGIC_VECTOR
    set_port_property   s0_uav_byteenable VHDL_TYPE STD_LOGIC_VECTOR
    set_port_property   s0_uav_readdata VHDL_TYPE STD_LOGIC_VECTOR
    set_port_property   s0_uav_writedata VHDL_TYPE STD_LOGIC_VECTOR
 
    #Declare the slave-side universal avalon interface
    add_interface_port  avalon_universal_master_0  m0_uav_address             address            output  [ get_parameter_value UAV_ADDRESS_W ]
    add_interface_port  avalon_universal_master_0  m0_uav_burstcount          burstcount         output  [ get_parameter_value UAV_BURSTCOUNT_W ]

    add_interface_port  avalon_universal_master_0  m0_uav_read                read               output  1
    add_interface_port  avalon_universal_master_0  m0_uav_write               write              output  1
    add_interface_port  avalon_universal_master_0  m0_uav_waitrequest         waitrequest        input   1
    add_interface_port  avalon_universal_master_0  m0_uav_readdatavalid       readdatavalid      input   1
    add_interface_port  avalon_universal_master_0  m0_uav_byteenable          byteenable         output  [ get_parameter_value UAV_BYTEENABLE_W ]
    add_interface_port  avalon_universal_master_0  m0_uav_readdata            readdata           input   [ get_parameter_value UAV_DATA_W ]
    add_interface_port  avalon_universal_master_0  m0_uav_writedata           writedata          output  [ get_parameter_value UAV_DATA_W ]
    add_interface_port  avalon_universal_master_0  m0_uav_lock         lock        output  1
    add_interface_port  avalon_universal_master_0  m0_uav_debugaccess         debugaccess        output  1

    # Declare type STD_LOGIC_VECTOR for multi-bit ports which are 1-bit under
    # some parameterizations.
    set_port_property   m0_uav_address VHDL_TYPE STD_LOGIC_VECTOR
    set_port_property   m0_uav_burstcount VHDL_TYPE STD_LOGIC_VECTOR
    set_port_property   m0_uav_byteenable VHDL_TYPE STD_LOGIC_VECTOR
    set_port_property   m0_uav_readdata VHDL_TYPE STD_LOGIC_VECTOR
    set_port_property   m0_uav_writedata VHDL_TYPE STD_LOGIC_VECTOR

    #Declare conduit interface
    add_interface_port conduit_start c0_request request output 1
    add_interface_port conduit_start c0_grant   grant   input  1
    add_interface_port conduit_start c0_uav_write uav_write output 1
}
