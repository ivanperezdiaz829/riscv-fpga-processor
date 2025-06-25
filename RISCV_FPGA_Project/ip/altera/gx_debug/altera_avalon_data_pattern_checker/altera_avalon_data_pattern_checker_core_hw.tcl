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
# | request TCL package from ACDS 9.1
# | 
package require -exact sopc 9.1
# | 
# +-----------------------------------

# +-----------------------------------
# | module altera_avalon_data_pattern_checker
# | 
set_module_property DESCRIPTION "An parallel data pattern checker core"
set_module_property NAME altera_avalon_data_pattern_checker_core 
set_module_property VERSION 13.1
set_module_property INTERNAL true 
set_module_property GROUP "Peripherals/Debug and Performance"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Avalon-ST Data Pattern Checker core"
set_module_property DATASHEET_URL http://www.altera.com/literature/ug/ug_embedded_ip.pdf
set_module_property TOP_LEVEL_HDL_FILE altera_avalon_data_pattern_checker.v
set_module_property TOP_LEVEL_HDL_MODULE altera_avalon_data_pattern_checker
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file altera_avalon_data_pattern_checker.v {SYNTHESIS SIMULATION}
add_file ../../merlin/altera_reset_controller/altera_reset_controller.v {SYNTHESIS SIMULATION}
add_file ../../merlin/altera_reset_controller/altera_reset_synchronizer.v {SYNTHESIS SIMULATION}
add_file altera_avalon_data_pattern_checker.sdc SDC
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter ST_DATA_W INTEGER 40
set_parameter_property ST_DATA_W ALLOWED_RANGES {32 40 50 64 66 80 128}
set_parameter_property ST_DATA_W DISPLAY_NAME ST_DATA_W
set_parameter_property ST_DATA_W UNITS None
set_parameter_property ST_DATA_W DISPLAY_HINT ""
set_parameter_property ST_DATA_W AFFECTS_GENERATION true
set_parameter_property ST_DATA_W IS_HDL_PARAMETER true

add_parameter NUM_CYCLES_FOR_LOCK INTEGER 40
set_parameter_property NUM_CYCLES_FOR_LOCK ALLOWED_RANGES 1:255 
set_parameter_property NUM_CYCLES_FOR_LOCK DISPLAY_NAME NUM_CYCLES_FOR_LOCK
set_parameter_property NUM_CYCLES_FOR_LOCK UNITS None
set_parameter_property NUM_CYCLES_FOR_LOCK VISIBLE false
set_parameter_property NUM_CYCLES_FOR_LOCK DISPLAY_HINT ""
set_parameter_property NUM_CYCLES_FOR_LOCK AFFECTS_GENERATION false
set_parameter_property NUM_CYCLES_FOR_LOCK IS_HDL_PARAMETER true

add_parameter BYPASS_ENABLED boolean 1
set_parameter_property BYPASS_ENABLED DEFAULT_VALUE 0
set_parameter_property BYPASS_ENABLED DISPLAY_NAME "Enable Bypass Interface"
set_parameter_property BYPASS_ENABLED UNITS None
set_parameter_property BYPASS_ENABLED DISPLAY_HINT "Select to add bypass interface"
set_parameter_property BYPASS_ENABLED AFFECTS_GENERATION true
set_parameter_property BYPASS_ENABLED IS_HDL_PARAMETER true 

add_parameter AVALON_ENABLED boolean 1 
set_parameter_property AVALON_ENABLED DEFAULT_VALUE 1
set_parameter_property AVALON_ENABLED DISPLAY_NAME "Enable Avalon Interface"
set_parameter_property AVALON_ENABLED UNITS None
set_parameter_property AVALON_ENABLED DISPLAY_HINT "Select to enable Avalon interface"
set_parameter_property AVALON_ENABLED AFFECTS_GENERATION true
set_parameter_property AVALON_ENABLED IS_HDL_PARAMETER true 

add_parameter FREQ_CNTER_ENABLED boolean 1 
set_parameter_property FREQ_CNTER_ENABLED DEFAULT_VALUE 0
set_parameter_property FREQ_CNTER_ENABLED DISPLAY_NAME "Enable Frequency Counter"
set_parameter_property FREQ_CNTER_ENABLED UNITS None
set_parameter_property FREQ_CNTER_ENABLED DISPLAY_HINT "Select to add frequency counter "
set_parameter_property FREQ_CNTER_ENABLED AFFECTS_GENERATION true
set_parameter_property FREQ_CNTER_ENABLED IS_HDL_PARAMETER true 
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point csr_clk
# | 
add_interface csr_clk clock end
set_interface_property csr_clk ENABLED true

add_interface_port csr_clk avs_clk clk Input 1
add_interface_port csr_clk reset reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point csr_slave
# | 
add_interface csr_slave avalon end
set_interface_property csr_slave addressAlignment DYNAMIC
set_interface_property csr_slave burstOnBurstBoundariesOnly false
set_interface_property csr_slave explicitAddressSpan 0
set_interface_property csr_slave holdTime 0
set_interface_property csr_slave isMemoryDevice false
set_interface_property csr_slave isNonVolatileStorage false
set_interface_property csr_slave linewrapBursts false
set_interface_property csr_slave maximumPendingReadTransactions 0
set_interface_property csr_slave printableDevice false
set_interface_property csr_slave readLatency 1
set_interface_property csr_slave readWaitTime 0
set_interface_property csr_slave setupTime 0
set_interface_property csr_slave timingUnits Cycles
set_interface_property csr_slave writeWaitTime 0

