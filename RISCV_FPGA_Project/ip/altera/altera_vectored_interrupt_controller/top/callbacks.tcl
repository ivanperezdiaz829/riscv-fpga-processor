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


#
# callbacks.tcl
#
# This script is set as a callback in the components _sw.tcl file.
# It is set using the command: 'set_sw_property callback_source_file callbacks.tcl'
#

# Maximum interrupt ports for a VIC
set MAX_INTR_PORTS              32

# Default vector table entry size (in byte)
set DEFAULT_VEC_SIZE            16

# Default linker section
set DEFAULT_LINKER_SECTION      ".text"

# Macro identifiers
set VEC_SIZE_INTF               "vec_size"
set LINKER_SECTION_INTF         "linker_section"
set VEC_TBL_BASE_INTF           "VEC_TBL_BASE"

set SN_ENABLE_PREEMPTION_INTO_NEW_RS      "enable_preemption_into_new_register_set"
set SN_ENABLE_PREEMPTION                  "enable_preemption"

# Query number of shadows register sets for the CPU
set cpu_name [get_cpu_name]
set NUM_OF_SHADOW_REG_SETS [ get_assignment $cpu_name "embeddedsw.CMacro.NUM_OF_SHADOW_REG_SETS" ]

# Store RIL min and RIL max
array set rrs_ril_array {}

proc print_dbgmsg { { msg "none" } } {
    set DEBUG_MSG 0
    if {$DEBUG_MSG == 1} {
        log_default $msg
    }
}


## ---------------------------------
#| * callback *
#| This is a callback proc set in the _sw.tcl file.
#| The callback is called from a context that maintains a reference to an
#| individual SOPC module instance, that uses the software element defined in
#| the _sw.tcl.
#| It is set using the command: 'set_sw_property initialization_callback initialize'
#|
#| Initialize the default value for the following settings (per VIC instance):
#| - VEC_SIZE
#| - VEC_TBL_BASE
#|
#| args 0 : module instance name
#|
proc initialize { args } {
    global DEFAULT_VEC_SIZE
    global VEC_SIZE_INTF
    global VEC_TBL_BASE_INTF

    set module_name [get_module_name]

    # Set VEC_SIZE
    add_module_sw_setting $VEC_SIZE_INTF decimal_number
    set_module_sw_setting_property $VEC_SIZE_INTF default_value $DEFAULT_VEC_SIZE
    set_module_sw_setting_property $VEC_SIZE_INTF identifier [ string toupper $VEC_SIZE_INTF ]
    set_module_sw_setting_property $VEC_SIZE_INTF destination system_h_define
    set_module_sw_setting_property $VEC_SIZE_INTF description "The number of bytes in each vector table entry. Supported values are 16, 32, 64, 128, 256 and 512."

    # Set VEC_TBL_BASE - this value doesn't store in *.bsp file.
    # Vector table label in format <module_name>_VECTOR_TABLE
    set vec_tbl_label [format "%s_VECTOR_TABLE" [ string toupper $module_name ] ]
    add_module_systemh_line $VEC_TBL_BASE_INTF $vec_tbl_label
}

