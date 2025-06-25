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



# $Id: //acds/rel/13.1/ip/merlin/altera_generic_tristate_controller/altera_generic_tristate_controller_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

# +-----------------------------------
# | 
# | altera_generic_tristate_controller "Generic Tristate Controller" v1.0
# | 2008.10.15.13:20:06
# | 
# | 
# +-----------------------------------

package require -exact sopc 11.0

# +-----------------------------------
# | module altera_generic_tristate_driver
# | 
set_module_property NAME altera_generic_tristate_controller
set_module_property VERSION 13.1
set_module_property GROUP "Tri-State Components"
set_module_property DISPLAY_NAME "Generic Tri-State Controller"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property COMPOSE_CALLBACK composed
set_module_property HIDE_FROM_SOPC true
set_module_property ANALYZE_HDL FALSE
set_module_property AUTHOR "Altera Corporation"
set_module_property DESCRIPTION "Provides a template for a controller that you can parameterize to reflect the behavior of an off-chip device."
set_module_property DATASHEET_URL http://www.altera.com/literature/ug/ug_avalon_tc.pdf
# | 
# +-----------------------------------

#+ ----------------------------------------
#| Handy-Dandy Functions
#+ ----------------------------------------

 proc log2ceiling { num } {
    set val 0
    set i   1
    while { $i < $num } {
        set val [ expr $val + 1 ]
        set i   [ expr 1 << $val ]
    }

    return $val;
 }

 proc max { a b } { 
    if { $a > $b } {
        return $a
    } else {
        return $b
    }
 }

 proc min { a b } {
   return [ expr -1 * [ max [expr -$a] [expr -$b] ] ]
 }

 proc pow2 { a } {
  set val 1
  for { set i 0 } { $i <= $a } { incr i } {
   if { $i == 1 } {
    set val 2
   } elseif { $i > 1 } {
       set val [ expr $val * 2 ]
     }
   }
  return $val
 }


# +-----------------------------------
# | parameters
# |

add_display_item "" "Signal Selection" GROUP
set_display_item_property "Signal Selection" display_hint tab

add_display_item "" "Signal Timing" group
set_display_item_property "Signal Timing" display_hint tab

add_display_item "" "Signal Polarities" group
set_display_item_property "Signal Polarities" display_hint tab

add_display_item "Signal Polarities" signalPolaritiesBlurb text "<html><b>Enable active low polarity on the following signals:<br> <b>"

add_parameter TCM_ADDRESS_W INTEGER 30
set_parameter_property TCM_ADDRESS_W AFFECTS_ELABORATION true
set_parameter_property TCM_ADDRESS_W HDL_PARAMETER true
set_parameter_property TCM_ADDRESS_W ALLOWED_RANGES "1:30"
set_parameter_property TCM_ADDRESS_W DISPLAY_NAME "Address width"
set_parameter_property TCM_ADDRESS_W DESCRIPTION "This component outputs a byte address. Number of bits contained in the address signal."
set_parameter_property TCM_ADDRESS_W GROUP "Signal Selection"

add_parameter TCM_DATA_W INTEGER 32
set_parameter_property TCM_DATA_W AFFECTS_ELABORATION true
set_parameter_property TCM_DATA_W HDL_PARAMETER true
set_parameter_property TCM_DATA_W ALLOWED_RANGES "1:32000"
set_parameter_property TCM_DATA_W DISPLAY_NAME "Data width"
set_parameter_property TCM_DATA_W DESCRIPTION "Number of bits contained in the data signal."
set_parameter_property TCM_DATA_W GROUP "Signal Selection"

add_parameter TCM_BYTEENABLE_W INTEGER 4
set_parameter_property TCM_BYTEENABLE_W AFFECTS_ELABORATION true
set_parameter_property TCM_BYTEENABLE_W HDL_PARAMETER true
set_parameter_property TCM_BYTEENABLE_W ALLOWED_RANGES "1:32000"
set_parameter_property TCM_BYTEENABLE_W DISPLAY_NAME "Byteenable width"
set_parameter_property TCM_BYTEENABLE_W DESCRIPTION "Number of bits contained in the byteenable signal."
set_parameter_property TCM_BYTEENABLE_W GROUP "Signal Selection"

add_parameter TCM_READ_WAIT INTEGER 1
set_parameter_property TCM_READ_WAIT AFFECTS_ELABORATION true
set_parameter_property TCM_READ_WAIT HDL_PARAMETER true
set_parameter_property TCM_READ_WAIT ALLOWED_RANGES "0:32000"
set_parameter_property TCM_READ_WAIT DISPLAY_NAME "Read wait time"
set_parameter_property TCM_READ_WAIT DESCRIPTION "Amount of time the read signal is held high for each transaction."
set_parameter_property TCM_READ_WAIT GROUP "Signal Timing"

add_parameter TCM_WRITE_WAIT INTEGER 0
set_parameter_property TCM_WRITE_WAIT AFFECTS_ELABORATION true
set_parameter_property TCM_WRITE_WAIT HDL_PARAMETER true
set_parameter_property TCM_WRITE_WAIT ALLOWED_RANGES "0:32000"
set_parameter_property TCM_WRITE_WAIT DISPLAY_NAME "Write wait time"
set_parameter_property TCM_WRITE_WAIT DESCRIPTION "Amount of time the write signal is held high for each transaction."
set_parameter_property TCM_WRITE_WAIT GROUP "Signal Timing"

add_parameter TCM_SETUP_WAIT INTEGER 0
set_parameter_property TCM_SETUP_WAIT AFFECTS_ELABORATION true
set_parameter_property TCM_SETUP_WAIT HDL_PARAMETER true
set_parameter_property TCM_SETUP_WAIT ALLOWED_RANGES "0:32000"
set_parameter_property TCM_SETUP_WAIT DISPLAY_NAME "Setup time"
set_parameter_property TCM_SETUP_WAIT DESCRIPTION "Amount of time required before a write or read signal is activated."
set_parameter_property TCM_SETUP_WAIT GROUP "Signal Timing"

add_parameter TCM_DATA_HOLD INTEGER 0
set_parameter_property TCM_DATA_HOLD AFFECTS_ELABORATION true
set_parameter_property TCM_DATA_HOLD HDL_PARAMETER true
set_parameter_property TCM_DATA_HOLD ALLOWED_RANGES "0:32000"
set_parameter_property TCM_DATA_HOLD DISPLAY_NAME "Data hold time"
set_parameter_property TCM_DATA_HOLD DESCRIPTION "Amount of time required for the data signal to be held following deassertion of write.  This is in addition to the write wait time."
set_parameter_property TCM_DATA_HOLD GROUP "Signal Timing"

