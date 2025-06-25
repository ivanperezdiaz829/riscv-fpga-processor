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


proc generate_example_design_fileset {name family} {
  # Get the output name
  set variant_name $name
  set device_family $family
  
  set example_sim_name "${variant_name}_tb"

  # Request a new temporary location to make the example designs
  set tmpdir [add_fileset_file {} OTHER TEMP {}]
  #_iprint "Using temporary directory $tmpdir"

  # Create the simulation example design component
  #_iprint "Generating simulation example design"
  cd $tmpdir
  
  # -------------------------------------------------
  # Generate testbench and sim scripts for simulation
  # -------------------------------------------------
  set simdir_name "simulation"
  file mkdir $simdir_name
  set simdir [file join $tmpdir $simdir_name]
  cd $simdir
  set simlang_vhdl "vhdl"
  file mkdir $simlang_vhdl
  set simvhdl [file join $simdir $simlang_vhdl]
  cd $simvhdl
  
  # Generate the parameterization list for VHDL
  set arg_list [list]
  lappend arg_list "--system-info=DEVICE_FAMILY=$device_family"
  lappend arg_list "--file-set=SIM_VHDL"
  lappend arg_list "--report-file=csv:${example_sim_name}.csv"
  lappend arg_list "--report-file=qip:${example_sim_name}/${example_sim_name}.qip"
  lappend arg_list "--report-file=spd:${example_sim_name}.spd"
  lappend arg_list "--report-file=txt:${example_sim_name}_report.txt"
  lappend arg_list "--output-name=${example_sim_name}"

  # add all non-derived parameters to the command line list
  foreach param [lsort [get_parameters]] {
    if {[get_parameter_property $param DERIVED] == 0} {
      lappend arg_list "--component-param=$param=[get_parameter_value $param]"
    }
  }

  #overwrite IS_RTL_SIM param to 1 in simulation
  lappend arg_list "--component-param=IS_RTL_SIM=1"
  set component_name "sdi_ii_tb"
  set lang_name "vhdl"
  generate_ip_from_quartus_sh $lang_name $component_name $example_sim_name $arg_list [pwd] "generate_tb.tcl" 
  
  cd $simdir
  set simlang_ver "verilog"
  file mkdir $simlang_ver
  set simver [file join $simdir $simlang_ver]
  cd $simver

# Generate the parameterization list for Verilog 
  set arg_list [list]
  lappend arg_list "--system-info=DEVICE_FAMILY=$device_family"
  lappend arg_list "--file-set=SIM_VERILOG"
  lappend arg_list "--report-file=csv:${example_sim_name}.csv"
  lappend arg_list "--report-file=qip:${example_sim_name}/${example_sim_name}.qip"
  lappend arg_list "--report-file=spd:${example_sim_name}.spd"
  lappend arg_list "--report-file=txt:${example_sim_name}_report.txt"
  lappend arg_list "--output-name=${example_sim_name}"

  # add all non-derived parameters to the command line list
  foreach param [lsort [get_parameters]] {
    if {[get_parameter_property $param DERIVED] == 0} {
      lappend arg_list "--component-param=$param=[get_parameter_value $param]"
    }
  }

  #overwrite IS_RTL_SIM param to 1 in simulation
  lappend arg_list "--component-param=IS_RTL_SIM=1"
  set component_name "sdi_ii_tb"
  set lang_name "verilog"
  generate_ip_from_quartus_sh $lang_name $component_name $example_sim_name $arg_list [pwd] "generate_tb.tcl" 
  # -------------------------------------------------------
  # Generate example design for hardware reference design
  # -------------------------------------------------------
  cd $tmpdir
  set example_design_name "${variant_name}_example_design"
  set eddir_name "example_design"
  file mkdir $eddir_name
  set eddir [file join $tmpdir $eddir_name]
  cd $eddir
  
  set ed_arg_list [list]
  lappend ed_arg_list "--system-info=DEVICE_FAMILY=$device_family"
  lappend ed_arg_list "--file-set=QUARTUS_SYNTH"
  lappend ed_arg_list "--report-file=csv:${example_design_name}.csv"
  lappend ed_arg_list "--report-file=qip:${example_design_name}/${example_design_name}.qip"
  lappend ed_arg_list "--report-file=txt:${example_design_name}_report.txt"
  lappend ed_arg_list "--output-name=${example_design_name}"

  # add all non-derived parameters to the command line list
  foreach param [lsort [get_parameters]] {
    if {[get_parameter_property $param DERIVED] == 0} {
      lappend ed_arg_list "--component-param=$param=[get_parameter_value $param]"
    }
  }
  
  set component_name "sdi_ii_example_design"
  set lang_name "hybrid"
  generate_ip_from_quartus_sh $lang_name $component_name $example_design_name $ed_arg_list [pwd] "generate_ed.tcl" 

  # ------------------------------------------------------------------
  # advertize recursively all files generated for the example designs
  # ------------------------------------------------------------------
  cd $tmpdir
  advertize_directory EXAMPLE_DESIGN {} $tmpdir {} EXAMPLE_DESIGN
}