## ---------------------------------
#| * callback *
#| This is a callback proc set in the _sw.tcl file.
#| The callback is called from a context that maintains a reference to an
#| individual SOPC module instance, that uses the software element defined in
#| the _sw.tcl.
#| It is set using the command: 'set_sw_property initialization_callback generate'
#|
#| This callback generates the vector table file. The generated vector table
#| file stores in specified directory and filename in format
#| "altera_<module_name>_vector_tbl.S". This callback also adds the source
#| file to Makefile after the vector table file is generated.
#|
#|
#| args 0 : module instance name
#| args 1 : path to the BSP directory
#| args 2 : driver sub directory
#|
proc generate { args } {
    global VEC_SIZE_INTF
    global LINKER_SECTION_INTF

    if {[llength $args] < 3} {
        error "Insufficient arguments for generate callback proc (expected 3, received [llength $args])."
    }

    set module_name [get_module_name]
    set NUM_OF_INT_PORTS [ get_module_assignment "embeddedsw.CMacro.NUMBER_OF_INT_PORTS" ]

    # Get BSP generate directory path
    set bsp_dir [lindex $args 1]
    set bsp_subdir [lindex $args 2]

    # Filename in format alt_<module_name>_vector_tbl.S
    set fname [format "altera_%s_vector_tbl.S" $module_name]

    # Query vector table label
    set vec_tbl_label [format "%s_VECTOR_TABLE" [ string toupper $module_name ] ]

    # Query linker section
    set section [ get_linker_section $module_name ]

    # Query VEC_SIZE
    set vec_size [ get_module_sw_setting_value $VEC_SIZE_INTF ]

    ## ---------------------------------
    #| Open a file for writing
    ## ---------------------------------
    set vector_table_bsp_relative_path "src/$fname"
    set vector_table_abolute_path $bsp_dir/$bsp_subdir/$vector_table_bsp_relative_path

    # Ensure destination directory exists
    if {![file isdirectory [file dirname $vector_table_abolute_path]]} {
       file mkdir [file dirname $vector_table_abolute_path]
    }

    set fp [open $vector_table_abolute_path w]

    add_file_header $fp

    ## ---------------------------------
    #| Write include file
    ## ---------------------------------
    puts $fp "/* Include funnel macros header file */"
    puts $fp "#include \"altera_vic_funnel.h\"\n"

    ## ---------------------------------
    #| Write header and label
    ## ---------------------------------
    # Add section flag "xa" for execute and allocate
    puts $fp "    .section $section, \"xa\""
    # use .align 2 - to force vector table base address links to
    # word-aligned address (4-byte)
    puts $fp "    .align 2"
    puts $fp "    .globl $vec_tbl_label"
    puts $fp "$vec_tbl_label:"

    ## ----------------------------------------
    #| Write funnel macros for each interrupt
    ## ----------------------------------------
    for {set x 0} {$x < $NUM_OF_INT_PORTS} {incr x} {
        set rnmi_text [format "irq%d_rnmi" $x]
        set rnmi_value [ get_module_sw_setting_value $rnmi_text ]

        # If it is a NMI, use NMI funnel.
        if { $rnmi_value == 1 || $rnmi_value == "true" } {

            set funnel_text "ALT_SHADOW_NON_PREEMPTIVE_NMI_INTERRUPT"

        } else {
            set rrs_text [format "irq%d_rrs" $x]
            set rrs_value [ get_module_sw_setting_value $rrs_text ]
            set preemption [ get_preemption $module_name $rrs_value ]

            # Non-NMI, check preemption setting.
            if { $preemption == 1 || $preemption == "true" } {
                # Preemptive funnel
                set funnel_text "ALT_SHADOW_PREEMPTIVE_INTERRUPT"
            } else {
                # Non-preemptive funnel
                set funnel_text "ALT_SHADOW_NON_PREEMPTIVE_INTERRUPT"
            }
        }

        set funnel [format "     $funnel_text    %d" $vec_size]

        puts $fp $funnel
    }

    ## ---------------------------------
    #| Close the file
    ## ---------------------------------
    close $fp

    ## ---------------------------------
    #| Add file to makefile
    ## ---------------------------------
    add_module_sw_property asm_source $vector_table_bsp_relative_path
}

## ---------------------------------
#| * callback *
#| This is a callback proc set in the _sw.tcl file.
#| The callback is called from a context that maintains a reference to an
#| individual SOPC module instance, that uses the software element defined in
#| the _sw.tcl.
#| It is set using the command: 'set_sw_property initialization_callback validate'
#|
#| This callback validates the vector size, RIL, RRS and RNMI
#|
#| args 0 : module instance name
#|
proc validate { args } {
    set module_name [get_module_name]

    sub_validate_vec_size $module_name
}

# Validate VEC_SIZE has one of these allowed values: 16, 32, 64, 128, 256, 512
proc sub_validate_vec_size { module_name } {
    global VEC_SIZE_INTF
    set vec_size [ get_module_sw_setting_value $VEC_SIZE_INTF]

    if { $vec_size != 16 &&
         $vec_size != 32 &&
         $vec_size != 64 &&
         $vec_size != 128 &&
         $vec_size != 256 &&
         $vec_size != 512 } {
         # incorrect VEC_SIZE
         log_error "ERROR: Module '$module_name' doesn't support vector size $vec_size. Allowed values are 16, 32, 64, 128, 256 and 512."
    }
}

# Get preemption setting, return false(0) or true(1).
proc get_preemption { module_name rrs } {
   set class_name [ get_module_class_name $module_name ]
   set preemption_text [format "%s_driver.enable_preemption_rs_%d" $class_name $rrs ]
   set preemption [ get_setting $preemption_text ]

   return $preemption
}

# Get linker section
proc get_linker_section { module_name } {
   global LINKER_SECTION_INTF
   set class_name [ get_module_class_name $module_name ]
   set linker_section_txt [format "%s_driver.$LINKER_SECTION_INTF" $class_name]
   set linker_section [ get_setting $linker_section_txt ]

   return $linker_section
}

