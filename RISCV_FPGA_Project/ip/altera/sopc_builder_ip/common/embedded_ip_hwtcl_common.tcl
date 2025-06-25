#-------------------------------------------------------------------------------
# common code
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# proc_bool2int
#
# return boolean value in integer format
#
# args:
#   bool   boolean value
#
# return:
#   value in integer format
#
proc proc_bool2int {bool} {
    if { $bool } {
       return 1
    } else {
       return 0
    }
}

#-------------------------------------------------------------------------------
# log2ceil
#
# rounded-upwards power of 2, used to determine address width need for given size
#
# args:
#   VALUE   value
#
# return:
#   value of minimum width
#
proc log2ceil {VALUE} {
    set result 0
    set value_range [ expr $VALUE - 1 ]
    while { [ expr $value_range > 0 ] } {
        set value_range [ expr $value_range / 2 ]
        set result [ expr $result + 1 ]
    }
    return $result
}

#-------------------------------------------------------------------------------
# string2upper_noSpace
#
# remove the whitespace and convert all characters to uppper case
#
# args:
#   string_in   input string
#
# return:
#   upper case string without whitespace
#
proc string2upper_noSpace { string_in } {
  regsub -all { } $string_in {} string_no_white_space
  set string_touppper [ string toupper $string_no_white_space ]
  	
  return $string_touppper
}

#-------------------------------------------------------------------------------
# proc_get_boolean_parameter
#
# return boolean parameter in int format
#
# args:
#   PARAM   module boolean parameter
#
# return:
#   boolean value in 0 or 1
#
proc proc_get_boolean_parameter {PARAM} {
    set bool_value [ get_parameter_value $PARAM ]
    return [ proc_bool2int $bool_value ]
}

#-------------------------------------------------------------------------------
# proc_isNumerical
#
# check if the value is a valid numerical integer
#
# args:
#   VALUE   input value
#
# return:
#   assertion result
#
proc proc_isNumerical {VALUE} {
    return [ string is double -strict $VALUE ]
}

#-------------------------------------------------------------------------------
# proc_doRounding
#
# round up the value
#
# args:
#   VALUE   input value
#
# return:
#   rounded value
#
proc proc_doRounding {VALUE} {
    return [ expr round($VALUE) ]
}

#-------------------------------------------------------------------------------
# sub_quartus_synth
#
# prepare synthesis files
#
# args:
#   NAME    component name
#
# return:
#   -
#
proc sub_quartus_synth {NAME} {
    set rtl_ext "v"
    set simgen  0
    set output_directory [ add_fileset_file dummy.txt OTHER TEMP "" ]

    generate                    "$NAME" "$output_directory" "$rtl_ext" "$simgen"
}

#-------------------------------------------------------------------------------
# sub_sim_verilog
#
# prepare verilog simulation files
#
# args:
#   NAME    component name
#
# return:
#   -
#
proc sub_sim_verilog {NAME} {
    set rtl_ext "v"
    set simgen  1
    set output_directory [ add_fileset_file dummy.txt OTHER TEMP "" ]

    generate                    "$NAME" "$output_directory" "$rtl_ext" "$simgen"
}

#-------------------------------------------------------------------------------
# sub_sim_vhdl
#
# prepare vhdl simulation files
#
# args:
#   NAME    component name
#
# return:
#   -
#
proc sub_sim_vhdl {NAME} {
    set rtl_ext "vhd"
    set simgen  1
    set output_directory [ add_fileset_file dummy.txt OTHER TEMP "" ]

    generate                    "$NAME" "$output_directory" "$rtl_ext" "$simgen"
}

