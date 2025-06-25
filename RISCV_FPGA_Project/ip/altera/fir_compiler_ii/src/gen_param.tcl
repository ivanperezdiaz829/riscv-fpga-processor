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


# Generate param file

#Parameters
set out_dir           [lindex $argv 0]
set component_name    [lindex $argv 1]
set PhysChanIn        [lindex $argv 2]
set PhysChanOut       [lindex $argv 3]
set ChansPerPhyIn     [lindex $argv 4]
set ChansPerPhyOut    [lindex $argv 5]
set InWidth           [lindex $argv 6]
set InFracWidth       [lindex $argv 7]
set OutWidth          [lindex $argv 8]
set OutFullWidth      [lindex $argv 9]
set OutFracWidth      [lindex $argv 10]
set OutFullFracWidth  [lindex $argv 11]
set nChans            [lindex $argv 12]
set nTaps             [lindex $argv 13]
set clockRate         [lindex $argv 14]
set inRate            [lindex $argv 15]
set interpN           [lindex $argv 16]
set decimN            [lindex $argv 17]
set busDataWidth      [lindex $argv 18]
set bankInWidth       [lindex $argv 19]

set file_name "${out_dir}${component_name}_param.txt"

if { [ catch { set out_file [ open $file_name w ] } err ] } {
    send_message "error" "$err"
    return
}

  puts $out_file "PhysChanIn : $PhysChanIn "
  puts $out_file "PhysChanOut : $PhysChanOut "
  puts $out_file "ChansPerPhyIn : $ChansPerPhyIn "
  puts $out_file "ChansPerPhyOut : $ChansPerPhyOut "
  puts $out_file "InWidth : $InWidth "
  puts $out_file "InFracWidth : $InFracWidth "
  puts $out_file "OutWidth : $OutWidth "
  puts $out_file "OutFullWidth : $OutFullWidth "
  puts $out_file "OutFracWidth : $OutFracWidth "
  puts $out_file "OutFullFracWidth : $OutFullFracWidth "
  puts $out_file "nChans : $nChans "
  puts $out_file "nTaps : $nTaps "
  puts $out_file "clockRate : $clockRate "
  puts $out_file "inRate : $inRate "
  puts $out_file "interpN : $interpN "
  puts $out_file "decimN : $decimN "
  puts $out_file "busDataWidth : $busDataWidth "
  puts $out_file "bankInWidth : $bankInWidth "

close $out_file