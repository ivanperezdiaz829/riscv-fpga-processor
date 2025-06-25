# +----------------------------------------------------------
# | 
# | Name: sopc_mwizc.tcl
# |
# | Description: Common *_hw.tcl code for the integration 
# | 		 of the Altera megafunctions with the SOPC
# | 		 Builder environemnet
# |
# | Version: 1.0
# |
# | Avalon-compatible Altera PLL module
# |
# +----------------------------------------------------------
	

# +-----------------------------------
# | Global/Fixed Module Parameters
# | 
# +-----------------------------------
#
# Nothing for now


# +-----------------------------------
# | Global Constants
# |

set XML_EXT 			".xml"
set TCL_EXT 			".tcl"
set VHDL_HDL_EXT 		".vhd"
set VERILOG_HDL_EXT 		".v"
set VHDL_HDL_LANG_NAME 		"VHDL"
set PATH_SEP 			"/"
set PARAM_INFIX 		"#"
set CBX_PFX  			"cbx_"

set CONST_PARAMS_HASH_KEY 	"CT"
set PRIV_PARAMS_HASH_KEY 	"PT"
set USED_PORTS_HASH_KEY 	"UP"
set IS_NUMERIC_HASH_KEY 	"IN"
set MF_PORTS_HASH_KEY 		"MF"
set IF_PORTS_HASH_KEY 		"IF"

set UNUSED_PORT_ID 		"UNUSED_PORT"

set MY_DEBUG 			0
set MY_INFO 			1

set MAX_ERROR_COUNT 10

# | 
# +-----------------------------------



# +-----------------------------------
# | Hidden Parameter Declarations
# |

set HIDDEN_CONSTANTS "HIDDEN_CONSTANTS"
set HIDDEN_PRIVATES "HIDDEN_PRIVATES"
set HIDDEN_USED_PORTS "HIDDEN_USED_PORTS"
set HIDDEN_IS_NUMERIC "HIDDEN_IS_NUMERIC"
set HIDDEN_MF_PORTS "HIDDEN_MF_PORTS"
set HIDDEN_IF_PORTS "HIDDEN_IF_PORTS"

set HIDDEN_HASH_PARAMS_LIST 	[ list $HIDDEN_CONSTANTS 	$HIDDEN_PRIVATES   	$HIDDEN_USED_PORTS  	$HIDDEN_IS_NUMERIC 	$HIDDEN_MF_PORTS $HIDDEN_IF_PORTS ]
set HIDDEN_HASH_TCL_IDS 	[ list "const_params"   	"private_params"  	"used_ports"       	"is_numeric" "mf_ports" "intrfc_port" ]
set HIDDEN_HASH_PARAMS_PREFIX 	[ list $CONST_PARAMS_HASH_KEY 	$PRIV_PARAMS_HASH_KEY 	$USED_PORTS_HASH_KEY 	$IS_NUMERIC_HASH_KEY		$MF_PORTS_HASH_KEY $IF_PORTS_HASH_KEY ]

set HIDDEN_SINGLE_VARS 		[ list HIDDEN_IS_FIRST_EDIT HIDDEN_CUSTOM_ELABORATION HIDDEN_CUSTOM_POST_EDIT]
set ALL_HIDDEN_PARAMS 		[ concat $HIDDEN_HASH_PARAMS_LIST $HIDDEN_SINGLE_VARS ]

# | 
# +-----------------------------------

set g_logid ""
set g_log_debug 0


# ============================================================
#			Utility Routines
# ============================================================
# ----------------------------------------------------
# |
# |  assert_debug
# |
# |  Prints a debug message
# |  when MY_DEBUG is set to 1  
# ----------------------------------------------------
proc assert_debug { msg } {
	
	global MY_DEBUG
	if {$MY_DEBUG == 1} {
		send_message info $msg
	}
}


# ----------------------------------------------------
# |
# |  assert_info
# |
# |  Prints an info message
# |  when MY_INFO is set to 1  
# ----------------------------------------------------
proc assert_info { msg } {
	
	global MY_INFO
	if {$MY_INFO == 1} {
		send_message info $msg
	}
}


# ----------------------------------------------------
# |  
# |  create_unique_id
# |
# |  Uses a combination of CPU ticks and current 
# |  time (which has a resolution of 1 sec) to 
# |  create a unique id 
# ----------------------------------------------------
proc create_unique_id { } {

	set myid   [ expr { pow(2,31)+[clock clicks] } ]
	set begin  [ expr { [ string length $myid ] -8 } ]
	set end	   [ expr { [ string length $myid ] -3 } ]
	set myid   [ string range $myid $begin $end ]
	set myid   [ clock seconds ]$myid

	return $myid
}