add_parameter TCM_MAX_PENDING_READ_TRANSACTIONS INTEGER 1
set_parameter_property TCM_MAX_PENDING_READ_TRANSACTIONS AFFECTS_ELABORATION true
set_parameter_property TCM_MAX_PENDING_READ_TRANSACTIONS HDL_PARAMETER false
set_parameter_property TCM_MAX_PENDING_READ_TRANSACTIONS ALLOWED_RANGES "0:32000"
set_parameter_property TCM_MAX_PENDING_READ_TRANSACTIONS DISPLAY_NAME "Maximum pending read transactions"
set_parameter_property TCM_MAX_PENDING_READ_TRANSACTIONS DESCRIPTION "Determines the size of FIFO buffers."
set_parameter_property TCM_MAX_PENDING_READ_TRANSACTIONS GROUP "Signal Timing"

add_parameter TCM_TURNAROUND_TIME INTEGER 2
set_parameter_property TCM_TURNAROUND_TIME AFFECTS_ELABORATION TRUE
set_parameter_property TCM_TURNAROUND_TIME HDL_PARAMETER TRUE
set_parameter_property TCM_TURNAROUND_TIME ALLOWED_RANGES "0:32000"
set_parameter_property TCM_TURNAROUND_TIME ENABLED TRUE
set_parameter_property TCM_TURNAROUND_TIME DISPLAY_NAME "Turnaround time"
set_parameter_property TCM_TURNAROUND_TIME DESCRIPTION "Amount of time required before a response signal can be initiated."
set_parameter_property TCM_TURNAROUND_TIME GROUP "Signal Timing"

add_parameter TCM_TIMING_UNITS INTEGER 1
set_parameter_property TCM_TIMING_UNITS AFFECTS_ELABORATION true
set_parameter_property TCM_TIMING_UNITS HDL_PARAMETER true
set_parameter_property TCM_TIMING_UNITS ALLOWED_RANGES { 1:Cycles 0:Nanoseconds }
set_parameter_property TCM_TIMING_UNITS DISPLAY_NAME "Timing units"
set_parameter_property TCM_TIMING_UNITS DESCRIPTION "Determines the units of time."
set_parameter_property TCM_TIMING_UNITS GROUP "Signal Timing"

add_parameter TCM_READLATENCY INTEGER 2
set_parameter_property TCM_READLATENCY AFFECTS_ELABORATION true
set_parameter_property TCM_READLATENCY HDL_PARAMETER true
set_parameter_property TCM_READLATENCY ALLOWED_RANGES "0:32000"
set_parameter_property TCM_READLATENCY DISPLAY_NAME "Read latency"
set_parameter_property TCM_READLATENCY DESCRIPTION "Note: Read latency should be parameterized with 2 additional cycles from the device's actual read latency to account for the I/O register delay in the Tristate Conduit Bridge. Read latency parameterizable in units of cycles only. Amount of time required before a signal reaches its destination."
set_parameter_property TCM_READLATENCY GROUP "Signal Timing"

add_parameter TCM_SYMBOLS_PER_WORD INTEGER 4
set_parameter_property TCM_SYMBOLS_PER_WORD AFFECTS_ELABORATION true
set_parameter_property TCM_SYMBOLS_PER_WORD HDL_PARAMETER true
set_parameter_property TCM_SYMBOLS_PER_WORD ALLOWED_RANGES "1:32000"
set_parameter_property TCM_SYMBOLS_PER_WORD DISPLAY_NAME "Bytes per word"
set_parameter_property TCM_SYMBOLS_PER_WORD GROUP "Signal Selection"
set_parameter_property TCM_SYMBOLS_PER_WORD DESCRIPTION "Number of bytes per word."

add_display_item "Signal Selection" signalSelectionBlurb text "<html><br><b>Enable the following signals:</b><br>"

add_display_item "Signal Selection" referenceText text "<html>Refer to the Avalon Interface Specifications for definitions of these signals: http://www.altera.com/literature/manual/mnl_avalon_spec.pdf"


add_parameter USE_READDATA INTEGER 1
set_parameter_property USE_READDATA AFFECTS_ELABORATION true
set_parameter_property USE_READDATA HDL_PARAMETER true
set_parameter_property USE_READDATA DISPLAY_HINT BOOLEAN
set_parameter_property USE_READDATA DISPLAY_NAME "readdata"
set_parameter_property USE_READDATA group "Signal Selection"
set_parameter_property USE_READDATA DESCRIPTION "When enabled, the readdata signal is included in the Avalon tri-state master interface."

add_parameter USE_WRITEDATA INTEGER 1
set_parameter_property USE_WRITEDATA AFFECTS_ELABORATION true
set_parameter_property USE_WRITEDATA HDL_PARAMETER true
set_parameter_property USE_WRITEDATA  DISPLAY_HINT BOOLEAN
set_parameter_property USE_WRITEDATA DISPLAY_NAME "writedata"
set_parameter_property USE_WRITEDATA group "Signal Selection"
set_parameter_property USE_WRITEDATA DESCRIPTION "When enabled, the writedata signal is included in the Avalon tri-state master interface."

add_parameter USE_READ INTEGER 1
set_parameter_property USE_READ AFFECTS_ELABORATION true
set_parameter_property USE_READ HDL_PARAMETER true
set_parameter_property USE_READ  DISPLAY_HINT BOOLEAN
set_parameter_property USE_READ DISPLAY_NAME "read"
set_parameter_property USE_READ group "Signal Selection"
set_parameter_property USE_READ DESCRIPTION "When enabled, the read signal is included in the Avalon tri-state master interface."

add_parameter USE_WRITE INTEGER 1
set_parameter_property USE_WRITE AFFECTS_ELABORATION true
set_parameter_property USE_WRITE HDL_PARAMETER true
set_parameter_property USE_WRITE  DISPLAY_HINT BOOLEAN
set_parameter_property USE_WRITE DISPLAY_NAME "write"
set_parameter_property USE_WRITE group "Signal Selection"
set_parameter_property USE_WRITE DESCRIPTION "When enabled, the write signal is included in the Avalon tri-state master interface."

add_parameter USE_BEGINTRANSFER INTEGER 1
set_parameter_property USE_BEGINTRANSFER AFFECTS_ELABORATION true
set_parameter_property USE_BEGINTRANSFER HDL_PARAMETER false
set_parameter_property USE_BEGINTRANSFER  DISPLAY_HINT BOOLEAN
set_parameter_property USE_BEGINTRANSFER DISPLAY_NAME "begintransfer"
set_parameter_property USE_BEGINTRANSFER group "Signal Selection"
set_parameter_property USE_BEGINTRANSFER DESCRIPTION "When enabled, the begintransfer signal is included in the Avalon tri-state master interface."