# Function: generate_ip_from_quartus_sh
#
#   This function generates an IP core by way of Quartus shell.
#
#   It creates a tcl file in the requested tmpdir. The file contents are determined
#   by arg_list, which is a list of command line arguments to ip-generate
#       e.g: --component-param=MEM_IS_CS_WIDTH=1.
#   The remainder of the tcl script will assemble the exec command and run it.
#
#   After Quartus finishes, the temporary tcl script will be deleted, and the
#   working directory will be restored.
#
proc generate_ip_from_quartus_sh {lang_name component_name variant_name arg_list tmpdir filename {subdir {}}} {
  set cwd [pwd]

  cd [file join $tmpdir $subdir]

  set qdir $::env(QUARTUS_ROOTDIR)
  set cmd "${qdir}/sopc_builder/bin/ip-generate"

  set fh [open $filename w]

  # Each argument is written to the file line by line.
  # This preserves the list nature, and allows quartus_sh to handle arguments with spaces correctly.
  puts $fh "set arg_list \[list\]"
  foreach item $arg_list {
    puts $fh "lappend arg_list \"$item\""
  }

  puts $fh "catch \{ eval \[concat \[list exec \"$cmd\" --component-name=$component_name\] \$arg_list\] \} temp"
  puts $fh "puts \$temp"
  close $fh

  set quartus_output [run_quartus_tcl_script $filename]
  
  # Only generate sim scripts for simulation 
  if {$component_name == "sdi_ii_tb"} {
    set cmd1 "${qdir}/sopc_builder/bin/ip-make-simscript"

    set fh1 [open generate_msim_setup.tcl w]
    puts $fh1 "catch \{ eval \[concat \[list exec \"$cmd1\"\] --spd=${variant_name}.spd\] \} temp"
    puts $fh1 "puts \$temp"
    close $fh1

    run_quartus_tcl_script generate_msim_setup.tcl
    # Delete redundant file in user directory, may comment this line for debug purpose.
    file delete -force -- generate_msim_setup.tcl
    
    #Generate wave.do for configuring waveform
    #generate_wave $variant_name
  if {$lang_name == "verilog"} {
    set fh2 [open run_sim.tcl w]
    puts $fh2 "cd mentor"
    puts $fh2 "source msim_setup.tcl"
    puts $fh2 "#--------------------------------------------------"
    puts $fh2 "# Elaborate the top level design with novopt option"
    #puts $fh2 "onerror {quit -f}"
    #puts $fh2 "onbreak {quit -f}"
    puts $fh2 "dev_com"
    puts $fh2 "com"
    puts $fh2 "elab_debug -t 1fs -sv_seed random"
    #puts $fh2 "source wave.do"
    puts $fh2 "run -all"
    close $fh2
	
    set fh3 [open run_riviera.tcl w]
    puts $fh3 "cd aldec"
    puts $fh3 "source rivierapro_setup.tcl"
    puts $fh3 "#--------------------------------------------------"
    puts $fh3 "# Elaborate the top level design with novopt option"
    #puts $fh3 "onerror {quit -f}"
    #puts $fh3 "onbreak {quit -f}"
    puts $fh3 "dev_com"
    puts $fh3 "com"
    puts $fh3 "elab_debug -t 1fs"
    #puts $fh3 "source wave.do"
    puts $fh3 "run -all"
    close $fh3
	
    set fh4 [open run_vcs.sh w]
    puts $fh4 "cd synopsys/vcs"
    puts $fh4 "cat vcs_setup.sh | sed -e 's/+vcs+finish+100/ /' > vcs_setup.sh.tmp; mv -f vcs_setup.sh.tmp vcs_setup.sh"
    puts $fh4 "source vcs_setup.sh"
    close $fh4
	
    #set fh5 [open run_ncsim.sh w]
    #puts $fh5 "cd cadence"
    #puts $fh5 "cat ncsim_setup.sh | sed -e 's/SKIP_ELAB=0/SKIP_ELAB=1/' > ncsim_setup.sh.tmp; mv -f ncsim_setup.sh.tmp ncsim_setup.sh"
    #puts $fh5 "cat ncsim_setup.sh | sed -e 's/SKIP_SIM=0/SKIP_SIM=1/' > ncsim_setup.sh.tmp; mv -f ncsim_setup.sh.tmp ncsim_setup.sh"
    #puts $fh5 "source ncsim_setup.sh"
    #puts $fh5 "ncelab -access +w+r+c -relax -namemap_mixgen \$TOP_LEVEL_NAME -SNAPSHOT top -timescale 1fs/1fs"
    #puts $fh5 "ncsim top"
    #close $fh5
	
    set fh6 [open run_vcsmx.sh w]
    puts $fh6 "cd synopsys/vcsmx"
    puts $fh6 "cat vcsmx_setup.sh | sed -e 's/+vcs+finish+100/ /' > vcsmx_setup.sh.tmp; mv -f vcsmx_setup.sh.tmp vcsmx_setup.sh"
    puts $fh6 "cat vcsmx_setup.sh | sed -e 's/vlogan +v2k           \\\\\\\"+incdir/vlogan +v2k -v2005           \\\\\\\"+incdir/' > vcsmx_setup.sh.tmp; mv -f vcsmx_setup.sh.tmp vcsmx_setup.sh"
    puts $fh6 "source vcsmx_setup.sh"
    close $fh6
	}
	
  if {$lang_name == "vhdl"} {
    set fh2 [open run_sim.tcl w]
    puts $fh2 "cd mentor"
    puts $fh2 "source msim_setup.tcl"
    puts $fh2 "#--------------------------------------------------"
    puts $fh2 "# Elaborate the top level design with novopt option"
    #puts $fh2 "onerror {quit -f}"
    #puts $fh2 "onbreak {quit -f}"
    puts $fh2 "dev_com"
    puts $fh2 "com"
    puts $fh2 "elab_debug -t 1fs -sv_seed random"
    #puts $fh2 "source wave.do"
    puts $fh2 "run -all"
    close $fh2
	}
  } 
  # Delete redundant file in user directory, may comment this line for debug purpose.
  file delete -force -- $filename
  #if {[::alt_mem_if::util::qini::qini_value "debug_msg_level"] == 0} {
  #  catch {file delete -force -- $filename} temp_result
  #}

  cd $cwd

  return $quartus_output
}