# ----------------------------------------------------
# |  
# |  process_exec_exit_status
# |
# |  Processes the combination pf the exit code 
# |  returned from a run of the qmegawiz executable
# |  and the gloabl $::errorCode to determine what
# |  occurred in the qmegawiz run
# |  
# ----------------------------------------------------
proc process_exec_exit_status { status } { 

	set error_code $::errorCode
	
	if { $status == 0 } {
		
		# The command succeeded, and wrote nothing to stderr.
		# $result contains what it wrote to stdout, unless it was redirected

	} elseif { [string equal $error_code NONE] } {
	
		# The command exited with a normal status, but wrote something
		# to stderr, which is included in $result.
	} else {
		
		switch -exact -- [lindex $error_code 0] {

			CHILDKILLED {
				foreach { - pid sigName msg } $error_code break
					# A child process, whose process ID was $pid,
					# died on a signal named $sigName.  A human-
					# readable message appears in $msg.
			    }
		
			    CHILDSTATUS {
				foreach { - pid code } $error_code break
				# A child process, whose process ID was $pid,
				# exited with a non-zero exit status, $code.
			    }
				
			    CHILDSUSP {
				foreach { - pid sigName msg } $error_code break
				# A child process, whose process ID was $pid,
				# has been suspended because of a signal named
				# $sigName.  A human-readable description of the
				# signal appears in $msg.
			    }
		
			    POSIX {
				foreach { - errName msg } $error_code break
				# One of the kernel calls to launch the command
				# failed.  The error code is in $errName, and a
				# human-readable message is in $msg.
	    	}
	 	}
   }
}

# ----------------------------------------------------
# |  
# |  process_cbx_exec_exit_status
# |
# |  Processes the combination pf the exit code 
# |  returned from a run of the clearbox executable
# |  and the gloabl $::errorCode to determine what
# |  occurred in the clearbox run
# |  
# ----------------------------------------------------
proc process_cbx_exec_exit_status { status } { 

# clearbox return code of 0, 3 & 4 are Successful

	set error_code $::errorCode
	set return_code 1
	
	if { $status == 0 } {
		
		# The command succeeded, and wrote nothing to stderr.
		# $result contains what it wrote to stdout, unless it was redirected
		set return_code 0

	} elseif { [string equal $error_code NONE] } {
	
		# The command exited with a normal status, but wrote something
		# to stderr, which is included in $result.
		set return_code 0

	} else {
		
		switch -exact -- [lindex $error_code 0] {

			CHILDKILLED {
				foreach { - pid sigName msg } $error_code break
					# A child process, whose process ID was $pid,
					# died on a signal named $sigName.  A human-
					# readable message appears in $msg.
			}
		
			CHILDSTATUS {
				foreach { - pid code } $error_code {
				# A child process, whose process ID was $pid,
				# exited with a non-zero exit status, $code.
					if { $code==3 || $code==4 } {
						set return_code 0
			   	}
				}
			}
				
			CHILDSUSP {
				foreach { - pid sigName msg } $error_code break
				# A child process, whose process ID was $pid,
				# has been suspended because of a signal named
				# $sigName.  A human-readable description of the
				# signal appears in $msg.
			}
		
			POSIX {
				foreach { - errName msg } $error_code break
				# One of the kernel calls to launch the command
				# failed.  The error code is in $errName, and a
				# human-readable message is in $msg.
	    	}
	 	}
   }
	return $return_code
}


# ----------------------------------------------------
# |  
# |  get_hdl_extension
# |
# |  Returns the extension string for the
# |  specified HDL language
# |  
# ----------------------------------------------------
proc get_hdl_extension { language } {

	global VHDL_HDL_LANG_NAME
	global VHDL_HDL_EXT
	global VERILOG_HDL_EXT
	
	set hdl_ext "" 
	
	if { [string match ${VHDL_HDL_LANG_NAME} [string toupper $language] ] == 1} {
		
		append hdl_ext ${VHDL_HDL_EXT}
	} else {
		
		append hdl_ext ${VERILOG_HDL_EXT}
	}

	return $hdl_ext
}


# ----------------------------------------------------
# |  
# |  delete_from_list
# |
# |  Removes a (string) entry from a given list
# |  
# ----------------------------------------------------
proc delete_from_list {input_list deleted_entry } {
	
    	set indx [lsearch -exact $input_list $deleted_entry]
    	return [lreplace $input_list $indx $indx]
}


# ----------------------------------------------------
# |  
# |  get_non_prefixed_param_name
# |
# |  Removes the prefix part of a (hash table) 
# |  parameter name that is of the form
# |
# |  prefix[PARAM_INFIX]remaing
# |  
# |  and returns the remianing part
# | 
# ----------------------------------------------------
proc get_non_prefixed_param_name { prefixed_param_name } {
	
	global PARAM_INFIX
	
	set split_prefixed_parname [split $prefixed_param_name $PARAM_INFIX ]
	set parname [lindex $split_prefixed_parname 1]
	
	return $parname
}


