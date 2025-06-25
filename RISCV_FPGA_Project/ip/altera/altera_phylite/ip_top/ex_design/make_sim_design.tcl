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
   post_message -type error  "USAGE: $argv0 \[VERILOG|VHDL\]"
   qexit -error
}

set argv0 "quartus_sh -t [info script]"
set args $quartus(args)

if {[llength $args] == 1 } {
   set lang [string toupper [string trim [lindex $args 0]]]
   if {$lang != "VERILOG" && $lang != "VHDL"} {
      show_usage_and_exit $argv0
   }
} else {
   set lang "VERILOG"
}

if {[llength $args] > 1} {
   show_usage_and_exit $argv0
}

set script_path [file dirname [file normalize [info script]]]

source "$script_path/params.tcl"

set ex_design_path         "$script_path/sim"
set system_name            $ed_params(SIM_QSYS_NAME)
set qsys_file              "${system_name}.qsys"
set family                 $ip_params(SYS_INFO_DEVICE_FAMILY)

puts "\n"
puts "*************************************************************************"
puts "Altera External Memory Interface IP Example Design Builder               "
puts "                                                                         "
puts "Type    : Simulation Design                                              "
puts "Family  : $family"
puts "Language: $lang"
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
exec -ignorestderr ip-generate --file-set=SIM_${lang} --output-directory=. --report-file=spd $qsys_file >>& ip_generate.out
exec -ignorestderr ip-make-simscript --spd=ed_sim.spd >>& make_simscript.out

file delete -force ed_sim.spd
file delete -force make_simscript.out
file delete -force ip_generate.out

puts "Finalizing..."

set vcs_scripts [list]
lappend vcs_scripts "${ex_design_path}/synopsys/vcs/vcs_setup.sh"
lappend vcs_scripts "${ex_design_path}/synopsys/vcsmx/vcsmx_setup.sh"

foreach vcs_script $vcs_scripts {
   if {[file exists $vcs_script]} {
      set fh [open $vcs_script r]
      set file_data [read $fh]
      close $fh
      
      set fh [open $vcs_script w]
      foreach line [split $file_data "\n"] {
         if {[regexp -- {USER_DEFINED_SIM_OPTIONS\s*=.*\+vcs\+finish\+100} $line]} {
            regsub -- {\+vcs\+finish\+100} $line {} line
         }
         
         if {[regexp -- {USER_DEFINED_ELAB_OPTIONS\s*=\s*\"\"\s*} $line]} {
            regsub -- {\"\"} $line {"-debug_pp +vcs+vcdpluson"} line
         }         
         puts $fh $line
      }
      close $fh
   }
}

puts "\n"
puts "*************************************************************************"
puts "Successfully generated example design at the following location:                                                    "
puts "                                                                         "
puts "   $ex_design_path                                                 "
puts "                                                                         "
puts "*************************************************************************"
puts "\n"
