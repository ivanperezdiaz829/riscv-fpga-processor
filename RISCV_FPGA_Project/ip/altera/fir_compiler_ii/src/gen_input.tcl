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


# Create input data file

#package require ::quartus::flow
#package require ::quartus::project
#package require ::quartus::iptclgen

#Parameters
set out_dir                        [lindex $argv 0]
set component_name                 [lindex $argv 1]

set DATA_WIDTH_c                   [lindex $argv 2]
set filter_type                    [lindex $argv 3]
set interpN                        [lindex $argv 4]
set decimN                         [lindex $argv 5]
set data_type                      [lindex $argv 6]
set NUM_OF_CHANNELS_c              [lindex $argv 7]
set NUM_OF_TAPS_c                  [lindex $argv 8]
set pfc_exists                     [lindex $argv 9]
set clockRate                      [lindex $argv 10]
set inRate                         [lindex $argv 11]
set bankcount                      [lindex $argv 12]

set INVERSE_TDM_FACTOR_c [expr int([expr ceil([expr double($inRate) / $clockRate])])]
# Adjust samples_factor to reduce/increase the number of samples
set samples_factor 2

#Temp
set pfc_exists false

set file_name "${out_dir}${component_name}_input.txt"

if { [ catch { set out_file [ open $file_name w ] } err ] } {
    send_message "error" "$err"
    return
}

if { ( $filter_type == "Decimation" || $filter_type == "Fractional Rate" ) && $pfc_exists == "false" } {

  set total_zero_samples [expr $NUM_OF_TAPS_c * $NUM_OF_CHANNELS_c * $decimN]

} elseif { ( $filter_type == "Decimation" || $filter_type == "Fractional Rate" ) && $pfc_exists == "true" } {

  set total_zero_samples [expr $NUM_OF_TAPS_c * 5 * $NUM_OF_CHANNELS_c * $decimN]

} else {

  set total_zero_samples [expr $NUM_OF_TAPS_c * $NUM_OF_CHANNELS_c * $INVERSE_TDM_FACTOR_c ]

}
  
if {$total_zero_samples < 10} {
  set total_zero_samples [expr $total_zero_samples * 3]
}

  # Reduce simulation time by reducing the number of samples
  if { $NUM_OF_CHANNELS_c < 6 } {
    set total_non_zero_samples [expr $NUM_OF_TAPS_c * $NUM_OF_CHANNELS_c *$decimN ]
  } else {
    set total_non_zero_samples [expr $samples_factor * $NUM_OF_CHANNELS_c *$decimN ]
  }
  
  if {$INVERSE_TDM_FACTOR_c > 1} {
    set total_non_zero_samples [expr $NUM_OF_TAPS_c * $NUM_OF_CHANNELS_c *$decimN * $INVERSE_TDM_FACTOR_c * $interpN ]
  }

if {$total_non_zero_samples < 15} {
  set total_non_zero_samples [expr $total_non_zero_samples * 3]
}

  if { $NUM_OF_CHANNELS_c < 6 } {
    set total_random_samples [expr $NUM_OF_TAPS_c * $NUM_OF_CHANNELS_c * $INVERSE_TDM_FACTOR_c]
  } else {
    set total_random_samples [expr $samples_factor * $NUM_OF_CHANNELS_c * $INVERSE_TDM_FACTOR_c]
  }

if { $filter_type == "Decimation" || $filter_type == "Fractional Rate" } {
  set total_random_samples [expr $NUM_OF_TAPS_c * $NUM_OF_CHANNELS_c * $decimN]
}

set total_samples [expr $total_non_zero_samples + $total_zero_samples + $total_random_samples]

#if($is_reg_test)
##${hash}NUMSYMBOLS $total_samples
#end  

#Random set of bank_seq, 0 = 0,1,2,3... , 1= random banks....
set bank_seq_set [expr {int(rand()*2)}]