set_interface_property csr_slave ASSOCIATED_CLOCK csr_clk
set_interface_property csr_slave ENABLED true

add_interface_port csr_slave avs_address address Input 3
add_interface_port csr_slave avs_write write Input 1
add_interface_port csr_slave avs_read read Input 1
add_interface_port csr_slave avs_byteenable byteenable Input 4
add_interface_port csr_slave avs_writedata writedata Input 32 
add_interface_port csr_slave avs_readdata readdata Output 32

# +-----------------------------------
# | elaboration callback
# | 
proc elaborate {} {
	set DATA_WIDTH [get_parameter_value ST_DATA_W]
	
	if { $DATA_WIDTH == 40 } {
	set SYMBOLS_PER_BEAT 4
	} elseif { $DATA_WIDTH == 32 } {
      set SYMBOLS_PER_BEAT 4
    } elseif { $DATA_WIDTH == 50 } {
	  set SYMBOLS_PER_BEAT 5	  
    } elseif { $DATA_WIDTH == 66 } {
      set SYMBOLS_PER_BEAT 1
    } elseif { $DATA_WIDTH == 64 } {	  
      set SYMBOLS_PER_BEAT 8
    } elseif { $DATA_WIDTH == 80 } {	  
      set SYMBOLS_PER_BEAT 10	  
    } else {
	  set SYMBOLS_PER_BEAT 16
    }	
	
    set bypass [get_parameter_value BYPASS_ENABLED]
    set avalon [get_parameter_value AVALON_ENABLED]
    
    if { $bypass == "true" } {
        if { $avalon == "true" } {
            set output_avalon "true"
            set output_conduit "false"
        } else {
            set output_avalon "false"
            set output_conduit "true"
        }
    }  {
        set output_avalon "false"
        set output_conduit "false"
    }
    
    if { $avalon == "true" } {
        set conduit false
    } else {
        set conduit true
    }

    if { $avalon == "true" } {
        #streaming clock
        add_interface pattern_in_clk clock end
        add_interface_port pattern_in_clk asi_clk clk Input 1
        set_interface_property pattern_in_clk ENABLED $avalon

        #avalon streaming
        add_interface pattern_in avalon_streaming sink end
        
        set_interface_property pattern_in dataBitsPerSymbol 10
        set_interface_property pattern_in errorDescriptor ""
        set_interface_property pattern_in maxChannel 0
        set_interface_property pattern_in readyLatency 0
        set_interface_property pattern_in symbolsPerBeat 4
        set_interface_property pattern_in ASSOCIATED_CLOCK pattern_in_clk
        set_interface_property pattern_in ENABLED $avalon 
        set_interface_property pattern_in dataBitsPerSymbol [expr $DATA_WIDTH / $SYMBOLS_PER_BEAT]
        set_interface_property pattern_in associatedReset csr_clk_reset
        add_interface_port pattern_in asi_valid valid Input 1
        add_interface_port pattern_in asi_ready ready Output 1
        add_interface_port pattern_in asi_data data Input $DATA_WIDTH
    } else {
        #conduit input clock
        add_interface conduit_pattern_in_clk conduit end 
        set_interface_property conduit_pattern_in_clk ENABLED $conduit
        add_interface_port conduit_pattern_in_clk asi_clk export Input 1

        #conduit input data
        add_interface conduit_pattern_in conduit end 
        set_interface_property conduit_pattern_in ENABLED $conduit
        add_interface_port conduit_pattern_in asi_data export Input $DATA_WIDTH
    }

    if { $output_avalon == "true" } { 
        #streaming output clock
        add_interface pattern_out_clk clock source
        add_interface_port pattern_out_clk aso_clk clk output 1
        set_interface_property pattern_out_clk ENABLED $output_avalon

        #pattern out avalon mode
        add_interface pattern_out avalon_streaming source end
     
        set_interface_property pattern_out errorDescriptor ""
        set_interface_property pattern_out maxChannel 0
        set_interface_property pattern_out readyLatency 0
        set_interface_property pattern_out symbolsPerBeat 4
        set_interface_property pattern_out ASSOCIATED_CLOCK pattern_out_clk
        set_interface_property pattern_out associatedReset csr_clk_reset
        set_interface_property pattern_out ENABLED $output_avalon 
        set_interface_property pattern_out dataBitsPerSymbol [expr $DATA_WIDTH / $SYMBOLS_PER_BEAT] 

        add_interface_port pattern_out aso_valid valid Output 1
        add_interface_port pattern_out aso_ready ready Input 1
        add_interface_port pattern_out aso_data data Output $DATA_WIDTH
    }
   if  { $output_conduit == "true" } {
        add_interface conduit_pattern_out_clk conduit end 
        set_interface_property conduit_pattern_out_clk ENABLED $output_conduit
        add_interface_port conduit_pattern_out_clk aso_clk export Output 1
        
        add_interface conduit_pattern_out conduit end 
        set_interface_property conduit_pattern_out ENABLED $output_conduit
        add_interface_port conduit_pattern_out aso_data export Output $DATA_WIDTH
      } 
}

