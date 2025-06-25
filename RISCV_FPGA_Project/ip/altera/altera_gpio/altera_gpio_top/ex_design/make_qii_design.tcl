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



proc error_and_exit {msg} {
   post_message -type error "SCRIPT_ABORTED!!!"
   foreach line [split $msg "\n"] {
      post_message -type error $line
   }
   qexit -error
}

proc show_usage_and_exit {argv0} {
   post_message -type error  "USAGE: $argv0 \[device_name\]"
   qexit -error
}

set argv0 "quartus_sh -t [info script]"
set args $quartus(args)

if {[llength $args] == 1 } {
   set force_device [string toupper [string trim [lindex $args 1]]]
} else {
   set force_device ""
}

if {[llength $args] > 1} {
   show_usage_and_exit $argv0
}

set script_path [file dirname [file normalize [info script]]]

source "$script_path/params.tcl"

set ex_design_path         "$script_path/qii"
set system_name            $ed_params(SYNTH_QSYS_NAME)
set qsys_file              "${system_name}.qsys"
set family                 $device_family

if {$force_device == ""} {
   set device $ed_params(DEFAULT_DEVICE)
} else {
   set device $force_device
}

puts "\n"
puts "*************************************************************************"
puts "Altera GPIO IP Example Design Builder                                    "
puts "                                                                         "
puts "Type  : Quartus II Project                                               "
puts "Family: $family                                                          "
puts "Device: $device                                                          "
puts "                                                                         "
puts "This script takes ~1 minute to execute...                                "
puts "*************************************************************************"
puts "\n"

if {[file isdirectory $ex_design_path]} {
   error_and_exit "Directory $ex_design_path already exists.\nThis script does not overwrite an existing directory.\nRemove the directory before re-running the script."
}

file mkdir $ex_design_path
file copy -force "${script_path}/$qsys_file" "${ex_design_path}/$qsys_file"

puts "Generating example design files..."
cd $ex_design_path
exec -ignorestderr ip-generate --file-set=QUARTUS_SYNTH --output-directory=. --report-file=qip $qsys_file >>& ip_generate.out

file delete -force ip_generate.out

puts "Creating Quartus II project..."
project_new -family $family -part $device $system_name
set_global_assignment -name QIP_FILE ${system_name}.qip
project_close 

puts "\n"
puts "*************************************************************************"
puts "Successfully generated example design at the following location:                                                    "
puts "                                                                         "
puts "   $ex_design_path                                                 "
puts "                                                                         "
puts "*************************************************************************"
puts "\n"
