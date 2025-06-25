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


# $File: //acds/rel/13.1/ip/sopc/components/verification/altera_avalon_mm_memory/altera_avalon_mm_memory_hw.tcl $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $
#------------------------------------------------------------------------------
package require -exact sopc 9.1

set_module_property NAME             	 	 altera_avalon_mm_memory
set_module_property GROUP            	 	 "Avalon Verification Suite"
set_module_property DISPLAY_NAME     	 	 "Altera Avalon MM Memory Slave"
set_module_property DESCRIPTION      	 	 "Altera Avalon MM Memory Slave"
set_module_property VERSION          	 	 13.1
set_module_property AUTHOR           	 	 "Altera Corporation"
set_module_property TOP_LEVEL_HDL_FILE   	 altera_avalon_mm_memory.sv
set_module_property TOP_LEVEL_HDL_MODULE 	 altera_avalon_mm_memory
set_module_property EDITABLE 			 false               
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property INTERNAL 			 true
set_module_property VALIDATION_CALLBACK          validate
set_module_property ELABORATION_CALLBACK         elaborate

#------------------------------------------------------------------------------
# Files
#------------------------------------------------------------------------------
set HDL_LIB_DIR "../lib"

add_file $HDL_LIB_DIR/verbosity_pkg.sv {SIMULATION}
add_file altera_avalon_mm_memory.sv    {SIMULATION SYNTHESIS}

#------------------------------------------------------------------------------
# Parameters
#------------------------------------------------------------------------------
set AV_ADDRESS_W             "AV_ADDRESS_W"
set AV_SYMBOL_W              "AV_SYMBOL_W" 
set AV_NUMSYMBOLS            "AV_NUMSYMBOLS"

#---------------------------------------------------------------------
add_parameter $AV_ADDRESS_W Positive 10
set_parameter_property $AV_ADDRESS_W DISPLAY_NAME "Address width"
set_parameter_property $AV_ADDRESS_W AFFECTS_ELABORATION true
set_parameter_property $AV_ADDRESS_W IS_HDL_PARAMETER true
set_parameter_property $AV_ADDRESS_W DESCRIPTION "The width of the address signal."
set_parameter_property $AV_ADDRESS_W GROUP "Port Widths"

add_parameter $AV_SYMBOL_W Positive 8
set_parameter_property $AV_SYMBOL_W DISPLAY_NAME "Symbol width"
set_parameter_property $AV_SYMBOL_W AFFECTS_ELABORATION true
set_parameter_property $AV_SYMBOL_W IS_HDL_PARAMETER true
set_parameter_property $AV_SYMBOL_W GROUP "Port Widths"

add_parameter $AV_NUMSYMBOLS Positive 4
set_parameter_property $AV_NUMSYMBOLS DISPLAY_NAME "Number of Symbols"
set_parameter_property $AV_NUMSYMBOLS AFFECTS_ELABORATION true
set_parameter_property $AV_NUMSYMBOLS ALLOWED_RANGES {1,2,4,8,16,32,64,128}
set_parameter_property $AV_NUMSYMBOLS IS_HDL_PARAMETER true
set_parameter_property $AV_SYMBOL_W GROUP "Port Widths"


#---------------------------------------------------------------------
proc validate {} {
    global AV_ADDRESS_W

    if { [get_parameter_value $AV_ADDRESS_W] > 16 } {
	send_message error "Address width must be less than or equal to 16 bits"
    }

}
#------------------------------------------------------------------------------
proc elaborate {} {
    global AV_ADDRESS_W          
    global AV_SYMBOL_W           
    global AV_NUMSYMBOLS         

    set AV_ADDRESS_W_VALUE  [get_parameter_value $AV_ADDRESS_W]
    set AV_SYMBOL_W_VALUE   [get_parameter_value $AV_SYMBOL_W] 
    set AV_NUMSYMBOLS_VALUE [get_parameter_value $AV_NUMSYMBOLS]

    set AV_DATA_W_VALUE [expr {$AV_SYMBOL_W_VALUE * $AV_NUMSYMBOLS_VALUE}]

    # Interface Names
    #---------------------------------------------------------------------
    set CLOCK_INTERFACE  "clk"
    set SLAVE_INTERFACE  "s0"

    #---------------------------------------------------------------------
    # Clock-Reset connection point
    #---------------------------------------------------------------------
    add_interface $CLOCK_INTERFACE clock end
    add_interface_port $CLOCK_INTERFACE clk clk Input 1
    add_interface_port $CLOCK_INTERFACE reset reset Input 1

    #---------------------------------------------------------------------
    #  Avalon Slave connection point
    #---------------------------------------------------------------------
    add_interface $SLAVE_INTERFACE avalon end

    # Interface Properties
    #---------------------------------------------------------------------
    set_interface_property $SLAVE_INTERFACE ENABLED true
    set_interface_property $SLAVE_INTERFACE ASSOCIATED_CLOCK $CLOCK_INTERFACE
    set_interface_property $SLAVE_INTERFACE addressAlignment DYNAMIC
    set_interface_property $SLAVE_INTERFACE holdTime 0
    set_interface_property $SLAVE_INTERFACE isMemoryDevice false
    set_interface_property $SLAVE_INTERFACE isNonVolatileStorage false
    set_interface_property $SLAVE_INTERFACE minimumUninterruptedRunLength 1
    set_interface_property $SLAVE_INTERFACE printableDevice false
    set_interface_property $SLAVE_INTERFACE readLatency 0
    set_interface_property $SLAVE_INTERFACE readWaitTime 1
    set_interface_property $SLAVE_INTERFACE setupTime 0
    set_interface_property $SLAVE_INTERFACE timingUnits Cycles
    set_interface_property $SLAVE_INTERFACE writeWaitTime 0
    set_interface_property $SLAVE_INTERFACE maximumPendingReadTransactions 1
    set_interface_property $SLAVE_INTERFACE linewrapBursts false
    set_interface_property $SLAVE_INTERFACE burstOnBurstBoundariesOnly false


    # Interface Ports					  
    #---------------------------------------------------------------------
    add_interface_port $SLAVE_INTERFACE avs_waitrequest waitrequest Output 1
    add_interface_port $SLAVE_INTERFACE avs_read read Input 1
    add_interface_port $SLAVE_INTERFACE avs_write write Input 1
    add_interface_port $SLAVE_INTERFACE avs_address address Input $AV_ADDRESS_W_VALUE
    add_interface_port $SLAVE_INTERFACE avs_byteenable byteenable Input $AV_NUMSYMBOLS_VALUE
    add_interface_port $SLAVE_INTERFACE avs_writedata writedata Input $AV_DATA_W_VALUE
    add_interface_port $SLAVE_INTERFACE avs_readdata readdata Output $AV_DATA_W_VALUE
    add_interface_port $SLAVE_INTERFACE avs_readdatavalid readdatavalid Output 1
}


