#-------------------------------------------------------------------------------
# [1] CORE MODULE ATTRIBUTES
#-------------------------------------------------------------------------------
set_module_property NAME "altera_nios2_qsys"
set_module_property DISPLAY_NAME "Nios II Processor"
set_module_property DESCRIPTION "Altera Nios II Processor"
set_module_property AUTHOR "Altera Corporation"
set_module_property DATASHEET_URL "http://www.altera.com/literature/hb/nios2/n2cpu_nii5v1.pdf"
set_module_property GROUP "Processors"

set_module_property VERSION "13.1"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property INTERNAL false
set_module_property HIDE_FROM_SOPC true

set_module_property EDITABLE true
set_module_property VALIDATION_CALLBACK validate
set_module_property ELABORATION_CALLBACK elaborate
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property SIMULATION_MODEL_IN_VERILOG true

# Define file set
add_fileset quartus_synth   QUARTUS_SYNTH   sub_quartus_synth
add_fileset sim_verilog     SIM_VERILOG     sub_sim_verilog
add_fileset sim_vhdl        SIM_VHDL        sub_sim_vhdl

#-------------------------------------------------------------------------------
# [2] GLOBAL VARIABLES
#-------------------------------------------------------------------------------
set CLOCK_INTF      "clk"
set I_MASTER_INTF   "instruction_master"
set D_MASTER_INTF   "data_master"
set CI_MASTER_INTF  "custom_instruction_master"
set D_IRQ_INTF      "d_irq"
set HBREAK_IRQ_INTF "irq"
set DEBUG_INTF      "jtag_debug_module"
set EXT_IRQ_INTF    "interrupt_controller_in"
set TCD_INTF_PREFIX "tightly_coupled_data_master_"
set TCD_PREFIX      "tightlyCoupledDataMaster"
set TCI_INTF_PREFIX "tightly_coupled_instruction_master_"
set TCI_PREFIX      "tightlyCoupledInstructionMaster"
set AV_DEBUG_PORT   "avalon_debug_port"
set CPU_RESET       "cpu_resetrequest"
set PROGRAM_COUNTER "program_counter"
set HW_BREAKTEST    "hardware_break_test"
set ECC_EVENT       "ecc_event"

#-------------------------------------------------------------------------------
# [3] SUPPORT ROUTINES
#-------------------------------------------------------------------------------
proc add_text_message {GROUP MSG} {
    
    global seperator_id
    set seperator_id [ expr { $seperator_id + 1 } ]
    set ID "text_${seperator_id}"
    
    add_display_item $GROUP $ID text $MSG
}

set seperator_id 0

proc add_line_seperator {GROUP} {
    add_text_message $GROUP      ""
}

proc proc_get_mpu_present {} {
    set mpu_enable [proc_get_boolean_parameter mpu_enabled]
    set mmu_enable [proc_get_boolean_parameter mmu_enabled]
    set impl [ get_parameter_value impl ]
    set mpu_present [ expr { "$impl" == "Fast" } && { ! $mmu_enable }  && { $mpu_enable } ]
    return [proc_bool2int $mpu_present]
}

proc proc_get_mmu_present {} {
    set mpu_enable [proc_get_boolean_parameter mpu_enabled]
    set mmu_enable [proc_get_boolean_parameter mmu_enabled]
    set impl [ get_parameter_value impl ]
    set mmu_present [ expr { "$impl" == "Fast" } && { $mmu_enable }  && { ! $mpu_enable } ]
    return [proc_bool2int $mmu_present]
}

proc proc_get_europa_imprecise_illegal_mem_exc {} {
    set impl [ get_parameter_value impl ]
    set mpu_enable [proc_get_mpu_present]
    set mmu_enable [proc_get_mmu_present]
    set imprecise_illegal_mem_exc [proc_get_boolean_parameter setting_illegalMemAccessDetection]
    set europa_imprecise_illegal_mem_exc [ expr { "$impl" == "Fast" } && { ! $mmu_enable } && { ! $mpu_enable } && { $imprecise_illegal_mem_exc } ]
    return $europa_imprecise_illegal_mem_exc
}

proc proc_get_europa_slave_access_error_exc {} {
    set impl [ get_parameter_value impl ]
    set mpu_enable [proc_get_mpu_present]
    set mmu_enable [proc_get_mmu_present]
    set slave_access_error_exc  [proc_get_boolean_parameter setting_preciseSlaveAccessErrorException]
    set europa_illegal_mem_detection [ proc_get_europa_illegal_mem_exc ]
    set europa_slave_access_error_exc [ expr { "$impl" == "Fast" } && { $europa_illegal_mem_detection } && { ! $mmu_enable } && { $slave_access_error_exc }  ]
    return $europa_slave_access_error_exc
}

proc proc_get_europa_division_error_exc {} {
    set impl [ get_parameter_value impl ]
    set mpu_enable [proc_get_mpu_present]
    set mmu_enable [proc_get_mmu_present]
    set division_error_exc [proc_get_boolean_parameter setting_preciseDivisionErrorException]
    set muldiv_divider [ proc_get_boolean_parameter muldiv_divider ]
    set europa_division_error_exc [ expr { "$impl" == "Fast" } && { $division_error_exc } && { $muldiv_divider } ]
    return $europa_division_error_exc
}

proc proc_get_europa_illegalInstructionsTrap {} {
    set mpu_enable [proc_get_mpu_present]
    set mmu_enable [proc_get_mmu_present]
    set illegalInstructionsTrap [proc_get_boolean_parameter setting_illegalInstructionsTrap]
    set europa_illegalInstructionsTrap [ expr { $illegalInstructionsTrap } || { $mpu_enable } || { $mmu_enable } ]
    return $europa_illegalInstructionsTrap
}

proc proc_get_europa_extra_exc_info {} {
    set impl [ get_parameter_value impl ]
    # Enable extra exception info when ECC present
    set ecc_present [ proc_get_boolean_parameter setting_ecc_present ]
    set mpu_enable [proc_get_mpu_present]
    set mmu_enable [proc_get_mmu_present]
    set extra_exc_info [proc_get_boolean_parameter setting_extraExceptionInfo]
    set europa_extra_exc_info [ expr { "$impl" == "Fast" } && { $extra_exc_info || $mpu_enable || $mmu_enable || $ecc_present} ]
    return $europa_extra_exc_info
}

proc proc_get_europa_illegal_mem_exc {} {
    set impl [ get_parameter_value impl ]
    set mpu_enable [proc_get_mpu_present]
    set mmu_enable [proc_get_mmu_present]
    set illegal_mem_exc [proc_get_boolean_parameter setting_preciseIllegalMemAccessException]
    set europa_illegal_mem_exc [ expr { "$impl" == "Fast" } && { $illegal_mem_exc || $mpu_enable || $mmu_enable } ]
    return $europa_illegal_mem_exc
}

proc proc_bool2int {bool} {
    if { $bool } {
       return 1
    } else {
       return 0
    }
}
proc proc_get_boolean_parameter {PARAM} {
    set bool_value [get_parameter_value $PARAM]
    return [proc_bool2int $bool_value]
}
proc proc_num2sz {NUMBER} {
    if { $NUMBER == 0 } {
        return 1
    }

    if { $NUMBER == 1 } {
        return 1
    }

    return [expr int(ceil(log($NUMBER)/log(2)))]
}

proc proc_span2width { n } {
    return [expr int(ceil(log($n)/log(2)))]    
}

proc proc_num2hex {NUMBER} {
    return [ format "0x%08x" $NUMBER ]
}

proc proc_num2unsigned {NUMBER} {
    return [ format "%u" $NUMBER ]
}

proc proc_set_display_format {NAME DISPLAY_HINT} {
    set_parameter_property  $NAME   "DISPLAY_HINT"      $DISPLAY_HINT
}

# TODO: description as arg
# TODO: do we need "affects_elaboration" often?
# TODO: add description
proc proc_add_parameter {NAME TYPE DEFAULT args} {
    set DESCRIPTION         "set \[$NAME\] value"
    add_parameter           $NAME $TYPE $DEFAULT $DESCRIPTION
    if {$args != ""} then {
        set_parameter_property  $NAME "ALLOWED_RANGES" $args
    }
    set_parameter_property  $NAME "VISIBLE" false
}

proc proc_add_derived_parameter {NAME TYPE DEFAULT args} {
    proc_add_parameter      $NAME $TYPE    $DEFAULT
    set_parameter_property  $NAME "DERIVED" true
    set_parameter_property  $NAME "VISIBLE" true
}

proc proc_add_system_info_parameter {NAME TYPE DEFAULT SYSTEM_INFO_ARG} {
    proc_add_parameter      $NAME   $TYPE           $DEFAULT
    set_parameter_property  $NAME   system_info     "$SYSTEM_INFO_ARG"
}

# TODO: appropriate use of quotation marks?
# TODO: proper use of status=experimentatl for debug mode?
proc proc_set_display_group {NAME GROUP EXPERIMENTAL DISPLAY_NAME args} {
    add_display_item        $GROUP  $NAME               parameter
    set_parameter_property  $NAME   "DISPLAY_NAME"      "$DISPLAY_NAME"
    set display_message     "$args"
    # only show those settings in debug mode
    if { "$EXPERIMENTAL" == "1" } {
        set_parameter_property  $NAME   "STATUS"       "EXPERIMENTAL"
        set_parameter_property  $NAME   "VISIBLE"           false
        lappend display_message "(Not Supported)"
    } else {
        set_parameter_property  $NAME   "VISIBLE"           true
    }
    
    if { [ expr { "DES_$args" != "DES_" } ] } {
        set_parameter_property  $NAME   "DESCRIPTION"       "[ join $display_message ]"
    }
}


proc proc_set_enable_visible_parameter {NAME ENABLED} {
    if { [ get_parameter_property $NAME "VISIBLE" ] } {
        if { "$ENABLED" == "enable" } {
            set_parameter_property $NAME "ENABLED" 1
        } else {
            set_parameter_property $NAME "ENABLED" 0
        }
    }
}

# Add a particular parameter to the 'group' that will
# affect the resulting output Perl hash
proc proc_set_info_hash_group {INFO_GROUP args} {
    global processor_infos
    foreach arg $args {
        lappend processor_infos($INFO_GROUP) $arg
    }
}

proc proc_set_interface_embeddedsw_cmacro_assignment {interface name value} {
    set name_upper_case "[ string toupper $name ]"
    set embeddedsw_name "embeddedsw.CMacro.${name_upper_case}"
    set_interface_assignment $interface $embeddedsw_name "$value"
}

proc proc_set_interface_embeddedsw_configuration_assignment {interface name value} {
    set embeddedsw_name "embeddedsw.configuration.${name}"
    set_interface_assignment $interface $embeddedsw_name "$value"
}

proc proc_set_module_embeddedsw_cmacro_assignment {name value} {
    set name_upper_case "[ string toupper $name ]"
    set embeddedsw_name "embeddedsw.CMacro.${name_upper_case}"
    set_module_assignment $embeddedsw_name "$value"
}

proc proc_set_module_embeddedsw_configuration_assignment {name value} {
    set embeddedsw_name "embeddedsw.configuration.${name}"
    set_module_assignment $embeddedsw_name "$value"
}

proc proc_validate_address_alignment {memory_address alignment_mask error_msg} {
    set next_valid_increment [ expr $alignment_mask + 0x1 ]
    set valid_address_mask [ expr $alignment_mask ^ 0xffffffff ]
    set previous_valid_address [ proc_num2hex [ expr $memory_address & $valid_address_mask ]]
    set next_valid_address [ proc_num2hex [ expr $previous_valid_address + $next_valid_increment ]]

    if { [ expr $memory_address & $alignment_mask ] != 0x0 } {
        send_message error "$error_msg. ($previous_valid_address or $next_valid_address are acceptable)"
    }
}
                                     
proc proc_validate_device_features {device_feature} {
    set device_features         [ get_parameter_value deviceFeaturesSystemInfo ]

    switch $device_feature {
        "dsp_mul" {
            return [ is_device_feature_exist "DSP" ]
        }
        "DSPBlock" {
            return [ is_device_feature_exist "DSP" ]
        }
        "embedded_mul" {
            return [ is_device_feature_exist "EMUL" ]
        }
        "EmbeddedMulFast" {
            return [ is_device_feature_exist "EMUL" ]
        }
        "M4K" {
            return [ is_device_feature_exist "M4K_MEMORY" ]
        }
        "M-RAM" {
            return [ is_device_feature_exist "MRAM_MEMORY" ]
        }
        "MLAB" {
            return [ is_device_feature_exist "MLAB_MEMORY" ]
        }
        "M9K" {
            return [ is_device_feature_exist "M9K_MEMORY" ]
        }
        "M10K" {
            return [ is_device_feature_exist "M10K_MEMORY" ]
        }
        "M20K" {
            return [ is_device_feature_exist "M20K_MEMORY" ]
        }
        "M144K" {
            return [ is_device_feature_exist "M144K_MEMORY" ]
        }
        "M512" {
            return [ is_device_feature_exist "M512_MEMORY" ]
        }
    }

    return 0
}

# DEVICE_FEATURES
#~~~~~~~~~~~~~~~~
#   MLAB_MEMORY
#   M4K_MEMORY
#   M144K_MEMORY
#   M512_MEMORY
#   MRAM_MEMORY
#   M9K_MEMORY
#   ADDRESS_STALL
#   DSP
#   EMUL
#   DSP_SHIFTER_BLOCK
#   ESB
#   EPCS
#   LVDS_IO
#   HARDCOPY
#   TRANSCEIVER_6G_BLOCK
#   TRANSCEIVER_3G_BLOCK
proc is_device_feature_exist {feature_name} {
    array set feature_array  [get_parameter_value deviceFeaturesSystemInfo]
    foreach one_feature [array names feature_array] {
        if { [ expr { "$one_feature" == "$feature_name" } ] } {
            return $feature_array($one_feature)
        }
    }
    return 0
}

proc proc_get_supported_ram_type {} {
    set supported_ram_type_system_info [list]
    array set feature_array  [get_parameter_value deviceFeaturesSystemInfo]
    foreach one_feature [array names feature_array] {
        if { [ string match "*_MEMORY*" "$one_feature" ] } {
            if { $feature_array($one_feature) } {
                lappend supported_ram_type_system_info "$one_feature"
            }
        }
    }
    set supported_ram_type [list]
    foreach ram_type $supported_ram_type_system_info {
        switch $ram_type {
            "M4K_MEMORY" {
                lappend supported_ram_type "M4K"
            }
            "M9K_MEMORY" {
                lappend supported_ram_type "M9K"
            }
            "M10K_MEMORY" {
                lappend supported_ram_type "M10K"
            }
            "M20K_MEMORY" {
                lappend supported_ram_type "M20K"
            }
            "M144K_MEMORY" {
                lappend supported_ram_type "M144K"
            }
            "MRAM_MEMORY" {
                # Basically do nothing for MRAMs
                #lappend supported_ram_type "MRam"
            }
            "MLAB_MEMORY" {
                lappend supported_ram_type "MLAB"
            }
            "M512_MEMORY" {
                lappend supported_ram_type "M512"
            }
            default {
                # Should never enter this function
                send_message error "$ram_type is not a valid ram type"
            }

        }
    }
    # Don't forget the AUTO
    lappend supported_ram_type "Automatic"
    return "$supported_ram_type"
}

proc proc_get_supported_cache_tagram_type {} {
    set supported_ram_type_system_info [list]
    array set feature_array  [get_parameter_value deviceFeaturesSystemInfo]
    foreach one_feature [array names feature_array] {
        if { [ string match "*_MEMORY*" "$one_feature" ] } {
            if { $feature_array($one_feature) } {
                lappend supported_ram_type_system_info "$one_feature"
            }
        }
    }
    set supported_ram_type [list]
    foreach ram_type $supported_ram_type_system_info {
        switch $ram_type {
            "M4K_MEMORY" {
                lappend supported_ram_type "M4K"
            }
            "M9K_MEMORY" {
                lappend supported_ram_type "M9K"
            }
            "M10K_MEMORY" {
                lappend supported_ram_type "M10K"
            }
            "M20K_MEMORY" {
                lappend supported_ram_type "M20K"
            }
            "M144K_MEMORY" {
                lappend supported_ram_type "M144K"
            }
            "MRAM_MEMORY" {
                # Basically do nothing for MRAMs
                #lappend supported_ram_type "MRam"
            }
            "MLAB_MEMORY" {
                # Basically do nothing for MLABs
                #lappend supported_ram_type "MLAB"
            }
            "M512_MEMORY" {
                lappend supported_ram_type "M512"
            }
            default {
                # Should never enter this function
                send_message error "$ram_type is not a valid ram type"
            }

        }
    }
    # Don't forget the AUTO
    lappend supported_ram_type "Automatic"
    return "$supported_ram_type"
}

proc proc_get_lowest_start_address {slave_map_param} {
    set slave_address [ lsort -ascii [ proc_get_address_map_slaves_start_address $slave_map_param ]]
    if { [ expr { "ADDR_$slave_address" == "ADDR_" } ] } {
        return [ proc_num2unsigned -1 ]
    } else {
        return [ proc_num2unsigned [ lindex $slave_address 0 ]]
    }
}

proc proc_get_higest_end_address {slave_map_param} {
    set slave_address [ lsort -ascii [ proc_get_address_map_slaves_end_address $slave_map_param ]]
    if { [ expr { "ADDR_$slave_address" == "ADDR_" } ] } {
        return [ proc_num2unsigned -1 ]
    } else {
        return [ proc_num2unsigned [ lindex $slave_address end ]]
    }

}

proc proc_decode_address_map {slave_map_param} {
    set address_map_xml [ get_parameter_value $slave_map_param ]
    return [ decode_address_map $address_map_xml ]
}

proc proc_get_address_map_slaves_name {slave_map_param} {
    set slaves_name [list]
    set address_map_dec [ proc_decode_address_map $slave_map_param]

    foreach slave_info $address_map_dec {
        array set slave_info_array $slave_info
        lappend slaves_name "$slave_info_array(name)"
    }

    foreach dup_check $slaves_name {
        set tmp($dup_check) 1
    }
    set slaves_name [ array names tmp ]

    return $slaves_name
}

proc proc_get_address_map_slaves_start_address {slave_map_param} {
    set slaves_start_address [list]
    set address_map_dec [ proc_decode_address_map $slave_map_param]

    foreach slave_info $address_map_dec {
        array set slave_info_array $slave_info
        lappend slaves_start_address "[ proc_num2hex $slave_info_array(start) ]"
    }
    return $slaves_start_address
}

proc proc_get_address_map_slaves_end_address {slave_map_param} {
    set slaves_end_address [list]
    set address_map_dec [ proc_decode_address_map $slave_map_param]

    foreach slave_info $address_map_dec {
        array set slave_info_array $slave_info
        lappend slaves_end_address "[ proc_num2hex [ expr $slave_info_array(end) - 1 ]]"
    }
    return $slaves_end_address
}

# [TODO]: replace proc_get_address_map_1_slave_start_address == -1
proc proc_is_slave_exist {slave_map_param slave_name} {
    set address_map_dec [ proc_decode_address_map $slave_map_param]
    foreach slave_info $address_map_dec {
        array set slave_info_array $slave_info
        set slave "$slave_info_array(name)"
        if { "$slave" == "$slave_name" } {
            return 1
        }
    }
    return 0
}

proc proc_get_address_map_1_slave_start_address {slave_map_param slave_name} {
    set address_map_dec [ proc_decode_address_map $slave_map_param]
    foreach slave_info $address_map_dec {
        array set slave_info_array $slave_info
        set slave "$slave_info_array(name)"
        if { "$slave" == "$slave_name" } {
            return [ proc_num2hex $slave_info_array(start) ]
        }
    }
    return -1
}

proc proc_get_address_map_1_slave_end_address {slave_map_param slave_name} {
    set address_map_dec [ proc_decode_address_map slave_map_param]
    foreach slave_info $address_map_dec {
        array set slave_info_array $slave_info
        set slave "$slave_info_array(name)"
        if { "$slave" == "$slave_name" } {
            return "[ proc_num2hex [ expr $slave_info_array(end) - 1 ]]"
        }
    }
    return -1
}

proc proc_calc_actual_address {slave_name address_offset} {
    global  TCI_PREFIX
    global  TCD_PREFIX
    
    set tcim_num    [ get_parameter_value icache_numTCIM ]
    
    if { $slave_name == "Absolute" } {
        return [ proc_num2unsigned $address_offset ]
    } else {
        if { [proc_is_slave_exist instSlaveMapParam $slave_name] } {
            set inst_address_base [ proc_get_address_map_1_slave_start_address instSlaveMapParam $slave_name ]
            return [ proc_num2unsigned [ expr $inst_address_base + $address_offset ] ]
        } else {
            foreach i {0 1 2 3} {
                set TCI_NAME  "${TCI_PREFIX}${i}"
                if { $i < $tcim_num } {
                    if { [ proc_is_slave_exist ${TCI_NAME}MapParam $slave_name ] } {
                        set tcim_address_base [ proc_get_address_map_1_slave_start_address ${TCI_NAME}MapParam $slave_name ]
                        return [ proc_num2unsigned [ expr $tcim_address_base + $address_offset ] ]
                    }
                }
            }
        }
        return -1
    }
}


proc proc_get_reset_addr {} {
    return [ proc_calc_actual_address [get_parameter_value resetSlave] [get_parameter_value resetOffset]]
}

proc proc_get_general_exception_addr {} {
    return [ proc_calc_actual_address [get_parameter_value exceptionSlave] [get_parameter_value exceptionOffset]]
}

proc proc_get_fast_tlb_miss_exception_addr {} {
    set mmu_enable [proc_get_mmu_present]
    if { $mmu_enable } {
        return [ proc_calc_actual_address [get_parameter_value mmu_TLBMissExcSlave] [get_parameter_value mmu_TLBMissExcOffset]]
    } else {
        return 0
    }

    return 0
}

proc proc_get_break_addr {} {
    return [ proc_calc_actual_address [get_parameter_value breakSlave] [get_parameter_value breakOffset]]
}

proc proc_get_data_master_present {} {
    set impl                            [ get_parameter_value impl ]
    set dcache_omitDataMaster           [ proc_get_boolean_parameter dcache_omitDataMaster ]
    set dcache_size_derived             [ get_parameter_value dcache_size_derived ]
    set tcdm_num                        [ get_parameter_value dcache_numTCDM ]
    
    return [ expr { "$impl" != "Fast" } || { "$dcache_omitDataMaster" == "0" } || { "$dcache_size_derived" != "0" } || { "$tcdm_num" == "0" } ]
}

proc proc_get_inst_master_present {} {
    set impl                            [ get_parameter_value impl ]
    set icache_size                     [ get_parameter_value icache_size ]
    
    return [ expr { "$impl" == "Tiny" } || { "$icache_size" != "0" } ]
}

#TODO: Properly implement this
proc proc_decode_ci_slave { param } {
    regsub -all "/?info>" $param "" param
    regsub -all "\{\""    $param "" param
    regsub -all "\"\}"    $param "" param
    regsub -all " />"     $param "" param
    regsub -all "info/>"  $param "" param
    
    return $param
}

proc proc_has_any_ci_slave {} {

    set has_combo [ proc_has_combo_ci_slave ]
    set has_multi [ proc_has_multi_ci_slave ]
    
    set has_any_ci [ expr $has_combo || $has_multi  ]
    
    return $has_any_ci
    
}

proc proc_has_combo_ci_slave {} {

    set ci_ori [ proc_decode_address_map customInstSlavesSystemInfo ]
    set custom_inst_slave [ proc_decode_ci_slave $ci_ori ]
    
    foreach custom_slave $custom_inst_slave {
        array set custom_slave_info $custom_slave
        set custom_slave_type  $custom_slave_info(clockCycleType)
        if { "$custom_slave_type" == "COMBINATORIAL" } {
            return 1
        }
    }
    
    return 0
}

proc proc_has_multi_ci_slave {} {

    set ci_ori [ proc_decode_address_map customInstSlavesSystemInfo ]
    set custom_inst_slave [ proc_decode_ci_slave $ci_ori ]
    
    foreach custom_slave $custom_inst_slave {
        array set custom_slave_info $custom_slave
        set custom_slave_type  $custom_slave_info(clockCycleType)
        if { [ expr { "$custom_slave_type" == "VARIABLE" } || { "$custom_slave_type" == "MULTICYCLE" } ] } {
            return 1
        }
    }
    
    return 0
}

proc proc_validate_offset { slave_name abs_address} {
    set local_data_address_map_dec            [ proc_decode_address_map dataSlaveMapParam ]
    foreach local_data_slave $local_data_address_map_dec {
        array set local_data_slave_info $local_data_slave
        if { "$local_data_slave_info(name)" == "$slave_name" } {
            set SlaveEndAddr [ proc_num2unsigned [ expr { $local_data_slave_info(end) - 1 } ] ]
            if { [ expr { $abs_address > $SlaveEndAddr } ] } {
                return 1
            } else {
                return 0
            }
        }
    }
}

proc proc_width2maxaddr { n } {
      # tcl version 8.0 limitation. Only able to convert float of 2^31 to integer
    if { [ expr { $n == 32 } ] } {
        return [ proc_num2hex 4294967295 ]
    } else {
        set number [ expr int(pow(2,$n) - 1) ]
        return [ proc_num2hex $number ]
    }
}

proc proc_get_cmacro_inst_addr_width {} {
    set tcim0 [ get_parameter_value tightlyCoupledInstructionMaster0AddrWidth]
    set tcim1 [ get_parameter_value tightlyCoupledInstructionMaster1AddrWidth]
    set tcim2 [ get_parameter_value tightlyCoupledInstructionMaster2AddrWidth]
    set tcim3 [ get_parameter_value tightlyCoupledInstructionMaster3AddrWidth]
    set im    [ get_parameter_value instAddrWidth ]

    set sorted_inst_addr_width  [ lsort "$im $tcim0 $tcim1 $tcim2 $tcim3" ]
    set highest_inst_addr_width [ lindex $sorted_inst_addr_width end ]
    return $highest_inst_addr_width
}

proc proc_get_cmacro_data_addr_width {} {
    set tcdm0 [ get_parameter_value tightlyCoupledDataMaster0AddrWidth]
    set tcdm1 [ get_parameter_value tightlyCoupledDataMaster1AddrWidth]
    set tcdm2 [ get_parameter_value tightlyCoupledDataMaster2AddrWidth]
    set tcdm3 [ get_parameter_value tightlyCoupledDataMaster3AddrWidth]
    set dm    [ get_parameter_value dataAddrWidth ]

    set sorted_data_addr_width  [ lsort "$dm $tcdm0 $tcdm1 $tcdm2 $tcdm3" ]
    set highest_data_addr_width [ lindex $sorted_data_addr_width end ]
    return $highest_data_addr_width
}

proc proc_calculate_ecc_bits { data_sz } {
    for { set ecc_bits 0 } { [ expr { pow(2,$ecc_bits) - $ecc_bits - 1 } < $data_sz]  } { incr ecc_bits } {}
    set ecc_bits [ expr $ecc_bits + 1 ]
    return $ecc_bits
}

proc proc_calculate_tlb_data_size {} {
    set local_finalTlbPtrSz      [ proc_get_final_tlb_ptr_size ]
    set local_mmupid             [ get_parameter_value mmu_processIDNumBits ]
    set local_tlb_num_ways       [ get_parameter_value mmu_tlbNumWays ]
    set local_instaddrwidth      [ get_parameter_value instAddrWidth ]
    set local_dataaddrwidth      [ get_parameter_value dataAddrWidth ]

    set local_tlb_ways_sz        [ proc_num2sz $local_tlb_num_ways ]
    set local_mmu_addr_offset_sz 12
    if { ${local_instaddrwidth} > ${local_dataaddrwidth} } {
        set pfn_size [ expr { ${local_instaddrwidth} - ${local_mmu_addr_offset_sz}} ]
    } else {
        set pfn_size [ expr { ${local_dataaddrwidth} - ${local_mmu_addr_offset_sz}} ]
    }
    set tag_size [ expr {32 - ( ${local_finalTlbPtrSz} - ${local_tlb_ways_sz} ) - ${local_mmu_addr_offset_sz} } ]
    # Cacheable, Readable, Writable, Executable and Global
    set const_size 5
    set tlb_data_size [ expr { ${tag_size} + ${local_mmupid} + ${const_size} + ${pfn_size} } ]
    
    return $tlb_data_size
}

proc proc_calculate_dc_tag_data_size {} {
    set dcache_lineSize_derived  [ get_parameter_value dcache_lineSize_derived ];
    set dcache_size_derived      [ get_parameter_value dcache_size_derived ];
    set local_dataaddrwidth      [ get_parameter_value dataAddrWidth ]

    set dc_bytes_per_line        $dcache_lineSize_derived;
    set dc_cache_wide            [ expr { $dc_bytes_per_line > 4 } ]
    set dc_words_per_line        [ expr { $dc_bytes_per_line>>2 } ];# 8 words/cacheline
    set data_master_addr_sz      $dcache_size_derived
    set dc_num_lines             [ expr { $data_master_addr_sz / $dc_bytes_per_line } ]
    set dc_addr_byte_field_sz    2
    set dc_addr_byte_field_lsb   0
    set dc_addr_byte_field_msb   [ expr { $dc_addr_byte_field_lsb + $dc_addr_byte_field_sz -1 } ]
    set dc_addr_offset_field_sz  [ proc_num2sz $dc_words_per_line ]
    set dc_addr_line_field_sz    [ proc_num2sz $dc_num_lines ]
    if { $dc_cache_wide }  {
        # this line needed the dc_addr_offset_field_sz
        set dc_addr_line_field_lsb [ expr {$dc_addr_byte_field_msb + 2 + $dc_addr_offset_field_sz -1} ]
    } else {
        set dc_addr_line_field_lsb [ expr {$dc_addr_byte_field_msb + 1 } ]
    }
    set dc_addr_line_field_msb   [ expr { $dc_addr_line_field_lsb + $dc_addr_line_field_sz - 1 } ]
    set dc_addr_tag_field_msb    [ expr { $local_dataaddrwidth - 1} ]
    set dc_addr_tag_field_lsb    [ expr { $dc_addr_line_field_msb +1 } ]
    set dc_addr_tag_field_sz     [ expr {$dc_addr_tag_field_msb - $dc_addr_tag_field_lsb + 1 } ]
    set dc_tag_entry_valid_sz    1
    set dc_tag_entry_dirty_sz    1
    #        finals
    set dc_tag_data_sz           [ expr { $dc_addr_tag_field_sz + $dc_tag_entry_valid_sz + $dc_tag_entry_dirty_sz } ]
    
    return $dc_tag_data_sz
}

proc proc_calculate_dc_tag_addr_size {} {
    set dcache_lineSize_derived  [ get_parameter_value dcache_lineSize_derived ];
    set dcache_size_derived      [ get_parameter_value dcache_size_derived ];
    set local_dataaddrwidth      [ get_parameter_value dataAddrWidth ]

    set dc_bytes_per_line        $dcache_lineSize_derived;
    set dc_words_per_line        [ expr { $dc_bytes_per_line>>2 } ];# 8 words/cacheline
    set data_master_addr_sz      $dcache_size_derived
    set dc_num_lines             [ expr { $data_master_addr_sz / $dc_bytes_per_line } ]

    set dc_addr_line_field_sz    [ proc_num2sz $dc_num_lines ]

    set dc_tag_addr_sz           $dc_addr_line_field_sz
    
    return $dc_tag_addr_sz
}

proc proc_calculate_dc_data_addr_size {} {
    set dcache_lineSize_derived  [ get_parameter_value dcache_lineSize_derived ];
    set dcache_size_derived      [ get_parameter_value dcache_size_derived ];
    set local_dataaddrwidth      [ get_parameter_value dataAddrWidth ]

    set dc_bytes_per_line        $dcache_lineSize_derived
    set dc_cache_wide            [ expr { $dc_bytes_per_line > 4 } ]
    set dc_words_per_line        [ expr { $dc_bytes_per_line>>2 } ];# 8 words/cacheline
    set data_master_addr_sz      $dcache_size_derived
    set dc_num_lines             [ expr { $data_master_addr_sz / $dc_bytes_per_line } ]
    set dc_addr_byte_field_sz    2
    set dc_addr_byte_field_lsb   0
    set dc_addr_byte_field_msb   [ expr { $dc_addr_byte_field_lsb + $dc_addr_byte_field_sz -1 } ]
    set dc_addr_offset_field_sz  [ proc_num2sz $dc_words_per_line ]
    set dc_addr_line_field_sz    [ proc_num2sz $dc_num_lines ]
    if { $dc_cache_wide }  {
        # this line needed the dc_addr_offset_field_sz
        set dc_addr_line_field_lsb [ expr {$dc_addr_byte_field_msb + 2 + $dc_addr_offset_field_sz -1} ]
    } else {
        set dc_addr_line_field_lsb [ expr {$dc_addr_byte_field_msb + 1 } ]
    }
    set dc_addr_line_field_msb   [ expr { $dc_addr_line_field_lsb + $dc_addr_line_field_sz - 1 } ]
    set dc_addr_tag_field_msb    [ expr { $local_dataaddrwidth - 1} ]
    set dc_addr_tag_field_lsb    [ expr { $dc_addr_line_field_msb +1 } ]
    set dc_addr_tag_field_sz     [ expr {$dc_addr_tag_field_msb - $dc_addr_tag_field_lsb + 1 } ]
    set dc_addr_line_offset_field_sz  [ expr { $dc_addr_line_field_sz + $dc_addr_offset_field_sz } ]
    if { $dc_cache_wide }  {
        set dc_data_addr_sz      $dc_addr_line_offset_field_sz
    } else {
        set dc_data_addr_sz      $dc_addr_line_field_sz
    }

    return $dc_data_addr_sz
}