# proc: run_quartus_tcl_script
#
#   Run a TCL script with the Quartus shell.
#
# parameters:
#
#    filename: name of the TCL script
#
# returns:
#
#   (none)
#
proc run_quartus_tcl_script {filename} {
  set qdir $::env(QUARTUS_ROOTDIR)
  set cmd [concat [list exec "${qdir}/bin/quartus_sh" "-t" $filename]]
  #_dprint 1 "Running the command: $cmd"
  catch { eval $cmd } tempresult
  #_dprint 1 "Returned: $tempresult"
  return $tempresult
}

# proc: advertize_directory
#
#    Description : Recursively advertize a directory.  The directory structure is preserved
#
# parameters:
#
#   valid_filesets : Names of filesets separated by ",". Choices are QUARTUS_SYNTH, SIM_VERILOG, SIM_VHDL, EXAMPLE_DESIGN
#   dirname        : subdirectory to advertize
#   src_fulldir    : directory (full path) of source file
#   dest_subdir    : subdirectory (relative to requested outdir) of destination of added file
#   fileset        :
#
# returns:
#
#   (none)
#
proc advertize_directory {valid_filesets dirname src_fulldir dest_subdir fileset} {
	foreach filename_full [glob -nocomplain [file join $src_fulldir $dirname "*"]] {
		set filename [file tail $filename_full]
		if {[file isdirectory $filename_full] && [string compare $filename "."] != 0 && [string compare $filename ".."] != 0} {
			advertize_directory $valid_filesets [file join $dirname $filename] $src_fulldir $dest_subdir $fileset
		} elseif {[file isfile $filename_full]} {
			advertize_file $valid_filesets $filename [file join $src_fulldir $dirname] [file join $dest_subdir $dirname] $fileset
		}
	}
}