add_parameter USE_BYTEENABLE INTEGER 1
set_parameter_property USE_BYTEENABLE AFFECTS_ELABORATION true
set_parameter_property USE_BYTEENABLE HDL_PARAMETER true
set_parameter_property USE_BYTEENABLE  DISPLAY_HINT BOOLEAN
set_parameter_property USE_BYTEENABLE DISPLAY_NAME "byteenable"
set_parameter_property USE_BYTEENABLE group "Signal Selection"
set_parameter_property USE_BYTEENABLE DESCRIPTION "When enabled, the byteenable signal is included in the Avalon tri-state master interface."

add_parameter USE_CHIPSELECT INTEGER 0
set_parameter_property USE_CHIPSELECT AFFECTS_ELABORATION true
set_parameter_property USE_CHIPSELECT HDL_PARAMETER true
set_parameter_property USE_CHIPSELECT  DISPLAY_HINT BOOLEAN
set_parameter_property USE_CHIPSELECT DISPLAY_NAME "chipselect"
set_parameter_property USE_CHIPSELECT group "Signal Selection"
set_parameter_property USE_CHIPSELECT DESCRIPTION "When enabled, the chipselect signal is included in the Avalon tri-state master interface."

add_parameter USE_LOCK INTEGER 0
set_parameter_property USE_LOCK AFFECTS_ELABORATION true
set_parameter_property USE_LOCK HDL_PARAMETER true
set_parameter_property USE_LOCK  DISPLAY_HINT BOOLEAN
set_parameter_property USE_LOCK DISPLAY_NAME "lock"
set_parameter_property USE_LOCK group "Signal Selection"
set_parameter_property USE_LOCK DESCRIPTION "When enabled, the lock signal is included in the Avalon tri-state master interface."

add_parameter USE_ADDRESS INTEGER 1
set_parameter_property USE_ADDRESS AFFECTS_ELABORATION true
set_parameter_property USE_ADDRESS HDL_PARAMETER true
set_parameter_property USE_ADDRESS  DISPLAY_HINT BOOLEAN
set_parameter_property USE_ADDRESS DISPLAY_NAME "address"
set_parameter_property USE_ADDRESS group "Signal Selection"
set_parameter_property USE_ADDRESS DESCRIPTION "When enabled, the address signal is included in the Avalon tri-state master interface."

add_parameter USE_WAITREQUEST INTEGER 0
set_parameter_property USE_WAITREQUEST AFFECTS_ELABORATION true
set_parameter_property USE_WAITREQUEST HDL_PARAMETER true
set_parameter_property USE_WAITREQUEST  DISPLAY_HINT BOOLEAN
set_parameter_property USE_WAITREQUEST DISPLAY_NAME "waitrequest"
set_parameter_property USE_WAITREQUEST group "Signal Selection"
set_parameter_property USE_WAITREQUEST DESCRIPTION "When enabled, the waitrequest signal is included in the Avalon tri-state master interface."

add_parameter USE_WRITEBYTEENABLE INTEGER 0
set_parameter_property USE_WRITEBYTEENABLE AFFECTS_ELABORATION true
set_parameter_property USE_WRITEBYTEENABLE HDL_PARAMETER true
set_parameter_property USE_WRITEBYTEENABLE  DISPLAY_HINT BOOLEAN
set_parameter_property USE_WRITEBYTEENABLE DISPLAY_NAME "writebyteenable"
set_parameter_property USE_WRITEBYTEENABLE group "Signal Selection"
set_parameter_property USE_WRITEBYTEENABLE DESCRIPTION "When enabled, the writebyteenable signal is included in the Avalon tri-state master interface."

add_parameter USE_OUTPUTENABLE INTEGER 0
set_parameter_property USE_OUTPUTENABLE AFFECTS_ELABORATION true
set_parameter_property USE_OUTPUTENABLE HDL_PARAMETER true
set_parameter_property USE_OUTPUTENABLE  DISPLAY_HINT BOOLEAN
set_parameter_property USE_OUTPUTENABLE DISPLAY_NAME "outputenable"
set_parameter_property USE_OUTPUTENABLE group "Signal Selection"
set_parameter_property USE_OUTPUTENABLE DESCRIPTION "When enabled, the outputenable signal is included in the Avalon tri-state master interface."

add_parameter USE_RESETREQUEST INTEGER 0
set_parameter_property USE_RESETREQUEST AFFECTS_ELABORATION true
set_parameter_property USE_RESETREQUEST HDL_PARAMETER true
set_parameter_property USE_RESETREQUEST  DISPLAY_HINT BOOLEAN
set_parameter_property USE_RESETREQUEST DISPLAY_NAME "resetrequest"
set_parameter_property USE_RESETREQUEST group "Signal Selection"
set_parameter_property USE_RESETREQUEST DESCRIPTION "When enabled, the resetrequest signal is included in the Avalon tri-state master interface."

add_parameter USE_IRQ INTEGER 0
set_parameter_property USE_IRQ AFFECTS_ELABORATION true
set_parameter_property USE_IRQ HDL_PARAMETER true
set_parameter_property USE_IRQ  DISPLAY_HINT BOOLEAN
set_parameter_property USE_IRQ DISPLAY_NAME "irq"
set_parameter_property USE_IRQ group "Signal Selection"
set_parameter_property USE_IRQ DESCRIPTION "When enabled, the irq signal is included in the Avalon tri-state master interface."

add_parameter USE_RESET_OUTPUT INTEGER 0
set_parameter_property USE_RESET_OUTPUT AFFECTS_ELABORATION true
set_parameter_property USE_RESET_OUTPUT HDL_PARAMETER true
set_parameter_property USE_RESET_OUTPUT  DISPLAY_HINT BOOLEAN
set_parameter_property USE_RESET_OUTPUT DISPLAY_NAME "reset output"
set_parameter_property USE_RESET_OUTPUT group "Signal Selection"
set_parameter_property USE_RESET_OUTPUT DESCRIPTION "When enabled, the output reset signal is included in the Avalon tri-state master interface."

add_parameter ACTIVE_LOW_READ INTEGER 0
set_parameter_property ACTIVE_LOW_READ AFFECTS_ELABORATION TRUE
set_parameter_property ACTIVE_LOW_READ HDL_PARAMETER TRUE
set_parameter_property ACTIVE_LOW_READ  DISPLAY_HINT BOOLEAN
set_parameter_property ACTIVE_LOW_READ DISPLAY_NAME "read"
set_parameter_property ACTIVE_LOW_READ group "Signal Polarities"
set_parameter_property ACTIVE_LOW_READ DESCRIPTION "When enabled, the read signal is asserted low."

add_parameter ACTIVE_LOW_LOCK INTEGER 0
set_parameter_property ACTIVE_LOW_LOCK AFFECTS_ELABORATION true
set_parameter_property ACTIVE_LOW_LOCK HDL_PARAMETER true
set_parameter_property ACTIVE_LOW_LOCK  DISPLAY_HINT BOOLEAN
set_parameter_property ACTIVE_LOW_LOCK DISPLAY_NAME "lock"
set_parameter_property ACTIVE_LOW_LOCK group "Signal Polarities"
set_parameter_property ACTIVE_LOW_LOCK DESCRIPTION "When enabled, the lock signal is asserted low."