proc proc_calculate_ic_tag_data_size {} {
    set local_instaddrwidth      [ get_parameter_value instAddrWidth ]
    set icache_size              [ get_parameter_value icache_size ]
    
    set ic_bytes_per_line        32 ;#32bytes /cacheline
    set ic_words_per_line        [ expr { $ic_bytes_per_line>>2 } ];# 8 words/cacheline
    set ic_total_bytes           $icache_size
    set ic_num_lines             [ expr { $ic_total_bytes / $ic_bytes_per_line } ]
    set ic_offset_field_sz       [ proc_num2sz $ic_words_per_line ]
    set ic_offset_field_lsb      0
    set ic_offset_field_msb      [ expr { $ic_offset_field_lsb + $ic_offset_field_sz -1 } ]
    set ic_line_field_sz         [ proc_num2sz $ic_num_lines ]
    set ic_line_field_lsb        [ expr { $ic_offset_field_msb +1 } ]
    set ic_line_field_msb        [ expr { $ic_line_field_lsb + $ic_line_field_sz -1 } ]
    set ic_tag_field_msb         [ expr { $local_instaddrwidth -3} ]
    set ic_tag_field_lsb         [ expr { $ic_line_field_msb +1 } ]
    set ic_tag_field_sz          [ expr { $ic_tag_field_msb - $ic_tag_field_lsb +1 } ]
    set ic_tag_data_sz           [ expr { $ic_tag_field_sz + $ic_words_per_line } ]
    
    return $ic_tag_data_sz
}

proc proc_calculate_ic_tag_addr_size {} {
    set icache_size              [ get_parameter_value icache_size ]
    
    set ic_bytes_per_line        32 ;#32bytes /cacheline
    set ic_words_per_line        [ expr { $ic_bytes_per_line>>2 } ];# 8 words/cacheline
    set ic_total_bytes           $icache_size
    set ic_num_lines             [ expr { $ic_total_bytes / $ic_bytes_per_line } ]
    set ic_line_field_sz         [ proc_num2sz $ic_num_lines ]

    set ic_tag_addr_sz           $ic_line_field_sz
    
    return $ic_tag_addr_sz
}

proc proc_calculate_ic_data_addr_size {} {
    set icache_size              [ get_parameter_value icache_size ]
    
    set ic_bytes_per_line        32 ;#32bytes /cacheline
    set ic_words_per_line        [ expr { $ic_bytes_per_line>>2 } ];# 8 words/cacheline
    set ic_total_bytes           $icache_size
    set ic_num_lines             [ expr { $ic_total_bytes / $ic_bytes_per_line } ]
    set ic_offset_field_sz       [ proc_num2sz $ic_words_per_line ]
    set ic_line_field_sz         [ proc_num2sz $ic_num_lines ]

    set ic_data_addr_sz          [ expr { $ic_line_field_sz + $ic_offset_field_sz } ]
    
    return $ic_data_addr_sz
}
#-------------------------------------------------------------------------------
# [4] PARAMETERS
#-------------------------------------------------------------------------------
#------------------------------
# [4.1] Actual Parameters
#------------------------------
proc_add_parameter      setting_showUnpublishedSettings             BOOLEAN     false
proc_add_parameter      setting_showInternalSettings                BOOLEAN     false
proc_add_parameter      setting_preciseSlaveAccessErrorException    BOOLEAN     false
proc_add_parameter      setting_preciseIllegalMemAccessException    BOOLEAN     false
proc_add_parameter      setting_preciseDivisionErrorException       BOOLEAN     false
proc_add_parameter      setting_performanceCounter                  BOOLEAN     false
proc_add_parameter      setting_illegalMemAccessDetection           BOOLEAN     false
proc_add_parameter      setting_illegalInstructionsTrap             BOOLEAN     false
proc_add_parameter      setting_fullWaveformSignals                 BOOLEAN     false
proc_add_parameter      setting_extraExceptionInfo                  BOOLEAN     false
proc_add_parameter      setting_exportPCB                           BOOLEAN     false
proc_add_parameter      setting_debugSimGen                         BOOLEAN     false
proc_add_parameter      setting_clearXBitsLDNonBypass               BOOLEAN     true
proc_add_parameter      setting_bit31BypassDCache                   BOOLEAN     true
proc_add_parameter      setting_bigEndian                           BOOLEAN     false
proc_add_parameter      setting_export_large_RAMs                   BOOLEAN     false
proc_add_parameter      setting_asic_enabled                        BOOLEAN     false
proc_add_parameter      setting_asic_synopsys_translate_on_off      BOOLEAN     false
proc_add_parameter      setting_oci_export_jtag_signals             BOOLEAN     false
proc_add_parameter      setting_bhtIndexPcOnly                      BOOLEAN     false
proc_add_parameter      setting_avalonDebugPortPresent              BOOLEAN     false
proc_add_parameter      setting_alwaysEncrypt                       BOOLEAN     true
proc_add_parameter      setting_allowFullAddressRange               BOOLEAN     false
proc_add_parameter      setting_activateTrace                       BOOLEAN     true
proc_add_parameter      setting_activateTrace_user                  BOOLEAN     false
proc_add_parameter      setting_activateTestEndChecker              BOOLEAN     false
proc_add_parameter      setting_ecc_sim_test_ports                  BOOLEAN     false
proc_add_parameter      setting_activateMonitors                    BOOLEAN     true
proc_add_parameter      setting_activateModelChecker                BOOLEAN     false
proc_add_parameter      setting_HDLSimCachesCleared                 BOOLEAN     true
proc_add_parameter      setting_HBreakTest                          BOOLEAN     false
proc_add_parameter      setting_breakslaveoveride                   BOOLEAN     false
proc_add_parameter      muldiv_divider                              BOOLEAN     false
proc_add_parameter      mpu_useLimit                                BOOLEAN     false
proc_add_parameter      mpu_enabled                                 BOOLEAN     false
proc_add_parameter      mmu_enabled                                 BOOLEAN     false
proc_add_parameter      mmu_autoAssignTlbPtrSz                      BOOLEAN     true
proc_add_parameter      manuallyAssignCpuID                         BOOLEAN     true
proc_add_parameter      debug_triggerArming                         BOOLEAN     true
proc_add_parameter      debug_embeddedPLL                           BOOLEAN     true
proc_add_parameter      debug_debugReqSignals                       BOOLEAN     false
proc_add_parameter      debug_assignJtagInstanceID                  BOOLEAN     false
proc_add_parameter      dcache_omitDataMaster                       BOOLEAN     false
proc_add_parameter      cpuReset                                    BOOLEAN     false
proc_add_parameter      is_hardcopy_compatible                      BOOLEAN     false
proc_add_parameter      setting_shadowRegisterSets                  INTEGER     0       "0:63"
proc_add_parameter      mpu_numOfInstRegion                         INTEGER     8       "2"  "3"   "4"   "5"   "6"   "7"   "8"   "9"  "10"  "11"  "12"  "13"  "14"  "15"  "16"  "17"  "18"  "19"  "20"  "21"  "22"  "23"  "24"  "25"  "26"  "27"  "28"  "29"  "30"  "31"  "32"
proc_add_parameter      mpu_numOfDataRegion                         INTEGER     8       "2"  "3"   "4"   "5"   "6"   "7"   "8"   "9"  "10"  "11"  "12"  "13"  "14"  "15"  "16"  "17"  "18"  "19"  "20"  "21"  "22"  "23"  "24"  "25"  "26"  "27"  "28"  "29"  "30"  "31"  "32"
proc_add_parameter      mmu_TLBMissExcOffset                        INTEGER     0
proc_add_parameter      debug_jtagInstanceID                        INTEGER     0       "0:255"
proc_add_parameter      resetOffset                                 INTEGER     0
proc_add_parameter      exceptionOffset                             INTEGER     32
proc_add_parameter      cpuID                                       INTEGER     0
proc_add_parameter      cpuID_stored                                INTEGER     0
proc_add_parameter      breakOffset                                 INTEGER     32
proc_add_parameter      userDefinedSettings                         STRING      ""
proc_add_parameter      resetSlave                                  STRING      "None"
proc_add_parameter      mmu_TLBMissExcSlave                         STRING      "None"
proc_add_parameter      exceptionSlave                              STRING      "None"
proc_add_parameter      breakSlave                                  STRING      "None"
# [SH] Change all Integer type with "_8" back to string since "string:Display name" is allowed
proc_add_parameter      setting_perfCounterWidth                    INTEGER     32          "16:16 Bits"  "24:24 Bits"  "32:32 Bits"
proc_add_parameter      setting_interruptControllerType             STRING      "Internal"  "Internal"  "External"
proc_add_parameter      setting_branchPredictionType                STRING      "Automatic" "Automatic"  "Static"  "Dynamic"
proc_add_parameter      setting_bhtPtrSz                            INTEGER     8           "8:256 Entries"  "9:512 Entries"  "10:1024 Entries"  "11:2048 Entries"
proc_add_parameter      muldiv_multiplierType                       STRING      "DSPBlock"  "DSPBlock:DSP Block"  "EmbeddedMulFast:Embedded Multipliers"  "LogicElementsFast:Logic Elements"  "NoneSmall:None"
proc_add_parameter      mpu_minInstRegionSize                       INTEGER     12          "6:64 Bytes"  "7:128 Bytes"  "8:256 Bytes"  "9:512 Bytes"  "10:1 Kbyte"  "11:2 Kbytes"  "12:4 Kbytes"  "13:8 Kbytes"  "14:16 Kbytes"  "15:32 Kbytes"  "16:64 Kbytes"  "17:128 Kbytes"  "18:256 Kbytes"  "19:512 Kbytes"  "20:1 Mbyte"
proc_add_parameter      mpu_minDataRegionSize                       INTEGER     12          "6:64 Bytes"  "7:128 Bytes"  "8:256 Bytes"  "9:512 Bytes"  "10:1 Kbyte"  "11:2 Kbytes"  "12:4 Kbytes"  "13:8 Kbytes"  "14:16 Kbytes"  "15:32 Kbytes"  "16:64 Kbytes"  "17:128 Kbytes"  "18:256 Kbytes"  "19:512 Kbytes"  "20:1 Mbyte"
proc_add_parameter      mmu_uitlbNumEntries                         INTEGER     4           "2:2 Entries"  "4:4 Entries"  "6:6 Entries"  "8:8 Entries"
proc_add_parameter      mmu_udtlbNumEntries                         INTEGER     6           "2:2 Entries"  "4:4 Entries"  "6:6 Entries"  "8:8 Entries"
proc_add_parameter      mmu_tlbPtrSz                                INTEGER     7           "7:128 Entries"  "8:256 Entries"  "9:512 Entries"  "10:1024 Entries"
proc_add_parameter      mmu_tlbNumWays                              INTEGER     16          "8:8 Ways"  "16:16 Ways"
proc_add_parameter      mmu_processIDNumBits                        INTEGER     8           "8:8 Bits"  "9:9 Bits"  "10:10 Bits"  "11:11 Bits"  "12:12 Bits"  "13:13 Bits"  "14:14 Bits"
proc_add_parameter      impl                                        STRING      "Fast"      "Tiny:Nios II/e"  "Small:Nios II/s"  "Fast:Nios II/f"
proc_add_parameter      icache_size                                 INTEGER     4096        "0:None"  "512:512 Bytes"  "1024:1 Kbyte"  "2048:2 Kbytes"  "4096:4 Kbytes"  "8192:8 Kbytes"  "16384:16 Kbytes"  "32768:32 Kbytes"  "65536:64 Kbytes"
# Created new parameter for TagRAM block type
# Old parameter still used for DataRAM block type
proc_add_parameter      icache_tagramBlockType                      STRING      "Automatic" "Automatic"  "M4K"  "M9K" "M10K" "M20K" "M144K"
proc_add_parameter      icache_ramBlockType                         STRING      "Automatic" "Automatic"  "M4K"  "MRam"  "MLAB"  "M9K" "M10K" "M20K" "M144K"
proc_add_parameter      icache_numTCIM                              INTEGER     0           "0:None"  "1:1"  "2:2"  "3:3"  "4:4"
proc_add_parameter      icache_burstType                            STRING      "None"      "None:Disable"  "Sequential:Enable"
proc_add_parameter      dcache_bursts                               STRING      "false"     "false:Disable" "true:Enable"
proc_add_parameter      dcache_victim_buf_impl                      STRING      "ram"       "ram:RAM"   "reg:Registers"
proc_add_parameter      debug_level                                 STRING      "Level1"    "NoDebug:No Debugger"  "Level1:Level 1"  "Level2:Level 2"  "Level3:Level 3"  "Level4:Level 4"
proc_add_parameter      debug_OCIOnchipTrace                        STRING      "_128"      "_128:128 Frames"  "_256:256 Frames"  "_512:512 Frames"  "_1k:1k Frames"  "_2k:2k Frames"  "_4k:4k Frames"  "_8k:8k Frames"  "_16k:16k Frames"
proc_add_parameter      dcache_size                                 INTEGER     2048        "0:None"  "512:512 Bytes"  "1024:1 Kbyte"  "2048:2 Kbytes"  "4096:4 Kbytes"  "8192:8 Kbytes"  "16384:16 Kbytes"  "32768:32 Kbytes"  "65536:64 Kbytes"
proc_add_parameter      dcache_tagramBlockType                      STRING      "Automatic" "Automatic"  "M4K"  "M9K" "M10K" "M20K" "M144K"
proc_add_parameter      dcache_ramBlockType                         STRING      "Automatic" "Automatic"  "M4K"  "MRam"  "MLAB"  "M9K" "M10K" "M20K" "M144K"
proc_add_parameter      dcache_numTCDM                              INTEGER     0           "0:None"  "1:1"  "2:2"  "3:3"  "4:4"
proc_add_parameter      dcache_lineSize                             INTEGER     32          "4:4 Bytes"  "16:16 Bytes"  "32:32 Bytes"
# Adding new parameter for exporting reset/exception/break vectors
proc_add_parameter      setting_exportvectors                       BOOLEAN     false
# Parameters for ECC Options
proc_add_parameter      setting_ecc_present                         BOOLEAN     false
proc_add_parameter      setting_ic_ecc_present                      BOOLEAN     true
proc_add_parameter      setting_rf_ecc_present                      BOOLEAN     true
proc_add_parameter      setting_mmu_ecc_present                     BOOLEAN     true
proc_add_parameter      setting_dc_ecc_present                      BOOLEAN     false
proc_add_parameter      setting_itcm_ecc_present                    BOOLEAN     false
proc_add_parameter      setting_dtcm_ecc_present                    BOOLEAN     false
# RAM block type parameter for all NIOS II RAMs
proc_add_parameter      regfile_ramBlockType                        STRING      "Automatic" "Automatic"  "M4K"  "MRam"  "MLAB"  "M9K" "M10K" "M20K" "M144K"
proc_add_parameter      ocimem_ramBlockType                         STRING      "Automatic" "Automatic"  "M4K"  "MRam"  "MLAB"  "M9K" "M10K" "M20K" "M144K"
proc_add_parameter      mmu_ramBlockType                            STRING      "Automatic" "Automatic"  "M4K"  "MRam"  "MLAB"  "M9K" "M10K" "M20K" "M144K"
proc_add_parameter      bht_ramBlockType                            STRING      "Automatic" "Automatic"  "M4K"  "MRam"  "MLAB"  "M9K" "M10K" "M20K" "M144K"


#------------------------------
# [4.2] Display Parameter In GUI
#------------------------------
set CORE         "Core Nios II"
set CORE_0       "Select a Nios II Core"
set CORE_1       "Hardware Arithmetic Operation"
set CORE_2       "Reset Vector"
set CORE_3       "Exception Vector"
set CORE_4       "MMU and MPU"

set CACHE        "Caches and Memory Interfaces"
set ICACHE       "Instruction Master"
set DCACHE       "Data Master"

set ADVANCED     "Advanced Features"
set ADVANCED_1   "General"
set ADVANCED_2   "Exception Checking"
set ADVANCED_3   "Branch Prediction"
set ADVANCED_4   "HardCopy Compatibility"
set ADVANCED_5   "More Settings"

set MMU_MPU      "MMU and MPU Settings"
set MMU          "MMU"
set MPU          "MPU"

set DEBUG        "JTAG Debug Module"
set DEBUG_1      "Select a Debugging Level"
set DEBUG_2      "Break Vector"
set DEBUG_3      "Advanced Debug Settings"

set CI           "Custom Instruction"
set CI_0         "General"

set TEST         "Test"
set HTML_TAB     " &nbsp &nbsp &nbsp &nbsp "
set REG_BLOCK_TYPE "Register File RAM Block Type"
set OCIMEM_BLOCK_TYPE "OCI Memory RAM Block Type"

# Original html at //acds/main/regtest/ip/sopc_builder_ip/altera_nios2/scripts/flow/system/merlin_support/_hwtcl_html_table/
set NIOSII_TABLE "<html><table border=\"1\" width=\"100%\">
		  <tr bgcolor=\"#C9DBF3\"><th></th><td><font size=5>Nios II/e</font></td><td><font size=5>Nios II/s</font></td>
		  <td><font size=5>Nios II/f</font></td></tr><!-- Family: TBD<br>f<sub>system</sub>: TBD<br>cpuid: TBD -->
		  <tr bgcolor=\"#FFFFFF\"><td valign=\"top\"><font size=6><b>Nios II</b></font><br>Selector Guide</td>
		  <td valign=\"top\" width=\"180\"><b>RISC<br>32-bit</b></td><td valign=\"top\" width=\"180\">RISC<br>32-bit<br>
		  <b>Instruction Cache<br>Branch Prediction<br>Hardware Multiply<br>Hardware Divide</b></td><td valign=\"top\" width=\"180\">RISC
		  <br>32-bit<br>Instruction Cache<br>Branch Prediction<br>Hardware Multiply<br>Hardware Divide<br><b>Barrel Shifter<br>Data Cache
		  <br>Dynamic Branch Prediction</b></td></tr><!--<tr bgcolor=\"#C9DBF3\"><td>Performance at 50.0 MHz</td><td>Up to 8 DMIPS</td>
		  <td>Up to 32 DMIPS</td><td>Up to 57 DMIPS</td></tr><tr bgcolor=\"#FFFFFF\"><td>Logic Usage</td><td>600-700 LEs</td>
		  <td>1200-1400 LEs</td><td>1400-1800 LEs</td></tr>--><tr bgcolor=\"#C9DBF3\"><td>Memory Usage (e.g Stratix IV)</td><td>Two M9Ks (or equiv.)</td>
		  <td>Two M9Ks + cache</td><td>Three M9Ks + cache</td></tr></table></html>"
		  
set JTAG_DEBUG_TABLE "<html><table border=\"1\" width=\"100%\"><tr bgcolor=\"#C9DBF3\"><th>No Debugger</th><th>Level 1</th><th>Level 2</th>
			<th>Level 3</th><th>Level 4</th></tr><tr bgcolor=\"#FFFFFF\"><td></td><td valign=\"top\"><b>JTAG Target Connection<br>
			Download Software<br>Software Breakpoints</b></td><td valign=\"top\">JTAG Target Connection<br>Download Software<br>
			Software Breakpoints<br><b>2 Hardware Breakpoints<br>2 Data Triggers</b></td><td valign=\"top\">JTAG Target Connection
			<br>Download Software<br>Software Breakpoints<br>2 Hardware Breakpoints<br>2 Data Triggers<br><b>Instruction Trace<br>
			On-Chip Trace</b></td><td valign=\"top\">JTAG Target Connection<br>Download Software<br>Software Breakpoints<br>
			<b>4 Hardware Breakpoints<br>4 Data Triggers</b><br>Instruction Trace<br>On-Chip Trace<br><b>Data Trace<br>Off-chip Trace</b>
			</td></tr><!--<tr bgcolor=\"#C9DBF3\"><td>No LEs</td><td>300-400 LEs</td><td>800-900 LEs</td><td>2400-2700 LEs</td>
			<td>3100-3700 LEs</td></tr>--><tr bgcolor=\"#C9DBF3\"><td>No M9Ks</td><td>One M9K</td><td>One M9K</td><td>One M9K + trace</td>
			<td>One M9K + trace</td></tr></table></html>"

			
#-------------------------------------------------------------------------------
# [4.4] Derived Parameter
#-------------------------------------------------------------------------------
proc_add_derived_parameter  resetAbsoluteAddr       INTEGER     0
proc_add_derived_parameter  exceptionAbsoluteAddr   INTEGER     0
proc_add_derived_parameter  breakAbsoluteAddr       INTEGER     0
proc_add_derived_parameter  mmu_TLBMissExcAbsAddr   INTEGER     0
proc_add_derived_parameter  dcache_bursts_derived   STRING      "false"
proc_add_derived_parameter  dcache_size_derived     INTEGER     2048
proc_add_derived_parameter  dcache_lineSize_derived INTEGER     32
set_parameter_property      dcache_bursts_derived   "VISIBLE"   "false"
set_parameter_property      dcache_size_derived     "VISIBLE"   "false"
set_parameter_property      dcache_lineSize_derived "VISIBLE"   "false"

# Additional derived parameter for translate_on_off (ASIC only)
# Overriding the Visible property
proc_add_derived_parameter  translate_on            STRING     { "synthesis translate_on"  }
proc_add_derived_parameter  translate_off           STRING     { "synthesis translate_off" }
set_parameter_property  translate_on  "VISIBLE" false
set_parameter_property  translate_off "VISIBLE" false

# $CORE
add_display_item            ""                                          $CORE       GROUP tab
add_display_item            "$CORE"                                     $CORE_0       GROUP
add_display_item            "$CORE"                                     $CORE_1       GROUP
add_display_item            "$CORE"                                     $CORE_2       GROUP
add_display_item            "$CORE"                                     $CORE_3       GROUP
add_display_item            "$CORE"                                     $CORE_4       GROUP
proc_set_display_group      impl                                        $CORE_0       0   "Nios II Core"
add_text_message   							                            $CORE_0       ${NIOSII_TABLE}
# add_line_seperator                                                      $CORE
proc_set_display_group      muldiv_multiplierType                       $CORE_1       0   "Hardware multiplication type"
proc_set_display_group      muldiv_divider                              $CORE_1       0   "Hardware divide"
# add_line_seperator                                                      $CORE
proc_set_display_group      resetSlave                                  $CORE_2       0   "Reset vector memory"
proc_set_display_group      resetOffset                                 $CORE_2       0   "Reset vector offset"
proc_set_display_group      resetAbsoluteAddr                           $CORE_2       0   "Reset vector"
# add_line_seperator                                                      $CORE
proc_set_display_group      exceptionSlave                              $CORE_3       0   "Exception vector memory"
proc_set_display_group      exceptionOffset                             $CORE_3       0   "Exception vector offset"
proc_set_display_group      exceptionAbsoluteAddr                       $CORE_3       0   "Exception vector"
# add_line_seperator                                                      $CORE
proc_set_display_group      mmu_enabled                                 $CORE_4       0   "Include MMU"
add_text_message                                                        $CORE_4       "Only include the MMU using an operating system that explicitly supports an MMU."
proc_set_display_group      mmu_TLBMissExcSlave                         $CORE_4       0   "Fast TLB Miss Exception vector memory"
proc_set_display_group      mmu_TLBMissExcOffset                        $CORE_4       0   "Fast TLB Miss Exception vector offset"
proc_set_display_group      mmu_TLBMissExcAbsAddr                       $CORE_4       0   "Fast TLB Miss Exception vector"
add_line_seperator                                                      $CORE_4
proc_set_display_group      mpu_enabled                                 $CORE_4       0   "Include MPU"

# $CACHE
add_display_item            ""                                          $CACHE      GROUP tab
add_display_item            "$CACHE"                                    $ICACHE     GROUP
add_display_item            "$CACHE"                                    $DCACHE     GROUP
proc_set_display_group      icache_size                                 $ICACHE      0   "Instruction cache"
proc_set_display_group      icache_tagramBlockType                      $ICACHE      1   "Tag RAM block type"
proc_set_display_group      icache_ramBlockType                         $ICACHE      1   "Data RAM block type"
proc_set_display_group      icache_burstType                            $ICACHE      0   "Burst transfers (burst size = 32 bytes)"
proc_set_display_group      icache_numTCIM                              $ICACHE      0   "Number of tightly coupled instruction master port(s)"

proc_set_display_group      dcache_omitDataMaster                       $DCACHE      0   "Omit data master port"
proc_set_display_group      dcache_size                                 $DCACHE      0   "Data cache"
proc_set_display_group      dcache_tagramBlockType                      $DCACHE      1   "Tag RAM block type"
proc_set_display_group      dcache_ramBlockType                         $DCACHE      1   "Data RAM block type"
proc_set_display_group      dcache_lineSize                             $DCACHE      0   "Data cache line size"
proc_set_display_group      dcache_bursts                               $DCACHE      0   "Bursts transfers (burst size = data cache line size)"
proc_set_display_group      dcache_victim_buf_impl                      $DCACHE      0   "Data cache victim buffer implementation"
proc_set_display_group      dcache_numTCDM                              $DCACHE      0   "Number of tightly coupled data master port(s)"

# $ADVANCED
add_display_item            ""                                          $ADVANCED     GROUP tab
add_display_item            "$ADVANCED"                                 $ADVANCED_1   GROUP
add_display_item            "$ADVANCED"                                 $ADVANCED_2   GROUP
add_display_item            "$ADVANCED"                                 $ADVANCED_3   GROUP
add_display_item            "$ADVANCED"                                 $ADVANCED_4   GROUP
add_display_item            "$ADVANCED"                                 "ECC"         GROUP
add_display_item            "$ADVANCED"                                 $REG_BLOCK_TYPE    GROUP
add_display_item            "$ADVANCED"                                 $ADVANCED_5   GROUP
proc_set_display_group      setting_bigEndian                           $ADVANCED_1   1   "Big endian"
proc_set_display_group      setting_interruptControllerType             $ADVANCED_1   0   "Interrupt controller"
proc_set_display_group      setting_shadowRegisterSets                  $ADVANCED_1   0   "Number of shadow register sets (0-63)"
add_text_message                                                        $ADVANCED_1   "<html>${HTML_TAB}External interrupt controller and shadow register setsonly supported in Nios II/f core.<br>${HTML_TAB}Internal interrupt controller is the only option for Nios II/e and Nios II/s core.</html>"
add_line_seperator                                                      $ADVANCED_1
proc_set_display_group      cpuReset                                    $ADVANCED_1   0   "Include cpu_resetrequest and cpu_resettaken signals"
add_text_message                                                        $ADVANCED_1   "<html>${HTML_TAB}These signals appear on the top-level Qsys system.<br>${HTML_TAB}You must manually connect these signals to logic external to the Qsys system.</html>"
add_line_seperator                                                      $ADVANCED_1
proc_set_display_group      manuallyAssignCpuID                         $ADVANCED_1   0   "Assign cpuid control register value manually"
proc_set_display_group      cpuID                                       $ADVANCED_1   0   "<html>${HTML_TAB}cpuid control register value</html>"
add_line_seperator                                                      $ADVANCED_1
proc_set_display_group      setting_activateTrace_user                  $ADVANCED_1   0   "Generate trace file during RTL simulation" "Creates a trace file called as \"system_name\"_\"cpu_name\".tr. Please use the nios2-trace command to display it."
proc_set_display_group      setting_showUnpublishedSettings             $ADVANCED_1       1   "Show Unpublished Settings"
proc_set_display_group      setting_showInternalSettings                $ADVANCED_1       1   "Show Internal Settings"
set_parameter_property      setting_showUnpublishedSettings "VISIBLE" "true"
set_parameter_property      setting_showInternalSettings    "VISIBLE" "true"
proc_set_display_group      setting_exportPCB                           $ADVANCED_1   1   "Export CPU Program Counter (PC)"
proc_set_display_group      setting_illegalInstructionsTrap             $ADVANCED_2   0   "Illegal instructions" "always present with MMU and MPU"
proc_set_display_group      setting_preciseDivisionErrorException       $ADVANCED_2   0   "Division error"
proc_set_display_group      setting_preciseIllegalMemAccessException    $ADVANCED_2   0   "Misaligned memory access" "always present with MMU and MPU"
proc_set_display_group      setting_preciseSlaveAccessErrorException    $ADVANCED_2   1   "<html>${HTML_TAB}Slave access error</html>" "requires misaligned memory access but incompatible with MMU"
proc_set_display_group      setting_extraExceptionInfo                  $ADVANCED_2   0   "Extra exception information" "always present with MMU and MPU"
proc_set_display_group      is_hardcopy_compatible                      $ADVANCED_4   0   "HardCopy compatible" "Enable migration onto HardCopy device"
proc_set_display_group      setting_illegalMemAccessDetection           $ADVANCED_2   1   "Imprecise illegal memory access" "deprecated, incompatible with precise exceptions, MMU and MPU"
proc_set_display_group      setting_branchPredictionType                $ADVANCED_3   1   "Branch prediction type"
proc_set_display_group      setting_bhtPtrSz                            $ADVANCED_3   1   "Number of entries"
proc_set_display_group      bht_ramBlockType                            $ADVANCED_3   1   "BHT RAM Block Type"
proc_set_display_group      setting_ecc_present                         "ECC"         0   "ECC Present"
proc_set_display_group      setting_ic_ecc_present                      "ECC"         1   "Instruction Cache ECC Present"
proc_set_display_group      setting_rf_ecc_present                      "ECC"         1   "Register File ECC Present"
proc_set_display_group      setting_dc_ecc_present                      "ECC"         1   "Data Cache ECC Present"
proc_set_display_group      setting_itcm_ecc_present                    "ECC"         1   "Instruction TCM ECC Present"
proc_set_display_group      setting_dtcm_ecc_present                    "ECC"         1   "Data TCM ECC Present"
proc_set_display_group      setting_mmu_ecc_present                     "ECC"         1   "MMU ECC Present"
proc_set_display_group      regfile_ramBlockType                        $REG_BLOCK_TYPE    1   "RAM block type"

# $MMU_MPU
add_display_item            ""                                          $MMU_MPU    GROUP tab
add_display_item            "$MMU_MPU"                                  $MMU        GROUP
add_display_item            "$MMU_MPU"                                  $MPU        GROUP
proc_set_display_group      mmu_processIDNumBits                        $MMU    0   "Process ID (PID) bits"
proc_set_display_group      mmu_autoAssignTlbPtrSz                      $MMU    0   "Optimize TLB entries base on device family"
proc_set_display_group      mmu_tlbPtrSz                                $MMU    0   "TLB entries"
proc_set_display_group      mmu_tlbNumWays                              $MMU    0   "TLB Set-Associativity"
proc_set_display_group      mmu_udtlbNumEntries                         $MMU    0   "Micro DTLB entries"
proc_set_display_group      mmu_uitlbNumEntries                         $MMU    0   "Micro ITLB entries"
proc_set_display_group      mmu_ramBlockType                            $MMU    1   "MMU RAM block type"
proc_set_display_group      mpu_useLimit                                $MPU    0   "Use Limit for region range"
proc_set_display_group      mpu_numOfDataRegion                         $MPU    0   "Number of data regions"
proc_set_display_group      mpu_minDataRegionSize                       $MPU    0   "Minimum data region size"
proc_set_display_group      mpu_numOfInstRegion                         $MPU    0   "Number of instruction regions"
proc_set_display_group      mpu_minInstRegionSize                       $MPU    0   "Minimum instruction region size"

# $DEBUG
add_display_item            ""                                          $DEBUG        GROUP       tab
add_display_item            "$DEBUG"                                    $DEBUG_1      GROUP
add_display_item            "$DEBUG"                                    $DEBUG_2      GROUP
add_display_item            "$DEBUG"                                    $DEBUG_3      GROUP
add_display_item            "$DEBUG"                                    $OCIMEM_BLOCK_TYPE      GROUP
proc_set_display_group      debug_level                                 $DEBUG_1      0   "Debug level"
add_text_message							$DEBUG_1      ${JTAG_DEBUG_TABLE}
proc_set_display_group      debug_debugReqSignals                       $DEBUG_1      0   "Include debugreq and debugack Signals"
add_text_message                                                        $DEBUG_1      "<html>${HTML_TAB}These signals appear on the top-level Qsys system.<br>${HTML_TAB}You must manually connect these signals to logic external to the Qsys system.</html>"
proc_set_display_group      debug_assignJtagInstanceID                  $DEBUG_1      1   "Assign JTAG Instance ID for debug core manually"
proc_set_display_group      debug_jtagInstanceID                        $DEBUG_1      1   "JTAG Instance ID value"
proc_set_display_group      breakSlave                                  $DEBUG_2      0   "Break vector memory"
proc_set_display_group      breakOffset                                 $DEBUG_2      0   "Break vector offset"
proc_set_display_group      breakAbsoluteAddr                           $DEBUG_2      0   "Break vector"
proc_set_display_group      debug_OCIOnchipTrace                        $DEBUG_3      0   "OCI Onchip Trace"
proc_set_display_group      debug_embeddedPLL                           $DEBUG_3      0   "Automatically generate internal 2x clock signal"
add_text_message                                                        $DEBUG_3      "<html>Advance debug licenses can be purchased from MIPS Technologies, Inc. <a href=http://www.mips.com/fs2redirect.htm target=_blank>http://www.mips.com/fs2redirect.htm</a></html>"
proc_set_display_group      ocimem_ramBlockType                         $OCIMEM_BLOCK_TYPE    1   "RAM block type"