# Add warning and lincense agreement to vector table file.
proc add_file_header { fp } {

    # Add warning
    puts $fp "/*
 * DO NOT MODIFY THIS FILE
 *
 * Changing this file will have subtle consequences
 * which will almost certainly lead to a nonfunctioning
 * system. If you do modify this file, be aware that your
 * changes will be overwritten and lost when this file
 * is generated again.
 *
 * DO NOT MODIFY THIS FILE
 */"

    puts $fp "\n"

    # Add license agreement
    puts $fp "/*
 * License Agreement
 *
 * Copyright (c) 2009
 * Altera Corporation, San Jose, California, USA.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the \"Software\"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * This agreement shall be governed in all respects by the laws of the State
 * of California and by the laws of the United States of America.
 */"

    puts $fp "\n"
}

# ------------------------------------------------------------------------------
#                       VIC class callbacks
# ------------------------------------------------------------------------------

#| * Callback *
#| This is a callback proc set in the _sw.tcl file.
#| This is a callback for the driver class defined by a _sw.tcl file for the driver element
#|
proc class_initialize { args } {
    global NUM_OF_SHADOW_REG_SETS
    global LINKER_SECTION_INTF
    global DEFAULT_LINKER_SECTION
    global SN_ENABLE_PREEMPTION
    global SN_ENABLE_PREEMPTION_INTO_NEW_RS

    set driver_name [lindex $args 0]

    # --------------------------------------------------------------------------
    # Initialize linker section to .text by default.
    # --------------------------------------------------------------------------
    add_class_sw_setting $LINKER_SECTION_INTF unquoted_string
    set_class_sw_setting_property $LINKER_SECTION_INTF default_value $DEFAULT_LINKER_SECTION
    set_class_sw_setting_property $LINKER_SECTION_INTF identifier [ string toupper $LINKER_SECTION_INTF ]
    set_class_sw_setting_property $LINKER_SECTION_INTF destination system_h_define
    set_class_sw_setting_property $LINKER_SECTION_INTF description "Linker section for vector table(s) and funnel code. This memory section must connect to data and instruction master of the CPU."

    # --------------------------------------------------------------------------
    # Initialize global preemption. If all the peripherals support preemption,
    # default global preemption to enabled, else otherwise.
    # --------------------------------------------------------------------------
    set default_preemption [ get_default_peripheral_preemption $driver_name ]
    add_class_sw_setting $SN_ENABLE_PREEMPTION boolean_define_only
    set_class_sw_setting_property $SN_ENABLE_PREEMPTION default_value $default_preemption
    set_class_sw_setting_property $SN_ENABLE_PREEMPTION identifier "ISR_PREEMPTION_ENABLED"
    set_class_sw_setting_property $SN_ENABLE_PREEMPTION destination system_h_define
    set_class_sw_setting_property $SN_ENABLE_PREEMPTION description "Enables global interrupt preemption. If true, defines the macro ALTERA_VIC_DRIVER_ISR_PREEMPTION_ENABLED in system.h"

    # --------------------------------------------------------------------------
    # Initialize preemption into new register set to disabled by default.
    # --------------------------------------------------------------------------
    add_class_sw_setting $SN_ENABLE_PREEMPTION_INTO_NEW_RS boolean_define_only
    set_class_sw_setting_property $SN_ENABLE_PREEMPTION_INTO_NEW_RS default_value 0
    set_class_sw_setting_property $SN_ENABLE_PREEMPTION_INTO_NEW_RS identifier "PREEMPTION_INTO_NEW_REGISTER_SET_ENABLED"
    set_class_sw_setting_property $SN_ENABLE_PREEMPTION_INTO_NEW_RS destination system_h_define
    set_class_sw_setting_property $SN_ENABLE_PREEMPTION_INTO_NEW_RS description "Enables preemption into new register set. If true, defines the macro ALTERA_VIC_DRIVER_PREEMPTION_INTO_NEW_REGISTER_SET_ENABLED in system.h"

    # --------------------------------------------------------------------------
    # Per-register set preemption setting (default disabled).
    # --------------------------------------------------------------------------
    # initialize preemption setting per register set (shadow register set only).
    for {set x 1} {$x <= $NUM_OF_SHADOW_REG_SETS} {incr x} {
        set preemption_rs_text [format "enable_preemption_rs_%d" $x]
        # default to preemption disabled funnel.
        add_class_sw_setting $preemption_rs_text boolean
        set_class_sw_setting_property $preemption_rs_text default_value 0
        set_class_sw_setting_property $preemption_rs_text identifier [ string toupper $preemption_rs_text ]
        set_class_sw_setting_property $preemption_rs_text destination system_h_define
        set_class_sw_setting_property $preemption_rs_text description "Enables preemption for register set $x."
    }

    # --------------------------------------------------------------------------
    # Initialize RIL, RRS and RNMI
    # --------------------------------------------------------------------------
    initialize_default_per_intr_settings $driver_name

}

