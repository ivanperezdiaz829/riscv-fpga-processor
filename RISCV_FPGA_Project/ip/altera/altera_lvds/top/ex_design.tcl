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


package provide altera_lvds::top::ex_design 0.1


namespace eval ::altera_lvds::top::ex_design:: {
   

   
}



proc ::altera_lvds::top::ex_design::example_design_fileset_callback {name} {

	set default_device "10AX115R3F40I3SGES"
    set synth_qsys_name "ed_synth"
    set synth_qsys_file "${synth_qsys_name}.qsys"
    set synth_qsys_path [create_temp_file $synth_qsys_file]
	set fh [open $synth_qsys_path "w"] 
	close $fh 
    
    set sim_qsys_name   "ed_sim"
    set sim_qsys_file   "${sim_qsys_name}.qsys"
    set sim_qsys_path   [create_temp_file $sim_qsys_file]
	set fh [open $sim_qsys_path "w"] 
	close $fh 
    
    
    set params_file "params.tcl"
    set params_path [create_temp_file $params_file]
    set fh [open $params_path "w"]    
    
    puts $fh "# This file is auto-generated."
    puts $fh "# It is used by make_qii_design.tcl and make_sim_design.tcl, and"
    puts $fh "# is not intended to be executed directly."
    puts $fh ""
 
    foreach param_name [get_parameters] {
       set param_val [get_parameter_value $param_name]
       puts $fh "set ip_params(${param_name}) \"${param_val}\""
    }
    
    puts $fh "set device_family  \"Arria 10\""
    puts $fh "set ed_params(ALTERA_LVDS_NAME)           \"$name\""
    puts $fh "set ed_params(DEFAULT_DEVICE)      \"$default_device\""
    puts $fh "set ed_params(SYNTH_QSYS_NAME)     \"$synth_qsys_name\""
    puts $fh "set ed_params(SIM_QSYS_NAME)       \"$sim_qsys_name\""
    puts $fh "set ed_params(TMP_SYNTH_QSYS_PATH) \"$synth_qsys_path\""
    puts $fh "set ed_params(TMP_SIM_QSYS_PATH)   \"$sim_qsys_path\""
    close $fh
    
    add_fileset_file $params_file OTHER PATH $params_path
 
    set cmd [concat [list exec qsys-script --cmd='source $params_path' --script=ex_design/make_qsys.tcl]]
    set cmd_fail [catch { eval $cmd } tempresult]
    add_fileset_file $synth_qsys_file OTHER PATH $synth_qsys_path
    add_fileset_file $sim_qsys_file OTHER PATH $sim_qsys_path
    
    set file "make_qii_design.tcl"
    set path "ex_design/${file}"
    add_fileset_file $file OTHER PATH $path
 
    set file "make_sim_design.tcl"
    set path "ex_design/${file}"
    add_fileset_file $file OTHER PATH $path
    
    set file "readme.txt"
    set path "ex_design/${file}"
    add_fileset_file $file OTHER PATH $path
}
 

proc ::altera_lvds::top::ex_design::_init {} {
}

::altera_lvds::top::ex_design::_init