# $TEST
#add_display_item            "$ADVANCED_5"                               $TEST       GROUP
proc_set_display_group      setting_performanceCounter                  $ADVANCED_5       1   "Performance counter"                       "INTERNAL"
proc_set_display_group      setting_perfCounterWidth                    $ADVANCED_5       1   "Performance counter width"                 "INTERNAL"
proc_set_display_group      setting_activateModelChecker                $ADVANCED_5       1   "Activate PLI model checker"                "INTERNAL"
proc_set_display_group      setting_activateTrace                       $ADVANCED_5       1   "Activate trace"                            "INTERNAL"
proc_set_display_group      setting_bit31BypassDCache                   $ADVANCED_5       1   "Bit 31 D-cache bypass"                     "INTERNAL"
proc_set_display_group      setting_fullWaveformSignals                 $ADVANCED_5       1   "Full Modelsim signals in waveforms"        "INTERNAL"
proc_set_display_group      setting_activateMonitors                    $ADVANCED_5       1   "Activate monitors"                         "INTERNAL"
proc_set_display_group      setting_allowFullAddressRange               $ADVANCED_5       1   "Allow full address range"                  "INTERNAL"
proc_set_display_group      setting_clearXBitsLDNonBypass               $ADVANCED_5       1   "Clear X data bits"                         "INTERNAL"
proc_set_display_group      setting_HDLSimCachesCleared                 $ADVANCED_5       1   "HDL simulation caches cleared"             "INTERNAL"
proc_set_display_group      setting_activateTestEndChecker              $ADVANCED_5       1   "Activate test end checker"                 "INTERNAL"
proc_set_display_group      setting_ecc_sim_test_ports                  $ADVANCED_5       1   "Enable ECC simulation test ports"          "INTERNAL"
proc_set_display_group      setting_alwaysEncrypt                       $ADVANCED_5       1   "Always encrypt"                            "INTERNAL"
proc_set_display_group      setting_debugSimGen                         $ADVANCED_5       1   "Debug Simgen"                              "INTERNAL"
proc_set_display_group      setting_HBreakTest                          $ADVANCED_5       1   "Hardware break test"                       "INTERNAL"
proc_set_display_group      setting_breakslaveoveride                   $ADVANCED_5       1   "Manually assign break slave"               "INTERNAL"
proc_set_display_group      setting_avalonDebugPortPresent              $ADVANCED_5       1   "Avalon Debug Port Present"                 "INTERNAL"
proc_set_display_group      debug_triggerArming                         $ADVANCED_5       1   "Trigger Arming"                            "INTERNAL"
proc_set_display_group      setting_export_large_RAMs                   $ADVANCED_5       1   "Export Large RAMs"                         "INTERNAL"
proc_set_display_group      setting_asic_enabled                        $ADVANCED_5       1   "ASIC enabled"                              "INTERNAL"
proc_set_display_group      setting_asic_synopsys_translate_on_off      $ADVANCED_5       1   "ASIC Synopsys translate"                   "INTERNAL"
proc_set_display_group      setting_oci_export_jtag_signals             $ADVANCED_5       1   "Export JTAG signals"                       "INTERNAL"
proc_set_display_group      setting_exportvectors                       $ADVANCED_5       1   "Export Vectors"                            "INTERNAL"
proc_set_display_group      userDefinedSettings                         $ADVANCED_5       1   "User Defined Settings"                     "INTERNAL"

# $CI
#add_display_item            ""                                          $CI        GROUP       tab
#add_text_message                                                         $CI      "Custom Instruction components can be edited through the Component Editor."

proc_set_display_format     resetOffset             "hexadecimal"
proc_set_display_format     resetAbsoluteAddr       "hexadecimal"
proc_set_display_format     exceptionOffset         "hexadecimal"
proc_set_display_format     exceptionAbsoluteAddr   "hexadecimal"
proc_set_display_format     mmu_TLBMissExcOffset    "hexadecimal"
proc_set_display_format     mmu_TLBMissExcAbsAddr   "hexadecimal"
proc_set_display_format     breakOffset             "hexadecimal"
proc_set_display_format     breakAbsoluteAddr       "hexadecimal"
proc_set_display_format     cpuID                   "hexadecimal"
proc_set_display_format     impl                    "radio"
proc_set_display_format     debug_level             "radio"

#------------------------------
# [4.3] SYSTEM_INFO Parameter
#------------------------------
proc_add_system_info_parameter          instAddrWidth                                       INTEGER         "1"                     "ADDRESS_WIDTH $I_MASTER_INTF"
proc_add_system_info_parameter          dataAddrWidth                                       INTEGER         "1"                     "ADDRESS_WIDTH $D_MASTER_INTF"
proc_add_system_info_parameter          tightlyCoupledDataMaster0AddrWidth                  INTEGER         "1"             		"ADDRESS_WIDTH tightly_coupled_data_master_0"
proc_add_system_info_parameter          tightlyCoupledDataMaster1AddrWidth                  INTEGER         "1"             		"ADDRESS_WIDTH tightly_coupled_data_master_1"
proc_add_system_info_parameter          tightlyCoupledDataMaster2AddrWidth                  INTEGER         "1"             		"ADDRESS_WIDTH tightly_coupled_data_master_2"
proc_add_system_info_parameter          tightlyCoupledDataMaster3AddrWidth                  INTEGER         "1"             		"ADDRESS_WIDTH tightly_coupled_data_master_3"
proc_add_system_info_parameter          tightlyCoupledInstructionMaster0AddrWidth           INTEGER         "1"             		"ADDRESS_WIDTH tightly_coupled_instruction_master_0"
proc_add_system_info_parameter          tightlyCoupledInstructionMaster1AddrWidth           INTEGER         "1"             		"ADDRESS_WIDTH tightly_coupled_instruction_master_1"
proc_add_system_info_parameter          tightlyCoupledInstructionMaster2AddrWidth           INTEGER         "1"             		"ADDRESS_WIDTH tightly_coupled_instruction_master_2"
proc_add_system_info_parameter          tightlyCoupledInstructionMaster3AddrWidth           INTEGER         "1"             		"ADDRESS_WIDTH tightly_coupled_instruction_master_3"
proc_add_system_info_parameter          instSlaveMapParam                                   STRING          ""                      "ADDRESS_MAP $I_MASTER_INTF"
proc_add_system_info_parameter          dataSlaveMapParam                                   STRING          ""                      "ADDRESS_MAP $D_MASTER_INTF"

proc_add_system_info_parameter          clockFrequency                                      LONG            "50000000"              "CLOCK_RATE $CLOCK_INTF"
proc_add_system_info_parameter          deviceFamilyName                                    STRING          "STRATIXIV"             "DEVICE_FAMILY"
proc_add_system_info_parameter          internalIrqMaskSystemInfo                           LONG            "0x0"                   "INTERRUPTS_USED $D_IRQ_INTF"


proc_add_system_info_parameter          customInstSlavesSystemInfo                           STRING          ""                      "CUSTOM_INSTRUCTION_SLAVES $CI_MASTER_INTF"
proc_add_system_info_parameter          deviceFeaturesSystemInfo                             STRING          ""                      "DEVICE_FEATURES"

proc_add_system_info_parameter          tightlyCoupledDataMaster0MapParam                    STRING          ""          		     "ADDRESS_MAP tightly_coupled_data_master_0"
proc_add_system_info_parameter          tightlyCoupledDataMaster1MapParam                    STRING          ""          		     "ADDRESS_MAP tightly_coupled_data_master_1"
proc_add_system_info_parameter          tightlyCoupledDataMaster2MapParam                    STRING          ""          		     "ADDRESS_MAP tightly_coupled_data_master_2"
proc_add_system_info_parameter          tightlyCoupledDataMaster3MapParam                    STRING          ""          		     "ADDRESS_MAP tightly_coupled_data_master_3"
proc_add_system_info_parameter          tightlyCoupledInstructionMaster0MapParam             STRING          ""          		     "ADDRESS_MAP tightly_coupled_instruction_master_0"
proc_add_system_info_parameter          tightlyCoupledInstructionMaster1MapParam             STRING          ""          		     "ADDRESS_MAP tightly_coupled_instruction_master_1"
proc_add_system_info_parameter          tightlyCoupledInstructionMaster2MapParam             STRING          ""          		     "ADDRESS_MAP tightly_coupled_instruction_master_2"
proc_add_system_info_parameter          tightlyCoupledInstructionMaster3MapParam             STRING          ""          		     "ADDRESS_MAP tightly_coupled_instruction_master_3"





#-------------------------------------------------------------------------------
# [5] INTERFACE
#-------------------------------------------------------------------------------

#------------------------------
# [5.1] Clock Interface
#------------------------------
add_interface           $CLOCK_INTF     "clock"     "sink"
add_interface_port      $CLOCK_INTF     "clk"       "clk"       "input"     1

#------------------------------
# [5.2] Reset Interface
#------------------------------
add_interface           reset_n     "reset"     "sink"      $CLOCK_INTF      
add_interface_port      reset_n     "reset_n"   "reset_n"   "input"     1

#------------------------------
# In elaborate callback:-
# [6.1] Data Master Interface
# [6.2] Instruction Master Interface 
# [6.3] Tightly Couple Data Master 
# [6.4] Tightly Couple Instruction Master
# [6.5] Interrupt Interface
# [6.6] Jtag Debug Module Interface
# [6.7] Avalon Debug Port Interface
# [6.8] Custom Instruction Interface 
# [6.9]Processor Instruction and Data Master
# [6.10] Conduit Interface
# [6.11] Avalon Hardware Break Interrupt Controller
#------------------------------

#------------------------------------------------------------------------------
# [6] ELABORATION Callback
#------------------------------------------------------------------------------

#------------------------------
# [6.3] T.C.Data.Master Interface
#------------------------------
proc sub_elaborate_tcdm_interface {} {
    global TCD_INTF_PREFIX
    global TCD_PREFIX
    global CLOCK_INTF

    set tcdm_num    [ get_parameter_value dcache_numTCDM ]
    set impl        [ get_parameter_value impl ]
    set data_width  32

    if { "${impl}" == "Fast" } {
        set ecc_present [ proc_get_boolean_parameter setting_ecc_present ]
        set dtcm_ecc_present [ proc_get_boolean_parameter setting_dtcm_ecc_present ]
        if { $ecc_present & "${impl}" == "Fast" & $dtcm_ecc_present } {
            set data_width 39
        }
        foreach i {0 1 2 3} {
            set INTF_NAME "${TCD_INTF_PREFIX}${i}"
            set TCD_NAME  "${TCD_PREFIX}${i}"
            if { $i < $tcdm_num } {               
                set local_daddr_width [ get_parameter_value ${TCD_NAME}AddrWidth ]
                add_interface           $INTF_NAME      "avalon"                    "master"            $CLOCK_INTF
                add_interface_port      $INTF_NAME      "dcm${i}_readdata"          "readdata"          "input"     $data_width
                add_interface_port      $INTF_NAME      "dcm${i}_waitrequest"       "waitrequest"       "input"     1
                add_interface_port      $INTF_NAME      "dcm${i}_readdatavalid"     "readdatavalid"     "input"     1
                add_interface_port      $INTF_NAME      "dcm${i}_address"           "address"           "output"    $local_daddr_width
                add_interface_port      $INTF_NAME      "dcm${i}_read"              "read"              "output"    1
                add_interface_port      $INTF_NAME      "dcm${i}_clken"             "clken"             "output"    1
                add_interface_port      $INTF_NAME      "dcm${i}_write"             "write"             "output"    1
                add_interface_port      $INTF_NAME      "dcm${i}_writedata"         "writedata"         "output"    $data_width
                if { $dtcm_ecc_present & $ecc_present } {
                    set_interface_property  $INTF_NAME      "bitsPerSymbol"     "39"
                } else {
                    add_interface_port      $INTF_NAME      "dcm${i}_byteenable"        "byteenable"        "output"    4
                }
                set_interface_property  $INTF_NAME      "addressGroup"              "1"
                set_interface_property  $INTF_NAME      "registerIncomingSignals"   "false"
                set_interface_property  $INTF_NAME      "ENABLED"                   "true"
                set_interface_property  $INTF_NAME      "associatedReset"           "reset_n"
            }
        }
    }
}


#------------------------------
# [6.4] T.C.Inst.Master Interface
#------------------------------
proc sub_elaborate_tcim_interface {} {
    global TCI_INTF_PREFIX
    global TCI_PREFIX
    global CLOCK_INTF
    set tcim_num    [ get_parameter_value icache_numTCIM ]
    set impl        [ get_parameter_value impl ]
    set ecc_present [ proc_get_boolean_parameter setting_ecc_present ]
    set itcm_ecc_present [ proc_get_boolean_parameter setting_itcm_ecc_present ]
    set data_width  32

    if { $ecc_present & "${impl}" == "Fast" & $itcm_ecc_present } {
        set data_width 39
    }

    if { "${impl}" != "Tiny" } {
        foreach i {0 1 2 3} {
            set INTF_NAME "${TCI_INTF_PREFIX}${i}"
            set TCI_NAME  "${TCI_PREFIX}${i}"
            
            if { $i < $tcim_num } {
                set local_iaddr_width [ get_parameter_value ${TCI_NAME}AddrWidth ]
                add_interface           $INTF_NAME      "avalon"                    "master"            $CLOCK_INTF
                add_interface_port      $INTF_NAME      "icm${i}_readdata"          "readdata"          "input"     $data_width
                add_interface_port      $INTF_NAME      "icm${i}_waitrequest"       "waitrequest"       "input"     1
                add_interface_port      $INTF_NAME      "icm${i}_readdatavalid"     "readdatavalid"     "input"     1
                add_interface_port      $INTF_NAME      "icm${i}_address"           "address"           "output"    $local_iaddr_width
                add_interface_port      $INTF_NAME      "icm${i}_read"              "read"              "output"    1
                add_interface_port      $INTF_NAME      "icm${i}_clken"             "clken"             "output"    1
                set_interface_property  $INTF_NAME      "addressGroup"              "1"
                set_interface_property  $INTF_NAME      "registerIncomingSignals"   "false"
                set_interface_property  $INTF_NAME      "ENABLED"                   "true"
                set_interface_property  $INTF_NAME      "associatedReset"           "reset_n"
                
                # When ECC enabled, allow write ports for recoverable ECC error
                if { $ecc_present & "${impl}" == "Fast" & $itcm_ecc_present } {
                    add_interface_port      $INTF_NAME      "icm${i}_writedata"     "writedata"         "output"    $data_width
                    add_interface_port      $INTF_NAME      "icm${i}_write"         "write"             "output"    1
                    set_interface_property  $INTF_NAME      "bitsPerSymbol"     "39"
                }
            }
        }
    }
}


#------------------------------
# [6.5] Interrupt Interfaces - irq receiver / eic st port
#------------------------------
proc sub_elaborate_interrupt_controller_ports {} {
    global D_IRQ_INTF
    global EXT_IRQ_INTF
    global CLOCK_INTF
    global D_MASTER_INTF
    
    set data_master_present             [ proc_get_data_master_present ]
    
    if { [ proc_get_eic_present ] } {
        # External IRQ Controller
        add_interface           $EXT_IRQ_INTF   "avalon_streaming"                  "end"                   $CLOCK_INTF
        add_interface_port      $EXT_IRQ_INTF   "eic_port_valid"                    "valid"                 "input"     1
        add_interface_port      $EXT_IRQ_INTF   "eic_port_data"                     "data"                  "input"     45
        set_interface_property  $EXT_IRQ_INTF   "symbolsPerBeat"                    "1"
        set_interface_property  $EXT_IRQ_INTF   "dataBitsPerSymbol"                 "45"
        set_interface_property  $EXT_IRQ_INTF   "ENABLED"                           "true"
        set_interface_property  $EXT_IRQ_INTF   "associatedReset"                   "reset_n"
        proc_set_interface_embeddedsw_configuration_assignment $EXT_IRQ_INTF "isInterruptControllerReceiver" 1
    } elseif { $data_master_present } {
        # Internal IRQ Controller
        add_interface           $D_IRQ_INTF     "interrupt"                         "receiver"              $CLOCK_INTF
        add_interface_port      $D_IRQ_INTF     "d_irq"                             "irq"                   "input"     32
        set_interface_property  $D_IRQ_INTF     "irqScheme"                         "individualRequests"
        set_interface_property  $D_IRQ_INTF     "associatedAddressablePoint"        $D_MASTER_INTF
        set_interface_property  $D_IRQ_INTF     "ENABLED"                           "true"
        set_interface_property  $D_IRQ_INTF     "associatedReset"                   "reset_n"
    }
}

#------------------------------
# [6.11] hbreak Interrupt Interfaces - irq receiver
#------------------------------
proc sub_elaborate_hbreak_interrupt_controller_ports {} {
	global HBREAK_IRQ_INTF
	global CLOCK_INTF
	global I_MASTER_INTF
	
	set local_impl [ get_parameter_value impl ]

	if { [ proc_get_boolean_parameter setting_HBreakTest ] } {
		add_interface           $HBREAK_IRQ_INTF     "interrupt"                         "receiver"              $CLOCK_INTF
		if { "$local_impl" == "Tiny" } {
			add_interface_port      $HBREAK_IRQ_INTF     "test_hbreak_req"                   "irq"                   "input"     1
		} else {
			add_interface_port      $HBREAK_IRQ_INTF     "test_hbreak_req"                   "irq"                   "input"     32
		}
		set_interface_property  $HBREAK_IRQ_INTF     "irqScheme"                         "individualRequests"
		set_interface_property  $HBREAK_IRQ_INTF     "associatedAddressablePoint"        $I_MASTER_INTF
		set_interface_property  $HBREAK_IRQ_INTF     "ENABLED"                           "true"
	}
}

#------------------------------
# [6.6] Jtag Debug Module interface
#------------------------------
proc sub_elaborate_jtag_debug_module_interface {} {
    global DEBUG_INTF
    global CLOCK_INTF
    global I_MASTER_INTF
    global D_MASTER_INTF

    set local_debug_level [ get_parameter_value debug_level ]
    if { "${local_debug_level}" != "NoDebug" } {
        # SPR:350621 resetrequest no longer valid in avalon interface
        add_interface           jtag_debug_module_reset      "reset"                "output"        $CLOCK_INTF
        add_interface_port      jtag_debug_module_reset     "jtag_debug_module_resetrequest"        "reset"     "output"        1
        # SPR:355400 to break reset loop when global reset is on
        set_interface_property  jtag_debug_module_reset     "associatedResetSinks"  "none"
        
        add_interface           $DEBUG_INTF     "avalon"                            "slave"                 $CLOCK_INTF

        add_interface_port      $DEBUG_INTF     "jtag_debug_module_address"         "address"               "input"        9
        add_interface_port      $DEBUG_INTF     "jtag_debug_module_byteenable"      "byteenable"            "input"        4
        add_interface_port      $DEBUG_INTF     "jtag_debug_module_debugaccess"     "debugaccess"           "input"        1
        add_interface_port      $DEBUG_INTF     "jtag_debug_module_read"            "read"                  "input"        1
        add_interface_port      $DEBUG_INTF     "jtag_debug_module_readdata"        "readdata"              "output"       32
        add_interface_port      $DEBUG_INTF     "jtag_debug_module_waitrequest"     "waitrequest"           "output"       1
        add_interface_port      $DEBUG_INTF     "jtag_debug_module_write"           "write"                 "input"        1
        add_interface_port      $DEBUG_INTF     "jtag_debug_module_writedata"       "writedata"             "input"        32
        set_interface_property  $DEBUG_INTF     "maximumPendingReadTransactions"    "0"
        set_interface_property  $DEBUG_INTF     "associatedClock"                   "$CLOCK_INTF"
        set_interface_property  $DEBUG_INTF     "alwaysBurstMaxBurst"               "false"
        set_interface_property  $DEBUG_INTF     "isMemoryDevice"                    "true"
        set_interface_property  $DEBUG_INTF     "registerIncomingSignals"           "true"
        set_interface_property  $DEBUG_INTF     "associatedReset"                   "reset_n"
        set_interface_property  $DEBUG_INTF     "ENABLED"                           "true"
        set_interface_assignment $DEBUG_INTF    "qsys.ui.connect"                   "${I_MASTER_INTF},${D_MASTER_INTF}"
        
        proc_set_interface_embeddedsw_configuration_assignment $DEBUG_INTF     "hideDevice" 1
        # We support two IDs for Nios II, need to register both so SystemConsole can bind
        set_module_assignment debug.hostConnection {type jtag id 70:34|110:135}

        # TODO: finish proper interface property settings
            #    Address_Alignment = "dynamic";
            #    Well_Behaved_Waitrequest = "0";
            #    Minimum_Uninterrupted_Run_Length = "1";
            #    Accepts_Internal_Connections = "1";
            #    Write_Latency = "0";
            #    Register_Incoming_Signals = "0";
            #    Register_Outgoing_Signals = "0";
            #    Always_Burst_Max_Burst = "0";
            #    Is_Big_Endian = "0";
            #    Is_Enabled = "1";
            #    Accepts_External_Connections = "1";
            #    Requires_Internal_Connections = "";
    }
}

#------------------------------
# [6.7] Avalon debug port
#------------------------------
proc sub_elaborate_avalon_debug_port_interface {} {
    global AV_DEBUG_PORT
    global CLOCK_INTF
    
    set local_debug_level [ get_parameter_value debug_level ]
    if { "${local_debug_level}" != "NoDebug" } {
	    set AVALON_DEBUG_PORT_PRESENT [ get_parameter_value setting_avalonDebugPortPresent ]
	    if { $AVALON_DEBUG_PORT_PRESENT } {
		add_interface          $AV_DEBUG_PORT "avalon"                          "slave"         $CLOCK_INTF
		add_interface_port     $AV_DEBUG_PORT "avalon_debug_port_address"       "address"       "input"        2
		add_interface_port     $AV_DEBUG_PORT "avalon_debug_port_readdata"      "readdata"      "output"       32
		add_interface_port     $AV_DEBUG_PORT "avalon_debug_port_write"         "write"         "input"        1
		add_interface_port     $AV_DEBUG_PORT "avalon_debug_port_writedata"     "writedata"     "input"        32
		set_interface_property $AV_DEBUG_PORT "maximumPendingReadTransactions"  "0"
		set_interface_property $AV_DEBUG_PORT "isMemoryDevice"                  "false"
		set_interface_property $AV_DEBUG_PORT "associatedReset"                 "reset_n"
	    }
    }
}

#------------------------------
# [6.1] D-Master Interface
#------------------------------
proc sub_elaborate_datam_interface {} {
    global D_MASTER_INTF
    global CLOCK_INTF
    
    set data_master_present     [ proc_get_data_master_present ]

    if { $data_master_present } {
            add_interface           $D_MASTER_INTF   "avalon"            "master"            $CLOCK_INTF
            set_interface_property  $D_MASTER_INTF   "burstOnBurstBoundariesOnly"           "true"
            set_interface_property  $D_MASTER_INTF   "linewrapBursts"                       "false"
            set_interface_property  $D_MASTER_INTF   "alwaysBurstMaxBurst"                  "false"
            set_interface_property  $D_MASTER_INTF   "doStreamReads"                        "false"
            set_interface_property  $D_MASTER_INTF   "doStreamWrites"                       "false"
            set_interface_property  $D_MASTER_INTF   "addressGroup"                         "1"
            set_interface_property	$D_MASTER_INTF	 "registerIncomingSignals"		        "true"
            set_interface_property  $D_MASTER_INTF   "associatedReset"                      "reset_n"
            add_interface_port      $D_MASTER_INTF   "d_address"         "address"           "output"    32
            add_interface_port      $D_MASTER_INTF   "d_byteenable"      "byteenable"        "output"    4
            add_interface_port      $D_MASTER_INTF   "d_read"            "read"              "output"    1
            add_interface_port      $D_MASTER_INTF   "d_readdata"        "readdata"          "input"     32
            add_interface_port      $D_MASTER_INTF   "d_waitrequest"     "waitrequest"       "input"     1
            add_interface_port      $D_MASTER_INTF   "d_write"           "write"             "output"    1
            add_interface_port      $D_MASTER_INTF   "d_writedata"       "writedata"         "output"    32
            set_interface_assignment $D_MASTER_INTF  "debug.providesServices" "master"
            
            set_port_property d_address WIDTH [ get_parameter_value dataAddrWidth ]
    }
}

#------------------------------
# [6.2] I-Master Interface
#------------------------------
proc sub_elaborate_instructionm_interface {} {
    global I_MASTER_INTF
    global CLOCK_INTF

    set inst_master_present             [ proc_get_inst_master_present ]
    
    if { $inst_master_present } {
        add_interface           $I_MASTER_INTF   "avalon"            "master"            $CLOCK_INTF
        set_interface_property  $I_MASTER_INTF   "burstOnBurstBoundariesOnly"           "false"
        set_interface_property  $I_MASTER_INTF   "linewrapBursts"                       "true"
        set_interface_property  $I_MASTER_INTF   "alwaysBurstMaxBurst"                  "true"
        set_interface_property  $I_MASTER_INTF   "doStreamReads"                        "false"
        set_interface_property  $I_MASTER_INTF   "doStreamWrites"                       "false"
        set_interface_property  $I_MASTER_INTF   "addressGroup"                         "1"
        set_interface_property  $I_MASTER_INTF   "associatedReset"                      "reset_n"
        #set_interface_property	$I_MASTER_INTF	 "registerIncomingSignals"		"true"
        add_interface_port      $I_MASTER_INTF  "i_address"         "address"           "output"    1
        add_interface_port      $I_MASTER_INTF  "i_read"            "read"              "output"    1
        add_interface_port      $I_MASTER_INTF  "i_readdata"        "readdata"          "input"     32
        add_interface_port      $I_MASTER_INTF  "i_waitrequest"     "waitrequest"       "input"     1
        #add_interface_port      $I_MASTER_INTF  "i_readdatavalid"     "readdatavalid"       "input"     1
        
        set_port_property i_address WIDTH [ get_parameter_value instAddrWidth ]
    }
}

#------------------------------
# [6.8] Custom Instruction
#------------------------------
proc sub_elaborate_custom_instruction {} {
        
    global  CLOCK_INTF
    global  CI_MASTER_INTF
    
    set has_any_ci      [ proc_has_any_ci_slave ]
    set has_combo_ci    [ proc_has_combo_ci_slave ]
    set has_multi_ci    [ proc_has_multi_ci_slave ]
    set local_impl [ get_parameter_value impl ]
    
    add_interface       $CI_MASTER_INTF     "nios_custom_instruction"       "master"
    
    
    if { $has_any_ci } {
        if { "$local_impl" == "Fast" } {
            if { $has_multi_ci  } {
                #MULTI
                # inputs:
                add_interface_port $CI_MASTER_INTF   "A_ci_multi_done"       "done"             "input"     1
                add_interface_port $CI_MASTER_INTF   "A_ci_multi_result"     "multi_result"     "input"     32
                # outputs:
                add_interface_port $CI_MASTER_INTF   "A_ci_multi_a"          "multi_a"          "output"    5
                add_interface_port $CI_MASTER_INTF   "A_ci_multi_b"          "multi_b"          "output"    5
                add_interface_port $CI_MASTER_INTF   "A_ci_multi_c"          "multi_c"          "output"    5
                add_interface_port $CI_MASTER_INTF   "A_ci_multi_clk_en"     "clk_en"           "output"    1
                add_interface_port $CI_MASTER_INTF   "A_ci_multi_clock"      "clk"              "output"    1
                add_interface_port $CI_MASTER_INTF   "A_ci_multi_reset"      "reset"            "output"    1
                add_interface_port $CI_MASTER_INTF   "A_ci_multi_reset_req"  "reset_req"        "output"    1
                add_interface_port $CI_MASTER_INTF   "A_ci_multi_dataa"      "multi_dataa"      "output"    32
                add_interface_port $CI_MASTER_INTF   "A_ci_multi_datab"      "multi_datab"      "output"    32
                #add_interface_port $CI_MASTER_INTF   "A_ci_multi_estatus"    "multi_estatus"    "output"    1
                #add_interface_port $CI_MASTER_INTF   "A_ci_multi_ipending"   "multi_ipending"   "output"    32
                add_interface_port $CI_MASTER_INTF   "A_ci_multi_n"          "multi_n"          "output"    8
                add_interface_port $CI_MASTER_INTF   "A_ci_multi_readra"     "multi_readra"     "output"    1
                add_interface_port $CI_MASTER_INTF   "A_ci_multi_readrb"     "multi_readrb"     "output"    1
                add_interface_port $CI_MASTER_INTF   "A_ci_multi_start"      "start"            "output"    1
                #add_interface_port $CI_MASTER_INTF   "A_ci_multi_status"     "multi_status"     "output"    1
                add_interface_port $CI_MASTER_INTF   "A_ci_multi_writerc"    "multi_writerc"    "output"    1
            }
            if { $has_combo_ci } {
                #COMBI
                # inputs:
                add_interface_port $CI_MASTER_INTF   "E_ci_combo_result"     "result"           "input"     32
                # outputs:
                add_interface_port $CI_MASTER_INTF   "E_ci_combo_a"          "a"                "output"    5
                add_interface_port $CI_MASTER_INTF   "E_ci_combo_b"          "b"                "output"    5
                add_interface_port $CI_MASTER_INTF   "E_ci_combo_c"          "c"                "output"    5
                add_interface_port $CI_MASTER_INTF   "E_ci_combo_dataa"      "dataa"            "output"    32
                add_interface_port $CI_MASTER_INTF   "E_ci_combo_datab"      "datab"            "output"    32
                #add_interface_port $CI_MASTER_INTF   "E_ci_combo_estatus"    "estatus"          "output"    1
                #add_interface_port $CI_MASTER_INTF   "E_ci_combo_ipending"   "ipending"         "output"    32
                add_interface_port $CI_MASTER_INTF   "E_ci_combo_n"          "n"                "output"    8
                add_interface_port $CI_MASTER_INTF   "E_ci_combo_readra"     "readra"           "output"    1
                add_interface_port $CI_MASTER_INTF   "E_ci_combo_readrb"     "readrb"           "output"    1
                #add_interface_port $CI_MASTER_INTF   "E_ci_combo_status"     "status"           "output"    1
                add_interface_port $CI_MASTER_INTF   "E_ci_combo_writerc"    "writerc"          "output"    1
            }
        } elseif { "$local_impl" == "Small" } {
            if { $has_multi_ci  } {
                #MULTI
                # inputs:
                add_interface_port $CI_MASTER_INTF   "M_ci_multi_done"       "done"             "input"     1
                add_interface_port $CI_MASTER_INTF   "M_ci_multi_result"     "multi_result"     "input"     32
                # outputs:
                add_interface_port $CI_MASTER_INTF   "M_ci_multi_a"          "multi_a"          "output"    5
                add_interface_port $CI_MASTER_INTF   "M_ci_multi_b"          "multi_b"          "output"    5
                add_interface_port $CI_MASTER_INTF   "M_ci_multi_c"          "multi_c"          "output"    5
                add_interface_port $CI_MASTER_INTF   "M_ci_multi_clk_en"     "clk_en"           "output"    1
                add_interface_port $CI_MASTER_INTF   "A_ci_multi_clock"      "clk"              "output"    1
                add_interface_port $CI_MASTER_INTF   "A_ci_multi_reset"      "reset"            "output"    1
                add_interface_port $CI_MASTER_INTF   "A_ci_multi_reset_req"  "reset_req"        "output"    1
                add_interface_port $CI_MASTER_INTF   "M_ci_multi_dataa"      "multi_dataa"      "output"    32
                add_interface_port $CI_MASTER_INTF   "M_ci_multi_datab"      "multi_datab"      "output"    32
                #add_interface_port $CI_MASTER_INTF   "M_ci_multi_estatus"    "multi_estatus"    "output"    1
                #add_interface_port $CI_MASTER_INTF   "M_ci_multi_ipending"   "multi_ipending"   "output"    32
                add_interface_port $CI_MASTER_INTF   "M_ci_multi_n"          "multi_n"          "output"    8
                add_interface_port $CI_MASTER_INTF   "M_ci_multi_readra"     "multi_readra"     "output"    1
                add_interface_port $CI_MASTER_INTF   "M_ci_multi_readrb"     "multi_readrb"     "output"    1
                add_interface_port $CI_MASTER_INTF   "M_ci_multi_start"      "start"            "output"    1
                #add_interface_port $CI_MASTER_INTF   "M_ci_multi_status"     "multi_status"     "output"    1
                add_interface_port $CI_MASTER_INTF   "M_ci_multi_writerc"    "multi_writerc"    "output"    1
            }
            if { $has_combo_ci } {
                #COMBI
                # inputs:
                add_interface_port $CI_MASTER_INTF   "E_ci_combo_result"     "result"           "input"     32
                # outputs:
                add_interface_port $CI_MASTER_INTF   "E_ci_combo_a"          "a"                "output"    5
                add_interface_port $CI_MASTER_INTF   "E_ci_combo_b"          "b"                "output"    5
                add_interface_port $CI_MASTER_INTF   "E_ci_combo_c"          "c"                "output"    5
                add_interface_port $CI_MASTER_INTF   "E_ci_combo_dataa"      "dataa"            "output"    32
                add_interface_port $CI_MASTER_INTF   "E_ci_combo_datab"      "datab"            "output"    32
                #add_interface_port $CI_MASTER_INTF   "E_ci_combo_estatus"    "estatus"          "output"    1
                #add_interface_port $CI_MASTER_INTF   "E_ci_combo_ipending"   "ipending"         "output"    32
                add_interface_port $CI_MASTER_INTF   "E_ci_combo_n"          "n"                "output"    8
                add_interface_port $CI_MASTER_INTF   "E_ci_combo_readra"     "readra"           "output"    1
                add_interface_port $CI_MASTER_INTF   "E_ci_combo_readrb"     "readrb"           "output"    1
                #add_interface_port $CI_MASTER_INTF   "E_ci_combo_status"     "status"           "output"    1
                add_interface_port $CI_MASTER_INTF   "E_ci_combo_writerc"    "writerc"          "output"    1
            }
        } elseif { "$local_impl" == "Tiny" } {
            if { $has_multi_ci  } {
                # inputs:
                add_interface_port $CI_MASTER_INTF     "E_ci_multi_done"     "done"          "input"         1
                # outputs:
                add_interface_port $CI_MASTER_INTF     "E_ci_multi_clk_en"   "clk_en"        "output"        1                
                add_interface_port $CI_MASTER_INTF     "E_ci_multi_start"    "start"         "output"        1
                }
                # inputs:
                add_interface_port $CI_MASTER_INTF     "E_ci_result"         "result"        "input"         32
                # outputs:
                add_interface_port $CI_MASTER_INTF     "D_ci_a"              "a"             "output"        5
                add_interface_port $CI_MASTER_INTF     "D_ci_b"              "b"             "output"        5
                add_interface_port $CI_MASTER_INTF     "D_ci_c"              "c"             "output"        5
                add_interface_port $CI_MASTER_INTF     "D_ci_n"              "n"             "output"        8
                add_interface_port $CI_MASTER_INTF     "D_ci_readra"         "readra"        "output"        1
                add_interface_port $CI_MASTER_INTF     "D_ci_readrb"         "readrb"        "output"        1
                add_interface_port $CI_MASTER_INTF     "D_ci_writerc"        "writerc"       "output"        1
                add_interface_port $CI_MASTER_INTF     "E_ci_dataa"          "dataa"         "output"        32
                add_interface_port $CI_MASTER_INTF     "E_ci_datab"          "datab"         "output"        32
                add_interface_port $CI_MASTER_INTF     "E_ci_multi_clock"    "clk"           "output"        1
                add_interface_port $CI_MASTER_INTF     "E_ci_multi_reset"    "reset"         "output"        1
                add_interface_port $CI_MASTER_INTF     "E_ci_multi_reset_req"   "reset_req"     "output"        1
                #add_interface_port $CI_MASTER_INTF     "W_ci_estatus"        "estatus"       "output"        1
                #add_interface_port $CI_MASTER_INTF     "W_ci_ipending"       "ipending"      "output"        32
                #add_interface_port $CI_MASTER_INTF     "W_ci_status"         "status"        "output"        1
            
            # Special requirement for e core
            set_interface_property $CI_MASTER_INTF  "sharedCombinationalAndMulticycle"  "true"
        }
    } else {
        # No CI Slave, just put any thing here for termination
        add_interface_port $CI_MASTER_INTF   "no_ci_readra"         "readra"        "output"        1
    }
}