add_parameter ACTIVE_LOW_WRITE INTEGER 0
set_parameter_property ACTIVE_LOW_WRITE AFFECTS_ELABORATION TRUE
set_parameter_property ACTIVE_LOW_WRITE HDL_PARAMETER TRUE
set_parameter_property ACTIVE_LOW_WRITE  DISPLAY_HINT BOOLEAN
set_parameter_property ACTIVE_LOW_WRITE DISPLAY_NAME "write"
set_parameter_property ACTIVE_LOW_WRITE group "Signal Polarities"
set_parameter_property ACTIVE_LOW_WRITE DESCRIPTION "When enabled, the write signal is asserted low."

add_parameter ACTIVE_LOW_CHIPSELECT INTEGER 0
set_parameter_property ACTIVE_LOW_CHIPSELECT AFFECTS_ELABORATION TRUE
set_parameter_property ACTIVE_LOW_CHIPSELECT HDL_PARAMETER TRUE
set_parameter_property ACTIVE_LOW_CHIPSELECT  DISPLAY_HINT BOOLEAN
set_parameter_property ACTIVE_LOW_CHIPSELECT DISPLAY_NAME "chipselect"
set_parameter_property ACTIVE_LOW_CHIPSELECT group "Signal Polarities"
set_parameter_property ACTIVE_LOW_CHIPSELECT DESCRIPTION "When enabled, the chipselect signal is asserted low."

add_parameter ACTIVE_LOW_BYTEENABLE INTEGER 0
set_parameter_property ACTIVE_LOW_BYTEENABLE AFFECTS_ELABORATION TRUE
set_parameter_property ACTIVE_LOW_BYTEENABLE HDL_PARAMETER TRUE
set_parameter_property ACTIVE_LOW_BYTEENABLE  DISPLAY_HINT BOOLEAN
set_parameter_property ACTIVE_LOW_BYTEENABLE DISPLAY_NAME "byteenable"
set_parameter_property ACTIVE_LOW_BYTEENABLE group "Signal Polarities"
set_parameter_property ACTIVE_LOW_BYTEENABLE DESCRIPTION "When enabled, the byteenable signal is asserted low."

add_parameter ACTIVE_LOW_OUTPUTENABLE INTEGER 0
set_parameter_property ACTIVE_LOW_OUTPUTENABLE AFFECTS_ELABORATION TRUE
set_parameter_property ACTIVE_LOW_OUTPUTENABLE HDL_PARAMETER TRUE
set_parameter_property ACTIVE_LOW_OUTPUTENABLE  DISPLAY_HINT BOOLEAN
set_parameter_property ACTIVE_LOW_OUTPUTENABLE DISPLAY_NAME "outputenable"
set_parameter_property ACTIVE_LOW_OUTPUTENABLE group "Signal Polarities"
set_parameter_property ACTIVE_LOW_OUTPUTENABLE DESCRIPTION "When enabled, the outputenable signal is asserted low."

add_parameter ACTIVE_LOW_WRITEBYTEENABLE INTEGER 0
set_parameter_property ACTIVE_LOW_WRITEBYTEENABLE AFFECTS_ELABORATION TRUE
set_parameter_property ACTIVE_LOW_WRITEBYTEENABLE HDL_PARAMETER TRUE
set_parameter_property ACTIVE_LOW_WRITEBYTEENABLE  DISPLAY_HINT BOOLEAN
set_parameter_property ACTIVE_LOW_WRITEBYTEENABLE DISPLAY_NAME "writebyteenable"
set_parameter_property ACTIVE_LOW_WRITEBYTEENABLE group "Signal Polarities"
set_parameter_property ACTIVE_LOW_WRITEBYTEENABLE DESCRIPTION "When enabled, the writebyteenable signal is asserted low."

add_parameter ACTIVE_LOW_WAITREQUEST INTEGER 0
set_parameter_property ACTIVE_LOW_WAITREQUEST AFFECTS_ELABORATION TRUE
set_parameter_property ACTIVE_LOW_WAITREQUEST HDL_PARAMETER TRUE
set_parameter_property ACTIVE_LOW_WAITREQUEST  DISPLAY_HINT BOOLEAN
set_parameter_property ACTIVE_LOW_WAITREQUEST DISPLAY_NAME "waitrequest"
set_parameter_property ACTIVE_LOW_WAITREQUEST group "Signal Polarities"
set_parameter_property ACTIVE_LOW_WAITREQUEST DESCRIPTION "When enabled, the waitrequest signal is asserted low."

add_parameter ACTIVE_LOW_BEGINTRANSFER INTEGER 0
set_parameter_property ACTIVE_LOW_BEGINTRANSFER AFFECTS_ELABORATION true
set_parameter_property ACTIVE_LOW_BEGINTRANSFER HDL_PARAMETER true
set_parameter_property ACTIVE_LOW_BEGINTRANSFER  DISPLAY_HINT BOOLEAN
set_parameter_property ACTIVE_LOW_BEGINTRANSFER DISPLAY_NAME "begintransfer"
set_parameter_property ACTIVE_LOW_BEGINTRANSFER group "Signal Polarities"
set_parameter_property ACTIVE_LOW_BEGINTRANSFER DESCRIPTION "When enabled, the begintransfer signal is asserted low."

add_parameter ACTIVE_LOW_RESETREQUEST INTEGER 0
set_parameter_property ACTIVE_LOW_RESETREQUEST AFFECTS_ELABORATION true
set_parameter_property ACTIVE_LOW_RESETREQUEST HDL_PARAMETER false
set_parameter_property ACTIVE_LOW_RESETREQUEST  DISPLAY_HINT BOOLEAN
set_parameter_property ACTIVE_LOW_RESETREQUEST DISPLAY_NAME "resetrequest"
set_parameter_property ACTIVE_LOW_RESETREQUEST group "Signal Polarities"
set_parameter_property ACTIVE_LOW_RESETREQUEST DESCRIPTION "When enabled, the resetrequest signal is asserted low."

add_parameter ACTIVE_LOW_IRQ INTEGER 0
set_parameter_property ACTIVE_LOW_IRQ AFFECTS_ELABORATION true
set_parameter_property ACTIVE_LOW_IRQ HDL_PARAMETER false
set_parameter_property ACTIVE_LOW_IRQ  DISPLAY_HINT BOOLEAN
set_parameter_property ACTIVE_LOW_IRQ DISPLAY_NAME "irq"
set_parameter_property ACTIVE_LOW_IRQ group "Signal Polarities"
set_parameter_property ACTIVE_LOW_IRQ DESCRIPTION "When enabled, the irq signal is asserted low."