#| * Callback *
#| This is a callback proc set in the _sw.tcl file.
#| This is a callback for the driver class defined by a _sw.tcl file for the driver element
#|
proc class_validate { args } {
    global NUM_OF_SHADOW_REG_SETS

    set driver_name [lindex $args 0]

    # ------------------------------------------------------
    # Validate number of shadow register set greater than 0.
    # ------------------------------------------------------
    if { $NUM_OF_SHADOW_REG_SETS == 0 } {
        log_error "ERROR: $driver_name needs at least one shadow register set in the system."
    }

    # ------------------------------------------------------
    # Validate linker section
    # ------------------------------------------------------
    sub_class_validate_linker_section $driver_name

    # ------------------------------------------------------
    # Validate RRS
    # ------------------------------------------------------
    set is_error [ sub_class_validate_rrs $driver_name ]
    if { $is_error != 0 } {
        #error
        return
    }

    # ------------------------------------------------------
    # Validate RIL
    # ------------------------------------------------------
    set is_error [ sub_class_validate_ril $driver_name ]
    if { $is_error != 0 } {
        #error
        return
    }

    # ---------------------------------------------------------
    # Validate RNMI
    # ---------------------------------------------------------
    set module_list [ get_module_instance_list $driver_name ]
    sub_class_validate_rnmi $driver_name $module_list

    # ---------------------------------------------------------
    # Validate preemption
    # ---------------------------------------------------------
    sub_class_validate_preemption $driver_name

    # ---------------------------------------------------------
    # Validate RRS and RIL
    # ---------------------------------------------------------
    sub_class_validate_rrs_ril $driver_name $module_list

}


# Validate RIL value in the allowed range, (RIL > 0) and
# (RIL <= ((1 << RIL_WIDTH) - 1))
proc sub_class_validate_ril { driver_name } {

    set vic_list [ get_module_instance_list $driver_name]
    set is_error 0

    foreach vic $vic_list {
        set RIL_WIDTH [ get_assignment $vic "embeddedsw.CMacro.RIL_WIDTH" ]
        set NUM_OF_INT_PORTS [ get_assignment $vic "embeddedsw.CMacro.NUMBER_OF_INT_PORTS" ]

        set max_ril [ expr (1 << $RIL_WIDTH) - 1]

        for {set x 0} {$x < $NUM_OF_INT_PORTS} {incr x} {

            set ril_text [format "$driver_name.$vic.irq%d_ril" $x]
            set ril_value [ get_setting $ril_text ]

            if {$ril_value <= 0 || $ril_value > $max_ril} {
                #error
                if { $max_ril == 1 } {
                    log_error "ERROR: Module '$vic': RIL for IRQ$x must set to $max_ril."
                    set is_error -1
                } else {
                    log_error "ERROR: Module '$vic': RIL for IRQ$x must within the range 1 and $max_ril."
                    set is_error -1
                }
            }
        }
    }
    return $is_error
}


# Validate RRS value less than NUM_OF_SHADOW_REG_SETS and greater than 0
proc sub_class_validate_rrs { driver_name } {
    global NUM_OF_SHADOW_REG_SETS
    set is_error 0
    set vic_list [ get_module_instance_list $driver_name]

    foreach vic $vic_list {
        set NUM_OF_INT_PORTS [ get_assignment $vic "embeddedsw.CMacro.NUMBER_OF_INT_PORTS" ]

        for {set x 0} {$x < $NUM_OF_INT_PORTS} {incr x} {

            set rrs_text [format "$driver_name.$vic.irq%d_rrs" $x]
            set rrs_value [ get_setting $rrs_text ]

            if {$rrs_value <= 0 || $rrs_value > $NUM_OF_SHADOW_REG_SETS} {
                # error
                if { $NUM_OF_SHADOW_REG_SETS == 1 } {
                    log_error "ERROR: Module '$vic': RRS for IRQ$x must set to $NUM_OF_SHADOW_REG_SETS."
                    set is_error -1
                } else {
                    log_error "ERROR: Module '$vic': RRS for IRQ$x must within the range 1 and $NUM_OF_SHADOW_REG_SETS."
                    set is_error -1
                }
            }
        }
    }
    return $is_error
}

