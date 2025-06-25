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
# | altera_reset_sequencer "Reset Sequencer" v1.0
# | 
# +-----------------------------------

# +-----------------------------------
# | request TCL package 
# | 
package require -exact qsys 13.1
# | 
# +-----------------------------------

# +-----------------------------------
# | module altera_reset_sequencer
# | 
set_module_property NAME altera_reset_sequencer
set_module_property VERSION 13.1
set_module_property GROUP "Clock and Reset"
set_module_property DISPLAY_NAME "Reset Sequencer"
set_module_property DESCRIPTION "Based on the input reset, controls the reset assertion and de-assertion sequence based on component parameterization"
set_module_property AUTHOR "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ELABORATION_CALLBACK elaborate
set_module_property HIDE_FROM_SOPC false
set_module_property HIDE_FROM_QSYS false
set_module_property ANALYZE_HDL FALSE
set_module_property DATASHEET_URL http://www.altera.com/literature/hb/qts/qsys_interconnect.pdf
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 

set my_sequencer_filelist [ list    altera_reset_sequencer.sv \
                                    altera_reset_sequencer_main.sv \
                                    altera_reset_sequencer_seq.sv \
                                    altera_reset_sequencer_deglitch.sv \
                                    altera_reset_sequencer_deglitch_main.sv \
                                    altera_reset_sequencer_dlycntr.sv \
                                    altera_reset_sequencer_av_csr.sv ]
set my_sequencer_rstctrlr_filelist [ list   altera_reset_controller.v \
                                            altera_reset_synchronizer.v ]

add_fileset          synthesis_fileset  QUARTUS_SYNTH   synth_callback_procedure
set_fileset_property synthesis_fileset  TOP_LEVEL       altera_reset_sequencer 

add_fileset          simulation_fileset SIM_VERILOG     synth_callback_procedure
set_fileset_property simulation_fileset TOP_LEVEL       altera_reset_sequencer

add_fileset          vhdl_fileset       SIM_VHDL        synth_callback_procedure_vhdl
set_fileset_property vhdl_fileset       TOP_LEVEL       altera_reset_sequencer

proc synth_callback_procedure { entity_name } {
    global my_sequencer_filelist
    global my_sequencer_rstctrlr_filelist

    foreach myfile $my_sequencer_filelist {
        add_fileset_file $myfile SYSTEM_VERILOG PATH "$myfile"
    }
    foreach myfile $my_sequencer_rstctrlr_filelist {
        add_fileset_file $myfile SYSTEM_VERILOG PATH "../altera_reset_controller/$myfile"
    }

}

proc synth_callback_procedure_vhdl { entity_name } {
   global my_sequencer_filelist
   global my_sequencer_rstctrlr_filelist

   if {1} {
    foreach myfile $my_sequencer_filelist {
     add_fileset_file mentor/$myfile SYSTEM_VERILOG_ENCRYPT PATH "mentor/$myfile" {MENTOR_SPECIFIC}
    }
    foreach myfile $my_sequencer_rstctrlr_filelist {
     add_fileset_file mentor/$myfile SYSTEM_VERILOG_ENCRYPT PATH "../altera_reset_controller/mentor/$myfile" {MENTOR_SPECIFIC}
    }
   }
   if {1} {
    foreach myfile $my_sequencer_filelist {
     add_fileset_file aldec/$myfile SYSTEM_VERILOG_ENCRYPT PATH "aldec/$myfile" {ALDEC_SPECIFIC}
    }
    foreach myfile $my_sequencer_rstctrlr_filelist {
     add_fileset_file aldec/$myfile SYSTEM_VERILOG_ENCRYPT PATH "../altera_reset_controller/aldec/$myfile" {ALDEC_SPECIFIC}
    }
   }
   if {0} {
    foreach myfile $my_sequencer_filelist {
     add_fileset_file cadence/$myfile SYSTEM_VERILOG_ENCRYPT PATH "cadence/$myfile" {CADENCE_SPECIFIC}
    }
    foreach myfile $my_sequencer_rstctrlr_filelist {
     add_fileset_file cadence/$myfile SYSTEM_VERILOG_ENCRYPT PATH "../altera_reset_controller/cadence/$myfile" {CADENCE_SPECIFIC}
    }
   }
   if {0} {
    foreach myfile $my_sequencer_filelist {
     add_fileset_file synopsys/$myfile SYSTEM_VERILOG_ENCRYPT PATH "synopsys/$myfile" {SYNOPSYS_SPECIFIC}
    }
    foreach myfile $my_sequencer_rstctrlr_filelist {
     add_fileset_file synopsys/$myfile SYSTEM_VERILOG_ENCRYPT PATH "../altera_reset_controller/synopsys/$myfile" {SYNOPSYS_SPECIFIC}
    }
   }    
}

# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 