add_parameter ACTIVE_LOW_RESET_OUTPUT INTEGER 0
set_parameter_property ACTIVE_LOW_RESET_OUTPUT AFFECTS_ELABORATION true
set_parameter_property ACTIVE_LOW_RESET_OUTPUT HDL_PARAMETER false
set_parameter_property ACTIVE_LOW_RESET_OUTPUT  DISPLAY_HINT BOOLEAN
set_parameter_property ACTIVE_LOW_RESET_OUTPUT DISPLAY_NAME "reset output"
set_parameter_property ACTIVE_LOW_RESET_OUTPUT group "Signal Polarities"
set_parameter_property ACTIVE_LOW_RESET_OUTPUT DESCRIPTION "When enabled, the output reset signal is asserted low."

add_parameter CHIPSELECT_THROUGH_READLATENCY INTEGER 0
set_parameter_property CHIPSELECT_THROUGH_READLATENCY AFFECTS_ELABORATION TRUE
set_parameter_property CHIPSELECT_THROUGH_READLATENCY HDL_PARAMETER TRUE
set_parameter_property CHIPSELECT_THROUGH_READLATENCY  DISPLAY_HINT BOOLEAN
set_parameter_property CHIPSELECT_THROUGH_READLATENCY DISPLAY_NAME "Chipselect through read latency"
set_parameter_property CHIPSELECT_THROUGH_READLATENCY DESCRIPTION "When enabled, chipselect signal is asserted for the duration of the read transfer, regardless of read latency."
set_parameter_property CHIPSELECT_THROUGH_READLATENCY GROUP "Signal Timing"

add_parameter IS_MEMORY_DEVICE INTEGER 0
set_parameter_property IS_MEMORY_DEVICE DISPLAY_HINT BOOLEAN
set_parameter_property IS_MEMORY_DEVICE HDL_PARAMETER false
set_parameter_property IS_MEMORY_DEVICE AFFECTS_ELABORATION true
set_parameter_property IS_MEMORY_DEVICE DISPLAY_NAME "Is memory device"
set_parameter_property IS_MEMORY_DEVICE DESCRIPTION "When enabled, identifies the external device as a memory. Used for downstream software tools."

add_display_item "" "Module Assignments" "text" ""
add_display_item "Module Assignments" "tablegroup" "group" "table"

add_parameter MODULE_ASSIGNMENT_KEYS STRINGLIST "embeddedsw.configuration.hwClassnameDriverSupportList"
set_parameter_property MODULE_ASSIGNMENT_KEYS HDL_PARAMETER false
set_parameter_property MODULE_ASSIGNMENT_KEYS AFFECTS_ELABORATION true
set_parameter_property MODULE_ASSIGNMENT_KEYS GROUP "tablegroup"
set_parameter_property MODULE_ASSIGNMENT_KEYS DISPLAY_NAME {Parameter}
set_parameter_property MODULE_ASSIGNMENT_KEYS DESCRIPTION {Parameter}
set_parameter_property MODULE_ASSIGNMENT_KEYS DISPLAY_HINT "WIDTH:370"

add_parameter MODULE_ASSIGNMENT_VALUES STRINGLIST "altera_avalon_lan91c111,altera_avalon_cfi_flash"
set_parameter_property MODULE_ASSIGNMENT_VALUES HDL_PARAMETER false
set_parameter_property MODULE_ASSIGNMENT_VALUES AFFECTS_ELABORATION true
set_parameter_property MODULE_ASSIGNMENT_VALUES GROUP "tablegroup"
set_parameter_property MODULE_ASSIGNMENT_VALUES DISPLAY_NAME {Value}
set_parameter_property MODULE_ASSIGNMENT_VALUES DESCRIPTION {Value}
set_parameter_property MODULE_ASSIGNMENT_VALUES DISPLAY_HINT "WIDTH:370"

add_display_item "" moduleAssignmentsBlurb text "<html>Use the module assignments to identify your components to downstream embedded software tools.<br>A value of 1 identifies the parameter as true, a value of 0 identifies it as false."

add_display_item "" sizeAssignmentBlurb text "<html>Note: For memory devices, the module assignment <b>embeddedsw.CMacro.SIZE</b> = <b><i>Memory Size in Bytes</i></b> must be defined.</html>"

add_display_item "" "Avalon Connection Point Assignments" "text" ""
add_display_item "Avalon Connection Point Assignments" "tablegroup1" "group" "table"

add_parameter INTERFACE_ASSIGNMENT_KEYS STRINGLIST ""
set_parameter_property INTERFACE_ASSIGNMENT_KEYS HDL_PARAMETER false
set_parameter_property INTERFACE_ASSIGNMENT_KEYS AFFECTS_ELABORATION true
set_parameter_property INTERFACE_ASSIGNMENT_KEYS GROUP "tablegroup1"
set_parameter_property INTERFACE_ASSIGNMENT_KEYS DISPLAY_NAME {Parameter}
set_parameter_property INTERFACE_ASSIGNMENT_KEYS DESCRIPTION {Parameter}
set_parameter_property INTERFACE_ASSIGNMENT_KEYS DISPLAY_HINT "WIDTH:370"

add_parameter INTERFACE_ASSIGNMENT_VALUES STRINGLIST ""
set_parameter_property INTERFACE_ASSIGNMENT_VALUES HDL_PARAMETER false
set_parameter_property INTERFACE_ASSIGNMENT_VALUES AFFECTS_ELABORATION true
set_parameter_property INTERFACE_ASSIGNMENT_VALUES GROUP "tablegroup1"
set_parameter_property INTERFACE_ASSIGNMENT_VALUES DISPLAY_NAME {Value}
set_parameter_property INTERFACE_ASSIGNMENT_VALUES DESCRIPTION {Value}
set_parameter_property INTERFACE_ASSIGNMENT_VALUES DISPLAY_HINT "WIDTH:370"

add_parameter CLOCK_RATE LONG 1
set_parameter_property CLOCK_RATE SYSTEM_INFO "CLOCK_RATE clk"
set_parameter_property CLOCK_RATE AFFECTS_ELABORATION true
set_parameter_property CLOCK_RATE DERIVED true
set_parameter_property CLOCK_RATE VISIBLE false


# | 
# +-----------------------------------


# +-----------------------------------
# | Add Interfaces
# | 
add_interface clk clock end
add_interface reset reset end
add_interface uas avalon slave
add_interface tcm tristate_conduit master
# | 
# +-----------------------------------

#Add Modules
add_instance clk altera_clock_bridge
add_instance reset altera_reset_bridge
add_instance tdt altera_tristate_controller_translator
add_instance slave_translator altera_merlin_slave_translator
add_instance tda altera_tristate_controller_aggregator