#------------------------------
# [6.9] Update Instruction Master & Data Master Interface
#------------------------------
proc sub_elaborate_update_processor_inst_and_data_master {} {


    # I-Master & D-Master may not present
    # Which is is true?
    # [SH] - inst_master not present when icache_size = 0
    # [SH] - data_master not present when omit_data_master = true and num_tcdm != 0
    #
    # set inst_master_present     [ expr { "$impl" == "Tiny" } || { "$icache_size" != "0" } ]
    # set data_master_present     [ expr { "$impl" != "Fast" } || { "$dcache_omitDataMaster" == "0" } || { "$dcache_size" != "0" } || { "$tcdm_num" == "0" } ]

    # Width
    #set_port_property i_address WIDTH [ get_parameter_value instAddrWidth ]
    #set_port_property d_address WIDTH [ get_parameter_value dataAddrWidth ]

    # Burst
    global I_MASTER_INTF
    global D_MASTER_INTF

    set impl                            [ get_parameter_value impl ]
    set dcache_omitDataMaster           [ proc_get_boolean_parameter dcache_omitDataMaster ]
    set tcdm_num                        [ get_parameter_value dcache_numTCDM ]

    # i_burstcount
    # if I-cache burst is turn on, i_burstcount width is always 4 bit wide
    set local_icache_bursttype      [ get_parameter_value icache_burstType ]
    set icache_size [get_parameter_value icache_size]
    set has_i_burstcount [ expr { "$icache_size" != "0" } && { "$impl" != "Tiny" } && { "$local_icache_bursttype" != "None" } ]

    if { $has_i_burstcount } {
        add_interface_port      $I_MASTER_INTF  "i_burstcount"         "burstcount"           "output"    4
    }

    # d_burstcount
    # if D-cache burst is turn on, d_burstcount width is
    #   not exist for 4 bit cache line size
    #   3 bit wide for 16 bit cache line size
    #   4 bit wide for 32 bit cache line size
    set local_dcache_burst_derived       [ proc_get_boolean_parameter dcache_bursts_derived ]
    set local_dcache_linesize_derived    [ get_parameter_value dcache_lineSize_derived ]
    set local_dcache_size_derived        [get_parameter_value dcache_size_derived]
    set has_d_burstcount [ expr { "$impl" == "Fast" } && { "$local_dcache_linesize_derived" != "4" } && { "$local_dcache_size_derived" != "0" } && { $local_dcache_burst_derived } ]
    set data_master_present             [ proc_get_data_master_present ]

    if { "$local_dcache_linesize_derived" == "16"  } {
        set local_d_burstcount_width 3
    } elseif { "$local_dcache_linesize_derived" == "32" } {
        set local_d_burstcount_width 4
    } else {
        set local_d_burstcount_width    0
    }

    if { $has_d_burstcount } {
        add_interface_port      $D_MASTER_INTF  "d_burstcount"         "burstcount"           "output"    $local_d_burstcount_width
    }

    # d_readdatavalid
    # only present in "Fast" core & dcachelinesize != 4
    set impl [get_parameter_value impl]
    set d_readdatavalid_exist [ expr  { "$impl" == "Fast" } && { "$local_dcache_linesize_derived" != "4" } && { "$local_dcache_size_derived" != "0" } ]
    if { $d_readdatavalid_exist } {
        add_interface_port      $D_MASTER_INTF  "d_readdatavalid"   "readdatavalid"     "input"     1

    }
    
    # d_master registerIncomingSignals
    set has_dcache [ expr { "$impl" == "Fast" } && { "$local_dcache_size_derived" != "0" } ]
    set dcache_omitDataMaster [ proc_get_boolean_parameter dcache_omitDataMaster ]
    
    if { "$data_master_present" == "1" } {
        if { "$has_dcache" == "1" } {
                if { "$local_dcache_linesize_derived" > "4" } {
                        set_interface_property  $D_MASTER_INTF     "registerIncomingSignals"           "false"
                } else {
                        set_interface_property  $D_MASTER_INTF     "registerIncomingSignals"           "true"
                }
        } elseif { [expr { ! $dcache_omitDataMaster } && { $impl != "Tiny" }] } {
                set_interface_property  $D_MASTER_INTF     "registerIncomingSignals"           "false"
        } else {
                set_interface_property  $D_MASTER_INTF     "registerIncomingSignals"           "true"
        }
    }

    # i_readdatavalid
    set has_i_readdatavalid [ expr { "$impl" != "Tiny" } && { "$icache_size" != "0" } ]
    if { $has_i_readdatavalid } {
        add_interface_port      $I_MASTER_INTF  "i_readdatavalid"   "readdatavalid"     "input"     1

    }

    # jtag_debug_module_debugaccess_to_roms only exist when debug there is jtag debug module
    set debug_level [ get_parameter_value debug_level ]
    if { [ expr { "$debug_level" != "NoDebug" } && { $data_master_present } ] } {
        add_interface_port      $D_MASTER_INTF  "jtag_debug_module_debugaccess_to_roms"   "debugaccess"   "output"        1
    }

}

#------------------------------
# [6.10] Conduite Interfaces :-
#           2 : Hidden Option : cpu_resetrequest & cpu_resettaken
#           3 : Hidden Option : pc & pc_valid
#           4 : Hidden Option : oci_hbreak_req & test_hbreak_req, test_hbreak_req does not pop up to top level
#           5 : Hidden Option : export large rams (icache, dcache, mmu, oci_ram, trace_ram)
#           6 : Hidden Option : asic enabled
#           7 : Hidden Option : oci export jtag signals
#------------------------------
proc sub_elaborate_conduit_interfaces {} {
    global DEBUG_INTF
    global CPU_RESET
    global PROGRAM_COUNTER
    global HW_BREAKTEST
    global CLOCK_INTF
    global ECC_EVENT

    set include_debug_debugReqSignals   [ proc_get_boolean_parameter debug_debugReqSignals ]
    set local_debug_level               [ get_parameter_value debug_level ]
    set local_cpuresetrequest           [ proc_get_boolean_parameter cpuReset ]
    set local_exportPCB                 [ proc_get_boolean_parameter setting_exportPCB ]
    set local_exportvectors             [ proc_get_boolean_parameter setting_exportvectors     ]
    set local_export_large_RAMs         [ proc_get_boolean_parameter setting_export_large_RAMs ]
    set local_asic_enabled              [ proc_get_boolean_parameter setting_asic_enabled ]
    set local_oci_export_jtag_signals   [ proc_get_boolean_parameter setting_oci_export_jtag_signals ]
    set local_HBreakTest                [ proc_get_boolean_parameter setting_HBreakTest ]
    set local_use_embeddedPLL           [ proc_get_boolean_parameter debug_embeddedPLL ]
    set local_instaddrwidth             [ get_parameter_value instAddrWidth ]
    set local_mmu_enable                [ proc_get_boolean_parameter mmu_enabled ]
    set local_avalon_debug_present      [ proc_get_boolean_parameter setting_avalonDebugPortPresent ]

    # Europa always default to 18. (oci_tm_width>>1), where oci_tm_width=dmaster_data_width+4
    set local_oci_tr_width              18

    if { "${local_debug_level}" != "NoDebug" } {
      if { $include_debug_debugReqSignals } {
          add_interface         ${DEBUG_INTF}_conduit   "conduit"                   "end"
          add_interface_port    ${DEBUG_INTF}_conduit   "jtag_debug_debugack"       "export"               "output"         1
          add_interface_port    ${DEBUG_INTF}_conduit   "jtag_debug_debugreq"       "export"               "input"          1
      }
    } 
    
    if { "${local_debug_level}" == "Level4" } {
        add_interface           ${DEBUG_INTF}_conduit "conduit"                       "end"
        add_interface_port      ${DEBUG_INTF}_conduit "jtag_debug_offchip_trace_clk"  "export"            "output"        1
        add_interface_port      ${DEBUG_INTF}_conduit "jtag_debug_offchip_trace_data" "export"            "output"        ${local_oci_tr_width}
        add_interface_port      ${DEBUG_INTF}_conduit "jtag_debug_trigout"            "export"            "output"        1
        # fb45387: Create a conduit clock to supply 2x external clock for Nios II debug
        if { !$local_use_embeddedPLL } {
            add_interface_port    ${DEBUG_INTF}_conduit  "clkx2"    "export"   "input"  1
        }
        
        # fb106382: Port Jtag_debug_debugreq is missing when level4 jtag is on
        if { $include_debug_debugReqSignals } {
            add_interface_port    ${DEBUG_INTF}_conduit   "jtag_debug_debugack"       "export"               "output"         1
            add_interface_port    ${DEBUG_INTF}_conduit   "jtag_debug_debugreq"       "export"               "input"          1
        }
    }
    
    if { $local_cpuresetrequest } {
        add_interface       ${CPU_RESET}_conduit        "conduit"                   "end"
        add_interface_port  ${CPU_RESET}_conduit        "cpu_resetrequest"          "export"                "input"         1
        add_interface_port  ${CPU_RESET}_conduit        "cpu_resettaken"            "export"                "output"        1
    }
    
    if { $local_exportPCB } {
        add_interface           ${PROGRAM_COUNTER}   "avalon_streaming"    "start"       $CLOCK_INTF
        add_interface_port      ${PROGRAM_COUNTER}   "pc"                  "data"        "output"        $local_instaddrwidth
        add_interface_port      ${PROGRAM_COUNTER}   "pc_valid"            "valid"       "output"        1
        set_interface_property  ${PROGRAM_COUNTER}   "associatedReset"     "reset_n"
        set_interface_property  ${PROGRAM_COUNTER}   "symbolsPerBeat"      "1"
        set_interface_property  ${PROGRAM_COUNTER}   "dataBitsPerSymbol"   $local_instaddrwidth
        set_interface_property  ${PROGRAM_COUNTER}   "ENABLED"             "true"
    }
    
    if { $local_HBreakTest } {
        if { "${local_debug_level}" != "NoDebug" } {
            add_interface       ${HW_BREAKTEST}_conduit        "conduit"                "end"
            add_interface_port  ${HW_BREAKTEST}_conduit        "oci_async_hbreak_req"        "export"                "output"        1
            add_interface_port  ${HW_BREAKTEST}_conduit        "oci_sync_hbreak_req"         "export"                "output"        1
        }
    }

# fb45389: export large rams parameter
    if { $local_export_large_RAMs } {
        sub_elaborate_export_large_rams
    }

# Adding support for ASIC flow: adding reset and sld_jtag conduit ports
    if { $local_asic_enabled} {
        if { "${local_debug_level}" != "NoDebug" } {
            add_interface       reset_conduit        "conduit"      "end"
            add_interface_port  reset_conduit        "clrn"         "export"                "input"        1
        }
    }
    
    if { $local_oci_export_jtag_signals == "1" && $local_avalon_debug_present == "0" } {
        if { "${local_debug_level}" != "NoDebug" } {
            add_interface       sld_jtag_conduit        "conduit"      "end"
            add_interface_port  sld_jtag_conduit        "vji_ir_out"   "export"                "output"       2
            add_interface_port  sld_jtag_conduit        "vji_tdo"      "export"                "output"       1
            add_interface_port  sld_jtag_conduit        "vji_cdr"      "export"                "input"        1
            add_interface_port  sld_jtag_conduit        "vji_ir_in"    "export"                "input"        2
            add_interface_port  sld_jtag_conduit        "vji_rti"      "export"                "input"        1
            add_interface_port  sld_jtag_conduit        "vji_sdr"      "export"                "input"        1
            add_interface_port  sld_jtag_conduit        "vji_tck"      "export"                "input"        1
            add_interface_port  sld_jtag_conduit        "vji_tdi"      "export"                "input"        1
            add_interface_port  sld_jtag_conduit        "vji_udr"      "export"                "input"        1
            add_interface_port  sld_jtag_conduit        "vji_uir"      "export"                "input"        1
        }
    }

    # Set the vector width to always 30 bits for MMU system, else follow the instruction address width
    if {$local_mmu_enable} {
        set local_vector_width 30
    } else {
        set local_vector_width [ expr {$local_instaddrwidth - 2} ]
    }

    # Adding conduit signals to reset/exception/break vectors
    if { $local_exportvectors } {
        add_interface           reset_vector_conduit        "conduit"                     "end"
        add_interface_port      reset_vector_conduit        "reset_vector_word_addr"      "export"                "input"        $local_vector_width
        add_interface           exception_vector_conduit    "conduit"                     "end"
        add_interface_port      exception_vector_conduit    "exception_vector_word_addr"  "export"                "input"        $local_vector_width
        add_interface           break_vector_conduit        "conduit"                     "end"
        add_interface_port      break_vector_conduit        "break_vector_word_addr"      "export"                "input"        $local_vector_width
        if {$local_mmu_enable} {
            add_interface           fast_tlb_miss_vector_conduit        "conduit"                             "end"
            add_interface_port      fast_tlb_miss_vector_conduit        "fast_tlb_miss_vector_word_addr"      "export"                "input"        $local_vector_width
        }
    }
    
    # Adding an ST streaming interface for the ECC event bus
    set local_ecc_present [ proc_get_boolean_parameter setting_ecc_present ]
    set local_impl [ string tolower [ get_parameter_value impl ]]
    set ecc_sim_test_ports [ proc_get_boolean_parameter setting_ecc_sim_test_ports ]
    if { "$local_impl" == "fast" && $local_ecc_present } {
        add_interface           ${ECC_EVENT}   "avalon_streaming"    "start"       $CLOCK_INTF
        add_interface_port      ${ECC_EVENT}   "ecc_event_bus"       "data"        "output"        30
        set_interface_property  ${ECC_EVENT}   "associatedReset"     "reset_n"
        set_interface_property  ${ECC_EVENT}   "symbolsPerBeat"      "1"
        set_interface_property  ${ECC_EVENT}   "dataBitsPerSymbol"   "30"
        set_interface_property  ${ECC_EVENT}   "ENABLED"             "true"
        
        # All ports are always available and are 72 bits for data + parity access
        if { $ecc_sim_test_ports } {
            foreach i {ic_tag ic_data dc_tag dc_data rf dtcm0 dtcm1 dtcm2 dtcm3 tlb} {
                set INTF_NAME "ecc_test_${i}"
                
                add_interface           $INTF_NAME   "avalon_streaming"          "end"       $CLOCK_INTF
                add_interface_port      $INTF_NAME   "ecc_test_${i}"       "data"        "input"        72
                add_interface_port      $INTF_NAME   "ecc_test_${i}_valid" "valid"       "input"        1
                add_interface_port      $INTF_NAME   "ecc_test_${i}_ready" "ready"       "output"       1
                set_interface_property  $INTF_NAME   "associatedReset"           "reset_n"
                set_interface_property  $INTF_NAME   "symbolsPerBeat"            "1"
                set_interface_property  $INTF_NAME   "dataBitsPerSymbol"         "72"
                set_interface_property  $INTF_NAME   "ENABLED"                   "true"
            }
        }
    }
}

#------------------------------
# [6.10-5] elaborate conduit interfaces for export large rams
#------------------------------
proc sub_elaborate_export_large_rams {} {
    set local_inst_master_present    [ proc_get_inst_master_present ]
    set local_data_master_present    [ proc_get_data_master_present ]
    set local_mmu_enabled            [ proc_get_mmu_present ]
    set local_debug_level            [ get_parameter_value debug_level ]
    set impl                         [ get_parameter_value impl ]
    set local_dcache_size_derived    [ get_parameter_value dcache_size_derived ]

    if { [expr { $local_inst_master_present == "1" } && { $impl != "Tiny" }] } {
        set ic_data_addr_sz          [ proc_calculate_ic_data_addr_size ]
        set ic_data_data_sz          32
        set ic_tag_addr_sz           [ proc_calculate_ic_tag_addr_size ]
        set ic_tag_data_sz           [ proc_calculate_ic_tag_data_size ]

        add_interface       icache_conduit        "conduit"                "end"
        add_interface_port  icache_conduit        "icache_tag_ram_write_data"        "icache_tag_ram_write_data"               "output"        $ic_tag_data_sz
        add_interface_port  icache_conduit        "icache_tag_ram_write_enable"      "icache_tag_ram_write_enable"             "output"        1
        add_interface_port  icache_conduit        "icache_tag_ram_write_address"     "icache_tag_ram_write_address"            "output"        $ic_tag_addr_sz
        add_interface_port  icache_conduit        "icache_tag_ram_read_clk_en"       "icache_tag_ram_read_clk_en"              "output"        1
        add_interface_port  icache_conduit        "icache_tag_ram_read_address"      "icache_tag_ram_read_address"             "output"        $ic_tag_addr_sz
        add_interface_port  icache_conduit        "icache_tag_ram_read_data"         "icache_tag_ram_read_data"                "input"         $ic_tag_data_sz
        add_interface_port  icache_conduit        "icache_data_ram_write_data"       "icache_data_ram_write_data"              "output"        $ic_data_data_sz
        add_interface_port  icache_conduit        "icache_data_ram_write_enable"     "icache_data_ram_write_enable"            "output"        1
        add_interface_port  icache_conduit        "icache_data_ram_write_address"    "icache_data_ram_write_address"           "output"        $ic_data_addr_sz
        add_interface_port  icache_conduit        "icache_data_ram_read_clk_en"      "icache_data_ram_read_clk_en"             "output"        1
        add_interface_port  icache_conduit        "icache_data_ram_read_address"     "icache_data_ram_read_address"            "output"        $ic_data_addr_sz
        add_interface_port  icache_conduit        "icache_data_ram_read_data"        "icache_data_ram_read_data"               "input"         $ic_data_data_sz
    }

    if { [expr { $local_data_master_present == "1" } && { $local_dcache_size_derived != "0" } && { $impl == "Fast" }] } {
        set dc_data_addr_sz          [ proc_calculate_dc_data_addr_size ]
        set dc_data_data_sz          32
        set dc_byte_en_sz            4
        set dc_tag_addr_sz           [ proc_calculate_dc_tag_addr_size ]
        set dc_tag_data_sz           [ proc_calculate_dc_tag_data_size ]
       
        set dc_bytes_per_line        [ get_parameter_value dcache_lineSize_derived ]
        set dc_cache_wide            [ expr { $dc_bytes_per_line > 4 } ]

        if { $dc_cache_wide } {
            add_interface       dcache_conduit        "conduit"                "end"
            add_interface_port  dcache_conduit        "dcache_g4b_tag_ram_write_data"        "dcache_g4b_tag_ram_write_data"                "output"        $dc_tag_data_sz
            add_interface_port  dcache_conduit        "dcache_g4b_tag_ram_write_enable"      "dcache_g4b_tag_ram_write_enable"              "output"        1
            add_interface_port  dcache_conduit        "dcache_g4b_tag_ram_write_address"     "dcache_g4b_tag_ram_write_address"             "output"        $dc_tag_addr_sz
            add_interface_port  dcache_conduit        "dcache_g4b_tag_ram_read_clk_en"       "dcache_g4b_tag_ram_read_clk_en"               "output"        1
            add_interface_port  dcache_conduit        "dcache_g4b_tag_ram_read_address"      "dcache_g4b_tag_ram_read_address"              "output"        $dc_tag_addr_sz
            add_interface_port  dcache_conduit        "dcache_g4b_tag_ram_read_data"         "dcache_g4b_tag_ram_read_data"                 "input"         $dc_tag_data_sz
            add_interface_port  dcache_conduit        "dcache_g4b_data_ram_write_data"       "dcache_g4b_data_ram_write_data"               "output"        $dc_data_data_sz
            add_interface_port  dcache_conduit        "dcache_g4b_data_ram_write_enable"     "dcache_g4b_data_ram_write_enable"             "output"        1
            add_interface_port  dcache_conduit        "dcache_g4b_data_ram_write_address"    "dcache_g4b_data_ram_write_address"            "output"        $dc_data_addr_sz
            add_interface_port  dcache_conduit        "dcache_g4b_data_ram_read_clk_en"      "dcache_g4b_data_ram_read_clk_en"              "output"        1
            add_interface_port  dcache_conduit        "dcache_g4b_data_ram_read_address"     "dcache_g4b_data_ram_read_address"             "output"        $dc_data_addr_sz
            add_interface_port  dcache_conduit        "dcache_g4b_data_ram_read_data"        "dcache_g4b_data_ram_read_data"                "input"         $dc_data_data_sz    
        } else {
            add_interface       dcache_conduit        "conduit"                "end"
            add_interface_port  dcache_conduit        "dcache_4b_tag_ram_data_b"            "dcache_4b_tag_ram_data_b"                "output"        $dc_tag_data_sz
            add_interface_port  dcache_conduit        "dcache_4b_tag_ram_write_enable_b"    "dcache_4b_tag_ram_write_enable_b"        "output"        1
            add_interface_port  dcache_conduit        "dcache_4b_tag_ram_clk_en0"           "dcache_4b_tag_ram_clk_en0"               "output"        1
            add_interface_port  dcache_conduit        "dcache_4b_tag_ram_clk_en1"           "dcache_4b_tag_ram_clk_en1"               "output"        1
            add_interface_port  dcache_conduit        "dcache_4b_tag_ram_address_a"         "dcache_4b_tag_ram_address_a"             "output"        $dc_tag_addr_sz
            add_interface_port  dcache_conduit        "dcache_4b_tag_ram_address_b"         "dcache_4b_tag_ram_address_b"             "output"        $dc_tag_addr_sz
            add_interface_port  dcache_conduit        "dcache_4b_tag_ram_q_a_data"          "dcache_4b_tag_ram_q_a_data"              "input"         $dc_tag_data_sz
            add_interface_port  dcache_conduit        "dcache_4b_tag_ram_q_b_data"          "dcache_4b_tag_ram_q_b_data"              "input"         $dc_tag_data_sz
            
            add_interface_port  dcache_conduit        "dcache_4b_data_ram_byteena_b"        "dcache_4b_data_ram_byteena_b"            "output"        $dc_byte_en_sz
            add_interface_port  dcache_conduit        "dcache_4b_data_ram_data_b"           "dcache_4b_data_ram_data_b"               "output"        $dc_data_data_sz
            add_interface_port  dcache_conduit        "dcache_4b_data_ram_write_enable_b"   "dcache_4b_data_ram_write_enable_b"       "output"        1
            add_interface_port  dcache_conduit        "dcache_4b_data_ram_address_a"        "dcache_4b_data_ram_address_a"            "output"        $dc_data_addr_sz
            add_interface_port  dcache_conduit        "dcache_4b_data_ram_address_b"        "dcache_4b_data_ram_address_b"            "output"        $dc_data_addr_sz
            add_interface_port  dcache_conduit        "dcache_4b_data_ram_clk_en0"          "dcache_4b_data_ram_clk_en0"              "output"        1
            add_interface_port  dcache_conduit        "dcache_4b_data_ram_clk_en1"          "dcache_4b_data_ram_clk_en1"              "output"        1
            add_interface_port  dcache_conduit        "dcache_4b_data_ram_q_a_data"         "dcache_4b_data_ram_q_a_data"             "input"         $dc_data_data_sz
            add_interface_port  dcache_conduit        "dcache_4b_data_ram_q_b_data"         "dcache_4b_data_ram_q_b_data"             "input"         $dc_data_data_sz
        }
    }
  
    if { $local_debug_level != "NoDebug" } {
        set local_oci_trace_addr_width             [ proc_get_oci_trace_addr_width ]
        add_interface       oci_ram_conduit        "conduit"                "end"
        add_interface_port  oci_ram_conduit        "cpu_lpm_oci_ram_sp_address"          "cpu_lpm_oci_ram_sp_address"           "output"       8
        add_interface_port  oci_ram_conduit        "cpu_lpm_oci_ram_sp_byte_enable"      "cpu_lpm_oci_ram_sp_byte_enable"       "output"       4
        add_interface_port  oci_ram_conduit        "cpu_lpm_oci_ram_sp_write_data"       "cpu_lpm_oci_ram_sp_write_data"        "output"       32
        add_interface_port  oci_ram_conduit        "cpu_lpm_oci_ram_sp_write_enable"     "cpu_lpm_oci_ram_sp_write_enable"      "output"       1
        add_interface_port  oci_ram_conduit        "cpu_lpm_oci_ram_sp_read_data"        "cpu_lpm_oci_ram_sp_read_data"         "input"        32
        
        # Disable OCI onchip trace interface if not supported by debug level
        # Only export trace ram when debug level > 2 and not tiny core
        set onchip_trace_support [ expr {  "$local_debug_level" == "Level3" } || { "$local_debug_level" == "Level4" } ]
        set tiny_or_no_onchip_trace_support [ expr { "$impl" == "Tiny" } || { "$onchip_trace_support" == "0" } ]

        if { !$tiny_or_no_onchip_trace_support } {
            add_interface       trace_ram_conduit      "conduit"                "end"
            add_interface_port  trace_ram_conduit      "cpu_lpm_trace_ram_bdp_clk_en_0"         "cpu_lpm_trace_ram_bdp_clk_en_0"            "output"       1
            add_interface_port  trace_ram_conduit      "cpu_lpm_trace_ram_bdp_clk_en_1"         "cpu_lpm_trace_ram_bdp_clk_en_1"            "output"       1
            add_interface_port  trace_ram_conduit      "cpu_lpm_trace_ram_bdp_address_a"        "cpu_lpm_trace_ram_bdp_address_a"           "output"       $local_oci_trace_addr_width
            add_interface_port  trace_ram_conduit      "cpu_lpm_trace_ram_bdp_write_data_a"     "cpu_lpm_trace_ram_bdp_write_data_a"        "output"       36
            add_interface_port  trace_ram_conduit      "cpu_lpm_trace_ram_bdp_write_enable_a"   "cpu_lpm_trace_ram_bdp_write_enable_a"      "output"       1
            add_interface_port  trace_ram_conduit      "cpu_lpm_trace_ram_bdp_read_data_a"      "cpu_lpm_trace_ram_bdp_read_data_a"         "input"        36
            add_interface_port  trace_ram_conduit      "cpu_lpm_trace_ram_bdp_address_b"        "cpu_lpm_trace_ram_bdp_address_b"           "output"       $local_oci_trace_addr_width
            add_interface_port  trace_ram_conduit      "cpu_lpm_trace_ram_bdp_write_data_b"     "cpu_lpm_trace_ram_bdp_write_data_b"        "output"       36
            add_interface_port  trace_ram_conduit      "cpu_lpm_trace_ram_bdp_write_enable_b"   "cpu_lpm_trace_ram_bdp_write_enable_b"      "output"       1
            add_interface_port  trace_ram_conduit      "cpu_lpm_trace_ram_bdp_read_data_b"      "cpu_lpm_trace_ram_bdp_read_data_b"         "input"        36
        }
    }
  
    if { [expr { $local_mmu_enabled }] } {
        set local_finalTlbPtrSz      [ proc_get_final_tlb_ptr_size ]
        set tlb_data_size            [ proc_calculate_tlb_data_size ]

        add_interface       mmu_conduit        "conduit"                "end"
        add_interface_port  mmu_conduit        "tlb_ram_write_enable"          "tlb_ram_write_enable"           "output"       1
        add_interface_port  mmu_conduit        "tlb_ram_read_address"          "tlb_ram_read_address"           "output"       ${local_finalTlbPtrSz}
        add_interface_port  mmu_conduit        "tlb_ram_write_address"         "tlb_ram_write_address"          "output"       ${local_finalTlbPtrSz}
        add_interface_port  mmu_conduit        "tlb_ram_write_data"            "tlb_ram_write_data"             "output"       ${tlb_data_size}
        add_interface_port  mmu_conduit        "tlb_ram_read_data"             "tlb_ram_read_data"              "input"        ${tlb_data_size}
     }
}

proc sub_elaborate_reset_req {} {
    set has_multi [ proc_has_multi_ci_slave ]
    set local_debug_level [ get_parameter_value debug_level ]
    set setting_oci_export_jtag_signals [ proc_get_boolean_parameter setting_oci_export_jtag_signals ]

    # Elaborate reset_req under 2 conditions
    # When there is a multi cycle custom instruction
    # When debug level is enabled (level 1,2,3,4) and oci is not exported
    set oci_ram_present [ expr { "${local_debug_level}" != "NoDebug" && !$setting_oci_export_jtag_signals } ]
    if { $oci_ram_present || $has_multi } {
        add_interface_port reset_n reset_req reset_req Input 1
    }
}

#------------------------------
# [6.0] elaborate callback main routine
#------------------------------
proc elaborate {} {
    # [6.1]
    sub_elaborate_datam_interface
    # [6.2]
    sub_elaborate_instructionm_interface
    # [6.3]
    sub_elaborate_tcdm_interface
    # [6.4]
    sub_elaborate_tcim_interface
    # [6.5]
    sub_elaborate_interrupt_controller_ports
    # [6.6]
    sub_elaborate_jtag_debug_module_interface
    # [6.7]
    sub_elaborate_avalon_debug_port_interface
    # [6.8]
    sub_elaborate_custom_instruction
    # [6.9]
    sub_elaborate_update_processor_inst_and_data_master
    # [6.10]
    sub_elaborate_conduit_interfaces
    # [6.11]
    sub_elaborate_hbreak_interrupt_controller_ports
    # Reset req for OCI RAM/multi CI
    sub_elaborate_reset_req
}

#------------------------------------------------------------------------------
# [7] VALIDATION Callback
#------------------------------------------------------------------------------
# Used for searching through the list of slave
proc proc_not_matched_valid { current_slave slave_list} {
    set matched [ expr [ lsearch -regexp $slave_list $current_slave ] == -1 ]
    return $matched
}

#------------------------------
# [7.1] Update parameter Allow Range
#------------------------------
proc sub_validate_update_parameters {} {

    global TCD_PREFIX
    global TCI_PREFIX
    # Slaves.
    # [SH] - validate that it is connected to Data Master
    set reset_slaves                    [ proc_get_address_map_slaves_name instSlaveMapParam ]
    set tcim_num                        [ get_parameter_value icache_numTCIM ]
    
    foreach i {0 1 2 3} {
            set INTF_TCI_NAME "${TCI_PREFIX}${i}"
            if { $i < $tcim_num } {                
                lappend reset_slaves [ proc_get_address_map_slaves_name ${INTF_TCI_NAME}MapParam ]
            }
    }
    
    # SPR:348488
    lappend reset_slaves "Absolute"
    lappend reset_slaves "None"

    # Assign to the base reset_slaves
    set exception_slaves $reset_slaves
    set break_slaves $reset_slaves
    set mmu_slaves $reset_slaves

    # This is to include the current slave as sudden removal will cause invalid range
    set current_resetSlave                  [ get_parameter_value resetSlave ]
    if { [ proc_not_matched_valid "$current_resetSlave" "$reset_slaves" ] } {
        lappend reset_slaves "$current_resetSlave"
    }

    set current_exceptionSlave              [ get_parameter_value exceptionSlave ]
    if { [ proc_not_matched_valid "$current_exceptionSlave" "$exception_slaves" ] } {
        lappend exception_slaves "$current_exceptionSlave"
    }

    set current_breakSlave                  [ get_parameter_value breakSlave ]
    if { [ proc_not_matched_valid "$current_breakSlave" "$break_slaves" ] } {
        lappend break_slaves "$current_breakSlave"
    }
    
    set current_mmu_TLBMissExcSlave         [ get_parameter_value mmu_TLBMissExcSlave ]
    if { [ proc_not_matched_valid "$current_mmu_TLBMissExcSlave" "$mmu_slaves" ] } {
        lappend mmu_slaves "$current_mmu_TLBMissExcSlave"
    }
    # This is for backward compatible, in previous designs "" is allowed
    # Only allow if this is selected previously. In future design, this will not be allowed
    if { "$current_mmu_TLBMissExcSlave" == "" } {
        lappend mmu_slaves "$current_mmu_TLBMissExcSlave"
    }

    set_parameter_property  resetSlave              "ALLOWED_RANGES" $reset_slaves
    set_parameter_property  exceptionSlave          "ALLOWED_RANGES" $exception_slaves
    set_parameter_property  breakSlave              "ALLOWED_RANGES" $break_slaves

    set_parameter_property  mmu_TLBMissExcSlave     "ALLOWED_RANGES" $mmu_slaves
    
    # RAM Block type
    set supported_ram_type    [proc_get_supported_ram_type]
    set supported_tagram_type [proc_get_supported_cache_tagram_type]
    set_parameter_property  dcache_tagramBlockType  "ALLOWED_RANGES" $supported_tagram_type
    set_parameter_property  icache_tagramBlockType  "ALLOWED_RANGES" $supported_tagram_type
    set_parameter_property  dcache_ramBlockType     "ALLOWED_RANGES" $supported_ram_type
    set_parameter_property  icache_ramBlockType     "ALLOWED_RANGES" $supported_ram_type
    set_parameter_property  regfile_ramBlockType    "ALLOWED_RANGES" $supported_ram_type
    set_parameter_property  ocimem_ramBlockType     "ALLOWED_RANGES" $supported_ram_type
    set_parameter_property  mmu_ramBlockType        "ALLOWED_RANGES" $supported_ram_type
    set_parameter_property  bht_ramBlockType        "ALLOWED_RANGES" $supported_ram_type

    #[SH] Multiply Type
}

