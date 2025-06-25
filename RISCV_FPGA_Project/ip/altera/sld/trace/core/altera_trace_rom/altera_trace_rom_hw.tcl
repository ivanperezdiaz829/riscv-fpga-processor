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


# +-----------------------------------
# | request TCL package from ACDS 11.0
# | 
package require -exact sopc 11.0
# | 
# +-----------------------------------

# +-----------------------------------
# | module altera_trace_rom
# | 
set_module_property NAME                         altera_trace_rom
set_module_property VERSION                      13.1
set_module_property AUTHOR                       "Altera Corporation"
set_module_property INTERNAL                     true
set_module_property OPAQUE_ADDRESS_MAP           true
set_module_property GROUP                        "Verification/Debug & Performance/Trace"
set_module_property DISPLAY_NAME                 "Trace ROM"
set_module_property TOP_LEVEL_HDL_FILE           altera_trace_rom.v
set_module_property TOP_LEVEL_HDL_MODULE         altera_trace_rom
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE                     true
set_module_property ANALYZE_HDL                  false
set_module_property STATIC_TOP_LEVEL_MODULE_NAME "altera_trace_rom"
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file altera_trace_rom.v {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------



proc proc_add_parameter {NAME TYPE DEFAULT IS_HDL VISIBLE AFFECTS_GENERATION GROUP DISP_NAME DESCRIPTION  args} {
    add_parameter           $NAME $TYPE $DEFAULT $DESCRIPTION
    if {$args != ""} then {
        set_parameter_property  $NAME "ALLOWED_RANGES" $args
    }
    set_parameter_property  $NAME "VISIBLE"            $VISIBLE
    set_parameter_property  $NAME "HDL_PARAMETER"      $IS_HDL
    set_parameter_property  $NAME "GROUP"              $GROUP
    set_parameter_property  $NAME "DISPLAY_NAME"       $DISP_NAME
    set_parameter_property  $NAME "AFFECTS_GENERATION" $AFFECTS_GENERATION
}


# +-----------------------------------
# | parameters
# | 
#                    name                      type   def_value   is_hdl   VISIBLE  Affects     group          display name                   Tooltip hint                                                                  args_range
#                  |                     |           |                              generation                                                                                                                         
proc_add_parameter  NUM_REGS                  INTEGER    1        true     true      true       ""           "Number of registers"           " "                                                                              1:32
proc_add_parameter  ADDR_WIDTH                INTEGER    2        true     true      true       ""           "Address Width"                   "Make sure I'm big enough for the number of clock domains! "                     1:5
proc_add_parameter  DATA_WIDTH                INTEGER    32       true     true      true       ""           "Data Width"                   "Make sure I'm big enough for the number of clock domains! "                     32:32

proc_add_parameter  REG_VALUE_STRING          STRING   "03020100" true     true      true       ""           "Regster values"                "register values as a string"
                      
# |                                                                                                                               
# +-----------------------------------

# +-----------------------------------
# | display items
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clk
# | 
add_interface clk clock end
set_interface_property clk clockRate 0

set_interface_property clk ENABLED true

add_interface_port clk clk clk Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point rom
# | 
add_interface rom avalon end
set_interface_property rom addressUnits WORDS
set_interface_property rom associatedClock clk
set_interface_property rom associatedReset reset
set_interface_property rom bitsPerSymbol 8
set_interface_property rom burstOnBurstBoundariesOnly false
set_interface_property rom burstcountUnits WORDS
set_interface_property rom explicitAddressSpan 0
set_interface_property rom holdTime 0
set_interface_property rom linewrapBursts false
set_interface_property rom maximumPendingReadTransactions 0
set_interface_property rom readLatency 2
set_interface_property rom readWaitStates 0
set_interface_property rom readWaitTime 0
set_interface_property rom setupTime 0
set_interface_property rom timingUnits Cycles
set_interface_property rom writeWaitTime 0

set_interface_property rom ENABLED true

add_interface_port rom rom_read read Input 1
add_interface_port rom rom_address address Input ADDR_WIDTH
add_interface_port rom rom_readdata readdata Output DATA_WIDTH
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point reset
# | 
add_interface reset reset end
set_interface_property reset associatedClock clk
set_interface_property reset synchronousEdges DEASSERT

set_interface_property reset ENABLED true

add_interface_port reset arst_n reset_n Input 1
# | 
# +-----------------------------------