# Validate RNMI across all the VIC instances:
# 1. If the particular interrupt sets as non-maskable interrupt (RNMI=1),
#    no sharing register set with normal interrupts (interrupts with RNMI=0),
#    but multiple NMIs can share same shadow register set.
# 2. Issue warning if any interrupt with NMI enabled is
#    not the highest priority (RIL).
proc sub_class_validate_rnmi { driver_name module_list } {

    foreach current_vic $module_list {
        set current_intr_ports [ get_assignment $current_vic "embeddedsw.CMacro.NUMBER_OF_INT_PORTS" ]

        for {set x 0} {$x < $current_intr_ports} {incr x} {

            set skip_warning 0
            set rnmi_text [format "$driver_name.$current_vic.irq%d_rnmi" $x]
            set rnmi_value [ get_setting $rnmi_text ]

            # If it is a non-maskable interrupt.
            if { $rnmi_value ==  1 || $rnmi_value == "true" } {
                foreach other_vic $module_list {
                    set other_intr_ports [ get_assignment $other_vic "embeddedsw.CMacro.NUMBER_OF_INT_PORTS" ]
                    # get RRS
                    set rrs_text [format "$driver_name.$current_vic.irq%d_rrs" $x]
                    set rrs_value [ get_setting $rrs_text ]

                    # get RIL
                    set ril_text [format "$driver_name.$current_vic.irq%d_ril" $x]
                    set ril_value [ get_setting $ril_text ]

                    for {set i 0} {$i < $other_intr_ports} {incr i} {
                        if { $i != $x } {
                            # get RRS, RIL and RNMI values for other interrupts
                            set rrs_other_irq_text [format "$driver_name.$other_vic.irq%d_rrs" $i]
                            set rrs_other_irq [ get_setting $rrs_other_irq_text ]

                            set ril_other_irq_text [format "$driver_name.$other_vic.irq%d_ril" $i]
                            set ril_other_irq [ get_setting $ril_other_irq_text ]

                            set rnmi_other_irq_text [format "$driver_name.$other_vic.irq%d_rnmi" $i]
                            set rnmi_other_irq [ get_setting $rnmi_other_irq_text ]

                            #---------------------------------------------------------
                            # Validate no shares register set with maskable interrupt
                            #---------------------------------------------------------
                            if { $rrs_other_irq == $rrs_value } {
                                #error if this interrupt is maskable interrupt (RNMI = 0)
                                if { $rnmi_other_irq == 0 ||
                                     $rnmi_other_irq == "false" } {
                                    #error
                                    log_error "ERROR: Non-maskable interrupt (IRQ$x) of module '$current_vic' can't share register set $rrs_value with maskable interrupt (IRQ$i) of module '$other_vic'."
                                }
                            }

                            #---------------------------------------------------
                            # Issue warning if any interrupt with NMI enabled is
                            # not the highest priority (RIL).
                            # (Issue warning once only)
                            #---------------------------------------------------
                            if { $skip_warning == 0 &&
                                ($rnmi_other_irq == 0 || $rnmi_other_irq == "false") &&
                                (($ril_other_irq > $ril_value) ||
                                    ($ril_other_irq == $ril_value && $i < $x)) } {
                                log_error "ERROR: Module '$current_vic': Non-maskable interrupt (IRQ$x) is not the highest priority (RIL)."
                                set skip_warning 1
                            }
                        }
                    }

                    #-------------------------------------------------
                    # Validate it uses the preemption disabled funnel.
                    #-------------------------------------------------
                    set preemption_text [format "$driver_name.enable_preemption_rs_%d" $rrs_value ]
                    set preemption [ get_setting $preemption_text ]
                    if { $preemption == 1 || $preemption == "true" } {
                        #NMI must use preemption disabled funnel.
                        log_error "ERROR: Module '$current_vic': Non-maskable interrupt (IRQ$x) must use preemption disabled funnel. Please disable preemption for register set $rrs_value."
                    }
                }
            }
        }
    }
}

# Validate "linker_section" is a valid linker section.
# Validate linker section's memory device is connected to data and instruction master.
# Validate linker section's memory device is writeable.
proc sub_class_validate_linker_section { driver_name } {
    global LINKER_SECTION_INTF

    set is_valid_section 0
    set vic_section [ get_setting "$driver_name.$LINKER_SECTION_INTF" ]

    # --------------------------------------------------------------------------
    # Validate it is a valid linker section
    # --------------------------------------------------------------------------
    set section_list [ get_current_section_mappings ]
    if { $section_list != "" } {
        foreach section $section_list {
            # section in format "section_name memory_region"
            scan $section "%s %s" section_name memory_region
            if { $vic_section == $section_name } {
                # found the section same as VIC section.
                set is_valid_section 1
            }
        }
        # .entry and .exceptions are not in section list, validate them separately.
        if { $vic_section == ".entry" || $vic_section == ".exceptions" } {
            set is_valid_section 1
        }

        # Issue an error if VIC linker section is not in the list.
        if { $is_valid_section == 0 } {
         log_error "ERROR: '$driver_name': Linker section '$vic_section' doesn't exist. Please add linker section with 'add_section_mapping' command."
        }
    }

    # --------------------------------------------------------------------------
    # Validate linker section's memory device is connected to data master
    # and instruction master and it is writeable memory device.
    # --------------------------------------------------------------------------
    set section_mapping [ get_section_mapping $vic_section ]
    if { $section_mapping != "" } {
        set data_master [ is_connected_to_data_master $section_mapping ]
        set inst_master [ is_connected_to_instruction_master $section_mapping ]

        if { (!$data_master) || (!$inst_master) } {
             log_error "ERROR: '$driver_name': \"$section_mapping\" must connect to instruction master and data master of the CPU."
        }

        set flash [is_flash $section_mapping]
        if { $flash == 1 || $flash == "true" } {
            log_error "ERROR: '$driver_name': Linker section '$vic_section' located in a not writeable memory device ($section_mapping). Please change it to writeable memory device."
        }

    }
}

