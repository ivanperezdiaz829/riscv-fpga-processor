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
# | 
# | altera_reset_controller "Merlin Reset Controller" v1.0
# | null 2009.06.28.16:38:58
# | 
# | 
# |    ./altera_reset_controller.v syn, sim
# |    ./altera_reset_synchronizer.v syn, sim
# | 
# +-----------------------------------

# +-----------------------------------
# | request TCL package 
# | 
package require -exact qsys 12.1
# | 
# +-----------------------------------

# +-----------------------------------
# | module altera_reset_controller
# | 
set_module_property DESCRIPTION ""
set_module_property NAME altera_reset_controller
set_module_property VERSION 13.1
set_module_property GROUP "Merlin Components"
set_module_property DISPLAY_NAME "Merlin Reset Controller"
set_module_property DESCRIPTION "For systems with multiple reset inputs, the Merlin Reset Controller ORs all reset inputs and generates a single reset output."
set_module_property AUTHOR "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ELABORATION_CALLBACK elaborate
set_module_property HIDE_FROM_SOPC false
set_module_property ANALYZE_HDL FALSE
set_module_property DATASHEET_URL http://www.altera.com/literature/hb/qts/qsys_interconnect.pdf
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 

add_fileset synthesis_fileset QUARTUS_SYNTH synth_callback_procedure
set_fileset_property synthesis_fileset TOP_LEVEL altera_reset_controller 
add_fileset simulation_fileset SIM_VERILOG synth_callback_procedure
set_fileset_property simulation_fileset TOP_LEVEL altera_reset_controller
add_fileset vhdl_fileset SIM_VHDL synth_callback_procedure_vhdl
set_fileset_property vhdl_fileset TOP_LEVEL altera_reset_controller

proc synth_callback_procedure { entity_name } {
    add_fileset_file altera_reset_controller.v VERILOG PATH "altera_reset_controller.v"
	add_fileset_file altera_reset_synchronizer.v VERILOG PATH "altera_reset_synchronizer.v"
	add_fileset_file altera_reset_controller.sdc SDC PATH "altera_reset_controller.sdc"
}

proc synth_callback_procedure_vhdl { entity_name } {
   if {1} {
      add_fileset_file mentor/altera_reset_controller.v VERILOG_ENCRYPT PATH "mentor/altera_reset_controller.v" {MENTOR_SPECIFIC}
	  add_fileset_file mentor/altera_reset_synchronizer.v VERILOG_ENCRYPT PATH "mentor/altera_reset_synchronizer.v" {MENTOR_SPECIFIC}
   }
   if {1} {
      add_fileset_file aldec/altera_reset_controller.v VERILOG_ENCRYPT PATH "aldec/altera_reset_controller.v" {ALDEC_SPECIFIC}
	  add_fileset_file aldec/altera_reset_synchronizer.v VERILOG_ENCRYPT PATH "aldec/altera_reset_synchronizer.v" {ALDEC_SPECIFIC}
   }
   if {0} {
      add_fileset_file cadence/altera_reset_controller.v VERILOG_ENCRYPT PATH "cadence/altera_reset_controller.v" {CADENCE_SPECIFIC}
	  add_fileset_file cadence/altera_reset_synchronizer.v VERILOG_ENCRYPT PATH "cadence/altera_reset_synchronizer.v" {CADENCE_SPECIFIC}
   }
   if {0} {
      add_fileset_file synopsys/altera_reset_controller.v VERILOG_ENCRYPT PATH "synopsys/altera_reset_controller.v" {SYNOPSYS_SPECIFIC}
	  add_fileset_file synopsys/altera_reset_synchronizer.v VERILOG_ENCRYPT PATH "synopsys/altera_reset_synchronizer.v" {SYNOPSYS_SPECIFIC}
   }    
}

# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter NUM_RESET_INPUTS INTEGER 6
set_parameter_property NUM_RESET_INPUTS DEFAULT_VALUE 6
set_parameter_property NUM_RESET_INPUTS DISPLAY_NAME {Number of inputs}
set_parameter_property NUM_RESET_INPUTS UNITS None
set_parameter_property NUM_RESET_INPUTS DISPLAY_HINT ""
set_parameter_property NUM_RESET_INPUTS AFFECTS_GENERATION false
set_parameter_property NUM_RESET_INPUTS HDL_PARAMETER true
set_parameter_property NUM_RESET_INPUTS ALLOWED_RANGES "1:16"
set_parameter_property NUM_RESET_INPUTS DESCRIPTION {Number of input reset interfaces}