# proc: advertize_file
#
#    Description
#
# parameters:
#
#   valid_filesets : Names of filesets separated by ",". Choices are QUARTUS_SYNTH, SIM_VERILOG, SIM_VHDL, EXAMPLE_DESIGN
#   filename       : filename only
#   src_fulldir    : directory (full path) of source file
#   dest_subdir    : subdirectory (relative to requested outdir) of destination of added file
#   fileset        :
#
# returns:
#
#   (none)
#
proc advertize_file {valid_filesets filename src_fulldir dest_subdir fileset} {

	# need all quartus_synth and sim_vhdl files for simgen
	if {[lsearch -exact [split $valid_filesets ","] "QUARTUS_SYNTH"] != -1 ||
	    [lsearch -exact [split $valid_filesets ","] "SIM_VHDL"] != -1} {
		if {[regexp ".*\\.((v)|(sv)|(vh)|(vhd)|(vho))\[ \t\]*$" $filename] } {
			lappend ::simgen_list [file join $src_fulldir $filename]
		}
	}

	if {[lsearch -exact [split $valid_filesets ","] $fileset] != -1} {

		if {[regexp {.*\.vh[do]} $filename] } {
			set file_type "VHDL"
		} elseif {[regexp {.*\.vh?} $filename] } {
			set file_type "VERILOG"
		} elseif {[regexp {.*\.hex} $filename]} {
			set file_type "HEX"
		} elseif {[regexp {.*\.sdc} $filename]} {
			set file_type "SDC"
		} elseif {[regexp {.*\.sv} $filename]} {
			set file_type "SYSTEM_VERILOG"
		} else {
			set file_type "OTHER"
		}

		# The second clause will equal one if the file is marked as valid for more fileset than just the example design
		if {[string compare -nocase $fileset "EXAMPLE_DESIGN"] == 0 && [string compare -nocase $valid_filesets "EXAMPLE_DESIGN"] == 1} {
			# the file must be for the memory interface, so add it to the internal qip
			if {[regexp {.*\.vh[do]} $filename] } {
				set file_type_qip "VHDL_FILE"
			} elseif {[regexp {.*\.vh?} $filename] } {
				set file_type_qip "VERILOG_FILE"
			} elseif {[regexp {.*\.sdc} $filename]} {
				set file_type_qip "SDC_FILE"
			} elseif {[regexp {.*\.tcl} $filename]} {
				set file_type_qip "TCL_FILE"
			} elseif {[regexp {.*\.sv} $filename]} {
				set file_type_qip "SYSTEMVERILOG_FILE"
			} else {
				set file_type_qip "SOURCE_FILE"
			}
			append ::example_design_memif_qipfile_contents "set_global_assignment -name $file_type_qip \[file join \$::quartus(qip_path) [file join $dest_subdir $filename]\] -library lib_${::mod_name}\n"
		}

		add_fileset_file [file join $dest_subdir $filename] $file_type PATH [file join $src_fulldir $filename]
	}
}

