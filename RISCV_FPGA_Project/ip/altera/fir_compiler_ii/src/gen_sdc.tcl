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


# Create sdc file

#Parameters
set out_dir                        [lindex $argv 0]
set component_name                 [lindex $argv 1]
set clock_rate                     [lindex $argv 2]

set file_name "${out_dir}${component_name}.sdc"

if { [ catch { set out_file [ open $file_name w ] } err ] } {
    send_message "error" "$err"
    return
}

puts $out_file "## Generated SDC file \"${out_dir}${component_name}.sdc\""
puts $out_file ""
puts $out_file "create_clock -name {clk} -period \"$clock_rate MHz\" \[get_ports {clk}\]"

close $out_file