# ----------------------------------------------------
# |  
# |  delete_files
# |
# |  Removes the prefix part of a (hash table) 
# |  parameter name that is of the form
# |
# |  prefix[PARAM_INFIX]remaing
# |  
# |  and returns the remianing part
# | 
# ----------------------------------------------------
proc delete_files { file_name_pattern } {
	
	set file_list [glob -nocomplain $file_name_pattern]
	foreach file_name $file_list {
		set try 1
		set errcount 0
		while { $try } {
			if [catch { file delete -force $file_name } err ] {
				incr errcount 1
				if { $errcount > 20} {
					set try 0
				}
				after 1000
			} else {
				#write_to_log "Deleted $file_name in $errcount tries"
				set try 0
			}
		}
	}
}

# ----------------------------------------------------
# |  
# |  get_work_directory
# |
# |  Get a scratch pad directory in which to place
# |  temp files
# |
# ----------------------------------------------------
proc get_work_directory {} {

	global PATH_SEP
	global WIZARD_NAME
	global MAX_ERROR_COUNT
	global env

	set error_count 0
	set create_dir 1

	if {[info exists env(TMP)] && [string match "" $env(TMP)] != 1 } {
		set base_work_dir $env(TMP)${PATH_SEP}sopc_${WIZARD_NAME}
	} elseif { [info exists env(HOME)] &&  [string match "" $env(HOME)] != 1 } {
		set base_work_dir $env(HOME)${PATH_SEP}sopc_${WIZARD_NAME}
	} else {
		set base_work_dir [pwd]${PATH_SEP}sopc_${WIZARD_NAME}
	}
	set base_work_dir [string map { \\ / } $base_work_dir]

	while { $create_dir } {
		set work_dir ${base_work_dir}[create_unique_id]
		#if [catch {close [open ${work_dir}${PATH_SEP}start {RDWR CREAT EXCL}]} err] {
			#incr error_count 1
		#} else {
			#set create_dir 0
		#}
		if { [ file exists $work_dir ] == 0 } {
			if [ catch {file mkdir $work_dir} err ] {
				incr error_count 1
			} else {
				set create_dir 0
			}
		} else {
			incr error_count 1
		}
		if { $error_count > $MAX_ERROR_COUNT } {
			set create_dir 0
			set work_dir ""
			send_message error "Could not create a temporary work directory"
			send_message error "Please make sure that one of TMP, TEMP or HOME environment variables is set and that the directory is writable"
		}
	}
	return $work_dir
}


# ============================================================
#			Auxiliary Routines
# ============================================================
# ----------------------------------------------------
# |  
# |  update_sopc_params_from_hidden_params
# |
# |  
# |  
# ----------------------------------------------------
proc update_sopc_params_from_hidden_params { hidden_params_hash } {
	

	global ALL_HIDDEN_PARAMS
	global HIDDEN_CONSTANTS 
	
	upvar $hidden_params_hash hidden_params	
	
	set param_list [get_parameters]

	# Remove hidden parameters from the (i)module parameters list
	foreach hidden_param $ALL_HIDDEN_PARAMS {
		
		set param_list [delete_from_list $param_list $hidden_param]
	}

	set hidden_constants [get_parameter_value $HIDDEN_CONSTANTS]
	foreach { hidden_param_name hidden_param_value } $hidden_constants {
		
		set real_hidden_param_name [ get_non_prefixed_param_name $hidden_param_name ]
		if { [lsearch $param_list $real_hidden_param_name] != -1 } {

			set_parameter_value $real_hidden_param_name $hidden_param_value
		}
	}
}


# ----------------------------------------------------
# |  
# |  construct_command_line_args
# |
# |  Go through all (i)module parameters and add them to an array
# |  However, if a parameter value is now "", treat it as if the 
# |  parameter has never been assigned and do not pass that parameter
# |  to the command line. 
# |
# |  The reason for the above is as follows:
# |  When we run the wizard, the set of parameters it dumps out
# |  into the xmout/tclout files is usually a small subset of the
# |  total set of SOPC/scripting exposed parameters. Hence, if we
# |  blindly use the diff between name/value of the SOPC (i)module
# |  parameters and the hidden ones to determine which parameter=value
# |  pair gets to be passed on the command line, we will potentially
# |  pass a large number of parameters that may have nothing to do with
# |  the current state (as saved in the hidden params), or the device family.
# |  To alleviate this problem, will initially assign all SOPC parameters
# |  to have a value of "". Any parameter that gets updated through the
# |  elaboration/edit/validation will get a non-"" value, and we will
# |  not pass those params that currently have a "" value. On the otehr
# |  hand, when a parameter that currently has a non-"" value is not present
# |  in the hidden parameters returned from elaboration, etc., we will
# |  revert its value back to "" 
# |  
# ----------------------------------------------------
proc construct_command_line_args { sopc_module_params_hash hidden_params_hash } {

	global UNUSED_PORT_ID
	global HIDDEN_SINGLE_VARS
	
	upvar $sopc_module_params_hash sopc_params
	upvar $hidden_params_hash hidden_params

	array set arr {}

	foreach {par_name par_val} [array get sopc_params] {
		
		set is_custom_cb [ lsearch $HIDDEN_SINGLE_VARS $par_name ]
		if { $is_custom_cb == -1 } {
			set sc_par_val [string trim $par_val]
			set sc_par_val [string tolower $sc_par_val]
		
			if { $par_val != "" || $sc_par_val == $UNUSED_PORT_ID } {
	
				set arr([string tolower $par_name]=$par_val) 1
			}
		}
	}

	foreach {par_name par_val} [array get hidden_params] {
		
		set real_param_name [ get_non_prefixed_param_name $par_name ]
		set name_value_pair_id [string tolower $real_param_name]=$par_val
	
		if { [info exists arr($name_value_pair_id)] } {

			unset arr($name_value_pair_id)
		}
	}

	foreach {par_name par_val} [] {

		set arr([string tolower $par_name],$par_val) 1
	}
	
	return [array names arr]
}