#------------------------------
# [7.2] To disable invalid Parameter
#------------------------------
proc sub_validate_update_parameterization_gui {} {
    set impl                                        [ get_parameter_value impl ]
    set device_family_name                          [ get_parameter_value deviceFamilyName ]
    set mmu_enabled                                 [ proc_get_mmu_present ]
    set mpu_enabled                                 [ proc_get_mpu_present ]
    set muldiv_divider                              [ proc_get_boolean_parameter muldiv_divider ]
    set setting_performanceCounter                  [ proc_get_boolean_parameter setting_performanceCounter ]
    set mmu_autoAssignTlbPtrSz                      [ proc_get_boolean_parameter mmu_autoAssignTlbPtrSz ]

    set icache_size                                 [ get_parameter_value icache_size ]
    set dcache_size                                 [ get_parameter_value dcache_size ]
    set dcache_lineSize                             [ get_parameter_value dcache_lineSize ]

    set setting_preciseIllegalMemAccessException    [ proc_get_boolean_parameter setting_preciseIllegalMemAccessException ]
    set setting_illegalMemAccessDetection           [ proc_get_boolean_parameter setting_illegalMemAccessDetection ]
    set setting_preciseDivisionErrorException       [ proc_get_boolean_parameter setting_preciseDivisionErrorException ]
    set setting_extraExceptionInfo                  [ proc_get_boolean_parameter setting_extraExceptionInfo ]

    set manuallyAssignCpuID                         [ proc_get_boolean_parameter manuallyAssignCpuID ]
    set debug_assignJtagInstanceID                  [ proc_get_boolean_parameter debug_assignJtagInstanceID ]
    set debug_level                                 [ get_parameter_value debug_level ]
    set branch_prediction_type                      [ get_parameter_value setting_branchPredictionType ]
    set local_exportvectors                         [ proc_get_boolean_parameter setting_exportvectors ]

    # Set all parameters to visible initially and disable accordingly
    proc_set_enable_visible_parameter mmu_enabled "enable"
    proc_set_enable_visible_parameter mmu_TLBMissExcSlave "enable"
    proc_set_enable_visible_parameter mmu_TLBMissExcOffset "enable"
    proc_set_enable_visible_parameter mmu_tlbNumWays "enable"
    proc_set_enable_visible_parameter mmu_tlbPtrSz "enable"
    proc_set_enable_visible_parameter mmu_processIDNumBits "enable"
    proc_set_enable_visible_parameter mmu_udtlbNumEntries "enable"
    proc_set_enable_visible_parameter mmu_uitlbNumEntries "enable"
    proc_set_enable_visible_parameter mmu_autoAssignTlbPtrSz "enable"
    proc_set_enable_visible_parameter mmu_ramBlockType "enable"

    proc_set_enable_visible_parameter mpu_enabled "enable"
    proc_set_enable_visible_parameter mpu_numOfDataRegion "enable"
    proc_set_enable_visible_parameter mpu_numOfInstRegion "enable"
    proc_set_enable_visible_parameter mpu_minDataRegionSize "enable"
    proc_set_enable_visible_parameter mpu_minInstRegionSize "enable"
    proc_set_enable_visible_parameter mpu_useLimit "enable"

    proc_set_enable_visible_parameter muldiv_multiplierType "enable"
    proc_set_enable_visible_parameter muldiv_divider "enable"

    proc_set_enable_visible_parameter icache_size "enable"
    proc_set_enable_visible_parameter icache_tagramBlockType "enable"
    proc_set_enable_visible_parameter icache_ramBlockType "enable"
    proc_set_enable_visible_parameter icache_burstType "enable"
    proc_set_enable_visible_parameter icache_numTCIM "enable"

    proc_set_enable_visible_parameter dcache_size "enable"
    proc_set_enable_visible_parameter dcache_tagramBlockType "enable"
    proc_set_enable_visible_parameter dcache_ramBlockType "enable"
    proc_set_enable_visible_parameter dcache_lineSize "enable"
    proc_set_enable_visible_parameter dcache_bursts "enable"
    proc_set_enable_visible_parameter dcache_numTCDM "enable"
    proc_set_enable_visible_parameter dcache_omitDataMaster "enable"
    proc_set_enable_visible_parameter dcache_victim_buf_impl "enable"  

    proc_set_enable_visible_parameter setting_ecc_present "enable"
    proc_set_enable_visible_parameter setting_ecc_sim_test_ports "disable"

    proc_set_enable_visible_parameter setting_interruptControllerType "enable"
    proc_set_enable_visible_parameter setting_shadowRegisterSets "enable"
    proc_set_enable_visible_parameter setting_illegalInstructionsTrap "enable"
    proc_set_enable_visible_parameter setting_preciseIllegalMemAccessException "enable"
    proc_set_enable_visible_parameter setting_preciseDivisionErrorException "enable"
    proc_set_enable_visible_parameter setting_preciseSlaveAccessErrorException "enable"
    proc_set_enable_visible_parameter setting_extraExceptionInfo "enable"
    proc_set_enable_visible_parameter setting_illegalMemAccessDetection "enable"
    proc_set_enable_visible_parameter setting_avalonDebugPortPresent "enable"
    
    proc_set_enable_visible_parameter cpuID "enable"

    proc_set_enable_visible_parameter setting_branchPredictionType "enable"
    proc_set_enable_visible_parameter setting_bhtPtrSz "enable"
    proc_set_enable_visible_parameter bht_ramBlockType "enable"

    proc_set_enable_visible_parameter breakSlave "enable"
    proc_set_enable_visible_parameter breakOffset "enable"
    proc_set_enable_visible_parameter exceptionSlave "enable"
    proc_set_enable_visible_parameter resetSlave "enable"
    proc_set_enable_visible_parameter exceptionOffset "enable"
    proc_set_enable_visible_parameter resetOffset "enable"

    proc_set_enable_visible_parameter debug_OCIOnchipTrace "enable"
    proc_set_enable_visible_parameter debug_debugReqSignals "enable"
    proc_set_enable_visible_parameter debug_embeddedPLL "enable"
    proc_set_enable_visible_parameter debug_level "enable"
    proc_set_enable_visible_parameter debug_assignJtagInstanceID "enable"
    proc_set_enable_visible_parameter debug_jtagInstanceID "enable"
    proc_set_enable_visible_parameter ocimem_ramBlockType "enable"

    proc_set_enable_visible_parameter setting_performanceCounter "enable"
    proc_set_enable_visible_parameter setting_perfCounterWidth "enable"

    proc_set_enable_visible_parameter setting_allowFullAddressRange "enable"
    proc_set_enable_visible_parameter setting_bit31BypassDCache "enable"
    proc_set_enable_visible_parameter is_hardcopy_compatible "enable"

    # Hardware multiply and divider can only be used if small and Fast core is selected
    if { "$impl" == "Tiny" } {
        proc_set_enable_visible_parameter muldiv_multiplierType "disable"
        proc_set_enable_visible_parameter muldiv_divider "disable"
    }

    # MMU and MPU can only be used if Fast core is selected
    if { "$impl" != "Fast" } {
        proc_set_enable_visible_parameter mmu_enabled "disable"
        proc_set_enable_visible_parameter mpu_enabled "disable"
    }

    # Disable MMU if MPU is enabled
    if { "$mpu_enabled" == "1" } {
        proc_set_enable_visible_parameter mmu_enabled "disable"
    }

    # Update tlb ptr sz if needed
    if { "$mmu_autoAssignTlbPtrSz" == "1" } {
        proc_set_enable_visible_parameter mmu_tlbPtrSz "disable"
    }

    # Disable TLB parameters unless MMU is enabled
    if { [ expr { "$impl" != "Fast" } || { "$mmu_enabled" != "1" } ] } {
        proc_set_enable_visible_parameter mmu_TLBMissExcSlave "disable"
        proc_set_enable_visible_parameter mmu_TLBMissExcOffset "disable"

        # If MMU is not enabled, all related parameters are disable
        proc_set_enable_visible_parameter mmu_tlbNumWays "disable"
        proc_set_enable_visible_parameter mmu_tlbPtrSz "disable"
        proc_set_enable_visible_parameter mmu_processIDNumBits "disable"
        proc_set_enable_visible_parameter mmu_udtlbNumEntries "disable"
        proc_set_enable_visible_parameter mmu_uitlbNumEntries "disable"
        proc_set_enable_visible_parameter mmu_autoAssignTlbPtrSz "disable"
        proc_set_enable_visible_parameter mmu_ramBlockType "disable"
    }

    # Disable MPU if MMU is enabled
    if { "$mmu_enabled" == "1" } {
        proc_set_enable_visible_parameter mpu_enabled "disable"
    }

    # If MPU is not enabled, all related parameters are disable
    if { "$mpu_enabled" == "0" || "[ get_parameter_property mpu_enabled "ENABLED" ]" == "0" } {
        proc_set_enable_visible_parameter mpu_numOfDataRegion "disable"
        proc_set_enable_visible_parameter mpu_numOfInstRegion "disable"
        proc_set_enable_visible_parameter mpu_minDataRegionSize "disable"
        proc_set_enable_visible_parameter mpu_minInstRegionSize "disable"
        proc_set_enable_visible_parameter mpu_useLimit "disable"
    }

    # Enable instruction cache parameters if instruction cache is present
    if { "$icache_size" == "0" } {
        proc_set_enable_visible_parameter icache_tagramBlockType "disable"
        proc_set_enable_visible_parameter icache_ramBlockType "disable"
        proc_set_enable_visible_parameter icache_burstType "disable"
    }

    # Enable data cache parameters if data cache is present
    if { "$dcache_size" == "0" } {
        proc_set_enable_visible_parameter dcache_tagramBlockType "disable"
        proc_set_enable_visible_parameter dcache_ramBlockType "disable"
        proc_set_enable_visible_parameter dcache_lineSize "disable"
        proc_set_enable_visible_parameter dcache_bursts "disable"
    }

    # Enhanced Interrupt Features can only be used with f core
    if { "$impl" != "Fast" } {
        proc_set_enable_visible_parameter setting_interruptControllerType "disable"
        proc_set_enable_visible_parameter setting_shadowRegisterSets "disable"
    }

    # Precise exceptions can only be used if Fast core is selected
    if { "$impl" != "Fast" } {
        proc_set_enable_visible_parameter setting_preciseIllegalMemAccessException "disable"
        proc_set_enable_visible_parameter setting_preciseSlaveAccessErrorException "disable"
        proc_set_enable_visible_parameter setting_preciseDivisionErrorException "disable"
        proc_set_enable_visible_parameter setting_extraExceptionInfo "disable"
    }

    # Division error can only be used if hardware division is enabled
    if { "$muldiv_divider" != "1" } {
        proc_set_enable_visible_parameter setting_preciseDivisionErrorException "disable"
    }

    # Disable illegal memory access and the imprecise version if MMU is enabled
    if { "$mmu_enabled" == "1" } {
        proc_set_enable_visible_parameter setting_preciseIllegalMemAccessException "disable"
        proc_set_enable_visible_parameter setting_illegalMemAccessDetection "disable"
    }

    # Disable illegal memory access and the imprecise version if MPU is enabled
    if { "$mpu_enabled" == "1" } {
        proc_set_enable_visible_parameter setting_preciseIllegalMemAccessException "disable"
        proc_set_enable_visible_parameter setting_illegalMemAccessDetection "disable"
    }

    # Imprecise illegal memory access only work if Fast core is selected
    if { "$impl" != "Fast" } {
        proc_set_enable_visible_parameter setting_illegalMemAccessDetection "disable"
    }

    # Illegal instruction exception automatically provided for MMU and MPU,
    # and extra exception information is mandatory for MMU and MPU
    if { "$mmu_enabled" == "1" || "$mpu_enabled" == "1" } {
        proc_set_enable_visible_parameter setting_extraExceptionInfo "disable"
        proc_set_enable_visible_parameter setting_illegalInstructionsTrap "disable"
    }

    # Disable DCache bit 32 bypass and full address range support if MMU is enabled
    if { "$mmu_enabled" == "1" } {
        proc_set_enable_visible_parameter setting_allowFullAddressRange "disable"
        proc_set_enable_visible_parameter setting_bit31BypassDCache "disable"
    }

    # Slave access error can only be set if precise illegal memory exception is set or MPU is enabled
    set setting_preciseIllegalMemAccessException_enabled [ expr { "$setting_preciseIllegalMemAccessException" == "1" }  && { "[ get_parameter_property setting_preciseIllegalMemAccessException "ENABLED" ]" == "1" }   ]
    if { "$mpu_enabled" == "0" && "$setting_preciseIllegalMemAccessException_enabled" == "0" } {
        proc_set_enable_visible_parameter setting_preciseSlaveAccessErrorException "disable"
    }

    # Imprecise illegal mem access detection is disabled if
    # any of the precise exceptions are turned on.  Slave Access Error can be skipped
    # because it can only be set if precise illegal mem access exception is enabled
    set setting_preciseDivisionErrorException_enabled [ expr { "$setting_preciseDivisionErrorException" == "1" } && { "[ get_parameter_property setting_preciseDivisionErrorException "ENABLED" ]" == "1" } ]
    set setting_preciseIllegalMemAccessException_enabled [ expr { "$setting_preciseIllegalMemAccessException" == "1" } && { "[ get_parameter_property setting_preciseIllegalMemAccessException "ENABLED" ]" == "1" } ]
    set is_any_other_exc_true [ expr { "$setting_preciseIllegalMemAccessException_enabled" == "1" } || { "$setting_preciseDivisionErrorException_enabled" == "1" } ]
    if { $is_any_other_exc_true } {
        proc_set_enable_visible_parameter setting_illegalMemAccessDetection "disable"
    }

    # If non-precise illegal memory access is set, none of the precise exceptions can be set
    set setting_illegalMemAccessDetection_enabled [ expr { "$setting_illegalMemAccessDetection" == "1" } && { "[ get_parameter_property setting_illegalMemAccessDetection "ENABLED" ]" == "1" } ]
    if { "$setting_illegalMemAccessDetection_enabled" == "1" } {
        proc_set_enable_visible_parameter setting_preciseIllegalMemAccessException "disable"
        proc_set_enable_visible_parameter setting_preciseSlaveAccessErrorException "disable"
        proc_set_enable_visible_parameter setting_preciseDivisionErrorException "disable"
        proc_set_enable_visible_parameter setting_extraExceptionInfo "disable"
    }

    # PerformanceCounter and PerformanceCounterWidth cannot be used with e core
    if { "$impl" == "Tiny" } {
        proc_set_enable_visible_parameter setting_performanceCounter "disable"
        proc_set_enable_visible_parameter setting_perfCounterWidth "disable"
    }

    # PerformanceCounterWidth is only applicable if PerformanceCounter is enabled
    if { "$setting_performanceCounter" == "0" } {
        proc_set_enable_visible_parameter setting_perfCounterWidth "disable"
    }

    # Branch Prediction only works with non-Tiny cores
    if { "$impl" == "Tiny" } {
        proc_set_enable_visible_parameter setting_branchPredictionType "disable"
        proc_set_enable_visible_parameter setting_bhtPtrSz "disable"
        proc_set_enable_visible_parameter bht_ramBlockType "disable"
    }

    # Gray out BHT prediction entries when Static is chosen
    if { "$branch_prediction_type" == "Static" } {
        proc_set_enable_visible_parameter setting_bhtPtrSz "disable"
    }

    # Don't allow user to assign jtag instance id if no debug core present
    # Avalon Debug Port present only available when debug level is at least 1
    # Only allow RAM Block modification for when debugger at least 1
    if { "$debug_level" == "NoDebug" } {
        proc_set_enable_visible_parameter debug_assignJtagInstanceID "disable"
        proc_set_enable_visible_parameter setting_avalonDebugPortPresent "disable"
        proc_set_enable_visible_parameter ocimem_ramBlockType "disable"
    }

    # Jtag instance ID value is only valid if user want to assign it and they are allowed to assign it
    set debug_assignJtagInstanceID_enabled [ expr { "$debug_assignJtagInstanceID" == "1" } && { "[ get_parameter_property debug_assignJtagInstanceID "ENABLED" ]" == "1" } ]
    if { "$debug_assignJtagInstanceID_enabled" == "0" } {
        proc_set_enable_visible_parameter debug_jtagInstanceID "disable"
    }

    # Warn user if the manually assign cpuIDValue is equal to the cpuIDValue that has been
    # manually assigned in another Nios II instance.
    if { "$manuallyAssignCpuID" == "0" } {
        proc_set_enable_visible_parameter cpuID "disable"
    }

    set setting_breakslaveoveride [ proc_get_boolean_parameter setting_breakslaveoveride ]
    # Absolute address is meaningless when debug_level != NoDebug
    # Cleanup on the NoDebug condition
    if { "$debug_level" != "NoDebug" & !$setting_breakslaveoveride } {
        proc_set_enable_visible_parameter breakSlave "disable"
        proc_set_enable_visible_parameter breakOffset "disable"
    }

    # If the implementation type is Tiny, we don't have an I-Cache
    if { "$impl" == "Tiny" } {
        proc_set_enable_visible_parameter icache_size "disable"
        proc_set_enable_visible_parameter icache_tagramBlockType "disable"
        proc_set_enable_visible_parameter icache_ramBlockType "disable"
        proc_set_enable_visible_parameter icache_burstType "disable"
        proc_set_enable_visible_parameter icache_numTCIM "disable"
    }

    # If the I-cache size is set to 0, only TCIM can be set (and must be set)
    if { "$icache_size" == "0" } {
        proc_set_enable_visible_parameter icache_tagramBlockType "disable"
        proc_set_enable_visible_parameter icache_ramBlockType "disable"
        proc_set_enable_visible_parameter icache_burstType "disable"
    }

    # If the D-cache size is set to 0, only TCIM can be set
    # D-cache victim is enabled when line size is not 4 and cache is present
    if { "$dcache_size" == "0" } {
        proc_set_enable_visible_parameter dcache_tagramBlockType "disable"
        proc_set_enable_visible_parameter dcache_ramBlockType "disable"
        proc_set_enable_visible_parameter dcache_bursts "disable"
        proc_set_enable_visible_parameter dcache_lineSize "disable"
        proc_set_enable_visible_parameter dcache_victim_buf_impl "disable"
    }

    # Burst is enabled only if we're using the wide caches (line_size of 16 or 32 bytes)
    if { "$dcache_lineSize" == "4" } {
        proc_set_enable_visible_parameter dcache_bursts "disable"
        proc_set_enable_visible_parameter dcache_victim_buf_impl "disable"
    }

    # Lastly, if the implementation is not Fast, none of these settings are valid
    # since data caches are only used for Nios2/F cores.
    if { "$impl" != "Fast" } {
        proc_set_enable_visible_parameter dcache_bursts "disable"
        proc_set_enable_visible_parameter dcache_lineSize "disable"
        proc_set_enable_visible_parameter dcache_numTCDM "disable"
        proc_set_enable_visible_parameter dcache_tagramBlockType "disable"
        proc_set_enable_visible_parameter dcache_ramBlockType "disable"
        proc_set_enable_visible_parameter dcache_size "disable"
        proc_set_enable_visible_parameter dcache_omitDataMaster "disable"
        proc_set_enable_visible_parameter dcache_victim_buf_impl "disable"
    }

    # Disable OCI onchip trace interface if not supported by debug level
    set onchip_trace_support [ expr {  "$debug_level" == "Level3" } || { "$debug_level" == "Level4" } ]
    set tiny_or_no_onchip_trace_support [ expr { "$impl" == "Tiny" } || { "$onchip_trace_support" == "0" } ]
    if { $tiny_or_no_onchip_trace_support } {
        proc_set_enable_visible_parameter debug_OCIOnchipTrace "disable"
    }

    # Don't allow user to assign jtag instance id if no debug core present
    if { "$debug_level" == "NoDebug" } {
        proc_set_enable_visible_parameter manuallyAssignCpuID "disable"
    } else {
        proc_set_enable_visible_parameter manuallyAssignCpuID "enable"
    }

    # Jtag instance ID value is only valid if user want to assign it and they are allowed to assign it
    set manuallyAssignCpuID_enabled [ expr { "$manuallyAssignCpuID" == "1" } && { "[ get_parameter_property manuallyAssignCpuID "ENABLED" ]" == "1" } ]
    if { "$manuallyAssignCpuID_enabled" == "0" } {
        proc_set_enable_visible_parameter cpuID "disable"
    }

    # Don't export debugack and debugreq signals when debug level = NoDebugger
    if { "$debug_level" == "NoDebug" } {
        proc_set_enable_visible_parameter debug_debugReqSignals "disable"
    }

    # Embedded PLL Check, which is only applicable when debug level is level 4
    if { [ expr { "$debug_level" != "Level4" } ] } {
        proc_set_enable_visible_parameter debug_embeddedPLL "disable"
    }

    # Embedded PLL is not supported for Cyclone families
    if { [ string match "CYCLONE*" "$device_family_name" ] } {
        proc_set_enable_visible_parameter debug_embeddedPLL "disable"
    }

    # Embedded PLL is not supported for Cyclone families
    if { [ expr { "$impl" == "Tiny" } ] } {
        proc_set_enable_visible_parameter debug_embeddedPLL "disable"
    }
    
    set local_device_family_name [ string toupper "$device_family_name" ]
    regsub -all " " "$local_device_family_name" "" local_device_family_name
    if { [ string match *HARDCOPY* $local_device_family_name ] } {
        proc_set_enable_visible_parameter is_hardcopy_compatible "disable"
    }

    # ECC is only for Fast Core
    if { "$impl" != "Fast" } {
        proc_set_enable_visible_parameter setting_ecc_present "disable"
    }
    
    set ecc_present [ proc_get_boolean_parameter setting_ecc_present ]

    # Only when ECC is present and Fast core, this is sim reg is enabled
    if { "$impl" == "Fast" && $ecc_present } {
        proc_set_enable_visible_parameter setting_ecc_sim_test_ports "enable"
    }    
    
    
    if { $local_exportvectors } {
        proc_set_enable_visible_parameter breakOffset "disable"
        proc_set_enable_visible_parameter exceptionOffset "disable"
        proc_set_enable_visible_parameter resetOffset "disable"
        proc_set_enable_visible_parameter breakSlave "disable"
        proc_set_enable_visible_parameter exceptionSlave "disable"
        proc_set_enable_visible_parameter resetSlave "disable"
    }
}