add_parameter OUTPUT_RESET_SYNC_EDGES STRING "deassert"
set_parameter_property OUTPUT_RESET_SYNC_EDGES DISPLAY_NAME {Output Reset Synchronous Edges}
set_parameter_property OUTPUT_RESET_SYNC_EDGES UNITS None
set_parameter_property OUTPUT_RESET_SYNC_EDGES AFFECTS_GENERATION false
set_parameter_property OUTPUT_RESET_SYNC_EDGES HDL_PARAMETER true
set_parameter_property OUTPUT_RESET_SYNC_EDGES ALLOWED_RANGES "none,both,deassert"
set_parameter_property OUTPUT_RESET_SYNC_EDGES DESCRIPTION {None: The reset is asserted and deasserted asynchronously. Use this setting if you have designed internal synchronization circuitry. Both: The reset is asserted and deasserted synchronously. Deassert: The reset is deasserted synchronously and asserted asynchronously.}

add_parameter SYNC_DEPTH INTEGER 2
set_parameter_property SYNC_DEPTH DEFAULT_VALUE 2
set_parameter_property SYNC_DEPTH DISPLAY_NAME {Synchronizer depth}
set_parameter_property SYNC_DEPTH UNITS None
set_parameter_property SYNC_DEPTH DISPLAY_HINT ""
set_parameter_property SYNC_DEPTH AFFECTS_GENERATION false
set_parameter_property SYNC_DEPTH HDL_PARAMETER true
set_parameter_property SYNC_DEPTH DESCRIPTION {Specifies the number of register stages the synchronizer uses to eliminate the propagation of metastable events.}

add_parameter RESET_REQUEST_PRESENT INTEGER 0
set_parameter_property RESET_REQUEST_PRESENT DEFAULT_VALUE 0
set_parameter_property RESET_REQUEST_PRESENT DISPLAY_NAME {Reset request logic enable}
set_parameter_property RESET_REQUEST_PRESENT UNITS None
set_parameter_property RESET_REQUEST_PRESENT DISPLAY_HINT "boolean"
set_parameter_property RESET_REQUEST_PRESENT AFFECTS_GENERATION false
set_parameter_property RESET_REQUEST_PRESENT HDL_PARAMETER true
set_parameter_property RESET_REQUEST_PRESENT DESCRIPTION {Selects if reset request logic is added to sequence reset entry. Only used if any periperal requires an early reset indication}

add_parameter RESET_REQ_WAIT_TIME INTEGER 0
set_parameter_property RESET_REQ_WAIT_TIME DEFAULT_VALUE 1
set_parameter_property RESET_REQ_WAIT_TIME ALLOWED_RANGES {1:50}
set_parameter_property RESET_REQ_WAIT_TIME DISPLAY_NAME {Reset request wait time}
set_parameter_property RESET_REQ_WAIT_TIME UNITS None
set_parameter_property RESET_REQ_WAIT_TIME DISPLAY_HINT ""
set_parameter_property RESET_REQ_WAIT_TIME AFFECTS_GENERATION false
set_parameter_property RESET_REQ_WAIT_TIME HDL_PARAMETER true
set_parameter_property RESET_REQ_WAIT_TIME DESCRIPTION {Defines the timing between assertion of reset_req to reset_out (min:1)}

add_parameter MIN_RST_ASSERTION_TIME INTEGER 0
set_parameter_property MIN_RST_ASSERTION_TIME DEFAULT_VALUE 3
set_parameter_property MIN_RST_ASSERTION_TIME DISPLAY_NAME {Minimum reset assertion time}
set_parameter_property MIN_RST_ASSERTION_TIME ALLOWED_RANGES {3:50}
set_parameter_property MIN_RST_ASSERTION_TIME UNITS None
set_parameter_property MIN_RST_ASSERTION_TIME DISPLAY_HINT ""
set_parameter_property MIN_RST_ASSERTION_TIME AFFECTS_GENERATION false
set_parameter_property MIN_RST_ASSERTION_TIME HDL_PARAMETER true
set_parameter_property MIN_RST_ASSERTION_TIME DESCRIPTION {Defines the minimum amount of clock to assert reset_out (min:3) }