# ----------------------------------------------------
# |  
# |  write_xml_out
# |
# |  Write out an XML file based on the exposed
# |  and hidden parameters to be used by the '-xmlin'
# |  mode of operation of qmegawiz
# |  
# ----------------------------------------------------
proc write_xml_out { hidden_params_hash xml_file } {
	
	global CONST_PARAMS_HASH_KEY
	global PRIV_PARAMS_HASH_KEY
	global USED_PORTS_HASH_KEY
	global IS_NUMERIC_HASH_KEY
	global PARAM_INFIX
	
	upvar $hidden_params_hash params_hash
	
	if [ catch {open $xml_file w} fid ] {
		
		send_message error "Couldn't open $xml_file for writing: $fid"
	} else {

		puts $fid "<?xml version=\"1.0\" ?>"
		puts $fid "<TOP_LEVEL_CNX_ELEMENT>"
		
		if [array exists params_hash] {
			
			# Write out the constants
			set conts_value_pairs [array get params_hash ${CONST_PARAMS_HASH_KEY}${PARAM_INFIX}*]
			foreach {name value} $conts_value_pairs {
				
				set no_prefixed_name [get_non_prefixed_param_name $name ]
				puts $fid "<CONSTANT NAME=\"$no_prefixed_name\" VALUE=\"$value\"/>"
			}
			
			# Write out the privates
			set privs_value_pairs [array get params_hash ${PRIV_PARAMS_HASH_KEY}${PARAM_INFIX}*]
			foreach {name value} $privs_value_pairs {
				
				set no_prefixed_name [get_non_prefixed_param_name $name ]
				puts $fid "<PRIVATE NAME=\"$no_prefixed_name\" VALUE=\"$value\"/>"
			}
			
			# Write out the used ports
			set used_ports_value_pairs [array get params_hash ${USED_PORTS_HASH_KEY}${PARAM_INFIX}*]
			foreach {name value} $used_ports_value_pairs {
				
				set no_prefixed_name [get_non_prefixed_param_name $name ]
				puts $fid "<USED_PORT> <PORT NAME=\"$no_prefixed_name\"/> </USED_PORT>"
			}
		}
		
		puts $fid "</TOP_LEVEL_CNX_ELEMENT>"
		close $fid
	}
}


# ----------------------------------------------------
# |  
# |  read_sopc_module_params_into_hash
# |
# |  Get the exposed (i)module parameters by reading
# |  all the parameters and removing the hidden ones
# |  and then writing them into the provided hash table
# |  
# |  If run_test is passed as true, a debug dump
# |  of the parameters being added will be printed
# |
# ----------------------------------------------------
proc read_sopc_module_params_into_hash { sopc_param_hash { run_test "false" } } {
		
	global ALL_HIDDEN_PARAMS
	
	# Get all (i)module parameters
	set param_list [get_parameters]
	
	# Remove hidden parameters from the (i)module parameters list
	foreach hidden_param $ALL_HIDDEN_PARAMS {
		set param_list [delete_from_list $param_list $hidden_param]
	}

	# Now enter the remaining ones into the provided array 
	foreach param $param_list {
		upvar 1 $sopc_param_hash param_hash
		set param_hash($param) [get_parameter_value $param]
		
		if { $run_test == "true" } {

			assert_info "${param} was stored in the hash"
		}
	}
}


# ----------------------------------------------------
# |  
# |  read_sopc_hidden_params_into_hash
# |
# |  Get the hidden (i)module parameters write
# |  them into the provided hash table
# |  
# |  If run_test is passed as true, a debug dump
# |  of the parameters being added will be printed
# |
# ----------------------------------------------------
proc read_sopc_hidden_params_into_hash { hidden_params_hash { run_test "false" } } {

	global HIDDEN_HASH_PARAMS_LIST
	
	upvar $hidden_params_hash params_hash

	# Concatenate all hidden hash parameters to make the complete hidden parameter values list
	set complete_hidden_params_list [list]
	foreach hidden_param $HIDDEN_HASH_PARAMS_LIST {
		
		set complete_hidden_params_list [concat $complete_hidden_params_list [get_parameter_value $hidden_param]]

		if { $run_test == "true" } {

			assert_info "The ${hidden_param} hidden param was stored in the hash"
		}
	}	

	array set params_hash $complete_hidden_params_list
}