# proc: derive_instance_name
#
# Derive the variation name for DUT and the derived TEST instances
#
# Eg. if DUT = tx xcvr, 
#     then the derived TEST instances = tx proto,rx xcvr, rx proto
#
# Naming: DUT = dut_tx_xcvr, TEST instances = test_tx_proto, test_rx_xcvr, 
#                                             test_rx_proto
#
# ------------------------------------------------------------------------
#      -------------------      -----------------
# ->  | inst1 = tx proto  | -> | inst2 = tx xcvr | ->    
#      -------------------      -----------------
#      -------------------      -----------------
# <-  | inst3 = rx proto  | <- | inst4 = rx xcvr | <- 
#      -------------------      -----------------
#
#  if DUT = xcvr_proto, du
#    the DUT has inst1, inst2, inst3 and inst4.
#    so inst1,2,3,4 have the same name: dut_du_xcvr_proto
#
#  if DUT = xcvr_proto, tx
#    the DUT has inst1 and inst2
#    so inst1,2 have the same name: dut_tx_xcvr_proto
#    & inst3,4 have the same name: test_rx_xcvr_proto
#
#  if DUT = xcvr_proto, rx
#    the DUT has inst3 and inst4
#    so inst3,4 have the same name: dut_rx_xcvr_proto
#    & inst1,2 have the same name: test_tx_xcvr_proto
#
#  if DUT = proto, du
#    the DUT has inst1 and inst3
#    so inst1,3 have the same name: dut_du_proto
#    & inst2,4 have the same name: test_du_xcvr
#
#  if DUT = proto, tx
#    the DUT has inst1
#    so inst1 has the name: dut_tx_proto
#    & inst2 has: test_tx_xcvr
#    & inst3 has: test_rx_proto
#    & inst4 has: test_rx_xcvr
#
#  if DUT = proto, rx
#    the DUT has inst3
#    so inst3 has the name: dut_rx_proto
#    & inst1 has: test_tx_proto
#    & inst2 has: test_tx_xcvr
#    & inst4 has: test_rx_xcvr
#
#  if DUT = xcvr, du
#    the DUT has inst2 and inst4
#    so inst2,4 have the same name: dut_du_xcvr
#    & inst1,3 have the same name: test_du_proto
#
#  if DUT = xcvr, tx
#    the DUT has inst2
#    so inst2 has the name: dut_tx_xcvr
#    & inst1 has: test_tx_proto
#    & inst3 has: test_rx_proto
#    & inst4 has: test_rx_xcvr
#
#  if DUT = xcvr, rx
#    the DUT has inst4
#    so inst4 has the name: dut_rx_xcvr
#    & inst1 has: test_tx_proto
#    & inst2 has: test_tx_xcvr
#    & inst3 has: test_rx_proto
# ----------------------------------------------------------------------------
#
proc derive_instance_name { dut_dir dut_config dut_std } {
  set  test_dirn     [derive_opposite_dir_param $dut_dir]  
  set  test_confign  [derive_opposite_config_param $dut_config] 
  set  ch            ch1

  if { $dut_config == "xcvr_proto" } {

    if { $dut_dir == "du" } {

      set inst1 ${ch}_dut_${dut_dir}_${dut_std}_${dut_config}  
      set inst2 ${ch}_dut_${dut_dir}_${dut_std}_${dut_config}
      set inst3 ${ch}_dut_${dut_dir}_${dut_std}_${dut_config}
      set inst4 ${ch}_dut_${dut_dir}_${dut_std}_${dut_config}

    } else {

       if { $dut_dir == "tx" } {

	 set inst1 ${ch}_dut_${dut_dir}_${dut_std}_${dut_config}
	 set inst2 ${ch}_dut_${dut_dir}_${dut_std}_${dut_config}
	 set inst3 ${ch}_test_${test_dirn}_${dut_std}_${dut_config}
	 set inst4 ${ch}_test_${test_dirn}_${dut_std}_${dut_config}

       } else {

	 set inst1 ${ch}_test_${test_dirn}_${dut_std}_${dut_config}
	 set inst2 ${ch}_test_${test_dirn}_${dut_std}_${dut_config}
	 set inst3 ${ch}_dut_${dut_dir}_${dut_std}_${dut_config}
	 set inst4 ${ch}_dut_${dut_dir}_${dut_std}_${dut_config}

       }
     }

  } else {

    if { $dut_config == "proto" } {

      if { $dut_dir == "du" } {

	set inst1 ${ch}_dut_${dut_dir}_${dut_std}_${dut_config}     
	set inst2 ${ch}_test_${dut_dir}_${dut_std}_${test_confign} 
	set inst3 ${ch}_dut_${dut_dir}_${dut_std}_${dut_config}   
	set inst4 ${ch}_test_${dut_dir}_${dut_std}_${test_confign}

      } else {

	if { $dut_dir == "tx" } {

	    set inst1 ${ch}_dut_${dut_dir}_${dut_std}_${dut_config}
	    set inst2 ${ch}_test_${dut_dir}_${dut_std}_${test_confign}
	    set inst3 ${ch}_test_${test_dirn}_${dut_std}_${dut_config}
	    set inst4 ${ch}_test_${test_dirn}_${dut_std}_${test_confign}

	} else {

	    set inst1 ${ch}_test_${test_dirn}_${dut_std}_${dut_config}
	    set inst2 ${ch}_test_${test_dirn}_${dut_std}_${test_confign}
	    set inst3 ${ch}_dut_${dut_dir}_${dut_std}_${dut_config}
	    set inst4 ${ch}_test_${dut_dir}_${dut_std}_${test_confign}

	}
      }
    } 
	
    if { $dut_config == "xcvr" } {

      if { $dut_dir == "du" } {

	set inst1 ${ch}_test_${dut_dir}_${dut_std}_${test_confign}  
	set inst2 ${ch}_dut_${dut_dir}_${dut_std}_${dut_config}
	set inst3 ${ch}_test_${dut_dir}_${dut_std}_${test_confign}
	set inst4 ${ch}_dut_${dut_dir}_${dut_std}_${dut_config}

      } else {

	if { $dut_dir == "tx" } {

	  set inst1 ${ch}_test_${dut_dir}_${dut_std}_${test_confign}
	  set inst2 ${ch}_dut_${dut_dir}_${dut_std}_${dut_config}
	  set inst3 ${ch}_test_${test_dirn}_${dut_std}_${test_confign}
	  set inst4 ${ch}_test_${test_dirn}_${dut_std}_${dut_config}

	} else {

	  set inst1 ${ch}_test_${test_dirn}_${dut_std}_${test_confign}
	  set inst2 ${ch}_test_${test_dirn}_${dut_std}_${dut_config}
	  set inst3 ${ch}_test_${dut_dir}_${dut_std}_${test_confign}
	  set inst4 ${ch}_dut_${dut_dir}_${dut_std}_${dut_config}

	}
      }
    }	
  }

  set_parameter_value INST1 $inst1
  set_parameter_value INST2 $inst2
  set_parameter_value INST3 $inst3
  set_parameter_value INST4 $inst4

}