add_parameter RESET_REQ_EARLY_DSRT_TIME INTEGER 0
set_parameter_property RESET_REQ_EARLY_DSRT_TIME DEFAULT_VALUE 1
set_parameter_property RESET_REQ_EARLY_DSRT_TIME ALLOWED_RANGES {0:50}
set_parameter_property RESET_REQ_EARLY_DSRT_TIME DISPLAY_NAME {Reset request deassert timing}
set_parameter_property RESET_REQ_EARLY_DSRT_TIME UNITS None
set_parameter_property RESET_REQ_EARLY_DSRT_TIME DISPLAY_HINT ""
set_parameter_property RESET_REQ_EARLY_DSRT_TIME AFFECTS_GENERATION false
set_parameter_property RESET_REQ_EARLY_DSRT_TIME HDL_PARAMETER true
set_parameter_property RESET_REQ_EARLY_DSRT_TIME DESCRIPTION {Defines the timing between deassertion of reset_req to reset_out}

for { set inp 0 } { $inp < 16 } { incr inp } {

add_parameter USE_RESET_REQUEST_IN${inp} INTEGER 0
set_parameter_property USE_RESET_REQUEST_IN${inp} DEFAULT_VALUE 0
set_parameter_property USE_RESET_REQUEST_IN${inp} DISPLAY_NAME "Enable reset_req for port reset_in$inp"
set_parameter_property USE_RESET_REQUEST_IN${inp} UNITS None
set_parameter_property USE_RESET_REQUEST_IN${inp} DISPLAY_HINT boolean
set_parameter_property USE_RESET_REQUEST_IN${inp} AFFECTS_GENERATION false
set_parameter_property USE_RESET_REQUEST_IN${inp} HDL_PARAMETER true
set_parameter_property USE_RESET_REQUEST_IN${inp} ALLOWED_RANGES "0:1"
set_parameter_property USE_RESET_REQUEST_IN${inp} DESCRIPTION {Set this if the reset_in interface has reset_req together with reset}
}

add_parameter USE_RESET_REQUEST_INPUT INTEGER 0
set_parameter_property USE_RESET_REQUEST_INPUT DEFAULT_VALUE 0
set_parameter_property USE_RESET_REQUEST_INPUT DISPLAY_NAME "Enable reset_req for reset_inputs"
set_parameter_property USE_RESET_REQUEST_INPUT DISPLAY_HINT boolean
set_parameter_property USE_RESET_REQUEST_INPUT ALLOWED_RANGES "0:1"
set_parameter_property USE_RESET_REQUEST_INPUT AFFECTS_GENERATION false
set_parameter_property USE_RESET_REQUEST_INPUT HDL_PARAMETER false
set_parameter_property USE_RESET_REQUEST_INPUT DESCRIPTION {Set this if any reset_in interface has reset_req together with the reset}

add_parameter ADAPT_RESET_REQUEST INTEGER 0
set_parameter_property ADAPT_RESET_REQUEST DEFAULT_VALUE 0
set_parameter_property ADAPT_RESET_REQUEST DISPLAY_NAME "Only adapt only reset request"
set_parameter_property ADAPT_RESET_REQUEST DISPLAY_HINT boolean
set_parameter_property ADAPT_RESET_REQUEST ALLOWED_RANGES "0:1"
set_parameter_property ADAPT_RESET_REQUEST AFFECTS_GENERATION false
set_parameter_property ADAPT_RESET_REQUEST HDL_PARAMETER true
set_parameter_property ADAPT_RESET_REQUEST DESCRIPTION {Set this if only reset request adaptation is required and no reset request generation is required. This used when all sources of reset request inputs are valid.}
set_parameter_property ADAPT_RESET_REQUEST DERIVED 1
set_parameter_property ADAPT_RESET_REQUEST VISIBLE 0

# | 
# +-----------------------------------

add_display_item "Reset request" RESET_REQUEST_PRESENT PARAMETER ""
add_display_item "Reset request Settings" RESET_REQ_WAIT_TIME PARAMETER ""
add_display_item "Reset request Settings" RESET_REQ_EARLY_DSRT_TIME PARAMETER ""
add_display_item "Reset request Settings" MIN_RST_ASSERTION_TIME PARAMETER ""

add_display_item "Reset request" "Reset request Settings" group
set_display_item_property "Reset request Settings" VISIBLE 0

add_display_item "Reset request Input" USE_RESET_REQUEST_INPUT PARAMETER ""
for { set inp 0 } { $inp < 16 } { incr inp } {
add_display_item "Reset request Input Setting" USE_RESET_REQUEST_IN${inp} PARAMETER ""
}
add_display_item "Reset request Input Setting" ADAPT_RESET_REQUEST PARAMETER ""

add_display_item "Reset request Input" "Reset request Input Setting" group
set_display_item_property "Reset request Input Setting" VISIBLE 0

# +-----------------------------------
# | input resets
# | 
for { set inp 0 } { $inp < 16 } { incr inp } {
    add_interface reset_in${inp} reset end
}