# ----------------------------------------------------
# |  
# |  read_one_sopc_hidden_param_into_hash
# |
# |  Get the specific hidden (i)module parameter write
# |  it into the provided hash table
# |  
# |  If run_test is passed as true, a debug dump
# |  of the parameters being added will be printed
# |
# ----------------------------------------------------
proc read_one_sopc_hidden_param_into_hash { hidden_params_hash hidden_param_name { run_test "false" } } {

	upvar $hidden_params_hash params_hash

	set complete_hidden_params_list [get_parameter_value $hidden_param_name]

	if { $run_test == "true" } {

		assert_info "The ${hidden_param} hidden param was stored in the hash"
	}

	array set params_hash $complete_hidden_params_list
		
}

# ----------------------------------------------------
# |  
# |  update_sopc_hidden_params
# |
# |  
# |  
# ----------------------------------------------------
proc update_sopc_hidden_params { hidden_params_hash } {

	global HIDDEN_HASH_PARAMS_LIST
	global HIDDEN_HASH_PARAMS_PREFIX
	global PARAM_INFIX
	
	upvar $hidden_params_hash hidden_hash
	
	foreach {hidden_hash_var} $HIDDEN_HASH_PARAMS_LIST {hidden_param_prefix} $HIDDEN_HASH_PARAMS_PREFIX {

		set_parameter_value $hidden_hash_var  [array get hidden_hash ${hidden_param_prefix}${PARAM_INFIX}*]
	}

}


# ----------------------------------------------------
# |  
# |  put_tclout_data_in_hash
# |
# |  
# |  
# ----------------------------------------------------
proc put_tclout_data_in_hash { tclout_hash hash_key hidden_params_hash { run_test "false" } } {
	
	upvar $tclout_hash tcl_hash
	upvar $hidden_params_hash params_hash

	global PARAM_INFIX
	
	if { [array exists tcl_hash] == 1 } {
		
		array set params_hash {}
		foreach index [array names tcl_hash] {
			
			set params_hash($hash_key$PARAM_INFIX$index) $tcl_hash($index)
			
			if { $run_test == "true" } {
				
				assert_info "tcl_hash($index) was assigned to key ${hash_key}${PARAM_INFIX}${index}" 
			}
		}
	}
}


# ----------------------------------------------------
# |  
# |  store_tclout_data_into_hashes
# |
# |  
# |  
# ----------------------------------------------------
proc store_tclout_data_into_hashes { hidden_params_hash tcl_file { run_test "false" } } {
	
	global HIDDEN_HASH_TCL_IDS
	global HIDDEN_HASH_PARAMS_PREFIX
	
	upvar $hidden_params_hash hidden_hash
	
	if { [catch {source $tcl_file} err] } {
		send_message error "Error while sourcing $tcl_file: $err"
		send_message error  "$::errorInfo"
	} else {
		foreach {tcl_hash_ident} $HIDDEN_HASH_TCL_IDS {hidden_param_prefix} $HIDDEN_HASH_PARAMS_PREFIX {
			put_tclout_data_in_hash $tcl_hash_ident $hidden_param_prefix hidden_hash $run_test
		}
	}
}

# ----------------------------------------------------
# |  
# |  get_private_parameter
# |
# |  
# |  
# ----------------------------------------------------
proc get_private_parameter { param_name } {

	global PRIV_PARAMS_HASH_KEY
	global PARAM_INFIX
	global HIDDEN_PRIVATES
	array set hidden_privates {}

	read_one_sopc_hidden_param_into_hash hidden_privates $HIDDEN_PRIVATES
	set key $PRIV_PARAMS_HASH_KEY$PARAM_INFIX$param_name
	return $hidden_privates($key)

}

# ----------------------------------------------------
# |  
# |  set_ifport_parameter
# |
# |  
# |  
# ----------------------------------------------------
proc set_ifport_parameter { param_name param_value } {

	global IF_PORTS_HASH_KEY
	global PARAM_INFIX

	set key $IF_PORTS_HASH_KEY$PARAM_INFIX$param_name
	set_hidden_parameter $key $param_value
}

# ----------------------------------------------------
# |  
# |  set_constant_parameter
# |
# |  
# |  
# ----------------------------------------------------
proc set_constant_parameter { param_name param_value } {

	global CONST_PARAMS_HASH_KEY
	global PARAM_INFIX

	set key $CONST_PARAMS_HASH_KEY$PARAM_INFIX$param_name
	set_hidden_parameter $key $param_value
}

# ----------------------------------------------------
# |  
# |  set_hidden_parameter
# |
# |  
# |  
# ----------------------------------------------------

