##Legal Notice: (C)2006 Altera Corporation. All rights reserved. Your
##use of Altera Corporation's design tools, logic functions and other
##software and tools, and its AMPP partner logic functions, and any
##output files any of the foregoing (including device programming or
##simulation files), and any associated documentation or information are
##expressly subject to the terms and conditions of the Altera Program
##License Subscription Agreement or other applicable license agreement,
##including, without limitation, that your use is for the sole purpose
##of programming logic devices manufactured by Altera and sold by Altera
##or its authorized distributors. Please refer to the applicable
##agreement for further details. 








package provide ::ddr::messages 0.1

namespace eval ::ddr::messages {
namespace export clkout_skew_too_big
namespace export get_tan_failed_message
namespace export back_annotation_successful
namespace export back_annotation_failed
namespace export back_annotation_no_file
namespace export found_wrong_number_of_pins
namespace export dqsfbc_not_setup_manually
namespace export dqsfbc_postamble_not_dedicated






proc clkout_skew_too_big { skew } {	return "TCO Skew between clock to SDRAM pins too high at ${skew}ps" 	}






proc get_tan_failed_message   {  } {
set res [list]
lappend res "  The most likely cause of this type of error is:"
lappend res "               (1) Some signals on the local-side interface are not connected causing logic to be optimised away,"
lappend res "                   This script requires that the complete logic for the specified width of the datapath (both read and write paths) be present in the design."
lappend res "               (2) The clear-text HDL files for the datapath may have been modified."
lappend res "               (3) Not all clocks from the system pll are global."
return  $res
}






proc back_annotation_successful { datafile } {
return "Successfully read back annotation file $datafile"
}






proc back_annotation_failed {back_ann_estdata err } {
return "Couldn't read back annotation data file ($back_ann_estdata) that was generated in previous compilation: $err"
}






proc back_annotation_no_file { back_ann_estdata } {
return "Backannotation file $back_ann_estdata doesn't exist"
}




#  report that the wrong number of some type of pin are found. Eg type="clock output" expected=2 found=0

proc found_wrong_number_of_pins { type expected actual } {
return "Post compile timing analysis expected to find $expected $type pins but found $actual."
}






proc dedicated_clkout_mode_warning {  } {
return "You must set up the dedicated clock outputs to meet memory timing parameters by modifying the PLL and top level."
}

proc found_no_datapath_pins {} {
return "Postcompile processing didn't find any datapath pins."
}

proc dqsfbc_not_setup_manually {} {
return "Resync and Postamble clocks must be set up manually. Please select the options 'Manual resynchronization control' and 'Manual postamble control' in the Manual Timings pane of the MegaWizard then regenerate and recompile the DDR/DDR2 SDRAM Controller core."
}
proc dqsfbc_postamble_not_dedicated {} {
return "This design doesn't have the Postamble clock set to 'dedicated'. Please change this in the Manual Timings pane of the MegaWizard then regenerate and recompile the DDR/DDR2 SDRAM Controller core."
}
}