#Export Interfaces
set_interface_property clk export_of clk.in_clk
set_interface_property reset export_of reset.in_reset
set_interface_property uas export_of tdt.avalon_universal_slave_0
set_interface_property tcm export_of tda.tristate_conduit_master_0

#Connect Interfaces
add_connection clk.out_clk reset.clk

add_connection clk.out_clk tdt.clk
add_connection reset.out_reset tdt.reset

add_connection clk.out_clk tda.clk
add_connection reset.out_reset tda.reset

add_connection clk.out_clk slave_translator.clk
add_connection reset.out_reset slave_translator.reset

add_connection tdt.conduit_start tda.conduit_end
add_connection tdt.avalon_universal_master_0 slave_translator.avalon_universal_slave_0
add_connection slave_translator.avalon_anti_slave_0 tda.avalon_slave_0




proc convertNanosToCycles { num } {

    set clock_rate [get_parameter_value CLOCK_RATE]
    if { $clock_rate != 0 && $clock_rate != 1 } {
	set clock_period [expr 1.0 / $clock_rate ]
	
	#Convert to ns
	set clock_period [expr $clock_period * 1000000000]
	
	set numCycles [expr $num / $clock_period]

	return [expr ceil($numCycles) ]
    }
    return $num
}

proc convertCyclesToNanos { numCycles } {
    set clock_rate [get_parameter_value CLOCK_RATE]

    if { $clock_rate != 0 && $clock_rate != 1 } {
	set clock_period [expr 1.0 / $clock_rate ]
	
	#Convert to ns
	set clock_period [expr $clock_period * 1000000000]

	set nanos [expr $numCycles * $clock_period]
	
	return $nanos
    }
    return $numCycles
}