proc sub_validate_check_module {} {
    global I_MASTER_INTF
    global D_MASTER_INTF
    global CLOCK_INTF
    global TCI_INTF_PREFIX
    global TCI_PREFIX
    global TCD_INTF_PREFIX
    global TCD_PREFIX
    global DEBUG_INTF

    global inst_slave_names
    global data_slave_names

    set inst_master_paddr_base          [ proc_num2hex [ proc_get_lowest_start_address instSlaveMapParam ] ]
    set inst_master_paddr_top           [ proc_num2hex [ proc_get_higest_end_address instSlaveMapParam ] ]
    set data_master_paddr_base          [ proc_num2hex [ proc_get_lowest_start_address dataSlaveMapParam ] ]
    set data_master_paddr_top           [ proc_num2hex [ proc_get_higest_end_address dataSlaveMapParam ] ]
    
    set resetSlave                      [ get_parameter_value resetSlave ]
    set exceptionSlave                  [ get_parameter_value exceptionSlave ]
    set breakSlave                      [ get_parameter_value breakSlave ]
    set mmu_TLBMissExcSlave             [ get_parameter_value mmu_TLBMissExcSlave ]
                                        
    set reset_addr                      [ proc_get_reset_addr ]
    set break_addr                      [ proc_get_break_addr ]
    set general_exception_addr          [ proc_get_general_exception_addr ]
    set fast_tlb_miss_exception_addr    [proc_get_fast_tlb_miss_exception_addr ]

    set resetOffset                     [ get_parameter_value resetOffset ]
    set exceptionOffset                 [ get_parameter_value exceptionOffset ]
                                        
    set tcim_num                        [ get_parameter_value icache_numTCIM ]
    set tcdm_num                        [ get_parameter_value dcache_numTCDM ]
    set icache_size                     [ get_parameter_value icache_size ]
    set dcache_size_derived             [ get_parameter_value dcache_size_derived ]
    set dcache_omitDataMaster           [ proc_get_boolean_parameter dcache_omitDataMaster ]
    set dcache_bursts_derived           [ get_parameter_value dcache_bursts_derived ]
                                        
    set impl                            [ get_parameter_value impl ]
    set device_family_name              [ get_parameter_value deviceFamilyName ]
    set muldiv_divider                  [ proc_get_boolean_parameter muldiv_divider ]
    set muldiv_multiplierType           [ get_parameter_value muldiv_multiplierType ]
    set cpu_freq                        [ get_parameter_value clockFrequency ]
    set debug_level                     [ get_parameter_value debug_level ]
    set debug_clk_x2                    [ proc_get_boolean_parameter debug_embeddedPLL ]
    set mmu_enabled                     [ proc_get_mmu_present ]
    set mpu_enabled                     [ proc_get_mpu_present ]
    set setting_interruptControllerType [ get_parameter_value setting_interruptControllerType ]
    set setting_shadowRegisterSets      [ get_parameter_value setting_shadowRegisterSets ]
    set debug_port_present              [ expr { "$debug_level" != "NoDebug" } ]
    set setting_bit31BypassDCache       [ proc_get_boolean_parameter setting_bit31BypassDCache ]
    set manuallyAssignCpuID             [ proc_get_boolean_parameter manuallyAssignCpuID ]
    set avail_break_slaves              [ proc_get_address_map_slaves_name instSlaveMapParam ]
    set export_vectors                  [ proc_get_boolean_parameter setting_exportvectors ]
    set ecc_present                     [ proc_get_boolean_parameter setting_ecc_present ]
    set dcache_victim_buf_impl          [ get_parameter_value dcache_victim_buf_impl ]

    # Constant
    set maximum_32bits_boundary      "0x100000000"
    set maximum_31bits_boundary      "0x80000000"
    set upper_4bits_address_mask     "0xf0000000"
    set upper_3bits_address_mask     "0xe0000000"
    set word_alignment_mask          "0x0000001f"

    set onchip_trace_support    [ expr { "$debug_level" == "Level3" } || { "$debug_level" == "Level4" } ]
    set inst_master_present     [ proc_get_inst_master_present ]
    set data_master_present     [ proc_get_data_master_present ]
    set both_master_present     [ expr {"$inst_master_present" == "1"} && {"$data_master_present" == "1"} ]
    
    set address_validity "address valid"
    # Do not check for the vectors when export_vectors are chosen
    if { !$export_vectors } {
        # validate that reset slave must be selected
        if { [ expr { "$resetSlave" == "None" } || { "RS_$resetSlave" == "RS_" } ] } {
            send_message error "Reset slave is not specified. Please select the reset slave"
            set address_validity "address not valid"
        } else {
                # return the reset offset address
                set abs_reset_inst_slaves [ proc_get_reset_addr ]
                set_parameter_value resetAbsoluteAddr $abs_reset_inst_slaves
                
                # validate that reset slave is connected to the instruction master
                # proc_get_address_map_1_slave_start_address will return -1 if no match
                set inst_reset_slave        [ proc_is_slave_exist instSlaveMapParam $resetSlave ]
                set tcim0resetSlave         [ proc_is_slave_exist ${TCI_PREFIX}0MapParam $resetSlave ]
                set tcim1resetSlave         [ proc_is_slave_exist ${TCI_PREFIX}1MapParam $resetSlave ]
                set tcim2resetSlave         [ proc_is_slave_exist ${TCI_PREFIX}2MapParam $resetSlave ]
                set tcim3resetSlave         [ proc_is_slave_exist ${TCI_PREFIX}3MapParam $resetSlave ]
                set data_reset_slave        [ expr { $inst_reset_slave } || { $tcim0resetSlave } || { $tcim1resetSlave } || { $tcim2resetSlave } || { $tcim3resetSlave } ]
                
                #if { [ expr { "[ proc_get_address_map_1_slave_start_address instSlaveMapParam $resetSlave ]" == "-1" } && { "$resetSlave" != "Absolute" } && { "$inst_master_present" == "1" } ] } {
                #    send_message error "Reset slave $resetSlave not connected to $I_MASTER_INTF."
                #}
                
                if { [ expr { "$inst_reset_slave" == "0" } && { "$tcim0resetSlave" == "0" } && { "$tcim1resetSlave" == "0" } && { "$tcim2resetSlave" == "0" } && { "$tcim3resetSlave" == "0" } && { "$resetSlave" != "Absolute" } ] } {
                    send_message error "Reset slave $resetSlave not connected to $I_MASTER_INTF."
                    set address_validity "address not valid"
                }
        
                # validate that reset slave is connected to the data master
                # Java model dont check this, do we want check?
                #if { [ expr { "[ proc_get_address_map_1_slave_start_address dataSlaveMapParam $resetSlave ]" == "-1" } && { "$resetSlave" != "Absolute" } && { "$data_master_present" == "1"} ] } {
                #    send_message error "Reset slave $resetSlave not connected to $D_MASTER_INTF."
                #}
                #if { "$data_reset_slave" == "0" } {
                #    if { [ expr { "[ proc_is_slave_exist dataSlaveMapParam $resetSlave ]" == "0" } && { "$resetSlave" != "Absolute" } && { "$data_master_present" == "1"} ] } {
                #        send_message error "Reset slave $resetSlave not connected to $D_MASTER_INTF."
                #    }
                #}
                # validate that reset slave offset must be multiple of 0x20 (from Nios2 validation)
                proc_validate_address_alignment $resetOffset \
                  $word_alignment_mask "Reset offset must be word aligned"
                  
                # validate that user's base + offset address does not exceed the slave end address
                if { [ expr { "[ proc_validate_offset $resetSlave $abs_reset_inst_slaves]" == "1" } && { "$resetSlave" != "Absolute" } ] } {
                    send_message error "Reset offset is too large for the selected memory"
                }
        
                # Vector must be cache aligned to 0x20, check when reset slave is valid
                if { [ expr { $reset_addr % 0x20 } && { $reset_addr != -1 } ] } {
                    send_message error "Reset vector must be a multiple of 0x20"
                }
            }
        
        # validate that exception slave must be selected
        if { [ expr { "$exceptionSlave" == "None" } || { "RS_$exceptionSlave" == "RS_" } ] } {
            send_message error "Exception slave is not specified. Please select the exception slave"
            set address_validity "address not valid"
        } else {
            # return the exception offset address
            set abs_exp_inst_slaves [ proc_get_general_exception_addr ]
            set_parameter_value exceptionAbsoluteAddr $abs_exp_inst_slaves
            
            # validate that Exception slave is connected to the instruction master
            #if { [ expr { "[ proc_get_address_map_1_slave_start_address instSlaveMapParam $exceptionSlave ]" == "-1" } && { "$exceptionSlave" != "Absolute" } && { "$inst_master_present" == "1"} ] } {
            #    send_message error "Exception slave $exceptionSlave not connected to $I_MASTER_INTF."
            #}
            set inst_exc_slave [ proc_is_slave_exist instSlaveMapParam $exceptionSlave ]
            set tcim0excSlave [ proc_is_slave_exist ${TCI_PREFIX}0MapParam $exceptionSlave ]
            set tcim1excSlave [ proc_is_slave_exist ${TCI_PREFIX}1MapParam $exceptionSlave ]
            set tcim2excSlave [ proc_is_slave_exist ${TCI_PREFIX}2MapParam $exceptionSlave ]
            set tcim3excSlave [ proc_is_slave_exist ${TCI_PREFIX}3MapParam $exceptionSlave ]
            set data_exc_slave      [ expr { $inst_exc_slave } || { $tcim0excSlave } || { $tcim1excSlave } || { $tcim2excSlave } || { $tcim3excSlave } ]
            if { [ expr { "$inst_exc_slave" == "0" } && { "$tcim0excSlave" == "0" } && { "$tcim1excSlave" == "0" } && { "$tcim2excSlave" == "0" } && { "$tcim3excSlave" == "0" } && { "$exceptionSlave" != "Absolute" } ] } {
                    send_message error "Exception slave $exceptionSlave not connected to $I_MASTER_INTF."
                    set address_validity "address not valid"
            }
        
            # validate that Exception slave is connected to the data master
            #if { [ expr { "[ proc_get_address_map_1_slave_start_address dataSlaveMapParam $exceptionSlave ]" == "-1" } && { "$exceptionSlave" != "Absolute" } && { "$data_master_present" == "1"} ] } {
            #    send_message error "Exception slave $exceptionSlave not connected to $D_MASTER_INTF."
            #}
            #if { "$data_exc_slave" == "0" } {
            #    if { [ expr { "[ proc_is_slave_exist dataSlaveMapParam $exceptionSlave ]" == "0" } && { "$exceptionSlave" != "Absolute" } && { "$data_master_present" == "1"} ] } {
            #            send_message error "Exception slave $exceptionSlave not connected to $D_MASTER_INTF."
            #    }
            #}
            # validate that Exception slave offset must be 0x20 (from Nios2 validation)
            proc_validate_address_alignment $exceptionOffset \
              $word_alignment_mask "Exception offset must be word aligned"
              
            # validate that user's base + offset address does not exceed the slave end address
            if { [ expr { "[ proc_validate_offset $exceptionSlave $abs_exp_inst_slaves]" == "1" } && { "$exceptionSlave" != "Absolute" } ] } {
                    send_message error "Exception offset is too large for the selected memory"
            }
        
            # check when the exception slave is valid
            if { [ expr { $general_exception_addr % 0x20 } && { $general_exception_addr != -1 } ] } {
                send_message error "Exception vector must be a multiple of 0x20"
            } 
        }
    }

    if { "$resetSlave" != "None" && "$reset_addr" == "$general_exception_addr" && "$address_validity" == "address valid" } {
        send_message error "Exception and Reset vectors are pointing to the same address"
    }

    if { "$mmu_enabled" == "1" && "$reset_addr" == "$fast_tlb_miss_exception_addr" && "$resetSlave" != "None" && "$address_validity" == "address valid" } {
        send_message error "Fast TLB miss and Reset vectors are pointing to the same address"
    }
    
    # return the Fast TLB Miss Exception offset address
    set mmu_TLBMissExcSlaveAbs [ proc_get_fast_tlb_miss_exception_addr ]
    set_parameter_value mmu_TLBMissExcAbsAddr $mmu_TLBMissExcSlaveAbs
    
    # validate that user's base + offset address does not exceed the slave end address
    if { [ expr { "[ proc_validate_offset $mmu_TLBMissExcSlave $mmu_TLBMissExcSlaveAbs]" == "1" } && { "$mmu_TLBMissExcSlave" != "Absolute" } ] } {
        send_message error "TLB Miss Exception offset is too large for the selected memory"
    }

    # validate that debug must be specified if debug port is enabled

    # TODO: figure out some way to assign the debug slave
    # to the jtag_debug_module. probably a syntactical thing
    # However this validation code can stay
    # Do not check for the vectors when export_vectors are chosen
    if { !$export_vectors } {
        if { [ expr { "$breakSlave" == "None" } || { "RS_$breakSlave" == "RS_" } ] } {
            if { $debug_port_present } {
                send_message error "Debug port is enabled. Please connect the instruction_master and data_master to jtag_debug_module"
            } else {
                send_message error "No break vector has been specified for this processor. Please choose an appropriate memory for the Break Vector setting"
                set address_validity "address not valid"
            }
        } else {
            # return the offset address
            set abs_break_inst_slaves [ proc_get_break_addr ]
            set_parameter_value breakAbsoluteAddr $abs_break_inst_slaves
            
            # validate that break slave is connected to the instruction master
            set inst_break_slave [ proc_is_slave_exist instSlaveMapParam $breakSlave ]
            set tcim0breakSlave [ proc_is_slave_exist ${TCI_PREFIX}0MapParam $breakSlave ]
            set tcim1breakSlave [ proc_is_slave_exist ${TCI_PREFIX}1MapParam $breakSlave ]
            set tcim2breakSlave [ proc_is_slave_exist ${TCI_PREFIX}2MapParam $breakSlave ]
            set tcim3breakSlave [ proc_is_slave_exist ${TCI_PREFIX}3MapParam $breakSlave ]

            if { "$debug_level" != "NoDebug" } {
                if { [ expr { "$inst_break_slave" == "0" } && { "$tcim0breakSlave" == "0" } && { "$tcim1breakSlave" == "0" } && { "$tcim2breakSlave" == "0" } && { "$tcim3breakSlave" == "0" } && { "$breakSlave" != "Absolute" } && { "$inst_master_present" == "1"} ] } {
                    send_message error "Debug slave $breakSlave not connected to $I_MASTER_INTF."
                    set address_validity "address not valid"
                }
            } else {
                if { [ expr { "$inst_break_slave" == "0" } && { "$tcim0breakSlave" == "0" } && { "$tcim1breakSlave" == "0" } && { "$tcim2breakSlave" == "0" } && { "$tcim3breakSlave" == "0" } && { "$breakSlave" != "Absolute" } && { "$inst_master_present" == "1"} ] } {
                    send_message error "Please choose an appropriate slave for the Break vector memory"
                    set address_validity "address not valid"
                }
            }
        
            # validate that debug slave is connected to the data master
            set data_break_slave [ proc_is_slave_exist dataSlaveMapParam $breakSlave ]
            set tcdm0breakSlave [ proc_is_slave_exist ${TCD_PREFIX}0MapParam $breakSlave ]
            set tcdm1breakSlave [ proc_is_slave_exist ${TCD_PREFIX}1MapParam $breakSlave ]
            set tcdm2breakSlave [ proc_is_slave_exist ${TCD_PREFIX}2MapParam $breakSlave ]
            set tcdm3breakSlave [ proc_is_slave_exist ${TCD_PREFIX}3MapParam $breakSlave ] 
            set data_break_slave_connect      [ expr { $data_break_slave } || { $tcdm0breakSlave } || { $tcdm1breakSlave } || { $tcdm2breakSlave } || { $tcdm3breakSlave } ]
            
            #if { "$data_break_slave_connect" == "0" } {
            #    if { [ expr { "[ proc_is_slave_exist dataSlaveMapParam $breakSlave ]" == "0" } && { "$breakSlave" != "Absolute" } && { "$data_master_present" == "1"} ] } {
            #        send_message error "Debug slave $breakSlave not connected to $D_MASTER_INTF."
            #    }
            #}
            
            # validate that user's base + offset address does not exceed the slave end address
            if { [ expr { "[ proc_validate_offset $breakSlave $abs_break_inst_slaves]" == "1" } && { "$breakSlave" != "Absolute" } ] } {
                send_message error "Break offset is too large for the selected memory"
            }
            
            # check when break slave is valid
            if { [ expr { $break_addr % 0x20 } && { $break_addr != -1 } ] } {
                send_message error "Break vector must be a multiple of 0x20"
            }
        }
    }

    # Get the clock frequency must be greater than 20MHz if jtag_debug_module is to work correctly
    if { [ expr { $cpu_freq != 0 } && { $cpu_freq < 20000000 } && { "$debug_level" != "NoDebug" } ] } {
        send_message error "Nios II debug module requires a clock frequency of at least 20 MHz"
    }

    # Validate instruction and data master against 2^32 boundary
    if { [ expr { $inst_master_paddr_top >= $maximum_32bits_boundary } ] } {
        send_message error "Nios II Instruction Master cannot address memories over 2^32"
    }

    if { [ expr { $data_master_paddr_top >= $maximum_32bits_boundary } ] } {
        send_message error "Nios II Data Master cannot address memories over 2^32"
    }

    set address_width [ get_parameter_value dataAddrWidth ]
    # Validate for non-MMU system
    if { [ expr { "$mmu_enabled" == "0" } ] } {
    # mmu not present
        if { [ expr { "$setting_bit31BypassDCache" == "1" } && { $address_width > 31 } && { "$dcache_omitDataMaster" == "0"}] } {
            send_message error "Memory map cannot fit within the addressable memory space of the Nios II Data Master which is restricted to 31 address bits"
        }

        # Validate that inst master has same uppper 4 bits address range
        set inst_master_paddr_top_upper_4bits [ proc_num2hex [expr $inst_master_paddr_top & $upper_4bits_address_mask ]]
        set inst_master_paddr_base_upper_4bits [ proc_num2hex [expr $inst_master_paddr_base & $upper_4bits_address_mask ]]

        if { "$inst_master_paddr_top_upper_4bits" != "$inst_master_paddr_base_upper_4bits" } {
            send_message warning "The address range of the slaves connected to the Nios II instruction masters exceeds 28 bits. Attempts to call functions across 28-bit boundaries is not supported by GCC and will result in linker errors."
        }

        ## Provide a warning message if TCM memory map and IM/DM memory map overlaps
        foreach i {0 1 2 3} {
            set INTF_TCI_NAME "${TCI_PREFIX}${i}"
            if { $i < $tcim_num } {
                set tcim_paddr_top_hex [ proc_num2hex [ proc_get_higest_end_address ${INTF_TCI_NAME}MapParam ]]
                set tcim_paddr_base_hex [ proc_num2hex [ proc_get_lowest_start_address ${INTF_TCI_NAME}MapParam ]]
                set inst_master_paddr_base_overlap_tcim [ expr { $inst_master_paddr_base >= $tcim_paddr_base_hex } && { $inst_master_paddr_base <= $tcim_paddr_top_hex } ]
                set inst_master_paddr_top_overlap_tcim [ expr { $inst_master_paddr_top >= $tcim_paddr_base_hex } && { $inst_master_paddr_top <= $tcim_paddr_top_hex } ]
                if { [ expr { $inst_master_paddr_base_overlap_tcim || $inst_master_paddr_top_overlap_tcim } ] } {
                    send_message warning "Generating non-optimal logic for ${INTF_TCI_NAME} due to memory map overlap with instruction master ($inst_master_paddr_base - $inst_master_paddr_top)"
                }
            }
        }

        foreach i {0 1 2 3} {
            set INTF_TCD_NAME "${TCD_PREFIX}${i}"
            if { $i < $tcdm_num } {
                set tcdm_paddr_top_hex [ proc_num2hex [ proc_get_higest_end_address ${INTF_TCD_NAME}MapParam ]]
                set tcdm_paddr_base_hex [ proc_num2hex [ proc_get_lowest_start_address ${INTF_TCD_NAME}MapParam ]]
                set data_master_paddr_base_overlap_tcdm [ expr { $data_master_paddr_base >= $tcdm_paddr_base_hex } && { $data_master_paddr_base <= $tcdm_paddr_top_hex } ]
                 set data_master_paddr_top_overlap_tcdm [ expr { $data_master_paddr_top >= $tcdm_paddr_base_hex } && { $data_master_paddr_top <= $tcdm_paddr_top_hex  } ]
                 if { [ expr {$data_master_paddr_base_overlap_tcdm || $data_master_paddr_top_overlap_tcdm } ] } {
                    send_message warning "Generating non-optimal logic for ${INTF_TCD_NAME} due to memory map overlap with data master ($data_master_paddr_base - $data_master_paddr_top)"
                }
            }
        }
    } else {
        # If mmu is enabled check for available mmu slaves first
        if {[ expr { "$mmu_TLBMissExcSlave" == "None" } || { "RS_$mmu_TLBMissExcSlave" == "RS_" } ]} {
            send_message error "Fast TLB miss exception vector memory is not specified. Please select the fast TLB miss exception slave"
        } else {
        # mmu present
        # check that the MMU Fast TLB is connected to any instruction master slave
            set inst_mmu_slave [ proc_is_slave_exist instSlaveMapParam $mmu_TLBMissExcSlave ]
            set tcim0mmuSlave [ proc_is_slave_exist ${TCI_PREFIX}0MapParam $mmu_TLBMissExcSlave ]
            set tcim1mmuSlave [ proc_is_slave_exist ${TCI_PREFIX}1MapParam $mmu_TLBMissExcSlave ]
            set tcim2mmuSlave [ proc_is_slave_exist ${TCI_PREFIX}2MapParam $mmu_TLBMissExcSlave ]
            set tcim3mmuSlave [ proc_is_slave_exist ${TCI_PREFIX}3MapParam $mmu_TLBMissExcSlave ]
            if { [ expr { "$inst_mmu_slave" == "0" } && { "$tcim0mmuSlave" == "0" } && { "$tcim1mmuSlave" == "0" } && { "$tcim2mmuSlave" == "0" } && { "$tcim3mmuSlave" == "0" } && { "$mmu_TLBMissExcSlave" != "Absolute" } && { "$inst_master_present" == "1"} ] } {
                send_message error "MMU Fast TLB slave $mmu_TLBMissExcSlave not connected to $I_MASTER_INTF."
                set address_validity "address not valid"
            }
        
            # Evaluate only when address is valid
            if { "$address_validity" == "address valid" } {
                # The tightly-coupled instruction and data masters can only connect to slaves with a base
                # address with bits 29-31 set to 0. This effectively restricts TCMs to having a 29-bit
                # address.  This is required because the TCMs are mapped into the KERNEL address region
                # which only supports a 29-bit physical address.
                foreach i {0 1 2 3} {
                    set INTF_TCI_NAME "${TCI_PREFIX}${i}"
                    if { $i < $tcim_num } {
                        set tcim_base_addr_top_3_bit [ expr [ proc_get_lowest_start_address ${INTF_TCI_NAME}MapParam ] & $upper_3bits_address_mask ]
                        if { [ expr { $tcim_base_addr_top_3_bit != 0 } ] } {
                            send_message error "In a MMU enabled system, Tightly Coupled Memory ${INTF_TCI_NAME} must be mapped into the KERNEL address region (address bits 31-29 set to 0)"
                        }
                    }
                }
                
                foreach i {0 1 2 3} {
                    set INTF_TCD_NAME "${TCD_PREFIX}${i}"
                    if { $i < $tcdm_num } {
                        set tcdm_base_addr_top_3_bit [ expr [ proc_get_lowest_start_address ${INTF_TCD_NAME}MapParam ] & $upper_3bits_address_mask ]
                        if { [ expr { $tcdm_base_addr_top_3_bit != 0 } ] } {
                            send_message error "In a MMU enabled system, Tightly Coupled Memory ${INTF_TCD_NAME} must be mapped into the KERNEL address region (address bits 31-29 set to 0)"
                        }
                    }
                }
                
                # Check Reset, Exception, Break, and Fast TLB Miss Exception slave addresses
                # to make sure they're mapped into the KERNEL region
                set reset_addr_top_3_bit [ expr { $reset_addr & $upper_3bits_address_mask } ]
                if { [ expr { $reset_addr_top_3_bit != 0 } ] } {
                    send_message error "In a MMU enabled system, reset vector must be mapped into the KERNEL address region (address bits 31-29 set to 0)"
                }
                
                set general_exceptopn_addr [ expr { $general_exception_addr & $upper_3bits_address_mask } ]
                if { [ expr { $general_exceptopn_addr != 0} ] } {
                    send_message error "In a MMU enabled system, exception vector must be mapped into the KERNEL address region (address bits 31-29 set to 0)"
                }
                
                set break_addr_top_3_bit [ expr { $break_addr & $upper_3bits_address_mask } ]
                if { [ expr { $break_addr_top_3_bit != 0 } ]  } {
                    send_message error "In a MMU enabled system, break vector must be mapped into the KERNEL address region (address bits 31-29 set to 0)"
                }
                
                set fast_tlb_addr_top_3_bit [ expr { $fast_tlb_miss_exception_addr & $upper_3bits_address_mask } ]
                if { [ expr { $fast_tlb_addr_top_3_bit != 0 } ] } {
                    send_message error "In a MMU enabled system, fast TLB miss vector must be mapped into the KERNEL address region (address bits 31-29 set to 0)"
                }
            }
            
            if { [ expr $fast_tlb_miss_exception_addr % 0x20 && { $fast_tlb_miss_exception_addr != -1 } ] } {
                send_message error "Fast TLB miss exception vector must be a multiple of 0x20"
            }
        }
    }

    # If the MPU is enabled, MPU "limit" mode is limited to systems
    # where both the instruction and data address width is 31 bits or 
    # less. This is part of a fix to SPR:389283 to suport 4GB addressing
    # with the MPU. 
    if { [ expr { "$mpu_enabled" == "1" } ] } {
      if { [proc_get_boolean_parameter mpu_useLimit] } {
        if { [ expr { $data_master_paddr_top >= $maximum_31bits_boundary } || { $inst_master_paddr_top >= $maximum_31bits_boundary } ] } {
          send_message error "MPU region 'Limit' mode cannot be used with instruction or data width greater than 31 bits."
        }
      }
    }
    
    if { "$impl" == "Fast" } {
        # MPU and MMU are mutually exclusive
        if { "$mmu_enabled" == "1" && "$mpu_enabled" == "1" } {
            send_message error "An MPU and an MMU are mutually exclusive"
        }

        # Check with omit data master is selected
        if { "$dcache_omitDataMaster" == "1" } {
            if { [ expr {"$tcdm_num" == "0"} ] } {
                send_message error "At least one Tightly Coupled Data Master must be present in order to omit Data Master"
            }

            # defaulting data cache size value to 0 when omit data master port is chosen
            set_parameter_property dcache_size "ENABLED" 0
            set_parameter_property dcache_lineSize "ENABLED" 0
            set_parameter_property dcache_bursts "ENABLED" 0
            set_parameter_value dcache_size_derived 0
            set_parameter_value dcache_lineSize_derived 0
            set_parameter_value dcache_bursts_derived false
            set_parameter_property dcache_victim_buf_impl "ENABLED" 0
        } else {
            set dcache_size_gui_value [ get_parameter_value dcache_size ]
            set dcache_lineSize_gui_value [ get_parameter_value dcache_lineSize ]
            set dcache_bursts_gui_value [ get_parameter_value dcache_bursts ]
            set_parameter_value dcache_size_derived $dcache_size_gui_value
            set_parameter_value dcache_lineSize_derived $dcache_lineSize_gui_value
            set_parameter_value dcache_bursts_derived $dcache_bursts_gui_value
            
            set setting_dc_ecc_present [ proc_get_boolean_parameter setting_dc_ecc_present ]
            if { $ecc_present } {
                # When Dcache size > 0, send out error message
                # But allow overrider just in case when the dc_ecc_present is set
                if { $dcache_size_gui_value > 0 & !$setting_dc_ecc_present } {
                    send_message error "Data Cache does not support ECC. Please turn off Dcache by setting it to None."
                }
                if { $setting_dc_ecc_present & $dcache_size_gui_value > 0 } {
                    if { $dcache_victim_buf_impl == "ram" } {
                        send_message warning "Data Cache Victim Line Bugger Implementation RAM will not be ECC protected. Recommended to choose register implementation."
                    }
                }
            }
        }
    }  else {
            set dcache_size_gui_value [ get_parameter_value dcache_size ]
            set dcache_lineSize_gui_value [ get_parameter_value dcache_lineSize ]
            set dcache_bursts_gui_value [ get_parameter_value dcache_bursts ]
            set_parameter_value dcache_size_derived $dcache_size_gui_value
            set_parameter_value dcache_lineSize_derived $dcache_lineSize_gui_value
            set_parameter_value dcache_bursts_derived $dcache_bursts_gui_value
    }
    
    # TODO: Ensure TCM slave didnt connect with inst/data master
    # TODO? how to ensure TCM slave has slave latency of 1
    # TODO? how to ensure TCM slave has same clock domain as the cpu
    # TODO? how to ensure jtag_debug_model only connect to own master


    # Display warning if cpuID is not assigned. Auto cpuID assignment is not supported in Qsys
    # backup cpuID value
    if { "$manuallyAssignCpuID" == "0" && "[ get_parameter_property manuallyAssignCpuID "ENABLED" ]" == "1" } {
        set cpuid_value [ get_parameter_value cpuID ]
        if { "$cpuid_value" != "0" } {
            set_parameter_value cpuID_stored $cpuid_value
            set_parameter_value cpuID 0
            set cpuid_value [ get_parameter_value cpuID ]
        }
        send_message info "CPUID control register value is ${cpuid_value}. Please manually assign CPUID if creating multiple Nios II system"
    }
    
    # restore previous cpuID value
    if { "$manuallyAssignCpuID" == "1" && "[ get_parameter_property manuallyAssignCpuID "ENABLED" ]" == "1" } {
        set cpuid_value [ get_parameter_value cpuID ]
        if { "$cpuid_value" == "0" } {
            set cpuid_stored_value [ get_parameter_value cpuID_stored ]
            set_parameter_value cpuID $cpuid_stored_value
        } else {
            set_parameter_value cpuID_stored $cpuid_value
        }
    }

    # Check device setting
    if { "$device_family_name" == "" } {
        send_message error "Device Type is not set"
    }

    # Debug Level check
    if { "$impl" == "Tiny" && "$debug_level" != "NoDebug" && "$debug_level" != "Level1" } {
        send_message error "Nios II processor does not support the debug level you have selected, Nios II/e only support No Debugger & Level 1"
    }

    if { "$debug_level" != "NoDebug" && "$both_master_present" == "0" } {
        send_message error "Nios II Debug Core requires both Instruction Master and Data Master to be present"
    }

    set setting_breakslaveoveride [ proc_get_boolean_parameter setting_breakslaveoveride ]
    # Automatically select the JTAG debug module if debugger is enabled
    # Really do somemore smart logic here, which is to avoid the breakslave set looping
    set current_break_slave [ get_parameter_value breakSlave ]
    
    # If the current break match debug interface 
    # and if it is part of the instruction master slave, set break_slave_is_debug_intf to 1 and break
    # Else set break_slave_is_debug_intf to 0 to continue with auto select
    if { [ string match "*${DEBUG_INTF}" "$current_break_slave" ] } {
        foreach default_slave $avail_break_slaves {
            if { [ string match "$current_break_slave" "$default_slave" ] } {
                set break_slave_is_debug_intf 1
                break
            } else {
                set break_slave_is_debug_intf 0
            }
        }
    } else {
        set break_slave_is_debug_intf 0
    }

    if { "$debug_level" != "NoDebug" && !$setting_breakslaveoveride && !$break_slave_is_debug_intf } {
        foreach default_slave $avail_break_slaves {
            if { [ string match "*${DEBUG_INTF}" "$default_slave" ] } {
                set_parameter_value breakSlave $default_slave
            }
        }
    }
    
    if { "$debug_level" == "NoDebug" } {
        send_message warning "No Debugger.  You will not be able to download or debug programs"
    }
    
    # Pending SPR:347223 (Auto connection of jtag_debug_module_slave)
    if { [ expr { "$debug_level" != "NoDebug" } && { ! [ string match -nocase "*jtag_debug_module" "$breakSlave" ] } && { $break_addr != -1 } && !$setting_breakslaveoveride ] } {
        send_message error "JTAG Debug Module must be connected to the Nios II Break Slave"
    }

    # Embedded PLL is not supported for Cyclone I/II/III/IV families due to limited number of PLL
    # FB:107781 For Cyclone V onwards, Embedded PLL will be auto-instantiated unless user decide to manually connect it
    if { [ string match -nocase "CYCLONE" "$device_family_name" ] ||
         [ string match -nocase "CYCLONE I*" "$device_family_name" ] ||
         [ string match -nocase "CYCLONE II*" "$device_family_name" ] ||
         [ string match -nocase "CYCLONE III*" "$device_family_name" ] ||
         [ string match -nocase "CYCLONE IV*" "$device_family_name" ] } {
        if { [ expr { $debug_clk_x2 } && { "$debug_level" == "Level4" } ] } {
            send_message error "Can't generate 2X sampling clock signal due to limited number of PLLs in this device family. Please connect 2X sampling clock manually"
        }
    }

    # If Cache Size is 0, then Instruction Master is omitted.  Info message
    if { "$impl" != "Tiny" && "$icache_size" == "0" } {
        send_message info "Disabling instruction cache omits Avalon instruction master port"
    }

    # Error case exists if cache size is 0 and numTCIM is 0
    if { "$inst_master_present" == "0" && "$tcim_num" == "0" } {
        send_message info "Processor must have instruction cache or at least one tightly coupled instruction master to function properly"
    }

    # Warn user if choosing enhanced interrupt without shadow register sets
    if { "$impl" == "Fast" && "$setting_interruptControllerType" == "External" && "$setting_shadowRegisterSets" == "0" } {
        send_message warning "Altera HAL does not support an external interrupt controller and 0 shadow register sets."
    }

    # Warn user if not choosing optimal value of shadow register sets for the chosen device family
    # only validate if shadow register sets setting is enabled
    # TODO: optimal 7 for M9K and 3 for M4K

    # Update tlb ptr sz if needed
    # TODO: 8 for M9K and 7 fo else


    # Multiplier Check
    # Ensure that only the supported multiplier type is chosen
    if { "$impl" != "Tiny" } {
        if { "$muldiv_multiplierType" == "DSPBlock" || "$muldiv_multiplierType" == "EmbeddedMulFast" } {
            if { "[ proc_validate_device_features "$muldiv_multiplierType" ]" == "0" } {
                send_message error "Multiplier selected is not compatible with selected device and design type"
            }
        }
    }
    
    # SPR:351336 (Auto change to default multiplier)
    if { [ string match -nocase "CYCLONE*" "$device_family_name" ] && "$impl" != "Tiny" } {
        if { "$muldiv_multiplierType" == "DSPBlock" } {
            send_message error "Multiplier selected is not compatible with selected device and design type"
            set_parameter_value muldiv_multiplierType "EmbeddedMulFast"
        }
    }
    
    if { [ string match -nocase "HardCopy*" "$device_family_name" ] && [ expr {"$muldiv_multiplierType" == "LogicElementsFast"} ] } {
        send_message error "Multiplier selected is not compatible with selected device and design type"
    }
    
    # Error case exists if avalonDebugPortPresent selected when NoDebug
    if { "$debug_level" == "NoDebug" && "$debug_port_present" == "1" } {
    	    send_message error "No Debugger available. Enable Debugger or disable Avalon Debug Port"
    }
    
    # Special case for dcache_bursts string type    
    if { ! [ expr { "$dcache_bursts_derived" == "true" } || { "$dcache_bursts_derived" == "false" } ] } {
        set small_db [string tolower $dcache_bursts_derived]
        if { [ expr { "$small_db" == "none" } || { "$small_db" == "0" } || { "$small_db" == "false" } || { "$small_db" == "" } || { "$small_db" == "disable" }] } {
            set_parameter_value dcache_bursts_derived false
        } else {
            set_parameter_value dcache_bursts_derived true
        }        
    }
    
    # check is_hardcopy_compatible
    set local_device_family_name [ string toupper "$device_family_name" ]
    regsub -all " " "$local_device_family_name" "" local_device_family_name
    if { [ string match *HARDCOPY* $local_device_family_name ] } {
        set_parameter_value is_hardcopy_compatible true
    }

    # check to make sure that the multiplier is supported by the device family
    # for either DSPBlock/Embedded Multiplier
    # else if the current Multiplier type is not in list, append it and check that it is not supported in current selected family
    # this is to suppress warning from Qsys and performed validation in hw.tcl
    if { "[ proc_validate_device_features "DSPBlock" ]" == "1" } {
       lappend allowed_multiplier "DSPBlock:DSP Block"
    }
    if { "[ proc_validate_device_features "EmbeddedMulFast" ]" == "1" } {
       lappend allowed_multiplier "EmbeddedMulFast:Embedded Multipliers"
    }

    # This case only happen when the moving from Cyclone to Stratix devices
    set current_multiplier                [ get_parameter_value muldiv_multiplierType ]
    if { "$current_multiplier" == "EmbeddedMulFast" && [ proc_not_matched_valid "$current_multiplier" "$allowed_multiplier" ] } {
        lappend allowed_multiplier "EmbeddedMulFast:Embedded Multipliers"
    }

    # This case only happen when the moving from Stratix to Cyclone devices
    if { "$current_multiplier" == "DSPBlock" && [ proc_not_matched_valid "$current_multiplier" "$allowed_multiplier" ] } {
        lappend allowed_multiplier "DSPBlock:DSP Block"
    }

    lappend allowed_multiplier "LogicElementsFast:Logic Elements" "NoneSmall:None"
    set_parameter_property muldiv_multiplierType ALLOWED_RANGES $allowed_multiplier

    # FB 12647: Error message when the clock source is unknown
    # Added this into Callback so that User can know about this error before RTL generation
    set cpu_freq                [ get_parameter_value clockFrequency ]
    if { $cpu_freq == 0 } {
        send_message warning "The clock source connected to the Nios's clock input has an unknown clock frequency."
    }

    # ASIC support for translate on/off
    set local_asic_enabled [ proc_get_boolean_parameter setting_asic_enabled ]
    set local_asic_synopsys_translate [ proc_get_boolean_parameter setting_asic_synopsys_translate_on_off ]

    if {$local_asic_enabled && $local_asic_synopsys_translate} {
        set_parameter_value  translate_on  { "synopsys translate_on"  }
        set_parameter_value  translate_off { "synopsys translate_off" }
    }
    
    if { $export_vectors == 1 } {
        send_message info "Please ensure that vector conduits are driven"
    }
}

# Some smart logic to auto select break slave.
#proc updateDebugSlave {} {
#    # Automatically select the JTAG debug module if debugger is enabled
#    if { "$debug_level" == "NoDebug" } {
#        set_parameter debug_port_present "0"
#    } else {
#        set_parameter debug_port_present "1"
#        foreach inst_slave $inst_slave_address_map_dec {
#            array set inst_slave_info $inst_slave
#            set inst_slave_name "$inst_slave_info(name)"
#            if { [ string match "$break_slave_interface" "$inst_slave_name" ] } {
#                foreach data_slave $data_slave_address_map_dec {
#                    array set data_slave_info $data_slave
#                    if { [ string match "$inst_slave_name" "$data_slave_info(name)" ] } {
#                        set found_break_slave   "1"
#                        set break_slave_value   "$inst_slave_name"
#                        set break_addr_value    "[ proc_num2unsigned [ expr $data_slave_info(start) + $break_slave_offset ]]"
#                        break
#                    }
#                }
#                if { "$found_break_slave" == "1" } {
#                    break
#                }
#            }
#        }
#    }
#}

proc proc_get_final_tlb_ptr_size {} {
    # Update tlb ptr sz if needed
    if { [ proc_get_boolean_parameter mmu_autoAssignTlbPtrSz ] } {
        if { [ is_device_feature_exist "M9K_MEMORY" ] } {
            return 8
        } else {
            return 7
        }
    } else {
        return [ get_parameter_value mmu_tlbPtrSz ]
    }
}


