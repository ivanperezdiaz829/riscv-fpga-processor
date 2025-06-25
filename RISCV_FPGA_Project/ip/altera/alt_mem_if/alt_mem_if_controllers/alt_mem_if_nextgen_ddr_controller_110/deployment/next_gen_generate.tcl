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



proc find_files { basedir pattern } {

	#set basedir [string trimright [file join [file normalize $basedir] { }]]
	# Tcl 8.0 does not implement file normalize. I don't think it's crucial here
	set basedir [string trimright [file join $basedir { }]]
	set found_files {}

	# Look in the current directory for matching files, -type {f r}
	# means ony readable normal files are looked at, -nocomplain stops
	# an error being thrown if the returned list is empty
	#foreach file_name [glob -nocomplain -type {f r} -path $basedir $pattern]
	# Tcl 8.0 does not implement the options -type or -path. Must mimic manually
	foreach file_name [glob -nocomplain [file join $basedir $pattern]] {
		if { [string compare [file type $file_name] "file"] == 0 && [file readable $file_name]} {
			lappend found_files $file_name
		}
	}

	# Now look for any sub direcories in the current directory
	#foreach dir_name [glob -nocomplain -type {d  r} -path $basedir *]
	# Tcl 8.0 does not implement the options -type or -path. Must mimic manually
	foreach dir_name [glob -nocomplain [file join $basedir "*"]] {
		if { [string compare [file type $dir_name] "directory"] == 0 && [file readable $dir_name]} {
			# Recusively call the routine on the sub directory and append any
  			# new files to the results
   			set sub_dir_list [find_files $dir_name $pattern]
			if { [llength $sub_dir_list] > 0 } {
				foreach sub_dir_file $sub_dir_list {
					lappend found_files $sub_dir_file
				}
			}
		}
	}

	return $found_files
}

proc derive_parameters_ctl {} {

    # set ifdef from checking parameter values
    if {$::param_array(CTL_ECC_ENABLED) == 1} {
        lappend ::ifdef_list "CTL_ECC_ENABLED"
    }
    if {$::param_array(CTL_HRB_ENABLED) == 1} {
        lappend ::ifdef_list "CTL_HRB_ENABLED"
    }
    if {$::param_array(CTL_ECC_AUTO_CORRECTION_ENABLED) == 1} {
        lappend ::ifdef_list "CTL_ECC_AUTO_CORRECTION_ENABLED"
    }
    if {$::param_array(CTL_ECC_CSR_ENABLED) == 1} {
        lappend ::ifdef_list "CTL_ECC_CSR_ENABLED"
    }
    if {$::param_array(CTL_CSR_ENABLED) == 1} {
        lappend ::ifdef_list "CTL_CSR_ENABLED"
    }
    if {$::param_array(CTL_ODT_ENABLED) == 1} {
        lappend ::ifdef_list "CTL_ODT_ENABLED"
    }
    if {$::param_array(CTL_REGDIMM_ENABLED) == 1} {
        lappend ::ifdef_list "CTL_REGDIMM_ENABLED"
    }
    if {$::param_array(CTL_OUTPUT_REGD) == 1} {
        lappend ::ifdef_list "CTL_OUTPUT_REGD"
    }
    if {$::param_array(CTL_USR_REFRESH_EN) == 1} {
        lappend ::ifdef_list "CTL_USR_REFRESH_EN"
    }
    if {$::param_array(MEM_IF_DQSN_EN) == 1} {
        lappend ::ifdef_list "MEM_IF_DQSN_EN"
    }
    if {[string compare $::param_array(MEM_TYPE) "DDR3"] == 0} {
        lappend ::ifdef_list "DDR3"
    }
    if {$::param_array(CTL_AUTOPCH_EN) == 1} {
        lappend ::ifdef_list "CTL_AUTOPCH_EN"
    }
    if {$::param_array(CTL_SELF_REFRESH_EN) == 1} {
        lappend ::ifdef_list "CTL_SELF_REFRESH_EN"
    }
	if {$::param_array(CTL_DEEP_POWERDN_EN) == 1} {
        lappend ::ifdef_list "CTL_DEEP_POWERDN_EN"
    }
    if {$::param_array(MEM_DLL_EN) == 1} {
        lappend ::ifdef_list "MEM_DLL_EN"
    }
}