# Validate preemption
proc sub_class_validate_preemption { driver_name } {
    global NUM_OF_SHADOW_REG_SETS
    global SN_ENABLE_PREEMPTION
    global SN_ENABLE_PREEMPTION_INTO_NEW_RS

    # --------------------------------------------------------------------------
    # Issue a warning if user enables "enable_preemption_into_new_register_set"
    # but global preemption is disabled.
    # --------------------------------------------------------------------------
    set global_preemption [ get_setting "$driver_name.$SN_ENABLE_PREEMPTION" ]
    set preemption_into_new_rs [ get_setting "$driver_name.$SN_ENABLE_PREEMPTION_INTO_NEW_RS" ]

    if { ($preemption_into_new_rs == 1 || $preemption_into_new_rs == "true") &&
        ($global_preemption == 0 || $global_preemption == "false") } {
        log_default "WARNING: '$driver_name': Global preemption is disabled. Please ensure that all the ISRs support preemption."
    }

    # --------------------------------------------------------------------------
    # Issue a warning if user enables per-register-set preemption but global
    # preemption is disabled.
    # --------------------------------------------------------------------------
    if { $global_preemption == 0 || $global_preemption == "false" } {
        for {set x 1} {$x <= $NUM_OF_SHADOW_REG_SETS} {incr x} {
            set preemption_text [format "$driver_name.enable_preemption_rs_%d" $x ]
            set per_rs_preemption [ get_setting $preemption_text ]

            if { $per_rs_preemption == 1 || $per_rs_preemption == "true" } {
                log_default "WARNING: '$driver_name': Global preemption is disabled. But register set $x preemption is enabled."
            }
        }
    }

    # --------------------------------------------------------------------------
    # Scans RRS for all interrupts, if specific register set preemption is enabled
    # then examine the preemption properties of that interrupt. Issue a warning
    # if specific register set preemption is enabled but that peripherals which
    # will use that register set don’t support preemption.
    # --------------------------------------------------------------------------
    for {set x 1} {$x <= $NUM_OF_SHADOW_REG_SETS} {incr x} {
        # Get per-register set preemption setting.
        set preemption_rs_text [format "$driver_name.enable_preemption_rs_%d" $x]
        set per_rs_preemption [ get_setting $preemption_rs_text ]

        if { $per_rs_preemption == 1 || $per_rs_preemption == "true" } {
            set vic_list [ get_module_instance_list $driver_name ]
            foreach current_vic $vic_list {
                # Get number of interrupt ports
                set NUM_OF_INT_PORTS [ get_assignment $current_vic "embeddedsw.CMacro.NUMBER_OF_INT_PORTS" ]
                for {set irq 0} {$irq < $NUM_OF_INT_PORTS} {incr irq} {

                    set rrs_text [format "$driver_name.$current_vic.irq%d_rrs" $irq]
                    set irq_rrs [ get_setting $rrs_text ]

                    # If IRQ uses this register set
                    if { $irq_rrs == $x } {
                        set peripheral [ get_class_peripheral $current_vic $irq ]
                        set peripheral_preemption [ get_peripheral_property $peripheral "isr_preemption_supported" ]

                        if { $peripheral_preemption == 0 ||
                             $peripheral_preemption == "false" } {
                            # Issue warning
                            log_default "WARNING: '$driver_name': Driver for '$peripheral' doesn't support preemption. Please change $rrs_text to register set with preemption disabled."
                        }
                    }
                }
            }
        }
    }
}