#-------------------------------------------------------------------------------
# proc_generate_component_rtl
#
# execute the component generation script
#
# args:
#   component_config_file   path to component configuration file
#   component_directory     path to component directory
#   output_name             module instance name
#   output_directory        generation output directory
#   rtl_ext                 hdl language
#   simulation              generate for simulation
#
# return:
#   -
#
proc proc_generate_component_rtl {component_config_file component_directory output_name output_directory rtl_ext simulation} {
    global env
    # Directory
    set OUTPUT_DIR              "$output_directory"
    set SIMULATION_DIR          "$output_directory"
    set COMPONENT_DIR           "$component_directory"
    set QUARTUS_ROOTDIR         "$env(QUARTUS_ROOTDIR)"
    set EMBEDDED_IP_COMMOM_DIR  "$QUARTUS_ROOTDIR/../ip/altera/sopc_builder_ip/common"
    set SOPC_BUILDER_BIN_DIR    "$QUARTUS_ROOTDIR/sopc_builder/bin"
    set EUROPA_DIR              "$SOPC_BUILDER_BIN_DIR/europa"
    set PERLLIB_DIR             "$SOPC_BUILDER_BIN_DIR/perl_lib"
    
    set perl_script             "$COMPONENT_DIR/generate_rtl.pl"
    
    if { $rtl_ext == "vhd" } {
        set language "vhdl"
    } else {
        set language "verilog"
    }

    set PLATFORM $::tcl_platform(platform)
    if { $PLATFORM == "java" } {
        set PLATFORM $::tcl_platform(host_platform)
    }

    # Case:136864 Use quartus(binpath) if its set
    if { [catch {set QUARTUS_BINDIR $::quartus(binpath)} errmsg] } {
        if { $PLATFORM == "windows" } {
            set BINDIRNAME "bin"
        } else {
            set BINDIRNAME "linux"
        }

        # Only the native tcl interpreter has 'tcl_platform(wordSize)'
        # In Jacl however 'tcl_platform(machine)' is set to the JVM bitness, not the OS bitness
        if { [catch {set WORDSIZE $::tcl_platform(wordSize)} errmsg] } {
            if {[string match "*64" $::tcl_platform(machine)]} {
                set WORDSIZE 8
            } else {
                set WORDSIZE 4
            }
        }
        if { $WORDSIZE == 8 } {
            set BINDIRNAME "${BINDIRNAME}64"
        }

        set QUARTUS_BINDIR "$QUARTUS_ROOTDIR/$BINDIRNAME"
    }

    set perl_bin "$QUARTUS_BINDIR/perl/bin/perl"
    if { $PLATFORM == "windows" } {
        set perl_bin "$perl_bin.exe"
    }
    if { ! [ file executable $perl_bin ] } {
        send_message error "Can't find path executable $perl_bin shipped with Quartus"
        return
    }

    # Unfortunately perl doesn't know about the path to the standard Perl include directories.
    set perl_std_libs $QUARTUS_BINDIR/perl/lib
    if { ! [ file isdirectory $perl_std_libs ] } {
        send_message error "Can't find Perl standard libraries $perl_std_libs shipped with Quartus"
        return
    }
    
    # Prepare command-line used to generate component RTL.
    if { ! [ file isfile $component_config_file ] } {
        send_message error "Can't find $component_config_file used to generate RTL"
    }
    
    set exec_list [ list \
        exec $perl_bin \
            -I $perl_std_libs \
            -I $EUROPA_DIR \
            -I $PERLLIB_DIR \
            -I $SOPC_BUILDER_BIN_DIR \
            -I $EMBEDDED_IP_COMMOM_DIR \
            -I $COMPONENT_DIR \
            "--" \
            $perl_script \
            --name=$output_name \
            --dir=$OUTPUT_DIR \
            --quartus_dir=$QUARTUS_ROOTDIR \
            --$language \
            --config=$component_config_file
    ]
    
    if { "$simulation" == "0" } {
        append exec_list     "  --do_build_sim=0  "
    } else {
        append exec_list     "  --do_build_sim=1  "
        append exec_list     "  --sim_dir=$SIMULATION_DIR  "
    }
    
    # start generation
    send_message Info "Starting RTL generation for module '$output_name'"
    send_message Info "  Generation command is \[$exec_list\]"
    
    set gen_output ""
    if { [ catch { set gen_output [ eval $exec_list ] } errmsg ] } {
        foreach errmsg_string [ split $errmsg "\n" ] {
            send_message Info "$errmsg_string"
        }
        send_message error "Failed to generate module $output_name"
    }
    
    if { $gen_output != "" } {
        foreach output_string [ split $gen_output "\n" ] {
            send_message Info $output_string
        }
    }
    send_message Info "Done RTL generation for module '$output_name'"
}


#-------------------------------------------------------------------------------
# proc_add_generated_files
#
# add the generated files using add_fileset_file
#
# args:
#   NAME                module instance name
#   output_directory    generation output directory
#   rtl_ext             hdl language
#   simulation          generate for simulation
#
# return:
#   -
#
proc proc_add_generated_files {NAME output_directory rtl_ext simulation} {
    # add files
    set gen_files [ glob  ${output_directory}${NAME}* ]

    if { "$rtl_ext" == "vhd" } {
        set language "VHDL"
        set rtl_sim_ext "vho"
    } else {
        set language "VERILOG"
        set rtl_sim_ext "vo"
    }
    
    foreach my_file $gen_files {
        # get filename
        set file_name [ file tail $my_file ]
        # add files
        if { [ string match "*.mif" "$file_name" ] } {
            add_fileset_file "$file_name" MIF PATH $my_file
        } elseif { [ string match "*.dat" "$file_name" ] } {
            add_fileset_file "$file_name" DAT PATH $my_file
        } elseif { [ string match "*.hex" "$file_name" ] } {
            add_fileset_file "$file_name" HEX PATH $my_file
        } elseif { [ string match "*.do" "$file_name" ] } {
            add_fileset_file "$file_name" OTHER PATH "$my_file"
        } elseif { [ string match "*.ocp" "$file_name" ] } {
            add_fileset_file "$file_name" OTHER PATH "$my_file"
        } elseif { [ string match "*.sdc" "$file_name" ] } {
            add_fileset_file "$file_name" SDC PATH "$my_file"
        } elseif { [ string match "*.pl" "$file_name" ] } {
            # do nothing
        } elseif { [ string match "*.${rtl_sim_ext}" "$file_name" ] } {
            if { $simulation } {
                add_fileset_file "$file_name" $language PATH "$my_file"
            }
        } elseif { [ string match "*.${rtl_ext}" "$file_name" ] } {
            add_fileset_file "$file_name" $language PATH "$my_file"
        } else {
            add_fileset_file "$file_name" OTHER PATH "$my_file"
        }
    }
}