##
## HDL Parameters
##
add_parameter NUM_OUTPUTS INTEGER 3
set_parameter_property NUM_OUTPUTS DEFAULT_VALUE 3
set_parameter_property NUM_OUTPUTS DISPLAY_NAME {Number of reset outputs}
set_parameter_property NUM_OUTPUTS UNITS None
set_parameter_property NUM_OUTPUTS DISPLAY_HINT ""
set_parameter_property NUM_OUTPUTS AFFECTS_GENERATION false
set_parameter_property NUM_OUTPUTS HDL_PARAMETER true
set_parameter_property NUM_OUTPUTS ALLOWED_RANGES "2:10"
set_parameter_property NUM_OUTPUTS DESCRIPTION {Number of output reset to be controlled. (Minimum 2 outputs)}

add_parameter NUM_INPUTS INTEGER 3
set_parameter_property NUM_INPUTS DEFAULT_VALUE 3
set_parameter_property NUM_INPUTS DISPLAY_NAME {Number of reset inputs}
set_parameter_property NUM_INPUTS UNITS None
set_parameter_property NUM_INPUTS DISPLAY_HINT ""
set_parameter_property NUM_INPUTS AFFECTS_GENERATION false
set_parameter_property NUM_INPUTS HDL_PARAMETER false
set_parameter_property NUM_INPUTS ALLOWED_RANGES "1:10"
set_parameter_property NUM_INPUTS DESCRIPTION {Number of input reset to be tied to this sequencer}