if {$bankcount > 1} {
  set bank_seq_cnt 0
  set bank_seq ""
  for {set cnt 0} {$cnt < [expr $total_samples * 2]} {incr cnt} {
    lappend bank_seq [expr $cnt%$bankcount]
  }
}
##all zeros for at least num_of_Taps times.
for {set idx 0} {$idx < $total_zero_samples} {incr idx} {
  if {$bankcount > 1} {
    if {$bank_seq_set == 0 } {
      puts $out_file "0 [lindex $bank_seq $bank_seq_cnt]"
      incr bank_seq_cnt
    } else {
      puts $out_file "0 [expr {int(rand()*$bankcount)}]"
    }
  } else {
  	puts $out_file "0"
  }
}

##the first samples of each channel

if {( $filter_type == "Decimation" || $filter_type == "Fractional Rate" ) && $pfc_exists == "false"} {
  for {set idx 1} {$idx < [expr $decimN+1]} {incr idx} {
    for {set sample 1} {$sample < [expr $NUM_OF_CHANNELS_c+1]} {incr sample} {
      if {$bankcount > 1} {
        if {$bank_seq_set == 0 } {
          puts $out_file "$sample [lindex $bank_seq $bank_seq_cnt]"
          incr bank_seq_cnt
        } else {
        	 puts $out_file "$sample [expr {int(rand()*$bankcount)}]"
        }
      } else {
        puts $out_file "$sample"
      }
    }
  }
} else {
  for {set sample 1} {$sample < [expr $NUM_OF_CHANNELS_c+1]} {incr sample} {
    if {$bankcount > 1} {
      if {$bank_seq_set == 0 } {
        puts $out_file "$sample [lindex $bank_seq $bank_seq_cnt]"
        incr bank_seq_cnt
      } else {
        puts $out_file "$sample [expr {int(rand()*$bankcount)}]"
      }
    } else {
    	puts $out_file "$sample"
    }
  }
}

##the rest are all zeros

if {( $filter_type == "Decimation" || $filter_type == "Fractional Rate" )} {
  set start_part_two [expr $NUM_OF_CHANNELS_c * $decimN + 1]
} else {
  set start_part_two [expr $NUM_OF_CHANNELS_c + 1]
}

for {set sample $start_part_two} {$sample < [expr $total_non_zero_samples+1]} {incr sample} {
  if {$bankcount > 1} {
    if {$bank_seq_set == 0 } {
      puts $out_file "0 [lindex $bank_seq $bank_seq_cnt]"
      incr bank_seq_cnt
    } else {
      puts $out_file "0 [expr {int(rand()*$bankcount)}]"
    }
  } else {
  	puts $out_file "0"
  }
}

##random number
if {($data_type == "Signed Binary") || ($data_type == "Signed Fractional Binary") } {
  set min_limit [expr 0 - [expr pow (2,[expr $DATA_WIDTH_c-1])]]
} else {
  set min_limit 0
}

if {($data_type == "Signed Binary") || ($data_type == "Signed Fractional Binary") } {
  set max_limit [expr [expr pow (2,[expr $DATA_WIDTH_c-1])] - 1]
} else {
  set max_limit [expr [expr pow (2,$DATA_WIDTH_c)] - 1]
}

for {set idx 0} {$idx < $total_random_samples} {incr idx} {
  # generate random integer number in the range [min,max]
  if {$bankcount > 1} {
    if {$bank_seq_set == 0 } {
      puts $out_file "[expr {int(rand()*($max_limit-$min_limit+1)+$min_limit)}] [lindex $bank_seq $bank_seq_cnt]"
      incr bank_seq_cnt
    } else {
    	puts $out_file "[expr {int(rand()*($max_limit-$min_limit+1)+$min_limit)}] [expr {int(rand()*$bankcount)}]"
    }
  } else {
    puts $out_file "[expr {int(rand()*($max_limit-$min_limit+1)+$min_limit)}]"
  }
}

close $out_file