# proc: derive_instance_param
#
# Derive the direction and configuration for dut and the derived test instances
#
# See proc derive_instance_name
#
proc derive_instance_param { dut_dir dut_config } {
  set  test_dirn     [derive_opposite_dir_param $dut_dir]  
  set  test_confign  [derive_opposite_config_param $dut_config] 

  if { $dut_config == "xcvr_proto" } {

    if { $dut_dir == "du" } {

      set num_inst 1
      set inst1_dir_param    $dut_dir
      set inst1_config_param $dut_config
      set inst2_dir_param    $dut_dir    ;# Unused
      set inst2_config_param $dut_config ;# Unused  
      set inst3_dir_param    $dut_dir    ;# Unused 
      set inst3_config_param $dut_config ;# Unused 
      set inst4_dir_param    $dut_dir    ;# Unused 
      set inst4_config_param $dut_config ;# Unused 

    } else {

       set num_inst 2

       if { $dut_dir == "tx" } {

	 set inst1_dir_param    $dut_dir
	 set inst1_config_param $dut_config
	 set inst2_dir_param    $dut_dir    ;# Unused
	 set inst2_config_param $dut_config ;# Unused
	 set inst3_dir_param    $test_dirn
	 set inst3_config_param $dut_config
         set inst4_dir_param    $test_dirn  ;# Unused
	 set inst4_config_param $dut_config ;# Unused

       } else {

	 set inst1_dir_param    $test_dirn
	 set inst1_config_param $dut_config
         set inst2_dir_param    $test_dirn  ;# Unused
	 set inst2_config_param $dut_config ;# Unused
	 set inst3_dir_param    $dut_dir
	 set inst3_config_param $dut_config
         set inst4_dir_param    $dut_dir    ;# Unused
	 set inst4_config_param $dut_config ;# Unused

       }
     }

  } else {

    if { $dut_config == "proto" } {

      if { $dut_dir == "du" } {

	set num_inst 2
        set inst1_dir_param    $dut_dir
        set inst1_config_param $dut_config
        set inst2_dir_param    $dut_dir
        set inst2_config_param $test_confign
        set inst3_dir_param    $dut_dir      ;# Unused 
        set inst3_config_param $dut_config   ;# Unused
        set inst4_dir_param    $dut_dir      ;# Unused
        set inst4_config_param $test_confign ;# Unused

      } else {

        set num_inst 4

	if { $dut_dir == "tx" } {

          set inst1_dir_param    $dut_dir
	  set inst1_config_param $dut_config
	  set inst2_dir_param    $dut_dir
	  set inst2_config_param $test_confign
	  set inst3_dir_param    $test_dirn
	  set inst3_config_param $dut_config
	  set inst4_dir_param    $test_dirn
	  set inst4_config_param $test_confign

	} else {

	  set inst1_dir_param    $test_dirn
	  set inst1_config_param $dut_config
	  set inst2_dir_param    $test_dirn
	  set inst2_config_param $test_confign
	  set inst3_dir_param    $dut_dir
	  set inst3_config_param $dut_config
	  set inst4_dir_param    $dut_dir
	  set inst4_config_param $test_confign

	}
      }
    } 
	
    if { $dut_config == "xcvr" } {

      if { $dut_dir == "du" } {

	set num_inst 2
        set inst1_dir_param    $dut_dir
        set inst1_config_param $test_confign
        set inst2_dir_param    $dut_dir
        set inst2_config_param $dut_config
	set inst3_dir_param    $dut_dir        ;# Unused
        set inst3_config_param $test_confign   ;# Unused
        set inst4_dir_param    $dut_dir        ;# Unused
        set inst4_config_param $dut_config     ;# Unused

      } else {

	set num_inst 4

	if { $dut_dir == "tx" } {

	  set inst1_dir_param    $dut_dir
	  set inst1_config_param $test_confign
	  set inst2_dir_param    $dut_dir
	  set inst2_config_param $dut_config
	  set inst3_dir_param    $test_dirn
	  set inst3_config_param $test_confign
	  set inst4_dir_param    $test_dirn
	  set inst4_config_param $dut_config

	} else {

	  set inst1_dir_param    $test_dirn
	  set inst1_config_param $test_confign
	  set inst2_dir_param    $test_dirn
	  set inst2_config_param $dut_config
	  set inst3_dir_param    $dut_dir
	  set inst3_config_param $test_confign
	  set inst4_dir_param    $dut_dir
	  set inst4_config_param $dut_config

	}
      }
    }	
  }

  set_parameter_value NUM_INST        $num_inst
  set_parameter_value INST1_DIR       $inst1_dir_param
  set_parameter_value INST2_DIR       $inst2_dir_param 
  set_parameter_value INST3_DIR       $inst3_dir_param
  set_parameter_value INST4_DIR       $inst4_dir_param
  set_parameter_value INST1_CONFIG    $inst1_config_param
  set_parameter_value INST2_CONFIG    $inst2_config_param
  set_parameter_value INST3_CONFIG    $inst3_config_param
  set_parameter_value INST4_CONFIG    $inst4_config_param

}