proc sub_validate_update_module_embeddedsw_cmacros {} {

    set impl                        [ get_parameter_value impl ]
    set icache_size                 [ get_parameter_value icache_size ]
    set dcache_size_derived         [ get_parameter_value dcache_size_derived ]
    set dcache_lineSize_derived     [ get_parameter_value dcache_lineSize_derived ]
    set mmu_enabled                 [ proc_get_mmu_present ]
    set resetAddress                [ proc_num2hex [ proc_get_reset_addr ] ]
    set excAddress                  [ proc_num2hex [ proc_get_general_exception_addr ] ]
    set breakAddress                [ proc_num2hex [ proc_get_break_addr ] ]
    set tlb_miss_addr               [ proc_num2hex [ proc_get_fast_tlb_miss_exception_addr ] ]
    set finalTlbPtrSz               [ proc_get_final_tlb_ptr_size ]

    # Start adding C Macro

    proc_set_module_embeddedsw_cmacro_assignment "CPU_IMPLEMENTATION"           "\"[ string tolower $impl ]\""
    proc_set_module_embeddedsw_cmacro_assignment "BIG_ENDIAN"                   "[ proc_get_boolean_parameter setting_bigEndian ]"
    proc_set_module_embeddedsw_cmacro_assignment "CPU_FREQ"                     "[ proc_num2unsigned [ get_parameter_value clockFrequency ]]u"

    # icache line size defaults to 32 / 2^5
    # these values should be set to 0 if icache is not enabled
    if { "$icache_size" == "0" || "$impl" == "Tiny" } {
        proc_set_module_embeddedsw_cmacro_assignment "ICACHE_LINE_SIZE"             0
        proc_set_module_embeddedsw_cmacro_assignment "ICACHE_LINE_SIZE_LOG2"        0
        proc_set_module_embeddedsw_cmacro_assignment "ICACHE_SIZE"                  0
    } else {
        proc_set_module_embeddedsw_cmacro_assignment "ICACHE_LINE_SIZE"             32
        proc_set_module_embeddedsw_cmacro_assignment "ICACHE_LINE_SIZE_LOG2"        5
        proc_set_module_embeddedsw_cmacro_assignment "ICACHE_SIZE"                  $icache_size

    }

    # this seems ugly somehow...
    if { "$dcache_size_derived" == "0" || "$impl" != "Fast" } {
        proc_set_module_embeddedsw_cmacro_assignment "DCACHE_LINE_SIZE"             0
        proc_set_module_embeddedsw_cmacro_assignment "DCACHE_LINE_SIZE_LOG2"        0
        proc_set_module_embeddedsw_cmacro_assignment "DCACHE_SIZE"                  0
    } else {
        proc_set_module_embeddedsw_cmacro_assignment "DCACHE_LINE_SIZE"             $dcache_lineSize_derived
        proc_set_module_embeddedsw_cmacro_assignment "DCACHE_LINE_SIZE_LOG2"        [ proc_num2sz $dcache_lineSize_derived ]
        proc_set_module_embeddedsw_cmacro_assignment "DCACHE_SIZE"                  $dcache_size_derived

        # The new data cache (line size not equal to 4 bytes) supports the INITDA instruction.
        if { "$dcache_lineSize_derived" != 4 } {
            proc_set_module_embeddedsw_cmacro_assignment "INITDA_SUPPORTED"  ""
            set_module_assignment {embeddedsw.dts.params.ALTR,has-initda} 1
        }
    }

    proc_set_module_embeddedsw_cmacro_assignment "FLUSHDA_SUPPORTED"            ""
    proc_set_module_embeddedsw_cmacro_assignment "HAS_JMPI_INSTRUCTION"         ""


    # mmu enabled?
    if { $mmu_enabled } {

        # Add the entries into system.h
        proc_set_module_embeddedsw_cmacro_assignment    "KERNEL_REGION_BASE"      "0xc0000000"
        proc_set_module_embeddedsw_cmacro_assignment    "IO_REGION_BASE"          "0xe0000000"
        proc_set_module_embeddedsw_cmacro_assignment    "KERNEL_MMU_REGION_BASE"  "0x80000000"
        proc_set_module_embeddedsw_cmacro_assignment    "USER_REGION_BASE"        "0x00000000"


        # Few other MMU parameter to send to system.h for reference
        proc_set_module_embeddedsw_cmacro_assignment    "MMU_PRESENT" ""
        proc_set_module_embeddedsw_cmacro_assignment    "PROCESS_ID_NUM_BITS"     [ get_parameter_value mmu_processIDNumBits ]
        proc_set_module_embeddedsw_cmacro_assignment    "TLB_NUM_WAYS"            [ get_parameter_value mmu_tlbNumWays ]
        proc_set_module_embeddedsw_cmacro_assignment    "TLB_NUM_WAYS_LOG2"       [ proc_num2sz [ get_parameter_value mmu_tlbNumWays ] ]
        proc_set_module_embeddedsw_cmacro_assignment    "TLB_PTR_SZ"              $finalTlbPtrSz
        proc_set_module_embeddedsw_cmacro_assignment    "TLB_NUM_ENTRIES"         [ expr { 1 << $finalTlbPtrSz } ]

        # If we have MMU, get the their kernel address
        proc_set_module_embeddedsw_cmacro_assignment    "FAST_TLB_MISS_EXCEPTION_ADDR"              "[ proc_num2hex [ expr { $tlb_miss_addr | 0xc0000000 } ] ]"
        proc_set_module_embeddedsw_cmacro_assignment    "EXCEPTION_ADDR"                            "[ proc_num2hex [ expr { $excAddress    | 0xc0000000 } ] ]"
        proc_set_module_embeddedsw_cmacro_assignment    "RESET_ADDR"                                "[ proc_num2hex [ expr { $resetAddress  | 0xc0000000 } ] ]"
        proc_set_module_embeddedsw_cmacro_assignment    "BREAK_ADDR"                                "[ proc_num2hex [ expr { $breakAddress  | 0xc0000000 } ] ]"
    } else {
        # If we don't have MMU, simply display the addresses
        proc_set_module_embeddedsw_cmacro_assignment    "EXCEPTION_ADDR"                            "$excAddress"
        proc_set_module_embeddedsw_cmacro_assignment    "RESET_ADDR"                                "$resetAddress"
        proc_set_module_embeddedsw_cmacro_assignment    "BREAK_ADDR"                                "$breakAddress"
    }

    set mpu_enable [proc_get_mpu_present]
    # mpu enabled?
    if { $mpu_enable } {
        proc_set_module_embeddedsw_cmacro_assignment "MPU_PRESENT" ""

        if { [ proc_get_boolean_parameter mpu_useLimit ] } {
            proc_set_module_embeddedsw_cmacro_assignment  "MPU_REGION_USES_LIMIT" ""
        }
        set mpu_min_inst_region_size_log2 [ get_parameter_value mpu_minInstRegionSize]
        set mpu_min_data_region_size_log2 [ get_parameter_value mpu_minDataRegionSize]

        proc_set_module_embeddedsw_cmacro_assignment   "MPU_MIN_DATA_REGION_SIZE_LOG2"     $mpu_min_data_region_size_log2
        proc_set_module_embeddedsw_cmacro_assignment   "MPU_MIN_DATA_REGION_SIZE"          [ expr { 1 << $mpu_min_data_region_size_log2 } ]
        proc_set_module_embeddedsw_cmacro_assignment   "MPU_MIN_INST_REGION_SIZE_LOG2"     $mpu_min_inst_region_size_log2
        proc_set_module_embeddedsw_cmacro_assignment   "MPU_MIN_INST_REGION_SIZE"          [ expr { 1 << $mpu_min_inst_region_size_log2 } ]
        proc_set_module_embeddedsw_cmacro_assignment   "MPU_NUM_DATA_REGIONS"              [ proc_num2unsigned [ get_parameter_value mpu_numOfDataRegion ]]
        proc_set_module_embeddedsw_cmacro_assignment   "MPU_NUM_INST_REGIONS"              [ proc_num2unsigned [ get_parameter_value mpu_numOfInstRegion ]]
    }

    # If break address and reset addresses are not same, then has_debug_stub
    if { [ expr { $breakAddress != $resetAddress } ] } {
        proc_set_module_embeddedsw_cmacro_assignment  "HAS_DEBUG_STUB"  ""
    }

    set debug_level    [ get_parameter_value debug_level ]
    # If debug level not NoDebug, then oci core is included
    proc_set_module_embeddedsw_cmacro_assignment "HAS_DEBUG_CORE" [ expr { "$debug_level" != "NoDebug" } ]

    # illegal instruction trap enabled or MMU is enabled?
    if { [ proc_get_europa_illegalInstructionsTrap ] } {
        proc_set_module_embeddedsw_cmacro_assignment  "HAS_ILLEGAL_INSTRUCTION_EXCEPTION" ""
    }

    # We're looking for Precise Illegal Mem Access Exception, Slave Access Error Exception, and extra exception info
    if { [ proc_get_europa_illegal_mem_exc ] } {
        proc_set_module_embeddedsw_cmacro_assignment  "HAS_ILLEGAL_MEMORY_ACCESS_EXCEPTION" ""
    }

    if { [ proc_get_europa_slave_access_error_exc ] } {
        proc_set_module_embeddedsw_cmacro_assignment  "HAS_SLAVE_ACCESS_ERROR_EXCEPTION" ""
    }

    if { [ proc_get_europa_division_error_exc ] } {
        proc_set_module_embeddedsw_cmacro_assignment  "HAS_DIVISION_ERROR_EXCEPTION" ""
    }

    if { [ proc_get_europa_imprecise_illegal_mem_exc ] } {
        proc_set_module_embeddedsw_cmacro_assignment  "HAS_IMPRECISE_ILLEGAL_MEMORY_ACCESS_EXCEPTION" ""
    }

    # Extra exception info is enabled when user turn on MPU, MMU or by enable it explicitly.
    if { [ proc_get_europa_extra_exc_info ] } {
        proc_set_module_embeddedsw_cmacro_assignment  "HAS_EXTRA_EXCEPTION_INFO" ""
    }

    # As of yet, we don't know how to deal with CPU ID
    set cpu_id [ get_parameter_value cpuID ]
    proc_set_module_embeddedsw_cmacro_assignment   "CPU_ID_SIZE" [ proc_num2sz $cpu_id ]
    proc_set_module_embeddedsw_cmacro_assignment   "CPU_ID_VALUE" [ proc_num2hex $cpu_id ]

    # Adding System.h content for hardware multiplier and divider
    # If the core is tiny, they're all disabled
    if { [ expr { "$impl" == "Tiny" } ] } {
        proc_set_module_embeddedsw_cmacro_assignment "HARDWARE_MULTIPLY_PRESENT"    0
        proc_set_module_embeddedsw_cmacro_assignment "HARDWARE_MULX_PRESENT"        0
        proc_set_module_embeddedsw_cmacro_assignment "HARDWARE_DIVIDE_PRESENT"      0
    } else {
        # Check the divider
        if { [ proc_get_boolean_parameter muldiv_divider ] } {
            proc_set_module_embeddedsw_cmacro_assignment  "HARDWARE_DIVIDE_PRESENT" 1
        } else {
            proc_set_module_embeddedsw_cmacro_assignment  "HARDWARE_DIVIDE_PRESENT" 0
        }

        # Check the multiplier
        set mul_type [ get_parameter_value muldiv_multiplierType ]
        if { [ expr { "$mul_type" == "NoneSmall" } ] } {
            proc_set_module_embeddedsw_cmacro_assignment "HARDWARE_MULTIPLY_PRESENT"    0
            proc_set_module_embeddedsw_cmacro_assignment "HARDWARE_MULX_PRESENT"        0
        } else {
            # We know that we have a hardware multiplier now
            proc_set_module_embeddedsw_cmacro_assignment "HARDWARE_MULTIPLY_PRESENT" 1

            # Need to check the mulx, which is a derived setting from the multiplier type
            if { [ expr { "$mul_type" == "DSPBlock" } ] } {
                proc_set_module_embeddedsw_cmacro_assignment "HARDWARE_MULX_PRESENT" 1
            } else {
                proc_set_module_embeddedsw_cmacro_assignment "HARDWARE_MULX_PRESENT" 0
            }
        }
    }

    # Add information about instruction and data address width
    proc_set_module_embeddedsw_cmacro_assignment   "INST_ADDR_WIDTH" [ proc_get_cmacro_inst_addr_width ]
    proc_set_module_embeddedsw_cmacro_assignment   "DATA_ADDR_WIDTH" [ proc_get_cmacro_data_addr_width ]

    # Adding System.h content for eic and shadow register sets support
    # If the core is not fast, they're all disabled
    set setting_interruptControllerType             [ get_parameter_value setting_interruptControllerType ]
    set ecc_present                                 [ proc_get_boolean_parameter setting_ecc_present ]
    set ecc_sim_test_ports                          [ proc_get_boolean_parameter setting_ecc_sim_test_ports ]

    if { [ expr { "$impl" == "Fast" } ] } {
        if { [ expr { "$setting_interruptControllerType" == "External" } ] } {
            proc_set_module_embeddedsw_cmacro_assignment  "EIC_PRESENT" ""
        }
        proc_set_module_embeddedsw_cmacro_assignment   "NUM_OF_SHADOW_REG_SETS" [ get_parameter_value setting_shadowRegisterSets ]
        
        # Adding a embeddedsw cmacro for ECC present
        if { $ecc_present } {
            proc_set_module_embeddedsw_cmacro_assignment  "ECC_PRESENT" ""

            if { $ecc_sim_test_ports } {
                proc_set_module_embeddedsw_cmacro_assignment  "ECC_RF_SIZE" "39"
                proc_set_module_embeddedsw_cmacro_assignment  "ECC_DCACHE_DATA_SIZE" "39"
                proc_set_module_embeddedsw_cmacro_assignment  "ECC_ICACHE_DATA_SIZE" "39"
                
                # Only define when TCMs are present
                set tcdm_num                 [ get_parameter_value dcache_numTCDM ]
                foreach i {0 1 2 3} {
                    if { $i < $tcdm_num } {
                        proc_set_module_embeddedsw_cmacro_assignment  "ECC_DTCM${i}_SIZE" "39"
                    }
                }

                # TLB, Data/Inst Cache Tag RAM
                set ic_tag_data_sz           [ proc_calculate_ic_tag_data_size ]
                set ic_tag_ecc_bits          [ proc_calculate_ecc_bits $ic_tag_data_sz ]
                set ic_tag_ecc_sz            [ expr { $ic_tag_ecc_bits + $ic_tag_data_sz } ]
                proc_set_module_embeddedsw_cmacro_assignment  "ECC_ICACHE_TAG_SIZE" $ic_tag_ecc_sz
                
                set dc_tag_data_sz           [ proc_calculate_dc_tag_data_size ]
                set dc_tag_ecc_bits          [ proc_calculate_ecc_bits $dc_tag_data_sz ]
                set dc_tag_ecc_sz            [ expr { $dc_tag_ecc_bits + $dc_tag_data_sz } ]
                proc_set_module_embeddedsw_cmacro_assignment  "ECC_DCACHE_TAG_SIZE" $dc_tag_ecc_sz
                
                set tlb_data_size         [ proc_calculate_tlb_data_size ]
                set tlb_ecc_bits          [ proc_calculate_ecc_bits $tlb_data_size ]
                set tlb_ecc_sz            [ expr { $tlb_ecc_bits + $tlb_data_size } ]
                proc_set_module_embeddedsw_cmacro_assignment  "ECC_TLB_SIZE" $tlb_ecc_sz
            }
        }
    }
    
    # Device tree parameters
    set_module_assignment embeddedsw.dts.vendor "altr"
    set_module_assignment embeddedsw.dts.group "cpu"
    set_module_assignment embeddedsw.dts.name "nios2"
    set_module_assignment embeddedsw.dts.compatible "altr,nios2-1.0"
    set_module_assignment {embeddedsw.dts.params.clock-frequency} [ get_module_assignment embeddedsw.CMacro.CPU_FREQ ]
    set_module_assignment {embeddedsw.dts.params.dcache-line-size} [ get_module_assignment embeddedsw.CMacro.DCACHE_LINE_SIZE ]
    set_module_assignment {embeddedsw.dts.params.icache-line-size} [ get_module_assignment embeddedsw.CMacro.ICACHE_LINE_SIZE ]
    set_module_assignment {embeddedsw.dts.params.dcache-size} [ get_module_assignment embeddedsw.CMacro.DCACHE_SIZE ]
    set_module_assignment {embeddedsw.dts.params.icache-size} [ get_module_assignment embeddedsw.CMacro.ICACHE_SIZE ]
    set_module_assignment {embeddedsw.dts.params.ALTR,implementation} "[ get_module_assignment embeddedsw.CMacro.CPU_IMPLEMENTATION ]"
    set_module_assignment {embeddedsw.dts.params.ALTR,reset-addr} [ get_module_assignment embeddedsw.CMacro.RESET_ADDR ]
    set_module_assignment {embeddedsw.dts.params.ALTR,exception-addr} [ get_module_assignment embeddedsw.CMacro.EXCEPTION_ADDR ]

    if { $mmu_enabled } {
        set_module_assignment {embeddedsw.dts.params.ALTR,pid-num-bits} [ get_module_assignment embeddedsw.CMacro.PROCESS_ID_NUM_BITS ]
        set_module_assignment {embeddedsw.dts.params.ALTR,tlb-num-ways} [ get_module_assignment embeddedsw.CMacro.TLB_NUM_WAYS ]
        set_module_assignment {embeddedsw.dts.params.ALTR,tlb-num-entries} [ get_module_assignment embeddedsw.CMacro.TLB_NUM_ENTRIES ]
        set_module_assignment {embeddedsw.dts.params.ALTR,tlb-ptr-sz} [ get_module_assignment embeddedsw.CMacro.TLB_PTR_SZ ]
        set_module_assignment {embeddedsw.dts.params.ALTR,has-mmu} [ get_module_assignment embeddedsw.CMacro.MMU_PRESENT ]
        set_module_assignment {embeddedsw.dts.params.ALTR,fast-tlb-miss-addr} [ get_module_assignment embeddedsw.CMacro.FAST_TLB_MISS_EXCEPTION_ADDR ]
    }
    # Boolean
    if { [ get_module_assignment embeddedsw.CMacro.HARDWARE_DIVIDE_PRESENT ] } {
        set_module_assignment {embeddedsw.dts.params.ALTR,has-div} 1
    }

    if { [ get_module_assignment embeddedsw.CMacro.HARDWARE_MULTIPLY_PRESENT ] } {
        set_module_assignment {embeddedsw.dts.params.ALTR,has-mul} 1
    }

    if { [ get_module_assignment embeddedsw.CMacro.HARDWARE_MULX_PRESENT ] } {
        set_module_assignment {embeddedsw.dts.params.ALTR,has-mulx} 1
    }
}

proc sub_validate_update_module_embeddedsw_configurations {} {
    # Required for embeddedsw tools to recognize this module as a Nios II CPU.
    proc_set_module_embeddedsw_configuration_assignment "cpuArchitecture"       "Nios II"
    proc_set_module_embeddedsw_configuration_assignment "HDLSimCachesCleared"   [ proc_get_boolean_parameter setting_HDLSimCachesCleared]

    proc_set_module_embeddedsw_configuration_assignment "resetSlave"            [ get_parameter_value resetSlave ]
    proc_set_module_embeddedsw_configuration_assignment "resetOffset"           [ get_parameter_value resetOffset ]
    proc_set_module_embeddedsw_configuration_assignment "exceptionSlave"        [ get_parameter_value exceptionSlave ]
    proc_set_module_embeddedsw_configuration_assignment "exceptionOffset"       [ get_parameter_value exceptionOffset ]
    proc_set_module_embeddedsw_configuration_assignment "breakSlave"            [ get_parameter_value breakSlave ]
    proc_set_module_embeddedsw_configuration_assignment "breakOffset"           [ get_parameter_value breakOffset ]

    # mmu enabled?
    set mmu_enabled    [ proc_get_mmu_present ]
    if { $mmu_enabled } {
        proc_set_module_embeddedsw_configuration_assignment "mmu_TLBMissExcSlave"            [ get_parameter_value mmu_TLBMissExcSlave ]
        proc_set_module_embeddedsw_configuration_assignment "mmu_TLBMissExcOffset"           [ get_parameter_value mmu_TLBMissExcOffset ]
    }
}
proc sub_show_hidden {} {
    set show_unpublished_settings   [ proc_get_boolean_parameter setting_showUnpublishedSettings ]
    set show_internal_settings      [ proc_get_boolean_parameter setting_showInternalSettings    ]
    set local_asic_enabled          [ proc_get_boolean_parameter setting_asic_enabled            ]

    set parameters [get_parameters]
    foreach param $parameters {
      if { [ expr { $param != "setting_showUnpublishedSettings" } && { $param != "setting_showInternalSettings" } ] } {
        set param_status [get_parameter_property $param "STATUS" ]

        if { "$param_status" == "EXPERIMENTAL" } {
            
            set param_description [get_parameter_property $param "DESCRIPTION" ]

            if { "$param_description" == "INTERNAL (Not Supported)" } {
                set_parameter_property  $param   "VISIBLE" $show_internal_settings
            } else {
                set_parameter_property  $param   "VISIBLE" $show_unpublished_settings
            }
        }
      }
      # Show asic_synopsys_translate_on_off parameter only when asic_enabled
      if { [ expr { $param == "setting_asic_synopsys_translate_on_off" }] } {
          set_parameter_property  $param   "VISIBLE" $local_asic_enabled
      }
    }
}

proc validate_process {} { 
    sub_validate_update_parameters
    sub_validate_update_parameterization_gui
    sub_validate_check_module
    sub_validate_update_module_embeddedsw_cmacros
    sub_validate_update_module_embeddedsw_configurations
    sub_show_hidden
}

proc validate {} {
    set local_instaddrwidth          [ get_parameter_value instAddrWidth ]
    set local_dataaddrwidth          [ get_parameter_value dataAddrWidth ]
    
    if { "$local_instaddrwidth" > "32" || "$local_dataaddrwidth" > "32" } {
        send_message error "Address width above 32 bits are not supported for Nios II"
    } else {
        validate_process
    }
}


#------------------------------------------------------------------------------
#                              G E N E R A T I O N
#------------------------------------------------------------------------------

proc proc_get_avalon_master_string {AVALON_MASTER} {
    array set avalon_master $AVALON_MASTER
    set indent "$avalon_master(indent)"
    set return_string {}
    append return_string "${indent}$avalon_master(name) => {\n"
        append return_string "${indent}\ttype => $avalon_master(type),\n"
        append return_string "${indent}\tis_tcm => $avalon_master(is_tcm),\n"
        append return_string "${indent}\tpaddr_base => $avalon_master(paddr_base),\n"
        append return_string "${indent}\tpaddr_top => $avalon_master(paddr_top),\n"
    append return_string "${indent}},\n"
    return "$return_string"
}

# validation is needed for TCM (only 1 slave plus info in validate_tightly_coupled_slave())
proc proc_get_avalon_master_info_string {} {
    global I_MASTER_INTF
    global D_MASTER_INTF
    global TCD_INTF_PREFIX
    global TCD_PREFIX
    global TCI_INTF_PREFIX
    global TCI_PREFIX
    
    set impl                            [ get_parameter_value impl ]
    set icache_size                     [ get_parameter_value icache_size ]
    set dcache_omitDataMaster           [ proc_get_boolean_parameter dcache_omitDataMaster ]
    set dcache_size_derived             [ get_parameter_value dcache_size_derived ]
    set tcdm_num                        [ get_parameter_value dcache_numTCDM ]
    set tcim_num                        [ get_parameter_value icache_numTCIM ]
    
    set inst_master_present             [ proc_get_inst_master_present ]
    set data_master_present             [ proc_get_data_master_present ]

    set instruction_master(name)        $I_MASTER_INTF
    set instruction_master(type)        "instruction"
    set instruction_master(is_tcm)      0
    set instruction_master(paddr_base)  [ proc_num2hex [ proc_get_lowest_start_address instSlaveMapParam ] ]
    set instruction_master(paddr_top)   [ proc_width2maxaddr [ get_parameter_value instAddrWidth ] ]
    set instruction_master(indent)      "\t\t\t"

    set data_master(name)               $D_MASTER_INTF
    set data_master(type)               "data"
    set data_master(is_tcm)             0
    set data_master(paddr_base)         [ proc_num2hex [ proc_get_lowest_start_address dataSlaveMapParam ] ]
    set data_master(paddr_top)          [ proc_width2maxaddr [ get_parameter_value dataAddrWidth ] ]
    set data_master(indent)             "\t\t\t"

    set tcdm_num    [ get_parameter_value dcache_numTCDM ]
    set tcim_num    [ get_parameter_value icache_numTCIM ]

    set return_string ""
    append return_string "\tavalon_master_info => {\n"
        append return_string "\t\tavalon_masters => {\n"
        if { $inst_master_present } {
            append return_string "[ proc_get_avalon_master_string [ array get instruction_master ]]"
        }
        if { $data_master_present } {
            append return_string "[ proc_get_avalon_master_string [ array get data_master ]]"
        }

    foreach i {0 1 2 3} {
        set TCD_INTF_NAME "${TCD_INTF_PREFIX}${i}"
        set TCD_NAME "${TCD_PREFIX}${i}"
        set tcdm_address_base [ proc_num2hex [ proc_get_lowest_start_address ${TCD_NAME}MapParam ] ]
        if { [ expr { $tcdm_address_base != "[ proc_num2hex "-1" ]" } ] } {
            if { $i < $tcdm_num } {
                set tcd_master(name)               $TCD_INTF_NAME
                set tcd_master(type)               "data"
                set tcd_master(is_tcm)             1
                set tcd_master(paddr_base)         [ proc_num2hex [ proc_get_lowest_start_address ${TCD_NAME}MapParam ] ]
                set tcd_master(paddr_top)          [ proc_num2hex [ proc_get_higest_end_address ${TCD_NAME}MapParam ] ]
                set tcd_master(indent)             "\t\t\t"
                append return_string "[ proc_get_avalon_master_string [ array get tcd_master ]]"
            }
        }
    }

    foreach i {0 1 2 3} {
        set TCI_INTF_NAME "${TCI_INTF_PREFIX}${i}"
        set TCI_NAME "${TCI_PREFIX}${i}"
        set tcim_address_base [ proc_num2hex [ proc_get_lowest_start_address ${TCI_NAME}MapParam ] ]
        if { [ expr { $tcim_address_base != "[ proc_num2hex "-1" ]" } ] } {
            if { $i < $tcim_num } {
                set tci_master(name)               $TCI_INTF_NAME
                set tci_master(type)               "instruction"
                set tci_master(is_tcm)             1
                set tci_master(paddr_base)         [ proc_num2hex [ proc_get_lowest_start_address ${TCI_NAME}MapParam ] ]
                set tci_master(paddr_top)          [ proc_num2hex [ proc_get_higest_end_address ${TCI_NAME}MapParam ] ]
                set tci_master(indent)             "\t\t\t"
                append return_string "[ proc_get_avalon_master_string [ array get tci_master ]]"
            }
        }
    }

        append return_string "\t\t},\n"
    append return_string "\t},\n"
    return "$return_string"
}

proc proc_get_avalon_slaves_string {AVALON_SLAVE} {
    array set avalon_slave $AVALON_SLAVE
    set indent "$avalon_slave(indent)"
    set avalon_slave_start  [ proc_num2hex $avalon_slave(start) ]
    set avalon_slave_end    [ proc_num2hex [ expr { $avalon_slave(end) - 1 } ] ]
    
    # Replace "." with "/". Eg. cpu_0.jtag_debug_module to cpu_0/jtag_debug_module to conform with system ptf
    # else quartus/sopc_builder/bin/europa/e_signal.pm will complaint "is no good for a signal"
    set avalon_slave_name [string map {. /} "$avalon_slave(name)"]
    
    set return_string {}
    
    append return_string "${indent}\"$avalon_slave_name\" => {\n"
    append return_string "${indent}\tbase => $avalon_slave_start,\n"
    append return_string "${indent}\tend => $avalon_slave_end,\n"

    # TODO: solve readonly according to nios2_ptf_utils.pm sub is_slave_readonly
    append return_string "${indent}\treadonly => 0,\n"
    append return_string "${indent}},\n"
    return "$return_string"
}

proc proc_get_custom_inst_slaves_string {CUSTOM_SLAVE} {
    array set custom_slave $CUSTOM_SLAVE
    set indent "$custom_slave(indent)"
    set custom_slave_name   $custom_slave(name)
    set custom_slave_type  $custom_slave(clockCycleType)
    set custom_slave_start  [ proc_num2hex $custom_slave(baseAddress) ]
    set custom_slave_span  $custom_slave(addressSpan)
    set custom_slave_width [ proc_span2width $custom_slave_span ]
    
    if { "$custom_slave_type" == "COMBINATORIAL" } {
        set custom_slave_type_europa "combo"
    } elseif { [ expr { "$custom_slave_type" == "VARIABLE" } || { "$custom_slave_type" == "MULTICYCLE" } ] } {
        set custom_slave_type_europa "multi"
    } else {
        set custom_slave_type_europa "$custom_slave_type"
    }
    
    set return_string {}
    
    append return_string "${indent}\"$custom_slave_name\" => {\n"
    append return_string "${indent}\ttype => $custom_slave_type_europa,\n"
    append return_string "${indent}\taddr_base => $custom_slave_start,\n"
    append return_string "${indent}\taddr_width => $custom_slave_width,\n"
    append return_string "${indent}},\n"
    return "$return_string"
}

proc proc_get_avalon_slave_info_string {} {

    global TCI_PREFIX
    global TCD_PREFIX  
    
    set tcim_num                        [ get_parameter_value icache_numTCIM ]
    set tcdm_num                        [ get_parameter_value dcache_numTCDM ]
    set tcim_slave_info_string ""
    set tcdm_slave_info_string ""    
    set inst_slave_info_string ""
    set data_slave_info_string ""
    
    set inst_address_map_dec [ proc_decode_address_map instSlaveMapParam ]
    foreach inst_slave $inst_address_map_dec {
        array set inst_slave_info $inst_slave
        set inst_slave_info(indent)      "\t\t\t"
        append inst_slave_info_string  [ proc_get_avalon_slaves_string [ array get inst_slave_info ] ]
    }

    set data_address_map_dec [ proc_decode_address_map dataSlaveMapParam ]
    foreach data_slave $data_address_map_dec {
        array set data_slave_info $data_slave
        set data_slave_info(indent)      "\t\t\t"
        append data_slave_info_string  [ proc_get_avalon_slaves_string [ array get data_slave_info ] ]
    }
    
    foreach i {0 1 2 3} {
        set INTF_TCD_NAME "${TCD_PREFIX}${i}"
        set tcdm_address_base [ proc_num2hex [ proc_get_lowest_start_address ${INTF_TCD_NAME}MapParam ] ]
        if { [ expr { $tcdm_address_base != "[ proc_num2hex "-1" ]" } ] } {
            set "tcdm_address_map_dec" [ proc_decode_address_map ${INTF_TCD_NAME}MapParam ]
                foreach tcdm_slave "$tcdm_address_map_dec" {
                    array set tcdm_slave_info $tcdm_slave
                    set tcdm_slave_info(indent)      "\t\t\t"
                    append tcdm_slave_info_string  [ proc_get_avalon_slaves_string [ array get tcdm_slave_info ] ]
                }
        }
    }
    
    foreach i {0 1 2 3} {
        set INTF_TCI_NAME "${TCI_PREFIX}${i}"
        set tcim_address_base [ proc_num2hex [ proc_get_lowest_start_address ${INTF_TCI_NAME}MapParam ] ]
        if { [ expr { $tcim_address_base != "[ proc_num2hex "-1" ]" } ] } {
            set "tcim_address_map_dec" [ proc_decode_address_map ${INTF_TCI_NAME}MapParam ]
                foreach tcim_slave "$tcim_address_map_dec" {
                    array set tcim_slave_info $tcim_slave
                    set tcim_slave_info(indent)      "\t\t\t"
                    append tcim_slave_info_string  [ proc_get_avalon_slaves_string [ array get tcim_slave_info ] ]
                }
        }
    }
    
    set return_string ""
    append return_string "\tavalon_slave_info => {\n"
        append return_string "\t\tavalon_instruction_slaves => {\n"
            append return_string "$inst_slave_info_string"
            append return_string "$tcim_slave_info_string"
            append return_string "\t\t},\n"
            append return_string "\t\tavalon_data_slaves => {\n"
            append return_string "$data_slave_info_string"
            append return_string "$tcdm_slave_info_string"
            append return_string "\t\t},\n"
    append return_string "\t},\n"
    return "$return_string"
}

proc proc_get_custom_inst_info_string {} {
    
    set ci_info_string ""
    set ci_ori [ proc_decode_address_map customInstSlavesSystemInfo ]
    set custom_inst_slave [ proc_decode_ci_slave $ci_ori ]
    
    #TODO: Remove this when hack get fixed
    if {[string match *name* $custom_inst_slave]} {
        foreach custom_slave $custom_inst_slave {
            array set custom_slave_info $custom_slave
            set custom_slave_info(indent)      "\t\t\t"
            append ci_info_string  [ proc_get_custom_inst_slaves_string [ array get custom_slave_info ] ]
        }
    
        set return_string ""
        append return_string "\tcustom_inst_info => {\n"
            append return_string "\t\tcustom_instructions => {\n"
            append return_string "$ci_info_string"
            append return_string "\t\t},\n"
        append return_string "\t},\n"
        return "$return_string"   
    }
}

proc proc_get_shift_rot_impl {} {
    set hardware_multiplier "[ get_parameter_value muldiv_multiplierType ]"
    set impl [ get_parameter_value impl ]
    if { "$impl" == "Tiny" } {
        return "small_le_shift"
    }
    switch $hardware_multiplier {
        "DSPBlock" {
            return "dsp_shift"
        }
        "EmbeddedMulFast" {
            return  "fast_le_shift"
        }
        "LogicElementsFast" {
            return "fast_le_shift"
        }
        "NoneSmall" {
            return "small_le_shift"
        }
        default {
            send_message error "$hardware_multiplier is not a supported Multiplier Type"
            return ""
        }
    }
}

proc proc_get_hardware_multiply_impl {} {
    set hardware_multiplier "[ get_parameter_value muldiv_multiplierType ]"
    set impl [ get_parameter_value impl ]
    if { "$impl" == "Tiny" } {
        return "no_mul"
    }
    switch $hardware_multiplier {
        "DSPBlock" {
            return "dsp_mul"
        }
        "EmbeddedMulFast" {
            return  "embedded_mul"
        }
        "LogicElementsFast" {
            return "le_mul"
        }
        "NoneSmall" {
            return "no_mul"
        }
        default {
            send_message error "$hardware_multiplier is not a supported Multiplier Type"
            return ""
        }
    }
}

proc proc_get_hardware_multiply_present {} {
    set hardware_multiplier "[ get_parameter_value muldiv_multiplierType ]"
    set impl [ get_parameter_value impl ]
    if { [ expr { "$impl" == "Tiny" } || { "$hardware_multiplier" == "NoneSmall" } ] } {
        return 0
    } else {
        return 1
    }
}