proc set_hidden_parameter { key param_value } {

	array set hidden_params_hash {}

	read_sopc_hidden_params_into_hash hidden_params_hash
	set hidden_params_hash($key) $param_value
	update_sopc_hidden_params hidden_params_hash
	update_sopc_params_from_hidden_params hidden_params_hash
	
}

# ----------------------------------------------------
# |  
# |  exec_clearbox
# |
# |  Run clearbox to generate fname <HDL or TCL> file
# |  If fname has a .tcl extension, clearbox generates the 
# |  SOPC interface ports information in the fname
# |  If fname has a .v or .vhd extension, clearbox generates
# |  the HDL output file for the avalon module
# |  
# ----------------------------------------------------
proc exec_clearbox { fname {output_dir "."} } {

	global WIZARD_NAME
	global PARAM_INFIX
	global PATH_SEP

	set module_name [string tolower $WIZARD_NAME]
	set module_name_uc [string toupper $module_name]
	set module_avalon_name ${module_name}_avalon


	set project_device_family [get_project_property DEVICE_FAMILY_NAME]
	if { [string match "" $project_device_family] } {
		return
	}

	set megafn_ports [get_parameter_value HIDDEN_MF_PORTS]
	set megafn_params [get_parameter_value HIDDEN_CONSTANTS]
	set port_list ""

	foreach {name val} $megafn_ports {
		set port [lindex [split $name $PARAM_INFIX] 1]
		append port_list ${port},
	} 
	set commandline "CBX_SUBMODULE_USED_PORTS=$module_name:"
	append commandline [string trimright $port_list ,]

	set if_ports [get_parameter_value HIDDEN_IF_PORTS]
	set if_port_list ""

	foreach {name val} $if_ports {
		set port [lindex [split $name $PARAM_INFIX] 1]
		append if_port_list ${port}
		append if_port_list " "
	}
	append commandline "\n$if_port_list"

	foreach {name val} $megafn_params {
		set param_name [lindex [split $name $PARAM_INFIX] 1]
		if { [string first " " $val] != -1 } {
			set val \"${val}\"
		}
		append commandline "\n$param_name=$val"
	}
	
	cd $output_dir
	set cbxcmdln_fname cbxcmdln_[create_unique_id]

	if { [ catch {open $cbxcmdln_fname w} fid ] } {
		send_message error "Could not open $cbxcmdln_fname for writing : $fid"
	} else {
		puts $fid $commandline
		close $fid
	}


    # construct the path to the 32-bit version of clearbox,
    # to match the presence of 32-bit shared libraries being
    # present in the LD_LIBRARY_PATH.
    set qrootdir $::env(QUARTUS_ROOTDIR)
    set os_platform $::tcl_platform(os)
    if { [string equal -nocase -length 3 $os_platform "lin"] } {
            set bindir "linux"
    } else {
            set bindir "bin"
    }
    set cbx_cmd "$qrootdir/$bindir/clearbox $module_avalon_name device_family=$project_device_family CBX_FILE=$fname -f $cbxcmdln_fname"

	set status [catch { eval exec $cbx_cmd } err]
	set cbx_return [process_cbx_exec_exit_status $status]
	if { $cbx_return==0 } {
	} else {
		send_message info "Error while generating $fname : $status : $err"
		send_message info "$::errorInfo"
	}
	
	# Cleanup all temporary files we have created 
	delete_files ${cbxcmdln_fname} 
}

# ----------------------------------------------------
# |  
# |  sync_parameters
# |
# |  Updates parameters in SOPC (both hidden as well as params exposed to users)
# |  based on information from the megawizard and clearbox
# |
# ----------------------------------------------------