add_parameter ENABLE_RESET_REQUEST_INPUT INTEGER 0
set_parameter_property ENABLE_RESET_REQUEST_INPUT DEFAULT_VALUE 0
set_parameter_property ENABLE_RESET_REQUEST_INPUT DISPLAY_NAME {Enable reset request as input to sequencer}
set_parameter_property ENABLE_RESET_REQUEST_INPUT UNITS None
set_parameter_property ENABLE_RESET_REQUEST_INPUT DISPLAY_HINT boolean
set_parameter_property ENABLE_RESET_REQUEST_INPUT AFFECTS_GENERATION false
set_parameter_property ENABLE_RESET_REQUEST_INPUT HDL_PARAMETER false
set_parameter_property ENABLE_RESET_REQUEST_INPUT ALLOWED_RANGES "0:1"
set_parameter_property ENABLE_RESET_REQUEST_INPUT DESCRIPTION {Enables reset request to be in input of sequencer. Reset request will be passthrough to outputs. If more than one reset input has reset request, it will be OR'ed together and send to all outputs}
set_parameter_property ENABLE_RESET_REQUEST_INPUT VISIBLE 0

add_parameter ENABLE_DEASSERTION_INPUT_QUAL INTEGER 0
set_parameter_property ENABLE_DEASSERTION_INPUT_QUAL DEFAULT_VALUE 0
set_parameter_property ENABLE_DEASSERTION_INPUT_QUAL DISPLAY_NAME {Bit-wise enable for input signal qualification}
set_parameter_property ENABLE_DEASSERTION_INPUT_QUAL UNITS None
set_parameter_property ENABLE_DEASSERTION_INPUT_QUAL DISPLAY_HINT ""
set_parameter_property ENABLE_DEASSERTION_INPUT_QUAL AFFECTS_GENERATION false
set_parameter_property ENABLE_DEASSERTION_INPUT_QUAL HDL_PARAMETER true
set_parameter_property ENABLE_DEASSERTION_INPUT_QUAL ALLOWED_RANGES "0:1023"
set_parameter_property ENABLE_DEASSERTION_INPUT_QUAL DERIVED 1
set_parameter_property ENABLE_DEASSERTION_INPUT_QUAL VISIBLE 0
set_parameter_property ENABLE_DEASSERTION_INPUT_QUAL DESCRIPTION {Enables signal input qualification during reset assertion sequencing}

add_parameter ENABLE_ASSERTION_SEQUENCE INTEGER 0
set_parameter_property ENABLE_ASSERTION_SEQUENCE DEFAULT_VALUE 0
set_parameter_property ENABLE_ASSERTION_SEQUENCE DISPLAY_NAME {Enable reset assertion sequence}
set_parameter_property ENABLE_ASSERTION_SEQUENCE UNITS None
set_parameter_property ENABLE_ASSERTION_SEQUENCE DISPLAY_HINT boolean
set_parameter_property ENABLE_ASSERTION_SEQUENCE AFFECTS_GENERATION false
set_parameter_property ENABLE_ASSERTION_SEQUENCE HDL_PARAMETER true
set_parameter_property ENABLE_ASSERTION_SEQUENCE ALLOWED_RANGES "0:1"
set_parameter_property ENABLE_ASSERTION_SEQUENCE DESCRIPTION {Enable/Disables the reset assertion sequencing}
set_parameter_property ENABLE_ASSERTION_SEQUENCE DERIVED 1
set_parameter_property ENABLE_ASSERTION_SEQUENCE VISIBLE 0

add_parameter ENABLE_DEASSERTION_SEQUENCE INTEGER 0
set_parameter_property ENABLE_DEASSERTION_SEQUENCE DEFAULT_VALUE 0
set_parameter_property ENABLE_DEASSERTION_SEQUENCE DISPLAY_NAME {Enable reset de-assertion sequence}
set_parameter_property ENABLE_DEASSERTION_SEQUENCE UNITS None
set_parameter_property ENABLE_DEASSERTION_SEQUENCE DISPLAY_HINT boolean
set_parameter_property ENABLE_DEASSERTION_SEQUENCE AFFECTS_GENERATION false
set_parameter_property ENABLE_DEASSERTION_SEQUENCE HDL_PARAMETER true
set_parameter_property ENABLE_DEASSERTION_SEQUENCE ALLOWED_RANGES "0:1"
set_parameter_property ENABLE_DEASSERTION_SEQUENCE DESCRIPTION {Enable/Disables the reset de-assertion sequencing}
set_parameter_property ENABLE_DEASSERTION_SEQUENCE DERIVED 1
set_parameter_property ENABLE_DEASSERTION_SEQUENCE VISIBLE 0

add_parameter MIN_ASRT_TIME INTEGER 0
set_parameter_property MIN_ASRT_TIME DEFAULT_VALUE 0
set_parameter_property MIN_ASRT_TIME DISPLAY_NAME {Minimum reset assertion time}
set_parameter_property MIN_ASRT_TIME UNITS None
set_parameter_property MIN_ASRT_TIME DISPLAY_HINT ""
set_parameter_property MIN_ASRT_TIME AFFECTS_GENERATION false
set_parameter_property MIN_ASRT_TIME HDL_PARAMETER true
set_parameter_property MIN_ASRT_TIME ALLOWED_RANGES "0:1023"
set_parameter_property MIN_ASRT_TIME DESCRIPTION {Defines the number of minimum cycles of reset assertion}

for { set out 0 } { $out < 10 } { incr out } {
set out_minus_1 "_in"
if { $out > 0} { set out_minus_1 [ expr $out - 1 ] }

add_parameter ASRT_DELAY${out} INTEGER 0
set_parameter_property ASRT_DELAY${out}  DEFAULT_VALUE 0
set_parameter_property ASRT_DELAY${out}  DISPLAY_NAME "Assertion Delay between reset$out_minus_1 to reset$out"
set_parameter_property ASRT_DELAY${out}  UNITS None
set_parameter_property ASRT_DELAY${out}  DISPLAY_HINT ""
set_parameter_property ASRT_DELAY${out}  AFFECTS_GENERATION false
set_parameter_property ASRT_DELAY${out}  HDL_PARAMETER true
set_parameter_property ASRT_DELAY${out}  ALLOWED_RANGES "0:1024"
set_parameter_property ASRT_DELAY${out}  DESCRIPTION "Number of cycles of delay between assertion of reset${out_minus_1} to reset_out${out}. Value of 0 indicates immediate assertion between the 2 resets"
set_parameter_property ASRT_DELAY${out}  DERIVED 1
set_parameter_property ASRT_DELAY${out}  VISIBLE 0

add_parameter DSRT_DELAY${out} INTEGER 0
set_parameter_property DSRT_DELAY${out}  DEFAULT_VALUE 0
set_parameter_property DSRT_DELAY${out}  DISPLAY_NAME "De-assertion Delay between reset$out_minus_1 to reset$out"
set_parameter_property DSRT_DELAY${out}  UNITS None
set_parameter_property DSRT_DELAY${out}  DISPLAY_HINT ""
set_parameter_property DSRT_DELAY${out}  AFFECTS_GENERATION false
set_parameter_property DSRT_DELAY${out}  HDL_PARAMETER true
set_parameter_property DSRT_DELAY${out}  ALLOWED_RANGES "0:1024"
set_parameter_property DSRT_DELAY${out}  DESCRIPTION "Number of cycles of delay between de-assertion of reset${out_minus_1} to reset_out${out}. Value of 0 indicates immediate assertion between the 2 resets."
set_parameter_property DSRT_DELAY${out}  DERIVED 1
set_parameter_property DSRT_DELAY${out}  VISIBLE 0

add_parameter ASRT_REMAP${out} INTEGER 3
set_parameter_property ASRT_REMAP${out} DEFAULT_VALUE $out
set_parameter_property ASRT_REMAP${out} DISPLAY_NAME "reset_out$out assert sequence #"
set_parameter_property ASRT_REMAP${out} UNITS None
set_parameter_property ASRT_REMAP${out} DISPLAY_HINT ""
set_parameter_property ASRT_REMAP${out} AFFECTS_GENERATION false
set_parameter_property ASRT_REMAP${out} HDL_PARAMETER true
set_parameter_property ASRT_REMAP${out} ALLOWED_RANGES "0:9"
set_parameter_property ASRT_REMAP${out} DESCRIPTION "Number assigned defines the order in which the reset is de-asserted"
set_parameter_property ASRT_REMAP${out}  DERIVED 1
set_parameter_property ASRT_REMAP${out}  VISIBLE 0

add_parameter DSRT_REMAP${out} INTEGER 3
set_parameter_property DSRT_REMAP${out} DEFAULT_VALUE $out
set_parameter_property DSRT_REMAP${out} DISPLAY_NAME "reset_out$out de-assert sequence #"
set_parameter_property DSRT_REMAP${out} UNITS None
set_parameter_property DSRT_REMAP${out} DISPLAY_HINT ""
set_parameter_property DSRT_REMAP${out} AFFECTS_GENERATION false
set_parameter_property DSRT_REMAP${out} HDL_PARAMETER true
set_parameter_property DSRT_REMAP${out} ALLOWED_RANGES "0:9"
set_parameter_property DSRT_REMAP${out} DESCRIPTION "Number assigned defines the order in which the reset is de-asserted"
set_parameter_property DSRT_REMAP${out}  DERIVED 1
set_parameter_property DSRT_REMAP${out}  VISIBLE 0

add_parameter DSRT_QUALCNT_${out} INTEGER 0
set_parameter_property DSRT_QUALCNT_${out} DEFAULT_VALUE 0
set_parameter_property DSRT_QUALCNT_${out} DISPLAY_NAME "Deglitch count for de-assertion of reset$out\_drst_qual"
set_parameter_property DSRT_QUALCNT_${out} UNITS None
set_parameter_property DSRT_QUALCNT_${out} DISPLAY_HINT ""
set_parameter_property DSRT_QUALCNT_${out} AFFECTS_GENERATION false
set_parameter_property DSRT_QUALCNT_${out} HDL_PARAMETER true
set_parameter_property DSRT_QUALCNT_${out} ALLOWED_RANGES "0:1024"
set_parameter_property DSRT_QUALCNT_${out} DESCRIPTION "Use for deglitching input signals used as qualification for reset sequencing. Value of zero indicates no deglitching is required"
set_parameter_property DSRT_QUALCNT_${out} DERIVED 1
set_parameter_property DSRT_QUALCNT_${out} VISIBLE 0

}

add_parameter ENABLE_CSR INTEGER 1
set_parameter_property ENABLE_CSR DEFAULT_VALUE 0
set_parameter_property ENABLE_CSR DISPLAY_NAME "Enable Reset Sequencer CSR"
set_parameter_property ENABLE_CSR TYPE INTEGER
set_parameter_property ENABLE_CSR UNITS None
set_parameter_property ENABLE_CSR DESCRIPTION "Controls whether a CSR register will be instantiated with this block. Register contains reset logging, s
oftware control of reset triggering, masking and forcing of resets."
set_parameter_property ENABLE_CSR AFFECTS_ELABORATION true
set_parameter_property ENABLE_CSR HDL_PARAMETER true
set_parameter_property ENABLE_CSR DISPLAY_HINT "boolean"

##
## TABLE PARAMETERS
##
add_parameter RESET_OUT_NAME STRING_LIST
set_parameter_property RESET_OUT_NAME DISPLAY_NAME "reset_out#"
set_parameter_property RESET_OUT_NAME AFFECTS_ELABORATION true
set_parameter_property RESET_OUT_NAME HDL_PARAMETER false
set_parameter_property RESET_OUT_NAME DERIVED true
set_parameter_property RESET_OUT_NAME DISPLAY_HINT FIXED_SIZE

add_parameter LIST_ASRT_SEQ STRING_LIST { 0 1 2 3 4 5 6 7 8 9 }
set_parameter_property LIST_ASRT_SEQ DISPLAY_NAME "ASRT Seq#"
set_parameter_property LIST_ASRT_SEQ DESCRIPTION "Assertion Sequence Number"
set_parameter_property LIST_ASRT_SEQ AFFECTS_ELABORATION true
set_parameter_property LIST_ASRT_SEQ HDL_PARAMETER false
set_parameter_property LIST_ASRT_SEQ DISPLAY_HINT FIXED_SIZE
set_parameter_property LIST_ASRT_SEQ DISPLAY_HINT WIDTH:100

add_parameter LIST_DSRT_SEQ STRING_LIST { 0 1 2 3 4 5 6 7 8 9 }
set_parameter_property LIST_DSRT_SEQ DISPLAY_NAME "DSRT Seq #"
set_parameter_property LIST_DSRT_SEQ DESCRIPTION "Deassertion Sequencer Number"
set_parameter_property LIST_DSRT_SEQ AFFECTS_ELABORATION true
set_parameter_property LIST_DSRT_SEQ HDL_PARAMETER false
set_parameter_property LIST_DSRT_SEQ DISPLAY_HINT FIXED_SIZE
set_parameter_property LIST_DSRT_SEQ DISPLAY_HINT WIDTH:100

add_parameter LIST_ASRT_DELAY STRING_LIST { 0 0 0 0 0 0 0 0 0 0}
set_parameter_property LIST_ASRT_DELAY DISPLAY_NAME "ASRT Cycle#"
set_parameter_property LIST_ASRT_DELAY DESCRIPTION "This reflects the assertion cycle delay between resets"
set_parameter_property LIST_ASRT_DELAY AFFECTS_ELABORATION true
set_parameter_property LIST_ASRT_DELAY HDL_PARAMETER false
set_parameter_property LIST_ASRT_DELAY DISPLAY_HINT FIXED_SIZE
set_parameter_property LIST_ASRT_DELAY DISPLAY_HINT WIDTH:100

add_parameter LIST_DSRT_DELAY STRING_LIST { 0 0 0 0 0 0 0 0 0 0 }
set_parameter_property LIST_DSRT_DELAY DISPLAY_NAME "DSRT Cycle# / Deglitch#"
set_parameter_property LIST_DSRT_DELAY DESCRIPTION "This reflects the deassertion cycle delay OR the deglitch count, depending on the USE_DSRT_QUAL value"
set_parameter_property LIST_DSRT_DELAY AFFECTS_ELABORATION true
set_parameter_property LIST_DSRT_DELAY HDL_PARAMETER false
set_parameter_property LIST_DSRT_DELAY DISPLAY_HINT FIXED_SIZE
set_parameter_property LIST_DSRT_DELAY DISPLAY_HINT WIDTH:200

add_parameter USE_DSRT_QUAL INTEGER_LIST { 0 0 0 0 0 0 0 0 0 0 }
set_parameter_property USE_DSRT_QUAL DISPLAY_NAME "USE_DSRT_QUAL"
set_parameter_property USE_DSRT_QUAL DESCRIPTION "Selects whether input signal is used to qualify assertion. WHen set, the DELAY is not used."
set_parameter_property USE_DSRT_QUAL AFFECTS_ELABORATION true
set_parameter_property USE_DSRT_QUAL HDL_PARAMETER false
set_parameter_property USE_DSRT_QUAL DISPLAY_HINT BOOLEAN
set_parameter_property USE_DSRT_QUAL DISPLAY_HINT FIXED_SIZE
set_parameter_property USE_DSRT_QUAL DISPLAY_HINT WIDTH:150

add_parameter ASRT_SEQ_MSG STRING
set_parameter_property ASRT_SEQ_MSG DISPLAY_NAME "Assertion Sequence"
set_parameter_property ASRT_SEQ_MSG AFFECTS_ELABORATION true
set_parameter_property ASRT_SEQ_MSG HDL_PARAMETER false
set_parameter_property ASRT_SEQ_MSG DISPLAY_HINT ROWS:3
set_parameter_property ASRT_SEQ_MSG DERIVED 1
#set_parameter_property ASRT_SEQ_MSG VISIBLE 0

add_parameter DSRT_SEQ_MSG STRING
set_parameter_property DSRT_SEQ_MSG DISPLAY_NAME "De-assertion Sequence"
set_parameter_property DSRT_SEQ_MSG AFFECTS_ELABORATION true
set_parameter_property DSRT_SEQ_MSG HDL_PARAMETER false
set_parameter_property DSRT_SEQ_MSG DISPLAY_HINT ROWS:3
set_parameter_property DSRT_SEQ_MSG DERIVED 1
#set_parameter_property DSRT_SEQ_MSG VISIBLE 0

# | 
# +-----------------------------------


# +-----------------------------------
# | display setting
# |
 
add_display_item "Sequencer Parameters" NUM_OUTPUTS PARAMETER ""
add_display_item "Sequencer Parameters" NUM_INPUTS PARAMETER ""
add_display_item "Sequencer Parameters" MIN_ASRT_TIME PARAMETER ""
add_display_item "Sequencer Parameters" ENABLE_CSR PARAMETER ""

add_display_item "Sequence Setup" id0 text "- ASRT Cycle# - Number of cycles after assertion of previous reset"
add_display_item "Sequence Setup" id1 text "- DSRT Cycle# - Number of cycles after deassertion of previous reset"
add_display_item "Sequence Setup" id2 text "- When USE_DSRT_QUAL==1. DSRT Cycle# refers to the # of cycles to deglitch the input qual signal"
add_display_item "Sequence Setup" myTable GROUP TABLE
add_display_item myTable RESET_OUT_NAME PARAMETER
add_display_item myTable LIST_ASRT_SEQ PARAMETER ""
add_display_item myTable LIST_ASRT_DELAY PARAMETER ""
add_display_item myTable LIST_DSRT_SEQ PARAMETER ""
add_display_item myTable LIST_DSRT_DELAY PARAMETER
add_display_item myTable USE_DSRT_QUAL PARAMETER ""


add_display_item "Sequence Setup" ASRT_SEQ_MSG PARAMETER ""
add_display_item "Sequence Setup" DSRT_SEQ_MSG PARAMETER ""
add_display_item "Sequence Setup" id3 text "Please check below for expected generated sequence"

# |
# +-----------------------------------

# +-----------------------------------
# | inputs
# | 

add_interface       clk clock end
add_interface_port  clk clk   clk Input 1

#add_interface           reset reset end
#add_interface_port      reset reset reset Input 1
#set_interface_property  reset synchronousEdges "deassert"
#set_interface_property  reset associatedClock "clk"

for { set num 0 } { $num < 10 } { incr num } {
    add_interface           reset_in${num}    reset end
    add_interface_port      reset_in${num}    reset_in${num} reset Input 1
    set_interface_property  reset_in${num}    synchronousEdges "none"
    add_interface_port      reset_in${num}    reset_req_in${num} reset_req Input 1
    set_port_property       reset_in${num}    TERMINATION true
}

# +-----------------------------------
# | output reset
# | 

# Reset outputs
for { set out 0 } { $out < 10 } { incr out } {

    add_interface reset_out${out} reset start
    set_interface_property  reset_out${out}  associatedClock "clk"
    set_interface_property  reset_out${out}  synchronousEdges "both"
    add_interface_port      reset_out${out}  reset_out${out} reset Output 1
    add_interface_port      reset_out${out}  reset_req_out${out} reset_req Output 1
    set_port_property       reset_out${out}  TERMINATION true
}

for { set in 0 } { $in < 10 } { incr in } {

    # Signal qualications
    add_interface       reset${in}_dsrt_qual conduit end
    add_interface_port  reset${in}_dsrt_qual reset${in}_dsrt_qual reset_dsrt_qual Input 1
    set_port_property   reset${in}_dsrt_qual TERMINATION true

}


# | 
# +-----------------------------------

proc elaborate {} {

    set num_outputs     [ get_parameter_value NUM_OUTPUTS ]
    set num_inputs      [ get_parameter_value NUM_INPUTS ]
    set use_reset_req   [ get_parameter_value ENABLE_RESET_REQUEST_INPUT ]
    set csr_en          [ get_parameter_value ENABLE_CSR ]

    set use_dsrt_qual   [ get_parameter_value USE_DSRT_QUAL ]
    set my_aseq        [ get_parameter_value LIST_ASRT_SEQ ]
    set my_asrt_dly    [ get_parameter_value LIST_ASRT_DELAY ]
    set my_dseq        [ get_parameter_value LIST_DSRT_SEQ ]
    set my_dsrt_dly    [ get_parameter_value LIST_DSRT_DELAY ]

    ## FIX UI reset_out name and #
    set reset_out_list ""
    for { set out 0 } { $out < $num_outputs } { incr out } {   
        lappend reset_out_list "reset_out$out"
    }    
    set_parameter_value RESET_OUT_NAME $reset_out_list

    set max_outputs 10
    set max_inputs 10

    set_display_item_property myTable DISPLAY_HINT ROWS:$num_outputs
    set_display_item_property myTable DISPLAY_HINT COLUMNS:$num_outputs

    ##
    ## Reset output settings
    ##
    set assoc_reset_sinks ""
    for { set num 0 } { $num < $num_inputs } { incr num } {
        append assoc_reset_sinks "reset_in${num} "
    }

    for { set out 0 } { $out < $max_outputs } { incr out } {
        if { $out < $num_outputs } {
            set_interface_property  reset_out${out}  associatedResetSinks $assoc_reset_sinks
            set_port_property       reset_out${out}  TERMINATION false
            if { $use_reset_req } {
                set_port_property reset_req_out${out} TERMINATION false
            } else {
                set_port_property reset_req_out${out} TERMINATION true
            }
        } else {
            set_port_property reset_out${out} TERMINATION true
            set_port_property reset_req_out${out} TERMINATION true
        }
    }

    ##
    ## Reset input settings
    ##
    for { set num 0 } { $num < $max_inputs } { incr num } {
        if { $num < $num_inputs } {
            set_port_property       reset_in${num} TERMINATION      false
            if {$use_reset_req == 1} {
                set_port_property reset_req_in${num} TERMINATION false
            } else {
                set_port_property reset_req_in${num} TERMINATION true
            }
        } else {
            set_port_property reset_in${num} TERMINATION true
            set_port_property reset_req_in${num} TERMINATION true
        }
    }

    # Reset deassertion input qualification termination
    set i 0
    set hdl_dsrt_qual_in 0
    # default
    if { ! [llength ${use_dsrt_qual} ] } {
        for { set num 0 } { $num < $max_outputs } { incr num } {
            lappend use_dsrt_qual 0
        }
    }
    # set by user
    for { set num 0 } { $num < $num_outputs } { incr num } {
        set qual [ lindex $use_dsrt_qual $num ]
        if { $qual == 1} { 
            set_port_property reset${num}_dsrt_qual TERMINATION false
            set_port_property reset${num}_dsrt_qual ROLE reset${num}_dsrt_qual
            set hdl_dsrt_qual_in [ expr $hdl_dsrt_qual_in | [ expr 1 << $num ] ]
        } else {
            set_port_property reset${num}_dsrt_qual TERMINATION true
        }
    }
    
    set_parameter_value  ENABLE_DEASSERTION_INPUT_QUAL $hdl_dsrt_qual_in

    ## Dummy set all to zero by default
    for { set num 0 } { $num < $max_outputs } { incr num } { 
        set_parameter_value ASRT_DELAY$num 0
        set_parameter_value DSRT_DELAY$num 0
        set_parameter_value DSRT_QUALCNT_$num 0
        set_parameter_value ASRT_REMAP$num $num
        set_parameter_value DSRT_REMAP$num $num
    }
    
    ##
    ## Assertion delays
    ## - sort the delays based on value smallest to biggest
    ##   - this will tell the ASRT_REMAP criteria
    ##   - this will also tell the delay# between resets
    ##
    set chk_asrt 0
    
    ## default
    if { ! [llength ${my_asrt_dly} ] } {
        for { set num 0 } { $num < $num_outputs } { incr num } {
            lappend my_asrt_dly "0"
        }
    }
    if { ! [llength ${my_aseq} ] } {
        for { set num 0 } { $num < $num_outputs } { incr num } {
            lappend my_aseq $num
        }
    }

    ## user
    for { set num 0 } { $num < $num_outputs } { incr num } {
        set seq      [ lindex $my_aseq $num ]
        set asrt_dly [ lindex $my_asrt_dly $num ]
        if { $asrt_dly == "" } {
            set asrt_dly 0 
        }
        if { $seq == "" } {
            set seq $num
        }
        if { $asrt_dly != 0 } { set chk_asrt 1 }
        set_parameter_value ASRT_REMAP$num $seq
        set_parameter_value ASRT_DELAY$seq $asrt_dly
    }
    ## check valid asrt seq num
    set asrt_seq_num_chk_list [lsort $my_aseq] 
    set asrt_prev 0
    for { set num 0 } { $num < $num_outputs } { incr num } {       
        if { [lindex $my_aseq $num ] > $num_outputs } {
            send_message {error} "Sequencer # set to more than number of outputs"
        }
        set temp [lindex $asrt_seq_num_chk_list $num]
        if { $num == 0 } { 
            set asrt_prev [lindex $asrt_seq_num_chk_list $num] 
        } else { 
            set asrt_now [ lindex $asrt_seq_num_chk_list $num ]
            if { $asrt_prev == $asrt_now } { 
                send_message {error} "Duplicate Sequence#. Set DELAY=0 for resets that assert together"
            }
            set asrt_prev $asrt_now
        }
    }

    set_parameter_value ENABLE_ASSERTION_SEQUENCE $chk_asrt

    ##
    ## De-assertion delays
    ##
    set chk_dsrt 0

    ## default
    if { ! [llength ${my_dsrt_dly} ] } {
        for { set num 0 } { $num < $num_outputs } { incr num } {
            lappend my_dsrt_dly "0"
        }
    }
    if { ! [llength ${my_dseq} ] } {
        for { set num 0 } { $num < $num_outputs } { incr num } {
            lappend my_dseq $num
        }
    }

    ## user
    for { set num 0 } { $num < $num_outputs } { incr num } {
        set seq      [ lindex $my_dseq $num ]
        if { $seq == "" } { set seq $num }
        set dsrt_dly [ lindex $my_dsrt_dly $num ]
        if { $dsrt_dly == "" }  { set dsrt_dly 0 }
        set qual     [ lindex $use_dsrt_qual $num ]
        if { $qual == "" }      { set qual 0 }        
        if { $dsrt_dly != 0 || $qual == 1 } { set chk_dsrt 1 }

        set_parameter_value DSRT_REMAP$num $seq
        if { $qual == 1 } {
            set_parameter_value DSRT_QUALCNT_$num $dsrt_dly
        } else {
            set_parameter_value DSRT_DELAY$seq $dsrt_dly
        }
    }
    ## chk dsrt
    set dsrt_seq_num_chk_list [lsort $my_dseq]
    set dsrt_prev 0
    for { set num 0 } { $num < $num_outputs } { incr num } {
        if { [lindex $my_dseq $num ] > $num_outputs } {
            send_message {error} "Sequencer # set to more than number of outputs"
        }
        set temp [lindex $dsrt_seq_num_chk_list $num]
        if { $num == 0 } {
            set dsrt_prev [lindex $dsrt_seq_num_chk_list $num]
        } else {
            set dsrt_now [ lindex $dsrt_seq_num_chk_list $num ]
            if { $dsrt_prev == $dsrt_now } {
                send_message {error} "Duplicate Sequence#. Set DELAY=0 for resets that assert together"
            }
            set dsrt_prev $dsrt_now
        }
    }


    set_parameter_value ENABLE_DEASSERTION_SEQUENCE $chk_dsrt
    
    ## Deassertion sequence when DQUAL is set is complicated


    # CSR Settings
    if { $csr_en == 1 } {

    add_interface           csr_reset reset end
    add_interface_port      csr_reset csr_reset reset Input 1
    set_interface_property  csr_reset synchronousEdges "none"

    #Avalon CSR Slave Interface
    set register_av 1
    set read_latency [ expr $register_av * 2 ]
    add_interface av_csr avalon end
    set_interface_property av_csr addressAlignment DYNAMIC
    set_interface_property av_csr bridgesToMaster ""
    set_interface_property av_csr burstOnBurstBoundariesOnly false
    set_interface_property av_csr holdTime 0
    set_interface_property av_csr isMemoryDevice false
    set_interface_property av_csr isNonVolatileStorage false
    set_interface_property av_csr linewrapBursts false
    set_interface_property av_csr maximumPendingReadTransactions 0
    set_interface_property av_csr minimumUninterruptedRunLength 1
    set_interface_property av_csr printableDevice false
    set_interface_property av_csr readLatency $read_latency
    set_interface_property av_csr readWaitTime 0
    set_interface_property av_csr setupTime 0
    set_interface_property av_csr timingUnits Cycles
    set_interface_property av_csr writeWaitTime 0
    set_interface_property av_csr constantBurstBehavior false
    set_interface_property av_csr burstcountUnits SYMBOLS
    set_interface_property av_csr addressUnits SYMBOLS
    set_interface_property av_csr associatedClock   clk
    set_interface_property av_csr associatedReset   csr_reset
    add_interface_port av_csr av_address       address     Input   8
    add_interface_port av_csr av_readdata      readdata    Output  32
    add_interface_port av_csr av_read          read        Input   1
    add_interface_port av_csr av_writedata     writedata   Input   32
    add_interface_port av_csr av_write         write       Input   1
        add_interface           av_csr_irq interrupt sender 
        set_interface_property  av_csr_irq associatedAddressablePoint av_csr
        set_interface_property  av_csr_irq associatedClock clk
        set_interface_property  av_csr_irq associatedReset csr_reset
        add_interface_port      av_csr_irq irq irq Output 1
    }

    ## DEBUG
    set debug 1
    if {$debug == 1} {
    for { set num 0 } { $num < $num_outputs } { incr num } {
        set a [ get_parameter_value ASRT_DELAY$num ]
        send_message {info} "ASRT_DELAY$num = $a"
    }
    for { set num 0 } { $num < $num_outputs } { incr num } {
        set a [ get_parameter_value ASRT_REMAP$num ]
        send_message {info} "ASRT_REMAP$num = $a"
    }
    for { set num 0 } { $num < $num_outputs } { incr num } {
        set a [ get_parameter_value DSRT_DELAY$num ]
        send_message {info} "DSRT_DELAY$num = $a"
    }
    for { set num 0 } { $num < $num_outputs } { incr num } {
        set a [ get_parameter_value DSRT_REMAP$num ]
        send_message {info} "DSRT_REMAP$num = $a"
    }
    for { set num 0 } { $num < $num_outputs } { incr num } {
        set a [ get_parameter_value DSRT_QUALCNT_$num ]
        send_message {info} "DSRT_QUALCNT_$num = $a"
    }
        set a [ get_parameter_value ENABLE_ASSERTION_SEQUENCE ]
        send_message {info} "ENABLE_ASSERTION_SEQUENCE = $a"
        set a [ get_parameter_value ENABLE_DEASSERTION_SEQUENCE ]
        send_message {info} "ENABLE_DEASSERTION_SEQUENCE = $a"
        set a [ get_parameter_value ENABLE_DEASSERTION_INPUT_QUAL ]
        send_message {info} "ENABLE_DEASSERTION_INPUT_QUAL = $a"
    }


    ##
    ## This section is to re-iterate the final sequence to user
    ##
    lappend asrt_seq "reset_in_asserted->"
    for { set num 0 } { $num < $num_outputs } { incr num } {
        for { set find 0 } { $find < $num_outputs } { incr find } {
            if { [get_parameter_value ASRT_REMAP$find ] == $num } {
                set a $find
            }
        }
        #set a [ get_parameter_value ASRT_REMAP$a ]
        set b [ get_parameter_value ASRT_DELAY$num ]
        if {$b == 0} { 
            if {$num > 0} {
                lappend asrt_seq "+" 
            }
        } else { 
            if {$num > 0} {
                lappend asrt_seq "->"
            }
            lappend asrt_seq "#$b->"
        }
        lappend asrt_seq "reset_out$a"
    }
    if { ![get_parameter_value ENABLE_ASSERTION_SEQUENCE] } {
        set_parameter_value ASRT_SEQ_MSG "DISABLED"
        #send_message {info} "Assertion Sequence is DISABLED"
    } else {
        set_parameter_value ASRT_SEQ_MSG "$asrt_seq"
        #send_message {info} "Assertion Sequence is :\n$asrt_seq"
    }

    lappend dsrt_seq "reset_in_deasserted->"
    for { set num 0 } { $num < $num_outputs } { incr num } {
        for { set find 0 } { $find < $num_outputs } { incr find } {
            if { [get_parameter_value DSRT_REMAP$find ] == $num } {
                set a $find
            }
        }
        set b [ get_parameter_value DSRT_DELAY$num ]
        set c [ lindex $use_dsrt_qual $a ]
        if {$c == 1} { 
             lappend dsrt_seq "->wait_dqual$a->"
        } else {
             if {$b == 0} {
                if {$num > 0} {
                    lappend dsrt_seq "+"
                }
             } else {
                if {$num > 0} {
                    lappend dsrt_seq "->"
                }   
                lappend dsrt_seq "#$b->"
             }
        }
        lappend dsrt_seq "reset_out$a"
    }
    if { ![get_parameter_value ENABLE_DEASSERTION_SEQUENCE] } {
        set_parameter_value DSRT_SEQ_MSG "DISABLED"
    } else {
        set_parameter_value DSRT_SEQ_MSG "$dsrt_seq"
        #send_message {info} "Deassertion Sequence is :\n $dsrt_seq"
    }


}