proc proc_get_setting_shadowRegisterSets {} {
    set num_shadow_reg_sets [get_parameter_value setting_shadowRegisterSets]
    set impl [get_parameter_value impl]
    if { "$impl" == "Fast" } {
        return $num_shadow_reg_sets
    } else {
        return 0
    }
}
#checked generatePTF
#TODO: export_large_RAMs & use_designware
proc proc_get_misc_info_string {} {
    set return_string ""
    set user_defined_settings ""
    set impl [ string tolower [ get_parameter_value impl ]]
    set userDefinedSettings [ get_parameter_value userDefinedSettings ]

    foreach each_user_setting [ split $userDefinedSettings ";" ] {
        regsub -all " " "$each_user_setting" "" each_user_setting
        regsub -all "=" "$each_user_setting" " => " each_user_setting
        if { "$each_user_setting" != "" } {
            append user_defined_settings "\t\t${each_user_setting},\n"
        }
    }

    append return_string "\tmisc_info => {\n"
        append return_string "\t\tbig_endian => [ proc_get_boolean_parameter setting_bigEndian ],\n"
        append return_string "\t\texport_pcb => [ proc_get_boolean_parameter setting_exportPCB ],\n"
        append return_string "\t\tshift_rot_impl => [ proc_get_shift_rot_impl ],\n"
        append return_string "\t\tnum_shadow_reg_sets => [ proc_get_setting_shadowRegisterSets],\n"
        append return_string "\t\texport_large_RAMs => [ proc_get_boolean_parameter setting_export_large_RAMs ],\n"
        append return_string "\t\texport_vectors => [ proc_get_boolean_parameter setting_exportvectors ],\n"
        #append return_string "\t\tuse_designware => 0,\n"
        append return_string "\t\tcore_type => $impl,\n"
        append return_string "\t\tCPU_Implementation =>$impl ,\n"
        append return_string "\t\tcpuid_value => [ proc_num2unsigned [ get_parameter_value cpuID ]],\n"
        append return_string "\t\tdont_overwrite_cpuid => 1,\n"
        append return_string "\t\tcpu_reset => [ proc_get_boolean_parameter cpuReset],\n"
        append return_string "\t\tregister_file_ram_type => [proc_get_europa_ram_block_type_param regfile_ramBlockType],\n"
        append return_string "$user_defined_settings"
    append return_string "\t},\n"
    return "$return_string"
}
#checked generatePTF
proc proc_get_ecc_info_string {} {
    set return_string ""
    set impl [ string tolower [ get_parameter_value impl ]]

    if {$impl == "fast"} {
        set ecc_present [ proc_get_boolean_parameter setting_ecc_present ]
        set rf_ecc_present [ proc_get_boolean_parameter setting_rf_ecc_present ]
        set ic_ecc_present [ expr {[proc_get_boolean_parameter setting_ic_ecc_present]} && {[get_parameter_value icache_size] > 0} ]
        set dc_ecc_present [ expr {[proc_get_boolean_parameter setting_dc_ecc_present]} && {[get_parameter_value dcache_size] > 0} ]
        set itcm_ecc_present [ expr {[proc_get_boolean_parameter setting_itcm_ecc_present]} && {[get_parameter_value icache_numTCIM] > 0} ]
        set dtcm_ecc_present [ expr {[proc_get_boolean_parameter setting_dtcm_ecc_present]} && {[get_parameter_value dcache_numTCDM] > 0} ]
        set mmu_ecc_present [ expr {[proc_get_boolean_parameter setting_mmu_ecc_present]} && [proc_get_mmu_present] ]
    } else {
        set ecc_present 0
        set rf_ecc_present 0
        set ic_ecc_present 0
        set dc_ecc_present 0
        set itcm_ecc_present 0
        set dtcm_ecc_present 0
        set mmu_ecc_present 0
    }
    
    append return_string "\tecc_info => {\n"
        append return_string "\t\tecc_present => $ecc_present,\n"
        append return_string "\t\trf_ecc_present   => $rf_ecc_present,\n"
        append return_string "\t\tic_ecc_present   => $ic_ecc_present,\n"
        append return_string "\t\tdc_ecc_present   => $dc_ecc_present,\n"
        append return_string "\t\titcm_ecc_present => $itcm_ecc_present,\n"
        append return_string "\t\tdtcm_ecc_present => $dtcm_ecc_present,\n"
        append return_string "\t\tmmu_ecc_present  => $mmu_ecc_present,\n"
    append return_string "\t},\n"
    return "$return_string"
}

#checked generatePTF
proc proc_get_mpu_info_string {} {
    set return_string ""
    set mpu_present [ proc_get_mpu_present ]
    if { $mpu_present } {
        set mpu_num_inst_regions [ proc_num2unsigned [ get_parameter_value mpu_numOfInstRegion]]
        set mpu_num_data_regions [ proc_num2unsigned [ get_parameter_value mpu_numOfDataRegion]]
        set mpu_min_inst_region_size_log2 [ get_parameter_value mpu_minInstRegionSize]
        set mpu_min_data_region_size_log2 [ get_parameter_value mpu_minDataRegionSize]
        set mpu_use_limit [proc_get_boolean_parameter mpu_useLimit]
    } else {
        set mpu_num_inst_regions 8
        set mpu_num_data_regions 8
        set mpu_min_inst_region_size_log2 12
        set mpu_min_data_region_size_log2 12
        set mpu_use_limit 0
    }
    append return_string "\tmpu_info => {\n"
        append return_string "\t\tmpu_present => $mpu_present,\n"
        append return_string "\t\tmpu_num_inst_regions => $mpu_num_inst_regions,\n"
        append return_string "\t\tmpu_num_data_regions => $mpu_num_data_regions,\n"
        append return_string "\t\tmpu_min_inst_region_size_log2 => $mpu_min_inst_region_size_log2,\n"
        append return_string "\t\tmpu_min_data_region_size_log2 => $mpu_min_data_region_size_log2,\n"
        append return_string "\t\tmpu_use_limit => $mpu_use_limit,\n"
    append return_string "\t},\n"
    return "$return_string"
}

#checked generatePTF
proc proc_get_mmu_info_string {} {
    set return_string ""
    set mmu_present [ proc_get_mmu_present ]

    if { $mmu_present } {
        set process_id_num_bits [get_parameter_value mmu_processIDNumBits]
        set tlb_ptr_sz [ proc_get_final_tlb_ptr_size ]
        set tlb_num_ways [get_parameter_value mmu_tlbNumWays]
        set udtlb_num_entries [get_parameter_value mmu_udtlbNumEntries]
        set uitlb_num_entries [get_parameter_value mmu_uitlbNumEntries]
    } else {
        set process_id_num_bits 0
        set tlb_ptr_sz 7
        set tlb_num_ways 16
        set udtlb_num_entries 6
        set uitlb_num_entries 4
    }

    append return_string "\tmmu_info => {\n"
        append return_string "\t\tmmu_present => $mmu_present,\n"
        append return_string "\t\tprocess_id_num_bits => $process_id_num_bits,\n"
        append return_string "\t\ttlb_ptr_sz => $tlb_ptr_sz,\n"
        append return_string "\t\ttlb_num_ways => $tlb_num_ways,\n"
        append return_string "\t\tudtlb_num_entries => $udtlb_num_entries,\n"
        append return_string "\t\tuitlb_num_entries => $uitlb_num_entries,\n"
        append return_string "\t\tmmu_ram_type => [proc_get_europa_ram_block_type_param mmu_ramBlockType],\n"
    append return_string "\t},\n"
    return "$return_string"
}

proc proc_get_eic_present {} {
    set local_interrupt_type [ get_parameter_value setting_interruptControllerType ]
    set impl [ get_parameter_value impl ]
    if { "${local_interrupt_type}" == "External" && "$impl" == "Fast" } {
        return 1
    } else {
        return 0
    }
}

#checked generatePTF
proc proc_get_interrupt_info_string {} {
    set return_string ""
    append return_string "\tinterrupt_info => {\n"
        append return_string "\t\teic_present => [ proc_get_eic_present ],\n"
        append return_string "\t\tinternal_irq_mask => [ get_parameter_value internalIrqMaskSystemInfo ],\n"
    append return_string "\t},\n"
    return "$return_string"
}

#checked generatePTF
proc proc_get_vector_info_string {} {
    set return_string ""

    append return_string "\tvector_info => {\n"
        append return_string "\t\treset_addr => [ proc_num2hex [ proc_get_reset_addr ] ],\n"
        append return_string "\t\tgeneral_exception_addr => [ proc_num2hex [ proc_get_general_exception_addr ] ],\n"
        append return_string "\t\tfast_tlb_miss_exception_addr => [ proc_num2hex [ proc_get_fast_tlb_miss_exception_addr ] ],\n"
        append return_string "\t\tbreak_addr => [ proc_num2hex [ proc_get_break_addr ] ],\n"
    append return_string "\t},\n"
    return "$return_string"
}

proc proc_get_project_info_string {} {
    set return_string ""

    set device_family_string [ string toupper "[ get_parameter_value deviceFamilyName ]" ]
    regsub -all " " "$device_family_string" "" device_family_string

    set local_asic_enabled  [ proc_get_boolean_parameter setting_asic_enabled ]
    set local_translate_on  [ get_parameter_value translate_on ]
    set local_translate_off [ get_parameter_value translate_off ]

    append return_string "\tproject_info => {\n"
        append return_string "\t\tclock_frequency        => [ get_parameter_value clockFrequency ],\n"
        append return_string "\t\tdevice_family          => $device_family_string,\n"
        append return_string "\t\thw_tcl_core            => 1,\n"
        append return_string "\t\tis_hardcopy_compatible => [ proc_bool2int [ get_parameter_value is_hardcopy_compatible ] ],\n"
        append return_string "\t\tasic_enabled           => $local_asic_enabled,\n"
        append return_string "\t\ttranslate_off          => $local_translate_off,\n"
        append return_string "\t\ttranslate_on           => $local_translate_on,\n"
    append return_string "\t},\n"
    return "$return_string"
}

proc proc_get_hardware_multiply_omits_msw {} {
    set hardware_multiplier "[ get_parameter_value muldiv_multiplierType ]"
    if { "$hardware_multiplier" == "DSPBlock" } {
        return 0
    } else {
        return 1
    }
}

proc proc_get_multiply_info_string {} {
    set return_string ""
    append return_string "\tmultiply_info => {\n"
        append return_string "\t\thardware_multiply_present => [ proc_get_hardware_multiply_present ],\n"
        append return_string "\t\thardware_multiply_omits_msw => [proc_get_hardware_multiply_omits_msw],\n"
        append return_string "\t\thardware_multiply_impl => [ proc_get_hardware_multiply_impl ],\n"
    append return_string "\t},\n"
    return "$return_string"
}

proc proc_get_hardware_divide_present {} {
    set divider_enable [proc_get_boolean_parameter muldiv_divider]
    set impl [ get_parameter_value impl ]
    if { [ expr { "$impl" == "Tiny" } || { ! $divider_enable } ] } {
        return 0
    } else {
        return 1
    }
}

proc proc_get_divide_info_string {} {
    set return_string ""
    append return_string "\tdivide_info => {\n"
        append return_string "\t\thardware_divide_present => [proc_get_hardware_divide_present],\n"
        # always fix to variable_latency
        append return_string "\t\thardware_divide_impl => variable_latency,\n"
    append return_string "\t},\n"
    return "$return_string"
}

proc proc_get_test_info_string {} {
    set ecc_present [ proc_get_boolean_parameter setting_ecc_present ]
    set impl [ string tolower [ get_parameter_value impl ]]
    if { "$impl" == "fast" && $ecc_present } {
        set ecc_sim_test_ports [proc_get_boolean_parameter setting_ecc_sim_test_ports]
    } else {
        set ecc_sim_test_ports 0
    }

    set return_string ""
    append return_string "\ttest_info => {\n"
        append return_string "\t\tactivate_model_checker => [proc_get_boolean_parameter setting_activateModelChecker],\n"
        append return_string "\t\tactivate_monitors => [proc_get_boolean_parameter setting_activateMonitors],\n"
        append return_string "\t\tactivate_trace_gui => [proc_get_boolean_parameter setting_activateTrace],\n"
        append return_string "\t\tactivate_trace_user => [proc_get_boolean_parameter setting_activateTrace_user],\n"
        append return_string "\t\tactivate_test_end_checker => [proc_get_boolean_parameter setting_activateTestEndChecker],\n"
        append return_string "\t\tactivate_ecc_sim_test_ports => $ecc_sim_test_ports,\n"
        append return_string "\t\talways_bypass_dcache => 0,\n"
        append return_string "\t\talways_encrypt => [proc_get_boolean_parameter setting_alwaysEncrypt],\n"
        append return_string "\t\tbit_31_bypass_dcache => [proc_get_boolean_parameter setting_bit31BypassDCache],\n"
        append return_string "\t\tclear_x_bits_ld_non_bypass => [proc_get_boolean_parameter setting_clearXBitsLDNonBypass],\n"
        append return_string "\t\tdebug_simgen => [proc_get_boolean_parameter setting_debugSimGen],\n"
        append return_string "\t\tfull_waveform_signals => [proc_get_boolean_parameter setting_fullWaveformSignals],\n"
        append return_string "\t\thbreak_test => [proc_get_boolean_parameter setting_HBreakTest],\n"
        append return_string "\t\thdl_sim_caches_cleared => [proc_get_boolean_parameter setting_HDLSimCachesCleared],\n"
        append return_string "\t\tperformance_counters_present => [proc_get_boolean_parameter setting_performanceCounter],\n"
        append return_string "\t\tperformance_counters_width => [proc_num2unsigned [get_parameter_value setting_perfCounterWidth]],\n"
    append return_string "\t},\n"
    return "$return_string"
}

proc proc_get_brpred_info_string {} {
    set return_string ""
    set impl [ get_parameter_value impl ]

    set setting_branchPredictionType    [ get_parameter_value setting_branchPredictionType ]
    set setting_bhtPtrSz                [ get_parameter_value setting_bhtPtrSz ]
    set setting_bhtIndexPcOnly          [ proc_get_boolean_parameter setting_bhtIndexPcOnly ]

    if { [ expr { "$impl" == "Tiny" } ] } {
        set brpred_type "Static"
        set brpred_size 8
        set brpred_pc_only 0
    } else {
        if { [ expr { "$setting_branchPredictionType" == "Automatic" } ] } {
            if { [ expr { "$impl" == "Small" } ] } {
                set brpred_type "Static"
            } else {
                set brpred_type "Dynamic"
            }
        } else {
            set brpred_type $setting_branchPredictionType
        }
        set brpred_size     $setting_bhtPtrSz
        set brpred_pc_only  $setting_bhtIndexPcOnly
    }


    append return_string "\tbrpred_info => {\n"
        append return_string "\t\tbranch_prediction_type => $brpred_type,\n"
        append return_string "\t\tbht_ptr_sz => $brpred_size,\n"
        append return_string "\t\tbht_index_pc_only => $brpred_pc_only,\n"
        append return_string "\t\tbht_ram_type => [proc_get_europa_ram_block_type_param bht_ramBlockType],\n"
    append return_string "\t},\n"
    return "$return_string"
}

proc proc_get_exception_info_string {} {
    set return_string ""
    append return_string "\texception_info => {\n"
        append return_string "\t\treserved_instructions_trap => [ proc_get_europa_illegalInstructionsTrap ],\n"
        append return_string "\t\tillegal_mem_exc => [ proc_get_europa_illegal_mem_exc ],\n"
        append return_string "\t\timprecise_illegal_mem_exc => [ proc_get_europa_imprecise_illegal_mem_exc ],\n"
        append return_string "\t\tslave_access_error_exc => [ proc_get_europa_slave_access_error_exc ],\n"
        append return_string "\t\tdivision_error_exc => [ proc_get_europa_division_error_exc ],\n"
        append return_string "\t\textra_exc_info => [ proc_get_europa_extra_exc_info ],\n"
    append return_string "\t},\n"
    return "$return_string"
}

proc proc_get_device_info_string {} {
    set ecc_present [ proc_get_boolean_parameter setting_ecc_present ]
    set impl [ string tolower [ get_parameter_value impl ]]
    if { "$impl" == "fast" && $ecc_present } {
        set mrams_present 0
    } else {
        set mrams_present [is_device_feature_exist MRAM_MEMORY]
    }
    # Always return 0 for dsp_block_support_shift
    # The new mult wrapper does not support shift mode
    set return_string ""
    append return_string "\tdevice_info => {\n"
        append return_string "\t\tdsp_block_supports_shift => 0,\n"
        append return_string "\t\taddress_stall_present => [is_device_feature_exist ADDRESS_STALL],\n"
        append return_string "\t\tmrams_present => $mrams_present,\n"
    append return_string "\t},\n"
    return "$return_string"
}

proc proc_get_europa_ram_block_type_param {param} {
    set model_ram_type [get_parameter_value $param]
    if { "$model_ram_type" == "Automatic" } {
        return "AUTO"
    } elseif { "$model_ram_type" == "MRam" } {
        return "M-RAM"
    } else {
        return $model_ram_type
    }
}


proc proc_get_dcache_info_string {} {
    set return_string ""
    set dcache_size_derived [get_parameter_value dcache_size_derived]
    set impl [get_parameter_value impl]
    append return_string "\tdcache_info => {\n"
    if { "$dcache_size_derived" == "0" || "$impl" != "Fast" } {
        append return_string "\t\tcache_has_dcache => 0,\n"
        append return_string "\t\tcache_dcache_size => 0,\n"
        append return_string "\t\tcache_dcache_line_size => 0,\n"
        append return_string "\t\tcache_dcache_bursts => 0,\n"
        append return_string "\t\tcache_dcache_tag_ram_block_type => AUTO,\n"
        append return_string "\t\tcache_dcache_ram_block_type => AUTO,\n"
        append return_string "\t\tcache_dcache_victim_buf_impl => RAM,\n"
    } else {
        append return_string "\t\tcache_has_dcache => 1,\n"
        append return_string "\t\tcache_dcache_size => [get_parameter_value dcache_size_derived],\n"
        append return_string "\t\tcache_dcache_line_size => [get_parameter_value dcache_lineSize_derived],\n"
        append return_string "\t\tcache_dcache_bursts => [proc_get_boolean_parameter dcache_bursts_derived],\n"
        append return_string "\t\tcache_dcache_tag_ram_block_type => [proc_get_europa_ram_block_type_param dcache_tagramBlockType],\n"
        append return_string "\t\tcache_dcache_ram_block_type => [proc_get_europa_ram_block_type_param dcache_ramBlockType],\n"
        append return_string "\t\tcache_dcache_victim_buf_impl => [get_parameter_value dcache_victim_buf_impl],\n"
    }
    append return_string "\t},\n"
    return "$return_string"
}


proc proc_get_icache_info_string {} {
    set return_string ""
    set icache_size [get_parameter_value icache_size]
    set impl [get_parameter_value impl]
    set burst_type [ get_parameter_value icache_burstType ]
    set icache_burst [ expr {"$burst_type" != "None"} ]

    append return_string "\ticache_info => {\n"
    if { "$icache_size" == "0" || "$impl" == "Tiny" } {
        append return_string "\t\tcache_has_icache => 0,\n"
        append return_string "\t\tcache_icache_size => 0,\n"
        append return_string "\t\tcache_icache_line_size => 0,\n"
        append return_string "\t\tcache_icache_burst_type => none,\n"
        append return_string "\t\tcache_icache_bursts => 0,\n"
        append return_string "\t\tcache_icache_tag_ram_block_type => AUTO,\n"
        append return_string "\t\tcache_icache_ram_block_type => AUTO,\n"
    } else {
        append return_string "\t\tcache_has_icache => 1,\n"
        append return_string "\t\tcache_icache_size => $icache_size,\n"
        append return_string "\t\tcache_icache_line_size => 32,\n"
        append return_string "\t\tcache_icache_burst_type => [ string tolower $burst_type ],\n"
        append return_string "\t\tcache_icache_bursts => $icache_burst,\n"
        append return_string "\t\tcache_icache_tag_ram_block_type => [proc_get_europa_ram_block_type_param icache_tagramBlockType],\n"
        append return_string "\t\tcache_icache_ram_block_type => [proc_get_europa_ram_block_type_param icache_ramBlockType],\n"
    }
    append return_string "\t},\n"
    return "$return_string"
}


proc proc_get_debug_info_string {} {
    set return_string ""
    append return_string "\tdebug_info => {\n"

    set debug_level "[ get_parameter_value debug_level ]"
    set oci_trace_addr_width [ proc_get_oci_trace_addr_width ]
    set oci_export_jtag_signals [ proc_get_boolean_parameter setting_oci_export_jtag_signals ]
    switch $debug_level {
        "NoDebug" {
            append return_string "\t\tinclude_oci => 0,\n"
            append return_string "\t\toci_num_xbrk => 0,\n"
            append return_string "\t\toci_num_dbrk => 0,\n"
            append return_string "\t\toci_dbrk_trace => 0,\n"
            append return_string "\t\toci_dbrk_pairs => 0,\n"
            append return_string "\t\toci_onchip_trace => 0,\n"
            append return_string "\t\toci_offchip_trace => 0,\n"
            append return_string "\t\toci_data_trace => 0,\n"
            append return_string "\t\tinclude_third_party_debug_port => 0,\n"
            append return_string "\t\toci_trace_addr_width => 7,\n"
            append return_string "\t\toci_export_jtag_signals => 0,\n"
            append return_string "\t\toci_mem_ram_type => AUTO,\n"
        }
        "Level1" {
            append return_string "\t\tinclude_oci => 1,\n"
            append return_string "\t\toci_num_xbrk => 0,\n"
            append return_string "\t\toci_num_dbrk => 0,\n"
            append return_string "\t\toci_dbrk_trace => 0,\n"
            append return_string "\t\toci_dbrk_pairs => 0,\n"
            append return_string "\t\toci_onchip_trace => 0,\n"
            append return_string "\t\toci_offchip_trace => 0,\n"
            append return_string "\t\toci_data_trace => 0,\n"
            append return_string "\t\tinclude_third_party_debug_port => 0,\n"
            append return_string "\t\toci_trace_addr_width => 7,\n"
            append return_string "\t\toci_export_jtag_signals => $oci_export_jtag_signals,\n"
            append return_string "\t\toci_mem_ram_type => [proc_get_europa_ram_block_type_param ocimem_ramBlockType],\n"
        }
        "Level2" {
            append return_string "\t\tinclude_oci => 1,\n"
            append return_string "\t\toci_num_xbrk => 2,\n"
            append return_string "\t\toci_num_dbrk => 2,\n"
            append return_string "\t\toci_dbrk_trace => 0,\n"
            append return_string "\t\toci_dbrk_pairs => 1,\n"
            append return_string "\t\toci_onchip_trace => 0,\n"
            append return_string "\t\toci_offchip_trace => 0,\n"
            append return_string "\t\toci_data_trace => 0,\n"
            append return_string "\t\tinclude_third_party_debug_port => 0,\n"
            append return_string "\t\toci_trace_addr_width => 7,\n"
            append return_string "\t\toci_export_jtag_signals => $oci_export_jtag_signals,\n"
            append return_string "\t\toci_mem_ram_type => [proc_get_europa_ram_block_type_param ocimem_ramBlockType],\n"
        }
        "Level3" {
            append return_string "\t\tinclude_oci => 1,\n"
            append return_string "\t\toci_num_xbrk => 2,\n"
            append return_string "\t\toci_num_dbrk => 2,\n"
            append return_string "\t\toci_dbrk_trace => 1,\n"
            append return_string "\t\toci_dbrk_pairs => 1,\n"
            append return_string "\t\toci_onchip_trace => 1,\n"
            append return_string "\t\toci_offchip_trace => 0,\n"
            append return_string "\t\toci_data_trace => 0,\n"
            append return_string "\t\tinclude_third_party_debug_port => 0,\n"
            append return_string "\t\toci_trace_addr_width => $oci_trace_addr_width,\n"
            append return_string "\t\toci_export_jtag_signals => $oci_export_jtag_signals,\n"
            append return_string "\t\toci_mem_ram_type => [proc_get_europa_ram_block_type_param ocimem_ramBlockType],\n"
        }
        "Level4" {
            append return_string "\t\tinclude_oci => 1,\n"
            append return_string "\t\toci_num_xbrk => 4,\n"
            append return_string "\t\toci_num_dbrk => 4,\n"
            append return_string "\t\toci_dbrk_trace => 1,\n"
            append return_string "\t\toci_dbrk_pairs => 1,\n"
            append return_string "\t\toci_onchip_trace => 1,\n"
            append return_string "\t\toci_offchip_trace => 1,\n"
            append return_string "\t\toci_data_trace => 1,\n"
            append return_string "\t\tinclude_third_party_debug_port => 0,\n"
            append return_string "\t\toci_trace_addr_width => $oci_trace_addr_width,\n"
            append return_string "\t\toci_export_jtag_signals => $oci_export_jtag_signals,\n"
            append return_string "\t\toci_mem_ram_type => [proc_get_europa_ram_block_type_param ocimem_ramBlockType],\n"
        }
    }


        set auto_assign [proc_get_boolean_parameter debug_assignJtagInstanceID]
        set user_jtag_inst_id [get_parameter_value debug_jtagInstanceID]
        if { !$auto_assign } {
            # sld_virtual_jtag Megafunction documentation tell me that this will be ignored if enable auto assign
            set virtual_jtag_instance_id  0
        } else {
            set virtual_jtag_instance_id $user_jtag_inst_id
        }
        
        # Avalon Debug Port present only available when debug level is at least 1 but java models allows it (bug).
        if { [ expr { "$debug_level" == "NoDebug" } ] } {
            set avalonDebugPortPresent 0
        } else {
            set avalonDebugPortPresent [proc_get_boolean_parameter setting_avalonDebugPortPresent]
        }
 	
        
        if { [ expr { "$debug_level" == "Level4" } ] } {
            set embedded_pll [proc_get_boolean_parameter debug_embeddedPLL]
        } else {
            set embedded_pll 0
        }

        append return_string "\t\tavalon_debug_port_present => $avalonDebugPortPresent,\n"
        append return_string "\t\toci_sync_depth => 2,\n"
        append return_string "\t\toci_num_pm => 0,\n"
        append return_string "\t\toci_pm_width => 32,\n"
        append return_string "\t\toci_debugreq_signals => [proc_get_boolean_parameter debug_debugReqSignals],\n"
        append return_string "\t\toci_trigger_arming => [proc_get_boolean_parameter debug_triggerArming],\n"
        append return_string "\t\toci_embedded_pll => $embedded_pll,\n"
        append return_string "\t\toci_virtual_jtag_instance_id => $virtual_jtag_instance_id,\n"
        append return_string "\t\toci_jtag_instance_id => $virtual_jtag_instance_id,\n"
        append return_string "\t\toci_assign_jtag_instance_id => $auto_assign,\n"
    append return_string "\t},\n"
    return "$return_string"
}

proc proc_get_oci_trace_addr_width {} {
    set debug_OCIOnchipTrace [get_parameter_value debug_OCIOnchipTrace]
    switch $debug_OCIOnchipTrace {
        "_128" {
            return    7
        }
        "_256" {
            return    8
        }
        "_512" {
            return    9
        }
        "_1k" {
            return    10
        }
        "_2k" {
            return    11
        }
        "_4k" {
            return    12
        }
        "_8k" {
            return    13
        }
        "_16k" {
            return    14
        }
    }
}

proc sub_generate_create_processor_config_file {output_name output_directory} {
    set processor_config_file "$output_directory/${output_name}_processor_configuration.pl"
    set processor_config      [open $processor_config_file "w"]

    puts $processor_config "# ${output_name} Processor Configuration File"
    puts $processor_config "return {"

    #checked generatePTF
    puts $processor_config "[ proc_get_avalon_master_info_string ]"
    puts $processor_config "[ proc_get_avalon_slave_info_string ]"
    puts $processor_config "[ proc_get_custom_inst_info_string ]"
    puts $processor_config "[ proc_get_misc_info_string ]"
    puts $processor_config "[ proc_get_ecc_info_string ]"
    puts $processor_config "[ proc_get_mpu_info_string ]"
    puts $processor_config "[ proc_get_mmu_info_string ]"
    puts $processor_config "[ proc_get_interrupt_info_string ]"
    puts $processor_config "[ proc_get_vector_info_string ]"
    puts $processor_config "[ proc_get_project_info_string ]"
    puts $processor_config "[ proc_get_debug_info_string ]"
    puts $processor_config "[ proc_get_icache_info_string ]"
    puts $processor_config "[ proc_get_dcache_info_string ]"
    puts $processor_config "[ proc_get_device_info_string ]"
    puts $processor_config "[ proc_get_multiply_info_string ]"
    puts $processor_config "[ proc_get_divide_info_string ]"
    puts $processor_config "[ proc_get_exception_info_string ]"
    puts $processor_config "[ proc_get_brpred_info_string ]"
    puts $processor_config "[ proc_get_test_info_string ]"

    puts $processor_config "};"

    close $processor_config
}

proc sub_generate_create_processor_rtl {output_name output_directory rtl_ext simgen} {
    global env
    # Directory
    set simulation_dir          "$output_directory"
    set processor_config_file   "$output_directory/${output_name}_processor_configuration.pl"
    set QUARTUS_ROOTDIR         "$env(QUARTUS_ROOTDIR)"
    set COMPONENT_DIR           "$QUARTUS_ROOTDIR/../ip/altera/nios2_ip/altera_nios2"
    set SOPC_BUILDER_BIN_DIR    "$QUARTUS_ROOTDIR/sopc_builder/bin"
    set CPU_LIB_DIR             "$COMPONENT_DIR/cpu_lib"
    set NIOS_LIB_DIR            "$COMPONENT_DIR/nios_lib"
    set EUROPA_DIR              "$SOPC_BUILDER_BIN_DIR/europa"
    set PERLLIB_DIR             "$SOPC_BUILDER_BIN_DIR/perl_lib"
    set NIOSII_GEN_MODULE_DIR   "$QUARTUS_ROOTDIR/../ip/altera/nios2_ip/altera_nios2"
    
    # Paths to normal and encypted perl scripts.
    set normal_perl_script "$COMPONENT_DIR/generate_rtl.pl"
    set eperl_script "$COMPONENT_DIR/generate_rtl.epl"
    
    # Initialize gen_output for message display
    set gen_output              ""
    set cpu_freq                [ get_parameter_value clockFrequency ]

    # Initialize plaintext to be always encrypted "0"
    set plainTEXTfound 0

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

    # Determine which perl executable and perl script to use.
    if { [ file isfile $normal_perl_script ] } {
        set perl_script $normal_perl_script
        set perl_bin "$QUARTUS_BINDIR/perl/bin/perl"

    } elseif { [ file isfile $eperl_script ] } {
        set perl_script $eperl_script
        set perl_bin "$QUARTUS_BINDIR/eperlcmd"

    } else {
        send_message error "Can't find Perl script $eperl_script used to generate RTL"
        return
    }

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

    # Prepare command-line used to generate CPU.
    # eperl requires '--' to separate perl args from script args
    set exec_list [ list \
        exec $perl_bin \
            -I $perl_std_libs \
            -I $EUROPA_DIR \
            -I $PERLLIB_DIR \
            -I $SOPC_BUILDER_BIN_DIR \
            -I $CPU_LIB_DIR \
            -I $NIOS_LIB_DIR \
            -I $COMPONENT_DIR \
            -I $NIOSII_GEN_MODULE_DIR \
            "--" \
            $perl_script \
            --name=$output_name \
            --dir=$output_directory \
            --quartus_dir=$QUARTUS_ROOTDIR \
            --$language \
            --config=$processor_config_file
    ]

    if { "$simgen" == "0" } {
        append exec_list     "  --do_build_sim=0  "
    } else {
        append exec_list     "  --do_build_sim=1  "
        append exec_list     "  --sim_dir=$output_directory  "
    }

    send_message Info "Starting RTL generation for module '$output_name'"
    send_message Info "  Generation command is \[$exec_list\]"

    if { [ catch { set gen_output [ eval $exec_list ] } errmsg ] } {
        foreach errmsg_string [ split $errmsg "\n" ] {
            send_message Info "$errmsg_string"
        }
        # SPR:357498
        if { $cpu_freq == 0 } {
            send_message error "Nios II generation failed, input clock is unknown or set to 0"
        }
        send_message error "Failed to generate module $output_name"
    }

    if { $gen_output != "" } {
        foreach output_string [ split $gen_output "\n" ] {
            send_message Info $output_string
        }
        set find_plaintext ""
        regexp {Creating plain-text RTL} $gen_output find_plaintext
        if { $find_plaintext == "Creating plain-text RTL" } {
            set plainTEXTfound 1
        }
    }
    send_message Info "Done RTL generation for module '$output_name'"
    return $plainTEXTfound
}

proc generate_with_plaintext {NAME rtl_ext simgen} {
    set output_directory [ add_fileset_file dummy.txt OTHER TEMP "" ]
    
    # generate
    set plainTEXTfound [generate                "$NAME" "$output_directory" "$rtl_ext" "$simgen"]
    sub_add_generated_files "$NAME" "$output_directory" "$rtl_ext" "$simgen" "$plainTEXTfound"
}

proc sub_sim_verilog {NAME} {
    set rtl_ext "v"
    set simgen  1
    
    generate_with_plaintext "$NAME" "$rtl_ext" "$simgen"

}

proc sub_sim_vhdl {NAME} {
    set rtl_ext "vhd"
    set simgen  1
    
    generate_with_plaintext "$NAME" "$rtl_ext" "$simgen"
}

proc sub_quartus_synth {NAME} {
    set rtl_ext "v"
    set simgen  0
    set output_directory [ add_fileset_file dummy.txt OTHER TEMP "" ]
    
    generate_with_plaintext "$NAME" "$rtl_ext" "$simgen"
}

proc generate {output_name output_directory rtl_ext simgen} {
    sub_generate_create_processor_config_file   "$output_name" "$output_directory"
    set plainTEXTfound [sub_generate_create_processor_rtl           "$output_name" "$output_directory" "$rtl_ext" "$simgen"]
    return $plainTEXTfound
}

proc sub_add_generated_files {NAME output_directory rtl_ext simgen plainTEXTfound} {
    # add files
    set gen_files [ glob ${output_directory}${NAME}* ]
    set always_encrypt [ get_parameter_value setting_alwaysEncrypt ]
    set impl           [ get_parameter_value impl ]
    # For Plaintext purpose
    set plaintextfound $plainTEXTfound 
    set is_encrypt     [ expr { $always_encrypt } && { $impl != "Tiny" } && { !$plaintextfound }]

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
            if { $simgen } {
                add_fileset_file "$file_name" $language PATH "$my_file"
            }
        } elseif { [ string match "*.${rtl_ext}" "$file_name" ] } {
            # checking for encryption
            if { $is_encrypt && [ string match "${NAME}.${rtl_ext}" "$file_name" ] } {
                # only Verilog files are used for synthesis
                if { [ expr { ! $simgen } || { "$language" == "VHDL" } ] } {
                    add_fileset_file "$file_name" ${language}_ENCRYPT PATH "$my_file"
                }
            } else {
                add_fileset_file "$file_name" $language PATH "$my_file"
            }
        } else {
            add_fileset_file "$file_name" OTHER PATH "$my_file"
        }
    }
}