proc sync_parameters { process_step silent } {
	
	global TCL_EXT
	global VERILOG_HDL_EXT
	global XML_EXT
	global CBX_PFX
	global WIZARD_NAME

	set got_default 0
	set ret_value "OK"

	# Since the [get_generation_property OUTPUT_NAME] cannot be called 
	# in any callback except the generation callback, need to generate
	# a unique wrapper name for the intermediate qmegawiz calls.
	# Using the porcess id as a unique id ([pid]) gives an error, so 
	# am using a time- and CPU clock-based scheme to make a unique ID.
	set fname $WIZARD_NAME[create_unique_id]
	set fname_tcl ${fname}${TCL_EXT}
	set fname_hdl ${fname}${VERILOG_HDL_EXT}
	set fname_xml ${fname}${XML_EXT}
	set fname_cbx_tcl ${CBX_PFX}${fname}${TCL_EXT}

	set project_device_family [get_project_property DEVICE_FAMILY_NAME]	
	if { [string compare "" $project_device_family] == 0 } {
		return
	}
	
	array set sopc_module_params_hash {}
	array set hidden_params_hash {}

	set editing [string match "edit" $process_step]
	# Check to see if default value setup has been done. If not, do 
	# the setup so that the hidden parameters have default values.
	set generate_default 0
	set hidden_is_first_edit_param [get_parameter_value HIDDEN_IS_FIRST_EDIT]
	if { [string compare "" $hidden_is_first_edit_param] == 0 } {
		set generate_default 1
	}
	set cmd_line_nonempty 0	

	if { $generate_default } {
		set xmlin ""
		set cmd_line_params ""

	} else {
	
		# Read (i)module parameters into a hash (TCL array)
		read_sopc_module_params_into_hash sopc_module_params_hash
	
		# Read (i)module hidden parameters into a hash (TCL array)
		read_sopc_hidden_params_into_hash hidden_params_hash
	
	# Create the command line mode parameters based on those parameters of (i)module
	# whose values have become different from those stored in the hidden parameters.
	# This is done so that a minimum number of constraints are passed to the qmegawiz
	# command line

		set cmd_line_params [construct_command_line_args sopc_module_params_hash hidden_params_hash ]
		if { [string compare "" $cmd_line_params] != 0 } {
			set cmd_line_nonempty 1
		} 
			
	}
	if { $editing || $generate_default || $cmd_line_nonempty } {

		set work_dir [get_work_directory]
		set current_dir [pwd]

		if { [string compare "" $work_dir] == 0 } {
			return
		} else {
			cd $work_dir
		}
		if { $editing || $cmd_line_nonempty } {
			set xmlin "-xmlin"	
			# Create an XML file based on hidden hash to serve as the -xmlin input
			write_xml_out hidden_params_hash $fname_xml
		}

		set edit_cmd_line "qmegawiz wizard=${WIZARD_NAME} INTENDED_DEVICE_FAMILY=$project_device_family \
			  $xmlin -xmlout -tclout -sopc $silent $cmd_line_params $fname_hdl"	

		set status [catch { eval exec $edit_cmd_line } err]

		if { $status != 0} {
			
			# Either there was a non-zero return code or there was
			# an abnormal exit of the child (wizard) process
			process_exec_exit_status $status

			if { $status == 1 } {

				set ret_value "CANCEL"
			} else {

				set ret_value "ERROR"
			}

		} else {
			
			if { [file exists $fname_tcl] } {
				# Read the -tclout TCL file and store the data into hashes"
				store_tclout_data_into_hashes hidden_params_hash $fname_tcl
			
				# Update (i)mdoule hidden parameters from the hidden hashes
				update_sopc_hidden_params hidden_params_hash
			
				# Finally, update (i)module normal parameters from the hidden parameters
				update_sopc_params_from_hidden_params hidden_params_hash
				set_parameter_value HIDDEN_IS_FIRST_EDIT 0
				set got_default 1
			}
		}
	
		if { $got_default } {
			# Run clearbox to update the Hidden interface port params in SOPC
			exec_clearbox $fname_cbx_tcl 
		
			if { [file exists $fname_cbx_tcl] } {
				store_tclout_data_into_hashes hidden_params_hash $fname_cbx_tcl
				update_sopc_hidden_params hidden_params_hash
			}
		}

		cd $current_dir
		# Cleanup all temporary files we have created 
		delete_files $work_dir

	}

	return $ret_value
}

# ----------------------------------------------------
# |  
# |  sync_interface
# |
# |  Compares hidden_if_ports parameter with the interface ports known to SOPC
# |   + adds conduits for hidden_if_ports not known to SOPC
# |   + adds termination on those SOPC ports not in the hidden_if_port list
# |
# ----------------------------------------------------

proc sync_interface { clk_interface_name } {

	global HIDDEN_IF_PORTS
	global IF_PORTS_HASH_KEY
	global PARAM_INFIX

	# if we have not yet generated default, there will be no ports in 
	# the HIDDEN_IF_PORTS param and all of this is irrelevant

		set sopc_known_ports [get_interface_ports]
	
		set mf_intrfc_port_list [list]
		array set hidden_intrfc_ports {}

		read_one_sopc_hidden_param_into_hash hidden_intrfc_ports $HIDDEN_IF_PORTS
			
		foreach port_name [array names hidden_intrfc_ports] {
			lappend mf_intrfc_port_list [get_non_prefixed_param_name $port_name]
		}
		
		foreach if_port $mf_intrfc_port_list {
			set found [ lsearch $sopc_known_ports $if_port ]
			if { $found == -1 } {
				set key $IF_PORTS_HASH_KEY$PARAM_INFIX$if_port
				set port_dir [lindex $hidden_intrfc_ports($key) 0]
				set port_width [lindex $hidden_intrfc_ports($key) 1]
		
				# wires are reported by clearbox as having width = 0
				if { $port_width == 0 } {
					set port_width 1
				}	
				set if_name ${if_port}_conduit
	
				add_interface $if_name conduit start 
				add_interface_port $if_name $if_port export $port_dir $port_width
			}
		}
		
		# set TERMINATION on those ports that are in SOPC's interface that 
		# are not in the HIDDEN_IF_PORTS
		
		if { [llength $mf_intrfc_port_list] != 0 } {
			foreach sopc_port $sopc_known_ports {
				set found [ lsearch $mf_intrfc_port_list $sopc_port ]
				if { $found == -1 } {
					set_port_property $sopc_port TERMINATION true
				}
			}
		} else {
			#write_to_log "MF interface port list is empty"
		}
}