# This proc returns a list of module instance name with specified driver name.
proc get_module_instance_list { driver_name } {
    # Get all slaves attached to the CPU.
    set slave_descs [get_slave_descs]
    set module_list [ list ]

    foreach module_name $slave_descs {
        # Make sure it is connected interrupt controller.
        if { [ is_connected_interrupt_controller_device $module_name ] == "1" ||
             [ is_connected_interrupt_controller_device $module_name ] == "true" } {
            # Lookup module class name for slave descriptor.
            set module_class_name [get_module_class_name $module_name]
            set module_driver_name [format "%s_driver" $module_class_name]

            if { $driver_name == $module_driver_name } {
                lappend module_list $module_name
            }
        }
    }

    return $module_list
}

# Return 0 if any peripheral doesn't support preemption, else otherwise.
proc get_default_peripheral_preemption { driver_name } {
  set vic_list [ get_module_instance_list $driver_name ]

  foreach current_vic $vic_list {

        set NUM_OF_INT_PORTS [ get_assignment $current_vic "embeddedsw.CMacro.NUMBER_OF_INT_PORTS" ]

        for {set x 0} {$x < $NUM_OF_INT_PORTS} {incr x} {

            set peripheral [ get_class_peripheral $current_vic $x ]
            set preemption [ get_peripheral_property $peripheral isr_preemption_supported ]

            if { $preemption == 0 || $preemption == "false" } {
                # One of peripheral doesn't support preemption.
                return 0
            }
        }
    }

    # All peripherals support preemption.
    return 1
}

# Sort VIC list in controller ID order (ID 0 in first element).
proc sort_vic_order { vic_list } {
    set current_index 0
    set new_list [ list ]

    for {set x 0} {$x < [llength $vic_list]} {incr x} {
        foreach vic $vic_list {
            set id [ get_interrupt_controller_id $vic ]
            if { $id == $current_index } {
                lappend new_list $vic
                set current_index [expr $current_index + 1]
                break
            }
        }
    }
    return $new_list
}

# Initialize default setting for RIL, RRS and RNMI for each interrupt in each VIC.
# 1. For each VIC, examining their RIL width, and then using the minimum RIL
#    width of all VICs as maximum RIL value.
# 2. Priority order: IRQ port 0 on the VIC connected to the CPU (i.e: VIC 0) is
#    highest priority, IRQ port (max) on VIC 0 is higher priority than IRQ 0 on
#    VIC 1, and so on.
# 3. Decrement the RIL value (start with RIL max) after being assigned to each
#    interrupt until you reach RIL = 1.
# 4. Uses the RIL values to assign shadow register sets, so that interrupts with
#    same RIL have same register set number.
proc initialize_default_per_intr_settings { driver_name } {
    global NUM_OF_SHADOW_REG_SETS
    global MAX_INTR_PORTS
    set vic_list [ get_module_instance_list $driver_name]

    if { $NUM_OF_SHADOW_REG_SETS == 0 } {
        return
    }
    # sort VIC in controller ID order
    set vic_list [ sort_vic_order $vic_list ]
    set current_ril [ get_ril_max $vic_list ]
    set current_rrs $NUM_OF_SHADOW_REG_SETS

    #print_dbgmsg "VIC    IRQ    RRS   RIL"
    #print_dbgmsg "========================="

    foreach vic $vic_list {
        set number_of_intrs_per_instance [ get_assignment $vic "embeddedsw.CMacro.NUMBER_OF_INT_PORTS" ]

        for {set irq 0} {$irq < $MAX_INTR_PORTS} {incr irq} {

            set ril_text [format "%s.irq%d_ril" [string toupper $vic] $irq]
            set rrs_text [format "%s.irq%d_rrs" [string toupper $vic] $irq]
            set rnmi_text [format "%s.irq%d_rnmi" [string toupper $vic] $irq]

            set ril_intf_text [format "%s_irq%d_ril" $vic $irq]
            set rrs_intf_text [format "%s_irq%d_rrs" $vic $irq]
            set rnmi_intf_text [format "%s_irq%d_rnmi" $vic $irq]

            if { $irq < $number_of_intrs_per_instance } {

                # Set default RRS
                add_class_sw_setting $rrs_text decimal_number
                set_class_sw_setting_property $rrs_text default_value $current_rrs
                set_class_sw_setting_property $rrs_text identifier [ string toupper $rrs_intf_text ]
                set_class_sw_setting_property $rrs_text destination system_h_define
                set_class_sw_setting_property $rrs_text description "Requested register set (RRS) value for IRQ$irq of '$vic'"

                # Set default RIL
                add_class_sw_setting $ril_text decimal_number
                set_class_sw_setting_property $ril_text default_value $current_ril
                set_class_sw_setting_property $ril_text identifier [ string toupper $ril_intf_text ]
                set_class_sw_setting_property $ril_text destination system_h_define
                set_class_sw_setting_property $ril_text description "Requested interrupt level (RIL) value for IRQ$irq of '$vic'"

                # Set default RNMI to 0
                add_class_sw_setting $rnmi_text boolean
                set_class_sw_setting_property $rnmi_text default_value 0
                set_class_sw_setting_property $rnmi_text identifier [ string toupper $rnmi_intf_text ]
                set_class_sw_setting_property $rnmi_text destination system_h_define
                set_class_sw_setting_property $rnmi_text description "Requested non-maskable interrupt (RNMI) value for IRQ$irq of '$vic'"

                #print_dbgmsg "$vic   $irq     $current_rrs    $current_ril"

                # decrease RIL value
                if { $current_ril != 1 } {
                    set current_ril [expr $current_ril - 1]

                    # decrease RRS value
                    if { $current_rrs != 1 } {
                        set current_rrs [expr $current_rrs - 1]
                    }
                }

            } else {
                # Unused interrupt
                # set to 0 and it doesn't store in *.bsp file.
                add_class_systemh_line [ string toupper $rrs_intf_text ] 0
                add_class_systemh_line [ string toupper $ril_intf_text ] 0
                add_class_systemh_line [ string toupper $rnmi_intf_text ] 0
            }
        }
    }
}

