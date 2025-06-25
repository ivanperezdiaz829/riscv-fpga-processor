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


proc run_generate {mod_name outdir ifdef_param_str fileset} {

	set inhdl_dir "$::env(QUARTUS_ROOTDIR)/../ip/altera/altdq_dqs2"

	set is_vhdl [expr [string compare -nocase "SIM_VHDL" $fileset] == 0]


	append ifdef_param_str "," "WRAPPER_NAME=$mod_name"

	set ifdef_param_list [split $ifdef_param_str ","]
	array set ::param_array [list]
	set ::ifdef_list [list]

	foreach param_pair $ifdef_param_list {
		set param_pair_list [split $param_pair "="]

		set param_name [lindex $param_pair_list 0]
		set param_val [lindex $param_pair_list 1]

		if {[string compare $param_val ""] == 0} {
			lappend ::ifdef_list $param_name
		} else {
			if {[string compare -nocase $param_name "DEVICE_FAMILY"] == 0} {
				set param_val_upper [string toupper $param_val]
				set param_val_out ""
				regsub -all "\[ \t\]+" $param_val_upper "" param_val_out
				set param_val_good $param_val_out
				lappend ::ifdef_list $param_val_good
			}

			array set ::param_array [list $param_name $param_val]

			if {[string compare -nocase $param_val "true"] == 0} {
				lappend ::ifdef_list $param_name
			}
		}
	}

	set device_family $::param_array(DEVICE_FAMILY)

	if {[string compare -nocase $::param_array(USE_ABSTRACT_RTL) "true"] == 0 &&
	    [string compare -nocase $::param_array(USE_REAL_RTL) "true"] == 0} {
		_dprint 1 "real+abstract altdq_dqs2 requested"
		_dprint 1 "real+abstract altdq_dqs2 requested"
		lappend ::ifdef_list "DUAL_IMPLEMENTATIONS"
		set dual_implementations 1
	} elseif {[string compare -nocase $::param_array(USE_ABSTRACT_RTL) "true"] == 0} {
		_dprint 1 "abstract-only altdq_dqs2 requested"
		set dual_implementations 0
	} else {
		_dprint 1 "real-only altdq_dqs2 requested"
		set dual_implementations 0
	}

	set altdq_ifdef_list [list $device_family]

	if {[string compare -nocase $device_family "ARRIAIIGX"] == 0} {
		lappend ::ifdef_list "FAMILY_HAS_NO_DYNCONF"
		lappend altdq_ifdef_list "FAMILY_HAS_NO_DYNCONF"
	}

	if {[string compare -nocase $device_family "STRATIXIII"] == 0 || [string compare -nocase $device_family "STRATIXIV"] == 0 ||
	    [string compare -nocase $device_family "ARRIAIIGX"] == 0 || [string compare -nocase $device_family "ARRIAIIGZ"] == 0} {
		lappend ::ifdef_list "DDIO_3REG"
		lappend altdq_ifdef_list "DDIO_3REG"
		set ::param_array(HR_DDIO_OUT_HAS_THREE_REGS) "true"
	} else {
		set ::param_array(HR_DDIO_OUT_HAS_THREE_REGS) "false"
	}

	if {[string compare -nocase $::param_array(USE_OFFSET_CTRL) "true"] == 0} {
		lappend altdq_ifdef_list "USE_OFFSET_CTRL"
	}

	if {[string compare -nocase $::param_array(CONNECT_TO_HARD_PHY) "true"] == 0} {
		lappend altdq_ifdef_list "CONNECT_TO_HARD_PHY"
	}
	if {[string compare -nocase $::param_array(QUARTER_RATE_MODE) "true"] == 0} {
		lappend altdq_ifdef_list "QUARTER_RATE_MODE"
	}
	if {[string compare -nocase $::param_array(USE_SHADOW_REGS) "true"] == 0} {
		lappend altdq_ifdef_list "USE_SHADOW_REGS"
	}
	if {[string compare -nocase $::param_array(LPDDR2) "true"] == 0} {
		lappend altdq_ifdef_list "LPDDR2"
	}
	if {[string compare -nocase $::param_array(USE_EXTERNAL_WRITE_STROBE_PORTS) "true"] == 0} {
		lappend altdq_ifdef_list "USE_EXTERNAL_WRITE_STROBE_PORTS"
	}
	
	if {[string compare -nocase $device_family "STRATIXIII"] == 0 || [string compare -nocase $device_family "STRATIXIV"] == 0 ||
	    [string compare -nocase $device_family "ARRIAIIGX"] == 0 || [string compare -nocase $device_family "ARRIAIIGZ"] == 0} {
		set ::param_array(DQS_ENABLE_AFTER_T7) "true"
	} else {
		set ::param_array(DQS_ENABLE_AFTER_T7) "false"
	}

	
	set ::ifdef_str [join $::ifdef_list ","]
	set supported_ifdefs_str "USE_DQS_ENABLE,PIN_TYPE_BIDIR,PIN_TYPE_INPUT,PIN_TYPE_OUTPUT,PIN_HAS_INPUT,PIN_HAS_OUTPUT,USE_BIDIR_STROBE,USE_STROBE_N,USE_OUTPUT_STROBE,HAS_EXTRA_OUTPUT_IOS,USE_TERMINATION_CONTROL,USE_DYNAMIC_CONFIG,USE_DQS_ENABLE,ARRIAVGZ,STRATIXV,STRATIXIII,STRATIXIV,ARRIAIIGX,ARRIAIIGZ,ARRIAV,CYCLONEV,CONNECT_TO_HARD_PHY,QUARTER_RATE_MODE,FAMILY_HAS_NO_DYNCONF,USE_OCT_ENA_IN,USE_OUTPUT_STROBE_RESET,DDIO_3REG,USE_OFFSET_CTRL,DUAL_IMPLEMENTATIONS,USE_2X_FF,USE_DQS_TRACKING,USE_HARD_FIFOS,USE_DQSIN_FOR_VFIFO_READ,DUAL_WRITE_CLOCK,USE_SHADOW_REGS,LPDDR2,USE_EXTERNAL_WRITE_STROBE_PORTS,USE_CAPTURE_REG_EXTERNAL_CLOCKING,USE_READ_FIFO_EXTERNAL_CLOCKING"
	set module_list ""

	set rtl_dir ${outdir}

	catch {file mkdir $outdir} temp_result

	set basename "altdq_dqs2"
	if {[string compare -nocase $device_family "ARRIAV"] == 0 || [string compare -nocase $device_family "CYCLONEV"] == 0} {
		set basename "altdq_dqs2_acv"
	}
	set real_altdq_dqs2 [alt_mem_if::util::iptclgen::generate_outfile_name $basename $altdq_ifdef_list 1]






_iprint "real_altdq_dqs2: $real_altdq_dqs2"







	if {$dual_implementations} {
		set ::param_array(DEFAULT_IMPLEMENTATION_NAME) "altdq_dqs2_abstract"
		set ::param_array(SECOND_IMPLEMENTATION_NAME) "$real_altdq_dqs2"
	} elseif {[string compare -nocase $::param_array(USE_ABSTRACT_RTL) "true"] == 0} {
		set ::param_array(DEFAULT_IMPLEMENTATION_NAME) "altdq_dqs2_abstract"
	} else {
		set ::param_array(DEFAULT_IMPLEMENTATION_NAME) "$real_altdq_dqs2"
	}

	if {$::param_array(EXTRA_OUTPUT_WIDTH) == 0} {
		set ::param_array(INDEX_DIR_HACK) "to"
	} else {
		set ::param_array(INDEX_DIR_HACK) "downto"
	}

	set tmp_list [list]
	foreach {name val} [array get ::param_array] {
		lappend tmp_list "${name}=${val}"
	}
	set ::param_str [join $tmp_list ","]






	
	
	set non_encryp_simulators [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]

	if {[string compare -nocase $::param_array(USE_ABSTRACT_RTL) "true"] == 0} {
		set filename "altdq_dqs2_abstract.sv"
		if { $is_vhdl } {
			add_fileset_file $filename [::alt_mem_if::util::hwtcl_utils::get_file_type $filename 1 0] PATH [file join "abstract" $filename] $non_encryp_simulators
			add_fileset_file [file join mentor $filename] [::alt_mem_if::util::hwtcl_utils::get_file_type $filename 1 1] PATH [file join "mentor" "abstract" $filename] MENTOR_SPECIFIC
		} else {
			add_fileset_file $filename [::alt_mem_if::util::hwtcl_utils::get_file_type $filename 1 0] PATH [file join "abstract" $filename]
		}
		
		if {[string compare -nocase $device_family "ARRIAIIGZ"] == 0 ||
		    [string compare -nocase $device_family "STRATIXIII"] == 0 ||
		    [string compare -nocase $device_family "STRATIXIV"] == 0} {
			set family_l [string tolower $device_family]
			set filename "altdq_dqs2_cal_delays_presv_${family_l}.sv"
		} elseif {[string compare -nocase $device_family "ARRIAIIGX"] == 0} {
			set filename "altdq_dqs2_cal_delays_arriaiigx.sv"
		} elseif {[string compare -nocase $device_family "ARRIAVGZ"] == 0} {
			set filename "altdq_dqs2_cal_delays_arriavgz.sv"
		} elseif {[string compare -nocase $device_family "STRATIXV"] == 0} {
			set filename "altdq_dqs2_cal_delays_stratixv.sv"
		} else {
			_iprint "Unknown device family $device_family"
			set filename "altdq_dqs2_cal_delays_ERROR.sv"
		}
		if { $is_vhdl } {
			add_fileset_file "altdq_dqs2_cal_delays.sv" [::alt_mem_if::util::hwtcl_utils::get_file_type $filename 1 0] PATH [file join "abstract" $filename] $non_encryp_simulators
			add_fileset_file [file join mentor "altdq_dqs2_cal_delays.sv"] [::alt_mem_if::util::hwtcl_utils::get_file_type $filename 1 1] PATH [file join "mentor" "abstract" $filename] MENTOR_SPECIFIC
		} else {
			add_fileset_file "altdq_dqs2_cal_delays.sv" [::alt_mem_if::util::hwtcl_utils::get_file_type $filename 1 0] PATH [file join "abstract" $filename]
		}
	}

	if {[string compare -nocase $::param_array(USE_REAL_RTL) "true"] == 0} {
		if {[string compare -nocase $device_family "ARRIAV"] == 0 || [string compare -nocase $device_family "CYCLONEV"] == 0} {
			set filename "altdq_dqs2_acv.sv"
		}	else {
			set filename "altdq_dqs2.sv"
		}
		set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name $filename $altdq_ifdef_list]
		if { $is_vhdl } {
			add_fileset_file $generated_file [::alt_mem_if::util::hwtcl_utils::get_file_type $filename 1 0] PATH $generated_file $non_encryp_simulators
			add_fileset_file [file join mentor $generated_file] [::alt_mem_if::util::hwtcl_utils::get_file_type $filename 1 1] PATH [file join "mentor" $generated_file] MENTOR_SPECIFIC
		} else {
			add_fileset_file $generated_file [::alt_mem_if::util::hwtcl_utils::get_file_type $filename 1 0] PATH $generated_file
		}
	}

	if {[string compare -nocase $device_family "ARRIAIIGX"] == 0} {
		set filename "soft_hr_ddio_out.v"
		if { $is_vhdl } {
			add_fileset_file $filename [::alt_mem_if::util::hwtcl_utils::get_file_type $filename 1 0] PATH $filename $non_encryp_simulators
			add_fileset_file [file join mentor $filename] [::alt_mem_if::util::hwtcl_utils::get_file_type $filename 1 1] PATH [file join "mentor" $filename] MENTOR_SPECIFIC
		} else {
			add_fileset_file $filename [::alt_mem_if::util::hwtcl_utils::get_file_type $filename 1 0] PATH $filename
		}
	}


	if {$is_vhdl} {
		set ext "vhd"
	} else {
		set ext "v"
	}
	
	set wrapper_fname "wrapper"
	if {[string compare -nocase $device_family "ARRIAV"] == 0 || [string compare -nocase $device_family "CYCLONEV"] == 0} {
		set wrapper_fname "wrapper_acv"
	}
	
	set parsed_rtl_file [alt_mem_if::util::iptclgen::parse_hdl $mod_name $::ifdef_str ${inhdl_dir} $outdir "${wrapper_fname}.${ext}" $module_list $supported_ifdefs_str]
	alt_mem_if::util::iptclgen::sub_strings [file join $outdir $parsed_rtl_file] [file join $outdir ${mod_name}.${ext}] $::param_str
	set path [file join $outdir ${mod_name}.${ext}]

	add_fileset_file ${mod_name}.${ext} [::alt_mem_if::util::hwtcl_utils::get_file_type ${mod_name}.${ext} 1 0] PATH $path
	
	set output_rtl_file ${mod_name}.${ext}
	
	if {[string equal -nocase $::param_array(GENERATE_EXAMPLE_DESIGN) "true"]} {
		_iprint "Generating example design"
		set example_design_indir "$inhdl_dir/example_design"
		set example_design_outdir "$outdir/example_design"
		file mkdir $example_design_outdir
		
		set example_design_files [list "dllex.v" "octex.v" "pllex.qip" "pllex.v" "top.v"]
		if {[expr [lsearch $::ifdef_list USE_DYNAMIC_CONFIG] >= 0]} {
			if {[string compare -nocase $device_family "STRATIXV"] == 0 || [string compare -nocase $device_family "ARRIAVGZ"] == 0} {
				lappend example_design_files "config_controller.sv"
			} elseif {[string compare -nocase $device_family "ARRIAV"] == 0 || [string compare -nocase $device_family "CYCLONEV"] == 0} {
				lappend example_design_files "config_controller_acv.sv"
			}
		}
		foreach fname $example_design_files {
			if {[string match "*.v" $fname]} {
				_iprint "Parsing $fname..."
				set modname [string range $fname 0 [expr [string length $fname] - 3]]
				set parsed_file [alt_mem_if::util::iptclgen::parse_hdl $modname $::ifdef_str $example_design_indir $example_design_outdir $fname $module_list $supported_ifdefs_str]
				alt_mem_if::util::iptclgen::sub_strings [file join $example_design_outdir $parsed_file] [file join $example_design_outdir $fname] $::param_str
				set path [file join $example_design_outdir $fname]
			} else {
				set path [file join $example_design_indir $fname]
			}
			add_fileset_file "./example_design/$fname" VERILOG PATH $path
		}
		
		set is_input [expr [lsearch $::ifdef_list PIN_TYPE_INPUT] >= 0]
		set is_output [expr [lsearch $::ifdef_list PIN_TYPE_OUTPUT] >= 0]
		set is_bidir [expr [lsearch $::ifdef_list PIN_TYPE_BIDIR] >= 0]
	
		set qsf_file_name "top.qsf"
		set qsf_f [open [file join $outdir $qsf_file_name] w]
		puts $qsf_f "set_global_assignment -name FAMILY \"$device_family\" "
		puts $qsf_f "set_global_assignment -name TOP_LEVEL_ENTITY top "
		if {[expr [lsearch $::ifdef_list USE_DYNAMIC_CONFIG] >= 0]} {
			if {[string compare -nocase $device_family "STRATIXV"] == 0 || [string compare -nocase $device_family "ARRIAVGZ"] == 0} {
				puts $qsf_f "set_global_assignment -name SYSTEMVERILOG_FILE example_design/config_controller.sv"
			} elseif {[string compare -nocase $device_family "ARRIAV"] == 0 || [string compare -nocase $device_family "CYCLONEV"] == 0} {
				puts $qsf_f "set_global_assignment -name SYSTEMVERILOG_FILE example_design/config_controller_acv.sv"
			}
		}
		puts $qsf_f "set_global_assignment -name VERILOG_FILE example_design/top.v "
		puts $qsf_f "set_global_assignment -name VERILOG_FILE example_design/pllex.v "
		puts $qsf_f "set_global_assignment -name VERILOG_FILE example_design/octex.v "
		puts $qsf_f "set_global_assignment -name VERILOG_FILE example_design/dllex.v "
		if { $is_vhdl } {
			puts $qsf_f "set_global_assignment -name VHDL_FILE $output_rtl_file "
		} else {
			puts $qsf_f "set_global_assignment -name VERILOG_FILE $output_rtl_file "
		}
		puts $qsf_f "set_global_assignment -name SYSTEMVERILOG_FILE $real_altdq_dqs2.sv "
		if {$is_output} {
			set dq_pins "write_data_out"
		} elseif {$is_input} {
			set dq_pins "read_data_in"
		} elseif {$is_bidir} {
			set dq_pins "read_write_data_io"
		}
		puts $qsf_f "set_instance_assignment -name IO_STANDARD \"SSTL-15 CLASS I\" -to $dq_pins\[*\]"
		if {$is_input || $is_bidir} {
			puts $qsf_f "set_instance_assignment -name INPUT_TERMINATION \"PARALLEL 50 OHM WITH CALIBRATION\" -to $dq_pins\[*\]"
		}
		if {$is_output || $is_bidir} {
			puts $qsf_f "set_instance_assignment -name OUTPUT_TERMINATION \"SERIES 50 OHM WITH CALIBRATION\" -to $dq_pins\[*\]"
		}
	
		set bidir_strobe [expr [lsearch $::ifdef_list USE_BIDIR_STROBE] >= 0]
		set output_strobe [expr [lsearch $::ifdef_list USE_OUTPUT_STROBE] >= 0]
                set differential_output_strobe [expr [lsearch $::ifdef_list DIFFERENTIAL_OUTPUT_STROBE] >= 0]
                set differential_capture_strobe [expr [lsearch $::ifdef_list DIFFERENTIAL_CAPTURE_STROBE] >= 0]
                set differential_bidir_strobe [expr [lsearch $::ifdef_list USE_STROBE_N] >= 0]
		if {$bidir_strobe} {
                        if {$differential_bidir_strobe} {
			        puts $qsf_f "set_instance_assignment -name IO_STANDARD \"DIFFERENTIAL 1.5-V SSTL CLASS I\" -to strobe*_io"
                        } else {
			        puts $qsf_f "set_instance_assignment -name IO_STANDARD \"SSTL-15 CLASS I\" -to strobe*_io"
                        }
			puts $qsf_f "set_instance_assignment -name OUTPUT_TERMINATION \"SERIES 50 OHM WITHOUT CALIBRATION\" -to strobe*_io"
			puts $qsf_f "set_instance_assignment -name INPUT_TERMINATION \"PARALLEL 50 OHM WITH CALIBRATION\" -to strobe*_io"
		} else {
			if {$is_input || $is_bidir} {
                                if {$differential_capture_strobe} {
				        puts $qsf_f "set_instance_assignment -name IO_STANDARD \"DIFFERENTIAL 1.5-V SSTL CLASS I\" -to capture_strobe*_in"
                                } else {
				        puts $qsf_f "set_instance_assignment -name IO_STANDARD \"SSTL-15 CLASS I\" -to capture_strobe*_in"
                                }
				puts $qsf_f "set_instance_assignment -name INPUT_TERMINATION \"PARALLEL 50 OHM WITH CALIBRATION\" -to capture_strobe*_in"
			}
			if {$output_strobe} {
                                if {$differential_output_strobe} {
				        puts $qsf_f "set_instance_assignment -name IO_STANDARD \"DIFFERENTIAL 1.5-V SSTL CLASS I\" -to output_strobe*_out"
                                } else {
				        puts $qsf_f "set_instance_assignment -name IO_STANDARD \"SSTL-15 CLASS I\" -to output_strobe*_out"
                                }
				puts $qsf_f "set_instance_assignment -name OUTPUT_TERMINATION \"SERIES 50 OHM WITHOUT CALIBRATION\" -to output_strobe*_out"
			}
		}
		close $qsf_f

		add_fileset_file $qsf_file_name OTHER PATH [file join $outdir $qsf_file_name]
		
		_iprint "Generating Testbench"
		set testbench_files [list "dqsagent.sv" "dqsdriver.sv" "tb.v"]
		foreach fname $testbench_files {
			if {[string match "*.v" $fname]} {
				_iprint "Parsing $fname..."
				set modname [string range $fname 0 [expr [string length $fname] - 3]]
				set parsed_file [alt_mem_if::util::iptclgen::parse_hdl $modname $::ifdef_str $example_design_indir $example_design_outdir $fname $module_list $supported_ifdefs_str]
				alt_mem_if::util::iptclgen::sub_strings [file join $example_design_outdir $parsed_file] [file join $example_design_outdir $fname] $::param_str
				set path [file join $example_design_outdir $fname]
			} else {
				set path [file join $example_design_indir $fname]
			}
			add_fileset_file "./example_design/$fname" VERILOG PATH $path
		}
		
		set microcode_file_in "_UNDEFINED_"
		if { $is_input } {
			set microcode_file_in "dqsdriver_microcode_input.sv"
		} elseif { $is_output } {
			set microcode_file_in "dqsdriver_microcode_output.sv"
		} elseif { $is_bidir } {
			set microcode_file_in "dqsdriver_microcode_bidir.sv"
		}
		
		set microcode_file_out "dqsdriver_microcode.sv"
		set path [file join $example_design_indir $microcode_file_in]
		add_fileset_file "./example_design/$microcode_file_out" VERILOG PATH $path

		_iprint "Generating Simulation Makefile"
		set file_name "Makefile"
		set makefile_f [open [file join $outdir $file_name] w]
		puts $makefile_f "VCS_OPT=\"\""
		puts $makefile_f "QUARTUS_LIB_SOURCE_FILES = \\"
		puts $makefile_f "\t\${QUARTUS_ROOTDIR}/eda/sim_lib/altera_mf.v \\"
		puts $makefile_f "\t\${QUARTUS_ROOTDIR}/eda/sim_lib/altera_lnsim.sv \\"
		puts $makefile_f "\t\${QUARTUS_ROOTDIR}/eda/sim_lib/220model.v \\"
		puts $makefile_f "\t\${QUARTUS_ROOTDIR}/eda/sim_lib/sgate.v \\"
		puts $makefile_f "\t\${QUARTUS_ROOTDIR}/eda/sim_lib/altera_primitives.v \\"
		puts $makefile_f "\t\${QUARTUS_ROOTDIR}/eda/sim_lib/[string tolower $device_family]_atoms.v \\"
		puts $makefile_f "\t\${QUARTUS_ROOTDIR}/eda/sim_lib/synopsys/[string tolower $device_family]_atoms_ncrypt.v"
		puts $makefile_f ""
		puts $makefile_f "OUTPUT_RTL_FILE = \\"
		puts $makefile_f "\t$output_rtl_file \\" 
		puts $makefile_f ""
		puts $makefile_f "SOURCE_FILES = \\"
		puts $makefile_f "\t$real_altdq_dqs2.sv \\"
		puts $makefile_f "\t./example_design/dllex.v \\" 
		puts $makefile_f "\t./example_design/octex.v \\" 
		puts $makefile_f "\t./example_design/pllex.v \\"
		if {[expr [lsearch $::ifdef_list USE_DYNAMIC_CONFIG] >= 0]} {
			if {[string compare -nocase $device_family "STRATIXV"] == 0 || [string compare -nocase $device_family "ARRIAVGZ"] == 0} {
				puts $makefile_f "\t./example_design/config_controller.sv \\"
			} elseif {[string compare -nocase $device_family "ARRIAV"] == 0 || [string compare -nocase $device_family "CYCLONEV"] == 0} {
				puts $makefile_f "\t./example_design/config_controller_acv.sv \\"
			}
		}
		puts $makefile_f "\t./example_design/dqsdriver.sv \\"
		puts $makefile_f "\t./example_design/dqsagent.sv \\"
		puts $makefile_f "\t./example_design/top.v \\"
		puts $makefile_f "\t./example_design/tb.v"
		puts $makefile_f ""
		puts $makefile_f "TB_MODULE=tb"
		puts $makefile_f ""
		puts $makefile_f "all : simulate"
		puts $makefile_f ""
		puts $makefile_f "lib :"
		puts $makefile_f "\tvlogan -timescale=1ps/1ps -sverilog \${QUARTUS_LIB_SOURCE_FILES} | tee mylog.lib.txt"
		puts $makefile_f ""
		puts $makefile_f "compile : lib"
		puts $makefile_f "\tvlogan -timescale=1ps/1ps -sverilog \${SOURCE_FILES} | tee mylog.comp.txt"
		if { $is_vhdl } {
			puts $makefile_f "\tvhdlan $output_rtl_file | tee -a mylog.comp.txt"
		} else {
			puts $makefile_f "\tvlogan -timescale=1ps/1ps -sverilog $output_rtl_file | tee -a mylog.comp.txt"
		}
		puts $makefile_f ""
		puts $makefile_f "VCS_GUI_OPTION="
		puts $makefile_f "# VCS_GUI_OPTION=-gui"
		puts $makefile_f "elaborate: compile"
		puts $makefile_f "\tvcs +vcs+lic+wait \${VCS_GUI_OPTION} -debug_pp \${TB_MODULE} | tee mylog.elab.txt"
		puts $makefile_f ""
		puts $makefile_f "simulate: elaborate"
		puts $makefile_f "\t./simv -l vcsout.txt "
		puts $makefile_f ""
		puts $makefile_f "clean : "
		puts $makefile_f "\trm -rf AN.DB DVEfiles csrc simv.daidir inter.vpd session.inter.vpd.tcl simv ucli.key .vcsmx_rebuild vcslog.txt reg.rout *.html *.gz reg_result.xml pass fail *.txt simv.vdb"

		close $makefile_f
		add_fileset_file $file_name OTHER PATH [file join $outdir $file_name]
		
		_iprint "Generating Simulation Makefile"
		set file_name_mf "Makefile_modelsim"
		set makefile_mf [open [file join $outdir $file_name_mf] w]
		puts $makefile_mf "VCS_OPT=\"\""
		puts $makefile_mf "QUARTUS_LIB_SOURCE_FILES = \\"
		puts $makefile_mf "\t\${QUARTUS_ROOTDIR}/eda/sim_lib/altera_mf.v \\"
		puts $makefile_mf "\t\${QUARTUS_ROOTDIR}/eda/sim_lib/altera_lnsim.sv \\"
		puts $makefile_mf "\t\${QUARTUS_ROOTDIR}/eda/sim_lib/220model.v \\"
		puts $makefile_mf "\t\${QUARTUS_ROOTDIR}/eda/sim_lib/sgate.v \\"
		puts $makefile_mf "\t\${QUARTUS_ROOTDIR}/eda/sim_lib/altera_primitives.v \\"
		puts $makefile_mf "\t\${QUARTUS_ROOTDIR}/eda/sim_lib/[string tolower $device_family]_atoms.v \\"
		puts $makefile_mf "\t\${QUARTUS_ROOTDIR}/eda/sim_lib/mentor/[string tolower $device_family]_atoms_ncrypt.v"
		puts $makefile_mf ""
		puts $makefile_mf "SOURCE_FILES = \\"
		puts $makefile_mf "\t$real_altdq_dqs2.sv \\"
		puts $makefile_mf "\t$output_rtl_file \\" 
		puts $makefile_mf "\t./example_design/dllex.v \\" 
		puts $makefile_mf "\t./example_design/octex.v \\" 
		puts $makefile_mf "\t./example_design/pllex.v \\"
		if {[expr [lsearch $::ifdef_list USE_DYNAMIC_CONFIG] >= 0]} {
			if {[string compare -nocase $device_family "STRATIXV"] == 0 || [string compare -nocase $device_family "ARRIAVGZ"] == 0} {
				puts $makefile_mf "\t./example_design/config_controller.sv \\"
			} elseif {[string compare -nocase $device_family "ARRIAV"] == 0 || [string compare -nocase $device_family "CYCLONEV"] == 0} {
				puts $makefile_mf "\t./example_design/config_controller_acv.sv \\"
			}
		}
		puts $makefile_mf "\t./example_design/dqsdriver.sv \\"
		puts $makefile_mf "\t./example_design/dqsagent.sv \\"
		puts $makefile_mf "\t./example_design/top.v \\"
		puts $makefile_mf "\t./example_design/tb.v"
		puts $makefile_mf ""
		puts $makefile_mf "TB_MODULE=tb"
		puts $makefile_mf ""
		puts $makefile_mf "all : simulate"
		puts $makefile_mf "simulate: all"
		puts $makefile_mf "\tvlib rtl_work"
		puts $makefile_mf "\tvmap work rtl_work"
		puts $makefile_mf "\tvlog -sv -work work \${QUARTUS_LIB_SOURCE_FILES} | tee msim_compile_libs.txt"
		puts $makefile_mf "\tvlog -sv -work work \${SOURCE_FILES} | tee msim_compile_source.txt"
		puts $makefile_mf "\tvsim -c work.tb -do \"run -a\" -l modelsimout.txt" 
		close $makefile_mf
		add_fileset_file $file_name_mf OTHER PATH [file join $outdir $file_name_mf]

	}
}