# ============================================================
#			Initialization Routine
# ============================================================
# ----------------------------------------------------
# |  
# |  do_init
# |
# |  This procedure gets called upon the initial
# |  (and only once) run of the script by the SOPC
# |  builder. Anything done in this proc should be
# |  not be instance-specific, that is, should not 
# |  be dependent on the current state of an instance
# |  and apply to all instances 
# |  
# ----------------------------------------------------
proc do_init { } {
	
	global HIDDEN_HASH_PARAMS_LIST
	global HIDDEN_SINGLE_VARS
	global HIDDEN_IF_PORTS


	# Set the callback procs
	set_module_property ELABORATION_CALLBACK do_elaboration
	set_module_property VALIDATION_CALLBACK do_validation
	set_module_property EDITOR_CALLBACK do_edit
	set_module_property GENERATION_CALLBACK do_generation

	# get the parameters that the component specific hw.tcl has already defined
	# these take priority over the ones that the common hw.tcl defines
	set known_param_list [get_parameters]
	
	# Add all exposed megafunction (MF) parameters to the (i)module params list
	set exposed_mf_params_list [get_exposed_mf_param_list]
	foreach { param_name } $exposed_mf_params_list {
		add_parameter $param_name STRING "" "$param_name megafunction parameter"			
	}

	# Add the hidden parameters as well. Explicitly set the visibility of
	# these parameters to off
	foreach hidden_param $HIDDEN_HASH_PARAMS_LIST {
		add_parameter $hidden_param STRING "" "Hidden megafunction parameter"
		set_parameter_property $hidden_param VISIBLE false
	}

	foreach hidden_param $HIDDEN_SINGLE_VARS {
		# only add param if it already has not been defined
		if { [lsearch $hidden_param $known_param_list] == -1 } {
			add_parameter $hidden_param STRING "" "Hidden parameter"
		}
		set_parameter_property $hidden_param VISIBLE false
	}
}



# ============================================================
#			Callback Routines
# ============================================================
# ----------------------------------------------------
# |  
# |  do_edit
# |
# |  This procedure gets called upon the initial
# |  instantiation of the component or when 
# |  re-editing its properties
# |  
# ----------------------------------------------------
proc do_edit { } {
	
	#write_to_log "editing"
	
	set silent ""
	catch {sync_parameters edit $silent} err

	if { $err == "OK" } {
		set custom_post_edit [get_parameter_value HIDDEN_CUSTOM_POST_EDIT]
		if { [string match "" $custom_post_edit] != 1 } {
			${custom_post_edit}
		}
	}

	return $err
}

# ----------------------------------------------------
# |  
# |  do_elaboration
# |
# |  
# |  
# ----------------------------------------------------
proc do_elaboration { } {

	#write_to_log "elaborating"
	set custom_elab [get_parameter_value HIDDEN_CUSTOM_ELABORATION]
	if { [string match "" $custom_elab] != 1 } {
		${custom_elab}
	}
	
	set INCLK_INTERFACE "inclk_interface"
	sync_interface $INCLK_INTERFACE

}

# ----------------------------------------------------
# |  
# |  do_validation
# |
# |  
# |  
# ----------------------------------------------------
proc do_validation {} {
	
	#assert_info "Entering validation callback"
	
	global HIDDEN_IF_PORTS
	global HIDDEN_PRIVATES

	#write_to_log "validating"

	set silent "-silent"
	sync_parameters validate $silent

}


# ----------------------------------------------------
# |  
# |  do_generation
# |
# |  
# |  
# ----------------------------------------------------
proc do_generation {} {

	global PATH_SEP
	global XML_EXT
	global WIZARD_NAME

	
	array set hidden_params_hash {}

	set language 		[get_generation_property HDL_LANGUAGE]
	set output_directory 	[get_generation_property OUTPUT_DIRECTORY]
	set output_name 	[get_generation_property OUTPUT_NAME]

	set outfile_hdl				${output_name}
	append outfile_hdl			[ get_hdl_extension $language ]

	set outfile_pathname 	${output_directory}${PATH_SEP}${outfile_hdl} 

	add_file $outfile_pathname { SYNTHESIS SIMULATION }

	exec_clearbox $outfile_hdl $output_directory
	
}

proc write_to_log { line_output } {
   global g_logid
	global g_log_debug

	if { $g_log_debug == 1 } {
		if { $g_logid == "" } {
			if { [ catch {open "debug_log_file" w} g_logid ] } {
				send_message error "Couldn't open debug_log_file"
			} else {
				puts $g_logid "STARTED"
				flush $g_logid
			}
		}  else {
   		puts $g_logid $line_output
   		flush $g_logid
		}
	}
}