# +-----------------------------------
# | output reset
# | 
add_interface clk clock end
add_interface reset_out reset start

add_interface_port clk        clk       clk   Input 1
add_interface_port reset_out  reset_out reset Output 1
set_interface_property reset_out associatedClock "clk"

add_interface_port reset_out  reset_req reset_req Output 1

for { set inp 0 } { $inp < 16 } { incr inp } {
    add_interface_port reset_in${inp} reset_in${inp}     reset      Input 1
    add_interface_port reset_in${inp} reset_req_in${inp} reset_req  Input 1
}

# | 
# +-----------------------------------

proc elaborate {} {

    set num_inputs [ get_parameter_value NUM_RESET_INPUTS ]
    set reset_sync_edges [ get_parameter_value OUTPUT_RESET_SYNC_EDGES ]
    set use_reset_req_in [ get_parameter_value USE_RESET_REQUEST_INPUT ]
    set use_reset_req [ get_parameter_value RESET_REQUEST_PRESENT ]
    set reset_req_asrt [ get_parameter_value RESET_REQ_WAIT_TIME ]
    set reset_req_dsrt [ get_parameter_value RESET_REQ_EARLY_DSRT_TIME ]
    set reset_asrt_min [ get_parameter_value MIN_RST_ASSERTION_TIME ]

    set max_inputs 16

    set reset_req_in_cnt 0
    for { set in 0 } { $in < $max_inputs } { incr in } {
        if { $in < $num_inputs } {
            set_port_property reset_in${in} TERMINATION false
            set_interface_property reset_in${in} synchronousEdges NONE
            if { [get_parameter_value USE_RESET_REQUEST_IN$in] == 1 } {
                set_port_property reset_req_in${in} TERMINATION false
                incr reset_req_in_cnt
            } else {
                set_port_property reset_req_in${in} TERMINATION true
                set_port_property reset_req_in${in} TERMINATION_VALUE 0
            }
        } else {
            set_port_property reset_in${in} TERMINATION true
            set_port_property reset_in${in} TERMINATION_VALUE 0
            set_port_property reset_req_in${in} TERMINATION true
            set_port_property reset_req_in${in} TERMINATION_VALUE 0
        }

    }

    if { $reset_req_in_cnt == $num_inputs } {
        set_parameter_value ADAPT_RESET_REQUEST 1
    } else {
        set_parameter_value ADAPT_RESET_REQUEST 0
    }

    set_interface_property reset_out synchronousEdges $reset_sync_edges

    set assoc_reset_sinks ""
    for { set i 0 } { $i < $num_inputs } { incr i } {
      #append assoc_reset_sinks "reset_in${i},"
	  append assoc_reset_sinks "reset_in${i} "
    }
    set_interface_property reset_out associatedResetSinks $assoc_reset_sinks

    ## Keep reset_req output when
    ## - reset_req needs to be generated (RESET_REQUEST_PRESENT==1) or 
    ##   adapted (ADAPT_RESET_REQUEST==1)
    if { $use_reset_req == 0 } {
        if { [get_parameter_value ADAPT_RESET_REQUEST] == 0} {
            set_port_property reset_req termination true
        }
    }

    ## Error if
    ## - all reset inputs has reset request but RESET_REQUEST_PRESENT==1
    if { $use_reset_req == 1 } {
        if { $reset_req_in_cnt == $num_inputs } {
            send_message {error} "RESET_REQUEST_PRESENT should not be set when all inputs has reset_request inputs"
        }
    }

    ## Reset assertion minimum support now is 3
    if {$reset_asrt_min < 3} {
        send_message "error" "Reset assertion time needs to be set to a minimum value of 3."
    }

    ## Reset request generation requires a clock. Will not error out in hw.tcl in case user instantiates this component directly
    ## Qsys will error out if automation is required and the output requires reset_req generation, but its edge requirement is NONE.

    ######################
    ## Display settings 
    ######################
    set_display_item_property "Reset request Settings" VISIBLE $use_reset_req
    set_display_item_property "Reset request Input Setting" VISIBLE $use_reset_req_in

    if { $use_reset_req_in == 1} {
        for { set in 0 } { $in < $num_inputs } { incr in } {
            set_parameter_property USE_RESET_REQUEST_IN$in VISIBLE 1
        }
    } else {
        for { set in 0 } { $in < $num_inputs } { incr in } {
            set_parameter_property USE_RESET_REQUEST_IN$in VISIBLE 0
        }
    }
    for { set in $num_inputs } { $in < $max_inputs } { incr in } {
            set_parameter_property USE_RESET_REQUEST_IN$in VISIBLE 0
    }

    

}
