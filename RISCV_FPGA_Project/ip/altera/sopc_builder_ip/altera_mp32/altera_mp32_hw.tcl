#-------------------------------------------------------------------------------
# Global variables
array set mp32_infos {}
set inst_slave_names {}
set inst_master_slave_ranges {}
set data_slave_names {}
set data_master_slave_ranges {}
set CLOCK_INTF      "clock"
set I_MASTER_INTF   "instruction_master"
set D_MASTER_INTF   "data_master"
set D_IRQ_INTF      "data_master_irq"
set DEBUG_INTF      "debug_port"
set DEFAULT_RESET_PADDR "0x1fc00000"
#-------------------------------------------------------------------------------
# Self define proc
proc proc_num2sz {NUMBER} {
    return [expr int(ceil(log($NUMBER)/log(2)))]
}
proc proc_num2hex {NUMBER} {
    return [ format "0x%08x" $NUMBER ]
}
proc proc_num2unsigned {NUMBER} {
    return [ format "%u" $NUMBER ]
}
proc proc_add_parameter {NAME TYPE DEFAULT args} {
    set DESCRIPTION         "set \[$NAME\] value"
    add_parameter           $NAME  $TYPE                $DEFAULT      $DESCRIPTION
    set_parameter_property  $NAME  "GROUP"              "Others"
    if {$args != ""} then {
        set_parameter_property  $NAME  "ALLOWED_RANGES"     $args
    }
    set_parameter_property  $NAME  "VISIBLE"            0
}
proc proc_add_derived_parameter {NAME TYPE DEFAULT args} {
    proc_add_parameter $NAME $TYPE $DEFAULT
    set_parameter_property  $NAME   "DERIVED"            true
}
proc proc_set_display_group {NAME GROUP EXPERIMENTAL DISPLAY_NAME} {
    set_parameter_property  $NAME   "VISIBLE"           true
    set_parameter_property  $NAME   "GROUP"             $GROUP
    set_parameter_property  $NAME   "DISPLAY_NAME"      $DISPLAY_NAME

    # only show those settings in debug mode
    if { "$EXPERIMENTAL" == "1" } {
        set_parameter_property  $NAME   "STATUS"       "experimental"
    }
}
proc proc_set_display_format {NAME DISPLAY_HINT} {
    set_parameter_property  $NAME   "DISPLAY_HINT"      $DISPLAY_HINT
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
proc proc_set_module_embeddedsw_cmacro_assignment {name value} {
    set name_upper_case "[ string toupper $name ]"
    set embeddedsw_name "embeddedsw.CMacro.${name_upper_case}"
    set_module_assignment $embeddedsw_name "$value"
}
proc proc_set_module_embeddedsw_configuration_assignment {name value} {
    set embeddedsw_name "embeddedsw.configuration.${name}"
    set_module_assignment $embeddedsw_name "$value"
}
proc proc_set_mp32_info_group {INFO_GROUP args} {
    global mp32_infos
    foreach arg $args {
        lappend mp32_infos($INFO_GROUP) $arg
    }
}
proc proc_get_mp32_infos_string {} {
    global mp32_infos
    set info_group [ array names mp32_infos ]
    set return_string ""
    foreach infos $info_group {
        append return_string "\t$infos => {\n"
        set parameters $mp32_infos($infos) 
        foreach parameter $parameters {
            append return_string "\t\t$parameter => [ get_parameter_value $parameter ],\n"
        }
        append return_string "\t},\n"
    }
    return "$return_string"
}
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
proc proc_get_avalon_master_info_string {} {
    global I_MASTER_INTF
    global D_MASTER_INTF
    
    set instruction_master(name)        $I_MASTER_INTF
    set instruction_master(type)        "instruction"
    set instruction_master(is_tcm)      0
    set instruction_master(paddr_base)  [ get_parameter_value inst_master_paddr_base ]
    set instruction_master(paddr_top)   [ get_parameter_value inst_master_paddr_top ]
    set instruction_master(indent)      "\t\t\t"
    set data_master(name)               $D_MASTER_INTF
    set data_master(type)               "data"
    set data_master(is_tcm)             0
    set data_master(paddr_base)         [ get_parameter_value data_master_paddr_base ]
    set data_master(paddr_top)          [ get_parameter_value data_master_paddr_top ]
    set data_master(indent)             "\t\t\t"
    set return_string ""
    append return_string "\tavalon_master_info => {\n"
    append return_string "\t\tavalon_masters => {\n"
    append return_string "[ proc_get_avalon_master_string [ array get instruction_master ]]"
    append return_string "[ proc_get_avalon_master_string [ array get data_master ]]"
    append return_string "\t\t},\n"
    append return_string "\t},\n"
    return "$return_string"
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
proc proc_validate_address_range {memory_address valid_range_start valid_range_end error_msg} {
    set memory_range {}
    set memory_address_hex [ proc_num2hex $memory_address ]
    set valid_range_start_address [ proc_num2hex $valid_range_start ]
    set valid_range_end_address [ proc_num2hex $valid_range_end ]
    lappend memory_range $valid_range_start_address $memory_address_hex \
      $valid_range_end_address
    set memory_range [ lsort -ascii $memory_range ]

    if { "[ lindex $memory_range 1 ]" != "$memory_address_hex" } {
        send_message error "$error_msg. (range within $valid_range_start_address and $valid_range_end_address are acceptable)"
    }
}
proc proc_get_slave_name_containing_address {memory_address slave_map_xml} {
    set memory_address_hex [ proc_num2hex $memory_address ]
    set slave_address_map_dec [ decode_address_map $slave_map_xml ]
    foreach slave $slave_address_map_dec {
        array set slave_info $slave
        set start_hex [ proc_num2hex $slave_info(start) ]
        set end_hex [ proc_num2hex [ expr $slave_info(end) - 1 ]]

        set memory_range {}
        lappend memory_range $start_hex $memory_address_hex $end_hex

        set memory_range [ lsort -ascii $memory_range ]
        if { "[ lindex $memory_range 1 ]" == "$memory_address_hex" } {
            return "$slave_info(name)"
        }
    }
    return ""
}
proc proc_validate_address_accessibility {memory_address slave_ranges error_msg} {
    set accessible 0
    set memory_address_hex [ proc_num2hex $memory_address ]
    foreach {start_addr end_addr} $slave_ranges {
        set memory_range {}
        lappend memory_range [ proc_num2hex $start_addr ] $memory_address_hex \
          [ proc_num2hex $end_addr ]
        set memory_range [ lsort -ascii $memory_range ]

        if { "[ lindex $memory_range 1 ]" == "$memory_address_hex" } {
            set accessible 1
            break
        }
    }
    if { "$accessible" == "0" } {
        send_message error "$error_msg. (Please ensure a memory device containing address $memory_address_hex is connected to the instruction_master)"
    }
}
proc proc_validate_divisibility {dividend divisor dividend_name divisor_name} {
    if { [ expr $dividend % $divisor ] } {
        send_message error "Number of $dividend_name must be divisible by number of $divisor_name"
    }
}

#-------------------------------------------------------------------------------
# Module
set_module_property NAME "altera_mp32"
set_module_property DISPLAY_NAME "Altera MP32 Processor"
set_module_property DESCRIPTION "MIPS32 Release 2 processor"
set_module_property AUTHOR "Altera Corporation"
set_module_property DATASHEET_URL "http://www.altera.com"
set_module_property GROUP "Processors"
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
#set_module_property GENERATION_CALLBACK generate
#set_module_property _PREVIEW_GENERATE_VERILOG_SIMULATION_CALLBACK generate
set_module_property VALIDATION_CALLBACK validate
set_module_property ELABORATION_CALLBACK elaborate
set_module_property SIMULATION_MODEL_IN_VHDL true

add_fileset quartus_synth   QUARTUS_SYNTH   sub_quartus_synth
add_fileset sim_verilog     SIM_VERILOG     sub_sim_verilog
add_fileset sim_vhdl        SIM_VHDL        sub_sim_vhdl

#-------------------------------------------------------------------------------
# Parameter
# Invisible by default
#####################
# PROJECT #
#####################
proc_add_parameter          device_family_name               STRING     "STRATIXII"
proc_add_parameter          device_features                  STRING     ""
proc_add_derived_parameter  device_family                    STRING     "STRATIXII"
proc_add_derived_parameter  clock_frequency                  INTEGER    "50000000"

#################
# MISCELLANEOUS #
#################
proc_add_parameter          ebase_cpu_num                    INTEGER     "0"          "0:1023"
proc_add_parameter          debug_port_present               INTEGER     "0"
proc_add_parameter          soft_reset_present               INTEGER     "0"
proc_add_parameter          nmi_present                      INTEGER     "0"
proc_add_parameter          big_endian                       INTEGER     "0"          "0:Little" "1:Big"
proc_add_parameter          be8                              INTEGER     "0"          
proc_add_parameter          export_pcb                       INTEGER     "0"
proc_add_derived_parameter  shift_rot_impl                   STRING      "dsp_shift"  "dsp_shift" "fast_le_shift"
proc_add_parameter          dsp_block_has_pipeline_reg       INTEGER     "0"          "0:Latency-optimized" "1:Frequency-optimized"
proc_add_parameter          num_shadow_reg_sets              INTEGER     "0"          0 1 2 3 4 5 6 7 8 9 10 11 12 13 14

##############
# INTERRUPTS #
##############
proc_add_parameter          timer_ip_num                     INTEGER    "7"          2 3 4 5 6 7
proc_add_parameter          eic_present                      INTEGER    "0"

#######
# MMU #
#######
proc_add_parameter          mmu_present                      INTEGER    "1"
proc_add_parameter          tlb_present                      INTEGER    "1"          "0:FMT" "1:TLB"
proc_add_parameter          tlb_num_entries                  INTEGER    "30"         16 30 32 60 64
proc_add_parameter          tlb_num_banks                    INTEGER    "3"         1 2 3 4 6 8 10 16
proc_add_parameter          udtlb_num_entries                INTEGER    "6"          4 6 8
proc_add_parameter          uitlb_num_entries                INTEGER    "4"          4 6 8
proc_add_derived_parameter  tlb_ptr_sz                       INTEGER    "4"

###########
# VECTORS #
###########
proc_add_parameter          reset_slave                      STRING    "None"
proc_add_parameter          reset_offset                     INTEGER   "0x0"
proc_add_parameter          debug_slave                      STRING    "None"
proc_add_derived_parameter  reset_paddr                      STRING    $DEFAULT_RESET_PADDR
proc_add_derived_parameter  debug_paddr                      STRING    "0x0"

#####################
# INSTRUCTION CACHE #
#####################
proc_add_parameter          cache_has_icache                 INTEGER    "1"

# Allowed ranges set in validate because range is a function of test mode.
proc_add_parameter          cache_icache_size                INTEGER    "16384"

proc_add_parameter          cache_icache_line_size           INTEGER    "32"         16 32
proc_add_parameter          cache_icache_ram_block_type      STRING     "AUTO"       "AUTO" "M9K" "M144K"
proc_add_parameter          cache_icache_burst_enable        INTEGER    "0"
proc_add_derived_parameter  cache_icache_burst_type          STRING     "none"       "none" "sequential"
proc_add_derived_parameter  icache_line_size_log2            INTEGER    "5"

##############
# DATA CACHE #
##############
proc_add_parameter          cache_has_dcache                 INTEGER    "1"

# Allowed ranges set in validate because range is a function of test mode.
proc_add_parameter          cache_dcache_size                INTEGER    "16384"

proc_add_parameter          cache_dcache_line_size           INTEGER    "32"         16 32
proc_add_parameter          cache_dcache_bursts              INTEGER    "0"
proc_add_parameter          cache_dcache_ram_block_type      STRING     "AUTO"       "AUTO" "M9K" "M144K"
proc_add_derived_parameter  dcache_line_size_log2            INTEGER    "5"

############
# MULTIPLY #
############
proc_add_derived_parameter  hardware_multiply_impl           STRING     "dsp_mul"    "dsp_mul" "embedded_mul"

##########
# DIVIDE #
##########
proc_add_parameter          hardware_divide_present          INTEGER    "1"

##########
# DEVICE #
##########
proc_add_parameter          dsp_block_supports_shift         INTEGER    "0"
proc_add_parameter          address_stall_present            INTEGER    "0"
proc_add_parameter          mrams_present                    INTEGER    "0"

#####################
# BRANCH PREDICTION #
#####################
proc_add_parameter          branch_prediction_type           STRING     "Dynamic"   "Static" "Dynamic"
proc_add_parameter          bht_ptr_sz                       INTEGER    "12"         "8:256 Entries" "9:512 Entries" "10:1024 Entries" "11:2048 Entries" "12:4096 Entries"

#################
# INTERNAL TEST #
#################
proc_add_parameter          altera_internal_test             INTEGER    "0"
proc_add_parameter          activate_model_checker           INTEGER    "0"
proc_add_parameter          activate_monitors                INTEGER    "1"
proc_add_parameter          activate_trace                   INTEGER    "1"
proc_add_parameter          activate_test_end_checker        INTEGER    "1"
proc_add_parameter          always_bypass_dcache             INTEGER    "0"
proc_add_parameter          always_encrypt                   INTEGER    "1"
proc_add_parameter          bit_31_bypass_dcache             INTEGER    "1"
proc_add_parameter          clear_x_bits_ld_non_bypass       INTEGER    "1"
proc_add_parameter          debug_simgen                     INTEGER    "0"
proc_add_parameter          full_waveform_signals            INTEGER    "1"
proc_add_parameter          hdl_sim_caches_cleared           INTEGER    "1"
proc_add_parameter          performance_counters_present     INTEGER    "0"
proc_add_parameter          performance_counters_width       INTEGER    "32"         32

#####################
# OTHERS #
#####################
proc_add_derived_parameter  inst_addr_width                  INTEGER    "0x0"
proc_add_derived_parameter  data_addr_width                  INTEGER    "0x0"
proc_add_derived_parameter  inst_slave_map_param             STRING     ""
proc_add_derived_parameter  data_slave_map_param             STRING     ""
proc_add_derived_parameter  inst_master_paddr_base           STRING     "0x0"
proc_add_derived_parameter  inst_master_paddr_top            STRING     "0x0"
proc_add_derived_parameter  data_master_paddr_base           STRING     "0x0"
proc_add_derived_parameter  data_master_paddr_top            STRING     "0x0"
proc_add_derived_parameter  cpu_freq                         INTEGER    "50000000"

#-------------------------------------------------------------------------------
set MAIN        "Main"
set CACHE       "Caches and Memory Interfaces"
set ADVANCED    "Advanced Features"
set MMU         "MMU Settings"
set INTERNAL    "Internal Test"

#
# Main
#
proc_set_display_group  debug_port_present              $MAIN    0   "Debug Port"
proc_set_display_group  debug_slave                     $MAIN    0   "Debug Slave"

#
# Caches and Memory Interfaces
#
proc_set_display_group  cache_icache_size               $CACHE    0   "Instruction Cache Size"
proc_set_display_group  cache_icache_ram_block_type     $CACHE    1   "Instruction Cache RAM Type"
#proc_set_display_group  cache_icache_burst_enable       $CACHE    0   "Instruction Master Enable Bursts"
proc_set_display_group  cache_dcache_size               $CACHE    0   "Data Cache Size"
proc_set_display_group  cache_dcache_ram_block_type     $CACHE    1   "Data Cache RAM Type"
#proc_set_display_group  cache_dcache_bursts            $CACHE    0   "Data Master Enable Bursts"

#
# Advanced Features
#
proc_set_display_group  big_endian                      $ADVANCED   0   "Endianness"
proc_set_display_group  ebase_cpu_num                   $ADVANCED   0   "CPUNum Value in COP0 EBASE Register"
proc_set_display_group  timer_ip_num                    $ADVANCED   0   "Internal Timer IRQ Number"
proc_set_display_group  reset_slave                     $ADVANCED   0   "Reset Slave"
proc_set_display_group  reset_offset                    $ADVANCED   0   "Reset Offset From Reset Slave Base Address"
proc_set_display_group  bht_ptr_sz                      $ADVANCED   1   "BHT Entries"
proc_set_display_group  dsp_block_has_pipeline_reg      $ADVANCED   1   "DSP Block Configuration"

#
# MMU Settings
#
proc_set_display_group  tlb_present                     $MMU        1   "MMU Type"
proc_set_display_group  tlb_num_entries                 $MMU        1   "TLB Entries"
proc_set_display_group  tlb_num_banks                   $MMU        1   "TLB Banks"
proc_set_display_group  udtlb_num_entries               $MMU        1   "Micro DTLB Entries"
proc_set_display_group  uitlb_num_entries               $MMU        1   "Micro ITLB Entries"

#
# Internal Test
#

proc_set_display_group  altera_internal_test            $INTERNAL   1   "Enable Altera Internal Test Mode"
proc_set_display_group  always_encrypt                  $INTERNAL   1   "Always Encrypt"
proc_set_display_group  activate_monitors               $INTERNAL   1   "Activate RTL Monitors"
proc_set_display_group  activate_test_end_checker       $INTERNAL   1   "Activate RTL Test-end Checker"
proc_set_display_group  activate_trace                  $INTERNAL   1   "Activate RTL Trace"
proc_set_display_group  hdl_sim_caches_cleared          $INTERNAL   1   "RTL Simulation Caches Cleared"
proc_set_display_group  debug_simgen                    $INTERNAL   1   "Debug Simgen"

#-------------------------------------------------------------------------------
# Set Display Format in GUI
proc_set_display_format     altera_internal_test                    "boolean"
proc_set_display_format     activate_model_checker                  "boolean"
proc_set_display_format     activate_monitors                       "boolean"
proc_set_display_format     activate_test_end_checker               "boolean"
proc_set_display_format     activate_trace                          "boolean"
proc_set_display_format     address_stall_present                   "boolean"
proc_set_display_format     always_bypass_dcache                    "boolean"
proc_set_display_format     always_encrypt                          "boolean"
proc_set_display_format     bit_31_bypass_dcache                    "boolean"
proc_set_display_format     cache_dcache_bursts                     "boolean"
proc_set_display_format     cache_icache_burst_enable               "boolean"
proc_set_display_format     cache_has_dcache                        "boolean"
proc_set_display_format     cache_has_icache                        "boolean"
proc_set_display_format     clear_x_bits_ld_non_bypass              "boolean"
proc_set_display_format     debug_port_present                      "boolean"
proc_set_display_format     debug_simgen                            "boolean"
proc_set_display_format     dsp_block_supports_shift                "boolean"
proc_set_display_format     eic_present                             "boolean"
proc_set_display_format     export_pcb                              "boolean"
proc_set_display_format     full_waveform_signals                   "boolean"
proc_set_display_format     hardware_divide_present                 "boolean"
proc_set_display_format     hdl_sim_caches_cleared                  "boolean"
proc_set_display_format     mmu_present                             "boolean"
proc_set_display_format     mrams_present                           "boolean"
proc_set_display_format     nmi_present                             "boolean"
proc_set_display_format     performance_counters_present            "boolean"
proc_set_display_format     soft_reset_present                      "boolean"
proc_set_display_format     reset_offset                            "hexadecimal"

#-------------------------------------------------------------------------------
# Setup mp32 RTL Configuration Parameter Group
proc_set_mp32_info_group  "project_info"  clock_frequency \
                                            device_family

proc_set_mp32_info_group  "misc_info"     ebase_cpu_num \
                                            debug_port_present \
                                            soft_reset_present \
                                            nmi_present \
                                            big_endian \
                                            be8 \
                                            export_pcb \
                                            shift_rot_impl \
                                            dsp_block_has_pipeline_reg \
                                            num_shadow_reg_sets

proc_set_mp32_info_group  "interrupt_info" timer_ip_num \
                                            eic_present

proc_set_mp32_info_group  "mmu_info"      mmu_present \
                                            tlb_present \
                                            tlb_num_entries \
                                            tlb_num_banks \
                                            udtlb_num_entries \
                                            uitlb_num_entries

proc_set_mp32_info_group  "vector_info"   reset_paddr \
                                            debug_paddr

proc_set_mp32_info_group  "icache_info"   cache_has_icache \
                                            cache_icache_size \
                                            cache_icache_line_size \
                                            cache_icache_burst_type \
                                            cache_icache_ram_block_type

proc_set_mp32_info_group  "dcache_info"   cache_has_dcache \
                                            cache_dcache_size \
                                            cache_dcache_line_size \
                                            cache_dcache_bursts \
                                            cache_dcache_ram_block_type

proc_set_mp32_info_group  "multiply_info" hardware_multiply_impl

proc_set_mp32_info_group  "divide_info"   hardware_divide_present

proc_set_mp32_info_group  "device_info"   dsp_block_supports_shift \
                                            address_stall_present \
                                            mrams_present

proc_set_mp32_info_group  "brpred_info"   branch_prediction_type \
                                            bht_ptr_sz

proc_set_mp32_info_group  "test_info"     activate_model_checker \
                                            activate_monitors \
                                            activate_trace \
                                            activate_test_end_checker \
                                            always_bypass_dcache \
                                            always_encrypt \
                                            bit_31_bypass_dcache \
                                            clear_x_bits_ld_non_bypass \
                                            debug_simgen \
                                            full_waveform_signals \
                                            hdl_sim_caches_cleared \
                                            performance_counters_present \
                                            performance_counters_width

#-------------------------------------------------------------------------------
# SYSTEM_INFO
set clock_interface_clock_rate                  [ list CLOCK_RATE $CLOCK_INTF ]
set instruction_master_max_slave_data_width     [ list ADDRESS_WIDTH $I_MASTER_INTF ]
set data_master_max_slave_data_width            [ list ADDRESS_WIDTH $D_MASTER_INTF ]
set instruction_master_slave_map                [ list ADDRESS_MAP $I_MASTER_INTF ]
set data_master_slave_map                       [ list ADDRESS_MAP $D_MASTER_INTF ]

set_parameter_property  cpu_freq                system_info $clock_interface_clock_rate
set_parameter_property  inst_addr_width         system_info $instruction_master_max_slave_data_width
set_parameter_property  data_addr_width         system_info $data_master_max_slave_data_width
set_parameter_property  inst_slave_map_param    system_info $instruction_master_slave_map
set_parameter_property  data_slave_map_param    system_info $data_master_slave_map

set_parameter_property  device_family_name      system_info {DEVICE_FAMILY}
set_parameter_property  device_features         system_info {DEVICE_FEATURES}

#-------------------------------------------------------------------------------
# Module Interface
#-----------------
# Clock Interface
#-----------------
add_interface           $CLOCK_INTF     "clock"     "sink"
add_interface_port      $CLOCK_INTF     "clk"       "clk"       "input"     1
add_interface_port      $CLOCK_INTF     "reset_n"   "reset_n"   "input"     1

#--------------------
# I-Master Interface
#--------------------
add_interface           $I_MASTER_INTF   "avalon"            "master"            $CLOCK_INTF
set_interface_property  $I_MASTER_INTF   "burstOnBurstBoundariesOnly"           "false"
set_interface_property  $I_MASTER_INTF   "linewrapBursts"                       "true"
set_interface_property  $I_MASTER_INTF   "doStreamReads"                        "false"
set_interface_property  $I_MASTER_INTF   "doStreamWrites"                       "false"
set_interface_property  $I_MASTER_INTF   "addressGroup"                         "1"
add_interface_port      $I_MASTER_INTF  "i_address"         "address"           "output"    1
add_interface_port      $I_MASTER_INTF  "i_read"            "read"              "output"    1
add_interface_port      $I_MASTER_INTF  "i_readdata"        "readdata"          "input"     32
add_interface_port      $I_MASTER_INTF  "i_readdatavalid"   "readdatavalid"     "input"     1
add_interface_port      $I_MASTER_INTF  "i_waitrequest"     "waitrequest"       "input"     1

#--------------------
# D-Master Interface
#--------------------
add_interface           $D_MASTER_INTF   "avalon"            "master"            $CLOCK_INTF
set_interface_property  $D_MASTER_INTF   "burstOnBurstBoundariesOnly"           "false"
set_interface_property  $D_MASTER_INTF   "linewrapBursts"                       "false"
set_interface_property  $D_MASTER_INTF   "doStreamReads"                        "false"
set_interface_property  $D_MASTER_INTF   "doStreamWrites"                       "false"
set_interface_property  $D_MASTER_INTF   "addressGroup"                         "1"
add_interface_port      $D_MASTER_INTF  "d_address"         "address"           "output"    32
add_interface_port      $D_MASTER_INTF  "d_byteenable"       "byteenable"       "output"    4
add_interface_port      $D_MASTER_INTF  "d_read"            "read"              "output"    1
add_interface_port      $D_MASTER_INTF  "d_readdata"        "readdata"          "input"     32
add_interface_port      $D_MASTER_INTF  "d_readdatavalid"   "readdatavalid"     "input"     1
add_interface_port      $D_MASTER_INTF  "d_waitrequest"     "waitrequest"       "input"     1
add_interface_port      $D_MASTER_INTF  "d_write"           "write"             "output"    1
add_interface_port      $D_MASTER_INTF  "d_writedata"       "writedata"         "output"    32

#---------------
# IRQ Interface
#---------------
add_interface           $D_IRQ_INTF     "interrupt"         "receiver"          $CLOCK_INTF
add_interface_port      $D_IRQ_INTF     "d_irq"             "irq"               "input"     6
set_interface_property  $D_IRQ_INTF     "irqScheme"                             "individualRequests"
set_interface_property  $D_IRQ_INTF     "associatedAddressablePoint"            $D_MASTER_INTF

#-------------------------------------------------------------------------------
# Callback
proc sub_validate_update_parameterization_gui {} {
    # disable reset offset parameter if no reset slave is selected
    if { "[ get_parameter_value reset_slave ]" != "None" } {
        proc_set_enable_visible_parameter "reset_offset" "enable"
    } else {
        proc_set_enable_visible_parameter "reset_offset" "disable"
    }

    # disable debug slave if debug port is disabled
    if { [ get_parameter_value debug_port_present ] } {
        proc_set_enable_visible_parameter "debug_slave" "enable"
    } else {
        proc_set_enable_visible_parameter "debug_slave" "disable"
    }

    # disable tlb setting if mmu is not enabled or TLB is not present
    if { [ get_parameter_value mmu_present ] } {
        proc_set_enable_visible_parameter "tlb_present"         "enable"
        if { [ get_parameter_value tlb_present ] } {
            proc_set_enable_visible_parameter "tlb_num_entries"     "enable"
            proc_set_enable_visible_parameter "tlb_num_banks"       "enable"
            proc_set_enable_visible_parameter "udtlb_num_entries"   "enable"
            proc_set_enable_visible_parameter "uitlb_num_entries"   "enable"
        } else {
            proc_set_enable_visible_parameter "tlb_num_entries"     "disable"
            proc_set_enable_visible_parameter "tlb_num_banks"       "disable"
            proc_set_enable_visible_parameter "udtlb_num_entries"   "disable"
            proc_set_enable_visible_parameter "uitlb_num_entries"   "disable"
        }
    } else {
        proc_set_enable_visible_parameter "tlb_present"         "disable"
        proc_set_enable_visible_parameter "tlb_num_entries"     "disable"
        proc_set_enable_visible_parameter "tlb_num_banks"       "disable"
        proc_set_enable_visible_parameter "udtlb_num_entries"   "disable"
        proc_set_enable_visible_parameter "uitlb_num_entries"   "disable"
    }

    if { [ get_parameter_value altera_internal_test ] } {
        set_parameter_property  cache_icache_size "ALLOWED_RANGES" { "512:512 bytes" "1024:1 Kbytes" "2048:2 Kbytes" "4096:4 Kbytes" "8192:8 Kbytes" "16384:16 Kbytes" "32768:32 Kbytes" "65536:64 Kbytes" }
        set_parameter_property  cache_dcache_size "ALLOWED_RANGES" { "512:512 bytes" "1024:1 Kbytes" "2048:2 Kbytes" "4096:4 Kbytes" "8192:8 Kbytes" "16384:16 Kbytes" "32768:32 Kbytes" "65536:64 Kbytes" }
    } else {
        set_parameter_property  cache_icache_size "ALLOWED_RANGES" { "4096:4 Kbytes" "8192:8 Kbytes" "16384:16 Kbytes" "32768:32 Kbytes" "65536:64 Kbytes" }
        set_parameter_property  cache_dcache_size "ALLOWED_RANGES" { "4096:4 Kbytes" "8192:8 Kbytes" "16384:16 Kbytes" "32768:32 Kbytes" "65536:64 Kbytes" }
    }
}
proc sub_validate_update_mp32_info_parameters {} {
    set_parameter_value  clock_frequency [ get_parameter_value cpu_freq ]

    set device_family_string [ string toupper "[ get_parameter_value device_family_name ]" ]
    regsub -all " " "$device_family_string" "" device_family_string
    set_parameter_value  device_family $device_family_string

    set_parameter_value  tlb_ptr_sz [ proc_num2sz [ get_parameter_value tlb_num_entries ] ]
    set_parameter_value  icache_line_size_log2 [ proc_num2sz [ get_parameter_value cache_icache_line_size ] ]
    set_parameter_value  dcache_line_size_log2 [ proc_num2sz [ get_parameter_value cache_dcache_line_size ] ]

    if { [ get_parameter_value cache_icache_burst_enable ] } {
        set_parameter_value  cache_icache_burst_type "sequential"
    } else {
        set_parameter_value  cache_icache_burst_type "none"
    }
    # select the correct multiplier and shifter implementation depending
    # on the device family
    array set device_features2 [get_parameter_value device_features]
    set device_has_dsp $device_features2(DSP)
    if {$device_has_dsp == 1} {
      set_parameter_value shift_rot_impl "dsp_shift"
      set_parameter_value hardware_multiply_impl "dsp_mul"
    } else {
      set_parameter_value shift_rot_impl "fast_le_shift"
      set_parameter_value hardware_multiply_impl "embedded_mul"
    }
}
proc sub_validate_update_master_slave_infos {} {
    # Keep an updated copy of processor slaves information
    # Sorting of the memory address is done via hex string sorting
    # this is due to that lsort -integer comparison is using signed integer
    global inst_slave_address_map_dec
    global data_slave_address_map_dec
    global inst_slave_names
    global inst_master_slave_ranges
    global data_slave_names
    global data_master_slave_ranges
    set inst_slave_address_map_xml [ get_parameter_value inst_slave_map_param ]
    set data_slave_address_map_xml [ get_parameter_value data_slave_map_param ]
    set inst_slave_names [ list "None" ]
    set data_slave_names [ list "None" ]

    if { $inst_slave_address_map_xml != "" } then {
        set inst_slave_address_map_dec [ decode_address_map $inst_slave_address_map_xml ]
        foreach inst_slave $inst_slave_address_map_dec {
            array set inst_slave_info $inst_slave
            lappend inst_slave_names "$inst_slave_info(name)"
            lappend inst_master_paddr_ranges [ proc_num2hex $inst_slave_info(start) ] [ proc_num2hex [ expr $inst_slave_info(end) - 1 ]]

            if { "[ get_parameter_value reset_slave ]" == "$inst_slave_info(name)" } {
                set_parameter_value reset_paddr [ proc_num2hex [ expr $inst_slave_info(start) + [ get_parameter_value reset_offset ]]]
            }
            if { "[ get_parameter_value debug_slave ]" == "$inst_slave_info(name)" } {
                set_parameter_value debug_paddr [ proc_num2hex $inst_slave_info(start) ]
            }
        }
        set inst_master_slave_ranges $inst_master_paddr_ranges
        set inst_master_paddr_ranges [ lsort -ascii $inst_master_paddr_ranges ]
        set_parameter_value inst_master_paddr_base [ proc_num2unsigned [ lindex $inst_master_paddr_ranges 0 ]]
        set_parameter_value inst_master_paddr_top [ proc_num2unsigned [ lindex $inst_master_paddr_ranges [ expr [ llength $inst_master_paddr_ranges ] -1 ]]]

        set_parameter_property  reset_slave  "ALLOWED_RANGES"     "$inst_slave_names"
        set_parameter_property  debug_slave  "ALLOWED_RANGES"     "$inst_slave_names"
    }

    if { $data_slave_address_map_xml != "" } then {
        set data_slave_address_map_dec [ decode_address_map $data_slave_address_map_xml ]
        foreach data_slave $data_slave_address_map_dec {
            array set data_slave_info $data_slave
            lappend data_slave_names "$data_slave_info(name)"
            lappend data_master_paddr_ranges [ proc_num2hex $data_slave_info(start) ] [ proc_num2hex [ expr $data_slave_info(end) -1 ]]
        }
        set data_master_slave_ranges $data_master_paddr_ranges
        set data_master_paddr_ranges [ lsort -ascii $data_master_paddr_ranges ]
        set_parameter_value data_master_paddr_base [ proc_num2unsigned [ lindex $data_master_paddr_ranges 0 ]]
        set_parameter_value data_master_paddr_top [ proc_num2unsigned [ lindex $data_master_paddr_ranges [ expr [ llength $data_master_paddr_ranges ] -1 ]]]
    }
}
proc sub_validate_check_module {} {
    global DEFAULT_RESET_PADDR
    global I_MASTER_INTF
    global D_MASTER_INTF
    global inst_slave_names
    global inst_master_slave_ranges
    global data_slave_names
    global data_master_slave_ranges
    set reset_slave [ get_parameter_value reset_slave ]
    set debug_slave [ get_parameter_value debug_slave ]
    set word_alignment_mask "0x00000003"
    set dseg_alignment_mask "0x001fffff"
    set uncached_address_range_start "0x00000000"
    set uncached_address_range_end "0x1fffffff"

    # validate that reset address is chosen or use the default.
    if { $reset_slave == "None" } {
        send_message info "Reset physical address is $DEFAULT_RESET_PADDR"
        set_parameter_value reset_paddr "$DEFAULT_RESET_PADDR"

        # validate that reset address must be accessible for instruction master
        proc_validate_address_accessibility [ get_parameter_value reset_paddr ] \
          $inst_master_slave_ranges "Reset address is not accessible from $I_MASTER_INTF"

        # validate that reset address must be accessible for data master
        proc_validate_address_accessibility [ get_parameter_value reset_paddr ] \
          $data_master_slave_ranges "Reset address is not accessible from $D_MASTER_INTF"

        # Convert default reset address to name of associated slave.
        # Can use either instruction or data master because it must be connected to both.
        set tmp_reset_slave [ proc_get_slave_name_containing_address $DEFAULT_RESET_PADDR [ get_parameter_value inst_slave_map_param ]]
        if { $tmp_reset_slave == "" } {
            send_message error "Can't find reset slave associated with default reset physical address $DEFAULT_RESET_PADDR"
        } else {
            proc_set_module_embeddedsw_configuration_assignment "reset_slave" $tmp_reset_slave
        }
    } else {
        # validate that reset slave is connected to the instruction master
        if { [ lsearch -exact $inst_slave_names $reset_slave ] == -1 } {
            send_message error "Reset slave $reset_slave is not connected to $I_MASTER_INTF."
        }

        # validate that reset slave is connected to the data master
        if { [ lsearch -exact $data_slave_names $reset_slave ] == -1 } {
            send_message error "Reset slave $reset_slave is not connected to $D_MASTER_INTF."
        }

        # validate that reset slave offset must be word aligned
        proc_validate_address_alignment [ get_parameter_value reset_offset ] \
          $word_alignment_mask "Reset offset must be word aligned"

        # Just use name of associated slave.
        proc_set_module_embeddedsw_configuration_assignment "reset_slave" $reset_slave
    }

    # validate that reset vector must be within uncached memory range
    proc_validate_address_range [ get_parameter_value reset_paddr ] \
      $uncached_address_range_start $uncached_address_range_end \
      "Reset vector must be within uncached memory range"

    if { [ get_parameter_value debug_port_present ] } {
        # validate that debug must be specified if debug port is enabled
        if {"[ get_parameter_value debug_slave ]" == "None" } {
            send_message error "Instantiate an EJTAG component, connect it to $I_MASTER_INTF and $D_MASTER_INTF, and configure the Debug Slave."
        } else {
            # validate that debug slave is connected to the instruction master
            if { [ lsearch -exact $inst_slave_names $debug_slave ] == -1 } {
                send_message error "EJTAG component Avalon slave $debug_slave is not connected to $I_MASTER_INTF."
            }

            # validate that debug slave is connected to the data master
            if { [ lsearch -exact $data_slave_names $debug_slave ] == -1 } {
                send_message error "EJTAG component Avalon slave $debug_slave is not connected to $D_MASTER_INTF."
            }

            # validate that debug slave address must be 2 Mbyte aligned
            proc_validate_address_alignment [ get_parameter_value debug_paddr ] \
              $dseg_alignment_mask "EJTAG component Avalon slave $debug_slave address isn't 2 MByte-aligned"
        }
    }

    if { [ get_parameter_value mmu_present ] } {
        if { [ get_parameter_value tlb_present ] } {
            # validate that number of TLB entries must be divisible by number of TLB banks
            proc_validate_divisibility [ get_parameter_value tlb_num_entries ] \
                [ get_parameter_value tlb_num_banks ] "TLB entries" "TLB banks"
        }
    }
}
proc sub_validate_update_module_embeddedsw_cmacros {} {
    #
    # Create all embeddedsw assignments in the CMacros namespace.
    #
    proc_set_module_embeddedsw_cmacro_assignment cpu_freq "[ get_parameter_value cpu_freq ]"
    proc_set_module_embeddedsw_cmacro_assignment reset_paddr "[ get_parameter_value reset_paddr ]"
    proc_set_module_embeddedsw_cmacro_assignment debug_paddr "[ get_parameter_value debug_paddr ]"
    proc_set_module_embeddedsw_cmacro_assignment ebase_cpu_num "[ get_parameter_value ebase_cpu_num ]"
    proc_set_module_embeddedsw_cmacro_assignment num_shadow_reg_sets "[ get_parameter_value num_shadow_reg_sets ]"
    proc_set_module_embeddedsw_cmacro_assignment timer_ip_num "[ get_parameter_value timer_ip_num ]"

    # Cache stuff
    if { [ get_parameter_value cache_has_icache ] } {
        proc_set_module_embeddedsw_cmacro_assignment icache_size "[ get_parameter_value cache_icache_size ]"
        proc_set_module_embeddedsw_cmacro_assignment icache_line_size "[ get_parameter_value cache_icache_line_size ]"
        proc_set_module_embeddedsw_cmacro_assignment icache_line_size_log2 "[ get_parameter_value icache_line_size_log2 ]"
    } else {
        proc_set_module_embeddedsw_cmacro_assignment icache_size "[ get_parameter_value 0 ]"
        proc_set_module_embeddedsw_cmacro_assignment icache_line_size "[ get_parameter_value 0 ]"
        proc_set_module_embeddedsw_cmacro_assignment icache_line_size_log2 "[ get_parameter_value 0 ]"
    }
    if { [ get_parameter_value cache_has_dcache ] } {
        proc_set_module_embeddedsw_cmacro_assignment dcache_size "[ get_parameter_value cache_dcache_size ]"
        proc_set_module_embeddedsw_cmacro_assignment dcache_line_size "[ get_parameter_value cache_dcache_line_size ]"
        proc_set_module_embeddedsw_cmacro_assignment dcache_line_size_log2 "[ get_parameter_value dcache_line_size_log2 ]"
    } else {
        proc_set_module_embeddedsw_cmacro_assignment dcache_size "[ get_parameter_value 0 ]"
        proc_set_module_embeddedsw_cmacro_assignment dcache_line_size "[ get_parameter_value 0 ]"
        proc_set_module_embeddedsw_cmacro_assignment dcache_line_size_log2 "[ get_parameter_value 0 ]"
    }

    # Create two versions of booleans.
    #   - "_present" versions which are only provided when the boolean is 1.
    #       The value of the CMacro is the empty string.
    #   - The versions without a suffix are always provided and the value is either 1 or 0.
    # Both of these are provided to make it more convenient for tools that read the
    # macro values and to match the Nios II conventions.
    proc_set_module_embeddedsw_cmacro_assignment debug_port "[ get_parameter_value debug_port_present ]"
    if { [ get_parameter_value debug_port_present ] } {
        proc_set_module_embeddedsw_cmacro_assignment debug_port_present ""
    }
    proc_set_module_embeddedsw_cmacro_assignment soft_reset "[ get_parameter_value soft_reset_present ]"
    if { [ get_parameter_value soft_reset_present ] } {
        proc_set_module_embeddedsw_cmacro_assignment soft_reset_present ""
    }
    proc_set_module_embeddedsw_cmacro_assignment nmi "[ get_parameter_value nmi_present ]"
    if { [ get_parameter_value nmi_present ] } {
        proc_set_module_embeddedsw_cmacro_assignment nmi_present ""
    }
    proc_set_module_embeddedsw_cmacro_assignment big_endian "[ get_parameter_value big_endian ]"  
    if { [ get_parameter_value big_endian ] } {
        proc_set_module_embeddedsw_cmacro_assignment big_endian_present ""
    }
    proc_set_module_embeddedsw_cmacro_assignment eic "[ get_parameter_value eic_present ]"
    if { [ get_parameter_value eic_present ] } {
        proc_set_module_embeddedsw_cmacro_assignment eic_present ""
    }
    proc_set_module_embeddedsw_cmacro_assignment mmu "[ get_parameter_value mmu_present ]"
    if { [ get_parameter_value mmu_present ] } {
        proc_set_module_embeddedsw_cmacro_assignment mmu_present ""

        proc_set_module_embeddedsw_cmacro_assignment tlb "[ get_parameter_value tlb_present ]"
        if { [ get_parameter_value tlb_present ] } {
            proc_set_module_embeddedsw_cmacro_assignment tlb_present ""

            proc_set_module_embeddedsw_cmacro_assignment tlb_num_entries "[ get_parameter_value tlb_num_entries ]"
            proc_set_module_embeddedsw_cmacro_assignment tlb_ptr_sz "[ get_parameter_value tlb_ptr_sz ]"
        }
    } else {
        proc_set_module_embeddedsw_cmacro_assignment tlb "0"
    }
}
proc sub_validate_update_module_embeddedsw_configurations {} {
    # Create most of the embeddedsw assignments in the configuration namespace.
    # Note that "reset_slave" is set elsewhere.
    proc_set_module_embeddedsw_configuration_assignment "cpuArchitecture" "MIPS32"
    proc_set_module_embeddedsw_configuration_assignment hdl_sim_caches_cleared "[ get_parameter_value hdl_sim_caches_cleared ]"
    proc_set_module_embeddedsw_configuration_assignment reset_offset "[ get_parameter_value reset_offset ]"
    if { [ get_parameter_value debug_port_present ] } {
        proc_set_module_embeddedsw_configuration_assignment debug_slave "[ get_parameter_value debug_slave ]"
    }
}
proc sub_elaborate_update_mp32_port_width {} {
    global I_MASTER_INTF
    global D_MASTER_INTF

    # Calculate the width of i_address and d_address
    if { [ get_parameter_value inst_addr_width ] } {
        set_port_property i_address WIDTH [ get_parameter_value inst_addr_width ]
    }
    if { [ get_parameter_value data_addr_width ] } {
        set_port_property d_address WIDTH [ get_parameter_value data_addr_width ]
    }
}
proc sub_elaborate_add_debug_port_interface {} {
    global DEBUG_INTF

    # Add debug port interface is enabled
    if { [ get_parameter_value debug_port_present ] } {
        add_interface           $DEBUG_INTF     "conduit"           "start"
        add_interface_port      $DEBUG_INTF     "debug_mode"        "export"            "output"    1
        add_interface_port      $DEBUG_INTF     "debug_dcr_int_e"   "export"            "input"     1
        add_interface_port      $DEBUG_INTF     "debug_intr"        "export"            "input"     1
        add_interface_port      $DEBUG_INTF     "debug_boot"        "export"            "input"     1
        add_interface_port      $DEBUG_INTF     "debug_probe_trap"  "export"            "input"     1
        add_interface_port      $DEBUG_INTF     "debug_hwbp"        "export"            "input"     1
        add_interface_port      $DEBUG_INTF     "debug_dpc"         "export"            "output"    30
        add_interface_port      $DEBUG_INTF     "debug_een"         "export"            "output"    1
        add_interface_port      $DEBUG_INTF     "debug_evalid"      "export"            "output"    1
    }
}
proc sub_generate_create_mp32_configuration {output_directory output_name} {
    set mp32_config_file "$output_directory/${output_name}_mp32_configuration.pl"
    set mp32_config [open $mp32_config_file "w"]

    puts $mp32_config "# mp32 Configuration File"
    puts $mp32_config "return {"
    puts $mp32_config "[ proc_get_mp32_infos_string ]"
    puts $mp32_config "[ proc_get_avalon_master_info_string ]"
    puts $mp32_config "};"
    
    close $mp32_config
}
proc sub_generate_create_mp32_rtl {output_directory output_name language simgen} {
    set mp32_config_file  "$output_directory/${output_name}_mp32_configuration.pl"
    # Directory
    set QUARTUS_ROOTDIR         [ get_project_property QUARTUS_ROOTDIR ]
    set COMPONENT_DIR           [ get_module_property MODULE_DIRECTORY ]
    set SOPC_BUILDER_BIN_DIR    "$QUARTUS_ROOTDIR/sopc_builder/bin"
    set EUROPA_DIR              "$SOPC_BUILDER_BIN_DIR/europa"
    set PERLLIB_DIR             "$SOPC_BUILDER_BIN_DIR/perl_lib"
    set CPU_LIB_DIR             "$COMPONENT_DIR/cpu_lib"
    set NIOS_LIB_DIR            "$COMPONENT_DIR/nios_lib"

    # Paths to normal and encypted perl scripts.
    set normal_perl_script "$COMPONENT_DIR/generate_rtl.pl"
    set eperl_script "$COMPONENT_DIR/generate_rtl.epl"

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
            "--" \
            $perl_script \
            --name=$output_name \
            --dir=$output_directory \
            --quartus_dir=$QUARTUS_ROOTDIR \
            --[ string tolower $language ] \
            --config=$mp32_config_file
    ]
    
    if { "$simgen" == "" } {
        append exec_list     "  --do_build_sim=0  "
    } else {
        append exec_list     "  --do_build_sim=1  "
        append exec_list     "  --sim_dir=$output_directory  "
    }
    
    send_message Info "Starting RTL generation for module '$output_name'"
    send_message Info "  Generation command is \[$exec_list\]"
    set gen_output [ eval $exec_list ]
    foreach output_string [ split $gen_output "\n" ] {
        send_message Info $output_string
    }
    send_message Info "Done RTL generation for module '$output_name'"
}
proc validate {} {
    sub_validate_update_parameterization_gui
    sub_validate_update_mp32_info_parameters
    sub_validate_update_master_slave_infos
    sub_validate_check_module
    sub_validate_update_module_embeddedsw_cmacros
    sub_validate_update_module_embeddedsw_configurations
}
proc elaborate {} {
    sub_elaborate_update_mp32_port_width
    sub_elaborate_add_debug_port_interface
}
proc generate {output_directory output_name language simgen} {
    sub_generate_create_mp32_configuration $output_directory $output_name
    sub_generate_create_mp32_rtl $output_directory $output_name $language $simgen
}
proc sub_sim_vhdl {NAME} {
    set output_directory [ add_fileset_file dummy.txt OTHER TEMP "" ]
    set language "vhdl"
    set language_set "VHDL"
    set simgen  1

    generate $output_directory $NAME $language $simgen
    sub_add_fileset "$NAME" "$output_directory" "$language_set" "$simgen"
}
proc sub_sim_verilog {NAME} {
    set output_directory [ add_fileset_file dummy.txt OTHER TEMP "" ]
    set language "verilog"
    set language_set "VERILOG"
    set simgen  1
    
    generate $output_directory $NAME $language $simgen
    sub_add_fileset "$NAME" "$output_directory" "$language_set" "$simgen"
}
proc sub_quartus_synth {NAME} {
    set output_directory [ add_fileset_file dummy.txt OTHER TEMP "" ]
    set language "verilog"
    set language_set "VERILOG"
    set simgen  0
    
    generate $output_directory $NAME $language $simgen
    sub_add_fileset "$NAME" "$output_directory" "$language_set" "$simgen"
}

proc sub_add_fileset {NAME output_directory rtl_ext simgen} {
    set gen_files [ glob ${output_directory}${NAME}* ]
    set is_encrypt [ get_parameter_value always_encrypt ]

    if { "$rtl_ext" == "VHDL" } {
        set rtl_sim_ext "vho"
        set rtl_file "vhd"
    } else {
        set rtl_sim_ext "vo"
        set rtl_file "v"
    }
    
    # Add RTL files
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
                add_fileset_file "$file_name" $rtl_ext PATH "$my_file"
            }
        } elseif { [ string match "*.${rtl_file}" "$file_name" ] } {
            # checking for encryption
            if { $is_encrypt && [ string match "${NAME}.${rtl_ext}" "$file_name" ] } {
                # only Verilog files are used for synthesis
                if { [ expr { ! $simgen } || { "$rtl_ext" == "VHDL" } ] } {
                    add_fileset_file "$file_name" ${rtl_ext}_ENCRYPT PATH "$my_file"
                }
            } else {
                add_fileset_file "$file_name" $rtl_ext PATH "$my_file"
            }
        } else {
            add_fileset_file "$file_name" OTHER PATH "$my_file"
        }
    }
}