proc composed {} {

    set TCM_TURNAROUND_TIME [ get_parameter_value TCM_TURNAROUND_TIME ]
    set TCM_READLATENCY     [ get_parameter_value TCM_READLATENCY ]
    set TCM_TIMING_UNITS    [ get_parameter_value TCM_TIMING_UNITS ]
    
    set mk_assign [get_parameter_value MODULE_ASSIGNMENT_KEYS]
    set mv_assign [get_parameter_value MODULE_ASSIGNMENT_VALUES]

    foreach key ${mk_assign} value ${mv_assign} {
	set_module_assignment $key $value
    }
    
    set key ""
    set value ""

    set cpk_assign [get_parameter_value INTERFACE_ASSIGNMENT_KEYS]
    set cpv_assign [get_parameter_value INTERFACE_ASSIGNMENT_VALUES]

    foreach key ${cpk_assign} value ${cpv_assign} {	
	set_interface_assignment uas $key $value
    }

    set burstcount_w [expr [log2ceiling [get_parameter_value TCM_SYMBOLS_PER_WORD]] +1]

    #Configure TDT
    set_instance_parameter tdt UAV_DATA_W       [ get_parameter_value TCM_DATA_W ]
    set_instance_parameter tdt UAV_BYTEENABLE_W [ get_parameter_value TCM_BYTEENABLE_W ]
    set_instance_parameter tdt UAV_ADDRESS_W    [ get_parameter_value TCM_ADDRESS_W ]
    set_instance_parameter tdt UAV_BURSTCOUNT_W   $burstcount_w
    set_instance_parameter tdt TURNAROUND_TIME    $TCM_TURNAROUND_TIME
    set_instance_parameter tdt READLATENCY        $TCM_READLATENCY
    set_instance_parameter tdt IS_MEMORY_DEVICE [ get_parameter_value IS_MEMORY_DEVICE ]
    set_instance_parameter tdt TIMING_UNITS [ get_parameter_value TCM_TIMING_UNITS ]
    set_instance_parameter tdt MAX_PENDING_READ_TRANSACTIONS [get_parameter_value TCM_MAX_PENDING_READ_TRANSACTIONS]

    if { [get_parameter_value TCM_SETUP_WAIT] == 0 } {
	if { [get_parameter_value TCM_WRITE_WAIT] == 0 && [get_parameter_value TCM_DATA_HOLD] == 0} {
	    set_instance_parameter tdt ZERO_WRITE_DELAY 1
	}
	
	if { [get_parameter_value TCM_READ_WAIT] == 0 } {
	    set_instance_parameter tdt ZERO_READ_DELAY 1	    
	}
    }


    #Configure Slave Translator
    set_instance_parameter slave_translator AV_ADDRESS_W           [ get_parameter_value TCM_ADDRESS_W ]
    set_instance_parameter slave_translator AV_DATA_W              [ get_parameter_value TCM_DATA_W ]
    set_instance_parameter slave_translator UAV_DATA_W             [ get_parameter_value TCM_DATA_W ]
    set_instance_parameter slave_translator AV_BURSTCOUNT_W          $burstcount_w
    set_instance_parameter slave_translator AV_BYTEENABLE_W        [ get_parameter_value TCM_BYTEENABLE_W ]
    set_instance_parameter slave_translator UAV_BYTEENABLE_W       [ get_parameter_value TCM_BYTEENABLE_W ]
    set_instance_parameter slave_translator AV_READLATENCY         $TCM_READLATENCY
    set_instance_parameter slave_translator AV_READ_WAIT           [ get_parameter_value TCM_READ_WAIT ]
    set_instance_parameter slave_translator AV_WRITE_WAIT          [ get_parameter_value TCM_WRITE_WAIT ]
    set_instance_parameter slave_translator AV_SETUP_WAIT          [ get_parameter_value TCM_SETUP_WAIT ]
    set_instance_parameter slave_translator AV_DATA_HOLD           [ get_parameter_value TCM_DATA_HOLD ]
    set_instance_parameter slave_translator UAV_ADDRESS_W          [ get_parameter_value TCM_ADDRESS_W ]
    set_instance_parameter slave_translator UAV_BURSTCOUNT_W         $burstcount_w
    set_instance_parameter slave_translator USE_READDATA           [ get_parameter_value USE_READDATA ]
    set_instance_parameter slave_translator USE_WRITEDATA          [ get_parameter_value USE_WRITEDATA ]
    set_instance_parameter slave_translator USE_READ               [ get_parameter_value USE_READ ]
    set_instance_parameter slave_translator USE_WRITE              [ get_parameter_value USE_WRITE ]
	set_instance_parameter slave_translator USE_WRITERESPONSE      0
	set_instance_parameter slave_translator USE_READRESPONSE       0
    set_instance_parameter slave_translator USE_BEGINBURSTTRANSFER 0
    set_instance_parameter slave_translator USE_BEGINTRANSFER      [ get_parameter_value USE_BEGINTRANSFER ]
    set_instance_parameter slave_translator USE_BYTEENABLE         [ get_parameter_value USE_BYTEENABLE ]
    set_instance_parameter slave_translator USE_CHIPSELECT         [ get_parameter_value USE_CHIPSELECT ]
    set_instance_parameter slave_translator USE_ADDRESS            [ get_parameter_value USE_ADDRESS ]
    set_instance_parameter slave_translator USE_BURSTCOUNT           0
    set_instance_parameter slave_translator USE_READDATAVALID        0
    set_instance_parameter slave_translator USE_WAITREQUEST        [ get_parameter_value USE_WAITREQUEST ]
    set_instance_parameter slave_translator USE_WRITEBYTEENABLE    [ get_parameter_value USE_WRITEBYTEENABLE ]
    set_instance_parameter slave_translator USE_LOCK               0
    set_instance_parameter slave_translator USE_OUTPUTENABLE       [ get_parameter_value USE_OUTPUTENABLE ]
    set_instance_parameter slave_translator AV_SYMBOLS_PER_WORD    [ get_parameter_value TCM_SYMBOLS_PER_WORD ]
    set_instance_parameter slave_translator AV_ADDRESS_SYMBOLS       1
    set_instance_parameter slave_translator AV_BURSTCOUNT_SYMBOLS    1
    set_instance_parameter slave_translator AV_CONSTANT_BURST_BEHAVIOR 0
    set_instance_parameter slave_translator CHIPSELECT_THROUGH_READLATENCY [ get_parameter_value CHIPSELECT_THROUGH_READLATENCY ]
    set_instance_parameter slave_translator AV_TIMING_UNITS                [ get_parameter_value TCM_TIMING_UNITS ]
    set_instance_parameter slave_translator AV_MAX_PENDING_READ_TRANSACTIONS [get_parameter_value TCM_MAX_PENDING_READ_TRANSACTIONS]


    #Configure TDA
    set_instance_parameter tda AV_ADDRESS_W                [ get_parameter_value TCM_ADDRESS_W ]
    set_instance_parameter tda AV_DATA_W                   [ get_parameter_value TCM_DATA_W ]
    set_instance_parameter tda AV_BYTEENABLE_W             [ get_parameter_value TCM_BYTEENABLE_W ]
    set_instance_parameter tda USE_READDATA                [ get_parameter_value USE_READDATA ]
    set_instance_parameter tda USE_WRITEDATA               [ get_parameter_value USE_WRITEDATA ]
    set_instance_parameter tda USE_READ                    [ get_parameter_value USE_READ ]
    set_instance_parameter tda USE_WRITE                   [ get_parameter_value USE_WRITE ]
    set_instance_parameter tda USE_BEGINTRANSFER           [ get_parameter_value USE_BEGINTRANSFER ]
    set_instance_parameter tda USE_BYTEENABLE              [ get_parameter_value USE_BYTEENABLE ]
    set_instance_parameter tda USE_CHIPSELECT              [ get_parameter_value USE_CHIPSELECT ]
    set_instance_parameter tda USE_LOCK             [ get_parameter_value USE_LOCK ]
    set_instance_parameter tda USE_ADDRESS                 [ get_parameter_value USE_ADDRESS ]
    set_instance_parameter tda USE_WAITREQUEST             [ get_parameter_value USE_WAITREQUEST ]
    set_instance_parameter tda USE_WRITEBYTEENABLE         [ get_parameter_value USE_WRITEBYTEENABLE ]
    set_instance_parameter tda USE_OUTPUTENABLE            [ get_parameter_value USE_OUTPUTENABLE ]
    set_instance_parameter tda USE_RESETREQUEST            [ get_parameter_value USE_RESETREQUEST ]
    set_instance_parameter tda USE_IRQ                     [ get_parameter_value USE_IRQ ]
    set_instance_parameter tda USE_RESET_OUTPUT            [ get_parameter_value USE_RESET_OUTPUT ]
    set_instance_parameter tda ACTIVE_LOW_READ             [ get_parameter_value ACTIVE_LOW_READ ]
    set_instance_parameter tda ACTIVE_LOW_LOCK      [ get_parameter_value ACTIVE_LOW_LOCK ]
    set_instance_parameter tda ACTIVE_LOW_WRITE            [ get_parameter_value ACTIVE_LOW_WRITE ]
    set_instance_parameter tda ACTIVE_LOW_CHIPSELECT       [ get_parameter_value ACTIVE_LOW_CHIPSELECT ]
    set_instance_parameter tda ACTIVE_LOW_BYTEENABLE       [ get_parameter_value ACTIVE_LOW_BYTEENABLE ]
    set_instance_parameter tda ACTIVE_LOW_OUTPUTENABLE     [ get_parameter_value ACTIVE_LOW_OUTPUTENABLE ]
    set_instance_parameter tda ACTIVE_LOW_WRITEBYTEENABLE  [ get_parameter_value ACTIVE_LOW_WRITEBYTEENABLE ]
    set_instance_parameter tda ACTIVE_LOW_WAITREQUEST      [ get_parameter_value ACTIVE_LOW_WAITREQUEST ]
    set_instance_parameter tda ACTIVE_LOW_BEGINTRANSFER    [ get_parameter_value ACTIVE_LOW_BEGINTRANSFER ]
    set_instance_parameter tda ACTIVE_LOW_RESETREQUEST     [ get_parameter_value ACTIVE_LOW_RESETREQUEST ]  
    set_instance_parameter tda ACTIVE_LOW_IRQ              [ get_parameter_value ACTIVE_LOW_IRQ ]
    set_instance_parameter tda ACTIVE_LOW_RESET_OUTPUT     [ get_parameter_value ACTIVE_LOW_RESET_OUTPUT ]
    set_instance_parameter tda AV_READ_WAIT                [ get_parameter_value TCM_READ_WAIT ]
    set_instance_parameter tda AV_WRITE_WAIT               [ get_parameter_value TCM_WRITE_WAIT ]
    set_instance_parameter tda AV_READ_LATENCY                                  $TCM_READLATENCY
    set_instance_parameter tda AV_SETUP_WAIT               [ get_parameter_value TCM_SETUP_WAIT ]
    set_instance_parameter tda AV_HOLD_TIME                [ get_parameter_value TCM_DATA_HOLD ]
    set_instance_parameter tda AV_TIMING_UNITS             [ get_parameter_value TCM_TIMING_UNITS ]

    if { [get_parameter_value USE_RESETREQUEST] == 1} {
	add_interface reset_out reset start
	set_interface_property reset_out export_of tda.reset_out
    }

    if { [get_parameter_value USE_IRQ ] == 1 } {
	add_interface irq_out interrupt sender
	set_interface_property irq_out export_of tda.irq_out
    }

    if { [get_parameter IS_MEMORY_DEVICE] } {
	set_module_assignment embeddedsw.memoryInfo.MEM_INIT_DATA_WIDTH [get_parameter TCM_DATA_W]
	set_module_assignment embeddedsw.memoryInfo.DAT_SYM_INSTALL_DIR SIM_DIR
	set_module_assignment embeddedsw.memoryInfo.GENERATE_DAT_SYM 1
	set_module_assignment testbench.partner.external_mem_bfm.class altera_external_memory_bfm
	set_module_assignment testbench.partner.external_mem_bfm.parameter.CDT_ADDRESS_W [ get_parameter TCM_ADDRESS_W ]
	set_module_assignment testbench.partner.external_mem_bfm.parameter.CDT_SYMBOL_W 8
	set_module_assignment testbench.partner.external_mem_bfm.parameter.CDT_NUMSYMBOLS [expr [ get_parameter TCM_DATA_W ] / 8]

    # + ------------------------------------------------------
    # | A helpful comment above says that read latency should be parameterized as actual_device_latency + 2.
    # | Well then, here we have the actual device model. So we need to subtract 2 from the tcm read latency
    # | value.
    # + ------------------------------------------------------
	set_module_assignment testbench.partner.external_mem_bfm.parameter.CDT_READ_LATENCY [ expr $TCM_READLATENCY - 2 ]
	set_module_assignment testbench.partner.external_mem_bfm.parameter.SIGNAL_ADDRESS_ROLES tcm_address_out
	set_module_assignment testbench.partner.external_mem_bfm.parameter.SIGNAL_DATA_ROLES tcm_data_out

	if { [get_parameter ACTIVE_LOW_RESET_OUTPUT] } {
	    set_module_assignment testbench.partner.external_mem_bfm.parameter.SIGNAL_RESET_ROLES tcm_reset_n_out
	} else {
	    set_module_assignment testbench.partner.external_mem_bfm.parameter.SIGNAL_RESET_ROLES tcm_reset_out
	}
	if { [get_parameter ACTIVE_LOW_CHIPSELECT] } {
	    set_module_assignment testbench.partner.external_mem_bfm.parameter.SIGNAL_CHIPSELECT_ROLES tcm_chipselect_n_out
	} else {
	    set_module_assignment testbench.partner.external_mem_bfm.parameter.SIGNAL_CHIPSELECT_ROLES tcm_chipselect_out
	}
	if { [get_parameter ACTIVE_LOW_WRITE] } {
	    set_module_assignment testbench.partner.external_mem_bfm.parameter.SIGNAL_WRITE_ROLES tcm_write_n_out
	} else {
	    set_module_assignment testbench.partner.external_mem_bfm.parameter.SIGNAL_WRITE_ROLES tcm_write_out
	}
	if { [get_parameter ACTIVE_LOW_READ] } {
	    set_module_assignment testbench.partner.external_mem_bfm.parameter.SIGNAL_READ_ROLES tcm_read_n_out
	} else {
	    set_module_assignment testbench.partner.external_mem_bfm.parameter.SIGNAL_READ_ROLES tcm_read_out
	}
	if { [get_parameter ACTIVE_LOW_BYTEENABLE] } {
	    set_module_assignment testbench.partner.external_mem_bfm.parameter.SIGNAL_BYTEENABLE_ROLES tcm_byteenable_n_out
	} else {
	    set_module_assignment testbench.partner.external_mem_bfm.parameter.SIGNAL_BYTEENABLE_ROLES tcm_byteenable_out
	}
	if { [get_parameter ACTIVE_LOW_BEGINTRANSFER] } {
	    set_module_assignment testbench.partner.external_mem_bfm.parameter.SIGNAL_BEGINTRANSFER_ROLES tcm_begintransfer_n_out
	} else {
	    set_module_assignment testbench.partner.external_mem_bfm.parameter.SIGNAL_BEGINTRANSFER_ROLES tcm_begintransfer_out
	}
	if { [get_parameter ACTIVE_LOW_OUTPUTENABLE] } {
	    set_module_assignment testbench.partner.external_mem_bfm.parameter.SIGNAL_OUTPUTENABLE_ROLES tcm_outputenable_n_out
	} else {
	    set_module_assignment testbench.partner.external_mem_bfm.parameter.SIGNAL_OUTPUTENABLE_ROLES tcm_outputenable_out
	}
   
	set_module_assignment postgeneration.simulation.init_file.param_name INIT_FILE
	set_module_assignment postgeneration.simulation.init_file.type MEM_INIT
	set_module_assignment postgeneration.simulation.init_file.param_owner tcm
	
	set_module_assignment testbench.partner.external_mem_bfm.parameter.USE_BEGINTRANSFER [ get_parameter USE_BEGINTRANSFER ]
	set_module_assignment testbench.partner.external_mem_bfm.parameter.USE_BYTEENABLE [ get_parameter USE_BYTEENABLE ]
	set_module_assignment testbench.partner.external_mem_bfm.parameter.USE_CHIPSELECT [ get_parameter USE_CHIPSELECT ] 
	set_module_assignment testbench.partner.external_mem_bfm.parameter.USE_WRITE [ get_parameter USE_WRITE ]
	set_module_assignment testbench.partner.external_mem_bfm.parameter.USE_READ [ get_parameter USE_READ ]
	set_module_assignment testbench.partner.external_mem_bfm.parameter.USE_OUTPUTENABLE [ get_parameter USE_OUTPUTENABLE ]
	set_module_assignment testbench.partner.external_mem_bfm.parameter.USE_RESET [ get_parameter USE_RESET_OUTPUT ]
	set_module_assignment testbench.partner.external_mem_bfm.parameter.ACTIVE_LOW_CHIPSELECT [get_parameter ACTIVE_LOW_CHIPSELECT]
	set_module_assignment testbench.partner.external_mem_bfm.parameter.ACTIVE_LOW_OUTPUTENABLE [ get_parameter ACTIVE_LOW_OUTPUTENABLE ]
	set_module_assignment testbench.partner.external_mem_bfm.parameter.ACTIVE_LOW_WRITE [ get_parameter ACTIVE_LOW_WRITE ]
	set_module_assignment testbench.partner.external_mem_bfm.parameter.ACTIVE_LOW_READ [ get_parameter ACTIVE_LOW_READ ]
	set_module_assignment testbench.partner.external_mem_bfm.parameter.ACTIVE_LOW_BYTEENABLE [ get_parameter ACTIVE_LOW_BYTEENABLE ]
	set_module_assignment testbench.partner.external_mem_bfm.parameter.ACTIVE_LOW_BEGINTRANSFER [ get_parameter ACTIVE_LOW_BEGINTRANSFER ]
	set_module_assignment testbench.partner.external_mem_bfm.parameter.ACTIVE_LOW_RESET [ get_parameter ACTIVE_LOW_RESET_OUTPUT ]
	set_module_assignment testbench.partner.map.tcm external_mem_bfm.conduit
	set_module_assignment testbench.partner.map.clk external_mem_bfm.clk
    }
}