# proc: derive_opposite_dir_param
#
# Derive the opposite direction for the derived test instances based on
# the dut direction
# 
# Eg. if dut = tx, 
#     then the derived test instances = rx
#
proc derive_opposite_dir_param { dut_dir } {

  if { $dut_dir == "du" } {

    set test_dirn du

  } elseif { $dut_dir == "tx" } {

    set test_dirn rx

  } else {

    set test_dirn tx

  }
  
  return $test_dirn
}

# proc: derive_opposite_config_param
#
# Derive the opposite configuration for the derived test instances based on
# the dut configuration
# 
# Eg. if dut = xcvr, 
#     then the derived test instances = proto
#
proc derive_opposite_config_param { dut_config } {

  if { $dut_config == "xcvr_proto" } {

    set test_confign xcvr_proto

  } elseif { $dut_config == "xcvr" } {

    set test_confign proto

  } else {

    set test_confign xcvr

  }

  return $test_confign
}

# proc: generate_wave
#
#   Generate wave.do file to configure the waveform
#   and add some instances to the wave window 
#
# parameters:
#   file_dir : subdirectory of the generated files 
# 
proc generate_wave {file_dir} {
   cd mentor
   set file [open wave.do w]
   puts $file "onerror \{resume\}"
   puts $file "quietly WaveActivateNextPane \{\} 0"
   puts $file "add wave -noupdate -divider \{tb test control outputs\}"
   puts $file "add wave -noupdate \/${file_dir}\/tb_test_control\/ref_clk"
   puts $file "add wave -noupdate \/${file_dir}\/tb_test_control\/p_clk"
   puts $file "add wave -noupdate \/${file_dir}\/tb_test_control\/reconfig_clk"
   puts $file "add wave -noupdate \/${file_dir}\/tb_test_control\/clk_fpga"
   puts $file "add wave -noupdate \/${file_dir}\/tb_test_control\/ref_rst"
   puts $file "add wave -noupdate \/${file_dir}\/tb_test_control\/p_rst"
   puts $file "add wave -noupdate \/${file_dir}\/tb_test_control\/reconfig_rst"
   puts $file "add wave -noupdate \/${file_dir}\/tb_test_control\/hd_sdn"
   puts $file "add wave -noupdate \/${file_dir}\/tb_test_control\/bar_75_100n"
   puts $file "add wave -noupdate \/${file_dir}\/tb_test_control\/enable"
   puts $file "add wave -noupdate \/${file_dir}\/tb_test_control\/patho"
   puts $file "add wave -noupdate \/${file_dir}\/tb_test_control\/blank"
   puts $file "add wave -noupdate \/${file_dir}\/tb_test_control\/no_color"
   puts $file "add wave -noupdate \/${file_dir}\/tb_test_control\/select_std"
   puts $file "add wave -noupdate \/${file_dir}\/tb_test_control\/enable_ln"
   puts $file "add wave -noupdate \/${file_dir}\/tb_test_control\/enable_crc"
   puts $file "add wave -noupdate \/${file_dir}\/tb_test_control\/tx_std"
   puts $file "add wave -noupdate \/${file_dir}\/tb_test_control\/enable_3g_search"
   puts $file "add wave -noupdate \/${file_dir}\/tb_test_control\/enable_hd_search"
   puts $file "add wave -noupdate \/${file_dir}\/tb_test_control\/enable_sd_search"
   puts $file "add wave -noupdate \/${file_dir}\/tb_test_control\/sdi_gxb_powerdown"
   puts $file "add wave -noupdate -divider \{ed input\}"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/ref_clk"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/p_clk"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/reconfig_clk"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/clk_fpga"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/ref_rst"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/p_rst"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/reconfig_rst"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/pattgen_hd_sdn"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/pattgen_bar_75_100n"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/pattgen_enable"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/pattgen_patho"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/pattgen_blank"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/pattgen_no_color"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/pattgen_select_std"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/dut_du_xcvr_proto_sdi_gxb_powerdown"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/dut_du_xcvr_proto_enable_crc"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/dut_du_xcvr_proto_enable_ln"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/dut_du_xcvr_proto_tx_std"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/dut_du_xcvr_proto_enable_sd_search"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/dut_du_xcvr_proto_enable_hd_search"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/dut_du_xcvr_proto_enable_3g_search"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/dut_du_xcvr_proto_sdi_rx"
   puts $file "add wave -noupdate -divider \{ed output\}"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/dut_du_xcvr_proto_gxb_tx_clkout"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/dut_du_xcvr_proto_tx_status"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/dut_du_xcvr_proto_sdi_tx"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/dut_du_xcvr_proto_rx_clk"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/dut_du_xcvr_proto_crc_error_y"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/dut_du_xcvr_proto_crc_error_c"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/dut_du_xcvr_proto_rx_AP"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/dut_du_xcvr_proto_rx_F"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/dut_du_xcvr_proto_rx_V"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/dut_du_xcvr_proto_rx_H"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/dut_du_xcvr_proto_rx_ln"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/dut_du_xcvr_proto_rx_std"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/dut_du_xcvr_proto_rx_xyz"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/dut_du_xcvr_proto_xyz_valid"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/dut_du_xcvr_proto_rx_eav"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/dut_du_xcvr_proto_rx_trs"
   puts $file "add wave -noupdate \/${file_dir}\/example_design\/dut_du_xcvr_proto_rx_status"
   puts $file "add wave -noupdate -divider \{checker serial input\}"
   puts $file "add wave -noupdate \/${file_dir}\/tb_checker_serial\/ref_clk"
   puts $file "add wave -noupdate \/${file_dir}\/tb_checker_serial\/sdi_serial"
   puts $file "add wave -noupdate \/${file_dir}\/tb_checker_serial\/tx_status"
   puts $file "add wave -noupdate -divider \{checker serial internal\}"
   puts $file "add wave -noupdate \/${file_dir}\/tb_checker_serial\/aligned"
   puts $file "add wave -noupdate \/${file_dir}\/tb_checker_serial\/tx_sclk"
   puts $file "add wave -noupdate \/${file_dir}\/tb_checker_serial\/tx_lfsr"
   puts $file "add wave -noupdate \/${file_dir}\/tb_checker_serial\/tx_nrzi"
   puts $file "add wave -noupdate \/${file_dir}\/tb_checker_serial\/last_sample"
   puts $file "add wave -noupdate \/${file_dir}\/tb_checker_serial\/descrambled"
   puts $file "add wave -noupdate -radix hexadecimal \/${file_dir}\/tb_checker_serial\/shiftreg"
   puts $file "add wave -noupdate \/${file_dir}\/tb_checker_serial\/trs_count"
   puts $file "add wave -noupdate \/${file_dir}\/tb_checker_serial\/txword"
   puts $file "TreeUpdate \[SetDefaultTree\]"
   puts $file "WaveRestoreCursors \{\{Cursor 1\} \{11383574 ps\} 0\}"
   puts $file "configure wave -namecolwidth 252"
   puts $file "configure wave -valuecolwidth 100"
   puts $file "configure wave -justifyvalue left"
   puts $file "configure wave -signalnamewidth 0"
   puts $file "configure wave -snapdistance 10"
   puts $file "configure wave -datasetprefix 0"
   puts $file "configure wave -rowmargin 4"
   puts $file "configure wave -childrowmargin 2"
   puts $file "configure wave -gridoffset 0"
   puts $file "configure wave -gridperiod 1"
   puts $file "configure wave -griddelta 40"
   puts $file "configure wave -timeline 0"
   puts $file "configure wave -timelineunits ps"
   puts $file "update"
   puts $file "WaveRestoreZoom \{692296 ps\} \{695080 ps\}"   
   close $file
   cd ..
   }