# proc copy_file {srcdir outdir file_str} {
#     #copy all cleartext rtl files to project dir
#     set file_list [split $file_str ","]
# 
#     foreach srcfile ${file_list} {
#         set outstr [catch {exec cp ${srcdir}/${srcfile} ${outdir}/${srcfile}} temp_result]
#         #puts "SYNTHESIS_FILE:${outdir}/${::module_name}_${srcfile}"
#     }
# }

proc generate_rtl {srcdir outdir file_str inst_name debug_mode final_sub_dir fileset} {
    #copy all cleartext rtl files to project dir
    set file_list [split $file_str ","]
    set generated_list [list]

    foreach srcfile ${file_list} {

        if {$debug_mode} {
            catch {file copy -force ${srcdir}/${srcfile} ${outdir}/${srcfile}} temp_result
            lappend generated_list ${outdir}/${srcfile}
        } else {

			set src_file [open "${srcdir}/${srcfile}" r]
			set dest_file [open "${outdir}/${inst_name}_${srcfile}" w]

			while {[gets $src_file line] != -1} {
				regsub -all {alt_mem_ddrx_} $line ${inst_name}_& line
				regsub -all {altera_avalon_half_rate_bridge} $line ${inst_name}_& line
				if {[regexp -nocase {alt_mem_ddrx_controller_top.v} $srcfile] && [lsearch -exact $::ifdef_list "USE_MM_INTERFACE"] == -1} {
					regsub -all {`define USE_MM_INTERFACE} $line "" line
				}
				puts $dest_file $line
			}

			close $dest_file
			close $src_file

			lappend generated_list ${outdir}/${inst_name}_${srcfile}

		}
        if {$debug_mode} {
        	alt_mem_if::util::iptclgen::advertize_file {QUARTUS_SYNTH,SIM_VERILOG,SIM_VHDL,EXAMPLE_DESIGN} ${srcfile} ${outdir} ${final_sub_dir} $fileset $::is_sopc
		} else {
        	alt_mem_if::util::iptclgen::advertize_file {QUARTUS_SYNTH,SIM_VERILOG,SIM_VHDL,EXAMPLE_DESIGN} ${inst_name}_${srcfile} ${outdir} ${final_sub_dir} $fileset $::is_sopc
		}
	}
	return $generated_list
}

# ======================================================================================================

proc run_generate_ctl {module_name outdir param_str fileset} {

	set qdir $::env(QUARTUS_ROOTDIR)
	set ::inhdl_dir ${qdir}/../ip/altera/alt_mem_if/alt_mem_if_controllers/alt_mem_if_nextgen_ddr_controller_110/rtl
	set insdc_dir ${qdir}/../ip/altera/mem/ddrx/source/sdc
	set inexample_dir ${qdir}/../ip/altera/mem/ddrx/source/example_design

# output subdirs
set example_dir_str "example_project"
set rtl_dir_str ""

set exampledir "$outdir/${example_dir_str}"
set rtldir "$outdir/${rtl_dir_str}"

catch {file mkdir $outdir} temp_result
catch {file mkdir $rtldir} temp_result

append param_str ",MODULENAME=$module_name"
append param_str ",CORE_NAME=$module_name"
append param_str ",wrapper_name=$module_name"

#msg_vdebug "Parameter string is: $param_str"

set ifdef_param_list [split $param_str ","]
array set ::param_array [list]
set ::ifdef_list [list]
array set gen_file_array [list]

foreach param_pair $ifdef_param_list {
	set param_pair_list [split $param_pair "="]

	set param_name [lindex $param_pair_list 0]
	set param_val [lindex $param_pair_list 1]

	if {[string compare $param_val ""] == 0} {
		#No value, treat like an ifdef
		lappend ::ifdef_list $param_name
	} else {
		# SOPCb sends us the customer formatted name for the device
		# family, so we need to make it uniform for our matching
		if {[string compare -nocase $param_name "DEVICE_FAMILY"] == 0} {
			set param_val [string toupper $param_val]
			set param_val_out ""
			regsub -all "\[ \t\n\]+" $param_val "" param_val_out
			set param_val $param_val_out
		}

		array set ::param_array [list $param_name $param_val]
	}
}

derive_parameters_ctl

#set supported_ifdefs_str "CTL_ECC_ENABLED,CTL_HRB_ENABLED,CTL_ECC_AUTO_CORRECTION_ENABLED,CTL_ECC_CSR_ENABLED,CTL_CSR_ENABLED,CTL_ODT_ENABLED,CTL_REGDIMM_ENABLED,CTL_OUTPUT_REGD,CTL_USR_REFRESH_EN,MEM_IF_DQSN_EN,DDR3,CTL_AUTOPCH_EN,CTL_SELF_REFRESH_EN,CTL_DEEP_POWERDN_EN,MEM_DLL_EN"

# translate lists into strings
set ::ifdef_str [join $::ifdef_list ","]
set tmp_list [list]
foreach {name val} [array get ::param_array] {
	lappend tmp_list "${name}=${val}"
}
set ::param_str [join $tmp_list ","]

if {$::debug_mode} {
    set temp_param_list [join $tmp_list "\n"]
    puts "// In DEBUG mode\n"
    puts "// Parameter string is: $temp_param_list\n"
}

send_message "info" "Generating Controller HDL files"

#set hdl_file_list "alt_ddrx_addr_cmd.v,alt_ddrx_afi_block.v,alt_ddrx_avalon_if.v,alt_ddrx_clock_and_reset.v,alt_ddrx_cmd_queue.v,alt_ddrx_controller.v,alt_ddrx_csr.v,alt_ddrx_ddr2_odt_gen.v,alt_ddrx_ddr3_odt_gen.v,alt_ddrx_decoder.v,alt_ddrx_decoder_40.v,alt_ddrx_decoder_72.v,alt_ddrx_ecc.v,alt_ddrx_encoder.v,alt_ddrx_encoder_40.v,alt_ddrx_encoder_72.v,alt_ddrx_input_if.v,alt_ddrx_odt_gen.v,alt_ddrx_state_machine.v,alt_ddrx_wdata_fifo.v,altera_avalon_half_rate_bridge.v,alt_ddrx_cmd_gen.v,alt_ddrx_bank_timer.v,alt_ddrx_bank_timer_wrapper.v,alt_ddrx_bank_timer_info.v,alt_ddrx_rank_monitor.v,alt_ddrx_cache.v,alt_ddrx_bypass.v,alt_ddrx_timing_param.v"

if {$::debug_mode} { puts "DESTINATION DIR: ${rtldir}" }


set foundfiles [find_files ${::inhdl_dir} "*" ]
set generated_list [list]
foreach foundfile $foundfiles {
	set next_gen_dir [file dirname $foundfile]
	set next_gen_file [file tail $foundfile]
	lappend generated_list [generate_rtl $next_gen_dir ${rtldir} $next_gen_file $module_name $::debug_mode ${rtl_dir_str} $fileset]
}

# generate a dummy DAT file for non-niosii VCS simulation
if {[string compare -nocase $fileset "EXAMPLE_DESIGN"] == 0} {
	set dat_file_name "${module_name}.dat"
	catch {file mkdir $exampledir} temp_result
	set dat_file_path "${exampledir}/${dat_file_name}"
	set dat_file [open "${dat_file_path}" w]
	close $dat_file
	alt_mem_if::util::iptclgen::advertize_file EXAMPLE_DESIGN ${dat_file_name} ${exampledir} ${example_dir_str} $fileset $::is_sopc
}

}