# Get minimum and maximum RIL assigned to each register set.
proc get_ril_min_max_list { driver_name module_list } {
    global rrs_ril_array
    global MAX_INTR_PORTS
    set MIN 0
    set MAX 1

    foreach vic $module_list {
        set NUM_OF_INT_PORTS [ get_assignment $vic "embeddedsw.CMacro.NUMBER_OF_INT_PORTS" ]

        for {set x 0} {$x < $NUM_OF_INT_PORTS} {incr x} {

            set ril_text [format "$driver_name.$vic.irq%d_ril" $x]
            set ril_value [ get_setting $ril_text ]
            set rrs_text [format "$driver_name.$vic.irq%d_rrs" $x]
            set rrs_value [ get_setting $rrs_text ]

            if { $ril_value < [ lindex $rrs_ril_array($rrs_value) $MIN ] ||
               [ lindex $rrs_ril_array($rrs_value) $MIN ] == 0 } {
                set new_list [ lreplace $rrs_ril_array($rrs_value) $MIN $MIN $ril_value ]
                set rrs_ril_array($rrs_value) $new_list
            }

            if { $ril_value > [ lindex $rrs_ril_array($rrs_value) $MAX ] ||
                [ lindex $rrs_ril_array($rrs_value) $MAX ] == 0 } {
                set new_list [ lreplace $rrs_ril_array($rrs_value) $MAX $MAX $ril_value ]
                set rrs_ril_array($rrs_value) $new_list
            }
        }
    }
}

# Validate RILs assigned to each register set do not overlap with any other
# register set.
proc sub_class_validate_rrs_ril { driver_name module_list } {
    global NUM_OF_SHADOW_REG_SETS
    global rrs_ril_array
    set MIN 0
    set MAX 1

    # Initialize array to zero
    for {set x 1} {$x <= $NUM_OF_SHADOW_REG_SETS} {incr x} {
        # Format: [RS#]   [RILmin]     [RILmax]
        lappend rrs_ril_array($x) 0 0
    }

    get_ril_min_max_list $driver_name $module_list

    for {set crs 1} {$crs <= [ array size rrs_ril_array ]} {incr crs} {
        for {set ors 1} {$ors <= [ array size rrs_ril_array ]} {incr ors} {
            if { $crs != $ors } {
                set crs_min [ lindex $rrs_ril_array($crs) $MIN ]
                set crs_max [ lindex $rrs_ril_array($crs) $MAX ]
                set ors_min [ lindex $rrs_ril_array($ors) $MIN ]
                set ors_max [ lindex $rrs_ril_array($ors) $MAX ]

                if { ($ors_min <= $crs_min && $ors_max <= $crs_min) ||
                     ($ors_min >= $crs_max && $ors_max >= $crs_max)} {
                     continue
                } else {
                    #error - overlap
                    log_error "ERROR: '$driver_name': RIL (min:$crs_min max:$crs_max) assigned to register set $crs overlap with register set $ors (RIL min:$ors_min max:$ors_max)."
                    return
                }
            }
        }
    }
}

# Examine the minimum RIL_WIDTH of all VICs and return the maximum RIL of this RIL_WIDTH.
proc get_ril_max { vic_list } {
    set ril_width_max 6
    foreach vic $vic_list {
        set ril_width [ get_assignment $vic "embeddedsw.CMacro.RIL_WIDTH" ]
        if { $ril_width < $ril_width_max } {
            set ril_width_max $ril_width
        }
    }
    set ril_max [ expr (1 << $ril_width_max) - 1]
    return $ril_max
}
# End of file
